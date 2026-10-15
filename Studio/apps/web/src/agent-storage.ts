/** Stable local Agent database namespace, supplied before WASM storage mounts.
 * Identity must come from trusted provisioning, not project files. Namespacing
 * prevents accidental mixing; it is not authorization or encryption.
 */
export async function agentStorageId(parentOrigin:string, accountId:string, projectId:string):Promise<string> {
  const origin=new URL(parentOrigin);
  if(!['http:','https:'].includes(origin.protocol) || origin.origin!==parentOrigin
    || !accountId || !projectId || accountId.length>1024 || projectId.length>1024)throw new Error('Invalid Agent storage identity');
  // Generation/session/revision intentionally excluded: reopening must find the
  // existing database, including all sub-sessions belonging to this project.
  const input=new TextEncoder().encode(JSON.stringify(['studio-agent-v1',parentOrigin,accountId,projectId]));
  const hash=await crypto.subtle.digest('SHA-256',input);
  return `agent-${[...new Uint8Array(hash)].map(byte=>byte.toString(16).padStart(2,'0')).join('')}`;
}

/** Acquire before mounting IDBFS. Release only after all runtime writes have
 * stopped, never merely on transport disconnect. Browser destruction releases
 * its locks automatically. All hosts sharing this database must use this lock.
 */
export function acquireAgentStorage(storageId:string, locks:LockManager|undefined=navigator.locks):Promise<{release():Promise<void>}> {
  if(!/^agent-[a-f0-9]{64}$/.test(storageId))return Promise.reject(new Error('Invalid Agent storage ID'));
  if(!locks)return Promise.reject(new Error('Exclusive Agent storage is unavailable in this browser'));
  return new Promise((resolve,reject)=>{
    let unlock!:()=>void;
    const held=new Promise<void>(done=>{unlock=done;});
    const operation=locks.request(`dora-studio-storage:${storageId}`,{mode:'exclusive',ifAvailable:true},async lock=>{
      if(!lock)throw new Error('This project Agent is already open in another tab');
      resolve({release:async()=>{unlock();await operation;}});
      await held;
    });
    void operation.catch(reject);
  });
}
