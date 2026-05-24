@echo off
setlocal EnableExtensions

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

echo.
echo [Project-Curtana] Bootloader unlock status
echo.

if "%CURTANA_HAS_FASTBOOT%"=="0" (
    echo [ERROR] fastboot was not found.
    echo Install platform-tools into "%CURTANA_PLATFORM_TOOLS%" or add fastboot.exe to PATH.
    exit /b 2
)

"%CURTANA_FASTBOOT%" devices | findstr /r /c:"[0-9A-Za-z].*fastboot" >nul
if errorlevel 1 (
    echo [ERROR] No Fastboot device detected.
    echo Boot the phone to Fastboot mode and run scripts\fastboot\verify_fastboot.bat.
    exit /b 1
)

echo [INFO] Querying fastboot getvar unlocked...
"%CURTANA_FASTBOOT%" getvar unlocked 2>&1
echo.
echo [INFO] Querying Xiaomi OEM device-info output...
"%CURTANA_FASTBOOT%" oem device-info 2>&1
echo.
echo [NOTE] Flashing custom recovery or custom ROMs requires an unlocked bootloader.
exit /b 0

:help
echo Usage: unlock_status_check.bat
echo.
echo Prints bootloader lock state using standard Fastboot and Xiaomi OEM output.
exit /b 0

