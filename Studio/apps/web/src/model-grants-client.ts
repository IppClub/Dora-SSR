export type ModelGrantChoice={grantId:string;label:string;model:string;enabled:boolean};
export type ModelGrantPage={configurations:ModelGrantChoice[];nextCursor:string|null};
export function decodeModelGrants(value:unknown):ModelGrantPage {
  const v=value as any,ids=new Set<string>();
  if(!v||v.version!==1||!Array.isArray(v.configurations)||v.configurations.length>50)throw new Error('Invalid grants');
  for(const item of v.configurations){
    if(!item||typeof item.grantId!=='string'||!/^[A-Za-z0-9_-]{1,128}$/.test(item.grantId)||ids.has(item.grantId)||![item.label,item.model].every(value=>typeof value==='string'&&value.length>0&&value.length<=256)||typeof item.enabled!=='boolean'||Object.keys(item).some(key=>!['grantId','label','model','enabled'].includes(key)))throw new Error('Invalid grant');
    ids.add(item.grantId);
  }
  // Cursor may represent an omitted, unavailable catalog binding.
  if(v.nextCursor!==null&&(typeof v.nextCursor!=='string'||!v.nextCursor.length||v.nextCursor.length>256))throw new Error('Invalid cursor');
  return structuredClone({configurations:v.configurations,nextCursor:v.nextCursor});
}
export async function loadModelGrants(after:string,signal:AbortSignal):Promise<ModelGrantPage> {
  if(after.length>256)throw new Error('Invalid cursor');
  const operation=AbortSignal.any([signal,AbortSignal.timeout(10000)]);operation.throwIfAborted();
  const response=await fetch(`/api/model-grants?${new URLSearchParams({after,limit:'20'})}`,{credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation});
  if(!response.ok||!response.body)throw new Error('Grants unavailable');
  const reader=response.body.getReader(),chunks:Uint8Array[]=[];let size=0;
  try{for(;;){operation.throwIfAborted();const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>131072)throw new Error('Too large');chunks.push(value);}}
  finally{await reader.cancel();reader.releaseLock();}
  operation.throwIfAborted();const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
  const page=decodeModelGrants(JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes)));
  if(page.nextCursor!==null&&page.nextCursor<=after)throw new Error('Nonadvancing cursor');
  return page;
}
