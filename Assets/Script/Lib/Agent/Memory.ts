// @preview-file off clear
import { App, Content, Path } from 'Dora';
import { Message, ToolCallFunction, callLLM, Log, clipTextToTokenBudget, parseXMLObjectFromText, safeJsonDecode, safeJsonEncode, sanitizeUTF8 } from 'Agent/Utils';
import { getActiveLLMConfig } from 'Agent/Utils';
import type { LLMConfig, ToolCall } from 'Agent/Utils';
import { sendWebIDEFileUpdate } from 'Agent/Tools';

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object";
}

function isArray(value: unknown): value is any[] {
	return Array.isArray(value);
}

export interface AgentConversationMessage extends Message {
	timestamp?: string;
}

export interface PersistedSessionState {
	messages: AgentConversationMessage[];
	lastConsolidatedIndex: number;
	carryMessageIndex?: number;
}

interface HistoryRecord {
	ts: string;
	summary?: string;
	rawArchive?: string;
}

function clampSessionIndex(messages: AgentConversationMessage[], index?: number): number {
	if (typeof index !== "number") return 0;
	if (index <= 0) return 0;
	return math.min(messages.length, math.floor(index));
}

const AGENT_CONFIG_DIR = ".agent";
const AGENT_PROMPTS_FILE = "AGENT.md";
const HISTORY_JSONL_FILE = "HISTORY.jsonl";
const HISTORY_MAX_RECORDS = 1000;
const SESSION_MAX_RECORDS = 1000;
const XML_DECISION_SCHEMA_EXAMPLE = `\`\`\`xml
<tool_call>
	<tool>edit_file</tool>
	<reason>Need to update the file content to implement the requested change.</reason>
	<params>
		<path>relative/path.ts</path>
		<old_str>
function oldName() {
	print("old");
}
		</old_str>
		<new_str>
function newName() {
	print("hello");
}
		</new_str>
	</params>
</tool_call>
\`\`\`

\`\`\`xml
<tool_call>
	<tool>read_file</tool>
	<reason>Need to inspect the current implementation before editing.</reason>
	<params>
		<path>relative/path.ts</path>
		<startLine>1</startLine>
		<endLine>200</endLine>
	</params>
</tool_call>
\`\`\`

\`\`\`xml
<tool_call>
	<tool>finish</tool>
	<params>
		<message>Final user-facing answer.</message>
	</params>
</tool_call>
\`\`\``;

export interface AgentPromptPack {
	agentIdentityPrompt: string;
	toolDefinitionsDetailed: string;
	replyLanguageDirectiveZh: string;
	replyLanguageDirectiveEn: string;
	toolCallingRetryPrompt: string;
	xmlDecisionFormatPrompt: string;
	xmlDecisionRepairPrompt: string;
	xmlDecisionSystemRepairPrompt: string;
	memoryCompressionSystemPrompt: string;
	memoryCompressionBodyPrompt: string;
	memoryCompressionToolCallingPrompt: string;
	memoryCompressionXmlPrompt: string;
	memoryCompressionXmlRetryPrompt: string;
}

export const DEFAULT_AGENT_PROMPT_PACK: AgentPromptPack = {
	agentIdentityPrompt: `### Dora Agent

You are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.

### Guidelines

- State intent before tool calls, but NEVER predict or claim results before receiving them.
- Before modifying a file, read it first. Do not assume files or directories exist.
- After writing or editing a file, re-read it if accuracy matters.
- If a tool call fails, analyze the error before retrying with a different approach.
- Ask for clarification when the request is ambiguous.
- Prefer reading and searching before editing when information is missing.
- Focus on outcomes, not tool names. Speak directly to the user.`,
	toolDefinitionsDetailed: `Available tools:
1. read_file: Read a specific line range from a file
	- Parameters: path, startLine(optional), endLine(optional)
	- Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. 0 is invalid.
	- startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.

2. edit_file: Make changes to a file
	- Parameters: path, old_str, new_str
		- Rules:
			- old_str and new_str MUST be different
			- old_str must match existing text exactly when it is non-empty
			- If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists

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
	- \`limit\` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.

7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn
	- Parameters: path(optional)
	- \`path\` can be workspace-relative file or directory to build.
	- Read the result and then decide whether another action is needed.

8. finish: End the task and reply directly to the user
	- Parameters: message`,
	replyLanguageDirectiveZh: "Use Simplified Chinese for natural-language fields (message/summary).",
	replyLanguageDirectiveEn: "Use English for natural-language fields (message/summary).",
	toolCallingRetryPrompt: "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.",
xmlDecisionFormatPrompt: `Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.

${XML_DECISION_SCHEMA_EXAMPLE}

Rules:
- Return exactly one \`<tool_call>...</tool_call>\` block.
- For every tool except finish, include \`<tool>\`, \`<reason>\`, and \`<params>\`.
- For finish, include \`<tool>\` and \`<params>\`. Do not include \`<reason>\`.
- Inside \`<params>\`, use one child tag per parameter, for example \`<path>\`, \`<old_str>\`, \`<new_str>\`.
- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.
- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.
- Keep params shallow and valid for the selected tool.
- If no more actions are needed, use tool finish and put the final user-facing answer in \`<params><message>...</message></params>\`.`,
	xmlDecisionRepairPrompt: `Convert the tool call result below into exactly one valid XML tool_call block.

XML schema example:
${XML_DECISION_SCHEMA_EXAMPLE}

Rules:
- Return exactly one XML \`<tool_call>...</tool_call>\` block.
- Return XML only. No prose before or after.
- Keep the same tool name, reason, and parameter values as the source whenever possible.
- For every tool except finish, include \`<tool>\`, \`<reason>\`, and \`<params>\`.
- For finish, include \`<tool>\` and \`<params>\` only.
- Inside \`<params>\`, use one child tag per parameter.
- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.
- Do not invent extra parameters.

Available tools and params reference:

{{TOOL_DEFINITIONS}}

### Original Raw Output
\`\`\`
{{ORIGINAL_RAW}}
\`\`\`

{{CANDIDATE_SECTION}}### Repair Task
- The current candidate is invalid because: {{LAST_ERROR}}
- Repair only the formatting/schema so the result becomes one valid XML tool_call block.
- Keep the tool name and argument values aligned with the original raw output.
- Retry attempt: {{ATTEMPT}}.
- The next reply must differ from the previously rejected candidate.
- Return XML only, with no prose before or after.`,
	xmlDecisionSystemRepairPrompt: `You repair invalid XML tool decisions for the Dora coding agent.

Your job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.

Requirements:
- Preserve the original tool name and parameter values whenever possible.
- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.
- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.
- Only repair formatting and schema shape so the output becomes valid XML.
- Do not continue the conversation and do not add explanations.
- Return XML only.`,
	memoryCompressionSystemPrompt: `You are a memory consolidation agent. You MUST call the save_memory tool.
Do not output any text besides the tool call.

### Task

Analyze the actions and update the memory. Follow these guidelines:

1. Preserve Important Information
	- User preferences and settings
	- Key decisions and their rationale
	- Important technical details
	- Project-specific context

2. Consolidate Redundant Information
	- Merge related entries
	- Remove outdated information
	- Summarize verbose sections

3. Maintain Structure
	- Keep the markdown format
	- Preserve section headers
	- Use clear, concise language

4. Create History Entry
	- Create a summary paragraph
	- Include key topics
	- Make it grep-searchable

Call the save_memory tool with your consolidated memory and history entry.`,
	memoryCompressionBodyPrompt: `### Current Memory (Long-term)

{{CURRENT_MEMORY}}

### Actions to Process

{{HISTORY_TEXT}}`,
	memoryCompressionToolCallingPrompt: `### Output Format

Call the save_memory tool with:
- history_entry: the summary paragraph without timestamp
- memory_update: the full updated MEMORY.md content`,
	memoryCompressionXmlPrompt: `### Output Format

Return exactly one XML block:
\`\`\`xml
<memory_update_result>
	<history_entry>Summary paragraph</history_entry>
	<memory_update>
Full updated MEMORY.md content
	</memory_update>
</memory_update_result>
\`\`\`

Rules:
- Return XML only, no prose before or after.
- Use exactly one root tag: \`<memory_update_result>\`.
- Use exactly two child tags: \`<history_entry>\` and \`<memory_update>\`.
- Use CDATA for \`<memory_update>\` when it spans multiple lines or contains markdown/code.`,
	memoryCompressionXmlRetryPrompt: "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only."
};

