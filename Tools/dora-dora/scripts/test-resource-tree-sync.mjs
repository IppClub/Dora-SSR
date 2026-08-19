import assert from "node:assert/strict";
import { build } from "esbuild";
import { mkdtemp, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const outputDir = await mkdtemp(path.join(tmpdir(), "dora-resource-tree-sync-"));
const outputFile = path.join(outputDir, "ResourceTreeSync.mjs");
await build({
	entryPoints: [path.resolve("src/ResourceTreeSync.ts")],
	bundle: true,
	format: "esm",
	platform: "node",
	outfile: outputFile,
});

const {
	getResourceTreeReconcileDirectory,
	getResourceTreeReconcileDirectories,
} = await import(pathToFileURL(outputFile).href);

const tree = {
	key: "/workspace",
	title: "workspace",
	dir: true,
	children: [{
		key: "/workspace/game",
		title: "game",
		dir: true,
		children: [{
			key: "/workspace/game/Script",
			title: "Script",
			dir: true,
			children: [],
		}],
	}],
};

assert.equal(
	getResourceTreeReconcileDirectory(tree, "/workspace/game/Script/init.ts", path.posix),
	"/workspace/game/Script",
);
assert.equal(
	getResourceTreeReconcileDirectory(tree, "/workspace/game/.build/generated.lua", path.posix),
	"/workspace/game",
	"a filtered parent must reconcile through the closest visible directory",
);
assert.equal(
	getResourceTreeReconcileDirectory(tree, "/workspace/new/nested/file.txt", path.posix),
	"/workspace",
	"a new hierarchy must reconcile through the closest existing ancestor",
);
assert.deepEqual(
	getResourceTreeReconcileDirectories(tree, [
		"/workspace/game/Script/a.ts",
		"/workspace/game/Script/b.ts",
		"/workspace/game/.build/generated.lua",
	], path.posix),
	["/workspace/game"],
	"ancestor refreshes should subsume descendant refreshes",
);
assert.equal(
	getResourceTreeReconcileDirectory({
		key: "C:\\workspace",
		title: "workspace",
		dir: true,
		children: [],
	}, "D:\\outside\\file.ts", path.win32),
	"C:\\workspace",
	"an absolute relative result from another Windows drive must not be treated as a descendant",
);

const appSource = await readFile(path.resolve("src/App.tsx"), "utf8");
assert.match(appSource, /const monacoRuntime = peekMonacoRuntime\(\)/);
assert.match(appSource, /cancelPendingUpdateFileBatch\(\);[\s\S]*scheduleGitAssetsRefresh\(\)/);
assert.match(appSource, /getResourceTreeReconcileDirectories\(/);
assert.match(appSource, /updateFileReconcileGenerationRef\.current !== reconcileGeneration/);
assert.match(appSource, /Incremental search updates cannot model[\s\S]*invalidateFileSearchIndex\(\)/);
assert.match(appSource, /Resolve canonical refresh targets before optimistic insertion[\s\S]*const reconcileDirectories[\s\S]*for \(let i = 0; i < events\.length/);

const commandSource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Tool/Command.ts"), "utf8");
assert.match(commandSource, /failed to refresh Web IDE tree after Lua command/);
assert.match(commandSource, /if \(key === "Content"\)[\s\S]*contentAccessed = true/);
assert.match(commandSource, /if \(key === "refreshTree"\)[\s\S]*return refreshTree/);
assert.match(commandSource, /refreshTreeCalled = true/);
assert.match(commandSource, /contentAccessed && !refreshTreeCalled && !refreshWorkspaceTree/);
assert.doesNotMatch(commandSource, /result\.success && contentAccessed && !refreshTreeCalled/);

const gitCommandSource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Tool/GitCommand.ts"), "utf8");
assert.match(gitCommandSource, /failed to refresh Web IDE tree after Git command/);

const checkpointSource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Tool/Checkpoint.ts"), "utf8");
assert.match(checkpointSource, /sendWebIDEFileUpdate\(fullPath, entry\.afterExists, entry\.afterContent\)/);
assert.match(checkpointSource, /sendWebIDEFileUpdate\(fullPath, false, ""\)/);

const sessionSource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Session.ts"), "utf8");
assert.match(sessionSource, /sendWebIDEFileUpdate\(path, false, ""\)/);
assert.match(sessionSource, /sendWebIDERefreshTree\(\)/);

const stepDebugSource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Runtime/StepDebugLog.ts"), "utf8");
assert.match(stepDebugSource, /writeStepLLMDebugFile[\s\S]*sendWebIDEFileUpdate\(path, true, content\)/);

const runtimePolicySource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Runtime/Policy.ts"), "utf8");
assert.match(runtimePolicySource, /Content\.save\(path, content\)[\s\S]*sendWebIDEFileUpdate\(path, true, content\)/);

const memorySource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Memory.ts"), "utf8");
assert.equal(
	(memorySource.match(/Content\.save\(/g) ?? []).length,
	(memorySource.match(/sendWebIDEFileUpdate\(/g) ?? []).length,
	"every Agent memory artifact save must have a matching Web IDE update",
);

const commandLua = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Tool/Command.lua"), "utf8");
assert.match(commandLua, /failed to refresh Web IDE tree after Lua command/);
assert.match(commandLua, /if key == "Content" then[\s\S]*contentAccessed = true/);
assert.match(commandLua, /if key == "refreshTree" then[\s\S]*return refreshTree/);
assert.match(commandLua, /contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree/);
assert.doesNotMatch(commandLua, /result\.success and contentAccessed and not refreshTreeCalled/);

const gitCommandLua = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Tool/GitCommand.lua"), "utf8");
assert.match(gitCommandLua, /failed to refresh Web IDE tree after Git command/);
const sessionLua = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Session.lua"), "utf8");
assert.match(sessionLua, /Tools\.sendWebIDEFileUpdate\(path, false, ""\)/);
assert.match(sessionLua, /Tools\.sendWebIDERefreshTree\(\)/);

console.log("Resource tree synchronization tests passed.");
