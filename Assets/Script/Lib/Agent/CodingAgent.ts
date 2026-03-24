// @preview-file off clear
import { json, Director, once, Content, wait, emit } from 'Dora';
import { Flow, Node } from 'Agent/flow';
import { callLLMStream, callLLM, Message, StopToken, Log, getActiveLLMConfig } from 'Agent/Utils';
import type { LLMConfig } from 'Agent/Utils';
import * as Tools from 'Agent/Tools';
import * as yaml from 'yaml';
import { MemoryCompressor, DEFAULT_AGENT_PROMPT } from 'Agent/Memory';

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
	stopToken?: StopToken;
	sessionId?: number;
	onEvent?: (event: CodingAgentEvent) => void;
}

type AgentDecisionMode = "tool_calling" | "yaml";

export type AgentToolName =
	| "read_file"
	| "read_file_range"
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
		reason: string;
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
	history: AgentActionRecord[];
	lastDecision?: {
		tool: AgentToolName;
		reason: string;
		params: Record<string, unknown>;
	};
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
		? "Use Simplified Chinese for natural-language fields (reason/message/summary)."
		: "Use English for natural-language fields (reason/message/summary).";
}

function limitReadContentForHistory(content: string, tool: "read_file" | "read_file_range"): string {
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
	const hint = tool === "read_file"
		? "Use read_file_range for the exact section you need."
		: "Narrow the requested line range.";
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
	if ((tool !== "read_file" && tool !== "read_file_range") || result.success !== true || type(result.content) !== "string") {
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

function getDecisionSystemPrompt(): string {
	return "You are a coding assistant that helps modify and navigate code.";
}

function getDecisionToolDefinitions(): string {
	return `Available tools:
1. read_file: Read content from a file with pagination
1b. read_file_range: Read specific line range from a file
2. edit_file: Make changes to a file
3. delete_file: Remove a file
4. grep_files: Search text patterns inside files
5. glob_files: Enumerate files under a directory with optional glob filters
6. search_dora_api: Search Dora SSR game engine docs and tutorials
7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn
8. finish: End and summarize`;
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
			getDecisionSystemPrompt(),
			getDecisionToolDefinitions(),
			formatHistorySummary
		)) {
			return;
		}
		const result = await memory.compressor.compress(
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
		|| name === "read_file_range"
		|| name === "edit_file"
		|| name === "delete_file"
		|| name === "grep_files"
		|| name === "search_dora_api"
		|| name === "glob_files"
		|| name === "build"
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
		lines.push(`- Reason: ${action.reason}`);
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
			} else if (action.tool === "read_file" || action.tool === "read_file_range") {
				lines.push(`- Result: ${success ? "Success" : "Failed"}`);
				if (success && type(result.content) === "string") {
					lines.push(`- Content: ${limitReadContentForHistory(result.content as string, action.tool)}`);
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
	const res = await callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig);
	if (res.success) {
		const text = res.response.choices?.[0]?.message?.content;
		if (text) {
			return { success: true, text };
		} else {
			return { success: false, message: "empty LLM response" };
		}
	} else {
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

	if (cancelledReason) return { success: false, message: cancelledReason, text };
	return { success: true, text };
}

function parseDecisionObject(rawObj: Record<string, unknown>): { success: true; tool: AgentToolName; reason: string; params: Record<string, unknown> } | { success: false; message: string } {
	if (type(rawObj.tool) !== "string") return { success: false, message: "missing tool" };
	const tool = rawObj.tool as string;
	if (!isKnownToolName(tool)) {
		return { success: false, message: `unknown tool: ${tool}` };
	}
	const reason = type(rawObj.reason) === "string" ? (rawObj.reason as string) : "";
	const params = type(rawObj.params) === "table" ? (rawObj.params as Record<string, unknown>) : {};
	return { success: true, tool, reason, params };
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
	params: Record<string, unknown>,
	history?: AgentActionRecord[]
): { success: true; params: Record<string, unknown> } | { success: false; message: string } {
	if (tool === "finish") return { success: true, params };

	if (tool === "read_file") {
		const path = getDecisionPath(params);
		if (path === "") return { success: false, message: "read_file requires path" };
		params.path = path;
		params.offset = clampIntegerParam(params.offset, 1, 1);
		params.limit = clampIntegerParam(params.limit, READ_FILE_DEFAULT_LIMIT, 1);
		return { success: true, params };
	}

	if (tool === "read_file_range") {
		const path = getDecisionPath(params);
		if (path === "") return { success: false, message: "read_file_range requires path" };
		const startLine = clampIntegerParam(params.startLine, 1, 1);
		const endLineRaw = params.endLine ?? startLine;
		const endLine = clampIntegerParam(endLineRaw, startLine, startLine);
		params.path = path;
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

function buildDecisionToolSchema() {
	return [{
		type: "function" as const,
		function: {
			name: "next_step",
			description: "Choose the next coding action for the agent.",
			parameters: {
				type: "object",
				properties: {
					tool: {
						type: "string",
						enum: [
							"read_file",
							"read_file_range",
							"edit_file",
							"delete_file",
							"grep_files",
							"search_dora_api",
							"glob_files",
							"build",
							"finish",
						],
					},
					reason: {
						type: "string",
						description: "Explain why this is the next best action.",
					},
					params: {
						type: "object",
						description: "Shallow parameter object for the selected tool.",
						properties: {
							path: { type: "string" },
							target_file: { type: "string" },
							old_str: { type: "string" },
							new_str: { type: "string" },
							pattern: { type: "string" },
							globs: {
								type: "array",
								items: { type: "string" },
							},
							useRegex: { type: "boolean" },
							caseSensitive: { type: "boolean" },
							offset: { type: "number" },
							groupByFile: { type: "boolean" },
							docSource: {
								type: "string",
								enum: ["api", "tutorial"],
							},
							programmingLanguage: {
								type: "string",
								enum: ["ts", "tsx", "lua", "yue", "teal", "tl", "wa"],
							},
							limit: { type: "number" },
							startLine: { type: "number" },
							endLine: { type: "number" },
							maxEntries: { type: "number" },
						},
					},
				},
				required: ["tool", "reason", "params"],
			},
		},
	}];
}

function buildDecisionPrompt(shared: AgentShared, userQuery: string, historyText: string, memoryContext: string, agentPrompt: string): string {
	return `${agentPrompt || DEFAULT_AGENT_PROMPT}
Given the request and action history, decide which tool to use next.

${memoryContext}

User request: ${userQuery}

Here are the actions you performed:
${historyText}

Available tools:
1. read_file: Read content from a file with pagination
	- Parameters: path (workspace-relative), offset(optional), limit(optional)
	- Prefer small reads and continue with a new offset (>= 1) when needed.
1b. read_file_range: Read specific line range from a file
	- Parameters: path, startLine, endLine
	- Line starts with 1.

2. edit_file: Make changes to a file
	- Parameters: path, old_str, new_str
		- Rules:
			- old_str and new_str MUST be different
			- old_str must match existing text exactly when it is non-empty
			- If file doesn't exist, set old_str to empty string to create it with new_str

3. delete_file: Remove a file
	- Parameters: target_file

4. grep_files: Search text patterns inside files
	- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)
	- \`path\` may point to either a directory or a single file.
	- This is content search (grep), not filename search.
	- \`pattern\` matches file contents. \`globs\` only restrict which files are searched.
	- \`useRegex\` defaults to false. Set \`useRegex=true\` when \`pattern\` is a regular expression such as \`^title:\`.
	- \`caseSensitive\` defaults to false.
	- Use \`|\` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.
	- Search results are intentionally capped. Refine the pattern or read a specific file next.
	- Use \`offset\` to continue browsing later pages of the same search.
	- Use \`groupByFile=true\` to rank candidate files before drilling into one file.

5. glob_files: Enumerate files under a directory
	- Parameters: path, globs(optional), maxEntries(optional)
	- Use this to discover files by path, extension, or glob pattern.
	- Directory listings are intentionally capped. Narrow the path before expanding further.

6. search_dora_api: Search Dora SSR game engine docs and tutorials
	- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)
	- \`docSource\` defaults to \`api\`. Use \`tutorial\` to search teaching docs.
	- Use \`|\` inside pattern to separate alternative queries; results are merged by union (OR), not AND.
	- \`useRegex\` defaults to false whenever supported by a search tool.
	- \`limit\` restricts each individual pattern search and must be <= ${SEARCH_DORA_API_LIMIT_MAX}.

7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn
	- Parameters: path(optional)
	- After one build completes, do not run build again unless files were edited/deleted. Read the result and then finish or take corrective action.

8. finish: End and summarize
	- Parameters: {}

Decision rules:
- Choose exactly one next action.
- Keep params shallow and valid for the selected tool.
- Prefer reading/searching before editing when information is missing.
- After any search tool returns candidate files or docs, use read_file or read_file_range to inspect search result details instead of repeatedly broadening search.
- Use glob_files to discover candidate files. Use grep_files only when you need to search file contents.
- Use finish only when no more actions are needed.
${getReplyLanguageDirective(shared)}`;
}

function replaceAllAndCount(text: string, oldStr: string, newStr: string): { content: string; replaced: number } {
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

	private getSystemPrompt(): string {
		return getDecisionSystemPrompt();
	}

	private getToolDefinitions(): string {
		return getDecisionToolDefinitions();
	}

	private async callDecisionByToolCalling(
		shared: AgentShared,
		prompt: string,
		lastError?: string
	): Promise<{ success: true; tool: AgentToolName; reason: string; params: Record<string, unknown> } | { success: false; message: string; raw?: string }> {
		if (shared.stopToken.stopped) {
			return { success: false, message: getCancelledReason(shared) };
		}
		Log("Info", `[CodingAgent] tool-calling decision start step=${shared.step + 1}${lastError ? ` retry_error=${lastError}` : ""}`);
		const tools = buildDecisionToolSchema();
		const messages: Message[] = [
			{
				role: "system",
				content: [
					"You are a coding assistant that must decide the next action by calling the next_step tool exactly once.",
					"Do not answer with plain text.",
					getReplyLanguageDirective(shared),
				].join("\n"),
			},
			{
				role: "user",
				content: lastError
					? `${prompt}\n\nPrevious tool call was invalid (${lastError}). Retry with one valid next_step tool call only.`
					: prompt,
			},
		];
		const res = await callLLM(messages, {
			...shared.llmOptions,
			tools,
			tool_choice: { type: "function", function: { name: "next_step" } },
		}, shared.stopToken, shared.llmConfig);
		if (shared.stopToken.stopped) {
			return { success: false, message: getCancelledReason(shared) };
		}
		if (!res.success) {
			Log("Error", `[CodingAgent] tool-calling request failed: ${res.message}`);
			return { success: false, message: res.message, raw: res.raw };
		}
		const choice = res.response.choices && res.response.choices[0];
		const message = choice && choice.message;
		const toolCalls = message && message.tool_calls;
		const toolCall = toolCalls && toolCalls[0];
		const fn = toolCall && toolCall.function;
		const messageContent = message && type(message.content) === "string" ? (message.content as string) : undefined;
		Log("Info", `[CodingAgent] tool-calling response finish_reason=${choice && choice.finish_reason ? choice.finish_reason : "unknown"} tool_calls=${toolCalls ? toolCalls.length : 0} content_len=${messageContent ? messageContent.length : 0}`);
		if (!fn || fn.name !== "next_step") {
			Log("Error", `[CodingAgent] missing next_step tool call`);
			return {
				success: false,
				message: "missing next_step tool call",
				raw: messageContent,
			};
		}
		const argsText = typeof fn.arguments === "string" ? fn.arguments : "";
		Log("Info", `[CodingAgent] tool-calling function=${fn.name} args_len=${argsText.length}`);
		if (argsText.trim() === "") {
			Log("Error", `[CodingAgent] empty next_step tool arguments`);
			return { success: false, message: "empty next_step tool arguments" };
		}
		const [rawObj, err] = json.decode(argsText);
		if (err !== undefined || rawObj === undefined || type(rawObj) !== "table") {
			Log("Error", `[CodingAgent] invalid next_step tool arguments JSON: ${tostring(err)}`);
			return {
				success: false,
				message: `invalid next_step tool arguments: ${tostring(err)}`,
				raw: argsText,
			};
		}
		const decision = parseDecisionObject(rawObj as Record<string, unknown>);
		if (!decision.success) {
			Log("Error", `[CodingAgent] invalid next_step tool arguments schema: ${decision.message}`);
			return {
				success: false,
				message: decision.message,
				raw: argsText,
			};
		}
		const validation = validateDecision(decision.tool, decision.params, shared.history);
		if (!validation.success) {
			Log("Error", `[CodingAgent] invalid next_step tool arguments values: ${validation.message}`);
			return {
				success: false,
				message: validation.message,
				raw: argsText,
			};
		}
		decision.params = validation.params;
		Log("Info", `[CodingAgent] tool-calling selected tool=${decision.tool} reason_len=${decision.reason.length}`);
		return decision;
	}

	async exec(input: { userQuery: string; history: AgentActionRecord[]; shared: AgentShared }): Promise<{ success: true; tool: AgentToolName; reason: string; params: Record<string, unknown> } | { success: false; message: string }> {
		const shared = input.shared;
		if (shared.stopToken.stopped) {
			return { success: false, message: getCancelledReason(shared) };
		}
		const { memory } = shared;

		// 获取长期记忆上下文
		const memoryContext = memory.compressor
			.getStorage()
			.getMemoryContext();
		const agentPrompt = memory.compressor
			.getStorage()
			.readAgentPrompt();

		// 只使用未压缩的历史
		const uncompressedHistory = input.history.slice(memory.lastConsolidatedIndex);
		const historyText = formatHistorySummaryForDecision(uncompressedHistory);

		const prompt = buildDecisionPrompt(input.shared, input.userQuery, historyText, memoryContext, agentPrompt);

		if (shared.decisionMode === "tool_calling") {
			Log("Info", `[CodingAgent] decision mode=tool_calling step=${shared.step + 1} history=${uncompressedHistory.length}`);
			let lastError = "tool calling validation failed";
			let lastRaw = "";
			for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
				Log("Info", `[CodingAgent] tool-calling attempt=${attempt + 1}`);
				const decision = await this.callDecisionByToolCalling(
					shared,
					prompt,
					attempt > 0 ? lastError : undefined
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

Respond with one YAML object:
\`\`\`yaml
'tool: "edit_file"
reason: |-
	A readable multi-line explanation is allowed.
	Keep indentation consistent.
params:
	path: "relative/path.ts"
	old_str: |-
		function oldName() {
			print("old");
		}
	new_str: |-
		function newName() {
			print("hello");
		}
\`\`\`
Strict YAML formatting rules:
- Return YAML only, no prose before/after.
- Use exactly one YAML object with keys: tool, reason, params.
- Multi-line strings are allowed using block scalars (\`|\`, \`|-\`, \`>\`).
- If using a block scalar, all content lines must be indented consistently with tabs.
- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.
- Keep params shallow and valid for the selected tool.
- Use tabs for all indentation, never spaces.
If no more actions are needed, use tool: finish.`;

		let lastError = "yaml validation failed";
		let lastRaw = "";
		for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
			const feedback = attempt > 0
				? `\n\nPrevious response was invalid (${lastError}). Return exactly one valid YAML object only and keep YAML indentation strictly consistent.`
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
			const validation = validateDecision(decision.tool, decision.params, input.history);
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
		const result = execRes as { success: true; tool: AgentToolName; reason: string; params: Record<string, unknown> } | { success: false; message: string };
		if (!result.success) {
			shared.error = result.message;
			return "error";
		}
		emitAgentEvent(shared, {
			type: "decision_made",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: shared.step + 1,
			tool: result.tool,
			reason: result.reason,
			params: result.params,
		});
		shared.lastDecision = {
			tool: result.tool,
			reason: result.reason,
			params: result.params,
		};
		shared.history.push({
			step: shared.history.length + 1,
			tool: result.tool,
			reason: result.reason,
			params: result.params,
			timestamp: os.date("!%Y-%m-%dT%H:%M:%SZ"),
		});
		persistHistoryState(shared);
		return result.tool;
	}
}

class ReadFileAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ path: string; range?: { startLine: number; endLine: number }; offset?: number; limit?: number; tool: AgentToolName; workDir: string; docLanguage: Tools.DoraAPIDocLanguage }> {
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
		if (last.tool === "read_file_range") {
			return {
				path,
				tool: last.tool,
				workDir: shared.workingDir,
				docLanguage: shared.useChineseResponse ? "zh" : "en",
				range: {
					startLine: Number(last.params.startLine ?? 1),
					endLine: Number(last.params.endLine ?? last.params.startLine ?? 1),
				},
			};
		}
		return {
			path,
			tool: "read_file",
			workDir: shared.workingDir,
			docLanguage: shared.useChineseResponse ? "zh" : "en",
			offset: Number(last.params.offset ?? 1),
			limit: Number(last.params.limit ?? READ_FILE_DEFAULT_LIMIT),
		};
	}

	async exec(input: { path: string; range?: { startLine: number; endLine: number }; offset?: number; limit?: number; tool: AgentToolName; workDir: string; docLanguage: Tools.DoraAPIDocLanguage }): Promise<Record<string, unknown>> {
		if (input.tool === "read_file_range" && input.range) {
			return Tools.readFileRange(input.workDir, input.path, input.range.startLine, input.range.endLine, input.docLanguage) as unknown as Record<string, unknown>;
		}
		return Tools.readFile(
			input.workDir,
			input.path,
			Number(input.offset ?? 1),
			Number(input.limit ?? READ_FILE_DEFAULT_LIMIT),
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
			const followupHint = shared.useChineseResponse
				? "然后读取搜索结果中相关的文件来了解详情。"
				: "Then read the relevant files from the search results to inspect the details.";
			if (!last.reason.includes(followupHint)) {
				last.reason = `${last.reason} ${followupHint}`.trim();
			}
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
			const followupHint = shared.useChineseResponse
				? "构建已完成，将根据结果做后续处理，不再重复构建。"
				: "Build completed. Shall handle the result instead of building again.";
			const {reason} = last;
			last.reason = last.reason && last.reason !== ""
				? `${last.reason}\n${followupHint}`
				: followupHint;
			last.result = execRes as Record<string, unknown>;
			emitAgentEvent(shared, {
				type: "tool_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step + 1,
				tool: last.tool,
				reason,
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
		const history = input.history;
		if (history.length === 0) {
			return "No actions were performed.";
		}
		const summary = formatHistorySummary(history);
		const prompt = `You are a coding assistant. Summarize what you did for the user.

Here are the actions you performed:
${summary}

Generate a concise response that explains:
1. What actions were taken
2. What was found or modified
3. Any next steps

IMPORTANT:
- Focus on outcomes, not tool names.
- Speak directly to the user.
${getReplyLanguageDirective(input.shared)}`;
		let res: LLMResult | undefined;
		for (let i = 0; i < input.shared.llmMaxTry; i++) {
			res = await llmStream(input.shared, [{ role: "user", content: prompt }]);
			if (res.success) break;
		}
		if (!res) return input.shared.useChineseResponse
				? `执行完成，但生成总结失败。`
				: `Completed, but failed to generate summary.`;
		if (!res.success) {
			return input.shared.useChineseResponse
				? `执行完成，但生成总结失败：${res.message}`
				: `Completed, but failed to generate summary: ${res.message}`;
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
		main.on("read_file_range", read);
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
	});
	const persistedSession = compressor.getStorage().readSessionState();

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
			temperature: 0.2,
			...(options.llmOptions ?? {}),
		},
		llmConfig,
		onEvent: options.onEvent,
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
			const result = { success: false as const, taskId: shared.taskId, message: shared.error, steps: shared.step };
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
