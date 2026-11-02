#!/usr/bin/env python3
"""Exercise xmake-driven Godot code generation and its incremental boundary."""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "build/godot-xmake/generated"
CONFIG = ROOT / "build/godot-xmake/xmake-config-test"


def run(*args: str) -> str:
    env = os.environ.copy()
    env["XMAKE_CONFIGDIR"] = str(CONFIG)
    return subprocess.check_output(args, cwd=ROOT, env=env, text=True, stderr=subprocess.STDOUT)


def snapshot() -> dict[str, tuple[int, int]]:
    return {
        path.relative_to(OUTPUT).as_posix(): (path.stat().st_mtime_ns, path.stat().st_size)
        for path in OUTPUT.rglob("*")
        if path.is_file()
    }


def main() -> None:
    run("xmake", "f", "-c", "-p", "macosx", "-a", "arm64", "-m", "release", "--dora_godot_runtime=y")
    first_log = run("xmake", "build", "-r", "-vD", "godot-codegen")
    first = snapshot()
    state = json.loads((OUTPUT / ".xmake-codegen.json").read_text(encoding="utf-8"))
    assert len(state["outputs"]) == 143, len(state["outputs"])
    required = {
        "core/version_generated.gen.h",
        "core/object/gdvirtual.gen.inc",
        "core/extension/gdextension_interface.gen.h",
        "modules/register_module_types.gen.cpp",
        "platform/register_platform_apis.gen.cpp",
        "drivers/gles3/shaders/canvas.glsl.gen.h",
        "servers/rendering/renderer_rd/shaders/forward_mobile/scene_forward_mobile.glsl.gen.h",
    }
    assert required.issubset(state["outputs"]), required - set(state["outputs"])

    second_log = run("xmake", "build", "-r", "-vD", "godot-codegen")
    second = snapshot()
    assert first == second, "unchanged inputs rewrote generated outputs"
    assert "unchanged: 143 outputs" in second_log, second_log
    assert "generated: 143 outputs" in first_log or "unchanged: 143 outputs" in first_log, first_log
    print("validated xmake-driven Godot codegen: 143 outputs; incremental rebuild unchanged")


if __name__ == "__main__":
    main()
