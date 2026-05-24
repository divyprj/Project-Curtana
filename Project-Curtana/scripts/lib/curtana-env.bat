@echo off
rem Project-Curtana shared environment bootstrap.
rem This file is called by user-facing scripts; it does not perform flashing.

set "CURTANA_SCRIPT_DIR=%~dp0"
for %%I in ("%CURTANA_SCRIPT_DIR%..\..") do set "CURTANA_ROOT=%%~fI"
set "CURTANA_PLATFORM_TOOLS=%CURTANA_ROOT%\tools\platform-tools"
set "CURTANA_LOG_DIR=%CURTANA_ROOT%\logs"
set "CURTANA_RECOVERY_DIR=%CURTANA_ROOT%\recovery\orangefox"
set "CURTANA_FIRMWARE_DIR=%CURTANA_ROOT%\firmware"
set "CURTANA_DRIVER_DIR=%CURTANA_ROOT%\drivers"

if not exist "%CURTANA_LOG_DIR%" mkdir "%CURTANA_LOG_DIR%" >nul 2>&1

if exist "%CURTANA_PLATFORM_TOOLS%\adb.exe" (
    set "CURTANA_ADB=%CURTANA_PLATFORM_TOOLS%\adb.exe"
    set "CURTANA_HAS_ADB=1"
) else (
    set "CURTANA_ADB=adb"
    where adb >nul 2>&1
    if errorlevel 1 (
        set "CURTANA_HAS_ADB=0"
    ) else (
        set "CURTANA_HAS_ADB=1"
    )
)

if exist "%CURTANA_PLATFORM_TOOLS%\fastboot.exe" (
    set "CURTANA_FASTBOOT=%CURTANA_PLATFORM_TOOLS%\fastboot.exe"
    set "CURTANA_HAS_FASTBOOT=1"
) else (
    set "CURTANA_FASTBOOT=fastboot"
    where fastboot >nul 2>&1
    if errorlevel 1 (
        set "CURTANA_HAS_FASTBOOT=0"
    ) else (
        set "CURTANA_HAS_FASTBOOT=1"
    )
)

exit /b 0
