# Firmware Workspace

Use this directory for local firmware packages, stock Fastboot ROMs, recovery ROMs, and checksum manifests while working on a device.

Do not commit proprietary firmware or ROM packages unless redistribution is explicitly allowed. Most MIUI firmware, modem, and vendor packages are redistribution-sensitive and should be kept local.

Recommended local organization:

```text
firmware/
  curtana/
    V14.0.4.0.SJWMIXM/
      firmware.zip
      firmware.zip.sha256
  stock/
    V14.0.3.0.SJWINXM/
      fastboot-rom.tgz
      fastboot-rom.tgz.sha256
```

Before flashing:

1. Confirm device codename and region.
2. Confirm Android base required by the ROM.
3. Verify SHA256.
4. Read rollback warnings in [docs/SECURITY_AND_FLASHING_SYSTEMS.md](../docs/SECURITY_AND_FLASHING_SYSTEMS.md).
