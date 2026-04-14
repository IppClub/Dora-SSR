// @preview-file off clear
import { App, Content, DB, Path, HttpServer, emit } from 'Dora';
import { runCodingAgent, CodingAgentEvent, CodingAgentRunResult, truncateAgentUserPrompt } from 'Agent/CodingAgent';
import * as Tools from 'Agent/Tools';
import { DualLayerStorage, MemoryMergeQueue } from 'Agent/Memory';
import { Log, safeJsonDecode, safeJsonEncode, sanitizeUTF8 } from 'Agent/Utils';
import type { StopToken } from 'Agent/Utils';

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

export interface AgentSessionSpawnInfo {
	prompt: string;
	goal: string;
	expectedOutput?: string;
	filesHint?: string[];
	createdAt?: string;
}

export interface AgentPendingMergeJobItem {
	jobId: string;
	sourceAgentId: string;
	sourceTitle: string;
	createdAt: string;
	attempts?: number;
	lastError?: string;
}

export type AgentSessionDetailResult = {
	success: true;
	session: AgentSessionItem;
	relatedSessions: AgentSessionItem[];
	pendingMergeCount: number;
	pendingMergeJobs: AgentPendingMergeJobItem[];
	spawnInfo?: AgentSessionSpawnInfo;
	messages: AgentSessionMessageItem[];
	steps: AgentSessionStepItem[];
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

const TABLE_SESSION = "AgentSession";
const TABLE_MESSAGE = "AgentSessionMessage";
const TABLE_STEP = "AgentSessionStep";
const TABLE_TASK = "AgentTask";
const AGENT_SESSION_SCHEMA_VERSION = 2;
const SPAWN_INFO_FILE = "SPAWN.json";
const FINALIZE_INFO_FILE = "FINALIZE.json";
const PENDING_HANDOFF_DIR = "pending-handoffs";

interface AgentSessionFinalizeInfo {
	sourceTaskId: number;
	message: string;
	createdAt?: string;
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
	createdAt: string;
}

const activeStopTokens: Record<number, StopToken> = {};
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

function deleteSessionRecords(sessionId: number) {
	DB.exec(`DELETE FROM ${TABLE_SESSION} WHERE parent_session_id = ?`, [sessionId]);
	DB.exec(`DELETE FROM ${TABLE_STEP} WHERE session_id = ?`, [sessionId]);
	DB.exec(`DELETE FROM ${TABLE_MESSAGE} WHERE session_id = ?`, [sessionId]);
	DB.exec(`DELETE FROM ${TABLE_SESSION} WHERE id = ?`, [sessionId]);
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

function getPendingMergeCount(projectRoot: string): number {
	return new MemoryMergeQueue(projectRoot).listJobs().length;
}

function listPendingMergeJobs(projectRoot: string): AgentPendingMergeJobItem[] {
	return new MemoryMergeQueue(projectRoot).listJobs().map(job => ({
		jobId: job.jobId,
		sourceAgentId: job.sourceAgentId,
		sourceTitle: job.sourceTitle,
		createdAt: job.createdAt,
		attempts: job.attempts,
		lastError: job.lastError,
	}));
}

function getSessionSpawnInfo(session: AgentSessionItem): AgentSessionSpawnInfo | undefined {
	const info = readSpawnInfo(session.projectRoot, session.memoryScope);
	if (!info) return undefined;
	return {
		prompt: typeof info.prompt === "string" ? sanitizeUTF8(info.prompt) : "",
		goal: typeof info.goal === "string" ? sanitizeUTF8(info.goal) : "",
		expectedOutput: typeof info.expectedOutput === "string" ? sanitizeUTF8(info.expectedOutput) : undefined,
		filesHint: Array.isArray(info.filesHint)
			? (info.filesHint as unknown[]).filter(item => typeof item === "string").map(item => sanitizeUTF8(item as string))
			: undefined,
		createdAt: typeof info.createdAt === "string" ? sanitizeUTF8(info.createdAt) : undefined,
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
	return Content.save(path, `${text}\n`);
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

function writeFinalizeInfo(projectRoot: string, memoryScope: string, value: AgentSessionFinalizeInfo): boolean {
	const dir = Path(projectRoot, ".agent", memoryScope);
	if (!Content.exist(dir)) {
		ensureDirRecursive(dir);
	}
	const path = Path(dir, FINALIZE_INFO_FILE);
	const [text] = safeJsonEncode(value as unknown as object);
	if (!text) return false;
	return Content.save(path, `${text}\n`);
}

function readFinalizeInfo(projectRoot: string, memoryScope: string): AgentSessionFinalizeInfo | undefined {
	const path = Path(projectRoot, ".agent", memoryScope, FINALIZE_INFO_FILE);
	if (!Content.exist(path)) return undefined;
	const text = Content.load(path) as string;
	if (!text || text.trim() === "") return undefined;
	const [value] = safeJsonDecode(text);
	if (value && !Array.isArray(value) && type(value) === "table") {
		const sourceTaskId = tonumber((value as any).sourceTaskId);
		if (!(sourceTaskId && sourceTaskId > 0)) return undefined;
		return {
			sourceTaskId,
			message: sanitizeUTF8(toStr((value as any).message)),
			createdAt: typeof (value as any).createdAt === "string"
				? sanitizeUTF8((value as any).createdAt)
				: undefined,
		};
	}
	return undefined;
}

function deleteFinalizeInfo(projectRoot: string, memoryScope: string): void {
	const path = Path(projectRoot, ".agent", memoryScope, FINALIZE_INFO_FILE);
	if (Content.exist(path)) {
		Content.remove(path);
	}
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

function emitSessionTreePatch(sessionId: number) {
	const session = getSessionItem(sessionId);
	if (!session) return;
	emitAgentSessionPatch(session.id, {
		session,
		relatedSessions: listRelatedSessions(session.id),
		pendingMergeCount: getPendingMergeCount(session.projectRoot),
		pendingMergeJobs: listPendingMergeJobs(session.projectRoot),
		spawnInfo: session.kind === "sub" ? getSessionSpawnInfo(session) : undefined,
	});
}

function emitSessionDeletedPatch(sessionId: number, rootSessionId: number, projectRoot: string) {
	emitAgentSessionPatch(sessionId, {
		sessionDeleted: true,
		relatedSessions: listRelatedSessions(rootSessionId),
		pendingMergeCount: getPendingMergeCount(projectRoot),
		pendingMergeJobs: listPendingMergeJobs(projectRoot),
	});
	const rootSession = getSessionItem(rootSessionId);
	if (rootSession) {
		emitAgentSessionPatch(rootSessionId, {
			session: rootSession,
			relatedSessions: listRelatedSessions(rootSessionId),
			pendingMergeCount: getPendingMergeCount(projectRoot),
			pendingMergeJobs: listPendingMergeJobs(projectRoot),
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
	const taskRes = Tools.createTask(`[sub_agent_handoff] ${tostring(items.length)} item(s)`);
	if (!taskRes.success) {
		Log("Warn", `[AgentSession] failed to create sub-agent handoff task for root=${rootSession.id}: ${taskRes.message}`);
		return;
	}
	const handoffTaskId = taskRes.taskId;
	Tools.setTaskStatus(handoffTaskId, "DONE");
	setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE");
	emitAgentSessionPatch(rootSession.id, {
		session: getSessionItem(rootSession.id),
	});
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
			},
			{
				sourceSessionId: item.sourceSessionId,
				sourceTitle: item.sourceTitle,
				prompt: item.prompt,
				goal: item.goal !== "" ? item.goal : item.sourceTitle,
				expectedOutput: item.expectedOutput ?? "",
				filesHint: item.filesHint ?? [],
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
		case "memory_merge_started": {
			upsertStep(sessionId, event.taskId, event.step, "merge_memory", {
				status: "RUNNING",
				reason: getDefaultUseChineseResponse()
					? `正在合并来自 ${event.sourceTitle} 的记忆。`
					: `Pending memory merge from ${event.sourceTitle}.`,
				params: {
					jobId: event.jobId,
					sourceAgentId: event.sourceAgentId,
					sourceTitle: event.sourceTitle,
				},
			});
			emitAgentSessionPatch(sessionId, {
				step: getStepItem(sessionId, event.taskId, event.step),
			});
			break;
		}
		case "memory_merge_finished": {
			upsertStep(sessionId, event.taskId, event.step, "merge_memory", {
				status: event.success ? "DONE" : "FAILED",
				reason: sanitizeUTF8(event.message),
				params: {
					jobId: event.jobId,
					sourceAgentId: event.sourceAgentId,
					sourceTitle: event.sourceTitle,
				},
				result: {
					success: event.success,
					attempts: event.attempts,
					jobId: event.jobId,
					sourceAgentId: event.sourceAgentId,
					sourceTitle: event.sourceTitle,
				},
			});
			emitAgentSessionPatch(sessionId, {
				step: getStepItem(sessionId, event.taskId, event.step),
			});
			break;
		}
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
			setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus);
			if (event.taskId !== undefined) {
				const removedStepIds = deleteMessageSteps(sessionId, event.taskId);
				finalizeTaskSteps(
					sessionId,
					event.taskId,
					typeof event.steps === "number" ? math.max(0, math.floor(event.steps)) : undefined,
					event.success ? undefined : (stopped ? "STOPPED" : "FAILED"),
				);
				const messageId = upsertAssistantMessage(sessionId, event.taskId, event.message);
				activeStopTokens[event.taskId] = undefined as any;
				emitAgentSessionPatch(sessionId, {
					session: getSessionItem(sessionId),
					message: getMessageItem(messageId),
					checkpoints: Tools.listCheckpoints(event.taskId),
					removedStepIds,
				});
			}
			const session = getSessionItem(sessionId);
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
	const created = createSubSession(parentSessionId, request.title);
	if (!created.success) {
		return created;
	}
	writeSpawnInfo(created.session.projectRoot, created.session.memoryScope, {
		prompt: normalizedPrompt,
		goal: normalizedTitle !== "" ? normalizedTitle : request.title,
		expectedOutput: request.expectedOutput ?? "",
		filesHint: request.filesHint ?? [],
		createdAt: os.date("!%Y-%m-%dT%H:%M:%SZ"),
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
		pendingMergeCount: getPendingMergeCount(normalizedSession.projectRoot),
		pendingMergeJobs: listPendingMergeJobs(normalizedSession.projectRoot),
		spawnInfo: normalizedSession.kind === "sub" ? getSessionSpawnInfo(normalizedSession) : undefined,
		messages: messages.map(row => rowToMessage(row as any[])),
		steps: steps.map(row => rowToStep(row as any[])),
	};
}

function buildSubAgentMemoryMergeJob(session: AgentSessionItem): { success: true } | { success: false; message: string } {
	if (session.kind !== "sub") {
		return { success: true };
	}
	const rootSession = getRootSessionItem(session.id);
	if (!rootSession) {
		return { success: false, message: "root session not found" };
	}
	const storage = new DualLayerStorage(session.projectRoot, session.memoryScope);
	const finalMemory = storage.readMemory();
	if (finalMemory.trim() === "") {
		return { success: false, message: "sub session memory is empty" };
	}
	const queue = new MemoryMergeQueue(session.projectRoot);
	const spawnInfo = readSpawnInfo(session.projectRoot, session.memoryScope);
	const createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ");
	const [sanitizedTitle] = string.gsub(session.title, "[^%w_-]", "_");
	const [cleanedTime1] = string.gsub(createdAt, "[-:]", "");
	const [cleanedTime2] = string.gsub(cleanedTime1, "%.%d+Z$", "Z");
	const jobId = `${cleanedTime2}_${sanitizeUTF8(sanitizedTitle)}_${tostring(session.id)}`;
	const result = queue.writeJob({
		jobId,
		rootAgentId: tostring(rootSession.id),
		sourceAgentId: tostring(session.id),
		sourceTitle: session.title,
		createdAt,
		spawn: {
			prompt: typeof spawnInfo?.prompt === "string"
				? spawnInfo.prompt as string
				: session.title,
			goal: typeof spawnInfo?.goal === "string"
				? spawnInfo.goal as string
				: session.title,
			expectedOutput: typeof spawnInfo?.expectedOutput === "string"
				? spawnInfo.expectedOutput as string
				: "",
			filesHint: Array.isArray(spawnInfo?.filesHint)
				? spawnInfo.filesHint as string[]
				: [],
		},
		memory: {
			finalMemory,
		},
	});
	if (!result.success) {
		return result;
	}
	return { success: true };
}

function appendSubAgentHandoffStep(session: AgentSessionItem, taskId: number, message: string): void {
	const rootSession = getRootSessionItem(session.id);
	if (!rootSession) return;
	const spawnInfo = getSessionSpawnInfo(session);
	const createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ");
	const [cleanedTime1] = string.gsub(createdAt, "[-:]", "");
	const [cleanedTime2] = string.gsub(cleanedTime1, "%.%d+Z$", "Z");
	const queueResult = writePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, {
		id: `${cleanedTime2}_sub_${tostring(session.id)}_${tostring(taskId)}`,
		sourceSessionId: session.id,
		sourceTitle: session.title,
		sourceTaskId: taskId,
		message: sanitizeUTF8(message),
		prompt: spawnInfo?.prompt ?? "",
		goal: spawnInfo?.goal ?? session.title,
		expectedOutput: spawnInfo?.expectedOutput ?? "",
		filesHint: spawnInfo?.filesHint ?? [],
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

function startSubSessionFinalize(session: AgentSessionItem, taskId: number, message: string): { success: true } | { success: false; message: string } {
	if (!writeFinalizeInfo(session.projectRoot, session.memoryScope, {
		sourceTaskId: taskId,
		message: sanitizeUTF8(message),
		createdAt: os.date("!%Y-%m-%dT%H:%M:%SZ"),
	})) {
		return { success: false, message: "failed to persist sub session finalize info" };
	}
	const compactPrompt = "/compact";
	const sent = sendPrompt(session.id, compactPrompt, true);
	if (!sent.success) {
		deleteFinalizeInfo(session.projectRoot, session.memoryScope);
		return sent;
	}
	return { success: true };
}

function completeSubSessionFinalizeAfterCompact(session: AgentSessionItem): { success: true } | { success: false; message: string } {
	const rootSessionId = getSessionRootId(session);
	const projectRoot = session.projectRoot;
	const finalizeInfo = readFinalizeInfo(projectRoot, session.memoryScope);
	if (!finalizeInfo) {
		return { success: false, message: "sub session finalize info not found" };
	}
	appendSubAgentHandoffStep(session, finalizeInfo.sourceTaskId, finalizeInfo.message);
	const mergeResult = buildSubAgentMemoryMergeJob(session);
	if (!mergeResult.success) {
		Log("Warn", `[AgentSession] sub session merge handoff failed session=${session.id} error=${mergeResult.message}`);
		return mergeResult;
	}
	deleteFinalizeInfo(projectRoot, session.memoryScope);
	deleteSessionRecords(session.id);
	emitSessionDeletedPatch(session.id, rootSessionId, projectRoot);
	return { success: true };
}

export function sendPrompt(sessionId: number, prompt: string, allowSubSessionStart = false): AgentSessionSendResult {
	const session = getSessionItem(sessionId);
	if (!session) {
		return { success: false, message: "session not found" };
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
		stopToken,
		onEvent: event => applyEvent(sessionId, event),
	}, async (result: CodingAgentRunResult) => {
		const nextSession = getSessionItem(sessionId);
		if (result.success) {
			if (nextSession && nextSession.kind === "sub") {
				if (normalizedPrompt.trim() === "/compact") {
					if (readFinalizeInfo(nextSession.projectRoot, nextSession.memoryScope)) {
						const finalized = completeSubSessionFinalizeAfterCompact(nextSession);
						if (!finalized.success) {
							Log("Warn", `[AgentSession] sub session compact finalize failed session=${nextSession.id} error=${finalized.message}`);
						}
					}
				} else {
					const started = startSubSessionFinalize(nextSession, taskId, result.message);
					if (!started.success) {
						Log("Warn", `[AgentSession] sub session finalize start failed session=${nextSession.id} error=${started.message}`);
					}
				}
			}
		}
		if (!result.success) {
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
