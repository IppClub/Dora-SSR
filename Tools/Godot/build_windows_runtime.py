#!/usr/bin/env python3
"""Build pinned LibGodot with one Dora Windows graphics bridge.
Produces a sealed Debug or optimized Release package; a build is not a GPU pass.
"""
import argparse,hashlib,json,os,shutil,subprocess,sys,tarfile,urllib.request,venv
from pathlib import Path
root=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser()
parser.add_argument('--build-dir',type=Path)
parser.add_argument('--archive',type=Path)
parser.add_argument('--scons',type=Path)
parser.add_argument('--arch',choices=['x86_64','arm64'],default='x86_64')
parser.add_argument('--jobs',type=int,default=2)
parser.add_argument('--target',choices=['template_debug','template_release'],default='template_debug')
parser.add_argument('--backend',choices=['WGL','D3D12'],default='WGL')
parser.add_argument('--mesa-libs',type=Path,help='Installed Godot NIR dependency root required by D3D12 builds')
parser.add_argument('--mingw',action='store_true',help='Use MinGW on a native Windows host; automatic when cross-compiling')
args=parser.parse_args()
build=(args.build_dir or root/('build/godot-windows-d3d12' if args.backend=='D3D12' else 'build/godot-windows')).resolve()
deps=build/'deps';deps.mkdir(parents=True,exist_ok=True)
assert args.jobs>0
archive=deps/'godot-4.6-stable.tar.gz'
if args.archive and args.archive.resolve()!=archive.resolve():shutil.copyfile(args.archive,archive)
if not archive.exists():
    urllib.request.urlretrieve('https://codeload.github.com/godotengine/godot/tar.gz/refs/tags/4.6-stable',archive)
expected='b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0'
assert hashlib.sha256(archive.read_bytes()).hexdigest()==expected,'Godot source archive checksum mismatch'
source=deps/'godot-4.6-stable'
if not source.is_dir():
    with tarfile.open(archive) as tar:tar.extractall(deps,filter='data')
subprocess.run([sys.executable,str(root/'Tools/Godot/prepare.py'),str(source)],check=True)
if args.scons:
    scons=args.scons.resolve();assert scons.is_file()
else:
    environment=build/'venv';windows=os.name=='nt'
    python=environment/('Scripts/python.exe' if windows else 'bin/python')
    scons=environment/('Scripts/scons.exe' if windows else 'bin/scons')
    if not scons.is_file():
        venv.create(environment,with_pip=True)
        subprocess.run([str(python),'-m','pip','install','scons==4.11.1'],check=True)
mingw=args.mingw or os.name!='nt'
release=args.target=='template_release'
is_d3d12=args.backend=='D3D12'
command=[str(scons),'platform=windows','arch='+args.arch,'target='+args.target,'library_type=shared_library',
    'disable_path_overrides=no','opengl3='+('no' if is_d3d12 else 'yes'),'vulkan=no','d3d12='+('yes' if is_d3d12 else 'no'),'accesskit=no','angle_libs=',
    'windows_subsystem=console','use_static_cpp=yes','optimize='+('speed' if release else 'none'),'debug_symbols=no','use_lto=no','-j'+str(args.jobs)]
if is_d3d12:
    assert args.mesa_libs and args.mesa_libs.is_dir(), '--mesa-libs is required for D3D12 (run Godot install_d3d12_sdk_windows.py first)'
    command+=['mesa_libs='+str(args.mesa_libs.resolve()),'use_pix=no','xaudio2=no','module_mono_enabled=no']
if mingw:command.append('use_mingw=yes')
(build/'command.json').write_text(json.dumps(command,indent=2)+'\n')
print('Building Windows '+args.arch+' runtime; log: '+str(build/'build.log'),flush=True)
with (build/'build.log').open('w') as log:subprocess.run(command,cwd=source,stdout=log,stderr=subprocess.STDOUT,check=True)
libraries=list((source/'bin').glob('libgodot*.dll'))+list((source/'bin').glob('godot*.dll'))
target_libraries=[path for path in libraries if args.target in path.name]
# Current Godot 4.6 shared-library builds on Windows use the unqualified
# `godot.dll` name, while older/patched build graphs include the target name.
# Prefer the qualified form when present, otherwise accept a sole exact DLL.
if len(target_libraries)==1:
    library=target_libraries[0]
else:
    exact=[path for path in libraries if path.name.lower()=='godot.dll']
    assert not target_libraries and len(libraries)==len(exact)==1, \
        'Expected one runtime DLL, found '+str(libraries)
    library=exact[0]
subprocess.run([sys.executable,str(root/'Tools/Godot/package_runtime.py'),'--source',str(source),'--library',str(library),'--output',str(build/'package'),'--architecture',args.arch,
    '--build-target',args.target,'--graphics-backend','d3d12' if is_d3d12 else 'wgl'],check=True)
(build/'compilation.json').write_text(json.dumps({'compiled':True,'target':'Windows '+args.arch,
    'godot_target':args.target,'optimization':'speed' if release else 'none','bridge':'D3D12 CPU-fence prototype' if is_d3d12 else 'WGL / OpenGL 3.3',
    'graphics_backend':'d3d12' if is_d3d12 else 'wgl',
    'gpu_tested':False,'scope':'full standard runtime; native window accessibility disabled; output validation recorded separately'},indent=2)+'\n')
print('Windows '+args.target+' runtime built; actual GPU validation still required',flush=True)
