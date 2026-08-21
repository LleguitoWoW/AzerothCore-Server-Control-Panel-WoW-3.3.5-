# =========================================================================
# Módulo: Gestión de mods (activar / desactivar vía .conf)
# =========================================================================

Function global:Obtener-CarpetaModulesConf {
    $candidatos = @()
    if ($Global:WorldConfPath) {
        $dirConf = Split-Path -Parent $Global:WorldConfPath
        if ($dirConf) {
            $candidatos += (Join-Path $dirConf "modules")
            $candidatos += (Join-Path (Split-Path -Parent $dirConf) "modules")
        }
    }
    if ($Global:WorldDir) {
        $candidatos += (Join-Path $Global:WorldDir "configs\modules")
        $candidatos += (Join-Path $Global:WorldDir "etc\modules")
        $candidatos += (Join-Path $Global:WorldDir "modules")
        $parent = Split-Path -Parent $Global:WorldDir
        if ($parent) {
            $candidatos += (Join-Path $parent "configs\modules")
            $candidatos += (Join-Path $parent "etc\modules")
        }
    }
    foreach ($c in $candidatos) {
        if ($c -and (Test-Path -LiteralPath $c)) { return $c }
    }
    return $null
}

Function global:Mods-ParsearValorActivo($raw) {
    if ($null -eq $raw) { return $null }
    $v = ([string]$raw).Trim().Trim('"').Trim("'")
    $low = $v.ToLowerInvariant()
    if ($low -in @("1", "true", "on", "yes", "y", "enabled")) { return $true }
    if ($low -in @("0", "false", "off", "no", "n", "disabled")) { return $false }
    return $null
}

Function global:Mods-FormatearValor($activo, $estiloOriginal) {
    $est = if ($estiloOriginal) { ([string]$estiloOriginal).Trim() } else { "1" }
    $low = $est.ToLowerInvariant()
    if ($low -in @("true", "false")) {
        if ($activo) { return "true" } else { return "false" }
    }
    if ($low -in @("on", "off")) {
        if ($activo) { return "on" } else { return "off" }
    }
    if ($low -in @("yes", "no")) {
        if ($activo) { return "yes" } else { return "no" }
    }
    # Por defecto numerico 1/0
    if ($activo) { return "1" } else { return "0" }
}

