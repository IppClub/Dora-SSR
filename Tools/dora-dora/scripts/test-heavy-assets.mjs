import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { basename, join, resolve } from "node:path";

const buildDir = resolve(process.cwd(), "build");
const indexHtml = readFileSync(join(buildDir, "index.html"), "utf8");
const manifest = JSON.parse(
	readFileSync(join(buildDir, "heavy-assets.json"), "utf8"),
);

const expectedAssets = [
	manifest.typescript,
	manifest.editorWorker,
	manifest.typescriptWorker,
];

const fixedPaths = [
	"/typescript.js",
	"/monacoeditorwork/editor.worker.bundle.js",
	"/monacoeditorwork/ts.worker.bundle.js",
];

function collectText(directory, result = []) {
	for (const entry of readdirSync(directory, { withFileTypes: true })) {
		const filePath = join(directory, entry.name);
		if (entry.isDirectory()) {
			collectText(filePath, result);
		} else if (entry.isFile() && /\.(html|js)$/.test(entry.name)) {
			result.push(readFileSync(filePath, "utf8"));
		}
	}
	return result;
}

const allText = collectText(buildDir).join("\n");
for (const fixedPath of fixedPaths) {
	if (allText.includes(fixedPath)) {
		throw new Error(`Found unversioned heavy asset reference: ${fixedPath}`);
	}
}

for (const assetUrl of expectedAssets) {
	if (typeof assetUrl !== "string") {
		throw new Error("Heavy asset manifest contains a non-string URL.");
	}
	const match = assetUrl.match(/-([a-f0-9]{12})\.js$/);
	if (match === null) {
		throw new Error(`Heavy asset URL is not versioned: ${assetUrl}`);
	}
	const relativePath = assetUrl.slice(1);
	const filePath = join(buildDir, relativePath);
	if (!existsSync(filePath)) {
		throw new Error(`Versioned heavy asset does not exist: ${filePath}`);
	}
	const actualHash = createHash("sha256")
		.update(readFileSync(filePath))
		.digest("hex")
		.slice(0, 12);
	if (actualHash !== match[1]) {
		throw new Error(
			`Hash mismatch for ${basename(filePath)}: expected ${match[1]}, got ${actualHash}`,
		);
	}
}

if (
	![manifest.editorWorker, manifest.typescriptWorker]
		.every((assetUrl) => indexHtml.includes(assetUrl))
) {
	throw new Error("index.html does not reference both versioned Monaco workers");
}

if (!allText.includes("/heavy-assets.json")) {
	throw new Error("TypeScript loaders do not reference the heavy asset manifest.");
}

console.log("Versioned heavy asset references and content hashes verified.");
