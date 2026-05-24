# Automation Toolkit

The Python automation toolkit provides cross-platform primitives for Project-Curtana.

Current commands:

```powershell
$env:PYTHONPATH = "$PWD\automation"
python -m curtana_toolkit.cli --help
python -m curtana_toolkit.cli sha256 firmware\rom.zip
python -m curtana_toolkit.cli verify firmware\rom.zip firmware\rom.zip.sha256
python -m curtana_toolkit.cli detect --mode adb
python -m curtana_toolkit.cli recovery-list
python -m curtana_toolkit.cli diagnostics
```

The toolkit intentionally starts with read-only operations and file verification. Future automated flashing will be implemented through dry-run plans and explicit confirmation gates.
