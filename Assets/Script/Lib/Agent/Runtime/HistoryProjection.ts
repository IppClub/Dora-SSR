import * as AgentUtils from 'Agent/Utils';
import type { Message } from 'Agent/Utils';
import * as AgentConfig from 'Agent/Config';
import type { AgentToolName } from 'Agent/Tool/Registry';

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object";
}

function isArray(value: unknown): value is unknown[] {
	return Array.isArray(value);
}

export function toJson(value: unknown, emptyAsArray: boolean): string {
	const [text, err] = AgentUtils.safeJsonEncode(value as object, false, emptyAsArray);
	if (text !== undefined) return text;
	return `{ "error": "json_encode_failed", "message": "${tostring(err)}" }`;
}

export function truncateText(text: string, maxLen: number): string {
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
	const [charLength] = utf8.len(text);
	if (charLength === undefined || charLength <= maxChars) return text;
	const startPos = utf8.offset(text, math.max(1, charLength - maxChars + 1));
	if (startPos === undefined) return text;
	return string.sub(text, startPos);
}

function truncateHistoryText(text: string, maxChars: number, label: string): string {
	if (maxChars <= 0 || text === "") return "";
	if (text.length <= maxChars) return text;
	const marker = `\n...[${label} truncated; ${text.length} chars total]...\n`;
	const remaining = math.max(0, maxChars - marker.length);
	const headChars = math.floor(remaining * 0.6);
	const tailChars = remaining - headChars;
	return `${utf8TakeHead(text, headChars)}${marker}${utf8TakeTail(text, tailChars)}`;
}

function limitReadContentForHistory(
	content: string,
	startLine: number,
	endLine: number,
	totalLines: number,
	maxChars: number,
	maxLines: number,
	label: string
): {
	content: string;
	truncated: boolean;
	retainedStartLine: number;
	retainedEndLine: number;
	nextStartLine?: number;
	partialLine?: number;
} {
	const sourceLineCount = endLine >= startLine ? endLine - startLine + 1 : 0;
	const contentLines = content.split("\n");
	const availableSourceLines = math.min(sourceLineCount, contentLines.length);
	if (content.length <= maxChars && availableSourceLines <= maxLines) {
		return {
			content,
			truncated: false,
			retainedStartLine: startLine,
			retainedEndLine: endLine,
		};
	}

	// Reserve room for an explicit continuation marker, then retain only whole
	// source lines. The read_file footer is intentionally excluded from the
	// source-line count and replaced with an accurate history marker.
	const contentBudget = math.max(0, maxChars - 240);
	const candidateLines = math.min(availableSourceLines, maxLines);
	const retainedLines: string[] = [];
	let retainedChars = 0;
	for (let i = 0; i < candidateLines; i++) {
		const line = contentLines[i];
		const nextChars = retainedChars + line.length + (retainedLines.length > 0 ? 1 : 0);
		if (nextChars > contentBudget) break;
		retainedLines.push(line);
		retainedChars = nextChars;
	}

	let retainedEndLine = startLine + retainedLines.length - 1;
	let partialLine: number | undefined;
	let retainedContent = retainedLines.join("\n");
	if (retainedLines.length === 0 && candidateLines > 0) {
		partialLine = startLine;
		retainedEndLine = startLine - 1;
		retainedContent = utf8TakeHead(contentLines[0], contentBudget);
	}
	const nextStartLine = retainedEndLine < endLine ? retainedEndLine + 1 : undefined;
	const retainedRange = retainedLines.length > 0
		? `complete lines ${startLine}-${retainedEndLine}`
		: partialLine !== undefined
			? `a partial preview of overlong line ${partialLine}`
			: "no source lines";
	const continuation = nextStartLine !== undefined
		? ` Use read_file with startLine=${nextStartLine} and a narrower endLine to continue.`
		: "";
	const marker = `[${label} retained ${retainedRange} of requested lines ${startLine}-${endLine} (${totalLines} lines total).${continuation}]`;
	return {
		content: retainedContent === "" ? marker : `${retainedContent}\n\n${marker}`,
		truncated: true,
		retainedStartLine: startLine,
		retainedEndLine,
		nextStartLine,
		partialLine,
	};
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

function sanitizeOneReadResultForHistory(result: Record<string, unknown>): Record<string, unknown> {
	if (result.success !== true || typeof result.content !== "string") return result;
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	const startLine = typeof result.startLine === "number" ? result.startLine : 1;
	const endLine = typeof result.endLine === "number" ? result.endLine : startLine;
	const totalLines = typeof result.totalLines === "number" ? result.totalLines : endLine;
	const limited = limitReadContentForHistory(
		result.content,
		startLine,
		endLine,
		totalLines,
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars,
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines,
		"read_file history"
	);
	clone.content = limited.content;
	if (limited.truncated) {
		clone.historyContentTruncated = true;
		clone.historyRetainedStartLine = limited.retainedStartLine;
		clone.historyRetainedEndLine = limited.retainedEndLine;
		if (limited.nextStartLine !== undefined) clone.historyNextStartLine = limited.nextStartLine;
		if (limited.partialLine !== undefined) clone.historyPartialLine = limited.partialLine;
	}
	return clone;
}

export function sanitizeReadResultForHistory(tool: AgentToolName, result: Record<string, unknown>): Record<string, unknown> {
	if (tool !== "read_file") return result;
	if (!Array.isArray(result.results)) return sanitizeOneReadResultForHistory(result);
	const clone: Record<string, unknown> = {};
	for (const key in result) clone[key] = result[key];
	clone.results = result.results.map(item => isRecord(item) && !isArray(item)
		? sanitizeOneReadResultForHistory(item)
		: item);
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
			content: typeof row.content === "string"
				? truncateText(row.content, 240)
				: row.content,
		});
	}
	return out;
}

