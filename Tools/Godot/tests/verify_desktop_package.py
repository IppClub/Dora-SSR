#!/usr/bin/env python3
"""Verify a staged desktop Dora package contains one sealed Godot runtime."""
import argparse
import hashlib
import json
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(root / "Tools/Godot"))
from verify_package import verify  # noqa: E402

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--platform", choices=["macosx", "linux", "windows"], required=True)
parser.add_argument("--package-root", type=Path, required=True)
parser.add_argument("--runtime-package", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()

package_root = args.package_root.resolve()
runtime = args.runtime_package.resolve()
assert package_root.is_dir() and not args.output.resolve().is_relative_to(package_root)
runtime_check = verify(runtime)
manifest_bytes = (runtime / "manifest.json").read_bytes()
manifest = json.loads(manifest_bytes)

if args.platform == "macosx":
    asset_root = package_root / "Contents/Resources"
    executable = package_root / "Contents/MacOS/Dora"
elif args.platform == "linux":
    asset_root = package_root / "usr/share/dora-ssr/Assets"
    executable = package_root / "usr/bin/dora-ssr"
else:
    asset_root = package_root
    executable = package_root / "Dora.exe"

library = asset_root / manifest["library"]
notices = asset_root / "GodotRuntimeNotices"
assert executable.is_file() and library.is_file()
assert hashlib.sha256(library.read_bytes()).hexdigest() == manifest["library_sha256"]
assert (notices / "manifest.json").read_bytes() == manifest_bytes
license_hashes = {}
for relative in manifest["licenses"]:
    source = runtime / relative
    staged = notices / relative
    assert source.is_file() and staged.is_file()
    assert staged.read_bytes() == source.read_bytes()
    license_hashes[relative] = hashlib.sha256(staged.read_bytes()).hexdigest()

report = {
    "passed": True,
    "scope": "Staged desktop package layout, sealed runtime bytes and declared license inventory only; installation, signature and runtime/GPU behavior are separate checks.",
    "platform": args.platform,
    "package_root": str(package_root),
    "executable": str(executable.relative_to(package_root)),
    "runtime_library": str(library.relative_to(package_root)),
    "runtime_library_sha256": manifest["library_sha256"],
    "runtime_manifest_sha256": hashlib.sha256(manifest_bytes).hexdigest(),
    "runtime_package_verification": runtime_check,
    "architectures": manifest.get("architectures"),
    "licenses": license_hashes,
}
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps({"passed": True, "platform": args.platform, "library": report["runtime_library"]}))
