// @preview-file off clear
import { json, HttpClient, DB, emit, Log as DoraLog, Director, once, App } from 'Dora';

let LOG_LEVEL = App.debugging ? 3 : 2;
export function setLogLevel(level: number) {
	LOG_LEVEL = level;
}

const LLM_TIMEOUT = 600;
const LLM_STREAM_TIMEOUT = 600;
const LLM_STREAM_RAW_DEBUG_MAX = 12000;
const LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT = 5;

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

export type SimpleXMLParseResult =
	| { success: true; obj: Record<string, unknown> }
	| { success: false; message: string };

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

export function sanitizeUTF8(text: string): string {
	if (!text) return "";
	let remaining = text;
	let output = "";
	while (remaining !== "") {
		const [len, invalidPos] = utf8.len(remaining);
		if (len !== undefined) {
			output += remaining;
			break;
		}
		const badPos = typeof invalidPos === "number" ? invalidPos : 1;
		if (badPos > 1) {
			output += remaining.substring(0, badPos - 1);
		}
		remaining = remaining.substring(badPos);
	}
	return output;
}

function sanitizeJSONValue(value: unknown): unknown {
	if (typeof value === "string") return sanitizeUTF8(value);
	if (Array.isArray(value)) {
		return value.map(item => sanitizeJSONValue(item));
	}
	if (value && type(value) === "table") {
		const result: Record<string, unknown> = {};
		for (const key in value as Record<string, unknown>) {
			result[key] = sanitizeJSONValue((value as Record<string, unknown>)[key]);
		}
		return result;
	}
	return value;
}

export function safeJsonEncode(value: unknown, indent?: boolean, sortKeys?: boolean, escapeSlash?: boolean, maxDepth?: number) {
	return json.encode(
		sanitizeJSONValue(value) as object,
		indent,
		sortKeys,
		escapeSlash,
		maxDepth,
	);
}

export function safeJsonDecode(text: string) {
	const [value, err] = json.decode(sanitizeUTF8(text));
	if (value === undefined) {
		return $multi(value, err);
	}
	return $multi(sanitizeJSONValue(value), err);
}

function normalizeLLMJSONResponse(text: string): string {
	return text.trim();
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
	if (charLen === undefined || charLen <= maxChars) return text;
	const startChar = math.max(1, charLen - maxChars + 1);
	const startPos = utf8.offset(text, startChar);
	if (startPos === undefined) return text;
	return string.sub(text, startPos);
}

export function estimateTextTokens(text: string): number {
	if (!text) return 0;
	const [charLen] = utf8.len(text);
	if (!charLen || charLen <= 0) return 0;
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
		const [toolCallsText] = safeJsonEncode((message.tool_calls ?? []) as object);
		total += estimateTextTokens(toolCallsText ?? "");
	}
	return total;
}

function estimateOptionsTokens(options: Record<string, any>): number {
	const [text] = safeJsonEncode(options as object);
	return text ? estimateTextTokens(text) : 0;
}

function getReservedOutputTokens(options: Record<string, any>, contextWindow: number): number {
	const explicitMax = typeof options.max_tokens === "number"
		? math.floor(options.max_tokens)
		: (typeof options.max_completion_tokens === "number"
			? math.floor(options.max_completion_tokens)
			: 0);
	if (explicitMax > 0) return math.max(256, explicitMax);
	return math.max(1024, math.floor(contextWindow * 0.2));
}

