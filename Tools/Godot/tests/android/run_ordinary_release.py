#!/usr/bin/env python3
"""Run public-Lua QA in an ordinary nondebuggable Release.

An emulator must be a task-owned AVD named DoraGodotRC1_*. A physical device
requires --physical-device. The separate debuggable instrumentation configures
the target's private fixture and exports only flat QA evidence files, so the
ordinary target remains nondebuggable. A timeout leaves the app and
active-run.json intact; do not restart a live acceptance.
"""
import argparse, hashlib, json, re, subprocess, sys, time
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from verify_ordinary_release import audit_apk, verify_case
p = argparse.ArgumentParser(description=__doc__)
for n in ('sdk', 'apk', 'runtime-package', 'output', 'lifecycle-apk'): p.add_argument('--' + n, type=Path, required=True)
p.add_argument('--serial', required=True); p.add_argument('--owned-avd')
p.add_argument('--physical-device', action='store_true')
p.add_argument('--buffers', type=int, choices=(2, 3, 4), default=3); p.add_argument('--missing', action='store_true')
p.add_argument('--direct', action='store_true')
a = p.parse_args()
out = a.output.resolve(); out.mkdir(parents=True, exist_ok=False)
adb = [str(a.sdk / 'platform-tools/adb'), '-s', a.serial]
def call(args, **kw): return subprocess.run(adb + args, check=True, timeout=30, **kw)
def text(args): return subprocess.check_output(adb + args, timeout=30).decode(errors='replace').strip()
emulator = text(['shell', 'getprop', 'ro.kernel.qemu']) == '1'
if emulator:
    assert not a.physical_device and a.owned_avd and a.owned_avd.startswith('DoraGodotRC1_')
    assert text(['emu', 'avd', 'name']).splitlines()[0] == a.owned_avd
else:
    assert a.physical_device and not a.owned_avd, 'Physical devices require --physical-device and no --owned-avd'
package = 'org.ippclub.dorassr'
controller_package = 'org.dora.godotrc1.lifecycle'
external = '/sdcard/Android/media/' + package + '/dora-godot-evidence'
aapt = a.sdk / 'build-tools/34.0.0/aapt'
artifacts = audit_apk(a.apk, a.runtime_package, aapt, a.missing)
existing = subprocess.run(adb + ['shell', 'pidof', package], capture_output=True, timeout=30)
assert existing.returncode == 1 and not existing.stdout.strip(), 'Existing app process or failed PID probe: inspect first'
with (out / 'install.log').open('w') as log: call(['install', '-r', str(a.apk.resolve())], stdout=log, stderr=subprocess.STDOUT)
controller_info = subprocess.check_output([str(aapt), 'dump', 'badging', str(a.lifecycle_apk)], text=True)
assert "package: name='org.dora.godotrc1.lifecycle'" in controller_info
with (out / 'controller-install.log').open('w') as controller_log:
    call(['install', '-r', str(a.lifecycle_apk.resolve())], stdout=controller_log, stderr=subprocess.STDOUT)
artifacts['lifecycle_controller_sha256'] = hashlib.sha256(a.lifecycle_apk.read_bytes()).hexdigest()
call(['shell', 'am', 'wait-for-broadcast-idle'], capture_output=True)
call(['shell', 'am', 'force-stop', package], capture_output=True)
call(['shell', 'am', 'force-stop', controller_package], capture_output=True)
info = text(['shell', 'dumpsys', 'package', package]); uid = re.search(r'\b(?:userId|appId)=(\d+)', info); assert uid
(out / 'installed-package.txt').write_text(info)
badging = subprocess.check_output([str(aapt), 'dump', 'badging', str(a.apk)], text=True)
activity = re.search(r"launchable-activity: name='([^']+)'", badging); assert activity
active = {'serial': a.serial, 'avd': a.owned_avd, 'physical_device': not emulator,
          'package': package, 'state': 'starting', 'evidence': external,
          'artifacts': artifacts, 'buffers': a.buffers, 'missing': a.missing, 'direct': a.direct}
state = out / 'active-run.json'; state.write_text(json.dumps(active, indent=2) + '\n')
instrument_log = (out / 'instrumentation.log').open('wb')
instrument_command = adb + ['shell', 'am', 'instrument', '-w',
    '-e', 'buffers', str(a.buffers), '-e', 'direct', str(int(a.direct)), '-e', 'missing', str(int(a.missing)),
    'org.dora.godotrc1.lifecycle/org.dora.godotrc1.ReleaseLifecycle']
instrument = subprocess.Popen(instrument_command, stdout=instrument_log, stderr=subprocess.STDOUT)
launch_deadline = time.monotonic() + 30
while True:
    probe = subprocess.run(adb + ['shell', 'pidof', package], capture_output=True, timeout=30)
    pid = probe.stdout.decode().strip()
    if re.fullmatch(r'\d+', pid): break
    assert instrument.poll() is None, 'Instrumentation ended before target launch; inspect instrumentation.log'
    assert time.monotonic() < launch_deadline, 'Target PID not observed; inspect instrumentation.log'
    time.sleep(.1)
active.update(pid=int(pid), state='running'); state.write_text(json.dumps(active, indent=2) + '\n')
with (out / 'run.log').open('wb') as log:
    logger = subprocess.Popen(adb + ['logcat', '--pid=' + pid, '-v', 'raw'], stdout=log, stderr=subprocess.STDOUT)
    try:
        deadline = time.monotonic() + 120
        while time.monotonic() < deadline:
            if 'destroy: Logger.' in (out / 'run.log').read_text(errors='replace'):
                assert instrument.wait(timeout=30) == 0
                break
            if instrument.poll() is not None:
                time.sleep(.5)
                if 'destroy: Logger.' not in (out / 'run.log').read_text(errors='replace'):
                    raise RuntimeError('Instrumentation ended before native shutdown; inspect instrumentation.log and run.log')
            time.sleep(.25)
        else: raise TimeoutError('No full shutdown; inspect this PID and active-run.json without restarting')
    finally:
        logger.terminate(); logger.wait(timeout=10)
        instrument_log.close()
files = out / 'files'; files.mkdir()
listing = text(['shell', 'ls', '-1', external]).splitlines()
allowed = {'result.json', 'controller.json'} | {name for name in listing if re.fullmatch(r'[a-z-]+\.png', name)}
assert set(listing) == allowed and {'result.json', 'controller.json'} <= allowed, listing
for name in listing:
    (files / name).write_bytes(subprocess.check_output(adb + ['exec-out', 'cat', external + '/' + name], timeout=30))
controller = json.loads((files / 'controller.json').read_text())
assert controller == {'buffers': a.buffers, 'direct': a.direct, 'missing': a.missing}, controller
result = verify_case(out, a.buffers, a.missing, a.direct)
result.update(artifacts=artifacts, serial=a.serial, avd=a.owned_avd, android_emulator=emulator,
              physical_device=not emulator, scope=__doc__,
              exit_method='Separate Android framework instrumentation calls Activity.finish after public Lua completion')
(out / 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
# A native full shutdown is proven before ending the remaining Android activity.
call(['shell', 'am', 'force-stop', package], capture_output=True)
active.update(state='finished', full_native_shutdown=True)
state.write_text(json.dumps(active, indent=2) + '\n')
print(json.dumps(result, indent=2))
