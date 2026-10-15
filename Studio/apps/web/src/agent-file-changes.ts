import {isProjectPath,validateSnapshot,type ProjectFile} from '@dora-studio/contracts';
import type {LocalProject,LocalWorkspace} from './workspace';

export type AgentFileChanges = {
  projectId:string;
  baseRevision:number;
  writes:ProjectFile[];
  deletes:string[];
};

/** Only explicit author-file changes, never a whole runtime filesystem snapshot.
 * The caller must authenticate the tool operation and exclude trusted host files.
 * LocalWorkspace.save performs the revision check and checkpoint in one transaction.
 */
export async function saveAgentFileChanges(storage:Pick<LocalWorkspace,'save'>,
  input:LocalProject,changes:AgentFileChanges,signal:AbortSignal) {
  signal.throwIfAborted();
  const project=structuredClone(input),batch=structuredClone(changes);
  if(batch.projectId!==project.snapshot.projectId || batch.baseRevision!==project.snapshot.revision)
    throw new Error('Agent changes belong to a different project revision');
  if(!Array.isArray(batch.writes) || !Array.isArray(batch.deletes) || batch.writes.length+batch.deletes.length===0)
    throw new Error('Empty or invalid Agent change batch');
  const files=new Map(project.snapshot.files.map(file=>[file.path,file]));
  const touched=new Set<string>();
  const check=(path:string)=>{
    if(!isProjectPath(path) || touched.has(path)) throw new Error('Invalid or duplicate Agent change path');
    touched.add(path);
  };
  for(const path of batch.deletes) {
    check(path);
    if(!files.delete(path)) throw new Error('Deleted Agent target does not exist');
  }
  for(const file of batch.writes) {check(file.path);files.set(file.path,file);}
  const snapshot={...project.snapshot,revision:batch.baseRevision+1,files:[...files.values()]};
  const errors=validateSnapshot(snapshot);
  if(errors.length) throw new Error(errors.join('; '));
  signal.throwIfAborted();
  return storage.save(project.name,snapshot,batch.baseRevision,true);
}
