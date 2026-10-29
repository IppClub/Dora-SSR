"""Verify an intentional lazy import trap releases exported native Object handles."""
import argparse, hashlib, json, re
from pathlib import Path


def verify(case):
    execution=json.loads((case/'execution.json').read_text())
    assert execution['native_exit_code']==2, 'Expected fixture failure exit 2, not a crash or singleton activation'
    log=(case/'run.log').read_text()
    assert 'GODOT_FFI_OWNERSHIP node_created=1 extra_retains=2 explicit_releases=1' in log
    errors=[line for line in log.splitlines() if re.search(r'\[(?:error|critical|warning)\]|ERROR:|WARNING:',line)]
    assert len(errors)==1 and "missing imported function: 'dora.object_to_spritX'" in errors[0],errors
    assert not any(token in log for token in ['C++ objects leaks','BGFX LEAK:','Metal Validation Error','MTLCommandBufferError'])
    destroyed=[name.strip() for group in re.findall(r'destroy: ([^\r\n]+)\.',log) for name in group.split(',')]
    for name in ['WasmRuntime','Director','BGFXDora','Logger']: assert destroyed.count(name)==1,(name,destroyed)
    assert destroyed.index('WasmRuntime')<destroyed.index('Director')<destroyed.index('BGFXDora')<destroyed.index('Logger')
    clients=re.findall(r'GodotRuntime (?:client closed|shutdown): produced=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
    readers=re.findall(r'GodotRuntime readers: buffers=(\d+), frames=(\d+), waits=(\d+), signals=(\d+), pending=(\d+), completed=(\d+), gpuErrors=(\d+)',log)
    assert len(clients)==len(readers)==1,(clients,readers)
    produced,completed,errors=map(int,clients[0]);assert produced==completed and errors==0
    slots,frames,waits,signals,pending,completed,errors=map(int,readers[0]);assert slots==3 and frames==completed and pending==errors==0 and 0<=waits<=signals==frames*slots
    audio=re.findall(r'GodotAudio drained: produced=(\d+), consumed=(\d+), nonzeroProduced=(\d+), nonzeroConsumed=(\d+), underrunFrames=(\d+)',log)
    assert len(audio)==1
    produced,consumed,nonzero,played,underruns=map(int,audio[0]);assert produced>=consumed>=0 and underruns==0 and 0<=nonzero<=produced*2 and 0<=played<=consumed*2
    for name,digest in execution['artifacts'].items():assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==digest,name
    return {'passed':True,'scope':'Actual Wa initializer lazy-import trap after repeated native Object retains and one release; remaining exported Object references reclaimed, GPU/PCM drained, full native shutdown. Does not cover every non-Object FFI heap allocation.','native_exit_code':2,'gpu_clients':clients,'gpu_readers':readers,'audio':audio,'execution_sha256':hashlib.sha256((case/'execution.json').read_bytes()).hexdigest(),'log_sha256':hashlib.sha256((case/'run.log').read_bytes()).hexdigest()}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('case',type=Path);a=p.parse_args()
    output=a.case/'ownership-verification.json';output.unlink(missing_ok=True)
    report=verify(a.case);output.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
