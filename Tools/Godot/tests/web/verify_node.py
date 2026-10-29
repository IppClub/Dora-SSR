#!/usr/bin/env python3
"""Validate actual Dora-composited PNGs, GPU reader drain and host PCM evidence."""
import argparse,hashlib,json,re
from pathlib import Path
from PIL import Image,ImageChops
p=argparse.ArgumentParser(description=__doc__);p.add_argument('results',type=Path);p.add_argument('--buffers',type=int,choices=[2,3,4],required=True);p.add_argument('--cabi-observer',action='store_true',help='Use observed C ABI/PCM evidence when native Info diagnostics are disabled');a=p.parse_args()
report=a.results/'verification.json';report.unlink(missing_ok=True)
r=json.loads((a.results/'execution.json').read_text());assert r['passed']
assert r['teardown']['state']['active'] is False and r['teardown']['dispose_again'] is False and r['teardown']['ime_present'] is False,r['teardown']
if r.get('suspension'):
 suspension=r['suspension'];assert suspension['entered']['state']['suspended'] is True and suspension['held']['state']['suspended'] is True and suspension['resumed']['state']['suspended'] is False,suspension
 assert suspension['entered']['transition']['engineFrame']==suspension['held']['transition']['engineFrame'],suspension
images={path.stem:Image.open(path).convert('RGB') for path in a.results.glob('*.png')}
expected={'preboot','animated','key','paused','paused-again','resumed','restart','resize','aliases','removed','removed-again','recreated'}
assert set(images)==expected and len(r['captures'])==len(expected)
checks=0

def near(im,x,y,expected,tolerance=2):
 global checks
 actual=im.getpixel((round(x),round(y)));assert all(abs(actual[i]-expected[i])<=tolerance for i in range(3)),(x,y,actual,expected)
 checks+=1

def stamp(im,cx,cy,width,height,scale=1):
 left,top=cx-width/2,cy-height/2;corner=12*scale
 for x,y,color in [(left+corner,top+corner,(255,0,0)),(left+width-corner,top+corner,(0,255,0)),(left+corner,top+height-corner,(0,0,255)),(left+width-corner,top+height-corner,(255,255,255))]:near(im,x,y,color)
 values=[]
 for y in (top+16*scale,top+height-16*scale):
  value=0
  for bit in range(16):
   x=left+width*0.2+(bit+0.5)*width*0.6/16;pixel=im.getpixel((round(x),round(y)));assert max(pixel)-min(pixel)<=2,pixel
   assert max(pixel)<10 or min(pixel)>245,pixel
   if min(pixel)>245:value|=1<<bit
  values.append(value)
 assert values[0]==values[1],('torn alias frame',values)
 return values[0]

frames={}
for name,im in images.items():
 assert im.size==(1280,720)
 if name in {'removed','removed-again'}:
  near(im,640,360,(26,26,26));continue
 width,height=(480,270) if name in {'resize','aliases'} else (640,360)
 frames[name]=stamp(im,640,360,width,height)
 near(im,640,360,(255,0,0) if name=='key' else (255,255,0))
 # Godot's premultiplied .8-alpha background over Dora's clear colour.
 near(im,640-width/2+width*0.125,360,(21,36,56))
assert frames['preboot']<=8 and frames['animated']>frames['preboot']
assert frames['paused']==frames['paused-again'] and frames['resumed']>frames['paused']
assert frames['restart']<frames['resumed']
assert ImageChops.difference(images['paused'],images['paused-again']).getbbox() is None
assert ImageChops.difference(images['removed'],images['removed-again']).getbbox() is None
aliases=[]
for name in ['aliases','removed','removed-again','recreated']:
 values=[stamp(images[name],160,470-index*110,120,67.5,.25) for index in range(a.buffers)]
 aliases.append({'capture':name,'frames':values})
