// @preview-file off clear
import * as Dora from 'Dora';
import { Content, DB, Path, Director, once, SearchFilesResult, Node, emit, wait, App, HttpServer, HttpClient, Git } from 'Dora';
import { Log, safeJsonDecode, safeJsonEncode } from 'Agent/Utils';
import type { ToolCall } from 'Agent/Utils';

export interface TruncatedEditRecovery {
	target: string;
	receivedText: string;
	reason: string;
}

function recoverJsonStringProperty(text: string, key: string): { value: string; complete: boolean } | undefined {
	const marker = `"${key}"`;
	const markerIndex = text.indexOf(marker);
	if (markerIndex < 0) return undefined;
	const colonIndex = text.indexOf(":", markerIndex + marker.length);
	if (colonIndex < 0) return undefined;
	let quoteIndex = colonIndex + 1;
	while (quoteIndex < text.length) {
		const code = text.charCodeAt(quoteIndex);
		if (code !== 32 && code !== 9 && code !== 10 && code !== 13) break;
		quoteIndex++;
	}
	if (quoteIndex >= text.length || text.charCodeAt(quoteIndex) !== 34) return undefined;
	let escaped = false;
	for (let i = quoteIndex + 1; i < text.length; i++) {
		const code = text.charCodeAt(i);
		if (escaped) {
			escaped = false;
			continue;
		}
		if (code === 92) {
			escaped = true;
			continue;
		}
		if (code === 34) {
			const [decoded] = safeJsonDecode(`{"value":${text.slice(quoteIndex, i + 1)}}`);
			if (decoded && type(decoded) === "table" && typeof (decoded as Record<string, unknown>).value === "string") {
				return { value: (decoded as Record<string, unknown>).value as string, complete: true };
			}
			return undefined;
		}
	}
	const fragment = text.slice(quoteIndex);
	for (let trim = 0; trim <= 6 && trim <= fragment.length - 1; trim++) {
		const [decoded] = safeJsonDecode(`{"value":${fragment.slice(0, fragment.length - trim)}"}`);
		if (decoded && type(decoded) === "table" && typeof (decoded as Record<string, unknown>).value === "string") {
			return { value: (decoded as Record<string, unknown>).value as string, complete: false };
		}
	}
	return undefined;
}

/**
 * Recover only a truncated whole-file overwrite. A truncated replacement with
 * non-empty old_str is unsafe and deliberately returns undefined.
 */
export function planTruncatedEditRecovery(
	toolCalls: ToolCall[] | undefined
): TruncatedEditRecovery | undefined {
	if (!toolCalls || toolCalls.length === 0) return undefined;
	for (let i = toolCalls.length - 1; i >= 0; i--) {
		const fn = toolCalls[i]?.function;
		if (!fn || fn.name !== "edit_file" || typeof fn.arguments !== "string") continue;
		const recovered = recoverJsonStringProperty(fn.arguments, "new_str");
		if (!recovered || recovered.complete || recovered.value.length === 0) continue;
		const target = recoverJsonStringProperty(fn.arguments, "path")
			?? recoverJsonStringProperty(fn.arguments, "target_file");
		const oldStr = recoverJsonStringProperty(fn.arguments, "old_str");
		if (!target || !target.complete || !oldStr || !oldStr.complete || oldStr.value !== "") continue;
		return {
			target: target.value,
			receivedText: recovered.value,
			reason: `The response ended while overwriting ${target.value}. Write the ${recovered.value.length} fully decoded characters directly to that file. This is the complete recoverable prefix; inspect the actual file next and decide whether it already suffices or needs a bounded continuation.`,
		};
	}
	return undefined;
}

export type AgentTaskStatus = "RUNNING" | "WAITING_USER" | "DONE" | "FAILED" | "STOPPED";
export type AgentTaskWorkMode = "code" | "plan";
export type CheckpointStatus = "PREPARED" | "APPLIED" | "REVERTED" | "FAILED";
export type FileOp = "write" | "create" | "delete";

export interface FileChange {
	path: string;
	op: FileOp;
	content?: string;
}

export interface ApplyChangesOptions {
	summary?: string;
	toolName?: string;
}

export type CreateTaskResult = {
	success: true;
	taskId: number;
} | {
	success: false;
	message: string;
};

export type ApplyChangesResult = {
	success: true;
	taskId: number;
	checkpointId: number;
	checkpointSeq: number;
} | {
	success: false;
	message: string;
};

export type RollbackResult = {
	success: true;
	checkpointId: number;
} | {
	success: false;
	message: string;
};

export type TaskRollbackResult = {
	success: true;
	taskId: number;
	checkpointId: number;
	checkpointCount: number;
} | {
	success: false;
	message: string;
};

export interface CheckpointDiffFile {
	path: string;
	op: FileOp;
	beforeExists: boolean;
	afterExists: boolean;
	beforeContent: string;
	afterContent: string;
}

export type CheckpointDiffResult = {
	success: true;
	files: CheckpointDiffFile[];
} | {
	success: false;
	message: string;
};

export type ListFilesResult = {
	success: true;
	files: string[];
	totalEntries?: number;
	truncated?: boolean;
	maxEntries?: number;
} | {
	success: false;
	message: string;
};

export type BuildMessage = {
	success: true;
	file: string;
} | {
	success: false;
	file: string;
	message: string;
};

export type BuildResult = {
	success: true;
	message: string;
	total: number;
	passed: number;
	failed: 0;
	messages: BuildMessage[];
} | {
	success: false;
	message: string;
	total?: number;
	passed?: number;
	failed?: number;
	messages?: BuildMessage[];
};

export type FetchUrlMode = "download";

export type FetchUrlProgress = {
	state: "pending" | "running";
	mode: FetchUrlMode;
	operationId: string;
	target: string;
	tempPath: string;
	progress?: number;
	current?: number;
	total?: number;
	message?: string;
	stage?: string;
	jobId?: number;
	gitState?: string;
	gitKind?: string;
};

export type FetchUrlResult = {
	success: true;
	state: "done";
	mode: FetchUrlMode;
	target: string;
	bytesWritten?: number;
} | {
	success: false;
	state: "failed";
	mode?: FetchUrlMode;
	target?: string;
	message: string;
	interrupted?: boolean;
	cleanupError?: string;
};

export type ExecuteCommandMode = "lua" | "git";

export type ExecuteCommandProgress = {
	state: "pending" | "running";
	mode: ExecuteCommandMode;
	operationId: string;
	progress?: number;
	message?: string;
	stage?: string;
	jobId?: number;
	gitState?: string;
	gitKind?: string;
};

export type ExecuteCommandResult = {
	success: true;
	mode: ExecuteCommandMode;
	output: string;
	cwd?: string;
} | {
	success: false;
	mode?: ExecuteCommandMode;
	output?: string;
	cwd?: string;
	message: string;
	phase?: "compile" | "execute" | "timeout" | "validate";
	interrupted?: boolean;
	cleanupError?: string;
};

interface AgentEntryDescriptor {
	entryName?: string;
	fileName?: string;
}

interface AgentEntryStatus extends AgentEntryDescriptor {
	success: boolean;
	running: boolean;
	workDir?: string;
	projectRoot?: string;
	runKind?: string;
}

interface DevEntryModule {
	allClear(this: void): void;
	stop(this: void): boolean;
	getCurrentEntryStatus(this: void): AgentEntryStatus;
	enterEntryAsync(this: void, entry: {
		entryName: string;
		fileName: string;
		workDir: string;
		projectRoot: string;
		runKind: "agent_test";
	}): LuaMultiReturn<[boolean, string | undefined]>;
}

export type GetLogsResult = {
	success: true;
	logs: string[];
	text?: string;
} | {
	success: false;
	message: string;
};

export type ReadFileResult = {
	success: true;
	content: string;
	totalLines?: number;
	startLine?: number;
	endLine?: number;
	truncated?: boolean;
	size?: number;
} | {
	success: false;
	message: string;
	size?: number;
	isBinary?: boolean;
};

export type SearchFilesToolResult = {
	success: true;
	results: SearchFilesResult[];
	groupedResults?: {
		file: string;
		totalMatches: number;
		matches: SearchFilesResult[];
	}[];
	totalResults?: number;
	truncated?: boolean;
	limit?: number;
	offset?: number;
	nextOffset?: number;
	hasMore?: boolean;
	groupByFile?: boolean;
} | {
	success: false;
	message: string;
};

export type DoraAPIDocLanguage = "zh" | "en";
export type DoraAPIDocSource = "api" | "tutorial";
export type DoraAPIProgrammingLanguage = "ts" | "tsx" | "lua" | "yue" | "teal" | "tl" | "wa";

export interface DoraAPISearchHit {
	file: string;
	line?: number;
	content?: string;
}

export type DoraAPISearchResult = {
	success: true;
	docSource: DoraAPIDocSource;
	docLanguage: DoraAPIDocLanguage;
	programmingLanguage: DoraAPIProgrammingLanguage;
	exts: string[];
	results: DoraAPISearchHit[];
	hint?: string;
	totalResults?: number;
	truncated?: boolean;
	limit?: number;
	fallbackPatterns?: string[];
} | {
	success: false;
	message: string;
};

export type DoraAPIReadDocResult = {
	success: true;
	docLanguage: DoraAPIDocLanguage;
	file: string;
	content: string;
	startLine?: number;
	endLine?: number;
} | {
	success: false;
	message: string;
};

export interface CheckpointItem {
	id: number;
	taskId: number;
	seq: number;
	status: string;
	summary: string;
	toolName: string;
	createdAt: number;
}

export interface TaskChangeSetFile {
	path: string;
	op: FileOp;
	checkpointCount: number;
	checkpointIds: number[];
}

export type TaskChangeSetSummary = {
	success: true;
	taskId: number;
	checkpointCount: number;
	filesChanged: number;
	files: TaskChangeSetFile[];
	latestCheckpointId?: number;
	latestCheckpointSeq?: number;
} | {
	success: false;
	message: string;
};

interface CheckpointEntryRow {
	id: number;
	ord: number;
	path: string;
	op: FileOp;
	beforeExists: boolean;
	beforeContent: string;
	afterExists: boolean;
	afterContent: string;
}

const TABLE_TASK = "AgentTask";
const TABLE_CP = "AgentCheckpoint";
const TABLE_ENTRY = "AgentCheckpointEntry";
const ENGINE_LOG_DOWNLOAD_DIR = ".download";
const ENGINE_LOG_FILE = "dora_full_logs.txt";
const AGENT_DOWNLOAD_TEMP_DIR = "agent";
const now = () => os.time();

function toBool(v: unknown): boolean {
	return v !== 0 && v !== false && v !== undefined;
}

function toStr(v: unknown): string {
	if (v === false || v === undefined) return "";
	return tostring(v);
}

function isValidWorkspacePath(path: string): boolean {
	if (!path || path.length === 0) return false;
	if (Content.isAbsolutePath(path)) return false;
	if (path.includes("..")) return false;
	return true;
}

function isValidWorkDir(workDir: string): boolean {
	if (!workDir || workDir.length === 0) return false;
	if (!Content.isAbsolutePath(workDir)) return false;
	if (!Content.exist(workDir) || !Content.isdir(workDir)) return false;
	return true;
}

function isValidSearchPath(path: string): boolean {
	if (path === "") return true;
	if (Content.isAbsolutePath(path)) return false;
	if (!path || path.length === 0) return false;
	if (path.includes("..")) return false;
	return true;
}

function resolveWorkspaceFilePath(workDir: string, path: string): string | undefined {
	if (!isValidWorkDir(workDir)) return undefined;
	if (!isValidWorkspacePath(path)) return undefined;
	return Path(workDir, path);
}

function resolveWorkspaceSearchPath(workDir: string, path: string): string | undefined {
	if (!isValidWorkDir(workDir)) return undefined;
	if (!isValidSearchPath(path)) return undefined;
	return path === "" ? workDir : Path(workDir, path);
}

function toWorkspaceRelativePath(workDir: string, path: string): string {
	if (!path || path.length === 0) return path;
	if (!Content.isAbsolutePath(path)) return path;
	return Path.getRelative(path, workDir);
}

function toWorkspaceRelativeFileList(workDir: string, files: string[]): string[] {
	return files.map(file => toWorkspaceRelativePath(workDir, file));
}

