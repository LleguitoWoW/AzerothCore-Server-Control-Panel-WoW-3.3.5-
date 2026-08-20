# ==========================================
# MÓDULO SATELLITE: CONFIGURACIÓN DE RATES (worldserver.conf)
# ==========================================

# Localiza el archivo worldserver.conf. Si ya fue localizado antes, reutiliza la ruta
# guardada en config_server.txt. Si no, intenta autodetectarlo dentro de la carpeta
# del WorldServer, y como último recurso pide al usuario que lo seleccione a mano.
Function Obtener-RutaWorldConf {
    # Solo aceptamos ARCHIVOS (no carpetas). Si en config_server.txt quedo una
    # carpeta (ej. ...\configs), Test-Path sin -PathType Leaf la daba por valida
    # y luego Set-Content fallaba con "Acceso denegado".
    if ($Global:WorldConfPath -and (Test-Path -LiteralPath $Global:WorldConfPath -PathType Leaf)) {
        return $Global:WorldConfPath
    }
    if ($Global:WorldConfPath -and (Test-Path -LiteralPath $Global:WorldConfPath -PathType Container)) {
        $Global:WorldConfPath = ""
    }

    if (-not $Global:WorldDir) { return $null }

    $candidatos = @(
        (Join-Path $Global:WorldDir "configs\worldserver.conf"),
        (Join-Path $Global:WorldDir "etc\worldserver.conf"),
        (Join-Path $Global:WorldDir "worldserver.conf"),
        (Join-Path $Global:WorldDir "configs\worldserver.conf.dist")
    )
    foreach ($candidato in $candidatos) {
        if (Test-Path -LiteralPath $candidato -PathType Leaf) {
            # Preferir .conf real sobre .dist
            if ($candidato -like "*.dist") { continue }
            $Global:WorldConfPath = $candidato
            try { Guardar-Configuracion } catch {}
            return $candidato
        }
    }
    # Si solo existe .dist, avisar pero no usarlo como destino de escritura
    foreach ($candidato in $candidatos) {
        if ($candidato -like "*.dist" -and (Test-Path -LiteralPath $candidato -PathType Leaf)) {
            break
        }
    }

    try {
        $encontrado = Get-ChildItem -LiteralPath $Global:WorldDir -Filter "worldserver.conf" -Recurse -ErrorAction SilentlyContinue |
            Where-Object { -not $_.PSIsContainer -and $_.Name -eq "worldserver.conf" } |
            Select-Object -First 1
        if ($encontrado) {
            $Global:WorldConfPath = $encontrado.FullName
            try { Guardar-Configuracion } catch {}
            return $encontrado.FullName
        }
    } catch {}

    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $fileBrowser.Title = Obtener-Texto "TituloBuscarConf" "Selecciona el archivo worldserver.conf"
    $fileBrowser.Filter = "worldserver.conf|worldserver.conf|Todos los archivos (*.*)|*.*"
    if ($Global:WorldDir -and (Test-Path -LiteralPath $Global:WorldDir)) {
        $fileBrowser.InitialDirectory = $Global:WorldDir
    }
    if ($fileBrowser.ShowDialog() -eq 'OK') {
        if (Test-Path -LiteralPath $fileBrowser.FileName -PathType Leaf) {
            $Global:WorldConfPath = $fileBrowser.FileName
            try { Guardar-Configuracion } catch {}
            return $fileBrowser.FileName
        }
    }
    return $null
}

