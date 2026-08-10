import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";
import { createRequire } from "node:module";
import { build } from "esbuild";
import ts from "typescript";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
const projectDir = resolve(scriptDir, "..");
const repoDir = resolve(projectDir, "../..");
const declarations = [
	resolve(repoDir, "Assets/Script/Lib/Dora/en/es6-subset.d.ts"),
	resolve(repoDir, "Assets/Script/Lib/Dora/zh-Hans/es6-subset.d.ts"),
];

const source = `
function assert(condition: unknown, message: string): asserts condition {
	if (!condition) throw new Error(message);
}

const mutable = [3, 1, 2];
const readonly: readonly number[] = mutable;
const nested: readonly (number | readonly number[])[] = [1, [2, 3]];

assert(mutable.at(-1) === 2, "Array.at");
assert(readonly.at(0) === 3, "ReadonlyArray.at");
assert(mutable.includes(1), "Array.includes");
assert(readonly.includes(2), "ReadonlyArray.includes");
assert(nested.flat().join(",") === "1,2,3", "Array.flat");
assert(readonly.toReversed().join(",") === "2,1,3", "Array.toReversed");
assert(readonly.toSorted((a, b) => a - b).join(",") === "1,2,3", "Array.toSorted");
assert(readonly.toSpliced(1, 1, 4).join(",") === "3,4,2", "Array.toSpliced");
assert(readonly.with(-1, 4).join(",") === "3,1,4", "Array.with");
let invalidWithRejected = false;
try {
	readonly.with(readonly.length, 4);
} catch {
	invalidWithRejected = true;
}
assert(invalidWithRejected, "Array.with rejects an out-of-range index");
assert(mutable.join(",") === "3,1,2", "copying array methods do not mutate their source");

assert("a-a".replaceAll("a", "b") === "b-b", "String.replaceAll string");
assert("a-a".replaceAll("a", value => value.toUpperCase()) === "A-A", "String.replaceAll callback");
assert("  x  ".trimStart() === "x  ", "String.trimStart");
assert("  x  ".trimLeft() === "x  ", "String.trimLeft");
assert("  x  ".trimEnd() === "  x", "String.trimEnd");
assert("  x  ".trimRight() === "  x", "String.trimRight");
assert("x".padStart(3, "0") === "00x", "String.padStart");
assert("x".padEnd(3, "0") === "x00", "String.padEnd");

const object = Object.fromEntries([["first", 1], ["second", 2]]);
assert(Object.values(object).reduce((sum, value) => sum + value, 0) === 3, "Object.values");
assert(Object.entries(object).length === 2, "Object.entries");
const described = Object.defineProperty({}, "first", { value: 1 });
assert(Object.getOwnPropertyDescriptors(described).first.value === 1, "Object.getOwnPropertyDescriptors");

let finalized = false;
Promise.resolve(1).finally(() => { finalized = true; });
assert(finalized, "Promise.finally");

let settled = false;
Promise.allSettled([Promise.resolve(1), Promise.reject("no")]).then(results => {
	settled = results[0].status === "fulfilled" && results[1].status === "rejected";
});
assert(settled, "Promise.allSettled");

let anyValue = 0;
Promise.any([Promise.reject("no"), Promise.resolve(2)]).then(value => { anyValue = value; });
assert(anyValue === 2, "Promise.any");
`;

const tempDir = mkdtempSync(join(tmpdir(), "dora-es6-subset-"));
const originalCwd = process.cwd();

try {
	const tstlBundle = join(tempDir, "tstl.cjs");
	await build({
		entryPoints: [resolve(projectDir, "src/3rdParty/tstl/index.ts")],
		bundle: true,
		platform: "node",
		format: "cjs",
		outfile: tstlBundle,
		loader: { ".lua": "text" },
		logLevel: "silent",
	});

	const tstl = require(tstlBundle);
	process.chdir(resolve(repoDir, "Assets/Script/Lib"));
	let emittedLua;

	for (const declarationPath of declarations) {
		const result = tstl.transpileVirtualProject(
			{
				"es6-subset.d.ts": readFileSync(declarationPath, "utf8"),
				"main.ts": source,
			},
			{
				noLib: true,
				strict: true,
				target: ts.ScriptTarget.ESNext,
				module: ts.ModuleKind.CommonJS,
				luaTarget: tstl.LuaTarget.Lua54,
				luaLibImport: tstl.LuaLibImportKind.Require,
				noHeader: true,
			},
		);

		const errors = result.diagnostics.filter(diagnostic => diagnostic.category === ts.DiagnosticCategory.Error);
		assert.equal(
			errors.length,
			0,
			errors.map(diagnostic => ts.flattenDiagnosticMessageText(diagnostic.messageText, "\n")).join("\n"),
		);

		const main = result.transpiledFiles.find(file => file.outPath.endsWith("main.lua"));
		assert(main, `No Lua output generated with ${declarationPath}`);
		assert(main.lua, `Lua output is empty with ${declarationPath}`);
		emittedLua ??= main.lua;
	}

	const luaFile = join(tempDir, "main.lua");
	writeFileSync(luaFile, emittedLua, "utf8");
	const runtime = spawnSync("lua", [luaFile], {
		cwd: resolve(repoDir, "Assets/Script/Lib"),
		encoding: "utf8",
	});
	assert.equal(runtime.status, 0, runtime.stderr || runtime.stdout);

	console.log("es6-subset declarations and TSTL runtime APIs passed for en and zh-Hans");
} finally {
	process.chdir(originalCwd);
	rmSync(tempDir, { recursive: true, force: true });
}
