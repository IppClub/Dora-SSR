// @preview-file off clear
import { App, Path, Content } from 'Dora';
import { Flow, Node } from 'Agent/flow';
import { callLLM, callLLMStreamAggregated, Message, StopToken, Log, getActiveLLMConfig, createLocalToolCallId, parseSimpleXMLChildren, parseXMLObjectFromText, safeJsonDecode, safeJsonEncode, sanitizeUTF8 } from 'Agent/Utils';
import type { LLMConfig } from 'Agent/Utils';
import * as Tools from 'Agent/Tools';
import { MemoryCompressor } from 'Agent/Memory';
import type { AgentPromptPack, AgentConversationMessage } from 'Agent/Memory';

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object";
}

function isArray(value: unknown): value is any[] {
	return Array.isArray(value);
}

interface SkillMetadata {
	name: string;
	description: string;
	always?: boolean;
}

interface Skill extends SkillMetadata {
	location: string;
	body?: string;
}

interface SkillsLoaderConfig {
	projectDir: string;
}

enum SkillPriority {
	BuiltIn = 0,
	User = 1,
	Project = 2,
}

interface SkillEntry {
	skill: Skill;
	priority: SkillPriority;
}

function stripWrappingQuotes(value: string): string {
	let [result] = string.gsub(value, '^"(.*)"$', "%1");
	[result] = string.gsub(result, "^'(.*)'$", "%1");
	return result;
}

function escapeXMLText(text: string): string {
	let [result] = string.gsub(text, "&", "&amp;");
	[result] = string.gsub(result, "<", "&lt;");
	[result] = string.gsub(result, ">", "&gt;");
	[result] = string.gsub(result, '"', "&quot;");
	[result] = string.gsub(result, "'", "&apos;");
	return result;
}

function parseYAMLFrontmatter(content: string): {
	metadata: Record<string, unknown> | undefined;
	body: string;
	error?: string;
} {
	if (!content || content.trim() === "") {
		return { metadata: undefined, body: "", error: "empty content" };
	}

	const trimmed = content.trim();
	if (!trimmed.startsWith("---")) {
		return { metadata: undefined, body: content };
	}

	const lines = trimmed.split("\n");
	let endLine = -1;
	for (let i = 1; i < lines.length; i++) {
		if (lines[i].trim() === "---") {
			endLine = i;
			break;
		}
	}

	if (endLine < 0) {
		return { metadata: undefined, body: content, error: "missing closing ---" };
	}

	const frontmatterLines = lines.slice(1, endLine);
	const frontmatterText = frontmatterLines.join("\n").trim();

	const metadata = parseSimpleYAML(frontmatterText);

	const bodyLines = lines.slice(endLine + 1);
	const body = bodyLines.join("\n").trim();

	return { metadata, body };
}

function parseSimpleYAML(text: string): Record<string, unknown> | undefined {
	if (!text || text.trim() === "") {
		return undefined;
	}

	const result: Record<string, unknown> = {};
	const lines = text.split("\n");
	let currentKey = "";
	let currentArray: string[] | undefined = undefined;

	for (let i = 0; i < lines.length; i++) {
		const line = lines[i];
		const trimmed = line.trim();

		if (trimmed === "" || trimmed.startsWith("#")) {
			continue;
		}

		if (trimmed.startsWith("- ")) {
			if (currentArray !== undefined && currentKey !== "") {
				const value = trimmed.substring(2).trim();
				const cleaned = stripWrappingQuotes(value);
				currentArray.push(cleaned);
			}
			continue;
		}

		const colonIndex = trimmed.indexOf(":");
		if (colonIndex > 0) {
			if (currentArray !== undefined && currentKey !== "") {
				result[currentKey] = currentArray;
				currentArray = undefined;
			}

			const key = trimmed.substring(0, colonIndex).trim();
			let value = trimmed.substring(colonIndex + 1).trim();

			if (value.startsWith("[") && value.endsWith("]")) {
				const arrayText = value.substring(1, value.length - 1);
				const items = arrayText.split(",").map(item => {
					const cleaned = stripWrappingQuotes(item.trim());
					return cleaned;
				});
				result[key] = items;
				continue;
			}

			if (value === "true") {
				result[key] = true;
				continue;
			}
			if (value === "false") {
				result[key] = false;
				continue;
			}

			if (value === "") {
				currentKey = key;
				currentArray = [];
				if (i + 1 < lines.length) {
					const nextLine = lines[i + 1].trim();
					if (!nextLine.startsWith("- ")) {
						currentArray = undefined;
						result[key] = "";
					}
				} else {
					currentArray = undefined;
					result[key] = "";
				}
				continue;
			}

			const cleaned = stripWrappingQuotes(value);
			result[key] = cleaned;
			currentKey = "";
			currentArray = undefined;
		}
	}

	if (currentArray !== undefined && currentKey !== "") {
		result[currentKey] = currentArray;
	}

	return result;
}

function validateSkillMetadata(
	metadata?: Record<string, unknown>
): { metadata: SkillMetadata; error?: string } {
	if (!metadata) {
		return {
			metadata: {
				name: "",
				description: "",
			},
			error: "missing frontmatter",
		};
	}

	const name = typeof metadata.name === "string" ? metadata.name.trim() : "";
	if (name === "") {
		return {
			metadata: {
				name: "",
				description: "",
			},
			error: "missing name in frontmatter",
		};
	}

	const description = typeof metadata.description === "string"
		? metadata.description.trim()
		: "";

	const always = metadata.always === true;

	return {
		metadata: {
			name,
			description,
			always
		},
	};
}

class SkillsLoader {
	private config: SkillsLoaderConfig;
	private skills: Map<string, SkillEntry> = new Map();
	private loaded = false;

	constructor(config: SkillsLoaderConfig) {
		this.config = config;
	}

	load(): void {
		this.skills.clear();

		const builtInDir = Path(Content.assetPath, "Doc", "skills");
		const builtInParent = Content.assetPath;
		this.loadSkillsFromDir(builtInDir, builtInParent, SkillPriority.BuiltIn);

		const userDir = Path(Content.writablePath, ".agent", "skills");
		const userParent = Content.writablePath;
		this.loadSkillsFromDir(userDir, userParent, SkillPriority.User);

		const projectDir = Path(this.config.projectDir, ".agent", "skills");
		const projectParent = this.config.projectDir;
		this.loadSkillsFromDir(projectDir, projectParent, SkillPriority.Project);

		this.loaded = true;
		Log("Info", `[SkillsLoader] Loaded ${this.skills.size} skills`);
	}

	private loadSkillsFromDir(dir: string, parent: string, priority: SkillPriority): void {
		if (!Content.exist(dir) || !Content.isdir(dir)) {
			return;
		}

		const subdirs = Content.getDirs(dir);
		if (!subdirs || subdirs.length === 0) {
			return;
		}

		for (const subdir of subdirs) {
			const skillPath = Path(dir, subdir, "SKILL.md");
			if (!Content.exist(skillPath)) {
				continue;
			}

			const skill = this.loadSkillFile(skillPath);
			if (!skill) {
				continue;
			}

			skill.location = Path.getRelative(skillPath, parent);

			const existing = this.skills.get(skill.name);
			if (existing && existing.priority >= priority) {
				continue;
			}

			this.skills.set(skill.name, { skill, priority });
		}
	}

	private loadSkillFile(skillPath: string): Skill | undefined {
		const content = Content.load(skillPath);
		if (!content) {
			Log("Warn", `[SkillsLoader] Failed to read ${skillPath}`);
			return undefined;
		}

		const parsed = parseYAMLFrontmatter(content);
		const validated = validateSkillMetadata(parsed.metadata);

		if (validated.error) {
			Log("Warn", `[SkillsLoader] Invalid SKILL.md at ${skillPath}: ${validated.error}`);
			return undefined;
		}

		let displayLocation = skillPath;
		if (skillPath.startsWith(this.config.projectDir)) {
			displayLocation = Path.getRelative(skillPath, this.config.projectDir);
		}

		const skill: Skill = {
			...validated.metadata,
			location: displayLocation,
			body: parsed.body,
		};

		return skill;
	}

	getAllSkills(): Skill[] {
		if (!this.loaded) {
			this.load();
		}

		const result: Skill[] = [];
		for (const entry of this.skills.values()) {
			result.push(entry.skill);
		}

		result.sort((a, b) => {
			if (a.name < b.name) {
				return -1;
			}
			if (a.name > b.name) {
				return 1;
			}
			if (a.location < b.location) {
				return -1;
			}
			if (a.location > b.location) {
				return 1;
			}
			return 0;
		});

		return result;
	}

	getSkill(name: string): Skill | undefined {
		if (!this.loaded) {
			this.load();
		}

		return this.skills.get(name)?.skill;
	}

	getAlwaysSkills(): Skill[] {
		const all = this.getAllSkills();
		return all.filter(skill => skill.always === true);
	}

	getSummarySkills(): Skill[] {
		const all = this.getAllSkills();
		return all.filter(skill => skill.always !== true);
	}

