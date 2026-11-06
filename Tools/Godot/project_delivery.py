"""Prepare Godot repositories and seal data-only games for Dora players.

This module manages project inputs, not the lifetime of an embedded LibGodot.
All editor work happens in an owned copy; author repositories remain untouched.
"""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import signal
import struct
import subprocess
import tempfile
import zipfile


GODOT_VERSION = (4, 7)
GAME_FORMAT = "dora-godot-game"
PLATFORMS = {"macOS", "Linux", "Windows Desktop", "Android", "iOS", "Web"}
SKIP_DIRECTORIES = {".git", ".godot", ".svn", ".hg"}


class ProjectError(ValueError):
    pass


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def source_files(root: Path):
    for directory, dirs, files in os.walk(root, followlinks=False):
        dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRECTORIES)
        for name in dirs + files:
            path = Path(directory) / name
            if path.is_symlink():
                raise ProjectError("Project symlinks must be materialized before delivery: " + str(path))
        for name in sorted(files):
            if name not in {".DS_Store", ".git"}:
                if not (Path(directory) / name).is_file():
                    raise ProjectError("Project contains a non-regular file")
                yield Path(directory) / name


def fingerprint(root: Path) -> dict:
    return {p.relative_to(root).as_posix(): digest(p) for p in source_files(root)}


def find_project(source: Path, selection: str | None = None) -> Path:
    source = source.resolve()
    if source.is_file() and source.name == "project.godot":
        if selection:
            raise ProjectError("--project is only valid with a repository directory")
        return source.parent
    if not source.is_dir():
        raise ProjectError("Expected a project.godot file or repository directory")
    if selection:
        chosen = (source / selection).resolve()
        if not chosen.is_relative_to(source):
            raise ProjectError("Selected project escapes its repository")
        if chosen.name == "project.godot":
            chosen = chosen.parent
        if not (chosen / "project.godot").is_file():
            raise ProjectError("Selected directory has no project.godot")
        return chosen
    if (source / "project.godot").is_file():
        return source
    projects = []
    for directory, dirs, files in os.walk(source, followlinks=False):
        dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRECTORIES and
                         not (Path(directory) / d).is_symlink())
        if "project.godot" in files:
            projects.append(Path(directory))
            dirs[:] = []
        if len(projects) > 128:
            raise ProjectError("Too many projects; select one with --project")
    if len(projects) != 1:
        choices = [p.relative_to(source).as_posix() for p in projects]
        raise ProjectError("Select a project with --project; candidates: " + json.dumps(choices))
    return projects[0]


def config_strings(text: str) -> dict:
    """Read only scalar metadata; Godot remains the actual ConfigFile parser."""
    result, section = {}, ""
    for line in text.splitlines():
        match = re.fullmatch(r"\s*\[([^]]+)\]\s*", line)
        if match:
            section = match[1]
            continue
        match = re.fullmatch(r'\s*([^=;]+)\s*=\s*("(?:[^"\\]|\\.)*")\s*', line)
        if match:
            try:
                result[section + "/" + match[1].strip()] = json.loads(match[2])
            except json.JSONDecodeError:
                pass
    return result


