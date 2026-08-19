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
    $TransmogScript = Join-Path $Global:RootDir "Transmog.ps1"
    $EstablosScript = Join-Path $Global:RootDir "Establos.ps1"
    $RealmScript = Join-Path $Global:RootDir "realm.ps1"

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

    # Transmog despues de Armeria (reutiliza Consulta-Armeria / iconos)
    if (Test-Path $TransmogScript) {
        try {
            $contenidoTransmog = Get-Content $TransmogScript -Raw -Encoding UTF8
            Invoke-Expression $contenidoTransmog
        } catch {
            [System.Windows.Forms.MessageBox]::Show(
                "No se pudo cargar Transmog.ps1.`n`nError: $($_.Exception.Message)",
                "Aviso", 'OK', 'Warning')
        }
    }

    # Establos (monturas + mascotas de compania)
    if (Test-Path $EstablosScript) {
        try {
            $contenidoEstablos = Get-Content $EstablosScript -Raw -Encoding UTF8
            Invoke-Expression $contenidoEstablos
        } catch {
            [System.Windows.Forms.MessageBox]::Show(
                "No se pudo cargar Establos.ps1.`n`nError: $($_.Exception.Message)",
                "Aviso", 'OK', 'Warning')
        }
    }

    if (Test-Path $RealmScript) {
        try {
            $contenidoRealm = Get-Content $RealmScript -Raw -Encoding UTF8
            Invoke-Expression $contenidoRealm
        } catch {
            [System.Windows.Forms.MessageBox]::Show(
                "No se pudo cargar realm.ps1.`n`nError: $($_.Exception.Message)",
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

    # ==========================================
    # ACTUALIZACIONES DEL PANEL (version remota)
    # ==========================================
    # Sube version.json a tu GitHub (raw) y cambia esta URL si hace falta.
    # Formato del JSON:
    #   { "version": "2.3", "url": "https://github.com/.../releases/latest", "notas": "..." }
    $Global:PanelVersion   = "2.5.0"
    $Global:PanelUpdateUrl = "https://raw.githubusercontent.com/LleguitoWoW/Panel-Control/main/version.json"

    Function Comparar-VersionPanel($local, $remota) {
        try {
            $vL = [version](($local -replace '[^\d\.]', '') -replace '^\.+|\.+$', '')
            $vR = [version](($remota -replace '[^\d\.]', '') -replace '^\.+|\.+$', '')
            return ($vR -gt $vL)
        } catch {
            return ($remota -ne $local -and "$remota" -gt "$local")
        }
    }

    Function Comprobar-ActualizacionPanel {
        try {
            if (-not $Global:PanelUpdateUrl) { return }
            $wc = New-Object System.Net.WebClient
            $wc.Encoding = [System.Text.Encoding]::UTF8
            $wc.Headers.Add("User-Agent", "PanelControl/$($Global:PanelVersion)")
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
            $jsonTxt = $wc.DownloadString($Global:PanelUpdateUrl)
            if (-not $jsonTxt) { return }
            $info = $jsonTxt | ConvertFrom-Json
            if (-not $info -or -not $info.version) { return }

            $verRemota = [string]$info.version
            if (-not (Comparar-VersionPanel $Global:PanelVersion $verRemota)) { return }

            $notas = if ($info.notas) { [string]$info.notas } else { "" }
            $urlDescarga = if ($info.url) { [string]$info.url } else { "" }

            $titulo = Obtener-Texto "TituloActualizacion" "Actualizacion disponible"
            $msg = ((Obtener-Texto "MsgActualizacionDisponible" "Hay una nueva version del panel.`n`nTu version: {0}`nNueva version: {1}") -f $Global:PanelVersion, $verRemota)
            if ($notas) {
                $msg += "`n`n" + (Obtener-Texto "MsgActualizacionNotas" "Novedades:") + "`n$notas"
            }
            $msg += "`n`n" + (Obtener-Texto "MsgActualizacionPregunta" "¿Quieres abrir la pagina de descarga?")

            $resp = [System.Windows.Forms.MessageBox]::Show(
                $msg, $titulo,
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            if ($resp -eq [System.Windows.Forms.DialogResult]::Yes -and $urlDescarga) {
                try { Start-Process $urlDescarga } catch {}
            }
        } catch {
            # Sin internet / 404 / JSON invalido -> silencio
        }
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
    # DISEÑO DE LA INTERFAZ (v2 - nucleo + lateral)
    # ==========================================
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Panel de Control - Lleguito"
    $form.Size = New-Object System.Drawing.Size(920, 635)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 26)
    $form.ForeColor = [System.Drawing.Color]::White
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false

    $ColorAcento = [System.Drawing.Color]::FromArgb(94, 129, 244)
    $ColorAcentoSuave = [System.Drawing.Color]::FromArgb(150, 160, 175)
    $ColorLateral = [System.Drawing.Color]::FromArgb(28, 28, 34)
    $ColorLateralBtn = [System.Drawing.Color]::FromArgb(40, 40, 48)

    $fontTitulo = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $fontNormal = New-Object System.Drawing.Font("Segoe UI", 10)
    $fontEstado = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fontSeccion = New-Object System.Drawing.Font("Segoe UI Semibold", 9)
    $fontLateral = New-Object System.Drawing.Font("Segoe UI", 9)

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

    # --- Iconos Blizz-like (cache local) ---
    Function Obtener-IconoPanel($nombreIcono, $tamanio) {
        try {
            $sz = 26
            try { if ($tamanio -gt 0) { $sz = [int]$tamanio } } catch {}
            if (-not $nombreIcono) { return $null }
            $nom = [string]$nombreIcono.Trim()
            $nomLow = $nom.ToLower()

            # Alias cortos del menu lateral -> icono Wowhead si no hay PNG propio
            $aliasWow = @{
                "config" = "trade_engineering"
                "cuentas" = "inv_misc_groupneedmore"
                "armeria" = "inv_misc_head_dragon_01"
                "personajes" = "inv_misc_book_09"
                "descargas" = "inv_crate_04"
                "npcbots" = "ability_hunter_pet_spider"
                "mods" = "inv_misc_wrench_01"
                "reino" = "inv_misc_map_01"
            }
            $nomWow = $nomLow
            if ($aliasWow.ContainsKey($nomLow)) { $nomWow = $aliasWow[$nomLow] }

            # 1) Iconos PERSONALIZADOS: Imagenes\menu\
            #    Acepta: menu_armeria.png, armeria.png, o el nombre completo del icono wow
            #    Formatos: .png .jpg .jpeg .bmp .gif
            $dirsCustom = @()
            if ($Global:ImgDir) { $dirsCustom += (Join-Path $Global:ImgDir "menu") }
            if ($Global:AppRoot) { $dirsCustom += (Join-Path $Global:AppRoot "Imagenes\menu") }
            if ($Global:RootDir) {
                $dirsCustom += (Join-Path $Global:RootDir "Armeria\Imagenes\menu")
                $dirsCustom += (Join-Path (Split-Path -Parent $Global:RootDir) "Imagenes\menu")
            }
            $candidatos = @(
                $nom,
                ($nomLow),
                ("menu_" + $nomLow),
                ($nomLow -replace '^menu_',''),
                ($nomLow -replace '^inv_',''),
                ($nomLow -replace '^ability_',''),
                ($nomLow -replace '^spell_','')
            ) | Select-Object -Unique
            $exts = @(".png",".jpg",".jpeg",".bmp",".gif")
            foreach ($dir in $dirsCustom) {
                if (-not $dir -or -not (Test-Path -LiteralPath $dir)) { continue }
                foreach ($c in $candidatos) {
                    foreach ($ext in $exts) {
                        $fp = Join-Path $dir ($c + $ext)
                        if (Test-Path -LiteralPath $fp) {
                            try {
                                $img = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $fp).Path)
                                $bmp = New-Object System.Drawing.Bitmap $img, $sz, $sz
                                $img.Dispose()
                                return $bmp
                            } catch {}
                        }
                    }
                }
            }

            # 2) Cache Wowhead / ZAM (Armeria\Imagenes\ui)
            $base = $Global:RootDir
            if (-not $base) { return $null }
            $cacheDir = Join-Path $base "Armeria\Imagenes\ui"
            if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force -ErrorAction SilentlyContinue | Out-Null }
            $cacheFile = Join-Path $cacheDir ("{0}.jpg" -f $nomWow)
            if (-not (Test-Path -LiteralPath $cacheFile)) {
                try {
                    $wc = New-Object System.Net.WebClient
                    $wc.Headers.Add("User-Agent", "Mozilla/5.0")
                    $bytes = $null
                    foreach ($sn in @("medium","large","small")) {
                        try {
                            $bytes = $wc.DownloadData("https://wow.zamimg.com/images/wow/icons/$sn/$nomWow.jpg")
                            if ($bytes -and $bytes.Length -gt 50) { break }
                            $bytes = $null
                        } catch { $bytes = $null }
                    }
                    if ($bytes) { [System.IO.File]::WriteAllBytes($cacheFile, $bytes) }
                } catch {}
            }
            if (Test-Path -LiteralPath $cacheFile) {
                $img = [System.Drawing.Image]::FromFile($cacheFile)
                $bmp = New-Object System.Drawing.Bitmap $img, $sz, $sz
                $img.Dispose()
                return $bmp
            }
        } catch {}
        return $null
    }

    # --- Panel lateral izquierdo ---
    $panelLateral = New-Object System.Windows.Forms.Panel
    $panelLateral.Location = New-Object System.Drawing.Point(0, 0)
    $panelLateral.Size = New-Object System.Drawing.Size(168, 605)
    $panelLateral.BackColor = $ColorLateral
    $form.Controls.Add($panelLateral)

    $lblLateralTit = New-Object System.Windows.Forms.Label
    $lblLateralTit.Text = "MENU"
    $lblLateralTit.Location = New-Object System.Drawing.Point(12, 14)
    $lblLateralTit.Size = New-Object System.Drawing.Size(140, 20)
    $lblLateralTit.Font = $fontSeccion
    $lblLateralTit.ForeColor = $ColorAcentoSuave
    $panelLateral.Controls.Add($lblLateralTit)

    Function Crear-BotonLateral($texto, $y, $iconName, $colorAccent, $accion) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = "  $texto"
        $btn.Location = New-Object System.Drawing.Point(8, $y)
        $btn.Size = New-Object System.Drawing.Size(152, 42)
        $btn.BackColor = $ColorLateralBtn
        $btn.ForeColor = [System.Drawing.Color]::White
        $btn.FlatStyle = 'Flat'
        $btn.FlatAppearance.BorderSize = 1
        $btn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(55, 55, 65)
        $btn.FlatAppearance.MouseOverBackColor = Aclarar-Color $ColorLateralBtn 18
        $btn.FlatAppearance.MouseDownBackColor = Oscurecer-Color $ColorLateralBtn 12
        $btn.Font = $fontLateral
        $btn.TextAlign = 'MiddleLeft'
        $btn.ImageAlign = 'MiddleLeft'
        $btn.TextImageRelation = 'ImageBeforeText'
        $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btn.Padding = New-Object System.Windows.Forms.Padding(4, 0, 0, 0)
        try {
            $ic = Obtener-IconoPanel $iconName 26
            if ($ic) { $btn.Image = $ic }
        } catch {}
        $btn.Add_Click($accion)
        $panelLateral.Controls.Add($btn)
        return $btn
    }

    # Submenus (ventanas pequenas)
    Function Abrir-MenuPersonajes {
        # Solo pdump / gestion de personajes (Armeria tiene boton propio)
        if (Get-Command Abrir-PanelPersonajes -ErrorAction SilentlyContinue) {
            Abrir-PanelPersonajes $form
        } else {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgPersonajesNoModulo" "No se cargo personajes.ps1"), (Obtener-Texto "BtnPersonajes" "Personajes"), 'OK', 'Error')
        }
    }

    Function Abrir-MenuNPCBots {
        $mf = New-Object System.Windows.Forms.Form
        $mf.Text = "NPCBots"
        $mf.Size = New-Object System.Drawing.Size(360, 180)
        $mf.StartPosition = 'CenterParent'
        $mf.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 26)
        $mf.ForeColor = [System.Drawing.Color]::White
        $mf.FormBorderStyle = 'FixedDialog'
        $mf.MaximizeBox = $false
        $b1 = New-Object System.Windows.Forms.Button
        $b1.Text = Obtener-Texto "BtnNPCBots" "Generador de NPCBots"
        $b1.Location = New-Object System.Drawing.Point(30, 30)
        $b1.Size = New-Object System.Drawing.Size(280, 36)
        $b1.BackColor = [System.Drawing.Color]::FromArgb(150, 40, 40)
        $b1.ForeColor = [System.Drawing.Color]::White
        $b1.FlatStyle = 'Flat'
        $b1.Add_Click({
            $mf.Close()
            $rutaHtmlBots = Join-Path $Global:RootDir "NPCBotsGenerator.html"
            if (Test-Path $rutaHtmlBots) {
                $aviso = Obtener-Texto "MsgAvisoNPCBots" "AVISO: requiere mod-npcbots instalado. Abrir generador?"
                $r = [System.Windows.Forms.MessageBox]::Show($aviso, "NPCBots", 'YesNo', 'Warning')
                if ($r -eq 'Yes') { Start-Process $rutaHtmlBots }
            } else {
                [System.Windows.Forms.MessageBox]::Show("No se encontro NPCBotsGenerator.html", "Error", 'OK', 'Error')
            }
        })
        $mf.Controls.Add($b1)
        $b2 = New-Object System.Windows.Forms.Button
        $b2.Text = Obtener-Texto "BtnInyectarSqlPrincipal" "Inyectar SQL"
        $b2.Location = New-Object System.Drawing.Point(30, 80)
        $b2.Size = New-Object System.Drawing.Size(280, 36)
        $b2.BackColor = [System.Drawing.Color]::FromArgb(60, 100, 160)
        $b2.ForeColor = [System.Drawing.Color]::White
        $b2.FlatStyle = 'Flat'
        $b2.Add_Click({ $mf.Close(); Abrir-PanelInyectarSQL $form })
        $mf.Controls.Add($b2)
        [void]$mf.ShowDialog($form)
    }

    Function Abrir-MenuConfig {
        $mf = New-Object System.Windows.Forms.Form
        $mf.Text = Obtener-Texto "BtnConfig" "Configuracion"
        $mf.Size = New-Object System.Drawing.Size(360, 180)
        $mf.StartPosition = 'CenterParent'
        $mf.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 26)
        $mf.ForeColor = [System.Drawing.Color]::White
        $mf.FormBorderStyle = 'FixedDialog'
        $mf.MaximizeBox = $false
        $b1 = New-Object System.Windows.Forms.Button
        $b1.Text = Obtener-Texto "BtnConfig" "Cambiar Rutas"
        $b1.Location = New-Object System.Drawing.Point(30, 30)
        $b1.Size = New-Object System.Drawing.Size(280, 36)
        $b1.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 78)
        $b1.ForeColor = [System.Drawing.Color]::White
        $b1.FlatStyle = 'Flat'
        $b1.Add_Click({ $mf.Close(); Configurar-Rutas })
        $mf.Controls.Add($b1)
        $b2 = New-Object System.Windows.Forms.Button
        $b2.Text = Obtener-Texto "BtnCredencialesMysql" "Credenciales MySQL"
        $b2.Location = New-Object System.Drawing.Point(30, 80)
        $b2.Size = New-Object System.Drawing.Size(280, 36)
        $b2.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 78)
        $b2.ForeColor = [System.Drawing.Color]::White
        $b2.FlatStyle = 'Flat'
        $b2.Add_Click({ $mf.Close(); Configurar-CredencialesMysql })
        $mf.Controls.Add($b2)
        [void]$mf.ShowDialog($form)
    }

    $script:BtnLatConfig = Crear-BotonLateral "Rutas / Config" 42 "config" $ColorAcento { Abrir-MenuConfig }
    $script:BtnLatCuentas = Crear-BotonLateral "Cuentas" 90 "cuentas" $ColorAcento { Abrir-PanelCuentas $form }
    $script:BtnLatArmeria = Crear-BotonLateral "Armeria" 138 "armeria" $ColorAcento {
        if (Get-Command Abrir-PanelArmeria -ErrorAction SilentlyContinue) {
            Abrir-PanelArmeria $form
        } else {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgArmeriaNoModulo" "No se cargo armeria.ps1"), (Obtener-Texto "BtnArmeria" "Armeria"), 'OK', 'Error')
        }
    }
    $script:BtnLatPers = Crear-BotonLateral "Personajes" 186 "personajes" $ColorAcento { Abrir-MenuPersonajes }
    $script:BtnLatDesc = Crear-BotonLateral "Descargas" 234 "descargas" $ColorAcento { Abrir-PanelDescargas $form }
    $script:BtnLatBots = Crear-BotonLateral "NPCBots" 282 "npcbots" $ColorAcento { Abrir-MenuNPCBots }
    $script:BtnLatMods = Crear-BotonLateral "Mods" 330 "mods" $ColorAcento {
        if ($Global:ModsDir -and (Test-Path $Global:ModsDir)) {
            Start-Process explorer.exe $Global:ModsDir
        } else {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgModsNoExiste" "La carpeta de mods no existe. Configura rutas."), "Mods", 'OK', 'Error')
            $Global:ModsDir = ""
        }
    }
    $script:BtnLatReino = Crear-BotonLateral "Reino" 378 "reino" $ColorAcento {
        if (Get-Command Abrir-PanelReino -ErrorAction SilentlyContinue) {
            Abrir-PanelReino $form
        } else {
            [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgReinoNoModulo" "No se encontro realm.ps1 en la carpeta Scripts."), (Obtener-Texto "TituloReino" "Reino"), 'OK', 'Error')
        }
    }

    # --- Zona nucleo (derecha del lateral) ---
    $OX = 185  # offset X del nucleo

    $lblTitulo = New-Object System.Windows.Forms.Label
    $lblTitulo.Font = $fontTitulo
    $lblTitulo.ForeColor = [System.Drawing.Color]::White
    $lblTitulo.AutoSize = $true
    $lblTitulo.Location = New-Object System.Drawing.Point(($OX + 10), 14)
    $form.Controls.Add($lblTitulo)

    $lineaAcentoTitulo = New-Object System.Windows.Forms.Panel
    $lineaAcentoTitulo.Location = New-Object System.Drawing.Point(($OX + 10), 42)
    $lineaAcentoTitulo.Size = New-Object System.Drawing.Size(60, 3)
    $lineaAcentoTitulo.BackColor = $ColorAcento
    $form.Controls.Add($lineaAcentoTitulo)

    Function Crear-PanelServicio($nombre, $y) {
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $nombre
        $lbl.Location = New-Object System.Drawing.Point(($OX + 10), $y)
        $lbl.Font = $fontNormal
        $lbl.ForeColor = [System.Drawing.Color]::FromArgb(225, 225, 230)
        $lbl.AutoSize = $true
        $form.Controls.Add($lbl)

        $estado = New-Object System.Windows.Forms.Label
        $estado.Text = "Offline"
        $estado.Location = New-Object System.Drawing.Point(($OX + 130), $y)
        $estado.Font = $fontEstado
        $estado.ForeColor = [System.Drawing.Color]::FromArgb(230, 90, 90)
        $estado.AutoSize = $true
        $form.Controls.Add($estado)
        return $estado
    }

    $luzMysql = Crear-PanelServicio "MySQL" 60
    $luzAuth = Crear-PanelServicio "AuthServer" 100
    $luzWorld = Crear-PanelServicio "WorldServer" 140
    $luzWow = Crear-PanelServicio "World of Warcraft" 180

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

    $btnStartMysql = Crear-Boton "" ($OX + 230) 60 ([System.Drawing.Color]::SeaGreen) { Start-Process "$Global:MysqlDir\mysqld.exe" -ArgumentList "--console" -WorkingDirectory $Global:MysqlDir }
    $btnStopMysql  = Crear-Boton "" ($OX + 340) 60 ([System.Drawing.Color]::IndianRed) { Stop-ProcesoMySQL }

    $btnStartAuth = Crear-Boton "" ($OX + 230) 100 ([System.Drawing.Color]::SeaGreen) { Start-Process "$Global:AuthDir\authserver.exe" -WorkingDirectory $Global:AuthDir }
    $btnStopAuth  = Crear-Boton "" ($OX + 340) 100 ([System.Drawing.Color]::IndianRed) { Stop-ProcesoSeguro "authserver" 20 }

    $btnStartWorld = Crear-Boton "" ($OX + 230) 140 ([System.Drawing.Color]::SeaGreen) { Start-Process "$Global:WorldDir\worldserver.exe" -WorkingDirectory $Global:WorldDir }
    $btnStopWorld  = Crear-Boton "" ($OX + 340) 140 ([System.Drawing.Color]::IndianRed) { Stop-ProcesoSeguro "worldserver" 30 }

    $btnStartWow = Crear-Boton "" ($OX + 230) 180 ([System.Drawing.Color]::SteelBlue) {
        if ($Global:WowExe) {
            $wowWorkingDir = Split-Path -Parent $Global:WowExe
            Start-Process $Global:WowExe -WorkingDirectory $wowWorkingDir
        }
    }
    $btnStartWow.Size = New-Object System.Drawing.Size(210, 30)

    $btnRates = Crear-Boton "" ($OX + 230) 238 ([System.Drawing.Color]::FromArgb(90, 60, 150)) {
        if (Get-Command Abrir-PanelRates -ErrorAction SilentlyContinue) {
            Abrir-PanelRates $form
        } else {
            [System.Windows.Forms.MessageBox]::Show("No se cargo rates.ps1", "Rates", 'OK', 'Error')
        }
    }
    $btnRates.Size = New-Object System.Drawing.Size(210, 30)

    $btnStartAll = Crear-Boton "" ($OX + 10) 275 ([System.Drawing.Color]::DarkGreen) { Iniciar-Todo }
    $btnStartAll.Size = New-Object System.Drawing.Size(200, 32)
    $btnStartAll.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

    $btnStopAll = Crear-Boton "" ($OX + 230) 275 ([System.Drawing.Color]::Firebrick) { Apagar-Todo }
    $btnStopAll.Size = New-Object System.Drawing.Size(210, 32)
    $btnStopAll.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

    # Estado + barra bajo World of Warcraft: anchos alineados con la columna Offline (OX+130)
    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Location = New-Object System.Drawing.Point(($OX + 10), 205)
    $lblStatus.Size = New-Object System.Drawing.Size(200, 14)
    $lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 7.5)
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 185)
    $form.Controls.Add($lblStatus)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(($OX + 10), 220)
    # Hasta ~ columna Offline del cliente WoW (estado en OX+130 + texto)
    $progressBar.Size = New-Object System.Drawing.Size(175, 8)
    $progressBar.Style = 'Continuous'
    $form.Controls.Add($progressBar)

    # Idioma: banderas ES / EN (PNG en Imagenes\)
    $script:ColorIdiomaActivo   = [System.Drawing.Color]::FromArgb(50, 110, 70)
    $script:ColorIdiomaInactivo = [System.Drawing.Color]::FromArgb(45, 45, 52)

    Function Cargar-IconoBandera($nombreArchivo) {
        $rutas = @(
            (Join-Path $Global:ImgDir $nombreArchivo),
            (Join-Path $Global:AppRoot "Imagenes\$nombreArchivo"),
            (Join-Path (Split-Path -Parent $Global:RootDir) "Imagenes\$nombreArchivo")
        )
        foreach ($r in $rutas) {
            if ($r -and (Test-Path -LiteralPath $r)) {
                try {
                    $img = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $r).Path)
                    # Redimensionar a 28x18 para el boton
                    $bmp = New-Object System.Drawing.Bitmap 28, 18
                    $g = [System.Drawing.Graphics]::FromImage($bmp)
                    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                    $g.DrawImage($img, 0, 0, 28, 18)
                    $g.Dispose()
                    $img.Dispose()
                    return $bmp
                } catch {}
            }
        }
        return $null
    }

    Function Actualizar-EstiloBotonesIdioma {
        if (-not $script:BtnLangES -or -not $script:BtnLangEN) { return }
        if ($Global:Idioma -eq "EN") {
            $script:BtnLangES.BackColor = $script:ColorIdiomaInactivo
            $script:BtnLangEN.BackColor = $script:ColorIdiomaActivo
            $script:BtnLangES.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(70, 70, 80)
            $script:BtnLangEN.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(120, 200, 140)
        } else {
            $script:BtnLangES.BackColor = $script:ColorIdiomaActivo
            $script:BtnLangEN.BackColor = $script:ColorIdiomaInactivo
            $script:BtnLangES.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(120, 200, 140)
            $script:BtnLangEN.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(70, 70, 80)
        }
    }

    $imgFlagES = Cargar-IconoBandera "flag_es.png"
    $imgFlagEN = Cargar-IconoBandera "flag_en.png"
    $tipIdioma = New-Object System.Windows.Forms.ToolTip

    $btnLangES = New-Object System.Windows.Forms.Button
    $btnLangES.Text = ""
    $btnLangES.Location = New-Object System.Drawing.Point(($OX + 400), 10)
    $btnLangES.Size = New-Object System.Drawing.Size(40, 30)
    $btnLangES.FlatStyle = 'Flat'
    $btnLangES.FlatAppearance.BorderSize = 2
    $btnLangES.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnLangES.TabStop = $false
    if ($imgFlagES) {
        $btnLangES.Image = $imgFlagES
        $btnLangES.ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    } else {
        $btnLangES.Text = "ES"
        $btnLangES.ForeColor = [System.Drawing.Color]::White
        $btnLangES.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
    }
    $tipIdioma.SetToolTip($btnLangES, "Espanol (ES)")
    $btnLangES.Add_Click({
        if ($Global:Idioma -ne "ES") {
            $Global:Idioma = "ES"
            Actualizar-EstiloBotonesIdioma
            Actualizar-Textos-Interfaz
            Guardar-Configuracion
        }
    })
    $form.Controls.Add($btnLangES)
    $script:BtnLangES = $btnLangES

    $btnLangEN = New-Object System.Windows.Forms.Button
    $btnLangEN.Text = ""
    $btnLangEN.Location = New-Object System.Drawing.Point(($OX + 444), 10)
    $btnLangEN.Size = New-Object System.Drawing.Size(40, 30)
    $btnLangEN.FlatStyle = 'Flat'
    $btnLangEN.FlatAppearance.BorderSize = 2
    $btnLangEN.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnLangEN.TabStop = $false
    if ($imgFlagEN) {
        $btnLangEN.Image = $imgFlagEN
        $btnLangEN.ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    } else {
        $btnLangEN.Text = "EN"
        $btnLangEN.ForeColor = [System.Drawing.Color]::White
        $btnLangEN.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
    }
    $tipIdioma.SetToolTip($btnLangEN, "English (EN)")
    $btnLangEN.Add_Click({
        if ($Global:Idioma -ne "EN") {
            $Global:Idioma = "EN"
            Actualizar-EstiloBotonesIdioma
            Actualizar-Textos-Interfaz
            Guardar-Configuracion
        }
    })
    $form.Controls.Add($btnLangEN)
    $script:BtnLangEN = $btnLangEN

    Actualizar-EstiloBotonesIdioma
    $btnIdioma = $btnLangES

    # Icono decorativo + uptime a la derecha
    $IconoImagenPath = Join-Path $Global:ImgDir "icono.png"
    if (Test-Path $IconoImagenPath) {
        $picIcono = New-Object System.Windows.Forms.PictureBox
        $picIcono.Location = New-Object System.Drawing.Point(720, 55)
        $picIcono.Size = New-Object System.Drawing.Size(160, 160)
        $picIcono.SizeMode = 'Zoom'
        $picIcono.Image = [System.Drawing.Image]::FromFile($IconoImagenPath)
        $form.Controls.Add($picIcono)
    }

    $lblUptimeTitulo = New-Object System.Windows.Forms.Label
    $lblUptimeTitulo.Location = New-Object System.Drawing.Point(720, 225)
    $lblUptimeTitulo.Size = New-Object System.Drawing.Size(160, 18)
    $lblUptimeTitulo.TextAlign = 'MiddleCenter'
    $lblUptimeTitulo.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    $lblUptimeTitulo.ForeColor = $ColorAcentoSuave
    $form.Controls.Add($lblUptimeTitulo)

    $lblWorldUptime = New-Object System.Windows.Forms.Label
    $lblWorldUptime.Text = "--:--:--"
    $lblWorldUptime.Location = New-Object System.Drawing.Point(720, 243)
    $lblWorldUptime.Size = New-Object System.Drawing.Size(160, 26)
    $lblWorldUptime.TextAlign = 'MiddleCenter'
    $lblWorldUptime.Font = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
    $lblWorldUptime.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 155)
    $form.Controls.Add($lblWorldUptime)

    # ==========================================
    # POBLACION DEL REINO (online)
    # ==========================================
    $lblPobTitulo = New-Object System.Windows.Forms.Label
    $lblPobTitulo.Text = "Poblacion del reino"
    $lblPobTitulo.Location = New-Object System.Drawing.Point(($OX + 10), 315)
    $lblPobTitulo.Size = New-Object System.Drawing.Size(140, 18)
    $lblPobTitulo.Font = $fontSeccion
    $lblPobTitulo.ForeColor = $ColorAcentoSuave
    $lblPobTitulo.AutoSize = $false
    $form.Controls.Add($lblPobTitulo)

    # Contadores pegados al boton Actualizar (sin solapar el titulo)
    $lblPobCount = New-Object System.Windows.Forms.Label
    $lblPobCount.Text = "Online: --"
    $lblPobCount.Location = New-Object System.Drawing.Point(($OX + 150), 315)
    $lblPobCount.Size = New-Object System.Drawing.Size(310, 18)
    $lblPobCount.Font = $fontSeccion
    $lblPobCount.ForeColor = [System.Drawing.Color]::FromArgb(100, 220, 120)
    $lblPobCount.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $form.Controls.Add($lblPobCount)

    $btnPobRefresh = New-Object System.Windows.Forms.Button
    $btnPobRefresh.Text = "Actualizar"
    $btnPobRefresh.Location = New-Object System.Drawing.Point(($OX + 465), 312)
    $btnPobRefresh.Size = New-Object System.Drawing.Size(78, 24)
    $btnPobRefresh.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 58)
    $btnPobRefresh.ForeColor = [System.Drawing.Color]::White
    $btnPobRefresh.FlatStyle = 'Flat'
    $btnPobRefresh.FlatAppearance.BorderSize = 0
    $btnPobRefresh.Cursor = [System.Windows.Forms.Cursors]::Hand
    $form.Controls.Add($btnPobRefresh)

    # Filtro: Todos / Jugadores / Bots
    $script:PobFiltro = "all"

    # ==========================================
    # CACHE DE "CONEXIONES" (evita que bots que comparten
    # una misma cuenta se solapen/pisen entre si en el panel)
    # ==========================================
    # AzerothCore solo permite 1 personaje online por cuenta a la vez.
    # Cuando varios bots comparten cuenta, el ultimo que "entra" hace
    # que los anteriores pasen a online=0 en la BD, aunque sigan activos.
    # Para no perder su fila, guardamos el ultimo estado visto de cada
    # personaje y lo mantenemos unos cuantos refrescos (PobGraceTicks)
    # aunque momentaneamente el SQL ya no lo marque como online.
    $script:PobCache      = @{}   # Nombre -> datos + ultimo tick visto
    $script:PobTick       = 0     # Contador de refrescos
    $script:PobGraceTicks = 3     # Ciclos que "sobrevive" en el panel sin confirmacion (con timer de 20s ~ 60s)
    Function Crear-BotonFiltroPob($texto, $x, $filtro) {
        $b = New-Object System.Windows.Forms.Button
        $b.Text = $texto
        $b.Location = New-Object System.Drawing.Point($x, 575)
        $b.Size = New-Object System.Drawing.Size(88, 22)
        $b.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 52)
        $b.ForeColor = [System.Drawing.Color]::White
        $b.FlatStyle = 'Flat'
        $b.FlatAppearance.BorderSize = 1
        $b.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(70, 70, 80)
        $b.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $b.Cursor = [System.Windows.Forms.Cursors]::Hand
        $b.Tag = $filtro
        $b.Add_Click({
            $script:PobFiltro = [string]$this.Tag
            try { Actualizar-PoblacionReino } catch {}
        })
        $form.Controls.Add($b)
        return $b
    }
    $script:BtnPobAll = Crear-BotonFiltroPob "Todos" ($OX + 280) "all"
    $script:BtnPobPlayers = Crear-BotonFiltroPob "Jugadores" ($OX + 372) "players"
    $script:BtnPobBots = Crear-BotonFiltroPob "Bots" ($OX + 464) "bots"

    $lvPob = New-Object System.Windows.Forms.ListView
    $lvPob.Location = New-Object System.Drawing.Point(($OX + 10), 338)
    $lvPob.Size = New-Object System.Drawing.Size(540, 232)
    $lvPob.View = "Details"
    $lvPob.FullRowSelect = $true
    $lvPob.GridLines = $false
    $lvPob.MultiSelect = $false
    $lvPob.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 34)
    $lvPob.ForeColor = [System.Drawing.Color]::White
    $lvPob.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $lvPob.HeaderStyle = "Nonclickable"
    [void]$lvPob.Columns.Add("Nombre", 120)
    [void]$lvPob.Columns.Add("Nivel", 40)
    [void]$lvPob.Columns.Add("Clase", 85)
    [void]$lvPob.Columns.Add("Raza", 85)
    [void]$lvPob.Columns.Add("Faccion", 70)
    [void]$lvPob.Columns.Add("Tipo", 55)
    $lvPob.SmallImageList = New-Object System.Windows.Forms.ImageList
    $lvPob.SmallImageList.ImageSize = New-Object System.Drawing.Size(16, 16)
    $lvPob.SmallImageList.ColorDepth = "Depth32Bit"
    # Iconos faccion (cache ui)
    try {
        $imgA = Obtener-IconoPanel "inv_bannerpvp_02" 16
        $imgH = Obtener-IconoPanel "inv_bannerpvp_01" 16
        if (-not $imgA) { $imgA = Obtener-IconoPanel "achievement_pvp_a_14" 16 }
        if (-not $imgH) { $imgH = Obtener-IconoPanel "achievement_pvp_h_14" 16 }
        if ($imgA) { [void]$lvPob.SmallImageList.Images.Add("alliance", $imgA) } else {
            $bmp = New-Object System.Drawing.Bitmap 16, 16
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.Clear([System.Drawing.Color]::FromArgb(40, 80, 180))
            $g.Dispose()
            [void]$lvPob.SmallImageList.Images.Add("alliance", $bmp)
        }
        if ($imgH) { [void]$lvPob.SmallImageList.Images.Add("horde", $imgH) } else {
            $bmp = New-Object System.Drawing.Bitmap 16, 16
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.Clear([System.Drawing.Color]::FromArgb(160, 30, 30))
            $g.Dispose()
            [void]$lvPob.SmallImageList.Images.Add("horde", $bmp)
        }
    } catch {}
    $form.Controls.Add($lvPob)

    $lblPobHint = New-Object System.Windows.Forms.Label
    $lblPobHint.Text = "Doble clic = Armeria"
    $lblPobHint.Location = New-Object System.Drawing.Point(($OX + 10), 575)
    $lblPobHint.Size = New-Object System.Drawing.Size(160, 18)
    $lblPobHint.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $lblPobHint.ForeColor = [System.Drawing.Color]::FromArgb(140, 140, 150)
    $form.Controls.Add($lblPobHint)

    $script:PobRazas = @{
        1="Humano"; 2="Orco"; 3="Enano"; 4="Elfo Noche"; 5="No-Muerto"
        6="Tauren"; 7="Gnomo"; 8="Trol"; 10="Elfo Sangre"; 11="Draenei"
    }
    $script:PobClases = @{
        1="Guerrero"; 2="Paladin"; 3="Cazador"; 4="Picaro"; 5="Sacerdote"
        6="DK"; 7="Chaman"; 8="Mago"; 9="Brujo"; 11="Druida"
    }
    # Razas Alianza: 1,3,4,7,11 — Horda: 2,5,6,8,10
    $script:PobRazasAlianza = @(1, 3, 4, 7, 11)


    Function Consulta-PanelMysql([string]$sql, [string]$bd) {
        try {
            if (-not $Global:MysqlDir) { return @() }
            $exe = Join-Path $Global:MysqlDir "mysql.exe"
            if (-not (Test-Path $exe)) { return @() }
            if (-not (Get-Process -Name "mysqld" -ErrorAction SilentlyContinue)) { return @() }
            $env:MYSQL_PWD = $Global:MysqlPass
            $filas = & $exe "-u$($Global:MysqlUser)" -N -B -e $sql $bd 2>$null
            $env:MYSQL_PWD = ""
            $out = @()
            foreach ($f in @($filas)) {
                if ($null -eq $f) { continue }
                $t = ("$f").TrimEnd("`r")
                if ($t -and $t -notmatch '^(mysql:|Warning|ERROR)') { $out += $t }
            }
            return $out
        } catch {
            try { $env:MYSQL_PWD = "" } catch {}
            return @()
        }
    }

    Function Actualizar-PoblacionReino {
        try {
            # Si MySQL no esta corriendo (servidor apagado/reiniciado), no hay nada
            # realmente online: vaciamos la cache para no dejar "fantasmas".
            if (-not (Get-Process -Name "mysqld" -ErrorAction SilentlyContinue)) {
                $script:PobCache = @{}
                $lvPob.Items.Clear()
                $lblPobCount.Text = (Obtener-Texto "LblOnlineOff" "Online: -- (MySQL off)")
                return
            }

            $bdChar = if ($Global:CharDbName) { $Global:CharDbName } else { "acore_characters" }
            $bdAuth = if ($Global:AuthDbName) { $Global:AuthDbName } else { "acore_auth" }
            $botPrefix = "rndbot"
            try {
                if ($Global:PlayerbotAccountPrefix) { $botPrefix = [string]$Global:PlayerbotAccountPrefix }
            } catch {}
            $botPrefix = $botPrefix.ToLower()

            # Query join auth: bot si username empieza por rndbot
            # Partes en comillas simples para no romper `class` en PowerShell
            $sql = 'SELECT c.name, c.level, c.race, c.`class`, LOWER(IFNULL(a.username,'''')) FROM `' + $bdChar + '`.characters c LEFT JOIN `' + $bdAuth + '`.account a ON a.id = c.account WHERE c.online = 1 ORDER BY c.name ASC LIMIT 2000;'

            $filas = @(Consulta-PanelMysql $sql $bdChar)
            $script:PobTick++

            # --- Paso 1: actualizar/insertar en la cache todo lo que el SQL confirma online ahora ---
            foreach ($ln in $filas) {
                if (-not $ln) { continue }
                $p = ("$ln") -split "`t"
                if ($p.Count -lt 2) { continue }
                $nombre = $p[0].Trim()
                if (-not $nombre) { continue }
                $nivel = if ($p.Count -ge 2) { $p[1].Trim() } else { "?" }
                $razaId = 0; $claseId = 0
                if ($p.Count -ge 3) { try { $razaId = [int](($p[2]).Trim()) } catch { $razaId = 0 } }
                if ($p.Count -ge 4) { try { $claseId = [int](($p[3]).Trim()) } catch { $claseId = 0 } }
                $userAcc = ""
                if ($p.Count -ge 5) { $userAcc = $p[4].Trim().ToLower() }

                $esBot = $false
                if ($userAcc -and $userAcc.StartsWith($botPrefix)) { $esBot = $true }

                $esAlianza = $script:PobRazasAlianza -contains $razaId

                $script:PobCache[$nombre] = [PSCustomObject]@{
                    Nombre     = $nombre
                    Nivel      = $nivel
                    RazaId     = $razaId
                    ClaseId    = $claseId
                    EsBot      = $esBot
                    EsAlianza  = $esAlianza
                    LastTick   = $script:PobTick
                    Confirmado = $true   # visto en ESTE refresco
                }
            }

            # --- Paso 2: purgar de la cache lo que lleva demasiados ciclos sin confirmarse ---
            $clavesAEliminar = @()
            foreach ($k in $script:PobCache.Keys) {
                $entrada = $script:PobCache[$k]
                if (($script:PobTick - $entrada.LastTick) -gt $script:PobGraceTicks) {
                    $clavesAEliminar += $k
                }
            }
            foreach ($k in $clavesAEliminar) { $script:PobCache.Remove($k) }

            # --- Paso 3: marcar como "no confirmado este ciclo" lo que sobrevive solo por la cache ---
            foreach ($k in $script:PobCache.Keys) {
                $script:PobCache[$k].Confirmado = ($script:PobCache[$k].LastTick -eq $script:PobTick)
            }

            # --- Paso 4: pintar la lista a partir de la cache (ya sin solapes) ---
            $lvPob.BeginUpdate()
            $lvPob.Items.Clear()
            $n = 0
            $nBots = 0
            $nPlayers = 0
            $filtro = "all"
            try { if ($script:PobFiltro) { $filtro = [string]$script:PobFiltro } } catch {}

            foreach ($entrada in ($script:PobCache.Values | Sort-Object Nombre)) {
                $esBot = $entrada.EsBot
                if ($esBot) { $nBots++ } else { $nPlayers++ }

                # Filtro de lista
                if ($filtro -eq "bots" -and -not $esBot) { continue }
                if ($filtro -eq "players" -and $esBot) { continue }

                $razaId = $entrada.RazaId
                $claseId = $entrada.ClaseId
                $raza = "$razaId"
                if ($script:PobRazas -and $script:PobRazas.ContainsKey([int]$razaId)) { $raza = [string]$script:PobRazas[[int]$razaId] }
                elseif ($script:PobRazas -and $script:PobRazas.ContainsKey("$razaId")) { $raza = [string]$script:PobRazas["$razaId"] }
                $clase = "$claseId"
                if ($script:PobClases -and $script:PobClases.ContainsKey([int]$claseId)) { $clase = [string]$script:PobClases[[int]$claseId] }
                elseif ($script:PobClases -and $script:PobClases.ContainsKey("$claseId")) { $clase = [string]$script:PobClases["$claseId"] }
                $esAlianza = $entrada.EsAlianza
                $faccion = if ($esAlianza) { (Obtener-Texto "LblAlianza" "Alianza") } else { (Obtener-Texto "LblHorda" "Horda") }
                $tipo = if ($esBot) { (Obtener-Texto "LblTipoBot" "Bot") } else { (Obtener-Texto "LblTipoJugador" "Jugador") }
                if (-not $entrada.Confirmado) { $tipo += " *" }  # * = sostenido por cache, no confirmado en este ciclo

                $lvi = New-Object System.Windows.Forms.ListViewItem($entrada.Nombre)
                [void]$lvi.SubItems.Add($entrada.Nivel)
                [void]$lvi.SubItems.Add($clase)
                [void]$lvi.SubItems.Add($raza)
                [void]$lvi.SubItems.Add($faccion)
                [void]$lvi.SubItems.Add($tipo)
                $lvi.Tag = $entrada.Nombre
                try {
                    if ($lvPob.SmallImageList -and $lvPob.SmallImageList.Images.Count -ge 2) {
                        $lvi.ImageIndex = if ($esAlianza) { 0 } else { 1 }
                    }
                } catch {}
                if ($esBot) {
                    $lvi.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 120)
                } elseif ($esAlianza) {
                    $lvi.ForeColor = [System.Drawing.Color]::FromArgb(120, 170, 255)
                } else {
                    $lvi.ForeColor = [System.Drawing.Color]::FromArgb(255, 120, 100)
                }
                if (-not $entrada.Confirmado) {
                    # Atenuado: esta fila se mantiene gracias a la cache, no confirmada en el ultimo refresco
                    $c = $lvi.ForeColor
                    $lvi.ForeColor = [System.Drawing.Color]::FromArgb(150, [int]($c.R * 0.65), [int]($c.G * 0.65), [int]($c.B * 0.65))
                }
                [void]$lvPob.Items.Add($lvi)
                $n++
            }

            $total = $nBots + $nPlayers
            $fmt = Obtener-Texto "LblOnlineFmt" "Online: {0}  |  Jugadores: {1}  |  Bots: {2}"
            $lblPobCount.Text = [string]::Format($fmt, $total, $nPlayers, $nBots)

            # Resaltar filtro activo
            try {
                foreach ($bf in @($script:BtnPobAll, $script:BtnPobPlayers, $script:BtnPobBots)) {
                    if (-not $bf) { continue }
                    if ([string]$bf.Tag -eq $filtro) {
                        $bf.BackColor = [System.Drawing.Color]::FromArgb(70, 100, 160)
                    } else {
                        $bf.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 52)
                    }
                }
            } catch {}
        } catch {
            $lblPobCount.Text = (Obtener-Texto "LblOnlineError" "Online: error")
        } finally {
            try { $lvPob.EndUpdate() } catch {}
        }
    }

    $btnPobRefresh.Add_Click({ Actualizar-PoblacionReino })

    $lvPob.Add_DoubleClick({
        try {
            if ($lvPob.SelectedItems.Count -lt 1) { return }
            $nom = [string]$lvPob.SelectedItems[0].Tag
            if (-not $nom) { $nom = $lvPob.SelectedItems[0].Text }
            if (-not $nom) { return }
            if (Get-Command Abrir-PanelArmeria -ErrorAction SilentlyContinue) {
                $Global:ArmeriaAutoBuscar = $nom
                Abrir-PanelArmeria $form $nom
            } else {
                [System.Windows.Forms.MessageBox]::Show("Armeria no cargada.", "Armeria", 'OK', 'Warning')
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error abriendo Armeria:`n$($_.Exception.Message)", "Armeria", 'OK', 'Error')
        }
    })

    # Timer cada 20s (bajo consumo)
    $timerPob = New-Object System.Windows.Forms.Timer
    $timerPob.Interval = 20000
    $timerPob.Add_Tick({ try { Actualizar-PoblacionReino } catch {} })
    $timerPob.Start()
    # Primera carga diferida 2s (deja arrancar MySQL)
    $timerPobOnce = New-Object System.Windows.Forms.Timer
    $timerPobOnce.Interval = 2000
    $timerPobOnce.Add_Tick({
        $timerPobOnce.Stop()
        $timerPobOnce.Dispose()
        try { Actualizar-PoblacionReino } catch {}
    })
    $timerPobOnce.Start()

    # Stubs para no romper Actualizar-Textos-Interfaz (botones movidos al lateral)
    $btnConfig = $script:BtnLatConfig
    $btnCuentas = $script:BtnLatCuentas
    $btnPersonajes = $script:BtnLatPers
    $btnDescargarHD = $script:BtnLatDesc
    $btnNPCBots = $script:BtnLatBots
    $btnMods = $script:BtnLatMods
    $btnArmeria = $script:BtnLatPers
    $btnInyectarSQL = $script:BtnLatBots
    $btnCredencialesMysql = $script:BtnLatConfig

    Function Actualizar-Textos-Interfaz {
        try { Actualizar-EstiloBotonesIdioma } catch {}
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
        $btnRates.Text       = Obtener-Texto "BtnRates" "Configurar Rates"
        $lblStatus.Text      = Obtener-Texto "StatusWait" "Esperando acciones..."
        $lblUptimeTitulo.Text = Obtener-Texto "LblUptime" "Tiempo en linea"
        try {
            if ($script:BtnLatConfig)  { $script:BtnLatConfig.Text  = "  " + (Obtener-Texto "BtnConfig" "Rutas / Config") }
            if ($script:BtnLatCuentas) { $script:BtnLatCuentas.Text = "  " + (Obtener-Texto "BtnCuentas" "Cuentas") }
            if ($script:BtnLatArmeria) { $script:BtnLatArmeria.Text = "  " + (Obtener-Texto "BtnArmeria" "Armeria") }
            if ($script:BtnLatPers)    { $script:BtnLatPers.Text    = "  " + (Obtener-Texto "BtnPersonajes" "Personajes") }
            if ($script:BtnLatDesc)    { $script:BtnLatDesc.Text    = "  " + (Obtener-Texto "BtnDescargarHD" "Descargas") }
            if ($script:BtnLatBots)    { $script:BtnLatBots.Text    = "  NPCBots" }
            if ($script:BtnLatMods)    { $script:BtnLatMods.Text    = "  " + (Obtener-Texto "BtnMods" "Mods") }
            if ($script:BtnLatReino)   { $script:BtnLatReino.Text   = "  " + (Obtener-Texto "BtnReino" "Reino") }
            if ($lblPobTitulo) { $lblPobTitulo.Text = Obtener-Texto "LblPoblacion" "Poblacion del reino" }
            if ($btnPobRefresh) { $btnPobRefresh.Text = Obtener-Texto "BtnActualizarPob" "Actualizar" }
            if ($lblPobHint) { $lblPobHint.Text = Obtener-Texto "HintPoblacionArmeria" "Doble clic = abrir Armeria" }
            if ($script:BtnPobAll) { $script:BtnPobAll.Text = Obtener-Texto "BtnFiltroTodos" "Todos" }
            if ($script:BtnPobPlayers) { $script:BtnPobPlayers.Text = Obtener-Texto "BtnFiltroJugadores" "Jugadores" }
            if ($script:BtnPobBots) { $script:BtnPobBots.Text = Obtener-Texto "BtnFiltroBots" "Bots" }
            if ($lvPob -and $lvPob.Columns.Count -ge 6) {
                $lvPob.Columns[0].Text = Obtener-Texto "ColPobNombre" "Nombre"
                $lvPob.Columns[1].Text = Obtener-Texto "ColPobNivel" "Nivel"
                $lvPob.Columns[2].Text = Obtener-Texto "ColPobClase" "Clase"
                $lvPob.Columns[3].Text = Obtener-Texto "ColPobRaza" "Raza"
                $lvPob.Columns[4].Text = Obtener-Texto "ColPobFaccion" "Faccion"
                $lvPob.Columns[5].Text = Obtener-Texto "ColPobTipo" "Tipo"
            }
            try { Actualizar-PoblacionReino } catch {}
        } catch {}
    }

    Actualizar-Textos-Interfaz

    # Comprobar actualizacion unos segundos despues de abrir el panel
    # (no bloquea el arranque; si no hay red, no dice nada)
    $timerUpdate = New-Object System.Windows.Forms.Timer
    $timerUpdate.Interval = 2500
    $timerUpdate.Add_Tick({
        $timerUpdate.Stop()
        $timerUpdate.Dispose()
        try { Comprobar-ActualizacionPanel } catch {}
    })
    $timerUpdate.Start()

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