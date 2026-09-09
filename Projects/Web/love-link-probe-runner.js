(function runDoraLoveLinkProbe(module) {
	module.onRuntimeInitialized = function onRuntimeInitialized() {
		const startedAt = performance.now();
		let heartbeats = 0;
		const heartbeat = setInterval(() => heartbeats++, 0);
		const readError = () => {
			const pointer = module.ccall("dora_web_love_link_probe_error", "number", [], []);
			return pointer ? module.UTF8ToString(pointer) : "";
		};
		const finish = (passed, error = "") => {
			clearInterval(heartbeat);
			const incremental = {
				steps: module.ccall("dora_web_love_incremental_probe_steps", "number", [], []),
				heartbeats,
				durationMs: performance.now() - startedAt,
			};
			globalThis.DoraLoveProbe = {passed, error, incremental};
			if (typeof document !== "undefined") {
				document.documentElement.dataset.doraLoveProbe = passed ? "passed" : "failed";
				document.documentElement.dataset.doraLoveError = error;
			}
			if (!passed) throw new Error(`Dora Love runtime probe failed: ${error || "unknown error"}`);
			console.log(`[INFO] Dora Love runtime link probe passed (${incremental.steps} incremental steps, ${incremental.heartbeats} heartbeats)`);
		};
		if (module.ccall("dora_web_love_link_probe", "number", [], []) !== 1) {
			finish(false, readError());
			return;
		}
		if (module.ccall("dora_web_love_incremental_probe_begin", "number", [], []) !== 1) {
			finish(false, readError());
			return;
		}
		const step = () => {
			const result = module.ccall("dora_web_love_incremental_probe_step", "number", [], []);
			if (result === 0) setTimeout(step, 0);
			else finish(result === 1, result === 1 ? "" : readError());
		};
		setTimeout(step, 0);
	};
})(Module);
