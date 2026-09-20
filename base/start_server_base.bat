@echo off
setlocal EnableDelayedExpansion

::set "PLUTONIUMSERVER_BASE=Y:\Games\Plutonium\PlutoniumServers\base"
set "VERSIONS_DIR=%PLUTONIUMSERVER%\base\plutonium_versions"

:: ==========================================
:: PRE-FLIGHT VALIDATIONS & BASE MAPPING
:: ==========================================
if "%GAME%"=="" (
    echo ERROR: GAME variable is not set.
    pause
    exit /b
)

:: Dynamically strip the last 2 characters (mp/zm/sp) to derive base game folder
set "BASE_GAME=%GAME:~0,-2%"
set "BASE_GAME_DIR=%PLUTONIUMSERVER%\base\base_game_files\%BASE_GAME%"

:: Validate that the base game folder exists on disk
if not exist "%BASE_GAME_DIR%" (
    echo ERROR: Base game directory not found for '%GAME%'.
    echo Expected path: %BASE_GAME_DIR%
    pause
    exit /b
)

:: Check if PLUTO_VERSION is empty
if "%PLUTO_VERSION%"=="" (
    echo ERROR: PLUTO_VERSION is not set.
    echo Available versions in %VERSIONS_DIR%:
    echo ----------------------------------------
    if exist "%VERSIONS_DIR%" (
        dir /b /ad "%VERSIONS_DIR%"
    ) else (
        echo   [Directory not found: %VERSIONS_DIR%]
    )
    echo ----------------------------------------
    pause
    exit /b
)

:: Check if the specified PLUTO_VERSION folder exists
if not exist "%VERSIONS_DIR%\%PLUTO_VERSION%" (
    echo ERROR: Specified PLUTO_VERSION '%PLUTO_VERSION%' does not exist in %VERSIONS_DIR%.
    echo Available versions:
    echo ----------------------------------------
    dir /b /ad "%VERSIONS_DIR%"
    echo ----------------------------------------
    pause
    exit /b
)

:: Set remaining paths using mapped BASE_GAME
set "LOCAL_GAME_FILES=%PLUTONIUMSERVER%\servers\%NAME%\GameFiles"
set "LOCAL_PLUTO_DATA=%PLUTONIUMSERVER%\servers\%NAME%\PlutoData\%PLUTO_VERSION%"
set "LOCAL_SERVER_DATA=%PLUTONIUMSERVER%\servers\%NAME%\ServerData"
set "SOURCE_SERVER_DATA=%PLUTONIUMSERVER%\serverData\%BASE_GAME%"

:: Automatically include active %MOD% into %SERVER_MODS% if set
if not "%MOD%"=="" (
    set "SERVER_MODS=%MOD% %SERVER_MODS%"
)

:: Check if SERVER_KEY is set
if "%SERVER_KEY%"=="" (
    echo ERROR: SERVER_KEY variable is not set.
    pause
    exit /b
)

:: Check if the specified CFG file exists in serverData\admin
set "CFG_FILE_PATH=%SOURCE_SERVER_DATA%\admin\%CFG%"
if not exist "%CFG_FILE_PATH%" (
    echo ERROR: Configuration file '%CFG%' was not found in
    echo - %SOURCE_SERVER_DATA%\admin
    echo Expected path: %CFG_FILE_PATH%
    pause
    exit /b
)

echo ===================================================
echo Launching Game Mode    : %GAME% (Base Game Folder: %BASE_GAME%)
echo Version Target         : %PLUTO_VERSION%
echo Force Fresh Copy       : %FORCE_FRESH_COPY%
echo Instance Name          : %NAME%
echo Net Port               : %PORT%
echo Config File            : %CFG%
if not "%MOD%"=="" (
    echo Active Mod             : %MOD%
)
echo Server Key             : [LOADED]
echo Server Directory       : %PLUTONIUMSERVER%\servers\%NAME%
echo ===================================================

