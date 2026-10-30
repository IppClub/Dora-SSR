#!/usr/bin/env python3
"""Create a sealed, relocatable Android direct-target physical-device test bundle."""
import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(root / "Tools/Godot/tests/android"))
from verify_ordinary_release import audit_apk

parser = argparse.ArgumentParser(description=__doc__)
for name in ("sdk", "apk", "lifecycle-apk", "runtime-package", "output"):
    parser.add_argument("--" + name, type=Path, required=True)
args = parser.parse_args()

sdk = args.sdk.resolve()
apk = args.apk.resolve()
controller = args.lifecycle_apk.resolve()
runtime = args.runtime_package.resolve()
output = args.output.resolve()
assert not output.exists(), "Refusing to replace an existing test bundle: " + str(output)
for path in (apk, controller):
    assert path.is_file(), "Missing APK: " + str(path)
assert runtime.is_dir(), "Missing runtime package"
aapt = sdk / "build-tools/34.0.0/aapt"
apksigner = sdk / "build-tools/34.0.0/apksigner"
adb = sdk / "platform-tools/adb"
for tool in (aapt, apksigner, adb):
    assert tool.is_file(), "Missing Android SDK tool: " + str(tool)

runtime_manifest = json.loads((runtime / "manifest.json").read_text())
runtime_library = runtime / runtime_manifest["library"]
elf = runtime_library.read_bytes()[:20]
assert elf[:6] == b"\x7fELF\x02\x01" and int.from_bytes(elf[18:20], "little") == 183, \
    "Physical bundle requires an ELF64 AArch64 runtime"
architectures = runtime_manifest.get("architectures")
assert architectures in (None, ["arm64"], ["arm64-v8a"]), "Runtime architecture inventory conflicts with ELF"
apk_audit = audit_apk(apk, runtime, aapt, False)

def command(*parts):
    return subprocess.check_output([str(part) for part in parts], text=True, stderr=subprocess.STDOUT)

def signer_digest(path):
    text = command(apksigner, "verify", "--print-certs", path)
    match = re.search(r"Signer #1 certificate SHA-256 digest: ([0-9a-fA-F]{64})", text)
    assert match, "APK signer digest missing: " + str(path)
    return match.group(1).lower()

controller_badging = command(aapt, "dump", "badging", controller)
assert "package: name='org.dora.godotrc1.lifecycle'" in controller_badging
controller_manifest = command(aapt, "dump", "xmltree", controller, "AndroidManifest.xml")
assert 'android:targetPackage(0x01010021)="org.ippclub.dorassr"' in controller_manifest
assert "org.dora.godotrc1.ReleaseLifecycle" in controller_manifest
target_signer = signer_digest(apk)
controller_signer = signer_digest(controller)
assert target_signer == controller_signer, "Target and lifecycle controller use different QA certificates"

def copy(relative):
    source = root / relative
    destination = output / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)

apk_dir = output / "apk"
apk_dir.mkdir(parents=True)
shutil.copy2(apk, apk_dir / "Dora-Godot-Release-local-qa.apk")
shutil.copy2(controller, apk_dir / "Dora-Godot-Lifecycle-local-qa.apk")
shutil.copytree(runtime, output / "runtime")
for relative in (
    "Tools/Godot/tests/android/run_direct_release.py",
    "Tools/Godot/tests/android/run_ordinary_release.py",
    "Tools/Godot/tests/android/verify_ordinary_release.py",
    "Tools/Godot/tests/android/ordinary_release.lua",
    "Tools/Godot/tests/project/main.gd",
    "Tools/Godot/tests/project/main.tscn",
    "Tools/Godot/tests/project/project.godot",
    "Tools/Godot/tests/project/state.gd",
    "Tools/Godot/verify_package.py",
    "Tools/Godot/package_manifest.py",
):
    copy(relative)

(output / "requirements.txt").write_text("Pillow==12.3.0\n", encoding="utf-8")
(output / "verify-bundle.py").write_text(r'''#!/usr/bin/env python3
import hashlib, json
from pathlib import Path
root=Path(__file__).resolve().parent
manifest=json.loads((root/'test-package.json').read_text())
def managed(p):
    relative=p.relative_to(root)
    return relative.parts[0] not in {'.venv','results'} and p.name!='test-package.json'
actual={p.relative_to(root).as_posix() for p in root.rglob('*') if p.is_file() and managed(p)}
expected=set(manifest['artifacts'])
assert actual==expected, 'Bundle inventory mismatch: '+str(sorted(actual^expected))
for name,digest in manifest['artifacts'].items():
    assert hashlib.sha256((root/name).read_bytes()).hexdigest()==digest, 'Bundle hash mismatch: '+name
print('Android direct-target physical test bundle verified:',len(expected),'files')
''', encoding="utf-8")

(output / "run-physical.sh").write_text(r'''#!/bin/sh
set -eu
cd "$(dirname "$0")"
if [ "$#" -ne 2 ]; then echo "usage: $0 DEVICE_SERIAL NEW_RESULTS_DIRECTORY" >&2; exit 2; fi
: "${ANDROID_HOME:?Set ANDROID_HOME to Android SDK 35 with Build Tools 34.0.0}"
python3 verify-bundle.py
if [ ! -x .venv/bin/python ]; then
  python3 -m venv .venv
  .venv/bin/python -m pip install --requirement requirements.txt
fi
exec .venv/bin/python Tools/Godot/tests/android/run_direct_release.py \
  --sdk "$ANDROID_HOME" --serial "$1" --physical-device \
  --apk apk/Dora-Godot-Release-local-qa.apk \
  --runtime-package runtime \
  --lifecycle-apk apk/Dora-Godot-Lifecycle-local-qa.apk \
  --output "$2"
''', encoding="utf-8")
(output / "run-physical.sh").chmod(0o755)

