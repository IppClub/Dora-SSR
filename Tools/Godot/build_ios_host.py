#!/usr/bin/env python3
"""Build an isolated Dora iOS Godot test app through the owning xmake graph."""
import argparse,fcntl,hashlib,json,os,plistlib,re,shutil,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--device',choices=['simulator','device'],default='simulator');p.add_argument('--jobs',type=int,default=2);a=p.parse_args();assert sys.platform=='darwin' and 1<=a.jobs<=16
build=root/'build/godot-ios';build.mkdir(parents=True,exist_ok=True);lock=(build/'host-build.lock').open('w');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
assets=build/'test-assets';shutil.copytree(root/'Assets',assets,dirs_exist_ok=True);(assets/'Script/init.lua').write_text('return true\n')
config=build/('host-config' if a.device=='simulator' else 'host-device-config');objects=build/('host-build' if a.device=='simulator' else 'host-device-build')
env=os.environ.copy();env.update(XMAKE_CONFIGDIR=str(config),DORA_BUILD_GODOT_NODE_TEST='1')
xmake=shutil.which('xmake');assert xmake
commands=[[xmake,'f','-y','-p','iphoneos','-a','arm64','-m','debug','--appledev='+('simulator' if a.device=='simulator' else 'iphoneos'),'--builddir='+str(objects),'--ccache=n','--xcode_codesign_identity=n'],[xmake,'build','-j',str(a.jobs),'Dora']]
# xmake's app rule caches the binary/directory rather than installfile contents.
# Invalidate only this owned test bundle cache to refresh staged assets/signing.
cache=root/('build/.deps/godot-ios-'+a.device+'/Dora/iphoneos/arm64/debug/Dora.app.d');cache.unlink(missing_ok=True)
report=build/a.device/'host-compilation.json';report.parent.mkdir(parents=True,exist_ok=True);report.unlink(missing_ok=True)
with (build/a.device/'host-build.log').open('w') as log:
 for command in commands:subprocess.run(command,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
app=build/'host'/a.device/'arm64/debug/Dora.app';binary=app/'Dora'
with (app/'Info.plist').open('rb') as file:info=plistlib.load(file)
assert info['CFBundleIdentifier']=='org.ippclub.dorassr.godotprototype.ios'
assert (app/'Script/init.lua').read_bytes()==b'return true\n'
assert info['UIApplicationSupportsIndirectInputEvents'] is True
subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True,capture_output=True)
symbols=subprocess.check_output(['nm','-gU',str(binary)],text=True);assert '_dora_godot_node_test_main' in symbols and '_dora_godot_node_test_finish' in symbols
metadata=subprocess.check_output(['xcrun','vtool','-show-build',str(binary)],text=True);assert re.search(r'platform\s+'+('IOSSIMULATOR' if a.device=='simulator' else 'IOS')+r'\s*$',metadata,re.M)
with binary.open('rb') as file:sha=hashlib.file_digest(file,'sha256').hexdigest()
r={'passed':True,'scope':'iOS Dora test-host build, signing and isolated asset inspection only; no runtime/GPU acceptance','device':a.device,'app':str(app),'native_host_sha256':sha,'bundle':info['CFBundleIdentifier'],'isolated_test_entry':True,'native_test_harness_linked':True,'indirect_mouse_enabled':True,'mach_o_build':metadata,'commands':commands,'ad_hoc_development_signature':True}
report.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
