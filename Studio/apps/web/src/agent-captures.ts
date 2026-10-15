import { isRuntimeEvent, type RuntimeEvent } from '@dora-studio/contracts';
import { decodeGameCapture } from './runtime-image';
import type { CaptureCompletion, LocalProject, LocalWorkspace } from './workspace';
import { findPrunableCaptures } from '@dora-studio/agent-contracts/vision-captures';

/** Commit a complete capture batch against the exact authoring revision it observed. */
export async function saveAgentCaptures(storage:LocalWorkspace, input:LocalProject, runId:string,
  inputCaptures:readonly RuntimeEvent[], signal:AbortSignal, completion?:Omit<CaptureCompletion,'files'>) {
  const project=structuredClone(input),captures=structuredClone(inputCaptures);
  if (captures.length < 1 || captures.length > 3 || !runId) throw new Error('Invalid capture batch');
  const seen=new Set<string>(), files=[...project.snapshot.files], paths:string[]=[];
  for (const capture of captures) {
    signal.throwIfAborted();
    if (!isRuntimeEvent(capture) || capture.type !== 'gameCaptured' || capture.projectId !== project.snapshot.projectId ||
      capture.revision !== project.snapshot.revision || capture.runId !== runId || seen.has(capture.captureId))
      throw new Error('Capture does not belong to this project revision and run');
    seen.add(capture.captureId);
    const png=await decodeGameCapture(capture.png,capture.width,capture.height);
    signal.throwIfAborted();
    let path:string;
    do {path=`.agent/vision/${Math.floor(Date.now()/1000)}-${crypto.getRandomValues(new Uint32Array(1))[0]}.png`;}
    while(files.some(file=>file.path===path));
    files.push({path,kind:'binary',bytes:png});paths.push(path);
  }
  signal.throwIfAborted();
  const removed=new Set(findPrunableCaptures(files.map(file=>file.path)));
  if (paths.some(path=>removed.has(path))) throw new Error('Capture timestamps conflict with retained history; check device clock');
  const saved=await storage.save(project.name,{...project.snapshot,revision:project.snapshot.revision+1,files:files.filter(file=>!removed.has(file.path))},project.snapshot.revision,true,completion ? {...completion,files:paths} : undefined);
  return {project:saved,files:paths,removedFiles:[...removed],checkpointId:project.snapshot.revision};
}
