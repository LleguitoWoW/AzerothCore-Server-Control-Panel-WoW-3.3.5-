# ============================================================
# DressMeSync.ps1 - MODULO NUEVO
# Sincroniza custom_unlocked_appearances -> UnlockedAppearances.lua
# del addon DressMe. No modifica la logica original del panel.
# ============================================================

try { Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue } catch {}
try { Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue } catch {}

# ============================================================
# Configuracion DressMe auto
# ============================================================
# Prefijos de cuentas playerbots que NO deben generar el lua
if (-not $Global:DressMeBotPrefixes) {
    $Global:DressMeBotPrefixes = @("rnb", "rnd", "rndbot", "playerbot", "bot")
}
# Intervalo del timer en minutos (0 = desactivado)
if ($null -eq $Global:DressMeTimerMinutes) {
    $Global:DressMeTimerMinutes = 5
}



Function global:DressMe-EsCuentaBot {
    param([string]$Username)
    if ([string]::IsNullOrWhiteSpace($Username)) { return $false }
    $u = $Username.Trim().ToLowerInvariant()
    $prefs = @()
    if ($Global:DressMeBotPrefixes) { $prefs = @($Global:DressMeBotPrefixes) }
    else { $prefs = @("rnb", "rnd", "rndbot", "playerbot", "bot") }
    foreach ($p in $prefs) {
        if ([string]::IsNullOrWhiteSpace($p)) { continue }
        $pre = $p.ToString().Trim().ToLowerInvariant()
        if ($pre -and $u.StartsWith($pre)) { return $true }
    }
    return $false
}

Function global:DressMe-ObtenerUsuarioCuenta {
    param([int]$AccountId)
    if ($AccountId -le 0) { return $null }
    try {
        $r = @(DressMe-Consulta "SELECT username FROM account WHERE id=$AccountId LIMIT 1;" "acore_auth")
        if ($r.Count -gt 0 -and $r[0]) { return ("$($r[0])").Trim() }
    } catch {}
    return $null
}

Function global:DressMe-ObtenerCuentaDeGuid {
    param([int]$GuidChar)
    if ($GuidChar -le 0) { return $null }
    $bd = if ($Global:CharDbName) { $Global:CharDbName } else { "acore_characters" }
    try {
        $r = @(DressMe-Consulta "SELECT account FROM characters WHERE guid=$GuidChar LIMIT 1;" $bd)
        if ($r.Count -gt 0 -and $r[0]) {
            $acc = 0
            try { $acc = [int](("$($r[0])").Trim()) } catch { $acc = 0 }
            if ($acc -gt 0) {
                $user = DressMe-ObtenerUsuarioCuenta $acc
                return [PSCustomObject]@{ AccountId = $acc; Username = $user }
            }
        }
    } catch {}
    return $null
}

Function global:DressMe-PuedeGenerarParaCuenta {
    param([int]$AccountId, [string]$Username = $null)
    if ($AccountId -le 0) { return $false }
    if (-not $Username) { $Username = DressMe-ObtenerUsuarioCuenta $AccountId }
    if (DressMe-EsCuentaBot $Username) {
        return $false
    }
    return $true
}

Function global:DressMe-ConfigPath {
    if ($Global:AppRoot) {
        return (Join-Path $Global:AppRoot "config_server.txt")
    }
    if ($PSScriptRoot) {
        $parent = Split-Path -Parent $PSScriptRoot
        $c1 = Join-Path $parent "config_server.txt"
        if (Test-Path -LiteralPath $c1) { return $c1 }
        $c2 = Join-Path $PSScriptRoot "config_server.txt"
        if (Test-Path -LiteralPath $c2) { return $c2 }
    }
    return $null
}

