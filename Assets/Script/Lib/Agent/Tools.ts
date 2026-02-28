// @preview-file off clear
import { Content, DB, Path, Log as DoraLog, Director, once, SearchFilesResult, Node, emit, wait, json, App, HttpServer } from 'Dora';

let logLevel = 3;

export function setLogLevel(level: number) {
	logLevel = level;
}

const Log = (type: "Info" | "Warn" | "Error", msg: string) => {
	if (logLevel < 1) return;
	else if (logLevel < 2 && (type === "Info" || type === "Warn")) return;
	else if (logLevel < 3 && type === "Info") return;
	DoraLog(type, msg);
};

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
	headSeq: number;
} | {
	success: false;
	message: string;
};

export type ListFilesResult = {
	success: true;
	files: string[];
} | {
	success: false;
	message: string;
};

export type TsBuildMessage = {
	success: true;
	file: string;
} | {
	success: false;
	file: string;
	message: string;
};

export type TsBuildResult = {
	success: true;
	messages: TsBuildMessage[];
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
} | {
	success: false;
	message: string;
};

export type SearchFilesToolResult = {
	success: true;
	results: SearchFilesResult[];
} | {
	success: false;
	message: string;
};

export type DoraAPIDocLanguage = "zh" | "en";
export type DoraAPIProgrammingLanguage = "ts" | "tsx" | "lua" | "yue" | "teal";

export interface DoraAPISearchHit {
	file: string;
	line?: number;
	content?: string;
}

export type DoraAPISearchResult = {
	success: true;
	docLanguage: DoraAPIDocLanguage;
	root: string;
	exts: string[];
	results: DoraAPISearchHit[];
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
const DORA_DOC_ZH_DIR = Path(Content.assetPath, "Script", "Lib", "Dora", "zh-Hans");
const DORA_DOC_EN_DIR = Path(Content.assetPath, "Script", "Lib", "Dora", "en");

const now = () => os.time();

function toBool(v: unknown): boolean {
	return v !== 0 && v !== false && v !== null && v !== undefined;
}

function toStr(v: unknown): string {
	if (v === false || v === null || v === undefined) return "";
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
	if (!path || path.length === 0) return false;
	if (path.includes("..")) return false;
	return true;
}

function normalizePathSep(path: string): string {
	return path.split("\\").join("/");
}

function ensureTrailingSlash(path: string): string {
	const p = normalizePathSep(path);
	return p.endsWith("/") ? p : `${p}/`;
}

function resolveWorkspaceFilePath(workDir: string, path: string): string | undefined {
	if (!isValidWorkDir(workDir)) return undefined;
	if (!isValidWorkspacePath(path)) return undefined;
	return Path(workDir, path);
}

function resolveWorkspaceSearchPath(workDir: string, path: string): string | undefined {
	if (!isValidWorkDir(workDir)) return undefined;
	const root = path ?? "";
	if (!isValidSearchPath(root)) return undefined;
	return root === "" ? workDir : Path(workDir, root);
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
		const row = results[i] as any;
		if (type(row) === "table") {
			const clone: Record<string, unknown> = {};
			for (const k in row) {
				clone[k] = row[k];
			}
			if (type(clone.file) === "string") {
				clone.file = toWorkspaceRelativePath(workDir, clone.file as string);
			}
			if (type(clone.path) === "string") {
				clone.path = toWorkspaceRelativePath(workDir, clone.path as string);
			}
			mapped.push(clone as unknown as SearchFilesResult);
		} else {
			mapped.push(results[i]);
		}
	}
	return mapped;
}

function getDoraDocRoot(docLanguage: DoraAPIDocLanguage): string {
	return docLanguage === "zh" ? DORA_DOC_ZH_DIR : DORA_DOC_EN_DIR;
}

function getDoraDocExtsByCodeLanguage(programmingLanguage: DoraAPIProgrammingLanguage): string[] {
	if (programmingLanguage === "ts" || programmingLanguage === "tsx") {
		return ["ts"];
	}
	return ["tl"];
}

