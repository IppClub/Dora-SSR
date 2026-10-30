#!/usr/bin/env python3
"""Real invalid-shader rejection, immediate teardown or same-process recovery."""
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

root = Path(__file__).resolve().parents[3]
parser = argparse.ArgumentParser(description=__doc__)
for name in ('binary', 'library', 'output'):
    parser.add_argument('--' + name, type=Path, required=True)
parser.add_argument('--project', type=Path, default=root / 'Tools/Godot/tests/project')
parser.add_argument('--mode', choices=('exit', 'recover'), required=True)
args = parser.parse_args()
platform = {'darwin': 'macOS Metal', 'linux': 'Linux EGL', 'win32': 'Windows WGL'}[sys.platform]
binary, library, project, out = [path.resolve() for path in (args.binary, args.library, args.project, args.output)]
assert binary.is_file() and library.is_file() and (project / 'project.godot').is_file()
assert b'dora_godot_node_test_main' in binary.read_bytes(), 'Use an opt-in native test host'
assert not out.exists(), 'Use fresh evidence directories'
out.mkdir(parents=True)
report = out / 'verification.json'

def digest(path):
    with path.open('rb') as file:
        return hashlib.file_digest(file, 'sha256').hexdigest()

artifacts = {str(path): digest(path) for path in (binary, library)}
fixtures = {str(path): digest(path) for path in (Path(__file__), Path(__file__).with_name('verify_macos.py'))}
(out / 'artifacts.json').write_text(json.dumps(artifacts, indent=2) + '\n')
try:
    if sys.platform == 'darwin':
        subprocess.run(['codesign', '--verify', '--deep', '--strict', str(binary.parents[2])], check=True, capture_output=True)
    # Match the existing native fixtures: do not treat the repository root as
    # an asset tree or discover an unrelated platform's init.lua recursively.
    assets = out / 'test-assets'
    shutil.copytree(root / 'Assets', assets)
    startup = assets / 'Script/init.lua'
    startup.write_text('return true\n')
    asset_inputs = {path.relative_to(assets).as_posix(): digest(path)
                    for path in sorted(assets.rglob('*')) if path.is_file()}
    (out / 'asset-inputs.json').write_text(json.dumps(asset_inputs, indent=2) + '\n')
    env = {key: value for key, value in os.environ.items()
           if not key.startswith(('DORA_GODOT_TEST_', 'DORA_GODOT_BINDING_'))}
    env.update(DORA_GODOT_LIBRARY=str(library), DORA_GODOT_TEST_PROJECT=str(project),
               DORA_GODOT_TEST_OUTPUT=str(out), DORA_GODOT_TEST_SHADER_FAILURE='1',
               DORA_GODOT_TEST_INIT_FAILURE_MODE=args.mode, DORA_GODOT_TEST_BUFFERS='3',
               DORA_GODOT_WINDOWS_GL='1', MTL_DEBUG_LAYER='1')
    if sys.platform != 'darwin':
        env.setdefault('SDL_AUDIODRIVER', 'dummy')
    flags = ('resize', 'cancel-resize', 'aliases', 'audio', 'audio-stall', 'reservation', 'controller')
    for flag in flags:
        env['DORA_GODOT_TEST_' + flag.upper().replace('-', '_')] = '1' if args.mode == 'recover' else '0'
    (project / '.godot').mkdir(exist_ok=True)
    (project / '.godot/global_script_class_cache.cfg').write_text('list=[]\n')
    started = time.monotonic()
    with (out / 'run.log').open('w') as log:
        process = subprocess.run([str(binary), '--asset', str(assets)], cwd=assets, env=env, stdout=log,
                                 stderr=subprocess.STDOUT, timeout=180)
    duration = time.monotonic() - started
    assert process.returncode == 0, ('Native host did not exit normally', process.returncode)
    assert all(digest(Path(path)) == sha for path, sha in artifacts.items()), 'Artifacts changed'
    assert all(digest(Path(path)) == sha for path, sha in fixtures.items()), 'Test inputs changed'
    assert digest(startup) == asset_inputs['Script/init.lua'], 'Fixture startup changed'
    raw = (out / 'run.log').read_text(encoding='utf-8', errors='replace')
    assert raw.count('GODOT_INIT_FAILURE begin=1') == 1
    assert raw.count('GODOT_INIT_FAILURE rejected=1') == 1
    expected = "GodotNode: alpha shader compilation failed: Shader entry point 'void main()' is not found."
    assert raw.count(expected) == 1
    assert raw.count('GodotNode Lua constructor failed') == 1
    assert raw.count('GodotNode:') == 1
    errors = [line for line in raw.splitlines() if re.search(r'ERROR:|WARNING:|\[(?:error|critical)\]', line)]
    assert len(errors) == 2 and any(expected in line for line in errors) \
        and any('GodotNode Lua constructor failed' in line for line in errors), 'Unexpected diagnostics outside the two injected errors'
    assert not re.search(r'BGFX LEAK:|C\+\+ objects leaks|Metal Validation Error|GODOT_NODE_TEST FAIL', raw)
    # This early-exit case must destroy GPU effects while their device lives,
    # without relying on any successful frame to initialize RendererManager.
    destroyed = re.findall(r'destroy: ([^\n]+)', raw)
    names = [name.strip().rstrip('.') for row in destroyed for name in row.split(',')]
    assert names.count('SpriteRenderer') == names.count('BGFXDora') == 1
    assert names.index('SpriteRenderer') < names.index('BGFXDora'), 'GPU effect destroyed after its device'
    recovered = None
    if args.mode == 'exit':
        assert 'GODOT_NODE_SCENE' not in raw and 'Godot Engine v' not in raw
        assert not list(out.glob('*.png')), 'Immediate failure mode rendered unexpectedly'
        assert not re.search(r'GodotRuntime (?:client closed|shutdown):', raw)
    else:
        marker = 'GODOT_INIT_FAILURE recovery_begin=1'
        assert raw.count(marker) == 1
        begin, end = raw.index('GODOT_INIT_FAILURE begin=1'), raw.index(marker)
        fault = raw[begin:end]
        assert expected in fault and 'GodotNode Lua constructor failed' in fault
        assert 'Godot Engine v' not in fault and 'GODOT_NODE_SCENE' not in fault
        assert fault.count('GodotNode:') == 1
        phase = out / 'recovered'
        phase.mkdir()
        for image in out.glob('*.png'):
            shutil.copy2(image, phase / image.name)
        # Preserve raw run.log. Only the separately delimited expected fault
        # is excluded from the ordinary verifier's recovery-phase input.
        (phase / 'run.log').write_text(raw[:begin] + raw[end:])
        subprocess.run([sys.executable, str(Path(__file__).with_name('verify_macos.py')),
                        '--results', str(phase), '--platform', platform,
                        *['--' + flag for flag in flags]], check=True)
        recovered = json.loads((phase / 'verification.json').read_text())
        assert recovered['passed'] and recovered['frames'] == 1000
    result = {'passed': True, 'platform': platform, 'mode': args.mode,
              'scope': 'Real compiler rejection then normal teardown before first frame' if args.mode == 'exit'
                       else 'Real compiler rejection then same-process full native GPU regression',
              'runtime_seconds': duration, 'native_exit_code': process.returncode,
              'captures': len(list(out.glob('*.png'))),
              'sprite_destroyed_before_bgfx': True, 'raw_log_sha256': digest(out / 'run.log'),
              'artifacts': artifacts, 'fixtures': fixtures, 'asset_path': str(assets),
              'asset_inventory_sha256': digest(out / 'asset-inputs.json'), 'recovery': recovered}
    report.write_text(json.dumps(result, indent=2) + '\n')
    print('Invalid-shader lifecycle acceptance: PASS (' + args.mode + ')', flush=True)
except BaseException as error:
    report.unlink(missing_ok=True)
    (out / 'failure.json').write_text(json.dumps({'passed': False, 'type': type(error).__name__,
                                                'error': str(error)}, indent=2) + '\n')
    raise
