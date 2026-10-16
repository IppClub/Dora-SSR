// @preview-file off clear
export interface StreamText {
	content?: string;
	reasoningContent?: string;
}
interface PendingUpdate {
	sessionId: number;
	taskId: number;
	step: number;
	value: StreamText;
	deltas: number;
	length: number;
	flushedAt: number;
	dirty: boolean;
}

/** Keep the first snapshot immediate, bound subsequent latency, and release
 * full text snapshots at every terminal/session lifecycle boundary. */
export class StreamUpdates {
	private entries: Record<string, PendingUpdate> = {};
	constructor(private publish: (sessionId: number, taskId: number, step: number, value: StreamText) => void) {}
	private key(sessionId: number, taskId: number, step: number): string {
		return `${sessionId}:${taskId}:${step}`;
	}
	private length(value: StreamText): number {
		return (value.content?.length ?? 0) + (value.reasoningContent?.length ?? 0);
	}
	private flush(entry: PendingUpdate, now: number) {
		entry.dirty = false;
		entry.deltas = 0;
		entry.length = this.length(entry.value);
		entry.flushedAt = now;
		this.publish(entry.sessionId, entry.taskId, entry.step, entry.value);
	}
	update(sessionId: number, taskId: number, step: number, value: StreamText, now: number) {
		const key = this.key(sessionId, taskId, step);
		let entry = this.entries[key];
		if (entry === undefined) {
			entry = {sessionId, taskId, step, value: {content: value.content, reasoningContent: value.reasoningContent}, deltas: 0, length: 0, flushedAt: now, dirty: true};
			this.entries[key] = entry;
			this.flush(entry, now);
			return;
		}
		// Session upserts treat missing/empty fields as unchanged. Preserve a
		// reasoning-only snapshot when a later content-only event arrives.
		entry.value = {
			content: value.content !== undefined && value.content !== "" ? value.content : entry.value.content,
			reasoningContent: value.reasoningContent !== undefined && value.reasoningContent !== "" ? value.reasoningContent : entry.value.reasoningContent,
		};
		entry.dirty = true;
		entry.deltas++;
		if (entry.deltas >= 32 || this.length(entry.value) - entry.length >= 4096 || now - entry.flushedAt >= 0.1)
			this.flush(entry, now);
	}
	flushDue(now: number) {
		for (const key of Object.keys(this.entries)) {
			const entry = this.entries[key];
			if (entry !== undefined && entry.dirty && now - entry.flushedAt >= 0.1) this.flush(entry, now);
		}
	}
	hasPending(): boolean {
		return Object.keys(this.entries).some(key => this.entries[key].dirty);
	}
	finish(sessionId: number, taskId: number, step: number) {
		delete this.entries[this.key(sessionId, taskId, step)];
	}
	clear(sessionId: number, taskId?: number, flushAt?: number) {
		for (const key of Object.keys(this.entries)) {
			const entry = this.entries[key];
			if (entry === undefined || entry.sessionId !== sessionId || (taskId !== undefined && entry.taskId !== taskId)) continue;
			// Detach before publishing so reentrant lifecycle events cannot resurrect it.
			delete this.entries[key];
			if (entry.dirty && flushAt !== undefined) this.flush(entry, flushAt);
		}
	}
}
