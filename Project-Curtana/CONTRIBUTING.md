# Contributing

Thanks for improving Project-Curtana. This repository is maintained as infrastructure for real Android flashing and recovery workflows, so contributions should be practical, testable, and safety-conscious.

Read the full contributor guide at [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md).

Minimum expectations:

- Use Conventional Commits.
- Keep scripts beginner-safe and reversible where possible.
- Document data-wiping or partition-writing behavior.
- Do not commit proprietary firmware, ROM packages, recovery images, or driver binaries unless redistribution is explicitly allowed.
- Run the validation workflow locally when possible:

```powershell
$env:PYTHONPATH = "$PWD\automation"
python -m pytest tests
```

