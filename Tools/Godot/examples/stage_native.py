#!/usr/bin/env python3
"""Prepare a runnable native Godot example beside an existing ordinary Dora host."""
import argparse, hashlib, json, shutil, subprocess, sys
from pathlib import Path
root=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(root/'Tools/Godot'))
from verify_package import verify
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--example',choices=['2d','3d'],required=True);p.add_argument('--runtime-package',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
g=p.add_mutually_exclusive_group(required=True);g.add_argument('--app',type=Path);g.add_argument('--binary',type=Path);p.add_argument('--asset-source',type=Path)
a=p.parse_args();package=a.runtime_package.resolve();verify(package);manifest=json.loads((package/'manifest.json').read_text());out=a.output.resolve();assert not out.exists(),'Use a new output directory'
if a.app:
    assert sys.platform=='darwin';binary=a.app.resolve()/'Contents/MacOS/Dora';assert binary.is_file()
else:
    assert a.asset_source and a.asset_source.is_dir();binary=a.binary.resolve();assert binary.is_file()
assert b'GODOT_CAPABILITY_QUERY matches=' not in binary.read_bytes(),'Use an ordinary host, not the opt-in native test host'
out.mkdir(parents=True)
if a.app:
    app=out/'Dora.app';shutil.copytree(a.app.resolve(),app,symlinks=True);assets=app/'Contents/Resources';binary=app/'Contents/MacOS/Dora'
else:
    assets=out/'assets';shutil.copytree(a.asset_source.resolve(),assets)
project=assets/'GodotProject';assert not project.exists(),'Existing host assets already contain GodotProject'
shutil.copytree(Path(__file__).with_name(a.example),project,ignore=shutil.ignore_patterns('.godot'))
(project/'.godot').mkdir();(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
shutil.copy2(Path(__file__).with_name('host.lua'),assets/'Script/GodotExample.lua')
(assets/'Script/init.lua').write_text('return require("Script.GodotExample")\n')
shutil.copy2(package/manifest['library'],assets/manifest['library'])
notices=assets/'GodotNotices';notices.mkdir(exist_ok=True)
for name in manifest['licenses']:
    target=notices/name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(package/name,target)
if a.app:
    subprocess.run(['codesign','--force','--deep','--sign','-',str(app)],check=True,capture_output=True)
    subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True,capture_output=True)
command=[str(binary)]+([] if a.app else ['--asset',str(assets)])
inputs=[binary,assets/'Script/init.lua',assets/'Script/GodotExample.lua',assets/manifest['library'],*project.rglob('*'),*notices.rglob('*')]
record={'prepared':True,'example':a.example,'command':command,'asset_root':str(assets),'runtime_manifest_sha256':hashlib.sha256((package/'manifest.json').read_bytes()).hexdigest(),'files_sha256':{str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in inputs if f.is_file()},'scope':'Runnable example staging with an existing ordinary host. macOS copy is locally ad-hoc signed. Linux/Windows binary remains at its existing location with its dependencies. Not a signed distribution installer or runtime/GPU acceptance.'}
(out/'example.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps({'prepared':True,'example':a.example,'command':command},indent=2))
