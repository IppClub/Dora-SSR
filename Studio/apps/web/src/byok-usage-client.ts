type Usage=Record<string,string>&{inputTokens:string;outputTokens:string};
export type ByokUsageRecord={requestId:string;projectId:string;configurationId:string;model:string;state:'pending-usage'|'recorded';usage:Usage|null;createdAt:number};
export type ByokUsageReport={summary:{registeredRequests:string;knownUsageRequests:string;pendingUsageRequests:string;inputTokens:string;outputTokens:string};records:ByokUsageRecord[];nextCursor:string|null};
const counter=(v:unknown):v is string=>typeof v==='string'&&/^(0|[1-9][0-9]{0,59})$/.test(v);
const identity=(v:unknown):v is string=>typeof v==='string'&&v.length>0&&v.length<=256;
export function decodeByokUsage(value:unknown):ByokUsageReport {
  const v=value as any;
  if(!v||v.version!==1||v.funding!=='byok'||!v.summary||!Array.isArray(v.records)||v.records.length>100)throw new Error('Invalid usage report');
  for(const key of ['registeredRequests','knownUsageRequests','pendingUsageRequests','inputTokens','outputTokens'])if(!counter(v.summary[key]))throw new Error('Invalid usage count');
  if(BigInt(v.summary.registeredRequests)!==BigInt(v.summary.knownUsageRequests)+BigInt(v.summary.pendingUsageRequests))throw new Error('Inconsistent usage counts');
  const ids=new Set();
  for(const row of v.records){
    if(!row||![row.requestId,row.projectId,row.configurationId,row.model].every(identity)||ids.has(row.requestId)||!Number.isSafeInteger(row.createdAt)||row.createdAt<0||row.createdAt>8640000000000000)throw new Error('Invalid usage record');
    ids.add(row.requestId);
    if(row.state==='pending-usage'){if(row.usage!==null)throw new Error('Invalid pending usage');}
    else if(row.state==='recorded'){
      if(!row.usage||!counter(row.usage.inputTokens)||!counter(row.usage.outputTokens)||!Object.values(row.usage).every(counter))throw new Error('Invalid recorded usage');
    }else throw new Error('Invalid usage state');
  }
  if(v.nextCursor!==null&&(!identity(v.nextCursor)||v.nextCursor!==v.records.at(-1)?.requestId))throw new Error('Invalid usage cursor');
  return structuredClone({summary:v.summary,records:v.records,nextCursor:v.nextCursor});
}
export async function loadByokUsage(after:string,signal:AbortSignal):Promise<ByokUsageReport> {
  if(typeof after!=='string'||after.length>256)throw new Error('Invalid usage cursor');
  const operation=AbortSignal.any([signal,AbortSignal.timeout(10000)]);
  const response=await fetch(`/api/byok/usage?${new URLSearchParams({after,limit:'20'})}`,{credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation});
  if(!response.ok||!response.body)throw new Error('Usage unavailable');
  const reader=response.body.getReader(),chunks:Uint8Array[]=[];let size=0;
  try{for(;;){operation.throwIfAborted();const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>1048576)throw new Error('Usage report too large');chunks.push(value);}}
  finally{await reader.cancel();reader.releaseLock();}
  operation.throwIfAborted();const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
  return decodeByokUsage(JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes)));
}
