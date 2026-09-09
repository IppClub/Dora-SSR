import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

const reportPath = path.resolve(process.argv[2] || "build/web-startup-performance.json");
const baselinePath = path.resolve(process.argv[3] || "Projects/Web/performance-baseline.json");
const outputPath = path.resolve(process.argv[4] || "build/web-performance-trend.json");

function readJson(file, label) {
	assert.ok(fs.statSync(file, {throwIfNoEntry: false})?.isFile(), `${label} is missing: ${file}`);
	return JSON.parse(fs.readFileSync(file, "utf8"));
}

function finiteNonNegative(value, label) {
	assert.ok(Number.isFinite(value) && value >= 0, `${label} must be a non-negative number`);
	return value;
}

const report = readJson(reportPath, "startup performance report");
const baseline = readJson(baselinePath, "performance baseline");
assert.equal(report.schemaVersion, 1, "unsupported startup performance report schema");
assert.equal(baseline.schemaVersion, 1, "unsupported performance baseline schema");
assert.ok(report.browser?.product, "startup performance report is missing browser identity");
const growth = finiteNonNegative(baseline.allowedGrowthPercent, "allowedGrowthPercent") / 100;

const comparisons = [];
for (const group of ["runtimeTotals", "firstLoadTotals"]) {
	for (const encoding of ["gzip", "brotli"]) {
		const current = finiteNonNegative(report.artifacts?.[group]?.[encoding], `report ${group}.${encoding}`);
		const reference = finiteNonNegative(baseline[group]?.[encoding], `baseline ${group}.${encoding}`);
		const limit = Math.floor(reference * (1 + growth));
		comparisons.push({metric: `${group}.${encoding}`, current, reference, limit, deltaPercent: ((current - reference) / reference) * 100, passed: current <= limit});
	}
}

const timings = [
	{metric: "cold.total", current: finiteNonNegative(report.cold?.total, "cold.total"), limit: finiteNonNegative(baseline.budgets?.coldMilliseconds, "coldMilliseconds")},
	{metric: "warm.total", current: finiteNonNegative(report.warm?.total, "warm.total"), limit: finiteNonNegative(baseline.budgets?.warmMilliseconds, "warmMilliseconds")},
].map((entry) => ({...entry, passed: entry.current <= entry.limit}));

const trend = {
	schemaVersion: 1,
	browser: report.browser,
	allowedGrowthPercent: baseline.allowedGrowthPercent,
	comparisons,
	timings,
	passed: comparisons.every((entry) => entry.passed) && timings.every((entry) => entry.passed),
};
fs.mkdirSync(path.dirname(outputPath), {recursive: true});
fs.writeFileSync(outputPath, `${JSON.stringify(trend, null, 2)}\n`);

const lines = [
	"### Dora Web performance trend",
	"",
	`Browser: \`${report.browser.product}\``,
	"",
	"| Metric | Current | Baseline/Budget | Limit | Result |",
	"| --- | ---: | ---: | ---: | --- |",
	...comparisons.map((entry) => `| ${entry.metric} | ${entry.current} B | ${entry.reference} B | ${entry.limit} B | ${entry.passed ? "pass" : "fail"} (${entry.deltaPercent.toFixed(2)}%) |`),
	...timings.map((entry) => `| ${entry.metric} | ${entry.current.toFixed(1)} ms | — | ${entry.limit} ms | ${entry.passed ? "pass" : "fail"} |`),
	"",
];
const summary = `${lines.join("\n")}\n`;
if (process.env.GITHUB_STEP_SUMMARY) fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, summary);
console.log(summary.trimEnd());
assert.equal(trend.passed, true, `Web performance trend exceeded its limit; see ${outputPath}`);
