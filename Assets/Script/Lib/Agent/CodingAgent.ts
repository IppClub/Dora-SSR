// @preview-file off clear
import { App, Path, json, Director, once, Content, wait, emit } from 'Dora';
import { Flow, Node } from 'Agent/flow';
import { callLLMStream, callLLM, Message, StopToken, Log, getActiveLLMConfig, estimateTextTokens, clipTextToTokenBudget } from 'Agent/Utils';
import type { LLMConfig } from 'Agent/Utils';
import * as Tools from 'Agent/Tools';
import * as yaml from 'yaml';
import { MemoryCompressor, DEFAULT_AGENT_PROMPT_PACK } from 'Agent/Memory';
import type { AgentPromptPack } from 'Agent/Memory';

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
	decisionMode?: "tool_calling" | "yaml";
	llmMaxTry?: number;
	llmOptions?: Record<string, unknown>;
	llmConfig?: LLMConfig;
	promptPack?: Partial<AgentPromptPack>;
	stopToken?: StopToken;
	sessionId?: number;
	onEvent?: (event: CodingAgentEvent) => void;
}

type AgentDecisionMode = "tool_calling" | "yaml";

export type AgentToolName =
	| "read_file"
	| "edit_file"
	| "delete_file"
	| "grep_files"
	| "search_dora_api"
	| "glob_files"
	| "build"
	| "message"
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
		type: "summary_stream";
		sessionId?: number;
		taskId: number;
		textDelta: string;
		fullText: string;
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
const DECISION_HISTORY_MAX_CHARS = 16000;
const SEARCH_DORA_API_LIMIT_MAX = 20;
const SEARCH_FILES_LIMIT_DEFAULT = 20;
const LIST_FILES_MAX_ENTRIES_DEFAULT = 200;
const SEARCH_PREVIEW_CONTEXT = 80;

