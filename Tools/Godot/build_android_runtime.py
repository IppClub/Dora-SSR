#!/usr/bin/env python3
"""Build the pinned full Android runtime with Dora's host-driven EGL bridge."""
import argparse,hashlib,json,os,re,shutil,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--sdk',type=Path,required=True);p.add_argument('--jobs',type=int,default=2);p.add_argument('--arch',choices=['arm64','x86_64','arm32'],default='arm64')
p.add_argument('--target',choices=['template_debug','template_release'],default='template_debug')
p.add_argument('--builder',choices=['auto','xmake'],default='xmake',help='Native xmake; auto is a compatibility alias')
p.add_argument('--xmake',default=os.environ.get('DORA_GODOT_XMAKE','xmake'))
p.add_argument('--build-dir',type=Path,help='Use a separate evidence/package directory')
a=p.parse_args();build=root/'build/godot-android';build.mkdir(parents=True,exist_ok=True)
a.builder='xmake'
mode='release' if a.target=='template_release' else 'debug'
xmake_arch={'arm64':'arm64-v8a','arm32':'armeabi-v7a','x86_64':'x86_64'}[a.arch]
variant='release' if a.target=='template_release' else 'debug'
result_dir=a.build_dir.resolve() if a.build_dir else (build if a.target=='template_debug' and a.arch=='arm64' else build/variant/a.arch)
result_dir.mkdir(parents=True,exist_ok=True)
package=result_dir/'package'
ndk=a.sdk/'ndk/28.1.13356709';assert (ndk/'source.properties').is_file(),'Install Android NDK28.1.13356709 with the SDK manager first'
assert 1<=a.jobs<=16
expected='b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0'
source=root/'Source/3rdParty/Godot'
for script in ('prepare.py','prepare_android.py'):subprocess.run(['python3',str(root/'Tools/Godot'/script),str(source)],check=True)
env=os.environ.copy();env['ANDROID_HOME']=str(a.sdk.resolve())
if a.builder=='xmake':
    xmake=shutil.which(a.xmake)
    if not xmake:p.error('Configured xmake executable is missing: '+a.xmake)
    version=re.search(r'xmake\s+v(\d+)\.',subprocess.check_output([xmake,'--version'],text=True))
    if not version or int(version[1])<3:p.error('Godot xmake migration requires xmake 3.x or newer')
    env['XMAKE_CONFIGDIR']=str(result_dir/'xmake-config')
    commands=[[xmake,'f','-P',str(root),'-c','-p','android','-a',xmake_arch,'-m',mode,
               '--dora_godot_runtime=y','--dora_godot_standalone=y','--ccache=n','--ndk='+str(ndk.resolve()),'--ndk_sdkver=28','--runtimes=c++_shared','-y'],
              [xmake,'build','-P',str(root),'-j'+str(a.jobs),'godot-runtime']]
names=['xmake.lua','Projects/xmake/options.lua','Projects/xmake/godot/targets.lua','Tools/Godot/generate_xmake_sources.py',
       'Projects/xmake/godot/android_'+a.arch+'_sources.lua']
inputs={name:hashlib.sha256((root/name).read_bytes()).hexdigest() for name in names}
commands.insert(1,[xmake,'l','-P',str(root),'Projects/xmake/godot/toolchain_info.lua',str(result_dir/'toolchain.json')])
(result_dir/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
compile_report=result_dir/'compilation.json';compile_report.unlink(missing_ok=True)
with (result_dir/'build.log').open('w') as log:
    for command in commands:
        result=subprocess.run(command,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT)
        if result.returncode:break
if result.returncode:raise SystemExit(result.returncode)
assert all(hashlib.sha256((root/name).read_bytes()).hexdigest()==value for name,value in inputs.items()),'Godot xmake inputs changed during the build'
abi={'arm64':'arm64-v8a','arm32':'armeabi-v7a','x86_64':'x86_64'}[a.arch]
output=root/'build/godot-xmake/android'/xmake_arch
if mode=='debug':output=output/'debug'
library=output/'lib/libgodot_android.so'
assert library.is_file(),library
package_command=['python3',str(root/'Tools/Godot/package_runtime.py'),'--source',str(source),'--library',str(library),'--library-name','libgodot_android.so','--output',str(package),'--build-target',a.target,'--graphics-backend','egl']
package_command+=['--architecture',a.arch]
subprocess.run(package_command,check=True)
jni=package/'jni'/abi;jni.mkdir(parents=True,exist_ok=True)
shutil.copy2(library,jni/'libgodot_android.so')
if a.builder=='xmake':
    candidates=list(ndk.glob('toolchains/llvm/prebuilt/*/sysroot/usr/lib/'+{'arm64':'aarch64-linux-android','arm32':'arm-linux-androideabi','x86_64':'x86_64-linux-android'}[a.arch]+'/libc++_shared.so'))
    assert len(candidates)==1,candidates
    stl=candidates[0]
assert stl.is_file(),stl
shutil.copy2(stl,jni/'libc++_shared.so')
from package_manifest import seal
from verify_package import verify
package_manifest=package/'manifest.json'
metadata=json.loads(package_manifest.read_text())
metadata.update(builder=a.builder,android_abi=abi,minimum_api=28,ndk_revision='28.1.13356709')
for name in ('NOTICE','NOTICE.toolchain'):
    shutil.copy2(ndk/name,package_manifest.parent/('ANDROID-NDK-'+name))
    metadata['licenses'].append('ANDROID-NDK-'+name)
package_manifest.write_text(json.dumps(seal(package_manifest.parent,metadata),indent=2)+'\n')
verify(package_manifest.parent)
record={'passed':True,'scope':'Android standard-module runtime cross-compilation only; no engine boot, Dora node or APK GPU acceptance','builder':a.builder,'source_archive_sha256':expected,'vendor_validation_sha256':hashlib.sha256((root/'Tools/Godot/vendor_source.py').read_bytes()).hexdigest(),'android_abi':abi,'ndk_revision':'28.1.13356709','minimum_api':28,'command':commands[-1],'commands':commands,'runtime_sha256':hashlib.sha256(library.read_bytes()).hexdigest(),'migration_inputs_sha256':inputs,'toolchain':json.loads((result_dir/'toolchain.json').read_text())}
compile_report.write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2))
