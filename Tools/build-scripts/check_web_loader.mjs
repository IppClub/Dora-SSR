import assert from "node:assert/strict";
import crypto from "node:crypto";
import path from "node:path";
import { pathToFileURL } from "node:url";

await import(pathToFileURL(path.resolve("Projects/Web/web-loader.js")));
const { validateManifest, mountStartup, mountUserStorage, fetchPath } = globalThis.DoraWebLoader;

const valid = {
	format: "dora-web-game",
	version: 1,
	engineVersion: "1.9.2",
	profile: "dora-preset",
	entry: "init.lua",
	files: [{
		path: "init.lua",
		url: "assets/init.0123456789ab.lua",
		size: 1,
		sha256: "0".repeat(64),
		startup: true
	}]
};

assert.equal(validateManifest(valid, "https://example.test/dora-web-manifest.json").entry, "init.lua");
for (const profile of ["dora-demo", "web-player-minimal"]) {
	const legacy = structuredClone(valid);
	legacy.profile = profile;
	assert.throws(
		() => validateManifest(legacy, "https://example.test/dora-web-manifest.json"),
		new RegExp(`unsupported Web profile: ${profile}`)
	);
}

for (const mutate of [
	(value) => { value.version = 2; },
	(value) => { value.entry = "../init.lua"; value.files[0].path = "../init.lua"; },
	(value) => { value.files[0].url = "https://evil.test/init.lua"; },
	(value) => { value.files[0].sha256 = "not-a-hash"; },
	(value) => { value.files.push({ ...value.files[0] }); },
	(value) => { value.files[0].startup = false; }
]) {
	const candidate = structuredClone(valid);
	mutate(candidate);
	assert.throws(() => validateManifest(candidate, "https://example.test/dora-web-manifest.json"));
}

console.log("[INFO] Dora Web manifest validation tests passed");

const startupData = Buffer.from("startup");
const lazyData = Buffer.from("lazy");
const retryData = Buffer.from("retry");
const staleData = Buffer.from("stale");
const digest = (data) => crypto.createHash("sha256").update(data).digest("hex");
const lazyManifest = {
	format: "dora-web-game",
	version: 1,
	engineVersion: "1.9.2",
	profile: "dora-preset",
	entry: "init.lua",
	files: [
		{ path: "init.lua", url: "assets/init.lua", size: startupData.length, sha256: digest(startupData), startup: true },
		{ path: "lazy.txt", url: "assets/lazy.txt", size: lazyData.length, sha256: digest(lazyData), startup: false },
		{ path: "retry.txt", url: "assets/retry.txt", size: retryData.length, sha256: digest(retryData), startup: false },
		{ path: "stale.txt", url: "assets/stale.txt", size: staleData.length, sha256: digest(staleData), startup: false }
	]
};

