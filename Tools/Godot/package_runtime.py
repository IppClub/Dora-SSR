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
parser.add_argument('--build-target',choices=['template_debug','template_release'],help='Actual SCons target used to produce this library')
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
for notice in args.license_file:
    assert notice.is_file() and not (args.output/notice.name).exists(), 'Notice missing or basename collides'
    shutil.copy2(notice,args.output/notice.name)
manifest={'preparation_script_sha256':hashlib.sha256(Path(__file__).with_name('prepare.py').read_bytes()).hexdigest(),
    'particle_material_key_header_sha256':hashlib.sha256((args.source/'scene/resources/particle_process_material.h').read_bytes()).hexdigest(),
    'godot_version':'4.6-stable','bridge_abi':1,
    'source':'https://github.com/godotengine/godot/tree/4.6-stable',
    'source_archive_sha256':'b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0',
    'library':destination.name,'library_sha256':hashlib.sha256(destination.read_bytes()).hexdigest(),
    'licenses':['GODOT-LICENSE.txt','GODOT-THIRD-PARTY-NOTICES.txt',*[file.name for file in args.license_file]],
    'scope':'development runtime; platform output validation is recorded separately'}
metal_driver = args.source / 'drivers/metal/rendering_device_driver_metal.mm'
if metal_driver.is_file():
    manifest['metal_driver_source_sha256'] = hashlib.sha256(metal_driver.read_bytes()).hexdigest()
    if '// Dora embedded Metal: no asynchronous library compilation past shutdown.' in metal_driver.read_text():
        manifest['embedded_metal_shader_loading'] = 'lazy'
if args.build_target:manifest['build_target']=args.build_target
(args.output/'manifest.json').write_text(json.dumps(seal(args.output,manifest),indent=2)+'\n')
verify(args.output)
print(args.output.resolve())
