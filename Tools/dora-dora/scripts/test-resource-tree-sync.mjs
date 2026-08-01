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

const toolsSource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Tools.ts"), "utf8");
assert.match(toolsSource, /failed to refresh Web IDE tree after Lua command/);
assert.match(toolsSource, /failed to refresh Web IDE tree after Git command/);
assert.match(toolsSource, /if \(key === "Content"\)[\s\S]*contentAccessed = true/);
assert.match(toolsSource, /if \(key === "refreshTree"\)[\s\S]*return refreshTree/);
assert.match(toolsSource, /refreshTreeCalled = true/);
assert.match(toolsSource, /contentAccessed && !refreshTreeCalled && !refreshProjectTree/);
assert.doesNotMatch(toolsSource, /result\.success && contentAccessed && !refreshTreeCalled/);
assert.match(toolsSource, /sendWebIDEFileUpdate\(fullPath, entry\.afterExists, entry\.afterContent\)/);
assert.match(toolsSource, /sendWebIDEFileUpdate\(fullPath, false, ""\)/);

const sessionSource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/AgentSession.ts"), "utf8");
assert.match(sessionSource, /sendWebIDEFileUpdate\(path, false, ""\)/);
assert.match(sessionSource, /sendWebIDERefreshTree\(\)/);

const codingAgentSource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/CodingAgent.ts"), "utf8");
assert.match(codingAgentSource, /writeStepLLMDebugFile[\s\S]*sendWebIDEFileUpdate\(path, true, content\)/);

const runtimePolicySource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/AgentRuntimePolicy.ts"), "utf8");
assert.match(runtimePolicySource, /Content\.save\(path, content\)[\s\S]*sendWebIDEFileUpdate\(path, true, content\)/);

const memorySource = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Memory.ts"), "utf8");
assert.equal(
	(memorySource.match(/Content\.save\(/g) ?? []).length,
	(memorySource.match(/sendWebIDEFileUpdate\(/g) ?? []).length,
	"every Agent memory artifact save must have a matching Web IDE update",
);

const toolsLua = await readFile(path.resolve("../../Assets/Script/Lib/Agent/Tools.lua"), "utf8");
assert.match(toolsLua, /failed to refresh Web IDE tree after Lua command/);
assert.match(toolsLua, /failed to refresh Web IDE tree after Git command/);
assert.match(toolsLua, /if key == "Content" then[\s\S]*contentAccessed = true/);
assert.match(toolsLua, /if key == "refreshTree" then[\s\S]*return refreshTree/);
assert.match(toolsLua, /contentAccessed and not refreshTreeCalled and not refreshProjectTree/);
assert.doesNotMatch(toolsLua, /result\.success and contentAccessed and not refreshTreeCalled/);
const sessionLua = await readFile(path.resolve("../../Assets/Script/Lib/Agent/AgentSession.lua"), "utf8");
assert.match(sessionLua, /Tools\.sendWebIDEFileUpdate\(path, false, ""\)/);
assert.match(sessionLua, /Tools\.sendWebIDERefreshTree\(\)/);

console.log("Resource tree synchronization tests passed.");
