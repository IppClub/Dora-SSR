#!/usr/bin/env python3
"""Build pinned standard-module Web LibGodot, separately from the Dora heap."""
import argparse,hashlib,json,shutil,subprocess,sys
from pathlib import Path
from package_manifest import seal
from verify_package import verify
root=Path(__file__).resolve().parents[2]
def digest(path):
 with path.open('rb') as file:return hashlib.file_digest(file,'sha256').hexdigest()
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--jobs',type=int,default=2)
p.add_argument('--target',choices=['template_debug','template_release'],default='template_debug')
p.add_argument('--build-dir',type=Path,help='Independent outputs; defaults to build/godot-web or build/godot-web/release')
a=p.parse_args();assert 1<=a.jobs<=16
build=(a.build_dir or (root/'build/godot-web' if a.target=='template_debug' else root/'build/godot-web/release')).resolve();build.mkdir(parents=True,exist_ok=True)
expected='b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0'
source=root/'Source/3rdParty/Godot'
for script in ('prepare.py','prepare_web.py'):subprocess.run(['python3',str(root/'Tools/Godot'/script),str(source)],check=True)
venv=root/'build/godot-runtime/venv';scons=venv/'bin/scons'
if not scons.is_file():
 subprocess.run([sys.executable,'-m','venv',str(venv)],check=True)
 subprocess.run([str(venv/'bin/pip'),'install','scons==4.11.1'],check=True)
command=[str(scons),'platform=web','arch=wasm32','target='+a.target,'library_type=static_library','disable_path_overrides=no','threads=yes','proxy_to_pthread=no','dlink_enabled=no','opengl3=yes','vulkan=no','optimize='+('speed' if a.target=='template_release' else 'none'),'debug_symbols=no','lto=none','-j'+str(a.jobs)]
report=build/'compilation.json';report.unlink(missing_ok=True)
with (build/'build.log').open('w') as log:result=subprocess.run(command,cwd=source,stdout=log,stderr=subprocess.STDOUT)
if result.returncode:raise SystemExit(result.returncode)
js=list((source/'bin').glob('godot.web.'+a.target+'*.js'));js=[f for f in js if not f.name.endswith(('.engine.js','.wrapped.js'))];assert len(js)==1,js
wasm=js[0].with_suffix('.wasm');assert wasm.is_file()
package=build/'package';package.mkdir(exist_ok=True)
for file in (js[0],wasm):shutil.copy2(file,package/('dora-godot'+file.suffix))
for name in ('LICENSE.txt','COPYRIGHT.txt','AUTHORS.md'):shutil.copy2(source/name,package/name)
for name in ('shared_gl','runtime_bridge'):shutil.copy2(root/'Tools/Godot/web'/(name+'.js'),package/(name+'.mjs'))
r={'passed':True,'scope':'Web standard-module LibGodot compilation only; no browser runtime or shared GPU output acceptance','source_archive_sha256':expected,'build_target':a.target,'optimization':'speed' if a.target=='template_release' else 'none','command':command,'emscripten':subprocess.check_output(['em++','--version'],text=True).splitlines()[0],'vendor_validation_sha256':digest(root/'Tools/Godot/vendor_source.py'),'vendored_sources_sha256':{str(file.relative_to(source)):digest(file) for file in [source/'platform/web/SCsub',source/'platform/web/detect.py',source/'platform/web/audio_driver_web.cpp',*sorted((source/'modules/dora_bridge').rglob('*.cpp')),*sorted((source/'modules/dora_bridge').rglob('*.h')),*sorted((source/'modules/dora_bridge').rglob('*.inc'))]},'artifacts':{file.name:digest(file) for file in package.iterdir() if file.is_file() and file.name!='manifest.json'}}
r['licenses']=['LICENSE.txt','COPYRIGHT.txt','AUTHORS.md'];seal(package,r)
report.write_text(json.dumps(r,indent=2)+'\n');(package/'manifest.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
verify(package)
