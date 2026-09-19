import {validateSnapshot,type ProjectSnapshot,type ProjectFile} from '@dora-studio/contracts';
import {prepareAgentProjectSnapshot} from './agent-project-snapshot';
import {matchesInstalledAgentProject,type AgentProjectFS} from './agent-project-install';

const recordPath='/user/.studio-author-baseline.json';
const root='/user/studio-project';

/** The next IDBFS barrier must include both files and this record. */
export async function writeAgentProjectBaseline(fs:AgentProjectFS,snapshot:ProjectSnapshot,signal:AbortSignal) {
  const prepared=await prepareAgentProjectSnapshot(snapshot,snapshot.projectId,signal);
  const bytes=new TextEncoder().encode(JSON.stringify({version:1,projectId:prepared.projectId,revision:prepared.revision,entry:prepared.entry,manifest:prepared.manifest}));
  if(bytes.length>2*1024*1024)throw new Error('Agent baseline exceeds limit');
  signal.throwIfAborted();
  const temporary=recordPath+'.'+crypto.randomUUID();
  try{fs.writeFile(temporary,bytes);fs.rename(temporary,recordPath);}
  catch(error){try{fs.unlink(temporary);}catch{/* Keep original failure. */}throw error;}
}

/** A changed tree returns its revision floor but no overwrite baseline.
 * A malformed record fails closed instead of being treated as a new project.
 */
export async function readAgentProjectBaseline(fs:AgentProjectFS,projectId:string,signal:AbortSignal):Promise<{revision:number;snapshot?:ProjectSnapshot}|undefined> {
  signal.throwIfAborted();
  if(!fs.analyzePath(recordPath).exists)return;
  const stat=fs.lstat(recordPath);
  if(!fs.isFile(stat.mode)||stat.size>2*1024*1024)throw new Error('Invalid Agent baseline file');
  const record=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(fs.readFile(recordPath)));
  if(!record || record.version!==1 || record.projectId!==projectId || !Array.isArray(record.manifest) || record.manifest.length>4096)throw new Error('Invalid Agent baseline');
  const manifest=record.manifest as {path:string;kind:'text'|'binary';size:number;sha256:string}[];
  let total=0;
  for(const file of manifest){
    if(!file || !['text','binary'].includes(file.kind) || !Number.isSafeInteger(file.size) || file.size<0 || file.size>64*1024*1024
      || (total+=file.size)>256*1024*1024 || typeof file.sha256!=='string' || !/^[a-f0-9]{64}$/.test(file.sha256))throw new Error('Invalid Agent baseline manifest');
  }
  const shape={version:1,projectId,revision:record.revision,entry:record.entry,files:manifest.map(file=>file.kind==='text'?{path:file.path,kind:'text',text:''}:{path:file.path,kind:'binary',bytes:new Uint8Array()})};
  if(validateSnapshot(shape).length || manifest.some(file=>file.path==='.agent'||file.path.startsWith('.agent/')))throw new Error('Invalid Agent baseline project');
  const changed={revision:record.revision as number};
  const files:ProjectFile[]=[];
  for(const file of manifest){
    signal.throwIfAborted();
    let bytes:Uint8Array<ArrayBuffer>;
    try{
      let parent=root;
      for(const part of file.path.split('/').slice(0,-1)){
        if(!fs.isDir(fs.lstat(parent).mode))return changed;
        parent+='/'+part;
      }
      if(!fs.isDir(fs.lstat(parent).mode))return changed;
      const path=root+'/'+file.path,stat=fs.lstat(path);
      if(!fs.isFile(stat.mode)||stat.size!==file.size)return changed;
      bytes=new Uint8Array(fs.readFile(path));
    }catch{return changed;}
    const hash=await crypto.subtle.digest('SHA-256',bytes);
    signal.throwIfAborted();
    if([...new Uint8Array(hash)].map(byte=>byte.toString(16).padStart(2,'0')).join('')!==file.sha256)return changed;
    files.push(file.kind==='text'?{path:file.path,kind:'text',text:new TextDecoder('utf-8',{fatal:true,ignoreBOM:true}).decode(bytes)}:{path:file.path,kind:'binary',bytes});
  }
  signal.throwIfAborted();
  const snapshot:ProjectSnapshot={version:1,projectId,revision:record.revision,entry:record.entry,files};
  return matchesInstalledAgentProject(fs,snapshot)?{...changed,snapshot}:changed;
}
