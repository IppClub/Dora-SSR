#!/usr/bin/env python3
"""Build a standard-module iOS Metal LibGodot archive."""
import argparse,hashlib,json,os,shutil,subprocess,tarfile,urllib.request
from pathlib import Path
root=Path(__file__).resolve().parents[2]
def digest(path):
 with path.open('rb') as file:return hashlib.file_digest(file,'sha256').hexdigest()
p=argparse.ArgumentParser();p.add_argument('--device',choices=['simulator','device'],default='simulator');p.add_argument('--jobs',type=int,default=2)
a=p.parse_args();assert 1<=a.jobs<=16
build=root/'build/godot-ios'/a.device;deps=build/'deps';deps.mkdir(parents=True,exist_ok=True)
expected='b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0'
archive=deps/'godot-4.6-stable.tar.gz'
if not archive.is_file():
 cached=root/'build/godot-runtime/deps/godot-4.6-stable.tar.gz'
 if cached.is_file():shutil.copy2(cached,archive)
 else:urllib.request.urlretrieve('https://codeload.github.com/godotengine/godot/tar.gz/refs/tags/4.6-stable',archive)
assert digest(archive)==expected
source=deps/'godot-4.6-stable'
if not source.is_dir():
 with tarfile.open(archive) as file:file.extractall(deps,filter='data')
for script in ('prepare.py','prepare_ios.py'):subprocess.run(['python3',str(root/'Tools/Godot'/script),str(source)],check=True)
scons=root/'build/godot-runtime/venv/bin/scons';assert scons.is_file()
command=[str(scons),'platform=ios','arch=arm64','target=template_debug','library_type=static_library','disable_path_overrides=no','simulator='+('yes' if a.device=='simulator' else 'no'),'metal=yes','vulkan=no','generate_bundle=no','optimize=none','debug_symbols=no','lto=none','-j'+str(a.jobs)]
report=build/'compilation.json';report.unlink(missing_ok=True)
with (build/'build.log').open('w') as log:result=subprocess.run(command,cwd=source,stdout=log,stderr=subprocess.STDOUT)
if result.returncode:raise SystemExit(result.returncode)
archives=list((source/'bin').glob('libgodot.ios.template_debug.arm64*.a'));assert len(archives)==1,archives
sdk_name='iphonesimulator' if a.device=='simulator' else 'iphoneos'
sdk=subprocess.check_output(['xcrun','--sdk',sdk_name,'--show-sdk-path'],text=True).strip()
# Keep the archive as the primary compilation artifact. Framework linkage is a
# separate step so native compile success never implies simulator/GPU acceptance.
r={'passed':True,'scope':'iOS standard-module Metal LibGodot archive compilation only; no native app boot or GPU acceptance','device':a.device,'architecture':'arm64','sdk':sdk,'source_archive_sha256':expected,'command':command,'archive':str(archives[0]),'archive_sha256':digest(archives[0]),'prepare_ios_sha256':hashlib.sha256((root/'Tools/Godot/prepare_ios.py').read_bytes()).hexdigest()}
report.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
