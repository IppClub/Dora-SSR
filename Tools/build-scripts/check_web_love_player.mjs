import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import {spawn} from "node:child_process";

const artifactRoot = path.resolve(process.argv[2] || "result/love-pthread-player");

function crc32(bytes) {
	let value = 0xffffffff;
	for (const byte of bytes) {
		value ^= byte;
		for (let bit = 0; bit < 8; bit++) value = (value >>> 1) ^ ((value & 1) ? 0xedb88320 : 0);
	}
	return (value ^ 0xffffffff) >>> 0;
}

function zip(entries) {
	const localParts = [], centralParts = [];
	let localOffset = 0;
	for (const [file, source] of Object.entries(entries)) {
		const name = Buffer.from(file), data = Buffer.from(source), checksum = crc32(data);
		const local = Buffer.alloc(30);
		local.writeUInt32LE(0x04034b50, 0); local.writeUInt16LE(20, 4); local.writeUInt16LE(0x800, 6);
		local.writeUInt32LE(checksum, 14); local.writeUInt32LE(data.length, 18); local.writeUInt32LE(data.length, 22);
		local.writeUInt16LE(name.length, 26);
		localParts.push(local, name, data);
		const central = Buffer.alloc(46);
		central.writeUInt32LE(0x02014b50, 0); central.writeUInt16LE(20, 4); central.writeUInt16LE(20, 6);
		central.writeUInt16LE(0x800, 8); central.writeUInt32LE(checksum, 16);
		central.writeUInt32LE(data.length, 20); central.writeUInt32LE(data.length, 24);
		central.writeUInt16LE(name.length, 28); central.writeUInt32LE(localOffset, 42);
		centralParts.push(central, name);
		localOffset += local.length + name.length + data.length;
	}
	const directory = Buffer.concat(centralParts), end = Buffer.alloc(22), count = Object.keys(entries).length;
	end.writeUInt32LE(0x06054b50, 0); end.writeUInt16LE(count, 8); end.writeUInt16LE(count, 10);
	end.writeUInt32LE(directory.length, 12); end.writeUInt32LE(localOffset, 16);
	return Buffer.concat([...localParts, directory, end]);
}

function chromeExecutable() {
	const candidates = [process.env.DORA_WEB_CHROME,
		process.platform === "darwin" ? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" : undefined,
		"/usr/bin/google-chrome", "/usr/bin/google-chrome-stable", "/usr/bin/chromium"].filter(Boolean);
	const executable = candidates.find((candidate) => fs.statSync(candidate, {throwIfNoEntry: false})?.isFile());
	if (!executable) throw new Error("Chrome/Chromium not found; set DORA_WEB_CHROME");
	return executable;
}

function mimeType(file) {
	return ({".html": "text/html; charset=utf-8", ".js": "text/javascript; charset=utf-8",
		".wasm": "application/wasm", ".data": "application/octet-stream"})[path.extname(file)] || "application/octet-stream";
}

const server = http.createServer((request, response) => {
	const pathname = new URL(request.url, "http://localhost").pathname;
	const relative = decodeURIComponent(pathname === "/" ? "/index.html" : pathname).replace(/^\/+/, "");
	const file = path.resolve(artifactRoot, relative);
	if (file !== artifactRoot && !file.startsWith(`${artifactRoot}${path.sep}`)) return response.writeHead(403).end();
	const stat = fs.statSync(file, {throwIfNoEntry: false});
	if (!stat?.isFile()) return response.writeHead(404).end();
	response.writeHead(200, {"Content-Type": mimeType(file), "Cache-Control": "no-store",
		"Cross-Origin-Opener-Policy": "same-origin", "Cross-Origin-Embedder-Policy": "require-corp",
		"Cross-Origin-Resource-Policy": "same-origin"});
	fs.createReadStream(file).pipe(response);
});
await new Promise((resolve, reject) => { server.once("error", reject); server.listen(0, "127.0.0.1", resolve); });

class Cdp {
	constructor(url) {
		this.id = 0; this.pending = new Map(); this.socket = new WebSocket(url);
		this.ready = new Promise((resolve, reject) => {
			this.socket.addEventListener("open", resolve, {once: true});
			this.socket.addEventListener("error", reject, {once: true});
		});
		this.socket.addEventListener("message", (event) => {
			const message = JSON.parse(event.data), pending = this.pending.get(message.id);
			if (!pending) return;
			this.pending.delete(message.id);
			message.error ? pending.reject(new Error(message.error.message)) : pending.resolve(message.result);
		});
	}
	async send(method, params = {}) {
		await this.ready;
		const id = ++this.id, result = new Promise((resolve, reject) => this.pending.set(id, {resolve, reject}));
		this.socket.send(JSON.stringify({id, method, params}));
		return result;
	}
	close() { this.socket.close(); }
}

