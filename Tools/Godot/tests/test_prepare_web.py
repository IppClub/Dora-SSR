#!/usr/bin/env python3
"""Regression: compatibility preparation entrypoints are read-only validators."""
import hashlib
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[3]
source = root / "Source/3rdParty/Godot"
paths = (
    "platform/web/SCsub",
    "platform/web/detect.py",
    "platform/web/audio_driver_web.cpp",
    "platform/web/js/libs/library_godot_os.js",
    "modules/dora_bridge/web/web_api.cpp",
)


def digest() -> dict[str, str]:
    return {
        name: hashlib.sha256((source / name).read_bytes()).hexdigest()
        for name in paths
    }


before = digest()
for _ in range(2):
    subprocess.run(["python3", str(root / "Tools/Godot/prepare.py"), str(source)], check=True)
    subprocess.run(["python3", str(root / "Tools/Godot/prepare_web.py"), str(source)], check=True)
assert digest() == before, "vendored Web validation changed source bytes"

scsub = (source / paths[0]).read_text()
assert "sys_env.AddJSLibraries(" in scsub
assert "# Dora embedded Web library: the host owns main and all frame scheduling." in scsub
assert "web_files.remove(\"web_main.cpp\")" in scsub
print("Vendored Web source validation is repeatable and read-only: PASS")
