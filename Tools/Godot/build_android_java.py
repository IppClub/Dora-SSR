#!/usr/bin/env python3
"""Build Java/resources from the pinned vendor tree, without SCons or native SOs."""
import argparse,hashlib,json,os,re,shutil,subprocess,zipfile
from pathlib import Path
from vendor_source import verify_android
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--sdk',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
p.add_argument('--java-home',type=Path)
a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
source=ROOT/'Source/3rdParty/Godot';main=source/'platform/android/java/lib/src/main'
verify_android(source)
config=source/'platform/android/java/app/config.gradle';version=source/'version.py'
build_inputs=[config,version,source/'UPSTREAM.json',
              source/'platform/android/java/gradlew',source/'platform/android/java/gradlew.bat',
              source/'platform/android/java/gradle/wrapper/gradle-wrapper.jar',
              source/'platform/android/java/gradle/wrapper/gradle-wrapper.properties']
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def snapshot():return {str(f.relative_to(source)):sha(f) for f in sorted([*main.rglob('*'),*build_inputs]) if f.is_file()}
def setting(name):
    m=re.search(r'\b'+re.escape(name)+r"\s*:\s*'([^']+)'",config.read_text());assert m,name;return m[1]
def version_field(name):
    m=re.search(r'^'+name+r'\s*=\s*(.+)$',version.read_text(),re.M);assert m,name;return m[1].strip('"')
library_version='.'.join(version_field(n) for n in ('major','minor','patch','status'))
assert library_version=='4.6.0.stable',library_version
before=snapshot();project=out/'project';project.mkdir(exist_ok=True)
for name in ('settings.gradle','build.gradle'):
    shutil.copy2(ROOT/'Projects/xmake/godot/android-java'/name,project/name)
(project/'gradle.properties').write_text('android.useAndroidX=true\nandroid.enableJetifier=true\nandroid.enableResourceOptimizations=false\norg.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8\nkotlin.compiler.execution.strategy=in-process\n')
sdk=str(a.sdk.resolve()).replace('\\','\\\\').replace(':','\\:')
(project/'local.properties').write_text('sdk.dir='+sdk+'\n')
env=os.environ.copy();env['ANDROID_HOME']=str(a.sdk.resolve())
java=a.java_home or (Path(env['JAVA_HOME']) if env.get('JAVA_HOME') else None)
if not java:
    candidate=Path('/Applications/Android Studio.app/Contents/jbr/Contents/Home')
    if candidate.is_dir():java=candidate
if java:env['JAVA_HOME']=str(java.resolve())
wrapper=source/('platform/android/java/gradlew.bat' if os.name=='nt' else 'platform/android/java/gradlew')
command=[str(wrapper),'-p',str(project),'--no-daemon','--max-workers=2',
         '-Pdora.godot.source='+str(source),'-Pdora.godot.version='+library_version,
         '-Pdora.godot.agp='+setting('androidGradlePlugin'),'-Pdora.godot.kotlin='+setting('kotlinVersion'),
         'assembleTemplateRelease']
(out/'command.json').write_text(json.dumps({'command':command,'java_home':env.get('JAVA_HOME'),'source_files':before},indent=2)+'\n')
with (out/'build.log').open('w') as log:result=subprocess.run(command,cwd=project,env=env,stdout=log,stderr=subprocess.STDOUT)
assert snapshot()==before,'Gradle changed vendor Java/resources'
(out/'result.json').write_text(json.dumps({'exit_code':result.returncode,'vendor_sources_unchanged':True})+'\n')
if result.returncode:raise SystemExit(result.returncode)
archives=list((project/'build/outputs/aar').glob('*-template-release.aar'));assert len(archives)==1,archives
archive=out/'godot-lib.template_release.aar';shutil.copy2(archives[0],archive)
with zipfile.ZipFile(archive) as z:
    assert 'classes.jar' in z.namelist() and 'AndroidManifest.xml' in z.namelist()
    assert not any(n.startswith('jni/') for n in z.namelist())
metadata={'passed':True,'builder':'vendor-gradle','source_version':library_version,'upstream_commit':'89cea143987d564363e15d207438530651d943ac','source_files':before,'vendor_sources_unchanged':True,'source_config_sha256':sha(config),'source_version_sha256':sha(version),'source_aar':str(archive),'source_aar_sha256':sha(archive),'agp':setting('androidGradlePlugin'),'kotlin':setting('kotlinVersion'),'native_entries':0,'scope':'Java/resources built from vendored source only; JNI loading and Android runtime acceptance remain separate'}
(out/'manifest.json').write_text(json.dumps(metadata,indent=2)+'\n');print(archive,flush=True)
