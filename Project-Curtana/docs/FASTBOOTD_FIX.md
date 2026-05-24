# FastbootD Fix Guide

FastbootD is userspace fastboot. It is entered from bootloader Fastboot but runs with Android userspace support, which allows safe operations on dynamic logical partitions.

Curtana/Miatoll devices using modern Android bases can involve dynamic partitions through the `super` partition. That is why a command may fail in bootloader Fastboot but work in FastbootD.

## Recognize the modes

```text
Bootloader Fastboot
  Screen: classic Fastboot logo
  Used for: boot recovery, flash recovery/boot/vbmeta, query unlock

FastbootD
  Screen: userspace fastboot/recovery-style screen
  Used for: logical partitions inside super, dynamic partition repair
```

Windows still uses `fastboot.exe` for both. The difference is on the phone.

## Enter FastbootD

From bootloader Fastboot:

```bat
fastboot reboot fastboot
```

Then verify:

```bat
fastboot devices
fastboot getvar is-userspace
```

Expected:

```text
is-userspace: yes
```

Some bootloader builds may not expose `is-userspace`. Use the device screen and package instructions as the primary source.

## Exit FastbootD

```bat
fastboot reboot bootloader
```

or:

```bat
fastboot reboot
```

Use `fastboot reboot bootloader` when you need to return to classic Fastboot for recovery booting or bootloader-visible partition work.

## When FastbootD is required

FastbootD is commonly required when flashing:

- `system`
- `system_ext`
- `product`
- `vendor`
- logical partitions inside `super`
- dynamic partition metadata repair operations

It may also be required by stock restore scripts that explicitly call:

```bat
fastboot reboot fastboot
```

Do not move a flash step into FastbootD unless the instructions or error clearly indicate it. Some partitions belong in bootloader Fastboot.

## Failure: FastbootD not detected on Windows

Symptom:

```text
fastboot reboot fastboot
phone changes screen
fastboot devices returns empty
```

Fix path:

```text
Keep phone on FastbootD screen
  -> open Device Manager
  -> find unknown Android/Fastboot device
  -> update driver
  -> choose Android Bootloader Interface
  -> re-run fastboot devices
```

Do not switch back to bootloader while installing the driver. Windows binds drivers per interface state.

## Failure: `is-userspace` remains empty

Possible causes:

- Old `fastboot.exe`.
- Device did not actually enter FastbootD.
- Recovery/boot image is damaged.
- USB driver switched incorrectly.

Fix:

1. Update platform-tools.
2. Return to bootloader:

   ```bat
   fastboot reboot bootloader
   ```

3. Re-enter FastbootD:

   ```bat
   fastboot reboot fastboot
   ```

4. Check driver in Device Manager.

## Failure: logical partition flash fails

Example:

```text
FAILED (remote: Partition not found)
```

Decision tree:

```text
Are you in bootloader Fastboot?
  yes -> if flashing system/product/vendor, enter FastbootD
  no
    -> confirm package target and partition name
    -> confirm dynamic partition metadata is intact
    -> update platform-tools
    -> inspect package flash script
```

Some ROM packages are recovery ZIPs and should not be manually decomposed and flashed with Fastboot. If a package is meant for recovery, use recovery.

## Failure: `Not enough space to resize partition`

This is a dynamic partition allocation issue. It can happen when a previous ROM changed logical partition layout or when a restore package expects a clean `super` state.

Options:

- Follow the stock ROM's official flash script for the exact device.
- Use FastbootD if the package requires it.
- Avoid random `fastboot delete-logical-partition` commands unless the package or maintainer specifies them.
- Return to stock with a clean flash when layout is badly inconsistent.

`fastboot wipe-super` is destructive and package-specific. Running it with the wrong `super_empty.img` can make recovery harder.

## Failure: device bootloops after FastbootD flash

Likely causes:

- Firmware base mismatch.
- Dirty flash across incompatible Android bases.
- Data encryption mismatch.
- Missing format data step.
- Wrong ROM target.
- vbmeta/verity state mismatch.

Recovery path:

```text
Boot recovery
  -> capture recovery log
  -> verify ROM and firmware target
  -> flash required firmware
  -> format data only if required
  -> reflash ROM cleanly
  -> if still failing, restore stock Fastboot ROM
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Technical note: dynamic partitions

Android dynamic partitions allow multiple logical partitions to share space inside a physical `super` partition. Instead of fixed-size `system`, `vendor`, and `product` partitions, metadata controls logical extents.

Bootloader Fastboot may not have enough userspace context to resize or map these logical partitions correctly. FastbootD runs with Android userspace components so it can manage dynamic partition metadata more safely.

Text diagram:

```text
Physical storage
  |
  +-- super
        |
        +-- metadata
        +-- system logical partition
        +-- vendor logical partition
        +-- product logical partition
        +-- system_ext logical partition
```

## Commands reference

```bat
fastboot reboot fastboot
fastboot getvar is-userspace
fastboot devices
fastboot reboot bootloader
fastboot reboot
```

Read-only inspection:

```bat
fastboot getvar all 2> logs\fastbootd-getvar-all.txt
```

Sanitize serial numbers before sharing logs.

