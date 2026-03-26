// @preview-file off clear
import { Content, Path, json } from 'Dora';
import { Message, ToolCallFunction, callLLM, Log } from 'Agent/Utils';
import type { LLMConfig } from 'Agent/Utils';
import { sendWebIDEFileUpdate } from 'Agent/Tools';
import * as yaml from 'yaml';

import type { AgentActionRecord } from 'Agent/CodingAgent';

export const DEFAULT_AGENT_PROMPT = "You are a coding assistant that helps modify and navigate code.";
const AGENT_CONFIG_DIR = ".agent";
const AGENT_PROMPTS_FILE = "AGENT.md";

export interface AgentPromptPack {
	agentIdentityPrompt: string;
	decisionIntroPrompt: string;
	toolDefinitionsShort: string;
	toolDefinitionsDetailed: string;
	decisionRulesPrompt: string;
	replyLanguageDirectiveZh: string;
	replyLanguageDirectiveEn: string;
	toolCallingSystemPrompt: string;
	toolCallingNoPlainTextPrompt: string;
	toolCallingRetryPrompt: string;
	yamlDecisionFormatPrompt: string;
	finalSummaryPrompt: string;
	memoryCompressionSystemPrompt: string;
	memoryCompressionBodyPrompt: string;
	memoryCompressionToolCallingPrompt: string;
	memoryCompressionYamlPrompt: string;
	memoryCompressionYamlRetryPrompt: string;
}

export const DEFAULT_AGENT_PROMPT_PACK: AgentPromptPack = {
	agentIdentityPrompt: DEFAULT_AGENT_PROMPT,
	decisionIntroPrompt: "Given the request and action history, decide which tool to use next.",
	toolDefinitionsShort: `Available tools:
1. read_file: Read content from a file with pagination
1b. read_file_range: Read specific line range from a file
2. edit_file: Make changes to a file
3. delete_file: Remove a file
4. grep_files: Search text patterns inside files
5. glob_files: Enumerate files under a directory with optional glob filters
6. search_dora_api: Search Dora SSR game engine docs and tutorials
7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn
8. finish: End and summarize`,
	toolDefinitionsDetailed: `Available tools:
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
	- \`limit\` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.

7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn
	- Parameters: path(optional)
	- After one build completes, do not run build again unless files were edited/deleted. Read the result and then finish or take corrective action.

8. finish: End and summarize
	- Parameters: {}`,
	decisionRulesPrompt: `Decision rules:
- Choose exactly one next action.
- Keep params shallow and valid for the selected tool.
- Prefer reading/searching before editing when information is missing.
- After any search tool returns candidate files or docs, use read_file or read_file_range to inspect search result details instead of repeatedly broadening search.
- Use glob_files to discover candidate files. Use grep_files only when you need to search file contents.
- If the user asked a question, prefer finishing only after you can answer it in the final response.`,
	replyLanguageDirectiveZh: "Use Simplified Chinese for natural-language fields (reason/message/summary).",
	replyLanguageDirectiveEn: "Use English for natural-language fields (reason/message/summary).",
	toolCallingSystemPrompt: "You are a coding assistant that must decide the next action by calling the next_step tool exactly once.",
	toolCallingNoPlainTextPrompt: "Do not answer with plain text.",
	toolCallingRetryPrompt: "Previous tool call was invalid ({{LAST_ERROR}}). Retry with one valid next_step tool call only.",
	yamlDecisionFormatPrompt: `Respond with one YAML object:
\`\`\`yaml
tool: "edit_file"
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
- If using a block scalar, all content lines must be indented consistently with tabs.`,
	finalSummaryPrompt: `You are a coding assistant. Summarize what you did for the user.

Here are the actions you performed:
{{SUMMARY}}

Generate a concise response that explains:
1. What actions were taken
2. What was found or modified
3. Any next steps

IMPORTANT:
- Focus on outcomes, not tool names.
- Speak directly to the user.
- If the user asked a question, include a direct answer to that question in the response.
{{LANGUAGE_DIRECTIVE}}`,
	memoryCompressionSystemPrompt: "You are a memory consolidation agent. You MUST call the save_memory tool.",
	memoryCompressionBodyPrompt: `Process this conversation and consolidate it.

### Current Long-term Memory
{{CURRENT_MEMORY}}

### Recent Actions to Process
{{HISTORY_TEXT}}

### Instructions

1. **Analyze the conversation**:
	- What was the user trying to accomplish?
	- What tools were used and what were the results?
	- Were there any problems or solutions?
	- What decisions were made?

2. **Update the long-term memory**:
	- Preserve all existing facts
	- Add new important information (user preferences, project context, decisions)
	- Remove outdated or redundant information
	- Keep the memory concise but complete

3. **Create a history entry**:
	- Summarize key events, decisions, and outcomes
	- Include details useful for grep search
	- Format as a single paragraph`,
	memoryCompressionToolCallingPrompt: `### Output Format

Call the save_memory tool with:
- history_entry: the summary paragraph without timestamp
- memory_update: the full updated MEMORY.md content`,
	memoryCompressionYamlPrompt: `### Output Format

Return exactly one YAML object:
\`\`\`yaml
history_entry: "Summary paragraph"
memory_update: |-
	Full updated MEMORY.md content
\`\`\`

Rules:
- Return YAML only, no prose before or after.
- Use exactly two keys: history_entry, memory_update.
- Use a block scalar for memory_update when it spans multiple lines.`,
	memoryCompressionYamlRetryPrompt: "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid YAML object only.",
};

