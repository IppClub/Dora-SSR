export type SecretMetadata={version:number;available:boolean};
export class SecretRequestError extends Error {
  constructor(readonly code:'invalid'|'conflict'|'unavailable'|'uncertain') {
    super(({invalid:'密钥请求无效。',conflict:'配置已被修改，请重新读取状态。',unavailable:'密钥状态暂时无法读取。',uncertain:'操作结果尚未确认，请先重新读取状态，不要直接重复提交。'})[code]);
  }
}
type Operation={method:'GET'}|{method:'PUT';expectedVersion:number;key:string;consent:true}|{method:'DELETE';expectedVersion:number};
/** No key storage, logging, redirect, or automatic write retry. */
export async function requestByokSecret(configurationId:string,input:Operation,signal:AbortSignal):Promise<SecretMetadata> {
  if(!/^[A-Za-z0-9_-]{1,128}$/.test(configurationId)||!['GET','PUT','DELETE'].includes(input.method))throw new SecretRequestError('invalid');
  if(input.method!=='GET'&&(!Number.isSafeInteger(input.expectedVersion)||input.expectedVersion<0||input.expectedVersion>=Number.MAX_SAFE_INTEGER))throw new SecretRequestError('invalid');
  if(input.method==='PUT'&&(input.consent!==true||typeof input.key!=='string'||!input.key.length||new TextEncoder().encode(input.key).length>16384||/[\u0000-\u001f\u007f]/.test(input.key)))throw new SecretRequestError('invalid');
  const operation=AbortSignal.any([signal,AbortSignal.timeout(10000)]);
  // An already-cancelled action has not sent anything.
  operation.throwIfAborted();
  try{
    const response=await fetch(new URL(`/api/byok/configurations/${configurationId}/secret`,location.origin),{
      method:input.method,credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation,
      ...(input.method==='GET'?{}:{headers:{'Content-Type':'application/json'},body:JSON.stringify(input.method==='PUT'?{expectedVersion:input.expectedVersion,key:input.key,consent:true}:{expectedVersion:input.expectedVersion})}),
    });
    if(response.status===409)throw new SecretRequestError('conflict');
    if(response.status!==200||!response.body)throw new Error('Unconfirmed response');
    const reader=response.body.getReader(),chunks:Uint8Array[]=[];let total=0;
    try{for(;;){operation.throwIfAborted();const {done,value}=await reader.read();if(done)break;total+=value.length;if(total>4096)throw new Error('Oversized metadata');chunks.push(value);}}
    finally{await reader.cancel();reader.releaseLock();}
    operation.throwIfAborted();
    const bytes=new Uint8Array(total);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
    const result=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));
    if(!result||typeof result!=='object'||Array.isArray(result)||Object.keys(result).some(key=>!['version','available'].includes(key))||!Number.isSafeInteger(result.version)||result.version<0||typeof result.available!=='boolean')throw new Error('Invalid metadata');
    if(input.method!=='GET'&&(result.version!==input.expectedVersion+1||result.available!==(input.method==='PUT')))throw new Error('Unexpected write result');
    return {version:result.version,available:result.available};
  }catch(error){
    if(error instanceof SecretRequestError)throw error;
    throw new SecretRequestError(input.method==='GET'?'unavailable':'uncertain');
  }
}
