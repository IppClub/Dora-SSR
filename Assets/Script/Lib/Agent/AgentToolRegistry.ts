// @preview-file off clear
import { compileJsonSchema } from 'Agent/JsonSchema';
import { AGENT_TOOL_HANDLERS } from 'Agent/AgentToolHandlers';
import { AGENT_TOOL_VALIDATORS } from 'Agent/AgentToolValidation';
import type { JsonSchema, JsonSchemaObject, JsonSchemaType } from 'Agent/JsonSchema';
import type {
	AgentDecisionMode,
	AgentRole,
	AgentToolCapabilityOptions,
	AgentToolDefinition,
	AgentToolName,
	AgentToolParameterDefinition,
	AgentToolSchemaContext,
	AgentWorkMode,
} from 'Agent/AgentToolTypes';

export type {
	AgentDecisionMode,
	AgentRole,
	AgentToolCapabilityOptions,
	AgentToolDefinition,
	AgentToolName,
	AgentToolParameterDefinition,
	AgentToolSchemaContext,
	AgentWorkMode,
} from 'Agent/AgentToolTypes';

export type AgentFunctionToolSchema = {
	type: "function";
	function: {
		name: string;
		description: string;
		parameters: Record<string, unknown>;
	};
};

type AgentToolDefinitionSource = Omit<AgentToolDefinition, "inputSchema" | "outputSchema"> & {
	parameters?: AgentToolParameterDefinition[];
};

const DEFAULT_SCHEMA_CONTEXT: AgentToolSchemaContext = {
	searchDoraDocLimitMax: 20,
};

const DEFAULT_TOOL_OUTPUT_SCHEMA: JsonSchema = {
	type: "object",
	properties: {
		success: { type: "boolean" },
	},
	required: ["success"],
};

function resolveText(value: string | ((context: AgentToolSchemaContext) => string), context: AgentToolSchemaContext): string {
	return typeof value === "string" ? value : value(context);
}

function getToolDescription(tool: AgentToolDefinition, context: AgentToolSchemaContext): string {
	return resolveText(tool.description, context);
}

function getToolRules(tool: AgentToolDefinition, context: AgentToolSchemaContext): string[] {
	return (tool.rules ?? []).map(rule => resolveText(rule, context));
}

function getParameterDescription(parameter: AgentToolParameterDefinition, context: AgentToolSchemaContext): string {
	return resolveText(parameter.description, context);
}

function createInputSchemaFromParameters(
	parameters: AgentToolParameterDefinition[] | undefined,
	context: AgentToolSchemaContext
): JsonSchemaObject {
	const properties: Record<string, JsonSchema> = {};
	const required: string[] = [];
	for (const parameter of parameters ?? []) {
		const property: JsonSchemaObject = {
			type: parameter.type as JsonSchemaType,
			description: getParameterDescription(parameter, context),
		};
		if (parameter.enum !== undefined) {
			property.enum = parameter.enum;
		}
		if (parameter.items !== undefined) {
			property.items = parameter.items;
		}
		if (parameter.minItems !== undefined) property.minItems = parameter.minItems;
		properties[parameter.name] = property;
		if (parameter.required === true) {
			required.push(parameter.name);
		}
	}
	const schema: JsonSchemaObject = {
		type: "object",
		properties,
	};
	if (required.length > 0) {
		schema.required = required;
	}
	return schema;
}

function createFunctionToolSchemaFromDefinition(tool: AgentToolDefinition, context: AgentToolSchemaContext): AgentFunctionToolSchema {
	const parameters = tool.inputSchema(context);
	const rules = getToolRules(tool, context);
	return {
		type: "function",
		function: {
			name: tool.name,
			description: [getToolDescription(tool, context), ...rules].join(" "),
			parameters,
		},
	};
}

