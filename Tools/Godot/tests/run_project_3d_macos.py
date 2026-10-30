#!/usr/bin/env python3
"""Stage a public-API ordinary host and run an imported animated glTF 3D project."""
import argparse,hashlib,json,os,shutil,subprocess,sys,time
from pathlib import Path
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__)
for name in ('app','library','output'):p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();assert sys.platform=='darwin';out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
def sha(path):
 with path.open('rb') as file:return hashlib.file_digest(file,'sha256').hexdigest()
try:
 app=a.app.resolve();library=a.library.resolve();binary=app/'Contents/MacOS/Dora'
 assert '_dora_godot_node_test_main' not in subprocess.check_output(['nm','-gU',str(binary)],text=True)
 subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True,capture_output=True)
 original={'binary':sha(binary),'runtime':sha(library)}
 project=out/'project';shutil.copytree(Path(__file__).with_name('project_3d'),project,ignore=shutil.ignore_patterns('.godot'))
 (project/'.godot').mkdir();(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
 staged=out/'Dora.app';subprocess.run(['cp','-cR',str(app),str(staged)],check=True)
 resources=staged/'Contents/Resources';shutil.copy2(library,resources/'libdora_godot.dylib')
 script=Path(__file__).with_name('project_3d.lua').read_text().replace('@PROJECT@',json.dumps(str(project))).replace('@OUTPUT@',json.dumps(str(out)))
 (resources/'Script/init.lua').write_text(script);(out/'startup.lua').write_text(script)
 subprocess.run(['codesign','--force','--deep','--timestamp=none','--sign','-',str(staged)],check=True,capture_output=True)
 subprocess.run(['codesign','--verify','--deep','--strict',str(staged)],check=True,capture_output=True)
 inputs=[staged/'Contents/MacOS/Dora',resources/'libdora_godot.dylib',resources/'Script/init.lua',*[f for f in project.rglob('*') if f.is_file() and '.godot' not in f.parts]]
 artifacts={str(f):sha(f) for f in inputs};(out/'artifacts.json').write_text(json.dumps(artifacts,indent=2)+'\n')
 env={k:v for k,v in os.environ.items() if not k.startswith(('DORA_GODOT_','DORA_BUILD_'))};env['MTL_DEBUG_LAYER']='1';started=time.monotonic()
 with (out/'run.log').open('w') as log:
  child=subprocess.Popen([str(staged/'Contents/MacOS/Dora')],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT)
  (out/'process.json').write_text(json.dumps({'pid':child.pid,'binary':str(staged/'Contents/MacOS/Dora')},indent=2)+'\n')
  try:code=child.wait(timeout=60)
  except subprocess.TimeoutExpired:
   child.terminate();child.wait(timeout=10);raise
 assert all(sha(Path(name))==expected for name,expected in artifacts.items())
 assert sha(binary)==original['binary'] and sha(library)==original['runtime']
 execution={'native_exit_code':code,'ordinary_host_without_test_entry':True,'original_artifacts':original,'runtime_seconds':time.monotonic()-started,'scope':__doc__,'artifacts':artifacts}
 (out/'execution.json').write_text(json.dumps(execution,indent=2)+'\n')
 subprocess.run([sys.executable,str(Path(__file__).with_name('verify_project_3d.py')),str(out)],check=True)
except BaseException as error:
 (out/'failure.json').write_text(json.dumps({'passed':False,'error':repr(error)},indent=2)+'\n');raise
