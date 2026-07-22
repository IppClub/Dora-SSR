// @preview-file off clear
import { App, Path, Content } from 'Dora';
import { Flow, Node } from 'Agent/flow';
import * as AgentUtils from 'Agent/Utils';
import type { LLMConfig, LLMTokenUsage, Message, StopToken, ToolCall } from 'Agent/Utils';
import * as Tools from 'Agent/Tools';
import { MemoryCompressor } from 'Agent/Memory';
import type { AgentPromptPack, AgentConversationMessage } from 'Agent/Memory';
import * as AgentToolRegistry from 'Agent/AgentToolRegistry';
import type { AgentDecisionMode, AgentRole, AgentToolName, AgentWorkMode } from 'Agent/AgentToolRegistry';
import * as AgentSkills from 'Agent/AgentSkills';
import * as AgentConfig from 'Agent/AgentConfig';
import * as AgentRuntimePolicy from 'Agent/AgentRuntimePolicy';
import type {
	AgentCompletionOutcome,
	AgentValidationKind,
	AgentValidationResult,
	AgentValidationReportItem,
	AgentLearningCandidateItem,
	AgentCompletionReport,
} from 'Agent/Utils';
import { normalizeQuestionnaire } from 'Agent/AgentQuestionnaire';
import type { AgentQuestionnaireSchema } from 'Agent/AgentQuestionnaire';

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object";
}

function isArray(value: unknown): value is unknown[] {
	return Array.isArray(value);
}


export type CodingAgentRunResult =
	| {
		success: true;
		taskId: number;
		message: string;
		steps: number;
		completion: AgentCompletionReport;
		waitingForUser?: false;
	}
	| {
		success: true;
		taskId: number;
		message: string;
		steps: number;
		waitingForUser: true;
		questionnaireId: number;
		completion?: undefined;
	}
	| {
		success: false;
		taskId?: number;
		message: string;
		steps?: number;
		completion?: AgentCompletionReport;
	};

export type {
	AgentCompletionOutcome,
	AgentValidationKind,
	AgentValidationResult,
	AgentValidationReportItem,
	AgentLearningCandidateItem,
	AgentCompletionReport,
} from 'Agent/Utils';

