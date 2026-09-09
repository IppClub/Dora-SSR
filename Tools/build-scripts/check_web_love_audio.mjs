import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import {spawn} from "node:child_process";

const artifactRoot = path.resolve(process.argv[2] || "build/web");
const reportPath = path.resolve(process.argv[3] || "build/web-love-audio-report.json");
const reloadCount = Number(process.env.DORA_WEB_LOVE_AUDIO_RELOADS || 20);
const soakSeconds = Number(process.env.DORA_WEB_LOVE_AUDIO_SOAK_SECONDS || 0);
const configuredSampleSeconds = Number(process.env.DORA_WEB_LOVE_AUDIO_SAMPLE_SECONDS || 0);
assert.ok(Number.isInteger(reloadCount) && reloadCount >= 0 && reloadCount <= 100,
	"DORA_WEB_LOVE_AUDIO_RELOADS must be an integer from 0 to 100");
assert.ok(Number.isFinite(soakSeconds) && soakSeconds >= 0 && soakSeconds <= 3600,
	"DORA_WEB_LOVE_AUDIO_SOAK_SECONDS must be from 0 to 3600");
assert.ok(Number.isFinite(configuredSampleSeconds) && configuredSampleSeconds >= 0,
	"DORA_WEB_LOVE_AUDIO_SAMPLE_SECONDS must not be negative");

for (const extension of ["html", "js", "wasm", "data"]) {
	const artifact = `dora-love-audio-probe.${extension}`;
	assert.ok(fs.statSync(path.join(artifactRoot, artifact), {throwIfNoEntry: false})?.isFile(),
		`missing Love Web audio artifact: ${artifact}`);
}

function chromeExecutable() {
	const candidates = [
		process.env.DORA_WEB_CHROME,
		process.platform === "darwin" ? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" : undefined,
		"/usr/bin/google-chrome", "/usr/bin/google-chrome-stable", "/usr/bin/chromium", "/usr/bin/chromium-browser",
	].filter(Boolean);
	const executable = candidates.find((candidate) => fs.statSync(candidate, {throwIfNoEntry: false})?.isFile());
	if (!executable) throw new Error("Chrome/Chromium not found; set DORA_WEB_CHROME");
	return executable;
}

function mimeType(file) {
	switch (path.extname(file)) {
		case ".html": return "text/html; charset=utf-8";
		case ".js": return "text/javascript; charset=utf-8";
		case ".wasm": return "application/wasm";
		default: return "application/octet-stream";
	}
}

function startServer() {
	const server = http.createServer((request, response) => {
		const requestPath = new URL(request.url, "http://localhost").pathname;
		if (requestPath === "/favicon.ico") return response.writeHead(204).end();
		const relative = decodeURIComponent(requestPath === "/" ? "/dora-love-audio-probe.html" : requestPath).replace(/^\/+/, "");
		const file = path.resolve(artifactRoot, relative);
		if (file !== artifactRoot && !file.startsWith(`${artifactRoot}${path.sep}`)) return response.writeHead(403).end();
		const stat = fs.statSync(file, {throwIfNoEntry: false});
		if (!stat?.isFile()) return response.writeHead(404).end();
		response.writeHead(200, {"Cache-Control": "no-store", "Content-Length": stat.size, "Content-Type": mimeType(file)});
		fs.createReadStream(file).pipe(response);
	});
	return new Promise((resolve, reject) => {
		server.once("error", reject);
		server.listen(0, "127.0.0.1", () => resolve(server));
	});
}