const EXPOSED_PROMPT_PACK_KEYS: (keyof AgentPromptPack)[] = [
	"agentIdentityPrompt",
	"replyLanguageDirectiveZh",
	"replyLanguageDirectiveEn",
];

const OVERRIDABLE_PROMPT_PACK_KEYS: (keyof AgentPromptPack)[] = [
	...EXPOSED_PROMPT_PACK_KEYS,
	"toolDefinitionsDetailed",
];

function replaceTemplateVars(template: string, vars: Record<string, string>): string {
	let output = template;
	for (const key in vars) {
		output = output.split(`{{${key}}}`).join(vars[key] ?? "");
	}
	return output;
}

export function resolveAgentPromptPack(value?: Record<string, unknown> | null): AgentPromptPack {
	const merged: AgentPromptPack = {
		...DEFAULT_AGENT_PROMPT_PACK,
	};
		if (value && !isArray(value) && isRecord(value)) {
			for (let i = 0; i < OVERRIDABLE_PROMPT_PACK_KEYS.length; i++) {
				const key = OVERRIDABLE_PROMPT_PACK_KEYS[i];
				if (typeof value[key] === "string") {
					merged[key] = value[key];
				}
			}
		}
	return merged;
}

export function renderDefaultAgentPromptPackMarkdown(): string {
	const pack = DEFAULT_AGENT_PROMPT_PACK;
	const lines: string[] = [];
	lines.push(`# Dora Agent Prompt Configuration`);
	lines.push("");
	lines.push(`Edit the content under each \`##\` heading. Missing sections fall back to built-in defaults.`);
	lines.push("");
	for (let i = 0; i < EXPOSED_PROMPT_PACK_KEYS.length; i++) {
		const key = EXPOSED_PROMPT_PACK_KEYS[i];
		lines.push(`## ${key}`);
		const text = pack[key] as string;
		const split = text.split("\n");
		for (let j = 0; j < split.length; j++) {
			lines.push(split[j]);
		}
		lines.push("");
	}
	return lines.join("\n").trim() + "\n";
}

function getPromptPackConfigPath(projectRoot: string): string {
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE);
}

function ensurePromptPackConfig(projectRoot: string): string | undefined {
	const path = getPromptPackConfigPath(projectRoot);
	if (Content.exist(path)) return undefined;
	const dir = Path.getPath(path);
	if (!Content.exist(dir)) {
		Content.mkdir(dir);
	}
	const content = renderDefaultAgentPromptPackMarkdown();
	if (!Content.save(path, content)) {
		return `Failed to create default Agent prompt config at ${path}. Using built-in defaults for this run.`;
	}
	sendWebIDEFileUpdate(path, true, content);
	return undefined;
}

function parsePromptPackMarkdown(text: string): {
	value?: Record<string, unknown>;
	missing: string[];
	unknown: string[];
	error?: string;
} {
	if (!text || text.trim() === "") {
		return {
			value: {},
			missing: [...EXPOSED_PROMPT_PACK_KEYS],
			unknown: [],
		};
	}
	const normalized = text.replace("\r\n", "\n");
	const lines = normalized.split("\n");
	const sections: Record<string, string[]> = {};
	const unknown: string[] = [];
	let currentHeading = "";
	const isKnownPromptPackKey = (name: string): boolean => {
		for (let i = 0; i < EXPOSED_PROMPT_PACK_KEYS.length; i++) {
			if (EXPOSED_PROMPT_PACK_KEYS[i] === name) return true;
		}
		return false;
	};
	for (let i = 0; i < lines.length; i++) {
		const line = lines[i];
		const [matchedHeading] = string.match(line, "^##[ \t]+(.+)$");
		if (matchedHeading !== undefined) {
			const heading = tostring(matchedHeading).trim();
			if (isKnownPromptPackKey(heading)) {
				currentHeading = heading;
				if (sections[currentHeading] === undefined) {
					sections[currentHeading] = [];
				}
				continue;
			}
			if (currentHeading === "") {
				unknown.push(heading);
				continue;
			}
		}
		if (currentHeading !== "") {
			sections[currentHeading].push(line);
		}
	}
	const value: Record<string, unknown> = {};
	const missing: string[] = [];
	for (let i = 0; i < EXPOSED_PROMPT_PACK_KEYS.length; i++) {
		const key = EXPOSED_PROMPT_PACK_KEYS[i];
		const section = sections[key];
		const body = section !== undefined ? section.join("\n").trim() : "";
		if (body === "") {
			missing.push(key);
			continue;
		}
		value[key] = body;
	}
	if (Object.keys(sections).length === 0) {
		return {
			error: "no ## sections found",
			unknown,
			missing,
		};
	}
	return { value, missing, unknown };
}

