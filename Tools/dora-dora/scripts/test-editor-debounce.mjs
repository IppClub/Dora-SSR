import assert from 'node:assert/strict';
import {test} from 'node:test';
import {fileURLToPath} from 'node:url';
import {loadAgentTsModule} from './load-agent-ts-module.mjs';
const {EditorDebounce} = await loadAgentTsModule(fileURLToPath(new URL('../src/EditorDebounce.ts',import.meta.url)));

test('a typing burst checks only its latest snapshot and preserves the save barrier', t => {
 t.mock.timers.enable({apis:['setTimeout']});
 const states=[], checked=[];
 const queue=new EditorDebounce(value=>states.push(value));
 for(let version=0;version<1000;version++) queue.schedule('a.ts',()=>checked.push(version));
 t.mock.timers.tick(499); assert.deepEqual(checked,[]); assert.deepEqual(states,[true]);
 t.mock.timers.tick(1); assert.deepEqual(checked,[999]); assert.deepEqual(states,[true,false]);
});
test('quick tab switching retains independent checks and waits for the last file', t => {
 t.mock.timers.enable({apis:['setTimeout']});
 const states=[], checked=[];const queue=new EditorDebounce(value=>states.push(value));
 queue.schedule('a.ts',()=>checked.push('a'));t.mock.timers.tick(250);
 queue.schedule('b.lua',()=>checked.push('b'));t.mock.timers.tick(250);
 assert.deepEqual(checked,['a']);assert.deepEqual(states,[true]);
 t.mock.timers.tick(250);assert.deepEqual(checked,['a','b']);assert.deepEqual(states,[true,false]);
});
test('unmount cancels pending work', t => {
 t.mock.timers.enable({apis:['setTimeout']});
 let checks=0;const queue=new EditorDebounce(()=>{});
 queue.schedule('a.ts',()=>checks++);queue.dispose();t.mock.timers.tick(1000);assert.equal(checks,0);
});
test('a synchronous validation failure releases the save barrier', t => {
 t.mock.timers.enable({apis:['setTimeout']});
 const states=[];const queue=new EditorDebounce(value=>states.push(value));
 queue.schedule('a.ts',()=>{throw new Error('invalid');});
 assert.throws(()=>t.mock.timers.tick(500),/invalid/);assert.deepEqual(states,[true,false]);
});
