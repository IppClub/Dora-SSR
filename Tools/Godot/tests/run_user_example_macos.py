#!/usr/bin/env python3
"""Exercise the actual user example host/projects in a copied ordinary macOS app."""
import argparse, hashlib, json, os, re, shutil, subprocess, sys
from pathlib import Path
from PIL import Image, ImageChops
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--prepared',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
assert sys.platform=='darwin';prepared=a.prepared.resolve();record=json.loads((prepared/'example.json').read_text());kind=record['example'];out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
for n,h in record['files_sha256'].items():assert hashlib.sha256(Path(n).read_bytes()).hexdigest()==h,n
app=out/'Dora.app';subprocess.run(['cp','-cR',str(prepared/'Dora.app'),str(app)],check=True);assets=app/'Contents/Resources'
script=Path(__file__).with_name('project_3d.lua').read_text();start=script.index('local node = assert(D.GodotNode(');end=script.index('local control =',start)
script=script[:start]+'local node = assert(require("Script.GodotExample"))\n'+script[end:]
script=script.replace('@OUTPUT@',json.dumps(str(out))).replace('DORA_PROJECT_3D','DORA_USER_EXAMPLE')
if kind=='2d':
 script=script.replace('if ticks == 180 then','if ticks == 155 then node:sendPointer(320,220,1,true);node:sendPointer(320,220,1,false) end\n    if ticks == 170 then capture("input") end\n    if ticks == 180 then').replace('captures == 6','captures == 7').replace('captures=6','captures=7')
(assets/'Script/init.lua').write_text(script);(out/'startup.lua').write_text(script)
subprocess.run(['codesign','--force','--deep','--timestamp=none','--sign','-',str(app)],check=True,capture_output=True)
inputs=[app/'Contents/MacOS/Dora',assets/'libdora_godot.dylib',assets/'Script/init.lua',assets/'Script/GodotExample.lua',*[f for f in (assets/'GodotProject').rglob('*') if f.is_file()]]
artifacts={str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in inputs};env={k:v for k,v in os.environ.items() if not k.startswith(('DORA_GODOT_','DORA_BUILD_'))};env['MTL_DEBUG_LAYER']='1'
with (out/'run.log').open('w') as log:result=subprocess.run([str(app/'Contents/MacOS/Dora')],env=env,cwd=root,stdout=log,stderr=subprocess.STDOUT,timeout=60)
execution={'native_exit_code':result.returncode,'example':kind,'artifacts':artifacts,'scope':__doc__};(out/'execution.json').write_text(json.dumps(execution,indent=2)+'\n');assert result.returncode==0
log=(out/'run.log').read_text();assert 'Godot example ready' in log;assert not re.search(r'\[(?:error|critical|warning)\]|ERROR:|WARNING:|C\+\+ objects leaks|BGFX LEAK:|Metal Validation Error',log),log
names=['animated-a','animated-b','paused-a','paused-b','resumed','removed']+(['input'] if kind=='2d' else [])
images={n:Image.open(out/(n+'.png')).convert('RGB') for n in names}
def changed(a,b):return sum(pixel!=(0,0,0) for pixel in ImageChops.difference(images[a],images[b]).getdata())
def green(n):return sum(g>60 and g>r*1.5 and g>b*1.1 for r,g,b in images[n].getdata())
assert green('animated-a')>300 and green('animated-b')>300
motion=changed('animated-a','animated-b');resume=changed('paused-b','resumed');assert motion>500 and resume>500,(motion,resume)
assert changed('paused-a','paused-b')==0
assert green('removed')==0
if kind=='2d':assert sum(r>150 and r>g*1.3 and g>b*1.3 for r,g,b in images['input'].getdata())>300
clients=re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)',log);readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
assert len(clients)==len(readers)==1
for row in clients:produced,completed,errors=map(int,row);assert produced==completed and errors==0
for row in readers:slots,frames,waits,signals,pending,completed,errors=map(int,row);assert slots==3 and frames==completed and pending==errors==0
life=[n.strip() for group in re.findall(r'destroy: ([^\r\n]+)\.',log) for n in group.split(',')];assert all(life.count(n)==1 for n in ['Director','BGFXDora','Logger']);assert life.index('Director')<life.index('BGFXDora')<life.index('Logger')
for n,h in artifacts.items():assert hashlib.sha256(Path(n).read_bytes()).hexdigest()==h,n
report={'passed':True,'example':kind,'captures':len(names),'animation_changed_pixels':motion,'resume_changed_pixels':resume,'paused_changed_pixels':0,'removed_green_pixels':0,'pointer_changes_color':kind=='2d','gpu_clients':clients,'gpu_readers':readers,'images_sha256':{n:hashlib.sha256((out/(n+'.png')).read_bytes()).hexdigest() for n in names},'scope':'Ordinary host executes unchanged user host.lua and staged editable project; native Metal rendering, pause/resume, 2D pointer, remove and full shutdown. QA-only startup controller is separate from the user example. No audio-content or other platform acceptance.'}
(out/'verification.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
