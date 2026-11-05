#!/usr/bin/env python3
"""Fetch and verify the pinned x64 GCC NIR SDK used by production D3D12."""
import hashlib
import json
from pathlib import Path
import subprocess
import zipfile
from verify_d3d12_sdk import verify

ROOT = Path(__file__).resolve().parents[2]

def ensure_sdk():
    metadata = ROOT / 'Projects/xmake/godot/windows_d3d12_sdk.json'
    spec = json.loads(metadata.read_text())
    destination = ROOT / 'build/godot-sdk/nir-25.3.1-1-x64-gcc'
    if (destination / 'bin/libNIR.windows.x86_64.a').is_file():
        verify(destination, metadata)
        return destination
    destination.parent.mkdir(parents=True, exist_ok=True)
    archive = destination.with_name(destination.name + '.zip')
    subprocess.run(['curl', '--fail', '--location', '--retry', '3', spec['source_url'], '-o', str(archive)], check=True)
    if hashlib.sha256(archive.read_bytes()).hexdigest() != spec['source_archive_sha256']:
        raise ValueError('NIR SDK archive hash mismatch')
    with zipfile.ZipFile(archive) as package:
        for entry in package.infolist():
            if not (destination / entry.filename).resolve().is_relative_to(destination.resolve()):
                raise ValueError('NIR SDK archive path escapes destination')
        package.extractall(destination)
    verify(destination, metadata)
    return destination

if __name__ == '__main__':
    print(ensure_sdk())
