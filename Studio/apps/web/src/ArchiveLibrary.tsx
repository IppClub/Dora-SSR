import {useEffect,useRef,useState} from 'react';
import type {ProjectArchive} from '@dora-studio/contracts';
import type {LocalWorkspace,LocalArchive} from './workspace';
import {archiveEntryCandidates,createArchiveProject} from './archive-project';
import './archive-library.css';
type ArchiveRow=Awaited<ReturnType<LocalWorkspace['listArchives']>>[number];
export function ArchiveLibrary({store,onProjectCreated,offeredFile,onOfferedHandled}:{store:LocalWorkspace;onProjectCreated:()=>Promise<void>;offeredFile?:File|undefined;onOfferedHandled:(file:File)=>void}) {
  const [rows,setRows]=useState<ArchiveRow[]>([]),[message,setMessage]=useState(''),[busy,setBusy]=useState(false);
  const [source,setSource]=useState<LocalArchive>(),[entry,setEntry]=useState('');
  const live=useRef(false),locked=useRef(false);
  const details=useRef<HTMLDetailsElement>(null);
  useEffect(()=>{if(offeredFile&&details.current)details.current.open=true;},[offeredFile]);
  useEffect(()=>{live.current=true;void store.listArchives().then(value=>{if(live.current)setRows(value);},()=>{if(live.current)setMessage('归档列表暂时无法读取。');});return()=>{live.current=false;};},[store]);
  async function packageAPI(){
    await import(/* @vite-ignore */ `${import.meta.env.BASE_URL}web-package.js`);
    return (globalThis as unknown as {DoraWebPackage:{inspectArchive(file:File,options:{projectBackup:true}):Promise<{files:{path:string;data:Uint8Array}[]}>;createArchive(files:{path:string;data:Uint8Array}[]):Uint8Array}}).DoraWebPackage;
  }
  async function preserve(file:File|undefined){
    if(!file||locked.current)return;locked.current=true;setBusy(true);setMessage('');
    let committed=false;
    try{
      if(file.size>256*1024*1024)throw new Error('归档超过 256 MiB');
      const api=await packageAPI(),parsed=await api.inspectArchive(file,{projectBackup:true});
      if(!live.current)return;
      const archive:ProjectArchive={version:1,kind:'project-archive',projectId:crypto.randomUUID(),revision:0,entry:null,files:parsed.files.map(item=>({path:item.path,kind:'binary',bytes:new Uint8Array(item.data)}))};
      await store.preserveArchive(file.name.replace(/\.(zip|dora)$/i,'').trim().slice(0,200)||'待适配归档',archive);
      committed=true;
      if(live.current&&file===offeredFile)onOfferedHandled(file);
      const next=await store.listArchives();if(live.current){setRows(next);setMessage('原文件已保存在本机归档，尚未转为可编辑项目，也未执行。');}
    }catch(error){if(live.current)setMessage(committed?'归档已保存，但列表刷新失败。请重新打开页面查看，不要重复上传。':error instanceof Error?error.message:'归档保存失败');}
    finally{locked.current=false;if(live.current)setBusy(false);}
  }
  async function download(id:string){
    if(locked.current)return;locked.current=true;setBusy(true);setMessage('');
    try{
      const record=await store.loadArchive(id);if(!record)throw new Error('归档不存在');
      const api=await packageAPI();if(!live.current)return;
      const bytes=api.createArchive(record.archive.files.map(file=>({path:file.path,data:file.kind==='binary'?file.bytes:new TextEncoder().encode(file.text)})));
      const url=URL.createObjectURL(new Blob([new Uint8Array(bytes)],{type:'application/zip'}));
      const link=document.createElement('a');link.href=url;link.download=`${record.name.replace(/[\\/:*?"<>|\x00-\x1f]/g,'_')}.zip`;link.click();setTimeout(()=>URL.revokeObjectURL(url),10000);
    }catch(error){if(live.current)setMessage(error instanceof Error?error.message:'归档下载失败');}
    finally{locked.current=false;if(live.current)setBusy(false);}
  }
  async function choose(id:string){
    if(locked.current)return;locked.current=true;setBusy(true);setMessage('');
    try{const record=await store.loadArchive(id);if(!record)throw new Error('归档不存在');if(live.current){setSource(record);setEntry('');}}
    catch{if(live.current)setMessage('归档暂时无法读取。');}finally{locked.current=false;if(live.current)setBusy(false);}
  }
  async function promote(){
    if(!source||!entry||locked.current)return;locked.current=true;setBusy(true);setMessage('');
    let committed=false;
    try{const snapshot=createArchiveProject(source.archive,entry);await store.save(`${source.name.slice(0,190)} · 副本`,snapshot,null);committed=true;if(live.current){setSource(undefined);setEntry('');setMessage('可编辑副本已创建。请从项目列表打开；原归档和当前草稿均未修改。');}await onProjectCreated();}
    catch(error){if(live.current)setMessage(committed?'副本已创建，但项目列表刷新失败。请先保存当前草稿，再重新打开页面查看，不要重复创建。':error instanceof Error?error.message:'副本创建未完成');}finally{locked.current=false;if(live.current)setBusy(false);}
  }
  return <details ref={details} className="archive-library"><summary>待适配归档 · {rows.length}</summary><p className="hint">保持原路径和文件字节，不自动适配。包含源码时可选择入口创建独立副本；仅 Wasm 包暂不能编辑或试玩。</p>
    {offeredFile&&<div><span>{offeredFile.name}</span><button disabled={busy} onClick={()=>void preserve(offeredFile)}>保留本次上传</button><button disabled={busy} onClick={()=>onOfferedHandled(offeredFile)}>放弃本次上传</button></div>}
    <label className="hint">保留待适配 ZIP<input type="file" accept=".dora,.zip" aria-label="保留待适配 ZIP" disabled={busy} onChange={event=>{const file=event.target.files?.[0];event.target.value='';void preserve(file);}}/></label>
    {message&&<p role="status" className="hint">{message}</p>}
    {source&&<div><span>{source.name} · 选择副本入口</span>{archiveEntryCandidates(source.archive).length?<><label>源码入口<select aria-label="归档源码入口" disabled={busy} value={entry} onChange={event=>setEntry(event.target.value)}><option value="">请选择，不会自动猜测</option>{archiveEntryCandidates(source.archive).map(path=><option key={path} value={path}>{path}</option>)}</select></label><p className="hint">保留所有文件及路径；其他目录也会保留。选择入口不代表已验证运行。</p><button disabled={busy||!entry} onClick={()=>void promote()}>确认创建副本</button></>:<p className="hint">此归档没有可选择的源码入口；不会生成假的入口文件。</p>}<button disabled={busy} onClick={()=>setSource(undefined)}>取消选择</button></div>}
    {rows.map(row=><div key={row.projectId}><span>{row.name} · {row.fileCount} 个文件</span><button disabled={busy} onClick={()=>void download(row.projectId)} aria-label={`下载归档 ${row.name}`}>下载原文件 ZIP</button><button disabled={busy} onClick={()=>void choose(row.projectId)} aria-label={`创建归档副本 ${row.name}`}>创建可编辑副本</button></div>)}
  </details>;
}
