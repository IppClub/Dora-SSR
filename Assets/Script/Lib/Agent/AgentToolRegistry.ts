// @preview-file off clear

export type AgentDecisionMode = "tool_calling" | "xml";
export type AgentRole = "main" | "sub";
export type AgentWorkMode = "code" | "plan";

export type AgentToolName =
	| "read_file"
	| "edit_file"
	| "delete_file"
	| "grep_files"
	| "search_dora_api"
	| "glob_files"
	| "build"
	| "fetch_url"
	| "execute_command"
	| "list_sub_agents"
	| "spawn_sub_agent"
	| "ask_user"
	| "finish";

const BUILT_IN_AGENT_TOOL_NAMES: AgentToolName[] = [
	"read_file",
	"edit_file",
	"delete_file",
	"grep_files",
	"search_dora_api",
	"glob_files",
	"build",
	"fetch_url",
	"execute_command",
	"list_sub_agents",
	"spawn_sub_agent",
	"ask_user",
	"finish",
];

export type AgentFunctionToolSchema = {
	type: "function";
	function: {
		name: string;
		description: string;
		parameters: Record<string, unknown>;
	};
};

export interface AgentToolSchemaContext {
	searchDoraApiLimitMax: number;
}

export interface AgentToolCapabilityOptions {
	disabledAgentTools?: AgentToolName[];
	workMode?: AgentWorkMode;
}

export interface AgentToolAvailabilityContext {
	role: AgentRole;
	workMode: AgentWorkMode;
	taskDisabledAgentTools: AgentToolName[];
	currentDisabledAgentTools: AgentToolName[];
	resumeRequiredTool?: AgentToolName;
	hasSpawnedSubAgentThisTask?: boolean;
	delegatedForegroundBudgetExhausted?: boolean;
	freshProjectBuildPending?: boolean;
	freshProjectCodeFile?: string;
	freshProjectHasAuthoredEdit?: boolean;
	buildRepairPending?: boolean;
	lastBuildSucceeded?: boolean;
	editBudgetExhausted?: boolean;
	repeatedDeterministicTestFailure?: boolean;
}

export interface ToolParameterPrompt {
	name: string;
	type: string;
	description: string | ((context: AgentToolSchemaContext) => string);
	required?: boolean;
	enum?: string[];
	items?: Record<string, unknown>;
}

export interface ToolPrompt {
	name: string;
	roles: AgentRole[];
	workModes: AgentWorkMode[];
	description: string | ((context: AgentToolSchemaContext) => string);
	parameters?: ToolParameterPrompt[];
	rules?: (string | ((context: AgentToolSchemaContext) => string))[];
	schema?: (context: AgentToolSchemaContext) => AgentFunctionToolSchema;
	preExecutable?: boolean;
	parallelSafe?: boolean;
}

export function findUnsupportedDoraTsEdit(path: string, newStr: string): string | undefined {
	const normalized = path.toLowerCase();
	if (!(normalized.endsWith(".ts") || normalized.endsWith(".tsx")) || normalized.endsWith(".d.ts")) return undefined;
	const isTestFile = normalized.endsWith("test.ts") || normalized.endsWith("test.tsx");
	const checks: Array<[string, string]> = [
		["Math.random", "inject a deterministic RNG or use supported bounded arithmetic"],
		["Math.hypot", "use Math.sqrt(x * x + y * y)"],
		["Math.imul", "use ordinary bounded multiplication"],
		["KeyName.Enter", "use a declared Dora KeyName such as Space, Up, A, D, Left, or Right"],
		["ReturnType<typeof", "annotate Dora factory instances with X.Type"],
	];
	const lines = newStr.split("\n");
	for (let i = 0; i < lines.length; i++) {
		const trimmed = lines[i].trim();
		if (trimmed.startsWith("//") || trimmed.startsWith("/*") || trimmed.startsWith("*")) continue;
		const uncommented = lines[i].split("//")[0] ?? "";
		let code = "";
		let quote = "";
		let escaped = false;
		for (let j = 0; j < uncommented.length; j++) {
			const char = uncommented[j];
			if (quote !== "") {
				if (escaped) escaped = false;
				else if (char === "\\") escaped = true;
				else if (char === quote) quote = "";
				code += " ";
			} else if (char === "\"" || char === "'" || char === "`") {
				quote = char;
				code += " ";
			} else {
				code += char;
			}
		}
		for (const [token, replacement] of checks) {
			if (code.indexOf(token) >= 0) {
				return `${token} is unsupported in Dora TypeScript; ${replacement}. The edit was not applied. Correct this replacement before continuing.`;
			}
		}
		if (isTestFile) {
			const compactCode = code.split(" ").join("").split("\t").join("");
			if (compactCode.indexOf("||true") >= 0 || compactCode.indexOf("check(true") >= 0 || compactCode.indexOf("assert(true") >= 0) {
				return "Vacuous always-true assertions are not allowed in authored test files. Replace the tautology with a deterministic observable condition that can fail. The edit was not applied.";
			}
		}
	}
	return undefined;
}

