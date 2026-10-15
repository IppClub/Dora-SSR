import {isProjectPath} from '@dora-studio/contracts';

export interface AgentFileCommitQueue {
  reconciliationRequired:true;
  overflowed:boolean;
  batches:{version:1;taskId:number;checkpointId:number;checkpointSeq:number;changes:{path:string;op:'create'|'write'|'delete'}[]}[];
}

/** Notifications are hints backed by original checkpoints, never save receipts. */
export function decodeAgentFileCommitQueue(value:unknown):AgentFileCommitQueue {
  const data=value as Record<string,unknown>|null;
  if(!data || data.reconciliationRequired!==true || typeof data.overflowed!=='boolean')throw new Error('Invalid Agent file commit queue');
  // Lua encodes an empty table as {}; only that exact empty form is accepted.
  const raw=data.batches;
  const batches=Array.isArray(raw)?raw:raw && typeof raw==='object' && (Object.getPrototypeOf(raw)===Object.prototype||Object.getPrototypeOf(raw)===null) && Object.keys(raw).length===0?[]:undefined;
  if(!batches || batches.length>32 || new TextEncoder().encode(JSON.stringify(value)).length>131072)throw new Error('Agent file commit queue exceeds bounds');
  const ids=new Set<number>();
  const positive=(id:unknown):id is number=>Number.isSafeInteger(id)&&(id as number)>0;
  const decoded=batches.map(batch=>{
    if(!batch || batch.version!==1 || !positive(batch.taskId) || !positive(batch.checkpointId) || !positive(batch.checkpointSeq)
      || ids.has(batch.checkpointId) || !Array.isArray(batch.changes) || !batch.changes.length || batch.changes.length>4096)throw new Error('Invalid Agent file commit batch');
    ids.add(batch.checkpointId);
    const paths=new Set<string>();
    const changes=batch.changes.map((change:{path:unknown;op:unknown})=>{
      if(!change || !isProjectPath(change.path) || paths.has(change.path) || !['create','write','delete'].includes(change.op as string))throw new Error('Invalid Agent committed path');
      paths.add(change.path);return {path:change.path,op:change.op as 'create'|'write'|'delete'};
    });
    return {version:1 as const,taskId:batch.taskId,checkpointId:batch.checkpointId,checkpointSeq:batch.checkpointSeq,changes};
  });
  return {reconciliationRequired:true,overflowed:data.overflowed,batches:decoded};
}
