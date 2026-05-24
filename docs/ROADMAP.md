# Roadmap

Project-Curtana grows in phases. The early project emphasizes safe Windows workflows and documentation; later phases add cross-platform automation and GUI support.

## v0.1 - Repository foundation

Status: active.

Goals:

- GitHub-ready repository structure.
- Production README and documentation set.
- Windows batch scripts for ADB, Fastboot, recovery, troubleshooting, and partition backup.
- Device profile config for Curtana/Miatoll.
- PowerShell diagnostics foundation.
- Python CLI foundation.
- Repository tests and GitHub Actions validation.

Exit criteria:

```text
[x] Scripts support --help.
[x] Documentation covers core flashing workflows.
[x] Tests validate required files and links.
[x] Safety model is documented.
```

## v0.2 - Diagnostics and manifests

Goals:

- Structured device detection output.
- Recovery image manager commands.
- SHA256 manifest verification.
- Sanitized diagnostic bundle generation.
- FastbootD detection helper.
- Better Windows driver reporting.

Planned commands:

```powershell
python -m curtana_toolkit.cli detect --json
python -m curtana_toolkit.cli diagnostics --sanitize
python -m curtana_toolkit.cli manifest verify firmware\manifest.json
```

## v0.3 - Guided flashing planner

Goals:

- Dry-run flashing plans.
- Package type classification.
- Recovery/Fastboot/FastbootD mode planner.
- Data-loss risk annotations.
- Step-by-step command execution with stop points.

Non-goals:

- Unattended flashing.
- EDL automation.
- Bypassing bootloader unlock.

## v0.4 - Linux parity

Goals:

- Linux shell scripts for ADB, Fastboot, recovery boot, and sideload.
- `udev` guidance and checks.
- Cross-platform diagnostics.
- Platform-tools version checks on Linux distributions.

## v0.5 - GUI prototype

Goals:

- GUI backed by Python planner.
- Device state dashboard.
- Package hash verification view.
- Guided recovery/Fastboot workflow.
- Log export.
- Explicit safety gates.

Design rule: the GUI must call shared backend logic rather than duplicating flashing code.

## v1.0 - Stable toolkit

Goals:

- Stable CLI/API contracts.
- Maintainer handbook.
- Tested workflows across representative Curtana states.
- Release artifacts with checksums.
- Complete support issue workflow.
- Documented upgrade policy.

## Long-term ideas

- ROM compatibility metadata registry.
- Recovery build registry with maintainer-provided checksums.
- Firmware base compatibility matrix.
- Structured bootloop triage assistant.
- Offline documentation bundle.
- Optional WebUSB diagnostics viewer for read-only states.

## Out of scope

- Bootloader unlock bypass.
- EDL flashing automation.
- Hosting proprietary ROMs or firmware.
- Circumventing device security controls.
- Supporting unrelated Xiaomi device families without maintainers and tests.
