#!/usr/bin/env python3
"""Build and run real Wasm3 generated bindings against native asynchronous failures.

Execution records are not acceptance reports. Keep raw diagnostics for a
separate strict audit; these cases do not establish successful GPU sharing.
"""
import argparse,hashlib,json,os,shutil,subprocess,time
from pathlib import Path
from PIL import Image,ImageChops
root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ('app','library','source-root','output'):p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--language',choices=['Rust','Wa'],required=True)
p.add_argument('--case',choices=['missing-library','missing-scene'],required=True)
p.add_argument('--wa-import-overlay',type=Path,help='Explicit one-line Emit import fix over an older sealed Wa vendor tree')
a=p.parse_args();out=a.output.resolve();assert not out.exists();out.mkdir(parents=True)
def digest(path):
 with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def pixels(image):return image.get_flattened_data() if hasattr(image,'get_flattened_data') else image.getdata()
def run(command,name,cwd=None,env=None,timeout=300):
 with (out/(name+'.log')).open('w') as log:
  child=subprocess.Popen(command,cwd=cwd,env=env,stdout=log,stderr=subprocess.STDOUT)
  (out/(name+'-process.json')).write_text(json.dumps({'pid':child.pid,'command':command},indent=2)+'\n')
  result=child.wait(timeout=timeout)
  assert result==0,(name,result)
