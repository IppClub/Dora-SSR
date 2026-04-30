// @preview-file off clear
import { App, Content, Path } from 'Dora';
import { Message, ToolCallFunction, callLLM, Log, clipTextToTokenBudget, parseXMLObjectFromText, safeJsonDecode, safeJsonEncode, sanitizeUTF8 } from 'Agent/Utils';
import { getActiveLLMConfig } from 'Agent/Utils';
import type { LLMConfig, ToolCall } from 'Agent/Utils';
import { sendWebIDEFileUpdate } from 'Agent/Tools';

const MEMORY_DEFAULT_LLM_TEMPERATURE = 0.1;
const MEMORY_DEFAULT_LLM_MAX_TOKENS = 8192;
const MEMORY_DEFAULT_CONTEXT_WINDOW = 64000;
const AGENT_MEMORY_CONTEXT_MIN_TOKENS = 1200;
const AGENT_MEMORY_CONTEXT_WINDOW_RATIO = 0.08;
const COMPRESSION_RESERVED_OUTPUT_MIN_TOKENS = 2048;
const COMPRESSION_RESERVED_OUTPUT_CONTEXT_RATIO = 0.2;
const COMPRESSION_HISTORY_MIN_TOKENS = 1200;
const COMPRESSION_HISTORY_AVAILABLE_RATIO = 0.9;
const COMPRESSION_HISTORY_TRUNCATED_MIN_CHARS = 2000;
const COMPRESSION_HISTORY_TRUNCATED_HEAD_RATIO = 0.35;
const COMPRESSION_DYNAMIC_MIN_TOKENS = 1600;
const COMPRESSION_DYNAMIC_PROMPT_OVERHEAD_TOKENS = 256;
const COMPRESSION_SECTION_MEMORY_MIN_TOKENS = 320;
const COMPRESSION_SECTION_MEMORY_RATIO = 0.2;
const COMPRESSION_SECTION_SESSION_MIN_TOKENS = 240;
const COMPRESSION_SECTION_SESSION_RATIO = 0.15;
const COMPRESSION_SECTION_HISTORY_MIN_TOKENS = 800;
const COMPRESSION_SECTION_HISTORY_RATIO = 0.45;

function buildMemoryLLMOptions(llmConfig: LLMConfig, overrides?: Record<string, unknown>): Record<string, unknown> {
	const options: Record<string, unknown> = {
		temperature: llmConfig.temperature ?? MEMORY_DEFAULT_LLM_TEMPERATURE,
		max_tokens: llmConfig.maxTokens ?? MEMORY_DEFAULT_LLM_MAX_TOKENS,
	};
	if (llmConfig.reasoningEffort) {
		options.reasoning_effort = llmConfig.reasoningEffort;
	}
	const merged = {
		...options,
		...(overrides ?? {}),
	};
	if (typeof merged.reasoning_effort !== "string" || merged.reasoning_effort.trim() === "") {
		delete merged.reasoning_effort;
	} else {
		merged.reasoning_effort = merged.reasoning_effort.trim();
	}
	return merged;
}

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

interface SubAgentLearningEntry {
	sourceSessionId: number;
	sourceTaskId: number;
	content: string;
	evidence: string[];
	createdAt: string;
	sortTs: number;
}

function clampSessionIndex(messages: AgentConversationMessage[], index?: number): number {
	if (typeof index !== "number") return 0;
	if (index <= 0) return 0;
	return math.min(messages.length, math.floor(index));
}

const AGENT_CONFIG_DIR = ".agent";
const AGENT_PROMPTS_FILE = "AGENT.md";
const NO_PROMPT_PACK_SECTIONS_ERROR = "no prompt pack sections found";
const HISTORY_JSONL_FILE = "HISTORY.jsonl";
const HISTORY_MAX_RECORDS = 1000;
const SESSION_MAX_RECORDS = 1000;
const SUB_AGENT_SPAWN_INFO_FILE = "SPAWN.json";
const SUB_AGENT_LEARNINGS_MAX_ITEMS = 10;
const SUB_AGENT_LEARNINGS_MAX_CHARS = 5000;
const SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200;
const SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5;
const DEFAULT_CORE_MEMORY_TEMPLATE = `## Core Memory

### User Preferences

### Stable Facts

### Known Decisions

### Known Issues
`;
const DEFAULT_PROJECT_MEMORY_TEMPLATE = `## Project Memory

### Project Facts

### Build And Run

### Files And Architecture

### Decisions

### Known Issues
`;
const DEFAULT_SESSION_SUMMARY_TEMPLATE = `## Session Summary

### Current Goal

### Recent Progress

### Open Issues
`;
const MEMORY_CONTEXT_DEFAULT_MAX_TOKENS = 4000;
const MEMORY_CONTEXT_MIN_MAX_TOKENS = 800;
const MEMORY_LAYER_MIN_TOKENS = 300;

