import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import {spawn} from "node:child_process";

const artifactRoot = path.resolve(process.argv[2] || "build/web");
const reportPath = path.resolve(process.argv[3] || "build/web-love-complex-report.json");
const screenshotPath = path.resolve(process.argv[4] || "build/web-love-complex.png");
const observationMs = Number(process.env.DORA_WEB_LOVE_COMPLEX_OBSERVATION_MS || 10000);
const flowWaitMs = Number(process.env.DORA_WEB_LOVE_COMPLEX_FLOW_WAIT_MS || 8000);
const reloadCount = Number(process.env.DORA_WEB_LOVE_COMPLEX_RELOADS || 0);
const soakSeconds = Number(process.env.DORA_WEB_LOVE_COMPLEX_SOAK_SECONDS || 0);
const flow = process.env.DORA_WEB_LOVE_COMPLEX_FLOW || "boot";
const pthreadProfile = process.env.DORA_WEB_PTHREADS === "1";
assert.ok(Number.isInteger(observationMs) && observationMs >= 0 && observationMs <= 120000,
	"DORA_WEB_LOVE_COMPLEX_OBSERVATION_MS must be an integer from 0 to 120000");
assert.ok(Number.isInteger(flowWaitMs) && flowWaitMs >= 0 && flowWaitMs <= 120000,
	"DORA_WEB_LOVE_COMPLEX_FLOW_WAIT_MS must be an integer from 0 to 120000");
assert.ok(Number.isInteger(reloadCount) && reloadCount >= 0 && reloadCount <= 100,
	"DORA_WEB_LOVE_COMPLEX_RELOADS must be an integer from 0 to 100");
assert.ok(Number.isInteger(soakSeconds) && soakSeconds >= 0 && soakSeconds <= 7200,
	"DORA_WEB_LOVE_COMPLEX_SOAK_SECONDS must be an integer from 0 to 7200");
assert.ok(["boot", "pointer-start", "play-round", "full-game", "keyboard-start"].includes(flow),
	"DORA_WEB_LOVE_COMPLEX_FLOW must be boot, pointer-start, play-round, full-game, or keyboard-start");
for (const extension of ["html", "js", "wasm", "data"])
	assert.ok(fs.statSync(path.join(artifactRoot, `dora-love-complex-probe.${extension}`),
		{throwIfNoEntry: false})?.isFile(), `missing Love Web complex-project ${extension} artifact`);

function chromeExecutable() {
	const candidates = [process.env.DORA_WEB_CHROME,
		process.platform === "darwin" ? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" : undefined,
		"/usr/bin/google-chrome", "/usr/bin/google-chrome-stable", "/usr/bin/chromium"].filter(Boolean);
	const executable = candidates.find((candidate) => fs.statSync(candidate, {throwIfNoEntry: false})?.isFile());
	if (!executable) throw new Error("Chrome/Chromium not found; set DORA_WEB_CHROME");
	return executable;
}

function mimeType(file) {
	switch (path.extname(file)) {
		case ".html": return "text/html; charset=utf-8";
		case ".js": return "text/javascript; charset=utf-8";
		case ".wasm": return "application/wasm";
		case ".data": return "application/octet-stream";
		default: return "application/octet-stream";
	}
}

function startServer() {
	const server = http.createServer((request, response) => {
		const requestPath = new URL(request.url, "http://localhost").pathname;
		if (requestPath === "/favicon.ico") return response.writeHead(204).end();
		const relative = decodeURIComponent(requestPath === "/" ? "/dora-love-complex-probe.html" : requestPath)
			.replace(/^\/+/, "");
		const file = path.resolve(artifactRoot, relative);
		if (file !== artifactRoot && !file.startsWith(`${artifactRoot}${path.sep}`)) return response.writeHead(403).end();
		const stat = fs.statSync(file, {throwIfNoEntry: false});
		if (!stat?.isFile()) return response.writeHead(404).end();
		response.writeHead(200, {
			"Cache-Control": "no-store",
			"Content-Length": stat.size,
			"Content-Type": mimeType(file),
			"Cross-Origin-Opener-Policy": "same-origin",
			"Cross-Origin-Embedder-Policy": "require-corp",
			"Cross-Origin-Resource-Policy": "same-origin",
		});
		fs.createReadStream(file).pipe(response);
	});
	return new Promise((resolve, reject) => {
		server.once("error", reject);
		server.listen(0, "127.0.0.1", () => resolve(server));
	});
}

