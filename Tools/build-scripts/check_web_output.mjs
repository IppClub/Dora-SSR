import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";

const outputDir = path.resolve(process.argv[2] || "result/dora-web-build-probe");
for (const file of ["index.html", "dora-player.html", "dora-player.js", "dora-player.wasm"]) {
	const filePath = path.join(outputDir, file);
	if (!fs.existsSync(filePath) || fs.statSync(filePath).size === 0) {
		throw new Error(`missing or empty Web artifact: ${filePath}`);
	}
}

const wasm = fs.readFileSync(path.join(outputDir, "dora-player.wasm"));
if (!WebAssembly.validate(wasm)) throw new Error("dora-player.wasm is not a valid WebAssembly module");
const module = await WebAssembly.compile(wasm);
const imports = WebAssembly.Module.imports(module);
const exports = WebAssembly.Module.exports(module);
const importObject = {};
for (const entry of imports) {
	importObject[entry.module] ??= {};
	if (entry.kind === "function") importObject[entry.module][entry.name] = () => 0;
}
await WebAssembly.instantiate(module, importObject);

const glue = fs.readFileSync(path.join(outputDir, "dora-player.js"), "utf8");
if (!glue.includes('Module["_dora_web_build_probe"]')) {
	throw new Error("dora_web_build_probe JavaScript export is missing");
}

const sizes = {};
for (const file of ["dora-player.js", "dora-player.wasm"]) {
	const bytes = fs.readFileSync(path.join(outputDir, file));
	sizes[file] = {
		raw: bytes.byteLength,
		gzip: zlib.gzipSync(bytes, { level: 9 }).byteLength,
		brotli: zlib.brotliCompressSync(bytes).byteLength
	};
}
fs.writeFileSync(path.join(outputDir, "size-report.json"), `${JSON.stringify({ sizes, imports, exports }, null, 2)}\n`);
console.log(`[INFO] WebAssembly validated; ${imports.length} imports, ${exports.length} exports`);
