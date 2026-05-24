@echo off
setlocal EnableExtensions

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

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

if "%~1"=="" (
    echo [Project-Curtana] Opening interactive adb shell. Type exit to return.
    "%CURTANA_ADB%" shell
) else (
    echo [Project-Curtana] Running adb shell command: %*
    "%CURTANA_ADB%" shell %*
)

exit /b %ERRORLEVEL%

:help
echo Usage:
echo   adb_shell.bat
echo   adb_shell.bat getprop ro.product.device
echo.
echo Opens an interactive ADB shell or runs the supplied shell command.
exit /b 0

