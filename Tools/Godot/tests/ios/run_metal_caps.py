#!/usr/bin/env python3
"""Observe simulator Metal capabilities without treating unsupported Godot as a pass."""
import argparse,hashlib,json,re,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser();p.add_argument('--udid',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--probe-cube-array',action='store_true',help='An unsupported allocation may abort only this standalone diagnostic process');a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
source=root/'Tools/Godot/tests/ios/metal_caps.mm';binary=out/'metal_caps';command=['xcrun','--sdk','iphonesimulator','clang++','-target','arm64-apple-ios14.0-simulator','-std=c++17','-fobjc-arc','-framework','Foundation','-framework','Metal',str(source),'-o',str(binary)]
with (out/'build.log').open('w') as log:subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,check=True)
subprocess.run(['codesign','--force','--sign','-','--timestamp=none',str(binary)],capture_output=True,check=True)
spawn=['xcrun','simctl','spawn',a.udid,str(binary)];query=subprocess.run(spawn,capture_output=True,text=True,check=True,timeout=30);text=query.stdout+query.stderr;(out/'query.log').write_text(text)
name=re.search(r'^DEVICE (.+)$',text,re.M);assert name
families={int(family):bool(int(supported)) for family,supported in re.findall(r'^FAMILY (\d+) ([01])$',text,re.M)};assert len(families)==15
record={'probe_completed':True,'scope':'Actual iOS simulator Metal family/texture capability diagnostic only; no Godot renderer or shared-texture GPU acceptance','udid':a.udid,'device_name':name[1],'families':families,'pinned_godot_required_apple_family':4,'godot_metal_minimum_family_supported':any(families.get(f,False) for f in range(1004,1010)),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'binary_sha256':hashlib.sha256(binary.read_bytes()).hexdigest(),'command':command}
if a.probe_cube_array:
 result=subprocess.run(spawn+['--cube-array'],capture_output=True,text=True,timeout=30);text=result.stdout+result.stderr;(out/'cube-array.log').write_text(text)
 if result.returncode==0 and 'CUBE_ARRAY_ALLOCATED 1' in text:status='allocated'
 elif result.returncode!=0 and 'Texture Cube Array is not supported on this device' in text:status='rejected_by_metal'
 else:raise RuntimeError('Unclassified Metal allocation result; inspect cube-array.log')
 record['cube_array']={'status':status,'returncode':result.returncode}
(out/'capabilities.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2))
