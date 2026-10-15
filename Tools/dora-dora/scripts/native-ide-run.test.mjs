import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {readFile} from 'node:fs/promises';
import ts from 'typescript';
const source=await readFile(new URL('../src/NativeIDERun.ts',import.meta.url),'utf8');
const code=ts.transpileModule(source,{compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2022}}).outputText;
function fixture(kind) {
 const messages=[];
 const bridge={postMessage:message=>messages.push(message)};
 const window={};window.top=window;
 if(kind==='macOS')window.webkit={messageHandlers:{doraIDERun:bridge}};
 if(kind==='Windows')window.chrome={webview:bridge};
 if(kind==='Android')window.DoraIDERun=bridge;
 const exports={};vm.runInNewContext(code,{window,exports,crypto:{},Date,Math});
 return {run:exports.runWithNativeIDE,messages,window};
}
for(const kind of ['macOS','Windows','Android']) {
 test(`${kind}: start precedes run; only clean success requests a switch`,async()=>{
  const f=fixture(kind), response={success:true};
  assert.equal(await f.run(async()=>{assert.match(f.messages[0],/^dora-ide-run:start:/);return response;}),response);
  assert.equal(f.messages[1],f.messages[0].replace(':start:',':success:'));
  for(const result of [{success:false},{success:true,err:'startup error'}]) {
   f.messages.length=0;assert.equal(await f.run(async()=>result),result);
   assert.equal(f.messages[1],f.messages[0].replace(':start:',':cancel:'));
  }
 });
}
test('remote browser and iframe never request a native switch',async()=>{
 for(const f of [fixture(),fixture('Windows')]) {
  if(f.window.chrome)f.window.top={};
  const response={success:true};assert.equal(await f.run(async()=>response),response);
  assert.deepEqual(f.messages,[]);
 }
});
test('failed transport is preserved and cancels pending switch',async()=>{
 const f=fixture('macOS'), error=new Error('offline');
 await assert.rejects(f.run(async()=>{throw error;}),e=>e===error);
 assert.equal(f.messages[1],f.messages[0].replace(':start:',':cancel:'));
});
test('out-of-order requests retain their own identities',async()=>{
 const f=fixture('Android');let finish;
 const first=f.run(()=>new Promise(resolve=>{finish=resolve;}));
 await f.run(async()=>({success:true}));finish({success:true});await first;
 assert.notEqual(f.messages[0],f.messages[1]);
 assert.equal(f.messages[2],f.messages[1].replace(':start:',':success:'));
 assert.equal(f.messages[3],f.messages[0].replace(':start:',':success:'));
});
