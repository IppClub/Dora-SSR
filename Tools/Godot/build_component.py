#!/usr/bin/env python3
"""Build and stage the production Godot component using the native xmake builders."""
import argparse
import hashlib
import json
import os
import platform
from pathlib import Path
import shutil
import subprocess
import sys

from verify_package import verify

ROOT = Path(__file__).resolve().parents[2]


def run(script, *args, env=None):
    program = 'bash' if script.endswith('.sh') else sys.executable
    try:
        subprocess.run([program, str(ROOT / 'Tools/Godot' / script), *map(str, args)],
                       cwd=ROOT, env=env, check=True)
    except subprocess.CalledProcessError:
        # Standalone builders retain compiler output in build.log. Surface its
        # tail as well, so a normal host build exposes the original error.
        directory = (env or {}).get('DORA_GODOT_BUILD_DIR')
        if '--build-dir' in args:
            directory = args[args.index('--build-dir') + 1]
        log_name = 'link.log' if script == 'link_ios_runtime.py' else 'build.log'
        log = Path(directory) / log_name if directory else None
        if log and log.is_file():
            with log.open('rb') as stream:
                stream.seek(max(0, log.stat().st_size - 96 * 1024))
                tail = stream.read().decode('utf-8', errors='replace').splitlines()[-180:]
            message = f'Godot compiler log: {log}\n' + '\n'.join(tail) + '\n'
            if hasattr(sys.stderr, 'buffer'):
                sys.stderr.buffer.write(message.encode('utf-8'))
                sys.stderr.buffer.flush()
            else:
                sys.stderr.write(message)
                sys.stderr.flush()
        raise


def copy_file(source, destination):
    destination.parent.mkdir(parents=True, exist_ok=True)
    def digest(file):
        with file.open('rb') as stream:
            return hashlib.file_digest(stream, 'sha256').digest()
    if destination.is_file() and digest(source) == digest(destination):
        return False
    shutil.copy2(source, destination)
    return True


