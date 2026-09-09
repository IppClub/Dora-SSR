import fs from "node:fs";
import path from "node:path";

const args = process.argv.slice(2);
const allowAsyncify = args.includes("--allow-asyncify");
const outputArg = args.find((arg) => !arg.startsWith("--")) || "result/dora-web-player";
const outputDir = path.resolve(outputArg);
const wasmPath = path.join(outputDir, "dora-player-runtime.wasm");
const gluePath = path.join(outputDir, "dora-player-runtime.js");

for (const file of [wasmPath, gluePath]) {
	if (!fs.statSync(file, { throwIfNoEntry: false })?.isFile()) {
		throw new Error(`missing Web policy input: ${file}`);
	}
}

function readULEB(bytes, state) {
	let value = 0;
	let multiplier = 1;
	for (let count = 0; count < 10; count++) {
		if (state.offset >= bytes.length) throw new Error("truncated WebAssembly ULEB128");
		const byte = bytes[state.offset++];
		value += (byte & 0x7f) * multiplier;
		if ((byte & 0x80) === 0) return value;
		multiplier *= 128;
	}
	throw new Error("invalid WebAssembly ULEB128");
}

function skipName(bytes, state) {
	const length = readULEB(bytes, state);
	state.offset += length;
	if (state.offset > bytes.length) throw new Error("truncated WebAssembly name");
}

function readLimits(bytes, state) {
	const flags = readULEB(bytes, state);
	readULEB(bytes, state);
	if ((flags & 1) !== 0) readULEB(bytes, state);
	return flags;
}

function hasSharedMemory(bytes) {
	if (bytes.subarray(0, 8).toString("hex") !== "0061736d01000000") {
		throw new Error("invalid WebAssembly header");
	}
	const moduleState = { offset: 8 };
	while (moduleState.offset < bytes.length) {
		const sectionId = bytes[moduleState.offset++];
		const sectionSize = readULEB(bytes, moduleState);
		const sectionEnd = moduleState.offset + sectionSize;
		if (sectionEnd > bytes.length) throw new Error("truncated WebAssembly section");
		if (sectionId === 2) {
			const count = readULEB(bytes, moduleState);
			for (let index = 0; index < count; index++) {
				skipName(bytes, moduleState);
				skipName(bytes, moduleState);
				const kind = bytes[moduleState.offset++];
				if (kind === 0) readULEB(bytes, moduleState);
				else if (kind === 1) {
					moduleState.offset++;
					readLimits(bytes, moduleState);
				} else if (kind === 2) {
					if ((readLimits(bytes, moduleState) & 2) !== 0) return true;
				} else if (kind === 3) moduleState.offset += 2;
				else if (kind === 4) {
					readULEB(bytes, moduleState);
					readULEB(bytes, moduleState);
				} else throw new Error(`unsupported WebAssembly import kind: ${kind}`);
			}
		} else if (sectionId === 5) {
			const count = readULEB(bytes, moduleState);
			for (let index = 0; index < count; index++) {
				if ((readLimits(bytes, moduleState) & 2) !== 0) return true;
			}
		}
		moduleState.offset = sectionEnd;
	}
	return false;
}

function listFiles(directory) {
	return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
		const fullPath = path.join(directory, entry.name);
		return entry.isDirectory() ? listFiles(fullPath) : [fullPath];
	});
}

const wasm = fs.readFileSync(wasmPath);
const glue = fs.readFileSync(gluePath, "utf8");
const wasmText = wasm.toString("latin1");
const module = await WebAssembly.compile(wasm);
const sharedMemory = hasSharedMemory(wasm);
const dynamicSections = ["dylink", "dylink.0"].filter((name) => WebAssembly.Module.customSections(module, name).length > 0);
const forbiddenGlueTokens = [
	"SharedArrayBuffer",
	"Atomics.",
	"PROXY_TO_PTHREAD",
	"pthread-main.js",
	"loadDynamicLibrary",
	"dynamicLibraries"
].filter((token) => glue.includes(token));
const forbiddenRuntimeTokens = [
	"dora_3d_node_",
	"dora_3d_model_",
	"dora_3d_physics_",
	"JoltPhysics",
	"VideoNode:",
	"Ogg/Theora",
].filter((token) => wasmText.includes(token) || glue.includes(token));
const allFiles = listFiles(outputDir);
const forbiddenArtifacts = allFiles
	.filter((file) => /(?:\.(?:so|dylib|dll|a|o|bc)|(?:pthread-main|wasm-worker)\.js)$/i.test(file))
	.map((file) => path.relative(outputDir, file));

const absolutePathPattern = /(?:\/Users\/[A-Za-z0-9._-]+\/|\/home\/[A-Za-z0-9._-]+\/|[A-Za-z]:\\(?:Users|src|work)\\)/;
const secretPattern = /(?:-----BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY-----|AKIA[0-9A-Z]{16}|github_pat_[A-Za-z0-9_]{20,}|ghp_[A-Za-z0-9]{30,})/;
const leakedPaths = [];
const leakedSecrets = [];
for (const file of allFiles) {
	const contents = fs.readFileSync(file).toString("latin1");
	if (absolutePathPattern.test(contents)) leakedPaths.push(path.relative(outputDir, file));
	if (secretPattern.test(contents)) leakedSecrets.push(path.relative(outputDir, file));
}

const asyncify = glue.includes("_asyncify_start_unwind") || glue.includes("Asyncify");
const failures = [];
if (sharedMemory) failures.push("shared WebAssembly memory is enabled");
if (dynamicSections.length) failures.push(`dynamic-linking sections: ${dynamicSections.join(", ")}`);
if (forbiddenGlueTokens.length) failures.push(`forbidden glue tokens: ${forbiddenGlueTokens.join(", ")}`);
if (forbiddenRuntimeTokens.length) failures.push(`forbidden runtime tokens: ${forbiddenRuntimeTokens.join(", ")}`);
if (forbiddenArtifacts.length) failures.push(`forbidden artifacts: ${forbiddenArtifacts.join(", ")}`);
if (leakedPaths.length) failures.push(`absolute build paths leaked in: ${leakedPaths.join(", ")}`);
if (leakedSecrets.length) failures.push(`credential-like material leaked in: ${leakedSecrets.join(", ")}`);
if (asyncify && !allowAsyncify) failures.push("global Asyncify is enabled; pass --allow-asyncify only for tracked risk R-10");

const report = {
	sharedMemory,
	dynamicSections,
	forbiddenGlueTokens,
	forbiddenRuntimeTokens,
	forbiddenArtifacts,
	leakedPaths,
	leakedSecrets,
	asyncify,
	allowedRisks: asyncify && allowAsyncify ? ["R-10: global Asyncify remains temporarily allowed"] : []
};
fs.writeFileSync(path.join(outputDir, "dependency-report.json"), `${JSON.stringify(report, null, 2)}\n`);
if (failures.length) throw new Error(`Web dependency policy failed:\n- ${failures.join("\n- ")}`);
console.log(`[INFO] Web dependency policy passed${report.allowedRisks.length ? "; " + report.allowedRisks[0] : ""}`);
