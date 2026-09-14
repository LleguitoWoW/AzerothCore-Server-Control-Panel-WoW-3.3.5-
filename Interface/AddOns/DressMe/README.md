# DressMe Unlocked + Control Panel (AzerothCore)

**Language / Idioma**

- [English](#english)
- [Español](#espa%C3%B1ol)

---

<a id="english"></a>

## English

Integration of the **DressMe** wardrobe addon with the **Control Panel** for **AzerothCore WotLK 3.3.5** private servers: only appearances unlocked in `custom_unlocked_appearances` (mod-transmog) are shown.

### Acknowledgments

The wardrobe addon is based on the original work of **[GetLocalPlayer](https://github.com/GetLocalPlayer)**:

> **[DressMe](https://github.com/GetLocalPlayer/DressMe)** — https://github.com/GetLocalPlayer/DressMe

All credit for the original DressMe belongs to them. This version only adds collection filtering, a minimap button, and Control Panel synchronization.

### Project contents

| Folder / pack | Description |
|---------------|-------------|
| `DressMe_Unlocked/` | Modified client addon (filter + minimap) |
| `Panel_DressMe_Boton/Scripts/` | Control Panel module and scripts |

### Requirements

- AzerothCore WotLK + mod-transmog (`custom_unlocked_appearances`)
- WoW 3.3.5a client
- Control Panel v1.5 on Windows with PowerShell 5.1+
- MySQL credentials and paths in `config_server.txt` (per installation; not shared)

### DressMe addon

- Install under `Interface/AddOns/DressMe`
- Minimap button and `/dressme`
- Filters by unlocked appearances from `UnlockedAppearances.lua`
- Requires the **modified** DressMe from this pack

### Control Panel v1.5 (DressMe integration)

- New module: `DressMeSync.ps1`
- Auto-export when loading a character in the armory (`armeria.ps1`)
- ✓ status on Transmog paperdoll (`Transmog.ps1`)
- Periodic timer (default 5 minutes) while the panel is running
- Skips playerbot-style account name prefixes: `rnb`, `rnd`, `rndbot`, `playerbot`, `bot`
- Uses `MYSQL_DIR`, `MYSQL_USER`, `MYSQL_PASS`, `CHAR_DB`, `WOW_EXE`, `DRESSME_DB_PATH` from `config_server.txt` so each user can have different credentials

### Credits

- **DressMe (original):** [GetLocalPlayer](https://github.com/GetLocalPlayer/DressMe)
- **Control Panel:** [LleguitoWoW](https://github.com/LleguitoWoW)

[↑ Language / Idioma](#dressme-unlocked--control-panel-azerothcore) · [Español](#espa%C3%B1ol)

---

<a id="español"></a>

## Español

Integración del vestidor **DressMe** con el **Panel de Control** para servidores privados **AzerothCore WotLK 3.3.5**: solo apariencias desbloqueadas en `custom_unlocked_appearances`.

### Agradecimientos

Addon original de **[GetLocalPlayer](https://github.com/GetLocalPlayer/DressMe)** — https://github.com/GetLocalPlayer/DressMe

### Addon

- Filtro por colección de cuenta
- Botón de minimapa y `/dressme`
- Instalar en `Interface/AddOns/DressMe` y mantener `db/UnlockedAppearances.lua` actualizado

### Panel de Control v1.5

- Módulo nuevo `DressMeSync.ps1`
- Auto-export al cargar un personaje en la armería
- ✓ en el paperdoll de Transmog
- Timer cada 5 minutos (configurable)
- Omite cuentas bot (`rnb`, `rnd`, `rndbot`, `playerbot`, `bot`)
- Credenciales y rutas por instalación en `config_server.txt` (no se asume el mismo user/pass para todos)

### Créditos

- DressMe original: **GetLocalPlayer** — https://github.com/GetLocalPlayer/DressMe
- Panel: [LleguitoWoW](https://github.com/LleguitoWoW)

**[↑ Language / Idioma](#dressme-unlocked--control-panel-azerothcore)** · [English](#english)
