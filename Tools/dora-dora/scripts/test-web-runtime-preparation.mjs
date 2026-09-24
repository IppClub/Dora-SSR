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
  const runtimeNames = ['dora-player-runtime.js', 'dora-player-runtime.wasm', 'dora-player-runtime.data',
    'dora-web-features.json', 'audio-worklet.js', 'dora-audio-mixer.wasm'];
  await mkdir(path.dirname(script), {recursive: true});
  await mkdir(path.join(ide, 'public'), {recursive: true});
  await mkdir(path.join(root, 'Tools/build-scripts'), {recursive: true});
  await mkdir(path.join(root, 'Source/Basic'), {recursive: true});
  await mkdir(path.join(root, 'Projects/Web'), {recursive: true});
  await mkdir(source);
  await copyFile(new URL('./prepare-web-runtime.mjs', import.meta.url), script);
  await copyFile(new URL('./web-runtime-source.mjs', import.meta.url), path.join(ide, 'scripts/web-runtime-source.mjs'));
  for (const name of ['LICENSE.txt', 'LICENSES.3rdparty.md', 'NOTICE.txt']) await writeFile(path.join(root, name), name);
  await writeFile(path.join(ide, 'public/logo512.png'), 'test logo');
  await writeFile(path.join(root, 'Source/Basic/Application.cpp'), '#define DORA_VERSION "1.9.3"_slice\n');
  await writeFile(path.join(root, 'Projects/Web/toolchain.env'), 'DORA_WEB_RUST_MIN_VERSION=1.85.1\n');
  await writeFile(path.join(root, '.gitignore'), [
    'build/',
    'build-count',
    'model-3d-feature',
    'music-feature',
    'love-feature',
    'yue-feature',
    'runtime-source/',
    'local-lock.json',
    'Tools/dora-dora/public/web-player/',
  ].join('\n'));
