#!/usr/bin/env python3
from pathlib import Path
import argparse, hashlib, json, re
from pck_manifest import files as pck_files
from PIL import Image, ImageChops
root=Path(__file__).resolve().parents[3]
parser=argparse.ArgumentParser()
parser.add_argument('--results',type=Path,default=root/'build/godot-runtime/node-results')
parser.add_argument('--platform',default='macOS Metal',choices=['macOS Metal','Linux EGL','Windows WGL','Android EGL','iOS Metal'])
parser.add_argument('--fixture',type=Path)
parser.add_argument('--audio',action='store_true',help='Require actual Godot stereo tone delivery to the host mixer callback')
parser.add_argument('--cancel-resize',action='store_true',help='Require removal immediately after an accepted resize request')
parser.add_argument('--reservation',action='store_true',help='Require failed competing node creation to preserve the original owner')
parser.add_argument('--resize',action='store_true',help='Require real viewport texture size switches without scene reboot')
parser.add_argument('--soak-frames',type=int,default=0,help='Additional animation frames sampled every 300 frames')
parser.add_argument('--audio-stall',action='store_true',help='Require two injected 250 ms render stalls and zero audio underruns')
parser.add_argument('--aliases',action='store_true',help='Verify three retained Sprite texture aliases across node removal')
parser.add_argument('--ime',action='store_true',help='Require automatic Godot Control IME lifecycle and OS-originated Windows Unicode commit')
parser.add_argument('--controller',action='store_true',help='Require Dora standard controller button/axis forwarding into Godot')
parser.add_argument('--buffers',type=int,choices=[2,3,4],default=3)
args=parser.parse_args()
assert not args.cancel_resize or args.resize, "--cancel-resize requires --resize"
assert not (args.resize and args.soak_frames), "Run resize and soak as separate cases"
results=args.results
(results/'verification.json').unlink(missing_ok=True)
log=(results/'run.log').read_text(encoding='utf-8',errors='replace')
assert not re.search(r'ERROR:|WARNING:|GodotNode:|BGFX LEAK:|GODOT_NODE_TEST FAIL',log), 'Runtime errors in run.log'
if args.platform in ('macOS Metal','iOS Metal'):
    assert 'Metal API Validation Enabled' in log
else:
    assert 'OpenGL API' in log and 'Compatibility' in log, 'Godot GL renderer missing'
for message in ['GODOT_NODE_SCENE boots=1 root_path_ok=1','GODOT_NODE_SCENE boots=2 root_path_ok=1','GODOT_NODE_SCENE boots=3 root_path_ok=1',
                'GODOT_NODE_FOCUS released=1','GODOT_NODE_INPUT_STATE mouse=1','GODOT_NODE_INPUT_STATE key=1 action=1','GODOT_NODE_POINTER x=240 y=310','GODOT_NODE_KEY space=1','GODOT_NODE_TEXT value=Dora',f'frames={(1000 if args.resize else 720)+args.soak_frames} captures={(9 if args.aliases else 8)+args.soak_frames//300+(6 if args.resize else 0)} recreated=1 result=0']:
    assert message in log, message
assert log.count('GODOT_NODE_PREBOOT_PAUSE paused=1 ticking=1')==2
names=['animated-a.png','animated-b.png','paused-a.png','paused-b.png','input.png','restarted.png','recreated.png','opacity.png']
images={n:Image.open(results/n).convert('RGB') for n in names}
assert len({i.size for i in images.values()})==1
if args.platform in ('Android EGL','iOS Metal'):
    # Dora capture limits the longer edge to 1280; portrait mobile output is
    # consequently narrower than the desktop-only 640px minimum.
    viewport=re.search(r'GODOT_NODE_VIEW buffer=(\d+)x(\d+) scale=1.25',log)
    assert viewport, 'Missing native mobile output dimensions'
    width,height=map(int,viewport.groups());scale=min(1,1280/max(width,height))
    expected=(max(1,int(width*scale)),max(1,int(height*scale)))
    assert all(i.size==expected for i in images.values()), ('Mobile capture dimensions',expected)
else:
    assert all(i.width>=640 and i.height>=360 for i in images.values())
