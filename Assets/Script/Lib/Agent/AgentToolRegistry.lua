-- [ts]: AgentToolRegistry.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local resolveText, getToolDescription, getToolRules, getParameterDescription, createFunctionToolSchemaFromPrompt, BUILT_IN_AGENT_TOOL_NAMES -- 1
function resolveText(value, context) -- 72
	return type(value) == "string" and value or value(context) -- 73
end -- 73
function getToolDescription(tool, context) -- 76
	return resolveText(tool.description, context) -- 77
end -- 77
function getToolRules(tool, context) -- 80
	return __TS__ArrayMap( -- 81
		tool.rules or ({}), -- 81
		function(____, rule) return resolveText(rule, context) end -- 81
	) -- 81
end -- 81
function getParameterDescription(parameter, context) -- 84
	return resolveText(parameter.description, context) -- 85
end -- 85
function createFunctionToolSchemaFromPrompt(tool, context) -- 88
	local properties = {} -- 89
	local required = {} -- 90
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 91
		local property = { -- 92
			type = parameter.type, -- 93
			description = getParameterDescription(parameter, context) -- 94
		} -- 94
		if parameter.enum ~= nil then -- 94
			property.enum = parameter.enum -- 97
		end -- 97
		if parameter.items ~= nil then -- 97
			property.items = parameter.items -- 100
		end -- 100
		properties[parameter.name] = property -- 102
		if parameter.required == true then -- 102
			required[#required + 1] = parameter.name -- 104
		end -- 104
	end -- 104
	local parameters = {type = "object", properties = properties} -- 107
	if #required > 0 then -- 107
		parameters.required = required -- 112
	end -- 112
	local rules = getToolRules(tool, context) -- 114
	return { -- 115
		type = "function", -- 116
		["function"] = { -- 117
			name = tool.name, -- 118
			description = table.concat( -- 119
				{ -- 119
					getToolDescription(tool, context), -- 119
					table.unpack(rules) -- 119
				}, -- 119
				" " -- 119
			), -- 119
			parameters = parameters -- 120
		} -- 120
	} -- 120
end -- 120
function ____exports.isKnownToolName(name) -- 375
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 376
end -- 375
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 483
	return __TS__ArrayMap( -- 484
		__TS__ArrayFilter( -- 484
			tools, -- 484
			function(____, tool) return tool.name ~= "finish" end -- 485
		), -- 485
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 486
	) -- 486
end -- 483
BUILT_IN_AGENT_TOOL_NAMES = { -- 20
	"read_file", -- 21
	"edit_file", -- 22
	"delete_file", -- 23
	"grep_files", -- 24
	"search_dora_api", -- 25
	"glob_files", -- 26
	"build", -- 27
	"fetch_url", -- 28
	"execute_command", -- 29
	"list_sub_agents", -- 30
	"spawn_sub_agent", -- 31
	"finish" -- 32
} -- 32
____exports.AGENT_TOOL_PROMPTS = { -- 125
	{ -- 126
		name = "read_file", -- 127
		roles = {"main", "sub"}, -- 128
		description = "Read a specific line range from a file.", -- 129
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to read."}, {name = "startLine", type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, -- 130
		rules = {"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative."}, -- 135
		preExecutable = true, -- 138
		parallelSafe = true -- 139
	}, -- 139
	{ -- 141
		name = "edit_file", -- 142
		roles = {"main", "sub"}, -- 143
		description = "Make changes to a file.", -- 144
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to edit."}, {name = "old_str", type = "string", required = true, description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, {name = "new_str", type = "string", required = true, description = "Replacement text or the full file content when rewriting or creating."}}, -- 145
		rules = {"old_str and new_str MUST be different.", "old_str must match existing text exactly when it is non-empty.", "If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists."} -- 150
	}, -- 150
	{name = "delete_file", roles = {"main", "sub"}, description = "Remove a file.", parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}}}, -- 156
	{ -- 164
		name = "grep_files", -- 165
		roles = {"main", "sub"}, -- 166
		description = "Search text patterns inside files.", -- 167
		parameters = { -- 168
			{name = "path", type = "string", description = "Base directory or file path to search within."}, -- 169
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 170
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 171
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 172
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 173
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 174
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 175
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 176
		}, -- 176
		rules = { -- 178
			"`path` may point to either a directory or a single file.", -- 179
			"This is content search (grep), not filename search.", -- 180
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 181
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 182
			"`caseSensitive` defaults to false.", -- 183
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 184
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 185
		}, -- 185
		preExecutable = true, -- 187
		parallelSafe = true -- 188
	}, -- 188
	{ -- 190
		name = "glob_files", -- 191
		roles = {"main", "sub"}, -- 192
		description = "Enumerate files under a directory.", -- 193
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 194
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 199
		preExecutable = true, -- 203
		parallelSafe = true -- 204
	}, -- 204
	{ -- 206
		name = "search_dora_api", -- 207
		roles = {"main", "sub"}, -- 208
		description = "Search Dora SSR game engine docs and tutorials.", -- 209
		parameters = { -- 210
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 211
			{name = "docSource", type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials. Defaults to api."}, -- 212
			{name = "programmingLanguage", type = "string", enum = { -- 213
				"ts", -- 213
				"tsx", -- 213
				"lua", -- 213
				"yue", -- 213
				"teal", -- 213
				"tl", -- 213
				"wa" -- 213
			}, description = "Preferred language variant to search."}, -- 213
			{ -- 214
				name = "limit", -- 214
				type = "number", -- 214
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 214
			}, -- 214
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 215
		}, -- 215
		rules = { -- 217
			"`docSource` defaults to `api`. Use `tutorial` to search teaching docs.", -- 218
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 219
			"`useRegex` defaults to false whenever supported by a search tool.", -- 220
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 221
		}, -- 221
		preExecutable = true, -- 223
		parallelSafe = true -- 224
	}, -- 224
	{ -- 226
		name = "build", -- 227
		roles = {"main", "sub"}, -- 228
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 229
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 230
		rules = {"Read the result and then decide whether another action is needed."} -- 233
	}, -- 233
	{ -- 237
		name = "fetch_url", -- 238
		roles = {"main", "sub"}, -- 239
		description = "Download a single HTTP or HTTPS resource into the project.", -- 240
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 241
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds.", "Use execute_command with mode=git for Git operations such as clone, status, diff, add, commit, pull, fetch, and push."} -- 245
	}, -- 245
	{ -- 252
		name = "execute_command", -- 253
		roles = {"main", "sub"}, -- 254
		description = "Execute a controlled engine command.", -- 255
		parameters = {{ -- 256
			name = "mode", -- 257
			type = "string", -- 257
			required = true, -- 257
			enum = {"lua", "git"}, -- 257
			description = "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." -- 257
		}, {name = "code", type = "string", description = "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result."}, {name = "command", type = "string", description = "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported."}, {name = "timeoutSeconds", type = "number", description = "Optional timeout for git mode. Defaults to 600 seconds. Lua mode should be short-running and cannot forcibly interrupt pure CPU infinite loops."}}, -- 257
		rules = { -- 262
			"This tool is available only when the user enables command execution for the current Agent task.", -- 263
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 264
			"Lua mode runs with a temporary environment whose global lookups fall back to Dora APIs; global writes stay in that one command and are not shared with later commands.", -- 265
			"Lua mode exposes projectDir and refreshTree(path?). Call refreshTree(\"relative/file\") after single-file changes, or refreshTree() after directory or bulk changes.", -- 266
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 267
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 268
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten." -- 269
		} -- 269
	}, -- 269
	{name = "finish", roles = {"main", "sub"}, description = "End the task and reply directly to the user.", parameters = {{name = "message", type = "string", required = true, description = "Final user-facing answer."}}}, -- 272
	{ -- 280
		name = "list_sub_agents", -- 281
		roles = {"main"}, -- 282
		description = "Query sub-agent state under the current main session.", -- 283
		parameters = {{name = "status", type = "string", enum = { -- 284
			"active_or_recent", -- 285
			"running", -- 285
			"done", -- 285
			"failed", -- 285
			"all" -- 285
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 285
		rules = { -- 290
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 291
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 292
			"limit defaults to a small recent window. Use offset to page older items.", -- 293
			"query filters by title, goal, or summary text.", -- 294
			"Do not use this after a successful spawn_sub_agent in the same turn." -- 295
		}, -- 295
		preExecutable = true, -- 297
		parallelSafe = true -- 298
	}, -- 298
	{ -- 300
		name = "spawn_sub_agent", -- 301
		roles = {"main"}, -- 302
		description = "Create and start a sub agent session for delegated implementation work.", -- 303
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 304
		rules = { -- 310
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 311
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 312
			"The spawned sub agent inherits the current session tool capabilities, including fetch_url and execute_command when enabled.", -- 313
			"title should be short and specific.", -- 314
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 315
			"If spawn succeeds, immediately finish the current turn and state that the work has been delegated.", -- 316
			"Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.", -- 317
			"Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.", -- 318
			"filesHint is an optional list of likely files or directories." -- 319
		} -- 319
	} -- 319
} -- 319
local DEFAULT_SCHEMA_CONTEXT = {searchDoraApiLimitMax = 20} -- 324
local function hasRole(tool, role) -- 328
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 329
end -- 328
local function getToolPrompt(name) -- 332
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 333
		if tool.name == name then -- 333
			return tool -- 334
		end -- 334
	end -- 334
	return nil -- 336
end -- 332
local function isToolCapabilityEnabled(tool, options) -- 339
	if not ____exports.isKnownToolName(tool.name) then -- 339
		return false -- 340
	end -- 340
	return __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 341
end -- 339
local function formatParameterList(tool) -- 344
	local parameters = tool.parameters or ({}) -- 345
	if #parameters == 0 then -- 345
		return "" -- 346
	end -- 346
	return table.concat( -- 347
		__TS__ArrayMap( -- 347
			parameters, -- 347
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 348
		), -- 348
		", " -- 349
	) -- 349
end -- 344
local function formatToolPrompt(tool, index, context) -- 352
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 353
	local parameterList = formatParameterList(tool) -- 354
	if parameterList ~= "" then -- 354
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 356
	end -- 356
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 358
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 359
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 360
	end -- 360
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 362
		lines[#lines + 1] = "\t- " .. rule -- 363
	end -- 363
	return table.concat(lines, "\n") -- 365
end -- 352
local function formatXMLRepairToolReference(tool) -- 368
	local parameterList = formatParameterList(tool) -- 369
	local params = parameterList ~= "" and parameterList or "none" -- 370
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 371
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 372
end -- 368
function ____exports.getAllowedToolsForRole(role, options) -- 379
	return __TS__ArrayMap( -- 380
		__TS__ArrayFilter( -- 380
			____exports.AGENT_TOOL_PROMPTS, -- 380
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 381
		), -- 381
		function(____, tool) return tool.name end -- 382
	) -- 382
end -- 379
function ____exports.getToolPromptsForRole(role, options) -- 385
	return __TS__ArrayFilter( -- 389
		____exports.AGENT_TOOL_PROMPTS, -- 389
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 389
	) -- 389
end -- 385
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 396
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 401
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 402
	local sections = __TS__ArrayMap( -- 403
		tools, -- 403
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 403
	) -- 403
	if (options and options.includeXmlRules) == true then -- 403
		sections[#sections + 1] = "XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, fetch_url, and execute_command, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 405
	end -- 405
	local body = table.concat(sections, "\n\n") -- 411
	return title ~= "" and (title .. "\n") .. body or body -- 412
end -- 396
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 415
	return ____exports.buildToolDefinitionsDetailed( -- 422
		____exports.getToolPromptsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools}), -- 423
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 427
	) -- 427
end -- 415
function ____exports.buildXMLRepairToolReference(role, options) -- 435
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools}) -- 436
	local ____array_22 = __TS__SparseArrayNew( -- 436
		"Allowed tools and XML params:", -- 438
		table.unpack(__TS__ArrayMap( -- 439
			tools, -- 439
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 439
		)) -- 439
	) -- 439
	__TS__SparseArrayPush( -- 439
		____array_22, -- 439
		"", -- 440
		"XML shape:", -- 441
		"- Wrap the decision in exactly one <tool_call> root.", -- 442
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 443
		"- For finish: include <tool> and <params><message>...</message></params>; omit <reason>.", -- 444
		"- Inside <params>, use one child tag per parameter name above." -- 445
	) -- 445
	local lines = {__TS__SparseArraySpread(____array_22)} -- 437
	return table.concat(lines, "\n") -- 447
end -- 435
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 450
	____exports.getToolPromptsForRole("sub"), -- 451
	{title = "Available tools:"} -- 452
) -- 452
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 455
	__TS__ArrayFilter( -- 456
		____exports.getToolPromptsForRole("main"), -- 456
		function(____, tool) return __TS__ArrayIndexOf( -- 457
			__TS__ArrayMap( -- 457
				____exports.getToolPromptsForRole("sub"), -- 457
				function(____, subTool) return subTool.name end -- 457
			), -- 457
			tool.name -- 457
		) < 0 end -- 457
	), -- 457
	{title = ""} -- 458
) -- 458
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 461
	__TS__ArrayFilter( -- 462
		____exports.AGENT_TOOL_PROMPTS, -- 462
		function(____, tool) return tool.name == "finish" end -- 462
	), -- 462
	{title = "", includeXmlRules = true} -- 463
) -- 463
function ____exports.canPreExecuteTool(tool) -- 466
	local prompt = getToolPrompt(tool) -- 467
	return (prompt and prompt.preExecutable) == true -- 468
end -- 466
function ____exports.canRunToolInParallel(tool) -- 471
	local prompt = getToolPrompt(tool) -- 472
	return (prompt and prompt.parallelSafe) == true -- 473
end -- 471
function ____exports.buildDecisionToolSchema(role, searchDoraApiLimitMax, options) -- 476
	local context = {searchDoraApiLimitMax = searchDoraApiLimitMax} -- 477
	return ____exports.buildDecisionToolSchemaForTools( -- 478
		____exports.getToolPromptsForRole(role, {disabledAgentTools = options and options.disabledAgentTools}), -- 478
		context -- 480
	) -- 480
end -- 476
return ____exports -- 476