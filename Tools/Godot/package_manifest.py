"""Versioned, content-addressed deployment inventory (not runtime acceptance)."""
import hashlib
from pathlib import Path

SOURCE_SHA256='b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0'

def digest(path):
    with Path(path).open('rb') as file:
        return hashlib.file_digest(file,'sha256').hexdigest()

def seal(package,manifest):
    package=Path(package)
    identity=dict(package_format='dora-godot-runtime',package_version=1,
        godot_version='4.6-stable',bridge_abi=1,source_archive_sha256=SOURCE_SHA256)
    for key,expected in identity.items():
        if key in manifest and manifest[key]!=expected:
            raise ValueError('Cannot seal incompatible identity: '+key)
    manifest.update(identity)
    manifest['artifacts']={file.relative_to(package).as_posix():digest(file)
        for file in sorted(package.rglob('*')) if file.is_file() and file!=package/'manifest.json'}
    return manifest
