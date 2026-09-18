export interface AgentQuiescence {
  quiescent:boolean;
  pending:Array<{sessionId:number;taskId:number;finalizing:boolean;stopRequested:boolean;message?:string}>;
}

/** Called only after the enclosing session snapshot has passed its size/schema checks. */
export function decodeAgentQuiescence(value:unknown):AgentQuiescence {
  const state=value as Record<string,unknown>|null;
  if (!state || state.success!==true || typeof state.quiescent!=='boolean' || !Array.isArray(state.pending)
    || state.quiescent !== (state.pending.length===0)) throw new Error('Invalid Agent quiescence result');
  const ids=new Set<number>();
  const pending=state.pending.map(item=>{
    if (!item || !Number.isSafeInteger(item.sessionId) || item.sessionId<=0 || !Number.isSafeInteger(item.taskId) || item.taskId<=0
      || ids.has(item.taskId) || typeof item.finalizing!=='boolean' || typeof item.stopRequested!=='boolean'
      || (item.finalizing && item.stopRequested) || (item.message!==undefined && typeof item.message!=='string')) throw new Error('Invalid pending Agent task');
    ids.add(item.taskId);
    return {sessionId:item.sessionId,taskId:item.taskId,finalizing:item.finalizing,stopRequested:item.stopRequested,...(item.message!==undefined?{message:item.message}:{})};
  });
  return {quiescent:state.quiescent,pending};
}
