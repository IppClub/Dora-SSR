import type {AgentQuiescence} from './agent-quiescence';

/** Caller owns exclusive lifecycle access. Keeps the native admission hold on
 * success and failure; does not destroy the runtime or claim cloud reconciliation.
 */
export async function persistStoppedAgent(
  source:{quiesce(signal:AbortSignal):Promise<AgentQuiescence>},
  storage:{doraSyncUserStorage(options:{afterCurrent:true}):Promise<unknown>},
  signal:AbortSignal,
  timeoutMs=15000,
):Promise<void> {
  if (!Number.isFinite(timeoutMs) || timeoutMs<=0 || timeoutMs>60000) throw new Error('Invalid Agent persistence timeout');
  const abort=new AbortController();
  const cancel=()=>abort.abort(signal.reason ?? new DOMException('Aborted','AbortError'));
  signal.addEventListener('abort',cancel,{once:true});
  if(signal.aborted)cancel();
  const timer=setTimeout(()=>abort.abort(new Error('Agent persistence timed out')),timeoutMs);
  const wait=<T>(work:()=>Promise<T>):Promise<T>=>new Promise((resolve,reject)=>{
    if(abort.signal.aborted){reject(abort.signal.reason);return;}
    const stopped=()=>{cleanup();reject(abort.signal.reason);};
    const cleanup=()=>abort.signal.removeEventListener('abort',stopped);
    abort.signal.addEventListener('abort',stopped,{once:true});
    Promise.resolve().then(()=>{
      if(abort.signal.aborted)throw abort.signal.reason;
      return work();
    }).then(value=>{cleanup();resolve(value);},error=>{cleanup();reject(error);});
  });
  const delay=()=>new Promise<void>(resolve=>{
    const done=()=>{clearTimeout(id);abort.signal.removeEventListener('abort',done);resolve();};
    const id=setTimeout(done,100);
    abort.signal.addEventListener('abort',done,{once:true});
  });
  try {
    for(;;){
      const state=await wait(()=>source.quiesce(abort.signal));
      if(state.quiescent && state.pending.length===0)break;
      await wait(delay);
    }
    await wait(()=>storage.doraSyncUserStorage({afterCurrent:true}));
    if(abort.signal.aborted)throw abort.signal.reason;
  } finally {
    clearTimeout(timer);signal.removeEventListener('abort',cancel);
    abort.abort(new Error('Agent persistence operation finished'));
  }
}
