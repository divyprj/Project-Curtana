"""Diagnostic report generation."""

from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
import json
import re

from .device import detect_adb, detect_fastboot, DeviceState


# Android serials are commonly long alphanumeric tokens and usually include
# digits. Avoid redacting ordinary words such as "platform" or "fastboot".
SERIAL_RE = re.compile(r"\b(?=[0-9A-Za-z]{8,}\b)(?=[0-9A-Za-z]*\d)[0-9A-Za-z]+\b")
EMAIL_RE = re.compile(r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b")


def redact_text(text: str) -> str:
    """Redact common identifiers from support text."""

    text = EMAIL_RE.sub("[email-redacted]", text)
    return SERIAL_RE.sub("[id-redacted]", text)


def redacted_state(state: DeviceState) -> dict:
    data = state.asdict()
    if data.get("serial"):
        data["serial"] = "[serial-redacted]"
    return data


def collect_diagnostics(platform_tools: str | Path | None = None) -> dict:
    """Collect read-only diagnostics from ADB and Fastboot."""

    reports: dict[str, dict | str] = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "project": "Project-Curtana",
    }

    for name, detector in {"adb": detect_adb, "fastboot": detect_fastboot}.items():
        try:
            reports[name] = redacted_state(detector(platform_tools))
        except Exception as exc:  # diagnostics should report partial failure
            reports[name] = {"visible": False, "warning": redact_text(str(exc))}
    return reports


def write_diagnostics(path: str | Path, platform_tools: str | Path | None = None) -> Path:
    output = Path(path)
    output.parent.mkdir(parents=True, exist_ok=True)
    report = collect_diagnostics(platform_tools)
    output.write_text(json.dumps(report, indent=2), encoding="utf-8")
    return output
