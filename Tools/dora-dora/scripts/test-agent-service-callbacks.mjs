import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";

const repoRoot = path.resolve("../..");
const codingAgentSource = await readFile(
	path.join(repoRoot, "Assets/Script/Lib/Agent/DoraAgent.ts"),
	"utf8",
);
const codingAgentLua = await readFile(
	path.join(repoRoot, "Assets/Script/Lib/Agent/DoraAgent.lua"),
	"utf8",
);

assert.match(
	codingAgentSource,
	/spawnSubAgent:\s*shared\.spawnSubAgent !== undefined\s*\? request => shared\.spawnSubAgent!\(request\)\s*:\s*undefined/,
	"spawnSubAgent must use a receiver-aware adapter before entering AgentToolServices",
);
assert.match(
	codingAgentSource,
	/listSubAgents:\s*shared\.listSubAgents !== undefined\s*\? request => shared\.listSubAgents!\(request\)\s*:\s*undefined/,
	"listSubAgents must use a receiver-aware adapter before entering AgentToolServices",
);
assert.match(
	codingAgentLua,
	/spawnSubAgent = shared\.spawnSubAgent ~= nil and \(function\(____, request\) return shared\.spawnSubAgent\(request\) end\) or nil/,
	"generated Lua must discard the services receiver before forwarding spawnSubAgent",
);
assert.match(
	codingAgentLua,
	/listSubAgents = shared\.listSubAgents ~= nil and \(function\(____, request\) return shared\.listSubAgents\(request\) end\) or nil/,
	"generated Lua must discard the services receiver before forwarding listSubAgents",
);

console.log("Agent service callback receiver adapters passed.");
