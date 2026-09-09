import assert from "node:assert/strict";
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

const playerDir = path.resolve(process.argv[2] || "");
const deploymentDir = path.resolve(process.argv[3] || "");
const releaseId = process.argv[4] || "";
if (!process.argv[2] || !process.argv[3] || !releaseId) {
	throw new Error("usage: package_web_preview.mjs <player-dir> <deployment-dir> <release-id>");
}
assert.match(releaseId, /^(?!\.{1,2}$)[A-Za-z0-9][A-Za-z0-9._-]{0,63}$/, "release ID must be a safe path segment");
assert.ok(fs.statSync(playerDir, {throwIfNoEntry: false})?.isDirectory(), `Player directory does not exist: ${playerDir}`);

for (const required of ["index.html", "dora-player-runtime.js", "dora-player-runtime.wasm", "dora-player-runtime.data", "dora-web-manifest.json", "dora-web-features.json"]) {
	assert.ok(fs.statSync(path.join(playerDir, required), {throwIfNoEntry: false})?.isFile(), `Player artifact is missing: ${required}`);
}

function collect(directory, prefix = "") {
	const files = [];
	for (const entry of fs.readdirSync(directory, {withFileTypes: true}).sort((a, b) => a.name.localeCompare(b.name))) {
		const relative = prefix ? `${prefix}/${entry.name}` : entry.name;
		const source = path.join(directory, entry.name);
		if (entry.isSymbolicLink()) throw new Error(`symbolic links are not allowed in a Web release: ${relative}`);
		if (entry.isDirectory()) files.push(...collect(source, relative));
		else if (entry.isFile()) files.push({relative, source});
	}
	return files;
}

function writeAtomic(file, source) {
	const temporary = `${file}.tmp-${process.pid}`;
	fs.writeFileSync(temporary, source);
	fs.renameSync(temporary, file);
}

function pointerHtml() {
	return "<!doctype html>\n<meta charset=\"utf-8\">\n<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">\n<title>Dora SSR Web Player</title>\n<p>Loading Dora SSR Web Player…</p>\n<script type=\"module\" src=\"dora-web-entry.js\"></script>\n";
}

function entryScript() {
	return `const response = await fetch("dora-web-current.json", {cache: "no-store"});
if (!response.ok) throw new Error(\`Dora Web release pointer failed (\${response.status})\`);
const pointer = await response.json();
if (pointer.schemaVersion !== 1 || typeof pointer.entry !== "string" || !/^releases\\/[A-Za-z0-9][A-Za-z0-9._-]{0,63}\\/index\\.html$/.test(pointer.entry)) throw new Error("Invalid Dora Web release pointer");
const target = new URL(pointer.entry, location.href);
target.search = location.search;
target.hash = location.hash;
location.replace(target.href);
`;
}

function contentSecurityPolicy(html) {
	const hashes = (tag) => [...html.matchAll(new RegExp(`<${tag}(?:\\s[^>]*)?>([\\s\\S]*?)<\\/${tag}>`, "gi"))]
		.map((match) => match[1])
		.filter((source) => source.length > 0)
		.map((source) => `'sha256-${crypto.createHash("sha256").update(source).digest("base64")}'`);
	const scripts = hashes("script");
	const styles = hashes("style");
	return [
		"default-src 'none'",
		`script-src 'self' 'wasm-unsafe-eval' ${scripts.join(" ")}`.trim(),
		`style-src ${styles.join(" ")}`.trim(),
		"connect-src 'self'",
		"img-src 'self' data: blob:",
		"media-src 'self' blob:",
		"font-src 'self' data:",
		"worker-src 'self' blob:",
		"base-uri 'none'",
		"form-action 'none'",
		"frame-ancestors 'none'",
		"object-src 'none'",
	].join("; ");
}

