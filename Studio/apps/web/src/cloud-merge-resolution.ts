import {validateSnapshot,isProjectPath,type ProjectSnapshot} from '@dora-studio/contracts';
import {planCloudMerge} from './cloud-project-merge';
export type FileChoice='local'|'remote';
export type ConflictResolution=FileChoice|{kind:'text';text:string}|{kind:'both';remotePath:string};
/** Recompute from original inputs; do not trust a mutable UI candidate list.
 * Choosing a null side explicitly accepts deletion. No default winner. */
export function resolveCloudMerge(base:ProjectSnapshot,local:ProjectSnapshot,remote:ProjectSnapshot,choices:ReadonlyMap<string,ConflictResolution>,entryChoice?:FileChoice):ProjectSnapshot{
 const plan=planCloudMerge(base,local,remote);
 const paths=new Set(plan.conflicts.map(conflict=>conflict.path));
 if([...choices.keys()].some(path=>!paths.has(path)))throw new Error('Unknown conflict choice');
 const files=[...plan.files];
 for(const conflict of plan.conflicts){
  const choice=choices.get(conflict.path);
  if(choice&&typeof choice==='object'){
   if(choice.kind==='text'){
    if(typeof choice.text!=='string'||conflict.local?.kind!=='text'||conflict.remote?.kind!=='text')throw new Error('Manual text resolution requires two text files');
    files.push({path:conflict.path,kind:'text',text:choice.text});continue;
   }
   if(choice.kind==='both'){
    if(conflict.local?.kind!=='binary'||conflict.remote?.kind!=='binary'||!isProjectPath(choice.remotePath)||choice.remotePath===conflict.path)throw new Error('Keep both requires binary files and a new path');
    if([...base.files,...local.files,...remote.files].some(file=>file.path===choice.remotePath))throw new Error('Keep both destination already exists');
    files.push(structuredClone(conflict.local),{...structuredClone(conflict.remote),path:choice.remotePath});continue;
   }
   throw new Error('Invalid conflict resolution');
  }
  if(choice!=='local'&&choice!=='remote')throw new Error('Unresolved file conflict');
  const selected=conflict[choice];if(selected)files.push(structuredClone(selected));
 }
 let entry=plan.entry;
 if(plan.entryConflict){
  if(entryChoice!=='local'&&entryChoice!=='remote')throw new Error('Unresolved entry conflict');
  entry=plan.entryConflict[entryChoice];
 }else if(entryChoice!==undefined)throw new Error('Unexpected entry choice');
 if(!entry||local.revision>=Number.MAX_SAFE_INTEGER)throw new Error('Invalid resolved revision or entry');
 const snapshot:ProjectSnapshot={version:local.version,projectId:local.projectId,revision:local.revision+1,entry,files:files.sort((a,b)=>a.path<b.path?-1:a.path>b.path?1:0)};
 const errors=validateSnapshot(snapshot);if(errors.length)throw new Error(`Invalid resolved structure: ${errors.join('; ')}`);
 return snapshot;
}
