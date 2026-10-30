#!/usr/bin/env python3
"""Run a specified macOS host/library pair without rebuilding either artifact."""
import argparse,hashlib,json,os,subprocess,sys,time
from pathlib import Path

root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--app',type=Path,required=True)
p.add_argument('--library',type=Path,required=True)
p.add_argument('--results',type=Path,required=True)
p.add_argument('--buffers',type=int,choices=[2,3,4],default=3)
p.add_argument('--host-mode',choices=['debug','release','unknown'],default='unknown',help='Must match the independently recorded host build configuration')
p.add_argument('--soak-frames',type=int,default=0,help='Additional animation frames, multiple of 300, maximum 216000; incompatible with resize')
p.add_argument('--min-runtime-seconds',type=float,default=0,help='Reject a run shorter than this measured process duration; never pad the test with an idle wait')
for flag in ('audio','controller','resize','aliases'):p.add_argument('--'+flag,action='store_true')
a=p.parse_args();assert sys.platform=='darwin'
assert 0<=a.soak_frames<=216000 and a.soak_frames%300==0
assert not (a.resize and a.soak_frames),'Run resize and long animation soak separately'
assert 0<=a.min_runtime_seconds<=240+a.soak_frames/30
app=a.app.resolve();library=a.library.resolve();out=a.results.resolve()
out.mkdir(parents=True,exist_ok=True);report=out/'verification.json';report.unlink(missing_ok=True)
binary=app/'Contents/MacOS/Dora';assert binary.is_file() and library.is_file()
# The explicit app is an isolated test host. Keep bundled user startup scripts
# untouched: the native opt-in test entry executes before ordinary app content.
symbols=subprocess.check_output(['nm','-gU',str(binary)],text=True)
assert '_dora_godot_node_test_main' in symbols,'Not an opt-in Godot test host'
subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True,capture_output=True)
project=root/'Tools/Godot/tests/project';(project/'.godot').mkdir(exist_ok=True)
(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
def digest(path):
    with path.open('rb') as file:return hashlib.file_digest(file,'sha256').hexdigest()
artifacts={'host':str(binary),'host_sha256':digest(binary),'library':str(library),'library_sha256':digest(library),'declared_host_mode':a.host_mode}
(out/'artifacts.json').write_text(json.dumps(artifacts,indent=2)+'\n')
env=os.environ.copy()
for key in list(env):
    if key.startswith('DORA_GODOT_TEST_') or key.startswith('DORA_GODOT_BINDING_'):env.pop(key)
env.update(DORA_GODOT_LIBRARY=str(library),DORA_GODOT_TEST_PROJECT=str(project),DORA_GODOT_TEST_OUTPUT=str(out),DORA_GODOT_TEST_BUFFERS=str(a.buffers),MTL_DEBUG_LAYER='1')
env['DORA_GODOT_TEST_SOAK_FRAMES']=str(a.soak_frames)
for flag in ('audio','controller','resize','aliases'):env['DORA_GODOT_TEST_'+flag.upper()]='1' if getattr(a,flag) else '0'
try:
    command=[sys.executable,str(root/'Tools/Godot/tests/runtime_abi.py'),'--library',str(library),'--backend','Metal','--output',str(out/'abi-preboot')]
    if a.audio:command.append('--require-audio')
    subprocess.run(command,check=True)
    started=time.monotonic()
    with (out/'run.log').open('w') as log:subprocess.run([str(binary)],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=240+a.soak_frames/30)
    runtime_seconds=time.monotonic()-started
    assert runtime_seconds>=a.min_runtime_seconds,f'Runtime {runtime_seconds:.3f}s is below required {a.min_runtime_seconds:.3f}s'
    command=[sys.executable,str(root/'Tools/Godot/tests/verify_macos.py'),'--results',str(out),'--buffers',str(a.buffers)]
    command+=['--soak-frames',str(a.soak_frames)]
    for flag in ('audio','controller','resize','aliases'):
        if getattr(a,flag):command.append('--'+flag)
    subprocess.run(command,check=True)
    assert artifacts['host_sha256']==digest(binary) and artifacts['library_sha256']==digest(library),'Artifacts changed during execution'
    result=json.loads(report.read_text());result['artifacts']=artifacts;result['runtime_seconds']=runtime_seconds
    result['required_min_runtime_seconds']=a.min_runtime_seconds
    report.write_text(json.dumps(result,indent=2)+'\n')
except BaseException:
    report.unlink(missing_ok=True);raise
