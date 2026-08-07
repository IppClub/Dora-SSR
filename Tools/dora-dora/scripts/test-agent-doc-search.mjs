import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";

const repo = path.resolve("../..");
const read = relative => readFile(path.join(repo, relative), "utf8");

const tools = await read("Assets/Script/Lib/Agent/Tools.ts");
const registry = await read("Assets/Script/Lib/Agent/AgentToolRegistry.ts");
const codingAgent = await read("Assets/Script/Lib/Agent/CodingAgent.ts");
const toolsLua = await read("Assets/Script/Lib/Agent/Tools.lua");
const registryLua = await read("Assets/Script/Lib/Agent/AgentToolRegistry.lua");
const codingAgentLua = await read("Assets/Script/Lib/Agent/CodingAgent.lua");
const webServer = await read("Assets/Script/Dev/WebServer.yue");
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
assert.match(registry, /name: "search_dora_doc"/);
assert.match(registry, /enum: \["dora-tutorial", "dora-api", "love-api", "tic80-api"\]/);
assert.match(codingAgent, /main\.on\("search_dora_doc", searchDora\)/);
assert.equal(codingAgent.match(/main\.on\("search_dora_doc", searchDora\)/g)?.length, 1);
assert.match(toolsLua, /function ____exports\.searchDoraDoc\(req\)/);
assert.match(toolsLua, /"!\*\*\/love\.d\." \.\. ext/);
assert.match(toolsLua, /"!\*\*\/tic80\.d\." \.\. ext/);
assert.match(registryLua, /name = "search_dora_doc"/);
assert.match(codingAgentLua, /main:on\("search_dora_doc", searchDora\)/);
assert.equal(codingAgentLua.match(/main:on\("search_dora_doc", searchDora\)/g)?.length, 1);

for (const language of ["en", "zh-Hans"]) {
	for (const extension of ["ts", "tl"]) {
		const definition = await read(`Assets/Script/Lib/Dora/${language}/love.d.${extension}`);
		const links = definition.match(/https:\/\/love2d\.org\/wiki\//g) ?? [];
		assert.ok(links.length >= 900, `${language}/love.d.${extension} must retain broad official API coverage`);
		assert.match(definition, /Gets the width of the Texture\./);
		assert.match(definition, /Draws objects on the screen\.|Draws a Drawable object/);
		assert.match(definition, /FreeBSD Documentation License/);
	}
}

console.log("Agent documentation search tests passed.");
