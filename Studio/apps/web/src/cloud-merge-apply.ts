import type {LocalWorkspace} from './workspace';
import type {previewCloudMerge} from './cloud-merge-preview';
import {resolveCloudMerge,type ConflictResolution,type FileChoice} from './cloud-merge-resolution';
import {loadSession} from './session-client';
type Preview=Awaited<ReturnType<typeof previewCloudMerge>>;
/** Caller must quiesce editing/Agent work before invoking, then update its view
 * from the committed return value. Does not upload or claim remote freshness. */
export async function applyCloudMerge(store:Pick<LocalWorkspace,'load'|'save'>,preview:Preview,choices:ReadonlyMap<string,ConflictResolution>,entry:FileChoice|undefined,signal:AbortSignal){
 signal.throwIfAborted();
 const snapshot=resolveCloudMerge(preview.base,preview.local,preview.remote,choices,entry);
 if(snapshot.projectId!==preview.projectId||snapshot.revision!==preview.localRevision+1)throw new Error('Merge preview identity mismatch');
 if(await loadSession(signal)!==preview.accountId)throw new Error('Account changed before merge');
 const current=await store.load(preview.projectId);signal.throwIfAborted();
 if(!current||current.snapshot.revision!==preview.localRevision)throw new Error('Local project changed before merge');
 return store.save(current.name,snapshot,preview.localRevision,true,undefined,undefined,{accountId:preview.accountId,expectedCloudRevision:preview.baseCloudRevision,cloudRevision:preview.remoteCloudRevision});
}
