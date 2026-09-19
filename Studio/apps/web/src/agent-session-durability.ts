import type {AgentSessionSource} from './agent-session-port-host';
import {decodeAgentSessionPatch} from './agent-session-decode';

export type DurableAgentSessionSource=AgentSessionSource&{waitForDurability():Promise<void>};

/**
 * Externally visible resumable boundaries must reach persistent storage before
 * Studio publishes or acknowledges them. Otherwise a page reload can erase an
 * accepted Code task or a pending/resumed Plan questionnaire from the history.
 */
export function persistSessionBoundariesBeforePublish(
  source:AgentSessionSource,
  persist:()=>Promise<unknown>,
  signal:AbortSignal,
):DurableAgentSessionSource {
  let barrier:Promise<void>=Promise.resolve();
  return {
    waitForDurability:()=>barrier,
    async capture(captureSignal){
      await barrier;
      captureSignal.throwIfAborted();
      return source.capture(captureSignal);
    },
    subscribe(listener,onClose){
      let active=true,failed=false;
      const close=()=>{
        if(!active||failed)return;
        failed=true;active=false;onClose?.();
      };
      const unsubscribe=source.subscribe((payload,sequence)=>{
        let needsPersistence=false;
        try{
          const patch=decodeAgentSessionPatch(payload);
          const running=patch.session?.currentTaskStatus==='RUNNING';
          needsPersistence=!!patch.pendingQuestionnaire
            || (running&&(patch.message?.role==='user'||patch.pendingQuestionnaire===false));
        }catch{close();return;}
        barrier=barrier.then(async()=>{
          signal.throwIfAborted();
          if(needsPersistence)await persist();
          signal.throwIfAborted();
          if(active)listener(payload,sequence);
        }).catch(close);
      },close);
      return()=>{if(!active)return;active=false;unsubscribe();};
    },
  };
}
