import { isBuildArtifact, isRuntimeEvent, matchesRuntimeEvent, type BuildArtifact, type RuntimeCommand, type RuntimeEvent } from '@dora-studio/contracts';
import { decodeGameCapture } from './runtime-image';

interface Options {
  runtimeURL: string;
  engineBuild: string;
  onEvent: (event: RuntimeEvent) => void;
  timeoutMs?: number;
  /** Only for local integration tests, never the production isolation boundary. */
  allowSameOriginDevelopment?: boolean;
}

export type RuntimeStartup = {readonly state: 'running';readonly runId:string} |
  {readonly state:'cancelled' | 'failed';readonly runId:string;readonly message:string};

export interface RuntimeRun {
  readonly runId: string;
  readonly projectId:string;
  readonly revision:number;
  readonly startedAt:number | undefined;
  /** Settles once; iframe creation is not evidence of successful startup. */
  readonly ready: Promise<RuntimeStartup>;
  capture(signal?:AbortSignal): Promise<Extract<RuntimeEvent,{type:'gameCaptured'|'captureFailed'}>>;
  readAgentCommand(commandId:string,signal:AbortSignal):Promise<Extract<RuntimeEvent,{type:'agentCommandResult'}>>;
  /** Releases only this run. A late owner cannot stop a subsequent preview. */
  stop(): boolean;
}

/** Owns the page lifetime. A restart always creates a new page and channel. */
export class RuntimeHost {
  private cleanup: (() => void) | undefined;
  private generation = 0;
  constructor(private container: HTMLElement, private options: Options) {}

