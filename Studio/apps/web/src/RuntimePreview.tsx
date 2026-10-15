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
  const container = useRef<HTMLDivElement>(null), host = useRef<RuntimeHost | undefined>(undefined);
  const startGeneration=useRef(0);
  const [status, setStatus] = useState('等待运行'), [active, setActive] = useState(false);
  const [logs, setLogs] = useState<{ level: string; message: string }[]>([]);
  const runtimeURL = import.meta.env.VITE_DORA_RUNTIME_URL;
  const engineBuild = import.meta.env.VITE_DORA_ENGINE_BUILD;
  const configurationProblem=!runtimeURL?'试玩 Player 未配置运行页地址':!engineBuild?'试玩 Player 未配置引擎版本':'';
  const toolbarStatus=status==='等待运行'||status==='已停止'?'':status;
  useEffect(() => {
    if (!container.current) return;
    if(configurationProblem){setStatus(configurationProblem);return;}
    const instance = new RuntimeHost(container.current, { runtimeURL, engineBuild,
      onEvent(event) {
        if (event.type === 'log') { setLogs(previous => [...previous.slice(-199), { level: event.level, message: event.message.slice(0, 8192) }]); return; }
        if (event.type === 'error') { setStatus(event.message); setActive(false); }
        else if (event.type === 'state') {
          setStatus(({ loading: '正在加载', ready: '正在启动', running: '正在运行', suspended: '已暂停', stopped: '已停止' })[event.state]);
          if (event.state === 'stopped') setActive(false);
        }
      } });
    host.current = instance;
    return () => { instance.stop(); host.current = undefined; };
  }, [runtimeURL, engineBuild,configurationProblem]);
  useEffect(() => {
    if(!active)setStatus(configurationProblem||'等待运行');
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
      if(!instance)throw new Error('独立试玩 Player 尚未就绪');
      const problem=runtimeSupportProblem({secure:window.isSecureContext,isolated:window.crossOriginIsolated,
        sharedMemory:typeof SharedArrayBuffer!=='undefined',offscreen:typeof OffscreenCanvas!=='undefined',
        transferCanvas:typeof HTMLCanvasElement.prototype.transferControlToOffscreen==='function'});
      if(problem)throw new Error(problem);
      signal.throwIfAborted();setLogs([]);setStatus('Agent 工具正在启动游戏…');setActive(true);
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
            const cancel=()=>{clearTimeout(timer);signal.removeEventListener('abort',cancel);reject(signal.reason??new Error('Agent 试玩已取消'));};
            signal.addEventListener('abort',cancel,{once:true});if(signal.aborted)cancel();
          });
          signal.throwIfAborted();
          const capture=await run.capture(signal);
          if(capture.type!=='gameCaptured')throw new Error(capture.message);
          frames.push({png:new Uint8Array(capture.png),width:capture.width,height:capture.height,elapsedSeconds:(performance.now()-started)/1000});
        }
        setStatus(`Agent 工具试玩完成 · ${frames.length} 帧`);
        return frames;
      }catch(error){setStatus(error instanceof Error?error.message:'Agent 工具试玩失败');throw error;}
      finally{signal.removeEventListener('abort',abort);run.stop();setActive(false);}
    },
    executeAgentLua:async(agentArtifact,commandId,signal)=>{
      const instance=host.current;
      if(!instance)throw new Error('独立试玩 Player 尚未就绪');
      const problem=runtimeSupportProblem({secure:window.isSecureContext,isolated:window.crossOriginIsolated,
        sharedMemory:typeof SharedArrayBuffer!=='undefined',offscreen:typeof OffscreenCanvas!=='undefined',
        transferCanvas:typeof HTMLCanvasElement.prototype.transferControlToOffscreen==='function'});
      if(problem)throw new Error(problem);
      signal.throwIfAborted();setLogs([]);setStatus('Agent Lua 命令正在启动游戏环境…');setActive(true);
      const run=instance.start(agentArtifact);
      const abort=()=>run.stop();signal.addEventListener('abort',abort,{once:true});
      try{
        const startup=await run.ready;
        if(startup.state!=='running')throw new Error(startup.message);
        const commandResult=await run.readAgentCommand(commandId,signal);
        const result:unknown=JSON.parse(commandResult.resultJSON);
        if(!result||typeof result!=='object'||Array.isArray(result))throw new Error('Agent Lua Player 返回了无效结果');
        const value=result as Record<string,unknown>;
        if(typeof value.success!=='boolean'||typeof value.output!=='string'
          ||(value.message!==undefined&&typeof value.message!=='string')
          ||(value.phase!==undefined&&typeof value.phase!=='string'))throw new Error('Agent Lua Player 返回了无效结果');
        const decoded:AgentLuaCommandResult={success:value.success,output:value.output,
          ...(typeof value.message==='string'?{message:value.message}:{}),...(typeof value.phase==='string'?{phase:value.phase}:{}),
          files:commandResult.files,deletedPaths:commandResult.deletedPaths};
        setStatus(decoded.success?'Agent Lua 命令执行完成':decoded.message??'Agent Lua 命令执行失败');
        return decoded;
      }catch(error){setStatus(error instanceof Error?error.message:'Agent Lua Player 执行失败');throw error;}
      finally{signal.removeEventListener('abort',abort);run.stop();setActive(false);}
    },
  }),[]);
  async function start() {
    if (active) return;
    const generation=++startGeneration.current;
    try {
      if(!host.current)throw new Error('独立试玩 Player 尚未就绪');
      const problem = runtimeSupportProblem({ secure: window.isSecureContext, isolated: window.crossOriginIsolated,
        sharedMemory: typeof SharedArrayBuffer !== 'undefined', offscreen: typeof OffscreenCanvas !== 'undefined',
        transferCanvas: typeof HTMLCanvasElement.prototype.transferControlToOffscreen === 'function' });
      if (problem) { setStatus(problem); return; }
      setLogs([]);setStatus('正在准备运行');setActive(true);
      const selected=resolveArtifact?await resolveArtifact():artifact;
      if(generation!==startGeneration.current)return;
      if(!selected)throw new Error('无法读取当前工作区');
      host.current.start(selected);setStatus('正在加载');
    } catch (error) { setStatus(error instanceof Error ? error.message : String(error)); setActive(false); }
  }
  function stop(){startGeneration.current++;host.current?.stop();setActive(false);setStatus('已停止');}
  return <div className="runtime-preview">
    <div className="runtime-toolbar"><div className="runtime-toolbar-state"><strong>试玩</strong>{toolbarStatus&&<span role="status">{toolbarStatus}</span>}</div><div className="runtime-toolbar-actions">
      {controls}
      {active?<button onClick={stop}>停止</button>:<button onClick={()=>void start()}>运行游戏</button>}
    </div></div>
    <div className="runtime-surface">
      <div className="runtime-host-surface" ref={container}/>
      {!active&&<div className="runtime-empty-state">等待运行中</div>}
    </div>
    <details className="runtime-logs"><summary>运行日志 · {logs.length}</summary><pre aria-label="游戏运行日志">{logs.map((log, index) => <div key={index} className={log.level === 'error' ? 'error-text' : ''}>{log.message}</div>)}</pre></details>
  </div>;
});
