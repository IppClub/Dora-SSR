import { createDirectoryBuildPlanner } from './directory-build-core.js';

function normalize(path) {
  const parts = [];
  for (const part of path.replaceAll('\\', '/').split('/')) {
    if (!part || part === '.') continue;
    if (part === '..' && parts.length && parts.at(-1) !== '..') parts.pop();
    else parts.push(part);
  }
  return (path.startsWith('/') ? '/' : '') + parts.join('/');
}

export const buildPath = (...parts) => normalize(parts.join('/'));
buildPath.getPath = path => path.slice(0, Math.max(0, path.lastIndexOf('/')));
buildPath.getFilename = path => path.slice(path.lastIndexOf('/') + 1);
buildPath.getName = path => buildPath.getFilename(path).replace(/(.+)\.[^.]*$/, '$1');
buildPath.getExt = path => buildPath.getFilename(path).match(/.+\.([^.]+)$/)?.[1] ?? '';
buildPath.replaceExt = (path, extension) => path.slice(0, path.lastIndexOf('.') + 1) + extension;
buildPath.getRelative = (path, root) => {
  const target = normalize(path).split('/');
  const base = normalize(root).split('/');
  let common = 0;
  while (common < target.length && common < base.length && target[common] === base[common]) common++;
  return [...base.slice(common).map(() => '..'), ...target.slice(common)].join('/') || '.';
};

// Snapshot paths are validated by the caller. Enumerate only supplied files
// and apply the shared planner's directory exclusions within the selected tree.
export function createSnapshotDirectoryPlanner(paths, load) {
  const files = new Set(paths);
  return createDirectoryBuildPlanner({
    glob(directory, patterns) {
      const skipped = new Set(patterns.slice(1).map(pattern => {
        const match = /^!\*\*\/([^*/?]+)\/\*\*$/.exec(pattern);
        if (!match) throw new Error(`Unsupported build exclusion: ${pattern}`);
        return match[1];
      }));
      const prefix = directory + '/';
      return [...files].filter(path => path.startsWith(prefix)).map(path => path.slice(prefix.length))
        .filter(path => !path.split('/').slice(0, -1).some(part => skipped.has(part)));
    },
    exist: path => files.has(path),
    load,
    read: (path, offset, count) => load(path)?.slice(offset, offset + count),
    isAbsolutePath: path => /^(?:[\\/]|[A-Za-z]:)/.test(path),
  }, buildPath);
}