async function waitForDevToolsPort(file, timeoutMs) {
	const deadline = Date.now() + timeoutMs;
	while (Date.now() < deadline) {
		if (fs.statSync(file, {throwIfNoEntry: false})?.isFile()) {
			const port = Number(fs.readFileSync(file, "utf8").split(/\r?\n/)[0]);
			if (Number.isInteger(port) && port > 0) return port;
		}
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	throw new Error(`timed out waiting for a valid DevTools port in ${file}`);
}

async function waitForJson(url, timeoutMs) {
	const deadline = Date.now() + timeoutMs;
	while (Date.now() < deadline) {
		try {
			const response = await fetch(url);
			if (response.ok) return response.json();
		} catch {}
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	throw new Error(`timed out waiting for ${url}`);
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
	onEvent(listener) { this.listeners.add(listener); }
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
	const result = await cdp.send("Runtime.evaluate", {expression, awaitPromise: true, returnByValue: true, ...options});
	if (result.exceptionDetails) throw new Error(result.exceptionDetails.exception?.description || result.exceptionDetails.text);
	return result.result.value;
}

async function snapshot(cdp) {
	return evaluate(cdp, "globalThis.doraLoveComplexSnapshot ? doraLoveComplexSnapshot() : null");
}

async function memorySnapshot(cdp) {
	await cdp.send("HeapProfiler.collectGarbage");
	const [dom, heap] = await Promise.all([
		cdp.send("Memory.getDOMCounters"), cdp.send("Runtime.getHeapUsage"),
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

async function canvasPoint(cdp, xRatio, yRatio) {
	return evaluate(cdp, `(() => {
		const rect = document.querySelector("canvas").getBoundingClientRect();
		return {x: rect.left + rect.width * ${xRatio}, y: rect.top + rect.height * ${yRatio}};
	})()`);
}

async function moveCanvas(cdp, xRatio, yRatio) {
	const point = await canvasPoint(cdp, xRatio, yRatio);
	await cdp.send("Input.dispatchMouseEvent", {type: "mouseMoved", x: point.x, y: point.y});
	return point;
}

async function clickCanvas(cdp, xRatio, yRatio, holdMs = 50) {
	const point = await moveCanvas(cdp, xRatio, yRatio);
	await cdp.send("Input.dispatchMouseEvent", {type: "mousePressed", x: point.x, y: point.y,
		button: "left", buttons: 1, clickCount: 1});
	await new Promise((resolve) => setTimeout(resolve, holdMs));
	await cdp.send("Input.dispatchMouseEvent", {type: "mouseReleased", x: point.x, y: point.y,
		button: "left", buttons: 0, clickCount: 1});
	return point;
}

async function prepareMouseHover(cdp) {
	await moveCanvas(cdp, 0.98, 0.02);
	await new Promise((resolve) => setTimeout(resolve, 250));
	await moveCanvas(cdp, 0.97, 0.03);
	await new Promise((resolve) => setTimeout(resolve, 50));
}

async function clickGameButton(cdp, state, prefix, hoverTargets) {
	const xRatio = Number(state?.gameState?.[`${prefix}ButtonXRatio`]);
	const yRatio = Number(state?.gameState?.[`${prefix}ButtonYRatio`]);
	if (xRatio >= 0 && xRatio <= 1 && yRatio >= 0 && yRatio <= 1)
		return clickCanvas(cdp, xRatio, yRatio);
	const target = await findCanvasHover(cdp, hoverTargets);
	return clickCanvas(cdp, target.xRatio, target.yRatio);
}

async function findCanvasHover(cdp, targets, bounds = {}) {
	const xMin = bounds.xMin ?? 0.05;
	const xMax = bounds.xMax ?? 0.95;
	const yMin = bounds.yMin ?? 0.05;
	const yMax = bounds.yMax ?? 0.95;
	const step = bounds.step ?? 0.025;
	const observed = new Map();
	await prepareMouseHover(cdp);
	for (let y = yMin; y <= yMax + 0.0001; y += step) {
		for (let x = xMin; x <= xMax + 0.0001; x += step) {
			const point = await moveCanvas(cdp, x, y);
			await new Promise((resolve) => setTimeout(resolve, 20));
			const state = await snapshot(cdp);
			const hoverTarget = state?.gameState?.hoverTarget || "";
			if (hoverTarget && !observed.has(hoverTarget)) observed.set(hoverTarget, {xRatio: x, yRatio: y});
			if (targets.includes(hoverTarget)) return {xRatio: x, yRatio: y, point, state};
		}
	}
	throw new Error(`could not find hover target ${targets.join(" or ")}; observed ${JSON.stringify(Object.fromEntries(observed))}`);
}

async function findCanvasHoverMatching(cdp, predicate, bounds = {}) {
	const xMin = bounds.xMin ?? 0.05;
	const xMax = bounds.xMax ?? 0.95;
	const yMin = bounds.yMin ?? 0.05;
	const yMax = bounds.yMax ?? 0.95;
	const step = bounds.step ?? 0.02;
	const observed = new Map();
	await prepareMouseHover(cdp);
	for (let y = yMin; y <= yMax + 0.0001; y += step) {
		for (let x = xMin; x <= xMax + 0.0001; x += step) {
			const point = await moveCanvas(cdp, x, y);
			await new Promise((resolve) => setTimeout(resolve, 20));
			const state = await snapshot(cdp);
			const hoverTarget = state?.gameState?.hoverTarget || "";
			if (hoverTarget && !observed.has(hoverTarget)) observed.set(hoverTarget, {xRatio: x, yRatio: y});
			if (predicate(hoverTarget, state?.gameState || {})) return {xRatio: x, yRatio: y, point, state};
		}
	}
	throw new Error(`could not find matching hover target; observed ${JSON.stringify(Object.fromEntries(observed))}`);
}

async function clearTutorial(cdp) {
	for (let tutorialStep = 0; tutorialStep < 16; tutorialStep++) {
		const tutorial = await snapshot(cdp);
		if (!tutorial.gameState?.overlayTutorial) return tutorial;
		const next = await findCanvasHover(cdp, ["tut_next", "skip_tutorial_section"]);
		await clickCanvas(cdp, next.xRatio, next.yRatio);
		await new Promise((resolve) => setTimeout(resolve, 250));
	}
	const state = await snapshot(cdp);
	assert.equal(state.gameState?.overlayTutorial, false, "Love complex-project tutorial overlay did not clear");
	return state;
}

async function clearSettledTutorial(cdp, settleMs = 750) {
	await new Promise((resolve) => setTimeout(resolve, settleMs));
	await clearTutorial(cdp);
	await new Promise((resolve) => setTimeout(resolve, 300));
	return clearTutorial(cdp);
}

async function selectHandCards(cdp, count) {
	const initial = await snapshot(cdp);
	const cardRatios = initial.gameState?.handCardRatios;
	if (Array.isArray(cardRatios) && cardRatios.length >= count) {
		for (let selected = 0; selected < count; selected++) {
			const [xRatio, yRatio] = cardRatios[cardRatios.length - 1 - selected] || [];
			assert.ok(Number.isFinite(xRatio) && Number.isFinite(yRatio), "invalid Love complex-project card coordinates");
			await clickCanvas(cdp, xRatio, yRatio);
			await waitForGameState(cdp, (state) => state.highlightedCards >= selected + 1,
				`${selected + 1} selected Love complex-project cards`, 5000);
		}
		return cardRatios.slice(-count);
	}
	const selectedTargets = new Set();
	while (selectedTargets.size < count) {
		const before = await snapshot(cdp);
		if (before.gameState?.overlayTutorial) await clearSettledTutorial(cdp, 100);
		const card = await findCanvasHoverMatching(cdp,
			(target, state) => state.hoverIsCard && !selectedTargets.has(target),
			{xMin: 0.12, xMax: 0.92, yMin: 0.58, yMax: 0.93, step: 0.015});
		selectedTargets.add(card.state.gameState.hoverTarget);
		await clickCanvas(cdp, card.xRatio, card.yRatio);
		await waitForGameState(cdp, (state) => state.highlightedCards >= selectedTargets.size,
			`${selectedTargets.size} selected Love complex-project cards`, 5000);
	}
	return [...selectedTargets];
}

function chooseBestHand(cards, limit = 5) {
	const available = cards.filter((card) => !card.selected && card.rank >= 2 && card.rank <= 14);
	if (limit <= 1) return available.sort((a, b) => b.rank - a.rank).slice(0, limit);
	const byRank = new Map();
	const bySuit = new Map();
	for (const card of available) {
		if (!byRank.has(card.rank)) byRank.set(card.rank, []);
		if (!bySuit.has(card.suit)) bySuit.set(card.suit, []);
		byRank.get(card.rank).push(card);
		bySuit.get(card.suit).push(card);
	}
	const groups = [...byRank.values()].sort((a, b) => b.length - a.length || b[0].rank - a[0].rank);
	const straight = (source) => {
		const ranks = new Map(source.map((card) => [card.rank, card]));
		if (ranks.has(14)) ranks.set(1, ranks.get(14));
		for (let high = 14; high >= 5; high--) {
			const run = [0, 1, 2, 3, 4].map((offset) => ranks.get(high - offset));
			if (run.every(Boolean)) return run;
		}
		return null;
	};
	for (const suited of bySuit.values()) {
		if (suited.length >= 5) {
			const run = straight(suited);
			if (run) return run;
		}
	}
	if (groups[0]?.length >= 4)
		return [...groups[0].slice(0, 4), ...available.filter((card) => card.rank !== groups[0][0].rank)
			.sort((a, b) => b.rank - a.rank).slice(0, 1)];
	const triple = groups.find((group) => group.length >= 3);
	const pair = groups.find((group) => group.length >= 2 && group !== triple);
	if (triple && pair) return [...triple.slice(0, 3), ...pair.slice(0, 2)];
	const flush = [...bySuit.values()].find((suited) => suited.length >= 5);
	if (flush) return flush.sort((a, b) => b.rank - a.rank).slice(0, 5);
	const run = straight(available);
	if (run) return run;
	if (triple)
		return [...triple.slice(0, 3), ...available.filter((card) => card.rank !== triple[0].rank)
			.sort((a, b) => b.rank - a.rank).slice(0, 2)];
	const pairs = groups.filter((group) => group.length >= 2);
	if (pairs.length >= 2) {
		const usedRanks = new Set([pairs[0][0].rank, pairs[1][0].rank]);
		return [...pairs[0].slice(0, 2), ...pairs[1].slice(0, 2),
			...available.filter((card) => !usedRanks.has(card.rank)).sort((a, b) => b.rank - a.rank).slice(0, 1)];
	}
	if (pair)
		return [...pair.slice(0, 2), ...available.filter((card) => card.rank !== pair[0].rank)
			.sort((a, b) => b.rank - a.rank).slice(0, 3)];
	return available.sort((a, b) => b.rank - a.rank).slice(0, Math.min(limit, available.length));
}

async function selectDetailedCards(cdp, chooser, description) {
	const before = await snapshot(cdp);
	const cards = before.gameState?.handCardDetails || [];
	const chosen = chooser(cards).sort((a, b) => b.index - a.index);
	assert.ok(chosen.length > 0, `no Love complex-project cards available for ${description}`);
	for (let index = 0; index < chosen.length; index++) {
		const target = String(chosen[index].target);
		const current = await snapshot(cdp);
		const card = current.gameState?.handCardDetails?.find(
			(candidate) => String(candidate.target) === target);
		assert.ok(card && Number.isFinite(card.x) && Number.isFinite(card.y),
			`missing Love complex-project card geometry for ${target}`);
		await clickCanvas(cdp, Math.min(0.99, card.x + 0.05), card.y);
		await waitForGameState(cdp, (state) => state.handCardDetails?.some(
			(candidate) => String(candidate.target) === target && candidate.selected),
			`${description} card ${index + 1}`, 5000);
	}
	return chosen;
}

async function selectBestHandCards(cdp, limit = 5) {
	return selectDetailedCards(cdp, (cards) => chooseBestHand(cards, limit), "best-hand selection");
}

async function selectLowestHandCard(cdp) {
	return selectDetailedCards(cdp, (cards) => cards.filter((card) => !card.selected)
		.sort((a, b) => a.rank - b.rank).slice(0, 1), "discard selection");
}

async function pressKey(cdp, key, code, virtualKeyCode) {
	await cdp.send("Input.dispatchKeyEvent", {type: "keyDown", key, code,
		windowsVirtualKeyCode: virtualKeyCode, nativeVirtualKeyCode: virtualKeyCode});
	await cdp.send("Input.dispatchKeyEvent", {type: "keyUp", key, code,
		windowsVirtualKeyCode: virtualKeyCode, nativeVirtualKeyCode: virtualKeyCode});
}

async function captureScreenshot(cdp, file) {
	const screenshot = await cdp.send("Page.captureScreenshot", {format: "png", captureBeyondViewport: false});
	fs.mkdirSync(path.dirname(file), {recursive: true});
	fs.writeFileSync(file, Buffer.from(screenshot.data, "base64"));
}

async function waitForRuntime(cdp, timeoutMs) {
	const deadline = Date.now() + timeoutMs;
	let state = null;
	while (Date.now() < deadline) {
		try {
			state = await snapshot(cdp);
		} catch (error) {
			// --pre-js installs the snapshot facade before the new Wasm instance
			// publishes its exports during a page reload. Treat that narrow ccall
			// window as not-ready rather than a runtime failure.
			if (!String(error).includes("Cannot read properties of undefined")) throw error;
			state = null;
		}
		if (state?.error || state?.state < 0 || (state?.state === 1 && state.hasGraphics)) return state;
		await new Promise((resolve) => setTimeout(resolve, 100));
	}
	throw new Error(`timed out waiting for Love complex project: ${JSON.stringify(state)}`);
}

async function waitForGameState(cdp, predicate, description, timeoutMs) {
	const deadline = Date.now() + timeoutMs;
	let state = null;
	while (Date.now() < deadline) {
		state = await snapshot(cdp);
		if (state?.error || state?.state < 0)
			throw new Error(`${description} runtime failed: ${state?.error || `state ${state?.state}`}`);
		if (predicate(state?.gameState || {})) return state;
		await new Promise((resolve) => setTimeout(resolve, 100));
	}
	throw new Error(`timed out waiting for ${description}: ${JSON.stringify(state?.gameState)}`);
}

const server = await startServer();
const profile = fs.mkdtempSync(path.join(os.tmpdir(), "dora-love-complex-chrome-"));
const chrome = spawn(chromeExecutable(), ["--headless=new", "--no-first-run", "--no-default-browser-check",
	"--disable-background-networking", "--enable-webgl", "--enable-unsafe-swiftshader", "--use-angle=swiftshader",
	"--remote-debugging-port=0", `--user-data-dir=${profile}`, "about:blank"],
	{stdio: ["ignore", "ignore", "pipe"]});
let cdp;
const pageErrors = [];
const consoleMessages = [];
let runtime = null;
let cleanup = null;
let chromeErrors = "";
chrome.stderr.on("data", (chunk) => { chromeErrors += chunk; });
try {
	const portFile = path.join(profile, "DevToolsActivePort");
	const port = await waitForDevToolsPort(portFile, 10000);
	const targets = await waitForJson(`http://127.0.0.1:${port}/json/list`, 10000);
	const target = targets.find((item) => item.type === "page");
	assert.ok(target?.webSocketDebuggerUrl, "Chrome page target was not created");
	cdp = new Cdp(target.webSocketDebuggerUrl);
	cdp.onEvent((message) => {
		if (message.method === "Runtime.exceptionThrown")
			pageErrors.push(message.params.exceptionDetails?.exception?.description || message.params.exceptionDetails?.text);
		if (message.method === "Runtime.consoleAPICalled") {
			const line = message.params.args.map((value) => value.value ?? value.description ?? "").join(" ");
			consoleMessages.push({type: message.params.type, line});
		}
	});
	await Promise.all([cdp.send("Runtime.enable"), cdp.send("Page.enable"), cdp.send("HeapProfiler.enable")]);
	await cdp.send("Emulation.setDeviceMetricsOverride", {
		width: 1280,
		height: 720,
		deviceScaleFactor: 1,
		mobile: false,
	});
	const version = await cdp.send("Browser.getVersion");
	const address = server.address();
	await cdp.send("Page.navigate", {url: `http://127.0.0.1:${address.port}/dora-love-complex-probe.html`});
	runtime = await waitForRuntime(cdp, 180000);
	const isolation = await evaluate(cdp,
		"({crossOriginIsolated: globalThis.crossOriginIsolated, sharedArrayBuffer: typeof SharedArrayBuffer === 'function'})");
	if (pthreadProfile) {
		assert.equal(isolation.crossOriginIsolated, true, "pthread profile requires a cross-origin isolated page");
		assert.equal(isolation.sharedArrayBuffer, true, "pthread profile requires SharedArrayBuffer");
	}
	if (!runtime.error) {
		const unlocked = await evaluate(cdp,
			"globalThis.doraUnlockLoveComplexAudio ? doraUnlockLoveComplexAudio() : null", {userGesture: true});
		await new Promise((resolve) => setTimeout(resolve, observationMs));
		runtime = {...await snapshot(cdp), unlocked};
	}
	await captureScreenshot(cdp, screenshotPath);
	const flowEvidence = [];
	if (flow !== "boot") {
		await cdp.send("Page.bringToFront");
		await evaluate(cdp, "DoraWebPlatform.setSuspended(false, 'love-complex-flow')");
		await evaluate(cdp, "Module.canvas.focus(); true");
		const before = await snapshot(cdp);
		let point = null;
		if (flow === "pointer-start" || flow === "play-round" || flow === "full-game") {
			if (!before.gameState?.mainMenu) {
				await clickCanvas(cdp, 0.5, 0.5);
				await waitForGameState(cdp, (state) => state.mainMenu && state.state === "MENU"
					&& !state.screenwipe && !state.locksFrame,
					"Love complex-project main menu", 30000);
			}
			await moveCanvas(cdp, 0.27, 0.86);
			await waitForGameState(cdp, (state) => state.mainMenu && state.hoverTarget,
				"Love complex-project Play hover target", 10000);
			point = await clickCanvas(cdp, 0.27, 0.86);
			if (flow === "play-round" || flow === "full-game") {
				await waitForGameState(cdp, (state) => state.blindSelect && state.state === "BLIND_SELECT"
					&& state.eventQueueCount <= 6, "Love complex-project settled blind selection", 30000);
				await clearSettledTutorial(cdp);
				const selectBlind = await findCanvasHover(cdp,
					["select_blind_button", "select_blind"], {xMin: 0.1, xMax: 0.5, yMin: 0.1, yMax: 0.7});
				await clickCanvas(cdp, selectBlind.xRatio, selectBlind.yRatio);
				await waitForGameState(cdp, (state) => state.state === "SELECTING_HAND"
					&& state.handCards > 0, "Love complex-project dealt hand", 30000);
				if (flow === "full-game") {
					await clearSettledTutorial(cdp);
					await selectHandCards(cdp, 1);
					await waitForGameState(cdp, (state) => state.state === "SELECTING_HAND"
						&& !state.locksFrame,
						"Love complex-project first-play controls", 15000);
					await captureScreenshot(cdp, screenshotPath.replace(/\.png$/i, "-pre-first-play.png"));
					const beforeFirstPlay = await snapshot(cdp);
					fs.writeFileSync(reportPath.replace(/\.json$/i, "-pre-first-play-state.json"),
						`${JSON.stringify(beforeFirstPlay, null, 2)}\n`);
					await clickGameButton(cdp, beforeFirstPlay, "play",
						["play_cards_from_highlighted", "play_button"]);
					await waitForGameState(cdp, (state) => (state.state === "SELECTING_HAND"
						&& state.handsLeft < beforeFirstPlay.gameState.handsLeft)
						|| state.state === "ROUND_EVAL" || state.shop,
						"Love complex-project first played hand", 30000);
					const discardHand = await waitForGameState(cdp,
						(state) => (state.state === "SELECTING_HAND" && state.handCards > 0)
							|| state.state === "ROUND_EVAL" || state.shop,
						"Love complex-project discard hand", 30000);
					if (discardHand.gameState.state === "SELECTING_HAND") {
						await clearSettledTutorial(cdp);
						await selectLowestHandCard(cdp);
					}
					await waitForGameState(cdp, (state) => state.state !== "SELECTING_HAND"
						|| !state.locksFrame,
						"Love complex-project discard controls", 15000);
					await captureScreenshot(cdp, screenshotPath.replace(/\.png$/i, "-pre-discard.png"));
					const beforeDiscard = await snapshot(cdp);
					if (beforeDiscard.gameState.state === "SELECTING_HAND") {
						await clickGameButton(cdp, beforeDiscard, "discard",
							["discard_cards_from_highlighted", "discard_button"]);
						await waitForGameState(cdp, (state) => state.state === "SELECTING_HAND"
							&& state.highlightedCards === 0 && state.discardsLeft < beforeDiscard.gameState.discardsLeft,
							"Love complex-project discard completion", 15000);
					}
					for (let hand = 0; hand < 6; hand++) {
						const handState = await waitForGameState(cdp,
							(state) => (state.state === "SELECTING_HAND" && state.handCards > 0)
								|| state.state === "ROUND_EVAL" || state.shop,
							"Love complex-project playable hand", 30000);
						if (handState.gameState.state !== "SELECTING_HAND") break;
						await clearSettledTutorial(cdp);
						await selectBestHandCards(cdp, Math.min(5, handState.gameState.handCards));
						await clearSettledTutorial(cdp);
						await waitForGameState(cdp, (state) => state.state === "SELECTING_HAND"
							&& !state.overlayTutorial && !state.locksFrame,
							"Love complex-project play controls", 15000);
						const beforePlay = await snapshot(cdp);
						await clickGameButton(cdp, beforePlay, "play",
							["play_cards_from_highlighted", "play_button"]);
						await waitForGameState(cdp,
							(state) => (state.state === "SELECTING_HAND"
								&& state.handsLeft < beforePlay.gameState.handsLeft)
								|| state.state === "ROUND_EVAL" || state.shop,
							"Love complex-project played hand", 30000);
					}
					const roundEnd = await waitForGameState(cdp,
						(state) => state.state === "ROUND_EVAL" || state.shop,
						"Love complex-project round evaluation", 60000);
					if (!roundEnd.gameState.shop) {
						await new Promise((resolve) => setTimeout(resolve, 1500));
						const cashOut = await findCanvasHover(cdp, ["cash_out_button", "cash_out"],
							{xMin: 0.25, xMax: 0.75, yMin: 0.5, yMax: 0.95, step: 0.015});
						const cashOutState = cashOut.state;
						await captureScreenshot(cdp, screenshotPath.replace(/\.png$/i, "-cash-out.png"));
						fs.writeFileSync(reportPath.replace(/\.json$/i, "-cash-out-state.json"),
							`${JSON.stringify(cashOutState, null, 2)}\n`);
						await clickCanvas(cdp, cashOut.xRatio, cashOut.yRatio);
					}
					await waitForGameState(cdp, (state) => state.shop && state.state === "SHOP",
						"Love complex-project shop", 30000);
				}
			}
		}
		else {
			if (!before.gameState?.mainMenu)
				await waitForGameState(cdp, (state) => state.mainMenu && state.state === "MENU"
					&& !state.screenwipe && !state.locksFrame,
					"Love complex-project main menu", 30000);
			await pressKey(cdp, " ", "Space", 32);
		}
		await cdp.send("Page.bringToFront");
		const samples = [];
		const flowStarted = Date.now();
		const totalFlowWaitMs = Math.max(flowWaitMs, soakSeconds * 1000);
		const sampleIntervalMs = soakSeconds >= 120 ? 60000 : 1000;
		const flowDeadline = flowStarted + totalFlowWaitMs;
		while (Date.now() < flowDeadline) {
			await new Promise((resolve) => setTimeout(resolve,
				Math.min(sampleIntervalMs, Math.max(1, flowDeadline - Date.now()))));
			const sample = await snapshot(cdp);
			const memory = soakSeconds > 0 ? await memorySnapshot(cdp) : {};
			samples.push({...sample, ...memory, elapsedSeconds: (Date.now() - flowStarted) / 1000,
				pageErrorCount: pageErrors.length});
		}
		const file = screenshotPath.replace(/\.png$/i, "-start-run.png");
		await captureScreenshot(cdp, file);
		flowEvidence.push({action: flow, point, before, waitMs: totalFlowWaitMs, samples,
			runtime: await snapshot(cdp), screenshot: path.basename(file)});
	}
	const released = await evaluate(cdp,
		"globalThis.doraReleaseLoveComplexProbe ? doraReleaseLoveComplexProbe() : false");
	cleanup = await snapshot(cdp);
	const reloadRuns = [{runtime, cleanup: {...cleanup, released}}];
	const reloadMemory = [await memorySnapshot(cdp)];
	for (let run = 1; run <= reloadCount; run++) {
		await cdp.send("Page.reload", {ignoreCache: true});
		let reloaded = await waitForRuntime(cdp, 180000);
		const unlocked = await evaluate(cdp,
			"globalThis.doraUnlockLoveComplexAudio ? doraUnlockLoveComplexAudio() : null", {userGesture: true});
		reloaded = {...await snapshot(cdp), unlocked};
		assert.equal(reloaded.error, "", `Love Web complex-project reload ${run} failed`);
		assert.equal(reloaded.state, 1, `Love Web complex-project reload ${run} did not run`);
		const reloadReleased = await evaluate(cdp,
			"globalThis.doraReleaseLoveComplexProbe ? doraReleaseLoveComplexProbe() : false");
		const reloadCleanup = await snapshot(cdp);
		assert.equal(reloadReleased, true, `Love Web complex-project reload ${run} cleanup failed`);
		assert.equal(reloadCleanup.state, 2, `Love Web complex-project reload ${run} cleanup did not complete`);
		assert.equal(reloadCleanup.hasGraphics, false, `Love Web complex-project reload ${run} retained graphics`);
		assert.equal(reloadCleanup.audioSources, 0, `Love Web complex-project reload ${run} retained audio sources`);
		assert.equal(reloadCleanup.audioFileDelta, 0, `Love Web complex-project reload ${run} retained AudioFiles`);
		assert.equal(reloadCleanup.voiceDelta, 0, `Love Web complex-project reload ${run} retained voices`);
		reloadRuns.push({runtime: reloaded, cleanup: {...reloadCleanup, released: reloadReleased}});
		reloadMemory.push(await memorySnapshot(cdp));
		console.log(`[INFO] Love Web complex-project reload ${run}/${reloadCount} passed`);
	}
	const firstMemory = reloadMemory[0];
	const lastMemory = reloadMemory.at(-1);
	assert.equal(lastMemory.documents, firstMemory.documents, "documents accumulated across complex-project reloads");
	assert.equal(lastMemory.nodes, firstMemory.nodes, "DOM nodes accumulated across complex-project reloads");
	assert.equal(lastMemory.listeners, firstMemory.listeners, "listeners accumulated across complex-project reloads");
	assert.ok(lastMemory.jsHeapUsed <= firstMemory.jsHeapUsed + 32 * 1024 * 1024,
		`JS heap grew beyond complex-project reload allowance: ${JSON.stringify({firstMemory, lastMemory})}`);
	const flowRuntime = flowEvidence.at(-1)?.runtime || null;
	const flowFailed = flowEvidence.some((entry) => entry.runtime?.error || entry.runtime?.state < 0
		|| entry.samples?.some((sample) => sample.error || sample.state < 0));
	const soakSamples = soakSeconds > 0 ? (flowEvidence.at(-1)?.samples || []) : [];
	for (let index = 1; index < soakSamples.length; index++) {
		assert.ok(soakSamples[index].frame > soakSamples[index - 1].frame,
			"Love Web complex-project engine frame stalled during soak");
		assert.ok(soakSamples[index].gameState.timerReal > soakSamples[index - 1].gameState.timerReal,
			"Love Web complex-project game timer stalled during soak");
		assert.equal(soakSamples[index].documents, soakSamples[0].documents,
			"documents changed during complex-project soak");
		assert.equal(soakSamples[index].nodes, soakSamples[0].nodes,
			"DOM nodes changed during complex-project soak");
		assert.equal(soakSamples[index].listeners, soakSamples[0].listeners,
			"listeners changed during complex-project soak");
		assert.equal(soakSamples[index].pageErrorCount, soakSamples[0].pageErrorCount,
			"browser errors appeared during complex-project soak");
	}
	const soakHeapSlopeBytesPerMinute = slopePerMinute(soakSamples, "jsHeapUsed");
	if (soakSeconds >= 300)
		assert.ok(soakHeapSlopeBytesPerMinute <= 1024 * 1024,
			`Love Web complex-project heap slope exceeded 1 MiB/min: ${soakHeapSlopeBytesPerMinute}`);
	const report = {schemaVersion: 2, fixture: "love-complex-project", browser: version,
		result: runtime?.error || runtime?.state < 0 || flowFailed || pageErrors.length || !released
			|| cleanup?.state !== 2 || cleanup?.hasGraphics || cleanup?.audioSources !== 0
			|| cleanup?.audioFileDelta !== 0 || cleanup?.voiceDelta !== 0
			? "failed" : "diagnostic-passed",
		observationMs, flowWaitMs, reloads: reloadCount, soakSeconds, flow, pthreadProfile, isolation, flowEvidence,
		runtime, cleanup: {...cleanup, released}, reloadRuns,
		reloadMemory: {first: firstMemory, last: lastMemory}, soakHeapSlopeBytesPerMinute, pageErrors,
		consoleMessages: consoleMessages.slice(-200), screenshot: path.basename(screenshotPath)};
	fs.mkdirSync(path.dirname(reportPath), {recursive: true});
	fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`);
	console.log(`[INFO] Love Web complex-project diagnostic report: ${reportPath}`);
	console.log(`[INFO] Love Web complex-project screenshot: ${screenshotPath}`);
	assert.equal(runtime?.error || "", "", `Love Web complex project failed: ${runtime?.error || "unknown error"}`);
	assert.deepEqual(pageErrors, [], `Love Web complex project raised page errors: ${pageErrors.join("\n")}`);
	assert.equal(runtime?.state, 1, "Love Web complex project did not remain running");
	assert.equal(runtime?.hasGraphics, true, "Love Web complex project created no graphics resources");
	assert.equal(flowFailed, false, `Love Web complex-project flow failed: ${flowRuntime?.error || "unknown error"}`);
	if (flow === "pointer-start" || flow === "play-round" || flow === "full-game") {
		assert.equal(flowRuntime?.gameState?.stage, "RUN", "Love Web complex project did not enter a run");
		if (flow === "pointer-start") {
			assert.equal(flowRuntime?.gameState?.state, "BLIND_SELECT",
				"Love Web complex project did not reach blind selection");
			assert.equal(flowRuntime?.gameState?.blindSelect, true,
				"Love Web complex project did not create the blind-selection UI");
		} else if (flow === "play-round") {
			assert.equal(flowRuntime?.gameState?.state, "SELECTING_HAND",
				"Love Web complex project did not reach hand selection");
			assert.ok(flowRuntime?.gameState?.handCards > 0,
				"Love Web complex project dealt no playable cards");
		} else {
			assert.equal(flowRuntime?.gameState?.state, "SHOP",
				"Love Web complex project did not reach the shop");
			assert.equal(flowRuntime?.gameState?.shop, true,
				"Love Web complex project did not create the shop UI");
			assert.equal(flowRuntime?.gameState?.savePresent, true,
				"Love Web complex project did not create a run save");
		}
	}
	assert.equal(released, true, "Love Web complex project cleanup failed");
	assert.equal(cleanup?.state, 2, "Love Web complex project cleanup did not complete");
	assert.equal(cleanup?.hasGraphics, false, "Love Web complex graphics resources survived cleanup");
	assert.equal(cleanup?.audioSources, 0, "Love Web complex audio sources survived cleanup");
	assert.equal(cleanup?.audioFileDelta, 0, "Love Web complex AudioFile objects survived cleanup");
	assert.equal(cleanup?.voiceDelta, 0, "Love Web complex SoLoud voices survived cleanup");
} finally {
	await cdp?.close().catch(() => {});
	const chromeExit = new Promise((resolve) => chrome.once("exit", resolve));
	chrome.kill("SIGTERM"); server.close();
	await Promise.race([chromeExit, new Promise((resolve) => setTimeout(resolve, 2000))]);
	fs.rmSync(profile, {recursive: true, force: true, maxRetries: 10, retryDelay: 100});
}
