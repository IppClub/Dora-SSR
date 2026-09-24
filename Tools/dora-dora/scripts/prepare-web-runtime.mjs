import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {forceWebRuntimeRebuild, runtimeSourceState} from './web-runtime-source.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const destination = path.join(root, 'Tools/dora-dora/public/web-player');
const runtimeNames = [
  'dora-player-runtime.js',
  'dora-player-runtime.wasm',
  'dora-player-runtime.data',
  'dora-web-features.json',
  'audio-worklet.js',
  'dora-audio-mixer.wasm',
];
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const describe = bytes => ({size: bytes.length, sha256: hash(bytes)});
const matches = (bytes, expected) => bytes && expected
  && bytes.length === expected.size && hash(bytes) === expected.sha256;
const read = file => fs.readFile(file).catch(() => null);
const hasExportFeatures = runtime => {
  try {
    const features = JSON.parse(runtime['dora-web-features.json']);
    return features?.modules?.model3D === true
      && features.modules.jolt3D === true
      && features.modules.rustBridge === true
      && features.modules.loveNode === true
      && features.modules.yueCompiler === false
      && features.modules.tealCompiler === false
      && features.modules.xmlCompiler === false;
  } catch {
    return false;
  }
};
const localFiles = {
  'dora-logo.png': await fs.readFile(path.join(root, 'Tools/dora-dora/public/logo512.png')),
  'LICENSE-Dora.txt': await fs.readFile(path.join(root, 'LICENSE.txt')),
  'LICENSES.3rdparty.md': await fs.readFile(path.join(root, 'LICENSES.3rdparty.md')),
  'NOTICE.txt': await fs.readFile(path.join(root, 'NOTICE.txt')),
};

