# Driver Setup

Windows driver state is one of the most common causes of failed Android flashing. ADB, Fastboot, FastbootD, recovery ADB, and Qualcomm emergency modes can appear as different USB interfaces, even though the same phone and cable are used.

This guide configures drivers safely for Curtana workflows.

## Driver modes

| Phone state | Transport | Typical Windows interface |
| --- | --- | --- |
| Android booted with USB debugging | ADB | Android Composite ADB Interface |
| Custom recovery with ADB enabled | ADB | Android Composite ADB Interface |
| Bootloader screen | Fastboot | Android Bootloader Interface |
| FastbootD | Fastboot userspace | Android Bootloader Interface or compatible Fastboot interface |
| Qualcomm emergency download | EDL | Qualcomm HS-USB QDLoader 9008 |

Windows may install one interface correctly and fail another. For example, `adb devices` can work while `fastboot devices` is empty.

## Safe driver sources

Use trusted sources:

- Android SDK Google USB Driver.
- OEM-provided Xiaomi/Android USB drivers when available.
- Qualcomm driver packages from reputable maintainer or OEM sources for service scenarios.

Avoid driver repacks from untrusted sites. USB driver packages run with high privilege and can affect all Android device detection on the host.

## Repository driver layout

```text
drivers/
  google-usb-driver/
    android_winusb.inf
  qualcomm/
    qcser.inf
  driver-package.zip
```

ZIP files can be placed directly in `drivers\`; the installer script extracts them into `drivers\extracted\` and installs discovered `.inf` files.

## Install with Project-Curtana

Open Command Prompt as Administrator from the repository root:

```bat
scripts\troubleshooting\install_drivers.bat
```

The script:

1. Confirms Administrator rights.
2. Extracts driver ZIP files under `drivers\`.
3. Searches for `.inf` files.
4. Runs `pnputil /add-driver ... /subdirs /install`.
5. Reports installation failure instead of silently continuing.

## Manual installation path

Use this path when Windows picks the wrong interface.

1. Connect the phone in the target mode.
2. Open **Device Manager**.
3. Find the phone under **Android Device**, **Other devices**, **Portable Devices**, or **Universal Serial Bus devices**.
4. Right-click -> **Update driver**.
5. Choose **Browse my computer for drivers**.
6. Choose the extracted driver folder under `drivers\`.
7. Select a matching interface:

```text
Android Composite ADB Interface     for ADB
Android Bootloader Interface        for Fastboot/FastbootD
Qualcomm HS-USB QDLoader 9008       only for emergency/service workflows
```

## ADB authorization troubleshooting

`adb devices` output:

```text
List of devices attached
abc12345        unauthorized
```

Fix path:

```text
Unlock phone screen
  -> accept RSA prompt
  -> if prompt does not show, revoke USB debugging authorizations
  -> reconnect cable
  -> run scripts\adb\check_device.bat
```

Commands:

```bat
tools\platform-tools\adb.exe kill-server
tools\platform-tools\adb.exe start-server
tools\platform-tools\adb.exe devices -l
```

If the phone never prompts, switch USB port, cable, and driver.

## Fastboot driver troubleshooting

`fastboot devices` empty while phone shows the Fastboot logo:

```text
Phone Fastboot screen visible
  -> Device Manager shows unknown Android device
  -> install Android Bootloader Interface driver
  -> reconnect USB
  -> run scripts\fastboot\verify_fastboot.bat
```

Manual check:

```bat
tools\platform-tools\fastboot.exe devices
```

If Windows shows **Kedacom USB Device**, update it manually to **Android Bootloader Interface**. Some Windows setups bind Fastboot to an incompatible driver provider.

## FastbootD driver troubleshooting

FastbootD often looks similar to Fastboot from the PC side but is a different phone mode. It can appear after:

```bat
fastboot reboot fastboot
```

If bootloader Fastboot works but FastbootD does not:

1. Keep the phone on the FastbootD screen.
2. Open Device Manager.
3. Update the interface driver to Android Bootloader Interface.
4. Re-run:

```bat
fastboot devices
```

Do not assume a ROM flash failed because the package is bad until the driver state has been checked in the exact mode required by the package.

## Qualcomm EDL warning

EDL mode is a low-level emergency interface. On many Xiaomi devices, useful EDL flashing requires authorized accounts or service tools. Random EDL tools and patched firehose loaders can be unsafe, illegal to redistribute, or device-specific.

Use EDL only when:

- The device cannot enter recovery or Fastboot.
- You understand the service authorization requirements.
- You have a verified package for the exact device.
- You accept that mistakes can hard-brick the board.

Project-Curtana documents EDL risk but does not automate EDL flashing.

## Driver cleanup

When Windows is confused:

```text
Device Manager
  -> View -> Devices by connection
  -> uninstall incorrect Android/Fastboot device
  -> check "Delete the driver software" only when removing a known-bad package
  -> reconnect in target mode
  -> install correct driver
```

Advanced users can inspect installed drivers:

```powershell
pnputil /enum-drivers | findstr /i "android google qualcomm xiaomi"
```

## Validation matrix

Run these after setup:

```bat
scripts\adb\check_device.bat
scripts\adb\reboot_bootloader.bat
scripts\fastboot\verify_fastboot.bat
fastboot reboot fastboot
fastboot devices
```

If all four states work, the host is ready for most Curtana flashing workflows.

