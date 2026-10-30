#!/usr/bin/env python3
"""Run the generated Rust/Wa modules through real Wasm3 and GodotNode.
Build the native opt-in test host and the modules with build.py first.
On headless Linux wrap this in tests/with_weston.py.
"""
import argparse, collections, hashlib, json, os, re, shutil, subprocess, sys
from pathlib import Path
from constructor_rejections import prepare_recovery
root=Path(__file__).resolve().parents[4]
parser=argparse.ArgumentParser()
parser.add_argument('--output',type=Path,default=root/'build/godot-bindings')
parser.add_argument('--project',type=Path,default=root/'Tools/Godot/tests/project')
parser.add_argument('--app',type=Path,help='Explicit isolated macOS test host; leave its content/signature unchanged')
parser.add_argument('--library',type=Path,help='Explicit runtime library; overrides DORA_GODOT_LIBRARY')
parser.add_argument('--languages',nargs='+',choices=['Rust','Wa'],default=['Rust','Wa'])
parser.add_argument('--verify-only',action='store_true',help='Verify existing captures and binding command logs without rerunning the GPU test')
parser.add_argument('--constructor-rejections',action='store_true',help='Verify opt-in Rust/Wa invalid constructors followed by normal GPU recovery')
parser.add_argument('--sprite-cast',action='store_true',help='Require the opt-in Wa Sprite conversion checks in each lifetime')
for flag in ('resize','cancel-resize','aliases','audio','audio-stall','reservation'):
    parser.add_argument('--'+flag,action='store_true')
args=parser.parse_args()
assert not args.sprite_cast or args.languages==['Wa'], '--sprite-cast currently applies to the Wa fixture'
if args.sprite_cast:
    assert json.loads((args.output/'compilation.json').read_text())['languages']['Wa']['sprite_cast']
assert not args.cancel_resize or args.resize, '--cancel-resize requires --resize'
assert not args.audio_stall or args.audio, '--audio-stall requires --audio'
assert sys.platform in ('darwin','linux','win32'), 'This runner supports macOS, Linux and Windows'
out=args.output.resolve();platform={'darwin':'macOS Metal','linux':'Linux EGL','win32':'Windows WGL'}[sys.platform]
if args.constructor_rejections:
    compiled=json.loads((out/'compilation.json').read_text())['languages']
    assert all(compiled[language]['constructor_rejections'] for language in args.languages),'Build explicit constructor-rejection fixtures first'
if sys.platform=='darwin':
    app=(args.app or root/'build/godot-runtime/dora/Dora.app').resolve();binary=app/'Contents/MacOS/Dora'
    if not args.verify_only and not args.app:
        (app/'Contents/Resources/Script/init.lua').write_text('return true\n')
        subprocess.run(['codesign','--force','--deep','--sign','-',str(app)],check=True)
    library=root/'build/godot-runtime/package/libdora_godot.dylib'
    if not args.verify_only and args.app:
        subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True,capture_output=True)
else:
    assert not args.app,'--app applies to macOS only'
    binary=root/('build/godot-runtime/dora/Dora.exe' if sys.platform=='win32' else 'build/godot-runtime/dora/Dora')
    library=root/('build/godot-windows/package/dora_godot.dll' if sys.platform=='win32' else 'build/godot-linux/package/libdora_godot.so')
    assert args.verify_only or sys.platform=='win32' or os.environ.get('WAYLAND_DISPLAY') or os.environ.get('DISPLAY'),'Provide a compositor, e.g. tests/with_weston.py'
    assets=root/'build/godot-runtime/test-assets'
    if not args.verify_only:
        assets.mkdir(parents=True,exist_ok=True)
        if sys.platform=='win32':shutil.copytree(root/'Assets',assets,dirs_exist_ok=True)
        else:subprocess.run(['rsync','-a',str(root/'Assets')+'/',str(assets)+'/'],check=True)
        (assets/'Script/init.lua').write_text('return true\n')
