#!/usr/bin/env python3
"""Audit a normal Release APK and replay its collected public-Lua acceptance.

The runner must supply per-process logcat and the app's godot-release files.
Local development signing and emulator results do not prove production signing
or physical Android coverage. APK source provenance is recorded separately.
"""
import argparse, hashlib, json, re, subprocess, sys, zipfile
from pathlib import Path
from PIL import Image, ImageChops
root = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(root / 'Tools/Godot'))
from verify_package import verify as verify_runtime

def sha(data): return hashlib.sha256(data).hexdigest()
def pixels(im): return im.get_flattened_data() if hasattr(im, 'get_flattened_data') else im.getdata()
def changed(a, b): return sum(max(p) > 8 for p in pixels(ImageChops.difference(a, b)))

def audit_apk(apk, runtime, aapt, missing):
    verify_runtime(runtime)
    metadata = json.loads((runtime / 'manifest.json').read_text())
    badging = subprocess.check_output([str(aapt), 'dump', 'badging', str(apk)], text=True)
    assert "package: name='org.ippclub.dorassr'" in badging, 'Expected ordinary Dora application ID'
    assert 'application-debuggable' not in badging, 'Release APK must not be debuggable'
    with zipfile.ZipFile(apk) as archive:
        names = archive.namelist()
        assert len(names) == len(set(names)), 'Ambiguous duplicate ZIP entries'
        host = archive.read('lib/arm64-v8a/libmain.so')
        for marker in (b'dora_godot_node_test_main', b'GODOT_CAPABILITY_QUERY matches=', b'GODOT_NODE_TEST complete='):
            assert marker not in host, 'Native test entry found in ordinary host'
        library = 'lib/arm64-v8a/libgodot_android.so'
        if missing:
            assert library not in names
        else:
            assert sha(archive.read(library)) == metadata['library_sha256']
        notices = {}
        for relative in metadata['licenses']:
            name = 'assets/GodotRuntimeNotices/' + relative
            notices[name] = sha(archive.read(name))
            assert notices[name] == metadata['artifacts'][relative], name
        fixture = archive.read('assets/Script/init.lua')
        assert fixture == Path(__file__).with_name('ordinary_release.lua').read_bytes(), 'QA startup source differs'
        for name in ('main.gd', 'main.tscn', 'project.godot'):
            assert 'assets/GodotProject/' + name in names
        assert 'assets/ffi-trap.wasm' in names
    return {'apk_sha256': sha(apk.read_bytes()), 'host_sha256': sha(host), 'startup_sha256': sha(fixture),
            'runtime_sha256': None if missing else metadata['library_sha256'], 'notices_sha256': notices,
            'ordinary_application_id': True, 'debuggable': False, 'native_test_entry': False}

