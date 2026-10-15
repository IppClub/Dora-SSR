import type {ProjectSnapshot} from '@dora-studio/contracts';
import {proposeAgentWriteback} from './agent-project-reconcile';
import {LocalWorkspace,WorkspaceError} from './workspace';

/** Local author commit only. Caller retains Agent quiescence until a separate
 * host baseline/persistence acknowledgement; never automatically retry conflicts. */
export async function commitAgentWriteback(store:LocalWorkspace,baseline:ProjectSnapshot,current:readonly {path:string;bytes:Uint8Array}[]) {
  // Own inputs before the first asynchronous storage read.
  const base=structuredClone(baseline),captured=structuredClone(current);
  const author=await store.load(base.projectId);
  if(!author)throw new WorkspaceError('conflict','Author project no longer exists');
  const proposal=proposeAgentWriteback(base,author.snapshot,captured);
  if(!proposal.changed)return {project:author,committed:false as const};
  const project=await store.save(author.name,{...proposal.snapshot,revision:proposal.expectedRevision+1},proposal.expectedRevision,true);
  return {project,committed:true as const};
}
