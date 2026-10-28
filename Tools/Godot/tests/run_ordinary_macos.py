#!/usr/bin/env python3
"""Stage an ordinary macOS app and verify bundled-runtime and missing-library behavior.

This runs the real Lua startup and public API without native test entrypoints.
It does not establish installer, update, distribution signing or GPU-loss recovery.
"""
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
from PIL import Image, ImageChops

root = Path(__file__).resolve().parents[3]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--app', type=Path, required=True)
parser.add_argument('--library', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--wait-pid', type=int, help='Wait for this currently live Dora process before taking the GUI lock')
args = parser.parse_args()
assert sys.platform == 'darwin'
out = args.output.resolve()
assert not out.exists(), 'Use a fresh output directory to preserve prior evidence'
out.mkdir(parents=True)
app = args.app.resolve()
binary = app / 'Contents/MacOS/Dora'
library = args.library.resolve()
assert binary.is_file() and library.is_file()
symbols = subprocess.check_output(['nm', '-gU', str(binary)], text=True)
assert '_dora_godot_node_test_main' not in symbols, 'Use an ordinary host, not the opt-in test application'
subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)

def digest(path):
    with path.open('rb') as file:
        return hashlib.file_digest(file, 'sha256').hexdigest()

def identity(pid):
    result = subprocess.run(['ps', '-p', str(pid), '-o', 'lstart=,comm='], capture_output=True, text=True)
    return result.stdout.strip() if result.returncode == 0 else None

if args.wait_pid:
    initial = identity(args.wait_pid)
    assert initial and initial.endswith('/Contents/MacOS/Dora'), 'Wait PID must currently identify a live Dora application'
    print('Waiting for existing Dora process:', args.wait_pid, flush=True)
    started = time.monotonic()
    while identity(args.wait_pid) == initial:
        assert time.monotonic() - started < 7200, 'Existing Dora process did not exit within the wait limit'
        time.sleep(5)

staged = out / 'Dora.app'
shutil.copytree(app, staged)
resources = staged / 'Contents/Resources'
bundled = resources / 'libdora_godot.dylib'
shutil.copy2(library, bundled)
project = root / 'Tools/Godot/tests/project'
(project / '.godot').mkdir(exist_ok=True)
(project / '.godot/global_script_class_cache.cfg').write_text('list=[]\n')
template = Path(__file__).with_name('ordinary_macos.lua').read_text()
artifacts = {'host_sha256': digest(binary), 'runtime_sha256': digest(library),
             'fixture_sha256': digest(Path(__file__).with_name('ordinary_macos.lua'))}
(out / 'artifacts.json').write_text(json.dumps(artifacts, indent=2) + '\n')
cases = []
try:
    for missing in (False, True):
        case = out / ('missing-library' if missing else 'bundled-runtime')
        case.mkdir()
        if missing:
            bundled.unlink()
        source = template.replace('@OUTPUT@', json.dumps(str(case))).replace('@PROJECT@', json.dumps(str(project))).replace('@MISSING@', 'true' if missing else 'false')
        (resources / 'Script/init.lua').write_text(source)
        subprocess.run(['codesign', '--force', '--deep', '--timestamp=none', '--sign', '-', str(staged)], check=True, capture_output=True)
        subprocess.run(['codesign', '--verify', '--deep', '--strict', str(staged)], check=True, capture_output=True)
        executed_host = staged / 'Contents/MacOS/Dora'
        executed = {'host_sha256': digest(executed_host),
                    'runtime_sha256': None if missing else digest(bundled),
                    'startup_sha256': digest(resources / 'Script/init.lua')}
        (case / 'artifacts.json').write_text(json.dumps(executed, indent=2) + '\n')
        env = os.environ.copy()
        for key in list(env):
            if key.startswith('DORA_GODOT_') or key.startswith('DORA_BUILD_'):
                env.pop(key)
        env['MTL_DEBUG_LAYER'] = '1'
        started = time.monotonic()
        with (case / 'run.log').open('w') as log:
            subprocess.run([str(staged / 'Contents/MacOS/Dora')], cwd=root, env=env,
                           stdout=log, stderr=subprocess.STDOUT, check=True, timeout=60)
        log = (case / 'run.log').read_text()
        assert 'GODOT_ORDINARY complete=1' in log, log[-2000:]
        assert 'GODOT_NODE_TEST' not in log
        assert 'BGFX LEAK:' not in log and 'C++ objects leaks' not in log
        assert ('Godot Engine v' in log) != missing
        expected = 'missing_library_rejected=1' if missing else 'running=1'
        assert 'GODOT_ORDINARY ' + expected in log
        images = [Image.open(case / f'frame-{n}.png').convert('RGB') for n in (1, 2)]
        assert images[0].size == images[1].size
        centers = []
        for image in images:
            green = [(x, y) for y in range(image.height) for x in range(image.width)
                     if (lambda rgb: rgb[1] > 220 and rgb[0] < 30 and rgb[2] < 30)(image.getpixel((x, y))) ]
            assert len(green) > 500, 'Ordinary Dora green content missing'
            centers.append(sum(x for x, _ in green) / len(green))
        assert centers[1] - centers[0] > 100, centers
        changed = sum(max(pixel) > 20 for pixel in ImageChops.difference(*images).getdata())
        assert changed > 1000
        if not missing:
            close = re.findall(r'GodotRuntime client closed: produced=(\d+), completed=(\d+), gpuErrors=(\d+)', log)
            assert len(close) == 1 and all(int(p) == int(c) and int(p) > 0 and int(e) == 0 for p, c, e in close), 'Node close must drain before ordinary app exit'
            w, h = images[0].size
            box = (round(w*.4), round(h*.3), round(w*.6), round(h*.7))
            crops = [image.crop(box) for image in images]
            assert all(sum(g > 70 and b > 70 and r < g*.65 for r, g, b in crop.getdata()) > 100 for crop in crops), 'Godot cube pixels missing'
            assert sum(max(pixel) > 8 for pixel in ImageChops.difference(*crops).getdata()) > 100, 'Godot cube did not animate'
            assert digest(bundled) == executed['runtime_sha256']
        else:
            assert not bundled.exists(), 'Missing-library case accidentally included the runtime'
        assert digest(executed_host) == executed['host_sha256']
        assert digest(binary) == artifacts['host_sha256'] and digest(library) == artifacts['runtime_sha256']
        cases.append({'case': case.name, 'passed': True, 'runtime_seconds': time.monotonic() - started,
                      'captures': 2, 'ordinary_green_centers': centers, 'changed_pixels': changed,
                      'godot_started': not missing, 'executed_artifacts': executed,
                      'runtime_lookup': 'default bundled resource path; no override'})
    (out / 'verification.json').write_text(json.dumps({'passed': True, 'scope': __doc__,
        'ordinary_host_without_test_entry': True, 'artifacts': artifacts, 'cases': cases}, indent=2) + '\n')
except BaseException as error:
    (out / 'verification.json').unlink(missing_ok=True)
    (out / 'failure.json').write_text(json.dumps({'passed': False, 'error': str(error), 'type': type(error).__name__}, indent=2) + '\n')
    raise
