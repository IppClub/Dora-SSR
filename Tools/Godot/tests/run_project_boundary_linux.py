#!/usr/bin/env python3
"""Run project rejection/recovery with an ordinary Linux host, inside Weston.

Requires an ordinary Dora binary, not the native Godot test entrypoint.
Stages its own assets and uses the default bundled-library lookup.
"""
import argparse,hashlib,json,os,re,shutil,subprocess,sys,time
from pathlib import Path
from verify_project_boundary import verify
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__)
for name in ('binary','library','output'):p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();assert sys.platform=='linux'
out=a.output.resolve();assert not out.exists(),'Use a fresh evidence directory'
out.mkdir(parents=True);binary=a.binary.resolve();library=a.library.resolve()
expected='GL runtime reopen requires the same project, dimensions and buffer count'
def digest(path):
    with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
try:
    symbols=subprocess.check_output(['nm','--defined-only',str(binary)],text=True)
    assert 'dora_godot_node_test_main' not in symbols,'Build an ordinary host without DORA_BUILD_GODOT_NODE_TEST'
    original={str(path):digest(path) for path in (binary,library)}
    subprocess.run([sys.executable,str(root/'Tools/Godot/verify_package.py'),str(library.parent),'--output',str(out/'package-integrity.json')],check=True)
    assets=out/'assets';shutil.copytree(root/'Assets',assets)
    bundled=assets/'libdora_godot.so';shutil.copy2(library,bundled)
    projects=[]
    for name in ('first-project','different-project'):
        project=out/name
        shutil.copytree(root/'Tools/Godot/tests/project',project,ignore=shutil.ignore_patterns('.godot'))
        (project/'.godot').mkdir();(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
        projects.append(project)
    code=Path(__file__).with_name('project_boundary.lua').read_text()
    for key,value in [('OUTPUT',out),('FIRST',projects[0]),('OTHER',projects[1]),('EXPECTED_ERROR',expected)]:code=code.replace('@'+key+'@',json.dumps(str(value)))
    startup=assets/'Script/init.lua';startup.write_text(code)
    executed={str(path):digest(path) for path in (binary,bundled,startup)}
    project_hashes={str(path):digest(path) for project in projects for path in project.rglob('*') if path.is_file() and '.godot' not in path.parts}
    (out/'artifacts.json').write_text(json.dumps({'original':original,'executed':executed,'projects':project_hashes},indent=2)+'\n')
    env=os.environ.copy()
    for key in list(env):
        if key.startswith(('DORA_GODOT_','DORA_BUILD_')):env.pop(key)
    env.update(SDL_AUDIODRIVER='dummy',GODOT_SILENCE_ROOT_WARNING='1')
    started=time.monotonic()
    with (out/'run.log').open('w') as log:subprocess.run([str(binary),'--asset',str(assets)],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=180)
    runtime_seconds=time.monotonic()-started
    verified=verify(out,expected,failed_reader_reported=False)
    match=re.search(r'OpenGL API (.+)',(out/'run.log').read_text());assert match,'Actual Godot GL renderer missing'
    assert all(digest(Path(path))==sha for path,sha in {**original,**executed,**project_hashes}.items()),'Artifacts or project inputs changed'
    (out/'verification.json').write_text(json.dumps({'passed':True,'platform':'Linux EGL','scope':'Ordinary Linux host with default bundled library: A animates, B is rejected, A reopens and animates; no multi-project or runtime unload support claimed','runtime_seconds':runtime_seconds,'godot_renderer':match.group(1),**verified,'artifacts':executed},indent=2)+'\n')
    print('Linux ordinary project boundary rejection and recovery: PASS')
except BaseException as error:
    (out/'verification.json').unlink(missing_ok=True)
    (out/'failure.json').write_text(json.dumps({'passed':False,'type':type(error).__name__,'error':str(error)},indent=2)+'\n');raise
