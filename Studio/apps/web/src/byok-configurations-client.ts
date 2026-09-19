export type ByokConfiguration={id:string;label:string;model:string;providerId:string;enabled:boolean;version:number};
export type ByokConfigurationPage={configurations:ByokConfiguration[];nextCursor:string|null};
export function decodeByokConfigurations(value:unknown):ByokConfigurationPage {
  const v=value as any;
  if(!v||v.version!==1||!Array.isArray(v.configurations)||v.configurations.length>50)throw new Error('Invalid configurations');
  const ids=new Set<string>();
  for(const item of v.configurations){
    if(!item||typeof item.id!=='string'||!/^[A-Za-z0-9_-]{1,128}$/.test(item.id)||ids.has(item.id)||![item.label,item.model,item.providerId].every(value=>typeof value==='string'&&value.length>0&&value.length<=256)||typeof item.enabled!=='boolean'||!Number.isSafeInteger(item.version)||item.version<1||Object.keys(item).some(key=>!['id','label','model','providerId','enabled','version'].includes(key)))throw new Error('Invalid configuration');
    ids.add(item.id);
  }
  if(v.nextCursor!==null&&(typeof v.nextCursor!=='string'||!ids.has(v.nextCursor)||v.nextCursor!==v.configurations.at(-1)?.id))throw new Error('Invalid configuration cursor');
  return structuredClone({configurations:v.configurations,nextCursor:v.nextCursor});
}
export async function loadByokConfigurations(after:string,signal:AbortSignal):Promise<ByokConfigurationPage> {
  if(typeof after!=='string'||after.length>128)throw new Error('Invalid cursor');
  const operation=AbortSignal.any([signal,AbortSignal.timeout(10000)]);
  const response=await fetch(`/api/byok/configurations?${new URLSearchParams({after,limit:'20'})}`,{credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation});
  if(!response.ok||!response.body)throw new Error('Configurations unavailable');
  const reader=response.body.getReader(),chunks:Uint8Array[]=[];let size=0;
  try{for(;;){operation.throwIfAborted();const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>262144)throw new Error('Configurations too large');chunks.push(value);}}
  finally{await reader.cancel();reader.releaseLock();}
  operation.throwIfAborted();const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
  return decodeByokConfigurations(JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes)));
}
