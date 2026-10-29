#!/usr/bin/env python3
"""Actual source-driven Window size/stretch and SDL-to-Godot GUI acceptance."""
import argparse,hashlib,json,os,shutil,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser();p.add_argument('--results',type=Path,required=True);p.add_argument('--library',type=Path)
p.add_argument('--app',type=Path,help='Explicit macOS opt-in host; preserve its content and signature')
p.add_argument('--startup',action='store_true',help='Also negotiate a Window size set by project _ready')
a=p.parse_args();out=a.results.resolve();out.mkdir(parents=True,exist_ok=True)
report=out/'verification.json';report.unlink(missing_ok=True)
project=root/('Tools/Godot/tests/output_startup_project' if a.startup else 'Tools/Godot/tests/output_project');(project/'.godot').mkdir(exist_ok=True)
(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
platform={'darwin':'macOS Metal','linux':'Linux EGL','win32':'Windows WGL'}[sys.platform]
if sys.platform=='darwin':
    app=(a.app or root/'build/godot-runtime/dora/Dora.app').resolve();binary=app/'Contents/MacOS/Dora'
    if a.app:
        subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True,capture_output=True)
    else:
        (app/'Contents/Resources/Script/init.lua').write_text('return true\n')
        subprocess.run(['codesign','--force','--deep','--sign','-',str(app)],check=True)
    library=root/'build/godot-runtime/package/libdora_godot.dylib';command=[str(binary)]
else:
    assert not a.app,'--app applies to macOS only'
    binary=root/('build/godot-runtime/dora/Dora.exe' if sys.platform=='win32' else 'build/godot-runtime/dora/Dora')
    library=root/('build/godot-windows/package/dora_godot.dll' if sys.platform=='win32' else 'build/godot-linux/package/libdora_godot.so')
    assets=root/'build/godot-runtime/test-assets';shutil.copytree(root/'Assets',assets,dirs_exist_ok=True)
    (assets/'Script/init.lua').write_text('return true\n');command=[str(binary),'--asset',str(assets)]
library=(a.library or library).resolve();assert library.is_file() and binary.is_file()
env=os.environ.copy();env.update(DORA_GODOT_LIBRARY=str(library),DORA_GODOT_TEST_PROJECT=str(project),DORA_GODOT_TEST_OUTPUT=str(out),DORA_GODOT_TEST_OUTPUT_CHANGE='1',DORA_GODOT_TEST_TIMING='0',MTL_DEBUG_LAYER='1')
env.pop('DORA_GODOT_BINDING_WASM',None)
env['DORA_GODOT_TEST_OUTPUT_STARTUP']='1' if a.startup else '0'
if sys.platform=='win32':env['DORA_GODOT_WINDOWS_GL']='1'
if sys.platform!='darwin':env.update(SDL_AUDIODRIVER='dummy',GODOT_SILENCE_ROOT_WARNING='1')
(out/'artifacts.json').write_text(json.dumps({str(path):hashlib.sha256(path.read_bytes()).hexdigest() for path in (binary,library)},indent=2)+'\n')
try:
    with (out/'run.log').open('w',encoding='utf8') as log:subprocess.run(command,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=180)
    subprocess.run([sys.executable,str(Path(__file__).with_name('verify_output.py')),'--results',str(out),'--platform',platform]+(['--startup'] if a.startup else []),check=True)
except BaseException:
    report.unlink(missing_ok=True);raise
