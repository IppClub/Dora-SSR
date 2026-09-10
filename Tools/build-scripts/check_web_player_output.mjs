import fs from "node:fs";
import crypto from "node:crypto";
import path from "node:path";
import zlib from "node:zlib";

const outputDir = path.resolve(process.argv[2] || "result/dora-web-player");
const artifacts = [
	"index.html",
	"dora-player-runtime.html",
	"dora-player-runtime.js",
	"dora-player-runtime.wasm",
	"dora-player-runtime.data",
	"dora-web-manifest.json",
	"dora-web-features.json"
];

for (const file of artifacts) {
	const filePath = path.join(outputDir, file);
	if (!fs.existsSync(filePath) || fs.statSync(filePath).size === 0) {
		throw new Error(`missing or empty Web Player artifact: ${filePath}`);
	}
}

const html = fs.readFileSync(path.join(outputDir, "index.html"), "utf8");
if (!/id=(?:["']?canvas["']?)/.test(html)) throw new Error("Web Player canvas is missing");
if (!html.includes("data-dora-state") || !html.includes("doraStop")) {
	throw new Error("Web Player lifecycle contract is missing");
}

const glue = fs.readFileSync(path.join(outputDir, "dora-player-runtime.js"), "utf8");
if (!glue.includes("dora_web_stop")) throw new Error("Web Player stop export is missing");
if (!glue.includes("dora_web_set_suspended")) throw new Error("Web Player suspend export is missing");
if (!glue.includes("dora_web_release_input")) throw new Error("Web Player input release export is missing");
if (!glue.includes("dora_web_asset_complete") || !glue.includes("fetchPath")) {
	throw new Error("Web Player lazy asset bridge is missing");
}

const wasm = fs.readFileSync(path.join(outputDir, "dora-player-runtime.wasm"));
if (!WebAssembly.validate(wasm)) throw new Error("Web Player WASM is not valid");
const module = await WebAssembly.compile(wasm);
const imports = WebAssembly.Module.imports(module);
const exports = WebAssembly.Module.exports(module);

const manifest = JSON.parse(fs.readFileSync(path.join(outputDir, "dora-web-manifest.json"), "utf8"));
if (manifest.format !== "dora-web-game" || manifest.version !== 1 || !Array.isArray(manifest.files)) {
	throw new Error("Web game manifest format is invalid");
}

const features = JSON.parse(fs.readFileSync(path.join(outputDir, "dora-web-features.json"), "utf8"));
if (features.format !== "dora-web-features" || features.version !== 2 || features.activeProfile !== "dora-preset") {
	throw new Error("Web feature profile format or active profile is invalid");
}
if (features.profiles?.core?.available !== true || features.profiles?.["dora-preset"]?.available !== true || features.profiles?.custom?.available !== true) {
	throw new Error("Web configurable profile availability is invalid");
}
const requiredModules = ["lua", "content", "http", "idbfs", "doraPackage", "input", "audio", "drawNode", "sprite", "label", "renderTarget", "particle", "spine", "dragonBones", "nanoVG", "playRho2D", "entity", "platformer", "builtinLuaLibraries", "imGui"];
requiredModules.push("yueCompiler", "machineLearning");
const excludedModules = ["threads", "dynamicLinking", "rustBridge", "wasmRuntime", "tealCompiler", "loveNode", "model3D", "jolt3D", "video", "workspace"];
for (const moduleName of requiredModules) {
	if (features.modules?.[moduleName] !== true) throw new Error(`required Web module is not declared: ${moduleName}`);
}
for (const moduleName of excludedModules) {
	if (features.modules?.[moduleName] !== false) throw new Error(`excluded Web module is not declared: ${moduleName}`);
}
if (!manifest.files.some((file) => file.startup === true) || !manifest.files.some((file) => file.startup !== true)) {
	throw new Error("Web game manifest must exercise startup and lazy assets");
}
const compatibilityExamples = new Map([
	["Examples/LuaSprite.lua", null],
	["Examples/YueDraw.yue", null],
	["Examples/YueDraw.lua", "Examples/YueDraw.yue"],
	["Examples/TealLabel.tl", null],
	["Examples/TealLabel.lua", "Examples/TealLabel.tl"],
]);
for (const [examplePath, generatedFrom] of compatibilityExamples) {
	const entry = manifest.files.find((file) => file.path === examplePath);
	if (!entry || entry.startup === true) throw new Error(`Web compatibility example must be a lazy manifest asset: ${examplePath}`);
	if (generatedFrom) {
		const generated = fs.readFileSync(path.join(outputDir, ...entry.url.split("/")), "utf8");
		if (!generated.includes(generatedFrom)) throw new Error(`Web compatibility example provenance is missing: ${examplePath}`);
	}
}
for (const file of manifest.files) {
	const assetPath = path.join(outputDir, ...file.url.split("/"));
	if (!fs.existsSync(assetPath)) throw new Error(`manifest asset is missing: ${file.url}`);
	const bytes = fs.readFileSync(assetPath);
	if (bytes.byteLength !== file.size) throw new Error(`manifest asset size mismatch: ${file.path}`);
	if (crypto.createHash("sha256").update(bytes).digest("hex") !== file.sha256) {
		throw new Error(`manifest asset SHA-256 mismatch: ${file.path}`);
	}
}

const manifestAssets = manifest.files.map((file) => file.url).sort();
function listAssetFiles(directory) {
	return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
		const fullPath = path.join(directory, entry.name);
		return entry.isDirectory() ? listAssetFiles(fullPath) : [fullPath];
	});
}
const assetRoot = path.join(outputDir, "assets");
const packagedAssets = listAssetFiles(assetRoot)
	.map((file) => path.posix.join("assets", path.relative(assetRoot, file).split(path.sep).join("/")))
	.sort();
if (JSON.stringify(packagedAssets) !== JSON.stringify(manifestAssets)) {
	throw new Error(`packaged assets do not exactly match manifest: ${JSON.stringify({ manifestAssets, packagedAssets })}`);
}

const sizes = {};
let totalGzip = 0;
let totalBrotli = 0;
for (const file of artifacts.slice(1, 5)) {
	const bytes = fs.readFileSync(path.join(outputDir, file));
	const gzip = zlib.gzipSync(bytes, { level: 9 }).byteLength;
	const brotli = zlib.brotliCompressSync(bytes, {
		params: { [zlib.constants.BROTLI_PARAM_QUALITY]: 6 }
	}).byteLength;
	sizes[file] = { raw: bytes.byteLength, gzip, brotli };
	totalGzip += gzip;
	totalBrotli += brotli;
}

const gzipBudget = 20 * 1024 * 1024;
if (totalGzip > gzipBudget) {
	throw new Error(`Web Player gzip size ${totalGzip} exceeds ${gzipBudget}`);
}

const report = { sizes, totals: { gzip: totalGzip, brotli: totalBrotli }, imports, exports };
fs.writeFileSync(path.join(outputDir, "size-report.json"), `${JSON.stringify(report, null, 2)}\n`);
console.log(`[INFO] Web Player validated; gzip ${totalGzip} B, brotli ${totalBrotli} B`);