export interface CodingAgentRunOptions {
	prompt: string;
	resumeConversation?: boolean;
	workDir: string;
	useChineseResponse?: boolean;
	taskId?: number;
	maxSteps?: number;
	decisionMode?: "tool_calling" | "xml";
	workMode?: AgentWorkMode;
	llmMaxTry?: number;
	llmOptions?: Record<string, unknown>;
	llmConfig?: LLMConfig;
	promptPack?: Partial<AgentPromptPack>;
	stopToken?: StopToken;
	sessionId?: number;
	memoryScope?: string;
	role?: "main" | "sub";
	disabledAgentTools?: AgentToolName[];
	spawnSubAgent?: (this: void, request: {
		parentSessionId: number;
		projectRoot?: string;
		title: string;
		prompt: string;
		expectedOutput?: string;
		filesHint?: string[];
		disabledAgentTools?: AgentToolName[];
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
	publishQuestionnaire?: (this: void, request: {
		sessionId: number;
		taskId: number;
		step: number;
		schema: AgentQuestionnaireSchema;
	}) => Promise<
		| { success: true; questionnaireId: number }
		| { success: false; message: string }
	>;
	onEvent?: (event: CodingAgentEvent) => void;
}

type AgentPromptCommand = "compact" | "clear";
export type { AgentDecisionMode, AgentRole, AgentToolName, AgentWorkMode };

export type AgentStepToolName = AgentToolName | "compress_memory";

export interface AgentContextMetric {
	usedTokens: number;
	maxTokens: number;
	ratio: number;
	messagesTokens: number;
	optionsTokens: number;
	toolDefinitionsTokens?: number;
	reservedOutputTokens: number;
	structuralOverhead: number;
	contextWindow: number;
	source: string;
	updatedAt: number;
	phase?: string;
	step?: number;
}

export interface AgentMetrics {
	context?: AgentContextMetric;
	usage?: AgentTokenUsageMetric;
}

export interface AgentTokenUsageMetric {
	inputTokens: number;
	outputTokens: number;
	totalTokens?: number;
	cachedInputTokens?: number;
	cacheMissInputTokens?: number;
	reasoningOutputTokens?: number;
	requestCount: number;
	cacheReportedRequestCount?: number;
	model: string;
	phase: string;
	step: number;
	updatedAt: number;
}

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
		type: "tool_progress";
		sessionId?: number;
		taskId: number;
		step: number;
		tool: AgentToolName;
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
		type: "metrics_updated";
		sessionId?: number;
		taskId: number;
		step?: number;
		metrics: AgentMetrics;
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
		type: "task_waiting_for_user";
		sessionId?: number;
		taskId: number;
		step: number;
		questionnaireId: number;
	}
	| {
		type: "task_finished";
		sessionId?: number;
		taskId?: number;
		success: boolean;
		message: string;
		steps?: number;
		completion?: AgentCompletionReport;
	};

function buildLLMOptions(llmConfig: LLMConfig, overrides?: Record<string, unknown>): Record<string, unknown> {
	const options: Record<string, unknown> = {
		temperature: llmConfig.temperature ?? AgentConfig.AGENT_DEFAULTS.llmTemperature,
		max_tokens: llmConfig.maxTokens ?? AgentConfig.AGENT_DEFAULTS.llmMaxTokens,
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
	// Some OpenAI-compatible providers support tools but reject an explicit
	// tool_choice. Agent decisions already validate tool calls and can repair or
	// fall back to XML, so never inherit a provider-specific forced choice here.
	delete merged.tool_choice;
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

interface PreExecutedToolResult {
	action: AgentActionRecord;
	matches(action: AgentActionRecord): boolean;
	promise: Promise<Record<string, unknown>>;
}

interface AgentFileContextItem {
	path: string;
	op: Tools.FileOp;
	checkpointId: number;
	checkpointSeq: number;
	beforeExists: boolean;
	afterExists: boolean;
	beforeBytes: number;
	afterBytes: number;
	diffPreview: string;
	beforeContentPreview?: string;
	afterContent?: string;
	afterContentPreview?: string;
	lineCount?: number;
	contentTruncated: boolean;
	fileListTruncated: boolean;
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
	completion?: AgentCompletionReport;
	userQuery: string;
	workingDir: string;
	useChineseResponse: boolean;
	decisionMode: AgentDecisionMode;
	workMode: AgentWorkMode;
	llmOptions: Record<string, unknown>;
	llmConfig: LLMConfig;
	llmMaxTry: number;
	onEvent?: (event: CodingAgentEvent) => void;
	promptPack: AgentPromptPack;
	history: AgentActionRecord[];
	pendingToolActions?: AgentActionRecord[];
	preExecutedResults?: Map<string, PreExecutedToolResult>;
	messages: AgentConversationMessage[];
	lastConsolidatedIndex: number;
	carryMessageIndex?: number;
	/** Compression produced a checkpoint that should guide the next decision. */
	resumeCheckpointPending?: boolean;
	/** Recommended next tool extracted from the compressed Active Checkpoint. */
	resumeRequiredTool?: AgentToolName;
	/** After compression, prevent broad rereads until the agent resumes real work. */
	resumeNarrowReadMode?: boolean;
	/** Successful source edits have not yet been checked by the project build. */
	unbuiltEdits?: boolean;
	/** Successful edit/delete actions since the most recent build attempt. */
	editsSinceBuild?: number;
	/** Distinct authored source paths edited since the most recent build attempt. */
	editedPathsSinceBuild?: string[];
	/** Whether this task has attempted at least one project build. */
	hasBuilt?: boolean;
	/** Whether the latest build passed and no authored edits have happened since it. */
	lastBuildSucceeded?: boolean;
	/** Track API lookups so later tool results can recommend an early build. */
	apiSearchesSinceBuild?: number;
	/** A deterministic test reported `failed`; later results should recommend fixing and building. */
	failedTestNeedsBuild?: boolean;
	/** An authored source/test file changed after the latest deterministic test failure. */
	failedTestHasSourceEdit?: boolean;
	/** A build returned concrete authored-file diagnostics that should guide the next repair. */
	buildRepairPending?: boolean;
	/** Consecutive deterministic test reports whose first-line result was failed. */
	deterministicTestFailureCount?: number;
	/** A project with zero buildable code files, or one buildable code file of at most 3 lines, should prefer an early implementation and build. */
	freshProjectBuildPending?: boolean;
	/** The only short code file found when freshProjectBuildPending was detected. */
	freshProjectCodeFile?: string;
	/** Target that received a valid decoded prefix from a truncated whole-file overwrite. */
	truncatedToolOverwritePath?: string;
	/** A successful spawn in this task makes list_sub_agents a discouraged polling path. */
	hasSpawnedSubAgentThisTask?: boolean;
	/** Number of foreground tool batches completed after the first successful spawn. */
	delegatedForegroundBatches?: number;
	/** Provider-reported token usage accumulated for this task. */
	tokenUsage?: AgentTokenUsageMetric;
	// Memory 相关字段
	memory: {
		/** Memory 压缩器实例 */
		compressor: MemoryCompressor;
	};
	// Skills 相关字段
	skills: {
		/** Skills 加载器实例 */
		loader: AgentSkills.SkillsLoader;
	};
	spawnSubAgent?: CodingAgentRunOptions["spawnSubAgent"];
	listSubAgents?: CodingAgentRunOptions["listSubAgents"];
	publishQuestionnaire?: CodingAgentRunOptions["publishQuestionnaire"];
	waitingQuestionnaireId?: number;
	disabledAgentTools: AgentToolName[];
}

function emitAgentEvent(shared: AgentShared, event: CodingAgentEvent) {
	if (shared.onEvent) {
		try {
			shared.onEvent(event);
		} catch (error) {
			AgentUtils.Log("Error", `[CodingAgent] onEvent handler failed: ${tostring(error)}`);
		}
	}
}

function emitLLMContextMetrics(
	shared: AgentShared,
	step: number,
	phase: string,
	messages: Message[],
	options: Record<string, unknown>
) {
	const fitted = AgentUtils.fitMessagesToContext(messages, options, shared.llmConfig);
	const messagesTokens = fitted.originalTokens;
	// Calculate tool definitions separately - they are fixed overhead, not conversation usage
	let toolDefinitionsTokens = 0;
	if (options.tools && Array.isArray(options.tools)) {
		const [toolsText] = AgentUtils.safeJsonEncode(options.tools as object);
		toolDefinitionsTokens = toolsText ? AgentUtils.estimateTextTokens(toolsText) : 0;
	}
	// Exclude tools from optionsTokens since we track them separately
	const optionsWithoutTools = { ...options };
	delete optionsWithoutTools.tools;
	const [optionsText] = AgentUtils.safeJsonEncode(optionsWithoutTools as object);
	const optionsTokens = optionsText ? AgentUtils.estimateTextTokens(optionsText) : 0;
	const contextWindow = shared.llmConfig.contextWindow > 0
		? math.floor(shared.llmConfig.contextWindow)
		: 64000;
	const explicitMax = typeof options.max_tokens === "number"
		? math.floor(options.max_tokens)
		: (typeof options.max_completion_tokens === "number"
			? math.floor(options.max_completion_tokens)
			: 0);
	const reservedOutputTokens = explicitMax > 0
		? math.max(256, explicitMax)
		: math.max(1024, math.floor(contextWindow * 0.2));
	const structuralOverhead = math.max(256, messages.length * 16);
	// Match the request fitter exactly: options, output reservation, and structural
	// overhead reduce the input budget instead of inflating the displayed usage.
	const usedTokens = messagesTokens;
	const maxTokens = fitted.budgetTokens;
	emitAgentEvent(shared, {
		type: "metrics_updated",
		sessionId: shared.sessionId,
		taskId: shared.taskId,
		step,
		metrics: {
			context: {
				usedTokens,
				maxTokens,
				ratio: math.max(0, math.min(1, usedTokens / maxTokens)),
				messagesTokens,
				optionsTokens,
				toolDefinitionsTokens,
				reservedOutputTokens,
				structuralOverhead,
				contextWindow,
				source: "llm_input_estimate",
				updatedAt: os.time(),
				phase,
				step,
			},
		},
	});
}

function recordLLMTokenUsage(shared: AgentShared, step: number, phase: string, usage?: LLMTokenUsage): void {
	if (!usage) return;
	const current = shared.tokenUsage;
	const cachedReported = usage.cachedInputTokens !== undefined;
	const cacheMissReported = usage.cacheMissInputTokens !== undefined;
	const reasoningReported = usage.reasoningOutputTokens !== undefined;
	const next: AgentTokenUsageMetric = {
		inputTokens: (current?.inputTokens ?? 0) + usage.inputTokens,
		outputTokens: (current?.outputTokens ?? 0) + usage.outputTokens,
		totalTokens: (current?.totalTokens ?? 0) + (usage.totalTokens ?? (usage.inputTokens + usage.outputTokens)),
		cachedInputTokens: cachedReported || current?.cachedInputTokens !== undefined
			? (current?.cachedInputTokens ?? 0) + (usage.cachedInputTokens ?? 0)
			: undefined,
		cacheMissInputTokens: cacheMissReported || current?.cacheMissInputTokens !== undefined
			? (current?.cacheMissInputTokens ?? 0) + (usage.cacheMissInputTokens ?? 0)
			: undefined,
		reasoningOutputTokens: reasoningReported || current?.reasoningOutputTokens !== undefined
			? (current?.reasoningOutputTokens ?? 0) + (usage.reasoningOutputTokens ?? 0)
			: undefined,
		requestCount: (current?.requestCount ?? 0) + 1,
		cacheReportedRequestCount: cachedReported || current?.cacheReportedRequestCount !== undefined
			? (current?.cacheReportedRequestCount ?? 0) + (cachedReported ? 1 : 0)
			: undefined,
		model: shared.llmConfig.model,
		phase,
		step,
		updatedAt: os.time(),
	};
	shared.tokenUsage = next;
	emitAgentEvent(shared, {
		type: "metrics_updated",
		sessionId: shared.sessionId,
		taskId: shared.taskId,
		step,
		metrics: { usage: next },
	});
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
	if (prompt.length <= AgentConfig.AGENT_LIMITS.userPromptMaxChars) return prompt;
	const offset = utf8.offset(prompt, AgentConfig.AGENT_LIMITS.userPromptMaxChars + 1);
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
	if (parent !== "" && parent !== dir && !Content.exist(parent) && !ensureDirRecursive(parent)) {
		return false;
	}
	return Content.mkdir(dir);
}

function encodeDebugJSON(value: unknown): string {
	const [text, err] = AgentUtils.safeJsonEncode(value as object);
	return text ?? `{ "error": "json_encode_failed", "message": "${tostring(err)}" }`;
}

export function normalizePolicyPath(path: string): string {
	return AgentRuntimePolicy.normalizeAgentPath(path);
}

/**
 * Main-session memory is an Agent-authored workspace area. Keep this check
 * rooted so similarly named nested project directories do not accidentally
 * bypass authored-source validation and build cadence.
 */
export function isMainAgentMemoryPath(path: string): boolean {
	return AgentRuntimePolicy.isMainAgentMemoryPath(path);
}

export function isAgentPlanPath(path: string): boolean {
	return AgentRuntimePolicy.isAgentPlanPath(path);
}

function inspectFreshProject(workDir: string): { fresh: boolean; codeFile?: string } {
	const result = Tools.listFiles({
		workDir,
		path: "",
		globs: AgentConfig.AGENT_FILE_PATTERNS.freshProjectCodeGlobs,
		maxEntries: 2,
	});
	if (!result.success) return { fresh: false };
	const totalEntries = result.totalEntries ?? result.files.length;
	if (totalEntries > 1) return { fresh: false };
	if (totalEntries === 0) return { fresh: true };
	if (result.files.length !== 1) return { fresh: false };
	const path = result.files[0];
	const loaded = Tools.readFileRaw(workDir, path);
	if (!loaded.success || loaded.content === undefined) return { fresh: false };
	const content = loaded.content.endsWith("\n")
		? loaded.content.slice(0, -1)
		: loaded.content;
	const lineCount = content === "" ? 0 : content.split("\n").length;
	return lineCount <= 3 ? { fresh: true, codeFile: path } : { fresh: false };
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
		AgentUtils.Log("Warn", `[CodingAgent] failed to save LLM debug file: ${path}`);
		return false;
	}
	return true;
}

function createStepLLMDebugPair(shared: AgentShared, stepId: number, inContent: string): number {
	if (!canWriteStepLLMDebug(shared, stepId)) return 0;
	const dir = getStepLLMDebugDir(shared);
	if (!ensureDirRecursive(dir)) {
		AgentUtils.Log("Warn", `[CodingAgent] failed to create LLM debug dir: ${dir}`);
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
		AgentUtils.Log("Warn", `[CodingAgent] failed to create LLM debug dir: ${dir}`);
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
	const firstMessage = messages.length > 0 ? messages[0] : undefined;
	if (firstMessage && firstMessage.role === "system" && typeof firstMessage.content === "string") {
		sections.push("# System Prompt");
		sections.push(firstMessage.content);
	}
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

function toJson(value: unknown, emptyAsArray: boolean): string {
	const [text, err] = AgentUtils.safeJsonEncode(value as object, false, emptyAsArray);
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

function sanitizeReadResultForHistory(tool: AgentToolName, result: Record<string, unknown>): Record<string, unknown> {
	if (tool !== "read_file" || result.success !== true || typeof result.content !== "string") {
		return result;
	}
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

function sanitizeListFilesResultForHistory(result: Record<string, unknown>): Record<string, unknown> {
	if (result.success !== true || !isArray(result.files)) return result;
	const clone: Record<string, unknown> = {};
	for (const key in result) {
		clone[key] = result[key];
	}
	clone.files = result.files.slice(0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries);
	return clone;
}

function sanitizeBuildResultForHistory(result: Record<string, unknown>): Record<string, unknown> {
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

function projectBuildResultForLLM(result: Record<string, unknown>): Record<string, unknown> {
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

function projectMessagesForLLMContext(messages: Message[]): Message[] {
	// Session history remains the source of truth for persistence and UI events.
	// Tool-call arguments remain byte-for-byte unchanged so the normal Agent loop
	// sees the exact calls that were originally stored and preserves cache prefixes.
	const projected: Message[] = [];
	for (let i = 0; i < messages.length; i++) {
		const message = messages[i];
		const next: Message = { ...message };
		if (message.role === "tool" && typeof message.content === "string") {
			next.content = projectToolResultContentForLLM(message.name ?? "tool", message.content);
		}
		projected.push(next);
	}
	return projected;
}

function projectMessagesForCompression(messages: Message[]): Message[] {
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

export function getDecisionDisabledAgentTools(shared: AgentShared): AgentToolName[] {
	// Capability is stable for the whole task. Runtime workflow state may add
	// guidance to a tool result, but must not hide or reject a tool that the
	// model can see in this task's schema/prompt.
	return shared.disabledAgentTools.slice();
}

function getDecisionToolDefinitions(shared: AgentShared): string {
	const params = { SEARCH_DORA_API_LIMIT_MAX: tostring(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) };
	const usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed === AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED
		&& shared.promptPack.mainAgentToolDefinitionsDetailed === AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED
		&& shared.promptPack.xmlToolDefinitionsDetailed === AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED;
	const base = shared.promptPack.toolDefinitionsDetailed;
	const mainAgentTools = shared.role === "main" ?
		shared.promptPack.mainAgentToolDefinitionsDetailed : "";
	if (usesDefaultToolPrompts) {
		const definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {
			includeFinish: true,
			includeXmlRules: true,
			context: { searchDoraApiLimitMax: AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax },
			disabledAgentTools: getDecisionDisabledAgentTools(shared),
			workMode: shared.workMode,
		});
		return replacePromptVars(definitions, params);
	}
	const withRole = replacePromptVars(
		`${base}${mainAgentTools}`,
		params
	);
	if (shared?.decisionMode !== "xml") {
		return withRole;
	}
	const xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed;
	return replacePromptVars(
		`${withRole}${xmlToolDefinitionsDetailed}`,
		params
	);
}

function getDecisionToolSchemaText(shared: AgentShared): string {
	const [toolsText] = AgentUtils.safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema(shared.role, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, {
		disabledAgentTools: getDecisionDisabledAgentTools(shared),
		workMode: shared.workMode,
	}) as object);
	return toolsText ?? "";
}

function isToolAllowedForRole(shared: AgentShared, tool: AgentToolName): boolean {
	return AgentToolRegistry.getAllowedToolsForRole(shared.role, {
		disabledAgentTools: getDecisionDisabledAgentTools(shared),
		workMode: shared.workMode,
	}).indexOf(tool) >= 0;
}

function clearPreExecutedResults(shared: AgentShared): void {
	shared.preExecutedResults = undefined;
}

async function startPreExecutedToolAction(shared: AgentShared, action: AgentActionRecord): Promise<Record<string, unknown>> {
	try {
		return await executeToolAction(shared, action);
	} catch (err) {
		const message = tostring(err);
		AgentUtils.Log("Error", `[CodingAgent] streaming pre-exec failed tool=${action.tool} id=${action.toolCallId}: ${message}`);
		return { success: false, message };
	}
}

function createPreExecutedToolResult(shared: AgentShared, action: AgentActionRecord): PreExecutedToolResult {
	const cloneParamValue = (value: unknown): unknown => {
		if (value === undefined) return value;
		if (isArray(value)) {
			return value.map(item => cloneParamValue(item));
		}
		if (typeof value === "object") {
			const clone: Record<string, unknown> = {};
			for (const key in value as Record<string, unknown>) {
				clone[key] = cloneParamValue((value as Record<string, unknown>)[key]);
			}
			return clone;
		}
		return value;
	};
	const params = cloneParamValue(action.params) as Record<string, unknown>;
	const areParamValuesEqual = (left: unknown, right: unknown): boolean => {
		if (left === right) return true;
		if (left === undefined || right === undefined) return false;
		if (isArray(left) || isArray(right)) {
			if (!isArray(left) || !isArray(right) || left.length !== right.length) return false;
			for (let i = 0; i < left.length; i++) {
				if (!areParamValuesEqual(left[i], right[i])) return false;
			}
			return true;
		}
		if (typeof left === "object" && typeof right === "object") {
			let leftCount = 0;
			for (const key in left as Record<string, unknown>) {
				leftCount++;
				if (!areParamValuesEqual(
					(left as Record<string, unknown>)[key],
					(right as Record<string, unknown>)[key]
				)) {
					return false;
				}
			}
			let rightCount = 0;
			for (const key in right as Record<string, unknown>) {
				rightCount++;
			}
			return leftCount === rightCount;
		}
		return false;
	};
	return {
		action,
		matches(nextAction: AgentActionRecord): boolean {
			return action.tool === nextAction.tool && areParamValuesEqual(params, nextAction.params);
		},
		promise: startPreExecutedToolAction(shared, action),
	};
}

async function executeToolActionWithPreExecution(shared: AgentShared, action: AgentActionRecord): Promise<Record<string, unknown>> {
	const preResult = shared.preExecutedResults?.get(action.toolCallId);
	let result: Record<string, unknown>;
	if (preResult) {
		shared.preExecutedResults?.delete(action.toolCallId);
		if (preResult.matches(action)) {
			AgentUtils.Log("Info", `[CodingAgent] using streaming pre-exec result tool=${action.tool} id=${action.toolCallId}`);
			result = await preResult.promise;
		} else {
			AgentUtils.Log("Warn", `[CodingAgent] discard stale streaming pre-exec result tool=${action.tool} id=${action.toolCallId}`);
			result = await executeToolAction(shared, action);
		}
	} else {
		result = await executeToolAction(shared, action);
	}
	const guidance: string[] = [];
	if (
		(shared.delegatedForegroundBatches ?? 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit
		&& action.tool !== "spawn_sub_agent"
		&& action.tool !== "finish"
	) {
		guidance.push("Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting.");
	}
	if (shared.resumeRequiredTool !== undefined && action.tool !== shared.resumeRequiredTool) {
		guidance.push(`The compression checkpoint recommends ${shared.resumeRequiredTool} next. Avoid restarting broad discovery unless this result shows it is necessary.`);
	}
	if (shared.failedTestNeedsBuild === true && action.tool !== "build" && action.tool !== "edit_file") {
		guidance.push("A deterministic test previously failed. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation.");
	}
	if (action.tool === "search_dora_api") {
		if (shared.unbuiltEdits === true) {
			guidance.push("There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery.");
		}
		if ((shared.apiSearchesSinceBuild ?? 0) >= 2) {
			guidance.push("Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup.");
		}
	}
	if (
		(action.tool === "edit_file" || action.tool === "delete_file")
		&& !AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params))
		&& AgentRuntimePolicy.isEditBudgetExhausted(shared)
	) {
		guidance.push("Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set.");
	}
	if (action.tool === "edit_file" && shared.resumeNarrowReadMode === true) {
		const oldStr = typeof action.params.old_str === "string" ? action.params.old_str : "";
		if (oldStr === "") {
			guidance.push("After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file.");
		}
	}
	if (action.tool === "list_sub_agents" && shared.hasSpawnedSubAgentThisTask === true) {
		guidance.push("Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains.");
	}
	if (shared.freshProjectBuildPending === true && action.tool !== "build") {
		guidance.push(shared.unbuiltEdits === true
			? "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback."
			: "This is a fresh project. Prefer creating a compilable first implementation, then build early.");
	}
	if (shared.buildRepairPending === true && action.tool !== "build" && action.tool !== "edit_file") {
		guidance.push("The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again.");
	}
	if (shared.lastBuildSucceeded === true && shared.unbuiltEdits !== true) {
		guidance.push("The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes.");
	}
	if (guidance.length > 0) {
		result.guidance = guidance.join("\n");
	}
	return result;
}

async function maybeCompressHistory(
	shared: AgentShared,
	includePendingUserPrompt = false,
	pendingUserPrompt = ""
): Promise<void> {
	const { memory } = shared;
	const maxRounds = memory.compressor.getMaxCompressionRounds();
	let changed = false;
	for (let round = 0; round < maxRounds; round++) {
		const systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode === "xml");
		const normalizedActiveMessages = sanitizeMessagesForLLMInput(getActiveConversationMessages(shared));
		const decisionActiveMessages = projectMessagesForLLMContext(normalizedActiveMessages);
		const activeMessages = projectMessagesForCompression(normalizedActiveMessages);
		// Keep the projected uncovered count for diagnostics. The trigger itself is
		// based on the exact next decision request below, including any carried prompt.
		const uncoveredMessages = projectMessagesForCompression(
			AgentRuntimePolicy.getUncoveredConversationMessages(
				shared.messages,
				shared.lastConsolidatedIndex
			)
		);
		// In tool_calling mode, tool descriptions come from the tools API schema, not from
		// the XML-only detailed prompt. Pass the schema text only for token accounting.
		const toolDefinitions = shared.decisionMode === "tool_calling"
			? getDecisionToolSchemaText(shared)
			: "";
		const triggerMessages = buildDecisionMessages(
			shared,
			undefined,
			1,
			undefined,
			shared.decisionMode,
			false,
			includePendingUserPrompt ? pendingUserPrompt : ""
		);
		const triggerOptions = shared.decisionMode === "tool_calling"
			? {
				...shared.llmOptions,
				...(shared.llmConfig.model.toLowerCase().includes("glm-5.2")
					&& (typeof shared.llmOptions.reasoning_effort !== "string"
						|| shared.llmOptions.reasoning_effort.trim() === "")
					? { reasoning_effort: "minimal" }
					: {}),
				tools: AgentToolRegistry.buildDecisionToolSchema(shared.role, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, {
					disabledAgentTools: getDecisionDisabledAgentTools(shared),
					workMode: shared.workMode,
				}),
			}
			: shared.llmOptions;
		const fitted = AgentUtils.fitMessagesToContext(triggerMessages, triggerOptions, shared.llmConfig);
		// Trigger at 100% of the exact effective input budget used by the normal
		// request path. The compression payload below remains independently projected.
		const thresholdReached = getActiveRealMessageCount(shared) > 0
			&& fitted.originalTokens >= fitted.budgetTokens;
		if (!thresholdReached) {
			if (changed) {
				persistHistoryState(shared);
			}
			return;
		}
		const compressionRound = round + 1;
		AgentUtils.Log("Info", `[Memory] Effective input budget reached tokens=${fitted.originalTokens} budget=${fitted.budgetTokens} round=${compressionRound}`);
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
				coveredThroughIndex: shared.lastConsolidatedIndex,
				uncoveredMessages: uncoveredMessages.length,
				inputTokens: fitted.originalTokens,
				inputBudgetTokens: fitted.budgetTokens,
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
				onUsage: (phase, usage) => {
					recordLLMTokenUsage(shared, stepId, phase, usage);
				},
				},
			"default",
			systemPrompt,
			toolDefinitions,
			decisionActiveMessages
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
				coveredThroughIndex: math.min(shared.messages.length, shared.lastConsolidatedIndex + effectiveCompressedCount),
				historyEntryPreview: summarizeHistoryEntryPreview(result.summary ?? ""),
			},
		});
		applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate);
		changed = true;
		AgentUtils.Log("Info", `[Memory] Compressed ${effectiveCompressedCount} messages (round ${compressionRound})`);
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
		const activeMessages = projectMessagesForCompression(getActiveConversationMessages(shared));
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
				onUsage: (phase, usage) => {
					recordLLMTokenUsage(shared, stepId, phase, usage);
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
		applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate);
		totalCompressed += effectiveCompressedCount;
		persistHistoryState(shared);
		AgentUtils.Log("Info", `[Memory] Full compaction compressed ${effectiveCompressedCount} messages (round ${rounds})`);
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

function getCompletionReport(params: Record<string, unknown>): AgentCompletionReport {
	return AgentUtils.normalizeAgentCompletionReport(params);
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
	carryMessageIndex?: number,
	sessionSummary?: string
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
	// Always mark the first post-compression decision as a resume. A partial
	// compression can leave bookkeeping/tool messages in the active tail; treating
	// any tail as a new user override made the model ignore an accurate checkpoint
	// and start regenerating files that already existed. A genuine newer user message
	// is still present in the decision messages and can refine the checkpoint, but it
	// must not silently turn resume into restart.
	const hasUncompressedTail = shared.lastConsolidatedIndex < shared.messages.length;
	shared.resumeCheckpointPending = true;
	shared.resumeRequiredTool = undefined;
	shared.resumeNarrowReadMode = true;
	// Runtime state is more authoritative than an LLM-written checkpoint. If
	// authored edits are still unbuilt, every compression path must resume at
	// the build boundary. A compression can leave bookkeeping messages in the
	// active tail even when there is no newer user instruction; gating this on
	// `hasUncompressedTail` allowed a stale checkpoint to overwrite authored
	// source before the pending build.
	if (shared.unbuiltEdits === true) {
		shared.resumeRequiredTool = "build";
	}
	// A carry created before the current task has taken a decision is the newly
	// submitted user instruction. The compressor deliberately leaves that message
	// outside the old session summary, so an old `Next tool: finish` must not bind
	// it. Once this task has executed at least one step, a carry belongs to the
	// in-progress task that was just summarized and should obey its checkpoint.
	// Messages that arrive during compression remain an uncompressed tail and are
	// likewise newer than the checkpoint.
	const carryStartsNewTask = typeof shared.carryMessageIndex === "number"
		// The compression operation itself is recorded as step 1 before this
		// state is applied. With no earlier task action, that carried user
		// message is still the new instruction and must outrank the old summary.
		&& shared.step <= 1;
	if (
		!hasUncompressedTail
		&& !carryStartsNewTask
		&& shared.resumeRequiredTool === undefined
		&& typeof sessionSummary === "string"
	) {
		const marker = "**Next tool**:";
		const markerIndex = sessionSummary.indexOf(marker);
		if (markerIndex >= 0) {
			const nextToolLine = sessionSummary.slice(markerIndex, markerIndex + 120);
			const toolNames: AgentToolName[] = [
				"read_file", "edit_file", "delete_file", "grep_files", "search_dora_api",
				"glob_files", "build", "fetch_url", "execute_command", "list_sub_agents",
				"spawn_sub_agent", "finish",
			];
			for (let i = 0; i < toolNames.length; i++) {
				const tool = toolNames[i];
				if (nextToolLine.indexOf(`\`${tool}\``) >= 0) {
					shared.resumeRequiredTool = tool;
					break;
				}
			}
		}
	}
	if (shared.hasSpawnedSubAgentThisTask === true && shared.resumeRequiredTool === "list_sub_agents") {
		shared.resumeRequiredTool = undefined;
	}
	if (shared.resumeRequiredTool !== undefined && !isToolAllowedForRole(shared, shared.resumeRequiredTool)) {
		shared.resumeRequiredTool = undefined;
	}
}

function appendConversationMessage(shared: AgentShared, message: AgentConversationMessage): void {
	shared.messages.push({
		...message,
		content: message.content ? AgentUtils.sanitizeUTF8(message.content) : message.content,
		name: message.name ? AgentUtils.sanitizeUTF8(message.name) : message.name,
		tool_call_id: message.tool_call_id ? AgentUtils.sanitizeUTF8(message.tool_call_id) : message.tool_call_id,
		reasoning_content: message.reasoning_content ? AgentUtils.sanitizeUTF8(message.reasoning_content) : message.reasoning_content,
		timestamp: message.timestamp ?? os.date("!%Y-%m-%dT%H:%M:%SZ"),
	});
}

function ensureToolCallId(toolCallId?: string): string {
	if (toolCallId && toolCallId !== "") return toolCallId;
	return AgentUtils.createLocalToolCallId();
}

function appendToolResultMessage(shared: AgentShared, action: AgentActionRecord): void {
	appendConversationMessage(shared, {
		role: "tool",
		tool_call_id: action.toolCallId,
		name: action.tool,
		content: action.result ? toJson(action.result, false) : "",
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
				arguments: toJson(action.params, false),
			},
		})),
	});
}