  start(input: BuildArtifact): RuntimeRun {
    if (!isBuildArtifact(input)) throw new Error('无效的编译产物');
    const url = new URL(this.options.runtimeURL, window.location.href);
    if (!['http:', 'https:'].includes(url.protocol) || url.username || url.password ||
        (url.origin === window.location.origin && !this.options.allowSameOriginDevelopment)) {
      throw new Error('运行页必须使用独立来源');
    }
    // A Player rebuild must create a new navigation identity. Browsers may
    // otherwise reuse an already loaded iframe document even when its static
    // response was marked no-store.
    url.searchParams.set('engineBuild', this.options.engineBuild);
    const artifact = structuredClone(input);
    this.stop();
    const generation = ++this.generation;
    const command: RuntimeCommand = { version: 1, type: 'loadSnapshot', sessionId: crypto.randomUUID(),
      projectId: artifact.projectId, revision: artifact.revision, requestId: crypto.randomUUID(),
      runId: crypto.randomUUID(), artifact, engineBuild: this.options.engineBuild, profile: 'dora-preset' };
    const { artifact: _artifact, type: _type, engineBuild: _engine, profile: _profile, ...identity } = command;
    let settle: (result: RuntimeStartup) => void;
    const ready = new Promise<RuntimeStartup>(resolve => { settle = resolve; });
    const captures = new Map<string,(event:Extract<RuntimeEvent,{type:'gameCaptured'|'captureFailed'}>)=>void>();
    const commandReads = new Map<string,(event:Extract<RuntimeEvent,{type:'agentCommandResult'}>)=>void>();
    const decoding = new Set<string>();
    let running = false;
    let startedAt:number | undefined;
    const fail = (message:string) => settle({state:'failed',runId:command.runId,message});
    const nonce = crypto.randomUUID();
    url.hash = new URLSearchParams({ parentOrigin: window.location.origin, nonce,
      identity: JSON.stringify(identity) }).toString();
    const frame = document.createElement('iframe');
    frame.title = 'Dora 游戏试玩';
    frame.className = 'runtime-frame';
    frame.setAttribute('sandbox', 'allow-scripts allow-same-origin allow-pointer-lock');
    frame.setAttribute('allow', 'autoplay; fullscreen; cross-origin-isolated');
    frame.referrerPolicy = 'no-referrer';
    const channel = new MessageChannel();
    let connected = false, finished = false;
    const current = () => !finished && generation === this.generation;
    const timer = window.setTimeout(() => {
      if (!current()) return;
      fail('运行启动超时，可重新试玩');
      this.stop();
      this.options.onEvent({ ...identity, type: 'error', code: 'timeout', message: '运行启动超时，可重新试玩' });
    }, this.options.timeoutMs ?? 45000);
    this.cleanup = () => {
      if (finished) return;
      finished = true;
      for (const [captureId,finish] of captures) finish({...identity,type:'captureFailed',captureId,message:'运行已停止'});
      for(const [commandId,finish] of commandReads)finish({...identity,type:'agentCommandResult',commandId,
        resultJSON:JSON.stringify({success:false,output:'',message:'Agent Lua Player stopped',phase:'execute'}),files:[],deletedPaths:[]});
      commandReads.clear();
      settle({state:'cancelled',runId:command.runId,message:'运行已停止或被替换'});
      window.clearTimeout(timer);
      frame.onload = null;
      channel.port1.onmessage = null;
      channel.port1.onmessageerror = null;
      channel.port1.close(); channel.port2.close();
      frame.remove();
    };
    channel.port1.onmessage = async ({ data }) => {
      if (!current() || !isRuntimeEvent(data) || !matchesRuntimeEvent(command, data)) return;
      if (data.type === 'state' && data.state === 'running') {
        running = true;
        startedAt ??= performance.now();
        window.clearTimeout(timer);
        settle({state:'running',runId:command.runId});
      }
      if (data.type === 'error') { fail(data.message); this.stop(); }
      if (data.type === 'gameCaptured' || data.type === 'captureFailed') {
        const finish=captures.get(data.captureId);
        if (!finish) return;
        if (data.type === 'captureFailed') {finish(data);return;}
        if (decoding.has(data.captureId)) return;
        decoding.add(data.captureId);
        try {
          const png=await decodeGameCapture(data.png,data.width,data.height);
          if (current() && captures.get(data.captureId) === finish) finish({...data,png});
        } catch {
          if (current() && captures.get(data.captureId) === finish)
            finish({...identity,type:'captureFailed',captureId:data.captureId,message:'游戏截图无法完整解码'});
        } finally {decoding.delete(data.captureId);}
        return;
      }
      if(data.type==='agentCommandResult'){
        const finish=commandReads.get(data.commandId);
        if(finish)finish(data);
        return;
      }
      this.options.onEvent(data);
    };
    channel.port1.onmessageerror = () => {
      if (!current()) return;
      fail('运行通道解码失败');
      this.stop();
      this.options.onEvent({ ...identity, type: 'error', code: 'runtimeFailure', message: '运行通道解码失败' });
    };
    channel.port1.start();
    frame.onload = () => {
      if (!current() || connected || !frame.contentWindow) return;
      connected = true;
      frame.contentWindow.postMessage({ type: 'dora-runtime-connect', nonce }, url.origin, [channel.port2]);
      channel.port1.postMessage(command);
    };
    frame.src = url.href;
    this.container.append(frame);
    return Object.freeze({runId: command.runId, projectId:command.projectId,revision:command.revision,get startedAt(){return startedAt;},ready, capture: (signal?:AbortSignal) => {
      const captureId=crypto.randomUUID();
      return new Promise<Extract<RuntimeEvent,{type:'gameCaptured'|'captureFailed'}>>(resolve=>{
        const failure=(message:string)=>({...identity,type:'captureFailed' as const,captureId,message});
        if (!current() || !running || signal?.aborted) {resolve(failure('游戏未运行或截图已取消'));return;}
        if (captures.size || decoding.size) {resolve(failure('已有截图正在处理'));return;}
        const finish=(event:Extract<RuntimeEvent,{type:'gameCaptured'|'captureFailed'}>)=>{
          if (!captures.delete(captureId)) return;
          window.clearTimeout(timeout);signal?.removeEventListener('abort',abort);resolve(event);
        };
        const abort=()=>finish(failure('截图已取消'));
        const timeout=window.setTimeout(()=>finish(failure('截图请求超时')),12000);
        captures.set(captureId,finish);signal?.addEventListener('abort',abort,{once:true});
        channel.port1.postMessage({...identity,type:'captureGame',captureId});
      });
    }, readAgentCommand:(commandId:string,signal:AbortSignal)=>new Promise<Extract<RuntimeEvent,{type:'agentCommandResult'}>>((resolve,reject)=>{
      if(!current()||!running||signal.aborted||!/^[a-zA-Z0-9_-]{1,128}$/.test(commandId)){reject(signal.reason??new Error('Agent Lua Player is unavailable'));return;}
      let poll:ReturnType<typeof window.setInterval>|undefined;
      const cleanup=()=>{if(poll!==undefined)window.clearInterval(poll);signal.removeEventListener('abort',abort);commandReads.delete(commandId);};
      const finish=(event:Extract<RuntimeEvent,{type:'agentCommandResult'}>)=>{cleanup();resolve(event);};
      const abort=()=>{cleanup();reject(signal.reason??new DOMException('Aborted','AbortError'));};
      commandReads.set(commandId,finish);signal.addEventListener('abort',abort,{once:true});
      const request=()=>{if(current()&&!signal.aborted)channel.port1.postMessage({...identity,type:'readAgentCommand',commandId});};
      request();poll=window.setInterval(request,25);
    }), stop: () => {
      if (!current()) return false;
      this.stop();
      return true;
    }});
  }

  stop(): void {
    this.generation++;
    this.cleanup?.();
    this.cleanup = undefined;
  }
}
