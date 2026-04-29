// @preview-file off clear
import { App, Content, DB, Path, HttpServer, emit } from 'Dora';
import { runCodingAgent, CodingAgentEvent, CodingAgentRunResult, truncateAgentUserPrompt } from 'Agent/CodingAgent';
import * as Tools from 'Agent/Tools';
import { DualLayerStorage } from 'Agent/Memory';
import { Log, callLLM, clipTextToTokenBudget, estimateTextTokens, getActiveLLMConfig, safeJsonDecode, safeJsonEncode, sanitizeUTF8 } from 'Agent/Utils';
import type { LLMConfig, Message, StopToken, ToolCallFunction } from 'Agent/Utils';

export type AgentSessionStatus = "IDLE" | "RUNNING" | "DONE" | "FAILED" | "STOPPED";
export type AgentSessionKind = "main" | "sub";
export type AgentMessageRole = "user" | "assistant";
export type AgentStepStatus = "PENDING" | "RUNNING" | "DONE" | "FAILED" | "STOPPED";

export interface AgentSessionItem {
	id: number;
	projectRoot: string;
	title: string;
	kind: AgentSessionKind;
	rootSessionId: number;
	parentSessionId?: number;
	memoryScope: string;
	status: AgentSessionStatus;
	currentTaskId?: number;
	currentTaskStatus?: AgentSessionStatus;
	currentTaskFinalizing?: boolean;
	createdAt: number;
	updatedAt: number;
}

export interface AgentSessionMessageItem {
	id: number;
	sessionId: number;
	taskId?: number;
	role: AgentMessageRole;
	content: string;
	createdAt: number;
	updatedAt: number;
}

export interface AgentSessionStepItem {
	id: number;
	sessionId: number;
	taskId: number;
	step: number;
	tool: string;
	status: AgentStepStatus;
	reason: string;
	reasoningContent: string;
	params?: Record<string, unknown>;
	result?: Record<string, unknown>;
	checkpointId?: number;
	checkpointSeq?: number;
	files?: { path: string; op: string }[];
	createdAt: number;
	updatedAt: number;
}

export interface AgentChangeSetFileItem {
	path: string;
	op: Tools.FileOp;
	checkpointCount: number;
	checkpointIds: number[];
}

export interface AgentChangeSetSummaryItem {
	success: true;
	taskId: number;
	checkpointCount: number;
	filesChanged: number;
	files: AgentChangeSetFileItem[];
	latestCheckpointId?: number;
	latestCheckpointSeq?: number;
}

export interface AgentSubAgentMemoryEntryItem {
	sourceSessionId: number;
	sourceTaskId: number;
	content: string;
	evidence: string[];
	createdAt: string;
}

export interface AgentSessionSpawnInfo {
	sessionId?: number;
	rootSessionId?: number;
	parentSessionId?: number;
	title?: string;
	prompt: string;
	goal: string;
	expectedOutput?: string;
	filesHint?: string[];
	status?: "RUNNING" | "DONE" | "FAILED" | "STOPPED";
	success?: boolean;
	cleared?: boolean;
	resultFilePath?: string;
	artifactDir?: string;
	sourceTaskId?: number;
	changeSet?: AgentChangeSetSummaryItem;
	memoryEntry?: AgentSubAgentMemoryEntryItem;
	memoryEntryError?: string;
	createdAt?: string;
	finishedAt?: string;
	createdAtTs?: number;
	finishedAtTs?: number;
}

export type AgentSessionDetailResult = {
	success: true;
	session: AgentSessionItem;
	relatedSessions: AgentSessionItem[];
	spawnInfo?: AgentSessionSpawnInfo;
	messages: AgentSessionMessageItem[];
	steps: AgentSessionStepItem[];
	checkpoints: Tools.CheckpointItem[];
} | {
	success: false;
	message: string;
};

export type AgentSessionSendResult = {
	success: true;
	sessionId: number;
	taskId: number;
} | {
	success: false;
	message: string;
};

export type AgentRunningSessionListResult = {
	success: true;
	sessions: AgentSessionItem[];
} | {
	success: false;
	message: string;
};

export type AgentRunningSubAgentInfo = {
	sessionId: number;
	title: string;
	parentSessionId?: number;
	rootSessionId: number;
	status: "RUNNING" | "DONE" | "FAILED" | "STOPPED";
	currentTaskId?: number;
	currentTaskStatus?: AgentSessionStatus;
	goal?: string;
	expectedOutput?: string;
	filesHint?: string[];
	summary?: string;
	success?: boolean;
	cleared?: boolean;
	resultFilePath?: string;
	artifactDir?: string;
	finishedAt?: string;
	createdAt: number;
	updatedAt: number;
};

export type AgentRunningSubAgentListResult = {
	success: true;
	rootSessionId: number;
	maxConcurrent: number;
	status: string;
	limit: number;
	offset: number;
	hasMore: boolean;
	sessions: AgentRunningSubAgentInfo[];
} | {
	success: false;
	message: string;
};

const TABLE_SESSION = "AgentSession";
const TABLE_MESSAGE = "AgentSessionMessage";
const TABLE_STEP = "AgentSessionStep";
const TABLE_TASK = "AgentTask";
const AGENT_SESSION_SCHEMA_VERSION = 2;
const SPAWN_INFO_FILE = "SPAWN.json";
const RESULT_FILE = "RESULT.md";
const PENDING_HANDOFF_DIR = "pending-handoffs";
const MAX_CONCURRENT_SUB_AGENTS = 4;
const SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE = 0.1;
const SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS = 1024;
const SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY = 3;
const SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200;
const SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5;
const SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS = 3000;
const SUB_AGENT_MEMORY_RESULT_MAX_TOKENS = 2000;
const SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES = 20;
const SUB_AGENT_MEMORY_TAIL_MAX_TOKENS = 4000;
const SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS = 600;

interface SubAgentResultRecord {
	sessionId: number;
	rootSessionId: number;
	parentSessionId?: number;
	title: string;
	prompt: string;
	goal: string;
	expectedOutput?: string;
	filesHint?: string[];
	status: "DONE" | "FAILED" | "STOPPED";
	success: boolean;
	cleared?: boolean;
	summary?: string;
	resultFilePath: string;
	artifactDir: string;
	sourceTaskId: number;
	createdAt: string;
	finishedAt: string;
	createdAtTs: number;
	finishedAtTs: number;
	changeSet?: AgentChangeSetSummaryItem;
	memoryEntry?: AgentSubAgentMemoryEntryItem;
	memoryEntryError?: string;
}

interface PendingSubAgentHandoffItem {
	id: string;
	sourceSessionId: number;
	sourceTitle: string;
	sourceTaskId: number;
	message: string;
	prompt: string;
	goal: string;
	expectedOutput?: string;
	filesHint?: string[];
	success?: boolean;
	resultFilePath?: string;
	artifactDir?: string;
	finishedAt?: string;
	changeSet?: AgentChangeSetSummaryItem;
	memoryEntry?: AgentSubAgentMemoryEntryItem;
	createdAt: string;
}

const activeStopTokens: Record<number, StopToken> = {};
const finalizingSubSessionTaskIds: Record<number, boolean> = {};
const now = () => os.time();

function getDefaultUseChineseResponse(): boolean {
	const [zh] = string.match(App.locale, "^zh");
	return zh !== undefined;
}

function toStr(v: unknown): string {
	if (v === false || v === null || v === undefined) return "";
	return tostring(v);
}

function encodeJson(value: unknown): string {
	const [text] = safeJsonEncode(value as object);
	return text ?? "";
}

function decodeJsonObject(text: string): Record<string, unknown> | undefined {
	if (!text || text === "") return undefined;
	const [value] = safeJsonDecode(text);
	if (value && !Array.isArray(value) && type(value) === "table") {
		return value as Record<string, unknown>;
	}
	return undefined;
}

function decodeJsonFiles(text: string): { path: string; op: string }[] | undefined {
	if (!text || text === "") return undefined;
	const [value] = safeJsonDecode(text);
	if (!value || !Array.isArray(value)) return undefined;
	const files: { path: string; op: string }[] = [];
	for (let i = 0; i < value.length; i++) {
		const item = value[i] as any;
		if (type(item) !== "table") continue;
		files.push({
			path: sanitizeUTF8(toStr(item.path)),
			op: sanitizeUTF8(toStr(item.op)),
		});
	}
	return files;
}

function decodeChangeSetSummary(value: unknown): AgentChangeSetSummaryItem | undefined {
	if (!value || Array.isArray(value) || type(value) !== "table") return undefined;
	const row = value as Record<string, unknown>;
	if (row.success !== true) return undefined;
	const taskId = typeof row.taskId === "number" ? row.taskId : 0;
	if (taskId <= 0) return undefined;
	const files: AgentChangeSetFileItem[] = [];
	if (Array.isArray(row.files)) {
		for (let i = 0; i < row.files.length; i++) {
			const file = row.files[i];
			if (!file || Array.isArray(file) || type(file) !== "table") continue;
			const fileRow = file as Record<string, unknown>;
			const path = sanitizeUTF8(toStr(fileRow.path));
			if (path === "") continue;
			const checkpointIds: number[] = [];
			if (Array.isArray(fileRow.checkpointIds)) {
				for (let j = 0; j < fileRow.checkpointIds.length; j++) {
					const checkpointId = typeof fileRow.checkpointIds[j] === "number" ? fileRow.checkpointIds[j] as number : 0;
					if (checkpointId > 0) checkpointIds.push(checkpointId);
				}
			}
			const op = toStr(fileRow.op);
			files.push({
				path,
				op: op === "create" || op === "delete" || op === "write" ? op : "write",
				checkpointCount: typeof fileRow.checkpointCount === "number" ? fileRow.checkpointCount : checkpointIds.length,
				checkpointIds,
			});
		}
	}
	return {
		success: true,
		taskId,
		checkpointCount: typeof row.checkpointCount === "number" ? row.checkpointCount : 0,
		filesChanged: typeof row.filesChanged === "number" ? row.filesChanged : files.length,
		files,
		latestCheckpointId: typeof row.latestCheckpointId === "number" ? row.latestCheckpointId : undefined,
		latestCheckpointSeq: typeof row.latestCheckpointSeq === "number" ? row.latestCheckpointSeq : undefined,
	};
}

function takeUtf8Head(text: string, maxChars: number): string {
	if (maxChars <= 0 || text === "") return "";
	const nextPos = utf8.offset(text, maxChars + 1);
	if (nextPos === undefined) return text;
	return string.sub(text, 1, nextPos - 1);
}

function normalizeMemoryEntryEvidence(value: unknown): string[] {
	const evidence: string[] = [];
	if (!Array.isArray(value)) return evidence;
	for (let i = 0; i < value.length && evidence.length < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS; i++) {
		const item = sanitizeUTF8(toStr(value[i])).trim();
		if (item === "") continue;
		if (evidence.indexOf(item) < 0) {
			evidence.push(item);
		}
	}
	return evidence;
}

function decodeSubAgentMemoryEntry(value: unknown): AgentSubAgentMemoryEntryItem | undefined {
	if (!value || Array.isArray(value) || type(value) !== "table") return undefined;
	const row = value as Record<string, unknown>;
	const sourceSessionId = typeof row.sourceSessionId === "number" ? row.sourceSessionId : 0;
	const sourceTaskId = typeof row.sourceTaskId === "number" ? row.sourceTaskId : 0;
	const content = takeUtf8Head(sanitizeUTF8(toStr(row.content)).trim(), SUB_AGENT_MEMORY_ENTRY_MAX_CHARS);
	if (sourceSessionId <= 0 || sourceTaskId <= 0 || content === "") return undefined;
	return {
		sourceSessionId,
		sourceTaskId,
		content,
		evidence: normalizeMemoryEntryEvidence(row.evidence),
		createdAt: sanitizeUTF8(toStr(row.createdAt)).trim(),
	};
}

