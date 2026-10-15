import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import vm from 'node:vm';
import {webcrypto} from 'node:crypto';
import {build} from 'esbuild';
import ts from 'typescript';
// Exercise the production bootstrap, fetch wrapper and modal lifecycle together.
// Only rendering is stubbed; decisions, signatures and timers use upstream code.
const source=await readFile(new URL('../src/index.tsx',import.meta.url),'utf8');
const ast=ts.createSourceFile('index.tsx',source,ts.ScriptTarget.Latest,true,ts.ScriptKind.TSX);
const names=new Set(['origFetch','checkAuthRequired','showAuthDialog','setupAuth']);
const declarations=ast.statements.filter(s=>ts.isVariableStatement(s)&&s.declarationList.declarations.some(d=>names.has(d.name.getText(ast))));
assert.equal(declarations.length,names.size,'Authentication bootstrap boundary changed');
const {outputFiles}=await build({stdin:{contents:`import {canonicalizeAuthPath} from './src/AuthSignature';\n${declarations.map(s=>s.getText(ast)).join('\n')}\nwindow.setupAuth=setupAuth;`,loader:'tsx',resolveDir:new URL('../',import.meta.url).pathname},bundle:true,write:false,format:'iife',jsxFactory:'React.createElement'});
const newSession={sessionId:'new-session',sessionSecret:'new-secret'};
function fixture({enabled=true,cached=true}={}) {
 const state={enabled,probeStatus:null,offline:false,dialog:null,shown:0,required:null,requests:[]};
 const storage=new Map(cached?[['doraWebAuthSession',JSON.stringify({sessionId:'old-session',sessionSecret:'old-secret'})]]:[]);
 const timers=new Set();
 class Socket {listeners=new Map();addEventListener(name,listener){this.listeners.set(name,listener);}close(){this.listeners.get('close')?.();}}
 const window={location:{href:'http://localhost:8866/'},WebSocket:Socket,fetch:async(input,init)=>{
  const request=input instanceof Request?input:new Request(input,init);
  if(new URL(request.url).pathname==='/info') {
   if(state.offline)throw new TypeError('Engine restarting');
   assert.equal(request.headers.has('X-Dora-Session'),false,'Probe must be unsigned');
   return new Response('{}',{status:state.probeStatus??(state.enabled?401:200)});
  }
  state.requests.push(request);
  return new Response('{}',{status:!state.enabled||request.headers.get('X-Dora-Session')===newSession.sessionId?200:401});
 }};
 vm.runInNewContext(outputFiles[0].text,{window,URL,Request,Headers,TextEncoder,Uint8Array,crypto:webcrypto,console,
  localStorage:{getItem:key=>storage.get(key)??null,setItem:(key,value)=>storage.set(key,value),removeItem:key=>storage.delete(key)},
  Service:{addr:path=>'http://localhost:8866'+path,setAuthRequired:value=>{state.required=value;},getWebSocket:()=>null},
  document:{body:{appendChild(){}},createElement:()=>({remove(){}})},AuthDialog:()=>{},React:{createElement:(type,props)=>({type,props})},
  ReactDOM:{createRoot:()=>({render:element=>{state.dialog=element.props;state.shown++;},unmount:()=>{state.dialog=null;}})},
  setTimeout:(fn,ms)=>{const id=setTimeout(()=>{timers.delete(id);fn();},ms===1000?10:ms);timers.add(id);return id;},
  clearTimeout:id=>{timers.delete(id);clearTimeout(id);},
 });
 return {state,window,storage,dispose:()=>{for(const id of timers)clearTimeout(id);}};
}
async function until(predicate) {
 for(let i=0;i<200;i++){if(predicate())return;await new Promise(r=>setTimeout(r,5));}
 assert.fail('Authentication transition did not settle');
}
test('disabled auth discards persisted credentials without opening PIN',async()=>{
 const f=fixture({enabled:false});try{
  await f.window.setupAuth();assert.equal((await f.window.fetch('http://localhost:8866/test')).status,200);
  assert.equal(f.state.shown,0);assert.equal(f.storage.size,0);assert.equal(f.state.requests[0].headers.has('X-Dora-Session'),false);
 }finally{f.dispose();}
});
test('open PIN closes after restart disables auth; offline and 500 do not dismiss it',async()=>{
 const f=fixture();try{
  await f.window.setupAuth();new f.window.WebSocket('ws://localhost:8868').close();await until(()=>f.state.dialog);
  f.state.offline=true;await new Promise(r=>setTimeout(r,30));assert.ok(f.state.dialog);assert.equal(f.state.required,true);
  f.state.offline=false;f.state.probeStatus=500;await new Promise(r=>setTimeout(r,30));assert.ok(f.state.dialog);
  f.state.probeStatus=null;f.state.enabled=false;await until(()=>!f.state.dialog&&f.state.required===false);
  assert.equal(f.state.shown,1);assert.equal(f.storage.size,0);
  assert.equal((await f.window.fetch('http://localhost:8866/test')).status,200);assert.equal(f.state.requests.at(-1).headers.has('X-Dora-Session'),false);
  new f.window.WebSocket('ws://localhost:8868').close();await new Promise(r=>setTimeout(r,30));assert.equal(f.state.shown,1);
 }finally{f.dispose();}
});
test('expired session prompts once and concurrent requests retry after authentication',async()=>{
 const f=fixture();try{
  await f.window.setupAuth();const pending=Promise.all([f.window.fetch('http://localhost:8866/test'),f.window.fetch('http://localhost:8866/test')]);
  await until(()=>f.state.dialog);assert.equal(f.state.shown,1);f.state.dialog.onToken(newSession);
  assert.deepEqual((await pending).map(r=>r.status),[200,200]);assert.equal(f.state.required,true);assert.equal(f.state.dialog,null);
 }finally{f.dispose();}
});
test('initial PIN gate resumes bootstrap when authentication is disabled',async()=>{
 const f=fixture({cached:false});try{
  const pending=f.window.setupAuth();await until(()=>f.state.dialog);f.state.enabled=false;await pending;
  assert.equal(f.state.dialog,null);assert.equal(f.state.required,false);
 }finally{f.dispose();}
});
test('socket loss while engine is offline does not open a speculative PIN',async()=>{
 const f=fixture();try{
  await f.window.setupAuth();f.state.offline=true;
  new f.window.WebSocket('ws://localhost:8868').close();
  await new Promise(r=>setTimeout(r,30));assert.equal(f.state.shown,0);assert.equal(f.state.required,true);
  f.state.offline=false;f.state.enabled=false;
  new f.window.WebSocket('ws://localhost:8868').close();
  await until(()=>f.state.required===false);assert.equal(f.state.shown,0);
 }finally{f.dispose();}
});
