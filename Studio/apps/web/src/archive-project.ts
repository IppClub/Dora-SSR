import {authoredProjectFiles,validateProjectArchive,validateSnapshot,type ProjectArchive,type ProjectFile,type ProjectSnapshot} from '@dora-studio/contracts';
export function archiveEntryCandidates(archive:ProjectArchive):string[] {
  if(validateProjectArchive(archive).length)throw new Error('归档数据无效');
  return authoredProjectFiles(archive.files).filter(file=>/\.(lua|yue|tl|xml|tsx?)$/i.test(file.path)).map(file=>file.path);
}
/** Explicit entry selection, new identity, unchanged paths and original archive. */
export function createArchiveProject(archive:ProjectArchive,entry:string):ProjectSnapshot {
  if(!archiveEntryCandidates(archive).includes(entry))throw new Error('请选择归档中的源码入口');
  const decoder=new TextDecoder('utf-8',{fatal:true,ignoreBOM:true});
  const files:ProjectFile[]=archive.files.map(file=>{
    if(file.kind==='text')return {...file};
    if(/\.(lua|yue|tl|xml|tsx?|json|md|txt|csv|svg|vert|frag)$/i.test(file.path)){
      try{return {path:file.path,kind:'text',text:decoder.decode(file.bytes)};}
      catch{if(file.path===entry)throw new Error('所选入口不是有效 UTF-8 源码；原归档仍保留');}
    }
    return {path:file.path,kind:'binary',bytes:new Uint8Array(file.bytes)};
  });
  const snapshot:ProjectSnapshot={version:1,projectId:crypto.randomUUID(),revision:0,entry,files};
  const errors=validateSnapshot(snapshot);if(errors.length)throw new Error(errors.join('; '));return snapshot;
}
