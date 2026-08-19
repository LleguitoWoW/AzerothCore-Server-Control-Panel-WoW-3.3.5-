# ==========================================
# MÓDULO: ARMERÍA DE PERSONAJES - PAPERDOLL
# ==========================================

$Global:ArmeriaRazas = @{
    1="Humano"; 2="Orco"; 3="Enano"; 4="Elfo de la Noche"
    5="No-Muerto"; 6="Tauren"; 7="Gnomo"; 8="Trol"
    10="Elfo de Sangre"; 11="Draenei"
}
$Global:ArmeriaClases = @{
    1="Guerrero"; 2="Paladin"; 3="Cazador"; 4="Picaro"
    5="Sacerdote"; 6="Cab. de la Muerte"; 7="Chaman"
    8="Mago"; 9="Brujo"; 11="Druida"
}
$Global:ArmeriaFacciones = @{
    21="Argentum al Amanecer"; 47="Ironforge"; 54="Gnomeregan"; 67="Undercity"
    68="Orgrimmar"; 69="Darnassus"; 70="Furia del Toro"; 72="Exodar"; 76="Stormwind"
    169="Clan Steamwheedle"; 270="Zandalar"; 369="Darkspear"; 470="Gadgetzan"
    510="Liga de Arathor"; 529="Defensor de Warsong"; 530="Kurenai"
    577="Cenarion"; 589="Silvermoon"; 609="Guardia del Bosque"
    729="La Mano Argenta"; 749="Guardia de Cenarius"
    909="Los Aldor"; 911="Liga de Exploradores"
    932="Cenarion"; 933="El Consorcio"; 934="Guardianes de Cenarius"
    935="Kurenai"; 941="Expedicion Cenarion"; 942="Shatar"
    947="Los Aldor"; 967="Los Aruspices"; 970="Honor Hold"; 978="Thrallmar"
    1011="Contrabandistas de Booty Bay"; 1012="Serviles de Gadgetzan"
    1031="Los Maghar"; 1050="Zandalar"; 1052="Guardia del Cielo Brumoso"
    1064="El Ojo del Kirin Tor"; 1067="La Cruzada Argenta"; 1073="El Nexo"
    1077="Frente del Hierro"; 1085="Exploradores de Horda"
    1090="El Filo de Invierno"; 1091="La Alianza de Punta Arpon"
    1094="La Orden Ebano"; 1119="Kirin Tor"; 1120="La Mano de la Venganza"
    1124="Los Susurros del Dios Oscuro"; 1126="Alianza de Punta Arpon"
    1158="La Cruzada Escarlata"
}

Function Obtener-NombreFaccion($id) {
    $idInt = [int]$id
    if ($Global:ArmeriaFacciones.ContainsKey($idInt)) { return $Global:ArmeriaFacciones[$idInt] }
    return "Faccion $id"
}

# ==========================================
# MÓDULO: REPUTACIONES
# ==========================================

$Global:ArmeriaReputacionGrupos = @(
    @{ Nombre="Ciudades de la Alianza"; Facciones=@(
        @{Id=72;  Nombre="Stormwind"}, @{Id=47;  Nombre="Ironforge"}, @{Id=69;  Nombre="Darnassus"},
        @{Id=54;  Nombre="Gnomeregan Exiles"}, @{Id=930; Nombre="Exodar"}
    )},
    @{ Nombre="Ciudades de la Horda"; Facciones=@(
        @{Id=76;  Nombre="Orgrimmar"}, @{Id=68;  Nombre="Undercity"}, @{Id=81;  Nombre="Thunder Bluff"},
        @{Id=530; Nombre="Darkspear Trolls"}, @{Id=911; Nombre="Silvermoon City"}
    )},
    @{ Nombre="Fuerzas de Batalla"; Facciones=@(
        @{Id=890; Nombre="Silverwing Sentinels"}, @{Id=509; Nombre="The League of Arathor"},
        @{Id=730; Nombre="Stormpike Guard"}, @{Id=889; Nombre="Warsong Outriders"},
        @{Id=510; Nombre="The Defilers"}, @{Id=729; Nombre="Frostwolf Clan"}
    )},
    @{ Nombre="Neutrales (Classic)"; Facciones=@(
        @{Id=529; Nombre="Argent Dawn"}, @{Id=87;  Nombre="Bloodsail Buccaneers"},
        @{Id=609; Nombre="Cenarion Circle"}, @{Id=909; Nombre="Darkmoon Faire"},
        @{Id=92;  Nombre="Gelkis Clan Centaur"}, @{Id=749; Nombre="Hydraxian Waterlords"},
        @{Id=93;  Nombre="Magram Clan Centaur"}, @{Id=349; Nombre="Ravenholdt"},
        @{Id=809; Nombre="Shen'dralar"}, @{Id=70;  Nombre="Syndicate"},
        @{Id=59;  Nombre="Thorium Brotherhood"}, @{Id=576; Nombre="Timbermaw Hold"},
        @{Id=589; Nombre="Wintersaber Trainers"}, @{Id=270; Nombre="Zandalar Tribe"},
        @{Id=910; Nombre="Brood of Nozdormu"}
    )},
    @{ Nombre="Steamwheedle Cartel"; Facciones=@(
        @{Id=21;  Nombre="Booty Bay"}, @{Id=577; Nombre="Everlook"},
        @{Id=369; Nombre="Gadgetzan"}, @{Id=470; Nombre="Ratchet"}
    )},
    @{ Nombre="TBC - Outland / Shattrath"; Facciones=@(
        @{Id=946;  Nombre="Honor Hold"}, @{Id=947;  Nombre="Thrallmar"},
        @{Id=942;  Nombre="Cenarion Expedition"}, @{Id=978;  Nombre="Kurenai"},
        @{Id=941;  Nombre="The Mag'har"}, @{Id=933;  Nombre="The Consortium"},
        @{Id=970;  Nombre="Sporeggar"}, @{Id=1011; Nombre="Lower City"},
        @{Id=935;  Nombre="The Sha'tar"}, @{Id=932;  Nombre="The Aldor"},
        @{Id=934;  Nombre="The Scryers"}, @{Id=1012; Nombre="Ashtongue Deathsworn"},
        @{Id=1031; Nombre="Sha'tari Skyguard"}, @{Id=989;  Nombre="Keepers of Time"},
        @{Id=967;  Nombre="The Violet Eye"}, @{Id=990;  Nombre="The Scale of the Sands"},
        @{Id=1015; Nombre="Netherwing"}, @{Id=1038; Nombre="Ogri'la"},
        @{Id=1077; Nombre="Shattered Sun Offensive"}, @{Id=922;  Nombre="Tranquillien"}
    )},
    @{ Nombre="WotLK - Alianza"; Facciones=@(
        @{Id=1037; Nombre="Alliance Vanguard"}, @{Id=1068; Nombre="Explorers' League"},
        @{Id=1126; Nombre="The Frostborn"}, @{Id=1094; Nombre="The Silver Covenant"},
        @{Id=1050; Nombre="Valiance Expedition"}
    )},
    @{ Nombre="WotLK - Horda"; Facciones=@(
        @{Id=1052; Nombre="Horde Expedition"}, @{Id=1067; Nombre="The Hand of Vengeance"},
        @{Id=1064; Nombre="The Taunka"}, @{Id=1124; Nombre="The Sunreavers"},
        @{Id=1085; Nombre="Warsong Offensive"}
    )},
    @{ Nombre="WotLK - Neutrales"; Facciones=@(
        @{Id=1106; Nombre="Argent Crusade"}, @{Id=1073; Nombre="The Kalu'ak"},
        @{Id=1090; Nombre="Kirin Tor"}, @{Id=1098; Nombre="Knights of the Ebon Blade"},
        @{Id=1119; Nombre="The Sons of Hodir"}, @{Id=1091; Nombre="The Wyrmrest Accord"},
        @{Id=1156; Nombre="The Ashen Verdict"}
    )},
    @{ Nombre="Cuenca de Sholazar (excluyentes)"; Facciones=@(
        @{Id=1104; Nombre="Frenzyheart Tribe"}, @{Id=1105; Nombre="The Oracles"}
    )}
)

# Mapa plano id -> nombre, para lookups rápidos
$Global:ArmeriaReputacionesFlat = @{}
foreach ($grupoRep in $Global:ArmeriaReputacionGrupos) {
    foreach ($facRep in $grupoRep.Facciones) {
        $Global:ArmeriaReputacionesFlat[[int]$facRep.Id] = $facRep.Nombre
    }
}

# Devuelve nombre del nivel de reputacion, color, y limites (min/max) del tramo actual segun el valor "standing"
Function Obtener-EstandingReputacion($valor) {
    $v = [int]$valor
    if     ($v -ge 42000) { $nombre="Exaltada";   $min=42000; $max=42000; $color=[System.Drawing.Color]::FromArgb(190, 90, 220) }
    elseif ($v -ge 21000) { $nombre="Venerada";   $min=21000; $max=41999; $color=[System.Drawing.Color]::FromArgb(60, 170, 220) }
    elseif ($v -ge 9000)  { $nombre="Honorable";  $min=9000;  $max=20999; $color=[System.Drawing.Color]::FromArgb(40, 170, 80)  }
    elseif ($v -ge 3000)  { $nombre="Amistosa";   $min=3000;  $max=8999;  $color=[System.Drawing.Color]::FromArgb(80, 200, 80)  }
    elseif ($v -ge 0)     { $nombre="Neutral";    $min=0;     $max=2999;  $color=[System.Drawing.Color]::FromArgb(220, 220, 90) }
    elseif ($v -ge -3000) { $nombre="Poco amistosa"; $min=-3000; $max=-1;    $color=[System.Drawing.Color]::FromArgb(230, 150, 20) }
    elseif ($v -ge -6000) { $nombre="Hostil";     $min=-6000; $max=-3001; $color=[System.Drawing.Color]::FromArgb(230, 80, 40)  }
    else                   { $nombre="Odiada";     $min=-42000;$max=-6001; $color=[System.Drawing.Color]::FromArgb(200, 20, 20)  }

    if ($nombre -eq "Exaltada") {
        $pct = 100
        $textoProgreso = "$v (Exaltada)"
    } else {
        $rango = ($max - $min + 1)
        $pct = [math]::Max(0, [math]::Min(100, [math]::Round((($v - $min) / $rango) * 100)))
        $textoProgreso = "$($v - $min) / $rango"
    }

    return [PSCustomObject]@{
        Nombre = $nombre
        Color  = $color
        Min    = $min
        Max    = $max
        Pct    = $pct
        Texto  = $textoProgreso
        Valor  = $v
    }
}

# Ventana de reputaciones de un personaje
Function Mostrar-VentanaReputaciones($guidChar, $nombreChar, $formPadre) {
    $fNormalR = New-Object System.Drawing.Font("Georgia", 9)
    $fBoldR   = New-Object System.Drawing.Font("Georgia", 9.5, [System.Drawing.FontStyle]::Bold)
    $fPeqR    = New-Object System.Drawing.Font("Georgia", 8)
    $fSecR    = New-Object System.Drawing.Font("Georgia", 8.5, [System.Drawing.FontStyle]::Bold)

    $repForm = New-Object System.Windows.Forms.Form
    $repForm.Text = "Reputaciones de $nombreChar"
    $repForm.Size = New-Object System.Drawing.Size(480, 720)
    $repForm.StartPosition = 'CenterParent'
    $repForm.BackColor = [System.Drawing.Color]::FromArgb(15, 12, 10)
    $repForm.ForeColor = [System.Drawing.Color]::FromArgb(230, 210, 180)
    $repForm.FormBorderStyle = 'FixedDialog'
    $repForm.MaximizeBox = $false
    $repForm.MinimizeBox = $false

    $lblTituloRep = New-Object System.Windows.Forms.Label
    $lblTituloRep.Text      = "Reputaciones - $nombreChar"
    $lblTituloRep.Location  = New-Object System.Drawing.Point(10, 10)
    $lblTituloRep.Size      = New-Object System.Drawing.Size(440, 24)
    $lblTituloRep.Font      = New-Object System.Drawing.Font("Georgia", 13, [System.Drawing.FontStyle]::Bold)
    $lblTituloRep.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $repForm.Controls.Add($lblTituloRep)

    $lblAvisoRep = New-Object System.Windows.Forms.Label
    $lblAvisoRep.Text      = "Las facciones sin registro se muestran como Neutral (valor por defecto)."
    $lblAvisoRep.Location  = New-Object System.Drawing.Point(10, 38)
    $lblAvisoRep.Size      = New-Object System.Drawing.Size(440, 16)
    $lblAvisoRep.Font      = New-Object System.Drawing.Font("Georgia", 7, [System.Drawing.FontStyle]::Italic)
    $lblAvisoRep.ForeColor = [System.Drawing.Color]::FromArgb(180, 160, 120)
    $repForm.Controls.Add($lblAvisoRep)

    $panelRep = New-Object System.Windows.Forms.Panel
    $panelRep.Location   = New-Object System.Drawing.Point(10, 60)
    $panelRep.Size       = New-Object System.Drawing.Size(444, 610)
    $panelRep.BackColor  = [System.Drawing.Color]::FromArgb(20, 18, 15)
    $panelRep.AutoScroll = $true
    $repForm.Controls.Add($panelRep)

    $tooltipRep = New-Object System.Windows.Forms.ToolTip
    $tooltipRep.AutoPopDelay = 8000; $tooltipRep.InitialDelay = 300; $tooltipRep.ReshowDelay = 150; $tooltipRep.ShowAlways = $true

    # Consulta de reputacion del personaje
    $repMap = @{}
    try {
        $repRaw = Consulta-Armeria "SELECT CONCAT(faction,'|',standing) FROM character_reputation WHERE guid=$guidChar;" "acore_characters"
        foreach ($lineaRep in $repRaw) {
            $pr = $lineaRep -split "\|"
            if ($pr.Count -lt 2) { continue }
            $repMap[[int]$pr[0].Trim()] = [int]$pr[1].Trim()
        }
    } catch {
        $lblTituloRep.Text = "Error al consultar reputaciones"
    }

    $BAR_W = 400
    $y = 4
    foreach ($grupo in $Global:ArmeriaReputacionGrupos) {
        $lblGrupo = New-Object System.Windows.Forms.Label
        $lblGrupo.Text      = "── $($grupo.Nombre) ──"
        $lblGrupo.Location  = New-Object System.Drawing.Point(5, $y)
        $lblGrupo.Size      = New-Object System.Drawing.Size($BAR_W, 18)
        $lblGrupo.Font      = $fSecR
        $lblGrupo.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
        $lblGrupo.TextAlign = 'MiddleCenter'
        $panelRep.Controls.Add($lblGrupo)
        $y += 22

        foreach ($fac in $grupo.Facciones) {
            $idFac  = [int]$fac.Id
            $valorRep = if ($repMap.ContainsKey($idFac)) { $repMap[$idFac] } else { 0 }
            $est = Obtener-EstandingReputacion $valorRep

            $lblNombreFac = New-Object System.Windows.Forms.Label
            $lblNombreFac.Text      = $fac.Nombre
            $lblNombreFac.Location  = New-Object System.Drawing.Point(5, $y)
            $lblNombreFac.Size      = New-Object System.Drawing.Size(230, 16)
            $lblNombreFac.Font      = $fPeqR
            $lblNombreFac.ForeColor = [System.Drawing.Color]::FromArgb(230, 220, 200)
            $panelRep.Controls.Add($lblNombreFac)

            $lblEstandingFac = New-Object System.Windows.Forms.Label
            $lblEstandingFac.Text      = $est.Nombre
            $lblEstandingFac.Location  = New-Object System.Drawing.Point(235, $y)
            $lblEstandingFac.Size      = New-Object System.Drawing.Size(170, 16)
            $lblEstandingFac.Font      = New-Object System.Drawing.Font("Georgia", 8, [System.Drawing.FontStyle]::Bold)
            $lblEstandingFac.ForeColor = $est.Color
            $lblEstandingFac.TextAlign = 'MiddleRight'
            $panelRep.Controls.Add($lblEstandingFac)
            $y += 18

            $barFondoRep = New-Object System.Windows.Forms.Panel
            $barFondoRep.Location  = New-Object System.Drawing.Point(5, $y)
            $barFondoRep.Size      = New-Object System.Drawing.Size($BAR_W, 8)
            $barFondoRep.BackColor = [System.Drawing.Color]::FromArgb(35, 30, 25)
            $panelRep.Controls.Add($barFondoRep)

            $anchoRep = [math]::Max(2, [int]($BAR_W * $est.Pct / 100))
            $barRellRep = New-Object System.Windows.Forms.Panel
            $barRellRep.Location  = New-Object System.Drawing.Point(0, 0)
            $barRellRep.Size      = New-Object System.Drawing.Size($anchoRep, 8)
            $barRellRep.BackColor = $est.Color
            $barFondoRep.Controls.Add($barRellRep)

            $tipRep = "$($fac.Nombre)`n$($est.Nombre): $($est.Texto)  ($($est.Pct)%)"
            $tooltipRep.SetToolTip($barFondoRep, $tipRep)
            $tooltipRep.SetToolTip($barRellRep, $tipRep)
            $tooltipRep.SetToolTip($lblNombreFac, $tipRep)
            $tooltipRep.SetToolTip($lblEstandingFac, $tipRep)

            $y += 16
        }
        $y += 6
    }

    $repForm.ShowDialog($formPadre) | Out-Null
}

# ==========================================
# MÓDULO: LOGROS
# ==========================================

# Ventana con los últimos logros completados de un personaje
# Detecta automáticamente la tabla y columnas de logros en acore_world,
# ya que el nombre exacto varía según la versión del dump/extractor usado.
Function Obtener-EsquemaLogros {
    if ($Global:ArmeriaLogrosSchema) { return $Global:ArmeriaLogrosSchema }

    try {
        $tablaRaw = Consulta-ArmeriaWorld "SELECT table_name FROM information_schema.tables WHERE table_schema='acore_world' AND table_name IN ('achievement_dbc','achievement') ORDER BY FIELD(table_name,'achievement_dbc','achievement') LIMIT 1;"
        if (-not $tablaRaw -or $tablaRaw.Count -eq 0) {
            $Global:ArmeriaLogrosSchema = [PSCustomObject]@{ Tabla=$null }
            return $Global:ArmeriaLogrosSchema
        }
        $tabla = $tablaRaw[0].Trim()

        $colsRaw = Consulta-ArmeriaWorld "SELECT column_name FROM information_schema.columns WHERE table_schema='acore_world' AND table_name='$tabla';"
        $cols = @($colsRaw | ForEach-Object { $_.Trim() })

        $colId = $cols | Where-Object { $_ -match '^(?i)ID$' } | Select-Object -First 1
        if (-not $colId) { $colId = "ID" }

        $colTituloEs = $cols | Where-Object { $_ -match '(?i)^title.*es' } | Select-Object -First 1
        $colTituloEn = $cols | Where-Object { $_ -match '(?i)^title.*en' } | Select-Object -First 1
        if (-not $colTituloEs) { $colTituloEs = $cols | Where-Object { $_ -match '(?i)^name.*es' } | Select-Object -First 1 }
        if (-not $colTituloEn) { $colTituloEn = $cols | Where-Object { $_ -match '(?i)^name.*en' } | Select-Object -First 1 }
        if (-not $colTituloEs -and -not $colTituloEn) {
            $colTituloEs = $cols | Where-Object { $_ -match '(?i)^(title|name)$' } | Select-Object -First 1
        }

        $colPuntos = $cols | Where-Object { $_ -match '(?i)^points$' } | Select-Object -First 1

        $Global:ArmeriaLogrosSchema = [PSCustomObject]@{
            Tabla       = $tabla
            ColId       = $colId
            ColTituloEs = $colTituloEs
            ColTituloEn = $colTituloEn
            ColPuntos   = $colPuntos
        }
    } catch {
        $Global:ArmeriaLogrosSchema = [PSCustomObject]@{ Tabla=$null }
    }
    return $Global:ArmeriaLogrosSchema
}

# ==========================================
# Dataset local de logros (WotLK 3.3.5.12340), incrustado en el script.
# Origen: DBC oficial del cliente (Achievement.dbc), vía azerothcore-armory.
# Evita depender de que achievement_dbc esté poblada en la BD, o de Wowhead
# (que no soporta logros via su API XML).
# Formato JSON comprimido (gzip) y en base64: { "id": {"es":..,"en":..,"p":puntos}, ... }
# ==========================================
$Global:ArmeriaLogrosDataB64 = "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"

Function Obtener-DatosLogrosLocal {
    if ($Global:ArmeriaLogrosData) { return $Global:ArmeriaLogrosData }
    $tabla = @{}
    try {
        $bytes = [Convert]::FromBase64String($Global:ArmeriaLogrosDataB64)
        $msIn = New-Object System.IO.MemoryStream(,$bytes)
        $gz = New-Object System.IO.Compression.GZipStream($msIn, [System.IO.Compression.CompressionMode]::Decompress)
        $msOut = New-Object System.IO.MemoryStream
        $gz.CopyTo($msOut)
        $gz.Close()
        $msIn.Close()
        $json = [System.Text.Encoding]::UTF8.GetString($msOut.ToArray())
        $obj = $json | ConvertFrom-Json

        foreach ($prop in $obj.PSObject.Properties) {
            $tabla[[int]$prop.Name] = $prop.Value
        }
    } catch {
        $tabla = @{}
    }
    $Global:ArmeriaLogrosData = $tabla
    return $Global:ArmeriaLogrosData
}

# ==========================================
# Dataset local de encantamientos/gemas (SpellItemEnchantment.dbc, WotLK 3.3.5.12340),
# incrustado igual que el de logros. Evita depender de que spellitemenchantment_dbc
# esté poblada en tu BD (viene vacía por defecto en la mayoría de repacks).
# ==========================================
$Global:ArmeriaEncantosDataB64 = "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"

Function Obtener-DatosEncantosLocal {
    if ($Global:ArmeriaEncantosData) { return $Global:ArmeriaEncantosData }
    $tabla = @{}
    try {
        $bytes = [Convert]::FromBase64String($Global:ArmeriaEncantosDataB64)
        $msIn = New-Object System.IO.MemoryStream(,$bytes)
        $gz = New-Object System.IO.Compression.GZipStream($msIn, [System.IO.Compression.CompressionMode]::Decompress)
        $msOut = New-Object System.IO.MemoryStream
        $gz.CopyTo($msOut)
        $gz.Close()
        $msIn.Close()
        $json = [System.Text.Encoding]::UTF8.GetString($msOut.ToArray())
        $obj = $json | ConvertFrom-Json

        foreach ($prop in $obj.PSObject.Properties) {
            $tabla[[int]$prop.Name] = $prop.Value
        }
    } catch {
        $tabla = @{}
    }
    $Global:ArmeriaEncantosData = $tabla
    return $Global:ArmeriaEncantosData
}

# Devuelve el nombre (es con fallback a en) de un encantamiento/gema por su ID.
# Prioriza el dataset local incrustado; si no está ahí, intenta la BD (spellitemenchantment_dbc).
Function Obtener-NombreEncanto($enchId) {
    $datos = Obtener-DatosEncantosLocal
    if ($datos -and $datos.ContainsKey([int]$enchId)) {
        $e = $datos[[int]$enchId]
        if ($e.es) { return $e.es }
        if ($e.en) { return $e.en }
    }
    try {
        $bd = (Consulta-ArmeriaWorld "SELECT IFNULL(Name_Lang_esES, Name_Lang_enUS) FROM spellitemenchantment_dbc WHERE ID=$enchId;")[0]
        if ($bd -and $bd.Trim() -ne "") { return $bd.Trim() }
    } catch {}
    return $null
}

Function Mostrar-VentanaLogros($guidChar, $nombreChar, $formPadre) {
    $fNormalL = New-Object System.Drawing.Font("Georgia", 9)
    $fBoldL   = New-Object System.Drawing.Font("Georgia", 10, [System.Drawing.FontStyle]::Bold)
    $fPeqL    = New-Object System.Drawing.Font("Georgia", 8)

    $logForm = New-Object System.Windows.Forms.Form
    $logForm.Text = "Logros de $nombreChar"
    $logForm.Size = New-Object System.Drawing.Size(460, 560)
    $logForm.StartPosition = 'CenterParent'
    $logForm.BackColor = [System.Drawing.Color]::FromArgb(15, 12, 10)
    $logForm.ForeColor = [System.Drawing.Color]::FromArgb(230, 210, 180)
    $logForm.FormBorderStyle = 'FixedDialog'
    $logForm.MaximizeBox = $false
    $logForm.MinimizeBox = $false

    $lblTituloLog = New-Object System.Windows.Forms.Label
    $lblTituloLog.Text      = "Últimos logros - $nombreChar"
    $lblTituloLog.Location  = New-Object System.Drawing.Point(10, 10)
    $lblTituloLog.Size      = New-Object System.Drawing.Size(420, 24)
    $lblTituloLog.Font      = New-Object System.Drawing.Font("Georgia", 13, [System.Drawing.FontStyle]::Bold)
    $lblTituloLog.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $logForm.Controls.Add($lblTituloLog)

    $panelLog = New-Object System.Windows.Forms.Panel
    $panelLog.Location   = New-Object System.Drawing.Point(10, 42)
    $panelLog.Size       = New-Object System.Drawing.Size(424, 470)
    $panelLog.BackColor  = [System.Drawing.Color]::FromArgb(20, 18, 15)
    $panelLog.AutoScroll = $true
    $logForm.Controls.Add($panelLog)

    $lblCargandoLog = New-Object System.Windows.Forms.Label
    $lblCargandoLog.Text      = "Cargando logros..."
    $lblCargandoLog.Location  = New-Object System.Drawing.Point(10, 42)
    $lblCargandoLog.Size      = New-Object System.Drawing.Size(420, 20)
    $lblCargandoLog.Font      = $fPeqL
    $lblCargandoLog.BackColor = [System.Drawing.Color]::FromArgb(20, 18, 15)
    $lblCargandoLog.ForeColor = [System.Drawing.Color]::FromArgb(200, 190, 170)
    $logForm.Controls.Add($lblCargandoLog)
    $lblCargandoLog.BringToFront()

    $tooltipLog = New-Object System.Windows.Forms.ToolTip
    $tooltipLog.AutoPopDelay = 8000; $tooltipLog.InitialDelay = 300; $tooltipLog.ReshowDelay = 150; $tooltipLog.ShowAlways = $true

    $ICON_LOG = 32
    $imgTrofeo = Descargar-IconoUI "achievement_general" $ICON_LOG

    $esquemaLog = Obtener-EsquemaLogros
    $datosLogrosLocal = Obtener-DatosLogrosLocal

    # Mostrar la ventana YA, antes de consultar nada, para que no parezca colgada.
    # Se deshabilita la ventana padre para simular comportamiento modal sin bloquear el hilo de UI.
    if ($formPadre) { $formPadre.Enabled = $false }
    $logForm.Add_FormClosed({ if ($formPadre) { $formPadre.Enabled = $true; $formPadre.Activate() } }.GetNewClosure())
    $logForm.Show($formPadre)
    $logForm.Refresh()
    [System.Windows.Forms.Application]::DoEvents()

    $y = 4
    try {
        $logRaw = Consulta-Armeria "SELECT CONCAT(achievement,'|',date) FROM character_achievement WHERE guid=$guidChar ORDER BY date DESC LIMIT 10;" "acore_characters"

        if (-not $logRaw -or $logRaw.Count -eq 0) {
            $lblCargandoLog.Visible = $false
            $lblSinLogros = New-Object System.Windows.Forms.Label
            $lblSinLogros.Text      = "Este personaje no tiene logros completados."
            $lblSinLogros.Location  = New-Object System.Drawing.Point(5, $y)
            $lblSinLogros.Size      = New-Object System.Drawing.Size(400, 40)
            $lblSinLogros.Font      = $fPeqL
            $lblSinLogros.ForeColor = [System.Drawing.Color]::FromArgb(180, 140, 60)
            $panelLog.Controls.Add($lblSinLogros)
        }

        $numLog = 0
        $totalLog = @($logRaw).Count
        foreach ($lineaLog in $logRaw) {
            $numLog++
            $lblCargandoLog.Text = "Cargando logros ($numLog/$totalLog)..."
            [System.Windows.Forms.Application]::DoEvents()
            $pl = $lineaLog -split "\|"
            if ($pl.Count -lt 2) { continue }
            $achId    = [int]$pl[0].Trim()
            $fechaUnix = [long]$pl[1].Trim()

            $nombreAch  = "Logro #$achId"
            $puntosAch  = 0

            # 1) Fuente principal: dataset local incrustado (offline, cubre WotLK 3.3.5 completo)
            if ($datosLogrosLocal -and $datosLogrosLocal.ContainsKey($achId)) {
                $achLocal = $datosLogrosLocal[$achId]
                if ($achLocal.es) { $nombreAch = $achLocal.es }
                elseif ($achLocal.en) { $nombreAch = $achLocal.en }
                if ($achLocal.p) { $puntosAch = [int]$achLocal.p }
            }

            # 2) Si no está en el dataset local, se intenta la BD (por si tiene datos propios/custom)
            if ($nombreAch -eq "Logro #$achId" -and $esquemaLog -and $esquemaLog.Tabla) {
                $colTitulo = if ($esquemaLog.ColTituloEs -and $esquemaLog.ColTituloEn) {
                    "IFNULL($($esquemaLog.ColTituloEs),$($esquemaLog.ColTituloEn))"
                } elseif ($esquemaLog.ColTituloEs) {
                    $esquemaLog.ColTituloEs
                } elseif ($esquemaLog.ColTituloEn) {
                    $esquemaLog.ColTituloEn
                } else {
                    $null
                }
                $colPuntosSql = if ($esquemaLog.ColPuntos) { "IFNULL($($esquemaLog.ColPuntos),0)" } else { "0" }

                if ($colTitulo) {
                    $datosAch = (Consulta-ArmeriaWorld "SELECT CONCAT($colTitulo,'|',$colPuntosSql) FROM $($esquemaLog.Tabla) WHERE $($esquemaLog.ColId)=$achId;")[0]
                    if ($datosAch) {
                        $pa = $datosAch -split "\|"
                        if ($pa.Count -ge 1 -and $pa[0].Trim() -ne "") { $nombreAch = $pa[0].Trim() }
                        if ($pa.Count -ge 2) { $puntosAch = [int]$pa[1].Trim() }
                    }
                }
            }

            $fechaTexto = try {
                ([System.DateTimeOffset]::FromUnixTimeSeconds($fechaUnix)).LocalDateTime.ToString("dd/MM/yyyy HH:mm")
            } catch { "-" }

            $panelFila = New-Object System.Windows.Forms.Panel
            $panelFila.Location  = New-Object System.Drawing.Point(0, $y)
            $panelFila.Size      = New-Object System.Drawing.Size(404, ($ICON_LOG + 6))
            $panelFila.BackColor = [System.Drawing.Color]::FromArgb(28, 24, 20)
            $panelLog.Controls.Add($panelFila)

            $pbLog = New-Object System.Windows.Forms.PictureBox
            $pbLog.Location  = New-Object System.Drawing.Point(4, 3)
            $pbLog.Size      = New-Object System.Drawing.Size($ICON_LOG, $ICON_LOG)
            $pbLog.SizeMode  = 'StretchImage'
            $pbLog.BackColor = [System.Drawing.Color]::Transparent
            if ($imgTrofeo) { $pbLog.Image = $imgTrofeo }
            $panelFila.Controls.Add($pbLog)

            $lblNombreAch = New-Object System.Windows.Forms.Label
            $lblNombreAch.Text      = $nombreAch
            $lblNombreAch.Location  = New-Object System.Drawing.Point(44, 4)
            $lblNombreAch.Size      = New-Object System.Drawing.Size(300, 16)
            $lblNombreAch.Font      = $fBoldL
            $lblNombreAch.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
            $panelFila.Controls.Add($lblNombreAch)

            $lblFechaAch = New-Object System.Windows.Forms.Label
            $lblFechaAch.Text      = "Completado: $fechaTexto"
            $lblFechaAch.Location  = New-Object System.Drawing.Point(44, 21)
            $lblFechaAch.Size      = New-Object System.Drawing.Size(220, 14)
            $lblFechaAch.Font      = $fPeqL
            $lblFechaAch.ForeColor = [System.Drawing.Color]::FromArgb(200, 190, 170)
            $panelFila.Controls.Add($lblFechaAch)

            $lblPuntosAch = New-Object System.Windows.Forms.Label
            $lblPuntosAch.Text      = "$puntosAch pts"
            $lblPuntosAch.Location  = New-Object System.Drawing.Point(330, 21)
            $lblPuntosAch.Size      = New-Object System.Drawing.Size(70, 14)
            $lblPuntosAch.Font      = $fPeqL
            $lblPuntosAch.ForeColor = [System.Drawing.Color]::FromArgb(100, 180, 255)
            $lblPuntosAch.TextAlign = 'MiddleRight'
            $panelFila.Controls.Add($lblPuntosAch)

            $tipLog = "$nombreAch`nCompletado: $fechaTexto`nPuntos: $puntosAch"
            $tooltipLog.SetToolTip($panelFila, $tipLog)
            $tooltipLog.SetToolTip($lblNombreAch, $tipLog)

            $y += ($ICON_LOG + 10)
        }
    } catch {
        $lblErrorLog = New-Object System.Windows.Forms.Label
        $lblErrorLog.Text      = "Error al consultar logros: $($_.Exception.Message)"
        $lblErrorLog.Location  = New-Object System.Drawing.Point(5, $y)
        $lblErrorLog.Size      = New-Object System.Drawing.Size(400, 60)
        $lblErrorLog.Font      = $fPeqL
        $lblErrorLog.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
        $panelLog.Controls.Add($lblErrorLog)
    }

    $lblCargandoLog.Visible = $false
}