if args.platform=='macOS Metal': assert all(i.size==(1280,720) for i in images.values())
def data(image): return image.get_flattened_data() if hasattr(image,'get_flattened_data') else image.getdata()
def changed(a,b): return sum(max(p)>8 for p in data(ImageChops.difference(images[a],images[b])))
assert changed('animated-a.png','animated-b.png') > 500
assert changed('paused-a.png','paused-b.png') == 0
for name in ['animated-a.png','restarted.png','recreated.png']:
    assert sum(g>70 and b>70 and r<g*.65 for r,g,b in data(images[name])) > 1000, name
assert sum(r>100 and r>g*2 and r>b*1.8 for r,g,b in data(images['input.png'])) > 1000
accounting=re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
assert len(accounting)==2 and all(int(p)==int(c) and int(e)==0 and int(p)>100 for p,c,e in accounting)
report={'passed':True,'platform':args.platform,'capture_size':list(images[names[0]].size),'scene_root_and_autoload_preserved':True,'animation':True,'pause_resume':True,'preboot_pause_and_always_processing':True,
        'pointer_key_text_input':True,'global_input_and_action_state':True,'focus_loss_releases_held_input':True,'scene_restart':True,'node_remove_recreate':True,'frames':(1000 if args.resize else 720)+args.soak_frames,
        'changed_animation_pixels':changed('animated-a.png','animated-b.png'),'changed_paused_pixels':0,
        'gpu_accounting':[{'produced':int(p),'completed':int(c),'errors':int(e)} for p,c,e in accounting]}
if args.ime:
    assert args.platform=='Windows WGL', 'The native OS-injection acceptance currently targets Windows'
    assert log.count('GODOT_NODE_IME_FOCUS active=1')==3, 'Godot LineEdit did not focus for all scene lifetimes'
    assert 'GODOT_NODE_HOST_IME stage=first active=1' in log
    assert 'GODOT_NODE_HOST_IME stage=removed active=0' in log
    assert 'GODOT_NODE_HOST_IME stage=second active=1' in log
    assert re.search(r'GODOT_NODE_TEXT value=.*WinIME中',log), 'OS-originated Unicode commit did not reach Godot LineEdit'
    report['automatic_control_ime_lifecycle']=True
    report['os_originated_unicode_commit']='WinIME中'
    report['composition_candidate_ui_tested']=False
if args.controller:
    for marker in ('GODOT_NODE_CONTROLLER_BUTTON device=7 pressed=1 state=1','GODOT_NODE_CONTROLLER_BUTTON device=7 pressed=0 state=0','GODOT_NODE_CONTROLLER_AXIS device=7 value=0.75','GODOT_NODE_CONTROLLER_AXIS device=7 value=0.0','GODOT_NODE_CONTROLLER_FOCUS released=1'):
        assert marker in log,marker
    report['controller_button_axis_forwarding']=True
    report['controller_focus_loss_releases_held_input']=True
if args.reservation:
    probes=re.findall(r'GODOT_NODE_RESERVATION stage=(\d+) rejected=(\d+)',log)
    assert probes==[(str(stage),'1') for stage in (0,100,110,560,570)], ('Runtime reservation ownership violated',probes)
    assert log.count('GODOT_NODE_SCENE boots=')==3, 'Competing create changed the active project'
    report['competing_nodes_rejected_preserving_runtime']=True
    trees=re.findall(r'GODOT_NODE_RESERVATION_TREE stage=(\d+) nodes=(\d+)',log)
    assert trees==[('115','1'),('575','1')], ('Failed nodes adopted into scene',trees)
    report['reservation_probes']=5
    report['failed_nodes_absent_from_scene']=True
if args.platform in ('Linux EGL','Windows WGL','Android EGL'):
    report['counter_scope']='cumulative per process'
    match=re.search(r'OpenGL API (.+)',log)
    report['godot_renderer']=match.group(1)
if args.audio_stall:
    assert args.audio, '--audio-stall requires --audio'
    assert log.count('GodotAudio test render stall: 250 ms')==2
    report['audio_render_stalls_ms']=[250,250]
