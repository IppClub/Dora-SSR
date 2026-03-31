// @preview-file off clear
import { App, Path, Content } from 'Dora';
import { Flow, Node } from 'Agent/flow';
import { callLLM, Message, StopToken, Log, getActiveLLMConfig, createLocalToolCallId, parseSimpleXMLChildren, parseXMLObjectFromText, safeJsonDecode, safeJsonEncode, sanitizeUTF8 } from 'Agent/Utils';
import type { LLMConfig } from 'Agent/Utils';
import * as Tools from 'Agent/Tools';
import { MemoryCompressor } from 'Agent/Memory';
import type { AgentPromptPack, AgentConversationMessage } from 'Agent/Memory';

export type CodingAgentRunResult =
	| {
		success: true;
		taskId: number;
		message: string;
		steps: number;
	}
	| {
		success: false;
		taskId?: number;
		message: string;
		steps?: number;
	};

export interface CodingAgentRunOptions {
	prompt: string;
	workDir: string;
	useChineseResponse?: boolean;
	taskId?: number;
	maxSteps?: number;
	decisionMode?: "tool_calling" | "xml";
	llmMaxTry?: number;
	llmOptions?: Record<string, unknown>;
	llmConfig?: LLMConfig;
	promptPack?: Partial<AgentPromptPack>;
	stopToken?: StopToken;
	sessionId?: number;
	onEvent?: (event: CodingAgentEvent) => void;
}

type AgentDecisionMode = "tool_calling" | "xml";

export type AgentToolName =
	| "read_file"
	| "edit_file"
	| "delete_file"
	| "grep_files"
	| "search_dora_api"
	| "glob_files"
	| "build"
	| "finish";

export type CodingAgentEvent =
	| {
		type: "task_started";
		sessionId?: number;
		taskId: number;
		prompt: string;
		workDir: string;
		maxSteps: number;
	}
	| {
		type: "decision_made";
		sessionId?: number;
		taskId: number;
		step: number;
		tool: AgentToolName;
		reason?: string;
		reasoningContent?: string;
		params: Record<string, unknown>;
	}
	| {
		type: "tool_started";
		sessionId?: number;
		taskId: number;
		step: number;
		tool: AgentToolName;
	}
	| {
		type: "tool_finished";
		sessionId?: number;
		taskId: number;
		step: number;
		tool: AgentToolName;
		reason?: string;
		result: Record<string, unknown>;
	}
	| {
		type: "checkpoint_created";
		sessionId?: number;
		taskId: number;
		step: number;
		tool: "edit_file" | "delete_file";
		checkpointId: number;
		checkpointSeq: number;
		files: {
			path: string;
			op: "write" | "create" | "delete";
		}[];
	}
	| {
		type: "task_finished";
		sessionId?: number;
		taskId?: number;
		success: boolean;
		message: string;
		steps?: number;
	};

const HISTORY_READ_FILE_MAX_CHARS = 12000;
const HISTORY_READ_FILE_MAX_LINES = 300;
const READ_FILE_DEFAULT_LIMIT = 300;
const HISTORY_SEARCH_FILES_MAX_MATCHES = 20;
const HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12;
const HISTORY_LIST_FILES_MAX_ENTRIES = 200;
const SEARCH_DORA_API_LIMIT_MAX = 20;
const SEARCH_FILES_LIMIT_DEFAULT = 20;
const LIST_FILES_MAX_ENTRIES_DEFAULT = 200;
const SEARCH_PREVIEW_CONTEXT = 80;

export interface AgentActionRecord {
	step: number;
	toolCallId: string;
	tool: AgentToolName;
	reason: string;
	reasoningContent?: string;
	params: Record<string, unknown>;
	result?: Record<string, unknown>;
	timestamp: string;
}

interface AgentShared {
	sessionId?: number;
	taskId: number;
	maxSteps: number;
	step: number;
	done: boolean;
	stopToken: StopToken;
	error?: string;
	response?: string;
	userQuery: string;
	workingDir: string;
	useChineseResponse: boolean;
	decisionMode: AgentDecisionMode;
	llmOptions: Record<string, unknown>;
	llmConfig: LLMConfig;
	llmMaxTry: number;
	onEvent?: (event: CodingAgentEvent) => void;
	promptPack: AgentPromptPack;
	history: AgentActionRecord[];
	messages: AgentConversationMessage[];
	// Memory 相关字段
	memory: {
		/** 上次压缩的消息索引 */
		lastConsolidatedMessageIndex: number;

		/** Memory 压缩器实例 */
		compressor: MemoryCompressor;
	};
}

function emitAgentEvent(shared: AgentShared, event: CodingAgentEvent) {
	if (shared.onEvent) {
		shared.onEvent(event);
	}
}

function getCancelledReason(shared: AgentShared): string {
	if (shared.stopToken.reason && shared.stopToken.reason !== "") return shared.stopToken.reason;
	return shared.useChineseResponse ? "已取消" : "cancelled";
}

function getMaxStepsReachedReason(shared: AgentShared): string {
	return shared.useChineseResponse
		? `已达到最大执行步数限制（${shared.maxSteps} 步）。`
		: `Maximum step limit reached (${shared.maxSteps} steps).`;
}

function getFailureSummaryFallback(shared: AgentShared, error: string): string {
	return shared.useChineseResponse
		? `任务因以下问题结束：${error}`
		: `The task ended due to the following issue: ${error}`;
}

function canWriteStepLLMDebug(shared: AgentShared, stepId = shared.step + 1): boolean {
	return App.debugging === true
		&& shared.sessionId !== undefined
		&& shared.sessionId > 0
		&& shared.taskId > 0
		&& stepId > 0;
}

function ensureDirRecursive(dir: string): boolean {
	if (!dir) return false;
	if (Content.exist(dir)) return Content.isdir(dir);
	const parent = Path.getPath(dir);
	if (parent && parent !== dir && !Content.exist(parent) && !ensureDirRecursive(parent)) {
		return false;
	}
	return Content.mkdir(dir);
}

function encodeDebugJSON(value: unknown): string {
	const [text, err] = safeJsonEncode(value as object);
	return text ?? `{ "error": "json_encode_failed", "message": "${tostring(err)}" }`;
}

function getStepLLMDebugDir(shared: AgentShared): string {
	return Path(
		shared.workingDir,
		".agent",
		tostring(shared.sessionId as number),
		tostring(shared.taskId),
	);
}

function getStepLLMDebugPath(shared: AgentShared, stepId: number, seq: number, kind: "in" | "out"): string {
	return Path(getStepLLMDebugDir(shared), `${tostring(stepId)}_${tostring(seq)}_${kind}.md`);
}

function getLatestStepLLMDebugSeq(shared: AgentShared, stepId: number): number {
	if (!canWriteStepLLMDebug(shared, stepId)) return 0;
	const dir = getStepLLMDebugDir(shared);
	if (!Content.exist(dir) || !Content.isdir(dir)) return 0;
	let latest = 0;
	for (const file of Content.getFiles(dir)) {
		const name = Path.getFilename(file);
		const [seqText] = string.match(name, `^${tostring(stepId)}_(%d+)_in%.md$`);
		if (seqText !== undefined) {
			latest = math.max(latest, tonumber(seqText) as number);
			continue;
		}
		const [legacyMatch] = string.match(name, `^${tostring(stepId)}_in%.md$`);
		if (legacyMatch !== undefined) {
			latest = math.max(latest, 1);
		}
	}
	return latest;
}

function writeStepLLMDebugFile(path: string, content: string): boolean {
	if (!Content.save(path, content)) {
		Log("Warn", `[CodingAgent] failed to save LLM debug file: ${path}`);
		return false;
	}
	return true;
}

function createStepLLMDebugPair(shared: AgentShared, stepId: number, inContent: string): number {
	if (!canWriteStepLLMDebug(shared, stepId)) return 0;
	const dir = getStepLLMDebugDir(shared);
	if (!ensureDirRecursive(dir)) {
		Log("Warn", `[CodingAgent] failed to create LLM debug dir: ${dir}`);
		return 0;
	}
	const seq = getLatestStepLLMDebugSeq(shared, stepId) + 1;
	const inPath = getStepLLMDebugPath(shared, stepId, seq, "in");
	const outPath = getStepLLMDebugPath(shared, stepId, seq, "out");
	if (!writeStepLLMDebugFile(inPath, inContent)) {
		return 0;
	}
	writeStepLLMDebugFile(outPath, "");
	return seq;
}