export function sanitizeSearchResultForHistory(
	tool: AgentToolName,
	result: Record<string, unknown>
): Record<string, unknown> {
	if (result.success !== true || !isArray(result.results)) return result;
	if (tool !== "grep_files" && tool !== "search_dora_doc") return result;
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	const maxItems = tool === "grep_files" ? AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches : AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches;
	clone.results = sanitizeSearchMatchesForHistory(
		result.results as Record<string, unknown>[],
		maxItems
	);
	if (tool === "grep_files" && isArray(result.groupedResults)) {
		const grouped = result.groupedResults;
		const shown = math.min(grouped.length, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches);
		const sanitizedGroups: Record<string, unknown>[] = [];
		for (let i = 0; i < shown; i++) {
			const row = grouped[i] as AnyTable;
			sanitizedGroups.push({
				file: row.file,
				totalMatches: row.totalMatches,
				matches: isArray(row.matches)
					? sanitizeSearchMatchesForHistory(row.matches as Record<string, unknown>[], 3)
					: [],
			});
		}
		clone.groupedResults = sanitizedGroups;
	}
	return clone;
}

export function sanitizeListFilesResultForHistory(result: Record<string, unknown>): Record<string, unknown> {
	if (result.success !== true || !isArray(result.files)) return result;
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	clone.files = result.files.slice(0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries);
	return clone;
}

export function sanitizeBuildResultForHistory(result: Record<string, unknown>): Record<string, unknown> {
	if (!isArray(result.messages)) return result;
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	const messages = result.messages as Record<string, unknown>[];
	const ordered = messages.slice().sort((a, b) => {
		const aFailed = a.success !== true;
		const bFailed = b.success !== true;
		if (aFailed === bFailed) return 0;
		return aFailed ? -1 : 1;
	});
	const shown = math.min(ordered.length, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages);
	const sanitized: Record<string, unknown>[] = [];
	for (let i = 0; i < shown; i++) {
		const item = ordered[i];
		const next: Record<string, unknown> = {};
		for (const key in item) {
			const value = item[key];
			next[key] = key === "message" && typeof value === "string"
				? truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars)
				: value;
		}
		sanitized.push(next);
	}
	clone.messages = sanitized;
	if (ordered.length > shown) {
		clone.truncatedMessages = ordered.length - shown;
	}
	return clone;
}

export function sanitizeActionParamsForHistory(tool: AgentToolName, params: Record<string, unknown>): Record<string, unknown> {
	if (tool !== "edit_file") return params;
	const clone: Record<string, unknown> = {};
	for (const key in params) {
		if (key === "old_str") {
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str");
		} else if (key === "new_str") {
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str");
		} else if (key === "edits" && isArray(params[key])) {
			clone.edits = (params[key] as unknown[]).map(item => {
				if (!isRecord(item) || isArray(item)) return { invalid: true };
				return {
					path: item.path,
					old_str_stats: summarizeEditTextParamForHistory(item.old_str, "old_str"),
					new_str_stats: summarizeEditTextParamForHistory(item.new_str, "new_str"),
				};
			});
		} else {
			clone[key] = params[key];
		}
	}
	return clone;
}