:: ==========================================
:: SETUP SYMLINKS & DATA
:: ==========================================
:: Step 1: Game Files Junction
if exist "%LOCAL_GAME_FILES%" goto :skip_gamefiles_link
echo [1/3] Setting up Game Files Link for %BASE_GAME%...
mklink /J "%LOCAL_GAME_FILES%" "%BASE_GAME_DIR%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [Linker] Standard user lacks link permissions. Requesting temporary elevation...
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c mklink /J \"%LOCAL_GAME_FILES%\" \"%BASE_GAME_DIR%\"' -Verb RunAs -Wait"
)
if %errorlevel% neq 0 (
    echo ERROR: Failed to create GameFiles junction even with elevation.
    pause
    exit /b
)
goto :done_gamefiles_link

:skip_gamefiles_link
echo [1/3] Game Files Link for %BASE_GAME% already exists. Skipping.
:done_gamefiles_link

:: Step 2: PlutoData Files Copy
if "%FORCE_FRESH_COPY%"=="1" (
    if exist "%LOCAL_PLUTO_DATA%" (
        echo [2/3] FORCE_FRESH_COPY set to 1. Removing existing PlutoData\%PLUTO_VERSION%...
        rmdir /s /q "%LOCAL_PLUTO_DATA%"
    )
)

if exist "%LOCAL_PLUTO_DATA%\bin" goto :skip_plutodata_copy

echo [2/3] Setting up PlutoData Version (%PLUTO_VERSION%)...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$src = (Get-Item '%VERSIONS_DIR%\%PLUTO_VERSION%').FullName;" ^
    "$dst = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('%LOCAL_PLUTO_DATA%');" ^
    "$files = Get-ChildItem -Path $src -Recurse -File;" ^
    "$total = $files.Count;" ^
    "$i = 0;" ^
    "foreach ($f in $files) {" ^
    "    $i++;" ^
    "    $rel = $f.FullName.Substring($src.Length).TrimStart('\');" ^
    "    $fileName = $f.Name;" ^
    "    $target = Join-Path $dst $rel;" ^
    "    $targetDir = Split-Path $target -Parent;" ^
    "    if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null };" ^
    "    Copy-Item $f.FullName -Destination $target -Force;" ^
    "    $status = \"`rCopying PlutoData [%PLUTO_VERSION%]: [$i/$total] $fileName\";" ^
    "    $maxLength = [Math]::Max(0, [Console]::BufferWidth - 1);" ^
    "    if ($status.Length -gt $maxLength -and $maxLength -gt 0) { $status = $status.Substring(0, $maxLength) };" ^
    "    Write-Host -NoNewline ($status.PadRight($maxLength));" ^
    "};" ^
    "Write-Host '';"
goto :done_plutodata_copy

:skip_plutodata_copy
echo [2/3] PlutoData Version (%PLUTO_VERSION%) already present. Skipping copy.

:done_plutodata_copy

:: ==========================================
:: SETUP SYMLINKS & DATA
:: ==========================================
echo [3/3] Setting up storage junctions for %BASE_GAME%...
set "STORAGE_DIR=%LOCAL_PLUTO_DATA%\storage\%BASE_GAME%"
if not exist "%STORAGE_DIR%" mkdir "%STORAGE_DIR%"
if not exist "%LOCAL_SERVER_DATA%" mkdir "%LOCAL_SERVER_DATA%"

:: Link admin and scripts (Local override if exists, otherwise fallback to central repository)
for %%D in (admin scripts) do (
    set "CENTRAL_SRC=%SOURCE_SERVER_DATA%\%%D"
    set "LOCAL_DEST=%LOCAL_SERVER_DATA%\%%D"
    set "STORAGE_DEST=%STORAGE_DIR%\%%D"

    if exist "!LOCAL_DEST!" (
        :: Local instance-specific folder exists; link PlutoData storage to it
        if not exist "!STORAGE_DEST!" (
            echo   - Linking local PlutoData\%%D to local ServerData\%%D
            mklink /J "!STORAGE_DEST!" "!LOCAL_DEST!" > nul
        ) else (
            if "%LINK_SERVERDATA_DEBUG%"=="1" echo   - PlutoData\storage\%BASE_GAME%\%%D link already setup.
        )
    ) else (
        :: No local folder; check central repository and link both local and PlutoData storage to it
        if exist "!CENTRAL_SRC!" (
            if not exist "!LOCAL_DEST!" (
                echo   - Linking local ServerData\%%D to central repository
                mklink /J "!LOCAL_DEST!" "!CENTRAL_SRC!" > nul
            ) else (
                if "%LINK_SERVERDATA_DEBUG%"=="1" echo   - ServerData\%%D link already setup.
            )
            if not exist "!STORAGE_DEST!" (
                echo   - Linking pluto PlutoData\storage\%BASE_GAME%\%%D to central repository
                mklink /J "!STORAGE_DEST!" "!CENTRAL_SRC!" > nul
            ) else (
                if "%LINK_SERVERDATA_DEBUG%"=="1" echo   - PlutoData\storage\%BASE_GAME%\%%D link already setup.
            )
        ) else (
            echo   WARNING: Central '%%D' folder not found at !CENTRAL_SRC!
        )
    )
)