# ==========================================
# MÓDULO: TALENTOS (árbol visual WotLK 3.3.5)
# ==========================================
# Datos de Talent.dbc / TalentTab.dbc (patch 3.3.5.12340), comprimidos.
# Origen: azerothcore-armory (r-o-b-o-t-o).
# Formato: { "tabs": { "tabId": [[talentId,tier,col,maxRank,spellRank1..], ...] },
#           "spells": { "spellId": "talentId|tabId|tier|col|rank|maxRank" } }

$Global:ArmeriaTalentosDataB64 = "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"

# Tabs ordenados por clase (OrderIndex 0,1,2) — ClassMask de TalentTab.dbc
$Global:ArmeriaTalentTabsPorClase = @{
    1  = @(161, 164, 163)   # Guerrero: Armas, Furia, Protección
    2  = @(382, 383, 381)   # Paladín: Sagrado, Protección, Retribución
    3  = @(361, 363, 362)   # Cazador: Dominio de bestias, Puntería, Supervivencia
    4  = @(182, 181, 183)   # Pícaro: Asesinato, Combate, Sutileza
    5  = @(201, 202, 203)   # Sacerdote: Disciplina, Sagrado, Sombras
    6  = @(398, 399, 400)   # Caballero de la Muerte: Sangre, Escarcha, Profano
    7  = @(261, 263, 262)   # Chamán: Elemental, Mejora, Restauración
    8  = @(81,  41,  61)    # Mago: Arcano, Fuego, Escarcha
    9  = @(302, 303, 301)   # Brujo: Aflicción, Demonología, Destrucción
    11 = @(283, 281, 282)   # Druida: Equilibrio, Combate feral, Restauración
}

$Global:ArmeriaTalentTabNombres = @{
    81="Arcano"; 41="Fuego"; 61="Escarcha"
    161="Armas"; 164="Furia"; 163="Protección"
    182="Asesinato"; 181="Combate"; 183="Sutileza"
    201="Disciplina"; 202="Sagrado"; 203="Sombras"
    261="Elemental"; 263="Mejora"; 262="Restauración"
    283="Equilibrio"; 281="Combate feral"; 282="Restauración"
    302="Aflicción"; 303="Demonología"; 301="Destrucción"
    361="Dominio de bestias"; 363="Puntería"; 362="Supervivencia"
    382="Sagrado"; 383="Protección"; 381="Retribución"
    398="Sangre"; 399="Escarcha"; 400="Profano"
}

# Iconos de cabecera por TalentTab (3.3.5)
$Global:ArmeriaTalentTabIconos = @{
    81="spell_holy_magicalsentry"; 41="spell_fire_firebolt02"; 61="spell_frost_frostbolt02"
    161="ability_rogue_eviscerate"; 164="ability_warrior_innerrage"; 163="ability_warrior_defensivestance"
    182="ability_rogue_eviscerate"; 181="ability_backstab"; 183="ability_stealth"
    201="spell_holy_wordfortitude"; 202="spell_holy_holybolt"; 203="spell_shadow_shadowwordpain"
    261="spell_nature_lightning"; 263="ability_shaman_stormstrike"; 262="spell_nature_magicimmunity"
    283="spell_nature_starfall"; 281="ability_racial_bearform"; 282="spell_nature_healingtouch"
    302="spell_shadow_deathcoil"; 303="spell_shadow_metamorphosis"; 301="spell_shadow_rainoffire"
    361="ability_hunter_beasttaming"; 363="ability_marksmanship"; 362="ability_hunter_swiftstrike"
    382="spell_holy_holybolt"; 383="spell_holy_devotionaura"; 381="spell_holy_auraoflight"
    398="spell_deathknight_bloodpresence"; 399="spell_deathknight_frostpresence"; 400="spell_deathknight_unholypresence"
}

# Fondos distintos por especialización
$Global:ArmeriaTalentTabFondos = @{
    81="mage-arcane"; 41="mage-fire"; 61="mage-frost"
    161="warrior-arms"; 164="warrior-fury"; 163="warrior-protection"
    182="rogue-assassination"; 181="rogue-outlaw"; 183="rogue-subtlety"
    201="priest-discipline"; 202="priest-holy"; 203="priest-shadow"
    261="shaman-elemental"; 263="shaman-enhancement"; 262="shaman-restoration"
    283="druid-balance"; 281="druid-feral"; 282="druid-restoration"
    302="warlock-affliction"; 303="warlock-demonology"; 301="warlock-destruction"
    361="hunter-beast-mastery"; 363="hunter-marksmanship"; 362="hunter-survival"
    382="paladin-holy"; 383="paladin-protection"; 381="paladin-retribution"
    398="death-knight-blood"; 399="death-knight-frost"; 400="death-knight-unholy"
}

Function Descargar-FondoTalento($tabId, $ancho, $alto) {
    try {
        if (-not $Global:ArmeriaTalentTabFondos.ContainsKey([int]$tabId)) { return $null }
        $slug = $Global:ArmeriaTalentTabFondos[[int]$tabId]
        if (-not $slug -or -not $Global:RootDir) { return $null }
        $cacheDir = Join-Path $Global:RootDir "Armeria\Imagenes\talent_bg"
        if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force -ErrorAction SilentlyContinue | Out-Null }
        $cacheFile = Join-Path $cacheDir ("$slug.jpg")
        if (-not (Test-Path -LiteralPath $cacheFile)) {
            $url = "https://wow.zamimg.com/images/tools/dragonflight-talent-calc/blizzard/talentbg-$slug.jpg"
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent", "Mozilla/5.0")
            $bytes = $wc.DownloadData($url)
            if ($bytes -and $bytes.Length -gt 1000) { [System.IO.File]::WriteAllBytes($cacheFile, $bytes) } else { return $null }
        }
        $img = [System.Drawing.Image]::FromFile($cacheFile)
        $w = if ($ancho -gt 0) { [int]$ancho } else { $img.Width }
        $h = if ($alto -gt 0) { [int]$alto } else { $img.Height }
        $bmp = New-Object System.Drawing.Bitmap $w, $h
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($img, 0, 0, $w, $h)
        $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 10, 8, 6))
        $g.FillRectangle($brush, 0, 0, $w, $h)
        $brush.Dispose(); $g.Dispose(); $img.Dispose()
        return $bmp
    } catch { return $null }
}

Function Descargar-FondoPvP($ancho, $alto) {
    try {
        if (-not $Global:RootDir) { return $null }
        $cacheDir = Join-Path $Global:RootDir "Armeria\Imagenes\pvp_bg"
        if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force -ErrorAction SilentlyContinue | Out-Null }
        $cacheFile = Join-Path $cacheDir "pvp_arena_bg.jpg"
        if (-not (Test-Path -LiteralPath $cacheFile)) {
            $url = "https://wow.zamimg.com/images/tools/dragonflight-talent-calc/blizzard/talentbg-warrior-fury.jpg"
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent", "Mozilla/5.0")
            $bytes = $wc.DownloadData($url)
            if ($bytes -and $bytes.Length -gt 1000) { [System.IO.File]::WriteAllBytes($cacheFile, $bytes) } else { return $null }
        }
        $img = [System.Drawing.Image]::FromFile($cacheFile)
        $w = if ($ancho -gt 0) { [int]$ancho } else { 460 }
        $h = if ($alto -gt 0) { [int]$alto } else { 530 }
        $bmp = New-Object System.Drawing.Bitmap $w, $h
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($img, 0, 0, $w, $h)
        $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(150, 8, 6, 5))
        $g.FillRectangle($brush, 0, 0, $w, $h)
        $brush.Dispose(); $g.Dispose(); $img.Dispose()
        return $bmp
    } catch { return $null }
}

Function Obtener-EspecializacionPersonaje($guidChar, $claseId) {
    # Devuelve "Nombre|TabId|Fuente|Distribucion"
    # Fuente: talentos-sesion | talentos-disco | calculo
    try {
        $g = [string]$guidChar

        # A) Calculo en vivo (siempre)
        $calcNombre = $null; $calcTab = 0; $calcDist = ""
        try {
            $info = Armeria-ObtenerPrimarySpecInfo $guidChar $claseId
            if ($info -and $info.TabId) {
                $calcNombre = [string]$info.Nombre
                $calcTab = [int]$info.TabId
                try { $calcDist = [string]$info.Distribucion } catch { $calcDist = "" }
            }
        } catch {}

        # B) Cache de la ventana Talentos (sesion)
        $sesNombre = $null; $sesTab = 0
        if ($script:ArmeriaSpecDetectada -and [string]$script:ArmeriaSpecDetectada.Guid -eq $g) {
            try {
                $sesNombre = [string]$script:ArmeriaSpecDetectada.Nombre
                $sesTab = [int]$script:ArmeriaSpecDetectada.TabId
            } catch {}
        }

        # C) Cache en disco
        $diskNombre = $null; $diskTab = 0
        try {
            if ($Global:RootDir) {
                $dirC = Join-Path $Global:RootDir "Armeria\Cache"
                $fc = Join-Path $dirC ("spec_{0}.txt" -f $g)
                if (Test-Path -LiteralPath $fc) {
                    $raw = (Get-Content -LiteralPath $fc -Raw -ErrorAction SilentlyContinue)
                    if ($raw) {
                        $raw = $raw.Trim()
                        if ($raw.Contains("|")) {
                            $pp = $raw -split "\|"
                            $diskNombre = $pp[0].Trim()
                            try { $diskTab = [int]$pp[1].Trim() } catch { $diskTab = 0 }
                        }
                    }
                }
            }
        } catch {}

        # Prioridad: sesion talentos > disco (escrito por ventana Talentos) > calculo
        $nombre = $null; $tabId = 0; $fuente = "ninguno"
        if ($sesTab -gt 0 -and $sesNombre) {
            $nombre = $sesNombre; $tabId = $sesTab; $fuente = "talentos-sesion"
        } elseif ($diskTab -gt 0 -and $diskNombre) {
            $nombre = $diskNombre; $tabId = $diskTab; $fuente = "talentos-disco"
        } elseif ($calcTab -gt 0 -and $calcNombre) {
            $nombre = $calcNombre; $tabId = $calcTab; $fuente = "calculo"
        }

        # Si hay calculo y no hay cache de talentos, persistir calculo para depurar
        try {
            if ($Global:RootDir -and $calcTab -gt 0) {
                $dirC = Join-Path $Global:RootDir "Armeria\Cache"
                if (-not (Test-Path $dirC)) { New-Item -ItemType Directory -Path $dirC -Force -ErrorAction SilentlyContinue | Out-Null }
                $fc = Join-Path $dirC ("spec_{0}.txt" -f $g)
                # Solo escribir si no hay cache de talentos, o actualizar linea de debug
                $fcDbg = Join-Path $dirC ("spec_{0}.debug.txt" -f $g)
                $dbg = @(
                    "guid=$g"
                    "calc=$calcNombre|$calcTab dist=$calcDist"
                    "sesion=$sesNombre|$sesTab"
                    "disco=$diskNombre|$diskTab"
                    "elegido=$nombre|$tabId fuente=$fuente"
                ) -join "`r`n"
                Set-Content -LiteralPath $fcDbg -Value $dbg -Encoding UTF8
                # NUNCA pisar una cache de talentos con un calculo debil
                $puedeEscribir = $false
                if ($fuente -eq "talentos-sesion") { $puedeEscribir = $true }
                elseif ($fuente -eq "calculo") {
                    $tot = 0
                    try { if ($info -and $info.Total) { $tot = [int]$info.Total } } catch {}
                    if ($tot -ge 20) { $puedeEscribir = $true }
                    # Si no hay disco previo, si escribir para no dejar vacio
                    if (-not $diskTab -or $diskTab -le 0) { $puedeEscribir = $true }
                }
                if ($puedeEscribir -and $nombre -and $tabId -gt 0) {
                    Set-Content -LiteralPath $fc -Value ("{0}|{1}" -f $nombre, $tabId) -Encoding UTF8
                }
            }
        } catch {}

        if (-not $nombre -or $tabId -le 0) { return $null }
        if (-not $calcDist) { $calcDist = "-" }
        return ("{0}|{1}|{2}|{3}" -f $nombre, $tabId, $fuente, $calcDist)
    } catch {
        return $null
    }
}


Function Obtener-DatosTalentosLocal {
    if ($Global:ArmeriaTalentosData) { return $Global:ArmeriaTalentosData }
    $resultado = [PSCustomObject]@{ Tabs = @{}; Spells = @{} }
    try {
        $bytes = [Convert]::FromBase64String($Global:ArmeriaTalentosDataB64)
        $msIn = New-Object System.IO.MemoryStream(,$bytes)
        $gz = New-Object System.IO.Compression.GZipStream($msIn, [System.IO.Compression.CompressionMode]::Decompress)
        $msOut = New-Object System.IO.MemoryStream
        $gz.CopyTo($msOut)
        $gz.Close(); $msIn.Close()
        $json = [System.Text.Encoding]::UTF8.GetString($msOut.ToArray())
        $obj = $json | ConvertFrom-Json
        $tabs = @{}
        foreach ($prop in $obj.tabs.PSObject.Properties) {
            $lista = @()
            foreach ($row in $prop.Value) {
                $arr = @($row)
                if ($arr.Count -lt 4) { continue }
                $ranks = @()
                for ($i = 4; $i -lt $arr.Count; $i++) {
                    $sid = 0
                    try { $sid = [int]$arr[$i] } catch { continue }
                    if ($sid -gt 0) { $ranks += $sid }
                }
                $lista += [PSCustomObject]@{
                    Id   = [int]$arr[0]
                    Tier = [int]$arr[1]
                    Col  = [int]$arr[2]
                    Max  = [int]$arr[3]
                    Ranks = $ranks
                }
            }
            $tabs[[int]$prop.Name] = $lista
        }
        $spells = @{}
        foreach ($prop in $obj.spells.PSObject.Properties) {
            $spells[[int]$prop.Name] = [string]$prop.Value
        }
        $resultado = [PSCustomObject]@{ Tabs = $tabs; Spells = $spells }
    } catch {
        $resultado = [PSCustomObject]@{ Tabs = @{}; Spells = @{} }
    }
    $Global:ArmeriaTalentosData = $resultado
    return $Global:ArmeriaTalentosData
}


