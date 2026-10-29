#!/usr/bin/env python3
"""Regression: pinned upstream JS libraries survive fresh/repeated/legacy prep."""
import argparse,hashlib,shutil,subprocess,tarfile,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--archive',type=Path,default=root/'build/godot-web/deps/godot-4.6-stable.tar.gz');a=p.parse_args()
assert hashlib.file_digest(a.archive.open('rb'),'sha256').hexdigest()=='b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0'
paths=['platform/web/SCsub','platform/web/detect.py','platform/web/audio_driver_web.cpp','platform/web/js/libs/library_godot_os.js']
with tempfile.TemporaryDirectory(prefix='dora-web-prep-') as temp:
 source=Path(temp)
 with tarfile.open(a.archive) as tar:
  for name in paths:
   target=source/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(tar.extractfile('godot-4.6-stable/'+name).read())
 target=source/'modules/dora_bridge/web/web_api.cpp';target.parent.mkdir(parents=True);shutil.copy2(root/'Tools/Godot/module/web/web_api.cpp',target)
 def prepare():subprocess.run(['python3',str(root/'Tools/Godot/prepare_web.py'),str(source)],check=True)
 upstream=(source/'platform/web/SCsub').read_text();library_section=upstream[upstream.index('sys_env.AddJSLibraries('):upstream.index('for lib in sys_env["JS_LIBS"]:')]
 prepare();first={name:(source/name).read_bytes() for name in paths};assert library_section in first[paths[0]].decode()
 prepare();assert first=={name:(source/name).read_bytes() for name in paths},'Repeated prep changed bytes'
 sc=source/paths[0];text=sc.read_text();anchor='\n\nsys_env.AddJSLibraries(';assert text.count(anchor)==1;sc.write_text(text.replace(anchor,'\nsys_env.AddJSLibraries(',1))
 prepare();assert first=={name:(source/name).read_bytes() for name in paths},'Legacy one-newline block changed upstream sections'
print('Pinned Web prep: fresh, repeat and legacy block preserve all upstream JS libraries: PASS')
