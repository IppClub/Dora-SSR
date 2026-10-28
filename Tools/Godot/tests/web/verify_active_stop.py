#!/usr/bin/env python3
"""Require live-node host shutdown, animated shared slots and final GPU/PCM drain."""
import argparse, hashlib, json, re
from pathlib import Path
from active_stop_images import verify_images
p=argparse.ArgumentParser(description=__doc__);p.add_argument('results',type=Path);p.add_argument('--buffers',type=int,choices=[2,3,4],required=True);a=p.parse_args()
report=a.results/'verification.json';report.unlink(missing_ok=True)
(a.results/'verification-failure.json').unlink(missing_ok=True)
try:
 r=json.loads((a.results/'execution.json').read_text());assert r['passed'] and r['godot_packaged'] and not r['ordinary']
 proof=r['active_stop'];assert proof['running'] and proof['frame']>=120 and proof['buffers']==a.buffers and proof['aliases']==a.buffers
 assert {x['name'] for x in r['captures']}=={'active-a','active-b'}
 logs='\n'.join(r['logs']);assert 'DORA_WEB_ACTIVE_STOP_READY' in logs
 assert not re.search(r'BGFX LEAK:|C\+\+ objects leaks|\[error\]|\[critical\]|ERROR:',logs)
 clients=re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)',logs)
 readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',logs)
 assert len(clients)==len(readers)==1,(clients,readers)
 produced,completed,errors=clients[0];assert int(produced)>0 and produced==completed and errors=='0'
 b,f,w,s,pending,c,e=map(int,readers[0]);assert b==a.buffers and f>0 and 0<w<=s and s==f*b and pending==0 and c==f and e==0
 audio=re.findall(r'GodotAudio drained: produced=(\d+), consumed=(\d+), nonzeroProduced=(\d+), nonzeroConsumed=(\d+), underrunFrames=(\d+)',logs);assert len(audio)==1,audio
 x,y,n,m,u=map(int,audio[0]);assert x>=y>0 and n>0 and m>0 and u==0
 tones=re.findall(r'GodotAudio tone: frames=(\d+), leftCrossings=(\d+), rightCrossings=(\d+)',logs);assert len(tones)==1,tones
 count,left,right=map(int,tones[0]);assert count==48000 and abs(left-440)<=2 and abs(right-660)<=2
 assert not r['teardown']['state']['active'] and not r['teardown']['dispose_again'] and not r['teardown']['ime_present']
 stamps, images = verify_images(a.results, a.buffers)
 result={'passed':True,'scope':'Actual Web host stop while Godot node and all texture aliases remain alive; output animation and one GPU/PCM client drained, not context loss or physical-device acceptance','buffers':a.buffers,'live_at_stop':proof,'stamps':stamps,'gpu_clients':clients,'gpu_readers':readers,'audio':audio,'tones':tones,'images_sha256':images,'execution_sha256':hashlib.sha256((a.results/'execution.json').read_bytes()).hexdigest()}
 report.write_text(json.dumps(result,indent=2)+'\n');print('Live Godot client host shutdown: PASS')
except BaseException as error:
 (a.results/'verification-failure.json').write_text(json.dumps({'passed':False,'error':repr(error)},indent=2)+'\n');raise
