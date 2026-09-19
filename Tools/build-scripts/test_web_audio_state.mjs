// Host protocol regression: intentionally reordered snapshots and repeated ends.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
const workerModule = {};
vm.runInNewContext(fs.readFileSync('Projects/Web/web-audio.js','utf8'), {Module:workerModule});
assert.equal(workerModule.doraAudio,undefined,'pthread workers must not create an AudioContext');
let node, finishBoot;
const boot = new Promise(resolve => { finishBoot = resolve; });
const sent = [], ended = [];
const module = {preRun: [], ccall: (name, type, types, args) => {
	assert.equal(name, 'dora_worklet_ended'); ended.push(args[0]);
}};
class Context {
	state = 'suspended';
	audioWorklet = {addModule: async () => {}};
	resume() { this.state = 'running'; return Promise.resolve(); }
	close() { this.state = 'closed'; return Promise.resolve(); }
}
class WorkletNode {
	constructor() { node = this; }
	port = {postMessage: data => sent.push(data), close() {}};
	connect() { queueMicrotask(() => this.port.onmessage({data:{type:'ready',sampleRate:48000}})); }
	disconnect() {}
}
vm.runInNewContext(fs.readFileSync('Projects/Web/web-audio.js','utf8'), {
	Module:module, URL, document:{currentScript:{src:'http://localhost/player.js'}}, isSecureContext:true,
	AudioContext:Context, AudioWorkletNode:WorkletNode,
	fetch:async()=>({ok:true,arrayBuffer:async()=>new ArrayBuffer(0)}), WebAssembly:{compile:async()=>({})},
	setTimeout, clearTimeout, addRunDependency(){}, removeRunDependency:finishBoot,
	addEventListener(){},removeEventListener(){},console:{warn(){},error(){}},
});
module.preRun[0](); await boot;
const audio=module.doraAudio;
const reply=data=>node.port.onmessage({data});
const config=Array(31).fill(0);
audio.bus(10,0,0,0,0,0);
assert.equal(sent.at(-1).type,'bus');assert.equal(sent.at(-1).id,10);
const id=audio.play('test.wav',new Uint8Array([1]),false,0,false,config,10,true);
assert.equal(sent.at(-1).bus,10);assert.equal(sent.at(-1).isStatic,true);
const playRevision=sent.at(-1).revision;
assert.ok(id); assert.equal(audio.get(id,0),1);
reply({type:'accepted',id});
reply({type:'voices',revision:playRevision-1,values:[]});
assert.equal(audio.get(id,0),1,'stale snapshot cannot end a pending voice');
audio.control(id,1,1);
const pauseRevision=sent.at(-1).revision;
reply({type:'voices',revision:playRevision,values:[id,0,0.1]});
assert.equal(audio.get(id,1),1,'stale snapshot cannot undo pause');
reply({type:'voices',revision:pauseRevision,values:[id,1,0.2]});
assert.equal(audio.get(id,2),0.2);
audio.control(id,0,0.5);
reply({type:'voices',revision:pauseRevision,values:[id,1,0.2]});
assert.equal(audio.get(id,2),0.5,'stale snapshot cannot undo seek');
audio.stop(id,0); assert.equal(audio.get(id,0),0);
reply({type:'voices',revision:pauseRevision,values:[]});assert.equal(ended.length,0);
reply({type:'voices',revision:sent.at(-1).revision,values:[]});
reply({type:'voices',revision:sent.at(-1).revision,values:[]});
assert.deepEqual(ended,[id],'AudioEnd must occur exactly once');
const second=audio.play('test.wav',null,false,0,false,config);
reply({type:'error',command:'play',id:second,message:'decoder failure'});
assert.deepEqual(ended,[id,second]);assert.equal(audio.get(second,0),0);
const third=audio.play('test.wav',null,false,0,false,config);
node.onprocessorerror();
assert.equal(audio.ready,false);assert.equal(audio.context.state,'closed');
assert.deepEqual(ended,[id,second,third],'processor failure must release pending sources');
console.log('Audio host protocol: stale snapshots, pause/seek ordering, exactly-once AudioEnd and failure cleanup passed.');
