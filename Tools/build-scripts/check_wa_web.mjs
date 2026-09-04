import fs from "node:fs";
import path from "node:path";

const outputDir = process.argv[2];
if (!outputDir) {
	console.error("Usage: node check_wa_web.mjs <package-directory>");
	process.exit(1);
}

const wasmPath = path.join(outputDir, "dora-wa.wasm");
const runtimePath = path.join(outputDir, "wasm_exec.js");
if (!fs.statSync(wasmPath).isFile() || !fs.statSync(runtimePath).isFile()) {
	throw new Error("browser Wa artifacts are missing");
}

globalThis.DoraWa = {};
globalThis.DoraWa.ready = Promise.resolve(globalThis.DoraWa);
eval(fs.readFileSync(runtimePath, "utf8"));

const go = new globalThis.Go();
const bytes = fs.readFileSync(wasmPath);
const { instance } = await WebAssembly.instantiate(bytes, go.importObject);
go.run(instance);

const deadline = Date.now() + 30000;
while (typeof globalThis.DoraWa.format !== "function") {
	if (Date.now() > deadline) throw new Error("browser Wa API initialization timed out");
	await new Promise(resolve => setTimeout(resolve, 10));
}

const result = await Promise.race([
	globalThis.DoraWa.format("local value = 1\n"),
	new Promise((_, reject) => setTimeout(() => reject(new Error("browser Wa format timed out")), 30000))
]);
if (typeof result !== "string") throw new Error("browser Wa format did not return a string");

console.log("[INFO] Browser Wa runtime smoke test passed");
process.exit(0);
