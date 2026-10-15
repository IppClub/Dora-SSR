import {validateSnapshot,type ProjectSnapshot} from '@dora-studio/contracts';
import type {LocalWorkspace} from './workspace';
import {loadCloudProject} from './cloud-project-client';
import {planCloudMerge} from './cloud-project-merge';
/** Read-only plan. The eventual apply transaction must still recheck local and
 * cloud bases; this result is not authorization to overwrite newer work. */
export async function previewCloudMerge(store:Pick<LocalWorkspace,'cloudSync'>,accountId:string,input:ProjectSnapshot,signal:AbortSignal){
 signal.throwIfAborted();if(validateSnapshot(input).length)throw new Error('Invalid local snapshot');
 const local=structuredClone(input),binding=await store.cloudSync(accountId,local.projectId);
 if(!binding||binding.accountId!==accountId||binding.projectId!==local.projectId||binding.cloudRevision<1||binding.pending)throw new Error('Resolve cloud binding before comparison');
 const [base,remote]=await Promise.all([loadCloudProject(local.projectId,signal,accountId,binding.cloudRevision),loadCloudProject(local.projectId,signal,accountId)]);
 signal.throwIfAborted();
 const current=await store.cloudSync(accountId,local.projectId);
 if(!current||current.pending||current.cloudRevision!==binding.cloudRevision||remote.cloudRevision<binding.cloudRevision)throw new Error('Cloud binding changed during comparison');
 return {accountId,projectId:local.projectId,localRevision:local.revision,baseCloudRevision:base.cloudRevision,remoteCloudRevision:remote.cloudRevision,base:base.snapshot,local,remote:remote.snapshot,plan:planCloudMerge(base.snapshot,local,remote.snapshot)};
}
