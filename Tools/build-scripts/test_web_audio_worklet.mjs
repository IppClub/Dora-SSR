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
command({type: 'dispose'});
assert.equal(p.process([], [[new Float32Array(128)]]), false);
console.log('AudioWorklet WASM: decoding, looping, pause, volume, fades, lifecycle and memory isolation passed.');
