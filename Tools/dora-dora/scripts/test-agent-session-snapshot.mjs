import assert from "node:assert/strict";
import { build } from "esbuild";
import { mkdtemp } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const outputDir = await mkdtemp(path.join(tmpdir(), "dora-agent-snapshot-"));
const outputFile = path.join(outputDir, "AgentSessionSnapshot.mjs");
await build({
	entryPoints: [path.resolve("src/AgentSessionSnapshot.ts")],
	bundle: true,
	format: "esm",
	platform: "node",
	outfile: outputFile,
});
const {
	clearAgentSessionSnapshotsForTest,
	getAgentSessionSnapshot,
	setAgentSessionSnapshot,
} = await import(pathToFileURL(outputFile).href);

const makeSnapshot = (id) => ({
	session: { id },
	relatedSessions: [],
	spawnInfo: null,
	messages: [{ id, content: `message-${id}` }],
	steps: [],
	checkpoints: [],
	pendingQuestionnaire: null,
	workMode: "code",
	hasActivePlan: false,
});

clearAgentSessionSnapshotsForTest();
setAgentSessionSnapshot(1, makeSnapshot(1));
const first = getAgentSessionSnapshot(1);
assert.equal(first?.messages[0].content, "message-1");
first.messages.length = 0;
assert.equal(getAgentSessionSnapshot(1)?.messages.length, 1, "reads must not mutate the cache");

for (let id = 2; id <= 26; id += 1) {
	setAgentSessionSnapshot(id, makeSnapshot(id));
}
assert.equal(getAgentSessionSnapshot(1), null, "the least recently used snapshot must be evicted");
assert.equal(getAgentSessionSnapshot(26)?.session?.id, 26);

console.log("Agent session snapshot cache passed hydration and LRU tests.");
