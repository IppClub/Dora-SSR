import { App, Content, Path, json } from "Dora";
import type { FeedEntry } from "Dev/Mobile/FeedModel";

const manifestName = "dora-package.json";
const maxPackageBytes = 256 * 1024 * 1024;
const maxUnpackedBytes = 512 * 1024 * 1024;
const runtimeEntries = ["init.lua", "init.yue", "init.tl", "init.xml", "init.wasm"];

export interface PackagePreview {
	stage: string;
	root: string;
	title: string;
	author?: string;
	bannerFile?: string;
	bytes: number;
}

export function packageFileAllowed(file: string): boolean {
	const name = string.gsub(file, "\\", "/")[0];
	if (name.startsWith("/") || name.indexOf(":") >= 0) return false;
	const parts = name.split("/");
	if (parts.some(part => part === ".." || part === "." || part === "")) return false;
	if (name === ".dora/repo.json" || name === ".dora/banner.jpg" || name === ".dora/banner.png") return true;
	return !parts.some(part => part.startsWith(".") || part === "node_modules" || part === "__MACOSX"
		|| part.toLowerCase() === "credentials.json" || part.toLowerCase() === "config.db")
		&& !name.toLowerCase().endsWith(".log");
}

function fail(zh: string, en: string): never {
	error(App.locale.toLowerCase().startsWith("zh") ? zh : en);
}

function cleanName(value: string) {
	const cleaned = string.gsub(value, '[\\/:*?"<>|%c]', "_")[0].trim();
	const name = string.gsub(cleaned, "^%.+", "")[0];
	const end = utf8.offset(name, 61);
	return name === "" ? "Game" : end ? string.sub(name, 1, end - 1) : name;
}

function newStage() {
	const cache = Path(Content.writablePath, ".share");
	// Retain exported files while system share targets may still be reading them.
	for (const dir of Content.exist(cache) ? Content.getDirs(cache) : []) {
		const [stamp] = string.match(dir, "^(%d+)%-%d+$");
		if (stamp !== undefined && (tonumber(stamp) ?? os.time()) < os.time() - 7 * 86400) Content.remove(Path(cache, dir));
	}
	const path = Path(Content.writablePath, ".share", `${os.time()}-${App.rand}`);
	if (!Content.mkdir(path)) fail("无法创建临时目录", "Could not create temporary folder");
	return path;
}

function encodeObject(value: object): string {
	const [encoded] = json.encode(value);
	if (encoded === undefined) fail("无法编码作品信息", "Could not encode game metadata");
	return encoded;
}

function readObject(path: string): Record<string, unknown> | undefined {
	if (!Content.exist(path)) return undefined;
	const [size] = Content.getAttr(path);
	if (size === undefined || size > 64 * 1024) fail("作品信息过大", "Package metadata is too large");
	const [value] = json.decode(Content.load(path));
	if (type(value) !== "table") fail("作品信息格式不正确", "Invalid package metadata");
	return value as Record<string, unknown>;
}

function runnable(root: string) {
	return runtimeEntries.some(file => Content.exist(Path(root, file)) && !Content.isdir(Path(root, file)));
}

export function discardPackage(preview: PackagePreview) {
	Content.remove(preview.stage);
}

