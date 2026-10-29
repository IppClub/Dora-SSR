#!/usr/bin/env python3
"""Strict native binding fault/continuing-Dora validation; no GPU-sharing claim."""
import argparse,hashlib,json,re
from pathlib import Path
from PIL import Image,ImageChops
p=argparse.ArgumentParser(description=__doc__);p.add_argument('results',type=Path);a=p.parse_args()
out=a.results;report=out/'verification.json';report.unlink(missing_ok=True)
def digest(path):
 with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def pixels(image):return image.get_flattened_data() if hasattr(image,'get_flattened_data') else image.getdata()
try:
 execution=json.loads((out/'execution.json').read_text());assert execution['executed'] and execution['native_exit_code']==0
 language=execution['language'];case=execution['case'];assert language in ('Rust','Wa') and case in ('missing-library','missing-scene')
 raw=(out/'run.log').read_text();assert digest(out/'run.log')==execution['raw_log_sha256']
 assert all(digest(Path(name))==sha for name,sha in {**execution['original'],**execution['artifacts']}.items())
 prefix='GODOT_BINDING_ASYNC '+language
 assert raw.count(prefix+' accepted=1 running=0 error_empty=1')==1
 errors=re.findall(re.escape(prefix)+r' error=([^\r\n]+)',raw);assert len(errors)==1
 error=errors[0];assert execution['expected_error_substring'] in error
 assert raw.count('GODOT_BINDING_ASYNC_HOST observed=1')==raw.count('GODOT_BINDING_ASYNC_HOST complete=1 captures=2')==1
 assert raw.index(prefix+' accepted=1')<raw.index(prefix+' error=')<raw.index('GODOT_BINDING_ASYNC_HOST observed=1')<raw.index('GODOT_BINDING_ASYNC_HOST complete=1')<raw.index('destroy: ')
 assert 'Metal API Validation Enabled' in raw
 assert re.search(r'destroy: .*WasmRuntime.*Director.*SpriteRenderer.*BGFXDora',raw)
 assert 'destroy: Logger.' in raw
 diagnostics=[line for line in raw.splitlines() if re.search(r'ERROR:|WARNING:|\[(?:error|critical|warning)\]',line)]
 own=[line for line in diagnostics if re.search(r'\[error\] GodotNode: '+re.escape(error)+r'$',line)]
 assert len(own)==1,diagnostics
 upstream=[line for line in diagnostics if line not in own]
 if case=='missing-library':
  assert not upstream,upstream
  assert 'Godot Engine v' not in raw
  assert error.startswith('dlopen(') and 'dora-godot-intentionally-missing.dylib' in error and '(no such file)' in error
 else:
  assert error=='Godot project startup failed'
  # Keep upstream diagnostics exact and bounded. Unknown errors, including
  # unrelated resource failures, must not be hidden by the expected fault.
  expected=["ERROR: Cannot open file 'res://dora-intentionally-missing-binding-scene.tscn'.",
            "ERROR: Failed loading resource: res://dora-intentionally-missing-binding-scene.tscn.",
            'ERROR: Failed loading scene: res://dora-intentionally-missing-binding-scene.tscn.']
  assert upstream==expected,upstream
  assert 'Godot Engine v' in raw
 assert not any(value in raw for value in ('BGFX LEAK:','C++ objects leaks','Metal Validation Error','MTLCommandBufferError','panic','Wasm trap'))
 readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',raw)
 assert len(readers)==1 and tuple(map(int,readers[0]))==(3,0,0,0,0,0,0),readers
 clients=re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)',raw)
 assert all(tuple(map(int,row))==(0,0,0) for row in clients),clients
 assert 'GodotAudio drained:' not in raw
 images=[Image.open(out/f'frame-{i}.png').convert('RGB') for i in (1,2)]
 assert images[0].size==images[1].size==(1280,720)
 centers=[]
 for image in images:
  green=[i%image.width for i,(r,g,b) in enumerate(pixels(image)) if g>220 and r<30 and b<30];assert len(green)>500
  centers.append(sum(green)/len(green))
 assert centers[1]-centers[0]>100
 changed=sum(max(pixel)>20 for pixel in pixels(ImageChops.difference(*images)));assert changed>1000
 assert all(digest(out/name)==sha for name,sha in execution['images_sha256'].items())
 result={'passed':True,'scope':'Actual native macOS Release host, real Wasm3 generated binding asynchronous error, two continuing Dora animation captures and normal cleanup. Godot GPU sharing/recovery not covered.','language':language,'case':case,'last_error':error,'expected_native_diagnostics':diagnostics,'gpu_readers':readers,'gpu_clients':clients,'dora_green_centers':centers,'changed_pixels':changed,'images_sha256':execution['images_sha256'],'execution_sha256':digest(out/'execution.json'),'raw_log_sha256':digest(out/'run.log')}
 report.write_text(json.dumps(result,indent=2)+'\n');print(language,case,'strict native asynchronous error: PASS')
except BaseException as error:
 (out/'verification-failure.json').write_text(json.dumps({'passed':False,'error':repr(error)},indent=2)+'\n');raise
