import assert from 'node:assert/strict';
import {build} from 'esbuild';
import {mkdtemp, readFile, rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import vm from 'node:vm';

const directory = await mkdtemp(path.join(tmpdir(), 'dora-web-package-'));
try {
  const outfile = path.join(directory, 'package.mjs');
  await build({entryPoints: ['src/WebPackage/Archive.ts'], outfile, bundle: true, platform: 'node', format: 'esm'});
  const {createWebArchive, readProjectZip} = await import(pathToFileURL(outfile).href);
  const {zipSync, unzipSync, strToU8, strFromU8} = await import('fflate');
  const runtime = {
    'runtime.json': strToU8(JSON.stringify({engineVersion: '1.9.2'})),
    'audio-worklet.js': strToU8('worklet'),
    'dora-audio-mixer.wasm': new Uint8Array([0,97,115,109]),
    'index.html': strToU8((await readFile('../../Projects/Web/player-shell.html', 'utf8')).replace('{{{ SCRIPT }}}', '<script src="dora-player-runtime.js"></script>')),
    'dora-logo.png': new Uint8Array(await readFile('public/logo512.png')),
    'dora-player-runtime.js': strToU8('runtime'),
    'dora-player-runtime.wasm': new Uint8Array([0, 97, 115, 109]),
    'dora-player-runtime.data': new Uint8Array([42]),
    'dora-web-features.json': strToU8(JSON.stringify({activeProfile: 'dora-preset', modules: {threads: false, crossOriginIsolationRequired: false}})),
  };
  const project = {
    'init.lua': strToU8('print("game")'),
    'Image/中文 #1.png': new Uint8Array([0, 255, 20]),
    '.env': strToU8('secret'),
    'node_modules/dependency/index.js': strToU8('dependency'),
    'credentials.json': strToU8('secret'),
    'LICENSE': strToU8('license'),
  };
  const archive = unzipSync(await createWebArchive(readProjectZip(zipSync(project)), runtime));
  const manifest = JSON.parse(strFromU8(archive['dora-web-manifest.json']));
  const context = {URL};
  vm.runInNewContext(await readFile('../../Projects/Web/web-loader.js', 'utf8'), context);
  context.DoraWebLoader.validateManifest(manifest, 'https://example.test/game/dora-web-manifest.json');
  assert.deepEqual(manifest.files.map(file => file.path).sort(), ['Image/中文 #1.png', 'LICENSE', 'init.lua']);
  for (const file of manifest.files) {
    const bytes = archive[decodeURIComponent(file.url)];
    assert.ok(bytes, file.url);
    assert.equal(file.size, bytes.length);
    assert.equal(file.sha256, createHash('sha256').update(bytes).digest('hex'));
    assert.equal(file.startup, true);
  }
  assert.ok(archive['index.html'] && archive['dora-player-runtime.wasm']);
  assert.deepEqual(archive['dora-logo.png'], runtime['dora-logo.png']);
  const shell = strFromU8(archive['index.html']);
  assert.match(shell, /src="dora-logo\.png"/);
  assert.match(shell, /id="engine-name">Dora SSR</);
  const shellMetadata = JSON.parse(strFromU8(archive['runtime.json'])).files['index.html'];
  assert.equal(shellMetadata.size, archive['index.html'].length);
  assert.equal(shellMetadata.sha256, createHash('sha256').update(archive['index.html']).digest('hex'));
  assert.equal(archive['.env'], undefined);
  const newer = unzipSync(await createWebArchive(project, {...runtime, 'runtime.json': strToU8(JSON.stringify({engineVersion: '1.9.3'}))}));
  assert.equal(JSON.parse(strFromU8(newer['dora-web-manifest.json'])).engineVersion, '1.9.3');
  assert.ok(newer['audio-worklet.js'] && newer['dora-audio-mixer.wasm']);
  await assert.rejects(createWebArchive({'init.ts': strToU8('print("hi")')}, runtime), /entry/);
  await assert.rejects(createWebArchive(project, {...runtime, 'dora-player-runtime.wasm': undefined}), /runtime/);
  await assert.rejects(createWebArchive(project, {...runtime, 'dora-logo.png': undefined}), /runtime/);
  await assert.rejects(createWebArchive({'../init.lua': project['init.lua']}, runtime), /path/);
  assert.throws(() => readProjectZip(zipSync({'init.lua': project['init.lua'], 'huge.bin': new Uint8Array(65 * 1024 * 1024)})), /large/);
  console.log('Web package archive, loader compatibility, filtering, and failure tests passed.');
} finally {
  await rm(directory, {recursive: true, force: true});
}