function projectEditResultForLLM(result: Record<string, unknown>): Record<string, unknown> {
	if (result.success !== true) {
		const failed: Record<string, unknown> = {};
		for (const key in result) {
			const value = result[key];
			failed[key] = typeof value === "string"
				? truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key)
				: value;
		}
		return failed;
	}
	const projected: Record<string, unknown> = {};
	const scalarKeys = [
		"success", "changed", "mode", "checkpointId", "checkpointSeq",
		"checkpointed", "reversible", "binary",
		"actualSaved", "actualSavedCharacters", "currentFileExists", "currentCharacters", "currentState",
	];
	for (let i = 0; i < scalarKeys.length; i++) {
		const key = scalarKeys[i];
		if (result[key] !== undefined) projected[key] = result[key];
	}
	if (isArray(result.files)) projected.files = result.files;
	if (typeof result.message === "string") {
		projected.message = truncateHistoryText(
			result.message,
			AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars,
			"message"
		);
	}
	if (typeof result.guidance === "string") {
		projected.guidance = truncateHistoryText(
			result.guidance,
			AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars,
			"guidance"
		);
	}
	if (isArray(result.fileContext)) {
		const summaries: Record<string, unknown>[] = [];
		for (let i = 0; i < result.fileContext.length; i++) {
			const item = result.fileContext[i];
			if (!isRecord(item) || isArray(item)) continue;
			const summary: Record<string, unknown> = {};
			const keys = [
				"path", "op", "beforeExists", "afterExists", "beforeBytes", "afterBytes",
				"lineCount", "contentTruncated", "fileListTruncated",
			];
			for (let j = 0; j < keys.length; j++) {
				const key = keys[j];
				if (item[key] !== undefined) summary[key] = item[key];
			}
			summaries.push(summary);
		}
		if (summaries.length > 0) projected.fileSummary = summaries;
	}
	if (typeof result.truncatedFileContextItems === "number") {
		projected.truncatedFileContextItems = result.truncatedFileContextItems;
	}
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed.";
	return projected;
}

function projectOneBuildResultForLLM(result: Record<string, unknown>): Record<string, unknown> {
	if (!isArray(result.messages)) return result;
	const projected: Record<string, unknown> = {};
	for (const key in result) {
		if (key !== "messages") projected[key] = result[key];
	}
	const maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages;
	const shown = math.min(result.messages.length, maxMessages);
	projected.messages = result.messages.slice(0, shown);
	if (result.messages.length > shown) {
		projected.llmHistoryTruncatedMessages = result.messages.length - shown;
	}
	return projected;
}

function projectBuildResultForLLM(result: Record<string, unknown>): Record<string, unknown> {
	if (!isArray(result.results)) return projectOneBuildResultForLLM(result);
	const projected: Record<string, unknown> = {};
	for (const key in result) {
		if (key !== "results") projected[key] = result[key];
	}
	projected.results = result.results.map(item => isRecord(item) && !isArray(item)
		? projectOneBuildResultForLLM(item)
		: item);
	return projected;
}

function projectCommandResultForLLM(result: Record<string, unknown>): Record<string, unknown> {
	const projected: Record<string, unknown> = {};
	for (const key in result) {
		const value = result[key];
		if (key === "output" && typeof value === "string") {
			projected[key] = truncateHistoryText(
				value,
				AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars,
				"command output"
			);
		} else if (key === "message" && typeof value === "string") {
			projected[key] = truncateHistoryText(
				value,
				AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars,
				"command message"
			);
		} else {
			projected[key] = value;
		}
	}
	return projected;
}

