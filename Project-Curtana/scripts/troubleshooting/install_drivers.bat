@echo off
setlocal EnableExtensions EnableDelayedExpansion

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

echo.
echo [Project-Curtana] Windows driver installer
echo Driver directory: "%CURTANA_DRIVER_DIR%"
echo.

net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Administrator rights are required to install USB drivers.
    echo Right-click Command Prompt and choose "Run as administrator", then run this script again.
    exit /b 5
)

if not exist "%CURTANA_DRIVER_DIR%" (
    echo [ERROR] Driver directory does not exist.
    exit /b 2
)

set "EXTRACTED=%CURTANA_DRIVER_DIR%\extracted"
if not exist "%EXTRACTED%" mkdir "%EXTRACTED%" >nul 2>&1

for %%Z in ("%CURTANA_DRIVER_DIR%\*.zip") do (
    if exist "%%~fZ" (
        echo [INFO] Extracting "%%~nxZ"...
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%%~fZ' -DestinationPath '%EXTRACTED%' -Force"
        if errorlevel 1 (
            echo [ERROR] Failed to extract "%%~nxZ".
            exit /b 3
        )
    )
)

set "INF_ROOT=%CURTANA_DRIVER_DIR%"
dir /b /s "%CURTANA_DRIVER_DIR%\*.inf" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No .inf driver files were found in "%CURTANA_DRIVER_DIR%".
    echo Put extracted Google USB or Qualcomm driver files in drivers\ and try again.
    exit /b 4
)

echo [INFO] Installing driver INF files with pnputil...
pnputil /add-driver "%CURTANA_DRIVER_DIR%\*.inf" /subdirs /install
if errorlevel 1 (
    echo [ERROR] pnputil reported a driver installation failure.
    exit /b 6
)

echo [OK] Driver installation command completed. Reconnect the phone and check Device Manager.
exit /b 0

:help
echo Usage: install_drivers.bat
echo.
echo Extracts driver zip files under drivers\ and installs discovered .inf files using pnputil.
exit /b 0

