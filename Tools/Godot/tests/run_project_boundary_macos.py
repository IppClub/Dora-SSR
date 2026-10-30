#!/usr/bin/env python3
"""Actual ordinary-host project rejection and same-project recovery, macOS."""
import argparse,hashlib,json,os,shutil,subprocess,time
from pathlib import Path
from verify_project_boundary import verify
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__)
for name in ('app','library','output'):p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();out=a.output.resolve();assert not out.exists(),'Use fresh evidence directory'
out.mkdir(parents=True);source=a.app.resolve();library=a.library.resolve();app=out/'Dora.app'
def digest(path):
    with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
try:
    binary=source/'Contents/MacOS/Dora'
    assert '_dora_godot_node_test_main' not in subprocess.check_output(['nm','-gU',str(binary)],text=True),'Use an ordinary host'
    subprocess.run(['codesign','--verify','--deep','--strict',str(source)],check=True,capture_output=True)
    original={str(path):digest(path) for path in (binary,library)}
    shutil.copytree(source,app);resources=app/'Contents/Resources'
    bundled=resources/'libdora_godot.dylib';shutil.copy2(library,bundled)
    first=root/'Tools/Godot/tests/project';other=out/'different-project'
    shutil.copytree(first,other,ignore=shutil.ignore_patterns('.godot'))
    (first/'.godot').mkdir(exist_ok=True)
    (first/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
    (other/'.godot').mkdir();(other/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
    template=Path(__file__).with_name('project_boundary.lua')
    code=template.read_text()
    for key,value in [('OUTPUT',out),('FIRST',first),('OTHER',other),('EXPECTED_ERROR','different Godot project')]:code=code.replace('@'+key+'@',json.dumps(str(value)))
    startup=resources/'Script/init.lua';startup.write_text(code)
    subprocess.run(['codesign','--force','--deep','--timestamp=none','--sign','-',str(app)],check=True,capture_output=True)
    subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True,capture_output=True)
    executed={str(path):digest(path) for path in (app/'Contents/MacOS/Dora',bundled,startup)}
    (out/'artifacts.json').write_text(json.dumps({'original':original,'executed':executed,'fixture_sha256':digest(template)},indent=2)+'\n')
    env=os.environ.copy()
    for key in list(env):
        if key.startswith(('DORA_GODOT_','DORA_BUILD_')):env.pop(key)
    env['MTL_DEBUG_LAYER']='1';started=time.monotonic()
    with (out/'run.log').open('w') as log:subprocess.run([str(app/'Contents/MacOS/Dora')],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=90)
    verified=verify(out,'different Godot project')
    assert all(digest(Path(path))==sha for path,sha in {**original,**executed}.items()),'Artifacts changed'
    (out/'verification.json').write_text(json.dumps({'passed':True,'scope':'Ordinary macOS Metal host: project A animated, different project B safely rejected, project A reopens and animates; no multi-project support or runtime unload claimed','runtime_seconds':time.monotonic()-started,**verified,'artifacts':executed},indent=2)+'\n')
    print('Project boundary rejection and recovery: PASS')
except BaseException as error:
    (out/'verification.json').unlink(missing_ok=True)
    (out/'failure.json').write_text(json.dumps({'passed':False,'type':type(error).__name__,'error':str(error)},indent=2)+'\n');raise
