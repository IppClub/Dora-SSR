#!/usr/bin/env python3
"""Verify runtime/GPU accounting, exact frame stamps, and animated output.
Requires Pillow. Reads only final Dora screenshots, never producer pixels.
"""
import csv
import json
from pathlib import Path
import re
import sys
from PIL import Image, ImageChops

def pixels(image):
    return image.get_flattened_data() if hasattr(image, 'get_flattened_data') else image.getdata()

root = Path(__file__).resolve().parents[2]
results = Path(sys.argv[1]) if len(sys.argv) > 1 else root / 'build/godot-metal-probe/results'
(results / 'verification.json').unlink(missing_ok=True)
log = (results / 'run.log').read_text()
for evidence in ['same_device=1', 'imported_same_texture=1', 'dynamic_gdscript=1', 'cpu_pixel_transfer=0']:
    assert evidence in log, f'Missing runtime evidence: {evidence}'
assert not re.search(r'ERROR:|GODOT_METAL_PROBE FAIL|BGFX LEAK:|WARNING:', log), 'Runtime errors/warnings in log'
match = re.search(r'GODOT_METAL_PROBE final (.+)', log)
assert match, 'Missing final GPU drain accounting'
counts = {k: int(v) for k,v in re.findall(r'(\w+)=(\d+)', match.group(1))}
assert counts['result'] == 0 and counts['gpu_errors'] == 0 and counts['tickets'] == 0
assert counts['producer_completed'] == counts['produced'] > 100
assert counts['consumer_completed'] == counts['waits'] == counts['signals'] >= 600
buffers = int(re.search(r'imported_same_texture=1 buffers=(\d+)', log).group(1))
frames = list(csv.DictReader((results / 'frames.csv').open()))
assert len(frames) == counts['consumer_completed']
frame_numbers = [int(r['bgfx_frame']) for r in frames]
sequences = [int(r['sequence']) for r in frames]
assert all(a < b for a,b in zip(frame_numbers, frame_numbers[1:])), 'Duplicate/out-of-order consumer frame'
assert all(a <= b for a,b in zip(sequences, sequences[1:])), 'Producer frame regressed'
assert set(int(r['slot']) for r in frames) == set(range(buffers)), 'Every ring slot must be used'
for slot in range(buffers):
    assert sum(int(r['slot']) == slot for r in frames) > 50, 'Insufficient buffer reuse'
by_frame = {int(r['bgfx_frame']): r for r in frames}
captures = list(csv.DictReader((results / 'captures.csv').open()))
assert len(captures) == log.count('success=1') and len(captures) >= 5
plain_images, stamps = [], []
for record in captures:
    image = Image.open(results / record['file']).convert('RGB')
    assert image.size == (1280,720), 'Verification currently expects the 1280x720 prototype capture'
    frame = by_frame[int(record['bgfx_frame'])]
    assert frame['sequence'] == record['sequence'] and frame['slot'] == record['slot']
    if int(record['transformed']):
        continue
    # A 640x360 source is centered and displayed at 1.25x by Dora. Both rows
    # were rendered by Godot from the same sequence, then copied by one GPU blit.
    decoded = []
    for source_y in (18,342):
        code = 0
        for bit in range(16):
            x = round(240 + (224 + bit*12 + 5)*1.25)
            y = round(135 + source_y*1.25)
            rgb = image.getpixel((x,y))
            assert max(rgb) < 35 or min(rgb) > 220, f'Invalid stamp cell in {record["file"]}'
            code |= (min(rgb) > 220) << bit
        decoded.append(code)
    assert decoded[0] == decoded[1] == (int(record['sequence']) & 65535), f'Stale/torn frame: {record["file"]}: {decoded}'
    center = image.crop((450,230,830,490))
    cyan = sum(b > 70 and g > 55 and r < g*.65 for r,g,b in pixels(center))
    assert cyan > 1000, f'Missing animated Godot cube: {record["file"]}'
    plain_images.append(center)
    stamps.append(decoded[0])
assert len(set(stamps)) == len(stamps) >= 4, 'Snapshots must capture distinct Godot frames'
differences = [sum(max(p)>8 for p in pixels(ImageChops.difference(a,b))) for a,b in zip(plain_images, plain_images[1:])]
assert all(n > 500 for n in differences), 'Godot cube animation froze (Dora transform unchanged in these captures)'
report = {
    'passed': True,
    'buffers': buffers,
    'continuous_godot_animation_verified': True,
    'exact_frame_stamps': stamps,
    'snapshot_animation_changed_pixels': differences,
    'gpu_accounting': counts,
    'slot_consumer_counts': {str(slot): sum(int(r['slot']) == slot for r in frames) for slot in range(buffers)},
    'producer_pixel_readback_or_upload': False,
    'gpu_copy': 'one blit from Godot Viewport into an event-protected ring slot per produced frame',
}
(results / 'verification.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
