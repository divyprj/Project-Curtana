# Custom ROM Guide

This guide describes a safe, maintainable workflow for installing custom ROMs on Curtana/Miatoll devices.

Every ROM has its own instructions. Treat this document as the engineering baseline and the ROM maintainer's instructions as the package-specific authority.

## Before you start

Confirm:

- Device is Curtana or a supported Miatoll variant.
- Bootloader is unlocked.
- Battery is above 50 percent.
- Platform-tools are current.
- Drivers work in ADB, Fastboot, recovery, and FastbootD if needed.
- Recovery image supports your Android base and encryption state.
- ROM package is intended for Curtana or Miatoll.
- Required firmware version is known.
- Personal data is backed up.

Check device state:

```bat
scripts\adb\check_device.bat
scripts\adb\reboot_bootloader.bat
scripts\fastboot\verify_fastboot.bat
scripts\fastboot\unlock_status_check.bat
```

## Understand package types

| Package | Installed from | Typical purpose |
| --- | --- | --- |
| Recovery ROM ZIP | OrangeFox/TWRP | Custom ROM install or MIUI recovery update. |
| Firmware ZIP | Recovery | Updates modem/vendor firmware blobs required by ROM. |
| Fastboot ROM TGZ | Bootloader/Fastboot/FastbootD | Full stock restore or deep repair. |
| Recovery IMG | Fastboot | Boot or flash custom recovery. |
| Boot IMG | Fastboot/recovery | Kernel/root repair or Magisk patch flow. |
| GApps ZIP | Recovery | Google apps for ROMs that do not include them. |
| Magisk ZIP/APK | Recovery/boot patch | Root solution; order-sensitive. |

Do not flash a package from the wrong environment. A recovery ZIP is not normally flashed with Fastboot. A Fastboot ROM is not normally installed from recovery.

## Firmware base

Custom ROM maintainers usually specify required firmware such as:

```text
Requires latest Android 12 firmware for miatoll.
Requires V14.x firmware.
Do not use Android 10 firmware.
```

Firmware includes low-level device components such as modem, DSP, Bluetooth, vendor blobs, and bootloader-adjacent partitions. Mismatched firmware can cause:

- No SIM or no network.
- Broken Wi-Fi/Bluetooth.
- Camera failure.
- Random reboots.
- Bootloop.
- Touch or display issues in recovery.

Do not downgrade firmware without understanding anti-rollback and regional compatibility.

## Verify downloads

Use SHA256:

```powershell
$env:PYTHONPATH = "$PWD\automation"
python -m curtana_toolkit.cli sha256 C:\ROMs\rom.zip
```

Verify with sidecar:

```powershell
$env:PYTHONPATH = "$PWD\automation"
python -m curtana_toolkit.cli verify C:\ROMs\rom.zip C:\ROMs\rom.zip.sha256
```

If the hash does not match, delete the package and download again. Never flash a package with a mismatched hash.

## Clean flash vs dirty flash

| Flash type | Meaning | Risk |
| --- | --- | --- |
| Clean flash | Format data or wipe data as instructed, then install ROM | Safer for major changes but destroys data. |
| Dirty flash | Install over existing ROM without data format | Convenient but can bootloop across incompatible builds. |

Clean flash is usually required when:

- Switching ROM families.
- Switching Android major versions.
- Moving between encrypted and differently encrypted data states.
- Coming from MIUI to AOSP-based ROM.
- Maintainer explicitly says clean flash.

Dirty flash may be acceptable for:

- Same ROM, same Android base, maintainer-approved incremental update.

## Recommended recovery workflow

```text
Prepare packages
  -> verify SHA256
  -> boot recovery
  -> copy packages or use sideload
  -> back up important partitions when possible
  -> wipe/format exactly as required
  -> flash firmware if required
  -> flash ROM
  -> flash recovery survival ZIP if required
  -> flash GApps if required by ROM
  -> flash Magisk only if desired and supported
  -> reboot recovery when instructions require it
  -> reboot system
```

