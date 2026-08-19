# ==========================================
# MODULO: TRANSMOG (coleccion de apariencias)
# ==========================================
# Basado en azerothcore/mod-transmog
# Tablas (acore_characters):
#   custom_unlocked_appearances (account_id, item_template_id)
#   custom_transmogrification   (GUID, FakeEntry, Owner)
# IMPORTANTE: NO descarga iconos de internet (congelaba el panel).
# Solo usa cache local de Armeria\Imagenes si existe.

$Global:TransmogNombresClase = @{
    0  = "Consumibles"
    1  = "Contenedores"
    2  = "Armas"
    3  = "Gemas"
    4  = "Armaduras"
    5  = "Reactivos"
    6  = "Proyectiles"
    7  = "Materiales / Comercio"
    8  = "Generico"
    9  = "Recetas"
    10 = "Dinero"
    11 = "Carcaj"
    12 = "Mision"
    13 = "Llaves"
    14 = "Permanente"
    15 = "Miscelanea (monturas, mascotas...)"
    16 = "Glifos"
}


Function global:T-Tm([string]$clave, [string]$defecto) {
    try {
        if (Get-Command Obtener-Texto -ErrorAction SilentlyContinue) {
            $t = Obtener-Texto $clave $defecto
            if ($t) { return $t }
        }
    } catch {}
    return $defecto
}

$Global:TransmogNombresRareza = @{
    0 = "Pobre"
    1 = "Comun"
    2 = "Poco comun"
    3 = "Raro"
    4 = "Epico"
    5 = "Legendario"
    6 = "Artefacto"
    7 = "Heirloom"
}

Function global:Transmog-Consulta([string]$sql, [string]$bd) {
    try {
        if (Get-Command Consulta-Armeria -ErrorAction SilentlyContinue) {
            $r = Consulta-Armeria $sql $bd
            if ($null -eq $r) { return @() }
            return @($r)
        }
    } catch {}
    try {
        $mysqlExe = Join-Path $Global:MysqlDir "mysql.exe"
        if (-not (Test-Path $mysqlExe)) { return @() }
        $env:MYSQL_PWD = $Global:MysqlPass
        $filas = & $mysqlExe "-u$Global:MysqlUser" -N -B -e $sql $bd 2>$null
        $env:MYSQL_PWD = ""
        $limpias = @()
        foreach ($t in @($filas)) {
            if ($t -and ("$t" -notmatch '^(mysql:|Warning|ERROR)')) { $limpias += "$t" }
        }
        return $limpias
    } catch { return @() }
}

Function global:Transmog-TablaExiste([string]$tabla, [string]$bd) {
    try {
        $sql = "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$bd' AND table_name='$tabla' LIMIT 1;"
        $r = @(Transmog-Consulta $sql "information_schema")
        if ($r.Count -eq 0) { $r = @(Transmog-Consulta $sql $bd) }
        if ($r.Count -gt 0) {
            $n = 0
            try { $n = [int](("$($r[0])").Trim()) } catch { $n = 0 }
            return ($n -gt 0)
        }
    } catch {}
    # Fallback: intentar SELECT 1
    try {
        $r2 = @(Transmog-Consulta "SELECT 1 FROM $tabla LIMIT 1;" $bd)
        return $true
    } catch { return $false }
    return $false
}

Function global:Transmog-NombreClase($classId) {
    $c = 0
    try { $c = [int]$classId } catch { $c = 0 }
    $def = "Clase $c"
    if ($Global:TransmogNombresClase -and $Global:TransmogNombresClase.ContainsKey($c)) {
        $def = [string]$Global:TransmogNombresClase[$c]
    }
    return (T-Tm ("TmClase$c") $def)
}

Function global:Transmog-NombreRareza($q) {
    $qi = 0
    try { $qi = [int]$q } catch { $qi = 0 }
    $def = "Q$qi"
    if ($Global:TransmogNombresRareza -and $Global:TransmogNombresRareza.ContainsKey($qi)) {
        $def = [string]$Global:TransmogNombresRareza[$qi]
    }
    return (T-Tm ("TmRareza$qi") $def)
}

Function global:Transmog-ColorRareza($q) {
    try {
        $qi = [int]$q
        if ($Global:ArmeriaColorCalidad -and $Global:ArmeriaColorCalidad.ContainsKey($qi)) {
            return $Global:ArmeriaColorCalidad[$qi]
        }
        switch ($qi) {
            0 { return [System.Drawing.Color]::Silver }
            1 { return [System.Drawing.Color]::White }
            2 { return [System.Drawing.Color]::Lime }
            3 { return [System.Drawing.Color]::DodgerBlue }
            4 { return [System.Drawing.Color]::Orchid }
            5 { return [System.Drawing.Color]::Orange }
            6 { return [System.Drawing.Color]::Gold }
            7 { return [System.Drawing.Color]::Cyan }
            default { return [System.Drawing.Color]::White }
        }
    } catch { return [System.Drawing.Color]::White }
}


