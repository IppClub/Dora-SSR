#!/usr/bin/env python3
"""Ordinary Windows WGL/Linux EGL host: imported animated glTF and spatial shader.

Linux requires a compositor, e.g. with_weston.py. Records actual native output;
this is not a physical GPU, large-project or audio-content acceptance claim.
"""
import argparse,hashlib,json,os,shutil,subprocess,sys,time
from pathlib import Path

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ('binary','library','asset-source','output'):p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args();assert sys.platform in ('win32','linux');platform='Windows WGL' if sys.platform=='win32' else 'Linux EGL';library_name='dora_godot.dll' if sys.platform=='win32' else 'libdora_godot.so';out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    if sys.platform=='linux':assert os.environ.get('WAYLAND_DISPLAY') or os.environ.get('DISPLAY'),'Run under with_weston.py'
    def sha(path):
     with path.open('rb') as file:return hashlib.file_digest(file,'sha256').hexdigest()
    try:
     binary=a.binary.resolve();library=a.library.resolve()
     assert b'dora_godot_node_test_main' not in binary.read_bytes(),'Ordinary host required'
     original={str(path):sha(path) for path in (binary,library)}
     assets=out/'assets';shutil.copytree(a.asset_source.resolve(),assets)
     shutil.copy2(library,assets/library_name)
     manifest=json.loads((library.parent/'manifest.json').read_text());notices={}
     for name in manifest['licenses']:
      relative=Path(name);assert not relative.is_absolute() and '..' not in relative.parts
      target=assets/'GodotNotices'/relative;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(library.parent/relative,target);notices[str(target)]=sha(target)
     project=assets/'GodotProject';shutil.copytree(Path(__file__).with_name('project_3d'),project,ignore=shutil.ignore_patterns('.godot'))
     (project/'.godot').mkdir();(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
     script=Path(__file__).with_name('project_3d.lua').read_text().replace('@PROJECT@',json.dumps(project.as_posix())).replace('@OUTPUT@',json.dumps(out.as_posix()))
     (assets/'Script/init.lua').write_text(script);(out/'startup.lua').write_text(script)
     artifacts={str(path):sha(path) for path in [binary,assets/library_name,assets/'Script/init.lua',*[p for p in project.rglob('*') if p.is_file() and '.godot' not in p.parts]]}
     for path in (binary.parent/'wa.dll',):
      if path.is_file():artifacts[str(path)]=sha(path)
     (out/'artifacts.json').write_text(json.dumps({'original':original,'executed':artifacts,'notices':notices},indent=2)+'\n')
     env={k:v for k,v in os.environ.items() if not k.startswith(('DORA_GODOT_','DORA_BUILD_'))};env.update(SDL_AUDIODRIVER='dummy',GODOT_SILENCE_ROOT_WARNING='1')
     if sys.platform=='win32':env['DORA_GODOT_WINDOWS_GL']='1'
     started=time.monotonic()
     with (out/'run.log').open('w',encoding='utf8') as log:
      child=subprocess.Popen([str(binary),'--asset',str(assets)],cwd=assets,env=env,stdout=log,stderr=subprocess.STDOUT)
      (out/'process.json').write_text(json.dumps({'pid':child.pid,'binary':str(binary)},indent=2)+'\n')
      try:code=child.wait(timeout=90)
      except subprocess.TimeoutExpired:
       child.terminate();child.wait(timeout=10);raise
     assert all(sha(Path(name))==expected for name,expected in {**original,**artifacts,**notices}.items())
     execution={'native_exit_code':code,'ordinary_host_without_test_entry':True,'platform':platform,'runtime_seconds':time.monotonic()-started,'scope':__doc__+' Native renderer/CPU are recorded separately; no physical GPU/audio/distribution proof.','artifacts':artifacts,'notices':notices,'original':original}
     (out/'execution.json').write_text(json.dumps(execution,indent=2)+'\n')
     subprocess.run([sys.executable,str(Path(__file__).with_name('verify_project_3d.py')),str(out),'--platform',platform],check=True)
    except BaseException as error:
     (out/'failure.json').write_text(json.dumps({'passed':False,'error':repr(error)},indent=2)+'\n');raise

if __name__=="__main__":main()