	buildLevel1Summary(): string {
		const skills = this.getSummarySkills();

		if (skills.length === 0) {
			return "";
		}

		const parts: string[] = [];

		for (const skill of skills) {
			let skillXML = `<skill>\n`;
			skillXML += `	<name>${this.escapeXML(skill.name)}</name>\n`;
			skillXML += `	<description>${this.escapeXML(skill.description)}</description>\n`;
			skillXML += `	<location>${this.escapeXML(skill.location)}</location>\n`;
			skillXML += `</skill>`;
			parts.push(skillXML);
		}

		return parts.join("\n\n");
	}

	buildActiveSkillsContent(): string {
		const skills = this.getAlwaysSkills();

		if (skills.length === 0) {
			return "";
		}

		const parts: string[] = [];

		for (const skill of skills) {
			parts.push(`## Skill: ${skill.name}\n`);
			if (skill.description !== undefined) {
				parts.push(`${skill.description}\n`);
			}
			if (skill.body && skill.body.trim() !== "") {
				parts.push(`\n${skill.body}`);
			}
			parts.push("");
		}

		return parts.join("\n");
	}

	loadSkillContent(name: string): string | undefined {
		const skill = this.getSkill(name);
		if (!skill) {
			return undefined;
		}

		if (skill.body && skill.body.trim() !== "") {
			return skill.body;
		}

		const content = Content.load(skill.location);
		if (!content) {
			return undefined;
		}

		const parsed = parseYAMLFrontmatter(content);
		return parsed.body || undefined;
	}

	buildSkillsPromptSection(): string {
		if (!this.loaded) {
			this.load();
		}

		const sections: string[] = [];

		const activeContent = this.buildActiveSkillsContent();
		sections.push(`# Active Skills\n\n${activeContent}`);

		const summary = this.buildLevel1Summary();
		sections.push(`# Skills\n\nRead a skill's SKILL.md with \`read_file\` for full instructions.\n\n${summary}`);

		return sections.join("\n\n---\n\n");
	}

	private escapeXML(text: string): string {
		return escapeXMLText(text);
	}

	reload(): void {
		this.loaded = false;
		this.load();
	}

	getSkillCount(): number {
		if (!this.loaded) {
			this.load();
		}
		return this.skills.size;
	}
}

function createSkillsLoader(config: SkillsLoaderConfig): SkillsLoader {
	return new SkillsLoader(config);
}

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
	memoryScope?: string;
	role?: "main" | "sub";
	spawnSubAgent?: (this: void, request: {
		parentSessionId: number;
		projectRoot?: string;
		title: string;
		prompt: string;
		expectedOutput?: string;
		filesHint?: string[];
	}) => Promise<
		| { success: true; sessionId: number; taskId: number; title: string }
		| { success: false; message: string }
	>;
	listSubAgents?: (this: void, request: {
		sessionId: number;
		projectRoot?: string;
		status?: string;
		limit?: number;
		offset?: number;
		query?: string;
	}) => Promise<
		| {
			success: true;
			rootSessionId: number;
			maxConcurrent: number;
			status: string;
			limit: number;
			offset: number;
			hasMore: boolean;
			sessions: {
				sessionId: number;
				title: string;
				parentSessionId?: number;
				rootSessionId: number;
				status: string;
				currentTaskId?: number;
				currentTaskStatus?: string;
				goal?: string;
				expectedOutput?: string;
				filesHint?: string[];
				summary?: string;
				success?: boolean;
				resultFilePath?: string;
				artifactDir?: string;
				finishedAt?: string;
				createdAt: number;
				updatedAt: number;
			}[];
		}
		| { success: false; message: string }
	>;
	onEvent?: (event: CodingAgentEvent) => void;
}

export const AGENT_USER_PROMPT_MAX_CHARS = 12000;

type AgentDecisionMode = "tool_calling" | "xml";
type AgentPromptCommand = "compact" | "clear";
type AgentRole = "main" | "sub";

export type AgentToolName =
	| "read_file"
	| "edit_file"
	| "delete_file"
	| "grep_files"
	| "search_dora_api"
	| "glob_files"
	| "build"
	| "list_sub_agents"
	| "spawn_sub_agent"
	| "finish";

