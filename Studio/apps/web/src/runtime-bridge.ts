import { isRuntimeCommand, isBoundedCapturePNG, type Correlation, type RuntimeEvent } from '@dora-studio/contracts';
import { prepareRuntimeSnapshot } from './runtime-snapshot';

type Identity = Correlation & { runId: string };
interface Options { parentOrigin: string; nonce: string; identity: Identity; engineBuild: string; timeoutMs?: number;
  engineVersion: string;
  captureGame?: (signal:AbortSignal)=>Promise<{png:Uint8Array;width:number;height:number}>;
}
interface RuntimeModule {
  doraSnapshot?: Promise<unknown>;
  print?: (text: string) => void;
  printErr?: (text: string) => void;
  FS?: {analyzePath(path:string):{exists:boolean};readFile(path:string,options:{encoding:'utf8'}):string;unlink(path:string):void};
}

/** Install before loading Emscripten. One connection and one snapshot per page. */
export function installRuntimeBridge(page: Window, module: RuntimeModule, options: Options) {
  const origin = new URL(options.parentOrigin);
  if (!['https:', 'http:'].includes(origin.protocol) || origin.origin !== options.parentOrigin || !options.nonce) {
    throw new Error('Invalid runtime parent configuration');
  }
  const identity = { ...options.identity };
  let port: MessagePort | undefined, disposed = false, accepted = false;
  let running = false;
  let capture: AbortController | undefined;
  let cancelCapture: (()=>void) | undefined;
  const captures = new Set<string>();
  let resolveSnapshot!: (snapshot: unknown) => void, rejectSnapshot!: (reason: Error) => void;
  module.doraSnapshot = new Promise((resolve, reject) => { resolveSnapshot = resolve; rejectSnapshot = reject; });
  // Emscripten attaches later; do not produce an unhandled rejection meanwhile.
  void module.doraSnapshot.catch(() => {});
  const send = (event: RuntimeEvent) => { if (!disposed) port?.postMessage(event); };
  let logWindow = Date.now(), logCount = 0;
  const originalPrint = module.print, originalError = module.printErr;
  function forwardLog(text: string, error: boolean) {
    if (disposed) return;
    if (Date.now() - logWindow >= 1000) { logWindow = Date.now(); logCount = 0; }
    if (++logCount > 200) {
      if (logCount === 201) send({ ...identity, type: 'log', level: 'warning', message: '日志过于频繁，已省略本秒后续输出。' });
      return;
    }
    const message = String(text).slice(0, 8192);
    send({ ...identity, type: 'log', level: error || /\[error\]/i.test(message) ? 'error' : /\[warn(?:ing)?\]/i.test(message) ? 'warning' : 'info', message });
    (error ? originalError || console.error : originalPrint || console.log)(message);
  }
  module.print = text => forwardLog(text, false);
  module.printErr = text => forwardLog(text, true);
  const timer = page.setTimeout(() => {
    send({ ...identity, type: 'error', code: 'timeout', message: '等待运行快照超时' });
    dispose();
  }, options.timeoutMs ?? 30000);
  const sameIdentity = (command: Correlation & { runId: string }) =>
    command.version === identity.version && command.sessionId === identity.sessionId &&
    command.projectId === identity.projectId && command.revision === identity.revision &&
    command.requestId === identity.requestId && command.runId === identity.runId;
  function connect(event: MessageEvent) {
    if (disposed || port || event.source !== page.parent || event.origin !== options.parentOrigin ||
        event.data?.type !== 'dora-runtime-connect' || event.data?.nonce !== options.nonce || event.ports.length !== 1) return;
    port = event.ports[0]!;
    page.removeEventListener('message', connect);
    port.onmessage = async ({ data }) => {
      if (disposed || !isRuntimeCommand(data) || !sameIdentity(data)) return;
      if (data.type === 'captureGame') {
        const captureId = data.captureId;
        const failed = (message:string) => send({...identity,type:'captureFailed',captureId,message:message.slice(0,8192)});
        if (!accepted || !running) { failed('游戏尚未运行'); return; }
        if (!options.captureGame) { failed('当前运行版本不支持受控截图'); return; }
        if (captures.has(captureId)) return;
        if (capture) { failed('已有截图正在处理'); return; }
        if (captures.size >= 128) { failed('本次运行截图请求已达安全上限'); return; }
        captures.add(captureId);
        const controller = new AbortController();capture = controller;
        const captureTimer = page.setTimeout(() => {
          controller.abort();
          if (capture === controller) { capture = undefined;cancelCapture = undefined; }
          failed('游戏截图超时');
        },10000);
        cancelCapture = () => {
          controller.abort();page.clearTimeout(captureTimer);
          if (capture === controller) capture = undefined;
          failed('游戏截图已取消');
        };
        try {
          const result = await options.captureGame(controller.signal);
          if (disposed || controller.signal.aborted) return;
          if (!isBoundedCapturePNG(result.png,result.width,result.height)) { failed('无效或过大的游戏截图'); return; }
          send({...identity,type:'gameCaptured',captureId,width:result.width,height:result.height,png:result.png.slice()});
        } catch (error) {
          if (!disposed && !controller.signal.aborted) failed(String(error));
        } finally {
          page.clearTimeout(captureTimer);
          if (capture === controller) { capture = undefined;cancelCapture = undefined; }
        }
        return;
      }
      if (data.type === 'readAgentCommand') {
        if (!accepted || !running || !module.FS) return;
        const path=`/tmp/studio-agent-command-${data.commandId}.json`;
        try{
          if(!module.FS.analyzePath(path).exists)return;
          const resultJSON=module.FS.readFile(path,{encoding:'utf8'});
          module.FS.unlink(path);
          if(typeof resultJSON!=='string'||resultJSON.length>262144)throw new Error('Agent Lua result exceeds limit');
          send({...identity,type:'agentCommandResult',commandId:data.commandId,resultJSON});
        }catch(error){
          send({...identity,type:'agentCommandResult',commandId:data.commandId,resultJSON:JSON.stringify({success:false,output:'',message:String(error),phase:'execute'})});
        }
        return;
      }
      if (accepted || data.type !== 'loadSnapshot') return;
      if (data.engineBuild !== options.engineBuild || data.profile !== 'dora-preset') {
        send({ ...identity, type: 'error', code: 'unsupported', message: '运行引擎版本或配置不匹配' });
        dispose();
        return;
      }
      accepted = true;
      try {
        const snapshot = await prepareRuntimeSnapshot(data.artifact, options.engineVersion);
        if (disposed) return;
        page.clearTimeout(timer);
        resolveSnapshot(snapshot);
      } catch (error) {
        if (disposed) return;
        send({ ...identity, type: 'error', code: 'invalidSnapshot', message: String(error) });
        dispose();
      }
    };
    port.onmessageerror = () => dispose();
    port.start();
    send({ ...identity, type: 'state', state: 'loading' });
  }
  function stateChanged(event: Event) {
    const detail = (event as CustomEvent).detail;
    running = detail?.state === 'running';
    if (!running) { cancelCapture?.();cancelCapture = undefined; }
    if (detail?.state === 'faulted') {
      send({ ...identity, type: 'error', code: 'runtimeFailure', message: String(detail.message || 'Runtime failed') });
    } else if (['ready', 'running', 'stopped'].includes(detail?.state)) {
      send({ ...identity, type: 'state', state: detail.state });
    }
  }
  function dispose() {
    if (disposed) return;
    disposed = true;
    cancelCapture?.();cancelCapture = undefined;capture = undefined;
    page.clearTimeout(timer);
    page.removeEventListener('message', connect);
    page.removeEventListener('dora-statechange', stateChanged);
    if (port) { port.onmessage = null; port.onmessageerror = null; port.close(); }
    rejectSnapshot(new Error('Runtime channel disposed'));
  }
  page.addEventListener('message', connect);
  page.addEventListener('dora-statechange', stateChanged);
  return { dispose };
}