function toWorkspaceRelativeSearchResults(workDir: string, results: SearchFilesResult[]): SearchFilesResult[] {
	const mapped: SearchFilesResult[] = [];
	for (let i = 0; i < results.length; i++) {
		const row = results[i];
		const clone: SearchFilesResult = { ...row };
		clone.file = toWorkspaceRelativePath(workDir, clone.file);
		mapped.push(clone);
	}
	return mapped;
}

function resolveWorkspaceDirectoryPath(workDir: string, path?: string): { success: true; path: string; relative: string } | { success: false; message: string } {
	const relative = (path ?? "").trim();
	if (relative === "") {
		return { success: true, path: workDir, relative: "." };
	}
	if (!isValidWorkDir(workDir) || !isValidWorkspacePath(relative)) {
		return { success: false, message: "invalid cwd path" };
	}
	const resolved = Path(workDir, relative);
	if (!Content.exist(resolved)) {
		return { success: false, message: "cwd does not exist" };
	}
	if (!Content.isdir(resolved)) {
		return { success: false, message: "cwd is not a directory" };
	}
	return { success: true, path: resolved, relative };
}

function getDoraAPIDocRoot(docLanguage: DoraAPIDocLanguage): string {
	const zhDir = Path(Content.assetPath, "Script", "Lib", "Dora", "zh-Hans");
	const enDir = Path(Content.assetPath, "Script", "Lib", "Dora", "en");
	return docLanguage === "zh" ? zhDir : enDir;
}

function getDoraTutorialDocRoot(docLanguage: DoraAPIDocLanguage): string {
	const zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial");
	const enDir = Path(Content.assetPath, "Doc", "en", "Tutorial");
	return docLanguage === "zh" ? zhDir : enDir;
}

function getDoraAPIDocExtsByCodeLanguage(programmingLanguage: DoraAPIProgrammingLanguage): string[] {
	if (programmingLanguage === "ts" || programmingLanguage === "tsx") {
		return ["ts"];
	}
	return ["tl"];
}

function getTutorialProgrammingLanguageDir(programmingLanguage: DoraAPIProgrammingLanguage): string {
	switch (programmingLanguage) {
		case "teal": return "tl";
		case "tl": return "tl";
		default: return programmingLanguage;
	}
}

function getDoraDocSearchTarget(
	docSource: DoraAPIDocSource,
	docLanguage: DoraAPIDocLanguage,
	programmingLanguage: DoraAPIProgrammingLanguage
): { root: string; exts: string[]; globs: string[] } {
	if (docSource === "tutorial") {
		const tutorialRoot = getDoraTutorialDocRoot(docLanguage);
		const langDir = getTutorialProgrammingLanguageDir(programmingLanguage);
		return {
			root: Path(tutorialRoot, langDir),
			exts: ["md"],
			globs: ["**/*.md"],
		};
	}
	const exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage);
	return {
		root: getDoraAPIDocRoot(docLanguage),
		exts,
		globs: exts.map(ext => `**/*.${ext}`),
	};
}

function getDoraDocResultBaseRoot(docSource: DoraAPIDocSource, docLanguage: DoraAPIDocLanguage): string {
	if (docSource === "tutorial") {
		return getDoraTutorialDocRoot(docLanguage);
	}
	return getDoraAPIDocRoot(docLanguage);
}

const AGENT_DORA_DOC_PREFIX = "@dora-doc/";

function toDocRelativePath(baseRoot: string, path: string, docSource: DoraAPIDocSource): string {
	if (!path || path.length === 0) return path;
	const relative = Content.isAbsolutePath(path) ? Path.getRelative(path, baseRoot) : path;
	return `${AGENT_DORA_DOC_PREFIX}${docSource}/${relative}`;
}

function resolveAgentDoraDocFilePath(path: string, docLanguage?: DoraAPIDocLanguage): string | undefined {
	if (!docLanguage) return undefined;
	let relative = path;
	let source: DoraAPIDocSource = "tutorial";
	if (path.startsWith(AGENT_DORA_DOC_PREFIX)) {
		const namespaced = path.slice(AGENT_DORA_DOC_PREFIX.length);
		if (namespaced.startsWith("api/")) {
			source = "api";
			relative = namespaced.slice(4);
		} else if (namespaced.startsWith("tutorial/")) {
			relative = namespaced.slice(9);
		} else {
			return undefined;
		}
	}
	if (!isValidWorkspacePath(relative)) return undefined;
	const candidate = Path(getDoraDocResultBaseRoot(source, docLanguage), relative);
	const root = getDoraDocResultBaseRoot(source, docLanguage);
	const checked = Path.getRelative(candidate, root);
	if (checked === ".." || checked.startsWith("../") || checked.startsWith("..\\")) return undefined;
	if (Content.exist(candidate) && !Content.isdir(candidate)) {
		return candidate;
	}
	return undefined;
}

function ensureDirPath(dir: string): boolean {
	if (!dir || dir === "." || dir === "") return true;
	if (Content.exist(dir)) return Content.isdir(dir);
	const parent = Path.getPath(dir);
	if (parent !== dir && parent !== "." && parent !== "") {
		if (!ensureDirPath(parent)) return false;
	}
	return Content.mkdir(dir);
}

function ensureDirForFile(path: string): boolean {
	const dir = Path.getPath(path);
	return ensureDirPath(dir);
}

function isHttpUrl(url: string): boolean {
	const normalized = url.trim().toLowerCase();
	return normalized.startsWith("http://") || normalized.startsWith("https://");
}

function createOperationId(): string {
	const raw = `${tostring(os.time())}-${tostring(math.floor(math.random() * 1000000000))}`;
	const [safe] = string.gsub(raw, "[^%w%-_]", "-");
	return safe;
}

function getAgentDownloadTempRoot(): string {
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR);
}

function cleanupPath(path: string): string | undefined {
	if (!path || path === "" || !Content.exist(path)) return undefined;
	if (Content.remove(path)) return undefined;
	return `failed to remove temporary path: ${path}`;
}

function quoteGitArg(value: string): string {
	const [plain] = string.match(value, "^[%w%._%-%/]+$");
	if (plain !== undefined) {
		return value;
	}
	let [escaped] = string.gsub(value, "\\", "\\\\");
	[escaped] = string.gsub(escaped, '"', '\\"');
	return `"${escaped}"`;
}

function shellSplit(command: string): string[] {
	const args: string[] = [];
	let current = "";
	let quote = "";
	let escaped = false;
	for (let i = 0; i < command.length; i++) {
		const ch = command.charAt(i);
		if (escaped) {
			current += ch;
			escaped = false;
			continue;
		}
		if (ch === "\\") {
			escaped = true;
			continue;
		}
		if (quote !== "") {
			if (ch === quote) {
				quote = "";
			} else {
				current += ch;
			}
			continue;
		}
		if (ch === "'" || ch === '"') {
			quote = ch;
			continue;
		}
		if (ch === " " || ch === "\t" || ch === "\n" || ch === "\r") {
			if (current !== "") {
				args.push(current);
				current = "";
			}
			continue;
		}
		current += ch;
	}
	if (escaped) {
		current += "\\";
	}
	if (current !== "") {
		args.push(current);
	}
	return args;
}

function normalizeGitCommand(command: string): string {
	const trimmed = command.trim();
	const normalized = trimmed.slice(0, 4).toLowerCase() === "git "
		? trimmed.slice(4).trim()
		: trimmed;
	return normalizeEscapedGitQuotes(normalized);
}

function normalizeEscapedGitQuotes(command: string): string {
	let result = "";
	for (let i = 0; i < command.length; i++) {
		const ch = command.charAt(i);
		const next = command.charAt(i + 1);
		if (ch === "\\" && (next === '"' || next === "'")) {
			result += next;
			i += 1;
			continue;
		}
		result += ch;
	}
	return result;
}

function gitDefaultTargetFromUrl(url: string): string {
	let target = url;
	const hashIndex = target.indexOf("#");
	if (hashIndex >= 0) target = target.slice(0, hashIndex);
	const queryIndex = target.indexOf("?");
	if (queryIndex >= 0) target = target.slice(0, queryIndex);
	[target] = string.gsub(target, "/+$", "");
	const [name] = string.match(target, "([^/]+)$");
	if (name !== undefined && name !== "") target = name;
	if (target.toLowerCase().endsWith(".git")) {
		target = target.slice(0, target.length - 4);
	}
	return target !== "" ? target : "repo";
}

function parseGitCloneCommand(command: string): {
	success: true;
	url: string;
	target: string;
	ref?: string;
	depth?: string;
} | {
	success: false;
	message: string;
} | undefined {
	const args = shellSplit(normalizeGitCommand(command));
	if (args.length === 0 || args[0] !== "clone") return undefined;
	let url = "";
	let target = "";
	let ref: string | undefined;
	let depth: string | undefined;
	for (let i = 1; i < args.length; i++) {
		const arg = args[i];
		if (arg === "-b" || arg === "--branch") {
			i += 1;
			if (i >= args.length) return { success: false, message: `${arg} requires a value` };
			ref = args[i];
			continue;
		}
		if (arg === "--depth") {
			i += 1;
			if (i >= args.length) return { success: false, message: "--depth requires a value" };
			depth = args[i];
			continue;
		}
		if (arg.startsWith("--depth=")) {
			depth = arg.slice("--depth=".length);
			continue;
		}
		if (arg.startsWith("-")) {
			return { success: false, message: `unsupported clone option: ${arg}` };
		}
		if (url === "") {
			url = arg;
			continue;
		}
		if (target === "") {
			target = arg;
			continue;
		}
		return { success: false, message: `unexpected clone argument: ${arg}` };
	}
	if (url === "") return { success: false, message: "git clone requires a URL" };
	if (!isHttpUrl(url)) return { success: false, message: "git clone only supports http:// and https:// URLs" };
	if (target === "") target = gitDefaultTargetFromUrl(url);
	return {
		success: true,
		url,
		target,
		ref,
		depth: depth !== undefined && depth !== "" ? depth : "1",
	};
}

function getGitHeadCommit(repoPath: string): string | undefined {
	const headPath = Path(repoPath, ".git", "HEAD");
	if (!Content.exist(headPath)) return undefined;
	const head = toStr(Content.load(headPath)).trim();
	const [ref] = string.match(head, "^ref:%s*(.-)%s*$");
	if (ref !== undefined && ref !== "") {
		const refPath = Path(repoPath, ".git", ref);
		if (Content.exist(refPath)) {
			const commit = toStr(Content.load(refPath)).trim();
			return commit !== "" ? commit : undefined;
		}
		return undefined;
	}
	return head !== "" ? head : undefined;
}

function runGitAndWait(
	repoPath: string,
	command: string,
	onStatus?: (status: Record<string, unknown>) => void,
	isCancelled?: () => boolean,
	timeout = 600,
): Promise<{ success: boolean; message?: string; status?: Record<string, unknown>; interrupted?: boolean }> {
	return new Promise(resolve => {
		let status: Record<string, unknown> | undefined;
		let jobId = 0;
		let settled = false;
		let canceled = false;
		const finish = (result: { success: boolean; message?: string; status?: Record<string, unknown>; interrupted?: boolean }) => {
			if (settled) return;
			settled = true;
			resolve(result);
		};
		const finishFromStatus = () => {
			const state = toStr(status?.state);
			if (state === "done") {
				finish({ success: true, status });
				return true;
			}
			if (state === "error" || state === "canceled") {
				const errorMessage = toStr(status?.error);
				const statusMessage = toStr(status?.message);
				finish({
					success: false,
					message: errorMessage !== "" ? errorMessage : (statusMessage !== "" ? statusMessage : (state === "canceled" ? "git command canceled" : "git command failed")),
					status,
					interrupted: state === "canceled",
				});
				return true;
			}
			return false;
		};
		jobId = Git.run(repoPath, command, (nextStatus) => {
			status = nextStatus as unknown as Record<string, unknown>;
			if (onStatus) onStatus(status);
			return finishFromStatus();
		}, "");
		if (jobId === undefined || jobId <= 0) {
			finish({ success: false, message: "failed to start git command" });
			return;
		}
		if (!status) {
			const [kind] = string.match(command, "^(%S+)");
			status = {
				id: jobId,
				state: "queued",
				kind: toStr(kind),
				repoPath,
				progress: 0,
				message: "queued",
			};
		}
		if (onStatus) onStatus(status);
		const startedAt = os.time();
		let lastEmitAt = startedAt;
		Director.systemScheduler.schedule(() => {
			if (settled) return true;
			if (!canceled && isCancelled && isCancelled()) {
				canceled = true;
				Git.cancel(jobId);
				finish({ success: false, message: "git command canceled", status, interrupted: true });
				return true;
			}
			if (finishFromStatus()) return true;
			const nowTime = os.time();
			if (nowTime - startedAt >= timeout) {
				Git.cancel(jobId);
				finish({ success: false, message: "git command timed out", status });
				return true;
			}
			if (onStatus && status && nowTime > lastEmitAt) {
				lastEmitAt = nowTime;
				onStatus(status);
			}
			return false;
		});
	});
}

