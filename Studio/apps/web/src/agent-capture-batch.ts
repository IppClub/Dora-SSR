import type { RuntimeEvent } from '@dora-studio/contracts';
import type { RuntimeRun } from './runtime-host';
import type { LocalProject, LocalWorkspace } from './workspace';
import { saveAgentCaptures } from './agent-captures';

function wait(ms:number,signal:AbortSignal) {
  return new Promise<void>((resolve,reject)=>{
    if(signal.aborted){reject(signal.reason);return;}
    const abort=()=>{clearTimeout(timer);reject(signal.reason);};
    const timer=setTimeout(()=>{signal.removeEventListener('abort',abort);resolve();},Math.max(0,ms));
    signal.addEventListener('abort',abort,{once:true});
  });
}
function cancellable<T>(pending:Promise<T>,signal:AbortSignal):Promise<T> {
  return new Promise((resolve,reject)=>{
    if(signal.aborted){reject(signal.reason);return;}
    const abort=()=>{signal.removeEventListener('abort',abort);reject(signal.reason);};
    signal.addEventListener('abort',abort,{once:true});
    pending.then(value=>{signal.removeEventListener('abort',abort);resolve(value);},error=>{signal.removeEventListener('abort',abort);reject(error);});
  });
}

/** Capture an already-started owned run. Does not replace execute_command or start/stop games. */
export async function captureAgentRunBatch(storage:LocalWorkspace,input:LocalProject,run:RuntimeRun,
  taskId:number,operationId:string,captureAtSeconds:readonly number[],signal:AbortSignal) {
  if(!globalThis.navigator?.locks) throw new Error('This browser cannot safely coordinate Agent capture operations');
  const project=structuredClone(input),times=[...captureAtSeconds];
  const key=JSON.stringify(['dora-studio-capture',project.snapshot.projectId,taskId,operationId]);
  return navigator.locks.request(key,{mode:'exclusive',signal},()=>executeCaptureBatch(storage,project,run,taskId,operationId,times,signal));
}

async function executeCaptureBatch(storage:LocalWorkspace,input:LocalProject,run:RuntimeRun,
  taskId:number,operationId:string,captureAtSeconds:readonly number[],signal:AbortSignal) {
  const project=structuredClone(input),times=[...captureAtSeconds];
  if(run.projectId!==project.snapshot.projectId || run.revision!==project.snapshot.revision)
    throw new Error('Preview run does not match the authoring revision');
  if(times.length<1 || times.length>3 || times.some((time,i)=>!Number.isFinite(time) || time<0 || time>10 || (i>0 && time<=times[i-1]!)))
    throw new Error('captureAtSeconds needs 1-3 increasing times between 0 and 10');
  signal.throwIfAborted();
  const reservation=await storage.reserveVisionCapture(project.snapshot.projectId,taskId,operationId,times.length,JSON.stringify({revision:project.snapshot.revision,times}));
  if(reservation.replayed) {
    let result=reservation.result;
    if(!result) {
      // Exclusive lock ownership means another cooperating page is no longer
      // executing this operation. Do not repeat side effects of an unknown run.
      const message='Previous capture execution ended before recording a result';
      await storage.completeVisionCaptureFailure(project.snapshot.projectId,taskId,operationId,project.snapshot.revision,message,true);
      result={success:false,interrupted:true,message,files:[],revision:project.snapshot.revision};
    }
    signal.throwIfAborted();
    const current=await storage.load(project.snapshot.projectId);
    const restored=current?.snapshot.revision===result.revision ? current : await storage.loadCheckpoint(project.snapshot.projectId,result.revision);
    signal.throwIfAborted();
    if(!restored || !Array.isArray(result.files) || result.files.some(path=>!restored.snapshot.files.some(file=>file.path===path && file.kind==='binary')))
      throw new Error('Completed capture snapshot is unavailable; refusing to repeat the operation');
    return {success:result.success,message:result.message,interrupted:result.interrupted,project:restored,files:[...result.files],removedFiles:[] as string[],
      captures:[] as Extract<RuntimeEvent,{type:'gameCaptured'}>[],restored:true,historical:current?.snapshot.revision!==result.revision,
      visionCapture:{batchCount:1,frameCount:times.length},visionBudget:reservation.budget};
  }
  const captures:Extract<RuntimeEvent,{type:'gameCaptured'}>[]=[];
  let failure:string | undefined;
  try {
    signal.throwIfAborted();
    // The caller owns the run. A capture failure must not stop someone else's game.
    const startup=await cancellable(run.ready,signal);
    signal.throwIfAborted();
    if(startup.state!=='running') throw new Error(startup.message);
    const started=run.startedAt;
    if(started===undefined) throw new Error('Preview startup timestamp is unavailable');
    for(const time of times) {
      await wait(time*1000-(performance.now()-started),signal);
      const capture=await run.capture(signal);
      signal.throwIfAborted();
      if(capture.type!=='gameCaptured') throw new Error(capture.message);
      captures.push(capture);
    }
  } catch(error) {failure=error instanceof Error ? error.message : String(error);}
  const accounting={captures,visionCapture:{batchCount:1,frameCount:times.length},visionBudget:reservation.budget};
  if(!captures.length) {
    let message=failure ?? 'No captures produced';
    try {await storage.completeVisionCaptureFailure(project.snapshot.projectId,taskId,operationId,project.snapshot.revision,message.slice(0,8192),signal.aborted);}
    catch(error) {message+=`; Failed to persist capture result: ${error instanceof Error ? error.message : String(error)}`;}
    return {success:false,message,interrupted:signal.aborted,project,files:[] as string[],removedFiles:[] as string[],...accounting};
  }
  try {
    // Cancellation prevents new work; retain already completed frames as the
    // native preview tool does. The original revision still guards this commit.
    const saved=await saveAgentCaptures(storage,project,run.runId,captures,new AbortController().signal,
      {taskId,operationId,success:failure===undefined,interrupted:signal.aborted,...(failure===undefined?{}:{message:failure.slice(0,8192)})});
    return {...saved,...accounting,success:failure===undefined,message:failure,interrupted:signal.aborted};
  } catch(error) {
    const persistenceError=error instanceof Error ? error.message : String(error);
    return {success:false,message:failure ? `${failure}; ${persistenceError}` : persistenceError,interrupted:signal.aborted,project,files:[] as string[],removedFiles:[] as string[],...accounting};
  }
}
