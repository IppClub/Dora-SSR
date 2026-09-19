import {useContext,useEffect,useRef,useState} from 'react';
import {CloudMergeAction} from './cloud-merge-action';
import type {ProjectFile,ProjectSnapshot} from '@dora-studio/contracts';
import type {LocalWorkspace} from './workspace';
import {previewCloudMerge} from './cloud-merge-preview';
import {resolveCloudMerge,type ConflictResolution,type FileChoice} from './cloud-merge-resolution';
function FileContent({file}:{file:ProjectFile|null}){return !file?<p>文件不存在（新增前或已删除）</p>:file.kind==='binary'?<p>二进制 · {file.bytes.length} 字节</p>:<pre style={{whiteSpace:'pre-wrap',overflowWrap:'anywhere',maxHeight:220,overflow:'auto'}}>{file.text.length>16000?file.text.slice(0,16000)+'\n…预览已截断，完整内容仍保留':file.text||'（空文件）'}</pre>;}
export function CloudMergePreview({store,accountId,snapshot,disabled}:{store:LocalWorkspace;accountId:string;snapshot:ProjectSnapshot;disabled:boolean}){
 const [open,setOpen]=useState(false);
 useEffect(()=>setOpen(false),[snapshot.revision]);
 return <><button disabled={disabled} onClick={()=>setOpen(true)}>远端有更新 · 选择版本</button>{open&&<PreviewDialog key={snapshot.revision} store={store} accountId={accountId} snapshot={snapshot} onClose={()=>setOpen(false)}/>}</>;
}
function PreviewDialog({store,accountId,snapshot,onClose}:{store:LocalWorkspace;accountId:string;snapshot:ProjectSnapshot;onClose:()=>void}){
 const dialog=useRef<HTMLDialogElement>(null),[result,setResult]=useState<Awaited<ReturnType<typeof previewCloudMerge>>>(),[failed,setFailed]=useState(false);
 useEffect(()=>{
  const controller=new AbortController();dialog.current?.showModal();
  void previewCloudMerge(store,accountId,snapshot,controller.signal).then(value=>{if(!controller.signal.aborted)setResult(value);}).catch(()=>{if(!controller.signal.aborted)setFailed(true);});
  return()=>{controller.abort();dialog.current?.close();};
 },[store,accountId,snapshot]);
 return <dialog ref={dialog} className="model-settings-dialog" aria-label="云端更新比较" onCancel={event=>{event.preventDefault();onClose();}}><header><h2>云端更新比较</h2><button autoFocus onClick={onClose}>关闭云端比较</button></header><div className="model-settings">
  <p>检测到其他设备上的内容比当前浏览器更新。查看差异后决定是否采用较新内容；关闭窗口不会修改当前工作区。</p>
  {!result?<p role="status">{failed?'无法比较，请核对账号、云基线及待确认上传后重试。':'正在读取基线与云端版本…'}</p>:<>
   <p>本地 r{result.localRevision} · 共同基线 v{result.baseCloudRevision} · 云端 v{result.remoteCloudRevision}</p>
   <p role="status">{result.plan.conflicts.length} 个文件冲突 · {result.plan.entryConflict?'存在入口冲突':'入口无冲突'}</p>
   {result.plan.entryConflict&&<p>入口：基线 {result.plan.entryConflict.base} / 本地 {result.plan.entryConflict.local} / 云端 {result.plan.entryConflict.remote}</p>}
   {result.plan.conflicts.map(conflict=><details key={conflict.path}><summary>{conflict.path}</summary><h3>共同基线</h3><FileContent file={conflict.base}/><h3>本地</h3><FileContent file={conflict.local}/><h3>云端</h3><FileContent file={conflict.remote}/></details>)}
   {!!result.plan.validationErrors.length&&<p>{result.plan.conflicts.length?'冲突文件尚未纳入候选结果，不代表原项目损坏。':''}候选结构尚不可保存：{result.plan.validationErrors.join('；')}</p>}
   <details><summary>可组合文件（{result.plan.files.length}）</summary>{result.plan.files.map(file=><details key={file.path}><summary>{file.path}</summary><FileContent file={file}/></details>)}</details>
   <ResolutionEditor result={result}/>
  </>}
 </div></dialog>;
}
function ResolutionEditor({result}:{result:Awaited<ReturnType<typeof previewCloudMerge>>}){
 const apply=useContext(CloudMergeAction),lock=useRef(false);const [saving,setSaving]=useState(false),[failure,setFailure]=useState('');
 const [choices,setChoices]=useState(new Map<string,ConflictResolution>()),[entry,setEntry]=useState<FileChoice>();
 const choose=(path:string,value:ConflictResolution|undefined)=>setChoices(previous=>{const next=new Map(previous);if(value===undefined)next.delete(path);else next.set(path,value);return next;});
 let candidate:ProjectSnapshot|undefined,error='';
 try{candidate=resolveCloudMerge(result.base,result.local,result.remote,choices,entry);}catch(cause){error=cause instanceof Error?cause.message:'无法生成候选';}
 return <section aria-label="冲突解决候选"><h3>解决冲突</h3><p>点击保存前，选择仅保留在本窗口。</p><fieldset disabled={saving} style={{border:0,padding:0,minWidth:0}}>
  {result.plan.conflicts.map(conflict=>{const choice=choices.get(conflict.path),mode=typeof choice==='string'?choice:choice?.kind??'';return <fieldset key={conflict.path} style={{minWidth:0}}><legend style={{overflowWrap:'anywhere'}}>{conflict.path}</legend>
   <label>解决方式<select aria-label={`解决方式 ${conflict.path}`} value={mode} onChange={event=>{const value=event.target.value;choose(conflict.path,value==='local'||value==='remote'?value:value==='text'?{kind:'text',text:conflict.local?.kind==='text'?conflict.local.text:''}:value==='both'?{kind:'both',remotePath:''}:undefined);}}>
    <option value="">请选择</option><option value="local">使用本地{conflict.local?'':'（删除）'}</option><option value="remote">使用云端{conflict.remote?'':'（删除）'}</option>
    {conflict.local?.kind==='text'&&conflict.remote?.kind==='text'&&<option value="text">手工合并文本</option>}
    {conflict.local?.kind==='binary'&&conflict.remote?.kind==='binary'&&<option value="both">保留双方二进制</option>}
   </select></label>
   {typeof choice==='object'&&choice.kind==='text'&&<textarea aria-label={`合并文本 ${conflict.path}`} style={{width:'100%',boxSizing:'border-box',minHeight:160}} value={choice.text} onChange={event=>choose(conflict.path,{kind:'text',text:event.target.value})}/>}
   {typeof choice==='object'&&choice.kind==='both'&&<label>云端文件另存路径<input aria-label={`云端另存路径 ${conflict.path}`} value={choice.remotePath} onChange={event=>choose(conflict.path,{kind:'both',remotePath:event.target.value})}/></label>}
  </fieldset>;})}
  {result.plan.entryConflict&&<label>入口选择<select aria-label="入口冲突选择" value={entry??''} onChange={event=>setEntry(event.target.value==='local'?'local':event.target.value==='remote'?'remote':undefined)}><option value="">请选择</option><option value="local">本地入口</option><option value="remote">云端入口</option></select></label>}
  <p role="status">{candidate?`候选校验通过 · ${candidate.files.length} 个文件；尚未保存`:`候选尚未就绪：${error}`}</p>
  </fieldset><button disabled={!candidate||!apply||saving} onClick={()=>{
   if(!apply||lock.current)return;lock.current=true;setSaving(true);setFailure('');
   void apply(result,choices,entry).catch(()=>setFailure('合并未能确认保存，请重新读取本地项目和云基线核对，不要重复提交。')).finally(()=>{lock.current=false;setSaving(false);});
  }}>{saving?'正在保存合并…':'保存合并到本机'}</button>{failure&&<p role="alert">{failure}</p>}
 </section>;
}
