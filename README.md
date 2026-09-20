# Plutonium Modular Server Launcher
A lightweight, zero-redundancy, and scalable server management framework for Plutonium servers (configured for IW5). This system utilizes Windows directory junctions (`mklink /J`) to share core game files, engine versions, and custom assets across multiple server instances without duplicating gigabytes of data.

## 🌟 Key Features

* **Zero File Bloat:** Each server instance weighs only around 500MB on disk by symlinking core assets rather than copying them.
* **Centralized Version Control:** Store your Plutonium versions (e.g., `r5338`, `r5346`) and base game files in a single shared repository.
* **Local-First Overrides:** Automatically checks for instance-specific local folders for admin files, scripts, and plugins, falling back to central repositories if none are found.
* **Selective Map & Mod Linking:** Manage your FastDL and custom maps/mods centrally and link only what you need per instance via simple config variables.
* **Integrated IW4MAdmin Support:** Optional, toggleable check that validates and boots up your management panel automatically alongside your server.

## 📂 Directory Architecture

The system is split between a core engine repository (`base/`) and isolated instance directories, allowing you to point everything to your chosen root path (e.g., `Y:\.PlutoniumServers`):

- **`base/`**: Contains core scripts, shared game files, and engine versions.
- **`servers/`** *(or anywhere on your system)*: Houses your individual instance configs (e.g., `!S1.bat`) and auto-generated runtime junctions.

```text
.PlutoniumServers/
├── base/
│   ├── base_game_files/       <-- Put your clean game installation here
│   ├── plutonium_versions/    <-- Store your downloaded Pluto version folders here
│   ├── server_config_template.bat <-- Copy this to create new servers
│   ├── start_server_base.bat  <-- The core script handling junctions and launching
│   ├── DownloadPluto.bat
│   └── plutonium.exe
└── servers/
    ├── S1/                    <-- Instance 1 folder (auto-generated junctions)
    └── S2/                    <-- Instance 2 folder (auto-generated junctions)
```
(Note: Your active instance configuration files like !S1.bat can live right alongside your servers folder or anywhere else you prefer to run them from!)

## 📥 Getting Started & Installation

If you want to grab and run the framework without using Git:

1. Scroll to the top of the main repository page on GitHub.
2. Click the green **`<> Code`** button.
3. Select **Download ZIP**.
4. Extract the contents of the ZIP file anywhere you want on your system (e.g., `Y:\.PlutoniumServers`).

---

## ⚙️ Configuration File Breakdown (`server_config_template.bat`)

When you copy the template and configure your instance batch file (e.g., `!S1.bat`), here is what every option does:

* **`GAME`**: Specifies the game shortcode for Plutonium (e.g., `iw5mp` for Modern Warfare 3).
* **`PLUTONIUM_VERSION`**: The specific engine version folder stored in your `base\plutonium_versions\` directory (e.g., `r5338`).
* **`FORCE_FRESH_COPY`**: Set to `1` to force a clean re-link/refresh of instance files, or `0` for normal startup.
* **`SERVER_KEY`**: Your unique Plutonium server key obtained from the Plutonium dashboard.
* **`CFG`**: The specific configuration file name your server will load upon startup (e.g., `ss_server_snd.cfg`).
* **`NAME`**: The short identifier name for your server instance.
* **`PORT`**: The network port your server instance will bind to (e.g., `27017`).
* **`PLUTONIUMSERVER`**: The absolute path pointing directly to your root framework directory (e.g., `Y:\.PlutoniumServers`).
* **`ENABLE_IW4MADMIN`**: Toggle to enable (`1`) or disable (`0`) automatic IW4MAdmin integration.
* **`IW4MADMIN_DIR`**: Absolute path pointing to your IW4MAdmin installation directory for status validation and auto-launching.
* **`LINK_SERVERDATA_DEBUG` / `LINK_USERMAP_DEBUG` / `LINK_MOD_DEBUG`**: Console debug toggles (`1` to show verbose paths/linking info, `0` to hide).
* **`SERVER_USERMAPS`**: Controls custom maps linking. Set to `all` to link every map available, or input a space-separated list (e.g., `mp_asylum mp_backlot_sh`).
* **`SERVER_MODS`**: Space-separated list of specific custom mods to link into this instance (leave blank if running vanilla/base configs).

---

## 🚀 How to Run

1. Ensure your base game files are placed correctly in `base\base_game_files\iw5`.
2. Ensure your target Plutonium version folder is placed inside `base\plutonium_versions\`.
3. Double-click your configured instance batch file (e.g., `!S1.bat`) from wherever you stored it. The script will automatically:
   - Validate and create the necessary directory junctions.
   - Check if IW4MAdmin is running (and boot it up via Windows Terminal if enabled and offline).
   - Launch your Plutonium server instance with zero redundant asset duplication on disk.
