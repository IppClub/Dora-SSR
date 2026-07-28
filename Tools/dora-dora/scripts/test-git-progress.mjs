import assert from "node:assert/strict";
import { build } from "esbuild";

const buildResult = await build({
	entryPoints: ["src/GitProgress.ts"],
	bundle: true,
	format: "esm",
	platform: "node",
	write: false,
});
const source = buildResult.outputFiles[0].text;
const progress = await import(`data:text/javascript;base64,${Buffer.from(source).toString("base64")}`);

assert.deepEqual(
	progress.parseGitProgressMessage("downloading LFS objects 1/3 · 5.0 MiB / 20.0 MiB"),
	{
		kind: "lfs-download",
		done: 1,
		total: 3,
		received: "5.0 MiB",
		totalBytes: "20.0 MiB",
		raw: "downloading LFS objects 1/3 · 5.0 MiB / 20.0 MiB",
	},
);
assert.deepEqual(
	progress.parseGitProgressMessage("downloading LFS objects 0/1"),
	{
		kind: "lfs-download",
		done: 0,
		total: 1,
		received: undefined,
		totalBytes: undefined,
		raw: "downloading LFS objects 0/1",
	},
);
assert.deepEqual(
	progress.parseGitProgressMessage("receiving objects"),
	{ kind: "message", raw: "receiving objects" },
);

console.log("Git progress message parsing passed.");