export type AgentStepToolName = AgentToolName | "compress_memory";

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
		type: "memory_compression_started";
		sessionId?: number;
		taskId: number;
		step: number;
		tool: "compress_memory";
		reason?: string;
		params: Record<string, unknown>;
	}
	| {
		type: "memory_compression_finished";
		sessionId?: number;
		taskId: number;
		step: number;
		tool: "compress_memory";
		reason?: string;
		result: Record<string, unknown>;
	}
	| {
		type: "assistant_message_updated";
		sessionId?: number;
		taskId: number;
		step: number;
		content: string;
		reasoningContent?: string;
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
const AGENT_DEFAULT_MAX_STEPS = 100;
const AGENT_DEFAULT_LLM_MAX_TRY = 5;
const AGENT_DEFAULT_LLM_TEMPERATURE = 0.1;
const AGENT_DEFAULT_LLM_MAX_TOKENS = 8192;

function buildLLMOptions(llmConfig: LLMConfig, overrides?: Record<string, unknown>): Record<string, unknown> {
	const options: Record<string, unknown> = {
		temperature: llmConfig.temperature ?? AGENT_DEFAULT_LLM_TEMPERATURE,
		max_tokens: llmConfig.maxTokens ?? AGENT_DEFAULT_LLM_MAX_TOKENS,
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
	role: AgentRole;
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
	pendingToolActions?: AgentActionRecord[];
	messages: AgentConversationMessage[];
	lastConsolidatedIndex: number;
	carryMessageIndex?: number;
	// Memory 相关字段
	memory: {
		/** Memory 压缩器实例 */
		compressor: MemoryCompressor;
	};
	// Skills 相关字段
	skills: {
		/** Skills 加载器实例 */
		loader: SkillsLoader;
	};
	spawnSubAgent?: CodingAgentRunOptions["spawnSubAgent"];
	listSubAgents?: CodingAgentRunOptions["listSubAgents"];
}

function emitAgentEvent(shared: AgentShared, event: CodingAgentEvent) {
	if (shared.onEvent) {
		try {
			shared.onEvent(event);
		} catch (error) {
			Log("Error", `[CodingAgent] onEvent handler failed: ${tostring(error)}`);
		}
	}
}

function emitAgentStartEvent(shared: AgentShared, action: AgentActionRecord) {
	emitAgentEvent(shared, {
		type: "tool_started",
		sessionId: shared.sessionId,
		taskId: shared.taskId,
		step: action.step,
		tool: action.tool,
	});
}

function emitAgentFinishEvent(shared: AgentShared, action: AgentActionRecord) {
	emitAgentEvent(shared, {
		type: "tool_finished",
		sessionId: shared.sessionId,
		taskId: shared.taskId,
		step: action.step,
		tool: action.tool,
		result: action.result ?? {},
	});
}

function emitAssistantMessageUpdated(shared: AgentShared, content: string, reasoningContent?: string) {
	emitAgentEvent(shared, {
		type: "assistant_message_updated",
		sessionId: shared.sessionId,
		taskId: shared.taskId,
		step: shared.step + 1,
		content,
		reasoningContent,
	});
}

function getMemoryCompressionStartReason(shared: AgentShared): string {
	return shared.useChineseResponse
		? `开始进行上下文记忆压缩。`
		: `Starting context memory compression.`;
}

function getMemoryCompressionSuccessReason(shared: AgentShared, compressedCount: number): string {
	return shared.useChineseResponse
		? `记忆压缩完成，已整理 ${compressedCount} 条历史消息。`
		: `Memory compression finished after consolidating ${compressedCount} historical messages.`;
}

function getMemoryCompressionFailureReason(shared: AgentShared, error: string): string {
	return shared.useChineseResponse
		? `记忆压缩失败：${error}`
		: `Memory compression failed: ${error}`;
}

function summarizeHistoryEntryPreview(text: string, maxChars = 180): string {
	const trimmed = text.trim();
	if (trimmed === "") return "";
	return truncateText(trimmed, maxChars);
}

function getCancelledReason(shared: AgentShared): string {
	if (shared.stopToken.reason && shared.stopToken.reason !== "") return shared.stopToken.reason;
	return shared.useChineseResponse ? "已取消" : "cancelled";
}

function getMaxStepsReachedReason(shared: AgentShared): string {
	return shared.useChineseResponse
		? `已达到最大执行步数限制（${shared.maxSteps} 步）。如需继续后续处理，请发送“继续”。`
		: `Maximum step limit reached (${shared.maxSteps} steps). Send "continue" if you want to proceed with the remaining work.`;
}

function getFailureSummaryFallback(shared: AgentShared, error: string): string {
	return shared.useChineseResponse
		? `任务因以下问题结束：${error}`
		: `The task ended due to the following issue: ${error}`;
}

function finalizeAgentFailure(shared: AgentShared, error: string): CodingAgentRunResult {
	if (shared.stopToken.stopped) {
		Tools.setTaskStatus(shared.taskId, "STOPPED");
		return emitAgentTaskFinishEvent(shared, false, getCancelledReason(shared));
	}
	Tools.setTaskStatus(shared.taskId, "FAILED");
	return emitAgentTaskFinishEvent(shared, false, error);
}

function getPromptCommand(prompt: string): AgentPromptCommand | undefined {
	const trimmed = prompt.trim();
	if (trimmed === "/compact") return "compact";
	if (trimmed === "/clear") return "clear";
	return undefined;
}

export function truncateAgentUserPrompt(prompt: string): string {
	if (!prompt) return "";
	if (prompt.length <= AGENT_USER_PROMPT_MAX_CHARS) return prompt;
	const offset = utf8.offset(prompt, AGENT_USER_PROMPT_MAX_CHARS + 1);
	if (offset === undefined) return prompt;
	return string.sub(prompt, 1, offset - 1);
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
	if (tool !== "read_file" || result.success !== true || typeof result.content !== "string") {
		return result;
	}
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	clone.content = limitReadContentForHistory(result.content, tool);
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

function sanitizeSearchResultForHistory(
	tool: AgentToolName,
	result: Record<string, unknown>
): Record<string, unknown> {
	if (result.success !== true || !isArray(result.results)) return result;
	if (tool !== "grep_files" && tool !== "search_dora_api") return result;
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	const maxItems = tool === "grep_files" ? HISTORY_SEARCH_FILES_MAX_MATCHES : HISTORY_SEARCH_DORA_API_MAX_MATCHES;
	clone.results = sanitizeSearchMatchesForHistory(
		result.results,
		maxItems
	);
	if (tool === "grep_files" && isArray(result.groupedResults)) {
		const grouped = result.groupedResults;
		const shown = math.min(grouped.length, HISTORY_SEARCH_FILES_MAX_MATCHES);
		const sanitizedGroups: Record<string, unknown>[] = [];
		for (let i = 0; i < shown; i++) {
			const row = grouped[i];
			sanitizedGroups.push({
				file: row.file,
				totalMatches: row.totalMatches,
				matches: isArray(row.matches)
					? sanitizeSearchMatchesForHistory(row.matches, 3)
					: [],
			});
		}
		clone.groupedResults = sanitizedGroups;
	}
	return clone;
}

function sanitizeListFilesResultForHistory(result: Record<string, unknown>): Record<string, unknown> {
	if (result.success !== true || !isArray(result.files)) return result;
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	clone.files = result.files.slice(0, HISTORY_LIST_FILES_MAX_ENTRIES);
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
	const spawnTool = `

9. list_sub_agents: Query sub-agent state under the current main session
	- Parameters: status(optional), limit(optional), offset(optional), query(optional)
	- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.
	- status defaults to active_or_recent and may also be running, done, failed, or all.
	- limit defaults to a small recent window. Use offset to page older items.
	- query filters by title, goal, or summary text.
	- Do not use this after a successful spawn_sub_agent in the same turn.

10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work
	- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)
	- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.
	- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.
	- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.
	- title should be short and specific.
	- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.
	- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.
	- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.
	- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.
	- filesHint is an optional list of likely files or directories.`;
	const availability = shared
		? `\n\nTool availability for this runtime:\n- role: ${shared.role}\n- allowed tools: ${getAllowedToolsForRole(shared.role).join(", ")}`
		: "";
	const withRole = `${base}${shared?.role === "main" ? spawnTool : ""}${availability}`;
	if (shared?.decisionMode !== "xml") {
		return withRole;
	}
	return `${withRole}

XML mode object fields:
- Use a single root tag: <tool_call>.
- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.
- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.
- Inside <params>, use one child tag per parameter and preserve each tag content as raw text.`;
}

function isToolAllowedForRole(role: AgentRole, tool: AgentToolName): boolean {
	return getAllowedToolsForRole(role).indexOf(tool) >= 0;
}

async function maybeCompressHistory(shared: AgentShared): Promise<void> {
	const { memory } = shared;
	const maxRounds = memory.compressor.getMaxCompressionRounds();
	let changed = false;
	for (let round = 0; round < maxRounds; round++) {
		const systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode === "xml");
		const activeMessages = getActiveConversationMessages(shared);
		// In tool_calling mode, tool definitions are passed as the tools API parameter and
		// consume tokens, but are NOT embedded in the system prompt. Pass them separately
		// so the token estimator accounts for them correctly.
		const toolDefinitions = shared.decisionMode === "tool_calling"
			? getDecisionToolDefinitions(shared)
			: "";
		if (!memory.compressor.shouldCompress(
			activeMessages,
			systemPrompt,
			toolDefinitions
		)) {
			if (changed) {
				persistHistoryState(shared);
			}
			return;
		}
		const compressionRound = round + 1;
		shared.step += 1;
		const stepId = shared.step;
		const pendingMessages = activeMessages.length;
		emitAgentEvent(shared, {
			type: "memory_compression_started",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: stepId,
			tool: "compress_memory",
			reason: getMemoryCompressionStartReason(shared),
			params: {
				round: compressionRound,
				maxRounds,
				pendingMessages,
			},
		});
		const result = await memory.compressor.compress(
			activeMessages,
			shared.llmOptions,
			shared.llmMaxTry,
			shared.decisionMode,
			{
				onInput: (phase, messages, options) => {
					saveStepLLMDebugInput(shared, stepId, phase, messages, options);
				},
				onOutput: (phase, text, meta) => {
					saveStepLLMDebugOutput(shared, stepId, phase, text, meta);
				},
			},
			"default",
			systemPrompt,
			toolDefinitions
		);
		if (!(result && result.success && result.compressedCount > 0)) {
			emitAgentEvent(shared, {
				type: "memory_compression_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: stepId,
				tool: "compress_memory",
				reason: getMemoryCompressionFailureReason(
					shared,
					result?.error ?? "compression returned no changes"
				),
				result: {
					success: false,
					round: compressionRound,
					error: result?.error ?? "compression returned no changes",
					compressedCount: result?.compressedCount ?? 0,
				},
			});
			if (changed) {
				persistHistoryState(shared);
			}
			return;
		}
		const effectiveCompressedCount = math.max(
			0,
			result.compressedCount - (typeof shared.carryMessageIndex === "number" ? 1 : 0)
		);
		if (effectiveCompressedCount <= 0) {
			if (changed) {
				persistHistoryState(shared);
			}
			return;
		}
		emitAgentEvent(shared, {
			type: "memory_compression_finished",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: stepId,
			tool: "compress_memory",
			reason: getMemoryCompressionSuccessReason(shared, result.compressedCount),
			result: {
				success: true,
				round: compressionRound,
				compressedCount: effectiveCompressedCount,
				historyEntryPreview: summarizeHistoryEntryPreview(result.summary ?? ""),
			},
		});
		applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex);
		changed = true;
		Log("Info", `[Memory] Compressed ${effectiveCompressedCount} messages (round ${compressionRound})`);
	}
	if (changed) {
		persistHistoryState(shared);
	}
}

async function compactAllHistory(shared: AgentShared): Promise<CodingAgentRunResult> {
	const { memory } = shared;
	let rounds = 0;
	let totalCompressed = 0;
	while (getActiveRealMessageCount(shared) > 0) {
		if (shared.stopToken.stopped) {
			Tools.setTaskStatus(shared.taskId, "STOPPED");
			return emitAgentTaskFinishEvent(shared, false, getCancelledReason(shared));
		}
		rounds += 1;
		shared.step += 1;
		const stepId = shared.step;
		const activeMessages = getActiveConversationMessages(shared);
		const pendingMessages = activeMessages.length;
		emitAgentEvent(shared, {
			type: "memory_compression_started",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: stepId,
			tool: "compress_memory",
			reason: getMemoryCompressionStartReason(shared),
			params: {
				round: rounds,
				maxRounds: 0,
				pendingMessages,
				fullCompaction: true,
			},
		});
		const result = await memory.compressor.compress(
			activeMessages,
			shared.llmOptions,
			shared.llmMaxTry,
			shared.decisionMode,
			{
				onInput: (phase, messages, options) => {
					saveStepLLMDebugInput(shared, stepId, phase, messages, options);
				},
				onOutput: (phase, text, meta) => {
					saveStepLLMDebugOutput(shared, stepId, phase, text, meta);
				},
			},
			"budget_max"
		);
		if (!(result && result.success && result.compressedCount > 0)) {
			emitAgentEvent(shared, {
				type: "memory_compression_finished",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: stepId,
				tool: "compress_memory",
				reason: getMemoryCompressionFailureReason(
					shared,
					result?.error ?? "compression returned no changes"
				),
				result: {
					success: false,
					rounds,
					error: result?.error ?? "compression returned no changes",
					compressedCount: result?.compressedCount ?? 0,
					fullCompaction: true,
				},
			});
			return finalizeAgentFailure(shared,
				result?.error ?? (shared.useChineseResponse
					? "记忆压缩未产生可推进的结果。"
					: "Memory compression produced no progress."));
		}
		const effectiveCompressedCount = math.max(
			0,
			result.compressedCount - (typeof shared.carryMessageIndex === "number" ? 1 : 0)
		);
		if (effectiveCompressedCount <= 0) {
			return finalizeAgentFailure(
				shared,
				shared.useChineseResponse
					? "记忆压缩未产生可推进的结果。"
					: "Memory compression produced no progress."
			);
		}
		emitAgentEvent(shared, {
			type: "memory_compression_finished",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: stepId,
			tool: "compress_memory",
			reason: getMemoryCompressionSuccessReason(shared, result.compressedCount),
			result: {
				success: true,
				round: rounds,
				compressedCount: effectiveCompressedCount,
				historyEntryPreview: summarizeHistoryEntryPreview(result.summary ?? ""),
				fullCompaction: true,
			},
		});
		applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex);
		totalCompressed += effectiveCompressedCount;
		persistHistoryState(shared);
		Log("Info", `[Memory] Full compaction compressed ${effectiveCompressedCount} messages (round ${rounds})`);
	}
	Tools.setTaskStatus(shared.taskId, "DONE");
	return emitAgentTaskFinishEvent(
		shared,
		true,
		shared.useChineseResponse
			? `会话整理完成，共整理 ${totalCompressed} 条消息，耗时 ${rounds} 轮。`
			: `Session compaction completed. Consolidated ${totalCompressed} messages in ${rounds} rounds.`
	);
}