:: Handle plugins folder (Local override or fallback to central)
set "LOCAL_PLUGINS=%LOCAL_SERVER_DATA%\plugins"
set "CENTRAL_PLUGINS=%SOURCE_SERVER_DATA%\plugins"
set "PLUTO_PLUGINS=%LOCAL_PLUTO_DATA%\plugins"

if exist "%LOCAL_PLUGINS%" (
    :: Local instance-specific plugins folder exists; link PlutoData to it
    if not exist "%PLUTO_PLUGINS%" (
        echo   - Linking local PlutoData\plugins to local ServerData\plugins
        mklink /J "%PLUTO_PLUGINS%" "%LOCAL_PLUGINS%" > nul
    ) else (
        if "%LINK_SERVERDATA_DEBUG%"=="1" echo   - PlutoData\plugins link already setup.
    )
) else (
    :: No local plugins folder; check central repository and link both local and PlutoData to it
    if exist "%CENTRAL_PLUGINS%" (
        if not exist "%LOCAL_PLUGINS%" (
            echo   - Linking local ServerData\plugins to central repository
            mklink /J "%LOCAL_PLUGINS%" "%CENTRAL_PLUGINS%" > nul
        ) else (
            if "%LINK_SERVERDATA_DEBUG%"=="1" echo   - ServerData\plugins link already setup.
        )
        if not exist "%PLUTO_PLUGINS%" (
            echo   - Linking local PlutoData\plugins to central repository
            mklink /J "%PLUTO_PLUGINS%" "%CENTRAL_PLUGINS%" > nul
        ) else (
            if "%LINK_SERVERDATA_DEBUG%"=="1" echo   - PlutoData\plugins link already setup.
        )
    )
)

:: Link specified usermaps from central repository
set "USERMAPS_DIR=%STORAGE_DIR%\usermaps"
if not exist "%USERMAPS_DIR%" mkdir "%USERMAPS_DIR%"

if not "%SERVER_USERMAPS%"=="" (
    if /i "%SERVER_USERMAPS%"=="all" (
        for /D %%D in ("%CENTRAL_MAPS_MODS%\%BASE_GAME%\usermaps\*") do (
            set "MAP_NAME=%%~nxD"
            set "DEST_MAP=%USERMAPS_DIR%\%%~nxD"
            if exist "!DEST_MAP!" (
                fsutil reparsepoint query "!DEST_MAP!" >nul 2>&1
                if errorlevel 1 rmdir /s /q "!DEST_MAP!" >nul 2>&1
            )
            if not exist "!DEST_MAP!" (
                echo   - Linking central usermap: !MAP_NAME!
                mklink /J "!DEST_MAP!" "%%D" > nul
            ) else (
                if "%LINK_USERMAP_DEBUG%"=="1" echo   - usermap '!MAP_NAME!' link already setup.
            )
        )
    ) else (
        for %%M in (%SERVER_USERMAPS%) do (
            set "SRC_MAP=%CENTRAL_MAPS_MODS%\%BASE_GAME%\usermaps\%%M"
            set "DEST_MAP=%USERMAPS_DIR%\%%M"
            if exist "!SRC_MAP!" (
                if exist "!DEST_MAP!" (
                    fsutil reparsepoint query "!DEST_MAP!" >nul 2>&1
                    if errorlevel 1 rmdir /s /q "!DEST_MAP!" >nul 2>&1
                )
                if not exist "!DEST_MAP!" (
                    echo   - Linking central usermap: %%M
                    mklink /J "!DEST_MAP!" "!SRC_MAP!" > nul
                ) else (
                    if "%LINK_USERMAP_DEBUG%"=="1" echo   - usermap '%%M' link already setup.
                )
            ) else (
                echo   WARNING: Specified usermap '%%M' not found in !SRC_MAP!
            )
        )
    )
)