const AGENT_TOOL_DEFINITION_SOURCES: AgentToolDefinitionSource[] = [
	{
		name: "read_file",
		roles: ["main", "sub"],
		workModes: ["code", "plan"],
		description: "Read one or more independent file ranges in one call.",
		parameters: [
			{
				name: "reads", type: "array", required: true, minItems: 1,
				description: "Non-empty independent file ranges. Use one item for a single read. No artificial item limit; keep ranges narrow enough to remain useful in context.",
				items: {
					type: "object",
					properties: {
						path: { type: "string", description: "Workspace or virtual path to read." },
						startLine: { type: "number", description: "Starting line; defaults to 1." },
						endLine: { type: "number", description: "Ending line; default follows startLine." },
					},
					required: ["path"], additionalProperties: false,
				},
			},
		],
		rules: [
			"Always use reads, including for a single range. When several known files or ranges are needed before the next decision, put them in the same array.",
			"Batch ranges are independent and ordered. A failed read remains in results and does not discard successful reads.",
			"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.",
			"Read @dora_full_logs.txt to inspect the current Dora engine log snapshot; it is a read-only virtual path, not a workspace file.",
			"Paths returned by search_dora_doc are authoritative built-in documentation paths and can be read directly without modifying them.",
		],
		parallelSafe: true,
	},
	{
		name: "edit_file",
		roles: ["main", "sub"],
		workModes: ["code", "plan"],
		description: "Make one file edit, or apply an ordered best-effort batch of file edits in one call. A batch may use a shared top-level path.",
		parameters: [
			{ name: "path", type: "string", description: "Workspace-relative file path for the legacy single-edit form, or the default path for batch entries that omit path." },
			{ name: "old_str", type: "string", description: "Legacy single-edit form: existing text to replace. If empty, rewrite the whole file or create it when missing." },
			{ name: "new_str", type: "string", description: "Legacy single-edit form: replacement text or complete file content." },
			{
				name: "edits",
				type: "array",
				minItems: 1,
				description: "Best-effort batch form: a non-empty array of ordered edit objects. May target multiple files or the same file repeatedly; a same-file edit sees the staged result of earlier successful entries.",
				items: {
					type: "object",
					properties: {
						path: { type: "string", description: "Workspace-relative file path to edit. May be omitted when the batch supplies a top-level default path." },
						old_str: { type: "string", description: "Existing staged text to replace; empty rewrites or creates." },
						new_str: { type: "string", description: "Replacement or complete file content." },
					},
					required: ["old_str", "new_str"],
					additionalProperties: false,
				},
			},
		],
		rules: [
			"Use path + old_str + new_str for one edit; edits for a batch with per-entry paths; or path + edits when all or some batch entries share a default path. Do not combine edits with top-level old_str/new_str.",
			"Prefer one batch when several independent files or several known replacements can be changed coherently before the next build.",
			"Each batch entry succeeds or fails independently. Failed entries are reported and skipped; all successful staged results are committed together in one checkpoint.",
			"Repeated paths are allowed and execute in array order against content from earlier successful entries; the final successful content for each unique path is written once.",
			"old_str and new_str MUST be different.",
			"old_str must match existing text exactly when it is non-empty.",
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.",
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build.",
		],
	},
	{
		name: "delete_file",
		roles: ["main", "sub"],
		workModes: ["code", "plan"],
		description: "Remove a file.",
		parameters: [
			{ name: "target_file", type: "string", required: true, description: "Workspace-relative file path to delete." },
		],
	},
	{
		name: "grep_files",
		roles: ["main", "sub"],
		workModes: ["code", "plan"],
		description: "Search text patterns inside files.",
		parameters: [
			{ name: "path", type: "string", description: "Workspace directory, workspace file, or exact @dora-doc/... virtual document path to search within." },
			{ name: "pattern", type: "string", required: true, description: "Content pattern to search for. Use | to express OR alternatives." },
			{ name: "globs", type: "array", items: { type: "string" }, description: "Optional file glob filters." },
			{ name: "useRegex", type: "boolean", description: "Set true when pattern is a regular expression." },
			{ name: "caseSensitive", type: "boolean", description: "Set true for case-sensitive matching." },
			{ name: "limit", type: "number", description: "Maximum number of results to return." },
			{ name: "offset", type: "number", description: "Offset for paginating later result pages." },
			{ name: "groupByFile", type: "boolean", description: "Set true to rank candidate files before drilling into one file." },
		],
		rules: [
			"`path` may point to a workspace directory, workspace file, or an exact @dora-doc/... virtual document returned by search_dora_doc.",
			"This is content search (grep), not filename search.",
			"`pattern` matches file contents. `globs` only restrict which files are searched.",
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.",
			"`caseSensitive` defaults to false.",
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.",
			"Search results are intentionally capped. Refine the pattern or read a specific file next.",
		],
		parallelSafe: true,
	},
	{
		name: "glob_files",
		roles: ["main", "sub"],
		workModes: ["code", "plan"],
		description: "Enumerate files under a directory.",
		parameters: [
			{ name: "path", type: "string", description: "Base directory to enumerate. Defaults to the workspace root when omitted." },
			{ name: "globs", type: "array", items: { type: "string" }, description: "Optional glob filters for returned paths." },
			{ name: "maxEntries", type: "number", description: "Maximum number of entries to return." },
		],
		rules: [
			"Use this to discover files by path, extension, or glob pattern.",
			"Directory listings are intentionally capped. Narrow the path before expanding further.",
		],
		parallelSafe: true,
	},
	{
		name: "search_dora_doc",
		roles: ["main", "sub"],
		workModes: ["code", "plan"],
		description: "Search one authoritative Dora, LÖVE, or TIC-80 documentation set.",
		parameters: [
			{ name: "pattern", type: "string", required: true, description: "Query string to search for. Use | to express OR alternatives." },
			{ name: "docType", type: "string", enum: ["dora-tutorial", "dora-api", "love-api", "tic80-api"], description: "Exact documentation set to search. Defaults to dora-api." },
			{ name: "programmingLanguage", type: "string", enum: ["ts", "tsx", "lua", "yue", "teal", "tl", "wa"], description: "Preferred language variant to search." },
			{ name: "limit", type: "number", description: context => `Maximum number of matches to return, up to ${context.searchDoraDocLimitMax}.` },
			{ name: "useRegex", type: "boolean", description: "Set true when pattern is a regular expression." },
		],
		rules: [
			"`docType` defaults to `dora-api`; select `dora-tutorial`, `love-api`, or `tic80-api` explicitly when needed.",
			"Each type searches only its matching files: Dora tutorials, Dora API definitions excluding Love/TIC-80, love.d.*, or tic80.d.*.",
			"Every result file uses the @dora-doc/<docType>/... namespace; it is readable with read_file and searchable with grep_files using the exact virtual path.",
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.",
			"`useRegex` defaults to false whenever supported by a search tool.",
			context => `\`limit\` restricts each individual pattern search and must be <= ${context.searchDoraDocLimitMax}.`,
		],
		parallelSafe: true,
	},
	{
		name: "build",
		roles: ["main", "sub"],
		workModes: ["code"],
		description: "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.",
		parameters: [
			{ name: "paths", type: "array", required: true, minItems: 1, items: { type: "string" }, description: "Independent files or directories to build sequentially in one call. Use one item for a single target and '.' for the project root." },
		],
		rules: [
			"Always use paths, including for a single target. Use paths: ['.'] to build the project root.",
			"Prefer one directory target when edited files share a root. Otherwise put all targets in one paths array.",
			"Batch targets build sequentially and best-effort. A failed target does not discard earlier successful build results.",
			"Read the result and then decide whether another action is needed.",
		],
	},
	{
		name: "fetch_url",
		roles: ["main", "sub"],
		workModes: ["code"],
		description: "Download a single HTTP or HTTPS resource into the project.",
		parameters: [
			{ name: "url", type: "string", required: true, description: "HTTP or HTTPS URL to download. Other schemes are rejected." },
			{ name: "target", type: "string", required: true, description: "Workspace-relative target file path. The target must not already exist." },
		],
		rules: [
			"This tool is available only when the user enables fetch_url for the current Agent task.",
			"Targets must stay inside the current project and existing files or directories are not overwritten.",
			"Local, private, metadata, and literal-IP destinations are rejected. Downloads are limited to 32 MiB.",
			"This tool writes to a temporary file first, then moves it into place only after the GET succeeds.",
		],
	},
	{
		name: "execute_command",
		roles: ["main", "sub"],
		workModes: ["code"],
		description: "Execute a controlled engine command.",
		parameters: [
			{ name: "mode", type: "string", required: true, enum: ["lua", "git"], description: "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." },
			{ name: "code", type: "string", description: "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result." },
			{ name: "command", type: "string", description: "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported." },
			{ name: "cwd", type: "string", description: "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C." },
			{ name: "timeoutSeconds", type: "number", description: "Optional total command timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode also interrupts a command thread that occupies one game frame for 5 seconds, but cannot interrupt a blocking native call." },
		],
		rules: [
			"This tool is available only when the user enables command execution for the current Agent task.",
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.",
			"Lua mode runs with a temporary environment whose global writes stay in that one command. DB, HttpClient, HttpServer, and Content write operations are unavailable. Content supports only project-relative exist, isdir, getAttr, and load operations.",
			"Lua command code is checked every 10,000 VM instructions against App.elapsedTime. A command thread that occupies one game frame for 5 seconds is interrupted; time spent yielded across frames does not accumulate toward this per-frame limit, and blocking native calls remain non-interruptible.",
			"Lua mode exposes projectDir, reportProgress(update), refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). reportProgress accepts a table with progress from 0 to 1 plus optional stage and message. getEntryStatus() returns a table containing success and running booleans.",
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.",
			"An Entry watchdog checks live Dora object and Lua-reference growth every frame and from the Lua instruction hook. Growth of 50,000 C++ objects or 10,000 Lua references stops the test, runs Entry cleanup, and returns the measured growth; replace such tests with bounded entities and fixed simulation steps.",
			"After a Lua command finishes, the Web IDE resource tree is refreshed automatically whenever the command accessed Content and did not call refreshTree itself, including commands that later fail, are canceled, or time out. Pure computation commands do not refresh the tree. refreshTree(\"relative/file\") or refreshTree() remains available for explicit updates.",
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.",
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.",
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.",
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.",
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten.",
			"Git clone rejects local, private, metadata, and literal-IP destinations and discards repositories larger than 128 MiB.",
			"The Web IDE resource tree is refreshed automatically after every successful Git command.",
		],
	},
	{
		name: "finish",
		roles: ["main", "sub"],
		workModes: ["code", "plan"],
		description: "End the task and provide a structured completion handoff.",
		parameters: [
			{ name: "message", type: "string", required: true, description: "Final user-facing answer." },
			{ name: "outcome", type: "string", enum: ["completed", "partial", "blocked"], description: "Work outcome. Sub agents must provide this; defaults to completed for compatibility." },
			{
				name: "validation", type: "array", items: {
					type: "object",
					properties: {
						kind: { type: "string", enum: ["build", "runtime", "manual"] },
						result: { type: "string", enum: ["passed", "failed", "not_run"] },
						evidence: { type: "array", items: { type: "string" } },
					},
					required: ["kind", "result"],
				}, description: "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."
			},
			{ name: "knownIssues", type: "array", items: { type: "string" }, description: "Known remaining issues or blockers. Sub agents must provide an array, which may be empty." },
			{ name: "assumptions", type: "array", items: { type: "string" }, description: "Material assumptions made during the work. Sub agents must provide an array, which may be empty." },
			{
				name: "learningCandidates", type: "array", items: {
					type: "object",
					properties: {
						claim: { type: "string" },
						scope: { type: "string", enum: ["file", "project", "engine"] },
						evidence: { type: "array", items: { type: "string" } },
						confidence: { type: "string", enum: ["observed", "inferred"] },
					},
					required: ["claim", "scope", "confidence"],
				}, description: "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."
			},
		],
		rules: [
			"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.",
			"Do not claim validation passed without concrete evidence from the corresponding tool result.",
			"Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration.",
		],
	},
	{
		name: "list_sub_agents",
		roles: ["main"],
		workModes: ["code"],
		description: "Query sub-agent state under the current main session.",
		parameters: [
			{ name: "status", type: "string", enum: ["active_or_recent", "running", "done", "failed", "all"], description: "Optional status filter. Defaults to active_or_recent." },
			{ name: "limit", type: "number", description: "Maximum number of items to return. Defaults to 5." },
			{ name: "offset", type: "number", description: "Offset for paging older items." },
			{ name: "query", type: "string", description: "Optional text filter matched against title, goal, or summary." },
		],
		rules: [
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.",
			"status defaults to active_or_recent and may also be running, done, failed, or all.",
			"limit defaults to a small recent window. Use offset to page older items.",
			"query filters by title, goal, or summary text.",
			"After any successful spawn_sub_agent in the current task, this tool is unavailable for the rest of that task. Finish the turn instead; completion arrives through an asynchronous handoff.",
		],
		parallelSafe: true,
	},
	{
		name: "spawn_sub_agent",
		roles: ["main"],
		workModes: ["code"],
		description: "Create and start a sub agent session for delegated implementation work.",
		parameters: [
			{ name: "title", type: "string", required: true, description: "Short tab title for the sub agent." },
			{ name: "prompt", type: "string", required: true, description: "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known." },
			{ name: "expectedOutput", type: "string", description: "Optional expected result summary." },
			{ name: "filesHint", type: "array", items: { type: "string" }, description: "Optional likely files or directories involved." },
		],
		rules: [
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.",
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.",
			"The spawned sub agent inherits the current session tool capabilities.",
			"title should be short and specific.",
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.",
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.",
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish the current turn and return control to the user while the sub agents keep running.",
			"After a successful spawn in the current task, do not call list_sub_agents, wait, join, or poll. Completion is delivered asynchronously as a later handoff.",
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.",
			"filesHint is an optional list of likely files or directories.",
		],
	},
	{
		name: "ask_user",
		roles: ["main"],
		workModes: ["plan"],
		description: "Present a structured questionnaire and pause the Plan task until the user submits every required answer.",
		parameters: [
			{ name: "title", type: "string", required: true, description: "Short questionnaire title." },
			{ name: "description", type: "string", description: "Optional context shown above the questions." },
			{
				name: "questions",
				type: "array",
				required: true,
				description: "One to eight questions. Use single_choice, multiple_choice, or text. A single-choice question may recommend at most one option.",
				items: {
					type: "object",
					properties: {
						id: { type: "string" },
						prompt: { type: "string" },
						description: { type: "string" },
						type: { type: "string", enum: ["single_choice", "multiple_choice", "text"] },
						required: { type: "boolean" },
						options: {
							type: "array",
							items: {
								type: "object",
								properties: {
									id: { type: "string" },
									label: { type: "string" },
									description: { type: "string" },
									recommended: { type: "boolean", description: "Mark an option as recommended. Use at most one for single_choice; multiple_choice may mark any recommended set." },
								},
								required: ["id", "label"],
							},
						},
						placeholder: { type: "string" },
					},
					required: ["id", "prompt", "type"],
				},
			},
		],
		rules: [
			"Inspect the project before asking; do not ask for facts available through read_file, grep_files, glob_files, or search_dora_doc.",
			"ask_user has no document-update prerequisite. Incorporate the answers into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish.",
			"For single_choice, mark at most one option recommended. For multiple_choice, recommended options form a suggested set.",
			"ask_user must be the only tool call in the response.",
			"The task pauses after the questionnaire is published and continues after the user submits answers or dismisses it.",
			"An answered or dismissed ask_user tool result contains authoritative user feedback. Apply answers when present; when dismissed, continue with reasonable assumptions and do not mechanically repeat the same questionnaire.",
		],
	},
];

