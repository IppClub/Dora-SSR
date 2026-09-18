import {installAgentWasmHost} from './agent-wasm-host';
import type {AgentHostModule} from './agent-wasm-source';

/** Install before executing trusted AgentHostSession.start, never game code.
 * Storage provisioning and runtime destruction remain the caller's ownership.
 */
export function prepareAgentBootstrap(module:AgentHostModule,parentWindow:Window,parentOrigin:string,
  binding:{projectId:string;generation:string;projectRoot:string},timeoutMs=30000) {
  const expected={...binding};
  const origin=new URL(parentOrigin);
  if(module.doraStudioAgentEvent || origin.origin!==parentOrigin || !['http:','https:'].includes(origin.protocol)
    || parentOrigin===location.origin || !expected.projectId || !expected.generation || !expected.projectRoot
    || !Number.isFinite(timeoutMs) || timeoutMs<=0 || timeoutMs>60000)throw new Error('Invalid Agent bootstrap configuration');
  let host:ReturnType<typeof installAgentWasmHost>|undefined;
  let closed=false;
  let resolveReady!:(value:ReturnType<typeof installAgentWasmHost>)=>void;
  let rejectReady!:(error:unknown)=>void;
  const ready=new Promise<ReturnType<typeof installAgentWasmHost>>((resolve,reject)=>{resolveReady=resolve;rejectReady=reject;});
  const close=()=>{
    if(closed)return;closed=true;clearTimeout(timer);
    window.removeEventListener('pagehide',close);
    if(module.doraStudioAgentEvent===receive)delete module.doraStudioAgentEvent;
    host?.close();rejectReady(new Error('Agent bootstrap closed'));
  };
  const receive=(payload:string)=>{
    if(closed)return;
    try {
      if(typeof payload!=='string' || payload.length>1024*1024 || new TextEncoder().encode(payload).length>1024*1024)throw new Error('Invalid Agent bootstrap event');
      const event=JSON.parse(payload);
      // Bridge.open emits its initial snapshot before initialized. The installed
      // source requests a fresh snapshot, so no pre-handshake snapshot is reused.
      if(event?.kind==='snapshot')return;
      if(event?.kind!=='initialized' || event.projectRoot!==expected.projectRoot
        || !Number.isSafeInteger(event.sessionId) || event.sessionId<=0)throw new Error('Mismatched Agent bootstrap event');
      delete module.doraStudioAgentEvent;
      host=installAgentWasmHost(module,parentWindow,parentOrigin,{...expected,sessionId:event.sessionId});
      clearTimeout(timer);resolveReady(host);
    }catch(error){rejectReady(error);close();throw error;}
  };
  const timer=setTimeout(()=>{rejectReady(new Error('Agent initialization timed out'));close();},timeoutMs);
  module.doraStudioAgentEvent=receive;
  window.addEventListener('pagehide',close,{once:true});
  return {ready,close};
}
