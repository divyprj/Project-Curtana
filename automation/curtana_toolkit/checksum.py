"""Checksum helpers for ROM, firmware, and recovery artifacts."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import hashlib
import re


SHA256_RE = re.compile(r"\b[a-fA-F0-9]{64}\b")


@dataclass(frozen=True)
class VerificationResult:
    """Result of a SHA256 verification operation."""

    path: Path
    expected: str
    actual: str

    @property
    def ok(self) -> bool:
        return self.expected.lower() == self.actual.lower()


def sha256_file(path: str | Path, chunk_size: int = 1024 * 1024) -> str:
    """Return SHA256 hex digest for a file using streaming reads."""

    file_path = Path(path)
    if not file_path.is_file():
        raise FileNotFoundError(f"file not found: {file_path}")

    digest = hashlib.sha256()
    with file_path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(chunk_size), b""):
            digest.update(chunk)
    return digest.hexdigest()


def read_expected_sha256(sidecar: str | Path) -> str:
    """Read the first SHA256-looking token from a sidecar checksum file."""

    sidecar_path = Path(sidecar)
    if not sidecar_path.is_file():
        raise FileNotFoundError(f"checksum file not found: {sidecar_path}")

    text = sidecar_path.read_text(encoding="utf-8", errors="replace")
    match = SHA256_RE.search(text)
    if not match:
        raise ValueError(f"no SHA256 digest found in {sidecar_path}")
    return match.group(0).lower()


def verify_sha256_sidecar(path: str | Path, sidecar: str | Path) -> VerificationResult:
    """Verify a file against a sidecar containing a SHA256 digest."""

    file_path = Path(path)
    expected = read_expected_sha256(sidecar)
    actual = sha256_file(file_path)
    return VerificationResult(path=file_path, expected=expected, actual=actual)

