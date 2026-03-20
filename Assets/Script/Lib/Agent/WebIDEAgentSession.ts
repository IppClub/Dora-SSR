// @preview-file off clear
import { Content, DB, Path, json } from 'Dora';
import { runCodingAgent, CodingAgentEvent, CodingAgentRunResult } from 'Agent/CodingAgent';
import * as Tools from 'Agent/Tools';
import type { StopToken } from 'Agent/Utils';

export type AgentSessionStatus = "IDLE" | "RUNNING" | "DONE" | "FAILED" | "STOPPED";
export type AgentMessageRole = "user" | "assistant";
export type AgentMessageKind = "message" | "summary";
export type AgentStepStatus = "PENDING" | "RUNNING" | "DONE";

export interface AgentSessionItem {
	id: number;
	projectRoot: string;
	title: string;
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
	kind: AgentMessageKind;
	content: string;
	streaming: boolean;
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
	params?: Record<string, unknown>;
	result?: Record<string, unknown>;
	checkpointId?: number;
	checkpointSeq?: number;
	files?: { path: string; op: string }[];
	createdAt: number;
	updatedAt: number;
}

export type AgentSessionDetailResult = {
	success: true;
	session: AgentSessionItem;
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
const SESSION_CONTEXT_MAX_MESSAGES = 12;
const SESSION_CONTEXT_MAX_CHARS = 12000;

const activeStopTokens: Record<number, StopToken> = {};
const activeAssistantMessageIds: Record<number, number> = {};

const now = () => os.time();

function toBool(v: unknown): boolean {
	return v !== 0 && v !== false && v !== null && v !== undefined;
}

function toStr(v: unknown): string {
	if (v === false || v === null || v === undefined) return "";
	return tostring(v);
}

function encodeJson(value: unknown): string {
	const [text] = json.encode(value as object);
	return text ?? "";
}

function decodeJsonObject(text: string): Record<string, unknown> | undefined {
	if (!text || text === "") return undefined;
	const [value] = json.decode(text);
	if (value && !Array.isArray(value) && type(value) === "table") {
		return value as Record<string, unknown>;
	}
	return undefined;
}

function decodeJsonFiles(text: string): { path: string; op: string }[] | undefined {
	if (!text || text === "") return undefined;
	const [value] = json.decode(text);
	if (!value || !Array.isArray(value)) return undefined;
	const files: { path: string; op: string }[] = [];
	for (let i = 0; i < value.length; i++) {
		const item = value[i] as any;
		if (type(item) !== "table") continue;
		files.push({
			path: toStr(item.path),
			op: toStr(item.op),
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
		status: toStr(row[3]) as AgentSessionStatus,
		currentTaskId: type(row[4]) === "number" && (row[4] as number) > 0 ? row[4] as number : undefined,
		currentTaskStatus: toStr(row[5]) as AgentSessionStatus,
		createdAt: row[6] as number,
		updatedAt: row[7] as number,
	};
}

function rowToMessage(row: any[]): AgentSessionMessageItem {
	return {
		id: row[0] as number,
		sessionId: row[1] as number,
		taskId: type(row[2]) === "number" && (row[2] as number) > 0 ? row[2] as number : undefined,
		role: toStr(row[3]) as AgentMessageRole,
		kind: toStr(row[4]) as AgentMessageKind,
		content: toStr(row[5]),
		streaming: toBool(row[6]),
		createdAt: row[7] as number,
		updatedAt: row[8] as number,
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
		params: decodeJsonObject(toStr(row[7])),
		result: decodeJsonObject(toStr(row[8])),
		checkpointId: type(row[9]) === "number" && (row[9] as number) > 0 ? row[9] as number : undefined,
		checkpointSeq: type(row[10]) === "number" && (row[10] as number) > 0 ? row[10] as number : undefined,
		files: decodeJsonFiles(toStr(row[11])),
		createdAt: row[12] as number,
		updatedAt: row[13] as number,
	};
}

function getSessionRow(sessionId: number) {
	return queryOne(
		`SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at
		FROM ${TABLE_SESSION}
		WHERE id = ?`,
		[sessionId],
	);
}

function getSessionItem(sessionId: number): AgentSessionItem | undefined {
	const row = getSessionRow(sessionId);
	return row ? rowToSession(row as any[]) : undefined;
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

function trimSessionContext(text: string, maxChars: number) {
	if (text.length <= maxChars) return text;
	const clipped = text.slice(text.length - maxChars);
	const newlinePos = clipped.indexOf("\n");
	return newlinePos >= 0 ? clipped.slice(newlinePos + 1) : clipped;
}

function buildSessionPromptContext(sessionId: number, useChineseResponse: boolean): string {
	const rows = queryRows(
		`SELECT role, kind, content
		FROM ${TABLE_MESSAGE}
		WHERE session_id = ? AND content <> ''
		ORDER BY id DESC
		LIMIT ?`,
		[sessionId, SESSION_CONTEXT_MAX_MESSAGES],
	) ?? [];
	if (rows.length === 0) return "";
	const messages = rows
		.slice()
		.reverse()
		.map(row => ({
			role: toStr((row as any[])[0]) as AgentMessageRole,
			kind: toStr((row as any[])[1]) as AgentMessageKind,
			content: toStr((row as any[])[2]).trim(),
		}))
		.filter(message => message.content !== "");
	if (messages.length === 0) return "";
	const lines: string[] = [];
	lines.push(useChineseResponse
		? "以下是同一会话中之前的对话内容，请把它们作为当前请求的上下文参考。若与当前请求冲突，以当前请求为准。"
		: "Here is the prior conversation from the same session. Use it as context for the current request. If there is any conflict, prefer the current request.");
	lines.push("");
	for (let i = 0; i < messages.length; i++) {
		const message = messages[i];
		const speaker = message.role === "user"
			? (useChineseResponse ? "用户" : "User")
			: (useChineseResponse ? "助手" : "Assistant");
		lines.push(`${speaker}: ${message.content}`);
	}
	return trimSessionContext(lines.join("\n"), SESSION_CONTEXT_MAX_CHARS);
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

function insertMessage(sessionId: number, role: AgentMessageRole, kind: AgentMessageKind, content: string, taskId?: number, streaming = false): number {
	const t = now();
	DB.exec(
		`INSERT INTO ${TABLE_MESSAGE}(session_id, task_id, role, kind, content, streaming, created_at, updated_at)
		VALUES(?, ?, ?, ?, ?, ?, ?, ?)`,
		[
			sessionId,
			taskId ?? 0,
			role,
			kind,
			content,
			streaming ? 1 : 0,
			t,
			t,
		],
	);
	return getLastInsertRowId();
}

function updateMessage(messageId: number, content: string, streaming: boolean) {
	DB.exec(
		`UPDATE ${TABLE_MESSAGE} SET content = ?, streaming = ?, updated_at = ? WHERE id = ?`,
		[content, streaming ? 1 : 0, now(), messageId],
	);
}

function getAssistantSummaryMessageId(taskId: number, sessionId: number): number {
	const cached = activeAssistantMessageIds[taskId];
	if (cached !== undefined) return cached;
	const row = queryOne(
		`SELECT id FROM ${TABLE_MESSAGE}
		WHERE session_id = ? AND task_id = ? AND role = ? AND kind = ?
		ORDER BY id DESC LIMIT 1`,
		[sessionId, taskId, "assistant", "summary"],
	);
	if (row && type(row[0]) === "number") {
		activeAssistantMessageIds[taskId] = row[0] as number;
		return row[0] as number;
	}
	const messageId = insertMessage(sessionId, "assistant", "summary", "", taskId, true);
	activeAssistantMessageIds[taskId] = messageId;
	return messageId;
}

function upsertStep(sessionId: number, taskId: number, step: number, tool: string, patch: {
	status?: AgentStepStatus;
	reason?: string;
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
	const reason = patch.reason ?? "";
	const paramsJson = patch.params ? encodeJson(patch.params) : "";
	const resultJson = patch.result ? encodeJson(patch.result) : "";
	const filesJson = patch.files ? encodeJson(patch.files) : "";
	const status = patch.status ?? "PENDING";
	if (!row) {
		const t = now();
		DB.exec(
			`INSERT INTO ${TABLE_STEP}(session_id, task_id, step, tool, status, reason, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)
			VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			[
				sessionId,
				taskId,
				step,
				tool,
				status,
				reason,
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
			params_json = CASE WHEN ? = '' THEN params_json ELSE ? END,
			result_json = CASE WHEN ? = '' THEN result_json ELSE ? END,
			checkpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,
			checkpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,
			files_json = CASE WHEN ? = '' THEN files_json ELSE ? END,
			updated_at = ?
		WHERE id = ?`,
		[
			tool,
			patch.status ?? "",
			status,
			reason,
			reason,
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

function applyEvent(sessionId: number, event: CodingAgentEvent) {
	switch (event.type) {
		case "task_started":
			setSessionState(sessionId, "RUNNING", event.taskId, "RUNNING");
			break;
		case "decision_made":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				status: "PENDING",
				reason: event.reason,
				params: event.params,
			});
			break;
		case "tool_started":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				status: "RUNNING",
			});
			break;
		case "tool_finished":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				status: "DONE",
				reason: event.reason,
				result: event.result,
			});
			break;
		case "checkpoint_created":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				checkpointId: event.checkpointId,
				checkpointSeq: event.checkpointSeq,
				files: event.files,
			});
			break;
		case "summary_stream": {
			const messageId = getAssistantSummaryMessageId(event.taskId, sessionId);
			const row = queryOne(`SELECT content FROM ${TABLE_MESSAGE} WHERE id = ?`, [messageId]);
			const oldContent = row ? toStr(row[0]) : "";
			const nextContent = oldContent + event.textDelta;
			updateMessage(messageId, nextContent, true);
			break;
		}
		case "task_finished": {
			const finalStatus: AgentSessionStatus = event.success
				? "DONE"
				: (activeStopTokens[event.taskId ?? -1]?.stopped ? "STOPPED" : "FAILED");
			setSessionState(sessionId, finalStatus, event.taskId, finalStatus);
			if (event.taskId !== undefined) {
				const messageId = getAssistantSummaryMessageId(event.taskId, sessionId);
				const row = queryOne(`SELECT content FROM ${TABLE_MESSAGE} WHERE id = ?`, [messageId]);
				const content = row ? toStr(row[0]) : "";
				updateMessage(messageId, content !== "" ? content : event.message, false);
				activeStopTokens[event.taskId] = undefined as any;
				activeAssistantMessageIds[event.taskId] = undefined as any;
			}
			break;
		}
	}
}

// initialize tables
{
	DB.exec(`CREATE TABLE IF NOT EXISTS ${TABLE_SESSION}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		project_root TEXT NOT NULL,
		title TEXT NOT NULL DEFAULT '',
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
		kind TEXT NOT NULL,
		content TEXT NOT NULL DEFAULT '',
		streaming INTEGER NOT NULL DEFAULT 0,
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

export function createSession(projectRoot: string, title = "") {
	if (!isValidProjectRoot(projectRoot)) {
		return { success: false as const, message: "invalid projectRoot" };
	}
	const row = queryOne(
		`SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at
		FROM ${TABLE_SESSION}
		WHERE project_root = ?
		ORDER BY updated_at DESC, id DESC
		LIMIT 1`,
		[projectRoot],
	);
	if (row) {
		return { success: true as const, session: rowToSession(row as any[]) };
	}
	const t = now();
	DB.exec(
		`INSERT INTO ${TABLE_SESSION}(project_root, title, status, current_task_status, created_at, updated_at)
		VALUES(?, ?, 'IDLE', 'IDLE', ?, ?)`,
		[projectRoot, title !== "" ? title : Path.getFilename(projectRoot), t, t],
	);
	const session = getSessionItem(getLastInsertRowId());
	if (!session) {
		return { success: false as const, message: "failed to create session" };
	}
	return { success: true as const, session };
}

export function getSession(sessionId: number): AgentSessionDetailResult {
	const session = getSessionItem(sessionId);
	if (!session) {
		return { success: false, message: "session not found" };
	}
	const normalizedSession = normalizeSessionRuntimeState(session);
	const messages = queryRows(
		`SELECT id, session_id, task_id, role, kind, content, streaming, created_at, updated_at
		FROM ${TABLE_MESSAGE}
		WHERE session_id = ?
		ORDER BY id ASC`,
		[sessionId],
	) ?? [];
	const steps = queryRows(
		`SELECT id, session_id, task_id, step, tool, status, reason, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at
		FROM ${TABLE_STEP}
		WHERE session_id = ?
		ORDER BY task_id DESC, step ASC`,
		[sessionId],
	) ?? [];
	return {
		success: true,
		session: normalizedSession,
		messages: messages.map(row => rowToMessage(row as any[])),
		steps: steps.map(row => rowToStep(row as any[])),
	};
}

export function sendPrompt(sessionId: number, prompt: string, useChineseResponse = true): AgentSessionSendResult {
	const session = getSessionItem(sessionId);
	if (!session) {
		return { success: false, message: "session not found" };
	}
	if ((session.currentTaskStatus === "RUNNING") && session.currentTaskId !== undefined && activeStopTokens[session.currentTaskId]) {
		return { success: false, message: "session task is still running" };
	}
	const taskRes = Tools.createTask(prompt);
	if (!taskRes.success) {
		return { success: false, message: taskRes.message };
	}
	const taskId = taskRes.taskId;
	const sessionContext = buildSessionPromptContext(sessionId, useChineseResponse);
	const agentPrompt = sessionContext !== ""
		? `${sessionContext}\n\n${useChineseResponse ? "当前用户请求：" : "Current user request:"}\n${prompt}`
		: prompt;
	insertMessage(sessionId, "user", "message", prompt, taskId, false);
	const assistantMessageId = insertMessage(sessionId, "assistant", "summary", "", taskId, true);
	activeAssistantMessageIds[taskId] = assistantMessageId;
	const stopToken: StopToken = { stopped: false };
	activeStopTokens[taskId] = stopToken;
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING");
	runCodingAgent({
		prompt: agentPrompt,
		workDir: session.projectRoot,
		useChineseResponse,
		taskId,
		sessionId,
		stopToken,
		onEvent: event => applyEvent(sessionId, event),
	}, (result: CodingAgentRunResult) => {
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
	stopToken.reason = "stopped by user";
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED");
	return { success: true as const };
}

export function getCurrentTaskId(sessionId: number): number | undefined {
	return getSessionItem(sessionId)?.currentTaskId;
}

export function listRunningSessions(): AgentRunningSessionListResult {
	const rows = queryRows(
		`SELECT id, project_root, title, status, current_task_id, current_task_status, created_at, updated_at
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