function getTaskChangeSetSummary(taskId: number): AgentChangeSetSummaryItem | undefined {
	const summary = Tools.summarizeTaskChangeSet(taskId);
	return summary.success ? summary : undefined;
}

function queryRows(sql: string, args?: (string | number | boolean)[]) {
	return args ? DB.query(sql, args as any) : DB.query(sql);
}

function queryOne(sql: string, args?: (string | number | boolean)[]) {
	const rows = queryRows(sql, args);
	if (!rows || rows.length === 0) return undefined;
	return rows[0];
}

function getLastInsertRowId(): number {
	const row = queryOne("SELECT last_insert_rowid()");
	return row ? ((row[0] as number) || 0) : 0;
}

function isValidProjectRoot(path: string): boolean {
	return !!path && Content.isAbsolutePath(path) && Content.exist(path) && Content.isdir(path);
}

function rowToSession(row: any[]): AgentSessionItem {
	return {
		id: row[0] as number,
		projectRoot: toStr(row[1]),
		title: toStr(row[2]),
		kind: (toStr(row[3]) === "sub" ? "sub" : "main") as AgentSessionKind,
		rootSessionId: typeof row[4] === "number" && row[4] > 0 ? row[4] : (row[0] as number),
		parentSessionId: typeof row[5] === "number" && row[5] > 0 ? row[5] : undefined,
		memoryScope: toStr(row[6]) !== "" ? toStr(row[6]) : "main",
		status: toStr(row[7]) as AgentSessionStatus,
		currentTaskId: typeof row[8] === "number" && row[8] > 0 ? row[8] : undefined,
		currentTaskStatus: toStr(row[9]) as AgentSessionStatus,
		currentTaskFinalizing: typeof row[8] === "number" && row[8] > 0 && finalizingSubSessionTaskIds[row[8]] === true,
		createdAt: row[10] as number,
		updatedAt: row[11] as number,
	};
}

function rowToMessage(row: any[]): AgentSessionMessageItem {
	return {
		id: row[0] as number,
		sessionId: row[1] as number,
		taskId: typeof row[2] === "number" && row[2] > 0 ? row[2] : undefined,
		role: toStr(row[3]) as AgentMessageRole,
		content: toStr(row[4]),
		createdAt: row[5] as number,
		updatedAt: row[6] as number,
	};
}

function rowToStep(row: any[]): AgentSessionStepItem {
	return {
		id: row[0] as number,
		sessionId: row[1] as number,
		taskId: row[2] as number,
		step: row[3] as number,
		tool: toStr(row[4]),
		status: toStr(row[5]) as AgentStepStatus,
		reason: toStr(row[6]),
		reasoningContent: toStr(row[7]),
		params: decodeJsonObject(toStr(row[8])),
		result: decodeJsonObject(toStr(row[9])),
		checkpointId: typeof row[10] === "number" && row[10] > 0 ? row[10] : undefined,
		checkpointSeq: typeof row[11] === "number" && row[11] > 0 ? row[11] : undefined,
		files: decodeJsonFiles(toStr(row[12])),
		createdAt: row[13] as number,
		updatedAt: row[14] as number,
	};
}

function getMessageItem(messageId: number): AgentSessionMessageItem | undefined {
	const row = queryOne(
		`SELECT id, session_id, task_id, role, content, created_at, updated_at
		FROM ${TABLE_MESSAGE}
		WHERE id = ?`,
		[messageId],
	);
	return row ? rowToMessage(row as any[]) : undefined;
}

function getStepItem(sessionId: number, taskId: number, step: number): AgentSessionStepItem | undefined {
	const row = queryOne(
		`SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at
		FROM ${TABLE_STEP}
		WHERE session_id = ? AND task_id = ? AND step = ?`,
		[sessionId, taskId, step],
	);
	return row ? rowToStep(row as any[]) : undefined;
}

function deleteMessageSteps(sessionId: number, taskId: number): number[] {
	const rows = queryRows(
		`SELECT id FROM ${TABLE_STEP}
		WHERE session_id = ? AND task_id = ? AND tool = ?`,
		[sessionId, taskId, "message"],
	) ?? [];
	const ids: number[] = [];
	for (let i = 0; i < rows.length; i++) {
		const row = rows[i] as any[];
		if (typeof row[0] === "number") {
			ids.push(row[0] as number);
		}
	}
	if (ids.length > 0) {
		DB.exec(
			`DELETE FROM ${TABLE_STEP}
			WHERE session_id = ? AND task_id = ? AND tool = ?`,
			[sessionId, taskId, "message"],
		);
	}
	return ids;
}

function getSessionRow(sessionId: number) {
	return queryOne(
		`SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at
		FROM ${TABLE_SESSION}
		WHERE id = ?`,
		[sessionId],
	);
}

function getSessionItem(sessionId: number): AgentSessionItem | undefined {
	const row = getSessionRow(sessionId);
	return row ? rowToSession(row as any[]) : undefined;
}

function getTaskPrompt(taskId: number): string | undefined {
	const row = queryOne(`SELECT prompt FROM ${TABLE_TASK} WHERE id = ?`, [taskId]);
	if (!row || typeof row[0] !== "string") return undefined;
	return toStr(row[0]);
}

function getLatestMainSessionByProjectRoot(projectRoot: string): AgentSessionItem | undefined {
	if (!isValidProjectRoot(projectRoot)) return undefined;
	const row = queryOne(
		`SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at
		FROM ${TABLE_SESSION}
		WHERE project_root = ? AND kind = 'main'
		ORDER BY updated_at DESC, id DESC
		LIMIT 1`,
		[projectRoot],
	);
	return row ? rowToSession(row as any[]) : undefined;
}

function countRunningSubSessions(rootSessionId: number): number {
	const rows = queryRows(
		`SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at
		FROM ${TABLE_SESSION}
		WHERE root_session_id = ? AND kind = 'sub'
		ORDER BY id ASC`,
		[rootSessionId],
	) ?? [];
	let count = 0;
	for (let i = 0; i < rows.length; i++) {
		const session = normalizeSessionRuntimeState(rowToSession(rows[i] as any[]));
		if (session.currentTaskStatus === "RUNNING") {
			count++;
		}
	}
	return count;
}

function deleteSessionRecords(sessionId: number, preserveArtifacts = false) {
	const session = getSessionItem(sessionId);
	const children = queryRows(`SELECT id FROM ${TABLE_SESSION} WHERE parent_session_id = ?`, [sessionId]) ?? [];
	for (let i = 0; i < children.length; i++) {
		const row = children[i] as any[];
		if (typeof row[0] === "number" && row[0] > 0) {
			deleteSessionRecords(row[0] as number, preserveArtifacts);
		}
	}
	DB.exec(`DELETE FROM ${TABLE_SESSION} WHERE parent_session_id = ?`, [sessionId]);
	DB.exec(`DELETE FROM ${TABLE_STEP} WHERE session_id = ?`, [sessionId]);
	DB.exec(`DELETE FROM ${TABLE_MESSAGE} WHERE session_id = ?`, [sessionId]);
	DB.exec(`DELETE FROM ${TABLE_SESSION} WHERE id = ?`, [sessionId]);
	if (!preserveArtifacts && session && session.kind === "sub" && session.memoryScope !== "") {
		Content.remove(Path(session.projectRoot, ".agent", session.memoryScope));
	}
}

function getSessionRootId(session: AgentSessionItem): number {
	return session.rootSessionId > 0 ? session.rootSessionId : session.id;
}

function getRootSessionItem(sessionId: number): AgentSessionItem | undefined {
	const session = getSessionItem(sessionId);
	if (!session) return undefined;
	return getSessionItem(getSessionRootId(session)) ?? session;
}

function listRelatedSessions(sessionId: number): AgentSessionItem[] {
	const root = getRootSessionItem(sessionId);
	if (!root) return [];
	const rows = queryRows(
		`SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at
		FROM ${TABLE_SESSION}
		WHERE id = ? OR root_session_id = ?
		ORDER BY
			CASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,
			id ASC`,
		[root.id, root.id],
	) ?? [];
	return rows.map(row => normalizeSessionRuntimeState(rowToSession(row as any[])));
}

function getSessionSpawnInfo(session: AgentSessionItem): AgentSessionSpawnInfo | undefined {
	const info = readSpawnInfo(session.projectRoot, session.memoryScope);
	if (!info) return undefined;
	return {
		sessionId: typeof info.sessionId === "number" ? info.sessionId : undefined,
		rootSessionId: typeof info.rootSessionId === "number" ? info.rootSessionId : undefined,
		parentSessionId: typeof info.parentSessionId === "number" ? info.parentSessionId : undefined,
		title: typeof info.title === "string" ? sanitizeUTF8(info.title) : undefined,
		prompt: typeof info.prompt === "string" ? sanitizeUTF8(info.prompt) : "",
		goal: typeof info.goal === "string" ? sanitizeUTF8(info.goal) : "",
		expectedOutput: typeof info.expectedOutput === "string" ? sanitizeUTF8(info.expectedOutput) : undefined,
		filesHint: Array.isArray(info.filesHint)
			? (info.filesHint as unknown[]).filter(item => typeof item === "string").map(item => sanitizeUTF8(item as string))
			: undefined,
		status: sanitizeUTF8(toStr(info.status)) === "FAILED"
			? "FAILED"
			: (sanitizeUTF8(toStr(info.status)) === "STOPPED" ? "STOPPED" : (sanitizeUTF8(toStr(info.status)) === "DONE" ? "DONE" : (sanitizeUTF8(toStr(info.status)) === "RUNNING" ? "RUNNING" : undefined))),
		success: info.success === true ? true : (info.success === false ? false : undefined),
		cleared: info.cleared === true ? true : undefined,
		resultFilePath: typeof info.resultFilePath === "string" ? sanitizeUTF8(info.resultFilePath) : undefined,
		artifactDir: typeof info.artifactDir === "string" ? sanitizeUTF8(info.artifactDir) : undefined,
		sourceTaskId: typeof info.sourceTaskId === "number" ? info.sourceTaskId : undefined,
		changeSet: decodeChangeSetSummary(info.changeSet),
		memoryEntry: decodeSubAgentMemoryEntry(info.memoryEntry),
		memoryEntryError: typeof info.memoryEntryError === "string" ? sanitizeUTF8(info.memoryEntryError) : undefined,
		createdAt: typeof info.createdAt === "string" ? sanitizeUTF8(info.createdAt) : undefined,
		finishedAt: typeof info.finishedAt === "string" ? sanitizeUTF8(info.finishedAt) : undefined,
		createdAtTs: typeof info.createdAtTs === "number" ? info.createdAtTs : undefined,
		finishedAtTs: typeof info.finishedAtTs === "number" ? info.finishedAtTs : undefined,
	};
}

function rebaseProjectRoot(projectRoot: string, oldRoot: string, newRoot: string) {
	if (projectRoot === oldRoot) {
		return newRoot;
	}
	for (const separator of ["/", "\\"]) {
		const prefix = `${oldRoot}${separator}`;
		if (projectRoot.startsWith(prefix)) {
			return `${newRoot}${projectRoot.slice(oldRoot.length)}`;
		}
	}
	return undefined;
}

