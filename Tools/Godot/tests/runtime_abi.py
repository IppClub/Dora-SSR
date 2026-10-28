#!/usr/bin/env python3
"""Exercise a real runtime's preboot C ABI without creating graphics/OS state."""
import argparse,ctypes as C,hashlib,json,platform
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--library',type=Path,required=True)
p.add_argument('--backend',choices=['Metal','EGL','WGL'],required=True)
p.add_argument('--output',type=Path,required=True)
p.add_argument('--require-audio',action='store_true',help='Fail if the optional PCM pull extension is missing')
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
report=a.output/'verification.json';report.unlink(missing_ok=True)
V=C.c_void_p;U=C.c_uint32;Q=C.c_uint64;I=C.c_int
class Config(C.Structure):
    _fields_=[('size',U),('backend',U),('width',U),('height',U),('buffer_count',U),('project_path',C.c_char_p),('scene_path',C.c_char_p),('native_device',V)]
class API(C.Structure):
    _fields_=[('size',U),('abi_version',U),
      ('version',C.CFUNCTYPE(C.c_char_p)),('open',C.CFUNCTYPE(V,V)),
      ('last_error',C.CFUNCTYPE(C.c_char_p,V)),('get_slot',C.CFUNCTYPE(I,V,U,V)),
      ('advance',C.CFUNCTYPE(Q,V,U,Q)),('input',C.CFUNCTYPE(I,V,V)),
      ('set_paused',C.CFUNCTYPE(I,V,I)),('restart_scene',C.CFUNCTYPE(I,V,C.c_char_p)),
      ('close',C.CFUNCTYPE(None,V,V)),('shutdown',C.CFUNCTYPE(None))]
class GLAPI(C.Structure):
    _fields_=[('size',U),('abi_version',U),
      ('can_produce',C.CFUNCTYPE(I,V,U,Q)),('consumer_begin',C.CFUNCTYPE(I,V,U,Q)),('consumer_end',C.CFUNCTYPE(I,V,U,Q))]
class GLAPI2(C.Structure):
    _fields_=GLAPI._fields_+[('can_advance',C.CFUNCTYPE(I,V,U,Q)),('advance_async',C.CFUNCTYPE(Q,V,U,Q))]
class TargetsAPI(C.Structure):
    _fields_=[('size',U),('abi_version',U),('bind',C.CFUNCTYPE(I,V,U,U,V,U))]
class ViewportAPI(C.Structure):
    _fields_=[('size',U),('abi_version',U),('resize',C.CFUNCTYPE(I,V,U,U))]
class OutputAPI(C.Structure):
    _fields_=[('size',U),('abi_version',U),('get_size',C.CFUNCTYPE(I,V,V))]
class IMEAPI(C.Structure):
    _fields_=[('size',U),('abi_version',U),('get_state',C.CFUNCTYPE(I,V,V))]
class AudioAPI(C.Structure):
    _fields_=[('size',U),('abi_version',U),('get_format',C.CFUNCTYPE(I,V,V)),('start_capture',C.CFUNCTYPE(I,V)),('read_pcm',C.CFUNCTYPE(U,V,V,U)),('get_stats',C.CFUNCTYPE(I,V,V))]
lib=C.CDLL(str(a.library.resolve()))
checks=[]
def check(value,name):
    assert value,name
    checks.append(name)
def table(getter,kind,name,version=1):
    getter.argtypes=[U,V];getter.restype=I
    check(getter(version,None)==0,name+': null destination')
    for requested,size in [(0,C.sizeof(kind)),(version+1,C.sizeof(kind)),(0xffffffff,C.sizeof(kind)),(version,0),(version,4),(version,C.sizeof(kind)-1)]:
        memory=(C.c_ubyte*(C.sizeof(kind)+64))(*([0xa5]*(C.sizeof(kind)+64)))
        C.cast(memory,C.POINTER(U))[0]=size
        before=bytes(memory)
        check(getter(requested,memory)==0,name+f': reject version={requested} size={size}')
        check(bytes(memory)==before,name+': rejected destination untouched')
    memory=(C.c_ubyte*(C.sizeof(kind)+64))(*([0xa5]*(C.sizeof(kind)+64)))
    C.cast(memory,C.POINTER(U))[0]=len(memory)
    check(getter(version,memory)==1,name+': valid extended destination')
    check(bytes(memory)[C.sizeof(kind):]==b'\xa5'*64,name+': trailing canary preserved')
    result=kind.from_buffer(memory)
    check(result.size==C.sizeof(kind) and result.abi_version==version,name+': prefix size/version')
    check(all(bool(getattr(result,field)) for field,_ in kind._fields_[2:]),name+': complete function table')
    # Keep the backing storage alive while invoking its typed function pointers.
    result._backing=memory
    return result
api=table(lib.dora_godot_get_api,API,'runtime')
version=api.version().decode('utf8')
check(version.startswith('Godot 4.6-stable / Dora bridge'),'runtime version')
backend=1 if a.backend=='Metal' else 3
def config():return Config(C.sizeof(Config),backend,640,360,3,b'.',b'',1)
check(not api.open(None),'null config rejected')
for field,value in [('size',0),('size',C.sizeof(Config)-1),('backend',99),('width',0),('height',0),('width',8193),('height',8193),('buffer_count',0),('buffer_count',1),('buffer_count',5),('project_path',None),('project_path',b''),('native_device',None)]:
    c=config();setattr(c,field,value)
    check(not api.open(C.byref(c)),f'invalid config {field}={value!r}')
    check(b'configuration' in api.last_error(None).lower(),'invalid config has configuration diagnostic')
