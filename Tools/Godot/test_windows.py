#!/usr/bin/env python3
"""Run the actual Windows GodotNode/WGL regression, retaining GPU evidence."""
import argparse,os,shutil,subprocess,sys,struct,json,hashlib,time,ctypes
from ctypes import wintypes
from pathlib import Path
root=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser()
parser.add_argument('--skip-build',action='store_true',help='Reuse both the Godot DLL and Dora test host')
parser.add_argument('--skip-runtime-build',action='store_true',help='Reuse the Godot DLL while building the Dora test host')
parser.add_argument('--xmake',default='xmake',help='Path to a complete native host xmake installation')
parser.add_argument('--arch',choices=['x86_64'],default='x86_64')
parser.add_argument('--library',type=Path,default=root/'build/godot-windows/package/dora_godot.dll')
parser.add_argument('--project',type=Path,default=root/'Tools/Godot/tests/project')
parser.add_argument('--results',type=Path,default=root/'build/godot-runtime/node-windows-results')
parser.add_argument('--jobs',type=int,default=2)
parser.add_argument('--fixture',type=Path,help='Imported PCK verification manifest; overrides the environment setting')
parser.add_argument('--audio',action='store_true',help='Verify Godot stereo test tone reaches the host mixer callback')
parser.add_argument('--soak-frames',type=int,default=0,help='Additional frames, sampled every 300 frames')
parser.add_argument('--timing',action='store_true',help='Verify actual shader/script clock parity with delayed rendering')
parser.add_argument('--resize',action='store_true',help='Verify native viewport size changes preserving scene/pause/audio')
parser.add_argument('--cancel-resize',action='store_true',help='Remove a node immediately after resize acceptance')
parser.add_argument('--reservation',action='store_true',help='Verify rejected competing nodes preserve runtime ownership')
parser.add_argument('--audio-stall',action='store_true',help='Inject render stalls and require uninterrupted audio supply')
parser.add_argument('--aliases',action='store_true',help='Verify retained Sprite texture aliases through node removal')
parser.add_argument('--ime',action='store_true',help='Verify automatic Control IME lifecycle and commit Unicode through the real Windows message path')
parser.add_argument('--controller',action='store_true',help='Verify Dora standard controller events reach Godot and are released on focus loss')
parser.add_argument('--buffers',type=int,choices=[2,3,4],default=3)
args=parser.parse_args();assert sys.platform=='win32','Run this on Windows; compilation on another OS is not GPU verification'
results=args.results.resolve();results.mkdir(parents=True,exist_ok=True)
(results/'verification.json').unlink(missing_ok=True)
env=os.environ.copy();env.update(DORA_GODOT_WINDOWS_GL='1',DORA_BUILD_GODOT_NODE_TEST='1')
env['DORA_GODOT_TEST_BUFFERS']=str(args.buffers)
assert 0<=args.soak_frames<=36000 and args.soak_frames%300==0
env['DORA_GODOT_TEST_SOAK_FRAMES']=str(args.soak_frames)
if args.audio:env['DORA_GODOT_TEST_AUDIO']='1'
if args.reservation:env['DORA_GODOT_TEST_RESERVATION']='1'
if args.resize:env['DORA_GODOT_TEST_RESIZE']='1'
if args.timing:env['DORA_GODOT_TEST_TIMING']='1'
if args.cancel_resize:
    assert args.resize, '--cancel-resize requires --resize'
    env['DORA_GODOT_TEST_CANCEL_RESIZE']='1'
if args.audio_stall:
    assert args.audio, '--audio-stall requires --audio'
    env['DORA_GODOT_TEST_AUDIO_STALL']='1'
