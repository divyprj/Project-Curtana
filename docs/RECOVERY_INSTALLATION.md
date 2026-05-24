# Recovery Installation

This guide covers OrangeFox/TWRP-style recovery workflows for Curtana.

Recovery is the operational center for many ROM installs: ZIP flashing, sideload, data formatting, backups, firmware packages, and repair scripts. A good recovery workflow starts with a temporary boot, not a blind flash.

## Recovery compatibility

Use a recovery build that explicitly supports one of:

- `curtana`
- `miatoll` with Curtana listed by the maintainer

Check the release notes for:

- Android base support.
- FBE/FBEv2 encryption support.
- Dynamic partition support.
- Touch support.
- Sideload support.
- Known issues with MIUI firmware versions.

Do not use a recovery image from another Xiaomi family because the screen, touch, fstab, encryption, or partition map may differ.

## Prepare the image

Place the recovery image at:

```text
recovery\orangefox\orangefox.img
```

or pass a full path:

```bat
scripts\recovery\boot_orangefox.bat C:\Android\orangefox.img
```

Verify checksum:

```powershell
$env:PYTHONPATH = "$PWD\automation"
python -m curtana_toolkit.cli sha256 recovery\orangefox\orangefox.img
```

Compare the output with the maintainer-provided checksum.

## Temporary boot first

Bootloader mode:

```bat
scripts\adb\reboot_bootloader.bat
```

Temporary boot:

```bat
scripts\recovery\boot_orangefox.bat
```

Why temporary boot first:

- It does not overwrite stock or existing recovery.
- It validates that Fastboot can load the image.
- It lets you check touch, screen, storage, and ADB behavior.
- It gives you a chance to stop before permanent changes.

## Inspect recovery after boot

In recovery, check:

- Touch input works.
- Battery level is safe.
- Internal storage mounts or decryption behavior is understood.
- ADB is visible:

```bat
adb devices
```

- Sideload can be started if storage is not readable.
- Recovery identifies the device as Curtana/Miatoll.

If recovery cannot decrypt data, that does not automatically mean it is broken. File-based encryption support depends on Android version, recovery build, and data state.

## Flash recovery permanently

After a successful temporary boot:

```bat
scripts\recovery\flash_recovery.bat
```

The script requires typing:

```text
FLASH
```

Manual equivalent:

```bat
fastboot flash recovery recovery\orangefox\orangefox.img
fastboot reboot recovery
```

Boot directly into recovery after flashing. Booting Android first may restore stock recovery on some stock configurations.

## Recovery survival

Some ROMs or stock systems overwrite recovery during boot. ROM maintainers may provide a recovery survival ZIP or instructions to reflash recovery after the ROM.

General pattern:

```text
Flash ROM
  -> flash recovery survival ZIP if required
  -> reboot recovery
  -> flash add-ons if required
  -> reboot system
```

Follow the ROM maintainer's order. Add-ons such as GApps or Magisk are order-sensitive.

## Sideload workflow

Start sideload in recovery, then on PC:

```bat
scripts\recovery\sideload_rom.bat C:\ROMs\rom.zip
```

The script prints SHA256 before sending the file.

Use sideload when:

- Internal storage is encrypted.
- Storage mount is unreliable.
- You want to avoid copying large ZIPs to the device.
- Recovery can enter ADB sideload mode.

## Data formatting

Recovery menus often include both wipe and format operations. They are not equivalent.

| Operation | Typical effect |
| --- | --- |
| Wipe cache/dalvik | Removes temporary runtime caches. |
| Wipe data | Clears app/user data in recovery-specific way. |
| Format data | Recreates the data filesystem and removes encryption metadata. |

Format data is destructive. It is often required when switching between encryption schemes, Android bases, or ROM families. It also removes internal storage.

Do not format data casually. Do it when:

- ROM instructions require clean flash.
- Recovery cannot handle previous encryption and the ROM path requires a clean start.
- Bootloop logs indicate data/encryption incompatibility.

## Backups

Recovery backups can be useful, but dynamic partition and encryption behavior varies by recovery build.

Recommended backups:

- Personal files to PC or cloud before flashing.
- Important partitions through recovery or ADB root when available.
- `boot`, `dtbo`, `recovery`, `vbmeta`, and `persist` when you know the backup method is reliable.

Project-Curtana includes:

```bat
scripts\automation\backup_partition.bat boot
```

This requires root access from Android or recovery.

## Recovery bootloop

If the phone always returns to recovery:

```text
Check ROM install log
  -> verify firmware base
  -> check whether format data was required
  -> check add-on order
  -> reflash ROM cleanly
  -> restore stock if partition layout is broken
```

If recovery itself loops or cannot boot:

```text
Bootloader Fastboot
  -> boot known-good recovery image temporarily
  -> if temporary boot works, flash recovery
  -> if temporary boot fails, verify image target and platform-tools
```

## OrangeFox notes

OrangeFox builds may include device-specific extras such as:

- OTA survival helpers.
- MIUI firmware/ROM install conveniences.
- File manager and terminal.
- Sideload and MTP support.
- Encryption handling improvements.

These features vary by build. Trust the recovery maintainer's release notes over generic instructions.

## Safety summary

- Boot before flashing.
- Verify checksums.
- Use Curtana/Miatoll builds only.
- Keep stock restore path available.
- Never relock bootloader after installing custom recovery or ROM.
- Keep logs when a flash fails.

