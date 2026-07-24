// @preview-file off clear
import { Content, DB, Path } from 'Dora';
import { Log } from 'Agent/Utils';

export const AGENT_SCHEMA_VERSION = 1;
export const AGENT_SCHEMA = "agent";
export const TABLE_SESSION = "agent.AgentSession";
export const TABLE_MESSAGE = "agent.AgentSessionMessage";
export const TABLE_STEP = "agent.AgentSessionStep";
export const TABLE_TASK = "agent.AgentTask";
export const TABLE_CHECKPOINT = "agent.AgentCheckpoint";
export const TABLE_CHECKPOINT_ENTRY = "agent.AgentCheckpointEntry";
export const TABLE_TASK_REFERENCE = "agent.AgentTaskReference";

const AGENT_DB_FILE = "agent.db";
const REQUIRED_TABLES: { name: string; columns: string[] }[] = [
	{
		name: "AgentSession",
		columns: [
			"id", "project_root", "title", "kind", "root_session_id",
			"parent_session_id", "memory_scope", "status", "current_task_id",
			"current_task_status", "created_at", "updated_at", "metrics_json",
			"work_mode",
		],
	},
	{
		name: "AgentSessionMessage",
		columns: [
			"id", "session_id", "task_id", "role", "content",
			"display_content", "created_at", "updated_at",
		],
	},
	{
		name: "AgentSessionStep",
		columns: [
			"id", "session_id", "task_id", "step", "tool", "status", "reason",
			"reasoning_content", "params_json", "result_json", "checkpoint_id",
			"checkpoint_seq", "files_json", "created_at", "updated_at",
		],
	},
	{
		name: "AgentTask",
		columns: [
			"id", "status", "prompt", "head_seq", "work_mode",
			"created_at", "updated_at",
		],
	},
	{
		name: "AgentCheckpoint",
		columns: [
			"id", "task_id", "seq", "status", "summary", "tool_name",
			"created_at", "applied_at", "reverted_at",
		],
	},
	{
		name: "AgentCheckpointEntry",
		columns: [
			"id", "checkpoint_id", "ord", "path", "op", "before_exists",
			"before_data", "after_exists", "after_data", "bytes_before",
			"bytes_after",
		],
	},
	{
		name: "AgentTaskReference",
		columns: ["owner_task_id", "target_task_id", "kind", "created_at"],
	},
];

const REQUIRED_INDEXES = [
	"idx_agent_session_project_root",
	"idx_agent_session_message_sid_id",
	"idx_agent_session_step_unique",
	"idx_agent_session_step_sid_task_step",
	"idx_agent_cp_task_seq",
	"idx_agent_entry_cp_ord",
	"idx_agent_task_ref_target",
];

const DROP_AGENT_SCHEMA_SQL = [
	`DROP TABLE IF EXISTS ${TABLE_CHECKPOINT_ENTRY};`,
	`DROP TABLE IF EXISTS ${TABLE_CHECKPOINT};`,
	`DROP TABLE IF EXISTS ${TABLE_STEP};`,
	`DROP TABLE IF EXISTS ${TABLE_MESSAGE};`,
	`DROP TABLE IF EXISTS ${TABLE_TASK_REFERENCE};`,
	`DROP TABLE IF EXISTS ${TABLE_SESSION};`,
	`DROP TABLE IF EXISTS ${TABLE_TASK};`,
];

