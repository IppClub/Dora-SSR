import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import {spawn} from "node:child_process";
import {inflateSync} from "node:zlib";

const fixtureKind = process.env.DORA_WEB_LOVE_VISUAL_KIND === "shader" ? "shader" : "graphics";
const shaderFixture = fixtureKind === "shader";
const artifactBase = shaderFixture ? "dora-love-shader-probe" : "dora-love-graphics-probe";
const artifactRoot = path.resolve(process.argv[2] || "build/web");
const screenshotPath = path.resolve(process.argv[3] || `build/web-love-${fixtureKind}.png`);
const reportPath = path.resolve(process.argv[4] || `build/web-love-${fixtureKind}-report.json`);
const reloadVariable = shaderFixture ? "DORA_WEB_LOVE_SHADER_RELOADS" : "DORA_WEB_LOVE_GRAPHICS_RELOADS";
const reloadCount = Number(process.env[reloadVariable] || 20);
assert.ok(Number.isInteger(reloadCount) && reloadCount >= 0 && reloadCount <= 100,
	`${reloadVariable} must be an integer from 0 to 100`);

for (const extension of ["html", "js", "wasm", "data"]) {
	const artifact = `${artifactBase}.${extension}`;
	assert.ok(fs.statSync(path.join(artifactRoot, artifact), {throwIfNoEntry: false})?.isFile(),
		`missing Love Web ${fixtureKind} artifact: ${artifact}`);
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
		if (requestPath === "/favicon.ico") return response.writeHead(204).end();
		const relative = decodeURIComponent(requestPath === "/" ? "/dora-love-graphics-probe.html" : requestPath).replace(/^\/+/, "");
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
		} catch (error) {
			lastError = error;
		}
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

function decodePng(bytes) {
	assert.deepEqual([...bytes.subarray(0, 8)], [137, 80, 78, 71, 13, 10, 26, 10], "invalid PNG signature");
	let offset = 8, width = 0, height = 0, bitDepth = 0, colorType = 0;
	let palette = Buffer.alloc(0), transparency = Buffer.alloc(0);
	const data = [];
	while (offset < bytes.length) {
		const length = bytes.readUInt32BE(offset);
		const type = bytes.toString("ascii", offset + 4, offset + 8);
		const chunk = bytes.subarray(offset + 8, offset + 8 + length);
		if (type === "IHDR") {
			width = chunk.readUInt32BE(0); height = chunk.readUInt32BE(4);
			bitDepth = chunk[8]; colorType = chunk[9];
			assert.equal(chunk[12], 0, "interlaced PNG screenshots are unsupported");
		} else if (type === "PLTE") palette = Buffer.from(chunk);
		else if (type === "tRNS") transparency = Buffer.from(chunk);
		else if (type === "IDAT") data.push(chunk);
		else if (type === "IEND") break;
		offset += length + 12;
	}
	const sourceChannels = colorType === 6 ? 4 : colorType === 2 ? 3 : colorType === 3 ? 1 : 0;
	assert.ok(sourceChannels, `unsupported PNG color type ${colorType}`);
	assert.ok(colorType === 3 ? [1, 2, 4, 8].includes(bitDepth) : bitDepth === 8,
		`unsupported PNG bit depth ${bitDepth} for color type ${colorType}`);
	const packed = inflateSync(Buffer.concat(data));
	const stride = Math.ceil(width * sourceChannels * bitDepth / 8);
	const bytesPerPixel = Math.max(1, Math.ceil(sourceChannels * bitDepth / 8));
	const scanlines = Buffer.alloc(stride * height);
	let sourceOffset = 0;
	for (let y = 0; y < height; y++) {
		const filter = packed[sourceOffset++];
		const row = y * stride;
		for (let x = 0; x < stride; x++) {
			const raw = packed[sourceOffset++];
			const left = x >= bytesPerPixel ? scanlines[row + x - bytesPerPixel] : 0;
			const up = y > 0 ? scanlines[row + x - stride] : 0;
			const upperLeft = y > 0 && x >= bytesPerPixel ? scanlines[row + x - stride - bytesPerPixel] : 0;
			let value = raw;
			if (filter === 1) value += left;
			else if (filter === 2) value += up;
			else if (filter === 3) value += Math.floor((left + up) / 2);
			else if (filter === 4) {
				const estimate = left + up - upperLeft;
				const leftDistance = Math.abs(estimate - left);
				const upDistance = Math.abs(estimate - up);
				const upperLeftDistance = Math.abs(estimate - upperLeft);
				value += leftDistance <= upDistance && leftDistance <= upperLeftDistance ? left
					: upDistance <= upperLeftDistance ? up : upperLeft;
			} else assert.equal(filter, 0, `unsupported PNG filter ${filter}`);
			scanlines[row + x] = value & 0xff;
		}
	}
	if (colorType !== 3) return {width, height, channels: sourceChannels, pixels: scanlines};
	const pixels = Buffer.alloc(width * height * 4);
	const mask = (1 << bitDepth) - 1;
	for (let y = 0; y < height; y++) for (let x = 0; x < width; x++) {
		const bit = x * bitDepth;
		const index = (scanlines[y * stride + Math.floor(bit / 8)] >> (8 - bitDepth - (bit % 8))) & mask;
		assert.ok(index * 3 + 2 < palette.length, `PNG palette index ${index} is out of range`);
		const target = (y * width + x) * 4;
		pixels[target] = palette[index * 3]; pixels[target + 1] = palette[index * 3 + 1]; pixels[target + 2] = palette[index * 3 + 2];
		pixels[target + 3] = index < transparency.length ? transparency[index] : 255;
	}
	return {width, height, channels: 4, pixels};
}