function updateLatestStepLLMDebugOutput(shared: AgentShared, stepId: number, content: string): void {
	if (!canWriteStepLLMDebug(shared, stepId)) return;
	const dir = getStepLLMDebugDir(shared);
	if (!ensureDirRecursive(dir)) {
		Log("Warn", `[CodingAgent] failed to create LLM debug dir: ${dir}`);
		return;
	}
	const latestSeq = getLatestStepLLMDebugSeq(shared, stepId);
	if (latestSeq <= 0) {
		const outPath = getStepLLMDebugPath(shared, stepId, 1, "out");
		writeStepLLMDebugFile(outPath, content);
		return;
	}
	const outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out");
	writeStepLLMDebugFile(outPath, content);
}

function saveStepLLMDebugInput(shared: AgentShared, stepId: number, phase: string, messages: Message[], options: Record<string, unknown>): void {
	if (!canWriteStepLLMDebug(shared, stepId)) return;
	const sections: string[] = [
		"# LLM Input",
		`session_id: ${tostring(shared.sessionId as number)}`,
		`task_id: ${tostring(shared.taskId)}`,
		`step_id: ${tostring(stepId)}`,
		`phase: ${phase}`,
		`timestamp: ${os.date("!%Y-%m-%dT%H:%M:%SZ")}`,
		"## Options",
		"```json",
		encodeDebugJSON(options),
		"```",
	];
	for (let i = 0; i < messages.length; i++) {
		const message = messages[i];
		sections.push(`## Message ${i + 1}`);
		sections.push(encodeDebugJSON(message));
	}
	createStepLLMDebugPair(shared, stepId, sections.join("\n"));
}

function saveStepLLMDebugOutput(shared: AgentShared, stepId: number, phase: string, text: string, meta?: Record<string, unknown>): void {
	if (!canWriteStepLLMDebug(shared, stepId)) return;
	const sections = [
		"# LLM Output",
		`session_id: ${tostring(shared.sessionId as number)}`,
		`task_id: ${tostring(shared.taskId)}`,
		`step_id: ${tostring(stepId)}`,
		`phase: ${phase}`,
		`timestamp: ${os.date("!%Y-%m-%dT%H:%M:%SZ")}`,
		...(meta ? ["## Meta", "```json", encodeDebugJSON(meta), "```"] : []),
		"## Content",
		text,
	];
	updateLatestStepLLMDebugOutput(shared, stepId, sections.join("\n"));
}

function toJson(value: unknown): string {
	const [text, err] = safeJsonEncode(value as object);
	if (text !== undefined) return text;
	return `{ "error": "json_encode_failed", "message": "${tostring(err)}" }`;
}

function truncateText(text: string, maxLen: number): string {
	if (text.length <= maxLen) return text;
	const nextPos = utf8.offset(text, maxLen + 1);
	if (nextPos === undefined) return text;
	return `${string.sub(text, 1, nextPos - 1)}...`;
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

function summarizeUnknown(value: unknown, maxLen = 320): string {
	if (value === undefined) return "undefined";
	if (value === null) return "null";
	if (typeof value === "string") {
		return truncateText(value, maxLen).replace("\n", "\\n");
	}
	if (type(value) === "number" || type(value) === "boolean") {
		return tostring(value);
	}
	return truncateText(toJson(value), maxLen).replace("\n", "\\n");
}

function getReplyLanguageDirective(shared: AgentShared): string {
	return shared.useChineseResponse
		? shared.promptPack.replyLanguageDirectiveZh
		: shared.promptPack.replyLanguageDirectiveEn;
}

function replacePromptVars(template: string, vars: Record<string, string>): string {
	let output = template;
	for (const key in vars) {
		output = output.split(`{{${key}}}`).join(vars[key] ?? "");
	}
	return output;
}

function limitReadContentForHistory(content: string, tool: "read_file"): string {
	const lines = content.split("\n");
	const overLineLimit = lines.length > HISTORY_READ_FILE_MAX_LINES;
	const limitedByLines = overLineLimit
		? lines.slice(0, HISTORY_READ_FILE_MAX_LINES).join("\n")
		: content;
	if (limitedByLines.length <= HISTORY_READ_FILE_MAX_CHARS && !overLineLimit) {
		return content;
	}
	const limited = limitedByLines.length > HISTORY_READ_FILE_MAX_CHARS
		? utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS)
		: limitedByLines;
	const reasons: string[] = [];
	if (content.length > HISTORY_READ_FILE_MAX_CHARS) reasons.push(`${content.length} chars`);
	if (lines.length > HISTORY_READ_FILE_MAX_LINES) reasons.push(`${lines.length} lines`);
	const hint = "Narrow the requested line range.";
	return `[${tool} content truncated for history (${reasons.join(", ")}). ${hint}]\n${limited}`;
}

function summarizeEditTextParamForHistory(value: unknown, key: "old_str" | "new_str"): Record<string, unknown> | undefined {
	if (typeof value !== "string") return undefined;
	const text = value;
	const lineCount = text === "" ? 0 : text.split("\n").length;
	return {
		charCount: text.length,
		lineCount,
		isMultiline: lineCount > 1,
		summaryType: `${key}_summary`,
	};
}

function sanitizeReadResultForHistory(tool: AgentToolName, result: Record<string, unknown>): Record<string, unknown> {
	if (tool !== "read_file" || result.success !== true || type(result.content) !== "string") {
		return result;
	}
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	clone.content = limitReadContentForHistory(result.content as string, tool);
	return clone;
}

function sanitizeSearchMatchesForHistory(
	items: Record<string, unknown>[],
	maxItems: number
): Record<string, unknown>[] {
	const shown = math.min(items.length, maxItems);
	const out: Record<string, unknown>[] = [];
	for (let i = 0; i < shown; i++) {
		const row = items[i];
		out.push({
			file: row.file,
			line: row.line,
			content: type(row.content) === "string"
				? truncateText(row.content as string, 240)
				: row.content,
		});
	}
	return out;
}

function sanitizeSearchResultForHistory(
	tool: AgentToolName,
	result: Record<string, unknown>
): Record<string, unknown> {
	if (result.success !== true || type(result.results) !== "table") return result;
	if (tool !== "grep_files" && tool !== "search_dora_api") return result;
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	const maxItems = tool === "grep_files" ? HISTORY_SEARCH_FILES_MAX_MATCHES : HISTORY_SEARCH_DORA_API_MAX_MATCHES;
	clone.results = sanitizeSearchMatchesForHistory(
		result.results as Record<string, unknown>[],
		maxItems
	);
	if (tool === "grep_files" && type(result.groupedResults) === "table") {
		const grouped = result.groupedResults as Record<string, unknown>[];
		const shown = math.min(grouped.length, HISTORY_SEARCH_FILES_MAX_MATCHES);
		const sanitizedGroups: Record<string, unknown>[] = [];
		for (let i = 0; i < shown; i++) {
			const row = grouped[i];
			sanitizedGroups.push({
				file: row.file,
				totalMatches: row.totalMatches,
				matches: type(row.matches) === "table"
					? sanitizeSearchMatchesForHistory(row.matches as Record<string, unknown>[], 3)
					: [],
			});
		}
		clone.groupedResults = sanitizedGroups;
	}
	return clone;
}

function sanitizeListFilesResultForHistory(result: Record<string, unknown>): Record<string, unknown> {
	if (result.success !== true || type(result.files) !== "table") return result;
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	const files = result.files as string[];
	clone.files = files.slice(0, HISTORY_LIST_FILES_MAX_ENTRIES);
	return clone;
}

function sanitizeActionParamsForHistory(tool: AgentToolName, params: Record<string, unknown>): Record<string, unknown> {
	if (tool !== "edit_file") return params;
	const clone: Record<string, unknown> = {};
	for (const key in params) {
		if (key === "old_str") {
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str");
		} else if (key === "new_str") {
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str");
		} else {
			clone[key] = params[key];
		}
	}
	return clone;
}

function getDecisionToolDefinitions(shared?: AgentShared): string {
	const base = replacePromptVars(
		shared?.promptPack.toolDefinitionsDetailed ?? "",
		{ SEARCH_DORA_API_LIMIT_MAX: tostring(SEARCH_DORA_API_LIMIT_MAX) }
	);
	if (shared?.decisionMode !== "xml") {
		return base;
	}
	return `${base}

XML mode object fields:
- Use a single root tag: <tool_call>.
- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.
- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.
- Inside <params>, use one child tag per parameter and preserve each tag content as raw text.`;
}

