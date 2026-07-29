/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { matchSorter } from "match-sorter";
import type { FileSearchEntry } from "./FileSearchProtocol";

interface IndexedFileSearchEntry extends FileSearchEntry {
	title: string;
	normalizedTitle: string;
}

const getTitle = (relativePath: string) => {
	const slash = relativePath.lastIndexOf("/");
	return slash >= 0 ? relativePath.slice(slash + 1) : relativePath;
};

const getEntryKey = (entry: FileSearchEntry) => `${entry.rootId}:${entry.relativePath}`;

export class FileSearchIndexCore {
	private entries: IndexedFileSearchEntry[] = [];
	private entriesByKey = new Map<string, IndexedFileSearchEntry>();

	initialize(entries: FileSearchEntry[]) {
		this.entries = entries.map(entry => {
			const title = getTitle(entry.relativePath);
			return {
				...entry,
				title,
				normalizedTitle: title.toLocaleLowerCase(),
			};
		});
		this.entriesByKey = new Map(this.entries.map(entry => [getEntryKey(entry), entry]));
	}

	update(entry: FileSearchEntry, exists: boolean) {
		const key = getEntryKey(entry);
		if (exists) {
			const title = getTitle(entry.relativePath);
			const indexedEntry = {
				...entry,
				title,
				normalizedTitle: title.toLocaleLowerCase(),
			};
			const previous = this.entriesByKey.get(key);
			this.entriesByKey.set(key, indexedEntry);
			if (previous) {
				const index = this.entries.indexOf(previous);
				if (index >= 0) this.entries[index] = indexedEntry;
			} else {
				this.entries.push(indexedEntry);
			}
			return;
		}
		const prefix = `${entry.relativePath}/`;
		this.entries = this.entries.filter(item => {
			const removed = item.rootId === entry.rootId && (
				item.relativePath === entry.relativePath
				|| item.relativePath.startsWith(prefix)
			);
			if (removed) this.entriesByKey.delete(getEntryKey(item));
			return !removed;
		});
	}

	move(oldEntry: FileSearchEntry, newEntry: FileSearchEntry) {
		const prefix = `${oldEntry.relativePath}/`;
		let changed = false;
		this.entries = this.entries.map(entry => {
			if (
				entry.rootId !== oldEntry.rootId
				|| (
					entry.relativePath !== oldEntry.relativePath
					&& !entry.relativePath.startsWith(prefix)
				)
			) {
				return entry;
			}
			changed = true;
			const relativePath = `${newEntry.relativePath}${entry.relativePath.slice(oldEntry.relativePath.length)}`;
			const title = getTitle(relativePath);
			return {
				rootId: newEntry.rootId,
				relativePath,
				title,
				normalizedTitle: title.toLocaleLowerCase(),
			};
		});
		if (changed) {
			this.entriesByKey = new Map(this.entries.map(entry => [getEntryKey(entry), entry]));
		}
	}

	search(query: string, limit = 100) {
		const input = query.trim().toLocaleLowerCase();
		if (input === "") return [];
		const prefixMatches: IndexedFileSearchEntry[] = [];
		const substringMatches: IndexedFileSearchEntry[] = [];
		for (const entry of this.entries) {
			if (entry.normalizedTitle.startsWith(input)) {
				if (prefixMatches.length < limit) prefixMatches.push(entry);
			} else if (entry.normalizedTitle.includes(input)) {
				if (substringMatches.length < limit) substringMatches.push(entry);
			}
		}
		const directMatches = [...prefixMatches, ...substringMatches].slice(0, limit);
		if (directMatches.length > 0) {
			return directMatches.map(({ rootId, relativePath }) => ({ rootId, relativePath }));
		}
		const fuzzyMatches = matchSorter(this.entries, input, { keys: ["title"] });
		for (const entry of fuzzyMatches) {
			directMatches.push(entry);
			if (directMatches.length >= limit) break;
		}
		return directMatches.map(({ rootId, relativePath }) => ({ rootId, relativePath }));
	}

	size() {
		return this.entries.length;
	}
}
