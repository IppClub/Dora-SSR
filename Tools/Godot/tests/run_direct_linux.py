#!/usr/bin/env python3
"""Validate Linux EGL Godot direct-target rendering with prebuilt artifacts.

Runs the full 2/3/4-buffer node matrix in isolated Weston sessions. The report
records the actual renderer; virtual/software output is not physical-GPU proof.
"""
import argparse
import hashlib
import json
import os
import platform
import re
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[3]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--binary", type=Path, required=True)
parser.add_argument("--library", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
assert sys.platform == "linux"

binary = args.binary.resolve()
library = args.library.resolve()
output = args.output.resolve()
assert binary.is_file() and library.is_file()
output.mkdir(parents=True, exist_ok=False)


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


artifacts = {str(path): digest(path) for path in (binary, library)}
environment = os.environ.copy()
for key in list(environment):
    if key.startswith(("DORA_GODOT_TEST_", "DORA_BUILD_")):
        environment.pop(key)
environment.update(
    DORA_GODOT_SKIP_BUILD="1",
    DORA_GODOT_SKIP_PREBOOT_ABI="0",
    DORA_GODOT_LIBRARY=str(library),
    DORA_GODOT_DORA_BINARY=str(binary),
    DORA_GODOT_GL_DIRECT="1",
    DORA_GODOT_TEST_AUDIO="1",
    DORA_GODOT_TEST_CONTROLLER="1",
    DORA_GODOT_TEST_RESIZE="1",
    DORA_GODOT_TEST_CANCEL_RESIZE="1",
    DORA_GODOT_TEST_ALIASES="1",
    DORA_GODOT_TEST_RESERVATION="1",
)

report = output / "verification.json"
try:
    subprocess.run(
        [sys.executable, str(root / "Tools/Godot/verify_package.py"), str(library.parent),
         "--output", str(output / "package-verification.json")],
        cwd=root, check=True, env=environment,
    )
    cases = []
    for buffers in (2, 3, 4):
        case = output / f"buffers-{buffers}"
        environment.update(
            DORA_GODOT_TEST_BUFFERS=str(buffers),
            DORA_GODOT_NODE_RESULTS=str(case),
        )
        command = [
            sys.executable, str(root / "Tools/Godot/tests/with_weston.py"),
            "--logs", str(output / f"weston-{buffers}"), "--",
            "bash", "Tools/Godot/test_linux.sh",
        ]
        with (output / f"buffers-{buffers}.log").open("w") as log:
            subprocess.run(command, cwd=root, env=environment, stdout=log,
                           stderr=subprocess.STDOUT, check=True, timeout=900)
        result = json.loads((case / "verification.json").read_text())
        assert result["passed"] and result["platform"] == "Linux EGL"
        runtime_log = (case / "run.log").read_text()
        enabled = re.findall(r"DORA_GODOT_GL_DIRECT enabled buffers=(\d+) size=(\d+)x(\d+) blits=0", runtime_log)
        completed = [int(value) for value in re.findall(r"DORA_GODOT_GL_DIRECT completed frames=(\d+) blits=0", runtime_log)]
        assert enabled and all(int(item[0]) == buffers for item in enabled), enabled
        assert completed and all(value > 0 for value in completed), completed
        assert all(digest(Path(path)) == value for path, value in artifacts.items())
        cases.append({
            "buffers": buffers,
            "report": str(case / "verification.json"),
            "frames": result["frames"],
            "renderer": result["godot_renderer"],
            "direct_sessions": len(enabled),
            "direct_completed_frames": completed,
            "blits": 0,
        })
    report.write_text(json.dumps({
        "passed": True,
        "scope": "Linux EGL GodotNode direct render targets; virtual/software renderer is not physical-GPU proof",
        "system": platform.platform(),
        "machine": platform.machine(),
        "artifacts": artifacts,
        "cases": cases,
    }, indent=2) + "\n")
    print("Linux EGL direct-target 2/3/4 matrix: PASS")
except BaseException as error:
    report.unlink(missing_ok=True)
    (output / "failure.json").write_text(json.dumps({
        "passed": False,
        "type": type(error).__name__,
        "error": str(error),
    }, indent=2) + "\n")
    raise