:: Link specified mods from central repository
set "MODS_DIR=%STORAGE_DIR%\mods"
if not exist "%MODS_DIR%" mkdir "%MODS_DIR%"

if not "%SERVER_MODS%"=="" (
    if /i "%SERVER_MODS%"=="all" (
        for /D %%D in ("%CENTRAL_MAPS_MODS%\%BASE_GAME%\mods\*") do (
            set "MOD_NAME=%%~nxD"
            set "DEST_MOD=%MODS_DIR%\%%~nxD"
            if exist "!DEST_MOD!" (
                fsutil reparsepoint query "!DEST_MOD!" >nul 2>&1
                if errorlevel 1 rmdir /s /q "!DEST_MOD!" >nul 2>&1
            )
            if not exist "!DEST_MOD!" (
                echo   - Linking central mod: !MOD_NAME!
                mklink /J "!DEST_MOD!" "%%~fD" > nul
            ) else (
                if "%LINK_MOD_DEBUG%"=="1" echo   - mod '!MOD_NAME!' link already setup.
            )
        )
    ) else (
        for %%M in (%SERVER_MODS%) do (
            set "SRC_MOD=%CENTRAL_MAPS_MODS%\%BASE_GAME%\mods\%%M"
            set "DEST_MOD=%MODS_DIR%\%%M"
            if exist "!SRC_MOD!" (
                if exist "!DEST_MOD!" (
                    fsutil reparsepoint query "!DEST_MOD!" >nul 2>&1
                    if errorlevel 1 rmdir /s /q "!DEST_MOD!" >nul 2>&1
                )
                if not exist "!DEST_MOD!" (
                    echo   - Linking central mod: %%M
                    mklink /J "!DEST_MOD!" "!SRC_MOD!" > nul
                ) else (
                    if "%LINK_MOD_DEBUG%"=="1" echo   - mod '%%M' link already setup.
                )
            ) else (
                echo   WARNING: Specified mod '%%M' not found in !SRC_MOD!
            )
        )
    )
)

:: Verify setup success
if not exist "%LOCAL_PLUTO_DATA%\bin\plutonium-bootstrapper-win32.exe" (
    echo ERROR: Could not find plutonium-bootstrapper-win32.exe in %LOCAL_PLUTO_DATA%\bin
    pause
    exit /b
)

:: ==========================================
:: CHECK & LAUNCH IW4MADMIN
:: ==========================================
echo Checking if IW4MAdmin is running...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-CimInstance Win32_Process -Filter \"Name = 'dotnet.exe'\" | Where-Object { $_.CommandLine -like '*IW4MAdmin.dll*' }) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% equ 1 (
    echo IW4MAdmin is not running. Starting IW4MAdmin...
    wt -w 0 nt -d "%PLUTONIUMSERVER%\IW4MAdmin" cmd /k "StartIW4MAdmin.cmd"
) else (
    echo IW4MAdmin is already running.
)

:: Build Mod command-line parameter
if not "%MOD%"=="" (
    set "MOD_CMDLINE=+set fs_game "mods/%MOD%""
) else (
    set "MOD_CMDLINE="
)

:: ==========================================
:: SERVER LAUNCH LOOP
:: ==========================================
title Plutonium %GAME% - %NAME% - Port %PORT%
echo Setup complete. Starting server for %GAME% [%NAME%]...

cd /D "%LOCAL_PLUTO_DATA%"

:server
echo (%date%) - (%time%) Starting %GAME% server [%NAME%]...

start "" /wait /abovenormal bin\plutonium-bootstrapper-win32.exe %GAME% "%LOCAL_GAME_FILES%" -dedicated -appdata "%LOCAL_PLUTO_DATA%" +set key %SERVER_KEY% %MOD_CMDLINE% +set testdvar test +set sv_config %CFG% +net_port %PORT% +start_map_rotate

echo (%date%) - (%time%) WARNING: %GAME% server [%NAME%] closed or crashed. Restarting...
goto server