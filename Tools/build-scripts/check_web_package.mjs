import assert from "node:assert/strict";
import path from "node:path";
import {pathToFileURL} from "node:url";
import {deflateRawSync, inflateRawSync} from "node:zlib";

await import(pathToFileURL(path.resolve("Projects/Web/web-package.js")));
const {crc32, inspectPackage, installPackage} = globalThis.DoraWebPackage;

function zip(entries) {
	const localParts = [];
	const centralParts = [];
	let localOffset = 0;
	for (const entry of entries) {
		const name = Buffer.from(entry.path);
		const data = Buffer.from(entry.data || "");
		const method = entry.method === 0 ? 0 : 8;
		const flags = entry.encrypted ? 0x801 : 0x800;
		const extra = entry.zip64 ? Buffer.from([1, 0, 0, 0]) : Buffer.alloc(0);
		const compressed = method === 0 ? data : deflateRawSync(data);
		const checksum = entry.badCrc ? (crc32(data) ^ 1) >>> 0 : crc32(data);
		const local = Buffer.alloc(30);
		local.writeUInt32LE(0x04034b50, 0);
		local.writeUInt16LE(20, 4);
		local.writeUInt16LE(flags, 6);
		local.writeUInt16LE(method, 8);
		local.writeUInt32LE(entry.localBadCrc ? (checksum ^ 1) >>> 0 : checksum, 14);
		local.writeUInt32LE(compressed.length, 18);
		local.writeUInt32LE(data.length, 22);
		local.writeUInt16LE(name.length, 26);
		local.writeUInt16LE(extra.length, 28);
		localParts.push(local, name, extra, compressed);

		const central = Buffer.alloc(46);
		central.writeUInt32LE(0x02014b50, 0);
		central.writeUInt16LE(entry.symlink ? 0x0314 : 20, 4);
		central.writeUInt16LE(20, 6);
		central.writeUInt16LE(flags, 8);
		central.writeUInt16LE(method, 10);
		central.writeUInt32LE(checksum, 16);
		central.writeUInt32LE(compressed.length, 20);
		central.writeUInt32LE(data.length, 24);
		central.writeUInt16LE(name.length, 28);
		central.writeUInt16LE(extra.length, 30);
		if (entry.symlink) central.writeUInt32LE((0xa1ff << 16) >>> 0, 38);
		central.writeUInt32LE(localOffset, 42);
		centralParts.push(central, name, extra);
		localOffset += local.length + name.length + extra.length + compressed.length;
	}
	const centralDirectory = Buffer.concat(centralParts);
	const end = Buffer.alloc(22);
	end.writeUInt32LE(0x06054b50, 0);
	end.writeUInt16LE(entries.length, 8);
	end.writeUInt16LE(entries.length, 10);
	end.writeUInt32LE(centralDirectory.length, 12);
	end.writeUInt32LE(localOffset, 16);
	return Buffer.concat([...localParts, centralDirectory, end]);
}

const manifest = (overrides = {}) => JSON.stringify({
	format: "dora-game",
	version: 1,
	title: "Web package fixture",
	engineVersion: "1.9.2",
	entry: "init",
	...overrides
});
const inflateRaw = (data) => inflateRawSync(data);
const validEntries = [
	{path: "dora-package.json", data: manifest(), method: 0},
	{path: "init.lua", data: "print('package fixture')"},
	{path: "Image/logo.txt", data: "asset"}
];

const inspected = await inspectPackage(zip(validEntries), {inflateRaw});
assert.equal(inspected.manifest.title, "Web package fixture");
assert.equal(inspected.root, "");
assert.deepEqual(inspected.files.map((file) => file.path), ["dora-package.json", "init.lua", "Image/logo.txt"]);

const wrapped = await inspectPackage(zip(validEntries.map((entry) => ({...entry, path: `Game/${entry.path}`}))), {inflateRaw});
assert.equal(wrapped.root, "Game");
assert.deepEqual(wrapped.files.map((file) => file.path), ["dora-package.json", "init.lua", "Image/logo.txt"]);

