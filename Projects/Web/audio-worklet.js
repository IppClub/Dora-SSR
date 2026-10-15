// The complete mixer and decoders live in this isolated WASM instance.
class DoraAudioProcessor extends AudioWorkletProcessor {
	constructor(options) {
		super();
		this.alive = true;
		this.frames = 0;
		this.clipped = 0;
		this.position = 128;
		this.revision = 0;
		const unsupported = () => { throw new Error('Unexpected audio WASI operation'); };
		const wasi = {
			proc_exit: unsupported,
			fd_close: () => 8, fd_seek: () => 8, fd_read: () => 8, fd_write: () => 8,
			environ_sizes_get: (count, size) => {
				const heap = new Uint32Array(this.api.memory.buffer);
				heap[count >> 2] = heap[size >> 2] = 0;
				return 0;
			},
			environ_get: () => 0,
		};
		const instance = new WebAssembly.Instance(options.processorOptions.wasm, {
			wasi_snapshot_preview1: wasi,
			env: {emscripten_notify_memory_growth: () => { this.samples = null; }},
		});
		this.api = instance.exports;
		this.api._initialize();
		if (this.api.audio_init(sampleRate)) throw new Error('SoLoud audio initialization failed');
		this.configBuffer = this.api.malloc(31 * 4);
		if (!this.configBuffer) throw new Error('Audio configuration allocation failed');
		this.port.onmessage = ({data}) => {
			this.revision = data.revision || 0;
			try { this.command(data); this.reportVoices(); }
			catch (error) { this.port.postMessage({type: 'error', message: String(error), id: data.id, command: data.type}); }
		};
		this.port.postMessage({type: 'ready', sampleRate});
	}
	reportVoices() {
		const ptr = this.api.audio_status();
		const count = new Float64Array(this.api.memory.buffer, ptr, 1)[0];
		this.port.postMessage({type: 'voices', revision: this.revision,
			values: new Float64Array(this.api.memory.buffer, ptr + 8, count * 3).slice()});
	}
	command(data) {
		const api = this.api;
		if (data.config || data.type === 'config' || data.type === 'listener') {
			const expected = data.type === 'listener' ? 15 : 31;
			if (!data.config || data.config.length !== expected || !data.config.every(Number.isFinite)) throw new Error('Invalid audio configuration');
			new Float32Array(api.memory.buffer, this.configBuffer, data.config.length).set(data.config);
		}
		switch (data.type) {
			case 'play': {
				const bytes = new Uint8Array(data.bytes);
				const ptr = api.malloc(bytes.length);
				if (!ptr) throw new Error('Audio memory exhausted');
				let result;
				try {
					new Uint8Array(api.memory.buffer, ptr, bytes.length).set(bytes);
					result = api.audio_play(data.id, data.asset, ptr, bytes.length, data.loop, data.fade, data.background ? 1 : 0, data.config ? this.configBuffer : 0, data.bus || 0, data.isStatic ? 1 : 0);
				} finally { api.free(ptr); }
				if (result) throw new Error(`Audio load/play failed (${result})`);
				this.port.postMessage({type: 'accepted', id: data.id});
				break;
			}
			case 'config': api.audio_config(data.id, this.configBuffer); break;
			case 'bus':
				if (api.audio_bus(data.id, data.op, data.a, data.b, data.c, data.d)) throw new Error('Audio bus command failed');
				break;
			case 'listener': api.audio_listener(this.configBuffer); break;
			case 'control':
				if (api.audio_control(data.id, data.op, data.value)) throw new Error('Audio control failed');
				break;
			case 'stop': api.audio_stop(data.id, data.fade); break;
			case 'stopAll': api.audio_stop_all(data.fade); break;
			case 'volume': api.audio_volume(data.value); break;
			case 'pause': api.audio_pause(data.value); break;
			case 'dispose': api.audio_stop_all(0); this.alive = false; break;
		}
	}
	process(inputs, outputs) {
		if (!this.alive) return false;
		const output = outputs[0];
		if (!output?.length) return true;
		// Work with any browser render quantum; SoLoud consumes fixed 128-frame blocks.
		for (let i = 0; i < output[0].length; ++i) {
			if (this.position === 128) {
				const ptr = this.api.audio_mix();
				if (!this.samples || this.samples.buffer !== this.api.memory.buffer)
					this.samples = new Float32Array(this.api.memory.buffer, ptr, 256);
				this.position = 0;
			}
			const index = this.position++ * 2;
			for (let channel = 0; channel < output.length; ++channel) {
				const value = this.samples[index + Math.min(channel, 1)];
				output[channel][i] = Number.isFinite(value) ? value : 0;
				if (Math.abs(value) >= 1) ++this.clipped;
			}
		}
		const before = this.frames;
		this.frames += output[0].length;
		if (Math.floor(before / 1024) !== Math.floor(this.frames / 1024)) {
			this.reportVoices();
		}
		if (Math.floor(before / sampleRate) !== Math.floor(this.frames / sampleRate)) {
			this.port.postMessage({type: 'stats', frames: this.frames, clipped: this.clipped,
				voices: this.api.audio_voice_count(), buses: this.api.audio_bus_count(), assetBytes: this.api.audio_asset_bytes()});
		}
		return true;
	}
}
registerProcessor('dora-audio', DoraAudioProcessor);
