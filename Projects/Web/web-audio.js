// Phase 1: Audio.play/playStream. AudioSource/buses retain their SDL backend.
// This module never produces PCM. Only the worklet calls SoLoud::mix().
(function(module) {
	const base = new URL('.', document.currentScript?.src || document.baseURI);
	let context, node, ready = false, disposed = false;
	let hostSuspended = false;
	let nextVoice = 1, nextAsset = 1, cacheBytes = 0;
	const cache = new Map();
	const maxBytes = 64 * 1024 * 1024;
	let stats = {backend: 'initializing'};
	function send(message, transfers = []) { if (ready) node.port.postMessage(message, transfers); }
	function fail(error) {
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
				else if (data.type === 'error') {
					stats = {...stats, lastError: data.message};
					console.error('[DoraAudio]', data.message, data.id);
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
		globalThis.removeEventListener('pointerdown', resume, true);
		globalThis.removeEventListener('keydown', resume, true);
	}
	module.doraAudio = {
		get ready() { return ready; },
		get context() { return context; },
		get state() { return {...stats, ready, cacheBytes, context: context?.state}; },
		has: key => cache.has(key),
		play(key, bytes, loop, fade, background = false) {
			if (!ready || nextVoice >= 0xfffff) return 0;
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
			const id = (nextVoice++ * 4096) >>> 0;
			const copy = asset.bytes.slice().buffer;
			send({type: 'play', id, asset: asset.id, bytes: copy, loop, fade: Math.max(0, fade), background}, [copy]);
			return id;
		},
		stop(id, fade) { send({type: 'stop', id, fade: Math.max(0, fade)}); },
		stopAll(fade) {
			send({type: 'stopAll', fade: Math.max(0, fade)});
			if (fade <= 0) { cache.clear(); cacheBytes = 0; }
		},
		volume(value) { send({type: 'volume', value}); },
		pause(value) { send({type: 'pause', value}); },
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