async function maybeCompressHistory(shared: AgentShared): Promise<void> {
	const { memory } = shared;
	const maxRounds = memory.compressor.getMaxCompressionRounds();
	let changed = false;
	for (let round = 0; round < maxRounds; round++) {
		const systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode === "xml");
		// In tool_calling mode, tool definitions are passed as the tools API parameter and
		// consume tokens, but are NOT embedded in the system prompt. Pass them separately
		// so the token estimator accounts for them correctly.
		const toolDefinitions = shared.decisionMode === "tool_calling"
			? getDecisionToolDefinitions(shared)
			: "";
		if (!memory.compressor.shouldCompress(
			shared.messages,
			memory.lastConsolidatedMessageIndex,
			systemPrompt,
			toolDefinitions
		)) {
			return;
		}
		const result = await memory.compressor.compress(
			shared.messages,
			memory.lastConsolidatedMessageIndex,
			systemPrompt,
			toolDefinitions,
			shared.llmOptions,
			shared.llmMaxTry,
			shared.decisionMode
		);
		if (!(result && result.success && result.compressedCount > 0)) {
			if (changed) {
				persistHistoryState(shared);
			}
			return;
		}
		memory.lastConsolidatedMessageIndex += result.compressedCount;
		changed = true;
		Log("Info", `[Memory] Compressed ${result.compressedCount} messages (round ${round + 1})`);
	}
	if (changed) {
		persistHistoryState(shared);
	}
}

function isKnownToolName(name: string): name is AgentToolName {
	return name === "read_file"
		|| name === "edit_file"
		|| name === "delete_file"
		|| name === "grep_files"
		|| name === "search_dora_api"
		|| name === "glob_files"
		|| name === "build"
		|| name === "finish";
}

function getFinishMessage(params: Record<string, unknown>, fallback = ""): string {
	if (type(params.message) === "string" && (params.message as string).trim() !== "") {
		return (params.message as string).trim();
	}
	if (type(params.response) === "string" && (params.response as string).trim() !== "") {
		return (params.response as string).trim();
	}
	if (type(params.summary) === "string" && (params.summary as string).trim() !== "") {
		return (params.summary as string).trim();
	}
	return fallback.trim();
}

function persistHistoryState(shared: AgentShared): void {
	shared.memory.compressor.getStorage().writeSessionState(
		shared.messages,
		shared.memory.lastConsolidatedMessageIndex
	);
}

function appendConversationMessage(shared: AgentShared, message: AgentConversationMessage): void {
	shared.messages.push({
		...message,
		content: message.content ? sanitizeUTF8(message.content) : message.content,
		name: message.name ? sanitizeUTF8(message.name) : message.name,
		tool_call_id: message.tool_call_id ? sanitizeUTF8(message.tool_call_id) : message.tool_call_id,
		reasoning_content: message.reasoning_content ? sanitizeUTF8(message.reasoning_content) : message.reasoning_content,
		timestamp: message.timestamp ?? os.date("!%Y-%m-%dT%H:%M:%SZ"),
	});
}

function ensureToolCallId(toolCallId?: string): string {
	if (toolCallId && toolCallId !== "") return toolCallId;
	return createLocalToolCallId();
}

function appendToolResultMessage(shared: AgentShared, action: AgentActionRecord): void {
	appendConversationMessage(shared, {
		role: "tool",
		tool_call_id: action.toolCallId,
		name: action.tool,
		content: action.result ? toJson(action.result) : "",
	});
}

function parseXMLToolCallObjectFromText(text: string): { success: true; obj: Record<string, unknown> } | { success: false; message: string } {
	const children = parseXMLObjectFromText(text, "tool_call");
	if (!children.success) return children;
	const rawObj = children.obj;
	const paramsText = typeof rawObj.params === "string" ? rawObj.params as string : "";
	const params = paramsText !== ""
		? parseSimpleXMLChildren(paramsText)
		: { success: true as const, obj: {} as Record<string, unknown> };
	if (!params.success) {
		return { success: false, message: params.message };
	}
	return {
		success: true,
		obj: {
			tool: rawObj.tool,
			reason: rawObj.reason,
			params: params.obj,
		},
	};
}

type LLMResult = {
	success: true;
	text: string
} | {
	success: false;
	message: string;
	text?: string
};

async function llm(
	shared: AgentShared,
	messages: Message[],
	phase: "decision_xml" | "decision_xml_repair" = "decision_xml"
): Promise<LLMResult> {
	const stepId = shared.step + 1;
	saveStepLLMDebugInput(shared, stepId, phase, messages, shared.llmOptions);
	const res = await callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig);
	if (res.success) {
		const text = res.response.choices?.[0]?.message?.content;
		if (text) {
			saveStepLLMDebugOutput(shared, stepId, phase, text, { success: true });
			return { success: true, text };
		} else {
			saveStepLLMDebugOutput(shared, stepId, phase, "empty LLM response", { success: false });
			return { success: false, message: "empty LLM response" };
		}
	} else {
		saveStepLLMDebugOutput(shared, stepId, phase, res.raw ?? res.message, { success: false });
		return { success: false, message: res.message };
	}
}

type DecisionSuccess = {
	success: true;
	tool: AgentToolName;
	params: Record<string, unknown>;
	toolCallId?: string;
	reason?: string;
	reasoningContent?: string;
	directSummary?: string;
};
type DecisionResult = DecisionSuccess | DecisionFailure;
type DecisionFailure = { success: false; message: string; raw?: string };

function parseDecisionObject(rawObj: Record<string, unknown>): DecisionSuccess | DecisionFailure {
	if (type(rawObj.tool) !== "string") return { success: false, message: "missing tool" };
	const tool = rawObj.tool as string;
	if (!isKnownToolName(tool)) {
		return { success: false, message: `unknown tool: ${tool}` };
	}
	const reason = type(rawObj.reason) === "string"
		? (rawObj.reason as string).trim()
		: undefined;
	if (tool !== "finish" && (!reason || reason === "")) {
		return { success: false, message: `${tool} requires top-level reason` };
	}
	const params = type(rawObj.params) === "table" ? (rawObj.params as Record<string, unknown>) : {};
	return {
		success: true,
		tool,
		params,
		reason,
	};
}

function parseDecisionToolCall(functionName: string, rawObj: unknown): DecisionSuccess | DecisionFailure {
	if (!isKnownToolName(functionName)) {
		return { success: false, message: `unknown tool: ${functionName}` };
	}
	if (rawObj === undefined || rawObj === null) {
		return { success: true, tool: functionName, params: {} };
	}
	if (type(rawObj) !== "table") {
		return { success: false, message: `invalid ${functionName} arguments` };
	}
	return {
		success: true,
		tool: functionName,
		params: rawObj as Record<string, unknown>,
	};
}

function getDecisionPath(params: Record<string, unknown>): string {
	if (type(params.path) === "string") return (params.path as string).trim();
	if (type(params.target_file) === "string") return (params.target_file as string).trim();
	return "";
}

function clampIntegerParam(value: unknown, fallback: number, minValue: number, maxValue?: number): number {
	let num = Number(value);
	if (!Number.isFinite(num)) num = fallback;
	num = math.floor(num);
	if (num < minValue) num = minValue;
	if (maxValue !== undefined && num > maxValue) num = maxValue;
	return num;
}

