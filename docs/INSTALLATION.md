# Installation

This guide installs Project-Curtana as a local Android flashing and diagnostics workspace for Xiaomi Curtana devices.

Project-Curtana is intentionally portable. The scripts can use platform-tools bundled under the repository or platform-tools already available in your system `PATH`.

## Requirements

| Requirement | Purpose |
| --- | --- |
| Windows 10 or Windows 11 | Primary supported script environment. |
| Android platform-tools | Provides `adb.exe` and `fastboot.exe`. |
| USB data cable | Charging-only cables will not work. |
| Unlocked bootloader | Required for custom recovery and custom ROM flashing. |
| Device-specific recovery | OrangeFox/TWRP build for `curtana` or supported `miatoll`. |
| Verified ROM/firmware packages | Prevents corrupt downloads and wrong-device flashes. |

Advanced users can also use the Python automation modules on Linux/macOS, but the current production scripts are Windows batch and PowerShell.

## Directory model

```text
Project-Curtana/
  tools/platform-tools/       adb.exe and fastboot.exe, optional but recommended
  drivers/                    local driver packages and extracted INF files
  recovery/orangefox/         local recovery images and recovery ZIPs
  firmware/                   local firmware, ROMs, and checksum files
  logs/                       diagnostics, backups, and generated reports
```

The repository does not redistribute Android SDK binaries, Xiaomi firmware, recovery images, ROM builds, or proprietary drivers. Those artifacts remain local inputs.

## Step 1: Clone or open the repository

```powershell
git clone https://github.com/Project-Curtana/Project-Curtana.git
cd Project-Curtana
```

If you are working from a downloaded ZIP, extract it to a short path such as:

```text
C:\Android\Project-Curtana
```

Avoid paths with special characters when doing low-level device work. Batch scripts support quoted paths, but vendor flashing tools and driver installers are often less tolerant.

## Step 2: Install platform-tools

Download Android platform-tools from the official Android SDK distribution and extract these files into [../tools/platform-tools](../tools/platform-tools/README.md):

```text
adb.exe
fastboot.exe
AdbWinApi.dll
AdbWinUsbApi.dll
```

Expected layout:

```text
Project-Curtana/
  tools/
    platform-tools/
      adb.exe
      fastboot.exe
      AdbWinApi.dll
      AdbWinUsbApi.dll
```

The scripts first use local platform-tools. If local files are missing, they try `adb` and `fastboot` from `PATH`.

Verify manually:

```bat
tools\platform-tools\adb.exe version
tools\platform-tools\fastboot.exe --version
```

## Step 3: Install drivers

Use [DRIVER_SETUP.md](DRIVER_SETUP.md) for the detailed driver path.

Quick path:

1. Put driver ZIP files or extracted driver folders under `drivers\`.
2. Open Command Prompt as Administrator.
3. Run:

```bat
scripts\troubleshooting\install_drivers.bat
```

Driver state matters because Windows uses different interfaces for Android, recovery, Fastboot, FastbootD, and Qualcomm emergency modes.

## Step 4: Enable USB debugging

On the phone:

1. Open **Settings**.
2. Open **About phone**.
3. Tap **MIUI version** or **Build number** until Developer options are enabled.
4. Open **Additional settings** -> **Developer options**.
5. Enable **USB debugging**.
6. Connect USB and approve the RSA fingerprint prompt.

Then run:

```bat
scripts\adb\check_device.bat
```

Expected result:

```text
[OK] Authorized ADB device detected.
```

If the device shows `unauthorized`, unlock the phone screen and approve the prompt. If no prompt appears, revoke USB debugging authorizations, reconnect, and try again.

## Step 5: Verify Fastboot

Reboot to bootloader:

```bat
scripts\adb\reboot_bootloader.bat
```

Check Fastboot:

```bat
scripts\fastboot\verify_fastboot.bat
```

Expected output includes a Fastboot device and bootloader variables such as `product`, `unlocked`, and sometimes `current-slot`.

Curtana devices may report `curtana` or `miatoll` depending on the bootloader/recovery context. Treat unexpected values as a reason to stop and inspect before flashing.

## Step 6: Check bootloader unlock state

```bat
scripts\fastboot\unlock_status_check.bat
```

Custom recovery, custom ROMs, modified boot images, and many repair operations require an unlocked bootloader.

Do not relock the bootloader while running custom recovery, custom ROM, Magisk-patched boot images, non-stock vbmeta state, or mismatched firmware. Relocking in that state can brick the device.

## Step 7: Add recovery image

Place a verified OrangeFox image here:

```text
recovery\orangefox\orangefox.img
```

Then temporary boot first:

```bat
scripts\recovery\boot_orangefox.bat
```

Temporary booting is safer than immediately flashing because it confirms:

- Fastboot can load the image.
- The image is compatible enough to boot.
- Touch, storage, and decryption behavior can be inspected.

Flash only after a successful temporary boot:

```bat
scripts\recovery\flash_recovery.bat
```

## Step 8: Prepare firmware and ROMs

Keep ROMs and firmware in `firmware\` or another local folder. Always verify checksums:

```powershell
$env:PYTHONPATH = "$PWD\automation"
python -m curtana_toolkit.cli sha256 firmware\rom.zip
```

If a ROM maintainer provides a `.sha256` file:

```powershell
$env:PYTHONPATH = "$PWD\automation"
python -m curtana_toolkit.cli verify firmware\rom.zip firmware\rom.zip.sha256
```

## Operational checklist

Before flashing:

- Device codename and family are known.
- Bootloader is unlocked.
- Battery is above 50 percent.
- USB cable is stable and data-capable.
- Drivers are installed for the mode you are using.
- Recovery and ROM are built for Curtana or supported Miatoll.
- SHA256 checksums match.
- Required firmware base is installed or ready to flash.
- Personal data is backed up.
- You have a known path back to stock.

## Troubleshooting during installation

```text
adb devices empty
  -> Check USB debugging, RSA prompt, cable, Google USB driver.

adb unauthorized
  -> Unlock phone, approve RSA prompt, revoke authorizations if needed.

fastboot devices empty
  -> Check Android Bootloader Interface driver in Device Manager.

fastboot works but flashing fails
  -> Confirm unlock state, correct mode, correct partition, and dynamic partition requirements.

recovery boots but storage is encrypted
  -> Use sideload/USB OTG or format data only when the ROM flow requires it.
```

## Next guides

- [DRIVER_SETUP.md](DRIVER_SETUP.md)
- [FASTBOOT_GUIDE.md](FASTBOOT_GUIDE.md)
- [RECOVERY_INSTALLATION.md](RECOVERY_INSTALLATION.md)
- [CUSTOM_ROM_GUIDE.md](CUSTOM_ROM_GUIDE.md)
- [SECURITY_AND_FLASHING_SYSTEMS.md](SECURITY_AND_FLASHING_SYSTEMS.md)
