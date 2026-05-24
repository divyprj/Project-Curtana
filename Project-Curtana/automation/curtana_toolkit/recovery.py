"""Recovery image discovery helpers."""

from __future__ import annotations

from dataclasses import dataclass, asdict
from pathlib import Path

from .checksum import sha256_file


@dataclass(frozen=True)
class RecoveryArtifact:
    path: Path
    kind: str
    size_bytes: int
    sha256: str

    def asdict(self) -> dict:
        data = asdict(self)
        data["path"] = str(self.path)
        return data


def scan_recovery_artifacts(directory: str | Path) -> list[RecoveryArtifact]:
    """Scan a directory for recovery images or zips and return hashes."""

    root = Path(directory)
    if not root.exists():
        return []

    artifacts: list[RecoveryArtifact] = []
    for path in sorted(root.iterdir()):
        if not path.is_file():
            continue
        suffix = path.suffix.lower()
        if suffix not in {".img", ".zip"}:
            continue
        artifacts.append(
            RecoveryArtifact(
                path=path,
                kind="image" if suffix == ".img" else "zip",
                size_bytes=path.stat().st_size,
                sha256=sha256_file(path),
            )
        )
    return artifacts