function formatSchemaErrors(errors: { schemaPath: string; message: string }[]): string {
	return errors.map(item => `${item.schemaPath !== "" ? item.schemaPath : "/"}: ${item.message}`).join("; ");
}

function createToolDefinition(source: AgentToolDefinitionSource): AgentToolDefinition {
	const definition: AgentToolDefinition = {
		...source,
		inputSchema: context => createInputSchemaFromParameters(source.parameters, context),
		outputSchema: DEFAULT_TOOL_OUTPUT_SCHEMA,
		handler: AGENT_TOOL_HANDLERS[source.name],
		validateInput: AGENT_TOOL_VALIDATORS[source.name],
	};
	const inputResult = compileJsonSchema(definition.inputSchema(DEFAULT_SCHEMA_CONTEXT));
	if (!inputResult.success) {
		throw new Error(`Invalid input schema for ${definition.name}: ${formatSchemaErrors(inputResult.errors)}`);
	}
	const outputResult = compileJsonSchema(definition.outputSchema);
	if (!outputResult.success) {
		throw new Error(`Invalid output schema for ${definition.name}: ${formatSchemaErrors(outputResult.errors)}`);
	}
	return definition;
}

export const AGENT_TOOL_DEFINITIONS: AgentToolDefinition[] = AGENT_TOOL_DEFINITION_SOURCES.map(source => createToolDefinition(source));