function downloadFile(req: {
	url: string;
	tempPath: string;
	timeout: number;
	onProgress: (current: number, total: number) => void;
	isCancelled?: () => boolean;
}): Promise<{ success: boolean; interrupted?: boolean; message?: string; bytesWritten?: number }> {
	return new Promise(resolve => {
		let requestId = 0;
		let settled = false;
		let bytesWritten = 0;
		const finish = (result: { success: boolean; interrupted?: boolean; message?: string; bytesWritten?: number }) => {
			if (settled) return;
			settled = true;
			requestId = 0;
			resolve(result);
		};
		Director.systemScheduler.schedule(() => {
			if (settled) return true;
			if (req.isCancelled?.() === true && requestId !== 0) {
				HttpClient.cancel(requestId);
				finish({ success: false, interrupted: true, message: "download canceled" });
				return true;
			}
			if (requestId !== 0 && !HttpClient.isRequestActive(requestId)) {
				finish({ success: false, message: "download request ended without a completion callback" });
				return true;
			}
			return false;
		});
		Director.systemScheduler.schedule(once(() => {
			requestId = HttpClient.download(req.url, req.tempPath, req.timeout, (interrupted, current, total) => {
				if (typeof current === "number" && current > bytesWritten) {
					bytesWritten = current;
				}
				if (interrupted) {
					finish({ success: false, interrupted: true, message: "download failed" });
					return true;
				}
				if (req.isCancelled?.() === true) {
					finish({ success: false, interrupted: true, message: "download canceled" });
					return true;
				}
				if (current === total) {
					finish({ success: true, bytesWritten });
					return false;
				}
				req.onProgress(current, total);
				return false;
			});
			if (requestId === 0) {
				finish({ success: false, message: "failed to schedule download request" });
			} else if (req.isCancelled?.() === true) {
				HttpClient.cancel(requestId);
				finish({ success: false, interrupted: true, message: "download canceled" });
			}
		}));
	});
}

function getFileState(path: string) {
	const exists = Content.exist(path);
	if (!exists) {
		return {
			exists: false,
			content: "",
			bytes: 0,
		};
	}
	if (Content.isdir(path)) {
		return {
			exists: true,
			content: "",
			bytes: 0,
			isDirectory: true,
		};
	}
	const content = Content.load(path);
	if (typeof content !== "string") {
		return {
			exists: true,
			content: "",
			bytes: 0,
		};
	}
	return {
		exists: true,
		content,
		bytes: content.length,
	};
}

function inspectReadableFile(path: string): { success: true; size?: number } | { success: false; message: string; size?: number; isBinary?: boolean } {
	try {
		const [size, isBinary] = Content.getAttr(path);
		if (size === undefined) {
			return {
				success: false,
				message: "failed to read file"
			};
		}
		if (isBinary) {
			return {
				success: false,
				message: `file is binary and cannot be previewed by read_file${typeof size === "number" ? ` (${size} bytes)` : ""}`,
				size: typeof size === "number" ? size : undefined,
				isBinary: true,
			};
		}
		return {
			success: true,
			size: typeof size === "number" ? size : undefined,
		};
	} catch (e) {
		Log("Warn", `[Agent.Tools] Content.getAttr failed for ${path}: ${tostring(e)}`);
		return { success: true };
	}
}

function isEngineLogFilePath(path: string): boolean {
	return path === ENGINE_LOG_FILE;
}

function readEngineLogFile(path: string): ReadFileResult | undefined {
	if (!isEngineLogFilePath(path)) return undefined;
	const content = getEngineLogText();
	if (content === undefined) {
		return { success: false, message: "failed to read engine logs" };
	}
	return { success: true, content, size: content.length };
}

function queryOne(sql: string, args?: (number | string | boolean)[]) {
	const rows = args ? DB.query(sql, args) : DB.query(sql);
	if (!rows || rows.length === 0) return undefined;
	return rows[0];
}

// initialize tables once when module is loaded
{
	DB.exec(`CREATE TABLE IF NOT EXISTS ${TABLE_TASK}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		status TEXT NOT NULL,
		prompt TEXT NOT NULL DEFAULT '',
		head_seq INTEGER NOT NULL DEFAULT 0,
		work_mode TEXT NOT NULL DEFAULT 'code',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);`);
	const taskColumns = DB.query(`PRAGMA table_info(${TABLE_TASK})`) ?? [];
	let hasTaskWorkMode = false;
	for (let i = 0; i < taskColumns.length; i++) {
		if (tostring(taskColumns[i][1]) === "work_mode") {
			hasTaskWorkMode = true;
			break;
		}
	}
	if (!hasTaskWorkMode) {
		DB.exec(`ALTER TABLE ${TABLE_TASK} ADD COLUMN work_mode TEXT NOT NULL DEFAULT 'code';`);
	}
	DB.exec(`CREATE TABLE IF NOT EXISTS ${TABLE_CP}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		task_id INTEGER NOT NULL,
		seq INTEGER NOT NULL,
		status TEXT NOT NULL,
		summary TEXT NOT NULL DEFAULT '',
		tool_name TEXT NOT NULL DEFAULT '',
		created_at INTEGER NOT NULL,
		applied_at INTEGER,
		reverted_at INTEGER
	);`);
	DB.exec(`CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON ${TABLE_CP}(task_id, seq);`);
	DB.exec(`CREATE TABLE IF NOT EXISTS ${TABLE_ENTRY}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		checkpoint_id INTEGER NOT NULL,
		ord INTEGER NOT NULL,
		path TEXT NOT NULL,
		op TEXT NOT NULL,
		before_exists INTEGER NOT NULL,
		before_content TEXT,
		after_exists INTEGER NOT NULL,
		after_content TEXT,
		bytes_before INTEGER NOT NULL DEFAULT 0,
		bytes_after INTEGER NOT NULL DEFAULT 0
	);`);
	DB.exec(`CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON ${TABLE_ENTRY}(checkpoint_id, ord);`);
}

function isDtsFile(path: string): boolean {
	return Path.getExt(Path.getName(path)) === "d";
}

function isTiledEditorContent(content: string): boolean {
	return content.trim().startsWith("<?xml");
}

type SupportedBuildKind = "ts" | "xml" | "teal" | "lua" | "yue" | "yarn";

function getSupportedBuildKind(path: string): SupportedBuildKind | undefined {
	switch (Path.getExt(path)) {
		case "ts": case "tsx": return "ts";
		case "xml": return "xml";
		case "tl": return "teal";
		case "lua": return "lua";
		case "yue": return "yue";
		case "yarn": return "yarn";
		default: return undefined;
	}
}

function getTaskHeadSeq(taskId: number): number | undefined {
	const row = queryOne(`SELECT head_seq FROM ${TABLE_TASK} WHERE id = ?`, [taskId]);
	if (!row) return undefined;
	return (row[0] as number | undefined) || 0;
}

function getTaskStatus(taskId: number): string | undefined {
	const row = queryOne(`SELECT status FROM ${TABLE_TASK} WHERE id = ?`, [taskId]);
	if (!row) return undefined;
	return toStr(row[0]);
}

function getLastInsertRowId(): number {
	const row = queryOne("SELECT last_insert_rowid()");
	return row ? ((row[0] as number | undefined) || 0) : 0;
}

function insertCheckpoint(taskId: number, seq: number, summary: string, toolName: string, status: CheckpointStatus): number {
	DB.exec(
		`INSERT INTO ${TABLE_CP}(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)`,
		[taskId, seq, status, summary, toolName, now()],
	);
	return getLastInsertRowId();
}

function getCheckpointEntries(checkpointId: number, desc = false): CheckpointEntryRow[] {
	const rows = DB.query(
		`SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content
		FROM ${TABLE_ENTRY}
		WHERE checkpoint_id = ?
		ORDER BY ord ${desc ? "DESC" : "ASC"}`,
		[checkpointId],
	);
	if (!rows) return [];
	const result: CheckpointEntryRow[] = [];
	for (let i = 0; i < rows.length; i++) {
		const row = rows[i];
		result.push({
			id: row[0] as number,
			ord: row[1] as number,
			path: toStr(row[2]),
			op: toStr(row[3]) as FileOp,
			beforeExists: toBool(row[4]),
			beforeContent: toStr(row[5]),
			afterExists: toBool(row[6]),
			afterContent: toStr(row[7]),
		});
	}
	return result;
}

function rejectDuplicatePaths(changes: FileChange[]): string | undefined {
	const seen = new Set<string>();
	for (const change of changes) {
		const key = change.path;
		if (seen.has(key)) return key;
		seen.add(key);
	}
	return undefined;
}

function getLinkedDeletePaths(workDir: string, path: string): string[] {
	const fullPath = resolveWorkspaceFilePath(workDir, path);
	if (!fullPath || !Content.exist(fullPath) || Content.isdir(fullPath)) return [];
	const parent = Path.getPath(fullPath);
	const baseName = Path.getName(fullPath).toLowerCase();
	const ext = Path.getExt(fullPath);
	const linked: string[] = [];
	for (const file of Content.getFiles(parent)) {
		if (Path.getName(file).toLowerCase() !== baseName) continue;
		const siblingExt = Path.getExt(file);
		if (siblingExt === "tl" && ext === "vs") {
			linked.push(toWorkspaceRelativePath(workDir, Path(parent, file)));
			continue;
		}
		if (siblingExt === "lua" && (ext === "tl" || ext === "yue" || ext === "ts" || ext === "tsx" || ext === "vs" || ext === "bl" || ext === "xml")) {
			linked.push(toWorkspaceRelativePath(workDir, Path(parent, file)));
		}
	}
	return linked;
}

function expandLinkedDeleteChanges(workDir: string, changes: FileChange[]): FileChange[] {
	const expanded: FileChange[] = [];
	const seen = new Set<string>();
	for (let i = 0; i < changes.length; i++) {
		const change = changes[i];
		if (!seen.has(change.path)) {
			seen.add(change.path);
			expanded.push(change);
		}
		if (change.op !== "delete") continue;
		const linkedPaths = getLinkedDeletePaths(workDir, change.path);
		for (let j = 0; j < linkedPaths.length; j++) {
			const linkedPath = linkedPaths[j];
			if (seen.has(linkedPath)) continue;
			seen.add(linkedPath);
			expanded.push({ path: linkedPath, op: "delete" });
		}
	}
	return expanded;
}

function applySingleFile(path: string, exists: boolean, content: string): boolean {
	if (exists) {
		if (!ensureDirForFile(path)) return false;
		return Content.save(path, content);
	}
	if (Content.exist(path)) {
		return Content.remove(path);
	}
	return true;
}

function rollbackPreparedFileChanges(
	checkpointId: number,
	workDir: string,
	appliedCount: number
): string | undefined {
	const entries = getCheckpointEntries(checkpointId, true);
	let remaining = appliedCount;
	const failures: string[] = [];
	for (let i = 0; i < entries.length && remaining > 0; i++) {
		const entry = entries[i];
		if (entry.ord > appliedCount) continue;
		const fullPath = resolveWorkspaceFilePath(workDir, entry.path);
		if (!fullPath || !applySingleFile(fullPath, entry.beforeExists, entry.beforeContent)) {
			failures.push(entry.path);
		} else {
			sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent);
		}
		remaining--;
	}
	return failures.length > 0 ? `rollback failed for: ${failures.join(", ")}` : undefined;
}

function encodeJSON(obj: object): string | undefined {
	const [text] = safeJsonEncode(obj);
	return text;
}

export function sendWebIDEFileUpdate(file: string, exists: boolean, content: string): boolean {
	if (HttpServer.wsConnectionCount === 0) {
		return true;
	}
	const payload = encodeJSON({ name: "UpdateFile", file, exists, content });
	if (!payload) {
		return false;
	}
	emit("AppWS", "Send", payload);
	return true;
}

