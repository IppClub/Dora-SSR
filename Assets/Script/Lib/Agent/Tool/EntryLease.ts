// @preview-file off clear
export interface EntryStatus {
	success: boolean;
	running: boolean;
	runId?: number;
	kind?: string;
	fileName?: string;
	workDir?: string;
	projectRoot?: string;
	entryName?: string;
}
export interface DevEntryModule {
	allClear(this: void): void;
	stop(this: void): boolean;
	getCurrentEntryStatus(this: void): EntryStatus;
	enterEntryAsync(this: void, entry: {entryName: string; fileName: string; workDir: string; projectRoot: string; runKind: "agent_test"}): LuaMultiReturn<[boolean, string | undefined]>;
}
let owner = "";
let runId: number | undefined;
/**
 * Acquires the Agent-owned Entry runtime. A running game without an Agent
 * owner belongs to the user and is stopped so Agent work takes priority.
 * Agent-owned runs remain mutually exclusive and are never preempted.
 * Returns true when a user game was interrupted.
 */
export function acquireEntryLease(id: string, entry: DevEntryModule): boolean {
	if (owner !== "" && owner !== id) error("Dora entry runtime is busy with another Agent tool");
	const status = entry.getCurrentEntryStatus();
	let interruptedUserRun = false;
	if (status.running && (owner !== id || status.runId !== runId)) {
		if (owner !== "") error("Dora entry runtime is busy with another Agent tool");
		if (!entry.stop()) error("Dora could not interrupt the running user game for Agent work");
		interruptedUserRun = true;
	}
	owner = id;
	return interruptedUserRun;
}
// The lease predicts Entry's next run id as (current + 1). This relies on an
// invariant in Script.Dev.Entry: enterEntryAsync increments its run counter
// exactly once, synchronously at entry, and nothing else increments it.
export function recordEntryLeaseRun(id: string, entry: DevEntryModule): void {
	if (owner === id) runId = (entry.getCurrentEntryStatus().runId ?? 0) + 1;
}
export function ownsEntryLease(id: string, entry: DevEntryModule): boolean {
	const status = entry.getCurrentEntryStatus();
	return owner === id && status.running && runId !== undefined && status.runId === runId;
}
export function releaseEntryLease(id: string, entry: DevEntryModule): string | undefined {
	if (owner !== id) return undefined;
	let cleanupError: string | undefined;
	try { if (ownsEntryLease(id, entry) && !entry.stop()) error("entry refused to stop"); }
	catch (e) { cleanupError = `failed to stop Agent preview: ${tostring(e)}`; }
	owner = ""; runId = undefined;
	return cleanupError;
}
