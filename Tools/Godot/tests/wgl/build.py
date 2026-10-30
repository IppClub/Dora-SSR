#!/usr/bin/env python3
"""Build a real Windows x64 WGL transport executable with MinGW.
Compilation is not Windows GPU execution. Run transport.exe on Windows and keep
its renderer/error output separately. Uses the pinned Godot GLAD implementation.
"""
import argparse,json,subprocess,re
from pathlib import Path
root=Path(__file__).resolve().parents[4]
parser=argparse.ArgumentParser()
parser.add_argument('--godot-source',type=Path,required=True)
parser.add_argument('--output',type=Path,default=root/'build/godot-windows/transport')
parser.add_argument('--cc',default='x86_64-w64-mingw32-gcc')
parser.add_argument('--cxx',default='x86_64-w64-mingw32-g++')
parser.add_argument('--dora-objects',action='store_true',help='Also compile the real Dora GodotNode and Windows loader objects')
args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
(out/'compilation.json').unlink(missing_ok=True)
glad=args.godot_source.resolve()/'thirdparty/glad';assert (glad/'gl.c').is_file()
for name in ['gl','egl']:
    subprocess.run([args.cc,'-O0','-g','-I',str(glad),'-c',str(glad/(name+'.c')),'-o',str(out/(name+'.o'))],check=True)
for name in ['transport','runtime']:
    sources=[str(root/('Tools/Godot/tests/wgl/'+name+'.cpp'))]
    if name=='transport':sources.append(str(root/'Tools/Godot/module/gl/wgl_transport.cpp'))
    subprocess.run([args.cxx,'-std=c++20','-O0','-g','-Wall','-Wextra','-Werror','-Wno-cast-function-type','-I',str(root),'-I',str(glad),
        *(['-municode'] if name=='runtime' else []),*sources,str(out/'gl.o'),str(out/'egl.o'),'-static','-lopengl32','-lgdi32','-luser32','-o',str(out/(name+'.exe'))],check=True)
if args.dora_objects:
    metadata=(root/'Projects/xmake/engine.lua').read_text().split('local dora_includedirs = {',1)[1].split('}',1)[0]
    includes=['-I'+str(root/name) for name in re.findall(r'rootpath\("([^"]+)"\)',metadata)]
    for name in ['GodotRuntimeGL','GodotNode','Application']:
        source=root/('Source/Basic/'+name+'.cpp' if name=='Application' else 'Source/Godot/'+name+'.cpp')
        subprocess.run([args.cxx,'-std=c++20','-O0','-DBX_CONFIG_DEBUG=1','-DSPDLOG_FMT_EXTERNAL','-DNOMINMAX','-DWIN32_LEAN_AND_MEAN','-DDORA_GODOT_NODE_TEST=1','-DWITH_SDL2_STATIC',
            *includes,'-c',str(source),'-o',str(out/(name+'.o'))],check=True)
report={'compiled':True,'target':'Windows x64','scope':'real WGL transport binary; GPU execution pending','gpu_tested':False,'native_dora_bridge_objects':args.dora_objects}
(out/'compilation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
