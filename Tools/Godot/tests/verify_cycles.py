#!/usr/bin/env python3
"""Verify repeated real node lifecycles; Metal allocation coverage is explicit."""
import argparse,json,re
from pathlib import Path
from PIL import Image,ImageChops

def verify(out,cycles,buffers,warmup,platform,max_metal_growth_bytes=None):
    assert 2<=cycles<=1000 and 1<=warmup<cycles
    log=(out/'run.log').read_text()
    assert f'GODOT_CYCLES_DONE count={cycles} captures={cycles*3} result=0' in log
    assert not any(s in log for s in ('BGFX LEAK:','C++ objects leaks','ERROR:','[error]'))
    assert list(map(int,re.findall(r'GODOT_NODE_SCENE boots=(\d+) root_path_ok=1',log)))==list(range(1,cycles+1))
    clients=re.findall(r'GodotRuntime client closed: produced=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
    assert len(clients)==cycles and all(int(x)>0 and x==y and z=='0' for x,y,z in clients)
    readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
    assert len(readers)==cycles and all(int(b)==buffers and int(f)>0 and 0<int(w)<=int(s) and int(s)==int(f)*buffers and pending=='0' and f==done and errors=='0' for b,f,w,s,pending,done,errors in readers)
    audio=re.findall(r'GodotAudio drained: produced=(\d+), consumed=(\d+), nonzeroProduced=(\d+), nonzeroConsumed=(\d+), underrunFrames=(\d+)',log)
    assert len(audio)==cycles and all(int(x)>=int(y)>0 and int(n)>0 and int(m)>0 and u=='0' for x,y,n,m,u in audio)
    pattern=r'GODOT_CYCLE_IDLE index=(\d+) textures=(\d+) programs=(\d+) shaders=(\d+) framebuffers=(\d+) textureBytes=(-?\d+) rtBytes=(-?\d+) metalBytes=(-?\d+)'
    names=('index','textures','programs','shaders','framebuffers','texture_bytes','rt_bytes','metal_bytes')
    samples=[dict(zip(names,map(int,row))) for row in re.findall(pattern,log)]
    assert [s['index'] for s in samples]==list(range(1,cycles+1))
    (out/'resource-samples.json').write_text(json.dumps(samples,indent=2)+'\n')
    changed=[]
    def pixels(image):return image.get_flattened_data() if hasattr(image,'get_flattened_data') else image.getdata()
    for cycle in range(1,cycles+1):
        images=[Image.open(out/f'cycle-{cycle}-{suffix}.png').convert('RGB') for suffix in ('a','b','removed')]
        assert all(im.size==(1280,720) for im in images)
        crops=[im.crop((500,240,780,450)) for im in images]
        for im in crops[:2]:assert sum(g>70 and b>70 and r<g*.65 for r,g,b in pixels(im))>1000
        count=sum(max(pixel)>8 for pixel in pixels(ImageChops.difference(crops[0],crops[1])));assert count>100;changed.append(count)
        assert all(max(abs(c-e) for c,e in zip(pixel,(25,35,49)))<=3 for pixel in pixels(crops[2])),'Removed node still visible'
    steady=samples[warmup:];baseline=steady[0]
    for name in ('textures','programs','shaders','framebuffers','texture_bytes','rt_bytes'):
        assert all(s[name]==baseline[name] for s in steady),(name,[s[name] for s in steady])
    growth=None
    if max_metal_growth_bytes is not None:
        assert max_metal_growth_bytes>=0 and all(s['metal_bytes']>=0 for s in steady),'Metal allocation query unavailable'
        growth=max(s['metal_bytes'] for s in steady)-baseline['metal_bytes']
        assert growth<=max_metal_growth_bytes,('Metal allocation growth',growth,max_metal_growth_bytes)
    return {'passed':True,'platform':platform,'scope':'Repeated clients in one process, screenshots, GPU/PCM drain and post-close bgfx handle estimates; Metal allocation only when explicitly required. CPU heap and other driver allocations are not measured.','cycles':cycles,'buffers':buffers,'captures':cycles*3,'warmup_cycles':warmup,'metal_allocation_tested':max_metal_growth_bytes is not None,'max_metal_growth_bytes':max_metal_growth_bytes,'observed_peak_metal_growth_bytes':growth,'minimum_animation_changed_pixels':min(changed),'resources':samples}

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--results',type=Path,required=True)
    p.add_argument('--cycles',type=int,required=True)
    p.add_argument('--buffers',type=int,choices=[2,3,4],required=True)
    p.add_argument('--warmup',type=int,default=5)
    p.add_argument('--platform',required=True)
    p.add_argument('--max-metal-growth-bytes',type=int)
    a=p.parse_args();report=a.results/'verification.json';report.unlink(missing_ok=True)
    (a.results/'failure.json').unlink(missing_ok=True)
    try:
        result=verify(a.results,a.cycles,a.buffers,a.warmup,a.platform,a.max_metal_growth_bytes)
        report.write_text(json.dumps(result,indent=2)+'\n')
        print('Repeated client GPU/resource acceptance: PASS')
    except BaseException as error:
        (a.results/'failure.json').write_text(json.dumps({'passed':False,'type':type(error).__name__,'error':str(error)},indent=2)+'\n');raise
