import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtemp, mkdir, writeFile, readFile, rm, access, symlink} from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import {gzipSync} from 'node:zlib';
import {precompressAssets, verifyPrecompressedAssets, readAsset, manifestName} from './precompress-assets.mjs';

async function fixture(run) {
 const root=await mkdtemp(path.join(os.tmpdir(),'dora-precompressed-'));
 try {await run(root);} finally {await rm(root,{recursive:true,force:true});}
}
const raw=Buffer.from('console.log("pack once, serve gzip directly");\n'.repeat(200));
test('distribution stores one representation, including nested WASM/data; original logical paths decode',()=>fixture(async root=>{
 await mkdir(path.join(root,'web-player'));
 for(const name of ['index.html','app.js','web-player/runtime.wasm','web-player/runtime.data']) await writeFile(path.join(root,name),raw);
 await writeFile(path.join(root,'small.json'),'{}');
 await writeFile(path.join(root,'icon.png'),Buffer.from([1,2,3]));
 const result=await precompressAssets(root);assert.equal(result.files,4);assert.ok(result.gzipBytes<result.originalBytes);
 for(const name of ['index.html','app.js','web-player/runtime.wasm','web-player/runtime.data']){
  await assert.rejects(access(path.join(root,name)));assert.deepEqual(await readAsset(root,name),raw);
 }
 assert.equal((await readAsset(root,'small.json')).toString(),'{}');assert.equal(await verifyPrecompressedAssets(root),4);
 const first=await readFile(path.join(root,'app.js.gz')), manifest=await readFile(path.join(root,manifestName));
 await precompressAssets(root);assert.deepEqual(await readFile(path.join(root,'app.js.gz')),first);assert.deepEqual(await readFile(path.join(root,manifestName)),manifest);
}));
test('edited input replaces old gzip and retains no stale original',()=>fixture(async root=>{
 await writeFile(path.join(root,'app.js'),raw);await precompressAssets(root);
 const edited=Buffer.from('z'.repeat(raw.length));await writeFile(path.join(root,'app.js'),edited);await precompressAssets(root);
 assert.deepEqual(await readAsset(root,'app.js'),edited);assert.equal(await verifyPrecompressedAssets(root),1);
}));
test('verifier rejects corrupted, missing and duplicate representations',()=>fixture(async root=>{
 await writeFile(path.join(root,'app.js'),raw);await precompressAssets(root);
 const packed=await readFile(path.join(root,'app.js.gz'));
 await writeFile(path.join(root,'app.js.gz'),gzipSync('wrong content'));await assert.rejects(verifyPrecompressedAssets(root),/Invalid gzip/);
 await writeFile(path.join(root,'app.js.gz'),packed);await writeFile(path.join(root,'app.js'),raw);await assert.rejects(verifyPrecompressedAssets(root),/Duplicate/);
 await rm(path.join(root,'app.js'));await rm(path.join(root,'app.js.gz'));await assert.rejects(verifyPrecompressedAssets(root),/Missing gzip/);
}));
test('manifest paths and orphan compressed files are rejected',()=>fixture(async root=>{
 await precompressAssets(root);await writeFile(path.join(root,'orphan.js.gz'),gzipSync(raw));await assert.rejects(verifyPrecompressedAssets(root),/Unlisted/);
 await writeFile(path.join(root,manifestName),JSON.stringify({version:1,files:{'../outside.js':{}}}));await assert.rejects(verifyPrecompressedAssets(root),/Invalid gzip asset path/);
 await assert.rejects(readAsset(root,'../outside.js'),/Invalid asset path/);
}));
test('output symlinks are not followed',()=>fixture(async root=>{
 await writeFile(path.join(root,'source.js'),raw);await symlink(path.join(root,'source.js'),path.join(root,'linked.js'));
 await precompressAssets(root);const m=JSON.parse(await readFile(path.join(root,manifestName)));assert.deepEqual(Object.keys(m.files),['source.js']);
}));
