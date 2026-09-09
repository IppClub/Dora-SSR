import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {execFileSync} from "node:child_process";

const packagePath = path.resolve(process.argv[2] || "");
const stageDirectory = path.resolve(process.argv[3] || "");
assert.ok(process.argv[2] && fs.statSync(packagePath, {throwIfNoEntry: false})?.isFile(),
	"complex project .dora package is missing");
assert.ok(process.argv[3] && path.basename(stageDirectory) === "love-complex-stage",
	"complex project staging target must end in love-complex-stage");

fs.rmSync(stageDirectory, {recursive: true, force: true});
fs.mkdirSync(stageDirectory, {recursive: true});
execFileSync("unzip", ["-qq", packagePath, "-d", stageDirectory], {stdio: "pipe"});

function walk(directory) {
	for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
		const absolute = path.join(directory, entry.name);
		assert.ok(!entry.isSymbolicLink(), `complex project package extracted a symlink: ${absolute}`);
		if (entry.isDirectory()) walk(absolute);
	}
}
walk(stageDirectory);
for (const relative of ["main.lua", "conf.lua", "version.jkr"])
	assert.ok(fs.statSync(path.join(stageDirectory, relative), {throwIfNoEntry: false})?.isFile(),
		`complex project staged runtime is missing: ${relative}`);
for (const relative of ["resources", "localization", "engine"])
	assert.ok(fs.statSync(path.join(stageDirectory, relative), {throwIfNoEntry: false})?.isDirectory(),
		`complex project staged runtime is missing: ${relative}`);
assert.ok(!fs.readFileSync(path.join(stageDirectory, "main.lua"), "utf8").includes("LoveNode("),
	"Love Web complex-project entry must not invoke its Dora wrapper");
console.log(`[INFO] Staged licensed Love complex package at ${stageDirectory}`);
