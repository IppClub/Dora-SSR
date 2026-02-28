// @preview-file off clear
import { json, sleep, Director, once, Content, wait, emit } from 'Dora';
import { Flow, Node } from 'Agent/flow';
import { callLLM, Message } from 'Agent/Utils';
import * as Tools from 'Agent/Tools';
import * as yaml from 'yaml';

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
	llmOptions?: Record<string, unknown>;
}

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

interface AgentActionRecord {
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
	cancelled: boolean;
	error?: string;
	response?: string;
	userQuery: string;
	workingDir: string;
	useChineseResponse: boolean;
	llmOptions: Record<string, unknown>;
	history: AgentActionRecord[];
	lastDecision?: {
		tool: AgentToolName;
		reason: string;
		params: Record<string, unknown>;
	};
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
					lines.push(`- Content: ${result.content as string}`);
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

async function callLLMText(shared: AgentShared, messages: Message[]): Promise<{ success: true; text: string } | { success: false; message: string; text?: string }> {
	let text = "";
	let cancelledReason: string | undefined;
	let done = false;

	for (let i = 0; i < 5; i++) {
		done = false;
		cancelledReason = undefined;
		text = "";
		emit("LLM_IN", messages.map((m, i) => i.toString() + ": " + m.content).join('\n'));
		callLLM(
			messages,
			shared.llmOptions,
			{
				id: undefined,
				onData: (data) => {
					if (shared.cancelled) return true;
					const choice = data.choices && data.choices[0];
					const delta = choice && choice.delta;
					if (delta && type(delta.content) === "string") {
						text += delta.content as string;
						emit("LLM_OUT", delta.content);
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

		if (text === "") {
			cancelledReason = "empty LLM output";
		}
		if (!cancelledReason) break;
		emit("LLM_ABORT");
		await new Promise<void>(resolve => {
			Director.systemScheduler.schedule(once(() => {
				sleep(2);
				resolve();
			}));
		});
	}
	emit("LLMStream", "\n");
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
		return {
			userQuery: shared.userQuery,
			history: shared.history,
			shared,
		};
	}

	async exec(input: { userQuery: string; history: AgentActionRecord[]; shared: AgentShared }): Promise<{ success: true; tool: AgentToolName; reason: string; params: Record<string, unknown> } | { success: false; message: string }> {
		const historyText = formatHistorySummary(input.history);
		const prompt = [
			"You are a coding assistant that helps modify and navigate code.",
			"Given the request and action history, decide which tool to use next.",
			"",
			`User request: ${input.userQuery}`,
			"",
			"Here are the actions you performed:",
			historyText,
			"",
			"Available tools:",
			"1. read_file: Read content from a file",
			"   - Parameters: path (workspace-relative)",
			"1b. read_file_range: Read specific line range from a file",
			"   - Parameters: path, startLine, endLine",
			"",
			"2. edit_file: Make changes to a file",
			"   - Parameters: path, old_str, new_str",
			"   - Rules:",
			"     - old_str and new_str MUST be different",
			"     - old_str must match existing text exactly when it is non-empty",
			"     - If file doesn't exist, set old_str to empty string to create it with new_str",
			"",
			"3. delete_file: Remove a file",
			"   - Parameters: target_file",
			"",
			"4. search_files: Search patterns in workspace files",
			"   - Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional)",
			"",
			"5. list_files: List files under a directory",
			"   - Parameters: path, globs(optional)",
			"",
			"6. search_dora_api: Search Dora SSR game engine API docs",
			"   - Parameters: pattern, programmingLanguage(ts/tsx/lua/yue/teal), topK(optional)",
			"",
			"7. run_ts_build: Run TS transpile/build checks",
			"   - Parameters: path(optional), timeoutSec(optional)",
			"",
			"8. finish: End and summarize",
			"   - Parameters: {}",
			"",
			"Respond with one YAML object:",
			"```yaml",
			'tool: "edit_file"',
			"reason: |-",
			"\tA readable multi-line explanation is allowed.",
			"\tKeep indentation consistent.",
			"params:",
			'\tpath: "relative/path.ts"',
			"\told_str: |-",
			"\t\tfunction oldName() {",
			'\t\t\tconsole.log("old");',
			"\t\t}",
			"\tnew_str: |-",
			"\t\tfunction newName() {",
			'\t\t\tconsole.log("hello");',
			"\t\t}",
			"```",
			"Strict YAML formatting rules:",
			"- Return YAML only, no prose before/after.",
			"- Use exactly one YAML object with keys: tool, reason, params.",
			"- Multi-line strings are allowed using block scalars (`|`, `|-`, `>`).",
			"- If using a block scalar, all content lines must be indented consistently with tabs.",
			"- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.",
			"- Keep params shallow and valid for the selected tool.",
			"- Use tabs for all indentation, never spaces.",
			"If no more actions are needed, use tool: finish.",
			getReplyLanguageDirective(input.shared),
		].join("\n");

		const shared = input.shared;
		let lastError = "yaml validation failed";
		let lastRaw = "";
		for (let attempt = 0; attempt < 3; attempt++) {
			const feedback = attempt > 0
				? `\n\nPrevious response was invalid (${lastError}). Return exactly one valid YAML object only and keep YAML indentation strictly consistent.`
				: "";
			const messages: Message[] = [{ role: "user", content: `${prompt}${feedback}` }];
			const llmRes = await callLLMText(shared, messages);
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
		if (result.tool === "finish") return "finish";
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
			last.result = result;
		}
		shared.step += 1;
		return shared.step >= shared.maxSteps ? "finish" : "main";
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
		return shared.step >= shared.maxSteps ? "finish" : "main";
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
		return shared.step >= shared.maxSteps ? "finish" : "main";
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
		return shared.step >= shared.maxSteps ? "finish" : "main";
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
		return shared.step >= shared.maxSteps ? "finish" : "main";
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
			path: (params.path as string) ?? "",
			timeoutSec: Number(params.timeoutSec ?? 20),
		});
		return result as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) last.result = execRes as Record<string, unknown>;
		shared.step += 1;
		return shared.step >= shared.maxSteps ? "finish" : "main";
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
			last.result = execRes as Record<string, unknown>;
		}
		shared.step += 1;
		return shared.step >= shared.maxSteps ? "finish" : "main";
	}
}