export interface AgentActionRecord {
	step: number;
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
	// Memory 相关字段
	memory: {
		/** 上次压缩的历史索引 */
		lastConsolidatedIndex: number;

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
	const [text, err] = json.encode(value as object);
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
		sections.push(`role: ${message.role ?? ""}`);
		sections.push("");
		sections.push(message.content ?? "");
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
	const [text, err] = json.encode(value as object);
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
	if (charLen === false || charLen <= maxChars) return text;
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

function trimPromptContext(text: string, maxChars: number, label: string): string {
	if (text.length <= maxChars) return text;
	const keepHead = math.max(0, math.floor(maxChars * 0.35));
	const keepTail = math.max(0, maxChars - keepHead);
	const head = keepHead > 0 ? utf8TakeHead(text, keepHead) : "";
	const tail = keepTail > 0 ? utf8TakeTail(text, keepTail) : "";
	return `[history summary truncated for ${label}; showing head and tail within ${maxChars} chars]\n${head}\n...\n${tail}`;
}

function pushLimitedMatches(
	lines: string[],
	items: Record<string, unknown>[],
	maxItems: number,
	mapper: (item: Record<string, unknown>, index: number) => string
) {
	const shown = math.min(items.length, maxItems);
	for (let j = 0; j < shown; j++) {
		lines.push(mapper(items[j], j));
	}
	if (items.length > shown) {
		lines.push(`  ... ${items.length - shown} more omitted`);
	}
}

function formatHistorySummaryForDecision(history: AgentActionRecord[]): string {
	return trimPromptContext(formatHistorySummary(history), DECISION_HISTORY_MAX_CHARS, "decision");
}

function getDecisionSystemPrompt(shared?: AgentShared): string {
	return shared?.promptPack.agentIdentityPrompt ?? DEFAULT_AGENT_PROMPT_PACK.agentIdentityPrompt;
}

function getDecisionToolDefinitions(shared?: AgentShared): string {
	return replacePromptVars(
		shared?.promptPack.toolDefinitionsDetailed ?? DEFAULT_AGENT_PROMPT_PACK.toolDefinitionsDetailed,
		{ SEARCH_DORA_API_LIMIT_MAX: tostring(SEARCH_DORA_API_LIMIT_MAX) }
	);
}

async function maybeCompressHistory(shared: AgentShared): Promise<void> {
	const { memory } = shared;
	const maxRounds = memory.compressor.getMaxCompressionRounds();
	let changed = false;
	for (let round = 0; round < maxRounds; round++) {
		if (!memory.compressor.shouldCompress(
			shared.userQuery,
			shared.history,
			memory.lastConsolidatedIndex,
			getDecisionSystemPrompt(shared),
			getDecisionToolDefinitions(shared),
			formatHistorySummary
		)) {
			return;
		}
		const result = await memory.compressor.compress(
			shared.userQuery,
			shared.history,
			memory.lastConsolidatedIndex,
			shared.llmOptions,
			formatHistorySummary,
			shared.llmMaxTry,
			shared.decisionMode
		);
		if (!(result && result.success && result.compressedCount > 0)) {
			if (changed) {
				persistHistoryState(shared);
			}
			return;
		}
		memory.lastConsolidatedIndex += result.compressedCount;
		changed = true;
		Log("Info", `[Memory] Compressed ${result.compressedCount} history records (round ${round + 1})`);
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
		|| name === "message"
		|| name === "finish";
}

function formatHistorySummary(history: AgentActionRecord[]): string {
	if (history.length === 0) {
		return "No previous actions.";
	}
	const actions = history;
	const lines: string[] = [];
	lines.push("");
	for (let i = 0; i < actions.length; i++) {
		const action = actions[i];
		lines.push(`Action ${i + 1}:`);
		lines.push(`- Tool: ${action.tool}`);
		if (action.params && type(action.params) === "table" && next(action.params) !== undefined) {
			lines.push("- Parameters:");
			for (const key in action.params) {
				lines.push(`  - ${key}: ${summarizeUnknown(action.params[key], 2000)}`);
			}
		}
		if (action.result && type(action.result) === "table") {
			const result = action.result as Record<string, unknown>;
			const success = result.success === true;
			if (action.tool === "build") {
				if (!success && type(result.message) === "string") {
					lines.push("- Result: Failed");
					lines.push(`- Error: ${truncateText(result.message as string, 1200)}`);
				} else if (type(result.messages) === "table") {
					const messages = result.messages as Record<string, unknown>[];
					let successCount = 0;
					let failedCount = 0;
					for (let j = 0; j < messages.length; j++) {
						if (messages[j].success === true) successCount += 1;
						else failedCount += 1;
					}
					lines.push(`- Result: ${failedCount > 0 ? "Completed With Errors" : "Success"}`);
					lines.push(`- Build summary: ${successCount} succeeded, ${failedCount} failed`);
					if (messages.length > 0) {
						lines.push("- Build details:");
						const shown = math.min(messages.length, 12);
						for (let j = 0; j < shown; j++) {
							const item = messages[j];
							const file = type(item.file) === "string" ? (item.file as string) : "(unknown)";
							if (item.success === true) {
								lines.push(`  ${j + 1}. OK ${file}`);
							} else {
								const message = type(item.message) === "string"
									? truncateText(item.message as string, 400)
									: "build failed";
								lines.push(`  ${j + 1}. FAIL ${file}: ${message}`);
							}
						}
						if (messages.length > shown) {
							lines.push(`  ... ${messages.length - shown} more omitted`);
						}
					}
				} else {
					lines.push(`- Result: ${success ? "Success" : "Failed"}`);
				}
			} else if (action.tool === "read_file") {
				lines.push(`- Result: ${success ? "Success" : "Failed"}`);
				if (success && type(result.content) === "string") {
					lines.push("- Content:");
					lines.push(limitReadContentForHistory(result.content as string, action.tool));
					if (result.startLine !== undefined || result.endLine !== undefined || result.totalLines !== undefined) {
						lines.push(
							`- Range: ${result.startLine !== undefined ? tostring(result.startLine) : "?"}-${result.endLine !== undefined ? tostring(result.endLine) : "?"} / total ${result.totalLines !== undefined ? tostring(result.totalLines) : "?"}`
						);
					}
				} else if (!success && type(result.message) === "string") {
					lines.push(`- Error: ${truncateText(result.message as string, 600)}`);
				}
			} else if (action.tool === "grep_files") {
				lines.push(`- Result: ${success ? "Success" : "Failed"}`);
				if (success && type(result.results) === "table") {
					const matches = result.results as Record<string, unknown>[];
					const totalMatches = type(result.totalResults) === "number"
						? (result.totalResults as number)
						: matches.length;
					lines.push(`- Matches: ${totalMatches}`);
					lines.push("- Next: Immediately read the relevant file from the potentially related results to gather more information.");
					if (type(result.offset) === "number" && type(result.limit) === "number") {
						lines.push(`- Page: offset=${tostring(result.offset)} limit=${tostring(result.limit)}`);
					}
					if (result.hasMore === true && result.nextOffset !== undefined) {
						lines.push(`- More: continue with offset=${tostring(result.nextOffset)}`);
					}
					if (type(result.groupedResults) === "table") {
						const groups = result.groupedResults as Record<string, unknown>[];
						lines.push("- Groups:");
						pushLimitedMatches(lines, groups, HISTORY_SEARCH_FILES_MAX_MATCHES, (g, index) => {
							const file = type(g.file) === "string" ? (g.file as string) : "";
							const total = g.totalMatches !== undefined ? tostring(g.totalMatches) : "?";
							return `  ${index + 1}. ${file}: ${total} matches`;
						});
					} else {
						pushLimitedMatches(lines, matches, HISTORY_SEARCH_FILES_MAX_MATCHES, (m, index) => {
							const file = type(m.file) === "string" ? (m.file as string) : "";
							const line = m.line !== undefined ? tostring(m.line) : "";
							const content = type(m.content) === "string" ? (m.content as string) : summarizeUnknown(m, 240);
							return `  ${index + 1}. ${file}${line !== "" ? ":" + line : ""}: ${content}`;
						});
					}
				}
			} else if (action.tool === "search_dora_api") {
				lines.push(`- Result: ${success ? "Success" : "Failed"}`);
				if (success && type(result.results) === "table") {
					const hits = result.results as Record<string, unknown>[];
					const totalHits = type(result.totalResults) === "number"
						? (result.totalResults as number)
						: hits.length;
					lines.push(`- Matches: ${totalHits}`);
					pushLimitedMatches(lines, hits, HISTORY_SEARCH_DORA_API_MAX_MATCHES, (m, index) => {
						const file = type(m.file) === "string" ? (m.file as string) : "";
						const line = m.line !== undefined ? tostring(m.line) : "";
						const content = type(m.content) === "string" ? (m.content as string) : summarizeUnknown(m, 240);
						return `  ${index + 1}. ${file}${line !== "" ? ":" + line : ""}: ${content}`;
					});
				}
			} else if (action.tool === "edit_file") {
				lines.push(`- Result: ${success ? "Success" : "Failed"}`);
				if (success) {
					if (result.mode !== undefined) {
						lines.push(`- Mode: ${tostring(result.mode)}`);
					}
					if (result.replaced !== undefined) {
						lines.push(`- Replaced: ${tostring(result.replaced)}`);
					}
				}
			} else if (action.tool === "glob_files") {
				lines.push(`- Result: ${success ? "Success" : "Failed"}`);
				if (success && type(result.files) === "table") {
					const files = result.files as string[];
					const totalEntries = type(result.totalEntries) === "number"
						? (result.totalEntries as number)
						: files.length;
					lines.push(`- Entries: ${totalEntries}`);
					lines.push("- Next: Immediately read the relevant file snippets from the potentially related results to gather more information.");
					lines.push("- Directory structure:");
					if (files.length > 0) {
						const shown = math.min(files.length, HISTORY_LIST_FILES_MAX_ENTRIES);
						for (let j = 0; j < shown; j++) {
							lines.push(`  ${files[j]}`);
						}
						if (files.length > shown) {
							lines.push(`  ... ${files.length - shown} more omitted`);
						}
					} else {
						lines.push("  (Empty or inaccessible directory)");
					}
				}
			} else if (action.tool === "message") {
				lines.push(`- Result: ${success ? "Success" : "Failed"}`);
				if (success && type(result.message) === "string") {
					lines.push(`- Message: ${truncateText(result.message as string, 1200)}`);
				} else if (!success && type(result.message) === "string") {
					lines.push(`- Error: ${truncateText(result.message as string, 600)}`);
				}
			} else {
				lines.push(`- Result: ${success ? "Success" : "Failed"}`);
				lines.push(`- Detail: ${truncateText(toJson(result), 4000)}`);
			}
		} else if (action.result !== undefined) {
			lines.push(`- Result: ${summarizeUnknown(action.result, 3000)}`);
		} else {
			lines.push("- Result: pending");
		}
		if (i < actions.length - 1) lines.push("");
	}
	return lines.join("\n");
}

function persistHistoryState(shared: AgentShared): void {
	shared.memory.compressor.getStorage().writeSessionState(
		shared.history,
		shared.memory.lastConsolidatedIndex
	);
}

function extractYAMLFromText(text: string): string {
	const source = text.trim();
	const yamlFencePos = source.indexOf("```yaml");
	if (yamlFencePos >= 0) {
		const from = yamlFencePos + "```yaml".length;
		const end = source.indexOf("```", from);
		if (end > from) return source.slice(from, end).trim();
	}
	const ymlFencePos = source.indexOf("```yml");
	if (ymlFencePos >= 0) {
		const from = ymlFencePos + "```yml".length;
		const end = source.indexOf("```", from);
		if (end > from) return source.slice(from, end).trim();
	}
	const fencePos = source.indexOf("```");
	if (fencePos >= 0) {
		const firstLineEnd = source.indexOf("\n", fencePos);
		const end = source.indexOf("```", firstLineEnd >= 0 ? firstLineEnd + 1 : fencePos + 3);
		if (firstLineEnd >= 0 && end > firstLineEnd) {
			return source.slice(firstLineEnd + 1, end).trim();
		}
	}
	return source;
}

function parseYAMLObjectFromText(text: string): { success: true; obj: Record<string, unknown> } | { success: false; message: string } {
	const yamlText = extractYAMLFromText(text);
	const [obj, err] = yaml.parse(yamlText);
	if (obj === undefined || type(obj) !== "table") {
		return { success: false, message: `invalid yaml: ${tostring(err)}` };
	}
	return { success: true, obj: obj as Record<string, unknown> };
}

type LLMResult = {
	success: true;
	text: string
} | {
	success: false;
	message: string;
	text?: string
};

async function llm(shared: AgentShared, messages: Message[]): Promise<LLMResult> {
	const stepId = shared.step + 1;
	saveStepLLMDebugInput(shared, stepId, "decision_yaml", messages, shared.llmOptions);
	const res = await callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig);
	if (res.success) {
		const text = res.response.choices?.[0]?.message?.content;
		if (text) {
			saveStepLLMDebugOutput(shared, stepId, "decision_yaml", text, { success: true });
			return { success: true, text };
		} else {
			saveStepLLMDebugOutput(shared, stepId, "decision_yaml", "empty LLM response", { success: false });
			return { success: false, message: "empty LLM response" };
		}
	} else {
		saveStepLLMDebugOutput(shared, stepId, "decision_yaml", res.raw ?? res.message, { success: false });
		return { success: false, message: res.message };
	}
}

async function llmStream(shared: AgentShared, messages: Message[]): Promise<LLMResult> {
	let text = "";
	let cancelledReason: string | undefined;
	let done = false;

	if (shared.stopToken.stopped) {
		return { success: false, message: getCancelledReason(shared), text };
	}
	done = false;
	cancelledReason = undefined;
	text = "";
	const stepId = shared.step;
	saveStepLLMDebugInput(shared, stepId, "final_summary", messages, shared.llmOptions);
	callLLMStream(
		messages,
		shared.llmOptions,
		{
			id: undefined,
			stopToken: shared.stopToken,
			onData: (data) => {
				if (shared.stopToken.stopped) return true;
				const choice = data.choices && data.choices[0];
				const delta = choice && choice.delta;
				if (delta && type(delta.content) === "string") {
					const content = delta.content as string;
					text += content;
					emitAgentEvent(shared, {
						type: "summary_stream",
						sessionId: shared.sessionId,
						taskId: shared.taskId,
						textDelta: content,
						fullText: text,
					});
					const [res] = json.encode({ name: "LLMStream", content });
					if (res !== undefined) {
						emit("AppWS", "Send", res);
					}
				}
				return false;
			},
			onCancel: (reason) => {
				cancelledReason = reason;
				done = true;
			},
			onDone: () => {
				done = true;
			},
		},
		shared.llmConfig,
	);

	await new Promise<void>(resolve => {
		Director.systemScheduler.schedule(once(() => {
			wait(() => done || shared.stopToken.stopped);
			resolve();
		}));
	});
	if (shared.stopToken.stopped) {
		cancelledReason = getCancelledReason(shared);
	}

	if (!cancelledReason && text === "") {
		cancelledReason = "empty LLM output";
	}
	saveStepLLMDebugOutput(shared, stepId, "final_summary", cancelledReason ? `CANCELLED: ${cancelledReason}\n\n${text}` : text, {
		stream: true,
		cancelled: cancelledReason !== undefined,
	});

	if (cancelledReason) return { success: false, message: cancelledReason, text };
	return { success: true, text };
}

type DecisionSuccess = {
	success: true;
	tool: AgentToolName;
	params: Record<string, unknown>;
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
	if (tool === "message") {
		return { success: false, message: "message is not a callable tool" };
	}
	const params = type(rawObj.params) === "table" ? (rawObj.params as Record<string, unknown>) : {};
	return { success: true, tool, params };
}

function parseDecisionToolCall(functionName: string, rawObj: unknown): DecisionSuccess | DecisionFailure {
	if (!isKnownToolName(functionName)) {
		return { success: false, message: `unknown tool: ${functionName}` };
	}
	if (functionName === "message") {
		return { success: false, message: "message is not a callable tool" };
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
	if (tool === "finish") return { success: true, params };

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
		if (oldStr === newStr) {
			return { success: false, message: "edit_file old_str and new_str must be different" };
		}
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
	name: Exclude<AgentToolName, "message">,
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
			"Run build/checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). After one build completes, do not run build again unless files were edited or deleted. Read the result and then finish or take corrective action.",
			{
				path: { type: "string", description: "Optional workspace-relative file or directory to build." },
			}
		),
		createFunctionToolSchema(
			"finish",
			"End the task and let the agent summarize the outcome.",
			{}
		),
	];
}

function buildDecisionPrompt(shared: AgentShared, userQuery: string, historyText: string, memoryContext: string): string {
	const toolDefinitions = shared.decisionMode === "yaml"
		? replacePromptVars(shared.promptPack.toolDefinitionsDetailed, {
			SEARCH_DORA_API_LIMIT_MAX: tostring(SEARCH_DORA_API_LIMIT_MAX),
		})
		: "";
	const memorySection = memoryContext;
	const toolSection = toolDefinitions !== ""
		? `### Available Tools

${toolDefinitions}`
		: "";
	const staticPrompt = `${shared.promptPack.decisionIntroPrompt}

${memorySection}

### Current User Request

### Action History

${toolSection}

### Decision Rules

${shared.promptPack.decisionRulesPrompt}`;
	const contextWindow = math.max(4000, shared.llmConfig.contextWindow);
	const reservedOutputTokens = math.max(1024, math.floor(contextWindow * 0.2));
	const staticTokens = estimateTextTokens(staticPrompt);
	const dynamicBudget = math.max(1200, contextWindow - reservedOutputTokens - staticTokens - 256);
	const boundedUserQuery = clipTextToTokenBudget(userQuery, math.max(400, math.floor(dynamicBudget * 0.4)));
	const boundedHistory = clipTextToTokenBudget(historyText, math.max(400, math.floor(dynamicBudget * 0.35)));
	const boundedMemory = clipTextToTokenBudget(memoryContext, math.max(240, math.floor(dynamicBudget * 0.25)));
	const boundedMemorySection = boundedMemory !== ""
		? `${boundedMemory}
`
		: "";
	const toolSectionText = toolDefinitions !== ""
		? `### Available Tools

${toolDefinitions}
`
		: "";
	return `${shared.promptPack.decisionIntroPrompt}

${boundedMemorySection}### Current User Request

${boundedUserQuery}

### Action History

${boundedHistory}

${toolSectionText}### Decision Rules

${shared.promptPack.decisionRulesPrompt}`;
}

function normalizeLineEndings(text: string): string {
	return text.split("\r\n").join("\n").split("\r").join("\n");
}

function replaceAllAndCount(text: string, oldStr: string, newStr: string): { content: string; replaced: number } {
	text = normalizeLineEndings(text);
	oldStr = normalizeLineEndings(oldStr);
	newStr = normalizeLineEndings(newStr);
	if (oldStr === "") return { content: text, replaced: 0 };
	let count = 0;
	let from = 0;
	while (true) {
		const idx = text.indexOf(oldStr, from);
		if (idx < 0) break;
		count += 1;
		from = idx + oldStr.length;
	}
	if (count === 0) return { content: text, replaced: 0 };
	return {
		content: text.split(oldStr).join(newStr),
		replaced: count,
	};
}

class MainDecisionAgent extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ userQuery: string; history: AgentActionRecord[]; shared: AgentShared }> {
		if (shared.stopToken.stopped || shared.step >= shared.maxSteps) {
			return {
				userQuery: shared.userQuery,
				history: shared.history,
				shared,
			};
		}