function resolveText(value: string | ((context: AgentToolSchemaContext) => string), context: AgentToolSchemaContext): string {
	return typeof value === "string" ? value : value(context);
}

function getToolDescription(tool: ToolPrompt, context: AgentToolSchemaContext): string {
	return resolveText(tool.description, context);
}

function getToolRules(tool: ToolPrompt, context: AgentToolSchemaContext): string[] {
	return (tool.rules ?? []).map(rule => resolveText(rule, context));
}

function getParameterDescription(parameter: ToolParameterPrompt, context: AgentToolSchemaContext): string {
	return resolveText(parameter.description, context);
}

function createFunctionToolSchemaFromPrompt(tool: ToolPrompt, context: AgentToolSchemaContext): AgentFunctionToolSchema {
	const properties: Record<string, unknown> = {};
	const required: string[] = [];
	for (const parameter of tool.parameters ?? []) {
		const property: Record<string, unknown> = {
			type: parameter.type,
			description: getParameterDescription(parameter, context),
		};
		if (parameter.enum !== undefined) {
			property.enum = parameter.enum;
		}
		if (parameter.items !== undefined) {
			property.items = parameter.items;
		}
		properties[parameter.name] = property;
		if (parameter.required === true) {
			required.push(parameter.name);
		}
	}
	const parameters: Record<string, unknown> = {
		type: "object",
		properties,
	};
	if (required.length > 0) {
		parameters.required = required;
	}
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

export const AGENT_TOOL_PROMPTS: ToolPrompt[] = [
	{
		name: "read_file",
		roles: ["main", "sub"],
		workModes: ["code", "plan"],
		description: "Read a specific line range from a file.",
		parameters: [
			{ name: "path", type: "string", required: true, description: "Workspace-relative file path to read, or an exact @dora-doc/... path returned by search_dora_api." },
			{ name: "startLine", type: "number", description: "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid." },
			{ name: "endLine", type: "number", description: "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid." },
		],
		rules: [
			"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.",
			"Paths returned by search_dora_api are authoritative built-in documentation paths and can be read directly without modifying them.",
		],
		parallelSafe: true,
	},
	{
		name: "edit_file",
		roles: ["main", "sub"],
		workModes: ["code", "plan"],
		description: "Make changes to a file.",
		parameters: [
			{ name: "path", type: "string", required: true, description: "Workspace-relative file path to edit." },
			{ name: "old_str", type: "string", required: true, description: "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing." },
			{ name: "new_str", type: "string", required: true, description: "Replacement text or the full file content when rewriting or creating." },
		],
		rules: [
			"old_str and new_str MUST be different.",
			"old_str must match existing text exactly when it is non-empty.",
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.",
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build.",
			"For Dora .ts/.tsx source, the engine rejects known unsupported constructs before writing: Math.random, Math.hypot, Math.imul, KeyName.Enter, and ReturnType<typeof DoraFactory>. Inject or implement a bounded RNG, use supported arithmetic/key names, and annotate Dora instances with X.Type.",
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
			{ name: "path", type: "string", description: "Base directory or file path to search within." },
			{ name: "pattern", type: "string", required: true, description: "Content pattern to search for. Use | to express OR alternatives." },
			{ name: "globs", type: "array", items: { type: "string" }, description: "Optional file glob filters." },
			{ name: "useRegex", type: "boolean", description: "Set true when pattern is a regular expression." },
			{ name: "caseSensitive", type: "boolean", description: "Set true for case-sensitive matching." },
			{ name: "limit", type: "number", description: "Maximum number of results to return." },
			{ name: "offset", type: "number", description: "Offset for paginating later result pages." },
			{ name: "groupByFile", type: "boolean", description: "Set true to rank candidate files before drilling into one file." },
		],
		rules: [
			"`path` may point to either a directory or a single file.",
			"This is content search (grep), not filename search.",
			"`pattern` matches file contents. `globs` only restrict which files are searched.",
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.",
			"`caseSensitive` defaults to false.",
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.",
			"Search results are intentionally capped. Refine the pattern or read a specific file next.",
		],
		preExecutable: true,
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
		preExecutable: true,
		parallelSafe: true,
	},
	{
		name: "search_dora_api",
		roles: ["main", "sub"],
		workModes: ["code", "plan"],
		description: "Search Dora SSR game engine docs and tutorials.",
		parameters: [
			{ name: "pattern", type: "string", required: true, description: "Query string to search for. Use | to express OR alternatives." },
			{ name: "docSource", type: "string", enum: ["api", "tutorial"], description: "Search API docs or tutorials. Defaults to api." },
			{ name: "programmingLanguage", type: "string", enum: ["ts", "tsx", "lua", "yue", "teal", "tl", "wa"], description: "Preferred language variant to search." },
			{ name: "limit", type: "number", description: context => `Maximum number of matches to return, up to ${context.searchDoraApiLimitMax}.` },
			{ name: "useRegex", type: "boolean", description: "Set true when pattern is a regular expression." },
		],
		rules: [
			"`docSource` defaults to `api`. Use `tutorial` to search teaching docs.",
			"Every result file uses the @dora-doc/api/... or @dora-doc/tutorial/... namespace and is readable with read_file.",
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.",
			"`useRegex` defaults to false whenever supported by a search tool.",
			context => `\`limit\` restricts each individual pattern search and must be <= ${context.searchDoraApiLimitMax}.`,
		],
		preExecutable: true,
		parallelSafe: true,
	},
	{
		name: "build",
		roles: ["main", "sub"],
		workModes: ["code"],
		description: "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.",
		parameters: [
			{ name: "path", type: "string", description: "Optional workspace-relative file or directory to build." },
		],
		rules: [
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
			{ name: "timeoutSeconds", type: "number", description: "Optional timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode can stop cooperative engine work but cannot interrupt a pure CPU loop that never yields." },
		],
		rules: [
			"This tool is available only when the user enables command execution for the current Agent task.",
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.",
			"Lua mode runs with a temporary environment whose global lookups fall back to Dora APIs; global writes stay in that one command and are not shared with later commands.",
			"Lua mode exposes projectDir, refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). getEntryStatus() returns a table containing success and running booleans.",
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.",
			"Call refreshTree(\"relative/file\") after single-file changes, or refreshTree() after directory or bulk changes.",
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.",
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.",
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.",
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.",
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten.",
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
			{ name: "validation", type: "array", items: {
				type: "object",
				properties: {
					kind: { type: "string", enum: ["build", "runtime", "manual"] },
					result: { type: "string", enum: ["passed", "failed", "not_run"] },
					evidence: { type: "array", items: { type: "string" } },
				},
				required: ["kind", "result"],
			}, description: "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run." },
			{ name: "knownIssues", type: "array", items: { type: "string" }, description: "Known remaining issues or blockers. Sub agents must provide an array, which may be empty." },
			{ name: "assumptions", type: "array", items: { type: "string" }, description: "Material assumptions made during the work. Sub agents must provide an array, which may be empty." },
			{ name: "learningCandidates", type: "array", items: {
				type: "object",
				properties: {
					claim: { type: "string" },
					scope: { type: "string", enum: ["file", "project", "engine"] },
					evidence: { type: "array", items: { type: "string" } },
					confidence: { type: "string", enum: ["observed", "inferred"] },
				},
				required: ["claim", "scope", "confidence"],
			}, description: "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty." },
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
				description: "One to eight questions. Use single_choice, multiple_choice, or text. A single-choice question may recommend at most one option. A multiple-choice question may recommend a set no larger than maxSelections.",
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
									recommended: { type: "boolean", description: "Mark an option as recommended. Use at most one for single_choice; multiple_choice may mark a recommended set no larger than maxSelections." },
								},
								required: ["id", "label"],
							},
						},
						allowOther: { type: "boolean" },
						placeholder: { type: "string" },
						minSelections: { type: "number" },
						maxSelections: { type: "number" },
					},
					required: ["id", "prompt", "type"],
				},
			},
		],
		rules: [
			"Inspect the project before asking; do not ask for facts available through read_file, grep_files, glob_files, or search_dora_api.",
			"ask_user has no document-update prerequisite. Incorporate the answers into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish.",
			"For single_choice, mark at most one option recommended. For multiple_choice, recommended options form a suggested set and must not exceed maxSelections.",
			"ask_user must be the only tool call in the response.",
			"The task pauses after the questionnaire is published and continues only after the user submits valid feedback.",
		],
	},
];