# Mapa spellId -> nombre + icono (desde Spell.dbc + SpellIcon.dbc del armory)
# Permite cargar iconos desde ZAM sin consultar Wowhead.
$Global:ArmeriaTalentSpellsB64 = "H4sIAP5dfGoC/7V92ZbbOLLtr2j1S7+c7iXO5HnzWK7ucpWP011e977kgihIYiVFqjlkWnXW/fcbgYGASDAzCbBfymUTe5MiMQQCETv+9y+JH/7lv//3L9Vf/vsvvxTHU/dEy/Iv//WXAv7eXuD/7091eb1v+/O5rsqhwf/7r79kyQD8QJrutLk7FbTc32Ar0vUNvW8fiqo+UGyFSC/wMwn93HdFSToqYGRXlEV3vW/qYw+4E9nXT23XFA+0RWQQq5u+LUn+sHnTNPXTzT056P5Ciqq9ABBxUZRsJe7nqqV5t7l7Is3Z9LAFu96yywjN/EBCP8Gr2Hypn2gzfUMX9s8cEC4FREsB8UJA5EvAtxO8sKI6bu4uNC9IWfxJuqKujO+/E23b26b48UPF+HtR7YtcZ9Ge4VG7yHHD2/xXdcUOg8/ykRTQNSbgfmhxYA1Yr8uGvvPhSjeHutmQagP/O4XTK4XLpII/WbfbbuOhF7BXtvm5OvSt8bnZuyvkZUR723i488/nS1M/0v3mY9HQHRmNmAP84/2hJGe6q8tOgLUOOICbuu1Ykxs0/iv/L17b+pLAkwQcV3R0Dgddt24kLDU+9AaGT9sZHlv+II5Ot07o4Vu/7ZuKdbq6L80wAcmGsfMZfjytxKzSmkH6D82iyaPe5XWTn6bQFp5iB0/EkdAvhjeLH20jh4jxo8on9baBdj+SG97GmXa0btqu5jMJYoaP8b1uyv2mqDbslu1o+J3Jkd4/YRPogrwBJ/ACbfpru8138mjq+D/whxft+V72Hs8b3s67puhgRJabz6RtTRPgU9FeTpSUEql6/bGadLqCzZh5UdEGZ3EO8bfLIcN3Z/1rOqNxGKxC5TCZIGx4uHf1ede3k0mIf2/4NfVB9TIvGsbSl4LCm4Ke+XNOnxuGAqgmEDYIN+9OpKpoOeksDNx2vXxONfrvTqTrxr9N3as91fmDBA3f7AttzoRdN+DwewmEGq7fiwru8tcWnrAYT08MleO/w3Pv2EgW8OkQeguz/p+k2RsYipzqfTvNbl/Nd0CZ3wv77xOScmQ2nWTe1RXd1Af4szTd+ghrf0HFyPe3yYDPKUwYwNzOPO9puKvvDXd90+SwSGzu+l1X0u46HU/7Av8Cg7LIJTgYgeGBc1p1zXQZFPbImVREzTm+748IPtZ53xpuTR9r1d/9YAz7DOur6Xb5icgv4wfJ+Jd2YqIxGmuwfByGOdwPhzveYauNYbLT5o32UtZ7KqHDfT/jq9u86WBA0DO8JhOcwDAr2pP+lqPxr+WLwbhXiZ+8h+k2hy/YtrhyPxZtIX6kIIsMvazHUcJY5jrMMByDeDC6vlybevf8CignXrBYLSfeIE4tkaEyD3FAvCVNU4xmHPhp97iuVGLoZ5G6GQy5zV1FLsapBueCM2n4O/G34fgLTSdu8Yhs74A2gEQOI+hLQ1sKowfH+6Q7CzRch5lWM2x8Lx4Ivj3Vf/tEqj180e+UXOrKbNtCn7gnP+j9NuMMfjqsAnew1u7nUS1evvcTifMnPekTbWro4Xdsq2K0pQkuTyfJoKwcglPW3I3PcPV+60mUoQfDMD+Ob/iEH7xu2BxwpBIcT8Bf6fCyJfRY9wqRTBDfTj285mbzrhy6h0R2/FKOVwR+ai5/ImfczQ3jV4LZMHtCW4ZDDSvCb4+0uWidS32XbSRRw3d5TwlsSL/DdGKeKOAqm8UETrM5mw6GmfEzyrfakkewznYlbDsFfPgs34BTjlOYV66v68l+NnyaN9UR3u5nWCqO03mSrQc7nN/gBdYHmKfPRUUkh5rjK3iG4jJdiMQDnAvYMjcFmpgSmyrjBOfXZwYCu36/jSVy+MTfoOOcKtq+tIT5gbK2f25gqH4fmydsAWAWsPaOgq1nME3qet+QSfdvCD48vCl5WTAMv/JLX+X4KuY+MOvIAuUN9/2JHDe/NfuhA05g7N3siBzkgTedJt4XLXwaMLsmFv8ty5Ncf4ElMLEo38WYYM8vCvDQKz5U2pu6GQ19hV/p0NDqz6uEaYvBGQwXtkeX07SpTx3QeKH7M87egkJZg2XfDENhmGdOsAW7uafaM7xrelp2V+MsSmFZz9W+AWDD93lb12d8zt9hIjY+5KUfZsNAmV//qnZNsS9x7QDak9kiAmsUJranru6ofLXKKzRsIT7VT+XsfNPmsF0dwOH0o1Lo7Djm2DYZXk8384Hhz7wZ3poauk+UXhhWuMuMDrUS3s0e34+AT6fodyVVe8rJisIvcnAwnaTvwKaY65cwpbTFI+XePEmRWntUAJw5gMOtC9hzAWdOPgA/iLauBN5CtwxAguUuEkAlS10kgEmXY5SPa4HzwA8yS1hmAws1L9MSWBxYb94AHLqAE8udH0Aza2iiVs38uvmdFpVpL5/DJuWEBwp0L3GBk3/VDw3m7mudHwBOXcCZi//DD938J4CPLTzLAEtsYNF2u9iFASDPBuTbgAILkDKYlrgFAZfZ4dT4ep1n0I/U6cGrEaGTiwsIIleC2JUgcSTIfGsfIYBTJ4eTH2+j1dxfQBY7OeP8OEoXOhDiOHD0k8Rx6MwQOTkx4jh2xKe2TpBYXwlf69YGVOzmjYjVoLEkyBJ7N1Wy1U5oYbPxg77gy4slzrPwqCVqhViECqxQNj6/RPkfLL2ciXJD2DKo3epC/1CiAhsWI2NrZGKLVBurxT60RO2pLLC+Azawx8beYu9dEvsWmMACEy7HKH/+srlDhSksxIWWuMgOZ5hYv9JHWs3OrI24KuCZCzzdBiu4M9NtaO/OTLfaaX+V9y3G5qAb+Mm8DCunS6oOexc4f1M1+S5C+VbHSqny9C7EhZa4yBKXOrri0yBUBzX0svkOVvF+3IN2JH+AjeNOQiIbP2+qfIQLjtn9NNzaweKFcS8ASZZD0uWQbPELV4vSEn98qtajZbDIDhbbwRLX8400cj4iSVUskT2F507hu3rxU+UofHXvSny7YD1ABtbIeJ1DlzRJ1iJK1yLK1iHKoq39gZAWZLwoqg6AgS0wtT2dzaLM4hg6i7dWqMAinCHTAn5fdYSaqUH1WkCwFBAuBQzz+i8YrnrXkZEzlS2j8FXQIc7+EEAVY/PqgEkABRYgZRbbHQUHW+WzsGbwnBl8VwYVkLUs8hqQkUWUAcBiO1hiB0ttYInywcKyimvfJFUCo+FaWHthhrlIkDJLyrqlm//p8aSqaTcYpEw6bcg/MT8Muv6ableSPZXDH0iy5f6iQPP2/CID7mCXdyjpD9qas12Ep7iTv1htQ94jLjdkh1xI0wzNhxf0viclzIizLheJ3kO7J5YqxBkCgy1QVAW6HG/dvDffqim6HqO6W5I3xUGGNABbMNqz4Rt42SQJEsOh/k/MmT3n4AaIr/rUvm/I2OgSj8r/GAKeAWewYS7woJ05aINf4lDNR7WHfkpw87352psD3cSNYVXZ455JGsDAMt2F/7OAGfH29g+FmCSDRJ1v2nYrdchpy5D5iz9QFiyFpGoyXzDsUhv3M6B8K1RghQrd56RUzYYuJPEaJMkKJGrmef3knt4ELr8aFNqAIhtQ6jgf684CSwblDLdm8J0ZFi1jaRQuam6w6O3XrFQdUi5bs1ItJWEhMFm2AGgb9kVLXZpEtkudts1+i8N2Y9xyyP3dpYe3f2L5TCIwO9B2h/wAEwNi3tOcXuZO/1VIR6Dt9D5hnjHsW9AvMqyzE78oILzFCH8xIliMCJcikq3Da0s8F7BaXsi57g/l1KMMnKSUaeSZ5tKpiq6AeeHR2C0P/XlXUgnKLEBaIuwC0PAyPpQ9us0mx1jcXzAK2pAWj76fpV1/ec2pXrhVzs3fLhdY82BgdNeXfT/hVvXGV719AARLAbHL+wi1HOoF70P1yCUg3/Ilqh75vmi66+ZbA3PoeDJuRXgINJ867t7w8JUXIltCU2r2q6H+7UO+p3S0z5fTOZN9aPs87wEu0YELWiXbvOYFeYb0hy910dbVGHIR/ypgoR0ssoPFdrDECqZi/n+h3YmU056Zi3xBzUsfesrYXQaL7GCxHSyxg2krfamOBZ89hgRUZoMKt1YozwrlW6GGzv8VDwFaivMpBvyR6Ug7FPRY7SnZS2xqj1WncV/77oRAbX4f7PSmL/Z4rE/Pu/qJlhKrvmCvufGfzaMBVGaDUqbd8udURp4FdurA+KCOJl9xchl6hn3HYorQncJg1GP3ZNble0M/NSQfAUu8Csv0DO3Djwu6BN4wF/VMaEsBTdTvydw5dDOjwXeFURGwbWknhraXSIi/HBIsh5h8ffuKXvFU0LwNe2DXW7wsOKIVOOIVOJKbLHUWdvJcXjsgMjWflfDPbDozp8g9c8Ydeqnu9TlDB+xmY8ihV7S0HXSDQk1WA7AXMh99Tqqu4P8rkSoKEuzozUfSUfMeqijLru5zYeBpihoLcYElLrTERVY4XzmYvopBOBtaXJZExrCFvjpw/+kEsPL6jLMm72H147hIJad+hj4ET/rmWBhsk1Oxo02lsrcAqJZ9c5+RJ3IlpReJuTnKo+SBwI7ydUfNAFZfsMD+vvlK27p8NAaDYLJDQ4/QajgGDKNAM1TAPm/2tVElrWtI9e9eJRiESTi1Zn+uKtqw1MjpmW+B14YMQ4CnBmMYNbq+w2z23yZxOaXThRMeP+CXZNmzZB9hR1d0/d7wWEh1GC5zNkNQBKbobzB78sUkklALDRbvYxJLJnNvKoyUfJCdJ4mTNX9FvOYLjrMVyQzSaEt6TuK5wX2nr5uEluNFrYevnhoStf69HpNazl1aOPVSYOg2B2kB0rYEqf0Uqp1UWoCzrQvYswen6rGZJqTxsERX9KT8JKJ81D5dqp2xonpmMwMuybWuTgSPGQRO6RAAih1zbD5RMslklB+trqujdNSHmTo9VeifYAs1OWXgTy7bHKEJC3QULMYENfo0ZWjYPwtUppkg7PyEnU8bXxheZjpGl6agQjUtzFRsOaaKbj7TUcKx9IY99CIKHiDqqIC/pM2XhlxpYwgxvrAL9eHEG4p0ZaAwiRBNXzjjQKwCBuN7zwQ3izuykFGBVVbw78WxNuo8MZXXHbwINR6jrfo01n0TSLIVSNTHciHx1iDxbb8DYAOrjw/A0BaYuA0TYEgd+3y09bfLRzigUvfZBViyNViUZooTi7cGS2ghmxhtlaNOpEbAQmEUlRDTXgfbbjxBkfDMCR5vXeB+pOUG4nXMg3ycyafeob70pSTHnkq0CowgzcPk7Ere8qlgnV+A4u3oltNRLm/IxVj45xLoZNRfNt9GunwysoCCcSmnWz/xR/d8czgU1cwrGh3ZA3o6ubCFbar5Oxc2CRzDPPM7LTAWlT/I6w/7gMLgZBQfje0xvpCiej7oDSXABZlypPxOzvgm882H864h+UwcKD+62oHBvpeShVGgYo5e//012bElIIueFqilbQnIc/1QJp2zpf3FpHK2nCNcgSNegSNZr+NqUmwWQ1kTVbNCJw5Tly5NZoHWlrjlM3UQ+E7oyGLSDdSJ5yKUobMsgadO8DCz37ZFgYqZs0JHTujYBR1bbXMBF9jhDKHLX9prfkIhE34yaTpH4C20o8soVEsQm5Y+wp2MQ7m4nOoKXSMCZ/KuWj1AEtyOrEPdnOcnk4MUuYo0eS3m0zEvvMX5cjmRFgzO4sBngnirRqNK+n6h8gCAVHom/CMGoTHduhf11gCp55g/3gSCPidcFm9VXABm1Tc7augdJv1zQHrjhxUSM6b75tBEiYfFWtoOq8Ly13bzU0PayyvTfuKtQReY6dP9Wj+SF5X0Aa6qcZRMTQiPcfqRVgyDPtYlWOw1x3lbi6/qaZHjC0CJDSi1AVl2Hc/b2gI9W6BvCwwse7kWkrUYGVkjY1uk2qhbDSstxmThBKRFmCxGhoaxOGd03RxjxJ4emimxz8g+3QjOx1pYwjd8B7CqTO9rWoljLSrgTYWqiM3z6zhMi1c0FTswuI8irhRINGlnFlg/95VH+vWxFh7wrdgbXxcH8lMGTakq9gzxl98Ji//XD7+UuBcBjvsnbKEdfgGN97IbUPx44Q5DiTC+F5MUs67gaX2Y4dQEdnTQgXhcq6AJDd61osqJPN0x8DQ3DQRPogYdrlQsVnrDOkb7yhMcIBk+6a+sFQzAuycwCibbWvkg8EOrwdyItQgIdpgHX1c8gklYkW322aehsvNLmvC2fzwzJMYnfACOV+khBh1BCxp/G7l/Fn8br0GSrdLRfF3UZ9Gw93Vhn4VI3xoZWCND20nKV0vncmhsD03soan9gPO9zAGsfCU2YM8F7Fuunr4fWCNDa2RkjYzXWKd8P1mHJl2HJluFRtmbtmaAVhvKniJyt8Z8TTzLniRarDMImNBWCzHWqkOJvfd8KYWxuhyA40WyKABQcYg9lkkj1TNrKNtfYAlVfQ1VZ1Ef0NPENHPmKQyH8rEfewY/9VTyY1y/6caoMIS0s8jKzfe6PBh/DPPWPeFVwWDYeHB10namlkJX99Xw3eLR4e4IO83djf3Es+8miW+PTb2FvST1lwKCpYBwKSBx/d4GsfrFvU6FKdsOnyxyHT7B1refMQKl4WADDl3AkQs4Xjwra6emCzCpBWZxLao4jP0FWf+xVovjdc3DZc2jZc3jRc1TLZu+rvebdw35k85nbRbniwRmlkB16LEUeFNZt5zkFPMII8IqfwtEuBAR6RF457ppTjOSUGVxoPtGnscCTouAK+lMvibPXjnQgqXHSZsmUvs4C2xkj1WHIb9V9LUK4EIUYCs5MncOZRg6cHgrcPgrcIQuxyZRYtBTMu0Zh/VP/R8rWuNJnmwdHuXMdOTxVuLxV+FJIr0CCBhsm6+U5OaikKR54OfIEppaQ2O3WkRAELkSxK4EmXXlqFhL6FgO1uWs4QL7rPNKhpM6JbEua22Hjx3xiSM+dcRnE8/5tOcKOP+DZdYdh7UxVZ4wa4bp1vJzXVeHcUKOuQf4vgtaCQCyp8dyridy4SEF5iP18SGnpk9uTxG5Uwwd8W1DUFXGuDfpTnUjpCFiTe781RC1KL8eEimlUOHgM30W2MsXlZwTNW30JaDEAqTS9d6hd6srjB5owmYm3nmGdVmT9f5IG5bydGxoa1BeEyn+mshyU5NGsmRrsKgjZCcWbxUWfxWWYVz9dqYVq09XgmVuXhby5gofp1TxFWk6nZd+moTw3sxLrSyXLBiym0546M0e+lu3dZolNqBsOUjLRfodC2+Q6qUCB7GWfPR6iLcc4i+HBIsh6jRj8cDN1HmGBVZ5Dk5F/rD5VAw5tUxHs2jze4B39zvYR95vAwFTLvtlMM8OFmojsM4NeZistBxAu/vTlYrIP8BFlrjYEpdY4lI7nL5+9eg8vqk1ejstDfLvAPPsYHpgcXOhFRPIJ0/t+Aui8FXHKsE93W9DiQ6c0KETOrmdwTFxpqgmv1jTCQNMaoHJlmNirdhXQ/esisWt5NDNfutRpHAQsKskQ+rKkOhasHvS1c11xi2qdcScdBIeusEjJ7iWfkseyZHqIZi3fblh1yUss4AlmtY8/8TPBuaMDgAAreefNh1aAd2JZTkbBAPk+l0fyFEdmQNJuAZJtAZJvAaJJntG9lw1E1m+kEGTdXRmeqU8NQmWMlT2FjxGpYrmYfahhuCaI61kbKRg8lZjUgtJ34xyhkcvZfRjUltgZgnULO6FQM8WGExM2tcc2oPxjfFdkiRagyRegyQb7XqLtnuGQEn6JJq253KoZw/17aGBPTScvOu3WBn4ah5SLTDzv0h85IiPHfGJIz51wntq9v8JVh6ckziPcYPR1B0/HMPo0FsaTT24o1U73ogaZXkSLaFgGSy1gnmeIVjyj/6RPhcrqV0XLP4qLMEqLLFLaC/glbFzW41bmiz0SusDrFL1Uykh2WKIljr5asj09XzTgv1eEQsIHKE7R+Ytl0lIAn+cMzl73jGSYwNoYA2NNW8/fOLWVNZbhDS3WgMGDlNDuNo/K/ggdG8+zT02xXlI8gB87IhPHPGpIz5zwieJliUHe6Xy2p6nZ5c4I7X14ammEpXZoNKtFUpFNNFyg7lYtOrmBRQPsNCicIg6/U40NSp7isidYnjVb0lFZ3VqmQ9CILKlCBVa9WqEtxjhL0YEc+nwb+sZpST2xxB2BBSxK4VWoMeewnenCNwp1IRZ97D3Zpm+z0auiDPdRKvesxjqGepC1k3Tz5Z1IDtecQou0x+Xsh7kUJPUYNHYc/krcgUrcoUrck2DAX7mqX8vJwUm2nGoFTp0QScjAYndjKRim9d4DMDkVjg087SasrCw9TlLNJq3K+rm0lL25sT5KVCkzhSGVAMpfzVR8ZiWnE0yQ3LAInywdcOriPgP5x1teN64ITqphLWKvyIJjGyBsS0wsQWmtkAlDd2/WpEl0Yr2gCGANU8a42C4yQ1PNW/Bl2tT5yUxmT96inyqVcr4FYNAWIjDS4I+gIqsUPHSx9P2VG8wpOE8jlAZ3oJorzZUr2yvxbdieGjOFWZn3rRcIAGX2OHUWHtPH0lrEFdVKQiqfmyqFciY2dcjqiRAeSFPlQTFFiDlNrrrL5fb8/eX9atSTcXdEh874qez4TsU2UYHzndKZiWrmBJ3fYA9YFU3tTCpU1MCthPd1JT4BeygOSGdqWhRqonE21L4BiPkPVpiGzTZTCQn0mP0y1HiVWYR7PWeWe1gXqgPO7A2JDCzBPo3smN4ZNG9Ikgy1XIXh6/24Qf8mnbORLrZvKZaGo8woU3xodpETmHup62a86YqeYsJAleC0JUgciTQPBDnC5j9Vz6EzPZR1ZGjNO7SwKCbvaSnhmqeng0mEvVtYBrsRAwRwFI7WGYF06rEY5KQUT/EtCqEWqH4hUB/FDv7+dliEyOlp1TLUbHEh074SFtGi0csTjxRA9I0cZ8a6SFJtcIDS4GBLTC0BUaWwGgsqX4ns15NWWdVfiLQatD4BrzviA8c8aEjPnLDq8HBTgzOtNprwS8NLYu8vS/2Nbz2ycFDGmdmnZTuxFIE9VwP/LsMnQFcYIkzbZ4vL2dAATKyRsbWyInd/IxC6pl2BD4LjP22aCVB6kqQuREk27kPBQO0qmj5coIXcIQrcETjH8KDzOaEN9mXeKwLdvInDtOBJV6FJVmFJdU94O8HX5X5yO8Mr02VzwF0NioKe8fuYq7XNtUATBNv60gQePrz/14YXgCbslkiBSkxolxkTqZJGDhgQ3tsNO2Jd7KW5uuqbQJHtAJH7M6hStmID/iurv7QQmVw9iSAY0bRYH5pNWuWwbQKHvh6DR6AiYdnz/u07LLJ1p3Cc6fw3SkCV4rU4AUdtmxvjnV1fWaX3aK2T0NaSZWtRJXpsv54mvFLUT0Yd41gfaESFle1ZlCtbKSIezSHWhrLa2aatJ8V2pD5+RUTuH+YM2/GetuZZ8rVXMjgOTMoxzKehF5YxT1jblZDqmNJ0UoWb98PtHUNGqP7VJSCMAUoCJUxYcRlmlDLXd88Fo/TuCuThzPTNFoW4hJLXGqJy+xw6eT3bb4RzFt9VZJ4pil72OG1koPw4Q913dGxNN1DIXa50Dpc1HqJMgI0T5Y1T5c0D3QRWhaLTVic+asqEGaBWlf+WZQlrGij+PgXY0aBwnOnCNwplBQIjP+R42mIkapaVHgTENVFv18faVPBxKk0odj+6cJSXnzZPrGeZALl2FqM1US2tcNbrgL8SPVqpTcikl0vpqjQeCi9BK/O0A6HIi9gI3x9WScQcIklLrXEZXY45TFeiJsGDnxiI/CvLQtON2dKtFVxQQNAFJEFGn8dmmAdmlGhdNY/2pcETDLNfboQl9nhlF9vIc6zxCk/ZHFmcTLDsNGmikS0NuyVpPTAtLhwgRoxQilC4iNHfOyGj7VArKZRWjQS0l+ODcGsWswXJTCNSJxviTPsLXEynsk2+ncPi7HWaU0FwJfAYyd4quWfN91Ml7oUtMnpngwCbJkWrrkQl1riMjucpl28DKcqrJGnh82H67g3dPUTyhyL4FsAZMsA0Xa7FKCOyHKwk5ho8WQ8HOuSnlnchhoRkSY1hmdWgNq8wWy90f3ENQlS0tNoc72s6vPErt83BRh+93BLQZOuQ5OtQmMoZvwGpr98yDX7XFcPdCZdlrCWLFD9zJtxUkOm2Aqk3n+C1H+BFLviy3kDmXb44UoUrkUUrUUUr0U09LUvsLU7FNVeWejye51x23P/R49mc1cchY84i5RfZDnWVISZVvvNF9qZewse/VyoHPemknVL4MMHfSukA3TBndtM2APLTq/7dlcIBxngI0PCxSMa+7MPsKOwYWph33saSPS0ouJc7IlhI4r6hf3w0sbap2/rav96PY4sUvEqH6o9TK5VTjHbpKhmpHqnIuzAEa7AEa3AEa/AkbhzaEH4oi+9L9q8uIDBR1+l4AQUvjuF0g6Cz40ZVhc68bBoqeQ71SmyOSGG5/QFAJbZwOLt1g7m2cF8O5iNQEgWe1s7mG8Hi5Wjv4TZ5YSab9N8/l1flo2UXgBUYoVKrVCZDcrfWqFUB+H6xc99Z/kKlWdgCSiwAYU2oGgpyN9uw+nK+la49NA4+Gyu4nwowB4//IHBeLxeMDJFqzHN6hzNxmIBShk5i1CJDSrevt4njM29Zc39Zc2DZc3DZc21ki4XjMoxFpEeleQW2Cx+UQ79mdqxSJC4EqSuBJkbgbfduhIo3w9q+hT5bF0YPTUcgb4tMLAFhrbAyBKoksW+PdWv1eo9kfMZDBu+fiOJvwZJsAaJXozw0fAaxKln1xS7Hi9KhSLEpg7YzB7rbx2wngNWqyO2r/vdRJyLHjD+jzcOtksaR0saT+vEvBcq8rpHyiAyr/2WIFuBJNyuQRIslMlHTGiBiSwwsQUmWY5R+31ZPwLVbsijSbmHB/EqFRFJEblTaP07hxlvvMmcHL+qAjmIzlzQ6dYJ7TmhfRe0MjksxduRI1mBI3Xm0EryqSLWs6KVuxIjnAQwtgUmtsDUFphZArWU87LsjQGnrKcIBSpZjRSRvjUysEaG1sjIGhmP0xDM848GUfvOO/jHdtCZU+JJM8VfEBvZYw155L+Q6wbGyidWJv2FEurIEDkzJOP6aL+Yt6z4H/3ZU0tcZocLg3EiKp1MIZ4nG4fPbsq/F+2+Ps+mpvCrgilaiykKjfEvg2bKjLFyZuIvtZzpfcPpiBVNvA5NMhpsmLhb4vbaGFZUUnqRyNQamdki46010rNG+iPkKLnn5rhXTBF5SQZ44AYP3eCRGzx2gQdq97J4ag1UgI0F1nfAmtVT3zV9ixKm5mmuPYtTMySIXQkSRwI9DrwC0/xQsIxt8yTN53C1kwr0OHALtOeCTm7WYqakX5/PZHL8J8NQi6qijYxC97dhPN3UfsV707pvn81mZEr2giNz50i2K3AoQWHMb7hjybQmGIaYDSHTADQUM/zE/DX4Pv8hPNYz9z/rPOk6PIbcvXclVUVkJ7HF/CIDa6E5avmmTUubB3iOr+PqZvLkUMrGHcUmVpJ5a5JNTyA+/KB5bzBrwlRiAgvMsAKIbZg5Jlm+PR5scxZtBEXkSpEoh6U4lIc+8JXu6fky2guK9NZ79ArDm6PAUWGseCMHaZpFLuf7sPNSz6Jbcmy+gU90fWXBTSBSpr8YYlrheeOmfeTsCDR30Pvikb5KDQNMfhVc8B73jd/xtubd9fA+oN3T8OSBFlpgzRA7MyTODKkjgymjGOYoVNOcxOgwNYInObMEmvqhSMJjiaR1WR9nMlP4H1ICEPZP6lzVmiFwZgidGZzfQ+rdVMTsTkVj1oxmSWMlrBwcmKWas4/sC83JOYrlaIbLCAy1isAv5tlAa7UAWeWFIUPiyBCGgWsslQ+WiU04tR9q5Z+was9DUW0+jtXExIMf6ian9UHpSQM6jq3rIgA6cy5p4IdahRF7ZWykCdehidahiVehUTavVFTe8HV1+npp2cN3OzLtAQHOHMDKyrUBey5g3xocacm6n8yJwzwygP0zRwRaDNIVVx8c/x9JMRL4YLh+aHFgDRhDZvDW/KPfH1lleIOTr5GbhWE/EGlKgtYUWvbYlW6gJ21IpUW762/tCrMqvFr4k2HjrfLK/o4hsPmMO/dRu8iBapWE/Xfbc9NxdvuAWUTQ5ja0BkgCZxJdeph9+KkWGAf3TXG4CogKe3wtJB1Zp2yiz+FzmTZ9O96ikQ0EQ+TMELsyGE52fxfVhZ6TLylEY1mJiIqmnNRw0utMmqkd4h2CNt9xl2Y6e2P/+ySuCqzngPUdsIEDNrTFpppjjJXNNWK10rlSls5PtVhykQAGFkRXdP2emg68+B9Y4qLENEgqSFQE8PdCpBS+Q+V8w/2Zoj4mk5VEmIsAD1zgmTIDP5Rs1iTml3djyQwyTUiQuBKkrgTZlGC2hi1LPWrYVUTDQNm6oJUfHBcPYcbdTWRp5Sah7suS0vx070t86IiP3PDJeKeEyoylYflkAnbc+1EfqGwhSKI1SOI1SAxdgXt32hk5vq7uRcI+wNOtG9x/lUdJZgfjjkGVuEB86IiPnfBazNFIvIhFt9ESfu6978nGwZLG4YLGpo/4rEwvlc32WivOZfqi1lyTM+XZirTjOlCIzlzQapNrhZ56ZWGx2KMRvPkGe6izuUY1byE5AmcOX1kH8ld8J9dni44NyMgaGVsiQxUL8AXswGIigAw2F4/2VYm5iMpsUGroLUIpiUm8tnmza+vmMqfVRpjDHuhJeWzq/iJJwjVItMi8BgcQ92dQMpZGwKe/73gblv/5hG0YiZZONX4JCt08tGdStafiIkGeDci3ARnkmjF4lCt9dIZsA3l2sJfNWt5K8IUr82l1UZnT+PkDDe701w809MQuWwotReZDtcddlH6GNCagvMlwWJklBt2P76eiKXEmGZMM/y6gmv9zv6cVvM1pYudwSCrY90O2XStpwnVoolVoouyZ0zljJ5mmuGRJvF2FxVuFxV+FJViDJYmte5uyBliEI3oT5vv5gTfR+rma6+zgvgtcq5D0lZwv88hGXOWoQAsozOuKGwBm4/JEGiIOJjLNU8iOQjY3GW3jW7LjkANvIeCp3W3V0LG6reGkH8OjmpxeOqNMWntpYAcu0Zk1OthuDVF1n+onFvvxjTbjqrN6Ma42h+3pWdIkq9DEelKI0IU3ALFuyqEvyeFQ8uSPVuI9R7zviA8c8aETXqsG+q8KVuxdSTdvhkYzNTVYM0V1HwguPWCUS/y+ocfCKM4K4x3P2LUvqe3DrNCRE1oTLUTV2M1HyqNH5oVlD7IFZ4jX2swFWz/0x7/lVgFxNCRYk060EAyRM0PszJA4M6SuDOmoMsahn69JIa4KYDoqaEFgbv+IXpV5ODRhfhdJkTlTaFqW1hSeO4XvThHcauSin+95J2AgkZE1MrZGqurhFEV7N19UFJGBoGKNbiONgm2g7BgnFn8NFm+iaP9VufrnB9NhODLgNFqJHScabx0azStbEZiyqXG6xpogB7zGULFaMP9VNTAJs1IwBre08Cn0qhGv6CZYolVY4jVY1Nm6WnrMnhpZ0EI2u8hW957kClbkClfkiqbxPL890qasyf7Z8MFaNhI86Uo82So8Wm0F5qdkCS6NsSJdh9e1Ki4AzgzReM+F3wVbrXasEjGZi6PtZQu5OUN86ojP3PDeuPDM/6Am41xsE+9N/x6aCI5gBY5wBQ77gM72tpXgS1fmy9blu6nODrNygaEes1+fF1vXPr2auKVb4bPaa49i4tj1s3CIIDZywMYO2MEG5pFif22HXDYTAf9DxtRJjnQFjsydwyCN9+6Eddbw7OLZQ4tHKnJGJVOwFpMKZB1+l0yDn/9deloAcgQrcIQrcEQrcMTuHJq5X1JctnBR+jRN6Rn096VnKNWs/KVILeaUhcFVrMJw1U6qWZDzTohrBXpiwhKYFgj0npJ9qYcxa+qneVO37Q4MSM+TuMASF1riIktcbIdTE744o//w40LB5m7pa3URgETtEaxJPE+FII7O5CdOYPpIRZADwgI7mFITKsmebr494dI0yUfg3XaHTTrZQhDEjgQq7/JX2jxSlgB519GhytctQ8Xa4EvDFoLBc2TQlBU+wna423w0BemLoYsNRBC/AGcOYBWA+aF6pGV9YbsgUSnHREGHZlo9HSTy1yIK1iJSTogCDR4sHUVYoJvZ0S4a5aKNIEnWIEnXIMlWIFEzhAuJNw3Juut3XUkng57TyKisVjYSPP5KPMFKPONQsy910WoV5iQJeq95ogG7LlS6kSBxJVDyXmB3dcazYf4Tcrw+1N5BaGYNVTPgcqjaGBTVflxyezT5oK6bbCDgkRs8doKrUw+2gxyHfd/i2Q5Sj/tGgsiNIEi3urXATCi+hBgZ9qINX0Ekhe9OEbhSRIY88LfluBrbWOAHcIbc79fhvFGE9RdY08YlZG7iqy+igcD7jvhQBQoV7ZngbvpdWRPjg19kk5y1EAyRM0M2+g0fziwPZ77MEWkOMJELeOq7wQM3uHLi4NA11SwXvx239FooEWIjB2zsgE0csKkDVq38Zf1klmDhNXMCL9aiE0tyRdvpqcDCtcUoV445Ni+8CbbAv0uKzJlCi1u0ptBSg8ifzAi8jI8ZGHxIGpcHDYD17bEq+0z0aNSaNj43O2WTaiiITKyRqS1Sk+ppyLFGBcK3jbZ+D8LQsHLv7/eszf3Wk+hES3H5k1abd/X4pjLBBa7m9fBxlGNsKTCzBGorRU43H8t6lEzMYUVOD+ySAPk2ID17B6dljCsy4Qi7/FQIeTGERvbQ2B6a2ENTe6hW2aiEtXEq1cIzMthFFkYlgOnWFugbRgk+HRsPM2lZeI1XE0SGwJkhGUWrfEeX6GY4ZTNV9WMNn7DdcMp2L/g0YQUljfim6/qKThZSIZOLefD5CbP7hHffS9WGDHXMjIsLA6N40M3Skt7km7JEIZZ4bszapEz5u+kkNLCHRhq0OLD1YS6zWDYYUowRHzvi03HG5y/Fgc5me2Jpd4nMbJFqk7UYGdycd6JfeZLjwdUO8bLK3kZoZA+N7aHJTR7wT32xNwvK43+O8qrApg7YzB4bbh2wngN2LJj3vADonjUq9DaCR8XgdnWRw3bBkOMqrwhItByiHFkkx8nzfW+qZC+eEuNaHzFmQj1l5oZXFcveNHvMJmGJEUadN8Ia7OV1gfcc8b4jXpNvP+9I95yDfiIshfjMDa9H7FrhVd1jLrA3heXiggAkSwHpUoBJv++rEpM3q3o+8kAYTpGM5S5hVbnUpnfCO+ZFXBZo3wk9vFGlT6FkX1o6KdpRorjP/R+yMc+VKhRfsjJfujKfsv8JTmDmaeegrnGYshmXwTwbWKaWzTfsrIoVz5rROyO8Rau00gJ/q6KxeafsrvjO3pKuK+kLkpSBH6inVlYqbJOa/jIXekh2tVwP6I9LWQ+d2w9MRrM9WbAmWTSKbX1G1YL/oWlZID5xw09ia5fiA0d86IQPE+20oTTWUxHgvG9asMBJfipgI7KX+DRwxIdOeK1+2x1MiQ3MEbjzIfmD2e/cikaEtWEcgac7eqR2izGc9Va9pUXBC6m1EejKhG408So0ysqBF3NkW6sZUdgWr9eHQdAUwaEL2OCHEunRL4rRIzxzgmt5HFZwzw3uu8GVE2bX1uWM7UHUNQ7TDjIWwXwrWDqJp5tum8WgFQF1atsM6+LWCa1OjWEUm3NBzvyKAPhLAcEygK+lO4oqaZhhPbPQs9+CarPaSh9o0gX2FMqbgYF4d/3l0mBsjumLYi5Z2w/XOYGKmFgaJRloNSsssJE91h/nxsx2JaGgqXqSFjdggQ0csKEDNrLGBol3e3ZES7PU6EMvjtcC7cjol74izdgncascXGKTG79EoGku2BJ4rgRqaYdNBZbhhaVMf2u3FDveqD5ob04vgWvPoXLpMGtRr8UxEmBWlwUys0TGBiHvj4Q2BZ2eCskRxi4Px2dBbJDvXkzhu1MoFTJMnmAi9RS+ddG3xjfRPRXcn6hyLYAkXIMkWoMkXoMkcSfRFAqszw1gN6e2xyhlO1FVHVU9H8vdAkOkqawUZ3iGb/BL8mnwJ2e4sDadbCIofHcKXeEYfievhoAuio9F19G2M1JRleEAFJE7RexOoYsE7UlXN9fNzxVGq+ZdO/M+RLtiaMaplKvOnSpZjUrZrb/2DfQjPLmRVEYmkX4w4QlW4jHsWL4xhSzjt5JtBhEtoEi37hS3qRSYq0ebg7FqL2epeLOLaiWI/LWIgrWIDNEUX+kf/SOtyCzZ8JIabKkfdABhsjZhujZhtjJhtl2XMPM0z1F1LM3T/Zld8gVETW4LbRlNitlyfg89tcr8gi70o0m/Wlggx+IgfM64P1eFJJDFX4UlWIFFS8r/cm1qTMgjuTk6qe4HTGSBiS0wU3WYXzDmsxlKQ5FRcZ0hafRKC6bmDd8fvb6cMDBYs06EofoGbyrWpTDRqZwY9UL8h7A2J9FEMITODJEm9F/nBRYrghUIPrJpTAqig2xaaC0FX7Yun3KmrcSnxHZIVxYPdFzTYUSV81aNbCRYwlVYolVYlL1GG6x6j6c8o3INY21U3rAdWgmmZDWmdDWmbC2mZLsaU2Q6ftbd4+MPx5pR1UrwxOvwpFqfhs7RwxaqOJsZ/sQdWn6SvsNQOz2xwIYO2LGo8mehSGnG8/N7qVopOeIVOJIVONIVODJ3Dk3rpyihf/CMs7qb1D+kuxKWKtI0ItwaoJoLua172CHD53yuNs9tI0Hir0ESrEESTvawczs9OdRFu9udVagVsnNmUhqyp6Yoh131p76aKQbUsXbM9MJ/kTzpSjzZKjxatT6YvuqWLsxfCrWierYEgSvBeCLhImHF86OP6YR1MusdWJJVWNIVWGI1FL/BJ32LVaU234vuVFTP1J164g0YQxLdlqK8qTP8YuxJqAVAOvwMLRTShSXKnH5KvHWDK3nIoslLGWJsPpDNWZMalTphu8WPQWBeV3v7quQqBRP36EzaDYAzB7CqXG8DVrL4suKL7lGai88MtcClt7BOlaQ9vS7bBpCpNTKzRapo0q/kUuw3/yxMmchyvcImD4XKQwZ85oZXcRY/1azAE87iMKfXZGYeP9aog3aiHW8jWEJ3FpjKs/FZqnbGMl4o0Ujp+F8EPNi6wL2truQKeCY1fls276bLsmQ++SEB7rvBDfXrX1+yDwi8rSuB50YQxFMhm8/kD9reFLSAn304yOQrwITLMcoHJCtcY5VxLNUxFybbqFIeiI/tAxMBnTigw3Aqqv0ZBgIWSdR/wkRMnjzCd9jJDEfgSVfiyVbhiUJvtBu9zSXWZF/aE/AzDZL7IBXoaOuEdru374QOXNAqsJhX5prGQ9ykX3d101BhOkdR6tmDtcKgUgLzn1X9VNL9cWlBNSTz1yQLViOLo2gUrQIGxsUcWKkuIzLxvHjksdcS9Eaq+fB2q2KHanNUghNbcBgEQWqSqWNL2rOilUTVJkGiMLjJa2QV2MqpfAyrOcLy+jvlnEdw5gDWqndUAOaV1ya1U25YCtGwZT9jp/0MrWLzCmTxmmRqKUBZ2GqoVft5KsLPqFrejG2CZRwY8qQr8WSr8ITb7a3mL2a8onJqa3AuMp5qaHaRrQSTvxpTsBqTprrQoh04Y+YwljNvshMtOIMfjcbGMwR88r3Fq4BtNFDREOwmpy4MfNAuC2hgD9Vq13e4vM8UIDrVWPlMVB5CXGyJSy1xai8ljuQMIO20Dn9ZMjqPfAuLsQlWsss7vMqR8fKbqaOA10O85RB/KSTS+wZLx8HhzzK7TdgnllqIOavtRRJErgQq1LDBMN6PDaV/GofFDq8f+GWBTR2wmT1WE6yo9jyIhhcLXZTFDkRa5L4jkbcWkToiwuqmYNt3NVsP3taV8e3kvFmHFeR32EbwJCvxpOvwJNuVeLyVeDT7l16e6X17uKx3viTUI6K7jkW14GJSmCf1ljdSkfNhpKuPCa/H93GFW7EPGOcjADgMXMD2d45TZZl/a0h/Js+VHqrqRyJhkR0sMwndv2lb0pfdDIemdk9EQ06mBvoaZFoCOpcgxUn3TXNuZ5jqw6S+HdLE69BoYbk0f8Df9a6hTzMcHf8EDKq5mbGWE1Afrguq2yFB5kigPGCw3WKxHuZUuqH0F2+Fh4Dl40DirUES3FTXYklmz/VU3kBgQwds5IBVJ4wFdAmmdVFc5r48NoGln9d/xBOjWwnbVishMb3z0IBjtUmQHKhe9mjqdpLXBTKzRSqf0R3mIrGSMm/rZ/DYChrtao3DX4EjcOfQ4mVOdf6AKuWzNSnldUQm3tTXMhWw0zhKQMtiKFRrKMhUue2G7IvcFGIlSajWQqBjJ3TihNbqPJHuBF3/mSxkXgJOczMhQeZG4G+3rgTKZsQCH6Tla9K4ktrkXajGqp6apPTXpwzWpwzXp4xWp/QN0cs/ny9zTLJNcb5IAs+VIHAk0E7XaLm5u1a0ORqzSw9YsrzaiyNGRHrWyEkRuC8k754p0XTBywKbOGBTB2xmjw23DthopCiniQqOPy+XlZPCggiOXcCJAzi6OXPfN+Qwt/DshusCmdkilQG/GBnr7je+WjfFGayZau4XoyMOF+yhmWBKVmNKV2PK1mJSO3RXJnWU8K4pOli3y81bbD9j4eSi0Y61ERSRO0XsSqEFeL0ZB6DragU3IecIS+1g2UiQaVqNlMsxUbxK2EWO9DxrZGSNHF7vjL7eqb5g5zgqiydS+5XXY1Ro0Fdy0XI89RxRcUEA4qWAZCFAEwmmlVkx7yIucICaML/BLop5aEnRGcKiMNsSdvnsooBm1lA1ZS6HTrTBmvqx2Jv1YIQ8mGohOMIVOKIVOOIVOJIVOKZhG6LA7Lh0403N4Me62D+R8kF44RKT9Lwdz2BdstIzLEl+3D0G8ZFqr1efQXTihE5d0CpzlQmP4Ep11x8OtBlHWGqFrKFRO7QRNN46NP46NFpXh/ZNOyNKtVdXBTDW3mW1AXReXFgBJ0PYJSVlfWDKb9r0lCbODKkjQ6IYZPExU4Ii1zASDbTwhdRTH/MT6WcdISciwtgxXjk0hFHV1QOeRU09YTzLU0aunHnDg3SIAdswun97Kh/4eVb1pzlXtGYtDrwBh6twHDt44AaP1nwVWbwiW7jNRnE543KwpjzcoRisIFFuZheScfkgmHYvtD0Vh25Gl4VHR7d6M0Hlr0YVaDk4FXdGfqOkeeZ3kaMmw4QMgTND6MwwDP/vRbnf/NTUT51ZiOBQ1n1T8Lp8AFTpbD9XmMGPJ1p1r7TgR91MtHnCJpIhdGaInBnU7EdKeiNmfws+wuVBzB6BhljQV6XGAzbzHLBDr/snOtpEzNI/+ln4AyvZB43+4G0ETbgOTbQOTTxOkaeTenTiM8gMeRSHP53xbFmOxyxzJ9FSrFxItGNKUcPGxKAXuEGUcuojIxvMOH2bxRqwCRozD2IpibT8ESu45wYP7caRtpv9kJfFpTV3GyqucYzm3309JlqOCXzrcartngfst4YKdc0DfXYt7qChWoi1fbU7VbIelcqloY+sgOefZnxDLyWthoUjCkNbYGQHzGKtQGnTl5PNozDwh9I+yrrNVJrG57rZFfuiu86eMsGA2NOcXCVU85+A0Y2n41gt7QbOcA8VpnvdHyvydH881b2YEDK102MH1FeRZdDOMvCzriF7AynSm5PmPQY51I2eLYL329PmPoglRAvy63geuWpOftD7OBUt1f7raw8782/kMvtkDTToyEUCp2NjKYNyC5DmARMFHw1qwjfvBtrlqpmgSUdv+Pdhc3Tbr9C1DdP1TuC0WOZ+92jYMup3blUTRGdbdQp3l4u4Y3b7mQK0+GD0SiVYy+aHXz6DnUlhQ/wwmfxOoQns9sSi/e1UNGA+kdvAOVYJCjZxbV0dWWCSoFFBG7/13U6LVr3dcYO52cOcWvd7iYvU7as97Toy+94eZQOBVJG1V7TIi3kkC5qAD45dXYDVqX8PgxQ2ynV9nvMRwATwIF+3VilU1sj+XB8xLpLO3j4vCVjY+fC9VbjHZ9rkBQbibHgCjD4QMVbh3vN8Cbod/HD13Bp9TDB+S0q5Mhji1Gkc4boEbGjx8s6T+20TAVNL3bvmeuk2H/GA1liFHG5XHK571NVu5VtSK9QH6HD0XOTzOqV4X3zLEqpZbflpVzeVcW6GN95SLCQpYCoq/FvdH09aCvqt77weRnvmBXrwKvsKhkhRcT8poSigoVaLB6aCzc8zwQYwJLm0osQFWvGytjOl3uk9R5wk41zH+rAvaaLb7KX3Qjn4uVkH/2Wv2gmi4UP9Vm3I5gvaap/qpqXPzF5nJsEO/5KfSHMURi5QZTfxoHIa+alRETWTwlgspEbg9comDdhcKMki1P5nat+KPne/la8lma4jP+dXQ+az/oOKnA5KesCR+rfVwM0BpcYsTkSHKmz/qWTB9BjV8HI5NMSq49GmOBb7Deqk7WHKHHTScJzCCgzoMynKe1g3BFKlQRdn88umFIsY7hpZeRdRmbbTH77XrzRv6ktdFu3ca2di/Hv11tXW8V8VDjOsvzqWi5c6/nXVkePQ/bTInTc5WNrn6QEdS/4egrNhABNUhtMY1LiHTXxDYERx17phqupgdft3z36NRCulhR5j9lnIZj0Ib6v0WVimBCIeVW/7CcZAfS1nMqUvFFYf0kmw+k4w/c54pfEP2jU9bdV8oxUR/06wGhCrV8YWU+NrJqgVMsRYZ1rlb7Z4/O0deWB1clV1HPWV+eGrZjVmWgAOjKu+mbF5+R/weKzCpISq4QSPc6trrrpzid0SXhdYEQKmYuuK5jhb0IK29QHnWCkogkitpsSxyGfF0GV1kaqDbgcN2xMVO+9MK+PNqxgzgV3oFtC5KJ3s3WF2fxpCyrNAWekfKcpevmOz5DPdA/1zHJptF1rnAPGWQ/zlkGA5JHTcrGSaM9yWQtPYA6sHI4JwOX2udi7/g2fLA147bkRubjvdwpXxFIsZUctY+gmsA1g9Nl9ro75jAysIrFK67aQVZXHYygBNug5NtgqNVqbciSZ43V400/y4dlvKzOTQXcigiYIt3xVqTmEr9EoWoqad5UakeVItDKto6zmhA5t9PeBCS1xqv6PXoo8swP4q2/lIicks2x9HwdYW6L6xjoJwBY50+eY80otILdica0mny3BapaGF+2stGGihAzPTYoCWQxNLj2um5T0uhqp12Mrjmmm5iZYEahkSeyPoSmdSzTO0uEk59qVQv0aKzJlCy7BYZk3H6hDJ2pqO9dN6W46R92vhBib2Uye4isG3cIbFTq60WM2LS/de8c2R00JobA9NraEqrdVmlxsrY98Obu0OjGPPyh0Yx74lLrDEhVa4RItse613NdFi2V6PSS0w2XKMssyXb9CSzHMBxzcbSpYT/+yKz/UIwHpWJpm9ZQc0gefoI0WOYPGuGFGhDSq8kSvYlWg2GjycTwXX0UCEtxgRLER46tjKwtmNeC3SnZfY/Frg+RZp6FT87ETKHW32XijBqQs4cwArR6AN2HMBJ9Z+XkSnTujMBa12RFboxNYVieDUAawS0yxcZ4hf43gBeJS8oSOP53TWgAy+M0NoddoNSLWa/tQXXMn4p7qhh4JWmjv9b3zyjAKB0ta5JSjPAhWo6f0thTffPJgLJIprHBNPD+yYgT7WJjMd6UMzXZsM2BJvTTZDVDo/s32Rjc32Y7ZoTTZDwKjYHL5I17N2Yz5/VT4tiO/b9XKaixrsxDWGifXY3bzo5lQYCn5RYGILTLIYk6h17/fiWJQGB6CEPQ7XOVLLfTyRut28rcu5lIgcG+xqLm4TbbWycMxAI2Vdtc9YaNeOtxDg0AUcuYBjF3BiDfa22vxcdcXfuLfh/9bPOP8GX8OfYhsILMpZ8gE2h2IDuWuYpttLaw2fCz1P+X8XHeUjMrNFqiNToWIOazVsLyo69Vv6vsQkFpjUApMtxyi76fUYTUXO+ttpAnL2HLF1Vh2iExe0OrH7qTgMIqYftKD0mWBlggG9gkTNPS4k3hok/hokgTuJJjrgFiuFVKlTmg4yZK4Mylr6V8UCNskOftD4YJ8FTd6faHm+Z5MQ7FR+/GjImbQYgrcfcvaFwHzkhVHs6mDwtFJ2zM5vByvfLAkOw57jYt8SF1jiQktcZIlTcZVyk7H5jUynBui5ahtSi5AvxCs9hKoqTmCpaFuYm913BdNqKlAqz9nurolvddfACqXKMuI5SIkRR4fO9KSEXWcpfBKbOmAze6yabH8hj+RGK/wGWcLVg6gagDDPDubbwZTWGqrP/ddGpQVNarkLBiZTx1KDZKkO5IlW4onX4VFb5G+nvmLVLgzZ+wjv9OsMrCUeKQUAvNxOw3oFiUyeabVmgstfkSu4Sd6ilaG+gVTAZw0G9duu7ujw68JVWPTkNxTjZzp75u+D15Wb1NOiGSywiQNWK6FF8SywPt9GzN/gz7INn5EkR+bOEWxX4PBW4PBX4Ahu4yINogICf8Dr6iAfsJF2boVGjEot/dDRpoLWJp6daFsfqGwl6KJ16WK1UuWUT/9vnsgDrQwhvmwJkM3I0EowJasxpWsxxVOVEz7V3sTy3swG7UNRwVvCVpLEW4NExXoXe/g938kjNX6pDi8/sasCGVgjQ2tkZI2MLZGxmmsxTAVD8af6wzxubM+u7/CygMb2UO1spqn4mSRuJsxFIOHjVli7jLcQDKkzQ+bKENzGcMH8xOTC56PuWtwQdXJPpwVqWOInguBm7WRRSpO3IaKJoIjcKWJnCjVMeVIFao08E8F4Yo0OdcNeiuRQwnV9J4Xl353IJE2bc+R9x2Tl85M4aUeKyJ0icadI3SkyZwq1A/tXdSBFs3mzfySYimOm6FkjMrQRJOEaJHrp2/qJKSpcKBZzKv406Q6L8SratrdNOaXa0Nyxwmq34ZrzWWOBxEdKkoZeNzWfPb5PC67wZ7lAoxpnjydRdQUpYneKxJ0idafInCmyid/27oJONBP+3De4o7oMTjatGtp3ci3J1Qh74pcEIl6M0GrrVDA3vTnX8JTfwBJ5nFkvTtiOYLO260Q7xpVstytyeStyqQj0kvRYPbbZHNBsx+8pyrmZa7nJ5tgaGovabpI2+4/QqjDTdWm9/wyt/5+hDW7L7W3eG84Z9YJ7++Gc0dNqofxe5KzywkvJUjwXX3cbJCob2J4kTQ0+EWbkGwvwsShKFrg9lGVBDpUMwN2N7+kPTPEfxZIKDmY4lH3bSXTohI6c0Oq8t6SkauntPld+RmHA57yNttf1tRRxoUiG4RcYUt6ao6UxDmXIhI98raTNO0yeb+iMFkTbN4/FIxbDxtOjvOPd0Nf89x+qk5AM+Ib+nHbW8bPDU6jB5eMnaWBQlSGsIor5WZSkjGgleKKVeOKVeJKVeNJ1eLQEyboBCwl5xgngLPx1Jy53BY+1RmzigE0dsJk1NtVSyJZjfSdhTGQIXBk0V+hTXV/mc4L3DTnWMPqeHgRSE0fouVGFa80n2ui51CzkF4wBnDVOMPbvtywZNwq0KMI3u/pcVMx8xmrRWqL+NABG1BGSRYKQJ12HRwk1fKEd5vLtVdfHX4LnjfAaslC2jxe2v9Uw3byvxwPrcrq2mOdx30khUoRlVrB06iF7pznKbw9jc1nGC4GeLVBZIJhCh7CyJPq57R9gkpfN9b6i+UNJcnovYiQC7SzcAhs6YOMb/wiYq40qVG46sIZuQ3IZCRtoEZBWeE3r4Q5z5rB07dtp+Jc2CFvWTKJDJ3TkhNaVVc4UQ4hPdWcG57xFCw3Ei/dVrDpT9PyfvnicdDGBfoIG/+bXBTZ2wCb2WOPBGtg412d+ujoOw4b4BiSZvyZZuCaZFskPX3zzleb9hTYmR4iu4NXQI62oKlkATJr4rCvT8AO/FJgBixt4rDI701lFm5Y1EQyJM0PqyhB6uiwafKQDbKhZ3omZA+sK4umOSJpEhsCZIXRmiJwZYlcGFVX5c/VYHOvn+lSBLW67UxS4wdV+qt6x5Al9Qzqe/LBJK1oIfOaGV6dflngVbVGDMfhYTJYsgS2HywIY2AJDW2CkFUuheTfK9Zh0FGxzFk04g1bcmcKF5wl22OQWr1yHn3peF/QLbC9n8Cfe5MJaCLzniPcd8Sqsq/4h/Cc4L81MW7BjrjpMKz9LfOyITxzxatqtC6488Wu9+dDm5DJnq2C7+lDVlDcSPNkqPIFWl49rwT3SZ1ZZKtuoBTZQu767qoD1EPfZRTW7z8Yhoa0igWYzWsFDJ3iilfas8q44FKhn3kzn7gspCeyI7tuh2VMjw++AJl6HRrl+nzCI9iuFiW7XG2bzgQfbNVozTqS2S19x20ixn87pqkiqRra83VIDmbcmmb8m2bhizp2hrKtk4ZVqVGhZEG61bMldsX8xmSrQ6jP8Ai/7hJ45qrsHdqQCU+/yeJE5cYFWSOHVEF+TZs8fNv+n7huzxr7o1FiTEHY0Eq3VnQIjBDpRW4gaysYEarzK/yIJMkcCFVJlS6D8q0TlI+IW57UC90ASbW/qb0mWz5iQ0o5dOuRU/btoyB8wkKoH2BwO30KlNLqwJLFeOrqBfvzMxhReRDf8Cq30kFbqZfQCiyonTaXZdFqc7S+EaaCO1UxkBBBzkiu3kRYo+7UmzDF+R/IGZqrcrPuNSlANHhfDN2hq0kga7zZSQ7y2r6eiqk0+9rI40H0jJHQQ7zviNQ1x/rwzJhb69kuMby7p8OzhOrOwFodr8RAqQOmEKQNshf8+yT6QTwCzSn14Uq8/dUFrGol9WcKUtadz5Z530KDp25NEJi4HI4EmQXZ3YgIGTCR/6vgcXjxrVR8GoRDk8FfgCFbgUFVesPJ6g+uTwSPFhxH68ZphQ6hVhvhIKTpib2scDRPOoWhP92EqUb4VKtTKKf213bCgpPnZqX4qJTC2BSbjOeYrzevH6TbmuWpAyJNp8elFXrRnwymBvMIh/ri2nSzAZahqiM5gTH7bCR08zqAWN1sGrbQ7TK3o4WVHlFObVRmL2CwfWgkafx2aYB2a0Hqu02KFLbDaUSobfbC07jf/6PdHFijfzvwIqhr/odoKymR1Sk1MiJK8rl6aT3as1e18opVUrA49Zpm9xFKIdrc8ui3iwqMl/OEIgFe0u7JF+jmqI8FwpP3uiqkMOlm0IpmWb4IJb68j63jT3fWGyVuNyV+NKVLF/85nHrzAbCO5S5ohO7HWzE4eNlScMla590NEanE2j0EZjlqcJdZzwPr22DBdx0qLtWLbmH0AD/GJTLdaw8jkbVglJkngORKoNFE1yciv+qVv5rbFwyzDvull2D7FKq1vHT7V46Z8/+jb7iW+VmzORARPoMUTrkOox8yxGKdBt4ueL+Ws2cvjoRhXJxpyOi1WbhU6b1W6yKCaQolRQ+9SQ19TGcmAzWyx4dZQyOojLfn4nC/FexiaCJZ0DZZQ8xDgTqTaoMk7TQUgGMt8n5OqKna8eBXDa+Jg6oix7svNL0wB1iweMhwx6kqxyJWuxxWtOhWEmhrSSnzRqnxBOP0O7yl87yLffCNYvaN94QXueetONBas6X+ENftPsKov9KWBfQpLo3xX1qPiTkL/6yKb5KwFY9BcBZ8LGK8lV+6e5gyc4Z9wA4hNdqKFYEidGTJXBmW0WTLEQWL0Gf1aN4Mb3pz7n2SSIXVmyFwZwtvsoA2T2DH1hbbr92xEMXUdgdZyElkrTAzqCmw5LyeHDtiyGKSlgCRzJ0mCUNeAqm7jJDQpNyZOqxKDw0RNCW+53jSMMpj4ZSjclIGFxdYHdZACHJk7hwqGujuxJDLUOjNK4rMu2fJGWox1tFUu6E/o978tRWXuB+FWYLV0zvwK1i0ZSXtw1UvUT2koVz6RQN8SqNVSyOse/v2l0lktb6aFpgOJUgZFFUTSagK4N+8rh8ukLfIB6NsCNRkuiloL1CQsCu0P7BIDeVtN/6f+G9rreGDHvoY5WUqTTU0lR+rOoc5aUE8rLy7T/ik89eeiaWoMupPfS1NvssB6DljfARs4YGM7ZcfIU4fuPNsX5rN8VkN2kIeLfD+yroiB6NgFrd7U7+SMyQv5TYLnM6cfgI0tKkUiLrHCBYGmD92gmTeX0sYGcMfbMFNwSGrDw1V3Ek1M/1YZaYnKXaT5Q36VRS7wWZ6tS0Ca85U9zZAnAjzBOjyxljje0tywlN5IvnMVUQFNbKHappqvXtLMP9W0Kn6MDxUuJwrG7Q/09Audqjjw9Irne1xAeabOzClBSy+EPyCpfhRUxPwATbQOTbwOTbIOTboKjZomvv39179/+/v4s+zq8+5+G8nW8aLWyaLWmR7ZRZvNY/t305m9FttFm8cW45IFQ7h1ZvCcGbRgwvyBaR39UpP9XDRR/oCnETUZ4IEbPHSBa2VAvoNt98BKLU4lJuTZbdeQ/kwk1LeHBvbQ0BqqdWU8H2RBt4sUEGJtw2hPkbpSpL6/uLIooILQqs4lIiNLZKbF5cuEo83X6Q5dfi7KS3wMO3QgSJS8AVxlJ9T95NR3PqsJGDJXBmU1WzN4zgy+G0Oi6QV+pRXFLL1P9cWQpceFo2FzO5SJQ7DvAFaBp99JY9ZslQ/+pBowbKqss5/gxkqS0aRxH0iMZ4HxLTCBBSZcjjF4EX+uWowFv4P3dTZthQp2vWWXOUm0XYPEW4FEk9lkTf7agh1TQqeuzfWX2B9HGTLBOdR51Rfe2+rhUPMLyc0i9/mJlCWpjnrYGTDFqzElqzGlN28Itp/okzGcU97EUiWaNvlCnGeDS0O9DhlLiv9SF21dzSsyX9h1mQELBIGLSAzglTpTUXYn2LXBpndGFempwZo78AOuJGcHw5IjcufQFmQKPbljdarMSSlyptvTvGBh8coVBjzBSjzhSjzRSjzKu/BImwdVXcmU/fbABWoEVNkeX9BdNlNUsa9aJhtGDoeS16YVFZrSVC1d7wn6AabVrrkD9j7wJCJchsi2Kv7n9QZZtjUIDvBqrl/H1VzHL5nfv7kp5oqE2bqEmkLVZ9qRc91cTvV4zRrqS+KZq4yUzxJl5n7ti+p1hTARllnB1D5wGcxbDou3nor1ZGK9v5D2ZFYSQbXekvD5EnAqTFhJNmtWnHa48FiXYALUEhdZ4hJLXGqFyxLt8KKpi9xkop7YFRiprGgX7D+j22q+WNTmSPevilpHdOSEjp3QiRM6dUBrKeBMGx5GupCg+0bpzbnhUAOep/wDVIVfLYf61lAVEfS1uHTF3pzYIS4xSKDV1iugC06DPOXs1VCW5iNg2iHH8Xhb0nQU5AGjs+NGF8I8O5jK4xIR6mgSixB1Y30dTKZtpbUHDOHUHmaJI/PGcCtFbyVD7MgQK8txuZIJwj03uH+bzsuWqx/UKG0kNwLw7fcSHrjBteV+MpGLlBU5h+u6hO/4Sehs9PqOyk+sKRHy9KY7WEyLipgesK+utChxg9+KRoIicadI3Smy8U5BL01xmyfEfNOsUoUAZ1trsL/N9LN1WFvHoft9hfa4L1uni1pnC1p72+2i1t6C1olaFJg6xyeVvzWMID50QgnQH715ELqwxvSNIBKYeGuB8Rc+mEp4vyswl2U33QJrY+VYN2D1E4mNrLHZNjKEXGE+zguRCbu+y8E28SVNugJNoB343xVgO1ebX4qDsbhvQ//dF1yqDWCeVl/yTJ+zuIucni9w+6tAqsV9MTKwRUbaWWM+W4AR/7MjZbmV70b19SUwTX3jy7WpczCvz8/bpYEWhve5RgGizd1DURmDxNhlNe0EgXKbLYd61lBNsqFGRa/j5kN+mkSpFEzpsKcsHqqRizmgfSe0qgjQ1H8ay0sMWO0dq03zElhoOH1/C3NS+1AYQzzarq4ofPOnQdgw1vOl7TmULf+tIZcZjQxatRgCJSHpUoiWJPiFiWGxCp5Gi6MhDwPIELyNm0qwr0g5dcGjwnRXtAM6ckLHLmh14vThzDLbKEogVZPTumeyhoBFna86sQRrsKilk4l/3mZLSoojXjrwKxymBgcL8/5+I5Wnp/9B/6wPLOOfI7XaAdo69Fj3DdNBYWE15nlatOGRN3+XbPGqbMmabGoTw7Ikx8quXEES9hb45k7Y+wQssYOldrDMChZtbWCJ2sneQX+FqxcjstUuCmBgC0zsgNnWULDpPNbSPNYlPYuCTTABcw+Qnpnxpb3mpyLHAn5NbU4x4S1OrEHLCbSCmW/r/ZXFQOA4Mzz39byrSxhhNVezQWxmjdUEBKWYyEj44IXM3jgMVC7tR/jH6+YLuRqsXWYmHLDBRVwX6MQBnSVaTtXxiMVz+u4VSftx5GnRew2lPBn0YF7IsFQjzqEH/tIiLfft24ltQwH97YQKZ41KiZ6UP5/WGACibEUqfy0qTUv3PW3rcjZ8jtdo1taJWDsdXg6N7KGxPTSxgf6//w9GevaEmzICAA=="

