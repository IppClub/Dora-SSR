#!/usr/bin/env python3
"""Import a Godot repository, export/install a game package, or preview it in Dora."""
from __future__ import annotations

import argparse
import json
import math
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import zipfile

from project_delivery import (ProjectError, archive_game, digest, export_game, inspect,
                              import_repository, install_game, prepare, run_command, write_json)
from verify_package import verify as verify_runtime


def clone(repository: str, output: Path, timeout: float) -> dict:
    if output.exists() or output.is_symlink():
        raise ProjectError("Clone into a new directory")
    output.parent.mkdir(parents=True, exist_ok=True)
    log = output.parent / (output.name + ".clone.log")
    run_command(["git", "clone", "--", repository, str(output)], log, timeout)
    commit = subprocess.check_output(["git", "-C", str(output), "rev-parse", "HEAD"], text=True).strip()
    return {"cloned": True, "repository": str(output.resolve()), "commit": commit}


def lua_string(value: str) -> str:
    equals = ""
    while "]" + equals + "]" in value:
        equals += "="
    return "[" + equals + "[" + value + "]" + equals + "]"


def require_ordinary_host(binary: Path) -> None:
    if not binary.is_file():
        raise ProjectError("Dora executable is missing")
    markers = (b"GODOT_NODE_TEST", b"GODOT_CAPABILITY_QUERY matches=")
    previous = b""
    with binary.open("rb") as file:
        while block := file.read(1024 * 1024):
            data = previous + block
            if any(marker in data for marker in markers):
                raise ProjectError("Use an ordinary Dora host, not an opt-in Godot test executable")
            previous = data[-64:]


