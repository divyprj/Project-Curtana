# Script Catalog

Project-Curtana scripts are Windows batch entry points designed for cautious, beginner-friendly workflows. They all support `--help`.

## ADB

| Script | Purpose |
| --- | --- |
| [adb/check_device.bat](adb/check_device.bat) | Start ADB and verify an authorized device. |
| [adb/reboot_bootloader.bat](adb/reboot_bootloader.bat) | Reboot Android/recovery into Fastboot. |
| [adb/reboot_recovery.bat](adb/reboot_recovery.bat) | Reboot Android into recovery. |
| [adb/adb_shell.bat](adb/adb_shell.bat) | Open an interactive shell or run one shell command. |

## Fastboot

| Script | Purpose |
| --- | --- |
| [fastboot/verify_fastboot.bat](fastboot/verify_fastboot.bat) | Verify Fastboot device detection and print core variables. |
| [fastboot/unlock_status_check.bat](fastboot/unlock_status_check.bat) | Query bootloader unlock status. |

## Recovery

| Script | Purpose |
| --- | --- |
| [recovery/boot_orangefox.bat](recovery/boot_orangefox.bat) | Temporarily boot OrangeFox from Fastboot. |
| [recovery/flash_recovery.bat](recovery/flash_recovery.bat) | Flash a recovery image after explicit confirmation. |
| [recovery/sideload_rom.bat](recovery/sideload_rom.bat) | Print SHA256 and sideload a ROM ZIP through recovery. |

## Troubleshooting

| Script | Purpose |
| --- | --- |
| [troubleshooting/install_drivers.bat](troubleshooting/install_drivers.bat) | Extract and install Windows USB driver INF files. |
| [troubleshooting/clean_temp.bat](troubleshooting/clean_temp.bat) | Stop ADB and clean toolkit temporary files. |

## Automation

| Script | Purpose |
| --- | --- |
| [automation/backup_partition.bat](automation/backup_partition.bat) | Back up a named partition through ADB root/su. |

## Tool discovery

Scripts prefer local platform-tools under `tools\platform-tools`. If local tools are absent, they fall back to `PATH`.

```text
Project-Curtana\tools\platform-tools\adb.exe
Project-Curtana\tools\platform-tools\fastboot.exe
```

