# Security Policy

Project-Curtana handles flashing operations that can wipe user data, alter boot-critical partitions, expose private logs, and change the security posture of a phone. Security reports are treated seriously even when the issue is a script safety flaw rather than a remote exploit.

## Supported versions

| Version | Security support |
| --- | --- |
| 0.1.x | Supported for critical safety and security fixes |

## Report privately when possible

Report privately if an issue could:

- Flash the wrong partition.
- Bypass a confirmation gate.
- Run injected shell commands through a path or argument.
- Encourage unsafe bootloader relocking.
- Hide checksum failures.
- Leak serial, IMEI, account, or personal file data in logs.
- Install drivers or execute binaries from an unexpected location.
- Cause data loss through unclear defaults.

For public issues, remove personal identifiers and avoid posting exploit-ready command injection examples until maintainers have acknowledged the report.

## Security boundaries

Project-Curtana does not claim to secure:

- Third-party ROM packages.
- Third-party recovery images.
- Xiaomi bootloader unlock systems.
- EDL authorization systems.
- User-downloaded driver packages.
- Modified platform-tools binaries.

The project does aim to secure:

- Its scripts.
- Its automation code.
- Its default workflows.
- Its documentation advice.
- Its test and release process.

## Handling command arguments

Scripts and automation must treat paths and user input carefully:

- Quote file paths.
- Avoid shell concatenation in Python.
- Use lists with `subprocess.run`.
- Reject missing files before calling flashing tools.
- Require explicit confirmation for write actions.
- Avoid accepting arbitrary partition names for flash commands unless a denylist/allowlist is present.

## Log privacy policy

Logs submitted to issues should be sanitized.

Sensitive values:

- IMEI.
- Serial number.
- Phone number.
- Account email.
- Local Windows username.
- Personal file names.
- Unlock tokens.
- Device-specific calibration partitions.

Maintainers should ask users to redact logs rather than reposting sensitive content in replies.

## Unsafe workflow examples

These require correction if found in docs or scripts:

```bat
fastboot flashing lock
fastboot flash xbl random-xbl.elf
fastboot flash modem NON-HLOS.bin
fastboot wipe-super super_empty.img
```

Such commands are not always wrong, but they are high-risk and must be tied to a trusted exact-device stock restore flow with explicit warnings.

## Disclosure response

Maintainer response target:

| Severity | Target response |
| --- | --- |
| Critical wrong-partition or command injection risk | 48 hours |
| High data-loss or unsafe relock guidance | 72 hours |
| Medium log privacy or checksum bypass issue | 7 days |
| Low documentation ambiguity | Next patch release |

## Security release process

1. Reproduce privately.
2. Patch with the smallest safe change.
3. Add a regression test where possible.
4. Update docs and changelog.
5. Release a patch version.
6. Credit reporter if they want credit.
