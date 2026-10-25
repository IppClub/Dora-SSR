/* Copyright (c) 2026 Li Jin <dragon-fly@qq.com>
 * SPDX-License-Identifier: MIT */
import { MAX_CONCURRENT_UPLOADS } from './UploadFile';

export const UPLOAD_ADMISSION_BATCH_SIZE = 64;

export class FolderUploadQueue<T> {
	private pending: T[] = [];
	private pendingHead = 0;
	private ready: T[] = [];
	private head = 0;
	private active = 0;
	private timer: ReturnType<typeof setTimeout> | undefined;
	private controller = new AbortController();
	private disposed = false;

	constructor(private handlers: {
		admit: (item: T) => boolean | void;
		upload: (item: T, signal: AbortSignal) => Promise<void>;
		error: (item: T, error: unknown) => void;
	}) {}

	enqueue(item: T) {
		if (this.disposed) return;
		this.pending.push(item);
		if (this.timer === undefined) this.scheduleAdmission();
	}

	private scheduleAdmission() {
		if (this.disposed || this.timer !== undefined) return;
		this.timer = setTimeout(() => {
			this.timer = undefined;
			// Yield between batches so selecting a large folder cannot monopolize UI work.
			const batch = this.pending.slice(this.pendingHead, this.pendingHead + UPLOAD_ADMISSION_BATCH_SIZE);
			this.pendingHead += batch.length;
			for (const item of batch) {
				if (this.disposed) return;
				if (this.handlers.admit(item) !== false) this.ready.push(item);
			}
			this.drain();
			if (this.pendingHead < this.pending.length) this.scheduleAdmission();
			else { this.pending = []; this.pendingHead = 0; }
		}, 0);
	}

	private drain() {
		while (!this.disposed && this.active < MAX_CONCURRENT_UPLOADS && this.head < this.ready.length) {
			const item = this.ready[this.head++];
			this.active++;
			void Promise.resolve().then(() => {
				if (!this.disposed) return this.handlers.upload(item, this.controller.signal);
			}).catch(error => {
				if (!this.disposed) this.handlers.error(item, error);
			}).finally(() => {
				this.active--;
				this.drain();
			});
		}
		// Release consumed File references without shifting the remaining queue per upload.
		if (this.head && this.head === this.ready.length) {
			this.ready = [];
			this.head = 0;
		} else if (this.head >= 256 && this.head >= this.ready.length / 2) {
			this.ready = this.ready.slice(this.head);
			this.head = 0;
		}
	}

	dispose() {
		this.disposed = true;
		clearTimeout(this.timer);
		this.controller.abort();
		this.pending = [];
		this.pendingHead = 0;
		this.ready = [];
		this.head = 0;
	}
}
