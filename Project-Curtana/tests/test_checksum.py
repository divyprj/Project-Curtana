from __future__ import annotations

from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from curtana_toolkit.checksum import sha256_file, verify_sha256_sidecar


class ChecksumTests(unittest.TestCase):
    def test_sha256_file(self) -> None:
        with TemporaryDirectory() as tmp:
            path = Path(tmp) / "artifact.bin"
            path.write_bytes(b"curtana")
            self.assertEqual(
                sha256_file(path),
                "d24d332a40fb2e13cc73d26d38ce49adbf9a53b91e4ee402cc505368d05c1015",
            )

    def test_verify_sidecar(self) -> None:
        with TemporaryDirectory() as tmp:
            path = Path(tmp) / "artifact.bin"
            path.write_bytes(b"curtana")
            sidecar = Path(tmp) / "artifact.bin.sha256"
            sidecar.write_text(f"{sha256_file(path)}  artifact.bin\n", encoding="utf-8")
            result = verify_sha256_sidecar(path, sidecar)
            self.assertTrue(result.ok)


if __name__ == "__main__":
    unittest.main()
