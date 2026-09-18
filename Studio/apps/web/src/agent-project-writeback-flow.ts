import type {ProjectSnapshot} from '@dora-studio/contracts';
import type {AgentProjectCapture} from './agent-project-capture';
import type {LocalProject,LocalWorkspace} from './workspace';
import {commitAgentWriteback} from './agent-project-writeback';

interface WritebackHost {
  projectId:string;
  captureProject(signal:AbortSignal):Promise<AgentProjectCapture>;
  syncProject(snapshot:ProjectSnapshot,signal:AbortSignal):Promise<void>;
}
export type AgentWritebackResult={project:LocalProject;committed:boolean;hostConfirmed:boolean};
const activeProjects=new WeakMap<LocalWorkspace,Set<string>>();

/** Caller serializes workspace navigation/edits and supplies the acknowledged
 * baseline. Keeps Agent paused; cloud sync and model execution are not included. */
export async function reconcileAgentProject(store:LocalWorkspace,host:WritebackHost,baseline:ProjectSnapshot,signal:AbortSignal):Promise<AgentWritebackResult> {
  if(host.projectId!==baseline.projectId)throw new Error('Agent writeback project mismatch');
  const projectId=baseline.projectId;
  let active=activeProjects.get(store);
  if(!active){active=new Set();activeProjects.set(store,active);}
  if(active.has(projectId))throw new Error('Agent project writeback already in progress');
  active.add(projectId);
  try{return await performWriteback(store,host,baseline,signal);}
  finally{active.delete(projectId);}
}

async function performWriteback(store:LocalWorkspace,host:WritebackHost,baseline:ProjectSnapshot,signal:AbortSignal):Promise<AgentWritebackResult> {
  const base=structuredClone(baseline);
  signal.throwIfAborted();
  const captured=await host.captureProject(signal);
  signal.throwIfAborted();
  if(captured.projectId!==base.projectId||captured.reconciliationRequired!==true)throw new Error('Invalid captured project');
  const saved=await commitAgentWriteback(store,base,captured.files);
  // From this point failure must carry the committed author version. A cancelled
  // or failed host acknowledgement must never masquerade as an author rollback.
  try{
    signal.throwIfAborted();
    await host.syncProject(saved.project.snapshot,signal);
    signal.throwIfAborted();
    return {...saved,hostConfirmed:true};
  }catch{return {...saved,hostConfirmed:false};}
}
