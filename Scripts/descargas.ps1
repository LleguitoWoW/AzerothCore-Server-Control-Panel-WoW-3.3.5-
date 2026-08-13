# ==========================================
# MÓDULO SATELLITE: DESCARGA DEL CLIENTE HD
# ==========================================

Function Abrir-PanelDescargas($parentForm) {
    $subForm = New-Object System.Windows.Forms.Form
    $subForm.Text = Obtener-Texto "TituloDescargarHD" "Descargar Cliente HD"
    $subForm.Size = New-Object System.Drawing.Size(420, 420)
    $subForm.StartPosition = 'CenterParent'
    $subForm.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
    $subForm.ForeColor = [System.Drawing.Color]::White
    $subForm.FormBorderStyle = 'FixedDialog'
    $subForm.MaximizeBox = $false
    $subForm.MinimizeBox = $false

    $fInfo  = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
    $fGroup = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fLink  = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)

    # ------------------------------------------
    # CAJA CON LOS 3 ENLACES DE DESCARGA
    # ------------------------------------------
    $boxDescargas = New-Object System.Windows.Forms.GroupBox
    $boxDescargas.Text = Obtener-Texto "TituloDescargarHD" "Descargar Cliente HD"
    $boxDescargas.Location = New-Object System.Drawing.Point(15, 15)
    $boxDescargas.Size = New-Object System.Drawing.Size(380, 200)
    $boxDescargas.ForeColor = [System.Drawing.Color]::White
    $boxDescargas.Font = $fGroup
    $subForm.Controls.Add($boxDescargas)

    $lblInfo = New-Object System.Windows.Forms.Label
    $lblInfo.Text = Obtener-Texto "MsgDescargarInfo" "Elige la parte que quieras descargar:"
    $lblInfo.Location = New-Object System.Drawing.Point(15, 28)
    $lblInfo.Size = New-Object System.Drawing.Size(350, 20)
    $lblInfo.Font = $fInfo
    $lblInfo.ForeColor = [System.Drawing.Color]::LightGray
    $boxDescargas.Controls.Add($lblInfo)

    Function Agregar-EnlaceDescarga($texto, $url, $y) {
        $link = New-Object System.Windows.Forms.LinkLabel
        $link.Text = $texto
        $link.Location = New-Object System.Drawing.Point(20, $y)
        $link.AutoSize = $true
        $link.Font = $fLink
        $link.LinkColor = [System.Drawing.Color]::DeepSkyBlue
        $link.ActiveLinkColor = [System.Drawing.Color]::Gold
        $link.VisitedLinkColor = [System.Drawing.Color]::DeepSkyBlue
        $link.LinkBehavior = 'HoverUnderline'
        $link.Add_LinkClicked({ Start-Process $url }.GetNewClosure())
        $boxDescargas.Controls.Add($link)
    }

    Agregar-EnlaceDescarga (Obtener-Texto "LblParte1" "Parte 1") "https://drive.google.com/file/d/118t4Rf_rIPkDggcVHWpTm7ylNYVIlbqp/view?usp=drive_link" 60
    Agregar-EnlaceDescarga (Obtener-Texto "LblParte2" "Parte 2") "https://drive.google.com/file/d/1GiaGWQlhUUoY43Fdkq-zeobcewWf3_eI/view?usp=drive_link" 100
    Agregar-EnlaceDescarga (Obtener-Texto "LblParte3" "Parte 3") "https://drive.google.com/file/d/1HeA7baDjKihJp1w5dSEdHLi5f9fNBYg1/view?usp=drive_link" 140

    # ------------------------------------------
    # CAJA CON EL ENLACE DE DESCARGA DEL SERVIDOR
    # ------------------------------------------
    $boxServidor = New-Object System.Windows.Forms.GroupBox
    $boxServidor.Text = Obtener-Texto "TituloServidor" "Servidor"
    $boxServidor.Location = New-Object System.Drawing.Point(15, 225)
    $boxServidor.Size = New-Object System.Drawing.Size(380, 100)
    $boxServidor.ForeColor = [System.Drawing.Color]::White
    $boxServidor.Font = $fGroup
    $subForm.Controls.Add($boxServidor)

    $linkServidor = New-Object System.Windows.Forms.LinkLabel
    $linkServidor.Text = Obtener-Texto "LblServidor" "Descargar Servidor"
    $linkServidor.Location = New-Object System.Drawing.Point(20, 40)
    $linkServidor.AutoSize = $true
    $linkServidor.Font = $fLink
    $linkServidor.LinkColor = [System.Drawing.Color]::DeepSkyBlue
    $linkServidor.ActiveLinkColor = [System.Drawing.Color]::Gold
    $linkServidor.VisitedLinkColor = [System.Drawing.Color]::DeepSkyBlue
    $linkServidor.LinkBehavior = 'HoverUnderline'
    $linkServidor.Add_LinkClicked({ Start-Process "https://mega.nz/folder/51o2XRSQ#PaC_SmNqXFXzRnlMfi_HBQ" }.GetNewClosure())
    $boxServidor.Controls.Add($linkServidor)

    $btnCerrar = New-Object System.Windows.Forms.Button
    $btnCerrar.Text = Obtener-Texto "BtnCerrar" "Cerrar"
    $btnCerrar.Location = New-Object System.Drawing.Point(140, 340)
    $btnCerrar.Size = New-Object System.Drawing.Size(120, 32)
    $btnCerrar.BackColor = [System.Drawing.Color]::DimGray
    $btnCerrar.FlatStyle = 'Flat'
    $btnCerrar.Font = $fGroup
    $btnCerrar.Add_Click({ $subForm.Close() })
    $subForm.Controls.Add($btnCerrar)

    $subForm.ShowDialog() | Out-Null
}