def preview(args) -> dict:
    host_binary = args.app.resolve() / "Contents/MacOS/Dora" if args.app else args.binary.resolve()
    require_ordinary_host(host_binary)
    work = args.work_dir.absolute()
    if work.exists() or work.is_symlink():
        raise ProjectError("Preview needs a new work directory")
    remote = "://" in args.source or args.source.startswith("git@")
    source = Path(args.source).resolve() if not remote else None
    if source and source.is_dir() and work.resolve().is_relative_to(source):
        raise ProjectError("Preview work must be outside the input repository/game package")
    if not math.isfinite(args.duration) or args.duration < 0 or not 1 <= args.width <= 8192 or not 1 <= args.height <= 8192:
        raise ProjectError("Invalid duration or viewport dimensions")
    work.mkdir(parents=True)
    if remote:
        clone(args.source, work / "repository", args.timeout)
        source = work / "repository"
    if source.is_file() and zipfile.is_zipfile(source):
        with zipfile.ZipFile(source) as archive:
            game_archive = False
            if "game.json" in archive.namelist() and archive.getinfo("game.json").file_size <= 4 * 1024**2:
                try:
                    metadata = json.loads(archive.read("game.json"))
                    game_archive = isinstance(metadata, dict) and metadata.get("format") == "dora-godot-game"
                except (ValueError, UnicodeError):
                    pass
        if game_archive:
            info = install_game(source, work / "installed")
        else:
            import_repository(source, work / "repository")
            source = work / "repository"
            info = inspect(source, args.project)
    else:
        info = inspect(source, args.project)
    if info["kind"] == "project":
        result = prepare(source, work / "prepared", args.godot, args.project, args.timeout)
        project = result["project"]
    else:
        project = info["project"]
    host_platform = {"darwin": "macOS", "linux": "Linux", "win32": "Windows Desktop"}.get(sys.platform)
    if info["kind"] == "game" and info["platform"] != host_platform:
        raise ProjectError("Game package targets " + info["platform"] + "; export a pack for " + str(host_platform))
    runtime = args.runtime_package.resolve()
    verify_runtime(runtime)
    manifest = json.loads((runtime / "manifest.json").read_text(encoding="utf-8"))
    library = runtime / manifest["library"]
    if args.app:
        if sys.platform != "darwin":
            raise ProjectError("--app requires macOS; use --binary and --asset-source elsewhere")
        source_app = args.app.resolve()
        if not (source_app / "Contents/MacOS/Dora").is_file():
            raise ProjectError("Dora.app executable is missing")
        app = work / "Dora.app"
        copied = subprocess.run(["cp", "-cR", str(source_app), str(app)], capture_output=True)
        if copied.returncode:
            if app.exists():
                shutil.rmtree(app)  # Only this newly created, owned preview copy.
            shutil.copytree(source_app, app, symlinks=True)
        assets = app / "Contents/Resources"
        binary = app / "Contents/MacOS/Dora"
        command = [str(binary)]
    else:
        if not args.binary or not args.binary.is_file() or not args.asset_source or not args.asset_source.is_dir():
            raise ProjectError("Provide an existing Dora --binary and --asset-source")
        assets = work / "assets"
        shutil.copytree(args.asset_source.resolve(), assets)
        binary = args.binary.resolve()
        command = [str(binary), "--asset", str(assets)]
    (assets / "Script").mkdir(exist_ok=True)
    values = {"PROJECT": lua_string(project), "WIDTH": str(args.width), "HEIGHT": str(args.height),
              "BUFFERS": str(args.buffers), "DURATION": str(args.duration),
              "CAPTURE": lua_string(str(args.capture.resolve()) if args.capture else ""),
              "STATE": lua_string(str(work / "player.json")), "ERROR": lua_string(str(work / "player-error.txt"))}
    if args.capture:
        args.capture.parent.mkdir(parents=True, exist_ok=True)
    template = Path(__file__).with_name("project_player.lua").read_text(encoding="utf-8")
    startup = re.sub(r"@([A-Z_]+)@", lambda match: values[match[1]], template)
    (assets / "Script/init.lua").write_text(startup, encoding="utf-8")
    if args.app:
        subprocess.run(["codesign", "--force", "--deep", "--timestamp=none", "--sign", "-", str(app)],
                       capture_output=True, check=True)
        subprocess.run(["codesign", "--verify", "--deep", "--strict", str(app)],
                       capture_output=True, check=True)
    record = {"prepared": True, "command": command, "project": project,
              "host_sha256": digest(binary), "runtime_sha256": digest(library),
              "runtime_manifest_sha256": digest(runtime / "manifest.json"),
              "startup_sha256": digest(assets / "Script/init.lua"),
              "scope": "One game in an ordinary Dora host; does not implement in-process project switching"}
    write_json(work / "preview.json", record)
    if args.no_run:
        return record
    env = {k: v for k, v in os.environ.items() if not k.startswith(("DORA_GODOT_", "DORA_BUILD_"))}
    env["DORA_GODOT_LIBRARY"] = str(library)
    if manifest.get("graphics_backend") == "wgl":
        env["DORA_GODOT_WINDOWS_GL"] = "1"
    run_command(command, work / "run.log", args.duration + 90 if args.duration else None, env=env,
                cwd=binary.parent)
    text = (work / "run.log").read_text(encoding="utf-8", errors="replace")
    state = json.loads((work / "player.json").read_text()) if (work / "player.json").is_file() else {}
    if not state.get("ready") or state.get("failed") or (args.capture and not state.get("captured")) or "SCRIPT ERROR:" in text:
        raise ProjectError("Dora preview failed; see " + str(work / "run.log"))
    if state.get("state") != "closed":
        state.update(state="closed", reason="window_closed")
        write_json(work / "player.json", state)
    record.update(played=True, exit_code=0, player=state)
    write_json(work / "preview.json", record)
    return record


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    scan = commands.add_parser("inspect", help="Find a project or verify a data-only game/PCK")
    scan.add_argument("source", type=Path)
    scan.add_argument("--project", help="Project directory relative to a multi-project repository")
    git = commands.add_parser("clone")
    git.add_argument("repository")
    git.add_argument("--output", type=Path, required=True)
    git.add_argument("--timeout", type=float, default=300)
    archive_import = commands.add_parser("import", help="Import a source-repository ZIP without its caches/.git")
    archive_import.add_argument("source", type=Path)
    archive_import.add_argument("--output", type=Path, required=True)
    imported = commands.add_parser("prepare")
    exported = commands.add_parser("export")
    play = commands.add_parser("run")
    for command in [imported, exported, play]:
        command.add_argument("source", type=str if command is play else Path)
        command.add_argument("--project")
        command.add_argument("--godot", default=os.getenv("DORA_GODOT_EDITOR", "godot"))
        command.add_argument("--timeout", type=float, default=300)
    imported.add_argument("--output", type=Path, required=True)
    exported.add_argument("--output", type=Path, required=True)
    exported.add_argument("--work-dir", type=Path, required=True)
    exported.add_argument("--id", required=True)
    exported.add_argument("--version", default="0.1.0")
    exported.add_argument("--preset")
    from project_delivery import PLATFORMS
    exported.add_argument("--platform", choices=sorted(PLATFORMS))
    play.add_argument("--work-dir", type=Path, required=True)
    host = play.add_mutually_exclusive_group(required=True)
    host.add_argument("--app", type=Path)
    host.add_argument("--binary", type=Path)
    play.add_argument("--asset-source", type=Path)
    play.add_argument("--runtime-package", type=Path, required=True)
    play.add_argument("--width", type=int, default=640)
    play.add_argument("--height", type=int, default=360)
    play.add_argument("--buffers", type=int, choices=[2, 3, 4], default=3)
    play.add_argument("--duration", type=float, default=0, help="Seconds after ready; 0 runs until window close")
    play.add_argument("--capture", type=Path)
    play.add_argument("--no-run", action="store_true", help="Prepare the ordinary host without launching")
    archive = commands.add_parser("archive")
    archive.add_argument("source", type=Path)
    archive.add_argument("--output", type=Path, required=True)
    install = commands.add_parser("install")
    install.add_argument("source", type=Path)
    install.add_argument("--output", type=Path, required=True)
    install.add_argument("--max-bytes", type=int, default=4 * 1024**3)
    install.add_argument("--max-files", type=int, default=10000)
    args = parser.parse_args()
    try:
        if args.command == "inspect":
            result = inspect(args.source, args.project)
        elif args.command == "clone":
            result = clone(args.repository, args.output, args.timeout)
        elif args.command == "import":
            result = import_repository(args.source, args.output)
        elif args.command == "prepare":
            result = prepare(args.source, args.output, args.godot, args.project, args.timeout)
        elif args.command == "export":
            result = export_game(args.source, args.output, args.work_dir, args.godot, args.id,
                                 args.version, args.project, args.preset, args.platform, args.timeout)
        elif args.command == "archive":
            result = archive_game(args.source, args.output)
        elif args.command == "install":
            result = install_game(args.source, args.output, args.max_bytes, args.max_files)
        else:
            result = preview(args)
        print(json.dumps(result, indent=2, ensure_ascii=False))
        return 0
    except (ProjectError, OSError, subprocess.SubprocessError, zipfile.BadZipFile) as error:
        print(json.dumps({"ok": False, "error": str(error)}, ensure_ascii=False), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
