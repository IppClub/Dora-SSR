import {execFileSync} from "node:child_process";
import {createRequire} from "node:module";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {fileURLToPath} from "node:url";

const require = createRequire(import.meta.url);
const rootDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const packageRoot = path.dirname(require.resolve("@zhobo63/imgui-ts/package.json"));
const outputDir = path.join(rootDir, "src", "ActionEditor", "imgui-ts-types");
const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "imgui-ts-types-"));
const tempOutDir = path.join(tempDir, "dist");
const tsconfigPath = path.join(tempDir, "tsconfig.json");

const writeJson = (filename, value) => {
	fs.writeFileSync(filename, `${JSON.stringify(value, null, 2)}\n`);
};

const copyDirectory = (source, target) => {
	fs.mkdirSync(target, {recursive: true});
	for (const entry of fs.readdirSync(source, {withFileTypes: true})) {
		const sourcePath = path.join(source, entry.name);
		const targetPath = path.join(target, entry.name);
		if (entry.isDirectory()) {
			copyDirectory(sourcePath, targetPath);
		} else if (entry.isFile() && entry.name.endsWith(".d.ts")) {
			fs.copyFileSync(sourcePath, targetPath);
		}
	}
};

const patchDeclarationFile = (filename) => {
	let content = fs.readFileSync(filename, "utf8");
	content = content.replace(
		"export type ImScalar<T> = [ T ];",
		"export type ImScalar<T> = T[];",
	);
	content = content
		.replace(/^(\s*)Set\(([^)]*)\): this;$/gm, "$1Set?($2): this;")
		.replace(/^(\s*)Copy\(([^)]*)\): this;$/gm, "$1Copy?($2): this;")
		.replace(/^(\s*)Equals\(([^)]*)\): boolean;$/gm, "$1Equals?($2): boolean;");
	fs.writeFileSync(filename, content);
};

const patchDeclarations = (dir) => {
	for (const entry of fs.readdirSync(dir, {withFileTypes: true})) {
		const filename = path.join(dir, entry.name);
		if (entry.isDirectory()) {
			patchDeclarations(filename);
		} else if (entry.isFile() && entry.name.endsWith(".d.ts")) {
			patchDeclarationFile(filename);
		}
	}
};

writeJson(tsconfigPath, {
	compilerOptions: {
		target: "ES2020",
		module: "ESNext",
		moduleResolution: "bundler",
		declaration: true,
		emitDeclarationOnly: true,
		allowJs: true,
		skipLibCheck: true,
		strict: false,
		isolatedModules: false,
		outDir: tempOutDir,
	},
	include: [path.join(packageRoot, "src", "**", "*.ts")],
});

try {
	execFileSync(process.execPath, [require.resolve("typescript/bin/tsc"), "-p", tsconfigPath, "--pretty", "false"], {
		cwd: rootDir,
		stdio: "inherit",
	});
	fs.rmSync(outputDir, {recursive: true, force: true});
	copyDirectory(tempOutDir, outputDir);
	fs.copyFileSync(path.join(packageRoot, "src", "bind-imgui.d.ts"), path.join(outputDir, "bind-imgui.d.ts"));
	fs.copyFileSync(path.join(packageRoot, "src", "emscripten.d.ts"), path.join(outputDir, "emscripten.d.ts"));
	patchDeclarations(outputDir);
	console.log(`Generated imgui-ts declarations at ${path.relative(rootDir, outputDir)}`);
} finally {
	fs.rmSync(tempDir, {recursive: true, force: true});
}