## Sideload workflow

Start ADB sideload in OrangeFox/TWRP. On PC:

```bat
scripts\recovery\sideload_rom.bat C:\ROMs\rom.zip
```

For multiple packages, sideload one at a time and return to sideload mode between packages as recovery requires.

Example:

```text
Sideload firmware
  -> recovery returns to menu
  -> start sideload again
  -> sideload ROM
  -> start sideload again if GApps required
  -> sideload GApps
```

## Wipe and format guidance

Common recovery terms:

```text
Wipe cache/dalvik
  Low risk. Clears runtime caches.

Wipe data
  Removes app data but may preserve internal storage depending on recovery.

Format data
  Destructive. Removes encryption metadata and internal storage.
```

Format data is often required when coming from MIUI encryption to an AOSP ROM. Back up internal storage first.

## Add-on order

Typical AOSP flow:

```text
Firmware if required
ROM
Recovery survival if required
Reboot recovery if required
GApps if ROM does not include Google apps
Magisk if root is desired
Reboot system
```

Some ROMs include GApps or forbid flashing a separate GApps package. Some ROMs require a reboot to recovery before add-ons because the active slot or recovery ramdisk changes.

## First boot

First boot can take 5 to 15 minutes. Do not interrupt early unless there is a clear failure such as repeated reboot to recovery or bootloader.

Expected first boot behavior:

- Boot animation may run for several minutes.
- Device may get warm.
- Recovery logs are no longer visible after reboot.
- Setup wizard appears after data initialization.

If first boot exceeds the ROM maintainer's expected time, return to recovery and inspect logs.

## Bootloop recovery path

```text
Bootloop
  -> wait long enough for first boot
  -> boot recovery
  -> capture recovery log
  -> verify ROM target and checksum
  -> verify required firmware
  -> confirm format data requirement
  -> reflash cleanly
  -> if still looping, restore stock
```

Useful commands:

```bat
adb devices
adb pull /tmp/recovery.log logs\recovery.log
adb logcat -d > logs\logcat-after-bootloop.txt
```

Log availability depends on how far Android boots and what recovery exposes.

## Firmware mismatch symptoms

| Symptom | Possible mismatch |
| --- | --- |
| No SIM, no IMEI display, no mobile network | Modem/baseband mismatch or damaged modem state. |
| Wi-Fi or Bluetooth cannot enable | Firmware/vendor mismatch. |
| Camera crashes | Vendor blobs or firmware base mismatch. |
| Bootloop after ROM flash | Wrong firmware, dirty data, wrong package, add-on order. |
| Touch broken in recovery | Wrong recovery build or incompatible firmware/kernel state. |

Firmware mismatch is not fixed by repeatedly wiping cache. Confirm the required base.

## Magisk and root notes

Root changes boot integrity and can complicate support.

Before using Magisk:

- Boot the ROM once unrooted when possible.
- Keep a copy of the stock/current boot image.
- Understand OTA and recovery survival implications.
- Do not report ROM bugs with root modules enabled unless you can reproduce without them.

## After install validation

Check:

- Wi-Fi.
- Bluetooth.
- Mobile network.
- Camera.
- Fingerprint.
- GPS.
- Charging.
- Recovery access.
- Fastboot access.
- Encryption and screen lock.

Capture build info:

```bat
adb shell getprop ro.product.device
adb shell getprop ro.build.fingerprint
adb shell getprop ro.build.version.release
```

Remove serial/account details before sharing.

## When to restore stock

Restore stock when:

- Dynamic partition layout is badly broken.
- Firmware state is unknown.
- Device cannot boot any known-good ROM.
- Recovery installs fail consistently with verified packages.
- You need to relock bootloader safely.

Use [STOCK_ROM_RESTORE.md](STOCK_ROM_RESTORE.md).