function hasRole(tool: AgentToolDefinition, role: AgentRole): boolean {
	return tool.roles.indexOf(role) >= 0;
}

function hasWorkMode(tool: AgentToolDefinition, workMode: AgentWorkMode): boolean {
	return tool.workModes.indexOf(workMode) >= 0;
}

export function getToolDefinition(name: string): AgentToolDefinition | undefined {
	for (const tool of AGENT_TOOL_DEFINITIONS) {
		if (tool.name === name) return tool;
	}
	return undefined;
}

function isToolCapabilityEnabled(tool: AgentToolDefinition, options?: AgentToolCapabilityOptions): boolean {
	if (!isKnownToolName(tool.name)) return false;
	return hasWorkMode(tool, options?.workMode ?? "code")
		&& (options?.disabledAgentTools ?? []).indexOf(tool.name as AgentToolName) < 0;
}

function formatParameterList(tool: AgentToolDefinition): string {
	const parameters = tool.parameters ?? [];
	if (parameters.length === 0) return "";
	return parameters
		.map(parameter => parameter.required === true ? parameter.name : `${parameter.name}(optional)`)
		.join(", ");
}

function formatToolPrompt(tool: AgentToolDefinition, index: number, context: AgentToolSchemaContext): string {
	const lines = [`${index + 1}. ${tool.name}: ${getToolDescription(tool, context)}`];
	const parameterList = formatParameterList(tool);
	if (parameterList !== "") {
		lines.push(`\t- Parameters: ${parameterList}`);
	}
	for (const parameter of tool.parameters ?? []) {
		const label = parameter.required === true ? parameter.name : `${parameter.name}(optional)`;
		lines.push(`\t- ${label}: ${getParameterDescription(parameter, context)}`);
	}
	for (const rule of getToolRules(tool, context)) {
		lines.push(`\t- ${rule}`);
	}
	return lines.join("\n");
}