if args.audio:
    assert log.count('GODOT_NODE_AUDIO tone=440,660 rate=48000 channels=2')==3
    drained=re.findall(r'GodotAudio drained: produced=(\d+), consumed=(\d+), nonzeroProduced=(\d+), nonzeroConsumed=(\d+), underrunFrames=(\d+)',log)
    assert len(drained)==2, 'Both node audio sources must drain'
    for produced,consumed,nonzero_produced,nonzero_consumed,underruns in map(lambda v:map(int,v),drained):
        assert produced>=consumed>48000 and nonzero_produced>=nonzero_consumed>48000
        assert nonzero_produced<=produced*2 and nonzero_consumed<=consumed*2
        assert underruns==0, ('Host audio source underrun',underruns)
    tones=re.findall(r'GodotAudio tone: frames=(\d+), leftCrossings=(\d+), rightCrossings=(\d+)',log)
    assert len(tones)==2
    for frames,left,right in map(lambda v:map(int,v),tones):
        assert frames==48000 and abs(left-440)<=3 and abs(right-660)<=3, ('Stereo tone/clock/channel mismatch',frames,left,right)
    report['godot_pcm_to_host_mixer_callback']=True
    report['audio_sample_rate']=48000
    report['audio_channels']=2
    report['audio_device_audibility_tested']=False
    report['audio_accounting']=[dict(zip(('produced','consumed','nonzero_produced','nonzero_consumed','underrun_frames'),map(int,v))) for v in drained]
if args.resize:
    assert log.count('GODOT_NODE_SCENE boots=')==3, 'Resize restarted the scene'
    assert log.count('GodotRuntime resized:')==3, 'Unexpected extra texture generations'
    expected=[(800,450,0),(320,180,1),(640,360,0)]
    for generation,(width,height,paused) in enumerate(expected,1):
        assert f'GodotRuntime resized: width={width}, height={height}, generation={generation}' in log
        assert f'GODOT_NODE_RESIZE width={width} height={height} result=0' in log
        assert f'GODOT_NODE_VIEWPORT width={width} height={height} paused={paused}' in log
    viewport=re.search(r'GODOT_NODE_VIEW buffer=(\d+)x(\d+) scale=1.25',log)
    assert viewport
    host_w,host_h=map(int,viewport.groups())
    resize_names=[('resized-large-a.png',800,450),('resized-large-b.png',800,450),
                  ('resized-small-a.png',320,180),('resized-small-b.png',320,180),
                  ('resized-small-motion.png',320,180),('resized-restored.png',640,360)]
    for name,width,height in resize_names:
        image=Image.open(results/name).convert('RGB')
        assert image.size==images[names[0]].size
        sx,sy=image.width/host_w,image.height/host_h
        for x,y in ((10,10),(width-10,10),(10,height-10),(width-10,height-10)):
            pixel=image.getpixel((round(image.width/2+(x-width/2)*1.25*sx),round(image.height/2+(y-height/2)*1.25*sy)))
            assert pixel[0]>235 and pixel[2]>235 and pixel[1]<20, ('Resize corner missing/cropped/scaled',name,pixel)
        if args.aliases:
            # Check the active resized texture too, not just frozen old aliases.
            # The stamp redraws on viewport resize even while simulation is paused.
            codes=[]
            for y in (16,height-16):
                code=0
                for bit in range(16):
                    x=width*0.2+(bit+0.5)*width*0.6/16
                    pixel=image.getpixel((round(image.width/2+(x-width/2)*1.25*sx),round(image.height/2+(y-height/2)*1.25*sy)))
                    assert max(pixel)-min(pixel)<8 and (max(pixel)<40 or min(pixel)>210), ('Unclear resized stamp',name,pixel)
                    if min(pixel)>210:code|=1<<bit
                codes.append(code)
            assert codes[0]==codes[1] and codes[0]>0, ('Torn resized texture',name,codes)
        outside=image.getpixel((round(image.width/2+(width/2+10)*1.25*sx),round(image.height/2+(height/2+10)*1.25*sy)))
        assert max(abs(c-b) for c,b in zip(outside,(25,35,49)))<=3, ('Resize did not update node bounds',name,outside)
        images[name]=image
    def resized_scene_changed(a,b,width,height):
        image=images[a];sx,sy=image.width/host_w,image.height/host_h
        box=(round(image.width/2-width*.2*1.25*sx),round(image.height/2-height*.3*1.25*sy),
             round(image.width/2+width*.2*1.25*sx),round(image.height/2+height*.3*1.25*sy))
        return sum(max(p)>8 for p in data(ImageChops.difference(images[a].crop(box),images[b].crop(box))))
    large_scene=resized_scene_changed('resized-large-a.png','resized-large-b.png',800,450)
    small_scene=resized_scene_changed('resized-small-b.png','resized-small-motion.png',320,180)
    assert large_scene>10 and small_scene>10, ('Resized cube scene froze',large_scene,small_scene)
    report['resize_scene_changed_pixels']={'large':large_scene,'resumed_small':small_scene}
    assert changed('resized-large-a.png','resized-large-b.png')>500
    assert changed('resized-small-a.png','resized-small-b.png')==0
    assert changed('resized-small-b.png','resized-small-motion.png')>500
    report['viewport_resize_dimensions']=[[w,h] for w,h,_ in expected]
    report['resize_kept_scene_and_pause']=True
    report['resize_audio_verified']=args.audio
    if args.cancel_resize:
        assert 'GODOT_NODE_RESIZE_CANCEL accepted=1' in log
        report['remove_during_resize']=True
    report['resize_corner_and_node_bounds_samples']=30
    report['active_resized_stamp_pairs']=6 if args.aliases else 0