export function loadAgentPromptPack(projectRoot: string): { pack: AgentPromptPack; warnings: string[]; path: string } {
	const path = getPromptPackConfigPath(projectRoot);
	const warnings: string[] = [];
	const ensureWarning = ensurePromptPackConfig(projectRoot);
	if (ensureWarning && ensureWarning !== "") {
		warnings.push(ensureWarning);
	}
	if (!Content.exist(path)) {
		return {
			pack: resolveAgentPromptPack(),
			warnings,
			path,
		};
	}
	const text = Content.load(path) as string;
	if (!text || text.trim() === "") {
		warnings.push(`Agent prompt config at ${path} is empty. Using built-in defaults for this run.`);
		return {
			pack: resolveAgentPromptPack(),
			warnings,
			path,
		};
	}
	const parsed = parsePromptPackMarkdown(text);
	if (parsed.error || !parsed.value) {
		warnings.push(`Agent prompt config at ${path} is invalid (${parsed.error ?? "parse failed"}). Using built-in defaults for this run.`);
		return {
			pack: resolveAgentPromptPack(),
			warnings,
			path,
		};
	}
	if (parsed.unknown.length > 0) {
		warnings.push(`Agent prompt config at ${path} contains unrecognized sections: ${parsed.unknown.join(", ")}.`);
	}
	if (parsed.missing.length > 0) {
		warnings.push(`Agent prompt config at ${path} is missing sections: ${parsed.missing.join(", ")}. Built-in defaults were used for those sections.`);
	}
	return {
		pack: resolveAgentPromptPack(parsed.value),
		warnings,
		path,
	};
}

/**
 * Memory 配置
 */
export interface MemoryConfig {
	/** 压缩触发阈值 (0-1) */
	compressionThreshold: number;

	/** 普通压缩目标阈值 (0-1)，触发后压到该比例以下 */
	compressionTargetThreshold: number;

	/** 最大压缩轮数 */
	maxCompressionRounds: number;

	/** 当前项目完整路径 */
	projectDir: string;

	/** 当前运行绑定的 LLM 配置 */
	llmConfig: LLMConfig;

	/** 当前会话使用的 Prompt 配置 */
	promptPack?: Partial<AgentPromptPack> | AgentPromptPack;

	/** 当前 memory scope，留空表示 .agent 根目录 */
	scope?: string;
}

/**
 * 压缩结果
 */
export interface CompressionResult {
	/** 更新后的 MEMORY.md 内容 */
	memoryUpdate: string;

	/** 历史记录时间戳 */
	ts?: string;

	/** 历史记录摘要 */
	summary?: string;

	/** 压缩的历史记录数量 */
	compressedCount: number;

	/** 是否成功 */
	success: boolean;

	/** 错误信息 (如果失败) */
	error?: string;

	/** 需要补回 active context 的最后一条 user 消息索引（相对当前 active messages） */
	carryMessageIndex?: number;
}

export interface MemoryCompressionDebugContext {
	onInput?: (phase: string, messages: Message[], options: Record<string, unknown>) => void;
	onOutput?: (phase: string, text: string, meta?: Record<string, unknown>) => void;
}

export type MemoryCompressionDecisionMode = "tool_calling" | "xml";
export type MemoryCompressionBoundaryMode = "default" | "budget_max";
type CompressionBoundarySelection = {
	chunkEnd: number;
	compressedCount: number;
	carryMessageIndex?: number;
};

/**
 * Token 估算器
 *
 * 提供简单高效的 token 估算功能。
 * 估算精度足够用于压缩触发判断。
 */
export class TokenEstimator {
	/**
	 * 估算文本的 token 数量
	 */
	static estimate(text: string): number {
		if (!text) return 0;
		return App.estimateTokens(text);
	}

	static estimateMessages(messages: Message[]): number {
		if (!messages || messages.length === 0) return 0;
		let total = 0;
		for (let i = 0; i < messages.length; i++) {
			const message = messages[i];
			total += this.estimate(message.role ?? "");
			total += this.estimate(message.content ?? "");
			total += this.estimate(message.name ?? "");
			total += this.estimate(message.tool_call_id ?? "");
			total += this.estimate(message.reasoning_content ?? "");
			const [toolCallsText] = safeJsonEncode((message.tool_calls ?? []) as object);
			total += this.estimate(toolCallsText ?? "");
			total += 8;
		}
		return total;
	}

	static estimatePromptMessages(
		messages: Message[],
		systemPrompt: string,
		toolDefinitions: string
	): number {
		return (
			this.estimateMessages(messages) +
			this.estimate(systemPrompt) +
			this.estimate(toolDefinitions)
		);
	}
}