Function Obtener-DatosTalentSpellsLocal {
    if ($Global:ArmeriaTalentSpellsData) { return $Global:ArmeriaTalentSpellsData }
    $tabla = @{}
    try {
        $bytes = [Convert]::FromBase64String($Global:ArmeriaTalentSpellsB64)
        $msIn = New-Object System.IO.MemoryStream(,$bytes)
        $gz = New-Object System.IO.Compression.GZipStream($msIn, [System.IO.Compression.CompressionMode]::Decompress)
        $msOut = New-Object System.IO.MemoryStream
        $gz.CopyTo($msOut)
        $gz.Close(); $msIn.Close()
        $json = [System.Text.Encoding]::UTF8.GetString($msOut.ToArray())
        $obj = $json | ConvertFrom-Json
        foreach ($prop in $obj.PSObject.Properties) {
            $sid = 0
            try { $sid = [int]$prop.Name } catch { continue }
            $n = ""
            $i = ""
            try { $n = [string]$prop.Value.n } catch {}
            try { $i = [string]$prop.Value.i } catch {}
            $tabla[$sid] = [PSCustomObject]@{ Nombre = $n; Icono = $i }
        }
    } catch {
        $tabla = @{}
    }
    $Global:ArmeriaTalentSpellsData = $tabla
    return $Global:ArmeriaTalentSpellsData
}


# ==========================================
# DATOS: GLIFOS (GlyphProperties 3.3.5)
# ==========================================
$Global:ArmeriaGlifosDataB64 = "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"

Function Obtener-DatosGlifosLocal {
    if ($Global:ArmeriaGlifosData) { return $Global:ArmeriaGlifosData }
    $tabla = @{}
    try {
        $bytes = [Convert]::FromBase64String($Global:ArmeriaGlifosDataB64)
        $msIn = New-Object System.IO.MemoryStream(,$bytes)
        $gz = New-Object System.IO.Compression.GZipStream($msIn, [System.IO.Compression.CompressionMode]::Decompress)
        $msOut = New-Object System.IO.MemoryStream
        $gz.CopyTo($msOut)
        $gz.Close(); $msIn.Close()
        $json = [System.Text.Encoding]::UTF8.GetString($msOut.ToArray())
        $obj = $json | ConvertFrom-Json
        foreach ($prop in $obj.PSObject.Properties) {
            $gid = 0
            try { $gid = [int]$prop.Name } catch { continue }
            $s = 0; $f = 0; $n = ""; $i = ""
            try { $s = [int]$prop.Value.s } catch {}
            try { $f = [int]$prop.Value.f } catch {}
            try { $n = [string]$prop.Value.n } catch {}
            try { $i = [string]$prop.Value.i } catch {}
            $tabla[$gid] = [PSCustomObject]@{ SpellId = $s; Flags = $f; Nombre = $n; Icono = $i }
        }
    } catch { $tabla = @{} }
    $Global:ArmeriaGlifosData = $tabla
    return $Global:ArmeriaGlifosData
}

Function Descargar-IconoPorNombre($nombreIcono, $tamanio, $cacheKey) {
    try {
        if (-not $nombreIcono -or -not $Global:RootDir) { return $null }
        $nom = $nombreIcono.ToLower().Trim()
        if (-not $nom) { return $null }
        $sz = 36
        try { if ($tamanio -gt 0) { $sz = [int]$tamanio } } catch {}
        $cacheDir = Join-Path $Global:RootDir "Armeria\Imagenes\spells"
        if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force -ErrorAction SilentlyContinue | Out-Null }
        # Incluir nombre de icono en la clave para que un cambio de icono no reutilice cache vieja
        $key = if ($cacheKey) { "{0}_{1}" -f $cacheKey, $nom } else { $nom }
        $cacheFile = Join-Path $cacheDir ("icon_{0}.jpg" -f ($key -replace '[^\w\-]', '_'))

        if (Test-Path -LiteralPath $cacheFile) {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($cacheFile)
                if ($bytes -and $bytes.Length -gt 50) {
                    $ms = New-Object System.IO.MemoryStream(,$bytes)
                    $img = [System.Drawing.Image]::FromStream($ms)
                    $clone = New-Object System.Drawing.Bitmap $img, $sz, $sz
                    $img.Dispose(); $ms.Dispose()
                    return $clone
                }
            } catch {}
        }
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $bytes2 = $null
        foreach ($sn in @("medium","large","small")) {
            try {
                $bytes2 = $wc.DownloadData("https://wow.zamimg.com/images/wow/icons/$sn/$nom.jpg")
                if ($bytes2 -and $bytes2.Length -gt 50) { break }
                $bytes2 = $null
            } catch { $bytes2 = $null }
        }
        if (-not $bytes2) { return $null }
        try { [System.IO.File]::WriteAllBytes($cacheFile, $bytes2) } catch {}
        $ms2 = New-Object System.IO.MemoryStream(,$bytes2)
        $img2 = [System.Drawing.Image]::FromStream($ms2)
        $clone2 = New-Object System.Drawing.Bitmap $img2, $sz, $sz
        $img2.Dispose(); $ms2.Dispose()
        return $clone2
    } catch { return $null }
}

Function Obtener-NombreSpellTalento($spellId) {
    if (-not $spellId -or $spellId -le 0) { return $null }
    $sid = [int]$spellId
    if (-not $Global:ArmeriaSpellNombreCache) { $Global:ArmeriaSpellNombreCache = @{} }
    if ($Global:ArmeriaSpellNombreCache.ContainsKey($sid)) {
        return $Global:ArmeriaSpellNombreCache[$sid]
    }
    $nombre = $null
    try {
        $local = Obtener-DatosTalentSpellsLocal
        if ($local -and $local.ContainsKey($sid) -and $local[$sid].Nombre) {
            $nombre = [string]$local[$sid].Nombre
        }
    } catch {}
    if (-not $nombre) { $nombre = "Talento #$sid" }
    $Global:ArmeriaSpellNombreCache[$sid] = $nombre
    return $nombre
}


# ==========================================
# Ranking de talentos compartido (Armeria + ventana Talentos)
# ==========================================
Function global:Armeria-GetTalentRanksForSpec {
    param($specIdx, $tabsList, $spellMap, $datos)
    $spellSet = @{}
    try {
        if ($null -ne $spellMap -and $spellMap.ContainsKey([int]$specIdx)) {
            $tmp = $spellMap[[int]$specIdx]
            if ($null -ne $tmp) { $spellSet = $tmp }
        }
    } catch { $spellSet = @{} }
    $ranksByTalent = @{}
    $pointsByTab = @{}
    if ($null -eq $datos -or $null -eq $datos.Tabs) {
        return [PSCustomObject]@{ Ranks = $ranksByTalent; Points = $pointsByTab }
    }
    foreach ($tabId in @($tabsList)) {
        $tid = 0
        try { $tid = [int]$tabId } catch { continue }
        $pointsByTab[$tid] = 0
        $listaTal = $null
        try { $listaTal = $datos.Tabs[$tid] } catch {}
        if ($null -eq $listaTal) { try { $listaTal = $datos.Tabs["$tid"] } catch {} }
        if ($null -eq $listaTal) { continue }
        foreach ($tal in @($listaTal)) {
            if ($null -eq $tal) { continue }
            $best = 0
            $ranksArr = @()
            try { $ranksArr = @($tal.Ranks) } catch { continue }
            for ($r = 0; $r -lt $ranksArr.Count; $r++) {
                try {
                    $sid = [int]$ranksArr[$r]
                    if ($sid -gt 0 -and $spellSet.ContainsKey($sid)) { $best = $r + 1 }
                } catch {}
            }
            try {
                $ranksByTalent[[int]$tal.Id] = $best
                $pointsByTab[$tid] = [int]$pointsByTab[$tid] + $best
            } catch {}
        }
    }
    return [PSCustomObject]@{ Ranks = $ranksByTalent; Points = $pointsByTab }
}


# Hechizos firma por especializacion (fallback si character_talent no matchea bien los ranks)
# Shaman: el calculo por ranks a veces solo ve 5 pts Elemental aunque el personaje sea Mejora.
$Global:ArmeriaSpecHechizosFirma = @{
    # classId = @{ tabId = @(spellIds) }
    1 = @{ # Guerrero
        161 = @(12294, 30330, 46924)      # Arms: Mortal Strike, etc.
        164 = @(23881, 12292, 60970)      # Fury: Bloodthirst
        163 = @(20243, 469, 50720)        # Protection: Devastate
    }
    2 = @{ # Paladin
        382 = @(20473, 53563, 31821)      # Holy
        383 = @(20925, 48952, 64205)      # Protection
        381 = @(35395, 53385, 20066)      # Retribution: Crusader Strike, Divine Storm
    }
    3 = @{ # Hunter
        361 = @(19574, 34026, 19577)      # BM
        363 = @(19434, 53209, 19506)      # MM
        362 = @(19306, 63672, 60097)      # Survival
    }
    4 = @{ # Rogue
        182 = @(1329, 32645, 14183)       # Assassination
        181 = @(13877, 51690, 13750)      # Combat
        183 = @(16511, 14183, 36554)      # Subtlety (approx)
    }
    5 = @{ # Priest
        201 = @(47540, 33206, 10060)      # Discipline
        202 = @(34861, 47788, 48089)      # Holy
        203 = @(15407, 34914, 47585)      # Shadow: Mind Flay, VT, Dispersion
    }
    6 = @{ # DK
        398 = @(49998, 55050, 55262)      # Blood
        399 = @(49143, 49184, 51271)      # Frost
        400 = @(55090, 49206, 51052)      # Unholy
    }
    7 = @{ # Shaman
        261 = @(51490, 51505, 16166, 30706, 16039, 16109, 16578, 16086, 29062)   # Elemental
        263 = @(17364, 60103, 51533, 30823, 8232, 16259, 16295, 16252, 16254, 16256, 16261, 16268, 16043) # Enhancement
        262 = @(974, 61295, 16188, 51886, 16182, 16226, 16176, 16187, 16190)     # Restoration
    }
    8 = @{ # Mage
        81  = @(44425, 31589, 12043)      # Arcane
        41  = @(11366, 11129, 44457)      # Fire
        61  = @(31687, 11426, 44572)      # Frost
    }
    9 = @{ # Warlock
        302 = @(30108, 48181, 59164)      # Affliction
        303 = @(47241, 59672, 47193)      # Demonology
        301 = @(17962, 50796, 47897)      # Destruction
    }
    11 = @{ # Druid
        283 = @(48505, 24858, 33831)      # Balance
        281 = @(33917, 50334, 52610)      # Feral
        282 = @(48438, 18562, 17116)      # Resto
    }
}

Function global:Armeria-DetectarSpecPorHechizos($guidChar, $claseId) {
    try {
        $cid = [int]$claseId
        if (-not $Global:ArmeriaSpecHechizosFirma.ContainsKey($cid)) { return $null }
        $mapa = $Global:ArmeriaSpecHechizosFirma[$cid]
        $spellsKnown = @{}
        try {
            foreach ($linea in @(Consulta-Armeria "SELECT spell FROM character_spell WHERE guid=$guidChar AND disabled=0;" "acore_characters")) {
                if (-not $linea) { continue }
                $sp = 0
                try { $sp = [int](("$linea").Trim()) } catch { continue }
                if ($sp -gt 0) { $spellsKnown[$sp] = $true }
            }
        } catch {}
        # Tambien talentos (por si no estan en character_spell)
        try {
            foreach ($linea in @(Consulta-Armeria "SELECT spell FROM character_talent WHERE guid=$guidChar;" "acore_characters")) {
                if (-not $linea) { continue }
                $pt = ("$linea").Trim() -split "\|"
                $sp = 0
                try { $sp = [int]$pt[0].Trim() } catch { continue }
                if ($sp -gt 0) { $spellsKnown[$sp] = $true }
            }
        } catch {}
        if ($spellsKnown.Count -eq 0) { return $null }

        $bestTab = $null
        $bestHits = -1
        $detalle = @()
        foreach ($tabId in @($mapa.Keys)) {
            $hits = 0
            $lista = @($mapa[$tabId])
            foreach ($sid in $lista) {
                try {
                    if ($spellsKnown.ContainsKey([int]$sid)) { $hits++ }
                } catch {}
            }
            $detalle += ("{0}:{1}" -f $tabId, $hits)
            if ($hits -gt $bestHits) { $bestHits = $hits; $bestTab = [int]$tabId }
        }
        if ($null -eq $bestTab -or $bestHits -le 0) { return $null }
        $nombre = "Rama $bestTab"
        try {
            if ($Global:ArmeriaTalentTabNombres.ContainsKey($bestTab)) {
                $nombre = [string]$Global:ArmeriaTalentTabNombres[$bestTab]
            }
        } catch {}
        return @{
            Nombre = $nombre
            TabId = $bestTab
            Hits = $bestHits
            Detalle = ($detalle -join ",")
        }
    } catch { return $null }
}

Function global:Armeria-ObtenerPrimarySpecInfo {
    param($guidChar, $claseId)
    # 1) Carga todos los spells de character_talent
    # 2) Cuenta cuantos caen en el pool de ranks de cada rama (mas fiable que rank-a-rank)
    # 3) Fallback hechizos firma si total bajo
    try {
        $claseIdInt = [int]$claseId
        if (-not $Global:ArmeriaTalentTabsPorClase.ContainsKey($claseIdInt)) { return $null }
        $tabsClase = @($Global:ArmeriaTalentTabsPorClase[$claseIdInt])
        if ($tabsClase.Count -eq 0) { return $null }

        $spellSetAll = @{}
        try {
            foreach ($linea in @(Consulta-Armeria "SELECT CONCAT(IFNULL(spell,0),'|',IFNULL(specMask,0)) FROM character_talent WHERE guid=$guidChar;" "acore_characters")) {
                if (-not $linea) { continue }
                $pt = ("$linea").Trim() -split "\|"
                $sp = 0
                try { $sp = [int]$pt[0].Trim() } catch { continue }
                if ($sp -gt 0) { $spellSetAll[$sp] = $true }
            }
        } catch {}
        if ($spellSetAll.Count -eq 0) { return $null }

        $datosTal = Obtener-DatosTalentosLocal
        if (-not $datosTal -or -not $datosTal.Tabs) { return $null }

        $bestTab = $null
        $bestPts = -1
        $ptsList = @()
        $totalPts = 0

        foreach ($tabId in $tabsClase) {
            $tid = [int]$tabId
            $listaTal = $null
            try { $listaTal = $datosTal.Tabs[$tid] } catch {}
            if ($null -eq $listaTal) { try { $listaTal = $datosTal.Tabs["$tid"] } catch {} }

            # Pool de todos los spellIds de ranks de esta rama
            $pool = @{}
            $ptsRank = 0
            if ($listaTal) {
                foreach ($tal in @($listaTal)) {
                    if ($null -eq $tal) { continue }
                    $ranksArr = @()
                    try { $ranksArr = @($tal.Ranks) } catch { continue }
                    $best = 0
                    for ($r = 0; $r -lt $ranksArr.Count; $r++) {
                        $sid = 0
                        try { $sid = [int]$ranksArr[$r] } catch { continue }
                        if ($sid -le 0) { continue }
                        $pool[$sid] = $true
                        if ($spellSetAll.ContainsKey($sid)) { $best = $r + 1 }
                    }
                    $ptsRank += $best
                }
            }
            # Hits de membresia (mas tolerante)
            $hits = 0
            foreach ($sid in @($pool.Keys)) {
                try { if ($spellSetAll.ContainsKey([int]$sid)) { $hits++ } } catch {}
            }
            # Usar el maximo entre puntos-por-rank y hits (hits/3 aprox como "puntos")
            $score = $ptsRank
            if ($hits -gt $score) { $score = $hits }

            $ptsList += $score
            $totalPts += $score
            if ($score -gt $bestPts) { $bestPts = $score; $bestTab = $tid }
        }

        $firmaUsada = $false
        if ($totalPts -lt 20) {
            $firma = Armeria-DetectarSpecPorHechizos $guidChar $claseId
            if ($firma -and $firma.TabId -and [int]$firma.Hits -gt 0) {
                # Solo usar firma si gana con claridad
                $bestTab = [int]$firma.TabId
                $bestPts = [int]$firma.Hits
                $ptsList = @("firma:$($firma.Detalle)")
                $firmaUsada = $true
                $totalPts = $bestPts
            }
        }

        if ($null -eq $bestTab -or $bestPts -le 0) { return $null }

        $nombre = "Rama $bestTab"
        try {
            if ($Global:ArmeriaTalentTabNombres.ContainsKey([int]$bestTab)) {
                $nombre = [string]$Global:ArmeriaTalentTabNombres[[int]$bestTab]
            }
        } catch {}

        $distTxt = ($ptsList -join " / ")
        if ($firmaUsada) { $distTxt = "firma($distTxt)" }

        return @{
            Nombre = $nombre
            TabId = [int]$bestTab
            Pts = [int]$bestPts
            Distribucion = $distTxt
            Total = [int]$totalPts
            TalentCount = [int]$spellSetAll.Count
        }
    } catch {
        return $null
    }
}