const storedFiles = new Map();
const storedDirectories = new Set(["/"]);
let failRenameTargetOnce;
function mkdirTree(directory) {
	let current = "/";
	for (const part of directory.split("/").filter(Boolean)) {
		current = current === "/" ? `/${part}` : `${current}/${part}`;
		storedDirectories.add(current);
	}
}
const fileSystem = {
	mkdirTree,
	analyzePath(file) { return { exists: storedFiles.has(file) || storedDirectories.has(file) }; },
	stat(file) {
		if (storedDirectories.has(file)) return {mode: "directory"};
		if (storedFiles.has(file)) return {mode: "file"};
		throw new Error("path does not exist");
	},
	isDir(mode) { return mode === "directory"; },
	readdir(directory) {
		const prefix = directory === "/" ? "/" : `${directory}/`;
		const children = new Set([".", ".."]);
		for (const candidate of [...storedDirectories, ...storedFiles.keys()]) {
			if (candidate.startsWith(prefix)) {
				const child = candidate.slice(prefix.length).split("/")[0];
				if (child) children.add(child);
			}
		}
		return [...children];
	},
	writeFile(file, data) {
		mkdirTree(path.posix.dirname(file));
		storedFiles.set(file, Buffer.from(data));
	},
	unlink(file) {
		if (!storedFiles.delete(file)) throw new Error("file does not exist");
	},
	rmdir(directory) {
		const prefix = `${directory}/`;
		if ([...storedDirectories, ...storedFiles.keys()].some((candidate) => candidate !== directory && candidate.startsWith(prefix))) {
			throw new Error("directory is not empty");
		}
		if (!storedDirectories.delete(directory)) throw new Error("directory does not exist");
	},
	rename(source, target) {
		if (failRenameTargetOnce === target) {
			failRenameTargetOnce = undefined;
			throw new Error(`injected rename failure: ${target}`);
		}
		if (storedFiles.has(source)) {
			storedFiles.set(target, storedFiles.get(source));
			storedFiles.delete(source);
			return;
		}
		if (!storedDirectories.has(source)) throw new Error("rename source does not exist");
		const directoryMoves = [...storedDirectories].filter((candidate) => candidate === source || candidate.startsWith(`${source}/`));
		const fileMoves = [...storedFiles].filter(([candidate]) => candidate.startsWith(`${source}/`));
		for (const candidate of directoryMoves) storedDirectories.delete(candidate);
		for (const [candidate] of fileMoves) storedFiles.delete(candidate);
		for (const candidate of directoryMoves) storedDirectories.add(`${target}${candidate.slice(source.length)}`);
		for (const [candidate, data] of fileMoves) storedFiles.set(`${target}${candidate.slice(source.length)}`, data);
	}
};
const startupProgress = [];
const module = { FS: fileSystem, doraReportProgress(loaded, total, detail) { startupProgress.push({loaded, total, detail}); } };
const requestCounts = new Map();
const requestOptions = new Map();
let failRetryOnce = true;
let resolveStaleResponse;
let manifestResponse = lazyManifest;
const originalFetch = globalThis.fetch;
globalThis.fetch = async (url, options) => {
	const href = String(url);
	requestCounts.set(href, (requestCounts.get(href) || 0) + 1);
	requestOptions.set(href, options);
	if (href.endsWith("dora-web-manifest.json")) {
		return new Response(JSON.stringify(manifestResponse), { status: 200 });
	}
	if (href.endsWith("assets/init.lua")) return new Response(startupData, { status: 200 });
	if (href.endsWith("assets/lazy.txt")) return new Response(lazyData, { status: 200 });
	if (href.endsWith("assets/retry.txt")) {
		if (failRetryOnce) {
			failRetryOnce = false;
			return new Response("temporary failure", { status: 503 });
		}
		return new Response(retryData, { status: 200 });
	}
	if (href.endsWith("assets/stale.txt")) return new Promise((resolve) => { resolveStaleResponse = resolve; });
	if (href.endsWith("assets/init-v2.lua")) return new Response("updated", { status: 200 });
	return new Response("not found", { status: 404 });
};

