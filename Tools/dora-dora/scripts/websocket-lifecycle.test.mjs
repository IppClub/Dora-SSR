import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {EventEmitter} from 'node:events';
import {readFile} from 'node:fs/promises';
import ts from 'typescript';
const source = await readFile(new URL('../src/Service.ts', import.meta.url), 'utf8');
const code = ts.transpileModule(source, {compilerOptions: {module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022}}).outputText;
const flush = async () => { for (let i = 0; i < 10; i++) await Promise.resolve(); };
function fixture(warmup = async () => {}) {
 const sockets = [], timers = new Map(), listeners = new Map(); let timer = 0;
 class Socket {
  constructor(url) { this.url = url; this.closed = false; sockets.push(this); }
  close() { this.closed = true; this.onclose?.(); }
 }
 const exports = {};
 const window = {location: {hostname: 'localhost', href: 'http://localhost:8866/', search: ''},
  addEventListener(name, handler) { listeners.set(name, handler); }};
 const require = name => {
  if (name === './utils/typedEmitter') return {TypedEmitter: EventEmitter};
  if (name === './LogBuffer') return {LogBuffer: class {}};
  if (name === './NativeIDERun') return {runWithNativeIDE: run => run()};
  if (name === './AuthSignature') return {};
  if (name === './TranspileTS') return {warmupTypescriptTranspiler: warmup};
  throw new Error(`Unexpected import ${name}`);
 };
 vm.runInNewContext(code, {exports, require, window, URL, URLSearchParams, process: {env: {NODE_ENV: "production"}}, WebSocket: Socket, console,
  setTimeout(callback) { timers.set(++timer, callback); return timer; }, clearTimeout(id) { timers.delete(id); }});
 return {service: exports, window, sockets, timers, dispatch: (name, event = {}) => listeners.get(name)?.(event)};
}
test('native Close disconnects and cancels pending reconnect', async () => {
 const f = fixture(); f.service.openWebSocket(); await flush();
 const first = f.sockets[0]; first.onclose(); assert.equal(f.timers.size, 1);
 f.dispatch('dora-ide-close'); assert.equal(first.closed, true); assert.equal(f.timers.size, 0);
 assert.equal(first.onclose, null);
});
test('Close during transpiler warmup cannot create a late connection', async () => {
 let finish; const f = fixture(() => new Promise(resolve => { finish = resolve; }));
 f.service.openWebSocket(); await flush(); f.dispatch('dora-ide-close'); finish(); await flush();
 assert.equal(f.sockets.length, 0); assert.equal(f.timers.size, 0);
});
test('reopening owns one connection and stale retries cannot reconnect', async () => {
 const f = fixture(); f.service.openWebSocket(); await flush();
 f.sockets[0].onclose(); const staleRetry = [...f.timers.values()][0];
 f.service.openWebSocket(); await flush(); staleRetry(); await flush();
 assert.equal(f.sockets.length, 2); assert.equal(f.sockets[0].closed, true);
 assert.equal(f.sockets[1].closed, false); assert.equal(f.timers.size, 0);
});
test('page cache entry closes its socket and restores exactly once on pageshow', async () => {
 const f = fixture(); f.service.openWebSocket(); await flush(); f.dispatch('pagehide');
 assert.equal(f.sockets[0].closed, true); f.dispatch('pageshow', {persisted: false}); await flush();
 assert.equal(f.sockets.length, 1); f.dispatch('pageshow', {persisted: true}); await flush();
 assert.equal(f.sockets.length, 2); assert.equal(f.sockets[1].closed, false);
});

test('native Close before Service starts prevents late module initialization from connecting', async () => {
 const f = fixture(); f.window.__doraIDEClosed = true; f.service.openWebSocket(); await flush();
 assert.equal(f.sockets.length, 0); assert.equal(f.timers.size, 0);
});
