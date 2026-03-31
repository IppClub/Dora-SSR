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

export interface ToolCallFunction {
	name?: string;
	arguments?: string;
}

export interface ToolCall {
	id?: string;
	type?: string;
	function?: ToolCallFunction;
}

export interface Message {
	role: string;
	content?: string;
	name?: string;
	tool_call_id?: string;
	reasoning_content?: string;
	tool_calls?: ToolCall[];
}

const TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz";
let TOOL_CALL_ID_COUNTER = 0;

function toBase36(value: number): string {
	if (value <= 0) return "0";
	let remaining = math.floor(value);
	let out = "";
	while (remaining > 0) {
		const digit = remaining % 36;
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) + out;
		remaining = math.floor(remaining / 36);
	}
	return out;
}

export function createLocalToolCallId(): string {
	TOOL_CALL_ID_COUNTER += 1;
	const timePart = toBase36(os.time());
	const counterPart = toBase36(TOOL_CALL_ID_COUNTER);
	return `tc${timePart}${counterPart}`;
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

function utf8TakeHead(text: string, maxChars: number): string {
	if (maxChars <= 0 || text === "") return "";
	const nextPos = utf8.offset(text, maxChars + 1);
	if (nextPos === undefined) return text;
	return string.sub(text, 1, nextPos - 1);
}

function utf8TakeTail(text: string, maxChars: number): string {
	if (maxChars <= 0 || text === "") return "";
	const [charLen] = utf8.len(text);
	if (charLen === false || charLen <= maxChars) return text;
	const startChar = math.max(1, charLen - maxChars + 1);
	const startPos = utf8.offset(text, startChar);
	if (startPos === undefined) return text;
	return string.sub(text, startPos);
}

export function estimateTextTokens(text: string): number {
	if (!text) return 0;
	const [charLen] = utf8.len(text);
	if (charLen === false || charLen <= 0) return 0;
	const otherChars = text.length - charLen;
	const tokens = Math.ceil(charLen / 1.5 + otherChars / 4);
	return Math.max(1, tokens);
}

function estimateMessagesTokens(messages: Message[]): number {
	let total = 0;
	for (let i = 0; i < messages.length; i++) {
		const message = messages[i];
		total += 8;
		total += estimateTextTokens(message.role ?? "");
		total += estimateTextTokens(message.content ?? "");
		total += estimateTextTokens(message.name ?? "");
		total += estimateTextTokens(message.tool_call_id ?? "");
		total += estimateTextTokens(message.reasoning_content ?? "");
		const [toolCallsText] = json.encode((message.tool_calls ?? []) as object);
		total += estimateTextTokens(toolCallsText ?? "");
	}
	return total;
}

function estimateOptionsTokens(options: Record<string, any>): number {
	const [text] = json.encode(options as object);
	return text ? estimateTextTokens(text) : 0;
}

function getReservedOutputTokens(options: Record<string, any>, contextWindow: number): number {
	const explicitMax = type(options.max_tokens) === "number"
		? math.floor(options.max_tokens as number)
		: (type(options.max_completion_tokens) === "number"
			? math.floor(options.max_completion_tokens as number)
			: 0);
	if (explicitMax > 0) return math.max(256, explicitMax);
	return math.max(1024, math.floor(contextWindow * 0.2));
}

function getInputTokenBudget(messages: Message[], options: Record<string, any>, config: LLMConfig): number {
	const contextWindow = math.max(4000, config.contextWindow);
	const reservedOutputTokens = getReservedOutputTokens(options, contextWindow);
	const optionTokens = estimateOptionsTokens(options);
	const structuralOverhead = math.max(256, messages.length * 16);
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead);
}

export function clipTextToTokenBudget(text: string, budgetTokens: number): string {
	if (budgetTokens <= 0 || text === "") return "";
	const estimated = estimateTextTokens(text);
	if (estimated <= budgetTokens) return text;
	const charsPerToken = estimated > 0 ? text.length / estimated : 4;
	const targetChars = math.max(200, math.floor(budgetTokens * charsPerToken));
	const keepHead = math.max(0, math.floor(targetChars * 0.35));
	const keepTail = math.max(0, targetChars - keepHead);
	const head = keepHead > 0 ? utf8TakeHead(text, keepHead) : "";
	const tail = keepTail > 0 ? utf8TakeTail(text, keepTail) : "";
	return `${head}\n...\n${tail}`;
}

