import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import {spawn} from "node:child_process";

const roots = process.argv.slice(2).map((item) => path.resolve(item));
if (roots.length === 0) throw new Error("usage: check_web_game_smoke.mjs <player-dir> [...]");
for (const root of roots) {
	assert.ok(fs.statSync(path.join(root, "index.html"), {throwIfNoEntry: false})?.isFile(), `Web Player is missing: ${root}`);
	const manifest = JSON.parse(fs.readFileSync(path.join(root, "dora-web-manifest.json"), "utf8"));
	assert.equal(manifest.profile, "dora-preset", `${root} does not use the default Dora preset`);
}

function chromeExecutable() {
	const candidates = [
		process.env.DORA_WEB_CHROME,
		process.platform === "darwin" ? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" : undefined,
		"/usr/bin/google-chrome",
		"/usr/bin/google-chrome-stable",
		"/usr/bin/chromium",
	].filter(Boolean);
	const executable = candidates.find((item) => fs.statSync(item, {throwIfNoEntry: false})?.isFile());
	if (!executable) throw new Error("Chrome/Chromium not found; set DORA_WEB_CHROME");
	return executable;
}

function contentType(filename) {
	switch (path.extname(filename)) {
		case ".html": return "text/html; charset=utf-8";
		case ".js": return "text/javascript; charset=utf-8";
		case ".json": return "application/json; charset=utf-8";
		case ".wasm": return "application/wasm";
		case ".png": return "image/png";
		default: return "application/octet-stream";
	}
}

const server = http.createServer((request, response) => {
	const url = new URL(request.url, "http://localhost");
	if (url.pathname === "/favicon.ico") {
		response.writeHead(204).end();
		return;
	}
	const parts = decodeURIComponent(url.pathname).split("/").filter(Boolean);
	const rootIndex = Number(parts.shift());
	if (!Number.isInteger(rootIndex) || rootIndex < 0 || rootIndex >= roots.length) {
		response.writeHead(404).end();
		return;
	}
	const relative = parts.length === 0 ? "index.html" : parts.join("/");
	const filename = path.resolve(roots[rootIndex], relative);
	if (!filename.startsWith(`${roots[rootIndex]}${path.sep}`)) {
		response.writeHead(403).end();
		return;
	}
	const stat = fs.statSync(filename, {throwIfNoEntry: false});
	if (!stat?.isFile()) {
		response.writeHead(404).end();
		return;
	}
	response.writeHead(200, {"Content-Type": contentType(filename), "Content-Length": stat.size});
	fs.createReadStream(filename).pipe(response);
});
await new Promise((resolve, reject) => {
	server.once("error", reject);
	server.listen(0, "127.0.0.1", resolve);
});

async function waitForFile(filename, timeoutMs) {
	const deadline = Date.now() + timeoutMs;
	while (Date.now() < deadline) {
		if (fs.statSync(filename, {throwIfNoEntry: false})?.isFile()) return;
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	throw new Error(`timed out waiting for ${filename}`);
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
			} else {
				for (const listener of this.listeners) listener(message);
			}
		});
	}
	async send(method, params = {}) {
		await this.ready;
		const id = this.nextId++;
		const result = new Promise((resolve, reject) => this.pending.set(id, {resolve, reject}));
		this.socket.send(JSON.stringify({id, method, params}));
		return result;
	}
	onEvent(listener) { this.listeners.add(listener); }
	close() { this.socket.close(); }
}

const profile = fs.mkdtempSync(path.join(os.tmpdir(), "dora-web-game-smoke-"));
const chrome = spawn(chromeExecutable(), [
	"--headless=new", "--no-first-run", "--no-default-browser-check", "--disable-background-networking",
	"--enable-webgl", "--enable-unsafe-swiftshader", "--use-angle=swiftshader", "--remote-debugging-port=0",
	`--user-data-dir=${profile}`, "about:blank",
], {stdio: ["ignore", "ignore", "pipe"]});
let chromeErrors = "";
chrome.stderr.on("data", (chunk) => { chromeErrors += chunk; });

