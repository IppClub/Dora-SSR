import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {lstat, readFile, readlink} from 'node:fs/promises';
import path from 'node:path';

function git(cwd, args, encoding = 'utf8') {
  return execFileSync('git', args, {cwd, encoding, stdio: ['ignore', 'pipe', 'pipe']});
}

async function hashUntracked(hash, cwd) {
  const names = git(cwd, ['ls-files', '--others', '--exclude-standard', '-z'], 'buffer')
    .toString('utf8').split('\0').filter(Boolean).sort();
  for (const name of names) {
    const file = path.join(cwd, name);
    const info = await lstat(file);
    hash.update(`untracked\0${name}\0${info.mode}\0`);
    hash.update(info.isSymbolicLink() ? await readlink(file) : await readFile(file));
    hash.update('\0');
  }
}

async function hashDirtyRepository(hash, cwd, label) {
  hash.update(`repository\0${label}\0`);
  hash.update(git(cwd, ['rev-parse', 'HEAD']));
  hash.update(git(cwd, ['status', '--porcelain=v1', '--untracked-files=all']));
  hash.update(git(cwd, ['diff', '--binary', 'HEAD', '--']));
  await hashUntracked(hash, cwd);
}

export async function runtimeSourceState(root) {
  try {
    const sourceCommit = git(root, ['rev-parse', 'HEAD']).trim();
    if (!/^[0-9a-f]{40}$/.test(sourceCommit)) throw new Error('invalid Git commit');
    const status = git(root, ['status', '--porcelain=v1', '--untracked-files=all']);
    if (!status) return {sourceCommit, sourceFingerprint: sourceCommit, sourceDirty: false};

    const hash = createHash('sha256');
    await hashDirtyRepository(hash, root, '.');
    const submodules = git(root, ['submodule', 'foreach', '--quiet', '--recursive', 'pwd'])
      .split('\n').map(value => value.trim()).filter(Boolean).sort();
    for (const submodule of submodules) {
      await hashDirtyRepository(hash, submodule, path.relative(root, submodule));
    }
    return {sourceCommit, sourceFingerprint: hash.digest('hex'), sourceDirty: true};
  } catch (error) {
    return {sourceCommit: null, sourceFingerprint: null, sourceDirty: true,
      sourceStateError: error instanceof Error ? error.message : String(error)};
  }
}

export function forceWebRuntimeRebuild(env = process.env) {
  return /^(?:1|true|yes|on)$/i.test(env.DORA_WEB_RUNTIME_FORCE_REBUILD || '');
}
