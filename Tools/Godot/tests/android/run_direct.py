#!/usr/bin/env python3
"""Run the Android EGL direct-target 2/3/4 debug-prototype matrix."""
import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[4]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--serial", required=True)
parser.add_argument("--sdk", type=Path, required=True)
parser.add_argument("--apk", type=Path, required=True)
parser.add_argument("--runtime-package", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
parser.add_argument("--allow-emulator-regression", action="store_true")
args = parser.parse_args()

output = args.output.resolve()
output.mkdir(parents=True, exist_ok=False)
apk = args.apk.resolve()
runtime_package = args.runtime_package.resolve()
adb = args.sdk.resolve() / "platform-tools/adb"
artifacts = {
    "apk_sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
    "runtime_manifest_sha256": hashlib.sha256((runtime_package / "manifest.json").read_bytes()).hexdigest(),
}

cases = []
try:
    device_is_emulator = subprocess.check_output(
        [str(adb), "-s", args.serial, "shell", "getprop", "ro.kernel.qemu"],
        text=True,
        timeout=30,
    ).strip() == "1"
    if device_is_emulator and not args.allow_emulator_regression:
        raise RuntimeError("physical Android device required unless --allow-emulator-regression is set")
    for buffers in (2, 3, 4):
        case = output / f"buffers-{buffers}"
        command = [
            sys.executable, str(root / "Tools/Godot/tests/android/run_node.py"),
            "--serial", args.serial, "--sdk", str(args.sdk.resolve()),
            "--apk", str(apk), "--runtime-package", str(runtime_package),
            "--output", str(case), "--buffers", str(buffers),
            "--direct", "--audio", "--resize", "--cancel-resize", "--aliases",
            "--reservation", "--ime", "--controller", "--background",
        ]
        with (output / f"buffers-{buffers}.log").open("w") as log:
            subprocess.run(command, cwd=root, check=True, stdout=log,
                           stderr=subprocess.STDOUT, timeout=600)
        result = json.loads((case / "verification.json").read_text())
        assert result["android_emulator"] == device_is_emulator
        runtime_log = (case / "run.log").read_text(errors="replace")
        assert "GODOT_NODE_GL_DIRECT intent=1 env=1" in runtime_log
        enabled = re.findall(
            r"DORA_GODOT_GL_DIRECT enabled buffers=(\d+) size=(\d+)x(\d+) blits=0",
            runtime_log,
        )
        completed = [int(value) for value in re.findall(
            r"DORA_GODOT_GL_DIRECT completed frames=(\d+) blits=0", runtime_log
        )]
        assert enabled and all(int(item[0]) == buffers for item in enabled), enabled
        assert completed and all(value > 0 for value in completed), completed
        assert result["passed"] and result["direct_targets_requested"]
        assert result["android_background_resume"]["passed"]
        assert result["android_ime"]["passed"]
        assert all(item["errors"] == 0 and item["produced"] == item["completed"]
                   for item in result["gpu_accounting"])
        assert all(item["pending"] == 0 and item["gpu_errors"] == 0
                   for item in result["gpu_readers"])
        assert all(item["underrun_frames"] == 0 for item in result["audio_accounting"])
        cases.append({
            "buffers": buffers,
            "report": str(case / "verification.json"),
            "android_emulator": result["android_emulator"],
            "renderer": result["godot_renderer"],
            "frames": result["frames"],
            "direct_sessions": len(enabled),
            "direct_completed_frames": completed,
            "blits": 0,
        })
    physical = not device_is_emulator
    report = {
        "passed": True,
        "physical_device_functional_regression": physical,
        "direct02_physical_device_accepted": False,
        "direct02_release_accepted": False,
        "scope": "Android physical-device debug-prototype functional regression; ordinary nondebuggable Release pending"
                 if physical else "Android emulator regression only; not DIRECT-02 acceptance",
        "serial": args.serial,
        "artifacts": artifacts,
        "cases": cases,
    }
    (output / "verification.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
except BaseException as error:
    (output / "failure.json").write_text(json.dumps({
        "passed": False,
        "type": type(error).__name__,
        "error": str(error),
    }, indent=2) + "\n")
    raise