Function global:Mostrar-DetalleItemTransmog {
    param($entry, $nombreHint, $formPadre)

    try {
        $e = 0
        try { $e = [int]$entry } catch { $e = 0 }
        if ($e -le 0) { return }

        $bdWorld = "acore_world"
        $nombre = if ($nombreHint) { [string]$nombreHint } else { "#$e" }
        $quality = 0
        $nombreCal = ""

        # Datos basicos de item_template
        try {
            $sql = "SELECT IFNULL(name,''), IFNULL(Quality,0) FROM item_template WHERE entry=$e LIMIT 1;"
            $raw = @(Transmog-Consulta $sql $bdWorld)
            if ($raw.Count -gt 0 -and $raw[0]) {
                $p = ("$($raw[0])") -split "`t"
                if ($p.Count -ge 1 -and $p[0]) { $nombre = $p[0].Trim() }
                if ($p.Count -ge 2) { try { $quality = [int]($p[1].Trim()) } catch {} }
            }
        } catch {}

        if ($Global:ArmeriaNombreCalidad -and $Global:ArmeriaNombreCalidad.ContainsKey($quality)) {
            $nombreCal = [string]$Global:ArmeriaNombreCalidad[$quality]
        } else {
            $nombreCal = Transmog-NombreRareza $quality
        }

        # Texto tooltip igual que Armeria: Nombre + Rareza + separador + stats
        $statsTooltip = ""
        try {
            if (Get-Command Obtener-TooltipItem -ErrorAction SilentlyContinue) {
                $statsTooltip = [string](Obtener-TooltipItem $e $null $null)
            }
        } catch {}

        $textoTooltip = "$nombre`n$nombreCal"
        if ($statsTooltip -and $statsTooltip.Trim().Length -gt 0) {
            $textoTooltip += "`n─────────────`n$statsTooltip"
        }

        # Color de calidad (borde)
        $colorCalidad = Transmog-ColorRareza $quality
        if ($Global:ArmeriaColorCalidad -and $Global:ArmeriaColorCalidad.ContainsKey($quality)) {
            $colorCalidad = $Global:ArmeriaColorCalidad[$quality]
        }

        $det = New-Object System.Windows.Forms.Form
        $det.Text = "Item $e"
        $det.StartPosition = "CenterParent"
        $det.BackColor = [System.Drawing.Color]::FromArgb(12, 10, 8)
        $det.FormBorderStyle = "FixedDialog"
        $det.MaximizeBox = $false
        $det.MinimizeBox = $false
        $det.ShowInTaskbar = $false

        # Icono
        $pb = New-Object System.Windows.Forms.PictureBox
        $pb.Location = New-Object System.Drawing.Point(14, 14)
        $pb.Size = New-Object System.Drawing.Size(48, 48)
        $pb.SizeMode = "StretchImage"
        $pb.BackColor = [System.Drawing.Color]::FromArgb(20, 18, 15)
        $pb.BorderStyle = "FixedSingle"
        $img = $null
        try {
            if (Get-Command Descargar-IconoArmeria -ErrorAction SilentlyContinue) {
                $img = Descargar-IconoArmeria $e 48
            }
        } catch {}
        if (-not $img -and $Global:RootDir) {
            try {
                $cf = Join-Path $Global:RootDir "Armeria\Imagenes\$e.jpg"
                if (Test-Path -LiteralPath $cf) {
                    $img0 = [System.Drawing.Image]::FromFile($cf)
                    $bmp = New-Object System.Drawing.Bitmap 48, 48
                    $g0 = [System.Drawing.Graphics]::FromImage($bmp)
                    $g0.DrawImage($img0, 0, 0, 48, 48)
                    $g0.Dispose(); $img0.Dispose()
                    $img = $bmp
                }
            } catch {}
        }
        if ($img) { $pb.Image = $img }
        [void]$det.Controls.Add($pb)

        # Panel estilo tooltip Armeria (OwnerDraw)
        $panelTip = New-Object System.Windows.Forms.Panel
        $panelTip.Location = New-Object System.Drawing.Point(70, 10)
        $panelTip.BackColor = [System.Drawing.Color]::FromArgb(20, 18, 15)
        $panelTip.BorderStyle = "None"
        $script:TmDetTexto = $textoTooltip
        $script:TmDetColorCal = $colorCalidad

        $fontTip = New-Object System.Drawing.Font("Georgia", 8.5)
        $fontBold = New-Object System.Drawing.Font("Georgia", 8.5, [System.Drawing.FontStyle]::Bold)

        # Calcular tamaño
        $maxW = 280; $totalH = 10
        foreach ($ln in ($textoTooltip -split "`n")) {
            $sz = [System.Windows.Forms.TextRenderer]::MeasureText($ln, $fontTip)
            if ($sz.Width -gt $maxW) { $maxW = $sz.Width }
            $totalH += $sz.Height + 1
        }
        if ($maxW -gt 420) { $maxW = 420 }
        if ($totalH -gt 520) { $totalH = 520 }
        $panelTip.Size = New-Object System.Drawing.Size(($maxW + 20), ($totalH + 8))

        $panelTip.Add_Paint({
            param($sender, $e)
            $g = $e.Graphics
            $g.Clear([System.Drawing.Color]::FromArgb(20, 18, 15))
            $txt = $script:TmDetTexto
            if (-not $txt) { return }
            $colorCalidad = $script:TmDetColorCal
            if (-not $colorCalidad) { $colorCalidad = [System.Drawing.Color]::FromArgb(163, 53, 238) }

            $penBorde = New-Object System.Drawing.Pen($colorCalidad, 2)
            $g.DrawRectangle($penBorde, 1, 1, ($sender.Width - 3), ($sender.Height - 3))
            $penBorde.Dispose()

            $fN = New-Object System.Drawing.Font("Georgia", 8.5)
            $fB = New-Object System.Drawing.Font("Georgia", 8.5, [System.Drawing.FontStyle]::Bold)
            $brushNormal = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230,210,180))
            $brushVerde  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30,255,0))
            $brushCal    = New-Object System.Drawing.SolidBrush($colorCalidad)
            $brushGris   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(160,150,130))
            $brushAzul   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100,180,255))
            $brushGrisClaro = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120,110,100))

            $y = 6; $x = 8; $esPrimera = $true
            foreach ($ln in ($txt -split "`n")) {
                $brush = $brushNormal; $font = $fN
                if ($esPrimera -and $ln -and $ln -notmatch '^\s*$') {
                    $brush = $brushCal; $font = $fB; $esPrimera = $false
                }
                elseif ($ln -match '^[─\-]+$') { $brush = $brushGris }
                elseif ($ln -match '(?i)^(equipar|equip|uso|use|chance on|probabilidad al|al golpear|on equip|on use)\b') { $brush = $brushVerde }
                elseif ($ln -match '^[\+\-]\d' -or $ln -match '(?i)valoraci[oó]n|poder de|esp[ií]ritu|aguante|agilidad|fuerza|intelecto|armadura|cr[ií]tico|golpe|resistencia|da[nñ]o|celeridad|haste|índice de|indice de|pericia|expertise|penetraci[oó]n|defense|defensa|block|bloqueo|dodge|esquiva|parry|parada|resilience|resiliencia|mp5|mana cada|regenera') { $brush = $brushVerde }
                elseif ($ln -match '^(Encantamiento|Gema|Socket|Bonus socket|Set):') { $brush = $brushAzul }
                elseif ($ln -match '^(Pobre|Comun|Poco comun|Raro|Epico|Legendario|Artefacto|Herencia)$') { $brush = $brushCal }
                elseif ($ln -match '^\[.+\]$' -or $ln -match 'vacío|piezas|Se liga|Necesitas|Nivel de objeto|Unique|Único') { $brush = $brushGris }
                $g.DrawString($ln, $font, $brush, $x, $y)
                $y += [math]::Ceiling($g.MeasureString($ln, $font).Height) + 1
            }
            $fN.Dispose(); $fB.Dispose()
            $brushNormal.Dispose(); $brushVerde.Dispose(); $brushCal.Dispose()
            $brushGris.Dispose(); $brushAzul.Dispose(); $brushGrisClaro.Dispose()
        })
        [void]$det.Controls.Add($panelTip)

        $btnCerrar = New-Object System.Windows.Forms.Button
        $btnCerrar.Text = (T-Tm "BtnCerrar" "Cerrar")
        $btnCerrar.Size = New-Object System.Drawing.Size(90, 26)
        $btnCerrar.FlatStyle = "Flat"
        $btnCerrar.BackColor = [System.Drawing.Color]::FromArgb(50, 40, 20)
        $btnCerrar.ForeColor = [System.Drawing.Color]::White
        $btnCerrar.Add_Click({ $det.Close() })
        [void]$det.Controls.Add($btnCerrar)

        # Ajustar tamaño del formulario
        $formW = [Math]::Max(360, $panelTip.Right + 20)
        $formH = [Math]::Max(200, $panelTip.Bottom + 50)
        if ($formW -gt 520) { $formW = 520 }
        if ($formH -gt 620) { $formH = 620 }
        $det.ClientSize = New-Object System.Drawing.Size($formW, $formH)
        $btnCerrar.Location = New-Object System.Drawing.Point( ([int](($formW - 90) / 2)), ($formH - 36) )

        [void]$det.ShowDialog()
        $det.Dispose()
        try { $fontTip.Dispose(); $fontBold.Dispose() } catch {}
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error detalle item:`n$($_.Exception.Message)", "Transmog", "OK", "Error")
    }
}


Function global:Transmog-RellenarLista {
    param($listView, $lbl, $allItems, $filtroTexto, $accId)

    if (-not $listView) { return }
    try {
        $listView.BeginUpdate()
        $listView.Items.Clear()
        $listView.Groups.Clear()

        $lista = @()
        if ($null -ne $allItems) { $lista = @($allItems) }

        if ($filtroTexto -and ([string]$filtroTexto).Trim().Length -gt 0) {
            $f = ([string]$filtroTexto).Trim().ToLower()
            $tmp = @()
            foreach ($x in $lista) {
                $n = ""; $e = ""
                try { $n = ([string]$x.Nombre).ToLower() } catch {}
                try { $e = [string]$x.Entry } catch {}
                if (($n -and $n.Contains($f)) -or ($e -eq $f)) { $tmp += $x }
            }
            $lista = $tmp
        }

        $grupos = @{}
        foreach ($it in $lista) {
            $cl = 0
            try { $cl = [int]$it.Class } catch {}
            $gName = Transmog-NombreClase $cl
            if (-not $grupos.ContainsKey($cl)) {
                $g = New-Object System.Windows.Forms.ListViewGroup($gName, "Horizontal")
                $grupos[$cl] = $g
                [void]$listView.Groups.Add($g)
            }
            $rareza = Transmog-NombreRareza $it.Quality
            $lvi = New-Object System.Windows.Forms.ListViewItem([string]$it.Nombre)
            [void]$lvi.SubItems.Add([string]$it.Entry)
            [void]$lvi.SubItems.Add($rareza)
            [void]$lvi.SubItems.Add([string]$it.ItemLevel)
            [void]$lvi.SubItems.Add($gName)
            $lvi.ForeColor = Transmog-ColorRareza $it.Quality
            $lvi.Group = $grupos[$cl]
            $lvi.Tag = [string]$it.Entry
            [void]$listView.Items.Add($lvi)
        }

        if ($lbl) {
            $lbl.Text = ((T-Tm "LblAprendidasCuenta" "APRENDIDAS (cuenta #{0}): {1} piezas  |  Agrupadas por clase  |  Doble clic = ficha") -f $accId, $lista.Count)
        }
    } catch {
        if ($lbl) { $lbl.Text = "Error lista: $($_.Exception.Message)" }
    } finally {
        try { $listView.EndUpdate() } catch {}
    }
}


Function global:Transmog-CargarIconoLocal($entry, $tamanio) {
    $e = 0
    try { $e = [int]$entry } catch { return $null }
    if ($e -le 0) { return $null }
    $sz = 64
    try { if ($tamanio -gt 0) { $sz = [int]$tamanio } } catch {}
    try {
        if (Get-Command Descargar-IconoArmeria -ErrorAction SilentlyContinue) {
            $img = Descargar-IconoArmeria $e $sz
            if ($img) { return $img }
        }
    } catch {}
    $dirs = @()
    if ($Global:RootDir) {
        $dirs += (Join-Path $Global:RootDir "Armeria\Imagenes")
        $dirs += (Join-Path $Global:RootDir "Imagenes")
    }
    if ($Global:AppRoot) { $dirs += (Join-Path $Global:AppRoot "Imagenes") }
    foreach ($dir in $dirs) {
        if (-not $dir -or -not (Test-Path -LiteralPath $dir)) { continue }
        foreach ($ext in @(".jpg", ".png", ".jpeg", ".bmp")) {
            $fp = Join-Path $dir ("$e$ext")
            if (Test-Path -LiteralPath $fp) {
                try {
                    $img0 = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $fp).Path)
                    $bmp = New-Object System.Drawing.Bitmap $sz, $sz
                    $g = [System.Drawing.Graphics]::FromImage($bmp)
                    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                    $g.DrawImage($img0, 0, 0, $sz, $sz)
                    $g.Dispose(); $img0.Dispose()
                    return $bmp
                } catch {}
            }
        }
    }
    return $null
}


Function global:Transmog-RutaCacheScreenshot($entry) {
    $e = 0
    try { $e = [int]$entry } catch { return $null }
    $dirs = @()
    if ($Global:RootDir) {
        $dirs += (Join-Path $Global:RootDir "Armeria\Imagenes\screenshots")
        $dirs += (Join-Path $Global:RootDir "Imagenes\screenshots")
    }
    if ($Global:AppRoot) { $dirs += (Join-Path $Global:AppRoot "Imagenes\screenshots") }
    foreach ($d in $dirs) {
        if ($d) { return (Join-Path $d "$e.jpg") }
    }
    return $null
}

# Descarga captura de Wowhead (item equipado en personaje). Cache local.
# Solo se llama al hacer clic (no en masa) para no congelar el panel.
Function global:Transmog-ObtenerScreenshotWowhead($entry) {
    $e = 0
    try { $e = [int]$entry } catch { return $null }
    if ($e -le 0) { return $null }

    $cacheFile = Transmog-RutaCacheScreenshot $e
    if ($cacheFile -and (Test-Path -LiteralPath $cacheFile)) {
        try {
            $img = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $cacheFile).Path)
            $clone = New-Object System.Drawing.Bitmap $img
            $img.Dispose()
            return $clone
        } catch {}
    }

    # Directorio cache
    if ($cacheFile) {
        $dir = Split-Path -Parent $cacheFile
        if ($dir -and -not (Test-Path -LiteralPath $dir)) {
            try { New-Item -ItemType Directory -Path $dir -Force | Out-Null } catch {}
        }
    }

    try {
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $wc.Headers.Add("Accept", "text/html")
        # Timeout aproximado via ServicePoint
        try { [System.Net.ServicePointManager]::Expect100Continue = $false } catch {}
        $html = $null
        foreach ($urlPage in @(
            "https://www.wowhead.com/wotlk/item=$e",
            "https://www.wowhead.com/wotlk/es/item=$e",
            "https://www.wowhead.com/item=$e"
        )) {
            try {
                $html = $wc.DownloadString($urlPage)
                if ($html -and $html.Length -gt 1000) { break }
            } catch { $html = $null }
        }
        if (-not $html) { return $null }

        $shotId = $null
        # Preferir bloque screenshots = [{...id...typeId...}]
        if ($html -match 'screenshots\s*=\s*(\[[\s\S]*?\]);') {
            $json = $Matches[1]
            $ids = [regex]::Matches($json, '"id"\s*:\s*(\d+)')
            if ($ids.Count -gt 0) {
                # Ultimo suele ser el mas visible / reciente; primero tambien vale
                $shotId = $ids[$ids.Count - 1].Groups[1].Value
                # Si hay varios, preferir el primero de la lista (orden wowhead)
                $shotId = $ids[0].Groups[1].Value
            }
        }
        if (-not $shotId) {
            $m2 = [regex]::Match($html, 'uploads/screenshots/(?:normal|thumb|resized)/(\d+)')
            if ($m2.Success) { $shotId = $m2.Groups[1].Value }
        }
        if (-not $shotId) { return $null }

        $bytes = $null
        foreach ($imgUrl in @(
            "https://wow.zamimg.com/uploads/screenshots/normal/$shotId.jpg",
            "https://wow.zamimg.com/uploads/screenshots/resized/$shotId.jpg",
            "https://wow.zamimg.com/uploads/screenshots/thumb/$shotId.jpg"
        )) {
            try {
                $bytes = $wc.DownloadData($imgUrl)
                if ($bytes -and $bytes.Length -gt 500) { break }
                $bytes = $null
            } catch { $bytes = $null }
        }
        if (-not $bytes) { return $null }

        if ($cacheFile) {
            try { [System.IO.File]::WriteAllBytes($cacheFile, $bytes) } catch {}
        }
        $ms = New-Object System.IO.MemoryStream(,$bytes)
        $img2 = [System.Drawing.Image]::FromStream($ms)
        $clone2 = New-Object System.Drawing.Bitmap $img2
        $img2.Dispose(); $ms.Dispose()
        return $clone2
    } catch {
        return $null
    }
}

Function global:Transmog-ActualizarVistaPrevia {
    param($entry, $nombreHint, $pbPreview, $lblNombre, $lblMeta, $lblStats, $panelBorde)

    try {
        $e = 0
        try { $e = [int]$entry } catch { $e = 0 }
        if ($e -le 0) {
            if ($pbPreview) { $pbPreview.Image = $null }
            if ($lblNombre) { $lblNombre.Text = (T-Tm "TmPreviewVacio" "Selecciona un item de la lista") }
            if ($lblMeta) { $lblMeta.Text = "" }
            if ($lblStats) { $lblStats.Text = "" }
            if ($panelBorde) { $panelBorde.BackColor = [System.Drawing.Color]::FromArgb(60, 50, 40) }
            return
        }

        $bdWorld = "acore_world"
        $nombre = if ($nombreHint) { [string]$nombreHint } else { "#$e" }
        $quality = 0
        $ilvl = 0
        $classId = -1
        $displayId = 0
        try {
            $sql = "SELECT IFNULL(name,''), IFNULL(Quality,0), IFNULL(ItemLevel,0), IFNULL(class,0), IFNULL(displayid,0) FROM item_template WHERE entry=$e LIMIT 1;"
            $raw = @(Transmog-Consulta $sql $bdWorld)
            if ($raw.Count -gt 0 -and $raw[0]) {
                $p = ("$($raw[0])") -split "`t"
                if ($p.Count -ge 1 -and $p[0]) { $nombre = $p[0].Trim() }
                if ($p.Count -ge 2) { try { $quality = [int]($p[1].Trim()) } catch {} }
                if ($p.Count -ge 3) { try { $ilvl = [int]($p[2].Trim()) } catch {} }
                if ($p.Count -ge 4) { try { $classId = [int]($p[3].Trim()) } catch {} }
                if ($p.Count -ge 5) { try { $displayId = [int]($p[4].Trim()) } catch {} }
            }
        } catch {}

        $rareza = Transmog-NombreRareza $quality
        $colorCal = Transmog-ColorRareza $quality
        if ($panelBorde) { $panelBorde.BackColor = $colorCal }
        if ($lblNombre) {
            $lblNombre.Text = $nombre
            $lblNombre.ForeColor = $colorCal
        }
        $meta = "Entry $e"
        if ($ilvl -gt 0) { $meta += "  |  iLvl $ilvl" }
        $meta += "  |  $rareza"
        if ($classId -ge 0) { $meta += "  |  $(Transmog-NombreClase $classId)" }
        if ($displayId -gt 0) { $meta += "`nDisplayID: $displayId" }
        if ($lblMeta) { $lblMeta.Text = $meta }

        $stats = ""
        try {
            if (Get-Command Obtener-TooltipItem -ErrorAction SilentlyContinue) {
                $stats = [string](Obtener-TooltipItem $e $null $null)
            }
        } catch {}
        if ($lblStats) {
            if ($stats -and $stats.Trim().Length -gt 0) {
                $lblStats.Text = $stats
            } else {
                $lblStats.Text = (T-Tm "TmPreviewSinStats" "Sin estadisticas adicionales.")
            }
        }

        if ($pbPreview) {
            # 1) Captura Wowhead (objeto equipado)  2) fallback icono
            $img = $null
            try { $img = Transmog-ObtenerScreenshotWowhead $e } catch { $img = $null }
            if (-not $img) {
                try { $img = Transmog-CargarIconoLocal $e 128 } catch { $img = $null }
            }
            if ($img) {
                $pbPreview.Image = $img
                $pbPreview.SizeMode = "Zoom"
            } else {
                $pbPreview.Image = $null
            }
        }
    } catch {
        try {
            if ($lblNombre) { $lblNombre.Text = "Error: $($_.Exception.Message)" }
        } catch {}
    }
}

