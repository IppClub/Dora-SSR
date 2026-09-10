import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import {spawn} from "node:child_process";

const galleryMode = process.argv[2] === '--gallery';
const roots = process.argv.slice(galleryMode ? 3 : 2).map((item) => path.resolve(item));
if (roots.length === 0) throw new Error("usage: check_web_game_smoke.mjs <player-dir> [...]");
for (const root of roots) {
	if (galleryMode) continue;
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
	let filename = path.resolve(roots[rootIndex], relative);
	if (!filename.startsWith(`${roots[rootIndex]}${path.sep}`)) {
		response.writeHead(403).end();
		return;
	}
	if (fs.statSync(filename, {throwIfNoEntry: false})?.isDirectory()) filename = path.join(filename, 'index.html');
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
		if (message.method === "Log.entryAdded" && message.params.entry.level === "error") pageErrors.push(`${message.params.entry.url || ''}: ${message.params.entry.text}`);
		if (message.method === "Runtime.consoleAPICalled" && message.params.type === "error") {
			pageErrors.push(message.params.args.map((arg) => arg.value ?? arg.description ?? "").join(" "));
		}
		if (message.method === "Runtime.consoleAPICalled") {
			pageLogs.push(message.params.args.map((arg) => arg.value ?? arg.description ?? "").join(" "));
		}
	});
	await Promise.all([cdp.send("Page.enable"), cdp.send("Runtime.enable"), cdp.send("Log.enable")]);
	await cdp.send('Emulation.setDeviceMetricsOverride', {width: 1280, height: 1100, deviceScaleFactor: 1, mobile: false});
	const cases = galleryMode ? JSON.parse(fs.readFileSync(path.join(roots[0], 'catalog.json'))).games.map(game => {
		const catalog = JSON.parse(fs.readFileSync(path.join(roots[0], 'catalog.json')));
		return {name: game.id, url: `${process.env.DORA_WEB_GALLERY_URL || `http://127.0.0.1:${server.address().port}/0/`}${catalog.player}?game=${game.id}`};
	}) : roots.map((root, index) => ({name: path.basename(root), url: `http://127.0.0.1:${server.address().port}/${index}/`}));
	for (const {name, url} of cases.filter(item => !process.env.DORA_WEB_SMOKE_GAME || item.name === process.env.DORA_WEB_SMOKE_GAME)) {
		pageErrors = [];
		pageLogs = [];
		const galleryPage = galleryMode && process.env.DORA_WEB_GALLERY_PAGE;
		await cdp.send("Page.navigate", {url: galleryPage || url});
		if (galleryPage) {
			const title = JSON.parse(fs.readFileSync(path.join(roots[0], 'catalog.json'))).games.find(game => game.id === name).title;
			const ready = Date.now() + 15000;
			let clicked = false;
			while (Date.now() < ready) {
				const result = await cdp.send('Runtime.evaluate', {expression: `(() => {const article = [...document.querySelectorAll('article')].find(item => item.querySelector('h2')?.textContent === ${JSON.stringify(title)}); if (!article) return false; article.querySelector('button').click(); return true;})()`, returnByValue: true});
				if (result.result.value) {clicked = true; break;}
				await new Promise(resolve => setTimeout(resolve, 100));
			}
			assert.ok(clicked, `Missing gallery card: ${title}`);
		}
		const stateExpression = galleryPage ? "document.querySelector('iframe')?.contentDocument?.documentElement.dataset.doraState" : "document.documentElement.dataset.doraState";
		const deadline = Date.now() + 20000;
		let state = "booting";
		while (Date.now() < deadline) {
			await new Promise((resolve) => setTimeout(resolve, 100));
			const result = await cdp.send("Runtime.evaluate", {expression: stateExpression, returnByValue: true});
			state = result.result.value;
			if (state === "running" || state === "faulted") break;
		}
		const detail = await cdp.send('Runtime.evaluate', {expression: galleryPage ? "document.querySelector('iframe')?.contentDocument?.getElementById('status')?.textContent" : "document.getElementById('status')?.textContent", returnByValue: true});
		assert.equal(state, "running", `${name} failed to start: ${detail.result.value}\n${pageErrors.join("\n")}\n${pageLogs.join('\n')}`);
		if (galleryPage) {
			const fullscreenCalls = await cdp.send('Runtime.evaluate', {expression: `(() => {const w = document.querySelector('iframe').contentWindow; const c = w.document.querySelector('canvas'); const original = c.requestFullscreen; let calls = 0; c.requestFullscreen = () => {calls++; return Promise.resolve();}; c.dispatchEvent(new w.MouseEvent('dblclick', {bubbles:true})); c.requestFullscreen = original; return calls;})()`, returnByValue:true});
			assert.equal(fullscreenCalls.result.value, 0, 'Double-clicking the game must not request fullscreen');
		}
		if (name === 'ai-fighter' && process.env.DORA_WEB_TEST_AI === '1') {
			const rect = await cdp.send('Runtime.evaluate', {expression: `(() => {const r = document.querySelector('iframe').getBoundingClientRect(); return {x:r.x,y:r.y,width:r.width,height:r.height};})()`, returnByValue:true});
			const r = rect.result.value;
			const click = async (x,y) => {
				await cdp.send('Input.dispatchMouseEvent', {type:'mouseMoved', x,y});
				await cdp.send('Input.dispatchMouseEvent', {type:'mousePressed', x,y,button:'left',clickCount:1});
				await new Promise(resolve => setTimeout(resolve, 100));
				await cdp.send('Input.dispatchMouseEvent', {type:'mouseReleased', x,y,button:'left',clickCount:1});
			};
			await click(r.x+r.width/2-250, r.y+r.height/2);
			await new Promise(resolve => setTimeout(resolve, 500));
			const shot = await cdp.send('Page.captureScreenshot', {format:'png'});
			fs.mkdirSync('build/ai-input', {recursive:true});
			fs.writeFileSync('build/ai-input/equipment.png', shot.data, 'base64');
			await click(r.x+r.width/2-112, r.y+r.height/2+222);
			await new Promise(resolve => setTimeout(resolve, 700));
			const capture = async label => {
				const result = await cdp.send('Page.captureScreenshot', {format:'png'});
				fs.writeFileSync(`build/ai-input/${label}.png`, result.data, 'base64');
			};
			await capture('training');
			await cdp.send('Input.dispatchKeyEvent', {type:'keyDown', key:'d', code:'KeyD', windowsVirtualKeyCode:68});
			await new Promise(resolve => setTimeout(resolve, 600));
			await capture('keyboard-right');
			await cdp.send('Input.dispatchKeyEvent', {type:'keyUp', key:'d', code:'KeyD', windowsVirtualKeyCode:68});
			await cdp.send('Input.dispatchMouseEvent', {type:'mouseMoved', x:r.x+40,y:r.y+r.height-70});
			await cdp.send('Input.dispatchMouseEvent', {type:'mousePressed', x:r.x+40,y:r.y+r.height-70,button:'left',clickCount:1});
			await new Promise(resolve => setTimeout(resolve, 1200));
			await capture('virtual-left');
			await cdp.send('Input.dispatchMouseEvent', {type:'mouseReleased', x:r.x+40,y:r.y+r.height-70,button:'left',clickCount:1});
		}
		if (name === 'dodge-the-creeps' && process.env.DORA_WEB_TEST_DODGE === '1') {
			const rect = await cdp.send('Runtime.evaluate', {expression: `(() => {const r = document.querySelector('iframe').getBoundingClientRect(); return {x:r.x+r.width/2,y:r.y+r.height*(0.5+150/700)};})()`, returnByValue: true});
			await cdp.send('Input.dispatchMouseEvent', {type:'mousePressed', ...rect.result.value, button:'left', clickCount:1});
			await cdp.send('Input.dispatchMouseEvent', {type:'mouseReleased', ...rect.result.value, button:'left', clickCount:1});
			const focusStyle = await cdp.send('Runtime.evaluate', {expression: `(() => {const w = document.querySelector('iframe').contentWindow; const canvas = w.document.querySelector('canvas'); return {focused:w.document.activeElement === canvas, color:w.getComputedStyle(canvas).outlineColor};})()`, returnByValue:true});
			assert.deepEqual(focusStyle.result.value, {focused:true, color:'rgba(176, 176, 176, 0.35)'}, 'Game focus ring must use translucent gray');
			await new Promise(resolve => setTimeout(resolve, 300));
			await cdp.send('Input.dispatchKeyEvent', {type:'keyDown', key:'d', code:'KeyD', windowsVirtualKeyCode:68});
			await new Promise(resolve => setTimeout(resolve, 250));
			await cdp.send('Input.dispatchKeyEvent', {type:'keyUp', key:'d', code:'KeyD', windowsVirtualKeyCode:68});
			await new Promise(resolve => setTimeout(resolve, 1500));
			if (process.env.DORA_WEB_SMOKE_SCREENSHOT_DIR) {
				const shot = await cdp.send('Page.captureScreenshot', {format:'png'});
				fs.mkdirSync(process.env.DORA_WEB_SMOKE_SCREENSHOT_DIR, {recursive:true});
				fs.writeFileSync(path.join(process.env.DORA_WEB_SMOKE_SCREENSHOT_DIR, 'dodge-gameplay.png'), shot.data, 'base64');
			}
		}
		await new Promise((resolve) => setTimeout(resolve, 1500));
		const heartbeat = await cdp.send("Runtime.evaluate", {expression: stateExpression, returnByValue: true});
		assert.equal(heartbeat.result.value, "running", `${name} stopped after startup:\n${pageErrors.join("\n")}`);
		assert.deepEqual(pageErrors, [], `${name} emitted browser errors`);
		assert.ok(!pageLogs.some(message => /stack traceback|Missing End\(|\[error\]/i.test(message)), `${name} script errors:\n${pageLogs.join('\n')}`);
		if (name === 'web-api-contract') assert.ok(pageLogs.some(message => message.includes('DORA_WEB_API_CONTRACT_PASSED')), 'API contract did not finish');
		if (galleryPage) {
			const saved = await cdp.send('Runtime.evaluate', {expression: `(async () => {
				const m = document.querySelector('iframe').contentWindow.Module;
				const file = '/user/saves/gallery-smoke.txt';
				if (m.FS.analyzePath(file).exists) throw Error('Another game save leaked into ${name}');
				m.FS.writeFile(file, ${JSON.stringify(name)});
				await m.doraSyncUserStorage();
				return m.FS.readlink('/user');
			})()`, awaitPromise: true, returnByValue: true});
			assert.equal(saved.result.value, `/dora-saves/${name}`, `${name} isolated storage failed: ${JSON.stringify(saved.exceptionDetails)}`);
			await cdp.send('Runtime.evaluate', {expression: `document.querySelector('section button').click()`});
			const restartDeadline = Date.now() + 20000;
			let restored;
			while (Date.now() < restartDeadline) {
				await new Promise(resolve => setTimeout(resolve, 100));
				const result = await cdp.send('Runtime.evaluate', {expression: `(() => {const w = document.querySelector('iframe')?.contentWindow; if (w?.document.documentElement.dataset.doraState !== 'running') return null; return w.Module.FS.readFile('/user/saves/gallery-smoke.txt', {encoding:'utf8'});})()`, returnByValue: true});
				restored = result.result.value;
				if (restored === name) break;
			}
			assert.equal(restored, name, `${name} save did not survive restart`);
			assert.deepEqual(pageErrors, [], `${name} restart emitted browser errors`);
			console.log(`[INFO] ${name} isolated save and restart passed`);
		}
		if (process.env.DORA_WEB_SMOKE_SCREENSHOT_DIR) {
			const screenshot = await cdp.send("Page.captureScreenshot", {format: "png", captureBeyondViewport: false});
			const screenshotDirectory = path.resolve(process.env.DORA_WEB_SMOKE_SCREENSHOT_DIR);
			fs.mkdirSync(screenshotDirectory, {recursive: true});
			fs.writeFileSync(path.join(screenshotDirectory, `${name}.png`), screenshot.data, "base64");
		}
		if (process.env.DORA_WEB_SMOKE_LOG === "1") {
			for (const message of pageLogs) console.log(`[BROWSER] ${message}`);
		}
		console.log(`[INFO] ${name} entered and remained in the running state`);
		if (galleryPage) {
			const closed = await cdp.send('Runtime.evaluate', {expression: `(() => {const buttons = document.querySelectorAll('section button'); buttons[buttons.length - 1].click(); return true;})()`, returnByValue: true});
			assert.equal(closed.result.value, true);
			await new Promise(resolve => setTimeout(resolve, 100));
			const frameCount = await cdp.send('Runtime.evaluate', {expression: `document.querySelectorAll('iframe').length`, returnByValue: true});
			assert.equal(frameCount.result.value, 0, 'Close must destroy the game iframe');
		}
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