const fakeBuild = `#!/usr/bin/env bash
set -euo pipefail
count_file="$PWD/build-count"
count=0
[[ ! -f "$count_file" ]] || count="$(<"$count_file")"
printf '%s' "$((count + 1))" > "$count_file"
printf '%s' "\${DORA_WEB_FEATURE_MODEL_3D:-}" > "$PWD/model-3d-feature"
printf '%s' "\${DORA_WEB_FEATURE_MUSIC:-}" > "$PWD/music-feature"
printf '%s' "\${DORA_WEB_FEATURE_LOVE:-}" > "$PWD/love-feature"
printf '%s' "\${DORA_WEB_FEATURE_YUE:-}" > "$PWD/yue-feature"
mkdir -p "$DORA_WEB_PLAYER_PACKAGE_DIR"
for name in dora-player-runtime.js dora-player-runtime.wasm dora-player-runtime.data dora-web-features.json audio-worklet.js dora-audio-mixer.wasm; do
  if [[ "$name" == "dora-web-features.json" ]]; then
    printf '%s' '{"modules":{"model3D":true,"jolt3D":true,"rustBridge":true,"loveNode":true,"yueCompiler":false,"tealCompiler":false,"xmlCompiler":false}}' > "$DORA_WEB_PLAYER_PACKAGE_DIR/$name"
  else
    printf 'locally built %s' "$name" > "$DORA_WEB_PLAYER_PACKAGE_DIR/$name"
  fi
done
`;
  await writeFile(path.join(root, 'Tools/build-scripts/build_web.sh'), fakeBuild);
  for (const args of [
    ['init'],
    ['config', 'user.email', 'runtime-test@example.invalid'],
    ['config', 'user.name', 'Runtime Test'],
    ['add', '.'],
    ['commit', '-m', 'fixture'],
  ]) {
    const result = spawnSync('git', args, {cwd: root, encoding: 'utf8'});
    assert.equal(result.status, 0, result.stderr);
  }
  const run = env => spawnSync(process.execPath, [script], {encoding: 'utf8', env: {...process.env, ...env}});

  const cold = run();
  assert.equal(cold.status, 0, cold.stderr);
  assert.match(cold.stdout, /building it from the local source tree/);
  assert.equal(await readFile(path.join(root, 'build-count'), 'utf8'), '1');
  assert.equal(await readFile(path.join(root, 'model-3d-feature'), 'utf8'), 'ON');
  assert.equal(await readFile(path.join(root, 'music-feature'), 'utf8'), 'OFF');
  assert.equal(await readFile(path.join(root, 'love-feature'), 'utf8'), 'ON');
  assert.equal(await readFile(path.join(root, 'yue-feature'), 'utf8'), 'OFF');
  const output = path.join(ide, 'public/web-player');
  for (const name of runtimeNames.filter(name => name !== 'dora-web-features.json')) {
    assert.match(await readFile(path.join(output, name), 'utf8'), /^locally built /);
  }
  const metadata = JSON.parse(await readFile(path.join(output, 'runtime.json'), 'utf8'));
  assert.equal(metadata.engineVersion, '1.9.3');
  assert.match(metadata.sourceCommit, /^[0-9a-f]{40}$/);
  assert.equal(metadata.sourceFingerprint, metadata.sourceCommit);
  assert.equal(metadata.sourceDirty, false);

  const warm = run();
  assert.equal(warm.status, 0, warm.stderr);
  assert.match(warm.stdout, /verified local cache/);
  assert.equal(await readFile(path.join(root, 'build-count'), 'utf8'), '1');

  // A source change must invalidate the cache even when the public version is unchanged.
  await writeFile(path.join(root, 'Source/Basic/Application.cpp'), '#define DORA_VERSION "1.9.3"_slice\n// changed source\n');
  const sourceChange = run();
  assert.equal(sourceChange.status, 0, sourceChange.stderr);
  assert.match(sourceChange.stdout, /building it from the local source tree/);
  assert.equal(await readFile(path.join(root, 'build-count'), 'utf8'), '2');
  const changedMetadata = JSON.parse(await readFile(path.join(output, 'runtime.json'), 'utf8'));
  assert.equal(changedMetadata.sourceCommit, metadata.sourceCommit);
  assert.notEqual(changedMetadata.sourceFingerprint, metadata.sourceFingerprint);
  assert.equal(changedMetadata.sourceDirty, true);

  // The explicit switch rebuilds even when the source fingerprint is unchanged.
  const forced = run({DORA_WEB_RUNTIME_FORCE_REBUILD: '1'});
  assert.equal(forced.status, 0, forced.stderr);
  assert.match(forced.stdout, /rebuild explicitly requested/);
  assert.equal(await readFile(path.join(root, 'build-count'), 'utf8'), '3');

  // A checksum-valid but feature-incomplete cache must be rebuilt.
  const featureName = 'dora-web-features.json';
  const incompleteFeatures = Buffer.from('{"modules":{"model3D":false,"jolt3D":false,"rustBridge":false}}');
  await writeFile(path.join(output, featureName), incompleteFeatures);
  changedMetadata.files[featureName] = {size: incompleteFeatures.length, sha256: createHash('sha256').update(incompleteFeatures).digest('hex')};
  await writeFile(path.join(output, 'runtime.json'), JSON.stringify(changedMetadata));
  const featureRepair = run();
  assert.equal(featureRepair.status, 0, featureRepair.stderr);
  assert.equal(await readFile(path.join(root, 'build-count'), 'utf8'), '4');

  // Corruption triggers a fresh local build instead of a network request.
  await writeFile(path.join(output, runtimeNames[0]), 'corrupt');
  const repair = run();
  assert.equal(repair.status, 0, repair.stderr);
  assert.equal(await readFile(path.join(root, 'build-count'), 'utf8'), '5');

  // Explicit locks remain available for reproducible local overrides.
  const lockFiles = {};
  for (const name of runtimeNames) {
    const bytes = Buffer.from(name === featureName
      ? '{"modules":{"model3D":true,"jolt3D":true,"rustBridge":true,"loveNode":true,"yueCompiler":false,"tealCompiler":false,"xmlCompiler":false}}'
      : `override ${name}`);
    await writeFile(path.join(source, name), bytes);
    lockFiles[name] = {size: bytes.length, sha256: createHash('sha256').update(bytes).digest('hex')};
  }
  lockFiles['index.html'] = {size: 999, sha256: '0'.repeat(64)};
  const lockPath = path.join(root, 'local-lock.json');
  await writeFile(lockPath, JSON.stringify({engineVersion: '1.9.3', baseUrl: pathToFileURL(source + path.sep).href, files: lockFiles}));
  const override = run({DORA_WEB_RUNTIME_LOCK: lockPath});
  assert.equal(override.status, 0, override.stderr);
  assert.match(await readFile(path.join(output, runtimeNames[0]), 'utf8'), /^override /);
  await assert.rejects(readFile(path.join(output, 'index.html')), {code: 'ENOENT'});

  // A bad override cannot publish a partial runtime over the working cache.
  lockFiles[runtimeNames[0]] = {size: 3, sha256: '0'.repeat(64)};
  await writeFile(lockPath, JSON.stringify({engineVersion: '1.9.3', baseUrl: pathToFileURL(source + path.sep).href, files: lockFiles}));
  await writeFile(path.join(source, runtimeNames[0]), 'bad');
  const invalid = run({DORA_WEB_RUNTIME_LOCK: lockPath});
  assert.notEqual(invalid.status, 0);
  assert.match(invalid.stderr, /checksum mismatch/);
  assert.match(await readFile(path.join(output, runtimeNames[0]), 'utf8'), /^override /);
  console.log('Runtime preparation: local auto-build, verified cache, repair, and explicit override passed.');
} finally {
  await rm(root, {recursive: true, force: true});
}