interface MemoryTextSection {
	title: string;
	body: string;
	fullText: string;
	index: number;
	score: number;
}

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
	mainAgentRolePrompt: string;
	subAgentRolePrompt: string;
	functionCallingPrompt: string;
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
	agentIdentityPrompt: `# Dora Agent

You are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.

# Guidelines

- State intent before tool calls, but NEVER predict or claim results before receiving them.
- Before modifying a file, read it first. Do not assume files or directories exist.
- After writing or editing a file, re-read it if accuracy matters.
- If a tool call fails, analyze the error before retrying with a different approach.
- Ask for clarification when the request is ambiguous.
- Prefer reading and searching before editing when information is missing.
- Focus on outcomes, not tool names. Speak directly to the user.`,
	mainAgentRolePrompt: `# Agent Role

You are the main agent. Your job is to discuss plans with the user, inspect the codebase, make direct edits when that is the simplest path, and delegate larger or parallelizable implementation work by spawning sub agents.

Rules:
- You may use the full toolset directly, including edit_file, delete_file, and build.
- Use direct tools for small, focused, or user-interactive changes where staying in the current run gives the clearest result.
- Use spawn_sub_agent for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.
- Use list_sub_agents only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether another delegation is necessary or whether to read a result file.
- Keep sub-agent titles short and specific.
- The sub-agent prompt should be self-contained and executable, and should explain the exact task, constraints, expected output, and relevant files when known.
- After spawn_sub_agent succeeds, immediately finish the current turn and tell the user the work has been delegated.
- After a successful spawn_sub_agent, do not call list_sub_agents or any other tool in the same turn.
- Treat the sub-agent completion result as an asynchronous handoff that should be continued in later conversation turns.`,
	subAgentRolePrompt: `# Agent Role

You are a sub agent. Your job is to execute concrete implementation, editing, and build work delegated by the main agent.

Rules:
- Focus on completing the delegated task end-to-end.
- Use the available implementation tools directly when needed, including edit_file, delete_file, and build.
- Documentation writing tasks are also part of your execution scope when delegated by the main agent.
- Summaries should stay concise and execution-oriented.`,
	functionCallingPrompt: `# Function Calling

You may return multiple tool calls in one response when the calls are independent and all results are useful before the next reasoning step.`,
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
	toolCallingRetryPrompt: "Previous response was invalid ({{LAST_ERROR}}). Retry with one or more valid tool calls.",
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
	- Separate updates into Core Memory, Project Memory, and Session Summary

4. Create History Entry
	- Create a summary paragraph
	- Include key topics
	- Make it grep-searchable

Call the save_memory tool with your consolidated memory and history entry.`,
	memoryCompressionBodyPrompt: `# Current Core Memory

{{CURRENT_MEMORY}}

# Current Project Memory

{{CURRENT_PROJECT_MEMORY}}

# Current Session Summary

{{CURRENT_SESSION_SUMMARY}}

# Actions to Process

{{HISTORY_TEXT}}`,
	memoryCompressionToolCallingPrompt: `### Output Format

Call the save_memory tool with:
- history_entry: the summary paragraph without timestamp
- memory_update: the full updated MEMORY.md content (Core Memory only)
- project_memory_update: optional full updated PROJECT_MEMORY.md content; omit or leave empty to keep the current content
- session_summary_update: optional full updated SESSION_SUMMARY.md content; omit or leave empty to keep the current content`,
	memoryCompressionXmlPrompt: `### Output Format

Return exactly one XML block:
\`\`\`xml
<memory_update_result>
	<history_entry>Summary paragraph</history_entry>
	<memory_update>
Full updated MEMORY.md content (Core Memory only)
	</memory_update>
	<project_memory_update>
Full updated PROJECT_MEMORY.md content
	</project_memory_update>
	<session_summary_update>
Full updated SESSION_SUMMARY.md content
	</session_summary_update>
</memory_update_result>
\`\`\`

Rules:
- Return XML only, no prose before or after.
- Use exactly one root tag: \`<memory_update_result>\`.
- Include \`<history_entry>\` and \`<memory_update>\`. \`<project_memory_update>\` and \`<session_summary_update>\` are optional; omit them to keep current content.
- Use CDATA for markdown update fields when they span multiple lines or contain markdown/code.`,
	memoryCompressionXmlRetryPrompt: "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only."
};