function hasXMLParam(params: Record<string, unknown>, name: string): boolean {
	return params[name] !== undefined;
}

function inferToolNameFromXMLParams(params: Record<string, unknown>): AgentToolName | undefined {
	if (hasXMLParam(params, "old_str") || hasXMLParam(params, "new_str")) {
		return "edit_file";
	}
	if (hasXMLParam(params, "target_file")) {
		return "delete_file";
	}
	if (hasXMLParam(params, "startLine") || hasXMLParam(params, "endLine")) {
		if (hasXMLParam(params, "path")) return "read_file";
		return undefined;
	}
	if (hasXMLParam(params, "docSource") || hasXMLParam(params, "programmingLanguage")) {
		if (hasXMLParam(params, "pattern")) return "search_dora_api";
		return undefined;
	}
	if (hasXMLParam(params, "groupByFile") || hasXMLParam(params, "caseSensitive")) {
		if (hasXMLParam(params, "pattern")) return "grep_files";
		return undefined;
	}
	if (hasXMLParam(params, "globs")) {
		if (hasXMLParam(params, "pattern")) return "grep_files";
		return "glob_files";
	}
	if (hasXMLParam(params, "maxEntries")) {
		return "glob_files";
	}
	if (hasXMLParam(params, "message") || hasXMLParam(params, "response") || hasXMLParam(params, "summary")) {
		return "finish";
	}
	if (hasXMLParam(params, "title") || hasXMLParam(params, "prompt") || hasXMLParam(params, "expectedOutput") || hasXMLParam(params, "filesHint")) {
		return "spawn_sub_agent";
	}
	if (hasXMLParam(params, "status") || hasXMLParam(params, "query")) {
		return "list_sub_agents";
	}
	return undefined;
}

function parseDSMLAttribute(source: string, offset: number, name: string): { success: true; value: string; next: number } | { success: false; message: string } {
	const attrOpen = `${name}="`;
	const attrStart = source.indexOf(attrOpen, offset);
	if (attrStart < 0) return { success: false, message: `missing ${name} attribute` };
	const valueStart = attrStart + attrOpen.length;
	const valueEnd = source.indexOf('"', valueStart);
	if (valueEnd < 0) return { success: false, message: `unterminated ${name} attribute` };
	return {
		success: true,
		value: source.slice(valueStart, valueEnd),
		next: valueEnd + 1,
	};
}

function extractDSMLReason(text: string, invokeStart: number, tool: AgentToolName): string {
	const toolCallsStart = text.indexOf("<｜｜DSML｜｜tool_calls>");
	const before = toolCallsStart >= 0 && toolCallsStart < invokeStart
		? text.slice(0, toolCallsStart).trim()
		: text.slice(0, invokeStart).trim();
	if (before !== "" && before.indexOf("<｜｜DSML") < 0) return before;
	if (tool === "finish") return "";
	return "Converted provider-native tool call syntax to XML.";
}

function parseDSMLToolCallObjectFromText(text: string): { success: true; obj: Record<string, unknown> } | { success: false; message: string } {
	const invokeOpen = '<｜｜DSML｜｜invoke name="';
	const invokeStart = text.indexOf(invokeOpen);
	if (invokeStart < 0) return { success: false, message: "missing DSML invoke" };
	const nameStart = invokeStart + invokeOpen.length;
	const nameEnd = text.indexOf('"', nameStart);
	if (nameEnd < 0) return { success: false, message: "unterminated DSML invoke name" };
	const toolName = text.slice(nameStart, nameEnd);
	if (!AgentToolRegistry.isKnownToolName(toolName)) {
		return { success: false, message: `unknown DSML tool: ${toolName}` };
	}
	const invokeOpenEnd = text.indexOf(">", nameEnd);
	if (invokeOpenEnd < 0) return { success: false, message: "unterminated DSML invoke open tag" };
	const invokeClose = "</｜｜DSML｜｜invoke>";
	const invokeEnd = text.indexOf(invokeClose, invokeOpenEnd + 1);
	if (invokeEnd < 0) return { success: false, message: "missing DSML invoke close tag" };

	const body = text.slice(invokeOpenEnd + 1, invokeEnd);
	const params: Record<string, unknown> = {};
	const paramOpen = "<｜｜DSML｜｜parameter";
	const paramClose = "</｜｜DSML｜｜parameter>";
	let pos = 0;
	while (pos < body.length) {
		const start = body.indexOf(paramOpen, pos);
		if (start < 0) break;
		const openEnd = body.indexOf(">", start + paramOpen.length);
		if (openEnd < 0) return { success: false, message: "unterminated DSML parameter open tag" };
		const name = parseDSMLAttribute(body, start + paramOpen.length, "name");
		if (!name.success) return name;
		const close = body.indexOf(paramClose, openEnd + 1);
		if (close < 0) return { success: false, message: "missing DSML parameter close tag" };
		params[name.value] = body.slice(openEnd + 1, close);
		pos = close + paramClose.length;
	}
	return {
		success: true,
		obj: {
			tool: toolName,
			reason: extractDSMLReason(text, invokeStart, toolName),
			params,
		},
	};
}

