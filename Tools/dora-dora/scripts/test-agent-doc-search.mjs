import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";

const repo = path.resolve("../..");
const read = relative => readFile(path.join(repo, relative), "utf8");

const tools = await read("Assets/Script/Lib/Agent/Tools.ts");
const agentConfig = await read("Assets/Script/Lib/Agent/AgentConfig.ts");
const registry = await read("Assets/Script/Lib/Agent/AgentToolRegistry.ts");
const codingAgent = await read("Assets/Script/Lib/Agent/CodingAgent.ts");
const memory = await read("Assets/Script/Lib/Agent/Memory.ts");
const utils = await read("Assets/Script/Lib/Agent/Utils.ts");
const toolsLua = await read("Assets/Script/Lib/Agent/Tools.lua");
const agentConfigLua = await read("Assets/Script/Lib/Agent/AgentConfig.lua");
const registryLua = await read("Assets/Script/Lib/Agent/AgentToolRegistry.lua");
const codingAgentLua = await read("Assets/Script/Lib/Agent/CodingAgent.lua");
const memoryLua = await read("Assets/Script/Lib/Agent/Memory.lua");
const utilsLua = await read("Assets/Script/Lib/Agent/Utils.lua");
const webServer = await read("Assets/Script/Dev/WebServer.yue");
const llmConfigDialog = await read("Tools/dora-dora/src/LLMConfigDialog.tsx");
const legacyToolName = ["search", "dora", "api"].join("_");
const legacyRequestField = ["doc", "Source"].join("");

for (const source of [tools, registry, codingAgent, toolsLua, registryLua, codingAgentLua, webServer]) {
	assert.ok(!source.includes(legacyToolName), "legacy documentation tool name must be removed");
	assert.ok(!source.includes(legacyRequestField), "legacy documentation request field must be removed");
}

assert.match(tools, /DoraDocSearchType = "dora-tutorial" \| "dora-api" \| "love-api" \| "tic80-api"/);
assert.match(tools, /docType === "love-api" \? "love" : "tic80"/);
assert.match(tools, /globs: exts\.map\(ext => `\$\{name\}\.d\.\$\{ext\}`\)/);
assert.match(tools, /`!\*\*\/love\.d\.\$\{ext\}`/);
assert.match(tools, /`!\*\*\/tic80\.d\.\$\{ext\}`/);
assert.match(tools, /`\$\{AGENT_DORA_DOC_PREFIX\}\$\{docType\}\/\$\{relative\}`/);
assert.match(tools, /docType === "love-api"\) return normalized === "love\.d\.ts" \|\| normalized === "love\.d\.tl"/);
assert.match(tools, /docType === "tic80-api"\) return normalized === "tic80\.d\.ts" \|\| normalized === "tic80\.d\.tl"/);
assert.match(tools, /document is outside the requested search type/);
assert.match(tools, /export async function searchDoraDoc/);
for (const source of [tools, toolsLua, agentConfig, agentConfigLua]) {
	assert.doesNotMatch(source, /fetchUrlMaxBytes/);
	assert.doesNotMatch(source, /gitCloneMaxBytes/);
	assert.doesNotMatch(source, /download exceeds .* byte limit/);
	assert.doesNotMatch(source, /cloned repository exceeds .* byte limit/);
}
assert.doesNotMatch(tools, /function getDirectorySizeUpTo/);
assert.match(registry, /name: "search_dora_doc"/);
assert.match(registry, /enum: \["dora-tutorial", "dora-api", "love-api", "tic80-api"\]/);
assert.match(codingAgent, /action\.tool === "search_dora_doc"/);
assert.match(codingAgent, /main\.on\("batch_tools", batch\)/);
assert.doesNotMatch(codingAgent, /main\.on\("search_dora_doc", searchDora\)/);
assert.match(memory, /const HISTORY_MAX_RECORDS = 1000;/);
assert.doesNotMatch(memory, /HISTORY_MAX_BYTES/);
assert.match(memory, /records\.slice\(records\.length - HISTORY_MAX_RECORDS\)/);
assert.match(memoryLua, /local HISTORY_MAX_RECORDS = 1000/);
assert.doesNotMatch(memoryLua, /HISTORY_MAX_BYTES/);
assert.doesNotMatch(utils, /function applyProviderLLMDefaults/);
assert.doesNotMatch(utilsLua, /local function applyProviderLLMDefaults/);
assert.match(utils, /customOptions: normalizeLLMCustomOptions\(config\["custom_options"\]\)/);
assert.match(memory, /\.\.\.getAuxiliaryLLMOptions\(llmConfig\)/);
const deepSeekTemplate = llmConfigDialog.slice(
	llmConfigDialog.indexOf("id: 'deepseek'"),
	llmConfigDialog.indexOf("id: 'moonshot'"),
);
assert.equal((deepSeekTemplate.match(/thinking: \{ type: 'disabled' \}/g) ?? []).length, 1,
	"DeepSeek should disable thinking only for auxiliary memory-compression calls");
assert.match(toolsLua, /function ____exports\.searchDoraDoc\(req\)/);
assert.match(toolsLua, /"!\*\*\/love\.d\." \.\. ext/);
assert.match(toolsLua, /"!\*\*\/tic80\.d\." \.\. ext/);
assert.match(registryLua, /name = "search_dora_doc"/);
assert.match(codingAgentLua, /action\.tool == "search_dora_doc"/);
assert.match(codingAgentLua, /main:on\("batch_tools", batch\)/);
assert.doesNotMatch(codingAgentLua, /main:on\("search_dora_doc", searchDora\)/);

for (const language of ["en", "zh-Hans"]) {
	for (const extension of ["ts", "tl"]) {
		const definition = await read(`Assets/Script/Lib/Dora/${language}/love.d.${extension}`);
		const parameterDocs = definition.match(/@param/g) ?? [];
		const returnDocs = definition.match(/@returns?/g) ?? [];
		assert.ok(parameterDocs.length >= 1400, `${language}/love.d.${extension} must retain broad parameter documentation`);
		assert.ok(returnDocs.length >= 900, `${language}/love.d.${extension} must retain broad return-value documentation`);
		for (const api of ["getWidth", "newShader", "setIdentity", "newThread", "newWorld"]) {
			assert.match(definition, new RegExp(`${api}[:(]`), `${language}/love.d.${extension} must retain ${api}`);
		}
		assert.match(definition, /FreeBSD/);
	}
}

console.log("Agent documentation search tests passed.");
