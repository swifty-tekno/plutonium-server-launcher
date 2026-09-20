@echo off
set "installDir=Y:\Games\Plutonium\PlutoniumServers\base\plutonium_versions\temp"

:: Pass the variable into the -install-dir argument
y:\Games\Plutonium\PlutoniumServers\base\plutonium.exe -install-dir "%installDir%" -update-only
