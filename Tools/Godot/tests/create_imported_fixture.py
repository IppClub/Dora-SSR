#!/usr/bin/env python3
"""Create/import/pack the project with a PNG omitted from its exported PCK.
Requires a Godot editor executable. Its version is recorded; the runtime under
validation is always the separate, pinned Dora/Godot bridge build.
"""
import argparse, hashlib, json, shutil, struct, subprocess, zlib
from pathlib import Path
from pck_manifest import files as pck_files
root=Path(__file__).resolve().parents[3]
parser=argparse.ArgumentParser()
parser.add_argument('--godot',default='godot')
parser.add_argument('--output',type=Path,default=root/'build/godot-runtime/imported-fixture')
args=parser.parse_args(); out=args.output.resolve(); project=out/'project'
out.mkdir(parents=True,exist_ok=True)
shutil.copytree(root/'Tools/Godot/tests/project',project,dirs_exist_ok=True,ignore=shutil.ignore_patterns('.godot'))
assets=project/'assets'; assets.mkdir(exist_ok=True)
def chunk(name,data):
    return struct.pack('>I',len(data))+name+data+struct.pack('>I',zlib.crc32(name+data)&0xffffffff)
png=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',16,16,8,6,0,0,0))+chunk(b'IDAT',zlib.compress((b'\0'+b'\xff\0\xff\xff'*16)*16))+chunk(b'IEND',b'')
(assets/'marker.png').write_bytes(png)
version=subprocess.check_output([args.godot,'--version'],text=True).strip()
with (out/'import.log').open('w') as log:
    subprocess.run([args.godot,'--headless','--path',str(project),'--editor','--import'],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=120)
script=project/'main.gd'; text=script.read_text()
text=text.replace('extends Node3D\n','extends Node3D\nvar packed_fixture: Texture2D = preload("res://assets/marker.png")\n')
text=text.replace('func _ready() -> void:\n','''func _ready() -> void:
    if not (packed_fixture is CompressedTexture2D) or packed_fixture.get_width() != 16:
        push_error("Packed imported texture did not load")
    var marker := Sprite2D.new()
    marker.texture = packed_fixture
    marker.position = Vector2(40, 40)
    $UI.add_child(marker)
    for index in range(2):
        var rect := ColorRect.new()
        rect.position = Vector2(72 + index * 40, 32)
        rect.size = Vector2(16, 16)
        rect.color = Color(0.5, 0.25, 0.75, 0.5 if index == 0 else 1.0)
        rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
        $UI.add_child(rect)
    var additive := ColorRect.new()
    additive.position = Vector2(152, 32)
    additive.size = Vector2(16, 16)
    additive.color = Color(1, 0, 0, 0.5)
    additive.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var blend := CanvasItemMaterial.new()
    blend.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
    additive.material = blend
    $UI.add_child(additive)
    print("GODOT_NODE_PACKED_TEXTURE width=", packed_fixture.get_width(), " height=", packed_fixture.get_height())
''');script.write_text(text)
pck=out/'project.pck'
# load_resource_pack retains the original res:// directory first. Give that
# operation a tiny, controlled project instead of recursively scanning the repo.
packer_host=out/'packer-host'; packer_host.mkdir(exist_ok=True)
(packer_host/'project.godot').write_text('config_version=5\n[application]\nconfig/name="PCK fixture host"\n')
with (out/'pack.log').open('w') as log:
    subprocess.run([args.godot,'--headless','--path',str(packer_host),'--script',str(root/'Tools/Godot/tests/create_pck.gd'),'--',str(project),str(pck)],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=120)
assert 'imported_texture=1 raw_png_present=0' in (out/'pack.log').read_text()
entries=pck_files(pck)
assert 'assets/marker.png' not in entries and 'assets/marker.png.import' in entries
assert any(n.endswith('.ctex') for n in entries)
manifest={'additive_control':True,'alpha_controls':True,'packed_files':entries,'packer_version':version,'pack_sha256':hashlib.sha256(pck.read_bytes()).hexdigest(),
    'imported_texture':'res://assets/marker.png','raw_png_present_in_pack':False,
    'imported_files':[p.name for p in sorted((project/'.godot/imported').glob('*.ctex'))]}
assert manifest['imported_files']
(out/'fixture.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(pck)