		await maybeCompressHistory(shared);

		return {
			userQuery: shared.userQuery,
			history: shared.history,
			shared,
		};
	}

	private async callDecisionByToolCalling(
		shared: AgentShared,
		prompt: string,
		lastError?: string,
		attempt = 1,
		lastRaw?: string
	): Promise<DecisionResult | DecisionFailure> {
		if (shared.stopToken.stopped) {
			return { success: false, message: getCancelledReason(shared) };
		}
		Log("Info", `[CodingAgent] tool-calling decision start step=${shared.step + 1}${lastError ? ` retry_error=${lastError}` : ""}`);
		const tools = buildDecisionToolSchema();
		const messages: Message[] = [
			{
				role: "system",
				content: [
					shared.promptPack.agentIdentityPrompt,
					getReplyLanguageDirective(shared),
				].join("\n"),
			},
			{
				role: "user",
				content: lastError
					? `${prompt}\n\n${replacePromptVars(shared.promptPack.toolCallingRetryPrompt, { LAST_ERROR: lastError })}

Retry attempt: ${attempt}.
The next reply must differ from the previously rejected output.
${lastRaw && lastRaw !== "" ? `Last rejected output summary: ${truncateText(lastRaw, 300)}` : ""}`
				: prompt,
			},
		];
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
			const [rawObj, err] = json.decode(argsText);
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
		decision.reason = messageContent;
		decision.reasoningContent = reasoningContent;
		Log("Info", `[CodingAgent] tool-calling selected tool=${decision.tool}`);
		return decision;
	}

	async exec(input: { userQuery: string; history: AgentActionRecord[]; shared: AgentShared }): Promise<DecisionResult | DecisionFailure> {
		const shared = input.shared;
		if (shared.stopToken.stopped) {
			return { success: false, message: getCancelledReason(shared) };
		}
		if (shared.step >= shared.maxSteps) {
			Log("Warn", `[CodingAgent] maximum step limit reached step=${shared.step} max=${shared.maxSteps}`);
			return { success: false, message: getMaxStepsReachedReason(shared) };
		}
		const { memory } = shared;

		// 获取长期记忆上下文
		const memoryContext = memory.compressor
			.getStorage()
			.getMemoryContext();

		// 只使用未压缩的历史
		const uncompressedHistory = input.history.slice(memory.lastConsolidatedIndex);
		const historyText = formatHistorySummaryForDecision(uncompressedHistory);

		const prompt = buildDecisionPrompt(input.shared, input.userQuery, historyText, memoryContext);

		if (shared.decisionMode === "tool_calling") {
			Log("Info", `[CodingAgent] decision mode=tool_calling step=${shared.step + 1} history=${uncompressedHistory.length}`);
			let lastError = "tool calling validation failed";
			let lastRaw = "";
			for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
				Log("Info", `[CodingAgent] tool-calling attempt=${attempt + 1}`);
				const decision = await this.callDecisionByToolCalling(
					shared,
					prompt,
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

		const yamlPrompt = `${prompt}

${shared.promptPack.yamlDecisionFormatPrompt}
- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.
- Keep params shallow and valid for the selected tool.
- Use tabs for all indentation, never spaces.
If no more actions are needed, use tool: finish.`;

		let lastError = "yaml validation failed";
		let lastRaw = "";
		for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
			const feedback = attempt > 0
				? `\n\nPrevious response was invalid (${lastError}). Retry attempt: ${attempt + 1}. Return exactly one valid YAML object only and keep YAML indentation strictly consistent. The next reply must differ from the rejected one.${lastRaw !== "" ? `\nLast rejected output summary: ${truncateText(lastRaw, 300)}` : ""}`
				: "";
			const messages: Message[] = [{ role: "user", content: `${yamlPrompt}${feedback}` }];
			const llmRes = await llm(shared, messages);
			if (shared.stopToken.stopped) {
				return { success: false, message: getCancelledReason(shared) };
			}
			if (!llmRes.success) {
				lastError = llmRes.message;
				continue;
			}
			lastRaw = llmRes.text;
			const parsed = parseYAMLObjectFromText(llmRes.text);
			if (!parsed.success) {
				lastError = parsed.message;
				continue;
			}
			const decision = parseDecisionObject(parsed.obj);
			if (!decision.success) {
				lastError = decision.message;
				continue;
			}
			const validation = validateDecision(decision.tool, decision.params);
			if (!validation.success) {
				lastError = validation.message;
				continue;
			}
			decision.params = validation.params;
			return decision;
		}
		return { success: false, message: `cannot produce valid decision yaml: ${lastError}; last_output=${truncateText(lastRaw, 400)}` };
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const result = execRes as DecisionResult | { success: false; message: string };
		if (!result.success) {
			shared.error = result.message;
			return "error";
		}
		if (result.directSummary && result.directSummary !== "") {
			shared.response = result.directSummary;
			shared.done = true;
			persistHistoryState(shared);
			return undefined;
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
		shared.history.push({
			step: shared.history.length + 1,
			tool: result.tool,
			reason: result.reason ?? "",
			reasoningContent: result.reasoningContent,
			params: result.params,
			timestamp: os.date("!%Y-%m-%dT%H:%M:%SZ"),
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
		if (oldStr === newStr) throw new Error("old_str and new_str must be different");
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
				replaced: 0,
				checkpointId: createRes.checkpointId,
				checkpointSeq: createRes.checkpointSeq,
				files: [{ path: input.path, op: "create" as const }],
			};
		}
		if (input.oldStr === "") {
			return { success: false, message: "old_str must be non-empty when editing an existing file" };
		}

		const replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr);
		if (replaceRes.replaced === 0) {
			return { success: false, message: "old_str not found in file" };
		}
		if (replaceRes.content === readRes.content) {
			return {
				success: true,
				changed: false,
				mode: "no_change",
				replaced: replaceRes.replaced,
			};
		}

		const applyRes = Tools.applyFileChanges(input.taskId, input.workDir, [{ path: input.path, op: "write", content: replaceRes.content }], {
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
			replaced: replaceRes.replaced,
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
				&& type(result.checkpointId) === "number"
				&& type(result.checkpointSeq) === "number"
				&& type(result.files) === "table") {
				emitAgentEvent(shared, {
					type: "checkpoint_created",
					sessionId: shared.sessionId,
					taskId: shared.taskId,
					step: shared.step + 1,
					tool: last.tool,
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

class FormatResponseNode extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ history: AgentActionRecord[]; shared: AgentShared }> {
		const last = shared.history[shared.history.length - 1];
		if (last && last.tool === "finish") {
			emitAgentEvent(shared, {
				type: "tool_started",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step + 1,
				tool: last.tool,
			});
		}
		return { history: shared.history, shared };
	}

	async exec(input: { history: AgentActionRecord[]; shared: AgentShared }): Promise<string> {
		if (input.shared.stopToken.stopped) {
			return getCancelledReason(input.shared);
		}
		const failureNote = input.shared.error && input.shared.error !== ""
			? (input.shared.useChineseResponse
				? `\n\n本次任务因以下错误结束，请在总结中明确说明：\n${input.shared.error}`
				: `\n\nThis task ended with the following error. Make sure the summary states it clearly:\n${input.shared.error}`)
			: "";
		const history = input.history;
		if (history.length === 0) {
			if (input.shared.error && input.shared.error !== "") {
				return getFailureSummaryFallback(input.shared, input.shared.error);
			}
			return "No actions were performed.";
		}
		const summary = formatHistorySummary(history);
		const staticPrompt = replacePromptVars(input.shared.promptPack.finalSummaryPrompt, {
			SUMMARY: "",
			LANGUAGE_DIRECTIVE: getReplyLanguageDirective(input.shared),
		});
		const contextWindow = math.max(4000, input.shared.llmConfig.contextWindow);
		const reservedOutputTokens = math.max(1024, math.floor(contextWindow * 0.2));
		const staticTokens = estimateTextTokens(staticPrompt);
		const failureTokens = estimateTextTokens(failureNote);
		const summaryBudget = math.max(400, contextWindow - reservedOutputTokens - staticTokens - failureTokens - 256);
		const boundedSummary = clipTextToTokenBudget(summary, summaryBudget);
		const prompt = replacePromptVars(input.shared.promptPack.finalSummaryPrompt, {
			SUMMARY: boundedSummary,
			LANGUAGE_DIRECTIVE: getReplyLanguageDirective(input.shared),
		}) + failureNote;
		let res: LLMResult | undefined;
		for (let i = 0; i < input.shared.llmMaxTry; i++) {
			res = await llmStream(input.shared, [{ role: "user", content: prompt }]);
			if (res.success) break;
		}
		if (!res) {
			return input.shared.error && input.shared.error !== ""
				? getFailureSummaryFallback(input.shared, input.shared.error)
				: (input.shared.useChineseResponse
					? `执行完成，但生成总结失败。`
					: `Completed, but failed to generate summary.`);
		}
		if (!res.success) {
			return input.shared.error && input.shared.error !== ""
				? getFailureSummaryFallback(input.shared, input.shared.error)
				: (input.shared.useChineseResponse
					? `执行完成，但生成总结失败：${res.message}`
					: `Completed, but failed to generate summary: ${res.message}`);
		}
		return res.text;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last && last.tool === "finish") {
			last.result = { success: true, message: execRes as string };
			emitAgentEvent(shared, {
				type: "tool_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step + 1,
				tool: last.tool,
				result: last.result,
			});
			shared.step += 1;
		}
		shared.response = execRes as string;
		shared.done = true;
		persistHistoryState(shared);
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
		const format = new FormatResponseNode(1, 0);

		main.on("read_file", read);
		main.on("grep_files", search);
		main.on("search_dora_api", searchDora);
		main.on("glob_files", list);
		main.on("delete_file", del);
		main.on("build", build);
		main.on("edit_file", edit);
		main.on("finish", format);
		main.on("error", format);

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
		decisionMode: options.decisionMode === "yaml" ? "yaml" : "tool_calling",
		llmOptions: {
			temperature: 0.1,
			max_tokens: 8192,
			...(options.llmOptions ?? {}),
		},
		llmConfig,
		onEvent: options.onEvent,
		promptPack,
		history: persistedSession.history,
		// Memory 状态
		memory: {
			lastConsolidatedIndex: persistedSession.lastConsolidatedIndex,
			compressor,
		},
	};

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