function clearSessionHistory(shared: AgentShared): CodingAgentRunResult {
	shared.messages = [];
	shared.lastConsolidatedIndex = 0;
	shared.carryMessageIndex = undefined;
	persistHistoryState(shared);
	Tools.setTaskStatus(shared.taskId, "DONE");
	return emitAgentTaskFinishEvent(
		shared,
		true,
		shared.useChineseResponse
			? "SESSION.jsonl 已清空。"
			: "SESSION.jsonl has been cleared."
	);
}

function isKnownToolName(name: string): name is AgentToolName {
	return name === "read_file"
		|| name === "edit_file"
		|| name === "delete_file"
		|| name === "grep_files"
		|| name === "search_dora_api"
		|| name === "glob_files"
		|| name === "build"
		|| name === "list_sub_agents"
		|| name === "spawn_sub_agent"
		|| name === "finish";
}

function getFinishMessage(params: Record<string, unknown>, fallback = ""): string {
	if (typeof params.message === "string" && params.message.trim() !== "") {
		return params.message.trim();
	}
	if (typeof params.response === "string" && params.response.trim() !== "") {
		return params.response.trim();
	}
	if (typeof params.summary === "string" && params.summary.trim() !== "") {
		return params.summary.trim();
	}
	return fallback.trim();
}

function persistHistoryState(shared: AgentShared): void {
	shared.memory.compressor.getStorage().writeSessionState(
		shared.messages,
		shared.lastConsolidatedIndex,
		shared.carryMessageIndex
	);
}

function getActiveConversationMessages(shared: AgentShared): AgentConversationMessage[] {
	const activeMessages: AgentConversationMessage[] = [];
	if (
		typeof shared.carryMessageIndex === "number"
		&& shared.carryMessageIndex >= 0
		&& shared.carryMessageIndex < shared.lastConsolidatedIndex
		&& shared.carryMessageIndex < shared.messages.length
	) {
		activeMessages.push({
			...shared.messages[shared.carryMessageIndex],
		});
	}
	for (let i = shared.lastConsolidatedIndex; i < shared.messages.length; i++) {
		activeMessages.push(shared.messages[i]);
	}
	return activeMessages;
}

function getActiveRealMessageCount(shared: AgentShared): number {
	return math.max(0, shared.messages.length - shared.lastConsolidatedIndex);
}

function applyCompressedSessionState(
	shared: AgentShared,
	compressedCount: number,
	carryMessageIndex?: number
): void {
	const syntheticPrefixCount = typeof shared.carryMessageIndex === "number" ? 1 : 0;
	const previousActiveStart = shared.lastConsolidatedIndex;
	const realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount);
	shared.lastConsolidatedIndex = math.min(
		shared.messages.length,
		previousActiveStart + realCompressedCount
	);
	if (typeof carryMessageIndex === "number") {
		if (syntheticPrefixCount > 0 && carryMessageIndex === 0) {
			// Keep the previously carried user message.
		} else {
			const carryOffset = syntheticPrefixCount > 0
				? carryMessageIndex - 1
				: carryMessageIndex;
			shared.carryMessageIndex = carryOffset >= 0
				? previousActiveStart + carryOffset
				: undefined;
		}
	} else {
		shared.carryMessageIndex = undefined;
	}
	if (
		typeof shared.carryMessageIndex === "number"
		&& (
			shared.carryMessageIndex < 0
			|| shared.carryMessageIndex >= shared.lastConsolidatedIndex
			|| shared.carryMessageIndex >= shared.messages.length
		)
	) {
		shared.carryMessageIndex = undefined;
	}
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