async function waitFor(read, predicate, label, timeoutMs = 120000) {
	const deadline = Date.now() + timeoutMs;
	let lastValue;
	while (Date.now() < deadline) {
		const value = lastValue = await read();
		if (predicate(value)) return value;
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	throw new Error(`timed out waiting for ${label}: ${JSON.stringify(lastValue)}`);
}

const profile = fs.mkdtempSync(path.join(os.tmpdir(), "dora-love-player-"));
const chrome = spawn(chromeExecutable(), ["--headless=new", "--no-sandbox", "--disable-gpu-sandbox",
	"--no-first-run", "--no-default-browser-check", "--disable-background-networking", "--enable-webgl",
	"--enable-unsafe-swiftshader", "--use-angle=swiftshader",
	"--remote-debugging-port=0", `--user-data-dir=${profile}`, `http://127.0.0.1:${server.address().port}/`],
	{stdio: "ignore"});
let cdp;
try {
	const portFile = path.join(profile, "DevToolsActivePort");
	const debugPort = await waitFor(() => Promise.resolve(fs.statSync(portFile, {throwIfNoEntry: false})?.isFile()
		? Number(fs.readFileSync(portFile, "utf8").split(/\r?\n/)[0]) : 0), (value) => value > 0, "DevTools port", 30000);
	const targets = await waitFor(async () => fetch(`http://127.0.0.1:${debugPort}/json/list`).then((response) => response.json()),
		(value) => value.some((target) => target.type === "page"), "browser page", 30000);
	cdp = new Cdp(targets.find((target) => target.type === "page").webSocketDebuggerUrl);
	await cdp.send("Runtime.enable");
	const evaluate = async (expression) => {
		const result = await cdp.send("Runtime.evaluate", {expression, awaitPromise: true, returnByValue: true});
		if (result.exceptionDetails) throw new Error(result.exceptionDetails.exception?.description || result.exceptionDetails.text);
		return result.result.value;
	};
	await waitFor(() => evaluate("typeof DoraLovePthreadPlayer !== 'undefined' && Boolean(DoraLovePthreadPlayer.state.ready)"), Boolean, "player readiness");
	const fixture = zip({
		"conf.lua": "function love.conf(t) t.window.width=160 t.window.height=90 t.window.resizable=false t.modules.audio=false t.modules.video=false t.modules.thread=false t.modules.physics=false end",
		"main.lua": "function love.load() love.graphics.setBackgroundColor(0.05,0.08,0.12) end function love.draw() love.graphics.setColor(0.2,0.9,0.45) love.graphics.rectangle('fill',32,20,96,50) end"
	});
	const encoded = fixture.toString("base64");
	assert.equal(await evaluate(`(async()=>{const bytes=Uint8Array.from(atob(${JSON.stringify(encoded)}),c=>c.charCodeAt(0));return DoraLovePthreadPlayer.importPackage(new File([bytes],'ci-love-fixture.dora'));})()`), true);
	const running = await waitFor(() => evaluate(`({running:DoraLovePthreadPlayer.state.running,status:Module.ccall('dora_web_love_player_status','number',[],[]),isolated:crossOriginIsolated,storage:Module.doraStorageState,project:Module.UTF8ToString(Module.ccall('dora_web_love_player_project','number',[],[])),error:Module.UTF8ToString(Module.ccall('dora_web_love_player_error','number',[],[])),message:document.getElementById('player-status').textContent})`),
		(value) => {
			if (value.status < 0) throw new Error(`Love project failed: ${value.error || value.message}`);
			return value.running && value.status === 1;
		}, "Love project startup", 30000);
	assert.equal(running.isolated, true); assert.equal(running.storage, "ready");
	assert.match(running.project, /^\/user\/projects\/ci-love-fixture-[0-9a-f]{16}\/main\.lua$/);
	assert.equal(await evaluate("DoraLovePthreadPlayer.stopProject()"), true);
	const stopped = await waitFor(() => evaluate(`({running:DoraLovePthreadPlayer.state.running,status:document.getElementById('player-status').textContent})`),
		(value) => !value.running && /synchronized/.test(value.status), "Love project stop");
	assert.match(stopped.status, /synchronized/);
	assert.equal(await evaluate("DoraLovePthreadPlayer.startProject({id:'missing-project',name:'Missing project'})"), true);
	const recovered = await waitFor(() => evaluate(`({busy:DoraLovePthreadPlayer.state.busy,running:DoraLovePthreadPlayer.state.running,message:document.getElementById('player-status').textContent,faulted:document.getElementById('player-status').dataset.faulted})`),
		(value) => !value.busy && !value.running && value.faulted === "true", "failed project cleanup");
	assert.match(recovered.message, /does not exist/i);
	assert.equal(await evaluate("DoraLovePthreadPlayer.startProject(DoraLovePthreadPlayer.state.projects[0])"), true);
	await waitFor(() => evaluate("DoraLovePthreadPlayer.state.running"), Boolean, "project restart after failure");
	assert.equal(await evaluate("DoraLovePthreadPlayer.stopProject()"), true);
	console.log(`[INFO] Love pthread Player browser import/start/stop passed: ${running.project}`);
} finally {
	cdp?.close(); chrome.kill("SIGTERM"); server.close(); fs.rmSync(profile, {recursive: true, force: true});
}
