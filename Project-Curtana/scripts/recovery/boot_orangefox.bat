@echo off
setlocal EnableExtensions

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

set "IMAGE=%~1"
if "%IMAGE%"=="" set "IMAGE=%CURTANA_RECOVERY_DIR%\orangefox.img"

echo.
echo [Project-Curtana] Temporary OrangeFox boot
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

echo [SAFETY] This command boots the image in RAM and does not flash it.
echo [INFO] Running fastboot boot...
"%CURTANA_FASTBOOT%" boot "%IMAGE%"
if errorlevel 1 (
    echo [ERROR] fastboot boot failed.
    exit /b 4
)

echo [OK] Boot command sent. Wait for OrangeFox to load on the device.
exit /b 0

:help
echo Usage:
echo   boot_orangefox.bat
echo   boot_orangefox.bat C:\path\to\OrangeFox.img
echo.
echo Temporarily boots an OrangeFox recovery image without flashing it.
exit /b 0

