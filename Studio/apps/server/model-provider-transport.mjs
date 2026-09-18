import {normalizeModelUsage} from './model-usage.mjs';

const maxRequestBytes=1024*1024,maxResponseBytes=16*1024*1024;
const counter=value=>{
  if(typeof value==='number'&&Number.isSafeInteger(value)&&value>=0)return BigInt(value);
  if(typeof value==='string'&&/^(?:0|[1-9][0-9]{0,18})$/.test(value))return BigInt(value);
  throw new TypeError('Invalid provider usage counter');
};
/** Normalize OpenAI-compatible completion usage without summing overlapping
 * cached/reasoning breakdowns into the billed input/output totals. */
export function compatibleCompletionUsage(value){
  if(value==null)return null;
  if(typeof value!=='object'||Array.isArray(value))throw new TypeError('Invalid provider usage');
  const input=counter(value.prompt_tokens),output=counter(value.completion_tokens);
  const result={inputTokens:input,outputTokens:output};
  if(value.total_tokens!==undefined)result.totalTokens=counter(value.total_tokens);
  const prompt=value.prompt_tokens_details,completion=value.completion_tokens_details;
  if(prompt!==undefined){
    if(!prompt||typeof prompt!=='object'||Array.isArray(prompt))throw new TypeError('Invalid prompt usage details');
    if(prompt.cached_tokens!==undefined)result.cachedInputTokens=counter(prompt.cached_tokens);
    if(prompt.audio_tokens!==undefined)result.inputAudioTokens=counter(prompt.audio_tokens);
  }
  if(completion!==undefined){
    if(!completion||typeof completion!=='object'||Array.isArray(completion))throw new TypeError('Invalid completion usage details');
    if(completion.reasoning_tokens!==undefined)result.reasoningOutputTokens=counter(completion.reasoning_tokens);
    if(completion.audio_tokens!==undefined)result.outputAudioTokens=counter(completion.audio_tokens);
  }
  return normalizeModelUsage(result);
}

export function endpointURL(endpoint){
  const url=new URL(endpoint);
  if(url.protocol!=='https:'||url.username||url.password||url.search||url.hash||!url.hostname||url.pathname==='/')throw new TypeError('Invalid trusted provider endpoint');
  return url.href;
}
function serializeRequest(body,includeStreamUsage,requestByteLimit){
  if(!body||typeof body!=='object'||Array.isArray(body)||typeof body.model!=='string'||!body.model||!Array.isArray(body.messages)||!body.messages.length||typeof body.stream!=='boolean')throw new TypeError('Invalid completion request');
  if(typeof includeStreamUsage!=='boolean'||includeStreamUsage&&!body.stream)throw new TypeError('Invalid stream usage policy');
  if(includeStreamUsage&&body.stream_options!==undefined&&(typeof body.stream_options!=='object'||!body.stream_options||Array.isArray(body.stream_options)))throw new TypeError('Invalid stream options');
  const request=includeStreamUsage?{...body,stream_options:{...body.stream_options,include_usage:true}}:body;
  const encoded=JSON.stringify(request);
  if(!Number.isSafeInteger(requestByteLimit)||requestByteLimit<1||requestByteLimit>20*1024*1024)throw new TypeError('Invalid completion request limit');
  if(typeof encoded!=='string'||Buffer.byteLength(encoded)>requestByteLimit)throw new TypeError('Completion request too large');
  return encoded;
}
function providerKey(key){
  if(!(key instanceof Uint8Array)||key.byteLength<1||key.byteLength>16384)throw new TypeError('Invalid provider credential');
  const value=Buffer.from(key).toString('utf8');
  if(!value||/[\x00-\x20\x7f]/.test(value))throw new TypeError('Invalid provider credential');
  return value;
}
function streamEvents(){
  let text='',eventLines=[],done=false,usage=null;
  const flush=()=>{
    if(!eventLines.length)return;
    const data=eventLines.join('\n');eventLines=[];
    if(data==='[DONE]'){
      if(done)throw new Error('Duplicate completion terminator');
      done=true;return;
    }
    if(done)throw new Error('Completion data after terminator');
    let item;try{item=JSON.parse(data);}catch{throw new Error('Malformed provider stream event');}
    if(!item||typeof item!=='object'||Array.isArray(item)||item.error)throw new Error('Provider stream error');
    if(item.usage!==undefined&&item.usage!==null){
      const next=compatibleCompletionUsage(item.usage);
      if(usage&&JSON.stringify(usage,(_,value)=>typeof value==='bigint'?value.toString():value)!==JSON.stringify(next,(_,value)=>typeof value==='bigint'?value.toString():value))throw new Error('Conflicting provider usage');
      usage=next;
    }
  };
  return {
    push(chunk){
      text+=chunk;
      for(;;){const newline=text.indexOf('\n');if(newline<0)break;let line=text.slice(0,newline);text=text.slice(newline+1);if(line.endsWith('\r'))line=line.slice(0,-1);
        if(!line)flush();else if(line.startsWith('data:'))eventLines.push(line.slice(5).trimStart());
      }
      if(text.length>65536||eventLines.reduce((size,line)=>size+line.length,0)>65536)throw new Error('Oversized provider stream event');
    },
    finish(){if(text)throw new Error('Incomplete provider stream line');flush();if(!done)throw new Error('Missing provider stream terminator');return usage;},
  };
}

