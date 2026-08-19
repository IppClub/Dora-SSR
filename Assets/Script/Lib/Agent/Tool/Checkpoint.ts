// @preview-file off clear
import { Content, DB, Path } from 'Dora';
import type { SQL } from 'Dora';
import {
	TABLE_TASK,
	TABLE_CHECKPOINT as TABLE_CP,
	TABLE_CHECKPOINT_ENTRY as TABLE_ENTRY,
	requireAgentStorage,
} from 'Agent/Storage/Database';
import { Log } from 'Agent/Utils';
import {
	isValidWorkDir,
	isValidWorkspacePath,
	resolveWorkspaceFilePath,
	toWorkspaceRelativePath,
	ensureDirForFile,
	getFileState,
} from 'Agent/Tool/Workspace';
import { sendWebIDEFileUpdate, sendWebIDERefreshTree } from 'Agent/Tool/WebIDESync';
import { getLastInsertRowId, queryOne, toStr } from 'Agent/Storage/Support';

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

const now = () => os.time();

function toBool(v: unknown): boolean {
	return v !== 0 && v !== false && v !== undefined;
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
		if (Content.exist(fullPath) && !Content.isdir(fullPath)) {
			const [, isBinary] = Content.getAttr(fullPath);
			if (isBinary === true) {
				return {
					success: false,
					message: change.op === "delete"
						? `binary file deletion must use delete_file: ${change.path}`
						: `binary files cannot be edited with text checkpoints: ${change.path}`,
				};
			}
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