function formatXMLRepairToolReference(tool: AgentToolDefinition): string {
	const parameterList = formatParameterList(tool);
	const params = parameterList !== "" ? parameterList : "none";
	const reason = tool.name === "finish" ? "no reason tag" : "reason tag required";
	return `- ${tool.name}: params: ${params}; ${reason}`;
}

export function isKnownToolName(name: string): name is AgentToolName {
	return getToolDefinition(name) !== undefined;
}

export function getAllowedToolsForRole(role: AgentRole, options?: AgentToolCapabilityOptions): AgentToolName[] {
	return AGENT_TOOL_DEFINITIONS
		.filter(tool => hasRole(tool, role) && isKnownToolName(tool.name) && isToolCapabilityEnabled(tool, options))
		.map(tool => tool.name as AgentToolName);
}

export function buildCurrentToolAvailabilityGuidance(): string {
	return [
		"Current tool availability:",
		"- every tool defined in the current system prompt or exposed in the current tool schema is executable",
		"- capabilities disabled for this task are omitted from both the definitions and schema",
	].join("\n");
}

export function getToolDefinitionsForRole(role: AgentRole, options?: {
	includeFinish?: boolean;
	disabledAgentTools?: AgentToolName[];
	workMode?: AgentWorkMode;
}): AgentToolDefinition[] {
	return AGENT_TOOL_DEFINITIONS.filter(tool =>
		hasRole(tool, role)
		&& (options?.includeFinish === true || tool.name !== "finish")
		&& isToolCapabilityEnabled(tool, options)
	);
}

