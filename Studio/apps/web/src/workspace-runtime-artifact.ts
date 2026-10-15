import {serializeArtifactContent,type BuildArtifact,type ProjectSnapshot} from '@dora-studio/contracts';

const generatedSource=/\.(?:vs|bl|tsx?|tl|yue|xml)$/i;

function generatedEntry(snapshot:ProjectSnapshot):string|undefined{
  if(!generatedSource.test(snapshot.entry))return undefined;
  const candidate=snapshot.entry.replace(generatedSource,'.lua');
  return snapshot.files.find(file=>file.path.toLowerCase()===candidate.toLowerCase())?.path;
}

async function packageWorkspace(snapshot:ProjectSnapshot,entry:string):Promise<BuildArtifact>{
  const copy=structuredClone(snapshot);
  const content={compilerVersion:'dora-studio-workspace-1',entry,files:copy.files,sourceMaps:{}};
  const digest=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(serializeArtifactContent(content)));
  return {...content,buildId:crypto.randomUUID(),projectId:copy.projectId,revision:copy.revision,
    sha256:[...new Uint8Array(digest)].map(byte=>byte.toString(16).padStart(2,'0')).join('')};
}

/** A successful explicit build for this exact snapshot is authoritative. Agent
 * writeback can retain a generated Lua sibling beside its authored TS source;
 * preferring that sibling after a new editor build would silently run stale
 * code. With no matching build, fall back to a workspace-generated entry and
 * finally let Player diagnose the raw source entry. */
export async function resolveWorkspaceRuntimeArtifact(snapshot:ProjectSnapshot,compiled:BuildArtifact|null):Promise<BuildArtifact>{
  if(compiled?.projectId===snapshot.projectId&&compiled.revision===snapshot.revision)return compiled;
  const entry=generatedEntry(snapshot);
  return packageWorkspace(snapshot,entry??snapshot.entry);
}
