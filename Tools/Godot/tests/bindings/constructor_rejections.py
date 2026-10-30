"""Prepare strict recovery verification without modifying the native raw log."""
import collections
import re
import shutil


def prepare_recovery(results, language):
    raw = (results / 'run.log').read_text(encoding='utf-8')
    assert raw.count('GODOT_BINDING ' + language + ' constructor_rejections=6') == 2
    expected = {'GodotNode: invalid viewport dimensions or buffer count': 10,
                'GodotNode: project directory or .pck bundle was not found': 2}
    rejected = collections.Counter()
    kept = []
    for line in raw.splitlines(keepends=True):
        if re.search(r'ERROR:|WARNING:|\[(?:error|critical)\]', line):
            message = re.search(r'\[error\] (GodotNode: [^\r\n]+)$', line)
            assert message and message.group(1) in expected, ('Unexpected rejection-run diagnostic', line)
            rejected[message.group(1)] += 1
        else:
            kept.append(line)
    assert dict(rejected) == expected, ('Unexpected constructor diagnostic counts', dict(rejected))
    recovered = results / 'recovered'
    recovered.mkdir(exist_ok=True)
    for image in results.glob('*.png'):
        shutil.copy2(image, recovered / image.name)
    (recovered / 'run.log').write_text(''.join(kept), encoding='utf-8')
    return recovered
