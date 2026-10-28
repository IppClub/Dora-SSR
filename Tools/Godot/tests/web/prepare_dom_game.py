#!/usr/bin/env python3
"""Stage the trusted DOM GodotNode fixture without changing ordinary packages."""
import argparse,hashlib,json,os,shutil,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--package',type=Path,default=root/'build/godot-web/dom-player')
a=p.parse_args();package=a.package.resolve();stage=root/'build/godot-web/dom-game'
shutil.copytree(root/'Tools/Godot/tests/web/dom_game',stage,dirs_exist_ok=True)
shutil.copytree(root/'Tools/Godot/tests/web/dom_project',stage/'godot',dirs_exist_ok=True)
cache=stage/'godot/.godot';cache.mkdir(exist_ok=True);(cache/'global_script_class_cache.cfg').write_text('list=[]\n')
environment=os.environ.copy();environment.update(DORA_WEB_GAME_PROFILE='core',DORA_WEB_EAGER_GAME_ASSETS='0',DORA_WEB_INCLUDE_GODOT_CACHE='1')
subprocess.run(['node',str(root/'Projects/xmake/tools/web/package_web_game.mjs'),str(stage),str(package),'init.lua'],env=environment,check=True)
runtime=root/'build/godot-web/package';manifest=json.loads((runtime/'manifest.json').read_text());target=package/'godot';target.mkdir(exist_ok=True)
for name,digest in manifest['artifacts'].items():assert hashlib.sha256((runtime/name).read_bytes()).hexdigest()==digest,name
for file in runtime.iterdir():
 if file.is_file():shutil.copy2(file,target/file.name)
print('Staged trusted DOM fixture; native Godot JS/WASM hashes verified')
