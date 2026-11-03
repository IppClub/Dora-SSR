#!/usr/bin/env python3
"""Verify the exact prebuilt NIR headers/archive used by the D3D12 xmake profile."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def verify(sdk, metadata_path):
    sdk = sdk.resolve()
    metadata = json.loads(metadata_path.read_text())
    if metadata['schema_version'] != 1:
        raise ValueError('Unsupported NIR SDK inventory schema')
    version = (sdk / 'godot-mesa/VERSION.info').read_text().strip()
    if version != metadata['mesa_version']:
        raise ValueError('NIR SDK version differs from the audited compiler profile: ' + version)
    for name, expected in metadata['files'].items():
        path = sdk / name
        if Path(name).is_absolute() or '..' in Path(name).parts or not path.resolve().is_relative_to(sdk):
            raise ValueError('SDK inventory path escapes its root: ' + name)
        with path.open('rb') as file:
            actual = hashlib.file_digest(file, 'sha256').hexdigest()
        if actual != expected:
            raise ValueError('NIR SDK input differs from the audited release: ' + name)
    return {
        'passed': True,
        'scope': 'Exact pinned NIR SDK file inventory only; not compiler, linker, license-completeness or GPU acceptance',
        'sdk': str(sdk),
        'godot_nir_tag': metadata['godot_nir_tag'],
        'mesa_version': version,
        'files': len(metadata['files']),
        'inventory_sha256': hashlib.sha256(metadata_path.read_bytes()).hexdigest(),
        'source_archive_sha256': metadata['source_archive_sha256'],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--sdk', type=Path, required=True)
    parser.add_argument('--metadata', type=Path)
    parser.add_argument('--architecture', choices=['x86_64','arm64'], default='x86_64')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    metadata = args.metadata
    if metadata is None:
        names = ['windows_d3d12_arm64_sdk.json'] if args.architecture == 'arm64' else [
            'windows_d3d12_sdk.json', 'windows_d3d12_x86_64_llvm_sdk.json']
        library = 'bin/libNIR.windows.' + args.architecture + '.a'
        actual = hashlib.sha256((args.sdk / library).read_bytes()).hexdigest()
        matches = [ROOT / 'Projects/xmake/godot' / name for name in names
                   if json.loads((ROOT / 'Projects/xmake/godot' / name).read_text())['files'].get(library) == actual]
        if len(matches) != 1:
            parser.error('NIR library does not match a pinned SDK for this architecture')
        metadata = matches[0]
    report = verify(args.sdk, metadata)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + '\n')
    print('Godot NIR SDK: PASS;', report['files'], 'exact audited inputs')


if __name__ == '__main__':
    main()
