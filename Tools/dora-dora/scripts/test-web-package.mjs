import assert from 'node:assert/strict';
import {build} from 'esbuild';
import {mkdtemp, readFile, rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {createHash, webcrypto} from 'node:crypto';
import vm from 'node:vm';

const directory = await mkdtemp(path.join(tmpdir(), 'dora-web-package-'));
try {
  const outfile = path.join(directory, 'package.mjs');
  await build({entryPoints: ['src/WebPackage/Archive.ts'], outfile, bundle: true, platform: 'node', format: 'esm'});
  const {createWebArchive, readProjectZip} = await import(pathToFileURL(outfile).href);
  const {zipSync, unzipSync, strToU8, strFromU8} = await import('fflate');
  const runtime = {
    'runtime.json': strToU8(JSON.stringify({engineVersion: '1.9.3'})),
    'audio-worklet.js': strToU8('worklet'),
    'dora-audio-mixer.wasm': new Uint8Array([0,97,115,109]),
    'index.html': strToU8((await readFile('../../Projects/Web/player-shell.html', 'utf8')).replace('{{{ SCRIPT }}}', '<script src="dora-player-runtime.js"></script>')),
    'dora-logo.png': new Uint8Array(await readFile('public/logo512.png')),
    'dora-player-runtime.js': strToU8('runtime'),
    'dora-player-runtime.wasm': new Uint8Array([0, 97, 115, 109]),
    'dora-player-runtime.data': new Uint8Array([42]),
    'dora-web-features.json': strToU8(JSON.stringify({activeProfile: 'dora-preset', modules: {
      threads: false, crossOriginIsolationRequired: false, model3D: true, jolt3D: true, rustBridge: true,
    }})),
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
  assert.doesNotMatch(shell, /id="engine-name"/);
  const shellMetadata = JSON.parse(strFromU8(archive['runtime.json'])).files['index.html'];
  assert.equal(shellMetadata.size, archive['index.html'].length);
  assert.equal(shellMetadata.sha256, createHash('sha256').update(archive['index.html']).digest('hex'));
  assert.equal(archive['.env'], undefined);
  const newer = unzipSync(await createWebArchive(project, {...runtime, 'runtime.json': strToU8(JSON.stringify({engineVersion: '1.9.4'}))}));
  assert.equal(JSON.parse(strFromU8(newer['dora-web-manifest.json'])).engineVersion, '1.9.4');
  assert.ok(newer['audio-worklet.js'] && newer['dora-audio-mixer.wasm']);
  const pretendRuntime = {...runtime, 'dora-player-runtime.js': strToU8('Module.doraSnapshot; new URL("dora-audio-mixer.wasm",base); new URL("audio-worklet.js",base);')};
  const adaptedRuntime = unzipSync(await createWebArchive(project, pretendRuntime, 'html'));
  assert.match(strFromU8(adaptedRuntime['dora-player-runtime.js']), /Module\.locateFile\("audio-worklet.js"\)/);
  const invalidRuntime = {...pretendRuntime, 'dora-player-runtime.js': strToU8('new URL("audio-worklet.js",base);')};
  await assert.rejects(createWebArchive(project, invalidRuntime, 'html'), /Invalid snapshot\/audio v1 adapter/);
  const duplicateRuntime = {...pretendRuntime, 'dora-player-runtime.js': strToU8('new URL("dora-audio-mixer.wasm",base); new URL("audio-worklet.js",base); new URL("audio-worklet.js",base);')};
  await assert.rejects(createWebArchive(project, duplicateRuntime, 'html'), /Invalid snapshot\/audio v1 adapter/);
  assert.ok(unzipSync(await createWebArchive(project, pretendRuntime, 'http'))['dora-player-runtime.js']);
  const realRuntime = new Uint8Array(await readFile('public/web-player/dora-player-runtime.js').catch(() => {
    throw new Error('Run pnpm prepare:web-runtime before testing HTML runtime compatibility.');
  }));
  const htmlRuntime = {...runtime, 'dora-player-runtime.js': realRuntime};
  // Export owns its shell; compiler/gallery HTML formatting must not affect it.
  const foreignShell = '<html><body><canvas id=canvas></canvas><script async src=dora-player-runtime.js></script></body></html>';
  for (const format of ['html', 'http']) {
    const foreign = unzipSync(await createWebArchive(project, {...htmlRuntime, 'index.html': strToU8(foreignShell)}, format));
    const ownShell = strFromU8(foreign['index.html']);
    assert.doesNotMatch(ownShell, /id="engine-name"/);
    assert.match(ownShell, format === 'html' ? /src="html-loader.js"/ : /src="dora-player-runtime.js"/);
    const absent = unzipSync(await createWebArchive(project, {...htmlRuntime, 'index.html': undefined}, format));
    assert.equal(strFromU8(absent['index.html']), ownShell);
  }
  const html = unzipSync(await createWebArchive(project, htmlRuntime, 'html'));
  assert.match(strFromU8(html['index.html']), /src="html-loader.js"/);
  assert.doesNotMatch(strFromU8(html['index.html']), /id="engine-name"/);
  assert.equal(html['dora-player-runtime.wasm'], undefined);
  assert.equal(html['dora-web-manifest.json'], undefined);
  assert.ok(!Object.keys(html).some(name => name.startsWith('assets/')));
  assert.match(strFromU8(html['dora-player-runtime.js']), /Module\.locateFile\("audio-worklet.js"\)/);
  const htmlMetadata = JSON.parse(strFromU8(html['runtime.json']));
  for (const [name, file] of Object.entries(htmlMetadata.files)) {
    assert.equal(html[name]?.length, file.size, name);
    assert.equal(createHash('sha256').update(html[name]).digest('hex'), file.sha256, name);
  }
  async function bootHtml(overrides = {}) {
    const assetFiles = {...html, ...overrides};
    const faults = [], requests = [], blobs = [], revoked = [];
    class LocalURL extends URL {
      static createObjectURL(blob) { blobs.push(blob); return 'blob:test/' + blobs.length; }
      static revokeObjectURL(url) { revoked.push(url); }
    }
    const browser = {
      URL: LocalURL, Blob, TextEncoder, Uint8Array, atob, btoa, crypto: webcrypto, WebAssembly,
      setTimeout, clearTimeout, console: {error() {}}, Module: {},
      doraSetProgress(value, message) { browser.message = message; },
      doraSetState(state, message) { browser.message = message; faults.push({state, message}); }, addEventListener() {},
      document: {baseURI: 'file:///test/中文%20game/index.html', createElement: () => ({remove() {}}), body: {
        appendChild(script) {
          // Resolve using the encoded base so unicode and spaces remain valid.
          const relative = decodeURIComponent(script.src.slice(new URL('.', browser.document.baseURI).href.length));
          requests.push(relative);
          if (relative === 'dora-player-runtime.js') { if (!assetFiles[relative]) script.onerror(); return; }
          queueMicrotask(() => {
            if (!assetFiles[relative]) { script.onerror(); return; }
            vm.runInContext(strFromU8(assetFiles[relative]), sandbox);
            script.onload();
          });
        }
      }}
    };
    browser.window = browser;
    const sandbox = vm.createContext(browser);
    await vm.runInContext(strFromU8(html['html-loader.js']), sandbox);
    await new Promise(resolve => setTimeout(resolve, 10));
    return {browser, faults, requests, blobs, revoked};
  }
  const local = await bootHtml();
  assert.deepEqual(local.faults, []);
  assert.ok(local.requests.includes('dora-player-runtime.js'));
  assert.deepEqual(local.browser.Module.wasmBinary, runtime['dora-player-runtime.wasm']);
  assert.deepEqual(new Uint8Array(local.browser.Module.getPreloadedPackage()), runtime['dora-player-runtime.data']);
  assert.equal(local.browser.Module.getPreloadedPackage(), null);
  for (const file of local.browser.Module.doraSnapshot.files) assert.deepEqual(file.bytes, project[file.path]);
  assert.equal(local.blobs.length, 1);
  assert.match(local.browser.Module.locateFile('audio-worklet.js'), /^data:text\/javascript;base64,/);
  assert.match(local.browser.Module.locateFile('dora-audio-mixer.wasm'), /^blob:/);
  assert.match(local.browser.Module.doraStorageId, /^html-[a-f0-9]{64}$/);
  local.browser.Module.onRuntimeInitialized();
  assert.equal(local.browser.Module.doraSnapshot, undefined);
  const missing = await bootHtml({'html-assets/0.js': undefined});
  assert.match(missing.faults[0].message, /Extract the entire ZIP/);
  assert.equal(missing.browser.message, missing.faults[0].message);
  assert.ok(!missing.requests.includes('dora-player-runtime.js'));
  const corrupt = await bootHtml({'html-assets/0.js': strToU8('DoraHtmlPackage.deliver("dora-player-runtime.wasm","AAAAAA==");')});
  assert.match(corrupt.faults[0].message, /checksum mismatch/);
  assert.equal(corrupt.browser.message, corrupt.faults[0].message);
  assert.ok(!corrupt.requests.includes('dora-player-runtime.js'));
  const noEngine = await bootHtml({'dora-player-runtime.js': undefined});
  assert.match(noEngine.browser.message, /Unable to load the engine/);
  assert.equal(noEngine.browser.Module.doraSnapshot, undefined);
  assert.equal(noEngine.browser.Module.wasmBinary, undefined);
  assert.equal(noEngine.revoked.length, 1);
  const aborted = await bootHtml();
  aborted.browser.Module.onAbort('test abort');
  assert.equal(aborted.browser.message, 'test abort');
  assert.equal(aborted.browser.Module.doraSnapshot, undefined);
  assert.equal(aborted.browser.Module.getPreloadedPackage, undefined);
  assert.equal(aborted.revoked.length, 1);
  await assert.rejects(createWebArchive(project, runtime, 'html'), /Invalid snapshot\/audio v1 adapter/);
  await assert.rejects(createWebArchive(project, runtime, 'other'), /format/);
  const incompleteFeatures = {...runtime, 'dora-web-features.json': strToU8(JSON.stringify({
    activeProfile: 'dora-preset', modules: {threads: false, model3D: false, jolt3D: false, rustBridge: false},
  }))};
  await assert.rejects(createWebArchive(project, incompleteFeatures), /Unsupported Web runtime profile/);
  await assert.rejects(createWebArchive({'init.ts': strToU8('print("hi")')}, runtime), /entry/);
  await assert.rejects(createWebArchive(project, {...runtime, 'dora-player-runtime.wasm': undefined}), /runtime/);
  await assert.rejects(createWebArchive(project, {...runtime, 'dora-logo.png': undefined}), /runtime/);
  await assert.rejects(createWebArchive({'../init.lua': project['init.lua']}, runtime), /path/);
  assert.throws(() => readProjectZip(zipSync({'init.lua': project['init.lua'], 'huge.bin': new Uint8Array(65 * 1024 * 1024)})), /large/);
  console.log('Web package archive, loader compatibility, filtering, and failure tests passed.');
} finally {
  await rm(directory, {recursive: true, force: true});
}
