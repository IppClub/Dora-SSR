import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import {spawn} from "node:child_process";
import {brotliCompressSync, constants as zlibConstants, deflateRawSync, gzipSync, inflateSync} from "node:zlib";

const root = path.resolve(process.argv[2] || "result/dora-web-player");
const screenshotPath = path.resolve(process.argv[3] || "build/web-browser-smoke.png");
let artifactRoot = root;
const releasePointerPath = path.join(root, "dora-web-current.json");
const deploymentPolicyPath = path.join(root, "dora-web-deployment.json");
const deploymentPolicy = fs.statSync(deploymentPolicyPath, {throwIfNoEntry: false})?.isFile()
	? JSON.parse(fs.readFileSync(deploymentPolicyPath, "utf8"))
	: null;
if (fs.statSync(releasePointerPath, {throwIfNoEntry: false})?.isFile()) {
	const pointer = JSON.parse(fs.readFileSync(releasePointerPath, "utf8"));
	assert.equal(pointer.schemaVersion, 1, "unsupported Dora Web release pointer schema");
	assert.match(pointer.entry, /^releases\/[A-Za-z0-9][A-Za-z0-9._-]{0,63}\/index\.html$/, "unsafe Dora Web release pointer entry");
	artifactRoot = path.resolve(root, path.dirname(pointer.entry));
	assert.ok(artifactRoot.startsWith(`${root}${path.sep}`) && fs.statSync(artifactRoot, {throwIfNoEntry: false})?.isDirectory(), "Dora Web release pointer target is missing");
}
const readyMessage = "lazy asset, Sprite, Label, RenderTarget, blend, scissor, stencil, Particle, Spine, DragonBones, NanoVG, PlayRho, ImGui and Lua/YueScript/Teal examples verified";
const reloadCount = Number(process.env.DORA_WEB_RELOADS || 0);
assert.ok(Number.isInteger(reloadCount) && reloadCount >= 0 && reloadCount <= 100, "DORA_WEB_RELOADS must be an integer from 0 to 100");
const soakSeconds = Number(process.env.DORA_WEB_SOAK_SECONDS || 0);
const soakSampleSeconds = Number(process.env.DORA_WEB_SOAK_SAMPLE_SECONDS || 60);
assert.ok(Number.isFinite(soakSeconds) && soakSeconds >= 0 && soakSeconds <= 3600, "DORA_WEB_SOAK_SECONDS must be from 0 to 3600");
assert.ok(Number.isFinite(soakSampleSeconds) && soakSampleSeconds >= 1 && soakSampleSeconds <= 300, "DORA_WEB_SOAK_SAMPLE_SECONDS must be from 1 to 300");
const reportSuffix = process.env.DORA_WEB_REPORT_SUFFIX || "";
assert.match(reportSuffix, /^[a-z0-9-]*$/, "DORA_WEB_REPORT_SUFFIX may only contain lowercase letters, digits, and hyphens");

function reportPath(name) {
	const suffix = reportSuffix ? `-${reportSuffix}` : "";
	return path.join(path.dirname(screenshotPath), `${name}${suffix}.json`);
}

function crc32(bytes) {
	let value = 0xffffffff;
	for (const byte of bytes) {
		value ^= byte;
		for (let bit = 0; bit < 8; bit++) value = (value & 1) ? (0xedb88320 ^ (value >>> 1)) : (value >>> 1);
	}
	return (value ^ 0xffffffff) >>> 0;
}

function createPackageFixture() {
	const entries = [
		["dora-package.json", JSON.stringify({format: "dora-game", version: 1, title: "Browser import", engineVersion: "1.9.2", entry: "init"})],
		["init.lua", "print('browser package import ready')"],
	];
	const locals = [];
	const centrals = [];
	let localOffset = 0;
	for (const [entryPath, source] of entries) {
		const name = Buffer.from(entryPath);
		const data = Buffer.from(source);
		const compressed = deflateRawSync(data);
		const checksum = crc32(data);
		const local = Buffer.alloc(30);
		local.writeUInt32LE(0x04034b50, 0);
		local.writeUInt16LE(20, 4);
		local.writeUInt16LE(0x800, 6);
		local.writeUInt16LE(8, 8);
		local.writeUInt32LE(checksum, 14);
		local.writeUInt32LE(compressed.length, 18);
		local.writeUInt32LE(data.length, 22);
		local.writeUInt16LE(name.length, 26);
		locals.push(local, name, compressed);
		const central = Buffer.alloc(46);
		central.writeUInt32LE(0x02014b50, 0);
		central.writeUInt16LE(20, 4);
		central.writeUInt16LE(20, 6);
		central.writeUInt16LE(0x800, 8);
		central.writeUInt16LE(8, 10);
		central.writeUInt32LE(checksum, 16);
		central.writeUInt32LE(compressed.length, 20);
		central.writeUInt32LE(data.length, 24);
		central.writeUInt16LE(name.length, 28);
		central.writeUInt32LE(localOffset, 42);
		centrals.push(central, name);
		localOffset += local.length + name.length + compressed.length;
	}
	const directory = Buffer.concat(centrals);
	const end = Buffer.alloc(22);
	end.writeUInt32LE(0x06054b50, 0);
	end.writeUInt16LE(entries.length, 8);
	end.writeUInt16LE(entries.length, 10);
	end.writeUInt32LE(directory.length, 12);
	end.writeUInt32LE(localOffset, 16);
	return Buffer.concat([...locals, directory, end]);
}

const packageFixture = createPackageFixture();

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

function mimeType(file) {
	switch (path.extname(file)) {
		case ".html": return "text/html; charset=utf-8";
		case ".js": return "text/javascript; charset=utf-8";
		case ".json": return "application/json; charset=utf-8";
		case ".wasm": return "application/wasm";
		case ".png": return "image/png";
		case ".ttf": return "font/ttf";
		default: return "application/octet-stream";
	}
}