function validateDecision(
	tool: AgentToolName,
	params: Record<string, unknown>
): { success: true; params: Record<string, unknown> } | { success: false; message: string } {
	if (tool === "finish") {
		const message = getFinishMessage(params);
		if (message === "") return { success: false, message: "finish requires params.message" };
		params.message = message;
		return { success: true, params };
	}

	if (tool === "read_file") {
		const path = getDecisionPath(params);
		if (path === "") return { success: false, message: "read_file requires path" };
		params.path = path;
		const startLine = clampIntegerParam(params.startLine, 1, 1);
		const endLineRaw = params.endLine ?? READ_FILE_DEFAULT_LIMIT;
		const endLine = clampIntegerParam(endLineRaw, startLine, startLine);
		params.startLine = startLine;
		params.endLine = endLine;
		return { success: true, params };
	}

	if (tool === "edit_file") {
		const path = getDecisionPath(params);
		if (path === "") return { success: false, message: "edit_file requires path" };
		const oldStr = type(params.old_str) === "string" ? (params.old_str as string) : "";
		const newStr = type(params.new_str) === "string" ? (params.new_str as string) : "";
		params.path = path;
		params.old_str = oldStr;
		params.new_str = newStr;
		return { success: true, params };
	}

	if (tool === "delete_file") {
		const targetFile = getDecisionPath(params);
		if (targetFile === "") return { success: false, message: "delete_file requires target_file" };
		params.target_file = targetFile;
		return { success: true, params };
	}

	if (tool === "grep_files") {
		const pattern = type(params.pattern) === "string" ? (params.pattern as string).trim() : "";
		if (pattern === "") return { success: false, message: "grep_files requires pattern" };
		params.pattern = pattern;
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1);
		params.offset = clampIntegerParam(params.offset, 0, 0);
		return { success: true, params };
	}

	if (tool === "search_dora_api") {
		const pattern = type(params.pattern) === "string" ? (params.pattern as string).trim() : "";
		if (pattern === "") return { success: false, message: "search_dora_api requires pattern" };
		params.pattern = pattern;
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX);
		return { success: true, params };
	}

	if (tool === "glob_files") {
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1);
		return { success: true, params };
	}

	if (tool === "build") {
		const path = getDecisionPath(params);
		if (path !== "") {
			params.path = path;
		}
		return { success: true, params };
	}

	return { success: true, params };
}

function createFunctionToolSchema(
	name: AgentToolName,
	description: string,
	properties: Record<string, unknown>,
	required: string[] = []
) {
	const parameters: Record<string, unknown> = {
		type: "object",
		properties,
	};
	if (required.length > 0) {
		parameters.required = required;
	}
	return {
		type: "function" as const,
		function: {
			name,
			description,
			parameters,
		},
	};
}

function buildDecisionToolSchema() {
	return [
		createFunctionToolSchema(
			"read_file",
			"Read a specific line range from a file. Parameters: path, startLine(optional), endLine(optional). Line numbering starts with 1. startLine defaults to 1 and endLine defaults to 300.",
			{
				path: { type: "string", description: "Workspace-relative file path to read." },
				startLine: { type: "number", description: "1-based starting line number. Defaults to 1." },
				endLine: { type: "number", description: "1-based ending line number. Defaults to 300." },
			},
			["path"]
		),
		createFunctionToolSchema(
			"edit_file",
			"Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.",
			{
				path: { type: "string", description: "Workspace-relative file path to edit." },
				old_str: { type: "string", description: "Existing text to replace. Use an empty string only when creating a new file." },
				new_str: { type: "string", description: "Replacement text or the full new file content when creating." },
			},
			["path", "old_str", "new_str"]
		),
		createFunctionToolSchema(
			"delete_file",
			"Remove a file. Parameters: target_file.",
			{
				target_file: { type: "string", description: "Workspace-relative file path to delete." },
			},
			["target_file"]
		),
		createFunctionToolSchema(
			"grep_files",
			"Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.",
			{
				path: { type: "string", description: "Base directory or file path to search within." },
				pattern: { type: "string", description: "Content pattern to search for. Use | to express OR alternatives." },
				globs: { type: "array", items: { type: "string" }, description: "Optional file glob filters." },
				useRegex: { type: "boolean", description: "Set true when pattern is a regular expression." },
				caseSensitive: { type: "boolean", description: "Set true for case-sensitive matching." },
				limit: { type: "number", description: "Maximum number of results to return." },
				offset: { type: "number", description: "Offset for paginating later result pages." },
				groupByFile: { type: "boolean", description: "Set true to rank candidate files before drilling into one file." },
			},
			["pattern"]
		),
		createFunctionToolSchema(
			"glob_files",
			"Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.",
			{
				path: { type: "string", description: "Base directory to enumerate. Defaults to the workspace root when omitted." },
				globs: { type: "array", items: { type: "string" }, description: "Optional glob filters for returned paths." },
				maxEntries: { type: "number", description: "Maximum number of entries to return." },
			}
		),
		createFunctionToolSchema(
			"search_dora_api",
			`Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= ${SEARCH_DORA_API_LIMIT_MAX}.`,
			{
				pattern: { type: "string", description: "Query string to search for. Use | to express OR alternatives." },
				docSource: { type: "string", enum: ["api", "tutorial"], description: "Search API docs or tutorials." },
				programmingLanguage: {
					type: "string",
					enum: ["ts", "tsx", "lua", "yue", "teal", "tl", "wa"],
					description: "Preferred language variant to search.",
				},
				limit: { type: "number", description: `Maximum number of matches to return, up to ${SEARCH_DORA_API_LIMIT_MAX}.` },
				useRegex: { type: "boolean", description: "Set true when pattern is a regular expression." },
			},
			["pattern"]
		),
		createFunctionToolSchema(
			"build",
			"Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.",
			{
				path: { type: "string", description: "Optional workspace-relative file or directory to build." },
			}
		),
	];
}

function buildAgentSystemPrompt(shared: AgentShared, includeToolDefinitions = false): string {
	const sections: string[] = [
		shared.promptPack.agentIdentityPrompt,
		getReplyLanguageDirective(shared),
	];
	const memoryContext = shared.memory.compressor.getStorage().getMemoryContext();
	if (memoryContext !== "") {
		sections.push(memoryContext);
	}
	if (includeToolDefinitions) {
		sections.push("### Available Tools\n\n" + getDecisionToolDefinitions(shared));
		if (shared.decisionMode === "xml") {
			sections.push(buildXmlDecisionInstruction(shared));
		}
	}
	return sections.join("\n\n");
}

function getUnconsolidatedMessages(shared: AgentShared): Message[] {
	return shared.messages.slice(shared.memory.lastConsolidatedMessageIndex);
}

function buildDecisionMessages(shared: AgentShared, lastError?: string, attempt = 1, lastRaw?: string): Message[] {
	const messages: Message[] = [
		{ role: "system", content: buildAgentSystemPrompt(shared, shared.decisionMode === "xml") },
		...getUnconsolidatedMessages(shared),
	];
	if (lastError && lastError !== "") {
		const retryHeader = shared.decisionMode === "xml"
			? `Previous response was invalid (${lastError}). Return exactly one valid XML tool_call block only.`
			: replacePromptVars(shared.promptPack.toolCallingRetryPrompt, { LAST_ERROR: lastError });
		messages.push({
			role: "user",
			content: `${retryHeader}

Retry attempt: ${attempt}.
The next reply must differ from the previously rejected output.
${lastRaw && lastRaw !== "" ? `Last rejected output summary: ${truncateText(lastRaw, 300)}` : ""}`,
		});
	}
	return messages;
}

function buildXmlDecisionInstruction(shared: AgentShared, feedback?: string): string {
	return `${shared.promptPack.xmlDecisionFormatPrompt}${feedback ?? ""}`;
}

function buildXmlRepairMessages(
	shared: AgentShared,
	originalRaw: string,
	candidateRaw: string,
	lastError: string,
	attempt: number
): Message[] {
	const hasCandidate = candidateRaw.trim() !== "";
	const candidateSection = hasCandidate
		? `### Current Candidate To Repair
\`\`\`
${truncateText(candidateRaw, 4000)}
\`\`\`

`
		: "";
	const repairPrompt = replacePromptVars(shared.promptPack.xmlDecisionRepairPrompt, {
		TOOL_DEFINITIONS: getDecisionToolDefinitions(shared),
		ORIGINAL_RAW: truncateText(originalRaw, 4000),
		CANDIDATE_SECTION: candidateSection,
		LAST_ERROR: lastError,
		ATTEMPT: tostring(attempt),
	});
	return [
		{
			role: "system",
			content: `You repair invalid XML tool decisions for the Dora coding agent.

Your job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.

Requirements:
- Preserve the original tool name and parameter values whenever possible.
- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.
- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.
- Only repair formatting and schema shape so the output becomes valid XML.
- Do not continue the conversation and do not add explanations.
- Return XML only.`,
		},
		{
			role: "user",
			content: repairPrompt,
		},
	];
}

function tryParseAndValidateDecision(rawText: string): DecisionSuccess | DecisionFailure {
	const parsed = parseXMLToolCallObjectFromText(rawText);
	if (!parsed.success) {
		return { success: false, message: parsed.message, raw: rawText };
	}
	const decision = parseDecisionObject(parsed.obj);
	if (!decision.success) {
		return { success: false, message: decision.message, raw: rawText };
	}
	const validation = validateDecision(decision.tool, decision.params);
	if (!validation.success) {
		return { success: false, message: validation.message, raw: rawText };
	}
	decision.params = validation.params;
	decision.toolCallId = ensureToolCallId(decision.toolCallId);
	return decision;
}

