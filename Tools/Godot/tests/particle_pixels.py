"""Measure two actual GPUParticles2D outputs against independent CPU markers."""
from PIL import Image

def verify_particles(out, metadata, host_w, host_h, clocks):
    measurements={}
    def circular_difference(a,b,period):return (a-b+period/2)%period-period/2
    for name,w,h in metadata:
        w,h=int(w),int(h);im=Image.open(out/name).convert('RGB')
        sx,sy=im.width/host_w,im.height/host_h
        def marker(y,color):
            left=round(im.width/2+(48-w/2)*1.25*sx)
            right=round(im.width/2+(528-w/2)*1.25*sx)
            top=round(im.height/2+(y-9-h/2)*1.25*sy)
            bottom=round(im.height/2+(y+9-h/2)*1.25*sy)
            assert 0<=left<right<=im.width and 0<=top<bottom<=im.height
            xs=[]
            for py in range(top,bottom):
                for px in range(left,right):
                    r,g,b=im.getpixel((px,py))
                    match={'cyan':r<40 and g>210 and b>210,
                           'yellow':r>210 and g>210 and b<40,
                           'red':r>210 and g<40 and b<40}[color]
                    if match:xs.append(px+0.5)
            assert len(xs)>=6,('Missing particle/reference pixels',name,y,color,len(xs))
            assert max(xs)-min(xs)<=12*1.25*sx,('Particle spread/duplicate output',name,color)
            return w/2+(sum(xs)/len(xs)-im.width/2)/(1.25*sx)
        custom,custom_cpu=marker(180,'cyan'),marker(220,'red')
        standard,standard_cpu=marker(260,'yellow'),marker(300,'red')
        standard_ticks=0
        for bit in range(16):
            x=round(im.width/2+(128+(bit+0.5)*24-w/2)*1.25*sx)
            y=round(im.height/2+(144-h/2)*1.25*sy)
            pixel=im.getpixel((x,y))
            assert max(pixel)-min(pixel)<8 and (max(pixel)<40 or min(pixel)>210),('Unclear standard clock',name,pixel)
            if min(pixel)>210:standard_ticks|=1<<bit
        seconds=clocks[name]['script_ticks_64hz']/64
        errors=[abs(circular_difference(custom,custom_cpu,448)),
                abs(circular_difference(standard,standard_cpu,160))]
        assert max(errors)<=3,('GPU particle / CPU marker drift',name,custom,custom_cpu,standard,standard_cpu)
        assert abs(circular_difference(custom_cpu,64+seconds*8,448))<=2
        assert abs(circular_difference(standard_cpu,64+standard_ticks/64*4,160))<=2
        measurements[name]={'custom_gpu_x':custom,'custom_cpu_x':custom_cpu,
                            'standard_gpu_x':standard,'standard_cpu_x':standard_cpu,'max_error_pixels':max(errors),'standard_clock_ticks':standard_ticks}
    for phase in ('normal','quarter','double','paused','resumed'):
        first,last=measurements[phase+'-a.png'],measurements[phase+'-b.png']
        seconds=(clocks[phase+'-b.png']['script_ticks_64hz']-clocks[phase+'-a.png']['script_ticks_64hz'])%65536/64
        for kind,velocity,period in (('custom',8,448),('standard',4,160)):
            elapsed=seconds if kind=='custom' else (last['standard_clock_ticks']-first['standard_clock_ticks'])%65536/64
            movement=(last[kind+'_gpu_x']-first[kind+'_gpu_x'])%period
            assert abs(circular_difference(movement,elapsed*velocity,period))<=4,('Particle phase progression',phase,kind,movement,seconds)
            if elapsed*velocity>4:assert movement>0.5,('Particle did not advance',phase,kind)
    assert measurements['paused-a.png']['standard_clock_ticks']==measurements['paused-b.png']['standard_clock_ticks'], 'Pausable CPU clock advanced'
    assert abs(measurements['paused-a.png']['standard_gpu_x']-measurements['paused-b.png']['standard_gpu_x'])<=0.1, 'Pausable GPU emitter advanced'
    for kind,period in (('custom',448),('standard',160)):
        anchor=measurements['freeze-a.png'][kind+'_gpu_x']
        for name in ('freeze-resized.png','freeze-b.png'):
            assert abs(circular_difference(measurements[name][kind+'_gpu_x'],anchor,period))<=0.8,('Frozen particle advanced during resize',kind,name)
    return {'types':['GPUParticles2D/custom DELTA shader','GPUParticles2D/ParticleProcessMaterial'],
            'max_cpu_reference_error_pixels':max(v['max_error_pixels'] for v in measurements.values()),
            'time_scales_and_pause_verified':True,'zero_scale_resize_frozen':True,'measurements':measurements}
