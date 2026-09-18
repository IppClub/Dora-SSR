import {decodeAgentHostConfig} from './agent-host-config';
import {agentStorageId,acquireAgentStorage} from './agent-storage';
import {prepareAgentBootstrap} from './agent-bootstrap';
import type {AgentHostModule} from './agent-wasm-source';

const claimed=new WeakSet<object>();
/** Trusted page setup before engine loading. Assign storageId to
 * Module.doraStorageId synchronously (it is a Promise); the loader awaits it.
 * close stops communication, not runtime writes. Destroy the document to release
 * an admitted storage lease; do not reuse a Module after a failed startup.
 */
export function prepareAgentHostRuntime(module:AgentHostModule,parentWindow:Window,value:unknown) {
  const config=decodeAgentHostConfig(value);
  if(claimed.has(module))throw new Error('Agent runtime already configured');
  const bootstrap=prepareAgentBootstrap(module,parentWindow,config.parentOrigin,config);
  claimed.add(module);
  let closed=false;
  const close=()=>{closed=true;bootstrap.close();};
  void bootstrap.ready.catch(()=>close());
  const storageId=(async()=>{
    const id=await agentStorageId(config.parentOrigin,config.accountId,config.projectId);
    if(closed)throw new Error('Agent runtime closed before storage acquisition');
    const lease=await acquireAgentStorage(id);
    // A cancelled setup must not acquire a lease after its owner has gone away.
    if(closed){await lease.release();throw new Error('Agent runtime closed before storage admission');}
    return id;
  })().catch(error=>{close();throw error;});
  const ready=Promise.all([storageId,bootstrap.ready]).then(([,host])=>{
    if(closed)throw new Error('Agent runtime closed before readiness');
    return host;
  });
  return {config,storageId,ready,close};
}
