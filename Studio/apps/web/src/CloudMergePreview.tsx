import {useStudioI18n} from './i18n';
import {useContext,useEffect,useRef,useState} from 'react';
import {CloudMergeAction} from './cloud-merge-action';
import type {ProjectFile,ProjectSnapshot} from '@dora-studio/contracts';
import type {LocalWorkspace} from './workspace';
import {previewCloudMerge} from './cloud-merge-preview';
import {resolveCloudMerge,type ConflictResolution,type FileChoice} from './cloud-merge-resolution';
function FileContent({file}:{file:ProjectFile|null}){
  const {t} = useStudioI18n();
 return !file?<p>{t('projects.missingMergeFile')}</p>:file.kind==='binary'?<p>{t('projects.binarySize', {count: file.bytes.length})}</p>:<pre style={{whiteSpace:'pre-wrap',overflowWrap:'anywhere',maxHeight:220,overflow:'auto'}}>{file.text.length>16000?file.text.slice(0,16000)+t('projects.truncatedPreview'):file.text||t('projects.emptyFile')}</pre>;}
export function CloudMergePreview({store,accountId,snapshot,disabled}:{store:LocalWorkspace;accountId:string;snapshot:ProjectSnapshot;disabled:boolean}){
  const {t} = useStudioI18n();
 const [open,setOpen]=useState(false);
 useEffect(()=>setOpen(false),[snapshot.revision]);
 return <><button disabled={disabled} onClick={()=>setOpen(true)}>{t('projects.chooseRemoteVersion')}</button>{open&&<PreviewDialog key={snapshot.revision} store={store} accountId={accountId} snapshot={snapshot} onClose={()=>setOpen(false)}/>}</>;
}
function PreviewDialog({store,accountId,snapshot,onClose}:{store:LocalWorkspace;accountId:string;snapshot:ProjectSnapshot;onClose:()=>void}){
  const {t} = useStudioI18n();
 const dialog=useRef<HTMLDialogElement>(null),[result,setResult]=useState<Awaited<ReturnType<typeof previewCloudMerge>>>(),[failed,setFailed]=useState(false);
 useEffect(()=>{
  const controller=new AbortController();dialog.current?.showModal();
  void previewCloudMerge(store,accountId,snapshot,controller.signal).then(value=>{if(!controller.signal.aborted)setResult(value);}).catch(()=>{if(!controller.signal.aborted)setFailed(true);});
  return()=>{controller.abort();dialog.current?.close();};
 },[store,accountId,snapshot]);
 return <dialog ref={dialog} className="model-settings-dialog" aria-label={t('projects.compareCloud')} onCancel={event=>{event.preventDefault();onClose();}}><header><h2>{t('projects.compareCloud')}</h2><button autoFocus onClick={onClose}>{t('projects.closeCloudComparison')}</button></header><div className="model-settings">
  <p>{t('projects.compareCloudNote')}</p>
  {!result?<p role="status">{failed?t('projects.compareCloudFailed'):t('projects.loadingCloudComparison')}</p>:<>
   <p>{t('projects.mergeVersions', {local: result.localRevision, base: result.baseCloudRevision, remote: result.remoteCloudRevision})}</p>
   <p role="status">{t('projects.fileConflicts', {count: result.plan.conflicts.length, entry: t(result.plan.entryConflict?'projects.entryConflict':'projects.entryMatches')})}</p>
   {result.plan.entryConflict&&<p>{t('projects.entryVersions', {...result.plan.entryConflict})}</p>}
   {result.plan.conflicts.map(conflict=><details key={conflict.path}><summary>{conflict.path}</summary><h3>{t('projects.baseline')}</h3><FileContent file={conflict.base}/><h3>{t('projects.local')}</h3><FileContent file={conflict.local}/><h3>{t('projects.cloud')}</h3><FileContent file={conflict.remote}/></details>)}
   {!!result.plan.validationErrors.length&&<p>{result.plan.conflicts.length?t('projects.conflictFileNote'):''}{t('projects.invalidCandidate', {errors: result.plan.validationErrors.join('; ')})}</p>}
   <details><summary>{t('projects.mergeableFiles', {count: result.plan.files.length})}</summary>{result.plan.files.map(file=><details key={file.path}><summary>{file.path}</summary><FileContent file={file}/></details>)}</details>
   <ResolutionEditor result={result}/>
  </>}
 </div></dialog>;
}
function ResolutionEditor({result}:{result:Awaited<ReturnType<typeof previewCloudMerge>>}){
  const {t} = useStudioI18n();
 const apply=useContext(CloudMergeAction),lock=useRef(false);const [saving,setSaving]=useState(false),[failure,setFailure]=useState(false);
 const [choices,setChoices]=useState(new Map<string,ConflictResolution>()),[entry,setEntry]=useState<FileChoice>();
 const choose=(path:string,value:ConflictResolution|undefined)=>setChoices(previous=>{const next=new Map(previous);if(value===undefined)next.delete(path);else next.set(path,value);return next;});
 let candidate:ProjectSnapshot|undefined,error='';
 try{candidate=resolveCloudMerge(result.base,result.local,result.remote,choices,entry);}catch(cause){error=cause instanceof Error?cause.message:t('projects.candidateUnavailable');}
 return <section aria-label={t('projects.mergeCandidate')}><h3>{t('projects.resolveConflicts')}</h3><p>{t('projects.mergeChoiceNote')}</p><fieldset disabled={saving} style={{border:0,padding:0,minWidth:0}}>
  {result.plan.conflicts.map(conflict=>{const choice=choices.get(conflict.path),mode=typeof choice==='string'?choice:choice?.kind??'';return <fieldset key={conflict.path} style={{minWidth:0}}><legend style={{overflowWrap:'anywhere'}}>{conflict.path}</legend>
   <label>{t('projects.resolution')}<select aria-label={t('projects.resolutionFor', {path: conflict.path})} value={mode} onChange={event=>{const value=event.target.value;choose(conflict.path,value==='local'||value==='remote'?value:value==='text'?{kind:'text',text:conflict.local?.kind==='text'?conflict.local.text:''}:value==='both'?{kind:'both',remotePath:''}:undefined);}}>
    <option value="">{t('projects.choose')}</option><option value="local">{t(conflict.local?'projects.useLocal':'projects.useLocalDelete')}</option><option value="remote">{t(conflict.remote?'projects.useCloud':'projects.useCloudDelete')}</option>
    {conflict.local?.kind==='text'&&conflict.remote?.kind==='text'&&<option value="text">{t('projects.mergeText')}</option>}
    {conflict.local?.kind==='binary'&&conflict.remote?.kind==='binary'&&<option value="both">{t('projects.keepBoth')}</option>}
   </select></label>
   {typeof choice==='object'&&choice.kind==='text'&&<textarea aria-label={t('projects.mergeTextFor', {path: conflict.path})} style={{width:'100%',boxSizing:'border-box',minHeight:160}} value={choice.text} onChange={event=>choose(conflict.path,{kind:'text',text:event.target.value})}/>}
   {typeof choice==='object'&&choice.kind==='both'&&<label>{t('projects.cloudCopyPath')}<input aria-label={t('projects.cloudCopyPathFor', {path: conflict.path})} value={choice.remotePath} onChange={event=>choose(conflict.path,{kind:'both',remotePath:event.target.value})}/></label>}
  </fieldset>;})}
  {result.plan.entryConflict&&<label>{t('projects.chooseEntry')}<select aria-label={t('projects.resolveEntry')} value={entry??''} onChange={event=>setEntry(event.target.value==='local'?'local':event.target.value==='remote'?'remote':undefined)}><option value="">{t('projects.choose')}</option><option value="local">{t('projects.localEntry')}</option><option value="remote">{t('projects.cloudEntry')}</option></select></label>}
  <p role="status">{candidate?t('projects.candidateValid', {count: candidate.files.length}):t('projects.candidateInvalid', {error: error})}</p>
  </fieldset><button disabled={!candidate||!apply||saving} onClick={()=>{
   if(!apply||lock.current)return;lock.current=true;setSaving(true);setFailure(false);
   void apply(result,choices,entry).catch(()=>setFailure(true)).finally(()=>{lock.current=false;setSaving(false);});
  }}>{saving?t('projects.savingMerge'):t('projects.saveMerge')}</button>{failure&&<p role="alert">{t('projects.mergeUnconfirmed')}</p>}
 </section>;
}
