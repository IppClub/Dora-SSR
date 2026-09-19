// Pure WASM/DSP regression test: suitable for CI, no browser or graphics needed.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import path from 'node:path';

const build = path.resolve(process.argv[2] || 'build/web');
const wasm = new WebAssembly.Module(fs.readFileSync(path.join(build, 'dora-audio-mixer.wasm')));
assert.ok(!WebAssembly.Module.imports(wasm).some(x => x.kind === 'memory'), 'mixer must own its memory');
const messages = [];
let Processor;
vm.runInNewContext(fs.readFileSync('Projects/Web/audio-worklet.js', 'utf8'), {
	WebAssembly, Uint8Array, Uint32Array, Float32Array, Math, Number, Error,
	sampleRate: Number(process.env.DORA_AUDIO_TEST_RATE || 48000),
	AudioWorkletProcessor: class { port = {postMessage: data => messages.push(data)}; },
	registerProcessor: (_, type) => { Processor = type; },
});
const p = new Processor({processorOptions: {wasm}});
assert.equal(messages[0].type, 'ready');
assert.ok(!(p.api.memory.buffer instanceof SharedArrayBuffer));

export function sineWav(rate = 48000) {
	const frames = rate / 10;
	const data = Buffer.alloc(44 + frames * 2);
	data.write('RIFF'); data.writeUInt32LE(data.length - 8, 4); data.write('WAVEfmt ', 8);
	data.writeUInt32LE(16, 16); data.writeUInt16LE(1, 20); data.writeUInt16LE(1, 22);
	data.writeUInt32LE(rate, 24); data.writeUInt32LE(rate * 2, 28);
	data.writeUInt16LE(2, 32); data.writeUInt16LE(16, 34); data.write('data', 36);
	data.writeUInt32LE(frames * 2, 40);
	for (let i = 0; i < frames; ++i) data.writeInt16LE(Math.round(8000 * Math.sin(2 * Math.PI * 440 * i / rate)), 44 + i * 2);
	return data;
}
const command = data => p.port.onmessage({data});
const render = (blocks, frames = 128) => {
	let energy = 0, nonzero = 0;
	for (let block = 0; block < blocks; ++block) {
		const channels = [new Float32Array(frames), new Float32Array(frames)];
		assert.equal(p.process([], [channels]), true);
		for (const value of channels[0]) {
			assert.ok(Number.isFinite(value));
			energy += value * value;
			if (Math.abs(value) > 0.001) ++nonzero;
		}
	}
	return {energy, nonzero};
};
command({type: 'play', id: 4096, asset: 1, bytes: sineWav(), loop: true, fade: 0});
assert.ok(render(500).energy > 100);
assert.equal(p.api.audio_voice_count(), 1, 'short sound should loop');
command({type: 'pause', value: true});
render(2);
assert.equal(render(50).energy, 0);
command({type: 'pause', value: false});
assert.ok(render(50, 256).energy > 10, 'non-default render quantum');
command({type: 'volume', value: 0}); render(2);
assert.equal(render(50).energy, 0);
command({type: 'volume', value: 1});
command({type: 'stop', id: 4096, fade: 0.05});
render(40);
assert.equal(p.api.audio_voice_count(), 0);
assert.equal(render(30).energy, 0);
command({type: 'play', id: 8192, asset: 1, bytes: sineWav(), loop: false, fade: 0.02});
assert.ok(render(20).energy > 1);
render(100);
assert.equal(p.api.audio_voice_count(), 0, 'one-shot must finish');
for (const file of process.argv.slice(3)) {
	command({type: 'play', id: 12288, asset: 2, bytes: fs.readFileSync(file), loop: true, fade: 0});
	assert.ok(render(1000).energy > 0, `decode ${file}`);
	command({type: 'stopAll', fade: 0});
}
command({type: 'stopAll', fade: 0});
assert.equal(p.api.audio_asset_bytes(), 0);
command({type: 'play', id: 16384, asset: 3, bytes: new Uint8Array([1, 2, 3]), loop: false, fade: 0});
assert.ok(messages.some(x => x.type === 'error'), 'invalid input must report an error');