# Localiza Playerbots.conf (mod playerbots): normalmente en configs\modules\
Function Obtener-RutaPlayerbotsConf {
    if (-not $Global:WorldDir) { return $null }
    $candidatos = @(
        (Join-Path $Global:WorldDir "configs\modules\Playerbots.conf"),
        (Join-Path $Global:WorldDir "configs\modules\playerbots.conf"),
        (Join-Path $Global:WorldDir "etc\modules\Playerbots.conf"),
        (Join-Path $Global:WorldDir "modules\Playerbots.conf")
    )
    foreach ($candidato in $candidatos) {
        if (Test-Path -LiteralPath $candidato -PathType Leaf) { return $candidato }
    }
    try {
        $encontrado = Get-ChildItem -LiteralPath $Global:WorldDir -Filter "Playerbots.conf" -Recurse -ErrorAction SilentlyContinue |
            Where-Object { -not $_.PSIsContainer } | Select-Object -First 1
        if ($encontrado) { return $encontrado.FullName }
        $encontrado2 = Get-ChildItem -LiteralPath $Global:WorldDir -Filter "playerbots.conf" -Recurse -ErrorAction SilentlyContinue |
            Where-Object { -not $_.PSIsContainer } | Select-Object -First 1
        if ($encontrado2) { return $encontrado2.FullName }
    } catch {}
    return $null
}