function encodeCompressionDebugJSON(value: unknown): string {
	const [text, err] = safeJsonEncode(value as object);
	return text ?? `{ "error": "json_encode_failed", "message": "${tostring(err)}" }`;
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

function ensureDirRecursive(dir: string): boolean {
	if (!dir || dir === "") return false;
	if (Content.exist(dir)) return Content.isdir(dir);
	const parent = Path.getPath(dir);
	if (parent && parent !== dir && !Content.exist(parent)) {
		if (!ensureDirRecursive(parent)) {
			return false;
		}
	}
	return Content.mkdir(dir);
}

/**
 * 双层存储管理器
 *
 * 管理 MEMORY.md (长期记忆) 和 HISTORY.jsonl (历史日志)
 */
export class DualLayerStorage {
	private projectDir: string;
	private agentRootDir: string;
	private agentDir: string;
	private memoryPath: string;
	private historyPath: string;
	private sessionPath: string;

	constructor(projectDir: string, scope = "") {
		this.projectDir = projectDir;
		this.agentRootDir = Path(this.projectDir, ".agent");
		this.agentDir = scope !== ""
			? Path(this.agentRootDir, scope)
			: this.agentRootDir;
		this.memoryPath = Path(this.agentDir, "MEMORY.md");
		this.historyPath = Path(this.agentDir, HISTORY_JSONL_FILE);
		this.sessionPath = Path(this.agentDir, "SESSION.jsonl");
		this.ensureAgentFiles();
	}

	private ensureDir(dir: string): void {
		if (!Content.exist(dir)) {
			ensureDirRecursive(dir);
		}
	}

	private ensureFile(path: string, content: string): boolean {
		if (Content.exist(path)) return false;
		this.ensureDir(Path.getPath(path));
		if (!Content.save(path, content)) {
			return false;
		}
		sendWebIDEFileUpdate(path, true, content);
		return true;
	}

	private ensureAgentFiles(): void {
		this.ensureDir(this.agentRootDir);
		this.ensureDir(this.agentDir);
		this.ensureFile(this.memoryPath, "");
		this.ensureFile(this.historyPath, "");
	}

	private encodeJsonLine(value: unknown): string | undefined {
		const [text] = safeJsonEncode(value as object);
		return text;
	}

	private decodeJsonLine(text: string): unknown {
		const [value] = safeJsonDecode(text);
		return value;
	}

	private decodeConversationMessage(value: unknown): AgentConversationMessage | undefined {
		if (!value || isArray(value) || !isRecord(value)) return undefined;
		const row = value;
		const role = typeof row.role === "string" ? row.role : "";
		if (role === "") return undefined;
		const message: AgentConversationMessage = { role };
		if (typeof row.content === "string") message.content = sanitizeUTF8(row.content);
		if (typeof row.name === "string") message.name = sanitizeUTF8(row.name);
		if (typeof row.tool_call_id === "string") message.tool_call_id = sanitizeUTF8(row.tool_call_id);
		if (typeof row.reasoning_content === "string") message.reasoning_content = sanitizeUTF8(row.reasoning_content);
		if (typeof row.timestamp === "string") message.timestamp = sanitizeUTF8(row.timestamp);
		if (isArray(row.tool_calls)) {
			message.tool_calls = row.tool_calls as Message["tool_calls"];
		}
		return message;
	}

	private decodeHistoryRecord(value: unknown): HistoryRecord | undefined {
		if (!value || isArray(value) || !isRecord(value)) return undefined;
		const row = value;
		const ts = typeof row.ts === "string" && row.ts.trim() !== ""
			? sanitizeUTF8(row.ts)
			: "";
		const summary = typeof row.summary === "string" && row.summary.trim() !== ""
			? sanitizeUTF8(row.summary)
			: undefined;
		const rawArchive = typeof row.rawArchive === "string" && row.rawArchive.trim() !== ""
			? sanitizeUTF8(row.rawArchive)
			: undefined;
		if (ts === "" || (summary === undefined && rawArchive === undefined)) return undefined;
		const record: HistoryRecord = {
			ts,
			summary,
			rawArchive,
		};
		return record;
	}

	private readHistoryRecords(): HistoryRecord[] {
		if (!Content.exist(this.historyPath)) {
			return [];
		}
		const text = Content.load(this.historyPath) as string;
		if (!text || text.trim() === "") {
			return [];
		}
		const lines = text.split("\n");
		const records: HistoryRecord[] = [];
		for (let i = 0; i < lines.length; i++) {
			const line = lines[i].trim();
			if (line === "") continue;
			const decoded = this.decodeJsonLine(line);
			const record = this.decodeHistoryRecord(decoded);
			if (record) {
				records.push(record);
			}
		}
		return records;
	}

	private saveHistoryRecords(records: HistoryRecord[]): void {
		this.ensureDir(Path.getPath(this.historyPath));
		const normalized = records.length > HISTORY_MAX_RECORDS
			? records.slice(records.length - HISTORY_MAX_RECORDS)
			: records;
		const lines: string[] = [];
		for (let i = 0; i < normalized.length; i++) {
			const line = this.encodeJsonLine(normalized[i]);
			if (line) {
				lines.push(line);
			}
		}
		const content = lines.length > 0 ? `${lines.join("\n")}\n` : "";
		Content.save(this.historyPath, content);
		sendWebIDEFileUpdate(this.historyPath, true, content);
	}

	// ===== MEMORY.md 操作 =====

	/**
	 * 读取长期记忆
	 */
	readMemory(): string {
		if (!Content.exist(this.memoryPath)) {
			return "";
		}
		return Content.load(this.memoryPath) as string;
	}

	/**
	 * 写入长期记忆
	 */
	writeMemory(content: string): void {
		this.ensureDir(Path.getPath(this.memoryPath));
		Content.save(this.memoryPath, content);
	}

	/**
	 * 生成注入到 prompt 的记忆上下文
	 */
	getMemoryContext(): string {
		const memory = this.readMemory();
		if (!memory) return "";

		return `### Long-term Memory

${memory}`;
	}

	// ===== HISTORY.jsonl 操作 =====

	appendHistoryRecord(record: HistoryRecord): void {
		const records = this.readHistoryRecords();
		records.push(record);
		this.saveHistoryRecords(records);
	}

	readSessionState(): PersistedSessionState {
		if (!Content.exist(this.sessionPath)) {
			return { messages: [], lastConsolidatedIndex: 0 };
		}
		const text = Content.load(this.sessionPath) as string;
		if (!text || text.trim() === "") {
			return { messages: [], lastConsolidatedIndex: 0 };
		}
		const lines = text.split("\n");
		const messages: AgentConversationMessage[] = [];
		let lastConsolidatedIndex = 0;
		let carryMessageIndex: number | undefined = undefined;
		for (let i = 0; i < lines.length; i++) {
			const line = lines[i].trim();
			if (line === "") continue;
			const data = this.decodeJsonLine(line);
			if (!data || isArray(data) || !isRecord(data)) continue;
			const row = data;
			if (typeof row.lastConsolidatedIndex === "number") {
				lastConsolidatedIndex = math.floor(row.lastConsolidatedIndex);
				if (typeof row.carryMessageIndex === "number") {
					carryMessageIndex = math.floor(row.carryMessageIndex);
				}
				continue;
			}
			const message = this.decodeConversationMessage(row.message ?? row);
			if (message) {
				messages.push(message);
			}
		}
		const normalizedLastConsolidatedIndex = clampSessionIndex(messages, lastConsolidatedIndex);
		const normalizedCarryMessageIndex = typeof carryMessageIndex === "number"
			&& carryMessageIndex >= 0
			&& carryMessageIndex < normalizedLastConsolidatedIndex
			&& carryMessageIndex < messages.length
			? math.floor(carryMessageIndex)
			: undefined;
		return {
			messages,
			lastConsolidatedIndex: normalizedLastConsolidatedIndex,
			carryMessageIndex: normalizedCarryMessageIndex,
		};
	}

	writeSessionState(
		messages: AgentConversationMessage[] = [],
		lastConsolidatedIndex = 0,
		carryMessageIndex?: number
	): void {
		this.ensureDir(Path.getPath(this.sessionPath));
		const lines: string[] = [];
		const dropCount = messages.length > SESSION_MAX_RECORDS
			? messages.length - SESSION_MAX_RECORDS
			: 0;
		const normalizedMessages = dropCount > 0
			? messages.slice(dropCount)
			: messages;
		const normalizedLastConsolidatedIndex = clampSessionIndex(
			normalizedMessages,
			lastConsolidatedIndex - dropCount
		);
		const normalizedCarryMessageIndex = typeof carryMessageIndex === "number"
			&& carryMessageIndex - dropCount >= 0
			&& carryMessageIndex - dropCount < normalizedLastConsolidatedIndex
			&& carryMessageIndex - dropCount < normalizedMessages.length
			? math.floor(carryMessageIndex - dropCount)
			: undefined;
		const stateLine = this.encodeJsonLine({
			lastConsolidatedIndex: normalizedLastConsolidatedIndex,
			carryMessageIndex: normalizedCarryMessageIndex,
		});
		if (stateLine) {
			lines.push(stateLine);
		}
		for (let i = 0; i < normalizedMessages.length; i++) {
			const line = this.encodeJsonLine({
				message: normalizedMessages[i],
			});
			if (line) {
				lines.push(line);
			}
		}
		const content = lines.length > 0 ? `${lines.join("\n")}\n` : "";
		Content.save(this.sessionPath, content);
		sendWebIDEFileUpdate(this.sessionPath, true, content);
	}
}

/**
 * Memory 压缩器
 *
 * 负责：
 * 1. 判断是否需要压缩
 * 2. 执行 LLM 压缩
 * 3. 更新存储
 */
export class MemoryCompressor {
	private storage: DualLayerStorage;
	private config: Omit<MemoryConfig, "promptPack"> & { promptPack: AgentPromptPack };
	private consecutiveFailures: number = 0;

	private static readonly MAX_FAILURES = 3;

	constructor(config: MemoryConfig) {
		const loadedPromptPack = loadAgentPromptPack(config.projectDir);
		for (let i = 0; i < loadedPromptPack.warnings.length; i++) {
			Log("Warn", `[Agent] ${loadedPromptPack.warnings[i]}`);
		}
		const overridePack = (config.promptPack && !isArray(config.promptPack) && isRecord(config.promptPack))
			? config.promptPack
			: undefined;
		this.config = {
			...config,
			promptPack: resolveAgentPromptPack({
				...(loadedPromptPack.pack as unknown as Record<string, unknown>),
				...(overridePack ?? {}),
			}),
		};
		this.config.compressionThreshold = math.min(1, math.max(0.05, this.config.compressionThreshold));
		this.config.compressionTargetThreshold = math.min(
			this.config.compressionThreshold,
			math.max(0.05, this.config.compressionTargetThreshold)
		);
		this.storage = new DualLayerStorage(this.config.projectDir, this.config.scope ?? "");
	}

	getPromptPack(): AgentPromptPack {
		return this.config.promptPack;
	}

	/**
	 * 检查是否需要压缩
	 */
	shouldCompress(
		messages: Message[],
		systemPrompt: string,
		toolDefinitions: string
	): boolean {
		const messageTokens = TokenEstimator.estimatePromptMessages(
			messages,
			systemPrompt,
			toolDefinitions
		);

		const threshold = this.getContextWindow() * this.config.compressionThreshold;

		return messageTokens > threshold;
	}

	/**
	 * 执行压缩
	 */
	async compress(
		messages: AgentConversationMessage[],
		llmOptions: Record<string, unknown>,
		maxLLMTry?: number,
		decisionMode: MemoryCompressionDecisionMode = "tool_calling",
		debugContext?: MemoryCompressionDebugContext,
		boundaryMode: MemoryCompressionBoundaryMode = "default",
		systemPrompt = "",
		toolDefinitions = ""
	): Promise<CompressionResult | null> {
		const toCompress = messages;
		if (toCompress.length === 0) return null;
		const currentMemory = this.storage.readMemory();

		const boundary = this.findCompressionBoundary(
			toCompress,
			currentMemory,
			boundaryMode,
			systemPrompt,
			toolDefinitions
		);
		const chunk = toCompress.slice(0, boundary.chunkEnd);

		if (chunk.length === 0) return null;
		const historyText = this.formatMessagesForCompression(chunk);

		try {
			// 调用 LLM 压缩
			const result = await this.callLLMForCompression(
				currentMemory,
				historyText,
				llmOptions,
				maxLLMTry ?? 3,
				decisionMode,
				debugContext
			);

			if (result.success) {
				// 成功：写入存储
				this.storage.writeMemory(result.memoryUpdate);
				if (result.ts) {
					this.storage.appendHistoryRecord({
						ts: result.ts,
						summary: result.summary,
					});
				}
				this.consecutiveFailures = 0;

				return {
					...result,
					compressedCount: boundary.compressedCount,
					carryMessageIndex: boundary.carryMessageIndex,
				};
			}

			// LLM 返回失败
			return this.handleCompressionFailure(chunk, result.error || "Unknown error");

		} catch (error) {
			return this.handleCompressionFailure(chunk, error instanceof Error ? error.message : "Unknown error");
		}
	}

	/**
	 * 找到压缩边界
	 *
	 * 策略：在用户相关操作处切分，保持对话完整性
	 */
	private findCompressionBoundary(
		messages: AgentConversationMessage[],
		currentMemory: string,
		boundaryMode: MemoryCompressionBoundaryMode,
		systemPrompt: string,
		toolDefinitions: string
	): CompressionBoundarySelection {
		const targetTokens = boundaryMode === "budget_max"
			? math.max(1, this.getCompressionHistoryTokenBudget(currentMemory))
			: math.max(1, this.getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions));
		let accumulatedTokens = 0;
		let lastSafeBoundary = 0;
		let lastSafeBoundaryWithinBudget = 0;
		let lastClosedBoundary = 0;
		let lastClosedBoundaryWithinBudget = 0;
		const pendingToolCalls: Record<string, boolean> = {};
		let pendingToolCallCount = 0;
		let exceededBudget = false;

		for (let i = 0; i < messages.length; i++) {
			const message = messages[i];
			const tokens = this.estimateCompressionMessageTokens(message, i);
			accumulatedTokens += tokens;

			if (message.role === "assistant" && message.tool_calls && message.tool_calls.length > 0) {
				for (let j = 0; j < message.tool_calls.length; j++) {
					const toolCallEntry: ToolCall = message.tool_calls[j];
					const idValue = toolCallEntry.id;
					const id = typeof idValue === "string" ? idValue : "";
					if (id !== "" && !pendingToolCalls[id]) {
						pendingToolCalls[id] = true;
						pendingToolCallCount += 1;
					}
				}
			}

			if (message.role === "tool" && message.tool_call_id && pendingToolCalls[message.tool_call_id]) {
				pendingToolCalls[message.tool_call_id] = false;
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1);
			}

			const isAtEnd = i >= messages.length - 1;
			const nextRole = !isAtEnd ? messages[i + 1].role : "";
			const isUserTurnBoundary = !isAtEnd && nextRole === "user";
			const isSafeBoundary = pendingToolCallCount === 0 && (isAtEnd || isUserTurnBoundary);
			const isClosedToolBoundary = pendingToolCallCount === 0 && i > 0;
			if (isSafeBoundary) {
				lastSafeBoundary = i + 1;
				if (accumulatedTokens <= targetTokens) {
					lastSafeBoundaryWithinBudget = i + 1;
				}
			}
			if (isClosedToolBoundary) {
				lastClosedBoundary = i + 1;
				if (accumulatedTokens <= targetTokens) {
					lastClosedBoundaryWithinBudget = i + 1;
				}
			}

			if (accumulatedTokens > targetTokens && !exceededBudget) {
				exceededBudget = true;
			}

			// When budget exceeded, continue scanning until we find a usable boundary
			if (exceededBudget && isSafeBoundary) {
				return this.buildCarryBoundary(messages, i + 1);
			}
		}

		if (lastSafeBoundaryWithinBudget > 0) {
			return { chunkEnd: lastSafeBoundaryWithinBudget, compressedCount: lastSafeBoundaryWithinBudget };
		}
		if (lastSafeBoundary > 0) {
			return { chunkEnd: lastSafeBoundary, compressedCount: lastSafeBoundary };
		}
		if (lastClosedBoundaryWithinBudget > 0) {
			return this.buildCarryBoundary(messages, lastClosedBoundaryWithinBudget);
		}
		if (lastClosedBoundary > 0) {
			return this.buildCarryBoundary(messages, lastClosedBoundary);
		}
		const fallback = math.min(messages.length, 1);
		return { chunkEnd: fallback, compressedCount: fallback };
	}

	private buildCarryBoundary(messages: AgentConversationMessage[], chunkEnd: number): CompressionBoundarySelection {
		let carryUserIndex = -1;
		for (let i = 0; i < chunkEnd; i++) {
			if (messages[i].role === "user") {
				carryUserIndex = i;
			}
		}
		if (carryUserIndex < 0) {
			return { chunkEnd, compressedCount: chunkEnd };
		}
		return {
			chunkEnd,
			compressedCount: chunkEnd,
			carryMessageIndex: carryUserIndex,
		};
	}

	private estimateCompressionMessageTokens(message: AgentConversationMessage, index: number): number {
		const lines: string[] = [];
		lines.push(`Message ${index + 1}: role=${message.role}`);
		if (message.name && message.name !== "") lines.push(`name=${message.name}`);
		if (message.tool_call_id && message.tool_call_id !== "") lines.push(`tool_call_id=${message.tool_call_id}`);
		if (message.reasoning_content && message.reasoning_content !== "") lines.push(`reasoning=${message.reasoning_content}`);
		if (message.tool_calls && message.tool_calls.length > 0) {
			const [toolCallsText] = safeJsonEncode(message.tool_calls as object);
			lines.push(`tool_calls=${toolCallsText ?? ""}`);
		}
		if (message.content && message.content !== "") lines.push(message.content);
		const prefix = index > 0 ? "\n\n" : "";
		return TokenEstimator.estimate(prefix + lines.join("\n"));
	}

	private getRequiredCompressionTokens(
		messages: AgentConversationMessage[],
		systemPrompt: string,
		toolDefinitions: string
	): number {
		const currentTokens = TokenEstimator.estimatePromptMessages(
			messages,
			systemPrompt,
			toolDefinitions
		);
		const threshold = this.getContextWindow() * this.config.compressionTargetThreshold;
		const overflow = math.max(0, currentTokens - threshold);
		if (overflow <= 0) {
			return math.max(1, this.estimateCompressionMessageTokens(messages[0], 0));
		}
		const safetyMargin = math.max(64, math.floor(threshold * 0.01));
		return overflow + safetyMargin;
	}

	private formatMessagesForCompression(messages: AgentConversationMessage[]): string {
		const lines: string[] = [];
		for (let i = 0; i < messages.length; i++) {
			const message = messages[i];
			lines.push(`Message ${i + 1}: role=${message.role}`);
			if (message.name && message.name !== "") lines.push(`name=${message.name}`);
			if (message.tool_call_id && message.tool_call_id !== "") lines.push(`tool_call_id=${message.tool_call_id}`);
			if (message.reasoning_content && message.reasoning_content !== "") lines.push(`reasoning=${message.reasoning_content}`);
			if (message.tool_calls && message.tool_calls.length > 0) {
				const [toolCallsText] = safeJsonEncode(message.tool_calls as object);
				lines.push(`tool_calls=${toolCallsText ?? ""}`);
			}
			if (message.content && message.content !== "") lines.push(message.content);
			if (i < messages.length - 1) lines.push("");
		}
		return lines.join("\n");
	}

	/**
	 * 调用 LLM 执行压缩
	 */
	private async callLLMForCompression(
		currentMemory: string,
		historyText: string,
		llmOptions: Record<string, unknown>,
		maxLLMTry: number,
		decisionMode: MemoryCompressionDecisionMode,
		debugContext?: MemoryCompressionDebugContext
	): Promise<CompressionResult> {
		const boundedHistoryText = this.boundCompressionHistoryText(currentMemory, historyText);
		if (decisionMode === "xml") {
			return this.callLLMForCompressionByXML(
				currentMemory,
				boundedHistoryText,
				llmOptions,
				maxLLMTry,
				debugContext
			);
		}
		return this.callLLMForCompressionByToolCalling(
			currentMemory,
			boundedHistoryText,
			llmOptions,
			maxLLMTry,
			debugContext
		);
	}

	private getContextWindow(): number {
		return Math.max(4000, this.config.llmConfig.contextWindow);
	}

	private getCompressionHistoryTokenBudget(currentMemory: string): number {
		const contextWindow = this.getContextWindow();
		const reservedOutputTokens = Math.max(2048, Math.floor(contextWindow * 0.2));
		const staticPromptTokens = TokenEstimator.estimate(this.buildCompressionStaticPrompt("tool_calling"));
		const memoryTokens = TokenEstimator.estimate(currentMemory);
		const available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens;
		return Math.max(1200, Math.floor(available * 0.9));
	}

	private boundCompressionHistoryText(currentMemory: string, historyText: string): string {
		const historyTokens = TokenEstimator.estimate(historyText);
		const tokenBudget = this.getCompressionHistoryTokenBudget(currentMemory);
		if (historyTokens <= tokenBudget) return historyText;
		const charsPerToken = historyTokens > 0
			? historyText.length / historyTokens
			: 4;
		const targetChars = Math.max(2000, Math.floor(tokenBudget * charsPerToken));
		const keepHead = Math.max(0, Math.floor(targetChars * 0.35));
		const keepTail = Math.max(0, targetChars - keepHead);
		const head = keepHead > 0 ? utf8TakeHead(historyText, keepHead) : "";
		const tail = keepTail > 0 ? utf8TakeTail(historyText, keepTail) : "";
		return `[compression history truncated to fit context window; token_budget=${tokenBudget}, original_tokens=${historyTokens}]\n${head}\n...\n${tail}`;
	}

	private buildBoundedCompressionSections(currentMemory: string, historyText: string): {
		currentMemory: string;
		historyText: string;
	} {
		const contextWindow = this.getContextWindow();
		const reservedOutputTokens = Math.max(2048, math.floor(contextWindow * 0.2));
		const staticPromptTokens = TokenEstimator.estimate(this.buildCompressionStaticPrompt("tool_calling"));
		const dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256);
		const boundedMemory = clipTextToTokenBudget(currentMemory || "(empty)", math.max(320, math.floor(dynamicBudget * 0.35)));
		const boundedHistory = clipTextToTokenBudget(historyText, math.max(800, math.floor(dynamicBudget * 0.65)));
		return {
			currentMemory: boundedMemory,
			historyText: boundedHistory,
		};
	}

	private async callLLMForCompressionByToolCalling(
		currentMemory: string,
		historyText: string,
		llmOptions: Record<string, unknown>,
		maxLLMTry: number,
		debugContext?: MemoryCompressionDebugContext
	): Promise<CompressionResult> {
		const prompt = this.buildCompressionPromptBody(currentMemory, historyText);

		// 定义 save_memory 工具
		const tools = [{
			type: "function" as const,
			function: {
				name: "save_memory",
				description: "Save the memory consolidation result to persistent storage.",
				parameters: {
					type: "object",
					properties: {
						history_entry: {
							type: "string",
							description: "A paragraph summarizing key events/decisions/topics. " +
								"Include detail useful for grep search."
						},
						memory_update: {
							type: "string",
							description: "Full updated long-term memory as markdown. " +
								"Include all existing facts plus new ones."
						},
					},
					required: ["history_entry", "memory_update"],
				},
			},
		}];

		const messages: Message[] = [
			{
				role: "system",
				content: this.buildToolCallingCompressionSystemPrompt(),
			},
			{
				role: "user",
				content: prompt
			}
		];

		let fn: ToolCallFunction | undefined;
		let argsText = "";
		for (let i = 0; i < maxLLMTry; i++) {
			debugContext?.onInput?.("memory_compression_tool_calling", messages, {
				...llmOptions,
				tools,
				tool_choice: { type: "function", function: { name: "save_memory" } },
			});
			// 调用 LLM，强制使用 save_memory 工具
			const response = await callLLM(
				messages,
				{
					...llmOptions,
					tools,
					tool_choice: { type: "function", function: { name: "save_memory" } },
				},
				undefined,
				this.config.llmConfig
			);

			if (!response.success) {
				debugContext?.onOutput?.("memory_compression_tool_calling", response.raw ?? response.message, { success: false });
				return {
					success: false,
					memoryUpdate: currentMemory,
					compressedCount: 0,
					error: response.message,
				};
			}
			debugContext?.onOutput?.("memory_compression_tool_calling", encodeCompressionDebugJSON(response.response), { success: true });

			const choice = response.response.choices && response.response.choices[0];
			const message = choice && choice.message;
			const toolCalls = message && message.tool_calls;
			const toolCall = toolCalls && toolCalls[0];
			fn = toolCall && toolCall.function;
			argsText = fn && typeof fn.arguments === "string" ? fn.arguments : "";
			if (fn !== undefined && argsText.length > 0) break;
		}

		if (!fn || fn.name !== "save_memory") {
			return {
				success: false,
				memoryUpdate: currentMemory,
				compressedCount: 0,
				error: "missing save_memory tool call",
			};
		}

		if (argsText.trim() === "") {
			return {
				success: false,
				memoryUpdate: currentMemory,
				compressedCount: 0,
				error: "empty save_memory tool arguments",
			};
		}

		// 解析 tool arguments JSON
		try {
			const [args, err] = safeJsonDecode(argsText);
			if (err !== undefined || !args || typeof args !== "object") {
				return {
					success: false,
					memoryUpdate: currentMemory,
					compressedCount: 0,
					error: `Failed to parse tool arguments JSON: ${tostring(err)}`,
				};
			}

			return this.buildCompressionResultFromObject(
				args as Record<string, unknown>,
				currentMemory
			);
		} catch (error) {
			return {
				success: false,
				memoryUpdate: currentMemory,
				compressedCount: 0,
				error: `Failed to process LLM response: ${error instanceof Error ? error.message : tostring(error)}`,
			};
		}
	}

	private async callLLMForCompressionByXML(
		currentMemory: string,
		historyText: string,
		llmOptions: Record<string, unknown>,
		maxLLMTry: number,
		debugContext?: MemoryCompressionDebugContext
	): Promise<CompressionResult> {
		const prompt = this.buildCompressionPromptBody(currentMemory, historyText);
		let lastError = "invalid xml response";

		for (let i = 0; i < maxLLMTry; i++) {
			const feedback = i > 0
				? `\n\n${replaceTemplateVars(this.config.promptPack.memoryCompressionXmlRetryPrompt, {
					LAST_ERROR: lastError,
				})}`
				: "";
			const requestMessages: Message[] = [
				{ role: "system", content: this.buildXMLCompressionSystemPrompt() },
				{ role: "user", content: `${prompt}${feedback}` },
			];
			debugContext?.onInput?.("memory_compression_xml", requestMessages, llmOptions);
			const response = await callLLM(
				requestMessages,
				llmOptions,
				undefined,
				this.config.llmConfig
			);

			if (!response.success) {
				debugContext?.onOutput?.("memory_compression_xml", response.raw ?? response.message, { success: false });
				return {
					success: false,
					memoryUpdate: currentMemory,
					compressedCount: 0,
					error: response.message,
				};
			}

			const choice = response.response.choices && response.response.choices[0];
			const message = choice && choice.message;
			const text = message && typeof message.content === "string" ? message.content : "";
			debugContext?.onOutput?.("memory_compression_xml", text !== "" ? text : encodeCompressionDebugJSON(response.response), { success: true });
			if (text.trim() === "") {
				lastError = "empty xml response";
				continue;
			}

			const parsed = this.parseCompressionXMLObject(text, currentMemory);
			if (parsed.success) {
				return parsed;
			}
			lastError = parsed.error || "invalid xml response";
		}

		return {
			success: false,
			memoryUpdate: currentMemory,
			compressedCount: 0,
			error: lastError,
		};
	}

	/**
	 * 构建压缩提示
	 */
	private buildCompressionPromptBodyRaw(currentMemory: string, historyText: string): string {
		return replaceTemplateVars(this.config.promptPack.memoryCompressionBodyPrompt, {
			CURRENT_MEMORY: currentMemory || "(empty)",
			HISTORY_TEXT: historyText,
		});
	}

	private buildCompressionPromptBody(currentMemory: string, historyText: string): string {
		const bounded = this.buildBoundedCompressionSections(currentMemory, historyText);
		return replaceTemplateVars(this.config.promptPack.memoryCompressionBodyPrompt, {
			CURRENT_MEMORY: bounded.currentMemory,
			HISTORY_TEXT: bounded.historyText,
		});
	}

	private buildCompressionStaticPrompt(mode: MemoryCompressionDecisionMode): string {
		const formatPrompt = mode === "xml"
			? this.config.promptPack.memoryCompressionXmlPrompt
			: this.config.promptPack.memoryCompressionToolCallingPrompt;
		return `${this.config.promptPack.memoryCompressionSystemPrompt}

${formatPrompt}

${this.buildCompressionPromptBodyRaw("", "")}`;
	}

	private buildToolCallingCompressionSystemPrompt(): string {
		return `${this.config.promptPack.memoryCompressionSystemPrompt}

${this.config.promptPack.memoryCompressionToolCallingPrompt}`;
	}

	private buildXMLCompressionSystemPrompt(): string {
		return `${this.config.promptPack.memoryCompressionSystemPrompt}

${this.config.promptPack.memoryCompressionXmlPrompt}`;
	}

	private parseCompressionXMLObject(text: string, currentMemory: string): CompressionResult {
		const parsed = parseXMLObjectFromText(text, "memory_update_result");
		if (!parsed.success) {
			return {
				success: false,
				memoryUpdate: currentMemory,
				compressedCount: 0,
				error: parsed.message,
			};
		}
		return this.buildCompressionResultFromObject(
			parsed.obj,
			currentMemory
		);
	}

	private buildCompressionResultFromObject(
		obj: Record<string, unknown>,
		currentMemory: string
	): CompressionResult {
		const historyEntry = typeof obj.history_entry === "string" ? obj.history_entry : "";
		const memoryBody = typeof obj.memory_update === "string" ? obj.memory_update : currentMemory;
		if (historyEntry.trim() === "" || memoryBody.trim() === "") {
			return {
				success: false,
				memoryUpdate: currentMemory,
				compressedCount: 0,
				error: "missing history_entry or memory_update",
			};
		}
		const ts = os.date("%Y-%m-%d %H:%M");
		return {
			success: true,
			memoryUpdate: memoryBody,
			ts,
			summary: historyEntry,
			compressedCount: 0,
		};
	}

	/**
	 * 处理压缩失败
	 */
	private handleCompressionFailure(
		chunk: AgentConversationMessage[],
		error: string
	): CompressionResult {
		this.consecutiveFailures++;

		if (this.consecutiveFailures >= MemoryCompressor.MAX_FAILURES) {
			const archived = this.rawArchive(chunk);
			this.consecutiveFailures = 0;

			return {
				success: true,
				memoryUpdate: this.storage.readMemory(),
				ts: archived.ts,
				compressedCount: chunk.length,
			};
		}

		return {
			success: false,
			memoryUpdate: this.storage.readMemory(),
			compressedCount: 0,
			error,
		};
	}

	/**
	 * 原始归档（降级方案）
	 */
	private rawArchive(chunk: AgentConversationMessage[]): { ts: string } {
		const ts = os.date("%Y-%m-%d %H:%M");
		const rawArchive = this.formatMessagesForCompression(chunk);
		this.storage.appendHistoryRecord({
			ts,
			rawArchive,
		});
		return { ts };
	}

	/**
	 * 获取存储实例（用于读取 memory context）
	 */
	getStorage(): DualLayerStorage {
		return this.storage;
	}

	getMaxCompressionRounds(): number {
		return math.max(1, math.floor(this.config.maxCompressionRounds));
	}
}

