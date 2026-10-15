// @preview-file off clear
type Listener = (this: void, payload: string, sequence: number) => void;
const listeners: Record<number, {sessionId: number; listener: Listener}> = {};
const sequences: Record<number, number> = {};
let nextId = 0;

/** Trusted host subscription; not an authorization boundary for project code. */
export function subscribeSessionPatches(sessionId: number, listener: Listener): (this: void) => void {
	if (typeof sessionId !== "number" || !Number.isFinite(sessionId) || Math.floor(sessionId) !== sessionId || sessionId <= 0 || sessionId > 9007199254740991 || typeof listener !== "function") error("Invalid session subscription");
	const id = ++nextId;
	listeners[id] = {sessionId, listener};
	return () => { delete listeners[id]; };
}

/** Immutable serialized payload, snapshot iteration and isolated observer errors. */
export function publishSessionPatch(sessionId: number, payload: string): number {
	const sequence = (sequences[sessionId] ?? 0) + 1;
	if (sequence > 9007199254740991) error("Session event sequence exhausted");
	sequences[sessionId] = sequence;
	const pending = Object.values(listeners).filter(item => item.sessionId === sessionId);
	let failed = 0;
	for (const item of pending) {
		try { item.listener(payload, sequence); } catch { failed++; }
	}
	return failed;
}

/** Read on the same trusted synchronous host. A yielding/mutating read is not a stable snapshot.
 * Sequence numbers are runtime-local; a runtime restart requires a new host generation.
 */
export function captureSessionSnapshot(sessionId: number, read: (this: void) => string): {payload: string; sequence: number} {
	if (!Number.isFinite(sessionId) || Math.floor(sessionId) !== sessionId || sessionId <= 0 || sessionId > 9007199254740991) error("Invalid snapshot session");
	const sequence = sequences[sessionId] ?? 0;
	const payload = read();
	if (typeof payload !== "string" || (sequences[sessionId] ?? 0) !== sequence) error("Session changed during snapshot read");
	return {payload, sequence};
}
