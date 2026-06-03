-- [ts]: AgentToolRegistry.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local resolveText, getToolDescription, getToolRules, getParameterDescription, createFunctionToolSchemaFromPrompt -- 1
function resolveText(value, context) -- 64
	return type(value) == "string" and value or value(context) -- 65
end -- 65
function getToolDescription(tool, context) -- 68
	return resolveText(tool.description, context) -- 69
end -- 69
function getToolRules(tool, context) -- 72
	return __TS__ArrayMap( -- 73
		tool.rules or ({}), -- 73
		function(____, rule) return resolveText(rule, context) end -- 73
	) -- 73
end -- 73
function getParameterDescription(parameter, context) -- 76
	return resolveText(parameter.description, context) -- 77
end -- 77
function createFunctionToolSchemaFromPrompt(tool, context) -- 80
	local properties = {} -- 81
	local required = {} -- 82
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 83
		local property = { -- 84
			type = parameter.type, -- 85
			description = getParameterDescription(parameter, context) -- 86
		} -- 86
		if parameter.enum ~= nil then -- 86
			property.enum = parameter.enum -- 89
		end -- 89
		if parameter.items ~= nil then -- 89
			property.items = parameter.items -- 92
		end -- 92
		properties[parameter.name] = property -- 94
		if parameter.required == true then -- 94
			required[#required + 1] = parameter.name -- 96
		end -- 96
	end -- 96
	local parameters = {type = "object", properties = properties} -- 99
	if #required > 0 then -- 99
		parameters.required = required -- 104
	end -- 104
	local rules = getToolRules(tool, context) -- 106
	return { -- 107
		type = "function", -- 108
		["function"] = { -- 109
			name = tool.name, -- 110
			description = table.concat( -- 111
				{ -- 111
					getToolDescription(tool, context), -- 111
					table.unpack(rules) -- 111
				}, -- 111
				" " -- 111
			), -- 111
			parameters = parameters -- 112
		} -- 112
	} -- 112
end -- 112
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 427
	return __TS__ArrayMap( -- 428
		__TS__ArrayFilter( -- 428
			tools, -- 428
			function(____, tool) return tool.name ~= "finish" end -- 429
		), -- 429
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 430
	) -- 430
end -- 427
local BUILT_IN_AGENT_TOOL_NAMES = { -- 18
	"read_file", -- 19
	"edit_file", -- 20
	"delete_file", -- 21
	"grep_files", -- 22
	"search_dora_api", -- 23
	"glob_files", -- 24
	"build", -- 25
	"list_sub_agents", -- 26
	"spawn_sub_agent", -- 27
	"finish" -- 28
} -- 28
____exports.AGENT_TOOL_PROMPTS = { -- 117
	{ -- 118
		name = "read_file", -- 119
		roles = {"main", "sub"}, -- 120
		description = "Read a specific line range from a file.", -- 121
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to read."}, {name = "startLine", type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, -- 122
		rules = {"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative."}, -- 127
		preExecutable = true, -- 130
		parallelSafe = true -- 131
	}, -- 131
	{ -- 133
		name = "edit_file", -- 134
		roles = {"main", "sub"}, -- 135
		description = "Make changes to a file.", -- 136
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to edit."}, {name = "old_str", type = "string", required = true, description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, {name = "new_str", type = "string", required = true, description = "Replacement text or the full file content when rewriting or creating."}}, -- 137
		rules = {"old_str and new_str MUST be different.", "old_str must match existing text exactly when it is non-empty.", "If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists."} -- 142
	}, -- 142
	{name = "delete_file", roles = {"main", "sub"}, description = "Remove a file.", parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}}}, -- 148
	{ -- 156
		name = "grep_files", -- 157
		roles = {"main", "sub"}, -- 158
		description = "Search text patterns inside files.", -- 159
		parameters = { -- 160
			{name = "path", type = "string", description = "Base directory or file path to search within."}, -- 161
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 162
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 163
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 164
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 165
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 166
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 167
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 168
		}, -- 168
		rules = { -- 170
			"`path` may point to either a directory or a single file.", -- 171
			"This is content search (grep), not filename search.", -- 172
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 173
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 174
			"`caseSensitive` defaults to false.", -- 175
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 176
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 177
		}, -- 177
		preExecutable = true, -- 179
		parallelSafe = true -- 180
	}, -- 180
	{ -- 182
		name = "glob_files", -- 183
		roles = {"main", "sub"}, -- 184
		description = "Enumerate files under a directory.", -- 185
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 186
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 191
		preExecutable = true, -- 195
		parallelSafe = true -- 196
	}, -- 196
	{ -- 198
		name = "search_dora_api", -- 199
		roles = {"main", "sub"}, -- 200
		description = "Search Dora SSR game engine docs and tutorials.", -- 201
		parameters = { -- 202
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 203
			{name = "docSource", type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials. Defaults to api."}, -- 204
			{name = "programmingLanguage", type = "string", enum = { -- 205
				"ts", -- 205
				"tsx", -- 205
				"lua", -- 205
				"yue", -- 205
				"teal", -- 205
				"tl", -- 205
				"wa" -- 205
			}, description = "Preferred language variant to search."}, -- 205
			{ -- 206
				name = "limit", -- 206
				type = "number", -- 206
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 206
			}, -- 206
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 207
		}, -- 207
		rules = { -- 209
			"`docSource` defaults to `api`. Use `tutorial` to search teaching docs.", -- 210
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 211
			"`useRegex` defaults to false whenever supported by a search tool.", -- 212
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 213
		}, -- 213
		preExecutable = true, -- 215
		parallelSafe = true -- 216
	}, -- 216
	{ -- 218
		name = "build", -- 219
		roles = {"main", "sub"}, -- 220
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 221
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 222
		rules = {"Read the result and then decide whether another action is needed."} -- 225
	}, -- 225
	{name = "finish", roles = {"main", "sub"}, description = "End the task and reply directly to the user.", parameters = {{name = "message", type = "string", required = true, description = "Final user-facing answer."}}}, -- 229
	{ -- 237
		name = "list_sub_agents", -- 238
		roles = {"main"}, -- 239
		description = "Query sub-agent state under the current main session.", -- 240
		parameters = {{name = "status", type = "string", enum = { -- 241
			"active_or_recent", -- 242
			"running", -- 242
			"done", -- 242
			"failed", -- 242
			"all" -- 242
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 242
		rules = { -- 247
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 248
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 249
			"limit defaults to a small recent window. Use offset to page older items.", -- 250
			"query filters by title, goal, or summary text.", -- 251
			"Do not use this after a successful spawn_sub_agent in the same turn." -- 252
		}, -- 252
		preExecutable = true, -- 254
		parallelSafe = true -- 255
	}, -- 255
	{ -- 257
		name = "spawn_sub_agent", -- 258
		roles = {"main"}, -- 259
		description = "Create and start a sub agent session for delegated implementation work.", -- 260
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 261
		rules = { -- 267
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 268
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 269
			"The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.", -- 270
			"title should be short and specific.", -- 271
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 272
			"If spawn succeeds, immediately finish the current turn and state that the work has been delegated.", -- 273
			"Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.", -- 274
			"Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.", -- 275
			"filesHint is an optional list of likely files or directories." -- 276
		} -- 276
	} -- 276
} -- 276
local DEFAULT_SCHEMA_CONTEXT = {searchDoraApiLimitMax = 20} -- 281
local function hasRole(tool, role) -- 285
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 286
end -- 285
local function getToolPrompt(name) -- 289
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 290
		if tool.name == name then -- 290
			return tool -- 291
		end -- 291
	end -- 291
	return nil -- 293
end -- 289
local function formatParameterList(tool) -- 296
	local parameters = tool.parameters or ({}) -- 297
	if #parameters == 0 then -- 297
		return "" -- 298
	end -- 298
	return table.concat( -- 299
		__TS__ArrayMap( -- 299
			parameters, -- 299
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 300
		), -- 300
		", " -- 301
	) -- 301
end -- 296
local function formatToolPrompt(tool, index, context) -- 304
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 305
	local parameterList = formatParameterList(tool) -- 306
	if parameterList ~= "" then -- 306
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 308
	end -- 308
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 310
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 311
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 312
	end -- 312
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 314
		lines[#lines + 1] = "\t- " .. rule -- 315
	end -- 315
	return table.concat(lines, "\n") -- 317
end -- 304
local function formatXMLRepairToolReference(tool) -- 320
	local parameterList = formatParameterList(tool) -- 321
	local params = parameterList ~= "" and parameterList or "none" -- 322
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 323
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 324
end -- 320
function ____exports.isKnownToolName(name) -- 327
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 328
end -- 327
function ____exports.getAllowedToolsForRole(role) -- 331
	return __TS__ArrayMap( -- 332
		__TS__ArrayFilter( -- 332
			____exports.AGENT_TOOL_PROMPTS, -- 332
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) end -- 333
		), -- 333
		function(____, tool) return tool.name end -- 334
	) -- 334
end -- 331
function ____exports.getToolPromptsForRole(role, options) -- 337
	return __TS__ArrayFilter( -- 340
		____exports.AGENT_TOOL_PROMPTS, -- 340
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") end -- 340
	) -- 340
end -- 337
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 346
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 351
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 352
	local sections = __TS__ArrayMap( -- 353
		tools, -- 353
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 353
	) -- 353
	if (options and options.includeXmlRules) == true then -- 353
		sections[#sections + 1] = "XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 355
	end -- 355
	local body = table.concat(sections, "\n\n") -- 361
	return title ~= "" and (title .. "\n") .. body or body -- 362
end -- 346
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 365
	return ____exports.buildToolDefinitionsDetailed( -- 371
		____exports.getToolPromptsForRole(role, {includeFinish = options and options.includeFinish}), -- 372
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 373
	) -- 373
end -- 365
function ____exports.buildXMLRepairToolReference(role) -- 381
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true}) -- 382
	local ____array_16 = __TS__SparseArrayNew( -- 382
		"Allowed tools and XML params:", -- 384
		table.unpack(__TS__ArrayMap( -- 385
			tools, -- 385
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 385
		)) -- 385
	) -- 385
	__TS__SparseArrayPush( -- 385
		____array_16, -- 385
		"", -- 386
		"XML shape:", -- 387
		"- Wrap the decision in exactly one <tool_call> root.", -- 388
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 389
		"- For finish: include <tool> and <params><message>...</message></params>; omit <reason>.", -- 390
		"- Inside <params>, use one child tag per parameter name above." -- 391
	) -- 391
	local lines = {__TS__SparseArraySpread(____array_16)} -- 383
	return table.concat(lines, "\n") -- 393
end -- 381
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 396
	____exports.getToolPromptsForRole("sub"), -- 397
	{title = "Available tools:"} -- 398
) -- 398
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 401
	__TS__ArrayFilter( -- 402
		____exports.getToolPromptsForRole("main"), -- 402
		function(____, tool) return __TS__ArrayIndexOf( -- 403
			__TS__ArrayMap( -- 403
				____exports.getToolPromptsForRole("sub"), -- 403
				function(____, subTool) return subTool.name end -- 403
			), -- 403
			tool.name -- 403
		) < 0 end -- 403
	), -- 403
	{title = ""} -- 404
) -- 404
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 407
	__TS__ArrayFilter( -- 408
		____exports.AGENT_TOOL_PROMPTS, -- 408
		function(____, tool) return tool.name == "finish" end -- 408
	), -- 408
	{title = "", includeXmlRules = true} -- 409
) -- 409
function ____exports.canPreExecuteTool(tool) -- 412
	local prompt = getToolPrompt(tool) -- 413
	return (prompt and prompt.preExecutable) == true -- 414
end -- 412
function ____exports.canRunToolInParallel(tool) -- 417
	local prompt = getToolPrompt(tool) -- 418
	return (prompt and prompt.parallelSafe) == true -- 419
end -- 417
function ____exports.buildDecisionToolSchema(role, searchDoraApiLimitMax) -- 422
	local context = {searchDoraApiLimitMax = searchDoraApiLimitMax} -- 423
	return ____exports.buildDecisionToolSchemaForTools( -- 424
		____exports.getToolPromptsForRole(role), -- 424
		context -- 424
	) -- 424
end -- 422
return ____exports -- 422