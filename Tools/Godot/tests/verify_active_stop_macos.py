#!/usr/bin/env python3
"""Require ordinary native host shutdown to drain a live Godot GPU/audio client."""
import argparse
import hashlib
import json
import re
from pathlib import Path
from web.active_stop_images import verify_images

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('results', type=Path)
p.add_argument('--buffers', type=int, choices=[2, 3, 4], required=True)
a = p.parse_args()
report = a.results / 'verification.json'
report.unlink(missing_ok=True)
(a.results / 'verification-failure.json').unlink(missing_ok=True)
try:
    execution = json.loads((a.results / 'execution.json').read_text())
    assert execution['passed'] and execution['native_exit_code'] == 0
    proof = execution['live_at_stop']
    assert proof['running'] and proof['frame'] >= 120
    assert proof['buffers'] == proof['aliases'] == a.buffers
    log = (a.results / 'run.log').read_text()
    assert 'Metal API Validation Enabled' in log
    assert 'DORA_NATIVE_ACTIVE_STOP_REQUESTED' in log
    assert not any(x in log for x in ('[error]', '[critical]', 'ERROR:', 'BGFX LEAK:', 'C++ objects leaks', 'Metal Validation Error', 'MTLCommandBufferError'))
    clients = re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)', log)
    assert len(clients) == 1, clients
    produced, completed, errors = map(int, clients[0])
    assert produced > 0 and produced == completed and errors == 0
    readers = re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)', log)
    assert len(readers) == 1, readers
    b, f, w, s, pending, c, e = map(int, readers[0])
    assert b == a.buffers and f > 0 and 0 < w <= s and s == f * b
    assert pending == e == 0 and c == f
    audio = re.findall(r'GodotAudio drained: produced=(\d+), consumed=(\d+), nonzeroProduced=(\d+), nonzeroConsumed=(\d+), underrunFrames=(\d+)', log)
    assert len(audio) == 1, audio
    produced, consumed, nonzero, played, underruns = map(int, audio[0])
    assert produced >= consumed > 0 and nonzero > 0 and played > 0 and underruns == 0
    tones = re.findall(r'GodotAudio tone: frames=(\d+), leftCrossings=(\d+), rightCrossings=(\d+)', log)
    assert len(tones) == 1, tones
    count, left, right = map(int, tones[0])
    assert count == 48000 and abs(left - 440) <= 2 and abs(right - 660) <= 2
    assert log.index('DORA_NATIVE_ACTIVE_STOP_REQUESTED') < log.index('GodotAudio drained:')
    stamps, images = verify_images(a.results, a.buffers)
    result = {'passed': True, 'scope': 'Ordinary macOS Release host stopped with live Godot node and all aliases; native Metal validation and GPU/PCM drain, not physical iOS or full distribution acceptance', 'buffers': a.buffers, 'live_at_stop': proof, 'gpu_clients': clients, 'gpu_readers': readers, 'audio': audio, 'tones': tones, 'stamps': stamps, 'images_sha256': images, 'execution_sha256': hashlib.sha256((a.results / 'execution.json').read_bytes()).hexdigest(), 'log_sha256': hashlib.sha256((a.results / 'run.log').read_bytes()).hexdigest()}
    report.write_text(json.dumps(result, indent=2) + '\n')
    print('Ordinary Metal host active-client shutdown: PASS')
except BaseException as error:
    (a.results / 'verification-failure.json').write_text(json.dumps({'passed': False, 'error': repr(error)}, indent=2) + '\n')
    raise
