// @preview-file off clear
import { json, Director, once, HttpClient, DB, emit } from 'Dora';

export interface Message {
	role: string;
	content: string;
}

const postLLM = (messages: Message[], url: string, apiKey: string, model: string, options: Record<string, any>, receiver: (this: void, data: string) => boolean) => {
	const data: Record<string, any> = {
		...options,
		model,
		messages,
		stream: true,
	};
	return new Promise<string>((resolve, reject) => {
		Director.systemScheduler.schedule(once(() => {
			const [jsonStr, err] = json.encode(data);
			if (jsonStr !== undefined) {
				const res = HttpClient.postAsync(url, [
					`Authorization: Bearer ${apiKey}`,
				], jsonStr, 10, receiver);
				if (res) {
					resolve(res);
				} else {
					reject("failed to get http response");
				}
			} else {
				reject(err);
			}
		}));
	});
};

type OnJSON = (this: void, obj: any, raw: string) => void;
type OnDone = (this: void, text: string) => void;
type OnError = (this: void, err: unknown, context?: { raw?: string }) => void;

export function createSSEJSONParser(opts: {
	onJSON: OnJSON;
	onDone?: OnDone;
	onError?: OnError;
}) {
	let buffer = "";
	let eventDataLines: string[] = [];

	function flushEventIfAny() {
		if (eventDataLines.length === 0) return;

		const dataPayload = eventDataLines.join("\n");
		eventDataLines = [];

		if (dataPayload === "[DONE]") {
			opts.onDone?.(dataPayload);
			return;
		}

		const [obj, err] = json.decode(dataPayload);
		if (err === null) {
			opts.onJSON(obj, dataPayload);
		} else {
			opts.onError?.(err, { raw: dataPayload });
		}
	}

	function feed(chunk: string) {
		buffer += chunk;

		while (true) {
			const nl = buffer.indexOf("\n");
			if (nl < 0) break;

			let line = buffer.slice(0, nl);
			buffer = buffer.slice(nl + 1);

			if (line.endsWith("\r")) line = line.slice(0, -1);

			if (line === "") {
				flushEventIfAny();
				continue;
			}

			// skip comments
			if (line.startsWith(":")) continue;

			if (line.startsWith("data:")) {
				let v = line.slice(5);
				if (v.startsWith(" ")) v = v.slice(1);
				eventDataLines.push(v);
				continue;
			}
		}
	}

	function end() {
		if (buffer.length > 0) {
			let line = buffer;
			buffer = "";
			if (line.endsWith("\r")) line = line.slice(0, -1);

			if (line.startsWith("data:")) {
				let v = line.slice(5);
				if (v.startsWith(" ")) v = v.slice(1);
				eventDataLines.push(v);
			}
		}
		flushEventIfAny();
	}

	return { feed, end };
}

export interface LLMStreamData {
	id: string;
	created: number;
	object: string;
	model: string;
	choices: Choice[];
}

interface Choice {
	index: number;
	delta: Delta;
}

interface Delta {
	role: string;
	reasoning_content?: string;
	content?: string;
}

interface CallEvent {
	id: undefined;
	onData: (this: void, data: LLMStreamData) => boolean;
	onCancel?: (this: void, reason: string) => void;
	onDone?: (this: void, content: string) => void;
}

interface CallStream {
	id: number;
	stopToken: boolean;
}

export const callLLM = (messages: Message[], options: Record<string, any>, event: CallEvent | CallStream): {success: true} | {success: false, message: string} => {
	let callEvent: CallEvent;
	if (event.id !== undefined) {
		const id = event.id;
		callEvent = {
			id: undefined,
			onData: (data) => {
				emit("AppWS", "Send", {name: "LLMContent", id, data});
				return event.stopToken;
			},
			onCancel: (reason) => {
				emit("AppWS", "Send", {name: "LLMCancel", id, reason});
			},
			onDone: () => {
				emit("AppWS", "Send", {name: "LLMDone", id});
			}
		};
	} else {
		callEvent = event;
	}
	const {onData, onDone} = callEvent;
	let {onCancel} = callEvent;
	const rows = DB.query("select * from LLMConfig", true);
	const records: Record<string, any>[] = [];
	if (rows && rows.length > 1) {
		for (let i = 1; i < rows.length; i++) {
			const record: Record<string, any> = {};
			for (let c = 0; c < rows[i].length; c++) {
				record[rows[0][c] as string] = rows[i][c];
			}
			records.push(record);
		}
	}
	const config = records.find(r => r["active"] !== 0);
	if (!config) return {success: false, message: "no active LLM config"};
	const {url, model, api_key} = config;
	if ("string" !== typeof url || "string" !== typeof model || "string" !== typeof api_key) {
		return {success: false, message: "got invalude LLM config"};
	}
	let stopLLM = false;
	const parser = createSSEJSONParser({
		onJSON: (obj) => {
			const result = onData(obj);
			if (result) stopLLM = result;
		}
	});
	(async () => {
		try {
			const result = await postLLM(messages, url, api_key, model, options, (data) => {
				if (stopLLM) {
					if (onCancel) {
						onCancel("LLM Stopped");
						onCancel = undefined;
					}
					return true;
				}
				parser.feed(data);
				return false;
			});
			parser.end();
			if (onDone) {
				onDone(result);
			}
		} catch (e) {
			stopLLM = true;
			if (onCancel) {
				onCancel(tostring(e));
				onCancel = undefined;
			}
		}
	})();
	return {success: true};
}
