// @preview-file off clear
import { sleep } from 'Dora';

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
/** Wait for the prior Agent test to clean up while the calling command is live. */
export function acquireEntryLease(id: string, entry: DevEntryModule, isCancelled: () => boolean): void {
	while (owner !== "" && owner !== id && !isCancelled()) sleep();
	if (isCancelled()) error("Agent entry request cancelled");
	const status = entry.getCurrentEntryStatus();
	if (status.running && (owner !== id || status.runId !== runId)) {
		error("A user game is running. Stop the game before running an Agent preview or test.");
	}
	owner = id;
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
export function canClearEntryAfterCommand(id: string, entry: DevEntryModule): boolean {
	return ownsEntryLease(id, entry) || (owner === "" && !entry.getCurrentEntryStatus().running);
}
export function releaseEntryLease(id: string, entry: DevEntryModule): string | undefined {
	if (owner !== id) return undefined;
	let cleanupError: string | undefined;
	try { if (ownsEntryLease(id, entry) && !entry.stop()) error("entry refused to stop"); }
	catch (e) { cleanupError = `failed to stop Agent preview: ${tostring(e)}`; }
	owner = ""; runId = undefined;
	return cleanupError;
}
