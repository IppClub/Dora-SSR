#!/usr/bin/env python3
"""Test timing acceptance gates with real before/after native evidence copies.

No engine/GPU is launched and no captured pixels are synthesized or modified.
"""
import argparse,json,re,shutil,subprocess,sys,tempfile
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--good',type=Path,required=True)
p.add_argument('--bad',type=Path,required=True)
a=p.parse_args();accepted=json.loads((a.good/'verification.json').read_text());assert accepted['passed']
platform=accepted['platform'];goodlog=(a.good/'run.log').read_text(encoding='utf8',errors='replace')
cases=[('original-fixed-step',a.bad,None,'Shader TIME / script time drift'),
       ('stopped-frame-counter',a.good,re.sub(r'GODOT_TIMING_DRAWN value=\d+','GODOT_TIMING_DRAWN value=0',goodlog),'Drawn-frame counter stopped'),
       ('wrong-scale-metadata',a.good,goodlog.replace('scale=0.25 paused=0','scale=1.0 paused=0'),'Time-scale command not applied')]
with tempfile.TemporaryDirectory(prefix='dora-godot-timing-') as directory:
    evidence=Path(directory)
    for name,source,log,expected in cases:
        for old in evidence.glob('*.png'):old.unlink()
        for image in source.glob('*.png'):shutil.copy2(image,evidence/image.name)
        (evidence/'run.log').write_text(log if log is not None else (source/'run.log').read_text(encoding='utf8',errors='replace'),encoding='utf8')
        report=evidence/'verification.json';report.write_text('{"passed":true}\n')
        result=subprocess.run([sys.executable,str(Path(__file__).with_name('verify_timing.py')),'--results',str(evidence),'--platform',platform],capture_output=True,text=True,timeout=30)
        assert result.returncode!=0 and not report.exists(),(name,result.stdout,result.stderr)
        assert expected in result.stderr,(name,result.stderr)
print('Timing verifier rejection: PASS; actual pre-fix pixels plus 2 metadata failures; GPU not launched')
