"""Read-only ADB and Fastboot device detection."""

from __future__ import annotations

from dataclasses import dataclass, asdict
from pathlib import Path
import shutil
import subprocess


@dataclass(frozen=True)
class CommandResult:
    command: list[str]
    returncode: int
    stdout: str
    stderr: str


@dataclass(frozen=True)
class DeviceState:
    transport: str
    visible: bool
    serial: str | None = None
    state: str | None = None
    product: str | None = None
    unlocked: str | None = None
    is_userspace: str | None = None
    warning: str | None = None

    def asdict(self) -> dict:
        return asdict(self)


def _tool_path(name: str, platform_tools: str | Path | None = None) -> str:
    if platform_tools:
        candidate = Path(platform_tools) / f"{name}.exe"
        if candidate.is_file():
            return str(candidate)
        candidate_no_ext = Path(platform_tools) / name
        if candidate_no_ext.is_file():
            return str(candidate_no_ext)
    found = shutil.which(name)
    if found:
        return found
    raise FileNotFoundError(f"{name} was not found in platform-tools or PATH")


def run_tool(command: list[str], timeout: int = 20) -> CommandResult:
    completed = subprocess.run(
        command,
        check=False,
        capture_output=True,
        text=True,
        timeout=timeout,
    )
    return CommandResult(
        command=command,
        returncode=completed.returncode,
        stdout=completed.stdout,
        stderr=completed.stderr,
    )


def detect_adb(platform_tools: str | Path | None = None) -> DeviceState:
    adb = _tool_path("adb", platform_tools)
    result = run_tool([adb, "devices", "-l"])
    if result.returncode != 0:
        return DeviceState("adb", False, warning=result.stderr.strip() or result.stdout.strip())

    lines = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    for line in lines[1:]:
        parts = line.split()
        if len(parts) >= 2:
            return DeviceState("adb", parts[1] == "device", serial=parts[0], state=parts[1])
    return DeviceState("adb", False, warning="no ADB device listed")


def _fastboot_getvar(fastboot: str, name: str) -> str | None:
    result = run_tool([fastboot, "getvar", name])
    combined = "\n".join([result.stdout, result.stderr])
    for line in combined.splitlines():
        if line.lower().startswith(f"{name.lower()}:"):
            return line.split(":", 1)[1].strip()
    return None


def detect_fastboot(platform_tools: str | Path | None = None) -> DeviceState:
    fastboot = _tool_path("fastboot", platform_tools)
    result = run_tool([fastboot, "devices"])
    if result.returncode != 0:
        return DeviceState("fastboot", False, warning=result.stderr.strip() or result.stdout.strip())

    for line in result.stdout.splitlines():
        parts = line.split()
        if parts:
            return DeviceState(
                transport="fastboot",
                visible=True,
                serial=parts[0],
                state=parts[1] if len(parts) > 1 else "fastboot",
                product=_fastboot_getvar(fastboot, "product"),
                unlocked=_fastboot_getvar(fastboot, "unlocked"),
                is_userspace=_fastboot_getvar(fastboot, "is-userspace"),
            )
    return DeviceState("fastboot", False, warning="no Fastboot device listed")

