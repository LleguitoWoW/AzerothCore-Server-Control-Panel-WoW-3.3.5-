function Abrir-PanelReino {
    param($ParentForm)

    $bdAuth = if ($Global:AuthDbName) { $Global:AuthDbName } else { "acore_auth" }

    $mf = New-Object System.Windows.Forms.Form
    $mf.Text = Obtener-Texto "TituloReino" "Reino"
    $mf.Size = New-Object System.Drawing.Size(380, 400)
    $mf.StartPosition = 'CenterParent'
    $mf.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 26)
    $mf.ForeColor = [System.Drawing.Color]::White
    $mf.FormBorderStyle = 'FixedDialog'
    $mf.MaximizeBox = $false
    $mf.MinimizeBox = $false

    $lblTitulo = New-Object System.Windows.Forms.Label
    $lblTitulo.Text = Obtener-Texto "LblReinoDatos" "Datos del reino (acore_auth.realmlist)"
    $lblTitulo.Location = New-Object System.Drawing.Point(20, 15)
    $lblTitulo.Size = New-Object System.Drawing.Size(330, 20)
    $lblTitulo.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 190)
    $mf.Controls.Add($lblTitulo)

    $lblId = New-Object System.Windows.Forms.Label
    $lblId.Text = Obtener-Texto "LblReinoCargando" "Cargando..."
    $lblId.Location = New-Object System.Drawing.Point(20, 40)
    $lblId.Size = New-Object System.Drawing.Size(330, 18)
    $lblId.ForeColor = [System.Drawing.Color]::FromArgb(140, 140, 150)
    $lblId.Font = New-Object System.Drawing.Font("Georgia", 8, [System.Drawing.FontStyle]::Italic)
    $mf.Controls.Add($lblId)

    # --- Nombre del reino ---
    $lblNombre = New-Object System.Windows.Forms.Label
    $lblNombre.Text = Obtener-Texto "LblReinoNombre" "Nombre del reino:"
    $lblNombre.Location = New-Object System.Drawing.Point(20, 75)
    $lblNombre.Size = New-Object System.Drawing.Size(320, 18)
    $mf.Controls.Add($lblNombre)

    $txtNombre = New-Object System.Windows.Forms.TextBox
    $txtNombre.Location = New-Object System.Drawing.Point(20, 96)
    $txtNombre.Size = New-Object System.Drawing.Size(330, 24)
    $txtNombre.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 40)
    $txtNombre.ForeColor = [System.Drawing.Color]::White
    $txtNombre.BorderStyle = 'FixedSingle'
    $mf.Controls.Add($txtNombre)

    # --- Direccion IP ---
    $lblAddr = New-Object System.Windows.Forms.Label
    $lblAddr.Text = Obtener-Texto "LblReinoAddr" "Direccion IP (address):"
    $lblAddr.Location = New-Object System.Drawing.Point(20, 132)
    $lblAddr.Size = New-Object System.Drawing.Size(320, 18)
    $mf.Controls.Add($lblAddr)

    $txtAddr = New-Object System.Windows.Forms.TextBox
    $txtAddr.Location = New-Object System.Drawing.Point(20, 153)
    $txtAddr.Size = New-Object System.Drawing.Size(330, 24)
    $txtAddr.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 40)
    $txtAddr.ForeColor = [System.Drawing.Color]::White
    $txtAddr.BorderStyle = 'FixedSingle'
    $mf.Controls.Add($txtAddr)

    # --- Puerto ---
    $lblPuerto = New-Object System.Windows.Forms.Label
    $lblPuerto.Text = Obtener-Texto "LblReinoPuerto" "Puerto:"
    $lblPuerto.Location = New-Object System.Drawing.Point(20, 189)
    $lblPuerto.Size = New-Object System.Drawing.Size(150, 18)
    $mf.Controls.Add($lblPuerto)

    $txtPuerto = New-Object System.Windows.Forms.TextBox
    $txtPuerto.Location = New-Object System.Drawing.Point(20, 210)
    $txtPuerto.Size = New-Object System.Drawing.Size(150, 24)
    $txtPuerto.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 40)
    $txtPuerto.ForeColor = [System.Drawing.Color]::White
    $txtPuerto.BorderStyle = 'FixedSingle'
    $mf.Controls.Add($txtPuerto)

    # --- Icono del reino ---
    $lblIcono = New-Object System.Windows.Forms.Label
    $lblIcono.Text = Obtener-Texto "LblReinoIcono" "Icono del reino:"
    $lblIcono.Location = New-Object System.Drawing.Point(200, 189)
    $lblIcono.Size = New-Object System.Drawing.Size(150, 18)
    $mf.Controls.Add($lblIcono)

    # Valores reales que acepta la columna `icon` de realmlist, con su texto traducido
    $script:ReinoIconMap = @(
        [PSCustomObject]@{ Valor = 0; Texto = (Obtener-Texto "IconoReino0" "Normal") }
        [PSCustomObject]@{ Valor = 1; Texto = (Obtener-Texto "IconoReino1" "JcJ") }
        [PSCustomObject]@{ Valor = 4; Texto = (Obtener-Texto "IconoReino4" "Normal") }
        [PSCustomObject]@{ Valor = 6; Texto = (Obtener-Texto "IconoReino6" "JdR") }
        [PSCustomObject]@{ Valor = 8; Texto = (Obtener-Texto "IconoReino8" "JdR JcJ") }
    )

    $cmbIcono = New-Object System.Windows.Forms.ComboBox
    $cmbIcono.Location = New-Object System.Drawing.Point(200, 210)
    $cmbIcono.Size = New-Object System.Drawing.Size(150, 24)
    $cmbIcono.DropDownStyle = 'DropDownList'
    $cmbIcono.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 40)
    $cmbIcono.ForeColor = [System.Drawing.Color]::White
    foreach ($opt in $script:ReinoIconMap) {
        [void]$cmbIcono.Items.Add("$($opt.Valor) - $($opt.Texto)")
    }
    $cmbIcono.SelectedIndex = 0
    $mf.Controls.Add($cmbIcono)

    $lblInfo = New-Object System.Windows.Forms.Label
    $lblInfo.Text = Obtener-Texto "LblReinoInfo" "Usa la IP publica/DNS para jugar por internet, o 127.0.0.1 para solo este PC."
    $lblInfo.Location = New-Object System.Drawing.Point(20, 246)
    $lblInfo.Size = New-Object System.Drawing.Size(330, 30)
    $lblInfo.ForeColor = [System.Drawing.Color]::FromArgb(140, 140, 150)
    $lblInfo.Font = New-Object System.Drawing.Font("Georgia", 8)
    $mf.Controls.Add($lblInfo)

    $script:ReinoIdActual = $null

    Function Cargar-DatosReino {
        $lblId.Text = Obtener-Texto "LblReinoCargando" "Cargando..."
        $sql = "SELECT id, name, address, port, icon FROM ``$bdAuth``.realmlist ORDER BY id ASC LIMIT 1;"
        $filas = @(Consulta-PanelMysql $sql $bdAuth)
        if ($filas.Count -eq 0) {
            $lblId.Text = Obtener-Texto "LblReinoErrorCarga" "No se pudo leer el reino (revisa MySQL / credenciales)."
            $txtNombre.Enabled = $false
            $txtAddr.Enabled = $false
            $txtPuerto.Enabled = $false
            $cmbIcono.Enabled = $false
            return
        }
        $p = ("$($filas[0])") -split "`t"
        $script:ReinoIdActual = $p[0].Trim()
        $txtNombre.Text = if ($p.Count -ge 2) { $p[1] } else { "" }
        $txtAddr.Text = if ($p.Count -ge 3) { $p[2] } else { "" }
        $txtPuerto.Text = if ($p.Count -ge 4) { $p[3].Trim() } else { "8085" }

        $iconoActual = 0
        if ($p.Count -ge 5) { try { $iconoActual = [int]($p[4].Trim()) } catch { $iconoActual = 0 } }
        $idxSeleccion = 0
        for ($i = 0; $i -lt $script:ReinoIconMap.Count; $i++) {
            if ($script:ReinoIconMap[$i].Valor -eq $iconoActual) { $idxSeleccion = $i }
        }
        $cmbIcono.SelectedIndex = $idxSeleccion

        $plantillaId = Obtener-Texto "LblReinoId" "Reino id: {0}"
        $lblId.Text = $plantillaId -f $script:ReinoIdActual
    }

    $btnGuardar = New-Object System.Windows.Forms.Button
    $btnGuardar.Text = Obtener-Texto "BtnGuardar" "Guardar"
    $btnGuardar.Location = New-Object System.Drawing.Point(20, 300)
    $btnGuardar.Size = New-Object System.Drawing.Size(155, 36)
    $btnGuardar.BackColor = [System.Drawing.Color]::FromArgb(46, 125, 70)
    $btnGuardar.ForeColor = [System.Drawing.Color]::White
    $btnGuardar.FlatStyle = 'Flat'
    $btnGuardar.Add_Click({
        $tituloReino = Obtener-Texto "TituloReino" "Reino"
        if (-not $script:ReinoIdActual) {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgReinoNoCargado" "No se ha cargado el reino todavia."), $tituloReino, 'OK', 'Warning')
            return
        }
        $nombreNuevo = $txtNombre.Text.Trim()
        $addrNueva = $txtAddr.Text.Trim()
        $puertoNuevo = $txtPuerto.Text.Trim()
        if (-not $nombreNuevo -or -not $addrNueva -or -not $puertoNuevo) {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgReinoVacio" "El nombre y la direccion IP no pueden estar vacios."), $tituloReino, 'OK', 'Warning')
            return
        }
        $puertoInt = 0
        if (-not [int]::TryParse($puertoNuevo, [ref]$puertoInt)) {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgReinoPuertoInvalido" "El puerto debe ser un numero (por ejemplo 8085)."), $tituloReino, 'OK', 'Warning')
            return
        }
        $iconoValor = $script:ReinoIconMap[$cmbIcono.SelectedIndex].Valor

        # Escapado basico de comillas simples para no romper el SQL
        $nombreEsc = $nombreNuevo.Replace("'", "''")
        $addrEsc = $addrNueva.Replace("'", "''")
        $idEsc = $script:ReinoIdActual.Replace("'", "''")

        $sqlUpdate = "UPDATE ``$bdAuth``.realmlist SET name='$nombreEsc', address='$addrEsc', port=$puertoInt, icon=$iconoValor WHERE id='$idEsc';"
        [void](Consulta-PanelMysql $sqlUpdate $bdAuth)

        [System.Windows.Forms.MessageBox]::Show(
            (Obtener-Texto "MsgReinoActualizado" "Reino actualizado.`n`nSi tienes el AuthServer o el WorldServer arrancados, puede que necesites reiniciarlos (o esperar al refresco de cache) para que los jugadores vean el cambio en la lista de reinos."),
            $tituloReino, 'OK', 'Information')
        Cargar-DatosReino
    })
    $mf.Controls.Add($btnGuardar)

    $btnCerrar = New-Object System.Windows.Forms.Button
    $btnCerrar.Text = Obtener-Texto "BtnReinoCerrar" "Cerrar"
    $btnCerrar.Location = New-Object System.Drawing.Point(195, 300)
    $btnCerrar.Size = New-Object System.Drawing.Size(155, 36)
    $btnCerrar.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 78)
    $btnCerrar.ForeColor = [System.Drawing.Color]::White
    $btnCerrar.FlatStyle = 'Flat'
    $btnCerrar.Add_Click({ $mf.Close() })
    $mf.Controls.Add($btnCerrar)

    Cargar-DatosReino

    [void]$mf.ShowDialog($ParentForm)
}
