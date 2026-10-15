import { isProjectPath, validateSnapshot, type ProjectFile } from '@dora-studio/contracts';
import type { LocalProject, LocalWorkspace } from './workspace';

type Change = { path: string; op: string; content?: string };

/** One tool invocation, one fixed base revision. Storage provides atomic conflict checking. */
export function createLocalEditBackend(storage: LocalWorkspace, project: LocalProject, taskId: number) {
  let current = structuredClone(project);
  const initialErrors = validateSnapshot(current.snapshot);
  if (initialErrors.length || !Number.isSafeInteger(taskId) || taskId < 0) throw new Error('Invalid edit binding');
  const baseRevision = current.snapshot.revision;
  let submitted = false;
  const validTarget = (workDir: string, path: string) => workDir === current.snapshot.projectId &&
    isProjectPath(path) && !path.startsWith('@');
  const inspect = (workDir: string, path: string) => {
    if (!validTarget(workDir, path)) return { success: false as const, message: 'Invalid project edit path' };
    const file = current.snapshot.files.find(file => file.path === path);
    if (file?.kind === 'binary') return { success: false as const, message: 'Cannot edit binary resource as text' };
    if (!file && current.snapshot.files.some(file => file.path.startsWith(path + '/') || path.startsWith(file.path + '/'))) {
      return { success: false as const, message: 'File/directory path conflict' };
    }
    return { success: true as const, exists: !!file, content: file?.text ?? '' };
  };
  return {
    inspectWorkspaceTextTarget: inspect,
    readFileRaw(workDir: string, path: string) {
      const result = inspect(workDir, path);
      return result.success && result.exists ? { success: true, content: result.content } : { success: false, message: 'File not found' };
    },
    async applyFileChanges(requestTaskId: number, workDir: string, changes: Change[]) {
      if (submitted || requestTaskId !== taskId || workDir !== current.snapshot.projectId) return { success: false, message: 'Stale or mismatched edit request' };
      submitted = true;
      try {
        if (!changes.length) throw new Error('No file changes');
        const files = new Map<string, ProjectFile>(current.snapshot.files.map(file => [file.path, file]));
        const seen = new Set<string>();
        for (const change of changes) {
          if (!validTarget(workDir, change.path) || seen.has(change.path) ||
              (change.op !== 'delete' && typeof change.content !== 'string') ||
              !['create', 'write', 'delete'].includes(change.op)) throw new Error('Invalid file change');
          seen.add(change.path);
          const prior = files.get(change.path);
          if (change.op === 'delete') {
            if (!prior) throw new Error('File not found');
            files.delete(change.path); continue;
          }
          if ((change.op === 'create' && prior) || (change.op === 'write' && (!prior || prior.kind !== 'text'))) throw new Error('File state changed');
          files.set(change.path, { path: change.path, kind: 'text', text: change.content! });
        }
        const snapshot = { ...current.snapshot, revision: baseRevision + 1, files: [...files.values()] };
        const errors = validateSnapshot(snapshot);
        if (errors.length) throw new Error(errors.join('; '));
        current = await storage.save(current.name, snapshot, baseRevision, true);
        return { success: true, checkpointId: baseRevision, checkpointSeq: snapshot.revision };
      } catch (error) {
        return { success: false, message: error instanceof Error ? error.message : String(error) };
      }
    },
    async deleteFile(requestTaskId: number, workDir: string, path: string) {
      const binary = current.snapshot.files.find(file => file.path === path)?.kind === 'binary';
      const result = await this.applyFileChanges(requestTaskId, workDir, [{ path, op: 'delete' }]);
      return { ...result, checkpointed: result.success, reversible: result.success, binary };
    },
    getProject: () => structuredClone(current),
  };
}
