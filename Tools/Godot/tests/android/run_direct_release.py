#!/usr/bin/env python3
"""Run the ordinary nondebuggable Android direct-target 2/3/4 acceptance matrix."""
import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[4]
parser = argparse.ArgumentParser(description=__doc__)
for name in ("sdk", "apk", "runtime-package", "lifecycle-apk", "output"):
    parser.add_argument("--" + name, type=Path, required=True)
parser.add_argument("--serial", required=True)
parser.add_argument("--owned-avd")
parser.add_argument("--physical-device", action="store_true")
parser.add_argument("--default-policy", action="store_true",
                    help="Leave DORA_GODOT_GL_DIRECT unset and require the validated direct default")
args = parser.parse_args()

output = args.output.resolve()
output.mkdir(parents=True, exist_ok=False)
adb = args.sdk.resolve() / "platform-tools/adb"
emulator = subprocess.check_output(
    [str(adb), "-s", args.serial, "shell", "getprop", "ro.kernel.qemu"],
    text=True,
    timeout=30,
).strip() == "1"
if emulator:
    assert not args.physical_device and args.owned_avd and args.owned_avd.startswith("DoraGodotRC1_")
else:
    assert args.physical_device and not args.owned_avd

cases = []
try:
    for buffers in (2, 3, 4):
        case = output / f"buffers-{buffers}"
        command = [
            sys.executable,
            str(root / "Tools/Godot/tests/android/run_ordinary_release.py"),
            "--serial", args.serial,
            "--sdk", str(args.sdk.resolve()),
            "--apk", str(args.apk.resolve()),
            "--runtime-package", str(args.runtime_package.resolve()),
            "--lifecycle-apk", str(args.lifecycle_apk.resolve()),
            "--output", str(case),
            "--buffers", str(buffers),
            "--full",
        ]
        if not args.default_policy:
            command.append("--direct")
        if emulator:
            command += ["--owned-avd", args.owned_avd]
        else:
            command.append("--physical-device")
        with (output / f"buffers-{buffers}.log").open("w") as log:
            subprocess.run(command, cwd=root, check=True, stdout=log,
                           stderr=subprocess.STDOUT, timeout=300)
        result = json.loads((case / "verification.json").read_text())
        assert result["passed"] and result["direct_targets_active"] and result["full_acceptance"]
        assert result["direct_targets_default"] == args.default_policy
        assert result["direct_targets_requested"] != args.default_policy
        assert result["direct_blits"] == 0 and result["artifacts"]["debuggable"] is False
        assert result["android_emulator"] == emulator
        cases.append({
            "buffers": buffers,
            "report": str(case / "verification.json"),
            "gpu_clients": result["gpu_clients"],
            "gpu_readers": result["gpu_readers"],
            "pcm": result["metrics"]["pcm"],
            "blits": result["direct_blits"],
            "aliases": buffers,
            "touch": True,
            "ime": True,
            "home_resume": True,
            "resize_sizes": [[640, 360], [800, 450], [320, 180]],
        })
    report = {
        "passed": True,
        "ordinary_nondebuggable_release": True,
        "physical_device": not emulator,
        "direct02_accepted": not emulator,
        "default_direct_policy": args.default_policy,
        "scope": ("Ordinary nondebuggable Release direct-target 2/3/4 physical-device acceptance: "
                  "system touch/IME, same-process Home/resume, resize and retained texture aliases"
                  if not emulator else
                  "Ordinary nondebuggable Release full matrix on an emulator; not physical-device acceptance"),
        "serial": args.serial,
        "artifacts": {
            "apk_sha256": hashlib.sha256(args.apk.read_bytes()).hexdigest(),
            "runtime_manifest_sha256": hashlib.sha256((args.runtime_package / "manifest.json").read_bytes()).hexdigest(),
            "lifecycle_apk_sha256": hashlib.sha256(args.lifecycle_apk.read_bytes()).hexdigest(),
        },
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
