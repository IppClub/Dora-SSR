import {decodeAgentSessionPatch, decodeAgentSessionSnapshot} from './agent-session-decode';
import {decodeAgentProjectSnapshot} from './agent-project-snapshot';
import type {ProjectSnapshot} from '@dora-studio/contracts';
import {decodeAgentProjectCapture,type AgentProjectCapture} from './agent-project-capture';
import {isBuildArtifact,type BuildArtifact} from '@dora-studio/contracts';
import type {AgentPreviewCapture} from './agent-tool-preview-host';
import type {AgentLuaCommandResult} from './agent-tool-lua-host';
import {isAgentPromptOptions,type AgentPromptOptions} from './agent-prompt-options';
import type {AgentModelQueueStore} from './agent-model-queue';

export interface AgentHostLifecycle {
  persist(signal:AbortSignal):Promise<void>;
  syncProject?(snapshot:ProjectSnapshot,signal:AbortSignal):Promise<void>;
  captureProject?(signal:AbortSignal):Promise<AgentProjectCapture>;
  captureLiveProject?(signal:AbortSignal):Promise<AgentProjectCapture>;
  sendPrompt?(prompt:string,grantId:string,requestId:string,options:AgentPromptOptions,signal:AbortSignal):Promise<number>;
  handleQuestionnaire?(action:'respond'|'cancel',questionnaireId:number,answers:unknown[],grantId:string,requestId:string,signal:AbortSignal):Promise<number>;
  stopTask?(requestId:string,signal:AbortSignal):Promise<void>;
  modelQueue?:AgentModelQueueStore;
}

export interface AgentSessionSource {
  subscribe(listener: (payload:string, sequence:number) => void, onClose?:()=>void): () => void;
  capture(signal: AbortSignal): {payload:string;sequence:number} | Promise<{payload:string;sequence:number}>;
}

/** Trusted-host adapter. The host supplies authorization, source isolation and a stable generation.
 * Serves one subscription and an optional explicitly supplied persistence capability.
 * Prompt commands are accepted only on the authenticated dedicated host port;
 * the host resolves model configuration from its own protected origin.
 */
