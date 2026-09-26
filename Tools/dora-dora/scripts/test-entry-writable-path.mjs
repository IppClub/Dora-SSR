import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";

const repoRoot = path.resolve("../..");
const entryYue = await readFile(path.join(repoRoot, "Assets/Script/Dev/Entry.yue"), "utf8");
const entryLua = await readFile(path.join(repoRoot, "Assets/Script/Dev/Entry.lua"), "utf8");

assert.match(
	entryYue,
	/if writablePath ~= "" and Content\\exist\(writablePath\) and Content\\isdir\(writablePath\)[\s\S]*?Content\.writablePath = writablePath/,
	"the Yue startup source must validate the saved workspace before applying it",
);
assert.match(
	entryYue,
	/unless DB\\exec "update Config set value_str = \? where name = \?", \{Content\.writablePath, "writablePath"\}/,
	"the Yue startup source must synchronously persist the fallback workspace",
);
assert.match(
	entryLua,
	/if writablePath ~= "" and Content:exist\(writablePath\) and Content:isdir\(writablePath\) then[\s\S]*?Content\.writablePath = writablePath/,
	"the generated Lua runtime must validate the saved workspace before applying it",
);
assert.match(
	entryLua,
	/DB:exec\("update Config set value_str = \? where name = \?", \{[\s\S]*?Content\.writablePath,[\s\S]*?"writablePath"[\s\S]*?\}\)/,
	"the generated Lua runtime must synchronously persist the fallback workspace",
);

console.log("Entry writable-path recovery regression tests passed.");
