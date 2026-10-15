import { validateSnapshot, isProjectPath } from '@dora-studio/contracts';
import { createWorkspaceList } from './workspace-list.js';

/** Each binding owns a matcher instance and a copied revision. No host filesystem. */
export async function createSnapshotListBackend(input, createMatcher) {
  const snapshot = structuredClone(input);
  const errors = validateSnapshot(snapshot);
  if (errors.length) throw new Error(errors.join('; '));
  const module = await createMatcher();
  const reset = module.cwrap('glob_reset', null, []);
  const add = module.cwrap('glob_add', null, ['string']);
  const compile = module.cwrap('glob_compile', null, []);
  const match = module.cwrap('glob_match', 'number', ['string']);
  const skip = module.cwrap('glob_skip_directory', 'number', ['string']);
  const root = '/project';
  const resolve = (workDir, path) => {
    if (workDir !== snapshot.projectId || typeof path !== 'string' || /^[\\/]/.test(path)) return undefined;
    const relative = path.replace(/\\/g, '/').replace(/^(\.\/)+/, '').replace(/\/$/, '');
    if (relative === '' || relative === '.') return root;
    return isProjectPath(relative) && !relative.startsWith('@') ? `${root}/${relative}` : undefined;
  };
  return createWorkspaceList({
    resolveWorkspaceSearchPath: resolve,
    toWorkspaceRelativePath: (_workDir, path) => path,
    Content: { glob(searchRoot, patterns, levels) {
      if (Object.keys(levels).length) throw new Error('Source variant filtering is not yet connected');
      if (patterns.some(pattern => typeof pattern !== 'string' || pattern.includes('\0'))) throw new Error('Invalid glob pattern');
      reset(); patterns.forEach(add); compile();
      const prefix = searchRoot === root ? '' : searchRoot.slice(root.length + 1) + '/';
      const results = [];
      // Stable snapshot order, independent of filesystem enumeration order.
      for (const file of snapshot.files) {
        if (!file.path.startsWith(prefix)) continue;
        const relative = file.path.slice(prefix.length);
        const parts = relative.split('/');
        let pruned = false;
        for (let i = 1; i < parts.length; i++) {
          if (skip(parts.slice(0, i).join('/'))) { pruned = true; break; }
        }
        if (!pruned && match(relative)) results.push(relative);
      }
      return results;
    } },
  });
}