function ensureDirRecursive(dir: string): boolean {
	if (!dir || dir === "") return false;
	if (Content.exist(dir)) return Content.isdir(dir);
	const parent = Path.getPath(dir);
	if (parent && parent !== dir && !Content.exist(parent)) {
		if (!ensureDirRecursive(parent)) {
			return false;
		}
	}
	return Content.mkdir(dir);
}

function writeSpawnInfo(projectRoot: string, memoryScope: string, value: Record<string, unknown>): boolean {
	const dir = Path(projectRoot, ".agent", memoryScope);
	if (!Content.exist(dir)) {
		ensureDirRecursive(dir);
	}
	const path = Path(dir, SPAWN_INFO_FILE);
	const [text] = safeJsonEncode(value as object);
	if (!text) return false;
	const content = `${text}\n`;
	if (!Content.save(path, content)) {
		return false;
	}
	Tools.sendWebIDEFileUpdate(path, true, content);
	return true;
}

function readSpawnInfo(projectRoot: string, memoryScope: string): Record<string, unknown> | undefined {
	const path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE);
	if (!Content.exist(path)) return undefined;
	const text = Content.load(path) as string;
	if (!text || text.trim() === "") return undefined;
	const [value] = safeJsonDecode(text);
	if (value && !Array.isArray(value) && type(value) === "table") {
		return value as Record<string, unknown>;
	}
	return undefined;
}

function getArtifactRelativeDir(memoryScope: string): string {
	return Path(".agent", memoryScope);
}

function getArtifactDir(projectRoot: string, memoryScope: string): string {
	return Path(projectRoot, getArtifactRelativeDir(memoryScope));
}

function getResultRelativePath(memoryScope: string): string {
	return Path(getArtifactRelativeDir(memoryScope), RESULT_FILE);
}

function getResultPath(projectRoot: string, memoryScope: string): string {
	return Path(projectRoot, getResultRelativePath(memoryScope));
}

function readSubAgentResultSummary(projectRoot: string, resultFilePath: string): string {
	if (!resultFilePath || resultFilePath === "") return "";
	const path = Path(projectRoot, resultFilePath);
	if (!Content.exist(path)) return "";
	const text = sanitizeUTF8(Content.load(path) as string);
	if (!text || text.trim() === "") return "";
	const marker = "\n## Summary\n";
	const [start] = string.find(text, marker, 1, true);
	if (start !== undefined) {
		return string.sub(text, start + marker.length).trim();
	}
	return text.trim();
}

function buildSubAgentMemoryEntryLLMOptions(llmConfig: LLMConfig): Record<string, unknown> {
	const options: Record<string, unknown> = {
		temperature: llmConfig.temperature ?? SUB_AGENT_MEMORY_ENTRY_LLM_TEMPERATURE,
		max_tokens: math.min(llmConfig.maxTokens ?? SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS, SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TOKENS),
	};
	if (llmConfig.reasoningEffort) {
		options.reasoning_effort = llmConfig.reasoningEffort.trim();
	}
	if (typeof options.reasoning_effort !== "string" || options.reasoning_effort.trim() === "") {
		delete options.reasoning_effort;
	}
	return options;
}

function buildSubAgentMemoryEntryToolSchema() {
	return [{
		type: "function" as const,
		function: {
			name: "save_sub_agent_memory_entry",
			description: "Save one durable memory paragraph extracted from a completed sub-agent session.",
			parameters: {
				type: "object",
				properties: {
					content: {
						type: "string",
						description: "A concise paragraph of key information worth carrying into future main-agent context. Use an empty string when nothing durable should be saved.",
					},
					evidence: {
						type: "array",
						items: { type: "string" },
						description: "Optional short file paths, artifact paths, or concrete anchors that support the memory paragraph.",
					},
				},
				required: ["content"],
			},
		},
	}];
}

function buildSubAgentMemoryEntrySystemPrompt(): string {
	return `You generate a durable memory entry for the parent Dora agent.
Prefer calling save_sub_agent_memory_entry when tool calling is available.
If you cannot call tools, output exactly one JSON object with this shape: {"content":"...","evidence":["..."]}.

Use the completed sub-agent conversation and final result to decide whether anything should be remembered.
Return a single compact paragraph in content, similar to a history entry.
Focus on durable facts: implemented behavior, important design decisions, constraints, discovered project conventions, or follow-up risks.
Do not include generic progress narration, praise, or temporary execution details.
If there is no information likely to help future work, set content to an empty string.
Keep evidence short and concrete, such as touched file paths or result artifact paths.`;
}

function formatSubAgentMemoryTailMessage(message: Message): string {
	const lines: string[] = [`role: ${sanitizeUTF8(toStr(message.role))}`];
	if (typeof message.name === "string" && message.name !== "") {
		lines.push(`name: ${sanitizeUTF8(message.name)}`);
	}
	if (typeof message.tool_call_id === "string" && message.tool_call_id !== "") {
		lines.push(`tool_call_id: ${sanitizeUTF8(message.tool_call_id)}`);
	}
	const content = typeof message.content === "string"
		? clipTextToTokenBudget(sanitizeUTF8(message.content), SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS)
		: "";
	if (content !== "") {
		lines.push(`content:\n${content}`);
	}
	if (Array.isArray(message.tool_calls) && message.tool_calls.length > 0) {
		const [toolCallsText] = safeJsonEncode(message.tool_calls as object);
		if (toolCallsText !== undefined && toolCallsText !== "") {
			lines.push(`tool_calls:\n${clipTextToTokenBudget(toolCallsText, SUB_AGENT_MEMORY_TAIL_MESSAGE_MAX_TOKENS)}`);
		}
	}
	return lines.join("\n");
}

function buildSubAgentRecentMessageTail(messages: Message[]): string {
	const parts: string[] = [];
	let totalTokens = 0;
	let count = 0;
	for (let i = messages.length - 1; i >= 0 && count < SUB_AGENT_MEMORY_TAIL_MAX_MESSAGES; i--) {
		const text = formatSubAgentMemoryTailMessage(messages[i]);
		if (text === "") continue;
		const tokens = estimateTextTokens(text);
		if (parts.length > 0 && totalTokens + tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS) break;
		if (tokens > SUB_AGENT_MEMORY_TAIL_MAX_TOKENS && parts.length === 0) {
			parts.unshift(clipTextToTokenBudget(text, SUB_AGENT_MEMORY_TAIL_MAX_TOKENS));
			break;
		}
		parts.unshift(text);
		totalTokens += tokens;
		count += 1;
	}
	return parts.length > 0 ? parts.join("\n\n---\n\n") : "(empty)";
}

function buildSubAgentMemoryEntryPrompt(record: SubAgentResultRecord, resultText: string, memoryContext: string, recentMessageTail: string): string {
	const files = record.changeSet?.files ?? [];
	const changedFiles = files.map(file => `- ${file.path} (${file.op})`).join("\n");
	const boundedMemoryContext = clipTextToTokenBudget(memoryContext !== "" ? memoryContext : "(empty)", SUB_AGENT_MEMORY_CONTEXT_MAX_TOKENS);
	const boundedResultText = clipTextToTokenBudget(resultText !== "" ? resultText : "(empty)", SUB_AGENT_MEMORY_RESULT_MAX_TOKENS);
	return `Sub-agent memory context:
${boundedMemoryContext}

Sub-agent task metadata:
- sessionId: ${tostring(record.sessionId)}
- taskId: ${tostring(record.sourceTaskId)}
- title: ${record.title}
- goal: ${record.goal}
- prompt: ${record.prompt}
- expectedOutput: ${record.expectedOutput ?? ""}
- resultFilePath: ${record.resultFilePath}
- finishedAt: ${record.finishedAt}

Changed files:
${changedFiles !== "" ? changedFiles : "- none"}

Final sub-agent result:
${boundedResultText}

Recent conversation tail:
${recentMessageTail}

Generate the memory entry now.`;
}

function buildSubAgentMemoryEntryRetryPrompt(lastError: string): string {
	return `Previous memory entry response was invalid: ${lastError}

Retry with exactly one JSON object and no Markdown fences, no prose, no tool call.
Schema:
{"content":"one concise durable memory paragraph, or empty string if nothing should be saved","evidence":["optional short file path or artifact path"]}

Rules:
- content must be a string.
- evidence must be an array of strings.
- Use {"content":"","evidence":[]} when there is no durable memory to save.`;
}

function normalizeGeneratedSubAgentMemoryEntry(value: unknown, record: SubAgentResultRecord): AgentSubAgentMemoryEntryItem | undefined {
	if (!value || Array.isArray(value) || type(value) !== "table") return undefined;
	const row = value as Record<string, unknown>;
	const content = takeUtf8Head(sanitizeUTF8(toStr(row.content)).trim(), SUB_AGENT_MEMORY_ENTRY_MAX_CHARS);
	if (content === "") return undefined;
	return {
		sourceSessionId: record.sessionId,
		sourceTaskId: record.sourceTaskId,
		content,
		evidence: normalizeMemoryEntryEvidence(row.evidence),
		createdAt: record.finishedAt,
	};
}

function getMemoryEntryToolFunction(response: unknown): ToolCallFunction | undefined {
	if (!response || Array.isArray(response) || type(response) !== "table") return undefined;
	const row = response as Record<string, any>;
	const choices = row.choices;
	if (!Array.isArray(choices) || choices.length === 0) return undefined;
	const message = choices[0]?.message;
	const toolCalls = message?.tool_calls;
	if (!Array.isArray(toolCalls)) return undefined;
	for (let i = 0; i < toolCalls.length; i++) {
		const fn = toolCalls[i]?.function as ToolCallFunction | undefined;
		if (fn?.name === "save_sub_agent_memory_entry") return fn;
	}
	return undefined;
}

function getMemoryEntryPlainContent(response: unknown): string {
	if (!response || Array.isArray(response) || type(response) !== "table") return "";
	const row = response as Record<string, any>;
	const choices = row.choices;
	if (!Array.isArray(choices) || choices.length === 0) return "";
	const message = choices[0]?.message;
	return typeof message?.content === "string" ? sanitizeUTF8(message.content).trim() : "";
}

function decodeMemoryEntryFromPlainContent(content: string): unknown {
	if (content === "") return undefined;
	const [direct] = safeJsonDecode(content);
	if (direct !== undefined) return direct;
	const [start] = string.find(content, "{", 1, true);
	if (start === undefined) return undefined;
	let end = content.length;
	while (end >= start) {
		const candidate = string.sub(content, start, end);
		const [value] = safeJsonDecode(candidate);
		if (value !== undefined) return value;
		end -= 1;
	}
	return undefined;
}

function hasEmptyMemoryEntryContent(value: unknown): boolean {
	if (!value || Array.isArray(value) || type(value) !== "table") return false;
	const row = value as Record<string, unknown>;
	return typeof row.content === "string" && sanitizeUTF8(row.content).trim() === "";
}

