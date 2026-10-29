#!/usr/bin/env python3
"""Actual .NET/public App.Run error probe. Execution is separate from acceptance."""
import argparse,hashlib,json,os,shutil,subprocess,sys,time
from pathlib import Path
import xml.sax.saxutils as xml
root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ('source-root','native-library','library','output'):p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--dotnet',required=True,help='Runtime matching the native DLL architecture')
p.add_argument('--compiler',required=True,help='Installed SDK dotnet executable')
a=p.parse_args();assert sys.platform=='win32';out=a.output.resolve();assert not out.exists();out.mkdir(parents=True)
def digest(path):
 with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def run(command,name,cwd,env,timeout=180):
 with (out/(name+'.log')).open('w',encoding='utf8') as log:
  child=subprocess.Popen(command,cwd=cwd,env=env,stdout=log,stderr=subprocess.STDOUT)
  (out/(name+'-process.json')).write_text(json.dumps({'pid':child.pid,'command':command},indent=2)+'\n')
  code=child.wait(timeout=timeout)
  assert code==0,(name,code)
try:
 started=time.monotonic();source=a.source_root.resolve();native=a.native_library.resolve();library=a.library.resolve()
 originals={str(path):digest(path) for path in (native,library)}
 stage=out/'fixture';stage.mkdir();fixture=Path(__file__).with_name('async_error.cs');shutil.copy2(fixture,stage/'main.cs')
 inputs={str(path):digest(path) for path in (source/'Tools/dora-cs/DoraCS/Dora').rglob('*.cs')}
 includes=[str(source/'Tools/dora-cs/DoraCS/Dora/**/*.cs'),str(stage/'main.cs')]
 csproj='<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><TargetFramework>net8.0</TargetFramework><OutputType>Exe</OutputType><Nullable>enable</Nullable><AllowUnsafeBlocks>true</AllowUnsafeBlocks><ImplicitUsings>enable</ImplicitUsings><EnableDefaultCompileItems>false</EnableDefaultCompileItems><TreatWarningsAsErrors>true</TreatWarningsAsErrors></PropertyGroup><ItemGroup>'+''.join('<Compile Include="'+xml.escape(path,{'"':'&quot;'})+'" />' for path in includes)+'</ItemGroup></Project>'
 (stage/'async-errors.csproj').write_text(csproj)
 env={k:v for k,v in os.environ.items() if not k.startswith(('DORA_GODOT_','DORA_BUILD_'))}
 run([a.compiler,'build',str(stage/'async-errors.csproj'),'--nologo'],'fixture-build',source,env)
 module=stage/'bin/Debug/net8.0/async-errors.dll';assert module.is_file()
 cases=[]
 for case_name in ('missing-library','missing-scene'):
  case=out/case_name;case.mkdir();assets=case/'assets';shutil.copytree(source/'Assets',assets)
  project=case/'project';shutil.copytree(source/'Tools/Godot/tests/project',project,ignore=shutil.ignore_patterns('.godot'))
  (project/'.godot').mkdir();(project/'.godot/global_script_class_cache.cfg').write_text('list=[]\n')
  expected='cannot load Dora/Godot runtime DLL, Win32 error 126' if case_name=='missing-library' else 'Godot project startup failed'
  script=Path(__file__).with_name('async_error_host.lua').read_text()
  for name,value in [('LANGUAGE','CSharp'),('EXPECTED',expected),('OUTPUT',case.as_posix())]:script=script.replace('@'+name+'@',json.dumps(value))
  (assets/'Script/init.lua').write_text(script);(case/'startup.lua').write_text(script)
  artifacts={str(path):digest(path) for path in (native,library,module,assets/'Script/init.lua')}
  native_env=env.copy();native_env.update(DORA_GODOT_CSHARP_NATIVE_LIBRARY=str(native),DORA_GODOT_CSHARP_ASSETS=str(assets),DORA_GODOT_TEST_PROJECT=str(project),DORA_GODOT_BINDING_ERROR_SCENE='res://dora-intentionally-missing-binding-scene.tscn' if case_name=='missing-scene' else 'res://main.tscn',DORA_GODOT_BINDING_EXPECTED_ERROR=expected,DORA_GODOT_WINDOWS_GL='1',SDL_AUDIODRIVER='dummy',GODOT_SILENCE_ROOT_WARNING='1',DORA_GODOT_LIBRARY=str(library) if case_name=='missing-scene' else str(case/'dora-godot-intentionally-missing.dll'))
  native_env['PATH']=str(native.parent)+os.pathsep+native_env['PATH']
  stamp=time.monotonic()
  with (case/'run.log').open('w',encoding='utf8') as log:
   child=subprocess.Popen([a.dotnet,str(module)],cwd=assets,env=native_env,stdout=log,stderr=subprocess.STDOUT)
   (case/'run-process.json').write_text(json.dumps({'pid':child.pid,'module':str(module)},indent=2)+'\n')
   code=child.wait(timeout=60)
  assert code==0,(case_name,code)
  assert all(digest(Path(path))==sha for path,sha in artifacts.items())
  record={'executed':True,'scope':'Real Windows .NET/public App.Run and generated P/Invoke; no private Godot test entry called. Reused sealed native DLL and LibGodot; complete engine cleanup is audited separately.','platform':'Windows WGL','language':'CSharp','case':case_name,'native_exit_code':code,'runtime_seconds':time.monotonic()-stamp,'expected_error_substring':expected,'artifacts':artifacts,'original':originals,'raw_log_sha256':digest(case/'run.log'),'images_sha256':{f'frame-{i}.png':digest(case/f'frame-{i}.png') for i in (1,2)}}
  (case/'execution.json').write_text(json.dumps(record,indent=2)+'\n');cases.append(record)
 assert all(digest(Path(path))==sha for path,sha in {**originals,**inputs}.items())
 (out/'execution.json').write_text(json.dumps({'executed':True,'scope':__doc__,'runtime_seconds':time.monotonic()-started,'binding_inputs':inputs,'fixture_source_sha256':digest(stage/'main.cs'),'module_sha256':digest(module),'original':originals,'cases':cases},indent=2)+'\n')
 print('Two actual C# asynchronous error executions recorded; strict diagnostics/cleanup audit required')
except BaseException as error:
 (out/'failure.json').write_text(json.dumps({'passed':False,'error':repr(error)},indent=2)+'\n');raise
