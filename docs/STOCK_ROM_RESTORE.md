# Stock ROM Restore

Stock restore returns Curtana to an official MIUI/HyperOS-style firmware state using a verified package for the exact device and region.

Use stock restore when:

- Custom ROM install repeatedly bootloops.
- Dynamic partitions are inconsistent.
- Firmware state is unknown.
- You need to recover before selling or servicing the device.
- You want a clean baseline before another ROM.

## Package types

| Package | Extension | Installed from | Notes |
| --- | --- | --- | --- |
| Fastboot ROM | `.tgz` or `.tar` | Fastboot scripts / Mi Flash | Full restore package with images and flash scripts. |
| Recovery ROM | `.zip` | Stock recovery/custom recovery | OTA-style update package. |
| Firmware-only ZIP | `.zip` | Custom recovery | Partial firmware update used by custom ROM flows. |

For deep repair, use a Fastboot ROM for the exact variant.

## Region and device matching

Xiaomi build names encode important information:

```text
curtana_in_global_images_V14.0.3.0.SJWINXM_...
```

Example interpretation:

| Segment | Meaning |
| --- | --- |
| `curtana` | Device codename. |
| `in_global` | Regional channel, India global in this example. |
| `V14.0.3.0` | MIUI version. |
| `SJWINXM` | Android/region/build code. |
| `images` | Fastboot image package. |

Do not flash packages for another device family. Be cautious crossing regional firmware channels because modem, carrier, anti-rollback, and OTA behavior can differ.

## Anti-rollback

Some Xiaomi devices expose anti-rollback state through:

```bat
fastboot getvar anti
```

If anti-rollback is enforced, flashing a package with a lower rollback index can brick the device. Not all builds expose the value clearly, and community documentation can be incomplete.

Safe rule:

- Avoid downgrading bootloader or firmware bases unless you have verified device-specific rollback safety.
- Prefer same or newer official builds for stock restore.
- Do not mix random firmware partitions from different releases.

## Flash script choices

Official Fastboot ROMs commonly include scripts such as:

```text
flash_all.bat
flash_all_except_storage.bat
flash_all_lock.bat
```

Meaning:

| Script | Effect |
| --- | --- |
| `flash_all.bat` | Clean flash and wipes data. Usually safest for repair. |
| `flash_all_except_storage.bat` | Attempts to preserve internal storage. Higher risk when state is inconsistent. |
| `flash_all_lock.bat` | Flashes stock and relocks bootloader. Dangerous if package or region is wrong. |

Do not use `flash_all_lock.bat` unless:

- You are flashing a fully stock official package for the exact device and region.
- The device boots stock cleanly.
- You understand relock risk.

Relocking with custom partitions can brick.

## Restore workflow

```text
Download exact Fastboot ROM
  -> verify SHA256
  -> extract to a short path
  -> install drivers
  -> boot phone to Fastboot
  -> verify product and unlock state
  -> run official flash script or Mi Flash
  -> wait without disconnecting USB
  -> first boot may take several minutes
```

Use a short path:

```text
C:\Android\Stock\curtana_V14\
```

Avoid:

```text
C:\Users\Name\Downloads\very long folder name with spaces and parentheses\...
```

## Project-Curtana pre-checks

```bat
scripts\fastboot\verify_fastboot.bat
scripts\fastboot\unlock_status_check.bat
```

Verify package hash:

```powershell
$env:PYTHONPATH = "$PWD\automation"
python -m curtana_toolkit.cli sha256 C:\Android\Stock\curtana_fastboot_rom.tgz
```

## FastbootD in stock restore

Some restore scripts enter FastbootD for dynamic partitions:

```bat
fastboot reboot fastboot
```

Let the official script control mode transitions. If the script pauses or fails after entering FastbootD:

1. Keep the phone on the FastbootD screen.
2. Install the driver for that exact mode.
3. Re-run the failing command only when you understand the script state.

See [FASTBOOTD_FIX.md](FASTBOOTD_FIX.md).

## Mi Flash notes

Mi Flash is commonly used for Xiaomi Fastboot ROMs on Windows.

Safety settings:

- Prefer **clean all** for repair.
- Avoid **clean all and lock** unless you intentionally want to relock and the package is exact.
- Confirm the selected folder contains image files and flash scripts, not the parent folder above them.

Mi Flash logs can help identify driver or path failures. Save logs before closing the tool.

## Common restore failures

### `can not found file flash_all.bat`

Wrong folder selected or archive not fully extracted. Select the folder containing the script and `images\`.

### `waiting for device`

Fastboot driver issue. Reinstall Android Bootloader Interface while phone is in Fastboot mode.

### Flash fails after `fastboot reboot fastboot`

FastbootD driver issue. Install driver while phone is in FastbootD.

### Anti-rollback or rollback error

Stop. Do not force a downgrade. Download a newer package for the exact device/region.

### Bootloop after successful flash

First boot can be long. If it loops repeatedly:

- Boot recovery if available and wipe data.
- Re-run clean flash.
- Confirm package target.
- Check whether bootloader was relocked with wrong state.

## Data preservation warning

Trying to preserve data during repair often makes recovery slower. If the device is already bootlooping from incompatible data or encryption, preserving storage may keep the bootloop.

When the goal is a reliable stock baseline, use a clean flash and restore personal data from backups.

## After restore

Validate:

- Device boots setup wizard.
- SIM/network works.
- Wi-Fi/Bluetooth work.
- Camera opens.
- Bootloader state matches your intent.
- Recovery is stock if you plan to relock.

If you relocked, confirm the device boots fully before doing further modifications.
