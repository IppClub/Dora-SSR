import assert from "node:assert/strict";
import { build } from "esbuild";
import { mkdtemp, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const outputDir = await mkdtemp(path.join(tmpdir(), "dora-log-buffer-"));
const outputFile = path.join(outputDir, "LogBuffer.mjs");
await build({
	entryPoints: [path.resolve("src/LogBuffer.ts")],
	bundle: true,
	format: "esm",
	platform: "node",
	outfile: outputFile,
});
const { LogBuffer } = await import(pathToFileURL(outputFile).href);

const lineBuffer = new LogBuffer({ maxLines: 3, maxBytes: 1024 });
lineBuffer.append("one\n");
lineBuffer.append("two\n");
lineBuffer.append("three\n");
lineBuffer.append("four\n");
assert.equal(lineBuffer.getText(), "two\nthree\nfour\n");
assert.equal(lineBuffer.getStats().lines, 3);
assert.equal(lineBuffer.isTruncated(), true);

const byteBuffer = new LogBuffer({ maxLines: 100, maxBytes: 12 });
byteBuffer.append("1234");
byteBuffer.append("5678");
assert.equal(byteBuffer.getText(), "345678");
assert.ok(byteBuffer.getStats().bytes <= 12);

const pressureBuffer = new LogBuffer();
for (let index = 0; index < 30_000; index += 1) {
	pressureBuffer.append(`line-${index.toString().padStart(5, "0")} data data data\n`);
}
const stats = pressureBuffer.getStats();
assert.ok(stats.lines <= 10_000, JSON.stringify(stats));
assert.ok(stats.bytes <= 4 * 1024 * 1024, JSON.stringify(stats));
assert.equal(stats.truncated, true);
assert.ok(pressureBuffer.getText().endsWith("line-29999 data data data\n"));
assert.equal(pressureBuffer.getText(), pressureBuffer.getText(), "cached reads remain stable");

const source = await readFile(path.resolve("src/Service.ts"), "utf8");
assert.match(source, /eventEmitter\.emit\(WsEvent\.Log,\s*text\)/);
assert.doesNotMatch(source, /eventEmitter\.emit\(WsEvent\.Log,\s*text,\s*log/);

console.log("LogBuffer bounded-buffer and incremental-event tests passed.", stats);
