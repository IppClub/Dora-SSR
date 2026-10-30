#!/usr/bin/env python3
"""Create a sealed, relocatable Windows D3D12 CPU-fence acceptance bundle."""
import argparse
import hashlib
import json
import shutil
import struct
from pathlib import Path

from verify_package import verify

root = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--host-dir', type=Path, required=True, help='Directory containing the D3D12-only Dora.exe host')
parser.add_argument('--runtime-package', type=Path, required=True, help='Sealed d3d12 Godot runtime package')
parser.add_argument('--output', type=Path, required=True, help='New bundle directory; must not already exist')
parser.add_argument('--assets', type=Path, default=root / 'Assets')
parser.add_argument('--project', type=Path, default=root / 'Tools/Godot/tests/project')
parser.add_argument('--include-symbols', action='store_true', help='Include host PDB files for crash-symbol handoff')
args = parser.parse_args()

host_dir = args.host_dir.resolve()
runtime = args.runtime_package.resolve()
output = args.output.resolve()
assert host_dir.is_dir() and (host_dir / 'Dora.exe').is_file(), 'D3D12 Dora.exe host is missing'
assert runtime.is_dir(), 'Runtime package is missing'
assert not output.exists(), 'Refusing to replace an existing test bundle: ' + str(output)
runtime_report = verify(runtime)
runtime_manifest = json.loads((runtime / 'manifest.json').read_text(encoding='utf-8'))
assert runtime_manifest.get('graphics_backend') == 'd3d12', 'Runtime package is not sealed as d3d12'
assert runtime_manifest.get('architectures') in (['x86_64'], ['x64']), 'Physical test bundle requires x64 runtime'

def pe_machine(path):
    with Path(path).open('rb') as file:
        assert file.read(2) == b'MZ', 'Not a PE image: ' + str(path)
        file.seek(0x3c)
        offset = struct.unpack('<I', file.read(4))[0]
        file.seek(offset)
        assert file.read(4) == b'PE\0\0', 'Invalid PE signature: ' + str(path)
        return struct.unpack('<H', file.read(2))[0]

runtime_library = runtime / runtime_manifest['library']
assert pe_machine(host_dir / 'Dora.exe') == 0x8664, 'Dora host is not x86_64'
assert pe_machine(runtime_library) == 0x8664, 'Godot runtime is not x86_64'

host_output = output / 'build/godot-runtime/dora'
host_output.mkdir(parents=True)
for source in [host_dir / 'Dora.exe', *sorted(host_dir.glob('*.dll'))]:
    shutil.copy2(source, host_output / source.name)
if args.include_symbols:
    for source in sorted(host_dir.glob('*.pdb')):
        shutil.copy2(source, host_output / source.name)
shutil.copytree(runtime, output / 'runtime')
shutil.copytree(args.assets.resolve(), output / 'Assets', ignore=shutil.ignore_patterns('build', '.DS_Store', '*.tmp'))
(output / 'Assets/Script/init.lua').write_text('return true\n', encoding='utf-8')
shutil.copytree(args.project.resolve(), output / 'Tools/Godot/tests/project')
cache = output / 'Tools/Godot/tests/project/.godot'
cache.mkdir(parents=True, exist_ok=True)
(cache / 'global_script_class_cache.cfg').write_text('list=[]\n', encoding='utf-8')
for relative in (
    'Tools/Godot/test_windows.py',
    'Tools/Godot/tests/runtime_abi.py',
    'Tools/Godot/tests/verify_macos.py',
    'Tools/Godot/tests/pck_manifest.py',
    'Tools/Godot/verify_package.py',
    'Tools/Godot/package_manifest.py',
):
    source = root / relative
    destination = output / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)

(output / 'requirements.txt').write_text('Pillow==12.3.0\n', encoding='utf-8')
(output / 'setup-python.cmd').write_text(r'''@echo off
setlocal
cd /d "%~dp0"
py -3 -m venv .venv || exit /b 1
.venv\Scripts\python.exe -m pip install --requirement requirements.txt || exit /b 1
echo Python test environment ready.
''', encoding='utf-8')
(output / 'collect-system.ps1').write_text(r'''$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Out = Join-Path $Root "results\system"
New-Item -ItemType Directory -Force -Path $Out | Out-Null
Get-CimInstance Win32_OperatingSystem | Format-List * | Out-File -Encoding utf8 (Join-Path $Out "operating-system.txt")
Get-CimInstance Win32_VideoController | Format-List * | Out-File -Encoding utf8 (Join-Path $Out "video-controllers.txt")
& dxdiag.exe /whql:off /t (Join-Path $Out "dxdiag.txt")
Get-FileHash -Algorithm SHA256 (Join-Path $Root "build\godot-runtime\dora\Dora.exe"), (Join-Path $Root "runtime\dora_godot.dll") |
    ConvertTo-Json | Out-File -Encoding utf8 (Join-Path $Out "binary-hashes.json")
''', encoding='utf-8')

