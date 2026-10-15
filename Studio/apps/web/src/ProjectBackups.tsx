import {useEffect,useRef,useState} from 'react';
import {loadCloudProject,listCloudHistory} from './cloud-project-client';
import {exportProject} from './project-export';

const time=(value:number)=>new Intl.DateTimeFormat('zh-CN',{year:'numeric',month:'2-digit',day:'2-digit',hour:'2-digit',minute:'2-digit'}).format(value);

export function ProjectBackups({accountId,projectId}:{accountId:string;projectId:string}){
 return <div className="cloud-project-backups"><BackupDownload accountId={accountId} projectId={projectId}/></div>;
}

function BackupDownload({accountId,projectId,revision,updatedAt}:{accountId:string;projectId:string;revision?:number;updatedAt?:number}){
 const context=useRef({controller:new AbortController(),busy:false});const [status,setStatus]=useState(''),[busy,setBusy]=useState(false);
 useEffect(()=>{const current=context.current;return()=>current.controller.abort();},[]);
 return <><button disabled={busy} onClick={()=>{
  const current=context.current;if(current.busy||current.controller.signal.aborted)return;current.busy=true;setBusy(true);setStatus('正在下载项目备份…');
  void (async()=>{try{
   const result=await loadCloudProject(projectId,current.controller.signal,accountId,revision);
   const bytes=await exportProject(`项目 ${projectId}`.slice(0,200),result.snapshot);
   current.controller.signal.throwIfAborted();
   const url=URL.createObjectURL(new Blob([new Uint8Array(bytes)],{type:'application/zip'}));
   const stamp=new Date(result.updatedAt).toISOString().replace(/[:.]/g,'-');
   const link=document.createElement('a');link.href=url;link.download=`dora-project-${stamp}.zip`;link.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
   setStatus(`已下载 ${time(result.updatedAt)} 的项目备份`);
  }catch{if(!current.controller.signal.aborted)setStatus('下载失败，请稍后重试。');}
  finally{current.busy=false;if(!current.controller.signal.aborted)setBusy(false);}})();
 }}>{revision===undefined?'下载项目备份 ZIP':`下载 ${time(updatedAt??0)} 的内容`}</button>{status&&<span role="status">{status}</span>}{revision===undefined&&<BackupHistory accountId={accountId} projectId={projectId}/>}</>;
}

function BackupHistory({accountId,projectId}:{accountId:string;projectId:string}){
 const [open,setOpen]=useState(false),[after,setAfter]=useState(0),[page,setPage]=useState<Awaited<ReturnType<typeof listCloudHistory>>>(),[failed,setFailed]=useState(false);
 useEffect(()=>{const controller=new AbortController();setPage(undefined);setFailed(false);
  if(open)void listCloudHistory(projectId,accountId,controller.signal,after).then(value=>{if(!controller.signal.aborted)setPage(value);}).catch(()=>{if(!controller.signal.aborted)setFailed(true);});
  return()=>controller.abort();
 },[accountId,projectId,open,after]);
 return <><button aria-expanded={open} onClick={()=>setOpen(value=>!value)}>项目备份历史</button>{open&&<section aria-label={`项目备份历史 ${projectId}`}><p>按更新时间下载历史内容，不改变当前项目。</p>{!page?<p role="status">{failed?'无法读取历史，请关闭后重试。':'正在读取历史…'}</p>:<>{page.items.map(item=><div key={item.cloudRevision}><BackupDownload accountId={accountId} projectId={projectId} revision={item.cloudRevision} updatedAt={item.updatedAt}/></div>)}{!page.items.length&&<p>没有历史备份。</p>}{after>0&&<button onClick={()=>setAfter(0)}>返回历史首页</button>}{page.nextCursor!==null&&<button onClick={()=>setAfter(page.nextCursor!)}>下一页历史</button>}</>}</section>}</>;
}
