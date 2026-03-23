// @preview-file off clear
import { json, HttpClient, DB, emit, Log as DoraLog, Director, once } from 'Dora';

let LOG_LEVEL = 2;
export function setLogLevel(level: number) {
	LOG_LEVEL = level;
}

let LLM_TIMEOUT = 600;
export function setLLMTimeout(timeout: number) {
	LLM_TIMEOUT = timeout;
}

export const Log = (type: "Info" | "Warn" | "Error", msg: string) => {
	if (LOG_LEVEL < 1) return;
	else if (LOG_LEVEL < 2 && (type === "Info" || type === "Warn")) return;
	else if (LOG_LEVEL < 3 && type === "Info") return;
	DoraLog(type, msg);
};

export interface Message {
	role: string;
	content: string;
}

export interface StopToken {
	stopped: boolean;
	reason?: string;
}

function previewText(text: string, maxLen = 200): string {
	if (!text) return "";
	const compact = text.replace("\r", "\\r").replace("\n", "\\n");
	if (compact.length <= maxLen) return compact;
	return `${compact.slice(0, maxLen)}...`;
}

const postLLM = (
	messages: Message[],
	url: string,
	apiKey: string,
	model: string,
	options: Record<string, any>,
	stream: boolean,
	receiver?: (this: void, data: string) => boolean,
	stopToken?: StopToken
) => {
	const data: Record<string, any> = {
		...options,
		model,
		messages,
		stream,
	};
	stopToken ??= { stopped: false };
	return new Promise<string>((resolve, reject) => {
		let requestId = 0;
		let settled = false;
		const finishResolve = (text: string) => {
			if (settled) return;
			settled = true;
			resolve(text);
		};
		const finishReject = (err: unknown) => {
			if (settled) return;
			settled = true;
			reject(err);
		};
		Director.systemScheduler.schedule(() => {
			if (!settled) {
				if (stopToken.stopped) {
					if (requestId !== 0) {
						HttpClient.cancel(requestId);
						requestId = 0;
					}
					finishReject("request cancelled");
					return true;
				}
				return false;
			}
			return true;
		});
		Director.systemScheduler.schedule(once(() => {
			emit("LLM_IN", messages.map((m, i) => i.toString() + ": " + m.content).join('\n'));
			const [jsonStr, err] = json.encode(data);
			if (jsonStr !== undefined) {
				const headers = [
					`Authorization: Bearer ${apiKey}`,
					"Content-Type: application/json",
					"Accept: application/json",
				];
				requestId = receiver
					? HttpClient.post(url, headers, jsonStr, LLM_TIMEOUT, (data) => {
						if (stopToken.stopped) return true;
						return receiver(data);
					}, (data) => {
						requestId = 0;
						if (data !== undefined) {
							finishResolve(data);
						} else {
							finishReject("failed to get http response");
						}
					})
					: HttpClient.post(url, headers, jsonStr, LLM_TIMEOUT, (data) => {
						requestId = 0;
						if (stopToken.stopped) {
							finishReject("request cancelled");
							return;
						}
						if (data !== undefined) {
							finishResolve(data);
						} else {
							finishReject("failed to get http response");
						}
					});
				if (requestId === 0) {
					finishReject("failed to schedule http request");
				} else if (stopToken.stopped) {
					HttpClient.cancel(requestId);
					requestId = 0;
					finishReject("request cancelled");
				}
			} else {
				finishReject(err);
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
		if (err === undefined) {
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

export interface ToolCallFunction {
	name?: string;
	arguments?: string;
}

interface ToolCall {
	id?: string;
	type?: string;
	function?: ToolCallFunction;
}

interface NonStreamMessage {
	role?: string;
	content?: string;
	reasoning_content?: string;
	tool_calls?: ToolCall[];
}

interface NonStreamChoice {
	index?: number;
	message?: NonStreamMessage;
	finish_reason?: string;
}

export interface LLMResponseData {
	id?: string;
	created?: number;
	object?: string;
	model?: string;
	choices?: NonStreamChoice[];
}

interface CallEvent {
	id: undefined;
	stopToken?: StopToken;
	onData: (this: void, data: LLMStreamData) => boolean;
	onCancel?: (this: void, reason: string) => void;
	onDone?: (this: void, content: string) => void;
}

interface CallStream {
	id: number;
	stopToken: StopToken;
}

type LLMConfig = {
	url: string;
	model: string;
	api_key: string;
};

function getActiveLLMConfig(): { success: true; config: LLMConfig } | { success: false; message: string } {
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
	if (!config) {
		return { success: false, message: "no active LLM config" };
	}
	const { url, model, api_key } = config;
	if ("string" !== typeof url || "string" !== typeof model || "string" !== typeof api_key) {
		return { success: false, message: "got invalude LLM config" };
	}
	return {
		success: true,
		config: {
			url,
			model,
			api_key,
		},
	};
}

export const callLLMStream = (messages: Message[], options: Record<string, any>, event: CallEvent | CallStream): { success: true } | { success: false, message: string } => {
	let callEvent: CallEvent;
	if (event.id !== undefined) {
		const id = event.id;
		callEvent = {
			id: undefined,
			onData: (data) => {
				emit("AppWS", "Send", { name: "LLMContent", id, data });
				return event.stopToken.stopped;
			},
			onCancel: (reason) => {
				emit("AppWS", "Send", { name: "LLMCancel", id, reason });
			},
			onDone: () => {
				emit("AppWS", "Send", { name: "LLMDone", id });
			}
		};
	} else {
		callEvent = event;
	}
	const { onData, onDone } = callEvent;
	let { onCancel } = callEvent;
	const configRes = getActiveLLMConfig();
	if (!configRes.success) {
		if (onCancel) onCancel(configRes.message);
		return { success: false, message: configRes.message };
	}
	const { url, model, api_key } = configRes.config;
	let stopLLM = false;
	const parser = createSSEJSONParser({
		onJSON: (obj) => {
			const result = onData(obj);
			if (result) stopLLM = result;
		}
	});
	(async () => {
		try {
			const result = await postLLM(messages, url, api_key, model, options, true, (data) => {
				if (stopLLM) {
					if (onCancel) {
						onCancel("LLM Stopped");
						onCancel = undefined;
					}
					return true;
				}
				parser.feed(data);
				return false;
			}, "stopToken" in event ? event.stopToken : undefined);
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
	return { success: true };
}

export async function callLLM(
	messages: Message[],
	options: Record<string, any>,
	stopToken?: StopToken
): Promise<{ success: true; response: LLMResponseData } | { success: false; message: string; raw?: string }> {
	const configRes = getActiveLLMConfig();
	if (!configRes.success) {
		Log("Error", `[Agent.Utils] callLLMOnce config error: ${configRes.message}`);
		return { success: false, message: configRes.message };
	}
	const { url, model, api_key } = configRes.config;
	Log("Info", `[Agent.Utils] callLLMOnce request model=${model} url=${url} messages=${messages.length}`);
	if (stopToken?.stopped) {
		const reason = stopToken.reason ?? "request cancelled";
		Log("Info", `[Agent.Utils] callLLMOnce cancelled before request: ${reason}`);
		return { success: false, message: reason };
	}
	try {
		const raw = await postLLM(messages, url, api_key, model, options, false, undefined, stopToken);
		Log("Info", `[Agent.Utils] callLLMOnce raw response length=${raw.length}`);
		const [response, err] = json.decode(raw);
		if (err !== undefined || response === undefined || type(response) !== "table") {
			const rawPreview = previewText(raw);
			Log("Error", `[Agent.Utils] callLLMOnce invalid JSON: ${tostring(err)} raw_preview=${rawPreview}`);
			return {
				success: false,
				message: `invalid LLM response JSON: ${tostring(err)}; raw=${rawPreview}`,
				raw,
			};
		}
		const responseObj = response as LLMResponseData;
		const choiceCount = responseObj.choices ? responseObj.choices.length : 0;
		Log("Info", `[Agent.Utils] callLLMOnce decoded response choices=${choiceCount}`);
		return {
			success: true,
			response: responseObj,
		};
	} catch (e) {
		if (stopToken?.stopped) {
			const reason = stopToken.reason ?? "request cancelled";
			Log("Info", `[Agent.Utils] callLLMOnce cancelled during request: ${reason}`);
			return { success: false, message: reason };
		}
		Log("Error", `[Agent.Utils] callLLMOnce exception: ${tostring(e)}`);
		return { success: false, message: tostring(e) };
	}
}