const CREATE_AGENT_SCHEMA_SQL = [
	`CREATE TABLE ${TABLE_SESSION}(
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
		updated_at INTEGER NOT NULL,
		metrics_json TEXT NOT NULL DEFAULT '',
		work_mode TEXT NOT NULL DEFAULT 'code'
	);`,
	`CREATE INDEX agent.idx_agent_session_project_root
		ON AgentSession(project_root, updated_at DESC);`,
	`CREATE TABLE ${TABLE_MESSAGE}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		session_id INTEGER NOT NULL,
		task_id INTEGER,
		role TEXT NOT NULL,
		content TEXT NOT NULL DEFAULT '',
		display_content TEXT NOT NULL DEFAULT '',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);`,
	`CREATE INDEX agent.idx_agent_session_message_sid_id
		ON AgentSessionMessage(session_id, id);`,
	`CREATE TABLE ${TABLE_STEP}(
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
	);`,
	`CREATE UNIQUE INDEX agent.idx_agent_session_step_unique
		ON AgentSessionStep(session_id, task_id, step);`,
	`CREATE INDEX agent.idx_agent_session_step_sid_task_step
		ON AgentSessionStep(session_id, task_id, step);`,
	`CREATE TABLE ${TABLE_TASK}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		status TEXT NOT NULL,
		prompt TEXT NOT NULL DEFAULT '',
		head_seq INTEGER NOT NULL DEFAULT 0,
		work_mode TEXT NOT NULL DEFAULT 'code',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);`,
	`CREATE TABLE ${TABLE_CHECKPOINT}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		task_id INTEGER NOT NULL,
		seq INTEGER NOT NULL,
		status TEXT NOT NULL,
		summary TEXT NOT NULL DEFAULT '',
		tool_name TEXT NOT NULL DEFAULT '',
		created_at INTEGER NOT NULL,
		applied_at INTEGER,
		reverted_at INTEGER
	);`,
	`CREATE INDEX agent.idx_agent_cp_task_seq
		ON AgentCheckpoint(task_id, seq);`,
	`CREATE TABLE ${TABLE_CHECKPOINT_ENTRY}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		checkpoint_id INTEGER NOT NULL,
		ord INTEGER NOT NULL,
		path TEXT NOT NULL,
		op TEXT NOT NULL,
		before_exists INTEGER NOT NULL,
		before_data BLOB,
		after_exists INTEGER NOT NULL,
		after_data BLOB,
		bytes_before INTEGER NOT NULL DEFAULT 0,
		bytes_after INTEGER NOT NULL DEFAULT 0
	);`,
	`CREATE INDEX agent.idx_agent_entry_cp_ord
		ON AgentCheckpointEntry(checkpoint_id, ord);`,
	`CREATE TABLE ${TABLE_TASK_REFERENCE}(
		owner_task_id INTEGER NOT NULL,
		target_task_id INTEGER NOT NULL,
		kind TEXT NOT NULL,
		created_at INTEGER NOT NULL,
		PRIMARY KEY(owner_task_id, target_task_id, kind)
	);`,
	`CREATE INDEX agent.idx_agent_task_ref_target
		ON AgentTaskReference(target_task_id);`,
	`PRAGMA agent.user_version = ${AGENT_SCHEMA_VERSION};`,
];

const DROP_LEGACY_AGENT_SQL = [
	"DROP TABLE IF EXISTS main.AgentCheckpointEntry;",
	"DROP TABLE IF EXISTS main.AgentCheckpoint;",
	"DROP TABLE IF EXISTS main.AgentSessionStep;",
	"DROP TABLE IF EXISTS main.AgentSessionMessage;",
	"DROP TABLE IF EXISTS main.AgentSession;",
	"DROP TABLE IF EXISTS main.AgentTaskReference;",
	"DROP TABLE IF EXISTS main.AgentTask;",
	"DROP TABLE IF EXISTS main.AgentQuestionnaire;",
];

let storageError: string | undefined;
let storageReady = false;

function toStr(value: unknown): string {
	if (value === false || value === undefined) return "";
	return tostring(value);
}

function getSchemaVersion(): number | undefined {
	const rows = DB.query("PRAGMA agent.user_version");
	if (!rows || rows.length === 0 || typeof rows[0][0] !== "number") return undefined;
	return math.max(0, math.floor(rows[0][0] as number));
}

function rebuildSchema(): boolean {
	const tableRows = DB.query(
		"SELECT name FROM agent.sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
	) ?? [];
	const dropAllTables: string[] = [];
	for (let i = 0; i < tableRows.length; i++) {
		const tableName = toStr(tableRows[i][0]);
		if (tableName === "") continue;
		const [quotedName] = string.gsub(tableName, '"', '""');
		dropAllTables.push(`DROP TABLE IF EXISTS agent."${quotedName}";`);
	}
	return DB.transaction([...dropAllTables, ...DROP_AGENT_SCHEMA_SQL, ...CREATE_AGENT_SCHEMA_SQL]);
}

