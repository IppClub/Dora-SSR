import { DB } from 'Dora';
import { safeJsonDecode, safeJsonEncode } from 'Agent/Utils';
import { queryRows, toStr, getLastInsertRowId } from 'Agent/Storage/Support';

export type InputDelivery = "queue" | "steer";
export interface InputSubmission {
	delivery?: InputDelivery;
	requestId?: string;
	action?: "cancel" | "edit" | "steer" | "resume" | "hold" | "release";
	inputId?: number;
}
export interface PendingInput {
	id: number;
	content: string;
	delivery: InputDelivery;
	status: string;
	held: boolean;
	taskId?: number;
	options: Record<string, unknown>;
}
const table = "agent.AgentSessionInput";
function checkedExec(sql: string, values: (string | number | boolean)[]): number {
 const changed = DB.exec(sql,values);
 if (changed < 0) throw new Error("failed to persist Agent input queue");
 return changed;
}
function decode(row: unknown[]): PendingInput {
	const [options] = safeJsonDecode(toStr(row[6]));
	return {id: row[0] as number, content: toStr(row[1]), delivery: row[2] === "steer" ? "steer" : "queue",
		status: toStr(row[3]), held: row[4] === 1, taskId: typeof row[5] === "number" ? row[5] : undefined,
		options: options && typeof options === "object" ? options as Record<string, unknown> : {}};
}
export function listInputs(sessionId: number, includeDelivered = false): PendingInput[] {
	return (queryRows(`SELECT id, content, delivery, status, held, task_id, options_json FROM ${table}
		WHERE session_id = ? AND status IN (${includeDelivered ? "'pending','delivering','editing','delivered'" : "'pending','delivering','editing'"}) ORDER BY position, id`, [sessionId]) ?? []).map(row=>decode(row));
}
export function getInput(sessionId: number, id: number): PendingInput | undefined {
	const rows = queryRows(`SELECT id, content, delivery, status, held, task_id, options_json FROM ${table} WHERE session_id=? AND id=?`, [sessionId, id]);
	return rows && rows.length > 0 ? decode(rows[0]) : undefined;
}
export function admitInput(sessionId: number, content: string, delivery: InputDelivery, requestId: string, options: Record<string, unknown>, taskId?: number): PendingInput {
	const existing = queryRows(`SELECT id, content, delivery, status, held, task_id, options_json FROM ${table} WHERE session_id=? AND request_id=?`, [sessionId, requestId]);
	if (existing && existing.length > 0) {
		const item = decode(existing[0]);
		if ((item.options.submittedContent ?? item.content) !== content) throw new Error("input request ID was reused with different content");
		return item;
	}
	if (listInputs(sessionId).length >= 50) throw new Error("message queue is full (50); remove an entry first");
	const [encoded] = safeJsonEncode({...options,submittedContent:content});
	if (!encoded || checkedExec(`INSERT INTO ${table}(session_id,request_id,content,delivery,status,held,task_id,options_json,position)
		VALUES(?,?,?,?, 'pending',0,?,?,COALESCE((SELECT MAX(position)+1 FROM ${table} WHERE session_id=?),1))`,
		[sessionId, requestId, content, delivery, taskId ?? false, encoded, sessionId]) < 0) throw new Error("failed to save pending input");
	const item = getInput(sessionId, getLastInsertRowId());
	if (!item) throw new Error("failed to read saved input");
	return item;
}
export function markDelivering(id: number, taskId: number): void {
	if (checkedExec(`UPDATE ${table} SET status='delivering', task_id=? WHERE id=? AND status IN ('pending','delivering')`, [taskId,id]) < 0) throw new Error("failed to reserve input");
}
export function markDelivered(id: number, messageId?: number, step = 0): void {
	if (checkedExec(`UPDATE ${table} SET status='delivered',message_id=COALESCE(?,message_id),delivered_step=? WHERE id=?`, [messageId ?? false,step,id]) < 0) throw new Error("failed to commit input delivery");
}
export function holdInputs(sessionId: number): void {
	checkedExec(`UPDATE ${table} SET held=1, delivery='queue' WHERE session_id=? AND status IN ('pending','delivering','editing')`, [sessionId]);
}
export function recoverInputs(sessionId: number): void {
	checkedExec(`UPDATE ${table} SET status='pending',held=1,delivery='queue' WHERE session_id=? AND status IN ('delivering','editing')`, [sessionId]);
	holdInputs(sessionId);
}
export function mutateInput(sessionId: number, command: InputSubmission, content: string): void {
	if (command.action === "resume") {
		checkedExec(`UPDATE ${table} SET held=0 WHERE session_id=? AND status='pending'`, [sessionId]);
		return;
	}
	const item = getInput(sessionId, command.inputId ?? 0);
	if (!item || (item.status !== "pending" && item.status !== "editing")) throw new Error("input was already delivered or removed; refresh the queue");
	if (command.action === "hold" || command.action === "release") checkedExec(`UPDATE ${table} SET status=? WHERE id=?`,[command.action === "hold" ? "editing" : "pending",item.id]);
	else if (command.action === "cancel") checkedExec(`UPDATE ${table} SET status='cancelled' WHERE id=?`, [item.id]);
	else if (command.action === "edit") {
		if (content.trim() === "") throw new Error("prompt is empty");
		checkedExec(`UPDATE ${table} SET content=? WHERE id=?`, [content,item.id]);
	} else if (item.status === "editing") throw new Error("message is being edited; finish or release the edit first");
	else if (command.action === "steer") checkedExec(`UPDATE ${table} SET delivery='steer',held=0 WHERE id=?`, [item.id]);
	else throw new Error("invalid input action");
}
