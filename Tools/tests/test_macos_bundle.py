#!/usr/bin/env python3
"""Recover cached macOS bundle outputs and refresh resources without relinking."""
import argparse
import gzip
import plistlib
import shutil
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--bundle', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
bundle = args.bundle.resolve()
assert bundle.is_relative_to(root / 'build') and bundle.name == 'Dora.app', bundle
exe = bundle / 'Contents/MacOS/Dora'
commands = subprocess.check_output(['ps', '-axo', 'command'], text=True).splitlines()
assert not any(line == str(exe) or line.startswith(str(exe) + ' ') for line in commands), 'Quit this generated Dora.app before testing its rebuild'


def build():
    subprocess.run(['xmake', 'build', 'Dora'], cwd=root, check=True)


def verify():
    metadata = plistlib.loads((bundle / 'Contents/Info.plist').read_bytes())
    assert metadata['CFBundleIdentifier'] == 'IppClub.DoraSSR'
    assert metadata['CFBundleExecutable'] == 'Dora'
    for name in ['AppIcon.icns', 'Assets.car']:
        assert (bundle / 'Contents/Resources' / name).is_file(), name
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(bundle)], check=True)
    signature = subprocess.check_output(['codesign', '-dv', str(bundle)], text=True, stderr=subprocess.STDOUT)
    assert 'Identifier=IppClub.DoraSSR\n' in signature and 'Info.plist=not bound' not in signature, signature


www = root / 'Assets/www'
www.mkdir(parents=True, exist_ok=True)
raw = www / '__dora_bundle_rebuild_test__.js'
packed = Path(str(raw) + '.gz')
assert not raw.exists() and not packed.exists(), 'Reserved fixture name already exists'
installed = bundle / 'Contents/Resources/www' / raw.name
try:
    raw.write_bytes(b'/* bundle resource refresh */\n' * 200)
    build(); verify(); assert installed.read_bytes() == raw.read_bytes()
    packed.write_bytes(gzip.compress(raw.read_bytes(), mtime=0)); raw.unlink()
    build(); verify()
    assert not installed.exists() and Path(str(installed) + '.gz').read_bytes() == packed.read_bytes()
    unchanged = (bundle / 'Contents/MacOS/Dora').stat().st_mtime_ns
    build(); verify(); assert exe.stat().st_mtime_ns == unchanged, 'No-op build regenerated/signed the executable'
    # Reproduce output deletion while all xmake source dependency caches survive.
    shutil.rmtree(bundle)
    build(); verify()
    assert not installed.exists() and Path(str(installed) + '.gz').read_bytes() == packed.read_bytes()
    print('PASS: stable macOS identity, raw-to-gzip resource replacement, no-op build and complete bundle recovery')
finally:
    raw.unlink(missing_ok=True); packed.unlink(missing_ok=True)
    build()