# Busca la clave de enable mas probable en el conf
Function global:Mods-DetectarClaveEnable($lineas) {
    # 1) Preferido: marcador del panel en la linea anterior (o en la misma linea)
    #    Pon en el .conf UNA de estas formas:
    #      # @PANEL_TOGGLE
    #      MiMod.Enable = 1
    #    o en la misma linea:
    #      MiMod.Enable = true   # @PANEL_TOGGLE
    $marker = '@PANEL_TOGGLE'
    for ($i = 0; $i -lt $lineas.Count; $i++) {
        $t = [string]$lineas[$i]
        if ($t -notmatch [regex]::Escape($marker)) { continue }

        # Misma linea: clave = valor ... # @PANEL_TOGGLE
        if ($t -match '^\s*([A-Za-z0-9_.]+)\s*=\s*([^#]+)') {
            $clave = $Matches[1].Trim()
            $val = $Matches[2].Trim()
            $bool = Mods-ParsearValorActivo $val
            if ($null -ne $bool) {
                return [PSCustomObject]@{
                    LineaIndex = $i
                    Clave      = $clave
                    Valor      = $val
                    Activo     = $bool
                    Score      = 1000
                    LineaRaw   = $t
                    Origen     = "marcador-misma-linea"
                }
            }
        }

        # Linea siguiente con clave = valor
        for ($j = $i + 1; $j -lt $lineas.Count; $j++) {
            $n = [string]$lineas[$j]
            if ($n -match '^\s*$') { continue }
            if ($n -match '^\s*#') { continue }
            if ($n -match '^\s*([A-Za-z0-9_.]+)\s*=\s*(.+)$') {
                $clave = $Matches[1].Trim()
                $val = $Matches[2].Trim()
                if ($val -match '(\s+#.*)$') { $val = $val.Substring(0, $val.Length - $Matches[1].Length).Trim() }
                $bool = Mods-ParsearValorActivo $val
                if ($null -ne $bool) {
                    return [PSCustomObject]@{
                        LineaIndex = $j
                        Clave      = $clave
                        Valor      = $val
                        Activo     = $bool
                        Score      = 1000
                        LineaRaw   = $n
                        Origen     = "marcador"
                    }
                }
            }
            break
        }
    }

    # 2) Fallback automatico (por si no hay marcador)
    $patrones = @(
        '^\s*([A-Za-z0-9_.]+)\.Enable\s*=\s*(.+)$',
        '^\s*([A-Za-z0-9_.]+)\.Enabled\s*=\s*(.+)$',
        '^\s*Enable\.([A-Za-z0-9_]+)\s*=\s*(.+)$',
        '^\s*([A-Za-z0-9_.]*Enable[A-Za-z0-9_]*)\s*=\s*(.+)$',
        '^\s*([A-Za-z0-9_.]*Enabled[A-Za-z0-9_]*)\s*=\s*(.+)$'
    )
    $candidatos = @()
    $i = 0
    foreach ($linea in $lineas) {
        $i++
        $t = [string]$linea
        if ($t -match '^\s*#') { continue }
        if ($t -notmatch '=') { continue }
        foreach ($pat in $patrones) {
            if ($t -match $pat) {
                $clave = $Matches[1].Trim()
                $val = $Matches[2].Trim()
                if ($val -match '(\s+#.*)$') { $val = $val.Substring(0, $val.Length - $Matches[1].Length).Trim() }
                if ($clave -match 'Max|Min|Count|Level|Rate|Chance|Distance|Time|Size|Radius') { continue }
                $bool = Mods-ParsearValorActivo $val
                if ($null -eq $bool) { continue }
                $score = 10
                if ($clave -match '\.Enable$') { $score = 100 }
                elseif ($clave -match '\.Enabled$') { $score = 90 }
                elseif ($clave -match '^Enable') { $score = 80 }
                elseif ($clave -match 'Enable') { $score = 50 }
                $candidatos += [PSCustomObject]@{
                    LineaIndex = ($i - 1)
                    Clave      = $clave
                    Valor      = $val
                    Activo     = $bool
                    Score      = $score
                    LineaRaw   = $t
                    Origen     = "auto"
                }
                break
            }
        }
    }
    if ($candidatos.Count -eq 0) { return $null }
    return ($candidatos | Sort-Object Score -Descending | Select-Object -First 1)
}

Function global:Mods-Listar {
    $dir = Obtener-CarpetaModulesConf
    $lista = @()
    if (-not $dir) {
        return @{ Error = (Obtener-Texto "MsgModsConfNoDir" "No se encontro la carpeta configs\modules. Configura la ruta del worldserver."); Mods = @(); Dir = $null }
    }
    $files = @(Get-ChildItem -LiteralPath $dir -Filter "*.conf" -File -ErrorAction SilentlyContinue | Sort-Object Name)
    foreach ($f in $files) {
        $lineas = @()
        try { $lineas = Get-Content -LiteralPath $f.FullName -Encoding UTF8 } catch {
            try { $lineas = Get-Content -LiteralPath $f.FullName } catch { continue }
        }
        $det = Mods-DetectarClaveEnable $lineas
        $nombre = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
        $lista += [PSCustomObject]@{
            Nombre     = $nombre
            Archivo    = $f.Name
            Ruta       = $f.FullName
            TieneEnable = [bool]$det
            Clave      = if ($det) { $det.Clave } else { $null }
            Valor      = if ($det) { $det.Valor } else { $null }
            Activo     = if ($det) { [bool]$det.Activo } else { $null }
            LineaIndex = if ($det) { $det.LineaIndex } else { -1 }
        }
    }
    return @{ Error = $null; Mods = $lista; Dir = $dir }
}

