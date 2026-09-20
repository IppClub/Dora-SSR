import assert from 'node:assert/strict';
import {mkdtemp, mkdir, readFile, writeFile, copyFile, rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';

// Use an isolated filesystem: never replace the developer's prepared runtime.
const root = await mkdtemp(path.join(tmpdir(), 'dora-runtime-preparation-'));
try {
  const ide = path.join(root, 'Tools/dora-dora');
  const source = path.join(root, 'runtime-source');
  const script = path.join(ide, 'scripts/prepare-web-runtime.mjs');
  await mkdir(path.dirname(script), {recursive: true});
  await mkdir(path.join(ide, 'public'), {recursive: true});
  await mkdir(source);
  await copyFile(new URL('./prepare-web-runtime.mjs', import.meta.url), script);
  for (const name of ['LICENSE.txt', 'LICENSES.3rdparty.md', 'NOTICE.txt']) await writeFile(path.join(root, name), name);
  await writeFile(path.join(ide, 'public/logo512.png'), 'test logo');
  const bytes = Buffer.from('test runtime');
  const name = 'dora-player-runtime.js';
  const lock = {engineVersion: '1.9.3', baseUrl: pathToFileURL(source + path.sep).href, files: {
    [name]: {size: bytes.length, sha256: createHash('sha256').update(bytes).digest('hex')},
    // Old locks may describe a missing or differently formatted compiler shell.
    'index.html': {size: 999, sha256: '0'.repeat(64)},
  }};
  const lockPath = path.join(root, 'local-lock.json');
  await writeFile(lockPath, JSON.stringify(lock));
  await writeFile(path.join(source, name), bytes);
  const run = () => spawnSync(process.execPath, [script], {encoding: 'utf8', env: {...process.env, DORA_WEB_RUNTIME_LOCK: lockPath}});
  const cold = run();
  assert.equal(cold.status, 0, cold.stderr);
  const output = path.join(ide, 'public/web-player');
  assert.deepEqual(await readFile(path.join(output, name)), bytes);
  assert.equal(JSON.parse(await readFile(path.join(output, 'runtime.json'), 'utf8')).files['index.html'], undefined);
  await assert.rejects(readFile(path.join(output, 'index.html')), {code: 'ENOENT'});
  await rm(path.join(source, name));
  const warm = run();
  assert.equal(warm.status, 0, warm.stderr);
  assert.match(warm.stdout, /verified cache/);

  // A bad replacement cannot publish a partial runtime over the working cache.
  lock.files[name] = {size: 3, sha256: '0'.repeat(64)};
  await writeFile(lockPath, JSON.stringify(lock));
  await writeFile(path.join(source, name), 'bad');
  const invalid = run();
  assert.notEqual(invalid.status, 0);
  assert.match(invalid.stderr, /checksum mismatch/);
  assert.deepEqual(await readFile(path.join(output, name)), bytes);
  console.log('Runtime preparation: shell independence, local cache, and checksum rejection passed.');
} finally {
  await rm(root, {recursive: true, force: true});
}
