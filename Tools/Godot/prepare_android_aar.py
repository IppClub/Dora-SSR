#!/usr/bin/env python3
"""Stage pinned upstream Android Java/resources without its competing native SOs."""
import argparse,hashlib,json,os,subprocess,sys,urllib.request,zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--output',type=Path,default=root/'build/godot-android/java')
p.add_argument('--builder',choices=('maven','vendor'),default='vendor')
p.add_argument('--sdk',type=Path,default=os.environ.get('ANDROID_HOME') or os.environ.get('ANDROID_SDK_ROOT'))
p.add_argument('--java-home',type=Path)
p.add_argument('--vendor-build-dir',type=Path,default=root/'build/godot-android/vendor-java')
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
source_build=None
if a.builder=='vendor':
 if not a.sdk:p.error('--sdk is required for --builder vendor')
 command=[sys.executable,str(root/'Tools/Godot/build_android_java.py'),'--sdk',str(a.sdk),'--output',str(a.vendor_build_dir)]
 if a.java_home:command+=['--java-home',str(a.java_home)]
 subprocess.run(command,check=True)
 source_build=json.loads((a.vendor_build_dir/'manifest.json').read_text())
 assert source_build['passed'] and source_build['vendor_sources_unchanged']
 archive=Path(source_build['source_aar']);expected=source_build['source_aar_sha256']
else:
 archive=root/'build/godot-android/deps/godot-4.7.2.stable.aar';archive.parent.mkdir(parents=True,exist_ok=True)
 expected='8791eecfe7c96a4de2d188a0bccfe9b83b92589a5a6825847473416a990e8629'
 if not archive.is_file():urllib.request.urlretrieve('https://repo.maven.apache.org/maven2/org/godotengine/godot/4.7.2.stable/godot-4.7.2.stable.aar',archive)
assert hashlib.sha256(archive.read_bytes()).hexdigest()==expected
output=a.output/'godot-java-4.7.2.stable.aar';removed=[]
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
(a.output/'manifest.json').write_text(json.dumps({'builder':a.builder,'source_build':source_build,'source_version':'4.7.2.stable','source_sha256':expected,'java_aar_sha256':hashlib.sha256(output.read_bytes()).hexdigest(),'provider_class':'org.ippclub.dorassr.GodotFileProvider','removed_native_entries':removed,'scope':'upstream Java/resources only; native runtime supplied separately by the compiled Dora bridge'},indent=2)+'\n')
print(output.resolve())
