# Changelog Policy

The root [CHANGELOG.md](../CHANGELOG.md) contains release notes. This document defines how maintainers should write them.

Project-Curtana follows Semantic Versioning:

```text
MAJOR.MINOR.PATCH
```

## Version rules

| Change | Version impact |
| --- | --- |
| Breaking script argument behavior | Major |
| Removing a documented workflow | Major |
| New script or automation module | Minor |
| New documentation guide | Minor |
| Safer validation around existing behavior | Patch |
| Typo or link fix | Patch |
| Security fix that changes unsafe behavior | Patch or minor depending on behavior |

## Changelog sections

Use these headings when relevant:

```text
Added
Changed
Deprecated
Removed
Fixed
Security
Documentation
```

## Entry style

Good:

```text
- Added FastbootD driver troubleshooting decision tree.
- Fixed ADB device parsing when an unauthorized device is connected.
- Security: added confirmation gate before recovery flashing.
```

Avoid:

```text
- Update files.
- Fix stuff.
- More docs.
```

## Release checklist

```text
[ ] Changelog updated.
[ ] README status and roadmap still accurate.
[ ] Tests pass.
[ ] Batch help output works.
[ ] Documentation links pass.
[ ] Release notes list workflow risk changes.
[ ] Release does not include proprietary binaries.
[ ] Git tag uses vMAJOR.MINOR.PATCH format.
```

## Tag format

```text
v0.1.0
v0.1.1
v0.2.0
```

## Pre-release format

```text
v0.2.0-alpha.1
v0.2.0-beta.1
v1.0.0-rc.1
```

Use pre-releases for GUI prototypes, automated flashing planners, and any workflow that needs broad testing before being recommended.