for (const [label, entries, pattern, options = {}] of [
	["parent traversal", [...validEntries, {path: "../outside.txt", data: "bad"}], /unsafe ZIP entry path/],
	["absolute path", [...validEntries, {path: "/outside.txt", data: "bad"}], /unsafe ZIP entry path/],
	["drive path", [...validEntries, {path: "C:outside.txt", data: "bad"}], /unsafe ZIP entry path/],
	["backslash path", [...validEntries, {path: "folder\\outside.txt", data: "bad"}], /unsafe ZIP entry path/],
	["normalized duplicate", [...validEntries, {path: "e\u0301.txt", data: "one"}, {path: "é.txt", data: "two"}], /duplicate normalized ZIP entry/],
	["case duplicate", [...validEntries, {path: "A.txt", data: "one"}, {path: "a.txt", data: "two"}], /duplicate normalized ZIP entry/],
	["symbolic link", [...validEntries, {path: "link", data: "init.lua", symlink: true}], /symbolic links are unsupported/],
	["encrypted entry", validEntries.map((entry, index) => index === 1 ? {...entry, encrypted: true} : entry), /encrypted ZIP entries are unsupported/],
	["ZIP64 extra", validEntries.map((entry, index) => index === 1 ? {...entry, zip64: true} : entry), /ZIP64 entries are unsupported/],
	["private file", [...validEntries, {path: "credentials.json", data: "secret"}], /disallowed Dora package file/],
	["bad CRC", validEntries.map((entry, index) => index === 1 ? {...entry, badCrc: true} : entry), /CRC mismatch/],
	["local CRC mismatch", validEntries.map((entry, index) => index === 1 ? {...entry, localBadCrc: true} : entry), /local sizes or CRC disagree/],
	["newer engine", [{path: "dora-package.json", data: manifest({engineVersion: "99.0.0"})}, validEntries[1]], /newer engine/],
	["missing manifest", [validEntries[1]], /dora-package.json is missing/],
	["file limit", validEntries, /file is too large/, {limits: {fileBytes: 4}}]
]) {
	await assert.rejects(inspectPackage(zip(entries), {inflateRaw, ...options}), pattern, label);
}
await assert.rejects(inspectPackage(zip(validEntries), {inflateRaw, limits: {archiveBytes: 512 * 1024 * 1024}}), /hard limit/);

class MemoryFs {
	constructor() {
		this.directories = new Set(["/", "/user", "/user/projects"]);
		this.files = new Map();
	}
	mkdirTree(target) {
		let current = "";
		for (const part of target.split("/").filter(Boolean)) { current += `/${part}`; this.directories.add(current); }
	}
	analyzePath(target) { return {exists: this.directories.has(target) || this.files.has(target)}; }
	writeFile(target, data) { this.files.set(target, Buffer.from(data)); }
	unlink(target) { if (!this.files.delete(target)) throw new Error(`missing file: ${target}`); }
	rmdir(target) { this.directories.delete(target); }
	readdir(target) {
		const prefix = target === "/" ? "/" : `${target}/`;
		const names = new Set([".", ".."]);
		for (const item of [...this.directories, ...this.files.keys()]) {
			if (item.startsWith(prefix)) {
				const name = item.slice(prefix.length).split("/")[0];
					if (name) names.add(name);
				}
			}
			return [...names];
		}
	stat(target) { return {mode: this.directories.has(target) ? 1 : 0}; }
	isDir(mode) { return mode === 1; }
	rename(source, target) {
		if (!this.directories.has(source) || this.analyzePath(target).exists) throw new Error("invalid rename");
		const directories = [...this.directories].filter((item) => item === source || item.startsWith(`${source}/`));
		const files = [...this.files].filter(([item]) => item.startsWith(`${source}/`));
		for (const item of directories) this.directories.delete(item);
		for (const [item] of files) this.files.delete(item);
		for (const item of directories) this.directories.add(`${target}${item.slice(source.length)}`);
		for (const [item, data] of files) this.files.set(`${target}${item.slice(source.length)}`, data);
	}
}

const fileSystem = new MemoryFs();
let syncCount = 0;
const module = {FS: fileSystem, doraSyncUserStorage: async () => { syncCount++; }};
assert.equal(await installPackage(module, inspected, "fixture-1"), "/user/projects/fixture-1");
assert.equal(fileSystem.files.get("/user/projects/fixture-1/init.lua").toString(), "print('package fixture')");
assert.equal(syncCount, 1);
await assert.rejects(installPackage(module, inspected, "fixture-1"), /already exists/);

const rollbackFs = new MemoryFs();
await assert.rejects(installPackage({FS: rollbackFs, doraSyncUserStorage: async () => { throw new Error("quota"); }}, inspected, "rollback"), /persistence failed/);
assert.equal(rollbackFs.analyzePath("/user/projects/rollback").exists, false, "failed persistence must roll back the installed directory");
assert.equal([...rollbackFs.directories].some((item) => item.includes(".dora-import-")), false, "failed installs must remove staging directories");

console.log("[INFO] Dora .dora ZIP validation and atomic install tests passed");
