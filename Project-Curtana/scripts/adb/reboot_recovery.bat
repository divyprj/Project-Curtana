@echo off
setlocal EnableExtensions

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

echo.
echo [Project-Curtana] Reboot to recovery
echo.

if "%CURTANA_HAS_ADB%"=="0" (
    echo [ERROR] adb was not found.
    echo Install platform-tools into "%CURTANA_PLATFORM_TOOLS%" or add adb.exe to PATH.
    exit /b 2
)

"%CURTANA_ADB%" get-state >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No authorized ADB device is available.
    echo Run scripts\adb\check_device.bat first.
    exit /b 1
)

echo [INFO] Sending adb reboot recovery...
"%CURTANA_ADB%" reboot recovery
if errorlevel 1 (
    echo [ERROR] adb reboot recovery failed.
    exit /b 3
)

echo [OK] Reboot command sent. Wait for recovery to finish booting.
exit /b 0

:help
echo Usage: reboot_recovery.bat
echo.
echo Reboots an authorized ADB device into recovery mode.
exit /b 0

