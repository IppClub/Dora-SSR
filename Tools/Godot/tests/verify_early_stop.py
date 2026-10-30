"""Strict diagnostics for ordinary-host shutdown before Godot node readiness."""
import re


def verify(log, *, metal=False):
    assert 'DORA_EARLY_STOP accepted=1 running=0' in log
    if metal:
        assert 'Metal API Validation Enabled' in log
    assert not any(x in log for x in ('[error]', '[critical]', 'ERROR:', 'BGFX LEAK:', 'C++ objects leaks', 'Metal Validation Error', 'MTLCommandBufferError'))
    destroyed = [name.strip() for group in re.findall(r'destroy: ([^\r\n]+)\.', log) for name in group.split(',')]
    # Life may batch Logger with the remaining singletons on Windows. Require
    # the exact singleton and its order, rather than a standalone log line.
    for name in ('Director', 'BGFXDora', 'Logger'):
        assert destroyed.count(name) == 1, ('Missing or duplicate engine cleanup', name, destroyed)
    assert destroyed.index('Director') < destroyed.index('BGFXDora') < destroyed.index('Logger')
    assert log.index('DORA_EARLY_STOP') < log.index('destroy: ')
    clients = re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)', log)
    readers = re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)', log)
    audio = re.findall(r'GodotAudio drained: produced=(\d+), consumed=(\d+), nonzeroProduced=(\d+), nonzeroConsumed=(\d+), underrunFrames=(\d+)', log)
    booted = 'Godot Engine v' in log
    if booted:
        assert len(clients) == len(readers) == len(audio) == 1, (clients, readers, audio)
        produced, completed, errors = map(int, clients[0])
        assert produced == completed and errors == 0
        buffers, frames, waits, signals, pending, completed, errors = map(int, readers[0])
        assert buffers == 3 and frames == completed and pending == errors == 0
        assert 0 <= waits <= signals and signals == frames * buffers
        produced, consumed, nonzero, played, underruns = map(int, audio[0])
        assert produced >= consumed >= 0 and underruns == 0
        assert 0 <= nonzero <= produced * 2 and 0 <= played <= consumed * 2
    else:
        assert not clients and not readers and not audio
    return {'godot_booted': booted, 'gpu_clients': clients, 'gpu_readers': readers, 'audio': audio}
