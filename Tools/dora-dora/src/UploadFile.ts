import { sha256 } from '@noble/hashes/sha2.js';
import { bytesToHex } from '@noble/hashes/utils.js';

export const MAX_UPLOAD_FILE_BYTES = Number.MAX_SAFE_INTEGER;
export const UPLOAD_CHUNK_BYTES = 4 * 1024 * 1024;
export const RESUMABLE_UPLOAD_THRESHOLD = 32 * 1024 * 1024;
export const MAX_CONCURRENT_UPLOADS = 2;
export type UploadPhase = 'hashing' | 'uploading' | 'verifying' | 'resuming';
export type UploadProgress = (percent: number, phase: UploadPhase) => void;

export class UploadError extends Error {
	constructor(public readonly fileName: string, public readonly reason: string, public readonly status?: number) {
		super(reason);
	}
}

export function checkUploadSize(file: Pick<File, 'name' | 'size'>) {
	if (!Number.isSafeInteger(file.size) || file.size < 0) throw new UploadError(file.name, 'tooLarge');
}

async function send(url: string, file: File, body: BodyInit, signal?: AbortSignal, resumable = false) {
	let response: Response;
	try {
		// Preserve the authenticated fetch wrapper. Only a single chunk is buffered.
		response = await fetch(url, { method: 'POST', body, signal,
			headers: resumable ? { 'Content-Type': 'application/octet-stream' } : undefined });
	} catch (error) {
		if (signal?.aborted) throw error;
		throw new UploadError(file.name, 'networkError');
	}
	if (!response.ok) {
		const reasons: Record<number, string> = {
			400: 'invalidRequest', 401: 'unauthorized', 403: 'forbidden', 404: 'resumeUnsupported',
			408: 'timedOut', 409: 'resumeConflict', 413: 'serverTooLarge', 422: 'integrityError',
			503: 'busy', 504: 'timedOut', 507: 'storageError',
		};
		throw new UploadError(file.name, reasons[response.status] ?? 'serverError', response.status);
	}
	return response;
}

function pause(ms: number, signal?: AbortSignal) {
	return new Promise<void>((resolve, reject) => {
		const abort = () => { clearTimeout(timer); signal?.removeEventListener('abort', abort); reject(new DOMException('Aborted', 'AbortError')); };
		const timer = setTimeout(() => { signal?.removeEventListener('abort', abort); resolve(); }, ms);
		signal?.addEventListener('abort', abort, { once: true });
		if (signal?.aborted) abort();
	});
}

async function runUploadFile(url: string, file: File, signal?: AbortSignal, progress?: UploadProgress) {
	checkUploadSize(file);
	if (file.size < RESUMABLE_UPLOAD_THRESHOLD) {
		const form = new FormData();
		form.append('file', file, file.name);
		await send(url, file, form, signal);
		progress?.(100, 'uploading');
		return;
	}
	progress?.(0, 'hashing');
	const hasher = sha256.create();
	for (let offset = 0; offset < file.size; offset += UPLOAD_CHUNK_BYTES) {
		signal?.throwIfAborted();
		hasher.update(new Uint8Array(await file.slice(offset, offset + UPLOAD_CHUNK_BYTES).arrayBuffer()));
	}
	const hash = bytesToHex(hasher.digest());
	const split = url.indexOf('?');
	const base = split < 0 ? url : url.slice(0, split);
	const params = new URLSearchParams(split < 0 ? '' : url.slice(split + 1));
	params.set('size', String(file.size));
	params.set('hash', hash);
	// Stable across reloads and engine restarts. A different file with the same
	// name/size cannot reuse a checkpoint because its full content hash differs.
	params.set('id', bytesToHex(sha256(new TextEncoder().encode(JSON.stringify([params.get('path'), params.get('name'), file.size, hash])))));
	const request = async (action: string, offset = 0, chunk?: Uint8Array) => {
		const query = new URLSearchParams(params);
		query.set('action', action);
		query.set('offset', String(offset));
		if (chunk) query.set('chunkHash', bytesToHex(sha256(chunk)));
		const response = await send(`${base}/resumable?${query}`, file, chunk ? new Blob([chunk as Uint8Array<ArrayBuffer>]) : '', signal, true);
		let result: { offset: number; complete: boolean };
		try { result = await response.json(); }
		catch { throw new UploadError(file.name, 'invalidRequest'); }
		if (!Number.isSafeInteger(result.offset) || result.offset < 0 || result.offset > file.size || typeof result.complete !== 'boolean' || (result.complete && result.offset !== file.size)) {
			throw new UploadError(file.name, 'invalidRequest');
		}
		return result;
	};
	for (let attempt = 0; ; attempt++) {
		try {
			progress?.(0, 'resuming');
			let state = await request('status');
			if (state.complete) { progress?.(100, 'uploading'); return; }
			let offset = state.offset;
			progress?.(offset / file.size * 100, 'uploading');
			while (offset < file.size) {
				signal?.throwIfAborted();
				const chunk = new Uint8Array(await file.slice(offset, offset + UPLOAD_CHUNK_BYTES).arrayBuffer());
				state = await request('chunk', offset, chunk);
				if (state.offset !== offset + chunk.length) throw new UploadError(file.name, 'resumeConflict', 409);
				offset = state.offset;
				progress?.(Math.min(99, offset / file.size * 100), 'uploading');
			}
			progress?.(99, 'verifying');
			state = await request('complete');
			if (!state.complete || state.offset !== file.size) throw new UploadError(file.name, 'invalidRequest');
			progress?.(100, 'uploading');
			return;
		} catch (error) {
			const retryable = error instanceof UploadError && ['networkError', 'timedOut', 'busy', 'resumeConflict'].includes(error.reason);
			if (signal?.aborted || !retryable || attempt >= 3) throw error;
			progress?.(0, 'resuming');
			await pause(500 * 2 ** attempt, signal);
		}
	}
}

// Folder uploads share a bounded queue, so many large files do not exhaust the
// server's body budget or hash all selected files simultaneously.
let activeUploads = 0;
const waitingUploads: Array<() => void> = [];
function acquireUploadSlot(signal?: AbortSignal): Promise<() => void> {
	return new Promise((resolve, reject) => {
		const abort = () => {
			const index = waitingUploads.indexOf(grant);
			if (index >= 0) waitingUploads.splice(index, 1);
			signal?.removeEventListener('abort', abort);
			reject(new DOMException('Aborted', 'AbortError'));
		};
		const grant = () => {
			signal?.removeEventListener('abort', abort);
			activeUploads++;
			resolve(() => { activeUploads--; waitingUploads.shift()?.(); });
		};
		if (signal?.aborted) { abort(); return; }
		if (activeUploads < MAX_CONCURRENT_UPLOADS) grant();
		else { waitingUploads.push(grant); signal?.addEventListener('abort', abort, { once: true }); }
	});
}
export async function uploadFile(url: string, file: File, signal?: AbortSignal, progress?: UploadProgress) {
	checkUploadSize(file);
	const release = await acquireUploadSlot(signal);
	try { signal?.throwIfAborted(); await runUploadFile(url, file, signal, progress); }
	finally { release(); }
}