function normalizeLineEndings(text: string): string {
	let [res] = string.gsub(text, "\r\n", "\n");
	[res] = string.gsub(res, "\r", "\n");
	return res;
}

function countOccurrences(text: string, searchStr: string): number {
	if (searchStr === "") return 0;
	let count = 0;
	let pos = 0;
	while (true) {
		const idx = text.indexOf(searchStr, pos);
		if (idx < 0) break;
		count += 1;
		pos = idx + searchStr.length;
	}
	return count;
}

function replaceFirst(text: string, oldStr: string, newStr: string): string {
	if (oldStr === "") return text;
	const idx = text.indexOf(oldStr);
	if (idx < 0) return text;
	return text.substring(0, idx) + newStr + text.substring(idx + oldStr.length);
}

function splitLines(text: string): string[] {
	return text.split("\n");
}

function getLeadingWhitespace(text: string): string {
	let i = 0;
	while (i < text.length) {
		const ch = text[i];
		if (ch !== " " && ch !== "\t") break;
		i += 1;
	}
	return text.substring(0, i);
}

function getCommonIndentPrefix(lines: string[]): string {
	let common: string | undefined;
	for (let i = 0; i < lines.length; i++) {
		const line = lines[i];
		if (line.trim() === "") continue;
		const indent = getLeadingWhitespace(line);
		if (common === undefined) {
			common = indent;
			continue;
		}
		let j = 0;
		const maxLen = math.min(common.length, indent.length);
		while (j < maxLen && common[j] === indent[j]) {
			j += 1;
		}
		common = common.substring(0, j);
		if (common === "") break;
	}
	return common ?? "";
}

function removeIndentPrefix(line: string, indent: string): string {
	if (indent !== "" && line.startsWith(indent)) {
		return line.substring(indent.length);
	}
	const lineIndent = getLeadingWhitespace(line);
	let j = 0;
	const maxLen = math.min(lineIndent.length, indent.length);
	while (j < maxLen && lineIndent[j] === indent[j]) {
		j += 1;
	}
	return line.substring(j);
}

function dedentLines(lines: string[]): { indent: string; lines: string[] } {
	const indent = getCommonIndentPrefix(lines);
	return {
		indent,
		lines: lines.map(line => removeIndentPrefix(line, indent)),
	};
}

function joinLines(lines: string[]): string {
	return lines.join("\n");
}

function findIndentTolerantReplacement(
	content: string,
	oldStr: string,
	newStr: string
): { success: true; content: string } | { success: false; message: string } {
	const contentLines = splitLines(content);
	const oldLines = splitLines(oldStr);
	if (oldLines.length === 0) {
		return { success: false, message: "old_str not found in file" };
	}
	const dedentedOld = dedentLines(oldLines);
	const dedentedOldText = joinLines(dedentedOld.lines);
	const dedentedNew = dedentLines(splitLines(newStr));
	const matches: { start: number; end: number; indent: string }[] = [];
	for (let start = 0; start <= contentLines.length - oldLines.length; start++) {
		const candidateLines = contentLines.slice(start, start + oldLines.length);
		const dedentedCandidate = dedentLines(candidateLines);
		if (joinLines(dedentedCandidate.lines) === dedentedOldText) {
			matches.push({
				start,
				end: start + oldLines.length,
				indent: dedentedCandidate.indent,
			});
		}
	}
	if (matches.length === 0) {
		return { success: false, message: "old_str not found in file" };
	}
	if (matches.length > 1) {
		return {
			success: false,
			message: `old_str appears ${matches.length} times in file after indentation normalization. Please provide more context to uniquely identify the target location.`,
		};
	}
	const match = matches[0];
	const rebuiltNewLines = dedentedNew.lines.map(line => line === "" ? "" : match.indent + line);
	const nextLines = [
		...contentLines.slice(0, match.start),
		...rebuiltNewLines,
		...contentLines.slice(match.end),
	];
	return { success: true, content: joinLines(nextLines) };
}

class MainDecisionAgent extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ shared: AgentShared }> {
		if (shared.stopToken.stopped || shared.step >= shared.maxSteps) {
			return { shared };
		}

		await maybeCompressHistory(shared);

