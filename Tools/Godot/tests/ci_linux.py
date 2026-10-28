#!/usr/bin/env python3
"""Linux CI entry: build real runtimes, then execute the strict EGL matrix.

Protocol/package checks alone never produce this GPU acceptance report.
"""
import argparse,hashlib,json,os,platform,subprocess,sys,time
from pathlib import Path
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--output',type=Path,default=root/'build/godot-runtime/ci-linux')
p.add_argument('--skip-build',action='store_true',help='Use explicitly prebuilt artifacts for local reproduction; not the workflow default')
p.add_argument('--ordinary-binary',type=Path,help='Explicit prebuilt ordinary host, required with --skip-build')
p.add_argument('--jobs',type=int,default=2)
a=p.parse_args();assert sys.platform=='linux' and 1<=a.jobs<=16
out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
report=out/'verification.json';report.unlink(missing_ok=True);(out/'failure.json').unlink(missing_ok=True)
env=os.environ.copy()
for key in list(env):
    if key.startswith(('DORA_GODOT_TEST_','DORA_GODOT_BINDING_')):env.pop(key)
env.update(DORA_BUILD_GODOT_NODE_TEST='1',JOBS=str(a.jobs))
def run(command,name,timeout=3600):
    with (out/name).open('w') as log:
        subprocess.run(command,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=timeout)
def digest(path):
    with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