export function sendWebIDERefreshTree(): boolean {
	if (HttpServer.wsConnectionCount === 0) {
		return true;
	}
	const payload = encodeJSON({ name: "RefreshTree" });
	if (!payload) {
		return false;
	}
	emit("AppWS", "Send", payload);
	return true;
}

function syncProjectFileToWebIDE(workDir: string, path: string): boolean {
	const target = resolveWorkspaceFilePath(workDir, path);
	if (!target) return false;
	if (!Content.exist(target)) {
		return sendWebIDEFileUpdate(target, false, "");
	}
	if (Content.isdir(target)) {
		return sendWebIDERefreshTree();
	}
	let content = "";
	try {
		const [, isBinary] = Content.getAttr(target);
		if (!isBinary) {
			const loaded = Content.load(target);
			content = typeof loaded === "string" ? loaded : "";
		}
	} catch (e) {
		Log("Warn", `[Agent.Tools] failed to inspect file for Web IDE update file=${target}: ${tostring(e)}`);
	}
	return sendWebIDEFileUpdate(target, true, content);
}

function refreshProjectTree(workDir: string, path?: string): boolean {
	const normalized = typeof path === "string" ? path.trim() : "";
	if (normalized === "") {
		return sendWebIDERefreshTree();
	}
	return syncProjectFileToWebIDE(workDir, normalized);
}

function syncDownloadedFileToWebIDE(file: string): boolean {
	let content = "";
	try {
		const [, isBinary] = Content.getAttr(file);
		if (!isBinary) {
			const loaded = Content.load(file);
			content = typeof loaded === "string" ? loaded : "";
		}
	} catch (e) {
		Log("Warn", `[fetch_url] failed to inspect downloaded file for Web IDE update file=${file}: ${tostring(e)}`);
	}
	return sendWebIDEFileUpdate(file, true, content);
}

async function runSingleNonTsBuild(file: string): Promise<BuildMessage> {
	return new Promise<BuildMessage>((resolve) => {
		const moduleName = "Script.Dev.WebServer";
		const { buildAsync } = require(moduleName);
		Director.systemScheduler.schedule(once(() => {
			const result = buildAsync(file);
			resolve(result);
		}));
	})
}

let transpileRequestSeq = 0;

export async function runSingleTsTranspile(file: string, content: string, projectRoot?: string): Promise<BuildMessage> {
	let done = false;
	transpileRequestSeq += 1;
	const requestId = `agent-build-${transpileRequestSeq}`;
	let result: BuildMessage = {
		success: false,
		file,
		message: "transpile timeout or Web IDE not connected",
	};
	if (HttpServer.wsConnectionCount === 0) {
		return result;
	}
	const listener = Node();
	listener.gslot("AppWS", (event) => {
		if (event.type !== "Receive") return;
		const [res] = safeJsonDecode(event.msg);
		if (!res || Array.isArray(res)) return;
		const payload = res as AnyTable;
		if (payload.name !== "TranspileTS") return;
		if (payload.id !== requestId) return;
		if (payload.success) {
			const luaFile = Path.replaceExt(file, "lua");
			if (Content.save(luaFile, tostring(payload.luaCode))) {
				result = { success: true, file };
			} else {
				result = { success: false, file, message: `failed to save ${luaFile}` };
			}
		} else {
			result = { success: false, file, message: tostring(payload.message) };
		}
		done = true;
	});
	const payload = encodeJSON({
		name: "TranspileTS",
		id: requestId,
		file,
		content,
		projectRoot,
	});
	if (!payload) {
		listener.removeFromParent();
		return { success: false, file, message: "failed to encode transpile request" };
	}
	await new Promise<void>(resolve => {
		Director.systemScheduler.schedule(once(() => {
			emit("AppWS", "Send", payload);
			wait(() => done);
			if (!done) {
				listener.removeFromParent();
			}
			resolve();
		}));
	});
	return result;
}

export function createTask(prompt = "", workMode: AgentTaskWorkMode = "code"): CreateTaskResult {
	const t = now();
	const affected = DB.exec(
		`INSERT INTO ${TABLE_TASK}(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)`,
		["RUNNING", prompt, workMode, t, t],
	);
	if (affected <= 0) {
		return { success: false, message: "failed to create task" };
	}
	return { success: true, taskId: getLastInsertRowId() };
}

export function setTaskStatus(taskId: number, status: AgentTaskStatus) {
	DB.exec(`UPDATE ${TABLE_TASK} SET status = ?, updated_at = ? WHERE id = ?`, [status, now(), taskId]);
	Log("Info", `[task:${taskId}] status=${status}`);
}

export function listCheckpoints(taskId: number): CheckpointItem[] {
	const rows = DB.query(
		`SELECT id, task_id, seq, status, summary, tool_name, created_at
		FROM ${TABLE_CP}
		WHERE task_id = ?
		ORDER BY seq DESC`,
		[taskId],
	);
	if (!rows) return [];
	const items: CheckpointItem[] = [];
	for (let i = 0; i < rows.length; i++) {
		const row = rows[i];
		items.push({
			id: row[0] as number,
			taskId: row[1] as number,
			seq: row[2] as number,
			status: toStr(row[3]),
			summary: toStr(row[4]),
			toolName: toStr(row[5]),
			createdAt: row[6] as number,
		});
	}
	return items;
}

function listCheckpointIdsForTask(taskId: number, desc = false): { id: number; seq: number }[] {
	const rows = DB.query(
		`SELECT id, seq
		FROM ${TABLE_CP}
		WHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')
		ORDER BY seq ${desc ? "DESC" : "ASC"}`,
		[taskId],
	);
	if (!rows) return [];
	const items: { id: number; seq: number }[] = [];
	for (let i = 0; i < rows.length; i++) {
		const row = rows[i];
		items.push({
			id: row[0] as number,
			seq: row[1] as number,
		});
	}
	return items;
}

function deriveFileOp(beforeExists: boolean, afterExists: boolean): FileOp {
	if (!beforeExists && afterExists) return "create";
	if (beforeExists && !afterExists) return "delete";
	return "write";
}

export function summarizeTaskChangeSet(taskId: number): TaskChangeSetSummary {
	if (!getTaskStatus(taskId)) {
		return { success: false, message: "task not found" };
	}
	const checkpoints = listCheckpointIdsForTask(taskId, false);
	const filesByPath: Record<string, {
		path: string;
		beforeExists: boolean;
		afterExists: boolean;
		checkpointIds: number[];
	}> = {};
	let latestCheckpointId: number | undefined = undefined;
	let latestCheckpointSeq: number | undefined = undefined;
	for (let i = 0; i < checkpoints.length; i++) {
		const checkpoint = checkpoints[i];
		latestCheckpointId = checkpoint.id;
		latestCheckpointSeq = checkpoint.seq;
		const entries = getCheckpointEntries(checkpoint.id, false);
		for (let j = 0; j < entries.length; j++) {
			const entry = entries[j];
			let item = filesByPath[entry.path];
			if (!item) {
				item = {
					path: entry.path,
					beforeExists: entry.beforeExists,
					afterExists: entry.afterExists,
					checkpointIds: [],
				};
				filesByPath[entry.path] = item;
			}
			item.afterExists = entry.afterExists;
			item.checkpointIds.push(checkpoint.id);
		}
	}
	const files: TaskChangeSetFile[] = [];
	for (const [, item] of pairs(filesByPath)) {
		files.push({
			path: item.path,
			op: deriveFileOp(item.beforeExists, item.afterExists),
			checkpointCount: item.checkpointIds.length,
			checkpointIds: item.checkpointIds,
		});
	}
	files.sort((a, b) => a.path < b.path ? -1 : (a.path > b.path ? 1 : 0));
	return {
		success: true,
		taskId,
		checkpointCount: checkpoints.length,
		filesChanged: files.length,
		files,
		latestCheckpointId,
		latestCheckpointSeq,
	};
}

export function getTaskChangeSetDiff(taskId: number): CheckpointDiffResult {
	if (!getTaskStatus(taskId)) {
		return { success: false, message: "task not found" };
	}
	const checkpoints = listCheckpointIdsForTask(taskId, false);
	if (checkpoints.length === 0) {
		return { success: false, message: "change set not found or empty" };
	}
	const filesByPath: Record<string, {
		path: string;
		beforeExists: boolean;
		beforeContent: string;
		afterExists: boolean;
		afterContent: string;
	}> = {};
	for (let i = 0; i < checkpoints.length; i++) {
		const entries = getCheckpointEntries(checkpoints[i].id, false);
		for (let j = 0; j < entries.length; j++) {
			const entry = entries[j];
			let item = filesByPath[entry.path];
			if (!item) {
				item = {
					path: entry.path,
					beforeExists: entry.beforeExists,
					beforeContent: entry.beforeContent,
					afterExists: entry.afterExists,
					afterContent: entry.afterContent,
				};
				filesByPath[entry.path] = item;
			}
			item.afterExists = entry.afterExists;
			item.afterContent = entry.afterContent;
		}
	}
	const files: CheckpointDiffFile[] = [];
	for (const [, item] of pairs(filesByPath)) {
		files.push({
			path: item.path,
			op: deriveFileOp(item.beforeExists, item.afterExists),
			beforeExists: item.beforeExists,
			afterExists: item.afterExists,
			beforeContent: item.beforeContent,
			afterContent: item.afterContent,
		});
	}
	files.sort((a, b) => a.path < b.path ? -1 : (a.path > b.path ? 1 : 0));
	return { success: true, files };
}

function readWorkspaceFile(workDir: string, path: string, docLanguage?: DoraAPIDocLanguage): ReadFileResult {
	const engineLog = readEngineLogFile(path);
	if (engineLog) return engineLog;
	const fullPath = resolveWorkspaceFilePath(workDir, path);
	if (fullPath && Content.exist(fullPath) && !Content.isdir(fullPath)) {
		const attr = inspectReadableFile(fullPath);
		if (!attr.success) return attr;
		return { success: true, content: Content.load(fullPath), size: attr.size };
	}
	const docPath = resolveAgentDoraDocFilePath(path, docLanguage);
	if (docPath) {
		const attr = inspectReadableFile(docPath);
		if (!attr.success) return attr;
		return { success: true, content: Content.load(docPath), size: attr.size };
	}
	if (!fullPath) return { success: false, message: "invalid path or workDir" };
	return { success: false, message: "file not found" };
}

export function readFileRaw(workDir: string, path: string, docLanguage?: DoraAPIDocLanguage): ReadFileResult {
	const result = readWorkspaceFile(workDir, path, docLanguage);
	if (!result.success && Content.exist(path) && !Content.isdir(path)) {
		const attr = inspectReadableFile(path);
		if (!attr.success) return attr;
		return { success: true, content: Content.load(path), size: attr.size };
	}
	return result;
}

function getEngineLogText(): string | undefined {
	const folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR);
	if (!Content.exist(folder)) {
		Content.mkdir(folder);
	}
	const logPath = Path(folder, ENGINE_LOG_FILE);
	if (!App.saveLog(logPath)) {
		return undefined;
	}
	return Content.load(logPath);
}

export function getLogs(req?: { tailLines?: number; joinText?: boolean }): GetLogsResult {
	const text = getEngineLogText();
	if (text === undefined) {
		return { success: false, message: "failed to read engine logs" };
	}
	const tailLines = math.max(1, math.floor(req?.tailLines ?? 200));
	const allLines = text.split("\n");
	const logs = allLines.slice(math.max(0, allLines.length - tailLines));
	return req?.joinText ? { success: true, logs, text: logs.join("\n") } : { success: true, logs };
}

export function listFiles(req: {
	workDir: string;
	path: string;
	globs?: string[];
	maxEntries?: number;
}): ListFilesResult {
	const root = req.path ?? "";
	const searchRoot = resolveWorkspaceSearchPath(req.workDir, root);
	if (!searchRoot) {
		return { success: false, message: "invalid path or workDir" };
	}
	try {
		const userGlobs = req.globs && req.globs.length > 0 ? req.globs : ["**"];
		const globs = ensureSafeSearchGlobs(userGlobs);
		let files = Content.glob(searchRoot, globs, extensionLevels);
		files = toWorkspaceRelativeFileList(req.workDir, files);
		const totalEntries = files.length;
		const maxEntries = math.max(1, math.floor(req.maxEntries ?? 200));
		const truncated = totalEntries > maxEntries;
		return {
			success: true,
			files: truncated ? files.slice(0, maxEntries) : files,
			totalEntries,
			truncated,
			maxEntries,
		};
	} catch (e) {
		return { success: false, message: tostring(e) };
	}
}

