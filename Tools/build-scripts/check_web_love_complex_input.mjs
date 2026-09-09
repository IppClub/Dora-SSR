import assert from "node:assert/strict";
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {execFileSync} from "node:child_process";

const descriptorPath = path.resolve(process.argv.find((argument) => argument.endsWith(".json"))
	|| "Projects/Web/love-complex-project.json");
const descriptor = fs.statSync(descriptorPath, {throwIfNoEntry: false})?.isFile()
	? JSON.parse(fs.readFileSync(descriptorPath, "utf8")) : null;
const pathEnvironment = descriptor?.source?.pathEnvironment || "DORA_WEB_LOVE_COMPLEX_PACKAGE";
const packagePath = path.resolve(process.env[pathEnvironment] || "");

assert.ok(descriptor, `complex project descriptor is missing: ${descriptorPath}`);
assert.ok(process.env[pathEnvironment], `${pathEnvironment} must point to the licensed local .dora package`);
assert.ok(fs.statSync(packagePath, {throwIfNoEntry: false})?.isFile(),
	`complex project package does not exist: ${packagePath}`);
assert.equal(path.extname(packagePath).toLowerCase(), ".dora", "complex project input must be a .dora package");

function digest(data) {
	return crypto.createHash("sha256").update(data).digest("hex");
}

const entries = execFileSync("unzip", ["-Z", "-1", packagePath],
	{encoding: "utf8", maxBuffer: 32 * 1024 * 1024}).split(/\r?\n/).filter(Boolean);
assert.ok(entries.length > 0, "complex project package is empty");
for (const entry of entries) {
	assert.ok(!entry.includes("\\"), `complex project package entry contains a backslash: ${entry}`);
	assert.ok(!entry.startsWith("/") && !/^[A-Za-z]:\//.test(entry),
		`complex project package entry is absolute: ${entry}`);
	assert.ok(!entry.split("/").includes(".."), `complex project package entry escapes its root: ${entry}`);
}
execFileSync("unzip", ["-tqq", packagePath], {stdio: "pipe"});

const required = ["main.lua", "conf.lua", "init.lua", "version.jkr", "resources/", "localization/", "engine/"];
for (const entry of required) assert.ok(entries.includes(entry), `complex project package is missing ${entry}`);
const loveMain = execFileSync("unzip", ["-p", packagePath, "main.lua"], {encoding: "utf8"});
const loveConfig = execFileSync("unzip", ["-p", packagePath, "conf.lua"], {encoding: "utf8"});
const doraEntry = execFileSync("unzip", ["-p", packagePath, "init.lua"], {encoding: "utf8"});
const versionRecord = execFileSync("unzip", ["-p", packagePath, "version.jkr"]);
assert.ok(loveMain.includes("function love.run()") && loveMain.includes("function love.load()"),
	"complex project Love entry is missing its runtime callbacks");
assert.ok(loveConfig.includes("function love.conf"), "complex project Love configuration is missing");
assert.ok(!loveMain.includes("LoveNode(") && !loveMain.includes("init_dora"),
	"selected Love runtime entry must not invoke Dora extensions");
assert.ok(doraEntry.includes('LoveNode("main.lua")'), "package Dora wrapper no longer hosts main.lua in LoveNode");

const actual = {
	archiveSha256: digest(fs.readFileSync(packagePath)),
	archiveBytes: fs.statSync(packagePath).size,
	entryCount: entries.length,
	gameVersion: versionRecord.toString("utf8").trim().split(/\r?\n/)[0],
	versionRecordSha256: digest(versionRecord),
	entrypoints: {love: "main.lua", loveConfig: "conf.lua", doraWrapper: "init.lua"},
};

assert.equal(descriptor.format, "dora-web-love-complex-package");
assert.equal(descriptor.version, 2);
assert.deepEqual(actual, descriptor.expected,
	"licensed complex project package drifted; review the new archive before updating the descriptor");
assert.equal(descriptor.runtime.usesDoraExtensions, false,
	"P5-09 selected Love runtime must not use Dora extensions");
assert.equal(descriptor.runtime.distribution, "local-only-not-bundled",
	"licensed project content must remain outside Dora-SSR artifacts");
console.log(`[INFO] Love Web complex input verified: ${descriptor.project.name} ${actual.gameVersion}, ${actual.entryCount} package entries`);
