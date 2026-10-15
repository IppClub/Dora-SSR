// @preview-file off clear

export type EntryRunQueueItemState = "queued" | "running" | "missing";

export interface EntryRunQueueItem {
	id: string;
	state: EntryRunQueueItemState;
	position?: number;
}

export interface EntryRunQueue {
	enqueue(id: string): {success: true; position: number} | {success: false; message: string};
	tryAcquire(id: string): boolean;
	get(id: string): EntryRunQueueItem;
	release(id: string): boolean;
	cancel(id: string): boolean;
	size(): number;
}

/**
 * FIFO admission in front of EntryLease. The queue decides which request may
 * attempt to acquire the renderer; EntryLease remains the authority for
 * ownership of the actual Entry run and its cleanup.
 */
export function createEntryRunQueue(maxPending = 32): EntryRunQueue {
	let active = "";
	const waiting: string[] = [];
	const validId = (id: string) => typeof id === "string" && id.trim() !== "";
	const waitingIndex = (id: string) => waiting.indexOf(id);
	return {
		enqueue(id) {
			if (!validId(id)) return {success: false, message: "entry run id is required"};
			if (active === id || waitingIndex(id) >= 0) return {success: false, message: "entry run is already queued"};
			if (waiting.length >= maxPending) return {success: false, message: "entry run queue is full"};
			waiting.push(id);
			return {success: true, position: waiting.length};
		},
		tryAcquire(id) {
			if (active === id) return true;
			if (active !== "" || waiting[0] !== id) return false;
			waiting.shift();
			active = id;
			return true;
		},
		get(id) {
			if (active === id) return {id, state: "running"};
			const index = waitingIndex(id);
			return index >= 0 ? {id, state: "queued", position: index + 1} : {id, state: "missing"};
		},
		release(id) {
			if (active !== id) return false;
			active = "";
			return true;
		},
		cancel(id) {
			const index = waitingIndex(id);
			if (index < 0) return false;
			waiting.splice(index, 1);
			return true;
		},
		size() {
			return waiting.length + (active === "" ? 0 : 1);
		},
	};
}

export const sharedEntryRunQueue = createEntryRunQueue();
