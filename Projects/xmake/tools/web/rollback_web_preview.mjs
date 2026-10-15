import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

const deploymentDir = path.resolve(process.argv[2] || "");
if (!process.argv[2]) throw new Error("usage: rollback_web_preview.mjs <deployment-dir>");

function writeAtomic(file, source) {
	const temporary = `${file}.tmp-${process.pid}`;
	fs.writeFileSync(temporary, source);
	fs.renameSync(temporary, file);
}

const pointerPath = path.join(deploymentDir, "dora-web-current.json");
assert.ok(fs.statSync(pointerPath, {throwIfNoEntry: false})?.isFile(), "current release pointer is missing");
const pointer = JSON.parse(fs.readFileSync(pointerPath, "utf8"));
assert.equal(pointer.schemaVersion, 1, "unsupported current release pointer schema");
assert.ok(pointer.previous, "no previous Web release is available for rollback");
assert.ok(fs.statSync(path.join(deploymentDir, "releases", pointer.previous), {throwIfNoEntry: false})?.isDirectory(), "previous Web release directory is missing");
const next = {schemaVersion: 1, current: pointer.previous, previous: pointer.current, entry: `releases/${pointer.previous}/index.html`};
writeAtomic(pointerPath, `${JSON.stringify(next, null, 2)}\n`);
console.log(`[INFO] Dora Web preview rolled back from ${pointer.current} to ${pointer.previous}`);