if args.aliases:env['DORA_GODOT_TEST_ALIASES']='1'
if args.ime:env['DORA_GODOT_TEST_IME']='1'
if args.controller:env['DORA_GODOT_TEST_CONTROLLER']='1'
if not args.skip_build:
    if not args.skip_runtime_build:
        subprocess.run([sys.executable,str(root/'Tools/Godot/build_windows_runtime.py'),'--jobs',str(args.jobs),'--arch',args.arch],cwd=root,check=True)
    subprocess.run([args.xmake,'f','-y','-p','windows','-a','x64' if args.arch=='x86_64' else args.arch],cwd=root,env=env,check=True)
    subprocess.run([args.xmake,'build','-j'+str(args.jobs),'Dora'],cwd=root,env=env,check=True)
binary=root/'build/godot-runtime/dora/Dora.exe';assert binary.is_file() and args.library.is_file()
def machine(path):
    with path.open('rb') as file:
        assert file.read(2)==b'MZ',path
        file.seek(0x3c);offset=struct.unpack('<I',file.read(4))[0]
        file.seek(offset);assert file.read(4)==b'PE\0\0',path
        return struct.unpack('<H',file.read(2))[0]
assert machine(binary)==machine(args.library),'Dora executable and Godot DLL architectures must match'
abi=[sys.executable,str(root/'Tools/Godot/tests/runtime_abi.py'),'--library',str(args.library.resolve()),
    '--backend','WGL','--output',str(results/'abi-preboot')]
if args.audio:abi+=['--require-audio']
subprocess.run(abi,cwd=root,check=True)

assets=root/'build/godot-runtime/test-assets';shutil.copytree(root/'Assets',assets,dirs_exist_ok=True)
(assets/'Script/init.lua').write_text('return true\n')
for fixture_project in ('project','timing_project'):
    cache=root/'Tools/Godot/tests'/fixture_project/'.godot';cache.mkdir(exist_ok=True)
    (cache/'global_script_class_cache.cfg').write_text('list=[]\n')
env.update(DORA_GODOT_LIBRARY=str(args.library.resolve()),DORA_GODOT_TEST_PROJECT=str(args.project.resolve()),
    DORA_GODOT_TEST_OUTPUT=str(results),SDL_AUDIODRIVER='dummy',GODOT_SILENCE_ROOT_WARNING='1')
