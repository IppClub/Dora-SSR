(function(scope) {
	"use strict";

	const LIMITS = Object.freeze({
		manifestBytes: 1024 * 1024,
		files: 4096,
		fileBytes: 64 * 1024 * 1024,
		totalBytes: 256 * 1024 * 1024,
		startupFiles: 64
	});

	function validatePath(value, label) {
		if (typeof value !== "string" || !value || value.startsWith("/") || value.includes("\\") || /[\0-\x1f]/.test(value)) {
			throw new Error(`${label} is not a safe relative path`);
		}
		const parts = value.split("/");
		if (parts.some((part) => !part || part === "." || part === "..")) {
			throw new Error(`${label} is not a safe relative path`);
		}
		return value;
	}

	function validateManifest(input, manifestUrl, options) {
		if (!input || typeof input !== "object" || Array.isArray(input)) throw new Error("manifest must be an object");
		if (input.format !== "dora-web-game" || input.version !== 1) throw new Error("unsupported Dora Web manifest format or version");
		if (input.engineVersion !== "1.9.2") throw new Error(`unsupported engine version: ${input.engineVersion}`);
		if (input.profile !== "web-player-minimal" && input.profile !== "web-player-full") {
			throw new Error(`unsupported Web profile: ${input.profile}`);
		}
		const entry = validatePath(input.entry, "manifest entry");
		if (!Array.isArray(input.files) || input.files.length === 0 || input.files.length > LIMITS.files) {
			throw new Error("manifest file count is invalid");
		}

		const baseUrl = new URL(manifestUrl, scope.location && scope.location.href);
		const allowedOrigins = new Set([baseUrl.origin, ...((options && options.allowedOrigins) || [])]);
		const paths = new Set();
		let totalBytes = 0;
		let startupFiles = 0;
		const files = input.files.map((file, index) => {
			if (!file || typeof file !== "object") throw new Error(`manifest file ${index} is invalid`);
			const filePath = validatePath(file.path, `manifest file ${index} path`);
			if (paths.has(filePath)) throw new Error(`duplicate manifest path: ${filePath}`);
			paths.add(filePath);
			if (!Number.isSafeInteger(file.size) || file.size < 0 || file.size > LIMITS.fileBytes) {
				throw new Error(`manifest file size is invalid: ${filePath}`);
			}
			totalBytes += file.size;
			if (totalBytes > LIMITS.totalBytes) throw new Error("manifest exceeds the total size limit");
			if (typeof file.sha256 !== "string" || !/^[0-9a-f]{64}$/.test(file.sha256)) {
				throw new Error(`manifest SHA-256 is invalid: ${filePath}`);
			}
			const url = new URL(file.url, baseUrl);
			if ((url.protocol !== "http:" && url.protocol !== "https:") || url.username || url.password || !allowedOrigins.has(url.origin)) {
				throw new Error(`manifest URL is not allowed: ${file.url}`);
			}
			const startup = file.startup === true;
			if (startup) startupFiles++;
			return Object.freeze({ path: filePath, url: url.href, size: file.size, sha256: file.sha256, startup });
		});
		if (startupFiles === 0 || startupFiles > LIMITS.startupFiles) throw new Error("manifest startup file count is invalid");
		const entryFile = files.find((file) => file.path === entry);
		if (!entryFile || !entryFile.startup) throw new Error("manifest entry must be a startup file");
		return Object.freeze({
			format: input.format,
			version: input.version,
			engineVersion: input.engineVersion,
			profile: input.profile,
			entry,
			files: Object.freeze(files)
		});
	}

	async function sha256Hex(data) {
		if (!scope.crypto || !scope.crypto.subtle) throw new Error("Web Crypto SHA-256 is unavailable");
		const digest = await scope.crypto.subtle.digest("SHA-256", data);
		return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
	}

	async function fetchBytes(file) {
		const response = await scope.fetch(file.url, { credentials: "same-origin", cache: "force-cache" });
		if (!response.ok) throw new Error(`asset request failed (${response.status}): ${file.path}`);
		const declaredLength = Number(response.headers.get("content-length"));
		if (Number.isFinite(declaredLength) && declaredLength > file.size) throw new Error(`asset is larger than declared: ${file.path}`);
		const data = await response.arrayBuffer();
		if (data.byteLength !== file.size) throw new Error(`asset size mismatch: ${file.path}`);
		if (await sha256Hex(data) !== file.sha256) throw new Error(`asset SHA-256 mismatch: ${file.path}`);
		return new Uint8Array(data);
	}

	async function loadManifest(manifestUrl, options) {
		const requestedUrl = new URL(manifestUrl, scope.location && scope.location.href);
		const allowedOrigins = new Set([
			...(scope.location && scope.location.origin ? [scope.location.origin] : [requestedUrl.origin]),
			...((options && options.allowedOrigins) || [])
		]);
		if (requestedUrl.username || requestedUrl.password || !allowedOrigins.has(requestedUrl.origin)) {
			throw new Error(`manifest origin is not allowed: ${requestedUrl.origin}`);
		}
		const response = await scope.fetch(requestedUrl.href, { credentials: "same-origin", cache: "no-cache" });
		if (!response.ok) throw new Error(`manifest request failed (${response.status})`);
		if (response.url && !allowedOrigins.has(new URL(response.url).origin)) throw new Error("manifest redirected to a disallowed origin");
		const declaredLength = Number(response.headers.get("content-length"));
		if (Number.isFinite(declaredLength) && declaredLength > LIMITS.manifestBytes) throw new Error("manifest is too large");
		const source = await response.text();
		if (source.length > LIMITS.manifestBytes) throw new Error("manifest is too large");
		let input;
		try { input = JSON.parse(source); } catch (error) { throw new Error(`manifest JSON is invalid: ${error.message}`); }
		return validateManifest(input, response.url || requestedUrl.href, { allowedOrigins: [...allowedOrigins] });
	}

	const moduleStates = new WeakMap();

	function normalizeGamePath(value) {
		if (typeof value !== "string") throw new Error("asset path must be a string");
		const relativePath = value.startsWith("/game/") ? value.slice(6) : value;
		if (relativePath.startsWith("/")) throw new Error(`asset is outside /game: ${value}`);
		return validatePath(relativePath, "asset path");
	}

	function writeVerifiedFile(fileSystem, file, data, root = "/game") {
		const target = `${root}/${file.path}`;
		fileSystem.mkdirTree(target.slice(0, target.lastIndexOf("/")));
		const temporary = `${target}.dora-download`;
		try { fileSystem.unlink(temporary); } catch (_) { }
		fileSystem.writeFile(temporary, data);
		fileSystem.rename(temporary, target);
	}

	function removeTree(fileSystem, target) {
		if (!fileSystem.analyzePath(target).exists) return;
		const stat = fileSystem.stat(target);
		if (!fileSystem.isDir(stat.mode)) {
			fileSystem.unlink(target);
			return;
		}
		for (const child of fileSystem.readdir(target)) {
			if (child !== "." && child !== "..") removeTree(fileSystem, `${target}/${child}`);
		}
		fileSystem.rmdir(target);
	}

	function manifestState(module) {
		const state = moduleStates.get(module);
		if (!state) throw new Error("Dora Web manifest is not mounted");
		return state;
	}

	async function fetchPath(module, value) {
		const relativePath = normalizeGamePath(value);
		const state = manifestState(module);
		const target = `/game/${relativePath}`;
		const file = state.files.get(relativePath);
		if (!file) throw new Error(`asset is not declared in the manifest: ${relativePath}`);
		if (state.mounted.has(relativePath) && state.fileSystem.analyzePath(target).exists) return target;
		if (state.inflight.has(relativePath)) return state.inflight.get(relativePath);
		const request = (async () => {
			const data = await fetchBytes(file);
			if (!state.active || moduleStates.get(module) !== state) throw new Error("asset request belongs to a superseded manifest");
			writeVerifiedFile(state.fileSystem, file, data);
			state.mounted.add(relativePath);
			return target;
		})();
		state.inflight.set(relativePath, request);
		try {
			return await request;
		} finally {
			state.inflight.delete(relativePath);
		}
	}

	async function mountStartup(module, manifestUrl) {
		scope.performance?.mark?.("dora-manifest-start");
		const manifest = await loadManifest(manifestUrl, { allowedOrigins: module.doraAllowedOrigins || [] });
		scope.performance?.mark?.("dora-manifest-ready");
		const startupFiles = manifest.files.filter((file) => file.startup);
		const loaded = await Promise.all(startupFiles.map(async (file) => ({ file, data: await fetchBytes(file) })));
		scope.performance?.mark?.("dora-startup-assets-ready");
		const fileSystem = module.FS;
		if (!fileSystem) throw new Error("Emscripten filesystem is unavailable");
		const previous = moduleStates.get(module);
		const generation = (previous?.generation || 0) + 1;
		const staging = `/tmp/dora-game-stage-${generation}`;
		const backup = `/tmp/dora-game-backup-${generation}`;
		fileSystem.mkdirTree("/tmp");
		removeTree(fileSystem, staging);
		removeTree(fileSystem, backup);
		const state = {
			fileSystem,
			generation,
			active: false,
			files: new Map(manifest.files.map((file) => [file.path, file])),
			inflight: new Map(),
			mounted: new Set()
		};
		try {
			fileSystem.mkdirTree(staging);
			for (const item of loaded) {
				writeVerifiedFile(fileSystem, item.file, item.data, staging);
				state.mounted.add(item.file.path);
			}
			const hadGame = fileSystem.analyzePath("/game").exists;
			if (hadGame) fileSystem.rename("/game", backup);
			try {
				fileSystem.rename(staging, "/game");
			} catch (error) {
				if (fileSystem.analyzePath("/game").exists) removeTree(fileSystem, "/game");
				if (hadGame && fileSystem.analyzePath(backup).exists) fileSystem.rename(backup, "/game");
				throw error;
			}
			if (fileSystem.analyzePath(backup).exists) removeTree(fileSystem, backup);
		} catch (error) {
			removeTree(fileSystem, staging);
			throw error;
		}
		if (previous) previous.active = false;
		state.active = true;
		moduleStates.set(module, state);
		module.doraManifest = manifest;
		return manifest;
	}

	async function mountUserStorage(module) {
		scope.performance?.mark?.("dora-storage-start");
		const fileSystem = module.FS;
		if (!fileSystem || !module.IDBFS) throw new Error("IDBFS is unavailable");
		try { fileSystem.mkdir("/user"); } catch (error) {
			if (!fileSystem.analyzePath("/user").exists) throw error;
		}
		fileSystem.mount(module.IDBFS, {}, "/user");
		await new Promise((resolve, reject) => {
			fileSystem.syncfs(true, (error) => error ? reject(error) : resolve());
		});
		for (const directory of ["/user/saves", "/user/settings", "/user/projects"]) fileSystem.mkdirTree(directory);
		scope.performance?.mark?.("dora-storage-ready");
		let syncInFlight = null;
		let queuedSync = null;
		function storageError(error) {
			if (error && (error.name === "QuotaExceededError" || error.code === 22)) return new Error("IDBFS quota exceeded");
			return new Error(`IDBFS sync failed: ${error && error.message ? error.message : error}`);
		}
		function runSync(afterCurrent) {
			if (syncInFlight) {
				if (!afterCurrent) return syncInFlight;
				return syncInFlight.catch(function() { }).then(function() { return runSync(false); });
			}
			syncInFlight = new Promise((resolve, reject) => {
				fileSystem.syncfs(false, (error) => error ? reject(storageError(error)) : resolve());
			}).finally(function() { syncInFlight = null; });
			return syncInFlight;
		}
		module.doraSyncUserStorage = function() {
			const batch = queuedSync;
			queuedSync = null;
			if (batch) clearTimeout(batch.timer);
			const syncing = runSync(Boolean(batch && syncInFlight));
			if (batch) syncing.then(batch.resolve, batch.reject);
			return syncing;
		};
		module.doraQueueUserStorageSync = function(delay = 250) {
			if (!Number.isFinite(delay) || delay < 0 || delay > 5000) return Promise.reject(new Error("IDBFS sync delay is invalid"));
			if (queuedSync) {
				clearTimeout(queuedSync.timer);
				queuedSync.timer = setTimeout(module.doraSyncUserStorage, delay);
				return queuedSync.promise;
			}
			let resolveBatch;
			let rejectBatch;
			const promise = new Promise((resolve, reject) => { resolveBatch = resolve; rejectBatch = reject; });
			queuedSync = {promise, resolve: resolveBatch, reject: rejectBatch, timer: setTimeout(module.doraSyncUserStorage, delay)};
			return promise;
		};
		const testParams = new URLSearchParams(scope.location && scope.location.search || "");
		if (testParams.has("dora-test-storage-write")) {
			fileSystem.writeFile("/user/settings/web-test.txt", testParams.get("dora-test-storage-write"));
			await module.doraSyncUserStorage();
			document.documentElement.dataset.doraStorageTest = "written";
		} else if (testParams.has("dora-test-storage-read")) {
			const expected = testParams.get("dora-test-storage-read");
			const actual = fileSystem.readFile("/user/settings/web-test.txt", { encoding: "utf8" });
			if (actual !== expected) throw new Error("IDBFS persistence check failed");
			document.documentElement.dataset.doraStorageTest = "passed";
		}
	}

	const api = Object.freeze({ LIMITS, validateManifest, loadManifest, fetchBytes, fetchPath, mountStartup, mountUserStorage });
	scope.DoraWebLoader = api;

	if (typeof Module !== "undefined" && typeof document !== "undefined") {
		Module.preRun = Module.preRun || [];
		Module.preRun.push(function() {
			Module.FS = FS;
			Module.IDBFS = IDBFS;
			const manifestUrl = Module.doraManifestUrl || new URLSearchParams(location.search).get("manifest") || "dora-web-manifest.json";
			const dependency = "dora-web-manifest";
			addRunDependency(dependency);
			Promise.all([api.mountUserStorage(Module), api.mountStartup(Module, manifestUrl)]).then(function() {
				scope.performance?.mark?.("dora-content-ready");
				removeRunDependency(dependency);
			}).catch(function(error) {
				if (typeof window.doraSetState === "function") window.doraSetState("faulted", error.message);
				removeRunDependency(dependency);
				abort(error.message);
			});
		});
	}
})(typeof globalThis !== "undefined" ? globalThis : self);
