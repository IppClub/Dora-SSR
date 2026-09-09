import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import {spawn, spawnSync} from "node:child_process";

const artifactRoot = path.resolve(process.argv[2] || "build/web");
const reportPath = path.resolve(process.argv[3] || "build/web-love-runtime-report.json");
const reloadCount = Number(process.env.DORA_WEB_LOVE_RELOADS || 20);
assert.ok(Number.isInteger(reloadCount) && reloadCount >= 0 && reloadCount <= 100, "DORA_WEB_LOVE_RELOADS must be an integer from 0 to 100");

for (const artifact of ["dora-love-runtime-probe.html", "dora-love-runtime-probe.js", "dora-love-runtime-probe.wasm", "dora-love-runtime-probe.data"]) {
	assert.ok(fs.statSync(path.join(artifactRoot, artifact), {throwIfNoEntry: false})?.isFile(), `missing Love Web runtime artifact: ${artifact}`);
}

const nodeProbe = spawnSync(process.execPath, ["dora-love-runtime-probe.js"], {
	cwd: artifactRoot,
	encoding: "utf8",
	timeout: 30000,
});
assert.equal(nodeProbe.error, undefined, `Love Web Node fixture could not start: ${nodeProbe.error?.message}`);
assert.equal(nodeProbe.status, 0, `Love Web Node fixture failed:\n${nodeProbe.stdout}\n${nodeProbe.stderr}`);
assert.match(nodeProbe.stdout, /Dora Love runtime link probe passed/, `Love Web Node fixture did not report success:\n${nodeProbe.stdout}\n${nodeProbe.stderr}`);

function chromeExecutable() {
	const candidates = [
		process.env.DORA_WEB_CHROME,
		process.platform === "darwin" ? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" : undefined,
		"/usr/bin/google-chrome",
		"/usr/bin/google-chrome-stable",
		"/usr/bin/chromium",
		"/usr/bin/chromium-browser",
	].filter(Boolean);
	const executable = candidates.find((candidate) => fs.statSync(candidate, {throwIfNoEntry: false})?.isFile());
	if (!executable) throw new Error("Chrome/Chromium not found; set DORA_WEB_CHROME");
	return executable;
}

function removeProfile(directory) {
	try {
		fs.rmSync(directory, {recursive: true, force: true, maxRetries: 20, retryDelay: 100});
	} catch (error) {
		if (!["EBUSY", "ENOTEMPTY", "EPERM"].includes(error?.code)) throw error;
		console.warn(`[WARN] Chrome profile cleanup deferred: ${error.message}`);
	}
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
		if (requestPath === "/favicon.ico") {
			response.writeHead(204).end();
			return;
		}
		const relative = decodeURIComponent(requestPath === "/" ? "/dora-love-runtime-probe.html" : requestPath).replace(/^\/+/, "");
		const file = path.resolve(artifactRoot, relative);
		if (file !== artifactRoot && !file.startsWith(`${artifactRoot}${path.sep}`)) {
			response.writeHead(403).end();
			return;
		}
		const stat = fs.statSync(file, {throwIfNoEntry: false});
		if (!stat?.isFile()) {
			response.writeHead(404).end();
			return;
		}
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

	onEvent(listener) {
		this.listeners.add(listener);
		return () => this.listeners.delete(listener);
	}

	async close() {
		if (this.socket.readyState === WebSocket.CLOSED) return;
		await new Promise((resolve) => {
			const timeout = setTimeout(resolve, 1000);
			this.socket.addEventListener("close", () => {
				clearTimeout(timeout);
				resolve();
			}, {once: true});
			this.socket.close();
		});
	}
}