def inject_windows_unicode(process,log_path,text):
    user32=ctypes.WinDLL('user32',use_last_error=True);imm32=ctypes.WinDLL('imm32',use_last_error=True);kernel32=ctypes.WinDLL('kernel32',use_last_error=True)
    user32.EnumWindows.argtypes=[ctypes.c_void_p,wintypes.LPARAM];user32.EnumWindows.restype=wintypes.BOOL
    user32.GetWindowThreadProcessId.argtypes=[wintypes.HWND,ctypes.POINTER(wintypes.DWORD)];user32.GetWindowThreadProcessId.restype=wintypes.DWORD
    user32.IsWindowVisible.argtypes=[wintypes.HWND];user32.IsWindowVisible.restype=wintypes.BOOL
    user32.ShowWindow.argtypes=[wintypes.HWND,ctypes.c_int];user32.ShowWindow.restype=wintypes.BOOL
    user32.SetForegroundWindow.argtypes=[wintypes.HWND];user32.SetForegroundWindow.restype=wintypes.BOOL
    user32.GetForegroundWindow.argtypes=[];user32.GetForegroundWindow.restype=wintypes.HWND
    kernel32.GetCurrentThreadId.argtypes=[];kernel32.GetCurrentThreadId.restype=wintypes.DWORD
    user32.AttachThreadInput.argtypes=[wintypes.DWORD,wintypes.DWORD,wintypes.BOOL];user32.AttachThreadInput.restype=wintypes.BOOL
    user32.BringWindowToTop.argtypes=[wintypes.HWND];user32.BringWindowToTop.restype=wintypes.BOOL
    user32.SetFocus.argtypes=[wintypes.HWND];user32.SetFocus.restype=wintypes.HWND
    user32.GetWindowTextW.argtypes=[wintypes.HWND,wintypes.LPWSTR,ctypes.c_int];user32.GetWindowTextW.restype=ctypes.c_int
    user32.GetClassNameW.argtypes=[wintypes.HWND,wintypes.LPWSTR,ctypes.c_int];user32.GetClassNameW.restype=ctypes.c_int
    imm32.ImmGetContext.argtypes=[wintypes.HWND];imm32.ImmGetContext.restype=wintypes.HANDLE
    imm32.ImmGetOpenStatus.argtypes=[wintypes.HANDLE];imm32.ImmGetOpenStatus.restype=wintypes.BOOL
    imm32.ImmReleaseContext.argtypes=[wintypes.HWND,wintypes.HANDLE];imm32.ImmReleaseContext.restype=wintypes.BOOL
    windows=[]
    callback_type=ctypes.WINFUNCTYPE(wintypes.BOOL,wintypes.HWND,wintypes.LPARAM)
    @callback_type
    def collect(hwnd,_):
        pid=wintypes.DWORD();user32.GetWindowThreadProcessId(hwnd,ctypes.byref(pid))
        if pid.value==process.pid and user32.IsWindowVisible(hwnd):windows.append(hwnd)
        return True
    deadline=time.monotonic()+30;hwnd=None
    while time.monotonic()<deadline and not hwnd:
        if process.poll() is not None:raise RuntimeError('Dora exited before its Windows HWND became visible')
        windows.clear();user32.EnumWindows(collect,0)
        for candidate in windows:
            window_class=ctypes.create_unicode_buffer(256);user32.GetClassNameW(candidate,window_class,len(window_class))
            if window_class.value=='SDL_app':hwnd=candidate;break
        if not hwnd:time.sleep(.05)
    assert hwnd,'Dora SDL_app HWND was not found'
    target_thread=user32.GetWindowThreadProcessId(hwnd,None);current_thread=kernel32.GetCurrentThreadId()
    attached=bool(user32.AttachThreadInput(current_thread,target_thread,True))
    try:
        user32.ShowWindow(hwnd,5);user32.BringWindowToTop(hwnd);user32.SetForegroundWindow(hwnd);user32.SetFocus(hwnd)
    finally:
        if attached:user32.AttachThreadInput(current_thread,target_thread,False)
    marker='GODOT_NODE_HOST_IME stage=first active=1'
    while time.monotonic()<deadline:
        if process.poll() is not None:raise RuntimeError('Dora exited before Windows IME became active')
        if log_path.exists() and marker in log_path.read_text(errors='replace'):break
        time.sleep(.05)
    else:raise TimeoutError('Dora automatic IME activation marker was not observed')
    fallback_hwnd=hwnd;descriptions=[];hwnd=None;context=None
    context_deadline=time.monotonic()+5
    while time.monotonic()<context_deadline and not context:
        windows.clear();user32.EnumWindows(collect,0)
        descriptions=[]
        for candidate in windows:
            title=ctypes.create_unicode_buffer(256);window_class=ctypes.create_unicode_buffer(256)
            user32.GetWindowTextW(candidate,title,len(title));user32.GetClassNameW(candidate,window_class,len(window_class))
            descriptions.append({'hwnd':int(candidate),'title':title.value,'class':window_class.value})
            user32.ShowWindow(candidate,5);user32.SetForegroundWindow(candidate);time.sleep(.05)
            candidate_context=imm32.ImmGetContext(candidate)
            if candidate_context:hwnd=candidate;context=candidate_context;break
        if not context:time.sleep(.05)
    if not hwnd:hwnd=fallback_hwnd
    time.sleep(.1)
    open_status=bool(imm32.ImmGetOpenStatus(context)) if context else None
    if context:imm32.ImmReleaseContext(hwnd,context)
    class KEYBDINPUT(ctypes.Structure):
        _fields_=[('wVk',wintypes.WORD),('wScan',wintypes.WORD),('dwFlags',wintypes.DWORD),('time',wintypes.DWORD),('dwExtraInfo',ctypes.c_size_t)]
    class MOUSEINPUT(ctypes.Structure):
        _fields_=[('dx',wintypes.LONG),('dy',wintypes.LONG),('mouseData',wintypes.DWORD),('dwFlags',wintypes.DWORD),('time',wintypes.DWORD),('dwExtraInfo',ctypes.c_size_t)]
    class HARDWAREINPUT(ctypes.Structure):
        _fields_=[('uMsg',wintypes.DWORD),('wParamL',wintypes.WORD),('wParamH',wintypes.WORD)]
    class INPUTUNION(ctypes.Union):_fields_=[('mi',MOUSEINPUT),('ki',KEYBDINPUT),('hi',HARDWAREINPUT)]
    class INPUT(ctypes.Structure):_fields_=[('type',wintypes.DWORD),('union',INPUTUNION)]
    user32.SendInput.argtypes=[wintypes.UINT,ctypes.POINTER(INPUT),ctypes.c_int];user32.SendInput.restype=wintypes.UINT
    events=[]
    for offset in range(0,len(text.encode('utf-16-le')),2):
        unit=int.from_bytes(text.encode('utf-16-le')[offset:offset+2],'little')
        events.extend((INPUT(1,INPUTUNION(ki=KEYBDINPUT(0,unit,0x0004,0,0))),INPUT(1,INPUTUNION(ki=KEYBDINPUT(0,unit,0x0006,0,0)))))
    array=(INPUT*len(events))(*events);sent=user32.SendInput(len(events),array,ctypes.sizeof(INPUT))
    assert sent==len(events),(sent,len(events),ctypes.get_last_error())
    selected=next(item for item in descriptions if item['hwnd']==int(hwnd))
    return {'hwnd':int(hwnd),'window_title':selected['title'],'window_class':selected['class'],'imm_context':bool(context),'imm_open_status':open_status,'unicode_commit':text,'sendinput_events':sent,
        'foreground_after_request':int(user32.GetForegroundWindow())==int(hwnd),'scope':'Real Win32 SendInput/WM_CHAR commit with SDL text input active; not candidate/composition UI'}
