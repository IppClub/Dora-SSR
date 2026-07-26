import assert from "node:assert/strict";
import { build } from "esbuild";
import { mkdtemp } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const outputDir = await mkdtemp(path.join(tmpdir(), "dora-agent-render-window-"));
const outputFile = path.join(outputDir, "AgentRenderWindow.mjs");
await build({
	entryPoints: [path.resolve("src/AgentRenderWindow.ts")],
	bundle: true,
	format: "esm",
	platform: "node",
	outfile: outputFile,
});
const { getAgentTailRenderWindow } = await import(pathToFileURL(outputFile).href);

const steps = Array.from({ length: 200 }, (_, index) => ({ id: index + 1 }));
const initial = getAgentTailRenderWindow(steps, 80, 80);
assert.equal(initial.items.length, 80);
assert.equal(initial.items[0].id, 121);
assert.equal(initial.hiddenCount, 120);
assert.equal(initial.revealCount, 80);

const expanded = getAgentTailRenderWindow(steps, 160, 80);
assert.equal(expanded.items.length, 160);
assert.equal(expanded.items[0].id, 41);
assert.equal(expanded.hiddenCount, 40);
assert.equal(expanded.revealCount, 40);

const hidden = getAgentTailRenderWindow(steps, 0, 80);
assert.equal(hidden.items.length, 0);
assert.equal(hidden.hiddenCount, 200);
assert.equal(hidden.revealCount, 80);

const complete = getAgentTailRenderWindow(steps, 240, 80);
assert.equal(complete.items, steps, "fully visible windows should reuse the source array");
assert.equal(complete.hiddenCount, 0);
assert.equal(complete.revealCount, 0);

console.log("Agent render window bounded-tail and reveal tests passed.");
