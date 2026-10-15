import {requestAgentLaunch,revokeAgentLaunch} from './agent-launch-client';
import {mountAgentHostFrame} from './agent-host-frame';
import {createAgentRetirement} from './agent-retirement';
import type {AgentSessionController} from './agent-session-controller';
import {prepareAgentProjectSnapshot} from './agent-project-snapshot';
import type {ProjectSnapshot} from '@dora-studio/contracts';
import type {AgentProjectCapture} from './agent-project-capture';
import type {AgentLuaHandler,AgentPreviewHandler} from './agent-session-port';
import type {AgentPromptOptions} from './agent-prompt-options';
import type {AgentModelQueueStore} from './agent-model-queue';

export interface WorkspaceAgentBinding {
  projectId:string;
  controller:AgentSessionController;
  retirement:ReturnType<typeof createAgentRetirement>;
  close?:()=>void;
  syncProject?:(snapshot:ProjectSnapshot,signal:AbortSignal)=>Promise<void>;
  captureProject?:(signal:AbortSignal)=>Promise<AgentProjectCapture>;
  captureLiveProject?:(signal:AbortSignal)=>Promise<AgentProjectCapture>;
  sendPrompt?:(prompt:string,grantId:string,requestId:string,options:AgentPromptOptions,signal:AbortSignal)=>Promise<number>;
  handleQuestionnaire?:(action:'respond'|'cancel',questionnaireId:number,answers:unknown[],grantId:string,requestId:string,signal:AbortSignal)=>Promise<number>;
  stopTask?:(requestId:string,signal:AbortSignal)=>Promise<void>;
  setPreviewHandler?:(handler:AgentPreviewHandler|undefined)=>void;
  setLuaHandler?:(handler:AgentLuaHandler|undefined)=>void;
  modelQueue?:AgentModelQueueStore;
}

export function isLiveWorkspaceAgent(agent:WorkspaceAgentBinding|undefined,projectId:string):agent is WorkspaceAgentBinding {
  return !!agent&&agent.projectId===projectId&&!agent.controller.closed;
}

/** No credentials or raw provider errors are exposed to the workbench. */
export class AgentStartupFailure extends Error {
  constructor(readonly retryCleanup:()=>Promise<void>,readonly cleanupPending:boolean) {
    super(cleanupPending?'Agent 启动失败，服务端清理尚未确认。':'Agent 启动失败，启动实例已清理。');
  }
}

function waitForAgentOperation<T>(operation:Promise<T>,signal:AbortSignal):Promise<T>{
  signal.throwIfAborted();
  return new Promise<T>((resolve,reject)=>{
    const aborted=()=>reject(signal.reason instanceof Error?signal.reason:new DOMException('Agent 操作已取消','AbortError'));
    signal.addEventListener('abort',aborted,{once:true});
    operation.then(value=>{signal.removeEventListener('abort',aborted);resolve(value);},error=>{signal.removeEventListener('abort',aborted);reject(error);});
  });
}

/** Signal controls startup only. Once ready, use retirement, not abort, to save.
 * The caller must retain the returned binding until retirement is confirmed.
 */
export async function startWorkspaceAgent(container:HTMLElement,projectId:string,hostOrigin:string,signal:AbortSignal):Promise<WorkspaceAgentBinding> {
  const launch=await requestAgentLaunch(projectId,hostOrigin,signal);
  let host:ReturnType<typeof mountAgentHostFrame>|undefined;
  let cleaned=false;
  const cleanup=async()=>{
    if(cleaned)return;
    // A cancelled startup must still be able to revoke its server instance.
    await revokeAgentLaunch(launch,hostOrigin,new AbortController().signal);
    cleaned=true;
  };
  const abort=()=>host?.close();
  try {
    signal.throwIfAborted();
    // The trusted Web engine and original Agent libraries cold-load separately
    // from Studio; keep the provisioning deadline bounded but realistic.
    host=mountAgentHostFrame(container,launch,60000);
    signal.addEventListener('abort',abort,{once:true});
    const connection=await host.ready;
    signal.throwIfAborted();
    const owner=host;
    return {projectId,controller:connection.controller,modelQueue:connection.modelQueue,close:()=>owner.close(),retirement:createAgentRetirement({persistAndClose:()=>owner.persistAndClose(),revoke:cleanup}),setPreviewHandler:connection.setPreviewHandler,setLuaHandler:connection.setLuaHandler,
      ...(connection.canSendPrompt?{sendPrompt:async(prompt:string,grantId:string,requestId:string,options:AgentPromptOptions,signal:AbortSignal)=>{
		signal.throwIfAborted();const taskId=await waitForAgentOperation(connection.sendPrompt(prompt,grantId,requestId,options),signal);signal.throwIfAborted();return taskId;
      }}:{}),
      ...(connection.canHandleQuestionnaire?{handleQuestionnaire:async(action:'respond'|'cancel',questionnaireId:number,answers:unknown[],grantId:string,requestId:string,signal:AbortSignal)=>{
		signal.throwIfAborted();const taskId=await waitForAgentOperation(connection.handleQuestionnaire(action,questionnaireId,answers,grantId,requestId),signal);signal.throwIfAborted();return taskId;
      }}:{}),
      ...(connection.canStopTask?{stopTask:async(requestId:string,signal:AbortSignal)=>{
		signal.throwIfAborted();await waitForAgentOperation(connection.stopTask(requestId),signal);signal.throwIfAborted();
      }}:{}),
      ...(connection.canCaptureProject?{captureProject:async(signal:AbortSignal)=>{
		signal.throwIfAborted();const result=await waitForAgentOperation(connection.captureProject(),signal);signal.throwIfAborted();return result;
      }}:{}),
      ...(connection.canCaptureLiveProject?{captureLiveProject:async(signal:AbortSignal)=>{
		signal.throwIfAborted();const result=await waitForAgentOperation(connection.captureLiveProject(),signal);signal.throwIfAborted();return result;
      }}:{}),
      ...(connection.canSyncProject?{syncProject:async(snapshot:ProjectSnapshot,signal:AbortSignal)=>{
        const envelope=await prepareAgentProjectSnapshot(snapshot,projectId,signal);
		signal.throwIfAborted();await waitForAgentOperation(connection.syncProject(envelope),signal);signal.throwIfAborted();
      }}:{})};
  }catch{
    host?.close();
    try{await cleanup();}catch{/* Preserve a retry handle, not a false cleanup confirmation. */}
    throw new AgentStartupFailure(cleanup,!cleaned);
  }finally{signal.removeEventListener('abort',abort);}
}
