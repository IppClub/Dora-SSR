#!/usr/bin/env python3
"""Run the isolated Dora/Godot app on an explicit iOS simulator, retaining evidence."""
import argparse,fcntl,hashlib,json,os,plistlib,re,shutil,subprocess,sys,time
from pathlib import Path
root=Path(__file__).resolve().parents[4];bundle='org.ippclub.dorassr.godotprototype.ios'
p=argparse.ArgumentParser();p.add_argument('--udid',required=True);p.add_argument('--app',type=Path,required=True);p.add_argument('--framework',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--case',choices=['lifecycle','timing','particles','output'],default='lifecycle');p.add_argument('--buffers',type=int,choices=[2,3,4],default=3)
p.add_argument('--expect-unsupported-gpu',action='store_true',help='Verify fail-fast hardware rejection; never reports shared-output acceptance')
p.add_argument('--dora-only',action='store_true',help='Render ordinary Dora content without creating GodotNode')
for flag in ('audio','audio-stall','resize','cancel-resize','aliases','reservation'):p.add_argument('--'+flag,action='store_true')
a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True);report=out/'verification.json';report.unlink(missing_ok=True)
assert not a.cancel_resize or a.resize
assert not a.audio_stall or a.audio
assert not (a.dora_only and a.expect_unsupported_gpu)
if a.expect_unsupported_gpu:assert a.case=='lifecycle' and not any(getattr(a,f) for f in ('audio','audio_stall','resize','cancel_resize','aliases','reservation'))
if a.case!='lifecycle':assert a.buffers==3 and not any(getattr(a,f) for f in ('audio','audio_stall','resize','cancel_resize','aliases','reservation'))
lockfile=root/'build/godot-ios/simulator-test.lock';lockfile.parent.mkdir(parents=True,exist_ok=True);lock=lockfile.open('w');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
def run(args,**kwargs):return subprocess.run(['xcrun','simctl']+args,check=True,timeout=180,**kwargs)
def capture(args):return subprocess.check_output(['xcrun','simctl']+args,text=True,timeout=30).strip()
def alive(pid):
 try:os.kill(pid,0);return True
 except ProcessLookupError:return False
state=json.loads(capture(['list','devices','-j']));device=next(d for group in state['devices'].values() for d in group if d['udid']==a.udid);assert device['state']=='Booted','Boot the explicit simulator first'
active_file=root/'build/godot-ios/active-run.json'
if active_file.exists():
 previous=json.loads(active_file.read_text());assert previous['udid']==a.udid,'Inspect previous simulator run before changing devices'
 if alive(previous['pid']):
  command=subprocess.check_output(['ps','-p',str(previous['pid']),'-o','command='],text=True).strip()
  if command.startswith(previous['executable']):
   assert Path(previous['finish']).is_file(),'Previous native test is unfinished; inspect its PID/logs instead of restarting'
   json.loads(Path(previous['finish']).read_text());run(['terminate',a.udid,bundle],capture_output=True)
