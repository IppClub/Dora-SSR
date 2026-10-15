import {connectAgentFrameSession} from './agent-frame-session';

/** URL and binding must come from trusted provisioning, never imported project data. */
export function mountAgentHostFrame(container:HTMLElement, options:{url:string;projectId:string;generation:string;sessionId?:number},timeoutMs=30000) {
  const url=new URL(options.url,location.href);
  if(!['http:','https:'].includes(url.protocol) || url.origin===location.origin || url.username || url.password
    || !options.projectId || !options.generation || (options.sessionId!==undefined && (!Number.isSafeInteger(options.sessionId) || options.sessionId<=0))
    || !Number.isFinite(timeoutMs) || timeoutMs<=0 || timeoutMs>60000)throw new Error('Invalid trusted Agent host configuration');
  const binding={projectId:options.projectId,generation:options.generation,sessionId:options.sessionId};
  const frame=document.createElement('iframe');
  frame.title='Dora Agent 宿主';frame.setAttribute('aria-hidden','true');frame.tabIndex=-1;
  frame.setAttribute('sandbox','allow-scripts allow-same-origin');
  frame.setAttribute('allow','cross-origin-isolated');frame.referrerPolicy='no-referrer';
  const abort=new AbortController();
  let closed=false,connecting=false,loaded=false,hostReady=false;
  let connection:Awaited<ReturnType<typeof connectAgentFrameSession>>|undefined;
  let resolveReady:(value:Awaited<ReturnType<typeof connectAgentFrameSession>>)=>void;
  let rejectReady:(error:unknown)=>void;
  const ready=new Promise<Awaited<ReturnType<typeof connectAgentFrameSession>>>((resolve,reject)=>{resolveReady=resolve;rejectReady=reject;});
  const close=(reason:unknown=new Error('Agent host frame closed'))=>{
    if(closed)return;closed=true;
    clearTimeout(timer);window.removeEventListener('message',onMessage);frame.removeEventListener('load',onLoad);
    abort.abort(reason);connection?.close();frame.remove();rejectReady(reason);
  };
  const connect=async()=>{
    if(closed || connecting || !loaded || !hostReady)return;
    connecting=true;
    try {
      const result=await connectAgentFrameSession(frame,url.origin,{...binding,sessionId:binding.sessionId!},abort.signal);
      if(closed){result.close();return;}
      connection=result;clearTimeout(timer);window.removeEventListener('message',onMessage);frame.removeEventListener('load',onLoad);
      resolveReady({...result,close:()=>close()});
    } catch(error){close(error);}
  };
  const onLoad=()=>{loaded=true;void connect();};
  const onMessage=(event:MessageEvent)=>{
    if(closed || event.source!==frame.contentWindow || event.origin!==url.origin)return;
    const message=event.data;
    if(message?.type==='studio-agent-failed' && message.version===1 && message.projectId===binding.projectId
      && message.generation===binding.generation && message.code==='initialization-failed'
      && typeof message.message==='string' && message.message.length<=1024){
      close(new Error(`Agent host initialization failed: ${message.message}`));return;
    }
    if(connecting || hostReady)return;
    if(!message || message.type!=='studio-agent-ready' || message.version!==1 || message.projectId!==binding.projectId || message.generation!==binding.generation
      || !Number.isSafeInteger(message.sessionId) || message.sessionId<=0
      || (binding.sessionId!==undefined && message.sessionId!==binding.sessionId))return;
    // Only this provisioned host may choose the newly created/restored session.
    // Freeze the first accepted ID; all subsequent port messages must match it.
    binding.sessionId=message.sessionId;
    hostReady=true;void connect();
  };
  const timer=setTimeout(()=>close(new Error('Agent host startup timed out')),timeoutMs);
  window.addEventListener('message',onMessage);
  frame.addEventListener('load',onLoad);
  frame.src=url.href;
  try {container.append(frame);}catch(error){close(error);}
  // Normal retirement must keep the runtime alive until Agent storage confirms
  // persistence. A failure leaves it attached for recovery/retry. This does not
  // save the authoring workspace or confirm cloud synchronization.
  let retiring:Promise<void>|undefined;
  const persistAndClose=():Promise<void>=>{
    if(closed)return Promise.reject(new Error('Agent host frame closed'));
    if(retiring)return retiring;
    retiring=(async()=>{
      const current=await ready;
      if(closed || current.controller.closed)throw new Error('Agent host frame closed');
      if(!current.canPersist)throw new Error('Agent persistent storage unavailable');
      await current.persist();
      if(closed || current.controller.closed)throw new Error('Agent host closed before persistence confirmation');
      close();
    })().finally(()=>{retiring=undefined;});
    return retiring;
  };
  return {ready,close,persistAndClose};
}
