@echo off
setlocal EnableDelayedExpansion
:: ==========================================
:: CONFIGURATION
:: ==========================================

:: Game and Engine Mode (e.g., iw5mp for Multiplayer)
set "GAME=iw5mp"

:: Target Plutonium version folder name inside base\plutonium_versions\ (e.g., r5338)
set "PLUTO_VERSION=r5338"

:: Set to 1 to completely wipe and re-copy PlutoData\%PLUTO_VERSION% on startup, or 0 to keep existing files
set "FORCE_FRESH_COPY=0"

:: Your official Plutonium server token/key required for hosting online
:: Generate/get your key from: https://platform.plutonium.pw/servers
set "SERVER_KEY="

:: Configuration file name loaded from your serverData\admin folder (e.g., ss_server_snd.cfg)
set "CFG=ss_server_snd.cfg"

:: Unique folder identifier for this specific instance (determines its workspace inside SERVERS_DIR)
set "NAME=S1"

:: Network port number used for incoming server traffic and client connections
set "PORT=27017"

:: Active mod name for this specific instance (only specify folder name, e.g., "my_mod", not "mods/my_mod")
set "MOD="

:: Root path pointing directly to your central PlutoniumServers base directory
set "PLUTONIUMSERVER=Y:\.PlutoniumServers"

:: Target directory for runtime instances. Defaults to a 'servers' folder inside your base path, 
:: but can be overridden with any custom absolute path (e.g., "D:\MyServerInstances" or on another drive)
set "SERVERS_DIR=%PLUTONIUMSERVER%\servers"

:: Set to 1 to automatically check for and launch IW4MAdmin if offline, or 0 to skip it completely
:: does not download or update  (maybe add in future)
set "ENABLE_IW4MADMIN=1"

:: Absolute directory path where your IW4MAdmin files and startup script are located
set "IW4MADMIN_DIR=%PLUTONIUMSERVER%\IW4MAdmin"

:: Debug logging switches for tracking symlink/junction creation (1 = Enabled, 0 = Disabled)
SET "LINK_SERVERDATA_DEBUG=1" 
set "LINK_USERMAP_DEBUG=0"
set "LINK_MOD_DEBUG=0"

:: Centralized server data repository path (automatically appends game name internally, e.g., serverData\iw5)
:: Example path structure: %PLUTONIUMSERVER%\serverData
:: Expected internal layout: \iw5\admin, \iw5\scripts, and \iw5\plugins
set "CENTRAL_SERVERDATA=%PLUTONIUMSERVER%\serverData"

:: Central Map & Mod Repository Root (used for FastDL / webserver redirection points)
:: Example path structure: %PLUTONIUMSERVER%\maps_mods
:: Expected internal layout: \iw5\mods and \iw5\usermaps
set "CENTRAL_MAPS_MODS=%PLUTONIUMSERVER%\maps_mods"

:: Space-separated list of central usermaps to link to this instance (use "all" to link everything, or specific names)
set "SERVER_USERMAPS=all"

:: Space-separated list of central mods to link to this instance (only specify mod folder names, not "mods/")
set "SERVER_MODS="

:: ==========================================
:: LAUNCH EXECUTION
:: ==========================================
wt -w 0 nt -d "%PLUTONIUMSERVER%\base" --title "Plutonium IW5 - %NAME%" cmd /k "start_server_base.bat"
timeout /t 1 /nobreak >nul
