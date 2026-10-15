import {validateSnapshot,type ProjectFile,type ProjectSnapshot} from '@dora-studio/contracts';
import {mergeCloudText} from './cloud-text-merge';
export interface CloudFileConflict {path:string;base:ProjectFile|null;local:ProjectFile|null;remote:ProjectFile|null}
export interface CloudMergePlan {files:ProjectFile[];conflicts:CloudFileConflict[];entry:string|null;entryConflict:{base:string;local:string;remote:string}|null;validationErrors:string[]}
function same(a:ProjectFile|undefined,b:ProjectFile|undefined):boolean{
 if(!a||!b)return a===b;
 if(a.kind!==b.kind)return false;
 if(a.kind==='text'&&b.kind==='text')return a.text===b.text;
 return a.kind==='binary'&&b.kind==='binary'&&a.bytes.length===b.bytes.length&&a.bytes.every((value,index)=>value===b.bytes[index]);
}
/** Three-way plan. Never writes or inserts conflict markers into source. */
export function planCloudMerge(base:ProjectSnapshot,local:ProjectSnapshot,remote:ProjectSnapshot):CloudMergePlan{
 if([base,local,remote].some(snapshot=>validateSnapshot(snapshot).length)||base.projectId!==local.projectId||base.projectId!==remote.projectId)throw new Error('Invalid cloud merge snapshots');
 const maps=[base,local,remote].map(snapshot=>new Map(snapshot.files.map(file=>[file.path,file])));
 const paths=new Set([...base.files,...local.files,...remote.files].map(file=>file.path));
 const files:ProjectFile[]=[],conflicts:CloudFileConflict[]=[];
 for(const path of [...paths].sort()){
  const original=maps[0]!.get(path),left=maps[1]!.get(path),right=maps[2]!.get(path);
  let selected:ProjectFile|undefined;
  if(same(left,right))selected=left;
  else if(same(left,original))selected=right;
  else if(same(right,original))selected=left;
  else{
   const merged=original?.kind==='text'&&left?.kind==='text'&&right?.kind==='text'?mergeCloudText(original.text,left.text,right.text):null;
   if(merged!==null)selected={path,kind:'text',text:merged};
   else{conflicts.push(structuredClone({path,base:original??null,local:left??null,remote:right??null}));continue;}
  }
  if(selected)files.push(structuredClone(selected));
 }
 const entry=local.entry===remote.entry?local.entry:local.entry===base.entry?remote.entry:remote.entry===base.entry?local.entry:null;
 const entryConflict=entry===null?{base:base.entry,local:local.entry,remote:remote.entry}:null;
 // Combined edits can introduce path collisions or remove the selected entry,
 // even if every individual input is valid. Such plans are not savable yet.
 const validationErrors=entry===null?['entry conflict']:validateSnapshot({...local,entry,files});
 return {files,conflicts,entry,entryConflict,validationErrors};
}