		return { shared };
	}

	private async callDecisionByToolCalling(
		shared: AgentShared,
		lastError?: string,
		attempt = 1,
		lastRaw?: string
	): Promise<DecisionResult | DecisionFailure> {
		if (shared.stopToken.stopped) {
			return { success: false, message: getCancelledReason(shared) };
		}
		Log("Info", `[CodingAgent] tool-calling decision start step=${shared.step + 1}${lastError ? ` retry_error=${lastError}` : ""}`);
		const tools = buildDecisionToolSchema();
		const messages = buildDecisionMessages(shared, lastError, attempt, lastRaw);
		const stepId = shared.step + 1;
		const llmOptions = {
			...shared.llmOptions,
			tools,
		};
		saveStepLLMDebugInput(shared, stepId, "decision_tool_calling", messages, llmOptions);
		const res = await callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig);
		if (shared.stopToken.stopped) {
			return { success: false, message: getCancelledReason(shared) };
		}
		if (!res.success) {
			saveStepLLMDebugOutput(shared, stepId, "decision_tool_calling", res.raw ?? res.message, { success: false });
			Log("Error", `[CodingAgent] tool-calling request failed: ${res.message}`);
			return { success: false, message: res.message, raw: res.raw };
		}
		saveStepLLMDebugOutput(shared, stepId, "decision_tool_calling", encodeDebugJSON(res.response), { success: true });
		const choice = res.response.choices && res.response.choices[0];
		const message = choice && choice.message;
		const toolCalls = message && message.tool_calls;
		const toolCall = toolCalls && toolCalls[0];
		const fn = toolCall && toolCall.function;
		const toolCallId = toolCall && type(toolCall.id) === "string"
			? (toolCall.id as string)
			: undefined;
		const reasoningContent = message && type(message.reasoning_content) === "string"
			? (message.reasoning_content as string).trim()
			: undefined;
		const messageContent = message && type(message.content) === "string"
			? (message.content as string).trim()
			: undefined;
		Log("Info", `[CodingAgent] tool-calling response finish_reason=${choice && choice.finish_reason ? choice.finish_reason : "unknown"} tool_calls=${toolCalls ? toolCalls.length : 0} content_len=${messageContent ? messageContent.length : 0} reasoning_len=${reasoningContent ? reasoningContent.length : 0}`);
		if (!fn || type(fn.name) !== "string" || fn.name === "") {
			if (messageContent && messageContent !== "") {
				Log("Info", `[CodingAgent] tool-calling fallback direct_finish_len=${messageContent.length}`);
				return {
					success: true,
					tool: "finish",
					params: {},
					reason: messageContent,
					reasoningContent,
					directSummary: messageContent,
				};
			}
			Log("Error", `[CodingAgent] missing tool call and plain-text fallback`);
			return {
				success: false,
				message: "missing tool call",
				raw: messageContent,
			};
		}
		const functionName = fn.name as string;
		const argsText = typeof fn.arguments === "string" ? fn.arguments : "";
		Log("Info", `[CodingAgent] tool-calling function=${functionName} args_len=${argsText.length}`);
		const rawArgs = argsText.trim() === "" ? {} : (() => {
			const [rawObj, err] = safeJsonDecode(argsText);
			if (err !== undefined || rawObj === undefined) {
				return { __error: tostring(err) };
			}
			return rawObj;
		})();
		if (type(rawArgs) === "table" && (rawArgs as Record<string, unknown>).__error !== undefined) {
			const err = tostring((rawArgs as Record<string, unknown>).__error);
			Log("Error", `[CodingAgent] invalid ${functionName} arguments JSON: ${err}`);
			return {
				success: false,
				message: `invalid ${functionName} arguments: ${err}`,
				raw: argsText,
			};
		}
		p(rawArgs);
		const decision = parseDecisionToolCall(functionName, rawArgs);
		if (!decision.success) {
			Log("Error", `[CodingAgent] invalid tool arguments schema: ${decision.message}`);
			return {
				success: false,
				message: decision.message,
				raw: argsText,
			};
		}
		const validation = validateDecision(decision.tool, decision.params);
		if (!validation.success) {
			Log("Error", `[CodingAgent] invalid ${decision.tool} arguments values: ${validation.message}`);
			return {
				success: false,
				message: validation.message,
				raw: argsText,
			};
		}
		decision.params = validation.params;
		decision.toolCallId = ensureToolCallId(toolCallId);
		decision.reason = messageContent;
		decision.reasoningContent = reasoningContent;
		Log("Info", `[CodingAgent] tool-calling selected tool=${decision.tool}`);
		return decision;
	}

	private async repairDecisionXml(
		shared: AgentShared,
		originalRaw: string,
		initialError: string
	): Promise<DecisionResult | DecisionFailure> {
		Log("Info", `[CodingAgent] xml repair flow start step=${shared.step + 1} error=${initialError}`);
		let lastError = initialError;
		let candidateRaw = "";
		for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
			Log("Info", `[CodingAgent] xml repair attempt=${attempt + 1}`);
			const messages = buildXmlRepairMessages(
				shared,
				originalRaw,
				candidateRaw,
				lastError,
				attempt + 1
			);
			const llmRes = await llm(shared, messages, "decision_xml_repair");
			if (shared.stopToken.stopped) {
				return { success: false, message: getCancelledReason(shared) };
			}
			if (!llmRes.success) {
				lastError = llmRes.message;
				Log("Error", `[CodingAgent] xml repair attempt failed: ${lastError}`);
				continue;
			}
			candidateRaw = llmRes.text;
			const decision = tryParseAndValidateDecision(candidateRaw);
			if (decision.success) {
				Log("Info", `[CodingAgent] xml repair succeeded tool=${decision.tool}`);
				return decision;
			}
			lastError = decision.message;
			Log("Error", `[CodingAgent] xml repair candidate invalid: ${lastError}`);
		}
		Log("Error", `[CodingAgent] xml repair exhausted retries: ${lastError}`);
		return {
			success: false,
			message: `cannot repair invalid decision xml: ${lastError}`,
			raw: candidateRaw,
		};
	}

	async exec(input: { shared: AgentShared }): Promise<DecisionResult | DecisionFailure> {
		const shared = input.shared;
		if (shared.stopToken.stopped) {
			return { success: false, message: getCancelledReason(shared) };
		}
		if (shared.step >= shared.maxSteps) {
			Log("Warn", `[CodingAgent] maximum step limit reached step=${shared.step} max=${shared.maxSteps}`);
			return { success: false, message: getMaxStepsReachedReason(shared) };
		}

		if (shared.decisionMode === "tool_calling") {
			Log("Info", `[CodingAgent] decision mode=tool_calling step=${shared.step + 1} messages=${getUnconsolidatedMessages(shared).length}`);
			let lastError = "tool calling validation failed";
			let lastRaw = "";
			for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
				Log("Info", `[CodingAgent] tool-calling attempt=${attempt + 1}`);
				const decision = await this.callDecisionByToolCalling(
					shared,
					attempt > 0 ? lastError : undefined,
					attempt + 1,
					lastRaw
				);
				if (shared.stopToken.stopped) {
					return { success: false, message: getCancelledReason(shared) };
				}
				if (decision.success) {
					return decision;
				}
				lastError = decision.message;
				lastRaw = decision.raw ?? "";
				Log("Error", `[CodingAgent] tool-calling attempt failed: ${lastError}`);
			}
			Log("Error", `[CodingAgent] tool-calling exhausted retries: ${lastError}`);
			return { success: false, message: `cannot produce valid tool call: ${lastError}; last_output=${truncateText(lastRaw, 400)}` };
		}

		let lastError = "xml validation failed";
		let lastRaw = "";
		for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
			const messages: Message[] = buildDecisionMessages(
				shared,
				attempt > 0
					? `Previous request failed before producing repairable output (${lastError}).`
					: undefined,
				attempt + 1,
				lastRaw
			);
			const llmRes = await llm(shared, messages, "decision_xml");
			if (shared.stopToken.stopped) {
				return { success: false, message: getCancelledReason(shared) };
			}
			if (!llmRes.success) {
				lastError = llmRes.message;
				lastRaw = llmRes.text ?? "";
				continue;
			}
			lastRaw = llmRes.text;
			const decision = tryParseAndValidateDecision(llmRes.text);
			if (decision.success) {
				return decision;
			}
			lastError = decision.message;
			return this.repairDecisionXml(shared, llmRes.text, lastError);
		}
		return { success: false, message: `cannot produce valid decision xml: ${lastError}; last_output=${truncateText(lastRaw, 400)}` };
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const result = execRes as DecisionResult | { success: false; message: string };
		if (!result.success) {
			shared.error = result.message;
			shared.response = getFailureSummaryFallback(shared, result.message);
			shared.done = true;
			appendConversationMessage(shared, {
				role: "assistant",
				content: shared.response,
			});
			persistHistoryState(shared);
			return "done";
		}
		if (result.directSummary && result.directSummary !== "") {
			shared.response = result.directSummary;
			shared.done = true;
			appendConversationMessage(shared, {
				role: "assistant",
				content: result.directSummary,
				reasoning_content: result.reasoningContent,
			});
			persistHistoryState(shared);
			return "done";
		}
		if (result.tool === "finish") {
			const finalMessage = getFinishMessage(result.params, result.reason ?? "");
			shared.response = finalMessage;
			shared.done = true;
			appendConversationMessage(shared, {
				role: "assistant",
				content: finalMessage,
				reasoning_content: result.reasoningContent,
			});
			persistHistoryState(shared);
			return "done";
		}
		emitAgentEvent(shared, {
			type: "decision_made",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: shared.step + 1,
			tool: result.tool,
			reason: result.reason,
			reasoningContent: result.reasoningContent,
			params: result.params,
		});
		const toolCallId = ensureToolCallId(result.toolCallId);
		shared.history.push({
			step: shared.history.length + 1,
			toolCallId,
			tool: result.tool,
			reason: result.reason ?? "",
			reasoningContent: result.reasoningContent,
			params: result.params,
			timestamp: os.date("!%Y-%m-%dT%H:%M:%SZ"),
		});
		appendConversationMessage(shared, {
			role: "assistant",
			content: result.reason ?? "",
			reasoning_content: result.reasoningContent,
			tool_calls: [{
				id: toolCallId,
				type: "function",
				function: {
					name: result.tool,
					arguments: toJson(result.params),
				},
			}],
		});
		persistHistoryState(shared);
		return result.tool;
	}
}

class ReadFileAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ path: string; startLine: number; endLine: number; tool: "read_file"; workDir: string; docLanguage: Tools.DoraAPIDocLanguage }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentEvent(shared, {
			type: "tool_started",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: shared.step + 1,
			tool: last.tool,
		});
		const path = type(last.params.path) === "string"
			? (last.params.path as string)
			: (type(last.params.target_file) === "string" ? (last.params.target_file as string) : "");
		if (path.trim() === "") throw new Error("missing path");
		return {
			path,
			tool: "read_file",
			workDir: shared.workingDir,
			docLanguage: shared.useChineseResponse ? "zh" : "en",
			startLine: Number(last.params.startLine ?? 1),
			endLine: Number(last.params.endLine ?? READ_FILE_DEFAULT_LIMIT),
		};
	}

	async exec(input: { path: string; startLine: number; endLine: number; tool: "read_file"; workDir: string; docLanguage: Tools.DoraAPIDocLanguage }): Promise<Record<string, unknown>> {
		return Tools.readFile(
			input.workDir,
			input.path,
			Number(input.startLine ?? 1),
			Number(input.endLine ?? READ_FILE_DEFAULT_LIMIT),
			input.docLanguage
		) as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const result = execRes as Record<string, unknown>;
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.result = sanitizeReadResultForHistory(last.tool, result);
			appendToolResultMessage(shared, last);
			emitAgentEvent(shared, {
				type: "tool_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step + 1,
				tool: last.tool,
				result: last.result,
			});
		}
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		shared.step += 1;
		return "main";
	}
}

class SearchFilesAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentEvent(shared, {
			type: "tool_started",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: shared.step + 1,
			tool: last.tool,
		});
		return { params: last.params, workDir: shared.workingDir };
	}

	async exec(input: { params: Record<string, unknown>; workDir: string }): Promise<Record<string, unknown>> {
		const params = input.params;
		const result = await Tools.searchFiles({
			workDir: input.workDir,
			path: (params.path as string) ?? "",
			pattern: (params.pattern as string) ?? "",
			globs: params.globs as string[] | undefined,
			useRegex: params.useRegex as boolean | undefined,
			caseSensitive: params.caseSensitive as boolean | undefined,
			includeContent: true,
			contentWindow: SEARCH_PREVIEW_CONTEXT,
			limit: math.max(1, math.floor(Number(params.limit ?? SEARCH_FILES_LIMIT_DEFAULT))),
			offset: math.max(0, math.floor(Number(params.offset ?? 0))),
			groupByFile: params.groupByFile === true,
		});
		return result as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			const result = execRes as Record<string, unknown>;
			last.result = sanitizeSearchResultForHistory(last.tool, result);
			appendToolResultMessage(shared, last);
			emitAgentEvent(shared, {
				type: "tool_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step + 1,
				tool: last.tool,
				result: last.result,
			});
		}
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		shared.step += 1;
		return "main";
	}
}

class SearchDoraAPIAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; useChineseResponse: boolean }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentEvent(shared, {
			type: "tool_started",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: shared.step + 1,
			tool: last.tool,
		});
		return { params: last.params, useChineseResponse: shared.useChineseResponse };
	}

	async exec(input: { params: Record<string, unknown>; useChineseResponse: boolean }): Promise<Record<string, unknown>> {
		const params = input.params;
		const result = await Tools.searchDoraAPI({
			pattern: (params.pattern as string) ?? "",
			docSource: ((params.docSource as string) ?? "api") as Tools.DoraAPIDocSource,
			docLanguage: (input.useChineseResponse ? "zh" : "en") as Tools.DoraAPIDocLanguage,
			programmingLanguage: ((params.programmingLanguage as string) ?? "ts") as Tools.DoraAPIProgrammingLanguage,
			limit: math.min(SEARCH_DORA_API_LIMIT_MAX, math.max(1, Number(params.limit ?? 8))),
			useRegex: params.useRegex as boolean | undefined,
			caseSensitive: false,
			includeContent: true,
			contentWindow: SEARCH_PREVIEW_CONTEXT,
		});
		return result as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			const result = execRes as Record<string, unknown>;
			last.result = sanitizeSearchResultForHistory(last.tool, result);
			appendToolResultMessage(shared, last);
			emitAgentEvent(shared, {
				type: "tool_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step + 1,
				tool: last.tool,
				result: last.result,
			});
		}
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		shared.step += 1;
		return "main";
	}
}

class ListFilesAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentEvent(shared, {
			type: "tool_started",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: shared.step + 1,
			tool: last.tool,
		});
		return { params: last.params, workDir: shared.workingDir };
	}

	async exec(input: { params: Record<string, unknown>; workDir: string }): Promise<Record<string, unknown>> {
		const params = input.params;
		const result = Tools.listFiles({
			workDir: input.workDir,
			path: (params.path as string) ?? "",
			globs: params.globs as string[] | undefined,
			maxEntries: math.max(1, math.floor(Number(params.maxEntries ?? LIST_FILES_MAX_ENTRIES_DEFAULT))),
		});
		return result as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.result = sanitizeListFilesResultForHistory(execRes as Record<string, unknown>);
			appendToolResultMessage(shared, last);
			emitAgentEvent(shared, {
				type: "tool_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step + 1,
				tool: last.tool,
				result: last.result,
			});
		}
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		shared.step += 1;
		return "main";
	}
}

class DeleteFileAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ targetFile: string; taskId: number; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentEvent(shared, {
			type: "tool_started",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: shared.step + 1,
			tool: last.tool,
		});
		const targetFile = type(last.params.target_file) === "string"
			? (last.params.target_file as string)
			: (type(last.params.path) === "string" ? (last.params.path as string) : "");
		if (targetFile.trim() === "") throw new Error("missing target_file");
		return { targetFile, taskId: shared.taskId, workDir: shared.workingDir };
	}

	async exec(input: { targetFile: string; taskId: number; workDir: string }): Promise<Record<string, unknown>> {
		const result = Tools.applyFileChanges(input.taskId, input.workDir, [{ path: input.targetFile, op: "delete" }], {
			summary: `delete_file: ${input.targetFile}`,
			toolName: "delete_file",
		});
		if (!result.success) {
			return result as unknown as Record<string, unknown>;
		}
		return {
			success: true,
			changed: true,
			mode: "delete",
			checkpointId: result.checkpointId,
			checkpointSeq: result.checkpointSeq,
			files: [{ path: input.targetFile, op: "delete" as const }],
		};
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.result = execRes as Record<string, unknown>;
			appendToolResultMessage(shared, last);
			emitAgentEvent(shared, {
				type: "tool_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step + 1,
				tool: last.tool,
				result: last.result,
			});
			const result = last.result;
			if (last.tool === "delete_file"
				&& type(result.checkpointId) === "number"
				&& type(result.checkpointSeq) === "number"
				&& type(result.files) === "table") {
				emitAgentEvent(shared, {
					type: "checkpoint_created",
					sessionId: shared.sessionId,
					taskId: shared.taskId,
					step: shared.step + 1,
					tool: "delete_file",
					checkpointId: result.checkpointId as number,
					checkpointSeq: result.checkpointSeq as number,
					files: result.files as { path: string; op: "write" | "create" | "delete"; }[],
				});
			}
		}
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		shared.step += 1;
		return "main";
	}
}

class BuildAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentEvent(shared, {
			type: "tool_started",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: shared.step + 1,
			tool: last.tool,
		});
		return { params: last.params, workDir: shared.workingDir };
	}

	async exec(input: { params: Record<string, unknown>; workDir: string }): Promise<Record<string, unknown>> {
		const params = input.params;
		const result = await Tools.build({
			workDir: input.workDir,
			path: (params.path as string) ?? ""
		});
		return result as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.result = execRes as Record<string, unknown>;
			appendToolResultMessage(shared, last);
			emitAgentEvent(shared, {
				type: "tool_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step + 1,
				tool: last.tool,
				result: last.result,
			});
		}
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		shared.step += 1;
		return "main";
	}
}

class EditFileAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ path: string; oldStr: string; newStr: string; taskId: number; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentEvent(shared, {
			type: "tool_started",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: shared.step + 1,
			tool: last.tool,
		});
		const path = type(last.params.path) === "string"
			? (last.params.path as string)
			: (type(last.params.target_file) === "string" ? (last.params.target_file as string) : "");
		const oldStr = type(last.params.old_str) === "string" ? (last.params.old_str as string) : "";
		const newStr = type(last.params.new_str) === "string" ? (last.params.new_str as string) : "";
		if (path.trim() === "") throw new Error("missing path");
		return { path, oldStr, newStr, taskId: shared.taskId, workDir: shared.workingDir };
	}

	async exec(input: { path: string; oldStr: string; newStr: string; taskId: number; workDir: string }): Promise<Record<string, unknown>> {
		const readRes = Tools.readFileRaw(input.workDir, input.path);
		if (!readRes.success) {
			if (input.oldStr !== "") {
				return { success: false, message: `read file failed: ${readRes.message}` };
			}
			const createRes = Tools.applyFileChanges(input.taskId, input.workDir, [{ path: input.path, op: "create", content: input.newStr }], {
				summary: `create file ${input.path} via edit_file`,
				toolName: "edit_file",
			});
			if (!createRes.success) {
				return { success: false, message: `create file failed: ${createRes.message}` };
			}
			return {
				success: true,
				changed: true,
				mode: "create",
				checkpointId: createRes.checkpointId,
				checkpointSeq: createRes.checkpointSeq,
				files: [{ path: input.path, op: "create" as const }],
			};
		}
		if (input.oldStr === "") {
			const overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, [{ path: input.path, op: "write", content: input.newStr }], {
				summary: `overwrite file ${input.path} via edit_file`,
				toolName: "edit_file",
			});
			if (!overwriteRes.success) {
				return { success: false, message: `write file failed: ${overwriteRes.message}` };
			}
			return {
				success: true,
				changed: true,
				mode: "overwrite",
				checkpointId: overwriteRes.checkpointId,
				checkpointSeq: overwriteRes.checkpointSeq,
				files: [{ path: input.path, op: "write" as const }],
			};
		}

		// Normalize line endings for consistent matching
		const normalizedContent = normalizeLineEndings(readRes.content);
		const normalizedOldStr = normalizeLineEndings(input.oldStr);
		const normalizedNewStr = normalizeLineEndings(input.newStr);

		// Check how many times old_str appears
		const occurrences = countOccurrences(normalizedContent, normalizedOldStr);
		if (occurrences === 0) {
			const indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr);
			if (!indentTolerant.success) {
				return { success: false, message: indentTolerant.message };
			}
			const applyRes = Tools.applyFileChanges(input.taskId, input.workDir, [{ path: input.path, op: "write", content: indentTolerant.content }], {
				summary: `replace text in ${input.path} via edit_file (indent-tolerant)`,
				toolName: "edit_file",
			});
			if (!applyRes.success) {
				return { success: false, message: `write file failed: ${applyRes.message}` };
			}
			return {
				success: true,
				changed: true,
				mode: "replace_indent_tolerant",
				checkpointId: applyRes.checkpointId,
				checkpointSeq: applyRes.checkpointSeq,
				files: [{ path: input.path, op: "write" as const }],
			};
		}
		if (occurrences > 1) {
			return { success: false, message: `old_str appears ${occurrences} times in file. Please provide more context to uniquely identify the target location.` };
		}

		// Perform the replacement (we know it appears exactly once)
		const newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr);
		const applyRes = Tools.applyFileChanges(input.taskId, input.workDir, [{ path: input.path, op: "write", content: newContent }], {
			summary: `replace text in ${input.path} via edit_file`,
			toolName: "edit_file",
		});
		if (!applyRes.success) {
			return { success: false, message: `write file failed: ${applyRes.message}` };
		}
		return {
			success: true,
			changed: true,
			mode: "replace",
			checkpointId: applyRes.checkpointId,
			checkpointSeq: applyRes.checkpointSeq,
			files: [{ path: input.path, op: "write" as const }],
		};
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.params = sanitizeActionParamsForHistory(last.tool, last.params);
			last.result = execRes as Record<string, unknown>;
			appendToolResultMessage(shared, last);
			emitAgentEvent(shared, {
				type: "tool_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step + 1,
				tool: last.tool,
				result: last.result,
			});
			const result = last.result;
			if ((last.tool === "edit_file" || last.tool === "delete_file")
				&& typeof result.checkpointId === "number"
				&& typeof result.checkpointSeq === "number"
				&& Array.isArray(result.files)) {
				emitAgentEvent(shared, {
					type: "checkpoint_created",
					sessionId: shared.sessionId,
					taskId: shared.taskId,
					step: shared.step + 1,
					tool: last.tool,
					checkpointId: result.checkpointId,
					checkpointSeq: result.checkpointSeq,
					files: result.files,
				});
			}
		}
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		shared.step += 1;
		return "main";
	}
}

