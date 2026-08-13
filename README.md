# 🛡️ AzerothCore Server Control Panel (WoW 3.3.5)

A graphical control panel built with **PowerShell + Windows Forms** for managing a World of Warcraft private server (AzerothCore / TrinityCore 3.3.5) without having to touch the console manually. It includes service management, account management, character management, rates, a Wowhead-style visual armory, a path configuration wizard, and a standalone HTML NPCBots generator.

> ⚠️ This project is intended for **development/testing environments on Windows**, not for public production use. It requires an already installed and compiled AzerothCore/TrinityCore server.

---

## ✨ Main Features

### 🎛️ Main Panel (`Panel-GUI.ps1`)
- Real-time status indicators (Online/Offline) for **MySQL**, **AuthServer**, **WorldServer**, and the **World of Warcraft** client.
- Individual **Start/Stop** buttons for each service.
- **"Start All"** / **"Stop All"** button that boots or shuts down the whole stack in the correct order (MySQL → AuthServer → WorldServer), with a progress bar and configurable wait times.
- Safe MySQL shutdown: tries `mysqladmin shutdown` and a SQL `SHUTDOWN` before forcing the process to close as a last resort.
- Welcome **splash screen** and a **farewell screen** with social media links (GitHub, Buy Me a Coffee, YouTube), both fully optional (they only show up if the corresponding images exist).
- Initial **configuration wizard**: pick the MySQL, AuthServer, and WorldServer folders plus the `Wow.exe` executable through a graphical file/folder picker, saved to `config_server.txt`.
- MySQL credential management split between an application user (guilds/characters) and an admin user (shutdown/permissions).
- **Multi-language** support (Spanish / English) via a centralized dictionary that's easy to extend with more languages.

### 👤 Account Management (`cuentas.ps1`)
- Create new accounts (`account create`) directly from the UI.
- Promote an account to **Game Master** (`account set gmlevel`).
- Commands are sent safely to the WorldServer console by simulating real keystrokes (no external macros).

### 🧙 Character & Guild Management (`personajes.ps1`)
- **PDUMP** generator and manager (export/import characters).
- **Guild SQL generator**, output as plain, editable text: it builds the required rows for `guild`, `guild_rank`, `guild_bank_tab`, `guild_bank_right`, `guild_member`, `guild_bank_item`, `guild_eventlog`, etc., with placeholders (`@@GUILDID@@`, `@@GMGUID@@`, `@@ITEMBASE@@`) that get substituted automatically before injection — nothing is hidden, you see exactly what will be inserted.
- Direct injection of the generated SQL into the chosen database, with a list of previously saved dumps.

### ⚔️ Character Armory (`armeria.ps1`)
A **Wowhead/Armory-style** character viewer, built entirely in Windows Forms:
- **Paperdoll** with all equipment slots and item tooltips (automatically downloads and caches icons).
- **Reputation** window, organized by faction groups (Alliance, Horde, battlegrounds, neutrals...).
- **Achievements** window.
- **Talents, spells, and glyphs** window, with spec detection based on class.
- **PvP** stats window (honor, known titles, etc.).
- Local per-character cache system to speed up repeated loads.

### 📈 Rates Configuration (`rates.ps1`)
A visual editor for the `worldserver.conf` file that lets you adjust settings without touching the file by hand:
- Experience rates (`Rate.XP.Kill`, `Rate.XP.Quest`, `Rate.XP.Quest.DF`, `Rate.XP.Explore`).
- Reputation gain rate (`Rate.Reputation.Gain`).
- Skill/profession rates (`SkillGain.Crafting`, `SkillGain.Defense`, `SkillGain.Gathering`, `SkillGain.Weapon`, `MaxPrimaryTradeSkill`).
- Creature rates by difficulty (damage, spell damage, and HP: `Rate.Creature.*.Damage/.SpellDamage/.HP`).
- Automatic detection of the `worldserver.conf` path (or manual selection if not found).
- Saves changes directly to the server's real configuration file.

### 📥 HD Client Download (`descargas.ps1`)
A window with direct links (Google Drive / MEGA) to download the game client in multiple parts.

### 🌐 Multi-language (`idiomas.ps1`)
Centralized dictionary with all UI strings in **Spanish** and **English**, loaded dynamically on panel startup.

