/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { FileSearchIndexCore } from "./FileSearchIndexCore";
import type { FileSearchWorkerRequest, FileSearchWorkerResponse } from "./FileSearchProtocol";

const index = new FileSearchIndexCore();
let generation = 0;

self.onmessage = (event: MessageEvent<FileSearchWorkerRequest>) => {
	const message = event.data;
	switch (message.type) {
		case "initialize": {
			generation = message.generation;
			index.initialize(message.entries);
			self.postMessage({
				type: "ready",
				generation,
			} satisfies FileSearchWorkerResponse);
			break;
		}
		case "query": {
			if (message.generation !== generation) return;
			const entries = index.search(message.query, message.limit);
			self.postMessage({
				type: "result",
				generation,
				requestId: message.requestId,
				entries,
			} satisfies FileSearchWorkerResponse);
			break;
		}
		case "update": {
			if (message.generation !== generation) return;
			index.update(message.entry, message.exists);
			break;
		}
		case "move": {
			if (message.generation !== generation) return;
			index.move(message.oldEntry, message.newEntry);
			break;
		}
	}
};
