import {type StudioMessage, useStudioI18n} from './i18n';
import {useEffect,useRef,useState} from 'react';
import {loadCloudProject,listCloudHistory} from './cloud-project-client';
import {exportProject} from './project-export';


export function ProjectBackups({accountId,projectId}:{accountId:string;projectId:string}){
 return <div className="cloud-project-backups"><BackupDownload accountId={accountId} projectId={projectId}/></div>;
}

function BackupDownload({accountId,projectId,revision,updatedAt}:{accountId:string;projectId:string;revision?:number;updatedAt?:number}){
  const {t, date} = useStudioI18n();
 const context=useRef({controller:new AbortController(),busy:false});const [status,setStatus]=useState<StudioMessage>(),[busy,setBusy]=useState(false);
 useEffect(()=>{const current=context.current;return()=>current.controller.abort();},[]);
 return <><button disabled={busy} onClick={()=>{
  const current=context.current;if(current.busy||current.controller.signal.aborted)return;current.busy=true;setBusy(true);setStatus(['projects.downloadingBackup']);
  void (async()=>{try{
   const result=await loadCloudProject(projectId,current.controller.signal,accountId,revision);
   const bytes=await exportProject(t('projects.backupName', {id: projectId}).slice(0,200),result.snapshot);
   current.controller.signal.throwIfAborted();
   const url=URL.createObjectURL(new Blob([new Uint8Array(bytes)],{type:'application/zip'}));
   const stamp=new Date(result.updatedAt).toISOString().replace(/[:.]/g,'-');
   const link=document.createElement('a');link.href=url;link.download=`dora-project-${stamp}.zip`;link.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
   setStatus(['projects.backupDownloaded', {date: new Date(result.updatedAt)}]);
  }catch{if(!current.controller.signal.aborted)setStatus(['projects.backupDownloadFailed']);}
  finally{current.busy=false;if(!current.controller.signal.aborted)setBusy(false);}})();
 }}>{revision===undefined?t('projects.downloadBackup'):t('projects.downloadVersion', {date: date(updatedAt??0)})}</button>{status&&<span role="status">{t(...status)}</span>}{revision===undefined&&<BackupHistory accountId={accountId} projectId={projectId}/>}</>;
}

function BackupHistory({accountId,projectId}:{accountId:string;projectId:string}){
  const {t} = useStudioI18n();
 const [open,setOpen]=useState(false),[after,setAfter]=useState(0),[page,setPage]=useState<Awaited<ReturnType<typeof listCloudHistory>>>(),[failed,setFailed]=useState(false);
 useEffect(()=>{const controller=new AbortController();setPage(undefined);setFailed(false);
  if(open)void listCloudHistory(projectId,accountId,controller.signal,after).then(value=>{if(!controller.signal.aborted)setPage(value);}).catch(()=>{if(!controller.signal.aborted)setFailed(true);});
  return()=>controller.abort();
 },[accountId,projectId,open,after]);
 return <><button aria-expanded={open} onClick={()=>setOpen(value=>!value)}>{t('projects.backupHistory')}</button>{open&&<section aria-label={t('projects.backupHistoryFor', {id: projectId})}><p>{t('projects.backupHistoryNote')}</p>{!page?<p role="status">{failed?t('projects.backupHistoryFailed'):t('projects.loadingBackupHistory')}</p>:<>{page.items.map(item=><div key={item.cloudRevision}><BackupDownload accountId={accountId} projectId={projectId} revision={item.cloudRevision} updatedAt={item.updatedAt}/></div>)}{!page.items.length&&<p>{t('projects.noBackups')}</p>}{after>0&&<button onClick={()=>setAfter(0)}>{t('projects.firstBackupPage')}</button>}{page.nextCursor!==null&&<button onClick={()=>setAfter(page.nextCursor!)}>{t('projects.nextBackupPage')}</button>}</>}</section>}</>;
}
