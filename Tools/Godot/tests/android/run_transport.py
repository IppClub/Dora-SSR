#!/usr/bin/env python3
"""NDK-build and execute the real shared-EGL transport on one Android target.

This checks two native EGL contexts, fences and GPU pixels. It does NOT boot
LibGodot, instantiate Dora/GodotNode, or validate an APK's lifecycle/input.
"""
import argparse,hashlib,json,os,re,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser();p.add_argument('--serial',required=True);p.add_argument('--ndk',type=Path,required=True);p.add_argument('--adb',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True);report=out/'verification.json';report.unlink(missing_ok=True)
adb=[str(a.adb),'-s',a.serial]
assert a.ndk.is_dir() and a.adb.is_file()
compiler=a.ndk/'toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android28-clang++';assert compiler.is_file()
properties={}
for name in ('ro.product.cpu.abi','ro.build.version.sdk','ro.kernel.qemu','ro.hardware.egl'):
 properties[name]=subprocess.check_output(adb+['shell','getprop',name],text=True,timeout=30).strip()
assert properties['ro.product.cpu.abi']=='arm64-v8a',properties
remote='/data/local/tmp/dora-godot-01a17dc1/egl-transport'
subprocess.run(adb+['shell','mkdir','-p',remote],check=True,timeout=30)
artifacts={};logs={}
for case,source in [('transport','transport.cpp'),('host-targets','host_targets.cpp')]:
 sources=[root/'Tools/Godot/tests/gl'/source,root/'Tools/Godot/module/gl/egl_transport.cpp']
 binary=out/case
 command=[str(compiler),'-std=c++20','-O0','-g','-Wall','-Wextra','-Werror','-static-libstdc++','-I',str(root)]+[str(s) for s in sources]+['-lEGL','-lGLESv3','-o',str(binary)]
 with (out/(case+'-build.log')).open('w') as log:subprocess.run(command,cwd=root,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=180)
 artifacts[case]={'binary_sha256':hashlib.sha256(binary.read_bytes()).hexdigest(),'sources':{str(s.relative_to(root)):hashlib.sha256(s.read_bytes()).hexdigest() for s in sources}}
 subprocess.run(adb+['push',str(binary),remote+'/'+case],check=True,timeout=60,capture_output=True)
 subprocess.run(adb+['shell','chmod','700',remote+'/'+case],check=True,timeout=30)
 with (out/(case+'-run.log')).open('w') as log:subprocess.run(adb+['shell',remote+'/'+case],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=180)
 logs[case]=(out/(case+'-run.log')).read_text(errors='replace')
assert 'EGL_TRANSPORT PASS consumers=3600 sampled_frames=99' in logs['transport']
assert 'GL_TARGETS PASS buffers=2,3,4 generations=3 samples=54 host_ownership_preserved=1' in logs['host-targets']
renderer=re.search(r'EGL_TRANSPORT renderer=(.*?) version=(.*)',logs['transport']);assert renderer
r={'passed':True,'scope':'actual Android native two-context EGL GPU transport only; no LibGodot boot, Dora node or APK validation','serial':a.serial,'properties':properties,'emulator':properties['ro.kernel.qemu']=='1','renderer':renderer[1],'gl_version':renderer[2],'buffers':[2,3,4],'consumer_frames':3600,'transport_pixel_samples':99,'target_generation_pixel_samples':54,'ndk_source_properties':(a.ndk/'source.properties').read_text(),'artifacts':artifacts,'production_cpu_pixel_transport':False}
report.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
