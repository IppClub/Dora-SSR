#!/usr/bin/env python3
"""Run owning generators in isolation and publish the integration binding outputs.

Preserves unrelated user changes in other generated bindings.
"""
import argparse,shutil,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=root/'build/godot-bindings-generator');a=p.parse_args()
stage=a.output.resolve();assert stage.is_relative_to(root/'build') and stage!=root/'build', 'Use a dedicated directory under build/'
for relative in ('Tools/WasmGen','Tools/dora-cs/CSharpGen','Source/Wasm/Dora',
                 'Tools/dora-rust/dora/src/dora','Tools/dora-wa/vendor','Tools/dora-cs/DoraCS/Dora'):
    shutil.copytree(root/relative,stage/relative,dirs_exist_ok=True)
outputs=('Source/Wasm/Dora/GodotNodeWasm.hpp','Tools/dora-rust/dora/src/dora/godot_node.rs',
         'Tools/dora-wa/vendor/dora/godot_node.wa','Tools/dora-cs/DoraCS/Dora/GodotNode.cs',
         *(f'Tools/dora-cs/DoraCS/Dora/{name}.cs' for name in ('Audio','Director','Grabber','Grid','RenderTarget')))
for relative in outputs:
    (stage/relative).unlink(missing_ok=True)
for relative in ('Tools/WasmGen','Tools/dora-cs/CSharpGen'):
    with (stage/(Path(relative).name+'-generator.log')).open('w') as log:
        subprocess.run(['yue','-e','gen.yue'],cwd=stage/relative,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=300)
for relative in outputs:
    source=stage/relative;assert source.is_file(),relative
    text=source.read_text()
    if 'godot' in source.name.lower():assert 'viewport' in text.lower() and 'resize' in text.lower(),relative
    target=root/relative
    if not target.is_file() or target.read_bytes()!=source.read_bytes():shutil.copyfile(source,target)
print('Generated GodotNode bindings and C# ABI repairs; other outputs remain isolated')
