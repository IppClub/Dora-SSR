// Run with a native Dora instance and usable external Web IDEs disconnected.
// Exercises the real embedded IDE, rather than a mocked WebSocket compiler.
// Set DORA_REMOTE_FIXTURE=1 for a guest/device; DORA_COMPILER_URL selects its service.
import assert from 'node:assert/strict';
import {mkdtemp, writeFile, readFile, rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join, win32, posix} from 'node:path';
import {randomUUID, createHash, createHmac} from 'node:crypto';
const base = process.env.DORA_COMPILER_URL ?? 'http://localhost:8866';
// Optional approved session file; credentials are never printed or committed.
const auth = process.env.DORA_IDE_AUTH_FILE
 ? JSON.parse(await readFile(process.env.DORA_IDE_AUTH_FILE,'utf8')) : null;
if (auth) { assert.ok(auth.sessionId); assert.ok(auth.sessionSecret); }
const post = async (path, body = {}) => {
 const encoded = JSON.stringify(body);
 const headers = {'Content-Type':'application/json'};
 if (auth) {
  const timestamp = Math.floor(Date.now()/1000).toString(), nonce = randomUUID();
  const hash = createHash('sha256').update(encoded).digest('hex');
  const payload = [auth.sessionId,'POST',path,timestamp,nonce,hash].join('\n');
  Object.assign(headers, {'X-Dora-Session':auth.sessionId,'X-Dora-Timestamp':timestamp,
   'X-Dora-Nonce':nonce,'X-Dora-Signature':createHmac('sha256',auth.sessionSecret).update(payload).digest('hex')});
 }
 const response = await fetch(base + path, {method:'POST',headers,body:encoded,signal:AbortSignal.timeout(45000)});
 assert.equal(response.status,200,path); return response.json();
};
const waitFor = async (predicate, label, seconds = 20) => {
 const deadline = Date.now() + seconds * 1000;
 while (Date.now() < deadline) {
  const status = await post('/status');
  if (predicate(status)) return status;
  await new Promise(resolve => setTimeout(resolve,100));
 }
 throw new Error(`Timed out: ${label}`);
};
const action = async name => assert.equal((await post('/ide',{action:name})).success,true,name);
const initial = await post('/status');
assert.equal(initial.nativeIDE.supported,true);
assert.equal(typeof initial.nativeIDE.enabled,'boolean');
const setEnabled = async enabled => {
 assert.equal((await post('/command',{code:`App.webIDEEnabled = ${enabled}`,log:false})).success,true);
 await waitFor(s=>s.nativeIDE.enabled===enabled && (enabled || s.nativeIDE.state==='stopped'),'runtime IDE configuration');
};
assert.equal(initial.typescriptCompiler.webIDEReady,false,'Disconnect usable external IDEs first');
const externalCount = initial.wsConnectionCount;
// Remote fixtures also allow Android/emulators and Windows guests to use the
// same real compilation verifier without sharing the host's filesystem.
const remote = process.env.DORA_REMOTE_FIXTURE === '1';
const nativeJoin = initial.platform === 'Windows' ? win32.join : posix.join;
const root = remote ? nativeJoin(initial.writablePath,`.native-ide-${randomUUID()}`)
 : await mkdtemp(join(tmpdir(),'dora-native-ide-'));