function startServer() {
	const server = http.createServer(async (request, response) => {
		const requestPath = new URL(request.url, "http://localhost").pathname;
		if (requestPath === "/favicon.ico") {
			response.writeHead(204).end();
			return;
		}
		if (requestPath === "/__dora_test__/package.dora") {
			response.writeHead(200, {"Cache-Control": "no-store", "Content-Length": packageFixture.length, "Content-Type": "application/zip"});
			response.end(packageFixture);
			return;
		}
		if (requestPath === "/__dora_test__/http/get") {
			response.writeHead(200, {"Content-Type": "application/json", "X-Dora-Test": "get"});
			response.end(JSON.stringify({method: request.method, ready: true}));
			return;
		}
		if (requestPath === "/__dora_test__/http/post") {
			const chunks = [];
			for await (const chunk of request) chunks.push(chunk);
			response.writeHead(201, {"Content-Type": "text/plain"});
			response.end(Buffer.concat(chunks));
			return;
		}
		if (requestPath === "/__dora_test__/http/status") {
			response.writeHead(418, {"Content-Type": "text/plain"});
			response.end("teapot");
			return;
		}
		if (requestPath === "/__dora_test__/http/slow") {
			setTimeout(() => {
				if (!response.destroyed) response.writeHead(200).end("late");
			}, 250);
			return;
		}
		if (requestPath === "/__dora_test__/http/stream") {
			response.writeHead(200, {"Content-Type": "application/octet-stream"});
			response.write(Buffer.alloc(1024, 1));
			setTimeout(() => {
				if (!response.destroyed) response.end(Buffer.alloc(1024, 2));
			}, 20);
			return;
		}
		if (requestPath === "/__dora_test__/http/large") {
			response.writeHead(200, {"Content-Type": "application/octet-stream"});
			response.end(Buffer.alloc(4096, 3));
			return;
		}
		const relative = decodeURIComponent(requestPath === "/" ? "/index.html" : requestPath).replace(/^\/+/, "");
		const file = path.resolve(root, relative);
		if (file !== root && !file.startsWith(`${root}${path.sep}`)) {
			response.writeHead(403).end();
			return;
		}
		const stat = fs.statSync(file, {throwIfNoEntry: false});
		if (!stat?.isFile()) {
			response.writeHead(404).end();
			return;
		}
		const cacheControl = relative.startsWith("releases/") || relative.startsWith("assets/")
			? "public, max-age=31536000, immutable"
			: relative === "index.html" || relative === "dora-web-entry.js" || relative === "dora-web-current.json" || relative === "dora-web-manifest.json"
				? "no-cache"
				: "public, max-age=3600";
		let contentSecurityPolicy;
		if (deploymentPolicy) {
			const releaseMatch = /^releases\/([^/]+)\//.exec(relative);
			if (releaseMatch) {
				const releaseMetadata = JSON.parse(fs.readFileSync(path.join(root, "releases", releaseMatch[1], "dora-web-release.json"), "utf8"));
				contentSecurityPolicy = releaseMetadata.contentSecurityPolicy;
			} else {
				contentSecurityPolicy = deploymentPolicy.security?.rootContentSecurityPolicy;
			}
		}
		response.writeHead(200, {
			"Cache-Control": cacheControl,
			"Content-Length": stat.size,
			"Content-Type": mimeType(file),
			...(contentSecurityPolicy ? {"Content-Security-Policy": contentSecurityPolicy} : {}),
		});
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

function decodePng(bytes) {
	assert.deepEqual([...bytes.subarray(0, 8)], [137, 80, 78, 71, 13, 10, 26, 10], "invalid PNG signature");
	let offset = 8;
	let width = 0;
	let height = 0;
	let bitDepth = 0;
	let colorType = 0;
	let palette = Buffer.alloc(0);
	let transparency = Buffer.alloc(0);
	const data = [];
	while (offset < bytes.length) {
		const length = bytes.readUInt32BE(offset);
		const type = bytes.toString("ascii", offset + 4, offset + 8);
		const chunk = bytes.subarray(offset + 8, offset + 8 + length);
		if (type === "IHDR") {
			width = chunk.readUInt32BE(0);
			height = chunk.readUInt32BE(4);
			bitDepth = chunk[8];
			colorType = chunk[9];
			assert.equal(chunk[12], 0, "interlaced PNG screenshots are unsupported");
		} else if (type === "PLTE") palette = Buffer.from(chunk);
		else if (type === "tRNS") transparency = Buffer.from(chunk);
		else if (type === "IDAT") data.push(chunk);
		else if (type === "IEND") break;
		offset += length + 12;
	}
	const sourceChannels = colorType === 6 ? 4 : colorType === 2 ? 3 : colorType === 3 ? 1 : 0;
	assert.ok(sourceChannels, `unsupported PNG color type ${colorType}`);
	assert.ok(colorType === 3 ? [1, 2, 4, 8].includes(bitDepth) : bitDepth === 8, `unsupported PNG bit depth ${bitDepth} for color type ${colorType}`);
	const packed = inflateSync(Buffer.concat(data));
	const stride = Math.ceil(width * sourceChannels * bitDepth / 8);
	const filterBytesPerPixel = Math.max(1, Math.ceil(sourceChannels * bitDepth / 8));
	const scanlines = Buffer.alloc(stride * height);
	let sourceOffset = 0;
	for (let y = 0; y < height; y++) {
		const filter = packed[sourceOffset++];
		const row = y * stride;
		for (let x = 0; x < stride; x++) {
			const raw = packed[sourceOffset++];
			const left = x >= filterBytesPerPixel ? scanlines[row + x - filterBytesPerPixel] : 0;
			const up = y > 0 ? scanlines[row + x - stride] : 0;
			const upperLeft = y > 0 && x >= filterBytesPerPixel ? scanlines[row + x - stride - filterBytesPerPixel] : 0;
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
	assert.ok(palette.length > 0 && palette.length % 3 === 0, "indexed PNG is missing a valid palette");
	const pixels = Buffer.alloc(width * height * 4);
	const mask = (1 << bitDepth) - 1;
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			const bit = x * bitDepth;
			const index = (scanlines[y * stride + Math.floor(bit / 8)] >> (8 - bitDepth - (bit % 8))) & mask;
			assert.ok(index * 3 + 2 < palette.length, `PNG palette index ${index} is out of range`);
			const target = (y * width + x) * 4;
			pixels[target] = palette[index * 3];
			pixels[target + 1] = palette[index * 3 + 1];
			pixels[target + 2] = palette[index * 3 + 2];
			pixels[target + 3] = index < transparency.length ? transparency[index] : 255;
		}
	}
	return {width, height, channels: 4, pixels};
}

function findColor(image, predicate) {
	let count = 0;
	let minX = image.width;
	let minY = image.height;
	let maxX = -1;
	let maxY = -1;
	for (let y = 0; y < image.height; y++) {
		for (let x = 0; x < image.width; x++) {
			const offset = (y * image.width + x) * image.channels;
			const r = image.pixels[offset];
			const g = image.pixels[offset + 1];
			const b = image.pixels[offset + 2];
			if (!predicate(r, g, b, x, y)) continue;
			count++;
			minX = Math.min(minX, x);
			minY = Math.min(minY, y);
			maxX = Math.max(maxX, x);
			maxY = Math.max(maxY, y);
		}
	}
	return {count, minX, minY, maxX, maxY};
}

function assertFixture(image) {
	assert.equal(image.width, 1280);
	assert.equal(image.height, 720);
	const backgroundOffset = (20 * image.width + 20) * image.channels;
	for (let channel = 0; channel < 3; channel++) assert.ok(image.pixels[backgroundOffset + channel] < 40, "background is not dark");

	const green = findColor(image, (r, g, b, x, y) => x >= 440 && x <= 840 && y >= 250 && y <= 470 && r >= 65 && r <= 120 && g >= 165 && g <= 215 && b >= 110 && b <= 180);
	assert.ok(green.count > 50000, `green fixture is missing: ${JSON.stringify(green)}`);
	assert.ok(green.minX >= 440 && green.minX <= 480 && green.maxX >= 800 && green.maxX <= 840, `green fixture x bounds changed: ${JSON.stringify(green)}`);
	assert.ok(green.minY >= 250 && green.minY <= 290 && green.maxY >= 430 && green.maxY <= 470, `green fixture y bounds changed: ${JSON.stringify(green)}`);

	const yellow = findColor(image, (r, g, b, x, y) => x >= 290 && x <= 470 && y >= 270 && y <= 450 && r > 190 && g > 130 && g < 230 && b < 100);
	assert.ok(yellow.count > 1000, `Sprite fixture is missing: ${JSON.stringify(yellow)}`);
	const label = findColor(image, (r, g, b, x, y) => x >= 670 && x <= 840 && y >= 330 && y <= 390 && r > 210 && g > 210 && b > 210);
	assert.ok(label.count > 400, `Label fixture is missing: ${JSON.stringify(label)}`);
	const renderTarget = findColor(image, (r, g, b, x, y) => x >= 560 && x <= 720 && y >= 500 && y <= 660 && r >= 15 && r <= 75 && g >= 30 && g <= 100 && b >= 45 && b <= 125);
	assert.ok(renderTarget.count > 4000, `RenderTarget fixture is missing: ${JSON.stringify(renderTarget)}`);
	const stencil = findColor(image, (r, g, b, x, y) => x >= 650 && x <= 710 && y >= 580 && y <= 650 && r > 210 && g > 150 && g < 235 && b < 140);
	assert.ok(stencil.count > 500, `stencil fixture is missing: ${JSON.stringify(stencil)}`);
	const scissor = findColor(image, (r, g, b, x, y) => x >= 580 && x <= 620 && y >= 600 && y <= 645 && r >= 50 && r <= 100 && g >= 190 && g <= 240 && b >= 210 && b <= 250);
	assert.ok(scissor.count > 500, `scissor fixture is missing: ${JSON.stringify(scissor)}`);
	const particle = findColor(image, (r, g, b, x, y) => x >= 180 && x <= 240 && y >= 540 && y <= 610 && r < 120 && g > 190 && b > 210);
	assert.ok(particle.count > 100, `Particle fixture is missing: ${JSON.stringify(particle)}`);
	const spine = findColor(image, (r, g, b, x, y) => x >= 890 && x <= 990 && y >= 530 && y <= 630 && ((r < 80 && g > 170 && b > 180) || (r < 90 && g > 150 && b < 150)));
	assert.ok(spine.count > 1500, `Spine fixture is missing: ${JSON.stringify(spine)}`);
	const dragonBones = findColor(image, (r, g, b, x, y) => x >= 1020 && x <= 1140 && y >= 520 && y <= 640 && r > 220 && g >= 70 && g <= 190 && b < 160);
	assert.ok(dragonBones.count > 1500, `DragonBones fixture is missing: ${JSON.stringify(dragonBones)}`);
	const nanoVgBackground = findColor(image, (r, g, b, x, y) => x >= 100 && x <= 300 && y >= 100 && y <= 260 && r >= 55 && r <= 100 && g >= 30 && g <= 80 && b >= 90 && b <= 150);
	assert.ok(nanoVgBackground.count > 10000, `NanoVG background fixture is missing: ${JSON.stringify(nanoVgBackground)}`);
	const nanoVgScissor = findColor(image, (r, g, b, x, y) => x >= 140 && x <= 260 && y >= 130 && y <= 230 && r >= 90 && r <= 160 && g > 180 && b >= 90 && b <= 170);
	assert.ok(nanoVgScissor.count > 3000, `NanoVG scissor fixture is missing: ${JSON.stringify(nanoVgScissor)}`);
	const physicsStatic = findColor(image, (r, g, b, x, y) => x >= 930 && x <= 1150 && y >= 190 && y <= 245 && r >= 35 && r <= 55 && g >= 60 && g <= 80 && b >= 35 && b <= 55);
	assert.ok(physicsStatic.count > 3000, `PlayRho static debug fixture is missing: ${JSON.stringify(physicsStatic)}`);
	const physicsDynamic = findColor(image, (r, g, b, x, y) => x >= 990 && x <= 1090 && y >= 145 && y <= 220 && Math.abs(r - g) <= 3 && Math.abs(g - b) <= 3 && r >= 45 && r <= 60);
	assert.ok(physicsDynamic.count > 1200, `PlayRho dynamic debug fixture is missing: ${JSON.stringify(physicsDynamic)}`);
	const imguiWindow = findColor(image, (r, g, b, x, y) => x >= 15 && x <= 245 && y >= 255 && y <= 425 && Math.abs(r - 51) <= 2 && Math.abs(g - 65) <= 2 && Math.abs(b - 91) <= 2);
	assert.ok(imguiWindow.count > 25000, `ImGui window fixture is missing: ${JSON.stringify(imguiWindow)}`);
	assert.deepEqual([imguiWindow.minX, imguiWindow.minY, imguiWindow.maxX, imguiWindow.maxY], [20, 283, 239, 419], `ImGui window bounds changed: ${JSON.stringify(imguiWindow)}`);
	const imguiButton = findColor(image, (r, g, b, x, y) => x >= 20 && x <= 180 && y >= 300 && y <= 380 && Math.abs(r - 210) <= 2 && Math.abs(g - 81) <= 2 && Math.abs(b - 136) <= 2);
	assert.ok(imguiButton.count > 2800, `ImGui clipped button fixture is missing: ${JSON.stringify(imguiButton)}`);
	assert.ok(imguiButton.minX === 30 && imguiButton.maxX === 101, `ImGui button clipping bounds changed: ${JSON.stringify(imguiButton)}`);
	const imguiText = findColor(image, (r, g, b, x, y) => x >= 20 && x <= 200 && y >= 285 && y <= 365 && r > 185 && g > 185 && b > 185);
	assert.ok(imguiText.count > 40, `ImGui custom-font text is missing: ${JSON.stringify(imguiText)}`);
	const luaSprite = findColor(image, (r, g, b, x, y) => x >= 1080 && x <= 1200 && y >= 30 && y <= 150 && r > 190 && g > 130 && g < 230 && b < 100);
	assert.ok(luaSprite.count > 200, `Lua Sprite example is missing: ${JSON.stringify(luaSprite)}`);
	const yueDraw = findColor(image, (r, g, b, x, y) => x >= 250 && x <= 350 && y >= 590 && y <= 690 && Math.abs(r - 24) <= 3 && Math.abs(g - 160) <= 3 && Math.abs(b - 251) <= 3);
	assert.ok(yueDraw.count > 4000, `YueScript DrawNode example is missing: ${JSON.stringify(yueDraw)}`);
	const tealLabel = findColor(image, (r, g, b, x, y) => x >= 560 && x <= 720 && y >= 30 && y <= 100 && r > 210 && g > 210 && b > 210);
	assert.ok(tealLabel.count > 150, `Teal Label example is missing: ${JSON.stringify(tealLabel)}`);
	return {green, yellow, label, renderTarget, stencil, scissor, particle, spine, dragonBones, nanoVgBackground, nanoVgScissor, physicsStatic, physicsDynamic, imguiWindow, imguiButton, imguiText, luaSprite, yueDraw, tealLabel};
}

function assertDpr2Fixture(image) {
	assert.equal(image.width, 2560, "DPR=2 screenshot width changed");
	assert.equal(image.height, 1440, "DPR=2 screenshot height changed");
	const imguiWindow = findColor(image, (r, g, b, x, y) => x >= 30 && x <= 490 && y >= 510 && y <= 850 && Math.abs(r - 51) <= 2 && Math.abs(g - 65) <= 2 && Math.abs(b - 91) <= 2);
	assert.ok(imguiWindow.count > 100000, `DPR=2 ImGui window fixture is missing: ${JSON.stringify(imguiWindow)}`);
	assert.deepEqual([imguiWindow.minX, imguiWindow.minY, imguiWindow.maxX, imguiWindow.maxY], [41, 567, 478, 838], `DPR=2 ImGui window bounds changed: ${JSON.stringify(imguiWindow)}`);
	const imguiButton = findColor(image, (r, g, b, x, y) => x >= 40 && x <= 360 && y >= 600 && y <= 760 && Math.abs(r - 210) <= 2 && Math.abs(g - 81) <= 2 && Math.abs(b - 136) <= 2);
	assert.ok(imguiButton.count > 11000, `DPR=2 ImGui clipped button fixture is missing: ${JSON.stringify(imguiButton)}`);
	assert.ok(imguiButton.minX === 61 && imguiButton.maxX === 203, `DPR=2 ImGui button clipping bounds changed: ${JSON.stringify(imguiButton)}`);
	return {imguiWindow, imguiButton};
}

function assertRenderTargetReadback(image) {
	assert.equal(image.width, 192, "RenderTarget readback width changed");
	assert.equal(image.height, 192, "RenderTarget readback height changed");
	const background = findColor(image, (r, g, b) => Math.abs(r - 23) <= 8 && Math.abs(g - 50) <= 8 && Math.abs(b - 77) <= 8);
	assert.ok(background.count > 12000, `RenderTarget background readback changed: ${JSON.stringify(background)}`);
	const blend = findColor(image, (r, g, b) => r >= 115 && r <= 145 && g >= 58 && g <= 82 && b >= 60 && b <= 86);
	assert.ok(blend.count > 6000, `RenderTarget blend readback changed: ${JSON.stringify(blend)}`);
	const stencil = findColor(image, (r, g, b) => r > 235 && g >= 190 && g <= 225 && b >= 80 && b <= 125);
	assert.ok(stencil.count > 2000, `RenderTarget stencil readback changed: ${JSON.stringify(stencil)}`);
	const scissor = findColor(image, (r, g, b) => r >= 50 && r <= 100 && g >= 190 && g <= 240 && b >= 210 && b <= 250);
	assert.ok(scissor.count >= 1400 && scissor.count <= 1600, `RenderTarget scissor readback changed: ${JSON.stringify(scissor)}`);
	assert.ok(scissor.minX >= 24 && scissor.maxX <= 55 && scissor.minY >= 128 && scissor.maxY <= 175, `RenderTarget scissor bounds changed: ${JSON.stringify(scissor)}`);
	return {background, blend, stencil, scissor};
}

async function waitForReadyCount(consoleMessages, expected, chromeErrors) {
	const deadline = Date.now() + 30000;
	while (consoleMessages.filter((message) => message.includes(readyMessage)).length < expected && Date.now() < deadline) {
		await new Promise((resolve) => setTimeout(resolve, 50));
	}
	const actual = consoleMessages.filter((message) => message.includes(readyMessage)).length;
	assert.equal(actual, expected, `fixture did not become ready exactly once for navigation ${expected}:\n${consoleMessages.join("\n")}\n${chromeErrors}`);
}

async function waitForConsole(consoleMessages, predicate, description) {
	const deadline = Date.now() + 5000;
	while (!consoleMessages.some(predicate) && Date.now() < deadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	const message = [...consoleMessages].reverse().find(predicate);
	assert.ok(message, `timed out waiting for ${description}:\n${consoleMessages.join("\n")}`);
	return message;
}

async function memorySnapshot(cdp) {
	await cdp.send("HeapProfiler.collectGarbage");
	const [{metrics}, dom] = await Promise.all([
		cdp.send("Performance.getMetrics"),
		cdp.send("Memory.getDOMCounters"),
	]);
	const values = Object.fromEntries(metrics.map(({name, value}) => [name, value]));
	return {
		documents: dom.documents,
		nodes: dom.nodes,
		listeners: dom.jsEventListeners,
		jsHeapUsed: values.JSHeapUsedSize,
	};
}

async function engineFrame(cdp) {
	const result = await cdp.send("Runtime.evaluate", {expression: "Module._dora_web_set_suspended(0)", returnByValue: true});
	assert.equal(result.exceptionDetails, undefined, `engine frame heartbeat failed: ${result.exceptionDetails?.text || "unknown error"}`);
	assert.ok(Number.isInteger(result.result.value), `engine frame heartbeat is invalid: ${JSON.stringify(result.result.value)}`);
	return result.result.value;
}

function linearSlope(values, times) {
	const meanValue = values.reduce((sum, value) => sum + value, 0) / values.length;
	const meanTime = times.reduce((sum, value) => sum + value, 0) / times.length;
	let covariance = 0;
	let variance = 0;
	for (let index = 0; index < values.length; index++) {
		covariance += (times[index] - meanTime) * (values[index] - meanValue);
		variance += (times[index] - meanTime) ** 2;
	}
	return variance === 0 ? 0 : covariance / variance;
}

async function runSoak(cdp, seconds, sampleSeconds, pageErrors, pageWarnings) {
	if (seconds <= 0) return null;
	const started = Date.now();
	const initialErrorCount = pageErrors.length;
	const samples = [];
	let previousFrame = -1;
	while (true) {
		const elapsedSeconds = (Date.now() - started) / 1000;
		const [memory, frame] = await Promise.all([memorySnapshot(cdp), engineFrame(cdp)]);
		assert.ok(previousFrame < 0 || frame > previousFrame, `engine frame heartbeat stalled during soak: ${JSON.stringify({previousFrame, frame, elapsedSeconds})}`);
		previousFrame = frame;
		const sample = {elapsedSeconds, frame, ...memory, pageErrors: pageErrors.length, pageWarnings: pageWarnings.length};
		samples.push(sample);
		console.log(`[INFO] Soak sample ${samples.length}: ${JSON.stringify(sample)}`);
		if (elapsedSeconds >= seconds) break;
		await new Promise((resolve) => setTimeout(resolve, Math.min(sampleSeconds, seconds - elapsedSeconds) * 1000));
	}
	assert.equal(pageErrors.length, initialErrorCount, `browser errors appeared during soak: ${pageErrors.slice(initialErrorCount).join("\n")}`);
	const lifecycleWarnings = pageWarnings.filter((warning) => /context lost|too many active WebGL|GL_OUT_OF_MEMORY|out of memory/i.test(warning));
	assert.deepEqual(lifecycleWarnings, [], `browser lifecycle warnings appeared during soak: ${lifecycleWarnings.join("\n")}`);
	const baseline = samples[0];
	const final = samples.at(-1);
	assert.ok(final.documents <= baseline.documents + 1, `documents accumulated during soak: ${JSON.stringify({baseline, final})}`);
	assert.ok(final.nodes <= baseline.nodes + 50, `DOM nodes accumulated during soak: ${JSON.stringify({baseline, final})}`);
	assert.ok(final.listeners <= baseline.listeners + 10, `event listeners accumulated during soak: ${JSON.stringify({baseline, final})}`);
	assert.ok(final.jsHeapUsed <= baseline.jsHeapUsed + 8 * 1024 * 1024, `JS heap exceeded soak allowance: ${JSON.stringify({baseline, final})}`);
	const heapSlopeBytesPerMinute = linearSlope(samples.map((sample) => sample.jsHeapUsed), samples.map((sample) => sample.elapsedSeconds)) * 60;
	if (seconds >= 300) assert.ok(heapSlopeBytesPerMinute <= 256 * 1024, `JS heap trend exceeded 256 KiB/min during soak: ${heapSlopeBytesPerMinute}`);
	return {durationSeconds: (Date.now() - started) / 1000, sampleIntervalSeconds: sampleSeconds, heapSlopeBytesPerMinute, samples};
}

async function startupTiming(cdp, label) {
	const timing = await cdp.send("Runtime.evaluate", {
		expression: `(() => {
			const navigation = performance.getEntriesByType("navigation")[0];
			const resources = performance.getEntriesByType("resource");
			const marks = Object.fromEntries(performance.getEntriesByType("mark")
				.filter((entry) => entry.name.startsWith("dora-"))
				.map((entry) => [entry.name, entry.startTime]));
			const resource = (suffix) => {
				const entry = resources.find((item) => new URL(item.name).pathname.endsWith(suffix));
				return entry ? {responseEnd: entry.responseEnd, duration: entry.duration, transferSize: entry.transferSize, encodedBodySize: entry.encodedBodySize, decodedBodySize: entry.decodedBodySize} : null;
			};
			const gameAssets = resources.filter((entry) => new URL(entry.name).pathname.includes("/assets/"));
			const runtimeDownloadsReady = Math.max(0, ...[resource("/dora-player-runtime.js"), resource("/dora-player-runtime.wasm"), resource("/dora-player-runtime.data")].filter(Boolean).map((entry) => entry.responseEnd));
			const now = performance.now();
			return {
				label: ${JSON.stringify(label)},
				total: now,
				html: navigation ? {responseEnd: navigation.responseEnd, duration: navigation.duration, transferSize: navigation.transferSize, encodedBodySize: navigation.encodedBodySize, decodedBodySize: navigation.decodedBodySize} : null,
				javascript: resource("/dora-player-runtime.js"),
				wasm: resource("/dora-player-runtime.wasm"),
				data: resource("/dora-player-runtime.data"),
				manifest: resource("/dora-web-manifest.json"),
				gameAssets: {
					count: gameAssets.length,
					responseEnd: gameAssets.length ? Math.max(...gameAssets.map((entry) => entry.responseEnd)) : 0,
					transferSize: gameAssets.reduce((sum, entry) => sum + entry.transferSize, 0),
					encodedBodySize: gameAssets.reduce((sum, entry) => sum + entry.encodedBodySize, 0),
				},
				marks,
				milestones: {
					shellReady: marks["dora-shell-ready"],
					runtimeDownloadsReady,
					manifestReady: marks["dora-manifest-ready"],
					startupAssetsReady: marks["dora-startup-assets-ready"],
					storageReady: marks["dora-storage-ready"],
					runtimeInitialized: marks["dora-state-ready"],
					engineFirstFrame: marks["dora-state-running"],
					fixtureReady: now,
				},
				phases: {
					shell: marks["dora-shell-ready"],
					runtimeDownloads: runtimeDownloadsReady,
					manifest: marks["dora-manifest-ready"] - marks["dora-manifest-start"],
					startupAssetMount: marks["dora-startup-assets-ready"] - marks["dora-manifest-ready"],
					storageRestore: marks["dora-storage-ready"] - marks["dora-storage-start"],
					wasmRuntimeInitialize: marks["dora-state-ready"] - Math.max(runtimeDownloadsReady, marks["dora-storage-ready"], marks["dora-startup-assets-ready"]),
					engineAndFirstFrame: marks["dora-state-running"] - marks["dora-state-ready"],
					gameFixture: now - marks["dora-state-running"],
				},
			};
		})()`,
		returnByValue: true,
	});
	assert.equal(timing.exceptionDetails, undefined, `${label} startup timing query failed: ${timing.exceptionDetails?.text || "unknown error"}`);
	const value = timing.result.value;
	for (const mark of ["dora-shell-ready", "dora-state-ready", "dora-state-running", "dora-manifest-ready", "dora-startup-assets-ready", "dora-storage-ready", "dora-content-ready"]) {
		assert.ok(Number.isFinite(value.marks[mark]), `${label} startup mark is missing: ${mark}`);
	}
	return value;
}

function compressedSizes(file) {
	const bytes = fs.readFileSync(file);
	return {
		raw: bytes.length,
		gzip: gzipSync(bytes, {level: 9}).length,
		brotli: brotliCompressSync(bytes, {params: {[zlibConstants.BROTLI_PARAM_QUALITY]: 6}}).length,
	};
}

function startupArtifactSizes() {
	const runtimeNames = ["dora-player-runtime.html", "dora-player-runtime.js", "dora-player-runtime.wasm", "dora-player-runtime.data"];
	const runtime = Object.fromEntries(runtimeNames.map((name) => [name, compressedSizes(path.join(artifactRoot, name))]));
	const manifest = JSON.parse(fs.readFileSync(path.join(artifactRoot, "dora-web-manifest.json"), "utf8"));
	const supportNames = ["index.html", "dora-web-manifest.json", "dora-web-features.json"];
	const support = Object.fromEntries(supportNames.map((name) => [name, compressedSizes(path.join(artifactRoot, name))]));
	const startupAssets = Object.fromEntries(manifest.files
		.filter((entry) => entry.startup)
		.map((entry) => [entry.url, compressedSizes(path.join(artifactRoot, entry.url))]));
	const totals = (groups) => Object.values(groups).flatMap(Object.values).reduce((sum, sizes) => ({
		raw: sum.raw + sizes.raw,
		gzip: sum.gzip + sizes.gzip,
		brotli: sum.brotli + sizes.brotli,
	}), {raw: 0, gzip: 0, brotli: 0});
	return {
		runtime,
		support,
		startupAssets,
		runtimeTotals: totals([runtime]),
		firstLoadTotals: totals([runtime, support, startupAssets]),
	};
}

const server = await startServer();
const address = server.address();
const profile = fs.mkdtempSync(path.join(os.tmpdir(), "dora-web-chrome-"));
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

try {
	const portFile = path.join(profile, "DevToolsActivePort");
	await waitForFile(portFile, 10000);
	const port = Number(fs.readFileSync(portFile, "utf8").split(/\r?\n/)[0]);
	const targets = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
	const target = targets.find((item) => item.type === "page");
	assert.ok(target?.webSocketDebuggerUrl, "Chrome page target was not created");
	const cdp = new Cdp(target.webSocketDebuggerUrl);
	const consoleMessages = [];
	const pageErrors = [];
	const pageWarnings = [];
	cdp.onEvent((message) => {
		if (message.method === "Runtime.consoleAPICalled") {
			const text = message.params.args.map((arg) => arg.value ?? arg.description ?? "").join(" ");
			consoleMessages.push(text);
			if (message.params.type === "error") pageErrors.push(text);
			else if (message.params.type === "warning") pageWarnings.push(text);
		} else if (message.method === "Runtime.exceptionThrown") {
			pageErrors.push(message.params.exceptionDetails.text);
		} else if (message.method === "Log.entryAdded") {
			if (message.params.entry.level === "error") pageErrors.push(message.params.entry.text);
			else if (message.params.entry.level === "warning") pageWarnings.push(message.params.entry.text);
		}
	});
	await Promise.all([
		cdp.send("Page.enable"),
		cdp.send("Runtime.enable"),
		cdp.send("Log.enable"),
		cdp.send("Network.enable"),
		cdp.send("Performance.enable"),
		cdp.send("HeapProfiler.enable"),
	]);
	const browserVersion = await cdp.send("Browser.getVersion");
	const browser = {
		product: browserVersion.product,
		protocolVersion: browserVersion.protocolVersion,
		userAgent: browserVersion.userAgent,
		jsVersion: browserVersion.jsVersion,
	};
	console.log(`[INFO] Browser: ${browser.product}`);
	await cdp.send("Emulation.setDeviceMetricsOverride", {width: 1280, height: 720, deviceScaleFactor: 1, mobile: false});
	await cdp.send("Network.clearBrowserCache");
	await cdp.send("Page.navigate", {url: `http://127.0.0.1:${address.port}/`});
	await waitForReadyCount(consoleMessages, 1, chromeErrors);
	const coldStartup = await startupTiming(cdp, "cold");
	assert.ok(coldStartup.marks["dora-state-running"] <= 5000, `cold engine startup exceeded 5 seconds: ${JSON.stringify(coldStartup)}`);
	assert.ok(coldStartup.total <= 5000, `cold fixture startup exceeded 5 seconds: ${JSON.stringify(coldStartup)}`);
	for (const message of ["Dora Web example Lua Sprite verified", "Dora Web example YueScript DrawNode verified", "Dora Web example Teal Label verified"]) {
		assert.equal(consoleMessages.filter((entry) => entry.includes(message)).length, 1, `${message} was not logged exactly once`);
	}
	const runtimeFeatures = await cdp.send("Runtime.evaluate", {
		expression: "({platform: DoraWebPlatform.features, global: DoraWebFeatures, module: Module.doraWebFeatures})",
		returnByValue: true,
	});
	assert.equal(runtimeFeatures.exceptionDetails, undefined, `runtime feature profile query failed: ${runtimeFeatures.exceptionDetails?.text || "unknown error"}`);
	assert.deepEqual(runtimeFeatures.result.value.platform, runtimeFeatures.result.value.global, "DoraWebPlatform feature profile differs from the host profile");
	assert.deepEqual(runtimeFeatures.result.value.module, runtimeFeatures.result.value.global, "Module feature profile differs from the host profile");
	assert.equal(runtimeFeatures.result.value.global.activeProfile, "minimal", "browser runtime did not activate the minimal feature profile");
	assert.equal(runtimeFeatures.result.value.global.profiles.full.available, false, "unvalidated full profile was exposed as available");
	const imguiBoundsMessage = consoleMessages.find((message) => /Dora Web ImGui button bounds [0-9.]+ [0-9.]+ [0-9.]+ [0-9.]+/.test(message));
	assert.ok(imguiBoundsMessage, `ImGui button bounds are missing:\n${consoleMessages.join("\n")}`);
	const imguiBounds = /bounds ([0-9.]+) ([0-9.]+) ([0-9.]+) ([0-9.]+)/.exec(imguiBoundsMessage).slice(1).map(Number);
	const imguiTapCount = consoleMessages.filter((message) => message.includes("Dora Web input mouse-began")).length;
	const imguiClickCount = consoleMessages.filter((message) => message.includes("Dora Web ImGui button clicked")).length;
	const imguiClickX = imguiBounds[0] + Math.min(24, (imguiBounds[2] - imguiBounds[0]) / 4);
	const imguiClickY = (imguiBounds[1] + imguiBounds[3]) / 2;
	await cdp.send("Input.dispatchMouseEvent", {type: "mouseMoved", x: imguiClickX, y: imguiClickY});
	await cdp.send("Input.dispatchMouseEvent", {type: "mousePressed", x: imguiClickX, y: imguiClickY, button: "left", buttons: 1, clickCount: 1});
	await cdp.send("Input.dispatchMouseEvent", {type: "mouseReleased", x: imguiClickX, y: imguiClickY, button: "left", buttons: 0, clickCount: 1});
	await waitForConsole(consoleMessages, (message) => message.includes("Dora Web ImGui button clicked"), "ImGui button click");
	assert.equal(consoleMessages.filter((message) => message.includes("Dora Web ImGui button clicked")).length, imguiClickCount + 1, "ImGui button click was not delivered exactly once");
	assert.equal(consoleMessages.filter((message) => message.includes("Dora Web input mouse-began")).length, imguiTapCount, "ImGui click leaked into the Dora scene touch layer");
	const dpr2MetricsStart = consoleMessages.length;
	await cdp.send("Emulation.setDeviceMetricsOverride", {width: 1280, height: 720, deviceScaleFactor: 2, mobile: false});
	await cdp.send("Runtime.evaluate", {expression: "dispatchEvent(new Event('resize'))"});
	await waitForConsole(consoleMessages, (message) => consoleMessages.indexOf(message) >= dpr2MetricsStart && message.includes("visual=1280x720 buffer=2560x1440 dpr=2.000"), "DPR=2 canvas metrics");
	await cdp.send("Input.dispatchMouseEvent", {type: "mouseMoved", x: 500, y: 50});
	await new Promise((resolve) => setTimeout(resolve, 250));
	const dpr2Capture = await cdp.send("Page.captureScreenshot", {format: "png", fromSurface: true});
	const dpr2Screenshot = Buffer.from(dpr2Capture.data, "base64");
	const dpr2ScreenshotPath = path.join(path.dirname(screenshotPath), `${path.basename(screenshotPath, path.extname(screenshotPath))}-dpr2.png`);
	fs.mkdirSync(path.dirname(dpr2ScreenshotPath), {recursive: true});
	fs.writeFileSync(dpr2ScreenshotPath, dpr2Screenshot);
	const dpr2Regions = assertDpr2Fixture(decodePng(dpr2Screenshot));
	const dpr1MetricsStart = consoleMessages.length;
	await cdp.send("Emulation.setDeviceMetricsOverride", {width: 1280, height: 720, deviceScaleFactor: 1, mobile: false});
	await cdp.send("Runtime.evaluate", {expression: "dispatchEvent(new Event('resize'))"});
	await waitForConsole(consoleMessages, (message) => consoleMessages.indexOf(message) >= dpr1MetricsStart && message.includes("visual=1280x720 buffer=1280x720 dpr=1.000"), "restored DPR=1 canvas metrics");
	const physicsMessage = consoleMessages.find((message) => /Dora Web PlayRho verified y=-?[0-9.]+ mass=[0-9.]+/.test(message));
	assert.ok(physicsMessage, `PlayRho deterministic simulation result is missing:\n${consoleMessages.join("\n")}`);
	const physicsValues = /y=(-?[0-9.]+) mass=([0-9.]+)/.exec(physicsMessage);
	assert.ok(physicsValues, `PlayRho simulation result is malformed: ${physicsMessage}`);
	const physicsY = Number(physicsValues[1]);
	const physicsMass = Number(physicsValues[2]);
	assert.ok(physicsY >= -20 && physicsY < 15, `PlayRho body did not enter the expected collision corridor: ${physicsMessage}`);
	assert.ok(physicsMass > 0, `PlayRho dynamic body mass is invalid: ${physicsMessage}`);
	const renderTargetBytes = await cdp.send("Runtime.evaluate", {
		expression: "Array.from(Module.FS.readFile('/tmp/dora-web-render-target.png'))",
		returnByValue: true,
	});
	assert.equal(renderTargetBytes.exceptionDetails, undefined, `RenderTarget PNG readback is unavailable: ${renderTargetBytes.exceptionDetails?.text || "unknown error"}`);
	const renderTargetPng = Buffer.from(renderTargetBytes.result.value);
	const renderTargetReadbackPath = path.join(path.dirname(screenshotPath), "web-render-target-readback.png");
	fs.mkdirSync(path.dirname(renderTargetReadbackPath), {recursive: true});
	fs.writeFileSync(renderTargetReadbackPath, renderTargetPng);
	const renderTargetRegions = assertRenderTargetReadback(decodePng(renderTargetPng));
	const packageApi = await cdp.send("Runtime.evaluate", {
		expression: "typeof globalThis.DoraWebPackage?.inspectPackage === 'function' && typeof globalThis.DoraWebPackage?.installPackage === 'function'",
		returnByValue: true,
	});
	assert.equal(packageApi.result.value, true, ".dora package API is not available in the Player");
	const virtualRoots = await cdp.send("Runtime.evaluate", {
		expression: "['/builtin/README.txt', '/game/init.lua', '/user/saves', '/user/settings', '/user/projects', '/tmp'].map(path => [path, Module.FS.analyzePath(path).exists])",
		returnByValue: true,
	});
	assert.deepEqual(virtualRoots.result.value, [
		["/builtin/README.txt", true],
		["/game/init.lua", true],
		["/user/saves", true],
		["/user/settings", true],
		["/user/projects", true],
		["/tmp", true],
	], "Web virtual filesystem roots are incomplete");
	const platformContract = await cdp.send("Runtime.evaluate", {
		expression: `({
			available: typeof DoraWebPlatform?.pickFiles === 'function',
			shared: DoraWebPlatform === Module.doraWebPlatform,
			capabilities: DoraWebPlatform.capabilities,
			state: DoraWebPlatform.state,
		})`,
		returnByValue: true,
	});
	assert.equal(platformContract.result.value.available, true, "Dora Web platform API is unavailable");
	assert.equal(platformContract.result.value.shared, true, "Module does not expose the shared Web platform API");
	assert.equal(platformContract.result.value.capabilities.keyboard, true);
	assert.equal(platformContract.result.value.capabilities.mouse, true);
	assert.equal(platformContract.result.value.capabilities.fileInput, true);
	assert.equal(platformContract.result.value.capabilities.ime, true);
	assert.equal(platformContract.result.value.state.active, true);

	await cdp.send("Page.bringToFront");
	await cdp.send("Runtime.evaluate", {expression: "DoraWebPlatform.setSuspended(false, 'browser-smoke-input')", awaitPromise: true});
	await cdp.send("Input.dispatchMouseEvent", {type: "mousePressed", x: 640, y: 360, button: "left", buttons: 1, clickCount: 1});
	await cdp.send("Input.dispatchMouseEvent", {type: "mouseReleased", x: 640, y: 360, button: "left", buttons: 0, clickCount: 1});
	await cdp.send("Runtime.evaluate", {expression: "Module.canvas.focus()"});
	await new Promise((resolve) => setTimeout(resolve, 100));
	await cdp.send("Input.dispatchKeyEvent", {type: "keyDown", key: "a", code: "KeyA", windowsVirtualKeyCode: 65, nativeVirtualKeyCode: 65});
	await waitForConsole(consoleMessages, (message) => message.includes("Dora Web input key=A pressed=true"), "Dora key-down state");
	await cdp.send("Input.dispatchKeyEvent", {type: "keyUp", key: "A", code: "KeyA", windowsVirtualKeyCode: 65, nativeVirtualKeyCode: 65});
	await waitForConsole(consoleMessages, (message) => message.includes("Dora Web input key=A pressed=false"), "Dora key-up state");
	const keyDownCount = consoleMessages.filter((message) => message.includes("Dora Web input key=A pressed=true")).length;
	await cdp.send("Input.dispatchKeyEvent", {type: "keyDown", key: "a", code: "KeyA", windowsVirtualKeyCode: 65, nativeVirtualKeyCode: 65});
	const secondKeyDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web input key=A pressed=true")).length <= keyDownCount && Date.now() < secondKeyDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	assert.ok(consoleMessages.filter((message) => message.includes("Dora Web input key=A pressed=true")).length > keyDownCount, "second Dora key-down was not observed");
	await cdp.send("Runtime.evaluate", {expression: "window.dispatchEvent(new Event('blur'))"});
	const keyUpCount = consoleMessages.filter((message) => message.includes("Dora Web input key=A pressed=false")).length;
	const blurDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web input key=A pressed=false")).length <= keyUpCount && Date.now() < blurDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	assert.ok(consoleMessages.filter((message) => message.includes("Dora Web input key=A pressed=false")).length > keyUpCount, "blur did not synthesize Dora key release");
	const releasedInput = await cdp.send("Runtime.evaluate", {expression: "DoraWebPlatform.state.pressedKeys", returnByValue: true});
	assert.equal(releasedInput.result.value, 0, "host key state remained pressed after blur");

	const mouseDownCount = consoleMessages.filter((message) => message.includes("Dora Web input mouse-left=true")).length;
	await cdp.send("Input.dispatchMouseEvent", {type: "mouseMoved", x: 320, y: 240});
	await cdp.send("Input.dispatchMouseEvent", {type: "mousePressed", x: 320, y: 240, button: "left", buttons: 1, clickCount: 1});
	const mouseDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web input mouse-left=true")).length <= mouseDownCount && Date.now() < mouseDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	assert.ok(consoleMessages.filter((message) => message.includes("Dora Web input mouse-left=true")).length > mouseDownCount, "second Dora mouse-down was not observed");
	const mouseMessage = [...consoleMessages].reverse().find((message) => message.includes("Dora Web input mouse-left=true"));
	const mouseMatch = mouseMessage.match(/x=(-?[\d.]+) y=(-?[\d.]+)/);
	assert.ok(mouseMatch, `Dora mouse position was not logged: ${mouseMessage}`);
	assert.ok(Math.abs(Number(mouseMatch[1]) - 320) <= 2 && Math.abs(Number(mouseMatch[2]) - 240) <= 2, `Dora mouse coordinates changed: ${mouseMessage}`);
	await cdp.send("Input.dispatchMouseEvent", {type: "mouseReleased", x: 320, y: 240, button: "left", buttons: 0, clickCount: 1});
	await waitForConsole(consoleMessages, (message) => message.includes("Dora Web input mouse-left=false"), "Dora mouse-up state");
	await cdp.send("Input.dispatchMouseEvent", {type: "mouseWheel", x: 320, y: 240, deltaX: 0, deltaY: 120});
	await waitForConsole(consoleMessages, (message) => message.includes("Dora Web input wheel"), "Dora mouse-wheel state");
	await cdp.send("Emulation.setTouchEmulationEnabled", {enabled: true, maxTouchPoints: 5});
	const touchStartCount = consoleMessages.filter((message) => message.includes("Dora Web input touch-began")).length;
	await cdp.send("Input.dispatchTouchEvent", {
		type: "touchStart",
		touchPoints: [
			{x: 180, y: 180, id: 11, radiusX: 4, radiusY: 4, force: 1},
			{x: 420, y: 300, id: 22, radiusX: 4, radiusY: 4, force: 1},
		],
	});
	const touchStartDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web input touch-began")).length < touchStartCount + 2 && Date.now() < touchStartDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	const touchBegins = consoleMessages.filter((message) => message.includes("Dora Web input touch-began")).slice(touchStartCount);
	assert.equal(touchBegins.length, 2, `Dora did not receive two touch points: ${JSON.stringify(touchBegins)}`);
	const touchIds = touchBegins.map((message) => Number(message.match(/id=(\d+)/)?.[1]));
	assert.equal(new Set(touchIds).size, 2, `Dora touch IDs were not distinct: ${JSON.stringify(touchBegins)}`);
	await cdp.send("Input.dispatchTouchEvent", {
		type: "touchMove",
		touchPoints: [
			{x: 200, y: 190, id: 11, radiusX: 4, radiusY: 4, force: 1},
			{x: 440, y: 320, id: 22, radiusX: 4, radiusY: 4, force: 1},
		],
	});
	await waitForConsole(consoleMessages, (message) => message.includes("Dora Web input touch-moved"), "Dora touch-move state");
	const touchEndCount = consoleMessages.filter((message) => message.includes("Dora Web input touch-ended")).length;
	await cdp.send("Input.dispatchTouchEvent", {type: "touchEnd", touchPoints: []});
	const touchEndDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web input touch-ended")).length < touchEndCount + 2 && Date.now() < touchEndDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	assert.equal(consoleMessages.filter((message) => message.includes("Dora Web input touch-ended")).length, touchEndCount + 2, "Dora did not release both touch points");
	const cancelStartCount = consoleMessages.filter((message) => message.includes("Dora Web input touch-began")).length;
	const cancelEndCount = consoleMessages.filter((message) => message.includes("Dora Web input touch-ended")).length;
	await cdp.send("Input.dispatchTouchEvent", {
		type: "touchStart",
		touchPoints: [{x: 260, y: 220, id: 33, radiusX: 4, radiusY: 4, force: 1}],
	});
	const cancelStartDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web input touch-began")).length <= cancelStartCount && Date.now() < cancelStartDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	assert.ok(consoleMessages.filter((message) => message.includes("Dora Web input touch-began")).length > cancelStartCount, "Dora did not receive touch point before cancellation");
	await cdp.send("Input.dispatchTouchEvent", {type: "touchCancel", touchPoints: []});
	const cancelEndDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web input touch-ended")).length <= cancelEndCount && Date.now() < cancelEndDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	assert.ok(consoleMessages.filter((message) => message.includes("Dora Web input touch-ended")).length > cancelEndCount, "Dora did not release cancelled touch point");
	await cdp.send("Emulation.setTouchEmulationEnabled", {enabled: false});

	await cdp.send("Runtime.evaluate", {
		expression: `(function() {
			const state = globalThis.__doraGamepadState = {
				connected: true,
				timestamp: performance.now(),
				axes: [0, 0, 0, 0],
				buttons: Array.from({length: 17}, () => ({pressed: false, touched: false, value: 0})),
			};
			const gamepad = globalThis.__doraGamepad = {
				id: 'Dora Web Test Gamepad',
				index: 0,
				mapping: 'standard',
				get connected() { return state.connected; },
				get timestamp() { return state.timestamp; },
				get axes() { return state.axes; },
				get buttons() { return state.buttons; },
			};
			Object.defineProperty(navigator, 'getGamepads', {
				configurable: true,
				value: () => state.connected ? [gamepad] : [],
			});
			globalThis.__doraEmitGamepad = type => {
				const event = new Event(type);
				Object.defineProperty(event, 'gamepad', {value: gamepad});
				dispatchEvent(event);
			};
			__doraEmitGamepad('gamepadconnected');
		})()`,
	});
	await new Promise((resolve) => setTimeout(resolve, 100));
	const gamepadPressedCount = consoleMessages.filter((message) => message.includes("Dora Web gamepad a=true")).length;
	await cdp.send("Runtime.evaluate", {
		expression: `__doraGamepadState.buttons[0] = {pressed: true, touched: true, value: 1};
			__doraGamepadState.axes = [0.5, 0, 0, 0];
			__doraGamepadState.timestamp += 100;`,
	});
	await new Promise((resolve) => setTimeout(resolve, 50));
	await cdp.send("Runtime.evaluate", {
		expression: `__doraGamepadState.axes = [1, 0, 0, 0];
			__doraGamepadState.timestamp += 100;`,
	});
	const gamepadPressDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web gamepad a=true")).length <= gamepadPressedCount && Date.now() < gamepadPressDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	assert.ok(consoleMessages.filter((message) => message.includes("Dora Web gamepad a=true")).length > gamepadPressedCount, "Dora did not receive Gamepad A press");
	await waitForConsole(consoleMessages, (message) => /Dora Web gamepad (axis .* value=1\.000|leftx=1\.000)/.test(message), "Dora Gamepad leftx axis");
	const gamepadReleasedCount = consoleMessages.filter((message) => message.includes("Dora Web gamepad a=false")).length;
	await cdp.send("Runtime.evaluate", {expression: "dispatchEvent(new Event('blur'))"});
	const gamepadBlurDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web gamepad a=false")).length <= gamepadReleasedCount && Date.now() < gamepadBlurDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	assert.ok(consoleMessages.filter((message) => message.includes("Dora Web gamepad a=false")).length > gamepadReleasedCount, "Dora did not release Gamepad state on blur");
	await waitForConsole(consoleMessages, (message) => /Dora Web gamepad leftx=0\.000/.test(message), "Dora Gamepad axis release on blur");
	await cdp.send("Runtime.evaluate", {
		expression: `__doraGamepadState.buttons[0] = {pressed: false, touched: false, value: 0};
			__doraGamepadState.axes = [0, 0, 0, 0];
			__doraGamepadState.timestamp += 100;`,
	});
	await new Promise((resolve) => setTimeout(resolve, 50));
	await cdp.send("Page.bringToFront");
	const gamepadRepressCount = consoleMessages.filter((message) => message.includes("Dora Web gamepad a=true")).length;
	await cdp.send("Runtime.evaluate", {
		expression: `__doraGamepadState.buttons[0] = {pressed: true, touched: true, value: 1};
			__doraGamepadState.axes = [-0.5, 0, 0, 0];
			__doraGamepadState.timestamp += 100;`,
	});
	const gamepadRepressDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web gamepad a=true")).length <= gamepadRepressCount && Date.now() < gamepadRepressDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	assert.ok(consoleMessages.filter((message) => message.includes("Dora Web gamepad a=true")).length > gamepadRepressCount, "Dora did not resume Gamepad input after focus");
	const gamepadDisconnectCount = consoleMessages.filter((message) => message.includes("Dora Web gamepad a=false")).length;
	await cdp.send("Runtime.evaluate", {
		expression: `__doraGamepadState.connected = false;
			__doraGamepadState.timestamp += 100;
			__doraEmitGamepad('gamepaddisconnected');`,
	});
	const gamepadDisconnectDeadline = Date.now() + 5000;
	while (consoleMessages.filter((message) => message.includes("Dora Web gamepad a=false")).length <= gamepadDisconnectCount && Date.now() < gamepadDisconnectDeadline) {
		await new Promise((resolve) => setTimeout(resolve, 25));
	}
	assert.ok(consoleMessages.filter((message) => message.includes("Dora Web gamepad a=false")).length > gamepadDisconnectCount, "Dora retained Gamepad state after disconnect");

	const audioUnlocked = await cdp.send("Runtime.evaluate", {
		expression: `(async function() {
			const result = await DoraWebPlatform.unlockAudio();
			return {result, state: DoraWebPlatform.state};
		})()`,
		awaitPromise: true,
		returnByValue: true,
	});
	assert.equal(audioUnlocked.result.value.result.supported, true, "SDL2 AudioContext is unavailable");
	assert.equal(audioUnlocked.result.value.state.audioUnlocked, true, "AudioContext was not unlocked");
	assert.equal(audioUnlocked.result.value.state.audioState, "running", "AudioContext did not enter running state");
	assert.ok(consoleMessages.some((message) => message.includes("Dora Web WAV/OGG play/loop/pause/volume/stop verified")), "Dora WAV/OGG playback controls did not complete");
	const visibilityLifecycle = await cdp.send("Runtime.evaluate", {
		expression: `(async function() {
			const events = [];
			const listener = event => events.push(event.detail);
			addEventListener('dora-visibilitychange', listener);
			const hidden = await DoraWebPlatform.setSuspended(true, 'browser-smoke');
			await new Promise(resolve => setTimeout(resolve, 120));
			const hiddenAgain = await DoraWebPlatform.setSuspended(true, 'browser-smoke-repeat');
			const shown = await DoraWebPlatform.setSuspended(false, 'browser-smoke');
			await new Promise(resolve => setTimeout(resolve, 120));
			const shownAgain = await DoraWebPlatform.setSuspended(false, 'browser-smoke-repeat');
			removeEventListener('dora-visibilitychange', listener);
			return {hidden, hiddenAgain, shown, shownAgain, events, state: DoraWebPlatform.state};
		})()`,
		awaitPromise: true,
		returnByValue: true,
	});
	assert.equal(visibilityLifecycle.result.value.hidden.suspended, true);
	assert.equal(visibilityLifecycle.result.value.hidden.audioState, "suspended");
	assert.equal(visibilityLifecycle.result.value.hiddenAgain.engineFrame, visibilityLifecycle.result.value.hidden.engineFrame, "Dora engine frame advanced while suspended");
	assert.equal(visibilityLifecycle.result.value.shown.suspended, false);
	assert.equal(visibilityLifecycle.result.value.shown.audioState, "running");
	assert.ok(visibilityLifecycle.result.value.shownAgain.engineFrame > visibilityLifecycle.result.value.shown.engineFrame, "Dora engine frame did not resume after suspension");
	assert.equal(visibilityLifecycle.result.value.events.length, 2);
	await cdp.send("Runtime.evaluate", {expression: "globalThis.__doraNativeVisibilityEvents = []; addEventListener('dora-visibilitychange', event => __doraNativeVisibilityEvents.push(event.detail))"});
	const visibilityTargetResponse = await fetch(`http://127.0.0.1:${port}/json/new?about%3Ablank`, {method: "PUT"});
	assert.equal(visibilityTargetResponse.ok, true, "failed to create the visibility test tab");
	const visibilityTarget = await visibilityTargetResponse.json();
	try {
		const backgroundResponse = await fetch(`http://127.0.0.1:${port}/json/activate/${visibilityTarget.id}`);
		assert.equal(backgroundResponse.ok, true, "failed to background the Dora tab");
		let nativeVisibility;
		const hiddenDeadline = Date.now() + 5000;
		do {
			await new Promise((resolve) => setTimeout(resolve, 25));
			const result = await cdp.send("Runtime.evaluate", {expression: "({visibility: document.visibilityState, state: DoraWebPlatform.state, events: __doraNativeVisibilityEvents})", returnByValue: true});
			nativeVisibility = result.result.value;
		} while (nativeVisibility.visibility !== "hidden" && Date.now() < hiddenDeadline);
		assert.equal(nativeVisibility.visibility, "hidden", "background tab did not become hidden");
		assert.equal(nativeVisibility.state.suspended, true, "background tab did not suspend DoraWebPlatform");
		assert.equal(nativeVisibility.state.audioState, "suspended", "background tab did not suspend AudioContext");

		const foregroundResponse = await fetch(`http://127.0.0.1:${port}/json/activate/${target.id}`);
		assert.equal(foregroundResponse.ok, true, "failed to restore the Dora tab");
		const visibleDeadline = Date.now() + 5000;
		do {
			await new Promise((resolve) => setTimeout(resolve, 25));
			const result = await cdp.send("Runtime.evaluate", {expression: "({visibility: document.visibilityState, state: DoraWebPlatform.state, events: __doraNativeVisibilityEvents})", returnByValue: true});
			nativeVisibility = result.result.value;
		} while ((nativeVisibility.visibility !== "visible" || nativeVisibility.state.suspended || nativeVisibility.state.audioState !== "running") && Date.now() < visibleDeadline);
		assert.equal(nativeVisibility.visibility, "visible", "foreground tab did not become visible");
		assert.equal(nativeVisibility.state.suspended, false, "foreground tab did not resume DoraWebPlatform");
		assert.equal(nativeVisibility.state.audioState, "running", "foreground tab did not resume AudioContext");
		assert.ok(nativeVisibility.events.some((event) => event.suspended && event.reason === "visibility"), "native hidden event did not reach DoraWebPlatform");
		assert.ok(nativeVisibility.events.some((event) => !event.suspended && event.reason === "visibility"), "native visible event did not reach DoraWebPlatform");
	} finally {
		await fetch(`http://127.0.0.1:${port}/json/activate/${target.id}`).catch(() => {});
		await fetch(`http://127.0.0.1:${port}/json/close/${visibilityTarget.id}`).catch(() => {});
	}
	const filePickerContract = await cdp.send("Runtime.evaluate", {
		expression: `(async function() {
			const originalPicker = window.showOpenFilePicker;
			const originalClick = HTMLInputElement.prototype.click;
			try {
				window.showOpenFilePicker = async () => [{getFile: async () => new File(['native'], 'native.dora')}];
				const native = await DoraWebPlatform.pickFiles();
				HTMLInputElement.prototype.click = function() {
					Object.defineProperty(this, 'files', {value: [new File(['fallback'], 'fallback.dora')]});
					this.dispatchEvent(new Event('change'));
				};
				const fallback = await DoraWebPlatform.pickFiles({preferNative: false, accept: '.dora'});
				return {native: native.map(file => [file.name, file.size]), fallback: fallback.map(file => [file.name, file.size])};
			} finally {
				window.showOpenFilePicker = originalPicker;
				HTMLInputElement.prototype.click = originalClick;
			}
		})()`,
		awaitPromise: true,
		returnByValue: true,
	});
	assert.deepEqual(filePickerContract.result.value, {native: [["native.dora", 6]], fallback: [["fallback.dora", 8]]});
	const pickerFixturePath = path.join(profile, "browser-picker.dora");
	fs.writeFileSync(pickerFixturePath, "picker");
	await cdp.send("Page.setInterceptFileChooserDialog", {enabled: true});
	let removeFileChooserListener;
	const fileChooserHandled = new Promise((resolve, reject) => {
		removeFileChooserListener = cdp.onEvent((message) => {
			if (message.method !== "Page.fileChooserOpened") return;
			void cdp.send("DOM.setFileInputFiles", {
				files: [pickerFixturePath],
				backendNodeId: message.params.backendNodeId,
			}).then(resolve, reject);
		});
	});
	let realFallbackPicker;
	try {
		const pickerEvaluation = cdp.send("Runtime.evaluate", {
			expression: `(async function() {
				const files = await DoraWebPlatform.pickFiles({preferNative: false, accept: '.dora'});
				return files.map(file => [file.name, file.size]);
			})()`,
			awaitPromise: true,
			returnByValue: true,
		});
		const timeout = new Promise((_, reject) => setTimeout(() => reject(new Error("timed out waiting for the real file chooser")), 5000));
		[realFallbackPicker] = await Promise.all([pickerEvaluation, Promise.race([fileChooserHandled, timeout])]);
	} finally {
		removeFileChooserListener?.();
		await cdp.send("Page.setInterceptFileChooserDialog", {enabled: false});
	}
	assert.deepEqual(realFallbackPicker.result.value, [["browser-picker.dora", 6]], "real fallback file chooser did not return the selected File");
	const platformCapabilities = await cdp.send("Runtime.evaluate", {expression: "DoraWebPlatform.capabilities", returnByValue: true});
	assert.equal(platformCapabilities.result.value.ime, true, "IME composition capability was not detected");
	assert.equal(platformCapabilities.result.value.clipboardRead, true, "Clipboard read capability was not detected");
	assert.equal(platformCapabilities.result.value.clipboardWrite, true, "Clipboard write capability was not detected");
	assert.equal(platformCapabilities.result.value.pointerLock, true, "Pointer Lock capability was not detected");
	await cdp.send("Browser.grantPermissions", {
		origin: `http://127.0.0.1:${address.port}`,
		permissions: ["clipboardReadWrite", "clipboardSanitizedWrite"],
	});
	const clipboardContract = await cdp.send("Runtime.evaluate", {
		expression: `(async function() {
			await DoraWebPlatform.writeClipboard('Dora Web clipboard');
			return DoraWebPlatform.readClipboard();
		})()`,
		awaitPromise: true,
		returnByValue: true,
	});
	assert.equal(clipboardContract.result.value, "Dora Web clipboard", "Clipboard read/write round trip failed");
	await cdp.send("Runtime.evaluate", {
		expression: `Module.canvas.addEventListener('click', async function lock() {
			Module.canvas.removeEventListener('click', lock);
			globalThis.__doraPointerLockResult = await DoraWebPlatform.requestPointerLock();
		}, {once: true})`,
	});
	await cdp.send("Input.dispatchMouseEvent", {type: "mousePressed", x: 640, y: 360, button: "left", clickCount: 1});
	await cdp.send("Input.dispatchMouseEvent", {type: "mouseReleased", x: 640, y: 360, button: "left", clickCount: 1});
	const pointerLockDeadline = Date.now() + 5000;
	let pointerLockResult;
	do {
		await new Promise((resolve) => setTimeout(resolve, 25));
		const result = await cdp.send("Runtime.evaluate", {expression: "({result: globalThis.__doraPointerLockResult, locked: document.pointerLockElement === Module.canvas})", returnByValue: true});
		pointerLockResult = result.result.value;
	} while (!pointerLockResult.locked && Date.now() < pointerLockDeadline);
	assert.equal(pointerLockResult.result, true, "DoraWebPlatform did not report Pointer Lock acquisition");
	assert.equal(pointerLockResult.locked, true, "Canvas did not acquire Pointer Lock");
	await cdp.send("Runtime.evaluate", {expression: "document.exitPointerLock()"});
	const networkContract = await cdp.send("Runtime.evaluate", {
		expression: `(async function() {
			const result = {};
			result.capabilities = DoraWebNetwork.capabilities;
			result.moduleCapabilities = Module.doraWebCapabilities;
			const get = await DoraWebNetwork.get('/__dora_test__/http/get').promise;
			result.get = {status: get.status, header: get.headers['x-dora-test'], body: JSON.parse(get.text())};
			const post = await DoraWebNetwork.post('/__dora_test__/http/post', 'posted').promise;
			result.post = {status: post.status, body: post.text()};
			const status = await DoraWebNetwork.get('/__dora_test__/http/status').promise;
			result.status = {ok: status.ok, status: status.status, body: status.text()};
			try { await DoraWebNetwork.get('/__dora_test__/http/slow', {timeoutMs: 20}).promise; }
			catch (error) { result.timeout = error.code; }
			const cancelled = DoraWebNetwork.get('/__dora_test__/http/slow');
			setTimeout(() => cancelled.cancel(), 20);
			try { await cancelled.promise; } catch (error) { result.cancel = error.code; }
			const progress = [];
			const streamed = await DoraWebNetwork.get('/__dora_test__/http/stream', {onProgress: (current, total) => progress.push([current, total])}).promise;
			result.progress = {bytes: streamed.body.byteLength, events: progress};
			try { await DoraWebNetwork.get('/__dora_test__/http/large', {maxBytes: 1024}).promise; }
			catch (error) { result.limit = error.code; }
			try { DoraWebNetwork.get('/__dora_test__/http/get', {maxBytes: DoraWebNetwork.HARD_MAX_RESPONSE_BYTES + 1}); }
			catch (error) { result.hardLimit = error.code; }
			try { DoraWebNetwork.get('https://example.com/'); } catch (error) { result.origin = error.code; }
			result.httpServer = DoraWebNetwork.startHttpServer();
			result.webSocketServer = DoraWebNetwork.startWebSocketServer();
			return result;
		})()`,
		awaitPromise: true,
		returnByValue: true,
	});
	assert.equal(networkContract.exceptionDetails, undefined, `Web network contract failed: ${networkContract.exceptionDetails?.text || "unknown error"}`);
	const network = networkContract.result.value;
	assert.deepEqual(network.get, {status: 200, header: "get", body: {method: "GET", ready: true}});
	assert.deepEqual(network.post, {status: 201, body: "posted"});
	assert.deepEqual(network.status, {ok: false, status: 418, body: "teapot"});
	assert.equal(network.timeout, "TIMEOUT");
	assert.equal(network.cancel, "CANCELLED");
	assert.equal(network.progress.bytes, 2048);
	assert.ok(network.progress.events.length >= 1, "streaming response did not report progress");
	assert.equal(network.progress.events.at(-1)[0], 2048);
	assert.equal(network.limit, "SIZE");
	assert.equal(network.hardLimit, "LIMIT");
	assert.equal(network.origin, "ORIGIN");
	assert.equal(network.capabilities.httpClient, true);
	assert.equal(network.capabilities.httpServer, false);
	assert.deepEqual(network.moduleCapabilities, network.capabilities);
	assert.deepEqual(network.httpServer, {supported: false, kind: "http", reason: "browser pages cannot bind inbound TCP/HTTP ports"});
	assert.deepEqual(network.webSocketServer, {supported: false, kind: "websocket", reason: "browser pages cannot bind inbound TCP/HTTP ports"});
	const packageInstall = await cdp.send("Runtime.evaluate", {
		expression: `(async function() {
			const response = await fetch('/__dora_test__/package.dora', {cache: 'no-store'});
			const inspected = await DoraWebPackage.inspectPackage(await response.arrayBuffer());
			const target = await DoraWebPackage.installPackage(Module, inspected, 'browser-import');
			return {target, source: Module.FS.readFile(target + '/init.lua', {encoding: 'utf8'})};
		})()`,
		awaitPromise: true,
		returnByValue: true,
	});
	assert.equal(packageInstall.exceptionDetails, undefined, `.dora package install failed: ${packageInstall.exceptionDetails?.text || "unknown error"}`);
	assert.deepEqual(packageInstall.result.value, {target: "/user/projects/browser-import", source: "print('browser package import ready')"});
	await cdp.send("Page.reload", {ignoreCache: false});
	await waitForReadyCount(consoleMessages, 2, chromeErrors);
	const warmStartup = await startupTiming(cdp, "warm");
	assert.ok(warmStartup.marks["dora-state-running"] <= 2000, `warm engine startup exceeded 2 seconds: ${JSON.stringify(warmStartup)}`);
	assert.ok(warmStartup.total <= 2000, `warm fixture startup exceeded 2 seconds: ${JSON.stringify(warmStartup)}`);
	for (const [name, resource] of [["JavaScript", warmStartup.javascript], ["WASM", warmStartup.wasm], ["data", warmStartup.data]]) {
		assert.equal(resource.transferSize, 0, `warm ${name} was not served from browser cache: ${JSON.stringify(resource)}`);
	}
	assert.equal(warmStartup.gameAssets.transferSize, 0, `warm game assets were not served from browser cache: ${JSON.stringify(warmStartup.gameAssets)}`);
	const artifactSizes = startupArtifactSizes();
	const gzipBudget = 20 * 1024 * 1024;
	assert.ok(artifactSizes.runtimeTotals.gzip <= gzipBudget, `runtime gzip size exceeded 20 MiB: ${JSON.stringify(artifactSizes.runtimeTotals)}`);
	const startupPerformancePath = reportPath("web-startup-performance");
	fs.mkdirSync(path.dirname(startupPerformancePath), {recursive: true});
	fs.writeFileSync(startupPerformancePath, `${JSON.stringify({
		schemaVersion: 1,
		browser,
		budgets: {coldMilliseconds: 5000, warmMilliseconds: 2000, runtimeGzipBytes: gzipBudget},
		artifacts: artifactSizes,
		cold: coldStartup,
		warm: warmStartup,
	}, null, 2)}\n`);
	const persistedPackage = await cdp.send("Runtime.evaluate", {
		expression: "Module.FS.readFile('/user/projects/browser-import/init.lua', {encoding: 'utf8'})",
		returnByValue: true,
	});
	assert.equal(persistedPackage.result.value, "print('browser package import ready')", ".dora package did not survive IDBFS reload");
	const batchedStorage = await cdp.send("Runtime.evaluate", {
		expression: `(async function() {
			Module.FS.writeFile('/user/settings/browser-batch.txt', 'batched storage ready');
			const first = Module.doraQueueUserStorageSync(20);
			const second = Module.doraQueueUserStorageSync(0);
			const shared = first === second;
			await first;
			return shared;
		})()`,
		awaitPromise: true,
		returnByValue: true,
	});
	assert.equal(batchedStorage.result.value, true, "IDBFS queued writes did not share a batch");
	await cdp.send("Page.reload", {ignoreCache: true});
	await waitForReadyCount(consoleMessages, 3, chromeErrors);
	const persistedBatch = await cdp.send("Runtime.evaluate", {
		expression: "Module.FS.readFile('/user/settings/browser-batch.txt', {encoding: 'utf8'})",
		returnByValue: true,
	});
	assert.equal(persistedBatch.result.value, "batched storage ready", "batched IDBFS write did not survive reload");
	const baselineMemory = await memorySnapshot(cdp);
	for (let reload = 1; reload <= reloadCount; reload++) {
		await cdp.send("Page.reload", {ignoreCache: true});
		await waitForReadyCount(consoleMessages, reload + 3, chromeErrors);
	}
	const finalMemory = await memorySnapshot(cdp);
	const soakReport = await runSoak(cdp, soakSeconds, soakSampleSeconds, pageErrors, pageWarnings);
	if (soakReport) {
		const soakReportPath = reportPath("web-soak-report");
		fs.mkdirSync(path.dirname(soakReportPath), {recursive: true});
		fs.writeFileSync(soakReportPath, `${JSON.stringify({schemaVersion: 1, browser, ...soakReport}, null, 2)}\n`);
		console.log(`[INFO] Browser soak report: ${soakReportPath}`);
	}
	const expectedHttpProbeErrors = pageErrors.filter((error) => /status of 418 \(I'm a Teapot\)/.test(error));
	const expectedTouchCancelErrors = pageErrors.filter((error) => /Ignored attempt to cancel a touchcancel event with cancelable=false/.test(error));
	const expectedProbeErrors = new Set([...expectedHttpProbeErrors, ...expectedTouchCancelErrors]);
	const unexpectedPageErrors = pageErrors.filter((error) => !expectedProbeErrors.has(error));
	assert.equal(expectedHttpProbeErrors.length, 1, `expected exactly one HTTP 418 browser log:\n${pageErrors.join("\n")}`);
	assert.equal(expectedTouchCancelErrors.length, 1, `expected exactly one touchcancel browser log:\n${pageErrors.join("\n")}`);
	assert.deepEqual(unexpectedPageErrors, [], `browser errors:\n${unexpectedPageErrors.join("\n")}`);
	const lifecycleWarnings = pageWarnings.filter((warning) => /context lost|too many active WebGL|GL_OUT_OF_MEMORY|out of memory/i.test(warning));
	assert.deepEqual(lifecycleWarnings, [], `browser lifecycle warnings:\n${lifecycleWarnings.join("\n")}`);
	if (reloadCount > 0) {
		assert.ok(finalMemory.documents <= baselineMemory.documents + 1, `documents accumulated across reloads: ${JSON.stringify({baselineMemory, finalMemory})}`);
		assert.ok(finalMemory.nodes <= baselineMemory.nodes + 50, `DOM nodes accumulated across reloads: ${JSON.stringify({baselineMemory, finalMemory})}`);
		assert.ok(finalMemory.listeners <= baselineMemory.listeners + 10, `event listeners accumulated across reloads: ${JSON.stringify({baselineMemory, finalMemory})}`);
		assert.ok(finalMemory.jsHeapUsed <= baselineMemory.jsHeapUsed + 8 * 1024 * 1024, `JS heap grew beyond reload allowance: ${JSON.stringify({baselineMemory, finalMemory})}`);
	}
	await new Promise((resolve) => setTimeout(resolve, 250));
	const capture = await cdp.send("Page.captureScreenshot", {format: "png", fromSurface: true});
	const screenshot = Buffer.from(capture.data, "base64");
	fs.mkdirSync(path.dirname(screenshotPath), {recursive: true});
	fs.writeFileSync(screenshotPath, screenshot);
	const regions = assertFixture(decodePng(screenshot));
	const stopped = await cdp.send("Runtime.evaluate", {
		expression: `(async function() {
			const changed = new Promise(resolve => addEventListener('dora-statechange', event => {
				if (event.detail.state === 'stopped') resolve(true);
			}, {once: false}));
			const accepted = doraStop();
			await Promise.race([changed, new Promise(resolve => setTimeout(() => resolve(false), 5000))]);
			return {
				accepted,
				runtime: document.documentElement.dataset.doraState,
				platform: DoraWebPlatform.state,
				audioDeviceClosed: !Module.SDL2?.audio && !Module.SDL2?.audioContext,
			};
		})()`,
		awaitPromise: true,
		returnByValue: true,
	});
	assert.equal(stopped.result.value.accepted, true, "Web stop request was rejected");
	assert.equal(stopped.result.value.runtime, "stopped", "Web runtime did not stop");
	assert.equal(stopped.result.value.platform.active, false, "Web platform listeners were not disposed on stop");
	assert.ok(["suspended", "unavailable"].includes(stopped.result.value.platform.audioState), "AudioContext remained active after stop");
	assert.equal(stopped.result.value.audioDeviceClosed, true, "SDL audio device or AudioContext remained reachable after stop");
	const advancedTextureProbe = await cdp.send("Runtime.evaluate", {
		expression: `(() => {
			const gl = document.querySelector("canvas")?.getContext("webgl2");
			if (!gl) return {webgl2: false};
			const extensions = gl.getSupportedExtensions() || [];
			const probe = (internalFormat, format, type, attachment) => {
				while (gl.getError() !== gl.NO_ERROR) {}
				const texture = gl.createTexture();
				const framebuffer = gl.createFramebuffer();
				gl.bindTexture(gl.TEXTURE_2D, texture);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
				gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat, 4, 4, 0, format, type, null);
				gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
				gl.framebufferTexture2D(gl.FRAMEBUFFER, attachment, gl.TEXTURE_2D, texture, 0);
				const status = gl.checkFramebufferStatus(gl.FRAMEBUFFER);
				const error = gl.getError();
				gl.bindFramebuffer(gl.FRAMEBUFFER, null);
				gl.bindTexture(gl.TEXTURE_2D, null);
				gl.deleteFramebuffer(framebuffer);
				gl.deleteTexture(texture);
				return {complete: status === gl.FRAMEBUFFER_COMPLETE, status, error};
			};
			const debug = gl.getExtension("WEBGL_debug_renderer_info");
			return {
				webgl2: typeof gl.texImage3D === "function",
				renderer: debug ? gl.getParameter(debug.UNMASKED_RENDERER_WEBGL) : "masked",
				maxTextureSize: gl.getParameter(gl.MAX_TEXTURE_SIZE),
				maxColorAttachments: gl.getParameter(gl.MAX_COLOR_ATTACHMENTS),
				colorBufferFloat: extensions.includes("EXT_color_buffer_float"),
				floatLinear: extensions.includes("OES_texture_float_linear"),
				anisotropic: extensions.some((name) => name.includes("texture_filter_anisotropic")),
				compressed: {
					s3tc: extensions.includes("WEBGL_compressed_texture_s3tc"),
					s3tcSrgb: extensions.includes("WEBGL_compressed_texture_s3tc_srgb"),
					etc: extensions.includes("WEBGL_compressed_texture_etc"),
					astc: extensions.includes("WEBGL_compressed_texture_astc"),
					pvrtc: extensions.some((name) => name.includes("compressed_texture_pvrtc")),
				},
				rgba8: probe(gl.RGBA8, gl.RGBA, gl.UNSIGNED_BYTE, gl.COLOR_ATTACHMENT0),
				rgba16f: probe(gl.RGBA16F, gl.RGBA, gl.HALF_FLOAT, gl.COLOR_ATTACHMENT0),
				rgba32f: probe(gl.RGBA32F, gl.RGBA, gl.FLOAT, gl.COLOR_ATTACHMENT0),
				depth24Stencil8: probe(gl.DEPTH24_STENCIL8, gl.DEPTH_STENCIL, gl.UNSIGNED_INT_24_8, gl.DEPTH_STENCIL_ATTACHMENT),
			};
		})()`,
		returnByValue: true,
	});
	assert.equal(advancedTextureProbe.exceptionDetails, undefined, `advanced WebGL2 texture probe failed: ${advancedTextureProbe.exceptionDetails?.text || "unknown error"}`);
	const advancedTextureCaps = advancedTextureProbe.result.value;
	assert.equal(advancedTextureCaps.webgl2, true, "Web Player did not retain a WebGL2 context");
	assert.ok(advancedTextureCaps.maxTextureSize >= 4096, `WebGL2 max texture size is below the Player baseline: ${JSON.stringify(advancedTextureCaps)}`);
	assert.equal(advancedTextureCaps.rgba8.complete && advancedTextureCaps.rgba8.error === 0, true, `RGBA8 framebuffer probe failed: ${JSON.stringify(advancedTextureCaps.rgba8)}`);
	assert.equal(advancedTextureCaps.depth24Stencil8.complete && advancedTextureCaps.depth24Stencil8.error === 0, true, `D24S8 framebuffer probe failed: ${JSON.stringify(advancedTextureCaps.depth24Stencil8)}`);
	if (advancedTextureCaps.colorBufferFloat) {
		assert.equal(advancedTextureCaps.rgba16f.complete && advancedTextureCaps.rgba16f.error === 0, true, `EXT_color_buffer_float did not provide RGBA16F rendering: ${JSON.stringify(advancedTextureCaps.rgba16f)}`);
		assert.equal(advancedTextureCaps.rgba32f.complete && advancedTextureCaps.rgba32f.error === 0, true, `EXT_color_buffer_float did not provide RGBA32F rendering: ${JSON.stringify(advancedTextureCaps.rgba32f)}`);
	}
	const advancedTextureReportPath = reportPath("web-advanced-texture-capabilities");
	fs.writeFileSync(advancedTextureReportPath, `${JSON.stringify({schemaVersion: 1, browser, ...advancedTextureCaps}, null, 2)}\n`);
	console.log(`[INFO] Browser 2D rendering fixture passed: ${screenshotPath}`);
	console.log(`[INFO] Browser DPR=2 ImGui fixture passed: ${dpr2ScreenshotPath}`);
	console.log(`[INFO] RenderTarget readback PNG: ${renderTargetReadbackPath}`);
	console.log(`[INFO] Pixel regions: ${JSON.stringify(regions)}`);
	console.log(`[INFO] DPR=2 ImGui regions: ${JSON.stringify(dpr2Regions)}`);
	console.log(`[INFO] WebGL2 advanced texture capabilities: ${JSON.stringify(advancedTextureCaps)}`);
	console.log(`[INFO] WebGL2 advanced texture capability report: ${advancedTextureReportPath}`);
	console.log(`[INFO] Startup performance: cold=${coldStartup.total.toFixed(1)} ms, warm=${warmStartup.total.toFixed(1)} ms, runtime gzip=${artifactSizes.runtimeTotals.gzip} B`);
	console.log(`[INFO] Startup performance report: ${startupPerformancePath}`);
	console.log(`[INFO] RenderTarget readback regions: ${JSON.stringify(renderTargetRegions)}`);
	console.log(`[INFO] Browser warnings observed: ${pageWarnings.length}; lifecycle warnings: ${lifecycleWarnings.length}`);
	console.log(`[INFO] Expected HTTP/touchcancel probe logs: ${expectedHttpProbeErrors.length}/${expectedTouchCancelErrors.length}; unexpected browser errors: ${unexpectedPageErrors.length}`);
	console.log("[INFO] .dora package import and IDBFS reload persistence passed");
	console.log("[INFO] Batched IDBFS write and reload persistence passed");
	console.log("[INFO] Fetch GET/POST/status/timeout/cancel/progress/size/origin and inbound server capability contract passed");
	console.log("[INFO] Dora keyboard/mouse/wheel, multitouch/cancel, Gamepad connect/button/axis/blur/disconnect, audio unlock, visibility, mocked native and real fallback file pickers, and stop cleanup passed");
	console.log("[INFO] Native browser background/foreground visibility and AudioContext suspend/resume passed");
	console.log("[INFO] Capability matrix, Clipboard round trip, and Pointer Lock acquisition passed");
	if (reloadCount > 0) console.log(`[INFO] Browser lifecycle passed ${reloadCount} reloads: ${JSON.stringify({baselineMemory, finalMemory})}`);
	await cdp.close();
} finally {
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
		if (!exited && chrome.exitCode === null) {
			chrome.kill("SIGKILL");
			await new Promise((resolve) => {
				chrome.once("exit", resolve);
				setTimeout(resolve, 2000);
			});
		}
	}
	chrome.stderr.destroy();
	fs.rmSync(profile, {recursive: true, force: true});
}