for language in args.languages:
    results=out/('node-'+language.lower());results.mkdir(parents=True,exist_ok=True)
    report_path=results/'verification.json';report_path.unlink(missing_ok=True)
    (results/'failure.json').unlink(missing_ok=True)
    wasm=out/'rust/target/wasm32-wasip1/debug/godot-bindings.wasm' if language=='Rust' else out/'wa.wasm'
    assert args.verify_only or (binary.is_file() and wasm.is_file()), 'Build host and binding fixtures first'
    env=os.environ.copy();env.update(DORA_GODOT_BINDING_WASM=str(wasm),DORA_GODOT_TEST_PROJECT=str(args.project.resolve()),DORA_GODOT_TEST_OUTPUT=str(results),DORA_GODOT_LIBRARY=str(args.library.resolve()) if args.library else env.get('DORA_GODOT_LIBRARY',str(library)),MTL_DEBUG_LAYER='1')
    flags=('resize','cancel-resize','aliases','audio','audio-stall','reservation')
    for flag in flags:
        env['DORA_GODOT_TEST_'+flag.upper().replace('-','_')]='1' if getattr(args,flag.replace('-','_')) else '0'
    env['DORA_GODOT_TEST_BUFFERS']='3'
    env['DORA_GODOT_TEST_SOAK_FRAMES']='0'
    env['DORA_GODOT_TEST_TIMING']='0'
    if sys.platform=='win32':env['DORA_GODOT_WINDOWS_GL']='1'
    if sys.platform!='darwin':env.update(SDL_AUDIODRIVER='dummy',GODOT_SILENCE_ROOT_WARNING='1')
    command=[str(binary)] if sys.platform=='darwin' else [str(binary),'--asset',str(assets)]
    try:
        if not args.verify_only:
            artifacts={str(path):hashlib.sha256(path.read_bytes()).hexdigest()
                for path in (binary,wasm,Path(env['DORA_GODOT_LIBRARY']))}
            (results/'artifacts.json').write_text(json.dumps(artifacts,indent=2)+'\n')
            with (results/'run.log').open('w') as log:
                subprocess.run(command,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=180)
            assert all(hashlib.sha256(Path(path).read_bytes()).hexdigest()==expected for path,expected in artifacts.items()),'Host, module or runtime changed during execution'
        verify_results=results
        if args.constructor_rejections:
            verify_results=prepare_recovery(results,language)
        subprocess.run([sys.executable,str(root/'Tools/Godot/tests/verify_macos.py'),'--platform',platform,'--results',str(verify_results)]+['--'+flag for flag in flags if getattr(args,flag.replace('-','_'))],check=True)
        log=(results/'run.log').read_text();prefix='GODOT_BINDING '+language+' '
        assert log.count(prefix+'created=1')==2
        if args.sprite_cast:
            assert log.count(prefix+'sprite_cast_begin=1')==2
            assert log.count(prefix+'sprite_cast=1 rejected_plain_node=1')==2
        expected={'probe':2,'resume':2,'verify':2,'pause':1,'input':1,'held':1,'restart':1}
        if args.resize:
            expected.update({operation:1 for operation in ('resize_large','resize_small','resize_restore','verify_large','verify_small','verify_restore','resize_pause','resize_resume','resize_invalid')})
        if args.cancel_resize:expected['resize_cancel']=1
        actual=collections.Counter(re.findall(re.escape(prefix)+r'command=([a-z_]+)(?=\r?$)',log,re.MULTILINE))
        assert actual==expected,(language,dict(actual),expected)
        report=json.loads((verify_results/'verification.json').read_text());report.update(binding_language=language,binding_transport='real Wasm3 generated imports',binding_commands=expected)
        if args.sprite_cast:report.update(sprite_cast_to_godot_node=2,non_sprite_cast_rejections=2)
        if args.constructor_rejections:
            report.update(constructor_rejections=12,raw_log_sha256=hashlib.sha256((results/'run.log').read_bytes()).hexdigest(),recovery_scope='Six rejected constructors per lifetime, then complete normal GPU verification; only the twelve exact expected error lines excluded from recovered/run.log, raw log preserved')
        report['artifacts']=json.loads((results/'artifacts.json').read_text())
        report_path.write_text(json.dumps(report,indent=2)+'\n')
        print(language+' bindings and GPU output: PASS',flush=True)
    except BaseException as error:
        report_path.unlink(missing_ok=True)
        (results/'failure.json').write_text(json.dumps({'passed':False,'language':language,'error_type':type(error).__name__,'error':str(error),'scope':'Binding runtime acceptance failed; frame completion does not prove process cleanup'},indent=2)+'\n')
        raise
