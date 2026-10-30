#!/usr/bin/env python3
"""Actual Windows .NET/PInvoke GPU acceptance, separate from compilation.

Build the shared Dora test host with DORA_BUILD_CSHARP_NATIVE=1 and
DORA_BUILD_GODOT_NODE_TEST=1, then build.py --languages CSharp --output <out>.
Use a .NET host matching the native DLL architecture (e.g. x64 on ARM Windows).
"""
import argparse, collections, hashlib, json, os, re, shutil, subprocess, sys
from pathlib import Path
from constructor_rejections import prepare_recovery
root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser()
p.add_argument('--output',type=Path,default=root/'build/godot-bindings-csharp')
p.add_argument('--project',type=Path,default=root/'Tools/Godot/tests/project')
p.add_argument('--native-library',type=Path,default=root/'build/dora-csharp/native/Dora.dll')
p.add_argument('--library',type=Path,required=True,help='Matching optional Godot runtime DLL')
p.add_argument('--dotnet',default='dotnet')
p.add_argument('--verify-only',action='store_true')
p.add_argument('--constructor-rejections',action='store_true')
a=p.parse_args();assert sys.platform=='win32','The public C# native host currently supports Windows only'
out=a.output.resolve();results=out/'node-csharp';results.mkdir(parents=True,exist_ok=True)
report_path=results/'verification.json';report_path.unlink(missing_ok=True)
(results/'failure.json').unlink(missing_ok=True)
try:
    if a.constructor_rejections:
        assert json.loads((out/'compilation.json').read_text())['languages']['CSharp']['constructor_rejections'], 'Build the explicit constructor-rejection fixture first'
    if not a.verify_only:
        for name in ('run.log','artifacts.json','exports.json'):(results/name).unlink(missing_ok=True)
        native=a.native_library.resolve();library=a.library.resolve()
        fixture=out/'csharp/bin/Debug/net8.0/bindings.dll'
        assert native.is_file() and library.is_file() and fixture.is_file(), 'Build shared native host and C# fixture first'
        subprocess.run([sys.executable,str(Path(__file__).with_name('native_exports.py')),
            '--library',str(native),'--output',str(results/'exports.json')],check=True)
        assets=out/'test-assets';shutil.copytree(root/'Assets',assets,dirs_exist_ok=True)
        (assets/'Script/init.lua').write_text('return true\n')
        project=a.project.resolve();(project/'.godot').mkdir(exist_ok=True)
        (project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
        env=os.environ.copy();env.update(DORA_GODOT_TEST_PROJECT=str(project),DORA_GODOT_TEST_OUTPUT=str(results),
            DORA_GODOT_LIBRARY=str(library),DORA_GODOT_CSHARP_NATIVE_LIBRARY=str(native),
            DORA_GODOT_CSHARP_ASSETS=str(assets),DORA_GODOT_WINDOWS_GL='1',DORA_GODOT_TEST_BUFFERS='3',
            DORA_GODOT_TEST_SOAK_FRAMES='0',DORA_GODOT_TEST_TIMING='0',SDL_AUDIODRIVER='dummy')
        env.pop('DORA_GODOT_BINDING_WASM',None)
        env['DORA_GODOT_BINDING_REJECTIONS']='1' if a.constructor_rejections else '0'
        for flag in ('RESIZE','CANCEL_RESIZE','ALIASES','AUDIO','AUDIO_STALL','RESERVATION'):env['DORA_GODOT_TEST_'+flag]='1'
        env['PATH']=str(native.parent)+os.pathsep+env['PATH']
        provenance={str(path):hashlib.sha256(path.read_bytes()).hexdigest() for path in (native,library,fixture)}
        (results/'artifacts.json').write_text(json.dumps(provenance,indent=2)+'\n')
        with (results/'run.log').open('w',encoding='utf-8') as log:
            subprocess.run([a.dotnet,str(fixture)],cwd=assets,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=180)
        assert all(hashlib.sha256(Path(path).read_bytes()).hexdigest()==expected for path,expected in provenance.items()),'Native host, runtime or C# fixture changed during execution'
    verify_results=prepare_recovery(results,'CSharp') if a.constructor_rejections else results
    subprocess.run([sys.executable,str(root/'Tools/Godot/tests/verify_macos.py'),'--platform','Windows WGL',
        '--results',str(verify_results),'--resize','--cancel-resize','--aliases','--audio','--audio-stall','--reservation'],check=True)
    log=(results/'run.log').read_text(encoding='utf-8');prefix='GODOT_BINDING CSharp '
    assert log.count(prefix+'created=1')==2
    assert log.count(prefix+'abi_helpers=1')==2
    assert log.count(prefix+'unsupported_reason_empty=1')==2
    expected={'probe':2,'resume':2,'verify':2,'pause':1,'input':1,'held':1,'restart':1}
    expected.update({key:1 for key in ('resize_large','resize_small','resize_restore','verify_large','verify_small',
        'verify_restore','resize_pause','resize_resume','resize_invalid','resize_cancel')})
    actual=collections.Counter(re.findall(re.escape(prefix)+r'command=([a-z_]+)(?=\r?$)',log,re.MULTILINE))
    assert actual==expected,(dict(actual),expected)
    report=json.loads((verify_results/'verification.json').read_text());report.update(binding_language='CSharp',
        binding_transport='real .NET public App.Run and generated P/Invoke',binding_commands=expected,
        unsupported_reason_query_executed=True,
        artifacts=json.loads((results/'artifacts.json').read_text()))
    if a.constructor_rejections:
        report.update(constructor_rejections=12,raw_log_sha256=hashlib.sha256((results/'run.log').read_bytes()).hexdigest(),recovery_scope='TryCreate returns null for six invalid constructors per lifetime, then full GPU regression; raw log preserved, twelve expected errors excluded only in recovered/run.log')
    report_path.write_text(json.dumps(report,indent=2)+'\n')
    print('CSharp native bindings and GPU output: PASS',flush=True)
except BaseException as error:
    report_path.unlink(missing_ok=True)
    (results/'failure.json').write_text(json.dumps({'passed':False,'error_type':type(error).__name__,'error':str(error)},indent=2)+'\n')
    raise