Function global:Mods-Alternar($rutaArchivo) {
    if (-not $rutaArchivo -or -not (Test-Path -LiteralPath $rutaArchivo)) {
        return @{ Ok = $false; Msg = "Archivo no encontrado." }
    }
    $lineas = $null
    try { $lineas = [System.Collections.Generic.List[string]](Get-Content -LiteralPath $rutaArchivo -Encoding UTF8) }
    catch { $lineas = [System.Collections.Generic.List[string]](Get-Content -LiteralPath $rutaArchivo) }

    $det = Mods-DetectarClaveEnable $lineas
    if (-not $det) {
        return @{ Ok = $false; Msg = (Obtener-Texto "MsgModsSinEnable" "No se detecto una clave Enable/Enabled en este conf.") }
    }

    $nuevoActivo = -not [bool]$det.Activo
    $nuevoVal = Mods-FormatearValor $nuevoActivo $det.Valor
    $idx = [int]$det.LineaIndex
    $oldLine = $lineas[$idx]
    # Sustituir solo el valor tras el =
    if ($oldLine -match '^(\s*[A-Za-z0-9_.]+\s*=\s*)(.*)$') {
        $nuevaLinea = $Matches[1] + $nuevoVal
        # conservar comentario final si existia
        if ($oldLine -match '(\s+#.*)$') { $nuevaLinea += $Matches[1] }
        $lineas[$idx] = $nuevaLinea
    } else {
        $lineas[$idx] = ($det.Clave + " = " + $nuevoVal)
    }

    try {
        # Backup .bak una vez
        $bak = $rutaArchivo + ".bak"
        if (-not (Test-Path -LiteralPath $bak)) {
            Copy-Item -LiteralPath $rutaArchivo -Destination $bak -Force
        }
        Set-Content -LiteralPath $rutaArchivo -Value $lineas -Encoding UTF8
        return @{
            Ok     = $true
            Activo = $nuevoActivo
            Clave  = $det.Clave
            Valor  = $nuevoVal
            Msg    = if ($nuevoActivo) { "ON" } else { "OFF" }
        }
    } catch {
        return @{ Ok = $false; Msg = $_.Exception.Message }
    }
}

