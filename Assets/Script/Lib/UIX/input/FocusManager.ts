import type * as Dora from "Dora";

export interface FocusHandle {
	id: string;
	node: Dora.Node.Type;
	disabled: (this: void) => boolean;
	focus: (this: void) => void;
	blur: (this: void) => void;
	activate: (this: void) => void;
}

export class FocusManager {
	private handles: FocusHandle[] = [];
	private current?: FocusHandle;

	register(this: FocusManager, handle: FocusHandle): void {
		this.unregister(handle.id);
		this.handles.push(handle);
	}

	unregister(this: FocusManager, id: string): void {
		for (let i of $range(1, this.handles.length)) {
			if (this.handles[i - 1].id === id) {
				const handle = this.handles[i - 1];
				if (this.current === handle) {
					handle.blur();
					this.current = undefined;
				}
				table.remove(this.handles, i);
				return;
			}
		}
	}

	focus(this: FocusManager, id: string): void {
		for (let i of $range(1, this.handles.length)) {
			const handle = this.handles[i - 1];
			if (handle.id === id && !handle.disabled()) {
				if (this.current !== undefined && this.current !== handle) {
					this.current.blur();
				}
				this.current = handle;
				handle.focus();
				return;
			}
		}
	}

	focusNext(this: FocusManager): void {
		if (this.handles.length === 0) return;
		let start = 1;
		if (this.current !== undefined) {
			for (let i of $range(1, this.handles.length)) {
				if (this.handles[i - 1] === this.current) {
					start = i + 1;
					break;
				}
			}
		}
		for (let offset of $range(0, this.handles.length - 1)) {
			const index = ((start + offset - 1) % this.handles.length) + 1;
			const handle = this.handles[index - 1];
			if (!handle.disabled()) {
				this.focus(handle.id);
				return;
			}
		}
	}

	activate(this: FocusManager): void {
		if (this.current !== undefined && !this.current.disabled()) {
			this.current.activate();
		}
	}

	clear(this: FocusManager): void {
		if (this.current !== undefined) {
			this.current.blur();
		}
		this.current = undefined;
		this.handles = [];
	}
}

