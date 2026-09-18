import {validateSnapshot,type ProjectSnapshot} from '@dora-studio/contracts';
export class CloudProjectError extends Error{constructor(readonly status:number,readonly code:string|null=null){super(`Cloud project request failed (${status})`);}}
const limit=32*1024*1024;
export async function listCloudHistory(projectId:string,accountId:string,signal:AbortSignal,after=0):Promise<{items:{cloudRevision:number;updatedAt:number}[];nextCursor:number|null}>{
 identity(projectId);if(!Number.isSafeInteger(after)||after<0)throw new Error('Invalid history cursor');
 const data=await request(`/api/projects/${encodeURIComponent(projectId)}/history?limit=20&after=${after}`,signal,undefined,accountId) as {version:number;items:{cloudRevision:number;updatedAt:number}[];nextCursor:number|null};
 if(!data||data.version!==1||!Array.isArray(data.items)||data.items.length>20)throw new Error('Invalid cloud history');
 let previous=after;const items=data.items.map(row=>{if(!row||!Number.isSafeInteger(row.cloudRevision)||row.cloudRevision<=previous||!Number.isSafeInteger(row.updatedAt)||row.updatedAt<0)throw new Error('Invalid history record');previous=row.cloudRevision;return {cloudRevision:row.cloudRevision,updatedAt:row.updatedAt};});
 if(data.nextCursor!==null&&(!items.length||data.nextCursor!==previous))throw new Error('Invalid history cursor');
 return {items,nextCursor:data.nextCursor};
}
export async function listCloudProjects(signal:AbortSignal,after='',accountId?:string):Promise<{items:{projectId:string;name:string;cloudRevision:number;updatedAt:number}[];nextCursor:string|null}>{
 if(after)identity(after);
 const data=await request(`/api/projects?limit=20&after=${encodeURIComponent(after)}`,signal,undefined,accountId) as {version:number;items:{projectId:string;name:string;cloudRevision:number;updatedAt:number}[];nextCursor:string|null};
 if(!data||data.version!==1||!Array.isArray(data.items)||data.items.length>20)throw new Error('Invalid cloud list');
 const seen=new Set<string>();
 const items=data.items.map(row=>{if(!row||typeof row.projectId!=='string'||!Number.isSafeInteger(row.cloudRevision)||row.cloudRevision<1||!Number.isSafeInteger(row.updatedAt)||row.updatedAt<0||seen.has(row.projectId))throw new Error('Invalid cloud project');identity(row.projectId);projectName(row.name);seen.add(row.projectId);return {projectId:row.projectId,name:row.name.trim(),cloudRevision:row.cloudRevision,updatedAt:row.updatedAt};});
 if(data.nextCursor!==null&&(!items.length||data.nextCursor!==items.at(-1)!.projectId||data.nextCursor===after))throw new Error('Invalid cloud cursor');
 return {items,nextCursor:data.nextCursor};
}
function identity(value:string){if(!value.trim()||value.length>256||/[\u0000-\u001f\u007f]/.test(value)||/[\ud800-\udfff]/u.test(value))throw new Error('Invalid cloud identity');return value;}
function projectName(value:string){if(typeof value!=='string'||!value.trim()||value.length>200||/[\u0000-\u001f\u007f]/.test(value)||/[\ud800-\udfff]/u.test(value))throw new Error('Invalid project name');return value.trim();}
function base64(bytes:Uint8Array){let text='';for(let start=0;start<bytes.length;start+=8192)text+=String.fromCharCode(...bytes.subarray(start,start+8192));return btoa(text);}
async function request(path:string,signal:AbortSignal,body?:string,accountId?:string):Promise<unknown>{
 const operation=AbortSignal.any([signal,AbortSignal.timeout(30000)]);operation.throwIfAborted();
 const response=await fetch(path,{method:body===undefined?'GET':'PUT',...(body===undefined?{}:{body}),headers:{...(body===undefined?{}:{'Content-Type':'application/json'}),...(accountId===undefined?{}:{'X-Studio-Account':encodeURIComponent(identity(accountId))})},credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation});
 if(!response.ok){await response.body?.cancel();throw new CloudProjectError(response.status,response.headers.get('X-Studio-Project-Error'));}
 if(!response.body)throw new Error('Missing cloud response');
 const reader=response.body.getReader(),chunks:Uint8Array[]=[];let size=0;
 try{for(;;){const {done,value}=await reader.read();operation.throwIfAborted();if(done)break;size+=value.length;if(size>limit)throw new Error('Cloud response too large');chunks.push(value);}}
 finally{await reader.cancel();reader.releaseLock();}
 const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
 return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));
}
export async function uploadCloudProject(accountId:string,snapshot:ProjectSnapshot,baseRevision:number,requestId:string,signal:AbortSignal,name:string):Promise<{cloudRevision:number;replayed:boolean}>{
 identity(accountId);identity(snapshot.projectId);identity(requestId);
 if(validateSnapshot(snapshot).length||!Number.isSafeInteger(baseRevision)||baseRevision<0||baseRevision>=Number.MAX_SAFE_INTEGER)throw new Error('Invalid cloud upload');
 projectName(name);
 const body=JSON.stringify({expectedAccountId:accountId,requestId,baseRevision,name:name.trim(),snapshot:{version:snapshot.version,projectId:snapshot.projectId,revision:snapshot.revision,entry:snapshot.entry,files:snapshot.files.map(file=>file.kind==='binary'?{path:file.path,kind:'binary',base64:base64(file.bytes)}:{path:file.path,kind:'text',text:file.text})}});
 if(new TextEncoder().encode(body).length>limit)throw new Error('Cloud upload too large');
 const receipt=await request(`/api/projects/${encodeURIComponent(snapshot.projectId)}`,signal,body) as Record<string,unknown>;
 if(!receipt||receipt.version!==1||receipt.projectId!==snapshot.projectId||receipt.requestId!==requestId||receipt.cloudRevision!==baseRevision+1||typeof receipt.replayed!=='boolean'||Object.keys(receipt).some(key=>!['version','projectId','requestId','cloudRevision','replayed'].includes(key)))throw new Error('Invalid cloud receipt');
 return {cloudRevision:receipt.cloudRevision as number,replayed:receipt.replayed};
}
export async function deleteCloudProject(accountId:string,projectId:string,signal:AbortSignal):Promise<void>{
 identity(accountId);identity(projectId);
 const operation=AbortSignal.any([signal,AbortSignal.timeout(30000)]);operation.throwIfAborted();
 const response=await fetch(`/api/projects/${encodeURIComponent(projectId)}`,{method:'DELETE',headers:{'X-Studio-Account':encodeURIComponent(accountId)},credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation});
 operation.throwIfAborted();
 if(response.status!==204){await response.body?.cancel();throw new CloudProjectError(response.status,response.headers.get('X-Studio-Project-Error'));}
 await response.body?.cancel();
}
export async function loadCloudProject(projectId:string,signal:AbortSignal,accountId?:string,cloudRevision?:number):Promise<{cloudRevision:number;updatedAt:number;name:string;snapshot:ProjectSnapshot}>{
 identity(projectId);
 if(cloudRevision!==undefined&&(!Number.isSafeInteger(cloudRevision)||cloudRevision<1))throw new Error('Invalid requested cloud revision');
 const record=await request(`/api/projects/${encodeURIComponent(projectId)}${cloudRevision===undefined?'':`/versions/${cloudRevision}`}`,signal,undefined,accountId) as {version:number;cloudRevision:number;updatedAt:number;name:string;snapshot:ProjectSnapshot};
 if(!record||record.version!==1||!Number.isSafeInteger(record.cloudRevision)||record.cloudRevision<1||!Number.isSafeInteger(record.updatedAt)||record.updatedAt<0||projectName(record.name)!==record.name.trim()||!Array.isArray(record.snapshot?.files))throw new Error('Invalid cloud snapshot');
 if(cloudRevision!==undefined&&record.cloudRevision!==cloudRevision)throw new Error('Cloud revision mismatch');
 const snapshot={...record.snapshot,files:record.snapshot.files.map(file=>{
  if(file.kind==='text')return {path:file.path,kind:'text' as const,text:file.text};
  const encoded=(file as unknown as {base64:string}).base64;
  if(file.kind!=='binary'||typeof encoded!=='string')throw new Error('Invalid cloud file');
  const text=atob(encoded);if(btoa(text)!==encoded)throw new Error('Invalid cloud encoding');
  return {path:file.path,kind:'binary' as const,bytes:Uint8Array.from(text,char=>char.charCodeAt(0))};
 })};
 if(snapshot.projectId!==projectId||validateSnapshot(snapshot).length)throw new Error('Invalid cloud snapshot');
 return {cloudRevision:record.cloudRevision,updatedAt:record.updatedAt,name:record.name.trim(),snapshot};
}
