import assert from "node:assert/strict";
import { build } from "esbuild";
import { mkdtemp, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const repoRoot = path.resolve("../..");
const budgetSource = path.join(repoRoot, "Assets/Script/Lib/Agent/Runtime/StepBudget.ts");
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
	getPlainTextCompletionBudgetState,
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
assert.deepEqual(getPlainTextCompletionBudgetState(997, 999), {
	outcome: "completed",
	budgetExhausted: false,
});
assert.deepEqual(getPlainTextCompletionBudgetState(998, 999), {
	outcome: "partial",
	budgetExhausted: true,
});

const sessionSource = await readFile(path.join(repoRoot, "Assets/Script/Lib/Agent/Session.ts"), "utf8");
assert.match(
	sessionSource,
	/initialAgentStepCount:\s*getAgentStepCount\(session\.id, taskId\)/,
	"continuing an interrupted task must restore its cumulative agent step count",
);

const configSource = await readFile(path.join(repoRoot, "Assets/Script/Lib/Agent/Config.ts"), "utf8");
assert.match(configSource, /maxSteps:\s*999\b/, "the default long-running task limit must be 999");

const codingAgentSource = await readFile(path.join(repoRoot, "Assets/Script/Lib/Agent/DoraAgent.ts"), "utf8");
assert.match(
	codingAgentSource,
	/preExecutedResults\.size\s*>=\s*remainingWorkSteps/,
	"streaming tool pre-execution must respect the remaining task budget",
);
assert.match(
	codingAgentSource,
	/decisions\.length\s*>\s*remainingWorkSteps/,
	"oversized tool batches must be detected for diagnostics",
);
assert.match(
	codingAgentSource,
	/executing complete tool batch beyond remaining step budget/,
	"every tool call already returned by the model must be retained at the budget boundary",
);
assert.doesNotMatch(
	codingAgentSource,
	/tool call batch exceeds the remaining task step budget/,
	"an oversized tool batch must not reject and retry the current decision turn",
);
assert.match(
	codingAgentSource,
	/preExecutionFailure:\s*\{ code, message \}/,
	"invalid tool calls must become per-call failure results",
);
assert.match(
	codingAgentSource,
	/executeToolActionSafely/,
	"unexpected execution failures must be isolated to their individual tool calls",
);
assert.match(
	codingAgentSource,
	/budgetExhausted:\s*completion\.budgetExhausted/,
	"task_finished events must expose whether the step budget ended the task",
);

console.log("Agent step budget tests passed.");
