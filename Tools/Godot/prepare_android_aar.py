#!/usr/bin/env python3
"""Stage pinned upstream Android Java/resources without its competing native SOs."""
import argparse,hashlib,json,urllib.request,zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=root/'build/godot-android/java');a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
archive=root/'build/godot-android/deps/godot-4.6.0.stable.aar';archive.parent.mkdir(parents=True,exist_ok=True)
expected='567f1b8da098169cac561e7dcbda38f766697dca687baf542010fe7d5a7f8ef7'
if not archive.is_file():urllib.request.urlretrieve('https://repo.maven.apache.org/maven2/org/godotengine/godot/4.6.0.stable/godot-4.6.0.stable.aar',archive)
assert hashlib.sha256(archive.read_bytes()).hexdigest()==expected
output=a.output/'godot-java-4.6.0.stable.aar';removed=[]
with zipfile.ZipFile(archive) as source,zipfile.ZipFile(output,'w',zipfile.ZIP_DEFLATED) as destination:
 for item in source.infolist():
  if item.filename.startswith('jni/'):removed.append(item.filename);continue
  data=source.read(item.filename)
  if item.filename=='AndroidManifest.xml':
   android='http://schemas.android.com/apk/res/android';ET.register_namespace('android',android)
   manifest=ET.fromstring(data);changed=0
   for provider in manifest.iter('provider'):
    if provider.get('{'+android+'}name')=='androidx.core.content.FileProvider':
     provider.set('{'+android+'}name','org.ippclub.dorassr.GodotFileProvider');changed+=1
   assert changed==1,'Unexpected upstream provider declaration'
   data=ET.tostring(manifest,encoding='utf-8',xml_declaration=True)
  destination.writestr(item,data)
with zipfile.ZipFile(output) as result:assert not any(name.startswith('jni/') for name in result.namelist())
(a.output/'manifest.json').write_text(json.dumps({'source_version':'4.6.0.stable','source_sha256':expected,'java_aar_sha256':hashlib.sha256(output.read_bytes()).hexdigest(),'provider_class':'org.ippclub.dorassr.GodotFileProvider','removed_native_entries':removed,'scope':'upstream Java/resources only; native runtime supplied separately by the compiled Dora bridge'},indent=2)+'\n')
print(output.resolve())
