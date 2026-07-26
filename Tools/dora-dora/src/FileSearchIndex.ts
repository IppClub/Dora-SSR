/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

import { FileSearchIndexCore } from "./FileSearchIndexCore";
import type {
	FileSearchEntry,
	FileSearchRoot,
	FileSearchSnapshot,
	FileSearchWorkerRequest,
	FileSearchWorkerResponse,
	FilterOption,
} from "./FileSearchProtocol";

let worker: Worker | null = null;
let workerUnavailable = false;
let generation = 0;
let requestId = 0;
let snapshot: FileSearchSnapshot | null = null;
let fallbackIndex: FileSearchIndexCore | null = null;
let readyPromise: Promise<void> = Promise.resolve();
let resolveReady: (() => void) | null = null;
const pendingQueries = new Map<number, (entries: FileSearchEntry[]) => void>();

const updateDiagnostics = (values: Record<string, string | number | boolean>) => {
	if (typeof document === "undefined") return;
	const node = document.querySelector<HTMLElement>("[data-dora-perf-diagnostics]");
	if (!node) return;
	for (const [key, value] of Object.entries(values)) {
		node.dataset[key] = String(value);
	}
};

const resolvePendingQueries = () => {
	for (const resolve of pendingQueries.values()) resolve([]);
	pendingQueries.clear();
};

const normalizeRelativePath = (value: string) => value.replace(/^[\\/]+/, "");
const getEntryKey = (entry: FileSearchEntry) => `${entry.rootId}:${entry.relativePath}`;

const getRelativePath = (rootPath: string, file: string) => {
	const normalizedRoot = rootPath.replaceAll("\\", "/").replace(/\/+$/, "");
	const normalizedFile = file.replaceAll("\\", "/");
	if (normalizedFile === normalizedRoot) return "";
	const prefix = `${normalizedRoot}/`;
	const caseInsensitive = /^[A-Za-z]:\//.test(normalizedRoot);
	const comparableFile = caseInsensitive ? normalizedFile.toLocaleLowerCase() : normalizedFile;
	const comparablePrefix = caseInsensitive ? prefix.toLocaleLowerCase() : prefix;
	if (!comparableFile.startsWith(comparablePrefix)) return null;
	return normalizeRelativePath(normalizedFile.slice(prefix.length));
};

const joinRootPath = (rootPath: string, relativePath: string) => {
	const separator = rootPath.includes("\\") && !rootPath.includes("/") ? "\\" : "/";
	return `${rootPath.replace(/[\\/]+$/, "")}${separator}${relativePath.replaceAll("/", separator).replaceAll("\\", separator)}`;
};

const getTitle = (relativePath: string) => {
	const slash = Math.max(relativePath.lastIndexOf("/"), relativePath.lastIndexOf("\\"));
	return slash >= 0 ? relativePath.slice(slash + 1) : relativePath;
};

const resolveEntry = (file: string, roots = snapshot?.roots): FileSearchEntry | null => {
	if (roots === undefined) return null;
	const candidates = [...roots].sort((a, b) => b.absolutePath.length - a.absolutePath.length);
	for (const root of candidates) {
		const relativePath = getRelativePath(root.absolutePath, file);
		if (relativePath === null || relativePath === "") continue;
		return {
			rootId: root.id,
			relativePath,
		};
	}
	return null;
};

const getRoot = (rootId: number): FileSearchRoot | null => (
	snapshot?.roots.find(root => root.id === rootId) ?? null
);

const toFilterOption = (entry: FileSearchEntry): FilterOption | null => {
	const root = getRoot(entry.rootId);
	if (root === null) return null;
	const relativePath = normalizeRelativePath(entry.relativePath);
	return {
		title: getTitle(relativePath),
		fileKey: joinRootPath(root.absolutePath, relativePath),
		path: `${root.label}/${relativePath.replaceAll("\\", "/")}`,
		rootKind: root.kind,
	};
};

const ensureFallbackIndex = () => {
	if (fallbackIndex !== null || snapshot === null) return fallbackIndex;
	fallbackIndex = new FileSearchIndexCore();
	fallbackIndex.initialize(snapshot.entries);
	return fallbackIndex;
};

const ensureWorker = () => {
	if (worker !== null || workerUnavailable || typeof Worker === "undefined") return worker;
	worker = new Worker(new URL("./FileSearchWorker.ts", import.meta.url), { type: "module" });
	worker.onmessage = (event: MessageEvent<FileSearchWorkerResponse>) => {
		const message = event.data;
		if (message.generation !== generation) {
			updateDiagnostics({ doraPerfSearchIgnoredGeneration: message.generation });
			return;
		}
		if (message.type === "ready") {
			updateDiagnostics({ doraPerfSearchReady: true });
			resolveReady?.();
			resolveReady = null;
			return;
		}
		const resolve = pendingQueries.get(message.requestId);
		if (!resolve) return;
		pendingQueries.delete(message.requestId);
		updateDiagnostics({
			doraPerfSearchResultCount: message.entries.length,
			doraPerfSearchResultRequest: message.requestId,
		});
		resolve(message.entries);
	};
	worker.onerror = () => {
		worker?.terminate();
		worker = null;
		workerUnavailable = true;
		updateDiagnostics({ doraPerfSearchWorkerError: true });
		resolveReady?.();
		resolveReady = null;
		resolvePendingQueries();
	};
	return worker;
};