def inspect_project(source: Path, selection: str | None = None) -> dict:
    project = find_project(source, selection)
    text = (project / "project.godot").read_text(encoding="utf-8-sig")
    if not re.search(r"(?m)^\s*config_version\s*=\s*5\s*$", text):
        raise ProjectError("This player accepts Godot 4 projects; convert Godot 3 projects first")
    metadata = config_strings(text)
    files = list(source_files(project))
    extensions = [p.relative_to(project).as_posix() for p in files if p.suffix == ".gdextension"]
    features = re.search(r'config/features\s*=\s*PackedStringArray\((.*?)\)', text, re.S)
    csharp = bool(features and '"C#"' in features[1])
    if not metadata.get("application/run/main_scene"):
        raise ProjectError("The project has no application/run/main_scene")
    git = None
    if shutil.which("git"):
        tracked = subprocess.run(["git", "-C", str(project), "ls-files", "--error-unmatch", "--", "project.godot"],
                                 capture_output=True, timeout=15)
        revision = subprocess.run(["git", "-C", str(project), "rev-parse", "HEAD"],
                                  capture_output=True, text=True, timeout=15)
        if tracked.returncode == 0 and revision.returncode == 0:
            top = subprocess.check_output(["git", "-C", str(project), "rev-parse", "--show-toplevel"],
                                          text=True, timeout=15).strip()
            relative = project.relative_to(Path(top).resolve()).as_posix()
            changed = subprocess.check_output(["git", "-C", top, "status", "--porcelain", "--", relative],
                                              timeout=15)
            git = {"revision": revision.stdout.strip(), "subdirectory": relative, "dirty": bool(changed.strip())}
    return {
        "kind": "project", "project": str(project),
        "title": metadata.get("application/config/name") or project.name,
        "main_scene": metadata["application/run/main_scene"],
        "rendering_method": metadata.get("rendering/renderer/rendering_method", "default"),
        "requires_csharp": csharp, "native_extensions": extensions,
        "import_cache_present": (project / ".godot/imported").is_dir(),
        "source_files": len(files), "git": git,
    }


def require_supported(info: dict) -> None:
    if info["requires_csharp"]:
        raise ProjectError("Godot C#/Mono is disabled in Dora; this project requires C#")
    if info["native_extensions"]:
        raise ProjectError("Native GDExtension delivery needs platform sidecars; unsupported in this data-only package: "
                           + ", ".join(info["native_extensions"]))