function toDocRelativePath(docRoot: string, file: string): string {
	return Path.getRelative(file, docRoot);
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

function isTsLikeFile(path: string): boolean {
	const ext = Path.getExt(path);
	return ext === "ts" || ext === "tsx";
}

function isDtsFile(path: string): boolean {
	return Path.getExt(Path.getName(path)) === "d";
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
		`SELECT id, ord, path, before_exists, before_content, after_exists, after_content
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
			beforeExists: toBool(row[3]),
			beforeContent: toStr(row[4]),
			afterExists: toBool(row[5]),
			afterContent: toStr(row[6]),
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
	const [text] = json.encode(obj);
	return text;
}

export async function runSingleTsTranspile(file: string, content: string, timeoutSec: number): Promise<TsBuildMessage> {
	let done = false;
	let result: TsBuildMessage = {
		success: false,
		file,
		message: "transpile timeout or Web IDE not connected",
	};
	if (HttpServer.wsConnectionCount === 0) {
		return result;
	}
	const listener = Node();
	listener.gslot("AppWS", (eventType, msg) => {
		if (eventType !== "Receive") return;
		const [res] = json.decode(msg);
		if (!res || Array.isArray(res) || res.name !== "TranspileTS") return;
		if (res.success) {
			const luaFile = Path.replaceExt(file, "lua");
			if (Content.save(luaFile, tostring(res.luaCode))) {
				result = { success: true, file };
			} else {
				result = { success: false, file, message: `failed to save ${luaFile}` };
			}
		} else {
			result = { success: false, file, message: tostring(res.message) };
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
		listener.once(() => {
			emit("AppWS", "Send", payload);
			const start = App.runningTime;
			wait(() => done || App.runningTime - start >= timeoutSec);
			if (!done) {
				listener.removeFromParent();
			}
			resolve();
		});
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

function readWorkspaceFile(workDir: string, path: string): ReadFileResult {
	const fullPath = resolveWorkspaceFilePath(workDir, path);
	if (!fullPath) return { success: false, message: "invalid path or workDir" };
	if (!Content.exist(fullPath) || Content.isdir(fullPath)) return { success: false, message: "file not found" };
	return { success: true, content: Content.load(fullPath) };
}

export function readFile(workDir: string, path: string): ReadFileResult {
	const result = readWorkspaceFile(workDir, path);
	if (!result.success && Content.exist(path)) {
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
	if (text === undefined || text === null) {
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
		return { success: true, files };
	} catch (e) {
		return { success: false, message: tostring(e) };
	}
}

export function readFileRange(workDir: string, path: string, startLine: number, endLine: number): ReadFileResult {
	const res = readFile(workDir, path);
	if (!res.success || res.content === undefined) return res;
	const s = Math.max(1, math.floor(startLine));
	const e = Math.max(s, math.floor(endLine));
	const lines = res.content.split("\n");
	const part: string[] = [];
	for (let i = s; i <= e && i <= lines.length; i++) {
		part.push(lines[i - 1]);
	}
	return { success: true, content: part.join("\n") };
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
	for (const [p0] of string.gmatch(trimmed, "%S+")) {
		const p = tostring(p0).trim();
		if (p !== "") out.push(p);
	}
	return out;
}

function mergeSearchFileResultsUnique(resultsList: SearchFilesResult[][]): SearchFilesResult[] {
	const merged: SearchFilesResult[] = [];
	const seen = new Set<string>();
	for (let i = 0; i < resultsList.length; i++) {
		const list = resultsList[i];
		for (let j = 0; j < list.length; j++) {
			const row = list[j] as any;
			const key = type(row) === "table"
				? `${tostring(row.file ?? row.path ?? "")}:${tostring(row.pos ?? "")}:${tostring(row.line ?? "")}:${tostring(row.column ?? "")}`
				: tostring(j);
			if (seen.has(key)) continue;
			seen.add(key);
			merged.push(list[j]);
		}
	}
	return merged;
}

function mergeDoraAPISearchHitsUnique(resultsList: DoraAPISearchHit[][], topK: number): DoraAPISearchHit[] {
	const merged: DoraAPISearchHit[] = [];
	const seen = new Set<string>();
	for (let i = 0; i < resultsList.length && merged.length < topK; i++) {
		const list = resultsList[i];
		for (let j = 0; j < list.length && merged.length < topK; j++) {
			const row = list[j];
			const key = `${row.file}:${tostring(row.line ?? "")}:${tostring(row.content ?? "")}`;
			if (seen.has(key)) continue;
			seen.add(key);
			merged.push(row);
		}
	}
	return merged;
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
}): Promise<SearchFilesToolResult> {
	const searchRoot = resolveWorkspaceSearchPath(req.workDir, req.path);
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
				const allResults: SearchFilesResult[][] = [];
				for (let i = 0; i < patterns.length; i++) {
					allResults.push(Content.searchFilesAsync(
						searchRoot,
						codeExtensions,
						extensionLevels,
						ensureSafeSearchGlobs(req.globs ?? ["**"]),
						patterns[i],
						req.useRegex ?? false,
						req.caseSensitive ?? false,
						req.includeContent ?? true,
						req.contentWindow ?? 120
					));
				}
				const results = mergeSearchFileResultsUnique(allResults);
				resolve({ success: true, results: toWorkspaceRelativeSearchResults(req.workDir, results) });
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
	topK?: number;
	useRegex?: boolean;
	caseSensitive?: boolean;
	includeContent?: boolean;
	contentWindow?: number;
}): Promise<DoraAPISearchResult> {
	const pattern = (req.pattern ?? "").trim();
	if (pattern === "") return { success: false, message: "empty pattern" };
	const patterns = splitSearchPatterns(pattern);
	if (patterns.length === 0) return { success: false, message: "empty pattern" };
	const docRoot = getDoraDocRoot(req.docLanguage);
	if (!Content.exist(docRoot) || !Content.isdir(docRoot)) {
		return { success: false, message: `doc root not found: ${docRoot}` };
	}
	const exts = getDoraDocExtsByCodeLanguage(req.programmingLanguage);
	const dotExts = exts.map(ext => ext.startsWith(".") ? ext : `.${ext}`);
	const globs = exts.map(ext => `**/*.${ext}`);
	const topK = math.max(1, math.floor(req.topK ?? 10));

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
						req.contentWindow ?? 140
					);
					const hits: DoraAPISearchHit[] = [];
					for (let i = 0; i < raw.length; i++) {
						const row = raw[i] as any;
						if (type(row) !== "table") continue;
						const file = type(row.file) === "string"
							? toDocRelativePath(docRoot, row.file as string)
							: (type(row.path) === "string" ? toDocRelativePath(docRoot, row.path as string) : "");
						if (file === "") continue;
						hits.push({
							file,
							line: type(row.line) === "number" ? (row.line as number) : undefined,
							content: type(row.content) === "string" ? (row.content as string) : undefined,
						});
					}
					allHits.push(hits);
				}
				const hits = mergeDoraAPISearchHitsUnique(allHits, topK);
				resolve({
					success: true,
					docLanguage: req.docLanguage,
					root: docRoot,
					exts,
					results: hits,
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
	const dup = rejectDuplicatePaths(changes);
	if (dup) {
		return { success: false, message: `duplicate path in batch: ${dup}` };
	}

	for (const change of changes) {
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

	for (let i = 0; i < changes.length; i++) {
		const change = changes[i];
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

export function rollbackToCheckpoint(taskId: number, workDir: string, targetSeq: number): RollbackResult {
	if (!isValidWorkDir(workDir)) return { success: false, message: "invalid workDir" };
	const headSeq = getTaskHeadSeq(taskId);
	if (headSeq === undefined) return { success: false, message: "task not found" };
	if (targetSeq < 0 || targetSeq > headSeq) {
		return { success: false, message: "invalid target seq" };
	}
	if (targetSeq === headSeq) {
		return { success: true, headSeq };
	}

	const cps = DB.query(
		`SELECT id, seq FROM ${TABLE_CP}
		WHERE task_id = ? AND status = ? AND seq > ? AND seq <= ?
		ORDER BY seq DESC`,
		[taskId, "APPLIED", targetSeq, headSeq],
	);
	if (!cps) return { success: false, message: "failed to query checkpoints" };

	for (let i = 0; i < cps.length; i++) {
		const cpId = cps[i][0] as number;
		const cpSeq = cps[i][1] as number;
		const entries = getCheckpointEntries(cpId, true);
		for (const entry of entries) {
			const fullPath = resolveWorkspaceFilePath(workDir, entry.path);
			if (!fullPath) {
				return { success: false, message: `invalid path: ${entry.path}` };
			}
			const ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent);
			if (!ok) {
				Log("Error", `Agent rollback failed at checkpoint ${cpSeq}, file ${entry.path}`);
				Log("Info", `[rollback] failed checkpoint=${cpSeq} file=${entry.path}`);
				return { success: false, message: `failed to rollback file: ${entry.path}` };
			}
		}
		DB.exec(
			`UPDATE ${TABLE_CP} SET status = ?, reverted_at = ? WHERE id = ?`,
			["REVERTED", now(), cpId],
		);
	}

	DB.exec(
		`UPDATE ${TABLE_TASK} SET head_seq = ?, updated_at = ? WHERE id = ?`,
		[targetSeq, now(), taskId],
	);
	return { success: true, headSeq: targetSeq };
}

export function getCheckpointEntriesForDebug(checkpointId: number) {
	return getCheckpointEntries(checkpointId, false);
}

export async function runTsBuild(req: { workDir: string; path: string; timeoutSec?: number }): Promise<TsBuildResult> {
	const targetRel = req.path ?? "";
	const target = resolveWorkspaceSearchPath(req.workDir, targetRel);
	const timeoutSec = math.max(1, math.floor(req.timeoutSec ?? 20));
	if (!target) {
		return { success: false, message: "invalid path or workDir" };
	}
	if (!Content.exist(target)) {
		return { success: false, message: "path not existed" };
	}
	const messages: TsBuildMessage[] = [];
	if (!Content.isdir(target)) {
		if (!isTsLikeFile(target)) {
			return { success: false, message: "expecting a TypeScript file" };
		}
		const content = Content.load(target);
		if (content === undefined || content === null) {
			return { success: false, message: "failed to read file" };
		}
		const updatePayload = encodeJSON({ name: "UpdateTSCode", file: target, content });
		if (!updatePayload) {
			return { success: false, message: "failed to encode UpdateTSCode request" };
		}
		emit("AppWS", "Send", updatePayload);
		if (!isDtsFile(target)) {
			messages.push(await runSingleTsTranspile(target, content, timeoutSec));
		}
		Log("Info", `[ts_build] file=${target} messages=${messages.length}`);
		return {
			success: true,
			messages: messages.map(m => m.success
				? ({ ...m, file: toWorkspaceRelativePath(req.workDir, m.file) })
				: ({ ...m, file: toWorkspaceRelativePath(req.workDir, m.file) })),
		};
	}

	const relFiles = Content.getAllFiles(target);
	const fileData: Record<string, string> = {};
	for (const rel of relFiles) {
		const file = Content.isAbsolutePath(rel) ? rel : Path(target, rel);
		if (!isTsLikeFile(file)) continue;
		const content = Content.load(file);
		if (content === undefined || content === null) {
			messages.push({ success: false, file, message: "failed to read file" });
			continue;
		}
		fileData[file] = content;
		const updatePayload = encodeJSON({ name: "UpdateTSCode", file, content });
		if (!updatePayload) {
			messages.push({ success: false, file, message: "failed to encode UpdateTSCode request" });
			continue;
		}
		emit("AppWS", "Send", updatePayload);
	}
	for (const file in fileData) {
		if (isDtsFile(file)) continue;
		messages.push(await runSingleTsTranspile(file, fileData[file], timeoutSec));
	}
	Log("Info", `[ts_build] dir=${target} messages=${messages.length}`);
	return {
		success: true,
		messages: messages.map(m => m.success
			? ({ ...m, file: toWorkspaceRelativePath(req.workDir, m.file) })
			: ({ ...m, file: toWorkspaceRelativePath(req.workDir, m.file) })),
	};
}
