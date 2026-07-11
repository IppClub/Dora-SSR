// @preview-file off clear

export type AgentDecisionMode = "tool_calling" | "xml";
export type AgentRole = "main" | "sub";

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
	| "wait_sub_agents"
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
	"wait_sub_agents",
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
	description: string | ((context: AgentToolSchemaContext) => string);
	parameters?: ToolParameterPrompt[];
	rules?: (string | ((context: AgentToolSchemaContext) => string))[];
	schema?: (context: AgentToolSchemaContext) => AgentFunctionToolSchema;
	preExecutable?: boolean;
	parallelSafe?: boolean;
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
		description: "Read a specific line range from a file.",
		parameters: [
			{ name: "path", type: "string", required: true, description: "Workspace-relative file path to read." },
			{ name: "startLine", type: "number", description: "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid." },
			{ name: "endLine", type: "number", description: "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid." },
		],
		rules: [
			"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.",
		],
		preExecutable: true,
		parallelSafe: true,
	},
	{
		name: "edit_file",
		roles: ["main", "sub"],
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
		],
	},
	{
		name: "delete_file",
		roles: ["main", "sub"],
		description: "Remove a file.",
		parameters: [
			{ name: "target_file", type: "string", required: true, description: "Workspace-relative file path to delete." },
		],
	},
	{
		name: "grep_files",
		roles: ["main", "sub"],
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
		description: "Download a single HTTP or HTTPS resource into the project.",
		parameters: [
			{ name: "url", type: "string", required: true, description: "HTTP or HTTPS URL to download. Other schemes are rejected." },
			{ name: "target", type: "string", required: true, description: "Workspace-relative target file path. The target must not already exist." },
		],
		rules: [
			"This tool is available only when the user enables fetch_url for the current Agent task.",
			"Targets must stay inside the current project and existing files or directories are not overwritten.",
			"This tool writes to a temporary file first, then moves it into place only after the GET succeeds.",
			"Use execute_command with mode=git for Git operations such as clone, status, diff, add, commit, pull, fetch, and push.",
		],
	},
	{
		name: "execute_command",
		roles: ["main", "sub"],
		description: "Execute a controlled engine command.",
		parameters: [
			{ name: "mode", type: "string", required: true, enum: ["lua", "git"], description: "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." },
			{ name: "code", type: "string", description: "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result." },
			{ name: "command", type: "string", description: "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported." },
			{ name: "cwd", type: "string", description: "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C." },
			{ name: "timeoutSeconds", type: "number", description: "Optional timeout for git mode. Defaults to 600 seconds. Lua mode should be short-running and cannot forcibly interrupt pure CPU infinite loops." },
		],
		rules: [
			"This tool is available only when the user enables command execution for the current Agent task.",
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.",
			"Lua mode runs with a temporary environment whose global lookups fall back to Dora APIs; global writes stay in that one command and are not shared with later commands.",
			"Lua mode exposes projectDir and refreshTree(path?). Call refreshTree(\"relative/file\") after single-file changes, or refreshTree() after directory or bulk changes.",
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.",
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.",
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.",
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten.",
		],
	},
	{
		name: "finish",
		roles: ["main", "sub"],
		description: "End the task and reply directly to the user.",
		parameters: [
			{ name: "message", type: "string", required: true, description: "Final user-facing answer." },
		],
	},
	{
		name: "list_sub_agents",
		roles: ["main"],
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
			"Do not use this to poll for results — prefer wait_sub_agents. Use list_sub_agents only to inspect overall sub-agent status when needed.",
		],
		preExecutable: true,
		parallelSafe: true,
	},
	{
		name: "spawn_sub_agent",
		roles: ["main"],
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
			"The spawned sub agent inherits the current session tool capabilities, including fetch_url and execute_command when enabled.",
			"title should be short and specific.",
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.",
			"spawn_sub_agent is fire-and-forget: it returns immediately with a session id and does NOT wait for the sub agent to finish.",
			"You may dispatch multiple sub agents before waiting. After spawning, call wait_sub_agents to block until at least one finishes and return its result in the same turn.",
			"You can also keep doing other work in the same turn after spawning; sub-agent results are collected when you call wait_sub_agents.",
			"filesHint is an optional list of likely files or directories.",
		],
	},
	{
		name: "wait_sub_agents",
		roles: ["main"],
		description: "Block until at least one spawned sub agent finishes, then return its result in the same turn. This is how you collect sub-agent results without ending the turn.",
		parameters: [
			{ name: "timeout", type: "number", description: "Max seconds to wait. Defaults to 120." },
			{ name: "sessionIds", type: "array", items: { type: "number" }, description: "Optional list of sub-agent session ids to wait on. If omitted, waits on all running sub agents of the current main session." },
		],
		rules: [
			"Call this after one or more spawn_sub_agent calls to block until at least one sub agent completes, then read its result in the same turn.",
			"Returns finished sub-agent results (summary + memoryEntry) plus remainingRunning and timedOut.",
			"If timedOut is true and sub agents are still running, call wait_sub_agents again, or finish and handle them later.",
			"If consumed is empty, the sub agents may have failed — use list_sub_agents to inspect their status.",
			"Prefer this over list_sub_agents for collecting results.",
		],
		preExecutable: false,
		parallelSafe: false,
	},
];