(output / "run-physical.cmd").write_text(r'''@echo off
setlocal
cd /d "%~dp0"
if "%~2"=="" echo usage: %~nx0 DEVICE_SERIAL NEW_RESULTS_DIRECTORY & exit /b 2
if "%ANDROID_HOME%"=="" echo Set ANDROID_HOME to Android SDK 35 with Build Tools 34.0.0 & exit /b 2
py -3 verify-bundle.py || exit /b 3
if not exist .venv\Scripts\python.exe (
  py -3 -m venv .venv || exit /b 4
  .venv\Scripts\python.exe -m pip install --requirement requirements.txt || exit /b 5
)
.venv\Scripts\python.exe Tools\Godot\tests\android\run_direct_release.py ^
  --sdk "%ANDROID_HOME%" --serial "%~1" --physical-device ^
  --apk apk\Dora-Godot-Release-local-qa.apk ^
  --runtime-package runtime ^
  --lifecycle-apk apk\Dora-Godot-Lifecycle-local-qa.apk ^
  --output "%~2"
exit /b %errorlevel%
''', encoding="utf-8")

(output / "README.txt").write_text(r'''Dora + Godot Android EGL direct-target physical acceptance bundle

Status
------
This bundle has passed static integrity checks and the same 2/3/4 matrix has
passed on an API 35 ARM64 emulator. It does NOT contain physical-device evidence.
DIRECT-02 remains pending until this exact bundle passes on an ARM64 phone/tablet.

Prerequisites
-------------
1. ARM64 Android device with Developer options and USB debugging enabled.
2. Android SDK 35, Build Tools 34.0.0, platform-tools and Python 3 on the host.
3. Set ANDROID_HOME. The first run installs pinned Pillow into a local .venv.
4. Remove or preserve any existing org.ippclub.dorassr installation first; this
   locally QA-signed APK is not a production/distribution signature.

Run
---
macOS/Linux:
  ./run-physical.sh DEVICE_SERIAL results/physical-device

Windows:
  run-physical.cmd DEVICE_SERIAL results\physical-device

The runner refuses emulators, uses no adb root, installs the ordinary
nondebuggable/R8 target plus a separately signed instrumentation controller,
and executes 2/3/4 buffers with system touch, SDL IME text, same-PID Home/resume,
640x360/800x450/320x180 resize, retained texture aliases, PCM and full shutdown.

Acceptance
----------
Preserve the whole results directory. Its verification.json must report
passed=true, physical_device=true and direct02_accepted=true. Every case must
report blits=0, produced==completed, GPU pending/errors=0 and PCM underruns=0.
Do not treat installation, compilation or an emulator run as physical acceptance.
''', encoding="utf-8")

def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

source_scope = (
    "Source/Godot/GodotRuntimeGL.cpp",
    "Tools/Godot/module/gl/egl_transport.cpp",
    "Tools/Godot/module/register_types_gl.cpp",
    "Tools/Godot/package_android_direct_test.py",
    "Tools/Godot/tests/android/lifecycle/app/src/main/java/org/dora/godotrc1/ReleaseLifecycle.java",
    "Tools/Godot/tests/android/ordinary_release.lua",
    "Tools/Godot/tests/android/run_direct_release.py",
    "Tools/Godot/tests/android/run_ordinary_release.py",
    "Tools/Godot/tests/android/verify_ordinary_release.py",
    "Tools/Godot/tests/gl/transport.cpp",
    "Tools/Godot/tests/project/main.gd",
)
manifest = {
    "package_format": "dora-godot-android-direct-physical-test",
    "package_version": 1,
    "status": "emulator_matrix_passed; physical_device_acceptance_pending",
    "android_abi": "arm64-v8a",
    "physical_device_tested": False,
    "direct02_accepted": False,
    "target_package": "org.ippclub.dorassr",
    "controller_package": "org.dora.godotrc1.lifecycle",
    "qa_signer_sha256": target_signer,
    "apk_audit": apk_audit,
    "runtime_manifest_sha256": digest(runtime / "manifest.json"),
    "source_scope": {name: digest(root / name) for name in source_scope},
}
manifest["artifacts"] = {
    file.relative_to(output).as_posix(): digest(file)
    for file in sorted(output.rglob("*"))
    if file.is_file() and file.name != "test-package.json"
}
(output / "test-package.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
subprocess.run([sys.executable, str(output / "verify-bundle.py")], check=True)
archive = Path(shutil.make_archive(str(output), "zip", output.parent, output.name))
with zipfile.ZipFile(archive) as zipped:
    assert zipped.testzip() is None
summary = {
    "passed": True,
    "scope": "Static APK/runtime/signature/inventory validation and ZIP CRC only; no physical-device execution",
    "directory": str(output),
    "archive": str(archive),
    "archive_sha256": digest(archive),
    "files": len(manifest["artifacts"]) + 1,
    "bytes": sum(path.stat().st_size for path in output.rglob("*") if path.is_file()),
    "physical_device_tested": False,
    "direct02_accepted": False,
}
(output.parent / (output.name + "-verification.json")).write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps(summary, indent=2))
