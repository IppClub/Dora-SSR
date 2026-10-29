#!/usr/bin/env python3
"""Refresh and execute the new C# capability query in the task-owned Windows checkout.

Run from the shared source tree with the guest's Python. All native mutations
are confined to an already owned checkout; result copies stay under build/.
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--owned', type=Path, required=True)
parser.add_argument('--package', type=Path, required=True, help='Sealed version-1 Windows runtime package')
args = parser.parse_args()
assert sys.platform == 'win32'
shared = Path(__file__).resolve().parents[4]
owned = args.owned.resolve()
repo = owned / 'repo'
source_package = args.package.resolve()
assert (source_package / 'manifest.json').is_file()
assert (owned / 'task-owner.txt').is_file() and (repo / 'xmake.lua').is_file()
assert (owned / 'task-owner.txt').read_text(encoding='utf-8').strip() == 'Dora Godot integration task 01a17dc1', 'Unexpected task ownership marker'
assert repo.resolve() != shared.resolve(), 'Guest staging checkout must be separate'
# Fail before rebuilding/running native tests if this interpreter cannot run
# the strict image verifier used by run_csharp.py.
subprocess.run([sys.executable, '-c', 'from PIL import Image, ImageChops'], check=True)
out = repo / 'build/godot-bindings-capability-csharp'
out.mkdir(parents=True, exist_ok=True)
(out / 'pipeline-failure.json').unlink(missing_ok=True)
(out / 'node-csharp/verification.json').unlink(missing_ok=True)
destination = shared / 'build/godot-bindings-capability-csharp-windows'
destination.mkdir(parents=True, exist_ok=True)
files = ['Source/Basic/Application.cpp', 'Source/Common/Debug.cpp',
         'Source/Node/Sprite.cpp',
         'Source/3rdParty/bgfx/dora/BgfxEmbeddedShaders.hpp',
         'Source/Input/Keyboard.cpp', 'Source/Lua/LuaBinding.cpp',
         'Projects/xmake/engine.lua', 'Projects/xmake/manifests/engine.lua']
directories = ['Source/Godot', 'Source/Cache', 'Source/Wasm',
               'Tools/Godot/tests', 'Tools/dora-cs/DoraCS/Dora']
for relative in files:
    target = repo / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(shared / relative, target)
for relative in directories:
    shutil.copytree(shared / relative, repo / relative, dirs_exist_ok=True,
                    ignore=shutil.ignore_patterns('__pycache__', '.godot'))
hashes = {}
for relative in files + directories:
    source = shared / relative
    for path in ([source] if source.is_file() else source.rglob('*')):
        if path.is_file() and '__pycache__' not in path.parts and '.godot' not in path.parts:
            hashes[path.relative_to(shared).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
(out / 'source-hashes.json').write_text(json.dumps(hashes, indent=2) + '\n')
env = os.environ.copy()
env.update(XMAKE_PROGRAM_DIR=str(owned / 'tools-arm64/xmake'),
           DORA_BUILD_CSHARP_NATIVE='1', DORA_BUILD_GODOT_NODE_TEST='1',
           DORA_GODOT_WINDOWS_GL='1')
compiler = Path('C:/Program Files/dotnet/dotnet.exe')
dotnet = owned / 'dotnet-x64-8/dotnet.exe'
xmake = owned / 'tools-arm64/xmake/xmake.exe'
assert compiler.is_file() and dotnet.is_file() and xmake.is_file()
env['PATH'] = str(compiler.parent) + ';C:\\App\\Strawberry\\c\\bin;' + env['PATH']
try:
    with (out / 'pipeline.log').open('w', encoding='utf-8') as log:
        for command in ([str(xmake), 'f', '-y', '-p', 'windows', '-a', 'x64'],
                        [str(xmake), 'build', '-j2', 'Dora'],
                        [sys.executable, str(repo / 'Tools/Godot/tests/bindings/build.py'),
                         '--languages', 'CSharp', '--output', str(out)]):
            subprocess.run(command, cwd=repo, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
        package = repo / 'build/godot-windows/capability-package'
        shutil.copytree(source_package, package, dirs_exist_ok=True)
        # The guest scripts import this package verifier from their repo root.
        for name in ('verify_package.py', 'package_manifest.py'):
            shutil.copy2(shared / 'Tools/Godot' / name, repo / 'Tools/Godot' / name)
        subprocess.run([sys.executable, str(repo / 'Tools/Godot/verify_package.py'), str(package)],
                       cwd=repo, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
        subprocess.run([sys.executable, str(repo / 'Tools/Godot/tests/bindings/run_csharp.py'),
                        '--output', str(out), '--library', str(package / 'dora_godot.dll'),
                        '--dotnet', str(dotnet)], cwd=repo, env=env, stdout=log,
                       stderr=subprocess.STDOUT, check=True)
except BaseException as error:
    (out / 'pipeline-failure.json').write_text(json.dumps({'passed': False,
        'type': type(error).__name__, 'error': str(error)}, indent=2) + '\n')
    raise
finally:
    # copytree merges files; remove outcome markers absent from the new run.
    for relative in ('pipeline-failure.json', 'node-csharp/failure.json', 'node-csharp/verification.json'):
        if not (out / relative).is_file():
            (destination / relative).unlink(missing_ok=True)
    shutil.copytree(out, destination, dirs_exist_ok=True,
                    ignore=shutil.ignore_patterns('test-assets', 'obj'))
print('Windows C# capability query native acceptance: PASS', flush=True)
