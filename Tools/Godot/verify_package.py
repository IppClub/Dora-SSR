#!/usr/bin/env python3
"""Verify an optional runtime package without loading executable code."""
import argparse,hashlib,json,re
from pathlib import Path,PurePosixPath
from package_manifest import SOURCE_SHA256,digest

def verify(package):
    package=Path(package).resolve()
    manifest=json.loads((package/'manifest.json').read_text(encoding='utf-8'))
    if manifest.get('package_format')!='dora-godot-runtime' or manifest.get('package_version')!=1:
        raise ValueError('Unsupported package format; rebuild the package with current tools')
    if manifest.get('bridge_abi')!=1 or manifest.get('godot_version')!='4.6-stable' or manifest.get('source_archive_sha256')!=SOURCE_SHA256:
        raise ValueError('Runtime version, bridge ABI or pinned source mismatch')
    architectures=manifest.get('architectures')
    if architectures is not None and (not isinstance(architectures,list) or not architectures
        or len(architectures)!=len(set(architectures)) or any(name not in {'arm64','arm32','x86_64','x64'} for name in architectures)):
        raise ValueError('Invalid runtime architecture inventory')
    graphics_backend=manifest.get('graphics_backend')
    if graphics_backend is not None and graphics_backend not in {'metal','egl','wgl','d3d12','webgl2'}:
        raise ValueError('Invalid graphics backend inventory')
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
    if graphics_backend == 'd3d12':
        notice = 'GODOT-NIR-THIRD-PARTY-NOTICES.txt'
        provenance = 'GODOT-NIR-PROVENANCE.json'
        if notice not in licenses or provenance not in artifacts:
            raise ValueError('D3D12 NIR dependency notices/provenance missing')
        dependency = json.loads((package / provenance).read_text(encoding='utf-8'))
        if (dependency.get('godot_nir_tag') != '25.3.1-1' or
                dependency.get('notice_sha256') != artifacts[notice]):
            raise ValueError('D3D12 NIR notice provenance mismatch')
        if dependency.get('schema') not in (1, 2, 3):
            raise ValueError('Unsupported D3D12 NIR notice schema')
        if dependency['schema'] >= 2:
            expected = {
                'mesa/src/util/drm_is_nouveau.h': '10e68930ffc4bd3919989b33ac4ec0c0174174c95d20c4ed1339143063e25e2a',
                'mesa/src/util/format/u_format.yaml': '8cc08434fdf13defe70ab210941ac18d04332d2148af680794fe8e7b6a14bacf',
            }
            history = dependency.get('historical_notice_sources')
            if not isinstance(history, list) or len(history) != len(expected):
                raise ValueError('D3D12 inherited notices missing or invalid')
            seen = set()
            body = (package / notice).read_text(encoding='utf-8')
            for entry in history:
                if not isinstance(entry, dict):
                    raise ValueError('D3D12 inherited notices missing or invalid')
                target = entry.get('applies_to')
                text = entry.get('notice_text')
                if (not isinstance(target, str) or target not in expected or target in seen or
                        not isinstance(text, str) or text not in body or
                        entry.get('notice_sha256') != expected[target] or
                        hashlib.sha256(text.encode()).hexdigest() != expected[target]):
                    raise ValueError('D3D12 inherited notices missing or invalid')
                seen.add(target)
    if graphics_backend == 'd3d12' and dependency['schema'] >= 3:
        from verify_nir_review import verify_review
        verify_review(dependency.get('license_review'), dependency)
    library=manifest.get('library')
    if not library and not {'dora-godot.js','dora-godot.wasm','runtime_bridge.mjs','shared_gl.mjs'}.issubset(artifacts):
        raise ValueError('Missing native library or complete Web runtime payload')
    if library and (library not in artifacts or manifest.get('library_sha256')!=artifacts[library]):
        raise ValueError('Library inventory mismatch')
    result = {'passed':True,'scope':'Package integrity/version/license inventory only; no library execution, signature verification or GPU acceptance',
        'package':str(package),'manifest_sha256':digest(package/'manifest.json'),'files':len(artifacts),
        'bytes':sum((package/name).stat().st_size for name in artifacts),'godot_version':manifest['godot_version'],'bridge_abi':manifest['bridge_abi'],
        'graphics_backend':graphics_backend}
    if graphics_backend == 'd3d12':
        result['nir_notice_schema'] = dependency['schema']
        result['nir_inherited_notice_sources'] = len(dependency.get('historical_notice_sources', []))
    return result

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
        args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(text,encoding='utf-8')
    print(text,end='')
