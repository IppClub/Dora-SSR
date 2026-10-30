#!/usr/bin/env python3
"""Install only the task's opt-in APK and collect actual in-process node output.

A timeout does not stop/restart the native test. Its PID and output directory
remain in active-run.json for inspection. A new invocation refuses to replace
an earlier native test still running without a finish marker.
"""
import argparse,fcntl,hashlib,io,json,os,re,shutil,subprocess,sys,tarfile,tempfile,time,zipfile
from pathlib import Path
root=Path(__file__).resolve().parents[4];package='org.ippclub.dorassr.godotprototype'
p=argparse.ArgumentParser();p.add_argument('--serial',required=True);p.add_argument('--sdk',type=Path,required=True);p.add_argument('--apk',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--case',choices=['lifecycle','timing','particles','output'],default='lifecycle')
p.add_argument('--buffers',type=int,choices=[2,3,4],default=3)
p.add_argument('--runtime-package',type=Path,default=root/'build/godot-android/package',help='Exact sealed runtime package embedded in the APK')
p.add_argument('--background',action='store_true',help='Send the owned activity Home after animation sampling, then resume the same native process')
for flag in ('audio','audio-stall','resize','cancel-resize','aliases','reservation','ime','controller'):p.add_argument('--'+flag,action='store_true')
a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True);report=out/'verification.json';report.unlink(missing_ok=True)
assert not a.cancel_resize or a.resize
assert not a.audio_stall or a.audio
if a.case!='lifecycle':
 assert a.buffers==3 and not any(getattr(a,flag) for flag in ('audio','audio_stall','resize','cancel_resize','aliases','reservation','ime','controller','background')), 'Extended lifecycle flags require --case lifecycle'
adb=[str(a.sdk/'platform-tools/adb'),'-s',a.serial]
def run(args,**kw):return subprocess.run(adb+args,check=True,timeout=60,**kw)
def capture(args):return subprocess.check_output(adb+args,timeout=30).decode('utf8',errors='replace').strip()
lockfile=root/'build/godot-android/android-test.lock';lockfile.parent.mkdir(parents=True,exist_ok=True);lock=lockfile.open('w');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
active_file=root/'build/godot-android/active-run.json'
probe=subprocess.run(adb+['shell','pidof',package],capture_output=True,timeout=30)
pid=probe.stdout.decode('utf8',errors='replace').strip() if probe.returncode==0 else ''
if pid:
 assert active_file.exists(),'Prototype process exists without this driver ownership record'
 previous=json.loads(active_file.read_text());assert previous['serial']==a.serial
 probe=subprocess.run(adb+['shell','run-as',package,'cat',previous['finish']],capture_output=True,timeout=30)
 assert probe.returncode==0,'Previous native test has no finish marker; inspect it instead of restarting'
 json.loads(probe.stdout)
 run(['shell','am','force-stop',package],capture_output=True)
aapt=a.sdk/'build-tools/34.0.0/aapt';assert aapt.is_file() and a.apk.is_file()
badging=subprocess.check_output([str(aapt),'dump','badging',str(a.apk)],text=True)
assert re.search(r"package: name='"+re.escape(package)+r"'",badging), 'Refusing to install another app'
assert 'application-debuggable' in badging, 'The isolated test APK needs run-as access for its native evidence'
activity=re.search(r"launchable-activity: name='([^']+)'",badging);assert activity
with zipfile.ZipFile(a.apk) as apk:
 assert apk.read('assets/Script/init.lua')==b'return true\n','Not the isolated test asset package'
 runtime=apk.read('lib/arm64-v8a/libgodot_android.so');host=apk.read('lib/arm64-v8a/libmain.so')
