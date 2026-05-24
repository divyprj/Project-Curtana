@echo off
setlocal EnableExtensions

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

set "IMAGE=%~1"
if "%IMAGE%"=="" set "IMAGE=%CURTANA_RECOVERY_DIR%\orangefox.img"

echo.
echo [Project-Curtana] Flash recovery partition
echo Recovery image: "%IMAGE%"
echo.

if "%CURTANA_HAS_FASTBOOT%"=="0" (
    echo [ERROR] fastboot was not found.
    echo Install platform-tools into "%CURTANA_PLATFORM_TOOLS%" or add fastboot.exe to PATH.
    exit /b 2
)

if not exist "%IMAGE%" (
    echo [ERROR] Recovery image was not found.
    echo Provide a path to an OrangeFox .img file or place it at:
    echo "%CURTANA_RECOVERY_DIR%\orangefox.img"
    exit /b 3
)

"%CURTANA_FASTBOOT%" devices | findstr /r /c:"[0-9A-Za-z].*fastboot" >nul
if errorlevel 1 (
    echo [ERROR] No Fastboot device detected.
    echo Boot the phone to Fastboot mode first.
    exit /b 1
)

echo [WARNING] This writes the recovery partition.
echo [WARNING] Use only a recovery built for curtana/miatoll and keep a known-good boot/recovery backup.
set /p CONFIRM=Type FLASH to continue: 
if /i not "%CONFIRM%"=="FLASH" (
    echo [CANCELLED] Recovery flash was not started.
    exit /b 0
)

echo [INFO] Running fastboot flash recovery...
"%CURTANA_FASTBOOT%" flash recovery "%IMAGE%"
if errorlevel 1 (
    echo [ERROR] fastboot flash recovery failed.
    exit /b 4
)

echo [INFO] Rebooting directly into recovery to prevent stock recovery restoration...
"%CURTANA_FASTBOOT%" reboot recovery 2>nul
if errorlevel 1 (
    echo [WARN] fastboot reboot recovery was not accepted. Use hardware keys to boot recovery immediately.
)

echo [OK] Recovery flash flow completed.
exit /b 0

:help
echo Usage:
echo   flash_recovery.bat
echo   flash_recovery.bat C:\path\to\OrangeFox.img
echo.
echo Flashes an OrangeFox/TWRP-compatible recovery image to the recovery partition.
exit /b 0

