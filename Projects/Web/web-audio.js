// Independent mixing for encoded sources, spatial audio and bus/filter graphs.
// This module never produces PCM. Only the worklet calls SoLoud::mix().
(function(module) {
	// Emscripten pthread workers load the same glue, but only the window owns
	// the AudioContext. Love worker requests are marshalled to the logic host.
	if (typeof document === 'undefined') return;
	const base = new URL('.', document.currentScript?.src || document.baseURI);
	let context, node, ready = false, disposed = false;
	let hostSuspended = false;
	let nextVoice = 1, nextAsset = 1, cacheBytes = 0;
	const cache = new Map();
	const voices = new Map();
	let revision = 0, listener;
	const maxBytes = 64 * 1024 * 1024;
	let stats = {backend: 'initializing'};
	function send(message, transfers = []) {
		if (!ready) return revision;
		message.revision = ++revision;
		node.port.postMessage(message, transfers);
		return revision;
	}
	function ended(id) {
		const voice = voices.get(id);
		voices.delete(id);
		if (voice?.tracked && !disposed) module.ccall?.('dora_worklet_ended', null, ['number'], [id]);
	}
	function fail(error) {
		for (const id of [...voices.keys()]) ended(id);
		dispose();
		stats = {backend: 'sdl-fallback', error: String(error)};
		console.warn('[DoraAudio] Worklet unavailable; using SDL:', error);
	}
	async function initialize() {
		if (module.doraAudioWorklet === false) throw new Error('disabled by host');
		const Context = globalThis.AudioContext || globalThis.webkitAudioContext;
		if (!globalThis.isSecureContext || !Context || !globalThis.AudioWorkletNode)
			throw new Error('AudioWorklet requires a supported browser and HTTPS (or localhost)');
		context = new Context({latencyHint: 'interactive'});
		const response = await fetch(new URL('dora-audio-mixer.wasm', base));
		if (!response.ok) throw new Error(`Audio mixer HTTP ${response.status}`);
		const wasm = await WebAssembly.compile(await response.arrayBuffer());
		await context.audioWorklet.addModule(new URL('audio-worklet.js', base));
		if (disposed) return;
		node = new AudioWorkletNode(context, 'dora-audio', {
			numberOfInputs: 0, numberOfOutputs: 1, outputChannelCount: [2], processorOptions: {wasm},
		});
		await new Promise((resolve, reject) => {
			node.onprocessorerror = () => {
				const error = new Error('Audio processor failed');
				if (ready) fail(error); else reject(error);
			};
			node.port.onmessage = ({data}) => {
				if (data.type === 'ready') {
					stats = {backend: 'audioworklet-soloud', sampleRate: data.sampleRate};
					resolve();
				} else if (data.type === 'stats') stats = {...stats, ...data};
				else if (data.type === 'accepted') {
					const voice = voices.get(data.id);
					if (voice) voice.accepted = true;
				} else if (data.type === 'voices') {
					const live = new Set();
					for (let i = 0; i < data.values.length; i += 3) {
						const id = data.values[i], voice = voices.get(id);
						live.add(id);
						if (voice && data.revision >= voice.revision) {
							voice.paused = data.values[i + 1]; voice.position = data.values[i + 2];
						}
					}
					for (const [id, voice] of voices) {
						if (voice.accepted && data.revision >= voice.revision && !live.has(id)) ended(id);
					}
				}
				else if (data.type === 'error') {
					stats = {...stats, lastError: data.message};
					console.error('[DoraAudio]', data.message, data.id);
					if (data.command === 'play') ended(data.id);
				}
			};
			node.connect(context.destination);
		});
		if (!disposed) ready = true;
	}
	function resume() {
		if (!disposed && !hostSuspended && context && context.state !== 'running' && context.state !== 'closed')
			void context.resume().catch(() => {});
	}
	function dispose() {
		if (disposed) return;
		send({type: 'dispose'});
		disposed = true;
		ready = false;
		node?.disconnect();
		node?.port.close();
		void context?.close().catch(() => {});
		cache.clear(); cacheBytes = 0;
		voices.clear();
		globalThis.removeEventListener('pointerdown', resume, true);
		globalThis.removeEventListener('keydown', resume, true);
	}
	module.doraAudio = {
		get ready() { return ready; },
		get context() { return context; },
		get state() { return {...stats, ready, cacheBytes, context: context?.state}; },
		has: key => cache.has(key),
		bus(id, op, a, b, c, d) { if (ready) send({type: 'bus', id: id >>> 0, op, a, b, c, d}); },
		play(key, bytes, loop, fade, background = false, config = null, bus = 0, isStatic = false) {
			if (!ready || voices.size >= 64) return 0;
			let asset = cache.get(key);
			if (!asset) {
				if (!bytes?.length || bytes.length > maxBytes) return 0;
				while (cacheBytes + bytes.length > maxBytes) {
					const oldest = cache.keys().next().value;
					cacheBytes -= cache.get(oldest).bytes.length;
					cache.delete(oldest);
				}
				asset = {id: nextAsset++, bytes};
				cacheBytes += bytes.length;
			}
			cache.delete(key); cache.set(key, asset);
			// Low 12 bits are zero: never a valid SoLoud voice handle (index + 1).
			let id;
			do {
				if (nextVoice >= 0xfffff) nextVoice = 1;
				id = (nextVoice++ * 4096) >>> 0;
			} while (voices.has(id));
			const copy = asset.bytes.slice().buffer;
			const sent = send({type: 'play', id, asset: asset.id, bytes: copy, loop, fade: Math.max(0, fade), background, config, bus: bus >>> 0, isStatic}, [copy]);
			voices.set(id, {accepted: false, tracked: Boolean(config), paused: 0, position: 0, revision: sent, config});
			return id;
		},
		configure(id, config) {
			id >>>= 0;
			const voice = voices.get(id);
			if (!voice || voice.config?.every((v, i) => v === config[i])) return;
			voice.config = config;
			voice.revision = send({type: 'config', id, config});
		},
		listener(config) {
			if (listener?.every((v, i) => v === config[i])) return;
			listener = config; send({type: 'listener', config});
		},
		control(id, op, value) {
			id >>>= 0;
			const voice = voices.get(id);
			if (!voice) return;
			if (op === 0) voice.position = value;
			if (op === 1) voice.paused = value ? 1 : 0;
			voice.revision = send({type: 'control', id, op, value});
		},
		get(id, property) { const voice = voices.get(id >>> 0); return voice && !voice.stopping ? (property === 0 ? 1 : property === 1 ? voice.paused : voice.position) : 0; },
		stop(id, fade) {
			id >>>= 0;
			const sent = send({type: 'stop', id, fade: Math.max(0, fade)});
			const voice = voices.get(id);
			if (voice) { voice.revision = sent; voice.stopping = fade <= 0; }
		},
		stopAll(fade) {
			const sent = send({type: 'stopAll', fade: Math.max(0, fade)});
			for (const voice of voices.values()) { voice.revision = sent; voice.stopping = fade <= 0; }
			if (fade <= 0) { cache.clear(); cacheBytes = 0; }
		},
		volume(value) { send({type: 'volume', value}); },
		pause(value) {
			const sent = send({type: 'pause', value});
			for (const voice of voices.values()) { voice.revision = sent; voice.paused = value ? 1 : 0; }
		},
		setSuspended(value) { hostSuspended = Boolean(value); },
		resume, dispose,
	};
	globalThis.addEventListener('pointerdown', resume, true);
	globalThis.addEventListener('keydown', resume, true);
	module.preRun = module.preRun || [];
	module.preRun.push(() => {
		addRunDependency('dora-audio');
		let timer;
		Promise.race([initialize(), new Promise((_, reject) => {
			timer = setTimeout(() => reject(new Error('Audio initialization timeout')), 15000);
		})]).catch(fail).finally(() => { clearTimeout(timer); removeRunDependency('dora-audio'); });
	});
})(Module);