async function generateSubAgentMemoryEntry(session: AgentSessionItem, record: SubAgentResultRecord, resultText: string): Promise<{ entry?: AgentSubAgentMemoryEntryItem; error?: string }> {
	if (!record.success) return {};
	const configRes = getActiveLLMConfig();
	if (!configRes.success) {
		return { error: configRes.message };
	}
	const storage = new DualLayerStorage(session.projectRoot, session.memoryScope);
	const persisted = storage.readSessionState();
	const memoryContext = storage.readMemory();
	const recentMessageTail = buildSubAgentRecentMessageTail(persisted.messages);
	const prompt = buildSubAgentMemoryEntryPrompt(record, resultText, memoryContext, recentMessageTail);
	const tools = configRes.config.supportsFunctionCalling ? buildSubAgentMemoryEntryToolSchema() : undefined;
	let lastError = "missing memory entry";
	for (let attempt = 0; attempt < SUB_AGENT_MEMORY_ENTRY_LLM_MAX_TRY; attempt++) {
		const useTools = attempt === 0 && tools !== undefined;
		const messages: Message[] = [
			{ role: "system", content: buildSubAgentMemoryEntrySystemPrompt() },
			{
				role: "user",
				content: attempt === 0
					? prompt
					: `${prompt}\n\n${buildSubAgentMemoryEntryRetryPrompt(lastError)}`,
			},
		];
		const response = await callLLM(
			messages,
			{
				...buildSubAgentMemoryEntryLLMOptions(configRes.config),
				...(useTools ? { tools } : {}),
			},
			configRes.config,
		);
		if (!response.success) {
			lastError = response.message;
			if (useTools) {
				Log("Warn", `[AgentSession] sub session memory entry tool request failed, retrying without tools: ${response.message}`);
			}
			continue;
		}
		const fn = getMemoryEntryToolFunction(response.response);
		const argsText = fn && typeof fn.arguments === "string" ? fn.arguments : "";
		if (fn !== undefined && argsText !== "") {
			const [args, err] = safeJsonDecode(argsText);
			if (err !== undefined || args === undefined) {
				lastError = `invalid memory entry tool arguments: ${tostring(err)}`;
				continue;
			}
			if (hasEmptyMemoryEntryContent(args)) return {};
			const entry = normalizeGeneratedSubAgentMemoryEntry(args, record);
			if (entry !== undefined) return { entry };
			lastError = "invalid memory entry tool arguments shape";
			continue;
		}
		const plainContent = getMemoryEntryPlainContent(response.response);
		const plainArgs = decodeMemoryEntryFromPlainContent(plainContent);
		if (plainArgs !== undefined) {
			if (hasEmptyMemoryEntryContent(plainArgs)) return {};
			const entry = normalizeGeneratedSubAgentMemoryEntry(plainArgs, record);
			if (entry !== undefined) return { entry };
			lastError = "invalid memory entry JSON shape";
			continue;
		}
		lastError = "LLM did not return memory entry tool call or JSON content";
	}
	return { error: lastError };
}

function containsNormalizedText(text: string, query: string): boolean {
	const normalizedText = string.lower(sanitizeUTF8(text ?? ""));
	const normalizedQuery = string.lower(sanitizeUTF8(query ?? ""));
	if (normalizedQuery === "") return true;
	return string.find(normalizedText, normalizedQuery, 1, true) !== undefined;
}

function getSubAgentDisplayKey(item: {
	title?: string;
	goal?: string;
	parentSessionId?: number;
	rootSessionId: number;
}): string {
	const goal = string.lower(sanitizeUTF8(item.goal ?? "").trim());
	const title = string.lower(sanitizeUTF8(item.title ?? "").trim());
	const label = goal !== "" ? goal : title;
	return `${tostring(item.rootSessionId)}:${tostring(item.parentSessionId ?? 0)}:${label}`;
}

function writeSubAgentResultFile(session: AgentSessionItem, record: SubAgentResultRecord, resultText: string): boolean {
	const dir = getArtifactDir(session.projectRoot, session.memoryScope);
	if (!Content.exist(dir)) {
		ensureDirRecursive(dir);
	}
	const lines = [
		`# ${record.title !== "" ? record.title : `Sub Agent ${tostring(record.sessionId)}`}`,
		`- Status: ${record.status}`,
		`- Success: ${record.success ? "true" : "false"}`,
		`- Session ID: ${tostring(record.sessionId)}`,
		`- Source Task ID: ${tostring(record.sourceTaskId)}`,
		`- Goal: ${record.goal}`,
		...(record.expectedOutput && record.expectedOutput !== "" ? [`- Expected Output: ${record.expectedOutput}`] : []),
		...(record.filesHint && record.filesHint.length > 0 ? [`- Files Hint: ${record.filesHint.join(", ")}`] : []),
		`- Finished At: ${record.finishedAt}`,
		"",
		"## Summary",
		resultText !== "" ? resultText : "(empty)",
	];
	const path = getResultPath(session.projectRoot, session.memoryScope);
	const content = `${lines.join("\n")}\n`;
	if (!Content.save(path, content)) {
		return false;
	}
	Tools.sendWebIDEFileUpdate(path, true, content);
	return true;
}

function listSubAgentResultRecords(projectRoot: string, rootSessionId: number): SubAgentResultRecord[] {
	const dir = Path(projectRoot, ".agent", "subagents");
	if (!Content.exist(dir) || !Content.isdir(dir)) return [];
	const items: SubAgentResultRecord[] = [];
	for (const rawPath of Content.getDirs(dir)) {
		const path = Content.isAbsolutePath(rawPath) ? rawPath : Path(dir, rawPath);
		if (!Content.exist(path) || !Content.isdir(path)) continue;
		const info = readSpawnInfo(projectRoot, Path("subagents", Path.getFilename(path)));
		if (!info) continue;
		const sessionId = tonumber((info as any).sessionId);
		const infoRootSessionId = tonumber((info as any).rootSessionId);
		const sourceTaskId = tonumber((info as any).sourceTaskId);
		const status = sanitizeUTF8(toStr((info as any).status));
		if (!(sessionId && sessionId > 0) || !(infoRootSessionId && infoRootSessionId > 0) || infoRootSessionId !== rootSessionId) continue;
		if (status !== "DONE" && status !== "FAILED" && status !== "STOPPED") continue;
		items.push({
			sessionId,
			rootSessionId: infoRootSessionId,
			parentSessionId: tonumber((info as any).parentSessionId) || undefined,
			title: sanitizeUTF8(toStr((info as any).title)),
			prompt: sanitizeUTF8(toStr((info as any).prompt)),
			goal: sanitizeUTF8(toStr((info as any).goal)),
			expectedOutput: sanitizeUTF8(toStr((info as any).expectedOutput)),
			filesHint: Array.isArray((info as any).filesHint)
				? ((info as any).filesHint as unknown[]).filter(item => typeof item === "string").map(item => sanitizeUTF8(item as string))
				: [],
			status: status === "FAILED" ? "FAILED" : (status === "STOPPED" ? "STOPPED" : "DONE"),
			success: (info as any).success === true,
			cleared: (info as any).cleared === true,
			resultFilePath: sanitizeUTF8(toStr((info as any).resultFilePath)),
			artifactDir: sanitizeUTF8(toStr((info as any).artifactDir)) || getArtifactRelativeDir(Path("subagents", Path.getFilename(path))),
			sourceTaskId: sourceTaskId || 0,
			changeSet: decodeChangeSetSummary((info as any).changeSet),
			memoryEntry: decodeSubAgentMemoryEntry((info as any).memoryEntry),
			memoryEntryError: sanitizeUTF8(toStr((info as any).memoryEntryError)),
			createdAt: sanitizeUTF8(toStr((info as any).createdAt)),
			finishedAt: sanitizeUTF8(toStr((info as any).finishedAt)),
			createdAtTs: tonumber((info as any).createdAtTs) || 0,
			finishedAtTs: tonumber((info as any).finishedAtTs) || 0,
		});
	}
	items.sort((a, b) => a.finishedAtTs > b.finishedAtTs ? -1 : (a.finishedAtTs < b.finishedAtTs ? 1 : 0));
	return items;
}

function getPendingHandoffDir(projectRoot: string, memoryScope: string): string {
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR);
}

function writePendingHandoff(projectRoot: string, memoryScope: string, value: PendingSubAgentHandoffItem): boolean {
	const dir = getPendingHandoffDir(projectRoot, memoryScope);
	if (!Content.exist(dir)) {
		ensureDirRecursive(dir);
	}
	const path = Path(dir, `${value.id}.json`);
	const [text] = safeJsonEncode(value as unknown as object);
	if (!text) return false;
	return Content.save(path, `${text}\n`);
}

function listPendingHandoffs(projectRoot: string, memoryScope: string): PendingSubAgentHandoffItem[] {
	const dir = getPendingHandoffDir(projectRoot, memoryScope);
	if (!Content.exist(dir) || !Content.isdir(dir)) return [];
	const items: PendingSubAgentHandoffItem[] = [];
	for (const rawPath of Content.getFiles(dir)) {
		const path = Content.isAbsolutePath(rawPath) ? rawPath : Path(dir, rawPath);
		if (!path.endsWith(".json") || !Content.exist(path)) continue;
		const text = Content.load(path) as string;
		if (!text || text.trim() === "") continue;
		const [value] = safeJsonDecode(text);
		if (!value || Array.isArray(value) || type(value) !== "table") continue;
		const sourceTaskId = tonumber((value as any).sourceTaskId);
		const sourceSessionId = tonumber((value as any).sourceSessionId);
		const id = sanitizeUTF8(toStr((value as any).id));
		const sourceTitle = sanitizeUTF8(toStr((value as any).sourceTitle));
		const message = sanitizeUTF8(toStr((value as any).message));
		const prompt = sanitizeUTF8(toStr((value as any).prompt));
		const goal = sanitizeUTF8(toStr((value as any).goal));
		const createdAt = sanitizeUTF8(toStr((value as any).createdAt));
		if (!(sourceTaskId && sourceTaskId > 0) || !(sourceSessionId && sourceSessionId > 0) || id === "" || createdAt === "") {
			continue;
		}
		items.push({
			id,
			sourceSessionId,
			sourceTitle,
			sourceTaskId,
			message,
			prompt,
			goal,
			expectedOutput: sanitizeUTF8(toStr((value as any).expectedOutput)),
			filesHint: Array.isArray((value as any).filesHint)
				? ((value as any).filesHint as unknown[]).filter(item => typeof item === "string").map(item => sanitizeUTF8(item as string))
				: [],
			success: (value as any).success === true,
			resultFilePath: sanitizeUTF8(toStr((value as any).resultFilePath)),
			artifactDir: sanitizeUTF8(toStr((value as any).artifactDir)),
			finishedAt: sanitizeUTF8(toStr((value as any).finishedAt)),
			changeSet: decodeChangeSetSummary((value as any).changeSet),
			memoryEntry: decodeSubAgentMemoryEntry((value as any).memoryEntry),
			createdAt,
		});
	}
	items.sort((a, b) => a.id < b.id ? -1 : (a.id > b.id ? 1 : 0));
	return items;
}

function deletePendingHandoff(projectRoot: string, memoryScope: string, id: string): void {
	const path = Path(getPendingHandoffDir(projectRoot, memoryScope), `${id}.json`);
	if (Content.exist(path)) {
		Content.remove(path);
	}
}

function normalizePromptText(prompt: string): string {
	return truncateAgentUserPrompt(prompt ?? "").trim();
}

function normalizePromptTextSafe(prompt: unknown): string {
	if (typeof prompt === "string") {
		const normalized = normalizePromptText(prompt);
		if (normalized !== "") return normalized;
		const sanitized = sanitizeUTF8(prompt).trim();
		if (sanitized !== "") {
			return truncateAgentUserPrompt(sanitized);
		}
		return "";
	}
	const text = sanitizeUTF8(toStr(prompt)).trim();
	if (text === "") return "";
	return truncateAgentUserPrompt(text);
}