runner = r'''@echo off
setlocal
cd /d "%~dp0"
if not exist .venv\Scripts\python.exe (
  echo Run setup-python.cmd first.
  exit /b 2
)
powershell -NoProfile -ExecutionPolicy Bypass -File collect-system.ps1 || exit /b 3
set DORA_GODOT_WINDOWS_GL=
set DORA_GODOT_D3D12_WARP=
.venv\Scripts\python.exe Tools\Godot\test_windows.py --skip-build --backend D3D12 --buffers BUFFER_COUNT --resize --aliases --runtime-package "%CD%\runtime" --project "%CD%\Tools\Godot\tests\project" --results "%CD%\results\buffers-BUFFER_COUNT"
exit /b %errorlevel%
'''
for buffers in (2, 3, 4):
    (output / f'run-d3d12-{buffers}.cmd').write_text(runner.replace('BUFFER_COUNT', str(buffers)), encoding='utf-8')
(output / 'run-d3d12-matrix.cmd').write_text(r'''@echo off
setlocal
cd /d "%~dp0"
call run-d3d12-2.cmd || exit /b %errorlevel%
call run-d3d12-3.cmd || exit /b %errorlevel%
call run-d3d12-4.cmd || exit /b %errorlevel%
echo D3D12 2/3/4-buffer matrix passed.
''', encoding='utf-8')

(output / 'README.txt').write_text('''Dora + Godot D3D12 physical Windows acceptance bundle

Scope
-----
This bundle contains an x64 Dora host linked only with the D3D12 Godot bridge,
an x64 Godot 4.6 D3D12 runtime, the test project, and strict image/GPU-accounting
verification. It does not contain the WGL bridge and does not claim GPU acceptance
until a run on native x64 Windows with a Shader Model 6 capable physical adapter passes.

Prerequisites
-------------
1. Native x64 Windows 10/11 (not Windows-on-ARM x64 translation).
2. A physical D3D12 GPU with Shader Model 6 support and current driver.
3. Python 3 available through the `py` launcher; internet access is needed only once
   by setup-python.cmd to install the pinned Pillow verifier dependency.

Run
---
1. Extract the ZIP to a writable local NTFS directory.
2. Run setup-python.cmd.
3. Run run-d3d12-2.cmd first. Do not continue if it fails.
4. After the 2-buffer report passes, run run-d3d12-matrix.cmd for 2/3/4 buffers.

Evidence is written under results/. Preserve that whole directory. A valid result
must report passed=true, produced==completed, gpu_errors=0, gpu_pending=0, visible
animation changes, stable paused frames, resize success, and clean process exit.
Do not set DORA_GODOT_D3D12_WARP: this package is for physical-hardware acceptance.
''', encoding='utf-8')

scope_sources = [
    'Projects/xmake/engine.lua',
    'Source/Godot/GodotBridge.h',
    'Source/Godot/GodotBridgeD3D12.h',
    'Source/Godot/GodotNode.cpp',
    'Source/Godot/GodotRuntimeD3D12.cpp',
    'Source/3rdParty/bgfx/include/bgfx/platform.h',
    'Source/3rdParty/bgfx/src/bgfx.cpp',
    'Source/3rdParty/bgfx/src/bgfx_p.h',
    'Source/3rdParty/bgfx/src/renderer_d3d12.cpp',
    'Source/3rdParty/bgfx/xmake.lua',
    'Tools/Godot/module/SCsub',
    'Tools/Godot/module/register_types_d3d12.cpp',
    'Tools/Godot/package_runtime.py',
    'Tools/Godot/package_windows_d3d12_test.py',
    'Tools/Godot/prepare.py',
    'Tools/Godot/test_windows.py',
    'Tools/Godot/tests/runtime_abi.py',
    'Tools/Godot/tests/verify_macos.py',
    'Tools/Godot/verify_package.py',
]

def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

manifest = {
    'package_format': 'dora-godot-d3d12-physical-test',
    'package_version': 1,
    'status': 'compile_and_package_only; physical_GPU_acceptance_pending',
    'architecture': 'x86_64',
    'host_backend': 'd3d12-only',
    'runtime_backend': runtime_manifest['graphics_backend'],
    'host_sha256': digest(output / 'build/godot-runtime/dora/Dora.exe'),
    'runtime_sha256': digest(output / 'runtime/dora_godot.dll'),
    'runtime_manifest_sha256': runtime_report['manifest_sha256'],
    'source_scope': {name: digest(root / name) for name in scope_sources},
}
manifest['artifacts'] = {
    file.relative_to(output).as_posix(): digest(file)
    for file in sorted(output.rglob('*'))
    if file.is_file() and file.name != 'test-package.json'
}
(output / 'test-package.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
archive = Path(shutil.make_archive(str(output), 'zip', output.parent, output.name))
summary = {
    'passed': True,
    'scope': 'Static structure, x64 PE identity, sealed D3D12 runtime, artifact inventory and ZIP generation; no GPU execution',
    'directory': str(output),
    'archive': str(archive),
    'archive_sha256': digest(archive),
    'files': len(manifest['artifacts']) + 1,
    'bytes': sum(path.stat().st_size for path in output.rglob('*') if path.is_file()),
    'physical_gpu_tested': False,
}
(output.parent / (output.name + '-verification.json')).write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
print(json.dumps(summary, indent=2))
