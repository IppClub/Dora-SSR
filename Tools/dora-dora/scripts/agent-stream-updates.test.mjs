import assert from 'node:assert/strict';
import test from 'node:test';
import {build} from 'esbuild';
const result = await build({entryPoints:[new URL('../../../Assets/Script/Lib/Agent/Runtime/StreamUpdates.ts',import.meta.url).pathname],bundle:true,write:false,format:'esm',platform:'node'});
const {StreamUpdates}=await import('data:text/javascript;base64,'+Buffer.from(result.outputFiles[0].text).toString('base64'));
function fixture(){const calls=[];return {calls,updates:new StreamUpdates((...args)=>calls.push(args))};}
test('first snapshot is immediate and a slow second delta flushes within 100ms',()=>{
 const {calls,updates:u}=fixture();u.update(1,10,1,{content:'a'},0);assert.equal(calls.length,1);
 u.update(1,10,1,{content:'ab'},.01);assert.equal(calls.length,1);assert(u.hasPending());
 u.flushDue(.099);assert.equal(calls.length,1);u.flushDue(.101);assert.equal(calls[1][3].content,'ab');assert(!u.hasPending());
});
test('count and combined reasoning/text growth flush without waiting for a timer',()=>{
 const {calls,updates:u}=fixture();u.update(1,10,1,{content:''},0);
 for(let i=1;i<32;i++)u.update(1,10,1,{content:'x'.repeat(i)},.001);assert.equal(calls.length,1);
 u.update(1,10,1,{content:'x'.repeat(32)},.001);assert.equal(calls.length,2);
 u.update(1,10,1,{content:'x'.repeat(32),reasoningContent:'r'.repeat(4096)},.001);assert.equal(calls.length,3);
});
test('success discards pending data in favor of authoritative final event',()=>{
 const {calls,updates:u}=fixture();u.update(1,10,1,{content:'a'},0);u.update(1,10,1,{content:'ab'},.01);
 u.finish(1,10,1);u.flushDue(1);assert.equal(calls.length,1);assert(!u.hasPending());
 u.update(1,10,1,{content:'new'},2);assert.equal(calls.length,2);
});
test('stop/failure/wait boundaries flush latest text once and release task state',()=>{
 const {calls,updates:u}=fixture();u.update(1,10,1,{content:'a'},0);u.update(1,10,1,{content:'ab'},.01);
 u.update(1,11,1,{content:'other'},0);u.update(1,11,1,{content:'other+'},.01);
 u.clear(1,10,.02);assert.equal(calls.at(-1)[3].content,'ab');assert(u.hasPending());
 u.flushDue(1);assert.equal(calls.at(-1)[3].content,'other+');assert.equal(calls.filter(c=>c[1]===10).length,2);
 u.clear(1,10,2);assert.equal(calls.length,4);
});
test('deletion/new task discards dirty snapshots and stale scheduled ticks cannot resurrect them',()=>{
 const {calls,updates:u}=fixture();u.update(1,10,1,{content:'a'},0);u.update(1,10,1,{content:'ab'},.01);
 u.clear(1);u.flushDue(10);assert.equal(calls.length,1);assert(!u.hasPending());
});
test('sessions and steps remain isolated, including replacement/shrinking snapshots',()=>{
 const {calls,updates:u}=fixture();u.update(1,10,1,{content:'long text'},0);u.update(1,10,1,{content:'x'},.01);
 u.update(2,10,1,{content:'other session'},0);u.update(1,10,2,{content:'other step'},0);
 u.flushDue(.11);assert.equal(calls.at(-1)[3].content,'x');assert.equal(calls.length,4);
});

test('a lifecycle callback can clear other entries during a scheduled flush',()=>{
 let clear=false;const u=new StreamUpdates(()=>{if(clear)u.clear(1);});
 u.update(1,10,1,{content:'a'},0);u.update(1,10,2,{content:'b'},0);
 u.update(1,10,1,{content:'aa'},.01);u.update(1,10,2,{content:'bb'},.01);
 clear=true;u.flushDue(.11);assert(!u.hasPending());
});

test('content-only and reasoning-only updates preserve each other before a flush',()=>{
 const {calls,updates:u}=fixture();u.update(1,10,1,{content:''},0);
 u.update(1,10,1,{content:'',reasoningContent:'reasoning'},.01);
 u.update(1,10,1,{content:'answer'},.02);u.flushDue(.11);
 assert.deepEqual(calls.at(-1)[3],{content:'answer',reasoningContent:'reasoning'});
});
