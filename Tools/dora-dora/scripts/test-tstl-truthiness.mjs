import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { createRequire } from "node:module";
import { build } from "esbuild";
import ts from "typescript";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const projectDir = resolve(scriptDir, "..");
const require = createRequire(import.meta.url);
const tempDir = mkdtempSync(join(tmpdir(), "dora-tstl-truthiness-"));
const diagnosticText = "Only false and nil evaluate to 'false' in Lua";

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
	const compile = (type, expression) => {
		const result = tstl.transpileVirtualProject(
			{
				"main.ts": `declare const condition: ${type};\n${expression}`,
			},
			{
				strict: true,
				target: ts.ScriptTarget.ESNext,
				module: ts.ModuleKind.CommonJS,
				luaTarget: tstl.LuaTarget.Lua55,
				noHeader: true,
			},
		);
		return result.diagnostics.filter(diagnostic =>
			diagnostic.source === "typescript-to-lua" &&
			ts.flattenDiagnosticMessageText(diagnostic.messageText, "\n").includes(diagnosticText)
		);
	};

	for (const type of ["number", "string", "object", "string | number"]) {
		const directDiagnostics = compile(type, "if (condition) {}");
		const negatedDiagnostics = compile(type, "if (!condition) {}");
		assert.equal(negatedDiagnostics.length, 1, `if (!condition) must diagnose ${type}`);
		assert.deepEqual(
			negatedDiagnostics.map(({ code, category }) => ({ code, category })),
			directDiagnostics.map(({ code, category }) => ({ code, category })),
			`if (!condition) must use the same diagnostic as if (condition) for ${type}`,
		);
	}
	assert.equal(compile("number", "const hidden = !condition;").length, 1, "standalone !number must be diagnosed");
	assert.equal(compile("number", "if (!!condition) {}").length, 1, "double negation must diagnose the source operand once");
	assert.equal(compile("boolean", "if (!condition) {}").length, 0, "boolean negation must remain valid");
	assert.equal(compile("boolean", "const hidden = !condition;").length, 0, "standalone boolean negation must remain valid");

	console.log("TSTL logical-not truthiness diagnostics passed.");
} finally {
	rmSync(tempDir, { recursive: true, force: true });
}
