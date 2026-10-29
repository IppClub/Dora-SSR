#!/usr/bin/env python3
"""Verify actual imported 3D animation pixels, pause/resume, removal and GPU drain."""
import argparse,hashlib,json,re
from pathlib import Path
from PIL import Image,ImageChops
p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path);p.add_argument('--platform',choices=['macOS Metal','Windows WGL','Linux EGL'],default='macOS Metal');a=p.parse_args();out=a.output
report=out/'verification.json';report.unlink(missing_ok=True)
def pixels(image):return image.get_flattened_data() if hasattr(image,'get_flattened_data') else image.getdata()
try:
 execution=json.loads((out/'execution.json').read_text());assert execution['native_exit_code']==0
 log=(out/'run.log').read_text()
 assert not any(marker in log for marker in ('[error]','[critical]','[warning]','ERROR:','SCRIPT ERROR:','BGFX LEAK:','C++ objects leaks','Metal Validation Error','MTLCommandBufferError'))
 renderer=None
 if a.platform=='macOS Metal':assert 'Metal API Validation Enabled' in log
 else:
  match=re.search(r'OpenGL API[^\r\n]+',log);assert match,'Godot GL renderer must be recorded';renderer=match.group(0)
 assert log.count('GODOT_PROJECT_3D gltf_vertices=24 animation=Spin surfaces=1 tracks=2 shader=spatial')==1
 for marker in ('running=1','paused=1','resumed=1','complete=1 captures=6 ticks=230'):assert log.count('DORA_PROJECT_3D '+marker)==1
 names=['animated-a','animated-b','paused-a','paused-b','resumed','removed'];images={};counts={};hashes={}
 for name in names:
  assert log.count('DORA_PROJECT_3D capture='+name)==1
  path=out/(name+'.png');im=Image.open(path).convert('RGB');assert im.size==(1280,720);images[name]=im;hashes[name]=hashlib.sha256(path.read_bytes()).hexdigest()
  points=[(i%im.width,i//im.width) for i,(r,g,b) in enumerate(pixels(im)) if g>180 and r<60 and b<60]
  counts[name]=len(points)
  if name!='removed':
   assert 1500<len(points)<60000,(name,len(points))
   assert all(250<x<1030 and 100<y<620 for x,y in points),(name,'3D pixels outside central viewport')
  else:assert not points,'Imported mesh remained after GodotNode removal'
 def changed(left,right):return sum(pixel!=(0,0,0) for pixel in pixels(ImageChops.difference(images[left],images[right])))
 moving=changed('animated-a','animated-b');paused=changed('paused-a','paused-b');resumed=changed('paused-b','resumed')
 assert moving>500 and paused==0 and resumed>500,(moving,paused,resumed)
 clients=re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)',log);assert len(clients)==1
 produced,completed,errors=map(int,clients[0]);assert produced>50 and produced==completed and errors==0
 readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',log);assert len(readers)==1
 buffers,frames,waits,signals,pending,done,errors=map(int,readers[0]);assert buffers==3 and frames>50 and 0<waits<=signals and signals==frames*buffers and pending==errors==0 and done==frames
 destroyed=[name.strip() for group in re.findall(r'destroy: ([^\r\n]+)\.',log) for name in group.split(',')]
 for name in ('Director','BGFXDora','Logger'):assert destroyed.count(name)==1
 assert destroyed.index('Director')<destroyed.index('BGFXDora')<destroyed.index('Logger')
 result={'passed':True,'platform':a.platform,'renderer':renderer,'scope':'Ordinary '+a.platform+' host: actual runtime glTF mesh and animation import, unshaded 3D material, GPU output animation/pause/resume/removal and clean shutdown. Not large-scene, PCK, plugin/GDExtension or physical hardware acceptance.','captures':6,'imported_vertices':24,'imported_animation':'Spin','imported_animation_tracks':2,'spatial_shader_resource':True,'changed_animation_pixels':moving,'changed_paused_pixels':paused,'changed_resumed_pixels':resumed,'green_pixels':counts,'gpu_clients':clients,'gpu_readers':readers,'images_sha256':hashes,'log_sha256':hashlib.sha256((out/'run.log').read_bytes()).hexdigest(),'execution_sha256':hashlib.sha256((out/'execution.json').read_bytes()).hexdigest()}
 report.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
except BaseException as error:
 (out/'verification-failure.json').write_text(json.dumps({'passed':False,'error':repr(error)},indent=2)+'\n');raise