class EndNode extends Node<AgentShared> {
	async post(_shared: AgentShared, _prepRes: unknown, _execRes: unknown): Promise<string | undefined> {
		return undefined;
	}
}

class CodingAgentFlow extends Flow<AgentShared> {
	constructor() {
		const main = new MainDecisionAgent(1, 0);
		const read = new ReadFileAction(1, 0);
		const search = new SearchFilesAction(1, 0);
		const searchDora = new SearchDoraAPIAction(1, 0);
		const list = new ListFilesAction(1, 0);
		const del = new DeleteFileAction(1, 0);
		const build = new BuildAction(1, 0);
		const edit = new EditFileAction(1, 0);
		const done = new EndNode(1, 0);

		main.on("read_file", read);
		main.on("grep_files", search);
		main.on("search_dora_api", searchDora);
		main.on("glob_files", list);
		main.on("delete_file", del);
		main.on("build", build);
		main.on("edit_file", edit);
		main.on("done", done);

		read.on("main", main);
		search.on("main", main);
		searchDora.on("main", main);
		list.on("main", main);
		del.on("main", main);
		build.on("main", main);
		edit.on("main", main);

		super(main);
	}
}

async function runCodingAgentAsync(options: CodingAgentRunOptions): Promise<CodingAgentRunResult> {
	if (!options.workDir || !Content.isAbsolutePath(options.workDir) || !Content.exist(options.workDir) || !Content.isdir(options.workDir)) {
		return { success: false, message: "workDir must be an existing absolute directory path" };
	}
	const llmConfigRes = options.llmConfig
		? { success: true as const, config: options.llmConfig }
		: getActiveLLMConfig();
	if (!llmConfigRes.success) {
		return { success: false, message: llmConfigRes.message };
	}
	const llmConfig = llmConfigRes.config;
	const taskRes = options.taskId !== undefined
		? { success: true as const, taskId: options.taskId }
		: Tools.createTask(options.prompt);
	if (!taskRes.success) {
		return { success: false, message: taskRes.message };
	}
	// 创建 Memory 压缩器
	const compressor = new MemoryCompressor({
		compressionThreshold: 0.8,
		maxCompressionRounds: 3,
		maxTokensPerCompression: 20000,
		projectDir: options.workDir,
		llmConfig,
		promptPack: options.promptPack,
	});
	const persistedSession = compressor.getStorage().readSessionState();
	const promptPack = compressor.getPromptPack();

	const shared: AgentShared = {
		sessionId: options.sessionId,
		taskId: taskRes.taskId,
		maxSteps: math.max(1, math.floor(options.maxSteps ?? 40)),
		llmMaxTry: math.max(1, math.floor(options.llmMaxTry ?? 3)),
		step: 0,
		done: false,
		stopToken: options.stopToken ?? { stopped: false },
		response: "",
		userQuery: options.prompt,
		workingDir: options.workDir,
		useChineseResponse: options.useChineseResponse === true,
		decisionMode: options.decisionMode
			? options.decisionMode
			: (llmConfig.supportsFunctionCalling ? "tool_calling" : "xml"),
		llmOptions: {
			temperature: 0.1,
			max_tokens: 8192,
			...(options.llmOptions ?? {}),
		},
		llmConfig,
		onEvent: options.onEvent,
		promptPack,
		history: [],
		messages: persistedSession.messages,
		// Memory 状态
		memory: {
			lastConsolidatedMessageIndex: persistedSession.lastConsolidatedMessageIndex,
			compressor,
		},
	};
	appendConversationMessage(shared, {
		role: "user",
		content: options.prompt,
	});
	persistHistoryState(shared);

	try {
		emitAgentEvent(shared, {
			type: "task_started",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			prompt: shared.userQuery,
			workDir: shared.workingDir,
			maxSteps: shared.maxSteps,
		});
		if (shared.stopToken.stopped) {
			Tools.setTaskStatus(shared.taskId, "STOPPED");
			const result = { success: false as const, taskId: shared.taskId, message: getCancelledReason(shared), steps: shared.step };
			emitAgentEvent(shared, {
				type: "task_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				success: false,
				message: result.message,
				steps: result.steps,
			});
			return result;
		}
		Tools.setTaskStatus(shared.taskId, "RUNNING");
		const flow = new CodingAgentFlow();
		await flow.run(shared);
		if (shared.stopToken.stopped) {
			Tools.setTaskStatus(shared.taskId, "STOPPED");
			const result = { success: false as const, taskId: shared.taskId, message: getCancelledReason(shared), steps: shared.step };
			emitAgentEvent(shared, {
				type: "task_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				success: false,
				message: result.message,
				steps: result.steps,
			});
			return result;
		}
		if (shared.error) {
			Tools.setTaskStatus(shared.taskId, "FAILED");
			const result = {
				success: false as const,
				taskId: shared.taskId,
				message: shared.response && shared.response !== "" ? shared.response : shared.error,
				steps: shared.step,
			};
			emitAgentEvent(shared, {
				type: "task_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				success: false,
				message: result.message,
				steps: result.steps,
			});
			return result;
		}
		Tools.setTaskStatus(shared.taskId, "DONE");
		const result = {
			success: true,
			taskId: shared.taskId,
			message: shared.response || (shared.useChineseResponse ? "任务完成。" : "Task completed."),
			steps: shared.step,
		};
		emitAgentEvent(shared, {
			type: "task_finished",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			success: true,
			message: result.message,
			steps: result.steps,
		});
		return result;
	} catch (e) {
		Tools.setTaskStatus(shared.taskId, "FAILED");
		const result = { success: false as const, taskId: shared.taskId, message: tostring(e), steps: shared.step };
		emitAgentEvent(shared, {
			type: "task_finished",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			success: false,
			message: result.message,
			steps: result.steps,
		});
		return result;
	}
}

export function runCodingAgent(options: CodingAgentRunOptions, callback: (result: CodingAgentRunResult) => void) {
	runCodingAgentAsync(options).then(result => callback(result));
}