function findColor(image, predicate) {
	let count = 0, minX = image.width, minY = image.height, maxX = -1, maxY = -1;
	for (let y = 0; y < image.height; y++) for (let x = 0; x < image.width; x++) {
		const offset = (y * image.width + x) * image.channels;
		if (!predicate(image.pixels[offset], image.pixels[offset + 1], image.pixels[offset + 2])) continue;
		count++; minX = Math.min(minX, x); minY = Math.min(minY, y); maxX = Math.max(maxX, x); maxY = Math.max(maxY, y);
	}
	return {count, minX, minY, maxX, maxY};
}

function assertBounds(name, region, expected, minimumPixels) {
	assert.ok(region.count >= minimumPixels, `${name} pixels are missing: ${JSON.stringify(region)}`);
	for (const key of ["minX", "minY", "maxX", "maxY"])
		assert.ok(Math.abs(region[key] - expected[key]) <= 3,
			`${name} ${key} changed: ${JSON.stringify({region, expected})}`);
}

function assertFixture(image) {
	assert.equal(image.width, 1280); assert.equal(image.height, 720);
	if (shaderFixture) {
		const regions = {
			glsl3Left: findColor(image, (r, g, b) => r >= 85 && r < 120 && g >= 50 && g < 80 && b >= 50 && b < 80),
			glsl3Right: findColor(image, (r, g, b) => r < 45 && g >= 50 && g < 80 && b >= 110 && b < 145),
			glsl1Left: findColor(image, (r, g, b) => r >= 110 && r < 145 && g >= 110 && g < 145 && b >= 50 && b < 80),
			glsl1Right: findColor(image, (r, g, b) => r >= 15 && r < 50 && g > 220 && b >= 110 && b < 145),
		};
		assertBounds("GLSL3 varying/uniform/sampler left", regions.glsl3Left,
			{minX: 512, minY: 302, maxX: 543, maxY: 333}, 900);
		assertBounds("GLSL3 screen coordinate right", regions.glsl3Right,
			{minX: 544, minY: 302, maxX: 575, maxY: 333}, 900);
		assertBounds("GLSL1 precision/sampler left", regions.glsl1Left,
			{minX: 608, minY: 302, maxX: 639, maxY: 333}, 900);
		assertBounds("GLSL1 precision/sampler right", regions.glsl1Right,
			{minX: 640, minY: 302, maxX: 671, maxY: 333}, 900);
		return regions;
	}
	const regions = {
		canvasBlue: findColor(image, (r, g, b) => r < 45 && g >= 35 && g < 100 && b > 170),
		canvasGreen: findColor(image, (r, g, b) => r < 70 && g > 185 && b >= 35 && b < 110),
		mesh: findColor(image, (r, g, b) => r > 185 && g < 75 && b < 75),
		spriteBatch: findColor(image, (r, g, b) => r > 190 && g > 145 && b < 80),
		particleSystem: findColor(image, (r, g, b) => r < 70 && g > 175 && b > 190),
	};
	assertBounds("Canvas blue", regions.canvasBlue, {minX: 496, minY: 286, maxX: 559, maxY: 349}, 2500);
	assertBounds("Canvas green", regions.canvasGreen, {minX: 512, minY: 302, maxX: 543, maxY: 333}, 900);
	assertBounds("Mesh", regions.mesh, {minX: 576, minY: 286, maxX: 639, maxY: 349}, 3000);
	assertBounds("SpriteBatch", regions.spriteBatch, {minX: 656, minY: 286, maxX: 711, maxY: 325}, 600);
	assertBounds("ParticleSystem", regions.particleSystem, {minX: 748, minY: 312, maxX: 759, maxY: 323}, 100);
	return regions;
}