function validateSchema(): string | undefined {
	for (let i = 0; i < REQUIRED_TABLES.length; i++) {
		const required = REQUIRED_TABLES[i];
		const rows = DB.query(`PRAGMA agent.table_info(${required.name})`);
		if (!rows || rows.length !== required.columns.length) {
			return `table ${required.name} has an unexpected column count`;
		}
		for (let j = 0; j < required.columns.length; j++) {
			if (toStr(rows[j][1]) !== required.columns[j]) {
				return `table ${required.name} has an unexpected schema`;
			}
		}
	}
	const indexRows = DB.query(
		"SELECT name FROM agent.sqlite_master WHERE type = 'index' AND name LIKE 'idx_agent_%'",
	) ?? [];
	const indexes: Record<string, boolean> = {};
	for (let i = 0; i < indexRows.length; i++) {
		indexes[toStr(indexRows[i][0])] = true;
	}
	for (let i = 0; i < REQUIRED_INDEXES.length; i++) {
		if (!indexes[REQUIRED_INDEXES[i]]) {
			return `missing index ${REQUIRED_INDEXES[i]}`;
		}
	}
	return undefined;
}

function validateCodecAndWrite(): boolean {
	const binaryProbe = "Dora\0Blob\0Probe";
	const smallProbe = "Dora Agent small text";
	const compressedProbe = `Dora Agent checkpoint codec probe：${string.rep("压缩内容", 128)}`;
	const rows = DB.query(
		`SELECT
			CAST(? AS BLOB),
			typeof(CAST(? AS BLOB)),
			dora_decompress_text(dora_compress_text(?)),
			typeof(dora_compress_text(?)),
			dora_decompress_text(dora_compress_text(?)),
			typeof(dora_compress_text(?))`,
		[binaryProbe, binaryProbe, smallProbe, smallProbe, compressedProbe, compressedProbe],
	);
	if (
		!rows
		|| rows.length !== 1
		|| toStr(rows[0][0]) !== binaryProbe
		|| toStr(rows[0][1]) !== "blob"
		|| toStr(rows[0][2]) !== smallProbe
		|| toStr(rows[0][3]) !== "text"
		|| toStr(rows[0][4]) !== compressedProbe
		|| toStr(rows[0][5]) !== "blob"
	) {
		return false;
	}
	return DB.transaction([
		"CREATE TABLE agent.AgentStorageProbe(value INTEGER NOT NULL);",
		"INSERT INTO agent.AgentStorageProbe(value) VALUES(1);",
		"DROP TABLE agent.AgentStorageProbe;",
	]);
}

function initializeAgentStorage() {
	const dbPath = Path(Content.appPath, AGENT_DB_FILE);
	if (!DB.existDB(AGENT_SCHEMA)) {
		DB.exec(`ATTACH DATABASE ? AS ${AGENT_SCHEMA}`, [dbPath]);
	}
	if (!DB.existDB(AGENT_SCHEMA)) {
		storageError = `failed to attach ${dbPath}`;
		return;
	}

	const version = getSchemaVersion();
	if (version === undefined) {
		storageError = "failed to read agent.db schema version";
		return;
	}
	if (version > AGENT_SCHEMA_VERSION) {
		storageError = `agent.db schema ${version} is newer than supported ${AGENT_SCHEMA_VERSION}`;
		return;
	}
	if (version < AGENT_SCHEMA_VERSION && !rebuildSchema()) {
		storageError = "failed to create current agent.db schema";
		return;
	}
	const schemaError = validateSchema();
	if (schemaError) {
		storageError = `agent.db schema error: ${schemaError}`;
		return;
	}
	if (!validateCodecAndWrite()) {
		storageError = "agent.db codec or write probe failed";
		return;
	}
	if (!DB.transaction(DROP_LEGACY_AGENT_SQL)) {
		storageError = "failed to remove legacy Agent tables from dora.db";
		return;
	}
	storageReady = true;
	Log("Info", `[AgentStorage] ready path=${dbPath} schema=${AGENT_SCHEMA_VERSION}`);
}

export function isAgentStorageReady(): boolean {
	return storageReady;
}

export function getAgentStorageError(): string | undefined {
	return storageError;
}

export function requireAgentStorage(): { success: true } | { success: false; message: string } {
	if (storageReady) return { success: true };
	return {
		success: false,
		message: storageError ? `Agent database unavailable: ${storageError}` : "Agent database unavailable",
	};
}

function normalizeTaskIds(rows: unknown[][] | undefined): number[] {
	const result: number[] = [];
	if (!rows) return result;
	for (let i = 0; i < rows.length; i++) {
		const taskId = typeof rows[i][0] === "number" ? math.floor(rows[i][0] as number) : 0;
		if (taskId > 0 && result.indexOf(taskId) < 0) result.push(taskId);
	}
	return result;
}

