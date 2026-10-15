import {openAgentSessionSnapshot, type AgentSessionController} from './agent-session-controller';
import type {AgentProjectSnapshot} from './agent-project-snapshot';
import {decodeAgentProjectCapture,type AgentProjectCapture} from './agent-project-capture';
import {isBuildArtifact,type BuildArtifact} from '@dora-studio/contracts';
import type {AgentPreviewCapture} from './agent-tool-preview-host';
import type {AgentLuaCommandResult} from './agent-tool-lua-host';
import {isAgentPromptOptions,type AgentPromptOptions} from './agent-prompt-options';
import {createAgentModelQueueStore,type AgentModelQueueStore} from './agent-model-queue';

export type AgentPreviewHandler=(artifact:BuildArtifact,captureAtSeconds:readonly number[],signal:AbortSignal)=>Promise<readonly AgentPreviewCapture[]>;
export type AgentLuaHandler=(artifact:BuildArtifact,commandId:string,timeoutSeconds:number,signal:AbortSignal)=>Promise<AgentLuaCommandResult>;

/** The caller must obtain this dedicated port from its authenticated Agent host.
 * Port ownership is a capability; never accept a port supplied by game code.
 * Host sends one snapshot before patches on the same FIFO channel.
 */
export function connectAgentSessionPort(port: MessagePort, binding: {projectId:string;generation:string;sessionId:number}, signal: AbortSignal, timeoutMs = 15000): Promise<{controller:AgentSessionController;modelQueue:AgentModelQueueStore;close:()=>void;canPersist:boolean;persist:()=>Promise<void>;canSyncProject:boolean;syncProject:(snapshot:AgentProjectSnapshot)=>Promise<void>;canCaptureProject:boolean;captureProject:()=>Promise<AgentProjectCapture>;canCaptureLiveProject:boolean;captureLiveProject:()=>Promise<AgentProjectCapture>;canSendPrompt:boolean;sendPrompt:(prompt:string,grantId:string,requestId:string,options:AgentPromptOptions)=>Promise<number>;canHandleQuestionnaire:boolean;handleQuestionnaire:(action:'respond'|'cancel',questionnaireId:number,answers:unknown[],grantId:string,requestId:string)=>Promise<number>;canStopTask:boolean;stopTask:(requestId:string)=>Promise<void>;setPreviewHandler:(handler:AgentPreviewHandler|undefined)=>void;setLuaHandler:(handler:AgentLuaHandler|undefined)=>void}> {
  const expected = {projectId:binding.projectId, generation:binding.generation, sessionId:binding.sessionId};
  return new Promise((resolve, reject) => {
    let controller: AgentSessionController | undefined;
    let retired = false;
    let timer: ReturnType<typeof setTimeout> | undefined;
    let canPersist=false,canSyncProject=false,canCaptureProject=false,canCaptureLiveProject=false,canSendPrompt=false,canHandleQuestionnaire=false,canStopTask=false;
    let previewHandler:AgentPreviewHandler|undefined;
    let luaHandler:AgentLuaHandler|undefined;
    let modelQueue:ReturnType<typeof createAgentModelQueueStore>|undefined;
    let preview:{id:string;controller:AbortController}|undefined;
    let lua:{id:string;controller:AbortController}|undefined;
    let operation:{id:string;type:'persisted'|'project-synced'|'project-captured'|'live-project-captured'|'prompt-sent'|'questionnaire-handled'|'task-stopped';revision?:number;resolve:(value?:AgentProjectCapture|number)=>void;reject:(error:unknown)=>void;timer:ReturnType<typeof setTimeout>}|undefined;
    const cleanup = () => {
      if (timer !== undefined) clearTimeout(timer);
      if(operation){clearTimeout(operation.timer);operation.reject(new Error('Agent persistence connection closed'));operation=undefined;}
      preview?.controller.abort(new Error('Agent preview connection closed'));preview=undefined;previewHandler=undefined;
      lua?.controller.abort(new Error('Agent Lua connection closed'));lua=undefined;luaHandler=undefined;
      port.removeEventListener('message', onMessage);
      port.removeEventListener('messageerror', onError);
      signal.removeEventListener('abort', onAbort);
      try {port.postMessage({type:'unsubscribe',version:1,...expected});} catch {/* Peer may already be gone. */}
      port.close();
    };
    const close = () => {
      if (retired) return;
      retired = true; cleanup(); controller?.close();
      if (!controller) reject(new Error('Agent session connection closed'));
    };
    const fail = (error: unknown) => {
      if (retired) return;
      retired = true; cleanup(); controller?.close();
      if (!controller) reject(error);
    };
    const onAbort = () => fail(signal.reason ?? new DOMException('Aborted','AbortError'));
    const onError = () => fail(new Error('Agent session message could not be decoded'));
    const persist=():Promise<void>=>new Promise((resolve,reject)=>{
      if(retired || !controller || !canPersist){reject(new Error('Agent persistence unavailable'));return;}
      if(operation){reject(new Error('Agent persistence already in progress'));return;}
      const id=crypto.randomUUID();
      operation={id,type:'persisted',resolve:()=>resolve(),reject,timer:setTimeout(()=>fail(new Error('Agent persistence response timed out')),20000)};
      try {port.postMessage({type:'persist',version:1,...expected,requestId:id});}catch(error){fail(error);}
    });
    const syncProject=(snapshot:AgentProjectSnapshot):Promise<void>=>new Promise((resolve,reject)=>{
      if(retired || !controller || !canSyncProject || operation || snapshot.projectId!==expected.projectId || !Number.isSafeInteger(snapshot.revision) || snapshot.revision<0){reject(new Error('Agent project synchronization unavailable'));return;}
      const id=crypto.randomUUID();
      operation={id,type:'project-synced',revision:snapshot.revision,resolve:()=>resolve(),reject,timer:setTimeout(()=>fail(new Error('Agent project synchronization timed out')),20000)};
      try{port.postMessage({type:'sync-project',version:1,...expected,requestId:id,snapshot});}catch(error){fail(error);}
    });
    const captureProject=():Promise<AgentProjectCapture>=>new Promise((resolve,reject)=>{
      if(retired||!controller||!canCaptureProject||operation){reject(new Error('Agent project capture unavailable'));return;}
      const id=crypto.randomUUID();
      operation={id,type:'project-captured',resolve:value=>value&&typeof value==='object'?resolve(value):reject(new Error('Missing Agent capture')),reject,timer:setTimeout(()=>fail(new Error('Agent project capture timed out')),20000)};
      try{port.postMessage({type:'capture-project',version:1,...expected,requestId:id});}catch(error){fail(error);}
    });
    const captureLiveProject=():Promise<AgentProjectCapture>=>new Promise((resolve,reject)=>{
      if(retired||!controller||!canCaptureLiveProject||operation){reject(new Error('Agent live project capture unavailable'));return;}
      const id=crypto.randomUUID();operation={id,type:'live-project-captured',resolve:value=>value&&typeof value==='object'?resolve(value as AgentProjectCapture):reject(new Error('Missing Agent live project capture')),reject,timer:setTimeout(()=>fail(new Error('Agent live project capture timed out')),20000)};
      try{port.postMessage({type:'capture-live-project',version:1,...expected,requestId:id});}catch(error){fail(error);}
    });
    const sendPrompt=(prompt:string,grantId:string,requestId:string,options:AgentPromptOptions):Promise<number>=>new Promise((resolve,reject)=>{
      if(retired||!controller||!canSendPrompt||operation||typeof prompt!=='string'||!prompt.trim()||prompt.length>5000||!/^[A-Za-z0-9_-]{1,128}$/.test(grantId)||!/^[0-9a-f-]{36}$/i.test(requestId)||!isAgentPromptOptions(options)){reject(new Error('Agent prompt unavailable or invalid'));return;}
      operation={id:requestId,type:'prompt-sent',resolve:value=>typeof value==='number'?resolve(value):reject(new Error('Missing Agent task acknowledgement')),reject,timer:setTimeout(()=>fail(new Error('Agent prompt acknowledgement timed out; inspect session before retrying')),20000)};
      try{port.postMessage({type:'send-prompt',version:1,...expected,requestId,prompt,grantId,options});}catch(error){fail(error);}
    });
    const handleQuestionnaire=(action:'respond'|'cancel',questionnaireId:number,answers:unknown[],grantId:string,requestId:string):Promise<number>=>new Promise((resolve,reject)=>{
      if(retired||!controller||!canHandleQuestionnaire||operation||!Number.isSafeInteger(questionnaireId)||questionnaireId<=0||!Array.isArray(answers)||answers.length>3||!/^[A-Za-z0-9_-]{1,128}$/.test(grantId)||!/^[0-9a-f-]{36}$/i.test(requestId)||JSON.stringify(answers).length>65536){reject(new Error('Agent questionnaire unavailable or invalid'));return;}
      operation={id:requestId,type:'questionnaire-handled',resolve:value=>typeof value==='number'?resolve(value):reject(new Error('Missing Agent questionnaire acknowledgement')),reject,timer:setTimeout(()=>fail(new Error('Agent questionnaire acknowledgement timed out; inspect session before retrying')),20000)};
      try{port.postMessage({type:`questionnaire-${action}`,version:1,...expected,requestId,questionnaireId,...(action==='respond'?{answers}:{}),grantId});}catch(error){fail(error);}
    });
    const stopTask=(requestId:string):Promise<void>=>new Promise((resolve,reject)=>{
      if(retired||!controller||!canStopTask||operation||!/^[0-9a-f-]{36}$/i.test(requestId)){reject(new Error('Agent stop unavailable'));return;}
      operation={id:requestId,type:'task-stopped',resolve:()=>resolve(),reject,timer:setTimeout(()=>fail(new Error('Agent stop acknowledgement timed out; inspect session before retrying')),20000)};
      try{port.postMessage({type:'stop-task',version:1,...expected,requestId});}catch(error){fail(error);}
    });
    const setPreviewHandler=(handler:AgentPreviewHandler|undefined)=>{previewHandler=handler;};
    const setLuaHandler=(handler:AgentLuaHandler|undefined)=>{luaHandler=handler;};
    const onMessage = (event: MessageEvent<unknown>) => {
      if (retired) return;
      try {
        const value = event.data;
        if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error('Invalid Agent transport message');
        const message = value as Record<string, unknown>;
        if (!controller) {
          if (message.type !== 'snapshot') throw new Error('Agent transport requires an initial snapshot');
          controller = openAgentSessionSnapshot(expected, value);
          modelQueue=createAgentModelQueueStore(message.modelQueue);
          canPersist=message.canPersist===true;
          canSyncProject=message.canSyncProject===true;
          canCaptureProject=message.canCaptureProject===true;
          canCaptureLiveProject=message.canCaptureLiveProject===true;
          canSendPrompt=message.canSendPrompt===true;
          canHandleQuestionnaire=message.canHandleQuestionnaire===true;
          canStopTask=message.canStopTask===true;
          if (timer !== undefined) clearTimeout(timer);
          resolve({controller,modelQueue,close,canPersist,persist,canSyncProject,syncProject,canCaptureProject,captureProject,canCaptureLiveProject,captureLiveProject,canSendPrompt,sendPrompt,canHandleQuestionnaire,handleQuestionnaire,canStopTask,stopTask,setPreviewHandler,setLuaHandler});
        } else {
          if(message.type==='model-queue'){
            if(message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId)throw new Error('Invalid Agent model queue message');
            modelQueue!.update(message.modelQueue);return;
          }
          if(message.type==='preview-cancel'){
            if(message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId
              ||typeof message.requestId!=='string'||!/^[0-9a-f-]{36}$/i.test(message.requestId))throw new Error('Invalid Agent preview cancellation');
            if(preview?.id===message.requestId){preview.controller.abort(new Error('Original Agent preview canceled'));preview=undefined;}
            return;
          }
          if(message.type==='lua-cancel'){
            if(message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId
              ||typeof message.requestId!=='string'||!/^[0-9a-f-]{36}$/i.test(message.requestId))throw new Error('Invalid Agent Lua cancellation');
            if(lua?.id===message.requestId){lua.controller.abort(new Error('Original Agent Lua command canceled'));lua=undefined;}
            return;
          }
          if(message.type==='preview-request'){
            const times=message.captureAtSeconds,agentArtifact=message.artifact;
            if(message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId
              ||typeof message.requestId!=='string'||!/^[0-9a-f-]{36}$/i.test(message.requestId)
              ||!isBuildArtifact(agentArtifact)||agentArtifact.projectId!==expected.projectId
              ||!Array.isArray(times)||times.length<1||times.length>3
              ||times.some((time:unknown,index:number)=>typeof time!=='number'||!Number.isFinite(time)||time<0||time>10||(index>0&&time<=Number(times[index-1]))))throw new Error('Invalid Agent preview request');
            const id=message.requestId,handler=previewHandler;
            if(!handler||preview||lua){port.postMessage({type:'preview-result',version:1,...expected,requestId:id,success:false,message:'Agent Player preview unavailable'});return;}
            const controller=new AbortController();preview={id,controller};
            void handler(agentArtifact,times,controller.signal).then(frames=>{
              if(retired||preview?.id!==id||controller.signal.aborted)return;
              if(frames.length!==times.length||frames.some(frame=>!(frame.png instanceof Uint8Array)||frame.png.byteLength>12*1024*1024
                ||!Number.isSafeInteger(frame.width)||!Number.isSafeInteger(frame.height)||!Number.isFinite(frame.elapsedSeconds)))throw new Error('Invalid Agent preview frames');
              port.postMessage({type:'preview-result',version:1,...expected,requestId:id,success:true,captures:frames});
            }).catch(error=>{if(!retired&&preview?.id===id&&!controller.signal.aborted)port.postMessage({type:'preview-result',version:1,...expected,requestId:id,success:false,message:error instanceof Error?error.message.slice(0,4096):'Agent Player preview failed'});})
              .finally(()=>{if(preview?.id===id)preview=undefined;});
            return;
          }
          if(message.type==='lua-request'){
            const agentArtifact=message.artifact,commandId=message.commandId,timeoutSeconds=message.timeoutSeconds;
            if(message.version!==1||message.projectId!==expected.projectId||message.generation!==expected.generation||message.sessionId!==expected.sessionId
              ||typeof message.requestId!=='string'||!/^[0-9a-f-]{36}$/i.test(message.requestId)
              ||!isBuildArtifact(agentArtifact)||agentArtifact.projectId!==expected.projectId
              ||typeof commandId!=='string'||!/^[a-zA-Z0-9_-]{1,128}$/.test(commandId)
              ||!Number.isSafeInteger(timeoutSeconds)||Number(timeoutSeconds)<1||Number(timeoutSeconds)>600)throw new Error('Invalid Agent Lua request');
            const id=message.requestId,handler=luaHandler;
            if(!handler||lua||preview){port.postMessage({type:'lua-result',version:1,...expected,requestId:id,success:false,message:'Agent Lua Player unavailable'});return;}
            const controller=new AbortController();lua={id,controller};
            void handler(agentArtifact,commandId,Number(timeoutSeconds),controller.signal).then(result=>{
              if(retired||lua?.id!==id||controller.signal.aborted)return;
              if(!result||typeof result.success!=='boolean'||typeof result.output!=='string'||new TextEncoder().encode(result.output).byteLength>131072
                ||(result.message!==undefined&&(typeof result.message!=='string'||new TextEncoder().encode(result.message).byteLength>16384)))throw new Error('Invalid Agent Lua Player result');
              port.postMessage({type:'lua-result',version:1,...expected,requestId:id,success:true,result});
            }).catch(error=>{if(!retired&&lua?.id===id&&!controller.signal.aborted)port.postMessage({type:'lua-result',version:1,...expected,requestId:id,success:false,message:error instanceof Error?error.message.slice(0,4096):'Agent Lua Player failed'});})
              .finally(()=>{if(lua?.id===id)lua=undefined;});
            return;
          }
          if(message.type==='persisted' || message.type==='project-synced' || message.type==='project-captured'||message.type==='live-project-captured'||message.type==='prompt-sent'||message.type==='questionnaire-handled'||message.type==='task-stopped') {
            if(!operation || message.type!==operation.type || message.requestId!==operation.id || message.version!==1 || message.projectId!==expected.projectId || message.generation!==expected.generation || message.sessionId!==expected.sessionId || typeof message.success!=='boolean'
              || (message.type==='project-synced' && message.success && message.revision!==operation.revision)
              || ((message.type==='prompt-sent'||message.type==='questionnaire-handled') && message.success && (!Number.isSafeInteger(message.taskId)||Number(message.taskId)<=0)))throw new Error('Invalid Agent operation response');
            const captured=(message.type==='project-captured'||message.type==='live-project-captured')&&message.success?decodeAgentProjectCapture(message.capture,expected):undefined;
            const taskId=(message.type==='prompt-sent'||message.type==='questionnaire-handled')&&message.success?Number(message.taskId):undefined;
            const completed=operation;operation=undefined;clearTimeout(completed.timer);
            if(message.success)completed.resolve(captured??taskId);else completed.reject(new Error(completed.type==='persisted'?'Agent persistence failed; host retained':completed.type==='project-captured'?'Agent project capture failed':completed.type==='prompt-sent'?'Agent prompt rejected; inspect session before retrying':completed.type==='questionnaire-handled'?'Agent questionnaire rejected; inspect session before retrying':'Agent project synchronization failed'));
            return;
          }
          if (message.type !== 'patch') throw new Error('Unexpected Agent transport message');
          const result = controller.receive(value);
          if (result === 'resync-required' || controller.closed) {
            retired = true;
            cleanup(); // Preserve the explicit resync state instead of replacing it with closed.
          }
        }
      } catch (error) {fail(error);}
    };
    if (!expected.projectId || !expected.generation || !Number.isSafeInteger(expected.sessionId) || expected.sessionId <= 0) {fail(new Error('Invalid Agent session binding'));return;}
    if (!Number.isFinite(timeoutMs) || timeoutMs <= 0 || timeoutMs > 60000) {fail(new Error('Invalid Agent connection timeout'));return;}
    if (signal.aborted) {onAbort();return;}
    signal.addEventListener('abort', onAbort, {once:true});
    port.addEventListener('message', onMessage);
    port.addEventListener('messageerror', onError);
    timer = setTimeout(() => fail(new Error('Agent session connection timed out')), timeoutMs);
    try {
      port.start();
      port.postMessage({type:'subscribe',version:1,...expected});
    } catch (error) {fail(error);}
  });
}
