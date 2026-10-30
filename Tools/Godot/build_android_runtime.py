#!/usr/bin/env python3
"""Build the pinned full Android runtime with Dora's host-driven EGL bridge."""
import argparse,hashlib,json,os,shutil,subprocess,tarfile,urllib.request
from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--sdk',type=Path,required=True);p.add_argument('--jobs',type=int,default=2);p.add_argument('--arch',choices=['arm64','x86_64','arm32'],default='arm64')
p.add_argument('--target',choices=['template_debug','template_release'],default='template_debug')
a=p.parse_args();build=root/'build/godot-android';deps=build/'deps';deps.mkdir(parents=True,exist_ok=True)
variant='release' if a.target=='template_release' else 'debug'
result_dir=build if a.target=='template_debug' and a.arch=='arm64' else build/variant/a.arch
result_dir.mkdir(parents=True,exist_ok=True)
package=result_dir/'package'
ndk=a.sdk/'ndk/28.1.13356709';assert (ndk/'source.properties').is_file(),'Install Android NDK28.1.13356709 with the SDK manager first'
assert 1<=a.jobs<=16
archive=deps/'godot-4.6-stable.tar.gz';expected='b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0'
if not archive.exists():
    cached=root/'build/godot-runtime/deps/godot-4.6-stable.tar.gz'
    if cached.is_file():shutil.copy2(cached,archive)
    else:urllib.request.urlretrieve('https://codeload.github.com/godotengine/godot/tar.gz/refs/tags/4.6-stable',archive)
assert hashlib.sha256(archive.read_bytes()).hexdigest()==expected
source=deps/'godot-4.6-stable'
if not source.is_dir():
    with tarfile.open(archive) as file:file.extractall(deps,filter='data')
for script in ('prepare.py','prepare_android.py'):subprocess.run(['python3',str(root/'Tools/Godot'/script),str(source)],check=True)
(source/'dora_android.map').write_text('{ global: dora_godot_get_*; Java_org_godotengine_*; local: *; };\n')
scons=root/'build/godot-runtime/venv/bin/scons';assert scons.is_file(),'Set up the Godot build venv with build_runtime.sh first'
command=[str(scons),'platform=android','arch='+a.arch,'target='+a.target,'library_type=shared_library','generate_android_binaries=no','disable_path_overrides=no','vulkan=no','opengl3=yes','swappy=no','ndk_platform=android-28','optimize='+('speed' if variant=='release' else 'none'),'debug_symbols=no','use_lto=no','linkflags=-Wl,--version-script=dora_android.map','-j'+str(a.jobs)]
env=os.environ.copy();env['ANDROID_HOME']=str(a.sdk.resolve())
compile_report=result_dir/'compilation.json';compile_report.unlink(missing_ok=True)
with (result_dir/'build.log').open('w') as log:
    result=subprocess.run(command,cwd=source,env=env,stdout=log,stderr=subprocess.STDOUT)
if result.returncode:raise SystemExit(result.returncode)
abi={'arm64':'arm64-v8a','arm32':'armeabi-v7a','x86_64':'x86_64'}[a.arch]
library=source/('platform/android/java/lib/libs/'+variant+'/'+abi+'/libgodot_android.so')
assert library.is_file(),library
subprocess.run(['python3',str(root/'Tools/Godot/package_runtime.py'),'--source',str(source),'--library',str(library),'--library-name','libgodot_android.so','--output',str(package),'--build-target',a.target],check=True)
jni=package/'jni'/abi;jni.mkdir(parents=True,exist_ok=True)
shutil.copy2(library,jni/'libgodot_android.so')
stl=source/('platform/android/java/lib/libs/'+variant+'/'+abi+'/libc++_shared.so')
assert stl.is_file(),stl
shutil.copy2(stl,jni/'libc++_shared.so')
from package_manifest import seal
from verify_package import verify
package_manifest=package/'manifest.json'
metadata=json.loads(package_manifest.read_text())
for name in ('NOTICE','NOTICE.toolchain'):
    shutil.copy2(ndk/name,package_manifest.parent/('ANDROID-NDK-'+name))
    metadata['licenses'].append('ANDROID-NDK-'+name)
package_manifest.write_text(json.dumps(seal(package_manifest.parent,metadata),indent=2)+'\n')
verify(package_manifest.parent)
record={'passed':True,'scope':'Android standard-module runtime cross-compilation only; no engine boot, Dora node or APK GPU acceptance','source_archive_sha256':expected,'prepare_android_sha256':hashlib.sha256((root/'Tools/Godot/prepare_android.py').read_bytes()).hexdigest(),'android_abi':abi,'ndk_revision':'28.1.13356709','minimum_api':28,'command':command,'runtime_sha256':hashlib.sha256(library.read_bytes()).hexdigest()}
compile_report.write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2))
