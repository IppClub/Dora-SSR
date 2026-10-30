#!/usr/bin/env python3
"""Verify an intentionally failing Wasm initializer exits without a GPU teardown crash.
Build main.rs with --project /dora-godot-intentionally-missing-project first.
"""
import argparse,json,os,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[4]
parser=argparse.ArgumentParser()
parser.add_argument('--module',type=Path,required=True)
parser.add_argument('--case',choices=['invalid-project','missing-library'],default='invalid-project')
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
report=out/'verification.json';report.unlink(missing_ok=True)
project='/dora-godot-intentionally-missing-project' if args.case=='invalid-project' else str(root/'Tools/Godot/tests/project')
env=os.environ.copy();env.update(DORA_GODOT_BINDING_WASM=str(args.module.resolve()),DORA_GODOT_TEST_PROJECT=project,DORA_GODOT_TEST_OUTPUT=str(out),MTL_DEBUG_LAYER='1')
if args.case=='missing-library':
    suffix='.dylib' if sys.platform=='darwin' else '.dll' if sys.platform=='win32' else '.so'
    missing=out/('dora-godot-intentionally-missing-library'+suffix);assert not missing.exists()
    env['DORA_GODOT_LIBRARY']=str(missing)
if sys.platform=='darwin':
    app=root/'build/godot-runtime/dora/Dora.app';binary=app/'Contents/MacOS/Dora'
    (app/'Contents/Resources/Script/init.lua').write_text('return true\n')
    subprocess.run(['codesign','--force','--deep','--sign','-',str(app)],check=True)
    command=[str(binary)]
else:
    env.update(SDL_AUDIODRIVER='dummy',GODOT_SILENCE_ROOT_WARNING='1')
    command=[str(root/'build/godot-runtime/dora/Dora'),'--asset',str(root/'build/godot-runtime/test-assets')]
with (out/'run.log').open('w') as log:
    result=subprocess.run(command,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=60)
log=(out/'run.log').read_text()
assert result.returncode==2, ('expected test failure exit 2, not a crash',result.returncode)
if args.case=='invalid-project':
    assert 'GodotNode: project directory or .pck bundle was not found' in log
    assert 'failed to load wasm module' in log
else:
    assert 'GODOT_BINDING Rust created=1' in log
    assert 'GODOT_NODE_TEST FAIL' in log and 'dora-godot-intentionally-missing-library' in log
assert 'BGFX LEAK:' not in log and 'C++ objects leaks' not in log
assert 'Godot Engine v' not in log, 'Invalid project must be rejected before Godot boot'
data={'passed':True,'scope':'GodotNode failure during real Wasm initialization/startup and native host shutdown','case':args.case,'exit_code':result.returncode,'godot_started':False,'gpu_handle_leaks':False,'host_platform':sys.platform}
report.write_text(json.dumps(data,indent=2)+'\n');print(json.dumps(data,indent=2))