function assertShaderFailurePolicy(consoleMessages, expectedRuns) {
	const expected = [
		"LOVE_WEB_SHADER_FAILURE_PASS\ttranslation\t[love-shader/translation]",
		"LOVE_WEB_SHADER_FAILURE_PASS\tcompile\t[love-shader/driver/pixel]",
		"LOVE_WEB_SHADER_FAILURE_PASS\tlink\t[love-shader/driver/link]",
		"LOVE_WEB_SHADER_VALIDATION_FAILURE_PASS\tvalidate\t[love-shader/driver/pixel]",
		"LOVE_WEB_SHADER_FAILURE_POLICY_PASS\t4",
	];
	const counts = Object.fromEntries(expected.map((marker) => [marker,
		consoleMessages.filter((line) => line.includes(marker)).length]));
	for (const marker of expected)
		assert.equal(counts[marker], expectedRuns,
			`Love Web shader failure marker count changed: ${JSON.stringify(counts)}`);
	assert.equal(consoleMessages.some((line) => line.includes("BGFX FATAL")), false,
		"invalid Love Web shaders reached bgfx instead of failing during preflight");
	const diagnosticSamples = {};
	for (const label of ["translation", "compile", "link", "validate"]) {
		const marker = `LOVE_WEB_SHADER_FAILURE_DIAGNOSTIC\t${label}\t`;
		const matching = consoleMessages.filter((line) => line.includes(marker));
		assert.equal(matching.length, expectedRuns, `Love Web shader ${label} diagnostic count changed`);
		diagnosticSamples[label] = matching[0].slice(matching[0].indexOf(marker) + marker.length);
	}
	assert.match(diagnosticSamples.compile, /Love pixel Shader source line [0-9]+/,
		"WebGL compile diagnostic lost its Love source location");
	assert.match(diagnosticSamples.compile, /WebGL GLSL ES 3\.00 compile failed.*ERROR:/,
		"WebGL compile diagnostic lost its translated summary or driver log");
	assert.match(diagnosticSamples.link, /WebGL GLSL ES 3\.00 link failed.*LinkValues/,
		"WebGL link diagnostic lost its translated summary or driver log");
	return {defaultAction: "explicit-error", silentFallback: false,
		translationFailures: counts[expected[0]], compileFailures: counts[expected[1]],
		linkFailures: counts[expected[2]], validationFailures: counts[expected[3]], diagnosticSamples};
}

