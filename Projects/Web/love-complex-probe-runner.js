(function installLoveComplexProbe(global) {
	"use strict";
	const probe = global.DoraLoveComplexProbe = {
		started: false, state: 0, error: "", logs: [],
	};
	const originalLog = console.log.bind(console);
	console.log = function(...args) {
		const line = args.map(String).join(" ");
		probe.logs.push(line);
		if (probe.logs.length > 500) probe.logs.shift();
		originalLog(...args);
	};

	function call(name, returnType = "number") {
		return Module.ccall(name, returnType, [], []);
	}

	function runtimeError() {
		try { return Module.UTF8ToString(call("dora_web_love_complex_probe_error")); }
		catch (error) { return String(error || "Love Web complex project failed"); }
	}

	function gameState() {
		try {
			const value = Module.UTF8ToString(call("dora_web_love_complex_probe_game_state"));
			return JSON.parse(value);
		} catch (error) {
			return {available: false, error: String(error)};
		}
	}

	function poll() {
		probe.state = call("dora_web_love_complex_probe_status");
		if (probe.state < 0) probe.error = runtimeError();
		if (probe.state !== 2 && !probe.error) setTimeout(poll, 16);
	}

	function start() {
		if (probe.started) return;
		probe.started = true;
		if (call("dora_web_love_complex_probe_start") !== 1) {
			probe.error = runtimeError();
			return;
		}
		poll();
	}

	global.doraLoveComplexSnapshot = function() {
		probe.state = call("dora_web_love_complex_probe_status");
		if (probe.state < 0) probe.error = runtimeError();
		const audioContext = Module.SDL2?.audioContext;
		return {
			state: probe.state,
			error: probe.error,
			frame: call("dora_web_love_complex_probe_frame"),
			hasGraphics: call("dora_web_love_complex_probe_has_graphics") === 1,
			nodeUpdating: call("dora_web_love_complex_probe_is_updating") === 1,
			runtimeStatus: call("dora_web_love_complex_probe_runtime_status"),
			audioSources: call("dora_web_love_complex_probe_audio_sources"),
			audioFileDelta: call("dora_web_love_complex_probe_audio_file_delta"),
			voiceDelta: call("dora_web_love_complex_probe_voice_delta"),
			hostPointerPresses: call("dora_web_love_complex_probe_pointer_presses"),
			hostPointerButton: call("dora_web_love_complex_probe_pointer_button"),
			hostPointerFromMouse: call("dora_web_love_complex_probe_pointer_from_mouse"),
			hostPointerX: call("dora_web_love_complex_probe_pointer_x"),
			hostPointerY: call("dora_web_love_complex_probe_pointer_y"),
			gameState: gameState(),
			audioContext: audioContext?.state || "missing",
			webPlatform: global.DoraWebPlatform?.state || null,
			documentHidden: Boolean(global.document?.hidden),
			pageState: global.document?.documentElement?.dataset?.doraState || "missing",
			crossOriginIsolated: Boolean(global.crossOriginIsolated),
			sharedArrayBuffer: typeof global.SharedArrayBuffer === "function",
			logs: probe.logs.slice(-80),
		};
	};

	global.doraUnlockLoveComplexAudio = async function() {
		const context = Module.SDL2?.audioContext;
		if (!context) return {supported: false, state: "missing"};
		if (context.state !== "running") await context.resume();
		return {supported: true, state: context.state};
	};

	global.doraReleaseLoveComplexProbe = async function() {
		if (call("dora_web_love_complex_probe_release") !== 1) {
			probe.error = runtimeError();
			return false;
		}
		const deadline = performance.now() + 10000;
		while (performance.now() < deadline) {
			probe.state = call("dora_web_love_complex_probe_status");
			if (probe.state < 0) { probe.error = runtimeError(); return false; }
			if (probe.state === 2) return true;
			await new Promise((resolve) => setTimeout(resolve, 16));
		}
		probe.error = "Love Web complex-project cleanup timed out";
		return false;
	};

	global.addEventListener("dora-statechange", (event) => {
		if (event.detail?.state === "running") setTimeout(start, 0);
	});
})(globalThis);