async function waitForFile(file, timeoutMs) {
	const deadline = Date.now() + timeoutMs;
	while (Date.now() < deadline) {
		if (fs.statSync(file, {throwIfNoEntry: false})?.isFile()) return;
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	throw new Error(`timed out waiting for ${file}`);
}

async function waitForJson(url, timeoutMs) {
	const deadline = Date.now() + timeoutMs;
	let lastError;
	while (Date.now() < deadline) {
		try {
			const response = await fetch(url);
			if (response.ok) return response.json();
			lastError = new Error(`HTTP ${response.status}`);
		} catch (error) { lastError = error; }
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	throw new Error(`timed out waiting for ${url}: ${lastError?.message || "unknown error"}`);
}

class Cdp {
	constructor(url) {
		this.nextId = 1;
		this.pending = new Map();
		this.listeners = new Set();
		this.socket = new WebSocket(url);
		this.ready = new Promise((resolve, reject) => {
			this.socket.addEventListener("open", resolve, {once: true});
			this.socket.addEventListener("error", reject, {once: true});
		});
		this.socket.addEventListener("message", (event) => {
			const message = JSON.parse(event.data);
			if (message.id) {
				const pending = this.pending.get(message.id);
				if (!pending) return;
				this.pending.delete(message.id);
				if (message.error) pending.reject(new Error(message.error.message));
				else pending.resolve(message.result);
				return;
			}
			for (const listener of this.listeners) listener(message);
		});
	}
	async send(method, params = {}) {
		await this.ready;
		const id = this.nextId++;
		const result = new Promise((resolve, reject) => this.pending.set(id, {resolve, reject}));
		this.socket.send(JSON.stringify({id, method, params}));
		return result;
	}
	onEvent(listener) { this.listeners.add(listener); return () => this.listeners.delete(listener); }
	async close() {
		if (this.socket.readyState === WebSocket.CLOSED) return;
		await new Promise((resolve) => {
			const timeout = setTimeout(resolve, 1000);
			this.socket.addEventListener("close", () => { clearTimeout(timeout); resolve(); }, {once: true});
			this.socket.close();
		});
	}
}

async function evaluate(cdp, expression, options = {}) {
	const result = await cdp.send("Runtime.evaluate", {
		expression, awaitPromise: true, returnByValue: true, ...options,
	});
	if (result.exceptionDetails)
		throw new Error(result.exceptionDetails.exception?.description || result.exceptionDetails.text);
	return result.result.value;
}

async function unlockAudio(cdp) {
	const deadline = Date.now() + 15000;
	while (Date.now() < deadline) {
		const result = await evaluate(cdp,
			"globalThis.doraUnlockLoveAudioProbe ? doraUnlockLoveAudioProbe() : null",
			{userGesture: true});
		if (result?.supported) {
			assert.equal(result.state, "running", `Love Web AudioContext did not unlock: ${JSON.stringify(result)}`);
			return result;
		}
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	throw new Error("timed out waiting for the Love Web AudioContext");
}

async function waitForSnapshot(cdp, predicate, label, timeoutMs = 15000) {
	const deadline = Date.now() + timeoutMs;
	let snapshot = null;
	while (Date.now() < deadline) {
		snapshot = await evaluate(cdp, "globalThis.doraLoveAudioSnapshot ? doraLoveAudioSnapshot() : null");
		if (snapshot?.error) throw new Error(`${label}: ${snapshot.error}`);
		if (snapshot && predicate(snapshot)) return snapshot;
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	throw new Error(`timed out waiting for ${label}: ${JSON.stringify(snapshot)}`);
}

async function memorySnapshot(cdp) {
	await cdp.send("HeapProfiler.collectGarbage");
	const [dom, heap] = await Promise.all([
		cdp.send("Memory.getDOMCounters"),
		cdp.send("Runtime.getHeapUsage"),
	]);
	return {documents: dom.documents, nodes: dom.nodes, listeners: dom.jsEventListeners,
		jsHeapUsed: heap.usedSize};
}

function slopePerMinute(samples, key) {
	if (samples.length < 2) return 0;
	const xs = samples.map((sample) => sample.elapsedSeconds / 60);
	const ys = samples.map((sample) => sample[key]);
	const meanX = xs.reduce((sum, value) => sum + value, 0) / xs.length;
	const meanY = ys.reduce((sum, value) => sum + value, 0) / ys.length;
	const denominator = xs.reduce((sum, value) => sum + (value - meanX) ** 2, 0);
	return denominator === 0 ? 0 : xs.reduce((sum, value, index) =>
		sum + (value - meanX) * (ys[index] - meanY), 0) / denominator;
}

async function runSoak(cdp, seconds, pageErrors) {
	if (seconds <= 0) return null;
	const intervalSeconds = configuredSampleSeconds > 0 ? configuredSampleSeconds
		: seconds >= 120 ? 60 : Math.max(1, seconds / 5);
	const start = performance.now();
	const samples = [];
	let nextSample = 0;
	while (true) {
		const elapsedSeconds = (performance.now() - start) / 1000;
		if (elapsedSeconds + 0.001 >= nextSample || elapsedSeconds >= seconds) {
			const [runtime, memory] = await Promise.all([
				evaluate(cdp, "doraLoveAudioSnapshot()"), memorySnapshot(cdp),
			]);
			assert.equal(runtime.error, "", `Love Web audio soak failed: ${JSON.stringify(runtime)}`);
			assert.equal(runtime.instances, 2, "Love Web audio instance count changed during soak");
			assert.equal(runtime.sources, 8, "Love Web audio Source count changed during soak");
			assert.ok(runtime.playing >= 2, "Love Web looping audio playback stopped during soak");
			assert.ok(runtime.voices > 0 && runtime.audioFiles === 6,
				`Love Web audio native resources changed during soak: ${JSON.stringify(runtime)}`);
			assert.equal(runtime.audioContext, "running", "Love Web AudioContext stopped during soak");
			samples.push({elapsedSeconds, ...runtime, ...memory,
				pageErrorCount: pageErrors.length});
			console.log(`[INFO] Love Web audio soak ${elapsedSeconds.toFixed(1)}/${seconds}s: frame=${runtime.frame}, heap=${memory.jsHeapUsed}, voices=${runtime.voices}`);
			nextSample += intervalSeconds;
		}
		if (elapsedSeconds >= seconds) break;
		await new Promise((resolve) => setTimeout(resolve,
			Math.min(1000, Math.max(25, (nextSample - elapsedSeconds) * 1000))));
	}
	for (let index = 1; index < samples.length; index++) {
		assert.ok(samples[index].frame > samples[index - 1].frame, "Love Web audio engine frame stalled during soak");
		assert.equal(samples[index].documents, samples[0].documents, "documents changed during Love Web audio soak");
		assert.equal(samples[index].nodes, samples[0].nodes, "DOM nodes changed during Love Web audio soak");
		assert.equal(samples[index].listeners, samples[0].listeners, "listeners changed during Love Web audio soak");
		assert.equal(samples[index].pageErrorCount, samples[0].pageErrorCount, "browser errors appeared during Love Web audio soak");
	}
	assert.ok(samples.at(-1).cycleCount > samples[0].cycleCount,
		"Love Web SoundData stop/replay cycle did not advance during soak");
	const heapSlopeBytesPerMinute = slopePerMinute(samples, "jsHeapUsed");
	if (seconds >= 300)
		assert.ok(heapSlopeBytesPerMinute <= 256 * 1024,
			`Love Web audio heap slope exceeded 256 KiB/min: ${heapSlopeBytesPerMinute}`);
	return {durationSeconds: samples.at(-1).elapsedSeconds, sampleIntervalSeconds: intervalSeconds,
		samples, heapSlopeBytesPerMinute};
}

async function exerciseLifecycle(cdp, expectedReadyCount) {
	const initial = await waitForSnapshot(cdp, (snapshot) => snapshot.state === 1
		&& snapshot.readyCount >= expectedReadyCount && snapshot.instances === 2
		&& snapshot.sources === 8 && snapshot.playing >= 2, "two ready Love Web audio instances");
	assert.equal(initial.audioContext, "running");
	assert.equal(initial.audioFiles, 6, `unexpected Love Web AudioFile count: ${JSON.stringify(initial)}`);
	assert.ok(initial.voices > 0, `Love Web audio created no SoLoud voices: ${JSON.stringify(initial)}`);

	assert.equal(await evaluate(cdp, "doraRestartFirstLoveAudioProbe()"), true,
		"Love Web audio instance restart failed");
	const restarted = await waitForSnapshot(cdp, (snapshot) => snapshot.state === 1
		&& snapshot.readyCount >= expectedReadyCount + 1 && snapshot.instances === 2
		&& snapshot.sources === 8 && snapshot.playing >= 2,
		"restarted Love Web audio instance");
	assert.equal(restarted.audioFiles, initial.audioFiles, "AudioFile count changed after Love instance restart");
	assert.ok(restarted.voices >= 10 && restarted.voices <= initial.voices + 4,
		`SoLoud voices exceeded the restart lifecycle bound: ${JSON.stringify({initial, restarted})}`);

	assert.equal(await evaluate(cdp, "doraReleaseFirstLoveAudioProbe()"), true,
		"isolated Love Web audio cleanup failed");
	const isolated = await waitForSnapshot(cdp, (snapshot) => snapshot.state === 5
		&& snapshot.instances === 1 && snapshot.sources === 4 && snapshot.playing >= 1,
		"isolated Love Web audio cleanup");
	assert.equal(isolated.audioFiles, 3, "peer AudioFile resources changed after isolated cleanup");
	assert.ok(isolated.voices > 0 && isolated.voices < restarted.voices,
		"peer SoLoud voices were not isolated from first instance cleanup");

	const finalCleanup = await evaluate(cdp,
		"(async () => { const accepted = await doraReleaseLoveAudioProbe(); return {accepted, snapshot: doraLoveAudioSnapshot()}; })()");
	assert.equal(finalCleanup.accepted, true,
		`final Love Web audio cleanup failed: ${JSON.stringify(finalCleanup.snapshot)}`);
	const released = await waitForSnapshot(cdp, (snapshot) => snapshot.state === 2
		&& snapshot.instances === 0 && snapshot.sources === 0,
		"final Love Web audio cleanup");
	assert.equal(released.audioFiles, 0, "Love Web AudioFile resources survived cleanup");
	assert.equal(released.voices, 0, "Love Web SoLoud voices survived cleanup");
	return {initial, restarted, isolated, released};
}

const server = await startServer();
const profile = fs.mkdtempSync(path.join(os.tmpdir(), "dora-love-audio-chrome-"));
const chrome = spawn(chromeExecutable(), ["--headless=new", "--no-first-run", "--no-default-browser-check",
	"--disable-background-networking", "--enable-webgl", "--enable-unsafe-swiftshader", "--use-angle=swiftshader",
	"--remote-debugging-port=0", `--user-data-dir=${profile}`, "about:blank"],
	{stdio: ["ignore", "ignore", "pipe"]});
let chromeErrors = "";
chrome.stderr.on("data", (chunk) => { chromeErrors += chunk; });
let cdp;
try {
	const portFile = path.join(profile, "DevToolsActivePort");
	await waitForFile(portFile, 10000);
	const port = Number(fs.readFileSync(portFile, "utf8").split(/\r?\n/)[0]);
	const targets = await waitForJson(`http://127.0.0.1:${port}/json/list`, 10000);
	const target = targets.find((item) => item.type === "page");
	assert.ok(target?.webSocketDebuggerUrl, "Chrome page target was not created");
	cdp = new Cdp(target.webSocketDebuggerUrl);
	const pageErrors = [];
	const consoleMessages = [];
	cdp.onEvent((message) => {
		if (message.method === "Runtime.exceptionThrown") {
			const details = message.params.exceptionDetails;
			pageErrors.push(details?.exception?.description || details?.text || "browser exception");
		}
		if (message.method === "Runtime.consoleAPICalled") {
			const line = message.params.args.map((value) => value.value ?? value.description ?? "").join(" ");
			consoleMessages.push(line);
			if (message.params.type === "error") pageErrors.push(line);
			if (process.env.DORA_WEB_LOVE_TRACE) console.error(`[BROWSER] ${line}`);
		}
	});
	await Promise.all([cdp.send("Runtime.enable"), cdp.send("Page.enable"), cdp.send("HeapProfiler.enable")]);
	const version = await cdp.send("Browser.getVersion");
	const address = server.address();
	const url = `http://127.0.0.1:${address.port}/dora-love-audio-probe.html`;
	const lifecycleRuns = [];
	const reloadMemory = [];
	let soak = null;
	for (let run = 0; run <= reloadCount; run++) {
		if (run === 0) await cdp.send("Page.navigate", {url});
		else await cdp.send("Page.reload", {ignoreCache: true});
		await waitForSnapshot(cdp, (snapshot) => snapshot.readyCount >= 2
			&& snapshot.instances === 2 && snapshot.sources === 8,
			`Love Web audio run ${run + 1}`);
		await unlockAudio(cdp);
		await waitForSnapshot(cdp, (snapshot) => snapshot.audioContext === "running"
			&& snapshot.playing >= 2, `unlocked Love Web audio run ${run + 1}`);
		if (run === reloadCount) soak = await runSoak(cdp, soakSeconds, pageErrors);
		lifecycleRuns.push(await exerciseLifecycle(cdp, 2));
		reloadMemory.push(await memorySnapshot(cdp));
	}
	assert.deepEqual(pageErrors, [], `Love Web audio browser errors:\n${pageErrors.join("\n")}`);
	const createdMarkers = consoleMessages.filter((line) => line.includes("LOVE_WEB_AUDIO_CREATED")).length;
	const readyMarkers = consoleMessages.filter((line) => line.includes("LOVE_WEB_AUDIO_READY")).length;
	assert.equal(createdMarkers, (reloadCount + 1) * 3, "Love Web audio creation marker count changed");
	assert.equal(readyMarkers, (reloadCount + 1) * 3, "Love Web audio ready marker count changed");
	const firstMemory = reloadMemory[0];
	const lastMemory = reloadMemory.at(-1);
	assert.ok(lastMemory.documents <= firstMemory.documents + 1,
		`documents accumulated across Love Web audio reloads: ${JSON.stringify({firstMemory, lastMemory})}`);
	assert.ok(lastMemory.nodes <= firstMemory.nodes + 20,
		`DOM nodes accumulated across Love Web audio reloads: ${JSON.stringify({firstMemory, lastMemory})}`);
	assert.ok(lastMemory.listeners <= firstMemory.listeners + 5,
		`listeners accumulated across Love Web audio reloads: ${JSON.stringify({firstMemory, lastMemory})}`);
	assert.ok(lastMemory.jsHeapUsed <= firstMemory.jsHeapUsed + 8 * 1024 * 1024,
		`JS heap grew beyond Love Web audio reload allowance: ${JSON.stringify({firstMemory, lastMemory})}`);
	const report = {
		schemaVersion: 1,
		fixture: "love-audio-resource-lifecycle",
		browser: version,
		result: "passed",
		reloads: reloadCount,
		runs: reloadCount + 1,
		instanceRestarts: reloadCount + 1,
		isolatedCleanupPasses: reloadCount + 1,
		finalCleanupPasses: reloadCount + 1,
		reloadMemory: {first: firstMemory, last: lastMemory},
		soak,
		resourceSample: lifecycleRuns[0],
		coverage: ["WAV static Source", "OGG streaming Source", "SoundData Source", "Source clone",
			"play/pause/resume/seek/stop/loop/volume/pitch", "AudioContext user-gesture unlock",
			"two concurrent LoveNode instances", "instance restart", "isolated instance cleanup",
			"AudioFile and SoLoud voice cleanup", "reload DOM/listener/heap trend", "configurable long-run soak"],
	};
	fs.mkdirSync(path.dirname(reportPath), {recursive: true});
	fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`);
	console.log(`[INFO] Love Web audio lifecycle fixture passed in ${version.product} with ${reloadCount} reloads`);
	if (soak) console.log(`[INFO] Love Web audio soak passed for ${soak.durationSeconds.toFixed(3)} seconds with heap slope ${soak.heapSlopeBytesPerMinute.toFixed(1)} B/min`);
	console.log(`[INFO] Love Web audio report: ${reportPath}`);
} finally {
	await cdp?.close().catch(() => {});
	const chromeExit = new Promise((resolve) => chrome.once("exit", resolve));
	chrome.kill("SIGTERM"); server.close();
	await Promise.race([chromeExit, new Promise((resolve) => setTimeout(resolve, 2000))]);
	fs.rmSync(profile, {recursive: true, force: true, maxRetries: 10, retryDelay: 100});
}