export function getTaskReferenceClosure(rootTaskIds: number[]): number[] {
	const closure: number[] = [];
	const seen: Record<number, boolean> = {};
	const queue: number[] = [];
	for (let i = 0; i < rootTaskIds.length; i++) {
		const taskId = math.floor(rootTaskIds[i]);
		if (taskId <= 0 || seen[taskId]) continue;
		seen[taskId] = true;
		closure.push(taskId);
		queue.push(taskId);
	}
	for (let offset = 0; offset < queue.length; offset++) {
		const ownerTaskId = queue[offset];
		const targets = normalizeTaskIds(DB.query(
			`SELECT target_task_id FROM ${TABLE_TASK_REFERENCE} WHERE owner_task_id = ?`,
			[ownerTaskId],
		));
		for (let i = 0; i < targets.length; i++) {
			const targetTaskId = targets[i];
			if (seen[targetTaskId]) continue;
			seen[targetTaskId] = true;
			closure.push(targetTaskId);
			queue.push(targetTaskId);
		}
	}
	return closure;
}

export function getSessionOperableTaskIds(sessionId: number): number[] {
	const roots = normalizeTaskIds(DB.query(
		`SELECT current_task_id FROM ${TABLE_SESSION} WHERE id = ? AND current_task_id > 0`,
		[sessionId],
	));
	return getTaskReferenceClosure(roots);
}

export function getAllOperableTaskIds(): number[] {
	const roots = normalizeTaskIds(DB.query(
		`SELECT current_task_id FROM ${TABLE_SESSION} WHERE current_task_id > 0`,
	));
	return getTaskReferenceClosure(roots);
}

export function addTaskReference(ownerTaskId: number, targetTaskId: number, kind = "sub_agent_handoff"): boolean {
	if (ownerTaskId <= 0 || targetTaskId <= 0 || ownerTaskId === targetTaskId) return false;
	return DB.exec(
		`INSERT OR IGNORE INTO ${TABLE_TASK_REFERENCE}(owner_task_id, target_task_id, kind, created_at)
		VALUES(?, ?, ?, ?)`,
		[ownerTaskId, targetTaskId, kind, os.time()],
	) >= 0;
}

export function isTaskOperableForSession(sessionId: number, taskId: number): boolean {
	if (sessionId <= 0 || taskId <= 0) return false;
	return getSessionOperableTaskIds(sessionId).indexOf(taskId) >= 0;
}

function getTaskStatus(taskId: number): string {
	const rows = DB.query(`SELECT status FROM ${TABLE_TASK} WHERE id = ?`, [taskId]);
	return rows && rows.length > 0 ? toStr(rows[0][0]) : "";
}

export function cleanupTaskHeavyData(taskId: number): boolean {
	if (taskId <= 0) return false;
	const status = getTaskStatus(taskId);
	if (status === "") return false;
	if (status === "RUNNING" || status === "WAITING_USER") return false;
	if (getAllOperableTaskIds().indexOf(taskId) >= 0) return false;
	const targets = normalizeTaskIds(DB.query(
		`SELECT target_task_id FROM ${TABLE_TASK_REFERENCE} WHERE owner_task_id = ?`,
		[taskId],
	));
	const success = DB.transaction([
		`DELETE FROM ${TABLE_CHECKPOINT_ENTRY}
			WHERE checkpoint_id IN (SELECT id FROM ${TABLE_CHECKPOINT} WHERE task_id = ${math.floor(taskId)});`,
		`DELETE FROM ${TABLE_CHECKPOINT} WHERE task_id = ${math.floor(taskId)};`,
		`DELETE FROM ${TABLE_STEP} WHERE task_id = ${math.floor(taskId)};`,
		`DELETE FROM ${TABLE_TASK_REFERENCE}
			WHERE owner_task_id = ${math.floor(taskId)}
				OR target_task_id = ${math.floor(taskId)};`,
		`DELETE FROM ${TABLE_TASK}
			WHERE id = ${math.floor(taskId)}
				AND NOT EXISTS (
					SELECT 1 FROM ${TABLE_MESSAGE} WHERE task_id = ${math.floor(taskId)}
				)
				AND NOT EXISTS (
					SELECT 1 FROM ${TABLE_SESSION} WHERE current_task_id = ${math.floor(taskId)}
				)
				AND NOT EXISTS (
					SELECT 1 FROM ${TABLE_TASK_REFERENCE}
					WHERE owner_task_id = ${math.floor(taskId)}
						OR target_task_id = ${math.floor(taskId)}
				);`,
	]);
	if (!success) return false;
	Log("Info", `[AgentStorage] cleaned heavy data task=${taskId}`);
	for (let i = 0; i < targets.length; i++) {
		cleanupTaskHeavyData(targets[i]);
	}
	return true;
}

