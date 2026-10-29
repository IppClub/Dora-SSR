#!/usr/bin/env python3
"""Audit exported C# native fault probes; feedback and full cleanup are separate gates."""
import argparse,hashlib,json,re
from pathlib import Path
from PIL import Image,ImageChops
p=argparse.ArgumentParser(description=__doc__);p.add_argument('results',type=Path);a=p.parse_args();out=a.results
for name in ('verification.json','feedback-verification.json','verification-failure.json'):(out/name).unlink(missing_ok=True)
def digest(path):
 with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def pixels(image):return image.get_flattened_data() if hasattr(image,'get_flattened_data') else image.getdata()
try:
 exported=json.loads((out/'input-export.json').read_text());assert exported['passed'];mapping=exported['mapping']
 assert all(digest(out/value['exported_relative'])==value['sha256'] for value in mapping.values())
 execution=json.loads((out/'execution.json').read_text());assert execution['executed'] and len(execution['cases'])==2
 assert digest(out/'fixture/main.cs')==execution['fixture_source_sha256']
 assert all(mapping[name]['sha256']==sha for name,sha in {**execution['binding_inputs'],**execution['original']}.items())
 cases=[]
 for name in ('missing-library','missing-scene'):
  case=out/name;e=json.loads((case/'execution.json').read_text());assert e['executed'] and e['native_exit_code']==0 and e['language']=='CSharp' and e['case']==name
  assert all(mapping[path]['sha256']==sha for path,sha in e['artifacts'].items())
  raw=(case/'run.log').read_text();assert digest(case/'run.log')==e['raw_log_sha256']
  assert raw.count('GODOT_BINDING_ASYNC CSharp accepted=1 running=0 error_empty=1')==1
  messages=re.findall(r'GODOT_BINDING_ASYNC CSharp error=([^\r\n]+)',raw);assert len(messages)==1;error=messages[0]
  expected='cannot load Dora/Godot runtime DLL, Win32 error 126' if name=='missing-library' else 'Godot project startup failed'
  assert error==expected and e['expected_error_substring']==expected
  assert raw.count('GODOT_BINDING_ASYNC_HOST observed=1')==raw.count('GODOT_BINDING_ASYNC_HOST complete=1 captures=2')==1
  assert raw.index('accepted=1')<raw.index('CSharp error=')<raw.index('HOST observed=1')<raw.index('HOST complete=1')
  errors=[line for line in raw.splitlines() if re.search(r'ERROR:|WARNING:|\[(?:error|critical|warning)\]',line)]
  own=[line for line in errors if re.search(r'\[error\] GodotNode: '+re.escape(expected)+r'$',line)];assert len(own)==1,errors
  upstream=[line for line in errors if line not in own]
  if name=='missing-library':assert not upstream and 'Godot Engine v' not in raw
  else:
   assert upstream==["ERROR: Cannot open file 'res://dora-intentionally-missing-binding-scene.tscn'.",'ERROR: Failed loading resource: res://dora-intentionally-missing-binding-scene.tscn.','ERROR: Failed loading scene: res://dora-intentionally-missing-binding-scene.tscn.'],upstream
   assert 'OpenGL API 3.3' in raw and 'Parallels using Metal' in raw
  assert not any(token in raw for token in ('BGFX LEAK:','C++ objects leaks','MTLCommandBufferError','GODOT_BINDING_ASYNC CSharp failure=','missing imported function','Wasm trap'))
  assert not re.search(r'GodotRuntime (?:client closed|shutdown):|GodotRuntime readers:|GodotAudio drained:',raw), 'GL early failure has no opened client; unexpected work must be audited'
  images=[Image.open(case/f'frame-{i}.png').convert('RGB') for i in (1,2)];assert images[0].size==images[1].size==(1280,720)
  centers=[]
  for image in images:
   green=[i%image.width for i,(r,g,b) in enumerate(pixels(image)) if g>220 and r<30 and b<30];assert len(green)>500
   centers.append(sum(green)/len(green))
  assert centers[1]-centers[0]>100
  changed=sum(max(pixel)>20 for pixel in pixels(ImageChops.difference(*images)));assert changed>1000
  assert all(digest(case/path)==sha for path,sha in e['images_sha256'].items())
  cleanup=bool(re.search(r'destroy: .*Director.*SpriteRenderer.*BGFXDora',raw) and 'destroy: Logger.' in raw)
  cases.append({'case':name,'binding_feedback_passed':True,'full_engine_cleanup_observed':cleanup,'last_error':error,'dora_green_centers':centers,'changed_pixels':changed,'images_sha256':e['images_sha256'],'raw_log_sha256':digest(case/'run.log')})
 feedback={'passed':True,'scope':'Actual Windows ARM64 VM/x64 .NET generated P/Invoke public App.Run: two asynchronous errors, public Event.Emit and four continuing Dora captures. No GPU-sharing, physical hardware or full native teardown claim. Reused existing native/runtime DLLs; no private test entry invoked.','native_processes':2,'captures':4,'cases':cases,'exported_inputs_rehashed':len(mapping)}
 (out/'feedback-verification.json').write_text(json.dumps(feedback,indent=2)+'\n')
 complete=all(case['full_engine_cleanup_observed'] for case in cases)
 result={'passed':complete,'binding_feedback_passed':True,'full_engine_cleanup_observed':complete,'scope':'Full native engine cleanup gate in addition to generated C# error feedback. Missing Director/SpriteRenderer/BGFXDora/Logger destruction prevents full acceptance even when the process exits zero.','cases':cases}
 (out/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
 print('C# feedback PASS; complete native cleanup '+('PASS' if complete else 'NOT OBSERVED'))
 raise SystemExit(0 if complete else 1)
except Exception as error:
 (out/'feedback-verification.json').unlink(missing_ok=True)
 (out/'verification.json').unlink(missing_ok=True)
 (out/'verification-failure.json').write_text(json.dumps({'passed':False,'error':repr(error)},indent=2)+'\n');raise
