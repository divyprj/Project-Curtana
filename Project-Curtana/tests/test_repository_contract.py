from __future__ import annotations

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]


class RepositoryContractTests(unittest.TestCase):
    def test_required_directories_exist(self) -> None:
        required = [
            ".github/ISSUE_TEMPLATE",
            ".github/workflows",
            "docs",
            "scripts/adb",
            "scripts/fastboot",
            "scripts/recovery",
            "scripts/troubleshooting",
            "scripts/automation",
            "recovery/orangefox",
            "firmware",
            "drivers",
            "tools/platform-tools",
            "screenshots",
            "configs",
            "automation",
            "powershell",
            "logs",
            "assets",
            "tests",
        ]
        missing = [path for path in required if not (ROOT / path).is_dir()]
        self.assertEqual(missing, [])

    def test_required_documentation_exists(self) -> None:
        docs = [
            "INSTALLATION.md",
            "DRIVER_SETUP.md",
            "FASTBOOT_GUIDE.md",
            "FASTBOOTD_FIX.md",
            "RECOVERY_INSTALLATION.md",
            "CUSTOM_ROM_GUIDE.md",
            "STOCK_ROM_RESTORE.md",
            "TROUBLESHOOTING.md",
            "SECURITY_AND_FLASHING_SYSTEMS.md",
            "FAQ.md",
            "CONTRIBUTING.md",
            "CHANGELOG.md",
            "SECURITY.md",
            "ARCHITECTURE.md",
            "ROADMAP.md",
        ]
        missing = [doc for doc in docs if not (ROOT / "docs" / doc).is_file()]
        self.assertEqual(missing, [])

    def test_required_batch_scripts_exist_and_have_help(self) -> None:
        scripts = [
            "scripts/adb/check_device.bat",
            "scripts/fastboot/verify_fastboot.bat",
            "scripts/adb/reboot_recovery.bat",
            "scripts/adb/reboot_bootloader.bat",
            "scripts/recovery/boot_orangefox.bat",
            "scripts/recovery/flash_recovery.bat",
            "scripts/recovery/sideload_rom.bat",
            "scripts/troubleshooting/clean_temp.bat",
            "scripts/troubleshooting/install_drivers.bat",
            "scripts/fastboot/unlock_status_check.bat",
            "scripts/adb/adb_shell.bat",
            "scripts/automation/backup_partition.bat",
        ]
        for script in scripts:
            path = ROOT / script
            self.assertTrue(path.is_file(), script)
            text = path.read_text(encoding="utf-8", errors="ignore")
            self.assertIn("--help", text, script)
            self.assertRegex(text, r"(?i)errorlevel|exit /b", script)

    def test_markdown_links_resolve(self) -> None:
        link_re = re.compile(r"\[[^\]]+\]\((?!https?://|mailto:|#)([^)]+)\)")
        missing: list[str] = []
        for markdown in ROOT.rglob("*.md"):
            text = markdown.read_text(encoding="utf-8")
            for match in link_re.finditer(text):
                target = match.group(1).split("#", 1)[0]
                if not target or target.startswith("data:"):
                    continue
                target = target.replace("%20", " ")
                if not (markdown.parent / target).resolve().exists():
                    missing.append(f"{markdown.relative_to(ROOT)} -> {target}")
        self.assertEqual(missing, [])


if __name__ == "__main__":
    unittest.main()

