#!/usr/bin/env python3
"""Run the portable ownership/ABI tests in an existing Linux Parallels VM.
Only writes to /tmp/dora-godot-integration; it does not alter guest packages.
"""
from pathlib import Path
import argparse, base64, json, subprocess, time
parser=argparse.ArgumentParser()
parser.add_argument('--vm',default='Ubuntu ARM64')
parser.add_argument('--output',default='build/godot-runtime/protocol-linux-arm64.json')
args=parser.parse_args()
root=Path(__file__).resolve().parents[3]
prl='/Applications/Parallels Desktop.app/Contents/MacOS/prlctl'
prefix='/tmp/dora-godot-integration'
def python(code):
    # prlctl constructs a guest command line. The outer double quotes must be
    # preserved as part of its argv; payloads are base64 and contain no quotes.
    for attempt in range(3):
        result=subprocess.run([prl,'exec',args.vm,'/usr/bin/python3','-c','"'+code+'"'],capture_output=True,text=True)
        if result.returncode == 0:
            time.sleep(0.05)
            return result.stdout
        time.sleep(0.2 * (attempt+1))
    raise RuntimeError(result.stderr+result.stdout)
for name in ['Source/Godot/GodotBridge.h','Source/Godot/GodotBridgeGL.h','Source/Godot/GodotBridgeAudio.h','Source/Godot/GodotAudioQueue.h','Source/Godot/GodotFrameRing.h','Source/Godot/GodotRenderBootQueue.h','Tools/Godot/tests/frame_ring.cpp','Tools/Godot/tests/render_boot.cpp','Tools/Godot/tests/audio_queue.cpp',
             'Source/Godot/GodotGpuReads.h','Tools/Godot/tests/gpu_reads.cpp','Tools/Godot/tests/bridge_abi.c','Tools/Godot/tests/protocol.sh']:
    path=prefix+'/'+name
    python("import pathlib; p=pathlib.Path('"+path+"'); p.parent.mkdir(parents=True,exist_ok=True); p.write_bytes(b'')")
    data=base64.b64encode((root/name).read_bytes()).decode()
    # The guest-agent command size is bounded on some Parallels versions.
    for i in range(0,len(data),512):
        python("import base64; f=open('"+path+"','r+b'); f.seek("+str(i//4*3)+"); f.write(base64.b64decode('"+data[i:i+512]+"')); f.close()")
print(python("import subprocess; raise SystemExit(subprocess.run(['/bin/bash','"+prefix+"/Tools/Godot/tests/protocol.sh']).returncode)"))
report=json.loads(python("import pathlib; print(pathlib.Path('"+prefix+"/build/godot-runtime/protocol/verification.json').read_text())"))
assert report['passed'] and report['system']=='Linux'
output=root/args.output; output.parent.mkdir(parents=True,exist_ok=True)
output.write_text(json.dumps(report,indent=2)+'\n')