if args.soak_frames:
    assert args.soak_frames>0 and args.soak_frames%300==0
    assert f'GODOT_NODE_SOAK frames={args.soak_frames} samples={args.soak_frames//300}' in log
    samples=sorted(results.glob('soak-*.png'),key=lambda p:int(p.stem.split('-')[1]))
    assert len(samples)==args.soak_frames//300
    previous=None
    for path in samples:
        image=Image.open(path).convert('RGB')
        assert image.size==images[names[0]].size
        if previous is not None:
            # Restrict to the central scene, excluding the alias barcodes.
            box=(image.width//2-200,image.height//2-120,image.width//2+200,image.height//2+120)
            assert sum(max(p)>8 for p in data(ImageChops.difference(previous.crop(box),image.crop(box))))>500, ('Frozen soak scene',path)
        images[path.name]=image;previous=image
    report['soak_frames']=args.soak_frames
    report['soak_samples']=len(samples)
if args.aliases:
    viewport=re.search(r'GODOT_NODE_VIEW buffer=(\d+)x(\d+) scale=1.25',log)
    assert viewport
    width,height=map(int,viewport.groups())
    aliases=re.findall(r'GODOT_NODE_ALIAS index=(\d+) x=(-?\d+) y=(-?\d+) scale=(0\.\d+) handle=(\d+)',log)
    assert len(aliases)==args.buffers and {int(v[0]) for v in aliases}==set(range(args.buffers))
    assert len({v[4] for v in aliases})==args.buffers, 'Aliases must retain distinct ring textures'
    images['aliases-after-remove.png']=Image.open(results/'aliases-after-remove.png').convert('RGB')
    orphan=images['aliases-after-remove.png']
    assert orphan.size==images[names[0]].size
    center=orphan.crop((orphan.width//2-100,orphan.height//2-100,orphan.width//2+100,orphan.height//2+100))
    assert all(max(abs(c-b) for c,b in zip(pixel,(25,35,49)))<=3 for pixel in data(center)), 'Original node remained after removal'
    stamps=[]
    for _,x,y,scale,_ in aliases:
        scale=float(scale)
        assert scale in (0.20,0.25)
        crops={}
        for name,image in images.items():
            sx,sy=image.width/width,image.height/height
            left=image.width/2+int(x)*sx-320*scale*sx
            top=image.height/2-int(y)*sy-180*scale*sy
            rows=[]
            for source_y in (16,344):
                value=0
                for bit in range(16):
                    pixel=image.getpixel((round(left+(128+bit*24+12)*scale*sx),round(top+source_y*scale*sy)))
                    assert max(pixel)-min(pixel)<8 and (max(pixel)<40 or min(pixel)>210), ('Unclear alias stamp',name,pixel)
                    if min(pixel)>210:value|=1<<bit
                rows.append(value)
            assert rows[0]==rows[1] and rows[0]>0, ('Alias texture torn or uninitialized',name,rows)
            stamps.append(rows[0])
            crops[name]=image.crop((round(left+180*scale*sx),round(top+60*scale*sy),round(left+460*scale*sx),round(top+300*scale*sy)))
        assert sum(max(p)>8 for p in data(ImageChops.difference(crops['animated-a.png'],crops['animated-b.png'])))>10, 'Alias cube did not animate'
        assert sum(max(p)>8 for p in data(ImageChops.difference(crops['paused-a.png'],crops['paused-b.png'])))==0, 'Alias changed while paused'
        assert sum(g>70 and b>70 and r<g*.65 for r,g,b in data(crops['aliases-after-remove.png']))>10, 'Retained alias missing after removal'
    readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
    assert len(readers)==2
    for buffers,frames,waits,signals,pending,completed,errors in (map(int,row) for row in readers):
        assert buffers==args.buffers and frames==completed and frames>100 and signals==frames*buffers
        assert 0<waits<=signals and pending==0 and errors==0
    report['retained_texture_aliases']=args.buffers
    report['alias_stamp_samples']=len(stamps)
    report['alias_animation_pause_and_node_removal']=True
    report['gpu_readers']=[dict(zip(('buffers','frames','waits','signals','pending','completed','gpu_errors'),map(int,row))) for row in readers]
if args.fixture:
    fixture=json.loads(args.fixture.read_text()); pack=args.fixture.parent/'project.pck'
    assert hashlib.sha256(pack.read_bytes()).hexdigest()==fixture['pack_sha256']
    entries=pck_files(pack)
    assert 'assets/marker.png' not in entries and 'assets/marker.png.import' in entries
    assert any(n.endswith('.ctex') for n in entries)
    assert log.count('GODOT_NODE_PACKED_TEXTURE width=16 height=16')==3
    viewport=re.search(r'GODOT_NODE_VIEW buffer=(\d+)x(\d+) scale=1.25',log)
    assert viewport, 'Missing producer-to-capture coordinate evidence'
    width,height=map(int,viewport.groups())
    for name,image in images.items():
        # Dora captures downsample the physical framebuffer to <=1280 pixels.
        # The node is 640x360 at scale 1.25, centered in the UI camera.
        x=round(image.width/2-350*image.width/width)
        y=round(image.height/2-175*image.height/height)
        r,g,b=image.getpixel((x,y))
        if name=='opacity.png':
            assert max(abs(a-b) for a,b in zip((r,g,b),(140,18,152)))<=3, ('node opacity incorrect',name,(r,g,b))
        else:
            assert r>240 and b>240 and g<10, ('imported marker absent/flipped',name,(r,g,b))
    if fixture.get('alpha_controls'):
        for name,image in images.items():
            ratio_x,ratio_y=image.width/width,image.height/height
            y=round(image.height/2-175*ratio_y)
            opaque=image.getpixel((round(image.width/2-250*ratio_x),y))
            half=image.getpixel((round(image.width/2-300*ratio_x),y))
            expected=tuple(round((color+background)/2) for color,background in zip(opaque,(25,35,49)))
            assert max(abs(a-b) for a,b in zip(half,expected))<=3, ('incorrect Godot alpha compositing',name,opaque,half,expected)
        report['premultiplied_alpha_and_node_opacity']=True
    if fixture.get('additive_control'):
        for name,image in images.items():
            ratio_x,ratio_y=image.width/width,image.height/height
            y=round(image.height/2-175*ratio_y)
            additive=image.getpixel((round(image.width/2-200*ratio_x),y))
            opacity=0.5 if name=='opacity.png' else 1.0
            expected=tuple(round(source*opacity+background*(1-(64/255)*opacity)) for source,background in zip((128,0,0),(25,35,49)))
            assert max(abs(a-b) for a,b in zip(additive,expected))<=3, ('additive viewport color lost',name,additive,expected)
        report['additive_viewport_pixels']=True
    report['packaged_imported_texture']=True
    report['source_png_present_in_pack']=False
    report['fixture_pack_sha256']=fixture['pack_sha256']
(results/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