const SUB_AGENT_REQUIRED_FINISH_PARAMS = [
	"message",
	"outcome",
	"validation",
	"knownIssues",
	"assumptions",
	"learningCandidates",
];

function getDecisionToolDefinitionsForRole(role: AgentRole, options?: {
	includeFinish?: boolean;
	disabledAgentTools?: AgentToolName[];
	workMode?: AgentWorkMode;
}): AgentToolDefinition[] {
	const tools = getToolDefinitionsForRole(role, options);
	if (role !== "sub") return tools;
	return tools.map(tool => {
		if (tool.name !== "finish") return tool;
		const parameters = (tool.parameters ?? []).map(parameter => ({
			...parameter,
			required: SUB_AGENT_REQUIRED_FINISH_PARAMS.indexOf(parameter.name) >= 0,
		}));
		return {
			...tool,
			parameters,
			inputSchema: context => createInputSchemaFromParameters(parameters, context),
		};
	});
}

export function buildToolDefinitionsDetailed(tools: AgentToolDefinition[], options?: {
	title?: string;
	includeXmlRules?: boolean;
	context?: AgentToolSchemaContext;
}): string {
	const title = options?.title !== undefined ? options.title : "Available tools:";
	const context = options?.context ?? DEFAULT_SCHEMA_CONTEXT;
	const sections: string[] = tools.map((tool, index) => formatToolPrompt(tool, index, context));
	if (options?.includeXmlRules === true) {
		const reasonTools = tools
			.filter(tool => tool.name !== "finish")
			.map(tool => tool.name)
			.join(", ");
		sections.push(`XML mode object fields:
- Use a single root tag: <tool_call>.
- For ${reasonTools !== "" ? reasonTools : "tools other than finish"}, include <tool>, <reason>, and <params>.
- For finish, omit <reason> and include <message> plus every other required parameter shown above inside <params>.
- Inside <params>, use one child tag per parameter and preserve each tag content as raw text.`);
	}
	const body = sections.join("\n\n");
	return title !== "" ? `${title}\n${body}` : body;
}

