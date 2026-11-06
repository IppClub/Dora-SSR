#!/usr/bin/env python3
"""Stage an optional runtime with its upstream license notices and build manifest."""
import argparse, hashlib, json, shutil
from pathlib import Path
from package_manifest import seal
from verify_package import verify
parser=argparse.ArgumentParser()
parser.add_argument('--source',type=Path,required=True)
parser.add_argument('--library',type=Path,required=True)
parser.add_argument('--output',type=Path,required=True)
parser.add_argument('--library-name',help='Preserve a platform-required library basename, e.g. Android Java JNI loader')
parser.add_argument('--build-target',choices=['template_debug','template_release'],help='Actual Godot target used to produce this library')
parser.add_argument('--architecture',action='append',choices=['arm64','arm32','x86_64','x64'],default=[],help='Architecture slice present in the packaged library; repeat for universal libraries')
parser.add_argument('--graphics-backend',choices=['metal','egl','wgl','d3d12','webgl2'],help='Graphics backend implemented by this runtime package')
parser.add_argument('--static-accesskit-sdk',choices=['linux'],help='Include the pinned Linux static SDK notices and provenance')
parser.add_argument('--extra-directory',type=Path,action='append',default=[],help='Include a dependency tree under its basename, e.g. Android jni/')
parser.add_argument('--license-file',type=Path,action='append',default=[],help='Additional dependency notice, copied by basename and included in license inventory')
args=parser.parse_args()
assert args.library.is_file(),args.library
suffix=args.library.suffix
assert suffix in ('.dylib','.so','.dll'), 'Unsupported native runtime extension'
assert args.output.resolve()!=args.source.resolve()
args.output.mkdir(parents=True,exist_ok=True)
(args.output/'manifest.json').unlink(missing_ok=True)
name=args.library_name or ('libdora_godot'+suffix if suffix!='.dll' else 'dora_godot.dll')
assert Path(name).name==name and name.endswith(suffix) and name not in ('.','..'), 'Invalid library basename'
destination=args.output/name
shutil.copy2(args.library,destination)
for source,name in [('LICENSE.txt','GODOT-LICENSE.txt'),('COPYRIGHT.txt','GODOT-THIRD-PARTY-NOTICES.txt')]:
    shutil.copy2(args.source/source,args.output/name)
for directory in args.extra_directory:
    assert directory.is_dir() and directory.name not in ('.','..',''), 'Invalid dependency directory'
    assert not args.output.resolve().is_relative_to(directory.resolve()), 'Dependency tree contains output directory'
    shutil.copytree(directory,args.output/directory.name,dirs_exist_ok=True)
dependency_provenance = []
if args.graphics_backend == 'metal' and suffix == '.dylib':
    notices = Path(__file__).parent / 'licenses/accesskit-0.22.3'
    args.license_file.append(notices / 'GODOT-ACCESSKIT-NOTICES.txt')
    provenance = notices / 'GODOT-ACCESSKIT-PROVENANCE.json'
    shutil.copy2(provenance, args.output / provenance.name)
    dependency_provenance.append(provenance.name)
if args.static_accesskit_sdk == 'linux':
    assert args.graphics_backend == 'egl' and suffix == '.so', 'Linux AccessKit requires the EGL shared runtime'
    spec = Path(__file__).resolve().parents[2] / 'Projects/xmake/godot/linux_accesskit_sdk.json'
    provenance_name = 'GODOT-ACCESSKIT-PROVENANCE.json'
    assert provenance_name not in dependency_provenance
    shutil.copy2(spec, args.output / provenance_name)
    args.license_file.append(Path(__file__).parent / 'licenses/accesskit-0.22.3/GODOT-ACCESSKIT-NOTICES.txt')
    dependency_provenance.append(provenance_name)
if args.graphics_backend == 'd3d12':
    notices = Path(__file__).parent / 'licenses/nir-25.3.1-1'
    args.license_file.append(notices / 'GODOT-NIR-THIRD-PARTY-NOTICES.txt')
    provenance = notices / 'GODOT-NIR-PROVENANCE.json'
    assert json.loads(provenance.read_text()).get('schema') == 3, 'Regenerate current NIR notices before packaging D3D12'
    shutil.copy2(provenance, args.output / provenance.name)
    dependency_provenance.append(provenance.name)
reserved = {destination.name, "manifest.json", "GODOT-LICENSE.txt", "GODOT-THIRD-PARTY-NOTICES.txt", *dependency_provenance}
for notice in args.license_file:
    assert notice.is_file() and notice.name not in reserved, 'Notice missing or basename collides'
    reserved.add(notice.name)
    target = args.output/notice.name
    assert not target.is_symlink() and (not target.exists() or target.is_file()), 'Unsafe notice destination'
    shutil.copy2(notice,target)
manifest={'vendor_validation_script_sha256':hashlib.sha256(Path(__file__).with_name('vendor_source.py').read_bytes()).hexdigest(),
    'vendor_provenance_sha256':hashlib.sha256((args.source/'UPSTREAM.json').read_bytes()).hexdigest(),
    'upstream_commit':'ed1daf0bf001b61586d9930840f2f1394092c079',
    'particle_material_key_header_sha256':hashlib.sha256((args.source/'scene/resources/particle_process_material.h').read_bytes()).hexdigest(),
    'godot_version':'4.7.2-stable','bridge_abi':1,
    'source':'https://github.com/godotengine/godot/tree/4.7.2-stable',
    'source_archive_sha256':'e954996374cbd1cb5d72e0e3781cc537408e6ce73b010b12c6c2f308a820690a',
    'library':destination.name,'library_sha256':hashlib.sha256(destination.read_bytes()).hexdigest(),
    'licenses':['GODOT-LICENSE.txt','GODOT-THIRD-PARTY-NOTICES.txt',*[file.name for file in args.license_file]],
    'scope':'development runtime; platform output validation is recorded separately'}
metal_driver = args.source / 'drivers/metal/rendering_device_driver_metal.cpp'
if metal_driver.is_file():
    manifest['metal_driver_source_sha256'] = hashlib.sha256(metal_driver.read_bytes()).hexdigest()
    if '// Dora embedded Metal: no asynchronous library compilation past shutdown.' in metal_driver.read_text():
        manifest['embedded_metal_shader_loading'] = 'lazy'
if args.static_accesskit_sdk:manifest['static_accesskit_sdk']=args.static_accesskit_sdk
if dependency_provenance:manifest['dependency_provenance']=dependency_provenance
if args.build_target:manifest['build_target']=args.build_target
if args.architecture:manifest['architectures']=sorted(set(args.architecture))
if args.graphics_backend:manifest['graphics_backend']=args.graphics_backend
(args.output/'manifest.json').write_text(json.dumps(seal(args.output,manifest),indent=2)+'\n')
verify(args.output)
print(args.output.resolve())