try {
	const portFile = path.join(profile, "DevToolsActivePort");
	await waitForFile(portFile, 10000);
	const port = Number(fs.readFileSync(portFile, "utf8").split(/\r?\n/)[0]);
	const targets = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
	const target = targets.find((item) => item.type === "page");
	assert.ok(target?.webSocketDebuggerUrl, "Chrome page target was not created");
	const cdp = new Cdp(target.webSocketDebuggerUrl);
	let pageErrors = [];
	let pageLogs = [];
	cdp.onEvent((message) => {
		if (message.method === "Runtime.exceptionThrown") {
			pageErrors.push(message.params.exceptionDetails.exception?.description ?? message.params.exceptionDetails.text);
		}
		if (message.method === "Log.entryAdded" && message.params.entry.level === "error") pageErrors.push(message.params.entry.text);
		if (message.method === "Runtime.consoleAPICalled" && message.params.type === "error") {
			pageErrors.push(message.params.args.map((arg) => arg.value ?? arg.description ?? "").join(" "));
		}
		if (message.method === "Runtime.consoleAPICalled") {
			pageLogs.push(message.params.args.map((arg) => arg.value ?? arg.description ?? "").join(" "));
		}
	});
	await Promise.all([cdp.send("Page.enable"), cdp.send("Runtime.enable"), cdp.send("Log.enable")]);
	for (let index = 0; index < roots.length; index++) {
		pageErrors = [];
		pageLogs = [];
		await cdp.send("Page.navigate", {url: `http://127.0.0.1:${server.address().port}/${index}/`});
		const deadline = Date.now() + 20000;
		let state = "booting";
		while (Date.now() < deadline) {
			await new Promise((resolve) => setTimeout(resolve, 100));
			const result = await cdp.send("Runtime.evaluate", {expression: "document.documentElement.dataset.doraState", returnByValue: true});
			state = result.result.value;
			if (state === "running" || state === "faulted") break;
		}
		assert.equal(state, "running", `${path.basename(roots[index])} failed to start:\n${pageErrors.join("\n")}\n${chromeErrors}`);
		await new Promise((resolve) => setTimeout(resolve, 1500));
		const heartbeat = await cdp.send("Runtime.evaluate", {expression: "document.documentElement.dataset.doraState", returnByValue: true});
		assert.equal(heartbeat.result.value, "running", `${path.basename(roots[index])} stopped after startup:\n${pageErrors.join("\n")}`);
		assert.deepEqual(pageErrors, [], `${path.basename(roots[index])} emitted browser errors`);
		if (process.env.DORA_WEB_SMOKE_SCREENSHOT_DIR) {
			const screenshot = await cdp.send("Page.captureScreenshot", {format: "png", captureBeyondViewport: false});
			const screenshotDirectory = path.resolve(process.env.DORA_WEB_SMOKE_SCREENSHOT_DIR);
			fs.mkdirSync(screenshotDirectory, {recursive: true});
			fs.writeFileSync(path.join(screenshotDirectory, `${path.basename(roots[index])}.png`), screenshot.data, "base64");
		}
		if (process.env.DORA_WEB_SMOKE_LOG === "1") {
			for (const message of pageLogs) console.log(`[BROWSER] ${message}`);
		}
		console.log(`[INFO] ${path.basename(roots[index])} entered and remained in the running state`);
	}
	cdp.close();
} finally {
	server.close();
	server.closeAllConnections();
	if (chrome.exitCode === null) {
		chrome.kill("SIGTERM");
		await new Promise((resolve) => {
			const timeout = setTimeout(resolve, 2000);
			chrome.once("exit", () => {
				clearTimeout(timeout);
				resolve();
			});
		});
	}
	fs.rmSync(profile, {recursive: true, force: true});
}
