import assert from "node:assert/strict";
import { build } from "esbuild";
import { mkdtemp } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const outputDir = await mkdtemp(path.join(tmpdir(), "dora-agent-patch-"));
const outputFile = path.join(outputDir, "AgentPatchBatch.mjs");
await build({
	entryPoints: [path.resolve("src/AgentPatchBatch.ts")],
	bundle: true,
	format: "esm",
	platform: "node",
	outfile: outputFile,
});
const {
	agentCollectionToArray,
	applyMessagePatches,
	applyStepPatches,
	applyCheckpointPatches,
	applyMessageCollectionPatches,
	createMessageCollection,
	reconcileMessageCollection,
	isImmediateAgentPatch,
} = await import(pathToFileURL(outputFile).href);

const patches = [
	{ sessionId: 1, message: { id: 2, content: "partial" } },
	{ sessionId: 1, message: { id: 2, content: "complete" } },
	{ sessionId: 1, message: { id: 1, content: "first" } },
];
assert.deepEqual(
	applyMessagePatches([], patches).map(({ id, content }) => ({ id, content })),
	[{ id: 1, content: "first" }, { id: 2, content: "complete" }],
);

assert.deepEqual(
	applyStepPatches(
		[{ id: 1, taskId: 1, step: 1 }],
		[
			{ sessionId: 1, step: { id: 2, taskId: 2, step: 1 } },
			{ sessionId: 1, removedStepIds: [2] },
			{ sessionId: 1, step: { id: 2, taskId: 2, step: 2 } },
		],
	).map(({ id, step }) => ({ id, step })),
	[{ id: 2, step: 2 }, { id: 1, step: 1 }],
);

assert.deepEqual(
	applyCheckpointPatches(
		[{ id: 1, taskId: 1, seq: 1 }],
		[
			{ sessionId: 1, checkpoint: { id: 2, taskId: 1, seq: 2 } },
			{ sessionId: 1, checkpoints: [{ id: 3, taskId: 2, seq: 1 }] },
			{ sessionId: 1, checkpoint: { id: 4, taskId: 2, seq: 2 } },
		],
	).map(({ id }) => id),
	[4, 3],
);

assert.equal(isImmediateAgentPatch({ sessionId: 1, pendingQuestionnaire: false }), true);
assert.equal(isImmediateAgentPatch({ sessionId: 1, message: { id: 1 } }), false);

const initialMessages = Array.from({ length: 200 }, (_, index) => ({
	id: index + 1,
	content: `message-${index + 1}`,
}));
const streamingPatches = Array.from({ length: 5_000 }, (_, index) => ({
	sessionId: 1,
	message: {
		id: 200,
		content: `stream-${index}`,
	},
}));
let oldMessages = initialMessages;
const oldStart = performance.now();
for (const patch of streamingPatches) {
	const next = [...oldMessages];
	const index = next.findIndex((message) => message.id === patch.message.id);
	next[index] = patch.message;
	oldMessages = next.sort((left, right) => left.id - right.id);
}
const oldDuration = performance.now() - oldStart;
const batchStart = performance.now();
const batchedMessages = applyMessagePatches(initialMessages, streamingPatches);
const batchDuration = performance.now() - batchStart;
assert.equal(batchedMessages[199].content, "stream-4999");
assert.equal(oldMessages[199].content, "stream-4999");

const initialCollection = createMessageCollection(initialMessages);
const normalizedStart = performance.now();
const normalizedCollection = applyMessageCollectionPatches(initialCollection, streamingPatches);
const normalizedDuration = performance.now() - normalizedStart;
assert.equal(normalizedCollection.orderedIds, initialCollection.orderedIds, "updates to an existing entity should reuse ordering");
assert.equal(normalizedCollection.byId.get(1), initialCollection.byId.get(1), "stable entities should keep their references");
assert.equal(normalizedCollection.byId.get(200).content, "stream-4999");
assert.equal(agentCollectionToArray(normalizedCollection)[199].content, "stream-4999");

const appendedCollection = applyMessageCollectionPatches(normalizedCollection, [
	{ sessionId: 1, message: { id: 201, content: "new" } },
]);
assert.notEqual(appendedCollection.orderedIds, normalizedCollection.orderedIds);
assert.equal(appendedCollection.orderedIds.at(-1), 201);

const refreshedCollection = reconcileMessageCollection(
	normalizedCollection,
	agentCollectionToArray(normalizedCollection).map(message => ({ ...message })),
);
assert.equal(refreshedCollection, normalizedCollection, "an equivalent full refresh should preserve the collection");

const refreshedWithChange = reconcileMessageCollection(
	normalizedCollection,
	agentCollectionToArray(normalizedCollection).map(message => (
		message.id === 200 ? { ...message, content: "changed" } : { ...message }
	)),
);
assert.notEqual(refreshedWithChange, normalizedCollection);
assert.equal(refreshedWithChange.orderedIds, normalizedCollection.orderedIds);
assert.equal(refreshedWithChange.byId.get(1), normalizedCollection.byId.get(1));
assert.equal(refreshedWithChange.byId.get(200).content, "changed");

console.log("Agent patch batch merge tests passed.", {
	patches: streamingPatches.length,
	oldCommits: streamingPatches.length,
	batchedCommits: 1,
	oldDurationMs: Number(oldDuration.toFixed(2)),
	batchDurationMs: Number(batchDuration.toFixed(2)),
	normalizedDurationMs: Number(normalizedDuration.toFixed(2)),
});