export async function compactSessionMemoryScope(options: {
	projectDir: string;
	scope?: string;
	llmConfig?: LLMConfig;
	llmOptions?: Record<string, unknown>;
	llmMaxTry?: number;
	promptPack?: Partial<AgentPromptPack> | AgentPromptPack;
	decisionMode?: MemoryCompressionDecisionMode;
}): Promise<{ success: true; remainingMessages: number } | { success: false; message: string }> {
	const llmConfigRes = options.llmConfig
		? { success: true as const, config: options.llmConfig }
		: getActiveLLMConfig();
	if (!llmConfigRes.success) {
		return { success: false, message: llmConfigRes.message };
	}
	const compressor = new MemoryCompressor({
		compressionThreshold: 0.8,
		compressionTargetThreshold: 0.5,
		maxCompressionRounds: 3,
		projectDir: options.projectDir,
		llmConfig: llmConfigRes.config,
		promptPack: options.promptPack,
		scope: options.scope,
	});
	const storage = compressor.getStorage();
	const persistedSession = storage.readSessionState();
	let messages = persistedSession.messages;
	let lastConsolidatedIndex = persistedSession.lastConsolidatedIndex;
	let carryMessageIndex = persistedSession.carryMessageIndex;
	const llmOptions = {
		temperature: 0.1,
		max_tokens: 8192,
		...(options.llmOptions ?? {}),
	};
	while (lastConsolidatedIndex < messages.length) {
		const activeMessages: AgentConversationMessage[] = [];
		if (
			typeof carryMessageIndex === "number"
			&& carryMessageIndex >= 0
			&& carryMessageIndex < lastConsolidatedIndex
			&& carryMessageIndex < messages.length
		) {
			activeMessages.push({
				...messages[carryMessageIndex],
			});
		}
		for (let i = lastConsolidatedIndex; i < messages.length; i++) {
			activeMessages.push(messages[i]);
		}
		const result = await compressor.compress(
			activeMessages,
			llmOptions,
			math.max(1, math.floor(options.llmMaxTry ?? 5)),
			options.decisionMode ?? "tool_calling",
			undefined,
			"budget_max"
		);
		if (!(result && result.success && result.compressedCount > 0)) {
			return {
				success: false,
				message: result?.error ?? "memory compaction produced no progress",
			};
		}
		const syntheticPrefixCount = activeMessages.length > 0
			&& lastConsolidatedIndex < messages.length
			&& activeMessages[0] !== messages[lastConsolidatedIndex]
			? 1
			: 0;
		const realCompressedCount = math.max(0, result.compressedCount - syntheticPrefixCount);
		lastConsolidatedIndex = math.min(messages.length, lastConsolidatedIndex + realCompressedCount);
		if (typeof result.carryMessageIndex === "number") {
			if (syntheticPrefixCount > 0 && result.carryMessageIndex === 0) {
				// Reuse the previously carried user message.
			} else {
				const carryOffset = syntheticPrefixCount > 0
					? result.carryMessageIndex - 1
					: result.carryMessageIndex;
				carryMessageIndex = carryOffset >= 0
					? lastConsolidatedIndex - realCompressedCount + carryOffset
					: undefined;
			}
		} else {
			carryMessageIndex = undefined;
		}
		if (
			typeof carryMessageIndex === "number"
			&& (carryMessageIndex < 0 || carryMessageIndex >= lastConsolidatedIndex || carryMessageIndex >= messages.length)
		) {
			carryMessageIndex = undefined;
		}
		storage.writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex);
	}
	return { success: true, remainingMessages: messages.length - lastConsolidatedIndex };
}
