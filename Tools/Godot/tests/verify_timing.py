#!/usr/bin/env python3
"""Decode actual shader TIME and independent script-clock pixels."""
from pathlib import Path
import argparse,json,re
from PIL import Image
p=argparse.ArgumentParser()
p.add_argument('--results',type=Path,required=True)
p.add_argument('--platform',choices=['macOS Metal','Linux EGL','Windows WGL','Android EGL','iOS Metal'],default='macOS Metal')
p.add_argument('--particles',action='store_true',help='Also measure actual GPUParticles2D custom and standard materials')
a=p.parse_args();out=a.results;report=out/'verification.json';report.unlink(missing_ok=True)
log=(out/'run.log').read_text(encoding='utf8',errors='replace')
assert not re.search(r'ERROR:|WARNING:|GodotNode:|BGFX LEAK:|SCRIPT ERROR',log),'Runtime error'
assert 'GODOT_TIMING_TEST frames=1000 captures=13 result=0' in log
assert log.count('GODOT_TIMING_READY delay_ms=60 root_always=1')==1
if a.platform in ('macOS Metal','iOS Metal'):assert 'Metal API Validation Enabled' in log
else:assert 'OpenGL API' in log and 'Compatibility' in log
view=re.search(r'GODOT_TIMING_VIEW width=(\d+) height=(\d+) scale=1.25',log);assert view
host_w,host_h=map(int,view.groups())
metadata=re.findall(r'GODOT_TIMING_CAPTURE name=(\S+) width=(\d+) height=(\d+)',log)
assert len(metadata)==13 and len({n for n,_,_ in metadata})==13
clocks={}
for name,w,h in metadata:
    w,h=int(w),int(h);assert (w,h)==((800,450) if name=='freeze-resized.png' else (640,360))
    image=Image.open(out/name).convert('RGB');sx,sy=image.width/host_w,image.height/host_h
    codes=[]
    for y in (80,112):
        code=0
        for bit in range(16):
            x=128+(bit+0.5)*24
            pixel=image.getpixel((round(image.width/2+(x-w/2)*1.25*sx),round(image.height/2+(y-h/2)*1.25*sy)))
            assert max(pixel)-min(pixel)<8 and (max(pixel)<40 or min(pixel)>210),('Unclear shader clock',name,pixel)
            if min(pixel)>210:code|=1<<bit
        codes.append(code)
    clocks[name]={'shader_ticks_64hz':codes[0],'script_ticks_64hz':codes[1]}
phases={}
for name in ('normal','quarter','double','paused','resumed'):
    first,last=clocks[name+'-a.png'],clocks[name+'-b.png']
    gpu=(last['shader_ticks_64hz']-first['shader_ticks_64hz'])%65536
    script=(last['script_ticks_64hz']-first['script_ticks_64hz'])%65536
    assert script>6,('Clock sample interval too short',name,script)
    assert abs(gpu-script)<=2,('Shader TIME / script time drift',name,gpu,script)
    phases[name]={'shader_seconds':gpu/64,'script_seconds':script/64}
anchor=clocks['normal-a.png']
relative_drift=[]
for name,value in clocks.items():
    gpu=(value['shader_ticks_64hz']-anchor['shader_ticks_64hz'])%65536
    script=(value['script_ticks_64hz']-anchor['script_ticks_64hz'])%65536
    drift=(gpu-script+32768)%65536-32768
    assert abs(drift)<=2,('Clock drift across time-scale transition',name,drift)
    relative_drift.append(abs(drift))
freeze=[clocks[n] for n in ('freeze-a.png','freeze-resized.png','freeze-b.png')]
assert all(v==freeze[0] for v in freeze),'Frozen TIME advanced during rendering/viewport redraw'
drawn=re.findall(r'GODOT_TIMING_DRAWN value=(\d+) scale=([\d.]+) paused=(\d+)',log)
assert len(drawn)==13 and all(int(drawn[i+1][0])>int(drawn[i][0]) for i in range(12)),('Drawn-frame counter stopped',drawn)
expected_scales=[1,1,.25,.25,2,2,1,1,0,0,0,1,1]
assert [float(v[1]) for v in drawn]==expected_scales,('Time-scale command not applied',drawn)
assert [int(v[2]) for v in drawn]==[int(i in (6,7)) for i in range(13)],('Pause command not applied',drawn)
accounting=re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
assert len(accounting)==1 and all(int(p)==int(c) and int(p)>100 and int(e)==0 for p,c,e in accounting)
readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
assert len(readers)==1
buffers,frames,waits,signals,pending,completed,errors=map(int,readers[0]);assert buffers==3 and frames==completed and pending==0 and errors==0 and waits>0 and signals==frames*buffers
result={'passed':True,'scope':'actual shader TIME vs independent script uniform clock; delayed producer, time scales1/0.25/2/0, SceneTree pause and zero-time resize redraw','platform':a.platform,'controller_frames':1000,'captures':13,'deliberate_process_delay_ms':60,'clock_resolution_hz':64,'phase_intervals':phases,'max_relative_drift_ticks':max(relative_drift),'freeze_with_resize':True,'drawn_frames_advanced':True,'gpu_accounting':[dict(zip(('produced','completed','errors'),map(int,v))) for v in accounting],'clocks':clocks}
if a.particles:
    from particle_pixels import verify_particles
    assert 'DORA_PARTICLE_DIAG' not in log and 'DORA_GL_DIAG' not in log, 'Temporary native diagnostics are not acceptance evidence'
    assert log.count('GODOT_PARTICLE_READY count=2 shader_delta=1 standard_material=1')==1
    result['particles']=verify_particles(out,metadata,host_w,host_h,clocks)
    result['scope']+='; actual custom and standard GPUParticles2D vs CPU reference markers'
report.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