async function waitForProbe(cdp, pageErrors, chromeErrors) {
	const deadline = Date.now() + 15000;
	while (Date.now() < deadline) {
		const evaluation = await cdp.send("Runtime.evaluate", {expression: "globalThis.DoraLoveProbe || null", returnByValue: true});
		if (evaluation.result.value) {
			const probe = evaluation.result.value;
			assert.equal(probe.passed, true, `Love Web browser fixture failed: ${JSON.stringify(probe)}`);
			assert.equal(probe.error, "", `Love Web browser fixture reported an error: ${JSON.stringify(probe)}`);
			assert.ok(probe.incremental.steps > 2, `Love Web love.load did not span multiple slices: ${JSON.stringify(probe)}`);
			assert.ok(probe.incremental.heartbeats > 0, `browser event loop did not advance during Love Web love.load: ${JSON.stringify(probe)}`);
			return probe;
		}
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	throw new Error(`timed out waiting for Love Web browser fixture\npage errors: ${pageErrors.join("\n")}\nChrome: ${chromeErrors()}`);
}

const server = await startServer();
const address = server.address();
const profile = fs.mkdtempSync(path.join(os.tmpdir(), "dora-love-chrome-"));
const chrome = spawn(chromeExecutable(), [
	"--headless=new",
	"--no-first-run",
	"--no-default-browser-check",
	"--disable-background-networking",
	"--enable-webgl",
	"--enable-unsafe-swiftshader",
	"--use-angle=swiftshader",
	"--remote-debugging-port=0",
	`--user-data-dir=${profile}`,
	"about:blank",
], {stdio: ["ignore", "ignore", "pipe"]});
let chromeErrors = "";
chrome.stderr.on("data", (chunk) => { chromeErrors += chunk; });
let cdp;

try {
	const portFile = path.join(profile, "DevToolsActivePort");
	await waitForFile(portFile, 10000);
	const port = Number(fs.readFileSync(portFile, "utf8").split(/\r?\n/)[0]);
	const targets = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
	const target = targets.find((item) => item.type === "page");
	assert.ok(target?.webSocketDebuggerUrl, "Chrome page target was not created");
	cdp = new Cdp(target.webSocketDebuggerUrl);
	const pageErrors = [];
	cdp.onEvent((message) => {
		if (message.method === "Runtime.exceptionThrown") pageErrors.push(message.params.exceptionDetails.exception?.description || message.params.exceptionDetails.text);
		else if (message.method === "Log.entryAdded" && message.params.entry.level === "error") pageErrors.push(message.params.entry.text);
	});
	await Promise.all([cdp.send("Page.enable"), cdp.send("Runtime.enable"), cdp.send("Log.enable")]);
	const browserVersion = await cdp.send("Browser.getVersion");
	await cdp.send("Page.navigate", {url: `http://127.0.0.1:${address.port}/dora-love-runtime-probe.html`});
	let probe = await waitForProbe(cdp, pageErrors, () => chromeErrors);
	const incrementalRuns = [probe.incremental];
	for (let reload = 0; reload < reloadCount; reload++) {
		await cdp.send("Page.reload", {ignoreCache: true});
		await new Promise((resolve) => setTimeout(resolve, 25));
		probe = await waitForProbe(cdp, pageErrors, () => chromeErrors);
		incrementalRuns.push(probe.incremental);
	}
	assert.deepEqual(pageErrors, [], `Love Web browser fixture emitted errors:\n${pageErrors.join("\n")}`);
	const report = {
		schemaVersion: 1,
		browser: {
			product: browserVersion.product,
			protocolVersion: browserVersion.protocolVersion,
			userAgent: browserVersion.userAgent,
			jsVersion: browserVersion.jsVersion,
		},
		reloads: reloadCount,
		result: "passed",
		incrementalLoad: {
			runs: incrementalRuns.length,
			minimumSteps: Math.min(...incrementalRuns.map((run) => run.steps)),
			minimumHeartbeats: Math.min(...incrementalRuns.map((run) => run.heartbeats)),
			maximumDurationMs: Math.max(...incrementalRuns.map((run) => run.durationMs)),
		},
		coverage: ["LoveRuntime open/configure/start/update/draw/stop/close", "incremental love.load instruction budget", "love.bootYield explicit yield", "browser event-loop heartbeat during load", "incremental failure traceback and pending-close cleanup", "Lua callbacks", "ImageData pixels", "default TrueType font rasterizer", "keyboard/mouse/touch events", "math random generator", "data SHA-256"],
	};
	fs.mkdirSync(path.dirname(reportPath), {recursive: true});
	fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`);
	console.log("[INFO] Love Web Node runtime fixture passed");
	console.log(`[INFO] Love Web browser runtime fixture passed in ${browserVersion.product} with ${reloadCount} reloads`);
	console.log(`[INFO] Love Web runtime report: ${reportPath}`);
} finally {
	if (cdp) await cdp.close();
	server.close();
	server.closeAllConnections();
	if (chrome.exitCode === null) {
		chrome.kill("SIGTERM");
		const exited = await new Promise((resolve) => {
			const onExit = () => {
				clearTimeout(timeout);
				resolve(true);
			};
			const timeout = setTimeout(() => {
				chrome.off("exit", onExit);
				resolve(false);
			}, 2000);
			chrome.once("exit", onExit);
		});
		if (!exited && chrome.exitCode === null) chrome.kill("SIGKILL");
	}
	chrome.stderr.destroy();
	removeProfile(profile);
}