function formatReadSlice(
	content: string,
	startLine: number,
	endLine: number
): ReadFileResult {
	const lines = content.split("\n");
	const totalLines = lines.length;
	if (totalLines === 0) {
		return {
			success: true,
			content: "",
			totalLines: 0,
			startLine: 1,
			endLine: 0,
			truncated: false,
		};
	}
	const rawStart = math.floor(startLine);
	const rawEnd = math.floor(endLine);
	if (rawStart === 0) {
		return { success: false, message: "startLine cannot be 0" };
	}
	if (rawEnd === 0) {
		return { success: false, message: "endLine cannot be 0" };
	}
	const start = rawStart > 0
		? rawStart
		: math.max(1, totalLines + rawStart + 1);
	if (start > totalLines) {
		return { success: false, message: `startLine ${start} exceeds file length ${totalLines}` };
	}
	const end = math.min(
		totalLines,
		rawEnd > 0
			? rawEnd
			: math.max(1, totalLines + rawEnd + 1)
	);
	if (end < start) {
		return {
			success: false,
			message: `resolved endLine ${end} is before startLine ${start}`,
		};
	}
	const slice: string[] = [];
	for (let i = start; i <= end; i++) {
		slice.push(lines[i - 1]);
	}
	const truncated = start > 1 || end < totalLines;
	const hint = end < totalLines
		? `(Showing lines ${start}-${end} of ${totalLines}. Use startLine=${end + 1} to continue.)`
		: truncated
			? `(Showing lines ${start}-${end} of ${totalLines}.)`
			: `(End of file - ${totalLines} lines total)`;
	const body = slice.join("\n");
	const output = body === "" ? hint : `${body}\n\n${hint}`;
	return {
		success: true,
		content: output,
		totalLines,
		startLine: start,
		endLine: end,
		truncated,
	};
}

export function readFile(
	workDir: string,
	path: string,
	startLine?: number,
	endLine?: number,
	docLanguage?: DoraAPIDocLanguage
): ReadFileResult {
	const fallback = readFileRaw(workDir, path, docLanguage);
	if (!fallback.success || fallback.content === undefined) return fallback;
	const resolvedStartLine = startLine ?? 1;
	const resolvedEndLine = endLine ?? (resolvedStartLine < 0 ? -1 : 300);
	return formatReadSlice(
		fallback.content,
		resolvedStartLine,
		resolvedEndLine
	);
}

const codeExtensions = [".lua", ".tl", ".yue", ".ts", ".tsx", ".xml", ".md", ".yarn", ".wa", ".mod"];
const extensionLevels: Record<string, number> = {
	vs: 2,
	bl: 2,
	ts: 1,
	tsx: 1,
	tl: 1,
	yue: 1,
	xml: 1,
	lua: 0,
};

function ensureSafeSearchGlobs(globs: string[]): string[] {
	const result: string[] = [];
	for (let i = 0; i < globs.length; i++) {
		result.push(globs[i]);
	}
	const requiredExcludes = ["!**/.*/**", "!**/node_modules/**"];
	for (let i = 0; i < requiredExcludes.length; i++) {
		if (result.indexOf(requiredExcludes[i]) === -1) {
			result.push(requiredExcludes[i]);
		}
	}
	return result;
}

function splitSearchPatterns(pattern: string): string[] {
	const trimmed = (pattern ?? "").trim();
	if (trimmed === "") return [];
	const out: string[] = [];
	const seen = new Set<string>();
	for (const [p0] of string.gmatch(trimmed, "([^|]+)")) {
		const p = tostring(p0).trim();
		if (p !== "" && !seen.has(p)) {
			seen.add(p);
			out.push(p);
		}
	}
	return out;
}

function splitWhitespaceSearchPatterns(pattern: string): string[] {
	const out: string[] = [];
	const seen = new Set<string>();
	for (const [p0] of string.gmatch(pattern, "(%S+)")) {
		const p = tostring(p0).trim();
		const key = p.toLowerCase();
		if (p !== "" && !seen.has(key)) {
			seen.add(key);
			out.push(p);
		}
	}
	return out;
}

function mergeSearchFileResultsUnique(resultsList: SearchFilesResult[][]): SearchFilesResult[] {
	const merged: SearchFilesResult[] = [];
	const seen = new Set<string>();
	for (let i = 0; i < resultsList.length; i++) {
		const list = resultsList[i];
		for (let j = 0; j < list.length; j++) {
			const row = list[j];
			const key = `${row.file}:${row.pos}:${row.line}:${row.column}`;
			if (seen.has(key)) continue;
			seen.add(key);
			merged.push(list[j]);
		}
	}
	return merged;
}

function buildGroupedSearchResults(results: SearchFilesResult[]): {
	file: string;
	totalMatches: number;
	matches: SearchFilesResult[];
}[] {
	const order: string[] = [];
	const grouped = new Map<string, {
		file: string;
		totalMatches: number;
		matches: SearchFilesResult[];
	}>();
	for (let i = 0; i < results.length; i++) {
		const row = results[i]
		const file = row.file;
		const key = file !== "" ? file : `(unknown:${i})`;
		let bucket = grouped.get(key);
		if (!bucket) {
			bucket = { file: file !== "" ? file : "(unknown)", totalMatches: 0, matches: [] };
			grouped.set(key, bucket);
			order.push(key);
		}
		bucket.totalMatches += 1;
		bucket.matches.push(results[i]);
	}
	const out: {
		file: string;
		totalMatches: number;
		matches: SearchFilesResult[];
	}[] = [];
	for (let i = 0; i < order.length; i++) {
		const bucket = grouped.get(order[i]);
		if (bucket) out.push(bucket);
	}
	return out;
}

function mergeDoraAPISearchHitsUnique(resultsList: DoraAPISearchHit[][]): DoraAPISearchHit[] {
	const merged: DoraAPISearchHit[] = [];
	const seen = new Set<string>();
	let index = 0;
	let advanced = true;
	while (advanced) {
		advanced = false;
		for (let i = 0; i < resultsList.length; i++) {
			const list = resultsList[i];
			if (index >= list.length) continue;
			advanced = true;
			const row = list[index];
			const key = `${row.file}:${tostring(row.line ?? "")}:${tostring(row.content ?? "")}`;
			if (seen.has(key)) continue;
			seen.add(key);
			merged.push(row);
		}
		index += 1;
	}
	return merged;
}

function getDoraAPIFilePriority(file: string, docSource: DoraAPIDocSource, programmingLanguage: DoraAPIProgrammingLanguage): number {
	if (docSource !== "api") return 100;
	if (programmingLanguage !== "tsx") return 100;
	switch (Path.getFilename(file).toLowerCase()) {
		case "jsx.d.ts": return 0;
		case "dorax.d.ts": return 1;
		case "dora.d.ts": return 2;
		default: return 100;
	}
}

function sortDoraAPISearchHits(
	hits: DoraAPISearchHit[],
	docSource: DoraAPIDocSource,
	programmingLanguage: DoraAPIProgrammingLanguage
): DoraAPISearchHit[] {
	const sorted = hits.slice();
	sorted.sort((a, b) => {
		const pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage);
		const pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage);
		if (pa !== pb) return pa - pb;
		const fa = a.file.toLowerCase();
		const fb = b.file.toLowerCase();
		if (fa !== fb) return fa < fb ? -1 : 1;
		return (a.line ?? 0) - (b.line ?? 0);
	});
	return sorted;
}

export async function searchFiles(req: {
	workDir: string;
	path: string;
	globs?: string[];
	pattern: string;
	useRegex?: boolean;
	caseSensitive?: boolean;
	includeContent?: boolean;
	contentWindow?: number;
	limit?: number;
	offset?: number;
	groupByFile?: boolean;
}): Promise<SearchFilesToolResult> {
	const resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path);
	if (!resolvedPath) {
		return { success: false, message: "invalid path or workDir" as string };
	}
	const searchIsSingleFile = Content.exist(resolvedPath) && !Content.isdir(resolvedPath);
	const searchRoot = searchIsSingleFile ? Path.getPath(resolvedPath) : resolvedPath;
	if (!searchRoot) {
		return { success: false, message: "invalid path or workDir" as string };
	}
	if (!req.pattern || req.pattern.trim() === "") {
		return { success: false, message: "empty pattern" as string };
	}
	const patterns = splitSearchPatterns(req.pattern);
	if (patterns.length === 0) {
		return { success: false, message: "empty pattern" as string };
	}
	return new Promise(resolve => {
		Director.systemScheduler.schedule(once(() => {
			try {
				const searchGlobs = searchIsSingleFile
					? [Path.getFilename(resolvedPath)]
					: ensureSafeSearchGlobs(req.globs ?? ["**"]);
				const allResults: SearchFilesResult[][] = [];
				for (let i = 0; i < patterns.length; i++) {
					allResults.push(Content.searchFilesAsync(
						searchRoot,
						codeExtensions,
						extensionLevels,
						searchGlobs,
						patterns[i],
						req.useRegex ?? false,
						req.caseSensitive ?? false,
						req.includeContent ?? true,
						req.contentWindow ?? 120
					));
				}
				const results = mergeSearchFileResultsUnique(allResults);
				const totalResults = results.length;
				const limit = math.max(1, math.floor(req.limit ?? 20));
				const offset = math.max(0, math.floor(req.offset ?? 0));
				const paged = offset >= totalResults ? [] : results.slice(offset, offset + limit);
				const nextOffset = offset + paged.length;
				const hasMore = nextOffset < totalResults;
				const truncated = offset > 0 || hasMore;
				const relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged);
				const groupByFile = req.groupByFile === true;
				resolve({
					success: true,
					results: relativeResults,
					groupedResults: groupByFile ? buildGroupedSearchResults(relativeResults) : undefined,
					totalResults,
					truncated,
					limit,
					offset,
					nextOffset,
					hasMore,
					groupByFile,
				});
			} catch (e) {
				resolve({ success: false, message: tostring(e) });
			}
		}));
	});
}

export async function searchDoraAPI(req: {
	pattern: string;
	docLanguage: DoraAPIDocLanguage;
	programmingLanguage: DoraAPIProgrammingLanguage;
	docSource?: DoraAPIDocSource;
	limit?: number;
	useRegex?: boolean;
	caseSensitive?: boolean;
	includeContent?: boolean;
	contentWindow?: number;
}): Promise<DoraAPISearchResult> {
	const pattern = (req.pattern ?? "").trim();
	if (pattern === "") return { success: false, message: "empty pattern" };
	const patterns = splitSearchPatterns(pattern);
	if (patterns.length === 0) return { success: false, message: "empty pattern" };
	const docSource = req.docSource ?? "api";
	const target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage);
	const docRoot = target.root;
	const resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage);
	if (!Content.exist(docRoot) || !Content.isdir(docRoot)) {
		return { success: false, message: `doc root not found: ${docRoot}` };
	}
	const exts = target.exts;
	const dotExts = exts.map(ext => ext.startsWith(".") ? ext : `.${ext}`);
	const globs = target.globs;
	const limit = math.max(1, math.floor(req.limit ?? 10));

	return new Promise(resolve => {
		Director.systemScheduler.schedule(once(() => {
			try {
				const allHits: DoraAPISearchHit[][] = [];
				for (let p = 0; p < patterns.length; p++) {
					const raw = Content.searchFilesAsync(
						docRoot,
						dotExts,
						{},
						ensureSafeSearchGlobs(globs),
						patterns[p],
						req.useRegex ?? false,
						req.caseSensitive ?? false,
						req.includeContent ?? true,
						req.contentWindow ?? 80
					);
					const hits: DoraAPISearchHit[] = [];
					for (let i = 0; i < raw.length; i++) {
						const row = raw[i];
						const file = toDocRelativePath(resultBaseRoot, row.file, docSource);
						if (file === "") continue;
						hits.push({
							file,
							line: typeof row.line === "number" ? row.line : undefined,
							content: typeof row.content === "string" ? row.content : undefined,
						});
					}
					allHits.push(sortDoraAPISearchHits(hits, docSource, req.programmingLanguage).slice(0, limit));
				}
				let hits = mergeDoraAPISearchHitsUnique(allHits);
				let fallbackPatterns: string[] | undefined;
				// Preserve phrase search first. If a model sends a space-separated
				// keyword list instead of the documented `|` form and gets no hits,
				// retry the individual terms inside the same tool call.
				if (hits.length === 0 && patterns.length === 1 && req.useRegex !== true && pattern.indexOf("|") < 0) {
					const terms = splitWhitespaceSearchPatterns(pattern);
					if (terms.length > 1) {
						fallbackPatterns = terms;
						const fallbackHits: DoraAPISearchHit[][] = [];
						for (let p = 0; p < terms.length; p++) {
							const raw = Content.searchFilesAsync(
								docRoot,
								dotExts,
								{},
								ensureSafeSearchGlobs(globs),
								terms[p],
								false,
								req.caseSensitive ?? false,
								req.includeContent ?? true,
								req.contentWindow ?? 80
							);
							const termHits: DoraAPISearchHit[] = [];
							for (let i = 0; i < raw.length; i++) {
								const row = raw[i];
								const file = toDocRelativePath(resultBaseRoot, row.file, docSource);
								if (file === "") continue;
								termHits.push({
									file,
									line: typeof row.line === "number" ? row.line : undefined,
									content: typeof row.content === "string" ? row.content : undefined,
								});
							}
							fallbackHits.push(sortDoraAPISearchHits(termHits, docSource, req.programmingLanguage).slice(0, limit));
						}
						hits = mergeDoraAPISearchHitsUnique(fallbackHits);
					}
				}
				resolve({
					success: true,
					docSource,
					docLanguage: req.docLanguage,
					programmingLanguage: req.programmingLanguage,
					exts,
					results: hits,
					hint: "Use read_file directly with the namespaced file value from a search result to view the complete authoritative document.",
					totalResults: hits.length,
					truncated: false,
					limit,
					fallbackPatterns,
				});
			} catch (e) {
				resolve({ success: false, message: tostring(e) });
			}
		}));
	});
}

