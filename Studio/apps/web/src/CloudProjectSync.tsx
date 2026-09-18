import {useEffect,useRef,useState} from 'react';
import type {ProjectSnapshot} from '@dora-studio/contracts';
import type {LocalWorkspace,CloudSyncRecord} from './workspace';
import {startCloudUpload,resumeCloudUpload} from './cloud-project-sync';
import {CloudProjectError,loadCloudProject} from './cloud-project-client';

const time=(value:number)=>new Intl.DateTimeFormat('zh-CN',{year:'numeric',month:'2-digit',day:'2-digit',hour:'2-digit',minute:'2-digit'}).format(value);
type Remote=Awaited<ReturnType<typeof loadCloudProject>>;

export function CloudProjectSync({store,accountId,name,snapshot,localUpdatedAt,disabled,onResolveRemote,onAttentionChange,onSynchronized}:{store:LocalWorkspace;accountId:string;name:string;snapshot:ProjectSnapshot;localUpdatedAt:number;disabled:boolean;onResolveRemote:(remote:Remote,useRemote:boolean)=>Promise<void>;onAttentionChange?:(attention:boolean)=>void;onSynchronized?:()=>void}){
 const [record,setRecord]=useState<CloudSyncRecord>(),[ready,setReady]=useState(false),[running,setRunning]=useState(false),[message,setMessage]=useState(''),[failed,setFailed]=useState(false),[remote,setRemote]=useState<Remote>(),[retry,setRetry]=useState(0);
 const active=useRef(true),busy=useRef(false),controller=useRef(new AbortController());
 useEffect(()=>{
  active.current=true;const operation=new AbortController();controller.current=operation;
  void store.cloudSync(accountId,snapshot.projectId).then(value=>{if(!operation.signal.aborted){setRecord(value);setReady(true);}}).catch(()=>{if(!operation.signal.aborted)setMessage('无法读取自动同步状态，请重新打开项目。');});
  return()=>{active.current=false;operation.abort();};
 },[store,accountId,snapshot.projectId,snapshot.revision,retry]);
 async function upload(){
  if(busy.current||!ready||disabled)return;busy.current=true;setRunning(true);setFailed(false);setRemote(undefined);setMessage('正在自动保存…');
  try{
   let current=record;
   if(!current?.pending){
    try{
     const latest=await loadCloudProject(snapshot.projectId,controller.current.signal,accountId);
     if(latest.cloudRevision>(current?.cloudRevision??0)&&latest.updatedAt>localUpdatedAt){
      if(active.current){setFailed(true);setRemote(latest);setMessage(`其他设备上的内容更新于 ${time(latest.updatedAt)}，比当前浏览器 ${time(localUpdatedAt)} 更新。`);}return;
     }
     if(!current){current=await store.bindCloudBaseline(accountId,snapshot.projectId,latest.cloudRevision);if(active.current)setRecord(current);}
    }catch(error){if(!(error instanceof CloudProjectError&&error.status===404))throw error;}
   }
   await (current?.pending?resumeCloudUpload(store,accountId,snapshot.projectId,controller.current.signal):startCloudUpload(store,accountId,snapshot,controller.current.signal,name));
   if(active.current){setMessage('');onSynchronized?.();}
  }catch(error){
   if(active.current){
    if(error instanceof CloudProjectError&&error.code==='revision-conflict'){
     try{const latest=await loadCloudProject(snapshot.projectId,controller.current.signal,accountId);if(active.current){setRemote(latest);setMessage(`其他设备上的内容更新于 ${time(latest.updatedAt)}，请选择保留哪一份。`);}}catch{setMessage('其他设备上的内容有更新，但暂时无法读取；请稍后重试。');}
    }else setMessage('自动保存失败，前端工作区内容仍安全保留。');
    setFailed(true);
   }
  }finally{
   if(active.current){try{const next=await store.cloudSync(accountId,snapshot.projectId);if(active.current)setRecord(next);}catch{if(active.current){setReady(false);setMessage('无法核对自动保存状态，请重新打开项目。');}}if(active.current)setRunning(false);}
   busy.current=false;
  }
 }
 useEffect(()=>{
  if(!ready||running||disabled||failed)return;
  if(record?.pending||record?.syncedLocalRevision!==snapshot.revision)void upload();
  else setMessage('');
 // upload is intentionally driven only by persisted snapshot/record transitions.
 // eslint-disable-next-line react-hooks/exhaustive-deps
 },[ready,running,disabled,failed,record?.pending?.requestId,record?.syncedLocalRevision,snapshot.revision]);
 useEffect(()=>{onAttentionChange?.(failed);return()=>onAttentionChange?.(false);},[failed,onAttentionChange]);
 async function resolve(useRemote:boolean){
  if(!remote||busy.current||disabled)return;busy.current=true;setRunning(true);
  try{await onResolveRemote(remote,useRemote);if(active.current){setRemote(undefined);setFailed(false);setMessage(useRemote?'':'已保留当前内容，正在自动保存…');onSynchronized?.();setRetry(value=>value+1);}}
  catch{if(active.current)setMessage('处理其他设备上的更新失败，当前工作区内容未被覆盖，请重试。');}
  finally{busy.current=false;if(active.current)setRunning(false);}
 }
 if(ready&&!running&&!failed&&!remote&&!message)return null;
 return <div className={`sync-status ${failed?'failed':''}`}><span role="status">{message||(!ready?'正在读取自动保存状态…':'正在自动保存…')}</span>{failed&&!remote&&<button disabled={running||disabled} onClick={()=>{setFailed(false);setRetry(value=>value+1);}}>{running?'正在重试…':'重试'}</button>}{remote&&<div className="remote-choice" role="alertdialog" aria-label="其他设备上的内容较新"><p>使用较新内容会更新当前工作区，当前浏览器中的内容会先自动保留到历史记录。</p><button disabled={running||disabled} onClick={()=>void resolve(false)}>保留当前内容</button><button className="primary" disabled={running||disabled} onClick={()=>void resolve(true)}>使用较新内容</button></div>}</div>;
}
