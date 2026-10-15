export type AgentModelQueueState={version:1;state:'idle'}|{version:1;state:'queued';queuedAt:number;position:number};
export interface AgentModelQueueStore {getSnapshot:()=>AgentModelQueueState;subscribe:(listener:()=>void)=>()=>void}
export const idleAgentModelQueue:AgentModelQueueState={version:1,state:'idle'};

export function decodeAgentModelQueue(value:unknown):AgentModelQueueState{
  if(!value||typeof value!=='object'||Array.isArray(value))throw new Error('Invalid Agent model queue state');
  const state=value as Record<string,unknown>;
  if(state.version!==1)return (()=>{throw new Error('Invalid Agent model queue state');})();
  if(state.state==='idle')return idleAgentModelQueue;
  if(state.state==='queued'&&Number.isSafeInteger(state.queuedAt)&&Number(state.queuedAt)>0&&Number.isSafeInteger(state.position)&&Number(state.position)>0)
    return {version:1,state:'queued',queuedAt:Number(state.queuedAt),position:Number(state.position)};
  throw new Error('Invalid Agent model queue state');
}

export function createAgentModelQueueStore(initial:unknown=idleAgentModelQueue):AgentModelQueueStore&{update:(value:unknown)=>void}{
  let current=decodeAgentModelQueue(initial);const listeners=new Set<()=>void>();
  return {getSnapshot:()=>current,subscribe(listener){listeners.add(listener);return()=>listeners.delete(listener);},update(value){
    const next=decodeAgentModelQueue(value);
    if(next.state===current.state&&(next.state==='idle'||(current.state==='queued'&&next.queuedAt===current.queuedAt&&next.position===current.position)))return;
    current=next;for(const listener of listeners)listener();
  }};
}