def stage(package, destination, platform, metadata):
    destination.mkdir(parents=True, exist_ok=True)
    changed = False
    if platform in ('ios', 'web'):
        for file in sorted(package.rglob('*')):
            if file.is_file() and (platform == 'web' or 'DoraGodot.framework' in file.parts):
                relative = file.relative_to(package)
                target = destination / ('Frameworks' if platform == 'ios' else '') / relative
                changed = copy_file(file, target) or changed
        if platform == 'web':
            return changed  # The complete package already includes its notices.
    else:
        changed = copy_file(package / metadata['library'], destination / metadata['library'])
    notices = destination / 'GodotRuntimeNotices'
    notices.mkdir(exist_ok=True)
    changed = copy_file(package / 'manifest.json', notices / 'manifest.json') or changed
    for name in metadata['licenses']:
        changed = copy_file(package / name, notices / name) or changed
    return changed


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--platform', choices=['macosx', 'linux', 'windows', 'android', 'web', 'ios'], required=True)
    p.add_argument('--arch', required=True)
    p.add_argument('--mode', choices=['debug', 'release'], required=True)
    p.add_argument('--device', choices=['simulator', 'device'], default='simulator')
    p.add_argument('--jobs', type=int, default=int(os.environ.get('JOBS', '2')))
    p.add_argument('--runtime-package', type=Path)
    p.add_argument('--stage', type=Path)
    p.add_argument('--stage-only', action='store_true')
    p.add_argument('--sdk', type=Path)
    p.add_argument('--output', type=Path)
    a = p.parse_args()
    if a.jobs < 1:
        p.error('jobs must be positive')
    if a.platform in ('android', 'ios', 'web'):
        a.jobs = min(a.jobs, 16)  # Respect the standalone mobile/Web builders.
    arch = {'aarch64': 'arm64', 'x64': 'x86_64', 'arm64-v8a': 'arm64', 'armeabi-v7a': 'arm32'}.get(a.arch, a.arch)
    supported = {'macosx': ['arm64'], 'linux': ['arm64', 'x86_64'], 'windows': ['x86_64'],
                 'android': ['arm64', 'arm32', 'x86_64'], 'web': ['wasm32'], 'ios': ['arm64']}
    if arch not in supported[a.platform]:
        p.error(f'Godot production component does not support {a.platform}/{arch}; explicitly disable Godot for a Dora-only build')
    build = ROOT / 'build/godot-component' / a.platform / arch / a.mode
    if a.platform == 'ios':
        build /= a.device
    package = (a.runtime_package or build / 'package').resolve()
    target = 'template_' + a.mode
    env = os.environ.copy()
    env.update(DORA_GODOT_TARGET=target, JOBS=str(a.jobs), DORA_GODOT_XMAKE=env.get('DORA_XMAKE', 'xmake'))
    if not a.stage_only and not a.runtime_package:
        build.mkdir(parents=True, exist_ok=True)
        if a.platform in ('macosx', 'linux'):
            env.update(DORA_GODOT_BUILD_DIR=str(build), DORA_GODOT_ARCH=arch, DORA_GODOT_LINUX_ARCH=arch)
            host_arch = {'aarch64': 'arm64', 'AMD64': 'x86_64'}.get(platform.machine(), platform.machine())
            if a.platform == 'linux' and arch != host_arch:
                env.setdefault('DORA_GODOT_LINUX_CROSS', 'aarch64-linux-gnu-' if arch == 'arm64' else 'x86_64-linux-gnu-')
            run('build_runtime.sh' if a.platform == 'macosx' else 'build_linux_runtime.sh', env=env)
        elif a.platform == 'windows':
            run('build_windows_runtime.py', '--build-dir', build, '--arch', arch, '--target', target,
                '--backend', 'WGL', '--jobs', a.jobs, env=env)
        elif a.platform == 'web':
            run('build_web_runtime.py', '--build-dir', build, '--target', target, '--jobs', a.jobs, env=env)
        elif a.platform == 'ios':
            run('build_ios_runtime.py', '--build-dir', build, '--target', target, '--device', a.device, '--jobs', a.jobs, env=env)
            run('link_ios_runtime.py', '--build-dir', build, '--device', a.device, env=env)
        else:
            sdk = a.sdk or Path(env.get('ANDROID_HOME') or env.get('ANDROID_SDK_ROOT') or Path.home() / 'Library/Android/sdk')
            run('build_android_runtime.py', '--build-dir', build, '--sdk', sdk, '--arch', arch, '--target', target, '--jobs', a.jobs, env=env)
    verify(package)
    metadata = json.loads((package / 'manifest.json').read_text())
    if metadata.get('build_target') != target:
        p.error(f'{a.mode} host requires {target}, not {metadata.get("build_target")}')
    architectures = metadata.get('architectures', []) if a.platform != 'web' else [metadata.get('toolchain', {}).get('arch')]
    if arch not in architectures:
        p.error('Godot runtime architecture does not match the host')
    backend = {'macosx': 'metal', 'ios': 'metal', 'linux': 'egl', 'android': 'egl', 'windows': 'wgl', 'web': 'webgl2'}[a.platform]
    if metadata.get('graphics_backend') != backend:
        p.error('Godot runtime graphics backend does not match the production host')
    if a.platform == 'ios' and metadata.get('device') != a.device:
        p.error('Godot framework SDK does not match the iOS host')
    changed = stage(package, a.stage.resolve(), a.platform, metadata) if a.stage else False
    result = {'package': str(package), 'platform': a.platform, 'arch': arch, 'build_target': target,
              'graphics_backend': backend, 'library': metadata.get('library', 'dora-godot.wasm'), 'staged_changed': changed}
    if a.output:
        a.output.parent.mkdir(parents=True, exist_ok=True)
        a.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