function buildSubAgentPromptFallback(title: string, expectedOutput?: string, filesHint?: string[]): string {
	const sections: string[] = [];
	const normalizedTitle = sanitizeUTF8(title ?? "").trim();
	const normalizedExpected = sanitizeUTF8(expectedOutput ?? "").trim();
	const normalizedFiles = (filesHint ?? [])
		.filter(item => typeof item === "string")
		.map(item => sanitizeUTF8(item).trim())
		.filter(item => item !== "");
	if (normalizedTitle !== "") {
		sections.push(`Task: ${normalizedTitle}`);
	}
	if (normalizedExpected !== "") {
		sections.push(`Expected output: ${normalizedExpected}`);
	}
	if (normalizedFiles.length > 0) {
		sections.push(`Files hint:\n- ${normalizedFiles.join("\n- ")}`);
	}
	return sections.join("\n\n").trim();
}

function normalizeSessionRuntimeState(session: AgentSessionItem): AgentSessionItem {
	if (session.currentTaskId === undefined || session.currentTaskStatus !== "RUNNING") {
		return session;
	}
	if (activeStopTokens[session.currentTaskId]) {
		return session;
	}
	Tools.setTaskStatus(session.currentTaskId, "STOPPED");
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED");
	return {
		...session,
		status: "STOPPED",
		currentTaskStatus: "STOPPED",
		updatedAt: now(),
	};
}

function setSessionState(sessionId: number, status: AgentSessionStatus, currentTaskId?: number, currentTaskStatus?: AgentSessionStatus) {
	DB.exec(
		`UPDATE ${TABLE_SESSION}
		SET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?
		WHERE id = ?`,
		[
			status,
			currentTaskId ?? 0,
			currentTaskStatus ?? status,
			now(),
			sessionId,
		],
	);
}

function setSessionStateForTaskEvent(sessionId: number, taskId: number | undefined, status: AgentSessionStatus, currentTaskStatus?: AgentSessionStatus) {
	if (taskId === undefined || taskId <= 0) {
		setSessionState(sessionId, status, taskId, currentTaskStatus);
		return;
	}
	const row = getSessionRow(sessionId);
	if (!row) return;
	const session = rowToSession(row as any[]);
	if (session.currentTaskId !== taskId) {
		Log("Info", `[AgentSession] ignore stale task event session=${sessionId} eventTask=${taskId} currentTask=${tostring(session.currentTaskId)}`);
		return;
	}
	setSessionState(sessionId, status, taskId, currentTaskStatus);
}

function insertMessage(sessionId: number, role: AgentMessageRole, content: string, taskId?: number): number {
	const t = now();
	DB.exec(
		`INSERT INTO ${TABLE_MESSAGE}(session_id, task_id, role, content, created_at, updated_at)
		VALUES(?, ?, ?, ?, ?, ?)`,
		[
			sessionId,
			taskId ?? 0,
			role,
			sanitizeUTF8(content),
			t,
			t,
		],
	);
	return getLastInsertRowId();
}

function updateMessage(messageId: number, content: string) {
	DB.exec(
		`UPDATE ${TABLE_MESSAGE} SET content = ?, updated_at = ? WHERE id = ?`,
		[sanitizeUTF8(content), now(), messageId],
	);
}

function upsertAssistantMessage(sessionId: number, taskId: number, content: string): number {
	const row = queryOne(
		`SELECT id FROM ${TABLE_MESSAGE}
		WHERE session_id = ? AND task_id = ? AND role = ?
		ORDER BY id DESC LIMIT 1`,
		[sessionId, taskId, "assistant"],
	);
	if (row && typeof row[0] === "number") {
		updateMessage(row[0], content);
		return row[0];
	}
	return insertMessage(sessionId, "assistant", content, taskId);
}

function upsertStep(sessionId: number, taskId: number, step: number, tool: string, patch: {
	status?: AgentStepStatus;
	reason?: string;
	reasoningContent?: string;
	params?: Record<string, unknown>;
	result?: Record<string, unknown>;
	checkpointId?: number;
	checkpointSeq?: number;
	files?: { path: string; op: string }[];
}) {
	const row = queryOne(
		`SELECT id FROM ${TABLE_STEP} WHERE session_id = ? AND task_id = ? AND step = ?`,
		[sessionId, taskId, step],
	);
	const reason = sanitizeUTF8(patch.reason ?? "");
	const reasoningContent = sanitizeUTF8(patch.reasoningContent ?? "");
	const paramsJson = patch.params ? encodeJson(patch.params) : "";
	const resultJson = patch.result ? encodeJson(patch.result) : "";
	const filesJson = patch.files ? encodeJson(patch.files) : "";
	const statusPatch = patch.status ?? "";
	const status = patch.status ?? "PENDING";
	if (!row) {
		const t = now();
		DB.exec(
			`INSERT INTO ${TABLE_STEP}(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)
			VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			[
				sessionId,
				taskId,
				step,
				tool,
				status,
				reason,
				reasoningContent,
				paramsJson,
				resultJson,
				patch.checkpointId ?? 0,
				patch.checkpointSeq ?? 0,
				filesJson,
				t,
				t,
			],
		);
		return;
	}
	DB.exec(
		`UPDATE ${TABLE_STEP}
		SET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,
			reason = CASE WHEN ? = '' THEN reason ELSE ? END,
			reasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,
			params_json = CASE WHEN ? = '' THEN params_json ELSE ? END,
			result_json = CASE WHEN ? = '' THEN result_json ELSE ? END,
			checkpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,
			checkpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,
			files_json = CASE WHEN ? = '' THEN files_json ELSE ? END,
			updated_at = ?
		WHERE id = ?`,
		[
			tool,
			statusPatch,
			status,
			reason,
			reason,
			reasoningContent,
			reasoningContent,
			paramsJson,
			paramsJson,
			resultJson,
			resultJson,
			patch.checkpointId ?? 0,
			patch.checkpointId ?? 0,
			patch.checkpointSeq ?? 0,
			patch.checkpointSeq ?? 0,
			filesJson,
			filesJson,
			now(),
			row[0] as number,
		],
	);
}

function getNextStepNumber(sessionId: number, taskId: number): number {
	const row = queryOne(
		`SELECT MAX(step) FROM ${TABLE_STEP} WHERE session_id = ? AND task_id = ?`,
		[sessionId, taskId],
	);
	const current = row && typeof row[0] === "number" ? row[0] as number : 0;
	return math.max(0, current) + 1;
}

function appendSystemStep(
	sessionId: number,
	taskId: number,
	tool: string,
	_systemType: string,
	reason: string,
	result?: Record<string, unknown>,
	params?: Record<string, unknown>,
	status: AgentStepStatus = "DONE",
): AgentSessionStepItem | undefined {
	const step = getNextStepNumber(sessionId, taskId);
	upsertStep(sessionId, taskId, step, tool, {
		status,
		reason,
		params,
		result,
	});
	return getStepItem(sessionId, taskId, step);
}

function finalizeTaskSteps(sessionId: number, taskId: number, finalSteps?: number, finalStatus?: AgentStepStatus) {
	if (taskId <= 0) return;
	if (finalSteps !== undefined && finalSteps >= 0) {
		DB.exec(
			`DELETE FROM ${TABLE_STEP}
			WHERE session_id = ? AND task_id = ? AND step > ?`,
			[sessionId, taskId, finalSteps],
		);
	}
	if (!finalStatus) return;
	if (finalSteps !== undefined && finalSteps >= 0) {
		DB.exec(
			`UPDATE ${TABLE_STEP}
			SET status = ?, updated_at = ?
			WHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')`,
			[finalStatus, now(), sessionId, taskId, finalSteps],
		);
		return;
	}
	DB.exec(
		`UPDATE ${TABLE_STEP}
		SET status = ?, updated_at = ?
		WHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')`,
		[finalStatus, now(), sessionId, taskId],
	);
}

function sanitizeStoredSteps(sessionId: number) {
	DB.exec(
		`UPDATE ${TABLE_STEP}
		SET status = (
			CASE (
				SELECT status FROM ${TABLE_TASK}
				WHERE id = ${TABLE_STEP}.task_id
			)
				WHEN 'STOPPED' THEN 'STOPPED'
				ELSE 'FAILED'
			END
		),
		updated_at = ?
		WHERE session_id = ?
			AND status IN ('PENDING', 'RUNNING')
			AND COALESCE((
				SELECT status FROM ${TABLE_TASK}
				WHERE id = ${TABLE_STEP}.task_id
			), '') <> 'RUNNING'`,
		[now(), sessionId],
	);
}

function emitAgentSessionPatch(sessionId: number, patch: Record<string, unknown>) {
	if (HttpServer.wsConnectionCount === 0) {
		return;
	}
	const [text] = safeJsonEncode({
		name: "AgentSessionPatch",
		sessionId,
		...patch,
	} as object);
	if (!text) return;
	emit("AppWS", "Send", text);
}

function emitSessionDeletedPatch(sessionId: number, rootSessionId: number, projectRoot: string) {
	emitAgentSessionPatch(sessionId, {
		sessionDeleted: true,
		relatedSessions: listRelatedSessions(rootSessionId),
	});
	const rootSession = getSessionItem(rootSessionId);
	if (rootSession) {
		emitAgentSessionPatch(rootSessionId, {
			session: rootSession,
			relatedSessions: listRelatedSessions(rootSessionId),
		});
	}
}

function flushPendingSubAgentHandoffs(rootSession: AgentSessionItem): void {
	if (rootSession.kind !== "main") return;
	if (rootSession.currentTaskStatus === "RUNNING" && rootSession.currentTaskId && activeStopTokens[rootSession.currentTaskId]) {
		return;
	}
	const items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope);
	if (items.length === 0) return;
	let handoffTaskId = 0;
	const currentTaskPrompt = rootSession.currentTaskId ? getTaskPrompt(rootSession.currentTaskId) : undefined;
	if (
		rootSession.currentTaskId
		&& rootSession.currentTaskId > 0
		&& rootSession.currentTaskStatus !== "RUNNING"
		&& typeof currentTaskPrompt === "string"
		&& currentTaskPrompt.startsWith("[sub_agent_handoff]")
	) {
		handoffTaskId = rootSession.currentTaskId;
	} else {
		const taskRes = Tools.createTask(`[sub_agent_handoff] ${tostring(items.length)} item(s)`);
		if (!taskRes.success) {
			Log("Warn", `[AgentSession] failed to create sub-agent handoff task for root=${rootSession.id}: ${taskRes.message}`);
			return;
		}
		handoffTaskId = taskRes.taskId;
		Tools.setTaskStatus(handoffTaskId, "DONE");
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE");
		emitAgentSessionPatch(rootSession.id, {
			session: getSessionItem(rootSession.id),
		});
	}
	for (let i = 0; i < items.length; i++) {
		const item = items[i];
		const step = appendSystemStep(
			rootSession.id,
			handoffTaskId,
			"sub_agent_handoff",
			"sub_agent_handoff",
			item.message,
			{
				sourceSessionId: item.sourceSessionId,
				sourceTitle: item.sourceTitle,
				sourceTaskId: item.sourceTaskId,
				success: item.success === true,
				summary: item.message,
				resultFilePath: item.resultFilePath ?? "",
				artifactDir: item.artifactDir ?? "",
				finishedAt: item.finishedAt ?? "",
				changeSet: item.changeSet,
				memoryEntry: item.memoryEntry,
			},
			{
				sourceSessionId: item.sourceSessionId,
				sourceTitle: item.sourceTitle,
				sourceTaskId: item.sourceTaskId,
				prompt: item.prompt,
				goal: item.goal !== "" ? item.goal : item.sourceTitle,
				expectedOutput: item.expectedOutput ?? "",
				filesHint: item.filesHint ?? [],
				resultFilePath: item.resultFilePath ?? "",
				artifactDir: item.artifactDir ?? "",
				changeSet: item.changeSet,
				memoryEntry: item.memoryEntry,
			},
			"DONE",
		);
		if (step) {
			emitAgentSessionPatch(rootSession.id, { step });
		}
		deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id);
	}
}

