(function installLoveShaderProbe(global) {
	"use strict";
	const probe = global.DoraLoveShaderProbe = {
		started: false,
		running: false,
		visualReady: false,
		released: false,
		error: "",
	};
	const originalLog = console.log.bind(console);
	console.log = function(...args) {
		const line = args.map(String).join(" ");
		if (line.includes("LOVE_WEB_SHADER_READY")) probe.visualReady = true;
		originalLog(...args);
	};

	function runtimeError() {
		try {
			return Module.UTF8ToString(Module.ccall("dora_web_love_shader_probe_error", "number", [], []));
		} catch (error) {
			return String(error || "Love Web shader fixture failed");
		}
	}

	function poll() {
		const status = Module.ccall("dora_web_love_shader_probe_status", "number", [], []);
		probe.running = status === 1;
		probe.released = status === 2;
		if (status < 0) probe.error = runtimeError();
		if (!probe.error && !probe.released) setTimeout(poll, 16);
	}

	function start() {
		if (probe.started) return;
		probe.started = true;
		if (Module.ccall("dora_web_love_shader_probe_start", "number", [], []) !== 1) {
			probe.error = runtimeError();
			return;
		}
		poll();
	}

	global.doraReleaseLoveShaderProbe = async function() {
		if (Module.ccall("dora_web_love_shader_probe_release", "number", [], []) !== 1) {
			probe.error = runtimeError();
			return false;
		}
		const deadline = performance.now() + 5000;
		while (performance.now() < deadline) {
			const status = Module.ccall("dora_web_love_shader_probe_status", "number", [], []);
			if (status < 0) {
				probe.error = runtimeError();
				return false;
			}
			if (status === 2) {
				probe.running = false;
				probe.released = true;
				return true;
			}
			await new Promise((resolve) => setTimeout(resolve, 16));
		}
		probe.error = "Love Web shader cleanup timed out";
		return false;
	};

	global.addEventListener("dora-statechange", (event) => {
		if (event.detail?.state === "running") setTimeout(start, 0);
	});
})(globalThis);
