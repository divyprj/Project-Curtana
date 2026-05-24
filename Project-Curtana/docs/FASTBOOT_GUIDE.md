# Fastboot Guide

Fastboot is the bootloader protocol used to query device state, boot temporary images, and flash bootloader-visible partitions.

On Curtana, Fastboot is essential for:

- Checking bootloader unlock state.
- Booting OrangeFox/TWRP temporarily.
- Flashing recovery.
- Recovering from some bootloops.
- Entering FastbootD for dynamic partition operations.
- Returning to stock with official Fastboot ROM scripts.

## Fastboot vs ADB vs recovery

```text
Android booted
  -> adb works
  -> fastboot does not work

Bootloader Fastboot screen
  -> fastboot works
  -> adb does not work

Recovery booted
  -> adb may work
  -> fastboot does not work unless recovery exposes a reboot path

FastbootD screen
  -> fastboot works
  -> used for userspace dynamic partitions
```

Run commands only in the mode expected by the guide you are following.

## Verify Fastboot

Boot to Fastboot:

```bat
scripts\adb\reboot_bootloader.bat
```

Verify:

```bat
scripts\fastboot\verify_fastboot.bat
```

Manual equivalent:

```bat
fastboot devices
fastboot getvar product
fastboot getvar unlocked
fastboot getvar current-slot
```

`fastboot getvar` often prints to stderr; that is normal.

## Device identity

Useful variables:

```bat
fastboot getvar product
fastboot getvar unlocked
fastboot getvar current-slot
fastboot getvar anti
```

Interpretation:

| Variable | Meaning |
| --- | --- |
| `product` | Bootloader-reported codename. Curtana may report `curtana` or `miatoll`. |
| `unlocked` | Whether bootloader is unlocked. Custom flashing requires `yes` or `true`. |
| `current-slot` | A/B slot if exposed. Curtana workflows can still involve slot-aware packages. |
| `anti` | Anti-rollback index when exposed. Downgrades require caution. |

If `product` is not expected, stop. Do not flash while guessing.

## Boot a recovery image temporarily

Temporary boot is the safest first recovery test:

```bat
scripts\recovery\boot_orangefox.bat recovery\orangefox\orangefox.img
```

Manual:

```bat
fastboot boot recovery\orangefox\orangefox.img
```

This loads the recovery image into memory. It does not write the recovery partition. Use it to confirm compatibility before flashing.

## Flash recovery

After temporary boot is confirmed:

```bat
scripts\recovery\flash_recovery.bat recovery\orangefox\orangefox.img
```

Manual:

```bat
fastboot flash recovery recovery\orangefox\orangefox.img
fastboot reboot recovery
```

Boot directly into recovery after flashing. Some stock systems restore stock recovery during normal boot.

## Unlock state

Check:

```bat
scripts\fastboot\unlock_status_check.bat
```

The script runs both:

```bat
fastboot getvar unlocked
fastboot oem device-info
```

Typical Xiaomi output includes:

```text
Device unlocked: true
Device critical unlocked: true
```

Exact wording can vary by bootloader version.

## Fastboot flashing risk model

Fastboot can write partitions with very little context. That makes it powerful and dangerous.

Low-risk read-only commands:

```bat
fastboot devices
fastboot getvar product
fastboot getvar unlocked
```

Medium-risk commands:

```bat
fastboot boot recovery.img
fastboot reboot
fastboot reboot recovery
fastboot reboot fastboot
```

High-risk commands:

```bat
fastboot flash recovery recovery.img
fastboot flash boot boot.img
fastboot erase userdata
fastboot wipe-super
```

Critical-risk commands:

```bat
fastboot flash xbl xbl.elf
fastboot flash abl abl.elf
fastboot flash modem NON-HLOS.bin
fastboot flashing lock
```

Do not flash bootloader, modem, or critical firmware partitions unless you are following a trusted stock restore package for the exact variant.

## FastbootD handoff

Enter FastbootD:

```bat
fastboot reboot fastboot
```

The device screen should change from the bootloader Fastboot screen to a userspace FastbootD screen. See [FASTBOOTD_FIX.md](FASTBOOTD_FIX.md) for the dedicated guide.

## Common failures

### `waiting for any device`

Likely causes:

- Wrong mode.
- Bad driver.
- Bad cable.
- USB hub instability.
- Old platform-tools.

Fix:

```text
Confirm phone is on Fastboot screen
  -> check Device Manager
  -> install Android Bootloader Interface driver
  -> try rear motherboard USB port
  -> update platform-tools
```

### `FAILED (remote: Flashing is not allowed in Lock State)`

The bootloader is locked. Unlocking requires Xiaomi's official unlock flow and wipes data.

Do not try to bypass this with random scripts. Bypass attempts can make the device unrecoverable.

### `FAILED (remote: partition not found)`

Likely causes:

- Wrong partition name.
- Trying to flash a dynamic logical partition in bootloader Fastboot instead of FastbootD.
- Package intended for another device.
- Recovery/ROM instructions not followed.

### `FAILED (remote: size too large)`

Likely causes:

- Image does not match partition.
- Sparse image expected in FastbootD.
- Wrong device build.
- Outdated Fastboot binary.

## Real-world examples

### Recovery first boot

```bat
scripts\fastboot\verify_fastboot.bat
scripts\recovery\boot_orangefox.bat C:\Android\orangefox.img
```

Expected: phone leaves Fastboot and boots OrangeFox.

### Recovery permanent install

```bat
scripts\recovery\flash_recovery.bat C:\Android\orangefox.img
```

Expected: script asks for `FLASH`, writes recovery, then attempts to reboot recovery.

### Move to FastbootD

```bat
fastboot reboot fastboot
fastboot devices
```

Expected: device appears in FastbootD and remains visible to `fastboot devices`.

## Logging

When asking for help, capture sanitized output:

```bat
fastboot devices
fastboot getvar all 2> logs\fastboot-getvar-all.txt
```

Remove serial numbers, IMEI, token values, and account identifiers before sharing.

