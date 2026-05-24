# Contributing Guide

Project-Curtana is maintained as Android flashing infrastructure. Contributions should improve repeatability, safety, clarity, or diagnostics for real Curtana workflows.

## Contribution principles

- Prefer read-only diagnostics before write actions.
- Add confirmation gates before destructive commands.
- Document the exact phone mode required by each command.
- Avoid unsupported device claims.
- Do not commit proprietary packages or redistributed binaries without clear permission.
- Keep beginner instructions accurate without hiding advanced risk.

## Development setup

```powershell
git clone https://github.com/Project-Curtana/Project-Curtana.git
cd Project-Curtana
$env:PYTHONPATH = "$PWD\automation"
python -m unittest discover -s tests -p "test_*.py"
```

Batch help checks:

```powershell
Get-ChildItem scripts -Recurse -Filter *.bat | ForEach-Object {
  cmd /c "`"$($_.FullName)`" --help"
  if ($LASTEXITCODE -ne 0) { throw "failed: $($_.FullName)" }
}
```

## Conventional commits

Use clear commit messages:

```text
feat: add fastbootd detection command
fix: handle unauthorized adb devices
docs: explain recovery data format risk
test: validate markdown links
chore: update issue labels
security: prevent unsafe partition target default
```

Types:

| Type | Use |
| --- | --- |
| `feat` | New user-facing capability. |
| `fix` | Bug fix. |
| `docs` | Documentation-only change. |
| `test` | Tests or validation. |
| `chore` | Maintenance with no user behavior change. |
| `security` | Safety or security-sensitive change. |
| `refactor` | Internal improvement without behavior change. |

## Branch strategy

Recommended model:

```text
main
  Stable releases and tagged versions.

develop
  Integration branch for the next minor release.

feature/<short-name>
  New scripts, docs, or automation.

fix/<short-name>
  Bug fixes.

security/<short-name>
  Private or carefully reviewed safety/security fixes.
```

Release branches can be used when maintaining older versions:

```text
release/0.1
release/0.2
```

## Pull request expectations

Each PR should include:

- Problem statement.
- Summary of changed behavior.
- Safety impact.
- Commands tested.
- Screenshots or logs when relevant and sanitized.
- Documentation updates for workflow changes.

For scripts:

- Support `--help`.
- Validate required tools.
- Validate required files.
- Check phone mode where practical.
- Use explicit confirmation for partition writes, wipes, sideloads, or backups requiring root.
- Return non-zero exit codes for failures.

For docs:

- State exact mode: Android, recovery, Fastboot, or FastbootD.
- Include rollback/data-loss warnings when relevant.
- Prefer decision trees over vague advice.
- Keep links relative and working.

For Python:

- Use standard library unless a dependency is justified.
- Keep device IO behind small functions that can be tested.
- Make dry-run behavior possible before adding automated flashing.

## Labels strategy

Recommended GitHub labels:

| Label | Purpose |
| --- | --- |
| `bug` | Reproducible failure. |
| `enhancement` | New feature or workflow improvement. |
| `documentation` | Docs-only work. |
| `support` | User help request. |
| `needs-triage` | Maintainer has not classified yet. |
| `adb` | ADB-specific issue. |
| `fastboot` | Bootloader Fastboot issue. |
| `fastbootd` | Userspace Fastboot issue. |
| `recovery` | OrangeFox/TWRP workflow. |
| `drivers` | Windows driver setup. |
| `firmware` | Firmware or stock restore. |
| `security` | Safety or vulnerability report. |
| `good-first-issue` | Small scoped contribution. |
| `blocked` | Waiting on logs, device access, or upstream information. |

## Milestone roadmap

Use milestones aligned with SemVer:

```text
v0.1 - Repository foundation and Windows workflows
v0.2 - Python diagnostics and checksum manifests
v0.3 - Guided flashing planner
v0.4 - Linux parity
v0.5 - GUI prototype
v1.0 - Stable toolkit release
```

## Release strategy

Release artifacts should include:

- Source archive.
- Checksums for release archive.
- Changelog.
- Compatibility notes.
- Known issues.
- Upgrade notes.

Do not attach third-party ROMs, firmware, recovery images, platform-tools, or proprietary drivers to releases unless redistribution rights are explicit.

## Review checklist

```text
[ ] Does this improve a real Curtana workflow?
[ ] Is the target phone mode explicit?
[ ] Are destructive actions gated?
[ ] Are logs and privacy considered?
[ ] Are docs updated?
[ ] Are tests updated?
[ ] Are links valid?
[ ] Does the change avoid unsupported device claims?
```

## Code of conduct

Be precise and respectful. Users asking for flashing help may be stressed because their phone is bootlooping. Ask for logs and facts, avoid blame, and give recovery paths that minimize additional risk.