Function global:Mostrar-VentanaTransmog {
    param($guidChar, $nombreChar, $formPadre)

    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
        Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue

        $bdChar  = "acore_characters"
        $bdWorld = "acore_world"
        $guidNum = 0
        try { $guidNum = [int]$guidChar } catch { $guidNum = 0 }
        if ($guidNum -le 0) {
            [System.Windows.Forms.MessageBox]::Show((T-Tm "MsgGuidInvalido" "GUID de personaje no valido."), "Transmog", "OK", "Warning")
            return
        }

        $tmForm = New-Object System.Windows.Forms.Form
        $tmForm.Text = ((T-Tm "TituloTransmog" "Transmog - {0}") -f $nombreChar)
        $tmForm.Size = New-Object System.Drawing.Size(960, 800)
        $tmForm.StartPosition = "CenterParent"
        $tmForm.BackColor = [System.Drawing.Color]::FromArgb(15, 12, 10)
        $tmForm.ForeColor = [System.Drawing.Color]::White
        $tmForm.MinimizeBox = $false

        $fTitle = New-Object System.Drawing.Font("Georgia", 12, [System.Drawing.FontStyle]::Bold)
        $fPeq   = New-Object System.Drawing.Font("Georgia", 8.5)
        $fBold  = New-Object System.Drawing.Font("Georgia", 9, [System.Drawing.FontStyle]::Bold)

        $lblTit = New-Object System.Windows.Forms.Label
        $lblTit.Text = ((T-Tm "TituloColeccionTransmog" "Coleccion de apariencias - {0}") -f $nombreChar)
        $lblTit.Location = New-Object System.Drawing.Point(12, 8)
        $lblTit.Size = New-Object System.Drawing.Size(520, 22)
        $lblTit.Font = $fTitle
        $lblTit.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
        [void]$tmForm.Controls.Add($lblTit)

        $lblAviso = New-Object System.Windows.Forms.Label
        $lblAviso.Text = (T-Tm "AvisoTransmogCuenta" "AVISO: La lista superior son apariencias APRENDIDAS ligadas a la CUENTA (compartidas por todos los personajes). Abajo: transmogs ACTIVOS de ESTE personaje.")
        $lblAviso.Location = New-Object System.Drawing.Point(12, 30)
        $lblAviso.Size = New-Object System.Drawing.Size(920, 32)
        $lblAviso.Font = $fPeq
        $lblAviso.ForeColor = [System.Drawing.Color]::FromArgb(255, 180, 80)
        [void]$tmForm.Controls.Add($lblAviso)

        $lblInfo = New-Object System.Windows.Forms.Label
        $lblInfo.Text = (T-Tm "LblCargandoTransmog" "Cargando coleccion de cuenta...")
        $lblInfo.Location = New-Object System.Drawing.Point(12, 64)
        $lblInfo.Size = New-Object System.Drawing.Size(520, 18)
        $lblInfo.Font = $fPeq
        $lblInfo.ForeColor = [System.Drawing.Color]::FromArgb(180, 170, 150)
        [void]$tmForm.Controls.Add($lblInfo)

        $txtFiltro = New-Object System.Windows.Forms.TextBox
        $txtFiltro.Location = New-Object System.Drawing.Point(540, 62)
        $txtFiltro.Size = New-Object System.Drawing.Size(180, 22)
        $txtFiltro.BackColor = [System.Drawing.Color]::FromArgb(30, 28, 24)
        $txtFiltro.ForeColor = [System.Drawing.Color]::White
        [void]$tmForm.Controls.Add($txtFiltro)

        $btnFiltrar = New-Object System.Windows.Forms.Button
        $btnFiltrar.Text = (T-Tm "LblFiltrar" "Filtrar")
        $btnFiltrar.Location = New-Object System.Drawing.Point(730, 60)
        $btnFiltrar.Size = New-Object System.Drawing.Size(80, 24)
        $btnFiltrar.FlatStyle = "Flat"
        $btnFiltrar.BackColor = [System.Drawing.Color]::FromArgb(50, 40, 20)
        $btnFiltrar.ForeColor = [System.Drawing.Color]::White
        [void]$tmForm.Controls.Add($btnFiltrar)

        # ListView coleccion de CUENTA
        $lv = New-Object System.Windows.Forms.ListView
        $lv.Location = New-Object System.Drawing.Point(12, 88)
        $lv.Size = New-Object System.Drawing.Size(920, 220)
        $lv.View = "Details"
        $lv.FullRowSelect = $true
        $lv.GridLines = $true
        $lv.BackColor = [System.Drawing.Color]::FromArgb(22, 20, 18)
        $lv.ForeColor = [System.Drawing.Color]::White
        $lv.Font = $fPeq
        $lv.ShowGroups = $true
        [void]$lv.Columns.Add((T-Tm "ColApariencia" "Nombre"), 320)
        [void]$lv.Columns.Add((T-Tm "ColEntry" "Entry"), 70)
        [void]$lv.Columns.Add((T-Tm "ColRareza" "Rareza"), 100)
        [void]$lv.Columns.Add((T-Tm "ColIlvl" "iLvl"), 50)
        [void]$lv.Columns.Add((T-Tm "ColClaseItem" "Clase"), 200)
        [void]$tmForm.Controls.Add($lv)

        $lblActivosTit = New-Object System.Windows.Forms.Label
        $lblActivosTit.Text = (T-Tm "LblActivosTitulo" "Transmogs activos de este personaje (paperdoll)")
        $lblActivosTit.Location = New-Object System.Drawing.Point(12, 316)
        $lblActivosTit.Size = New-Object System.Drawing.Size(470, 18)
        $lblActivosTit.Font = $fBold
        $lblActivosTit.ForeColor = [System.Drawing.Color]::FromArgb(160, 200, 255)
        [void]$tmForm.Controls.Add($lblActivosTit)

        # Paperdoll de transmogs activos (mismo layout de slots que Armeria, reducido)
        $panelDoll = New-Object System.Windows.Forms.Panel
        $panelDoll.Location = New-Object System.Drawing.Point(12, 338)
        $panelDoll.Size = New-Object System.Drawing.Size(470, 390)
        $panelDoll.BackColor = [System.Drawing.Color]::FromArgb(20, 15, 12)
        $panelDoll.BorderStyle = "FixedSingle"
        [void]$tmForm.Controls.Add($panelDoll)

        $lblActivos = New-Object System.Windows.Forms.Label
        $lblActivos.Location = New-Object System.Drawing.Point(12, 732)
        $lblActivos.Size = New-Object System.Drawing.Size(470, 24)
        $lblActivos.Font = $fPeq
        $lblActivos.ForeColor = [System.Drawing.Color]::FromArgb(180, 170, 150)
        $lblActivos.Text = "Cargando paperdoll..."
        [void]$tmForm.Controls.Add($lblActivos)

        # Panel derecho: vista previa del item (clic en lista)
        $lblPreviewTit = New-Object System.Windows.Forms.Label
        $lblPreviewTit.Text = (T-Tm "TmPreviewTitulo" "Vista previa del objeto")
        $lblPreviewTit.Location = New-Object System.Drawing.Point(500, 316)
        $lblPreviewTit.Size = New-Object System.Drawing.Size(430, 18)
        $lblPreviewTit.Font = $fBold
        $lblPreviewTit.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
        [void]$tmForm.Controls.Add($lblPreviewTit)

        $panelPreview = New-Object System.Windows.Forms.Panel
        $panelPreview.Location = New-Object System.Drawing.Point(500, 338)
        $panelPreview.Size = New-Object System.Drawing.Size(430, 390)
        $panelPreview.BackColor = [System.Drawing.Color]::FromArgb(18, 16, 14)
        $panelPreview.BorderStyle = "FixedSingle"
        [void]$tmForm.Controls.Add($panelPreview)

        $bordeIcono = New-Object System.Windows.Forms.Panel
        $bordeIcono.Location = New-Object System.Drawing.Point(55, 12)
        $bordeIcono.Size = New-Object System.Drawing.Size(320, 200)
        $bordeIcono.BackColor = [System.Drawing.Color]::FromArgb(60, 50, 40)
        $bordeIcono.Padding = New-Object System.Windows.Forms.Padding(4)
        [void]$panelPreview.Controls.Add($bordeIcono)

        $pbPreview = New-Object System.Windows.Forms.PictureBox
        $pbPreview.Dock = "Fill"
        $pbPreview.SizeMode = "StretchImage"
        $pbPreview.BackColor = [System.Drawing.Color]::FromArgb(12, 10, 8)
        $pbPreview.BorderStyle = "None"
        [void]$bordeIcono.Controls.Add($pbPreview)

        $lblPrevNombre = New-Object System.Windows.Forms.Label
        $lblPrevNombre.Location = New-Object System.Drawing.Point(12, 220)
        $lblPrevNombre.Size = New-Object System.Drawing.Size(406, 28)
        $lblPrevNombre.Font = New-Object System.Drawing.Font("Georgia", 11, [System.Drawing.FontStyle]::Bold)
        $lblPrevNombre.ForeColor = [System.Drawing.Color]::White
        $lblPrevNombre.TextAlign = "MiddleCenter"
        $lblPrevNombre.Text = (T-Tm "TmPreviewVacio" "Selecciona un item de la lista")
        [void]$panelPreview.Controls.Add($lblPrevNombre)

        $lblPrevMeta = New-Object System.Windows.Forms.Label
        $lblPrevMeta.Location = New-Object System.Drawing.Point(12, 250)
        $lblPrevMeta.Size = New-Object System.Drawing.Size(406, 36)
        $lblPrevMeta.Font = $fPeq
        $lblPrevMeta.ForeColor = [System.Drawing.Color]::FromArgb(180, 170, 150)
        $lblPrevMeta.TextAlign = "MiddleCenter"
        $lblPrevMeta.Text = ""
        [void]$panelPreview.Controls.Add($lblPrevMeta)

        $lblPrevStats = New-Object System.Windows.Forms.Label
        $lblPrevStats.Location = New-Object System.Drawing.Point(12, 288)
        $lblPrevStats.Size = New-Object System.Drawing.Size(406, 90)
        $lblPrevStats.Font = New-Object System.Drawing.Font("Consolas", 8)
        $lblPrevStats.ForeColor = [System.Drawing.Color]::FromArgb(100, 220, 100)
        $lblPrevStats.Text = (T-Tm "TmPreviewHint" "Clic = captura del objeto equipado (Wowhead) + datos.`nDoble clic = ficha completa.")
        [void]$panelPreview.Controls.Add($lblPrevStats)

        $script:TmPbPreview = $pbPreview
        $script:TmLblPrevNombre = $lblPrevNombre
        $script:TmLblPrevMeta = $lblPrevMeta
        $script:TmLblPrevStats = $lblPrevStats
        $script:TmBordePreview = $bordeIcono

        # Posiciones tipo Armeria (escala ~0.9)
        $tmPosSlot = @(
            @(8,10), @(8,58), @(8,106), @(8,154), @(8,202), @(8,250), @(8,298), @(8,346),
            @(360,10), @(360,58), @(360,106), @(360,154), @(360,202), @(360,250), @(360,298),
            @(130,346), @(210,346), @(290,346), @(360,346)
        )
        if ($Global:ArmeriaSlotNombre -and $Global:ArmeriaSlotNombre.Count -ge 19) {
            $tmSlotNom = @($Global:ArmeriaSlotNombre)
        } else {
            $tmSlotNom = @("Cabeza","Cuello","Hombros","Camisa","Pecho","Cintura","Piernas","Pies","Munecas","Manos","Anillo 1","Anillo 2","Abalorio 1","Abalorio 2","Espalda","Mano principal","Mano secundaria","A distancia","Tabardo")
        }
        $SZ = 42
        $slotMap = @{}
        $tipSlots = New-Object System.Windows.Forms.ToolTip
        $tipSlots.InitialDelay = 300
        for ($s = 0; $s -le 18; $s++) {
            $px = $tmPosSlot[$s][0]
            $py = $tmPosSlot[$s][1]
            $borde = New-Object System.Windows.Forms.Panel
            $borde.Location = New-Object System.Drawing.Point($px, $py)
            $borde.Size = New-Object System.Drawing.Size($SZ, $SZ)
            $borde.BackColor = [System.Drawing.Color]::FromArgb(45, 40, 35)
            $borde.Padding = New-Object System.Windows.Forms.Padding(2)
            $pb = New-Object System.Windows.Forms.PictureBox
            $pb.Dock = "Fill"
            $pb.SizeMode = "StretchImage"
            $pb.BackColor = [System.Drawing.Color]::FromArgb(20, 15, 12)
            $pb.Cursor = [System.Windows.Forms.Cursors]::Hand
            [void]$borde.Controls.Add($pb)
            $nomSlot = $tmSlotNom[$s]
            $tipSlots.SetToolTip($borde, $nomSlot)
            $tipSlots.SetToolTip($pb, $nomSlot)
            $borde.Tag = $null
            $pb.Tag = $null
            [void]$panelDoll.Controls.Add($borde)
            $slotMap[$s] = @{ Borde = $borde; Pb = $pb; Nombre = $nomSlot }
        }
        $script:TmSlotMap = $slotMap
        $script:TmTipSlots = $tipSlots

        # --- Comprobar tabla ---
        $tieneTabla = $false
        try { $tieneTabla = [bool](Transmog-TablaExiste "custom_unlocked_appearances" $bdChar) } catch {}
        if (-not $tieneTabla) {
            $lblInfo.Text = (T-Tm "MsgTablaTransmogNoExiste" "No existe custom_unlocked_appearances. Importa el SQL del mod-transmog en acore_characters.")
            [void]$tmForm.ShowDialog()
            $tmForm.Dispose()
            return
        }

        # --- Cuenta ---
        $accountId = 0
        try {
            $rAcc = @(Transmog-Consulta "SELECT account FROM characters WHERE guid=$guidNum LIMIT 1;" $bdChar)
            if ($rAcc.Count -gt 0 -and $rAcc[0]) { $accountId = [int](("$($rAcc[0])").Trim()) }
        } catch {}
        if ($accountId -le 0) {
            $lblInfo.Text = (T-Tm "MsgSinCuentaTransmog" "No se pudo obtener la cuenta del personaje.")
            [void]$tmForm.ShowDialog()
            $tmForm.Dispose()
            return
        }

        # --- Items aprendidos (1 sola query, una linea) ---
        $sqlItems = "SELECT ua.item_template_id, IFNULL(it.name,'(desconocido)'), IFNULL(it.Quality,0), IFNULL(it.ItemLevel,0), IFNULL(it.class,0) FROM custom_unlocked_appearances ua LEFT JOIN ${bdWorld}.item_template it ON it.entry=ua.item_template_id WHERE ua.account_id=$accountId ORDER BY it.class ASC, it.Quality DESC, it.name ASC;"

        $items = @()
        try {
            $raw = @(Transmog-Consulta $sqlItems $bdChar)
            foreach ($ln in $raw) {
                if (-not $ln) { continue }
                $p = ("$ln") -split "`t"
                if ($p.Count -lt 1) { continue }
                $entry = 0
                try { $entry = [int]($p[0].Trim()) } catch { continue }
                if ($entry -le 0) { continue }
                $nom = "#$entry"
                if ($p.Count -ge 2 -and $p[1]) { $nom = $p[1].Trim() }
                $qual = 0; if ($p.Count -ge 3) { try { $qual = [int]($p[2].Trim()) } catch {} }
                $ilvl = 0; if ($p.Count -ge 4) { try { $ilvl = [int]($p[3].Trim()) } catch {} }
                $cls  = 0; if ($p.Count -ge 5) { try { $cls  = [int]($p[4].Trim()) } catch {} }
                $items += [PSCustomObject]@{ Entry=$entry; Nombre=$nom; Quality=$qual; ItemLevel=$ilvl; Class=$cls }
            }
        } catch {
            $lblInfo.Text = "Error SQL: $($_.Exception.Message)"
        }

        # --- Transmogs activos de ESTE personaje (paperdoll por slot) ---
        $activosTxt = (T-Tm "MsgSinActivosTransmog" "Ningun transmog activo en {0}.") -f $nombreChar
        $nAct = 0
        try {
            if (Transmog-TablaExiste "custom_transmogrification" $bdChar) {
                # Solo items equipados (bag=0, slot 0-18) con transmog
                $sqlAct = "SELECT ci.slot, ct.FakeEntry, IFNULL(it.name, CONCAT('#',ct.FakeEntry)), IFNULL(it.Quality,0), IFNULL(it.ItemLevel,0), ct.GUID, IFNULL(ii.itemEntry,0) FROM custom_transmogrification ct INNER JOIN character_inventory ci ON ci.item=ct.GUID AND ci.guid=ct.Owner AND ci.bag=0 AND ci.slot BETWEEN 0 AND 18 LEFT JOIN item_instance ii ON ii.guid=ct.GUID LEFT JOIN ${bdWorld}.item_template it ON it.entry=ct.FakeEntry WHERE ct.Owner=$guidNum;"
                $actRaw = @(Transmog-Consulta $sqlAct $bdChar)
                foreach ($ln in $actRaw) {
                    if (-not $ln) { continue }
                    $p = ("$ln") -split "`t"
                    if ($p.Count -lt 2) { continue }
                    $slot = -1
                    try { $slot = [int]($p[0].Trim()) } catch { continue }
                    if ($slot -lt 0 -or $slot -gt 18) { continue }
                    if (-not $script:TmSlotMap.ContainsKey($slot)) { continue }
                    $fe = 0
                    try { $fe = [int]($p[1].Trim()) } catch { continue }
                    if ($fe -le 0) { continue }
                    $nom = "#$fe"
                    if ($p.Count -ge 3 -and $p[2]) { $nom = $p[2].Trim() }
                    $q = 0; if ($p.Count -ge 4) { try { $q = [int]($p[3].Trim()) } catch {} }
                    $il = 0; if ($p.Count -ge 5) { try { $il = [int]($p[4].Trim()) } catch {} }
                    $ig = ""; if ($p.Count -ge 6 -and $p[5]) { $ig = $p[5].Trim() }
                    $realEntry = 0; if ($p.Count -ge 7) { try { $realEntry = [int]($p[6].Trim()) } catch {} }

                    $cell = $script:TmSlotMap[$slot]
                    $cell.Borde.BackColor = Transmog-ColorRareza $q
                    $img = $null
                    try {
                        if (Get-Command Descargar-IconoArmeria -ErrorAction SilentlyContinue) {
                            $img = Descargar-IconoArmeria $fe 40
                        }
                    } catch {}
                    if (-not $img -and $Global:RootDir) {
                        try {
                            $cf = Join-Path $Global:RootDir "Armeria\Imagenes\$fe.jpg"
                            if (Test-Path -LiteralPath $cf) {
                                $img0 = [System.Drawing.Image]::FromFile($cf)
                                $bmp = New-Object System.Drawing.Bitmap 40, 40
                                $g0 = [System.Drawing.Graphics]::FromImage($bmp)
                                $g0.DrawImage($img0, 0, 0, 40, 40)
                                $g0.Dispose(); $img0.Dispose()
                                $img = $bmp
                            }
                        } catch {}
                    }
                    if ($img) { $cell.Pb.Image = $img }

                    $tip = "$($cell.Nombre)`n$nom`nEntry apariencia: $fe"
                    if ($realEntry -gt 0) { $tip += "`nItem real: $realEntry" }
                    $tip += "`n$(Transmog-NombreRareza $q)  |  iLvl $il`n(Clic = ficha)"
                    try {
                        $script:TmTipSlots.SetToolTip($cell.Borde, $tip)
                        $script:TmTipSlots.SetToolTip($cell.Pb, $tip)
                    } catch {}
                    $cell.Pb.Tag = $fe
                    $cell.Borde.Tag = $fe
                    $nAct++

                    # Clic en slot -> ficha
                    $handler = {
                        $feClick = 0
                        try { $feClick = [int]$this.Tag } catch {}
                        if ($feClick -gt 0) {
                            try { Mostrar-DetalleItemTransmog $feClick $null $null } catch {}
                        }
                    }.GetNewClosure()
                    $cell.Pb.Add_Click($handler)
                    $cell.Borde.Add_Click($handler)
                }
                if ($nAct -gt 0) {
                    $activosTxt = ((T-Tm "MsgActivosTransmog" "Activos en {0}: {1}  |  Clic en slot = ficha") -f $nombreChar, $nAct)
                } else {
                    $activosTxt = ((T-Tm "MsgSinActivosTransmog" "Ningun transmog activo en {0} (equipados).") -f $nombreChar)
                }
            } else {
                $activosTxt = (T-Tm "MsgTablaActivosNoExiste" "Tabla custom_transmogrification no encontrada.")
            }
        } catch {
            $activosTxt = "Error paperdoll: $($_.Exception.Message)"
        }
        $lblActivos.Text = $activosTxt

        $script:TmItems = $items
        $script:TmAcc = $accountId
        $script:TmLv = $lv
        $script:TmLbl = $lblInfo
        $script:TmTxt = $txtFiltro

        Transmog-RellenarLista $lv $lblInfo $items "" $accountId

        $btnFiltrar.Add_Click({
            try {
                Transmog-RellenarLista $script:TmLv $script:TmLbl $script:TmItems $script:TmTxt.Text $script:TmAcc
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Error filtro: $($_.Exception.Message)", "Transmog", "OK", "Error")
            }
        })
        $txtFiltro.Add_KeyDown({
            if ($_.KeyCode -eq "Enter") {
                try { Transmog-RellenarLista $script:TmLv $script:TmLbl $script:TmItems $script:TmTxt.Text $script:TmAcc } catch {}
                $_.SuppressKeyPress = $true
            }
        })

        # Doble clic / Enter en coleccion de cuenta
        $abrirDetalle = {
            param($listRef)
            try {
                if (-not $listRef -or $listRef.SelectedItems.Count -lt 1) { return }
                $sel = $listRef.SelectedItems[0]
                $ent = 0
                if ($sel.Tag) { try { $ent = [int]$sel.Tag } catch {} }
                if ($ent -le 0 -and $sel.SubItems.Count -gt 1) {
                    try { $ent = [int]$sel.SubItems[1].Text } catch {}
                }
                if ($ent -gt 0) { Mostrar-DetalleItemTransmog $ent $sel.Text $null }
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Error al abrir detalle:`n$($_.Exception.Message)", "Transmog", "OK", "Error")
            }
        }

        $lv.Add_DoubleClick({ & $abrirDetalle $script:TmLv })
        $lv.Add_KeyDown({
            if ($_.KeyCode -eq "Enter") { & $abrirDetalle $script:TmLv; $_.SuppressKeyPress = $true }
        })

        # Un clic: vista previa a la derecha (icono grande + datos)
        $lv.Add_SelectedIndexChanged({
            try {
                if (-not $script:TmLv -or $script:TmLv.SelectedItems.Count -lt 1) { return }
                $sel = $script:TmLv.SelectedItems[0]
                $ent = 0
                if ($sel.Tag) { try { $ent = [int]$sel.Tag } catch {} }
                if ($ent -le 0 -and $sel.SubItems.Count -gt 1) {
                    try { $ent = [int]$sel.SubItems[1].Text } catch {}
                }
                if ($ent -gt 0) {
                    Transmog-ActualizarVistaPrevia $ent $sel.Text $script:TmPbPreview $script:TmLblPrevNombre $script:TmLblPrevMeta $script:TmLblPrevStats $script:TmBordePreview
                }
            } catch {}
        })

        if ($lblInfo.Text -notmatch "Clic") {
            $lblInfo.Text = ($lblInfo.Text + "  |  Clic = vista previa  |  Doble clic = ficha")
        }

        [void]$tmForm.ShowDialog()
        $tmForm.Dispose()
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Error al abrir Transmog:`n$($_.Exception.Message)",
            "Transmog", "OK", "Error")
    }
}
