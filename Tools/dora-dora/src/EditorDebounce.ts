// Pending checks belong to files, so switching tabs does not discard another
// file's check. Keep only the latest snapshot for each file during a burst.
export class EditorDebounce {
	private pending = new Map<string, ReturnType<typeof setTimeout>>();
	private onPendingChanged: (pending: boolean) => void;
	constructor(onPendingChanged: (pending: boolean) => void) {
		this.onPendingChanged = onPendingChanged;
	}
	schedule(key: string, check: () => void) {
		const previous = this.pending.get(key);
		if (previous !== undefined) clearTimeout(previous);
		const wasIdle = this.pending.size === 0;
		this.pending.set(key, setTimeout(() => {
			this.pending.delete(key);
			try { check(); }
			finally { if (this.pending.size === 0) this.onPendingChanged(false); }
		}, 500));
		if (wasIdle) this.onPendingChanged(true);
	}
	dispose() {
		for (const timer of this.pending.values()) clearTimeout(timer);
		this.pending.clear();
	}
}
