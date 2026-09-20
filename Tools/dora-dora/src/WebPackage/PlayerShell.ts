import type {WebPackageFormat} from './Archive';

// The export page owns its markup and boot callbacks, independently of the
// gallery and Emscripten-generated HTML. Both formats share this template.
export function createPlayerShell(format: WebPackageFormat): string {
  return String.raw`<!doctype html>
<html lang="en" data-dora-state="booting">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width,initial-scale=1">
	<title>Dora SSR Web Player</title>
	<style>
		html, body, canvas { width: 100%; height: 100%; margin: 0; overflow: hidden; }
		canvas { display: block; }
		canvas:focus { outline: 0.5px solid rgba(176, 176, 176, 0.35); outline-offset: -0.5px; }
		#status { position: fixed; inset: 0; display: grid; place-items: center; color: #ddd; background: #181818; font: 14px system-ui, sans-serif; }
		#status-content { width: min(320px, calc(100% - 48px)); text-align: center; }
		#status-message { min-height: 1.4em; }
		#progress-track { height: 4px; margin-top: 12px; overflow: hidden; border-radius: 2px; background: rgba(255, 255, 255, 0.14); }
		#progress-bar { width: 100%; height: 100%; border-radius: inherit; background: #d7b044; transform: scaleX(0); transform-origin: left; transition: transform 120ms ease-out; }
		html[data-dora-progress="indeterminate"] #progress-bar { width: 38%; animation: dora-progress 1.15s ease-in-out infinite; }
		html[data-dora-state="faulted"] #progress-track { display: none; }
		html[data-dora-state="running"] #status, html[data-dora-state="stopped"] #status { display: none; }
		@keyframes dora-progress { from { transform: translateX(-105%); } to { transform: translateX(365%); } }
		@media (prefers-reduced-motion: reduce) { #progress-bar { transition: none; } html[data-dora-progress="indeterminate"] #progress-bar { animation-duration: 2.3s; } }
	</style>
<style>
    #engine-brand { display: flex; justify-content: center; margin-bottom: 28px; }
    #engine-logo { display: block; width: 128px; height: 128px; object-fit: contain; }
    #status-message { font-size: 12px; line-height: 1.6; color: #aeb6bf; overflow-wrap: anywhere; }
    @media (max-height: 360px) { #engine-brand { margin-bottom: 12px; } #engine-logo { width: 80px; height: 80px; } }
  </style>
</head>
<body>
	<canvas id="canvas" tabindex="0"></canvas>
	<div id="status" role="status">
		<div id="status-content"><div id="engine-brand"><img id="engine-logo" src="dora-logo.png" alt="" width="128" height="128"></div>
			<div id="status-message">Loading Dora SSR…</div>
			<div id="progress-track"><div id="progress-bar" role="progressbar" aria-label="Loading game resources"></div></div>
		</div>
	</div>
	<script>
		performance.mark("dora-shell-ready");
		window.doraSetProgress = function(value, detail) {
			const root = document.documentElement;
			const bar = document.getElementById("progress-bar");
			const message = document.getElementById("status-message");
			if (detail) message.textContent = detail;
			if (!Number.isFinite(value)) {
				root.dataset.doraProgress = "indeterminate";
				bar.removeAttribute("aria-valuenow");
				return;
			}
			const progress = Math.max(0, Math.min(1, value));
			root.dataset.doraProgress = "determinate";
			bar.style.transform = "scaleX(" + progress + ")";
			bar.setAttribute("aria-valuemin", "0");
			bar.setAttribute("aria-valuemax", "100");
			bar.setAttribute("aria-valuenow", String(Math.round(progress * 100)));
		};
		window.doraSetState = function(state, detail) {
			performance.mark("dora-state-" + state);
			if (document.documentElement.dataset.doraState === "faulted" && state === "stopped") return;
			document.documentElement.dataset.doraState = state;
			const message = document.getElementById("status-message");
			if (state === "faulted") message.textContent = detail || "Dora SSR failed to start.";
			else if (state === "stopping") message.textContent = "Stopping Dora SSR…";
			else if (state === "ready") window.doraSetProgress(1, "Starting Dora SSR…");
			window.dispatchEvent(new CustomEvent("dora-statechange", { detail: { state, message: detail || "" } }));
			if (state === "running" && new URLSearchParams(location.search).has("dora-test-stop")) {
				setTimeout(function() { window.doraStop(); }, 0);
			}
		};
		var Module = {
			canvas: document.getElementById("canvas"),
			setStatus: function(status) {
				const match = /\((\d+)\/(\d+)\)/.exec(status || "");
				if (match && Number(match[2]) > 0) window.doraSetProgress((Number(match[1]) / Number(match[2])) * 0.5, "Loading Dora runtime…");
				else if (status && status !== "Running...") window.doraSetProgress(NaN, status);
			},
			doraReportProgress: function(loaded, total, detail) {
				window.doraSetProgress(total > 0 ? 0.5 + (loaded / total) * 0.48 : NaN, detail || "Loading game resources…");
			},
			onRuntimeInitialized: function() { window.doraSetState("ready"); },
			onAbort: function(reason) { window.doraSetState("faulted", String(reason || "Runtime aborted")); }
		};
		window.doraSetProgress(0, "Loading Dora runtime…");
		window.doraStop = function() {
			if (document.documentElement.dataset.doraState !== "running") return false;
			window.doraSetState("stopping");
			window.DoraWebPlatform?.dispose();
			Module.ccall("dora_web_stop", null, [], []);
			return true;
		};
		window.addEventListener("dora-stop-request", window.doraStop);
	</script>
	<script src="${format === 'html' ? 'html-loader.js' : 'dora-player-runtime.js'}"></script>
</body>
</html>
`;
}
