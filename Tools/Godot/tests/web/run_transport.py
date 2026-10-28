#!/usr/bin/env python3
"""Build and run the independent-WASM WebGL2 transport probe (not Godot)."""
import argparse, hashlib, json, shutil, subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--output',type=Path,default=root/'build/godot-web/transport')
a=p.parse_args();output=a.output.resolve();output.mkdir(parents=True,exist_ok=True)
report=output/'verification.json';report.unlink(missing_ok=True)
source=root/'Tools/Godot/tests/web'
command=['em++',str(source/'gl_module.cpp'),'-O0','-std=c++17','-sMODULARIZE=1','-sEXPORT_NAME=createGLProbe','-sALLOW_MEMORY_GROWTH=1','-sMIN_WEBGL_VERSION=2','-sMAX_WEBGL_VERSION=2','-sEXPORTED_RUNTIME_METHODS=GL,HEAPU8','-sENVIRONMENT=web','--no-entry','-o',str(output/'godot-web-probe.js')]
subprocess.run(command,check=True,cwd=root)
shutil.copy2(source/'transport.html',output/'index.html')
shutil.copy2(root/'Tools/Godot/web/shared_gl.js',output/'shared_gl.mjs')
result=subprocess.run(['node',str(source/'run_browser.cjs'),str(output)],cwd=root)
if report.is_file():
 data=json.loads(report.read_text())
 files=[source/'gl_module.cpp',source/'transport.html',source/'run_browser.cjs',Path(__file__).resolve(),root/'Tools/Godot/web/shared_gl.js',output/'godot-web-probe.js',output/'godot-web-probe.wasm']
 data['sha256']={str(file.relative_to(root)) if file.is_relative_to(root) else str(file):hashlib.sha256(file.read_bytes()).hexdigest() for file in files}
 data['emscripten']=subprocess.check_output(['em++','--version'],text=True).splitlines()[0]
 data['command']=command;report.write_text(json.dumps(data,indent=2)+'\n')
raise SystemExit(result.returncode)
