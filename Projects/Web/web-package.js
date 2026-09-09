(function(scope) {
	"use strict";

	const LIMITS = Object.freeze({
		archiveBytes: 256 * 1024 * 1024,
		files: 10000,
		fileBytes: 64 * 1024 * 1024,
		totalBytes: 512 * 1024 * 1024,
		manifestBytes: 64 * 1024
	});
	const runtimeEntries = Object.freeze(["init.lua", "init.yue", "init.tl", "init.xml", "init.wasm"]);
	const decoder = new TextDecoder("utf-8", {fatal: true});

	function toBytes(input) {
		if (input instanceof Uint8Array) return Promise.resolve(input);
		if (input instanceof ArrayBuffer) return Promise.resolve(new Uint8Array(input));
		if (typeof Blob !== "undefined" && input instanceof Blob) return input.arrayBuffer().then((data) => new Uint8Array(data));
		throw new Error("Dora package must be a Blob, ArrayBuffer, or Uint8Array");
	}

	function viewOf(bytes) {
		return new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
	}

	function safeAdd(left, right, limit, label) {
		if (!Number.isSafeInteger(left) || !Number.isSafeInteger(right) || left < 0 || right < 0 || left > limit - right) {
			throw new Error(`${label} exceeds its limit`);
		}
		return left + right;
	}

	function decodeName(bytes) {
		let name;
		try { name = decoder.decode(bytes); } catch (_) { throw new Error("ZIP entry name is not valid UTF-8"); }
		if (name.normalize("NFC") !== name) name = name.normalize("NFC");
		return name;
	}

	function validateEntryPath(value, directory) {
		if (!value || value.includes("\\") || value.includes(":" ) || /[\0-\x1f]/.test(value) || value.startsWith("/")) {
			throw new Error(`unsafe ZIP entry path: ${value || "<empty>"}`);
		}
		const path = directory && value.endsWith("/") ? value.slice(0, -1) : value;
		const parts = path.split("/");
		if (!path || parts.some((part) => !part || part === "." || part === "..")) throw new Error(`unsafe ZIP entry path: ${value}`);
		return path;
	}

	function packageFileAllowed(path) {
		if (path === "dora-package.json" || [".dora/repo.json", ".dora/banner.jpg", ".dora/banner.png"].some((allowed) => path === allowed || path.endsWith(`/${allowed}`))) return true;
		const parts = path.split("/");
		const lowerName = parts[parts.length - 1].toLowerCase();
		return !parts.some((part) => part.startsWith(".") || part === "node_modules" || part === "__MACOSX")
			&& lowerName !== "credentials.json" && lowerName !== "config.db" && !lowerName.endsWith(".log");
	}

	let crcTable;
	function crc32(bytes) {
		if (!crcTable) {
			crcTable = new Uint32Array(256);
			for (let index = 0; index < 256; index++) {
				let value = index;
				for (let bit = 0; bit < 8; bit++) value = (value & 1) ? (0xedb88320 ^ (value >>> 1)) : (value >>> 1);
				crcTable[index] = value >>> 0;
			}
		}
		let value = 0xffffffff;
		for (const byte of bytes) value = crcTable[(value ^ byte) & 0xff] ^ (value >>> 8);
		return (value ^ 0xffffffff) >>> 0;
	}

	function findEndRecord(bytes, view) {
		const first = Math.max(0, bytes.length - 22 - 0xffff);
		for (let offset = bytes.length - 22; offset >= first; offset--) {
			if (view.getUint32(offset, true) !== 0x06054b50) continue;
			const commentBytes = view.getUint16(offset + 20, true);
			if (offset + 22 + commentBytes === bytes.length) return offset;
		}
		throw new Error("ZIP end record is missing or malformed");
	}

	function hasExtraField(bytes, offset, length, fieldId) {
		const view = viewOf(bytes);
		const end = offset + length;
		while (offset < end) {
			if (offset + 4 > end) throw new Error("ZIP extra field is malformed");
			const id = view.getUint16(offset, true);
			const size = view.getUint16(offset + 2, true);
			offset += 4;
			if (offset + size > end) throw new Error("ZIP extra field exceeds its bounds");
			if (id === fieldId) return true;
			offset += size;
		}
		return false;
	}

	function parseCentralDirectory(bytes, limits) {
		if (bytes.length === 0 || bytes.length > limits.archiveBytes) throw new Error("Dora package archive size is invalid");
		const view = viewOf(bytes);
		const end = findEndRecord(bytes, view);
		const disk = view.getUint16(end + 4, true);
		const directoryDisk = view.getUint16(end + 6, true);
		const diskEntries = view.getUint16(end + 8, true);
		const totalEntries = view.getUint16(end + 10, true);
		const directoryBytes = view.getUint32(end + 12, true);
		const directoryOffset = view.getUint32(end + 16, true);
		if (disk !== 0 || directoryDisk !== 0 || diskEntries !== totalEntries) throw new Error("multi-disk ZIP packages are unsupported");
		if (totalEntries === 0xffff || directoryBytes === 0xffffffff || directoryOffset === 0xffffffff) throw new Error("ZIP64 packages are unsupported");
		if (totalEntries === 0 || totalEntries > limits.files) throw new Error("Dora package file count is invalid");
		if (safeAdd(directoryOffset, directoryBytes, end, "ZIP central directory") !== end) throw new Error("ZIP central directory bounds are invalid");

		const entries = [];
		const names = new Set();
		let totalBytes = 0;
		let offset = directoryOffset;
		for (let index = 0; index < totalEntries; index++) {
			if (offset + 46 > end || view.getUint32(offset, true) !== 0x02014b50) throw new Error("ZIP central directory entry is malformed");
			const madeBy = view.getUint16(offset + 4, true);
			const flags = view.getUint16(offset + 8, true);
			const method = view.getUint16(offset + 10, true);
			const checksum = view.getUint32(offset + 16, true);
			const compressedBytes = view.getUint32(offset + 20, true);
			const unpackedBytes = view.getUint32(offset + 24, true);
			const nameBytes = view.getUint16(offset + 28, true);
			const extraBytes = view.getUint16(offset + 30, true);
			const commentBytes = view.getUint16(offset + 32, true);
			const externalAttributes = view.getUint32(offset + 38, true);
			const localOffset = view.getUint32(offset + 42, true);
			const next = safeAdd(offset, 46 + nameBytes + extraBytes + commentBytes, end, "ZIP directory entry");
			if (next > end) throw new Error("ZIP central directory entry exceeds its bounds");
			if (flags & (1 | 0x40 | 0x2000)) throw new Error("encrypted ZIP entries are unsupported");
			if (method !== 0 && method !== 8) throw new Error(`unsupported ZIP compression method: ${method}`);
			if ([compressedBytes, unpackedBytes, localOffset].includes(0xffffffff)) throw new Error("ZIP64 entries are unsupported");
			const rawName = bytes.subarray(offset + 46, offset + 46 + nameBytes);
			if (hasExtraField(bytes, offset + 46 + nameBytes, extraBytes, 0x0001)) throw new Error("ZIP64 entries are unsupported");
			const decodedName = decodeName(rawName);
			const directory = decodedName.endsWith("/");
			const path = validateEntryPath(decodedName, directory);
			const key = path.toLocaleLowerCase("en-US");
			if (names.has(key)) throw new Error(`duplicate normalized ZIP entry: ${path}`);
			names.add(key);
			const unixMode = madeBy >>> 8 === 3 ? externalAttributes >>> 16 : 0;
			if ((unixMode & 0xf000) === 0xa000) throw new Error(`symbolic links are unsupported: ${path}`);
			if (!directory) {
				if (!packageFileAllowed(path)) throw new Error(`disallowed Dora package file: ${path}`);
				if (unpackedBytes > limits.fileBytes) throw new Error(`Dora package file is too large: ${path}`);
				totalBytes = safeAdd(totalBytes, unpackedBytes, limits.totalBytes, "Dora package unpacked size");
			}
			entries.push({path, directory, flags, method, checksum, compressedBytes, unpackedBytes, localOffset, rawName});
			offset = next;
		}
		if (offset !== end) throw new Error("ZIP central directory size does not match its entries");
		return {entries, directoryOffset, totalBytes};
	}

	function compressedSlices(bytes, parsed) {
		const view = viewOf(bytes);
		const ranges = [];
		for (const entry of parsed.entries) {
			if (entry.localOffset + 30 > parsed.directoryOffset || view.getUint32(entry.localOffset, true) !== 0x04034b50) {
				throw new Error(`ZIP local header is malformed: ${entry.path}`);
			}
			const flags = view.getUint16(entry.localOffset + 6, true);
			const method = view.getUint16(entry.localOffset + 8, true);
			const checksum = view.getUint32(entry.localOffset + 14, true);
			const compressedBytes = view.getUint32(entry.localOffset + 18, true);
			const unpackedBytes = view.getUint32(entry.localOffset + 22, true);
			const nameBytes = view.getUint16(entry.localOffset + 26, true);
			const extraBytes = view.getUint16(entry.localOffset + 28, true);
			if (flags !== entry.flags || method !== entry.method || nameBytes !== entry.rawName.length) throw new Error(`ZIP headers disagree: ${entry.path}`);
			if (!(flags & 8) && (checksum !== entry.checksum || compressedBytes !== entry.compressedBytes || unpackedBytes !== entry.unpackedBytes)) {
				throw new Error(`ZIP local sizes or CRC disagree: ${entry.path}`);
			}
			const nameStart = entry.localOffset + 30;
			const dataStart = safeAdd(nameStart, nameBytes + extraBytes, parsed.directoryOffset, "ZIP local header");
			if (hasExtraField(bytes, nameStart + nameBytes, extraBytes, 0x0001)) throw new Error("ZIP64 entries are unsupported");
			const dataEnd = safeAdd(dataStart, entry.compressedBytes, parsed.directoryOffset, "ZIP entry data");
			const localName = bytes.subarray(nameStart, nameStart + nameBytes);
			if (localName.length !== entry.rawName.length || localName.some((byte, index) => byte !== entry.rawName[index])) throw new Error(`ZIP local name disagrees: ${entry.path}`);
			ranges.push({start: entry.localOffset, end: dataEnd, entry});
			entry.compressed = bytes.subarray(dataStart, dataEnd);
		}
		ranges.sort((left, right) => left.start - right.start);
		for (let index = 1; index < ranges.length; index++) {
			if (ranges[index].start < ranges[index - 1].end) throw new Error("ZIP entries have overlapping data ranges");
		}
	}

	async function inflateRaw(compressed, expectedBytes, customInflate) {
		if (customInflate) return new Uint8Array(await customInflate(compressed, expectedBytes));
		if (typeof DecompressionStream === "undefined") throw new Error("raw DEFLATE is unavailable in this browser");
		const reader = new Blob([compressed]).stream().pipeThrough(new DecompressionStream("deflate-raw")).getReader();
		const chunks = [];
		let size = 0;
		while (true) {
			const {done, value} = await reader.read();
			if (done) break;
			size += value.byteLength;
			if (size > expectedBytes) {
				await reader.cancel();
				throw new Error("ZIP entry expands beyond its declared size");
			}
			chunks.push(value);
		}
		const result = new Uint8Array(size);
		let offset = 0;
		for (const chunk of chunks) { result.set(chunk, offset); offset += chunk.byteLength; }
		return result;
	}

	function compareVersion(left, right) {
		const parse = (value) => {
			if (typeof value !== "string" || !/^\d+(?:\.\d+){0,3}$/.test(value)) throw new Error(`invalid Dora engine version: ${value}`);
			return value.split(".").map(Number);
		};
		const a = parse(left);
		const b = parse(right);
		for (let index = 0; index < Math.max(a.length, b.length); index++) {
			if ((a[index] || 0) !== (b[index] || 0)) return (a[index] || 0) - (b[index] || 0);
		}
		return 0;
	}

	async function inspectPackage(input, options = {}) {
		const requestedLimits = options.limits || {};
		const limits = Object.freeze(Object.fromEntries(Object.entries(LIMITS).map(([name, hardLimit]) => {
			const requested = requestedLimits[name];
			if (requested === undefined) return [name, hardLimit];
			if (!Number.isSafeInteger(requested) || requested < 1 || requested > hardLimit) throw new Error(`${name} cannot exceed the Web package hard limit`);
			return [name, requested];
		})));
		const bytes = await toBytes(input);
		const parsed = parseCentralDirectory(bytes, limits);
		compressedSlices(bytes, parsed);
		const files = [];
		for (const entry of parsed.entries) {
			if (entry.directory) continue;
			const data = entry.method === 0 ? new Uint8Array(entry.compressed) : await inflateRaw(entry.compressed, entry.unpackedBytes, options.inflateRaw);
			if (data.byteLength !== entry.unpackedBytes) throw new Error(`ZIP entry size mismatch: ${entry.path}`);
			if (crc32(data) !== entry.checksum) throw new Error(`ZIP entry CRC mismatch: ${entry.path}`);
			files.push({path: entry.path, data});
		}
		const filePaths = new Set(files.map((file) => file.path));
		let root = "";
		if (!runtimeEntries.some((entry) => filePaths.has(entry))) {
			const roots = new Set(files.map((file) => file.path.split("/")[0]));
			if (roots.size !== 1) throw new Error("Dora package has no runnable init entry");
			root = [...roots][0];
			if (!runtimeEntries.some((entry) => filePaths.has(`${root}/${entry}`))) throw new Error("Dora package has no runnable init entry");
		}
		const relativeFiles = files.map((file) => ({path: root ? file.path.slice(root.length + 1) : file.path, data: file.data}));
		const manifestFile = relativeFiles.find((file) => file.path === "dora-package.json");
		if (!manifestFile || manifestFile.data.byteLength > limits.manifestBytes) throw new Error("dora-package.json is missing or too large");
		let manifest;
		try { manifest = JSON.parse(decoder.decode(manifestFile.data)); } catch (error) { throw new Error(`dora-package.json is invalid: ${error.message}`); }
		if (!manifest || typeof manifest !== "object" || Array.isArray(manifest) || manifest.format !== "dora-game" || manifest.version !== 1 || manifest.entry !== "init") {
			throw new Error("unsupported dora-package.json format, version, or entry");
		}
		if (typeof manifest.title !== "string" || !manifest.title.trim() || manifest.title.length > 120) throw new Error("Dora package title is invalid");
		const currentEngineVersion = options.currentEngineVersion || "1.9.2";
		if (compareVersion(manifest.engineVersion, currentEngineVersion) > 0) throw new Error("Dora package requires a newer engine");
		return Object.freeze({manifest: Object.freeze({...manifest}), root, archiveBytes: bytes.byteLength, unpackedBytes: parsed.totalBytes, files: Object.freeze(relativeFiles)});
	}

	function validateProjectId(value) {
		if (typeof value !== "string" || !/^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$/.test(value) || value === "." || value === "..") throw new Error("project id is invalid");
		return value;
	}

	function removeTree(fileSystem, target) {
		if (!fileSystem.analyzePath(target).exists) return;
		for (const name of fileSystem.readdir(target)) {
			if (name === "." || name === "..") continue;
			const child = `${target}/${name}`;
			const stat = fileSystem.stat(child);
			if (fileSystem.isDir(stat.mode)) removeTree(fileSystem, child); else fileSystem.unlink(child);
		}
		fileSystem.rmdir(target);
	}

	async function installPackage(module, inspected, projectId) {
		const fileSystem = module && module.FS;
		if (!fileSystem || !inspected || !Array.isArray(inspected.files)) throw new Error("Dora package install state is invalid");
		if (typeof module.doraSyncUserStorage !== "function") throw new Error("IDBFS sync is unavailable");
		const id = validateProjectId(projectId);
		const root = "/user/projects";
		const target = `${root}/${id}`;
		if (fileSystem.analyzePath(target).exists) throw new Error(`project already exists: ${id}`);
		const random = scope.crypto && typeof scope.crypto.randomUUID === "function" ? scope.crypto.randomUUID() : `${Date.now()}-${Math.random().toString(16).slice(2)}`;
		const stage = `${root}/.dora-import-${random}`;
		fileSystem.mkdirTree(stage);
		try {
			for (const file of inspected.files) {
				const path = validateEntryPath(file.path, false);
				const output = `${stage}/${path}`;
				fileSystem.mkdirTree(output.slice(0, output.lastIndexOf("/")));
				fileSystem.writeFile(output, file.data);
			}
			fileSystem.rename(stage, target);
			try { await module.doraSyncUserStorage(); } catch (error) {
				removeTree(fileSystem, target);
				try { await module.doraSyncUserStorage(); } catch (_) { }
				throw new Error(`Dora package persistence failed: ${error.message || error}`);
			}
			return target;
		} catch (error) {
			removeTree(fileSystem, stage);
			throw error;
		}
	}

	const api = Object.freeze({LIMITS, runtimeEntries, crc32, inspectPackage, installPackage});
	scope.DoraWebPackage = api;
})(typeof globalThis !== "undefined" ? globalThis : self);
