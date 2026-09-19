export type AgentTaskTerminal='DONE'|'FAILED'|'STOPPED';
/** The first-prompt writeback gate observes the original main task, not a
 * completed assistant step, a sub Agent or a stale previous task. */
export function initialPromptTerminal(session:{kind:'main'|'sub';currentTaskId?:number;status:string;currentTaskStatus?:string},taskId:number):AgentTaskTerminal|undefined{
  if(!Number.isSafeInteger(taskId)||taskId<1||session.kind!=='main'||session.currentTaskId!==taskId)return undefined;
  if(!['DONE','FAILED','STOPPED'].includes(session.status)||session.currentTaskStatus!==undefined&&session.currentTaskStatus!==session.status)return undefined;
  return session.status as AgentTaskTerminal;
}

/** Every terminal task is safe to reconcile. Failed or user-stopped tasks may
 * still contain useful committed file checkpoints and must not remain hidden. */
export function shouldAutoWriteback(status:AgentTaskTerminal|undefined):status is AgentTaskTerminal{
  return status==='DONE'||status==='FAILED'||status==='STOPPED';
}