export function buildRoleToolDefinitionsDetailed(role: AgentRole, options?: {
	includeFinish?: boolean;
	includeXmlRules?: boolean;
	title?: string;
	context?: AgentToolSchemaContext;
	disabledAgentTools?: AgentToolName[];
	workMode?: AgentWorkMode;
}): string {
	return buildToolDefinitionsDetailed(
		getDecisionToolDefinitionsForRole(role, {
			includeFinish: options?.includeFinish,
			disabledAgentTools: options?.disabledAgentTools,
			workMode: options?.workMode,
		}),
		{
			title: options?.title,
			includeXmlRules: options?.includeXmlRules,
			context: options?.context,
		}
	);
}

export function buildXMLRepairToolReference(role: AgentRole, options?: AgentToolCapabilityOptions): string {
	const tools = getToolDefinitionsForRole(role, {
		includeFinish: true,
		disabledAgentTools: options?.disabledAgentTools,
		workMode: options?.workMode,
	});
	const lines = [
		"Allowed tools and XML params:",
		...tools.map(tool => formatXMLRepairToolReference(tool)),
		"",
		"XML shape:",
		"- Wrap the decision in exactly one <tool_call> root.",
		"- For tools except finish: include <tool>, <reason>, and <params>.",
		"- For finish: include <tool>, omit <reason>, and include <message> plus every other required parameter shown above inside <params>.",
		"- Inside <params>, use one child tag per parameter name above.",
	];
	return lines.join("\n");
}

export const AGENT_TOOL_DEFINITIONS_DETAILED = buildToolDefinitionsDetailed(
	getToolDefinitionsForRole("sub"),
	{ title: "Available tools:" }
);

export const MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" + buildToolDefinitionsDetailed(
	getToolDefinitionsForRole("main")
		.filter(tool => getToolDefinitionsForRole("sub").map(subTool => subTool.name).indexOf(tool.name) < 0),
	{ title: "" }
);

export const XML_TOOL_DEFINITIONS_DETAILED = "\n\n" + buildToolDefinitionsDetailed(
	AGENT_TOOL_DEFINITIONS.filter(tool => tool.name === "finish"),
	{ title: "", includeXmlRules: true }
);

export function canPreExecuteTool(tool: AgentToolName): boolean {
	const definition = getToolDefinition(tool);
	return definition?.preExecutable === true;
}

export function canRunToolInParallel(tool: AgentToolName): boolean {
	const definition = getToolDefinition(tool);
	return definition?.parallelSafe === true;
}

export function buildDecisionToolSchema(role: AgentRole, searchDoraDocLimitMax: number, options?: AgentToolCapabilityOptions) {
	const context = { searchDoraDocLimitMax };
	return buildDecisionToolSchemaForTools(getDecisionToolDefinitionsForRole(role, {
		includeFinish: true,
		disabledAgentTools: options?.disabledAgentTools,
		workMode: options?.workMode,
	}), context);
}

export function buildDecisionToolSchemaForTools(tools: AgentToolDefinition[], context: AgentToolSchemaContext) {
	return tools
		.map(tool => createFunctionToolSchemaFromDefinition(tool, context));
}
