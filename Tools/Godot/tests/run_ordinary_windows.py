#!/usr/bin/env python3
"""Ordinary Windows app: bundled project/runtime and missing-runtime fallback.

Includes upstream runtime notices in each asset tree;
this does not verify installers, updates, signing or production distribution.
"""
import argparse,hashlib,json,os,re,shutil,subprocess,sys,time
from pathlib import Path
from PIL import Image,ImageChops
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__)
for name in ('binary','library','output'):p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();assert sys.platform=='win32'
out=a.output.resolve();assert not out.exists(),'Use a fresh evidence directory'
out.mkdir(parents=True);binary=a.binary.resolve();library=a.library.resolve()
def digest(path):
    with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def pixels(image):return image.get_flattened_data() if hasattr(image,'get_flattened_data') else image.getdata()
try:
    assert b'dora_godot_node_test_main' not in binary.read_bytes(),'Use an ordinary host'
    subprocess.run([sys.executable,str(root/'Tools/Godot/verify_package.py'),str(library.parent),'--output',str(out/'package-integrity.json')],check=True)
    manifest=json.loads((library.parent/'manifest.json').read_text());assert manifest['library']==library.name
    original={str(path):digest(path) for path in (binary,library)}
    template=Path(__file__).with_name('ordinary_native.lua');cases=[]
    for missing in (False,True):
        case=out/('missing-library' if missing else 'bundled-runtime');case.mkdir()
        assets=case/'assets';shutil.copytree(root/'Assets',assets)
        bundled=assets/'dora_godot.dll'
        bundled.unlink(missing_ok=True)
        if not missing:shutil.copy2(library,bundled)
        notices={}
        for name in manifest['licenses']:
            relative=Path(name);assert not relative.is_absolute() and '..' not in relative.parts
            source=library.parent/relative;destination=assets/'GodotNotices'/relative
            destination.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,destination)
            assert digest(destination)==digest(source)
            notices[str(destination)]=digest(destination)
        project=assets/'GodotProject'
        shutil.copytree(root/'Tools/Godot/tests/project',project,ignore=shutil.ignore_patterns('.godot'))
        (project/'.godot').mkdir();(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
        code=template.read_text()
        # The WGL loader reports the native module-not-found status exactly.
        expected_error='cannot load Dora/Godot runtime DLL, Win32 error 126'
        old='assert(godot.lastError:find(@LIBRARY_NAME@, 1, true))'
        assert code.count(old)==1
        code=code.replace(old,'assert(godot.lastError == '+json.dumps(expected_error)+')')
        for key,value in [('OUTPUT',case.as_posix()),('PROJECT','GodotProject'),('LIBRARY_NAME',bundled.name),('EXPECTED_PROJECT_PATH',str(project))]:code=code.replace('@'+key+'@',json.dumps(value))
        code=code.replace('@MISSING@','true' if missing else 'false')
        startup=assets/'Script/init.lua';startup.write_text(code)
        executed={str(path):digest(path) for path in (binary,startup)}
        if not missing:executed[str(bundled)]=digest(bundled)
        projects={str(path):digest(path) for path in project.rglob('*') if path.is_file() and '.godot' not in path.parts}
        (case/'artifacts.json').write_text(json.dumps({'original':original,'executed':executed,'project':projects,'notices':notices,'fixture_sha256':digest(template)},indent=2)+'\n')
        env=os.environ.copy()
        for key in list(env):
            if key.startswith(('DORA_GODOT_','DORA_BUILD_')):env.pop(key)
        env.update(SDL_AUDIODRIVER='dummy',GODOT_SILENCE_ROOT_WARNING='1',DORA_GODOT_WINDOWS_GL='1')
        started=time.monotonic()
        with (case/'run.log').open('w') as log:subprocess.run([str(binary),'--asset',str(assets)],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=90)
        runtime=time.monotonic()-started;log=(case/'run.log').read_text()
        assert 'GODOT_ORDINARY complete=1' in log
        assert 'GODOT_NODE_TEST' not in log and 'BGFX LEAK:' not in log and 'C++ objects leaks' not in log
        assert ('Godot Engine v' in log)!=missing
        expected='missing_library_rejected=1' if missing else 'running=1'
        assert 'GODOT_ORDINARY '+expected in log
        errors=[line for line in log.splitlines() if '[error]' in line or 'ERROR:' in line]
        assert (len(errors)==1 and errors[0].endswith('GodotNode: '+expected_error)) if missing else not errors,errors
        images=[Image.open(case/f'frame-{i}.png').convert('RGB') for i in (1,2)]
        assert images[0].size==images[1].size
        centers=[]
        for image in images:
            # Iterate RGB data once; preserve exact renderer-sized screenshots.
            green=[index%image.width for index,(r,g,b) in enumerate(pixels(image)) if g>220 and r<30 and b<30]
            assert len(green)>500,'Ordinary Dora green content missing'
            centers.append(sum(green)/len(green))
        assert centers[1]-centers[0]>100,centers
        changed=sum(max(pixel)>20 for pixel in pixels(ImageChops.difference(*images)));assert changed>1000
        clients=re.findall(r'GodotRuntime client closed: produced=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
        readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
        if missing:
            assert not bundled.exists() and not clients and not readers
        else:
            assert len(clients)==len(readers)==1
            assert all(int(p)>0 and p==c and e=='0' for p,c,e in clients)
            for b,f,w,s,pending,c,e in readers:assert b=='3' and int(f)>0 and 0<int(w)<=int(s) and int(s)==int(f)*3 and pending=='0' and f==c and e=='0'
            w,h=images[0].size;box=(round(w*.4),round(h*.3),round(w*.6),round(h*.7));crops=[im.crop(box) for im in images]
            assert all(sum(g>70 and b>70 and r<g*.65 for r,g,b in pixels(im))>100 for im in crops),'Godot cube missing'
            assert sum(max(pixel)>8 for pixel in pixels(ImageChops.difference(*crops)))>100,'Godot cube did not animate'
        assert all(digest(Path(path))==sha for path,sha in {**original,**executed,**projects,**notices}.items()),'Inputs changed during execution'
        cases.append({'case':case.name,'passed':True,'runtime_seconds':runtime,'captures':2,'ordinary_green_centers':centers,'changed_pixels':changed,'godot_started':not missing,'relative_project_lookup':True,'runtime_lookup':'Default assets path; no library override','gpu_clients':clients,'gpu_readers':readers,'artifacts':executed,'notices':notices,'images_sha256':{f'frame-{i}.png':digest(case/f'frame-{i}.png') for i in (1,2)}})
    (out/'verification.json').write_text(json.dumps({'passed':True,'platform':'Windows WGL','scope':__doc__,'ordinary_host_without_test_entry':True,'cases':cases},indent=2)+'\n')
    print('Ordinary Windows bundled-runtime and missing-library fallback: PASS')
except BaseException as error:
    (out/'verification.json').unlink(missing_ok=True)
    (out/'failure.json').write_text(json.dumps({'passed':False,'type':type(error).__name__,'error':str(error)},indent=2)+'\n');raise