for handle in (None,1):
    check(api.get_slot(handle,0,None)==0,'invalid handle get_slot')
    check(api.advance(handle,0,0)==0,'invalid handle advance')
    check(api.input(handle,None)==0,'invalid handle input')
    check(api.set_paused(handle,1)==0,'invalid handle pause')
    check(api.restart_scene(handle,b'res://main.tscn')==0,'invalid handle restart')
    memory=(C.c_ubyte*64)(*([0xa5]*64));C.cast(memory,C.POINTER(U))[0]=64
    before=bytes(memory);api.close(handle,memory)
    check(bytes(memory)==before,'invalid handle close leaves stats untouched')
if a.backend!='Metal':
    extension=table(lib.dora_godot_get_gl_api,GLAPI2,'GL extension',2)
    legacy=table(lib.dora_godot_get_gl_api,GLAPI,'legacy GL extension')
    for handle in (None,1):
        for name in ('can_produce','consumer_begin','consumer_end','can_advance','advance_async'):
            check(getattr(extension,name)(handle,0,0)==0,'invalid handle GL '+name)
audio_getter=getattr(lib,'dora_godot_get_audio_api',None)
check(not a.require_audio or audio_getter is not None,'required audio extension present')
if audio_getter is not None:
    audio=table(audio_getter,AudioAPI,'audio extension',2)
    for handle in (None,1):
        memory=(C.c_ubyte*64)(*([0xa5]*64));C.cast(memory,C.POINTER(U))[0]=64
        before=bytes(memory)
        check(audio.start_capture(handle)==0,'invalid audio start handle')
        check(audio.get_stats(handle,memory)==0,'invalid audio stats handle')
        check(bytes(memory)==before,'rejected audio stats untouched')
        check(audio.get_format(handle,memory)==0,'invalid audio format handle')
        check(bytes(memory)==before,'rejected audio format untouched')
        for frames in (0,1,4096,4097,0xffffffff):
            check(audio.read_pcm(handle,memory,frames)==0,'invalid audio PCM handle')
            check(bytes(memory)==before,'rejected audio PCM untouched')
        check(audio.read_pcm(handle,None,1)==0,'null PCM destination rejected')
targets_getter=getattr(lib,'dora_godot_get_gl_targets_api',None)
if targets_getter is not None:
    targets=table(targets_getter,TargetsAPI,'GL host targets extension')
    for handle in (None,1):
        for count in (0,2,3,4,5,0xffffffff):
            check(targets.bind(handle,640,360,None,count)==0,'invalid GL target handle/count/array rejected')
viewport_getter=getattr(lib,'dora_godot_get_viewport_api',None)
if viewport_getter is not None:
    viewport=table(viewport_getter,ViewportAPI,'viewport extension')
    for handle in (None,1):
        for width,height in ((640,360),(0,360),(640,0),(8193,360),(640,8193),(0xffffffff,1)):
            check(viewport.resize(handle,width,height)==0,'invalid viewport handle/size rejected')
output_getter=getattr(lib,'dora_godot_get_output_api',None)
if output_getter is not None:
    output=table(output_getter,OutputAPI,'physical output extension')
    for handle in (None,1):
        memory=(C.c_ubyte*80)(*([0xa5]*80));C.cast(memory,C.POINTER(U))[0]=16
        before=bytes(memory)
        check(output.get_size(handle,memory)==0,'invalid output handle rejected')
        check(bytes(memory)==before,'rejected output size destination untouched')
        check(output.get_size(handle,None)==0,'null output size rejected')
ime_getter=getattr(lib,'dora_godot_get_ime_api',None)
if ime_getter is not None:
    ime=table(ime_getter,IMEAPI,'IME extension')
    for handle in (None,1):
        memory=(C.c_ubyte*80)(*([0xa5]*80));C.cast(memory,C.POINTER(U))[0]=24
        before=bytes(memory)
        check(ime.get_state(handle,memory)==0,'invalid IME handle rejected')
        check(bytes(memory)==before,'rejected IME state destination untouched')
        check(ime.get_state(handle,None)==0,'null IME state rejected')
api.shutdown();api.shutdown()
c=config();check(not api.open(C.byref(c)),'open after shutdown rejected before native device use')
check(b'terminated' in api.last_error(None).lower(),'post-shutdown lifecycle diagnostic')
result={'passed':True,'scope':'real native runtime preboot ABI/parameter/handle guards; no graphics context, engine boot or GPU test',
        'backend':a.backend,'system':platform.system(),'process_pointer_bits':C.sizeof(V)*8,'runtime_version':version,
        'library_sha256':hashlib.sha256(a.library.read_bytes()).hexdigest(),'checks':checks,'gpu_tested':False,
        'output_extension':output_getter is not None,'ime_extension':ime_getter is not None,'gl_targets_extension':targets_getter is not None,'audio_extension':audio_getter is not None,'audio_output_tested':False,
        'gl_extension_abi':extension.abi_version if a.backend!='Metal' else None,
        'legacy_gl_extension_abi':legacy.abi_version if a.backend!='Metal' else None}
report.write_text(json.dumps(result,indent=2)+'\n')
print('Native preboot ABI guards: PASS;',len(checks),'checks;',a.backend)
