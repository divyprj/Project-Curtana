@echo off
setlocal EnableExtensions EnableDelayedExpansion

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

echo.
echo [Project-Curtana] Fastboot verification
echo.

if "%CURTANA_HAS_FASTBOOT%"=="0" (
    echo [ERROR] fastboot was not found.
    echo Install platform-tools into "%CURTANA_PLATFORM_TOOLS%" or add fastboot.exe to PATH.
    exit /b 2
)

set "DEVICE_COUNT=0"
for /f "tokens=1,2" %%A in ('"%CURTANA_FASTBOOT%" devices') do (
    if not "%%A"=="" set /a DEVICE_COUNT+=1
)

if "!DEVICE_COUNT!"=="0" (
    echo [WARN] No Fastboot device detected.
    echo Confirm the phone shows the Fastboot screen, use a data-capable cable, and verify drivers.
    exit /b 1
)

echo [OK] Fastboot device detected.
echo.
echo Device variables:
"%CURTANA_FASTBOOT%" getvar product 2>&1
"%CURTANA_FASTBOOT%" getvar unlocked 2>&1
"%CURTANA_FASTBOOT%" getvar current-slot 2>&1

echo.
echo [NOTE] Curtana devices may report product as curtana or miatoll depending on bootloader/recovery context.
exit /b 0

:help
echo Usage: verify_fastboot.bat
echo.
echo Checks whether a device is visible in Fastboot and prints key bootloader variables.
exit /b 0

