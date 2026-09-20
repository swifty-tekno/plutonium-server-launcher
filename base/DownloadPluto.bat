@echo off
setlocal

set "baseDir=%~dp0"
set "exePath=%baseDir%plutonium.exe"
set "versionsDir=%baseDir%plutonium_versions"
set "tempDir=%versionsDir%\_temp_download"

if not exist "%exePath%" (
    echo [ERROR] plutonium.exe not found in the base directory!
    pause
    exit /b 1
)

:: Clean up any stale temp directory if it exists
if exist "%tempDir%" rmdir /s /q "%tempDir%"

echo [INFO] Running plutonium.exe to fetch latest files...
echo [INFO] plutonium.exe will open a windows and download files.
echo [INFO] once its complete you need to close it for script to continue.
"%exePath%" -install-dir "%tempDir%" -update-only

echo [INFO] Checking downloaded bootstrapper version properties...
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "$bootstrapper = Join-Path '%tempDir%' 'bin\plutonium-bootstrapper-win32.exe'; if (Test-Path $bootstrapper) { $rawVersion = (Get-Item $bootstrapper).VersionInfo.FileVersion; if ($rawVersion) { $rawVersion.Split('.')[-1].Trim() } }"') do (
    set "VERSION_STRING=%%i"
)

if "%VERSION_STRING%"=="" (
    echo [ERROR] Could not detect version from the downloaded bootstrapper! Check %tempDir% manually.
    pause
    exit /b 1
)

set "finalDir=%versionsDir%\r%VERSION_STRING%"

:: Check if this version already exists
if exist "%finalDir%" (
    echo [INFO] Version r%VERSION_STRING% already exists. Cleaning up temp files and exiting...
    rmdir /s /q "%tempDir%"
    echo [SUCCESS] No changes made. You are already up to date!
    pause
    exit /b 0
)

:: Automatically rename the temp folder to match the stripped version name (e.g., r5346)
ren "%tempDir%" "r%VERSION_STRING%"

echo [SUCCESS] Downloaded and created new version folder: r%VERSION_STRING%
pause
endlocal