ime_evidence=None
with (results/'run.log').open('w') as log:
    process=subprocess.Popen([str(binary),'--asset',str(assets)],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT)
    try:
        if args.ime:
            log.flush();ime_evidence=inject_windows_unicode(process,results/'run.log','WinIME中')
            (results/'windows-ime.json').write_text(json.dumps(ime_evidence,indent=2)+'\n',encoding='utf-8')
        returncode=process.wait(timeout=180+args.soak_frames/30)
    except subprocess.TimeoutExpired:
        process.kill();process.wait();raise
    except BaseException:
        process.kill();process.wait();raise
    if returncode:raise subprocess.CalledProcessError(returncode,[str(binary),'--asset',str(assets)])
if args.timing:
    subprocess.run([sys.executable,str(root/'Tools/Godot/tests/verify_timing.py'),'--results',str(results),'--platform','Windows WGL'],check=True)
    sys.exit(0)
command=[sys.executable,str(root/'Tools/Godot/tests/verify_macos.py'),'--platform','Windows WGL','--results',str(results),'--buffers',str(args.buffers)]
fixture=args.fixture or env.get('DORA_GODOT_FIXTURE_MANIFEST')
if fixture:command+=['--fixture',str(Path(fixture).resolve())]
command+=['--soak-frames',str(args.soak_frames)]
if args.audio:command+=['--audio']
if args.reservation:command+=['--reservation']
if args.resize:command+=['--resize']
if args.cancel_resize:command+=['--cancel-resize']
if args.audio_stall:command+=['--audio-stall']
if args.aliases:command+=['--aliases']
if args.ime:command+=['--ime']
if args.controller:command+=['--controller']
subprocess.run(command,check=True)

report_path=results/'verification.json';report=json.loads(report_path.read_text(encoding='utf-8'))
report['runtime_architecture']={0x8664:'x86_64',0xaa64:'arm64'}.get(machine(args.library),hex(machine(args.library)))
with args.library.open('rb') as library:
    digest=hashlib.sha256()
    for block in iter(lambda:library.read(1024*1024),b''):digest.update(block)
report['runtime_library_sha256']=digest.hexdigest()
if ime_evidence:report['windows_ime']=ime_evidence
report_path.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
