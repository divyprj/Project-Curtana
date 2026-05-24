"""Command line interface for Project-Curtana automation."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

from .checksum import sha256_file, verify_sha256_sidecar
from .config import repository_root, toolkit_paths
from .device import detect_adb, detect_fastboot
from .diagnostics import collect_diagnostics, write_diagnostics
from .recovery import scan_recovery_artifacts


def _print_json(data: object) -> None:
    print(json.dumps(data, indent=2, default=str))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="curtana-toolkit",
        description="Read-only automation helpers for Project-Curtana.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    sha = sub.add_parser("sha256", help="calculate SHA256 for a file")
    sha.add_argument("path", type=Path)

    verify = sub.add_parser("verify", help="verify a file against a SHA256 sidecar")
    verify.add_argument("path", type=Path)
    verify.add_argument("sidecar", type=Path)

    detect = sub.add_parser("detect", help="detect ADB or Fastboot device state")
    detect.add_argument("--mode", choices=["adb", "fastboot"], default="adb")
    detect.add_argument("--platform-tools", type=Path)
    detect.add_argument("--json", action="store_true", dest="as_json")

    rec = sub.add_parser("recovery-list", help="list local recovery artifacts with SHA256")
    rec.add_argument("--directory", type=Path)
    rec.add_argument("--json", action="store_true", dest="as_json")

    diag = sub.add_parser("diagnostics", help="collect read-only diagnostics")
    diag.add_argument("--platform-tools", type=Path)
    diag.add_argument("--output", type=Path)
    diag.add_argument("--json", action="store_true", dest="as_json")

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        if args.command == "sha256":
            print(sha256_file(args.path))
            return 0

        if args.command == "verify":
            result = verify_sha256_sidecar(args.path, args.sidecar)
            status = "OK" if result.ok else "FAIL"
            print(f"{status} {result.path}")
            print(f"expected: {result.expected}")
            print(f"actual:   {result.actual}")
            return 0 if result.ok else 1

        if args.command == "detect":
            state = detect_adb(args.platform_tools) if args.mode == "adb" else detect_fastboot(args.platform_tools)
            if args.as_json:
                _print_json(state.asdict())
            else:
                print(f"transport: {state.transport}")
                print(f"visible:   {state.visible}")
                if state.state:
                    print(f"state:     {state.state}")
                if state.product:
                    print(f"product:   {state.product}")
                if state.unlocked:
                    print(f"unlocked:  {state.unlocked}")
                if state.is_userspace:
                    print(f"userspace: {state.is_userspace}")
                if state.warning:
                    print(f"warning:   {state.warning}")
            return 0 if state.visible else 1

        if args.command == "recovery-list":
            if args.directory:
                directory = args.directory
            else:
                directory = toolkit_paths(repository_root())["recovery_images"]
            artifacts = scan_recovery_artifacts(directory)
            if args.as_json:
                _print_json([artifact.asdict() for artifact in artifacts])
            else:
                if not artifacts:
                    print(f"no recovery artifacts found in {directory}")
                for artifact in artifacts:
                    print(f"{artifact.kind:5} {artifact.size_bytes:12} {artifact.sha256}  {artifact.path}")
            return 0

        if args.command == "diagnostics":
            if args.output:
                output = write_diagnostics(args.output, args.platform_tools)
                print(f"wrote {output}")
            else:
                report = collect_diagnostics(args.platform_tools)
                if args.as_json:
                    _print_json(report)
                else:
                    _print_json(report)
            return 0

    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    parser.print_help()
    return 2


if __name__ == "__main__":
    raise SystemExit(main())

