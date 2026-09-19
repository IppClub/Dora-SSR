import {isProjectPath,validateSnapshot,type ProjectFile,type ProjectSnapshot} from '@dora-studio/contracts';

export type AgentProjectSnapshot=Awaited<ReturnType<typeof prepareAgentProjectSnapshot>>;

/** Author data, not a Player manifest: the receiver must never execute entry.
 * No destination paths or trusted-host files are inferred from this payload.
 */
export async function prepareAgentProjectSnapshot(input:ProjectSnapshot,projectId:string,signal:AbortSignal) {
  signal.throwIfAborted();
  if(validateSnapshot(input).length || input.projectId!==projectId)throw new Error('Invalid Agent author snapshot binding');
  if(input.files.length>4096)throw new Error('Agent author snapshot exceeds file limit');
  // Own bytes before any hashing awaits; caller edits cannot change this revision.
  const snapshot=structuredClone(input),encoder=new TextEncoder();
  let total=0;
  const files=snapshot.files.map(file=>{
    const bytes=file.kind==='text'?encoder.encode(file.text):new Uint8Array(file.bytes);
    total+=bytes.byteLength;
    if(bytes.byteLength>64*1024*1024 || total>256*1024*1024)throw new Error('Agent author snapshot exceeds byte limit');
    return {path:file.path,kind:file.kind,bytes};
  });
  const manifest=[];
  for(const file of files){
    signal.throwIfAborted();
    const hash=await crypto.subtle.digest('SHA-256',file.bytes);
    manifest.push({path:file.path,kind:file.kind,size:file.bytes.byteLength,sha256:[...new Uint8Array(hash)].map(byte=>byte.toString(16).padStart(2,'0')).join('')});
  }
  signal.throwIfAborted();
  return {version:1 as const,kind:'dora-agent-author-snapshot' as const,projectId:snapshot.projectId,revision:snapshot.revision,entry:snapshot.entry,manifest,files};
}

/** Validate again at the privileged receiver. The project ID must come from
 * the authenticated connection, not the payload. This grants no filesystem access.
 */
export async function decodeAgentProjectSnapshot(value:unknown,projectId:string,signal:AbortSignal):Promise<ProjectSnapshot> {
  signal.throwIfAborted();
  const data=value as Partial<AgentProjectSnapshot>|null;
  if(!data || data.version!==1 || data.kind!=='dora-agent-author-snapshot' || data.projectId!==projectId
    || !Number.isSafeInteger(data.revision) || (data.revision as number)<0 || !isProjectPath(data.entry)
    || !Array.isArray(data.files) || !Array.isArray(data.manifest) || data.files.length>4096
    || data.files.length!==data.manifest.length)throw new Error('Invalid Agent author envelope');
  let total=0;
  const paths=new Set<string>();
  // Validate bounded fields before copying; never clone arbitrary extra properties.
  const files=data.files.map((file,index)=>{
    const entry=data.manifest![index];
    if(!file || !entry || !isProjectPath(file.path) || paths.has(file.path) || !(file.bytes instanceof Uint8Array)
      || !['text','binary'].includes(file.kind) || entry.path!==file.path || entry.kind!==file.kind
      || entry.size!==file.bytes.byteLength || typeof entry.sha256!=='string' || !/^[a-f0-9]{64}$/.test(entry.sha256))throw new Error('Invalid Agent author file');
    paths.add(file.path);total+=file.bytes.byteLength;
    if(file.bytes.byteLength>64*1024*1024 || total>256*1024*1024)throw new Error('Agent author snapshot exceeds byte limit');
    return {path:file.path,kind:file.kind,bytes:new Uint8Array(file.bytes),sha256:entry.sha256};
  });
  const decoded:ProjectFile[]=[];
  const snapshot:ProjectSnapshot={version:1,projectId,revision:data.revision!,entry:data.entry!,files:decoded};
  for(const file of files){
    signal.throwIfAborted();
    const hash=await crypto.subtle.digest('SHA-256',file.bytes);
    if([...new Uint8Array(hash)].map(byte=>byte.toString(16).padStart(2,'0')).join('')!==file.sha256)throw new Error('Agent author integrity mismatch');
    decoded.push(file.kind==='text'?{path:file.path,kind:'text',text:new TextDecoder('utf-8',{fatal:true,ignoreBOM:true}).decode(file.bytes)}:{path:file.path,kind:'binary',bytes:file.bytes});
  }
  signal.throwIfAborted();
  if(validateSnapshot(snapshot).length)throw new Error('Invalid Agent author project');
  return snapshot;
}