Function global:Mods-RellenarPanelLista {
    param($panel, $lblDir, $fPeq, $fBold)

    if (-not $panel) { return }
    try { $panel.Controls.Clear() } catch {}

    $data = Mods-Listar
    if ($data.Error) {
        if ($lblDir) { $lblDir.Text = $data.Error }
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $data.Error
        $lbl.Location = New-Object System.Drawing.Point(12, 12)
        $lbl.Size = New-Object System.Drawing.Size(620, 60)
        $lbl.ForeColor = [System.Drawing.Color]::FromArgb(255, 150, 100)
        $lbl.Font = $fPeq
        $panel.Controls.Add($lbl)
        return
    }
    if ($lblDir) {
        $lblDir.Text = (Obtener-Texto "LblModsCarpeta" "Carpeta:") + " " + $data.Dir
    }

    $y = 8
    foreach ($m in $data.Mods) {
        $row = New-Object System.Windows.Forms.Panel
        $row.Location = New-Object System.Drawing.Point(8, $y)
        $row.Size = New-Object System.Drawing.Size(640, 44)
        $row.BackColor = [System.Drawing.Color]::FromArgb(30, 28, 26)

        $lblN = New-Object System.Windows.Forms.Label
        $lblN.Text = $m.Nombre
        $lblN.Location = New-Object System.Drawing.Point(10, 6)
        $lblN.Size = New-Object System.Drawing.Size(280, 18)
        $lblN.Font = $fBold
        $lblN.ForeColor = [System.Drawing.Color]::White
        $row.Controls.Add($lblN)

        $lblK = New-Object System.Windows.Forms.Label
        if ($m.TieneEnable) {
            $lblK.Text = "$($m.Clave) = $($m.Valor)"
        } else {
            $lblK.Text = (Obtener-Texto "MsgModsSinClave" "Sin @PANEL_TOGGLE / Enable detectado")
        }
        $lblK.Location = New-Object System.Drawing.Point(10, 24)
        $lblK.Size = New-Object System.Drawing.Size(360, 16)
        $lblK.Font = New-Object System.Drawing.Font("Georgia", 7.5)
        $lblK.ForeColor = [System.Drawing.Color]::FromArgb(160, 150, 140)
        $row.Controls.Add($lblK)

        $btn = New-Object System.Windows.Forms.Button
        $btn.Size = New-Object System.Drawing.Size(110, 32)
        $btn.Location = New-Object System.Drawing.Point(510, 6)
        $btn.FlatStyle = "Flat"
        $btn.Font = $fBold
        $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btn.Tag = $m.Ruta

        if (-not $m.TieneEnable) {
            $btn.Text = "—"
            $btn.Enabled = $false
            $btn.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
            $btn.ForeColor = [System.Drawing.Color]::Gray
        } elseif ($m.Activo) {
            $btn.Text = (Obtener-Texto "BtnModOn" "ON")
            $btn.BackColor = [System.Drawing.Color]::FromArgb(30, 120, 60)
            $btn.ForeColor = [System.Drawing.Color]::White
        } else {
            $btn.Text = (Obtener-Texto "BtnModOff" "OFF")
            $btn.BackColor = [System.Drawing.Color]::FromArgb(120, 40, 40)
            $btn.ForeColor = [System.Drawing.Color]::White
        }

        $btn.Add_Click({
            try {
                $ruta = [string]$this.Tag
                $res = Mods-Alternar $ruta
                if (-not $res.Ok) {
                    [System.Windows.Forms.MessageBox]::Show(
                        $res.Msg,
                        (Obtener-Texto "TituloMods" "Mods del servidor"),
                        "OK", "Warning")
                    return
                }
                if ($script:ModsPanelLista -and $script:ModsLblDir) {
                    Mods-RellenarPanelLista $script:ModsPanelLista $script:ModsLblDir $script:ModsFontPeq $script:ModsFontBold
                }
            } catch {
                [System.Windows.Forms.MessageBox]::Show(
                    $_.Exception.Message,
                    (Obtener-Texto "TituloMods" "Mods del servidor"),
                    "OK", "Error")
            }
        })

        $row.Controls.Add($btn)
        $panel.Controls.Add($row)
        $y += 50
    }

    if ($data.Mods.Count -eq 0) {
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = (Obtener-Texto "MsgModsVacio" "No hay archivos .conf en la carpeta de modules.")
        $lbl.Location = New-Object System.Drawing.Point(12, 12)
        $lbl.Size = New-Object System.Drawing.Size(600, 40)
        $lbl.ForeColor = [System.Drawing.Color]::FromArgb(200, 180, 120)
        $lbl.Font = $fPeq
        $panel.Controls.Add($lbl)
    }
}

