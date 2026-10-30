#!/usr/bin/env python3
"""Check failed standalone GPU verification cannot leave a stale PASS report.

Uses intentionally incomplete evidence, without launching either engine.
This verifies report failure handling, not GPU rendering.
"""
import json
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[3]
verifiers = [
    (root/'Tools/Godot/tests/verify_macos.py', '--results'),
    (root/'Tools/Godot/tests/verify_timing.py', '--results'),
    (root/'Tools/LibGodotMetalProbe/verify_outputs.py', None),
]
checks = 0
with tempfile.TemporaryDirectory(prefix='dora-godot-verifier-') as temporary:
    evidence = Path(temporary)
    report = evidence/'verification.json'
    for verifier, option in verifiers:
        for log in (None, 'ERROR: injected runtime failure\n'):
            report.write_text(json.dumps({'passed': True})+'\n')
            logfile = evidence/'run.log'
            logfile.unlink(missing_ok=True)
            if log is not None:
                logfile.write_text(log)
            command = [sys.executable, str(verifier)]
            if option:
                command.append(option)
            command.append(str(evidence))
            result = subprocess.run(command, capture_output=True, text=True, timeout=30)
            assert result.returncode != 0, (verifier, 'Accepted invalid evidence')
            assert not report.exists(), (verifier, 'Retained stale PASS report', result.stderr)
            checks += 1
print(f'Verifier failure handling: PASS; {checks} cases; GPU not tested')
