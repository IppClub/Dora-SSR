import {decodeAgentSessionPatch, decodeAgentSessionSnapshot} from './agent-session-decode';
import type {AgentSessionSource} from './agent-session-port-host';
import {decodeAgentQuiescence, type AgentQuiescence} from './agent-quiescence';
import {decodeAgentFileCommitQueue,type AgentFileCommitQueue} from './agent-file-commit-queue';
import {isAgentPromptOptions,type AgentPromptOptions} from './agent-prompt-options';

export interface AgentHostModule {
  FS?: import('./agent-project-install').AgentProjectFS;
  doraSyncUserStorage?: (options:{afterCurrent:true})=>Promise<unknown>;
  doraStudioAgentEvent?: (payload:string) => void;
  ccall(name:string, result:null, types:string[], args:string[]): unknown;
}

export type AgentToolRequest = {operation:'transpile-ts'|'build-script'|'preview-game'|'execute-lua';file:string;content:string;projectRoot:string};
export type AgentToolReply={success:true;luaCode:string}|{success:true;resultJSON:string}|{success:false;message:string};

/** Owns the callback of one trusted Agent WASM instance, never a game instance. */
export function createAgentWasmSource(module:AgentHostModule, sessionId:number, toolHandler?:(request:AgentToolRequest,signal:AbortSignal)=>Promise<AgentToolReply>): AgentSessionSource & {close():void;quiesce(signal:AbortSignal):Promise<AgentQuiescence>;readFileCommits(signal:AbortSignal):Promise<AgentFileCommitQueue>;requestPrompt(prompt:string,options:AgentPromptOptions,llmConfig:Record<string,unknown>,requestId:string,signal:AbortSignal):Promise<number>;requestQuestionnaire(action:'respond'|'cancel',questionnaireId:number,answers:unknown[],llmConfig:Record<string,unknown>,requestId:string,signal:AbortSignal):Promise<number>;requestStop(requestId:string,signal:AbortSignal):Promise<void>;releaseQuiescence(signal:AbortSignal):Promise<void>} {
  if (!Number.isSafeInteger(sessionId) || sessionId <= 0 || module.doraStudioAgentEvent) throw new Error('Invalid or already owned Agent host');
  let closed = false;
	const toolLifetime=new AbortController();
	const activeTools=new Map<string,AbortController>();
  const listeners = new Set<{event:(payload:string,sequence:number)=>void;close:(()=>void)|undefined}>();
  const pending = new Map<string,{kind:'snapshot'|'command';finish:(value:{payload:string;sequence:number})=>void;fail:(reason:unknown)=>void}>();
  const close = () => {
    if (closed) return;
    closed = true;
	toolLifetime.abort(new Error('Agent tool host closed'));
    if (module.doraStudioAgentEvent === receive) delete module.doraStudioAgentEvent;
    const observers = [...listeners];listeners.clear();
    for (const observer of observers) {try {observer.close?.();} catch {/* Continue releasing other observers. */}}
    for (const request of [...pending.values()]) request.fail(new Error('Agent WASM source closed'));
  };
  const receive = (payload:string) => {
    if (closed) return;
    try {
      if (payload.length > 1024*1024 || new TextEncoder().encode(payload).length > 1024*1024) throw new Error('Agent callback exceeds limit');
      const event = JSON.parse(payload);
      if (!event || event.sessionId !== sessionId || !Number.isSafeInteger(event.sequence) || event.sequence < 0 || typeof event.payload !== 'string') throw new Error('Invalid Agent callback binding');
      if (event.kind === 'snapshot') {
        // Initial and late snapshots cannot satisfy an unrelated pending request.
        const request = typeof event.requestId === 'string' ? pending.get(event.requestId) : undefined;
        if (!request) return;
        if(request.kind!=='snapshot')throw new Error('Mismatched Agent callback kind');
        decodeAgentSessionSnapshot(event.payload,sessionId);
        request.finish({payload:event.payload,sequence:event.sequence});
      } else if(event.kind==='command') {
        const request=typeof event.requestId==='string'?pending.get(event.requestId):undefined;
        if(!request)return;
        if(request.kind!=='command')throw new Error('Mismatched Agent callback kind');
        if(typeof event.payload!=='string'||event.payload.length>16384)throw new Error('Invalid Agent command response');
        request.finish({payload:event.payload,sequence:event.sequence});
      } else if(event.kind==='tool-request') {
		if(!toolHandler||typeof event.requestId!=='string'||!/^studio-tool-[1-9]\d*-[1-9]\d*$/.test(event.requestId)||activeTools.size>=1||activeTools.has(event.requestId)||event.payload.length>524288+4096)throw new Error('Invalid Agent tool callback');
		const input=JSON.parse(event.payload) as AgentToolRequest;
		if((input?.operation!=='transpile-ts'&&input?.operation!=='build-script'&&input?.operation!=='preview-game'&&input?.operation!=='execute-lua')||typeof input.file!=='string'||typeof input.projectRoot!=='string'||typeof input.content!=='string'||input.content.length>524288||input.file.length>1024||input.projectRoot.length>1024||!input.file.startsWith(input.projectRoot+'/')||input.file.slice(input.projectRoot.length+1).split('/').some(part=>!part||part==='.'||part==='..')||!/^\/user\/studio-project$/.test(input.projectRoot)
			|| (input.operation==='transpile-ts'?!/\.tsx?$/.test(input.file):input.operation==='build-script'?!/\.(tl|lua|yarn)$/.test(input.file):input.operation==='preview-game'?(!/\.lua$/.test(input.file)||input.content.length>2048):(!/\.lua$/.test(input.file)||input.content.length>140000)))throw new Error('Invalid Agent tool input');
		const id=event.requestId,controller=new AbortController();activeTools.set(id,controller);
		void toolHandler(input,AbortSignal.any([toolLifetime.signal,controller.signal])).then(reply=>{
			if(closed||controller.signal.aborted)return;
			if(reply.success?((input.operation==='transpile-ts'||input.operation==='build-script')?(!('luaCode' in reply)||typeof reply.luaCode!=='string'||new TextEncoder().encode(reply.luaCode).byteLength>1048576):(!('resultJSON' in reply)||typeof reply.resultJSON!=='string'||new TextEncoder().encode(reply.resultJSON).byteLength>262144)):(typeof reply.message!=='string'||new TextEncoder().encode(reply.message).byteLength>4096))throw new Error('Invalid Agent tool result');
			module.ccall('dora_web_agent_request',null,['string'],[JSON.stringify({operation:'tool-result',sessionId,requestId:id,result:reply})]);
		}).catch(error=>{
			if(closed||controller.signal.aborted)return;
			try{module.ccall('dora_web_agent_request',null,['string'],[JSON.stringify({operation:'tool-result',sessionId,requestId:id,result:{success:false,message:error instanceof Error?error.message.slice(0,4096):'Studio Agent tool unavailable'}})]);}
			catch{close();}
		}).finally(()=>activeTools.delete(id));
      } else if(event.kind==='tool-cancel') {
		if(typeof event.requestId!=='string'||!/^studio-tool-[1-9]\d*-[1-9]\d*$/.test(event.requestId)||event.payload!=='{}')throw new Error('Invalid Agent tool cancellation');
		activeTools.get(event.requestId)?.abort(new Error('Original Agent tool canceled'));
      } else if (event.kind === 'patch') {
        const patch = decodeAgentSessionPatch(event.payload);
        if (patch.sessionId !== sessionId || event.sequence <= 0) throw new Error('Invalid Agent patch binding');
        for (const listener of [...listeners]) listener.event(event.payload,event.sequence);
      } else throw new Error('Unknown Agent callback');
    } catch (error) {close();throw error;}
  };
  module.doraStudioAgentEvent = receive;
  const requestSnapshot = (signal:AbortSignal,operation:'snapshot'|'quiesce'):Promise<{payload:string;sequence:number}> => {
      return new Promise((resolve,reject) => {
        if (closed || pending.size >= 1) {reject(new Error('Agent snapshot unavailable or already pending'));return;}
        if (signal.aborted) {reject(signal.reason);return;}
        const requestId = crypto.randomUUID();
        const cleanup = () => {clearTimeout(timer);signal.removeEventListener('abort',abort);pending.delete(requestId);};
        const fail = (reason:unknown) => {cleanup();reject(reason);};
        const abort = () => fail(signal.reason ?? new DOMException('Aborted','AbortError'));
        const timer = setTimeout(() => fail(new Error('Agent snapshot timed out')),15000);
        pending.set(requestId,{kind:'snapshot',finish:value=>{cleanup();resolve(value);},fail});
        signal.addEventListener('abort',abort,{once:true});
        try {module.ccall('dora_web_agent_request',null,['string'],[JSON.stringify({operation,sessionId,requestId})]);}
        catch (error) {fail(error);}
      });
  };
  return {
    close,
    releaseQuiescence(signal:AbortSignal):Promise<void> {
      return new Promise((resolve,reject)=>{
        if(closed||pending.size>=1||signal.aborted){reject(new Error('Agent quiescence release unavailable'));return;}
        const requestId=crypto.randomUUID();
        const cleanup=()=>{clearTimeout(timer);signal.removeEventListener('abort',abort);pending.delete(requestId);};
        const fail=(reason:unknown)=>{cleanup();reject(reason);};
        const abort=()=>fail(signal.reason??new DOMException('Aborted','AbortError'));
        const timer=setTimeout(()=>fail(new Error('Agent quiescence release timed out')),15000);
        pending.set(requestId,{kind:'command',finish:value=>{
          cleanup();try{const result=JSON.parse(value.payload);if(result?.success===true)resolve();else reject(new Error('Agent quiescence release rejected'));}
          catch(error){reject(error);}
        },fail});
        signal.addEventListener('abort',abort,{once:true});
        try{module.ccall('dora_web_agent_request',null,['string'],[JSON.stringify({operation:'resume',sessionId,requestId})]);}
        catch(error){fail(error);}
      });
    },
    requestPrompt(prompt:string,options:AgentPromptOptions,llmConfig:Record<string,unknown>,requestId:string,signal:AbortSignal):Promise<number> {
      return new Promise((resolve,reject)=>{
        if(closed||pending.size>=1||signal.aborted||!requestId||!/^[0-9a-f-]{36}$/i.test(requestId)||pending.has(requestId)||typeof prompt!=='string'||!prompt.trim()||prompt.length>5000||!isAgentPromptOptions(options)){reject(new Error('Agent prompt request unavailable'));return;}
        const cleanup=()=>{clearTimeout(timer);signal.removeEventListener('abort',abort);pending.delete(requestId);};
        const fail=(reason:unknown)=>{cleanup();reject(reason);};
        const abort=()=>fail(signal.reason??new DOMException('Aborted','AbortError'));
        const timer=setTimeout(()=>fail(new Error('Agent prompt acknowledgement timed out; inspect the session before retrying')),20000);
        pending.set(requestId,{kind:'command',finish:value=>{
          cleanup();
          try{
            const result=JSON.parse(value.payload);
            if(result?.success===true&&Number.isSafeInteger(result.taskId)&&result.taskId>0)resolve(result.taskId);
            else if(result?.success===false&&typeof result.message==='string'&&result.message.length<=4096)reject(new Error(result.message));
            else reject(new Error('Invalid Agent prompt acknowledgement'));
          }catch(error){reject(error);}
        },fail});
        signal.addEventListener('abort',abort,{once:true});
        try{module.ccall('dora_web_agent_request',null,['string'],[JSON.stringify({operation:'prompt',sessionId,requestId,prompt,workMode:options.workMode,disabledAgentTools:options.disabledAgentTools,llmConfig})]);}
        catch(error){fail(error);}
      });
    },
    requestQuestionnaire(action:'respond'|'cancel',questionnaireId:number,answers:unknown[],llmConfig:Record<string,unknown>,requestId:string,signal:AbortSignal):Promise<number> {
      return new Promise((resolve,reject)=>{
        if(closed||pending.size>=1||signal.aborted||!/^[0-9a-f-]{36}$/i.test(requestId)||pending.has(requestId)||!Number.isSafeInteger(questionnaireId)||questionnaireId<=0||!Array.isArray(answers)||answers.length>3){reject(new Error('Agent questionnaire request unavailable'));return;}
        const cleanup=()=>{clearTimeout(timer);signal.removeEventListener('abort',abort);pending.delete(requestId);};
        const fail=(reason:unknown)=>{cleanup();reject(reason);};
        const abort=()=>fail(signal.reason??new DOMException('Aborted','AbortError'));
        const timer=setTimeout(()=>fail(new Error('Agent questionnaire acknowledgement timed out; inspect the session before retrying')),20000);
        pending.set(requestId,{kind:'command',finish:value=>{cleanup();try{const result=JSON.parse(value.payload);if(result?.success===true&&Number.isSafeInteger(result.taskId)&&result.taskId>0)resolve(result.taskId);else if(result?.success===false&&typeof result.message==='string'&&result.message.length<=4096)reject(new Error(result.message));else reject(new Error('Invalid Agent questionnaire acknowledgement'));}catch(error){reject(error);}},fail});
        signal.addEventListener('abort',abort,{once:true});
        try{module.ccall('dora_web_agent_request',null,['string'],[JSON.stringify({operation:`questionnaire-${action}`,sessionId,requestId,questionnaireId,...(action==='respond'?{answers}:{}),llmConfig})]);}
        catch(error){fail(error);}
      });
    },
    requestStop(requestId:string,signal:AbortSignal):Promise<void> {
      return new Promise((resolve,reject)=>{
        if(closed||pending.size>=1||signal.aborted||!/^[0-9a-f-]{36}$/i.test(requestId)||pending.has(requestId)){reject(new Error('Agent stop request unavailable'));return;}
        const cleanup=()=>{clearTimeout(timer);signal.removeEventListener('abort',abort);pending.delete(requestId);};
        const fail=(reason:unknown)=>{cleanup();reject(reason);};
        const abort=()=>fail(signal.reason??new DOMException('Aborted','AbortError'));
        const timer=setTimeout(()=>fail(new Error('Agent stop acknowledgement timed out')),15000);
        pending.set(requestId,{kind:'command',finish:value=>{cleanup();try{const result=JSON.parse(value.payload);if(result?.success===true)resolve();else reject(new Error(typeof result?.message==='string'?result.message:'Agent stop rejected'));}catch(error){reject(error);}},fail});
        signal.addEventListener('abort',abort,{once:true});
        try{module.ccall('dora_web_agent_request',null,['string'],[JSON.stringify({operation:'stop',sessionId,requestId})]);}
        catch(error){fail(error);}
      });
    },
    subscribe(listener,onClose) {
      if (closed) throw new Error('Agent WASM source closed');
      const observer = {event:listener,close:onClose};
      listeners.add(observer);return () => {listeners.delete(observer);};
    },
    capture: signal => requestSnapshot(signal,'snapshot'),
    async readFileCommits(signal) {
      const result=await requestSnapshot(signal,'snapshot');
      try{return decodeAgentFileCommitQueue(JSON.parse(result.payload).studioFileCommits);}
      catch(error){close();throw error;}
    },
    async quiesce(signal) {
      const result=await requestSnapshot(signal,'quiesce');
      try {return decodeAgentQuiescence(JSON.parse(result.payload).studioQuiescence);}
      catch(error) {close();throw error;}
    },
  };
}
