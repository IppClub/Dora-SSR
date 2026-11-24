import type {ProjectMessageKey} from './locales';
import {ProjectMessageError} from './project-messages';
import type {LocalProject,LocalWorkspace} from './workspace';
import {resumeCloudUpload,startCloudUpload} from './cloud-project-sync';
import {CloudProjectError,loadCloudProject} from './cloud-project-client';

type Store=Pick<LocalWorkspace,'load'|'save'|'cloudSync'|'bindCloudBaseline'|'acceptCloudBaseline'|'prepareCloudUpload'|'confirmCloudUpload'|'rejectCloudUpload'>;
type RemoteProject=Awaited<ReturnType<typeof loadCloudProject>>;
export type ProjectOpenStage={value:number;label:ProjectMessageKey};
interface ProjectOpenSyncDependencies{
 loadRemote?:(projectId:string,signal:AbortSignal,accountId:string)=>Promise<RemoteProject|undefined>;
 resumeUpload?:(store:Store,accountId:string,projectId:string,signal:AbortSignal)=>Promise<unknown>;
 startUpload?:(store:Store,accountId:string,project:LocalProject,signal:AbortSignal)=>Promise<unknown>;
}

export interface ProjectOpenSyncRequest{
 store:Store;
 projectId:string;
 accountId?:string;
 signal:AbortSignal;
 progress:(stage:ProjectOpenStage)=>void;
 chooseNewer:(remote:RemoteProject,local:LocalProject)=>Promise<boolean>;
}

/** Resolve one project identity before the editable workspace becomes active. */
async function readRemote(projectId:string,signal:AbortSignal,accountId:string):Promise<RemoteProject|undefined>{
 try{return await loadCloudProject(projectId,signal,accountId);}
 catch(error){if(error instanceof CloudProjectError&&error.status===404)return undefined;throw error;}
}

export async function synchronizeProjectForOpen(request:ProjectOpenSyncRequest,dependencies:ProjectOpenSyncDependencies={}):Promise<LocalProject>{
 const {store,projectId,accountId,signal,progress,chooseNewer}=request;
 const loadRemote=dependencies.loadRemote??readRemote;
 const resumeUpload=dependencies.resumeUpload??((target,owner,id,operation)=>resumeCloudUpload(target as LocalWorkspace,owner,id,operation));
 const startUpload=dependencies.startUpload??((target,owner,current,operation)=>startCloudUpload(target as LocalWorkspace,owner,current.snapshot,operation,current.name));
 signal.throwIfAborted();
 let local=await store.load(projectId);
 if(!accountId){if(!local)throw new ProjectMessageError('projects.signInToSync');return local;}

 progress({value:18,label:'projects.checkingUpdates'});
 let remote:RemoteProject|undefined;
 remote=await loadRemote(projectId,signal,accountId);

 if(!remote){
  if(!local)throw new ProjectMessageError('projects.projectMissing');
  const record=await store.cloudSync(accountId,projectId);
  progress({value:62,label:'projects.savingProjectContent'});
  if(record?.pending)await resumeUpload(store,accountId,projectId,signal);
  else if(record&&record.cloudRevision>0)throw new ProjectMessageError('projects.syncedProjectMissing');
  else if(record?.syncedLocalRevision!==local.snapshot.revision)await startUpload(store,accountId,local,signal);
  return (await store.load(projectId))??local;
 }

 if(!local){
  progress({value:76,label:'projects.savingInBrowser'});
  return store.save(remote.name,{...remote.snapshot,revision:0},null,false,undefined,{accountId,cloudRevision:remote.cloudRevision});
 }

 let record=await store.cloudSync(accountId,projectId);
 if(record?.pending){
  progress({value:44,label:'projects.finishingLastSync'});
  await resumeUpload(store,accountId,projectId,signal);
  record=await store.cloudSync(accountId,projectId);
  progress({value:55,label:'projects.recheckingUpdates'});
  const refreshed=await loadRemote(projectId,signal,accountId);
  if(!refreshed)throw new ProjectMessageError('projects.syncedProjectUnreadable');
  remote=refreshed;
 }
 if(record&&remote.cloudRevision<record.cloudRevision)throw new ProjectMessageError('projects.staleRemoteRevision');
 const knownCloudRevision=record?.cloudRevision??0;
 if(!record)record=await store.bindCloudBaseline(accountId,projectId,remote.cloudRevision);

 const remoteAdvanced=remote.cloudRevision>knownCloudRevision;
 const useRemote=remoteAdvanced&&remote.updatedAt>local.updatedAt?await chooseNewer(remote,local):false;
 if(remoteAdvanced||useRemote){
  await store.acceptCloudBaseline(accountId,projectId,remote.cloudRevision);
  if(useRemote){
   progress({value:78,label:'projects.applyingNewer'});
   return store.save(remote.name,{...remote.snapshot,projectId,revision:local.snapshot.revision+1},local.snapshot.revision,true,undefined,undefined,{accountId,expectedCloudRevision:remote.cloudRevision,cloudRevision:remote.cloudRevision,synced:true});
  }
  record=await store.cloudSync(accountId,projectId);
 }
 if(record?.syncedLocalRevision!==local.snapshot.revision){
  progress({value:76,label:'projects.savingCurrent'});
  await startUpload(store,accountId,local,signal);
 }
 progress({value:94,label:'projects.finishingOpen'});
 return (await store.load(projectId))??local;
}
