// Runs in the exported page before the unmodified engine boot sequence.
// Classic scripts work on file:// without weakening browser security settings.
export const htmlPlayer = String.raw`async function(config) {
  'use strict';
  const root = new URL('.', document.baseURI);
  const blobs = [];
  const pending = new Map();
  const queue = [];
  const cancelLoads = new Set();
  let failure = null;
  let clearResources = () => {};
  let active = 0, loaded = 0;
  const total = Object.values(config.records).reduce((sum, file) => sum + file.size, 0);
  const checksum = async bytes => Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256', bytes)), byte => byte.toString(16).padStart(2, '0')).join('');
  const fail = error => {
    if (failure) return;
    failure = error;
    for (const job of queue.splice(0)) job.reject(error);
    for (const cancel of Array.from(cancelLoads)) cancel(error);
    clearResources();
    release();
    console.error(error);
    window.doraSetState('faulted', error.message || String(error));
  };
  const release = () => { for (const url of blobs) URL.revokeObjectURL(url); blobs.length = 0; };
  window.addEventListener('pagehide', event => { if (!event.persisted) { clearResources(); release(); } });
  function pump() {
    while (!failure && active < 4 && queue.length) {
      const {name, resolve, reject} = queue.shift();
      const record = config.records[name];
      const script = document.createElement('script');
      active++;
      let delivered = false, finished = false;
      const finish = () => {
        if (finished) return;
        finished = true;
        clearTimeout(timer);
        script.remove();
        pending.delete(name);
        cancelLoads.delete(cancel);
        active--;
        pump();
      };
      const cancel = error => { reject(error); finish(); };
      const timer = setTimeout(() => { reject(new Error('Timed out loading ' + record.script)); finish(); }, 120000);
      cancelLoads.add(cancel);
      pending.set(name, encoded => {
        if (delivered) return;
        delivered = true;
        (async () => {
          const raw = atob(encoded);
          if (raw.length !== record.size) throw new Error('HTML asset size mismatch: ' + name);
          const bytes = new Uint8Array(raw.length);
          for (let index = 0; index < raw.length; index++) bytes[index] = raw.charCodeAt(index);
          if (await checksum(bytes) !== record.sha256) throw new Error('HTML asset checksum mismatch: ' + name);
          if (failure) return;
          loaded += bytes.length;
          window.doraSetProgress(0.5 * loaded / total, 'Loading game resources…');
          resolve(bytes);
        })().catch(reject).finally(finish);
      });
      script.onload = () => { if (!delivered) { reject(new Error('Invalid HTML asset: ' + record.script)); finish(); } };
      script.onerror = () => { reject(new Error('Unable to load ' + record.script + '. Extract the entire ZIP before opening index.html.')); finish(); };
      script.src = new URL(record.script, root).href;
      document.body.appendChild(script);
    }
  }
  function read(name) {
    if (failure) return Promise.reject(failure);
    if (!Object.hasOwn(config.records, name)) return Promise.reject(new Error('Unknown HTML asset: ' + name));
    return new Promise((resolve, reject) => { queue.push({name, resolve, reject}); pump(); });
  }
  window.DoraHtmlPackage = Object.freeze({deliver: (name, encoded) => pending.get(name)?.(encoded)});
  try {
    if (!window.WebAssembly || !window.crypto?.subtle) throw new Error('Please use a modern browser with WebAssembly and Web Crypto support.');
    const names = Object.keys(config.records);
    const values = await Promise.all(names.map(read));
    const files = new Map(names.map((name, index) => [name, values[index]]));
    delete window.DoraHtmlPackage;
    let preload = files.get('dora-player-runtime.data').buffer;
    clearResources = () => {
      preload = null;
      delete Module.doraSnapshot;
      delete Module.wasmBinary;
      delete Module.getPreloadedPackage;
      files.clear();
      values.length = 0;
    };
    Module.wasmBinary = files.get('dora-player-runtime.wasm');
    Module.getPreloadedPackage = () => { const bytes = preload; preload = null; return bytes; };
    Module.doraSnapshot = {manifest: config.manifest, files: config.manifest.files.map(file => ({path: file.path, bytes: files.get(decodeURIComponent(file.url))}))};
    // file:// pages share an opaque origin: isolate saves by package directory.
    Module.doraStorageId = 'html-' + await checksum(new TextEncoder().encode(root.href));
    const audio = new Map();
    for (const [name, type] of [['dora-audio-mixer.wasm', 'application/wasm'], ['audio-worklet.js', 'text/javascript']]) {
      // A worklet module fetched from blob:null is rejected by Chromium on file://.
      // A data URL can be imported by the worklet without an origin or disk fetch.
      if (name === 'audio-worklet.js') {
        let source = '';
        for (const byte of files.get(name)) source += String.fromCharCode(byte);
        audio.set(name, 'data:text/javascript;base64,' + btoa(source));
        continue;
      }
      const url = URL.createObjectURL(new Blob([files.get(name)], {type}));
      audio.set(name, url);
      blobs.push(url);
    }
    Module.locateFile = (name, prefix = '') => audio.get(name) || new URL(name, prefix || root).href;
    const initialized = Module.onRuntimeInitialized;
    Module.onRuntimeInitialized = function() {
      clearResources();
      initialized?.();
    };
    const aborted = Module.onAbort;
    Module.onAbort = function(reason) {
      fail(new Error(String(reason || 'Runtime aborted')));
      aborted?.(reason);
    };
    const script = document.createElement('script');
    script.src = new URL('dora-player-runtime.js', root).href;
    script.onerror = () => fail(new Error('Unable to load the engine. Extract the entire ZIP before opening index.html.'));
    document.body.appendChild(script);
  } catch (error) { fail(error); }
}`;