export const PROMPT_PACK_KEYS: (keyof AgentPromptPack)[] = [
	"agentIdentityPrompt",
	"decisionIntroPrompt",
	"toolDefinitionsShort",
	"toolDefinitionsDetailed",
	"decisionRulesPrompt",
	"replyLanguageDirectiveZh",
	"replyLanguageDirectiveEn",
	"toolCallingSystemPrompt",
	"toolCallingNoPlainTextPrompt",
	"toolCallingRetryPrompt",
	"yamlDecisionFormatPrompt",
	"finalSummaryPrompt",
	"memoryCompressionSystemPrompt",
	"memoryCompressionBodyPrompt",
	"memoryCompressionToolCallingPrompt",
	"memoryCompressionYamlPrompt",
	"memoryCompressionYamlRetryPrompt",
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
		if (value && !Array.isArray(value) && type(value) === "table") {
			for (let i = 0; i < PROMPT_PACK_KEYS.length; i++) {
				const key = PROMPT_PACK_KEYS[i];
				if (typeof value[key] === "string") {
					((merged as unknown) as Record<string, unknown>)[key] = value[key] as string;
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
	for (let i = 0; i < PROMPT_PACK_KEYS.length; i++) {
		const key = PROMPT_PACK_KEYS[i];
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
			missing: [...PROMPT_PACK_KEYS],
			unknown: [],
		};
	}
	const normalized = text.replace("\r\n", "\n");
	const lines = normalized.split("\n");
	const sections: Record<string, string[]> = {};
	const unknown: string[] = [];
	let currentHeading = "";
	const isKnownPromptPackKey = (name: string): boolean => {
		for (let i = 0; i < PROMPT_PACK_KEYS.length; i++) {
			if (PROMPT_PACK_KEYS[i] === name) return true;
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
	for (let i = 0; i < PROMPT_PACK_KEYS.length; i++) {
		const key = PROMPT_PACK_KEYS[i];
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

	/** 最大压缩轮数 */
	maxCompressionRounds: number;

	/** 每次压缩的最大 token 数 */
	maxTokensPerCompression: number;

	/** 当前项目完整路径 */
	projectDir: string;

	/** 当前运行绑定的 LLM 配置 */
	llmConfig: LLMConfig;

	/** 当前会话使用的 Prompt 配置 */
	promptPack?: Partial<AgentPromptPack> | AgentPromptPack;
}

/**
 * 压缩结果
 */
export interface CompressionResult {
	/** 更新后的 MEMORY.md 内容 */
	memoryUpdate: string;

	/** 追加到 HISTORY.md 的条目 */
	historyEntry: string;

	/** 压缩的历史记录数量 */
	compressedCount: number;

	/** 是否成功 */
	success: boolean;

	/** 错误信息 (如果失败) */
	error?: string;
}

export type MemoryCompressionDecisionMode = "tool_calling" | "yaml";

/**
 * Token 估算器
 *
 * 提供简单高效的 token 估算功能。
 * 估算精度足够用于压缩触发判断。
 */
export class TokenEstimator {
	// 平均每 4 个字符 ≈ 1 token (适用于英文为主的内容)
	private static readonly CHARS_PER_TOKEN = 4;

	// 中文字符权重更高
	private static readonly CHINESE_CHARS_PER_TOKEN = 1.5;

	/**
	 * 估算文本的 token 数量
	 */
	static estimate(text: string): number {
		if (!text) return 0;

		// 简单统计中文字符
		const [chineseChars] = utf8.len(text);
		if (!chineseChars) return 0;

		const otherChars = text.length - chineseChars;

		const tokens = Math.ceil(
			chineseChars / this.CHINESE_CHARS_PER_TOKEN +
			otherChars / this.CHARS_PER_TOKEN
		);

		return Math.max(1, tokens);
	}

	/**
	 * 估算历史记录的 token 数量
	 */
	static estimateHistory(history: AgentActionRecord[], formatFunc: (h: AgentActionRecord[]) => string): number {
		if (!history || history.length === 0) return 0;
		const text = formatFunc(history);
		return this.estimate(text);
	}

	/**
	 * 估算完整 prompt 的 token 数量
	 */
	static estimatePrompt(
		userQuery: string,
		history: AgentActionRecord[],
		systemPrompt: string,
		toolDefinitions: string,
		formatFunc: (h: AgentActionRecord[]) => string
	): number {
		return (
			this.estimate(userQuery) +
			this.estimateHistory(history, formatFunc) +
			this.estimate(systemPrompt) +
			this.estimate(toolDefinitions)
		);
	}
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

/**
 * 双层存储管理器
 *
 * 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
 */
export class DualLayerStorage {
	private projectDir: string;
	private agentDir: string;
	private memoryPath: string;
	private historyPath: string;
	private sessionPath: string;

	constructor(projectDir: string) {
		this.projectDir = projectDir;
		this.agentDir = Path(this.projectDir, ".agent");
		this.memoryPath = Path(this.agentDir, "MEMORY.md");
		this.historyPath = Path(this.agentDir, "HISTORY.md");
		this.sessionPath = Path(this.agentDir, "SESSION.jsonl");
		this.ensureAgentFiles();
	}

	private ensureDir(dir: string): void {
		if (!Content.exist(dir)) {
			Content.mkdir(dir);
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
		this.ensureDir(this.agentDir);
		this.ensureFile(this.memoryPath, "");
		this.ensureFile(this.historyPath, "");
	}

	private encodeJsonLine(value: unknown): string | undefined {
		const [text] = json.encode(value as object);
		return text;
	}

	private decodeJsonLine(text: string): unknown {
		const [value] = json.decode(text);
		return value;
	}

	private decodeActionRecord(value: unknown): AgentActionRecord | undefined {
		if (!value || Array.isArray(value) || type(value) !== "table") return undefined;
		const row = value as Record<string, unknown>;
		const tool = typeof row.tool === "string" ? row.tool : "";
		const reason = typeof row.reason === "string" ? row.reason : "";
		const timestamp = typeof row.timestamp === "string" ? row.timestamp : "";
		if (tool === "" || timestamp === "") return undefined;
		const params = row.params && !Array.isArray(row.params) && type(row.params) === "table"
			? row.params as Record<string, unknown>
			: {};
		const result = row.result && !Array.isArray(row.result) && type(row.result) === "table"
			? row.result as Record<string, unknown>
			: undefined;
		return {
			step: math.max(1, math.floor(Number(row.step ?? 1))),
			tool: tool as AgentActionRecord["tool"],
			reason,
			params,
			result,
			timestamp,
		};
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

	// ===== HISTORY.md 操作 =====

	/**
	 * 追加历史日志
	 */
	appendHistory(entry: string): void {
		this.ensureDir(Path.getPath(this.historyPath));

		const existing = Content.exist(this.historyPath)
			? Content.load(this.historyPath) as string
			: "";

		Content.save(this.historyPath, existing + entry + "\n\n");
	}

	/**
	 * 读取完整历史日志
	 */
	readHistory(): string {
		if (!Content.exist(this.historyPath)) {
			return "";
		}
		return Content.load(this.historyPath) as string;
	}

	readSessionState(): { history: AgentActionRecord[]; lastConsolidatedIndex: number } {
		if (!Content.exist(this.sessionPath)) {
			return { history: [], lastConsolidatedIndex: 0 };
		}
		const text = Content.load(this.sessionPath) as string;
		if (!text || text.trim() === "") {
			return { history: [], lastConsolidatedIndex: 0 };
		}
		const lines = text.split("\n");
		const history: AgentActionRecord[] = [];
		let lastConsolidatedIndex = 0;
		for (let i = 0; i < lines.length; i++) {
			const line = lines[i].trim();
			if (line === "") continue;
			const data = this.decodeJsonLine(line);
			if (!data || Array.isArray(data) || type(data) !== "table") continue;
			const row = data as Record<string, unknown>;
			if (row._type === "metadata") {
				lastConsolidatedIndex = math.max(0, math.floor(Number(row.lastConsolidatedIndex ?? 0)));
				continue;
			}
			const record = this.decodeActionRecord(row);
			if (record) {
				history.push(record);
			}
		}
		return {
			history,
			lastConsolidatedIndex: math.min(lastConsolidatedIndex, history.length),
		};
	}

	writeSessionState(history: AgentActionRecord[], lastConsolidatedIndex: number): void {
		this.ensureDir(Path.getPath(this.sessionPath));
		const lines: string[] = [];
		const meta = this.encodeJsonLine({
			_type: "metadata",
			lastConsolidatedIndex: math.min(math.max(0, math.floor(lastConsolidatedIndex)), history.length),
		});
		if (meta) {
			lines.push(meta);
		}
		for (let i = 0; i < history.length; i++) {
			const line = this.encodeJsonLine(history[i]);
			if (line) {
				lines.push(line);
			}
		}
		const content = lines.join("\n") + "\n";
		Content.save(this.sessionPath, content);
		sendWebIDEFileUpdate(this.sessionPath, true, content);
	}

	/**
	 * 搜索历史日志 (返回匹配的行)
	 */
	searchHistory(keyword: string): string[] {
		const history = this.readHistory();
		if (!history) return [];

		const lines = history.split("\n");
		const lowerKeyword = keyword.toLowerCase();

		return lines.filter(line =>
			line.toLowerCase().includes(lowerKeyword)
		);
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
		const overridePack = (config.promptPack && !Array.isArray(config.promptPack) && type(config.promptPack) === "table")
			? config.promptPack as Record<string, unknown>
			: undefined;
		this.config = {
			...config,
			promptPack: resolveAgentPromptPack({
				...(loadedPromptPack.pack as unknown as Record<string, unknown>),
				...(overridePack ?? {}),
			}),
		};
		this.storage = new DualLayerStorage(this.config.projectDir);
	}

	getPromptPack(): AgentPromptPack {
		return this.config.promptPack;
	}

	/**
	 * 检查是否需要压缩
	 */
	shouldCompress(
		userQuery: string,
		history: AgentActionRecord[],
		lastConsolidatedIndex: number,
		systemPrompt: string,
		toolDefinitions: string,
		formatFunc: (h: AgentActionRecord[]) => string
	): boolean {
		const uncompressedHistory = history.slice(lastConsolidatedIndex);

		const tokens = TokenEstimator.estimatePrompt(
			userQuery,
			uncompressedHistory,
			systemPrompt,
			toolDefinitions,
			formatFunc
		);

		const threshold = this.getContextWindow() * this.config.compressionThreshold;

		return tokens > threshold;
	}

	/**
	 * 执行压缩
	 */
	async compress(
		userQuery: string,
		history: AgentActionRecord[],
		lastConsolidatedIndex: number,
		llmOptions: Record<string, unknown>,
		formatFunc: (h: AgentActionRecord[]) => string,
		maxLLMTry?: number,
		decisionMode: MemoryCompressionDecisionMode = "tool_calling"
	): Promise<CompressionResult | null> {
		const toCompress = history.slice(lastConsolidatedIndex);
		if (toCompress.length === 0) return null;

		// 找到压缩边界
		const boundary = this.findCompressionBoundary(toCompress, formatFunc);
		const chunk = toCompress.slice(0, boundary);

		if (chunk.length === 0) return null;

		const currentMemory = this.storage.readMemory();
		const historyText = formatFunc(chunk);

		try {
			// 调用 LLM 压缩
			const result = await this.callLLMForCompression(
				currentMemory,
				historyText,
				llmOptions,
				maxLLMTry ?? 3,
				decisionMode
			);

			if (result.success) {
				// 成功：写入存储
				this.storage.writeMemory(result.memoryUpdate);
				this.storage.appendHistory(result.historyEntry);
				this.consecutiveFailures = 0;

				return {
					...result,
					compressedCount: chunk.length,
				};
			}

			// LLM 返回失败
			return this.handleCompressionFailure(userQuery, chunk, result.error || "Unknown error");

		} catch (error) {
			// 异常
			return this.handleCompressionFailure(
				userQuery,
				chunk,
				error instanceof Error ? error.message : "Unknown error"
			);
		}
	}

	/**
	 * 找到压缩边界
	 *
	 * 策略：在用户相关操作处切分，保持对话完整性
	 */
	private findCompressionBoundary(
		history: AgentActionRecord[],
		formatFunc: (h: AgentActionRecord[]) => string
	): number {
		const targetTokens = this.config.maxTokensPerCompression;
		let accumulatedTokens = 0;

		for (let i = 0; i < history.length; i++) {
			const record = history[i];
			const tokens = TokenEstimator.estimate(
				formatFunc([record])
			);

			accumulatedTokens += tokens;

			// 超过目标，返回当前位置
			if (accumulatedTokens > targetTokens) {
				return Math.max(1, i);
			}
		}

		return history.length;
	}

	/**
	 * 调用 LLM 执行压缩
	 */
	private async callLLMForCompression(
		currentMemory: string,
		historyText: string,
		llmOptions: Record<string, unknown>,
		maxLLMTry: number,
		decisionMode: MemoryCompressionDecisionMode
	): Promise<CompressionResult> {
		const boundedHistoryText = this.boundCompressionHistoryText(currentMemory, historyText);
		if (decisionMode === "yaml") {
			return this.callLLMForCompressionByYAML(
				currentMemory,
				boundedHistoryText,
				llmOptions,
				maxLLMTry
			);
		}
		return this.callLLMForCompressionByToolCalling(
			currentMemory,
			boundedHistoryText,
			llmOptions,
			maxLLMTry
		);
	}

	private getContextWindow(): number {
		return Math.max(4000, this.config.llmConfig.contextWindow);
	}

	private getCompressionHistoryTokenBudget(currentMemory: string): number {
		const contextWindow = this.getContextWindow();
		const reservedOutputTokens = Math.max(2048, Math.floor(contextWindow * 0.2));
		const staticPromptTokens = TokenEstimator.estimate(this.buildCompressionPromptBody("", ""));
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

	private async callLLMForCompressionByToolCalling(
		currentMemory: string,
		historyText: string,
		llmOptions: Record<string, unknown>,
		maxLLMTry: number
	): Promise<CompressionResult> {
		const prompt = this.buildToolCallingCompressionPrompt(currentMemory, historyText);

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
				content: this.config.promptPack.memoryCompressionSystemPrompt,
			},
			{
				role: "user",
				content: prompt
			}
		];

		let fn: ToolCallFunction | undefined;
		let argsText = "";
		for (let i = 0; i < maxLLMTry; i++) {
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
				return {
					success: false,
					memoryUpdate: currentMemory,
					historyEntry: "",
					compressedCount: 0,
					error: response.message,
				};
			}

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
				historyEntry: "",
				compressedCount: 0,
				error: "missing save_memory tool call",
			};
		}

		if (argsText.trim() === "") {
			return {
				success: false,
				memoryUpdate: currentMemory,
				historyEntry: "",
				compressedCount: 0,
				error: "empty save_memory tool arguments",
			};
		}

		// 解析 tool arguments JSON
		try {
			const [args, err] = json.decode(argsText);
			if (err !== undefined || !args || typeof args !== "object") {
				return {
					success: false,
					memoryUpdate: currentMemory,
					historyEntry: "",
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
				historyEntry: "",
				compressedCount: 0,
				error: `Failed to process LLM response: ${error instanceof Error ? error.message : tostring(error)}`,
			};
		}
	}

	private async callLLMForCompressionByYAML(
		currentMemory: string,
		historyText: string,
		llmOptions: Record<string, unknown>,
		maxLLMTry: number
	): Promise<CompressionResult> {
		const prompt = this.buildYAMLCompressionPrompt(currentMemory, historyText);
		let lastError = "invalid yaml response";

		for (let i = 0; i < maxLLMTry; i++) {
			const feedback = i > 0
				? `\n\n${replaceTemplateVars(this.config.promptPack.memoryCompressionYamlRetryPrompt, {
					LAST_ERROR: lastError,
				})}`
				: "";
			const response = await callLLM(
				[{ role: "user", content: `${prompt}${feedback}` }],
				llmOptions,
				undefined,
				this.config.llmConfig
			);

			if (!response.success) {
				return {
					success: false,
					memoryUpdate: currentMemory,
					historyEntry: "",
					compressedCount: 0,
					error: response.message,
				};
			}

			const choice = response.response.choices && response.response.choices[0];
			const message = choice && choice.message;
			const text = message && typeof message.content === "string" ? message.content : "";
			if (text.trim() === "") {
				lastError = "empty yaml response";
				continue;
			}

			const parsed = this.parseCompressionYAMLObject(text, currentMemory);
			if (parsed.success) {
				return parsed;
			}
			lastError = parsed.error || "invalid yaml response";
		}

		return {
			success: false,
			memoryUpdate: currentMemory,
			historyEntry: "",
			compressedCount: 0,
			error: lastError,
		};
	}

	/**
	 * 构建压缩提示
	 */
	private buildCompressionPromptBody(currentMemory: string, historyText: string): string {
		return replaceTemplateVars(this.config.promptPack.memoryCompressionBodyPrompt, {
			CURRENT_MEMORY: currentMemory || "(empty)",
			HISTORY_TEXT: historyText,
		});
	}

	private buildToolCallingCompressionPrompt(currentMemory: string, historyText: string): string {
		return `${this.buildCompressionPromptBody(currentMemory, historyText)}

${this.config.promptPack.memoryCompressionToolCallingPrompt}`;
	}

	private buildYAMLCompressionPrompt(currentMemory: string, historyText: string): string {
		return `${this.buildCompressionPromptBody(currentMemory, historyText)}

${this.config.promptPack.memoryCompressionYamlPrompt}`;
	}

	private extractYAMLFromText(text: string): string {
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
		return source;
	}

	private parseCompressionYAMLObject(text: string, currentMemory: string): CompressionResult {
		const yamlText = this.extractYAMLFromText(text);
		const [obj, err] = yaml.parse(yamlText);
		if (!obj || typeof obj !== "object") {
			return {
				success: false,
				memoryUpdate: currentMemory,
				historyEntry: "",
				compressedCount: 0,
				error: `invalid yaml: ${tostring(err)}`,
			};
		}
		return this.buildCompressionResultFromObject(
			obj as Record<string, unknown>,
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
				historyEntry: "",
				compressedCount: 0,
				error: "missing history_entry or memory_update",
			};
		}
		const ts = os.date("%Y-%m-%d %H:%M");
		return {
			success: true,
			memoryUpdate: memoryBody,
			historyEntry: `[${ts}] ${historyEntry}`,
			compressedCount: 0,
		};
	}

	/**
	 * 处理压缩失败
	 */
	private handleCompressionFailure(
		userQuery: string,
		chunk: AgentActionRecord[],
		error: string
	): CompressionResult {
		this.consecutiveFailures++;

		if (this.consecutiveFailures >= MemoryCompressor.MAX_FAILURES) {
			// 连续失败 3 次，执行原始归档
			this.rawArchive(userQuery, chunk);
			this.consecutiveFailures = 0;

				return {
					success: true,
					memoryUpdate: this.storage.readMemory(),
					historyEntry: "[RAW ARCHIVE] Detailed history not recorded",
					compressedCount: chunk.length,
				};
		}

		return {
			success: false,
			memoryUpdate: this.storage.readMemory(),
			historyEntry: "",
			compressedCount: 0,
			error,
		};
	}

	/**
	 * 原始归档（降级方案）
	 */
	private rawArchive(userQuery: string, chunk: AgentActionRecord[]): void {
		const ts = os.date("%Y-%m-%d %H:%M");
		const prompt = userQuery.trim() !== ""
			? userQuery.trim().replace("\n", " ")
			: "(empty prompt)";
		const compactPrompt = prompt.length > 160 ? `${prompt.slice(0, 160)}...` : prompt;
		this.storage.appendHistory(
			`[${ts}] [RAW ARCHIVE] prompt="${compactPrompt}" (${chunk.length} actions, compression failed; detailed history not recorded)`
		);
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
