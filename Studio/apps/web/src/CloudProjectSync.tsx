import {type StudioMessage, useStudioI18n} from './i18n';
import {useEffect,useRef,useState} from 'react';
import type {ProjectSnapshot} from '@dora-studio/contracts';
import type {LocalWorkspace,CloudSyncRecord} from './workspace';
import {startCloudUpload,resumeCloudUpload} from './cloud-project-sync';
import {CloudProjectError,loadCloudProject} from './cloud-project-client';

type Remote=Awaited<ReturnType<typeof loadCloudProject>>;

export function CloudProjectSync({store,accountId,name,snapshot,localUpdatedAt,disabled,onResolveRemote,onAttentionChange,onSynchronized}:{store:LocalWorkspace;accountId:string;name:string;snapshot:ProjectSnapshot;localUpdatedAt:number;disabled:boolean;onResolveRemote:(remote:Remote,useRemote:boolean)=>Promise<void>;onAttentionChange?:(attention:boolean)=>void;onSynchronized?:()=>void}){
  const {t} = useStudioI18n();
 const [record,setRecord]=useState<CloudSyncRecord>(),[ready,setReady]=useState(false),[running,setRunning]=useState(false),[message,setMessage]=useState<StudioMessage>(),[failed,setFailed]=useState(false),[remote,setRemote]=useState<Remote>(),[retry,setRetry]=useState(0);
 const active=useRef(true),busy=useRef(false),controller=useRef(new AbortController());
 useEffect(()=>{
  active.current=true;const operation=new AbortController();controller.current=operation;
  void store.cloudSync(accountId,snapshot.projectId).then(value=>{if(!operation.signal.aborted){setRecord(value);setReady(true);}}).catch(()=>{if(!operation.signal.aborted)setMessage(['projects.autosaveStateFailed']);});
  return()=>{active.current=false;operation.abort();};
 },[store,accountId,snapshot.projectId,snapshot.revision,retry]);
 async function upload(){
  if(busy.current||!ready||disabled)return;busy.current=true;setRunning(true);setFailed(false);setRemote(undefined);setMessage(['projects.autosaving']);
  try{
   let current=record;
   if(!current?.pending){
    try{
     const latest=await loadCloudProject(snapshot.projectId,controller.current.signal,accountId);
     if(latest.cloudRevision>(current?.cloudRevision??0)&&latest.updatedAt>localUpdatedAt){
      if(active.current){setFailed(true);setRemote(latest);setMessage(['projects.remoteNewerAt', {remote: new Date(latest.updatedAt), local: new Date(localUpdatedAt)}]);}return;
     }
     if(!current){current=await store.bindCloudBaseline(accountId,snapshot.projectId,latest.cloudRevision);if(active.current)setRecord(current);}
    }catch(error){if(!(error instanceof CloudProjectError&&error.status===404))throw error;}
   }
   await (current?.pending?resumeCloudUpload(store,accountId,snapshot.projectId,controller.current.signal):startCloudUpload(store,accountId,snapshot,controller.current.signal,name));
   if(active.current){setMessage(undefined);onSynchronized?.();}
  }catch(error){
   if(active.current){
    if(error instanceof CloudProjectError&&error.code==='revision-conflict'){
     try{const latest=await loadCloudProject(snapshot.projectId,controller.current.signal,accountId);if(active.current){setRemote(latest);setMessage(['projects.chooseRemoteAt', {date: new Date(latest.updatedAt)}]);}}catch{setMessage(['projects.remoteLoadFailed']);}
    }else setMessage(['projects.autosaveFailed']);
    setFailed(true);
   }
  }finally{
   if(active.current){try{const next=await store.cloudSync(accountId,snapshot.projectId);if(active.current)setRecord(next);}catch{if(active.current){setReady(false);setMessage(['projects.autosaveVerifyFailed']);}}if(active.current)setRunning(false);}
   busy.current=false;
  }
 }
 useEffect(()=>{
  if(!ready||running||disabled||failed)return;
  if(record?.pending||record?.syncedLocalRevision!==snapshot.revision)void upload();
  else setMessage(undefined);
 // upload is intentionally driven only by persisted snapshot/record transitions.
 // eslint-disable-next-line react-hooks/exhaustive-deps
 },[ready,running,disabled,failed,record?.pending?.requestId,record?.syncedLocalRevision,snapshot.revision]);
 useEffect(()=>{onAttentionChange?.(failed);return()=>onAttentionChange?.(false);},[failed,onAttentionChange]);
 async function resolve(useRemote:boolean){
  if(!remote||busy.current||disabled)return;busy.current=true;setRunning(true);
  try{await onResolveRemote(remote,useRemote);if(active.current){setRemote(undefined);setFailed(false);setMessage(useRemote?undefined:['projects.keptCurrent']);onSynchronized?.();setRetry(value=>value+1);}}
  catch{if(active.current)setMessage(['projects.resolveRemoteFailed']);}
  finally{busy.current=false;if(active.current)setRunning(false);}
 }
 if(ready&&!running&&!failed&&!remote&&!message)return null;
 return <div className={`sync-status ${failed?'failed':''}`}><span role="status">{message?t(...message):(!ready?t('projects.loadingAutosave'):t('projects.autosaving'))}</span>{failed&&!remote&&<button disabled={running||disabled} onClick={()=>{setFailed(false);setRetry(value=>value+1);}}>{running?t('projects.retrying'):t('projects.retry')}</button>}{remote&&<div className="remote-choice" role="alertdialog" aria-label={t('projects.remoteNewer')}><p>{t('projects.remoteHistoryNote')}</p><button disabled={running||disabled} onClick={()=>void resolve(false)}>{t('projects.keepCurrent')}</button><button className="primary" disabled={running||disabled} onClick={()=>void resolve(true)}>{t('projects.useNewer')}</button></div>}</div>;
}