const DEFAULT_SCHEMA_CONTEXT: AgentToolSchemaContext = {
	searchDoraApiLimitMax: 20,
};

function hasRole(tool: ToolPrompt, role: AgentRole): boolean {
	return tool.roles.indexOf(role) >= 0;
}

function hasWorkMode(tool: ToolPrompt, workMode: AgentWorkMode): boolean {
	return tool.workModes.indexOf(workMode) >= 0;
}

function getToolPrompt(name: string): ToolPrompt | undefined {
	for (const tool of AGENT_TOOL_PROMPTS) {
		if (tool.name === name) return tool;
	}
	return undefined;
}

function isToolCapabilityEnabled(tool: ToolPrompt, options?: AgentToolCapabilityOptions): boolean {
	if (!isKnownToolName(tool.name)) return false;
	return hasWorkMode(tool, options?.workMode ?? "code")
		&& (options?.disabledAgentTools ?? []).indexOf(tool.name as AgentToolName) < 0;
}

function formatParameterList(tool: ToolPrompt): string {
	const parameters = tool.parameters ?? [];
	if (parameters.length === 0) return "";
	return parameters
		.map(parameter => parameter.required === true ? parameter.name : `${parameter.name}(optional)`)
		.join(", ");
}

function formatToolPrompt(tool: ToolPrompt, index: number, context: AgentToolSchemaContext): string {
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

function formatXMLRepairToolReference(tool: ToolPrompt): string {
	const parameterList = formatParameterList(tool);
	const params = parameterList !== "" ? parameterList : "none";
	const reason = tool.name === "finish" ? "no reason tag" : "reason tag required";
	return `- ${tool.name}: params: ${params}; ${reason}`;
}

export function isKnownToolName(name: string): name is AgentToolName {
	return BUILT_IN_AGENT_TOOL_NAMES.indexOf(name as AgentToolName) >= 0;
}

export function getAllowedToolsForRole(role: AgentRole, options?: AgentToolCapabilityOptions): AgentToolName[] {
	return AGENT_TOOL_PROMPTS
		.filter(tool => hasRole(tool, role) && isKnownToolName(tool.name) && isToolCapabilityEnabled(tool, options))
		.map(tool => tool.name as AgentToolName);
}

export function buildCurrentToolAvailabilityPrompt(_context: AgentToolAvailabilityContext): string {
	return [
		"Current tool availability:",
		"- every tool defined below or exposed in the current tool schema is executable",
		"- capabilities disabled for this task are omitted from both the definitions and schema",
	].join("\n");
}

export function getToolPromptsForRole(role: AgentRole, options?: {
	includeFinish?: boolean;
	disabledAgentTools?: AgentToolName[];
	workMode?: AgentWorkMode;
}): ToolPrompt[] {
	return AGENT_TOOL_PROMPTS.filter(tool =>
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

function getDecisionToolPromptsForRole(role: AgentRole, options?: {
	includeFinish?: boolean;
	disabledAgentTools?: AgentToolName[];
	workMode?: AgentWorkMode;
}): ToolPrompt[] {
	const tools = getToolPromptsForRole(role, options);
	if (role !== "sub") return tools;
	return tools.map(tool => tool.name !== "finish" ? tool : {
		...tool,
		parameters: (tool.parameters ?? []).map(parameter => ({
			...parameter,
			required: SUB_AGENT_REQUIRED_FINISH_PARAMS.indexOf(parameter.name) >= 0,
		})),
	});
}

export function buildToolDefinitionsDetailed(tools: ToolPrompt[], options?: {
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
		getDecisionToolPromptsForRole(role, {
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
	const tools = getToolPromptsForRole(role, {
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
	getToolPromptsForRole("sub"),
	{ title: "Available tools:" }
);

export const MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" + buildToolDefinitionsDetailed(
	getToolPromptsForRole("main")
		.filter(tool => getToolPromptsForRole("sub").map(subTool => subTool.name).indexOf(tool.name) < 0),
	{ title: "" }
);

export const XML_TOOL_DEFINITIONS_DETAILED = "\n\n" + buildToolDefinitionsDetailed(
	AGENT_TOOL_PROMPTS.filter(tool => tool.name === "finish"),
	{ title: "", includeXmlRules: true }
);

export function canPreExecuteTool(tool: AgentToolName): boolean {
	const prompt = getToolPrompt(tool);
	return prompt?.preExecutable === true;
}

export function canRunToolInParallel(tool: AgentToolName): boolean {
	const prompt = getToolPrompt(tool);
	return prompt?.parallelSafe === true;
}

export function buildDecisionToolSchema(role: AgentRole, searchDoraApiLimitMax: number, options?: AgentToolCapabilityOptions) {
	const context = { searchDoraApiLimitMax };
	return buildDecisionToolSchemaForTools(getDecisionToolPromptsForRole(role, {
		includeFinish: true,
		disabledAgentTools: options?.disabledAgentTools,
		workMode: options?.workMode,
	}), context);
}

export function buildDecisionToolSchemaForTools(tools: ToolPrompt[], context: AgentToolSchemaContext) {
	return tools
		.map(tool => tool.schema ? tool.schema(context) : createFunctionToolSchemaFromPrompt(tool, context));
}