function applyEvent(sessionId: number, event: CodingAgentEvent) {
	switch (event.type) {
		case "task_started":
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING");
			emitAgentSessionPatch(sessionId, {
				session: getSessionItem(sessionId),
			});
			break;
		case "decision_made":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				status: "PENDING",
				reason: event.reason,
				reasoningContent: event.reasoningContent,
				params: event.params,
			});
			emitAgentSessionPatch(sessionId, {
				step: getStepItem(sessionId, event.taskId, event.step),
			});
			break;
		case "tool_started":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				status: "RUNNING",
			});
			emitAgentSessionPatch(sessionId, {
				step: getStepItem(sessionId, event.taskId, event.step),
			});
			break;
		case "tool_finished":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				status: event.result.success === true ? "DONE" : "FAILED",
				reason: event.reason,
				result: event.result,
			});
			emitAgentSessionPatch(sessionId, {
				step: getStepItem(sessionId, event.taskId, event.step),
			});
			break;
		case "checkpoint_created":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				checkpointId: event.checkpointId,
				checkpointSeq: event.checkpointSeq,
				files: event.files,
			});
			emitAgentSessionPatch(sessionId, {
				step: getStepItem(sessionId, event.taskId, event.step),
				checkpoints: Tools.listCheckpoints(event.taskId),
			});
			break;
		case "memory_compression_started":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				status: "RUNNING",
				reason: event.reason,
				params: event.params,
			});
			emitAgentSessionPatch(sessionId, {
				step: getStepItem(sessionId, event.taskId, event.step),
			});
			break;
		case "memory_compression_finished":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				status: event.result.success === true ? "DONE" : "FAILED",
				reason: event.reason,
				result: event.result,
			});
			emitAgentSessionPatch(sessionId, {
				step: getStepItem(sessionId, event.taskId, event.step),
			});
			break;
		case "assistant_message_updated": {
			upsertStep(sessionId, event.taskId, event.step, "message", {
				status: "RUNNING",
				reason: event.content,
				reasoningContent: event.reasoningContent,
			});
			emitAgentSessionPatch(sessionId, {
				step: getStepItem(sessionId, event.taskId, event.step),
			});
			break;
		}
		case "task_finished": {
			const stopped = activeStopTokens[event.taskId ?? -1]?.stopped === true;
			const finalStatus: AgentSessionStatus = event.success
				? "DONE"
				: (stopped ? "STOPPED" : "FAILED");
			const session = getSessionItem(sessionId);
			const isSubSession = session?.kind === "sub";
			const sessionStatus: AgentSessionStatus = isSubSession ? "RUNNING" : finalStatus;
			if (isSubSession && event.taskId !== undefined) {
				finalizingSubSessionTaskIds[event.taskId] = true;
			}
			setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus);
			if (event.taskId !== undefined) {
				const removedStepIds = deleteMessageSteps(sessionId, event.taskId);
				finalizeTaskSteps(
					sessionId,
					event.taskId,
					typeof event.steps === "number" ? math.max(0, math.floor(event.steps)) : undefined,
					event.success ? undefined : (stopped ? "STOPPED" : "FAILED"),
				);
				const messageId = upsertAssistantMessage(sessionId, event.taskId, event.message);
				if (!isSubSession) {
					activeStopTokens[event.taskId] = undefined as any;
				}
				emitAgentSessionPatch(sessionId, {
					session: getSessionItem(sessionId),
					message: getMessageItem(messageId),
					checkpoints: Tools.listCheckpoints(event.taskId),
					removedStepIds,
				});
			}
			if (session && session.kind === "main") {
				flushPendingSubAgentHandoffs(session);
			}
			break;
		}
	}
}

function getSchemaVersion(): number {
	const row = queryOne("PRAGMA user_version");
	return row && typeof row[0] === "number" ? row[0] : 0;
}

function setSchemaVersion(version: number) {
	DB.exec(`PRAGMA user_version = ${math.max(0, math.floor(version))}`);
}

function recreateSchema() {
	DB.exec(`DROP TABLE IF EXISTS ${TABLE_STEP};`);
	DB.exec(`DROP TABLE IF EXISTS ${TABLE_MESSAGE};`);
	DB.exec(`DROP TABLE IF EXISTS ${TABLE_SESSION};`);
	DB.exec(`CREATE TABLE IF NOT EXISTS ${TABLE_SESSION}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		project_root TEXT NOT NULL,
		title TEXT NOT NULL DEFAULT '',
		kind TEXT NOT NULL DEFAULT 'main',
		root_session_id INTEGER NOT NULL DEFAULT 0,
		parent_session_id INTEGER,
		memory_scope TEXT NOT NULL DEFAULT 'main',
		status TEXT NOT NULL DEFAULT 'IDLE',
		current_task_id INTEGER,
		current_task_status TEXT NOT NULL DEFAULT 'IDLE',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);`);
	DB.exec(`CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON ${TABLE_SESSION}(project_root, updated_at DESC);`);
	DB.exec(`CREATE TABLE IF NOT EXISTS ${TABLE_MESSAGE}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		session_id INTEGER NOT NULL,
		task_id INTEGER,
		role TEXT NOT NULL,
		content TEXT NOT NULL DEFAULT '',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);`);
	DB.exec(`CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON ${TABLE_MESSAGE}(session_id, id);`);
	DB.exec(`CREATE TABLE IF NOT EXISTS ${TABLE_STEP}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		session_id INTEGER NOT NULL,
		task_id INTEGER NOT NULL,
		step INTEGER NOT NULL,
		tool TEXT NOT NULL DEFAULT '',
		status TEXT NOT NULL DEFAULT 'PENDING',
		reason TEXT NOT NULL DEFAULT '',
		reasoning_content TEXT NOT NULL DEFAULT '',
		params_json TEXT NOT NULL DEFAULT '',
		result_json TEXT NOT NULL DEFAULT '',
		checkpoint_id INTEGER,
		checkpoint_seq INTEGER,
		files_json TEXT NOT NULL DEFAULT '',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);`);
	DB.exec(`CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON ${TABLE_STEP}(session_id, task_id, step);`);
	DB.exec(`CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON ${TABLE_STEP}(session_id, task_id, step);`);
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION);
}

// initialize tables
{
	if (getSchemaVersion() !== AGENT_SESSION_SCHEMA_VERSION) {
		recreateSchema();
	} else {
		DB.exec(`CREATE TABLE IF NOT EXISTS ${TABLE_SESSION}(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			project_root TEXT NOT NULL,
			title TEXT NOT NULL DEFAULT '',
			kind TEXT NOT NULL DEFAULT 'main',
			root_session_id INTEGER NOT NULL DEFAULT 0,
			parent_session_id INTEGER,
			memory_scope TEXT NOT NULL DEFAULT 'main',
			status TEXT NOT NULL DEFAULT 'IDLE',
			current_task_id INTEGER,
			current_task_status TEXT NOT NULL DEFAULT 'IDLE',
			created_at INTEGER NOT NULL,
			updated_at INTEGER NOT NULL
		);`);
		DB.exec(`CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON ${TABLE_SESSION}(project_root, updated_at DESC);`);
		DB.exec(`CREATE TABLE IF NOT EXISTS ${TABLE_MESSAGE}(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			session_id INTEGER NOT NULL,
			task_id INTEGER,
			role TEXT NOT NULL,
			content TEXT NOT NULL DEFAULT '',
			created_at INTEGER NOT NULL,
			updated_at INTEGER NOT NULL
		);`);
		DB.exec(`CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON ${TABLE_MESSAGE}(session_id, id);`);
		DB.exec(`CREATE TABLE IF NOT EXISTS ${TABLE_STEP}(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			session_id INTEGER NOT NULL,
			task_id INTEGER NOT NULL,
			step INTEGER NOT NULL,
			tool TEXT NOT NULL DEFAULT '',
			status TEXT NOT NULL DEFAULT 'PENDING',
			reason TEXT NOT NULL DEFAULT '',
			reasoning_content TEXT NOT NULL DEFAULT '',
			params_json TEXT NOT NULL DEFAULT '',
			result_json TEXT NOT NULL DEFAULT '',
			checkpoint_id INTEGER,
			checkpoint_seq INTEGER,
			files_json TEXT NOT NULL DEFAULT '',
			created_at INTEGER NOT NULL,
			updated_at INTEGER NOT NULL
		);`);
		DB.exec(`CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON ${TABLE_STEP}(session_id, task_id, step);`);
		DB.exec(`CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON ${TABLE_STEP}(session_id, task_id, step);`);
	}
}

export function createSession(projectRoot: string, title = "") {
	if (!isValidProjectRoot(projectRoot)) {
		return { success: false as const, message: "invalid projectRoot" };
	}
	const row = queryOne(
		`SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at
		FROM ${TABLE_SESSION}
		WHERE project_root = ? AND kind = 'main'
		ORDER BY updated_at DESC, id DESC
		LIMIT 1`,
		[projectRoot],
	);
	if (row) {
		return { success: true as const, session: rowToSession(row as any[]) };
	}
	const t = now();
	DB.exec(
		`INSERT INTO ${TABLE_SESSION}(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)
		VALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)`,
		[projectRoot, title !== "" ? title : Path.getFilename(projectRoot), t, t],
	);
	const sessionId = getLastInsertRowId();
	DB.exec(`UPDATE ${TABLE_SESSION} SET root_session_id = ? WHERE id = ?`, [sessionId, sessionId]);
	const session = getSessionItem(sessionId);
	if (!session) {
		return { success: false as const, message: "failed to create session" };
	}
	return { success: true as const, session };
}

export function createSubSession(parentSessionId: number, title = "") {
	const parent = getSessionItem(parentSessionId);
	if (!parent) {
		return { success: false as const, message: "parent session not found" };
	}
	const rootId = getSessionRootId(parent);
	const t = now();
	DB.exec(
		`INSERT INTO ${TABLE_SESSION}(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)
		VALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)`,
		[parent.projectRoot, title !== "" ? title : `Sub ${tostring(rootId)}`, rootId, parent.id, t, t],
	);
	const sessionId = getLastInsertRowId();
	const memoryScope = `subagents/${tostring(sessionId)}`;
	DB.exec(`UPDATE ${TABLE_SESSION} SET memory_scope = ? WHERE id = ?`, [memoryScope, sessionId]);
	const session = getSessionItem(sessionId);
	if (!session) {
		return { success: false as const, message: "failed to create sub session" };
	}
	const parentStorage = new DualLayerStorage(parent.projectRoot, parent.memoryScope);
	const subStorage = new DualLayerStorage(parent.projectRoot, memoryScope);
	subStorage.writeMemory(parentStorage.readMemory());
	return { success: true as const, session };
}

