#!/usr/bin/env python3
"""Repeated real GodotNode clients and post-close GPU resource observations."""
import argparse,hashlib,json,os,subprocess,time
from pathlib import Path
from verify_cycles import verify
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__)
for name in ('app','library','output'):p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--cycles',type=int,default=100)
p.add_argument('--buffers',type=int,choices=[2,3,4],default=3)
p.add_argument('--warmup',type=int,default=5)
p.add_argument('--max-metal-growth-bytes',type=int,default=0)
a=p.parse_args();assert 2<=a.cycles<=1000 and 1<=a.warmup<a.cycles and a.max_metal_growth_bytes>=0
out=a.output.resolve();assert not out.exists(),'Use a fresh output directory'
out.mkdir(parents=True);report=out/'verification.json'
binary=a.app.resolve()/'Contents/MacOS/Dora';library=a.library.resolve()
subprocess.run(['codesign','--verify','--deep','--strict',str(a.app.resolve())],check=True,capture_output=True)
def digest(path):
    with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
artifacts={str(path):digest(path) for path in (binary,library)}
(out/'artifacts.json').write_text(json.dumps(artifacts,indent=2)+'\n')
env=os.environ.copy()
for key in list(env):
    if key.startswith(('DORA_GODOT_TEST_','DORA_GODOT_BINDING_')):env.pop(key)
env.update(DORA_GODOT_LIBRARY=str(library),DORA_GODOT_TEST_PROJECT=str(root/'Tools/Godot/tests/project'),DORA_GODOT_TEST_OUTPUT=str(out),DORA_GODOT_TEST_CYCLES=str(a.cycles),DORA_GODOT_TEST_BUFFERS=str(a.buffers),DORA_GODOT_TEST_AUDIO='1',MTL_DEBUG_LAYER='1')
try:
    started=time.monotonic()
    with (out/'run.log').open('w') as log:subprocess.run([str(binary)],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=120+a.cycles*10)
    duration=time.monotonic()-started
    result=verify(out,a.cycles,a.buffers,a.warmup,'macOS Metal',a.max_metal_growth_bytes)
    assert all(digest(Path(path))==sha for path,sha in artifacts.items()),'Artifacts changed during execution'
    result.update(runtime_seconds=duration,artifacts=artifacts)
    report.write_text(json.dumps(result,indent=2)+'\n')
    print('Repeated client GPU/resource acceptance: PASS',flush=True)
except BaseException as error:
    report.unlink(missing_ok=True)
    (out/'failure.json').write_text(json.dumps({'passed':False,'type':type(error).__name__,'error':str(error)},indent=2)+'\n');raise
