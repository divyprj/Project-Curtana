# OrangeFox Recovery Assets

Place locally downloaded OrangeFox files for Curtana/Miatoll here when running scripts.

Recommended local names:

```text
orangefox.img
OrangeFox-Rxx.x-miatoll.zip
```

The repository intentionally does not redistribute recovery images. Recovery builds are third-party artifacts with their own maintainers, release cadence, and licensing. Verify the source, device target, and SHA256 checksum before booting or flashing any recovery image.

Safe workflow:

```bat
scripts\recovery\boot_orangefox.bat recovery\orangefox\orangefox.img
```

Only flash after the temporary boot works:

```bat
scripts\recovery\flash_recovery.bat recovery\orangefox\orangefox.img
```