function getInputTokenBudget(messages: Message[], options: Record<string, any>, config: LLMConfig): number {
	const contextWindow = math.max(64000, config.contextWindow);
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

function isXMLWhitespaceChar(ch: string): boolean {
	return ch === " " || ch === "\t" || ch === "\n" || ch === "\r";
}

function findLineStart(value: string, from: number): number {
	let i = from;
	while (i >= 0) {
		if (value[i] === "\n") return i + 1;
		i -= 1;
	}
	return 0;
}

function findLastLiteral(text: string, needle: string): number {
	if (needle === "") return text.length;
	let last = -1;
	let from = 0;
	while (from <= text.length - needle.length) {
		const pos = text.indexOf(needle, from);
		if (pos < 0) break;
		last = pos;
		from = pos + 1;
	}
	return last;
}

function unwrapXMLRawText(text: string): string {
	const trimmed = text.trim();
	if (trimmed.startsWith("<![CDATA[") && trimmed.endsWith("]]>")) {
		return trimmed.slice(9, trimmed.length - 3);
	}
	return text;
}

function readSimpleXMLTagName(source: string, openStart: number, openEnd: number): { success: true; tagName: string; selfClosing: boolean } | { success: false; message: string } {
	const rawTag = source.slice(openStart + 1, openEnd).trim();
	if (rawTag === "") {
		return { success: false, message: `invalid xml: empty tag at offset ${tostring(openStart)}` };
	}
	let selfClosing = false;
	let tagText = rawTag;
	if (tagText.endsWith("/")) {
		selfClosing = true;
		tagText = tagText.slice(0, tagText.length - 1).trim();
	}
	let tagName = "";
	for (let i = 0; i < tagText.length; i++) {
		const ch = tagText[i];
		if (isXMLWhitespaceChar(ch) || ch === "/") break;
		tagName += ch;
	}
	if (tagName === "") {
		return { success: false, message: `invalid xml: unsupported tag syntax <${rawTag}>` };
	}
	return { success: true, tagName, selfClosing };
}

function findMatchingXMLClose(source: string, tagName: string, contentStart: number): { success: true; closeStart: number } | { success: false; message: string } {
	const sameOpenPrefix = `<${tagName}`;
	const sameCloseToken = `</${tagName}>`;
	let pos = contentStart;
	let depth = 1;
	while (pos < source.length) {
		const lt = source.indexOf("<", pos);
		if (lt < 0) break;
		if (source.startsWith("<![CDATA[", lt)) {
			const cdataEnd = source.indexOf("]]>", lt + 9);
			if (cdataEnd < 0) return { success: false, message: "invalid xml: unterminated CDATA" };
			pos = cdataEnd + 3;
			continue;
		}
		if (source.startsWith("<!--", lt)) {
			const commentEnd = source.indexOf("-->", lt + 4);
			if (commentEnd < 0) return { success: false, message: "invalid xml: unterminated comment" };
			pos = commentEnd + 3;
			continue;
		}
		if (source.startsWith(sameCloseToken, lt)) {
			depth -= 1;
			if (depth === 0) return { success: true, closeStart: lt };
			pos = lt + sameCloseToken.length;
			continue;
		}
		if (source.startsWith(sameOpenPrefix, lt)) {
			const openEnd = source.indexOf(">", lt);
			if (openEnd < 0) return { success: false, message: "invalid xml: unterminated opening tag" };
			const tagInfo = readSimpleXMLTagName(source, lt, openEnd);
			if (!tagInfo.success) return tagInfo;
			if (tagInfo.tagName === tagName && !tagInfo.selfClosing) {
				depth += 1;
			}
			pos = openEnd + 1;
			continue;
		}
		const genericEnd = source.indexOf(">", lt);
		if (genericEnd < 0) return { success: false, message: "invalid xml: unterminated nested tag" };
		pos = genericEnd + 1;
	}
	return { success: false, message: `invalid xml: missing closing tag </${tagName}>` };
}

export function extractXMLFromText(text: string): string {
	const source = text.trim();
	const extractFencedBlock = (fence: string): string | undefined => {
		if (!source.startsWith(fence)) return undefined;
		const firstLineEnd = source.indexOf("\n", 0);
		if (firstLineEnd < 0) return undefined;
		let searchPos = firstLineEnd + 1;
		const closingFencePositions: number[] = [];
		while (searchPos < source.length) {
			const end = source.indexOf("```", searchPos);
			if (end < 0) break;
			const lineStart = findLineStart(source, end - 1);
			const lineEnd = source.indexOf("\n", end);
			const actualLineEnd = lineEnd >= 0 ? lineEnd : source.length;
			if (source.slice(lineStart, actualLineEnd).trim() === "```") {
				closingFencePositions.push(end);
			}
			searchPos = end + 1;
		}
		for (let i = closingFencePositions.length - 1; i >= 0; i--) {
			const closingFencePos = closingFencePositions[i];
			const afterFence = source.slice(closingFencePos + 3).trim();
			if (afterFence !== "") continue;
			return source.slice(firstLineEnd + 1, closingFencePos).trim();
		}
		return undefined;
	};
	const xmlBlock = extractFencedBlock("```xml");
	if (xmlBlock !== undefined) return xmlBlock;
	const genericBlock = extractFencedBlock("```");
	if (genericBlock !== undefined) return genericBlock;
	return source;
}

export function parseSimpleXMLChildren(source: string): SimpleXMLParseResult {
	const result: Record<string, unknown> = {};
	let pos = 0;
	while (pos < source.length) {
		while (pos < source.length && isXMLWhitespaceChar(source[pos])) pos += 1;
		if (pos >= source.length) break;
		if (source[pos] !== "<") {
			return { success: false, message: `invalid xml: expected tag at offset ${tostring(pos)}` };
		}
		if (source.startsWith("</", pos)) {
			return { success: false, message: `invalid xml: unexpected closing tag at offset ${tostring(pos)}` };
		}
		const openEnd = source.indexOf(">", pos);
		if (openEnd < 0) {
			return { success: false, message: "invalid xml: unterminated opening tag" };
		}
		const tagInfo = readSimpleXMLTagName(source, pos, openEnd);
		if (!tagInfo.success) return tagInfo;
		if (tagInfo.selfClosing) {
			result[tagInfo.tagName] = "";
			pos = openEnd + 1;
			continue;
		}
		const closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1);
		if (!closeRes.success) return closeRes;
		const closeToken = `</${tagInfo.tagName}>`;
		result[tagInfo.tagName] = unwrapXMLRawText(source.slice(openEnd + 1, closeRes.closeStart));
		pos = closeRes.closeStart + closeToken.length;
	}
	return { success: true, obj: result };
}

