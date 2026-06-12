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
function resolveText(value, context) -- 70
	return type(value) == "string" and value or value(context) -- 71
end -- 71
function getToolDescription(tool, context) -- 74
	return resolveText(tool.description, context) -- 75
end -- 75
function getToolRules(tool, context) -- 78
	return __TS__ArrayMap( -- 79
		tool.rules or ({}), -- 79
		function(____, rule) return resolveText(rule, context) end -- 79
	) -- 79
end -- 79
function getParameterDescription(parameter, context) -- 82
	return resolveText(parameter.description, context) -- 83
end -- 83
function createFunctionToolSchemaFromPrompt(tool, context) -- 86
	local properties = {} -- 87
	local required = {} -- 88
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 89
		local property = { -- 90
			type = parameter.type, -- 91
			description = getParameterDescription(parameter, context) -- 92
		} -- 92
		if parameter.enum ~= nil then -- 92
			property.enum = parameter.enum -- 95
		end -- 95
		if parameter.items ~= nil then -- 95
			property.items = parameter.items -- 98
		end -- 98
		properties[parameter.name] = property -- 100
		if parameter.required == true then -- 100
			required[#required + 1] = parameter.name -- 102
		end -- 102
	end -- 102
	local parameters = {type = "object", properties = properties} -- 105
	if #required > 0 then -- 105
		parameters.required = required -- 110
	end -- 110
	local rules = getToolRules(tool, context) -- 112
	return { -- 113
		type = "function", -- 114
		["function"] = { -- 115
			name = tool.name, -- 116
			description = table.concat( -- 117
				{ -- 117
					getToolDescription(tool, context), -- 117
					table.unpack(rules) -- 117
				}, -- 117
				" " -- 117
			), -- 117
			parameters = parameters -- 118
		} -- 118
	} -- 118
end -- 118
function ____exports.isKnownToolName(name) -- 355
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 356
end -- 355
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 463
	return __TS__ArrayMap( -- 464
		__TS__ArrayFilter( -- 464
			tools, -- 464
			function(____, tool) return tool.name ~= "finish" end -- 465
		), -- 465
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 466
	) -- 466
end -- 463
BUILT_IN_AGENT_TOOL_NAMES = { -- 19
	"read_file", -- 20
	"edit_file", -- 21
	"delete_file", -- 22
	"grep_files", -- 23
	"search_dora_api", -- 24
	"glob_files", -- 25
	"build", -- 26
	"fetch_url", -- 27
	"list_sub_agents", -- 28
	"spawn_sub_agent", -- 29
	"finish" -- 30
} -- 30
____exports.AGENT_TOOL_PROMPTS = { -- 123
	{ -- 124
		name = "read_file", -- 125
		roles = {"main", "sub"}, -- 126
		description = "Read a specific line range from a file.", -- 127
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to read."}, {name = "startLine", type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, -- 128
		rules = {"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative."}, -- 133
		preExecutable = true, -- 136
		parallelSafe = true -- 137
	}, -- 137
	{ -- 139
		name = "edit_file", -- 140
		roles = {"main", "sub"}, -- 141
		description = "Make changes to a file.", -- 142
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to edit."}, {name = "old_str", type = "string", required = true, description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, {name = "new_str", type = "string", required = true, description = "Replacement text or the full file content when rewriting or creating."}}, -- 143
		rules = {"old_str and new_str MUST be different.", "old_str must match existing text exactly when it is non-empty.", "If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists."} -- 148
	}, -- 148
	{name = "delete_file", roles = {"main", "sub"}, description = "Remove a file.", parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}}}, -- 154
	{ -- 162
		name = "grep_files", -- 163
		roles = {"main", "sub"}, -- 164
		description = "Search text patterns inside files.", -- 165
		parameters = { -- 166
			{name = "path", type = "string", description = "Base directory or file path to search within."}, -- 167
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 168
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 169
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 170
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 171
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 172
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 173
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 174
		}, -- 174
		rules = { -- 176
			"`path` may point to either a directory or a single file.", -- 177
			"This is content search (grep), not filename search.", -- 178
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 179
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 180
			"`caseSensitive` defaults to false.", -- 181
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 182
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 183
		}, -- 183
		preExecutable = true, -- 185
		parallelSafe = true -- 186
	}, -- 186
	{ -- 188
		name = "glob_files", -- 189
		roles = {"main", "sub"}, -- 190
		description = "Enumerate files under a directory.", -- 191
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 192
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 197
		preExecutable = true, -- 201
		parallelSafe = true -- 202
	}, -- 202
	{ -- 204
		name = "search_dora_api", -- 205
		roles = {"main", "sub"}, -- 206
		description = "Search Dora SSR game engine docs and tutorials.", -- 207
		parameters = { -- 208
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 209
			{name = "docSource", type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials. Defaults to api."}, -- 210
			{name = "programmingLanguage", type = "string", enum = { -- 211
				"ts", -- 211
				"tsx", -- 211
				"lua", -- 211
				"yue", -- 211
				"teal", -- 211
				"tl", -- 211
				"wa" -- 211
			}, description = "Preferred language variant to search."}, -- 211
			{ -- 212
				name = "limit", -- 212
				type = "number", -- 212
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 212
			}, -- 212
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 213
		}, -- 213
		rules = { -- 215
			"`docSource` defaults to `api`. Use `tutorial` to search teaching docs.", -- 216
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 217
			"`useRegex` defaults to false whenever supported by a search tool.", -- 218
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 219
		}, -- 219
		preExecutable = true, -- 221
		parallelSafe = true -- 222
	}, -- 222
	{ -- 224
		name = "build", -- 225
		roles = {"main", "sub"}, -- 226
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 227
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 228
		rules = {"Read the result and then decide whether another action is needed."} -- 231
	}, -- 231
	{ -- 235
		name = "fetch_url", -- 236
		roles = {"main", "sub"}, -- 237
		description = "Import an HTTP or HTTPS network resource into the project.", -- 238
		parameters = {{ -- 239
			name = "mode", -- 240
			type = "string", -- 240
			required = true, -- 240
			enum = {"download", "git_clone"}, -- 240
			description = "Use download to GET a file, or git_clone to shallow clone an HTTP or HTTPS Git repository." -- 240
		}, {name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download or clone. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path for download, or target directory path for git_clone. The target must not already exist."}, {name = "ref", type = "string", description = "Optional branch, tag, or commit-ish for git_clone."}}, -- 240
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "download writes to a temporary file first, then moves it into place only after the GET succeeds.", "git_clone uses an HTTP or HTTPS shallow clone into a temporary directory, then moves it into place only after clone succeeds."} -- 245
	}, -- 245
	{name = "finish", roles = {"main", "sub"}, description = "End the task and reply directly to the user.", parameters = {{name = "message", type = "string", required = true, description = "Final user-facing answer."}}}, -- 252
	{ -- 260
		name = "list_sub_agents", -- 261
		roles = {"main"}, -- 262
		description = "Query sub-agent state under the current main session.", -- 263
		parameters = {{name = "status", type = "string", enum = { -- 264
			"active_or_recent", -- 265
			"running", -- 265
			"done", -- 265
			"failed", -- 265
			"all" -- 265
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 265
		rules = { -- 270
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 271
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 272
			"limit defaults to a small recent window. Use offset to page older items.", -- 273
			"query filters by title, goal, or summary text.", -- 274
			"Do not use this after a successful spawn_sub_agent in the same turn." -- 275
		}, -- 275
		preExecutable = true, -- 277
		parallelSafe = true -- 278
	}, -- 278
	{ -- 280
		name = "spawn_sub_agent", -- 281
		roles = {"main"}, -- 282
		description = "Create and start a sub agent session for delegated implementation work.", -- 283
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 284
		rules = { -- 290
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 291
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 292
			"The spawned sub agent inherits the current session tool capabilities, including fetch_url when network import is enabled.", -- 293
			"title should be short and specific.", -- 294
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 295
			"If spawn succeeds, immediately finish the current turn and state that the work has been delegated.", -- 296
			"Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.", -- 297
			"Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.", -- 298
			"filesHint is an optional list of likely files or directories." -- 299
		} -- 299
	} -- 299
} -- 299
local DEFAULT_SCHEMA_CONTEXT = {searchDoraApiLimitMax = 20} -- 304
local function hasRole(tool, role) -- 308
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 309
end -- 308
local function getToolPrompt(name) -- 312
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 313
		if tool.name == name then -- 313
			return tool -- 314
		end -- 314
	end -- 314
	return nil -- 316
end -- 312
local function isToolCapabilityEnabled(tool, options) -- 319
	if not ____exports.isKnownToolName(tool.name) then -- 319
		return false -- 320
	end -- 320
	return __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 321
end -- 319
local function formatParameterList(tool) -- 324
	local parameters = tool.parameters or ({}) -- 325
	if #parameters == 0 then -- 325
		return "" -- 326
	end -- 326
	return table.concat( -- 327
		__TS__ArrayMap( -- 327
			parameters, -- 327
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 328
		), -- 328
		", " -- 329
	) -- 329
end -- 324
local function formatToolPrompt(tool, index, context) -- 332
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 333
	local parameterList = formatParameterList(tool) -- 334
	if parameterList ~= "" then -- 334
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 336
	end -- 336
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 338
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 339
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 340
	end -- 340
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 342
		lines[#lines + 1] = "\t- " .. rule -- 343
	end -- 343
	return table.concat(lines, "\n") -- 345
end -- 332
local function formatXMLRepairToolReference(tool) -- 348
	local parameterList = formatParameterList(tool) -- 349
	local params = parameterList ~= "" and parameterList or "none" -- 350
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 351
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 352
end -- 348
function ____exports.getAllowedToolsForRole(role, options) -- 359
	return __TS__ArrayMap( -- 360
		__TS__ArrayFilter( -- 360
			____exports.AGENT_TOOL_PROMPTS, -- 360
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 361
		), -- 361
		function(____, tool) return tool.name end -- 362
	) -- 362
end -- 359
function ____exports.getToolPromptsForRole(role, options) -- 365
	return __TS__ArrayFilter( -- 369
		____exports.AGENT_TOOL_PROMPTS, -- 369
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 369
	) -- 369
end -- 365
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 376
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 381
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 382
	local sections = __TS__ArrayMap( -- 383
		tools, -- 383
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 383
	) -- 383
	if (options and options.includeXmlRules) == true then -- 383
		sections[#sections + 1] = "XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and fetch_url, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 385
	end -- 385
	local body = table.concat(sections, "\n\n") -- 391
	return title ~= "" and (title .. "\n") .. body or body -- 392
end -- 376
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 395
	return ____exports.buildToolDefinitionsDetailed( -- 402
		____exports.getToolPromptsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools}), -- 403
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 407
	) -- 407
end -- 395
function ____exports.buildXMLRepairToolReference(role, options) -- 415
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools}) -- 416
	local ____array_22 = __TS__SparseArrayNew( -- 416
		"Allowed tools and XML params:", -- 418
		table.unpack(__TS__ArrayMap( -- 419
			tools, -- 419
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 419
		)) -- 419
	) -- 419
	__TS__SparseArrayPush( -- 419
		____array_22, -- 419
		"", -- 420
		"XML shape:", -- 421
		"- Wrap the decision in exactly one <tool_call> root.", -- 422
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 423
		"- For finish: include <tool> and <params><message>...</message></params>; omit <reason>.", -- 424
		"- Inside <params>, use one child tag per parameter name above." -- 425
	) -- 425
	local lines = {__TS__SparseArraySpread(____array_22)} -- 417
	return table.concat(lines, "\n") -- 427
end -- 415
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 430
	____exports.getToolPromptsForRole("sub"), -- 431
	{title = "Available tools:"} -- 432
) -- 432
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 435
	__TS__ArrayFilter( -- 436
		____exports.getToolPromptsForRole("main"), -- 436
		function(____, tool) return __TS__ArrayIndexOf( -- 437
			__TS__ArrayMap( -- 437
				____exports.getToolPromptsForRole("sub"), -- 437
				function(____, subTool) return subTool.name end -- 437
			), -- 437
			tool.name -- 437
		) < 0 end -- 437
	), -- 437
	{title = ""} -- 438
) -- 438
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 441
	__TS__ArrayFilter( -- 442
		____exports.AGENT_TOOL_PROMPTS, -- 442
		function(____, tool) return tool.name == "finish" end -- 442
	), -- 442
	{title = "", includeXmlRules = true} -- 443
) -- 443
function ____exports.canPreExecuteTool(tool) -- 446
	local prompt = getToolPrompt(tool) -- 447
	return (prompt and prompt.preExecutable) == true -- 448
end -- 446
function ____exports.canRunToolInParallel(tool) -- 451
	local prompt = getToolPrompt(tool) -- 452
	return (prompt and prompt.parallelSafe) == true -- 453
end -- 451
function ____exports.buildDecisionToolSchema(role, searchDoraApiLimitMax, options) -- 456
	local context = {searchDoraApiLimitMax = searchDoraApiLimitMax} -- 457
	return ____exports.buildDecisionToolSchemaForTools( -- 458
		____exports.getToolPromptsForRole(role, {disabledAgentTools = options and options.disabledAgentTools}), -- 458
		context -- 460
	) -- 460
end -- 456
return ____exports -- 456