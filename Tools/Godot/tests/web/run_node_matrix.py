#!/usr/bin/env python3
"""Run real Dora GodotNode cases in separate owned packages and browsers."""
import argparse,json,shutil,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[4];source=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--package',type=Path,default=root/'build/godot-web/dora-player');p.add_argument('--output',type=Path,default=root/'build/godot-web/node-matrix');p.add_argument('--buffers',type=int,nargs='+',choices=[2,3,4],default=[2,3,4]);a=p.parse_args()
a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=True);report=a.output/'verification.json';report.unlink(missing_ok=True);cases=[]
for buffers in a.buffers:
 package=a.output/('player-'+str(buffers));result=a.output/('case-'+str(buffers))
 shutil.copytree(a.package.resolve(),package,dirs_exist_ok=True)
 subprocess.run(['python3',str(source/'prepare_node_game.py'),'--buffers',str(buffers),'--package',str(package)],check=True,cwd=root)
 subprocess.run(['node',str(source/'run_node.cjs'),str(package),str(result)],check=True,cwd=root)
 subprocess.run(['python3',str(source/'verify_node.py'),str(result),'--buffers',str(buffers)],check=True,cwd=root)
 data=json.loads((result/'verification.json').read_text());cases.append({'buffers':buffers,'report':str(result/'verification.json'),'controller_frames':data['controller_frames'],'captures':len(data['captures'])})
report.write_text(json.dumps({'passed':True,'scope':'Actual Dora GodotNode Web with controller button/axis/focus-release and post-stop platform-service teardown acceptance for listed buffer counts only; latency/DOM input/other browser coverage pending','cases':cases},indent=2)+'\n')