function appendAssistantToolCallsMessage(
	shared: AgentShared,
	actions: AgentActionRecord[],
	content?: string,
	reasoningContent?: string
): void {
	appendConversationMessage(shared, {
		role: "assistant",
		content: content ?? "",
		reasoning_content: reasoningContent,
		tool_calls: actions.map(action => ({
			id: action.toolCallId,
			type: "function",
			function: {
				name: action.tool,
				arguments: toJson(action.params),
			},
		})),
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
	text: string;
	reasoningContent?: string
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
		const message = res.response.choices?.[0]?.message;
		const text = message?.content;
		const reasoningContent = typeof message?.reasoning_content === "string"
			? sanitizeUTF8(message.reasoning_content)
			: undefined;
		if (text) {
			saveStepLLMDebugOutput(shared, stepId, phase, text, { success: true });
			return { success: true, text, reasoningContent };
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
type DecisionBatchSuccess = {
	success: true;
	kind: "batch";
	decisions: DecisionSuccess[];
	content?: string;
	reasoningContent?: string;
};
type DecisionResult = DecisionSuccess | DecisionBatchSuccess | DecisionFailure;
type DecisionFailure = { success: false; message: string; raw?: string };

function isDecisionBatchSuccess(result: DecisionSuccess | DecisionBatchSuccess): result is DecisionBatchSuccess {
	return (result as DecisionBatchSuccess).kind === "batch";
}

function parseDecisionObject(rawObj: Record<string, unknown>): DecisionSuccess | DecisionFailure {
	if (typeof rawObj.tool !== "string") return { success: false, message: "missing tool" };
	const tool = rawObj.tool;
	if (!isKnownToolName(tool)) {
		return { success: false, message: `unknown tool: ${tool}` };
	}
	const reason = typeof rawObj.reason === "string"
		? rawObj.reason.trim()
		: undefined;
	if (tool !== "finish" && (!reason || reason === "")) {
		return { success: false, message: `${tool} requires top-level reason` };
	}
	const params = isRecord(rawObj.params) ? rawObj.params : {};
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
	if (!isRecord(rawObj)) {
		return { success: false, message: `invalid ${functionName} arguments` };
	}
	return {
		success: true,
		tool: functionName,
		params: rawObj,
	};
}

function parseToolCallArguments(functionName: string, argsText: string): Record<string, unknown> | DecisionFailure {
	if (argsText.trim() === "") {
		return {};
	}
	const [rawObj, err] = safeJsonDecode(argsText);
	if (err !== undefined || rawObj === undefined) {
		return {
			success: false,
			message: `invalid ${functionName} arguments: ${tostring(err)}`,
			raw: argsText,
		};
	}
	const [encodedRaw] = safeJsonEncode(rawObj as object);
	if (encodedRaw === "null" || !isRecord(rawObj) || isArray(rawObj)) {
		return {
			success: false,
			message: `invalid ${functionName} arguments`,
			raw: argsText,
		};
	}
	return rawObj;
}

function parseAndValidateToolCallDecision(
	shared: AgentShared,
	functionName: string,
	argsText: string,
	toolCallId?: string,
	reason?: string,
	reasoningContent?: string
): DecisionSuccess | DecisionFailure {
	const rawArgs = parseToolCallArguments(functionName, argsText);
	if (isRecord(rawArgs) && rawArgs.success === false) {
		return rawArgs as DecisionFailure;
	}
	const decision = parseDecisionToolCall(functionName, rawArgs);
	if (!decision.success) {
		return {
			success: false,
			message: decision.message,
			raw: argsText,
		};
	}
	const validation = validateDecision(decision.tool, decision.params);
	if (!validation.success) {
		return {
			success: false,
			message: validation.message,
			raw: argsText,
		};
	}
	if (!isToolAllowedForRole(shared.role, decision.tool)) {
		return {
			success: false,
			message: `${decision.tool} is not allowed for role ${shared.role}`,
			raw: argsText,
		};
	}
	decision.params = validation.params;
	decision.toolCallId = ensureToolCallId(toolCallId);
	decision.reason = reason;
	decision.reasoningContent = reasoningContent;
	return decision;
}

function getDecisionPath(params: Record<string, unknown>): string {
	if (typeof params.path === "string") return params.path.trim();
	if (typeof params.target_file === "string") return params.target_file.trim();
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

function parseReadLineParam(
	value: unknown,
	fallback: number,
	paramName: "startLine" | "endLine"
): { success: true; value: number } | { success: false; message: string } {
	let num = Number(value);
	if (!Number.isFinite(num)) num = fallback;
	num = math.floor(num);
	if (num === 0) {
		return { success: false, message: `${paramName} cannot be 0` };
	}
	return { success: true, value: num };
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
		const startLineRes = parseReadLineParam(params.startLine, 1, "startLine");
		if (!startLineRes.success) return startLineRes;
		const endLineDefault = startLineRes.value < 0 ? -1 : READ_FILE_DEFAULT_LIMIT;
		const endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine");
		if (!endLineRes.success) return endLineRes;
		params.startLine = startLineRes.value;
		params.endLine = endLineRes.value;
		return { success: true, params };
	}

	if (tool === "edit_file") {
		const path = getDecisionPath(params);
		if (path === "") return { success: false, message: "edit_file requires path" };
		const oldStr = typeof params.old_str === "string" ? params.old_str : "";
		const newStr = typeof params.new_str === "string" ? params.new_str : "";
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
		const pattern = typeof params.pattern === "string" ? params.pattern.trim() : "";
		if (pattern === "") return { success: false, message: "grep_files requires pattern" };
		params.pattern = pattern;
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1);
		params.offset = clampIntegerParam(params.offset, 0, 0);
		return { success: true, params };
	}

	if (tool === "search_dora_api") {
		const pattern = typeof params.pattern === "string" ? params.pattern.trim() : "";
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

	if (tool === "list_sub_agents") {
		const status = typeof params.status === "string" ? params.status.trim() : "";
		if (status !== "") {
			params.status = status;
		}
		params.limit = clampIntegerParam(params.limit, 5, 1);
		params.offset = clampIntegerParam(params.offset, 0, 0);
		if (typeof params.query === "string") {
			params.query = params.query.trim();
		}
		return { success: true, params };
	}

	if (tool === "spawn_sub_agent") {
		const prompt = typeof params.prompt === "string" ? params.prompt.trim() : "";
		const title = typeof params.title === "string" ? params.title.trim() : "";
		if (prompt === "") return { success: false, message: "spawn_sub_agent requires prompt" };
		if (title === "") return { success: false, message: "spawn_sub_agent requires title" };
		params.prompt = prompt;
		params.title = title;
		if (typeof params.expectedOutput === "string") {
			params.expectedOutput = params.expectedOutput.trim();
		}
		if (isArray(params.filesHint)) {
			params.filesHint = params.filesHint
				.filter(item => typeof item === "string")
				.map(item => sanitizeUTF8(item));
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

function getAllowedToolsForRole(role: AgentRole): AgentToolName[] {
	return role === "main"
		? ["read_file", "edit_file", "delete_file", "grep_files", "search_dora_api", "glob_files", "build", "list_sub_agents", "spawn_sub_agent", "finish"]
		: ["read_file", "edit_file", "delete_file", "grep_files", "search_dora_api", "glob_files", "build", "finish"];
}

function buildDecisionToolSchema(shared: AgentShared) {
	const allowed = getAllowedToolsForRole(shared.role);
	const tools = [
		createFunctionToolSchema(
			"read_file",
			"Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.",
			{
				path: { type: "string", description: "Workspace-relative file path to read." },
				startLine: { type: "number", description: "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid." },
				endLine: { type: "number", description: "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid." },
			},
			["path"]
		),
		createFunctionToolSchema(
			"edit_file",
			"Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.",
			{
				path: { type: "string", description: "Workspace-relative file path to edit." },
				old_str: { type: "string", description: "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing." },
				new_str: { type: "string", description: "Replacement text or the full file content when rewriting or creating." },
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
		createFunctionToolSchema(
			"list_sub_agents",
			"Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.",
			{
				status: { type: "string", enum: ["active_or_recent", "running", "done", "failed", "all"], description: "Optional status filter. Defaults to active_or_recent." },
				limit: { type: "number", description: "Maximum number of items to return. Defaults to 5." },
				offset: { type: "number", description: "Offset for paging older items." },
				query: { type: "string", description: "Optional text filter matched against title, goal, or summary." },
			}
		),
		createFunctionToolSchema(
			"spawn_sub_agent",
			"Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.",
			{
				title: { type: "string", description: "Short tab title for the sub agent." },
				prompt: { type: "string", description: "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known." },
				expectedOutput: { type: "string", description: "Optional expected result summary." },
				filesHint: { type: "array", items: { type: "string" }, description: "Optional likely files or directories involved." },
			},
			["title", "prompt"]
		),
	];
	return tools.filter(tool => allowed.indexOf(tool.function.name as AgentToolName) >= 0);
}

function buildAgentSystemPrompt(shared: AgentShared, includeToolDefinitions = false): string {
	const rolePrompt = shared.role === "main"
		? `### Agent Role

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
- Treat the sub-agent completion result as an asynchronous handoff that should be continued in later conversation turns.`
		: `### Agent Role

You are a sub agent. Your job is to execute concrete implementation, editing, and build work delegated by the main agent.

Rules:
- Focus on completing the delegated task end-to-end.
- Use the available implementation tools directly when needed, including edit_file, delete_file, and build.
- Documentation writing tasks are also part of your execution scope when delegated by the main agent.
- Summaries should stay concise and execution-oriented.`;
	const sections: string[] = [
		shared.promptPack.agentIdentityPrompt,
		rolePrompt,
		getReplyLanguageDirective(shared),
	];
	if (shared.decisionMode === "tool_calling") {
		sections.push(`### Function Calling

You may return multiple tool calls in one response when the calls are independent and all results are useful before the next reasoning step. Do not include finish in a multi-tool response.`);
	}
	const memoryBudget = math.max(1200, math.floor((shared.llmConfig.contextWindow ?? 64000) * 0.08));
	const memoryContext = shared.memory.compressor.getStorage().getRelevantMemoryContext(shared.userQuery, memoryBudget);
	if (memoryContext !== "") {
		sections.push(memoryContext);
	}
	if (includeToolDefinitions) {
		sections.push("### Available Tools\n\n" + getDecisionToolDefinitions(shared));
		if (shared.decisionMode === "xml") {
			sections.push(buildXmlDecisionInstruction(shared));
		}
	}
	// 添加 Skills 部分
	const skillsSection = buildSkillsSection(shared);
	if (skillsSection !== "") {
		sections.push(skillsSection);
	}
	return sections.join("\n\n");
}

function buildSkillsSection(shared: AgentShared): string {
	if (!shared.skills?.loader) {
		return "";
	}
	return shared.skills.loader.buildSkillsPromptSection();
}

function sanitizeMessagesForLLMInput(messages: Message[]): Message[] {
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

function getUnconsolidatedMessages(shared: AgentShared): Message[] {
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared));
}

function getFinalDecisionTurnPrompt(shared: AgentShared): string {
	return shared.useChineseResponse
		? "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。"
		: "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds.";
}

function appendPromptToLatestDecisionMessage(messages: Message[], prompt: string): Message[] {
	if (messages.length === 0 || prompt.trim() === "") return messages;
	const next = messages.map(message => ({ ...message }));
	for (let i = next.length - 1; i >= 0; i--) {
		const message = next[i];
		if (message.role !== "assistant" && message.role !== "user") continue;
		const content = typeof message.content === "string" ? message.content.trim() : "";
		message.content = content !== ""
			? `${content}\n\n${prompt}`
			: prompt;
		return next;
	}
	next.push({ role: "user", content: prompt });
	return next;
}

function buildDecisionMessages(shared: AgentShared, lastError?: string, attempt = 1, lastRaw?: string): Message[] {
	let messages: Message[] = [
		{ role: "system", content: buildAgentSystemPrompt(shared, shared.decisionMode === "xml") },
		...getUnconsolidatedMessages(shared),
	];
	if (shared.step + 1 >= shared.maxSteps) {
		messages = appendPromptToLatestDecisionMessage(messages, getFinalDecisionTurnPrompt(shared));
	}
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
			content: shared.promptPack.xmlDecisionSystemRepairPrompt,
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
		const tools = buildDecisionToolSchema(shared);
		const messages = buildDecisionMessages(shared, lastError, attempt, lastRaw);
		const stepId = shared.step + 1;
		const llmOptions = {
			...shared.llmOptions,
			tools,
		};
		saveStepLLMDebugInput(shared, stepId, "decision_tool_calling", messages, llmOptions);
		let lastStreamContent = "";
		let lastStreamReasoning = "";
		const res = await callLLMStreamAggregated(
			messages,
			llmOptions,
			shared.stopToken,
			shared.llmConfig,
			(response) => {
				const streamMessage = response.choices?.[0]?.message;
				const nextContent = typeof streamMessage?.content === "string"
					? sanitizeUTF8(streamMessage.content)
					: "";
				const nextReasoning = typeof streamMessage?.reasoning_content === "string"
					? sanitizeUTF8(streamMessage.reasoning_content)
					: "";
				if (nextContent === lastStreamContent && nextReasoning === lastStreamReasoning) {
					return;
				}
				lastStreamContent = nextContent;
				lastStreamReasoning = nextReasoning;
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning !== "" ? nextReasoning : undefined);
			}
		);
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
		const reasoningContent = message && typeof message.reasoning_content === "string"
			? message.reasoning_content
			: undefined;
		const messageContent = message && typeof message.content === "string"
			? message.content.trim()
			: undefined;
		Log("Info", `[CodingAgent] tool-calling response finish_reason=${choice && choice.finish_reason ? choice.finish_reason : "unknown"} tool_calls=${toolCalls ? toolCalls.length : 0} content_len=${messageContent ? messageContent.length : 0} reasoning_len=${reasoningContent ? reasoningContent.length : 0}`);
		if (!toolCalls || toolCalls.length === 0) {
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
		const decisions: DecisionSuccess[] = [];
		for (let i = 0; i < toolCalls.length; i++) {
			const toolCall = toolCalls[i];
			const fn = toolCall && toolCall.function;
			if (!fn || typeof fn.name !== "string" || fn.name === "") {
				Log("Error", `[CodingAgent] missing function name for tool call index=${i + 1}`);
				return {
					success: false,
					message: `missing function name for tool call ${i + 1}`,
					raw: messageContent,
				};
			}
			const functionName = fn.name;
			const argsText = typeof fn.arguments === "string" ? fn.arguments : "";
			const toolCallId = toolCall && typeof toolCall.id === "string"
				? toolCall.id
				: undefined;
			Log("Info", `[CodingAgent] tool-calling function=${functionName} index=${i + 1}/${toolCalls.length} args_len=${argsText.length}`);
			const decision = parseAndValidateToolCallDecision(
				shared,
				functionName,
				argsText,
				toolCallId,
				messageContent,
				reasoningContent
			);
			if (!decision.success) {
				Log("Error", `[CodingAgent] invalid tool call index=${i + 1}: ${decision.message}`);
				return decision;
			}
			decisions.push(decision);
		}
		if (decisions.length === 1) {
			Log("Info", `[CodingAgent] tool-calling selected tool=${decisions[0].tool}`);
			return decisions[0];
		}
		for (let i = 0; i < decisions.length; i++) {
			if (decisions[i].tool === "finish") {
				return {
					success: false,
					message: "finish cannot be mixed with other tool calls",
					raw: messageContent,
				};
			}
		}
		Log("Info", `[CodingAgent] tool-calling selected batch tools=${decisions.map(decision => decision.tool).join(",")}`);
		return {
			success: true,
			kind: "batch",
			decisions,
			content: messageContent,
			reasoningContent,
		};
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
				decision.reasoningContent = llmRes.reasoningContent;
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
				decision.reasoningContent = llmRes.reasoningContent;
				if (!isToolAllowedForRole(shared.role, decision.tool)) {
					lastError = `${decision.tool} is not allowed for role ${shared.role}`;
					return this.repairDecisionXml(shared, llmRes.text, lastError);
				}
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
			if (shared.stopToken.stopped) {
				shared.error = getCancelledReason(shared);
				shared.done = true;
				return "done";
			}
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
		if (isDecisionBatchSuccess(result)) {
			const startStep = shared.step;
			const actions: AgentActionRecord[] = [];
			for (let i = 0; i < result.decisions.length; i++) {
				const decision = result.decisions[i];
				const toolCallId = ensureToolCallId(decision.toolCallId);
				const step = startStep + i + 1;
				const actionReason = i === 0 ? decision.reason : "";
				const actionReasoningContent = i === 0 ? decision.reasoningContent : undefined;
				emitAgentEvent(shared, {
					type: "decision_made",
					sessionId: shared.sessionId,
					taskId: shared.taskId,
					step,
					tool: decision.tool,
					reason: actionReason,
					reasoningContent: actionReasoningContent,
					params: decision.params,
				});
				const action: AgentActionRecord = {
					step,
					toolCallId,
					tool: decision.tool,
					reason: actionReason ?? "",
					reasoningContent: actionReasoningContent,
					params: decision.params,
					timestamp: os.date("!%Y-%m-%dT%H:%M:%SZ"),
				};
				shared.history.push(action);
				actions.push(action);
			}
			shared.step = startStep + actions.length;
			shared.pendingToolActions = actions;
			appendAssistantToolCallsMessage(
				shared,
				actions,
				result.content ?? "",
				result.reasoningContent
			);
			persistHistoryState(shared);
			return "batch_tools";
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
		const toolCallId = ensureToolCallId(result.toolCallId);
		shared.step += 1;
		const step = shared.step;
		emitAgentEvent(shared, {
			type: "decision_made",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step,
			tool: result.tool,
			reason: result.reason,
			reasoningContent: result.reasoningContent,
			params: result.params,
		});
		shared.history.push({
			step,
			toolCallId,
			tool: result.tool,
			reason: result.reason ?? "",
			reasoningContent: result.reasoningContent,
			params: result.params,
			timestamp: os.date("!%Y-%m-%dT%H:%M:%SZ"),
		});
		const action = shared.history[shared.history.length - 1];
		appendAssistantToolCallsMessage(shared, [action], result.reason ?? "", result.reasoningContent);
		persistHistoryState(shared);
		return result.tool;
	}
}

class ReadFileAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ path: string; startLine: number; endLine: number; tool: "read_file"; workDir: string; docLanguage: Tools.DoraAPIDocLanguage }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentStartEvent(shared, last);
		const path = typeof last.params.path === "string"
			? last.params.path
			: (typeof last.params.target_file === "string" ? last.params.target_file : "");
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
			emitAgentFinishEvent(shared, last);
		}
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

class SearchFilesAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentStartEvent(shared, last);
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
			emitAgentFinishEvent(shared, last);
		}
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

class SearchDoraAPIAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; useChineseResponse: boolean }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentStartEvent(shared, last);
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
			emitAgentFinishEvent(shared, last);
		}
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

class ListFilesAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentStartEvent(shared, last);
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
			emitAgentFinishEvent(shared, last);
		}
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

class DeleteFileAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ targetFile: string; taskId: number; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentStartEvent(shared, last);
		const targetFile = typeof last.params.target_file === "string"
			? last.params.target_file
			: (typeof last.params.path === "string" ? last.params.path : "");
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

	async post(shared: AgentShared, _prepRes: unknown, execRes: Record<string, unknown>): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.result = execRes;
			appendToolResultMessage(shared, last);
			emitAgentFinishEvent(shared, last);
			const result = last.result;
			if (last.tool === "delete_file"
				&& typeof result.checkpointId === "number"
				&& typeof result.checkpointSeq === "number"
				&& isArray(result.files)) {
				emitAgentEvent(shared, {
					type: "checkpoint_created",
					sessionId: shared.sessionId,
					taskId: shared.taskId,
					step: last.step,
					tool: "delete_file",
					checkpointId: result.checkpointId,
					checkpointSeq: result.checkpointSeq,
					files: result.files,
				});
			}
		}
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

class BuildAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ params: Record<string, unknown>; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentStartEvent(shared, last);
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
			emitAgentFinishEvent(shared, last);
		}
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

class SpawnSubAgentAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{
		title: string;
		prompt: string;
		expectedOutput?: string;
		filesHint?: string[];
		sessionId?: number;
		projectRoot: string;
		spawnSubAgent?: CodingAgentRunOptions["spawnSubAgent"];
	}> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentStartEvent(shared, last);
		const filesHint = isArray(last.params.filesHint)
			? (last.params.filesHint as unknown[]).filter(item => typeof item === "string") as string[]
			: undefined;
		return {
			title: typeof last.params.title === "string" ? last.params.title : "Sub",
			prompt: typeof last.params.prompt === "string" ? last.params.prompt : "",
			expectedOutput: typeof last.params.expectedOutput === "string" ? last.params.expectedOutput : undefined,
			filesHint,
			sessionId: shared.sessionId,
			projectRoot: shared.workingDir,
			spawnSubAgent: shared.spawnSubAgent,
		};
	}

	async exec(input: {
		title: string;
		prompt: string;
		expectedOutput?: string;
		filesHint?: string[];
		sessionId?: number;
		projectRoot: string;
		spawnSubAgent?: CodingAgentRunOptions["spawnSubAgent"];
	}): Promise<Record<string, unknown>> {
		if (!input.spawnSubAgent) {
			return { success: false, message: "spawn_sub_agent is not available in this runtime" };
		}
		if (input.sessionId === undefined || input.sessionId <= 0) {
			return { success: false, message: "spawn_sub_agent requires a parent session" };
		}
		Log("Info", `[CodingAgent] spawn_sub_agent exec title_len=${input.title.length} prompt_len=${input.prompt.length} expected_len=${typeof input.expectedOutput === "string" ? input.expectedOutput.length : 0} files_hint_count=${input.filesHint?.length ?? 0}`);
		const result = await input.spawnSubAgent({
			parentSessionId: input.sessionId,
			projectRoot: input.projectRoot,
			title: input.title,
			prompt: input.prompt,
			expectedOutput: input.expectedOutput,
			filesHint: input.filesHint,
		});
		if (!result.success) {
			return result as unknown as Record<string, unknown>;
		}
		return {
			success: true,
			sessionId: result.sessionId,
			taskId: result.taskId,
			title: result.title,
			hint: "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results.",
		};
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.result = execRes as Record<string, unknown>;
			appendToolResultMessage(shared, last);
			emitAgentFinishEvent(shared, last);
		}
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

class ListSubAgentsAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{
		sessionId?: number;
		projectRoot: string;
		status?: string;
		limit?: number;
		offset?: number;
		query?: string;
		listSubAgents?: CodingAgentRunOptions["listSubAgents"];
	}> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentStartEvent(shared, last);
		return {
			sessionId: shared.sessionId,
			projectRoot: shared.workingDir,
			status: typeof last.params.status === "string" ? last.params.status : undefined,
			limit: typeof last.params.limit === "number" ? last.params.limit : undefined,
			offset: typeof last.params.offset === "number" ? last.params.offset : undefined,
			query: typeof last.params.query === "string" ? last.params.query : undefined,
			listSubAgents: shared.listSubAgents,
		};
	}

	async exec(input: {
		sessionId?: number;
		projectRoot: string;
		status?: string;
		limit?: number;
		offset?: number;
		query?: string;
		listSubAgents?: CodingAgentRunOptions["listSubAgents"];
	}): Promise<Record<string, unknown>> {
		if (!input.listSubAgents) {
			return { success: false, message: "list_sub_agents is not available in this runtime" };
		}
		if (input.sessionId === undefined || input.sessionId <= 0) {
			return { success: false, message: "list_sub_agents requires a current session" };
		}
		const result = await input.listSubAgents({
			sessionId: input.sessionId,
			projectRoot: input.projectRoot,
			status: input.status,
			limit: input.limit,
			offset: input.offset,
			query: input.query,
		});
		return result as unknown as Record<string, unknown>;
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.result = execRes as Record<string, unknown>;
			appendToolResultMessage(shared, last);
			emitAgentFinishEvent(shared, last);
		}
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

class EditFileAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ path: string; oldStr: string; newStr: string; taskId: number; workDir: string }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentStartEvent(shared, last);
		const path = typeof last.params.path === "string"
			? last.params.path
			: (typeof last.params.target_file === "string" ? last.params.target_file : "");
		const oldStr = typeof last.params.old_str === "string" ? last.params.old_str : "";
		const newStr = typeof last.params.new_str === "string" ? last.params.new_str : "";
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
			emitAgentFinishEvent(shared, last);
			const result = last.result;
			if ((last.tool === "edit_file" || last.tool === "delete_file")
				&& typeof result.checkpointId === "number"
				&& typeof result.checkpointSeq === "number"
				&& isArray(result.files)) {
				emitAgentEvent(shared, {
					type: "checkpoint_created",
					sessionId: shared.sessionId,
					taskId: shared.taskId,
					step: last.step,
					tool: last.tool,
					checkpointId: result.checkpointId,
					checkpointSeq: result.checkpointSeq,
					files: result.files,
				});
			}
		}
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

function emitCheckpointEventForAction(shared: AgentShared, action: AgentActionRecord): void {
	const result = action.result;
	if (!result) return;
	if ((action.tool === "edit_file" || action.tool === "delete_file")
		&& typeof result.checkpointId === "number"
		&& typeof result.checkpointSeq === "number"
		&& isArray(result.files)) {
		emitAgentEvent(shared, {
			type: "checkpoint_created",
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: action.step,
			tool: action.tool,
			checkpointId: result.checkpointId,
			checkpointSeq: result.checkpointSeq,
			files: result.files,
		});
	}
}

