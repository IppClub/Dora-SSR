#!/usr/bin/env python3
"""Build the pinned iOS Metal LibGodot archive with an audited platform profile."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'Source/3rdParty/Godot'

def digest(path):
    with path.open('rb') as file:
        return hashlib.file_digest(file, 'sha256').hexdigest()

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--device', choices=['simulator', 'device'], default='simulator')
    p.add_argument('--target', choices=['template_debug', 'template_release'], default='template_debug')
    p.add_argument('--builder', choices=['auto', 'xmake'], default='xmake',
                   help='Native xmake; auto is a compatibility alias')
    p.add_argument('--xmake', default=os.environ.get('DORA_GODOT_XMAKE', 'xmake'))
    p.add_argument('--build-dir', type=Path)
    p.add_argument('--jobs', type=int, default=2)
    a = p.parse_args()
    if not 1 <= a.jobs <= 16:
        p.error('jobs must be between 1 and 16')
    if sys.platform != 'darwin':
        p.error('iOS builds require macOS and Xcode')
    a.builder = 'xmake'
    sdk_name = 'iphonesimulator' if a.device == 'simulator' else 'iphoneos'
    sdk = subprocess.check_output(['xcrun', '--sdk', sdk_name, '--show-sdk-path'], text=True).strip()
    sdk_version = subprocess.check_output(['xcrun', '--sdk', sdk_name, '--show-sdk-version'], text=True).strip()
    xcode = next((parent for parent in Path(sdk).parents if parent.suffix == '.app'), None)
    if not xcode:
        p.error('Cannot identify the active Xcode application from SDK: ' + sdk)
    mode = 'release' if a.target == 'template_release' else 'debug'
    build = (a.build_dir or ROOT / 'build/godot-ios' / a.device).resolve()
    build.mkdir(parents=True, exist_ok=True)
    report = build / 'compilation.json'
    report.unlink(missing_ok=True)
    for script in ('prepare.py', 'prepare_ios.py'):
        subprocess.run([sys.executable, str(ROOT / 'Tools/Godot' / script), str(SOURCE)], check=True)
    env = os.environ.copy()
    env['PYTHONDONTWRITEBYTECODE'] = '1'
    inputs = {}
    toolchain = None
    appledev = 'simulator' if a.device == 'simulator' else 'iphoneos'
    if a.builder == 'xmake':
        variant = 'ios_simulator_arm64' if a.device == 'simulator' else 'ios_device_arm64'
        names = [f'Projects/xmake/godot/{variant}_sources.lua',
                 'Projects/xmake/godot/template_release_ios.json', 'Projects/xmake/godot/ios_link.json',
                 'Projects/xmake/godot/targets.lua', 'Tools/Godot/generate_xmake_sources.py', 'xmake.lua', 'Projects/xmake/options.lua', 'Projects/xmake/dependencies/host_tools.lua']
        inputs = {name: digest(ROOT / name) for name in names}
        xmake = shutil.which(a.xmake)
        if not xmake:
            p.error('Configured xmake executable is missing: ' + a.xmake)
        version = re.search(r'xmake\s+v(\d+)\.', subprocess.check_output([xmake, '--version'], text=True))
        if not version or int(version[1]) < 3:
            p.error('Godot xmake migration requires xmake 3.x or newer')
        env['XMAKE_CONFIGDIR'] = str(build / 'xmake-config')
        commands = [[xmake, 'f', '-P', str(ROOT), '-c', '-p', 'iphoneos', '-a', 'arm64', '-m', mode,
                     '--appledev=' + appledev, '--xcode=' + str(xcode), '--xcode_sdkver=' + sdk_version, '--dora_godot_runtime=y','--dora_godot_standalone=y', '--ccache=n', '-y'],
                    [xmake, 'l', '-P', str(ROOT), 'Projects/xmake/godot/toolchain_info.lua', str(build / 'toolchain.json')],
                    [xmake, 'build', '-P', str(ROOT), '-j' + str(a.jobs), 'godot-runtime']]
    (build / 'commands.json').write_text(json.dumps(commands, indent=2) + '\n')
    with (build / 'build.log').open('w') as log:
        for command in commands:
            result = subprocess.run(command, cwd=ROOT,
                                    env=env, stdout=log, stderr=subprocess.STDOUT)
            if result.returncode:
                raise SystemExit(result.returncode)
            if command is commands[1]:
                toolchain = json.loads((build / 'toolchain.json').read_text())
                assert toolchain['plat'] == 'iphoneos' and toolchain['arch'] == 'arm64', toolchain
                assert toolchain['appledev'] == appledev and toolchain['target_minver'] == '14.0', toolchain
                assert Path(toolchain['sdk']).resolve() == Path(sdk).resolve(), f"xmake SDK {toolchain['sdk']} differs from active xcrun SDK {sdk}"
    if any(digest(ROOT / name) != value for name, value in inputs.items()):
        raise RuntimeError('Godot migration inputs changed during build')
    if a.builder == 'xmake':
        archive = Path(toolchain['targetfile'])
        if not archive.is_absolute():
            archive = ROOT / archive
    assert archive.is_file(), archive
    r = {'passed': True, 'scope': 'iOS standard-module Metal archive compilation only; no app boot or GPU acceptance',
         'device': a.device, 'architecture': 'arm64', 'sdk': sdk, 'build_target': a.target, 'builder': a.builder,
         'toolchain': toolchain, 'commands': commands, 'command': commands[-1],
         'source_archive_sha256': 'e954996374cbd1cb5d72e0e3781cc537408e6ce73b010b12c6c2f308a820690a',
         'archive': str(archive), 'archive_sha256': digest(archive),
         'vendor_validation_sha256': digest(ROOT / 'Tools/Godot/vendor_source.py'),
         'migration_inputs_sha256': inputs}
    report.write_text(json.dumps(r, indent=2) + '\n')
    print(json.dumps(r, indent=2))

if __name__ == '__main__':
    main()