export function parseXMLObjectFromText(text: string, rootTag: string): SimpleXMLParseResult {
	const xmlText = extractXMLFromText(text);
	const rootOpen = `<${rootTag}>`;
	const rootClose = `</${rootTag}>`;
	const start = xmlText.indexOf(rootOpen);
	const end = findLastLiteral(xmlText, rootClose);
	if (start < 0 || end < start) {
		return { success: false, message: `invalid xml: missing <${rootTag}> root` };
	}
	const beforeRoot = xmlText.slice(0, start).trim();
	const afterRoot = xmlText.slice(end + rootClose.length).trim();
	if (beforeRoot !== "" || afterRoot !== "") {
		return { success: false, message: "invalid xml: root must be the only top-level block" };
	}
	const rootContent = xmlText.slice(start + rootOpen.length, end);
	return parseSimpleXMLChildren(rootContent);
}

export function fitMessagesToContext(messages: Message[], options: Record<string, any>, config: LLMConfig): {
	messages: Message[];
	trimmed: boolean;
	originalTokens: number;
	fittedTokens: number;
	budgetTokens: number;
} {
	const modelName = config.model.toLowerCase();
	const shouldEchoReasoningContent = messages.some(message => typeof message.reasoning_content === "string")
		|| (normalizeReasoningEffort(config.reasoningEffort) ?? "") !== ""
		|| modelName.includes("reasoner")
		|| modelName.includes("thinking");
	const cloned = messages.map(message => {
		const clonedMessage = { ...message };
		if (
			shouldEchoReasoningContent
			&& clonedMessage.role === "assistant"
			&& typeof clonedMessage.reasoning_content !== "string"
		) {
			clonedMessage.reasoning_content = "";
		}
		return clonedMessage;
	});
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
	const requestTimeout = stream ? LLM_STREAM_TIMEOUT : LLM_TIMEOUT;
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
			const [jsonStr, err] = safeJsonEncode(data);
			if (jsonStr !== undefined) {
				const headers = [
					`Authorization: Bearer ${apiKey}`,
					"Content-Type: application/json",
					"Accept: application/json",
				];
				requestId = receiver
					? HttpClient.post(url, headers, jsonStr, requestTimeout, (data) => {
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
					: HttpClient.post(url, headers, jsonStr, requestTimeout, (data) => {
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

		const [obj, err] = safeJsonDecode(dataPayload);
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
	message?: NonStreamMessage;
	finish_reason?: string;
}

interface Delta {
	role?: string;
	reasoning_content?: string;
	content?: string;
	tool_calls?: StreamDeltaToolCall[];
}

interface StreamDeltaToolCallFunction {
	name?: string;
	arguments?: string;
}

interface StreamDeltaToolCall {
	index?: number;
	id?: string;
	type?: string;
	function?: StreamDeltaToolCallFunction;
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

type LLMProviderError = NonNullable<LLMResponseData["error"]>;

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

interface StreamChoiceAccumulator {
	index: number;
	message: NonStreamMessage;
	finish_reason?: string;
}

export type LLMConfig = {
	url: string;
	model: string;
	apiKey: string;
	contextWindow: number;
	temperature: number;
	maxTokens: number;
	reasoningEffort?: string;
	supportsFunctionCalling: boolean;
};

function normalizeContextWindow(value: unknown): number {
	if (typeof value === "number") {
		return math.max(64000, math.floor(value));
	}
	return 64000;
}

function normalizeSupportsFunctionCalling(value: unknown): boolean {
	return value === undefined || value === null || value !== 0;
}

function normalizeLLMTemperature(value: unknown): number {
	if (typeof value === "number") {
		return math.max(0, math.min(2, value));
	}
	return 0.1;
}

function normalizeLLMMaxTokens(value: unknown): number {
	if (typeof value === "number") {
		return math.max(1, math.floor(value));
	}
	return 8192;
}

function normalizeReasoningEffort(value: unknown): string | undefined {
	if (typeof value !== "string") return undefined;
	const normalized = sanitizeUTF8(value).trim();
	return normalized !== "" ? normalized : undefined;
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
			temperature: normalizeLLMTemperature(config["temperature"]),
			maxTokens: normalizeLLMMaxTokens(config["max_tokens"]),
			reasoningEffort: normalizeReasoningEffort(config["reasoning_effort"]),
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

function mergeStreamToolCall(target: ToolCall, delta: StreamDeltaToolCall) {
	if (typeof delta.id === "string" && delta.id !== "") {
		target.id = delta.id;
	}
	if (typeof delta.type === "string" && delta.type !== "") {
		target.type = delta.type;
	}
	if (delta.function) {
		target.function ??= {};
		if (typeof delta.function.name === "string" && delta.function.name !== "") {
			target.function.name = (target.function.name ?? "") + delta.function.name;
		}
		if (typeof delta.function.arguments === "string" && delta.function.arguments !== "") {
			target.function.arguments = (target.function.arguments ?? "") + delta.function.arguments;
		}
	}
}

function mergeStreamChoice(acc: StreamChoiceAccumulator, choice: Choice) {
	const delta = choice.delta ?? {};
	const fullMessage = choice.message ?? {};
	const message = acc.message;
	const role = typeof delta.role === "string" && delta.role !== ""
		? delta.role
		: (typeof fullMessage.role === "string" ? fullMessage.role : undefined);
	if (typeof role === "string" && role !== "") {
		message.role = role;
	}
	const content = typeof delta.content === "string" && delta.content !== ""
		? delta.content
		: (typeof fullMessage.content === "string" ? fullMessage.content : undefined);
	if (typeof content === "string" && content !== "") {
		message.content = (message.content ?? "") + content;
	}
	const reasoningContent = typeof delta.reasoning_content === "string" && delta.reasoning_content !== ""
		? delta.reasoning_content
		: (typeof fullMessage.reasoning_content === "string" ? fullMessage.reasoning_content : undefined);
	if (typeof reasoningContent === "string" && reasoningContent !== "") {
		message.reasoning_content = (message.reasoning_content ?? "") + reasoningContent;
	}
	const toolCalls = (delta.tool_calls && delta.tool_calls.length > 0)
		? delta.tool_calls
		: (fullMessage.tool_calls ?? []);
	if (toolCalls && toolCalls.length > 0) {
		message.tool_calls ??= [];
		for (let i = 0; i < toolCalls.length; i++) {
			const item: StreamDeltaToolCall = toolCalls[i] as StreamDeltaToolCall;
			const index = typeof item.index === "number" && item.index >= 0
				? math.floor(item.index)
				: i;
			message.tool_calls[index] ??= {};
			mergeStreamToolCall(message.tool_calls[index], item);
		}
	}
	if (typeof choice.finish_reason === "string" && choice.finish_reason !== "") {
		acc.finish_reason = choice.finish_reason;
	}
}

function buildStreamResponse(
	states: Record<number, StreamChoiceAccumulator>,
	model?: string,
	id?: string,
	created?: number,
	object?: string,
	providerError?: LLMProviderError
): LLMResponseData {
	const indexes = Object.keys(states)
		.map(key => Number(key))
		.filter(index => Number.isFinite(index))
		.sort((a, b) => a - b);
	return {
		id,
		created,
		object,
		model,
		choices: indexes.map(index => {
			const state = states[index];
			return {
				index,
				message: {
					role: state.message.role ?? "assistant",
					content: state.message.content,
					reasoning_content: state.message.reasoning_content,
					tool_calls: state.message.tool_calls,
				},
				finish_reason: state.finish_reason,
			};
		}),
		error: providerError,
	};
}

export async function callLLMStreamAggregated(
	messages: Message[],
	options: Record<string, any>,
	stopTokenOrConfig?: StopToken | LLMConfig,
	llmConfig?: LLMConfig,
	onChunk?: (response: LLMResponseData, chunk: LLMStreamData) => void
): Promise<{ success: true; response: LLMResponseData } | { success: false; message: string; raw?: string }> {
	const stopToken = stopTokenOrConfig && "stopped" in stopTokenOrConfig ? stopTokenOrConfig : undefined;
	const config = stopTokenOrConfig && "url" in stopTokenOrConfig
		? stopTokenOrConfig
		: llmConfig;
	const resolvedConfig = config ?? (() => {
		const configRes = getActiveLLMConfig();
		if (!configRes.success) {
			Log("Error", `[Agent.Utils] callLLMStreamAggregated config error: ${configRes.message}`);
			return undefined;
		}
		return configRes.config;
	})();
	if (!resolvedConfig) {
		return { success: false, message: "no active LLM config" };
	}
	const { url, model, apiKey } = resolvedConfig;
	const fitted = fitMessagesToContext(messages, options, resolvedConfig);
	const toolCount = Array.isArray(options.tools) ? options.tools.length : 0;
	const toolChoice = typeof options.tool_choice === "string"
		? options.tool_choice
		: (options.tool_choice !== undefined ? "object" : "unset");
	Log("Info", `[Agent.Utils] callLLMStreamAggregated request model=${model} url=${url} messages=${messages.length} tools=${toolCount} tool_choice=${toolChoice} max_tokens=${tostring(options.max_tokens ?? "unset")} temperature=${tostring(options.temperature ?? "unset")}${fitted.trimmed ? ` trimmed_tokens=${fitted.originalTokens}->${fitted.fittedTokens}/${fitted.budgetTokens}` : ""}`);
	if (stopToken?.stopped) {
		const reason = stopToken.reason ?? "request cancelled";
		Log("Info", `[Agent.Utils] callLLMStreamAggregated cancelled before request: ${reason}`);
		return { success: false, message: reason };
	}
	try {
		const states: Record<number, StreamChoiceAccumulator> = {};
		let responseId: string | undefined = undefined;
		let responseCreated: number | undefined = undefined;
		let responseObject: string | undefined = undefined;
		let providerError: LLMProviderError | undefined;
		let httpChunkCount = 0;
		let rawStreamBytes = 0;
		let rawStreamPreview = "";
		let sseJSONChunkCount = 0;
		let choiceJSONChunkCount = 0;
		let emptyChoicesChunkCount = 0;
		let missingChoicesChunkCount = 0;
		let parseErrorCount = 0;
		let doneChunkSeen = false;
		let lastJSONPreview = "";
		const parser = createSSEJSONParser({
			onJSON: (obj, raw) => {
				sseJSONChunkCount++;
				lastJSONPreview = previewText(raw, 500);
				if (!obj || type(obj) !== "table") {
					return;
				}
				const chunk = obj as LLMStreamData & LLMResponseData;
				if (chunk.error) {
					providerError = chunk.error;
					Log("Warn", `[Agent.Utils] callLLMStreamAggregated provider error chunk: ${previewText(raw, 300)}`);
					return;
				}
				responseId = typeof chunk.id === "string" ? chunk.id : responseId;
				responseCreated = typeof chunk.created === "number" ? chunk.created : responseCreated;
				responseObject = typeof chunk.object === "string" ? chunk.object : responseObject;
				const choices = Array.isArray(chunk.choices) ? chunk.choices : [];
				if (!Array.isArray(chunk.choices)) {
					missingChoicesChunkCount++;
					if (missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT) {
						Log("Warn", `[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=${previewText(raw, 300)}`);
					}
				} else if (choices.length === 0) {
					emptyChoicesChunkCount++;
					if (emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT) {
						Log("Warn", `[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=${previewText(raw, 300)}`);
					}
				} else {
					choiceJSONChunkCount++;
				}
				for (let i = 0; i < choices.length; i++) {
					const choice = choices[i] as Choice;
					const index = typeof choice.index === "number" ? choice.index : i;
					states[index] ??= {
						index,
						message: { role: "assistant" },
					};
					mergeStreamChoice(states[index], choice);
				}
				onChunk?.(
					buildStreamResponse(states, model, responseId, responseCreated, responseObject, providerError),
					{
						id: chunk.id ?? "",
						created: chunk.created ?? 0,
						object: chunk.object ?? "",
						model: chunk.model ?? model,
						choices,
					}
				);
			},
			onDone: () => {
				doneChunkSeen = true;
			},
			onError: (err, context) => {
				parseErrorCount++;
				Log("Warn", `[Agent.Utils] callLLMStreamAggregated parse error: ${tostring(err)} raw=${previewText(context?.raw ?? "", 300)}`);
			},
		});
		await postLLM(fitted.messages, url, apiKey, model, options, true, (data) => {
			if (stopToken?.stopped) return true;
			httpChunkCount++;
			rawStreamBytes += data.length;
			if (rawStreamPreview.length < LLM_STREAM_RAW_DEBUG_MAX) {
				rawStreamPreview += data.slice(0, LLM_STREAM_RAW_DEBUG_MAX - rawStreamPreview.length);
			}
			parser.feed(data);
			return false;
		}, stopToken);
		parser.end();
		if (sseJSONChunkCount === 0 && rawStreamPreview.trim() !== "") {
			const [rawResponse] = safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview));
			if (rawResponse && type(rawResponse) === "table") {
				const rawResponseObj = rawResponse as LLMResponseData;
				if (rawResponseObj.error) {
					providerError = rawResponseObj.error;
					lastJSONPreview = previewText(normalizeLLMJSONResponse(rawStreamPreview), 500);
					Log("Warn", `[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=${previewText(rawStreamPreview, 500)}`);
				}
			}
		}
		const response = buildStreamResponse(states, model, responseId, responseCreated, responseObject, providerError);
		const choiceCount = response.choices ? response.choices.length : 0;
		const streamStats = `http_chunks=${httpChunkCount} raw_bytes=${rawStreamBytes} sse_json_chunks=${sseJSONChunkCount} choice_chunks=${choiceJSONChunkCount} empty_choice_chunks=${emptyChoicesChunkCount} missing_choice_chunks=${missingChoicesChunkCount} parse_errors=${parseErrorCount} done=${doneChunkSeen ? "true" : "false"}`;
		Log("Info", `[Agent.Utils] callLLMStreamAggregated decoded response choices=${choiceCount} ${streamStats}`);
		if (!response.choices || response.choices.length === 0) {
			const providerMessage = providerError?.message ?? "";
			const providerType = providerError?.type ?? "";
			const providerCode = providerError && (typeof providerError.code === "string" || typeof providerError.code === "number")
				? tostring(providerError.code)
				: "";
			const details = [providerType, providerCode].filter(part => part !== "").join("/");
			const rawPreview = previewText(sanitizeUTF8(rawStreamPreview), 1200);
			const lastJSON = lastJSONPreview !== "" ? ` last_json=${lastJSONPreview}` : "";
			const message = providerMessage !== ""
				? `LLM returned no choices: ${providerMessage}${details !== "" ? ` (${details})` : ""}; ${streamStats}; raw=${rawPreview}${lastJSON}`
				: `LLM returned no choices; ${streamStats}; raw=${rawPreview}${lastJSON}`;
			Log("Error", `[Agent.Utils] callLLMStreamAggregated empty choices ${streamStats} raw_preview=${rawPreview}${lastJSON}`);
			return {
				success: false,
				message,
				raw: rawStreamPreview,
			};
		}
		return {
			success: true,
			response,
		};
	} catch (e) {
		if (stopToken?.stopped) {
			const reason = stopToken.reason ?? "request cancelled";
			Log("Info", `[Agent.Utils] callLLMStreamAggregated cancelled during request: ${reason}`);
			return { success: false, message: reason };
		}
		Log("Error", `[Agent.Utils] callLLMStreamAggregated exception: ${tostring(e)}`);
		return { success: false, message: tostring(e) };
	}
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
		const raw = sanitizeUTF8(await postLLM(fitted.messages, url, apiKey, model, options, false, undefined, stopToken));
		const normalizedRaw = normalizeLLMJSONResponse(raw);
		Log("Info", `[Agent.Utils] callLLMOnce raw response length=${raw.length}${normalizedRaw.length !== raw.length ? ` normalized=${normalizedRaw.length}` : ""}`);
		const [response, err] = safeJsonDecode(normalizedRaw);
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
			const providerMessage = providerError && typeof providerError.message === "string"
				? providerError.message
				: "";
			const providerType = providerError && typeof providerError.type === "string"
				? providerError.type
				: "";
			const providerCode = providerError && (typeof providerError.code === "string" || typeof providerError.code === "number")
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
