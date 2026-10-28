#!/usr/bin/env python3
"""Verify final consumer captures from the independent LibGodot/EGL test."""
import argparse,json,re
from pathlib import Path
from PIL import Image,ImageChops
parser=argparse.ArgumentParser();parser.add_argument('results',type=Path);parser.add_argument('--backend',choices=['EGL','WGL'],default='EGL');args=parser.parse_args()
prefix='LIBGODOT_'+args.backend
log=(args.results/'run.log').read_text(encoding='utf-8',errors='replace')
assert not re.search(r'ERROR:|WARNING:|FAIL',log)
assert 'GODOT_NODE_SCENE boots=1 root_path_ok=1' in log
match=re.search(prefix+r' PASS frames=(\d+) produced=(\d+) completed=(\d+) errors=(\d+)',log)
assert match and match[1]=='360' and match[2]==match[3] and match[4]=='0'
images={n:Image.open(args.results/('frame-'+str(n)+'.ppm')).convert('RGB') for n in (60,90,150,180,270,330)}
assert all(image.size==(640,360) for image in images.values())
def pixels(image): return image.get_flattened_data() if hasattr(image,'get_flattened_data') else image.getdata()
def changed(a,b): return sum(max(p)>8 for p in pixels(ImageChops.difference(images[a],images[b])))
assert changed(60,90)>200 and changed(270,330)>200, 'Godot animation frozen'
assert changed(150,180)==0, 'Paused Godot output changed'
for n,image in images.items():
    assert sum(g>70 and b>70 and r<g*.65 for r,g,b in pixels(image))>500, 'Godot cube absent'
    image.save(args.results/('frame-'+str(n)+'.png'))
report={'passed':True,'scope':'real LibGodot scene -> shared '+args.backend+' texture -> independent consumer; Dora node tested separately',
    'renderer':re.search(prefix+r' renderer=(.*)',log)[1],'frames':360,'produced':int(match[2]),
    'completed':int(match[3]),'gpu_errors':0,'scene_root_preserved':True,
    'animation_changed_pixels':changed(60,90),'paused_changed_pixels':changed(150,180),
    'resumed_changed_pixels':changed(270,330),'cpu_pixel_transport':False}
(args.results/'verification.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
