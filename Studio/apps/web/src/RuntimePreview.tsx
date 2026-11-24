import {type StudioMessage, useStudioI18n} from './i18n';
import { forwardRef, useEffect, useImperativeHandle, useRef, useState, type ReactNode } from 'react';
import type { BuildArtifact } from '@dora-studio/contracts';
import { RuntimeHost } from './runtime-host';
import { runtimeSupportProblem } from './runtime-support';
import type {AgentPreviewCapture} from './agent-tool-preview-host';
import type {AgentLuaCommandResult} from './agent-tool-lua-host';

export interface RuntimePreviewHandle {
  ready():boolean;
  previewAgent(artifact:BuildArtifact,captureAtSeconds:readonly number[],signal:AbortSignal):Promise<readonly AgentPreviewCapture[]>;
  executeAgentLua(artifact:BuildArtifact,commandId:string,signal:AbortSignal):Promise<AgentLuaCommandResult>;
}

export const RuntimePreview=forwardRef<RuntimePreviewHandle,{ artifact: BuildArtifact | null;resolveArtifact?:()=>Promise<BuildArtifact>;controls?:ReactNode;autoRunBuildId?:string|undefined;onAutoRunConsumed?:()=>void }>(function RuntimePreview({ artifact,resolveArtifact,controls,autoRunBuildId,onAutoRunConsumed },ref) {
  const {t} = useStudioI18n();
  const container = useRef<HTMLDivElement>(null), host = useRef<RuntimeHost | undefined>(undefined);
  const startGeneration=useRef(0);
  const [status, setStatus] = useState<StudioMessage | string>(['projects.runtimeWaiting']), [active, setActive] = useState(false);
  const [logs, setLogs] = useState<{ level: string; message: string }[]>([]);
  const runtimeURL = import.meta.env.VITE_DORA_RUNTIME_URL;
  const engineBuild = import.meta.env.VITE_DORA_ENGINE_BUILD;
  const configurationProblem=!runtimeURL?'projects.runtimeNoUrl':!engineBuild?'projects.runtimeNoVersion':undefined;
  const toolbarStatus=typeof status==='string'?status:status[0]==='projects.runtimeWaiting'||status[0]==='projects.runtimeStopped'?'':t(...status);
  useEffect(() => {
    if (!container.current) return;
    if(configurationProblem){setStatus([configurationProblem]);return;}
    const instance = new RuntimeHost(container.current, { runtimeURL, engineBuild,
      onEvent(event) {
        if (event.type === 'log') { setLogs(previous => [...previous.slice(-199), { level: event.level, message: event.message.slice(0, 8192) }]); return; }
        if (event.type === 'error') { setStatus(event.message); setActive(false); }
        else if (event.type === 'state') {
          setStatus([({loading:'projects.runtimeLoading', ready:'projects.runtimeStarting', running:'projects.runtimeRunning', suspended:'projects.runtimePaused', stopped:'projects.runtimeStopped'} as const)[event.state]]);
          if (event.state === 'stopped') setActive(false);
        }
      } });
    host.current = instance;
    return () => { instance.stop(); host.current = undefined; };
  }, [runtimeURL, engineBuild,configurationProblem]);
  useEffect(() => {
    if(!active)setStatus([configurationProblem??'projects.runtimeWaiting']);
    // A newly compiled artifact is adopted by the next run. It must not stop
    // the immutable artifact snapshot already running in the Player.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [artifact,configurationProblem]);
  useEffect(() => {
    if(!artifact||!autoRunBuildId||artifact.buildId!==autoRunBuildId)return;
    onAutoRunConsumed?.();
    start();
  }, [artifact,autoRunBuildId]);
  useImperativeHandle(ref,()=>({
    ready:()=>!!host.current,
    previewAgent:async(agentArtifact,times,signal)=>{
      const instance=host.current;
      if(!instance)throw new Error(t('projects.runtimeNotReady'));
      const problem=runtimeSupportProblem({secure:window.isSecureContext,isolated:window.crossOriginIsolated,
        sharedMemory:typeof SharedArrayBuffer!=='undefined',offscreen:typeof OffscreenCanvas!=='undefined',
        transferCanvas:typeof HTMLCanvasElement.prototype.transferControlToOffscreen==='function'});
      if(problem)throw new Error(t(problem));
      signal.throwIfAborted();setLogs([]);setStatus(['projects.agentPlaytestStarting']);setActive(true);
      const run=instance.start(agentArtifact);
      const abort=()=>run.stop();signal.addEventListener('abort',abort,{once:true});
      try{
        const startup=await run.ready;
        if(startup.state!=='running')throw new Error(startup.message);
        const started=performance.now(),frames:AgentPreviewCapture[]=[];
        for(const time of times){
          const remaining=started+time*1000-performance.now();
          if(remaining>0)await new Promise<void>((resolve,reject)=>{
            const timer=setTimeout(()=>{signal.removeEventListener('abort',cancel);resolve();},remaining);
            const cancel=()=>{clearTimeout(timer);signal.removeEventListener('abort',cancel);reject(signal.reason??new Error(t('projects.agentPlaytestCancelled')));};
            signal.addEventListener('abort',cancel,{once:true});if(signal.aborted)cancel();
          });
          signal.throwIfAborted();
          const capture=await run.capture(signal);
          if(capture.type!=='gameCaptured')throw new Error(capture.message);
          frames.push({png:new Uint8Array(capture.png),width:capture.width,height:capture.height,elapsedSeconds:(performance.now()-started)/1000});
        }
        setStatus(['projects.agentPlaytestFinished', {count: frames.length}]);
        return frames;
      }catch(error){setStatus(error instanceof Error?error.message:['projects.agentPlaytestFailed']);throw error;}
      finally{signal.removeEventListener('abort',abort);run.stop();setActive(false);}
    },
    executeAgentLua:async(agentArtifact,commandId,signal)=>{
      const instance=host.current;
      if(!instance)throw new Error(t('projects.runtimeNotReady'));
      const problem=runtimeSupportProblem({secure:window.isSecureContext,isolated:window.crossOriginIsolated,
        sharedMemory:typeof SharedArrayBuffer!=='undefined',offscreen:typeof OffscreenCanvas!=='undefined',
        transferCanvas:typeof HTMLCanvasElement.prototype.transferControlToOffscreen==='function'});
      if(problem)throw new Error(t(problem));
      signal.throwIfAborted();setLogs([]);setStatus(['projects.agentLuaStarting']);setActive(true);
      const run=instance.start(agentArtifact);
      const abort=()=>run.stop();signal.addEventListener('abort',abort,{once:true});
      try{
        const startup=await run.ready;
        if(startup.state!=='running')throw new Error(startup.message);
        const commandResult=await run.readAgentCommand(commandId,signal);
        const result:unknown=JSON.parse(commandResult.resultJSON);
        if(!result||typeof result!=='object'||Array.isArray(result))throw new Error(t('projects.agentLuaInvalid'));
        const value=result as Record<string,unknown>;
        if(typeof value.success!=='boolean'||typeof value.output!=='string'
          ||(value.message!==undefined&&typeof value.message!=='string')
          ||(value.phase!==undefined&&typeof value.phase!=='string'))throw new Error(t('projects.agentLuaInvalid'));
        const decoded:AgentLuaCommandResult={success:value.success,output:value.output,
          ...(typeof value.message==='string'?{message:value.message}:{}),...(typeof value.phase==='string'?{phase:value.phase}:{}),
          files:commandResult.files,deletedPaths:commandResult.deletedPaths};
        setStatus(decoded.success?['projects.agentLuaFinished']:decoded.message??['projects.agentLuaFailed']);
        return decoded;
      }catch(error){setStatus(error instanceof Error?error.message:['projects.agentLuaPlayerFailed']);throw error;}
      finally{signal.removeEventListener('abort',abort);run.stop();setActive(false);}
    },
  }),[]);
  async function start() {
    if (active) return;
    const generation=++startGeneration.current;
    try {
      if(!host.current)throw new Error(t('projects.runtimeNotReady'));
      const problem = runtimeSupportProblem({ secure: window.isSecureContext, isolated: window.crossOriginIsolated,
        sharedMemory: typeof SharedArrayBuffer !== 'undefined', offscreen: typeof OffscreenCanvas !== 'undefined',
        transferCanvas: typeof HTMLCanvasElement.prototype.transferControlToOffscreen === 'function' });
      if (problem) { setStatus([problem]); return; }
      setLogs([]);setStatus(['projects.runtimePreparing']);setActive(true);
      const selected=resolveArtifact?await resolveArtifact():artifact;
      if(generation!==startGeneration.current)return;
      if(!selected)throw new Error(t('projects.runtimeDraftFailed'));
      host.current.start(selected);setStatus(['projects.runtimeLoading']);
    } catch (error) { setStatus(error instanceof Error ? error.message : String(error)); setActive(false); }
  }
  function stop(){startGeneration.current++;host.current?.stop();setActive(false);setStatus(['projects.runtimeStopped']);}
  return <div className="runtime-preview">
    <div className="runtime-toolbar"><div className="runtime-toolbar-state"><strong>{t('projects.playtest')}</strong>{toolbarStatus&&<span role="status">{toolbarStatus}</span>}</div><div className="runtime-toolbar-actions">
      {controls}
      {active?<button onClick={stop}>{t('projects.stopPlaytest')}</button>:<button onClick={()=>void start()}>{t('projects.runGame')}</button>}
    </div></div>
    <div className="runtime-surface">
      <div className="runtime-host-surface" ref={container}/>
      {!active&&<div className="runtime-empty-state">{t('projects.waitingForRun')}</div>}
    </div>
    <details className="runtime-logs"><summary>{t('projects.logsTitle', {count: logs.length})}</summary><pre aria-label={t('projects.runtimeLogs')}>{logs.map((log, index) => <div key={index} className={log.level === 'error' ? 'error-text' : ''}>{log.message}</div>)}</pre></details>
  </div>;
});