export function fitMessagesToContext(messages: Message[], options: Record<string, any>, config: LLMConfig): {
	messages: Message[];
	trimmed: boolean;
	originalTokens: number;
	fittedTokens: number;
	budgetTokens: number;
} {
	const cloned = messages.map(message => ({ ...message }));
	const budgetTokens = getInputTokenBudget(cloned, options, config);
	const originalTokens = estimateMessagesTokens(cloned);
	if (originalTokens <= budgetTokens) {
		return {
			messages: cloned,
			trimmed: false,
			originalTokens,
			fittedTokens: originalTokens,
			budgetTokens,
		};
	}

	const roleOverhead = (message: Message) => estimateTextTokens(message.role ?? "") + 8;
	let fixedOverhead = 0;
	const contentIndexes: number[] = [];
	for (let i = 0; i < cloned.length; i++) {
		fixedOverhead += roleOverhead(cloned[i]);
		contentIndexes.push(i);
	}
	const contentBudget = math.max(64, budgetTokens - fixedOverhead);
	if (contentIndexes.length === 1) {
		const idx = contentIndexes[0];
		cloned[idx].content = clipTextToTokenBudget(cloned[idx].content ?? "", contentBudget);
		const fittedTokens = estimateMessagesTokens(cloned);
		return {
			messages: cloned,
			trimmed: true,
			originalTokens,
			fittedTokens,
			budgetTokens,
		};
	}

	const nonSystemIndexes: number[] = [];
	const systemIndexes: number[] = [];
	for (let i = 0; i < cloned.length; i++) {
		if (cloned[i].role === "system") systemIndexes.push(i);
		else nonSystemIndexes.push(i);
	}
	const priorityIndexes = [...nonSystemIndexes, ...systemIndexes];
	let remainingContentBudget = contentBudget;
	for (let i = priorityIndexes.length - 1; i >= 0; i--) {
		const idx = priorityIndexes[i];
		const message = cloned[idx];
		const minBudget = message.role === "system" ? 96 : 192;
		const target = math.max(minBudget, math.floor(remainingContentBudget / math.max(1, i + 1)));
		message.content = clipTextToTokenBudget(message.content ?? "", target);
		remainingContentBudget -= estimateTextTokens(message.content ?? "");
		remainingContentBudget = math.max(0, remainingContentBudget);
	}

	let fittedTokens = estimateMessagesTokens(cloned);
	if (fittedTokens > budgetTokens) {
		for (let i = 0; i < priorityIndexes.length && fittedTokens > budgetTokens; i++) {
			const idx = priorityIndexes[i];
			const message = cloned[idx];
			const currentTokens = estimateTextTokens(message.content ?? "");
			const excess = fittedTokens - budgetTokens;
			const nextBudget = math.max(message.role === "system" ? 48 : 96, currentTokens - excess - 16);
			message.content = clipTextToTokenBudget(message.content ?? "", nextBudget);
			fittedTokens = estimateMessagesTokens(cloned);
		}
	}
	if (fittedTokens > budgetTokens) {
		for (let i = 0; i < priorityIndexes.length && fittedTokens > budgetTokens; i++) {
			const idx = priorityIndexes[i];
			if (cloned[idx].role === "system") continue;
			cloned[idx].content = clipTextToTokenBudget(cloned[idx].content ?? "", 48);
			fittedTokens = estimateMessagesTokens(cloned);
		}
	}
	return {
		messages: cloned,
		trimmed: true,
		originalTokens,
		fittedTokens,
		budgetTokens,
	};
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
	error?: {
		message?: string;
		type?: string;
		code?: string | number;
	};
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

export type LLMConfig = {
	url: string;
	model: string;
	apiKey: string;
	contextWindow: number;
	supportsFunctionCalling: boolean;
};

function normalizeContextWindow(value: unknown): number {
	if (type(value) === "number") {
		return math.max(4000, math.floor(value as number));
	}
	return 64000;
}

function normalizeSupportsFunctionCalling(value: unknown): boolean {
	return value === undefined || value === null || value !== 0;
}

export function getActiveLLMConfig(): { success: true; config: LLMConfig } | { success: false; message: string } {
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
			apiKey: api_key,
			contextWindow: normalizeContextWindow(config["context_window"]),
			supportsFunctionCalling: normalizeSupportsFunctionCalling(config["supports_function_calling"]),
		},
	};
}

