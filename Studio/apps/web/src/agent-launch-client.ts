/** hostOrigin comes from trusted deployment configuration, never a project. */
export async function requestAgentLaunch(projectId:string,hostOrigin:string,signal:AbortSignal) {
  const host=new URL(hostOrigin);
  if(!/^[A-Za-z0-9_-]{1,128}$/.test(projectId) || host.origin!==hostOrigin
    || !['http:','https:'].includes(host.protocol) || hostOrigin===location.origin)throw new Error('Invalid Agent launch configuration');
  const operation=AbortSignal.any([signal,AbortSignal.timeout(15000)]);
  operation.throwIfAborted();
  const response=await fetch(new URL(`/api/projects/${projectId}/agent-launch`,location.origin),{
    method:'POST',credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation,
  });
  if(response.status!==201 || !response.body)throw new Error('Agent launch request failed');
  const reader=response.body.getReader();let total=0;const chunks:Uint8Array[]=[];
  try {
    for(;;){operation.throwIfAborted();const {done,value}=await reader.read();if(done)break;total+=value.length;if(total>16384)throw new Error('Agent launch response too large');chunks.push(value);}
  }finally{await reader.cancel();reader.releaseLock();}
  operation.throwIfAborted();
  const bytes=new Uint8Array(total);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
  const result=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));
  if(!result || result.version!==1 || result.projectId!==projectId || typeof result.generation!=='string'
    || !/^[a-f0-9-]{36}$/.test(result.generation) || !Number.isSafeInteger(result.expiresAt) || result.expiresAt<=Date.now()
    || typeof result.url!=='string')throw new Error('Invalid Agent launch response');
  const url=new URL(result.url);
  if(url.origin!==hostOrigin || url.username || url.password || url.search || url.hash
    || !/^\/agent-host\/[a-f0-9-]{36}\/index\.html$/.test(url.pathname))throw new Error('Untrusted Agent launch URL');
  return Object.freeze({projectId,generation:result.generation as string,url:url.href,expiresAt:result.expiresAt as number});
}

/** Only removes the server launch snapshot; call after stopping/persisting and
 * destroying the browser host. Failure must not be reported as cleanup success.
 */
export async function revokeAgentLaunch(launch:{projectId:string;url:string},hostOrigin:string,signal:AbortSignal):Promise<void> {
  const projectId=launch.projectId,url=new URL(launch.url),host=new URL(hostOrigin);
  const match=/^\/agent-host\/([a-f0-9-]{36})\/index\.html$/.exec(url.pathname);
  if(!/^[A-Za-z0-9_-]{1,128}$/.test(projectId) || host.origin!==hostOrigin || !['http:','https:'].includes(host.protocol)
    || hostOrigin===location.origin || url.origin!==hostOrigin || url.username || url.password || url.search || url.hash || !match)throw new Error('Invalid Agent revocation target');
  const operation=AbortSignal.any([signal,AbortSignal.timeout(15000)]);
  operation.throwIfAborted();
  const response=await fetch(new URL(`/api/projects/${projectId}/agent-launch/${match[1]}`,location.origin),{
    method:'DELETE',credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation,
  });
  operation.throwIfAborted();
  if(response.status!==204)throw new Error('Agent launch cleanup was not confirmed');
}
