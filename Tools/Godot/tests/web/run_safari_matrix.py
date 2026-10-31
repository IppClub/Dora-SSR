#!/usr/bin/env python3
"""Prepare and run the strict native Safari direct-target 2/3/4 matrix."""
import argparse,json,shutil,subprocess
from pathlib import Path

root=Path(__file__).resolve().parents[4]
source=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--package',type=Path,default=root/'build/godot-web/dora-player',help='Dora Web package used as the immutable host template')
p.add_argument('--runtime-package',type=Path,default=root/'build/godot-web/package',help='Sealed Godot Web runtime package')
p.add_argument('--output',type=Path,default=root/'build/godot-web/direct-node-safari-matrix')
p.add_argument('--cabi-observer',action='store_true',help='Use production C ABI counters when native Info logs are disabled')
a=p.parse_args()

template=a.package.resolve();runtime=a.runtime_package.resolve();output=a.output.resolve()
assert template.is_dir(),template
assert runtime.is_dir() and (runtime/'manifest.json').is_file(),runtime
assert not output.exists(),'Use a fresh matrix output directory'
output.mkdir(parents=True)
aggregate=output/'verification.json'
cases=[];shared=None;browser=None;capabilities=None;instrumentation=None
stable_artifacts=('dora-player-runtime.js','dora-player-runtime.wasm','godot/dora-godot.js',
    'godot/dora-godot.wasm','godot/shared_gl.mjs','godot/runtime_bridge.mjs')

for buffers in (2,3,4):
    package=output/f'player-{buffers}'
    result=output/f'case-{buffers}'
    shutil.copytree(template,package)
    subprocess.run(['python3',str(source/'prepare_node_game.py'),'--buffers',str(buffers),'--package',str(package),'--runtime-package',str(runtime)],check=True,cwd=root)
    command=['python3',str(source/'run_safari.py'),'--package',str(package),'--output',str(result),'--buffers',str(buffers)]
    if a.cabi_observer:command.append('--cabi-observer')
    subprocess.run(command,check=True,cwd=root)
    report=json.loads((result/'verification.json').read_text())
    assert report['passed'] and report['browser_engine']=='safari'
    assert report['browser_headless'] is False and report['renderer']=='Apple GPU'
    assert report['godot_packaged'] is True and report['ordinary'] is False
    assert report['buffers']==buffers and report['direct_target'] is True
    assert report['steady_state_blits']==0 and len(report['direct_completed_frames'])==2
    assert all(value>0 for value in report['direct_completed_frames'])
    assert report['controller_frames']==620 and len(report['captures'])==12
    assert report['capabilities']['safari:useSimulator'] is False
    artifacts={name:report['artifacts'][name] for name in stable_artifacts}
    if shared is None:shared=artifacts
    else:assert artifacts==shared,(artifacts,shared)
    if browser is None:browser=report['browser'];capabilities=report['capabilities']
    else:assert report['browser']==browser and report['capabilities']==capabilities
    if instrumentation is None:instrumentation=report['test_instrumentation_sha256']
    else:assert report['test_instrumentation_sha256']==instrumentation
    cases.append({'buffers':buffers,'report':str((result/'verification.json').relative_to(output)),
        'controller_frames':report['controller_frames'],'captures':len(report['captures']),
        'pixel_checks':report['pixel_checks'],'direct_completed_frames':report['direct_completed_frames'],
        'gpu_clients':report['gpu_clients'],'gpu_readers':report['gpu_readers']})

summary={'passed':True,'scope':'Installed native macOS Safari direct-target 2/3/4 acceptance; physical iOS Safari and background throttling are not covered',
    'browser_engine':'safari','browser':browser,'capabilities':capabilities,'buffers':[2,3,4],
    'direct_target':True,'steady_state_blits':0,'test_instrumentation_sha256':instrumentation,
    'artifacts':shared,'cases':cases,
    'totals':{'controller_frames':sum(case['controller_frames'] for case in cases),
        'captures':sum(case['captures'] for case in cases),'pixel_checks':sum(case['pixel_checks'] for case in cases),
        'direct_completed_frames':sum(sum(case['direct_completed_frames']) for case in cases)}}
aggregate.write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))