export const callLLMStream = (
	messages: Message[],
	options: Record<string, any>,
	event: CallEvent | CallStream,
	llmConfig?: LLMConfig
): { success: true } | { success: false, message: string } => {
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
	const config = llmConfig ?? (() => {
		const configRes = getActiveLLMConfig();
		if (!configRes.success) {
			if (onCancel) onCancel(configRes.message);
			return undefined;
		}
		return configRes.config;
	})();
	if (!config) {
		return { success: false, message: "no active LLM config" };
	}
	const { url, model, apiKey } = config;
	const fitted = fitMessagesToContext(messages, options, config);
	if (fitted.trimmed) {
		Log("Warn", `[Agent.Utils] callLLMStream trimmed input tokens=${fitted.originalTokens} budget=${fitted.budgetTokens} fitted=${fitted.fittedTokens}`);
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
			const result = await postLLM(fitted.messages, url, apiKey, model, options, true, (data) => {
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
	stopTokenOrConfig?: StopToken | LLMConfig,
	llmConfig?: LLMConfig
): Promise<{ success: true; response: LLMResponseData } | { success: false; message: string; raw?: string }> {
	const stopToken = stopTokenOrConfig && "stopped" in stopTokenOrConfig ? stopTokenOrConfig : undefined;
	const config = stopTokenOrConfig && "url" in stopTokenOrConfig
		? stopTokenOrConfig
		: llmConfig;
	const resolvedConfig = config ?? (() => {
		const configRes = getActiveLLMConfig();
		if (!configRes.success) {
			Log("Error", `[Agent.Utils] callLLMOnce config error: ${configRes.message}`);
			return undefined;
		}
		return configRes.config;
	})();
	if (!resolvedConfig) {
		return { success: false, message: "no active LLM config" };
	}
	const { url, model, apiKey } = resolvedConfig;
	const fitted = fitMessagesToContext(messages, options, resolvedConfig);
	Log("Info", `[Agent.Utils] callLLMOnce request model=${model} url=${url} messages=${messages.length}${fitted.trimmed ? ` trimmed_tokens=${fitted.originalTokens}->${fitted.fittedTokens}/${fitted.budgetTokens}` : ""}`);
	if (stopToken?.stopped) {
		const reason = stopToken.reason ?? "request cancelled";
		Log("Info", `[Agent.Utils] callLLMOnce cancelled before request: ${reason}`);
		return { success: false, message: reason };
	}
	try {
		const raw = await postLLM(fitted.messages, url, apiKey, model, options, false, undefined, stopToken);
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
		if (!responseObj.choices || responseObj.choices.length === 0) {
			const providerError = responseObj.error;
			const providerMessage = providerError && type(providerError.message) === "string"
				? providerError.message as string
				: "";
			const providerType = providerError && type(providerError.type) === "string"
				? providerError.type as string
				: "";
			const providerCode = providerError && (type(providerError.code) === "string" || type(providerError.code) === "number")
				? tostring(providerError.code)
				: "";
			const details = [providerType, providerCode].filter(part => part !== "").join("/");
			const rawPreview = previewText(raw, 400);
			const message = providerMessage !== ""
				? `LLM returned no choices: ${providerMessage}${details !== "" ? ` (${details})` : ""}`
				: `LLM returned no choices; raw=${rawPreview}`;
			Log("Error", `[Agent.Utils] callLLMOnce empty choices raw_preview=${rawPreview}`);
			return {
				success: false,
				message,
				raw,
			};
		}
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
