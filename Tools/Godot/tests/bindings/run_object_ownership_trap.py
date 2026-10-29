#!/usr/bin/env python3
"""Exercise actual Wasm3 Object ownership on initializer trap, without a language compiler or Godot boot."""
import argparse, hashlib, json, os, re, shutil, subprocess, sys
from pathlib import Path


def uint(value):
    result=bytearray()
    while True:
        byte=value&127;value>>=7;result.append(byte|(128 if value else 0))
        if not value:return bytes(result)


def name(text):
    data=text.encode();return uint(len(data))+data


def vector(items):return uint(len(items))+b''.join(items)
def section(kind,data):return bytes([kind])+uint(len(data))+data


def fixture():
    # (func _start (local i64) call node_new local.tee 0 call object_retain
    #  local.get 0 call object_retain local.get 0 call object_release unreachable)
    # Two owned references remain on trap. Exports match the real Dora Wasm ABI.
    types=[b'\x60\x00\x01\x7e',b'\x60\x01\x7e\x00',b'\x60\x00\x01\x7f',b'\x60\x01\x7f\x00',b'\x60\x00\x00']
    imports=[name('dora')+name(n)+b'\x00'+uint(t) for n,t in [('node_new',0),('object_retain',1),('object_release',1)]]
    exports=[name(n)+b'\x00'+uint(i) for i,n in enumerate(['dora_wasm_version','call_function','deref_function','_start'],3)]
    bodies=[b'\x00\x41'+uint((0<<16)|(5<<8)|11)+b'\x0b',b'\x00\x0b',b'\x00\x0b',b'\x01\x01\x7e\x10\x00\x22\x00\x10\x01\x20\x00\x10\x01\x20\x00\x10\x02\x00\x0b']
    return b'\x00asm\x01\x00\x00\x00'+section(1,vector(types))+section(2,vector(imports))+section(3,vector([uint(t) for t in [2,3,3,4]]))+section(7,vector(exports))+section(10,vector([uint(len(b))+b for b in bodies]))


p=argparse.ArgumentParser(description=__doc__);g=p.add_mutually_exclusive_group(required=True);g.add_argument('--app',type=Path);g.add_argument('--binary',type=Path)
p.add_argument('--asset-source',type=Path);p.add_argument('--output',type=Path,required=True);p.add_argument('--expect-object-leaks',type=int,default=0,help='Nonzero is historical failure reproduction only')
a=p.parse_args();root=Path(__file__).resolve().parents[4];out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
wasm=out/'trap.wasm';wasm.write_bytes(fixture())
if a.app:
    assert sys.platform=='darwin';app=out/'Dora.app';shutil.copytree(a.app.resolve(),app,symlinks=True);assets=app/'Contents/Resources';binary=app/'Contents/MacOS/Dora'
else:
    assert a.asset_source;assets=out/'assets';shutil.copytree(a.asset_source.resolve(),assets);binary=a.binary.resolve()
(assets/'Script/init.lua').write_text('return true\n')
if a.app:subprocess.run(['codesign','--force','--deep','--sign','-',str(app)],check=True,capture_output=True)
env=os.environ.copy()
for key in list(env):
    if key.startswith('DORA_GODOT_TEST_') or key=='DORA_GODOT_LIBRARY':env.pop(key)
env.update(DORA_GODOT_BINDING_WASM=str(wasm),DORA_GODOT_TEST_PROJECT=str(root/'Tools/Godot/tests/project'),DORA_GODOT_TEST_OUTPUT=str(out),DORA_GODOT_TEST_BUFFERS='3',MTL_DEBUG_LAYER='1',SDL_AUDIODRIVER='dummy')
command=[str(binary)]+([] if a.app else ['--asset',str(assets)])
artifacts={str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in [binary,wasm]}
with (out/'run.log').open('w') as log:result=subprocess.run(command,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=60)
log=(out/'run.log').read_text();leaks=sum(map(int,re.findall(r'(\d+) C\+\+ objects leaks',log)))
execution={'native_exit_code':result.returncode,'object_leaks':leaks,'artifacts':artifacts};(out/'execution.json').write_text(json.dumps(execution,indent=2)+'\n')
assert result.returncode==2,result.returncode
assert re.search(r'failed to load wasm module: .*due to: \[trap\] unreachable executed',log),log
assert 'Godot Engine v' not in log and 'BGFX LEAK:' not in log
assert leaks==a.expect_object_leaks,(leaks,a.expect_object_leaks)
errors=[line for line in log.splitlines() if re.search(r'\[(?:error|critical)\]|ERROR:|WARNING:',line)];assert len(errors)==1,errors
names=[n.strip() for group in re.findall(r'destroy: ([^\r\n]+)\.',log) for n in group.split(',')]
for n in ['WasmRuntime','Director','BGFXDora','Logger']:assert names.count(n)==1,(n,names)
assert names.index('WasmRuntime')<names.index('Director')<names.index('BGFXDora')<names.index('Logger')
assert all(hashlib.sha256(Path(n).read_bytes()).hexdigest()==s for n,s in artifacts.items())
report={'passed':True,'scope':'Actual Wasm3 plain Node exported-handle retain twice/release once then unreachable trap; no Godot boot or GPU sharing. Nonzero expected leaks is a negative baseline only.','failure_reproduction_only':a.expect_object_leaks!=0,**execution}
(out/'verification.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
