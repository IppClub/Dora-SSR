#!/usr/bin/env python3
"""Stage the real Dora GodotNode fixture without changing ordinary packages."""
import argparse,hashlib,json,os,shutil,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--package',type=Path,default=root/'build/godot-web/dora-player');p.add_argument('--buffers',type=int,choices=[2,3,4],default=3);p.add_argument('--pack',action='store_true');p.add_argument('--godot-editor',default=shutil.which('godot') or '/Applications/Godot.app/Contents/MacOS/Godot')
p.add_argument('--audio-hold-seconds',type=float,default=0,help='Keep the first live animated scene running before input/lifecycle steps for an output audio observation')
a=p.parse_args();package=a.package.resolve()
# Concurrent browser matrices must not rewrite each other's source fixture
# while package_web_game is reading it, even if both use the same buffer count.
stage=root/'build/godot-web'/('node-game-'+str(a.buffers)+'-'+hashlib.sha256(str(package).encode()).hexdigest()[:12])
assert 0<=a.audio_hold_seconds<=3600
shutil.copytree(root/'Tools/Godot/tests/web/node_game',stage,dirs_exist_ok=True)
lua=stage/'init.lua';text=lua.read_text().replace('640, 360, 3','640, 360, '+str(a.buffers)).replace('#aliases < 3','#aliases < '+str(a.buffers))
text=text.replace('local aliases = {}','local aliases = {}\nlocal audioHold = '+str(a.audio_hold_seconds)).replace('controller:schedule(function()','controller:schedule(function(dt)')
text=text.replace('    frame = frame + 1','    if frame == 55 and audioHold > 0 then audioHold = math.max(0, audioHold - dt); return false end\n    frame = frame + 1')
lua.write_text(text)
shutil.copytree(root/'Tools/Godot/tests/web/node_project',stage/'godot',dirs_exist_ok=True)
cache=stage/'godot/.godot';cache.mkdir(exist_ok=True);(cache/'global_script_class_cache.cfg').write_text('list=[]\n')
if a.pack:
 (stage/'godot/class_cache.cfg').write_text('list=[]\n')
 subprocess.run([a.godot_editor,'--headless','--path',str((stage/'godot').resolve()),'--script',str(root/'Tools/Godot/tests/web/pack_project.gd'),'--',str((stage/'godot').resolve()),str((stage/'project.pck').resolve())],check=True)
 lua.write_text(lua.read_text().replace('/game/godot','/game/project.pck'));shutil.rmtree(stage/'godot')
else:(stage/'project.pck').unlink(missing_ok=True)
environment=os.environ.copy();environment.update(DORA_WEB_GAME_PROFILE='core',DORA_WEB_EAGER_GAME_ASSETS='0',DORA_WEB_INCLUDE_GODOT_CACHE='1')
subprocess.run(['node',str(root/'Projects/xmake/tools/web/package_web_game.mjs'),str(stage),str(package),'init.lua'],env=environment,check=True)
runtime=root/'build/godot-web/package';manifest=json.loads((runtime/'manifest.json').read_text());target=package/'godot';target.mkdir(exist_ok=True)
for name,digest in manifest['artifacts'].items():assert hashlib.sha256((runtime/name).read_bytes()).hexdigest()==digest,name
for file in runtime.iterdir():
 if file.is_file():shutil.copy2(file,target/file.name)
print('Staged buffers='+str(a.buffers)+'; native Godot JS/WASM hashes verified')
