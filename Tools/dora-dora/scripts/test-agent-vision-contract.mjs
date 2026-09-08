import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";

const repoRoot = path.resolve("../..");
const readAgentSource = relativePath => readFile(path.join(repoRoot, relativePath), "utf8");

const [workspaceSource, handlersSource, registrySource, visionSource, bindingSource, memorySource, workspaceLua, handlersLua, registryLua, visionLua, bindingLua, memoryLua] = await Promise.all([
	readAgentSource("Assets/Script/Lib/Agent/Tool/Workspace.ts"),
	readAgentSource("Assets/Script/Lib/Agent/Tool/Handlers.ts"),
	readAgentSource("Assets/Script/Lib/Agent/Tool/Registry.ts"),
	readAgentSource("Assets/Script/Lib/Agent/Tool/VisionAnalysis.ts"),
	readAgentSource("Assets/Script/Lib/Agent/Tool/VisionBinding.ts"),
	readAgentSource("Assets/Script/Lib/Agent/Memory.ts"),
	readAgentSource("Assets/Script/Lib/Agent/Tool/Workspace.lua"),
	readAgentSource("Assets/Script/Lib/Agent/Tool/Handlers.lua"),
	readAgentSource("Assets/Script/Lib/Agent/Tool/Registry.lua"),
	readAgentSource("Assets/Script/Lib/Agent/Tool/VisionAnalysis.lua"),
	readAgentSource("Assets/Script/Lib/Agent/Tool/VisionBinding.lua"),
	readAgentSource("Assets/Script/Lib/Agent/Memory.lua"),
]);

assert.match(workspaceSource, /preferSourceVariants\?: boolean/);
assert.match(
	workspaceSource,
	/Content\.glob\(searchRoot, globs, req\.preferSourceVariants === false \? \{\} : extensionLevels\)/,
	"file inventory must be able to retain same-basename variants",
);
assert.match(
	handlersSource,
	/preferSourceVariants: false/,
	"Agent glob_files must request a complete inventory",
);
assert.doesNotMatch(
	workspaceSource.match(/export function listFiles[\s\S]*?\n\}/)?.[0] ?? "",
	/preferSourceVariants === true/,
	"internal callers must keep source preference by default",
);

for (const requiredRule of [
	"A capped, truncated, or non-exact listing does not prove that a file is absent",
	"Preserve the report's confidence and uncertainty",
	"Only images listed in the tool result were visually inspected",
	"label filename-based or creative use ideas as suggestions",
]) {
	assert.ok(registrySource.includes(requiredRule), `missing Agent evidence rule: ${requiredRule}`);
}

for (const requiredInstruction of [
	"answer under a separate label for every image",
	"Separate directly visible observations from inferences and candidate creative uses",
	"must never be stated as definite facts",
	"For sprite strips or sheets, compare the visible frames",
	"For tiny or dense sprite sheets, prefer neutral descriptions",
	"do not assign an animation, action, state, or direction unless the pixels show it",
	"Do not infer file existence, metadata, source-code causes, or gameplay/input testing from images",
]) {
	assert.ok(visionSource.includes(requiredInstruction), `missing vision grounding instruction: ${requiredInstruction}`);
}
assert.match(visionSource, /temperature:0\.1,top_p:0\.6/);
assert.ok(visionSource.includes("reportGuidance:\"Qualitative visual observation only"));
assert.match(bindingSource, /VISION_PROFILE_VERSION = 5/);
assert.match(bindingSource, /model: "glm-5\.3-flash"/);
assert.match(visionSource, /reasoning_effort:"low"/);
assert.ok(memorySource.includes("earlier-turn listing does not prove absence"));
assert.ok(memorySource.includes("Preserve confidence and uncertainty from visual reports"));

assert.match(workspaceLua, /req\.preferSourceVariants == false and \(\{\}\) or extensionLevels/);
assert.match(handlersLua, /preferSourceVariants = false/);
for (const requiredRule of ["does not prove that a file is absent", "confidence and uncertainty", "were visually inspected"]) {
	assert.ok(registryLua.includes(requiredRule), `generated registry is missing evidence rule: ${requiredRule}`);
}
for (const requiredInstruction of ["separate label for every image", "sprite strips or sheets", "must never be stated as definite facts"]) {
	assert.ok(visionLua.includes(requiredInstruction), `generated vision prompt is missing instruction: ${requiredInstruction}`);
}
assert.match(visionLua, /temperature = 0\.1/);
assert.ok(visionLua.includes("reportGuidance = \"Qualitative visual observation only"));
assert.match(bindingLua, /VISION_PROFILE_VERSION = 5/);
assert.match(bindingLua, /model = "glm-5\.3-flash"/);
assert.match(visionLua, /reasoning_effort = "low"/);
assert.ok(memoryLua.includes("earlier-turn listing does not prove absence"));
assert.ok(memoryLua.includes("Preserve confidence and uncertainty from visual reports"));

console.log("Agent image-analysis evidence contract tests passed.");
