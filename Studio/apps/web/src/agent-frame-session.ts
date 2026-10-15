import {requestAgentFramePort} from './agent-frame-port';
import {connectAgentSessionPort} from './agent-session-port';

/** Call after the application-owned trusted Agent frame has loaded.
 * The owner must close this connection on frame removal/project change.
 */
export async function connectAgentFrameSession(frame: HTMLIFrameElement, origin: string, binding: {projectId:string;generation:string;sessionId:number}, signal: AbortSignal) {
  const target = frame.contentWindow;
  if (!target) throw new Error('Agent frame is not attached');
  const expected = {projectId:binding.projectId,generation:binding.generation,sessionId:binding.sessionId};
  const abort = new AbortController();
  const cancel = () => abort.abort(signal.reason ?? new DOMException('Aborted','AbortError'));
  const navigated = () => abort.abort(new Error('Agent host navigated; reconnect with a new generation'));
  const cleanup = () => {
    frame.removeEventListener('load', navigated);
    signal.removeEventListener('abort', cancel);
  };
  abort.signal.addEventListener('abort', cleanup, {once:true});
  frame.addEventListener('load', navigated);
  signal.addEventListener('abort', cancel, {once:true});
  if (signal.aborted) cancel();
  try {
    const port = await requestAgentFramePort(target, origin, abort.signal);
    const connection = await connectAgentSessionPort(port, expected, abort.signal);
    return {controller:connection.controller,modelQueue:connection.modelQueue,canPersist:connection.canPersist,persist:connection.persist,canSyncProject:connection.canSyncProject,syncProject:connection.syncProject,canCaptureProject:connection.canCaptureProject,captureProject:connection.captureProject,canCaptureLiveProject:connection.canCaptureLiveProject,captureLiveProject:connection.captureLiveProject,canSendPrompt:connection.canSendPrompt,sendPrompt:connection.sendPrompt,canHandleQuestionnaire:connection.canHandleQuestionnaire,handleQuestionnaire:connection.handleQuestionnaire,canStopTask:connection.canStopTask,stopTask:connection.stopTask,setPreviewHandler:connection.setPreviewHandler,setLuaHandler:connection.setLuaHandler,close:() => {
      cleanup();
      abort.abort(new Error('Agent frame session closed'));
      connection.close();
    }};
  } catch (error) {
    cleanup();
    abort.abort(error);
    throw error;
  }
}
