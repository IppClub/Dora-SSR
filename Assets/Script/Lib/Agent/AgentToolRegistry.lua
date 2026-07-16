-- [ts]: AgentToolRegistry.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local resolveText, getToolDescription, getToolRules, getParameterDescription, createFunctionToolSchemaFromPrompt, BUILT_IN_AGENT_TOOL_NAMES -- 1
function resolveText(value, context) -- 120
	return type(value) == "string" and value or value(context) -- 121
end -- 121
function getToolDescription(tool, context) -- 124
	return resolveText(tool.description, context) -- 125
end -- 125
function getToolRules(tool, context) -- 128
	return __TS__ArrayMap( -- 129
		tool.rules or ({}), -- 129
		function(____, rule) return resolveText(rule, context) end -- 129
	) -- 129
end -- 129
function getParameterDescription(parameter, context) -- 132
	return resolveText(parameter.description, context) -- 133
end -- 133
function createFunctionToolSchemaFromPrompt(tool, context) -- 136
	local properties = {} -- 137
	local required = {} -- 138
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 139
		local property = { -- 140
			type = parameter.type, -- 141
			description = getParameterDescription(parameter, context) -- 142
		} -- 142
		if parameter.enum ~= nil then -- 142
			property.enum = parameter.enum -- 145
		end -- 145
		if parameter.items ~= nil then -- 145
			property.items = parameter.items -- 148
		end -- 148
		properties[parameter.name] = property -- 150
		if parameter.required == true then -- 150
			required[#required + 1] = parameter.name -- 152
		end -- 152
	end -- 152
	local parameters = {type = "object", properties = properties} -- 155
	if #required > 0 then -- 155
		parameters.required = required -- 160
	end -- 160
	local rules = getToolRules(tool, context) -- 162
	return { -- 163
		type = "function", -- 164
		["function"] = { -- 165
			name = tool.name, -- 166
			description = table.concat( -- 167
				{ -- 167
					getToolDescription(tool, context), -- 167
					table.unpack(rules) -- 167
				}, -- 167
				" " -- 167
			), -- 167
			parameters = parameters -- 168
		} -- 168
	} -- 168
end -- 168
function ____exports.isKnownToolName(name) -- 458
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 459
end -- 458
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 591
	return __TS__ArrayMap( -- 592
		tools, -- 592
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 593
	) -- 593
end -- 591
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
function ____exports.findUnsupportedDoraTsEdit(path, newStr) -- 72
	local normalized = string.lower(path) -- 73
	if not (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tsx")) or __TS__StringEndsWith(normalized, ".d.ts") then -- 73
		return nil -- 74
	end -- 74
	local isTestFile = __TS__StringEndsWith(normalized, "test.ts") or __TS__StringEndsWith(normalized, "test.tsx") -- 75
	local checks = { -- 76
		{"Math.random", "inject a deterministic RNG or use supported bounded arithmetic"}, -- 77
		{"Math.hypot", "use Math.sqrt(x * x + y * y)"}, -- 78
		{"Math.imul", "use ordinary bounded multiplication"}, -- 79
		{"KeyName.Enter", "use a declared Dora KeyName such as Space, Up, A, D, Left, or Right"}, -- 80
		{"ReturnType<typeof", "annotate Dora factory instances with X.Type"} -- 81
	} -- 81
	local lines = __TS__StringSplit(newStr, "\n") -- 83
	do -- 83
		local i = 0 -- 84
		while i < #lines do -- 84
			do -- 84
				local trimmed = __TS__StringTrim(lines[i + 1]) -- 85
				if __TS__StringStartsWith(trimmed, "//") or __TS__StringStartsWith(trimmed, "/*") or __TS__StringStartsWith(trimmed, "*") then -- 85
					goto __continue5 -- 86
				end -- 86
				local uncommented = __TS__StringSplit(lines[i + 1], "//")[1] or "" -- 87
				local code = "" -- 88
				local quote = "" -- 89
				local escaped = false -- 90
				do -- 90
					local j = 0 -- 91
					while j < #uncommented do -- 91
						local char = __TS__StringAccess(uncommented, j) -- 92
						if quote ~= "" then -- 92
							if escaped then -- 92
								escaped = false -- 94
							elseif char == "\\" then -- 94
								escaped = true -- 95
							elseif char == quote then -- 95
								quote = "" -- 96
							end -- 96
							code = code .. " " -- 97
						elseif char == "\"" or char == "'" or char == "`" then -- 97
							quote = char -- 99
							code = code .. " " -- 100
						else -- 100
							code = code .. char -- 102
						end -- 102
						j = j + 1 -- 91
					end -- 91
				end -- 91
				for ____, ____value in ipairs(checks) do -- 105
					local token = ____value[1] -- 105
					local replacement = ____value[2] -- 105
					if (string.find(code, token, nil, true) or 0) - 1 >= 0 then -- 105
						return ((token .. " is unsupported in Dora TypeScript; ") .. replacement) .. ". The edit was not applied. Correct this replacement before continuing." -- 107
					end -- 107
				end -- 107
				if isTestFile then -- 107
					local compactCode = table.concat( -- 111
						__TS__StringSplit( -- 111
							table.concat( -- 111
								__TS__StringSplit(code, " "), -- 111
								"" -- 111
							), -- 111
							"\t" -- 111
						), -- 111
						"" -- 111
					) -- 111
					if (string.find(compactCode, "||true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "check(true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "assert(true", nil, true) or 0) - 1 >= 0 then -- 111
						return "Vacuous always-true assertions are not allowed in authored test files. Replace the tautology with a deterministic observable condition that can fail. The edit was not applied." -- 113
					end -- 113
				end -- 113
			end -- 113
			::__continue5:: -- 113
			i = i + 1 -- 84
		end -- 84
	end -- 84
	return nil -- 117
end -- 72
____exports.AGENT_TOOL_PROMPTS = { -- 173
	{ -- 174
		name = "read_file", -- 175
		roles = {"main", "sub"}, -- 176
		description = "Read a specific line range from a file.", -- 177
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to read."}, {name = "startLine", type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, -- 178
		rules = {"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative."}, -- 183
		preExecutable = true, -- 186
		parallelSafe = true -- 187
	}, -- 187
	{ -- 189
		name = "edit_file", -- 190
		roles = {"main", "sub"}, -- 191
		description = "Make changes to a file.", -- 192
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to edit."}, {name = "old_str", type = "string", required = true, description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, {name = "new_str", type = "string", required = true, description = "Replacement text or the full file content when rewriting or creating."}}, -- 193
		rules = { -- 198
			"old_str and new_str MUST be different.", -- 199
			"old_str must match existing text exactly when it is non-empty.", -- 200
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.", -- 201
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build.", -- 202
			"For Dora .ts/.tsx source, the engine rejects known unsupported constructs before writing: Math.random, Math.hypot, Math.imul, KeyName.Enter, and ReturnType<typeof DoraFactory>. Inject or implement a bounded RNG, use supported arithmetic/key names, and annotate Dora instances with X.Type." -- 203
		} -- 203
	}, -- 203
	{name = "delete_file", roles = {"main", "sub"}, description = "Remove a file.", parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}}}, -- 206
	{ -- 214
		name = "grep_files", -- 215
		roles = {"main", "sub"}, -- 216
		description = "Search text patterns inside files.", -- 217
		parameters = { -- 218
			{name = "path", type = "string", description = "Base directory or file path to search within."}, -- 219
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 220
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 221
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 222
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 223
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 224
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 225
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 226
		}, -- 226
		rules = { -- 228
			"`path` may point to either a directory or a single file.", -- 229
			"This is content search (grep), not filename search.", -- 230
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 231
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 232
			"`caseSensitive` defaults to false.", -- 233
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 234
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 235
		}, -- 235
		preExecutable = true, -- 237
		parallelSafe = true -- 238
	}, -- 238
	{ -- 240
		name = "glob_files", -- 241
		roles = {"main", "sub"}, -- 242
		description = "Enumerate files under a directory.", -- 243
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 244
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 249
		preExecutable = true, -- 253
		parallelSafe = true -- 254
	}, -- 254
	{ -- 256
		name = "search_dora_api", -- 257
		roles = {"main", "sub"}, -- 258
		description = "Search Dora SSR game engine docs and tutorials.", -- 259
		parameters = { -- 260
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 261
			{name = "docSource", type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials. Defaults to api."}, -- 262
			{name = "programmingLanguage", type = "string", enum = { -- 263
				"ts", -- 263
				"tsx", -- 263
				"lua", -- 263
				"yue", -- 263
				"teal", -- 263
				"tl", -- 263
				"wa" -- 263
			}, description = "Preferred language variant to search."}, -- 263
			{ -- 264
				name = "limit", -- 264
				type = "number", -- 264
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 264
			}, -- 264
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 265
		}, -- 265
		rules = { -- 267
			"`docSource` defaults to `api`. Use `tutorial` to search teaching docs.", -- 268
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 269
			"`useRegex` defaults to false whenever supported by a search tool.", -- 270
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 271
		}, -- 271
		preExecutable = true, -- 273
		parallelSafe = true -- 274
	}, -- 274
	{ -- 276
		name = "build", -- 277
		roles = {"main", "sub"}, -- 278
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 279
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 280
		rules = {"Read the result and then decide whether another action is needed."} -- 283
	}, -- 283
	{ -- 287
		name = "fetch_url", -- 288
		roles = {"main", "sub"}, -- 289
		description = "Download a single HTTP or HTTPS resource into the project.", -- 290
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 291
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds.", "Use execute_command with mode=git for Git operations such as clone, status, diff, add, commit, pull, fetch, and push."} -- 295
	}, -- 295
	{ -- 302
		name = "execute_command", -- 303
		roles = {"main", "sub"}, -- 304
		description = "Execute a controlled engine command.", -- 305
		parameters = { -- 306
			{ -- 307
				name = "mode", -- 307
				type = "string", -- 307
				required = true, -- 307
				enum = {"lua", "git"}, -- 307
				description = "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." -- 307
			}, -- 307
			{name = "code", type = "string", description = "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result."}, -- 308
			{name = "command", type = "string", description = "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported."}, -- 309
			{name = "cwd", type = "string", description = "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C."}, -- 310
			{name = "timeoutSeconds", type = "number", description = "Optional timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode can stop cooperative engine work but cannot interrupt a pure CPU loop that never yields."} -- 311
		}, -- 311
		rules = { -- 313
			"This tool is available only when the user enables command execution for the current Agent task.", -- 314
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 315
			"Lua mode runs with a temporary environment whose global lookups fall back to Dora APIs; global writes stay in that one command and are not shared with later commands.", -- 316
			"Lua mode exposes projectDir, refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). getEntryStatus() returns a table containing success and running booleans.", -- 317
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 318
			"Call refreshTree(\"relative/file\") after single-file changes, or refreshTree() after directory or bulk changes.", -- 319
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 320
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.", -- 321
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 322
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.", -- 323
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten." -- 324
		} -- 324
	}, -- 324
	{ -- 327
		name = "finish", -- 328
		roles = {"main", "sub"}, -- 329
		description = "End the task and provide a structured completion handoff.", -- 330
		parameters = { -- 331
			{name = "message", type = "string", required = true, description = "Final user-facing answer."}, -- 332
			{name = "outcome", type = "string", enum = {"completed", "partial", "blocked"}, description = "Work outcome. Sub agents must provide this; defaults to completed for compatibility."}, -- 333
			{name = "validation", type = "array", items = {type = "object", properties = {kind = {type = "string", enum = {"build", "runtime", "manual"}}, result = {type = "string", enum = {"passed", "failed", "not_run"}}, evidence = {type = "array", items = {type = "string"}}}, required = {"kind", "result"}}, description = "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."}, -- 334
			{name = "knownIssues", type = "array", items = {type = "string"}, description = "Known remaining issues or blockers. Sub agents must provide an array, which may be empty."}, -- 343
			{name = "assumptions", type = "array", items = {type = "string"}, description = "Material assumptions made during the work. Sub agents must provide an array, which may be empty."}, -- 344
			{name = "learningCandidates", type = "array", items = {type = "object", properties = {claim = {type = "string"}, scope = {type = "string", enum = {"file", "project", "engine"}}, evidence = {type = "array", items = {type = "string"}}, confidence = {type = "string", enum = {"observed", "inferred"}}}, required = {"claim", "scope", "confidence"}}, description = "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."} -- 345
		}, -- 345
		rules = {"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.", "Do not claim validation passed without concrete evidence from the corresponding tool result.", "Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration."} -- 356
	}, -- 356
	{ -- 362
		name = "list_sub_agents", -- 363
		roles = {"main"}, -- 364
		description = "Query sub-agent state under the current main session.", -- 365
		parameters = {{name = "status", type = "string", enum = { -- 366
			"active_or_recent", -- 367
			"running", -- 367
			"done", -- 367
			"failed", -- 367
			"all" -- 367
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 367
		rules = { -- 372
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 373
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 374
			"limit defaults to a small recent window. Use offset to page older items.", -- 375
			"query filters by title, goal, or summary text.", -- 376
			"Do not poll immediately after spawning. Use this later only when the current status is unknown and affects the next decision." -- 377
		}, -- 377
		preExecutable = true, -- 379
		parallelSafe = true -- 380
	}, -- 380
	{ -- 382
		name = "spawn_sub_agent", -- 383
		roles = {"main"}, -- 384
		description = "Create and start a sub agent session for delegated implementation work.", -- 385
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 386
		rules = { -- 392
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 393
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 394
			"The spawned sub agent inherits the current session tool capabilities, including fetch_url and execute_command when enabled.", -- 395
			"title should be short and specific.", -- 396
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 397
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 398
			"After dispatching, continue useful foreground work or finish the turn when there is nothing else useful to do.", -- 399
			"Do not poll a newly spawned sub agent in the same turn. Its completion is delivered asynchronously as a later handoff.", -- 400
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.", -- 401
			"filesHint is an optional list of likely files or directories." -- 402
		} -- 402
	} -- 402
} -- 402
local DEFAULT_SCHEMA_CONTEXT = {searchDoraApiLimitMax = 20} -- 407
local function hasRole(tool, role) -- 411
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 412
end -- 411
local function getToolPrompt(name) -- 415
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 416
		if tool.name == name then -- 416
			return tool -- 417
		end -- 417
	end -- 417
	return nil -- 419
end -- 415
local function isToolCapabilityEnabled(tool, options) -- 422
	if not ____exports.isKnownToolName(tool.name) then -- 422
		return false -- 423
	end -- 423
	return __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 424
end -- 422
local function formatParameterList(tool) -- 427
	local parameters = tool.parameters or ({}) -- 428
	if #parameters == 0 then -- 428
		return "" -- 429
	end -- 429
	return table.concat( -- 430
		__TS__ArrayMap( -- 430
			parameters, -- 430
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 431
		), -- 431
		", " -- 432
	) -- 432
end -- 427
local function formatToolPrompt(tool, index, context) -- 435
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 436
	local parameterList = formatParameterList(tool) -- 437
	if parameterList ~= "" then -- 437
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 439
	end -- 439
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 441
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 442
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 443
	end -- 443
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 445
		lines[#lines + 1] = "\t- " .. rule -- 446
	end -- 446
	return table.concat(lines, "\n") -- 448
end -- 435
local function formatXMLRepairToolReference(tool) -- 451
	local parameterList = formatParameterList(tool) -- 452
	local params = parameterList ~= "" and parameterList or "none" -- 453
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 454
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 455
end -- 451
function ____exports.getAllowedToolsForRole(role, options) -- 462
	return __TS__ArrayMap( -- 463
		__TS__ArrayFilter( -- 463
			____exports.AGENT_TOOL_PROMPTS, -- 463
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 464
		), -- 464
		function(____, tool) return tool.name end -- 465
	) -- 465
end -- 462
function ____exports.getToolPromptsForRole(role, options) -- 468
	return __TS__ArrayFilter( -- 472
		____exports.AGENT_TOOL_PROMPTS, -- 472
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 472
	) -- 472
end -- 468
local SUB_AGENT_REQUIRED_FINISH_PARAMS = { -- 479
	"message", -- 480
	"outcome", -- 481
	"validation", -- 482
	"knownIssues", -- 483
	"assumptions", -- 484
	"learningCandidates" -- 485
} -- 485
local function getDecisionToolPromptsForRole(role, options) -- 488
	local tools = ____exports.getToolPromptsForRole(role, options) -- 492
	if role ~= "sub" then -- 492
		return tools -- 493
	end -- 493
	return __TS__ArrayMap( -- 494
		tools, -- 494
		function(____, tool) return tool.name ~= "finish" and tool or __TS__ObjectAssign( -- 494
			{}, -- 494
			tool, -- 495
			{parameters = __TS__ArrayMap( -- 494
				tool.parameters or ({}), -- 496
				function(____, parameter) return __TS__ObjectAssign( -- 496
					{}, -- 496
					parameter, -- 497
					{required = __TS__ArrayIndexOf(SUB_AGENT_REQUIRED_FINISH_PARAMS, parameter.name) >= 0} -- 496
				) end -- 496
			)} -- 496
		) end -- 496
	) -- 496
end -- 488
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 503
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 508
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 509
	local sections = __TS__ArrayMap( -- 510
		tools, -- 510
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 510
	) -- 510
	if (options and options.includeXmlRules) == true then -- 510
		sections[#sections + 1] = "XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, fetch_url, and execute_command, include <tool>, <reason>, and <params>.\n- For finish, omit <reason> and include <message> plus every other required parameter shown above inside <params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 512
	end -- 512
	local body = table.concat(sections, "\n\n") -- 518
	return title ~= "" and (title .. "\n") .. body or body -- 519
end -- 503
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 522
	return ____exports.buildToolDefinitionsDetailed( -- 529
		getDecisionToolPromptsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools}), -- 530
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 534
	) -- 534
end -- 522
function ____exports.buildXMLRepairToolReference(role, options) -- 542
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools}) -- 543
	local ____array_22 = __TS__SparseArrayNew( -- 543
		"Allowed tools and XML params:", -- 545
		table.unpack(__TS__ArrayMap( -- 546
			tools, -- 546
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 546
		)) -- 546
	) -- 546
	__TS__SparseArrayPush( -- 546
		____array_22, -- 546
		"", -- 547
		"XML shape:", -- 548
		"- Wrap the decision in exactly one <tool_call> root.", -- 549
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 550
		"- For finish: include <tool>, omit <reason>, and include <message> plus every other required parameter shown above inside <params>.", -- 551
		"- Inside <params>, use one child tag per parameter name above." -- 552
	) -- 552
	local lines = {__TS__SparseArraySpread(____array_22)} -- 544
	return table.concat(lines, "\n") -- 554
end -- 542
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 557
	____exports.getToolPromptsForRole("sub"), -- 558
	{title = "Available tools:"} -- 559
) -- 559
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 562
	__TS__ArrayFilter( -- 563
		____exports.getToolPromptsForRole("main"), -- 563
		function(____, tool) return __TS__ArrayIndexOf( -- 564
			__TS__ArrayMap( -- 564
				____exports.getToolPromptsForRole("sub"), -- 564
				function(____, subTool) return subTool.name end -- 564
			), -- 564
			tool.name -- 564
		) < 0 end -- 564
	), -- 564
	{title = ""} -- 565
) -- 565
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 568
	__TS__ArrayFilter( -- 569
		____exports.AGENT_TOOL_PROMPTS, -- 569
		function(____, tool) return tool.name == "finish" end -- 569
	), -- 569
	{title = "", includeXmlRules = true} -- 570
) -- 570
function ____exports.canPreExecuteTool(tool) -- 573
	local prompt = getToolPrompt(tool) -- 574
	return (prompt and prompt.preExecutable) == true -- 575
end -- 573
function ____exports.canRunToolInParallel(tool) -- 578
	local prompt = getToolPrompt(tool) -- 579
	return (prompt and prompt.parallelSafe) == true -- 580
end -- 578
function ____exports.buildDecisionToolSchema(role, searchDoraApiLimitMax, options) -- 583
	local context = {searchDoraApiLimitMax = searchDoraApiLimitMax} -- 584
	return ____exports.buildDecisionToolSchemaForTools( -- 585
		getDecisionToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools}), -- 585
		context -- 588
	) -- 588
end -- 583
return ____exports -- 583