Function Mostrar-VentanaTalentos($guidChar, $nombreChar, $claseId, $formPadre) {
    $fBoldT   = New-Object System.Drawing.Font("Georgia", 10, [System.Drawing.FontStyle]::Bold)
    $fPeqT    = New-Object System.Drawing.Font("Georgia", 8)
    $fTituloT = New-Object System.Drawing.Font("Georgia", 13, [System.Drawing.FontStyle]::Bold)
    $fMiniT   = New-Object System.Drawing.Font("Georgia", 7)

    $talForm = New-Object System.Windows.Forms.Form
    $talForm.Text = "Talentos de $nombreChar"
    $talForm.Size = New-Object System.Drawing.Size(1280, 760)
    $talForm.StartPosition = 'CenterParent'
    $talForm.BackColor = [System.Drawing.Color]::FromArgb(15, 12, 10)
    $talForm.ForeColor = [System.Drawing.Color]::FromArgb(230, 210, 180)
    $talForm.FormBorderStyle = 'Sizable'
    $talForm.MaximizeBox = $true
    $talForm.MinimizeBox = $false
    $talForm.MinimumSize = New-Object System.Drawing.Size(1100, 640)

    $lblTituloTal = New-Object System.Windows.Forms.Label
    $lblTituloTal.Text      = "Talentos - $nombreChar"
    $lblTituloTal.Location  = New-Object System.Drawing.Point(10, 8)
    $lblTituloTal.Size      = New-Object System.Drawing.Size(500, 24)
    $lblTituloTal.Font      = $fTituloT
    $lblTituloTal.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $talForm.Controls.Add($lblTituloTal)

    $lblDist = New-Object System.Windows.Forms.Label
    $lblDist.Text      = ""
    $lblDist.Location  = New-Object System.Drawing.Point(520, 12)
    $lblDist.Size      = New-Object System.Drawing.Size(380, 20)
    $lblDist.Font      = $fBoldT
    $lblDist.ForeColor = [System.Drawing.Color]::FromArgb(200, 190, 170)
    $lblDist.TextAlign = 'MiddleRight'
    $talForm.Controls.Add($lblDist)

    $panelSpecs = New-Object System.Windows.Forms.Panel
    $panelSpecs.Location  = New-Object System.Drawing.Point(10, 36)
    $panelSpecs.Size      = New-Object System.Drawing.Size(880, 32)
    $panelSpecs.BackColor = [System.Drawing.Color]::FromArgb(20, 18, 15)
    $talForm.Controls.Add($panelSpecs)

    $panelArbol = New-Object System.Windows.Forms.Panel
    $panelArbol.Location   = New-Object System.Drawing.Point(10, 74)
    $panelArbol.Size       = New-Object System.Drawing.Size(960, 640)
    $panelArbol.BackColor  = [System.Drawing.Color]::FromArgb(18, 16, 14)
    $panelArbol.AutoScroll = $true
    $panelArbol.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $talForm.Controls.Add($panelArbol)

    # Glifos a la derecha (visible en resoluciones pequeñas)
    $panelGlifos = New-Object System.Windows.Forms.Panel
    $panelGlifos.Location  = New-Object System.Drawing.Point(980, 74)
    $panelGlifos.Size      = New-Object System.Drawing.Size(270, 640)
    $panelGlifos.BackColor = [System.Drawing.Color]::FromArgb(18, 16, 14)
    $panelGlifos.AutoScroll = $true
    $panelGlifos.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $talForm.Controls.Add($panelGlifos)

    $lblGlifosTitulo = New-Object System.Windows.Forms.Label
    $lblGlifosTitulo.Text = "Glifos"
    $lblGlifosTitulo.Location = New-Object System.Drawing.Point(8, 6)
    $lblGlifosTitulo.Size = New-Object System.Drawing.Size(250, 20)
    $lblGlifosTitulo.Font = $fBoldT
    $lblGlifosTitulo.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $panelGlifos.Controls.Add($lblGlifosTitulo)

    $tooltipTal = New-Object System.Windows.Forms.ToolTip
    $tooltipTal.AutoPopDelay = 10000; $tooltipTal.InitialDelay = 250; $tooltipTal.ReshowDelay = 100; $tooltipTal.ShowAlways = $true

    $CELL = 48
    $GAP  = 6
    $TREE_W = 300

    $datosTal = Obtener-DatosTalentosLocal
    $null = Obtener-DatosTalentSpellsLocal  # nombres + iconos locales
    $tabsClase = if ($Global:ArmeriaTalentTabsPorClase.ContainsKey([int]$claseId)) {
        $Global:ArmeriaTalentTabsPorClase[[int]$claseId]
    } else { @() }

    $activeSpec = 0
    $numSpecs = 1
    try {
        $rSpec = (Consulta-Armeria "SELECT CONCAT(IFNULL(activeTalentGroup,0),'|',IFNULL(talentGroupsCount,1)) FROM characters WHERE guid=$guidChar;" "acore_characters")[0]
        if ($rSpec) {
            $ps = $rSpec.Trim() -split "\|"
            if ($ps.Count -ge 1) { $activeSpec = [int]$ps[0] }
            if ($ps.Count -ge 2) { $numSpecs = [math]::Max(1, [int]$ps[1]) }
        }
    } catch {}

    $spellsPorSpec = @{ 0 = @{}; 1 = @{} }
    try {
        $talRaw = Consulta-Armeria "SELECT CONCAT(spell,'|',specMask) FROM character_talent WHERE guid=$guidChar;" "acore_characters"
        foreach ($linea in $talRaw) {
            $pt = $linea -split "\|"
            if ($pt.Count -lt 2) { continue }
            $sp = 0; $mask = 0
            try { $sp = [int]$pt[0].Trim(); $mask = [int]$pt[1].Trim() } catch { continue }
            if ($sp -le 0) { continue }
            if (($mask -band 1) -ne 0) { $spellsPorSpec[0][$sp] = $true }
            if (($mask -band 2) -ne 0) { $spellsPorSpec[1][$sp] = $true }
        }
    } catch {}

    $script:TalentoSpecActual = $activeSpec

    Function Get-TalentRanksForSpecLocal($specIdx, $tabsList, $spellMap, $datos) {
        return (Armeria-GetTalentRanksForSpec $specIdx $tabsList $spellMap $datos)
    }

    $null = Obtener-DatosGlifosLocal

    Function Render-Glifos {
        param($specIdx)
        try {
            $panelGlifos.Controls.Clear()
            $lblGlifosTitulo = New-Object System.Windows.Forms.Label
            $lblGlifosTitulo.Text = "Glifos - Especialización " + ($specIdx + 1)
            $lblGlifosTitulo.Location = New-Object System.Drawing.Point(8, 6)
            $lblGlifosTitulo.Size = New-Object System.Drawing.Size(400, 20)
            $lblGlifosTitulo.Font = $fBoldT
            $lblGlifosTitulo.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
            $panelGlifos.Controls.Add($lblGlifosTitulo)

            $glifosIds = @(0,0,0,0,0,0)
            try {
                $gRaw = (Consulta-Armeria "SELECT CONCAT(IFNULL(glyph1,0),'|',IFNULL(glyph2,0),'|',IFNULL(glyph3,0),'|',IFNULL(glyph4,0),'|',IFNULL(glyph5,0),'|',IFNULL(glyph6,0)) FROM character_glyphs WHERE guid=$guidChar AND talentGroup=$specIdx LIMIT 1;" "acore_characters")[0]
                if ($gRaw) {
                    $parts = $gRaw.Trim() -split "\|"
                    for ($gi = 0; $gi -lt 6 -and $gi -lt $parts.Count; $gi++) {
                        try { $glifosIds[$gi] = [int]$parts[$gi] } catch { $glifosIds[$gi] = 0 }
                    }
                }
            } catch {}

            $datosG = Obtener-DatosGlifosLocal
            $mayores = @()
            $menores = @()
            foreach ($gid in $glifosIds) {
                if ($gid -le 0) { continue }
                $info = $null
                if ($datosG -and $datosG.ContainsKey([int]$gid)) { $info = $datosG[[int]$gid] }
                $esMenor = $false
                if ($info -and ([int]$info.Flags -eq 1)) { $esMenor = $true }
                $item = [PSCustomObject]@{ Id = [int]$gid; Info = $info }
                if ($esMenor) { $menores += $item } else { $mayores += $item }
            }

            # Rellenar hasta 3 slots vacíos por tipo
            while ($mayores.Count -lt 3) { $mayores += [PSCustomObject]@{ Id = 0; Info = $null } }
            while ($menores.Count -lt 3) { $menores += [PSCustomObject]@{ Id = 0; Info = $null } }

            Function Add-GlifoSlot($parent, $x, $y, $item, $tipoTxt) {
                $box = New-Object System.Windows.Forms.Panel
                $box.Location = New-Object System.Drawing.Point($x, $y)
                $box.Size = New-Object System.Drawing.Size(250, 52)
                $box.BackColor = [System.Drawing.Color]::FromArgb(28, 24, 20)
                $parent.Controls.Add($box)

                $pb = New-Object System.Windows.Forms.PictureBox
                $pb.Location = New-Object System.Drawing.Point(4, 4)
                $pb.Size = New-Object System.Drawing.Size(40, 40)
                $pb.SizeMode = 'Zoom'
                $pb.BackColor = [System.Drawing.Color]::FromArgb(20, 18, 15)
                $box.Controls.Add($pb)

                $lbl = New-Object System.Windows.Forms.Label
                $lbl.Location = New-Object System.Drawing.Point(50, 6)
                $lbl.Size = New-Object System.Drawing.Size(220, 36)
                $lbl.Font = $fPeqT
                $lbl.ForeColor = [System.Drawing.Color]::FromArgb(220, 210, 190)

                if ($item.Id -gt 0 -and $null -ne $item.Info) {
                    $nombre = [string]$item.Info.Nombre
                    if (-not $nombre) { $nombre = "Glifo #" + $item.Id }
                    $lbl.Text = $tipoTxt + ": " + $nombre
                    $imgG = $null
                    $sidG = 0
                    try { $sidG = [int]$item.Info.SpellId } catch { $sidG = 0 }
                    $iconoNom = ""
                    try { $iconoNom = [string]$item.Info.Icono } catch { $iconoNom = "" }

                    # 1) Por nombre de icono del DBC (suele ser el correcto)
                    if (-not $imgG -and $iconoNom -and $iconoNom -notmatch '^ui-glyph-rune') {
                        try { $imgG = Descargar-IconoPorNombre $iconoNom 40 ("g" + $item.Id) } catch {}
                    }
                    # 2) Por spell del glifo (mapa de talentos o ZAM via nombre resuelto)
                    if (-not $imgG -and $sidG -gt 0) {
                        try { $imgG = Descargar-IconoSpell $sidG 40 } catch {}
                    }
                    # 3) Fallback incluso ui-glyph-rune / inscription
                    if (-not $imgG -and $iconoNom) {
                        try { $imgG = Descargar-IconoPorNombre $iconoNom 40 ("g" + $item.Id) } catch {}
                    }
                    # 4) Ultimo recurso: Wowhead XML del spell del glifo
                    if (-not $imgG -and $sidG -gt 0) {
                        try {
                            $wcG = New-Object System.Net.WebClient
                            $wcG.Headers.Add("User-Agent", "Mozilla/5.0")
                            $xmlG = $null
                            try { $xmlG = $wcG.DownloadString("https://www.wowhead.com/wotlk/spell=$sidG&xml") } catch {}
                            if ($xmlG -match '<icon[^>]*>([^<]+)</icon>') {
                                $nomWh = $Matches[1].ToLower().Trim()
                                $imgG = Descargar-IconoPorNombre $nomWh 40 ("g" + $item.Id)
                            }
                        } catch {}
                    }
                    if ($null -ne $imgG) { $pb.Image = $imgG }

                    $tip = $nombre
                    if ($sidG -gt 0) { $tip = $tip + " (Spell " + $sidG + ")" }
                    try { $tooltipTal.SetToolTip($box, $tip); $tooltipTal.SetToolTip($lbl, $tip); $tooltipTal.SetToolTip($pb, $tip) } catch {}
                } else {
                    $lbl.Text = $tipoTxt + ": (vacío)"
                    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(120, 110, 100)
                }
                $box.Controls.Add($lbl)
            }

            $lblMaj = New-Object System.Windows.Forms.Label
            $lblMaj.Text = "Mayores"
            $lblMaj.Location = New-Object System.Drawing.Point(8, 30)
            $lblMaj.Size = New-Object System.Drawing.Size(240, 18)
            $lblMaj.ForeColor = [System.Drawing.Color]::FromArgb(100, 180, 255)
            $lblMaj.Font = $fPeqT
            $panelGlifos.Controls.Add($lblMaj)

            $yG = 52
            for ($i = 0; $i -lt 3; $i++) {
                Add-GlifoSlot $panelGlifos 8 $yG $mayores[$i] "Mayor"
                $yG += 56
            }

            $lblMin = New-Object System.Windows.Forms.Label
            $lblMin.Text = "Menores"
            $lblMin.Location = New-Object System.Drawing.Point(8, ($yG + 8))
            $lblMin.Size = New-Object System.Drawing.Size(240, 18)
            $lblMin.ForeColor = [System.Drawing.Color]::FromArgb(180, 160, 100)
            $lblMin.Font = $fPeqT
            $panelGlifos.Controls.Add($lblMin)

            $yG += 30
            for ($i = 0; $i -lt 3; $i++) {
                Add-GlifoSlot $panelGlifos 8 $yG $menores[$i] "Menor"
                $yG += 56
            }
        } catch {
            $lblErrG = New-Object System.Windows.Forms.Label
            $lblErrG.Text = "No se pudieron cargar los glifos."
            $lblErrG.Location = New-Object System.Drawing.Point(8, 40)
            $lblErrG.Size = New-Object System.Drawing.Size(400, 20)
            $lblErrG.ForeColor = [System.Drawing.Color]::FromArgb(255, 120, 80)
            $panelGlifos.Controls.Add($lblErrG)
        }
    }

    Function Render-ArbolTalentos {

        param($specIdx)
        $panelArbol.Controls.Clear()
        $lblCargandoIconos = New-Object System.Windows.Forms.Label
        $lblCargandoIconos.Text = "Cargando iconos de talentos aprendidos..."
        $lblCargandoIconos.Location = New-Object System.Drawing.Point(10, 4)
        $lblCargandoIconos.Size = New-Object System.Drawing.Size(600, 18)
        $lblCargandoIconos.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
        $lblCargandoIconos.Font = $fPeqT
        $panelArbol.Controls.Add($lblCargandoIconos)
        $panelArbol.Refresh()
        [System.Windows.Forms.Application]::DoEvents()
        $info = Get-TalentRanksForSpecLocal $specIdx $tabsClase $spellsPorSpec $datosTal

        $pts = @()
        $nombres = @()
        foreach ($tabId in $tabsClase) {
            $p = if ($info.Points.ContainsKey([int]$tabId)) { $info.Points[[int]$tabId] } else { 0 }
            $pts += $p
            $n = if ($Global:ArmeriaTalentTabNombres.ContainsKey([int]$tabId)) { $Global:ArmeriaTalentTabNombres[[int]$tabId] } else { "Rama $tabId" }
            $nombres += $n
        }
        while ($pts.Count -lt 3) { $pts += 0; $nombres += "-" }
        $lblDist.Text = "$($pts[0]) / $($pts[1]) / $($pts[2])"
        $primIdx = 0
        for ($i = 1; $i -lt 3; $i++) { if ($pts[$i] -gt $pts[$primIdx]) { $primIdx = $i } }
        # Cache para la cabecera de la Armeria (misma deteccion)
        try {
            if (($pts[0]+$pts[1]+$pts[2]) -gt 0 -and $tabsClase -and $tabsClase.Count -gt $primIdx) {
                $tabCache = [int]$tabsClase[$primIdx]
                $nomCache = $nombres[$primIdx]
                $script:ArmeriaSpecDetectada = @{ Guid = [string]$guidChar; Nombre = $nomCache; TabId = $tabCache }
                if ($Global:RootDir) {
                    $dirC = Join-Path $Global:RootDir "Armeria\Cache"
                    if (-not (Test-Path $dirC)) { New-Item -ItemType Directory -Path $dirC -Force | Out-Null }
                    $fc = Join-Path $dirC ("spec_{0}.txt" -f $guidChar)
                    Set-Content -LiteralPath $fc -Value ("{0}|{1}" -f $nomCache, $tabCache) -Encoding UTF8
                }
            }
        } catch {}
        if (($pts[0]+$pts[1]+$pts[2]) -gt 0) {
            $lblTituloTal.Text = "Talentos - $nombreChar  ·  $($nombres[$primIdx])"
            try {
                $tabPrim = [int]$tabsClase[$primIdx]
                if ($Global:ArmeriaTalentTabIconos -and $Global:ArmeriaTalentTabIconos.ContainsKey($tabPrim)) {
                    $imgPrim = Descargar-IconoPorNombre $Global:ArmeriaTalentTabIconos[$tabPrim] 24 ("tab$tabPrim")
                    if ($imgPrim) {
                        $pbTitSpec = $null
                        foreach ($c in $talForm.Controls) {
                            if ($c -is [System.Windows.Forms.PictureBox] -and $c.Tag -eq "specTitleIcon") { $pbTitSpec = $c; break }
                        }
                        if (-not $pbTitSpec) {
                            $pbTitSpec = New-Object System.Windows.Forms.PictureBox
                            $pbTitSpec.Tag = "specTitleIcon"
                            $pbTitSpec.Size = New-Object System.Drawing.Size(24, 24)
                            $pbTitSpec.Location = New-Object System.Drawing.Point(12, 12)
                            $pbTitSpec.SizeMode = 'StretchImage'
                            $pbTitSpec.BackColor = [System.Drawing.Color]::Transparent
                            $talForm.Controls.Add($pbTitSpec)
                            $lblTituloTal.Location = New-Object System.Drawing.Point(40, $lblTituloTal.Location.Y)
                        }
                        $pbTitSpec.Image = $imgPrim
                    }
                }
            } catch {}
        }

        $coloresRama = @(
            [System.Drawing.Color]::FromArgb(180, 80, 60),
            [System.Drawing.Color]::FromArgb(60, 140, 180),
            [System.Drawing.Color]::FromArgb(80, 160, 80)
        )

        for ($ti = 0; $ti -lt $tabsClase.Count; $ti++) {
            $tabId = [int]$tabsClase[$ti]
            $x0 = 8 + $ti * ($TREE_W + 12)

            $panelTree = New-Object System.Windows.Forms.Panel
            $panelTree.Location  = New-Object System.Drawing.Point($x0, 4)
            $panelTree.Size      = New-Object System.Drawing.Size($TREE_W, 620)
            $panelTree.BackColor = [System.Drawing.Color]::FromArgb(22, 20, 18)
            $panelTree.BackgroundImageLayout = 'Stretch'
            $panelArbol.Controls.Add($panelTree)
            try {
                $fondoTree = Descargar-FondoTalento $tabId $TREE_W 620
                if ($fondoTree) { $panelTree.BackgroundImage = $fondoTree }
            } catch {}

            $iconSizeRama = 22
            $pbRama = New-Object System.Windows.Forms.PictureBox
            $pbRama.Location = New-Object System.Drawing.Point(6, 4)
            $pbRama.Size = New-Object System.Drawing.Size($iconSizeRama, $iconSizeRama)
            $pbRama.SizeMode = 'StretchImage'
            $pbRama.BackColor = [System.Drawing.Color]::FromArgb(40, 30, 28, 24)
            $panelTree.Controls.Add($pbRama)
            try {
                if ($Global:ArmeriaTalentTabIconos -and $Global:ArmeriaTalentTabIconos.ContainsKey($tabId)) {
                    $imgRama = Descargar-IconoPorNombre $Global:ArmeriaTalentTabIconos[$tabId] $iconSizeRama ("tab$tabId")
                    if ($imgRama) { $pbRama.Image = $imgRama }
                }
            } catch {}

            $lblRama = New-Object System.Windows.Forms.Label
            $lblRama.Text      = "$($nombres[$ti])  ($($pts[$ti]))"
            $lblRama.Location  = New-Object System.Drawing.Point((6 + $iconSizeRama + 4), 4)
            $lblRama.Size      = New-Object System.Drawing.Size(($TREE_W - $iconSizeRama - 16), 22)
            $lblRama.Font      = $fBoldT
            $lblRama.ForeColor = $coloresRama[$ti % 3]
            $lblRama.TextAlign = 'MiddleLeft'
            $lblRama.BackColor = [System.Drawing.Color]::FromArgb(160, 15, 12, 10)
            $panelTree.Controls.Add($lblRama)

            if (-not $datosTal.Tabs.ContainsKey($tabId)) { continue }
            $talentos = $datosTal.Tabs[$tabId]

            foreach ($tal in $talentos) {
                $rank = 0
                if ($info.Ranks.ContainsKey([int]$tal.Id)) { $rank = [int]$info.Ranks[[int]$tal.Id] }
                $maxR = [int]$tal.Max
                $cx = 12 + ([int]$tal.Col) * ($CELL + $GAP)
                $cy = 30 + ([int]$tal.Tier) * ($CELL + $GAP)

                $spellShow = 0
                if ($rank -gt 0 -and $rank -le $tal.Ranks.Count) {
                    $spellShow = [int]$tal.Ranks[$rank - 1]
                } elseif ($tal.Ranks.Count -gt 0) {
                    $spellShow = [int]$tal.Ranks[0]
                }
                # Icono siempre del rank 1 (misma apariencia visual del talento)
                $spellIconId = 0
                if ($tal.Ranks.Count -gt 0) { $spellIconId = [int]$tal.Ranks[0] }

                $celda = New-Object System.Windows.Forms.Panel
                $celda.Location  = New-Object System.Drawing.Point($cx, $cy)
                $celda.Size      = New-Object System.Drawing.Size($CELL, $CELL)
                if ($rank -ge $maxR -and $maxR -gt 0) {
                    $celda.BackColor = [System.Drawing.Color]::FromArgb(40, 90, 40)
                } elseif ($rank -gt 0) {
                    $celda.BackColor = [System.Drawing.Color]::FromArgb(50, 70, 100)
                } else {
                    $celda.BackColor = [System.Drawing.Color]::FromArgb(35, 30, 28)
                }

                $pbIcon = New-Object System.Windows.Forms.PictureBox
                $pbIcon.Location  = New-Object System.Drawing.Point(2, 2)
                $pbIcon.Size      = New-Object System.Drawing.Size(($CELL - 4), ($CELL - 16))
                $pbIcon.SizeMode  = 'Zoom'
                $pbIcon.BackColor = [System.Drawing.Color]::FromArgb(20, 18, 15)
                $celda.Controls.Add($pbIcon)

                $lblRank = New-Object System.Windows.Forms.Label
                $lblRank.Text      = ("{0}/{1}" -f $rank, $maxR)
                $lblRank.Location  = New-Object System.Drawing.Point(0, ($CELL - 14))
                $lblRank.Size      = New-Object System.Drawing.Size($CELL, 14)
                $lblRank.Font      = $fMiniT
                $lblRank.TextAlign = 'MiddleCenter'
                $lblRank.BackColor = [System.Drawing.Color]::FromArgb(30, 25, 20)
                if ($rank -gt 0) {
                    $lblRank.ForeColor = [System.Drawing.Color]::FromArgb(255, 220, 100)
                } else {
                    $lblRank.ForeColor = [System.Drawing.Color]::FromArgb(120, 110, 100)
                }
                $celda.Controls.Add($lblRank)
                $lblRank.BringToFront()

                # Nombre real desde mapa local (Spell.dbc)
                $nombreTal = $null
                if ($spellIconId -gt 0) {
                    try { $nombreTal = Obtener-NombreSpellTalento $spellIconId } catch {}
                }
                if (-not $nombreTal -and $spellShow -gt 0) {
                    try { $nombreTal = Obtener-NombreSpellTalento $spellShow } catch {}
                }
                if (-not $nombreTal) { $nombreTal = "Talento #" + $tal.Id }

                $tipBase = $nombreTal + "`nRango: $rank / $maxR"
                try {
                    $tooltipTal.SetToolTip($celda, $tipBase)
                    $tooltipTal.SetToolTip($lblRank, $tipBase)
                    $tooltipTal.SetToolTip($pbIcon, $tipBase)
                } catch {}

                $celda.Tag = @{
                    SpellId = $spellShow
                    IconSpellId = $spellIconId
                    Rank = $rank
                    Max = $maxR
                    TalentId = [int]$tal.Id
                    Nombre = $nombreTal
                    IconResolved = $false
                    PbIcon = $pbIcon
                }

                $panelTree.Controls.Add($celda)

                # Icono desde caché si ya existe
                if ($spellIconId -gt 0 -and $Global:RootDir) {
                    try {
                        $cf = Join-Path $Global:RootDir ("Armeria\Imagenes\spells\{0}.jpg" -f $spellIconId)
                        if (Test-Path -LiteralPath $cf) {
                            $imgSp = Descargar-IconoSpell $spellIconId ($CELL - 4)
                            if ($null -ne $imgSp -and $null -ne $pbIcon) {
                                $pbIcon.Image = $imgSp
                                $celda.Tag.IconResolved = $true
                            }
                        }
                    } catch {}
                }
            }
            [System.Windows.Forms.Application]::DoEvents()
        }

        # Segunda pasada: descargar TODOS los iconos de las 3 ramas (evita huecos)
        try {
            if ($null -ne $lblCargandoIconos) {
                $lblCargandoIconos.Text = "Descargando iconos de la clase..."
                $lblCargandoIconos.BringToFront()
            }
        } catch {}
        [System.Windows.Forms.Application]::DoEvents()

        $celdasIcono = @()
        try {
            foreach ($ctrl in @($panelArbol.Controls)) {
                if ($null -eq $ctrl) { continue }
                foreach ($c2 in @($ctrl.Controls)) {
                    if ($null -eq $c2) { continue }
                    $tg = $c2.Tag
                    if ($null -eq $tg) { continue }
                    try {
                        if ($tg.IconResolved) { continue }
                        if ([int]$tg.IconSpellId -le 0) { continue }
                        $celdasIcono += $c2
                    } catch {}
                }
            }
        } catch {}

        $nIcon = 0
        $totalIcon = @($celdasIcono).Count
        foreach ($celdaIt in $celdasIcono) {
            $nIcon++
            try {
                if ($null -ne $lblCargandoIconos) {
                    $lblCargandoIconos.Text = ("Iconos {0}/{1}..." -f $nIcon, $totalIcon)
                }
            } catch {}
            try {
                $tg = $celdaIt.Tag
                if ($null -eq $tg) { continue }
                $isp = [int]$tg.IconSpellId
                $imgSp2 = Descargar-IconoSpell $isp ($CELL - 4)
                if ($null -ne $imgSp2) {
                    $pb = $tg.PbIcon
                    if ($null -ne $pb) {
                        $pb.Image = $imgSp2
                    }
                    $tg.IconResolved = $true
                    $celdaIt.Tag = $tg
                }
            } catch {}
            if (($nIcon % 4) -eq 0) {
                try { [System.Windows.Forms.Application]::DoEvents() } catch {}
            }
        }

        try {
            if ($null -ne $lblCargandoIconos) {
                $lblCargandoIconos.Visible = $false
                $panelArbol.Controls.Remove($lblCargandoIconos)
            }
        } catch {}

        # Glifos de la spec actual
        try { Render-Glifos $specIdx } catch {}
    }

    $btnSpec0 = New-Object System.Windows.Forms.Button
    $btnSpec0.Text = "Especialización 1"
    $btnSpec0.Location = New-Object System.Drawing.Point(6, 3)
    $btnSpec0.Size = New-Object System.Drawing.Size(160, 26)
    $btnSpec0.FlatStyle = 'Flat'
    $btnSpec0.Font = $fPeqT
    $btnSpec0.ForeColor = [System.Drawing.Color]::White
    $panelSpecs.Controls.Add($btnSpec0)

    $btnSpec1 = New-Object System.Windows.Forms.Button
    $btnSpec1.Text = "Especialización 2"
    $btnSpec1.Location = New-Object System.Drawing.Point(172, 3)
    $btnSpec1.Size = New-Object System.Drawing.Size(160, 26)
    $btnSpec1.FlatStyle = 'Flat'
    $btnSpec1.Font = $fPeqT
    $btnSpec1.ForeColor = [System.Drawing.Color]::White
    $panelSpecs.Controls.Add($btnSpec1)

    if ($numSpecs -lt 2) {
        $btnSpec1.Enabled = $false
        $btnSpec1.Text = "Especialización 2 (no disponible)"
        $btnSpec1.Size = New-Object System.Drawing.Size(220, 26)
    }

    Function Actualizar-BotonesSpec {
        $activo = $script:TalentoSpecActual
        $cActivo = [System.Drawing.Color]::FromArgb(80, 50, 10)
        $cInact  = [System.Drawing.Color]::FromArgb(40, 35, 30)
        $bordeAct = [System.Drawing.Color]::FromArgb(255, 210, 0)
        $bordeIn  = [System.Drawing.Color]::FromArgb(80, 70, 60)
        $txt0 = "Especialización 1"
        $txt1 = "Especialización 2"
        if ($activeSpec -eq 0) { $txt0 = "Especialización 1 [ACTIVA]" }
        if ($activeSpec -eq 1) { $txt1 = "Especialización 2 [ACTIVA]" }
        if ($activo -eq 0) {
            $btnSpec0.BackColor = $cActivo
            $btnSpec0.Text = $txt0
            $btnSpec1.BackColor = $cInact
            $btnSpec1.Text = $txt1
            try { $btnSpec0.FlatAppearance.BorderColor = $bordeAct } catch {}
            try { $btnSpec1.FlatAppearance.BorderColor = $bordeIn } catch {}
        } else {
            $btnSpec1.BackColor = $cActivo
            $btnSpec1.Text = $txt1
            $btnSpec0.BackColor = $cInact
            $btnSpec0.Text = $txt0
            try { $btnSpec1.FlatAppearance.BorderColor = $bordeAct } catch {}
            try { $btnSpec0.FlatAppearance.BorderColor = $bordeIn } catch {}
        }
        if ($numSpecs -lt 2) {
            $btnSpec1.Text = "Especialización 2 (no disponible)"
        }
    }

    $btnSpec0.Add_Click({
        $script:TalentoSpecActual = 0
        Actualizar-BotonesSpec
        Render-ArbolTalentos 0
    }.GetNewClosure())
    $btnSpec1.Add_Click({
        if ($numSpecs -lt 2) { return }
        $script:TalentoSpecActual = 1
        Actualizar-BotonesSpec
        Render-ArbolTalentos 1
    }.GetNewClosure())

    if ($tabsClase.Count -eq 0) {
        $lblSin = New-Object System.Windows.Forms.Label
        $lblSin.Text = "No se encontraron ramas de talentos para esta clase (ID $claseId)."
        $lblSin.Location = New-Object System.Drawing.Point(20, 40)
        $lblSin.Size = New-Object System.Drawing.Size(600, 40)
        $lblSin.ForeColor = [System.Drawing.Color]::FromArgb(255, 150, 80)
        $panelArbol.Controls.Add($lblSin)
    } else {
        Actualizar-BotonesSpec
        Render-ArbolTalentos $script:TalentoSpecActual
    }

    $talForm.ShowDialog($formPadre) | Out-Null
}


$Global:ArmeriaColorCalidad = @{
    0=[System.Drawing.Color]::FromArgb(157,157,157)
    1=[System.Drawing.Color]::White
    2=[System.Drawing.Color]::FromArgb(30,255,0)
    3=[System.Drawing.Color]::FromArgb(0,112,221)
    4=[System.Drawing.Color]::FromArgb(163,53,238)
    5=[System.Drawing.Color]::FromArgb(255,128,0)
    6=[System.Drawing.Color]::FromArgb(230,204,128)
    7=[System.Drawing.Color]::FromArgb(0,204,255)
}
$Global:ArmeriaNombreCalidad = @{
    0="Pobre"; 1="Comun"; 2="Poco comun"; 3="Raro"
    4="Epico"; 5="Legendario"; 6="Artefacto"; 7="Herencia"
}

# Posicion visual de cada slot en el paperdoll - estilo WoW con columnas laterales
$Global:ArmeriaPosSlot = @(
    @(8,   10),   # 0  Cabeza
    @(8,   66),   # 1  Cuello
    @(8,  122),   # 2  Hombros
    @(8,  178),   # 3  Camisa
    @(8,  234),   # 4  Pecho
    @(8,  290),   # 5  Cintura
    @(8,  346),   # 6  Piernas
    @(8,  402),   # 7  Pies
    @(414, 10),   # 8  Munecas
    @(414, 66),   # 9  Manos
    @(414,122),   # 10 Anillo 1
    @(414,178),   # 11 Anillo 2
    @(414,234),   # 12 Abalorio 1
    @(414,290),   # 13 Abalorio 2
    @(414,346),   # 14 Espalda
    @(155,480),   # 15 Mano principal
    @(249,480),   # 16 Mano secundaria
    @(343,480),   # 17 A distancia
    @(414,402)    # 18 Tabardo
)
$Global:ArmeriaSlotNombre = @(
    "Cabeza","Cuello","Hombros","Camisa","Pecho","Cintura","Piernas","Pies",
    "Munecas","Manos","Anillo 1","Anillo 2","Abalorio 1","Abalorio 2",
    "Espalda","Mano principal","Mano secundaria","A distancia","Tabardo"
)

$Global:ArmeriaStatNombres = @{
    1="Aguante"; 2="Agilidad"; 3="Fuerza"; 4="Intelecto"; 5="Espiritu"
    6="Armadura"; 7="Poder de ataque"; 12="Critico"; 13="Golpe"
    14="Esquiva"; 15="Parada"; 16="Bloqueo"; 17="Poder hechizos"
    18="Curacion"; 20="Maná cada 5s"; 21="Resistencia arcana"
    22="Resistencia fuego"; 23="Resistencia escarcha"
    24="Resistencia naturaleza"; 25="Resistencia sombra"
    26="Resistencia sagrada"; 28="Pericia"; 31="Penetracion"
    32="Poder de ataque"; 33="Puntuacion critico"; 35="Resistencia"
    36="Velocidad de golpe"; 37="Poder hechizos"; 38="Penetracion hechizo"
    39="Maná cada 5s"; 40="Valoracion bloqueo"; 41="Valoracion esquiva"
    42="Valoracion parada"; 43="Poder ataque distancia"; 44="Valoracion golpe"
    45="Valoracion critico"; 46="Valoracion velocidad golpe"
    49="Valoracion resistencia"; 50="Poder de hechizos"
}

