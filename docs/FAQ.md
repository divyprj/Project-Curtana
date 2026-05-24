# FAQ

## What device does Project-Curtana support?

Project-Curtana targets Xiaomi Curtana devices, commonly Redmi Note 9 Pro India and Redmi Note 9S variants, within the Miatoll family.

## Is Miatoll the same as Curtana?

No. `miatoll` is a family umbrella for related devices. `curtana` is the specific codename targeted by this project. Some recoveries and ROMs support the whole Miatoll family, but firmware and regional packages still need care.

## Can this unlock my bootloader?

No. Xiaomi bootloader unlocking requires Xiaomi's official unlock process. Project-Curtana can check unlock status, but it does not bypass or automate account-based unlocking.

## Can I use this without Windows?

The current production scripts are Windows batch and PowerShell. The Python automation toolkit is designed to become cross-platform and already uses only standard Python libraries for its current commands.

## Does the repository include ROMs or firmware?

No. It provides folders and workflows for local packages but does not redistribute proprietary ROMs, firmware, recovery builds, platform-tools, or drivers.

## Where do I put platform-tools?

Put these files under `tools\platform-tools\`:

```text
adb.exe
fastboot.exe
AdbWinApi.dll
AdbWinUsbApi.dll
```

The scripts also work if `adb` and `fastboot` are available in `PATH`.

## Where do I put OrangeFox?

Put the image here:

```text
recovery\orangefox\orangefox.img
```

Then test boot:

```bat
scripts\recovery\boot_orangefox.bat
```

## Should I boot recovery or flash recovery first?

Boot first. Temporary booting with `fastboot boot` confirms basic compatibility without writing the recovery partition.

## Why does recovery show encrypted storage?

Modern Android uses file-based encryption. Recovery must understand the encryption implementation and metadata. If it cannot decrypt, use sideload or USB OTG, or format data only when your ROM workflow requires it.

## What is FastbootD?

FastbootD is userspace fastboot. It is used for dynamic logical partitions inside `super`, such as `system`, `vendor`, `product`, and `system_ext`.

Enter it with:

```bat
fastboot reboot fastboot
```

## Why does Fastboot work but FastbootD does not?

Windows may bind a different driver when the phone enters FastbootD. Install the Android Bootloader Interface driver while the phone is on the FastbootD screen.

## Can I relock the bootloader after installing a ROM?

Do not relock while running custom software. Relock only after restoring a fully stock official package for the exact device and region and confirming it boots correctly.

## What does `flash_all_lock.bat` do?

It flashes stock firmware and locks the bootloader. It is dangerous if used with the wrong package or non-stock state. Use `clean all`/`flash_all.bat` for repair unless you explicitly intend to relock and understand the risk.

## My ROM bootloops. What should I do?

Use this order:

```text
Boot recovery
  -> collect recovery log
  -> verify ROM checksum
  -> verify firmware requirement
  -> confirm clean flash and format data requirement
  -> reflash in documented order
  -> restore stock if still failing
```

## Can I flash firmware from another region?

Avoid it unless the ROM maintainer explicitly recommends it and the device community has validated it. Region mismatches can affect modem, carrier behavior, and rollback safety.

## Why does `adb sideload` stop around 47 percent?

ADB sideload progress shown on the PC is not always linear. Some recoveries report transfer completion around a mid-range percentage and continue verification/install on the phone. Read the recovery screen for final status.

## Does Project-Curtana support EDL?

It documents EDL risks but does not automate EDL flashing. EDL is a service-level recovery path, often authorization-gated on Xiaomi devices, and can hard-brick devices if misused.

## How do I ask for help safely?

Open a flashing help issue and include:

- Current phone state.
- Exact device variant.
- Commands run.
- Sanitized output.
- ROM/recovery/firmware names.
- What changed immediately before failure.

Remove IMEI, serial numbers, account emails, and personal file names.