def run_command(command: list[str], log: Path, timeout: float | None, *, env=None, cwd=None) -> None:
    """Stop only our own editor/build process group if the job times out."""
    with log.open("w", encoding="utf-8") as output:
        process = subprocess.Popen(command, stdout=output, stderr=subprocess.STDOUT,
                                   start_new_session=os.name != "nt", env=env, cwd=cwd)
        try:
            code = process.wait(timeout=timeout)
        except (subprocess.TimeoutExpired, KeyboardInterrupt):
            if os.name == "nt":
                subprocess.run(["taskkill", "/PID", str(process.pid), "/T", "/F"],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                os.killpg(process.pid, signal.SIGKILL)
            process.wait()
            raise ProjectError("Process job interrupted or timed out; see " + str(log))
    if code:
        raise ProjectError(f"Process job exited {code}; see {log}")
    text = log.read_text(encoding="utf-8", errors="replace")
    text = re.sub(r"\x1b\[[0-9;]*m", "", text)
    if re.search(r"(?m)^\s*(?:SCRIPT ERROR:|ERROR:)", text):
        raise ProjectError("Editor reported an import/script/export error; see " + str(log))


def editor_identity(executable: str) -> dict:
    found = shutil.which(executable)
    path = Path(found or executable).resolve()
    if not path.is_file():
        raise ProjectError("Set --godot or DORA_GODOT_EDITOR to a Godot 4.7 editor executable")
    result = subprocess.run([str(path), "--version"], capture_output=True, text=True, timeout=30)
    match = re.match(r"^(\d+)\.(\d+)(?:\.\d+)?\.stable(?:\.|$)", result.stdout.strip())
    if result.returncode or not match or tuple(map(int, match.groups())) != GODOT_VERSION:
        raise ProjectError("The importer must be Godot 4.7 stable; found " + result.stdout.strip())
    return {"path": str(path), "version": result.stdout.strip(), "sha256": digest(path)}


def prepare(source: Path, output: Path, editor: str, selection: str | None = None,
            timeout: float = 300) -> dict:
    info = inspect_project(source, selection)
    require_supported(info)
    original = Path(info["project"])
    output = output.absolute()
    if output.exists() or output.is_symlink():
        raise ProjectError("Use a new preparation output directory: " + str(output))
    source_root = source.resolve() if source.is_dir() else original
    if output.resolve().is_relative_to(source_root):
        raise ProjectError("Preparation output must be outside the author project/repository")
    identity = editor_identity(editor)
    before = fingerprint(original)
    output.parent.mkdir(parents=True, exist_ok=True)
    # Keep failed editor logs for diagnosis; never replace an existing output.
    output.mkdir()
    project = output / "project"
    project.mkdir()
    for relative in before:
        target = project / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(original / relative, target)
    run_command([identity["path"], "--headless", "--path", str(project), "--editor", "--import"],
                output / "import.log", timeout)
    if fingerprint(original) != before:
        raise ProjectError("Author project changed during preparation; discard this preparation")
    receipt = {"format": "dora-godot-prepared-project", "version": 1,
               "project": "project", "source": info, "editor": identity,
               "source_files_sha256": before, "prepared_files_sha256": fingerprint(project)}
    write_json(output / "prepared.json", receipt)
    return {"prepared": True, "project": str(project), "receipt": str(output / "prepared.json"),
            "editor_version": identity["version"], "source_unchanged": True}


def inspect_pck(path: Path) -> dict:
    """Validate standalone, unencrypted v2/v3/v4 indexes from the pinned loader layout."""
    total = path.stat().st_size
    with path.open("rb") as file:
        def read(count):
            data = file.read(count)
            if len(data) != count:
                raise ProjectError("Truncated PCK")
            return data
        def u32():
            return struct.unpack("<I", read(4))[0]
        def u64():
            return struct.unpack("<Q", read(8))[0]
        if read(4) != b"GDPC":
            raise ProjectError("Expected a standalone Godot PCK")
        version, major, minor, patch, flags = [u32() for _ in range(5)]
        if version not in (2, 3, 4) or major != 4 or (major, minor) > GODOT_VERSION:
            raise ProjectError("PCK requires an unsupported Godot version")
        if flags & ~2:
            raise ProjectError("Encrypted/sparse/patch PCKs are not supported by this delivery format")
        base = u64()
        directory = u64() if version >= 3 else 96
        if directory > total - 4 or base > total:
            raise ProjectError("PCK offsets exceed the file")
        file.seek(directory)
        count = u32()
        if not 0 < count <= min(1_000_000, total // 40):
            raise ProjectError("Invalid PCK file count")
        names = set()
        for _ in range(count):
            length = u32()
            if not 0 < length <= 65536:
                raise ProjectError("Invalid PCK path length")
            try:
                name = read(length).rstrip(b"\0").decode("utf-8").removeprefix("res://")
            except UnicodeDecodeError as error:
                raise ProjectError("Invalid UTF-8 PCK path") from error
            relative = PurePosixPath(name)
            if (relative.is_absolute() or ".." in relative.parts or "\\" in name or ":" in name or "\0" in name
                    or str(relative) != name or not name or name in names):
                raise ProjectError("Unsafe or duplicate PCK resource path")
            offset, size = u64(), u64()
            read(16)
            entry_flags = u32()
            if entry_flags or base + offset + size > total:
                raise ProjectError("Unsupported encrypted/patch entry or invalid PCK resource extent")
            names.add(name)
        if not {"project.binary", "project.godot"}.intersection(names):
            raise ProjectError("PCK contains no project configuration")
        if any(n.endswith((".gdextension", ".cs", ".csproj")) for n in names):
            raise ProjectError("This data-only player package does not include C# or native extension sidecars")
    return {"kind": "pck", "project": str(path.resolve()), "pack_version": version,
            "godot_version": f"{major}.{minor}.{patch}", "resource_count": count,
            "sha256": digest(path), "bytes": total}


def verify_game(package: Path) -> dict:
    package = package.resolve()
    if (package / "game.json").is_symlink():
        raise ProjectError("Game manifests must be regular files")
    if (package / "game.json").stat().st_size > 4 * 1024**2:
        raise ProjectError("Game manifest exceeds the metadata size limit")
    manifest = json.loads((package / "game.json").read_text(encoding="utf-8"))
    if not isinstance(manifest, dict) or manifest.get("format") != GAME_FORMAT or manifest.get("format_version") != 1:
        raise ProjectError("Unsupported game package format")
    if not all(isinstance(manifest.get(k), str) and manifest[k] for k in ("title", "version")):
        raise ProjectError("Game title/version metadata is missing")
    if not isinstance(manifest.get("id"), str) or not re.fullmatch(r"[a-z0-9][a-z0-9._-]{0,127}", manifest["id"]):
        raise ProjectError("Invalid game ID")
    runtime = manifest.get("runtime", {})
    if runtime not in ({"godot": "4.6", "mono": False}, {"godot": "4.7", "mono": False}):
        raise ProjectError("Game requires an unsupported runtime")
    if manifest.get("platform") not in PLATFORMS:
        raise ProjectError("Invalid game target platform")
    artifacts = manifest.get("artifacts")
    if not isinstance(artifacts, dict) or "game.pck" not in artifacts or manifest.get("entry") != "game.pck":
        raise ProjectError("Game PCK inventory is missing")
    for name, item in artifacts.items():
        if not isinstance(name, str):
            raise ProjectError("Game artifact names must be strings")
        relative = PurePosixPath(name)
        if (relative.is_absolute() or ".." in relative.parts or "\\" in name or ":" in name or "\0" in name
                or str(relative) != name or name == "game.json"):
            raise ProjectError("Unsafe game artifact path")
        file = package / name
        if (not file.is_file() or file.is_symlink() or not file.resolve().is_relative_to(package)
                or not isinstance(item, dict) or item.get("bytes") != file.stat().st_size
                or item.get("sha256") != digest(file)):
            raise ProjectError("Game artifact missing, unsafe or changed: " + name)
    actual = {p.relative_to(package).as_posix() for p in package.rglob("*") if p.is_file() and p != package / "game.json"}
    if actual != set(artifacts):
        raise ProjectError("Game artifact inventory differs")
    licenses = manifest.get("licenses", [])
    if not isinstance(licenses, list) or not all(isinstance(n, str) for n in licenses):
        raise ProjectError("Invalid game license inventory")
    for name in licenses:
        if name not in artifacts:
            raise ProjectError("Game license inventory is incomplete")
    pack = inspect_pck(package / "game.pck")
    return {"kind": "game", "verified": True, "project": pack["project"],
            "id": manifest["id"], "title": manifest["title"], "platform": manifest["platform"],
            "manifest_sha256": digest(package / "game.json"), "pack": pack}


def inspect(source: Path, selection: str | None = None) -> dict:
    source = source.resolve()
    if source.is_dir() and (selection or (source / "project.godot").is_file()):
        return inspect_project(source, selection)
    if source.is_file() and source.name == "game.json":
        return verify_game(source.parent)
    if source.is_dir() and (source / "game.json").is_file():
        path = source / "game.json"
        if path.stat().st_size <= 4 * 1024**2:
            try:
                metadata = json.loads(path.read_text(encoding="utf-8"))
            except (ValueError, UnicodeError):
                metadata = None
            if isinstance(metadata, dict) and metadata.get("format") == GAME_FORMAT:
                return verify_game(source)
    if source.is_file() and source.suffix.lower() == ".pck":
        return inspect_pck(source)
    return inspect_project(source, selection)


def presets(project: Path) -> list[dict]:
    path = project / "export_presets.cfg"
    if not path.is_file():
        return []
    text = path.read_text(encoding="utf-8-sig")
    values = config_strings(text)
    return [{"name": values[key], "platform": values.get(key.rsplit("/", 1)[0] + "/platform")}
            for key in values if re.fullmatch(r"preset\.\d+/name", key)]


def export_game(source: Path, output: Path, work: Path, editor: str, game_id: str,
                version: str = "0.1.0", selection: str | None = None, preset: str | None = None,
                platform: str | None = None, timeout: float = 300) -> dict:
    if not re.fullmatch(r"[a-z0-9][a-z0-9._-]{0,127}", game_id):
        raise ProjectError("Use a stable lowercase game ID with letters, numbers, dots or dashes")
    if output.exists() or output.is_symlink():
        raise ProjectError("Use a new game package output directory")
    author_project = find_project(source, selection)
    source_root = source.resolve() if source.is_dir() else author_project
    if output.resolve().is_relative_to(source_root):
        raise ProjectError("Game package output must be outside the author project/repository")
    if output.resolve().is_relative_to(work.resolve()) or work.resolve().is_relative_to(output.resolve()):
        raise ProjectError("Game package and build work directories must not overlap")
    prepared = prepare(source, work, editor, selection, timeout)
    project = Path(prepared["project"])
    available = presets(project)
    if preset:
        matches = [p for p in available if p["name"] == preset]
    elif len(available) == 1:
        matches = available
    elif not available and platform in PLATFORMS:
        preset = "Dora Player"
        options = {
            "macOS": 'binary_format/architecture="universal"',
            "Linux": 'binary_format/architecture="x86_64"',
            "Windows Desktop": 'binary_format/architecture="x86_64"',
            "Android": 'architectures/arm64-v8a=true',
            "iOS": 'application/targeted_device_family=2',
            "Web": 'variant/extensions_support=false',
        }
        (project / "export_presets.cfg").write_text(
            '[preset.0]\nname="Dora Player"\nplatform=' + json.dumps(platform)
            + '\nrunnable=true\nexport_filter="all_resources"\ninclude_filter=""\nexclude_filter=""\n'
              'export_path=""\nscript_export_mode=2\n[preset.0.options]\n' + options[platform] + '\n', encoding="utf-8")
        matches = [{"name": preset, "platform": platform}]
    else:
        matches = []
    if len(matches) != 1 or matches[0]["platform"] not in PLATFORMS:
        raise ProjectError("Select --preset, or --platform for a project without presets; available: " + json.dumps(available))
    selected = matches[0]
    if platform and selected["platform"] != platform:
        raise ProjectError("Selected export preset targets a different platform")
    output = output.absolute()
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=output.name + "-", dir=output.parent) as temporary:
        package = Path(temporary)
        receipt = json.loads((work / "prepared.json").read_text(encoding="utf-8"))
        run_command([receipt["editor"]["path"], "--headless", "--path", str(project),
                     "--export-pack", selected["name"], str(package / "game.pck")], work / "export.log", timeout)
        inspect_pck(package / "game.pck")
        licenses = []
        source_root = source.resolve() if source.is_dir() else source.resolve().parent
        for name in ["LICENSE", "LICENSE.txt", "LICENSE.md", "COPYING", "NOTICE", "CREDITS.md"]:
            original = project / name
            if not original.is_file() and (source_root / name).is_file():
                original = source_root / name
            if original.is_file() and not original.is_symlink():
                target = package / "licenses" / name
                target.parent.mkdir(exist_ok=True)
                shutil.copy2(original, target)
                licenses.append(target.relative_to(package).as_posix())
        manifest = {"format": GAME_FORMAT, "format_version": 1, "id": game_id,
                    "title": receipt["source"]["title"], "version": version,
                    "runtime": {"godot": "4.7", "mono": False}, "entry": "game.pck",
                    "platform": selected["platform"], "export_preset": selected["name"],
                    "rendering_method": receipt["source"]["rendering_method"],
                    "source": {"git": receipt["source"]["git"],
                               "files_sha256": hashlib.sha256(json.dumps(receipt["source_files_sha256"],
                                   sort_keys=True, separators=(",", ":")).encode()).hexdigest()},
                    "editor_version": receipt["editor"]["version"], "licenses": licenses,
                    "artifacts": {p.relative_to(package).as_posix(): {"sha256": digest(p), "bytes": p.stat().st_size}
                                  for p in sorted(package.rglob("*")) if p.is_file()}}
        write_json(package / "game.json", manifest)
        verify_game(package)
        if output.exists():
            raise ProjectError("Game package output appeared during export")
        package.rename(output)
    return verify_game(output)


def archive_game(package: Path, output: Path) -> dict:
    verified = verify_game(package)
    package = package.resolve()
    if output.exists() or output.is_symlink() or output.resolve().is_relative_to(package):
        raise ProjectError("Choose a new archive path outside the game package")
    output.parent.mkdir(parents=True, exist_ok=True)
    manifest = json.loads((package / "game.json").read_text(encoding="utf-8"))
    with tempfile.TemporaryDirectory(prefix="dora-game-archive-", dir=output.parent) as temporary:
        archive = Path(temporary) / "game.zip"
        with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_STORED) as zip:
            for name in ["game.json", *sorted(manifest["artifacts"])]:
                entry = zipfile.ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
                entry.external_attr = 0o100644 << 16
                with zip.open(entry, "w", force_zip64=True) as target, (package / name).open("rb") as source:
                    shutil.copyfileobj(source, target)
        if output.exists():
            raise ProjectError("Archive output appeared during packaging")
        archive.rename(output)
    return {"archived": True, "archive": str(output.resolve()), "sha256": digest(output),
            "bytes": output.stat().st_size, "id": verified["id"]}


