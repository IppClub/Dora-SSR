import assert from "node:assert/strict";
import { build } from "esbuild";
import { mkdtemp, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const repoRoot = path.resolve("../..");
const budgetSource = path.join(repoRoot, "Assets/Script/Lib/Agent/AgentStepBudget.ts");
const outputDir = await mkdtemp(path.join(tmpdir(), "dora-agent-step-budget-"));
const outputFile = path.join(outputDir, "AgentStepBudget.mjs");

await build({
	entryPoints: [budgetSource],
	bundle: true,
	format: "esm",
	platform: "node",
	outfile: outputFile,
});

const {
	getRemainingAgentWorkSteps,
	isFinalAgentDecisionTurn,
} = await import(pathToFileURL(outputFile).href);

assert.equal(isFinalAgentDecisionTurn(0, 999), false);
assert.equal(isFinalAgentDecisionTurn(997, 999), false);
assert.equal(isFinalAgentDecisionTurn(998, 999), true);
assert.equal(getRemainingAgentWorkSteps(0, 999), 998);
assert.equal(getRemainingAgentWorkSteps(997, 999), 1);
assert.equal(getRemainingAgentWorkSteps(998, 999), 0);
assert.equal(getRemainingAgentWorkSteps(999, 999), 0);

const sessionSource = await readFile(path.join(repoRoot, "Assets/Script/Lib/Agent/AgentSession.ts"), "utf8");
assert.match(
	sessionSource,
	/initialAgentStepCount:\s*getAgentStepCount\(session\.id, taskId\)/,
	"continuing an interrupted task must restore its cumulative agent step count",
);

const configSource = await readFile(path.join(repoRoot, "Assets/Script/Lib/Agent/AgentConfig.ts"), "utf8");
assert.match(configSource, /maxSteps:\s*999\b/, "the default long-running task limit must be 999");

const codingAgentSource = await readFile(path.join(repoRoot, "Assets/Script/Lib/Agent/CodingAgent.ts"), "utf8");
assert.match(
	codingAgentSource,
	/preExecutedResults\.size\s*>=\s*remainingWorkSteps/,
	"streaming tool pre-execution must respect the remaining task budget",
);
assert.match(
	codingAgentSource,
	/toolCalls\.length\s*>\s*1\s*&&\s*toolCalls\.length\s*>\s*remainingWorkSteps/,
	"parallel tool batches must not cross the remaining task budget",
);

console.log("Agent step budget tests passed.");
