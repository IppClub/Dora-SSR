#!/usr/bin/env python3
"""Run an intentional Wa lazy-import trap in a copied macOS opt-in test host."""
import argparse, hashlib, json, os, shutil, subprocess, sys, time
from pathlib import Path
from verify_ownership_failure import verify

p=argparse.ArgumentParser(description=__doc__)
for name in ['app','library','module','output']:p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--project',type=Path,default=Path(__file__).resolve().parents[1]/'project')
a=p.parse_args();assert sys.platform=='darwin'
out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
app=out/'Dora.app';shutil.copytree(a.app.resolve(),app,symlinks=True)
(app/'Contents/Resources/Script/init.lua').write_text('return true\n')
subprocess.run(['codesign','--force','--deep','--sign','-',str(app)],check=True,capture_output=True)
binary=app/'Contents/MacOS/Dora';module=a.module.resolve();library=a.library.resolve()
# Test builds may strip symbols: the fixture's expected output and exit status
# are also checked, so activating another GUI instance cannot count as a pass.
env=os.environ.copy()
for name in list(env):
    if name.startswith('DORA_GODOT_TEST_') or name=='GODOT_MTL_SHADER_LOAD_STRATEGY':env.pop(name)
env.update(DORA_GODOT_BINDING_WASM=str(module),DORA_GODOT_LIBRARY=str(library),DORA_GODOT_TEST_PROJECT=str(a.project.resolve()),DORA_GODOT_TEST_OUTPUT=str(out),DORA_GODOT_TEST_BUFFERS='3',MTL_DEBUG_LAYER='1')
artifacts={str(x):hashlib.sha256(x.read_bytes()).hexdigest() for x in [binary,module,library]}
started=time.monotonic()
with (out/'run.log').open('w') as log:
    result=subprocess.run([str(binary)],env=env,stdout=log,stderr=subprocess.STDOUT,timeout=60)
execution={'native_exit_code':result.returncode,'runtime_seconds':time.monotonic()-started,'artifacts':artifacts,'project':str(a.project.resolve()),'shader_loading_environment_override':False}
(out/'execution.json').write_text(json.dumps(execution,indent=2)+'\n')
report=verify(out);(out/'ownership-verification.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