export interface AgentStorageAudit {
	taskCount: number;
	checkpointCount: number;
	entryCount: number;
	stepCount: number;
	referenceCount: number;
	rawBytes: number;
	candidateTaskIds: number[];
}

export function auditOrphanHeavyData(): AgentStorageAudit {
	const operable = getAllOperableTaskIds();
	const rows = DB.query(
		`SELECT t.id,
			(SELECT COUNT(*) FROM ${TABLE_CHECKPOINT} c WHERE c.task_id = t.id),
			(SELECT COUNT(*) FROM ${TABLE_CHECKPOINT_ENTRY} e
				JOIN ${TABLE_CHECKPOINT} c ON c.id = e.checkpoint_id WHERE c.task_id = t.id),
			(SELECT COUNT(*) FROM ${TABLE_STEP} s WHERE s.task_id = t.id),
			(SELECT COUNT(*) FROM ${TABLE_TASK_REFERENCE} r WHERE r.owner_task_id = t.id),
			(SELECT COALESCE(SUM(e.bytes_before + e.bytes_after), 0) FROM ${TABLE_CHECKPOINT_ENTRY} e
				JOIN ${TABLE_CHECKPOINT} c ON c.id = e.checkpoint_id WHERE c.task_id = t.id),
			(SELECT COUNT(*) FROM ${TABLE_MESSAGE} m WHERE m.task_id = t.id)
		FROM ${TABLE_TASK} t
		WHERE t.status NOT IN ('RUNNING', 'WAITING_USER')`,
	) ?? [];
	const audit: AgentStorageAudit = {
		taskCount: 0,
		checkpointCount: 0,
		entryCount: 0,
		stepCount: 0,
		referenceCount: 0,
		rawBytes: 0,
		candidateTaskIds: [],
	};
	for (let i = 0; i < rows.length; i++) {
		const taskId = rows[i][0] as number;
		if (operable.indexOf(taskId) >= 0) continue;
		const checkpointCount = (rows[i][1] as number | undefined) ?? 0;
		const entryCount = (rows[i][2] as number | undefined) ?? 0;
		const stepCount = (rows[i][3] as number | undefined) ?? 0;
		const referenceCount = (rows[i][4] as number | undefined) ?? 0;
		const messageCount = (rows[i][6] as number | undefined) ?? 0;
		if (
			checkpointCount <= 0
			&& entryCount <= 0
			&& stepCount <= 0
			&& referenceCount <= 0
			&& messageCount > 0
		) {
			continue;
		}
		audit.taskCount++;
		audit.checkpointCount += checkpointCount;
		audit.entryCount += entryCount;
		audit.stepCount += stepCount;
		audit.referenceCount += referenceCount;
		audit.rawBytes += (rows[i][5] as number | undefined) ?? 0;
		audit.candidateTaskIds.push(taskId);
	}
	return audit;
}

export function cleanupOrphanHeavyDataBatch(maxTasks = 4): AgentStorageAudit {
	const audit = auditOrphanHeavyData();
	const limit = math.max(0, math.floor(maxTasks));
	let cleaned = 0;
	for (let i = 0; i < audit.candidateTaskIds.length && cleaned < limit; i++) {
		if (cleanupTaskHeavyData(audit.candidateTaskIds[i])) {
			cleaned++;
		}
	}
	if (audit.taskCount > 0) {
		Log(
			"Info",
			`[AgentStorage] orphan audit tasks=${audit.taskCount} checkpoints=${audit.checkpointCount} entries=${audit.entryCount} steps=${audit.stepCount} refs=${audit.referenceCount} raw_bytes=${audit.rawBytes} cleaned=${cleaned}`,
		);
	}
	return audit;
}

initializeAgentStorage();
