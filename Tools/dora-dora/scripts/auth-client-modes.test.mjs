import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createHmac,createHash,webcrypto} from 'node:crypto';
import vm from 'node:vm';
import {build} from 'esbuild';
import ts from 'typescript';

const source=await readFile(new URL('../src/Service.ts',import.meta.url),'utf8');
const ast=ts.createSourceFile('Service.ts',source,ts.ScriptTarget.Latest,true);
const names=new Set(['getSync','parseSession','addr']);
const declarations=ast.statements.filter(s=>(ts.isFunctionDeclaration(s)&&names.has(s.name?.getText(ast)))||(ts.isVariableStatement(s)&&s.declarationList.declarations.some(d=>names.has(d.name.getText(ast)))));
assert.equal(declarations.length,3);
const {outputFiles}=await build({stdin:{contents:`import {createAuthHeaders,canonicalizeAuthPath} from './src/AuthSignature';\nlet authRequired=true;\n${declarations.map(s=>s.getText(ast)).join('\n')}\nexport {getSync,createAuthHeaders};export const setRequired=value=>authRequired=value;`,loader:'ts',resolveDir:new URL('../',import.meta.url).pathname},bundle:true,write:false,format:'cjs'});
const session={sessionId:'lan-session',sessionSecret:'lan-secret'};
function fixture() {
 const requests=[];const module={exports:{}};
 class XHR {
  headers={};status=200;responseText='{"success":true}';
  open(method,url,async){Object.assign(this,{method,url,async});}
  setRequestHeader(name,value){this.headers[name]=value;}
  send(){requests.push(this);}
 }
 vm.runInNewContext(outputFiles[0].text,{module,exports:module.exports,URL,URLSearchParams,Uint8Array,TextEncoder,console,XMLHttpRequest:XHR,
  crypto:{getRandomValues:array=>webcrypto.getRandomValues(array)},
  window:{location:{href:'http://192.168.1.10:3000/'}},process:{env:{NODE_ENV:'development'}},
  localStorage:{getItem:()=>JSON.stringify(session)}});
 return {client:module.exports,requests};
}
function verify(headers,method,path,body='') {
 const payload=[session.sessionId,method,path,headers['X-Dora-Timestamp'],headers['X-Dora-Nonce'],body?createHash('sha256').update(body).digest('hex'):''].join('\n');
 assert.equal(headers['X-Dora-Signature'],createHmac('sha256',session.sessionSecret).update(payload).digest('hex'));
 assert.match(headers['X-Dora-Nonce'],/^[a-f0-9]{32}$/);
}
test('HTTP LAN without crypto.subtle signs synchronous compiler reads for the rewritten target',()=>{
 const {client,requests}=fixture();
 assert.equal(client.getSync('/read-sync',new URLSearchParams({path:'a b.ts',projectRoot:'project'})).success,true);
 const request=requests[0];assert.equal(request.async,false);assert.match(request.url,/^\/__dora\/api\/read-sync\?/);
 verify(request.headers,'GET','/read-sync?path=a%20b.ts&projectRoot=project');
 client.getSync('/read-sync',new URLSearchParams({path:'a b.ts',projectRoot:'project'}));
 assert.notEqual(requests[0].headers['X-Dora-Nonce'],requests[1].headers['X-Dora-Nonce']);
});
test('HTTP LAN signs JSON POST and empty GET bodies with the same HMAC contract',()=>{
 const {client}=fixture();
 verify(client.createAuthHeaders(session,'POST',new URL('http://192.168.1.10:3000/__dora/api/read?z=2&a=1'),new TextEncoder().encode('{}'),true),'POST','/read?a=1&z=2','{}');
 verify(client.createAuthHeaders(session,'GET',new URL('http://127.0.0.1:8866/log.txt'),new Uint8Array(),false),'GET','/log.txt');
});
test('local synchronous compiler reads remain unsigned',()=>{
 const {client,requests}=fixture();client.setRequired(false);
 client.getSync('/read-sync',new URLSearchParams({path:'test.ts'}));
 assert.deepEqual(requests[0].headers,{});
});
