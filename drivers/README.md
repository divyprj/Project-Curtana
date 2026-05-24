# Driver Workspace

Use this directory for local Windows USB driver packages.

Supported driver types:

- Google USB Driver for ADB.
- Android Bootloader Interface driver for Fastboot.
- Qualcomm USB drivers for diagnostics or service scenarios.

The installer script can extract ZIP files and install discovered `.inf` files:

```bat
scripts\troubleshooting\install_drivers.bat
```

Run the script from an Administrator Command Prompt. After installation, reconnect the phone and verify Device Manager shows the expected interface:

| Phone mode | Expected Windows interface |
| --- | --- |
| Android with USB debugging | Android Composite ADB Interface |
| Fastboot | Android Bootloader Interface |
| FastbootD | Android Bootloader Interface or compatible Android Fastboot interface |
| Qualcomm emergency mode | Qualcomm HS-USB QDLoader 9008 |

Do not use random driver repacks from untrusted sites. A bad USB driver can break detection across ADB, Fastboot, and FastbootD.
