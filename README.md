# Project-Curtana

[![Repository Health](https://img.shields.io/badge/status-active-brightgreen)](docs/ROADMAP.md)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)
[![Device](https://img.shields.io/badge/device-Xiaomi%20Curtana-orange)](docs/ARCHITECTURE.md)
[![Windows Toolkit](https://img.shields.io/badge/windows-batch%20%7C%20powershell-0078d4)](scripts/README.md)
[![Safety First](https://img.shields.io/badge/flashing-safety%20first-critical)](docs/SECURITY_AND_FLASHING_SYSTEMS.md)

Professional Android recovery, flashing, troubleshooting, and automation infrastructure for Xiaomi Curtana devices.

Project-Curtana is a maintainer-grade toolkit for Redmi Note 9 Pro India and Redmi Note 9S variants in the Curtana/Miatoll family. It focuses on the work Android modders actually repeat: setting up drivers, verifying ADB and Fastboot, booting or flashing recovery, using OrangeFox/TWRP workflows, handling FastbootD, recovering from bootloops, checking ROM integrity, and documenting safe firmware practice.

This repository is not a ROM archive and not a random collection of ZIP files. It is an operational toolkit: scripts, documentation, configs, diagnostics, and automation foundations designed to be reviewed, extended, tested, and maintained like real infrastructure.

## Supported Device

Project-Curtana targets:

| Codename | Device family | Common names | Notes |
| --- | --- | --- | --- |
| `curtana` | `miatoll` | Redmi Note 9 Pro India, Redmi Note 9S | Qualcomm Snapdragon 720G device family with dynamic partition workflows on modern Android bases. |

### What "Curtana" Means

`curtana` is Xiaomi's Android device codename for specific Redmi Note 9 Pro / Redmi Note 9S variants. Many custom recoveries and ROMs are released for `miatoll`, a family umbrella covering related Xiaomi devices that share a platform. A ROM or recovery marked `miatoll` may support Curtana, but firmware, modem, regional vendor blobs, anti-rollback state, and recovery compatibility still matter.

The toolkit treats this distinction seriously:

- Curtana is the primary target.
- Miatoll compatibility is recognized when the tool or guide context allows it.
- Firmware and rollback guidance warns users before mixing regional or Android-base packages.

## Flashing Ecosystem Overview

Android flashing on Curtana involves several execution environments:

```text
Android userspace
  |
  | adb reboot bootloader
  v
Fastboot bootloader
  |        \
  |         \ fastboot reboot fastboot
  v          v
Recovery     FastbootD userspace fastboot
  |           |
  | adb       | dynamic partitions and super image operations
  v           v
ROM install, firmware install, backups, repair flows
```

- **ADB** runs while Android or recovery exposes an ADB daemon.
- **Fastboot** runs in the bootloader and can boot images, flash bootloader-visible partitions, and query unlock state.
- **FastbootD** is userspace fastboot, used for dynamic partition operations that the bootloader fastboot cannot safely perform.
- **Recovery** such as OrangeFox or TWRP performs ROM ZIP installs, sideload, backups, formatting, encryption handling, and repair operations.

Project-Curtana provides scripts and documentation for each layer so a user understands which state the phone must be in before running a command.

## Features

- Windows batch scripts for ADB/Fastboot checks, recovery booting, recovery flashing, sideloading, driver install, partition backup, and cleanup.
- OrangeFox/TWRP-oriented recovery workflows with explicit warnings for Curtana/Miatoll compatibility.
- Fastboot and FastbootD troubleshooting guides for driver, device state, dynamic partition, and bootloop issues.
- Firmware and stock restore documentation that explains region, Android base, anti-rollback, modem, and clean flash risk.
- Python automation foundation for future device detection, SHA256 verification, recovery image management, diagnostics, and GUI integration.
- PowerShell diagnostics module for Windows maintainers and support workflows.
- GitHub templates, Actions validation, contribution policy, security policy, changelog, and release strategy.
- Beginner-friendly instructions without hiding advanced technical details.

## Repository Structure

```text
Project-Curtana/
  .github/
    ISSUE_TEMPLATE/
    workflows/
    pull_request_template.md
  assets/
  automation/
    curtana_toolkit/
  configs/
  docs/
  drivers/
  firmware/
  logs/
  powershell/
  recovery/
    orangefox/
  screenshots/
  scripts/
    adb/
    automation/
    fastboot/
    lib/
    recovery/
    troubleshooting/
  tests/
  tools/
    platform-tools/
  README.md
```

Read [ARCHITECTURE.md](docs/ARCHITECTURE.md) for the system design and [scripts/README.md](scripts/README.md) for script usage.

## Installation

1. Clone the repository.

   ```powershell
   git clone https://github.com/Project-Curtana/Project-Curtana.git
   cd Project-Curtana
   ```

2. Install Android platform-tools.

   - Download platform-tools from the Android SDK site.
   - Extract `adb.exe`, `fastboot.exe`, `AdbWinApi.dll`, and `AdbWinUsbApi.dll` into [tools/platform-tools](tools/platform-tools/README.md).
   - Alternatively, add platform-tools to your system `PATH`.

3. Install USB drivers on Windows.

   - Put extracted Google USB or Qualcomm driver files under [drivers](drivers/README.md), or put driver ZIP files there and let the installer extract them.
   - Run Command Prompt as Administrator.

   ```bat
   scripts\troubleshooting\install_drivers.bat
   ```

4. Verify ADB.

   ```bat
   scripts\adb\check_device.bat
   ```

5. Reboot to Fastboot and verify bootloader communication.

   ```bat
   scripts\adb\reboot_bootloader.bat
   scripts\fastboot\verify_fastboot.bat
   ```

Full setup instructions are in [INSTALLATION.md](docs/INSTALLATION.md) and [DRIVER_SETUP.md](docs/DRIVER_SETUP.md).

## ADB and Fastboot Setup

ADB and Fastboot are different transport layers:

- Use **ADB** when Android or recovery is running and USB debugging or recovery ADB is enabled.
- Use **Fastboot** when the device is on the bootloader Fastboot screen.
- Use **FastbootD** when flashing or repairing dynamic logical partitions such as `system`, `product`, or `vendor` inside `super`.

Recommended validation order:

```bat
scripts\adb\check_device.bat
scripts\adb\reboot_bootloader.bat
scripts\fastboot\verify_fastboot.bat
scripts\fastboot\unlock_status_check.bat
```

See [FASTBOOT_GUIDE.md](docs/FASTBOOT_GUIDE.md) and [FASTBOOTD_FIX.md](docs/FASTBOOTD_FIX.md).

## OrangeFox Setup

OrangeFox is the recommended recovery workflow for many Curtana modding operations because it supports common MIUI/custom ROM installation patterns, ZIP flashing, backups, and repair tooling.

Safe first-run approach:

1. Download an OrangeFox build explicitly marked for `curtana` or `miatoll`.
2. Verify its checksum.
3. Place the recovery image at `recovery/orangefox/orangefox.img` or pass the image path to the script.
4. Boot the image temporarily first.

```bat
scripts\recovery\boot_orangefox.bat
```

Only flash recovery after the temporary boot works:

```bat
scripts\recovery\flash_recovery.bat
```

Read [RECOVERY_INSTALLATION.md](docs/RECOVERY_INSTALLATION.md) before flashing recovery permanently.

## ROM Flashing Workflow

A conservative custom ROM flow looks like this:

```text
1. Confirm exact device variant and bootloader unlock state.
2. Back up important data and critical partitions.
3. Verify required firmware base for the ROM.
4. Verify ROM SHA256 checksum.
5. Boot recovery.
6. Format data only when the ROM instructions require it.
7. Flash firmware, ROM, recovery survival ZIP, GApps, or Magisk in the order documented by the ROM maintainer.
8. Reboot and wait through the first boot.
9. Capture logs if boot fails.
```

For sideload:

```bat
scripts\recovery\sideload_rom.bat C:\ROMs\rom-for-miatoll.zip
```

The full guide is [CUSTOM_ROM_GUIDE.md](docs/CUSTOM_ROM_GUIDE.md). Stock restore is covered in [STOCK_ROM_RESTORE.md](docs/STOCK_ROM_RESTORE.md).

## FastbootD Explained

FastbootD is not the same as the bootloader Fastboot screen. It is a userspace fastboot mode started from Android recovery/boot userspace. Dynamic partition devices use it because logical partitions inside `super` can require Android userspace metadata support.

Use FastbootD when:

- A ROM or stock restore guide explicitly says `fastboot reboot fastboot`.
- `fastboot flash system`, `vendor`, `product`, or `system_ext` fails in bootloader Fastboot.
- You are repairing dynamic partition metadata or sparse logical images.

Do not randomly switch between Fastboot and FastbootD during a flash. Follow the package's flash script or maintainer guide. See [FASTBOOTD_FIX.md](docs/FASTBOOTD_FIX.md).

## Troubleshooting

Common failure paths:

| Symptom | Likely layer | First action |
| --- | --- | --- |
| `adb devices` empty | ADB, driver, authorization | Run [check_device.bat](scripts/adb/check_device.bat), approve RSA prompt, reinstall drivers. |
| `fastboot devices` empty | Fastboot driver | Run [verify_fastboot.bat](scripts/fastboot/verify_fastboot.bat), check Device Manager. |
| Recovery asks for password or cannot decrypt data | File-based encryption | Use recovery storage via sideload/USB OTG, or format data when the ROM path requires clean data. |
| ROM install fails with firmware assert | Firmware mismatch | Flash required firmware package for Curtana/Miatoll and correct Android base. |
| Bootloop after ROM flash | Firmware, data, recovery order, incompatible build | Boot recovery, capture logs, verify package target and clean flash requirements. |
| Fastboot cannot flash `system` | Wrong mode for dynamic partition | Reboot to FastbootD and retry only if the guide says so. |

Detailed decision trees live in [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## Warnings and Disclaimers

Flashing can permanently damage data and may hard-brick a device if critical partitions are flashed incorrectly. This project reduces avoidable mistakes, but it cannot make unsafe packages safe.

- Back up personal data before unlocking or formatting.
- Never flash firmware for a different device family.
- Never flash random `persist`, modem, bootloader, or EDL packages.
- Do not relock the bootloader while running non-stock software.
- Understand rollback protection before downgrading MIUI or firmware bases.
- Use EDL only when you understand authorization and board-level risk.

Read [SECURITY_AND_FLASHING_SYSTEMS.md](docs/SECURITY_AND_FLASHING_SYSTEMS.md) and [SECURITY.md](docs/SECURITY.md).

## Screenshots

Screenshots for supported workflows belong in [screenshots](screenshots/README.md). Recommended captures:

- ADB authorization success.
- Fastboot detection success.
- OrangeFox main screen on Curtana/Miatoll.
- FastbootD screen.
- Successful sideload log.
- Driver state in Windows Device Manager.

Do not include device IMEI, serial number, phone number, account identifiers, or personal files in screenshots.

## Automation Architecture

The automation layer is intentionally split:

```text
Batch scripts       Immediate Windows workflows for beginners
PowerShell module   Windows diagnostics and maintainer support
Python toolkit      Cross-platform device detection, checksums, manifests, and future GUI backend
Configs             Device profile and safety policy data
Tests               Repository contract and link validation
```

Current Python entry point:

```powershell
$env:PYTHONPATH = "$PWD\automation"
python -m curtana_toolkit.cli --help
python -m curtana_toolkit.cli sha256 firmware\rom.zip
```

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for the scaling plan.

## Roadmap

Project-Curtana is built in phases:

- **v0.1.x**: Windows scripts, documentation, driver workflows, repository standards.
- **v0.2.x**: Python diagnostics CLI, checksum manifests, recovery image registry.
- **v0.3.x**: Guided flashing workflow planner and structured log bundles.
- **v0.4.x**: Linux shell parity and cross-platform transport checks.
- **v0.5.x**: GUI flashing manager backed by the Python toolkit.
- **v1.0.0**: Stable public API, tested workflows, release artifacts, maintainer handbook.

The living roadmap is [ROADMAP.md](docs/ROADMAP.md).

## Versioning

Project-Curtana follows Semantic Versioning:

```text
MAJOR.MINOR.PATCH
```

- **MAJOR**: breaking CLI/script behavior, changed repository contracts, or unsupported workflow removals.
- **MINOR**: new scripts, new diagnostics, new recovery workflows, or new supported automation modules.
- **PATCH**: documentation corrections, safer validation, bug fixes, and test improvements.

Release notes are maintained in [CHANGELOG.md](CHANGELOG.md).

## Contributing

Contributions should be operationally useful, documented, and safe by default.

- Use Conventional Commits such as `feat: add fastbootd validator` or `docs: clarify firmware downgrade risk`.
- Keep scripts idempotent where possible.
- Add tests for repository structure, links, or automation behavior.
- Avoid bundling copyrighted firmware, ROMs, or proprietary tools.
- Document any workflow that can wipe data or alter partitions.

Start with [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md).

## GitHub Topics

Recommended repository topics:

```text
android xiaomi curtana miatoll redmi-note-9-pro redmi-note-9s recovery orangefox twrp fastboot fastbootd adb custom-rom android-modding android-tools
```

## Credits

Project-Curtana is designed for the Android modding community around Xiaomi Curtana and the Miatoll device family. It acknowledges the work of Android platform-tools maintainers, recovery maintainers, ROM maintainers, kernel developers, firmware archivists, driver maintainers, and users who provide logs and careful reports.

This repository does not claim ownership of Android, Xiaomi, Redmi, OrangeFox, TWRP, Qualcomm, or ROM project trademarks.

## License

Project-Curtana source, scripts, and documentation are licensed under the [Apache License 2.0](LICENSE), unless a file explicitly states otherwise.

Third-party binaries, firmware, ROM packages, drivers, and recovery images are not licensed by this repository and should not be redistributed unless their original license permits it.

## Project Philosophy

Good flashing infrastructure should make dangerous operations understandable, repeatable, and reviewable. Project-Curtana prefers explicit state checks, plain language warnings, reproducible scripts, documented recovery paths, and logs that help maintainers diagnose failures without guessing.

The goal is not to make users reckless. The goal is to make careful users more capable.
