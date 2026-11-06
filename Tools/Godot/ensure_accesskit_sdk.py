#!/usr/bin/env python3
"""Fetch/verify the fixed upstream AccessKit static SDK for a pinned platform profile."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'Projects/xmake/godot/macos_accesskit_sdk.json'
DEFAULT = ROOT / 'build/godot-sdk/accesskit-0.22.3-macos-arm64'


def verify(destination, spec):
    for name, expected in spec['artifacts'].items():
        path = destination / name
        if path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to(destination.resolve()):
            raise ValueError('Missing/unsafe AccessKit SDK input: ' + name)
        if hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            raise ValueError('AccessKit SDK hash mismatch: ' + name)
    vendor_header = ROOT / 'Source/3rdParty/Godot/thirdparty/accesskit/include/accesskit.h'
    if vendor_header.read_bytes() != (destination / 'include/accesskit.h').read_bytes():
        raise ValueError('AccessKit SDK and vendored header differ')


def ensure(destination=DEFAULT, archive=None, spec_path=SPEC):
    spec = json.loads(spec_path.read_text())
    if destination.exists():
        verify(destination, spec)
        return destination
    destination.parent.mkdir(parents=True, exist_ok=True)
    archive = archive or destination.with_suffix('.zip')
    if not archive.exists():
        subprocess.run(['curl', '--fail', '--location', '--retry', '3', spec['source_url'], '-o', str(archive)], check=True)
    if hashlib.sha256(archive.read_bytes()).hexdigest() != spec['source_archive_sha256']:
        raise ValueError('AccessKit SDK archive hash mismatch')
    with tempfile.TemporaryDirectory(prefix='.accesskit-', dir=destination.parent) as temp:
        staging = Path(temp)
        with zipfile.ZipFile(archive) as package:
            for name in spec['artifacts']:
                target = staging / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(package.read(spec['archive_prefix'] + name))
        verify(staging, spec)
        shutil.copytree(staging, destination)
    return destination


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=DEFAULT)
    parser.add_argument('--archive', type=Path)
    parser.add_argument('--spec', type=Path, default=SPEC)
    args = parser.parse_args()
    print(ensure(args.output, args.archive, args.spec))
