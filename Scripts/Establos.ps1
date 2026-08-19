# ==========================================
# MODULO: ESTABLOS (monturas + mascotas de compania)
# ==========================================
# En 3.3.5 las monturas y companion pets se aprenden como hechizos
# (character_spell) y suelen estar ligados a item_template:
#   class = 15 (Miscellaneous)
#   subclass = 5  -> Montura
#   subclass = 2  -> Mascota de compania (loro, serpiente, etc.)
# NO incluye mascotas de cazador (character_pet).

Function global:T-Est([string]$clave, [string]$defecto) {
    try {
        if (Get-Command Obtener-Texto -ErrorAction SilentlyContinue) {
            $t = Obtener-Texto $clave $defecto
            if ($t) { return $t }
        }
    } catch {}
    return $defecto
}

Function global:Establos-Consulta([string]$sql, [string]$bd) {
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

Function global:Establos-ColorRareza($q) {
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

Function global:Establos-NombreRareza($q) {
    $qi = 0
    try { $qi = [int]$q } catch { $qi = 0 }
    $def = "Q$qi"
    if ($Global:ArmeriaNombreCalidad -and $Global:ArmeriaNombreCalidad.ContainsKey($qi)) {
        return [string]$Global:ArmeriaNombreCalidad[$qi]
    }
    switch ($qi) {
        0 { return (T-Est "TmRareza0" "Pobre") }
        1 { return (T-Est "TmRareza1" "Comun") }
        2 { return (T-Est "TmRareza2" "Poco comun") }
        3 { return (T-Est "TmRareza3" "Raro") }
        4 { return (T-Est "TmRareza4" "Epico") }
        5 { return (T-Est "TmRareza5" "Legendario") }
        6 { return (T-Est "TmRareza6" "Artefacto") }
        7 { return (T-Est "TmRareza7" "Heirloom") }
        default { return $def }
    }
}

Function global:Establos-CargarColeccion {
    param($guidChar)

    $guidNum = 0
    try { $guidNum = [int]$guidChar } catch { $guidNum = 0 }
    $resultado = @{ Monturas = @(); Mascotas = @(); Error = $null; Debug = "" }
    if ($guidNum -le 0) {
        $resultado.Error = (T-Est "MsgGuidInvalido" "GUID de personaje no valido.")
        return $resultado
    }

    $bdChar  = "acore_characters"
    $bdWorld = "acore_world"

    # 1) Hechizos del personaje (sin filtrar disabled: no todas las BD tienen esa columna)
    $spellSet = @{}
    try {
        $rawSp = @(Establos-Consulta "SELECT spell FROM character_spell WHERE guid=$guidNum;" $bdChar)
        foreach ($ln in $rawSp) {
            if (-not $ln) { continue }
            $sid = 0
            try { $sid = [int](("$ln").Trim().Split("`t")[0]) } catch { continue }
            if ($sid -gt 0) { $spellSet[$sid] = $true }
        }
    } catch {
        $resultado.Error = "character_spell: $($_.Exception.Message)"
        return $resultado
    }
    $resultado.Debug = "spells=$($spellSet.Count)"

    if ($spellSet.Count -eq 0) {
        $resultado.Error = $null
        return $resultado
    }

    # 2) Catalogo de monturas/mascotas desde item_template (class 15: Misc)
    #    subclass 5 = montura, 2 = mascota de compania
    #    El hechizo aprendido puede estar en spellid_1..5 (a menudo trigger=6 Learn)
    $sqlItems = "SELECT entry, IFNULL(name,''), IFNULL(Quality,0), IFNULL(ItemLevel,0), IFNULL(subclass,0), IFNULL(spellid_1,0), IFNULL(spellid_2,0), IFNULL(spellid_3,0), IFNULL(spellid_4,0), IFNULL(spellid_5,0) FROM item_template WHERE class=15 AND subclass IN (2,5);"
    $rawItems = @()
    try {
        $rawItems = @(Establos-Consulta $sqlItems $bdWorld)
    } catch {
        $resultado.Error = "item_template: $($_.Exception.Message)"
        return $resultado
    }
    $resultado.Debug += " items15=$($rawItems.Count)"

    $vistos = @{}
    foreach ($ln in $rawItems) {
        if (-not $ln) { continue }
        $p = ("$ln") -split "`t"
        if ($p.Count -lt 6) { continue }
        $entry = 0
        try { $entry = [int]($p[0].Trim()) } catch { continue }
        if ($entry -le 0 -or $vistos.ContainsKey($entry)) { continue }

        $spellsItem = @()
        for ($i = 5; $i -le 9 -and $i -lt $p.Count; $i++) {
            $s = 0
            try { $s = [int]($p[$i].Trim()) } catch { $s = 0 }
            if ($s -gt 0) { $spellsItem += $s }
        }
        $match = $false
        $matchedSpell = 0
        foreach ($s in $spellsItem) {
            if ($spellSet.ContainsKey($s)) { $match = $true; $matchedSpell = $s; break }
        }
        if (-not $match) { continue }

        $vistos[$entry] = $true
        $nom = "#$entry"
        if ($p.Count -ge 2 -and $p[1]) { $nom = $p[1].Trim() }
        $qual = 0; if ($p.Count -ge 3) { try { $qual = [int]($p[2].Trim()) } catch {} }
        $ilvl = 0; if ($p.Count -ge 4) { try { $ilvl = [int]($p[2].Trim()) } catch {} }
        $sub  = 0; if ($p.Count -ge 5) { try { $sub  = [int]($p[4].Trim()) } catch {} }

        $obj = [PSCustomObject]@{
            Entry     = $entry
            Nombre    = $nom
            Quality   = $qual
            ItemLevel = $ilvl
            Subclass  = $sub
            SpellId   = $matchedSpell
        }
        if ($sub -eq 5) {
            $resultado.Monturas += $obj
        } else {
            $resultado.Mascotas += $obj
        }
    }

    # Ordenar por rareza/nombre
    try {
        $resultado.Monturas = @($resultado.Monturas | Sort-Object -Property @{Expression='Quality';Descending=$true}, Nombre)
        $resultado.Mascotas = @($resultado.Mascotas | Sort-Object -Property @{Expression='Quality';Descending=$true}, Nombre)
    } catch {}

    $resultado.Debug += " mont=$($resultado.Monturas.Count) pet=$($resultado.Mascotas.Count)"
    return $resultado
}

Function global:Establos-FiltrarItems {
    param($items, $filtroTexto)
    $lista = @()
    if ($null -ne $items) { $lista = @($items) }
    if ($filtroTexto -and ([string]$filtroTexto).Trim().Length -gt 0) {
        $f = ([string]$filtroTexto).Trim().ToLower()
        $tmp = @()
        foreach ($x in $lista) {
            $n = ""; $e = ""
            try { $n = ([string]$x.Nombre).ToLower() } catch {}
            try { $e = [string]$x.Entry } catch {}
            if (($n -and $n.Contains($f)) -or ($e -eq $f)) { $tmp += $x }
        }
        return $tmp
    }
    return $lista
}

Function global:Establos-ActualizarVistaPrevia {
    param($entry, $nombreHint)

    try {
        $e = 0
        try { $e = [int]$entry } catch { $e = 0 }
        if ($e -le 0) { return }

        $nombre = if ($nombreHint) { [string]$nombreHint } else { "#$e" }
        $quality = 0
        $ilvl = 0
        try {
            $sql = "SELECT IFNULL(name,''), IFNULL(Quality,0), IFNULL(ItemLevel,0) FROM item_template WHERE entry=$e LIMIT 1;"
            $raw = @(Establos-Consulta $sql "acore_world")
            if ($raw.Count -gt 0 -and $raw[0]) {
                $p = ("$($raw[0])") -split "`t"
                if ($p.Count -ge 1 -and $p[0]) { $nombre = $p[0].Trim() }
                if ($p.Count -ge 2) { try { $quality = [int]($p[1].Trim()) } catch {} }
                if ($p.Count -ge 3) { try { $ilvl = [int]($p[2].Trim()) } catch {} }
            }
        } catch {}

        $color = Establos-ColorRareza $quality
        if ($script:EstBordePreview) { $script:EstBordePreview.BackColor = $color }
        if ($script:EstLblPrevNombre) {
            $script:EstLblPrevNombre.Text = $nombre
            $script:EstLblPrevNombre.ForeColor = $color
        }
        $meta = "Entry $e"
        if ($ilvl -gt 0) { $meta += "  |  iLvl $ilvl" }
        $meta += "  |  $(Establos-NombreRareza $quality)"
        if ($script:EstLblPrevMeta) { $script:EstLblPrevMeta.Text = $meta }

        $stats = ""
        try {
            if (Get-Command Obtener-TooltipItem -ErrorAction SilentlyContinue) {
                $stats = [string](Obtener-TooltipItem $e $null $null)
            }
        } catch {}
        if ($script:EstLblPrevStats) {
            if ($stats -and $stats.Trim().Length -gt 0) {
                $script:EstLblPrevStats.Text = $stats
            } else {
                $script:EstLblPrevStats.Text = (T-Est "TmPreviewHint" "Clic = captura Wowhead. Doble clic = ficha.")
            }
        }

        $img = $null
        # Preferir captura Wowhead (misma funcion que Transmog)
        try {
            if (Get-Command Transmog-ObtenerScreenshotWowhead -ErrorAction SilentlyContinue) {
                $img = Transmog-ObtenerScreenshotWowhead $e
            }
        } catch { $img = $null }

        if (-not $img) {
            try {
                if (Get-Command Descargar-IconoArmeria -ErrorAction SilentlyContinue) {
                    $img = Descargar-IconoArmeria $e 128
                }
            } catch {}
        }
        if (-not $img -and $Global:RootDir) {
            try {
                $cf = Join-Path $Global:RootDir "Armeria\Imagenes\$e.jpg"
                if (Test-Path -LiteralPath $cf) {
                    $img0 = [System.Drawing.Image]::FromFile($cf)
                    $img = New-Object System.Drawing.Bitmap $img0
                    $img0.Dispose()
                }
            } catch {}
        }
        if ($script:EstPbPreview) {
            $script:EstPbPreview.Image = $img
            $script:EstPbPreview.SizeMode = "Zoom"
        }
    } catch {}
}

Function global:Establos-RellenarIconos {
    param($panel, $items, $filtroTexto, $tooltip)

    if (-not $panel) { return }
    try {
        $panel.SuspendLayout()
        $panel.Controls.Clear()
        $lista = Establos-FiltrarItems $items $filtroTexto
        $ICON = 48
        $PAD  = 2
        foreach ($it in $lista) {
            $entry = 0
            try { $entry = [int]$it.Entry } catch { continue }
            if ($entry -le 0) { continue }

            $borde = New-Object System.Windows.Forms.Panel
            $borde.Size = New-Object System.Drawing.Size(($ICON + 4), ($ICON + 4))
            $borde.Margin = New-Object System.Windows.Forms.Padding(4)
            $borde.BackColor = Establos-ColorRareza $it.Quality
            $borde.Padding = New-Object System.Windows.Forms.Padding($PAD)
            $borde.Cursor = [System.Windows.Forms.Cursors]::Hand

            $pb = New-Object System.Windows.Forms.PictureBox
            $pb.Dock = "Fill"
            $pb.SizeMode = "StretchImage"
            $pb.BackColor = [System.Drawing.Color]::FromArgb(20, 15, 12)
            $pb.Cursor = [System.Windows.Forms.Cursors]::Hand

            $img = $null
            try {
                if (Get-Command Descargar-IconoArmeria -ErrorAction SilentlyContinue) {
                    $img = Descargar-IconoArmeria $entry $ICON
                }
            } catch {}
            if (-not $img -and $Global:RootDir) {
                try {
                    $cf = Join-Path $Global:RootDir "Armeria\Imagenes\$entry.jpg"
                    if (Test-Path -LiteralPath $cf) {
                        $img0 = [System.Drawing.Image]::FromFile($cf)
                        $bmp = New-Object System.Drawing.Bitmap $ICON, $ICON
                        $g0 = [System.Drawing.Graphics]::FromImage($bmp)
                        $g0.DrawImage($img0, 0, 0, $ICON, $ICON)
                        $g0.Dispose(); $img0.Dispose()
                        $img = $bmp
                    }
                } catch {}
            }
            if ($img) { $pb.Image = $img }

            $nomItem = [string]$it.Nombre
            $tip = "$nomItem`n$(Establos-NombreRareza $it.Quality)"
            if ($it.ItemLevel) { $tip += "  |  iLvl $($it.ItemLevel)" }
            $tip += "`nEntry: $entry"
            if ($it.SpellId) { $tip += "`nSpell: $($it.SpellId)" }
            $tip += "`n" + (T-Est "TipClicEstablos" "Clic = captura  |  Doble clic = ficha")
            try {
                if ($tooltip) {
                    $tooltip.SetToolTip($borde, $tip)
                    $tooltip.SetToolTip($pb, $tip)
                }
            } catch {}

            $borde.Tag = $entry
            $pb.Tag = $entry

            $abrir = {
                $fe = 0
                try { $fe = [int]$this.Tag } catch {}
                if ($fe -le 0) { return }
                try {
                    if (Get-Command Mostrar-DetalleItemTransmog -ErrorAction SilentlyContinue) {
                        Mostrar-DetalleItemTransmog $fe $null $null
                    } elseif (Get-Command Obtener-TooltipItem -ErrorAction SilentlyContinue) {
                        $t = Obtener-TooltipItem $fe $null $null
                        [System.Windows.Forms.MessageBox]::Show("$t", "Item $fe", "OK", "Information")
                    }
                } catch {
                    [System.Windows.Forms.MessageBox]::Show("Error detalle:`n$($_.Exception.Message)", (T-Est "BtnEstablos" "Establos"), "OK", "Error")
                }
            }.GetNewClosure()

            $preview = {
                $fe = 0
                try { $fe = [int]$this.Tag } catch {}
                if ($fe -le 0) { return }
                try { Establos-ActualizarVistaPrevia $fe $null } catch {}
            }.GetNewClosure()

            $pb.Add_Click($preview)
            $borde.Add_Click($preview)
            $pb.Add_DoubleClick($abrir)
            $borde.Add_DoubleClick($abrir)

            [void]$borde.Controls.Add($pb)
            [void]$panel.Controls.Add($borde)
        }
    } catch {
    } finally {
        try { $panel.ResumeLayout($true) } catch {}
    }
}

Function global:Mostrar-VentanaEstablos {
    param($guidChar, $nombreChar, $formPadre)

    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
        Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue

        $guidNum = 0
        try { $guidNum = [int]$guidChar } catch { $guidNum = 0 }
        if ($guidNum -le 0) {
            [System.Windows.Forms.MessageBox]::Show((T-Est "MsgGuidInvalido" "GUID de personaje no valido."), (T-Est "BtnEstablos" "Establos"), "OK", "Warning")
            return
        }

        $estForm = New-Object System.Windows.Forms.Form
        $estForm.Text = ((T-Est "TituloEstablos" "Establos - {0}") -f $nombreChar)
        $estForm.Size = New-Object System.Drawing.Size(980, 680)
        $estForm.StartPosition = "CenterParent"
        $estForm.BackColor = [System.Drawing.Color]::FromArgb(15, 12, 10)
        $estForm.ForeColor = [System.Drawing.Color]::White
        $estForm.MinimizeBox = $false

        $fTitle = New-Object System.Drawing.Font("Georgia", 12, [System.Drawing.FontStyle]::Bold)
        $fPeq   = New-Object System.Drawing.Font("Georgia", 8.5)
        $fBold  = New-Object System.Drawing.Font("Georgia", 9, [System.Drawing.FontStyle]::Bold)

        $lblTit = New-Object System.Windows.Forms.Label
        $lblTit.Text = ((T-Est "TituloColeccionEstablos" "Coleccion de monturas y mascotas - {0}") -f $nombreChar)
        $lblTit.Location = New-Object System.Drawing.Point(12, 8)
        $lblTit.Size = New-Object System.Drawing.Size(600, 22)
        $lblTit.Font = $fTitle
        $lblTit.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
        [void]$estForm.Controls.Add($lblTit)

        $lblAviso = New-Object System.Windows.Forms.Label
        $lblAviso.Text = (T-Est "AvisoEstablos" "Clic = captura del objeto (Wowhead). Doble clic = especificaciones.")
        $lblAviso.Location = New-Object System.Drawing.Point(12, 32)
        $lblAviso.Size = New-Object System.Drawing.Size(940, 20)
        $lblAviso.Font = $fPeq
        $lblAviso.ForeColor = [System.Drawing.Color]::FromArgb(255, 180, 80)
        [void]$estForm.Controls.Add($lblAviso)

        $lblInfo = New-Object System.Windows.Forms.Label
        $lblInfo.Text = (T-Est "LblCargandoEstablos" "Cargando establos...")
        $lblInfo.Location = New-Object System.Drawing.Point(12, 56)
        $lblInfo.Size = New-Object System.Drawing.Size(520, 18)
        $lblInfo.Font = $fPeq
        $lblInfo.ForeColor = [System.Drawing.Color]::FromArgb(180, 170, 150)
        [void]$estForm.Controls.Add($lblInfo)

        $txtFiltro = New-Object System.Windows.Forms.TextBox
        $txtFiltro.Location = New-Object System.Drawing.Point(560, 54)
        $txtFiltro.Size = New-Object System.Drawing.Size(200, 22)
        $txtFiltro.BackColor = [System.Drawing.Color]::FromArgb(30, 28, 24)
        $txtFiltro.ForeColor = [System.Drawing.Color]::White
        [void]$estForm.Controls.Add($txtFiltro)

        $btnFiltrar = New-Object System.Windows.Forms.Button
        $btnFiltrar.Text = (T-Est "LblFiltrar" "Filtrar")
        $btnFiltrar.Location = New-Object System.Drawing.Point(770, 52)
        $btnFiltrar.Size = New-Object System.Drawing.Size(80, 24)
        $btnFiltrar.FlatStyle = "Flat"
        $btnFiltrar.BackColor = [System.Drawing.Color]::FromArgb(50, 40, 20)
        $btnFiltrar.ForeColor = [System.Drawing.Color]::White
        [void]$estForm.Controls.Add($btnFiltrar)

        $tooltip = New-Object System.Windows.Forms.ToolTip
        $tooltip.AutoPopDelay = 12000
        $tooltip.InitialDelay = 250
        $tooltip.ReshowDelay = 100
        $tooltip.ShowAlways = $true

        # Monturas (izquierda)
        $lblMont = New-Object System.Windows.Forms.Label
        $lblMont.Text = (T-Est "LblMonturas" "Monturas")
        $lblMont.Location = New-Object System.Drawing.Point(12, 82)
        $lblMont.Size = New-Object System.Drawing.Size(280, 18)
        $lblMont.Font = $fBold
        $lblMont.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
        [void]$estForm.Controls.Add($lblMont)

        $panelMont = New-Object System.Windows.Forms.FlowLayoutPanel
        $panelMont.Location = New-Object System.Drawing.Point(12, 104)
        $panelMont.Size = New-Object System.Drawing.Size(280, 520)
        $panelMont.BackColor = [System.Drawing.Color]::FromArgb(22, 20, 18)
        $panelMont.AutoScroll = $true
        $panelMont.WrapContents = $true
        $panelMont.FlowDirection = "LeftToRight"
        $panelMont.Padding = New-Object System.Windows.Forms.Padding(4)
        [void]$estForm.Controls.Add($panelMont)

        # Mascotas (centro)
        $lblPet = New-Object System.Windows.Forms.Label
        $lblPet.Text = (T-Est "LblMascotasCompania" "Mascotas de compania")
        $lblPet.Location = New-Object System.Drawing.Point(300, 82)
        $lblPet.Size = New-Object System.Drawing.Size(280, 18)
        $lblPet.Font = $fBold
        $lblPet.ForeColor = [System.Drawing.Color]::FromArgb(160, 220, 120)
        [void]$estForm.Controls.Add($lblPet)

        $panelPet = New-Object System.Windows.Forms.FlowLayoutPanel
        $panelPet.Location = New-Object System.Drawing.Point(300, 104)
        $panelPet.Size = New-Object System.Drawing.Size(280, 520)
        $panelPet.BackColor = [System.Drawing.Color]::FromArgb(22, 20, 18)
        $panelPet.AutoScroll = $true
        $panelPet.WrapContents = $true
        $panelPet.FlowDirection = "LeftToRight"
        $panelPet.Padding = New-Object System.Windows.Forms.Padding(4)
        [void]$estForm.Controls.Add($panelPet)

        # Vista previa derecha (captura Wowhead)
        $lblPrevTit = New-Object System.Windows.Forms.Label
        $lblPrevTit.Text = (T-Est "TmPreviewTitulo" "Vista previa del objeto")
        $lblPrevTit.Location = New-Object System.Drawing.Point(592, 82)
        $lblPrevTit.Size = New-Object System.Drawing.Size(360, 18)
        $lblPrevTit.Font = $fBold
        $lblPrevTit.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
        [void]$estForm.Controls.Add($lblPrevTit)

        $panelPreview = New-Object System.Windows.Forms.Panel
        $panelPreview.Location = New-Object System.Drawing.Point(592, 104)
        $panelPreview.Size = New-Object System.Drawing.Size(360, 520)
        $panelPreview.BackColor = [System.Drawing.Color]::FromArgb(18, 16, 14)
        $panelPreview.BorderStyle = "FixedSingle"
        [void]$estForm.Controls.Add($panelPreview)

        $bordeIcono = New-Object System.Windows.Forms.Panel
        $bordeIcono.Location = New-Object System.Drawing.Point(20, 16)
        $bordeIcono.Size = New-Object System.Drawing.Size(318, 240)
        $bordeIcono.BackColor = [System.Drawing.Color]::FromArgb(60, 50, 40)
        $bordeIcono.Padding = New-Object System.Windows.Forms.Padding(4)
        [void]$panelPreview.Controls.Add($bordeIcono)

        $pbPreview = New-Object System.Windows.Forms.PictureBox
        $pbPreview.Dock = "Fill"
        $pbPreview.SizeMode = "Zoom"
        $pbPreview.BackColor = [System.Drawing.Color]::FromArgb(12, 10, 8)
        [void]$bordeIcono.Controls.Add($pbPreview)

        $lblPrevNombre = New-Object System.Windows.Forms.Label
        $lblPrevNombre.Location = New-Object System.Drawing.Point(10, 268)
        $lblPrevNombre.Size = New-Object System.Drawing.Size(338, 28)
        $lblPrevNombre.Font = New-Object System.Drawing.Font("Georgia", 11, [System.Drawing.FontStyle]::Bold)
        $lblPrevNombre.ForeColor = [System.Drawing.Color]::White
        $lblPrevNombre.TextAlign = "MiddleCenter"
        $lblPrevNombre.Text = (T-Est "TmPreviewVacio" "Selecciona un item de la lista")
        [void]$panelPreview.Controls.Add($lblPrevNombre)

        $lblPrevMeta = New-Object System.Windows.Forms.Label
        $lblPrevMeta.Location = New-Object System.Drawing.Point(10, 300)
        $lblPrevMeta.Size = New-Object System.Drawing.Size(338, 36)
        $lblPrevMeta.Font = $fPeq
        $lblPrevMeta.ForeColor = [System.Drawing.Color]::FromArgb(180, 170, 150)
        $lblPrevMeta.TextAlign = "MiddleCenter"
        $lblPrevMeta.Text = ""
        [void]$panelPreview.Controls.Add($lblPrevMeta)

        $lblPrevStats = New-Object System.Windows.Forms.Label
        $lblPrevStats.Location = New-Object System.Drawing.Point(10, 340)
        $lblPrevStats.Size = New-Object System.Drawing.Size(338, 165)
        $lblPrevStats.Font = New-Object System.Drawing.Font("Consolas", 8)
        $lblPrevStats.ForeColor = [System.Drawing.Color]::FromArgb(100, 220, 100)
        $lblPrevStats.Text = (T-Est "TipClicEstablos" "Clic en un icono = captura Wowhead.`nDoble clic = ficha completa.")
        [void]$panelPreview.Controls.Add($lblPrevStats)

        $script:EstPbPreview = $pbPreview
        $script:EstLblPrevNombre = $lblPrevNombre
        $script:EstLblPrevMeta = $lblPrevMeta
        $script:EstLblPrevStats = $lblPrevStats
        $script:EstBordePreview = $bordeIcono

        $datos = Establos-CargarColeccion $guidNum
        if ($datos.Error) {
            $lblInfo.Text = $datos.Error
        } else {
            $nM = @($datos.Monturas).Count
            $nP = @($datos.Mascotas).Count
            $lblInfo.Text = ((T-Est "LblResumenEstablos" "Monturas: {0}  |  Mascotas: {1}  |  Clic = captura  |  Doble clic = ficha") -f $nM, $nP)
            if ($nM -eq 0 -and $nP -eq 0 -and $datos.Debug) {
                $lblInfo.Text += "  [" + $datos.Debug + "]"
            }
            $lblMont.Text = ((T-Est "LblMonturasN" "Monturas ({0})") -f $nM)
            $lblPet.Text  = ((T-Est "LblMascotasN" "Mascotas de compania ({0})") -f $nP)
            Establos-RellenarIconos $panelMont $datos.Monturas "" $tooltip
            Establos-RellenarIconos $panelPet  $datos.Mascotas "" $tooltip
        }

        $script:EstMonturas = $datos.Monturas
        $script:EstMascotas = $datos.Mascotas
        $script:EstPanelMont = $panelMont
        $script:EstPanelPet = $panelPet
        $script:EstTxt = $txtFiltro
        $script:EstTip = $tooltip
        $script:EstLblMont = $lblMont
        $script:EstLblPet = $lblPet

        $aplicarFiltro = {
            try {
                $f = $script:EstTxt.Text
                Establos-RellenarIconos $script:EstPanelMont $script:EstMonturas $f $script:EstTip
                Establos-RellenarIconos $script:EstPanelPet  $script:EstMascotas $f $script:EstTip
                $nM = @(Establos-FiltrarItems $script:EstMonturas $f).Count
                $nP = @(Establos-FiltrarItems $script:EstMascotas $f).Count
                if ($script:EstLblMont) { $script:EstLblMont.Text = ((T-Est "LblMonturasN" "Monturas ({0})") -f $nM) }
                if ($script:EstLblPet)  { $script:EstLblPet.Text  = ((T-Est "LblMascotasN" "Mascotas de compania ({0})") -f $nP) }
            } catch {}
        }
        $btnFiltrar.Add_Click($aplicarFiltro)
        $txtFiltro.Add_KeyDown({
            if ($_.KeyCode -eq "Enter") {
                & $aplicarFiltro
                $_.SuppressKeyPress = $true
            }
        })

        [void]$estForm.ShowDialog()
        $estForm.Dispose()
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Error al abrir Establos:`n$($_.Exception.Message)",
            (T-Est "BtnEstablos" "Establos"), "OK", "Error")
    }
}
