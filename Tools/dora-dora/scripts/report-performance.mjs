import { createReadStream, existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { basename, dirname, extname, join, relative, resolve } from "node:path";
import { createGzip } from "node:zlib";

const argumentsList = process.argv.slice(2).filter((argument) => argument !== "--");
const buildDirectoryArgument = argumentsList.find((argument) => !argument.startsWith("--"));
const shellBudgetArgument = argumentsList.find((argument) => argument.startsWith("--shell-budget-kib="));
const shellBudgetBytes = shellBudgetArgument
	? Number(shellBudgetArgument.slice("--shell-budget-kib=".length)) * 1024
	: null;
const buildDir = resolve(process.cwd(), buildDirectoryArgument ?? "build");

function walk(directory) {
	return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
		const filePath = join(directory, entry.name);
		return entry.isDirectory() ? walk(filePath) : [filePath];
	});
}

function gzipSize(filePath) {
	return new Promise((resolveSize, reject) => {
		let size = 0;
		const gzip = createGzip({ level: 9 });
		gzip.on("data", (chunk) => {
			size += chunk.length;
		});
		gzip.on("end", () => resolveSize(size));
		gzip.on("error", reject);
		createReadStream(filePath).on("error", reject).pipe(gzip);
	});
}

if (!existsSync(buildDir)) {
	console.error(`Build directory not found: ${buildDir}`);
	process.exit(1);
}

const assetFiles = walk(buildDir)
	.filter((filePath) => [".js", ".css"].includes(extname(filePath)))
	.map((filePath) => ({
		filePath,
		path: relative(buildDir, filePath),
		rawBytes: statSync(filePath).size,
	}));

const files = await Promise.all(assetFiles.map(async (file) => ({
	...file,
	gzipBytes: await gzipSize(file.filePath),
})));

files.sort((left, right) => right.gzipBytes - left.gzipBytes);
const totals = files.reduce((result, file) => ({
	rawBytes: result.rawBytes + file.rawBytes,
	gzipBytes: result.gzipBytes + file.gzipBytes,
}), { rawBytes: 0, gzipBytes: 0 });

const fileByPath = new Map(files.map((file) => [file.path.replaceAll("\\", "/"), file]));
const indexPath = join(buildDir, "index.html");
const indexHtml = existsSync(indexPath) ? readFileSync(indexPath, "utf8") : "";
const htmlJsRoots = [
	...indexHtml.matchAll(/<script[^>]+type=["']module["'][^>]+src=["']([^"']+)["']/g),
	...indexHtml.matchAll(/<link[^>]+rel=["']modulepreload["'][^>]+href=["']([^"']+)["']/g),
].map(match => match[1].replace(/^\/+/, ""));
const appRoots = files
	.filter(file => /^assets\/App-[^/]+\.js$/.test(file.path.replaceAll("\\", "/")))
	.map(file => file.path.replaceAll("\\", "/"));
const shellQueue = [...new Set([...htmlJsRoots, ...appRoots])];
const shellPaths = new Set();
while (shellQueue.length > 0) {
	const assetPath = shellQueue.shift();
	if (!assetPath || shellPaths.has(assetPath) || !fileByPath.has(assetPath)) continue;
	shellPaths.add(assetPath);
	const source = readFileSync(join(buildDir, assetPath), "utf8");
	for (const match of source.matchAll(/(?:\bfrom\s*|\bimport\s*)["'](\.\/[^"']+)["']/g)) {
		const dependencyPath = join(dirname(assetPath), match[1]).replaceAll("\\", "/");
		if (!shellPaths.has(dependencyPath)) shellQueue.push(dependencyPath);
	}
}
const isMonacoAsset = (assetPath) =>
	/(^|\/)monaco(?:-|\/)|monacoeditorwork|(?:^|\/)(?:ts|editor)\.worker-/.test(assetPath);
const hydratedShellFiles = [...shellPaths]
	.filter(assetPath => !isMonacoAsset(assetPath))
	.map(assetPath => fileByPath.get(assetPath))
	.filter(Boolean);
const hydratedShellJs = hydratedShellFiles.reduce((result, file) => ({
	fileCount: result.fileCount + 1,
	rawBytes: result.rawBytes + file.rawBytes,
	gzipBytes: result.gzipBytes + file.gzipBytes,
}), { fileCount: 0, rawBytes: 0, gzipBytes: 0 });

const report = {
	generatedAt: new Date().toISOString(),
	buildDirectory: buildDir,
	fileCount: files.length,
	totals,
	hydratedShellJs: {
		...hydratedShellJs,
		budgetBytes: shellBudgetBytes,
		withinBudget: shellBudgetBytes === null || hydratedShellJs.gzipBytes <= shellBudgetBytes,
		excludes: "Monaco main bundle and language workers",
		files: hydratedShellFiles.map(file => file.path),
	},
	largestFiles: files.slice(0, 20).map(({ path, rawBytes, gzipBytes }) => ({
		path,
		name: basename(path),
		rawBytes,
		gzipBytes,
	})),
};

if (argumentsList.includes("--json")) {
	console.log(JSON.stringify(report, null, 2));
} else {
	console.log(`Build: ${report.buildDirectory}`);
	console.log(`JS/CSS files: ${report.fileCount}`);
	console.log(`Total: ${(totals.rawBytes / 1024).toFixed(1)} KiB raw, ${(totals.gzipBytes / 1024).toFixed(1)} KiB gzip`);
	console.log(`Hydrated IDE shell JS (excluding Monaco): ${hydratedShellJs.fileCount} files, ${(hydratedShellJs.gzipBytes / 1024).toFixed(1)} KiB gzip`);
	console.table(report.largestFiles.map((file) => ({
		file: file.path,
		"raw KiB": (file.rawBytes / 1024).toFixed(1),
		"gzip KiB": (file.gzipBytes / 1024).toFixed(1),
	})));
}

if (shellBudgetBytes !== null && hydratedShellJs.gzipBytes > shellBudgetBytes) {
	console.error(
		`Hydrated IDE shell exceeds budget: ${(hydratedShellJs.gzipBytes / 1024).toFixed(1)} KiB > ${(shellBudgetBytes / 1024).toFixed(1)} KiB`,
	);
	process.exitCode = 1;
}
