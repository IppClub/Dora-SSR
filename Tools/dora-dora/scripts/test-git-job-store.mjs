import assert from "node:assert/strict";
import { build } from "esbuild";

globalThis.window = {
	setTimeout,
	clearTimeout,
};

let pollCount = 0;
globalThis.fetch = async () => {
	pollCount++;
	const done = pollCount >= 2;
	return {
		json: async () => ({
			success: true,
			command: "log --metadata-only -n 1",
			status: {
				id: 42,
				state: done ? "done" : "running",
				kind: "log",
				repoPath: "/tmp/dora-git-job-store-test",
				progress: done ? 1 : 0.5,
			},
		}),
	};
};

const buildResult = await build({
	entryPoints: ["src/GitJobStore.ts"],
	bundle: true,
	format: "esm",
	platform: "node",
	write: false,
	define: {
		"process.env.NODE_ENV": JSON.stringify("development"),
	},
});
const source = buildResult.outputFiles[0].text;
const store = await import(`data:text/javascript;base64,${Buffer.from(source).toString("base64")}`);

const repoPath = "/tmp/dora-git-job-store-test";
let completionCount = 0;
const unsubscribe = store.subscribeGitJob(repoPath, () => {});
store.trackGitJob(repoPath, 42, "log --metadata-only -n 1", () => {
	completionCount++;
});
unsubscribe();

await new Promise(resolve => setTimeout(resolve, 750));

const snapshot = store.getGitJobSnapshot(repoPath);
assert.equal(snapshot?.status?.state, "done");
assert.equal(pollCount, 2);
assert.equal(completionCount, 0, "hidden panels must not receive component completion callbacks");
assert.equal(store.claimTerminalGitJob(repoPath, 42), true);
assert.equal(store.claimTerminalGitJob(repoPath, 42), false);

console.log("Git job store background polling and terminal recovery passed.");