with (a.app/'Info.plist').open('rb') as file:info=plistlib.load(file)
assert info['CFBundleIdentifier']==bundle,'Refusing another application package'
assert (a.app/'Script/init.lua').read_bytes()==b'return true\n','Not the isolated test assets'
framework_manifest=json.loads((a.framework.parent/'manifest.json').read_text());assert framework_manifest['passed'] and framework_manifest['device']=='simulator'
runtime_hash=hashlib.sha256((a.framework/'DoraGodot').read_bytes()).hexdigest();assert runtime_hash==framework_manifest['library_sha256']
staged=out/'Dora.app';assert not staged.exists(),'Use a fresh output directory to retain prior evidence'
shutil.copytree(a.app,staged);shutil.copytree(a.framework,staged/'Frameworks/DoraGodot.framework',dirs_exist_ok=True)
subprocess.run(['codesign','--force','--timestamp=none','--sign','-',str(staged)],check=True,capture_output=True)
subprocess.run(['codesign','--verify','--deep','--strict',str(staged)],check=True,capture_output=True)
assert hashlib.sha256((staged/'Frameworks/DoraGodot.framework/DoraGodot').read_bytes()).hexdigest()==runtime_hash
run(['install',a.udid,str(staged)],capture_output=True)
data=Path(capture(['get_app_container',a.udid,bundle,'data']));installed=Path(capture(['get_app_container',a.udid,bundle,'app']));executable=installed/info['CFBundleExecutable']
assert hashlib.sha256((installed/'Frameworks/DoraGodot.framework/DoraGodot').read_bytes()).hexdigest()==runtime_hash
runid=str(time.time_ns());project=data/'Documents'/('godot-project-'+runid);results=data/'Documents'/('godot-results-'+runid);results.mkdir(parents=True)
fixture={'lifecycle':'project','timing':'timing_project','particles':'particle_project','output':'output_startup_project'}[a.case]
shutil.copytree(root/'Tools/Godot/tests'/fixture,project,ignore=shutil.ignore_patterns('.godot'));(project/'.godot').mkdir();(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
options={'DORA_GODOT_TEST_PROJECT':str(project),'DORA_GODOT_TEST_OUTPUT':str(results),'DORA_GODOT_TEST_BUFFERS':str(a.buffers),'MTL_DEBUG_LAYER':'1'}
options['DORA_GODOT_TEST_DORA_ONLY']='1' if a.dora_only else '0'
for flag in ('audio','audio-stall','resize','cancel-resize','aliases','reservation'):options['DORA_GODOT_TEST_'+flag.upper().replace('-','_')]='1' if getattr(a,flag.replace('-','_')) else '0'
if a.case in ('timing','particles'):options['DORA_GODOT_TEST_TIMING']='1'
if a.case=='output':options.update(DORA_GODOT_TEST_OUTPUT_CHANGE='1',DORA_GODOT_TEST_OUTPUT_STARTUP='1')
env=os.environ.copy();env.update({'SIMCTL_CHILD_'+k:v for k,v in options.items()})
launch=run(['launch','--stdout='+str(out/'stdout.log'),'--stderr='+str(out/'stderr.log'),a.udid,bundle],capture_output=True,text=True,env=env)
(out/'launch.log').write_text(launch.stdout+launch.stderr);match=re.search(re.escape(bundle)+r':\s*(\d+)',launch.stdout);assert match,launch.stdout
pid=int(match[1]);finish=results/'native-finish.json';active={'udid':a.udid,'bundle':bundle,'pid':pid,'executable':str(executable),'finish':str(finish),'output':str(out),'state':'running'};active_file.write_text(json.dumps(active,indent=2)+'\n')
artifacts={'runtime_sha256':runtime_hash,'native_host_sha256':hashlib.sha256(executable.read_bytes()).hexdigest(),'udid':a.udid,'device':device,'case':a.case,'buffers':a.buffers}
(out/'artifacts.json').write_text(json.dumps(artifacts,indent=2)+'\n');finished=None
try:
 deadline=time.monotonic()+600
 while time.monotonic()<deadline:
  if finish.is_file():finished=json.loads(finish.read_text());break
  if not alive(pid):raise RuntimeError('Native process exited without a finish marker; inspect stdout/stderr logs')
  time.sleep(.5)
 if finished is None:raise TimeoutError('Native test not proven terminal; active-run.json records the original PID')
 time.sleep(1)
finally:
 text='\n'.join((out/name).read_text(errors='replace') if (out/name).exists() else '' for name in ('stdout.log','stderr.log'))
 (out/'run.log').write_text(text)
 if finished is not None:
  active.update(state='finished',native_finish=finished);active_file.write_text(json.dumps(active,indent=2)+'\n')
for path in results.iterdir():
 if path.is_file():shutil.copy2(path,out/path.name)
if a.dora_only:
 from PIL import Image
 log=(out/'run.log').read_text(errors='replace')
 assert finished=={'result':0,'captures':2},finished
 assert 'DORA_ONLY_TEST frames=180 captures=2 result=0' in log
 assert 'Godot Engine v4.6' not in log
 assert 'Metal API Validation Enabled' in log
 assert 'BGFX Shutdown complete.' in log
 centers=[]
 for name in ('dora-left.png','dora-right.png'):
  image=Image.open(out/name).convert('RGB');points=[(x,y) for y in range(image.height) for x in range(image.width) if (lambda c:c[1]>200 and c[0]<40 and c[2]<40)(image.getpixel((x,y)))]
  assert len(points)>1000,(name,len(points))
  centers.append([sum(v[i] for v in points)/len(points) for i in (0,1)])
 assert centers[1][0]-centers[0][0]>100,centers
 record={'passed':True,'scope':'Ordinary Dora DrawNode content in the isolated iOS test host; no GodotNode created; simulator only','gpu_shared_output_verified':False,'frames':180,'captures':2,'green_centers':centers,'native_host_sha256':artifacts['native_host_sha256'],'udid':a.udid}
 report.write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2));sys.exit(0)
if a.expect_unsupported_gpu:
 log=(out/'run.log').read_text(errors='replace')
 assert finished=={'result':2,'captures':0},finished
 assert 'Godot requires Apple4 Metal GPU capabilities' in log
 assert 'GODOT_CAPABILITY_QUERY matches=1 reason=Godot requires Apple4' in log,'Lua capability query did not match the native hardware rejection'
 assert 'Godot Engine v4.6' not in log,'Runtime was started before rejecting the unsupported GPU'
 assert 'destroy: Logger.' in log,'Host cleanup did not finish'
 record={'rejected_as_expected':True,'gpu_shared_output_verified':False,'scope':'Simulator hardware rejection before Godot runtime initialization; not a renderer/GPU-sharing pass','required_apple_family':4,'native_finish':finished,'runtime_library_sha256':runtime_hash,'native_host_sha256':artifacts['native_host_sha256'],'udid':a.udid}
 (out/'unsupported-gpu.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2));sys.exit(0)
assert finished['result']==0,finished
script='verify_timing.py' if a.case in ('timing','particles') else 'verify_output.py' if a.case=='output' else 'verify_macos.py'
command=[sys.executable,str(root/'Tools/Godot/tests'/script),'--results',str(out),'--platform','iOS Metal']
if a.case=='particles':command+=['--particles']
if a.case=='output':command+=['--startup']
if a.case=='lifecycle':
 command+=['--buffers',str(a.buffers)]
 for flag in ('audio','audio-stall','resize','cancel-resize','aliases','reservation'):
  if getattr(a,flag.replace('-','_')):command+=['--'+flag]
subprocess.run(command,check=True)
r=json.loads(report.read_text());r.update(ios_simulator=True,ios_udid=a.udid,ios_bundle=bundle,runtime_library_sha256=runtime_hash,native_host_sha256=artifacts['native_host_sha256']);report.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
