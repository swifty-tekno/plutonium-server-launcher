@echo off
setlocal EnableDelayedExpansion
:: ==========================================
:: CONFIGURATION
:: ==========================================
set "GAME=iw5mp"
set "PLUTONIUM_VERSION=r5338"

:: Set FORCE_FRESH_COPY to 1 to wipe existing PlutoData\%PLUTO_VERSION% and copy fresh
set "FORCE_FRESH_COPY=0"

set "SERVER_KEY="
:: CFG stored in %CENTRAL_SERVERDATA%\serverData\gamename\admin" will be linked to server instance
set "CFG=server.cfg"
:: folder name inside servers directory
set "NAME=SERVER1"
set "PORT=27017"
:: when setting the mod name you only need to specify modname not "mods/modname"
set "MOD="

SET "LINK_SERVERDATA_DEBUG=0" 
set "LINK_USERMAP_DEBUG=0"
set "LINK_MOD_DEBUG=0"

:: Point directly to your PlutoniumServers base directory
set "PLUTONIUMSERVER=Y:\.PlutoniumServers"

:: Set to 1 to enable IW4MAdmin check/launch, or 0 to skip it completely
set "ENABLE_IW4MADMIN=1"
:: IW4MAdmin directory
set "IW4MADMIN_DIR=%PLUTONIUMSERVER%\IW4MAdmin"

:: game is added on as part of path ie  serverData\iw5
set "CENTRAL_SERVERDATA=%PLUTONIUMSERVER%\serverData"
:: Central Map & Mod Repository Setup //used for fastdl point webserver to "CENTRAL_MAPS_MODS=%PLUTONIUMSERVER%\maps_mods\gamename"
set "CENTRAL_MAPS_MODS=%PLUTONIUMSERVER%\maps_mods"
:: Space-separated list of maps/mods from central repository to link to this instance
set "SERVER_USERMAPS=all"
:: when setting the mod name you only need to specify modname not "mods/modname"
set "SERVER_MODS="

:: opens in new window
::call "%PLUTONIUMSERVER%\base\start_server_base.bat"
:: Opens your second server script in a fresh tab right next to your current one
wt -w 0 nt -d "%PLUTONIUMSERVER%\base" --title "Plutonium IW5 - S1" cmd /k "start_server_base.bat"
timeout /t 1 /nobreak >nul