try:
    started=time.monotonic()
    arch={'aarch64':'arm64','x86_64':'x86_64'}.get(platform.machine());assert arch,'Unsupported CI CPU'
    assert a.skip_build or not a.ordinary_binary,'--ordinary-binary is only for prebuilt reproduction'
    if a.skip_build:assert a.ordinary_binary and a.ordinary_binary.is_file(),'--skip-build requires an explicit --ordinary-binary'
    ordinary=(a.ordinary_binary or root/f'build/linux/{arch}/debug/Dora').resolve()
    env['DORA_GODOT_PROTOCOL_OUTPUT']=str(out/'protocol')
    run(['bash','Tools/Godot/tests/protocol.sh'],'protocol.log')
    run([sys.executable,'Tools/Godot/tests/package_integrity.py'],'package-tests.log')
    if not a.skip_build:
        run(['bash','Tools/Godot/build_linux_runtime.sh'],'runtime-build-launcher.log')
        run(['xmake','f','-y','-p','linux','-a',arch,'-m','debug'],'host-configure.log')
        run(['xmake','build','-j'+str(a.jobs),'Dora'],'host-build.log')
    binary=Path(env.get('DORA_GODOT_DORA_BINARY',root/'build/godot-runtime/dora/Dora')).resolve()
    library=Path(env.get('DORA_GODOT_LIBRARY',root/'build/godot-linux/package/libdora_godot.so')).resolve()
    assert binary.is_file() and library.is_file()
    artifacts={str(path):digest(path) for path in (binary,library)}
    (out/'artifacts.json').write_text(json.dumps(artifacts,indent=2)+'\n')
    run([sys.executable,'Tools/Godot/verify_package.py',str(library.parent),'--output',str(out/'package-integrity.json')],'package-integrity.log')
    init_failure_reports=[]
    for mode in ('exit','recover'):
        case=out/('init-failure-'+mode)
        run([sys.executable,'Tools/Godot/tests/with_weston.py','--logs',str(out/('weston-init-failure-'+mode)),
            '--',sys.executable,'Tools/Godot/tests/run_init_failure.py','--binary',str(binary),
            '--library',str(library),'--output',str(case),'--mode',mode], 'init-failure-'+mode+'.log',timeout=300)
        data=json.loads((case/'verification.json').read_text());assert data['passed'] and data['native_exit_code']==0
        assert all(digest(Path(path))==sha for path,sha in artifacts.items()),'Artifacts changed during initialization-failure tests'
        init_failure_reports.append({'mode':mode,'report':str(case/'verification.json'),'captures':data['captures']})
    env.update(DORA_GODOT_SKIP_BUILD='1',DORA_GODOT_LIBRARY=str(library),DORA_GODOT_DORA_BINARY=str(binary))
    for flag in ('AUDIO','AUDIO_STALL','CONTROLLER','RESIZE','CANCEL_RESIZE','ALIASES','RESERVATION'):env['DORA_GODOT_TEST_'+flag]='1'
    cases=[]
    for buffers in (2,3,4):
        case=out/f'case-{buffers}'
        env.update(DORA_GODOT_TEST_BUFFERS=str(buffers),DORA_GODOT_NODE_RESULTS=str(case))
        run([sys.executable,'Tools/Godot/tests/with_weston.py','--logs',str(out/f'weston-{buffers}'),'--','bash','Tools/Godot/test_linux.sh'],f'case-{buffers}.log',timeout=600)
        data=json.loads((case/'verification.json').read_text());assert data['passed'] and data['platform']=='Linux EGL'
        assert all(digest(Path(path))==sha for path,sha in artifacts.items()),'Artifacts changed during matrix'
        cases.append({'buffers':buffers,'report':str(case/'verification.json'),'frames':data['frames'],'renderer':data['godot_renderer']})
    # The cycle fixture is a separate mode: keep audio, clear other scenario flags.
    for key in list(env):
        if key.startswith('DORA_GODOT_TEST_'):env.pop(key)
    cycle=out/'cycles-100'
    env.update(DORA_GODOT_TEST_CYCLES='100',DORA_GODOT_TEST_BUFFERS='3',DORA_GODOT_TEST_AUDIO='1',DORA_GODOT_NODE_RESULTS=str(cycle))
    run([sys.executable,'Tools/Godot/tests/with_weston.py','--logs',str(out/'weston-cycles'),'--','bash','Tools/Godot/test_linux.sh'],'cycles.log',timeout=1500)
    cycle_data=json.loads((cycle/'verification.json').read_text());assert cycle_data['passed'] and cycle_data['cycles']==100
    assert all(digest(Path(path))==sha for path,sha in artifacts.items()),'Artifacts changed during cycles'
    # Build the ordinary application separately. Its output path differs from
    # the test host, and both bytes must remain stable throughout acceptance.
    for key in list(env):
        if key.startswith('DORA_GODOT_TEST_'):env.pop(key)
    env.pop('DORA_BUILD_GODOT_NODE_TEST',None)
    if not a.skip_build:run(['xmake','build','-j'+str(a.jobs),'Dora'],'ordinary-host-build.log')
    assert ordinary.is_file(),'Ordinary host was not built'
    assert all(digest(Path(path))==sha for path,sha in artifacts.items()),'Ordinary build changed test artifacts'
    artifacts[str(ordinary)]=digest(ordinary)
    (out/'artifacts.json').write_text(json.dumps(artifacts,indent=2)+'\n')
    ordinary_reports=[]
    for name,script in (('ordinary-project-boundary','run_project_boundary_linux.py'),('ordinary-app','run_ordinary_linux.py')):
        case=out/name
        run([sys.executable,'Tools/Godot/tests/with_weston.py','--logs',str(out/('weston-'+name)),'--',sys.executable,'Tools/Godot/tests/'+script,'--binary',str(ordinary),'--library',str(library),'--output',str(case)],name+'.log',timeout=600)
        data=json.loads((case/'verification.json').read_text());assert data['passed'] and data['platform']=='Linux EGL'
        assert all(digest(Path(path))==sha for path,sha in artifacts.items()),'Artifacts changed during ordinary acceptance'
        captures=data.get('captures',sum(item['captures'] for item in data.get('cases',[])))
        ordinary_reports.append({'case':name,'report':str(case/'verification.json'),'captures':captures})
    source_hashes={str(path.relative_to(root)):digest(path) for folder in ('Source/Godot','Tools/Godot') for path in (root/folder).rglob('*') if path.is_file() and '__pycache__' not in path.parts and '.godot' not in path.parts}
    source_hashes.update({name:digest(root/name) for name in (
        'Source/Node/Sprite.cpp','Source/3rdParty/bgfx/dora/BgfxEmbeddedShaders.hpp','Projects/xmake/engine.lua')})
    (out/'sources.json').write_text(json.dumps(source_hashes,indent=2)+'\n')
    report.write_text(json.dumps({'passed':True,'scope':'Actual Linux EGL GodotNode GPU API execution, invalid-shader teardown/recovery, repeated clients and ordinary-host bundled/missing-library/project-boundary checks; renderer/CPU recorded, not a physical-GPU or distribution claim','system':platform.platform(),'machine':platform.machine(),'build_skipped':a.skip_build,'runtime_seconds':time.monotonic()-started,'artifacts':artifacts,'init_failure_reports':init_failure_reports,'cases':cases,'cycles_report':str(cycle/'verification.json'),'ordinary_reports':ordinary_reports,'github':{key:os.environ.get(key) for key in ('GITHUB_ACTIONS','GITHUB_REPOSITORY','GITHUB_SHA','GITHUB_RUN_ID')}},indent=2)+'\n')
    print('Linux CI EGL matrix, 100 cycles and ordinary-host regressions: PASS',flush=True)
except BaseException as error:
    report.unlink(missing_ok=True)
    (out/'failure.json').write_text(json.dumps({'passed':False,'type':type(error).__name__,'error':str(error)},indent=2)+'\n');raise