class FormatResponseNode extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ history: AgentActionRecord[]; shared: AgentShared }> {
		return { history: shared.history, shared };
	}

	async exec(input: { history: AgentActionRecord[]; shared: AgentShared }): Promise<string> {
		const history = input.history;
		if (history.length === 0) {
			return "No actions were performed.";
		}
		const summary = formatHistorySummary(history);
		const prompt = [
			"You are a coding assistant. Summarize what you did for the user.",
			"",
			"Here are the actions you performed:",
			summary,
			"",
			"Generate a concise response that explains:",
			"1. What actions were taken",
			"2. What was found or modified",
			"3. Any next steps",
			"",
			"IMPORTANT:",
			"- Focus on outcomes, not tool names.",
			"- Speak directly to the user.",
			getReplyLanguageDirective(input.shared),
		].join("\n");
		const res = await callLLMText(input.shared, [{ role: "user", content: prompt }]);
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
		read.on("finish", format);
		search.on("main", main);
		search.on("finish", format);
		searchDora.on("main", main);
		searchDora.on("finish", format);
		list.on("main", main);
		list.on("finish", format);
		del.on("main", main);
		del.on("finish", format);
		build.on("main", main);
		build.on("finish", format);
		edit.on("main", main);
		edit.on("finish", format);

		super(main);
	}
}

export function runCodingAgent(options: CodingAgentRunOptions, callback: (result: CodingAgentRunResult) => void) {
	runCodingAgentAsync(options).then(result => callback(result));
}

export async function runCodingAgentAsync(options: CodingAgentRunOptions): Promise<CodingAgentRunResult> {
	if (!options.workDir || !Content.isAbsolutePath(options.workDir) || !Content.exist(options.workDir) || !Content.isdir(options.workDir)) {
		return { success: false, message: "workDir must be an existing absolute directory path" };
	}
	const taskRes = options.taskId !== undefined
		? { success: true as const, taskId: options.taskId }
		: Tools.createTask(options.prompt);
	if (!taskRes.success) {
		return { success: false, message: taskRes.message };
	}

	const shared: AgentShared = {
		taskId: taskRes.taskId,
		maxSteps: Math.max(1, math.floor(options.maxSteps ?? 10)),
		step: 0,
		done: false,
		cancelled: false,
		response: "",
		userQuery: options.prompt,
		workingDir: options.workDir,
		useChineseResponse: options.useChineseResponse === true,
		llmOptions: {
			temperature: 0.2,
			...(options.llmOptions ?? {}),
		},
		history: [],
	};

	try {
		Tools.setTaskStatus(shared.taskId, "RUNNING");
		const flow = new CodingAgentFlow();
		await flow.run(shared);
		if (shared.cancelled) {
			Tools.setTaskStatus(shared.taskId, "STOPPED");
			return { success: false, taskId: shared.taskId, message: "cancelled", steps: shared.step };
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

export function cancelCodingAgent(shared: { cancelled?: boolean }) {
	shared.cancelled = true;
}
