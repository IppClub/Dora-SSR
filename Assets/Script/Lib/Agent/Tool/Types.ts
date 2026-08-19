// @preview-file off clear
import type { AgentCompletionReport, StopToken } from 'Agent/Utils';
import type { JsonSchema, JsonSchemaObject } from 'Agent/JsonSchema';

export type AgentDecisionMode = "tool_calling" | "xml";
export type AgentRole = "main" | "sub";
export type AgentWorkMode = "code" | "plan";

export type AgentToolName =
	| "read_file"
	| "edit_file"
	| "delete_file"
	| "grep_files"
	| "search_dora_doc"
	| "glob_files"
	| "build"
	| "fetch_url"
	| "execute_command"
	| "list_sub_agents"
	| "spawn_sub_agent"
	| "ask_user"
	| "finish";

export interface AgentToolSchemaContext {
	searchDoraDocLimitMax: number;
}

export interface AgentToolCapabilityOptions {
	disabledAgentTools?: AgentToolName[];
	workMode?: AgentWorkMode;
}

export interface AgentToolParameterDefinition {
	name: string;
	type: string;
	description: string | ((context: AgentToolSchemaContext) => string);
	required?: boolean;
	enum?: string[];
	items?: JsonSchema;
	minItems?: number;
}

export interface AgentToolControl {
	concludeTask?: boolean;
	finalMessage?: string;
	completion?: AgentCompletionReport;
	waitForUser?: boolean;
	questionnaireId?: number;
	spawnedSubAgent?: boolean;
}

export interface AgentToolHandlerResult {
	output: Record<string, unknown>;
	control?: AgentToolControl;
}

export type AgentToolSemanticValidationResult =
	| { success: true; value: Record<string, unknown> }
	| { success: false; message: string };

export type AgentToolInputValidator = (
	this: void,
	value: Record<string, unknown>
) => AgentToolSemanticValidationResult;

export interface AgentToolDefinition {
	name: AgentToolName;
	roles: AgentRole[];
	workModes: AgentWorkMode[];
	description: string | ((context: AgentToolSchemaContext) => string);
	parameters?: AgentToolParameterDefinition[];
	rules?: (string | ((context: AgentToolSchemaContext) => string))[];
	inputSchema: (context: AgentToolSchemaContext) => JsonSchemaObject;
	outputSchema: JsonSchema;
	validateInput?: AgentToolInputValidator;
	preExecutable?: boolean;
	parallelSafe?: boolean;
	timeoutSeconds?: number;
	handler?: AgentToolHandler;
}

export interface AgentToolCancellation {
	readonly stopToken: StopToken;
	isCancelled(): boolean;
	reason(): string | undefined;
}

export interface AgentToolProgressEvent {
	success: false;
	[key: string]: unknown;
}

export interface AgentToolSpawnRequest {
	parentSessionId: number;
	projectRoot?: string;
	title: string;
	prompt: string;
	expectedOutput?: string;
	filesHint?: string[];
	disabledAgentTools?: AgentToolName[];
}

export type AgentToolSpawnResult =
	| { success: true; sessionId: number; taskId: number; title: string }
	| { success: false; message: string };

export interface AgentToolListSubAgentsRequest {
	sessionId: number;
	projectRoot?: string;
	status?: string;
	limit?: number;
	offset?: number;
	query?: string;
}

export type AgentToolListSubAgentsResult =
	| {
		success: true;
		rootSessionId: number;
		maxConcurrent: number;
		status: string;
		limit: number;
		offset: number;
		hasMore: boolean;
		sessions: Record<string, unknown>[];
	}
	| { success: false; message: string };

export interface AgentToolPublishQuestionnaireRequest {
	sessionId: number;
	taskId: number;
	step: number;
	schema: Record<string, unknown>;
}

export type AgentToolPublishQuestionnaireResult =
	| { success: true; questionnaireId: number }
	| { success: false; message: string };

export interface AgentToolServices {
	spawnSubAgent?: (request: AgentToolSpawnRequest) => Promise<AgentToolSpawnResult>;
	listSubAgents?: (request: AgentToolListSubAgentsRequest) => Promise<AgentToolListSubAgentsResult>;
	publishQuestionnaire?: (request: AgentToolPublishQuestionnaireRequest) => Promise<AgentToolPublishQuestionnaireResult>;
}

export interface AgentToolWorkflowState {
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
	/** A project with no meaningful code should prefer an early implementation and build. */
	freshProjectBuildPending?: boolean;
	/** The only short code file found when freshProjectBuildPending was detected. */
	freshProjectCodeFile?: string;
	/** A successful spawn makes list_sub_agents a discouraged polling path for this task. */
	hasSpawnedSubAgentThisTask?: boolean;
	/** Number of foreground tool batches completed after the first successful spawn. */
	delegatedForegroundBatches?: number;
	/** Questionnaire currently blocking the task until user feedback arrives. */
	waitingQuestionnaireId?: number;
}

export interface AgentToolExecutionContext {
	sessionId?: number;
	taskId: number;
	step: number;
	workingDir: string;
	role: AgentRole;
	workMode: AgentWorkMode;
	useChineseResponse: boolean;
	disabledAgentTools: AgentToolName[];
	cancellation: AgentToolCancellation;
	emitProgress(result: AgentToolProgressEvent): void;
	services: AgentToolServices;
	workflow: AgentToolWorkflowState;
}

export type AgentToolHandler = (
	context: AgentToolExecutionContext,
	input: Record<string, unknown>
) => Promise<AgentToolHandlerResult>;
