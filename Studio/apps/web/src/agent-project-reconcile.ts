import {isProjectPath,validateSnapshot,type ProjectFile,type ProjectSnapshot} from '@dora-studio/contracts';

/** Produces a proposal only. The author store must compare-and-swap expectedRevision
 * when committing; this function neither saves nor acknowledges Agent changes. */
export function proposeAgentWriteback(baseline:ProjectSnapshot,author:ProjectSnapshot,current:readonly {path:string;bytes:Uint8Array}[]) {
  if(validateSnapshot(baseline).length||validateSnapshot(author).length)throw new Error('Invalid reconciliation snapshot');
  const encoder=new TextEncoder();
  const equal=(a:ProjectFile,b:ProjectFile)=>a.kind===b.kind && (a.kind==='text'&&b.kind==='text'?a.text===b.text:
    a.kind==='binary'&&b.kind==='binary'&&a.bytes.length===b.bytes.length&&a.bytes.every((v,i)=>v===b.bytes[i]));
  const originals=new Map(baseline.files.map(file=>[file.path,file]));
  if(baseline.projectId!==author.projectId||baseline.revision!==author.revision||baseline.entry!==author.entry||
    baseline.files.length!==author.files.length||author.files.some(file=>!originals.has(file.path)||!equal(file,originals.get(file.path)!)))
    throw new Error('Author project changed since Agent baseline');
  if(current.length>4096)throw new Error('Agent file count exceeded');
  const seen=new Set<string>();let total=0;
  const files:ProjectFile[]=current.map(file=>{
    if(!isProjectPath(file.path)||file.path==='.agent'||file.path.startsWith('.agent/')||seen.has(file.path)||!(file.bytes instanceof Uint8Array))throw new Error('Invalid Agent file');
    seen.add(file.path);
    if(file.bytes.length>64*1024*1024||(total+=file.bytes.length)>256*1024*1024)throw new Error('Agent file size exceeded');
    const bytes=new Uint8Array(file.bytes),original=originals.get(file.path);
    const kind=original?.kind??(/\.(lua|yue|tl|xml|tsx?|json|md|txt|csv|svg|vert|frag)$/i.test(file.path)?'text':'binary');
    if(kind==='binary')return {path:file.path,kind,bytes};
    const text=new TextDecoder('utf-8',{fatal:true,ignoreBOM:true}).decode(bytes);
    if(encoder.encode(text).length!==bytes.length)throw new Error('Agent text cannot round trip');
    return {path:file.path,kind,text};
  });
  const snapshot:ProjectSnapshot={...author,files};
  if(validateSnapshot(snapshot).length)throw new Error('Agent result has an invalid or missing entry');
  const changed=files.length!==baseline.files.length||files.some(file=>!originals.has(file.path)||!equal(file,originals.get(file.path)!));
  return {expectedRevision:author.revision,changed,snapshot};
}
