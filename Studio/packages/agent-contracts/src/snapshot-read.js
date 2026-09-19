import { validateSnapshot, isProjectPath } from '@dora-studio/contracts';
import { formatReadSlice } from './read-slice.js';

// One immutable revision per binding. No access to host filesystem or other projects.
export function createSnapshotReadBackend(input, virtualFiles = []) {
  const snapshot = structuredClone(input);
  const errors = validateSnapshot(snapshot);
  if (errors.length) throw new Error(errors.join('; '));
  const files = new Map(snapshot.files.map(file => [file.path, file]));
  const virtual = new Map();
  for (const file of virtualFiles) {
    if (!file || typeof file.text !== 'string' || typeof file.path !== 'string' ||
        !(file.path === '@dora_full_logs.txt' ||
          (file.path.startsWith('@dora-doc/') && isProjectPath(file.path.slice('@dora-doc/'.length))))) {
      throw new Error('Invalid virtual document binding');
    }
    if (virtual.has(file.path)) throw new Error('Duplicate virtual document binding');
    virtual.set(file.path, file.text);
  }
  return (workDir, path, startLine = 1, endLine = startLine < 0 ? -1 : 300) => {
    if (workDir !== snapshot.projectId) return { success: false, message: 'Project identity mismatch' };
    if (typeof path !== 'string') return { success: false, message: 'Invalid project path' };
    // Virtual namespaces are exact read-only bindings, never a project-file fallback.
    if (path === '@dora_full_logs.txt' || path.startsWith('@dora-doc/')) {
      const text = virtual.get(path);
      return text === undefined ? { success: false, message: 'Virtual document is unavailable for this request' }
        : formatReadSlice(text, startLine, endLine);
    }
    const normalized = path.replace(/\\/g, '/').replace(/^(\.\/)+/, '');
    if (normalized === '@dora_full_logs.txt' || normalized.startsWith('@dora-doc/')) {
      return { success: false, message: 'Virtual document requires an exact path' };
    }
    if (!isProjectPath(normalized)) return { success: false, message: 'Invalid project path' };
    const file = files.get(normalized);
    if (!file) return { success: false, message: 'File not found in project snapshot' };
    if (file.kind !== 'text') return { success: false, message: 'Cannot read binary resource as text' };
    return formatReadSlice(file.text, startLine, endLine);
  };
}