Function global:DressMe-LeerRutaAddon {
    # Preferir variable en memoria
    if ($Global:DressMeDbPath -and $Global:DressMeDbPath.Trim() -ne "") {
        return $Global:DressMeDbPath.Trim()
    }
    $cfg = DressMe-ConfigPath
    if ($cfg -and (Test-Path -LiteralPath $cfg)) {
        Get-Content -LiteralPath $cfg -Encoding UTF8 -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_ -match "^DRESSME_DB_PATH=(.*)$") {
                $Global:DressMeDbPath = $Matches[1].Trim()
            }
        }
    }
    if ($Global:DressMeDbPath -and $Global:DressMeDbPath.Trim() -ne "") {
        return $Global:DressMeDbPath.Trim()
    }
    # Autodetectar desde WOW_EXE
    if ($Global:WowExe -and (Test-Path -LiteralPath $Global:WowExe)) {
        $wowDir = Split-Path -Parent $Global:WowExe
        $auto = Join-Path $wowDir "Interface\AddOns\DressMe\db"
        if (Test-Path -LiteralPath $auto) {
            $Global:DressMeDbPath = $auto
            DressMe-GuardarRutaAddon $auto
            return $auto
        }
    }
    return $null
}

Function global:DressMe-GuardarRutaAddon([string]$ruta) {
    $Global:DressMeDbPath = $ruta
    $cfg = DressMe-ConfigPath
    if (-not $cfg) { return }

    $lineas = @()
    $found = $false
    if (Test-Path -LiteralPath $cfg) {
        Get-Content -LiteralPath $cfg -Encoding UTF8 -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_ -match "^DRESSME_DB_PATH=") {
                $lineas += "DRESSME_DB_PATH=$ruta"
                $found = $true
            } else {
                $lineas += $_
            }
        }
    }
    if (-not $found) {
        $lineas += "DRESSME_DB_PATH=$ruta"
    }
    try {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllLines($cfg, $lineas, $utf8)
    } catch {
        try { $lineas | Out-File -FilePath $cfg -Encoding UTF8 } catch {}
    }
}

Function global:DressMe-PedirRutaAddon {
    [System.Windows.Forms.MessageBox]::Show(
        "AVISO: Para que el filtro funcione debes tener instalado el addon DressMe MODIFICADO para servidores privados (incluye UnlockedAppearances.lua y el filtrado de apariencias).`n`nEl DressMe original de retail/privado sin modificar no aplicara la lista generada.`n`nA continuacion elige la carpeta db del addon:`n...\Interface\AddOns\DressMe\db",
        "DressMe - Requisito", "OK", "Information")
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = "Selecciona la carpeta db del addon DressMe modificado`n(ej: ...\Interface\AddOns\DressMe\db)"
    $actual = DressMe-LeerRutaAddon
    if ($actual -and (Test-Path -LiteralPath $actual)) {
        $fbd.SelectedPath = $actual
    }
    if ($fbd.ShowDialog() -eq "OK") {
        $sel = $fbd.SelectedPath
        DressMe-GuardarRutaAddon $sel
        return $sel
    }
    return $null
}

Function global:DressMe-MysqlExe {
    if ($Global:MysqlDir) {
        $p = Join-Path $Global:MysqlDir "mysql.exe"
        if (Test-Path -LiteralPath $p) { return $p }
    }
    $fb = "D:\Juegos\WoW\Azerothcore WoTLK Repack (Playerbots) 2026-09-07\mysql\bin\mysql.exe"
    if (Test-Path -LiteralPath $fb) { return $fb }
    return $null
}

Function global:DressMe-Consulta([string]$sql, [string]$bd) {
    try {
        if (Get-Command Transmog-Consulta -ErrorAction SilentlyContinue) {
            return @(Transmog-Consulta $sql $bd)
        }
    } catch {}
    try {
        if (Get-Command Consulta-Armeria -ErrorAction SilentlyContinue) {
            $r = Consulta-Armeria $sql $bd
            if ($null -eq $r) { return @() }
            return @($r)
        }
    } catch {}

    $mysqlExe = DressMe-MysqlExe
    if (-not $mysqlExe) { return @() }
    try {
        $env:MYSQL_PWD = $Global:MysqlPass
        $filas = & $mysqlExe -h "127.0.0.1" -P 3306 "-u$($Global:MysqlUser)" -N -B -e $sql $bd 2>&1
        $env:MYSQL_PWD = ""
        $out = @()
        foreach ($t in @($filas)) {
            if ($t -and ("$t" -notmatch '^(mysql:|Warning|ERROR)')) { $out += "$t" }
        }
        return $out
    } catch {
        $env:MYSQL_PWD = ""
        return @()
    }
}