sys.path.insert(0,str(root/'Tools/Godot'))
from verify_package import verify as verify_runtime_package
verify_runtime_package(a.runtime_package)
assert hashlib.sha256(runtime).hexdigest()==json.loads((a.runtime_package/'manifest.json').read_text())['library_sha256'],'APK does not contain the tested source-built runtime'
(out/'artifacts.json').write_text(json.dumps({'apk_sha256':hashlib.sha256(a.apk.read_bytes()).hexdigest(),'runtime_sha256':hashlib.sha256(runtime).hexdigest(),'native_host_sha256':hashlib.sha256(host).hexdigest(),'serial':a.serial,'case':a.case,'isolated_test_apk_debuggable':True,'runtime_package':str(a.runtime_package.resolve())},indent=2)+'\n')
with (out/'install.log').open('w') as log:run(['install','-r',str(a.apk.resolve())],stdout=log,stderr=subprocess.STDOUT)
base=capture(['shell','run-as',package,'pwd']);assert base.startswith('/data/user/') or base.startswith('/data/data/')
runid=str(time.time_ns());project_name='godot-project-'+runid;results_name='godot-results-'+runid
remote_project=base+'/files/'+project_name;remote_results=base+'/files/'+results_name
run(['shell','run-as',package,'mkdir','-p','files/'+project_name,'files/'+results_name],capture_output=True)
fixture={'lifecycle':'project','timing':'timing_project','particles':'particle_project','output':'output_startup_project'}[a.case]
with tempfile.TemporaryDirectory(prefix='dora-android-project-') as staging:
 staged=Path(staging)/'project';shutil.copytree(root/'Tools/Godot/tests'/fixture,staged,ignore=shutil.ignore_patterns('.godot'))
 (staged/'.godot').mkdir();(staged/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
 stream=io.BytesIO()
 with tarfile.open(fileobj=stream,mode='w') as archive:archive.add(staged,arcname='.')
 run(['exec-in','run-as',package,'tar','-xf','-','-C','files/'+project_name],input=stream.getvalue(),capture_output=True)
options={'DORA_GODOT_TEST_PROJECT':remote_project,'DORA_GODOT_TEST_OUTPUT':remote_results,'DORA_GODOT_TEST_BUFFERS':str(a.buffers)}
for flag in ('audio','audio-stall','resize','cancel-resize','aliases','reservation','ime','controller'):
 options['DORA_GODOT_TEST_'+flag.upper().replace('-','_')]='1' if getattr(a,flag.replace('-','_')) else '0'
if a.case in ('timing','particles'):options['DORA_GODOT_TEST_TIMING']='1'
if a.case=='output':options.update(DORA_GODOT_TEST_OUTPUT_CHANGE='1',DORA_GODOT_TEST_OUTPUT_STARTUP='1')
command=['shell','am','start','-W','-n',package+'/'+activity[1]]
for name,value in options.items():command+=['--es',name,value]
active={'serial':a.serial,'package':package,'finish':remote_results+'/native-finish.json','output':str(out),'remote_results':remote_results,'state':'starting'};active_file.write_text(json.dumps(active,indent=2)+'\n')
with (out/'launch.log').open('w') as log:run(command,stdout=log,stderr=subprocess.STDOUT)
pid=capture(['shell','pidof',package]);assert re.fullmatch(r'\d+',pid),pid
active.update(pid=int(pid),state='running');active_file.write_text(json.dumps(active,indent=2)+'\n')
log=(out/'run.log').open('wb');logger=subprocess.Popen(adb+['logcat','--pid='+pid,'-v','raw'],stdout=log,stderr=subprocess.STDOUT)
finished=None;background=None;ime=None

def exercise_ime():
 deadline=time.monotonic()+10
 while True:
  evidence=capture(['shell','dumpsys','input_method'])
  if ('mInputShown=true' in evidence or 'mShowRequested=true' in evidence) and ('org.libsdl.app.SDLActivity$DummyEdit' in evidence or 'org.libsdl.app.DummyEdit' in evidence):break
  if time.monotonic()>=deadline:raise RuntimeError('SDL IME did not become active in the controlled focus window')
  time.sleep(.1)
 (out/'input-method-active.txt').write_text(evidence)
 assert ('mInputShown=true' in evidence or 'mShowRequested=true' in evidence), 'Android soft keyboard was not shown'
 assert 'org.libsdl.app.SDLActivity$DummyEdit' in evidence or 'org.libsdl.app.DummyEdit' in evidence, 'SDL DummyEdit is not the served IME view'
 with (out/'ime-input.log').open('w') as file:run(['shell','input','text','IME42'],stdout=file,stderr=subprocess.STDOUT)
 deadline=time.monotonic()+10
 while time.monotonic()<deadline:
  current=(out/'run.log').read_text(errors='replace')
  if 'GODOT_NODE_TEXT value=DoraIME42' in current:
   run(['shell','run-as',package,'touch',remote_results+'/ime-accepted'],capture_output=True)
   record={'passed':True,'controlled_focus_window':True,'line_edit_auto_focus':True,'android_soft_keyboard_shown':True,'served_view':'SDL DummyEdit','committed_text':'IME42','scope':'Actual Android InputMethodManager soft-keyboard lifecycle and system-injected committed Latin text; composition/candidate UI is not covered'}
   (out/'ime.json').write_text(json.dumps(record,indent=2)+'\n');return record
  time.sleep(.1)
 raise RuntimeError('Android system text did not reach the focused Godot LineEdit')

def cycle_background():
 start=(out/'run.log').stat().st_size
 def segment():return (out/'run.log').read_bytes()[start:].decode('utf8',errors='replace')
 def wait_log(token):
  deadline=time.monotonic()+15
  while time.monotonic()<deadline:
   if token in segment():return
   time.sleep(.1)
  raise RuntimeError('Missing Android lifecycle evidence: '+token)
 home_at=time.monotonic();paused=False
 try:
  active['state']='background_requested';active_file.write_text(json.dumps(active,indent=2)+'\n')
  with (out/'background-home.log').open('w') as file:run(['shell','input','keyevent','KEYCODE_HOME'],stdout=file,stderr=subprocess.STDOUT)
  wait_log('onPause()');paused=True
  assert capture(['shell','pidof',package])==pid,'Background changed the native process'
  time.sleep(2)
 finally:
  # Restore a live owned activity after observation failure, but never turn
  # an unexpected native termination into an unrecorded new test process.
  probe=subprocess.run(adb+['shell','pidof',package],capture_output=True,timeout=30)
  same=probe.returncode==0 and probe.stdout.decode().strip()==pid
  active['state']='running' if same else 'terminated_during_background'
  active_file.write_text(json.dumps(active,indent=2)+'\n')
  if not same:raise RuntimeError('Native process changed during background; refusing an automatic restart')
  with (out/'background-resume.log').open('w') as file:run(command,stdout=file,stderr=subprocess.STDOUT)
 wait_log('onResume()')
 assert paused and capture(['shell','pidof',package])==pid,'Resume replaced the native process'
 evidence=segment()
 record={'passed':True,'native_pid':int(pid),'same_native_process':True,'background_seconds':time.monotonic()-home_at,'on_pause':True,'on_resume':True,'surface_destroyed':'surfaceDestroyed()' in evidence,'surface_created':'surfaceCreated()' in evidence,'scope':'Real Android Home/resume in the same native process; forced EGL context loss is not tested'}
 (out/'background.json').write_text(json.dumps(record,indent=2)+'\n')
 return record
try:
 deadline=time.monotonic()+240
 while time.monotonic()<deadline:
  if a.ime and ime is None:
   current=(out/'run.log').read_text(errors='replace')
   if 'GODOT_NODE_IME_READY stage=stable-window' in current and 'GODOT_NODE_TEXT value=Dora' in current:
    ime=exercise_ime()
  if a.background and background is None and 'GODOT_NODE_CAPTURE animated-b.png success=1' in (out/'run.log').read_text(errors='replace'):
   background=cycle_background()
  result=subprocess.run(adb+['shell','run-as',package,'cat',active['finish']],capture_output=True,timeout=30)
  if result.returncode==0 and result.stdout.strip():
   try:finished=json.loads(result.stdout)
   except json.JSONDecodeError:finished=None
   if finished is not None:break
  state=subprocess.run(adb+['shell','pidof',package],capture_output=True,timeout=30)
  if state.returncode!=0:raise RuntimeError('Native process terminated without a finish marker; inspect run.log')
  time.sleep(.5)
 if finished is None:raise TimeoutError('Native process not proven terminal; active-run.json records it for follow-up')
 time.sleep(1)
finally:
 logger.terminate()
 try:logger.wait(timeout=10)
 except subprocess.TimeoutExpired:logger.kill();logger.wait()
 log.close()
 if finished is not None:
  active['state']='finished';active['native_finish']=finished;active_file.write_text(json.dumps(active,indent=2)+'\n')
stream=subprocess.check_output(adb+['exec-out','run-as',package,'tar','-cf','-','-C',remote_results,'.'],timeout=60)
with tarfile.open(fileobj=io.BytesIO(stream)) as archive:archive.extractall(out,filter='data')
assert finished['result']==0,finished
script='verify_timing.py' if a.case in ('timing','particles') else 'verify_output.py' if a.case=='output' else 'verify_macos.py'
verify=[sys.executable,str(root/'Tools/Godot/tests'/script),'--results',str(out),'--platform','Android EGL']
if a.case=='particles':verify+=['--particles']
if a.case=='output':verify+=['--startup']
if a.case=='lifecycle':
 verify+=['--buffers',str(a.buffers)]
 for flag in ('audio','audio-stall','resize','cancel-resize','aliases','reservation','controller'):
  if getattr(a,flag.replace('-','_')):verify+=['--'+flag]
subprocess.run(verify,check=True)
result=json.loads(report.read_text())
if a.background:
 assert background and background['passed'],'Background cycle did not execute'
 result['android_background_resume']=background
if a.ime:
 assert ime and ime['passed'],'Android IME exercise did not execute'
 assert (out/'run.log').read_text(errors='replace').count('GODOT_NODE_IME_FOCUS active=1')>=2
 result['android_ime']=ime
result.update(android_serial=a.serial,android_package=package,runtime_library_sha256=hashlib.sha256(runtime).hexdigest(),apk_sha256=hashlib.sha256(a.apk.read_bytes()).hexdigest(),android_emulator=capture(['shell','getprop','ro.kernel.qemu'])=='1')
report.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