Function Obtener-TooltipItem($entry, $guidItem, $guidChar = $null) {
    try {
        $lines = @()
        $itemsetId = 0
        $sockColors = @(0,0,0)
        $sockBonusId = 0

        try {
            $g0 = (Consulta-ArmeriaWorld "SELECT CONCAT(IFNULL(itemset,0),'|',IFNULL(socketColor_1,0),'|',IFNULL(socketColor_2,0),'|',IFNULL(socketColor_3,0),'|',IFNULL(socketBonus,0)) FROM item_template WHERE entry=$entry;")[0]
            if ($g0) {
                $v = $g0 -split "\|"
                if ($v.Count -ge 5) {
                    $itemsetId = [int]$v[0]
                    $sockColors = @([int]$v[1],[int]$v[2],[int]$v[3])
                    $sockBonusId = [int]$v[4]
                }
            }
        } catch {}

        # Solo WotLK: https://www.wowhead.com/wotlk/  (nunca retail)
        $cacheTipDir = Join-Path $Global:RootDir "Armeria\Items\tooltips"
        if (-not (Test-Path $cacheTipDir)) { New-Item -ItemType Directory -Path $cacheTipDir -Force | Out-Null }
        $cacheTipFile = Join-Path $cacheTipDir "$entry.txt"
        $wowLines = @()

        if (Test-Path $cacheTipFile) {
            try { $wowLines = @(Get-Content $cacheTipFile -Encoding UTF8 | Where-Object { $_.Trim() -ne "" }) } catch {}
        }

        if ($wowLines.Count -eq 0) {
            try {
                $wc = New-Object System.Net.WebClient
                $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
                $wc.Encoding = [System.Text.Encoding]::UTF8
                $xml = $null
                # URLs exclusivamente WotLK 3.3.5
                $urls = @(
                    "https://www.wowhead.com/wotlk/es/item=$entry&xml",
                    "https://www.wowhead.com/wotlk/item=$entry&xml"
                )
                foreach ($url in $urls) {
                    try {
                        $xml = $wc.DownloadString($url)
                        if ($xml -and $xml -match 'htmlTooltip') { break }
                    } catch { $xml = $null }
                }

                if ($xml -match '(?s)<htmlTooltip>(.*?)</htmlTooltip>') {
                    $html = [System.Net.WebUtility]::HtmlDecode($Matches[1])
                    $html = $html -replace '(?i)<br\s*/?>', "`n"
                    $html = $html -replace '(?i)</div>', "`n"
                    $html = $html -replace '(?i)</tr>', "`n"
                    $html = $html -replace '(?i)</p>', "`n"
                    $html = $html -replace '<[^>]+>', ' '
                    $html = $html -replace '&nbsp;', ' '
                    $html = $html -replace '&quot;', '"'
                    $html = $html -replace '&amp;', '&'
                    $html = $html -replace '&lt;', '<'
                    $html = $html -replace '&gt;', '>'
                    $html = $html -replace '\]\]>', ''
                    $html = $html -replace '\r', ''

                    $skip = @(
                        '(?i)^sells?\s*for', '(?i)^precio', '(?i)^vendido',
                        '(?i)^dropped by', '(?i)^bot[ií]n', '(?i)^probabilidad de bot',
                        '(?i)^this item', '(?i)^durability', '(?i)^durabilidad',
                        '(?i)^classes?:', '(?i)^clases?:', '(?i)^set:',
                        '(?i)^\(\d+\)\s', '(?i)^\]\]', '^\s*\[+\s*$', '^\s*\]+\s*$'
                    )

                    $isFirst = $true
                    foreach ($raw in ($html -split "`n")) {
                        $t = ($raw -replace '\s+', ' ').Trim()
                        if (-not $t) { continue }
                        if ($isFirst) { $isFirst = $false; continue }
                        $bad = $false
                        foreach ($p in $skip) { if ($t -match $p) { $bad = $true; break } }
                        if ($bad) { continue }
                        $t = $t -replace '\]\]>', '' -replace '^\s*\[+\s*', '' -replace '\s*\]+\s*$', ''
                        $t = ($t -replace '\s+', ' ').Trim()
                        if (-not $t -or $t.Length -lt 2) { continue }
                        $t = $t -replace '([A-Za-zÁÉÍÓÚáéíóúñÑ]):(\S)', '$1: $2'
                        $wowLines += $t
                    }
                    if ($wowLines.Count -gt 0) {
                        $wowLines | Set-Content $cacheTipFile -Encoding UTF8
                    }
                }
            } catch {}
        }

        # Separa textos pegados de Wowhead ES (armadura, armas, reliquias, anillos...)
        # Ej: "Se liga al equiparlo Muñeca Tela" / "Se liga al equiparlo Una mano Espada" / "Se liga al equiparlo Reliquia"
        $slotTok = 'Mu[\u00f1n]ecas?|Munecas?|Wrist|Cabeza|Cuello|Hombros?|Espalda|Pecho|Camisa|Tabardo|Manos|Cintura|Piernas|Pies|Dedo|Anillo|Abalorio|Head|Neck|Shoulder|Back|Chest|Hands|Waist|Legs|Feet|Finger|Trinket|Una mano|Dos manos|Mano izquierda|Mano derecha|A distancia|Reliquia|One-Hand|Two-Hand|Held In Off-hand|Off Hand|Ranged|Relic|Main Hand'
        $tipoTok = 'Tela|Cuero|Malla|Placas|Cloth|Leather|Mail|Plate|Escudo|Shield'
        $armaTok = 'Espada|Maza|Hacha|Daga|Bast[oó]n|Arco|Ballesta|Arma de fuego|Arma de pu[\u00f1n]o|Lanza|Vara|Varita|Guja|Sword|Mace|Axe|Dagger|Staff|Bow|Crossbow|Gun|Fist|Polearm|Wand|Idol|[IÍ]dolo|Libram|T[oó]tem|Sigil|Sello|Sigilo'
        $unicoTok = '[\u00daU]nico(?:[\s\-]?[Ee]quipado)?|Unique(?:[\s\-]?[Ee]quipped)?'
        $wowLinesNorm = @()
        foreach ($w in $wowLines) {
            $t = "$w"
            # Slot/arma pegado al tipo: ManosMalla / Una manoEspada
            $t = $t -replace "(?i)\b($slotTok)($tipoTok|$armaTok)\b", '$1|||$2'
            # Slot + tipo/arma con espacio: Muñeca Tela / Una mano Espada / Reliquia Ídolo
            $t = $t -replace "(?i)\b($slotTok)\s+($tipoTok|$armaTok)\b", '$1|||$2'
            # Binding + (slot|unico|arma)
            $t = $t -replace "(?i)((?:Se liga|Se convierte|Binds when)[^\n|]*?)(?:\s+)($slotTok|$unicoTok|$armaTok)\b", '$1|||$2'
            # Unico + slot (o al reves)
            $t = $t -replace "(?i)\b($unicoTok)\s+($slotTok)\b", '$1|||$2'
            $t = $t -replace "(?i)\b($slotTok)\s+($unicoTok)\b", '$1|||$2'
            foreach ($part in ($t -split '\|\|\|')) {
                $p = ($part -replace '\s+', ' ').Trim()
                if ($p -and $p.Length -ge 2) { $wowLinesNorm += $p }
            }
        }
        $wowLines = $wowLinesNorm

        $bloqueBase = @(); $bloqueStats = @(); $bloqueEfectos = @()
        foreach ($w in $wowLines) {
            if ($w -match '(?i)^(se liga|se convierte|unique|[\u00fa]nico|nivel de objeto|necesitas ser|requires level|item level)') {
                $bloqueBase += $w
            }
            elseif ($w -match '(?i)^(equipar|uso|use|chance on|probabilidad al|equip:)') {
                $bloqueEfectos += $w
            }
            elseif ($w -match '^[\+\-]\d' -or $w -match '(?i)daño|damage|veloc|speed|armadura|armor|dps|por segundo') {
                $bloqueStats += $w
            }
            elseif ($w -match "(?i)^($tipoTok|$slotTok|$armaTok|$unicoTok|held in|hach)") {
                $bloqueBase += $w
            }
            else { $bloqueStats += $w }
        }
        foreach ($b in @($bloqueBase + $bloqueStats + $bloqueEfectos)) { $lines += $b }

        $gemIds = @()
        $enchRaw = (Consulta-Armeria "SELECT enchantments FROM item_instance WHERE guid=$guidItem;" "acore_characters")[0]
        if ($enchRaw) {
            $enchSlots = $enchRaw.Trim() -split " "
            $enchIds = @()
            for ($i = 0; $i -lt $enchSlots.Count; $i += 3) {
                $idVal = 0
                try { $idVal = [int]$enchSlots[$i] } catch { continue }
                if ($idVal -le 0) { continue }
                $tipo = if ([math]::Floor($i / 3) -le 1) { "Encantamiento" } else { "Gema" }
                $enchIds += @{ Id = $idVal; Tipo = $tipo }
            }
            if ($enchIds.Count -eq 0) {
                for ($i = 0; $i -lt [math]::Min(5, $enchSlots.Count); $i++) {
                    $idVal = 0
                    try { $idVal = [int]$enchSlots[$i] } catch { continue }
                    if ($idVal -le 0) { continue }
                    $tipo = if ($i -le 1) { "Encantamiento" } else { "Gema" }
                    $enchIds += @{ Id = $idVal; Tipo = $tipo }
                }
            }
            foreach ($ench in $enchIds) {
                $enchNombre = Obtener-NombreEncanto $ench.Id
                if (-not $enchNombre) { continue }
                if ($enchNombre.ToLower() -match 'windfury|winfury|flametongue|rockbiter|frostbrand|earthliving|sharpen|weight|oil|poison|scope|adamantite|felsteel|elemental') {
                    $ench.Tipo = "Encantamiento"
                }
                if ($ench.Tipo -eq "Gema") { $gemIds += $ench.Id }
                $lines += "$($ench.Tipo): $enchNombre"
            }
        }

        $mapaSocket = @{1="Meta";2="Rojo";3="Amarillo";4="Azul"}
        for ($s = 0; $s -lt 3; $s++) {
            if ($sockColors[$s] -le 0) { continue }
            $nombreCol = if ($mapaSocket.ContainsKey($sockColors[$s])) { $mapaSocket[$sockColors[$s]] } else { "Socket" }
            $gemaTxt = "vacío"
            if ($gemIds.Count -gt $s) {
                $gn = Obtener-NombreEncanto $gemIds[$s]
                if ($gn) { $gemaTxt = $gn }
            }
            $lines += "Socket $nombreCol`: $gemaTxt"
        }
        if ($sockBonusId -gt 0) {
            $bn = Obtener-NombreEncanto $sockBonusId
            if ($bn) { $lines += "Bonus socket: $bn" }
        }

        if ($itemsetId -gt 0 -and $guidChar) {
            try {
                $setCountRaw = (Consulta-Armeria "SELECT COUNT(*) FROM character_inventory ci JOIN item_instance ii ON ii.guid=ci.item JOIN acore_world.item_template it ON it.entry=ii.itemEntry WHERE ci.guid=$guidChar AND ci.bag=0 AND ci.slot BETWEEN 0 AND 18 AND it.itemset=$itemsetId;" "acore_characters")[0]
                $setCount = 0
                if ($setCountRaw) { $setCount = [int]$setCountRaw.Trim() }
                $setName = $null
                $bonusLines = @()
                $cacheSetsDir = Join-Path $Global:RootDir "Armeria\Sets"
                if (-not (Test-Path $cacheSetsDir)) { New-Item -ItemType Directory -Path $cacheSetsDir -Force | Out-Null }
                $cacheSetFile = Join-Path $cacheSetsDir "$itemsetId.json"
                if (Test-Path $cacheSetFile) {
                    try {
                        $c = Get-Content $cacheSetFile -Raw -Encoding UTF8 | ConvertFrom-Json
                        if ($c.name) { $setName = [string]$c.name }
                        if ($c.bonuses) { foreach ($b in $c.bonuses) { $bonusLines += @{ Thr=[int]$b.thr; Text=[string]$b.text } } }
                    } catch {}
                }
                if (-not $setName -or $bonusLines.Count -eq 0) {
                    try {
                        $wc2 = New-Object System.Net.WebClient
                        $wc2.Headers.Add("User-Agent", "Mozilla/5.0")
                        $wc2.Encoding = [System.Text.Encoding]::UTF8
                        $xml2 = $null
                        foreach ($url in @("https://www.wowhead.com/wotlk/es/item=$entry&xml","https://www.wowhead.com/wotlk/item=$entry&xml")) {
                            try { $xml2 = $wc2.DownloadString($url); if ($xml2 -match 'htmlTooltip') { break } } catch {}
                        }
                        if ($xml2 -match '(?s)<set[^>]*name="([^"]+)"') { $setName = $Matches[1] }
                        if ($xml2 -match '(?s)<htmlTooltip>(.*?)</htmlTooltip>') {
                            $ht = [System.Net.WebUtility]::HtmlDecode($Matches[1])
                            $pl = $ht -replace '<br\s*/?>', "`n" -replace '<[^>]+>', ' ' -replace '&nbsp;', ' '
                            foreach ($ln in ($pl -split "`n")) {
                                $t = ($ln -replace '\s+', ' ').Trim()
                                if ($t -match '^\((\d+)\)\s*(.+)$') {
                                    $thr=[int]$Matches[1]; $tx=$Matches[2].Trim()
                                    if ($tx.Length -gt 3 -and ($bonusLines | Where-Object { $_.Thr -eq $thr }).Count -eq 0) {
                                        $bonusLines += @{ Thr=$thr; Text=$tx }
                                    }
                                }
                            }
                        }
                        if ($setName -or $bonusLines.Count -gt 0) {
                            [PSCustomObject]@{ name=$setName; bonuses=@($bonusLines | ForEach-Object { [PSCustomObject]@{ thr=$_.Thr; text=$_.Text } }) } |
                                ConvertTo-Json -Depth 4 | Set-Content $cacheSetFile -Encoding UTF8
                        }
                    } catch {}
                }
                if (-not $setName) { $setName = "Set #$itemsetId" }
                if ($setCount -gt 0) {
                    $lines += "─────────────"
                    $lines += "Set: $setName ($setCount piezas)"
                    foreach ($b in ($bonusLines | Sort-Object Thr)) {
                        if ($setCount -ge $b.Thr) { $lines += "($($b.Thr)) $($b.Text)  [ACTIVO]" }
                        else { $lines += "($($b.Thr)) $($b.Text)" }
                    }
                }
            } catch {}
        }

        return ($lines -join "`n")
    } catch {
        return ""
    }
}

Function Consulta-ArmeriaWorld($sql) {
    $exe = Join-Path $Global:MysqlDir "mysql.exe"
    $env:MYSQL_PWD = $Global:MysqlAdminPass
    $filas = & $exe "-u$($Global:MysqlAdminUser)" -N -B -e $sql "acore_world" 2>$null
    $env:MYSQL_PWD = ""
    $limpias = @()
    foreach ($f in @($filas)) {
        if ($null -ne $f) {
            $t = $f.TrimEnd("`r")
            if ($t -and $t -notmatch '^(mysql:|Warning|ERROR)') { $limpias += $t }
        }
    }
    return ,$limpias
}

Function Consulta-Armeria($sql, $bd) {
    $exe = Join-Path $Global:MysqlDir "mysql.exe"
    $env:MYSQL_PWD = $Global:MysqlPass
    $filas = & $exe "-u$($Global:MysqlUser)" -N -B -e $sql $bd 2>$null
    $env:MYSQL_PWD = ""
    $limpias = @()
    foreach ($f in @($filas)) {
        if ($null -ne $f) {
            $t = $f.TrimEnd("`r")
            if ($t -and $t -notmatch '^(mysql:|Warning|ERROR)') { $limpias += $t }
        }
    }
    return ,$limpias
}

Function Obtener-RutaCachePersonaje($guid) {
    $dir = Join-Path $Global:RootDir "Armeria\Personajes"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    return Join-Path $dir "$guid.json"
}

Function Guardar-CachePersonaje($guid, $datos) {
    $ruta = Obtener-RutaCachePersonaje $guid
    $datos | ConvertTo-Json -Depth 5 | Set-Content $ruta -Encoding UTF8
}

Function Cargar-CachePersonaje($guid) {
    $ruta = Obtener-RutaCachePersonaje $guid
    if (Test-Path $ruta) {
        try { return Get-Content $ruta -Raw -Encoding UTF8 | ConvertFrom-Json }
        catch { return $null }
    }
    return $null
}

Function Limpiar-CachePersonaje($guid) {
    $ruta = Obtener-RutaCachePersonaje $guid
    if (Test-Path $ruta) {
        Remove-Item -Path $ruta -Force -ErrorAction SilentlyContinue
    }
}

Function Descargar-IconoUI($nombreIcono, $tamanio) {
    try {
        $cacheDir = Join-Path $Global:RootDir "Armeria\Imagenes\ui"
        if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null }
        $cacheFile = Join-Path $cacheDir "$nombreIcono.jpg"

        if (Test-Path $cacheFile) {
            $img = [System.Drawing.Image]::FromFile($cacheFile)
            return $img.GetThumbnailImage($tamanio, $tamanio, $null, [System.IntPtr]::Zero)
        }

        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $bytes = $wc.DownloadData("https://wow.zamimg.com/images/wow/icons/small/$($nombreIcono.ToLower()).jpg")
        [System.IO.File]::WriteAllBytes($cacheFile, $bytes)
        $ms  = New-Object System.IO.MemoryStream(,$bytes)
        $img = [System.Drawing.Image]::FromStream($ms)
        return $img.GetThumbnailImage($tamanio, $tamanio, $null, [System.IntPtr]::Zero)
    } catch {
        return $null
    }
}


Function Descargar-IconoSpell($spellId, $tamanio) {
    # Icono desde mapa local (SpellIcon.dbc) + ZAM CDN. Sin Wowhead.
    $sid = 0
    try { $sid = [int]$spellId } catch { return $null }
    if ($sid -le 0) { return $null }
    if (-not $Global:RootDir) { return $null }

    $sz = 36
    try { if ($tamanio -gt 0) { $sz = [int]$tamanio } } catch {}

    try {
        $cacheDir = Join-Path $Global:RootDir "Armeria\Imagenes\spells"
        if (-not (Test-Path $cacheDir)) {
            New-Item -ItemType Directory -Path $cacheDir -Force -ErrorAction SilentlyContinue | Out-Null
        }
        $cacheFile = Join-Path $cacheDir ("{0}.jpg" -f $sid)

        if (Test-Path -LiteralPath $cacheFile) {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($cacheFile)
                if ($bytes -and $bytes.Length -gt 50) {
                    $ms = New-Object System.IO.MemoryStream(,$bytes)
                    $img = [System.Drawing.Image]::FromStream($ms)
                    $clone = New-Object System.Drawing.Bitmap $img, $sz, $sz
                    $img.Dispose(); $ms.Dispose()
                    return $clone
                }
            } catch {}
        }

        $nombreIcono = $null
        try {
            $local = Obtener-DatosTalentSpellsLocal
            if ($local -and $local.ContainsKey($sid) -and $local[$sid].Icono) {
                $nombreIcono = ([string]$local[$sid].Icono).ToLower().Trim()
            }
        } catch {}
        # Buscar tambien en glifos (mismo SpellId)
        if (-not $nombreIcono) {
            try {
                $gl = Obtener-DatosGlifosLocal
                if ($gl) {
                    foreach ($gk in @($gl.Keys)) {
                        $gv = $gl[$gk]
                        if ($null -ne $gv -and [int]$gv.SpellId -eq $sid -and $gv.Icono) {
                            $cand = ([string]$gv.Icono).ToLower().Trim()
                            if ($cand -and $cand -notmatch '^ui-glyph-rune') {
                                $nombreIcono = $cand
                                break
                            }
                            if (-not $nombreIcono -and $cand) { $nombreIcono = $cand }
                        }
                    }
                }
            } catch {}
        }
        if (-not $nombreIcono) { return $null }

        try {
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent", "Mozilla/5.0")
            $bytes2 = $null
            foreach ($sn in @("medium", "large", "small")) {
                try {
                    $url = "https://wow.zamimg.com/images/wow/icons/$sn/$nombreIcono.jpg"
                    $bytes2 = $wc.DownloadData($url)
                    if ($bytes2 -and $bytes2.Length -gt 50) { break }
                    $bytes2 = $null
                } catch { $bytes2 = $null }
            }
            if (-not $bytes2) { return $null }
            try { [System.IO.File]::WriteAllBytes($cacheFile, $bytes2) } catch {}
            $ms2 = New-Object System.IO.MemoryStream(,$bytes2)
            $img2 = [System.Drawing.Image]::FromStream($ms2)
            $clone2 = New-Object System.Drawing.Bitmap $img2, $sz, $sz
            $img2.Dispose(); $ms2.Dispose()
            return $clone2
        } catch {
            return $null
        }
    } catch {
        return $null
    }
}

Function Descargar-IconoArmeria($entry, $tamanio) {
    try {
        $cacheDir = Join-Path $Global:RootDir "Armeria\Imagenes"
        if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null }
        $cacheFile = Join-Path $cacheDir "$entry.jpg"

        if (Test-Path $cacheFile) {
            $img = [System.Drawing.Image]::FromFile($cacheFile)
            return $img.GetThumbnailImage($tamanio, $tamanio, $null, [System.IntPtr]::Zero)
        }

        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $xml = $wc.DownloadString("https://www.wowhead.com/wotlk/item=$entry&xml")

        if ($xml -match '<icon[^>]*>([^<]+)</icon>') {
            $nombreIcono = $Matches[1].ToLower()
            $imgUrl  = "https://wow.zamimg.com/images/wow/icons/large/$nombreIcono.jpg"
            $bytes   = $wc.DownloadData($imgUrl)

            [System.IO.File]::WriteAllBytes($cacheFile, $bytes)

            $ms  = New-Object System.IO.MemoryStream(,$bytes)
            $img = [System.Drawing.Image]::FromStream($ms)
            return $img.GetThumbnailImage($tamanio, $tamanio, $null, [System.IntPtr]::Zero)
        }
        return $null
    } catch {
        return $null
    }
}

Function Crear-SlotVacio($x, $y, $tamanio, $nombreSlot, $tooltip) {
    $BORDE = 2
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location  = New-Object System.Drawing.Point($x, $y)
    $panel.Size      = New-Object System.Drawing.Size($tamanio, $tamanio)
    $panel.BackColor = [System.Drawing.Color]::FromArgb(45, 40, 35)

    $pb = New-Object System.Windows.Forms.PictureBox
    $pb.Location  = New-Object System.Drawing.Point($BORDE, $BORDE)
    $pb.Size      = New-Object System.Drawing.Size(($tamanio - $BORDE*2), ($tamanio - $BORDE*2))
    $pb.BackColor = [System.Drawing.Color]::FromArgb(20, 15, 12)
    $pb.SizeMode  = 'StretchImage'
    $panel.Controls.Add($pb)

    $tooltip.SetToolTip($panel, $nombreSlot)
    $tooltip.SetToolTip($pb, $nombreSlot)
    $panel.Tag = $pb
    return $panel
}


# ==========================================
# MÓDULO: PvP (honor, arenas, kills, títulos)
# ==========================================
# Títulos PvP frecuentes WotLK (CharTitles.dbc) — bit en knownTitles
$Global:ArmeriaTitulosPvP = @{
    1  = "Private / Scout"
    2  = "Corporal / Grunt"
    3  = "Sergeant"
    4  = "Master Sergeant / Senior Sergeant"
    5  = "Sergeant Major / First Sergeant"
    6  = "Knight / Stone Guard"
    7  = "Knight-Lieutenant / Blood Guard"
    8  = "Knight-Captain / Legionnaire"
    9  = "Knight-Champion / Centurion"
    10 = "Lieutenant Commander / Champion"
    11 = "Commander / Lieutenant General"
    12 = "Marshal / General"
    13 = "Field Marshal / Warlord"
    14 = "Grand Marshal / High Warlord"
    15 = "Knight of the Ebon Blade"
    28 = "Gladiator"
    29 = "Duelist"
    30 = "Rival"
    31 = "Challenger"
    42 = "Justicar"
    43 = "Conqueror"
    44 = "Disciples of the Nameless One"
    45 = "of the Alliance / of the Horde"
    48 = "Arena Master"
    62 = "Battlemaster"
    64 = "the Flawless Victor"
    66 = "Vanquisher"
    72 = "Warlord of Draenor"
    77 = "of the Shattered Sun"
    126 = "of the Ashen Verdict"
    142 = "the Argent Defender"
    143 = "the Patient"
    151 = "of the Alliance"
    152 = "of the Horde"
    157 = "Crusader"
    163 = "of the Nightfall"
    167 = "Starcaller"
    168 = "the Astral Walker"
    169 = "Herald of the Titans"
    170 = "Champion of Elune"
    171 = "Grand Crusader"
    172 = "the Argent Champion"
    173 = "the Immortal"
    174 = "the Undying"
    175 = "Jenkins"
    176 = "Bloodsail Admiral"
    177 = "the Insane"
    188 = "of the Exodar"
    189 = "of Darnassus"
    190 = "of Ironforge"
    191 = "of Stormwind"
    192 = "of Orgrimmar"
    193 = "of Sen'jin"
    194 = "of Silvermoon"
    195 = "of Thunder Bluff"
    196 = "of the Undercity"
    197 = "the Diplomat"
    198 = "the Explorer"
    209 = "Veteran of the Alliance"
    210 = "Warbound"
    211 = "Veteran of the Horde"
    220 = "the Kingslayer"
    221 = "of the Ashen Verdict"
    226 = "Hero of the Alliance"
    227 = "Hero of the Horde"
    228 = "the Hallowed"
    229 = "Loremaster"
    230 = "of the Alliance"
    231 = "of the Horde"
    232 = "the Bloodthirsty"
    242 = "Ambassador"
    247 = "the Exalted"
    250 = "Elder"
}

Function Test-TituloConocido($knownTitlesRaw, $titleId) {
    # knownTitles en AC suele ser cadena de bits / hex / números separados
    if (-not $knownTitlesRaw -or $titleId -le 0) { return $false }
    try {
        $tid = [int]$titleId
        $raw = $knownTitlesRaw.ToString().Trim()
        if ($raw -eq "" -or $raw -eq "0") { return $false }
        # Formato frecuente: varios UInt32/UInt64 separados por espacio
        $nums = @()
        foreach ($part in ($raw -split "[\s,;]+")) {
            if (-not $part) { continue }
            try {
                if ($part -match '^0x') { $nums += [Convert]::ToUInt64($part, 16) }
                else { $nums += [Convert]::ToUInt64($part) }
            } catch {}
        }
        if ($nums.Count -eq 0) { return $false }
        $bitIndex = $tid - 1
        $word = [int][math]::Floor($bitIndex / 32)
        $bit  = $bitIndex % 32
        if ($word -ge $nums.Count) {
            # probar con palabras de 64 bits
            $word64 = [int][math]::Floor($bitIndex / 64)
            $bit64  = $bitIndex % 64
            if ($word64 -lt $nums.Count) {
                $mask64 = [UInt64]1 -shl $bit64
                return (($nums[$word64] -band $mask64) -ne 0)
            }
            return $false
        }
        $mask = [UInt64]1 -shl $bit
        return (($nums[$word] -band $mask) -ne 0)
    } catch { return $false }
}

Function Mostrar-VentanaPvP($guidChar, $nombreChar, $formPadre) {
    $fBoldP = New-Object System.Drawing.Font("Georgia", 9.5, [System.Drawing.FontStyle]::Bold)
    $fPeqP  = New-Object System.Drawing.Font("Georgia", 8)
    $fSecP  = New-Object System.Drawing.Font("Georgia", 9, [System.Drawing.FontStyle]::Bold)
    $fTitP  = New-Object System.Drawing.Font("Georgia", 13, [System.Drawing.FontStyle]::Bold)
    $fMiniP = New-Object System.Drawing.Font("Georgia", 7.5)
    $pvpForm = New-Object System.Windows.Forms.Form
    $pvpForm.Text = "PvP - $nombreChar"; $pvpForm.Size = New-Object System.Drawing.Size(500, 620)
    $pvpForm.StartPosition = 'CenterParent'; $pvpForm.BackColor = [System.Drawing.Color]::FromArgb(15, 12, 10)
    $pvpForm.ForeColor = [System.Drawing.Color]::FromArgb(230, 210, 180); $pvpForm.FormBorderStyle = 'FixedDialog'
    $pvpForm.MaximizeBox = $false; $pvpForm.MinimizeBox = $false
    $lblTit = New-Object System.Windows.Forms.Label; $lblTit.Text = "PvP - $nombreChar"
    $lblTit.Location = New-Object System.Drawing.Point(12, 10); $lblTit.Size = New-Object System.Drawing.Size(460, 24)
    $lblTit.Font = $fTitP; $lblTit.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0); $pvpForm.Controls.Add($lblTit)
    $panelStatsP = New-Object System.Windows.Forms.Panel; $panelStatsP.Location = New-Object System.Drawing.Point(12, 40)
    $panelStatsP.Size = New-Object System.Drawing.Size(460, 530); $panelStatsP.BackColor = [System.Drawing.Color]::FromArgb(22, 20, 18)
    $panelStatsP.BackgroundImageLayout = 'Stretch'
    $panelStatsP.AutoScroll = $true; $pvpForm.Controls.Add($panelStatsP)
    try {
        $fondoPvp = Descargar-FondoPvP 460 800
        if ($fondoPvp) { $panelStatsP.BackgroundImage = $fondoPvp }
    } catch {}
    $honor = 0; $arenaPts = 0; $today = 0; $total = 0
    try {
        $row = (Consulta-Armeria "SELECT CONCAT(IFNULL(totalHonorPoints,0),'|',IFNULL(arenaPoints,0),'|',IFNULL(todayKills,0),'|',IFNULL(totalKills,0)) FROM characters WHERE guid=$guidChar;" "acore_characters")[0]
        if ($row) { $p = $row.Trim() -split "\|"; if ($p.Count -ge 1) { try { $honor = [long]$p[0] } catch {} }; if ($p.Count -ge 2) { try { $arenaPts = [long]$p[1] } catch {} }; if ($p.Count -ge 3) { try { $today = [long]$p[2] } catch {} }; if ($p.Count -ge 4) { try { $total = [long]$p[3] } catch {} } }
    } catch {}
    $mmrMap = @{}
    try { foreach ($ln in @(Consulta-Armeria "SELECT CONCAT(slot,'|',IFNULL(matchmakerRating,0),'|',IFNULL(maxMMR,0)) FROM character_arena_stats WHERE guid=$guidChar;" "acore_characters")) { $pm = "$ln" -split "\|"; if ($pm.Count -lt 2) { continue }; $sid = 0; $mmr = 0; $maxM = 0; try { $sid = [int]$pm[0].Trim() } catch { continue }; try { $mmr = [int]$pm[1].Trim() } catch {}; if ($pm.Count -ge 3) { try { $maxM = [int]$pm[2].Trim() } catch {} }; $mmrMap[$sid] = @{ MMR = $mmr; MaxMMR = $maxM } } } catch {}
    $equiposPorTipo = @{}
    try {
        foreach ($ln in @(Consulta-Armeria "SELECT CONCAT(IFNULL(at.type,0),'|',IFNULL(at.name,''),'|',IFNULL(at.rating,0),'|',IFNULL(at.rank,0),'|',IFNULL(at.seasonGames,0),'|',IFNULL(at.seasonWins,0),'|',IFNULL(at.weekGames,0),'|',IFNULL(at.weekWins,0),'|',IFNULL(atm.personalRating,0),'|',IFNULL(atm.seasonGames,0),'|',IFNULL(atm.seasonWins,0),'|',IFNULL(atm.weekGames,0),'|',IFNULL(atm.weekWins,0),'|',IFNULL(at.arenaTeamId,0),'|',IFNULL(at.captainGuid,0)) FROM arena_team_member atm JOIN arena_team at ON at.arenaTeamId=atm.arenaTeamId WHERE atm.guid=$guidChar ORDER BY at.type;" "acore_characters")) {
            $pe = "$ln" -split "\|"; if ($pe.Count -lt 8) { continue }; $tipo = 0; try { $tipo = [int]$pe[0].Trim() } catch { continue }
            $equiposPorTipo[$tipo] = @{ Nombre=$pe[1].Trim(); Rating=[int]$pe[2].Trim(); Rank=[int]$pe[3].Trim(); SeasonG=[int]$pe[4].Trim(); SeasonW=[int]$pe[5].Trim(); WeekG=[int]$pe[6].Trim(); WeekW=[int]$pe[7].Trim(); PersR=if($pe.Count-ge9){[int]$pe[8].Trim()}else{0}; PersSG=if($pe.Count-ge10){[int]$pe[9].Trim()}else{0}; PersSW=if($pe.Count-ge11){[int]$pe[10].Trim()}else{0}; PersWG=if($pe.Count-ge12){[int]$pe[11].Trim()}else{0}; PersWW=if($pe.Count-ge13){[int]$pe[12].Trim()}else{0}; TeamId=if($pe.Count-ge14){[int]$pe[13].Trim()}else{0}; Captain=if($pe.Count-ge15){[int]$pe[14].Trim()}else{0} }
        }
    } catch {}
    $script:y = 6
    $cDorado=[System.Drawing.Color]::FromArgb(255,200,80); $cAzul=[System.Drawing.Color]::FromArgb(100,180,255); $cRojo=[System.Drawing.Color]::FromArgb(255,120,100); $cVerde=[System.Drawing.Color]::FromArgb(100,220,100); $cBlanco=[System.Drawing.Color]::White; $cNaranja=[System.Drawing.Color]::FromArgb(255,160,60); $cGris=[System.Drawing.Color]::FromArgb(160,150,130); $cCapitan=[System.Drawing.Color]::FromArgb(255,210,0)
    Function Add-PvpFila([string]$n,$v,$c) { $ln=New-Object System.Windows.Forms.Label; $ln.Text=$n; $ln.Location=New-Object System.Drawing.Point(10,$script:y); $ln.Size=New-Object System.Drawing.Size(230,16); $ln.Font=$fPeqP; $ln.ForeColor=[System.Drawing.Color]::FromArgb(200,190,170); $panelStatsP.Controls.Add($ln); $lv=New-Object System.Windows.Forms.Label; $lv.Text=[string]$v; $lv.Location=New-Object System.Drawing.Point(245,$script:y); $lv.Size=New-Object System.Drawing.Size(185,16); $lv.Font=$fBoldP; $lv.ForeColor=$c; $lv.TextAlign='MiddleRight'; $panelStatsP.Controls.Add($lv); $script:y += 17 }
    Function Add-PvpSeccion([string]$t,$c) { $script:y += 4; $ls=New-Object System.Windows.Forms.Label; $ls.Text="── $t ──"; $ls.Location=New-Object System.Drawing.Point(6,$script:y); $ls.Size=New-Object System.Drawing.Size(430,18); $ls.Font=$fSecP; $ls.ForeColor=$c; $ls.TextAlign='MiddleCenter'; $panelStatsP.Controls.Add($ls); $script:y += 20 }
    Add-PvpSeccion "General" ([System.Drawing.Color]::FromArgb(255,210,0)); Add-PvpFila "Honor total" $honor $cDorado; Add-PvpFila "Puntos de arena" $arenaPts $cAzul; Add-PvpFila "Muertes de hoy" $today $cRojo; Add-PvpFila "Muertes totales" $total $cRojo
    foreach ($ta in @(@{Tipo=2;Slot=0;Nombre="2c2"},@{Tipo=3;Slot=1;Nombre="3c3"},@{Tipo=5;Slot=2;Nombre="5c5"})) {
        $eq = if ($equiposPorTipo.ContainsKey($ta.Tipo)) { $equiposPorTipo[$ta.Tipo] } else { $null }
        $mmrInfo = if ($mmrMap.ContainsKey($ta.Slot)) { $mmrMap[$ta.Slot] } else { $null }
        Add-PvpSeccion $(if ($eq) { "$($ta.Nombre)  ·  $($eq.Nombre)" } else { $ta.Nombre }) $cNaranja
        if ($eq) {
            $sL=[math]::Max(0,$eq.SeasonG-$eq.SeasonW); $wL=[math]::Max(0,$eq.WeekG-$eq.WeekW); $pLS=[math]::Max(0,$eq.PersSG-$eq.PersSW); $pLW=[math]::Max(0,$eq.PersWG-$eq.PersWW)
            $pctS=if($eq.SeasonG-gt0){[math]::Round(($eq.SeasonW/$eq.SeasonG)*100)}else{0}; $pctW=if($eq.WeekG-gt0){[math]::Round(($eq.WeekW/$eq.WeekG)*100)}else{0}
            Add-PvpFila "Índice de equipo" $eq.Rating $cDorado; if ($eq.Rank -gt 0) { Add-PvpFila "Rango del equipo" $eq.Rank $cBlanco }
            Add-PvpFila "Rating personal" $eq.PersR $cAzul
            if ($mmrInfo) { Add-PvpFila "MMR" $mmrInfo.MMR $cVerde; if ($mmrInfo.MaxMMR -gt 0) { Add-PvpFila "MMR máximo" $mmrInfo.MaxMMR $cVerde } }
            Add-PvpFila "Esta semana (equipo)" "$($eq.WeekG) jug. · $($eq.WeekW)-$wL ($pctW%)" $cBlanco
            Add-PvpFila "Temporada (equipo)" "$($eq.SeasonG) jug. · $($eq.SeasonW)-$sL ($pctS%)" $cBlanco
            Add-PvpFila "Personal (semana)" "$($eq.PersWG) jug. · $($eq.PersWW)-$pLW" $cBlanco
            Add-PvpFila "Personal (temporada)" "$($eq.PersSG) jug. · $($eq.PersSW)-$pLS" $cBlanco
            if ($eq.TeamId -gt 0) {
                $script:y += 2; $hm=New-Object System.Windows.Forms.Label; $hm.Text="Miembros"; $hm.Location=New-Object System.Drawing.Point(10,$script:y); $hm.Size=New-Object System.Drawing.Size(420,14); $hm.Font=$fMiniP; $hm.ForeColor=$cGris; $panelStatsP.Controls.Add($hm); $script:y += 15
                $hd=New-Object System.Windows.Forms.Label; $hd.Text="Nombre                  Clase            Jug.   V-D      Índice"; $hd.Location=New-Object System.Drawing.Point(10,$script:y); $hd.Size=New-Object System.Drawing.Size(420,14); $hd.Font=$fMiniP; $hd.ForeColor=$cGris; $panelStatsP.Controls.Add($hd); $script:y += 15
                try {
                    foreach ($mln in @(Consulta-Armeria "SELECT CONCAT(IFNULL(c.name,''),'|',IFNULL(c.class,0),'|',IFNULL(atm.seasonGames,0),'|',IFNULL(atm.seasonWins,0),'|',IFNULL(atm.personalRating,0),'|',IFNULL(atm.guid,0)) FROM arena_team_member atm JOIN characters c ON c.guid=atm.guid WHERE atm.arenaTeamId=$($eq.TeamId) ORDER BY atm.personalRating DESC;" "acore_characters")) {
                        $pm="$mln" -split "\|"; if ($pm.Count -lt 5) { continue }
                        $mN=$pm[0].Trim(); $mC=0;$mSG=0;$mSW=0;$mPR=0;$mG=0; try{$mC=[int]$pm[1].Trim()}catch{}; try{$mSG=[int]$pm[2].Trim()}catch{}; try{$mSW=[int]$pm[3].Trim()}catch{}; try{$mPR=[int]$pm[4].Trim()}catch{}; if($pm.Count-ge6){try{$mG=[int]$pm[5].Trim()}catch{}}
                        $mCl=if($Global:ArmeriaClases.ContainsKey($mC)){$Global:ArmeriaClases[$mC]}else{"?"}; $mL=[math]::Max(0,$mSG-$mSW)
                        $esCap=($mG -gt 0 -and $mG -eq $eq.Captain); $pref=if($esCap){"★ "}else{"  "}; $col=if($esCap){$cCapitan}elseif($mG -eq [int]$guidChar){$cVerde}else{$cBlanco}
                        $fm=New-Object System.Windows.Forms.Label; $fm.Text=("{0}{1,-18} {2,-14} {3,4}  {4,3}-{5,-3}  {6,5}" -f $pref,$mN,$mCl,$mSG,$mSW,$mL,$mPR); $fm.Location=New-Object System.Drawing.Point(10,$script:y); $fm.Size=New-Object System.Drawing.Size(420,15); $fm.Font=$fMiniP; $fm.ForeColor=$col; $panelStatsP.Controls.Add($fm); $script:y += 15
                    }
                } catch {}
            }
        } else {
            $ls=New-Object System.Windows.Forms.Label; $ls.Text="Sin equipo de arena"; $ls.Location=New-Object System.Drawing.Point(10,$script:y); $ls.Size=New-Object System.Drawing.Size(400,16); $ls.Font=$fPeqP; $ls.ForeColor=$cGris; $panelStatsP.Controls.Add($ls); $script:y += 17
            if ($mmrInfo -and $mmrInfo.MMR -gt 0) { Add-PvpFila "MMR" $mmrInfo.MMR $cVerde; if ($mmrInfo.MaxMMR -gt 0) { Add-PvpFila "MMR máximo" $mmrInfo.MaxMMR $cVerde } }
        }
    }
    $pvpForm.ShowDialog($formPadre) | Out-Null
}