def _unpack(archive: Path, output: Path, check, max_bytes: int, max_files: int,
            repository: bool = False) -> None:
    if output.exists() or output.is_symlink():
        raise ProjectError("Install into a new game directory")
    if max_bytes < 1 or max_files < 1:
        raise ProjectError("Installation size/file limits must be positive")
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as zip, tempfile.TemporaryDirectory(
            prefix="dora-game-install-", dir=output.parent) as temporary:
        package = Path(temporary)
        seen, total = set(), 0
        entries = zip.infolist()
        if len(entries) > max_files:
            raise ProjectError("Game archive exceeds the file limit")
        for entry in entries:
            name = entry.filename.rstrip("/")
            relative = PurePosixPath(name)
            if (not name or relative.is_absolute() or ".." in relative.parts or "\\" in name or ":" in name or "\0" in name
                    or str(relative) != name or name in seen or entry.flag_bits & 1
                    or (entry.external_attr >> 16) & 0o170000 == 0o120000):
                raise ProjectError("Unsafe, encrypted or duplicate archive entry")
            seen.add(name)
            total += entry.file_size
            if total > max_bytes:
                raise ProjectError("Game archive exceeds the expanded size limit")
        for entry in entries:
            if repository and SKIP_DIRECTORIES.intersection(PurePosixPath(entry.filename).parts):
                continue
            target = package / entry.filename
            if entry.is_dir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                with zip.open(entry) as source, target.open("xb") as destination:
                    shutil.copyfileobj(source, destination)
        if repository:
            children = list(package.iterdir())
            if len(children) == 1 and children[0].is_dir():
                package = children[0]  # Git hosting ZIPs wrap a single repository directory.
        check(package)
        if output.exists():
            raise ProjectError("Install output appeared during verification")
        package.rename(output)


def install_game(archive: Path, output: Path, max_bytes: int = 4 * 1024**3,
                 max_files: int = 10000) -> dict:
    _unpack(archive, output, verify_game, max_bytes, max_files)
    return verify_game(output)


def import_repository(archive: Path, output: Path, max_bytes: int = 4 * 1024**3,
                      max_files: int = 100000) -> dict:
    _unpack(archive, output, lambda root: None, max_bytes, max_files, repository=True)
    return {"imported": True, "repository": str(output.resolve()), "archive_sha256": digest(archive)}
