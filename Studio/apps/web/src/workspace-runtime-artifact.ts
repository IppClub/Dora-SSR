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

/** Prefer generated files already in the frontend workspace, otherwise retain
 * the latest explicit build. With neither, let Player diagnose the raw entry. */
export async function resolveWorkspaceRuntimeArtifact(snapshot:ProjectSnapshot,compiled:BuildArtifact|null):Promise<BuildArtifact>{
  const entry=generatedEntry(snapshot);
  if(entry||!generatedSource.test(snapshot.entry))return packageWorkspace(snapshot,entry??snapshot.entry);
  return compiled??packageWorkspace(snapshot,snapshot.entry);
}
