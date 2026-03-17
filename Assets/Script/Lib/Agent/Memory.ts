// @preview-file off clear
import { Content, Path, json } from 'Dora';
import { Message, ToolCallFunction, callLLM } from 'Agent/Utils';
import * as yaml from 'yaml';

import type { AgentActionRecord } from 'Agent/CodingAgent';

const AGENT_DIR = Path(Content.appPath, ".agent");

/**
 * Memory 配置
 */
export interface MemoryConfig {
	/** 上下文窗口大小 (tokens) */
	contextWindow: number;

	/** 压缩触发阈值 (0-1) */
	compressionThreshold: number;

	/** 最大压缩轮数 */
	maxCompressionRounds: number;

	/** 每次压缩的最大 token 数 */
	maxTokensPerCompression: number;

	/** 当前项目完整路径 */
	projectDir: string;
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

/**
 * 双层存储管理器
 *
 * 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
 */
export class DualLayerStorage {
	private projectDir: string;
	private memoryPath: string;
	private historyPath: string;

	constructor(projectDir: string) {
		this.projectDir = projectDir;
		this.memoryPath = Path(this.projectDir, "MEMORY.md");
		this.historyPath = Path(AGENT_DIR, "HISTORY.md");

		// 确保目录存在
		this.ensureDir(AGENT_DIR);
	}

	private ensureDir(dir: string): void {
		if (!Content.exist(dir)) {
			Content.mkdir(dir);
		}
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

		return `## Long-term Memory

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
	private config: MemoryConfig;
	private consecutiveFailures: number = 0;

	private static readonly MAX_FAILURES = 3;

	constructor(config?: Partial<MemoryConfig>) {
		this.config = {
			contextWindow: 32000,
			compressionThreshold: 0.8,
			maxCompressionRounds: 3,
			maxTokensPerCompression: 20000,
			projectDir: AGENT_DIR,
			...config,
		};
		this.storage = new DualLayerStorage(this.config.projectDir);
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

		const threshold = this.config.contextWindow * this.config.compressionThreshold;

		return tokens > threshold;
	}

	/**
	 * 执行压缩
	 */
	async compress(
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
			return this.handleCompressionFailure(chunk, result.error || "Unknown error", formatFunc);

		} catch (error) {
			// 异常
			return this.handleCompressionFailure(
				chunk,
				error instanceof Error ? error.message : "Unknown error",
				formatFunc
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
		if (decisionMode === "yaml") {
			return this.callLLMForCompressionByYAML(
				currentMemory,
				historyText,
				llmOptions,
				maxLLMTry
			);
		}
		return this.callLLMForCompressionByToolCalling(
			currentMemory,
			historyText,
			llmOptions,
			maxLLMTry
		);
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
				content: "You are a memory consolidation agent. You MUST call the save_memory tool."
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
				}
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
				? `\n\nPrevious response was invalid (${lastError}). Return exactly one valid YAML object only.`
				: "";
			const response = await callLLM(
				[{ role: "user", content: `${prompt}${feedback}` }],
				llmOptions
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
		return `Process this conversation and consolidate it.

## Current Long-term Memory
${currentMemory || "(empty)"}

## Recent Actions to Process
${historyText}

## Instructions

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
	- Format as a single paragraph
`;
	}

	private buildToolCallingCompressionPrompt(currentMemory: string, historyText: string): string {
		return `${this.buildCompressionPromptBody(currentMemory, historyText)}

## Output Format

Call the save_memory tool with:
- history_entry: the summary paragraph without timestamp
- memory_update: the full updated MEMORY.md content`;
	}

	private buildYAMLCompressionPrompt(currentMemory: string, historyText: string): string {
		return `${this.buildCompressionPromptBody(currentMemory, historyText)}

## Output Format

Return exactly one YAML object:
\`\`\`yaml
history_entry: "Summary paragraph"
memory_update: |-
	Full updated MEMORY.md content
\`\`\`

Rules:
- Return YAML only, no prose before or after.
- Use exactly two keys: history_entry, memory_update.
- Use a block scalar for memory_update when it spans multiple lines.`;
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
		chunk: AgentActionRecord[],
		error: string,
		formatFunc: (h: AgentActionRecord[]) => string
	): CompressionResult {
		this.consecutiveFailures++;

		if (this.consecutiveFailures >= MemoryCompressor.MAX_FAILURES) {
			// 连续失败 3 次，执行原始归档
			this.rawArchive(chunk, formatFunc);
			this.consecutiveFailures = 0;

			return {
				success: true,
				memoryUpdate: this.storage.readMemory(),
				historyEntry: "[RAW ARCHIVE] See HISTORY.md for details",
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
	private rawArchive(chunk: AgentActionRecord[], formatFunc: (h: AgentActionRecord[]) => string): void {
		const ts = os.date("%Y-%m-%d %H:%M");
		const text = formatFunc(chunk);

		this.storage.appendHistory(
			`[${ts}] [RAW ARCHIVE] ${chunk.length} actions (compression failed)\n` +
			`---\n${text}\n---`
		);
	}

	/**
	 * 获取存储实例（用于读取 memory context）
	 */
	getStorage(): DualLayerStorage {
		return this.storage;
	}
}