Function global:Abrir-PanelMods {
    param($formPadre)

    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue

    $fTitle = New-Object System.Drawing.Font("Georgia", 12, [System.Drawing.FontStyle]::Bold)
    $fPeq   = New-Object System.Drawing.Font("Georgia", 8.5)
    $fBold  = New-Object System.Drawing.Font("Georgia", 9, [System.Drawing.FontStyle]::Bold)

    $mf = New-Object System.Windows.Forms.Form
    $mf.Text = (Obtener-Texto "TituloMods" "Mods del servidor")
    $mf.Size = New-Object System.Drawing.Size(720, 560)
    $mf.StartPosition = "CenterParent"
    $mf.BackColor = [System.Drawing.Color]::FromArgb(18, 16, 14)
    $mf.ForeColor = [System.Drawing.Color]::White
    $mf.FormBorderStyle = "FixedDialog"
    $mf.MaximizeBox = $false

    $lblTit = New-Object System.Windows.Forms.Label
    $lblTit.Text = (Obtener-Texto "TituloMods" "Mods del servidor")
    $lblTit.Location = New-Object System.Drawing.Point(16, 12)
    $lblTit.Size = New-Object System.Drawing.Size(500, 24)
    $lblTit.Font = $fTitle
    $lblTit.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $mf.Controls.Add($lblTit)

    $lblInfo = New-Object System.Windows.Forms.Label
    $lblInfo.Location = New-Object System.Drawing.Point(16, 40)
    $lblInfo.Size = New-Object System.Drawing.Size(680, 36)
    $lblInfo.Font = $fPeq
    $lblInfo.ForeColor = [System.Drawing.Color]::FromArgb(200, 190, 160)
    $lblInfo.Text = (Obtener-Texto "MsgModsInfo" "En cada conf pon # @PANEL_TOGGLE encima de la linea Enable. El boton respeta 0/1 o true/false. Reinicia el worldserver.")
    $mf.Controls.Add($lblInfo)

    $lblDir = New-Object System.Windows.Forms.Label
    $lblDir.Location = New-Object System.Drawing.Point(16, 78)
    $lblDir.Size = New-Object System.Drawing.Size(390, 18)
    $lblDir.Font = New-Object System.Drawing.Font("Georgia", 7.5)
    $lblDir.ForeColor = [System.Drawing.Color]::FromArgb(150, 140, 130)
    $mf.Controls.Add($lblDir)

    $btnAyuda = New-Object System.Windows.Forms.Button
    $btnAyuda.Text = (Obtener-Texto "BtnAnadirMods" "Anadir mods")
    $btnAyuda.Location = New-Object System.Drawing.Point(420, 72)
    $btnAyuda.Size = New-Object System.Drawing.Size(130, 28)
    $btnAyuda.FlatStyle = "Flat"
    $btnAyuda.BackColor = [System.Drawing.Color]::FromArgb(40, 70, 100)
    $btnAyuda.ForeColor = [System.Drawing.Color]::White
    $btnAyuda.Font = $fPeq
    $btnAyuda.Add_Click({
        $msg = Obtener-Texto "MsgAnadirModsAyuda" "COMO ANADIR UN MOD AL GESTOR`n`n1) Instala el mod.`n2) Abre configs\modules\Nombre.conf`n3) Encima del Enable escribe:`n   # @PANEL_TOGGLE`n4) Guarda y pulsa Actualizar."
        [System.Windows.Forms.MessageBox]::Show(
            $msg,
            (Obtener-Texto "BtnAnadirMods" "Anadir mods"),
            "OK", "Information")
    })
    $mf.Controls.Add($btnAyuda)

    $btnRefresh = New-Object System.Windows.Forms.Button
    $btnRefresh.Text = (Obtener-Texto "BtnActualizar" "Actualizar")
    $btnRefresh.Location = New-Object System.Drawing.Point(560, 72)
    $btnRefresh.Size = New-Object System.Drawing.Size(130, 28)
    $btnRefresh.FlatStyle = "Flat"
    $btnRefresh.BackColor = [System.Drawing.Color]::FromArgb(50, 45, 40)
    $btnRefresh.ForeColor = [System.Drawing.Color]::White
    $btnRefresh.Font = $fPeq
    $mf.Controls.Add($btnRefresh)

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point(16, 108)
    $panel.Size = New-Object System.Drawing.Size(674, 400)
    $panel.AutoScroll = $true
    $panel.BackColor = [System.Drawing.Color]::FromArgb(22, 20, 18)
    $mf.Controls.Add($panel)

    $script:ModsPanelLista = $panel
    $script:ModsLblDir = $lblDir
    $script:ModsFontPeq = $fPeq
    $script:ModsFontBold = $fBold

    $btnRefresh.Add_Click({
        try {
            Mods-RellenarPanelLista $script:ModsPanelLista $script:ModsLblDir $script:ModsFontPeq $script:ModsFontBold
        } catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Mods", "OK", "Error")
        }
    })

    Mods-RellenarPanelLista $panel $lblDir $fPeq $fBold

    [void]$mf.ShowDialog($formPadre)
    $mf.Dispose()
}