Function global:DressMe-GenerarYCopiar {
    param(
        [Parameter(Mandatory=$true)][int]$AccountId,
        [string]$DbFolder = $null
    )

    if ($AccountId -le 0) {
        throw "AccountId invalido"
    }

    if (-not $DbFolder) {
        $DbFolder = DressMe-LeerRutaAddon
    }
    if (-not $DbFolder -or -not (Test-Path -LiteralPath $DbFolder)) {
        $DbFolder = DressMe-PedirRutaAddon
    }
    if (-not $DbFolder) {
        throw "No se configuro la ruta de la carpeta db del addon DressMe."
    }

    # Si el usuario eligio el .lua por error, usar la carpeta
    if ($DbFolder -match '\.lua$') {
        $DbFolder = Split-Path -Parent $DbFolder
    }

    $outFile = Join-Path $DbFolder "UnlockedAppearances.lua"
    $bd = if ($Global:CharDbName) { $Global:CharDbName } else { "acore_characters" }

    $sql = "SELECT item_template_id FROM custom_unlocked_appearances WHERE account_id = $AccountId;"
    $filas = @(DressMe-Consulta $sql $bd)
    $ids = @()
    foreach ($ln in $filas) {
        $t = ("$ln").Trim()
        if ($t -match '^\d+$') { $ids += [int]$t }
    }
    $ids = @($ids | Sort-Object -Unique)

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("local addon, ns = ...")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("-- Generado por DressMeSync (Panel Transmog)")
    [void]$sb.AppendLine("-- Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    [void]$sb.AppendLine("-- AccountId: $AccountId")
    [void]$sb.AppendLine("-- Total items: $($ids.Count)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("ns.UnlockedAppearances = ns.UnlockedAppearances or {}")
    [void]$sb.AppendLine("wipe(ns.UnlockedAppearances)")
    [void]$sb.AppendLine("")
    foreach ($id in $ids) {
        [void]$sb.AppendLine("ns.UnlockedAppearances[$id] = true")
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("function ns.IsAppearanceUnlocked(itemId)")
    [void]$sb.AppendLine("    if not next(ns.UnlockedAppearances) then return true end")
    [void]$sb.AppendLine("    return ns.UnlockedAppearances[itemId] == true")
    [void]$sb.AppendLine("end")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("function ns.IsAnyIdUnlocked(ids)")
    [void]$sb.AppendLine("    if not next(ns.UnlockedAppearances) then return true end")
    [void]$sb.AppendLine("    for _, id in ipairs(ids) do")
    [void]$sb.AppendLine("        if ns.UnlockedAppearances[id] then return true end")
    [void]$sb.AppendLine("    end")
    [void]$sb.AppendLine("    return false")
    [void]$sb.AppendLine("end")

    if (-not (Test-Path -LiteralPath $DbFolder)) {
        New-Item -ItemType Directory -Path $DbFolder -Force | Out-Null
    }

    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($outFile, $sb.ToString(), $utf8)

    # Persistir ruta por si se autodetoecto
    DressMe-GuardarRutaAddon $DbFolder

    return @{ Count = $ids.Count; Path = $outFile; Folder = $DbFolder; AccountId = $AccountId }
}

Function global:DressMe-SincronizarDesdeTransmog {
    # Llamado por el boton/check de la ventana Transmog
    try {
        $acc = 0
        if ($script:TmAcc) { try { $acc = [int]$script:TmAcc } catch {} }
        if ($acc -le 0) {
            [System.Windows.Forms.MessageBox]::Show(
                "No hay cuenta de transmog cargada. Abre Transmog desde un personaje.",
                "DressMe", "OK", "Warning")
            return
        }

        $user = DressMe-ObtenerUsuarioCuenta $acc
        if (-not (DressMe-PuedeGenerarParaCuenta -AccountId $acc -Username $user)) {
            [System.Windows.Forms.MessageBox]::Show(
                ("La cuenta '{0}' parece un playerbot (prefijo bloqueado).`nNo se genera el archivo DressMe." -f $(if ($user) { $user } else { $acc })),
                "DressMe", "OK", "Warning")
            return
        }

        $r = DressMe-GenerarYCopiar -AccountId $acc
        [System.Windows.Forms.MessageBox]::Show(
            ("Sincronizado.`n`nCuenta: {0}`nItems: {1}`n`nArchivo:`n{2}`n`nEn el juego escribe: /reload`n`nAVISO: Necesitas tener instalado el addon DressMe MODIFICADO para servidores privados (filtro por apariencias desbloqueadas). El DressMe original no usara este archivo." -f $r.AccountId, $r.Count, $r.Path),
            "DressMe - OK", "OK", "Information")
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Error al sincronizar:`n$($_.Exception.Message)",
            "DressMe", "OK", "Error")
    }
}

Function global:DressMe-ConfigurarRuta {
    $r = DressMe-PedirRutaAddon
    if ($r) {
        [System.Windows.Forms.MessageBox]::Show(
            "Ruta guardada en config_server.txt:`n`nDRESSME_DB_PATH=$r",
            "DressMe", "OK", "Information")
    }
}


Function global:DressMe-SincronizarSilencioso {
    param(
        [int]$AccountId = 0,
        [int]$GuidChar = 0,
        [switch]$MostrarAviso
    )
    try {
        $username = $null
        if ($AccountId -le 0 -and $GuidChar -gt 0) {
            $info = DressMe-ObtenerCuentaDeGuid $GuidChar
            if ($info) {
                $AccountId = [int]$info.AccountId
                $username = $info.Username
            }
        }
        if ($AccountId -le 0) { return $null }

        if (-not $username) { $username = DressMe-ObtenerUsuarioCuenta $AccountId }
        if (-not (DressMe-PuedeGenerarParaCuenta -AccountId $AccountId -Username $username)) {
            # Cuenta playerbot (prefijo rnb/rnd/...): no generar
            return $null
        }

        $ruta = DressMe-LeerRutaAddon
        if (-not $ruta -or -not (Test-Path -LiteralPath $ruta)) {
            return $null
        }

        $r = DressMe-GenerarYCopiar -AccountId $AccountId -DbFolder $ruta
        # Recordar ultima cuenta real para el timer periodico
        $Global:DressMeLastAccountId = $AccountId
        $Global:DressMeLastAccountUser = $username

        if ($MostrarAviso) {
            [System.Windows.Forms.MessageBox]::Show(
                ("DressMe actualizado automaticamente.`n`nCuenta: {0} ({1})`nItems: {2}`n`n{3}`n`n/reload en el juego.`n`nAVISO: Requiere el addon DressMe MODIFICADO para servidores privados." -f $AccountId, $username, $r.Count, $r.Path),
                "DressMe", "OK", "Information")
        }
        return $r
    } catch {
        return $null
    }
}

Function global:DressMe-AutoDesdeArmeria {
    param([int]$GuidChar)
    try {
        if ($GuidChar -le 0) { return }
        $ahora = Get-Date
        if ($script:DressMeLastAutoGuid -eq $GuidChar -and $script:DressMeLastAutoTime) {
            $diff = ($ahora - $script:DressMeLastAutoTime).TotalSeconds
            if ($diff -lt 30) { return }
        }
        $script:DressMeLastAutoGuid = $GuidChar
        $script:DressMeLastAutoTime = $ahora
        [void](DressMe-SincronizarSilencioso -GuidChar $GuidChar)
    } catch {}
}

Function global:DressMe-ElegirCuentaParaTimer {
    # 1) Ultima cuenta real usada en Armeria
    if ($Global:DressMeLastAccountId -and $Global:DressMeLastAccountId -gt 0) {
        if (DressMe-PuedeGenerarParaCuenta -AccountId ([int]$Global:DressMeLastAccountId)) {
            return [int]$Global:DressMeLastAccountId
        }
    }
    # 2) Primera cuenta online que no sea bot y tenga apariencias
    $bd = if ($Global:CharDbName) { $Global:CharDbName } else { "acore_characters" }
    $sql = @"
SELECT c.account, IFNULL(a.username,''), COUNT(ua.item_template_id) AS n
FROM characters c
INNER JOIN acore_auth.account a ON a.id = c.account
LEFT JOIN custom_unlocked_appearances ua ON ua.account_id = c.account
WHERE c.online = 1
GROUP BY c.account, a.username
ORDER BY n DESC;
"@
    try {
        foreach ($ln in @(DressMe-Consulta $sql $bd)) {
            if (-not $ln) { continue }
            $p = ("$ln") -split "`t"
            if ($p.Count -lt 1) { continue }
            $acc = 0
            try { $acc = [int]($p[0].Trim()) } catch { continue }
            $user = if ($p.Count -ge 2) { $p[1].Trim() } else { "" }
            if ($acc -gt 0 -and (DressMe-PuedeGenerarParaCuenta -AccountId $acc -Username $user)) {
                return $acc
            }
        }
    } catch {}
    return 0
}

Function global:DressMe-TickTimer {
    try {
        $ruta = DressMe-LeerRutaAddon
        if (-not $ruta -or -not (Test-Path -LiteralPath $ruta)) { return }
        $acc = DressMe-ElegirCuentaParaTimer
        if ($acc -le 0) { return }
        [void](DressMe-SincronizarSilencioso -AccountId $acc)
    } catch {}
}

Function global:DressMe-IniciarTimerAuto {
    try {
        $mins = 5
        if ($null -ne $Global:DressMeTimerMinutes) {
            try { $mins = [int]$Global:DressMeTimerMinutes } catch { $mins = 5 }
        }
        if ($mins -le 0) {
            DressMe-DetenerTimerAuto
            return
        }
        if ($script:DressMeAutoTimer) {
            try { $script:DressMeAutoTimer.Stop(); $script:DressMeAutoTimer.Dispose() } catch {}
            $script:DressMeAutoTimer = $null
        }
        $script:DressMeAutoTimer = New-Object System.Windows.Forms.Timer
        $script:DressMeAutoTimer.Interval = [Math]::Max(60000, $mins * 60 * 1000)
        $script:DressMeAutoTimer.Add_Tick({ DressMe-TickTimer })
        $script:DressMeAutoTimer.Start()
        $Global:DressMeTimerActivo = $true
    } catch {
        $Global:DressMeTimerActivo = $false
    }
}

Function global:DressMe-DetenerTimerAuto {
    try {
        if ($script:DressMeAutoTimer) {
            $script:DressMeAutoTimer.Stop()
            $script:DressMeAutoTimer.Dispose()
            $script:DressMeAutoTimer = $null
        }
    } catch {}
    $Global:DressMeTimerActivo = $false
}

# Arrancar timer al cargar el modulo (panel abierto)
try {
    if (Get-Command DressMe-IniciarTimerAuto -ErrorAction SilentlyContinue) {
        # Retrasar un poco para que exista config MySQL
        $boot = New-Object System.Windows.Forms.Timer
        $boot.Interval = 8000
        $boot.Add_Tick({
            try { $boot.Stop(); $boot.Dispose() } catch {}
            try { DressMe-IniciarTimerAuto } catch {}
        })
        $boot.Start()
    }
} catch {}
