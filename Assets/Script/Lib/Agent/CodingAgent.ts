// @preview-file off clear
import { json, Director, once, Content, wait, emit } from 'Dora';
import { Flow, Node } from 'Agent/flow';
import { callLLMStream, callLLM, Message, StopToken, Log } from 'Agent/Utils';
import * as Tools from 'Agent/Tools';
import * as yaml from 'yaml';
import { MemoryCompressor } from 'Agent/Memory';

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
	stopToken?: StopToken;
	memoryContext?: number;
}

type AgentDecisionMode = "tool_calling" | "yaml";

type AgentToolName =
	| "read_file"
	| "read_file_range"
	| "edit_file"
	| "delete_file"
	| "search_files"
	| "search_dora_api"
	| "list_files"
	| "run_ts_build"
	| "finish";

const HISTORY_READ_FILE_MAX_CHARS = 12000;
const HISTORY_READ_FILE_MAX_LINES = 300;

export interface AgentActionRecord {
	step: number;
	tool: AgentToolName;
	reason: string;
	params: Record<string, unknown>;
	result?: Record<string, unknown>;
	timestamp: string;
}

interface AgentShared {
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
	llmMaxTry: number;
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

		/** 是否在当前任务中已执行过压缩 */
		hasCompressedThisTask: boolean;
	};
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
	const pos = utf8.offset(text, maxLen);
	return `${text.slice(0, pos)}...`;
}

