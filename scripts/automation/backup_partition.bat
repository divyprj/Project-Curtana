@echo off
setlocal EnableExtensions

if /i "%~1"=="--help" goto :help
if /i "%~1"=="/?" goto :help

call "%~dp0..\lib\curtana-env.bat"

set "PARTITION=%~1"
if "%PARTITION%"=="" set "PARTITION=boot"
set "DEVICE_BACKUP_DIR=/sdcard/ProjectCurtanaBackups"
set "LOCAL_BACKUP_DIR=%CURTANA_LOG_DIR%\backups"

echo.
echo [Project-Curtana] Partition backup
echo Partition: %PARTITION%
echo Local output: "%LOCAL_BACKUP_DIR%"
echo.

if "%CURTANA_HAS_ADB%"=="0" (
    echo [ERROR] adb was not found.
    echo Install platform-tools into "%CURTANA_PLATFORM_TOOLS%" or add adb.exe to PATH.
    exit /b 2
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "if ($args[0] -match '^[A-Za-z0-9_][A-Za-z0-9_-]*$') { exit 0 } else { exit 1 }" "%PARTITION%"
if errorlevel 1 (
    echo [ERROR] Invalid partition name: "%PARTITION%"
    echo Use only letters, numbers, underscore, and hyphen.
    exit /b 5
)

"%CURTANA_ADB%" get-state >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No authorized ADB device is available.
    exit /b 1
)

echo [WARNING] This requires root access in Android or recovery.
echo [WARNING] Backing up incorrect block paths is safer than flashing them, but root commands still require care.
set /p CONFIRM=Type BACKUP to continue: 
if /i not "%CONFIRM%"=="BACKUP" (
    echo [CANCELLED] Partition backup was not started.
    exit /b 0
)

if not exist "%LOCAL_BACKUP_DIR%" mkdir "%LOCAL_BACKUP_DIR%" >nul 2>&1

echo [INFO] Preparing device backup directory...
"%CURTANA_ADB%" shell "mkdir -p %DEVICE_BACKUP_DIR%" >nul

echo [INFO] Reading /dev/block/by-name/%PARTITION% with su...
"%CURTANA_ADB%" shell "su -c 'dd if=/dev/block/by-name/%PARTITION% of=%DEVICE_BACKUP_DIR%/%PARTITION%.img bs=4M status=none && sync'"
if errorlevel 1 (
    echo [ERROR] Root dd command failed. Verify root access and partition name.
    exit /b 3
)

echo [INFO] Pulling backup image...
"%CURTANA_ADB%" pull "%DEVICE_BACKUP_DIR%/%PARTITION%.img" "%LOCAL_BACKUP_DIR%\%PARTITION%.img"
if errorlevel 1 (
    echo [ERROR] Failed to pull backup image.
    exit /b 4
)

echo [INFO] SHA256:
certutil -hashfile "%LOCAL_BACKUP_DIR%\%PARTITION%.img" SHA256 | findstr /v /i "certutil hash"

echo [OK] Backup complete.
exit /b 0

:help
echo Usage:
echo   backup_partition.bat
echo   backup_partition.bat recovery
echo   backup_partition.bat persist
echo.
echo Backs up a named partition through ADB root/su into logs\backups.
exit /b 0