function parseXMLToolCallObjectFromText(text: string): { success: true; obj: Record<string, unknown> } | { success: false; message: string } {
	const children = AgentUtils.parseXMLObjectFromText(text, "tool_call");
	let rawObj: Record<string, unknown> | undefined;
	if (children.success) {
		rawObj = children.obj;
	} else {
		const dsml = parseDSMLToolCallObjectFromText(text);
		if (dsml.success) return dsml;
		const toolStart = text.indexOf("<tool>");
		const paramsCloseToken = "</params>";
		if (toolStart >= 0) {
			const paramsClose = text.indexOf(paramsCloseToken, toolStart);
			if (paramsClose >= toolStart) {
				const bareCandidate = text.slice(toolStart, paramsClose + paramsCloseToken.length).trim();
				const bare = AgentUtils.parseSimpleXMLChildren(bareCandidate);
				if (bare.success && typeof bare.obj.tool === "string" && typeof bare.obj.params === "string") {
					rawObj = bare.obj;
				}
			}
		}
		if (rawObj === undefined) {
			const paramsOpen = text.indexOf("<params>");
			if (paramsOpen < 0) return children;
			const paramsCloseOnly = text.indexOf(paramsCloseToken, paramsOpen);
			if (paramsCloseOnly < paramsOpen) return children;
			const paramsTextOnly = text.slice(paramsOpen + "<params>".length, paramsCloseOnly);
			const paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly);
			if (!paramsOnly.success) return children;
			const inferredTool = inferToolNameFromXMLParams(paramsOnly.obj);
			if (inferredTool === undefined) return children;
			return {
				success: true,
				obj: {
					tool: inferredTool,
					reason: inferredTool === "finish" ? undefined : "Inferred tool from XML params.",
					params: paramsOnly.obj,
				},
			};
		}
	}
	if (rawObj === undefined) return children;
	const paramsText = typeof rawObj.params === "string" ? rawObj.params as string : "";
	const params = paramsText !== ""
		? AgentUtils.parseSimpleXMLChildren(paramsText)
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
	emitLLMContextMetrics(shared, stepId, phase, messages, shared.llmOptions);
	saveStepLLMDebugInput(shared, stepId, phase, messages, shared.llmOptions);
	let lastStreamReasoning = "";
	const res = await AgentUtils.callLLMStreamAggregated(
		messages,
		shared.llmOptions,
		shared.stopToken,
		shared.llmConfig,
		(response) => {
			const streamMessage = response.choices?.[0]?.message;
			const nextContent = typeof streamMessage?.content === "string"
				? AgentUtils.sanitizeUTF8(streamMessage.content)
				: "";
			if (nextContent === "") return;
			if (nextContent === lastStreamReasoning) return;
			lastStreamReasoning = nextContent;
			emitAssistantMessageUpdated(shared, "", nextContent);
		}
	);
	if (res.success) {
		const usage = res.tokenUsage;
		recordLLMTokenUsage(shared, stepId, phase, usage);
		const message = res.response.choices?.[0]?.message;
		const text = message?.content;
		const reasoningContent = typeof message?.reasoning_content === "string"
			? AgentUtils.sanitizeUTF8(message.reasoning_content)
			: undefined;
		if (text) {
			const parsed = tryParseAndValidateDecision(text, shared);
			if (parsed.success) {
				const reason = parsed.reason ?? "";
				emitAssistantMessageUpdated(shared, "", reason !== "" ? reason : undefined);
			}
			saveStepLLMDebugOutput(shared, stepId, phase, text, { success: true, usage });
			return { success: true, text, reasoningContent };
		} else {
			saveStepLLMDebugOutput(shared, stepId, phase, "empty LLM response", { success: false, usage });
			return { success: false, message: "empty LLM response" };
		}
	} else {
		const usage = res.tokenUsage;
		recordLLMTokenUsage(shared, stepId, phase, usage);
		saveStepLLMDebugOutput(shared, stepId, phase, res.raw ?? res.message, { success: false, usage });
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
	if (!AgentToolRegistry.isKnownToolName(tool)) {
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
	if (!AgentToolRegistry.isKnownToolName(functionName)) {
		return { success: false, message: `unknown tool: ${functionName}` };
	}
	if (rawObj === undefined) {
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
	const trimmedArgs = argsText.trim();
	if (trimmedArgs === "") {
		return {};
	}
	const [rawObj, err] = AgentUtils.safeJsonDecode(trimmedArgs);
	if (err !== undefined || rawObj === undefined) {
		return {
			success: false,
			message: `invalid ${functionName} arguments: ${tostring(err)}`,
			raw: argsText,
		};
	}
	const [encodedRaw] = AgentUtils.safeJsonEncode(rawObj as object);
	if (encodedRaw === "null" || !isRecord(rawObj) || trimmedArgs[0] === "[") {
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
	const completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params);
	if (!completionValidation.success) {
		return {
			success: false,
			message: completionValidation.message,
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
	const sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true);
	if (!sharedValidation.success) {
		return {
			success: false,
			message: sharedValidation.message,
			raw: argsText,
		};
	}
	decision.params = validation.params;
	decision.toolCallId = ensureToolCallId(toolCallId);
	decision.reason = reason;
	decision.reasoningContent = reasoningContent;
	return decision;
}

function createPreExecutableActionFromStream(shared: AgentShared, toolCall: ToolCall): AgentActionRecord | undefined {
	const functionName = toolCall.function?.name;
	const argsText = toolCall.function?.arguments ?? "";
	const toolCallId = typeof toolCall.id === "string" ? toolCall.id : undefined;
	if (!functionName || !toolCallId) return undefined;
	const rawArgs = parseToolCallArguments(functionName, argsText);
	if (isRecord(rawArgs) && rawArgs.success === false) return undefined;
	const decision = parseDecisionToolCall(functionName, rawArgs);
	if (!decision.success || !AgentToolRegistry.canPreExecuteTool(decision.tool)) return undefined;
	const validation = validateDecision(decision.tool, decision.params);
	if (!validation.success) return undefined;
	if (!validateDecisionForShared(shared, decision.tool, validation.params).success) return undefined;
	return {
		step: shared.step + 1,
		toolCallId,
		tool: decision.tool,
		reason: "",
		params: validation.params,
		timestamp: os.date("!%Y-%m-%dT%H:%M:%SZ"),
	};
}

function getDecisionPath(params: Record<string, unknown>): string {
	if (typeof params.path === "string") return params.path.trim();
	if (typeof params.target_file === "string") return params.target_file.trim();
	return "";
}

function validateDecisionForShared(
	shared: AgentShared,
	tool: AgentToolName,
	params: Record<string, unknown>,
	enforceFinalTurn = false
): { success: true } | { success: false; message: string } {
	if (enforceFinalTurn && isFinalDecisionTurn(shared) && tool !== "finish") {
		return { success: false, message: "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action" };
	}
	if (!isToolAllowedForRole(shared, tool)) {
		return { success: false, message: `${tool} is not allowed in ${shared.workMode} mode for role ${shared.role}` };
	}
	if (shared.workMode === "plan" && (tool === "edit_file" || tool === "delete_file")) {
		const path = getDecisionPath(params);
		if (!AgentRuntimePolicy.isAgentPlanPath(path)) {
			return { success: false, message: `${tool} in Plan mode may only write under ${AgentRuntimePolicy.AGENT_PLAN_DIR}` };
		}
	}
	if (tool === "delete_file") {
		const path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params));
		if (path === AgentRuntimePolicy.AGENT_PLAN_FILE || path === AgentRuntimePolicy.AGENT_PROGRESS_FILE) {
			return { success: false, message: `${path} is a fixed living document and cannot be deleted` };
		}
	}
	return { success: true };
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
		const completion = getCompletionReport(params);
		params.outcome = completion.outcome;
		params.validation = completion.validation;
		params.knownIssues = completion.knownIssues;
		params.assumptions = completion.assumptions;
		params.learningCandidates = completion.learningCandidates;
		return { success: true, params };
	}

	if (tool === "ask_user") {
		const normalized = normalizeQuestionnaire(params);
		if (!normalized.success) return normalized;
		return { success: true, params: normalized.schema as unknown as Record<string, unknown> };
	}

	if (tool === "read_file") {
		const path = getDecisionPath(params);
		if (path === "") return { success: false, message: "read_file requires path" };
		params.path = path;
		const startLineRes = parseReadLineParam(params.startLine, 1, "startLine");
		if (!startLineRes.success) return startLineRes;
		const endLineDefault = startLineRes.value < 0 ? -1 : AgentConfig.AGENT_LIMITS.readFileDefaultLimit;
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
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1);
		params.offset = clampIntegerParam(params.offset, 0, 0);
		return { success: true, params };
	}

	if (tool === "search_dora_api") {
		const pattern = typeof params.pattern === "string" ? params.pattern.trim() : "";
		if (pattern === "") return { success: false, message: "search_dora_api requires pattern" };
		params.pattern = pattern;
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax);
		return { success: true, params };
	}

	if (tool === "glob_files") {
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1);
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
				.map(item => AgentUtils.sanitizeUTF8(item));
		}
		return { success: true, params };
	}

	return { success: true, params };
}

function validateCompletionForRole(
	role: AgentRole,
	tool: AgentToolName,
	params: Record<string, unknown>
): { success: true } | { success: false; message: string } {
	if (role !== "sub" || tool !== "finish") return { success: true };
	if (params.outcome !== "completed" && params.outcome !== "partial" && params.outcome !== "blocked") {
		return { success: false, message: "sub-agent finish requires params.outcome" };
	}
	const requiredArrays = ["validation", "knownIssues", "assumptions", "learningCandidates"];
	for (let i = 0; i < requiredArrays.length; i++) {
		const name = requiredArrays[i];
		if (!isArray(params[name])) {
			return { success: false, message: `sub-agent finish requires params.${name} as an array` };
		}
	}
	return { success: true };
}

function buildAgentSystemPrompt(shared: AgentShared, includeToolDefinitions = false): string {
	const rolePrompt = shared.workMode === "plan"
		? shared.promptPack.planAgentRolePrompt
		: (shared.role === "main" ? shared.promptPack.mainAgentRolePrompt : shared.promptPack.subAgentRolePrompt);
	const sections: string[] = [
		shared.promptPack.agentIdentityPrompt,
		rolePrompt,
		getReplyLanguageDirective(shared),
	];
	if (shared.role === "main") {
		const planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE);
		const progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE);
		if (Content.exist(planPath) && Content.exist(progressPath)) {
			sections.push([
				"# Current Living Development Plan",
				"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.",
				`## ${AgentRuntimePolicy.AGENT_PLAN_FILE}\n\n${truncateText(AgentUtils.sanitizeUTF8(Content.load(planPath) as string), 12000)}`,
				`## ${AgentRuntimePolicy.AGENT_PROGRESS_FILE}\n\n${truncateText(AgentUtils.sanitizeUTF8(Content.load(progressPath) as string), 12000)}`,
			].join("\n\n"));
		}
	}
	if (shared.decisionMode === "tool_calling") {
		sections.push(shared.promptPack.functionCallingPrompt);
	}
	const memoryBudget = shared.memory.compressor.getMemoryContextBudget();
	const memoryContext = shared.memory.compressor.getStorage().getRelevantMemoryContext(shared.userQuery, memoryBudget);
	if (memoryContext !== "") {
		sections.push(memoryContext);
	}
	const skillsSection = buildSkillsSection(shared);
	if (skillsSection !== "") {
		sections.push(skillsSection);
	}
	if (includeToolDefinitions) {
		sections.push("### Available Tools\n\n" + getDecisionToolDefinitions(shared));
		if (shared.decisionMode === "xml") {
			sections.push(buildXmlDecisionInstruction(shared));
		}
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
	return projectMessagesForLLMContext(
		sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))
	);
}

function isFinalDecisionTurn(shared: AgentShared): boolean {
	return shared.step + 1 >= shared.maxSteps;
}

function getFinalDecisionTurnPrompt(shared: AgentShared): string {
	return shared.useChineseResponse
		? "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。"
		: "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed.";
}

function buildDecisionMessages(
	shared: AgentShared,
	lastError?: string,
	attempt = 1,
	lastRaw?: string,
	decisionMode: AgentDecisionMode = shared.decisionMode,
	consumeResumeCheckpoint = true,
	pendingUserPrompt = ""
): Message[] {
	const systemPrompt = buildAgentSystemPrompt(shared, decisionMode === "xml");
	const tailSections: string[] = [];
	if (shared.resumeCheckpointPending === true) {
		const activeUserInstruction = typeof shared.carryMessageIndex === "number"
			? " The active carried user instruction is newer than the compressed checkpoint and takes precedence."
			: "";
		tailSections.push(`Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery.${activeUserInstruction}`);
	}
	if (shared.truncatedToolOverwritePath !== undefined) {
		tailSections.push(`Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to ${shared.truncatedToolOverwritePath}. Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix.`);
	}
	if (consumeResumeCheckpoint) shared.resumeCheckpointPending = false;
	let messages: Message[] = [
		{ role: "system", content: systemPrompt },
		...getUnconsolidatedMessages(shared),
	];
	if (pendingUserPrompt !== "") {
		messages.push({ role: "user", content: pendingUserPrompt });
	}
	if (isFinalDecisionTurn(shared)) {
		tailSections.push(getFinalDecisionTurnPrompt(shared));
	}
	if (lastError && lastError !== "") {
		let retryHeader = decisionMode === "xml"
			? `Previous response was invalid (${lastError}). Return exactly one valid XML tool_call block only.`
			: replacePromptVars(shared.promptPack.toolCallingRetryPrompt, { LAST_ERROR: lastError });
		if (decisionMode === "xml") {
			retryHeader += "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags.";
		}
		if (decisionMode === "xml" && lastRaw && lastRaw.trim() !== "") {
			retryHeader += "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work.";
		}
		if (decisionMode === "tool_calling" && lastError.indexOf("truncated by max tokens") >= 0) {
			retryHeader += "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning.";
		}
		messages.push({
			role: "user",
			content: `${retryHeader}

		Retry attempt: ${attempt}.
	The next reply must differ from the previously rejected output.
	${lastRaw && lastRaw !== "" ? `Last rejected output summary: ${truncateText(lastRaw, 300)}` : ""}`,
		});
	}
	tailSections.push(AgentToolRegistry.buildCurrentToolAvailabilityPrompt({
		role: shared.role,
		workMode: shared.workMode,
		taskDisabledAgentTools: shared.disabledAgentTools,
		currentDisabledAgentTools: getDecisionDisabledAgentTools(shared),
		resumeRequiredTool: shared.resumeRequiredTool,
		hasSpawnedSubAgentThisTask: shared.hasSpawnedSubAgentThisTask,
		delegatedForegroundBudgetExhausted: (shared.delegatedForegroundBatches ?? 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit,
		freshProjectBuildPending: shared.freshProjectBuildPending,
		freshProjectCodeFile: shared.freshProjectCodeFile,
		freshProjectHasAuthoredEdit: shared.freshProjectBuildPending === true && shared.unbuiltEdits === true,
		buildRepairPending: shared.buildRepairPending,
		lastBuildSucceeded: shared.lastBuildSucceeded === true && shared.unbuiltEdits !== true,
		editBudgetExhausted: AgentRuntimePolicy.isEditBudgetExhausted(shared),
		repeatedDeterministicTestFailure: (shared.deterministicTestFailureCount ?? 0) >= 2,
	}));
	messages.push({
		role: "user",
		content: tailSections.join("\n\n"),
	});
	return messages;
}

function buildXmlDecisionInstruction(shared: AgentShared, feedback?: string): string {
	return `${shared.promptPack.xmlDecisionFormatPrompt}${feedback ?? ""}`;
}

function buildXmlRepairMessages(
	shared: AgentShared,
	originalRaw: string,
	originalReasoning: string | undefined,
	candidateRaw: string,
	candidateReasoning: string | undefined,
	lastError: string,
	attempt: number
): Message[] {
	const hasOriginalReasoning = originalReasoning !== undefined && originalReasoning.trim() !== "";
	const originalReasoningSection = hasOriginalReasoning
		? `### Original Reasoning
\`\`\`
${truncateText(originalReasoning as string, 4000)}
\`\`\`

`
		: "";
	const hasCandidate = candidateRaw.trim() !== "";
	const hasCandidateReasoning = candidateReasoning !== undefined && candidateReasoning.trim() !== "";
	const candidateReasoningSection = hasCandidateReasoning
		? `### Current Candidate Reasoning
\`\`\`
${truncateText(candidateReasoning as string, 4000)}
\`\`\`

`
		: "";
	const candidateSection = hasCandidate
		? `### Current Candidate To Repair
\`\`\`
${truncateText(candidateRaw, 4000)}
\`\`\`

${candidateReasoningSection}`
		: "";
	const toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {
		includeFinish: true,
		includeXmlRules: true,
		context: { searchDoraApiLimitMax: AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax },
		disabledAgentTools: getDecisionDisabledAgentTools(shared),
		workMode: shared.workMode,
	});
	const systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {
		TOOL_REPAIR_REFERENCE: toolRepairReference,
	});
	const repairPrompt = replacePromptVars(shared.promptPack.xmlDecisionRepairPrompt, {
		ORIGINAL_RAW: truncateText(originalRaw, 4000),
		ORIGINAL_REASONING_SECTION: originalReasoningSection,
		CANDIDATE_SECTION: candidateSection,
		LAST_ERROR: lastError,
		ATTEMPT: tostring(attempt),
	});
	const availabilityPrompt = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({
		role: shared.role,
		workMode: shared.workMode,
		taskDisabledAgentTools: shared.disabledAgentTools,
		currentDisabledAgentTools: getDecisionDisabledAgentTools(shared),
		resumeRequiredTool: shared.resumeRequiredTool,
		hasSpawnedSubAgentThisTask: shared.hasSpawnedSubAgentThisTask,
		delegatedForegroundBudgetExhausted: (shared.delegatedForegroundBatches ?? 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit,
		freshProjectBuildPending: shared.freshProjectBuildPending,
		freshProjectCodeFile: shared.freshProjectCodeFile,
		freshProjectHasAuthoredEdit: shared.freshProjectBuildPending === true && shared.unbuiltEdits === true,
		buildRepairPending: shared.buildRepairPending,
		lastBuildSucceeded: shared.lastBuildSucceeded === true && shared.unbuiltEdits !== true,
		editBudgetExhausted: AgentRuntimePolicy.isEditBudgetExhausted(shared),
		repeatedDeterministicTestFailure: (shared.deterministicTestFailureCount ?? 0) >= 2,
	});
	return [
		{
			role: "system",
			content: systemPrompt,
		},
		{
			role: "user",
			content: `${repairPrompt}\n\n${availabilityPrompt}`,
		},
	];
}

