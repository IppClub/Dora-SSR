#!/usr/bin/env python3
"""Verify physical output, stretch, premultiplied pixels and real SDL/GUI input."""
import argparse,json,re
from pathlib import Path
from PIL import Image
p=argparse.ArgumentParser();p.add_argument('--results',type=Path,required=True);p.add_argument('--platform',choices=['macOS Metal','Linux EGL','Windows WGL','Android EGL','iOS Metal'],required=True)
p.add_argument('--startup',action='store_true')
a=p.parse_args();out=a.results;report=out/'verification.json';report.unlink(missing_ok=True)
log=(out/'run.log').read_text(errors='replace')
assert not re.search(r'ERROR:|WARNING:|GodotNode:|BGFX LEAK:|SCRIPT ERROR',log),'Runtime error'
assert 'GODOT_OUTPUT_TEST frames=1260 captures=16 result=0' in log
assert log.count('GODOT_OUTPUT_READY')==1
if a.platform in ('macOS Metal','iOS Metal'):assert 'Metal API Validation Enabled' in log
else:assert 'OpenGL API' in log and 'Compatibility' in log
view=re.search(r'GODOT_OUTPUT_VIEW width=(\d+) height=(\d+) scale=0.85 x=40 y=-20',log);assert view
hw,hh=map(int,view.groups())
assert ('GODOT_OUTPUT_STARTUP width=720 height=480 result=0' if a.startup else 'GODOT_OUTPUT_STARTUP width=640 height=360 result=0') in log
# phase: physical size, logical content size, content scale, window margin
settings=[(800,450,800,450,1,1,0,0),(800,600,320,180,2.5,2.5,0,75),
 (800,600,320,180,2.5,2.5,0,75),(800,600,320,180,2.5,600/180,0,0),
 (800,600,320,240,2.5,2.5,0,0),(720,480,320,180,2,2,40,60),(640,360,640,360,1,1,0,0),(720,480,320,180,2.25,2.25,0,38)]
sizes=re.findall(r'GODOT_OUTPUT_SIZE phase=(\d+) width=(\d+) height=(\d+) result=(\d+)',log)
assert sizes==[(str(i),str(v[0]),str(v[1]),'0') for i,v in enumerate(settings,1)],sizes
assert [int(p) for p in re.findall(r'GODOT_OUTPUT_PHASE phase=(\d+)',log)]==list(range(1,9))
assert [int(p) for p in re.findall(r'GODOT_OUTPUT_SDL phase=(\d+)',log)]==list(range(1,9))
route=re.findall(r'GODOT_OUTPUT_SDL phase=\d+ x=[\d.]+ y=[\d.]+ kind=(mouse|touch)',log)
assert len(route)==8 and len(set(route))==1,route
buttons=re.findall(r'GODOT_OUTPUT_BUTTON phase=(\d+) hits=(\d+)',log)
assert buttons==[(str(i),str(i)) for i in range(1,9)],('Actual GUI button presses missing',buttons)
inputs=re.findall(r'GODOT_OUTPUT_INPUT phase=(\d+) x=([\d.e+-]+) y=([\d.e+-]+)',log)
assert len(inputs)==8,inputs
for i,x,y in inputs:assert abs(float(x)-80)<=2 and abs(float(y)-60)<=2,(i,x,y)
assert re.findall(r'GODOT_OUTPUT_BOUNCE width=(\d+) height=(\d+)',log)==[('400','300'),('720','480'),('640','360'),('720','480')]
measurements={}
for phase,(w,h,lw,lh,kx,ky,ox,oy) in enumerate(settings,1):
    positions=[]
    for sample in ('a','b'):
        name=f'phase-{phase}-{sample}.png';im=Image.open(out/name).convert('RGB');sx,sy=im.width/hw,im.height/hh
        def pixel(x,y):
            px=round(im.width/2+(40+(x-w/2)*.85)*sx)
            py=round(im.height/2+(20+(y-h/2)*.85)*sy)
            assert 0<=px<im.width and 0<=py<im.height,(name,px,py)
            return im.getpixel((px,py))
        def logical(x,y):return pixel(ox+x*kx,oy+y*ky)
        def near(actual,expected,tolerance=9):
            assert max(abs(v-e) for v,e in zip(actual,expected))<=tolerance,(name,actual,expected)
        near(logical(14,14),(255,0,255));near(logical(lw-14,lh-14),(255,255,0))
        near(logical(80,60),(0,255,0))
        # Half-alpha blue background and red overdraw, composited onto Dora's
        # known clear color. A second premultiplication in resolve fails here.
        near(logical(120,80),(25,43,63));near(logical(40,108),(140,21,31))
        near(pixel(w+10,h/2),(25,35,49))
        if oy:near(pixel(w/2,20),(25,35,49))
        if ox:near(pixel(10,h/2),(25,35,49))
        # Find the independent continuous animation in logical coordinates.
        colored=[]
        for x in range(180,289):
            r,g,b=logical(x,104)
            if r>210 and g<40 and b<40:colored.append(x)
        assert len(colored)>=4,('Missing moving pixels',name,colored)
        assert max(colored)-min(colored)<=10,('Duplicate moving pixels',name,colored)
        positions.append(sum(colored)/len(colored))
    movement=(positions[1]-positions[0])%100
    assert 1<movement<90,('Animation stopped or moved backwards',phase,positions)
    measurements[str(phase)]={'physical_size':[w,h],'logical_size':[lw,lh],'motion_x':positions,'input_logical':[float(inputs[phase-1][1]),float(inputs[phase-1][2])]}
accounting=re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
assert len(accounting)==1 and all(int(p)==int(c) and int(p)>100 and int(e)==0 for p,c,e in accounting),accounting
readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
assert len(readers)==1
buffers,frames,waits,signals,pending,completed,errors=map(int,readers[0]);assert buffers==3 and frames==completed and pending==0 and errors==0 and waits>0 and signals==frames*buffers
result={'passed':True,'scope':'actual Godot source Window size/content stretch, final Dora GPU composite, real SDL->Dora Touch->Godot GUI input and continuous animation; eight configurations','platform':a.platform,'controller_frames':1260,'captures':16,'sdl_event_route':route[0],'startup_source_size_verified':a.startup,'buffers':3,'gpu_copy_transport':True,'premultiplied_resolve_verified':True,'configurations':measurements,'gpu_accounting':accounting}
report.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
