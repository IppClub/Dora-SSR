#!/usr/bin/env python3
"""Run an ordinary Linux binary and stop it with an active Godot node and every shared slot retained."""
import argparse,hashlib,json,os,shutil,subprocess,sys,time
from pathlib import Path
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--buffers',type=int,choices=[2,3,4],required=True)
for key in ('binary','library','output'): p.add_argument('--'+key,type=Path,required=True)
a=p.parse_args()
assert sys.platform.startswith('linux')
out=a.output.resolve();assert not out.exists(),'Use a fresh evidence directory';out.mkdir(parents=True)
source=a.binary.resolve();runtime=a.library.resolve()
def digest(path):
 with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
assert 'dora_godot_node_test_main' not in subprocess.check_output(['nm','-g','--defined-only',str(source)],text=True)
assets=out/'assets';shutil.copytree(root/'Assets',assets)
project=out/'project';shutil.copytree(root/'Tools/Godot/tests/web/node_project',project,ignore=shutil.ignore_patterns('.godot'))
(project/'.godot').mkdir();(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
text=(root/'Tools/Godot/tests/web/active_stop.lua').read_text().replace('640, 360, 3','640, 360, '+str(a.buffers)).replace('#aliases < 3','#aliases < '+str(a.buffers)).replace('#aliases == 3','#aliases == '+str(a.buffers)).replace('"buffers":3','"buffers":'+str(a.buffers))
text=text.replace('"/game/godot"',json.dumps(str(project))).replace('"/user/"',json.dumps(str(out)+'/')).replace('"/user/active-stop.json"',json.dumps(str(out/'active-stop.json')))
text=text.replace('local D = require("Dora")','local D = require("Dora")\nD.App.devMode = false\nD.App.winSize = D.Size(1280,720)')
text=text.replace('    frame = frame + 1','    local factor = D.View.size.width / 1280\n    node.scaleX, node.scaleY = factor, factor\n    for i, alias in ipairs(aliases) do\n        alias.scaleX, alias.scaleY = factor * 0.25, factor * 0.25\n        alias.x, alias.y = -480 * factor, (i - 2) * 110 * factor\n    end\n    frame = frame + 1')
text=text.replace('        if frame == 120 then print("DORA_WEB_ACTIVE_STOP_READY") end','        if frame == 120 then print("DORA_NATIVE_ACTIVE_STOP_READY") end\n        if D.Content:exist('+json.dumps(str(out/'stop-request'))+') then\n            assert(node.running)\n            print("DORA_NATIVE_ACTIVE_STOP_REQUESTED")\n            D.App:shutdown()\n            return true\n        end')
startup=assets/'Script/init.lua';startup.write_text(text);(out/'startup.lua').write_text(text)
binary=source;artifacts={str(binary):digest(binary),str(runtime):digest(runtime),str(startup):digest(startup)}
(out/'artifacts.json').write_text(json.dumps(artifacts,indent=2)+'\n')
env={k:v for k,v in os.environ.items() if not k.startswith(('DORA_GODOT_TEST_','DORA_GODOT_BINDING_'))};env.update(DORA_GODOT_LIBRARY=str(runtime),SDL_AUDIODRIVER='dummy',GODOT_SILENCE_ROOT_WARNING='1',DORA_GODOT_TEST_AUDIO='1')
started=time.monotonic()
with (out/'run.log').open('w') as log:
 process=subprocess.Popen([str(binary),'--asset',str(assets)],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT)
 (out/'process.json').write_text(json.dumps({'pid':process.pid,'binary':str(binary)},indent=2)+'\n')
 deadline=time.monotonic()+120
 while not (out/'active-stop.json').exists() and process.poll() is None and time.monotonic()<deadline:time.sleep(.1)
 if not (out/'active-stop.json').exists():
  # Preserve a live stalled process for diagnosis; do not kill or restart it.
  raise RuntimeError('No live-node marker; child status='+str(process.poll()))
 proof=json.loads((out/'active-stop.json').read_text());assert proof['running'] and proof['frame']>=120 and proof['aliases']==a.buffers
 time.sleep(.25);(out/'stop-request').write_text('public App.shutdown requested while node remains attached\n')
 result=process.wait(timeout=60)
assert result==0,result
raw=(out/'run.log').read_text();assert 'DORA_NATIVE_ACTIVE_STOP_REQUESTED' in raw and 'OpenGL API' in raw
assert not any(x in raw for x in ('[error]','ERROR:','BGFX LEAK:','C++ objects leaks','Metal Validation Error'))
assert all(digest(Path(p))==sha for p,sha in artifacts.items())
(out/'execution.json').write_text(json.dumps({'passed':True,'scope':'Actual ordinary Linux Release host, live node and aliases retained until public App.shutdown; no native test entry; sealed prebuilt LibGodot','buffers':a.buffers,'runtime_seconds':time.monotonic()-started,'native_exit_code':result,'live_at_stop':json.loads((out/'active-stop.json').read_text()),'artifacts':artifacts,'source_host_sha256':digest(source)},indent=2)+'\n');print('Linux live client stopped normally',a.buffers,flush=True)

subprocess.run([sys.executable,str(root/"Tools/Godot/tests/verify_active_stop_linux.py"),str(out),"--buffers",str(a.buffers)],check=True)
