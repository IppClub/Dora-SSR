// @preview-file off clear
type Listener = (this: void, payload: string) => void;
const listeners: Record<number, {workDir: string; listener: Listener}> = {};
let nextId = 0;

/** Trusted host notifications only; checkpoint storage remains authoritative. */
export function subscribeFileCommits(workDir: string, listener: Listener): (this: void) => void {
	if (typeof workDir !== "string" || workDir === "" || typeof listener !== "function") error("Invalid file commit subscription");
	const id = ++nextId;
	listeners[id] = {workDir, listener};
	return () => { delete listeners[id]; };
}

export function hasFileCommitListeners(workDir: string): boolean {
	return Object.values(listeners).some(item => item.workDir === workDir);
}

/** Immutable serialized batch; observer errors cannot undo a completed tool commit.
 * This notification is not an acknowledgement of Studio workspace persistence.
 */
export function publishFileCommit(workDir: string, payload: string): number {
	const pending = Object.values(listeners).filter(item => item.workDir === workDir);
	let failed = 0;
	for (const item of pending) {
		try { item.listener(payload); } catch { failed++; }
	}
	return failed;
}
