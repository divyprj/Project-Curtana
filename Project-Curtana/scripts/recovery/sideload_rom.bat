@echo off
setlocal EnableExtensions

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

set "ROM=%~1"

echo.
echo [Project-Curtana] ADB sideload ROM package
echo.

if "%ROM%"=="" (
    echo [ERROR] Missing ROM zip path.
    echo Usage: sideload_rom.bat C:\path\to\rom.zip
    exit /b 2
)

if not exist "%ROM%" (
    echo [ERROR] ROM package not found: "%ROM%"
    exit /b 3
)

if "%CURTANA_HAS_ADB%"=="0" (
    echo [ERROR] adb was not found.
    echo Install platform-tools into "%CURTANA_PLATFORM_TOOLS%" or add adb.exe to PATH.
    exit /b 4
)

echo [INFO] File hash:
certutil -hashfile "%ROM%" SHA256 | findstr /v /i "certutil hash"
echo.
echo [SAFETY] Confirm the ROM is built for curtana or the miatoll family and matches the required firmware base.
echo [SAFETY] In OrangeFox/TWRP, start ADB Sideload before continuing here.
set /p CONFIRM=Type SIDELOAD to continue: 
if /i not "%CONFIRM%"=="SIDELOAD" (
    echo [CANCELLED] Sideload was not started.
    exit /b 0
)

echo [INFO] Running adb sideload...
"%CURTANA_ADB%" sideload "%ROM%"
if errorlevel 1 (
    echo [ERROR] adb sideload failed.
    echo Check recovery sideload mode, USB cable, and package compatibility.
    exit /b 5
)

echo [OK] Sideload completed. Review the recovery screen before rebooting.
exit /b 0

:help
echo Usage: sideload_rom.bat C:\path\to\rom.zip
echo.
echo Sends a ROM zip to recovery using ADB sideload after printing its SHA256 hash.
exit /b 0

