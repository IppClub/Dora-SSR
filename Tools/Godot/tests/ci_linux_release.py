#!/usr/bin/env python3
"""Build an optimized ordinary Linux host and exercise native shutdown boundaries.

Uses an existing, integrity-checked LibGodot package. SDL dummy audio and the
reported EGL renderer establish API behavior, not physical audio/GPU acceptance.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import subprocess
import sys
import time

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--source-root', type=Path, default=Path(__file__).resolve().parents[3])
p.add_argument('--library', type=Path)
p.add_argument('--output', type=Path)
p.add_argument('--jobs', type=int, default=2)
p.add_argument('--prebuilt-receipt', type=Path, help='Reproduce using an unchanged binary, compile-command receipt and adjacent full source-audit.json')
a = p.parse_args()
assert sys.platform.startswith('linux') and a.jobs > 0
root = a.source_root.resolve()
out = (a.output or root / 'build/godot-runtime/ci-linux-release').resolve()
assert not out.exists(), 'Use a fresh output directory'
out.mkdir(parents=True)
arch = {'aarch64': 'arm64', 'x86_64': 'x86_64'}.get(platform.machine())
assert arch, 'Unsupported CPU'
binary = root / f'build/linux/{arch}/release/Dora'
library = (a.library or root / 'build/godot-linux/package/libdora_godot.so').resolve()
env = {k: v for k, v in os.environ.items() if not k.startswith(('DORA_GODOT_', 'DORA_BUILD_'))}
env['SDL_AUDIODRIVER'] = 'dummy'
env.setdefault('LIBGL_ALWAYS_SOFTWARE', '1')
state = {'phase': 'preflight'}


def digest(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def run(command, name, timeout=7200):
    state.update(phase=name, command=command)
    state.pop('exit_code', None)
    (out / 'progress.json').write_text(json.dumps(state, indent=2) + '\n')
    with (out / (name + '.log')).open('w') as log:
        process = subprocess.Popen(command, cwd=root, env=env, stdout=log, stderr=subprocess.STDOUT)
        state['pid'] = process.pid
        (out / 'progress.json').write_text(json.dumps(state, indent=2) + '\n')
        result = process.wait(timeout=timeout)
    state['exit_code'] = result
    (out / 'progress.json').write_text(json.dumps(state, indent=2) + '\n')
    assert result == 0, (name, result)


try:
    started = time.monotonic()
    run([sys.executable, 'Tools/Godot/verify_package.py', str(library.parent), '--output', str(out / 'package-integrity.json')], 'package-integrity')
    runtime_sha = digest(library)
    inputs = ('Tools/Godot/tests/ci_linux_release.py', 'Source/Basic/Application.cpp', 'Source/Godot/GodotNode.cpp', 'Source/Godot/GodotNode.h', 'Projects/xmake/engine.lua',
              'Tools/Godot/tests/run_active_stop_linux.py', 'Tools/Godot/tests/verify_active_stop_linux.py',
              'Tools/Godot/tests/web/active_stop.lua', 'Tools/Godot/tests/web/active_stop_images.py',
              'Tools/Godot/tests/run_early_stop_linux.py', 'Tools/Godot/tests/verify_early_stop.py',
              'Tools/Godot/tests/run_ordinary_linux.py', 'Tools/Godot/tests/ordinary_native.lua', 'Tools/Godot/tests/with_weston.py')
    sources = {name: digest(root / name) for name in inputs}
    if a.prebuilt_receipt:
        receipt = json.loads(a.prebuilt_receipt.read_text())
        audit = json.loads(a.prebuilt_receipt.with_name('source-audit.json').read_text())
        assert receipt['passed'] and audit['passed']
        assert all(digest(root / name) == value for name, value in audit['files_sha256'].items())
        assert all(os.readlink(root / name) == value for name, value in audit['symlinks'].items())
        assert receipt['artifacts'][str(binary)] == digest(binary)
        assert receipt['artifacts'][str(library)] == runtime_sha
        commands = receipt['application_compile_commands']
        receipt_sha = digest(a.prebuilt_receipt)
    else:
        run(['xmake', 'f', '-P', str(root), '-p', 'linux', '-a', arch, '-m', 'release', '-y'], 'configure')
        # Ask for this unit again even with existing outputs so its optimization
        # and NDEBUG arguments are visible. File contents stay unchanged; xmake
        # may still reuse its content-addressed compiler cache.
        os.utime(root / 'Source/Basic/Application.cpp', None)
        run(['xmake', 'build', '-P', str(root), '-v', '-j' + str(a.jobs), 'Dora'], 'build')
        commands = [line for line in (out / 'build.log').read_text().splitlines() if 'Source/Basic/Application.cpp' in line and '-c ' in line]
        receipt_sha = None
    assert commands and all('-DNDEBUG' in line and re.search(r' -O(?:[123s]|fast)\b', line) for line in commands), commands
    assert digest(library) == runtime_sha
    artifacts = {str(path): digest(path) for path in (binary, library)}
    (out / 'artifacts.json').write_text(json.dumps(artifacts, indent=2) + '\n')
    cases = []
    for buffers in (2, 3, 4):
        case = out / f'case-{buffers}'
        run([sys.executable, 'Tools/Godot/tests/with_weston.py', '--logs', str(out / f'weston-{buffers}'), '--',
             sys.executable, 'Tools/Godot/tests/run_active_stop_linux.py', '--binary', str(binary), '--library', str(library),
             '--output', str(case), '--buffers', str(buffers)], f'case-{buffers}', 600)
        data = json.loads((case / 'verification.json').read_text())
        assert data['passed']
        cases.append({'buffers': buffers, 'report': str(case / 'verification.json'), 'renderer': data['godot_renderer']})
        assert all(digest(Path(name)) == value for name, value in artifacts.items())
    for name, script in (('early-stop', 'run_early_stop_linux.py'), ('ordinary', 'run_ordinary_linux.py')):
        case = out / name
        run([sys.executable, 'Tools/Godot/tests/with_weston.py', '--logs', str(out / ('weston-' + name)), '--',
             sys.executable, 'Tools/Godot/tests/' + script, '--binary', str(binary), '--library', str(library), '--output', str(case)], name, 600)
        assert json.loads((case / 'verification.json').read_text())['passed']
        assert all(digest(Path(path)) == value for path, value in artifacts.items())
    assert all(digest(root / name) == value for name, value in sources.items())
    report = {'passed': True, 'scope': __doc__, 'runtime_seconds': time.monotonic() - started, 'artifacts': artifacts,
              'source_hashes': sources, 'runtime_rebuilt': False, 'build_skipped': bool(a.prebuilt_receipt),
              'prebuilt_receipt_sha256': receipt_sha, 'application_compile_commands': commands, 'cases': cases,
              'early_stop_report': str(out / 'early-stop/verification.json'), 'ordinary_report': str(out / 'ordinary/verification.json'),
              'github': {key: os.environ.get(key) for key in ('GITHUB_SHA', 'GITHUB_RUN_ID')}}
    (out / 'verification.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Ordinary optimized Linux Release shutdown regressions: PASS')
except BaseException as error:
    (out / 'verification.json').unlink(missing_ok=True)
    (out / 'failure.json').write_text(json.dumps({'passed': False, 'phase': state['phase'], 'error': repr(error)}, indent=2) + '\n')
    raise
