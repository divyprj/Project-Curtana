# Troubleshooting

This guide is organized by device state. Start with what the phone can currently boot, then follow the matching path.

## State map

```text
Can boot Android?
  -> ADB checks, logs, reboot to recovery/bootloader

Can boot recovery?
  -> sideload, logs, backups, clean flash, format data

Can boot Fastboot?
  -> recovery boot, unlock checks, stock restore

Can boot FastbootD?
  -> dynamic partition repair, stock script continuation

Cannot show any mode?
  -> battery, cable, key combos, possible EDL/service path
```

## ADB problems

### `adb devices` empty

Check:

- Phone is booted Android or recovery.
- USB debugging is enabled.
- Cable supports data.
- Correct driver is installed.
- ADB server is not stuck.

Commands:

```bat
scripts\adb\check_device.bat
adb kill-server
adb start-server
adb devices -l
```

Decision tree:

```text
No device listed
  -> change cable/port
  -> check Device Manager
  -> install Google USB driver
  -> restart ADB server
  -> test another PC if possible
```

### `unauthorized`

Fix:

```text
Unlock phone screen
  -> accept RSA prompt
  -> if no prompt, revoke USB debugging authorizations
  -> reconnect USB
```

If recovery shows unauthorized, recovery's ADB implementation may not support the same authorization flow. Use sideload mode or MTP/USB OTG.

### `offline`

Fix:

```text
adb kill-server
reconnect cable
toggle USB debugging
restart phone or recovery
```

Old platform-tools can also cause offline states.

## Fastboot problems

### `fastboot devices` empty

Likely driver issue.

```text
Phone on Fastboot screen
  -> Device Manager
  -> update driver
  -> Android Bootloader Interface
  -> retry fastboot devices
```

Run:

```bat
scripts\fastboot\verify_fastboot.bat
```

### `FAILED (remote: Flashing is not allowed in Lock State)`

Bootloader is locked. Unlocking requires Xiaomi's official unlock flow and wipes data.

Do not attempt random bypass methods.

### `FAILED (remote: partition not found)`

Possible causes:

- Wrong partition name.
- Wrong mode; dynamic partition may require FastbootD.
- Wrong package target.
- Device partition layout differs from the guide.

Action:

```text
Confirm command source
  -> confirm partition belongs to Fastboot or FastbootD
  -> verify package target
  -> inspect ROM/stock script
```

## FastbootD problems

### Device disappears after entering FastbootD

Install driver while the phone is on the FastbootD screen.

```bat
fastboot reboot fastboot
fastboot devices
```

See [FASTBOOTD_FIX.md](FASTBOOTD_FIX.md).

### Logical partition flash fails

Do not randomly delete partitions. Follow the package's flash script. If the layout is inconsistent, a clean stock Fastboot restore is often safer than manual dynamic partition surgery.

## Recovery problems

### Recovery cannot decrypt data

Possible causes:

- Recovery does not support current Android/FBE version.
- Data was encrypted by a ROM using incompatible metadata.
- Screen lock/password state is incompatible.
- Data partition is corrupted.

Options:

- Use ADB sideload.
- Use USB OTG.
- Boot a newer recovery.
- Format data only when the ROM path requires it and personal data is backed up.

### Recovery shows internal storage as 0 MB

Usually encryption or data filesystem issue.

Do not wipe random partitions. If switching ROMs, follow the clean flash path and format data when required.

### ZIP install fails with assert

The package detected a mismatch.

Common assert causes:

- Wrong device codename.
- Wrong firmware base.
- Wrong Android version.
- Incomplete/corrupt download.
- Recovery too old.

Verify SHA256 and package target.

## Bootloop problems

### Boot animation loop

First boot can be long. If it loops beyond expected time:

```text
Boot recovery
  -> capture logs
  -> verify ROM checksum
  -> verify firmware requirement
  -> confirm clean flash requirement
  -> reflash in correct order
```

### Reboots to recovery

Likely causes:

- No valid system installed.
- Data/encryption failure.
- ROM install failed.
- Slot or boot image mismatch.

Actions:

- Read recovery log.
- Reflash ROM.
- Format data if required.
- Restore stock if partition layout is damaged.

### Reboots to Fastboot

Likely causes:

- Broken boot image.
- vbmeta/verity mismatch.
- Failed ROM install.
- Incompatible kernel/root patch.

Actions:

```text
Boot recovery temporarily
  -> flash ROM again
  -> restore stock boot image if root patch caused failure
  -> verify firmware
```

## Firmware problems

Symptoms:

- No baseband.
- No SIM.
- Wi-Fi/Bluetooth broken.
- Camera broken.
- Random reboots.
- Touch issue after firmware change.

Fix path:

```text
Identify required firmware
  -> verify package target
  -> flash correct firmware from recovery if maintainer supports it
  -> if state is unknown, restore full stock package
```

Do not mix modem and bootloader pieces from random builds.

## Driver problems by symptom

| Symptom | Likely fix |
| --- | --- |
| ADB works, Fastboot empty | Install Android Bootloader Interface. |
| Fastboot works, FastbootD empty | Install driver while in FastbootD. |
| Device Manager shows warning icon | Update driver from `drivers\`. |
| Device appears as MTP only | Enable USB debugging and install ADB driver. |
| QDLoader 9008 appears unexpectedly | Device may be in EDL; do not flash random EDL packages. |

## Log collection

Recovery log:

```bat
adb pull /tmp/recovery.log logs\recovery.log
```

Logcat:

```bat
adb logcat -d > logs\logcat.txt
```

Fastboot variables:

```bat
fastboot getvar all 2> logs\fastboot-getvar-all.txt
```

Sanitize:

- Serial number.
- IMEI.
- Phone number.
- Account email.
- Local user paths.
- Personal filenames.

## Known-good recovery path

When confused, return to the simplest known-good state:

```text
Fastboot visible
  -> boot known-good OrangeFox image
  -> verify recovery ADB
  -> sideload verified ROM or restore stock
```

If Fastboot is not visible, troubleshoot battery, button combos, USB, and possible service modes before attempting any flashing.
