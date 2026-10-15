export async function loadSession(signal:AbortSignal):Promise<string|null> {
  const operation=AbortSignal.any([signal,AbortSignal.timeout(10000)]);operation.throwIfAborted();
  const response=await fetch('/api/session',{credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation});
  if(response.status===401)return null;
  if(!response.ok||!response.body)throw new Error('Session unavailable');
  const reader=response.body.getReader(),chunks:Uint8Array[]=[];let size=0;
  try{for(;;){const {value,done}=await reader.read();operation.throwIfAborted();if(done)break;size+=value.length;if(size>4096)throw new Error('Session too large');chunks.push(value);}}
  finally{await reader.cancel();reader.releaseLock();}
  const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
  const value=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes)),id=value?.account?.accountId;
  if(value?.version!==1||Object.keys(value).some(key=>!['version','account'].includes(key))||Object.keys(value.account??{}).some(key=>key!=='accountId')||typeof id!=='string'||!id.trim()||id.length>256||/[\u0000-\u001f\u007f]/.test(id)||/[\ud800-\udfff]/u.test(id))throw new Error('Invalid session');
  return id;
}
