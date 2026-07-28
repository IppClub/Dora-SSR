// @preview-file off clear
import * as Dora from 'Dora';
import { Content, DB, Path, Director, once, SearchFilesResult, Node, emit, wait, App, HttpServer, HttpClient, Git } from 'Dora';
import type { SQL } from 'Dora';
import * as AgentConfig from 'Agent/AgentConfig';
import {
	TABLE_TASK,
	TABLE_CHECKPOINT as TABLE_CP,
	TABLE_CHECKPOINT_ENTRY as TABLE_ENTRY,
	requireAgentStorage,
} from 'Agent/AgentStorage';
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

export type DeleteFileResult = {
	success: true;
	taskId: number;
	checkpointed: true;
	reversible: true;
	binary: false;
	checkpointId: number;
	checkpointSeq: number;
} | {
	success: true;
	taskId: number;
	checkpointed: false;
	reversible: false;
	binary: true;
	message: string;
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

interface CheckpointEntryMetadataRow {
	id: number;
	ord: number;
	path: string;
	op: FileOp;
	beforeExists: boolean;
	afterExists: boolean;
	bytesBefore: number;
	bytesAfter: number;
}
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
		`SELECT id, ord, path, op, before_exists,
			dora_decompress_text(before_data),
			after_exists,
			dora_decompress_text(after_data)
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

function getCheckpointEntryMetadata(checkpointId: number, desc = false): CheckpointEntryMetadataRow[] {
	const rows = DB.query(
		`SELECT id, ord, path, op, before_exists, after_exists, bytes_before, bytes_after
		FROM ${TABLE_ENTRY}
		WHERE checkpoint_id = ?
		ORDER BY ord ${desc ? "DESC" : "ASC"}`,
		[checkpointId],
	);
	if (!rows) return [];
	const result: CheckpointEntryMetadataRow[] = [];
	for (let i = 0; i < rows.length; i++) {
		const row = rows[i];
		result.push({
			id: row[0] as number,
			ord: row[1] as number,
			path: toStr(row[2]),
			op: toStr(row[3]) as FileOp,
			beforeExists: toBool(row[4]),
			afterExists: toBool(row[5]),
			bytesBefore: (row[6] as number | undefined) ?? 0,
			bytesAfter: (row[7] as number | undefined) ?? 0,
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
	const storage = requireAgentStorage();
	if (!storage.success) return storage;
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

export function listCheckpointsForTasks(taskIds: number[]): CheckpointItem[] {
	const normalizedTaskIds: number[] = [];
	const seenTaskIds: Record<number, boolean> = {};
	for (let i = 0; i < taskIds.length; i++) {
		const taskId = math.floor(taskIds[i]);
		if (taskId <= 0 || seenTaskIds[taskId]) continue;
		seenTaskIds[taskId] = true;
		normalizedTaskIds.push(taskId);
	}
	if (normalizedTaskIds.length === 0) return [];
	const placeholders = normalizedTaskIds.map(() => "?").join(", ");
	const rows = DB.query(
		`SELECT id, task_id, seq, status, summary, tool_name, created_at
		FROM ${TABLE_CP}
		WHERE task_id IN (${placeholders})
		ORDER BY task_id DESC, seq DESC`,
		normalizedTaskIds,
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

export function listCheckpoints(taskId: number): CheckpointItem[] {
	return listCheckpointsForTasks([taskId]);
}

export function getCheckpoint(checkpointId: number): CheckpointItem | undefined {
	if (checkpointId <= 0) return undefined;
	const rows = DB.query(
		`SELECT id, task_id, seq, status, summary, tool_name, created_at
		FROM ${TABLE_CP}
		WHERE id = ?
		LIMIT 1`,
		[checkpointId],
	);
	if (!rows || rows.length === 0) return undefined;
	const row = rows[0];
	return {
		id: row[0] as number,
		taskId: row[1] as number,
		seq: row[2] as number,
		status: toStr(row[3]),
		summary: toStr(row[4]),
		toolName: toStr(row[5]),
		createdAt: row[6] as number,
	};
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
		const entries = getCheckpointEntryMetadata(checkpoint.id, false);
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
	const entryRows = DB.query(
		`SELECT e.id, e.path, e.before_exists, e.after_exists
		FROM ${TABLE_ENTRY} e
		JOIN ${TABLE_CP} c ON c.id = e.checkpoint_id
		WHERE c.task_id = ? AND c.status IN ('APPLIED', 'REVERTED')
		ORDER BY c.seq ASC, e.ord ASC`,
		[taskId],
	);
	if (!entryRows || entryRows.length === 0) {
		return { success: false, message: "change set not found or empty" };
	}
	const filesByPath: Record<string, {
		path: string;
		firstEntryId: number;
		lastEntryId: number;
		beforeExists: boolean;
		afterExists: boolean;
	}> = {};
	for (let i = 0; i < entryRows.length; i++) {
		const row = entryRows[i];
		const entryId = row[0] as number;
		const path = toStr(row[1]);
		let item = filesByPath[path];
		if (!item) {
			item = {
				path,
				firstEntryId: entryId,
				lastEntryId: entryId,
				beforeExists: toBool(row[2]),
				afterExists: toBool(row[3]),
			};
			filesByPath[path] = item;
		}
		item.lastEntryId = entryId;
		item.afterExists = toBool(row[3]);
	}
	const files: CheckpointDiffFile[] = [];
	for (const [, item] of pairs(filesByPath)) {
		const contentRows = DB.query(
			`SELECT
				(SELECT dora_decompress_text(before_data) FROM ${TABLE_ENTRY} WHERE id = ?),
				(SELECT dora_decompress_text(after_data) FROM ${TABLE_ENTRY} WHERE id = ?)`,
			[item.firstEntryId, item.lastEntryId],
		);
		if (!contentRows || contentRows.length === 0) {
			return { success: false, message: `failed to read checkpoint data for ${item.path}` };
		}
		files.push({
			path: item.path,
			op: deriveFileOp(item.beforeExists, item.afterExists),
			beforeExists: item.beforeExists,
			afterExists: item.afterExists,
			beforeContent: toStr(contentRows[0][0]),
			afterContent: toStr(contentRows[0][1]),
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
	const storage = requireAgentStorage();
	if (!storage.success) return storage;
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

	const preparedEntries: CheckpointEntryRow[] = [];
	for (let i = 0; i < expandedChanges.length; i++) {
		const change = expandedChanges[i];
		const fullPath = resolveWorkspaceFilePath(workDir, change.path);
		if (!fullPath) {
			return { success: false, message: `invalid path: ${change.path}` };
		}
		if (change.op === "delete" && Content.exist(fullPath) && Content.isdir(fullPath)) {
			return { success: false, message: `delete_file only supports files, not directories: ${change.path}` };
		}
		const before = getFileState(fullPath);
		const afterExists = change.op !== "delete";
		const afterContent = afterExists ? (change.content ?? "") : "";
		preparedEntries.push({
			id: 0,
			ord: i + 1,
			path: change.path,
			op: change.op,
			beforeExists: before.exists,
			beforeContent: before.content,
			afterExists,
			afterContent,
		});
	}

	const checkpointId = insertCheckpoint(taskId, nextSeq, options.summary ?? "", options.toolName ?? "", "PREPARED");
	if (checkpointId <= 0) {
		return { success: false, message: "failed to create checkpoint" };
	}
	const entryRows: (number | string | boolean)[][] = [];
	for (let i = 0; i < preparedEntries.length; i++) {
		const entry = preparedEntries[i];
		entryRows.push([
			checkpointId,
			entry.ord,
			entry.path,
			entry.op,
			entry.beforeExists ? 1 : 0,
			entry.beforeContent,
			entry.afterExists ? 1 : 0,
			entry.afterContent,
			entry.beforeContent.length,
			entry.afterContent.length,
		]);
	}
	const entryInsert: SQL = [
		`INSERT INTO ${TABLE_ENTRY}(checkpoint_id, ord, path, op, before_exists, before_data, after_exists, after_data, bytes_before, bytes_after)
		VALUES(?, ?, ?, ?, ?, dora_compress_text(?), ?, dora_compress_text(?), ?, ?)`,
		entryRows,
	];
	if (!DB.transaction([entryInsert])) {
		DB.exec(`UPDATE ${TABLE_CP} SET status = ? WHERE id = ?`, ["FAILED", checkpointId]);
		return { success: false, message: "failed to insert checkpoint entries" };
	}

	let appliedCount = 0;
	for (const entry of preparedEntries) {
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

export function deleteFile(taskId: number, workDir: string, targetFile: string, options: ApplyChangesOptions = {}): DeleteFileResult {
	const storage = requireAgentStorage();
	if (!storage.success) return storage;
	if (!isValidWorkDir(workDir)) {
		return { success: false, message: "invalid workDir" };
	}
	if (!getTaskStatus(taskId)) {
		return { success: false, message: "task not found" };
	}
	if (!isValidWorkspacePath(targetFile)) {
		return { success: false, message: `invalid path: ${targetFile}` };
	}
	const fullPath = resolveWorkspaceFilePath(workDir, targetFile);
	if (!fullPath) {
		return { success: false, message: `invalid path: ${targetFile}` };
	}
	if (Content.exist(fullPath) && Content.isdir(fullPath)) {
		return { success: false, message: `delete_file only supports files, not directories: ${targetFile}` };
	}

	let isBinary = false;
	if (Content.exist(fullPath)) {
		try {
			const [, detectedBinary] = Content.getAttr(fullPath);
			isBinary = detectedBinary === true;
		} catch (e) {
			Log("Warn", `[Agent.Tools] Content.getAttr failed before deleting ${fullPath}: ${tostring(e)}`);
		}
	}
	if (!isBinary) {
		const result = applyFileChanges(taskId, workDir, [{ path: targetFile, op: "delete" }], options);
		if (!result.success) return result;
		return {
			...result,
			checkpointed: true,
			reversible: true,
			binary: false,
		};
	}

	if (!Content.remove(fullPath)) {
		return { success: false, message: `failed to delete binary file: ${targetFile}` };
	}
	if (!sendWebIDEFileUpdate(fullPath, false, "")) {
		sendWebIDERefreshTree();
	}
	return {
		success: true,
		taskId,
		checkpointed: false,
		reversible: false,
		binary: true,
		message: "Binary file deleted directly without a checkpoint; this deletion cannot be rolled back.",
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
	let entryObjectBaseline = 0;
	let entryLuaRefBaseline = 0;
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
	const startEntryWatchdog = () => {
		entryObjectBaseline = Dora.Object.count;
		entryLuaRefBaseline = Dora.Object.luaRefCount;
	};
	const checkEntryWatchdog = (): string | undefined => {
		if (!ownsEntryRuntime) return undefined;
		const objectCount = Dora.Object.count;
		const luaRefCount = Dora.Object.luaRefCount;
		const objectGrowth = math.max(0, objectCount - entryObjectBaseline);
		const luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline);
		const exceededTotal =
			objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth ||
			luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth;
		if (!exceededTotal) return undefined;
		return `Entry watchdog stopped the test and cleaned up after abnormal object growth: ` +
			`live objects +${tostring(objectGrowth)}, Lua references +${tostring(luaRefGrowth)}. ` +
			`Use a bounded test with a strict entity limit and only a few fixed simulation steps.`;
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
			startEntryWatchdog();
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
			const watchdogMessage = checkEntryWatchdog();
			if (watchdogMessage !== undefined) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: watchdogMessage,
					phase: "execute",
					interrupted: true,
				});
				return true;
			}
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
			const [previousHook, previousHookMask, previousHookCount] = debug.gethook();
			let frameTimedOut = false, watchdogMessage: string | undefined;
			_G["print"] = capturePrint;
			debug.sethook(() => {
				watchdogMessage ??= checkEntryWatchdog();
				if (watchdogMessage !== undefined) error(watchdogMessage);
				if (App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds) {
					frameTimedOut = true;
					error(`Lua command exceeded ${tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)} seconds in one game frame`);
				}
			}, "", AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount);
			const [ok, runtimeErr] = pcall(fn);
			if (previousHook !== undefined && previousHookMask !== undefined && previousHookCount !== undefined) {
				debug.sethook(
					previousHook as (event: "call" | "tail call" | "return" | "line" | "count", line?: number) => unknown,
					previousHookMask,
					previousHookCount,
				);
			} else {
				debug.sethook();
			}
			_G["print"] = previousGlobalPrint;
			if (!ok) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: watchdogMessage ?? (frameTimedOut ? `Lua command exceeded ${tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)} seconds in one game frame` : truncateCommandError(toStr(runtimeErr))),
					phase: frameTimedOut ? "timeout" : "execute",
					interrupted: watchdogMessage !== undefined || frameTimedOut ? true : undefined,
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

export type GenerateSfxProgress = {
	state: "pending" | "running";
	operationId: string;
	path: string;
	stage?: string;
	message?: string;
};

export type GenerateSfxResult = {
	success: true;
	path: string;
	bytesWritten: number;
	durationSeconds: number;
	sampleRate: number;
	seed: number;
	description: string;
} | {
	success: false;
	path?: string;
	message: string;
	interrupted?: boolean;
};

export type GenerateSfxPresetKind =
	| "jump"
	| "explosion"
	| "hit"
	| "pickup"
	| "laser"
	| "powerup"
	| "click"
	| "random";

const SFX_SAMPLE_RATE = 44100;
const SFX_MAX_SAMPLES = SFX_SAMPLE_RATE * 3;
const SFX_OVERSAMPLING = 8;
const SFX_NOISE_SIZE = 32;
const SFX_PHASER_SIZE = 1024;
const SFX_WAV_PACK_CHUNK = 1024;

interface SfxRng {
	next(): number;
}

/**
 * Park-Miller LCG. Math.random is not acceptable here: the same seed must
 * always reproduce the same sound, and ordinary double arithmetic keeps the
 * multiplication exact (state * 16807 stays below 2^53).
 */
function createSfxRng(seed: number): SfxRng {
	let state = math.floor(math.abs(seed)) % 2147483647;
	if (state <= 0) state = 1;
	return {
		next: (): number => {
			state = (state * 16807) % 2147483647;
			return (state - 1) / 2147483646;
		},
	};
}

interface SfxrParams {
	waveType: number;
	startFreq: number;
	minFreq: number;
	slide: number;
	deltaSlide: number;
	duty: number;
	dutySweep: number;
	vibDepth: number;
	vibSpeed: number;
	attack: number;
	sustain: number;
	decay: number;
	punch: number;
	changeAmount: number;
	changeSpeed: number;
	phaserOffset: number;
	phaserSweep: number;
	lpCutoff: number;
	lpCutoffSweep: number;
	lpResonance: number;
	hpCutoff: number;
	hpCutoffSweep: number;
	repeatSpeed: number;
}

function resetSfxrParams(): SfxrParams {
	return {
		waveType: 0,
		startFreq: 0.3,
		minFreq: 0.0,
		slide: 0.0,
		deltaSlide: 0.0,
		duty: 0.0,
		dutySweep: 0.0,
		vibDepth: 0.0,
		vibSpeed: 0.0,
		attack: 0.0,
		sustain: 0.3,
		decay: 0.4,
		punch: 0.0,
		changeAmount: 0.0,
		changeSpeed: 0.0,
		phaserOffset: 0.0,
		phaserSweep: 0.0,
		lpCutoff: 1.0,
		lpCutoffSweep: 0.0,
		lpResonance: 0.0,
		hpCutoff: 0.0,
		hpCutoffSweep: 0.0,
		repeatSpeed: 0.0,
	};
}

/**
 * Preset generators ported from the classic sfxr/as3sfxr randomizers.
 * Parameter names map: changeAmount = arp_mod, changeSpeed = arp_speed.
 */
function generateSfxrPreset(kind: GenerateSfxPresetKind, rng: SfxRng): SfxrParams {
	const rnd = (): number => rng.next();
	const frnd = (range: number): number => rnd() * range;
	const p = resetSfxrParams();
	switch (kind) {
		case "pickup": {
			p.waveType = math.floor(rnd() * 3);
			p.startFreq = 0.4 + frnd(0.5);
			p.attack = 0.0;
			p.sustain = frnd(0.1);
			p.decay = 0.1 + frnd(0.4);
			p.punch = 0.3 + frnd(0.3);
			if (rnd() < 0.5) {
				p.changeSpeed = 0.5 + frnd(0.2);
				p.changeAmount = 0.2 + frnd(0.4);
			}
			break;
		}
		case "laser": {
			p.waveType = math.floor(rnd() * 3);
			if (p.waveType === 2 && rnd() < 0.5) p.waveType = math.floor(rnd() * 2);
			p.startFreq = 0.5 + frnd(0.5);
			p.minFreq = p.startFreq - 0.2 - frnd(0.6);
			if (p.minFreq < 0.2) p.minFreq = 0.2;
			p.slide = -0.15 - frnd(0.2);
			if (rnd() < 0.33) {
				p.startFreq = 0.3 + frnd(0.6);
				p.minFreq = frnd(0.1);
				p.slide = -0.35 - frnd(0.3);
			}
			if (rnd() < 0.5) {
				p.duty = frnd(0.5);
				p.dutySweep = frnd(0.2);
			} else {
				p.duty = 0.4 + frnd(0.5);
				p.dutySweep = -frnd(0.7);
			}
			p.attack = 0.0;
			p.sustain = 0.1 + frnd(0.2);
			p.decay = frnd(0.4);
			if (rnd() < 0.5) p.punch = frnd(0.3);
			if (rnd() < 0.33) {
				p.phaserOffset = frnd(0.2);
				p.phaserSweep = -frnd(0.2);
			}
			if (rnd() < 0.5) p.hpCutoff = frnd(0.3);
			break;
		}
		case "explosion": {
			p.waveType = 3;
			p.startFreq = 0.1 + frnd(0.4);
			p.slide = -0.1 + frnd(0.4);
			p.attack = 0.0;
			p.sustain = 0.1 + frnd(0.2);
			p.decay = frnd(0.5);
			if (rnd() < 0.5) {
				p.phaserOffset = -0.3 + frnd(0.9);
				p.phaserSweep = -frnd(0.3);
			}
			if (rnd() < 0.33) {
				p.startFreq = 0.2 + frnd(0.7);
				p.slide = -0.2 - frnd(0.2);
			}
			if (rnd() < 0.5) p.punch = 0.2 + frnd(0.6);
			break;
		}
		case "powerup": {
			p.waveType = rnd() < 0.5 ? 0 : 1;
			p.startFreq = 0.2 + frnd(0.3);
			p.slide = 0.1 + frnd(0.2);
			p.changeAmount = 0.2 + frnd(0.4);
			p.changeSpeed = 0.6 + frnd(0.3);
			p.attack = 0.0;
			p.sustain = 0.2 + frnd(0.3);
			p.decay = frnd(0.2);
			p.punch = 0.2 + frnd(0.4);
			break;
		}
		case "hit": {
			p.waveType = math.floor(rnd() * 3);
			if (p.waveType === 2) p.waveType = 3;
			p.startFreq = 0.2 + frnd(0.6);
			p.slide = -0.3 - frnd(0.4);
			p.attack = 0.0;
			p.sustain = frnd(0.1);
			p.decay = 0.1 + frnd(0.2);
			if (rnd() < 0.5) p.hpCutoff = frnd(0.3);
			break;
		}
		case "jump": {
			p.waveType = 0;
			p.startFreq = 0.3 + frnd(0.3);
			p.slide = 0.1 + frnd(0.2);
			p.attack = 0.0;
			p.sustain = 0.1 + frnd(0.3);
			p.decay = 0.1 + frnd(0.2);
			if (rnd() < 0.5) {
				p.duty = frnd(0.6);
				p.dutySweep = frnd(0.2);
			}
			break;
		}
		case "click": {
			p.waveType = math.floor(rnd() * 2);
			p.startFreq = 0.2 + frnd(0.4);
			p.attack = 0.0;
			p.sustain = 0.05 + frnd(0.05);
			p.decay = 0.05 + frnd(0.15);
			p.hpCutoff = 0.1;
			break;
		}
		default: {
			const families: GenerateSfxPresetKind[] = ["jump", "explosion", "hit", "pickup", "laser", "powerup", "click"];
			return generateSfxrPreset(families[math.floor(rnd() * families.length)], rng);
		}
	}
	return p;
}

/**
 * Synthesize float samples in [-1, 1] from sfxr parameters. Port of the
 * classic sfxr sample generator: frequency slide, arpeggio, vibrato, square
 * duty sweep, ADSR envelope with punch, one-pole low/high pass filters, and a
 * phaser tap. Length is bounded by the envelope plus SFX_MAX_SAMPLES.
 */
function synthSfxr(p: SfxrParams, masterVolume: number, rng: SfxRng): number[] {
	const samples: number[] = [];
	const startPeriod = 100.0 / (p.startFreq * p.startFreq + 0.001);
	let fperiod = startPeriod;
	let period = math.floor(fperiod);
	const fmaxperiod = 100.0 / (p.minFreq * p.minFreq + 0.001);
	const startSlide = 1.0 - (p.slide ** 3.0) * 0.01;
	let fslide = startSlide;
	const fdslide = -(p.deltaSlide ** 3.0) * 0.000001;
	let squareDuty = 0.5 - p.duty * 0.5;
	const squareSlide = -p.dutySweep * 0.00005;
	const arpMod = p.changeAmount >= 0.0
		? 1.0 - (p.changeAmount ** 2.0) * 0.9
		: 1.0 + (p.changeAmount ** 2.0) * 10.0;
	let arpTime = 0;
	let arpLimit = math.floor(((1.0 - p.changeSpeed) ** 2.0) * 20000.0) + 32;
	if (p.changeSpeed >= 1.0) arpLimit = 0;
	let envStage = 0;
	let envTime = 0;
	const envLength = [
		math.max(1, math.floor(p.attack * p.attack * 100000.0)),
		math.max(1, math.floor(p.sustain * p.sustain * 100000.0)),
		math.max(1, math.floor(p.decay * p.decay * 100000.0)),
	];
	const phaserBuffer: number[] = [];
	for (let i = 0; i < SFX_PHASER_SIZE; i++) phaserBuffer.push(0);
	let fphase = (p.phaserOffset ** 2.0) * 1020.0;
	if (p.phaserOffset < 0.0) fphase = -fphase;
	const fdsweep = (p.phaserSweep ** 2.0) * (p.phaserSweep < 0.0 ? -1.0 : 1.0);
	let iphase = math.floor(math.abs(fphase));
	if (iphase > SFX_PHASER_SIZE - 1) iphase = SFX_PHASER_SIZE - 1;
	let ipp = 0;
	const phaserOn = p.phaserOffset !== 0.0 || p.phaserSweep !== 0.0;
	const noiseBuffer: number[] = [];
	for (let i = 0; i < SFX_NOISE_SIZE; i++) noiseBuffer.push(rng.next() * 2.0 - 1.0);
	let fltp = 0.0;
	let fltdp = 0.0;
	let fltw = (p.lpCutoff ** 3.0) * 0.1;
	const fltwD = 1.0 + p.lpCutoffSweep * 0.0001;
	const fltdmp = (5.0 / (1.0 + (p.lpResonance ** 2.0) * 20.0)) * (0.01 + fltw);
	let fltphp = 0.0;
	let flthp = (p.hpCutoff ** 2.0) * 0.1;
	const flthpD = 1.0 + p.hpCutoffSweep * 0.0003;
	let vibPhase = 0.0;
	const vibSpeed = (p.vibSpeed ** 2.0) * 0.01;
	const vibAmp = p.vibDepth * 0.5;
	let repeatTime = 0;
	const repeatLimit = p.repeatSpeed > 0.0
		? math.floor(((1.0 - p.repeatSpeed) ** 2.0) * 20000.0) + 32
		: 0;
	let phase = 0;
	let finished = false;
	while (!finished && samples.length < SFX_MAX_SAMPLES) {
		repeatTime++;
		if (repeatLimit > 0 && repeatTime >= repeatLimit) {
			repeatTime = 0;
			fperiod = startPeriod;
			fslide = startSlide;
		}
		arpTime++;
		if (arpLimit > 0 && arpTime >= arpLimit) {
			arpLimit = 0;
			fperiod *= arpMod;
		}
		fslide += fdslide;
		fperiod *= fslide;
		if (fperiod > fmaxperiod) {
			fperiod = fmaxperiod;
			if (p.minFreq > 0.0) finished = true;
		}
		let rfperiod = fperiod;
		if (vibAmp > 0.0) {
			vibPhase += vibSpeed;
			rfperiod = fperiod * (1.0 + math.sin(vibPhase) * vibAmp);
		}
		period = math.floor(rfperiod);
		if (period < SFX_OVERSAMPLING) period = SFX_OVERSAMPLING;
		squareDuty += squareSlide;
		if (squareDuty < 0.0) squareDuty = 0.0;
		if (squareDuty > 0.5) squareDuty = 0.5;
		envTime++;
		if (envStage === 0 && envTime >= envLength[0]) {
			envStage = 1;
			envTime = 0;
		} else if (envStage === 1 && envTime >= envLength[1]) {
			envStage = 2;
			envTime = 0;
		} else if (envStage === 2 && envTime >= envLength[2]) {
			finished = true;
		}
		let envVol = 0.0;
		if (envStage === 0) envVol = envTime / envLength[0];
		else if (envStage === 1) envVol = 1.0 + (1.0 - envTime / envLength[1]) * 2.0 * p.punch;
		else envVol = 1.0 - envTime / envLength[2];
		fphase += fdsweep;
		iphase = math.floor(math.abs(fphase));
		if (iphase > SFX_PHASER_SIZE - 1) iphase = SFX_PHASER_SIZE - 1;
		flthp *= flthpD;
		if (flthp < 0.0) flthp = 0.0;
		if (flthp > 0.1) flthp = 0.1;
		let sample = 0.0;
		for (let subSampleIndex = 0; subSampleIndex < SFX_OVERSAMPLING; subSampleIndex++) {
			phase++;
			if (phase >= period) {
				phase = phase % period;
				if (p.waveType === 3) {
					for (let i = 0; i < SFX_NOISE_SIZE; i++) noiseBuffer[i] = rng.next() * 2.0 - 1.0;
				}
			}
			const cyclePos = phase / period;
			let subSample = 0.0;
			if (p.waveType === 0) subSample = cyclePos < squareDuty ? 0.5 : -0.5;
			else if (p.waveType === 1) subSample = 1.0 - cyclePos * 2.0;
			else if (p.waveType === 2) subSample = math.sin(cyclePos * 2.0 * math.pi);
			else subSample = noiseBuffer[math.floor(cyclePos * SFX_NOISE_SIZE)];
			const prevFltp = fltp;
			fltw *= fltwD;
			if (fltw < 0.0) fltw = 0.0;
			if (fltw > 0.1) fltw = 0.1;
			if (p.lpCutoff >= 1.0) {
				fltp = subSample;
				fltdp = 0.0;
			} else {
				fltdp += (subSample - fltp) * fltw;
				fltdp -= fltdp * fltdmp;
				fltp += fltdp;
			}
			fltphp += fltp - prevFltp;
			fltphp -= fltphp * flthp;
			subSample = fltphp;
			if (phaserOn) {
				phaserBuffer[ipp] = subSample;
				subSample += phaserBuffer[(ipp - iphase + SFX_PHASER_SIZE) % SFX_PHASER_SIZE];
				ipp = (ipp + 1) % SFX_PHASER_SIZE;
			}
			sample += subSample * envVol;
		}
		sample = sample / SFX_OVERSAMPLING;
		if (sample > 1.0) sample = 1.0;
		if (sample < -1.0) sample = -1.0;
		samples.push(sample * masterVolume);
	}
	return samples;
}

function encodePcmWav(samples: number[], sampleRate: number, rightSamples?: number[]): string {
	const channels = rightSamples ? 2 : 1;
	const dataSize = samples.length * channels * 2;
	const parts: string[] = [];
	parts.push(string.pack("<c4I4c4", "RIFF", 36 + dataSize, "WAVE"));
	parts.push(string.pack("<c4I4I2I2I4I4I2I2", "fmt ", 16, 1, channels, sampleRate, sampleRate * channels * 2, channels * 2, 16));
	parts.push(string.pack("<c4I4", "data", dataSize));
	for (let start = 0; start < samples.length; start += SFX_WAV_PACK_CHUNK) {
		const end = math.min(start + SFX_WAV_PACK_CHUNK, samples.length);
		let fmt = "<";
		const values: number[] = [];
		for (let i = start; i < end; i++) {
			fmt += "i2";
			const left = samples[i];
			const leftRaw = left >= 0.0 ? math.floor(left * 32767.0 + 0.5) : math.ceil(left * 32768.0 - 0.5);
			values.push(math.max(-32768, math.min(32767, leftRaw)));
			if (rightSamples) {
				fmt += "i2";
				const right = rightSamples[i];
				const rightRaw = right >= 0.0 ? math.floor(right * 32767.0 + 0.5) : math.ceil(right * 32768.0 - 0.5);
				values.push(math.max(-32768, math.min(32767, rightRaw)));
			}
		}
		parts.push(string.pack(fmt, ...values));
	}
	return parts.join("");
}

let sfxAutoSeedStep = 0;

export async function generateSfx(req: {
	workDir: string;
	path: string;
	type: string;
	seed?: number;
	volume?: number;
	onProgress?: (progress: GenerateSfxProgress) => void;
	isCancelled?: () => boolean;
}): Promise<GenerateSfxResult> {
	const relPath = (req.path ?? "").trim();
	if (relPath === "") {
		return { success: false, message: "missing path" };
	}
	if (!relPath.toLowerCase().endsWith(".wav")) {
		return { success: false, path: relPath, message: "generate_sfx writes WAV files; path must end in .wav" };
	}
	const kind = (req.type ?? "").trim().toLowerCase() as GenerateSfxPresetKind;
	const validKinds: string[] = ["jump", "explosion", "hit", "pickup", "laser", "powerup", "click", "random"];
	if (validKinds.indexOf(kind) < 0) {
		return { success: false, path: relPath, message: `unknown type '${req.type}'; expected one of: ${validKinds.join(", ")}` };
	}
	const target = resolveWorkspaceFilePath(req.workDir, relPath);
	if (!target) {
		return { success: false, path: relPath, message: "invalid path" };
	}
	if (Content.exist(target) && Content.isdir(target)) {
		return { success: false, path: relPath, message: "target path is a directory" };
	}
	if (req.isCancelled?.() === true) {
		return { success: false, path: relPath, message: "canceled", interrupted: true };
	}
	sfxAutoSeedStep += 1;
	let seed = 0;
	if (typeof req.seed === "number" && req.seed === req.seed && math.abs(req.seed) < 2147483647) {
		seed = math.floor(req.seed);
	} else {
		seed = (os.time() % 1000000000) + sfxAutoSeedStep * 7919;
	}
	let volume = 0.8;
	if (typeof req.volume === "number" && req.volume === req.volume) {
		volume = math.min(1.0, math.max(0.0, req.volume));
	}
	const operationId = createOperationId();
	const rng = createSfxRng(seed);
	let presetKind = kind;
	if (presetKind === "random") {
		const families: GenerateSfxPresetKind[] = ["jump", "explosion", "hit", "pickup", "laser", "powerup", "click"];
		presetKind = families[math.floor(rng.next() * families.length)];
	}
	req.onProgress?.({
		state: "running",
		operationId,
		path: relPath,
		stage: "synth",
		message: `synthesizing ${presetKind}`,
	});
	const params = generateSfxrPreset(presetKind, rng);
	const samples = synthSfxr(params, volume, rng);
	if (samples.length === 0) {
		return { success: false, path: relPath, message: "synthesis produced no samples" };
	}
	if (req.isCancelled?.() === true) {
		return { success: false, path: relPath, message: "canceled", interrupted: true };
	}
	req.onProgress?.({
		state: "running",
		operationId,
		path: relPath,
		stage: "write",
		message: "writing WAV",
	});
	const wav = encodePcmWav(samples, SFX_SAMPLE_RATE);
	if (!ensureDirForFile(target)) {
		return { success: false, path: relPath, message: "failed to create target directory" };
	}
	if (!Content.save(target, wav)) {
		return { success: false, path: relPath, message: "failed to write WAV file" };
	}
	if (!syncDownloadedFileToWebIDE(target)) {
		Log("Warn", `[generate_sfx] failed to sync file update target=${target}`);
	}
	const durationSeconds = math.floor((samples.length / SFX_SAMPLE_RATE) * 100.0 + 0.5) / 100.0;
	Log("Info", `[generate_sfx] type=${presetKind} seed=${seed} path=${relPath} bytes=${wav.length} samples=${samples.length}`);
	return {
		success: true,
		path: relPath,
		bytesWritten: wav.length,
		durationSeconds,
		sampleRate: SFX_SAMPLE_RATE,
		seed,
		description: `Saved a ${presetKind} sound effect to ${relPath} (${wav.length} bytes, ${durationSeconds}s, mono 16-bit ${SFX_SAMPLE_RATE} Hz, seed ${seed}). Play it with Audio.play("${relPath}") or an audio-source node; regenerate with a new seed or reproduce it with the same seed.`,
	};
}

export type GenerateMusicProgress = {
	state: "pending" | "running";
	operationId: string;
	path: string;
	stage?: string;
	message?: string;
	percent?: number;
};

export type GenerateMusicResult = {
	success: true;
	path: string;
	files: string[];
	projectPath: string;
	midiPath?: string;
	bytesWritten: number;
	durationSeconds: number;
	sampleRate: number;
	channels: number;
	seed: number;
	style: string;
	bpm: number;
	bars: number;
	key: string;
	mode: string;
	description: string;
} | {
	success: false;
	path?: string;
	message: string;
	interrupted?: boolean;
};

export type GenerateMusicStyle = "chiptune" | "adventure" | "calm" | "tense" | "victory" | "random";
type MusicMode = "major" | "minor" | "pentatonic" | "harmonic_minor" | "dorian" | "phrygian" | "chromatic";
type MusicInstrument = "square" | "pulse" | "saw" | "triangle" | "sine" | "organ" | "bell" | "pluck" | "fm" | "pad" | "sub" | "guitar" | "strings";
type MusicStinger = "none" | "victory" | "failure" | "both";
type MusicRenderKind = "loop" | "intro" | "outro" | "stinger";

interface MusicStyleConfig {
	bpm: number;
	mode: MusicMode;
	progression: number[];
	melodyStepSpan: number;
	melodyDensity: number;
	leadInstrument: MusicInstrument;
	bassInstrument: MusicInstrument;
	harmonyInstrument: MusicInstrument;
	melodyMix: number;
	bassMix: number;
	harmonyMix: number;
	drumMix: number;
	hatStride: number;
	reverb: number;
	delay: number;
	chorus: number;
	distortion: number;
}

interface MusicResolvedOptions {
	style: Exclude<GenerateMusicStyle, "random">;
	seed: number;
	bpm: number;
	bars: number;
	duration: number;
	volume: number;
	intensity: number;
	rootPitchClass: number;
	key: string;
	mode: MusicMode;
	progression: number[];
	progressionText: string;
	structure: string[];
	barsPerSection: number;
	melodyComplexity: number;
	rhythmComplexity: number;
	variation: number;
	leadInstrument: MusicInstrument;
	bassInstrument: MusicInstrument;
	harmonyInstrument: MusicInstrument;
	stereo: boolean;
	reverb: number;
	delay: number;
	chorus: number;
	distortion: number;
	bitCrush: number;
	lowPass: number;
	stems: boolean;
	introBars: number;
	outroBars: number;
	stinger: MusicStinger;
	exportMidi: boolean;
}

interface MusicArrangement {
	melodyNotes: number[];
	melodyAges: number[];
	bassNotes: number[];
	bassAges: number[];
	arpNotes: number[];
	chordRoots: number[];
}

interface StereoSamples {
	left: number[];
	right?: number[];
}

interface MusicRender {
	mix: StereoSamples;
	peak: number;
	clippingSamples: number;
	stems?: {
		melody: StereoSamples;
		bass: StereoSamples;
		harmony: StereoSamples;
		drums: StereoSamples;
	};
}

const MUSIC_SAMPLE_RATE = 44100;
const MUSIC_STEPS_PER_BAR = 16;
const MUSIC_MIN_SECONDS = 4;
const MUSIC_MAX_SECONDS = 32;
const MUSIC_NOISE_SIZE = 2048;
const MUSIC_RENDER_CHUNK = 8192;
const MUSIC_KEY_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
const MUSIC_VALID_MODES: string[] = ["major", "minor", "pentatonic", "harmonic_minor", "dorian", "phrygian", "chromatic"];
const MUSIC_VALID_INSTRUMENTS: string[] = ["square", "pulse", "saw", "triangle", "sine", "organ", "bell", "pluck", "fm", "pad", "sub", "guitar", "strings"];

function clamp01(value: number): number {
	return math.min(1.0, math.max(0.0, value));
}

function getMusicStyleConfig(style: GenerateMusicStyle): MusicStyleConfig {
	switch (style) {
		case "adventure": return {
			bpm: 124, mode: "major", progression: [0, 3, 4, 0], melodyStepSpan: 2,
			melodyDensity: 0.82, leadInstrument: "strings", bassInstrument: "triangle", harmonyInstrument: "organ",
			melodyMix: 0.28, bassMix: 0.24, harmonyMix: 0.15, drumMix: 0.22, hatStride: 2,
			reverb: 0.16, delay: 0.10, chorus: 0.18, distortion: 0.04,
		};
		case "calm": return {
			bpm: 84, mode: "pentatonic", progression: [0, 4, 3, 4], melodyStepSpan: 4,
			melodyDensity: 0.72, leadInstrument: "bell", bassInstrument: "sub", harmonyInstrument: "pad",
			melodyMix: 0.30, bassMix: 0.20, harmonyMix: 0.18, drumMix: 0.10, hatStride: 4,
			reverb: 0.34, delay: 0.16, chorus: 0.28, distortion: 0.0,
		};
		case "tense": return {
			bpm: 152, mode: "minor", progression: [0, 5, 6, 4], melodyStepSpan: 2,
			melodyDensity: 0.88, leadInstrument: "saw", bassInstrument: "saw", harmonyInstrument: "pulse",
			melodyMix: 0.24, bassMix: 0.29, harmonyMix: 0.15, drumMix: 0.26, hatStride: 1,
			reverb: 0.10, delay: 0.08, chorus: 0.10, distortion: 0.20,
		};
		case "victory": return {
			bpm: 148, mode: "major", progression: [0, 3, 4, 0], melodyStepSpan: 2,
			melodyDensity: 0.92, leadInstrument: "square", bassInstrument: "triangle", harmonyInstrument: "organ",
			melodyMix: 0.31, bassMix: 0.22, harmonyMix: 0.18, drumMix: 0.24, hatStride: 2,
			reverb: 0.22, delay: 0.12, chorus: 0.16, distortion: 0.04,
		};
		default: return {
			bpm: 138, mode: "major", progression: [0, 4, 5, 3], melodyStepSpan: 2,
			melodyDensity: 0.86, leadInstrument: "square", bassInstrument: "saw", harmonyInstrument: "pulse",
			melodyMix: 0.28, bassMix: 0.25, harmonyMix: 0.16, drumMix: 0.22, hatStride: 2,
			reverb: 0.10, delay: 0.08, chorus: 0.12, distortion: 0.06,
		};
	}
}

function musicScale(mode: MusicMode): number[] {
	if (mode === "minor") return [0, 2, 3, 5, 7, 8, 10];
	if (mode === "pentatonic") return [0, 2, 4, 7, 9];
	if (mode === "harmonic_minor") return [0, 2, 3, 5, 7, 8, 11];
	if (mode === "dorian") return [0, 2, 3, 5, 7, 9, 10];
	if (mode === "phrygian") return [0, 1, 3, 5, 7, 8, 10];
	if (mode === "chromatic") return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	return [0, 2, 4, 5, 7, 9, 11];
}

function musicScaleNote(root: number, scale: number[], degree: number): number {
	const octave = math.floor(degree / scale.length);
	const index = degree % scale.length;
	return root + octave * 12 + scale[index];
}

function parseRomanDegree(token: string): number | undefined {
	let normalized = token.trim();
	while (normalized.startsWith("b") || normalized.startsWith("#")) normalized = normalized.slice(1);
	normalized = normalized.toUpperCase();
	if (normalized === "I") return 0;
	if (normalized === "II") return 1;
	if (normalized === "III") return 2;
	if (normalized === "IV") return 3;
	if (normalized === "V") return 4;
	if (normalized === "VI") return 5;
	if (normalized === "VII") return 6;
	return undefined;
}

function parseMusicProgression(text: string | undefined, fallback: number[]): { degrees: number[]; text: string } {
	const normalized = (text ?? "").trim();
	if (normalized === "") return { degrees: fallback.slice(), text: fallback.map(value => tostring(value)).join(",") };
	const tokens = normalized.split(",");
	const degrees: number[] = [];
	for (let i = 0; i < tokens.length; i++) {
		const degree = parseRomanDegree(tokens[i]);
		if (degree === undefined) return { degrees: fallback.slice(), text: fallback.map(value => tostring(value)).join(",") };
		degrees.push(degree);
	}
	return degrees.length > 0 ? { degrees, text: normalized } : { degrees: fallback.slice(), text: fallback.map(value => tostring(value)).join(",") };
}

function parseMusicStructure(text: string | undefined): string[] {
	const tokens = (text ?? "A,A,B,A").split(",");
	const result: string[] = [];
	for (let i = 0; i < tokens.length && result.length < 8; i++) {
		const label = tokens[i].trim().toUpperCase();
		if (label !== "") result.push(label.slice(0, 8));
	}
	return result.length > 0 ? result : ["A"];
}

function resolveMusicInstrument(value: string | undefined, fallback: MusicInstrument): MusicInstrument {
	const normalized = (value ?? "auto").trim().toLowerCase();
	return MUSIC_VALID_INSTRUMENTS.indexOf(normalized) >= 0 ? normalized as MusicInstrument : fallback;
}

function fillMusicNote(notes: number[], ages: number[], start: number, span: number, note: number): void {
	const end = math.min(start + span, notes.length);
	for (let i = start; i < end; i++) {
		notes[i] = note;
		ages[i] = i - start;
	}
}

function sectionSeed(seed: number, label: string, barInSection: number, variation: number): number {
	let hash = 0;
	for (let i = 0; i < label.length; i++) hash = (hash * 31 + label.charCodeAt(i)) % 2147483647;
	return seed + hash * 131 + barInSection * 104729 + math.floor(variation * 10000.0) * 8191;
}

function createMusicArrangement(options: MusicResolvedOptions, bars: number, seedOffset = 0): MusicArrangement {
	const totalSteps = bars * MUSIC_STEPS_PER_BAR;
	const melodyNotes: number[] = [];
	const melodyAges: number[] = [];
	const bassNotes: number[] = [];
	const bassAges: number[] = [];
	const arpNotes: number[] = [];
	const chordRoots: number[] = [];
	const rootNote = 48 + options.rootPitchClass;
	for (let i = 0; i < totalSteps; i++) {
		melodyNotes.push(-1); melodyAges.push(0); bassNotes.push(-1); bassAges.push(0);
		arpNotes.push(-1); chordRoots.push(rootNote);
	}
	const scale = musicScale(options.mode);
	const styleConfig = getMusicStyleConfig(options.style);
	const chordToneChoices = [0, 2, 4, 7];
	const melodySpan = options.rhythmComplexity > 0.72 ? 1 : styleConfig.melodyStepSpan;
	const density = clamp01(styleConfig.melodyDensity * (0.55 + options.melodyComplexity * 0.65));
	for (let bar = 0; bar < bars; bar++) {
		const sectionIndex = math.floor(bar / options.barsPerSection) % options.structure.length;
		const sectionLabel = options.structure[sectionIndex];
		const barInSection = bar % options.barsPerSection;
		const localRng = createSfxRng(sectionSeed(options.seed + seedOffset, sectionLabel, barInSection, options.variation));
		const sectionOffset = math.max(0, sectionLabel.charCodeAt(0) - 65);
		const progressionIndex = (barInSection + sectionOffset) % options.progression.length;
		const chordDegree = options.progression[progressionIndex];
		const chordRoot = musicScaleNote(rootNote, scale, chordDegree);
		const barStart = bar * MUSIC_STEPS_PER_BAR;
		for (let localStep = 0; localStep < MUSIC_STEPS_PER_BAR; localStep++) {
			const step = barStart + localStep;
			chordRoots[step] = chordRoot;
			if (options.intensity > 0.25 || localStep % 2 === 0) {
				const arpTone = [0, 2, 4, 2][localStep % 4];
				arpNotes[step] = musicScaleNote(rootNote + 12, scale, chordDegree + arpTone);
			}
		}
		for (let localStep = 0; localStep < MUSIC_STEPS_PER_BAR; localStep += 4) {
			const step = barStart + localStep;
			const movingBass = options.intensity > 0.58 && localStep === 12;
			const bassDegree = chordDegree + (movingBass ? 4 : 0);
			fillMusicNote(bassNotes, bassAges, step, 4, musicScaleNote(rootNote - 12, scale, bassDegree));
		}
		for (let localStep = 0; localStep < MUSIC_STEPS_PER_BAR; localStep += melodySpan) {
			if (localRng.next() > density) continue;
			const step = barStart + localStep;
			let choice = chordToneChoices[math.floor(localRng.next() * chordToneChoices.length)];
			if (options.melodyComplexity > 0.65 && localRng.next() < options.melodyComplexity * 0.35) choice += 1;
			let note = musicScaleNote(rootNote + 12, scale, chordDegree + choice);
			if (localRng.next() < options.melodyComplexity * 0.30) note += 12;
			if (options.variation > 0.0 && sectionLabel !== "A" && localRng.next() < options.variation * 0.5) note += scale[1];
			fillMusicNote(melodyNotes, melodyAges, step, melodySpan, note);
		}
	}
	return { melodyNotes, melodyAges, bassNotes, bassAges, arpNotes, chordRoots };
}

function musicFrequency(note: number): number {
	return 440.0 * (2.0 ** ((note - 69) / 12.0));
}

function musicWave(phase: number, instrument: MusicInstrument): number {
	if (instrument === "square") return phase < 0.5 ? 0.7 : -0.7;
	if (instrument === "pulse") return phase < 0.25 ? 0.75 : -0.45;
	if (instrument === "saw") return 1.0 - phase * 2.0;
	if (instrument === "triangle" || instrument === "pluck") return phase < 0.5 ? phase * 4.0 - 1.0 : 3.0 - phase * 4.0;
	if (instrument === "organ") return math.sin(phase * 2.0 * math.pi) * 0.72 + math.sin(phase * 6.0 * math.pi) * 0.28;
	if (instrument === "bell") return math.sin(phase * 2.0 * math.pi) * 0.68 + math.sin(phase * 8.0 * math.pi) * 0.32;
	if (instrument === "fm") return math.sin(phase * 2.0 * math.pi + math.sin(phase * 6.0 * math.pi) * 2.2);
	if (instrument === "pad") return math.sin(phase * 2.0 * math.pi) * 0.65 + (phase < 0.5 ? phase * 4.0 - 1.0 : 3.0 - phase * 4.0) * 0.35;
	if (instrument === "sub") return math.sin(phase * 2.0 * math.pi) * 0.85 + math.sin(phase * 4.0 * math.pi) * 0.15;
	if (instrument === "guitar") return (phase < 0.5 ? phase * 4.0 - 1.0 : 3.0 - phase * 4.0) * 0.72 + math.sin(phase * 6.0 * math.pi) * 0.28;
	if (instrument === "strings") return (1.0 - phase * 2.0) * 0.55 + math.sin(phase * 2.0 * math.pi) * 0.45;
	return math.sin(phase * 2.0 * math.pi);
}

function musicEnvelope(time: number, length: number, attack: number, release: number, instrument?: MusicInstrument): number {
	if (time < 0.0 || time >= length) return 0.0;
	let value = 1.0;
	if (time < attack) value = time / attack;
	const remaining = length - time;
	if (remaining < release) value *= remaining / release;
	if (instrument === "pluck" || instrument === "bell" || instrument === "guitar") value *= 1.0 / (1.0 + time * (instrument === "bell" ? 3.5 : 8.0));
	return clamp01(value);
}

function createStereoSamples(stereo: boolean): StereoSamples {
	return stereo ? { left: [], right: [] } : { left: [] };
}

function pushStereo(samples: StereoSamples, left: number, right: number): void {
	if (samples.right) {
		samples.left.push(left);
		samples.right.push(right);
	} else {
		samples.left.push((left + right) * 0.5);
	}
}

function yieldMusicFrame(): Promise<void> {
	return new Promise<void>(resolve => {
		Director.systemScheduler.schedule(once(() => resolve()));
	});
}

async function synthMusic(
	options: MusicResolvedOptions,
	arrangement: MusicArrangement,
	bars: number,
	renderKind: MusicRenderKind,
	captureStems: boolean,
	onProgress?: (percent: number) => void,
	isCancelled?: () => boolean
): Promise<MusicRender | undefined> {
	const stepSeconds = 60.0 / options.bpm / 4.0;
	const durationSeconds = bars * MUSIC_STEPS_PER_BAR * stepSeconds;
	const totalSamples = math.floor(durationSeconds * MUSIC_SAMPLE_RATE);
	const mix = createStereoSamples(options.stereo);
	const stems = captureStems ? {
		melody: createStereoSamples(options.stereo), bass: createStereoSamples(options.stereo),
		harmony: createStereoSamples(options.stereo), drums: createStereoSamples(options.stereo),
	} : undefined;
	const noiseRng = createSfxRng(options.seed + bars * 65537 + (renderKind === "loop" ? 1 : 17));
	const noise: number[] = [];
	for (let i = 0; i < MUSIC_NOISE_SIZE; i++) noise.push(noiseRng.next() * 2.0 - 1.0);
	let melodyPhase = 0.0, bassPhase = 0.0, arpPhase = 0.0, padPhase = 0.0;
	let filteredLeft = 0.0, filteredRight = 0.0;
	let peak = 0.0, clippingSamples = 0;
	const fadeSamples = math.max(1, math.floor(MUSIC_SAMPLE_RATE * 0.008));
	const delayFrames = math.max(1, math.floor(MUSIC_SAMPLE_RATE * 60.0 / options.bpm * 0.5));
	const reverbFrames = math.max(1, math.floor(MUSIC_SAMPLE_RATE * 0.073));
	const delayLeft: number[] = [], delayRight: number[] = [], reverbLeft: number[] = [], reverbRight: number[] = [];
	for (let i = 0; i < delayFrames; i++) { delayLeft.push(0); delayRight.push(0); }
	for (let i = 0; i < reverbFrames; i++) { reverbLeft.push(0); reverbRight.push(0); }
	for (let sampleIndex = 0; sampleIndex < totalSamples; sampleIndex++) {
		if (sampleIndex % MUSIC_RENDER_CHUNK === 0) {
			if (isCancelled?.() === true) return undefined;
			onProgress?.(math.floor(sampleIndex / totalSamples * 100.0));
			if (sampleIndex > 0) await yieldMusicFrame();
		}
		const time = sampleIndex / MUSIC_SAMPLE_RATE;
		const stepFloat = time / stepSeconds;
		const stepIndex = math.min(arrangement.melodyNotes.length - 1, math.floor(stepFloat));
		const stepTime = (stepFloat - stepIndex) * stepSeconds;
		let melody = 0.0, bass = 0.0, harmony = 0.0, drums = 0.0;
		const melodyNote = arrangement.melodyNotes[stepIndex];
		if (melodyNote >= 0) {
			melodyPhase = (melodyPhase + musicFrequency(melodyNote) / MUSIC_SAMPLE_RATE) % 1.0;
			const noteTime = arrangement.melodyAges[stepIndex] * stepSeconds + stepTime;
			const span = options.rhythmComplexity > 0.72 ? 1 : getMusicStyleConfig(options.style).melodyStepSpan;
			const noteLength = span * stepSeconds * (0.72 + options.rhythmComplexity * 0.22);
			const env = musicEnvelope(noteTime, noteLength, 0.004, math.min(0.05, noteLength * 0.3), options.leadInstrument);
			melody = musicWave(melodyPhase, options.leadInstrument) * env * getMusicStyleConfig(options.style).melodyMix;
		}
		const bassNote = arrangement.bassNotes[stepIndex];
		if (bassNote >= 0) {
			bassPhase = (bassPhase + musicFrequency(bassNote) / MUSIC_SAMPLE_RATE) % 1.0;
			const noteTime = arrangement.bassAges[stepIndex] * stepSeconds + stepTime;
			const env = musicEnvelope(noteTime, stepSeconds * 3.75, 0.008, 0.08, options.bassInstrument);
			bass = musicWave(bassPhase, options.bassInstrument) * env * getMusicStyleConfig(options.style).bassMix;
		}
		const arpNote = arrangement.arpNotes[stepIndex];
		if (arpNote >= 0) {
			arpPhase = (arpPhase + musicFrequency(arpNote) / MUSIC_SAMPLE_RATE) % 1.0;
			const arpEnv = musicEnvelope(stepTime, stepSeconds * 0.72, 0.003, math.min(0.035, stepSeconds * 0.25), options.harmonyInstrument);
			harmony += musicWave(arpPhase, options.harmonyInstrument) * arpEnv * getMusicStyleConfig(options.style).harmonyMix;
		}
		const padNote = arrangement.chordRoots[stepIndex] + 12;
		padPhase = (padPhase + musicFrequency(padNote) / MUSIC_SAMPLE_RATE) % 1.0;
		harmony += musicWave(padPhase, options.harmonyInstrument) * (options.style === "calm" ? 0.10 : 0.035);
		const localStep = stepIndex % MUSIC_STEPS_PER_BAR;
		const noiseSample = noise[sampleIndex % MUSIC_NOISE_SIZE];
		const previousNoise = noise[(sampleIndex + MUSIC_NOISE_SIZE - 1) % MUSIC_NOISE_SIZE];
		const drumConfig = getMusicStyleConfig(options.style);
		const kickOn = options.intensity > 0.78 ? localStep % 4 === 0 : localStep === 0 || localStep === 8;
		let kickDecay = 0.0;
		if (kickOn) {
			const kickLength = math.min(stepSeconds, 0.16);
			if (stepTime < kickLength) {
				kickDecay = 1.0 - stepTime / kickLength;
				drums += math.sin(2.0 * math.pi * (58.0 + 82.0 * kickDecay) * stepTime) * kickDecay * kickDecay * drumConfig.drumMix;
			}
		}
		if (localStep === 4 || localStep === 12) {
			const snareLength = math.min(stepSeconds, 0.13);
			if (stepTime < snareLength) {
				const decay = 1.0 - stepTime / snareLength;
				drums += (noiseSample * 0.78 + math.sin(2.0 * math.pi * 180.0 * stepTime) * 0.22) * decay * drumConfig.drumMix * 0.68;
				if (options.intensity > 0.62) {
					const clapPhase = (stepTime * 38.0) % 1.0;
					drums += noiseSample * (clapPhase < 0.22 ? 1.0 : 0.0) * decay * drumConfig.drumMix * 0.24;
				}
			}
		}
		const hatStride = options.rhythmComplexity > 0.70 ? 1 : drumConfig.hatStride;
		if (localStep % hatStride === 0) {
			const hatLength = math.min(stepSeconds, 0.045);
			if (stepTime < hatLength) drums += (noiseSample - previousNoise) * (1.0 - stepTime / hatLength) * drumConfig.drumMix * 0.18;
		}
		if (localStep === 14 && options.intensity > 0.48) {
			const openHatLength = math.min(stepSeconds, 0.12);
			if (stepTime < openHatLength) drums += (noiseSample - previousNoise) * (1.0 - stepTime / openHatLength) * drumConfig.drumMix * 0.15;
		}
		if (localStep % 4 === 2 && options.intensity > 0.82) {
			const rideLength = math.min(stepSeconds, 0.08);
			if (stepTime < rideLength) drums += math.sin(2.0 * math.pi * 1800.0 * stepTime) * (1.0 - stepTime / rideLength) * drumConfig.drumMix * 0.09;
		}
		if (localStep >= 13 && options.rhythmComplexity > 0.68) {
			const tomLength = math.min(stepSeconds, 0.10);
			if (stepTime < tomLength) {
				const tomDecay = 1.0 - stepTime / tomLength;
				const tomFrequency = 150.0 - (localStep - 13) * 24.0;
				drums += math.sin(2.0 * math.pi * tomFrequency * stepTime) * tomDecay * drumConfig.drumMix * 0.26;
			}
		}
		const sectionStep = stepIndex % (options.barsPerSection * MUSIC_STEPS_PER_BAR);
		const sectionTime = sectionStep * stepSeconds + stepTime;
		if (sectionTime < 0.32 && options.intensity > 0.72) {
			drums += (noiseSample - previousNoise * 0.5) * (1.0 - sectionTime / 0.32) * drumConfig.drumMix * 0.16;
		}
		const duck = 1.0 - kickDecay * options.intensity * 0.24;
		melody *= duck * (0.72 + options.intensity * 0.42);
		bass *= 0.65 + options.intensity * 0.55;
		harmony *= duck * (0.50 + options.intensity * 0.62);
		drums *= 0.32 + options.intensity * 0.85;
		const chorusPan = math.sin(time * 2.0 * math.pi * 0.35) * options.chorus * 0.18;
		const melodyLeft = melody * (0.82 - chorusPan), melodyRight = melody * (1.18 + chorusPan);
		const bassLeft = bass, bassRight = bass;
		const harmonyLeft = harmony * (1.18 + chorusPan), harmonyRight = harmony * (0.82 - chorusPan);
		const drumsLeft = drums * 1.02, drumsRight = drums * 0.98;
		let left = melodyLeft + bassLeft + harmonyLeft + drumsLeft;
		let right = melodyRight + bassRight + harmonyRight + drumsRight;
		const delayPos = sampleIndex % delayFrames;
		const reverbPos = sampleIndex % reverbFrames;
		const delayedL = delayLeft[delayPos], delayedR = delayRight[delayPos];
		const reverbedL = reverbLeft[reverbPos], reverbedR = reverbRight[reverbPos];
		delayLeft[delayPos] = left + delayedR * 0.34;
		delayRight[delayPos] = right + delayedL * 0.34;
		reverbLeft[reverbPos] = left + reverbedR * 0.42;
		reverbRight[reverbPos] = right + reverbedL * 0.42;
		left += delayedL * options.delay + reverbedL * options.reverb * 0.45;
		right += delayedR * options.delay + reverbedR * options.reverb * 0.45;
		if (options.lowPass > 0.0) {
			const filterRate = 1.0 - options.lowPass * 0.94;
			filteredLeft += (left - filteredLeft) * filterRate;
			filteredRight += (right - filteredRight) * filterRate;
			left = filteredLeft;
			right = filteredRight;
		} else {
			filteredLeft = left;
			filteredRight = right;
		}
		const drive = 1.0 + options.distortion * 5.0;
		left = left * drive / (1.0 + math.abs(left) * drive * 0.58);
		right = right * drive / (1.0 + math.abs(right) * drive * 0.58);
		if (options.bitCrush > 0.0) {
			const bits = math.max(4, 16 - math.floor(options.bitCrush * 12.0));
			const levels = 2.0 ** (bits - 1);
			left = math.floor(left * levels + 0.5) / levels;
			right = math.floor(right * levels + 0.5) / levels;
		}
		let edgeFade = 1.0;
		if (sampleIndex < fadeSamples) edgeFade = sampleIndex / fadeSamples;
		if (sampleIndex >= totalSamples - fadeSamples) edgeFade = (totalSamples - 1 - sampleIndex) / fadeSamples;
		left *= options.volume * edgeFade * 0.72;
		right *= options.volume * edgeFade * 0.72;
		peak = math.max(peak, math.abs(left), math.abs(right));
		if (math.abs(left) > 1.0 || math.abs(right) > 1.0) clippingSamples++;
		left = math.max(-1.0, math.min(1.0, left));
		right = math.max(-1.0, math.min(1.0, right));
		pushStereo(mix, left, right);
		if (stems) {
			const stemGain = options.volume * edgeFade * 0.72;
			pushStereo(stems.melody, melodyLeft * stemGain, melodyRight * stemGain);
			pushStereo(stems.bass, bassLeft * stemGain, bassRight * stemGain);
			pushStereo(stems.harmony, harmonyLeft * stemGain, harmonyRight * stemGain);
			pushStereo(stems.drums, drumsLeft * stemGain, drumsRight * stemGain);
		}
	}
	onProgress?.(100);
	return { mix, peak, clippingSamples, stems };
}

function encodeMusicMidi(arrangement: MusicArrangement, options: MusicResolvedOptions): string {
	interface MidiEvent { tick: number; order: number; data: string; }
	const events: MidiEvent[] = [];
	const stepTicks = 120;
	const addNote = (tick: number, duration: number, channel: number, note: number, velocity: number) => {
		events.push({ tick, order: 1, data: string.char(0x90 + channel, note, velocity) });
		events.push({ tick: tick + duration, order: 0, data: string.char(0x80 + channel, note, 0) });
	};
	const addSustainedVoice = (notes: number[], ages: number[], channel: number, velocity: number) => {
		for (let step = 0; step < notes.length; step++) {
			if (notes[step] < 0 || ages[step] !== 0) continue;
			let span = 1;
			while (step + span < notes.length && notes[step + span] === notes[step] && ages[step + span] === span) span++;
			addNote(step * stepTicks, span * stepTicks, channel, notes[step], velocity);
		}
	};
	addSustainedVoice(arrangement.melodyNotes, arrangement.melodyAges, 0, 92);
	addSustainedVoice(arrangement.bassNotes, arrangement.bassAges, 1, 84);
	for (let step = 0; step < arrangement.arpNotes.length; step++) {
		if (arrangement.arpNotes[step] >= 0) addNote(step * stepTicks, math.floor(stepTicks * 0.72), 2, arrangement.arpNotes[step], 66);
		const localStep = step % MUSIC_STEPS_PER_BAR;
		if (localStep === 0 || localStep === 8) addNote(step * stepTicks, 60, 9, 36, 100);
		if (localStep === 4 || localStep === 12) {
			addNote(step * stepTicks, 60, 9, 38, 86);
			if (options.intensity > 0.62) addNote(step * stepTicks, 45, 9, 39, 62);
		}
		if (localStep % 2 === 0) addNote(step * stepTicks, 30, 9, 42, 54);
		if (localStep === 14 && options.intensity > 0.48) addNote(step * stepTicks, 90, 9, 46, 60);
		if (localStep % 4 === 2 && options.intensity > 0.82) addNote(step * stepTicks, 60, 9, 51, 48);
		if (localStep >= 13 && options.rhythmComplexity > 0.68) addNote(step * stepTicks, 70, 9, 45 - (localStep - 13) * 2, 70);
		if (step % (options.barsPerSection * MUSIC_STEPS_PER_BAR) === 0 && options.intensity > 0.72) addNote(step * stepTicks, 120, 9, 49, 72);
	}
	events.sort((a, b) => a.tick === b.tick ? a.order - b.order : a.tick - b.tick);
	const variableLength = (value: number): string => {
		const bytes: number[] = [value % 128];
		let rest = math.floor(value / 128);
		while (rest > 0) {
			bytes.push((rest % 128) + 128);
			rest = math.floor(rest / 128);
		}
		let result = "";
		for (let i = bytes.length - 1; i >= 0; i--) result += string.char(bytes[i]);
		return result;
	};
	const tempo = math.floor(60000000 / options.bpm);
	const parts: string[] = [string.char(0, 0xff, 0x51, 3, math.floor(tempo / 65536) % 256, math.floor(tempo / 256) % 256, tempo % 256)];
	parts.push(string.char(0, 0xff, 0x58, 4, 4, 2, 24, 8));
	let lastTick = 0;
	for (let i = 0; i < events.length; i++) {
		parts.push(variableLength(events[i].tick - lastTick) + events[i].data);
		lastTick = events[i].tick;
	}
	parts.push(string.char(0, 0xff, 0x2f, 0));
	const track = parts.join("");
	return string.pack(">c4I4I2I2I2", "MThd", 6, 0, 1, 480) + string.pack(">c4I4", "MTrk", track.length) + track;
}

function musicSiblingPath(path: string, suffix: string, extension = ".wav"): string {
	return path.slice(0, path.length - 4) + suffix + extension;
}

function saveGeneratedAsset(target: string, data: string, operationId: string): boolean {
	if (!ensureDirForFile(target)) return false;
	const temp = `${target}.${operationId}.tmp`;
	const backup = `${target}.${operationId}.bak`;
	Content.remove(temp);
	Content.remove(backup);
	if (!Content.save(temp, data)) return false;
	const hadTarget = Content.exist(target);
	if (hadTarget && !Content.move(target, backup)) {
		Content.remove(temp);
		return false;
	}
	if (!Content.move(temp, target)) {
		Content.remove(temp);
		if (hadTarget) Content.move(backup, target);
		return false;
	}
	Content.remove(backup);
	return true;
}

function musicFingerprint(options: MusicResolvedOptions): string {
	const raw = [
		options.style, tostring(options.seed), tostring(options.bpm), tostring(options.bars), tostring(options.volume),
		tostring(options.intensity), options.key, options.mode, options.progressionText, options.structure.join(","),
		tostring(options.barsPerSection), tostring(options.melodyComplexity), tostring(options.rhythmComplexity), tostring(options.variation),
		options.leadInstrument, options.bassInstrument, options.harmonyInstrument, tostring(options.stereo),
		tostring(options.reverb), tostring(options.delay), tostring(options.chorus), tostring(options.distortion), tostring(options.bitCrush),
		tostring(options.lowPass), tostring(options.stems), tostring(options.introBars), tostring(options.outroBars), options.stinger, tostring(options.exportMidi),
	].join("|");
	let hash = 2166136261;
	for (let i = 0; i < raw.length; i++) hash = (hash * 16777619 + raw.charCodeAt(i)) % 2147483647;
	return `music-v1-${math.floor(hash)}`;
}

function musicProjectObject(
	path: string,
	options: MusicResolvedOptions,
	files: string[],
	bytesWritten: number,
	durationSeconds: number,
	peak: number,
	clippingSamples: number,
	sourceProject?: string
): Record<string, unknown> {
	return {
		version: 1, generator: "Dora.CodingAgent.generate_music", fingerprint: musicFingerprint(options),
		path, files, bytesWritten, durationSeconds, peak, clippingSamples, sourceProject,
		params: {
			style: options.style, seed: options.seed, duration: options.duration, bpm: options.bpm, volume: options.volume,
			intensity: options.intensity, key: options.key, mode: options.mode, progression: options.progressionText,
			structure: options.structure.join(","), barsPerSection: options.barsPerSection,
			melodyComplexity: options.melodyComplexity, rhythmComplexity: options.rhythmComplexity, variation: options.variation,
			leadInstrument: options.leadInstrument, bassInstrument: options.bassInstrument, harmonyInstrument: options.harmonyInstrument,
			stereo: options.stereo, reverb: options.reverb, delay: options.delay, chorus: options.chorus,
			distortion: options.distortion, bitCrush: options.bitCrush, lowPass: options.lowPass, stems: options.stems,
			introBars: options.introBars, outroBars: options.outroBars, stinger: options.stinger, exportMidi: options.exportMidi,
		},
	};
}

function readCachedMusicResult(workDir: string, path: string, options: MusicResolvedOptions): GenerateMusicResult | undefined {
	const projectPath = musicSiblingPath(path, "", ".music.json");
	const target = resolveWorkspaceFilePath(workDir, path);
	const projectFull = resolveWorkspaceFilePath(workDir, projectPath);
	if (!target || !projectFull || !Content.exist(target) || !Content.exist(projectFull)) return undefined;
	const projectText = Content.load(projectFull);
	if (typeof projectText !== "string") return undefined;
	const [decoded] = safeJsonDecode(projectText);
	if (!decoded || type(decoded) !== "table") return undefined;
	const record = decoded as Record<string, unknown>;
	if (record.fingerprint !== musicFingerprint(options) || !Array.isArray(record.files)) return undefined;
	const files: string[] = [];
	for (let i = 0; i < record.files.length; i++) {
		if (typeof record.files[i] !== "string") return undefined;
		const relative = record.files[i] as string;
		const full = resolveWorkspaceFilePath(workDir, relative);
		if (!full || !Content.exist(full)) return undefined;
		files.push(relative);
	}
	if (files.indexOf(projectPath) < 0) files.push(projectPath);
	const durationSeconds = typeof record.durationSeconds === "number" ? record.durationSeconds : options.duration;
	const bytesWritten = typeof record.bytesWritten === "number" ? record.bytesWritten : 0;
	const midiPath = options.exportMidi ? musicSiblingPath(path, "", ".mid") : undefined;
	return {
		success: true, path, files, projectPath, midiPath, bytesWritten, durationSeconds,
		sampleRate: MUSIC_SAMPLE_RATE, channels: options.stereo ? 2 : 1, seed: options.seed,
		style: options.style, bpm: options.bpm, bars: options.bars, key: options.key, mode: options.mode,
		description: `Reused cached deterministic music assets for ${path} (${musicFingerprint(options)}).`,
	};
}

let musicAutoSeedStep = 0;

export async function generateMusic(req: {
	workDir: string; path: string; style: string; seed?: number; duration?: number; bpm?: number; volume?: number;
	intensity?: number; key?: string; mode?: string; progression?: string; structure?: string; barsPerSection?: number;
	melodyComplexity?: number; rhythmComplexity?: number; variation?: number;
	leadInstrument?: string; bassInstrument?: string; harmonyInstrument?: string;
	stereo?: boolean; reverb?: number; delay?: number; chorus?: number; distortion?: number; bitCrush?: number; lowPass?: number;
	stems?: boolean; introBars?: number; outroBars?: number; stinger?: string; exportMidi?: boolean;
	sourceProject?: string; onProgress?: (progress: GenerateMusicProgress) => void; isCancelled?: () => boolean;
}): Promise<GenerateMusicResult> {
	const relPath = (req.path ?? "").trim();
	if (relPath === "") return { success: false, message: "missing path" };
	if (!relPath.toLowerCase().endsWith(".wav")) return { success: false, path: relPath, message: "generate_music writes WAV files; path must end in .wav" };
	const requestedStyle = (req.style ?? "").trim().toLowerCase() as GenerateMusicStyle;
	const validStyles: string[] = ["chiptune", "adventure", "calm", "tense", "victory", "random"];
	if (validStyles.indexOf(requestedStyle) < 0) return { success: false, path: relPath, message: `unknown style '${req.style}'; expected one of: ${validStyles.join(", ")}` };
	const target = resolveWorkspaceFilePath(req.workDir, relPath);
	if (!target) return { success: false, path: relPath, message: "invalid path" };
	if (Content.exist(target) && Content.isdir(target)) return { success: false, path: relPath, message: "target path is a directory" };
	if (req.isCancelled?.() === true) return { success: false, path: relPath, message: "canceled", interrupted: true };
	musicAutoSeedStep += 1;
	let seed = typeof req.seed === "number" && req.seed === req.seed && math.abs(req.seed) < 2147483647
		? math.floor(req.seed) : (os.time() % 1000000000) + musicAutoSeedStep * 104729;
	const styleRng = createSfxRng(seed);
	let style = requestedStyle;
	if (style === "random") {
		const styles: GenerateMusicStyle[] = ["chiptune", "adventure", "calm", "tense", "victory"];
		style = styles[math.floor(styleRng.next() * styles.length)];
	}
	const styleConfig = getMusicStyleConfig(style);
	const bpm = typeof req.bpm === "number" && req.bpm === req.bpm ? math.floor(math.min(200, math.max(60, req.bpm))) : styleConfig.bpm;
	let requestedDuration = typeof req.duration === "number" && req.duration === req.duration ? req.duration : 16.0;
	requestedDuration = math.min(MUSIC_MAX_SECONDS, math.max(MUSIC_MIN_SECONDS, requestedDuration));
	const barSeconds = 240.0 / bpm;
	const minBars = math.max(1, math.ceil(MUSIC_MIN_SECONDS / barSeconds));
	const maxBars = math.max(minBars, math.floor(MUSIC_MAX_SECONDS / barSeconds));
	const bars = math.min(maxBars, math.max(minBars, math.floor(requestedDuration / barSeconds + 0.5)));
	const duration = bars * barSeconds;
	const requestedKey = (req.key ?? "random").trim().toUpperCase();
	let rootPitchClass = MUSIC_KEY_NAMES.indexOf(requestedKey);
	if (rootPitchClass < 0) rootPitchClass = math.floor(styleRng.next() * MUSIC_KEY_NAMES.length);
	const requestedMode = (req.mode ?? "auto").trim().toLowerCase();
	const mode = (MUSIC_VALID_MODES.indexOf(requestedMode) >= 0 ? requestedMode : styleConfig.mode) as MusicMode;
	const parsedProgression = parseMusicProgression(req.progression, styleConfig.progression);
	const options: MusicResolvedOptions = {
		style: style as Exclude<GenerateMusicStyle, "random">, seed, bpm, bars, duration,
		volume: typeof req.volume === "number" && req.volume === req.volume ? clamp01(req.volume) : 0.65,
		intensity: typeof req.intensity === "number" && req.intensity === req.intensity ? clamp01(req.intensity) : 0.6,
		rootPitchClass, key: MUSIC_KEY_NAMES[rootPitchClass], mode,
		progression: parsedProgression.degrees, progressionText: parsedProgression.text,
		structure: parseMusicStructure(req.structure),
		barsPerSection: typeof req.barsPerSection === "number" ? math.floor(math.min(8, math.max(1, req.barsPerSection))) : 2,
		melodyComplexity: typeof req.melodyComplexity === "number" ? clamp01(req.melodyComplexity) : 0.55,
		rhythmComplexity: typeof req.rhythmComplexity === "number" ? clamp01(req.rhythmComplexity) : 0.45,
		variation: typeof req.variation === "number" ? clamp01(req.variation) : 0.25,
		leadInstrument: resolveMusicInstrument(req.leadInstrument, styleConfig.leadInstrument),
		bassInstrument: resolveMusicInstrument(req.bassInstrument, styleConfig.bassInstrument),
		harmonyInstrument: resolveMusicInstrument(req.harmonyInstrument, styleConfig.harmonyInstrument),
		stereo: req.stereo !== false,
		reverb: typeof req.reverb === "number" ? clamp01(req.reverb) : styleConfig.reverb,
		delay: typeof req.delay === "number" ? clamp01(req.delay) : styleConfig.delay,
		chorus: typeof req.chorus === "number" ? clamp01(req.chorus) : styleConfig.chorus,
		distortion: typeof req.distortion === "number" ? clamp01(req.distortion) : styleConfig.distortion,
		bitCrush: typeof req.bitCrush === "number" ? clamp01(req.bitCrush) : 0.0,
		lowPass: typeof req.lowPass === "number" ? clamp01(req.lowPass) : 0.0,
		stems: req.stems === true,
		introBars: typeof req.introBars === "number" ? math.floor(math.min(8, math.max(0, req.introBars))) : 0,
		outroBars: typeof req.outroBars === "number" ? math.floor(math.min(8, math.max(0, req.outroBars))) : 0,
		stinger: (["victory", "failure", "both"].indexOf((req.stinger ?? "none").toLowerCase()) >= 0 ? (req.stinger ?? "none").toLowerCase() : "none") as MusicStinger,
		exportMidi: req.exportMidi === true,
	};
	const cached = readCachedMusicResult(req.workDir, relPath, options);
	if (cached) {
		req.onProgress?.({ state: "running", operationId: "cache", path: relPath, stage: "cache", percent: 100, message: "reusing matching deterministic music assets" });
		return cached;
	}
	const operationId = createOperationId();
	const files: string[] = [];
	let bytesWritten = 0;
	const saveAudio = (relative: string, render: MusicRender): boolean => {
		const full = resolveWorkspaceFilePath(req.workDir, relative);
		if (!full) return false;
		const wav = encodePcmWav(render.mix.left, MUSIC_SAMPLE_RATE, render.mix.right);
		if (!saveGeneratedAsset(full, wav, operationId)) return false;
		files.push(relative); bytesWritten += wav.length; syncDownloadedFileToWebIDE(full);
		return true;
	};
	req.onProgress?.({ state: "running", operationId, path: relPath, stage: "compose", percent: 0, message: `composing ${style} in ${options.key} ${mode} at ${bpm} BPM` });
	const arrangement = createMusicArrangement(options, bars);
	const render = await synthMusic(options, arrangement, bars, "loop", options.stems, percent => req.onProgress?.({
		state: "running", operationId, path: relPath, stage: "synth", percent, message: `synthesizing loop (${percent}%)`,
	}), req.isCancelled);
	if (!render) return { success: false, path: relPath, message: "canceled", interrupted: true };
	req.onProgress?.({ state: "running", operationId, path: relPath, stage: "write", percent: 100, message: "writing music assets" });
	if (!saveAudio(relPath, render)) return { success: false, path: relPath, message: "failed to write music WAV" };
	if (render.stems) {
		const stemNames: Array<keyof typeof render.stems> = ["melody", "bass", "harmony", "drums"];
		for (let i = 0; i < stemNames.length; i++) {
			const name = stemNames[i];
			const relative = musicSiblingPath(relPath, `_${name}`);
			const full = resolveWorkspaceFilePath(req.workDir, relative);
			if (!full) return { success: false, path: relPath, message: `invalid stem path: ${relative}` };
			const wav = encodePcmWav(render.stems[name].left, MUSIC_SAMPLE_RATE, render.stems[name].right);
			if (!saveGeneratedAsset(full, wav, operationId)) return { success: false, path: relPath, message: `failed to write ${name} stem` };
			files.push(relative); bytesWritten += wav.length; syncDownloadedFileToWebIDE(full);
			await yieldMusicFrame();
		}
	}
	const segmentSpecs: Array<{ suffix: string; bars: number; kind: MusicRenderKind; style?: GenerateMusicStyle; seedOffset: number }> = [];
	if (options.introBars > 0) segmentSpecs.push({ suffix: "_intro", bars: options.introBars, kind: "intro", seedOffset: 3001 });
	if (options.outroBars > 0) segmentSpecs.push({ suffix: "_outro", bars: options.outroBars, kind: "outro", seedOffset: 6007 });
	if (options.stinger === "victory" || options.stinger === "both") segmentSpecs.push({ suffix: "_victory", bars: 1, kind: "stinger", style: "victory", seedOffset: 9001 });
	if (options.stinger === "failure" || options.stinger === "both") segmentSpecs.push({ suffix: "_failure", bars: 1, kind: "stinger", style: "tense", seedOffset: 12007 });
	for (let i = 0; i < segmentSpecs.length; i++) {
		const spec = segmentSpecs[i];
		const segmentStyle = (spec.style ?? options.style) as Exclude<GenerateMusicStyle, "random">;
		const segmentConfig = getMusicStyleConfig(segmentStyle);
		const segmentOptions: MusicResolvedOptions = {
			...options,
			style: segmentStyle,
			seed: options.seed + spec.seedOffset,
			mode: spec.style ? segmentConfig.mode : options.mode,
			progression: spec.style ? segmentConfig.progression : options.progression,
			leadInstrument: spec.style ? segmentConfig.leadInstrument : options.leadInstrument,
			bassInstrument: spec.style ? segmentConfig.bassInstrument : options.bassInstrument,
			harmonyInstrument: spec.style ? segmentConfig.harmonyInstrument : options.harmonyInstrument,
			intensity: spec.style ? 0.9 : options.intensity,
			stems: false,
		};
		const segmentArrangement = createMusicArrangement(segmentOptions, spec.bars, spec.seedOffset);
		const segment = await synthMusic(segmentOptions, segmentArrangement, spec.bars, spec.kind, false, undefined, req.isCancelled);
		if (!segment) return { success: false, path: relPath, message: "canceled", interrupted: true };
		if (!saveAudio(musicSiblingPath(relPath, spec.suffix), segment)) return { success: false, path: relPath, message: `failed to write ${spec.suffix} segment` };
	}
	let midiPath: string | undefined;
	if (options.exportMidi) {
		midiPath = musicSiblingPath(relPath, "", ".mid");
		const midiFull = resolveWorkspaceFilePath(req.workDir, midiPath);
		const midi = encodeMusicMidi(arrangement, options);
		if (!midiFull || !saveGeneratedAsset(midiFull, midi, operationId)) return { success: false, path: relPath, message: "failed to write MIDI file" };
		files.push(midiPath); bytesWritten += midi.length; syncDownloadedFileToWebIDE(midiFull);
	}
	const actualDuration = math.floor((render.mix.left.length / MUSIC_SAMPLE_RATE) * 100.0 + 0.5) / 100.0;
	const projectPath = musicSiblingPath(relPath, "", ".music.json");
	const projectFull = resolveWorkspaceFilePath(req.workDir, projectPath);
	const [projectText] = safeJsonEncode(musicProjectObject(
		relPath, options, files.slice(), bytesWritten, actualDuration, render.peak, render.clippingSamples, req.sourceProject
	), true, false);
	if (!projectFull || !projectText || !saveGeneratedAsset(projectFull, projectText, operationId)) return { success: false, path: relPath, message: "failed to write music project file" };
	files.push(projectPath); bytesWritten += projectText.length; syncDownloadedFileToWebIDE(projectFull);
	if (render.clippingSamples > 0) Log("Warn", `[generate_music] limiter caught ${render.clippingSamples} clipping sample(s), pre-limit peak=${render.peak}`);
	Log("Info", `[generate_music] style=${style} seed=${seed} bpm=${bpm} bars=${bars} key=${options.key} ${mode} files=${files.length} bytes=${bytesWritten}`);
	return {
		success: true, path: relPath, files, projectPath, midiPath, bytesWritten, durationSeconds: actualDuration,
		sampleRate: MUSIC_SAMPLE_RATE, channels: options.stereo ? 2 : 1, seed, style, bpm, bars,
		key: options.key, mode,
		description: `Saved ${bars} bars of ${style} background music in ${options.key} ${mode} at ${bpm} BPM to ${relPath}, plus ${files.length - 1} companion asset(s). Stream the loop with Audio.playStream("${relPath}", true); use ${projectPath} to create compatible variations.`,
	};
}

export async function generateMusicVariation(req: {
	workDir: string; project: string; path: string; seed?: number; style?: string; intensity?: number; variation?: number;
	onProgress?: (progress: GenerateMusicProgress) => void; isCancelled?: () => boolean;
}): Promise<GenerateMusicResult> {
	const projectRel = (req.project ?? "").trim();
	if (!projectRel.toLowerCase().endsWith(".music.json")) return { success: false, path: req.path, message: "project must end in .music.json" };
	const projectFull = resolveWorkspaceFilePath(req.workDir, projectRel);
	if (!projectFull || !Content.exist(projectFull) || Content.isdir(projectFull)) return { success: false, path: req.path, message: "music project file not found" };
	const text = Content.load(projectFull);
	if (typeof text !== "string") return { success: false, path: req.path, message: "failed to read music project file" };
	const [decoded, decodeError] = safeJsonDecode(text);
	if (!decoded || type(decoded) !== "table") return { success: false, path: req.path, message: `invalid music project: ${tostring(decodeError)}` };
	const params = (decoded as Record<string, unknown>).params;
	if (!params || type(params) !== "table") return { success: false, path: req.path, message: "music project is missing params" };
	const p = params as Record<string, unknown>;
	const numberValue = (name: string): number | undefined => typeof p[name] === "number" ? p[name] as number : undefined;
	const stringValue = (name: string): string | undefined => typeof p[name] === "string" ? p[name] as string : undefined;
	const boolValue = (name: string): boolean | undefined => typeof p[name] === "boolean" ? p[name] as boolean : undefined;
	const oldSeed = numberValue("seed") ?? 1;
	return generateMusic({
		workDir: req.workDir, path: req.path, style: req.style ?? stringValue("style") ?? "chiptune",
		seed: req.seed ?? (oldSeed + 7919), duration: numberValue("duration"), bpm: numberValue("bpm"), volume: numberValue("volume"),
		intensity: req.intensity ?? numberValue("intensity"), key: stringValue("key"), mode: stringValue("mode"),
		progression: stringValue("progression"), structure: stringValue("structure"), barsPerSection: numberValue("barsPerSection"),
		melodyComplexity: numberValue("melodyComplexity"), rhythmComplexity: numberValue("rhythmComplexity"),
		variation: req.variation ?? numberValue("variation"), leadInstrument: stringValue("leadInstrument"),
		bassInstrument: stringValue("bassInstrument"), harmonyInstrument: stringValue("harmonyInstrument"), stereo: boolValue("stereo"),
		reverb: numberValue("reverb"), delay: numberValue("delay"), chorus: numberValue("chorus"), distortion: numberValue("distortion"),
		bitCrush: numberValue("bitCrush"), lowPass: numberValue("lowPass"), stems: boolValue("stems"), introBars: numberValue("introBars"), outroBars: numberValue("outroBars"),
		stinger: stringValue("stinger"), exportMidi: boolValue("exportMidi"), sourceProject: projectRel,
		onProgress: req.onProgress, isCancelled: req.isCancelled,
	});
}