export function searchDoraAPIHttp(req: {
	pattern: string;
	docLanguage: DoraAPIDocLanguage;
	programmingLanguage: DoraAPIProgrammingLanguage;
	docSource?: DoraAPIDocSource;
	limit?: number;
	useRegex?: boolean;
	caseSensitive?: boolean;
	includeContent?: boolean;
	contentWindow?: number;
}, callback: (result: DoraAPISearchResult) => void) {
	searchDoraAPI(req).then(result => callback(result));
}

export function readDoraDoc(req: {
	docLanguage: DoraAPIDocLanguage;
	file: string;
	startLine?: number;
	endLine?: number;
}): DoraAPIReadDocResult {
	const requestedFile = (req.file ?? "").split("\\").join("/");
	let file = requestedFile;
	let namespacedSource: DoraAPIDocSource | undefined = undefined;
	if (requestedFile.startsWith(AGENT_DORA_DOC_PREFIX)) {
		const namespaced = requestedFile.slice(AGENT_DORA_DOC_PREFIX.length);
		if (namespaced.startsWith("api/")) {
			namespacedSource = "api";
			file = namespaced.slice(4);
		} else if (namespaced.startsWith("tutorial/")) {
			namespacedSource = "tutorial";
			file = namespaced.slice(9);
		} else {
			return { success: false, message: "invalid Dora doc namespace" };
		}
	}
	if (!isValidWorkspacePath(file) || file === ".") {
		return { success: false, message: "invalid file" };
	}
	const lowerFile = file.toLowerCase();
	const isTutorialDoc = lowerFile.endsWith(".md");
	const isAPIDoc = lowerFile.endsWith(".ts") || lowerFile.endsWith(".tl");
	if (!isTutorialDoc && !isAPIDoc) return { success: false, message: "unsupported doc file type" };
	const docSource: DoraAPIDocSource = namespacedSource ?? (isTutorialDoc ? "tutorial" : "api");
	const root = getDoraDocResultBaseRoot(docSource, req.docLanguage);
	const fullPath = Path(root, file);
	const relative = Path.getRelative(fullPath, root);
	if (relative === ".." || relative.startsWith("../") || relative.startsWith("..\\")) {
		return { success: false, message: "invalid file" };
	}
	const readResult = readFile(root, file, req.startLine ?? 1, req.endLine ?? -1);
	if (!readResult.success) return readResult;
	return {
		success: true,
		docLanguage: req.docLanguage,
		file,
		content: readResult.content,
		startLine: readResult.startLine,
		endLine: readResult.endLine,
	};
}