function summarizeUnknown(value: unknown, maxLen = 320): string {
	if (value === undefined) return "undefined";
	if (value === null) return "null";
	if (type(value) === "string") {
		return truncateText(value as string, maxLen).replace("\n", "\\n");
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
		? limitedByLines.slice(0, HISTORY_READ_FILE_MAX_CHARS)
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
	if (type(value) !== "string") return undefined;
	const text = value as string;
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

function isKnownToolName(name: string): name is AgentToolName {
	return name === "read_file"
		|| name === "read_file_range"
		|| name === "edit_file"
		|| name === "delete_file"
		|| name === "search_files"
		|| name === "search_dora_api"
		|| name === "list_files"
		|| name === "run_ts_build"
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
			lines.push(`- Result: ${success ? "Success" : "Failed"}`);
			if (action.tool === "read_file" || action.tool === "read_file_range") {
				if (success && type(result.content) === "string") {
					lines.push(`- Content: ${limitReadContentForHistory(result.content as string, action.tool)}`);
				}
			} else if (action.tool === "search_files") {
				if (success && type(result.results) === "table") {
					const matches = result.results as Record<string, unknown>[];
					lines.push(`- Matches: ${matches.length}`);
					for (let j = 0; j < matches.length; j++) {
						const m = matches[j];
						const file = type(m.file) === "string" ? (m.file as string) : "";
						const line = m.line !== undefined ? tostring(m.line) : "";
						const content = type(m.content) === "string" ? (m.content as string) : summarizeUnknown(m, 240);
						lines.push(`  ${j + 1}. ${file}${line !== "" ? ":" + line : ""}: ${content}`);
					}
				}
			} else if (action.tool === "search_dora_api") {
				if (success && type(result.results) === "table") {
					const hits = result.results as Record<string, unknown>[];
					lines.push(`- Matches: ${hits.length}`);
					for (let j = 0; j < hits.length; j++) {
						const m = hits[j];
						const file = type(m.file) === "string" ? (m.file as string) : "";
						const line = m.line !== undefined ? tostring(m.line) : "";
						const content = type(m.content) === "string" ? (m.content as string) : summarizeUnknown(m, 240);
						lines.push(`  ${j + 1}. ${file}${line !== "" ? ":" + line : ""}: ${content}`);
					}
				}
			} else if (action.tool === "edit_file") {
				if (success) {
					if (result.mode !== undefined) {
						lines.push(`- Mode: ${tostring(result.mode)}`);
					}
					if (result.replaced !== undefined) {
						lines.push(`- Replaced: ${tostring(result.replaced)}`);
					}
				}
			} else if (action.tool === "list_files") {
				if (success && type(result.files) === "table") {
					const files = result.files as string[];
					lines.push("- Directory structure:");
					if (files.length > 0) {
						for (let j = 0; j < files.length; j++) {
							lines.push(`  ${files[j]}`);
						}
					} else {
						lines.push("  (Empty or inaccessible directory)");
					}
				}
			} else {
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
	const res = await callLLM(messages, shared.llmOptions, shared.stopToken);
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
			onData: (data) => {
				if (shared.stopToken.stopped) return true;
				const choice = data.choices && data.choices[0];
				const delta = choice && choice.delta;
				if (delta && type(delta.content) === "string") {
					const content = delta.content as string;
					text += content;
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
	);

	await new Promise<void>(resolve => {
		Director.systemScheduler.schedule(once(() => {
			wait(() => done);
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
							"search_files",
							"search_dora_api",
							"list_files",
							"run_ts_build",
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
							includeContent: { type: "boolean" },
							contentWindow: { type: "number" },
							programmingLanguage: {
								type: "string",
								enum: ["ts", "tsx", "lua", "yue", "teal"],
							},
							topK: { type: "number" },
							startLine: { type: "number" },
							endLine: { type: "number" },
						},
					},
				},
				required: ["tool", "reason", "params"],
			},
		},
	}];
}

function buildDecisionPrompt(shared: AgentShared, userQuery: string, historyText: string, memoryContext: string): string {
	return `You are a coding assistant that helps modify and navigate code.
Given the request and action history, decide which tool to use next.

${memoryContext}

User request: ${userQuery}

Here are the actions you performed:
${historyText}

Available tools:
1. read_file: Read content from a file
	- Parameters: path (workspace-relative)
1b. read_file_range: Read specific line range from a file
	- Parameters: path, startLine, endLine

2. edit_file: Make changes to a file
	- Parameters: path, old_str, new_str
		- Rules:
			- old_str and new_str MUST be different
			- old_str must match existing text exactly when it is non-empty
			- If file doesn't exist, set old_str to empty string to create it with new_str

3. delete_file: Remove a file
	- Parameters: target_file

4. search_files: Search patterns in workspace files
	- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional)

5. list_files: List files under a directory
	- Parameters: path, globs(optional)

6. search_dora_api: Search Dora SSR game engine API docs
	- Parameters: pattern, programmingLanguage(ts/tsx/lua/yue/teal), topK(optional)

7. run_ts_build: Run TS transpile/build checks
	- Parameters: path(optional)

8. finish: End and summarize
	- Parameters: {}

Decision rules:
- Choose exactly one next action.
- Keep params shallow and valid for the selected tool.
- Prefer reading/searching before editing when information is missing.
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
		const { userQuery, history, memory } = shared;

		if (shared.stopToken.stopped || shared.step >= shared.maxSteps) {
			return {
				userQuery: shared.userQuery,
				history: shared.history,
				shared,
			};
		}

		// 检查是否需要压缩
		if (!memory.hasCompressedThisTask) {
			const systemPrompt = this.getSystemPrompt();
			const toolDefs = this.getToolDefinitions();

			if (memory.compressor.shouldCompress(
				userQuery,
				history,
				memory.lastConsolidatedIndex,
				systemPrompt,
				toolDefs,
				formatHistorySummary
			)) {
				// 执行压缩
				const result = await memory.compressor.compress(
					history,
					memory.lastConsolidatedIndex,
					shared.llmOptions,
					formatHistorySummary,
					shared.llmMaxTry,
					shared.decisionMode
				);

				if (result && result.success) {
					memory.lastConsolidatedIndex += result.compressedCount;
					memory.hasCompressedThisTask = true;

					Log(
						'Info',
						`[Memory] Compressed ${result.compressedCount} history records`
					);
				}
			}
		}

		return {
			userQuery: shared.userQuery,
			history: shared.history,
			shared,
		};
	}

	private getSystemPrompt(): string {
		return "You are a coding assistant that helps modify and navigate code.";
	}

	private getToolDefinitions(): string {
		return `Available tools:
1. read_file: Read content from a file
1b. read_file_range: Read specific line range from a file
2. edit_file: Make changes to a file
3. delete_file: Remove a file
4. search_files: Search patterns in workspace files
5. list_files: List files under a directory
6. search_dora_api: Search Dora SSR game engine API docs
7. run_ts_build: Run TS transpile/build checks
8. finish: End and summarize`;
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
		}, shared.stopToken);
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

		// 只使用未压缩的历史
		const uncompressedHistory = input.history.slice(memory.lastConsolidatedIndex);
		const historyText = formatHistorySummary(uncompressedHistory);

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
		shared.lastDecision = {
			tool: result.tool,
			reason: result.reason,
			params: result.params,
		};
		shared.history.push({
			step: shared.step + 1,
			tool: result.tool,
			reason: result.reason,
			params: result.params,
			timestamp: os.date("!%Y-%m-%dT%H:%M:%SZ"),
		});
		return result.tool;
	}
}

class ReadFileAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ path: string; range?: { startLine: number; endLine: number }; tool: AgentToolName; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		const path = type(last.params.path) === "string"
			? (last.params.path as string)
			: (type(last.params.target_file) === "string" ? (last.params.target_file as string) : "");
		if (path.trim() === "") throw new Error("missing path");
		if (last.tool === "read_file_range") {
			return {
				path,
				tool: last.tool,
				workDir: shared.workingDir,
				range: {
					startLine: Number(last.params.startLine ?? 1),
					endLine: Number(last.params.endLine ?? last.params.startLine ?? 1),
				},
			};
		}
		return { path, tool: "read_file", workDir: shared.workingDir };
	}

	async exec(input: { path: string; range?: { startLine: number; endLine: number }; tool: AgentToolName; workDir: string }): Promise<Record<string, unknown>> {
		if (input.tool === "read_file_range" && input.range) {
			return Tools.readFileRange(input.workDir, input.path, input.range.startLine, input.range.endLine) as unknown as Record<string, unknown>;
		}
		return Tools.readFile(input.workDir, input.path) as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const result = execRes as Record<string, unknown>;
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.result = sanitizeReadResultForHistory(last.tool, result);
		}
		shared.step += 1;
		return "main";
	}
}

class SearchFilesAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
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
			includeContent: params.includeContent as boolean | undefined,
			contentWindow: Number(params.contentWindow ?? 120),
		});
		return result as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) last.result = execRes as Record<string, unknown>;
		shared.step += 1;
		return "main";
	}
}

class SearchDoraAPIAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; useChineseResponse: boolean }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		return { params: last.params, useChineseResponse: shared.useChineseResponse };
	}

	async exec(input: { params: Record<string, unknown>; useChineseResponse: boolean }): Promise<Record<string, unknown>> {
		const params = input.params;
		const result = await Tools.searchDoraAPI({
			pattern: (params.pattern as string) ?? "",
			docLanguage: input.useChineseResponse ? "zh" : "en",
			programmingLanguage: ((params.programmingLanguage as string) ?? "ts") as Tools.DoraAPIProgrammingLanguage,
			topK: Number(params.topK ?? 8),
			useRegex: params.useRegex as boolean | undefined,
			caseSensitive: params.caseSensitive as boolean | undefined,
			includeContent: params.includeContent as boolean | undefined,
			contentWindow: Number(params.contentWindow ?? 140),
		});
		return result as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) last.result = execRes as Record<string, unknown>;
		shared.step += 1;
		return "main";
	}
}

class ListFilesAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		return { params: last.params, workDir: shared.workingDir };
	}

	async exec(input: { params: Record<string, unknown>; workDir: string }): Promise<Record<string, unknown>> {
		const params = input.params;
		const result = Tools.listFiles({
			workDir: input.workDir,
			path: (params.path as string) ?? "",
			globs: params.globs as string[] | undefined,
		});
		return result as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) last.result = execRes as Record<string, unknown>;
		shared.step += 1;
		return "main";
	}
}

class DeleteFileAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ targetFile: string; taskId: number; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		const targetFile = type(last.params.target_file) === "string"
			? (last.params.target_file as string)
			: (type(last.params.path) === "string" ? (last.params.path as string) : "");
		if (targetFile.trim() === "") throw new Error("missing target_file");
		return { targetFile, taskId: shared.taskId, workDir: shared.workingDir };
	}

	async exec(input: { targetFile: string; taskId: number; workDir: string }): Promise<Record<string, unknown>> {
		return Tools.applyFileChanges(input.taskId, input.workDir, [{ path: input.targetFile, op: "delete" }], {
			summary: `delete_file: ${input.targetFile}`,
			toolName: "delete_file",
		}) as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) last.result = execRes as Record<string, unknown>;
		shared.step += 1;
		return "main";
	}
}

class RunTsBuildAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		return { params: last.params, workDir: shared.workingDir };
	}

	async exec(input: { params: Record<string, unknown>; workDir: string }): Promise<Record<string, unknown>> {
		const params = input.params;
		const result = await Tools.runTsBuild({
			workDir: input.workDir,
			path: (params.path as string) ?? ""
		});
		return result as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) last.result = execRes as Record<string, unknown>;
		shared.step += 1;
		return "main";
	}
}

class EditFileAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ path: string; oldStr: string; newStr: string; taskId: number; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
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
		const readRes = Tools.readFile(input.workDir, input.path);
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
		};
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.params = sanitizeActionParamsForHistory(last.tool, last.params);
			last.result = execRes as Record<string, unknown>;
		}
		shared.step += 1;
		return "main";
	}
}

class FormatResponseNode extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ history: AgentActionRecord[]; shared: AgentShared }> {
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
		shared.response = execRes as string;
		shared.done = true;
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
		const build = new RunTsBuildAction(1, 0);
		const edit = new EditFileAction(1, 0);
		const format = new FormatResponseNode(1, 0);

		main.on("read_file", read);
		main.on("read_file_range", read);
		main.on("search_files", search);
		main.on("search_dora_api", searchDora);
		main.on("list_files", list);
		main.on("delete_file", del);
		main.on("run_ts_build", build);
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
	const taskRes = options.taskId !== undefined
		? { success: true as const, taskId: options.taskId }
		: Tools.createTask(options.prompt);
	if (!taskRes.success) {
		return { success: false, message: taskRes.message };
	}

	// 创建 Memory 压缩器
	const compressor = new MemoryCompressor({
		contextWindow: options.memoryContext ?? 32000,
		compressionThreshold: 0.8,
		projectDir: options.workDir,
	});

	const shared: AgentShared = {
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
		history: [],
		// Memory 状态
		memory: {
			lastConsolidatedIndex: 0,
			compressor,
			hasCompressedThisTask: false,
		},
	};

	try {
		if (shared.stopToken.stopped) {
			Tools.setTaskStatus(shared.taskId, "STOPPED");
			return { success: false, taskId: shared.taskId, message: getCancelledReason(shared), steps: shared.step };
		}
		Tools.setTaskStatus(shared.taskId, "RUNNING");
		const flow = new CodingAgentFlow();
		await flow.run(shared);
		if (shared.stopToken.stopped) {
			Tools.setTaskStatus(shared.taskId, "STOPPED");
			return { success: false, taskId: shared.taskId, message: getCancelledReason(shared), steps: shared.step };
		}
		if (shared.error) {
			Tools.setTaskStatus(shared.taskId, "FAILED");
			return { success: false, taskId: shared.taskId, message: shared.error, steps: shared.step };
		}
		Tools.setTaskStatus(shared.taskId, "DONE");
		return {
			success: true,
			taskId: shared.taskId,
			message: shared.response || (shared.useChineseResponse ? "任务完成。" : "Task completed."),
			steps: shared.step,
		};
	} catch (e) {
		Tools.setTaskStatus(shared.taskId, "FAILED");
		return { success: false, taskId: shared.taskId, message: tostring(e), steps: shared.step };
	}
}

export function runCodingAgent(options: CodingAgentRunOptions, callback: (result: CodingAgentRunResult) => void) {
	runCodingAgentAsync(options).then(result => callback(result));
}
