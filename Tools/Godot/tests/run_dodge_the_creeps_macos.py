#!/usr/bin/env python3
"""Run the unchanged upstream Godot Dodge the Creeps project in an ordinary Dora app."""
import argparse, hashlib, json, os, re, shutil, subprocess, sys, time
from pathlib import Path
from PIL import Image, ImageChops

root = Path(__file__).resolve().parents[3]
p = argparse.ArgumentParser(description=__doc__)
for name in ('app', 'library', 'project', 'output'):
    p.add_argument('--' + name, type=Path, required=True)
p.add_argument('--upstream-commit', required=True)
p.add_argument('--editor-sha256', required=True)
a = p.parse_args()
assert sys.platform == 'darwin'

out = a.output.resolve()
assert not out.exists(), 'Use a fresh output directory to preserve prior evidence'
out.mkdir(parents=True)

def sha(path):
    with path.open('rb') as file:
        return hashlib.file_digest(file, 'sha256').hexdigest()

def tree_hashes(path):
    return {str(file.relative_to(path)): sha(file) for file in sorted(path.rglob('*'))
            if file.is_file() and '.godot' not in file.relative_to(path).parts}

try:
    source_app = a.app.resolve()
    source_binary = source_app / 'Contents/MacOS/Dora'
    library = a.library.resolve()
    source_project = a.project.resolve()
    assert source_binary.is_file() and library.is_file()
    assert (source_project / 'project.godot').is_file()
    assert (source_project / '.godot/imported').is_dir(), 'Import the upstream project with Godot 4.6 before running'
    assert '_dora_godot_node_test_main' not in subprocess.check_output(
        ['nm', '-gU', str(source_binary)], text=True), 'Use an ordinary Dora host'
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(source_app)], check=True, capture_output=True)
    subprocess.run([sys.executable, str(Path(__file__).with_name('runtime_abi.py')),
                    '--library', str(library), '--backend', 'Metal', '--require-audio',
                    '--output', str(out / 'abi-preboot')], check=True)

    app = out / 'Dora.app'
    subprocess.run(['cp', '-cR', str(source_app), str(app)], check=True)
    resources = app / 'Contents/Resources'
    project = resources / 'GodotProject'
    shutil.copytree(source_project, project, ignore=shutil.ignore_patterns('.git'))
    shutil.copy2(library, resources / 'libdora_godot.dylib')
    template = Path(__file__).with_name('dodge_the_creeps_macos.lua')
    startup = template.read_text().replace('@PROJECT@', json.dumps(str(project))).replace('@OUTPUT@', json.dumps(str(out)))
    (resources / 'Script/init.lua').write_text(startup)
    (out / 'startup.lua').write_text(startup)
    subprocess.run(['codesign', '--force', '--deep', '--timestamp=none', '--sign', '-', str(app)], check=True, capture_output=True)
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True, capture_output=True)

    source_hashes = tree_hashes(source_project)
    staged_hashes = tree_hashes(project)
    assert source_hashes == staged_hashes, 'Staged upstream project differs before execution'
    artifacts = {
        'upstream_repository': 'https://github.com/godotengine/godot-demo-projects',
        'upstream_project': '2d/dodge_the_creeps',
        'upstream_commit': a.upstream_commit,
        'godot_editor_archive_sha256': a.editor_sha256,
        'host_sha256': sha(source_binary),
        'runtime_sha256': sha(library),
        'controller_sha256': sha(template),
        'upstream_project_files': source_hashes,
    }
    (out / 'artifacts.json').write_text(json.dumps(artifacts, indent=2) + '\n')

    env = {key: value for key, value in os.environ.items()
           if not key.startswith(('DORA_GODOT_', 'DORA_BUILD_'))}
    env['MTL_DEBUG_LAYER'] = '1'
    started = time.monotonic()
    with (out / 'run.log').open('w') as log:
        result = subprocess.run([str(app / 'Contents/MacOS/Dora')], cwd=root, env=env,
                                stdout=log, stderr=subprocess.STDOUT, timeout=90)
    runtime_seconds = time.monotonic() - started
    assert result.returncode == 0
    assert tree_hashes(project) == staged_hashes, 'Upstream project source files changed during execution'
    assert sha(source_binary) == artifacts['host_sha256'] and sha(library) == artifacts['runtime_sha256']

    log = (out / 'run.log').read_text()
    assert 'DORA_DODGE running=1' in log and 'DORA_DODGE start_click=1' in log
    assert 'DORA_DODGE complete=1 captures=9 ticks=455' in log
    rejected = re.findall(r'ERROR:|WARNING:|Metal Validation Error|BGFX LEAK:|C\+\+ objects leaks', log)
    assert not rejected, rejected

    names = ['title', 'input-before', 'input-after', 'active-a', 'active-b',
             'paused-a', 'paused-b', 'resumed', 'removed']
    images = {name: Image.open(out / (name + '.png')).convert('RGB') for name in names}
    assert len({image.size for image in images.values()}) == 1
    width, height = images['title'].size
    box = (round(width * .32), round(height * .08), round(width * .68), round(height * .92))
    crops = {name: image.crop(box) for name, image in images.items()}
    def pixels(image):
        return image.get_flattened_data() if hasattr(image, 'get_flattened_data') else image.getdata()
    def changed(first, second):
        return sum(pixel != (0, 0, 0) for pixel in pixels(ImageChops.difference(crops[first], crops[second])))
    title_to_started = changed('title', 'input-before')
    active_motion = changed('active-a', 'active-b')
    paused_motion = changed('paused-a', 'paused-b')
    resumed_motion = changed('paused-b', 'resumed')
    removal_change = changed('resumed', 'removed')
    def player_center(name):
        points = [(x, y) for y in range(height) for x in range(width)
                  if (lambda color: abs(color[0] - 148) < 18 and abs(color[1] - 127) < 18
                      and abs(color[2] - 124) < 18)(images[name].getpixel((x, y)))]
        assert len(points) > 40, (name, len(points))
        return sum(x for x, _ in points) / len(points), len(points)
    player_before, player_before_pixels = player_center('input-before')
    player_after, player_after_pixels = player_center('input-after')
    player_movement = player_after - player_before
    assert title_to_started > 1000, title_to_started
    assert active_motion > 500, active_motion
    assert paused_motion == 0, paused_motion
    assert resumed_motion > 500, resumed_motion
    assert removal_change > 1000, removal_change
    assert player_movement > 40, (player_before, player_after, player_movement)

    clients = re.findall(r'GodotRuntime client closed: produced=(\d+), completed=(\d+), gpuErrors=(\d+)', log)
    readers = re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)', log)
    audio = re.findall(r'GodotAudio drained: produced=(\d+), consumed=(\d+), nonzeroProduced=(\d+), nonzeroConsumed=(\d+), underrunFrames=(\d+)', log)
    direct = re.findall(r'DORA_GODOT_METAL_DIRECT completed frames=(\d+) blits=(\d+) waits=(\d+)', log)
    assert len(clients) == len(readers) == len(audio) == len(direct) == 1
    produced, completed, errors = map(int, clients[0])
    assert produced == completed and produced > 0 and errors == 0
    buffers, frames, waits, signals, pending, completed_reads, read_errors = map(int, readers[0])
    assert buffers == 3 and frames == completed_reads and frames > 0 and pending == read_errors == 0
    audio_produced, consumed, nonzero_produced, nonzero_consumed, underruns = map(int, audio[0])
    assert audio_produced >= consumed > 0 and nonzero_produced > 0 and nonzero_consumed > 0 and underruns == 0
    direct_frames, blits, direct_waits = map(int, direct[0])
    assert direct_frames > 0 and direct_waits > 0 and blits == 0

    report = {
        'passed': True,
        'scope': 'Unchanged official open-source Godot project in an ordinary Dora Release host on native macOS Metal; generated .godot imports are produced by the official matching editor. This is not other-platform, large-project, plugin, distribution-signing, physical audio, or performance acceptance.',
        'project': {'name': 'Dodge the Creeps', 'upstream_repository': artifacts['upstream_repository'],
                    'path': artifacts['upstream_project'], 'commit': a.upstream_commit,
                    'source_files_unchanged': True, 'generated_import_cache_used': True},
        'runtime_seconds': runtime_seconds,
        'captures': len(names),
        'input': {'pointer_start_button': True, 'held_key_D': True,
                  'physical_key_action_moved_player_pixels': player_movement,
                  'player_centers_x': [player_before, player_after],
                  'player_color_pixels': [player_before_pixels, player_after_pixels]},
        'image_checks': {'title_to_started_changed_pixels': title_to_started,
                         'active_changed_pixels': active_motion, 'paused_changed_pixels': paused_motion,
                         'resumed_changed_pixels': resumed_motion, 'removal_changed_pixels': removal_change},
        'gpu': {'client': clients[0], 'readers': readers[0], 'metal_direct': direct[0],
                'steady_state_blits': 0},
        'audio': {'accounting': audio[0], 'decoded_project_ogg_nonzero': True,
                  'physical_device_audibility_tested': False},
        'artifacts': {key: value for key, value in artifacts.items() if key != 'upstream_project_files'},
        'abi_preboot_sha256': sha(out / 'abi-preboot/verification.json'),
        'images_sha256': {name: sha(out / (name + '.png')) for name in names},
        'log_sha256': sha(out / 'run.log'),
    }
    (out / 'verification.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
except BaseException as error:
    (out / 'verification.json').unlink(missing_ok=True)
    (out / 'failure.json').write_text(json.dumps({'passed': False, 'type': type(error).__name__,
                                                   'error': repr(error)}, indent=2) + '\n')
    raise
