@echo off
setlocal EnableExtensions

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

echo.
echo [Project-Curtana] Clean local toolkit temporary files
echo.

if "%CURTANA_HAS_ADB%"=="1" (
    echo [INFO] Stopping ADB server...
    "%CURTANA_ADB%" kill-server >nul 2>&1
)

set "LOCAL_TEMP=%TEMP%\project-curtana"
if exist "%LOCAL_TEMP%" (
    echo [INFO] Removing "%LOCAL_TEMP%"...
    rmdir /s /q "%LOCAL_TEMP%"
)

if not exist "%CURTANA_LOG_DIR%" mkdir "%CURTANA_LOG_DIR%" >nul 2>&1
for %%F in ("%CURTANA_LOG_DIR%\*.tmp" "%CURTANA_LOG_DIR%\*.partial") do (
    if exist "%%~fF" del /f /q "%%~fF"
)

echo [OK] Temporary toolkit files cleaned. Persistent logs were kept.
exit /b 0

:help
echo Usage: clean_temp.bat
echo.
echo Stops ADB and removes temporary Project-Curtana files without deleting persistent logs or backups.
exit /b 0

