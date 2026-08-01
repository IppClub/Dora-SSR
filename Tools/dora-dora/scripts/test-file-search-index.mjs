import assert from "node:assert/strict";
import { build } from "esbuild";
import { mkdtemp, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const outputDir = await mkdtemp(path.join(tmpdir(), "dora-file-search-"));
const outputFile = path.join(outputDir, "FileSearchIndexCore.mjs");
const managerOutputFile = path.join(outputDir, "FileSearchIndex.mjs");
const pathUtilsOutputFile = path.join(outputDir, "PathUtils.mjs");
await build({
	entryPoints: [path.resolve("src/FileSearchIndexCore.ts")],
	bundle: true,
	format: "esm",
	platform: "node",
	outfile: outputFile,
});
await build({
	entryPoints: [path.resolve("src/FileSearchIndex.ts")],
	bundle: true,
	format: "esm",
	platform: "browser",
	outfile: managerOutputFile,
});
await build({
	entryPoints: [path.resolve("src/PathUtils.ts")],
	bundle: true,
	format: "esm",
	platform: "node",
	outfile: pathUtilsOutputFile,
});
const { FileSearchIndexCore } = await import(pathToFileURL(outputFile).href);
const {
	isPathWithin,
	joinCanonicalRelativePath,
	relativePathFromRoot,
	toCanonicalRelativePath,
	toUrlPath,
} = await import(pathToFileURL(pathUtilsOutputFile).href);

assert.equal(isPathWithin("C:\\Workspace\\Game\\init.ts", "c:\\workspace", path.win32), true);
assert.equal(isPathWithin("C:\\Workspace2\\init.ts", "C:\\Workspace", path.win32), false);
assert.equal(isPathWithin("D:\\Workspace\\init.ts", "C:\\Workspace", path.win32), false);
assert.equal(isPathWithin("C:\\Workspace", "C:\\Workspace", path.win32), true);
assert.equal(
	relativePathFromRoot("C:\\Workspace", "C:\\Workspace\\Game\\init.ts", path.win32),
	"Game/init.ts",
);
assert.equal(relativePathFromRoot("C:\\Workspace", "C:\\Workspace2\\init.ts", path.win32), null);
assert.equal(toCanonicalRelativePath("Game\\Script\\init.ts", path.win32), "Game/Script/init.ts");
assert.equal(toUrlPath("Game\\Script\\init.ts", path.win32), "Game/Script/init.ts");
assert.equal(
	joinCanonicalRelativePath("C:\\Workspace", "Game/Script/init.ts", path.win32),
	"C:\\Workspace\\Game\\Script\\init.ts",
);
assert.equal(isPathWithin("/workspace/game/init.ts", "/workspace", path.posix), true);
assert.equal(isPathWithin("/workspace-copy/init.ts", "/workspace", path.posix), false);

const entries = Array.from({ length: 41_752 }, (_, index) => {
	const title = index % 1000 === 0 ? `SkyhookController${index}.tsx` : `GeneratedFile${index}.ts`;
	return {
		rootId: 0,
		relativePath: `project-${Math.floor(index / 200)}/${title}`,
	};
});
const index = new FileSearchIndexCore();
index.initialize(entries);
const timings = [];
for (const query of ["sky", "controller", "generatedfile41", "tsx"]) {
	const startedAt = performance.now();
	const results = index.search(query, 100);
	timings.push({ query, durationMs: Number((performance.now() - startedAt).toFixed(2)), results: results.length });
	assert.ok(results.length <= 100);
}
assert.equal(index.search("sky", 100)[0].relativePath.includes("Skyhook"), true);

index.update({
	rootId: 0,
	relativePath: "new-folder/NewUniqueTarget.ts",
}, true);
assert.equal(index.search("newuniquetarget", 100)[0]?.relativePath, "new-folder/NewUniqueTarget.ts");
index.update({
	rootId: 0,
	relativePath: "new-folder",
}, false);
assert.equal(index.search("newuniquetarget", 100).length, 0);

index.update({
	rootId: 0,
	relativePath: "old-folder/nested/MoveUniqueTarget.ts",
}, true);
index.move(
	{ rootId: 0, relativePath: "old-folder" },
	{ rootId: 0, relativePath: "new-folder" },
);
const moved = index.search("moveuniquetarget", 100)[0];
assert.equal(moved?.relativePath, "new-folder/nested/MoveUniqueTarget.ts");
const multiRootIndex = new FileSearchIndexCore();
multiRootIndex.initialize([
	{ rootId: 0, relativePath: "src/init.ts" },
	{ rootId: 1, relativePath: "src/init.ts" },
]);
assert.deepEqual(
	multiRootIndex.search("init", 100).map(entry => entry.rootId),
	[0, 1],
);
assert.equal(index.search("skyhok", 100)[0]?.relativePath.includes("Skyhook"), true);

const filterSource = await readFile(path.resolve("src/FileFilter.tsx"), "utf8");
assert.doesNotMatch(filterSource, /from ['"]match-sorter['"]/);
assert.doesNotMatch(filterSource, /Autocomplete/);
assert.match(filterSource, /setSelectedIndex\(0\)/);
assert.match(filterSource, /aria-selected=\{selected\}/);
assert.match(filterSource, /case "ArrowDown":/);
assert.match(filterSource, /case "Enter":/);
assert.match(filterSource, /touchAction: "pan-y"/);
const appSource = await readFile(path.resolve("src/App.tsx"), "utf8");
assert.doesNotMatch(appSource, /requestIdleCallback\(warmIndex/);
assert.match(appSource, /if \(!openFilter\) return;/);
assert.match(appSource, /Service\.exist\(\{ file: scriptDir \}\)/);
const managerSource = await readFile(path.resolve("src/FileSearchIndex.ts"), "utf8");
assert.match(managerSource, /new Worker\(new URL\("\.\/FileSearchWorker\.ts"/);

class MockWorker {
	onmessage = null;
	onerror = null;
	options = [];

	postMessage(message) {
		if (message.type === "initialize") {
			this.options = message.entries;
			setTimeout(() => {
				this.onmessage?.({
					data: { type: "ready", generation: message.generation },
				});
			}, 20);
			return;
		}
		if (message.type === "query") {
			const matches = this.options
				.filter(option => option.relativePath.toLowerCase().includes(message.query.toLowerCase()))
				.slice(0, message.limit);
			setTimeout(() => {
				this.onmessage?.({
					data: {
						type: "result",
						generation: message.generation,
						requestId: message.requestId,
						entries: matches,
					},
				});
			}, 0);
			return;
		}
		if (message.type === "update") {
			const prefix = `${message.entry.relativePath}/`;
			if (message.exists) {
				if (!this.options.some(option =>
					option.rootId === message.entry.rootId
					&& option.relativePath === message.entry.relativePath
				)) {
					this.options.push(message.entry);
				}
			} else {
				this.options = this.options.filter(option =>
					option.rootId !== message.entry.rootId
					|| (
						option.relativePath !== message.entry.relativePath
						&& !option.relativePath.startsWith(prefix)
					)
				);
			}
			return;
		}
		if (message.type === "move") {
			const prefix = `${message.oldEntry.relativePath}/`;
			this.options = this.options.map(option => {
				if (
					option.rootId !== message.oldEntry.rootId
					|| (
						option.relativePath !== message.oldEntry.relativePath
						&& !option.relativePath.startsWith(prefix)
					)
				) {
					return option;
				}
				return {
					rootId: message.newEntry.rootId,
					relativePath: `${message.newEntry.relativePath}${option.relativePath.slice(message.oldEntry.relativePath.length)}`,
				};
			});
		}
	}

	terminate() {}
}
globalThis.Worker = MockWorker;
const manager = await import(pathToFileURL(managerOutputFile).href);
void manager.initializeFileSearchIndex({
	key: "empty",
	roots: [{
		id: 0,
		kind: "workspace",
		absolutePath: "/workspace",
		label: "Workspace",
	}],
	entries: [],
});
const coldQuery = manager.searchFileIndex("coldtarget", 100);
void manager.initializeFileSearchIndex({
	key: "populated",
	roots: [{
		id: 0,
		kind: "workspace",
		absolutePath: "/workspace",
		label: "Workspace",
	}, {
		id: 1,
		kind: "builtin",
		absolutePath: "/builtin",
		label: "Built-in",
	}],
	entries: [{
		rootId: 0,
		relativePath: "ColdTarget.ts",
	}, {
		rootId: 1,
		relativePath: "ColdTarget.ts",
	}],
});
const coldResults = await Promise.race([
	coldQuery,
	new Promise((_, reject) => setTimeout(() => reject(new Error("reinitialized search stayed pending")), 500)),
]);
assert.equal(coldResults[0]?.title, "ColdTarget.ts");
assert.equal(coldResults[0]?.fileKey, "/workspace/ColdTarget.ts");
assert.equal(coldResults[0]?.path, "Workspace/ColdTarget.ts");
assert.equal(coldResults[1]?.fileKey, "/builtin/ColdTarget.ts");
assert.equal(coldResults[1]?.rootKind, "builtin");

manager.updateFileSearchIndex("/workspace/new-folder/NewTarget.ts", true);
assert.equal((await manager.searchFileIndex("newtarget", 100))[0]?.fileKey, "/workspace/new-folder/NewTarget.ts");
manager.moveFileSearchIndex("/workspace/new-folder", "/workspace/moved-folder");
assert.equal((await manager.searchFileIndex("newtarget", 100))[0]?.fileKey, "/workspace/moved-folder/NewTarget.ts");
manager.updateFileSearchIndex("/workspace/moved-folder", false);
assert.equal((await manager.searchFileIndex("newtarget", 100)).length, 0);

console.log("File search worker core tests passed.", {
	files: entries.length,
	timings,
});