def verify_case(case, buffers, missing):
    log = (case / 'run.log').read_text(errors='replace')
    result = json.loads((case / 'files/result.json').read_text())
    assert result['complete'] is True and result['missing'] is missing
    assert 'DORA_RELEASE complete=1 missing=' + str(int(missing)) in log
    assert not re.search(r'FATAL EXCEPTION|Fatal signal|BGFX LEAK:|C\+\+ objects leaks|\[critical\]', log)
    warnings = [l for l in log.splitlines() if 'WARNING:' in l or '[warning]' in l]
    # The emulator exposes an unmapped synthetic controller. SwiftShader can
    # reject cached program binaries; Godot explicitly recompiles from source.
    # Keep both diagnostics visible and reject every other warning.
    for line in warnings:
        assert (line.endswith("[warning] failed to open a new controller! Couldn't find mapping for device (0)")
                or line == 'WARNING: Failed to load cached shader, recompiling.'), line
    errors = [l for l in log.splitlines() if '[error]' in l or 'ERROR:' in l]
    if missing:
        assert len(errors) == 1 and 'libgodot_android.so' in errors[0], errors
        assert 'DORA_RELEASE missing_library_rejected=1' in log and 'Godot Engine v' not in log
        names = ['fallback-a', 'fallback-b']
    else:
        assert len(errors) == 1 and 'unreachable' in errors[0], errors
        assert 'DORA_RELEASE running=1' in log and 'DORA_RELEASE ffi_trap_recovered=1' in log
        assert 'Godot Engine v4.6' in log and 'GODOT_RELEASE_AUDIO' in log
        assert result['buffers'] == buffers
        names = ['animated-a', 'animated-b', 'paused-a', 'paused-b', 'resumed', 'input', 'removed']
    assert result['captures'] == len(names)
    images = {n: Image.open(case / 'files' / (n + '.png')).convert('RGB') for n in names}
    assert len({im.size for im in images.values()}) == 1
    ordinary = []
    for image in images.values():
        xs = [i % image.width for i, (r, g, b) in enumerate(pixels(image)) if r > 200 and g < 60 and b > 200]
        assert len(xs) > 100, 'Independent Dora node missing'
        ordinary.append(sum(xs) / len(xs))
    assert max(ordinary) - min(ordinary) > 25, 'Dora animation did not advance'
    clients = re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)', log)
    readers = re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)', log)
    metrics = {}
    if missing:
        assert not clients and not readers
    else:
        match = re.search(r'DORA_RELEASE view=(\d+)x(\d+) scale=([\d.]+) buffers=(\d+) missing=0', log)
        assert match and int(match[4]) == buffers
        vw, vh, scale = int(match[1]), int(match[2]), float(match[3])
        w, h = images['animated-a'].size
        assert abs(w / vw - h / vh) < .02
        sx, sy = w / vw, h / vh
        box = (round(w / 2 - 320 * scale * sx), round(h / 2 - 180 * scale * sy),
               round(w / 2 + 320 * scale * sx), round(h / 2 + 180 * scale * sy))
        crops = {n: im.crop(box) for n, im in images.items()}
        green = lambda im: sum(g > 120 and g > r * 2 and b > r * 2 for r, g, b in pixels(im))
        assert green(crops['animated-a']) > 100 and green(crops['animated-b']) > 100
        motion = changed(crops['animated-a'], crops['animated-b'])
        resumed = changed(crops['paused-b'], crops['resumed'])
        paused = changed(crops['paused-a'], crops['paused-b'])
        assert motion > 200 and resumed > 200 and paused == 0, (motion, resumed, paused)
        orange = sum(r > 150 and r > g * 1.3 and g > b * 1.3 for r, g, b in pixels(crops['input']))
        assert orange > 100 and green(crops['removed']) == 0
        assert len(clients) == len(readers) == 1
        for p, c, e in clients: assert int(p) > 0 and p == c and e == '0'
        for b, f, waits, signals, pending, c, e in readers:
            assert int(b) == buffers and int(f) > 0 and f == c and pending == e == '0'
            assert 0 < int(waits) <= int(signals) and int(signals) == int(f) * buffers
        pcm = re.findall(r'GodotAudio drained: produced=(\d+), consumed=(\d+), nonzeroProduced=(\d+), nonzeroConsumed=(\d+), underrunFrames=(\d+)', log)
        assert len(pcm) == 1
        produced, consumed, nzp, nzc, underruns = map(int, pcm[0])
        assert produced >= consumed > 48000 and nzp > 48000 and nzc > 48000 and underruns == 0, pcm
        metrics = {'godot_crop': box, 'animation_changed_pixels': motion, 'resume_changed_pixels': resumed,
                   'paused_changed_pixels': paused, 'pointer_orange_pixels': orange, 'pcm': pcm}
    life = [n.strip() for group in re.findall(r'destroy: ([^\r\n]+)\.', log) for n in group.split(',')]
    for n in ('Director', 'BGFXDora', 'Logger'): assert life.count(n) == 1, life
    assert life.index('Director') < life.index('BGFXDora') < life.index('Logger')
    return {'passed': True, 'missing': missing, 'buffers': buffers, 'captures': len(names), 'metrics': metrics,
            'gpu_clients': clients, 'gpu_readers': readers, 'ordinary_centers': ordinary,
            'allowed_environment_warnings': warnings,
            'log_sha256': sha((case / 'run.log').read_bytes()),
            'images_sha256': {n: sha((case / 'files' / (n + '.png')).read_bytes()) for n in names}}

def main():
    p = argparse.ArgumentParser(description=__doc__)
    for n in ('apk', 'runtime-package', 'aapt', 'case'): p.add_argument('--' + n, type=Path, required=True)
    p.add_argument('--buffers', type=int, choices=(2, 3, 4), default=3)
    p.add_argument('--missing', action='store_true'); a = p.parse_args()
    report = a.case / 'verification.json'; report.unlink(missing_ok=True)
    artifact = audit_apk(a.apk, a.runtime_package, a.aapt, a.missing)
    result = verify_case(a.case, a.buffers, a.missing)
    result.update(artifacts=artifact, scope=__doc__)
    report.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))
if __name__ == '__main__': main()
