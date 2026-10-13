// Run with a native Dora instance and usable external Web IDEs disconnected.
// Exercises the real embedded IDE, rather than a mocked WebSocket compiler.
import assert from 'node:assert/strict';
import {mkdtemp, writeFile, readFile, rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
const base = process.env.DORA_COMPILER_URL ?? 'http://localhost:8866';
const post = async (path, body = {}) => {
 const response = await fetch(base + path, {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(body),signal:AbortSignal.timeout(45000)});
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
assert.equal(initial.typescriptCompiler.webIDEReady,false,'Disconnect usable external IDEs first');
const externalCount = initial.wsConnectionCount;
const root = await mkdtemp(join(tmpdir(),'dora-native-ide-'));
try {
 const file = join(root,'init.ts'); await writeFile(file,'export const value = 42;\n');
 const build = async () => {
  assert.equal((await post('/ts/build',{path:file,projectRoot:root})).success,true);
  assert.match(await readFile(join(root,'init.lua'),'utf8'),/42/);
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
 assert.equal((await post('/ide',{action:'invalid'})).success,false);
 console.log(`Native IDE verification passed (${initial.platform}).`);
} finally {
 await action('stop'); await rm(root,{recursive:true,force:true});
}