const DEFAULT_SCHEMA_CONTEXT: AgentToolSchemaContext = {
	searchDoraApiLimitMax: 20,
};

function hasRole(tool: ToolPrompt, role: AgentRole): boolean {
	return tool.roles.indexOf(role) >= 0;
}

function getToolPrompt(name: string): ToolPrompt | undefined {
	for (const tool of AGENT_TOOL_PROMPTS) {
		if (tool.name === name) return tool;
	}
	return undefined;
}

function isToolCapabilityEnabled(tool: ToolPrompt, options?: AgentToolCapabilityOptions): boolean {
	if (!isKnownToolName(tool.name)) return false;
	return (options?.disabledAgentTools ?? []).indexOf(tool.name as AgentToolName) < 0;
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

export function getToolPromptsForRole(role: AgentRole, options?: {
	includeFinish?: boolean;
	disabledAgentTools?: AgentToolName[];
}): ToolPrompt[] {
	return AGENT_TOOL_PROMPTS.filter(tool =>
		hasRole(tool, role)
		&& (options?.includeFinish === true || tool.name !== "finish")
		&& isToolCapabilityEnabled(tool, options)
	);
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
		sections.push(`XML mode object fields:
- Use a single root tag: <tool_call>.
- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, fetch_url, execute_command, include <tool>, <reason>, and <params>.
- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.
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
}): string {
	return buildToolDefinitionsDetailed(
		getToolPromptsForRole(role, {
			includeFinish: options?.includeFinish,
			disabledAgentTools: options?.disabledAgentTools,
		}),
		{
			title: options?.title,
			includeXmlRules: options?.includeXmlRules,
			context: options?.context,
		}
	);
}

export function buildXMLRepairToolReference(role: AgentRole, options?: AgentToolCapabilityOptions): string {
	const tools = getToolPromptsForRole(role, { includeFinish: true, disabledAgentTools: options?.disabledAgentTools });
	const lines = [
		"Allowed tools and XML params:",
		...tools.map(tool => formatXMLRepairToolReference(tool)),
		"",
		"XML shape:",
		"- Wrap the decision in exactly one <tool_call> root.",
		"- For tools except finish: include <tool>, <reason>, and <params>.",
		"- For finish: include <tool> and <params><message>...</message></params>; omit <reason>.",
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
	return buildDecisionToolSchemaForTools(getToolPromptsForRole(role, {
		disabledAgentTools: options?.disabledAgentTools,
	}), context);
}

export function buildDecisionToolSchemaForTools(tools: ToolPrompt[], context: AgentToolSchemaContext) {
	return tools
		.filter(tool => tool.name !== "finish")
		.map(tool => tool.schema ? tool.schema(context) : createFunctionToolSchemaFromPrompt(tool, context));
}
