import {installAgentFrameHost} from './agent-frame-host';
import {createAgentWasmSource, type AgentHostModule} from './agent-wasm-source';
import {persistStoppedAgent} from './agent-persist-stopped';
import {installAgentProjectSnapshot,matchesInstalledAgentProject,readInstalledAgentFiles} from './agent-project-install';
import type {ProjectSnapshot} from '@dora-studio/contracts';
import {readAgentProjectBaseline,writeAgentProjectBaseline} from './agent-project-baseline';
import type {AgentProjectCapture} from './agent-project-capture';
import {transpileAgentTsTool} from './agent-tool-build';
import {previewAgentGameTool} from './agent-tool-preview-host';
import {executeAgentLuaTool} from './agent-tool-lua-host';
import {buildAgentScriptTool} from './agent-tool-script-build';
import type {AgentPromptOptions} from './agent-prompt-options';
import {persistSessionBoundariesBeforePublish,type DurableAgentSessionSource} from './agent-session-durability';
import {createAgentModelQueueStore,idleAgentModelQueue} from './agent-model-queue';

/** Owns transport and explicit stop/persist operations. close() does not imply
 * persistence; the runtime owner must await persist() before normal destruction.
 * Never install in a game Player.
 */
export function installAgentWasmHost(module:AgentHostModule, parentWindow:Window, parentOrigin:string,
  binding:{projectId:string;generation:string;sessionId:number;projectRoot?:string}) {
  let host:ReturnType<typeof installAgentFrameHost>|undefined;
  let unsubscribe:(()=>void)|undefined;
  let closed = false;
  let persisting = false;
  let authorBaseline:ProjectSnapshot|undefined;
  let baselineLoaded=false,baselineRevision:number|undefined;
  const source = createAgentWasmSource(module,binding.sessionId,module.FS&&binding.projectRoot==='/user/studio-project'
    ?(request,signal)=>request.operation==='transpile-ts'
      ?transpileAgentTsTool(module.FS!,binding.projectId,request,signal)
      :request.operation==='build-script'
      ?buildAgentScriptTool(module.FS!,binding.projectId,request,signal)
      :request.operation==='preview-game'
      ?previewAgentGameTool(module.FS!,binding.projectId,baselineRevision??0,request,
        (artifact,times,operation)=>{
          if(!host)throw new Error('Agent Player preview connection unavailable');
          return host.requestPreview(artifact,times,operation);
        },signal)
      :executeAgentLuaTool(module.FS!,binding.projectId,baselineRevision??0,request,
        (artifact,commandId,timeoutSeconds,operation)=>{
          if(!host)throw new Error('Agent Lua Player connection unavailable');
          return host.requestLua(artifact,commandId,timeoutSeconds,operation);
        },signal):undefined);
  const lifetime = new AbortController();
  let leaseTimer:ReturnType<typeof setInterval>|undefined;
  let queueTimer:ReturnType<typeof setInterval>|undefined,queuePolling=false;
  const modelQueue=createAgentModelQueueStore();
  const close = () => {
    if (closed) return;
    closed = true;
    lifetime.abort(new Error('Agent host closed'));
    if(leaseTimer!==undefined)clearInterval(leaseTimer);
    if(queueTimer!==undefined)clearInterval(queueTimer);
    window.removeEventListener('pagehide',close);
    unsubscribe?.();
    try {host?.close();} finally {source.close();}
  };
  const publishedSource:DurableAgentSessionSource=binding.projectRoot==='/user/studio-project'&&module.doraSyncUserStorage
    ?persistSessionBoundariesBeforePublish(source,()=>module.doraSyncUserStorage!({afterCurrent:true}),lifetime.signal)
    :Object.assign(source,{waitForDurability:()=>Promise.resolve()});
  try {
    host = installAgentFrameHost(parentWindow,parentOrigin,binding,publishedSource,{persist:signal=>persist(signal),modelQueue,
      ...(binding.projectRoot==='/user/studio-project' && module.FS && module.doraSyncUserStorage ? {syncProject:(snapshot:ProjectSnapshot,signal:AbortSignal)=>syncProject(snapshot,signal),captureProject:(signal:AbortSignal)=>captureProject(signal),captureLiveProject:(signal:AbortSignal)=>captureLiveProject(signal),sendPrompt:(prompt:string,grantId:string,requestId:string,options:AgentPromptOptions,signal:AbortSignal)=>sendPrompt(prompt,grantId,requestId,options,signal),handleQuestionnaire:(action:'respond'|'cancel',questionnaireId:number,answers:unknown[],grantId:string,requestId:string,signal:AbortSignal)=>handleQuestionnaire(action,questionnaireId,answers,grantId,requestId,signal),stopTask:(requestId:string,signal:AbortSignal)=>source.requestStop(requestId,signal)} : {})});
    unsubscribe = source.subscribe(()=>{},close);
    window.addEventListener('pagehide',close,{once:true});
    // Launch assets are deliberately short-lived. Keep only this authenticated,
    // active host's lease alive, so model calls during a long Agent task do not
    // fail five minutes after startup. A revoked account/session cannot renew.
    const renewLease=async()=>{
      if(closed)return;
      try{
        const url=new URL('./renew',location.href);
        const response=await fetch(url,{method:'POST',credentials:'same-origin',cache:'no-store',redirect:'error',
          headers:{'Content-Type':'application/json'},signal:AbortSignal.any([lifetime.signal,AbortSignal.timeout(10000)])});
        if(!response.ok)throw new Error('Agent launch renewal rejected');
        const data=await response.json();
        if(data?.version!==1||!Number.isSafeInteger(data.expiresAt)||data.expiresAt<=Date.now())throw new Error('Invalid Agent launch lease');
      }catch(error){if(!closed)console.warn('Studio Agent host lease unavailable');}
    };
    const pollModelQueue=async()=>{
      if(closed||queuePolling)return;queuePolling=true;
      try{
        const response=await fetch(new URL('./model-queue',location.href),{method:'GET',credentials:'same-origin',cache:'no-store',redirect:'error',signal:AbortSignal.any([lifetime.signal,AbortSignal.timeout(5000)])});
        if(!response.ok)throw new Error('Agent model queue unavailable');
        modelQueue.update(await response.json());
      }catch{if(!closed)modelQueue.update(idleAgentModelQueue);}
      finally{queuePolling=false;}
    };
    // Non-browser Agent lifecycle unit fixtures have no page URL or timer.
    if(typeof location!=='undefined'&&typeof location.href==='string'){
      void renewLease();
      leaseTimer=setInterval(()=>void renewLease(),60_000);
      void pollModelQueue();
      queueTimer=setInterval(()=>void pollModelQueue(),1_000);
    }
  } catch(error) {close();throw error;}
  const syncProject=async(snapshot:ProjectSnapshot,signal:AbortSignal)=>{
    if(closed || persisting || !module.FS || !module.doraSyncUserStorage || snapshot.projectId!==binding.projectId)throw new Error('Agent author synchronization unavailable');
    const operation=AbortSignal.any([signal,lifetime.signal]);
    persisting=true;
    try{
      operation.throwIfAborted();
      const state=await source.quiesce(operation);
      if(!state.quiescent || state.pending.length)throw new Error('Agent tasks must finish before author synchronization');
      operation.throwIfAborted();
      if(!baselineLoaded){
        const stored=await readAgentProjectBaseline(module.FS,binding.projectId,operation);
        authorBaseline=stored?.snapshot;baselineRevision=stored?.revision;baselineLoaded=true;
      }
      if(baselineRevision!==undefined && (snapshot.revision<baselineRevision || (snapshot.revision===baselineRevision && !authorBaseline)))throw new Error('Author revision does not reconcile the persisted baseline');
      // A verified persisted baseline permits one-sided author edits after reopening.
      const existing=module.FS.readdir('/user/studio-project').filter(name=>name!=='.'&&name!=='..'&&name!=='.agent');
      const alreadyInstalled=matchesInstalledAgentProject(module.FS,snapshot);
      if(baselineRevision!==undefined && !authorBaseline && !alreadyInstalled)throw new Error('Persisted author files changed and require reconciliation');
      if(authorBaseline){
        const unchanged=matchesInstalledAgentProject(module.FS,authorBaseline);
        if(snapshot.revision<authorBaseline.revision || (snapshot.revision===authorBaseline.revision && (!unchanged || !alreadyInstalled)))throw new Error('Stale author revision');
        if(!alreadyInstalled){
          if(!unchanged)throw new Error('Agent author files changed since the acknowledged baseline');
          installAgentProjectSnapshot(module.FS,snapshot);
        }
      }else if(existing.length){
        if(!alreadyInstalled)throw new Error('Existing author files require reconciliation before replacement');
      }else installAgentProjectSnapshot(module.FS,snapshot);
      await writeAgentProjectBaseline(module.FS,snapshot,operation);
      await module.doraSyncUserStorage({afterCurrent:true});
      operation.throwIfAborted();
      authorBaseline=structuredClone(snapshot);
      baselineRevision=snapshot.revision;
      // The original Agent's project admission hold was acquired before the
      // file swap. Reopen only after both the author baseline and IDBFS sync
      // are confirmed; any failure keeps task admission closed.
      await source.releaseQuiescence(operation);
    }finally{persisting=false;}
  };
  const persist=async (signal:AbortSignal) => {
    if(closed)throw new Error('Agent host closed');
    if(persisting)throw new Error('Agent persistence already in progress');
    if(!module.doraSyncUserStorage)throw new Error('Agent persistent storage unavailable');
    const operation=new AbortController();
    const cancelled=()=>operation.abort(signal.reason ?? new DOMException('Aborted','AbortError'));
    const retired=()=>operation.abort(lifetime.signal.reason);
    signal.addEventListener('abort',cancelled,{once:true});
    lifetime.signal.addEventListener('abort',retired,{once:true});
    if(signal.aborted)cancelled();
    persisting=true;
    try {
      await persistStoppedAgent(source,{doraSyncUserStorage:options=>module.doraSyncUserStorage!(options)},operation.signal);
    } finally {
      persisting=false;
      signal.removeEventListener('abort',cancelled);
      lifetime.signal.removeEventListener('abort',retired);
    }
  };
  const loadModelConfig=async(grantId:string,operation:AbortSignal)=>{
      if(!/^[A-Za-z0-9_-]{1,128}$/.test(grantId))throw new Error('Invalid Agent model grant');
      const url=new URL(`./model-config/${grantId}`,location.href);
      const expectedURL=new URL(`./model/${grantId}`,location.href).href;
      const expectedVisionURL=new URL(`./vision/${grantId}`,location.href).href;
      const response=await fetch(url,{method:'GET',credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation});
      if(!response.ok||!response.body)throw new Error('Agent model authorization unavailable');
      const reader=response.body.getReader(),decoder=new TextDecoder('utf-8',{fatal:true});let size=0,raw='';
      try{for(;;){const {done,value}=await reader.read();if(done)break;size+=value.byteLength;if(size>16384)throw new Error('Agent model binding too large');raw+=decoder.decode(value,{stream:true});}raw+=decoder.decode();}
      finally{await reader.cancel();reader.releaseLock();}
      const page=JSON.parse(raw),config=page?.llmConfig;
      if(page?.version!==1||page.grantId!==grantId||!config||typeof config!=='object'||Array.isArray(config)||config.url!==expectedURL||config.apiKey!=='studio-agent'||config.studioGateway!==true||typeof config.model!=='string'||!config.model||!Number.isSafeInteger(config.maxTokens)||config.maxTokens<1||config.maxTokens>65536||!config.customOptions?.auxiliaryOptions)throw new Error('Invalid Agent model binding');
      const vision=config.studioVision;
      if(vision!==undefined&&(!vision||typeof vision!=='object'||Array.isArray(vision)||vision.url!==expectedVisionURL||
        !((vision.provider==='deepseek'&&vision.model==='deepseek-flash')||(vision.provider==='glm-coding-cn'&&vision.model==='glm-5.3-flash'))))throw new Error('Invalid Agent vision binding');
      operation.throwIfAborted();return config as Record<string,unknown>;
  };
  const sendPrompt=async(prompt:string,grantId:string,requestId:string,options:AgentPromptOptions,signal:AbortSignal):Promise<number>=>{
    if(closed||persisting||!authorBaseline||baselineRevision===undefined||!binding.projectRoot||binding.projectRoot!=='/user/studio-project')throw new Error('Agent prompt requires a synchronized author project');
    const operation=AbortSignal.any([signal,lifetime.signal]);persisting=true;
    try{
      const config=await loadModelConfig(grantId,operation);
      const taskId=await source.requestPrompt(prompt,options,config,requestId,operation);
      await publishedSource.waitForDurability();
      operation.throwIfAborted();
      return taskId;
    }catch(error){
      // No supplier response or Key is surfaced at this host-command stage.
      console.warn('Studio Agent prompt command:',error instanceof Error?error.message.slice(0,256):'unavailable');
      throw error;
    }finally{persisting=false;}
  };
  const handleQuestionnaire=async(action:'respond'|'cancel',questionnaireId:number,answers:unknown[],grantId:string,requestId:string,signal:AbortSignal):Promise<number>=>{
    if(closed||persisting||!authorBaseline||baselineRevision===undefined||binding.projectRoot!=='/user/studio-project')throw new Error('Agent questionnaire requires a synchronized author project');
    const operation=AbortSignal.any([signal,lifetime.signal]);persisting=true;
    try{const config=await loadModelConfig(grantId,operation);const taskId=await source.requestQuestionnaire(action,questionnaireId,answers,config,requestId,operation);await publishedSource.waitForDurability();operation.throwIfAborted();return taskId;}
    catch(error){console.warn('Studio Agent questionnaire command:',error instanceof Error?error.message.slice(0,256):'unavailable');throw error;}
    finally{persisting=false;}
  };
  const captureProject=async(signal:AbortSignal):Promise<AgentProjectCapture>=>{
    if(closed||persisting||binding.projectRoot!=='/user/studio-project'||!module.FS)throw new Error('Agent project capture unavailable');
    const operation=AbortSignal.any([signal,lifetime.signal]);
    persisting=true;
    try{
      operation.throwIfAborted();
      const state=await source.quiesce(operation);
      if(!state.quiescent||state.pending.length)throw new Error('Agent tasks must finish before project capture');
      operation.throwIfAborted();
      const files=readInstalledAgentFiles(module.FS);
      // Keep admission closed. Capturing is neither author commit nor IDBFS sync.
      return {projectId:binding.projectId,generation:binding.generation,sessionId:binding.sessionId,reconciliationRequired:true as const,files};
    }finally{persisting=false;}
  };
  const captureLiveProject=async(signal:AbortSignal):Promise<AgentProjectCapture>=>{
    if(closed||persisting||binding.projectRoot!=='/user/studio-project'||!module.FS)throw new Error('Agent live project capture unavailable');
    const operation=AbortSignal.any([signal,lifetime.signal]);persisting=true;
    try{operation.throwIfAborted();const files=readInstalledAgentFiles(module.FS);operation.throwIfAborted();return {projectId:binding.projectId,generation:binding.generation,sessionId:binding.sessionId,reconciliationRequired:true as const,files};}
    finally{persisting=false;}
  };
  return {close,persist,captureProject};
}
