# ==========================================
# MÓDULO SATELLITE: GESTIÓN DE CUENTAS y GM
# ==========================================

# Importación de la API de Windows para gestionar el foco de ventanas de consola de manera independiente
$SigUser32 = '[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);'
Add-Type -MemberDefinition $SigUser32 -Name Win32WindowCuentas -Namespace Win32FunctionsCuentas -ErrorAction SilentlyContinue

Function Enviar-ComandoWorldServer($comando, $subForm, $parentForm) {
    $procWorld = Get-Process -Name "worldserver" -ErrorAction SilentlyContinue
    if (-not $procWorld) {
        [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgNoWorld" "WorldServer offline."), "Error", 'OK', 'Error')
        return $false
    }
    
    # Traer la consola del WorldServer al frente temporalmente
    [Win32FunctionsCuentas.Win32WindowCuentas]::SetForegroundWindow($procWorld.MainWindowHandle) | Out-Null
    Start-Sleep -Milliseconds 250
    
    # Enviar la cadena de texto simulando pulsaciones de teclado real + Enter
    [System.Windows.Forms.SendKeys]::SendWait($comando + "{ENTER}")
    Start-Sleep -Milliseconds 100
    
    # Devolver el foco a la aplicación gráfica de forma limpia
    [Win32FunctionsCuentas.Win32WindowCuentas]::SetForegroundWindow($parentForm.Handle) | Out-Null
    return $true
}

Function Abrir-PanelCuentas($parentForm) {
    $subForm = New-Object System.Windows.Forms.Form
    $subForm.Text = Obtener-Texto "BtnCuentas" "Cuentas y Personajes"
    $subForm.Size = New-Object System.Drawing.Size(430, 320)
    $subForm.StartPosition = 'CenterParent' # Centrado perfectamente sobre el panel principal
    $subForm.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
    $subForm.ForeColor = [System.Drawing.Color]::White
    $subForm.FormBorderStyle = 'FixedDialog'
    $subForm.MaximizeBox = $false
    $subForm.MinimizeBox = $false

    $fLabel = New-Object System.Drawing.Font("Segoe UI", 9)
    $fGroup = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

    # ------------------------------------------
    # SUBSECCIÓN 1: CREAR CUENTAS
    # ------------------------------------------
    $boxCrear = New-Object System.Windows.Forms.GroupBox
    $boxCrear.Text = Obtener-Texto "GrpCrear" "Crear Nueva Cuenta"
    $boxCrear.Location = New-Object System.Drawing.Point(15, 15)
    $boxCrear.Size = New-Object System.Drawing.Size(380, 115)
    $boxCrear.ForeColor = [System.Drawing.Color]::White
    $boxCrear.Font = $fGroup
    $subForm.Controls.Add($boxCrear)

    $lblUser1 = New-Object System.Windows.Forms.Label
    $lblUser1.Text = Obtener-Texto "LblUsuario" "Usuario:"
    $lblUser1.Location = New-Object System.Drawing.Point(15, 32)
    $lblUser1.Size = New-Object System.Drawing.Size(80, 20)
    $lblUser1.Font = $fLabel
    $boxCrear.Controls.Add($lblUser1)

    $txtUser1 = New-Object System.Windows.Forms.TextBox
    $txtUser1.Location = New-Object System.Drawing.Point(100, 29)
    $txtUser1.Size = New-Object System.Drawing.Size(140, 20)
    $txtUser1.Font = $fLabel
    $txtUser1.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtUser1.ForeColor = [System.Drawing.Color]::White
    $boxCrear.Controls.Add($txtUser1)

    $lblPass1 = New-Object System.Windows.Forms.Label
    $lblPass1.Text = Obtener-Texto "LblPassword" "Contraseña:"
    $lblPass1.Location = New-Object System.Drawing.Point(15, 67)
    $lblPass1.Size = New-Object System.Drawing.Size(80, 20)
    $lblPass1.Font = $fLabel
    $boxCrear.Controls.Add($lblPass1)

    $txtPass1 = New-Object System.Windows.Forms.TextBox
    $txtPass1.Location = New-Object System.Drawing.Point(100, 64)
    $txtPass1.Size = New-Object System.Drawing.Size(140, 20)
    $txtPass1.Font = $fLabel
    $txtPass1.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtPass1.ForeColor = [System.Drawing.Color]::White
    $boxCrear.Controls.Add($txtPass1)

    $btnAccionCrear = New-Object System.Windows.Forms.Button
    $btnAccionCrear.Text = Obtener-Texto "BtnAccion" "Crear"
    $btnAccionCrear.Location = New-Object System.Drawing.Point(260, 42)
    $btnAccionCrear.Size = New-Object System.Drawing.Size(100, 32)
    $btnAccionCrear.BackColor = [System.Drawing.Color]::SeaGreen
    $btnAccionCrear.FlatStyle = 'Flat'
    $btnAccionCrear.Font = $fGroup
    $btnAccionCrear.Add_Click({
        if ($txtUser1.Text.Trim() -and $txtPass1.Text.Trim()) {
            $comando = "account create $($txtUser1.Text.Trim()) $($txtPass1.Text.Trim())"
            if (Enviar-ComandoWorldServer $comando $subForm $parentForm) {
                [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgCreada" "¡Cuenta creada correctamente!"), "OK", 'OK', 'Information')
                $subForm.Close() # Cierra la subventana y vuelve al panel principal automáticamente
            }
        }
    })
    $boxCrear.Controls.Add($btnAccionCrear)

    # ------------------------------------------
    # SUBSECCIÓN 2: CONVERTIR CUENTA GM
    # ------------------------------------------
    $boxGM = New-Object System.Windows.Forms.GroupBox
    $boxGM.Text = Obtener-Texto "GrpGM" "Convertir Cuenta en GM"
    $boxGM.Location = New-Object System.Drawing.Point(15, 145)
    $boxGM.Size = New-Object System.Drawing.Size(380, 85)
    $boxGM.ForeColor = [System.Drawing.Color]::White
    $boxGM.Font = $fGroup
    $subForm.Controls.Add($boxGM)

    $lblUser2 = New-Object System.Windows.Forms.Label
    $lblUser2.Text = Obtener-Texto "LblUsuario" "Usuario:"
    $lblUser2.Location = New-Object System.Drawing.Point(15, 37)
    $lblUser2.Size = New-Object System.Drawing.Size(80, 20)
    $lblUser2.Font = $fLabel
    $boxGM.Controls.Add($lblUser2)

    $txtUser2 = New-Object System.Windows.Forms.TextBox
    $txtUser2.Location = New-Object System.Drawing.Point(100, 34)
    $txtUser2.Size = New-Object System.Drawing.Size(140, 20)
    $txtUser2.Font = $fLabel
    $txtUser2.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $txtUser2.ForeColor = [System.Drawing.Color]::White
    $boxGM.Controls.Add($txtUser2)

    $btnAccionGM = New-Object System.Windows.Forms.Button
    $btnAccionGM.Text = Obtener-Texto "BtnAccion" "Crear"
    $btnAccionGM.Location = New-Object System.Drawing.Point(260, 28)
    $btnAccionGM.Size = New-Object System.Drawing.Size(100, 32)
    $btnAccionGM.BackColor = [System.Drawing.Color]::SteelBlue
    $btnAccionGM.FlatStyle = 'Flat'
    $btnAccionGM.Font = $fGroup
    $btnAccionGM.Add_Click({
        if ($txtUser2.Text.Trim()) {
            $comando = "account set gmlevel $($txtUser2.Text.Trim()) 3 -1"
            if (Enviar-ComandoWorldServer $comando $subForm $parentForm) {
                [System.Windows.Forms.MessageBox]::Show((Obtener-Texto "MsgGMOK" "¡Rango GM asignado de forma segura!"), "OK", 'OK', 'Information')
                $subForm.Close() # Cierra la subventana y vuelve al panel principal automáticamente
            }
        }
    })
    $boxGM.Controls.Add($btnAccionGM)

    $subForm.ShowDialog() | Out-Null
}