### ⌨️ Ctrl+C to Processes (`send-ctrlc.ps1`)
A pure PowerShell helper script that uses the Windows API (`kernel32.dll`) to attach to another process's console and send it a real `CTRL_C_EVENT`, enabling clean shutdowns of AuthServer/WorldServer from the panel.

### 🤖 NPCBots Creator (`NPCBotsGenerator.html`)
A **standalone** HTML/CSS/JS tool (no need for the panel or PowerShell) with a "fantasy scroll" visual theme for guided generation of the data/SQL needed to create NPCBots in AzerothCore 3.3.5. Just open it directly in your browser.

### 🚀 Launcher (`Lanzador.bat`)
A `.bat` file that starts the panel (`Panel-GUI.ps1`) while hiding the black PowerShell console window, for a clean "desktop app" feel.

---

## 📁 Project Structure

```
📦 AzerothCore Control Panel
├── Lanzador.bat                  # Double-click to open the panel (no console window)
├── config_server.txt             # Auto-generated with your paths and credentials
├── Imagenes/                     # (optional) splash.png, despedida.png, social icons
├── Scripts/
│   ├── Panel-GUI.ps1             # Main script / interface
│   ├── cuentas.ps1                # Accounts & GM module
│   ├── personajes.ps1             # PDUMP and guilds module
│   ├── armeria.ps1                # Armory / paperdoll module
│   ├── rates.ps1                  # Rates configuration module
│   ├── descargas.ps1              # Client download module
│   ├── idiomas.ps1                # ES/EN text dictionary
│   └── send-ctrlc.ps1             # Clean shutdown utility (Ctrl+C)
└── NPCBotsGenerator.html         # NPCBots generator (standalone)
```

> 💡 The folder names (`Scripts/`, `Imagenes/`) are what `Panel-GUI.ps1` expects by default — keep this layout so everything works without editing any paths.

---

## 🔧 Requirements

- **Windows 10/11** with PowerShell 5.1 or higher.
- A compiled **AzerothCore** or **TrinityCore** server (3.3.5 branch), with `mysqld.exe`, `authserver.exe`, and `worldserver.exe` available.
- **World of Warcraft 3.3.5a** client.
- Permission to run PowerShell scripts (the launcher already uses `-ExecutionPolicy Bypass`, so you don't need to change your system's execution policy).

---

## ▶️ Installation & Usage

1. Download or clone this repository.
2. Place the scripts inside a `Scripts/` folder next to `Lanzador.bat` (see structure above).
3. (Optional) Create an `Imagenes/` folder with `splash.png`, `despedida.png`, `icono_github.png`, `icono_coffee.png`, and `icono_youtube.png` to customize the welcome/farewell screens.
4. Run **`Lanzador.bat`**.
5. On first run, a wizard will ask you to select:
   - The MySQL `bin` folder.
   - The `authserver.exe` folder.
   - The `worldserver.exe` folder.
   - The `Wow.exe` path.
6. That's it! You can now start/stop the server, create accounts, manage characters, tune rates, and browse the armory from a single window.

All configuration is saved to `config_server.txt`, at the application root (one level above `Scripts/`), so each installation of the panel can have its own paths and credentials.

---

## 🌍 Languages

The panel currently supports:
- 🇪🇸 Spanish (default)
- 🇬🇧 English

A new language can be added by extending the `$Global:Textos` dictionary in `idiomas.ps1`.

---

## ⚠️ Important Notes

- This panel **executes real administrative commands** on your server (creating accounts, granting GM rank, stopping/forcing processes, modifying `worldserver.conf`, injecting SQL). Only use it on environments you control.
- MySQL passwords are stored in plain text in `config_server.txt` so the panel can operate without asking for them every time; don't push it to public repositories with your real credentials inside.
- Commands sent to `worldserver`/`authserver` are simulated via keystrokes on the console window, so it's best not to move your mouse/keyboard focus while the panel is sending a command.

---

## 🙌 Credits

Developed by **[LleguitoWoW](https://github.com/LleguitoWoW)**.

- 🐙 GitHub: https://github.com/LleguitoWoW
- ☕ Buy Me a Coffee: https://buymeacoffee.com/llegus69h
- ▶️ YouTube: https://www.youtube.com/@Lleguito

---

