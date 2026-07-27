import assert from "node:assert/strict";
import { build } from "esbuild";
import { mkdtemp } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const outputDir = await mkdtemp(path.join(tmpdir(), "dora-agent-auto-scroll-"));
const outputFile = path.join(outputDir, "AgentAutoScroll.mjs");
await build({
	entryPoints: [path.resolve("src/AgentAutoScroll.ts")],
	bundle: true,
	format: "esm",
	platform: "node",
	outfile: outputFile,
});
const { resolveAgentAutoScrollState } = await import(pathToFileURL(outputFile).href);

const layoutGrowth = resolveAgentAutoScrollState({
	followingOutput: true,
	previousScrollTop: 600,
	previousScrollHeight: 1000,
	scrollTop: 600,
	scrollHeight: 1800,
	distanceToBottom: 800,
});
assert.equal(layoutGrowth.atBottom, false);
assert.equal(layoutGrowth.followingOutput, true, "content growth must not disable output following");

const userScrollUp = resolveAgentAutoScrollState({
	followingOutput: true,
	previousScrollTop: 800,
	previousScrollHeight: 1200,
	scrollTop: 500,
	scrollHeight: 1200,
	distanceToBottom: 300,
});
assert.equal(userScrollUp.followingOutput, false, "an upward user scroll must pause output following");

const contentShrink = resolveAgentAutoScrollState({
	followingOutput: true,
	previousScrollTop: 800,
	previousScrollHeight: 1400,
	scrollTop: 500,
	scrollHeight: 1000,
	distanceToBottom: 100,
});
assert.equal(contentShrink.followingOutput, true, "content shrinkage must not look like a user scroll");

const returnToBottom = resolveAgentAutoScrollState({
	followingOutput: false,
	previousScrollTop: 500,
	previousScrollHeight: 1200,
	scrollTop: 800,
	scrollHeight: 1200,
	distanceToBottom: 0,
});
assert.equal(returnToBottom.followingOutput, true, "reaching the bottom must resume output following");

console.log("Agent auto-scroll intent and layout-change tests passed.");