async function spawnSubAgentSession(request: {
	parentSessionId: number;
	projectRoot?: string;
	title: string;
	prompt: string;
	expectedOutput?: string;
	filesHint?: string[];
}): Promise<
	| { success: true; sessionId: number; taskId: number; title: string }
	| { success: false; message: string }
> {
	const normalizedTitle = sanitizeUTF8(request.title ?? "").trim();
	const rawPrompt = typeof request.prompt === "string" ? request.prompt : toStr(request.prompt);
	let normalizedPrompt = normalizePromptTextSafe(request.prompt);
	if (normalizedPrompt === "") {
		normalizedPrompt = buildSubAgentPromptFallback(
			normalizedTitle,
			request.expectedOutput,
			request.filesHint,
		);
	}
	if (normalizedPrompt === "") {
		Log("Warn", `[AgentSession] sub agent prompt empty title_len=${normalizedTitle.length} raw_prompt_len=${rawPrompt.length} expected_len=${toStr(request.expectedOutput).length} files_hint_count=${request.filesHint?.length ?? 0}`);
		return { success: false, message: "sub agent prompt is empty" };
	}
	Log("Info", `[AgentSession] sub agent prompt prepared title_len=${normalizedTitle.length} raw_prompt_len=${rawPrompt.length} normalized_prompt_len=${normalizedPrompt.length}`);
	let parentSessionId = request.parentSessionId;
	if (!getSessionItem(parentSessionId) && request.projectRoot && request.projectRoot !== "") {
		let fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot);
		if (!fallbackParent) {
			const createdMain = createSession(request.projectRoot);
			if (createdMain.success) {
				fallbackParent = createdMain.session;
			}
		}
		if (fallbackParent) {
			Log("Warn", `[AgentSession] spawn fallback parent session requested=${tostring(request.parentSessionId)} resolved=${tostring(fallbackParent.id)} project=${request.projectRoot}`);
			parentSessionId = fallbackParent.id;
		}
	}
	const parentSession = getSessionItem(parentSessionId);
	if (!parentSession) {
		return { success: false, message: "parent session not found" };
	}
	const runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession));
	if (runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS) {
		return { success: false, message: "已达到子代理并发上限，暂无法派出新的代理。" };
	}
	const created = createSubSession(parentSessionId, request.title);
	if (!created.success) {
		return created;
	}
	writeSpawnInfo(created.session.projectRoot, created.session.memoryScope, {
		sessionId: created.session.id,
		rootSessionId: created.session.rootSessionId,
		parentSessionId: created.session.parentSessionId,
		title: created.session.title,
		prompt: normalizedPrompt,
		goal: normalizedTitle !== "" ? normalizedTitle : request.title,
		expectedOutput: request.expectedOutput ?? "",
		filesHint: request.filesHint ?? [],
		status: "RUNNING",
		success: false,
		resultFilePath: "",
		artifactDir: getArtifactRelativeDir(created.session.memoryScope),
		sourceTaskId: 0,
		createdAt: os.date("!%Y-%m-%dT%H:%M:%SZ"),
		createdAtTs: created.session.createdAt,
		finishedAt: "",
		finishedAtTs: 0,
	});
	const sent = sendPrompt(created.session.id, normalizedPrompt, true);
	if (!sent.success) {
		return { success: false, message: sent.message };
	}
	return {
		success: true,
		sessionId: created.session.id,
		taskId: sent.taskId,
		title: created.session.title,
	};
}

export function deleteSessionsByProjectRoot(projectRoot: string) {
	if (!projectRoot || !Content.isAbsolutePath(projectRoot)) {
		return { success: false as const, message: "invalid projectRoot" };
	}
	const rows = queryRows(`SELECT id FROM ${TABLE_SESSION} WHERE project_root = ?`, [projectRoot]) ?? [];
	for (const row of rows) {
		const sessionId = typeof row[0] === "number" ? row[0] as number : 0;
		if (sessionId > 0) {
			deleteSessionRecords(sessionId);
		}
	}
	return { success: true as const, deleted: rows.length };
}

export function renameSessionsByProjectRoot(oldRoot: string, newRoot: string) {
	if (!oldRoot || !newRoot || !Content.isAbsolutePath(oldRoot) || !Content.isAbsolutePath(newRoot)) {
		return { success: false as const, message: "invalid projectRoot" };
	}
	const rows = queryRows(`SELECT id, project_root FROM ${TABLE_SESSION}`) ?? [];
	let renamed = 0;
	for (const row of rows) {
		const sessionId = typeof row[0] === "number" ? row[0] as number : 0;
		const projectRoot = toStr(row[1]);
		const nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot);
		if (sessionId > 0 && nextProjectRoot) {
			DB.exec(
				`UPDATE ${TABLE_SESSION} SET project_root = ?, title = ?, updated_at = ? WHERE id = ?`,
				[nextProjectRoot, Path.getFilename(nextProjectRoot), now(), sessionId],
			);
			renamed++;
		}
	}
	return { success: true as const, renamed };
}

export function getSession(sessionId: number): AgentSessionDetailResult {
	const session = getSessionItem(sessionId);
	if (!session) {
		return { success: false, message: "session not found" };
	}
	const normalizedSession = normalizeSessionRuntimeState(session);
	const relatedSessions = listRelatedSessions(sessionId);
	sanitizeStoredSteps(sessionId);
	const messages = queryRows(
		`SELECT id, session_id, task_id, role, content, created_at, updated_at
		FROM ${TABLE_MESSAGE}
		WHERE session_id = ?
		ORDER BY id ASC`,
		[sessionId],
	) ?? [];
	const steps = queryRows(
		`SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at
		FROM ${TABLE_STEP}
		WHERE session_id = ?
			AND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')
		ORDER BY task_id DESC, step ASC`,
		[sessionId],
	) ?? [];
	return {
		success: true,
		session: normalizedSession,
		relatedSessions,
		spawnInfo: normalizedSession.kind === "sub" ? getSessionSpawnInfo(normalizedSession) : undefined,
		messages: messages.map(row => rowToMessage(row as any[])),
		steps: steps.map(row => rowToStep(row as any[])),
		checkpoints: normalizedSession.currentTaskId ? Tools.listCheckpoints(normalizedSession.currentTaskId) : [],
	};
}

function appendSubAgentHandoffStep(session: AgentSessionItem, taskId: number, result: SubAgentResultRecord, summary: string): void {
	const rootSession = getRootSessionItem(session.id);
	if (!rootSession) return;
	const changeSet = result.changeSet ?? getTaskChangeSetSummary(taskId);
	const createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ");
	const [cleanedTime1] = string.gsub(createdAt, "[-:]", "");
	const [cleanedTime2] = string.gsub(cleanedTime1, "%.%d+Z$", "Z");
	const queueResult = writePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, {
		id: `${cleanedTime2}_sub_${tostring(session.id)}_${tostring(taskId)}`,
		sourceSessionId: session.id,
		sourceTitle: session.title,
		sourceTaskId: taskId,
		message: summary,
		prompt: result.prompt,
		goal: result.goal,
		expectedOutput: result.expectedOutput ?? "",
		filesHint: result.filesHint ?? [],
		success: result.success,
		resultFilePath: result.resultFilePath,
		artifactDir: result.artifactDir,
		finishedAt: result.finishedAt,
		changeSet,
		memoryEntry: result.memoryEntry,
		createdAt,
	});
	if (!queueResult) {
		Log("Warn", `[AgentSession] failed to queue sub-agent handoff root=${rootSession.id} source=${session.id}`);
		return;
	}
	if (!(rootSession.currentTaskStatus === "RUNNING" && rootSession.currentTaskId && activeStopTokens[rootSession.currentTaskId])) {
		flushPendingSubAgentHandoffs(rootSession);
	}
}

async function finalizeSubSession(session: AgentSessionItem, taskId: number, success: boolean, message: string): Promise<{ success: true } | { success: false; message: string }> {
	const rootSessionId = getSessionRootId(session);
	const rootSession = getRootSessionItem(session.id);
	if (!rootSession) {
		return { success: false, message: "root session not found" };
	}
	const spawnInfo = getSessionSpawnInfo(session);
	const finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ");
	const finishedAtTs = now();
	const resultText = sanitizeUTF8(message);
	const changeSet = getTaskChangeSetSummary(taskId);
	const record: SubAgentResultRecord = {
		sessionId: session.id,
		rootSessionId,
		parentSessionId: session.parentSessionId,
		title: session.title,
		prompt: spawnInfo?.prompt ?? "",
		goal: spawnInfo?.goal ?? session.title,
		expectedOutput: spawnInfo?.expectedOutput ?? "",
		filesHint: spawnInfo?.filesHint ?? [],
		status: success ? "DONE" : "FAILED",
		success,
		resultFilePath: getResultRelativePath(session.memoryScope),
		artifactDir: getArtifactRelativeDir(session.memoryScope),
		sourceTaskId: taskId,
		createdAt: spawnInfo?.createdAt ?? finishedAt,
		finishedAt,
		createdAtTs: session.createdAt,
		finishedAtTs,
		changeSet,
	};
	if (record.success) {
		const memoryEntryResult = await generateSubAgentMemoryEntry(session, record, resultText);
		record.memoryEntry = memoryEntryResult.entry;
		if (memoryEntryResult.error && memoryEntryResult.error !== "") {
			record.memoryEntryError = memoryEntryResult.error;
			Log("Warn", `[AgentSession] sub session memory entry failed session=${session.id} error=${memoryEntryResult.error}`);
		}
	}
	if (!writeSubAgentResultFile(session, record, resultText)) {
		return { success: false, message: "failed to persist sub session result file" };
	}
	if (!writeSpawnInfo(session.projectRoot, session.memoryScope, {
		sessionId: record.sessionId,
		rootSessionId: record.rootSessionId,
		parentSessionId: record.parentSessionId,
		title: record.title,
		prompt: record.prompt,
		goal: record.goal,
		expectedOutput: record.expectedOutput ?? "",
		filesHint: record.filesHint ?? [],
		status: record.status,
		success: record.success,
		resultFilePath: record.resultFilePath,
		artifactDir: record.artifactDir,
		sourceTaskId: record.sourceTaskId,
		createdAt: record.createdAt,
		finishedAt: record.finishedAt,
		createdAtTs: record.createdAtTs,
		finishedAtTs: record.finishedAtTs,
		changeSet: record.changeSet,
		memoryEntry: record.memoryEntry,
		memoryEntryError: record.memoryEntryError,
	})) {
		return { success: false, message: "failed to persist sub session spawn info" };
	}
	if (success) {
		appendSubAgentHandoffStep(session, taskId, record, resultText);
		deleteSessionRecords(session.id, true);
		emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot);
	}
	return { success: true };
}