# Iconos de botones de la Armeria (PvP, Talentos, etc.)
# Personalizables: coloca PNG/JPG en Imagenes\armeria\ con nombres:
#   pvp.png, talentos.png, reputaciones.png, logros.png, transmog.png, establos.png
# Tambien acepta el nombre del icono Wowhead (ej. achievement_general.png)
Function global:Armeria-ObtenerIconoAccion($clave, $tamanio) {
    try {
        $sz = 28
        try { if ($tamanio -gt 0) { $sz = [int]$tamanio } } catch {}
        $key = ([string]$clave).ToLower().Trim()
        if (-not $key) { return $null }

        $aliasWow = @{
            "pvp"           = "achievement_bg_killxenemies_generalsroom"
            "talentos"      = "ability_marksmanship"
            "reputaciones"  = "achievement_reputation_01"
            "logros"        = "achievement_general"
            "transmog"      = "inv_chest_cloth_17"
            "establos"      = "ability_mount_ridinghorse"
        }
        $wow = $key
        if ($aliasWow.ContainsKey($key)) { $wow = $aliasWow[$key] }

        $dirs = @()
        if ($Global:ImgDir) {
            $dirs += (Join-Path $Global:ImgDir "armeria")
            $dirs += (Join-Path $Global:ImgDir "menu")
        }
        if ($Global:AppRoot) {
            $dirs += (Join-Path $Global:AppRoot "Imagenes\armeria")
            $dirs += (Join-Path $Global:AppRoot "Imagenes\menu")
        }
        if ($Global:RootDir) {
            $dirs += (Join-Path $Global:RootDir "Armeria\Imagenes\armeria")
            $dirs += (Join-Path (Split-Path -Parent $Global:RootDir) "Imagenes\armeria")
            $dirs += (Join-Path (Split-Path -Parent $Global:RootDir) "Imagenes\menu")
        }
        $candidatos = @($key, ("armeria_" + $key), $wow) | Select-Object -Unique
        $exts = @(".png", ".jpg", ".jpeg", ".bmp", ".gif")
        foreach ($dir in $dirs) {
            if (-not $dir -or -not (Test-Path -LiteralPath $dir)) { continue }
            foreach ($c in $candidatos) {
                foreach ($ext in $exts) {
                    $fp = Join-Path $dir ($c + $ext)
                    if (Test-Path -LiteralPath $fp) {
                        try {
                            $img = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $fp).Path)
                            $bmp = New-Object System.Drawing.Bitmap $sz, $sz
                            $g = [System.Drawing.Graphics]::FromImage($bmp)
                            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                            $g.DrawImage($img, 0, 0, $sz, $sz)
                            $g.Dispose(); $img.Dispose()
                            return $bmp
                        } catch {}
                    }
                }
            }
        }

        try {
            if (Get-Command Descargar-IconoUI -ErrorAction SilentlyContinue) {
                $ic = Descargar-IconoUI $wow $sz
                if ($ic) { return $ic }
            }
        } catch {}
        return $null
    } catch { return $null }
}

Function global:Armeria-CrearBotonIcono($x, $y, $clave, $tooltipTxt, $colorBg, $tooltip, $szBtn = 48) {
    try { $szBtn = [int]$szBtn } catch { $szBtn = 48 }
    if ($szBtn -lt 28) { $szBtn = 28 }
    $iconSz = [math]::Max(20, $szBtn - 8)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Size = New-Object System.Drawing.Size($szBtn, $szBtn)
    $btn.FlatStyle = 'Flat'
    $btn.FlatAppearance.BorderSize = 1
    $btn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $btn.BackColor = $colorBg
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Text = ""
    $btn.Enabled = $false
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.ImageAlign = 'MiddleCenter'
    $btn.TextAlign = 'MiddleCenter'
    $btn.TextImageRelation = 'Overlay'
    $btn.Padding = New-Object System.Windows.Forms.Padding(0)
    try {
        $ic = Armeria-ObtenerIconoAccion $clave $iconSz
        if ($ic) {
            $btn.Image = $ic
            $btn.Text = ""
        } else {
            $btn.Text = ($clave.Substring(0,1).ToUpper())
            $btn.Font = New-Object System.Drawing.Font("Georgia", 14, [System.Drawing.FontStyle]::Bold)
        }
    } catch {
        try { $btn.Text = ($clave.Substring(0,1).ToUpper()) } catch { $btn.Text = "?" }
    }
    try {
        if ($tooltip) { $tooltip.SetToolTip($btn, $tooltipTxt) }
    } catch {}
    return $btn
}