export const initializeFileSearchIndex = (nextSnapshot: FileSearchSnapshot) => {
	if (snapshot?.key === nextSnapshot.key) return readyPromise;
	snapshot = nextSnapshot;
	fallbackIndex = null;
	resolveReady?.();
	resolveReady = null;
	resolvePendingQueries();
	const currentWorker = ensureWorker();
	if (currentWorker === null) {
		readyPromise = Promise.resolve();
		return readyPromise;
	}
	generation += 1;
	updateDiagnostics({
		doraPerfSearchGeneration: generation,
		doraPerfSearchIndexedOptions: nextSnapshot.entries.length,
		doraPerfSearchReady: false,
	});
	readyPromise = new Promise<void>(resolve => {
		resolveReady = resolve;
	});
	currentWorker.postMessage({
		type: "initialize",
		generation,
		entries: nextSnapshot.entries,
	} satisfies FileSearchWorkerRequest);
	return readyPromise;
};

export const invalidateFileSearchIndex = () => {
	generation += 1;
	snapshot = null;
	fallbackIndex = null;
	resolveReady?.();
	resolveReady = null;
	resolvePendingQueries();
	readyPromise = Promise.resolve();
	worker?.terminate();
	worker = null;
	updateDiagnostics({
		doraPerfSearchGeneration: generation,
		doraPerfSearchIndexedOptions: 0,
		doraPerfSearchReady: false,
	});
};

export const hasFileSearchIndex = (key: string) => snapshot?.key === key;

export const getFileSearchIndexSize = () => snapshot?.entries.length ?? 0;

export const searchFileIndex = async (query: string, limit = 100) => {
	const input = query.trim();
	if (input === "" || snapshot === null) return [];
	await readyPromise;
	const currentWorker = ensureWorker();
	let entries: FileSearchEntry[];
	if (currentWorker === null) {
		entries = ensureFallbackIndex()?.search(input, limit) ?? [];
	} else {
		const currentRequestId = ++requestId;
		updateDiagnostics({
			doraPerfSearchQueryGeneration: generation,
			doraPerfSearchQueryRequest: currentRequestId,
		});
		entries = await new Promise<FileSearchEntry[]>(resolve => {
			resolvePendingQueries();
			pendingQueries.set(currentRequestId, resolve);
			currentWorker.postMessage({
				type: "query",
				generation,
				requestId: currentRequestId,
				query: input,
				limit,
			} satisfies FileSearchWorkerRequest);
		});
	}
	return entries.flatMap(entry => {
		const option = toFilterOption(entry);
		return option === null ? [] : [option];
	});
};

export const updateFileSearchIndex = (file: string, exists: boolean) => {
	if (snapshot === null) return;
	const entry = resolveEntry(file);
	if (entry === null) return;
	const currentWorker = ensureWorker();
	if (currentWorker === null) {
		ensureFallbackIndex()?.update(entry, exists);
	} else {
		currentWorker.postMessage({
			type: "update",
			generation,
			entry,
			exists,
		} satisfies FileSearchWorkerRequest);
	}
	const entryKey = getEntryKey(entry);
	const prefixForward = `${entry.relativePath}/`;
	const prefixBackward = `${entry.relativePath}\\`;
	const nextEntries = exists
		? snapshot.entries.some(item => getEntryKey(item) === entryKey)
			? snapshot.entries
			: [...snapshot.entries, entry]
		: snapshot.entries.filter(item => item.rootId !== entry.rootId || (
			item.relativePath !== entry.relativePath
			&& !item.relativePath.startsWith(prefixForward)
			&& !item.relativePath.startsWith(prefixBackward)
		));
	snapshot = {
		...snapshot,
		entries: nextEntries,
	};
};

export const moveFileSearchIndex = (oldPath: string, newPath: string) => {
	if (snapshot === null) return;
	const oldEntry = resolveEntry(oldPath);
	const newEntry = resolveEntry(newPath);
	if (oldEntry === null || newEntry === null) return;
	const currentWorker = ensureWorker();
	if (currentWorker === null) {
		ensureFallbackIndex()?.move(oldEntry, newEntry);
	} else {
		currentWorker.postMessage({
			type: "move",
			generation,
			oldEntry,
			newEntry,
		} satisfies FileSearchWorkerRequest);
	}
	const prefixForward = `${oldEntry.relativePath}/`;
	const prefixBackward = `${oldEntry.relativePath}\\`;
	const nextEntries = snapshot.entries.map(entry => {
		if (
			entry.rootId !== oldEntry.rootId
			|| (
				entry.relativePath !== oldEntry.relativePath
				&& !entry.relativePath.startsWith(prefixForward)
				&& !entry.relativePath.startsWith(prefixBackward)
			)
		) {
			return entry;
		}
		return {
			rootId: newEntry.rootId,
			relativePath: `${newEntry.relativePath}${entry.relativePath.slice(oldEntry.relativePath.length)}`,
		};
	});
	snapshot = {
		...snapshot,
		entries: nextEntries,
	};
};
