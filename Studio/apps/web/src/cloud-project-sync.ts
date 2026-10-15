import type {ProjectSnapshot} from '@dora-studio/contracts';
import type {LocalWorkspace} from './workspace';
import {uploadCloudProject,CloudProjectError} from './cloud-project-client';
type Storage=Pick<LocalWorkspace,'prepareCloudUpload'|'cloudSync'|'confirmCloudUpload'|'rejectCloudUpload'>;
/** Explicit dispatch only. Persisted pending requests survive failures; retries
 * must use resumeCloudUpload rather than preparing a different snapshot. */
export async function startCloudUpload(storage:Storage,accountId:string,snapshot:ProjectSnapshot,signal:AbortSignal,name:string){
 signal.throwIfAborted();
 const projectId=snapshot.projectId;
 await storage.prepareCloudUpload(accountId,snapshot,crypto.randomUUID(),name);
 return resumeCloudUpload(storage,accountId,projectId,signal);
}
export async function resumeCloudUpload(storage:Storage,accountId:string,projectId:string,signal:AbortSignal){
 signal.throwIfAborted();
 const record=await storage.cloudSync(accountId,projectId);
 signal.throwIfAborted();
 if(!record?.pending||record.accountId!==accountId||record.projectId!==projectId||record.pending.snapshot.projectId!==projectId)throw new Error('No matching pending cloud upload');
 const {requestId,snapshot,name}=record.pending;
 let receipt;
 try{receipt=await uploadCloudProject(accountId,snapshot,record.cloudRevision,requestId,signal,name);}
 catch(error){
  if(error instanceof CloudProjectError&&error.status===409&&error.code==='revision-conflict')await storage.rejectCloudUpload(accountId,projectId,requestId);
  throw error;
 }
 // Once the server receipt is known, finish bookkeeping for its original owner
 // even if the view changed. UI must independently ignore obsolete completion.
 await storage.confirmCloudUpload(accountId,projectId,requestId,receipt.cloudRevision);
 return {cloudRevision:receipt.cloudRevision,localRevision:snapshot.revision,replayed:receipt.replayed};
}
