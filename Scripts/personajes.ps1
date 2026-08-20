# ==========================================
# MÓDULO SATELLITE: GESTIÓN DE PERSONAJES (PDUMP)
# ==========================================

# Importación de la API de Windows independiente para el foco de la consola
$SigUser32Pj = '[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);'
Add-Type -MemberDefinition $SigUser32Pj -Name Win32WindowPersonajes -Namespace Win32FunctionsPersonajes -ErrorAction SilentlyContinue

Function Enviar-ComandoWorldServerPj($comando, $subForm, $parentForm) {
    $procWorld = Get-Process -Name "worldserver" -ErrorAction SilentlyContinue
    if (-not $procWorld) {
        [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgNoWorld" "WorldServer offline."), "Error", 'OK', 'Error')
        return $false
    }
    
    # Traer consola al frente temporalmente
    [Win32FunctionsPersonajes.Win32WindowPersonajes]::SetForegroundWindow($procWorld.MainWindowHandle) | Out-Null
    Start-Sleep -Milliseconds 250
    
    # Simular teclado letra por letra para evitar teclas repetidas en la consola de AzerothCore/TrinityCore
    foreach ($letra in $comando.ToCharArray()) {
        # Escapamos caracteres especiales por si el nombre contiene alguno
        if ($letra -match '[+^%~(){}]') {
            [System.Windows.Forms.SendKeys]::SendWait("{$letra}")
        } else {
            [System.Windows.Forms.SendKeys]::SendWait($letra.ToString())
        }
        # Micropausa para que el motor del emulador no duplique las letras
        Start-Sleep -Milliseconds 20
    }
    
    Start-Sleep -Milliseconds 50
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Milliseconds 100
    
    # Devolver foco al panel gráfico
    [Win32FunctionsPersonajes.Win32WindowPersonajes]::SetForegroundWindow($parentForm.Handle) | Out-Null
    return $true
}

# ------------------------------------------
# HERMANDAD (GUILD): GENERADOR DE SQL CON MARCADORES DE ID
# AzerothCore no tiene un comando de consola tipo "pdump" para hermandades,
# asi que generamos el SQL de exportacion como TEXTO PLANO (igual que una
# herramienta de creacion de NPCBots): se ve exactamente lo que se va a
# insertar, con 3 marcadores (@@GUILDID@@, @@GMGUID@@, @@ITEMBASE@@) que se
# sustituyen con un boton antes de guardar/inyectar. Nada oculto.
#
# Tablas incluidas (columnas confirmadas en la wiki oficial de AzerothCore):
#   guild, guild_rank, guild_bank_tab, guild_bank_right, guild_member (solo GM),
#   guild_member_withdraw (solo GM), guild_bank_item, item_instance (objetos
#   del banco), guild_eventlog, guild_bank_eventlog (historial).
# ------------------------------------------

$Global:NombreBDCharacters = "acore_characters"
$Global:MysqlUser = "acore"
$Global:MysqlPass = "acore"

Function Obtener-RutaMysqlExe { return (Join-Path $Global:MysqlDir "mysql.exe") }

# Establece la contraseña vía variable de entorno para que mysql.exe no
# muestre el aviso "Using a password on the command line interface..."
Function Preparar-EntornoMysql { $env:MYSQL_PWD = $Global:MysqlPass }

Function Obtener-FilasCrudo($consulta) {
    Preparar-EntornoMysql
    $mysqlExe = Obtener-RutaMysqlExe
    $filas = & $mysqlExe "-u$Global:MysqlUser" -N -B -e $consulta $Global:NombreBDCharacters 2>$null
    $limpias = @()
    foreach ($f in @($filas)) {
        if ($null -ne $f) {
            $t = $f.TrimEnd("`r")
            if ($t -and $t -notmatch '^(mysql:|Warning|ERROR)') { $limpias += $t }
        }
    }
    return ,$limpias
}

# Ejecuta la consulta capturando el error REAL de MySQL (si lo hay)
Function Obtener-ErrorMysql($consulta) {
    Preparar-EntornoMysql
    $mysqlExe = Obtener-RutaMysqlExe
    if (-not (Test-Path $mysqlExe)) { return "No se encontro mysql.exe en: $mysqlExe" }
    $salidaCruda = & $mysqlExe "-u$Global:MysqlUser" -N -B -e $consulta $Global:NombreBDCharacters 2>&1
    $lineas = @()
    foreach ($item in @($salidaCruda)) {
        $texto = $item.ToString().TrimEnd("`r")
        if ($texto -and $texto -notmatch 'Using a password on the command line') { $lineas += $texto }
    }
    return ($lineas -join "`n").Trim()
}

# Obtiene el listado real de columnas de una tabla (solo se usa para
# guild_member_withdraw, cuya documentacion oficial tiene una errata)
Function Obtener-ColumnasTabla($tabla) {
    $filas = Obtener-FilasCrudo "SHOW COLUMNS FROM $tabla;"
    $columnas = @()
    foreach ($fila in $filas) {
        $partes = $fila -split "`t"
        if ($partes.Count -ge 1 -and $partes[0]) { $columnas += $partes[0] }
    }
    return ,$columnas
}

Function Escapar-SQL($valor) {
    if ($null -eq $valor -or $valor -eq '\N') { return "NULL" }
    $escapado = $valor.Replace("\", "\\").Replace("'", "\'")
    return "'$escapado'"
}

# Busca el ID de una hermandad por su nombre. Devuelve $null si no existe.
Function Buscar-GuildID($nombreGuild) {
    $mysqlExe = Obtener-RutaMysqlExe
    if (-not (Test-Path $mysqlExe)) { return $null }
    $nombreEscape = $nombreGuild -replace "'", "''"
    $resultado = Obtener-FilasCrudo "SELECT guildid FROM guild WHERE name='$nombreEscape';"
    if ($resultado.Count -gt 0 -and $resultado[0] -match '^\d+$') { return [int]$resultado[0] }
    return $null
}

# Busca el GUID actual de un personaje por su nombre
Function Buscar-GuidPorNombre($nombrePersonaje) {
    $nombreEscape = $nombrePersonaje -replace "'", "''"
    $fila = Obtener-FilasCrudo "SELECT guid FROM characters WHERE name='$nombreEscape';"
    if ($fila.Count -gt 0 -and $fila[0] -match '^\d+$') { return $fila[0] }
    return $null
}

# Comprobacion rapida (sin modificar nada): busca la hermandad por nombre y
# verifica que su leaderguid enlaza correctamente con un personaje real y
# con una fila en guild_member.
Function Verificar-Hermandad($nombreGuild) {
    $guildId = Buscar-GuildID $nombreGuild
    if (-not $guildId) { return "No se encontro ninguna hermandad con ese nombre en este servidor." }

    $lineas = @("Hermandad '$nombreGuild' encontrada (guildid=$guildId).")
    $filaLeader = Obtener-FilasCrudo "SELECT leaderguid FROM guild WHERE guildid=$guildId;"
    if ($filaLeader.Count -eq 0) { $lineas += "No se pudo leer leaderguid."; return ($lineas -join "`n") }

    $leaderGuid = $filaLeader[0].Trim()
    $lineas += "leaderguid = $leaderGuid"

    $filaChar = Obtener-FilasCrudo "SELECT name FROM characters WHERE guid=$leaderGuid;"
    if ($filaChar.Count -eq 0) {
        $lineas += "ALERTA: no existe ningun personaje con guid=$leaderGuid en la tabla 'characters'."
    } else {
        $lineas += "El personaje con ese guid es: '$($filaChar[0].Trim())'"
    }

    $filaMember = Obtener-FilasCrudo "SELECT COUNT(*) FROM guild_member WHERE guildid=$guildId AND guid=$leaderGuid;"
    if ($filaMember.Count -gt 0 -and $filaMember[0].Trim() -eq "1") {
        $lineas += "OK: hay una fila en guild_member que enlaza ese guid con esta hermandad."
    } else {
        $lineas += "ALERTA: NO hay ninguna fila en guild_member para ese guid en esta hermandad."
    }

    # Comprobamos si ese personaje aparece TAMBIEN en otra hermandad distinta
    # (residuo de pruebas anteriores no borradas), que es la causa mas comun
    # de "en el juego veo cosas de otra hermandad".
    $filaOtrasGuilds = Obtener-FilasCrudo "SELECT guildid FROM guild_member WHERE guid=$leaderGuid AND guildid<>$guildId;"
    if ($filaOtrasGuilds.Count -gt 0) {
        $listaOtras = ($filaOtrasGuilds -join ", ")
        $lineas += "ALERTA: este personaje TAMBIEN aparece en guild_member de otra(s) hermandad(es) con guildid: $listaOtras. Si son restos de pruebas anteriores, borralas para evitar confusiones (el juego solo puede mostrar una a la vez)."
    } else {
        $lineas += "OK: este personaje no pertenece a ninguna otra hermandad en este servidor."
    }

    $filaBanco = Obtener-FilasCrudo "SELECT COUNT(*) FROM guild_bank_item WHERE guildid=$guildId;"
    $numItems = if ($filaBanco.Count -gt 0) { $filaBanco[0].Trim() } else { "0" }
    $lineas += "Objetos en el banco (guild_bank_item): $numItems"

    if ([int]$numItems -gt 0) {
        $filaDetalle = Obtener-FilasCrudo "SELECT gbi.TabId, gbi.SlotId, gbi.item_guid, ii.itemEntry FROM guild_bank_item gbi LEFT JOIN item_instance ii ON ii.guid = gbi.item_guid WHERE gbi.guildid=$guildId ORDER BY gbi.TabId, gbi.SlotId;"
        foreach ($f in $filaDetalle) {
            $v = $f -split "`t"
            if ($v.Count -ge 4) {
                if ($v[3] -and $v[3] -ne '\N') {
                    $lineas += "  - Pestana $($v[0]), slot $($v[1]): item_guid=$($v[2]), itemEntry=$($v[3])"
                } else {
                    $lineas += "  - Pestana $($v[0]), slot $($v[1]): item_guid=$($v[2]) -- ALERTA: no existe fila en item_instance para ese guid (objeto roto/vacio)."
                }
            }
        }
    }

    return ($lineas -join "`n")
}

# Genera el SQL completo de exportacion de una hermandad, como TEXTO, con
# marcadores @@GUILDID@@ / @@GMGUID@@ / @@ITEMBASE@@ sin sustituir todavia.
Function Generar-SQL-Hermandad($nombreGuild) {
    $resultado = @{ Exito = $false; Sql = ""; Mensaje = "" }

    $guildId = Buscar-GuildID $nombreGuild
    if (-not $guildId) { $resultado.Mensaje = "No se encontro ninguna hermandad con ese nombre."; return $resultado }

    $filaLeader = Obtener-FilasCrudo "SELECT leaderguid FROM guild WHERE guildid=$guildId;"
    if ($filaLeader.Count -eq 0) { $resultado.Mensaje = "No se pudo leer el leaderguid de la hermandad."; return $resultado }
    $leaderOriginal = $filaLeader[0].Trim()
    if (-not $leaderOriginal -or $leaderOriginal -eq "0") { $resultado.Mensaje = "La hermandad no tiene un GM valido (leaderguid vacio)."; return $resultado }

    $filaLeaderName = Obtener-FilasCrudo "SELECT name FROM characters WHERE guid=$leaderOriginal;"
    $nombreGM = if ($filaLeaderName.Count -gt 0) { $filaLeaderName[0].Trim() } else { "(desconocido)" }

    $L = @()
    $L += "-- ================================================================"
    $L += "-- BACKUP DE HERMANDAD: $nombreGuild"
    $L += "-- GM original: $nombreGM (GUID original: $leaderOriginal)"
    $L += "-- Generado: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    $L += "-- ================================================================"
    $L += "-- Solo se incluye al GM como miembro (el resto debera reunirse de"
    $L += "-- nuevo en el juego, para evitar conflictos de GUID de otros personajes)."
    $L += "-- Marcadores a sustituir con el boton 'Aplicar IDs':"
    $L += "--   @@GUILDID@@  -> nuevo ID de la hermandad en este servidor"
    $L += "--   @@GMGUID@@   -> GUID actual del personaje GM en este servidor"
    $L += "--   @@ITEMBASE@@ -> primer GUID de item libre en este servidor"
    $L += ""
    $L += "START TRANSACTION;"
    $L += ""

    # --- guild ---
    $fila = Obtener-FilasCrudo "SELECT guildid,name,leaderguid,EmblemStyle,EmblemColor,BorderStyle,BorderColor,BackgroundColor,info,motd,createdate,BankMoney FROM guild WHERE guildid=$guildId;"
    if ($fila.Count -gt 0) {
        $v = $fila[0] -split "`t"
        $L += "-- guild"
        $L += "INSERT INTO ``guild`` (``guildid``,``name``,``leaderguid``,``EmblemStyle``,``EmblemColor``,``BorderStyle``,``BorderColor``,``BackgroundColor``,``info``,``motd``,``createdate``,``BankMoney``) VALUES (@@GUILDID@@, $(Escapar-SQL $v[1]), @@GMGUID@@, $($v[3]), $($v[4]), $($v[5]), $($v[6]), $($v[7]), $(Escapar-SQL $v[8]), $(Escapar-SQL $v[9]), $($v[10]), $($v[11]));"
        $L += ""
    }

    # --- guild_rank ---
    $filas = Obtener-FilasCrudo "SELECT guildid,rid,rname,rights,BankMoneyPerDay FROM guild_rank WHERE guildid=$guildId;"
    if ($filas.Count -gt 0) {
        $L += "-- guild_rank"
        foreach ($f in $filas) {
            $v = $f -split "`t"
            $L += "INSERT INTO ``guild_rank`` (``guildid``,``rid``,``rname``,``rights``,``BankMoneyPerDay``) VALUES (@@GUILDID@@, $($v[1]), $(Escapar-SQL $v[2]), $($v[3]), $($v[4]));"
        }
        $L += ""
    }

    # --- guild_bank_tab ---
    $filas = Obtener-FilasCrudo "SELECT guildid,TabId,TabName,TabIcon,TabText FROM guild_bank_tab WHERE guildid=$guildId;"
    if ($filas.Count -gt 0) {
        $L += "-- guild_bank_tab (pestanas del banco, incluye las pestanas ya compradas)"
        foreach ($f in $filas) {
            $v = $f -split "`t"
            $L += "INSERT INTO ``guild_bank_tab`` (``guildid``,``TabId``,``TabName``,``TabIcon``,``TabText``) VALUES (@@GUILDID@@, $($v[1]), $(Escapar-SQL $v[2]), $(Escapar-SQL $v[3]), $(Escapar-SQL $v[4]));"
        }
        $L += ""
    }

    # --- guild_bank_right ---
    $filas = Obtener-FilasCrudo "SELECT guildid,TabId,rid,gbright,SlotPerDay FROM guild_bank_right WHERE guildid=$guildId;"
    if ($filas.Count -gt 0) {
        $L += "-- guild_bank_right"
        foreach ($f in $filas) {
            $v = $f -split "`t"
            $L += "INSERT INTO ``guild_bank_right`` (``guildid``,``TabId``,``rid``,``gbright``,``SlotPerDay``) VALUES (@@GUILDID@@, $($v[1]), $($v[2]), $($v[3]), $($v[4]));"
        }
        $L += ""
    }

    # --- guild_member (solo el GM) ---
    $L += "-- guild_member (solo el GM)"
    $L += "INSERT INTO ``guild_member`` (``guildid``,``guid``,``rank``,``pnote``,``offnote``) VALUES (@@GUILDID@@, @@GMGUID@@, 0, '', '');"
    $L += ""

    # --- guild_member_withdraw (columnas dinamicas; solo fila del GM) ---
    $colsWithdraw = Obtener-ColumnasTabla "guild_member_withdraw"
    if ($colsWithdraw.Count -gt 0) {
        $listaColsW = $colsWithdraw -join ","
        $filas = Obtener-FilasCrudo "SELECT $listaColsW FROM guild_member_withdraw WHERE guid=$leaderOriginal;"
        if ($filas.Count -gt 0) {
            $L += "-- guild_member_withdraw"
            $colsQuoted = ($colsWithdraw | ForEach-Object { '`' + $_ + '`' }) -join ","
            foreach ($f in $filas) {
                $v = $f -split "`t"
                $valoresFinales = @()
                for ($i = 0; $i -lt $colsWithdraw.Count; $i++) {
                    if ($colsWithdraw[$i] -eq "guid") { $valoresFinales += "@@GMGUID@@" }
                    else { $valoresFinales += $v[$i] }
                }
                $L += "INSERT INTO ``guild_member_withdraw`` ($colsQuoted) VALUES (" + ($valoresFinales -join ",") + ");"
            }
            $L += ""
        }
    }

    # --- Objetos del banco: item_instance + guild_bank_item ---
    $filasItems = Obtener-FilasCrudo "SELECT guid,itemEntry,owner_guid,creatorGuid,giftCreatorGuid,count,duration,charges,flags,enchantments,randomPropertyId,durability,playedTime,text FROM item_instance WHERE guid IN (SELECT item_guid FROM guild_bank_item WHERE guildid=$guildId);"
    $mapaItems = @{}
    $indice = 0
    foreach ($f in $filasItems) {
        $guidOriginal = ($f -split "`t")[0]
        if ($guidOriginal -and -not $mapaItems.ContainsKey($guidOriginal)) {
            $mapaItems[$guidOriginal] = $indice
            $indice++
        }
    }

    if ($filasItems.Count -gt 0) {
        $L += "-- item_instance (objetos guardados en el banco)"
        foreach ($f in $filasItems) {
            $v = $f -split "`t"
            $guidOriginal = $v[0]
            $expresionGuid = "(@@ITEMBASE@@+$($mapaItems[$guidOriginal]))"
            $L += "INSERT INTO ``item_instance`` (``guid``,``itemEntry``,``owner_guid``,``creatorGuid``,``giftCreatorGuid``,``count``,``duration``,``charges``,``flags``,``enchantments``,``randomPropertyId``,``durability``,``playedTime``,``text``) VALUES ($expresionGuid, $($v[1]), $($v[2]), $($v[3]), $($v[4]), $($v[5]), $($v[6]), $(Escapar-SQL $v[7]), $($v[8]), $(Escapar-SQL $v[9]), $($v[10]), $($v[11]), $($v[12]), $(Escapar-SQL $v[13]));"
        }
        $L += ""
    }

    $filasBankItem = Obtener-FilasCrudo "SELECT guildid,TabId,SlotId,item_guid FROM guild_bank_item WHERE guildid=$guildId;"
    if ($filasBankItem.Count -gt 0) {
        $L += "-- guild_bank_item (enlaza cada objeto con su pestana/slot del banco)"
        foreach ($f in $filasBankItem) {
            $v = $f -split "`t"
            $itemGuidOriginal = $v[3]
            $expresionGuid = if ($mapaItems.ContainsKey($itemGuidOriginal)) { "(@@ITEMBASE@@+$($mapaItems[$itemGuidOriginal]))" } else { "0" }
            $L += "INSERT INTO ``guild_bank_item`` (``guildid``,``TabId``,``SlotId``,``item_guid``) VALUES (@@GUILDID@@, $($v[1]), $($v[2]), $expresionGuid);"
        }
        $L += ""
    }

    # --- Historial (opcional, no afecta al funcionamiento) ---
    $filas = Obtener-FilasCrudo "SELECT guildid,LogGuid,EventType,PlayerGuid1,PlayerGuid2,NewRank,timestamp FROM guild_eventlog WHERE guildid=$guildId;"
    if ($filas.Count -gt 0) {
        $L += "-- guild_eventlog (historial de eventos, informativo)"
        foreach ($f in $filas) {
            $v = $f -split "`t"
            $L += "INSERT INTO ``guild_eventlog`` (``guildid``,``LogGuid``,``EventType``,``PlayerGuid1``,``PlayerGuid2``,``NewRank``,``timestamp``) VALUES (@@GUILDID@@, $($v[1]), $($v[2]), $($v[3]), $($v[4]), $($v[5]), $($v[6]));"
        }
        $L += ""
    }

    $filas = Obtener-FilasCrudo "SELECT guildid,LogGuid,TabId,EventType,PlayerGuid,ItemOrMoney,ItemStackCount,DestTabId,TimeStamp FROM guild_bank_eventlog WHERE guildid=$guildId;"
    if ($filas.Count -gt 0) {
        $L += "-- guild_bank_eventlog (historial del banco, informativo)"
        foreach ($f in $filas) {
            $v = $f -split "`t"
            $L += "INSERT INTO ``guild_bank_eventlog`` (``guildid``,``LogGuid``,``TabId``,``EventType``,``PlayerGuid``,``ItemOrMoney``,``ItemStackCount``,``DestTabId``,``TimeStamp``) VALUES (@@GUILDID@@, $($v[1]), $($v[2]), $($v[3]), $($v[4]), $($v[5]), $($v[6]), $($v[7]), $($v[8]));"
        }
        $L += ""
    }

    $L += "COMMIT;"

    $resultado.Exito = $true
    $resultado.Sql = ($L -join "`n")
    return $resultado
}

# Sustituye los 3 marcadores por los valores indicados (simple find & replace,
# nada oculto: lo que ves en el cuadro de texto es exactamente lo que se
# guardara/inyectara).
Function Aplicar-IDs-SQL($texto, $nuevoGuildId, $nuevoGmGuid, $itemBase) {
    $resultado = $texto
    if ($nuevoGuildId) { $resultado = $resultado.Replace("@@GUILDID@@", [string]$nuevoGuildId) }
    if ($nuevoGmGuid)  { $resultado = $resultado.Replace("@@GMGUID@@", [string]$nuevoGmGuid) }
    if ($itemBase)     { $resultado = $resultado.Replace("@@ITEMBASE@@", [string]$itemBase) }
    return $resultado
}

# Inyecta el texto SQL (ya con los IDs aplicados) directamente en este servidor.
Function Inyectar-SQL($texto) {
    $resultado = @{ Exito = $false; Mensaje = "" }
    $mysqlExe = Obtener-RutaMysqlExe
    if (-not (Test-Path $mysqlExe)) { $resultado.Mensaje = "No se encontro mysql.exe en: $mysqlExe"; return $resultado }
    if ($texto -match '@@\w+@@') {
        $resultado.Mensaje = "El SQL todavia tiene marcadores sin sustituir (@@...@@). Pulsa 'Aplicar IDs' primero."
        return $resultado
    }
    Preparar-EntornoMysql
    $salida = ($texto | & $mysqlExe "-u$Global:MysqlUser" $Global:NombreBDCharacters 2>&1 | Out-String).Trim()
    $resultado.Exito = ($LASTEXITCODE -eq 0)
    $resultado.Mensaje = $salida
    return $resultado
}

# Version generica: permite elegir a que base de datos se inyecta (por ejemplo
# acore_world para NPCBots/creature_template, en vez de acore_characters).
Function Inyectar-SQL-EnBD($texto, $baseDatos) {
    $resultado = @{ Exito = $false; Mensaje = "" }
    $mysqlExe = Obtener-RutaMysqlExe
    if (-not (Test-Path $mysqlExe)) { $resultado.Mensaje = "No se encontro mysql.exe en: $mysqlExe"; return $resultado }
    if (-not $baseDatos) { $resultado.Mensaje = "Indica una base de datos."; return $resultado }
    Preparar-EntornoMysql
    $salida = ($texto | & $mysqlExe "-u$Global:MysqlUser" $baseDatos 2>&1 | Out-String).Trim()
    $resultado.Exito = ($LASTEXITCODE -eq 0)
    $resultado.Mensaje = $salida
    return $resultado
}

# ------------------------------------------
# VENTANA GENERICA: INYECTAR SQL (pegar y ejecutar directamente)
# Pensada para el SQL generado por herramientas externas como el
# Generador de NPCBots (HTML), pero sirve para cualquier SQL suelto.
# ------------------------------------------
Function Abrir-PanelInyectarSQL($parentForm) {
    $subForm = New-Object System.Windows.Forms.Form
    $subForm.Text = Obtener-Texto "TituloInyectarSQL" "Inyectar SQL"
    $subForm.Size = New-Object System.Drawing.Size(700, 560)
    $subForm.StartPosition = 'CenterParent'
    $subForm.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
    $subForm.ForeColor = [System.Drawing.Color]::White
    $subForm.FormBorderStyle = 'FixedDialog'
    $subForm.MaximizeBox = $false
    $subForm.MinimizeBox = $false

    $fLabel = New-Object System.Drawing.Font("Georgia", 9)
    $fMono = New-Object System.Drawing.Font("Consolas", 9)
    $fBold = New-Object System.Drawing.Font("Georgia", 9, [System.Drawing.FontStyle]::Bold)
    $fAvisoLocal = New-Object System.Drawing.Font("Georgia", 8, [System.Drawing.FontStyle]::Italic)

    $lblDB = New-Object System.Windows.Forms.Label
    $lblDB.Text = Obtener-Texto "LblBaseDatos" "Base de datos destino:"
    $lblDB.Location = New-Object System.Drawing.Point(15, 15)
    $lblDB.Size = New-Object System.Drawing.Size(140, 20)
    $lblDB.Font = $fLabel
    $subForm.Controls.Add($lblDB)

    $cmbDB = New-Object System.Windows.Forms.ComboBox
    $cmbDB.Location = New-Object System.Drawing.Point(155, 12)
    $cmbDB.Size = New-Object System.Drawing.Size(200, 22)
    $cmbDB.Font = $fLabel
    $cmbDB.DropDownStyle = 'DropDown'
    [void]$cmbDB.Items.Add("acore_world")
    [void]$cmbDB.Items.Add("acore_characters")
    [void]$cmbDB.Items.Add("acore_auth")
    $cmbDB.Text = "acore_world"
    $subForm.Controls.Add($cmbDB)

    $lblAvisoDB = New-Object System.Windows.Forms.Label
    $lblAvisoDB.Text = Obtener-Texto "MsgAvisoNPCBotsDB" "Nota: el SQL del Generador de NPCBots normalmente va en 'acore_world' (creature_template y similares)."
    $lblAvisoDB.Location = New-Object System.Drawing.Point(370, 15)
    $lblAvisoDB.Size = New-Object System.Drawing.Size(310, 34)
    $lblAvisoDB.Font = $fAvisoLocal
    $lblAvisoDB.ForeColor = [System.Drawing.Color]::Goldenrod
    $subForm.Controls.Add($lblAvisoDB)

    $txtSqlInyectar = New-Object System.Windows.Forms.TextBox
    $txtSqlInyectar.Location = New-Object System.Drawing.Point(15, 60)
    $txtSqlInyectar.Size = New-Object System.Drawing.Size(660, 380)
    $txtSqlInyectar.Multiline = $true
    $txtSqlInyectar.ScrollBars = 'Both'
    $txtSqlInyectar.WordWrap = $false
    $txtSqlInyectar.Font = $fMono
    $txtSqlInyectar.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
    $txtSqlInyectar.ForeColor = [System.Drawing.Color]::FromArgb(180, 230, 180)
    $txtSqlInyectar.AcceptsTab = $true
    $subForm.Controls.Add($txtSqlInyectar)

    $btnPegar = New-Object System.Windows.Forms.Button
    $btnPegar.Text = Obtener-Texto "BtnPegarPortapapeles" "Pegar del portapapeles"
    $btnPegar.Location = New-Object System.Drawing.Point(15, 450)
    $btnPegar.Size = New-Object System.Drawing.Size(190, 30)
    $btnPegar.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $btnPegar.FlatStyle = 'Flat'
    $btnPegar.Font = $fLabel
    $btnPegar.Add_Click({
        if ([System.Windows.Forms.Clipboard]::ContainsText()) {
            $txtSqlInyectar.Text = [System.Windows.Forms.Clipboard]::GetText()
        }
    })
    $subForm.Controls.Add($btnPegar)

    $btnLimpiar = New-Object System.Windows.Forms.Button
    $btnLimpiar.Text = Obtener-Texto "BtnLimpiar" "Limpiar"
    $btnLimpiar.Location = New-Object System.Drawing.Point(215, 450)
    $btnLimpiar.Size = New-Object System.Drawing.Size(110, 30)
    $btnLimpiar.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $btnLimpiar.FlatStyle = 'Flat'
    $btnLimpiar.Font = $fLabel
    $btnLimpiar.Add_Click({ $txtSqlInyectar.Text = "" })
    $subForm.Controls.Add($btnLimpiar)

    $btnInyectarGenerico = New-Object System.Windows.Forms.Button
    $btnInyectarGenerico.Text = Obtener-Texto "BtnInyectarSql" "Inyectar en este servidor"
    $btnInyectarGenerico.Location = New-Object System.Drawing.Point(335, 450)
    $btnInyectarGenerico.Size = New-Object System.Drawing.Size(200, 30)
    $btnInyectarGenerico.BackColor = [System.Drawing.Color]::SeaGreen
    $btnInyectarGenerico.FlatStyle = 'Flat'
    $btnInyectarGenerico.Font = $fBold
    $btnInyectarGenerico.Add_Click({
        $sqlTexto = $txtSqlInyectar.Text
        if (-not $sqlTexto.Trim()) { return }
        $baseDatos = $cmbDB.Text.Trim()
        if (-not $baseDatos) {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgFaltaBaseDatos" "Indica una base de datos destino."), "Error", 'OK', 'Error')
            return
        }
        $confirmacion = [System.Windows.Forms.MessageBox]::Show(
            ((Obtener-Texto "MsgConfirmarInyectarGenerico" "Esto va a ejecutar el SQL directamente sobre la base de datos '{0}' de este servidor. Continuar?") -f $baseDatos),
            "Confirmar", 'YesNo', 'Warning')
        if ($confirmacion -ne 'Yes') { return }

        $res = Inyectar-SQL-EnBD $sqlTexto $baseDatos
        if ($res.Exito) {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgInyectadoOKGenerico" "SQL inyectado correctamente."), "OK", 'OK', 'Information')
        } else {
            $msg = Obtener-Texto "MsgGuildError" "Error al procesar."
            if ($res.Mensaje) { $msg += "`n`n$($res.Mensaje)" }
            [System.Windows.Forms.MessageBox]::Show($msg, "Error", 'OK', 'Error')
        }
    })
    $subForm.Controls.Add($btnInyectarGenerico)

    $lblAvisoInyectar = New-Object System.Windows.Forms.Label
    $lblAvisoInyectar.Text = Obtener-Texto "MsgAvisoInyectarSql" "Revisa siempre el SQL antes de inyectarlo: se ejecuta tal cual, sin comprobaciones adicionales."
    $lblAvisoInyectar.Location = New-Object System.Drawing.Point(15, 488)
    $lblAvisoInyectar.Size = New-Object System.Drawing.Size(660, 20)
    $lblAvisoInyectar.Font = $fAvisoLocal
    $lblAvisoInyectar.ForeColor = [System.Drawing.Color]::Goldenrod
    $subForm.Controls.Add($lblAvisoInyectar)

    $btnCerrarInyectar = New-Object System.Windows.Forms.Button
    $btnCerrarInyectar.Text = Obtener-Texto "BtnCerrar" "Cerrar"
    $btnCerrarInyectar.Location = New-Object System.Drawing.Point(15, 512)
    $btnCerrarInyectar.Size = New-Object System.Drawing.Size(660, 30)
    $btnCerrarInyectar.BackColor = [System.Drawing.Color]::DimGray
    $btnCerrarInyectar.FlatStyle = 'Flat'
    $btnCerrarInyectar.Font = $fLabel
    $btnCerrarInyectar.Add_Click({ $subForm.Close() })
    $subForm.Controls.Add($btnCerrarInyectar)

    $subForm.ShowDialog() | Out-Null
}

# Lista los archivos .sql de backup de hermandad encontrados en la carpeta del WorldServer
Function Abrir-ListaGuildDumps($parentForm, $txtDestino) {
    $listForm = New-Object System.Windows.Forms.Form
    $listForm.Text = Obtener-Texto "TituloListaGuildDumps" "Backups de hermandad guardados"
    $listForm.Size = New-Object System.Drawing.Size(340, 420)
    $listForm.StartPosition = 'CenterParent'
    $listForm.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
    $listForm.ForeColor = [System.Drawing.Color]::White
    $listForm.FormBorderStyle = 'FixedDialog'
    $listForm.MaximizeBox = $false
    $listForm.MinimizeBox = $false

    $fListado = New-Object System.Drawing.Font("Georgia", 9)

    $lblInfo = New-Object System.Windows.Forms.Label
    $lblInfo.Text = Obtener-Texto "MsgCarpetaDumps" "Buscando en la carpeta del WorldServer:"
    $lblInfo.Location = New-Object System.Drawing.Point(15, 12)
    $lblInfo.Size = New-Object System.Drawing.Size(295, 18)
    $lblInfo.Font = $fListado
    $lblInfo.ForeColor = [System.Drawing.Color]::LightGray
    $listForm.Controls.Add($lblInfo)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(15, 35)
    $listBox.Size = New-Object System.Drawing.Size(295, 300)
    $listBox.Font = $fListado
    $listBox.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $listBox.ForeColor = [System.Drawing.Color]::White
    $listForm.Controls.Add($listBox)

    $hayArchivos = $false
    if (Test-Path $Global:WorldDir) {
        $candidatos = Get-ChildItem -Path $Global:WorldDir -File -Filter "*.sql" -ErrorAction SilentlyContinue
        $archivos = @()
        foreach ($candidato in $candidatos) {
            try {
                $primerasLineas = Get-Content -Path $candidato.FullName -TotalCount 5 -ErrorAction SilentlyContinue
                if ($primerasLineas -match "BACKUP DE HERMANDAD" -or $primerasLineas -match "GUILD BACKUP") {
                    $archivos += $candidato
                }
            } catch {}
        }
        $archivos = $archivos | Sort-Object LastWriteTime -Descending

        foreach ($archivo in $archivos) {
            $etiqueta = "$($archivo.Name)   [$($archivo.LastWriteTime.ToString('dd/MM/yyyy HH:mm'))]"
            $listBox.Items.Add($etiqueta) | Out-Null
        }
        if ($archivos.Count -gt 0) { $hayArchivos = $true }
    }

    if (-not $hayArchivos) {
        $listBox.Items.Add((Obtener-Texto "MsgNoGuildDumps" "No se encontraron backups de hermandad en esa carpeta.")) | Out-Null
        $listBox.Enabled = $false
    }

    $btnUsar = New-Object System.Windows.Forms.Button
    $btnUsar.Text = Obtener-Texto "BtnUsarArchivo" "Usar seleccionado"
    $btnUsar.Location = New-Object System.Drawing.Point(15, 345)
    $btnUsar.Size = New-Object System.Drawing.Size(295, 30)
    $btnUsar.BackColor = [System.Drawing.Color]::SteelBlue
    $btnUsar.FlatStyle = 'Flat'
    $btnUsar.Font = New-Object System.Drawing.Font("Georgia", 9, [System.Drawing.FontStyle]::Bold)

    $usarSeleccion = {
        if ($hayArchivos -and $listBox.SelectedItem) {
            $nombreArchivo = $listBox.SelectedItem.ToString().Split("   [")[0].Trim()
            $txtDestino.Text = $nombreArchivo
            $listForm.Close()
        }
    }
    $btnUsar.Add_Click($usarSeleccion)
    $listBox.Add_DoubleClick($usarSeleccion)
    $listForm.Controls.Add($btnUsar)

    $listForm.ShowDialog() | Out-Null
}

# ------------------------------------------
# VENTANA: EXPORTAR / INYECTAR HERMANDAD (SQL)
# ------------------------------------------
Function Abrir-PanelHermandadSQL($parentForm) {
    $subForm = New-Object System.Windows.Forms.Form
    $subForm.Text = Obtener-Texto "TituloHermandadSQL" "Hermandad: Generar / Inyectar SQL"
    $subForm.Size = New-Object System.Drawing.Size(790, 670)
    $subForm.StartPosition = 'CenterParent'
    $subForm.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
    $subForm.ForeColor = [System.Drawing.Color]::White
    $subForm.FormBorderStyle = 'FixedDialog'
    $subForm.MaximizeBox = $false
    $subForm.MinimizeBox = $false

    $fLabel = New-Object System.Drawing.Font("Georgia", 9)
    $fMono = New-Object System.Drawing.Font("Consolas", 9)
    $fBold = New-Object System.Drawing.Font("Georgia", 9, [System.Drawing.FontStyle]::Bold)

    # -- Fila: nombre de hermandad + generar/abrir --
    $lblNombreGuild = New-Object System.Windows.Forms.Label
    $lblNombreGuild.Text = Obtener-Texto "LblNombreGuildExportar" "Hermandad a exportar:"
    $lblNombreGuild.Location = New-Object System.Drawing.Point(15, 15)
    $lblNombreGuild.Size = New-Object System.Drawing.Size(140, 20)
    $lblNombreGuild.Font = $fLabel
    $subForm.Controls.Add($lblNombreGuild)

    $txtNombreGuild = New-Object System.Windows.Forms.TextBox
    $txtNombreGuild.Location = New-Object System.Drawing.Point(155, 12)
    $txtNombreGuild.Size = New-Object System.Drawing.Size(180, 20)
    $txtNombreGuild.Font = $fLabel
    $txtNombreGuild.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtNombreGuild.ForeColor = [System.Drawing.Color]::White
    $subForm.Controls.Add($txtNombreGuild)

    $txtSql = New-Object System.Windows.Forms.TextBox
    $txtSql.Location = New-Object System.Drawing.Point(15, 105)
    $txtSql.Size = New-Object System.Drawing.Size(745, 270)
    $txtSql.Multiline = $true
    $txtSql.ScrollBars = 'Both'
    $txtSql.WordWrap = $false
    $txtSql.Font = $fMono
    $txtSql.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
    $txtSql.ForeColor = [System.Drawing.Color]::FromArgb(180, 230, 180)

    $btnGenerar = New-Object System.Windows.Forms.Button
    $btnGenerar.Text = Obtener-Texto "BtnGenerarSql" "Generar SQL"
    $btnGenerar.Location = New-Object System.Drawing.Point(345, 12)
    $btnGenerar.Size = New-Object System.Drawing.Size(110, 24)
    $btnGenerar.BackColor = [System.Drawing.Color]::SeaGreen
    $btnGenerar.FlatStyle = 'Flat'
    $btnGenerar.Font = $fBold
    $btnGenerar.Add_Click({
        $nombre = $txtNombreGuild.Text.Trim()
        if (-not $nombre) { return }
        $res = Generar-SQL-Hermandad $nombre
        if ($res.Exito) {
            $txtSql.Text = $res.Sql
        } else {
            [System.Windows.Forms.MessageBox]::Show($res.Mensaje, "Error", 'OK', 'Error')
        }
    })
    $subForm.Controls.Add($btnGenerar)

    $btnGuardarDirecto = New-Object System.Windows.Forms.Button
    $btnGuardarDirecto.Text = Obtener-Texto "BtnGuardarHermandadDirecto" "Guardar Hermandad (genera + guarda .sql)"
    $btnGuardarDirecto.Location = New-Object System.Drawing.Point(15, 42)
    $btnGuardarDirecto.Size = New-Object System.Drawing.Size(300, 26)
    $btnGuardarDirecto.BackColor = [System.Drawing.Color]::SeaGreen
    $btnGuardarDirecto.FlatStyle = 'Flat'
    $btnGuardarDirecto.Font = $fBold
    $btnGuardarDirecto.Add_Click({
        $nombre = $txtNombreGuild.Text.Trim()
        if (-not $nombre) {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgFaltaNombreGuild" "Escribe el nombre de la hermandad primero."), "Error", 'OK', 'Error')
            return
        }
        $res = Generar-SQL-Hermandad $nombre
        if (-not $res.Exito) {
            [System.Windows.Forms.MessageBox]::Show($res.Mensaje, "Error", 'OK', 'Error')
            return
        }
        $txtSql.Text = $res.Sql
        $nombreArchivo = ($nombre -replace '[^a-zA-Z0-9_\-]', '_') + ".sql"
        $ruta = Join-Path $Global:WorldDir $nombreArchivo
        Set-Content -Path $ruta -Value $res.Sql -Encoding UTF8
        [System.Windows.Forms.MessageBox]::Show(((Obtener-Texto "MsgSqlGuardadoOK" "Guardado como '{0}' en la carpeta del WorldServer.") -f $nombreArchivo), "OK", 'OK', 'Information')
    })
    $subForm.Controls.Add($btnGuardarDirecto)

    $btnAbrirArchivo = New-Object System.Windows.Forms.Button
    $btnAbrirArchivo.Text = Obtener-Texto "BtnAbrirSqlGuardado" "Abrir .sql guardado..."
    $btnAbrirArchivo.Location = New-Object System.Drawing.Point(325, 42)
    $btnAbrirArchivo.Size = New-Object System.Drawing.Size(180, 26)
    $btnAbrirArchivo.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $btnAbrirArchivo.FlatStyle = 'Flat'
    $btnAbrirArchivo.Font = $fLabel
    $btnAbrirArchivo.Add_Click({
        $txtTemporal = New-Object System.Windows.Forms.TextBox
        Abrir-ListaGuildDumps $subForm $txtTemporal
        if ($txtTemporal.Text) {
            $ruta = Join-Path $Global:WorldDir $txtTemporal.Text
            if (Test-Path $ruta) { $txtSql.Text = Get-Content -Path $ruta -Raw -Encoding UTF8 }
        }
    })
    $subForm.Controls.Add($btnAbrirArchivo)

    $subForm.Controls.Add($txtSql)

    # -- Fila: nuevo ID hermandad --
    $lblIdGuild = New-Object System.Windows.Forms.Label
    $lblIdGuild.Text = Obtener-Texto "LblIdGuildNuevo" "Nuevo ID Hermandad:"
    $lblIdGuild.Location = New-Object System.Drawing.Point(15, 418)
    $lblIdGuild.Size = New-Object System.Drawing.Size(140, 20)
    $lblIdGuild.Font = $fLabel
    $subForm.Controls.Add($lblIdGuild)

    $txtIdGuild = New-Object System.Windows.Forms.TextBox
    $txtIdGuild.Location = New-Object System.Drawing.Point(155, 415)
    $txtIdGuild.Size = New-Object System.Drawing.Size(80, 20)
    $txtIdGuild.Font = $fLabel
    $txtIdGuild.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtIdGuild.ForeColor = [System.Drawing.Color]::White
    $subForm.Controls.Add($txtIdGuild)

    $btnAutoIdGuild = New-Object System.Windows.Forms.Button
    $btnAutoIdGuild.Text = Obtener-Texto "BtnAuto" "Auto"
    $btnAutoIdGuild.Location = New-Object System.Drawing.Point(240, 414)
    $btnAutoIdGuild.Size = New-Object System.Drawing.Size(55, 22)
    $btnAutoIdGuild.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $btnAutoIdGuild.FlatStyle = 'Flat'
    $btnAutoIdGuild.Font = $fLabel
    $btnAutoIdGuild.Add_Click({
        $fila = Obtener-FilasCrudo "SELECT IFNULL(MAX(guildid),0)+1 FROM guild;"
        if ($fila.Count -gt 0) { $txtIdGuild.Text = $fila[0].Trim() }
    })
    $subForm.Controls.Add($btnAutoIdGuild)

    # -- Fila: nombre/GUID del GM --
    $lblGmNombre = New-Object System.Windows.Forms.Label
    $lblGmNombre.Text = Obtener-Texto "LblGmNombreExistente" "Nombre del GM (ya cargado aqui):"
    $lblGmNombre.Location = New-Object System.Drawing.Point(15, 448)
    $lblGmNombre.Size = New-Object System.Drawing.Size(190, 20)
    $lblGmNombre.Font = $fLabel
    $subForm.Controls.Add($lblGmNombre)

    $txtGmNombre = New-Object System.Windows.Forms.TextBox
    $txtGmNombre.Location = New-Object System.Drawing.Point(205, 445)
    $txtGmNombre.Size = New-Object System.Drawing.Size(150, 20)
    $txtGmNombre.Font = $fLabel
    $txtGmNombre.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtGmNombre.ForeColor = [System.Drawing.Color]::White
    $subForm.Controls.Add($txtGmNombre)

    $lblGmGuid = New-Object System.Windows.Forms.Label
    $lblGmGuid.Text = Obtener-Texto "LblGmGuidCampo" "GUID:"
    $lblGmGuid.Location = New-Object System.Drawing.Point(365, 448)
    $lblGmGuid.Size = New-Object System.Drawing.Size(40, 20)
    $lblGmGuid.Font = $fLabel
    $subForm.Controls.Add($lblGmGuid)

    $txtGmGuid = New-Object System.Windows.Forms.TextBox
    $txtGmGuid.Location = New-Object System.Drawing.Point(405, 445)
    $txtGmGuid.Size = New-Object System.Drawing.Size(70, 20)
    $txtGmGuid.Font = $fLabel
    $txtGmGuid.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtGmGuid.ForeColor = [System.Drawing.Color]::White
    $subForm.Controls.Add($txtGmGuid)

    $btnBuscarGm = New-Object System.Windows.Forms.Button
    $btnBuscarGm.Text = Obtener-Texto "BtnBuscar" "Buscar"
    $btnBuscarGm.Location = New-Object System.Drawing.Point(480, 444)
    $btnBuscarGm.Size = New-Object System.Drawing.Size(60, 22)
    $btnBuscarGm.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $btnBuscarGm.FlatStyle = 'Flat'
    $btnBuscarGm.Font = $fLabel
    $btnBuscarGm.Add_Click({
        $nombre = $txtGmNombre.Text.Trim()
        if (-not $nombre) { return }
        $guid = Buscar-GuidPorNombre $nombre
        if ($guid) { $txtGmGuid.Text = $guid }
        else { [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgPersonajeNoEncontrado" "No se encontro ningun personaje con ese nombre en este servidor."), "Error", 'OK', 'Error') }
    })
    $subForm.Controls.Add($btnBuscarGm)

    # -- Fila: GUID base de objetos --
    $lblItemBase = New-Object System.Windows.Forms.Label
    $lblItemBase.Text = Obtener-Texto "LblItemBase" "GUID base para objetos del banco:"
    $lblItemBase.Location = New-Object System.Drawing.Point(15, 478)
    $lblItemBase.Size = New-Object System.Drawing.Size(210, 20)
    $lblItemBase.Font = $fLabel
    $subForm.Controls.Add($lblItemBase)

    $txtItemBase = New-Object System.Windows.Forms.TextBox
    $txtItemBase.Location = New-Object System.Drawing.Point(225, 475)
    $txtItemBase.Size = New-Object System.Drawing.Size(80, 20)
    $txtItemBase.Font = $fLabel
    $txtItemBase.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtItemBase.ForeColor = [System.Drawing.Color]::White
    $subForm.Controls.Add($txtItemBase)

    $btnAutoItemBase = New-Object System.Windows.Forms.Button
    $btnAutoItemBase.Text = Obtener-Texto "BtnAuto" "Auto"
    $btnAutoItemBase.Location = New-Object System.Drawing.Point(310, 474)
    $btnAutoItemBase.Size = New-Object System.Drawing.Size(55, 22)
    $btnAutoItemBase.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $btnAutoItemBase.FlatStyle = 'Flat'
    $btnAutoItemBase.Font = $fLabel
    $btnAutoItemBase.Add_Click({
        $fila = Obtener-FilasCrudo "SELECT IFNULL(MAX(guid),0)+100000 FROM item_instance;"
        if ($fila.Count -gt 0) { $txtItemBase.Text = $fila[0].Trim() }
    })
    $subForm.Controls.Add($btnAutoItemBase)

    # -- Aviso --
    $fAviso = New-Object System.Drawing.Font("Georgia", 8, [System.Drawing.FontStyle]::Italic)
    $lblAviso = New-Object System.Windows.Forms.Label
    $lblAviso.Text = Obtener-Texto "MsgAvisoHermandadSQL" "El personaje del GM debe existir YA en este servidor. RECOMENDADO: para el WorldServer antes de pulsar 'Inyectar' (evita que el objeto choque con GUIDs que el servidor reserva en memoria mientras esta encendido) y vuelve a arrancarlo despues."
    $lblAviso.Location = New-Object System.Drawing.Point(15, 504)
    $lblAviso.Size = New-Object System.Drawing.Size(745, 30)
    $lblAviso.ForeColor = [System.Drawing.Color]::Goldenrod
    $lblAviso.Font = $fAviso
    $subForm.Controls.Add($lblAviso)

    # -- Botones de accion --
    $btnAplicarIds = New-Object System.Windows.Forms.Button
    $btnAplicarIds.Text = Obtener-Texto "BtnAplicarIds" "Aplicar IDs al texto"
    $btnAplicarIds.Location = New-Object System.Drawing.Point(15, 540)
    $btnAplicarIds.Size = New-Object System.Drawing.Size(180, 30)
    $btnAplicarIds.BackColor = [System.Drawing.Color]::SteelBlue
    $btnAplicarIds.FlatStyle = 'Flat'
    $btnAplicarIds.Font = $fBold
    $btnAplicarIds.Add_Click({
        if (-not $txtSql.Text) { return }
        $txtSql.Text = Aplicar-IDs-SQL $txtSql.Text $txtIdGuild.Text.Trim() $txtGmGuid.Text.Trim() $txtItemBase.Text.Trim()
    })
    $subForm.Controls.Add($btnAplicarIds)

    $btnGuardarArchivo = New-Object System.Windows.Forms.Button
    $btnGuardarArchivo.Text = Obtener-Texto "BtnGuardarSqlArchivo" "Guardar en archivo .sql"
    $btnGuardarArchivo.Location = New-Object System.Drawing.Point(205, 540)
    $btnGuardarArchivo.Size = New-Object System.Drawing.Size(180, 30)
    $btnGuardarArchivo.BackColor = [System.Drawing.Color]::FromArgb(90, 60, 150)
    $btnGuardarArchivo.FlatStyle = 'Flat'
    $btnGuardarArchivo.Font = $fBold
    $btnGuardarArchivo.Add_Click({
        if (-not $txtSql.Text) { return }
        if ($txtSql.Text -notmatch '@@\w+@@') {
            $confirmacion = [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgAvisoGuardarModificado" "Este texto ya tiene los IDs aplicados (los marcadores @@...@@ ya no estan). Si lo guardas asi, sobrescribiras el archivo con esta version y no podras volver a aplicarle otros IDs distintos despues. Si quieres conservar el original para reutilizarlo en otro servidor, pulsa 'Generar SQL' de nuevo antes de guardar. Continuar y guardar tal cual esta ahora?"), "Aviso", 'YesNo', 'Warning')
            if ($confirmacion -ne 'Yes') { return }
        }
        $nombreBase = $txtNombreGuild.Text.Trim()
        if (-not $nombreBase) { $nombreBase = "hermandad" }
        $nombreArchivo = ($nombreBase -replace '[^a-zA-Z0-9_\-]', '_') + ".sql"
        $ruta = Join-Path $Global:WorldDir $nombreArchivo
        Set-Content -Path $ruta -Value $txtSql.Text -Encoding UTF8
        [System.Windows.Forms.MessageBox]::Show(((Obtener-Texto "MsgSqlGuardadoOK" "Guardado como '{0}' en la carpeta del WorldServer.") -f $nombreArchivo), "OK", 'OK', 'Information')
    })
    $subForm.Controls.Add($btnGuardarArchivo)

    $btnInyectar = New-Object System.Windows.Forms.Button
    $btnInyectar.Text = Obtener-Texto "BtnInyectarSql" "Inyectar en este servidor"
    $btnInyectar.Location = New-Object System.Drawing.Point(395, 540)
    $btnInyectar.Size = New-Object System.Drawing.Size(190, 30)
    $btnInyectar.BackColor = [System.Drawing.Color]::SeaGreen
    $btnInyectar.FlatStyle = 'Flat'
    $btnInyectar.Font = $fBold
    $btnInyectar.Add_Click({
        if (-not $txtSql.Text) { return }
        if ($txtSql.Text -match '@@\w+@@') {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgFaltaAplicarIds" "El texto todavia tiene marcadores @@...@@ sin sustituir. Pulsa 'Aplicar IDs al texto' primero."), "Error", 'OK', 'Error')
            return
        }
        $confirmacion = [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgConfirmarInyectar" "Esto va a ejecutar el SQL directamente sobre la base de datos de este servidor. Se recomienda tener el WorldServer PARADO mientras se hace esto, para evitar choques de GUID con objetos que el servidor cree en memoria mientras esta encendido. Continuar?"), "Confirmar", 'YesNo', 'Warning')
        if ($confirmacion -ne 'Yes') { return }

        $res = Inyectar-SQL $txtSql.Text
        if ($res.Exito) {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgInyectadoOK" "Hermandad inyectada correctamente. Reinicia el WorldServer para que el juego la cargue."), "OK", 'OK', 'Information')
        } else {
            $msg = (Obtener-Texto "MsgGuildError" "Error al procesar la hermandad.")
            if ($res.Mensaje) { $msg += "`n`n$($res.Mensaje)" }
            [System.Windows.Forms.MessageBox]::Show($msg, "Error", 'OK', 'Error')
        }
    })
    $subForm.Controls.Add($btnInyectar)

    $btnVerificarSql = New-Object System.Windows.Forms.Button
    $btnVerificarSql.Text = Obtener-Texto "BtnVerificarSql" "Verificar hermandad"
    $btnVerificarSql.Location = New-Object System.Drawing.Point(595, 540)
    $btnVerificarSql.Size = New-Object System.Drawing.Size(165, 30)
    $btnVerificarSql.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $btnVerificarSql.FlatStyle = 'Flat'
    $btnVerificarSql.Font = $fBold
    $btnVerificarSql.Add_Click({
        $nombre = $txtNombreGuild.Text.Trim()
        if (-not $nombre) { return }
        $texto = Verificar-Hermandad $nombre
        [System.Windows.Forms.MessageBox]::Show($texto, "Comprobacion", 'OK', 'Information')
    })
    $subForm.Controls.Add($btnVerificarSql)

    $btnAyudaHermandad = New-Object System.Windows.Forms.Button
    $btnAyudaHermandad.Text = Obtener-Texto "BtnAyudaHermandad" "Como se exporta? (Ayuda)"
    $btnAyudaHermandad.Location = New-Object System.Drawing.Point(15, 585)
    $btnAyudaHermandad.Size = New-Object System.Drawing.Size(360, 30)
    $btnAyudaHermandad.BackColor = [System.Drawing.Color]::FromArgb(90, 60, 150)
    $btnAyudaHermandad.FlatStyle = 'Flat'
    $btnAyudaHermandad.Font = $fBold
    $btnAyudaHermandad.Add_Click({
        $texto = Obtener-Texto "MsgAyudaHermandadTexto" @"
COMO MIGRAR UNA HERMANDAD A OTRO SERVIDOR
============================================

PASOS A SEGUIR:


===== EN EL SERVIDOR ANTIGUO =====

1. Guardar Personaje
   Guarda tu personaje (el que es GM de la hermandad) desde
   Personajes > Guardar Personaje.

2. Guardar tu Hermandad
   Ve a Hermandad, escribe el nombre y pulsa el boton
   "Guardar Hermandad (genera + guarda .sql)".


>>> Una vez hechos estos 2 pasos, copia LOS ARCHIVOS GENERADOS <<<
>>> a la carpeta donde esta el WorldServer del servidor NUEVO. <<<


===== EN EL SERVIDOR NUEVO =====

3. Cargar Personaje
   Carga tu personaje en el nuevo servidor.

4. Verificar el personaje
   Entra en el juego y comprueba que esta cargado. Puede
   pedirte que le cambies el nombre (si ya existe otro igual
   en este servidor); es normal, hazlo sin miedo.

5. Apaga el WorldServer.

6. Cargar tu Hermandad
   Pulsa el boton "Abrir .sql guardado..." y elige el archivo.

7. Rellena los campos:
     - Nombre del GM  ->  boton "Buscar" (rellena su GUID solo)
     - Nuevo ID Hermandad  ->  boton "Auto"
     - GUID base para objetos del banco  ->  boton "Auto"

8. Pulsa "Aplicar IDs al texto".

9. Pulsa "Inyectar en este servidor" (asi se guarda la hermandad).

10. Enciende el WorldServer y, una vez cargado, entra al juego.


FIN


NOTAS:

- Solo se exporta al GM como miembro. El resto de la gente debera
  volver a unirse a la hermandad dentro del juego.
- Puedes usar "Verificar hermandad" en cualquier momento para
  comprobar que el GM esta bien enlazado, sin tocar nada.
"@
        $formAyuda = New-Object System.Windows.Forms.Form
        $formAyuda.Text = Obtener-Texto "TituloAyudaHermandad" "Ayuda: como exportar una hermandad"
        $formAyuda.Size = New-Object System.Drawing.Size(650, 560)
        $formAyuda.StartPosition = 'CenterParent'
        $formAyuda.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
        $formAyuda.FormBorderStyle = 'FixedDialog'
        $formAyuda.MaximizeBox = $false
        $formAyuda.MinimizeBox = $false

        $txtAyuda = New-Object System.Windows.Forms.TextBox
        $txtAyuda.Location = New-Object System.Drawing.Point(15, 15)
        $txtAyuda.Size = New-Object System.Drawing.Size(605, 480)
        $txtAyuda.Multiline = $true
        $txtAyuda.ReadOnly = $true
        $txtAyuda.ScrollBars = 'Vertical'
        $txtAyuda.Font = New-Object System.Drawing.Font("Consolas", 9)
        $txtAyuda.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $txtAyuda.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
        $texto = $texto -replace "`r`n", "`n"
        $texto = $texto -replace "`n", "`r`n"
        $txtAyuda.Text = $texto
        $formAyuda.Controls.Add($txtAyuda)

        $btnCerrarAyuda = New-Object System.Windows.Forms.Button
        $btnCerrarAyuda.Text = Obtener-Texto "BtnCerrar" "Cerrar"
        $btnCerrarAyuda.Location = New-Object System.Drawing.Point(15, 500)
        $btnCerrarAyuda.Size = New-Object System.Drawing.Size(605, 30)
        $btnCerrarAyuda.BackColor = [System.Drawing.Color]::DimGray
        $btnCerrarAyuda.FlatStyle = 'Flat'
        $btnCerrarAyuda.ForeColor = [System.Drawing.Color]::White
        $btnCerrarAyuda.Add_Click({ $formAyuda.Close() })
        $formAyuda.Controls.Add($btnCerrarAyuda)

        $formAyuda.ShowDialog() | Out-Null
    })
    $subForm.Controls.Add($btnAyudaHermandad)

    $btnCerrarHermandad = New-Object System.Windows.Forms.Button
    $btnCerrarHermandad.Text = Obtener-Texto "BtnCerrar" "Cerrar"
    $btnCerrarHermandad.Location = New-Object System.Drawing.Point(385, 585)
    $btnCerrarHermandad.Size = New-Object System.Drawing.Size(375, 30)
    $btnCerrarHermandad.BackColor = [System.Drawing.Color]::DimGray
    $btnCerrarHermandad.FlatStyle = 'Flat'
    $btnCerrarHermandad.Font = $fLabel
    $btnCerrarHermandad.Add_Click({ $subForm.Close() })
    $subForm.Controls.Add($btnCerrarHermandad)

    $subForm.ShowDialog() | Out-Null
}

Function Abrir-ListaDumps($parentForm, $txtDestino) {
    $listForm = New-Object System.Windows.Forms.Form
    $listForm.Text = Obtener-Texto "TituloListaDumps" "Archivos .dump guardados"
    $listForm.Size = New-Object System.Drawing.Size(340, 420)
    $listForm.StartPosition = 'CenterParent'
    $listForm.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
    $listForm.ForeColor = [System.Drawing.Color]::White
    $listForm.FormBorderStyle = 'FixedDialog'
    $listForm.MaximizeBox = $false
    $listForm.MinimizeBox = $false

    $fListado = New-Object System.Drawing.Font("Georgia", 9)

    $lblInfo = New-Object System.Windows.Forms.Label
    $lblInfo.Text = Obtener-Texto "MsgCarpetaDumps" "Buscando en la carpeta del WorldServer:"
    $lblInfo.Location = New-Object System.Drawing.Point(15, 12)
    $lblInfo.Size = New-Object System.Drawing.Size(295, 18)
    $lblInfo.Font = $fListado
    $lblInfo.ForeColor = [System.Drawing.Color]::LightGray
    $listForm.Controls.Add($lblInfo)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(15, 35)
    $listBox.Size = New-Object System.Drawing.Size(295, 300)
    $listBox.Font = $fListado
    $listBox.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $listBox.ForeColor = [System.Drawing.Color]::White
    $listForm.Controls.Add($listBox)

    # NOTA: el servidor guarda los dumps SIN extensión (ej. "chami", no "chami.dump").
    # La única forma fiable de identificarlos es mirar la primera línea del archivo,
    # que siempre empieza con el aviso "IMPORTANT NOTE: THIS DUMPFILE..." generado por 'pdump write'.
    $hayArchivos = $false
    if (Test-Path $Global:WorldDir) {
        $candidatos = Get-ChildItem -Path $Global:WorldDir -File -ErrorAction SilentlyContinue
        $archivos = @()
        foreach ($candidato in $candidatos) {
            try {
                $primeraLinea = Get-Content -Path $candidato.FullName -TotalCount 1 -ErrorAction SilentlyContinue
                if ($primeraLinea -match "THIS DUMPFILE") {
                    $archivos += $candidato
                }
            } catch {}
        }
        $archivos = $archivos | Sort-Object LastWriteTime -Descending

        foreach ($archivo in $archivos) {
            $etiqueta = "$($archivo.Name)   [$($archivo.LastWriteTime.ToString('dd/MM/yyyy HH:mm'))]"
            $listBox.Items.Add($etiqueta) | Out-Null
        }
        if ($archivos.Count -gt 0) { $hayArchivos = $true }
    }

    if (-not $hayArchivos) {
        $listBox.Items.Add((Obtener-Texto "MsgNoDumps" "No se encontraron archivos de dump en esa carpeta.")) | Out-Null
        $listBox.Enabled = $false
    }

    $btnUsar = New-Object System.Windows.Forms.Button
    $btnUsar.Text = Obtener-Texto "BtnUsarArchivo" "Usar seleccionado"
    $btnUsar.Location = New-Object System.Drawing.Point(15, 345)
    $btnUsar.Size = New-Object System.Drawing.Size(295, 30)
    $btnUsar.BackColor = [System.Drawing.Color]::SteelBlue
    $btnUsar.FlatStyle = 'Flat'
    $btnUsar.Font = New-Object System.Drawing.Font("Georgia", 9, [System.Drawing.FontStyle]::Bold)

    $usarSeleccion = {
        if ($hayArchivos -and $listBox.SelectedItem) {
            $nombreArchivo = $listBox.SelectedItem.ToString().Split("   [")[0].Trim()
            $txtDestino.Text = $nombreArchivo
            $listForm.Close()
        }
    }
    $btnUsar.Add_Click($usarSeleccion)
    $listBox.Add_DoubleClick($usarSeleccion)
    $listForm.Controls.Add($btnUsar)

    $listForm.ShowDialog() | Out-Null
}

Function Abrir-PanelPersonajes($parentForm) {
    $subForm = New-Object System.Windows.Forms.Form
    $subForm.Text = Obtener-Texto "BtnPersonajes" "Gestión de Personajes"
    $subForm.Size = New-Object System.Drawing.Size(860, 460)
    $subForm.StartPosition = 'CenterParent'
    $subForm.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
    $subForm.ForeColor = [System.Drawing.Color]::White
    $subForm.FormBorderStyle = 'FixedDialog'
    $subForm.MaximizeBox = $false
    $subForm.MinimizeBox = $false

    $fLabel = New-Object System.Drawing.Font("Georgia", 9)
    $fGroup = New-Object System.Drawing.Font("Georgia", 10, [System.Drawing.FontStyle]::Bold)
    $fAviso = New-Object System.Drawing.Font("Georgia", 8.5, [System.Drawing.FontStyle]::Italic)

    # ------------------------------------------
    # SUBSECCIÓN 1: SALVAR PERSONAJE
    # ------------------------------------------
    $boxSalvar = New-Object System.Windows.Forms.GroupBox
    $boxSalvar.Text = Obtener-Texto "GrpSalvar" "Salvar Personaje"
    $boxSalvar.Location = New-Object System.Drawing.Point(15, 15)
    $boxSalvar.Size = New-Object System.Drawing.Size(395, 130)
    $boxSalvar.ForeColor = [System.Drawing.Color]::White
    $boxSalvar.Font = $fGroup
    $subForm.Controls.Add($boxSalvar)

    # 1º OPCIÓN VISUAL: Nombre del archivo
    $lblFile1 = New-Object System.Windows.Forms.Label
    $lblFile1.Text = Obtener-Texto "LblTxtFile" "Nombre del archivo:"
    $lblFile1.Location = New-Object System.Drawing.Point(15, 32)
    $lblFile1.Size = New-Object System.Drawing.Size(160, 20)
    $lblFile1.Font = $fLabel
    $boxSalvar.Controls.Add($lblFile1)

    $txtFile1 = New-Object System.Windows.Forms.TextBox
    $txtFile1.Location = New-Object System.Drawing.Point(180, 29)
    $txtFile1.Size = New-Object System.Drawing.Size(200, 20)
    $txtFile1.Font = $fLabel
    $txtFile1.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtFile1.ForeColor = [System.Drawing.Color]::White
    $boxSalvar.Controls.Add($txtFile1)

    # 2º OPCIÓN VISUAL: Nombre del personaje
    $lblPj1 = New-Object System.Windows.Forms.Label
    $lblPj1.Text = Obtener-Texto "LblTxtPjSalvar" "Nombre del personaje a salvar:"
    $lblPj1.Location = New-Object System.Drawing.Point(15, 67)
    $lblPj1.Size = New-Object System.Drawing.Size(160, 20)
    $lblPj1.Font = $fLabel
    $boxSalvar.Controls.Add($lblPj1)

    $txtPj1 = New-Object System.Windows.Forms.TextBox
    $txtPj1.Location = New-Object System.Drawing.Point(180, 64)
    $txtPj1.Size = New-Object System.Drawing.Size(200, 20)
    $txtPj1.Font = $fLabel
    $txtPj1.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtPj1.ForeColor = [System.Drawing.Color]::White
    $boxSalvar.Controls.Add($txtPj1)

    $btnAccionSalvar = New-Object System.Windows.Forms.Button
    $btnAccionSalvar.Text = Obtener-Texto "BtnSalvar" "Salvar"
    $btnAccionSalvar.Location = New-Object System.Drawing.Point(280, 93)
    $btnAccionSalvar.Size = New-Object System.Drawing.Size(100, 28)
    $btnAccionSalvar.BackColor = [System.Drawing.Color]::SeaGreen
    $btnAccionSalvar.FlatStyle = 'Flat'
    $btnAccionSalvar.Font = $fGroup
    $btnAccionSalvar.Add_Click({
        $fileName = $txtFile1.Text.Trim()
        $pjName = $txtPj1.Text.Trim()

        if ($pjName -and $fileName) {
            # Verificación del archivo existente en la carpeta del WorldServer
            $pathDestino = Join-Path $Global:WorldDir $fileName
            if (Test-Path $pathDestino) {
                [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgFileExists" "¡Error! Ya existe un archivo con ese nombre en el servidor."), "Error", 'OK', 'Warning')
                return
            }

            $comando = "pdump write $fileName $pjName"
            if (Enviar-ComandoWorldServerPj $comando $subForm $parentForm) {
                [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgDumpOK" "¡Comando de guardado enviado con éxito!"), "OK", 'OK', 'Information')
                $subForm.Close()
            }
        }
    })
    $boxSalvar.Controls.Add($btnAccionSalvar)

    # ------------------------------------------
    # SUBSECCIÓN 2: CARGAR PERSONAJE
    # ------------------------------------------
    $boxCargar = New-Object System.Windows.Forms.GroupBox
    $boxCargar.Text = Obtener-Texto "GrpCargar" "Cargar Personaje Guardado"
    $boxCargar.Location = New-Object System.Drawing.Point(15, 160)
    $boxCargar.Size = New-Object System.Drawing.Size(395, 205)
    $boxCargar.ForeColor = [System.Drawing.Color]::White
    $boxCargar.Font = $fGroup
    $subForm.Controls.Add($boxCargar)

    $lblAviso = New-Object System.Windows.Forms.Label
    $lblAviso.Text = Obtener-Texto "MsgCargarAviso" "Aviso: El archivo debe estar dentro del nuevo servidor."
    $lblAviso.Location = New-Object System.Drawing.Point(15, 25)
    $lblAviso.Size = New-Object System.Drawing.Size(365, 38)
    $lblAviso.ForeColor = [System.Drawing.Color]::Goldenrod
    $lblAviso.Font = $fAviso
    $lblAviso.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $boxCargar.Controls.Add($lblAviso)

    $lblFile2 = New-Object System.Windows.Forms.Label
    $lblFile2.Text = Obtener-Texto "LblTxtFile" "Nombre del archivo:"
    $lblFile2.Location = New-Object System.Drawing.Point(15, 77)
    $lblFile2.Size = New-Object System.Drawing.Size(160, 20)
    $lblFile2.Font = $fLabel
    $boxCargar.Controls.Add($lblFile2)

    $txtFile2 = New-Object System.Windows.Forms.TextBox
    $txtFile2.Location = New-Object System.Drawing.Point(180, 74)
    $txtFile2.Size = New-Object System.Drawing.Size(155, 20)
    $txtFile2.Font = $fLabel
    $txtFile2.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtFile2.ForeColor = [System.Drawing.Color]::White
    $boxCargar.Controls.Add($txtFile2)

    $btnVerDumps = New-Object System.Windows.Forms.Button
    $btnVerDumps.Text = "..."
    $btnVerDumps.Location = New-Object System.Drawing.Point(340, 73)
    $btnVerDumps.Size = New-Object System.Drawing.Size(35, 22)
    $btnVerDumps.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $btnVerDumps.FlatStyle = 'Flat'
    $btnVerDumps.Font = $fLabel
    $btnVerDumps.Add_Click({ Abrir-ListaDumps $subForm $txtFile2 })
    $boxCargar.Controls.Add($btnVerDumps)

    $lblAcc2 = New-Object System.Windows.Forms.Label
    $lblAcc2.Text = Obtener-Texto "LblTxtAccCargar" "Nombre de la cuenta:"
    $lblAcc2.Location = New-Object System.Drawing.Point(15, 112)
    $lblAcc2.Size = New-Object System.Drawing.Size(160, 20)
    $lblAcc2.Font = $fLabel
    $boxCargar.Controls.Add($lblAcc2)

    $txtAcc2 = New-Object System.Windows.Forms.TextBox
    $txtAcc2.Location = New-Object System.Drawing.Point(180, 109)
    $txtAcc2.Size = New-Object System.Drawing.Size(200, 20)
    $txtAcc2.Font = $fLabel
    $txtAcc2.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtAcc2.ForeColor = [System.Drawing.Color]::White
    $boxCargar.Controls.Add($txtAcc2)

    $btnAccionCargar = New-Object System.Windows.Forms.Button
    $btnAccionCargar.Text = Obtener-Texto "BtnCargar" "Cargar"
    $btnAccionCargar.Location = New-Object System.Drawing.Point(280, 162)
    $btnAccionCargar.Size = New-Object System.Drawing.Size(100, 28)
    $btnAccionCargar.BackColor = [System.Drawing.Color]::SteelBlue
    $btnAccionCargar.FlatStyle = 'Flat'
    $btnAccionCargar.Font = $fGroup
    $btnAccionCargar.Add_Click({
        $fileName = $txtFile2.Text.Trim()
        $accName = $txtAcc2.Text.Trim()

        if ($fileName -and $accName) {
            $comando = "pdump load $fileName $accName"
            if (Enviar-ComandoWorldServerPj $comando $subForm $parentForm) {
                [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgLoadOK" "¡Comando de carga enviado con éxito!"), "OK", 'OK', 'Information')
                $subForm.Close()
            }
        }
    })
    $boxCargar.Controls.Add($btnAccionCargar)

    # ------------------------------------------
    # SUBSECCIÓN 3: HERMANDAD (GUILD)
    # ------------------------------------------
    $boxGuild = New-Object System.Windows.Forms.GroupBox
    $boxGuild.Text = Obtener-Texto "GrpHermandad" "Hermandad (Guild)"
    $boxGuild.Location = New-Object System.Drawing.Point(425, 15)
    $boxGuild.Size = New-Object System.Drawing.Size(395, 130)
    $boxGuild.ForeColor = [System.Drawing.Color]::White
    $boxGuild.Font = $fGroup
    $subForm.Controls.Add($boxGuild)

    $lblGuildInfo = New-Object System.Windows.Forms.Label
    $lblGuildInfo.Text = Obtener-Texto "MsgGuildInfoBoton" "Exporta o inyecta una hermandad completa (miembros, banco, objetos y dinero) mediante SQL generado, con marcadores de ID que puedes sustituir tu mismo."
    $lblGuildInfo.Location = New-Object System.Drawing.Point(15, 25)
    $lblGuildInfo.Size = New-Object System.Drawing.Size(365, 60)
    $lblGuildInfo.Font = $fAviso
    $lblGuildInfo.ForeColor = [System.Drawing.Color]::LightGray
    $boxGuild.Controls.Add($lblGuildInfo)

    $btnAbrirHermandadSQL = New-Object System.Windows.Forms.Button
    $btnAbrirHermandadSQL.Text = Obtener-Texto "BtnAbrirHermandadSQL" "Abrir Hermandad (SQL)"
    $btnAbrirHermandadSQL.Location = New-Object System.Drawing.Point(15, 90)
    $btnAbrirHermandadSQL.Size = New-Object System.Drawing.Size(365, 30)
    $btnAbrirHermandadSQL.BackColor = [System.Drawing.Color]::SteelBlue
    $btnAbrirHermandadSQL.FlatStyle = 'Flat'
    $btnAbrirHermandadSQL.Font = $fGroup
    $btnAbrirHermandadSQL.Add_Click({ Abrir-PanelHermandadSQL $subForm })
    $boxGuild.Controls.Add($btnAbrirHermandadSQL)

    $subForm.ShowDialog() | Out-Null
}