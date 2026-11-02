#!/usr/bin/env python3
"""Validate the XMAKE-01 Godot target graph without compiling Godot."""

from __future__ import annotations

import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TARGETS = ROOT / "Projects/xmake/godot/targets.lua"
EXPECTED = [
    "godot-codegen",
    "godot-core",
    "godot-drivers",
    "godot-servers",
    "godot-scene",
    "godot-modules",
    "godot-main-platform",
    "godot-dora-bridge",
    "godot-runtime",
]
EXPECTED_DEPS = {
    "godot-core": "godot-codegen",
    "godot-drivers": "godot-core",
    "godot-servers": "godot-drivers",
    "godot-scene": "godot-servers",
    "godot-modules": "godot-scene",
    "godot-main-platform": "godot-modules",
    "godot-dora-bridge": "godot-main-platform",
    "godot-runtime": "godot-dora-bridge",
}


def run(*args: str) -> str:
    return subprocess.check_output(args, cwd=ROOT, text=True, stderr=subprocess.STDOUT)


def main() -> None:
    text = TARGETS.read_text(encoding="utf-8")
    declared = re.findall(r'name = "([^"]+)"', text)
    declared += re.findall(r'target\("([^"]+)"\)', text)
    # Platform blocks may reopen a target to append backend-specific link
    # settings; validate the logical target set rather than raw occurrences.
    assert set(declared) == set(EXPECTED), (declared, EXPECTED)
    assert 'path.join(os.projectdir(), "build/godot-xmake")' in text
    assert "Source/3rdParty/Godot" in text
    assert "has_config(\"dora_godot_runtime\")" in text

    before = run("git", "status", "--short", "--", "Source/3rdParty/Godot")
    listed = run("xmake", "show", "-l", "targets")
    after = run("git", "status", "--short", "--", "Source/3rdParty/Godot")
    assert before == after == "", (before, after)
    for target in EXPECTED:
        assert target in listed, target
        details = run("xmake", "show", "-t", target)
        if target != "godot-codegen":
            assert "build/godot-xmake" in details, (target, details)
        dependency = EXPECTED_DEPS.get(target)
        if dependency:
            assert dependency in details, (target, dependency)

    print(f"validated {len(EXPECTED)} Godot xmake targets; vendor tree unchanged")


if __name__ == "__main__":
    main()
