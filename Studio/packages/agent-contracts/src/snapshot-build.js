import { authoredProjectFiles, validateSnapshot, isProjectPath } from '@dora-studio/contracts';
import { createWorkspaceBuild } from './workspace-build.js';

/** Bind upstream traversal to one revision, never to an ambient host filesystem. */
export function createSnapshotBuildBackend(input, compileFile) {
  const snapshot = structuredClone(input);
  const errors = validateSnapshot(snapshot);
  if (errors.length) throw new Error(errors.join('; '));
  if (typeof compileFile !== 'function') throw new Error('Missing compiler backend');
  const root = '/project';
  const files = new Map(snapshot.files.map(file => [`${root}/${file.path}`, file]));
  const authoredPaths = new Set(authoredProjectFiles(snapshot.files).map(file => `${root}/${file.path}`));
  const directories = new Set([root]);
  for (const path of files.keys()) {
    let parent = path.slice(0, path.lastIndexOf('/'));
    while (parent.startsWith(root)) {
      directories.add(parent);
      parent = parent.slice(0, parent.lastIndexOf('/'));
    }
  }
  const resolve = (workDir, path) => {
    if (workDir !== snapshot.projectId || typeof path !== 'string' || /^[\\/]/.test(path)) return undefined;
    const normalized = path.replace(/\\/g, '/').replace(/^(\.\/)+/, '').replace(/\/$/, '');
    if (normalized === '.' || normalized === '') return root;
    return isProjectPath(normalized) && !normalized.startsWith('@') ? `${root}/${normalized}` : undefined;
  };
  const Path = (...parts) => parts.join('/');
  Path.getExt = path => { const name = path.split('/').at(-1); const dot = name.lastIndexOf('.'); return dot < 0 ? '' : name.slice(dot + 1); };
  Path.getName = path => path.split('/').at(-1).replace(/\.[^.]*$/, '');
  const compile = async (path, isCancelled) => {
    const file = files.get(path);
    if (!file || file.kind !== 'text') return { success: false, file: path, message: 'Cannot compile a binary resource as text' };
    if (isCancelled?.()) return { success: false, file: path, message: 'Build canceled.', interrupted: true };
    try {
      const result = await compileFile({ snapshot: structuredClone(snapshot), path: file.path, isCancelled });
      if (isCancelled?.()) return { success: false, file: path, message: 'Build canceled.', interrupted: true };
      if (result?.success === true) return { success: true, file: path };
      return { success: false, file: path, message: typeof result?.message === 'string' ? result.message : 'Compiler did not return a valid result',
        ...(result?.interrupted === true ? { interrupted: true } : {}) };
    } catch (error) {
      return { success: false, file: path, message: error instanceof Error ? error.message : 'Compiler failed' };
    }
  };
  // Each invocation captures its own cancellation function, including non-TS tools.
  return request => createWorkspaceBuild({
    Path, Log() {},
    Content: { exist: path => files.has(path) || directories.has(path), isdir: path => directories.has(path),
      load: path => files.get(path)?.kind === 'text' ? files.get(path).text : undefined,
      isAbsolutePath: path => path.startsWith('/') },
    resolveWorkspaceSearchPath: resolve,
    toWorkspaceRelativePath: (_workDir, path) => path.startsWith(`${root}/`) ? path.slice(root.length + 1) : path,
    listFiles: ({ workDir, path, globs, maxEntries }) => {
      const target = resolve(workDir, path);
      if (!target || !directories.has(target)) return { success: false, files: [] };
      const extensions = globs.map(glob => glob.replace(/^\*\*\/\*/, ''));
      const selected = [...files.keys()].filter(file => authoredPaths.has(file) && file.startsWith(`${target}/`) && extensions.some(ext => file.endsWith(ext))).sort();
      // Never silently omit files at the upstream traversal limit.
      if (selected.length > maxEntries) throw new Error('Build file limit exceeded');
      return { success: true, files: selected.map(file => file.slice(target.length + 1)) };
    },
    sendWebIDEFileUpdate: path => files.get(path)?.kind === 'text',
    runSingleTsTranspile: (path, _content, _workDir, isCancelled) => compile(path, isCancelled),
    runSingleNonTsBuild: path => compile(path, request.isCancelled),
  })(request);
}
