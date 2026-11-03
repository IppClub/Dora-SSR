#!/usr/bin/env python3
"""Build pinned standard-module Web LibGodot, separately from the Dora heap."""
import argparse,hashlib,json,os,re,shutil,subprocess,sys
from pathlib import Path
from package_manifest import seal
from verify_package import verify
root=Path(__file__).resolve().parents[2]
def digest(path):
 with path.open('rb') as file:return hashlib.file_digest(file,'sha256').hexdigest()
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--jobs',type=int,default=2)
p.add_argument('--target',choices=['template_debug','template_release'],default='template_debug')
p.add_argument('--builder',choices=['auto','xmake'],default='xmake',help='Native xmake; auto is a compatibility alias')
p.add_argument('--xmake',default=os.environ.get('DORA_GODOT_XMAKE','xmake'))
p.add_argument('--build-dir',type=Path,help='Independent outputs; defaults to build/godot-web or build/godot-web/release')
a=p.parse_args();assert 1<=a.jobs<=16
a.builder='xmake'
mode='release' if a.target=='template_release' else 'debug'
build=(a.build_dir or (root/'build/godot-web' if a.target=='template_debug' else root/'build/godot-web/release')).resolve();build.mkdir(parents=True,exist_ok=True)
expected='b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0'
source=root/'Source/3rdParty/Godot'
for script in ('prepare.py','prepare_web.py'):subprocess.run(['python3',str(root/'Tools/Godot'/script),str(source)],check=True)
env=os.environ.copy();env['BINARYEN_CORES']=str(a.jobs)
toolchain=None
migration_inputs={}
if a.builder=='xmake':
 migration_inputs={name:digest(root/name) for name in (
  'Projects/xmake/godot/web_wasm32_sources.lua','Projects/xmake/godot/web_link.json',
  'Projects/xmake/godot/template_release_web.json','Projects/xmake/godot/targets.lua',
  'Tools/Godot/generate_xmake_sources.py', 'xmake.lua', 'Projects/xmake/options.lua', 'Projects/xmake/dependencies/host_tools.lua')}
 xmake=shutil.which(a.xmake)
 if not xmake:p.error('Configured xmake executable is missing: '+a.xmake)
 version=re.search(r'xmake\s+v(\d+)\.',subprocess.check_output([xmake,'--version'],text=True))
 if not version or int(version[1])<3:p.error('Godot xmake migration requires xmake 3.x or newer')
 env['XMAKE_CONFIGDIR']=str(build/'xmake-config')
 commands=[[xmake,'f','-P',str(root),'-c','-p','wasm','-a','wasm32','-m',mode,'--dora_godot_runtime=y','--dora_godot_standalone=y','--ccache=n','-y'],
           [xmake,'l','-P',str(root),'Projects/xmake/godot/toolchain_info.lua',str(build/'toolchain.json')],
           [xmake,'build','-P',str(root),'-j'+str(a.jobs),'godot-runtime']]
report=build/'compilation.json';report.unlink(missing_ok=True)
(build/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
with (build/'build.log').open('w') as log:
 for command in commands:
  result=subprocess.run(command,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT)
  if result.returncode:break
if result.returncode:raise SystemExit(result.returncode)
assert all(digest(root/name)==expected for name,expected in migration_inputs.items()),'Godot xmake inputs changed during the build'
if a.builder=='xmake':
 toolchain=json.loads((build/'toolchain.json').read_text())
 assert toolchain['plat']=='wasm' and toolchain['arch']=='wasm32',toolchain
 assert 'Emscripten' in toolchain['linker_version'],toolchain
 js=[Path(toolchain['targetfile'])]
 if not js[0].is_absolute():js=[root/js[0]]
 compiler_version=toolchain['linker_version'].splitlines()[0]
assert len(js)==1 and js[0].is_file(),js
wasm=js[0].with_suffix('.wasm');assert wasm.is_file()
package=build/'package';package.mkdir(exist_ok=True)
for file in (js[0],wasm):shutil.copy2(file,package/('dora-godot'+file.suffix))
for name in ('LICENSE.txt','COPYRIGHT.txt','AUTHORS.md'):shutil.copy2(source/name,package/name)
for name in ('shared_gl','runtime_bridge'):shutil.copy2(root/'Tools/Godot/web'/(name+'.js'),package/(name+'.mjs'))
r={'passed':True,'scope':'Web standard-module LibGodot compilation only; no browser runtime or shared GPU output acceptance','source_archive_sha256':expected,'build_target':a.target,'optimization':'speed' if a.target=='template_release' else 'none','builder':a.builder,'command':commands[-1],'commands':commands,'toolchain':toolchain,'emscripten':compiler_version,'graphics_backend':'webgl2','vendor_validation_sha256':digest(root/'Tools/Godot/vendor_source.py'),'vendored_sources_sha256':{str(file.relative_to(source)):digest(file) for file in [source/'platform/web/SCsub',source/'platform/web/detect.py',source/'platform/web/audio_driver_web.cpp',*sorted((source/'modules/dora_bridge').rglob('*.cpp')),*sorted((source/'modules/dora_bridge').rglob('*.h')),*sorted((source/'modules/dora_bridge').rglob('*.inc'))]},'artifacts':{file.name:digest(file) for file in package.iterdir() if file.is_file() and file.name!='manifest.json'}}
r['licenses']=['LICENSE.txt','COPYRIGHT.txt','AUTHORS.md'];seal(package,r)
r['migration_inputs_sha256']=migration_inputs
r['profiling_functions']=a.builder=='xmake' and env.get('DORA_GODOT_WEB_PROFILE_FUNCTIONS')=='1'
report.write_text(json.dumps(r,indent=2)+'\n');(package/'manifest.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
verify(package)
