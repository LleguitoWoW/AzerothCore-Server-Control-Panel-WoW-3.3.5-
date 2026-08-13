try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # $Global:RootDir = carpeta "Scripts" (donde vive este archivo)
    # $Global:AppRoot = carpeta raíz de la aplicación (un nivel arriba de Scripts)
    # $Global:ImgDir  = carpeta "Imagenes" dentro de la raíz
    $Global:RootDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $Global:AppRoot = Split-Path -Parent $Global:RootDir
    $Global:ImgDir  = Join-Path $Global:AppRoot "Imagenes"

    $ConfigFile = Join-Path $Global:AppRoot "config_server.txt"
    $CtrlCScript = Join-Path $Global:RootDir "send-ctrlc.ps1"
    $IdiomasScript = Join-Path $Global:RootDir "idiomas.ps1"
    $CuentasScript = Join-Path $Global:RootDir "cuentas.ps1"
    $PersonajesScript = Join-Path $Global:RootDir "personajes.ps1" # Ruta del nuevo módulo
    $DescargasScript = Join-Path $Global:RootDir "descargas.ps1"
    $RatesScript = Join-Path $Global:RootDir "rates.ps1"
    $ArmeriaScript = Join-Path $Global:RootDir "armeria.ps1"

    # =========================================================================
    # CARGA SEGURA DE MÓDULOS EN UTF-8 (Evita errores en 'ñ', '¡' y acentos)
    # =========================================================================
    $Global:Textos = @{}
    if (Test-Path $IdiomasScript) { 
        try { 
            $contenidoIdiomas = Get-Content $IdiomasScript -Raw -Encoding UTF8
            Invoke-Expression $contenidoIdiomas
        } catch {
            [System.Windows.Forms.MessageBox]::Show(
                "No se pudo cargar idiomas.ps1, el panel se quedara solo en espanol.`n`nError: $($_.Exception.Message)",
                "Aviso de idiomas", 'OK', 'Warning')
        }
    }

    if (Test-Path $CuentasScript) {
        try { 
            $contenidoCuentas = Get-Content $CuentasScript -Raw -Encoding UTF8
            Invoke-Expression $contenidoCuentas
        } catch {}
    }

    if (Test-Path $PersonajesScript) {
        try { 
            $contenidoPersonajes = Get-Content $PersonajesScript -Raw -Encoding UTF8
            Invoke-Expression $contenidoPersonajes
        } catch {}
    }

    if (Test-Path $DescargasScript) {
        try {
            $contenidoDescargas = Get-Content $DescargasScript -Raw -Encoding UTF8
            Invoke-Expression $contenidoDescargas
        } catch {}
    }

    if (Test-Path $RatesScript) {
        try {
            $contenidoRates = Get-Content $RatesScript -Raw -Encoding UTF8
            Invoke-Expression $contenidoRates
        } catch {}
    }

    if (Test-Path $ArmeriaScript) {
        try {
            $contenidoArmeria = Get-Content $ArmeriaScript -Raw -Encoding UTF8
            Invoke-Expression $contenidoArmeria
        } catch {
            [System.Windows.Forms.MessageBox]::Show(
                "No se pudo cargar armeria.ps1.`n`nError: $($_.Exception.Message)",
                "Aviso", 'OK', 'Warning')
        }
    }

    # ==========================================
    # PANTALLA DE BIENVENIDA (SPLASH) ANTES DEL PANEL
    # ==========================================
    # Coloca un archivo "splash.png" dentro de la carpeta "Imagenes"
    # para que se muestre unos segundos antes de abrir el panel principal.
    # Si no existe el archivo, esta parte se salta y no afecta a nada.
    $SplashImagePath = Join-Path $Global:ImgDir "splash.png"
    if (Test-Path $SplashImagePath) {
        try {
            $splash = New-Object System.Windows.Forms.Form
            $splash.FormBorderStyle = 'None'
            $splash.StartPosition = 'CenterScreen'
            $splash.ShowInTaskbar = $false
            $splash.TopMost = $true

            $splashImg = [System.Drawing.Image]::FromFile($SplashImagePath)
            $splash.ClientSize = New-Object System.Drawing.Size($splashImg.Width, $splashImg.Height)
            $splash.BackgroundImage = $splashImg
            $splash.BackgroundImageLayout = 'Stretch'

            # Permite cerrar el splash antes de tiempo haciendo click sobre él
            $splash.Add_Click({ $splash.Close() })

            $splash.Show()
            $splash.Refresh()

            $SplashDuracionMs = 2500  # Duracion en pantalla (2.5 segundos). Cambia este valor a tu gusto.
            $splashTimer = New-Object System.Windows.Forms.Timer
            $splashTimer.Interval = $SplashDuracionMs
            $splashTimer.Add_Tick({
                $splashTimer.Stop()
                $splash.Close()
            })
            $splashTimer.Start()

            while ($splash.Visible) {
                Start-Sleep -Milliseconds 30
                [System.Windows.Forms.Application]::DoEvents()
            }
            $splashTimer.Dispose()
            $splash.Dispose()
        } catch {}
    }

    # ==========================================
    # GESTION DE CONFIGURACION
    # ==========================================
    $Global:MysqlDir = ""
    $Global:AuthDir = ""
    $Global:WorldDir = ""
    $Global:WowExe = ""
    $Global:WorldConfPath = ""
    $Global:ModsDir = ""
    $Global:MysqlAdminUser = "root"
    $Global:MysqlAdminPass = ""
    $Global:CharDbName = "acore_characters"
    $Global:Idioma = "ES"

    Function Obtener-Texto($clave, $defecto) {
        $idioma = $Global:Idioma
        if ($Global:Textos -and $Global:Textos.ContainsKey($idioma) -and $Global:Textos[$idioma].ContainsKey($clave)) {
            return $Global:Textos[$idioma][$clave]
        }
        return $defecto
    }

    Function Cargar-Configuracion {
        if (Test-Path $ConfigFile) {
            Get-Content $ConfigFile -Encoding UTF8 | ForEach-Object {
                if ($_ -match "^MYSQL_DIR=(.*)") { $Global:MysqlDir = $Matches[1] }
                if ($_ -match "^AUTH_DIR=(.*)") { $Global:AuthDir = $Matches[1] }
                if ($_ -match "^WORLD_DIR=(.*)") { $Global:WorldDir = $Matches[1] }
                if ($_ -match "^WOW_EXE=(.*)") { $Global:WowExe = $Matches[1] }
                if ($_ -match "^WORLDCONF_PATH=(.*)") { $Global:WorldConfPath = $Matches[1] }
                if ($_ -match "^MODS_DIR=(.*)") { $Global:ModsDir = $Matches[1] }
                if ($_ -match "^MYSQL_USER=(.*)") { $Global:MysqlUser = $Matches[1] }
                if ($_ -match "^MYSQL_PASS=(.*)") { $Global:MysqlPass = $Matches[1] }
                if ($_ -match "^MYSQL_ADMIN_USER=(.*)") { $Global:MysqlAdminUser = $Matches[1] }
                if ($_ -match "^MYSQL_ADMIN_PASS=(.*)") { $Global:MysqlAdminPass = $Matches[1] }
                if ($_ -match "^CHAR_DB=(.*)") { $Global:CharDbName = $Matches[1] }
                if ($_ -match "^LANG=(.*)") { $Global:Idioma = $Matches[1] }
            }
        }
        
        if (-not $Global:MysqlDir -or -not $Global:AuthDir -or -not $Global:WorldDir -or -not $Global:WowExe) {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "ConfigIn" "Faltan rutas de configuracion. Se abrira el asistente."), "Config", 'OK', 'Information')
            Configurar-Rutas
        }
    }

    Function Guardar-Configuracion {
        $configContenido = "MYSQL_DIR=$($Global:MysqlDir)`nAUTH_DIR=$($Global:AuthDir)`nWORLD_DIR=$($Global:WorldDir)`nWOW_EXE=$($Global:WowExe)`nWORLDCONF_PATH=$($Global:WorldConfPath)`nMODS_DIR=$($Global:ModsDir)`nMYSQL_USER=$($Global:MysqlUser)`nMYSQL_PASS=$($Global:MysqlPass)`nMYSQL_ADMIN_USER=$($Global:MysqlAdminUser)`nMYSQL_ADMIN_PASS=$($Global:MysqlAdminPass)`nCHAR_DB=$($Global:CharDbName)`nLANG=$($Global:Idioma)"
        $configContenido | Out-File -FilePath $ConfigFile -Encoding UTF8
    }

    Function Seleccionar-Carpeta($titulo) {
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = $titulo
        if ($folderBrowser.ShowDialog() -eq 'OK') { return $folderBrowser.SelectedPath }
        return ""
    }

    Function Seleccionar-Archivo($titulo) {
        $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $fileBrowser.Title = $titulo
        $fileBrowser.Filter = "Ejecutables (*.exe)|*.exe"
        if ($fileBrowser.ShowDialog() -eq 'OK') { return $fileBrowser.FileName }
        return ""
    }

    Function Configurar-Rutas {
        $Global:MysqlDir = Seleccionar-Carpeta "MySQL BIN"
        $Global:AuthDir = Seleccionar-Carpeta "AuthServer"
        $Global:WorldDir = Seleccionar-Carpeta "WorldServer"
        $Global:WowExe = Seleccionar-Archivo "Wow.exe"
        
        if ($Global:MysqlDir -and $Global:AuthDir -and $Global:WorldDir -and $Global:WowExe) {
            Guardar-Configuracion
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "ConfigSave" "Rutas guardadas."), "OK", 'OK', 'Information')
        } else {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "ConfigCancel" "Configuracion incompleta. El panel se cerrara."), "Error", 'OK', 'Error')
            if (Get-Variable -Name "form" -ErrorAction SilentlyContinue) { $form.Close() } else { exit }
        }
    }

    # Ventana para editar las credenciales de MySQL de ESTE servidor concreto
    # (se guardan en su propio config_server.txt, asi que cada instalacion del
    # panel puede tener un usuario/contraseña distintos sin tocar el codigo).
    Function Configurar-CredencialesMysql {
        $credForm = New-Object System.Windows.Forms.Form
        $credForm.Text = Obtener-Texto "TituloCredencialesMysql" "Credenciales de MySQL"
        $credForm.Size = New-Object System.Drawing.Size(430, 340)
        $credForm.StartPosition = 'CenterParent'
        $credForm.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 26)
        $credForm.ForeColor = [System.Drawing.Color]::White
        $credForm.FormBorderStyle = 'FixedDialog'
        $credForm.MaximizeBox = $false
        $credForm.MinimizeBox = $false

        $fLabelCred = New-Object System.Drawing.Font("Segoe UI", 9)
        $fGrupoCred = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
        $fAvisoCred = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Italic)

        $boxApp = New-Object System.Windows.Forms.GroupBox
        $boxApp.Text = Obtener-Texto "GrpMysqlApp" "Usuario de la aplicacion (hermandades, personajes...)"
        $boxApp.Location = New-Object System.Drawing.Point(15, 15)
        $boxApp.Size = New-Object System.Drawing.Size(390, 95)
        $boxApp.ForeColor = [System.Drawing.Color]::White
        $boxApp.Font = $fGrupoCred
        $credForm.Controls.Add($boxApp)

        $lblAppUser = New-Object System.Windows.Forms.Label
        $lblAppUser.Text = Obtener-Texto "LblUsuario" "Usuario:"
        $lblAppUser.Location = New-Object System.Drawing.Point(15, 28)
        $lblAppUser.Size = New-Object System.Drawing.Size(80, 20)
        $lblAppUser.Font = $fLabelCred
        $boxApp.Controls.Add($lblAppUser)

        $txtAppUser = New-Object System.Windows.Forms.TextBox
        $txtAppUser.Location = New-Object System.Drawing.Point(100, 25)
        $txtAppUser.Size = New-Object System.Drawing.Size(270, 20)
        $txtAppUser.Font = $fLabelCred
        $txtAppUser.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 60)
        $txtAppUser.ForeColor = [System.Drawing.Color]::White
        $txtAppUser.Text = if ($Global:MysqlUser) { $Global:MysqlUser } else { "acore" }
        $boxApp.Controls.Add($txtAppUser)

        $lblAppPass = New-Object System.Windows.Forms.Label
        $lblAppPass.Text = Obtener-Texto "LblContrasena" "Contrasena:"
        $lblAppPass.Location = New-Object System.Drawing.Point(15, 58)
        $lblAppPass.Size = New-Object System.Drawing.Size(80, 20)
        $lblAppPass.Font = $fLabelCred
        $boxApp.Controls.Add($lblAppPass)

        $txtAppPass = New-Object System.Windows.Forms.TextBox
        $txtAppPass.Location = New-Object System.Drawing.Point(100, 55)
        $txtAppPass.Size = New-Object System.Drawing.Size(270, 20)
        $txtAppPass.Font = $fLabelCred
        $txtAppPass.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 60)
        $txtAppPass.ForeColor = [System.Drawing.Color]::White
        $txtAppPass.UseSystemPasswordChar = $true
        $txtAppPass.Text = if ($Global:MysqlPass) { $Global:MysqlPass } else { "acore" }
        $boxApp.Controls.Add($txtAppPass)

        $boxAdmin = New-Object System.Windows.Forms.GroupBox
        $boxAdmin.Text = Obtener-Texto "GrpMysqlAdmin" "Usuario administrador (apagar MySQL, permisos)"
        $boxAdmin.Location = New-Object System.Drawing.Point(15, 120)
        $boxAdmin.Size = New-Object System.Drawing.Size(390, 95)
        $boxAdmin.ForeColor = [System.Drawing.Color]::White
        $boxAdmin.Font = $fGrupoCred
        $credForm.Controls.Add($boxAdmin)

        $lblAdminUser = New-Object System.Windows.Forms.Label
        $lblAdminUser.Text = Obtener-Texto "LblUsuario" "Usuario:"
        $lblAdminUser.Location = New-Object System.Drawing.Point(15, 28)
        $lblAdminUser.Size = New-Object System.Drawing.Size(80, 20)
        $lblAdminUser.Font = $fLabelCred
        $boxAdmin.Controls.Add($lblAdminUser)

        $txtAdminUser = New-Object System.Windows.Forms.TextBox
        $txtAdminUser.Location = New-Object System.Drawing.Point(100, 25)
        $txtAdminUser.Size = New-Object System.Drawing.Size(270, 20)
        $txtAdminUser.Font = $fLabelCred
        $txtAdminUser.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 60)
        $txtAdminUser.ForeColor = [System.Drawing.Color]::White
        $txtAdminUser.Text = if ($Global:MysqlAdminUser) { $Global:MysqlAdminUser } else { "root" }
        $boxAdmin.Controls.Add($txtAdminUser)

        $lblAdminPass = New-Object System.Windows.Forms.Label
        $lblAdminPass.Text = Obtener-Texto "LblContrasena" "Contrasena:"
        $lblAdminPass.Location = New-Object System.Drawing.Point(15, 58)
        $lblAdminPass.Size = New-Object System.Drawing.Size(80, 20)
        $lblAdminPass.Font = $fLabelCred
        $boxAdmin.Controls.Add($lblAdminPass)

        $txtAdminPass = New-Object System.Windows.Forms.TextBox
        $txtAdminPass.Location = New-Object System.Drawing.Point(100, 55)
        $txtAdminPass.Size = New-Object System.Drawing.Size(270, 20)
        $txtAdminPass.Font = $fLabelCred
        $txtAdminPass.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 60)
        $txtAdminPass.ForeColor = [System.Drawing.Color]::White
        $txtAdminPass.UseSystemPasswordChar = $true
        $txtAdminPass.Text = $Global:MysqlAdminPass
        $boxAdmin.Controls.Add($txtAdminPass)

        $chkVerPass = New-Object System.Windows.Forms.CheckBox
        $chkVerPass.Text = Obtener-Texto "ChkVerContrasenas" "Mostrar contrasenas"
        $chkVerPass.Location = New-Object System.Drawing.Point(15, 222)
        $chkVerPass.Size = New-Object System.Drawing.Size(200, 22)
        $chkVerPass.Font = $fLabelCred
        $chkVerPass.ForeColor = [System.Drawing.Color]::LightGray
        $chkVerPass.Add_CheckedChanged({
            $txtAppPass.UseSystemPasswordChar = -not $chkVerPass.Checked
            $txtAdminPass.UseSystemPasswordChar = -not $chkVerPass.Checked
        })
        $credForm.Controls.Add($chkVerPass)

        $lblAvisoCred = New-Object System.Windows.Forms.Label
        $lblAvisoCred.Text = Obtener-Texto "MsgAvisoCredencialesMysql" "El usuario administrador necesita el privilegio SHUTDOWN para poder apagar MySQL limpiamente. Estos datos se guardan solo en este equipo, en config_server.txt."
        $lblAvisoCred.Location = New-Object System.Drawing.Point(15, 248)
        $lblAvisoCred.Size = New-Object System.Drawing.Size(390, 34)
        $lblAvisoCred.Font = $fAvisoCred
        $lblAvisoCred.ForeColor = [System.Drawing.Color]::Goldenrod
        $credForm.Controls.Add($lblAvisoCred)

        $btnGuardarCred = New-Object System.Windows.Forms.Button
        $btnGuardarCred.Text = Obtener-Texto "BtnGuardar" "Guardar"
        $btnGuardarCred.Location = New-Object System.Drawing.Point(15, 286)
        $btnGuardarCred.Size = New-Object System.Drawing.Size(390, 30)
        $btnGuardarCred.BackColor = [System.Drawing.Color]::SeaGreen
        $btnGuardarCred.ForeColor = [System.Drawing.Color]::White
        $btnGuardarCred.FlatStyle = 'Flat'
        $btnGuardarCred.FlatAppearance.BorderSize = 0
        $btnGuardarCred.Font = $fGrupoCred
        $btnGuardarCred.Add_Click({
            $Global:MysqlUser = $txtAppUser.Text.Trim()
            $Global:MysqlPass = $txtAppPass.Text
            $Global:MysqlAdminUser = $txtAdminUser.Text.Trim()
            $Global:MysqlAdminPass = $txtAdminPass.Text
            Guardar-Configuracion
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgCredencialesGuardadas" "Credenciales guardadas correctamente."), "OK", 'OK', 'Information')
            $credForm.Close()
        })
        $credForm.Controls.Add($btnGuardarCred)

        $credForm.ShowDialog() | Out-Null
    }

    Cargar-Configuracion

    # ==========================================
    # DISEÑO DE LA INTERFAZ GRÁFICA (Ajustado)
    # ==========================================
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Panel de Control - Lleguito"
    $form.Size = New-Object System.Drawing.Size(680, 741) # Ensanchado para alojar los 3 botones limpios + descarga HD + rates + npcbots + credenciales mysql + mods + armeria
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 26)
    $form.ForeColor = [System.Drawing.Color]::White
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false

    # Paleta de acento reutilizable en toda la interfaz
    $ColorAcento = [System.Drawing.Color]::FromArgb(94, 129, 244)
    $ColorAcentoSuave = [System.Drawing.Color]::FromArgb(150, 160, 175)

    $fontTitulo = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
    $fontNormal = New-Object System.Drawing.Font("Segoe UI", 10)
    $fontEstado = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fontSeccion = New-Object System.Drawing.Font("Segoe UI Semibold", 9)

    $lblTitulo = New-Object System.Windows.Forms.Label
    $lblTitulo.Font = $fontTitulo
    $lblTitulo.ForeColor = [System.Drawing.Color]::White
    $lblTitulo.AutoSize = $true
    $lblTitulo.Location = New-Object System.Drawing.Point(50, 18)
    $form.Controls.Add($lblTitulo)

    # Linea de acento bajo el titulo, para dar un punto de color de marca
    $lineaAcentoTitulo = New-Object System.Windows.Forms.Panel
    $lineaAcentoTitulo.Location = New-Object System.Drawing.Point(50, 48)
    $lineaAcentoTitulo.Size = New-Object System.Drawing.Size(60, 3)
    $lineaAcentoTitulo.BackColor = $ColorAcento
    $form.Controls.Add($lineaAcentoTitulo)

    # Funciones auxiliares para el efecto visual al pasar el raton por los botones
    Function Aclarar-Color($color, $cantidad) {
        $r = [Math]::Min(255, $color.R + $cantidad)
        $g = [Math]::Min(255, $color.G + $cantidad)
        $b = [Math]::Min(255, $color.B + $cantidad)
        return [System.Drawing.Color]::FromArgb($r, $g, $b)
    }
    Function Oscurecer-Color($color, $cantidad) {
        $r = [Math]::Max(0, $color.R - $cantidad)
        $g = [Math]::Max(0, $color.G - $cantidad)
        $b = [Math]::Max(0, $color.B - $cantidad)
        return [System.Drawing.Color]::FromArgb($r, $g, $b)
    }

    Function Crear-PanelServicio($nombre, $y) {
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $nombre
        $lbl.Location = New-Object System.Drawing.Point(50, $y)
        $lbl.Font = $fontNormal
        $lbl.ForeColor = [System.Drawing.Color]::FromArgb(225, 225, 230)
        $lbl.AutoSize = $true
        $form.Controls.Add($lbl)

        $estado = New-Object System.Windows.Forms.Label
        $estado.Text = "Offline"
        $estado.Location = New-Object System.Drawing.Point(165, $y)
        $estado.Font = $fontEstado
        $estado.ForeColor = [System.Drawing.Color]::FromArgb(230, 90, 90)
        $estado.AutoSize = $true
        $form.Controls.Add($estado)

        return $estado
    }

    $luzMysql = Crear-PanelServicio "MySQL" 80
    $luzAuth = Crear-PanelServicio "AuthServer" 120
    $luzWorld = Crear-PanelServicio "WorldServer" 160
    $luzWow = Crear-PanelServicio "World of Warcraft" 200

    Function Crear-Boton($texto, $x, $y, $color, $accion) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $texto
        $btn.Location = New-Object System.Drawing.Point($x, ($y - 4))
        $btn.Size = New-Object System.Drawing.Size(100, 30)
        $btn.BackColor = $color
        $btn.ForeColor = [System.Drawing.Color]::White
        $btn.FlatStyle = 'Flat'
        $btn.FlatAppearance.BorderSize = 0
        $btn.FlatAppearance.MouseOverBackColor = Aclarar-Color $color 25
        $btn.FlatAppearance.MouseDownBackColor = Oscurecer-Color $color 20
        $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btn.Add_Click($accion)
        $form.Controls.Add($btn)
        return $btn
    }

    $btnStartMysql = Crear-Boton "" 240 80 ([System.Drawing.Color]::SeaGreen) { Start-Process "$Global:MysqlDir\mysqld.exe" -ArgumentList "--console" -WorkingDirectory $Global:MysqlDir }
    $btnStopMysql  = Crear-Boton "" 360 80 ([System.Drawing.Color]::IndianRed) { Stop-ProcesoMySQL }

    $btnStartAuth = Crear-Boton "" 240 120 ([System.Drawing.Color]::SeaGreen) { Start-Process "$Global:AuthDir\authserver.exe" -WorkingDirectory $Global:AuthDir }
    $btnStopAuth  = Crear-Boton "" 360 120 ([System.Drawing.Color]::IndianRed) { Stop-ProcesoSeguro "authserver" 20 }

    $btnStartWorld = Crear-Boton "" 240 160 ([System.Drawing.Color]::SeaGreen) { Start-Process "$Global:WorldDir\worldserver.exe" -WorkingDirectory $Global:WorldDir }
    $btnStopWorld  = Crear-Boton "" 360 160 ([System.Drawing.Color]::IndianRed) { Stop-ProcesoSeguro "worldserver" 30 }

    $btnStartWow = Crear-Boton "" 240 200 ([System.Drawing.Color]::SteelBlue) { 
        if ($Global:WowExe) {
            $wowWorkingDir = Split-Path -Parent $Global:WowExe
            Start-Process $Global:WowExe -WorkingDirectory $wowWorkingDir 
        }
    }
    $btnStartWow.Size = New-Object System.Drawing.Size(220, 30)

    # Alineado en la misma columna que "Iniciar Juego", justo debajo, para no invadir la zona del icono
    $btnRates = Crear-Boton "" 240 240 ([System.Drawing.Color]::FromArgb(90, 60, 150)) { Abrir-PanelRates $form }
    $btnRates.Size = New-Object System.Drawing.Size(220, 30)

    $btnStartAll = Crear-Boton "" 50 300 ([System.Drawing.Color]::MediumSeaGreen) { Iniciar-Todo }
    $btnStartAll.Size = New-Object System.Drawing.Size(270, 40)
    $btnStartAll.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

    $btnStopAll = Crear-Boton "" 340 300 ([System.Drawing.Color]::Firebrick) { Apagar-Todo }
    $btnStopAll.Size = New-Object System.Drawing.Size(270, 40)
    $btnStopAll.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Location = New-Object System.Drawing.Point(50, 360)
    $lblStatus.AutoSize = $true
    $lblStatus.Font = $fontNormal
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 205)
    $form.Controls.Add($lblStatus)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(50, 385)
    $progressBar.Size = New-Object System.Drawing.Size(560, 25) # Ensanchado simétricamente
    $progressBar.Style = 'Continuous'
    $form.Controls.Add($progressBar)

    # BOTÓN DE ANCHO COMPLETO PARA LA ARMERÍA DE PERSONAJES
    $btnArmeria = Crear-Boton "" 50 430 ([System.Drawing.Color]::FromArgb(150, 120, 20)) { Abrir-PanelArmeria $form }
    $btnArmeria.Size = New-Object System.Drawing.Size(580, 30)
    $btnArmeria.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

    # RE-DISTRIBUCIÓN INFERIOR DE 3 BOTONES COMPACTOS (Ancho 180px c/u, separación de 20px)
    $btnConfig = Crear-Boton "" 50 468 ([System.Drawing.Color]::FromArgb(70, 70, 78)) { Configurar-Rutas }
    $btnConfig.Size = New-Object System.Drawing.Size(180, 32)

    $btnCuentas = Crear-Boton "" 250 468 ([System.Drawing.Color]::FromArgb(60, 100, 160)) { Abrir-PanelCuentas $form }
    $btnCuentas.Size = New-Object System.Drawing.Size(180, 32)

    $btnPersonajes = Crear-Boton "" 450 468 ([System.Drawing.Color]::FromArgb(140, 75, 150)) { Abrir-PanelPersonajes $form }
    $btnPersonajes.Size = New-Object System.Drawing.Size(180, 32)

    # BOTÓN DE ANCHO COMPLETO PARA DESCARGAR EL CLIENTE HD
    $btnDescargarHD = Crear-Boton "" 50 530 ([System.Drawing.Color]::FromArgb(200, 140, 20)) { Abrir-PanelDescargas $form }
    $btnDescargarHD.Size = New-Object System.Drawing.Size(580, 30)
    $btnDescargarHD.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

    # SEPARADOR VISUAL DE SECCIÓN (línea + texto + línea, en vez de guiones ASCII)
    $lineaSepIzq = New-Object System.Windows.Forms.Panel
    $lineaSepIzq.Location = New-Object System.Drawing.Point(50, 576)
    $lineaSepIzq.Size = New-Object System.Drawing.Size(215, 1)
    $lineaSepIzq.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 78)
    $form.Controls.Add($lineaSepIzq)

    $lblSeparadorBots = New-Object System.Windows.Forms.Label
    $lblSeparadorBots.Text = Obtener-Texto "LblSeparadorNPCBots" "NPCBOTS"
    $lblSeparadorBots.Location = New-Object System.Drawing.Point(275, 566)
    $lblSeparadorBots.Size = New-Object System.Drawing.Size(130, 20)
    $lblSeparadorBots.TextAlign = 'MiddleCenter'
    $lblSeparadorBots.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $lblSeparadorBots.ForeColor = $ColorAcentoSuave
    $form.Controls.Add($lblSeparadorBots)

    $lineaSepDer = New-Object System.Windows.Forms.Panel
    $lineaSepDer.Location = New-Object System.Drawing.Point(415, 576)
    $lineaSepDer.Size = New-Object System.Drawing.Size(215, 1)
    $lineaSepDer.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 78)
    $form.Controls.Add($lineaSepDer)

    # BOTÓN DE ANCHO COMPLETO PARA EL GENERADOR DE NPCBOTS (requiere modulo mod-npcbots)
    $btnNPCBots = Crear-Boton "" 50 592 ([System.Drawing.Color]::FromArgb(150, 40, 40)) {
        $confirmacion = [System.Windows.Forms.MessageBox]::Show(
            (Obtener-Texto "MsgAvisoNPCBots" "AVISO OBLIGATORIO: este generador solo funciona en servidores AzerothCore que tengan instalado el modulo NPCBots (mod-npcbots). Si tu servidor NO lo tiene instalado, el SQL generado no servira de nada y podria dar errores al inyectarlo. Deseas abrir el generador?"),
            (Obtener-Texto "TituloAviso" "Aviso"), 'YesNo', 'Warning')
        if ($confirmacion -eq 'Yes') {
            $rutaHtmlBots = Join-Path $Global:RootDir "NPCBotsGenerator.html"
            if (Test-Path $rutaHtmlBots) {
                Start-Process $rutaHtmlBots
            } else {
                [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgNPCBotsNoEncontrado" "No se encontro el archivo NPCBotsGenerator.html en la carpeta Scripts."), "Error", 'OK', 'Error')
            }
        }
    }
    $btnNPCBots.Size = New-Object System.Drawing.Size(280, 30)
    $btnNPCBots.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

    $btnInyectarSQL = Crear-Boton "" 350 592 ([System.Drawing.Color]::FromArgb(60, 100, 160)) { Abrir-PanelInyectarSQL $form }
    $btnInyectarSQL.Size = New-Object System.Drawing.Size(280, 30)
    $btnInyectarSQL.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

    # BOTÓN DE ANCHO COMPLETO PARA CONFIGURAR LAS CREDENCIALES DE MYSQL
    $btnCredencialesMysql = Crear-Boton "" 50 630 ([System.Drawing.Color]::FromArgb(70, 70, 78)) { Configurar-CredencialesMysql }
    $btnCredencialesMysql.Size = New-Object System.Drawing.Size(580, 30)
    $btnCredencialesMysql.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

    # BOTÓN DE ANCHO COMPLETO PARA ABRIR LA CARPETA DE MODS
    $btnMods = Crear-Boton "" 50 668 ([System.Drawing.Color]::FromArgb(60, 100, 160)) {
        if (-not $Global:ModsDir -or -not (Test-Path $Global:ModsDir)) {
            $carpetaElegida = Seleccionar-Carpeta (Obtener-Texto "TituloSeleccionarMods" "Selecciona la carpeta de Mods")
            if ($carpetaElegida) {
                $Global:ModsDir = $carpetaElegida
                Guardar-Configuracion
            } else {
                return
            }
        }
        if (Test-Path $Global:ModsDir) {
            Start-Process "explorer.exe" -ArgumentList "`"$Global:ModsDir`""
        } else {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgModsCarpetaNoExiste" "La carpeta de Mods configurada ya no existe. Vuelve a pulsar el boton para seleccionarla de nuevo."), "Error", 'OK', 'Error')
            $Global:ModsDir = ""
        }
    }
    $btnMods.Size = New-Object System.Drawing.Size(580, 30)
    $btnMods.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

    $btnIdioma = Crear-Boton "Idioma: $Global:Idioma" 540 18 ([System.Drawing.Color]::FromArgb(70, 70, 78)) {
        if ($Global:Idioma -eq "ES") { $Global:Idioma = "EN" } else { $Global:Idioma = "ES" }
        $btnIdioma.Text = "Idioma: $Global:Idioma"
        Actualizar-Textos-Interfaz
        Guardar-Configuracion
    }
    $btnIdioma.Size = New-Object System.Drawing.Size(100, 26)

    # ==========================================
    # ICONO DEBAJO DEL SELECTOR DE IDIOMA (agregado, no modifica lo anterior)
    # ==========================================
    $IconoImagenPath = Join-Path $Global:ImgDir "icono.png"
    if (Test-Path $IconoImagenPath) {
        $picIcono = New-Object System.Windows.Forms.PictureBox
        $picIcono.Location = New-Object System.Drawing.Point(490, 65)
        $picIcono.Size = New-Object System.Drawing.Size(160, 160)
        $picIcono.SizeMode = 'Zoom'
        $picIcono.Image = [System.Drawing.Image]::FromFile($IconoImagenPath)
        $form.Controls.Add($picIcono)
    }

    # ==========================================
    # CONTADOR DE TIEMPO EN LINEA DEL WORLDSERVER
    # (hueco libre bajo el icono, no interfiere con nada mas)
    # ==========================================
    $lblUptimeTitulo = New-Object System.Windows.Forms.Label
    $lblUptimeTitulo.Location = New-Object System.Drawing.Point(490, 232)
    $lblUptimeTitulo.Size = New-Object System.Drawing.Size(160, 18)
    $lblUptimeTitulo.TextAlign = 'MiddleCenter'
    $lblUptimeTitulo.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $lblUptimeTitulo.ForeColor = $ColorAcentoSuave
    $form.Controls.Add($lblUptimeTitulo)

    $lblWorldUptime = New-Object System.Windows.Forms.Label
    $lblWorldUptime.Text = "--:--:--"
    $lblWorldUptime.Location = New-Object System.Drawing.Point(490, 250)
    $lblWorldUptime.Size = New-Object System.Drawing.Size(160, 26)
    $lblWorldUptime.TextAlign = 'MiddleCenter'
    $lblWorldUptime.Font = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
    $lblWorldUptime.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 155)
    $form.Controls.Add($lblWorldUptime)

    Function Actualizar-Textos-Interfaz {
        $lblTitulo.Text      = Obtener-Texto "Titulo" "PANEL DE CONTROL DEL SERVIDOR"
        $btnStartMysql.Text  = Obtener-Texto "BtnIniciar" "Iniciar"
        $btnStartAuth.Text   = $btnStartMysql.Text
        $btnStartWorld.Text  = $btnStartMysql.Text
        $btnStopMysql.Text   = Obtener-Texto "BtnApagar" "Apagar"
        $btnStopAuth.Text    = $btnStopMysql.Text
        $btnStopWorld.Text   = $btnStopMysql.Text
        $btnStartWow.Text    = Obtener-Texto "BtnWow" "Iniciar Juego"
        $btnStartAll.Text    = Obtener-Texto "BtnStartAll" "INICIAR TODO"
        $btnStopAll.Text     = Obtener-Texto "BtnStopAll" "APAGAR TODO"
        $btnConfig.Text      = Obtener-Texto "BtnConfig" "Cambiar Rutas"
        $btnCuentas.Text     = Obtener-Texto "BtnCuentas" "Cuentas y Rangos"
        $btnPersonajes.Text  = Obtener-Texto "BtnPersonajes" "Personajes (Pdump)"
        $btnDescargarHD.Text = Obtener-Texto "BtnDescargarHD" "Descargar Cliente HD y Servidor"
        $btnNPCBots.Text     = Obtener-Texto "BtnNPCBots" "Generador de NPCBots"
        $btnInyectarSQL.Text = Obtener-Texto "BtnInyectarSqlPrincipal" "Inyectar SQL"
        $btnCredencialesMysql.Text = Obtener-Texto "BtnCredencialesMysql" "Credenciales de MySQL (usuario / contrasena)"
        $btnMods.Text = Obtener-Texto "BtnMods" "Mods"
        $btnArmeria.Text = Obtener-Texto "BtnArmeria" "Armeria de Personajes"
        $btnRates.Text       = Obtener-Texto "BtnRates" "Configurar Rates"
        $lblStatus.Text      = Obtener-Texto "StatusWait" "Esperando acciones..."
        $lblUptimeTitulo.Text = Obtener-Texto "LblUptime" "Tiempo en linea"
    }

    Actualizar-Textos-Interfaz

    # ==========================================
    # LOGICA DE ACTUALIZACION Y PROCESOS
    # ==========================================
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.Add_Tick({
        if (Get-Process -Name "mysqld" -ErrorAction SilentlyContinue) { 
            $luzMysql.Text = "Online"; $luzMysql.ForeColor = [System.Drawing.Color]::LimeGreen 
        } else { 
            $luzMysql.Text = "Offline"; $luzMysql.ForeColor = [System.Drawing.Color]::Red 
        }
        
        if (Get-Process -Name "authserver" -ErrorAction SilentlyContinue) { 
            $luzAuth.Text = "Online"; $luzAuth.ForeColor = [System.Drawing.Color]::LimeGreen 
        } else { 
            $luzAuth.Text = "Offline"; $luzAuth.ForeColor = [System.Drawing.Color]::Red 
        }
        
        $procWorld = Get-Process -Name "worldserver" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($procWorld) { 
            $luzWorld.Text = "Online"; $luzWorld.ForeColor = [System.Drawing.Color]::LimeGreen 

            $tiempoActivo = (Get-Date) - $procWorld.StartTime
            if ($tiempoActivo.TotalHours -ge 24) {
                $lblWorldUptime.Text = "{0}d {1:D2}:{2:D2}:{3:D2}" -f [int]$tiempoActivo.Days, $tiempoActivo.Hours, $tiempoActivo.Minutes, $tiempoActivo.Seconds
            } else {
                $lblWorldUptime.Text = "{0:D2}:{1:D2}:{2:D2}" -f [int]$tiempoActivo.TotalHours, $tiempoActivo.Minutes, $tiempoActivo.Seconds
            }
            $lblWorldUptime.ForeColor = [System.Drawing.Color]::LimeGreen
        } else { 
            $luzWorld.Text = "Offline"; $luzWorld.ForeColor = [System.Drawing.Color]::Red 

            $lblWorldUptime.Text = "--:--:--"
            $lblWorldUptime.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 155)
        }

        if ($Global:WowExe) {
            $wowName = [System.IO.Path]::GetFileNameWithoutExtension($Global:WowExe)
            if ($wowName -and (Get-Process -Name $wowName -ErrorAction SilentlyContinue)) { 
                if ($Global:Idioma -eq "ES") { $luzWow.Text = "Jugando" } else { $luzWow.Text = "Playing" }
                $luzWow.ForeColor = [System.Drawing.Color]::Cyan 
            } else { 
                $luzWow.Text = "Offline"; $luzWow.ForeColor = [System.Drawing.Color]::Red 
            }
        }
    })
    $timer.Start()

    Function Esperar($segundos, $mensaje) {
        $lblStatus.Text = $mensaje
        $pasos = $segundos * 10
        for ($i = 0; $i -lt $pasos; $i++) {
            Start-Sleep -Milliseconds 100
            [System.Windows.Forms.Application]::DoEvents()
        }
    }

    Function Stop-ProcesoSeguro($nombre, $maxWait) {
        $nombreProceso = $nombre.Replace(".exe", "")
        $msgCtrlC = Obtener-Texto "CtrlC" "Enviando Ctrl+C a"
        $lblStatus.Text = "$msgCtrlC $nombreProceso..."
        [System.Windows.Forms.Application]::DoEvents()

        if (Get-Process -Name $nombreProceso -ErrorAction SilentlyContinue) {
            $argList = "-ExecutionPolicy Bypass -NoProfile -File `"$CtrlCScript`" -ProcessName $nombreProceso"
            Start-Process "powershell.exe" -ArgumentList $argList -NoNewWindow -Wait
            
            $waited = 0
            while ((Get-Process -Name $nombreProceso -ErrorAction SilentlyContinue) -and ($waited -lt ($maxWait * 2))) {
                Start-Sleep -Milliseconds 500
                $waited++
                [System.Windows.Forms.Application]::DoEvents()
            }
        }
        $lblStatus.Text = Obtener-Texto "Listo" "Listo."
        [System.Windows.Forms.Application]::DoEvents()
    }

    Function Stop-ProcesoMySQL {
        $lblStatus.Text = Obtener-Texto "Myson" "Apagando MySQL de forma limpia..."
        [System.Windows.Forms.Application]::DoEvents()

        if (Get-Process -Name "mysqld" -ErrorAction SilentlyContinue) {
            # mysqld.exe en Windows no responde a Ctrl+C como un programa de
            # consola normal; probamos dos formas de apagado limpio antes de forzar.
            $usuarioMysql = if ($Global:MysqlAdminUser) { $Global:MysqlAdminUser } else { "root" }
            $passMysql = $Global:MysqlAdminPass
            $env:MYSQL_PWD = $passMysql

            # Intento 1: mysqladmin shutdown (metodo clasico)
            $mysqlAdminExe = Join-Path $Global:MysqlDir "mysqladmin.exe"
            $salidaShutdown = ""
            try {
                $salidaShutdown = (& $mysqlAdminExe "-u$usuarioMysql" shutdown 2>&1 | Out-String).Trim()
            } catch {
                $salidaShutdown = $_.Exception.Message
            }

            $waited = 0
            while ((Get-Process -Name "mysqld" -ErrorAction SilentlyContinue) -and ($waited -lt 20)) {
                Start-Sleep -Milliseconds 500
                $waited++
                [System.Windows.Forms.Application]::DoEvents()
            }

            # Intento 2: si mysqladmin no funciono, probamos la sentencia SQL
            # "SHUTDOWN;" (funciona igual, pero por otra via; en MySQL 8.x es
            # la forma recomendada, mysqladmin shutdown queda mas de cara atras).
            $salidaShutdown2 = ""
            if (Get-Process -Name "mysqld" -ErrorAction SilentlyContinue) {
                $mysqlExeLocal = Join-Path $Global:MysqlDir "mysql.exe"
                try {
                    $salidaShutdown2 = (& $mysqlExeLocal "-u$usuarioMysql" -e "SHUTDOWN;" 2>&1 | Out-String).Trim()
                } catch {
                    $salidaShutdown2 = $_.Exception.Message
                }

                $waited = 0
                while ((Get-Process -Name "mysqld" -ErrorAction SilentlyContinue) -and ($waited -lt 20)) {
                    Start-Sleep -Milliseconds 500
                    $waited++
                    [System.Windows.Forms.Application]::DoEvents()
                }
            }

            if (Get-Process -Name "mysqld" -ErrorAction SilentlyContinue) {
                $lblStatus.Text = Obtener-Texto "Mysfail" "Finalizando proceso residual..."
                [System.Windows.Forms.Application]::DoEvents()
                Stop-Process -Name "mysqld" -Force -ErrorAction SilentlyContinue
                Start-Sleep -Milliseconds 500

                $mensaje = ((Obtener-Texto "MsgMysqlCierreForzado2" "El apagado limpio de MySQL (mysqladmin -u{0} shutdown) no ha funcionado a tiempo, asi que se ha tenido que forzar el cierre del proceso (no fue un apagado limpio).") -f $usuarioMysql)
                if ($salidaShutdown) {
                    $mensaje += "`n`n" + (Obtener-Texto "MsgMysqlShutdownDetalle" "Mensaje de mysqladmin:") + "`n$salidaShutdown"
                }
                if ($salidaShutdown2) {
                    $mensaje += "`n`n" + (Obtener-Texto "MsgMysqlShutdownDetalle2" "Mensaje de SHUTDOWN por SQL:") + "`n$salidaShutdown2"
                }
                [System.Windows.Forms.MessageBox]::Show($mensaje, (Obtener-Texto "TituloAviso" "Aviso"), 'OK', 'Warning')
            }
        }
        $lblStatus.Text = Obtener-Texto "Listo" "Listo."
        [System.Windows.Forms.Application]::DoEvents()
    }

    Function Iniciar-Todo {
        Deshabilitar-Botones
        $progressBar.Value = 0
        
        $lblStatus.Text = Obtener-Texto "StatusStartM" "[1/3] Iniciar MySQL..."
        Start-Process "$Global:MysqlDir\mysqld.exe" -ArgumentList "--console" -WorkingDirectory $Global:MysqlDir
        $progressBar.Value = 20
        Esperar 10 (Obtener-Texto "DbWait" "Esperando a que la Base de Datos cargue...")
        
        $lblStatus.Text = Obtener-Texto "StatusStartA" "[2/3] Iniciar AuthServer..."
        $progressBar.Value = 50
        Start-Process "$Global:AuthDir\authserver.exe" -WorkingDirectory $Global:AuthDir
        Esperar 10 (Obtener-Texto "AuthWait" "Esperando a que el autenticador este listo...")
        
        $lblStatus.Text = Obtener-Texto "StatusStartW" "[3/3] Iniciar WorldServer..."
        $progressBar.Value = 80
        Start-Process "$Global:WorldDir\worldserver.exe" -WorkingDirectory $Global:WorldDir
        Esperar 3 (Obtener-Texto "WorldWait" "Entorno lanzado correctamente.")
        
        $progressBar.Value = 100
        Habilitar-Botones
        $lblStatus.Text = Obtener-Texto "AllStarted" "Todo iniciado!"
    }

    Function Apagar-Todo {
        Deshabilitar-Botones
        $progressBar.Value = 100
        
        $lblStatus.Text = Obtener-Texto "StatusStopW" "[1/3] Apagando WorldServer..."
        Stop-ProcesoSeguro "worldserver" 30
        $progressBar.Value = 66
        
        $lblStatus.Text = Obtener-Texto "StatusStopA" "[2/3] Apagando AuthServer..."
        Stop-ProcesoSeguro "authserver" 20
        $progressBar.Value = 33
        
        $lblStatus.Text = Obtener-Texto "StatusStopM" "[3/3] Apagando MySQL..."
        Stop-ProcesoMySQL
        $progressBar.Value = 0
        
        Habilitar-Botones
        $lblStatus.Text = Obtener-Texto "AllStopped" "Entorno apagado!"
    }

    Function Deshabilitar-Botones {
        $form.Controls | Where-Object { $_.GetType().Name -eq "Button" } | ForEach-Object { $_.Enabled = $false }
    }
    Function Habilitar-Botones {
        $form.Controls | Where-Object { $_.GetType().Name -eq "Button" } | ForEach-Object { $_.Enabled = $true }
    }

    # ==========================================
    # PANTALLA DE DESPEDIDA CON REDES SOCIALES
    # ==========================================
    Function Mostrar-PantallaDespedida {
        $ImgDespedidaPath = Join-Path $Global:ImgDir "despedida.png"
        if (-not (Test-Path $ImgDespedidaPath)) { return }

        try {
            $despedida = New-Object System.Windows.Forms.Form
            $despedida.FormBorderStyle = 'None'
            $despedida.StartPosition = 'CenterScreen'
            $despedida.ShowInTaskbar = $false
            $despedida.TopMost = $true

            $imgDespedida = [System.Drawing.Image]::FromFile($ImgDespedidaPath)
            $despedida.ClientSize = New-Object System.Drawing.Size($imgDespedida.Width, $imgDespedida.Height)
            $despedida.BackgroundImage = $imgDespedida
            $despedida.BackgroundImageLayout = 'Stretch'

            # Botón "X" para cerrar, ya que al no tener bordes no hay barra de título
            $btnCerrarDespedida = New-Object System.Windows.Forms.Button
            $btnCerrarDespedida.Text = "X"
            $btnCerrarDespedida.Size = New-Object System.Drawing.Size(28, 28)
            $btnCerrarDespedida.Location = New-Object System.Drawing.Point(($imgDespedida.Width - 38), 10)
            $btnCerrarDespedida.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
            $btnCerrarDespedida.ForeColor = [System.Drawing.Color]::White
            $btnCerrarDespedida.FlatStyle = 'Flat'
            $btnCerrarDespedida.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
            $btnCerrarDespedida.Add_Click({ $despedida.Close() }.GetNewClosure())
            $despedida.Controls.Add($btnCerrarDespedida)

            # ------------------------------------------------------------------
            # ENLACES A REDES SOCIALES CON ICONO
            # Coloca los archivos icono_github.png / icono_coffee.png / icono_youtube.png
            # en la carpeta "Imagenes". Si alguno falta, simplemente no se dibuja.
            # ------------------------------------------------------------------
            Function Agregar-IconoRedSocial($archivoIcono, $texto, $url, $x, $y) {
                $rutaIcono = Join-Path $Global:ImgDir $archivoIcono
                if (-not (Test-Path $rutaIcono)) { return }

                $pic = New-Object System.Windows.Forms.PictureBox
                $pic.Location = New-Object System.Drawing.Point($x, $y)
                $pic.Size = New-Object System.Drawing.Size(40, 40)
                $pic.SizeMode = 'Zoom'
                $pic.BackColor = [System.Drawing.Color]::Transparent
                $pic.Cursor = [System.Windows.Forms.Cursors]::Hand
                $pic.Image = [System.Drawing.Image]::FromFile($rutaIcono)
                $pic.Add_Click({ Start-Process $url }.GetNewClosure())
                $despedida.Controls.Add($pic)

                $lbl = New-Object System.Windows.Forms.Label
                $lbl.Text = $texto
                $lbl.Location = New-Object System.Drawing.Point(($x + 48), ($y + 11))
                $lbl.AutoSize = $true
                $lbl.BackColor = [System.Drawing.Color]::Transparent
                $lbl.ForeColor = [System.Drawing.Color]::White
                $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
                $lbl.Cursor = [System.Windows.Forms.Cursors]::Hand
                $lbl.Add_Click({ Start-Process $url }.GetNewClosure())
                $despedida.Controls.Add($lbl)
            }

            # Columna pegada al lado derecho de la imagen, centrada verticalmente
            $colX = $imgDespedida.Width - 190
            $espacioEntreIconos = 60
            $totalAltura = 3 * $espacioEntreIconos
            $inicioY = [int](($imgDespedida.Height / 2) - ($totalAltura / 2))

            Agregar-IconoRedSocial "icono_github.png"  "GitHub"          "https://github.com/LleguitoWoW"     $colX ($inicioY + 0 * $espacioEntreIconos)
            Agregar-IconoRedSocial "icono_coffee.png"  "Buy me a coffee" "https://buymeacoffee.com/llegus69h" $colX ($inicioY + 1 * $espacioEntreIconos)
            Agregar-IconoRedSocial "icono_youtube.png" "YouTube"         "https://www.youtube.com/@Lleguito"  $colX ($inicioY + 2 * $espacioEntreIconos)

            $despedida.ShowDialog() | Out-Null
            $despedida.Dispose()
        } catch {}
    }

    $form.ShowDialog() | Out-Null
    $timer.Stop()
    $timer.Dispose()
    $form.Dispose()

    Mostrar-PantallaDespedida

} catch {
    Add-Type -AssemblyName System.Windows.Forms
    $errorMsg = "Error crítico al abrir el panel:`n`n" + $_.Exception.Message + "`n`nLínea: " + $_.InvocationInfo.ScriptLineNumber
    [System.Windows.Forms.MessageBox]::Show($errorMsg, "Error de Panel", 'OK', 'Error')
}