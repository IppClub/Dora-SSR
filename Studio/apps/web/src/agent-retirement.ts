export type AgentRetirementPhase='active'|'saving'|'save-failed'|'cleaning'|'cleanup-failed'|'closed';

/** Agent-only retirement. Author project/cloud persistence is a separate gate.
 * The caller exclusively owns the runtime while this coordinator is active.
 */
export function createAgentRetirement(actions:{persistAndClose():Promise<void>;revoke():Promise<void>}) {
  let saved=false,operation:Promise<void>|undefined;
  let snapshot:Readonly<{phase:AgentRetirementPhase}>=Object.freeze({phase:'active'});
  const listeners=new Set<()=>void>();
  const publish=(phase:AgentRetirementPhase)=>{
    snapshot=Object.freeze({phase});
    for(const listener of [...listeners])try{listener();}catch{/* UI observers cannot interrupt cleanup. */}
  };
  const run=():Promise<void>=>{
    if(operation)return operation;
    if(snapshot.phase==='closed')return Promise.resolve();
    // Defer notifications until operation is assigned, including reentrant UI.
    operation=Promise.resolve().then(async()=>{
      if(!saved){
        publish('saving');
        try{await actions.persistAndClose();saved=true;}
        catch(error){publish('save-failed');throw error;}
      }
      publish('cleaning');
      try{await actions.revoke();publish('closed');}
      catch(error){publish('cleanup-failed');throw error;}
    }).finally(()=>{operation=undefined;});
    return operation;
  };
  return {run,getSnapshot:()=>snapshot,subscribe:(listener:()=>void)=>{listeners.add(listener);return()=>{listeners.delete(listener);};}};
}