function stopClearedSubSession(session: AgentSessionItem, taskId: number): { success: true } | { success: false; message: string } {
	const spawnInfo = getSessionSpawnInfo(session);
	const finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ");
	const rootSessionId = getSessionRootId(session);
	Tools.setTaskStatus(taskId, "STOPPED");
	setSessionState(session.id, "STOPPED", taskId, "STOPPED");
	if (!writeSpawnInfo(session.projectRoot, session.memoryScope, {
		sessionId: session.id,
		rootSessionId,
		parentSessionId: session.parentSessionId,
		title: session.title,
		prompt: spawnInfo?.prompt ?? "",
		goal: spawnInfo?.goal ?? session.title,
		expectedOutput: spawnInfo?.expectedOutput ?? "",
		filesHint: spawnInfo?.filesHint ?? [],
		status: "STOPPED",
		success: false,
		cleared: true,
		resultFilePath: "",
		artifactDir: getArtifactRelativeDir(session.memoryScope),
		sourceTaskId: taskId,
		createdAt: spawnInfo?.createdAt ?? finishedAt,
		finishedAt,
		createdAtTs: session.createdAt,
		finishedAtTs: now(),
	})) {
		return { success: false, message: "failed to persist cleared sub session spawn info" };
	}
	deleteSessionRecords(session.id, true);
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot);
	return { success: true };
}

export function sendPrompt(sessionId: number, prompt: string, allowSubSessionStart = false): AgentSessionSendResult {
	const session = getSessionItem(sessionId);
	if (!session) {
		return { success: false, message: "session not found" };
	}
	if (session.currentTaskFinalizing === true || (session.currentTaskId !== undefined && finalizingSubSessionTaskIds[session.currentTaskId] === true)) {
		return { success: false, message: "session task is finalizing" };
	}
	if ((session.currentTaskStatus === "RUNNING") && session.currentTaskId !== undefined && activeStopTokens[session.currentTaskId]) {
		return { success: false, message: "session task is still running" };
	}
	let normalizedPrompt = normalizePromptTextSafe(prompt);
	if (normalizedPrompt === "" && session.kind === "sub") {
		const spawnInfo = getSessionSpawnInfo(session);
		if (spawnInfo) {
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt);
			if (normalizedPrompt === "") {
				normalizedPrompt = buildSubAgentPromptFallback(
					spawnInfo.goal,
					spawnInfo.expectedOutput,
					spawnInfo.filesHint,
				);
			}
		}
	}
	if (normalizedPrompt === "") {
		return { success: false, message: "prompt is empty" };
	}
	const taskRes = Tools.createTask(normalizedPrompt);
	if (!taskRes.success) {
		return { success: false, message: taskRes.message };
	}
	const taskId = taskRes.taskId;
	const useChineseResponse = getDefaultUseChineseResponse();
	insertMessage(sessionId, "user", normalizedPrompt, taskId);
	const stopToken: StopToken = { stopped: false };
	activeStopTokens[taskId] = stopToken;
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING");
	runCodingAgent({
		prompt: normalizedPrompt,
		workDir: session.projectRoot,
		useChineseResponse,
		taskId,
		sessionId,
		memoryScope: session.memoryScope,
		role: session.kind,
		spawnSubAgent: session.kind === "main"
			? spawnSubAgentSession
			: undefined,
		listSubAgents: session.kind === "main"
			? listRunningSubAgents
			: undefined,
		stopToken,
		onEvent: event => applyEvent(sessionId, event),
	}, async (result: CodingAgentRunResult) => {
		const nextSession = getSessionItem(sessionId);
		if (nextSession && nextSession.kind === "sub") {
			if (normalizedPrompt.trim() === "/clear") {
				const stopped = stopClearedSubSession(nextSession, taskId);
				if (!stopped.success) {
					Log("Warn", `[AgentSession] sub session clear stop failed session=${nextSession.id} error=${stopped.message}`);
					emitAgentSessionPatch(sessionId, {
						session: getSessionItem(sessionId),
					});
				}
				activeStopTokens[taskId] = undefined as any;
				return;
			}
			setSessionState(sessionId, "RUNNING", taskId, "RUNNING");
			emitAgentSessionPatch(sessionId, {
				session: getSessionItem(sessionId),
			});
			const finalized = await finalizeSubSession(nextSession, taskId, result.success, result.message);
			if (!finalized.success) {
				Log("Warn", `[AgentSession] sub session finalize failed session=${nextSession.id} error=${finalized.message}`);
			}
			const finalizedSession = getSessionItem(sessionId);
			if (finalizedSession) {
				const stopped = stopToken.stopped === true;
				const finalStatus: AgentSessionStatus = result.success
					? "DONE"
					: (stopped ? "STOPPED" : "FAILED");
				setSessionState(sessionId, finalStatus, taskId, finalStatus);
				emitAgentSessionPatch(sessionId, {
					session: getSessionItem(sessionId),
				});
			}
			activeStopTokens[taskId] = undefined as any;
			finalizingSubSessionTaskIds[taskId] = undefined as any;
		}
		if (!result.success && (!nextSession || nextSession.kind !== "sub")) {
			applyEvent(sessionId, {
				type: "task_finished",
				sessionId,
				taskId: result.taskId,
				success: false,
				message: result.message,
				steps: result.steps,
			});
		}
	});
	return { success: true, sessionId, taskId };
}

export function stopSessionTask(sessionId: number) {
	const session = getSessionItem(sessionId);
	if (!session || session.currentTaskId === undefined) {
		return { success: false as const, message: "session task not found" };
	}
	if (session.currentTaskFinalizing === true || finalizingSubSessionTaskIds[session.currentTaskId] === true) {
		return { success: false as const, message: "session task is finalizing" };
	}
	const normalizedSession = normalizeSessionRuntimeState(session);
	const stopToken = activeStopTokens[session.currentTaskId];
	if (!stopToken) {
		if (normalizedSession.currentTaskStatus === "STOPPED") {
			return { success: true as const, recovered: true };
		}
		return { success: false as const, message: "task is not running" };
	}
	stopToken.stopped = true;
	stopToken.reason = getDefaultUseChineseResponse() ? "用户已中断" : "stopped by user";
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED");
	return { success: true as const };
}

export function getCurrentTaskId(sessionId: number): number | undefined {
	return getSessionItem(sessionId)?.currentTaskId;
}

export function listRunningSessions(): AgentRunningSessionListResult {
	const rows = queryRows(
		`SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at
		FROM ${TABLE_SESSION}
		WHERE current_task_status = ?
		ORDER BY updated_at DESC, id DESC`,
		["RUNNING"],
	) ?? [];
	const sessions: AgentSessionItem[] = [];
	for (let i = 0; i < rows.length; i++) {
		const session = normalizeSessionRuntimeState(rowToSession(rows[i] as any[]));
		if (session.currentTaskStatus === "RUNNING") {
			sessions.push(session);
		}
	}
	return {
		success: true,
		sessions,
	};
}

export async function listRunningSubAgents(request: {
	sessionId: number;
	projectRoot?: string;
	status?: string;
	limit?: number;
	offset?: number;
	query?: string;
}): Promise<AgentRunningSubAgentListResult> {
	let session = getSessionItem(request.sessionId);
	if (!session && request.projectRoot && request.projectRoot !== "") {
		session = getLatestMainSessionByProjectRoot(request.projectRoot);
	}
	if (!session) {
		return { success: false, message: "session not found" };
	}
	const rootSession = getRootSessionItem(session.id);
	if (!rootSession) {
		return { success: false, message: "root session not found" };
	}
	const requestedStatus = sanitizeUTF8(toStr(request.status)).trim();
	const status = requestedStatus !== "" ? requestedStatus : "active_or_recent";
	const limit = math.max(1, math.floor(tonumber(request.limit as any) || 5));
	const offset = math.max(0, math.floor(tonumber(request.offset as any) || 0));
	const query = sanitizeUTF8(toStr(request.query)).trim();
	const rows = queryRows(
		`SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at
		FROM ${TABLE_SESSION}
		WHERE root_session_id = ? AND kind = 'sub'
		ORDER BY id ASC`,
		[rootSession.id],
	) ?? [];
	const runningSessions: AgentRunningSubAgentInfo[] = [];
	for (let i = 0; i < rows.length; i++) {
		const current = normalizeSessionRuntimeState(rowToSession(rows[i] as any[]));
		if (current.currentTaskStatus !== "RUNNING") {
			continue;
		}
		const spawnInfo = getSessionSpawnInfo(current);
		runningSessions.push({
			sessionId: current.id,
			title: current.title,
			parentSessionId: current.parentSessionId,
			rootSessionId: current.rootSessionId,
			status: "RUNNING",
			currentTaskId: current.currentTaskId,
			currentTaskStatus: current.currentTaskStatus ?? current.status,
			goal: spawnInfo?.goal,
			expectedOutput: spawnInfo?.expectedOutput,
			filesHint: spawnInfo?.filesHint,
			createdAt: current.createdAt,
			updatedAt: current.updatedAt,
		});
	}
	const completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id);
	const completedSessions: AgentRunningSubAgentInfo[] = completedRecords.map(record => ({
		sessionId: record.sessionId,
		title: record.title,
		parentSessionId: record.parentSessionId,
		rootSessionId: record.rootSessionId,
		status: record.status,
		goal: record.goal,
		expectedOutput: record.expectedOutput,
		filesHint: record.filesHint,
		summary: readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath),
		success: record.success,
		cleared: record.cleared,
		resultFilePath: record.resultFilePath,
		artifactDir: record.artifactDir,
		finishedAt: record.finishedAt,
		createdAt: record.createdAtTs,
		updatedAt: record.finishedAtTs,
	}));
	let merged: AgentRunningSubAgentInfo[] = [];
	if (status === "running") {
		merged = runningSessions;
	} else if (status === "done") {
		merged = completedSessions.filter(item => item.status === "DONE");
	} else if (status === "failed") {
		merged = completedSessions.filter(item => item.status === "FAILED");
	} else if (status === "stopped") {
		merged = completedSessions.filter(item => item.status === "STOPPED");
	} else if (status === "all") {
		merged = runningSessions.concat(completedSessions);
	} else {
		const runningKeys: Record<string, boolean> = {};
		for (let i = 0; i < runningSessions.length; i++) {
			runningKeys[getSubAgentDisplayKey(runningSessions[i])] = true;
		}
		const latestCompletedByKey: Record<string, AgentRunningSubAgentInfo> = {};
		for (let i = 0; i < completedSessions.length; i++) {
			const item = completedSessions[i];
			const key = getSubAgentDisplayKey(item);
			if (runningKeys[key]) {
				continue;
			}
			const current = latestCompletedByKey[key];
			if (!current || item.updatedAt > current.updatedAt) {
				latestCompletedByKey[key] = item;
			}
		}
		const latestCompleted: AgentRunningSubAgentInfo[] = [];
		for (const [, item] of pairs(latestCompletedByKey)) {
			latestCompleted.push(item);
		}
		merged = runningSessions.concat(latestCompleted);
	}
	if (query !== "") {
		merged = merged.filter(item =>
			containsNormalizedText(item.title, query)
			|| containsNormalizedText(item.goal ?? "", query)
			|| containsNormalizedText(item.summary ?? "", query)
		);
	}
	merged.sort((a, b) => {
		if (a.status === "RUNNING" && b.status !== "RUNNING") return -1;
		if (a.status !== "RUNNING" && b.status === "RUNNING") return 1;
		if (a.status === "RUNNING" || b.status === "RUNNING") {
			return a.updatedAt > b.updatedAt ? -1 : (a.updatedAt < b.updatedAt ? 1 : 0);
		}
		return a.updatedAt > b.updatedAt ? -1 : (a.updatedAt < b.updatedAt ? 1 : 0);
	});
	const paged = merged.slice(offset, offset + limit);
	return {
		success: true,
		rootSessionId: rootSession.id,
		maxConcurrent: MAX_CONCURRENT_SUB_AGENTS,
		status,
		limit,
		offset,
		hasMore: offset + limit < merged.length,
		sessions: paged,
	};
}