export function serveAgentSessionPort(port: MessagePort, binding: {projectId:string;generation:string;sessionId:number}, source: AgentSessionSource, lifecycle?:AgentHostLifecycle) {
  const expected = {projectId:binding.projectId,generation:binding.generation,sessionId:binding.sessionId};
  let closed = false, started = false, capturing = true, sequence = 0;
  let unsubscribe: (() => void) | undefined;
  let unsubscribeModelQueue:(()=>void)|undefined;
  const pending: {payload:string;sequence:number}[] = [];
  const captureAbort = new AbortController();
  let captureTimer: ReturnType<typeof setTimeout> | undefined;
  let persisting=false;
  const operations=new Set<string>();
  let preview:{id:string;finish:(captures:readonly AgentPreviewCapture[])=>void;fail:(reason:unknown)=>void;timer:ReturnType<typeof setTimeout>;abort:()=>void}|undefined;
  let lua:{id:string;finish:(result:AgentLuaCommandResult)=>void;fail:(reason:unknown)=>void;timer:ReturnType<typeof setTimeout>;abort:()=>void}|undefined;
  const close = () => {
    if (closed) return;
    closed = true;
    if (captureTimer !== undefined) clearTimeout(captureTimer);
    captureAbort.abort(new Error('Agent session port closed'));
    if(preview){clearTimeout(preview.timer);preview.fail(new Error('Agent preview port closed'));preview=undefined;}
    if(lua){clearTimeout(lua.timer);lua.fail(new Error('Agent Lua port closed'));lua=undefined;}
    port.removeEventListener('message', onMessage);
    port.removeEventListener('messageerror', close);
    pending.length = 0;
    try {port.postMessage({type:'closed',version:1,...expected});} catch {/* Peer may already be gone. */}
    try {unsubscribe?.();unsubscribeModelQueue?.();} finally {unsubscribe = undefined;unsubscribeModelQueue=undefined;port.close();}
  };
  const sendPatch = (payload:string, next:number) => {
    if (closed) return;
    try {
      if (!Number.isSafeInteger(next) || next <= 0) throw new Error('Invalid source sequence');
      const patch = decodeAgentSessionPatch(payload);
      if (patch.sessionId !== expected.sessionId) throw new Error('Foreign source session');
      if (capturing) {
        if (pending.length >= 32) throw new Error('Snapshot event buffer exceeded');
        pending.push({payload,sequence:next});return;
      }
      if (next <= sequence) return;
      if (next !== sequence + 1) throw new Error('Source sequence gap');
      port.postMessage({type:'patch',version:1,...expected,sequence:next,payload});
      sequence = next;
    } catch {close();}
  };
  const onMessage = async (event: MessageEvent<unknown>) => {
    if (closed) return;
    try {
      const message = event.data as Record<string,unknown> | null;
      if(message?.type==='preview-result'){
        if(!preview||message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId
          ||message.requestId!==preview.id||typeof message.success!=='boolean')throw new Error('Invalid Agent preview response');
        const current=preview;preview=undefined;clearTimeout(current.timer);
        if(message.success){
          const frames=message.captures;
          if(!Array.isArray(frames)||frames.length<1||frames.length>3||frames.some(frame=>!(frame.png instanceof Uint8Array)||frame.png.byteLength>12*1024*1024
            ||!Number.isSafeInteger(frame.width)||!Number.isSafeInteger(frame.height)||typeof frame.elapsedSeconds!=='number'))throw new Error('Invalid Agent preview captures');
          current.finish(frames as AgentPreviewCapture[]);
        }else current.fail(new Error(typeof message.message==='string'&&message.message.length<=4096?message.message:'Agent Player preview failed'));
        return;
      }
      if(message?.type==='lua-result'){
        if(!lua||message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId
          ||message.requestId!==lua.id||typeof message.success!=='boolean')throw new Error('Invalid Agent Lua response');
        const current=lua;lua=undefined;clearTimeout(current.timer);
        if(message.success){
          const result=message.result as Record<string,unknown>|undefined;
          if(!result||typeof result!=='object'||Array.isArray(result)||typeof result.success!=='boolean'||typeof result.output!=='string'
            ||(result.message!==undefined&&typeof result.message!=='string')||(result.phase!==undefined&&typeof result.phase!=='string'))throw new Error('Invalid Agent Lua result');
          current.finish({success:result.success,output:result.output,
            ...(typeof result.message==='string'?{message:result.message}:{}),
            ...(typeof result.phase==='string'?{phase:result.phase}:{})});
        }else current.fail(new Error(typeof message.message==='string'&&message.message.length<=4096?message.message:'Agent Lua Player failed'));
        return;
      }
      if(message?.type==='send-prompt') {
        if(!started||capturing||!lifecycle?.sendPrompt||persisting||message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId
          ||typeof message.requestId!=='string'||!/^[0-9a-f-]{36}$/i.test(message.requestId)||operations.has(message.requestId)||operations.size>=64
          ||typeof message.prompt!=='string'||!message.prompt.trim()||message.prompt.length>5000||typeof message.grantId!=='string'||!/^[A-Za-z0-9_-]{1,128}$/.test(message.grantId)
          ||!isAgentPromptOptions(message.options))throw new Error('Invalid Agent prompt request');
        operations.add(message.requestId);persisting=true;
        let taskId:number|undefined;
        try{taskId=await lifecycle.sendPrompt(message.prompt,message.grantId,message.requestId,message.options,captureAbort.signal);}
        catch{/* Do not disclose model credentials or privileged host errors. */}
        finally{persisting=false;}
        if(!closed)port.postMessage({type:'prompt-sent',version:1,...expected,requestId:message.requestId,success:taskId!==undefined,...(taskId!==undefined?{taskId}:{})});
        return;
      }
      if(message?.type==='capture-live-project') {
        if(!started||capturing||!lifecycle?.captureLiveProject||persisting||message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId
          ||typeof message.requestId!=='string'||!/^[0-9a-f-]{36}$/i.test(message.requestId)||operations.has(message.requestId)||operations.size>=64)throw new Error('Invalid live project capture request');
        operations.add(message.requestId);persisting=true;let capture:AgentProjectCapture|undefined;
        try{capture=await lifecycle.captureLiveProject(captureAbort.signal);}catch{/* Suppress host details. */}finally{persisting=false;}
        if(!closed)port.postMessage({type:'live-project-captured',version:1,...expected,requestId:message.requestId,success:!!capture,...(capture?{capture}:{})});
        return;
      }
      if(message?.type==='stop-task') {
        if(!started||capturing||!lifecycle?.stopTask||persisting||message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId
          ||typeof message.requestId!=='string'||!/^[0-9a-f-]{36}$/i.test(message.requestId)||operations.has(message.requestId)||operations.size>=64)throw new Error('Invalid Agent stop request');
        operations.add(message.requestId);persisting=true;let success=false;
        try{await lifecycle.stopTask(message.requestId,captureAbort.signal);success=true;}catch{/* Preserve only the public acknowledgement. */}finally{persisting=false;}
        if(!closed)port.postMessage({type:'task-stopped',version:1,...expected,requestId:message.requestId,success});
        return;
      }
      if(message?.type==='questionnaire-respond'||message?.type==='questionnaire-cancel'){
        const action=message.type==='questionnaire-respond'?'respond':'cancel',answers=action==='respond'?message.answers:[];
        if(!started||capturing||!lifecycle?.handleQuestionnaire||persisting||message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId
          ||typeof message.requestId!=='string'||!/^[0-9a-f-]{36}$/i.test(message.requestId)||operations.has(message.requestId)||operations.size>=64
          ||!Number.isSafeInteger(message.questionnaireId)||Number(message.questionnaireId)<=0||!Array.isArray(answers)||answers.length>3
          ||typeof message.grantId!=='string'||!/^[A-Za-z0-9_-]{1,128}$/.test(message.grantId)||JSON.stringify(answers).length>65536)throw new Error('Invalid Agent questionnaire request');
        operations.add(message.requestId);persisting=true;let taskId:number|undefined;
        try{taskId=await lifecycle.handleQuestionnaire(action,Number(message.questionnaireId),answers,message.grantId,message.requestId,captureAbort.signal);}catch{/* Suppress privileged errors. */}finally{persisting=false;}
        if(!closed)port.postMessage({type:'questionnaire-handled',version:1,...expected,requestId:message.requestId,success:taskId!==undefined,...(taskId!==undefined?{taskId}:{})});
        return;
      }
      if(message?.type==='capture-project') {
        if(!started || capturing || !lifecycle?.captureProject || persisting || message.version!==1 || message.projectId!==expected.projectId || message.generation!==expected.generation || message.sessionId!==expected.sessionId
          || typeof message.requestId!=='string' || !/^[0-9a-f-]{36}$/i.test(message.requestId) || operations.has(message.requestId) || operations.size>=64)throw new Error('Invalid project capture request');
        operations.add(message.requestId);persisting=true;
        let result:AgentProjectCapture|undefined;
        try{result=decodeAgentProjectCapture(await lifecycle.captureProject(captureAbort.signal),expected);}
        catch{/* Do not disclose privileged file or host errors. */}
        finally{persisting=false;}
        if(!closed)port.postMessage({type:'project-captured',version:1,...expected,requestId:message.requestId,success:!!result,...(result?{capture:result}:{})});
        return;
      }
      if(message?.type==='sync-project') {
        if(!started || capturing || !lifecycle?.syncProject || persisting || message.version!==1 || message.projectId!==expected.projectId || message.generation!==expected.generation || message.sessionId!==expected.sessionId
          || typeof message.requestId!=='string' || !/^[0-9a-f-]{36}$/i.test(message.requestId) || operations.has(message.requestId) || operations.size>=64)throw new Error('Invalid project synchronization request');
        operations.add(message.requestId);persisting=true;
        let success=false,revision:number|undefined;
        try {
          const snapshot=await decodeAgentProjectSnapshot(message.snapshot,expected.projectId,captureAbort.signal);
          revision=snapshot.revision;
          await lifecycle.syncProject(snapshot,captureAbort.signal);success=true;
        }catch{/* Never expose privileged host details. */}
        finally{persisting=false;}
        if(!closed)port.postMessage({type:'project-synced',version:1,...expected,requestId:message.requestId,success,revision});
        return;
      }
      if(message?.type==='persist') {
        if(!started || capturing || !lifecycle || persisting || message.version!==1 || message.projectId!==expected.projectId || message.generation!==expected.generation || message.sessionId!==expected.sessionId
          || typeof message.requestId!=='string' || !/^[0-9a-f-]{36}$/i.test(message.requestId) || operations.has(message.requestId) || operations.size>=64) throw new Error('Invalid persistence request');
        operations.add(message.requestId);persisting=true;
        let success=false;
        try {await lifecycle.persist(captureAbort.signal);success=true;} catch {/* Do not leak host errors or credentials. */}
        finally {persisting=false;}
        if(!closed)port.postMessage({type:'persisted',version:1,...expected,requestId:message.requestId,success});
        return;
      }
      if (message?.type === 'unsubscribe' && message.version === 1 && message.projectId === expected.projectId && message.generation === expected.generation && message.sessionId === expected.sessionId) {close();return;}
      if (started || !message || message.type !== 'subscribe' || message.version !== 1 || message.projectId !== expected.projectId || message.generation !== expected.generation || message.sessionId !== expected.sessionId) throw new Error('Invalid subscription');
      started = true;
      const stop = source.subscribe(sendPatch,close);
      if (closed) {stop();return;}
      unsubscribe = stop;
      unsubscribeModelQueue=lifecycle?.modelQueue?.subscribe(()=>{
        if(closed||capturing)return;
        try{port.postMessage({type:'model-queue',version:1,...expected,modelQueue:lifecycle.modelQueue!.getSnapshot()});}catch{close();}
      });
      captureTimer = setTimeout(close, 15000);
      const snapshot = await source.capture(captureAbort.signal);
      clearTimeout(captureTimer);
      if (closed) return;
      decodeAgentSessionSnapshot(snapshot.payload, expected.sessionId);
      if (!Number.isSafeInteger(snapshot.sequence) || snapshot.sequence < 0) throw new Error('Invalid snapshot cursor');
      sequence = snapshot.sequence;
      port.postMessage({type:'snapshot',version:1,...expected,...snapshot,canPersist:!!lifecycle,canSyncProject:!!lifecycle?.syncProject,canCaptureProject:!!lifecycle?.captureProject,canCaptureLiveProject:!!lifecycle?.captureLiveProject,canSendPrompt:!!lifecycle?.sendPrompt,canHandleQuestionnaire:!!lifecycle?.handleQuestionnaire,canStopTask:!!lifecycle?.stopTask,modelQueue:lifecycle?.modelQueue?.getSnapshot()??{version:1,state:'idle'}});
      capturing = false;
      for (const item of pending.splice(0)) sendPatch(item.payload,item.sequence);
    } catch {close();}
  };
  if (!expected.projectId || !expected.generation || !Number.isSafeInteger(expected.sessionId) || expected.sessionId <= 0) {port.close();throw new Error('Invalid host session binding');}
  port.addEventListener('message',onMessage);
  port.addEventListener('messageerror',close);
  port.start();
  const requestPreview=(artifact:BuildArtifact,captureAtSeconds:readonly number[],signal:AbortSignal):Promise<readonly AgentPreviewCapture[]>=>new Promise((resolve,reject)=>{
    if(closed||!started||capturing||persisting||preview||lua||signal.aborted||!isBuildArtifact(artifact)||artifact.projectId!==expected.projectId
      ||captureAtSeconds.length<1||captureAtSeconds.length>3){reject(new Error('Agent Player preview unavailable'));return;}
    const id=crypto.randomUUID();
    const cleanup=()=>{if(preview?.id===id)preview=undefined;signal.removeEventListener('abort',abort);clearTimeout(timer);};
    const fail=(reason:unknown)=>{cleanup();reject(reason);};
    const abort=()=>{try{port.postMessage({type:'preview-cancel',version:1,...expected,requestId:id});}catch{/* Port may already be gone. */}fail(signal.reason??new DOMException('Aborted','AbortError'));};
    const timer=setTimeout(()=>{try{port.postMessage({type:'preview-cancel',version:1,...expected,requestId:id});}catch{/* Port may already be gone. */}fail(new Error('Agent Player preview timed out'));},45000);
    preview={id,finish:frames=>{cleanup();resolve(frames);},fail,timer,abort};
    signal.addEventListener('abort',abort,{once:true});
    try{port.postMessage({type:'preview-request',version:1,...expected,requestId:id,artifact,captureAtSeconds});}
    catch(error){fail(error);}
  });
  const requestLua=(artifact:BuildArtifact,commandId:string,timeoutSeconds:number,signal:AbortSignal):Promise<AgentLuaCommandResult>=>new Promise((resolve,reject)=>{
    if(closed||!started||capturing||persisting||preview||lua||signal.aborted||!isBuildArtifact(artifact)||artifact.projectId!==expected.projectId
      ||!/^[a-zA-Z0-9_-]{1,128}$/.test(commandId)||!Number.isSafeInteger(timeoutSeconds)||timeoutSeconds<1||timeoutSeconds>120){reject(new Error('Agent Lua Player unavailable'));return;}
    const id=crypto.randomUUID();
    const cleanup=()=>{if(lua?.id===id)lua=undefined;signal.removeEventListener('abort',abort);clearTimeout(timer);};
    const fail=(reason:unknown)=>{cleanup();reject(reason);};
    const abort=()=>{try{port.postMessage({type:'lua-cancel',version:1,...expected,requestId:id});}catch{/* Port may already be gone. */}fail(signal.reason??new DOMException('Aborted','AbortError'));};
    const timer=setTimeout(()=>{try{port.postMessage({type:'lua-cancel',version:1,...expected,requestId:id});}catch{/* Port may already be gone. */}fail(new Error(`Lua command timed out after ${timeoutSeconds} seconds`));},timeoutSeconds*1000);
    lua={id,finish:result=>{cleanup();resolve(result);},fail,timer,abort};
    signal.addEventListener('abort',abort,{once:true});
    try{port.postMessage({type:'lua-request',version:1,...expected,requestId:id,artifact,commandId,timeoutSeconds});}
    catch(error){fail(error);}
  });
  return {close,requestPreview,requestLua,get closed(){return closed;}};
}
