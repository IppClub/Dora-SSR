#!/usr/bin/env python3
"""CPU-only negative checks against an actual passing GPU output dataset."""
import argparse,json,shutil,subprocess,sys,tempfile
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--results',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True);report=a.output/'verification.json';report.unlink(missing_ok=True)
original=json.loads((a.results/'verification.json').read_text());assert original['passed'] and original['captures']==16
verifier=Path(__file__).with_name('verify_output.py');checks={}
with tempfile.TemporaryDirectory(prefix='dora-godot-output-negative-') as temporary:
    copied=Path(temporary)/'dataset';shutil.copytree(a.results,copied)
    log=(copied/'run.log').read_text(errors='replace')
    command=[sys.executable,str(verifier),'--results',str(copied),'--platform',original['platform']]
    if original['startup_source_size_verified']:command+=['--startup']
    baseline=subprocess.run(command,capture_output=True,text=True);assert baseline.returncode==0,baseline.stderr
    for case in ('missing_bounce','missing_gui_button','runtime_error','missing_image'):
        (copied/'run.log').write_text(log)
        saved=None
        if case=='missing_bounce':(copied/'run.log').write_text(log.replace('GODOT_OUTPUT_BOUNCE width=400 height=300','REMOVED_BOUNCE',1))
        if case=='missing_gui_button':(copied/'run.log').write_text(log.replace('GODOT_OUTPUT_BUTTON phase=8 hits=8','REMOVED_GUI_BUTTON',1))
        if case=='runtime_error':(copied/'run.log').write_text(log+'\nGodotNode: injected verification failure\n')
        if case=='missing_image':
            image=copied/'phase-8-b.png';saved=image.read_bytes();image.unlink()
        (copied/'verification.json').write_text('{"passed":true,"stale":true}\n')
        result=subprocess.run(command,capture_output=True,text=True)
        checks[case]={'exit_code':result.returncode,'stale_pass_deleted':not (copied/'verification.json').exists()}
        assert result.returncode!=0 and checks[case]['stale_pass_deleted'],(case,result.stdout,result.stderr)
        if saved is not None:(copied/'phase-8-b.png').write_bytes(saved)
report.write_text(json.dumps({'passed':True,'scope':'CPU-only verifier rejection using copied actual GPU evidence; no engine or GPU launched','cases':checks},indent=2)+'\n');print(report.read_text())