function deploymentReadme(language) {
	if (language === "zh-CN") return `# Dora SSR Web Player 开发预览

当前版本和上一版本由 \`dora-web-current.json\` 记录，每个不可变版本的身份与哈希位于对应的 \`dora-web-release.json\`。

把本目录部署到独立的 HTTPS 静态 origin。先完整上传目标 \`releases/<release-id>/\`，验证 release manifest 中的大小与 SHA-256，再最后原子替换根目录的 \`dora-web-current.json\`。按照 \`dora-web-deployment.json\` 配置缓存、MIME 和 CSP；不得覆盖任何已存在的版本目录。回滚时用 \`rollback_web_preview.mjs\` 交换 current/previous 指针，再只上传新的 pointer。

这是 minimal profile 开发预览，不承诺 3D、Jolt 3D、视频、LoveNode、Web Workspace、pthread、动态链接、Rust/Wasm runtime 或浏览器内 YueScript/Teal 编译。桌面和移动浏览器支持范围以项目兼容矩阵中的真实版本证据为准。请在独立 origin 运行不可信游戏，并确认产物不包含凭据或私有配置。
`;
	return `# Dora SSR Web Player development preview

The current and previous versions are recorded in \`dora-web-current.json\`; each immutable version records its identity and hashes in its own \`dora-web-release.json\`.

Deploy this directory on a dedicated HTTPS static origin. Upload and verify the target \`releases/<release-id>/\` against its release manifest, then atomically replace the root \`dora-web-current.json\` last. Apply the cache, MIME, and CSP contract in \`dora-web-deployment.json\`; never overwrite an existing release directory. To roll back, use \`rollback_web_preview.mjs\` to exchange the current/previous pointer and upload only the new pointer.

This is a minimal-profile development preview. It does not promise 3D, Jolt 3D, video, LoveNode, Web Workspace, pthreads, dynamic linking, the Rust/Wasm runtime, or in-browser YueScript/Teal compilation. Browser support is limited to versions with recorded evidence in the project compatibility matrix. Run untrusted games on a dedicated origin and verify that no credentials or private configuration enter the artifact.
`;
}

fs.mkdirSync(path.join(deploymentDir, "releases"), {recursive: true});
const target = path.join(deploymentDir, "releases", releaseId);
assert.equal(fs.existsSync(target), false, `release already exists and is immutable: ${releaseId}`);
const stage = path.join(deploymentDir, "releases", `.${releaseId}.stage-${process.pid}`);
fs.rmSync(stage, {recursive: true, force: true});
fs.mkdirSync(stage, {recursive: true});

try {
	const files = collect(playerDir);
	const records = [];
	for (const file of files) {
		const destination = path.join(stage, ...file.relative.split("/"));
		fs.mkdirSync(path.dirname(destination), {recursive: true});
		fs.copyFileSync(file.source, destination, fs.constants.COPYFILE_EXCL);
		const bytes = fs.readFileSync(destination);
		records.push({path: file.relative, size: bytes.length, sha256: crypto.createHash("sha256").update(bytes).digest("hex")});
	}
	const playerHtml = fs.readFileSync(path.join(stage, "index.html"), "utf8");
	writeAtomic(path.join(stage, "dora-web-release.json"), `${JSON.stringify({schemaVersion: 1, releaseId, contentSecurityPolicy: contentSecurityPolicy(playerHtml), files: records}, null, 2)}\n`);
	fs.renameSync(stage, target);
} catch (error) {
	fs.rmSync(stage, {recursive: true, force: true});
	throw error;
}

const pointerPath = path.join(deploymentDir, "dora-web-current.json");
let previous = null;
if (fs.statSync(pointerPath, {throwIfNoEntry: false})?.isFile()) {
	const current = JSON.parse(fs.readFileSync(pointerPath, "utf8"));
	assert.equal(current.schemaVersion, 1, "unsupported current release pointer schema");
	previous = current.current;
}
const entry = `releases/${releaseId}/index.html`;
writeAtomic(pointerPath, `${JSON.stringify({schemaVersion: 1, current: releaseId, previous, entry}, null, 2)}\n`);
writeAtomic(path.join(deploymentDir, "index.html"), pointerHtml());
writeAtomic(path.join(deploymentDir, "dora-web-entry.js"), entryScript());
writeAtomic(path.join(deploymentDir, "README.md"), deploymentReadme("en"));
writeAtomic(path.join(deploymentDir, "README.zh-CN.md"), deploymentReadme("zh-CN"));
writeAtomic(path.join(deploymentDir, "dora-web-deployment.json"), `${JSON.stringify({
	schemaVersion: 1,
	cache: {
		"/index.html": "no-cache",
		"/dora-web-entry.js": "no-cache",
		"/dora-web-current.json": "no-cache",
		"/README.md": "no-cache",
		"/README.zh-CN.md": "no-cache",
		"/releases/*": "public, max-age=31536000, immutable"
	},
	mime: {".wasm": "application/wasm", ".js": "text/javascript; charset=utf-8", ".json": "application/json; charset=utf-8"},
	security: {
		rootContentSecurityPolicy: "default-src 'none'; script-src 'self'; connect-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'; object-src 'none'",
		releaseContentSecurityPolicy: "Read contentSecurityPolicy from each immutable releases/<id>/dora-web-release.json"
	}
}, null, 2)}\n`);
console.log(`[INFO] Dora Web preview release ${releaseId}: ${target}`);
