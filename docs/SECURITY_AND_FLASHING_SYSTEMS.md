# Security and Flashing Systems

Android flashing is a security-sensitive operation. The same mechanisms that allow recovery, repair, and custom ROM development can also wipe data, weaken verified boot, expose logs, or hard-brick a device.

This document explains the safety model used by Project-Curtana.

## Core principle

```text
Read-only checks first.
Temporary boot before permanent flash.
Verify packages before installing.
Back up before destructive operations.
Stop when the device identity is unclear.
```

## Bootloader unlock risk

Unlocking the bootloader allows unsigned or non-stock images to boot. This is required for custom recovery and custom ROM work, but it changes the device trust model.

Effects:

- User data is wiped during the official unlock process.
- Verified Boot guarantees are weakened.
- Physical attackers with device access have more options.
- Some banking/DRM apps may refuse to run.
- Warranty and service behavior may change by region.

Do not unlock unless you accept these tradeoffs.

## Relocking risk

Relocking is more dangerous than unlocking when the software state is not stock.

Never relock while using:

- Custom ROM.
- Custom recovery.
- Magisk/root.
- Patched boot image.
- Modified vbmeta.
- Mismatched regional firmware.
- Any partition not matching a full official stock package.

Wrong relock state can brick the device at bootloader verification time.

## Anti-brick precautions

Before flashing:

- Confirm exact device codename.
- Confirm package target.
- Verify SHA256.
- Confirm bootloader unlock state.
- Keep battery above 50 percent.
- Use a reliable USB cable.
- Avoid USB hubs during flashing.
- Keep a stock restore package available.
- Read the full ROM/recovery release notes.

During flashing:

- Do not disconnect USB.
- Do not close flash tools mid-write.
- Do not run unrelated ADB/Fastboot commands.
- Do not interrupt first boot early.

After flashing:

- Validate baseband, Wi-Fi, Bluetooth, camera, fingerprint, and recovery access.
- Keep logs for failures.

## EDL mode warning

EDL, or Emergency Download Mode, is a Qualcomm low-level service mode. It can recover deeply bricked devices in some circumstances, but it is not a normal modding workflow.

Risks:

- Many Xiaomi EDL operations require authorized accounts.
- Firehose loaders are device-specific and sensitive.
- Wrong EDL packages can corrupt boot-critical partitions.
- Random EDL tools may include malware.
- Legal redistribution of service files can be unclear.

Project-Curtana does not automate EDL flashing. It documents the risk so users do not mistake EDL for a routine fix.

## Firmware mismatch risks

Firmware packages may include:

- Modem/baseband.
- DSP.
- Bluetooth firmware.
- Camera-related vendor pieces.
- Bootloader-adjacent firmware.
- TrustZone/keymaster components.
- Vendor boot or device tree pieces depending on package.

Mismatched firmware can cause:

- No network.
- Broken sensors.
- Bootloop.
- Broken recovery touch.
- Broken camera.
- Random resets.
- Failed encryption/decryption.

Use firmware recommended by the ROM maintainer. Do not mix partitions from multiple releases manually.

## Rollback protection

Rollback protection prevents booting older vulnerable firmware or bootloader states. On Xiaomi devices, rollback behavior varies by device and release.

Potential signal:

```bat
fastboot getvar anti
```

Safe approach:

- Avoid downgrading firmware or bootloader packages.
- Prefer current or newer official packages.
- Research device-specific anti-rollback state before downgrades.
- Stop immediately if a tool reports rollback failure.

## Recovery corruption

Recovery corruption can happen when:

- Wrong recovery image is flashed.
- USB disconnects during flash.
- Stock ROM restores stock recovery.
- A ROM's boot/recovery handling overwrites recovery.

Recovery path:

```text
Bootloader Fastboot still works
  -> fastboot boot known-good recovery image
  -> verify it boots
  -> flash recovery if needed
```

If Fastboot does not work, the issue is deeper than recovery.

## Partition backup

Useful partitions to consider backing up:

| Partition | Why it matters |
| --- | --- |
| `boot` | Kernel/ramdisk, root patch recovery. |
| `dtbo` | Device tree overlays. |
| `recovery` | Known-good recovery restore. |
| `vbmeta` | Verified Boot state. |
| `persist` | Calibration and device-specific data; handle carefully. |

Use:

```bat
scripts\automation\backup_partition.bat boot
```

The script requires root access. Backups should be stored outside the phone as well as in `logs\backups`.

Do not share `persist` or other device-unique partitions publicly.

## Bootloop recovery

Bootloop response:

```text
Identify last successful state
  -> boot recovery
  -> collect logs
  -> verify firmware and package target
  -> undo root/kernel/add-on if applicable
  -> clean flash if data incompatibility is likely
  -> restore stock if layout or firmware state is unknown
```

Avoid repeated random flashing. Every write changes the state and makes diagnosis harder.

## Fastboot and FastbootD risks

Fastboot is powerful because it writes partitions without Android-level guardrails. FastbootD is safer for dynamic partitions, but it can still destroy layout if used incorrectly.

Do not run high-risk commands unless the package requires them:

```bat
fastboot erase userdata
fastboot wipe-super
fastboot delete-logical-partition product
fastboot flash xbl xbl.elf
fastboot flashing lock
```

If a guide tells you to run such commands, verify that it is written for Curtana/Miatoll and the exact firmware base.

## Driver security

USB driver installers run with administrator privileges. Treat them like software packages, not harmless support files.

Driver safety checklist:

- Download from trusted sources.
- Prefer signed drivers.
- Avoid repacked installers from unknown mirrors.
- Scan archives.
- Use Device Manager to inspect driver provider.
- Remove known-bad drivers when they hijack Fastboot interfaces.

## Log privacy

Logs can include:

- Serial numbers.
- IMEI or modem identifiers.
- Account emails.
- File paths.
- App package names.
- Recovery mount details.

Before sharing:

```text
Search for serial
Search for IMEI
Search for email
Search for local username
Replace sensitive values with [redacted]
```

## Safety checklist

Print or copy this before a flash:

```text
[ ] Device is Curtana or confirmed Miatoll-supported variant.
[ ] Bootloader is unlocked.
[ ] Battery is above 50 percent.
[ ] Platform-tools are current.
[ ] Drivers work in required modes.
[ ] Recovery/ROM/firmware checksums match.
[ ] Firmware base matches ROM instructions.
[ ] Personal data is backed up.
[ ] Stock restore package is available.
[ ] I know whether this flow requires format data.
[ ] I will not relock bootloader unless fully stock.
```
