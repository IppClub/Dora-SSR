/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

export interface LogBufferOptions {
	maxLines?: number;
	maxBytes?: number;
};

interface LogChunk {
	text: string;
	lines: number;
	bytes: number;
};

const countNewLines = (text: string) => {
	let count = 0;
	for (let index = 0; index < text.length; index += 1) {
		if (text.charCodeAt(index) === 10) count += 1;
	}
	return count;
};

export class LogBuffer {
	private static readonly targetChunkCharacters = 16 * 1024;
	private readonly maxLines: number;
	private readonly maxBytes: number;
	private chunks: LogChunk[] = [];
	private totalLines = 0;
	private totalBytes = 0;
	private cachedText = "";
	private cacheValid = true;
	private truncated = false;

	constructor(options: LogBufferOptions = {}) {
		this.maxLines = options.maxLines ?? 10_000;
		this.maxBytes = options.maxBytes ?? 4 * 1024 * 1024;
	}

	append(text: string) {
		if (text === "") return;
		const chunk = {
			text,
			lines: countNewLines(text),
			// JavaScript strings are stored as UTF-16 in memory. This conservative
			// estimate keeps the in-browser buffer within the configured budget.
			bytes: text.length * 2,
		};
		const last = this.chunks[this.chunks.length - 1];
		if (last && last.text.length + text.length <= LogBuffer.targetChunkCharacters) {
			last.text += text;
			last.lines += chunk.lines;
			last.bytes += chunk.bytes;
		} else {
			this.chunks.push(chunk);
		}
		this.totalLines += chunk.lines;
		this.totalBytes += chunk.bytes;
		this.cacheValid = false;
		this.enforceLimits();
	}

	clear() {
		this.chunks = [];
		this.totalLines = 0;
		this.totalBytes = 0;
		this.cachedText = "";
		this.cacheValid = true;
		this.truncated = false;
	}

	getText() {
		if (!this.cacheValid) {
			this.cachedText = this.chunks.map((chunk) => chunk.text).join("");
			this.cacheValid = true;
		}
		return this.cachedText;
	}

	isTruncated() {
		return this.truncated;
	}

	getStats() {
		return {
			bytes: this.totalBytes,
			lines: this.totalLines,
			chunks: this.chunks.length,
			truncated: this.truncated,
		};
	}

	private enforceLimits() {
		while (
			this.chunks.length > 1
			&& (this.totalLines > this.maxLines || this.totalBytes > this.maxBytes)
		) {
			const removed = this.chunks.shift();
			if (!removed) break;
			this.totalLines -= removed.lines;
			this.totalBytes -= removed.bytes;
			this.truncated = true;
		}

		const first = this.chunks[0];
		if (!first || (this.totalLines <= this.maxLines && this.totalBytes <= this.maxBytes)) return;

		let cutIndex = Math.max(0, first.text.length - Math.floor(this.maxBytes / 2));
		const linesToRemove = Math.max(0, first.lines - this.maxLines);
		if (linesToRemove > 0) {
			let remaining = linesToRemove;
			let lineCutIndex = 0;
			while (remaining > 0) {
				const next = first.text.indexOf("\n", lineCutIndex);
				if (next < 0) {
					lineCutIndex = first.text.length;
					break;
				}
				lineCutIndex = next + 1;
				remaining -= 1;
			}
			cutIndex = Math.max(cutIndex, lineCutIndex);
		}
		if (cutIndex > 0) {
			first.text = first.text.slice(cutIndex);
			first.lines = countNewLines(first.text);
			first.bytes = first.text.length * 2;
			this.totalLines = first.lines;
			this.totalBytes = first.bytes;
			this.truncated = true;
			this.cacheValid = false;
		}
	}
}
