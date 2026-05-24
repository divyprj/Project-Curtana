# Architecture

Project-Curtana is structured as a flashing and diagnostics ecosystem, not a single script. The architecture separates beginner-facing workflows from reusable automation primitives so the project can grow toward cross-platform CLI and GUI tooling without rewriting the safety model.

## System overview

```text
User
  |
  +-- Batch scripts --------------------+
  |                                     |
  +-- PowerShell diagnostics ----------+|
  |                                    ||
  +-- Python CLI and modules ----------++--> Platform-tools
                                       ||      adb / fastboot
Configs and device profiles ----------+|
Docs and safety model -----------------+
Tests and CI --------------------------+
```

## Layer responsibilities

| Layer | Responsibility |
| --- | --- |
| `scripts/` | Immediate Windows workflows with clear messages and confirmation gates. |
| `powershell/` | Windows diagnostics, structured support bundles, maintainer automation. |
| `automation/curtana_toolkit/` | Cross-platform Python primitives for detection, hashing, recovery scanning, and future guided workflows. |
| `configs/` | Device profile data, safety defaults, path configuration. |
| `docs/` | Operational procedures and risk model. |
| `tests/` | Repository contract, link validation, and automation behavior checks. |

## Device detection system

Target design:

```text
TransportDetector
  -> ADBDetector
       adb devices -l
       adb shell getprop
  -> FastbootDetector
       fastboot devices
       fastboot getvar product
       fastboot getvar unlocked
       fastboot getvar is-userspace
  -> RecoveryDetector
       adb shell test recovery properties
       recovery log availability
```

Detection should produce structured state:

```json
{
  "transport": "fastboot",
  "serial": "redacted",
  "product": "curtana",
  "family": "miatoll",
  "unlocked": true,
  "is_userspace": false,
  "warnings": []
}
```

Design rules:

- Detection is read-only.
- Serial values should be redacted in support bundles by default.
- Unknown product should block automated flashing plans.
- Device profile matching should be explicit and auditable.

## SHA256 ROM verifier

Current module: `automation/curtana_toolkit/checksum.py`.

Responsibilities:

- Calculate SHA256 for large files using streaming reads.
- Verify `.sha256` and `.sha256sum` sidecar files.
- Return structured pass/fail results.
- Support future manifest files for ROM, firmware, recovery, and stock packages.

Future manifest records should store artifact name, lowercase SHA256 digest, supported codenames, Android base, package kind, source URL, and maintainer notes. The verifier should reject manifests with malformed hashes or unsupported device targets before any flashing plan is created.

## Recovery image manager

Responsibilities:

- Scan `recovery/orangefox` for `.img` and `.zip` files.
- Compute file hashes.
- Track source URL and maintainer notes in local metadata when provided.
- Warn when the image target is unknown.
- Prefer temporary boot workflow before flash workflow.

Future commands:

```powershell
python -m curtana_toolkit.cli recovery list
python -m curtana_toolkit.cli recovery hash orangefox.img
python -m curtana_toolkit.cli recovery plan-boot orangefox.img
```

## Automated flashing workflows

Automated flashing must be introduced carefully. The project will not jump from scripts to unattended flashing without a planner and dry-run model.

Target flow:

```text
Collect state
  -> identify device
  -> verify unlock
  -> verify package hashes
  -> check firmware requirements
  -> produce plan
  -> dry-run commands
  -> require explicit user confirmation
  -> execute one stage at a time
  -> log every command and result
```

The planner should emit:

- Required phone mode.
- Command list.
- Data loss risk.
- Partition write risk.
- Expected recovery points.
- Abort conditions.

## FastbootD repair utility

Target responsibilities:

- Detect whether the phone is in bootloader Fastboot or FastbootD.
- Check `is-userspace` when available.
- Detect driver disappearance after mode switch.
- Explain dynamic partition failures.
- Collect `getvar all` logs with serial redaction.
- Avoid destructive layout operations unless a trusted manifest requires them.

Non-goals:

- Random deletion of logical partitions.
- Generic `wipe-super` automation.
- EDL flashing.

## Cross-platform Linux support

Linux support will use shell scripts and the Python core.

Needed pieces:

```text
scripts-linux/
  adb/check-device.sh
  fastboot/verify-fastboot.sh
  recovery/boot-orangefox.sh
  recovery/sideload-rom.sh
```

Linux-specific checks:

- `udev` rules.
- User group permissions.
- `adb` server ownership.
- Distribution platform-tools age.

Python modules should stay platform-neutral so Linux shell scripts can share detection, hashing, and planning logic.

## PowerShell automation system

PowerShell fills the gap between simple batch scripts and Python.

Current direction:

- Tool discovery.
- Device diagnostics.
- Log bundle creation.
- Driver state support commands.
- Maintainer-friendly support scripts.

PowerShell output should be structured enough for issue templates:

```powershell
.\powershell\Invoke-CurtanaDiagnostics.ps1 -OutputDirectory logs
```

## GUI flashing manager

Future GUI should be a frontend over the Python planner, not a separate flashing implementation.

Design:

```text
GUI
  -> Python API
       -> detection
       -> checksum
       -> plan
       -> execute stage
       -> log
  -> adb/fastboot
```

GUI requirements:

- Always show current phone mode.
- Display package hash status.
- Show data-loss warnings before buttons become active.
- Require explicit typed confirmation for partition writes.
- Provide log export.
- Never hide command output from advanced users.

## Android diagnostics toolkit

Diagnostics should gather:

- ADB device state.
- Fastboot variables.
- Recovery log if available.
- Selected Android properties.
- Driver hints on Windows.
- Platform-tools version.
- Project-Curtana version.

Sanitization should happen before creating shareable bundles:

```text
serial -> [serial-redacted]
imei -> [imei-redacted]
email -> [email-redacted]
local user path -> [user-redacted]
```

## Scalability strategy

1. Keep user-facing scripts thin.
2. Move reusable logic into Python modules.
3. Keep all device-specific assumptions in `configs/device_profiles.json`.
4. Add tests before expanding automation.
5. Introduce dry-run planners before execution engines.
6. Treat destructive commands as policy-controlled actions.
7. Keep docs and scripts in sync through CI checks.

## Module structure

```text
automation/curtana_toolkit/
  __init__.py
  checksum.py
  cli.py
  config.py
  device.py
  diagnostics.py
  recovery.py
```

Future modules:

```text
flash_plan.py
fastbootd.py
manifests.py
sanitize.py
transport.py
gui_api.py
```

## Safety state machine

```text
Unknown
  -> Read-only detection
Detected
  -> Hash verification
Verified inputs
  -> Dry-run plan
Plan accepted
  -> Stage execution
Stage complete
  -> Validate next state
Failure
  -> Stop, log, suggest recovery
```

No automated workflow should skip directly from `Unknown` to `Stage execution`.
