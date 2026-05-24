# Platform Tools

Place Android platform-tools binaries here for portable Windows operation:

```text
adb.exe
fastboot.exe
AdbWinApi.dll
AdbWinUsbApi.dll
```

Scripts first check this directory. If the files are not present, scripts fall back to tools available through the system `PATH`.

Keep platform-tools updated from the official Android SDK distribution. Old `fastboot.exe` builds frequently cause confusing failures with dynamic partitions and FastbootD.