/** Trusted transport only: endpoint and credential are supplied by the server,
 * never by an imported project or an unauthenticated request. It preserves raw
 * SSE chunks for the original Agent and only confirms completion at [DONE]. */
export async function sendCompatibleCompletion({endpoint,key,body,signal,onChunk,includeStreamUsage=false,requestByteLimit=maxRequestBytes,fetchImpl=fetch}){
  const url=endpointURL(endpoint),credential=providerKey(key),request=serializeRequest(body,includeStreamUsage,requestByteLimit);
  if(signal?.aborted)throw new Error('Provider request cancelled');
  if(onChunk!==undefined&&typeof onChunk!=='function')throw new TypeError('Invalid provider stream sink');
  if(body.stream&&typeof onChunk!=='function')throw new TypeError('Streaming completion requires a sink');
  const response=await fetchImpl(url,{method:'POST',redirect:'error',cache:'no-store',signal,headers:{Authorization:`Bearer ${credential}`,'Content-Type':'application/json',Accept:body.stream?'text/event-stream':'application/json'},body:request});
  if(!response?.ok||!response.body)throw new Error('Provider completion unavailable');
  const contentType=response.headers.get('content-type')?.toLowerCase()??'';
  if(body.stream?!contentType.startsWith('text/event-stream'):!contentType.startsWith('application/json'))throw new Error('Unexpected provider response type');
  const reader=response.body.getReader(),decoder=new TextDecoder('utf-8',{fatal:true}),events=body.stream?streamEvents():null;
  let bytes=0,raw='';
  try{
    for(;;){const {done,value}=await reader.read();if(done)break;
      bytes+=value.byteLength;if(bytes>maxResponseBytes)throw new Error('Provider response too large');
      const part=decoder.decode(value,{stream:true});
      if(events){events.push(part);await onChunk(part);}else raw+=part;
    }
    const tail=decoder.decode();if(tail){if(events){events.push(tail);await onChunk(tail);}else raw+=tail;}
  }finally{await reader.cancel();reader.releaseLock();}
  if(events)return {completed:true,usage:events.finish(),response:null};
  let item;try{item=JSON.parse(raw);}catch{throw new Error('Malformed provider completion');}
  if(!item||typeof item!=='object'||Array.isArray(item)||item.error||!Array.isArray(item.choices)||!item.choices.length)throw new Error('Invalid provider completion');
  return {completed:true,usage:compatibleCompletionUsage(item.usage),response:item};
}
