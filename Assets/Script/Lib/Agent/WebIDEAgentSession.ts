// @preview-file off clear
import { App, Content, DB, Path } from 'Dora';
import { runCodingAgent, CodingAgentEvent, CodingAgentRunResult } from 'Agent/CodingAgent';
import * as Tools from 'Agent/Tools';
import { Log, safeJsonDecode, safeJsonEncode, sanitizeUTF8 } from 'Agent/Utils';
import type { StopToken } from 'Agent/Utils';

export type AgentSessionStatus = "IDLE" | "RUNNING" | "DONE" | "FAILED" | "STOPPED";
export type AgentMessageRole = "user" | "assistant";
export type AgentStepStatus = "PENDING" | "RUNNING" | "DONE" | "FAILED" | "STOPPED";

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
const TABLE_TASK = "AgentTask";
const AGENT_SESSION_SCHEMA_VERSION = 1;

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
		checkpointId: type(row[10]) === "number" && (row[10] as number) > 0 ? row[10] as number : undefined,
		checkpointSeq: type(row[11]) === "number" && (row[11] as number) > 0 ? row[11] as number : undefined,
		files: decodeJsonFiles(toStr(row[12])),
		createdAt: row[13] as number,
		updatedAt: row[14] as number,
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
			content,
			t,
			t,
		],
	);
	return getLastInsertRowId();
}

function updateMessage(messageId: number, content: string) {
	DB.exec(
		`UPDATE ${TABLE_MESSAGE} SET content = ?, updated_at = ? WHERE id = ?`,
		[content, now(), messageId],
	);
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
	const reason = patch.reason ?? "";
	const reasoningContent = patch.reasoningContent ?? "";
	const paramsJson = patch.params ? encodeJson(patch.params) : "";
	const resultJson = patch.result ? encodeJson(patch.result) : "";
	const filesJson = patch.files ? encodeJson(patch.files) : "";
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
			patch.status ?? "",
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

function applyEvent(sessionId: number, event: CodingAgentEvent) {
	switch (event.type) {
		case "task_started":
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING");
			break;
		case "decision_made":
			upsertStep(sessionId, event.taskId, event.step, event.tool, {
				status: "PENDING",
				reason: event.reason,
				reasoningContent: event.reasoningContent,
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
				status: event.result.success === true ? "DONE" : "FAILED",
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
		case "task_finished": {
			const stopped = activeStopTokens[event.taskId ?? -1]?.stopped === true;
			const finalStatus: AgentSessionStatus = event.success
				? "DONE"
				: (stopped ? "STOPPED" : "FAILED");
			setSessionStateForTaskEvent(sessionId, event.taskId, finalStatus, finalStatus);
			if (event.taskId !== undefined) {
				finalizeTaskSteps(
					sessionId,
					event.taskId,
					type(event.steps) === "number" ? math.max(0, math.floor(event.steps as number)) : undefined,
					event.success ? undefined : (stopped ? "STOPPED" : "FAILED"),
				);
				const summaryRow = queryOne(
					`SELECT id FROM ${TABLE_MESSAGE}
					WHERE session_id = ? AND task_id = ? AND role = ?
					ORDER BY id DESC LIMIT 1`,
					[sessionId, event.taskId, "assistant"],
				);
				if (summaryRow && type(summaryRow[0]) === "number") {
					updateMessage(summaryRow[0] as number, event.message);
				} else {
					insertMessage(sessionId, "assistant", event.message, event.taskId);
				}
				activeStopTokens[event.taskId] = undefined as any;
			}
			break;
		}
	}
}

function getSchemaVersion(): number {
	const row = queryOne("PRAGMA user_version");
	return row && type(row[0]) === "number" ? row[0] as number : 0;
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
		messages: messages.map(row => rowToMessage(row as any[])),
		steps: steps.map(row => rowToStep(row as any[])),
	};
}

export function sendPrompt(sessionId: number, prompt: string): AgentSessionSendResult {
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
	const useChineseResponse = getDefaultUseChineseResponse();
	insertMessage(sessionId, "user", prompt, taskId);
	const stopToken: StopToken = { stopped: false };
	activeStopTokens[taskId] = stopToken;
	setSessionState(sessionId, "RUNNING", taskId, "RUNNING");
	runCodingAgent({
		prompt,
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
	stopToken.reason = getDefaultUseChineseResponse() ? "用户已中断" : "stopped by user";
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
