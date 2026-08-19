import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "../../..");
const read = relativePath => readFile(path.join(root, relativePath), "utf8");

const [workspaceTools, registry, workspaceToolsLua, registryLua, engineSkill, loveSkill] = await Promise.all([
	read("Assets/Script/Lib/Agent/Tool/Workspace.ts"),
	read("Assets/Script/Lib/Agent/Tool/Registry.ts"),
	read("Assets/Script/Lib/Agent/Tool/Workspace.lua"),
	read("Assets/Script/Lib/Agent/Tool/Registry.lua"),
	read("Assets/Doc/skills/dora-engine-coding/SKILL.md"),
	read("Assets/Doc/skills/love-game-development/SKILL.md"),
]);

assert.match(workspaceTools, /const ENGINE_LOG_FILE = "dora_full_logs\.txt";/);
assert.match(workspaceTools, /const ENGINE_LOG_VIRTUAL_FILE = "@dora_full_logs\.txt";/);
assert.match(workspaceTools, /return path === ENGINE_LOG_VIRTUAL_FILE;/);
assert.match(registry, /current Dora engine log snapshot/);
assert.match(registry, /read-only virtual path, not a workspace file/);

assert.match(workspaceToolsLua, /ENGINE_LOG_FILE = "dora_full_logs\.txt"/);
assert.match(workspaceToolsLua, /ENGINE_LOG_VIRTUAL_FILE = "@dora_full_logs\.txt"/);
assert.match(workspaceToolsLua, /return path == ENGINE_LOG_VIRTUAL_FILE/);
assert.match(registryLua, /current Dora engine log snapshot/);

assert.match(engineSkill, /read-only virtual file `@dora_full_logs\.txt`/);
assert.match(loveSkill, /docType: "love-api"/);
assert.match(loveSkill, /@dora-doc\/love-api\/\.\.\./);
assert.match(loveSkill, /read_file path="@dora_full_logs\.txt" startLine=-200/);
assert.match(loveSkill, /\[Love:<identity>\]/);
assert.match(loveSkill, /Do not execute the Love `main\.lua` directly as a Dora entry/);

console.log("agent virtual log and Love skill checks passed");
