#!/usr/bin/env python3
"""Verify an optional runtime package without loading executable code."""
import argparse,json,re
from pathlib import Path,PurePosixPath
from package_manifest import SOURCE_SHA256,digest

def verify(package):
    package=Path(package).resolve()
    manifest=json.loads((package/'manifest.json').read_text())
    if manifest.get('package_format')!='dora-godot-runtime' or manifest.get('package_version')!=1:
        raise ValueError('Unsupported package format; rebuild the package with current tools')
    if manifest.get('bridge_abi')!=1 or manifest.get('godot_version')!='4.6-stable' or manifest.get('source_archive_sha256')!=SOURCE_SHA256:
        raise ValueError('Runtime version, bridge ABI or pinned source mismatch')
    architectures=manifest.get('architectures')
    if architectures is not None and (not isinstance(architectures,list) or not architectures
        or len(architectures)!=len(set(architectures)) or any(name not in {'arm64','x86_64','x64'} for name in architectures)):
        raise ValueError('Invalid runtime architecture inventory')
    artifacts=manifest.get('artifacts')
    if not isinstance(artifacts,dict) or not artifacts:
        raise ValueError('Missing artifact inventory')
    for name,expected in artifacts.items():
        path=PurePosixPath(name)
        if path.is_absolute() or '..' in path.parts or '\\' in name or str(path)!=name:
            raise ValueError('Unsafe artifact path: '+name)
        file=package.joinpath(*path.parts)
        if not file.resolve().is_relative_to(package) or file.is_symlink() or not file.is_file():
            raise ValueError('Missing or unsafe artifact: '+name)
        if not isinstance(expected,str) or not re.fullmatch('[0-9a-f]{64}',expected) or digest(file)!=expected:
            raise ValueError('Artifact hash mismatch: '+name)
    actual={file.relative_to(package).as_posix() for file in package.rglob('*') if file.is_file() and file!=package/'manifest.json'}
    if actual!=set(artifacts):
        raise ValueError('Unlisted package files: '+str(sorted(actual-set(artifacts))))
    licenses=manifest.get('licenses',[])
    if not licenses or any(name not in artifacts for name in licenses):
        raise ValueError('License inventory missing or incomplete')
    library=manifest.get('library')
    if not library and not {'dora-godot.js','dora-godot.wasm','runtime_bridge.mjs','shared_gl.mjs'}.issubset(artifacts):
        raise ValueError('Missing native library or complete Web runtime payload')
    if library and (library not in artifacts or manifest.get('library_sha256')!=artifacts[library]):
        raise ValueError('Library inventory mismatch')
    return {'passed':True,'scope':'Package integrity/version/license inventory only; no library execution, signature verification or GPU acceptance',
        'package':str(package),'manifest_sha256':digest(package/'manifest.json'),'files':len(artifacts),
        'bytes':sum((package/name).stat().st_size for name in artifacts),'godot_version':manifest['godot_version'],'bridge_abi':manifest['bridge_abi']}

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('package',type=Path)
    parser.add_argument('--output',type=Path,help='Write a separate verification report outside the package')
    args=parser.parse_args()
    if args.output:
        if args.output.resolve().is_relative_to(args.package.resolve()):
            parser.error('Verification report must be outside the sealed package')
        args.output.unlink(missing_ok=True)
    result=verify(args.package);text=json.dumps(result,indent=2)+'\n'
    if args.output:
        args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(text)
    print(text,end='')