async function waitForProbe(cdp, pageErrors, consoleMessages) {
	const deadline = Date.now() + 20000;
	let lastProbe = null;
	while (Date.now() < deadline) {
		const probeGlobal = shaderFixture ? "DoraLoveShaderProbe" : "DoraLoveGraphicsProbe";
		const result = await cdp.send("Runtime.evaluate", {
			expression: `globalThis.${probeGlobal} || null`, returnByValue: true,
		});
		const probe = result.result.value;
		lastProbe = probe;
		if (probe?.error) throw new Error(`Love Web ${fixtureKind} fixture failed: ${probe.error}\n${consoleMessages.slice(-20).join("\n")}`);
		if (probe?.started && probe.running && probe.visualReady) return probe;
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	throw new Error(`timed out waiting for Love Web ${fixtureKind} fixture: ${JSON.stringify(lastProbe)}\n${pageErrors.join("\n")}\n${consoleMessages.slice(-20).join("\n")}`);
}

async function captureAndVerify(cdp, outputPath) {
	await new Promise((resolve) => setTimeout(resolve, 150));
	const capture = await cdp.send("Page.captureScreenshot", {format: "png", fromSurface: true});
	const screenshot = Buffer.from(capture.data, "base64");
	if (outputPath) {
		fs.mkdirSync(path.dirname(outputPath), {recursive: true});
		fs.writeFileSync(outputPath, screenshot);
	}
	return assertFixture(decodePng(screenshot));
}

const server = await startServer();
const profile = fs.mkdtempSync(path.join(os.tmpdir(), `dora-love-${fixtureKind}-chrome-`));
const chrome = spawn(chromeExecutable(), ["--headless=new", "--no-first-run", "--no-default-browser-check",
	"--disable-background-networking", "--enable-webgl", "--enable-unsafe-swiftshader", "--use-angle=swiftshader",
	"--window-size=1280,720", "--remote-debugging-port=0", `--user-data-dir=${profile}`, "about:blank"],
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
			if (process.env.DORA_WEB_LOVE_TRACE) console.error(`[BROWSER] ${line}`);
		}
	});
	await cdp.send("Runtime.enable"); await cdp.send("Page.enable");
	await cdp.send("Emulation.setDeviceMetricsOverride", {
		width: 1280, height: 720, deviceScaleFactor: 1, mobile: false,
	});
	const version = await cdp.send("Browser.getVersion");
	const address = server.address();
	await cdp.send("Page.navigate", {url: `http://127.0.0.1:${address.port}/${artifactBase}.html`});
	await waitForProbe(cdp, pageErrors, consoleMessages);
	const initialRegions = await captureAndVerify(cdp, reloadCount === 0 ? screenshotPath : null);
	let releases = 0;
	for (let reload = 0; reload <= reloadCount; reload++) {
		const releaseFunction = shaderFixture ? "doraReleaseLoveShaderProbe" : "doraReleaseLoveGraphicsProbe";
		const released = await cdp.send("Runtime.evaluate", {expression: `${releaseFunction}()`, awaitPromise: true, returnByValue: true});
		assert.equal(released.result.value, true, `Love Web ${fixtureKind} cleanup failed on run ${reload + 1}`);
		releases++;
		if (reload === reloadCount) break;
		await cdp.send("Page.reload", {ignoreCache: true});
		await waitForProbe(cdp, pageErrors, consoleMessages);
		if (reload + 1 === reloadCount) await captureAndVerify(cdp, screenshotPath);
	}
	assert.deepEqual(pageErrors, [], `browser exceptions:\n${pageErrors.join("\n")}`);
	const failurePolicy = shaderFixture
		? assertShaderFailurePolicy(consoleMessages, reloadCount + 1) : undefined;
	const coverage = shaderFixture
		? ["LoveNode Web host", "GLSL1 and GLSL3 translation", "varying", "uniform", "sampler", "precision", "coordinates", "Canvas readback", "translation failure", "WebGL compile failure", "WebGL link failure", "no silent fallback", "shader cleanup"]
		: ["LoveNode Web host", "Canvas render and readback", "Mesh", "SpriteBatch", "ParticleSystem", "coordinates", "node cleanup"];
	const report = {schemaVersion: 1, fixture: fixtureKind, browser: version, result: "passed", reloads: reloadCount,
		runs: reloadCount + 1, cleanupPasses: releases, regions: initialRegions,
		...(failurePolicy ? {failurePolicy} : {}), coverage};
	fs.mkdirSync(path.dirname(reportPath), {recursive: true});
	fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`);
	console.log(`[INFO] Love Web ${fixtureKind} fixture passed in ${version.product} with ${reloadCount} reloads`);
	console.log(`[INFO] Love Web ${fixtureKind} report: ${reportPath}`);
} finally {
	await cdp?.close().catch(() => {});
	const chromeExit = new Promise((resolve) => chrome.once("exit", resolve));
	chrome.kill("SIGTERM"); server.close();
	await Promise.race([chromeExit, new Promise((resolve) => setTimeout(resolve, 2000))]);
	removeProfile(profile);
}
