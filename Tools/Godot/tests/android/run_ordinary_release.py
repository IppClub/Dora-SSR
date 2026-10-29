#!/usr/bin/env python3
"""Run public-Lua QA in an ordinary nondebuggable Release on an owned AVD.

Requires a fresh task-owned rootable AVD named DoraGodotRC1_*. Root is used
only to collect this app's private evidence and set its QA fixture options.
Never installs into a general-purpose device. A timeout leaves the app and
active-run.json intact for inspection; do not restart a live acceptance.
The caller must shut down the owned AVD after completing its matrix.
"""
import argparse, hashlib, io, json, re, subprocess, sys, tarfile, time
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from verify_ordinary_release import audit_apk, verify_case
p = argparse.ArgumentParser(description=__doc__)
for n in ('sdk', 'apk', 'runtime-package', 'output', 'lifecycle-apk'): p.add_argument('--' + n, type=Path, required=True)
p.add_argument('--serial', required=True); p.add_argument('--owned-avd', required=True)
p.add_argument('--buffers', type=int, choices=(2, 3, 4), default=3); p.add_argument('--missing', action='store_true')
a = p.parse_args(); assert a.owned_avd.startswith('DoraGodotRC1_')
out = a.output.resolve(); out.mkdir(parents=True, exist_ok=False)
adb = [str(a.sdk / 'platform-tools/adb'), '-s', a.serial]
def call(args, **kw): return subprocess.run(adb + args, check=True, timeout=30, **kw)
def text(args): return subprocess.check_output(adb + args, timeout=30).decode(errors='replace').strip()
assert text(['emu', 'avd', 'name']).splitlines()[0] == a.owned_avd
package = 'org.ippclub.dorassr'; base = '/data/user/0/' + package + '/files/godot-release'
aapt = a.sdk / 'build-tools/34.0.0/aapt'
artifacts = audit_apk(a.apk, a.runtime_package, aapt, a.missing)
existing = subprocess.run(adb + ['shell', 'pidof', package], capture_output=True, timeout=30)
assert existing.returncode == 1 and not existing.stdout.strip(), 'Existing app process or failed PID probe: inspect first'
root_request = subprocess.run(adb + ['root'], capture_output=True, timeout=30)
(out / 'adb-root.log').write_bytes(root_request.stdout + root_request.stderr)
# adbd can disconnect before its root response reaches the host. Verify the
# reconnected daemon's actual UID rather than treating that transport status
# as an app failure; installation has not started at this point.
call(['wait-for-device'], capture_output=True)
assert text(['shell', 'id', '-u']) == '0', 'An owned rootable emulator is required for nondebuggable private files'
with (out / 'install.log').open('w') as log: call(['install', '-r', str(a.apk.resolve())], stdout=log, stderr=subprocess.STDOUT)
controller_info = subprocess.check_output([str(aapt), 'dump', 'badging', str(a.lifecycle_apk)], text=True)
assert "package: name='org.dora.godotrc1.lifecycle'" in controller_info
with (out / 'controller-install.log').open('w') as controller_log:
    call(['install', '-r', str(a.lifecycle_apk.resolve())], stdout=controller_log, stderr=subprocess.STDOUT)
artifacts['lifecycle_controller_sha256'] = hashlib.sha256(a.lifecycle_apk.read_bytes()).hexdigest()
info = text(['shell', 'dumpsys', 'package', package]); uid = re.search(r'\b(?:userId|appId)=(\d+)', info); assert uid
assert text(['shell', 'stat', '-c', '%u', '/data/user/0/' + package]) == uid[1]
(out / 'installed-package.txt').write_text(info)
# Remove only the task-specific fixture directory, after confirming no app PID.
call(['shell', 'rm', '-rf', base], capture_output=True)
call(['shell', 'mkdir', '-p', base], capture_output=True)
call(['shell', 'echo ' + str(a.buffers) + ' > ' + base + '/buffers.txt'], capture_output=True)
if a.missing: call(['shell', 'touch', base + '/expect-missing'], capture_output=True)
call(['shell', 'chown', '-R', uid[1] + ':' + uid[1], base], capture_output=True)
badging = subprocess.check_output([str(aapt), 'dump', 'badging', str(a.apk)], text=True)
activity = re.search(r"launchable-activity: name='([^']+)'", badging); assert activity
active = {'serial': a.serial, 'avd': a.owned_avd, 'package': package, 'state': 'starting', 'files': base,
          'artifacts': artifacts, 'buffers': a.buffers, 'missing': a.missing}
state = out / 'active-run.json'; state.write_text(json.dumps(active, indent=2) + '\n')
instrument_log = (out / 'instrumentation.log').open('wb')
instrument = subprocess.Popen(adb + ['shell', 'am', 'instrument', '-w',
    'org.dora.godotrc1.lifecycle/org.dora.godotrc1.ReleaseLifecycle'], stdout=instrument_log, stderr=subprocess.STDOUT)
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
            time.sleep(.25)
        else: raise TimeoutError('No full shutdown; inspect this PID and active-run.json without restarting')
    finally:
        logger.terminate(); logger.wait(timeout=10)
        instrument_log.close()
# Extraction accepts only this fixture's flat regular evidence files.
stream = subprocess.check_output(adb + ['exec-out', 'tar', '-cf', '-', '-C', base, '.'], timeout=30)
files = out / 'files'; files.mkdir()
with tarfile.open(fileobj=io.BytesIO(stream)) as archive:
    for member in archive:
        name = Path(member.name)
        if member.isfile() and len(name.parts) == 1 and (name.suffix == '.png' or name.name == 'result.json'):
            (files / name.name).write_bytes(archive.extractfile(member).read())
result = verify_case(out, a.buffers, a.missing)
result.update(artifacts=artifacts, serial=a.serial, avd=a.owned_avd, scope=__doc__, exit_method='Separate Android framework instrumentation calls Activity.finish after public Lua completion')
(out / 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
# A native full shutdown is proven before ending the remaining Android activity.
call(['shell', 'am', 'force-stop', package], capture_output=True)
active.update(state='finished', full_native_shutdown=True)
state.write_text(json.dumps(active, indent=2) + '\n')
print(json.dumps(result, indent=2))
