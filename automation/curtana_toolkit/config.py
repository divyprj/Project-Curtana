"""Configuration loading for Project-Curtana."""

from __future__ import annotations

from pathlib import Path
import json


def repository_root(start: str | Path | None = None) -> Path:
    """Find the repository root by walking upward from *start*."""

    current = Path(start or Path.cwd()).resolve()
    if current.is_file():
        current = current.parent

    for candidate in (current, *current.parents):
        if (candidate / "configs" / "toolkit.json").is_file() and (candidate / "README.md").is_file():
            return candidate
    raise FileNotFoundError("could not locate Project-Curtana repository root")


def load_json_config(name: str, root: str | Path | None = None) -> dict:
    """Load a JSON config from the repository configs directory."""

    repo = repository_root(root)
    config_path = repo / "configs" / name
    if not config_path.is_file():
        raise FileNotFoundError(f"config not found: {config_path}")
    return json.loads(config_path.read_text(encoding="utf-8"))


def toolkit_paths(root: str | Path | None = None) -> dict[str, Path]:
    """Return configured repository paths resolved to absolute paths."""

    repo = repository_root(root)
    config = load_json_config("toolkit.json", repo)
    return {key: (repo / value).resolve() for key, value in config["paths"].items()}