const EXPOSED_PROMPT_PACK_KEYS: (keyof AgentPromptPack)[] = [
	"agentIdentityPrompt",
	"mainAgentRolePrompt",
	"subAgentRolePrompt",
	"functionCallingPrompt",
	"toolDefinitionsDetailed",
	"replyLanguageDirectiveZh",
	"replyLanguageDirectiveEn",
	"toolCallingRetryPrompt",
	"xmlDecisionFormatPrompt",
	"xmlDecisionRepairPrompt",
	"xmlDecisionSystemRepairPrompt",
	"memoryCompressionSystemPrompt",
	"memoryCompressionBodyPrompt",
	"memoryCompressionToolCallingPrompt",
	"memoryCompressionXmlPrompt",
	"memoryCompressionXmlRetryPrompt"
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
			for (let i = 0; i < EXPOSED_PROMPT_PACK_KEYS.length; i++) {
				const key = EXPOSED_PROMPT_PACK_KEYS[i];
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
		lines.push(`## \`${key}\``);
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

function rewriteDefaultPromptPackConfig(path: string): string | undefined {
	const content = renderDefaultAgentPromptPackMarkdown();
	if (!Content.save(path, content)) {
		return `Failed to recreate default Agent prompt config at ${path}. Using built-in defaults for this run.`;
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
		const [matchedHeading] = string.match(line, "^##[ \t]+`([^`]+)`[ \t]*$");
		if (matchedHeading !== undefined) {
			const heading = tostring(matchedHeading).trim();
			if (isKnownPromptPackKey(heading)) {
				currentHeading = heading;
				if (sections[currentHeading] === undefined) {
					sections[currentHeading] = [];
				}
				continue;
			}
			unknown.push(heading);
			continue;
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
			error: NO_PROMPT_PACK_SECTIONS_ERROR,
			missing,
			unknown,
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
		const rewriteWarning = rewriteDefaultPromptPackConfig(path);
		if (rewriteWarning) {
			warnings.push(rewriteWarning);
		} else {
			warnings.push(`Agent prompt config at ${path} is empty. Recreated default prompt config.`);
		}
		return {
			pack: resolveAgentPromptPack(),
			warnings,
			path,
		};
	}
	const parsed = parsePromptPackMarkdown(text);
	if (parsed.error === NO_PROMPT_PACK_SECTIONS_ERROR) {
		const rewriteWarning = rewriteDefaultPromptPackConfig(path);
		if (rewriteWarning) {
			warnings.push(rewriteWarning);
		} else {
			warnings.push(`Agent prompt config at ${path} has no prompt sections. Recreated default prompt config.`);
		}
		return {
			pack: resolveAgentPromptPack(),
			warnings,
			path,
		};
	}
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

	/** 更新后的 PROJECT_MEMORY.md 内容 */
	projectMemoryUpdate?: string;

	/** 更新后的 SESSION_SUMMARY.md 内容 */
	sessionSummaryUpdate?: string;

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
		if (text === "") return 0;
		return App.estimateTokens(text);
	}

	static estimateMessages(messages: Message[]): number {
		if (messages === undefined || messages.length === 0) return 0;
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

function normalizeMemoryFileContent(content: string | undefined, template: string, importedSectionTitle: string): string {
	const safeContent = typeof content === "string" ? sanitizeUTF8(content) : "";
	const trimmed = safeContent.trim();
	if (trimmed === "") return template;
	if (trimmed.indexOf("\n## ") >= 0 || trimmed.indexOf("\n# ") >= 0 || trimmed.slice(0, 3) === "## " || trimmed.slice(0, 2) === "# ") {
		return safeContent;
	}
	return `${template.trim()}\n\n## ${importedSectionTitle}\n\n${trimmed}\n`;
}

function splitMemorySections(text: string): MemoryTextSection[] {
	const sections: MemoryTextSection[] = [];
	const lines = sanitizeUTF8(text ?? "").split("\n");
	let title = "Overview";
	let bodyLines: string[] = [];
	let index = 0;
	function flush(): void {
		const body = bodyLines.join("\n").trim();
		if (body !== "") {
			const fullText = title === "Overview" ? body : `## ${title}\n\n${body}`;
			sections.push({ title, body, fullText, index, score: 0 });
			index += 1;
		}
	}
	for (let i = 0; i < lines.length; i++) {
		const line = lines[i];
		if (line.slice(0, 3) === "## ") {
			flush();
			title = line.slice(3).trim();
			bodyLines = [];
		} else if (line.slice(0, 2) === "# ") {
			continue;
		} else {
			bodyLines.push(line);
		}
	}
	flush();
	return sections;
}

function collectQueryTerms(query: string): string[] {
	const terms: string[] = [];
	const lower = sanitizeUTF8(query ?? "").toLowerCase();
	let current = "";
	function pushCurrent(): void {
		const word = current.trim();
		if (word.length >= 2 && terms.indexOf(word) < 0) {
			terms.push(word);
		}
		current = "";
	}
	for (let i = 0; i < lower.length; i++) {
		const ch = lower.charAt(i);
		const code = lower.charCodeAt(i);
		const isAsciiWord = (code >= 48 && code <= 57) || (code >= 97 && code <= 122) || ch === "_" || ch === "-" || ch === ".";
		if (isAsciiWord) {
			current += ch;
		} else {
			pushCurrent();
			if (code > 127 && terms.indexOf(ch) < 0) terms.push(ch);
		}
	}
	pushCurrent();
	return terms;
}

function countOccurrences(text: string, term: string): number {
	if (text === "" || term === "") return 0;
	let count = 0;
	let start = 0;
	while (true) {
		const pos = text.indexOf(term, start);
		if (pos < 0) break;
		count += 1;
		start = pos + term.length;
	}
	return count;
}

function scoreMemorySection(section: MemoryTextSection, terms: string[]): number {
	const titleLower = section.title.toLowerCase();
	const bodyLower = section.body.toLowerCase();
	let score = 0;
	for (let i = 0; i < terms.length; i++) {
		const term = terms[i];
		score += countOccurrences(titleLower, term) * 6;
		score += countOccurrences(bodyLower, term);
	}
	if (
		titleLower.indexOf("user preference") >= 0 ||
		titleLower.indexOf("stable fact") >= 0 ||
		titleLower.indexOf("known decision") >= 0 ||
		titleLower.indexOf("known issue") >= 0 ||
		titleLower.indexOf("current goal") >= 0 ||
		titleLower.indexOf("recent progress") >= 0 ||
		titleLower.indexOf("build and run") >= 0
	) {
		score += terms.length > 0 ? 1 : 3;
	}
	return score;
}

function selectRelevantMemoryText(text: string, query: string, maxTokens: number): string {
	const sections = splitMemorySections(text);
	if (sections.length === 0) return "";
	const budget = math.max(MEMORY_LAYER_MIN_TOKENS, maxTokens);
	const terms = collectQueryTerms(query);
	for (let i = 0; i < sections.length; i++) {
		sections[i].score = scoreMemorySection(sections[i], terms);
	}
	const ranked = sections.slice();
	ranked.sort((a, b) => {
		if (a.score !== b.score) return b.score - a.score;
		return a.index - b.index;
	});
	const selected: MemoryTextSection[] = [];
	let used = 0;
	for (let i = 0; i < ranked.length; i++) {
		const section = ranked[i];
		if (terms.length > 0 && section.score <= 0) continue;
		const cost = TokenEstimator.estimate(section.fullText) + 12;
		if (selected.length > 0 && used + cost > budget) continue;
		selected.push(section);
		used += cost;
		if (used >= budget) break;
	}
	if (selected.length === 0) {
		for (let i = 0; i < sections.length; i++) {
			const section = sections[i];
			const cost = TokenEstimator.estimate(section.fullText) + 12;
			if (selected.length > 0 && used + cost > budget) continue;
			selected.push(section);
			used += cost;
			if (used >= budget) break;
		}
	}
	selected.sort((a, b) => a.index - b.index);
	return selected.map(section => section.fullText).join("\n\n");
}

function formatMemoryLayer(title: string, content: string): string {
	const trimmed = sanitizeUTF8(content ?? "").trim();
	if (trimmed === "") return "";
	return `#### ${title}\n\n${trimmed}`;
}

/**
 * 双层存储管理器
 *
 * 管理 MEMORY.md (长期记忆) 和 HISTORY.jsonl (历史日志)
 */
export class DualLayerStorage {
	private projectDir: string;
	private scope: string;
	private agentRootDir: string;
	private agentDir: string;
	private memoryPath: string;
	private projectMemoryPath: string;
	private sessionSummaryPath: string;
	private historyPath: string;
	private sessionPath: string;

	constructor(projectDir: string, scope = "") {
		this.projectDir = projectDir;
		this.scope = scope;
		this.agentRootDir = Path(this.projectDir, ".agent");
		this.agentDir = scope !== ""
			? Path(this.agentRootDir, scope)
			: this.agentRootDir;
		this.memoryPath = Path(this.agentDir, "MEMORY.md");
		this.projectMemoryPath = Path(this.agentDir, "PROJECT_MEMORY.md");
		this.sessionSummaryPath = Path(this.agentDir, "SESSION_SUMMARY.md");
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

	private ensureStructuredMemoryFile(path: string, template: string): void {
		if (!Content.exist(path)) {
			this.ensureFile(path, template);
			return;
		}
		const current = Content.load(path) as string;
		if (typeof current !== "string" || current.trim() === "") {
			Content.save(path, template);
			sendWebIDEFileUpdate(path, true, template);
		}
	}

	private ensureAgentFiles(): void {
		this.ensureDir(this.agentRootDir);
		this.ensureDir(this.agentDir);
		this.ensureStructuredMemoryFile(this.memoryPath, DEFAULT_CORE_MEMORY_TEMPLATE);
		this.ensureStructuredMemoryFile(this.projectMemoryPath, DEFAULT_PROJECT_MEMORY_TEMPLATE);
		this.ensureStructuredMemoryFile(this.sessionSummaryPath, DEFAULT_SESSION_SUMMARY_TEMPLATE);
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

	private readSpawnInfo(path: string): Record<string, unknown> | undefined {
		if (!Content.exist(path)) return undefined;
		const text = Content.load(path) as string;
		if (!text || text.trim() === "") return undefined;
		const [value] = safeJsonDecode(text);
		if (value && !isArray(value) && isRecord(value)) {
			return value;
		}
		return undefined;
	}

	private normalizeEvidence(value: unknown): string[] {
		const evidence: string[] = [];
		if (!isArray(value)) return evidence;
		for (let i = 0; i < value.length && evidence.length < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS; i++) {
			const item = typeof value[i] === "string" ? sanitizeUTF8(value[i]).trim() : "";
			if (item !== "" && evidence.indexOf(item) < 0) {
				evidence.push(item);
			}
		}
		return evidence;
	}

	private decodeSubAgentLearning(value: unknown, fallbackSortTs: number): SubAgentLearningEntry | undefined {
		if (!value || isArray(value) || !isRecord(value)) return undefined;
		const sourceSessionId = typeof value.sourceSessionId === "number" ? math.floor(value.sourceSessionId) : 0;
		const sourceTaskId = typeof value.sourceTaskId === "number" ? math.floor(value.sourceTaskId) : 0;
		const content = typeof value.content === "string"
			? utf8TakeHead(sanitizeUTF8(value.content).trim(), SUB_AGENT_MEMORY_ENTRY_MAX_CHARS)
			: "";
		if (sourceSessionId <= 0 || sourceTaskId <= 0 || content === "") return undefined;
		return {
			sourceSessionId,
			sourceTaskId,
			content,
			evidence: this.normalizeEvidence(value.evidence),
			createdAt: typeof value.createdAt === "string" ? sanitizeUTF8(value.createdAt).trim() : "",
			sortTs: fallbackSortTs,
		};
	}

	private readSubAgentLearningEntries(): SubAgentLearningEntry[] {
		if (this.scope !== "" && this.scope !== "main") return [];
		const subAgentsDir = Path(this.agentRootDir, "subagents");
		if (!Content.exist(subAgentsDir) || !Content.isdir(subAgentsDir)) return [];
		const entries: SubAgentLearningEntry[] = [];
		const seen: Record<string, boolean> = {};
		for (const rawPath of Content.getDirs(subAgentsDir)) {
			const dir = Content.isAbsolutePath(rawPath) ? rawPath : Path(subAgentsDir, rawPath);
			if (!Content.exist(dir) || !Content.isdir(dir)) continue;
			const info = this.readSpawnInfo(Path(dir, SUB_AGENT_SPAWN_INFO_FILE));
			if (info === undefined || info.success !== true) continue;
			const fallbackSortTs = typeof info.finishedAtTs === "number" ? info.finishedAtTs : 0;
			const entry = this.decodeSubAgentLearning(info.memoryEntry, fallbackSortTs);
			if (entry === undefined) continue;
			const key = `${entry.sourceSessionId}:${entry.sourceTaskId}`;
			if (seen[key]) continue;
			seen[key] = true;
			entries.push(entry);
		}
		entries.sort((a, b) => b.sortTs - a.sortTs);
		return entries;
	}

	private buildSubAgentLearningsContext(): string {
		const entries = this.readSubAgentLearningEntries();
		if (entries.length === 0) return "";
		const lines: string[] = ["## Sub-Agent Learnings", ""];
		let totalChars = 0;
		let count = 0;
		for (let i = 0; i < entries.length && count < SUB_AGENT_LEARNINGS_MAX_ITEMS; i++) {
			const entry = entries[i];
			const evidence = entry.evidence.length > 0 ? `\n  Evidence: ${entry.evidence.join(", ")}` : "";
			const line = `- [sub-agent:${tostring(entry.sourceSessionId)}/task:${tostring(entry.sourceTaskId)}] ${entry.content}${evidence}`;
			if (totalChars + line.length > SUB_AGENT_LEARNINGS_MAX_CHARS) break;
			lines.push(line);
			totalChars += line.length;
			count += 1;
		}
		return count > 0 ? lines.join("\n") : "";
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
			if (record !== undefined) {
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
			if (typeof line === "string" && line !== "") {
				lines.push(line);
			}
		}
		const content = lines.length > 0 ? `${lines.join("\n")}\n` : "";
		Content.save(this.historyPath, content);
		sendWebIDEFileUpdate(this.historyPath, true, content);
	}

	// ===== 结构化记忆操作 =====

	/**
	 * 读取核心长期记忆（用户偏好、稳定事实、已知决策、已知问题）
	 */
	readMemory(): string {
		if (!Content.exist(this.memoryPath)) {
			return DEFAULT_CORE_MEMORY_TEMPLATE;
		}
		return normalizeMemoryFileContent(Content.load(this.memoryPath) as string, DEFAULT_CORE_MEMORY_TEMPLATE, "Imported Notes");
	}

	/**
	 * 写入核心长期记忆
	 */
	writeMemory(content: string): void {
		const normalized = normalizeMemoryFileContent(content, DEFAULT_CORE_MEMORY_TEMPLATE, "Imported Notes");
		this.ensureDir(Path.getPath(this.memoryPath));
		Content.save(this.memoryPath, normalized);
		sendWebIDEFileUpdate(this.memoryPath, true, normalized);
	}

	readProjectMemory(): string {
		if (!Content.exist(this.projectMemoryPath)) {
			return DEFAULT_PROJECT_MEMORY_TEMPLATE;
		}
		return normalizeMemoryFileContent(Content.load(this.projectMemoryPath) as string, DEFAULT_PROJECT_MEMORY_TEMPLATE, "Imported Project Notes");
	}

	writeProjectMemory(content: string): void {
		const normalized = normalizeMemoryFileContent(content, DEFAULT_PROJECT_MEMORY_TEMPLATE, "Imported Project Notes");
		this.ensureDir(Path.getPath(this.projectMemoryPath));
		Content.save(this.projectMemoryPath, normalized);
		sendWebIDEFileUpdate(this.projectMemoryPath, true, normalized);
	}

	readSessionSummary(): string {
		if (!Content.exist(this.sessionSummaryPath)) {
			return DEFAULT_SESSION_SUMMARY_TEMPLATE;
		}
		return normalizeMemoryFileContent(Content.load(this.sessionSummaryPath) as string, DEFAULT_SESSION_SUMMARY_TEMPLATE, "Imported Session Notes");
	}

	writeSessionSummary(content: string): void {
		const normalized = normalizeMemoryFileContent(content, DEFAULT_SESSION_SUMMARY_TEMPLATE, "Imported Session Notes");
		this.ensureDir(Path.getPath(this.sessionSummaryPath));
		Content.save(this.sessionSummaryPath, normalized);
		sendWebIDEFileUpdate(this.sessionSummaryPath, true, normalized);
	}

	/**
	 * 生成注入到 prompt 的相关记忆上下文：只选择和当前用户请求相关的片段，避免整份 MEMORY.md 进上下文。
	 */
	getRelevantMemoryContext(query = "", maxTokens = MEMORY_CONTEXT_DEFAULT_MAX_TOKENS): string {
		const budget = math.max(MEMORY_CONTEXT_MIN_MAX_TOKENS, math.floor(maxTokens));
		const coreBudget = math.floor(budget * 0.30);
		const projectBudget = math.floor(budget * 0.35);
		const sessionBudget = math.floor(budget * 0.20);
		const subAgentBudget = math.max(0, budget - coreBudget - projectBudget - sessionBudget - 160);
		const sections: string[] = [];
		const core = formatMemoryLayer("Core Memory", selectRelevantMemoryText(this.readMemory(), query, coreBudget));
		if (core !== "") sections.push(core);
		const project = formatMemoryLayer("Project Memory", selectRelevantMemoryText(this.readProjectMemory(), query, projectBudget));
		if (project !== "") sections.push(project);
		const session = formatMemoryLayer("Session Summary", selectRelevantMemoryText(this.readSessionSummary(), query, sessionBudget));
		if (session !== "") sections.push(session);
		const subAgentLearnings = this.buildSubAgentLearningsContext();
		if (subAgentLearnings !== "") {
			sections.push(formatMemoryLayer("Sub-Agent Learnings", clipTextToTokenBudget(subAgentLearnings, subAgentBudget > 0 ? subAgentBudget : MEMORY_LAYER_MIN_TOKENS)));
		}
		if (sections.length === 0) return "";
		const output = `### Relevant Memory\n\n${sections.join("\n\n")}`;
		return TokenEstimator.estimate(output) > budget ? clipTextToTokenBudget(output, budget) : output;
	}

	/**
	 * 兼容旧调用；默认返回相关记忆而不是整份文件。
	 */
	getMemoryContext(query = "", maxTokens = MEMORY_CONTEXT_DEFAULT_MAX_TOKENS): string {
		return this.getRelevantMemoryContext(query, maxTokens);
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
				if (message !== undefined) {
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
		if (typeof stateLine === "string" && stateLine !== "") {
			lines.push(stateLine);
		}
		for (let i = 0; i < normalizedMessages.length; i++) {
			const line = this.encodeJsonLine({
				message: normalizedMessages[i],
			});
			if (typeof line === "string" && line !== "") {
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
				// 成功：写入三层记忆存储
				this.storage.writeMemory(result.memoryUpdate);
				if (typeof result.projectMemoryUpdate === "string") {
					this.storage.writeProjectMemory(result.projectMemoryUpdate);
				}
				if (typeof result.sessionSummaryUpdate === "string") {
					this.storage.writeSessionSummary(result.sessionSummaryUpdate);
				}
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
		return Math.max(MEMORY_DEFAULT_CONTEXT_WINDOW, this.config.llmConfig.contextWindow);
	}

	getMemoryContextBudget(): number {
		const contextWindow = math.max(MEMORY_DEFAULT_CONTEXT_WINDOW, this.config.llmConfig.contextWindow);
		return math.max(
			AGENT_MEMORY_CONTEXT_MIN_TOKENS,
			math.floor(contextWindow * AGENT_MEMORY_CONTEXT_WINDOW_RATIO)
		);
	}

	private getCompressionHistoryTokenBudget(currentMemory: string): number {
		const contextWindow = this.getContextWindow();
		const reservedOutputTokens = Math.max(
			COMPRESSION_RESERVED_OUTPUT_MIN_TOKENS,
			Math.floor(contextWindow * COMPRESSION_RESERVED_OUTPUT_CONTEXT_RATIO)
		);
		const staticPromptTokens = TokenEstimator.estimate(this.buildCompressionStaticPrompt("tool_calling"));
		const memoryTokens = TokenEstimator.estimate(currentMemory);
		const available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens;
		return Math.max(
			COMPRESSION_HISTORY_MIN_TOKENS,
			Math.floor(available * COMPRESSION_HISTORY_AVAILABLE_RATIO)
		);
	}

	private boundCompressionHistoryText(currentMemory: string, historyText: string): string {
		const historyTokens = TokenEstimator.estimate(historyText);
		const tokenBudget = this.getCompressionHistoryTokenBudget(currentMemory);
		if (historyTokens <= tokenBudget) return historyText;
		const charsPerToken = historyTokens > 0
			? historyText.length / historyTokens
			: 4;
		const targetChars = Math.max(
			COMPRESSION_HISTORY_TRUNCATED_MIN_CHARS,
			Math.floor(tokenBudget * charsPerToken)
		);
		const keepHead = Math.max(0, Math.floor(targetChars * COMPRESSION_HISTORY_TRUNCATED_HEAD_RATIO));
		const keepTail = Math.max(0, targetChars - keepHead);
		const head = keepHead > 0 ? utf8TakeHead(historyText, keepHead) : "";
		const tail = keepTail > 0 ? utf8TakeTail(historyText, keepTail) : "";
		return `[compression history truncated to fit context window; token_budget=${tokenBudget}, original_tokens=${historyTokens}]\n${head}\n...\n${tail}`;
	}

	private buildBoundedCompressionSections(currentMemory: string, historyText: string): {
		currentMemory: string;
		currentProjectMemory: string;
		currentSessionSummary: string;
		historyText: string;
	} {
		const contextWindow = this.getContextWindow();
		const reservedOutputTokens = Math.max(
			COMPRESSION_RESERVED_OUTPUT_MIN_TOKENS,
			math.floor(contextWindow * COMPRESSION_RESERVED_OUTPUT_CONTEXT_RATIO)
		);
		const staticPromptTokens = TokenEstimator.estimate(this.buildCompressionStaticPrompt("tool_calling"));
		const dynamicBudget = math.max(
			COMPRESSION_DYNAMIC_MIN_TOKENS,
			contextWindow - reservedOutputTokens - staticPromptTokens - COMPRESSION_DYNAMIC_PROMPT_OVERHEAD_TOKENS
		);
		const boundedMemory = clipTextToTokenBudget(currentMemory || "(empty)", math.max(
			COMPRESSION_SECTION_MEMORY_MIN_TOKENS,
			math.floor(dynamicBudget * COMPRESSION_SECTION_MEMORY_RATIO)
		));
		const boundedProjectMemory = clipTextToTokenBudget(this.storage.readProjectMemory() || "(empty)", math.max(
			COMPRESSION_SECTION_MEMORY_MIN_TOKENS,
			math.floor(dynamicBudget * COMPRESSION_SECTION_MEMORY_RATIO)
		));
		const boundedSessionSummary = clipTextToTokenBudget(this.storage.readSessionSummary() || "(empty)", math.max(
			COMPRESSION_SECTION_SESSION_MIN_TOKENS,
			math.floor(dynamicBudget * COMPRESSION_SECTION_SESSION_RATIO)
		));
		const boundedHistory = clipTextToTokenBudget(historyText, math.max(
			COMPRESSION_SECTION_HISTORY_MIN_TOKENS,
			math.floor(dynamicBudget * COMPRESSION_SECTION_HISTORY_RATIO)
		));
		return {
			currentMemory: boundedMemory,
			currentProjectMemory: boundedProjectMemory,
			currentSessionSummary: boundedSessionSummary,
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
							description: "Full updated MEMORY.md as markdown. Core memory only: user preferences, stable facts, decisions, known issues."
						},
						project_memory_update: {
							type: "string",
							description: "Full updated PROJECT_MEMORY.md as markdown. Project facts, build/run, files/architecture, project decisions and issues."
						},
						session_summary_update: {
							type: "string",
							description: "Full updated SESSION_SUMMARY.md as markdown. Current goal, recent progress, and open issues for this session."
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
			const requestOptions = {
				...llmOptions,
				tools,
			};
			debugContext?.onInput?.("memory_compression_tool_calling", messages, requestOptions);
			// 调用 LLM，提示模型使用 save_memory 工具；部分模型不支持强制 tool_choice。
			const response = await callLLM(
				messages,
				requestOptions,
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
			CURRENT_PROJECT_MEMORY: this.storage.readProjectMemory() || "(empty)",
			CURRENT_SESSION_SUMMARY: this.storage.readSessionSummary() || "(empty)",
			HISTORY_TEXT: historyText,
		});
	}

	private buildCompressionPromptBody(currentMemory: string, historyText: string): string {
		const bounded = this.buildBoundedCompressionSections(currentMemory, historyText);
		return replaceTemplateVars(this.config.promptPack.memoryCompressionBodyPrompt, {
			CURRENT_MEMORY: bounded.currentMemory,
			CURRENT_PROJECT_MEMORY: bounded.currentProjectMemory,
			CURRENT_SESSION_SUMMARY: bounded.currentSessionSummary,
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
		const memoryBody = typeof obj.memory_update === "string" && obj.memory_update.trim() !== ""
			? obj.memory_update
			: currentMemory;
		const projectMemoryBody = typeof obj.project_memory_update === "string" && obj.project_memory_update.trim() !== ""
			? obj.project_memory_update
			: this.storage.readProjectMemory();
		const sessionSummaryBody = typeof obj.session_summary_update === "string" && obj.session_summary_update.trim() !== ""
			? obj.session_summary_update
			: this.storage.readSessionSummary();
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
			projectMemoryUpdate: projectMemoryBody,
			sessionSummaryUpdate: sessionSummaryBody,
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
	const llmOptions = buildMemoryLLMOptions(llmConfigRes.config, options.llmOptions);
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
