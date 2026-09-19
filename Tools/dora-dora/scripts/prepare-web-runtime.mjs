import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const destination = path.join(root, 'Tools/dora-dora/public/web-player');
const lockPath = process.env.DORA_WEB_RUNTIME_LOCK
  ? path.resolve(process.env.DORA_WEB_RUNTIME_LOCK)
  : new URL('./web-runtime-lock.json', import.meta.url);
const lock = JSON.parse(await fs.readFile(lockPath, 'utf8'));
// Export owns its page template; ignore shells in older gallery/local locks.
const runtimeFiles = Object.fromEntries(Object.entries(lock.files).filter(([name]) => name !== 'index.html'));
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const localFiles = {
  'dora-logo.png': await fs.readFile(path.join(root, 'Tools/dora-dora/public/logo512.png')),
  'LICENSE-Dora.txt': await fs.readFile(path.join(root, 'LICENSE.txt')),
  'LICENSES.3rdparty.md': await fs.readFile(path.join(root, 'LICENSES.3rdparty.md')),
  'NOTICE.txt': await fs.readFile(path.join(root, 'NOTICE.txt')),
};
const files = {...runtimeFiles, ...Object.fromEntries(Object.entries(localFiles).map(([name, data]) => [name, {size: data.length, sha256: hash(data)}]))};
let cached = true;
for (const [name, expected] of Object.entries(files)) {
  const bytes = await fs.readFile(path.join(destination, name)).catch(() => null);
  if (!bytes || bytes.length !== expected.size || hash(bytes) !== expected.sha256) {cached = false; break;}
}
if (cached) {
  await fs.writeFile(path.join(destination, 'runtime.json'), JSON.stringify({version: 1, engineVersion: lock.engineVersion, files}));
  console.log('Web export runtime is ready (verified cache).');
} else {
  const stage = `${destination}.tmp-${process.pid}`;
  await fs.mkdir(stage, {recursive: true});
  try {
    for (const [name, expected] of Object.entries(runtimeFiles)) {
      const cachedBytes = await fs.readFile(path.join(destination, name)).catch(() => null);
      let bytes = cachedBytes;
      if (!bytes || bytes.length !== expected.size || hash(bytes) !== expected.sha256) {
        console.log(`Preparing Web export runtime: ${name}`);
        const url = new URL(name, lock.baseUrl);
        if (url.protocol === 'file:') {
          bytes = await fs.readFile(url);
        } else {
          const response = await fetch(url, {signal: AbortSignal.timeout(180000)});
          if (!response.ok) throw new Error(`Web runtime download failed (${response.status}): ${name}`);
          bytes = Buffer.from(await response.arrayBuffer());
        }
      }
      if (bytes.length !== expected.size || hash(bytes) !== expected.sha256) throw new Error(`Web runtime checksum mismatch: ${name}`);
      await fs.writeFile(path.join(stage, name), bytes);
    }
    for (const [name, data] of Object.entries(localFiles)) await fs.writeFile(path.join(stage, name), data);
    await fs.writeFile(path.join(stage, 'runtime.json'), JSON.stringify({version: 1, engineVersion: lock.engineVersion, files}));
    await fs.rm(destination, {recursive: true, force: true});
    await fs.rename(stage, destination);
    console.log('Web export runtime prepared.');
  } finally {
    await fs.rm(stage, {recursive: true, force: true});
  }
}
