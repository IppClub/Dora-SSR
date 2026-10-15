import {serveAgentSessionPort, type AgentSessionSource, type AgentHostLifecycle} from './agent-session-port-host';
import type {BuildArtifact} from '@dora-studio/contracts';
import type {AgentPreviewCapture} from './agent-tool-preview-host';
import type {AgentLuaCommandResult} from './agent-tool-lua-host';

/** Install only in a dedicated trusted host document with no user project scripts.
 * parentOrigin and binding come from trusted provisioning, not an incoming message.
 */
export function installAgentFrameHost(parentWindow: Window, parentOrigin: string, binding: {projectId:string;generation:string;sessionId:number}, source: AgentSessionSource, lifecycle?:AgentHostLifecycle) {
  if (new URL(parentOrigin).origin !== parentOrigin || parentOrigin === location.origin || !/^https?:/.test(parentOrigin)) throw new Error('Invalid Studio parent origin');
  const expected = {projectId:binding.projectId,generation:binding.generation,sessionId:binding.sessionId};
  let retired = false;
  let active: ReturnType<typeof serveAgentSessionPort> | undefined;
  const seen = new Set<string>();
  const close = () => {
    if (retired) return;
    retired = true;
    window.removeEventListener('message', onMessage);
    window.removeEventListener('pagehide', close);
    active?.close();active = undefined;
  };
  const onMessage = (event: MessageEvent<unknown>) => {
    if (retired || event.source !== parentWindow || event.origin !== parentOrigin) return;
    const message = event.data as Record<string,unknown> | null;
    if (!message || message.type !== 'studio-agent-connect' || message.version !== 1 || typeof message.requestId !== 'string' || !/^[0-9a-f-]{36}$/i.test(message.requestId) || event.ports.length) return;
    if (seen.has(message.requestId)) return;
    // A host generation has a bounded number of connection attempts; recreate it after exhaustion.
    if (seen.size >= 64) {close();return;}
    seen.add(message.requestId);
    active?.close();
    const channel = new MessageChannel();
    try {
      active = serveAgentSessionPort(channel.port1, expected, source,lifecycle);
      parentWindow.postMessage({type:'studio-agent-port',version:1,requestId:message.requestId},parentOrigin,[channel.port2]);
    } catch {
      channel.port1.close();channel.port2.close();close();
    }
  };
  window.addEventListener('message',onMessage);
  window.addEventListener('pagehide',close);
  try {parentWindow.postMessage({type:'studio-agent-ready',version:1,...expected},parentOrigin);}
  catch(error){close();throw error;}
  return {close,requestPreview:(artifact:BuildArtifact,times:readonly number[],signal:AbortSignal):Promise<readonly AgentPreviewCapture[]>=>{
    if(!active)return Promise.reject(new Error('Agent preview port unavailable'));
    return active.requestPreview(artifact,times,signal);
  },requestLua:(artifact:BuildArtifact,commandId:string,timeoutSeconds:number,signal:AbortSignal):Promise<AgentLuaCommandResult>=>{
    if(!active)return Promise.reject(new Error('Agent Lua Player port unavailable'));
    return active.requestLua(artifact,commandId,timeoutSeconds,signal);
  }};
}