export function applyFileChanges(taskId: number, workDir: string, changes: FileChange[], options: ApplyChangesOptions = {}): ApplyChangesResult {
	if (changes.length === 0) {
		return { success: false, message: "empty changes" };
	}
	if (!isValidWorkDir(workDir)) {
		return { success: false, message: "invalid workDir" };
	}
	if (!getTaskStatus(taskId)) {
		return { success: false, message: "task not found" };
	}
	const expandedChanges = expandLinkedDeleteChanges(workDir, changes);
	const dup = rejectDuplicatePaths(expandedChanges);
	if (dup) {
		return { success: false, message: `duplicate path in batch: ${dup}` };
	}

	for (const change of expandedChanges) {
		if (!isValidWorkspacePath(change.path)) {
			return { success: false, message: `invalid path: ${change.path}` };
		}
		if ((change.op === "write" || change.op === "create") && change.content === undefined) {
			return { success: false, message: `missing content for ${change.path}` };
		}
	}

	const headSeq = getTaskHeadSeq(taskId);
	if (headSeq === undefined) return { success: false, message: "task not found" };
	const nextSeq = headSeq + 1;
	const checkpointId = insertCheckpoint(taskId, nextSeq, options.summary ?? "", options.toolName ?? "", "PREPARED");
	if (checkpointId <= 0) {
		return { success: false, message: "failed to create checkpoint" };
	}

	for (let i = 0; i < expandedChanges.length; i++) {
		const change = expandedChanges[i];
		const fullPath = resolveWorkspaceFilePath(workDir, change.path);
		if (!fullPath) {
			DB.exec(`UPDATE ${TABLE_CP} SET status = ? WHERE id = ?`, ["FAILED", checkpointId]);
			return { success: false, message: `invalid path: ${change.path}` };
		}
		if (change.op === "delete" && Content.exist(fullPath) && Content.isdir(fullPath)) {
			DB.exec(`UPDATE ${TABLE_CP} SET status = ? WHERE id = ?`, ["FAILED", checkpointId]);
			return { success: false, message: `delete_file only supports files, not directories: ${change.path}` };
		}
		const before = getFileState(fullPath);
		const afterExists = change.op !== "delete";
		const afterContent = afterExists ? (change.content ?? "") : "";
		const inserted = DB.exec(
			`INSERT INTO ${TABLE_ENTRY}(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)
			VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			[
				checkpointId,
				i + 1,
				change.path,
				change.op,
				before.exists ? 1 : 0,
				before.content,
				afterExists ? 1 : 0,
				afterContent,
				before.bytes,
				afterContent.length,
			],
		);
		if (inserted <= 0) {
			DB.exec(`UPDATE ${TABLE_CP} SET status = ? WHERE id = ?`, ["FAILED", checkpointId]);
			return { success: false, message: `failed to insert checkpoint entry: ${change.path}` };
		}
	}

	let appliedCount = 0;
	for (const entry of getCheckpointEntries(checkpointId, false)) {
		const fullPath = resolveWorkspaceFilePath(workDir, entry.path);
		if (!fullPath) {
			DB.exec(`UPDATE ${TABLE_CP} SET status = ? WHERE id = ?`, ["FAILED", checkpointId]);
			const rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount);
			return { success: false, message: `invalid path: ${entry.path}${rollbackError !== undefined ? `; ${rollbackError}` : "; previously applied files restored"}` };
		}
		const ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent);
		if (!ok) {
			DB.exec(`UPDATE ${TABLE_CP} SET status = ? WHERE id = ?`, ["FAILED", checkpointId]);
			const rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1);
			return { success: false, message: `failed to apply file change: ${entry.path}${rollbackError !== undefined ? `; ${rollbackError}` : "; previously applied files restored"}` };
		}
		appliedCount++;
		if (!sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent)) {
			DB.exec(`UPDATE ${TABLE_CP} SET status = ? WHERE id = ?`, ["FAILED", checkpointId]);
			const rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount);
			return { success: false, message: `failed to sync file change: ${entry.path}${rollbackError !== undefined ? `; ${rollbackError}` : "; all applied files restored"}` };
		}
	}

	DB.exec(
		`UPDATE ${TABLE_CP} SET status = ?, applied_at = ? WHERE id = ?`,
		["APPLIED", now(), checkpointId],
	);
	DB.exec(
		`UPDATE ${TABLE_TASK} SET head_seq = ?, updated_at = ? WHERE id = ?`,
		[nextSeq, now(), taskId],
	);
	return {
		success: true,
		taskId,
		checkpointId,
		checkpointSeq: nextSeq,
	};
}

export function rollbackCheckpoint(checkpointId: number, workDir: string): RollbackResult {
	if (!isValidWorkDir(workDir)) return { success: false, message: "invalid workDir" };
	if (checkpointId <= 0) return { success: false, message: "invalid checkpointId" };
	const entries = getCheckpointEntries(checkpointId, true);
	if (entries.length === 0) {
		return { success: false, message: "checkpoint not found or empty" };
	}
	for (const entry of entries) {
		const fullPath = resolveWorkspaceFilePath(workDir, entry.path);
		if (!fullPath) {
			return { success: false, message: `invalid path: ${entry.path}` };
		}
		const ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent);
		if (!ok) {
			Log("Error", `Agent rollback failed at checkpoint ${checkpointId}, file ${entry.path}`);
			Log("Info", `[rollback] failed checkpoint=${checkpointId} file=${entry.path}`);
			return { success: false, message: `failed to rollback file: ${entry.path}` };
		}
		if (!sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent)) {
			Log("Error", `Agent rollback sync failed at checkpoint ${checkpointId}, file ${entry.path}`);
			Log("Info", `[rollback] sync_failed checkpoint=${checkpointId} file=${entry.path}`);
			return { success: false, message: `failed to sync rollback file: ${entry.path}` };
		}
	}
	DB.exec(`UPDATE ${TABLE_CP} SET status = ?, reverted_at = ? WHERE id = ?`, ["REVERTED", now(), checkpointId]);
	return { success: true, checkpointId };
}

export function rollbackTaskChangeSet(taskId: number, workDir: string): TaskRollbackResult {
	if (!isValidWorkDir(workDir)) return { success: false, message: "invalid workDir" };
	if (!getTaskStatus(taskId)) return { success: false, message: "task not found" };
	const checkpoints = listCheckpointIdsForTask(taskId, true);
	if (checkpoints.length === 0) {
		return { success: false, message: "change set not found or empty" };
	}
	let lastCheckpointId = 0;
	for (let i = 0; i < checkpoints.length; i++) {
		const result = rollbackCheckpoint(checkpoints[i].id, workDir);
		if (!result.success) return { success: false, message: result.message };
		lastCheckpointId = checkpoints[i].id;
	}
	return {
		success: true,
		taskId,
		checkpointId: lastCheckpointId,
		checkpointCount: checkpoints.length,
	};
}

export function getCheckpointEntriesForDebug(checkpointId: number) {
	return getCheckpointEntries(checkpointId, false);
}

export function getCheckpointDiff(checkpointId: number): CheckpointDiffResult {
	if (checkpointId <= 0) {
		return { success: false, message: "invalid checkpointId" };
	}
	const entries = getCheckpointEntries(checkpointId, false);
	if (entries.length === 0) {
		return { success: false, message: "checkpoint not found or empty" };
	}
	return {
		success: true,
		files: entries.map(entry => ({
			path: entry.path,
			op: entry.op,
			beforeExists: entry.beforeExists,
			afterExists: entry.afterExists,
			beforeContent: entry.beforeContent,
			afterContent: entry.afterContent,
		})),
	};
}

function finalizeBuildResult(workDir: string, messages: BuildMessage[]): BuildResult {
	const normalized = messages.map(m => m.success
		? ({ ...m, file: toWorkspaceRelativePath(workDir, m.file) })
		: ({ ...m, file: toWorkspaceRelativePath(workDir, m.file) }));
	const total = normalized.length;
	let failed = 0;
	for (let i = 0; i < normalized.length; i++) {
		if (!normalized[i].success) failed += 1;
	}
	const passed = total - failed;
	if (failed > 0) {
		return {
			success: false,
			message: `Build failed: ${failed}/${total} file(s) failed.`,
			total,
			passed,
			failed,
			messages: normalized,
		};
	}
	return {
		success: true,
		message: `Build passed: ${passed}/${total} file(s).`,
		total,
		passed,
		failed: 0,
		messages: normalized,
	};
}

export async function build(req: { workDir: string; path: string }): Promise<BuildResult> {
	const targetRel = req.path ?? "";
	const target = resolveWorkspaceSearchPath(req.workDir, targetRel);
	if (!target) {
		return { success: false, message: "invalid path or workDir" };
	}
	if (!Content.exist(target)) {
		return { success: false, message: "path not existed" };
	}
	const messages: BuildMessage[] = [];
	if (!Content.isdir(target)) {
		const kind = getSupportedBuildKind(target);
		if (!kind) {
			return { success: false, message: "expecting a ts/tsx, tl, lua, yue or yarn file" };
		}
		if (kind === "ts") {
			const content = Content.load(target);
			if (content === undefined) {
				return { success: false, message: "failed to read file" };
			}
			if (isTiledEditorContent(content)) {
				Log("Info", `[build] skip tiled editor file=${target}`);
				return finalizeBuildResult(req.workDir, messages);
			}
			if (!sendWebIDEFileUpdate(target, true, content)) {
				return { success: false, message: "failed to encode UpdateFile request" };
			}
			if (!isDtsFile(target)) {
				messages.push(await runSingleTsTranspile(target, content, req.workDir));
			}
		} else {
			messages.push(await runSingleNonTsBuild(target));
		}
		Log("Info", `[build] file=${target} messages=${messages.length}`);
		return finalizeBuildResult(req.workDir, messages);
	}
	const listResult = listFiles({
		workDir: req.workDir,
		path: targetRel,
		globs: codeExtensions.map(e => `**/*${e}`),
		maxEntries: 10000
	});

	const relFiles = listResult.success ? listResult.files : [];
	const tsFileData: Record<string, string> = {};
	const buildQueue: { file: string; kind: SupportedBuildKind }[] = [];
	for (const rel of relFiles) {
		const file = Content.isAbsolutePath(rel) ? rel : Path(target, rel);
		const kind = getSupportedBuildKind(file);
		if (!kind) continue;
		buildQueue.push({ file, kind });
		if (kind !== "ts") {
			continue;
		}
		const content = Content.load(file);
		if (content === undefined) {
			messages.push({ success: false, file, message: "failed to read file" });
			continue;
		}
		if (isTiledEditorContent(content)) {
			Log("Info", `[build] skip tiled editor file=${file}`);
			continue;
		}
		tsFileData[file] = content;
	}
	for (let i = 0; i < buildQueue.length; i++) {
		const { file, kind } = buildQueue[i];
		if (kind === "ts") {
			const content = tsFileData[file];
			if (content === undefined || isDtsFile(file)) {
				continue;
			}
			if (!sendWebIDEFileUpdate(file, true, content)) {
				messages.push({ success: false, file, message: "failed to encode UpdateFile request" });
				continue;
			}
			messages.push(await runSingleTsTranspile(file, content, req.workDir));
			continue;
		}
		messages.push(await runSingleNonTsBuild(file));
	}
	if (messages.length === 0) {
		Log("Info", `[build] dir=${target} messages=0 no buildable code files found`);
		return { success: false, message: "No code files were found to build." };
	}
	Log("Info", `[build] dir=${target} messages=${messages.length}`);
	return finalizeBuildResult(req.workDir, messages);
}

const EXECUTE_COMMAND_OUTPUT_MAX = 12000;
const EXECUTE_COMMAND_ERROR_MAX = 4000;
const LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30;
let agentEntryRuntimeOwner = "";

function truncateCommandOutput(output: string): string {
	if (output.length <= EXECUTE_COMMAND_OUTPUT_MAX) return output;
	return `${output.slice(0, EXECUTE_COMMAND_OUTPUT_MAX)}\n... output truncated ...`;
}

function truncateCommandError(message: string): string {
	if (message.length <= EXECUTE_COMMAND_ERROR_MAX) return message;
	return `${message.slice(0, EXECUTE_COMMAND_ERROR_MAX)}\n... error message truncated ...`;
}

function executeLuaCommand(req: {
	workDir: string;
	code: string;
	timeoutSeconds: number;
	operationId: string;
	onProgress?: (progress: ExecuteCommandProgress) => void;
	isCancelled?: () => boolean;
}): Promise<ExecuteCommandResult> {
	const code = (req.code ?? "").trim();
	if (code === "") {
		return Promise.resolve({ success: false, mode: "lua", output: "", message: "missing code", phase: "validate" });
	}
	const output: string[] = [];
	const entry = require("Script.Dev.Entry") as DevEntryModule;
	let ownsEntryRuntime = false;
	const acquireEntryRuntime = () => {
		if (agentEntryRuntimeOwner !== "" && agentEntryRuntimeOwner !== req.operationId) {
			error("Dora entry runtime is busy with another Agent command");
		}
		agentEntryRuntimeOwner = req.operationId;
		ownsEntryRuntime = true;
	};
	const stopOwnedEntry = (): string | undefined => {
		if (!ownsEntryRuntime) return undefined;
		let cleanupError: string | undefined;
		try {
			entry.stop();
		} catch (e) {
			cleanupError = `failed to stop Agent test entry: ${tostring(e)}`;
		}
		ownsEntryRuntime = false;
		if (agentEntryRuntimeOwner === req.operationId) {
			agentEntryRuntimeOwner = "";
		}
		return cleanupError;
	};
	const normalizeEntryFile = (value: unknown): { fileName: string; entryName: string } => {
		if (!value || type(value) !== "table") {
			error("enterEntryAsync expects a table with an optional project-relative fileName");
		}
		const descriptor = value as AgentEntryDescriptor;
		let relativeFile = typeof descriptor.fileName === "string" ? descriptor.fileName.trim() : "";
		if (relativeFile === "") relativeFile = "init";
		if (!isValidWorkspacePath(relativeFile)) {
			error("enterEntryAsync fileName must be a project-relative path without '..'");
		}
		let fileName = Path(req.workDir, relativeFile);
		const ext = Path.getExt(fileName);
		if (ext !== "") fileName = Path.replaceExt(fileName, "");
		const luaFile = Path.replaceExt(fileName, "lua");
		if (!Content.exist(luaFile)) {
			error(`Agent test entry was not built: ${luaFile}`);
		}
		const requestedName = typeof descriptor.entryName === "string" ? descriptor.entryName.trim() : "";
		return {
			fileName,
			entryName: requestedName !== "" ? requestedName : Path.getName(fileName),
		};
	};
	const capturePrint = (...values: unknown[]) => {
		const parts: string[] = [];
		for (let i = 0; i < values.length; i++) {
			parts.push(tostring(values[i]));
		}
		output.push(parts.join("\t"));
	};
	const env = setmetatable({
		projectDir: req.workDir,
		requireProjectModule: (moduleNameValue: unknown, reloadModulesValue?: unknown): unknown => {
			if (typeof moduleNameValue !== "string") {
				error("requireProjectModule expects a project module name string");
			}
			const moduleName = (moduleNameValue as string).trim();
			if (moduleName === "" || moduleName.indexOf("..") >= 0 || moduleName.indexOf("/") === 0) {
				error("requireProjectModule expects a non-empty project module name without '..' or an absolute path");
			}
			const reloadModules: string[] = [moduleName];
			if (reloadModulesValue !== undefined) {
				if (!Array.isArray(reloadModulesValue)) {
					error("requireProjectModule reloadModules must be an array of module names");
				}
				const items = reloadModulesValue as unknown[];
				for (let i = 0; i < items.length; i++) {
					const item = items[i];
					if (typeof item !== "string" || item.trim() === "" || item.indexOf("..") >= 0) {
						error("requireProjectModule reloadModules contains an invalid module name");
					}
					if (reloadModules.indexOf(item) < 0) reloadModules.push(item);
				}
			}
			const luaPackage = _G["package"] as unknown as {
				path: string;
				loaded: Record<string, unknown>;
			};
			const previousPath = luaPackage.path;
			const previousSearchPaths = Content.searchPaths;
			const scopedSearchPaths: string[] = [req.workDir];
			for (let i = 0; i < previousSearchPaths.length; i++) {
				const searchPath = previousSearchPaths[i];
				if (searchPath !== req.workDir) scopedSearchPaths.push(searchPath);
			}
			luaPackage.path = `${Path(req.workDir, "?.lua")};${Path(req.workDir, "?", "init.lua")};${previousPath}`;
			Content.searchPaths = scopedSearchPaths;
			try {
				for (let i = 0; i < reloadModules.length; i++) {
					const reloadName = reloadModules[i];
					luaPackage.loaded[reloadName] = undefined;
					luaPackage.loaded[reloadName.split("/").join(".")] = undefined;
					luaPackage.loaded[reloadName.split(".").join("/")] = undefined;
				}
				return require(moduleName.split("/").join("."));
			} finally {
				Content.searchPaths = previousSearchPaths;
				luaPackage.path = previousPath;
			}
		},
		print: capturePrint,
		refreshTree: (path?: unknown) => {
			if (path === undefined) {
				return refreshProjectTree(req.workDir);
			}
			if (typeof path !== "string") {
				error("refreshTree expects a project-relative file path string or no argument");
			}
			return refreshProjectTree(req.workDir, path as string);
		},
		getEntryStatus: () => entry.getCurrentEntryStatus(),
		enterEntryAsync: (value: unknown): LuaMultiReturn<[boolean, string | undefined]> => {
			const normalized = normalizeEntryFile(value);
			acquireEntryRuntime();
			entry.allClear();
			const [success, message] = entry.enterEntryAsync({
				entryName: normalized.entryName,
				fileName: normalized.fileName,
				workDir: req.workDir,
				projectRoot: req.workDir,
				runKind: "agent_test",
			});
			return $multi(success, message);
		},
		stopEntry: () => {
			if (!ownsEntryRuntime) return false;
			return entry.stop();
		},
	}, {
		__index: Dora,
	});
	const [fn, compileErr] = load(code, "=(agent_command)", "t", env);
	if (!fn) {
		return Promise.resolve({
			success: false,
			mode: "lua",
			output: truncateCommandOutput(output.join("\n")),
			message: truncateCommandError(toStr(compileErr)),
			phase: "compile",
		});
	}
	return new Promise(resolve => {
		let settled = false;
		const startedAt = App.runningTime;
		const onProgress = req.onProgress;
		const isCancelled = req.isCancelled;
		const finish = (result: ExecuteCommandResult) => {
			if (settled) return;
			settled = true;
			const cleanupError = stopOwnedEntry();
			if (!result.success && cleanupError !== undefined) {
				result.cleanupError = cleanupError;
			} else if (result.success && cleanupError !== undefined) {
				resolve({
					success: false,
					mode: "lua",
					output: result.output,
					message: cleanupError,
					phase: "execute",
					cleanupError,
				});
				return;
			}
			resolve(result);
		};
		if (onProgress) {
			onProgress({
				state: "pending",
				mode: "lua",
				operationId: req.operationId,
				stage: "lua",
				message: "Lua command pending",
			});
		}
		Director.systemScheduler.schedule(() => {
			if (settled) return true;
			if (isCancelled && isCancelled()) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: "Lua command canceled",
					phase: "execute",
					interrupted: true,
				});
				return true;
			}
			if (App.runningTime - startedAt >= req.timeoutSeconds) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: `Lua command timed out after ${tostring(req.timeoutSeconds)} seconds`,
					phase: "timeout",
				});
				return true;
			}
			return false;
		});
		Director.systemScheduler.schedule(once(() => {
			if (settled) return;
			if (onProgress) {
				onProgress({
					state: "running",
					mode: "lua",
					operationId: req.operationId,
					stage: "lua",
					message: "Lua command running",
				});
			}
			const previousGlobalPrint = _G["print"];
			_G["print"] = capturePrint;
			const [ok, runtimeErr] = pcall(fn);
			_G["print"] = previousGlobalPrint;
			if (!ok) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: truncateCommandError(toStr(runtimeErr)),
					phase: "execute",
				});
				return;
			}
			finish({ success: true, mode: "lua", output: truncateCommandOutput(output.join("\n")) });
		}));
	});
}

function formatGitStatusOutput(status?: Record<string, unknown>): string {
	if (!status) return "";
	const lines: string[] = [];
	const state = toStr(status.state);
	const kind = toStr(status.kind);
	const message = toStr(status.message);
	const errorMessage = toStr(status.error);
	if (kind !== "" || state !== "") {
		lines.push([kind, state].filter(item => item !== "").join(": "));
	}
	if (message !== "") lines.push(message);
	if (errorMessage !== "") lines.push(errorMessage);
	const data = status.data;
	if (data !== undefined) {
		const dataText = encodeJSON(data as object);
		lines.push(dataText !== undefined ? dataText : tostring(data));
	}
	return truncateCommandOutput(lines.join("\n"));
}

function emitGitProgress(
	mode: ExecuteCommandMode,
	operationId: string,
	onProgress: ((progress: ExecuteCommandProgress) => void) | undefined,
	status: Record<string, unknown>,
) {
	if (!onProgress) return;
	const progress = typeof status.progress === "number" ? status.progress as number : undefined;
	const kind = toStr(status.kind);
	const message = toStr(status.message);
	const state = toStr(status.state);
	const jobId = typeof status.id === "number" ? status.id as number : undefined;
	onProgress({
		state: "running",
		mode,
		operationId,
		stage: kind !== "" ? kind : "git",
		message: message !== "" ? message : (state !== "" ? state : "running"),
		progress,
		jobId,
		gitState: state !== "" ? state : undefined,
		gitKind: kind !== "" ? kind : undefined,
	});
}

async function cloneGitToTarget(req: {
	workDir: string;
	command: string;
	operationId: string;
	timeoutSeconds: number;
	onProgress?: (progress: ExecuteCommandProgress) => void;
	isCancelled?: () => boolean;
}): Promise<ExecuteCommandResult | undefined> {
	const parsed = parseGitCloneCommand(req.command);
	if (parsed === undefined) return undefined;
	if (!parsed.success) {
		return { success: false, mode: "git", output: "", message: parsed.message, phase: "validate" };
	}
	const target = resolveWorkspaceFilePath(req.workDir, parsed.target);
	if (!target) {
		return { success: false, mode: "git", output: "", message: "invalid clone target path", phase: "validate" };
	}
	if (Content.exist(target)) {
		return { success: false, mode: "git", output: "", message: "target already exists", phase: "validate" };
	}
	const targetParent = Path.getPath(target);
	if (!ensureDirPath(targetParent)) {
		return { success: false, mode: "git", output: "", message: "failed to create target parent directory" };
	}
	const tempRoot = getAgentDownloadTempRoot();
	if (!ensureDirPath(tempRoot)) {
		return { success: false, mode: "git", output: "", message: "failed to create agent download temp directory" };
	}
	const tempPath = Path(tempRoot, `${req.operationId}.repo`);
	Content.remove(tempPath);
	const depth = parsed.depth ?? "1";
	const command = [
		"clone",
		quoteGitArg(parsed.url),
		quoteGitArg(Path.getFilename(tempPath)),
		...(parsed.ref !== undefined && parsed.ref !== "" ? ["-b", quoteGitArg(parsed.ref)] : []),
		...(depth !== "" ? ["--depth", quoteGitArg(depth)] : []),
	].join(" ");
	req.onProgress?.({
		state: "pending",
		mode: "git",
		operationId: req.operationId,
		stage: "clone",
		message: "clone pending",
		progress: 0,
	});
	const gitRes = await runGitAndWait(
		tempRoot,
		command,
		status => emitGitProgress("git", req.operationId, req.onProgress, status),
		() => req.isCancelled?.() === true,
		req.timeoutSeconds,
	);
	if (!gitRes.success) {
		const cleanupError = cleanupPath(tempPath);
		return {
			success: false,
			mode: "git",
			output: formatGitStatusOutput(gitRes.status),
			message: gitRes.message ?? "git clone failed",
			interrupted: gitRes.interrupted || req.isCancelled?.() === true,
			cleanupError,
		};
	}
	if (!Content.move(tempPath, target)) {
		const cleanupError = cleanupPath(tempPath);
		return { success: false, mode: "git", output: formatGitStatusOutput(gitRes.status), message: "failed to move cloned repository into target path", cleanupError };
	}
	if (!refreshProjectTree(req.workDir)) {
		Log("Warn", `[execute_command] failed to refresh Web IDE tree after clone target=${target}`);
	}
	const commit = getGitHeadCommit(target);
	const output = [
		formatGitStatusOutput(gitRes.status),
		`cloned ${parsed.url} to ${parsed.target}`,
		commit !== undefined ? `commit ${commit}` : "",
	].filter(item => item !== "").join("\n");
	return { success: true, mode: "git", output: truncateCommandOutput(output) };
}

function loadGitProfile(): { name: string; email: string } | undefined {
	let rows: unknown[][] | undefined;
	try {
		rows = DB.query("select name, email from GitProfile where id = 1 limit 1") as unknown[][];
	} catch {
		return undefined;
	}
	if (!rows || !rows[0]) return undefined;
	const name = toStr(rows[0][0]);
	const email = toStr(rows[0][1]);
	if (name === "" && email === "") return undefined;
	return { name, email };
}

function applyGitProfileToCommit(command: string): string {
	const args = shellSplit(command);
	if (args[0] !== "commit") return command;
	let hasName = false;
	let hasEmail = false;
	for (const arg of args) {
		if (arg === "--author-name") hasName = true;
		if (arg === "--author-email") hasEmail = true;
	}
	if (hasName && hasEmail) return command;
	const profile = loadGitProfile();
	if (!profile) return command;
	const additions: string[] = [];
	if (!hasName && profile.name !== "") {
		additions.push("--author-name", quoteGitArg(profile.name));
	}
	if (!hasEmail && profile.email !== "") {
		additions.push("--author-email", quoteGitArg(profile.email));
	}
	if (additions.length === 0) return command;
	return `${command} ${additions.join(" ")}`;
}

async function executeGitCommand(req: {
	workDir: string;
	command: string;
	cwd?: string;
	timeoutSeconds: number;
	operationId: string;
	onProgress?: (progress: ExecuteCommandProgress) => void;
	isCancelled?: () => boolean;
}): Promise<ExecuteCommandResult> {
	let command = normalizeGitCommand(req.command ?? "");
	if (command === "") {
		return { success: false, mode: "git", output: "", message: "missing command", phase: "validate" };
	}
	const cloneResult = await cloneGitToTarget({
		workDir: req.workDir,
		command,
		operationId: req.operationId,
		timeoutSeconds: req.timeoutSeconds,
		onProgress: req.onProgress,
		isCancelled: req.isCancelled,
	});
	if (cloneResult !== undefined) return cloneResult;
	const cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd);
	if (!cwd.success) {
		return { success: false, mode: "git", output: "", cwd: req.cwd, message: cwd.message, phase: "validate" };
	}
	command = applyGitProfileToCommit(command);
	req.onProgress?.({
		state: "pending",
		mode: "git",
		operationId: req.operationId,
		stage: "git",
		message: "git command pending",
		progress: 0,
	});
	const gitRes = await runGitAndWait(
		cwd.path,
		command,
		status => emitGitProgress("git", req.operationId, req.onProgress, status),
		() => req.isCancelled?.() === true,
		req.timeoutSeconds,
	);
	const output = formatGitStatusOutput(gitRes.status);
	if (!gitRes.success) {
		return {
			success: false,
			mode: "git",
			output,
			cwd: cwd.relative,
			message: gitRes.message ?? "git command failed",
			interrupted: gitRes.interrupted || req.isCancelled?.() === true,
		};
	}
	return { success: true, mode: "git", cwd: cwd.relative, output };
}

export async function executeCommand(req: {
	workDir: string;
	mode: ExecuteCommandMode;
	code?: string;
	command?: string;
	cwd?: string;
	timeoutSeconds?: number;
	onProgress?: (progress: ExecuteCommandProgress) => void;
	isCancelled?: () => boolean;
}): Promise<ExecuteCommandResult> {
	const mode = req.mode;
	if (mode !== "lua" && mode !== "git") {
		return { success: false, message: "mode must be lua or git", phase: "validate" };
	}
	if (mode === "lua") {
		return executeLuaCommand({
			workDir: req.workDir,
			code: req.code ?? "",
			timeoutSeconds: math.max(1, math.floor(Number(req.timeoutSeconds ?? LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS))),
			operationId: createOperationId(),
			onProgress: req.onProgress,
			isCancelled: req.isCancelled,
		});
	}
	const operationId = createOperationId();
	return executeGitCommand({
		workDir: req.workDir,
		command: req.command ?? "",
		cwd: req.cwd,
		timeoutSeconds: math.max(1, math.floor(Number(req.timeoutSeconds ?? 600))),
		operationId,
		onProgress: req.onProgress,
		isCancelled: req.isCancelled,
	});
}

export async function fetchUrl(req: {
	workDir: string;
	url: string;
	target: string;
	onProgress?: (progress: FetchUrlProgress) => void;
	isCancelled?: () => boolean;
}): Promise<FetchUrlResult> {
	const mode: FetchUrlMode = "download";
	const url = (req.url ?? "").trim();
	const targetRel = (req.target ?? "").trim();
	if (!isHttpUrl(url)) {
		return { success: false, state: "failed", mode, target: targetRel, message: "fetch_url only supports http:// and https:// URLs" };
	}
	if (targetRel === "") {
		return { success: false, state: "failed", mode, message: "missing target" };
	}
	const target = resolveWorkspaceFilePath(req.workDir, targetRel);
	if (!target) {
		return { success: false, state: "failed", mode, target: targetRel, message: "invalid target path" };
	}
	if (Content.exist(target)) {
		return { success: false, state: "failed", mode, target: targetRel, message: "target already exists" };
	}
	const operationId = createOperationId();
	const tempRoot = getAgentDownloadTempRoot();
	if (!ensureDirPath(tempRoot)) {
		return { success: false, state: "failed", mode, target: targetRel, message: "failed to create agent download temp directory" };
	}
	const tempPath = Path(tempRoot, `${operationId}.download`);
	Content.remove(tempPath);
	const emitProgress = (progress: Partial<FetchUrlProgress>) => {
		if (!req.onProgress) return;
		req.onProgress({
			state: "running",
			mode,
			operationId,
			target: targetRel,
			tempPath,
			...progress,
		});
	};
	emitProgress({
		state: "pending",
		message: "download pending",
		stage: "download",
	});
	const interrupted = () => req.isCancelled?.() === true;
	if (!ensureDirForFile(tempPath)) {
		return { success: false, state: "failed", mode, target: targetRel, message: "failed to create temporary file directory" };
	}
	const downloadRes = await downloadFile({
		url,
		tempPath,
		timeout: 600,
		isCancelled: interrupted,
		onProgress: (current, total) => {
			const totalNumber = typeof total === "number" ? total : 0;
			emitProgress({
				stage: "download",
				message: "downloading",
				current,
				total,
				progress: totalNumber > 0 ? current / totalNumber : undefined,
			});
		},
	});
	if (!downloadRes.success) {
		const cleanupError = cleanupPath(tempPath);
		return {
			success: false,
			state: "failed",
			mode,
			target: targetRel,
			message: interrupted() ? "download canceled" : (downloadRes.message ?? "download failed"),
			interrupted: downloadRes.interrupted || interrupted(),
			cleanupError,
		};
	}
	if (!ensureDirForFile(target)) {
		const cleanupError = cleanupPath(tempPath);
		return { success: false, state: "failed", mode, target: targetRel, message: "failed to create target directory", cleanupError };
	}
	if (!Content.move(tempPath, target)) {
		const cleanupError = cleanupPath(tempPath);
		return { success: false, state: "failed", mode, target: targetRel, message: "failed to move downloaded file into target path", cleanupError };
	}
	let bytesWritten: number | undefined = downloadRes.bytesWritten;
	try {
		const [size] = Content.getAttr(target);
		if (bytesWritten === undefined || bytesWritten <= 0) {
			bytesWritten = typeof size === "number" ? size : undefined;
		}
	} catch (_) {
		// Keep the download callback byte count when Content attributes are unavailable.
	}
	if (bytesWritten === undefined || bytesWritten <= 0) {
		try {
			const loaded = Content.load(target);
			if (typeof loaded === "string") {
				bytesWritten = loaded.length;
			}
		} catch (_) {
			// Keep the stat result when the downloaded file cannot be loaded as text.
		}
	}
	if (!syncDownloadedFileToWebIDE(target)) {
		Log("Warn", `[fetch_url] failed to sync downloaded file update target=${target}`);
	}
	return { success: true, state: "done", mode, target: targetRel, bytesWritten };
}
