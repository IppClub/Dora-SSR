#!/usr/bin/env python3
"""Stop an ordinary native host immediately after accepting a Godot session."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
from verify_early_stop import verify

root = Path(__file__).resolve().parents[3]
p = argparse.ArgumentParser(description=__doc__)
for name in ('app', 'library', 'output'):
    p.add_argument('--' + name, type=Path, required=True)
a = p.parse_args()
assert sys.platform == 'darwin'
out = a.output.resolve()
assert not out.exists(), 'Use a fresh evidence directory'
out.mkdir(parents=True)

def digest(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()

try:
    source, library = a.app.resolve(), a.library.resolve()
    original = {str(path): digest(path) for path in (source / 'Contents/MacOS/Dora', library)}
    assert '_dora_godot_node_test_main' not in subprocess.check_output(['nm', '-gU', str(source / 'Contents/MacOS/Dora')], text=True)
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(source)], check=True, capture_output=True)
    app = out / 'Dora.app'
    shutil.copytree(source, app)
    project = out / 'project'
    shutil.copytree(root / 'Tools/Godot/tests/web/node_project', project, ignore=shutil.ignore_patterns('.godot'))
    (project / '.godot').mkdir()
    (project / '.godot/global_script_class_cache.cfg').write_text('list=[]\n')
    script = '''local D = require("Dora")
D.App.devMode = false
local node = assert(D.GodotNode(@PROJECT@, "", 640, 360, 3))
D.Director.ui:addChild(node)
assert(not node.running, "Stop before asynchronous runtime readiness")
assert(node.lastError == "", node.lastError)
print("DORA_EARLY_STOP accepted=1 running=0")
D.App:shutdown()
'''.replace('@PROJECT@', json.dumps(str(project)))
    startup = app / 'Contents/Resources/Script/init.lua'
    startup.write_text(script)
    (out / 'startup.lua').write_text(script)
    subprocess.run(['codesign', '--force', '--deep', '--timestamp=none', '--sign', '-', str(app)], check=True, capture_output=True)
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True, capture_output=True)
    binary = app / 'Contents/MacOS/Dora'
    executed = {str(path): digest(path) for path in (binary, library, startup)}
    (out / 'artifacts.json').write_text(json.dumps({'original': original, 'executed': executed}, indent=2) + '\n')
    env = {k: v for k, v in os.environ.items() if not k.startswith(('DORA_GODOT_', 'DORA_BUILD_'))}
    env.update(DORA_GODOT_LIBRARY=str(library), MTL_DEBUG_LAYER='1')
    started = time.monotonic()
    with (out / 'run.log').open('w') as log:
        process = subprocess.Popen([str(binary), '--asset', str(app / 'Contents/Resources')], cwd=root, env=env, stdout=log, stderr=subprocess.STDOUT)
        (out / 'process.json').write_text(json.dumps({'pid': process.pid, 'binary': str(binary)}, indent=2) + '\n')
        result = process.wait(timeout=60)
    raw = (out / 'run.log').read_text()
    assert result == 0, result
    diagnostics = verify(raw, metal=True)
    assert all(digest(Path(path)) == sha for path, sha in {**original, **executed}.items())
    report = {'passed': True, 'scope': 'Ordinary macOS Release host stopped immediately after session acceptance, before node readiness; actual lifecycle cleanup and no diagnostic errors. Not a frame-sharing or device-loss test.', 'native_exit_code': result, 'runtime_seconds': time.monotonic() - started, 'diagnostics': diagnostics, 'artifacts': executed, 'log_sha256': digest(out / 'run.log')}
    (out / 'verification.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Ordinary Release shutdown before Godot readiness: PASS')
except BaseException as error:
    (out / 'verification.json').unlink(missing_ok=True)
    (out / 'failure.json').write_text(json.dumps({'passed': False, 'error': repr(error)}, indent=2) + '\n')
    raise