try:
 started=time.monotonic();source=a.app.resolve();binding_root=a.source_root.resolve()
 assert '_dora_godot_node_test_main' not in subprocess.check_output(['nm','-gU',str(source/'Contents/MacOS/Dora')],text=True)
 original={str(source/'Contents/MacOS/Dora'):digest(source/'Contents/MacOS/Dora'),str(a.library.resolve()):digest(a.library.resolve())}
 app=out/'Dora.app';shutil.copytree(source,app)
 project=out/'project';shutil.copytree(binding_root/'Tools/Godot/tests/project',project,ignore=shutil.ignore_patterns('.godot'))
 (project/'.godot').mkdir();(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
 scene='res://dora-intentionally-missing-binding-scene.tscn' if a.case=='missing-scene' else 'res://main.tscn'
 expected='Godot project startup failed' if a.case=='missing-scene' else 'dora-godot-intentionally-missing.dylib'
 stage=out/'module';(stage/'src').mkdir(parents=True)
 env=os.environ.copy()
 if a.language=='Rust':
  shutil.copy2(Path(__file__).with_name('async_error.rs'),stage/'src/main.rs')
  (stage/'Cargo.toml').write_text('[package]\nname="godot-binding-async-error"\nversion="0.0.0"\nedition="2021"\n[dependencies]\ndora-ssr={path='+json.dumps(str(binding_root/'Tools/dora-rust/dora'))+'}\n')
  env.update(DORA_GODOT_BINDING_PROJECT=str(project),DORA_GODOT_BINDING_ERROR_SCENE=scene,DORA_GODOT_BINDING_EXPECTED_ERROR=expected)
  run(['cargo','build','--manifest-path',str(stage/'Cargo.toml'),'--target','wasm32-wasip1'],'module-build',env=env)
  module=stage/'target/wasm32-wasip1/debug/godot-binding-async-error.wasm'
 else:
  shutil.copytree(binding_root/'Tools/dora-wa/vendor',stage/'vendor')
  if a.wa_import_overlay:
   target=stage/'vendor/dora/dora.wa';before=target.read_bytes();after=a.wa_import_overlay.read_bytes()
   assert before.count(b'#wa:import dora emit\n')==1
   assert after==before.replace(b'#wa:import dora emit\n',b'#wa:import dora dora_emit\n')
   target.write_bytes(after)
   (out/'wa-import-overlay.json').write_text(json.dumps({'source':str(a.wa_import_overlay.resolve()),'before_sha256':hashlib.sha256(before).hexdigest(),'after_sha256':digest(target),'scope':'Only the public Emit import name changes; host and other generated bindings unchanged'},indent=2)+'\n')
  (stage/'wa.mod').write_text('name="godot-binding-async-error"\npkgpath="godot_binding_async_error"\ntarget="wasi"\n')
  text=Path(__file__).with_name('async_error.wa').read_text()
  for name,value in [('PROJECT',str(project)),('SCENE',scene),('EXPECTED_ERROR',expected)]:text=text.replace('"@'+name+'@"',json.dumps(value))
  (stage/'src/main.wa').write_text(text)
  run(['wa','build','.'],'module-build',cwd=stage)
  module=stage/'output/godot-binding-async-error.wasm'
 assert module.read_bytes().startswith(b'\x00asm')
 script='''local D = require("Dora")
D.App.devMode = false
D.App.winSize = D.Size(1280,720)
assert(D.Director:beginGameCapture())
local green = D.DrawNode()
green:drawPolygon({D.Vec2(-40,-40),D.Vec2(40,-40),D.Vec2(40,40),D.Vec2(-40,40)},D.Color(0xff00ff00))
D.Director.ui:addChild(green,100)
local control, observed, age, phase, captured = D.Node(), false, 0, 0, 0
D.Director.ui:addChild(control)
control:gslot("GodotBindingAsyncError",function(language,message)
    assert(language == @LANGUAGE@ and message:find(@EXPECTED@,1,true))
    assert(not observed)
    observed = true
    print("GODOT_BINDING_ASYNC_HOST observed=1")
end)
assert(D.Wasm:executeMainFile(@MODULE@))
control:schedule(function(dt)
    assert(D.App.runningTime < 30, "Binding fault test timed out")
    if not observed then return false end
    age = age + dt
    if phase < 2 and age > (phase == 0 and 0.5 or 1.5) then
        phase = phase + 1
        green.x = (phase == 1 and -220 or 220) * D.View.size.width / 1280
        local path = @OUTPUT@ .. "/frame-" .. phase .. ".png"
        assert(D.Director:captureGameAsync(path,function(ok)
            assert(ok)
            captured = captured + 1
        end))
    end
    if captured == 2 and age > 2 then
        print("GODOT_BINDING_ASYNC_HOST complete=1 captures=2")
        D.App:shutdown()
        return true
    end
    return false
end)
'''
 for name,value in [('LANGUAGE',a.language),('EXPECTED',expected),('MODULE',str(module)),('OUTPUT',str(out))]:script=script.replace('@'+name+'@',json.dumps(value))
 startup=app/'Contents/Resources/Script/init.lua';startup.write_text(script);(out/'startup.lua').write_text(script)
 run(['codesign','--force','--deep','--timestamp=none','--sign','-',str(app)],'sign')
 run(['codesign','--verify','--deep','--strict',str(app)],'signature-verification')
 artifacts={str(path):digest(path) for path in (app/'Contents/MacOS/Dora',module,startup)}
 env={k:v for k,v in os.environ.items() if not k.startswith(('DORA_GODOT_','DORA_BUILD_'))}
 env.update(MTL_DEBUG_LAYER='1',SDL_AUDIODRIVER='dummy',DORA_GODOT_LIBRARY=str(a.library.resolve()) if a.case=='missing-scene' else str(out/'dora-godot-intentionally-missing.dylib'))
 run([str(app/'Contents/MacOS/Dora')],'run',cwd=root,env=env,timeout=60)
 raw=(out/'run.log').read_text();assert raw.count('GODOT_BINDING_ASYNC_HOST observed=1')==1
 assert raw.count('GODOT_BINDING_ASYNC_HOST complete=1 captures=2')==1
 images=[Image.open(out/f'frame-{i}.png').convert('RGB') for i in (1,2)];assert images[0].size==images[1].size==(1280,720)
 centers=[]
 for image in images:
  indices=[i%image.width for i,(r,g,b) in enumerate(pixels(image)) if g>220 and r<30 and b<30]
  assert len(indices)>500;centers.append(sum(indices)/len(indices))
 assert centers[1]-centers[0]>100
 changed=sum(max(pixel)>20 for pixel in pixels(ImageChops.difference(*images)));assert changed>1000
 assert all(digest(Path(name))==sha for name,sha in {**original,**artifacts}.items())
 (out/'execution.json').write_text(json.dumps({'executed':True,'scope':__doc__,'language':a.language,'case':a.case,'native_exit_code':0,'runtime_seconds':time.monotonic()-started,'expected_error_substring':expected,'artifacts':artifacts,'original':original,'dora_green_centers':centers,'changed_pixels':changed,'images_sha256':{f'frame-{i}.png':digest(out/f'frame-{i}.png') for i in (1,2)},'raw_log_sha256':digest(out/'run.log'),'binding_source':str(binding_root)},indent=2)+'\n')
 print('Actual binding asynchronous error execution recorded; strict diagnostic audit still required')
except BaseException as error:
 (out/'failure.json').write_text(json.dumps({'passed':False,'error':repr(error)},indent=2)+'\n');raise
