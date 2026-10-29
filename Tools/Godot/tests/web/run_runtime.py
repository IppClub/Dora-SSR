#!/usr/bin/env python3
"""Run the real Web LibGodot against an independent WASM GL consumer."""
import argparse,hashlib,json,os,shutil,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,default=root/'build/godot-web/runtime-test')
p.add_argument('--buffers',type=int,choices=[2,3,4],default=3);p.add_argument('--pack',action='store_true')
p.add_argument('--godot-editor',default=shutil.which('godot') or '/Applications/Godot.app/Contents/MacOS/Godot')
a=p.parse_args();output=a.output.resolve();output.mkdir(parents=True,exist_ok=True)
report=output/'verification.json';report.unlink(missing_ok=True)
source=root/'Tools/Godot/tests/web';package=root/'build/godot-web/package'
assert (root/'build/godot-web/compilation.json').is_file(),'Build the real Web runtime first'
for name in ('dora-godot.js','dora-godot.wasm'):shutil.copy2(package/name,output/name)
shutil.copy2(source/'runtime.html',output/'index.html');shutil.copytree(source/'project',output/'project',dirs_exist_ok=True)
shutil.copy2(root/'Tools/Godot/web/shared_gl.js',output/'shared_gl.mjs')
shutil.copy2(root/'Tools/Godot/web/runtime_bridge.js',output/'runtime_bridge.mjs')
command=['em++',str(source/'gl_module.cpp'),'-O0','-std=c++17','-sMODULARIZE=1','-sEXPORT_NAME=createGLProbe','-sALLOW_MEMORY_GROWTH=1','-sMIN_WEBGL_VERSION=2','-sMAX_WEBGL_VERSION=2','-sEXPORTED_RUNTIME_METHODS=GL,HEAPU8','-sENVIRONMENT=web','--no-entry','-o',str(output/'godot-web-probe.js')]
subprocess.run(command,check=True,cwd=root)
if a.pack:
 with (output/'pack.log').open('w') as log:
  subprocess.run([a.godot_editor,'--headless','--path',str(output/'project'),'--script',str(source/'pack_project.gd'),'--',str(output/'project'),str(output/'project.pck')],stdout=log,stderr=subprocess.STDOUT,check=True)
 assert (output/'project.pck').is_file()
environment=os.environ.copy();environment['DORA_BROWSER_QUERY']='?buffers='+str(a.buffers)+('&pack=1' if a.pack else '')
result=subprocess.run(['node',str(source/'run_browser.cjs'),str(output)],cwd=root,env=environment)
if report.is_file():
 data=json.loads(report.read_text());data['sha256']={str(file.relative_to(output)):hashlib.sha256(file.read_bytes()).hexdigest() for file in output.rglob('*') if file.is_file() and file!=report}
 data['scope']='Real Godot Web runtime to independent WASM GL shader only; not Dora GodotNode acceptance'
 data['runtime_build']=json.loads((root/'build/godot-web/compilation.json').read_text())
 report.write_text(json.dumps(data,indent=2)+'\n')
raise SystemExit(result.returncode)