if (remote) assert.equal((await post('/new',{path:root,content:'',folder:true})).success,true);
const fixtureJoin = remote ? nativeJoin : join;
try {
 await setEnabled(true);
 const file = fixtureJoin(root,'init.ts');
 if (remote) assert.equal((await post('/write',{path:file,content:'export const value = 42;\n'})).success,true);
 else await writeFile(file,'export const value = 42;\n');
 const build = async () => {
  assert.equal((await post('/ts/build',{path:file,projectRoot:root})).success,true);
  const output = fixtureJoin(root,'init.lua');
  if (remote) {
   const result = await post('/read',{path:output}); assert.equal(result.success,true);
   assert.match(result.content,/42/);
  } else assert.match(await readFile(output,'utf8'),/42/);
 };
 await build();
 assert.equal((await post('/status')).typescriptCompiler.embeddedReady,true);
 await action('show');
 await waitFor(s=>s.nativeIDE.state==='visible' && s.typescriptCompiler.webIDEReady && s.wsConnectionCount===externalCount + 1,'real IDE ready');
 await waitFor(s=>!s.typescriptCompiler.embeddedRequested,'embedded compiler recycled on IDE takeover');
 await build();
 assert.equal((await post('/status')).typescriptCompiler.embeddedRequested,false);
 console.log('PASS: real native IDE compilation and background compiler handover');
 await action('hide');
 await waitFor(s=>s.nativeIDE.state==='hidden' && s.wsConnectionCount===externalCount + 1,'hide retains session');
 await build();
 assert.equal((await post('/status')).typescriptCompiler.embeddedRequested,false);
 console.log('PASS: hidden IDE retains compiler session');
 const hiddenGeneration = (await post('/status')).typescriptCompiler.webIDEGeneration;
 await action('toggle'); await waitFor(s=>s.nativeIDE.state==='visible','toggle to IDE');
 await build();
 await action('toggle'); await waitFor(s=>s.nativeIDE.state==='hidden','toggle to engine');
 await build();
 assert.equal((await post('/status')).typescriptCompiler.webIDEGeneration,hiddenGeneration,'toggle retains page and compiler generation');
 console.log('PASS: bidirectional toggle preserves IDE and compiler session');
 await action('show'); await waitFor(s=>s.nativeIDE.state==='visible','reopen');
 const generation = (await post('/status')).typescriptCompiler.webIDEGeneration;
 await action('reload'); await waitFor(s=>s.typescriptCompiler.webIDEGeneration > generation && s.typescriptCompiler.webIDEReady && s.wsConnectionCount===externalCount + 1,'reload reconnects');
 await build();
 assert.equal((await post('/status')).typescriptCompiler.embeddedRequested,false);
 console.log('PASS: reload reconnects and compiles');
 await action('stop'); await waitFor(s=>s.nativeIDE.state==='stopped' && s.wsConnectionCount===externalCount,'stop disconnects');
 await build();
 assert.equal((await post('/status')).typescriptCompiler.embeddedReady,true);
 await waitFor(s=>!s.typescriptCompiler.embeddedRequested,'idle compiler recycled',12);
 console.log('PASS: stop falls back to background compiler and idle recycling');
 assert.equal((await post('/run',{file:fixtureJoin(root,'init.lua'),asProj:true,projectRoot:root})).success,true);
 assert.equal((await post('/stop')).success,true);
 await action('show'); await waitFor(s=>s.nativeIDE.state==='visible','show before disabling');
 await setEnabled(false);
 await waitFor(s=>s.wsConnectionCount===externalCount,'disable disconnects IDE');
 for(const name of ['show','reload','toggle']) assert.equal((await post('/ide',{action:name})).success,false,'disabled '+name);
 await build();
 assert.equal((await post('/status')).typescriptCompiler.embeddedReady,true);
 await waitFor(s=>!s.typescriptCompiler.embeddedRequested,'disabled IDE compiler recycling',12);
 await setEnabled(true); await action('show');
 await waitFor(s=>s.nativeIDE.state==='visible' && s.typescriptCompiler.webIDEReady,'re-enable recreates IDE');
 await build(); await action('stop');
 console.log('PASS: service listeners survive game run/stop; runtime disable releases IDE, blocks opening and retains background compilation; re-enable works');
 assert.equal((await post('/ide',{action:'invalid'})).success,false);
 console.log(`Native IDE verification passed (${initial.platform}).`);
} finally {
 if ((await post('/status')).nativeIDE.enabled) await action('stop');
 await setEnabled(initial.nativeIDE.enabled);
 if (remote) assert.equal((await post('/delete',{path:root})).success,true);
 else await rm(root,{recursive:true,force:true});
}
