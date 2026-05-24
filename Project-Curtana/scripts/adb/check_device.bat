@echo off
setlocal EnableExtensions EnableDelayedExpansion

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

echo.
echo [Project-Curtana] ADB device check
echo Root: "%CURTANA_ROOT%"
echo.

if "%CURTANA_HAS_ADB%"=="0" (
    echo [ERROR] adb was not found.
    echo Install Android platform-tools into "%CURTANA_PLATFORM_TOOLS%" or add adb.exe to PATH.
    exit /b 2
)

"%CURTANA_ADB%" start-server >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to start the ADB server.
    exit /b 3
)

echo Connected devices:
"%CURTANA_ADB%" devices -l
echo.

set "DEVICE_COUNT=0"
for /f "skip=1 tokens=1,2,*" %%A in ('"%CURTANA_ADB%" devices') do (
    if /i "%%B"=="device" set /a DEVICE_COUNT+=1
    if /i "%%B"=="unauthorized" (
        echo [ACTION] Device %%A is unauthorized. Unlock the phone and approve the RSA fingerprint prompt.
        exit /b 4
    )
    if /i "%%B"=="offline" (
        echo [ACTION] Device %%A is offline. Reconnect USB, toggle USB debugging, or restart ADB.
        exit /b 5
    )
)

if "!DEVICE_COUNT!"=="0" (
    echo [WARN] No authorized ADB device detected.
    echo Check USB debugging, cable quality, drivers, and the selected USB mode.
    exit /b 1
)

echo [OK] Authorized ADB device detected.
exit /b 0

:help
echo Usage: check_device.bat
echo.
echo Checks whether an authorized Android device is visible through ADB.
exit /b 0