// File-backed AudioSource 3D state and lifecycle (same protocol as AudioSource.cpp).
const listener = [0,0,0, 0,0,1, 0,1,0, 0,0,0, 343,1,2];
const source = [2,-1,1,0,1,1,0,0, 10,0,0, 0,0,0, 0,0,0,
	2*Math.PI,2*Math.PI,0,1,0, 1,1000,1,1,1,0,0,0,1];
command({type:'listener', config:listener});
command({type:'play', id:20480, asset:4, bytes:sineWav(), loop:true, fade:0, config:source});
const sample = () => {
	render(30); // settle resampling and channel-gain interpolation
	let left=0, right=0, crossings=0, previous=0;
	for(let i=0;i<150;i++) {
		const out=[new Float32Array(128),new Float32Array(128)]; p.process([], [out]);
		for(let j=0;j<128;j++) {
			left+=out[0][j]**2;right+=out[1][j]**2;
			const value=out[0][j]+out[1][j]; if(value>0 && previous<=0) crossings++; previous=value;
		}
	}
	return {left,right,crossings};
};
const change = (index, value) => { source[index]=value; command({type:'config',id:20480,config:source}); };
const right=sample(); change(8,-10); const left=sample();
assert.ok((right.left-right.right)*(left.left-left.right)<0, 'moving source must reverse stereo balance');
assert.ok(Math.max(right.left,right.right)>2*Math.min(right.left,right.right));
listener[5]=-1;command({type:'listener',config:listener});const rotated=sample();
assert.ok((left.left-left.right)*(rotated.left-rotated.right)<0, 'listener rotation must reverse stereo balance');
listener[5]=1;command({type:'listener',config:listener});
source[8]=0;change(10,1);const near=sample();change(10,10);const far=sample();
assert.ok(near.left>far.left*30, 'distance attenuation must reduce volume');
change(13,-100);const negativeVelocity=sample();change(13,0);const stationary=sample();
// Preserve this repository's SoLoud velocity/sign convention, not a new Web approximation.
assert.ok(Math.abs(negativeVelocity.crossings/stationary.crossings - 343/443)<0.03, 'Doppler must match native SoLoud');
source[17]=Math.PI/4;source[18]=Math.PI/2;source[19]=0.05;change(16,-1);const facing=sample();
change(16,1);const away=sample();assert.ok(facing.left>away.left*30, 'directional cone must attenuate rear sound');
source[17]=source[18]=2*Math.PI;source[19]=0;change(16,0);
listener[2]=9;command({type:'listener',config:listener});const closeListener=sample();
assert.ok(closeListener.left>far.left*30, 'listener position must affect attenuation');
change(27,1);const relative=sample();assert.ok(relative.left<closeListener.left/30, 'listener-relative source must ignore listener translation');
command({type:'control',id:20480,op:1,value:1});render(2);
assert.equal(render(10).energy,0);
command({type:'control',id:20480,op:0,value:0.025});
const status=new Float64Array(p.api.memory.buffer,p.api.audio_status(),4);
assert.equal(status[0],1);assert.equal(status[1],20480);assert.equal(status[2],1);
assert.ok(Math.abs(status[3]-0.025)<0.001, 'seek must update reported position while paused');
command({type:'control',id:20480,op:1,value:0});
command({type:'stop',id:20480,fade:0.05});
// Repeated visit/config snapshots must not cancel an active fade.
for(let i=0;i<80;i++){command({type:'config',id:20480,config:source});render(1);}
assert.equal(p.api.audio_voice_count(),0);
assert.equal(render(20).energy,0);
assert.ok(messages.some(x=>x.type==='accepted' && x.id===20480));
assert.equal(messages.filter(x=>x.type==='voices').at(-1).values.length,0);
// Love's routing: per-source effects bus -> per-LoveNode volume bus -> output.
command({type:'stopAll',fade:0});
const busCommand = (id,op,a=0,b=0,c=0,d=0) => command({type:'bus',id,op,a,b,c,d});
busCommand(1,0); busCommand(2,0,1);
command({type:'play',id:24576,asset:5,bytes:sineWav(),loop:true,fade:0,bus:2,isStatic:true});
assert.equal(p.api.audio_asset_bytes(),4800*4,'static cache accounts decoded float PCM');
const full=render(100).energy; assert.ok(full>10);
busCommand(1,2,0.5);render(3);const half=render(100).energy;
assert.ok(half/full>0.22 && half/full<0.28, `parent bus volume must reach child voices: ${half/full}`);
busCommand(2,2,0);render(30);assert.equal(render(30).energy,0,'source bus mute');
busCommand(2,2,1);busCommand(1,2,1);render(3);
busCommand(1,3,1);const busRight=sample();
assert.ok(busRight.right>20*busRight.left,'parent bus pan');
busCommand(1,3,0);const normalPitch=sample();
busCommand(1,4,0.5);const lowerPitch=sample();
// Native Bus remixes children at its own sample rate; do not impose a new
// pitch-shift interpretation on the forwarded bus speed property.
assert.ok(lowerPitch.left>0 && normalPitch.left>0,'bus speed keeps graph valid');
busCommand(1,4,1);render(30);
// Biquad low-pass should suppress a 440Hz sine when cutoff is only 80Hz.
busCommand(2,8,0,2);busCommand(2,9,0,2,80);render(30);
assert.ok(render(100).energy<full/10,'live filter parameters must affect samples');
busCommand(2,10,0,2,8000,0.05);render(100);
assert.ok(render(100).energy>full*0.8,'filter parameter fade');
busCommand(2,8,0,0);render(30);assert.ok(render(100).energy>full*0.9,'filter detach');
command({type:'pause',value:true});render(30);assert.equal(render(30).energy,0,'pause bus graph');
command({type:'pause',value:false});render(30);assert.ok(render(100).energy>full*0.9,'resume bus graph');
// Every exposed filter must instantiate, replace, process and release safely.
for(let filter=1;filter<=11;filter++){busCommand(2,8,0,filter);render(10);busCommand(2,8,0,0);}
busCommand(1,5,0,0.05);render(100);assert.equal(render(30).energy,0,'bus fade');
busCommand(1,2,1);
command({type:'stopAll',fade:0});render(3);
command({type:'play',id:28672,asset:6,bytes:sineWav(),loop:true,fade:0,bus:2});
assert.ok(render(100).energy>10,'stopAll must preserve bus topology');
busCommand(2,1);render(3);assert.equal(p.api.audio_voice_count(),0,'bus release ends child voices');
busCommand(1,1);
assert.equal(p.api.audio_bus_count(),0,'all routing resources released');
// Love can own many idle per-source buses. They must not starve one-shot
// sources and prevent their cursors/AudioEnd from ever advancing.
busCommand(100,0);
for(let i=0;i<40;i++) {
	busCommand(101+i,0,100);
	command({type:'play',id:32768+i*4096,asset:7,bytes:sineWav(),loop:false,fade:0,bus:101+i});
}
render(150);
assert.equal(p.api.audio_voice_count(),0,'all sources behind more than 16 buses must finish');
for(let i=0;i<40;i++)busCommand(101+i,1);
busCommand(100,1);
assert.equal(messages.filter(x=>x.type==='error').length,1,'only the intentional invalid asset may fail');
command({type: 'dispose'});
assert.equal(p.process([], [[new Float32Array(128)]]), false);
console.log('AudioWorklet WASM: codecs, static/stream, 3D, bus hierarchy, all filters, controls, fades, lifecycle and memory isolation passed.');