Function Abrir-PanelRates($parentForm) {
    $rutaConf = Obtener-RutaWorldConf
    if (-not $rutaConf -or -not (Test-Path -LiteralPath $rutaConf -PathType Leaf)) {
        [System.Windows.Forms.MessageBox]::Show(
            (Obtener-Texto "MsgConfNoEncontrado" "No se pudo localizar el archivo worldserver.conf.") + "`n`nBusca normalmente en:`n  <WorldServer>\configs\worldserver.conf",
            "Error", 'OK', 'Error')
        return
    }

    try {
        $contenidoConf = Get-Content -LiteralPath $rutaConf -Raw -ErrorAction Stop
    } catch {
        [System.Windows.Forms.MessageBox]::Show("No se pudo leer:`n$rutaConf`n`n$($_.Exception.Message)", "Error", 'OK', 'Error')
        return
    }
    if (-not $contenidoConf -or $contenidoConf.Trim().Length -lt 20) {
        [System.Windows.Forms.MessageBox]::Show("El archivo parece vacio o no es un conf valido:`n$rutaConf", "Error", 'OK', 'Warning')
    }

    # Playerbots (opcional): si no existe el conf del mod, la seccion se muestra deshabilitada
    $rutaPlayerbots = Obtener-RutaPlayerbotsConf
    $contenidoPlayerbots = $null
    if ($rutaPlayerbots) {
        try { $contenidoPlayerbots = Get-Content $rutaPlayerbots -Raw -ErrorAction Stop } catch { $contenidoPlayerbots = $null }
    }

    Function Leer-ValorConf($clave) {
        if (-not $contenidoConf) { return 0 }
        $patron = '(?m)^\s*' + [regex]::Escape($clave) + '\s*=\s*([\d\.]+)'
        if ($contenidoConf -match $patron) { return [double]$Matches[1] }
        return 0
    }

    Function Leer-ValorPlayerbots($clave, $defecto) {
        if (-not $contenidoPlayerbots) { return $defecto }
        $patron = "(?m)^$([regex]::Escape($clave))\s*=\s*([\d\.]+)"
        if ($contenidoPlayerbots -match $patron) { return [double]$Matches[1] }
        return $defecto
    }

    $subForm = New-Object System.Windows.Forms.Form
    $subForm.Text = Obtener-Texto "TituloRates" "Configuracion de Rates"
    # Layout ancho (2 columnas): menos alto, mas ancho
    $subForm.Size = New-Object System.Drawing.Size(860, 720)
    $subForm.AutoScroll = $true
    $subForm.StartPosition = 'CenterParent'
    $subForm.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
    $subForm.ForeColor = [System.Drawing.Color]::White
    $subForm.FormBorderStyle = 'FixedDialog'
    $subForm.MaximizeBox = $false
    $subForm.MinimizeBox = $false

    $fGroup = New-Object System.Drawing.Font("Georgia", 10, [System.Drawing.FontStyle]::Bold)
    $fLabel = New-Object System.Drawing.Font("Georgia", 9)
    $fDesc  = New-Object System.Drawing.Font("Georgia", 8, [System.Drawing.FontStyle]::Italic)

    $CamposRates = @{}
    $CamposOpciones = @{}
    $CamposDecimales = @{}

    Function Agregar-CampoRate($grupo, $clave, $texto, $y) {
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $texto
        $lbl.Location = New-Object System.Drawing.Point(15, $y)
        $lbl.Size = New-Object System.Drawing.Size(230, 20)
        $lbl.Font = $fLabel
        $lbl.ForeColor = [System.Drawing.Color]::LightGray
        $grupo.Controls.Add($lbl)

        $txt = New-Object System.Windows.Forms.TextBox
        $txt.Location = New-Object System.Drawing.Point(255, ($y - 3))
        $txt.Size = New-Object System.Drawing.Size(95, 24)
        $txt.TextAlign = 'Center'
        $txt.Text = [string][int](Leer-ValorConf $clave)
        $grupo.Controls.Add($txt)

        $CamposRates[$clave] = $txt
    }

    Function Agregar-CampoTexto($grupo, $clave, $texto, $descripcion, $y) {
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $texto
        $lbl.Location = New-Object System.Drawing.Point(15, $y)
        $lbl.Size = New-Object System.Drawing.Size(230, 20)
        $lbl.Font = $fLabel
        $lbl.ForeColor = [System.Drawing.Color]::LightGray
        $grupo.Controls.Add($lbl)

        $txt = New-Object System.Windows.Forms.TextBox
        $txt.Location = New-Object System.Drawing.Point(255, ($y - 3))
        $txt.Size = New-Object System.Drawing.Size(95, 24)
        $txt.TextAlign = 'Center'
        $txt.Text = [string][int](Leer-ValorConf $clave)
        $grupo.Controls.Add($txt)

        $lblDesc = New-Object System.Windows.Forms.Label
        $lblDesc.Text = $descripcion
        $lblDesc.Location = New-Object System.Drawing.Point(15, ($y + 23))
        $lblDesc.Size = New-Object System.Drawing.Size(360, 34)
        $lblDesc.Font = $fDesc
        $lblDesc.ForeColor = [System.Drawing.Color]::DarkGray
        $grupo.Controls.Add($lblDesc)

        $CamposOpciones[$clave] = $txt
    }

    # Celda compacta para la tabla de Criaturas: admite valores decimales (ej: 0.75)
    Function Agregar-CeldaDecimal($grupo, $clave, $x, $y) {
        $txt = New-Object System.Windows.Forms.TextBox
        $txt.Location = New-Object System.Drawing.Point($x, $y)
        $txt.Size = New-Object System.Drawing.Size(48, 22)
        $txt.TextAlign = 'Center'
        $txt.Font = $fLabel
        $valorActual = Leer-ValorConf $clave
        if ($valorActual -eq [Math]::Floor($valorActual)) {
            $txt.Text = [string][int]$valorActual
        } else {
            $txt.Text = $valorActual.ToString([System.Globalization.CultureInfo]::InvariantCulture)
        }
        $grupo.Controls.Add($txt)
        $CamposDecimales[$clave] = $txt
    }

    # Layout 2 columnas:
    #   Izquierda (x=15): Skill, XP, Guild, Vuelos
    #   Derecha   (x=430): Reputacion, Criaturas, Playerbots
    # ------------------------------------------
    # GRUPO: SKILL  (columna izquierda)
    # ------------------------------------------
    $boxSkill = New-Object System.Windows.Forms.GroupBox
    $boxSkill.Text = Obtener-Texto "GrpSkill" "Habilidades (Skill)"
    $boxSkill.Location = New-Object System.Drawing.Point(15, 12)
    $boxSkill.Size = New-Object System.Drawing.Size(400, 200)
    $boxSkill.ForeColor = [System.Drawing.Color]::White
    $boxSkill.Font = $fGroup
    $subForm.Controls.Add($boxSkill)

    Agregar-CampoRate $boxSkill "MaxPrimaryTradeSkill" (Obtener-Texto "LblMaxPrimaryTradeSkill" "Max. profesiones primarias:") 28
    Agregar-CampoRate $boxSkill "SkillGain.Crafting"    (Obtener-Texto "LblSkillCrafting" "Ganancia de Crafteo:") 58
    Agregar-CampoRate $boxSkill "SkillGain.Defense"     (Obtener-Texto "LblSkillDefense" "Ganancia de Defensa:") 88
    Agregar-CampoRate $boxSkill "SkillGain.Gathering"   (Obtener-Texto "LblSkillGathering" "Ganancia de Recoleccion:") 118
    Agregar-CampoRate $boxSkill "SkillGain.Weapon"      (Obtener-Texto "LblSkillWeapon" "Ganancia de Armas:") 148

    # ------------------------------------------
    # GRUPO: REPUTACION  (columna derecha, arriba)
    # ------------------------------------------
    $boxRep = New-Object System.Windows.Forms.GroupBox
    $boxRep.Text = Obtener-Texto "GrpReputacion" "Reputacion"
    $boxRep.Location = New-Object System.Drawing.Point(430, 12)
    $boxRep.Size = New-Object System.Drawing.Size(400, 70)
    $boxRep.ForeColor = [System.Drawing.Color]::White
    $boxRep.Font = $fGroup
    $subForm.Controls.Add($boxRep)

    Agregar-CampoRate $boxRep "Rate.Reputation.Gain" (Obtener-Texto "LblRepGain" "Ganancia de Reputacion:") 30

    # ------------------------------------------
    # GRUPO: EXPERIENCIA  (columna izquierda)
    # ------------------------------------------
    $boxExp = New-Object System.Windows.Forms.GroupBox
    $boxExp.Text = Obtener-Texto "GrpExperiencia" "Experiencia (XP)"
    $boxExp.Location = New-Object System.Drawing.Point(15, 222)
    $boxExp.Size = New-Object System.Drawing.Size(400, 160)
    $boxExp.ForeColor = [System.Drawing.Color]::White
    $boxExp.Font = $fGroup
    $subForm.Controls.Add($boxExp)

    Agregar-CampoRate $boxExp "Rate.XP.Kill"     (Obtener-Texto "LblXPKill" "XP por Matar:") 28
    Agregar-CampoRate $boxExp "Rate.XP.Quest"    (Obtener-Texto "LblXPQuest" "XP por Mision:") 58
    Agregar-CampoRate $boxExp "Rate.XP.Quest.DF" (Obtener-Texto "LblXPQuestDF" "XP por Mision (LFG):") 88
    Agregar-CampoRate $boxExp "Rate.XP.Explore"  (Obtener-Texto "LblXPExplore" "XP por Explorar:") 118

    # ------------------------------------------
    # GRUPO: GUILD  (columna izquierda)
    # ------------------------------------------
    $boxGuild = New-Object System.Windows.Forms.GroupBox
    $boxGuild.Text = Obtener-Texto "GrpGuild" "Hermandad (Guild)"
    $boxGuild.Location = New-Object System.Drawing.Point(15, 392)
    $boxGuild.Size = New-Object System.Drawing.Size(400, 70)
    $boxGuild.ForeColor = [System.Drawing.Color]::White
    $boxGuild.Font = $fGroup
    $subForm.Controls.Add($boxGuild)

    Agregar-CampoRate $boxGuild "MinPetitionSigns" (Obtener-Texto "LblMinPetitionSigns" "Firmas min. para peticion:") 30

    # ------------------------------------------
    # GRUPO: RUTAS DE VUELO  (columna izquierda)
    # ------------------------------------------
    $boxVuelos = New-Object System.Windows.Forms.GroupBox
    $boxVuelos.Text = Obtener-Texto "GrpVuelos" "Rutas de Vuelo"
    $boxVuelos.Location = New-Object System.Drawing.Point(15, 472)
    $boxVuelos.Size = New-Object System.Drawing.Size(400, 155)
    $boxVuelos.ForeColor = [System.Drawing.Color]::White
    $boxVuelos.Font = $fGroup
    $subForm.Controls.Add($boxVuelos)

    Agregar-CampoTexto $boxVuelos "AllFlightPaths" `
        (Obtener-Texto "LblAllFlightPaths" "Todas las Rutas de Vuelo:") `
        (Obtener-Texto "DescAllFlightPaths" "0 = Desactivado. 1 = Activado (todas las rutas de vuelo disponibles desde el principio).") `
        30

    Agregar-CampoTexto $boxVuelos "InstantFlightPaths" `
        (Obtener-Texto "LblInstantFlightPaths" "Vuelos Instantaneos:") `
        (Obtener-Texto "DescInstantFlightPaths" "0 = Desactivado. 1 = Activado (vuelo instantaneo). 2 = El jugador elige en el juego si vuela o se teletransporta al destino.") `
        95

    # ------------------------------------------
    # GRUPO: CRIATURAS  (columna derecha)
    # ------------------------------------------
    $boxCriaturas = New-Object System.Windows.Forms.GroupBox
    $boxCriaturas.Text = Obtener-Texto "GrpCriaturas" "Criaturas"
    $boxCriaturas.Location = New-Object System.Drawing.Point(430, 92)
    $boxCriaturas.Size = New-Object System.Drawing.Size(400, 200)
    $boxCriaturas.ForeColor = [System.Drawing.Color]::White
    $boxCriaturas.Font = $fGroup
    $subForm.Controls.Add($boxCriaturas)

    $fColHead = New-Object System.Drawing.Font("Georgia", 7.5, [System.Drawing.FontStyle]::Bold)
    $sufijosCriaturas    = @("Normal", "Elite.Elite", "Elite.RARE", "Elite.RAREELITE", "Elite.WORLDBOSS")
    $encabezadosCriaturas = @(
        (Obtener-Texto "ColNormal" "Normal"),
        (Obtener-Texto "ColElite" "Elite"),
        (Obtener-Texto "ColRara" "Rara"),
        (Obtener-Texto "ColRareElite" "R.Elite"),
        (Obtener-Texto "ColJefe" "Jefe")
    )
    $colsX = @(100, 155, 210, 265, 320)

    for ($i = 0; $i -lt 5; $i++) {
        $lblCol = New-Object System.Windows.Forms.Label
        $lblCol.Text = $encabezadosCriaturas[$i]
        $lblCol.Location = New-Object System.Drawing.Point(($colsX[$i] - 2), 26)
        $lblCol.Size = New-Object System.Drawing.Size(52, 16)
        $lblCol.TextAlign = 'MiddleCenter'
        $lblCol.Font = $fColHead
        $lblCol.ForeColor = [System.Drawing.Color]::LightGray
        $boxCriaturas.Controls.Add($lblCol)
    }

    $lblDano = New-Object System.Windows.Forms.Label
    $lblDano.Text = Obtener-Texto "LblCreatureDamage" "Dano:"
    $lblDano.Location = New-Object System.Drawing.Point(15, 47)
    $lblDano.Size = New-Object System.Drawing.Size(80, 20)
    $lblDano.Font = $fLabel
    $lblDano.ForeColor = [System.Drawing.Color]::LightGray
    $boxCriaturas.Controls.Add($lblDano)

    $lblDanoMagico = New-Object System.Windows.Forms.Label
    $lblDanoMagico.Text = Obtener-Texto "LblCreatureSpellDamage" "Dano Magico:"
    $lblDanoMagico.Location = New-Object System.Drawing.Point(15, 74)
    $lblDanoMagico.Size = New-Object System.Drawing.Size(80, 20)
    $lblDanoMagico.Font = $fLabel
    $lblDanoMagico.ForeColor = [System.Drawing.Color]::LightGray
    $boxCriaturas.Controls.Add($lblDanoMagico)

    $lblVida = New-Object System.Windows.Forms.Label
    $lblVida.Text = Obtener-Texto "LblCreatureHP" "Vida:"
    $lblVida.Location = New-Object System.Drawing.Point(15, 101)
    $lblVida.Size = New-Object System.Drawing.Size(80, 20)
    $lblVida.Font = $fLabel
    $lblVida.ForeColor = [System.Drawing.Color]::LightGray
    $boxCriaturas.Controls.Add($lblVida)

    for ($i = 0; $i -lt 5; $i++) {
        Agregar-CeldaDecimal $boxCriaturas ("Rate.Creature." + $sufijosCriaturas[$i] + ".Damage")      $colsX[$i] 45
        Agregar-CeldaDecimal $boxCriaturas ("Rate.Creature." + $sufijosCriaturas[$i] + ".SpellDamage") $colsX[$i] 72
        Agregar-CeldaDecimal $boxCriaturas ("Rate.Creature." + $sufijosCriaturas[$i] + ".HP")          $colsX[$i] 99
    }

    $lblDescCriaturas = New-Object System.Windows.Forms.Label
    $lblDescCriaturas.Text = Obtener-Texto "DescCriaturas" "1 = valor por defecto (normal). Cuanto mayor el numero, mayor la dificultad (ej: 5). Admite decimales (ej: 0.75)."
    $lblDescCriaturas.Location = New-Object System.Drawing.Point(15, 130)
    $lblDescCriaturas.Size = New-Object System.Drawing.Size(360, 34)
    $lblDescCriaturas.Font = $fDesc
    $lblDescCriaturas.ForeColor = [System.Drawing.Color]::DarkGray
    $boxCriaturas.Controls.Add($lblDescCriaturas)

    # ------------------------------------------
    # GRUPO: PLAYERBOTS (poblacion / niveles)
    # Lee y escribe en configs\modules\Playerbots.conf
    # ------------------------------------------
    $CamposPlayerbots = @{}

    $boxBots = New-Object System.Windows.Forms.GroupBox
    $boxBots.Text = Obtener-Texto "GrpPlayerbots" "Playerbots (poblacion)"
    $boxBots.Location = New-Object System.Drawing.Point(430, 302)
    $boxBots.Size = New-Object System.Drawing.Size(400, 230)
    $boxBots.ForeColor = [System.Drawing.Color]::White
    $boxBots.Font = $fGroup
    $subForm.Controls.Add($boxBots)

    $lblBotsInfo = New-Object System.Windows.Forms.Label
    if ($rutaPlayerbots) {
        $lblBotsInfo.Text = (Obtener-Texto "DescPlayerbotsArchivo" "Archivo:") + " " + [System.IO.Path]::GetFileName($rutaPlayerbots)
        $lblBotsInfo.ForeColor = [System.Drawing.Color]::FromArgb(120, 200, 140)
    } else {
        $lblBotsInfo.Text = Obtener-Texto "MsgPlayerbotsNoEncontrado" "No se encontro Playerbots.conf (mod no instalado o ruta distinta)."
        $lblBotsInfo.ForeColor = [System.Drawing.Color]::Goldenrod
    }
    $lblBotsInfo.Location = New-Object System.Drawing.Point(15, 24)
    $lblBotsInfo.Size = New-Object System.Drawing.Size(360, 18)
    $lblBotsInfo.Font = $fDesc
    $boxBots.Controls.Add($lblBotsInfo)

    Function Agregar-CampoPlayerbots($clave, $texto, $defecto, $y) {
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $texto
        $lbl.Location = New-Object System.Drawing.Point(15, $y)
        $lbl.Size = New-Object System.Drawing.Size(230, 20)
        $lbl.Font = $fLabel
        $lbl.ForeColor = [System.Drawing.Color]::LightGray
        $boxBots.Controls.Add($lbl)

        $txt = New-Object System.Windows.Forms.TextBox
        $txt.Location = New-Object System.Drawing.Point(255, ($y - 3))
        $txt.Size = New-Object System.Drawing.Size(95, 24)
        $txt.TextAlign = 'Center'
        $txt.Text = [string][int](Leer-ValorPlayerbots $clave $defecto)
        $txt.Enabled = [bool]$rutaPlayerbots
        $boxBots.Controls.Add($txt)
        $CamposPlayerbots[$clave] = $txt
    }

    Agregar-CampoPlayerbots "AiPlayerbot.MinRandomBots"           (Obtener-Texto "LblMinRandomBots" "Min. bots en el mundo:") 500 50
    Agregar-CampoPlayerbots "AiPlayerbot.MaxRandomBots"           (Obtener-Texto "LblMaxRandomBots" "Max. bots en el mundo:") 800 80
    Agregar-CampoPlayerbots "AiPlayerbot.RandomBotMinLevel"       (Obtener-Texto "LblRandomBotMinLevel" "Nivel minimo bots:") 16 110
    Agregar-CampoPlayerbots "AiPlayerbot.RandomBotMaxLevel"       (Obtener-Texto "LblRandomBotMaxLevel" "Nivel maximo bots:") 80 140
    Agregar-CampoPlayerbots "AiPlayerbot.DeleteRandomBotAccounts" (Obtener-Texto "LblDeleteRandomBotAccounts" "Borrar cuentas bots (0/1):") 0 170

    $lblBotsDesc = New-Object System.Windows.Forms.Label
    $lblBotsDesc.Text = Obtener-Texto "DescDeleteRandomBotAccounts" "Borrar cuentas: 0 = desactivado, 1 = activado (reinicio de poblacion)."
    $lblBotsDesc.Location = New-Object System.Drawing.Point(15, 198)
    $lblBotsDesc.Size = New-Object System.Drawing.Size(360, 24)
    $lblBotsDesc.Font = $fDesc
    $lblBotsDesc.ForeColor = [System.Drawing.Color]::DarkGray
    $boxBots.Controls.Add($lblBotsDesc)

    # ------------------------------------------
    # BOTONES GUARDAR / CERRAR
    # ------------------------------------------
    $btnGuardar = New-Object System.Windows.Forms.Button
    $btnGuardar.Text = Obtener-Texto "BtnGuardarRates" "Guardar Rates"
    $btnGuardar.Location = New-Object System.Drawing.Point(275, 640)
    $btnGuardar.Size = New-Object System.Drawing.Size(150, 34)
    $btnGuardar.BackColor = [System.Drawing.Color]::SeaGreen
    $btnGuardar.FlatStyle = 'Flat'
    $btnGuardar.Font = $fGroup
    $btnGuardar.Add_Click({
        try {
            if (-not $rutaConf -or -not (Test-Path -LiteralPath $rutaConf -PathType Leaf)) {
                [System.Windows.Forms.MessageBox]::Show(
                    (Obtener-Texto "MsgConfNoEncontrado" "No se pudo localizar el archivo worldserver.conf.") + "`n`nRuta: $rutaConf",
                    "Error", 'OK', 'Error')
                return
            }
            if (-not $contenidoConf) {
                [System.Windows.Forms.MessageBox]::Show(
                    "El archivo de configuracion esta vacio o no se pudo leer:`n$rutaConf",
                    "Error", 'OK', 'Error')
                return
            }

            $nuevoContenido = $contenidoConf
            $todosCampos = @{}
            foreach ($clave in $CamposRates.Keys) { $todosCampos[$clave] = $CamposRates[$clave] }
            foreach ($clave in $CamposOpciones.Keys) { $todosCampos[$clave] = $CamposOpciones[$clave] }

            foreach ($clave in $todosCampos.Keys) {
                $textoEscrito = $todosCampos[$clave].Text.Trim()
                $valorNumerico = 0
                if (-not [int]::TryParse($textoEscrito, [ref]$valorNumerico)) { $valorNumerico = 0 }
                $valorTexto = [string]$valorNumerico
                $patron = '(?m)^(\s*' + [regex]::Escape($clave) + '\s*=\s*)\S+'
                $nuevoContenido = $nuevoContenido -replace $patron, ('${1}' + $valorTexto)
            }

            foreach ($clave in $CamposDecimales.Keys) {
                $textoEscrito = $CamposDecimales[$clave].Text.Trim().Replace(",", ".")
                $valorDecimal = 0.0
                if (-not [double]::TryParse($textoEscrito, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$valorDecimal)) { $valorDecimal = 1.0 }
                if ($valorDecimal -eq [Math]::Floor($valorDecimal)) {
                    $valorTexto = [string][int]$valorDecimal
                } else {
                    $valorTexto = $valorDecimal.ToString([System.Globalization.CultureInfo]::InvariantCulture)
                }
                $patron = '(?m)^(\s*' + [regex]::Escape($clave) + '\s*=\s*)\S+'
                $nuevoContenido = $nuevoContenido -replace $patron, ('${1}' + $valorTexto)
            }

            try {
                [System.IO.File]::WriteAllText($rutaConf, $nuevoContenido)
            } catch {
                $msgAcceso = "No se pudo escribir en:`n$rutaConf`n`n$($_.Exception.Message)`n`nSugerencias:`n- Cierra el WorldServer (puede bloquear el archivo)`n- Ejecuta el panel como administrador`n- Comprueba que la ruta sea un archivo worldserver.conf y no una carpeta"
                [System.Windows.Forms.MessageBox]::Show($msgAcceso, "Error", 'OK', 'Error')
                return
            }
            $contenidoConf = $nuevoContenido

            $msgExtra = ""
            if ($rutaPlayerbots -and (Test-Path -LiteralPath $rutaPlayerbots -PathType Leaf) -and $contenidoPlayerbots -and $CamposPlayerbots.Count -gt 0) {
                $nuevoBots = $contenidoPlayerbots
                foreach ($clave in $CamposPlayerbots.Keys) {
                    $textoEscrito = $CamposPlayerbots[$clave].Text.Trim()
                    $valorNumerico = 0
                    if (-not [int]::TryParse($textoEscrito, [ref]$valorNumerico)) { $valorNumerico = 0 }
                    if ($clave -eq "AiPlayerbot.DeleteRandomBotAccounts") {
                        if ($valorNumerico -ne 0) { $valorNumerico = 1 }
                    }
                    $valorTexto = [string]$valorNumerico
                    $patron = '(?m)^(\s*' + [regex]::Escape($clave) + '\s*=\s*)\S+'
                    if ($nuevoBots -match $patron) {
                        $nuevoBots = $nuevoBots -replace $patron, ('${1}' + $valorTexto)
                    } else {
                        $nuevoBots = $nuevoBots.TrimEnd() + "`r`n$clave = $valorTexto`r`n"
                    }
                }
                try {
                    [System.IO.File]::WriteAllText($rutaPlayerbots, $nuevoBots)
                    $contenidoPlayerbots = $nuevoBots
                    $msgExtra = "`n" + (Obtener-Texto "MsgPlayerbotsGuardado" "Playerbots.conf tambien actualizado.")
                } catch {
                    $msgExtra = "`n(Playerbots no guardado: $($_.Exception.Message))"
                }
            }

            [System.Windows.Forms.MessageBox]::Show(
                ((Obtener-Texto "MsgRatesGuardado" "Rates guardados correctamente en el archivo de configuracion!") + "`n`n$rutaConf" + $msgExtra),
                "OK", 'OK', 'Information')
        } catch {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgRatesError" "Error al guardar los rates.") + "`n`n" + $_.Exception.Message + "`n`nRuta conf: $rutaConf", "Error", 'OK', 'Error')
        }
    }.GetNewClosure())
    $subForm.Controls.Add($btnGuardar)

    $btnCerrar = New-Object System.Windows.Forms.Button
    $btnCerrar.Text = Obtener-Texto "BtnCerrar" "Cerrar"
    $btnCerrar.Location = New-Object System.Drawing.Point(445, 640)
    $btnCerrar.Size = New-Object System.Drawing.Size(150, 34)
    $btnCerrar.BackColor = [System.Drawing.Color]::DimGray
    $btnCerrar.FlatStyle = 'Flat'
    $btnCerrar.Font = $fGroup
    $btnCerrar.Add_Click({ $subForm.Close() }.GetNewClosure())
    $subForm.Controls.Add($btnCerrar)

    $subForm.AutoScrollMinSize = New-Object System.Drawing.Size(830, 690)
    $subForm.ShowDialog() | Out-Null
}