Function Abrir-PanelArmeria($formPadre, $nombreInicial = $null) {
    $SLOT_SIZE = 48

    $profNombres = @{
        164="Herreria"; 165="Peleteria"; 171="Alquimia"; 182="Herboristeria"
        185="Cocina"; 186="Mineria"; 197="Sastreria"; 202="Ingenieria"
        333="Encantamiento"; 393="Desuello"; 755="Joyeria"; 773="Inscripcion"
        129="Primeros auxilios"; 356="Pesca"
    }
    $profColores = @{
        164=[System.Drawing.Color]::FromArgb(160,120,60);   165=[System.Drawing.Color]::FromArgb(139,90,43)
        171=[System.Drawing.Color]::FromArgb(130,60,180);   182=[System.Drawing.Color]::FromArgb(50,160,50)
        185=[System.Drawing.Color]::FromArgb(200,100,30);   186=[System.Drawing.Color]::FromArgb(120,120,130)
        197=[System.Drawing.Color]::FromArgb(80,120,200);   202=[System.Drawing.Color]::FromArgb(100,180,180)
        333=[System.Drawing.Color]::FromArgb(255,200,0);    393=[System.Drawing.Color]::FromArgb(160,80,40)
        755=[System.Drawing.Color]::FromArgb(0,200,200);    773=[System.Drawing.Color]::FromArgb(180,60,60)
        129=[System.Drawing.Color]::FromArgb(200,200,200);  356=[System.Drawing.Color]::FromArgb(30,130,200)
    }

    $armForm = New-Object System.Windows.Forms.Form
    $armForm.Text = "Armeria de Personajes"
    $armForm.Size = New-Object System.Drawing.Size(1060, 850)
    try {
        $scr = $null
        if ($formPadre -and -not $formPadre.IsDisposed) { $scr = [System.Windows.Forms.Screen]::FromControl($formPadre) }
        if (-not $scr) { $scr = [System.Windows.Forms.Screen]::PrimaryScreen }
        $wa = $scr.WorkingArea
        $nuevoAncho = [math]::Min(1060, $wa.Width - 60)
        $nuevoAlto = [math]::Min(850, $wa.Height - 80)
        if ($nuevoAncho -gt ($wa.Width - 30)) { $nuevoAncho = $wa.Width - 30 }
        if ($nuevoAlto -gt ($wa.Height - 30)) { $nuevoAlto = $wa.Height - 30 }
        if ($nuevoAncho -lt 900) { $nuevoAncho = [math]::Min(900, $wa.Width - 20) }
        if ($nuevoAlto -lt 520) { $nuevoAlto = [math]::Min(520, $wa.Height - 20) }
        $armForm.Size = New-Object System.Drawing.Size($nuevoAncho, $nuevoAlto)
    } catch {}
    $fNormal = New-Object System.Drawing.Font("Georgia", 9)
    $fBold = New-Object System.Drawing.Font("Georgia", 9.5, [System.Drawing.FontStyle]::Bold)
    $fPeq = New-Object System.Drawing.Font("Georgia", 8)
    $fTitle = New-Object System.Drawing.Font("Georgia", 20, [System.Drawing.FontStyle]::Bold)
    $sepVert2 = New-Object System.Windows.Forms.Panel
    $sepVert2.BackColor = [System.Drawing.Color]::FromArgb(60, 50, 40)
    $sepVert2.Location = New-Object System.Drawing.Point(520, 150)
    $sepVert2.Size = New-Object System.Drawing.Size(1, 680)
    $armForm.Controls.Add($sepVert2)
    $lblStatsTitulo = New-Object System.Windows.Forms.Label
    $lblStatsTitulo.Text = "Estadisticas"
    $lblStatsTitulo.Location = New-Object System.Drawing.Point(530, 150)
    $lblStatsTitulo.Size = New-Object System.Drawing.Size(230, 20)
    $lblStatsTitulo.Font = $fBold
    $lblStatsTitulo.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $armForm.Controls.Add($lblStatsTitulo)
    $panelStats = New-Object System.Windows.Forms.Panel
    $panelStats.Location = New-Object System.Drawing.Point(530, 175)
    $panelStats.Size = New-Object System.Drawing.Size(230, 650)
    $panelStats.BackColor = [System.Drawing.Color]::FromArgb(20, 18, 15)
    $panelStats.AutoScroll = $false
    $armForm.Controls.Add($panelStats)
    $sepVert3 = New-Object System.Windows.Forms.Panel
    $sepVert3.BackColor = [System.Drawing.Color]::FromArgb(60, 50, 40)
    $sepVert3.Location = New-Object System.Drawing.Point(790, 150)
    $sepVert3.Size = New-Object System.Drawing.Size(1, 680)
    $armForm.Controls.Add($sepVert3)
    $armForm.StartPosition = 'CenterParent'
    $armForm.BackColor = [System.Drawing.Color]::FromArgb(15, 12, 10)
    $armForm.ForeColor = [System.Drawing.Color]::FromArgb(230, 210, 180)
    $armForm.FormBorderStyle = 'Sizable'
    $armForm.MaximizeBox = $true
    $armForm.MinimizeBox = $true
    $armForm.MinimumSize = New-Object System.Drawing.Size(900, 520)
    $tooltip = New-Object System.Windows.Forms.ToolTip
    $tooltip.AutoPopDelay = 8000; $tooltip.InitialDelay = 400; $tooltip.ReshowDelay = 200; $tooltip.ShowAlways = $true
    $tooltip.OwnerDraw = $true
    $tooltip.BackColor = [System.Drawing.Color]::FromArgb(20, 18, 15)
    $tooltip.ForeColor = [System.Drawing.Color]::FromArgb(230, 210, 180)
    $tooltip.Add_Popup({
        param($sender, $e)
        $txt = $tooltip.GetToolTip($e.AssociatedControl)
        if (-not $txt) { $e.ToolTipSize = New-Object System.Drawing.Size(120, 24); return }
        $fontTip = New-Object System.Drawing.Font("Georgia", 8.5)
        $maxW = 0; $totalH = 6
        foreach ($ln in ($txt -split "`n")) {
            $sz = [System.Windows.Forms.TextRenderer]::MeasureText($ln, $fontTip)
            if ($sz.Width -gt $maxW) { $maxW = $sz.Width }
            $totalH += $sz.Height + 1
        }
        $e.ToolTipSize = New-Object System.Drawing.Size(($maxW + 18), ($totalH + 6))
        $fontTip.Dispose()
    })
    $tooltip.Add_Draw({
        param($sender, $e)
        $g = $e.Graphics
        $g.Clear([System.Drawing.Color]::FromArgb(20, 18, 15))
        $txt = $tooltip.GetToolTip($e.AssociatedControl)
        if (-not $txt) { return }
        $colorCalidad = [System.Drawing.Color]::FromArgb(230, 210, 180)
        $mapaCal = @{
            "Pobre"=[System.Drawing.Color]::FromArgb(157,157,157); "Comun"=[System.Drawing.Color]::White
            "Poco comun"=[System.Drawing.Color]::FromArgb(30,255,0); "Raro"=[System.Drawing.Color]::FromArgb(0,112,221)
            "Epico"=[System.Drawing.Color]::FromArgb(163,53,238); "Legendario"=[System.Drawing.Color]::FromArgb(255,128,0)
            "Artefacto"=[System.Drawing.Color]::FromArgb(230,204,128); "Herencia"=[System.Drawing.Color]::FromArgb(0,204,255)
        }
        foreach ($k in $mapaCal.Keys) { if ($txt -match [regex]::Escape($k)) { $colorCalidad = $mapaCal[$k]; break } }
        $penBorde = New-Object System.Drawing.Pen($colorCalidad, 2)
        $g.DrawRectangle($penBorde, 1, 1, ($e.Bounds.Width - 3), ($e.Bounds.Height - 3))
        $penBorde.Dispose()
        $fontTip = New-Object System.Drawing.Font("Georgia", 8.5)
        $fontBold = New-Object System.Drawing.Font("Georgia", 8.5, [System.Drawing.FontStyle]::Bold)
        $brushNormal = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230,210,180))
        $brushVerde = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30,255,0))
        $brushCal = New-Object System.Drawing.SolidBrush($colorCalidad)
        $brushGris = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(160,150,130))
        $brushAzul = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100,180,255))
        $brushGrisClaro = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120,110,100))
        $y = 5; $x = 7; $esPrimera = $true
        foreach ($ln in ($txt -split "`n")) {
            $brush = $brushNormal; $font = $fontTip
            if ($esPrimera -and $ln -and $ln -notmatch '^\s*$') { $brush = $brushCal; $font = $fontBold; $esPrimera = $false }
            elseif ($ln -match '^[─\-]+$') { $brush = $brushGris }
            elseif ($ln -match '\[ACTIVO\]') { $brush = $brushVerde; $font = $fontBold }
            elseif ($ln -match '^\(\d+\)' -and $ln -notmatch '\[ACTIVO\]') { $brush = $brushGrisClaro }
            elseif ($ln -match '(?i)^(equipar|equip|uso|use|chance on|probabilidad al|al golpear|on equip|on use)\b') { $brush = $brushVerde }
            elseif ($ln -match '^[\+\-]\d' -or $ln -match '(?i)valoraci[oó]n|poder de|esp[ií]ritu|aguante|agilidad|fuerza|intelecto|armadura|cr[ií]tico|golpe|resistencia|da[nñ]o|celeridad|haste|índice de|indice de|pericia|expertise|penetraci[oó]n|defense|defensa|block|bloqueo|dodge|esquiva|parry|parada|resilience|resiliencia|mp5|mana cada|regenera') { $brush = $brushVerde }
            elseif ($ln -match '^(Encantamiento|Gema|Socket|Bonus socket|Set):') { $brush = $brushAzul }
            elseif ($ln -match '^(Pobre|Comun|Poco comun|Raro|Epico|Legendario|Artefacto|Herencia)$') { $brush = $brushCal }
            elseif ($ln -match '^\[.+\]$' -or $ln -match 'vacío|piezas|Se liga|Necesitas|Nivel de objeto|Unique|Único') { $brush = $brushGris }
            $g.DrawString($ln, $font, $brush, $x, $y)
            $y += [math]::Ceiling($g.MeasureString($ln, $font).Height) + 1
        }
        $fontTip.Dispose(); $fontBold.Dispose()
        $brushNormal.Dispose(); $brushVerde.Dispose(); $brushCal.Dispose()
        $brushGris.Dispose(); $brushAzul.Dispose(); $brushGrisClaro.Dispose()
    })
    $lblNombre = New-Object System.Windows.Forms.Label
    $lblNombre.Text = "Nombre del personaje:"
    $lblNombre.Location = New-Object System.Drawing.Point(530, 12)
    $lblNombre.Size = New-Object System.Drawing.Size(220, 18)
    $lblNombre.Font = $fNormal
    $armForm.Controls.Add($lblNombre)

    $txtNombre = New-Object System.Windows.Forms.TextBox
    $txtNombre.Location = New-Object System.Drawing.Point(530, 32)
    $txtNombre.Size = New-Object System.Drawing.Size(180, 22)
    $txtNombre.Font = $fNormal
    $txtNombre.BackColor = [System.Drawing.Color]::FromArgb(30, 25, 20)
    $txtNombre.ForeColor = [System.Drawing.Color]::White
    $armForm.Controls.Add($txtNombre)

    $btnBuscar = New-Object System.Windows.Forms.Button
    $btnBuscar.Text = "Buscar"
    $btnBuscar.Location = New-Object System.Drawing.Point(720, 30)
    $btnBuscar.Size = New-Object System.Drawing.Size(90, 26)
    $btnBuscar.BackColor = [System.Drawing.Color]::FromArgb(120, 20, 20)
    $btnBuscar.ForeColor = [System.Drawing.Color]::White
    $btnBuscar.FlatStyle = 'Flat'
    $btnBuscar.FlatAppearance.BorderSize = 1
    $btnBuscar.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $btnBuscar.Font = $fBold
    $armForm.Controls.Add($btnBuscar)

    $btnBorrarCache = New-Object System.Windows.Forms.Button
    $btnBorrarCache.Text = "Borrar Caché Jugador"
    $btnBorrarCache.Location = New-Object System.Drawing.Point(530, 62)
    $btnBorrarCache.Size = New-Object System.Drawing.Size(280, 26)
    $btnBorrarCache.BackColor = [System.Drawing.Color]::FromArgb(60, 20, 20)
    $btnBorrarCache.ForeColor = [System.Drawing.Color]::White
    $btnBorrarCache.FlatStyle = 'Flat'
    $btnBorrarCache.FlatAppearance.BorderSize = 1
    $btnBorrarCache.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(180, 80, 80)
    $btnBorrarCache.Font = $fPeq
    $tooltip.SetToolTip($btnBorrarCache, "Elimina únicamente el archivo .json de caché del personaje introducido")
    $armForm.Controls.Add($btnBorrarCache)

    $lblAvisoCache = New-Object System.Windows.Forms.Label
    $lblAvisoCache.Text = "Si no ves las estadisticas de los item equipados, borra cache del jugador para actualizarlos"
    $lblAvisoCache.Location = New-Object System.Drawing.Point(530, 91)
    $lblAvisoCache.Size = New-Object System.Drawing.Size(280, 34)
    $lblAvisoCache.Font = New-Object System.Drawing.Font("Georgia", 6.5, [System.Drawing.FontStyle]::Italic)
    $lblAvisoCache.ForeColor = [System.Drawing.Color]::FromArgb(210, 180, 100)
    $armForm.Controls.Add($lblAvisoCache)

    $btnBorrarCache.Add_Click({
        $nombre = $txtNombre.Text.Trim()
        if (-not $nombre) { 
            [System.Windows.Forms.MessageBox]::Show("Por favor, introduce el nombre de un personaje en la caja de texto.", "Atención", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return 
        }

        $ne = $nombre -replace "'", "''"
        try {
            $rGuid = (Consulta-Armeria "SELECT guid FROM characters WHERE name='$ne';" "acore_characters")[0]
            if ($rGuid) {
                $guid = $rGuid.Trim()
                $rutaCache = Obtener-RutaCachePersonaje $guid

                if (Test-Path $rutaCache) {
                    $dialogResult = [System.Windows.Forms.MessageBox]::Show(
                        "¿Estás seguro de que deseas eliminar la caché del personaje '$nombre' (ID: $guid)?", 
                        "Confirmar borrado de caché individual", 
                        [System.Windows.Forms.MessageBoxButtons]::YesNo, 
                        [System.Windows.Forms.MessageBoxIcon]::Warning
                    )
                    if ($dialogResult -eq [System.Windows.Forms.DialogResult]::Yes) {
                        Limpiar-CachePersonaje $guid
                        [System.Windows.Forms.MessageBox]::Show("Se ha borrado la caché de '$nombre' correctamente.", "Caché limpiada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                        $btnBuscar.PerformClick()
                    }
                } else {
                    [System.Windows.Forms.MessageBox]::Show("No existe un archivo de caché para el personaje '$nombre' (ID: $guid).", "Información", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show("Personaje '$nombre' no encontrado en la base de datos.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error al borrar la caché: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    $ICON_UI  = 18; $ICON_BIG = 42
    $pbRaza = New-Object System.Windows.Forms.PictureBox
    $pbRaza.Location = New-Object System.Drawing.Point(15, 8)
    $pbRaza.Size = New-Object System.Drawing.Size($ICON_BIG, $ICON_BIG)
    $pbRaza.SizeMode = 'StretchImage'
    $pbRaza.BackColor = [System.Drawing.Color]::Transparent
    $armForm.Controls.Add($pbRaza)
    $pbClase = New-Object System.Windows.Forms.PictureBox
    $pbClase.Location = New-Object System.Drawing.Point(62, 8)
    $pbClase.Size = New-Object System.Drawing.Size($ICON_BIG, $ICON_BIG)
    $pbClase.SizeMode = 'StretchImage'
    $pbClase.BackColor = [System.Drawing.Color]::Transparent
    $armForm.Controls.Add($pbClase)
    # Icono de especializacion (rama de talentos activa) junto a la clase
    $pbSpec = New-Object System.Windows.Forms.PictureBox
    $pbSpec.Location = New-Object System.Drawing.Point(109, 8)
    $pbSpec.Size = New-Object System.Drawing.Size($ICON_BIG, $ICON_BIG)
    $pbSpec.SizeMode = 'StretchImage'
    $pbSpec.BackColor = [System.Drawing.Color]::Transparent
    $armForm.Controls.Add($pbSpec)
    $lblNombreChar = New-Object System.Windows.Forms.Label
    $lblNombreChar.Text = "..."
    $lblNombreChar.Location = New-Object System.Drawing.Point(158, 6)
    $lblNombreChar.Size = New-Object System.Drawing.Size(327, 36)
    $lblNombreChar.Font = New-Object System.Drawing.Font("Georgia", 20, [System.Drawing.FontStyle]::Bold)
    $lblNombreChar.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $lblNombreChar.TextAlign = 'MiddleCenter'
    $armForm.Controls.Add($lblNombreChar)
    $lblFicha = New-Object System.Windows.Forms.Label
    $lblFicha.Text = ""
    $lblFicha.Location = New-Object System.Drawing.Point(158, 42)
    $lblFicha.Size = New-Object System.Drawing.Size(327, 18)
    $lblFicha.Font = New-Object System.Drawing.Font("Georgia", 9.5)
    $lblFicha.ForeColor = [System.Drawing.Color]::FromArgb(200, 190, 170)
    $lblFicha.TextAlign = 'MiddleCenter'
    $armForm.Controls.Add($lblFicha)

    $lblGuild = New-Object System.Windows.Forms.Label
    $lblGuild.Text = ""
    $lblGuild.Location = New-Object System.Drawing.Point(158, 60)
    $lblGuild.Size = New-Object System.Drawing.Size(327, 16)
    $lblGuild.Font = New-Object System.Drawing.Font("Georgia", 8.5, [System.Drawing.FontStyle]::Italic)
    $lblGuild.ForeColor = [System.Drawing.Color]::FromArgb(100, 220, 100)
    $lblGuild.TextAlign = 'MiddleCenter'
    $armForm.Controls.Add($lblGuild)

    $sepFicha = New-Object System.Windows.Forms.Panel
    $sepFicha.Location  = New-Object System.Drawing.Point(15, 82)
    $sepFicha.Size      = New-Object System.Drawing.Size(470, 1)
    $sepFicha.BackColor = [System.Drawing.Color]::FromArgb(60, 50, 40)
    $armForm.Controls.Add($sepFicha)

    # Botones de acceso rapido como ICONOS (fila unica, centrados bajo la ficha)
    # Personalizables: Imagenes\armeria\pvp.png, talentos.png, reputaciones.png,
    #                  logros.png, transmog.png, establos.png
    $szBtn = 48
    $btnGap = 12
    $numBtn = 6
    $anchoFila = ($numBtn * $szBtn) + (($numBtn - 1) * $btnGap)
    # Zona izquierda de la ficha: ~15..485 (ancho paperdoll 470)
    $zonaIzq = 15
    $zonaAncho = 470
    $btnX0 = $zonaIzq + [int](($zonaAncho - $anchoFila) / 2)
    if ($btnX0 -lt 15) { $btnX0 = 15 }
    $btnY1 = 86
    $btnX = $btnX0

    $tipEst = "Monturas y mascotas de compania aprendidas"
    try { $tipEst = (Obtener-Texto "TipEstablos" $tipEst) } catch {}

    $btnPvP = Armeria-CrearBotonIcono $btnX $btnY1 "pvp" "PvP - Honor, arenas y muertes" ([System.Drawing.Color]::FromArgb(80, 25, 25)) $tooltip $szBtn
    $armForm.Controls.Add($btnPvP)
    $btnX += $szBtn + $btnGap

    $btnTalentos = Armeria-CrearBotonIcono $btnX $btnY1 "talentos" "Talentos - Arbol de talentos (dual spec)" ([System.Drawing.Color]::FromArgb(45, 25, 70)) $tooltip $szBtn
    $armForm.Controls.Add($btnTalentos)
    $btnX += $szBtn + $btnGap

    $btnReputaciones = Armeria-CrearBotonIcono $btnX $btnY1 "reputaciones" "Reputaciones - Facciones y progreso" ([System.Drawing.Color]::FromArgb(60, 45, 10)) $tooltip $szBtn
    $armForm.Controls.Add($btnReputaciones)
    $btnX += $szBtn + $btnGap

    $btnLogros = Armeria-CrearBotonIcono $btnX $btnY1 "logros" "Logros - Ultimos logros completados" ([System.Drawing.Color]::FromArgb(10, 45, 60)) $tooltip $szBtn
    $armForm.Controls.Add($btnLogros)
    $btnX += $szBtn + $btnGap

    $btnTransmog = Armeria-CrearBotonIcono $btnX $btnY1 "transmog" "Transmog - Apariencias aprendidas" ([System.Drawing.Color]::FromArgb(70, 30, 90)) $tooltip $szBtn
    $armForm.Controls.Add($btnTransmog)
    $btnX += $szBtn + $btnGap

    $btnEstablos = Armeria-CrearBotonIcono $btnX $btnY1 "establos" $tipEst ([System.Drawing.Color]::FromArgb(30, 70, 50)) $tooltip $szBtn
    $armForm.Controls.Add($btnEstablos)

    # Variables de contexto del personaje actual (actualizadas al buscar)
    $script:ArmeriaGuidActual = $null
    $script:ArmeriaNombreActual = $null
    $script:ArmeriaClaseActual = 0

    $btnPvP.Add_Click({
        if ($script:ArmeriaGuidActual) {
            Mostrar-VentanaPvP $script:ArmeriaGuidActual $script:ArmeriaNombreActual $armForm
        }
    })
    $btnTalentos.Add_Click({
        if ($script:ArmeriaGuidActual) {
            Mostrar-VentanaTalentos $script:ArmeriaGuidActual $script:ArmeriaNombreActual $script:ArmeriaClaseActual $armForm
        }
    })
    $btnReputaciones.Add_Click({
        if ($script:ArmeriaGuidActual) {
            Mostrar-VentanaReputaciones $script:ArmeriaGuidActual $script:ArmeriaNombreActual $armForm
        }
    })
    $btnLogros.Add_Click({
        if ($script:ArmeriaGuidActual) {
            Mostrar-VentanaLogros $script:ArmeriaGuidActual $script:ArmeriaNombreActual $armForm
        }
    })
    $btnTransmog.Add_Click({
        if (-not $script:ArmeriaGuidActual) { return }
        try {
            if (Get-Command Mostrar-VentanaTransmog -ErrorAction SilentlyContinue) {
                Mostrar-VentanaTransmog $script:ArmeriaGuidActual $script:ArmeriaNombreActual $armForm
            } else {
                $rutaTm = Join-Path $Global:RootDir "Transmog.ps1"
                if (Test-Path $rutaTm) {
                    Invoke-Expression (Get-Content $rutaTm -Raw -Encoding UTF8)
                    if (Get-Command Mostrar-VentanaTransmog -ErrorAction SilentlyContinue) {
                        Mostrar-VentanaTransmog $script:ArmeriaGuidActual $script:ArmeriaNombreActual $armForm
                        return
                    }
                }
                [System.Windows.Forms.MessageBox]::Show(
                    ((Obtener-Texto "MsgModuloTransmogNoCargado" "No se cargo Transmog.ps1.`nColocalo en Scripts (junto a armeria.ps1) y reinicia el panel.`n`nRuta:`n{0}") -f $rutaTm),
                    "Transmog", 'OK', 'Warning')
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error al abrir Transmog:`n$($_.Exception.Message)", "Transmog", 'OK', 'Error')
        }
    })
    $btnEstablos.Add_Click({
        if (-not $script:ArmeriaGuidActual) { return }
        try {
            if (Get-Command Mostrar-VentanaEstablos -ErrorAction SilentlyContinue) {
                Mostrar-VentanaEstablos $script:ArmeriaGuidActual $script:ArmeriaNombreActual $armForm
            } else {
                $rutaEs = Join-Path $Global:RootDir "Establos.ps1"
                if (Test-Path $rutaEs) {
                    Invoke-Expression (Get-Content $rutaEs -Raw -Encoding UTF8)
                    if (Get-Command Mostrar-VentanaEstablos -ErrorAction SilentlyContinue) {
                        Mostrar-VentanaEstablos $script:ArmeriaGuidActual $script:ArmeriaNombreActual $armForm
                        return
                    }
                }
                [System.Windows.Forms.MessageBox]::Show(
                    ((Obtener-Texto "MsgModuloEstablosNoCargado" "No se cargo Establos.ps1.`nColocalo en Scripts y reinicia el panel.`n`nRuta:`n{0}") -f $rutaEs),
                    (Obtener-Texto "BtnEstablos" "Establos"), 'OK', 'Warning')
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error al abrir Establos:`n$($_.Exception.Message)", (Obtener-Texto "BtnEstablos" "Establos"), 'OK', 'Error')
        }
    })

    $sep = New-Object System.Windows.Forms.Panel
    $sep.Location = New-Object System.Drawing.Point(15, 140)
    $sep.Size = New-Object System.Drawing.Size(740, 1)
    $sep.BackColor = [System.Drawing.Color]::FromArgb(60, 50, 40)
    $armForm.Controls.Add($sep)

    $sepVert = New-Object System.Windows.Forms.Panel
    $sepVert.BackColor = [System.Drawing.Color]::FromArgb(60, 50, 40)
    $armForm.Controls.Add($sepVert)

    $lblCargando = New-Object System.Windows.Forms.Label
    $lblCargando.Text      = ""
    $lblCargando.Font      = $fNormal
    $lblCargando.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $armForm.Controls.Add($lblCargando)

    $panelDoll = New-Object System.Windows.Forms.Panel
    $panelDoll.BackColor = [System.Drawing.Color]::FromArgb(20, 15, 12)
    $panelDoll.BackgroundImageLayout = 'Zoom'
    $armForm.Controls.Add($panelDoll)

    $pbSilueta = New-Object System.Windows.Forms.PictureBox
    $pbSilueta.Location = New-Object System.Drawing.Point(64, 10)
    $pbSilueta.Size     = New-Object System.Drawing.Size(342, 460)
    $pbSilueta.SizeMode = 'Zoom'
    $pbSilueta.BackColor = [System.Drawing.Color]::Transparent
    $panelDoll.Controls.Add($pbSilueta)

    $lblProfTitulo = New-Object System.Windows.Forms.Label
    $lblProfTitulo.Text      = "Profesiones"
    $lblProfTitulo.Size      = New-Object System.Drawing.Size(245, 20)
    $lblProfTitulo.Font      = $fBold
    $lblProfTitulo.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
    $armForm.Controls.Add($lblProfTitulo)

    $panelProf = New-Object System.Windows.Forms.Panel
    $panelProf.BackColor  = [System.Drawing.Color]::FromArgb(20, 18, 15)
    $panelProf.AutoScroll = $true
    $armForm.Controls.Add($panelProf)

    $alturaPaneles = [math]::Max(360, $armForm.ClientSize.Height - 185)
    $alturaSep = $alturaPaneles + 22
    $sepVert.Location = New-Object System.Drawing.Point(500, 150)
    $sepVert.Size = New-Object System.Drawing.Size(1, $alturaSep)
    $sepVert2.Location = New-Object System.Drawing.Point(520, 150)
    $sepVert2.Size = New-Object System.Drawing.Size(1, $alturaSep)
    $sepVert3.Location = New-Object System.Drawing.Point(790, 150)
    $sepVert3.Size = New-Object System.Drawing.Size(1, $alturaSep)
    $lblCargando.Location = New-Object System.Drawing.Point(15, 155)
    $lblCargando.Size = New-Object System.Drawing.Size(470, 20)
    $panelDoll.Location = New-Object System.Drawing.Point(15, 175)
    $panelDoll.Size = New-Object System.Drawing.Size(470, $alturaPaneles)
    $panelStats.Location = New-Object System.Drawing.Point(530, 175)
    $panelStats.Size = New-Object System.Drawing.Size(230, $alturaPaneles)
    $lblStatsTitulo.Location = New-Object System.Drawing.Point(530, 150)
    $lblProfTitulo.Location = New-Object System.Drawing.Point(800, 150)
    $panelProf.Location = New-Object System.Drawing.Point(800, 175)
    $panelProf.Size = New-Object System.Drawing.Size(245, $alturaPaneles)
    $panelDoll.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
    $panelStats.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
    $panelProf.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
    $sepVert.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
    $sepVert2.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
    $sepVert3.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

    $slotControls = @{}
    for ($s = 0; $s -le 18; $s++) {
        $pos = $Global:ArmeriaPosSlot[$s]
        $pb  = Crear-SlotVacio $pos[0] $pos[1] $SLOT_SIZE $Global:ArmeriaSlotNombre[$s] $tooltip
        $panelDoll.Controls.Add($pb)
        $pb.BringToFront()
        $slotControls[$s] = $pb
    }

    $btnBuscar.Add_Click({
        $nombre = $txtNombre.Text.Trim()
        if (-not $nombre) { return }

        $lblFicha.Text    = "Buscando..."
        $lblCargando.Text = ""
        $pbSilueta.Image  = $null
        $pbSpec.Image     = $null
        $panelDoll.BackgroundImage = $null
        $btnPvP.Enabled = $false
        $btnTalentos.Enabled = $false
        $btnReputaciones.Enabled = $false
        $btnLogros.Enabled = $false
        $btnTransmog.Enabled = $false
        $btnEstablos.Enabled = $false
        $script:ArmeriaGuidActual = $null

        for ($s = 0; $s -le 18; $s++) {
            $slotControls[$s].BackColor = [System.Drawing.Color]::FromArgb(45, 40, 35)
            $pbInnerReset = $slotControls[$s].Tag
            if ($pbInnerReset -is [System.Windows.Forms.PictureBox]) {
                $pbInnerReset.Image     = $null
                $pbInnerReset.BackColor = [System.Drawing.Color]::FromArgb(20, 15, 12)
            }
            $tooltip.SetToolTip($slotControls[$s], $Global:ArmeriaSlotNombre[$s])
        }
        $armForm.Refresh()

        $ne = $nombre -replace "'", "''"

        try {
            $rGuid = (Consulta-Armeria "SELECT guid FROM characters WHERE name='$ne';" "acore_characters")[0]
            if (-not $rGuid) {
                $lblFicha.Text = "Personaje no encontrado."
                return
            }
            $guid = $rGuid.Trim()

            $rLevel  = (Consulta-Armeria "SELECT level FROM characters WHERE guid=$guid;" "acore_characters")[0]
            $rRace   = (Consulta-Armeria "SELECT race FROM characters WHERE guid=$guid;" "acore_characters")[0]
            $rClass  = (Consulta-Armeria "SELECT class FROM characters WHERE guid=$guid;" "acore_characters")[0]
            $rGender = (Consulta-Armeria "SELECT gender FROM characters WHERE guid=$guid;" "acore_characters")[0]

            $rGuild = (Consulta-Armeria "SELECT g.name FROM guild g JOIN guild_member gm ON gm.guildid=g.guildid WHERE gm.guid=$guid;" "acore_characters")[0]

            $razaId  = [int]$rRace.Trim()
            $claseId = [int]$rClass.Trim()
            $generoId = [int]$rGender.Trim()
            $hermandad = if ($rGuild) { $rGuild.Trim() } else { "-" }
            $raza  = if ($Global:ArmeriaRazas.ContainsKey($razaId))  { $Global:ArmeriaRazas[$razaId] }  else { "?" }
            $clase = if ($Global:ArmeriaClases.ContainsKey($claseId)) { $Global:ArmeriaClases[$claseId] } else { "?" }

            $bgPath = Join-Path $Global:RootDir "Armeria\Imagenes\fondos\bg_raza_$razaId.jpg"
            if (Test-Path $bgPath) {
                $panelDoll.BackgroundImage = [System.Drawing.Image]::FromFile($bgPath)
            }

            $siluetaPath = Join-Path $Global:RootDir "Armeria\Imagenes\siluetas\silueta_$razaId`_$generoId.png"
            if (Test-Path $siluetaPath) {
                $pbSilueta.Image = [System.Drawing.Image]::FromFile($siluetaPath)
            }

            $razaIconos = @{1="race_human_male";2="race_orc_male";3="race_dwarf_male";4="race_nightelf_male";5="race_scourge_male";6="race_tauren_male";7="race_gnome_male";8="race_troll_male";10="race_bloodelf_male";11="race_draenei_male"}
            $claseIconos = @{1="classicon_warrior";2="classicon_paladin";3="classicon_hunter";4="classicon_rogue";5="classicon_priest";6="classicon_deathknight";7="classicon_shaman";8="classicon_mage";9="classicon_warlock";11="classicon_druid"}
            
            $razaIconNombre = if ($razaIconos.ContainsKey($razaId)) { $razaIconos[$razaId] } else { "" }
            if ($generoId -eq 1) { $razaIconNombre = $razaIconNombre -replace "_male", "_female" }

            $claseIconNombre = if ($claseIconos.ContainsKey($claseId)) { $claseIconos[$claseId] } else { "" }
            if ($razaIconNombre)  { $imgRaza  = Descargar-IconoUI $razaIconNombre  $ICON_BIG; if ($imgRaza)  { $pbRaza.Image  = $imgRaza } }
            if ($claseIconNombre) { $imgClase = Descargar-IconoUI $claseIconNombre $ICON_BIG; if ($imgClase) { $pbClase.Image = $imgClase } }

            $lblNombreChar.Text = $nombre
            $pbSpec.Image = $null
            try { $tooltip.SetToolTip($pbSpec, "") } catch {}
            $especNombre = $null
            $tabSpec = 0
            $especFuente = ""
            $especDist = ""
            try {
                $especInfo = Obtener-EspecializacionPersonaje $guid $claseId
                if ($especInfo) {
                    $es = [string]$especInfo
                    $parts = $es -split "\|"
                    if ($parts.Count -ge 1) { $especNombre = $parts[0].Trim() }
                    if ($parts.Count -ge 2) { try { $tabSpec = [int]$parts[1].Trim() } catch { $tabSpec = 0 } }
                    if ($parts.Count -ge 3) { $especFuente = $parts[2].Trim() }
                    if ($parts.Count -ge 4) { $especDist = $parts[3].Trim() }
                }
            } catch {}
            if ($tabSpec -gt 0) {
                try {
                    $iconName = $null
                    if ($Global:ArmeriaTalentTabIconos) {
                        if ($Global:ArmeriaTalentTabIconos.ContainsKey($tabSpec)) {
                            $iconName = $Global:ArmeriaTalentTabIconos[$tabSpec]
                        } elseif ($Global:ArmeriaTalentTabIconos.ContainsKey("$tabSpec")) {
                            $iconName = $Global:ArmeriaTalentTabIconos["$tabSpec"]
                        }
                    }
                    if ($iconName) {
                        $imgSpec = Descargar-IconoPorNombre $iconName $ICON_BIG ("spec$tabSpec")
                        if ($imgSpec) {
                            $pbSpec.Image = $imgSpec
                        }
                    }
                } catch {}
            }
            # Tooltip de depuracion en el icono de spec
            try {
                $tipSpec = if ($especNombre) { $especNombre } else { "(sin especializacion)" }
                $tipSpec += "`nTabId: $tabSpec"
                if ($especDist) { $tipSpec += "`nPuntos: $especDist" }
                if ($especFuente) { $tipSpec += "`nFuente: $especFuente" }
                try {
                    if ($Global:RootDir) {
                        $tipSpec += "`nCache: " + (Join-Path $Global:RootDir ("Armeria\Cache\spec_{0}.txt" -f $guid))
                    }
                } catch {}
                $tooltip.SetToolTip($pbSpec, $tipSpec)
            } catch {}
            if ($especNombre) { $lblFicha.Text = "Nivel $($rLevel.Trim())  ·  $raza  ·  $clase  ·  $especNombre" }
            else { $lblFicha.Text = "Nivel $($rLevel.Trim())  ·  $raza  ·  $clase" }
                        $lblGuild.Text      = if ($hermandad -ne "-") { "< $hermandad >" } else { "" }

            $itemsRaw = Consulta-Armeria "SELECT ci.slot, ii.guid, ii.itemEntry, it.name, it.Quality FROM character_inventory ci JOIN item_instance ii ON ii.guid=ci.item JOIN acore_world.item_template it ON it.entry=ii.itemEntry WHERE ci.guid=$guid AND ci.bag=0 AND ci.slot BETWEEN 0 AND 18 ORDER BY ci.slot;" "acore_characters"

            $cachePersonaje = Cargar-CachePersonaje $guid
            $equipoActual   = @{} 

            $lblCargando.Text = "Cargando iconos y stats..."
            $armForm.Refresh()

            $cargados   = 0
            $desdecache = 0
            foreach ($linea in $itemsRaw) {
                $p = $linea -split "`t"
                if ($p.Count -lt 5) { continue }
                $slot      = [int]$p[0].Trim()
                $guidItem  = $p[1].Trim()
                $entry     = $p[2].Trim()
                $nombre_it = $p[3].Trim()
                $calidad   = [int]$p[4].Trim()

                if ($slot -lt 0 -or $slot -gt 18) { continue }

                $equipoActual[$slot] = $entry
                $colorBorde = if ($Global:ArmeriaColorCalidad.ContainsKey($calidad)) { $Global:ArmeriaColorCalidad[$calidad] } else { [System.Drawing.Color]::White }
                $nombreCal  = if ($Global:ArmeriaNombreCalidad.ContainsKey($calidad)) { $Global:ArmeriaNombreCalidad[$calidad] } else { "" }

                $entryCache = if ($cachePersonaje -and $cachePersonaje.equipo -and $cachePersonaje.equipo."s$slot") { $cachePersonaje.equipo."s$slot" } else { "" }
                $cambio = ($entry -ne $entryCache)

                $img = Descargar-IconoArmeria $entry $SLOT_SIZE
                $pbInner = $slotControls[$slot].Tag
                $slotControls[$slot].BackColor = $colorBorde
                
                if ($img) {
                    $pbInner.Image     = $img
                    $pbInner.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 45)
                    $cargados++
                } else {
                    $pbInner.Image     = $null
                    $pbInner.BackColor = [System.Drawing.Color]::FromArgb(20, 15, 12)
                }

                if (-not $cambio -and $cachePersonaje -and $cachePersonaje.tooltips -and $cachePersonaje.tooltips."s$slot") {
                    $textoTooltip = $cachePersonaje.tooltips."s$slot"
                    $desdecache++
                } else {
                    $statsTooltip = Obtener-TooltipItem $entry $guidItem $guid
                    $textoTooltip = "$nombre_it`n$nombreCal"
                    if ($statsTooltip) { $textoTooltip += "`n─────────────`n$statsTooltip" }
                }

                $tooltip.SetToolTip($slotControls[$slot], $textoTooltip)
                $tooltip.SetToolTip($pbInner, $textoTooltip)
                $slotControls[$slot].Tag = $pbInner
                $pbInner.Tag = $textoTooltip
            }

            $equipoJson  = @{}
            $tooltipsJson = @{}
            foreach ($s in $equipoActual.Keys) {
                $equipoJson["s$s"]   = $equipoActual[$s]
                $tooltipsJson["s$s"] = ($slotControls[$s].Tag).Tag
            }
            Guardar-CachePersonaje $guid @{ equipo = $equipoJson; tooltips = $tooltipsJson }

            $lblCargando.Text = ""

            $panelStats.Controls.Clear()
            $yS = 6

            Function Stat-Seccion($titulo, $color) {
                $lbl = New-Object System.Windows.Forms.Label
                $lbl.Text      = "── $titulo ──"
                $lbl.Location  = New-Object System.Drawing.Point(5, $yS)
                $lbl.Size      = New-Object System.Drawing.Size(220, 16)
                $lbl.Font      = New-Object System.Drawing.Font("Georgia", 7.5, [System.Drawing.FontStyle]::Bold)
                $lbl.ForeColor = $color
                $lbl.TextAlign = 'MiddleCenter'
                $panelStats.Controls.Add($lbl)
                $script:yS += 20
            }

            Function Stat-Fila($nombre, $valor, $colorVal) {
                $lblN = New-Object System.Windows.Forms.Label
                $lblN.Text      = $nombre
                $lblN.Location  = New-Object System.Drawing.Point(5, $script:yS)
                $lblN.Size      = New-Object System.Drawing.Size(140, 15)
                $lblN.Font      = $fPeq
                $lblN.ForeColor = [System.Drawing.Color]::FromArgb(210, 200, 180)
                $panelStats.Controls.Add($lblN)
                $lblV = New-Object System.Windows.Forms.Label
                $lblV.Text      = [string]$valor
                $lblV.Location  = New-Object System.Drawing.Point(145, $script:yS)
                $lblV.Size      = New-Object System.Drawing.Size(80, 15)
                $lblV.Font      = New-Object System.Drawing.Font("Georgia", 8, [System.Drawing.FontStyle]::Bold)
                $lblV.ForeColor = $colorVal
                $lblV.TextAlign = 'MiddleRight'
                $panelStats.Controls.Add($lblV)
                $script:yS += 17
            }

            $script:yS = $yS

            $cVerde  = [System.Drawing.Color]::FromArgb(100, 220, 100)
            $cAzul   = [System.Drawing.Color]::FromArgb(100, 180, 255)
            $cRojo   = [System.Drawing.Color]::FromArgb(255, 100, 100)
            $cAmar   = [System.Drawing.Color]::FromArgb(255, 220, 80)
            $cBlanco = [System.Drawing.Color]::White
            $cNar    = [System.Drawing.Color]::FromArgb(255, 180, 80)

            $statsOnlineRaw = (Consulta-Armeria "SELECT CONCAT(maxhealth,'|',maxpower1,'|',strength,'|',agility,'|',stamina,'|',intellect,'|',spirit,'|',armor,'|',attackPower,'|',rangedAttackPower,'|',spellPower,'|',critPct,'|',rangedCritPct,'|',spellCritPct,'|',dodgePct,'|',parryPct,'|',blockPct,'|',resilience,'|',resArcane,'|',resFire,'|',resNature,'|',resFrost,'|',resShadow,'|',resHoly) FROM character_stats WHERE guid=$guid;" "acore_characters")[0]

            $svOnline = $null
            $fuenteStats = ""

            if ($statsOnlineRaw -and $statsOnlineRaw.Trim() -ne "") {
                $svOnline = $statsOnlineRaw.Trim() -split "\|"
                $fuenteStats = "online"
                $cacheActual2 = Cargar-CachePersonaje $guid
                if (-not $cacheActual2) { $cacheActual2 = [PSCustomObject]@{ equipo=@{}; tooltips=@{} } }
                $cacheActual2 | Add-Member -NotePropertyName "characterStats" -NotePropertyValue $statsOnlineRaw.Trim() -Force
                Guardar-CachePersonaje $guid $cacheActual2
            } else {
                $cacheActual2 = Cargar-CachePersonaje $guid
                if ($cacheActual2 -and $cacheActual2.characterStats) {
                    $svOnline = $cacheActual2.characterStats -split "\|"
                    $fuenteStats = "cache"
                }
            }

            if ($svOnline -and $svOnline.Count -ge 18) {
                $fuenteLabel = if ($fuenteStats -eq "cache") { " (cache)" } else { "" }
                Stat-Seccion "Personaje$fuenteLabel" ([System.Drawing.Color]::FromArgb(255, 210, 0))
                Stat-Fila "Vida máxima"   $svOnline[0]                                        $cVerde
                Stat-Fila "Maná/Poder"    $svOnline[1]                                        $cAzul
                Stat-Fila "Fuerza"        $svOnline[2]                                        $cBlanco
                Stat-Fila "Agilidad"      $svOnline[3]                                        $cBlanco
                Stat-Fila "Aguante"       $svOnline[4]                                        $cBlanco
                Stat-Fila "Intelecto"     $svOnline[5]                                        $cBlanco
                Stat-Fila "Espíritu"      $svOnline[6]                                        $cBlanco
                $script:yS += 4
                Stat-Seccion "Combate" ([System.Drawing.Color]::FromArgb(200, 100, 100))
                Stat-Fila "Armadura"          $svOnline[7]                                    $cBlanco
                Stat-Fila "Poder de ataque"   $svOnline[8]                                    $cRojo
                Stat-Fila "PA distancia"      $svOnline[9]                                    $cAmar
                Stat-Fila "Poder hechizos"    $svOnline[10]                                   $cAzul
                Stat-Fila "Crítico C/C"       ("{0:F2}%" -f [double]$svOnline[11])             $cAmar
                Stat-Fila "Crítico distancia" ("{0:F2}%" -f [double]$svOnline[12])             $cAmar
                Stat-Fila "Crítico hechizo"   ("{0:F2}%" -f [double]$svOnline[13])             $cAzul
                $script:yS += 4
                Stat-Seccion "Defensa" ([System.Drawing.Color]::FromArgb(100, 160, 220))
                Stat-Fila "Esquiva"       ("{0:F2}%" -f [double]$svOnline[14])                 $cVerde
                Stat-Fila "Parada"        ("{0:F2}%" -f [double]$svOnline[15])                 $cVerde
                Stat-Fila "Bloqueo"       ("{0:F2}%" -f [double]$svOnline[16])                 $cVerde
                Stat-Fila "Resiliencia"   $svOnline[17]                                       $cNar

                # --- INICIO NUEVAS RESISTENCIAS ---
                if ($svOnline.Count -ge 24) {
                    $script:yS += 4
                    Stat-Seccion "Resistencias" ([System.Drawing.Color]::FromArgb(200, 150, 255))
                    Stat-Fila "Arcano"     $svOnline[18] ([System.Drawing.Color]::FromArgb(200, 150, 255))
                    Stat-Fila "Fuego"      $svOnline[19] $cRojo
                    Stat-Fila "Naturaleza" $svOnline[20] $cVerde
                    Stat-Fila "Escarcha"   $svOnline[21] $cAzul
                    Stat-Fila "Sombras"    $svOnline[22] ([System.Drawing.Color]::FromArgb(180, 100, 200))
                    Stat-Fila "Sagrado"    $svOnline[23] $cAmar
                }
                # --- FIN NUEVAS RESISTENCIAS ---

            } else {
                $lblSinStats = New-Object System.Windows.Forms.Label
                $lblSinStats.Text      = "Sin datos de estadisticas.`r`n`r`nPara activarlas edita worldserver.conf y cambia:`r`nPlayerSave.Stats.MinLevel = 0`r`na:`r`nPlayerSave.Stats.MinLevel = 1`r`n`r`nDespues conéctate con el personaje al menos una vez."
                $lblSinStats.Location  = New-Object System.Drawing.Point(5, $script:yS)
                $lblSinStats.Size      = New-Object System.Drawing.Size(220, 130)
                $lblSinStats.Font      = $fPeq
                $lblSinStats.ForeColor = [System.Drawing.Color]::FromArgb(180, 140, 60)
                $panelStats.Controls.Add($lblSinStats)
                $script:yS += 135
            }

            $totalIlvl2 = 0; $countIlvl2 = 0
            foreach ($lineaItem2 in $itemsRaw) {
                $pI2 = $lineaItem2 -split "`t"
                if ($pI2.Count -lt 3) { continue }
                $ilvlVal = (Consulta-ArmeriaWorld "SELECT ItemLevel FROM item_template WHERE entry=$($pI2[2].Trim());")[0]
                if ($ilvlVal -and [int]$ilvlVal -gt 0) { $totalIlvl2 += [int]$ilvlVal; $countIlvl2++ }
            }
            if ($countIlvl2 -gt 0) {
                $script:yS += 4
                Stat-Seccion "Equipo" ([System.Drawing.Color]::FromArgb(255, 210, 0))
                $ilvlMedio2 = [math]::Round($totalIlvl2 / $countIlvl2, 1)
                Stat-Fila "iLvl medio" $ilvlMedio2 $cAmar
            }

            # Activar botones de la cabecera con el personaje cargado
            $script:ArmeriaGuidActual = $guid
            $script:ArmeriaNombreActual = $nombre
            $script:ArmeriaClaseActual = $claseId
            $btnPvP.Enabled = $true
            $btnTalentos.Enabled = $true
            $btnReputaciones.Enabled = $true
            $btnLogros.Enabled = $true
            $btnTransmog.Enabled = $true
            $btnEstablos.Enabled = $true

            $panelProf.Controls.Clear()
            $profsRaw = Consulta-Armeria "SELECT CONCAT(skill,'|',value,'|',max) FROM character_skills WHERE guid=$guid AND skill IN (164,165,171,182,185,186,197,202,333,393,755,773,129,356) ORDER BY skill;" "acore_characters"

            $profIconos = @{
                164="trade_blacksmithing"; 165="inv_misc_leatherscrap_03"; 171="trade_alchemy"
                182="spell_nature_naturetouchgrow"; 185="inv_misc_food_15"; 186="trade_mining"
                197="trade_tailoring"; 202="trade_engineering"; 333="trade_engraving"
                393="inv_misc_pelt_wolf_01"; 755="inv_misc_gem_01"; 773="inv_inscription_tradeskill01"
                129="spell_holy_sealofsacrifice"; 356="trade_fishing"
            }

            $PROF_W   = 240
            $ICON_P   = 20

            $yProf = 8
            foreach ($linea in $profsRaw) {
                $p = $linea -split "\|"
                if ($p.Count -lt 3) { continue }
                $skillId  = [int]$p[0].Trim()
                $valor    = [int]$p[1].Trim()
                $maximo   = [int]$p[2].Trim()
                if ($maximo -eq 0) { continue }

                $nombreProf = if ($profNombres.ContainsKey($skillId)) { $profNombres[$skillId] } else { "Skill $skillId" }
                $colorProf  = if ($profColores.ContainsKey($skillId)) { $profColores[$skillId] } else { [System.Drawing.Color]::Gray }
                $pct        = [math]::Round(($valor / $maximo) * 100)

                $pbProf = New-Object System.Windows.Forms.PictureBox
                $pbProf.Location = New-Object System.Drawing.Point(5, $yProf)
                $pbProf.Size     = New-Object System.Drawing.Size($ICON_P, $ICON_P)
                $pbProf.SizeMode = 'StretchImage'
                $pbProf.BackColor = [System.Drawing.Color]::Transparent
                $panelProf.Controls.Add($pbProf)
                if ($profIconos.ContainsKey($skillId)) {
                    $imgProf = Descargar-IconoUI $profIconos[$skillId] $ICON_P
                    if ($imgProf) { $pbProf.Image = $imgProf }
                }

                $lblProf = New-Object System.Windows.Forms.Label
                $lblProf.Text      = $nombreProf
                $lblProf.Location  = New-Object System.Drawing.Point(28, ($yProf + 2))
                $lblProf.Size      = New-Object System.Drawing.Size(130, 16)
                $lblProf.Font      = $fPeq
                $lblProf.ForeColor = $colorProf
                $panelProf.Controls.Add($lblProf)

                $lblVal = New-Object System.Windows.Forms.Label
                $lblVal.Text      = "$valor/$maximo ($pct%)"
                $lblVal.Location  = New-Object System.Drawing.Point(158, ($yProf + 2))
                $lblVal.Size      = New-Object System.Drawing.Size(87, 16)
                $lblVal.Font      = $fPeq
                $lblVal.ForeColor = [System.Drawing.Color]::FromArgb(210, 200, 180)
                $lblVal.TextAlign = 'MiddleRight'
                $panelProf.Controls.Add($lblVal)

                $yProf += 22

                $barFondo = New-Object System.Windows.Forms.Panel
                $barFondo.Location  = New-Object System.Drawing.Point(5, $yProf)
                $barFondo.Size      = New-Object System.Drawing.Size($PROF_W, 8)
                $barFondo.BackColor = [System.Drawing.Color]::FromArgb(35, 30, 25)
                $panelProf.Controls.Add($barFondo)

                $anchoBar = [math]::Max(2, [int]($PROF_W * $valor / $maximo))
                $barRell = New-Object System.Windows.Forms.Panel
                $barRell.Location  = New-Object System.Drawing.Point(0, 0)
                $barRell.Size      = New-Object System.Drawing.Size($anchoBar, 8)
                $barRell.BackColor = $colorProf
                $barFondo.Controls.Add($barRell)

                $tooltip.SetToolTip($barFondo, "$nombreProf`: $valor / $maximo ($pct%)")
                $tooltip.SetToolTip($barRell,  "$nombreProf`: $valor / $maximo ($pct%)")

                $yProf += 14
            }

            if ($profsRaw.Count -eq 0) {
                $lblSinProf = New-Object System.Windows.Forms.Label
                $lblSinProf.Text      = "Sin profesiones"
                $lblSinProf.Location  = New-Object System.Drawing.Point(5, 8)
                $lblSinProf.Size      = New-Object System.Drawing.Size(235, 20)
                $lblSinProf.Font      = $fPeq
                $lblSinProf.ForeColor = [System.Drawing.Color]::FromArgb(120, 110, 100)
                $panelProf.Controls.Add($lblSinProf)
            }

            $armasNombres = @{
                43="Espadas"; 44="Hachas de 2m"; 45="Mazas"; 54="Defensa"
                55="Armas de fuego"; 136="Bastones"; 137="Hachas"
                150="Armas de asta"; 160="Mazas de 2m"; 172="Espadas de 2m"
                173="Dagas"; 176="Lanzas"; 226="Armas arrojadizas"
                256="Arcos largos"; 257="Ballesta"; 264="Varas"
                473="Sin armas"; 474="Armas de combate"
                1180="Armas de combate de 2m"
            }

            $yProf += 8
            $lblArmasTit = New-Object System.Windows.Forms.Label
            $lblArmasTit.Text      = "── Habilidades de armas ──"
            $lblArmasTit.Location  = New-Object System.Drawing.Point(5, $yProf)
            $lblArmasTit.Size      = New-Object System.Drawing.Size(235, 16)
            $lblArmasTit.Font      = New-Object System.Drawing.Font("Georgia", 7.5, [System.Drawing.FontStyle]::Bold)
            $lblArmasTit.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
            $lblArmasTit.TextAlign = 'MiddleCenter'
            $panelProf.Controls.Add($lblArmasTit)
            $yProf += 20

            $armasRaw = Consulta-Armeria "SELECT CONCAT(skill,'|',value,'|',max) FROM character_skills WHERE guid=$guid AND skill IN (43,44,45,54,55,136,137,150,160,172,173,176,226,256,257,264,473,474,1180) ORDER BY skill;" "acore_characters"

            foreach ($linea in $armasRaw) {
                $p = $linea -split "\|"
                if ($p.Count -lt 3) { continue }
                $skillId = [int]$p[0].Trim()
                $valor   = [int]$p[1].Trim()
                $maximo  = [int]$p[2].Trim()
                if ($maximo -eq 0) { continue }
                $nombreArma = if ($armasNombres.ContainsKey($skillId)) { $armasNombres[$skillId] } else { "Arma $skillId" }
                $pct        = [math]::Round(($valor / $maximo) * 100)

                $lblA = New-Object System.Windows.Forms.Label
                $lblA.Text      = $nombreArma
                $lblA.Location  = New-Object System.Drawing.Point(5, $yProf)
                $lblA.Size      = New-Object System.Drawing.Size(150, 16)
                $lblA.Font      = $fPeq
                $lblA.ForeColor = [System.Drawing.Color]::FromArgb(230, 220, 200)
                $panelProf.Controls.Add($lblA)

                $lblAVal = New-Object System.Windows.Forms.Label
                $lblAVal.Text      = "$valor / $maximo"
                $lblAVal.Location  = New-Object System.Drawing.Point(155, $yProf)
                $lblAVal.Size      = New-Object System.Drawing.Size(85, 16)
                $lblAVal.Font      = $fPeq
                $lblAVal.ForeColor = [System.Drawing.Color]::FromArgb(180, 170, 150)
                $lblAVal.TextAlign = 'MiddleRight'
                $panelProf.Controls.Add($lblAVal)
                $yProf += 18

                $barAFondo = New-Object System.Windows.Forms.Panel
                $barAFondo.Location  = New-Object System.Drawing.Point(5, $yProf)
                $barAFondo.Size      = New-Object System.Drawing.Size(235, 8)
                $barAFondo.BackColor = [System.Drawing.Color]::FromArgb(35, 30, 25)
                $panelProf.Controls.Add($barAFondo)

                $anchoA = [math]::Max(2, [int](235 * $valor / $maximo))
                $barARell = New-Object System.Windows.Forms.Panel
                $barARell.Location  = New-Object System.Drawing.Point(0, 0)
                $barARell.Size      = New-Object System.Drawing.Size($anchoA, 8)
                $barARell.BackColor = [System.Drawing.Color]::FromArgb(180, 140, 60)
                $barAFondo.Controls.Add($barARell)
                $tooltip.SetToolTip($barAFondo, "$nombreArma`: $valor / $maximo ($pct%)")
                $tooltip.SetToolTip($barARell,  "$nombreArma`: $valor / $maximo ($pct%)")
                $yProf += 16
            }

        } catch {
            $lblFicha.Text    = "Error: $($_.Exception.Message)"
            $lblCargando.Text = ""
        }
    })

    $txtNombre.Add_KeyDown({
        if ($_.KeyCode -eq 'Enter') { $btnBuscar.PerformClick() }
    })

    # Auto-buscar si se paso nombre (desde poblacion del panel, etc.)
    $autoNom = $null
    try {
        if ($nombreInicial -and ([string]$nombreInicial).Trim().Length -gt 0) {
            $autoNom = ([string]$nombreInicial).Trim()
        } elseif ($Global:ArmeriaAutoBuscar -and ([string]$Global:ArmeriaAutoBuscar).Trim().Length -gt 0) {
            $autoNom = ([string]$Global:ArmeriaAutoBuscar).Trim()
        }
    } catch {}
    # Referencias script para el handler (evitar NULL en el Tick)
    $script:ArmeriaTxtNombreRef = $txtNombre
    $script:ArmeriaBtnBuscarRef = $btnBuscar
    if ($autoNom) {
        $script:ArmeriaAutoNombrePendiente = $autoNom
        try { $txtNombre.Text = $autoNom } catch {}
        $armForm.Add_Shown({
            try {
                $n = $script:ArmeriaAutoNombrePendiente
                if (-not $n) { return }
                if ($script:ArmeriaTxtNombreRef) {
                    $script:ArmeriaTxtNombreRef.Text = $n
                }
                $tm = New-Object System.Windows.Forms.Timer
                $tm.Interval = 250
                $script:ArmeriaAutoTimer = $tm
                $tm.Add_Tick({
                    try {
                        if ($script:ArmeriaAutoTimer) {
                            $script:ArmeriaAutoTimer.Stop()
                            $script:ArmeriaAutoTimer.Dispose()
                            $script:ArmeriaAutoTimer = $null
                        }
                    } catch {}
                    try {
                        if ($script:ArmeriaBtnBuscarRef) {
                            $script:ArmeriaBtnBuscarRef.PerformClick()
                        }
                    } catch {}
                    try {
                        $script:ArmeriaAutoNombrePendiente = $null
                        $Global:ArmeriaAutoBuscar = $null
                    } catch {}
                })
                $tm.Start()
            } catch {}
        })
    }

    $armForm.ShowDialog() | Out-Null
}