/** Call in a Dora coroutine. This inspects data only, never executes imported code. */
export function inspectPackage(path: string): PackagePreview {
	const [bytes] = Content.getAttr(path);
	if (bytes === undefined || bytes > maxPackageBytes || bytes === 0 || Content.isdir(path)) {
		fail("无法读取作品包，文件应小于 256 MB", "Cannot read package; maximum size is 256 MB");
	}
	const stage = newStage();
	try {
		const unpacked = Path(stage, "content");
		if (!Content.unzipAsync(path, unpacked, packageFileAllowed, maxUnpackedBytes, 10000)) fail("作品包损坏、过大或含有无效路径", "Package is damaged, too large, or contains invalid paths");
		let root = unpacked;
		if (!runnable(root)) {
			const dirs = Content.getDirs(root).filter(dir => !dir.startsWith("."));
			if (dirs.length === 1 && runnable(Path(root, dirs[0]))) root = Path(root, dirs[0]);
		}
		if (!runnable(root)) fail("未找到可运行入口 init，请先在 Dora 中构建作品", "No runnable init entry; build the project in Dora first");
		let total = 0;
		for (const file of Content.getAllFiles(root)) {
			const [size] = Content.getAttr(Path(root, file));
			total += size ?? 0;
		}
		if (total > maxUnpackedBytes) fail("解包后的作品不能超过 512 MB", "Unpacked game exceeds 512 MB");
		const manifest = readObject(Path(root, manifestName));
		if (manifest && (manifest.format !== "dora-game" || manifest.version !== 1)) fail("不支持此作品包版本，请更新 Dora", "Unsupported package version; update Dora");
		const repo = readObject(Path(root, ".dora", "repo.json"));
		if (typeof manifest?.engineVersion === "string") {
			const required = manifest.engineVersion.split(".").map(part => tonumber(part) ?? 0);
			const current = App.version.split(".").map(part => tonumber(part) ?? 0);
			for (let i = 0; i < math.max(required.length, current.length); i++) {
				if ((required[i] ?? 0) > (current[i] ?? 0)) fail("作品由更新版本的 Dora 导出，请先更新引擎", "This package was exported by a newer Dora; update the engine first");
				if ((required[i] ?? 0) < (current[i] ?? 0)) break;
			}
		}
		const title = cleanName(typeof manifest?.title === "string" ? manifest.title : root !== unpacked ? Path.getFilename(root) : Path.getName(path));
		const author = typeof manifest?.author === "string" ? manifest.author.substring(0, 80) : undefined;
		// Normalize the fields consumed by Entry.scanDir; arbitrary metadata must not break the catalog.
		if (repo) {
			const titleInfo = (type(repo.title) === "table" ? repo.title : {}) as Record<string, unknown>;
			const description = (type(repo.description) === "table" ? repo.description : {}) as Record<string, unknown>;
			repo.title = { zh: typeof titleInfo.zh === "string" ? titleInfo.zh : title, en: typeof titleInfo.en === "string" ? titleInfo.en : title };
			repo.description = { zh: typeof description.zh === "string" ? description.zh : "", en: typeof description.en === "string" ? description.en : "" };
			repo.categories = []; // Imported packages are local games, not engine tools.
			if (!Content.save(Path(root, ".dora", "repo.json"), encodeObject(repo))) fail("无法保存作品信息", "Could not save game metadata");
		}
		const bannerFile = [".dora/banner.jpg", ".dora/banner.png", "Image/banner.jpg", "Image/banner.png"]
			.map(file => Path(root, file)).find(file => Content.exist(file));
		return { stage, root, title, author, bannerFile, bytes };
	} catch (e) {
		Content.remove(stage);
		throw e;
	}
}

export function installPackage(preview: PackagePreview): FeedEntry {
	const existing = [...Content.getDirs(Content.writablePath), ...Content.getFiles(Content.writablePath)].map(name => name.toLowerCase());
	let name = cleanName(preview.title);
	let suffix = 2;
	while (existing.includes(name.toLowerCase()) || Content.exist(Path(Content.writablePath, name))) name = `${cleanName(preview.title)} (${suffix++})`;
	const target = Path(Content.writablePath, name);
	const banner = preview.bannerFile ? Path.getRelative(preview.bannerFile, preview.root) : undefined;
	if (!Content.move(preview.root, target)) fail("无法安装作品，请检查剩余空间后重试", "Could not install game; check available space and retry");
	Content.remove(preview.stage);
	return { id: name, title: preview.title, description: "", kind: "local", workDir: target,
		fileName: Path(target, "init"), bannerFile: banner ? Path(target, banner) : undefined };
}

/** Snapshot source and assets before zipping so subsequent edits cannot alter a shared package. */
export function exportPackage(entry: Pick<FeedEntry, "title" | "workDir" | "fileName">): { path: string; bytes: number } {
	const root = entry.workDir;
	if (!root || !runnable(root)) fail("请先构建作品，确认可以试玩后再分享", "Build the game and check that it runs before sharing");
	const stage = newStage();
	try {
		const snapshot = Path(stage, "snapshot");
		if (!Content.mkdir(snapshot)) fail("无法创建作品快照", "Could not create game snapshot");
		let total = 0;
		const files = Content.getAllFiles(root).filter(file => packageFileAllowed(file));
		if (files.length > 10000) fail("作品文件数量过多", "Too many game files");
		for (const file of files) {
			const [size] = Content.getAttr(Path(root, file));
			total += size ?? 0;
			if (total > maxUnpackedBytes) fail("作品不能超过 512 MB", "Game exceeds 512 MB");
			const target = Path(snapshot, file);
			Content.mkdir(Path.getPath(target));
			if (!Content.copyAsync(Path(root, file), target)) fail("复制作品文件失败", "Could not copy game files");
		}
		const previous = readObject(Path(snapshot, manifestName));
		const manifest = { ...(previous ?? {}), format: "dora-game", version: 1, title: entry.title, engineVersion: App.version, entry: "init" };
		if (!Content.save(Path(snapshot, manifestName), encodeObject(manifest))) fail("无法保存作品信息", "Could not save game metadata");
		const path = Path(stage, `${cleanName(entry.title)}.zip`);
		if (!Content.zipAsync(snapshot, path)) fail("作品打包失败", "Could not package game");
		Content.remove(snapshot);
		const [bytes] = Content.getAttr(path);
		if (bytes === undefined || bytes > maxPackageBytes) fail("作品包不能超过 256 MB", "Package exceeds 256 MB");
		return { path, bytes };
	} catch (e) {
		Content.remove(stage);
		throw e;
	}
}
