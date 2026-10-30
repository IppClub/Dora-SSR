#!/usr/bin/env python3
"""Link the verified iOS Godot archive into an embedded, symbol-isolated framework."""
import argparse,hashlib,json,plistlib,re,shutil,subprocess
from pathlib import Path
from package_manifest import seal
from verify_package import verify
root=Path(__file__).resolve().parents[2]
def digest(path):
 with path.open('rb') as file:return hashlib.file_digest(file,'sha256').hexdigest()
p=argparse.ArgumentParser();p.add_argument('--device',choices=['simulator','device'],default='simulator');a=p.parse_args()
build=root/'build/godot-ios'/a.device;compiled=json.loads((build/'compilation.json').read_text());assert compiled['passed']
archive=Path(compiled['archive']);assert digest(archive)==compiled['archive_sha256']
source=build/'deps/godot-4.6-stable';package=build/'package';framework=package/'DoraGodot.framework';framework.mkdir(parents=True,exist_ok=True)
manifest=package/'manifest.json';manifest.unlink(missing_ok=True)
sdk=Path(compiled['sdk']);target='arm64-apple-ios14.0'+('-simulator' if a.device=='simulator' else '')
clang=subprocess.check_output(['xcrun','--find','clang++'],text=True).strip()
toolchain=Path(clang).parents[2]
frameworks=['Foundation','UIKit','CoreGraphics','CoreText','CoreVideo','CoreMedia','CoreMotion','CoreHaptics','GameController','AudioToolbox','AVFoundation','AVFAudio','Metal','MetalKit','MetalFX','QuartzCore','Security','SystemConfiguration','UniformTypeIdentifiers','Accessibility','Photos','PhotosUI','VideoToolbox','WebKit']
if a.device=='simulator':frameworks.remove('MetalFX')
for name in frameworks:assert (sdk/'System/Library/Frameworks'/(name+'.framework')).is_dir(),name
command=[clang,'-target',target,'-isysroot',str(sdk),'-dynamiclib','-Wl,-all_load',str(archive),'-Wl,-dead_strip','-Wl,-exported_symbols_list,'+str(source/'dora_bridge.exports'),'-install_name','@rpath/DoraGodot.framework/DoraGodot','-L'+str(sdk/'usr/lib/swift'),'-L'+str(toolchain/'usr/lib/swift'/'iphonesimulator' if a.device=='simulator' else toolchain/'usr/lib/swift/iphoneos'),'-lc++','-lresolv','-lz','-liconv','-o',str(framework/'DoraGodot')]
for name in frameworks:command+=['-weak_framework' if name=='MetalFX' else '-framework',name]
with (build/'link.log').open('w') as log:subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,check=True)
plist={'CFBundleIdentifier':'org.ippclub.dorassr.godot.runtime','CFBundleExecutable':'DoraGodot','CFBundleName':'DoraGodot','CFBundlePackageType':'FMWK','CFBundleShortVersionString':'0.1.0','CFBundleVersion':'1','MinimumOSVersion':'14.0','CFBundleSupportedPlatforms':['iPhoneSimulator' if a.device=='simulator' else 'iPhoneOS']}
with (framework/'Info.plist').open('wb') as file:plistlib.dump(plist,file)
for origin,dest in [('LICENSE.txt','GODOT-LICENSE.txt'),('COPYRIGHT.txt','GODOT-THIRD-PARTY-NOTICES.txt')]:shutil.copy2(source/origin,framework/dest)
subprocess.run(['codesign','--force','--timestamp=none','--sign','-',str(framework)],check=True)
subprocess.run(['codesign','--verify','--strict',str(framework)],check=True)
binary=framework/'DoraGodot';symbols=subprocess.check_output(['nm','-gU',str(binary)],text=True)
exports={line.split()[-1] for line in symbols.splitlines() if line.strip()};expected={line.strip() for line in (source/'dora_bridge.exports').read_text().splitlines() if line.strip()};assert exports==expected,exports
metadata=subprocess.check_output(['xcrun','vtool','-show-build',str(binary)],text=True);assert re.search(r'platform\s+'+('IOSSIMULATOR' if a.device=='simulator' else 'IOS')+r'\s*$',metadata,re.M),metadata
r={'passed':True,'scope':'iOS framework compilation/link/signature/export inspection only; no app boot or GPU acceptance','device':a.device,'framework':str(framework),'library_sha256':digest(binary),'source_archive_sha256':compiled['source_archive_sha256'],'archive_sha256':compiled['archive_sha256'],'command':command,'exports':sorted(exports),'mach_o_build':metadata,'ad_hoc_development_signature':True,'licenses':['GODOT-LICENSE.txt','GODOT-THIRD-PARTY-NOTICES.txt']}
r['library']='DoraGodot.framework/DoraGodot'
r['licenses']=['DoraGodot.framework/'+name for name in r['licenses']]
manifest.write_text(json.dumps(seal(package,r),indent=2)+'\n');print(json.dumps(r,indent=2))
verify(package)
