(function installLoveAudioProbe(global) {
	"use strict";
	const probe = global.DoraLoveAudioProbe = {
		started: false,
		readyCount: 0,
		cycleCount: 0,
		state: 0,
		error: "",
	};
	const originalLog = console.log.bind(console);
	console.log = function(...args) {
		const line = args.map(String).join(" ");
		if (line.includes("LOVE_WEB_AUDIO_READY")) probe.readyCount++;
		if (line.includes("LOVE_WEB_AUDIO_CYCLE")) probe.cycleCount++;
		originalLog(...args);
	};

	function call(name, returnType = "number") {
		return Module.ccall(name, returnType, [], []);
	}

	function runtimeError() {
		try {
			return Module.UTF8ToString(call("dora_web_love_audio_probe_error"));
		} catch (error) {
			return String(error || "Love Web audio fixture failed");
		}
	}

	function poll() {
		probe.state = call("dora_web_love_audio_probe_status");
		if (probe.state < 0) probe.error = runtimeError();
		if (!probe.error && probe.state !== 2) setTimeout(poll, 16);
	}

	function start() {
		if (probe.started) return;
		probe.started = true;
		if (call("dora_web_love_audio_probe_start") !== 1) {
			probe.error = runtimeError();
			return;
		}
		poll();
	}

	async function waitForState(expected, timeoutMs = 5000) {
		const deadline = performance.now() + timeoutMs;
		while (performance.now() < deadline) {
			const state = call("dora_web_love_audio_probe_status");
			probe.state = state;
			if (state < 0) {
				probe.error = runtimeError();
				return false;
			}
			if (state === expected) return true;
			await new Promise((resolve) => setTimeout(resolve, 16));
		}
		probe.error = `Love Web audio probe timed out waiting for state ${expected}`;
		return false;
	}

	global.doraLoveAudioSnapshot = function() {
		const context = Module.SDL2?.audioContext;
		return {
			state: call("dora_web_love_audio_probe_status"),
			instances: call("dora_web_love_audio_probe_instance_count"),
			sources: call("dora_web_love_audio_probe_source_count"),
			playing: call("dora_web_love_audio_probe_playing_count"),
			audioFiles: call("dora_web_love_audio_probe_audio_file_delta"),
			voices: call("dora_web_love_audio_probe_voice_delta"),
			frame: call("dora_web_love_audio_probe_frame"),
			audioContext: context?.state || "unavailable",
			readyCount: probe.readyCount,
			cycleCount: probe.cycleCount,
			error: probe.error,
		};
	};

	global.doraUnlockLoveAudioProbe = async function() {
		const context = Module.SDL2?.audioContext;
		if (!context) return {supported: false, state: "unavailable"};
		if (context.state !== "running") await context.resume();
		return {supported: true, state: context.state};
	};

	global.doraRestartFirstLoveAudioProbe = async function() {
		if (call("dora_web_love_audio_probe_restart_first") !== 1) {
			probe.error = runtimeError();
			return false;
		}
		return waitForState(1);
	};

	global.doraReleaseFirstLoveAudioProbe = async function() {
		if (call("dora_web_love_audio_probe_release_first") !== 1) {
			probe.error = runtimeError();
			return false;
		}
		return waitForState(5);
	};

	global.doraReleaseLoveAudioProbe = async function() {
		if (call("dora_web_love_audio_probe_release") !== 1) {
			probe.error = runtimeError();
			return false;
		}
		return waitForState(2);
	};

	global.addEventListener("dora-statechange", (event) => {
		if (event.detail?.state === "running") setTimeout(start, 0);
	});
})(globalThis);
