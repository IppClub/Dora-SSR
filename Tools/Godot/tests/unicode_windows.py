#!/usr/bin/env python3
"""Verify DLL/project/PCK/capture paths through the actual Windows Dora node.
Requires an already built opt-in test host and matching runtime DLL.
"""
import argparse,hashlib,json,os,shutil,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser()
p.add_argument('--library',type=Path,required=True)
p.add_argument('--project',type=Path,default=root/'Tools/Godot/tests/project')
p.add_argument('--fixture',type=Path,help='Imported PCK manifest; includes a third Unicode pack-path case')
p.add_argument('--workdir',type=Path,default=root/'build/godot-windows/unicode-fixture')
p.add_argument('--results',type=Path,default=root/'build/godot-windows/unicode-results')
a=p.parse_args()
assert sys.platform=='win32','Run the real Windows host; another OS is not a Unicode Windows path test'
work=a.workdir.resolve();out=a.results.resolve();out.mkdir(parents=True,exist_ok=True)
report=out/'verification.json';report.unlink(missing_ok=True)
assert a.library.is_file() and a.project.is_dir()
lib=work/'运行库 🚀'/a.library.name;lib.parent.mkdir(parents=True,exist_ok=True)
if lib.resolve()!=a.library.resolve():shutil.copy2(a.library,lib)
project=work/'项目 🚀'
assert not project.resolve().is_relative_to(a.project.resolve()),'Fixture copy must be outside the source project'
shutil.copytree(a.project,project,dirs_exist_ok=True)
cache=project/'.godot';cache.mkdir(exist_ok=True)
(cache/'global_script_class_cache.cfg').write_text('list=[]\n')
cases=[('dll',a.project.resolve(),out/'dll',None),('project_and_capture',project,out/'输出 🚀'/'project',None)]
if a.fixture:
    fixture=json.loads(a.fixture.read_text(encoding='utf-8'))
    pack=a.fixture.parent/'project.pck'
    assert hashlib.sha256(pack.read_bytes()).hexdigest()==fixture['pack_sha256']
    packed=work/'资源包 🚀';packed.mkdir(parents=True,exist_ok=True)
    shutil.copy2(pack,packed/'project.pck');shutil.copy2(a.fixture,packed/'fixture.json')
    cases.append(('pck_and_capture',packed/'project.pck',out/'输出 🚀'/'pck',packed/'fixture.json'))
env=os.environ.copy()
env.pop('DORA_GODOT_FIXTURE_MANIFEST',None);env.pop('DORA_GODOT_BINDING_WASM',None)
reports={}
for name,project_path,result,fixture_path in cases:
    command=[sys.executable,str(root/'Tools/Godot/test_windows.py'),'--skip-build',
        '--library',str(lib),'--project',str(project_path),'--results',str(result)]
    if fixture_path:command+=['--fixture',str(fixture_path)]
    with (out/(name+'-launcher.log')).open('w',encoding='utf-8') as log:
        subprocess.run(command,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=240)
    data=json.loads((result/'verification.json').read_text(encoding='utf-8'))
    assert data['passed'] and data['frames']==720 and data['runtime_architecture']=='x86_64'
    assert all(s['errors']==0 and s['produced']==s['completed'] for s in data['gpu_accounting'])
    if fixture_path:assert data['packaged_imported_texture'] and data['premultiplied_alpha_and_node_opacity']
    reports[name]={'report':str((result/'verification.json').relative_to(out)),
        'frames':data['frames'],'runtime_library_sha256':data['runtime_library_sha256']}
summary={'passed':True,'scope':'actual Windows GodotNode Unicode DLL/project/capture paths; PCK case only when supplied',
    'unicode_characters':'中文 🚀','cases':reports,'pck_case_included':bool(a.fixture),
    'consumer_frames':sum(v['frames'] for v in reports.values()),'capture_count':8*len(reports),'gpu_errors':0}
report.write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Windows Unicode node paths: PASS;',len(reports),'cases;',summary['consumer_frames'],'frames')
