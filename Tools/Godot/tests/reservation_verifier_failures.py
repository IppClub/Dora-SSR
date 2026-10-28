#!/usr/bin/env python3
"""Verify ownership rejection gates using mutated copies of real passing evidence.

Requires a native test run with --reservation. Does not launch a GPU test.
"""
import argparse,json,shutil,subprocess,sys,tempfile
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--results',type=Path,required=True)
a=p.parse_args()
r=json.loads((a.results/'verification.json').read_text())
assert r['passed'] and r['competing_nodes_rejected_preserving_runtime'] and r['failed_nodes_absent_from_scene']
log=(a.results/'run.log').read_text(encoding='utf8',errors='replace')
mutations={
    'competing-create-accepted':('GODOT_NODE_RESERVATION stage=110 rejected=1','GODOT_NODE_RESERVATION stage=110 rejected=0'),
    'failed-node-adopted':('GODOT_NODE_RESERVATION_TREE stage=115 nodes=1','GODOT_NODE_RESERVATION_TREE stage=115 nodes=4'),
    'missing-probe':('GODOT_NODE_RESERVATION stage=570 rejected=1','REMOVED_PROBE'),
    'missing-tree-check':('GODOT_NODE_RESERVATION_TREE stage=575 nodes=1','REMOVED_TREE_CHECK'),
}
with tempfile.TemporaryDirectory(prefix='dora-godot-reservation-') as directory:
    evidence=Path(directory)
    for image in a.results.glob('*.png'):shutil.copy2(image,evidence/image.name)
    command=[sys.executable,str(Path(__file__).with_name('verify_macos.py')),'--results',str(evidence),'--platform',r['platform'],'--reservation']
    if r.get('retained_texture_aliases'):command+=['--aliases','--buffers',str(r['retained_texture_aliases'])]
    if r.get('godot_pcm_to_host_mixer_callback'):command+=['--audio']
    if r.get('audio_render_stalls_ms'):command+=['--audio-stall']
    if r.get('viewport_resize_dimensions'):command+=['--resize']
    if r.get('remove_during_resize'):command+=['--cancel-resize']
    if r.get('soak_frames'):command+=['--soak-frames',str(r['soak_frames'])]
    for name,(before,after) in mutations.items():
        assert log.count(before)==1,(name,'Missing native evidence marker')
        (evidence/'run.log').write_text(log.replace(before,after),encoding='utf8')
        report=evidence/'verification.json';report.write_text('{"passed":true}\n')
        result=subprocess.run(command,capture_output=True,text=True,timeout=30)
        assert result.returncode!=0 and not report.exists(),(name,result.stdout,result.stderr)
        assert 'ownership violated' in result.stderr or 'Failed nodes adopted' in result.stderr,(name,result.stderr)
print('Reservation verifier rejection: PASS; 4 mutated-evidence cases; no GPU test launched')