async function engineVersion() {
  const source = await fs.readFile(path.join(root, 'Source/Basic/Application.cpp'), 'utf8');
  const version = source.match(/^#define DORA_VERSION "(\d+\.\d+\.\d+)"_slice$/m)?.[1];
  if (!version) throw new Error('Cannot read DORA_VERSION from Source/Basic/Application.cpp');
  return version;
}

async function publish(runtime, version, sourceState) {
  if (!hasExportFeatures(runtime)) throw new Error('Web export runtime is missing required 3D features');
  const parent = path.dirname(destination);
  await fs.mkdir(parent, {recursive: true});
  const stage = await fs.mkdtemp(path.join(parent, '.web-player-'));
  try {
    const files = {};
    for (const name of runtimeNames) {
      const bytes = runtime[name];
      if (!bytes?.length) throw new Error(`Missing locally built Web runtime file: ${name}`);
      files[name] = describe(bytes);
      await fs.writeFile(path.join(stage, name), bytes);
    }
    for (const [name, bytes] of Object.entries(localFiles)) {
      files[name] = describe(bytes);
      await fs.writeFile(path.join(stage, name), bytes);
    }
    await fs.writeFile(path.join(stage, 'runtime.json'), JSON.stringify({
      version: 1,
      engineVersion: version,
      sourceCommit: sourceState.sourceCommit,
      sourceFingerprint: sourceState.sourceFingerprint,
      sourceDirty: sourceState.sourceDirty,
      files,
    }));
    await fs.rm(destination, {recursive: true, force: true});
    await fs.rename(stage, destination);
  } finally {
    await fs.rm(stage, {recursive: true, force: true});
  }
}

async function cachedRuntime(sourceState) {
  const metadata = JSON.parse(await fs.readFile(path.join(destination, 'runtime.json'), 'utf8').catch(() => 'null'));
  if (!metadata || !/^\d+\.\d+\.\d+$/.test(metadata.engineVersion) || !metadata.files
    || !sourceState.sourceFingerprint || metadata.sourceCommit !== sourceState.sourceCommit
    || metadata.sourceFingerprint !== sourceState.sourceFingerprint
    || metadata.sourceDirty !== sourceState.sourceDirty) return null;
  const runtime = {};
  for (const name of runtimeNames) {
    const bytes = await read(path.join(destination, name));
    if (!matches(bytes, metadata.files[name])) return null;
    runtime[name] = bytes;
  }
  if (!hasExportFeatures(runtime)) return null;
  return {runtime, engineVersion: metadata.engineVersion};
}

async function prepareOverride(lockPath) {
  const lock = JSON.parse(await fs.readFile(path.resolve(lockPath), 'utf8'));
  // Export owns its page template; ignore shells in older gallery/local locks.
  const entries = Object.entries(lock.files).filter(([name]) => name !== 'index.html');
  const runtime = {};
  for (const [name, expected] of entries) {
    if (!runtimeNames.includes(name)) continue;
    let bytes = await read(path.join(destination, name));
    if (!matches(bytes, expected)) {
      console.log(`Preparing Web export runtime override: ${name}`);
      const url = new URL(name, lock.baseUrl);
      if (url.protocol === 'file:') {
        bytes = await fs.readFile(url);
      } else {
        const response = await fetch(url, {signal: AbortSignal.timeout(180000)});
        if (!response.ok) throw new Error(`Web runtime download failed (${response.status}): ${name}`);
        bytes = Buffer.from(await response.arrayBuffer());
      }
    }
    if (!matches(bytes, expected)) throw new Error(`Web runtime checksum mismatch: ${name}`);
    runtime[name] = bytes;
  }
  for (const name of runtimeNames) {
    if (!runtime[name]) throw new Error(`Web runtime override is missing: ${name}`);
  }
  await publish(runtime, lock.engineVersion, {
    sourceCommit: lock.sourceCommit || null,
    sourceFingerprint: lock.sourceFingerprint || null,
    sourceDirty: lock.sourceDirty ?? true,
  });
  console.log('Web export runtime prepared from explicit override.');
}

if (process.env.DORA_WEB_RUNTIME_LOCK) {
  await prepareOverride(process.env.DORA_WEB_RUNTIME_LOCK);
} else {
  const sourceState = await runtimeSourceState(root);
  const forced = forceWebRuntimeRebuild();
  if (sourceState.sourceStateError) {
    console.warn(`Web runtime source state is unavailable; cache disabled: ${sourceState.sourceStateError}`);
  }
  if (forced) console.log('Web export runtime rebuild explicitly requested.');
  const cached = forced ? null : await cachedRuntime(sourceState);
  if (cached) {
    // Refresh local notices without rebuilding the engine.
    await publish(cached.runtime, cached.engineVersion, sourceState);
    console.log('Web export runtime is ready (verified local cache).');
  } else {
    console.log('Web export runtime is missing or invalid; building it from the local source tree.');
    await fs.mkdir(path.join(root, 'build'), {recursive: true});
    const temporary = await fs.mkdtemp(path.join(root, 'build/web-runtime-package-'));
    try {
      const player = path.join(temporary, 'player');
      execFileSync('bash', ['Tools/build-scripts/build_web.sh'], {cwd: root, stdio: 'inherit', env: {
        ...process.env,
        DORA_WEB_BUILD_DIR: process.env.DORA_WEB_BUILD_DIR || path.join(root, 'build/web'),
        DORA_WEB_PACKAGE_DIR: path.join(temporary, 'probe'),
        DORA_WEB_PLAYER_PACKAGE_DIR: player,
        DORA_WEB_BUILD_ENGINE: '1',
        DORA_WEB_LINK_PLAYER: '1',
        DORA_WEB_BUILD_LOVE_PROBE: '0',
        DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER: '0',
        DORA_WEB_PTHREADS: '0',
        DORA_WEB_PROFILE: 'dora-preset',
        DORA_WEB_FEATURE_YUE: 'OFF',
        DORA_WEB_FEATURE_MUSIC: 'OFF',
        DORA_WEB_ALLOW_TOOLCHAIN_DRIFT: process.env.DORA_WEB_ALLOW_TOOLCHAIN_DRIFT ?? (process.env.CI ? '0' : '1'),
        DORA_WEB_BUILTIN_FONT: path.join(root, 'Assets/Font/sarasa-mono-sc-regular.ttf'),
        ...Object.fromEntries(['PHYSICS_2D', 'ENTITY', 'PLATFORMER', 'BUILTIN_LIBS', 'ML', 'LOVE', 'MODEL_3D']
          .map(feature => [`DORA_WEB_FEATURE_${feature}`, 'ON'])),
      }});
      const runtime = Object.fromEntries(await Promise.all(runtimeNames.map(async name => [name, await fs.readFile(path.join(player, name))])));
      await publish(runtime, await engineVersion(), sourceState);
      console.log('Web export runtime built from local sources.');
    } finally {
      await fs.rm(temporary, {recursive: true, force: true});
    }
  }
}
