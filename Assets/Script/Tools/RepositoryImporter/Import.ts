// @preview-file off
import { Content, Path } from "Dora";
import { runGit, quoteGitArgument, GitOperationStatus } from "Tools/ResourceDownloader/Git";

export function normalizeRepository(input: string): string | undefined {
	let [url] = string.gsub(input, "^%s*(.-)%s*$", "%1");
	[url] = string.gsub(url, "/$", "");
	const [host, owner, repo] = string.match(url, "^https://([%w%.%-]+)/([%w_.%-]+)/([%w_.%-]+)$");
	if (host === undefined || owner === undefined || repo === undefined || owner === "." || owner === ".." || repo === "." || repo === "..") return;
	if (host !== "github.com" && host !== "atomgit.com" && host !== "gitee.com" && host !== "gitcode.com") return;
	[url] = string.gsub(url, "%.git$", "");
	if (url.endsWith("/")) return;
	return url;
}

export function findEntry(root: string): string | undefined {
	const priority: Record<string, number> = {ts: 1, tsx: 2, yue: 3, tl: 4, lua: 5, xml: 6, wasm: 7};
	let best: string | undefined, bestDepth = math.huge, bestPriority = math.huge;
	for (const item of Content.getAllFiles(root)) {
		const [file] = string.gsub(item, "\\", "/");
		if (file.startsWith(".") || string.find(file, "/%.")[0] !== undefined || string.find(`/${file.toLowerCase()}`, "/node_modules/", 1, true)[0] !== undefined) continue;
		const [ext] = string.match(file.toLowerCase(), "init%.(%w+)$");
		if (ext === undefined || Path.getName(file).toLowerCase() !== "init" || priority[ext] === undefined) continue;
		const [, depth] = string.gsub(file, "/", "");
		if (depth < bestDepth || (depth === bestDepth && (priority[ext] < bestPriority || (priority[ext] === bestPriority && (best === undefined || file < best))))) {
			best = file; bestDepth = depth; bestPriority = priority[ext];
		}
	}
	return best === undefined ? undefined : Path(root, best);
}

export interface ImportedProject {root: string; entry: string; existing: boolean;}
export interface ImportOperation {
	canceled: boolean;
	phase: "clone" | "verify";
	status?: GitOperationStatus;
}

// The async continuation owns its temporary directory until Git acknowledges
// cancellation. Scene cleanup only marks this operation canceled; it must never
// remove a directory while the worker is still writing into it.
export async function importRepository(url: string, operation: ImportOperation): Promise<ImportedProject> {
	const repository = normalizeRepository(url);
	if (!repository) throw new Error("Use a public HTTPS repository on GitHub, AtomGit, Gitee or GitCode.");
	const [name] = string.gsub(repository.substring(8), "/", "-");
	const root = Path(Content.writablePath, name);
	const marker = Path(root, ".git", "dora-import-repository");
	if (Content.exist(root)) {
		if (!Content.isdir(root) || Content.load(marker) !== repository) throw new Error("The destination already exists and belongs to another project.");
		const entry = findEntry(root);
		if (!entry) throw new Error("The local project has no init entry.");
		return {root, entry, existing: true};
	}
	let temporary: string;
	do { temporary = Path(Content.writablePath, `.import-${os.time()}-${math.random(1, 2147483647)}`); } while (Content.exist(temporary));
	try {
		operation.phase = "clone";
		const clone = await runGit(Content.writablePath, `clone --depth 1 --no-lfs ${quoteGitArgument(repository)} ${quoteGitArgument(Path.getFilename(temporary))}`, {
			timeout: 600, isCanceled: () => operation.canceled, onStatus: status => { operation.status = status; },
		});
		if (operation.canceled) throw new Error("Canceled");
		if (!clone.success) throw new Error(clone.message ?? "Clone failed");
		operation.phase = "verify";
		const verified = await runGit(temporary, "verify-resource", {isCanceled: () => operation.canceled});
		if (operation.canceled) throw new Error("Canceled");
		if (!verified.success) throw new Error(verified.message ?? "Project verification failed");
		const entry = findEntry(temporary);
		if (!entry) throw new Error("The repository has no Dora init entry.");
		if (!Content.save(Path(temporary, ".git", "dora-import-repository"), repository)) throw new Error("Could not record the repository.");
		// Both paths are siblings on the workspace filesystem. Never merge into an
		// existing destination, including one created while the clone was running.
		if (Content.exist(root) || !Content.move(temporary, root)) throw new Error("Could not move the project into the workspace.");
		return {root, entry: Path(root, Path.getRelative(entry, temporary)), existing: false};
	} finally {
		if (Content.exist(temporary)) Content.remove(temporary);
	}
}
