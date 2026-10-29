#!/usr/bin/env python3
"""Execute both Windows WGL tests, not a simulation or compile-only check."""
import argparse,json,re,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[4]
parser=argparse.ArgumentParser()
parser.add_argument('--binaries',type=Path,default=root/'build/godot-windows/transport')
parser.add_argument('--library',type=Path,default=root/'build/godot-windows/package/dora_godot.dll')
parser.add_argument('--project',type=Path,default=root/'Tools/Godot/tests/project')
parser.add_argument('--output',type=Path,default=root/'build/godot-windows/wgl-results')
args=parser.parse_args();assert sys.platform=='win32','Windows execution is required'
out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
(out/'verification.json').unlink(missing_ok=True)
with (out/'transport.log').open('w') as log:
    subprocess.run([str(args.binaries.resolve()/'transport.exe')],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=120)
log=(out/'transport.log').read_text(encoding='utf-8',errors='replace');assert 'WGL_TRANSPORT PASS consumers=3600 sampled_frames=99' in log
assert 'FAIL' not in log and all('buffers='+str(n) in log for n in (2,3,4))
renderer=re.search(r'WGL_TRANSPORT renderer=(.*?) version=(.*)',log);assert renderer
report={'passed':True,'scope':'real Windows shared WGL transport; Godot/Dora node tested separately',
    'renderer':renderer[1],'gl_version':renderer[2],'consumer_frames':3600,'sampled_frames':99,'buffers':[2,3,4],'cpu_pixel_transport':False}
(out/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
project_cache=args.project/'.godot';project_cache.mkdir(exist_ok=True)
(project_cache/'global_script_class_cache.cfg').write_text('list=[]\n')
runtime=out/'runtime';runtime.mkdir(exist_ok=True);(runtime/'verification.json').unlink(missing_ok=True)
with (runtime/'run.log').open('w') as log:
    subprocess.run([str(args.binaries.resolve()/'runtime.exe'),str(args.library.resolve()),str(args.project.resolve()),str(runtime)],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=120)
subprocess.run([sys.executable,str(root/'Tools/Godot/tests/gl/verify_runtime.py'),str(runtime),'--backend','WGL'],check=True)
