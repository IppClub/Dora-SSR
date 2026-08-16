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
assert.match(tools, /const virtualDocPath = isVirtualDoc/);
assert.match(tools, /resolveAgentDoraDocFilePath\(requestedPath, req\.docLanguage \?\? "en"\)/);
assert.match(tools, /paged\.map\(row => \(\{ \.\.\.row, file: requestedPath \}\)\)/);
assert.match(tools, /grep_files with that exact @dora-doc path/);
assert.match(codingAgent, /docLanguage: shared\.useChineseResponse \? "zh" : "en"/);
assert.match(registry, /exact @dora-doc\/\.\.\. virtual document/);
assert.match(registry, /searchable with grep_files using the exact virtual path/);
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
	const tsDefinition = await read(`Assets/Script/Lib/Dora/${language}/love.d.ts`);
	const tealDefinition = await read(`Assets/Script/Lib/Dora/${language}/love.d.tl`);
	const stringEnums = [...tsDefinition.matchAll(/^\s*type\s+(\w+)\s*=\s*((?:"[^"]+"\s*\|\s*)*"[^"]+");$/gm)];
	assert.equal(stringEnums.length, 46, `${language}/love.d.ts string enum inventory changed unexpectedly`);
	const enumNames = stringEnums.map(([, name]) => name);
	const containsEnum = type => enumNames.some(name => new RegExp(`\\b${name}\\b`).test(type));
	assert.match(tealDefinition, /^local record LoveEnums$/m);
	assert.match(tealDefinition, /^local record Love\n\tembed LoveEnums$/m);
	for (const [, name, valuesSource] of stringEnums) {
		const expectedValues = [...valuesSource.matchAll(/"([^"]+)"/g)].map(match => match[1]);
		const enumMatches = [...tealDefinition.matchAll(new RegExp(`^\\tenum ${name}\\n((?:\\t\\t[^\\n]+\\n)+)`, "gm"))];
		assert.equal(enumMatches.length, 1, `${language}/love.d.tl must declare ${name} exactly once`);
		const actualValues = enumMatches[0][1].trim().split("\n").map(line => line.trim().replace(/^"|"$/g, ""));
		assert.deepEqual(actualValues, expectedValues, `${language}/love.d.tl ${name} values must match TypeScript`);
		assert.match(tealDefinition, new RegExp(`^local type ${name} = LoveEnums\\.${name}$`, "m"), `${language}/love.d.tl must retain the short alias for Love.${name}`);
	}
	assert.match(tealDefinition, /circle: function\(mode: DrawMode,/);
	assert.match(tealDefinition, /setFilter: function\(self: Image, min_filter: FilterMode, mag_filter\?: FilterMode,/);
	assert.match(tealDefinition, /getGamepadMapping: function\(self: Joystick, input: GamepadAxis \| GamepadButton\): JoystickInputType \| nil,/);
	assert.match(tealDefinition, /getOS: function\(\): OS/);
	assert.match(tealDefinition, /newBody: function\(world: World, x\?: number, y\?: number, body_type\?: BodyType\)/);
	assert.doesNotMatch(tealDefinition, /(rectangle|circle|ellipse|polygon): function\(mode: string,/);
	const tealLines = tealDefinition.split("\n");
	let checkedEnumParamDocs = 0;
	let checkedEnumReturnDocs = 0;
	for (let lineIndex = 0; lineIndex < tealLines.length; lineIndex++) {
		const signature = tealLines[lineIndex].match(/^\s*\w+: function\((.*)\)(?::\s*(.+))?$/);
		if (!signature) continue;
		const commentLines = [];
		for (let index = lineIndex - 1; index >= 0 && /^\s*--/.test(tealLines[index]); index--) commentLines.unshift(tealLines[index]);
		for (const parameter of signature[1].split(/,\s*/)) {
			const parameterMatch = parameter.match(/^(\w+)(?:\?)?:\s*(.+)$/);
			if (!parameterMatch || !containsEnum(parameterMatch[2])) continue;
			const documented = commentLines
				.map(line => line.match(/@param\s+(\w+)\s+\(([^)]+)\)/))
				.find(match => match?.[1] === parameterMatch[1]);
			if (!documented) continue;
			assert.equal(documented[2], parameterMatch[2], `${language}/love.d.tl ${parameterMatch[1]} documentation must use its enum type`);
			checkedEnumParamDocs++;
		}
		if (!signature[2]) continue;
		const documentedReturns = commentLines.map(line => line.match(/@return\s+\(([^)]+)\)/)).filter(Boolean);
		for (const [index, returnType] of signature[2].split(/,\s*/).entries()) {
			if (!containsEnum(returnType) || !documentedReturns[index]) continue;
			assert.equal(documentedReturns[index][1], returnType, `${language}/love.d.tl return documentation must use ${returnType}`);
			checkedEnumReturnDocs++;
		}
	}
	assert.ok(checkedEnumParamDocs >= 60, `${language}/love.d.tl must retain enum parameter documentation coverage`);
	assert.ok(checkedEnumReturnDocs >= 40, `${language}/love.d.tl must retain enum return documentation coverage`);

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

for (const [language, enumDocPath] of [
	["en", "Docs/docs/api/Class/Love.mdx"],
	["zh-Hans", "Docs/i18n/zh-Hans/docusaurus-plugin-content-docs/current/api/Class/Love.mdx"],
]) {
	const enumDoc = await read(enumDocPath);
	const tsDefinition = await read(`Assets/Script/Lib/Dora/${language}/love.d.ts`);
	const expectedEnumNames = [...tsDefinition.matchAll(/^\s*type\s+(\w+)\s*=\s*(?:"[^"]+"\s*\|\s*)*"[^"]+";$/gm)].map(match => match[1]);
	assert.equal(expectedEnumNames.length, 46, `${language} Love enum inventory changed unexpectedly`);
	const enumerationLabel = language === "en" ? "\\*\\*Type:\\*\\* Enumeration\\." : "\\*\\*类型：\\*\\* 枚举。";
	assert.equal((enumDoc.match(new RegExp(enumerationLabel, "g")) ?? []).length, expectedEnumNames.length, `${language} Love page must document every enumeration`);
	for (const enumName of expectedEnumNames) {
		assert.match(enumDoc, new RegExp(`^## Love\\.${enumName}\\n\\n${enumerationLabel}`, "m"));
		assert.match(enumDoc, new RegExp(`\\nenum ${enumName}\\n`));
	}
}

console.log("Agent documentation search tests passed.");