assert aliases[1]['frames']==aliases[2]['frames']==aliases[3]['frames']
assert any(after>=before for before,after in zip(aliases[0]['frames'],aliases[1]['frames']))
logs='\n'.join(r['logs']);assert logs.count('DORA_WEB_GODOT_BOOT')==3
for text in ['DORA_WEB_GODOT_POINTER 100,70','DORA_WEB_GODOT_KEY 1 state=1','DORA_WEB_GODOT_KEY 0 state=0','DORA_WEB_NODE_DONE frames=620 aliases='+str(a.buffers)]:assert text in logs,text
for text in ['DORA_WEB_GODOT_CONTROLLER_BUTTON device=7 pressed=1 state=1','DORA_WEB_GODOT_CONTROLLER_AXIS device=7 value=0.75','DORA_WEB_GODOT_CONTROLLER_FOCUS released=1']:
 assert text in logs,text
clients=re.findall(r'GodotRuntime client closed: produced=(\d+), completed=(\d+), gpuErrors=(\d+)',logs)
readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',logs)
if a.cabi_observer:
 metrics=r['audio_metrics'];assert not metrics['protocol_errors'],metrics['protocol_errors']
 sessions=metrics['sessions'];assert len(sessions)==2
 clients=[];readers=[];audio=[];tones=[]
 for session in sessions:
  produced,completed,errors,waits=session['close_stats']
  assert produced>0 and produced==completed and errors==0
  assert session['buffers']==a.buffers and session['pending_at_close']==0
  assert session['begins']+session['empty_ends']==session['ends'] and session['begins']>0 and session['max_pending']>0
  assert session['ends']%a.buffers==0
  assert all(value==0 for value in session['pending'].values())
  assert session['bindings']>0
  native=session['audio_stats'];assert native is not None
  made,used,nonzero,underruns=native
  assert made>=used>0 and used==session['pcm_frames'] and nonzero>0 and underruns==0
  assert session['nonzero_consumed']>0
  assert session['tone_frames']==48000
  left,right=session['tone_crossings'];assert abs(left-440)<=2 and abs(right-660)<=2,(left,right)
  clients.append([produced,completed,errors])
  readers.append({'buffers':session['buffers'],'begins':session['begins'],'ends':session['ends'],'pending':session['pending_at_close']})
  audio.append([made,used,nonzero,session['nonzero_consumed'],underruns])
  tones.append([session['tone_frames'],left,right])
else:
 assert len(clients)==2 and len(readers)==2,(clients,readers)
 for produced,completed,errors in clients:assert int(produced)>0 and produced==completed and int(errors)==0
 for buffers,frames_count,waits,signals,pending,completed,errors in readers:assert int(buffers)==a.buffers and int(frames_count)>0 and 0<int(waits)<=int(signals) and int(signals)==int(frames_count)*a.buffers and pending=='0' and completed==frames_count and errors=='0'
 audio=re.findall(r'GodotAudio drained: produced=(\d+), consumed=(\d+), nonzeroProduced=(\d+), nonzeroConsumed=(\d+), underrunFrames=(\d+)',logs)
 tones=re.findall(r'GodotAudio tone: frames=(\d+), leftCrossings=(\d+), rightCrossings=(\d+)',logs)
 assert len(audio)==2 and len(tones)==2,(audio,tones)
 for produced,consumed,nonzero_in,nonzero_out,underruns in audio:assert int(produced)>=int(consumed)>0 and int(nonzero_in)>0 and int(nonzero_out)>0 and int(underruns)==0
 for count,left,right in tones:assert int(count)==48000 and abs(int(left)-440)<=2 and abs(int(right)-660)<=2
r.update(passed=True,scope='Actual Dora GodotNode Web: composited GPU output, C ABI/manual pointer/key, standard controller button/axis/focus release, lifecycle/resize/retained aliases, GPU drain, PCM-to-SoLoud oracle and post-stop platform-service teardown; native DOM input and latency still pending',buffers=a.buffers,stats_evidence='Observed production C ABI and PCM' if a.cabi_observer else 'Native diagnostic logs',pixel_checks=checks,barcodes=frames,aliases=aliases,gpu_clients=clients,gpu_readers=readers,audio=audio,tones=tones,controller_button_axis_forwarding=True,controller_focus_loss_releases_held_input=True,platform_service_teardown=True,host_suspend_resume=bool(r.get('suspension')),images_sha256={name:hashlib.sha256((a.results/(name+'.png')).read_bytes()).hexdigest() for name in images})
report.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({key:r[key] for key in ['passed','buffers','controller_frames','pixel_checks','audio','tones']}))
