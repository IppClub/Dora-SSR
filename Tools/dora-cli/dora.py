#!python3
"""
Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

import requests

DEFAULT_LANGUAGE = "zh-Hans"
DEFAULT_HOST = os.environ.get("DORA_HOST", "127.0.0.1")
DEFAULT_PORT = int(os.environ.get("DORA_PORT", "8866"))
DEFAULT_TIMEOUT = float(os.environ.get("DORA_TIMEOUT", "10"))
DEFAULT_PROJECT = os.environ.get("DORA_PROJECT", os.getcwd())
SUPPORTED_LANGUAGES = ("zh-Hans", "en")
API_FILES = {
    "BlocklyGen.d.ts",
    "flow.d.ts",
    "Config.d.ts",
    "Dora.d.ts",
    "DoraX.d.ts",
    "es6-subset.d.ts",
    "ImGui.d.ts",
    "InputManager.d.ts",
    "jsx.d.ts",
    "lua.d.ts",
    "nvg.d.ts",
    "Platformer.d.ts",
    "PlatformerX.d.ts",
    "YarnRunner.d.ts",
    "Button.d.ts",
    "CircleButton.d.ts",
    "Ruler.d.ts",
    "ScrollArea.d.ts",
    "Circle.d.ts",
    "LineRect.d.ts",
    "Rectangle.d.ts",
    "Star.d.ts",
    "Utils.d.ts",
    "tic80.d.ts",
}
TSCONFIG = {
    "compilerOptions": {
        "jsx": "react",
        "target": "ESNext",
        "module": "ESNext",
        "strict": True,
        "esModuleInterop": False,
        "skipLibCheck": True,
        "forceConsistentCasingInFileNames": True,
        "allowSyntheticDefaultImports": True,
        "rootDir": "./",
        "typeRoots": ["API"],
        "types": ["Dora"],
    },
    "include": ["**/*.ts", "**/*.tsx"],
    "exclude": ["node_modules", "dist"],
}
WASM_TOOL_CONFIG = {
    "rust": {
        "label": "Rust",
        "build_cmd": ["cargo", "build", "--release", "--target", "wasm32-wasip1"],
        "build_dir": Path("target/wasm32-wasip1/release"),
    },
    "wa": {
        "label": "Wa",
        "build_cmd": ["wa", "build", "--target", "wasi", "-optimize"],
        "build_dir": Path("output"),
    },
}


class DoraError(RuntimeError):
    pass


def program_name() -> str:
    return Path(sys.argv[0]).name or "dora"


def add_project_argument(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "-p",
        "--project",
        default=DEFAULT_PROJECT,
        help="Project directory. Defaults to the current working directory.",
    )


def add_connection_arguments(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--host",
        default=DEFAULT_HOST,
        help=f"Dora SSR host. Defaults to {DEFAULT_HOST}.",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=DEFAULT_PORT,
        help=f"Dora SSR port. Defaults to {DEFAULT_PORT}.",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=DEFAULT_TIMEOUT,
        help=f"HTTP timeout in seconds. Defaults to {DEFAULT_TIMEOUT:g}.",
    )


def add_entry_argument(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--entry",
        default="init.lua",
        help="Entry file used by run/buildrun. Defaults to init.lua.",
    )


def add_target_path_argument(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "target_path",
        help="Destination folder in Dora SSR used for uploading the generated WASM.",
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog=program_name(),
        description="Dora SSR development CLI for TypeScript, Rust, and Wa projects.",
    )
    subparsers = parser.add_subparsers(dest="tool", metavar="tool")

    build_ts_parser(subparsers)
    build_wasm_parser(subparsers, "rust")
    build_wasm_parser(subparsers, "wa")

    stop_parser = subparsers.add_parser("stop", help="Stop the running Dora SSR project.")
    add_connection_arguments(stop_parser)

    return parser


def build_ts_parser(subparsers: argparse._SubParsersAction) -> None:
    ts_parser = subparsers.add_parser("ts", help="TypeScript workflow commands.")
    ts_subparsers = ts_parser.add_subparsers(dest="action", metavar="command")

    init_parser = ts_subparsers.add_parser(
        "init", help="Initialize a Dora SSR TypeScript project."
    )
    add_project_argument(init_parser)
    add_connection_arguments(init_parser)
    init_parser.add_argument(
        "-l",
        "--language",
        default=DEFAULT_LANGUAGE,
        choices=SUPPORTED_LANGUAGES,
        help="API language used by init.",
    )

    build_parser = ts_subparsers.add_parser(
        "build", help="Build a Dora SSR TypeScript project."
    )
    add_project_argument(build_parser)
    add_connection_arguments(build_parser)
    build_parser.add_argument(
        "-f",
        "--file",
        help="File or directory to build. Defaults to the project directory.",
    )

    run_parser = ts_subparsers.add_parser("run", help="Run a Dora SSR TypeScript project.")
    add_project_argument(run_parser)
    add_connection_arguments(run_parser)
    add_entry_argument(run_parser)

    buildrun_parser = ts_subparsers.add_parser(
        "buildrun", help="Build and then run a Dora SSR TypeScript project."
    )
    add_project_argument(buildrun_parser)
    add_connection_arguments(buildrun_parser)
    add_entry_argument(buildrun_parser)
    buildrun_parser.add_argument(
        "-f",
        "--file",
        help="File or directory to build. Defaults to the project directory.",
    )

    stop_parser = ts_subparsers.add_parser(
        "stop", help="Stop the running Dora SSR project."
    )
    add_connection_arguments(stop_parser)


def build_wasm_parser(subparsers: argparse._SubParsersAction, kind: str) -> None:
    config = WASM_TOOL_CONFIG[kind]
    tool_parser = subparsers.add_parser(
        kind, help=f"{config['label']} workflow commands."
    )
    tool_subparsers = tool_parser.add_subparsers(dest="action", metavar="command")

    build_parser = tool_subparsers.add_parser(
        "build", help=f"Build the {config['label']} project into WASM."
    )
    add_project_argument(build_parser)

    run_parser = tool_subparsers.add_parser(
        "run", help=f"Build, upload, and run the {config['label']} WASM project."
    )
    add_project_argument(run_parser)
    add_connection_arguments(run_parser)
    add_target_path_argument(run_parser)

    upload_parser = tool_subparsers.add_parser(
        "upload", help=f"Upload the latest built {config['label']} WASM file."
    )
    add_project_argument(upload_parser)
    add_connection_arguments(upload_parser)
    add_target_path_argument(upload_parser)
    upload_parser.add_argument(
        "--run",
        action="store_true",
        help="Run the uploaded WASM after upload completes.",
    )
def base_url(host: str, port: int) -> str:
    return f"http://{host}:{port}"


def resolve_project_dir(project: str) -> Path:
    project_dir = Path(project).expanduser().resolve()
    if not project_dir.exists():
        raise DoraError(f"Project directory does not exist: {project_dir}")
    if not project_dir.is_dir():
        raise DoraError(f"Project path is not a directory: {project_dir}")
    return project_dir


def resolve_build_target(project_dir: Path, target: str | None) -> Path:
    if not target:
        return project_dir
    candidate = Path(target).expanduser()
    if not candidate.is_absolute():
        candidate = project_dir / candidate
    return candidate.resolve()


def resolve_entry_file(project_dir: Path, entry: str) -> Path:
    candidate = Path(entry).expanduser()
    if not candidate.is_absolute():
        candidate = project_dir / candidate
    return candidate.resolve()


def create_session(timeout: float) -> requests.Session:
    session = requests.Session()
    session.timeout = timeout
    return session


def post_json(session: requests.Session, url: str, **kwargs) -> dict:
    try:
        response = session.post(url, timeout=session.timeout, **kwargs)
        response.raise_for_status()
        return response.json()
    except requests.ConnectionError as exc:
        raise DoraError(
            "Failed to connect to Dora SSR. Ensure the engine and Web IDE are "
            f"running at {url}."
        ) from exc
    except requests.Timeout as exc:
        raise DoraError(f"Request timed out: {url}") from exc
    except requests.RequestException as exc:
        raise DoraError(f"Request failed: {exc}") from exc
    except ValueError as exc:
        raise DoraError(f"Invalid JSON response from {url}") from exc


def fetch_api_targets(session: requests.Session, root_url: str, language: str) -> list[dict]:
    json_response = post_json(session, f"{root_url}/assets")
    children = json_response.get("children") or []
    if not children:
        raise DoraError("Unexpected /assets response: missing builtin asset tree.")

    builtin = children[0]
    builtin_key = builtin.get("key")
    if not builtin_key:
        raise DoraError("Unexpected /assets response: missing builtin key.")

    api_targets: list[dict] = []

    def visit(node: dict) -> None:
        if node.get("dir"):
            for child in node.get("children") or []:
                visit(child)
            return

        title = node.get("title")
        key = node.get("key")
        if title not in API_FILES or not key:
            return

        normalized_key = key.replace("\\", "/")
        if "Script/Lib/Dora" in normalized_key:
            if f"Script/Lib/Dora/{language}" in normalized_key:
                api_targets.append({"relative_path": Path(title), "remote_key": key})
            return

        relative_path = Path(
            os.path.relpath(key, os.path.join(builtin_key, "Script", "Lib"))
        )
        api_targets.append({"relative_path": relative_path, "remote_key": key})

    visit(builtin)
    return api_targets


def init_ts_project(
    session: requests.Session, root_url: str, project_dir: Path, language: str
) -> None:
    print(f"Initializing Dora SSR TypeScript project in {project_dir}...")
    api_dir = project_dir / "API"
    api_dir.mkdir(parents=True, exist_ok=True)

    for api in fetch_api_targets(session, root_url, language):
        local_path = api_dir / api["relative_path"]
        local_path.parent.mkdir(parents=True, exist_ok=True)
        json_response = post_json(
            session, f"{root_url}/read", json={"path": api["remote_key"]}
        )
        if not json_response.get("success"):
            raise DoraError(f"Failed to read {api['remote_key']}")
        local_path.write_text(json_response.get("content", ""), encoding="utf-8")

    tsconfig_path = project_dir / "tsconfig.json"
    tsconfig_path.write_text(
        json.dumps(TSCONFIG, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    print(f"API files written to {api_dir}")
    print(f"TypeScript config written to {tsconfig_path}")


def build_ts_project(
    session: requests.Session, root_url: str, project_dir: Path, target: str | None
) -> None:
    build_target = resolve_build_target(project_dir, target)
    print(f"Compiling Dora SSR TypeScript project: {build_target}")
    json_response = post_json(
        session, f"{root_url}/ts/build", json={"path": str(build_target)}
    )

    if not json_response.get("success"):
        message = json_response.get("message", "Unknown error.")
        raise DoraError(f"Compilation failed. {message}")

    print("Compilation complete.")
    messages = json_response.get("messages") or []
    if not messages:
        print("No files built.")
        return

    for message in messages:
        if message.get("success"):
            print(f"\033[92m[info]\033[0m {message.get('file')} built.")
        else:
            print(f"\033[91m[error]\033[0m {message.get('message')}")


def run_ts_project(
    session: requests.Session, root_url: str, project_dir: Path, entry: str
) -> None:
    entry_file = resolve_entry_file(project_dir, entry)
    json_response = post_json(
        session,
        f"{root_url}/run",
        json={"file": str(entry_file), "asProj": True},
    )
    if not json_response.get("success"):
        raise DoraError(f"Failed to run project with entry {entry_file}")
    print(f"Start running {entry_file}...")


def stop_project(session: requests.Session, root_url: str) -> None:
    json_response = post_json(session, f"{root_url}/stop")
    if not json_response.get("success"):
        raise DoraError("Failed to stop running project.")
    print("Stopped running.")


def build_wasm_project(kind: str, project_dir: Path) -> None:
    config = WASM_TOOL_CONFIG[kind]
    print(f"Compiling {config['label']} project in {project_dir}...")
    try:
        subprocess.run(config["build_cmd"], cwd=project_dir, check=True)
    except FileNotFoundError as exc:
        raise DoraError(
            f"Build tool not found for {config['label']}. Command: {config['build_cmd'][0]}"
        ) from exc
    except subprocess.CalledProcessError as exc:
        raise DoraError(f"{config['label']} compilation failed.") from exc
    print("Compilation complete.")


def find_latest_wasm(kind: str, project_dir: Path) -> Path:
    build_dir = project_dir / WASM_TOOL_CONFIG[kind]["build_dir"]
    direct_wasm_files = sorted(build_dir.glob("*.wasm"), key=lambda path: path.stat().st_mtime)
    if direct_wasm_files:
        latest = direct_wasm_files[-1]
        print(f"Found .wasm file: {latest}")
        return latest

    wasm_files = sorted(build_dir.rglob("*.wasm"), key=lambda path: path.stat().st_mtime)
    if not wasm_files:
        raise DoraError(
            f"No .wasm file found in {build_dir}. Please check if the compilation was successful."
        )
    latest = wasm_files[-1]
    print(f"Found .wasm file: {latest}")
    return latest


def upload_wasm_file(
    session: requests.Session,
    root_url: str,
    wasm_file: Path,
    target_path: str,
) -> str:
    try:
        with wasm_file.open("rb") as handle:
            files = {"file": (wasm_file.name, handle)}
            print("Uploading .wasm file...")
            response = session.post(
                f"{root_url}/upload",
                timeout=session.timeout,
                params={"path": target_path},
                files=files,
            )
            response.raise_for_status()
    except requests.RequestException as exc:
        raise DoraError(f"Failed to upload file {wasm_file}.") from exc

    remote_file = str(Path(target_path) / wasm_file.name)
    print(f"File uploaded to {remote_file}.")
    return remote_file


def run_remote_file(session: requests.Session, root_url: str, remote_file: str) -> None:
    json_response = post_json(
        session,
        f"{root_url}/run",
        json={"file": remote_file, "asProj": False},
    )
    if not json_response.get("success"):
        raise DoraError(f"Failed to run uploaded file {remote_file}")
    print("Started running.")


def run_wasm_workflow(
    kind: str,
    session: requests.Session,
    root_url: str,
    project_dir: Path,
    target_path: str,
    build_first: bool,
    run_after_upload: bool,
) -> None:
    if build_first:
        build_wasm_project(kind, project_dir)
    wasm_file = find_latest_wasm(kind, project_dir)
    remote_file = upload_wasm_file(session, root_url, wasm_file, target_path)
    if run_after_upload:
        run_remote_file(session, root_url, remote_file)


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        if args.tool == "stop":
            session = create_session(args.timeout)
            stop_project(session, base_url(args.host, args.port))
            return 0

        if args.tool == "ts":
            session = create_session(args.timeout)
            root_url = base_url(args.host, args.port)
            if args.action == "stop":
                stop_project(session, root_url)
                return 0

            project_dir = resolve_project_dir(args.project)
            if args.action == "init":
                init_ts_project(session, root_url, project_dir, args.language)
            elif args.action == "build":
                build_ts_project(session, root_url, project_dir, args.file)
            elif args.action == "run":
                run_ts_project(session, root_url, project_dir, args.entry)
            elif args.action == "buildrun":
                build_ts_project(session, root_url, project_dir, args.file)
                run_ts_project(session, root_url, project_dir, args.entry)
            else:
                raise DoraError("Missing ts command.")
            return 0

        if args.tool in WASM_TOOL_CONFIG:
            project_dir = resolve_project_dir(args.project)
            if args.action == "build":
                build_wasm_project(args.tool, project_dir)
                return 0

            session = create_session(args.timeout)
            root_url = base_url(args.host, args.port)
            if args.action == "run":
                run_wasm_workflow(
                    args.tool,
                    session,
                    root_url,
                    project_dir,
                    args.target_path,
                    build_first=True,
                    run_after_upload=True,
                )
            elif args.action == "upload":
                run_wasm_workflow(
                    args.tool,
                    session,
                    root_url,
                    project_dir,
                    args.target_path,
                    build_first=False,
                    run_after_upload=args.run,
                )
            else:
                raise DoraError(f"Missing {args.tool} command.")
            return 0

        parser.print_help()
        return 1
    except DoraError as exc:
        print(exc, file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("Interrupted.", file=sys.stderr)
        return 130


if __name__ == "__main__":
    sys.exit(main())