function projectToolResultContentForLLM(tool: string, content: string): string {
	const [decoded] = AgentUtils.safeJsonDecode(content);
	if (!isRecord(decoded) || isArray(decoded)) {
		return truncateHistoryText(
			content,
			AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars,
			`${tool} result`
		);
	}
	let projected = decoded;
	if (tool === "edit_file" || tool === "delete_file") {
		projected = projectEditResultForLLM(decoded);
	} else if (tool === "build") {
		projected = projectBuildResultForLLM(decoded);
	} else if (tool === "execute_command") {
		projected = projectCommandResultForLLM(decoded);
	}
	const encoded = toJson(projected, false);
	// read_file is already normalized once, before it enters session history.
	// Keep that representation stable across later requests for prompt caching.
	if (tool === "read_file") return encoded;
	if (encoded.length <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars) return encoded;
	const fallback: Record<string, unknown> = {
		success: projected.success,
		llmHistoryTruncated: true,
		originalChars: encoded.length,
		preview: truncateHistoryText(
			encoded,
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45),
			`${tool} result`
		),
	};
	return toJson(fallback, false);
}
export function projectMessagesForLLMContext(messages: Message[]): Message[] {
	// Session history remains the source of truth for persistence and UI events.
	// Tool-call arguments remain byte-for-byte unchanged so the normal Agent loop
	// sees the exact calls that were originally stored and preserves cache prefixes.
	const projected: Message[] = [];
	for (let i = 0; i < messages.length; i++) {
		const message = messages[i];
		const next: Message = { ...message };
		if (message.role === "assistant" && (!message.tool_calls || message.tool_calls.length === 0)) next.reasoning_content = undefined; // DeepSeek replays reasoning only with its tool calls.
		if (message.role === "tool" && typeof message.content === "string") {
			next.content = projectToolResultContentForLLM(message.name ?? "tool", message.content);
		}
		projected.push(next);
	}
	return projected;
}

export function projectMessagesForCompression(messages: Message[]): Message[] {
	const projected = projectMessagesForLLMContext(messages);
	for (let i = 0; i < projected.length; i++) {
		const message = projected[i];
		if (message.role !== "assistant" || !message.tool_calls || message.tool_calls.length === 0) continue;
		let changed = false;
		const toolCalls = message.tool_calls.map(toolCall => {
			const fn = toolCall.function;
			if (fn?.name !== "edit_file" || typeof fn.arguments !== "string") return toolCall;
			const [decoded] = AgentUtils.safeJsonDecode(fn.arguments);
			if (!isRecord(decoded) || isArray(decoded)) return toolCall;
			changed = true;
			return {
				...toolCall,
				function: {
					...fn,
					arguments: toJson(sanitizeActionParamsForHistory("edit_file", decoded), false),
				},
			};
		});
		if (changed) projected[i] = { ...message, tool_calls: toolCalls };
	}
	return projected;
}

export function sanitizeMessagesForLLMInput(messages: Message[]): Message[] {
	const sanitized: Message[] = [];
	let droppedAssistantToolCalls = 0;
	let droppedToolResults = 0;
	for (let i = 0; i < messages.length; i++) {
		const message = messages[i];
		if (message.role === "assistant" && message.tool_calls && message.tool_calls.length > 0) {
			const requiredIds: string[] = [];
			for (let j = 0; j < message.tool_calls.length; j++) {
				const toolCall = message.tool_calls[j];
				const id = typeof toolCall?.id === "string" ? toolCall.id : "";
				if (id !== "" && requiredIds.indexOf(id) < 0) {
					requiredIds.push(id);
				}
			}
			if (requiredIds.length === 0) {
				sanitized.push(message);
				continue;
			}
			const matchedIds: Record<string, boolean> = {};
			const matchedTools: Message[] = [];
			let j = i + 1;
			while (j < messages.length) {
				const toolMessage = messages[j];
				if (toolMessage.role !== "tool") break;
				const toolCallId = typeof toolMessage.tool_call_id === "string" ? toolMessage.tool_call_id : "";
				if (toolCallId !== "" && requiredIds.indexOf(toolCallId) >= 0 && matchedIds[toolCallId] !== true) {
					matchedIds[toolCallId] = true;
					matchedTools.push(toolMessage);
				} else {
					droppedToolResults += 1;
				}
				j += 1;
			}
			let complete = true;
			for (let j = 0; j < requiredIds.length; j++) {
				if (matchedIds[requiredIds[j]] !== true) {
					complete = false;
					break;
				}
			}
			if (complete) {
				sanitized.push(message, ...matchedTools);
			} else {
				droppedAssistantToolCalls += 1;
				droppedToolResults += matchedTools.length;
			}
			i = j - 1;
			continue;
		}
		if (message.role === "tool") {
			droppedToolResults += 1;
			continue;
		}
		sanitized.push(message);
	}
	return sanitized;
}
