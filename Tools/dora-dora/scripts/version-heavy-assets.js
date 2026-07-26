const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const buildDir = path.resolve(process.cwd(), "build");

function contentHash(filePath) {
	return crypto
		.createHash("sha256")
		.update(fs.readFileSync(filePath))
		.digest("hex")
		.slice(0, 12);
}

function versionFile(relativePath) {
	const sourcePath = path.join(buildDir, relativePath);
	if (!fs.existsSync(sourcePath)) {
		throw new Error(`Missing heavy asset: ${sourcePath}`);
	}
	const parsed = path.parse(relativePath);
	const versionedRelativePath = path.join(
		parsed.dir,
		`${parsed.name}-${contentHash(sourcePath)}${parsed.ext}`,
	);
	fs.renameSync(sourcePath, path.join(buildDir, versionedRelativePath));
	return {
		originalUrl: `/${relativePath.replaceAll(path.sep, "/")}`,
		versionedUrl: `/${versionedRelativePath.replaceAll(path.sep, "/")}`,
	};
}

const replacements = [
	versionFile("typescript.js"),
	versionFile(path.join("monacoeditorwork", "editor.worker.bundle.js")),
	versionFile(path.join("monacoeditorwork", "ts.worker.bundle.js")),
];

const [typescriptAsset, editorWorkerAsset, typescriptWorkerAsset] = replacements;
const manifest = {
	typescript: typescriptAsset.versionedUrl,
	editorWorker: editorWorkerAsset.versionedUrl,
	typescriptWorker: typescriptWorkerAsset.versionedUrl,
};
fs.writeFileSync(
	path.join(buildDir, "heavy-assets.json"),
	`${JSON.stringify(manifest, null, 2)}\n`,
	"utf8",
);

function collectHtmlFiles(directory, result = []) {
	for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
		const filePath = path.join(directory, entry.name);
		if (entry.isDirectory()) {
			collectHtmlFiles(filePath, result);
		} else if (entry.isFile() && entry.name.endsWith(".html")) {
			result.push(filePath);
		}
	}
	return result;
}

for (const htmlPath of collectHtmlFiles(buildDir)) {
	let html = fs.readFileSync(htmlPath, "utf8");
	for (const replacement of [editorWorkerAsset, typescriptWorkerAsset]) {
		html = html.replaceAll(
			replacement.originalUrl,
			replacement.versionedUrl,
		);
	}
	fs.writeFileSync(htmlPath, html, "utf8");
}

for (const replacement of replacements) {
	console.log(`Versioned ${replacement.originalUrl} -> ${replacement.versionedUrl}`);
}
