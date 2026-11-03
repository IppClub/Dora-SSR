#!/usr/bin/env python3
"""Build pinned LibGodot with one Dora Windows graphics bridge.
Produces a sealed Debug or optimized Release package; a build is not a GPU pass.
"""
import argparse,hashlib,json,os,re,subprocess,sys,shutil
from pathlib import Path
root=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser()
parser.add_argument('--build-dir',type=Path)
parser.add_argument('--arch',choices=['x86_64','arm64'],default='x86_64')
parser.add_argument('--jobs',type=int,default=2)
parser.add_argument('--target',choices=['template_debug','template_release'],default='template_debug')
parser.add_argument('--backend',choices=['WGL','D3D12'],default='WGL')
parser.add_argument('--mesa-libs',type=Path,help='Installed Godot NIR dependency root required by D3D12 builds')
parser.add_argument('--builder',choices=['auto','xmake'],default='xmake',help='Native xmake for all supported configurations; auto is a compatibility alias')
parser.add_argument('--xmake',default=os.environ.get('DORA_GODOT_XMAKE','xmake'))
parser.add_argument('--xmake-sdk',type=Path,help='MinGW SDK root (for example /usr when cross-compiling)')
parser.add_argument('--xmake-cross',help='MinGW executable prefix, for example x86_64-w64-mingw32-')
args=parser.parse_args()
args.builder='xmake'
mode='release' if args.target=='template_release' else 'debug'
if args.backend=='D3D12' and (not args.mesa_libs or not args.mesa_libs.is_dir()):
    parser.error('--mesa-libs must identify the audited Godot NIR SDK root for D3D12')
build=(args.build_dir or root/('build/godot-windows-d3d12' if args.backend=='D3D12' else 'build/godot-windows')).resolve()
build.mkdir(parents=True,exist_ok=True)
assert args.jobs>0
source=root/'Source/3rdParty/Godot'
subprocess.run([sys.executable,str(root/'Tools/Godot/prepare.py'),str(source)],check=True)
xmake=shutil.which(args.xmake)
if not xmake:parser.error('Configured xmake executable is missing: '+args.xmake)
version_output=subprocess.check_output([xmake,'--version'],text=True)
version=re.search(r'xmake\s+v(\d+)\.',version_output)
if not version or int(version[1])<3:
    parser.error('Godot xmake migration requires xmake 3.x or newer; use --xmake to select it: '+xmake)
env=os.environ.copy()
env['XMAKE_CONFIGDIR']=str(build/'xmake-config')
configure=[xmake,'f','-P',str(root),'-c','-p','mingw','-a',args.arch,'-m',mode,'--dora_godot_runtime=y','--dora_godot_standalone=y',
    '--dora_godot_windows_backend='+args.backend.lower(),'--ccache=n','-y']
if args.backend=='D3D12':configure+=['--dora_godot_mesa_libs='+str(args.mesa_libs.resolve())]
if args.xmake_sdk:configure+=['--sdk='+str(args.xmake_sdk.resolve())]
if args.xmake_cross:configure+=['--cross='+args.xmake_cross]
compile_command=[xmake,'build','-P',str(root),'-j'+str(args.jobs),'godot-runtime']
toolchain_command=[xmake,'l','-P',str(root),'Projects/xmake/godot/toolchain_info.lua',str(build/'toolchain.json')]
commands=[configure,toolchain_command,compile_command]
names=['xmake.lua','Projects/xmake/options.lua','Projects/xmake/godot/targets.lua','Tools/Godot/generate_xmake_sources.py',
       'Projects/xmake/godot/windows_'+('d3d12_' if args.backend=='D3D12' else '')+args.arch+'_sources.lua']
inputs={name:hashlib.sha256((root/name).read_bytes()).hexdigest() for name in names}
(build/'compilation.json').unlink(missing_ok=True)
(build/'command.json').write_text(json.dumps(commands,indent=2)+'\n')
with (build/'build.log').open('w') as log:
    for command in commands:
        subprocess.run(command,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
assert all(hashlib.sha256((root/name).read_bytes()).hexdigest()==value for name,value in inputs.items()),'Godot xmake inputs changed during the build'
output=root/'build/godot-xmake/windows'/args.arch/args.backend.lower()
if mode=='debug':output=output/'debug'
libraries=list((output/'lib').glob('*dora_godot.dll'))
assert len(libraries)==1, 'Expected one xmake runtime DLL, found '+str(libraries)
subprocess.run([sys.executable,str(root/'Tools/Godot/package_runtime.py'),'--source',str(source),
    '--library',str(libraries[0]),'--output',str(build/'package'),'--architecture',args.arch,
    '--build-target',args.target,'--graphics-backend',args.backend.lower()],check=True)
(build/'compilation.json').write_text(json.dumps({'compiled':True,'builder':'xmake','target':'Windows '+args.arch,
    'godot_target':args.target,'graphics_backend':args.backend.lower(),'xmake':xmake,'gpu_tested':False,'toolchain':json.loads((build/'toolchain.json').read_text()),
    'migration_inputs_sha256':inputs,'runtime_sha256':hashlib.sha256(libraries[0].read_bytes()).hexdigest(), 'commands':commands},indent=2)+'\n')
print('Windows xmake runtime packaged; actual GPU validation still required',flush=True)
sys.exit(0)
