// @preview-file off clear
import { Content, DB, Path, Director, once, SearchFilesResult, Node, emit, wait, App, HttpServer } from 'Dora';
import { Log, safeJsonDecode, safeJsonEncode } from 'Agent/Utils';

export type AgentTaskStatus = "RUNNING" | "DONE" | "FAILED" | "STOPPED";
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
	messages: BuildMessage[];
} | {
	success: false;
	message: string;
};

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
} | {
	success: false;
	message: string;
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
	totalResults?: number;
	truncated?: boolean;
	limit?: number;
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
const ENGINE_LOG_SNAPSHOT_DIR = ".agent";
const ENGINE_LOG_SNAPSHOT_FILE = "engine_logs_snapshot.txt";

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

function toDocRelativePath(baseRoot: string, path: string): string {
	if (!path || path.length === 0) return path;
	if (!Content.isAbsolutePath(path)) return path;
	return Path.getRelative(path, baseRoot);
}

function resolveAgentTutorialDocFilePath(path: string, docLanguage?: DoraAPIDocLanguage): string | undefined {
	if (!docLanguage) return undefined;
	if (!isValidWorkspacePath(path)) return undefined;
	const candidate = Path(getDoraTutorialDocRoot(docLanguage), path);
	if (Content.exist(candidate) && !Content.isdir(candidate)) {
		return candidate;
	}
	return undefined;
}

function ensureDirPath(dir: string): boolean {
	if (!dir || dir === "." || dir === "") return true;
	if (Content.exist(dir)) return Content.isdir(dir);
	const parent = Path.getPath(dir);
	if (parent && parent !== dir && parent !== "." && parent !== "") {
		if (!ensureDirPath(parent)) return false;
	}
	return Content.mkdir(dir);
}

function ensureDirForFile(path: string): boolean {
	const dir = Path.getPath(path);
	return ensureDirPath(dir);
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
	const content = Content.load(path);
	return {
		exists: true,
		content,
		bytes: content.length,
	};
}

function queryOne(sql: string, args?: (number | string | boolean)[]) {
	const rows = args ? DB.query(sql, args as any) : DB.query(sql);
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
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);`);
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
	return (row[0] as number) || 0;
}

function getTaskStatus(taskId: number): string | undefined {
	const row = queryOne(`SELECT status FROM ${TABLE_TASK} WHERE id = ?`, [taskId]);
	if (!row) return undefined;
	return toStr(row[0]);
}

function getLastInsertRowId(): number {
	const row = queryOne("SELECT last_insert_rowid()");
	return row ? ((row[0] as number) || 0) : 0;
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

async function runSingleNonTsBuild(file: string): Promise<BuildMessage> {
	return new Promise<BuildMessage>((resolve) => {
		const { buildAsync } = require("Script.Dev.WebServer");
		Director.systemScheduler.schedule(once(() => {
			const result = buildAsync(file);
			resolve(result);
		}));
	})
}

export async function runSingleTsTranspile(file: string, content: string): Promise<BuildMessage> {
	let done = false;
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
		const payload = res as any;
		if (payload.name !== "TranspileTS") return;
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
		file,
		content,
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

export function createTask(prompt = ""): CreateTaskResult {
	const t = now();
	const affected = DB.exec(
		`INSERT INTO ${TABLE_TASK}(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)`,
		["RUNNING", prompt, t, t],
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

function readWorkspaceFile(workDir: string, path: string, docLanguage?: DoraAPIDocLanguage): ReadFileResult {
	const fullPath = resolveWorkspaceFilePath(workDir, path);
	if (fullPath && Content.exist(fullPath) && !Content.isdir(fullPath)) {
		return { success: true, content: Content.load(fullPath) };
	}
	const docPath = resolveAgentTutorialDocFilePath(path, docLanguage);
	if (docPath) {
		return { success: true, content: Content.load(docPath) };
	}
	if (!fullPath) return { success: false, message: "invalid path or workDir" };
	return { success: false, message: "file not found" };
}

export function readFileRaw(workDir: string, path: string, docLanguage?: DoraAPIDocLanguage): ReadFileResult {
	const result = readWorkspaceFile(workDir, path, docLanguage);
	if (!result.success && Content.exist(path) && !Content.isdir(path)) {
		return { success: true, content: Content.load(path) };
	}
	return result;
}

function getEngineLogText(): string | undefined {
	const folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR);
	if (!Content.exist(folder)) {
		Content.mkdir(folder);
	}
	const logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE);
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
						const file = toDocRelativePath(resultBaseRoot, row.file);
						if (file === "") continue;
						hits.push({
							file,
							line: typeof row.line === "number" ? row.line : undefined,
							content: typeof row.content === "string" ? row.content : undefined,
						});
					}
					allHits.push(sortDoraAPISearchHits(hits, docSource, req.programmingLanguage).slice(0, limit));
				}
				const hits = mergeDoraAPISearchHitsUnique(allHits);
				resolve({
					success: true,
					docSource,
					docLanguage: req.docLanguage,
					programmingLanguage: req.programmingLanguage,
					exts,
					results: hits,
					totalResults: hits.length,
					truncated: false,
					limit,
				});
			} catch (e) {
				resolve({ success: false, message: tostring(e) });
			}
		}));
	});
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

	for (const entry of getCheckpointEntries(checkpointId, false)) {
		const fullPath = resolveWorkspaceFilePath(workDir, entry.path);
		if (!fullPath) {
			DB.exec(`UPDATE ${TABLE_CP} SET status = ? WHERE id = ?`, ["FAILED", checkpointId]);
			return { success: false, message: `invalid path: ${entry.path}` };
		}
		const ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent);
		if (!ok) {
			DB.exec(`UPDATE ${TABLE_CP} SET status = ? WHERE id = ?`, ["FAILED", checkpointId]);
			return { success: false, message: `failed to apply file change: ${entry.path}` };
		}
		if (!sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent)) {
			DB.exec(`UPDATE ${TABLE_CP} SET status = ? WHERE id = ?`, ["FAILED", checkpointId]);
			return { success: false, message: `failed to sync file change: ${entry.path}` };
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
	return { success: true, checkpointId };
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
			if (!sendWebIDEFileUpdate(target, true, content)) {
				return { success: false, message: "failed to encode UpdateFile request" };
			}
			if (!isDtsFile(target)) {
				messages.push(await runSingleTsTranspile(target, content));
			}
		} else {
			messages.push(await runSingleNonTsBuild(target));
		}
		Log("Info", `[build] file=${target} messages=${messages.length}`);
		return {
			success: true,
			messages: messages.map(m => m.success
				? ({ ...m, file: toWorkspaceRelativePath(req.workDir, m.file) })
				: ({ ...m, file: toWorkspaceRelativePath(req.workDir, m.file) })),
		};
	}
	const listResult = listFiles({
		workDir: req.workDir,
		path: target,
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
		tsFileData[file] = content;
		if (!sendWebIDEFileUpdate(file, true, content)) {
			messages.push({ success: false, file, message: "failed to encode UpdateFile request" });
			continue;
		}
	}
	for (let i = 0; i < buildQueue.length; i++) {
		const { file, kind } = buildQueue[i];
		if (kind === "ts") {
			const content = tsFileData[file];
			if (content === undefined || isDtsFile(file)) {
				continue;
			}
			messages.push(await runSingleTsTranspile(file, content));
			continue;
		}
		messages.push(await runSingleNonTsBuild(file));
	}
	Log("Info", `[build] dir=${target} messages=${messages.length}`);
	return {
		success: true,
		messages: messages.map(m => m.success
			? ({ ...m, file: toWorkspaceRelativePath(req.workDir, m.file) })
			: ({ ...m, file: toWorkspaceRelativePath(req.workDir, m.file) })),
	};
}
