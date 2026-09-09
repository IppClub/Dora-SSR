import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

const inputDir = path.resolve(process.argv[2] || "");
const outputDir = path.resolve(process.argv[3] || "");
const entry = process.argv[4] || "init.lua";
const maxFiles = 4096;
const maxFileSize = 64 * 1024 * 1024;
const maxTotalSize = 256 * 1024 * 1024;

if (!process.argv[2] || !process.argv[3]) {
	throw new Error("usage: package_web_game.mjs <input-dir> <output-dir> [entry]");
}
if (!fs.statSync(inputDir, { throwIfNoEntry: false })?.isDirectory()) {
	throw new Error(`game input directory does not exist: ${inputDir}`);
}

function validatePath(relativePath) {
	if (!relativePath || relativePath.includes("\\") || relativePath.startsWith("/") || /[\0-\x1f]/.test(relativePath)) {
		throw new Error(`unsafe game path: ${JSON.stringify(relativePath)}`);
	}
	const parts = relativePath.split("/");
	if (parts.some((part) => !part || part === "." || part === "..")) {
		throw new Error(`unsafe game path: ${JSON.stringify(relativePath)}`);
	}
	return relativePath;
}

function collectFiles(directory, prefix = "") {
	const files = [];
	for (const item of fs.readdirSync(directory, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
		if (item.name.startsWith(".")) continue;
		const relativePath = validatePath(prefix ? `${prefix}/${item.name}` : item.name);
		const sourcePath = path.join(directory, item.name);
		if (item.isSymbolicLink()) throw new Error(`symbolic links are not supported: ${relativePath}`);
		if (item.isDirectory()) files.push(...collectFiles(sourcePath, relativePath));
		else if (item.isFile()) files.push({ path: relativePath, sourcePath });
	}
	return files;
}

const files = collectFiles(inputDir);
if (files.length === 0 || files.length > maxFiles) throw new Error(`invalid game file count: ${files.length}`);
if (!files.some((file) => file.path === entry)) throw new Error(`game entry is missing: ${entry}`);

fs.mkdirSync(path.join(outputDir, "assets"), { recursive: true });
let totalSize = 0;
const manifestFiles = files.map((file) => {
	const data = fs.readFileSync(file.sourcePath);
	if (data.byteLength > maxFileSize) throw new Error(`game file is too large: ${file.path}`);
	totalSize += data.byteLength;
	if (totalSize > maxTotalSize) throw new Error("game files exceed the total size limit");
	const sha256 = crypto.createHash("sha256").update(data).digest("hex");
	const extension = path.posix.extname(file.path);
	const basename = extension ? file.path.slice(0, -extension.length) : file.path;
	const outputPath = `assets/${basename}.${sha256.slice(0, 12)}${extension}`;
	const destination = path.join(outputDir, ...outputPath.split("/"));
	fs.mkdirSync(path.dirname(destination), { recursive: true });
	fs.writeFileSync(destination, data);
	return {
		path: file.path,
		url: outputPath,
		size: data.byteLength,
		sha256,
		startup: file.path === entry
	};
});

const manifest = {
	format: "dora-web-game",
	version: 1,
	engineVersion: "1.9.2",
	profile: "web-player-minimal",
	entry,
	files: manifestFiles
};
const manifestPath = path.join(outputDir, "dora-web-manifest.json");
const temporaryPath = `${manifestPath}.tmp`;
fs.writeFileSync(temporaryPath, `${JSON.stringify(manifest, null, 2)}\n`);
fs.renameSync(temporaryPath, manifestPath);
console.log(`[INFO] Packaged ${files.length} game files (${totalSize} B): ${manifestPath}`);