function tryParseAndValidateDecision(rawText: string, shared: AgentShared): DecisionSuccess | DecisionFailure {
	const parsed = parseXMLToolCallObjectFromText(rawText);
	if (!parsed.success) {
		return { success: false, message: parsed.message, raw: rawText };
	}
	const decision = parseDecisionObject(parsed.obj);
	if (!decision.success) {
		return { success: false, message: decision.message, raw: rawText };
	}
	const completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params);
	if (!completionValidation.success) {
		return { success: false, message: completionValidation.message, raw: rawText };
	}
	const validation = validateDecision(decision.tool, decision.params);
	if (!validation.success) {
		return { success: false, message: validation.message, raw: rawText };
	}
	const sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true);
	if (!sharedValidation.success) {
		return { success: false, message: sharedValidation.message, raw: rawText };
	}
	decision.params = validation.params;
	decision.toolCallId = ensureToolCallId(decision.toolCallId);
	return decision;
}

class MainDecisionAgent extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ shared: AgentShared }> {
		if (shared.stopToken.stopped || shared.step >= shared.maxSteps) {
			return { shared };
		}

		await maybeCompressHistory(shared);

		return { shared };
	}

	private commitPreExecutedDecision(shared: AgentShared): DecisionSuccess | DecisionBatchSuccess | undefined {
		const preExecuted = shared.preExecutedResults;
		if (!preExecuted || preExecuted.size === 0) return undefined;
		const decisions: DecisionSuccess[] = [];
		preExecuted.forEach(preResult => {
			const action = preResult.action;
			decisions.push({
				success: true,
				tool: action.tool,
				params: action.params,
				toolCallId: action.toolCallId,
				reason: action.reason,
				reasoningContent: action.reasoningContent,
			});
		});
		if (decisions.length === 0) return undefined;
		AgentUtils.Log("Warn", `[CodingAgent] committing pre-executed tools after incomplete stream tools=${decisions.map(decision => decision.tool).join(",")}`);
		if (decisions.length === 1) {
			return decisions[0];
		}
		return {
			success: true,
			kind: "batch",
			decisions,
		};
	}

	private preserveTruncatedEditDecision(
		shared: AgentShared,
	toolCalls: ToolCall[] | undefined,
	reasoningContent?: string
): DecisionSuccess | undefined {
		const recovery = Tools.planTruncatedEditRecovery(toolCalls);
		if (!recovery) return undefined;
		shared.truncatedToolOverwritePath = recovery.target;
		AgentUtils.Log("Warn", `[CodingAgent] preserving truncated whole-file overwrite target=${recovery.target}`);
		return {
			success: true,
			tool: "edit_file",
			params: {
				path: recovery.target,
				old_str: "",
				new_str: recovery.receivedText,
				partialStreamRecovery: true,
			},
			toolCallId: AgentUtils.createLocalToolCallId(),
			reason: recovery.reason,
			reasoningContent,
		};
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
		AgentUtils.Log("Info", `[CodingAgent] tool-calling decision start step=${shared.step + 1}${lastError ? ` retry_error=${lastError}` : ""}`);
		const tools = AgentToolRegistry.buildDecisionToolSchema(shared.role, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, {
			disabledAgentTools: getDecisionDisabledAgentTools(shared),
			workMode: shared.workMode,
		});
		const messages = buildDecisionMessages(shared, lastError, attempt, lastRaw);
		const stepId = shared.step + 1;
		const useFastGlmToolDecision = shared.llmConfig.model.toLowerCase().includes("glm-5.2")
			&& (typeof shared.llmOptions.reasoning_effort !== "string"
				|| shared.llmOptions.reasoning_effort.trim() === "");
		const llmOptions = {
			...shared.llmOptions,
			...(useFastGlmToolDecision ? { reasoning_effort: "minimal" } : {}),
			tools,
		};
		emitLLMContextMetrics(shared, stepId, "decision_tool_calling", messages, llmOptions);
		saveStepLLMDebugInput(shared, stepId, "decision_tool_calling", messages, llmOptions);
		let lastStreamContent = "";
		let lastStreamReasoning = "";
		const preExecutedResults = new Map<string, PreExecutedToolResult>();
		shared.preExecutedResults = preExecutedResults;
		const res = await AgentUtils.callLLMStreamAggregated(
			messages,
			llmOptions,
			shared.stopToken,
			shared.llmConfig,
			(response) => {
				const streamMessage = response.choices?.[0]?.message;
				const nextContent = typeof streamMessage?.content === "string"
					? AgentUtils.sanitizeUTF8(streamMessage.content)
					: "";
				const nextReasoning = typeof streamMessage?.reasoning_content === "string"
					? AgentUtils.sanitizeUTF8(streamMessage.reasoning_content)
					: "";
				if (nextContent === lastStreamContent && nextReasoning === lastStreamReasoning) {
					return;
				}
				lastStreamContent = nextContent;
				lastStreamReasoning = nextReasoning;
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning !== "" ? nextReasoning : undefined);
			},
			(tc) => {
				if (shared.stopToken.stopped) return;
				const action = createPreExecutableActionFromStream(shared, tc);
				if (!action || preExecutedResults.has(action.toolCallId)) return;
				AgentUtils.Log("Info", `[CodingAgent] streaming pre-exec tool=${action.tool} id=${action.toolCallId}`);
				preExecutedResults.set(action.toolCallId, createPreExecutedToolResult(shared, action));
			}
		);
		if (shared.stopToken.stopped) {
			clearPreExecutedResults(shared);
			return { success: false, message: getCancelledReason(shared) };
		}
		if (!res.success) {
			const usage = res.tokenUsage;
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage);
			saveStepLLMDebugOutput(shared, stepId, "decision_tool_calling", res.raw ?? res.message, { success: false, usage });
			AgentUtils.Log("Error", `[CodingAgent] tool-calling request failed: ${res.message}`);
			const committed = this.commitPreExecutedDecision(shared);
			if (committed) return committed;
			const partialChoice = res.response?.choices?.[0];
			const partialDraft = this.preserveTruncatedEditDecision(
				shared,
				partialChoice?.message?.tool_calls,
				partialChoice?.message?.reasoning_content
			);
			if (partialDraft) return partialDraft;
			clearPreExecutedResults(shared);
			return { success: false, message: res.message, raw: res.raw };
		}
		const usage = res.tokenUsage;
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage);
		saveStepLLMDebugOutput(shared, stepId, "decision_tool_calling", encodeDebugJSON(res.response), { success: true, usage });
		const choice = res.response.choices && res.response.choices[0];
		const message = choice && choice.message;
		const toolCalls = message && message.tool_calls;
		const finishReason = choice && typeof choice.finish_reason === "string"
			? choice.finish_reason
			: "";
		const reasoningContent = message && typeof message.reasoning_content === "string"
			? message.reasoning_content
			: undefined;
		const messageContent = message && typeof message.content === "string"
			? message.content.trim()
			: undefined;
		AgentUtils.Log("Info", `[CodingAgent] tool-calling response finish_reason=${finishReason !== "" ? finishReason : "unknown"} tool_calls=${toolCalls ? toolCalls.length : 0} content_len=${messageContent ? messageContent.length : 0} reasoning_len=${reasoningContent ? reasoningContent.length : 0}`);
		if (finishReason === "length") {
			const committed = this.commitPreExecutedDecision(shared);
			if (committed) return committed;
			const partialDraft = this.preserveTruncatedEditDecision(shared, toolCalls, reasoningContent);
			if (partialDraft) return partialDraft;
			AgentUtils.Log("Error", `[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=${toolCalls ? toolCalls.length : 0} reasoning_len=${reasoningContent ? reasoningContent.length : 0}`);
			clearPreExecutedResults(shared);
			return {
				success: false,
				message: "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.",
				raw: reasoningContent ?? messageContent ?? "",
			};
		}
		if (!toolCalls || toolCalls.length === 0) {
			if (messageContent && messageContent !== "") {
				if (isFinalDecisionTurn(shared)) {
					clearPreExecutedResults(shared);
					return {
						success: false,
						message: "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message",
						raw: messageContent,
					};
				}
				if (shared.role === "sub") {
					AgentUtils.Log("Warn", `[CodingAgent] sub-agent returned plain text instead of structured finish`);
					clearPreExecutedResults(shared);
					return {
						success: false,
						message: "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted",
						raw: messageContent,
					};
				}
				AgentUtils.Log("Info", `[CodingAgent] tool-calling fallback direct_finish_len=${messageContent.length}`);
				clearPreExecutedResults(shared);
				return {
					success: true,
					tool: "finish",
					params: {},
					reason: messageContent,
					reasoningContent,
					directSummary: messageContent,
				};
			}
			AgentUtils.Log("Error", `[CodingAgent] missing tool call and plain-text fallback`);
			clearPreExecutedResults(shared);
			return {
				success: false,
				message: "missing tool call",
				raw: reasoningContent ?? messageContent ?? "",
			};
		}
		const decisions: DecisionSuccess[] = [];
		for (let i = 0; i < toolCalls.length; i++) {
			const toolCall = toolCalls[i];
			const fn = toolCall != undefined && toolCall.function;
			if (!fn || typeof fn.name !== "string" || fn.name === "") {
				AgentUtils.Log("Error", `[CodingAgent] missing function name for tool call index=${i + 1}`);
				clearPreExecutedResults(shared);
				return {
					success: false,
					message: `missing function name for tool call ${i + 1}`,
					raw: messageContent,
				};
			}
			const functionName = fn.name;
			const argsText = typeof fn.arguments === "string" ? fn.arguments : "";
			const toolCallId = toolCall != undefined && typeof toolCall.id === "string"
				? toolCall.id
				: undefined;
			AgentUtils.Log("Info", `[CodingAgent] tool-calling function=${functionName} index=${i + 1}/${toolCalls.length} args_len=${argsText.length}`);
			const decision = parseAndValidateToolCallDecision(
				shared,
				functionName,
				argsText,
				toolCallId,
				messageContent,
				reasoningContent
			);
			if (!decision.success) {
				AgentUtils.Log("Error", `[CodingAgent] invalid tool call index=${i + 1}: ${decision.message}`);
				clearPreExecutedResults(shared);
				return decision;
			}
			decisions.push(decision);
		}
		if (decisions.length === 1) {
			AgentUtils.Log("Info", `[CodingAgent] tool-calling selected tool=${decisions[0].tool}`);
			return decisions[0];
		}
		for (let i = 0; i < decisions.length; i++) {
			if (decisions[i].tool === "finish" || decisions[i].tool === "ask_user") {
				clearPreExecutedResults(shared);
				return {
					success: false,
					message: `${decisions[i].tool} cannot be mixed with other tool calls`,
					raw: messageContent,
				};
			}
		}
		AgentUtils.Log("Info", `[CodingAgent] tool-calling selected batch tools=${decisions.map(decision => decision.tool).join(",")}`);
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
		originalReasoning: string | undefined,
		initialError: string
	): Promise<DecisionResult | DecisionFailure> {
		AgentUtils.Log("Info", `[CodingAgent] xml repair flow start step=${shared.step + 1} error=${initialError}`);
		let lastError = initialError;
		let candidateRaw = "";
		let candidateReasoning: string | undefined = undefined;
		for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
			AgentUtils.Log("Info", `[CodingAgent] xml repair attempt=${attempt + 1}`);
			const messages = buildXmlRepairMessages(
				shared,
				originalRaw,
				originalReasoning,
				candidateRaw,
				candidateReasoning,
				lastError,
				attempt + 1
			);
			const llmRes = await llm(shared, messages, "decision_xml_repair");
			if (shared.stopToken.stopped) {
				return { success: false, message: getCancelledReason(shared) };
			}
			if (!llmRes.success) {
				lastError = llmRes.message;
				AgentUtils.Log("Error", `[CodingAgent] xml repair attempt failed: ${lastError}`);
				continue;
			}
			candidateRaw = llmRes.text;
			candidateReasoning = llmRes.reasoningContent;
			const decision = tryParseAndValidateDecision(candidateRaw, shared);
			if (decision.success) {
				decision.reasoningContent = llmRes.reasoningContent;
				AgentUtils.Log("Info", `[CodingAgent] xml repair succeeded tool=${decision.tool}`);
				return decision;
			}
			lastError = decision.message;
			AgentUtils.Log("Error", `[CodingAgent] xml repair candidate invalid: ${lastError}`);
		}
		AgentUtils.Log("Error", `[CodingAgent] xml repair exhausted retries: ${lastError}`);
		return {
			success: false,
			message: `cannot repair invalid decision xml: ${lastError}`,
			raw: candidateRaw,
		};
	}

	private async callDecisionByXml(
		shared: AgentShared,
		lastError?: string,
		attempt = 1,
		lastRaw?: string
	): Promise<DecisionResult | DecisionFailure> {
		const messages: Message[] = buildDecisionMessages(
			shared,
			lastError,
			attempt,
			lastRaw,
			"xml"
		);
		const llmRes = await llm(shared, messages, "decision_xml");
		if (shared.stopToken.stopped) {
			return { success: false, message: getCancelledReason(shared) };
		}
		if (!llmRes.success) {
			return {
				success: false,
				message: llmRes.message,
				raw: llmRes.text ?? "",
			};
		}
		const decision = tryParseAndValidateDecision(llmRes.text, shared);
		if (decision.success) {
			decision.reasoningContent = llmRes.reasoningContent;
			return decision;
		}
		return this.repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message);
	}

	async exec(input: { shared: AgentShared }): Promise<DecisionResult | DecisionFailure> {
		const shared = input.shared;
		if (shared.stopToken.stopped) {
			return { success: false, message: getCancelledReason(shared) };
		}
		if (shared.step >= shared.maxSteps) {
			AgentUtils.Log("Warn", `[CodingAgent] maximum step limit reached step=${shared.step} max=${shared.maxSteps}`);
			return { success: false, message: getMaxStepsReachedReason(shared) };
		}

		if (shared.decisionMode === "tool_calling") {
			AgentUtils.Log("Info", `[CodingAgent] decision mode=tool_calling step=${shared.step + 1} messages=${getUnconsolidatedMessages(shared).length}`);
			let lastError = "tool calling validation failed";
			let lastRaw = "";
			let shouldFallbackToXml = false;
			for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
				AgentUtils.Log("Info", `[CodingAgent] tool-calling attempt=${attempt + 1}`);
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
				AgentUtils.Log("Error", `[CodingAgent] tool-calling attempt failed: ${lastError}`);
				if (lastError === "missing tool call") {
					shouldFallbackToXml = true;
					break;
				}
			}
			if (shouldFallbackToXml) {
				AgentUtils.Log("Warn", `[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format`);
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block.";
				for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
					AgentUtils.Log("Info", `[CodingAgent] xml fallback attempt=${attempt + 1}`);
					const decision = await this.callDecisionByXml(
						shared,
						attempt > 0 ? lastError : "tool-calling returned no tool calls. Use XML decision format instead.",
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
					AgentUtils.Log("Error", `[CodingAgent] xml fallback attempt failed: ${lastError}`);
				}
				AgentUtils.Log("Error", `[CodingAgent] xml fallback exhausted retries: ${lastError}`);
				return { success: false, message: `cannot produce valid XML decision after tool-calling fallback: ${lastError}; last_output=${truncateText(lastRaw, 400)}` };
			}
			AgentUtils.Log("Error", `[CodingAgent] tool-calling exhausted retries: ${lastError}`);
			return { success: false, message: `cannot produce valid tool call: ${lastError}; last_output=${truncateText(lastRaw, 400)}` };
		}

		let lastError = "xml validation failed";
		let lastRaw = "";
		for (let attempt = 0; attempt < shared.llmMaxTry; attempt++) {
			const decision = await this.callDecisionByXml(
				shared,
				attempt > 0
					? `Previous request failed before producing repairable output (${lastError}).`
					: undefined,
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
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role === "sub" ? {
				outcome: "partial",
				knownIssues: ["Sub agent returned a plain-text finish without structured completion metadata."],
			} : {});
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
			shared.completion = getCompletionReport(result.params);
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
		// Route every tool through the shared executor, even for a single call.
		// The legacy per-tool flow nodes bypass runtime guards and accounting.
		shared.pendingToolActions = [action];
		persistHistoryState(shared);
		return "batch_tools";
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
			endLine: Number(last.params.endLine ?? AgentConfig.AGENT_LIMITS.readFileDefaultLimit),
		};
	}

	async exec(input: { path: string; startLine: number; endLine: number; tool: "read_file"; workDir: string; docLanguage: Tools.DoraAPIDocLanguage }): Promise<Record<string, unknown>> {
		return Tools.readFile(
			input.workDir,
			input.path,
			Number(input.startLine ?? 1),
			Number(input.endLine ?? AgentConfig.AGENT_LIMITS.readFileDefaultLimit),
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
			contentWindow: AgentConfig.AGENT_LIMITS.searchPreviewContext,
			limit: math.max(1, math.floor(Number(params.limit ?? AgentConfig.AGENT_LIMITS.searchFilesLimitDefault))),
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
			limit: math.min(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, math.max(1, Number(params.limit ?? 8))),
			useRegex: params.useRegex as boolean | undefined,
			caseSensitive: false,
			includeContent: true,
			contentWindow: AgentConfig.AGENT_LIMITS.searchPreviewContext,
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
			maxEntries: math.max(1, math.floor(Number(params.maxEntries ?? AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault))),
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
			last.params = sanitizeActionParamsForHistory(last.tool, last.params);
			last.result = sanitizeToolActionResultForHistory(last, execRes);
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
					files: result.files as {
						path: string;
						op: "write" | "create" | "delete";
					}[],
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
			last.result = sanitizeBuildResultForHistory(execRes as Record<string, unknown>);
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
		disabledAgentTools: AgentToolName[];
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
			disabledAgentTools: shared.disabledAgentTools,
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
		disabledAgentTools: AgentToolName[];
	}): Promise<Record<string, unknown>> {
		if (!input.spawnSubAgent) {
			return { success: false, message: "spawn_sub_agent is not available in this runtime" };
		}
		if (input.sessionId === undefined || input.sessionId <= 0) {
			return { success: false, message: "spawn_sub_agent requires a parent session" };
		}
		AgentUtils.Log("Info", `[CodingAgent] spawn_sub_agent exec title_len=${input.title.length} prompt_len=${input.prompt.length} expected_len=${typeof input.expectedOutput === "string" ? input.expectedOutput.length : 0} files_hint_count=${input.filesHint?.length ?? 0}`);
		const result = await input.spawnSubAgent({
			parentSessionId: input.sessionId,
			projectRoot: input.projectRoot,
			title: input.title,
			prompt: input.prompt,
			expectedOutput: input.expectedOutput,
			filesHint: input.filesHint,
			disabledAgentTools: input.disabledAgentTools,
		});
		if (!result.success) {
			return result as unknown as Record<string, unknown>;
		}
		return {
			success: true,
			sessionId: result.sessionId,
			taskId: result.taskId,
			title: result.title,
			hint: "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs.",
		};
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.result = execRes as Record<string, unknown>;
			if ((execRes as Record<string, unknown>).success === true) {
				shared.hasSpawnedSubAgentThisTask = true;
			}
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
		shouldDiscouragePolling: boolean;
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
			shouldDiscouragePolling: shared.hasSpawnedSubAgentThisTask === true,
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
		shouldDiscouragePolling: boolean;
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
		return {
			...(result as unknown as Record<string, unknown>),
			...(input.shouldDiscouragePolling
				? { guidance: "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." }
				: {}),
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
			return AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, {
				success: true,
				changed: true,
				mode: "create",
				checkpointId: createRes.checkpointId,
				checkpointSeq: createRes.checkpointSeq,
				files: [{ path: input.path, op: "create" as const }],
			});
		}
		if (input.oldStr === "") {
			if (AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr)) {
				return {
					success: false,
					message: `rewrite rejected: the complete current file appears more than once in the replacement for ${input.path}. The existing file is unchanged; submit one coherent full-file replacement.`,
					actualSaved: false,
					actualSavedCharacters: 0,
					currentFileExists: true,
					currentCharacters: readRes.content.length,
					currentState: `unchanged ${input.path} (${readRes.content.length} characters)`,
				};
			}
			const overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, [{ path: input.path, op: "write", content: input.newStr }], {
				summary: `overwrite file ${input.path} via edit_file`,
				toolName: "edit_file",
			});
			if (!overwriteRes.success) {
				return { success: false, message: `write file failed: ${overwriteRes.message}` };
			}
			return AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, {
				success: true,
				changed: true,
				mode: "overwrite",
				checkpointId: overwriteRes.checkpointId,
				checkpointSeq: overwriteRes.checkpointSeq,
				files: [{ path: input.path, op: "write" as const }],
			});
		}

		// Normalize line endings for consistent matching
		const normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content);
		const normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr);
		const normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr);

		// Check how many times old_str appears
		const occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr);
		if (occurrences === 0) {
			const indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr);
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
			return AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, {
				success: true,
				changed: true,
				mode: "replace_indent_tolerant",
				checkpointId: applyRes.checkpointId,
				checkpointSeq: applyRes.checkpointSeq,
				files: [{ path: input.path, op: "write" as const }],
			});
		}
		if (occurrences > 1) {
			return { success: false, message: `old_str appears ${occurrences} times in file. Please provide more context to uniquely identify the target location.` };
		}

		// Perform the replacement (we know it appears exactly once)
		const newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr);
		const applyRes = Tools.applyFileChanges(input.taskId, input.workDir, [{ path: input.path, op: "write", content: newContent }], {
			summary: `replace text in ${input.path} via edit_file`,
			toolName: "edit_file",
		});
		if (!applyRes.success) {
			return { success: false, message: `write file failed: ${applyRes.message}` };
		}
		return AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, {
			success: true,
			changed: true,
			mode: "replace",
			checkpointId: applyRes.checkpointId,
			checkpointSeq: applyRes.checkpointSeq,
			files: [{ path: input.path, op: "write" as const }],
		});
	}

	async post(shared: AgentShared, _prepRes: unknown, execRes: unknown): Promise<string | undefined> {
		const last = shared.history[shared.history.length - 1];
		if (last !== undefined) {
			last.params = sanitizeActionParamsForHistory(last.tool, last.params);
			last.result = sanitizeToolActionResultForHistory(last, execRes as Record<string, unknown>);
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
					files: result.files as {
						path: string;
						op: "write" | "create" | "delete";
					}[],
				});
			}
		}
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return "main";
	}
}

class FetchUrlAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ shared: AgentShared; action: AgentActionRecord }> {
		const last = shared.history[shared.history.length - 1];
		if (!last) throw new Error("no history");
		emitAgentStartEvent(shared, last);
		return { shared, action: last };
	}

	async exec(input: { shared: AgentShared; action: AgentActionRecord }): Promise<Record<string, unknown>> {
		return executeToolAction(input.shared, input.action);
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
			files: result.files as {
				path: string;
				op: "write" | "create" | "delete";
			}[],
		});
	}
}

async function executeToolAction(shared: AgentShared, action: AgentActionRecord): Promise<Record<string, unknown>> {
	if (shared.stopToken.stopped) {
		return { success: false, message: getCancelledReason(shared) };
	}
	if (shared.resumeRequiredTool !== undefined && action.tool === shared.resumeRequiredTool) {
		shared.resumeRequiredTool = undefined;
		shared.resumeCheckpointPending = false;
	}
	const params = action.params;
	const sharedValidation = validateDecisionForShared(shared, action.tool, params);
	if (!sharedValidation.success) return sharedValidation;
	if (action.tool === "read_file") {
		const startLine = Number(params.startLine ?? 1);
		let endLine = Number(params.endLine ?? AgentConfig.AGENT_LIMITS.readFileDefaultLimit);
		let clippedAfterCompression = false;
		if (
			shared.resumeNarrowReadMode === true
			&& startLine > 0
			&& endLine >= startLine
			&& endLine - startLine + 1 > 160
		) {
			endLine = startLine + 159;
			clippedAfterCompression = true;
		}
		const path = typeof params.path === "string"
			? params.path
			: (typeof params.target_file === "string" ? params.target_file : "");
		if (path.trim() === "") return { success: false, message: "missing path" };
		const result = Tools.readFile(
			shared.workingDir,
			path,
			startLine,
			endLine,
			shared.useChineseResponse ? "zh" : "en"
		) as unknown as Record<string, unknown>;
		if (clippedAfterCompression && result.success === true) {
			result.clipped = true;
			result.message = shared.useChineseResponse
				? `压缩恢复阶段已自动截取为第 ${startLine}-${endLine} 行（最多 160 行）。如仍需后续内容，请从第 ${endLine + 1} 行继续窄读。`
				: `The post-compression read was clipped to lines ${startLine}-${endLine} (160 lines maximum). Continue narrowly from line ${endLine + 1} only if needed.`;
		}
		return result;
	}
	// A forced post-compression build validates the checkpoint but does not
	// justify rereading whole authored files. Keep narrow-read mode across that
	// build; a later edit/command/search represents real resumed work and may
	// clear it normally.
	if (action.tool !== "build") shared.resumeNarrowReadMode = false;
	if (action.tool === "grep_files") {
		const searchPath = (params.path as string) ?? "";
		const searchGlobs = params.globs as string[] | undefined;
		const result = await Tools.searchFiles({
			workDir: shared.workingDir,
			path: searchPath,
			pattern: (params.pattern as string) ?? "",
			globs: params.globs as string[] | undefined,
			useRegex: params.useRegex as boolean | undefined,
			caseSensitive: params.caseSensitive as boolean | undefined,
			includeContent: true,
			contentWindow: AgentConfig.AGENT_LIMITS.searchPreviewContext,
			limit: math.max(1, math.floor(Number(params.limit ?? AgentConfig.AGENT_LIMITS.searchFilesLimitDefault))),
			offset: math.max(0, math.floor(Number(params.offset ?? 0))),
			groupByFile: params.groupByFile === true,
		});
		return result as unknown as Record<string, unknown>;
	}
	if (action.tool === "search_dora_api") {
		shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild ?? 0) + 1;
		const result = await Tools.searchDoraAPI({
			pattern: (params.pattern as string) ?? "",
			docSource: ((params.docSource as string) ?? "api") as Tools.DoraAPIDocSource,
			docLanguage: (shared.useChineseResponse ? "zh" : "en") as Tools.DoraAPIDocLanguage,
			programmingLanguage: ((params.programmingLanguage as string) ?? "ts") as Tools.DoraAPIProgrammingLanguage,
			limit: math.min(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, math.max(1, Number(params.limit ?? 8))),
			useRegex: params.useRegex as boolean | undefined,
			caseSensitive: false,
			includeContent: true,
			contentWindow: AgentConfig.AGENT_LIMITS.searchPreviewContext,
		});
		return result as unknown as Record<string, unknown>;
	}
	if (action.tool === "glob_files") {
		const result = Tools.listFiles({
			workDir: shared.workingDir,
			path: (params.path as string) ?? "",
			globs: params.globs as string[] | undefined,
			maxEntries: math.max(1, math.floor(Number(params.maxEntries ?? AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault))),
		});
		return result as unknown as Record<string, unknown>;
	}
	if (action.tool === "ask_user") {
		if (!shared.publishQuestionnaire) return { success: false, message: "ask_user is not available in this runtime" };
		if (shared.sessionId === undefined || shared.sessionId <= 0) return { success: false, message: "ask_user requires a session" };
		const normalized = normalizeQuestionnaire(params);
		if (!normalized.success) return normalized;
		const result = await shared.publishQuestionnaire({
			sessionId: shared.sessionId,
			taskId: shared.taskId,
			step: action.step,
			schema: normalized.schema,
		});
		if (!result.success) return result;
		shared.waitingQuestionnaireId = result.questionnaireId;
		return { success: true, waitingForUser: true, questionnaireId: result.questionnaireId };
	}
	if (action.tool === "delete_file") {
		const targetFile = typeof params.target_file === "string"
			? params.target_file
			: (typeof params.path === "string" ? params.path : "");
		if (targetFile.trim() === "") return { success: false, message: "missing target_file" };
		const normalizedTargetFile = normalizePolicyPath(targetFile);
		const editedPaths = shared.editedPathsSinceBuild ?? [];
		if (isMainAgentMemoryPath(normalizedTargetFile)) {
			return { success: false, message: "This .agent/main file is managed automatically and cannot be deleted with delete_file." };
		}
		const isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile);
		const result = Tools.applyFileChanges(shared.taskId, shared.workingDir, [{ path: targetFile, op: "delete" }], {
			summary: `delete_file: ${targetFile}`,
			toolName: "delete_file",
		});
		if (!result.success) {
			return result as unknown as Record<string, unknown>;
		}
		if (!isInternalDocumentEdit) {
			shared.unbuiltEdits = true;
			shared.lastBuildSucceeded = false;
			if (shared.failedTestNeedsBuild === true) shared.failedTestHasSourceEdit = true;
			if (editedPaths.indexOf(normalizedTargetFile) < 0) editedPaths.push(normalizedTargetFile);
			shared.editedPathsSinceBuild = editedPaths;
			shared.editsSinceBuild = (shared.editsSinceBuild ?? 0) + 1;
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
		const buildPath = (params.path as string) ?? "";
		const result = await Tools.build({
			workDir: shared.workingDir,
			path: buildPath
		});
		shared.unbuiltEdits = false;
		shared.editsSinceBuild = 0;
		shared.editedPathsSinceBuild = [];
		shared.hasBuilt = true;
		shared.lastBuildSucceeded = result.success;
		// The fresh-project gate promises to last only until the first successful
		// build. A normal coding turn usually builds init.ts directly, so requiring
		// an empty path here left read/discovery tools hidden for the entire task
		// even though the authored entry had already compiled successfully.
		if (result.success && shared.freshProjectBuildPending === true) {
			shared.freshProjectBuildPending = false;
		}
		shared.apiSearchesSinceBuild = 0;
		shared.buildRepairPending = false;
		if (!result.success && result.messages !== undefined) {
			for (let i = 0; i < result.messages.length; i++) {
				if (result.messages[i].success === false && result.messages[i].file !== "") {
					shared.buildRepairPending = true;
					break;
				}
			}
		}
		if (result.success && shared.failedTestNeedsBuild === true && shared.failedTestHasSourceEdit === true) {
			shared.failedTestNeedsBuild = false;
			shared.failedTestHasSourceEdit = false;
		}
		return result as unknown as Record<string, unknown>;
	}
	if (action.tool === "fetch_url") {
		const result = await Tools.fetchUrl({
			workDir: shared.workingDir,
			url: typeof params.url === "string" ? params.url : "",
			target: typeof params.target === "string" ? params.target : "",
			isCancelled: () => shared.stopToken.stopped === true,
			onProgress: progress => {
				emitAgentEvent(shared, {
					type: "tool_progress",
					sessionId: shared.sessionId,
					taskId: shared.taskId,
					step: action.step,
					tool: action.tool,
					result: {
						success: false,
						...progress,
					},
				});
			},
		});
		return result as unknown as Record<string, unknown>;
	}
	if (action.tool === "execute_command") {
		const mode = typeof params.mode === "string" ? params.mode : "";
		const result = await Tools.executeCommand({
			workDir: shared.workingDir,
			mode: mode as Tools.ExecuteCommandMode,
			code: typeof params.code === "string" ? params.code : undefined,
			command: typeof params.command === "string" ? params.command : undefined,
			cwd: typeof params.cwd === "string" ? params.cwd : undefined,
			timeoutSeconds: typeof params.timeoutSeconds === "number" ? params.timeoutSeconds : undefined,
			isCancelled: () => shared.stopToken.stopped === true,
			onProgress: progress => {
				emitAgentEvent(shared, {
					type: "tool_progress",
					sessionId: shared.sessionId,
					taskId: shared.taskId,
					step: action.step,
					tool: action.tool,
					result: {
						success: false,
						...progress,
					},
				});
			},
		});
		if (result.success && mode === "lua") {
			let deterministicFailure = false;
			let deterministicPass = false;
			const outputLines = result.output.split("\n");
			for (let i = 0; i < outputLines.length && !deterministicFailure; i++) {
				const line = outputLines[i].trim().toLowerCase();
				if (line === "passed") deterministicPass = true;
				if (line === "failed") {
					deterministicFailure = true;
					break;
				}
				let searchFrom = 0;
				while (searchFrom < line.length) {
					const failedIndex = line.indexOf("failed", searchFrom);
					if (failedIndex < 0) break;
					let after = failedIndex + "failed".length;
					while (after < line.length) {
						const ch = line.slice(after, after + 1);
						if (ch !== " " && ch !== "\t" && ch !== ":" && ch !== "=") break;
						after++;
					}
					let afterEnd = after;
					while (afterEnd < line.length) {
						const ch = line.slice(afterEnd, afterEnd + 1);
						if (ch < "0" || ch > "9") break;
						afterEnd++;
					}
					let count: number | undefined;
					if (afterEnd > after) {
						count = Number(line.slice(after, afterEnd));
					} else {
						let before = failedIndex - 1;
						while (before >= 0) {
							const ch = line.slice(before, before + 1);
							if (ch !== " " && ch !== "\t" && ch !== ":" && ch !== "=") break;
							before--;
						}
						const beforeEnd = before + 1;
						while (before >= 0) {
							const ch = line.slice(before, before + 1);
							if (ch < "0" || ch > "9") break;
							before--;
						}
						if (beforeEnd > before + 1) count = Number(line.slice(before + 1, beforeEnd));
					}
					if ((count !== undefined && count > 0) || (count === undefined && failedIndex === 0)) {
						deterministicFailure = true;
						break;
					}
					searchFrom = failedIndex + "failed".length;
				}
			}
			if (deterministicFailure) {
				shared.failedTestNeedsBuild = true;
				shared.failedTestHasSourceEdit = false;
				shared.deterministicTestFailureCount = (shared.deterministicTestFailureCount ?? 0) + 1;
			} else if (deterministicPass) {
				shared.deterministicTestFailureCount = 0;
			}
		}
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
			disabledAgentTools: shared.disabledAgentTools,
		});
		if (!result.success) {
			return result as unknown as Record<string, unknown>;
		}
		shared.hasSpawnedSubAgentThisTask = true;
		return {
			success: true,
			sessionId: result.sessionId,
			taskId: result.taskId,
			title: result.title,
			hint: "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs.",
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
		const normalizedPath = normalizePolicyPath(path);
		const isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath);
		if (!isInternalDocumentEdit) {
			const preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr);
			if (preflightIssue !== undefined) {
				const targetExists = Content.exist(Path(shared.workingDir, normalizedPath));
				const recovery = oldStr === "" && !targetExists
					? " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch."
					: " Reissue the corrected coherent replacement; do not patch text that was never written.";
				return { success: false, message: preflightIssue + recovery };
			}
		}
		const actionNode = new EditFileAction(1, 0);
		const result = await actionNode.exec({
			path,
			oldStr,
			newStr,
			taskId: shared.taskId,
			workDir: shared.workingDir,
		});
		if (!isInternalDocumentEdit && result.success === true && result.changed !== false) {
			if (params.partialStreamRecovery !== true) {
				shared.truncatedToolOverwritePath = undefined;
			}
			shared.unbuiltEdits = true;
			shared.lastBuildSucceeded = false;
			if (shared.failedTestNeedsBuild === true) shared.failedTestHasSourceEdit = true;
			const editedPaths = shared.editedPathsSinceBuild ?? [];
			if (editedPaths.indexOf(normalizedPath) < 0) editedPaths.push(normalizedPath);
			shared.editedPathsSinceBuild = editedPaths;
			shared.editsSinceBuild = (shared.editsSinceBuild ?? 0) + 1;
		}
		return result;
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
	if (action.tool === "build") {
		return sanitizeBuildResultForHistory(result);
	}
	if (action.tool === "edit_file" || action.tool === "delete_file") {
		if (result.success !== true) return result;
		if (typeof result.checkpointId !== "number" || typeof result.checkpointSeq !== "number") return result;
		if (isArray(result.fileContext)) return result;

		const contextLimits = {
			fullContentChars: 12000,
			previewChars: 4000,
			diffChars: 8000,
			totalChars: 24000,
			maxFiles: 8,
		};
		function truncateContextSnippet(sourceText: string, maxChars: number, label: string): string {
			if (maxChars <= 0) return `...${label} omitted (${sourceText.length} chars total)...`;
			if (sourceText.length <= maxChars) return sourceText;
			const nextUtf8Offset = utf8.offset(sourceText, maxChars + 1);
			const visiblePrefix = nextUtf8Offset === undefined ? sourceText : string.sub(sourceText, 1, nextUtf8Offset - 1);
			return `${visiblePrefix}\n...${label} truncated (${sourceText.length} chars total)...`;
		}
		function countLines(sourceText: string): number {
			if (sourceText === "") return 0;
			return sourceText.split("\n").length;
		}
		function buildUnifiedDiffPreview(filePath: string, beforeContent: string, afterContent: string, maxChars: number): string {
			if (beforeContent === afterContent) return "";
			const beforeLines = beforeContent.split("\n");
			const afterLines = afterContent.split("\n");
			const unifiedDiffLines: string[] = [`--- ${filePath}`, `+++ ${filePath}`];
			let firstChangedLine = 0;
			while (
				firstChangedLine < beforeLines.length
				&& firstChangedLine < afterLines.length
				&& beforeLines[firstChangedLine] === afterLines[firstChangedLine]
			) {
				firstChangedLine += 1;
			}
			let lastChangedBeforeLine = beforeLines.length - 1;
			let lastChangedAfterLine = afterLines.length - 1;
			while (
				lastChangedBeforeLine >= firstChangedLine
				&& lastChangedAfterLine >= firstChangedLine
				&& beforeLines[lastChangedBeforeLine] === afterLines[lastChangedAfterLine]
			) {
				lastChangedBeforeLine -= 1;
				lastChangedAfterLine -= 1;
			}
			const previewStartLine = math.max(0, firstChangedLine - 3);
			const previewEndLine = math.max(
				math.min(beforeLines.length - 1, lastChangedBeforeLine + 3),
				math.min(afterLines.length - 1, lastChangedAfterLine + 3)
			);
			unifiedDiffLines.push(`@@ ${previewStartLine + 1} @@`);
			for (let lineIndex = previewStartLine; lineIndex <= previewEndLine; lineIndex++) {
				const beforeLine = lineIndex < beforeLines.length ? beforeLines[lineIndex] : undefined;
				const afterLine = lineIndex < afterLines.length ? afterLines[lineIndex] : undefined;
				const beforeChanged = lineIndex >= firstChangedLine && lineIndex <= lastChangedBeforeLine;
				const afterChanged = lineIndex >= firstChangedLine && lineIndex <= lastChangedAfterLine;
				if (!beforeChanged && !afterChanged) {
					const contextLine = afterLine !== undefined ? afterLine : beforeLine;
					if (contextLine !== undefined) unifiedDiffLines.push(` ${contextLine}`);
					continue;
				}
				if (beforeChanged && beforeLine !== undefined) unifiedDiffLines.push(`-${beforeLine}`);
				if (afterChanged && afterLine !== undefined) unifiedDiffLines.push(`+${afterLine}`);
			}
			return truncateContextSnippet(unifiedDiffLines.join("\n"), maxChars, "diff");
		}

		const checkpointDiff = Tools.getCheckpointDiff(result.checkpointId);
		if (!checkpointDiff.success) return result;
		let remainingContextBudget = contextLimits.totalChars;
		const fileContextItems: AgentFileContextItem[] = [];
		const changedFiles = checkpointDiff.files;
		const maxContextFiles = math.min(changedFiles.length, contextLimits.maxFiles);
		for (let fileIndex = 0; fileIndex < maxContextFiles; fileIndex++) {
			if (remainingContextBudget <= 0) break;
			const changedFile = changedFiles[fileIndex];
			const beforeContent = changedFile.beforeExists ? changedFile.beforeContent : "";
			const afterContent = changedFile.afterExists ? changedFile.afterContent : "";
			const contextItem: AgentFileContextItem = {
				path: changedFile.path,
				op: changedFile.op,
				checkpointId: result.checkpointId,
				checkpointSeq: result.checkpointSeq,
				beforeExists: changedFile.beforeExists,
				afterExists: changedFile.afterExists,
				beforeBytes: beforeContent.length,
				afterBytes: afterContent.length,
				diffPreview: "",
				lineCount: changedFile.afterExists ? countLines(afterContent) : 0,
				contentTruncated: false,
				fileListTruncated: changedFiles.length > contextLimits.maxFiles,
			};
			if (changedFile.afterExists) {
				if (afterContent.length <= contextLimits.fullContentChars && afterContent.length <= remainingContextBudget) {
					contextItem.afterContent = afterContent;
					remainingContextBudget -= afterContent.length;
				} else {
					contextItem.afterContentPreview = truncateContextSnippet(
						afterContent,
						math.min(contextLimits.previewChars, math.max(400, remainingContextBudget)),
						"afterContent"
					);
					remainingContextBudget -= contextItem.afterContentPreview.length;
					contextItem.contentTruncated = true;
				}
			}
			const diffPreview = buildUnifiedDiffPreview(
				changedFile.path,
				beforeContent,
				afterContent,
				math.min(contextLimits.diffChars, math.max(400, remainingContextBudget))
			);
			contextItem.diffPreview = diffPreview;
			remainingContextBudget -= diffPreview.length;
			if (!changedFile.afterExists && beforeContent !== "") {
				contextItem.beforeContentPreview = truncateContextSnippet(
					beforeContent,
					math.min(contextLimits.previewChars, math.max(400, remainingContextBudget)),
					"beforeContent"
				);
				remainingContextBudget -= contextItem.beforeContentPreview.length;
				if (beforeContent.length > contextLimits.previewChars) contextItem.contentTruncated = true;
			}
			fileContextItems.push(contextItem);
		}
		if (fileContextItems.length === 0) return result;
		return {
			...result,
			fileContext: fileContextItems,
			...(changedFiles.length > maxContextFiles ? { truncatedFileContextItems: changedFiles.length - maxContextFiles } : {}),
		};
	}

	return result;
}