try {
	await mountStartup(module, "https://example.test/dora-web-manifest.json");
	assert.equal(storedFiles.get("/game/init.lua").toString(), "startup");
	assert.deepEqual(startupProgress[0], {loaded: 0, total: startupData.length, detail: "Loading game resources…"});
	assert.deepEqual(startupProgress.at(-1), {loaded: startupData.length, total: startupData.length, detail: "Loading game resources…"});
	assert.equal(requestOptions.get("https://example.test/dora-web-manifest.json").cache, "no-cache");
	assert.equal(requestOptions.get("https://example.test/assets/init.lua").cache, "force-cache");
	assert.equal(storedFiles.has("/game/lazy.txt"), false, "non-startup assets must not be prefetched");

	await Promise.all([fetchPath(module, "lazy.txt"), fetchPath(module, "/game/lazy.txt")]);
	assert.equal(storedFiles.get("/game/lazy.txt").toString(), "lazy");
	assert.equal(requestCounts.get("https://example.test/assets/lazy.txt"), 1, "concurrent fetches must be deduplicated");

	await assert.rejects(fetchPath(module, "retry.txt"), /503/);
	await fetchPath(module, "retry.txt");
	assert.equal(storedFiles.get("/game/retry.txt").toString(), "retry");
	assert.equal(requestCounts.get("https://example.test/assets/retry.txt"), 2, "a failed fetch must be retryable");
	await assert.rejects(fetchPath(module, "missing.txt"), /not declared/);
	await assert.rejects(fetchPath(module, "/user/settings.json"), /outside \/game/);

	const staleRequest = fetchPath(module, "stale.txt");
	const updatedData = Buffer.from("updated");
	manifestResponse = {
		...lazyManifest,
		files: [{path: "init.lua", url: "assets/init-v2.lua", size: updatedData.length, sha256: digest(updatedData), startup: true}]
	};
	failRenameTargetOnce = "/game";
	await assert.rejects(mountStartup(module, "https://example.test/dora-web-manifest.json"), /injected rename failure/);
	assert.equal(storedFiles.get("/game/init.lua").toString(), "startup", "a failed manifest swap must restore the previous startup asset");
	assert.equal(storedFiles.get("/game/lazy.txt").toString(), "lazy", "a failed manifest swap must restore previous lazy assets");
	await mountStartup(module, "https://example.test/dora-web-manifest.json");
	assert.equal(storedFiles.get("/game/init.lua").toString(), "updated", "a new hash URL must replace the previous startup asset");
	assert.equal(storedFiles.has("/game/lazy.txt"), false, "remount must remove files controlled by the previous manifest");
	resolveStaleResponse(new Response(staleData, {status: 200}));
	await assert.rejects(staleRequest, /superseded manifest/, "an old manifest request must not write into the new game directory");
	assert.equal(storedFiles.has("/game/stale.txt"), false, "a superseded request must not restore an old asset");
	await assert.rejects(fetchPath(module, "lazy.txt"), /not declared/, "removed manifest assets must not reuse stale MEMFS content");
} finally {
	globalThis.fetch = originalFetch;
}

console.log("[INFO] Dora Web lazy asset fetch, deduplication, and retry tests passed");

const storageSyncs = [];
let storageFailure;
const storageFileSystem = {
	mkdir() { },
	mkdirTree() { },
	mount() { },
	analyzePath() { return {exists: true}; },
	syncfs(populate, callback) {
		storageSyncs.push(populate);
		queueMicrotask(() => {
			const failure = storageFailure;
			storageFailure = undefined;
			callback(failure);
		});
	}
};
const storageModule = {FS: storageFileSystem, IDBFS: {}};
await mountUserStorage(storageModule);
assert.deepEqual(storageSyncs, [true], "IDBFS must populate before storage APIs become available");
const firstBatch = storageModule.doraQueueUserStorageSync(5);
const sameBatch = storageModule.doraQueueUserStorageSync(1);
assert.equal(firstBatch, sameBatch, "debounced writes must share one completion Promise");
await firstBatch;
assert.deepEqual(storageSyncs, [true, false], "a debounced batch must flush once");

const firstFlush = storageModule.doraSyncUserStorage();
const deduplicatedFlush = storageModule.doraSyncUserStorage();
assert.equal(firstFlush, deduplicatedFlush, "concurrent explicit sync calls must be deduplicated");
await firstFlush;
assert.deepEqual(storageSyncs, [true, false, false]);

let releaseSlowSync;
storageFileSystem.syncfs = (populate, callback) => {
	storageSyncs.push(populate);
	if (populate) queueMicrotask(() => callback());
	else if (!releaseSlowSync) releaseSlowSync = callback;
	else queueMicrotask(() => callback());
};
const slowFlush = storageModule.doraSyncUserStorage();
const queuedAfterSlow = storageModule.doraQueueUserStorageSync(0);
await new Promise((resolve) => setTimeout(resolve, 0));
releaseSlowSync();
await Promise.all([slowFlush, queuedAfterSlow]);
assert.deepEqual(storageSyncs, [true, false, false, false, false], "writes queued during sync must trigger a follow-up flush");

storageFileSystem.syncfs = (populate, callback) => {
	storageSyncs.push(populate);
	const failure = storageFailure;
	storageFailure = undefined;
	queueMicrotask(() => callback(failure));
};
storageFailure = Object.assign(new Error("browser quota"), {name: "QuotaExceededError"});
await assert.rejects(storageModule.doraSyncUserStorage(), /IDBFS quota exceeded/);
await storageModule.doraSyncUserStorage();
console.log("[INFO] Dora Web IDBFS batching, deduplication, quota mapping, and retry tests passed");
