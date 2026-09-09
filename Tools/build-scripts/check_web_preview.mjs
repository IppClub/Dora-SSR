import assert from "node:assert/strict";
import crypto from "node:crypto";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";

const playerDir = path.resolve(process.argv[2] || "result/dora-web-player");
const root = fs.mkdtempSync(path.join(os.tmpdir(), "dora-web-preview-check-"));
const packageScript = path.resolve("Tools/build-scripts/package_web_preview.mjs");
const rollbackScript = path.resolve("Tools/build-scripts/rollback_web_preview.mjs");

function run(script, args, expectedStatus = 0) {
	const result = spawnSync(process.execPath, [script, ...args], {encoding: "utf8"});
	assert.equal(result.status, expectedStatus, `${path.basename(script)} exited ${result.status}:\n${result.stdout}\n${result.stderr}`);
}

function verifyRelease(deployment, releaseId) {
	const releaseRoot = path.join(deployment, "releases", releaseId);
	const metadata = JSON.parse(fs.readFileSync(path.join(releaseRoot, "dora-web-release.json"), "utf8"));
	assert.equal(metadata.schemaVersion, 1);
	assert.equal(metadata.releaseId, releaseId);
	assert.match(metadata.contentSecurityPolicy, /script-src 'self' 'wasm-unsafe-eval' 'sha256-/);
	assert.match(metadata.contentSecurityPolicy, /style-src 'sha256-/);
	assert.doesNotMatch(metadata.contentSecurityPolicy, /'unsafe-inline'|'unsafe-eval'/);
	for (const file of metadata.files) {
		const bytes = fs.readFileSync(path.join(releaseRoot, ...file.path.split("/")));
		assert.equal(bytes.length, file.size, `release size mismatch: ${file.path}`);
		assert.equal(crypto.createHash("sha256").update(bytes).digest("hex"), file.sha256, `release hash mismatch: ${file.path}`);
	}
}

async function verifyHttpPolicy(deployment) {
	const policy = JSON.parse(fs.readFileSync(path.join(deployment, "dora-web-deployment.json"), "utf8"));
	const server = http.createServer((request, response) => {
		const pathname = decodeURIComponent(new URL(request.url, "http://127.0.0.1").pathname);
		const relative = pathname === "/" ? "index.html" : pathname.replace(/^\/+/, "");
		const file = path.resolve(deployment, relative);
		if (file !== deployment && !file.startsWith(`${deployment}${path.sep}`)) return response.writeHead(403).end();
		if (!fs.statSync(file, {throwIfNoEntry: false})?.isFile()) return response.writeHead(404).end();
		const extension = path.extname(file);
		const cache = pathname === "/" || pathname === "/index.html" || pathname === "/dora-web-entry.js" || pathname === "/dora-web-current.json"
			? "no-cache"
			: pathname.startsWith("/releases/") ? policy.cache["/releases/*"] : "no-cache";
		response.writeHead(200, {"Cache-Control": cache, "Content-Type": policy.mime[extension] || "application/octet-stream"});
		fs.createReadStream(file).pipe(response);
	});
	await new Promise((resolve, reject) => {
		server.once("error", reject);
		server.listen(0, "127.0.0.1", resolve);
	});
	try {
		const port = server.address().port;
		const index = await fetch(`http://127.0.0.1:${port}/index.html`);
		assert.equal(index.headers.get("cache-control"), "no-cache");
		const pointer = await fetch(`http://127.0.0.1:${port}/dora-web-current.json`);
		assert.equal(pointer.headers.get("cache-control"), "no-cache");
		assert.match(pointer.headers.get("content-type"), /^application\/json/);
		const entry = await fetch(`http://127.0.0.1:${port}/dora-web-entry.js`);
		assert.equal(entry.headers.get("cache-control"), "no-cache");
		assert.match(entry.headers.get("content-type"), /^text\/javascript/);
		const wasm = await fetch(`http://127.0.0.1:${port}/releases/preview-1/dora-player-runtime.wasm`);
		assert.equal(wasm.headers.get("cache-control"), "public, max-age=31536000, immutable");
		assert.equal(wasm.headers.get("content-type"), "application/wasm");
	} finally {
		server.close();
		server.closeAllConnections();
	}
}

try {
	const deployment = path.join(root, "deployment");
	run(packageScript, [playerDir, deployment, "preview-1"]);
	verifyRelease(deployment, "preview-1");
	let pointer = JSON.parse(fs.readFileSync(path.join(deployment, "dora-web-current.json"), "utf8"));
	assert.deepEqual(pointer, {schemaVersion: 1, current: "preview-1", previous: null, entry: "releases/preview-1/index.html"});
	run(packageScript, [playerDir, deployment, "preview-2"]);
	verifyRelease(deployment, "preview-2");
	pointer = JSON.parse(fs.readFileSync(path.join(deployment, "dora-web-current.json"), "utf8"));
	assert.deepEqual(pointer, {schemaVersion: 1, current: "preview-2", previous: "preview-1", entry: "releases/preview-2/index.html"});
	run(packageScript, [playerDir, deployment, "preview-2"], 1);
	run(rollbackScript, [deployment]);
	pointer = JSON.parse(fs.readFileSync(path.join(deployment, "dora-web-current.json"), "utf8"));
	assert.deepEqual(pointer, {schemaVersion: 1, current: "preview-1", previous: "preview-2", entry: "releases/preview-1/index.html"});
	assert.match(fs.readFileSync(path.join(deployment, "index.html"), "utf8"), /dora-web-entry\.js/);
	assert.match(fs.readFileSync(path.join(deployment, "dora-web-entry.js"), "utf8"), /dora-web-current\.json/);
	assert.match(fs.readFileSync(path.join(deployment, "README.md"), "utf8"), /dora-web-current\.json/);
	assert.match(fs.readFileSync(path.join(deployment, "README.zh-CN.md"), "utf8"), /dora-web-current\.json/);
	assert.match(fs.readFileSync(path.join(deployment, "README.md"), "utf8"), /does not promise 3D/);
	const policy = JSON.parse(fs.readFileSync(path.join(deployment, "dora-web-deployment.json"), "utf8"));
	assert.equal(policy.cache["/index.html"], "no-cache");
	assert.equal(policy.cache["/dora-web-entry.js"], "no-cache");
	assert.equal(policy.cache["/releases/*"], "public, max-age=31536000, immutable");
	assert.equal(policy.mime[".wasm"], "application/wasm");
	assert.match(policy.security.rootContentSecurityPolicy, /default-src 'none'/);
	assert.doesNotMatch(policy.security.rootContentSecurityPolicy, /unsafe-/);
	await verifyHttpPolicy(deployment);
	console.log("[INFO] Dora Web immutable release, atomic pointer, rollback, hashes, cache, and MIME policy passed");
} finally {
	fs.rmSync(root, {recursive: true, force: true});
}
