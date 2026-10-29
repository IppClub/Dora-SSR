#!/usr/bin/env python3
"""Build actual Rust/Wa regression modules and compile all C# binding units and the native-host fixture.
Does not start Godot, and does not count compilation as GPU validation.
"""
import argparse, hashlib, json, os, shutil, subprocess
from pathlib import Path, PureWindowsPath
root=Path(__file__).resolve().parents[4]
parser=argparse.ArgumentParser()
parser.add_argument('--output',type=Path,default=root/'build/godot-bindings')
parser.add_argument('--project',type=Path,default=root/'Tools/Godot/tests/project')
parser.add_argument('--languages',nargs='+',choices=['Rust','Wa','CSharp'],default=['Rust','Wa','CSharp'])
parser.add_argument('--constructor-rejections',action='store_true',help='Reject six invalid constructors before each successful node')
parser.add_argument('--sprite-cast',action='store_true',help='Exercise Wa GodotNode-to-Sprite and plain-Node rejection through real imports')
args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
assert not args.sprite_cast or args.languages==['Wa'], '--sprite-cast currently applies to the Wa fixture'
# Keep cross-host target paths lexical: macOS resolves /tmp to /private/tmp.
project=str(args.project) if PureWindowsPath(str(args.project)).is_absolute() else str(args.project.absolute())
report={}
(out/'compilation.json').unlink(missing_ok=True)
def run(command,log,cwd=root,env=None):
    with (out/log).open('w') as stream:
        subprocess.run(command,cwd=cwd,env=env,stdout=stream,stderr=subprocess.STDOUT,check=True,timeout=300)
for language in args.languages:
    if language=='Rust':
        stage=out/'rust';(stage/'src').mkdir(parents=True,exist_ok=True)
        shutil.copyfile(Path(__file__).with_name('main.rs'),stage/'src/main.rs')
        (stage/'Cargo.toml').write_text('[package]\nname="godot-bindings"\nversion="0.0.0"\nedition="2021"\n[dependencies]\ndora-ssr={path='+json.dumps(str(root/'Tools/dora-rust/dora'))+'}\n')
        env=os.environ.copy();env['DORA_GODOT_BINDING_PROJECT']=project
        env['DORA_GODOT_BINDING_REJECTIONS']='1' if args.constructor_rejections else '0'
        run(['cargo','build','--manifest-path',str(stage/'Cargo.toml'),'--target','wasm32-wasip1'],'rust-build.log',env=env)
    elif language=='Wa':
        stage=out/'wa';(stage/'src').mkdir(parents=True,exist_ok=True)
        (stage/'wa.mod').write_text('name="godot-bindings"\npkgpath="godot_bindings"\ntarget="wasi"\n')
        shutil.copytree(root/'Tools/dora-wa/vendor',stage/'vendor',dirs_exist_ok=True)
        (stage/'src/main.wa').write_text(Path(__file__).with_name('main.wa').read_text().replace('"@PROJECT@"',json.dumps(project,ensure_ascii=False)).replace('@CONSTRUCTOR_REJECTIONS@','true' if args.constructor_rejections else 'false').replace('@SPRITE_CAST@','true' if args.sprite_cast else 'false'))
        # Wa 1.2 project builds use output/<module name>.wasm, even with -o.
        artifact=stage/'output/godot-bindings.wasm';artifact.unlink(missing_ok=True)
        run(['wa','build','.'],'wa-build.log',cwd=stage)
        assert artifact.read_bytes().startswith(b'\x00asm'), 'Wa did not emit a Wasm module'
        shutil.copyfile(artifact,out/'wa.wasm')
    else:
        stage=out/'csharp';stage.mkdir(exist_ok=True)
        import xml.sax.saxutils as xml
        source=xml.escape(str(root/'Tools/dora-cs/DoraCS/Dora/**/*.cs'),{'"':'&quot;'})
        fixture=xml.escape(str(Path(__file__).with_name('main.cs')),{'"':'&quot;'})
        (stage/'bindings.csproj').write_text('<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><TargetFramework>net8.0</TargetFramework><OutputType>Exe</OutputType><Nullable>enable</Nullable><AllowUnsafeBlocks>true</AllowUnsafeBlocks><ImplicitUsings>enable</ImplicitUsings><EnableDefaultCompileItems>false</EnableDefaultCompileItems><TreatWarningsAsErrors>true</TreatWarningsAsErrors></PropertyGroup><ItemGroup><Compile Include="'+source+'" /><Compile Include="'+fixture+'" /></ItemGroup></Project>')
        run(['dotnet','build',str(stage/'bindings.csproj'),'--nologo'],'csharp-build.log')
    artifact={'Rust':out/'rust/target/wasm32-wasip1/debug/godot-bindings.wasm',
              'Wa':out/'wa.wasm','CSharp':out/'csharp/bin/Debug/net8.0/bindings.dll'}[language]
    assert artifact.is_file(),artifact
    binding={'Rust':root/'Tools/dora-rust/dora/src/dora/godot_node.rs',
             'Wa':root/'Tools/dora-wa/vendor/dora/godot_node.wa',
             'CSharp':root/'Tools/dora-cs/DoraCS/Dora/GodotNode.cs'}[language]
    report[language]={'compiled':True,'runtime_tested':False,'artifact':str(artifact),
        'constructor_rejections':args.constructor_rejections,
        'sprite_cast':args.sprite_cast,
        'artifact_sha256':hashlib.sha256(artifact.read_bytes()).hexdigest(),
        'godot_binding_sha256':hashlib.sha256(binding.read_bytes()).hexdigest()}
(out/'compilation.json').write_text(json.dumps({'scope':'language bindings compilation only; no GPU execution','languages':report},indent=2)+'\n')
print(json.dumps(report,indent=2))
