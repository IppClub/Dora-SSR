import { isBoundedCapturePNG } from '@dora-studio/contracts';

export interface CaptureModule {
  doraStudioCapture?: boolean;
  doraCaptureComplete?: (id:number,success:boolean)=>void;
  ccall?: (name:string,type:null,types:string[],args:number[])=>unknown;
  FS?: {
    analyzePath(path:string):{exists:boolean};
    lstat(path:string):{mode:number;size:number};
    isDir(mode:number):boolean;
    isFile(mode:number):boolean;
    readdir(path:string):string[];
    readFile(path:string):Uint8Array;
    readFile(path:string,options:{encoding:'utf8'}):string;
    unlink(path:string):void;
  };
}

/** Bridge one engine-thread capture back to the page. Never accepts a user path. */
export function createRuntimeCapture(module:CaptureModule) {
  module.doraStudioCapture = true;
  let next = 0;
  const pending = new Map<number,{resolve:(result:{png:Uint8Array;width:number;height:number})=>void;reject:(error:Error)=>void;signal:AbortSignal;abort:()=>void}>();
  module.doraCaptureComplete = (id,success) => {
    if (!Number.isSafeInteger(id) || id <= 0 || id > next) return;
    const request = pending.get(id);
    const path = `/tmp/dora-studio-capture-${id}.png`;
    try {
      if (!request) return;
      pending.delete(id);request.signal.removeEventListener('abort',request.abort);
      if (!success || !module.FS) throw new Error('引擎无法捕获游戏画面');
      const png = module.FS.readFile(path).slice();
      if (png.byteLength < 24) throw new Error('引擎返回的截图不完整');
      const header = new DataView(png.buffer,png.byteOffset,png.byteLength);
      const width=header.getUint32(16),height=header.getUint32(20);
      if (!isBoundedCapturePNG(png,width,height)) throw new Error('引擎截图超出限制或格式无效');
      request.resolve({png,width,height});
    } catch (error) { request?.reject(error instanceof Error ? error : new Error(String(error))); }
    finally { try { module.FS?.unlink(path); } catch { /* no output on failure */ } }
  };
  return (signal:AbortSignal) => new Promise<{png:Uint8Array;width:number;height:number}>((resolve,reject)=>{
    if (signal.aborted) {reject(new Error('截图已取消'));return;}
    if (!module.ccall || !module.FS || next === 2147483647) {reject(new Error('运行版本不支持截图'));return;}
    const id=++next;
    const abort=()=>{pending.delete(id);reject(new Error('截图已取消'));};
    pending.set(id,{resolve,reject,signal,abort});signal.addEventListener('abort',abort,{once:true});
    try {module.ccall('dora_web_capture_game',null,['number'],[id]);}
    catch(error) {pending.delete(id);signal.removeEventListener('abort',abort);reject(error);}
  });
}