function canRunBatchActionInParallel(this: unknown, action: AgentActionRecord): boolean {
	return AgentToolRegistry.canRunToolInParallel(action.tool);
}

interface ToolBatch {
	isConcurrencySafe: boolean;
	actions: AgentActionRecord[];
}

function partitionToolCalls(actions: AgentActionRecord[]): ToolBatch[] {
	const batches: ToolBatch[] = [];
	for (let i = 0; i < actions.length; i++) {
		const action = actions[i];
		const isSafe = canRunBatchActionInParallel(action);
		const lastBatch = batches.length > 0 ? batches[batches.length - 1] : undefined;
		if (isSafe && lastBatch && lastBatch.isConcurrencySafe) {
			lastBatch.actions.push(action);
		} else {
			batches.push({ isConcurrencySafe: isSafe, actions: [action] });
		}
	}
	return batches;
}

function completeStoppedToolAction(shared: AgentShared, action: AgentActionRecord): void {
	action.params = sanitizeActionParamsForHistory(action.tool, action.params);
	if (!action.result) {
		action.result = { success: false, message: getCancelledReason(shared) };
	}
	appendToolResultMessage(shared, action);
	emitAgentFinishEvent(shared, action);
	emitCheckpointEventForAction(shared, action);
}

class BatchToolAction extends Node<AgentShared> {
	async prep(shared: AgentShared): Promise<{ shared: AgentShared; actions: AgentActionRecord[] }> {
		return { shared, actions: shared.pendingToolActions ?? [] };
	}