async function executeToolAction(shared: AgentShared, action: AgentActionRecord): Promise<Record<string, unknown>> {
	if (shared.stopToken.stopped) {
		return { success: false, message: getCancelledReason(shared) };
	}
	const params = action.params;
	if (action.tool === "read_file") {
		const path = typeof params.path === "string"
			? params.path
			: (typeof params.target_file === "string" ? params.target_file : "");
		if (path.trim() === "") return { success: false, message: "missing path" };
		return Tools.readFile(
			shared.workingDir,
			path,
			Number(params.startLine ?? 1),
			Number(params.endLine ?? READ_FILE_DEFAULT_LIMIT),
			shared.useChineseResponse ? "zh" : "en"
		) as unknown as Record<string, unknown>;
	}
	if (action.tool === "grep_files") {
		const result = await Tools.searchFiles({
			workDir: shared.workingDir,
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
	if (action.tool === "search_dora_api") {
		const result = await Tools.searchDoraAPI({
			pattern: (params.pattern as string) ?? "",
			docSource: ((params.docSource as string) ?? "api") as Tools.DoraAPIDocSource,
			docLanguage: (shared.useChineseResponse ? "zh" : "en") as Tools.DoraAPIDocLanguage,
			programmingLanguage: ((params.programmingLanguage as string) ?? "ts") as Tools.DoraAPIProgrammingLanguage,
			limit: math.min(SEARCH_DORA_API_LIMIT_MAX, math.max(1, Number(params.limit ?? 8))),
			useRegex: params.useRegex as boolean | undefined,
			caseSensitive: false,
			includeContent: true,
			contentWindow: SEARCH_PREVIEW_CONTEXT,
		});
		return result as unknown as Record<string, unknown>;
	}
	if (action.tool === "glob_files") {
		const result = Tools.listFiles({
			workDir: shared.workingDir,
			path: (params.path as string) ?? "",
			globs: params.globs as string[] | undefined,
			maxEntries: math.max(1, math.floor(Number(params.maxEntries ?? LIST_FILES_MAX_ENTRIES_DEFAULT))),
		});
		return result as unknown as Record<string, unknown>;
	}
	if (action.tool === "delete_file") {
		const targetFile = typeof params.target_file === "string"
			? params.target_file
			: (typeof params.path === "string" ? params.path : "");
		if (targetFile.trim() === "") return { success: false, message: "missing target_file" };
		const result = Tools.applyFileChanges(shared.taskId, shared.workingDir, [{ path: targetFile, op: "delete" }], {
			summary: `delete_file: ${targetFile}`,
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
			files: [{ path: targetFile, op: "delete" as const }],
		};
	}
	if (action.tool === "build") {
		const result = await Tools.build({
			workDir: shared.workingDir,
			path: (params.path as string) ?? ""
		});
		return result as unknown as Record<string, unknown>;
	}
	if (action.tool === "spawn_sub_agent") {
		if (!shared.spawnSubAgent) {
			return { success: false, message: "spawn_sub_agent is not available in this runtime" };
		}
		if (shared.sessionId === undefined || shared.sessionId <= 0) {
			return { success: false, message: "spawn_sub_agent requires a parent session" };
		}
		const filesHint = isArray(params.filesHint)
			? (params.filesHint as unknown[]).filter(item => typeof item === "string") as string[]
			: undefined;
		const result = await shared.spawnSubAgent({
			parentSessionId: shared.sessionId,
			projectRoot: shared.workingDir,
			title: typeof params.title === "string" ? params.title : "Sub",
			prompt: typeof params.prompt === "string" ? params.prompt : "",
			expectedOutput: typeof params.expectedOutput === "string" ? params.expectedOutput : undefined,
			filesHint,
		});
		if (!result.success) {
			return result as unknown as Record<string, unknown>;
		}
		return {
			success: true,
			sessionId: result.sessionId,
			taskId: result.taskId,
			title: result.title,
			hint: "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results.",
		};
	}
	if (action.tool === "list_sub_agents") {
		if (!shared.listSubAgents) {
			return { success: false, message: "list_sub_agents is not available in this runtime" };
		}
		if (shared.sessionId === undefined || shared.sessionId <= 0) {
			return { success: false, message: "list_sub_agents requires a current session" };
		}
		const result = await shared.listSubAgents({
			sessionId: shared.sessionId,
			projectRoot: shared.workingDir,
			status: typeof params.status === "string" ? params.status : undefined,
			limit: typeof params.limit === "number" ? params.limit : undefined,
			offset: typeof params.offset === "number" ? params.offset : undefined,
			query: typeof params.query === "string" ? params.query : undefined,
		});
		return result as unknown as Record<string, unknown>;
	}
	if (action.tool === "edit_file") {
		const path = typeof params.path === "string"
			? params.path
			: (typeof params.target_file === "string" ? params.target_file : "");
		const oldStr = typeof params.old_str === "string" ? params.old_str : "";
		const newStr = typeof params.new_str === "string" ? params.new_str : "";
		if (path.trim() === "") return { success: false, message: "missing path" };
		const actionNode = new EditFileAction(1, 0);
		return actionNode.exec({
			path,
			oldStr,
			newStr,
			taskId: shared.taskId,
			workDir: shared.workingDir,
		});
	}
	return { success: false, message: `${action.tool} cannot be executed as a batched tool` };
}

function sanitizeToolActionResultForHistory(action: AgentActionRecord, result: Record<string, unknown>): Record<string, unknown> {
	if (action.tool === "read_file") {
		return sanitizeReadResultForHistory(action.tool, result);
	}
	if (action.tool === "grep_files" || action.tool === "search_dora_api") {
		return sanitizeSearchResultForHistory(action.tool, result);
	}
	if (action.tool === "glob_files") {
		return sanitizeListFilesResultForHistory(result);
	}
	return result;
}

function canRunBatchActionInParallel(action: AgentActionRecord): boolean {
	return action.tool === "read_file"
		|| action.tool === "grep_files"
		|| action.tool === "search_dora_api"
		|| action.tool === "glob_files"
		|| action.tool === "list_sub_agents";
}

class BatchToolAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ shared: AgentShared; actions: AgentActionRecord[] }> {
		return { shared, actions: shared.pendingToolActions ?? [] };
	}

	async exec(input: { shared: AgentShared; actions: AgentActionRecord[] }): Promise<AgentActionRecord[]> {
		const shared = input.shared;
		const allParallelSafe = input.actions.length > 1 && input.actions.every(canRunBatchActionInParallel);
		if (!allParallelSafe) {
			for (let i = 0; i < input.actions.length; i++) {
				const action = input.actions[i];
				emitAgentStartEvent(shared, action);
				const result = await executeToolAction(shared, action);
				action.params = sanitizeActionParamsForHistory(action.tool, action.params);
				action.result = sanitizeToolActionResultForHistory(action, result);
				appendToolResultMessage(shared, action);
				emitAgentFinishEvent(shared, action);
				emitCheckpointEventForAction(shared, action);
				persistHistoryState(shared);
				if (shared.stopToken.stopped) {
					break;
				}
			}
			return input.actions;
		}

		Log("Info", `[CodingAgent] batch read-only tools executing in parallel count=${input.actions.length}`);
		for (let i = 0; i < input.actions.length; i++) {
			emitAgentStartEvent(shared, input.actions[i]);
		}
		await Promise.all(input.actions.map(async action => {
			if (shared.stopToken.stopped) {
				action.result = { success: false, message: getCancelledReason(shared) };
				return action;
			}
			const result = await executeToolAction(shared, action);
			action.params = sanitizeActionParamsForHistory(action.tool, action.params);
			action.result = sanitizeToolActionResultForHistory(action, result);
			return action;
		}));
		for (let i = 0; i < input.actions.length; i++) {
			const action = input.actions[i];
			if (!action.result) {
				action.result = { success: false, message: "tool did not produce a result" };
			}
			appendToolResultMessage(shared, action);
			emitAgentFinishEvent(shared, action);
			emitCheckpointEventForAction(shared, action);
		}
		persistHistoryState(shared);
		return input.actions;
	}

	async post(shared: AgentShared, _prepRes: unknown, _execRes: unknown): Promise<string | undefined> {
		shared.pendingToolActions = undefined;
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

class EndNode extends Node<AgentShared> {
	async post(_shared: AgentShared, _prepRes: unknown, _execRes: unknown): Promise<string | undefined> {
		return undefined;
	}
}

class CodingAgentFlow extends Flow<AgentShared> {
	constructor(role: AgentRole) {
		const main = new MainDecisionAgent(1, 0);
		const read = new ReadFileAction(1, 0);
		const search = new SearchFilesAction(1, 0);
		const searchDora = new SearchDoraAPIAction(1, 0);
		const list = new ListFilesAction(1, 0);
		const listSub = new ListSubAgentsAction(1, 0);
		const del = new DeleteFileAction(1, 0);
		const build = new BuildAction(1, 0);
		const spawn = new SpawnSubAgentAction(1, 0);
		const edit = new EditFileAction(1, 0);
		const batch = new BatchToolAction(1, 0);
		const done = new EndNode(1, 0);

		main.on("batch_tools", batch);
		main.on("grep_files", search);
		main.on("search_dora_api", searchDora);
		main.on("glob_files", list);
		if (role === "main") {
			main.on("read_file", read);
			main.on("delete_file", del);
			main.on("build", build);
			main.on("edit_file", edit);
			main.on("list_sub_agents", listSub);
			main.on("spawn_sub_agent", spawn);
		} else {
			main.on("read_file", read);
			main.on("delete_file", del);
			main.on("build", build);
			main.on("edit_file", edit);
		}
		main.on("done", done);

		search.on("main", main);
		searchDora.on("main", main);
		list.on("main", main);
		listSub.on("main", main);
		spawn.on("main", main);
		batch.on("main", main);
		read.on("main", main);
		del.on("main", main);
		build.on("main", main);
		edit.on("main", main);

		super(main);
	}
}

function emitAgentTaskFinishEvent(shared: AgentShared, success: boolean, message: string): CodingAgentRunResult {
	const result = {
		success,
		taskId: shared.taskId,
		message,
		steps: shared.step
	};
	emitAgentEvent(shared, {
		type: "task_finished",
		sessionId: shared.sessionId,
		taskId: shared.taskId,
		success: result.success,
		message: result.message,
		steps: result.steps,
	});
	return result;
}

async function runCodingAgentAsync(options: CodingAgentRunOptions): Promise<CodingAgentRunResult> {
	if (!options.workDir || !Content.isAbsolutePath(options.workDir) || !Content.exist(options.workDir) || !Content.isdir(options.workDir)) {
		return { success: false, message: "workDir must be an existing absolute directory path" };
	}
	const normalizedPrompt = truncateAgentUserPrompt(options.prompt);
	const llmConfigRes = options.llmConfig
		? { success: true as const, config: options.llmConfig }
		: getActiveLLMConfig();
	if (!llmConfigRes.success) {
		return { success: false, message: llmConfigRes.message };
	}
	const llmConfig = llmConfigRes.config;
	const taskRes = options.taskId !== undefined
		? { success: true as const, taskId: options.taskId }
		: Tools.createTask(normalizedPrompt);
	if (!taskRes.success) {
		return { success: false, message: taskRes.message };
	}
	// 创建 Memory 压缩器
	const compressor = new MemoryCompressor({
		compressionThreshold: 0.8,
		compressionTargetThreshold: 0.5,
		maxCompressionRounds: 3,
		projectDir: options.workDir,
		llmConfig,
		promptPack: options.promptPack,
		scope: options.memoryScope,
	});
	const persistedSession = compressor.getStorage().readSessionState();
	const promptPack = compressor.getPromptPack();

	const shared: AgentShared = {
		sessionId: options.sessionId,
		taskId: taskRes.taskId,
		role: options.role ?? "main",
		maxSteps: math.max(1, math.floor(options.maxSteps ?? AGENT_DEFAULT_MAX_STEPS)),
		llmMaxTry: math.max(1, math.floor(options.llmMaxTry ?? AGENT_DEFAULT_LLM_MAX_TRY)),
		step: 0,
		done: false,
		stopToken: options.stopToken ?? { stopped: false },
		response: "",
		userQuery: normalizedPrompt,
		workingDir: options.workDir,
		useChineseResponse: options.useChineseResponse === true,
		decisionMode: options.decisionMode
			? options.decisionMode
			: (llmConfig.supportsFunctionCalling ? "tool_calling" : "xml"),
		llmOptions: buildLLMOptions(llmConfig, options.llmOptions),
		llmConfig,
		onEvent: options.onEvent,
		promptPack,
		history: [],
		messages: persistedSession.messages,
		lastConsolidatedIndex: persistedSession.lastConsolidatedIndex,
		carryMessageIndex: persistedSession.carryMessageIndex,
		// Memory 状态
		memory: {
			compressor,
		},
		// Skills 系统
		skills: {
			loader: createSkillsLoader({
				projectDir: options.workDir,
			}),
		},
		spawnSubAgent: options.spawnSubAgent,
		listSubAgents: options.listSubAgents,
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
			return emitAgentTaskFinishEvent(shared, false, getCancelledReason(shared));
		}
		Tools.setTaskStatus(shared.taskId, "RUNNING");
		const promptCommand = getPromptCommand(shared.userQuery);
		if (promptCommand === "clear") {
			return clearSessionHistory(shared);
		}
		if (promptCommand === "compact") {
			if (shared.role === "sub") {
				Tools.setTaskStatus(shared.taskId, "FAILED");
				return emitAgentTaskFinishEvent(
					shared,
					false,
					shared.useChineseResponse
						? "子代理会话不支持 /compact。"
						: "Sub-agent sessions do not support /compact."
				);
			}
			return await compactAllHistory(shared);
		}
		appendConversationMessage(shared, {
			role: "user",
			content: normalizedPrompt,
		});
		persistHistoryState(shared);
		const flow = new CodingAgentFlow(shared.role);
		await flow.run(shared);
		if (shared.stopToken.stopped) {
			Tools.setTaskStatus(shared.taskId, "STOPPED");
			return emitAgentTaskFinishEvent(shared, false, getCancelledReason(shared));
		}
		if (shared.error) {
			return finalizeAgentFailure(shared,
				shared.response && shared.response !== "" ? shared.response : shared.error);
		}
		Tools.setTaskStatus(shared.taskId, "DONE");
		return emitAgentTaskFinishEvent(shared, true,
			shared.response || (shared.useChineseResponse ? "任务完成。" : "Task completed."));
	} catch (e) {
		return finalizeAgentFailure(shared, tostring(e));
	}
}

export function runCodingAgent(options: CodingAgentRunOptions, callback: (result: CodingAgentRunResult) => void) {
	runCodingAgentAsync(options).then(result => callback(result));
}