	async exec(input: { shared: AgentShared; actions: AgentActionRecord[] }): Promise<AgentActionRecord[]> {
		const shared = input.shared;
		const spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask === true;
		const preExecuted = shared.preExecutedResults;
		const batches = partitionToolCalls(input.actions);
		const parallelBatchCount = batches.filter(b => b.isConcurrencySafe).length;
		const serialBatchCount = batches.filter(b => !b.isConcurrencySafe).length;
		AgentUtils.Log("Info", `[CodingAgent] smart batch partition total=${input.actions.length} parallel_batches=${parallelBatchCount} serial_batches=${serialBatchCount}`);

		for (let batchIdx = 0; batchIdx < batches.length; batchIdx++) {
			const batch = batches[batchIdx];
			if (shared.stopToken.stopped) {
				for (const action of batch.actions) {
					completeStoppedToolAction(shared, action);
				}
				continue;
			}

			if (batch.isConcurrencySafe && batch.actions.length > 1) {
				const preExecCount = batch.actions.filter(a => preExecuted?.has(a.toolCallId)).length;
				AgentUtils.Log("Info", `[CodingAgent] batch ${batchIdx + 1}/${batches.length} parallel count=${batch.actions.length} pre_executed=${preExecCount}`);
				for (let i = 0; i < batch.actions.length; i++) {
					emitAgentStartEvent(shared, batch.actions[i]);
				}
				await Promise.all(batch.actions.map(async action => {
					if (shared.stopToken.stopped) {
						action.result = { success: false, message: getCancelledReason(shared) };
						return action;
					}
					const result = await executeToolActionWithPreExecution(shared, action);
					action.params = sanitizeActionParamsForHistory(action.tool, action.params);
					action.result = sanitizeToolActionResultForHistory(action, result);
					return action;
				}));
				for (let i = 0; i < batch.actions.length; i++) {
					const action = batch.actions[i];
					if (!action.result) {
						action.result = { success: false, message: "tool did not produce a result" };
					}
					appendToolResultMessage(shared, action);
					emitAgentFinishEvent(shared, action);
					emitCheckpointEventForAction(shared, action);
				}
			} else {
				AgentUtils.Log("Info", `[CodingAgent] batch ${batchIdx + 1}/${batches.length} serial count=${batch.actions.length}`);
				for (let i = 0; i < batch.actions.length; i++) {
					const action = batch.actions[i];
					emitAgentStartEvent(shared, action);
					const result = await executeToolActionWithPreExecution(shared, action);
					action.params = sanitizeActionParamsForHistory(action.tool, action.params);
					action.result = sanitizeToolActionResultForHistory(action, result);
					appendToolResultMessage(shared, action);
					emitAgentFinishEvent(shared, action);
					emitCheckpointEventForAction(shared, action);
					persistHistoryState(shared);
					if (shared.stopToken.stopped) {
						for (let j = i + 1; j < batch.actions.length; j++) {
							completeStoppedToolAction(shared, batch.actions[j]);
						}
						break;
					}
				}
			}
		}
		let spawnSeen = spawnedBeforeBatch;
		let didDelegatedForegroundWork = false;
		for (let i = 0; i < input.actions.length; i++) {
			const action = input.actions[i];
			if (action.tool === "spawn_sub_agent") {
				if (action.result?.success === true) spawnSeen = true;
				continue;
			}
			if (spawnSeen && action.tool !== "finish") {
				didDelegatedForegroundWork = true;
			}
		}
		if (didDelegatedForegroundWork) {
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches ?? 0) + 1;
		}
		persistHistoryState(shared);
		return input.actions;
	}

	async post(shared: AgentShared, _prepRes: unknown, _execRes: unknown): Promise<string | undefined> {
		shared.pendingToolActions = undefined;
		shared.preExecutedResults = undefined;
		persistHistoryState(shared);
		await maybeCompressHistory(shared);
		persistHistoryState(shared);
		return shared.waitingQuestionnaireId !== undefined ? "done" : "main";
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
		const fetch = new FetchUrlAction(1, 0);
		const exec = new FetchUrlAction(1, 0);
		const batch = new BatchToolAction(1, 0);
		const done = new EndNode(1, 0);

		main.on("batch_tools", batch);
		main.on("grep_files", search);
		main.on("search_dora_api", searchDora);
		main.on("glob_files", list);
		main.on("fetch_url", fetch);
		main.on("execute_command", exec);
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
		batch.on("done", done);
		read.on("main", main);
		del.on("main", main);
		build.on("main", main);
		edit.on("main", main);
		fetch.on("main", main);
		exec.on("main", main);

		super(main);
	}
}

function emitAgentTaskFinishEvent(shared: AgentShared, success: boolean, message: string): CodingAgentRunResult {
	const completion = shared.completion ?? AgentUtils.normalizeAgentCompletionReport({
		outcome: success ? "completed" : "blocked",
		knownIssues: success ? [] : [message],
	});
	const result: CodingAgentRunResult = success
		? {
			success: true,
			taskId: shared.taskId,
			message,
			steps: shared.step,
			completion,
		}
		: {
			success: false,
			taskId: shared.taskId,
			message,
			steps: shared.step,
			completion,
		};
	emitAgentEvent(shared, {
		type: "task_finished",
		sessionId: shared.sessionId,
		taskId: shared.taskId,
		success: result.success,
		message: result.message,
		steps: result.steps,
		completion: result.completion,
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
		: AgentUtils.getActiveLLMConfig();
	if (!llmConfigRes.success) {
		return { success: false, message: llmConfigRes.message };
	}
	const llmConfig = llmConfigRes.config;
	const taskRes = options.taskId !== undefined
		? { success: true as const, taskId: options.taskId }
		: Tools.createTask(normalizedPrompt, options.workMode ?? "code");
	if (!taskRes.success) {
		return { success: false, message: taskRes.message };
	}
	// 创建 Memory 压缩器
	const compressor = new MemoryCompressor({
		compressionTargetThreshold: 0.5,
		maxCompressionRounds: 3,
		projectDir: options.workDir,
		llmConfig,
		promptPack: options.promptPack,
		scope: options.memoryScope,
	});
	const persistedSession = compressor.getStorage().readSessionState();
	let effectiveUserQuery = normalizedPrompt;
	if (options.resumeConversation === true) {
		for (let i = persistedSession.messages.length - 1; i >= 0; i--) {
			const message = persistedSession.messages[i];
			if (message.role === "user" && typeof message.content === "string" && message.content.trim() !== "") {
				effectiveUserQuery = message.content;
				break;
			}
		}
	}
	const promptPack = compressor.getPromptPack();
	const freshProject = inspectFreshProject(options.workDir);
	const freshProjectBuildPending = freshProject.fresh;
	const freshProjectCodeFile = freshProject.codeFile;

	const shared: AgentShared = {
		sessionId: options.sessionId,
		taskId: taskRes.taskId,
		role: options.role ?? "main",
		maxSteps: math.max(1, math.floor(options.maxSteps ?? AgentConfig.AGENT_DEFAULTS.maxSteps)),
		llmMaxTry: math.max(1, math.floor(options.llmMaxTry ?? AgentConfig.AGENT_DEFAULTS.llmMaxTry)),
		step: 0,
		done: false,
		stopToken: options.stopToken ?? { stopped: false },
		response: "",
		userQuery: effectiveUserQuery,
		workingDir: options.workDir,
		useChineseResponse: options.useChineseResponse === true,
		workMode: options.workMode ?? "code",
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
			loader: AgentSkills.createSkillsLoader({
				projectDir: options.workDir,
				disabledAgentTools: options.disabledAgentTools ?? [],
				allowedAgentTools: AgentToolRegistry.getAllowedToolsForRole(options.role ?? "main", {
					workMode: options.workMode ?? "code",
					disabledAgentTools: options.disabledAgentTools ?? [],
				}),
			}),
		},
		spawnSubAgent: options.spawnSubAgent,
		listSubAgents: options.listSubAgents,
		publishQuestionnaire: options.publishQuestionnaire,
		disabledAgentTools: options.disabledAgentTools ?? [],
		freshProjectBuildPending,
		freshProjectCodeFile,
		hasSpawnedSubAgentThisTask: false,
		delegatedForegroundBatches: 0,
	};

	try {
		if (shared.workMode === "plan") {
			const planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir);
			if (!planDocuments.success) {
				Tools.setTaskStatus(shared.taskId, "FAILED");
				return { success: false, taskId: shared.taskId, message: planDocuments.message };
			}
		}
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
		const promptCommand = options.resumeConversation === true ? undefined : getPromptCommand(shared.userQuery);
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
		await maybeCompressHistory(shared, true, options.resumeConversation === true ? "" : normalizedPrompt);
		if (shared.stopToken.stopped) {
			Tools.setTaskStatus(shared.taskId, "STOPPED");
			return emitAgentTaskFinishEvent(shared, false, getCancelledReason(shared));
		}
		if (options.resumeConversation !== true) {
			appendConversationMessage(shared, {
				role: "user",
				content: normalizedPrompt,
			});
			persistHistoryState(shared);
		}
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
		if (shared.waitingQuestionnaireId !== undefined) {
			Tools.setTaskStatus(shared.taskId, "WAITING_USER");
			emitAgentEvent(shared, {
				type: "task_waiting_for_user",
				sessionId: shared.sessionId,
				taskId: shared.taskId,
				step: shared.step,
				questionnaireId: shared.waitingQuestionnaireId,
			});
			return {
				success: true,
				taskId: shared.taskId,
				message: shared.useChineseResponse ? "等待用户填写调查问卷。" : "Waiting for questionnaire feedback.",
				steps: shared.step,
				waitingForUser: true,
				questionnaireId: shared.waitingQuestionnaireId,
			};
		}
		if (isFinalDecisionTurn(shared) && shared.completion?.outcome === "partial") {
			Tools.setTaskStatus(shared.taskId, "FAILED");
			return emitAgentTaskFinishEvent(shared, false,
				shared.response || (shared.useChineseResponse ? "本轮达到处理上限，工作尚未完成。" : "This task reached its processing limit with work remaining."));
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
