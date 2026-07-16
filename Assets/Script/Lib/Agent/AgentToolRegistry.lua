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
function resolveText(value, context) -- 134
	return type(value) == "string" and value or value(context) -- 135
end -- 135
function getToolDescription(tool, context) -- 138
	return resolveText(tool.description, context) -- 139
end -- 139
function getToolRules(tool, context) -- 142
	return __TS__ArrayMap( -- 143
		tool.rules or ({}), -- 143
		function(____, rule) return resolveText(rule, context) end -- 143
	) -- 143
end -- 143
function getParameterDescription(parameter, context) -- 146
	return resolveText(parameter.description, context) -- 147
end -- 147
function createFunctionToolSchemaFromPrompt(tool, context) -- 150
	local properties = {} -- 151
	local required = {} -- 152
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 153
		local property = { -- 154
			type = parameter.type, -- 155
			description = getParameterDescription(parameter, context) -- 156
		} -- 156
		if parameter.enum ~= nil then -- 156
			property.enum = parameter.enum -- 159
		end -- 159
		if parameter.items ~= nil then -- 159
			property.items = parameter.items -- 162
		end -- 162
		properties[parameter.name] = property -- 164
		if parameter.required == true then -- 164
			required[#required + 1] = parameter.name -- 166
		end -- 166
	end -- 166
	local parameters = {type = "object", properties = properties} -- 169
	if #required > 0 then -- 169
		parameters.required = required -- 174
	end -- 174
	local rules = getToolRules(tool, context) -- 176
	return { -- 177
		type = "function", -- 178
		["function"] = { -- 179
			name = tool.name, -- 180
			description = table.concat( -- 181
				{ -- 181
					getToolDescription(tool, context), -- 181
					table.unpack(rules) -- 181
				}, -- 181
				" " -- 181
			), -- 181
			parameters = parameters -- 182
		} -- 182
	} -- 182
end -- 182
function ____exports.isKnownToolName(name) -- 470
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 471
end -- 470
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 641
	return __TS__ArrayMap( -- 642
		tools, -- 642
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 643
	) -- 643
end -- 641
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
function ____exports.findUnsupportedDoraTsEdit(path, newStr) -- 86
	local normalized = string.lower(path) -- 87
	if not (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tsx")) or __TS__StringEndsWith(normalized, ".d.ts") then -- 87
		return nil -- 88
	end -- 88
	local isTestFile = __TS__StringEndsWith(normalized, "test.ts") or __TS__StringEndsWith(normalized, "test.tsx") -- 89
	local checks = { -- 90
		{"Math.random", "inject a deterministic RNG or use supported bounded arithmetic"}, -- 91
		{"Math.hypot", "use Math.sqrt(x * x + y * y)"}, -- 92
		{"Math.imul", "use ordinary bounded multiplication"}, -- 93
		{"KeyName.Enter", "use a declared Dora KeyName such as Space, Up, A, D, Left, or Right"}, -- 94
		{"ReturnType<typeof", "annotate Dora factory instances with X.Type"} -- 95
	} -- 95
	local lines = __TS__StringSplit(newStr, "\n") -- 97
	do -- 97
		local i = 0 -- 98
		while i < #lines do -- 98
			do -- 98
				local trimmed = __TS__StringTrim(lines[i + 1]) -- 99
				if __TS__StringStartsWith(trimmed, "//") or __TS__StringStartsWith(trimmed, "/*") or __TS__StringStartsWith(trimmed, "*") then -- 99
					goto __continue5 -- 100
				end -- 100
				local uncommented = __TS__StringSplit(lines[i + 1], "//")[1] or "" -- 101
				local code = "" -- 102
				local quote = "" -- 103
				local escaped = false -- 104
				do -- 104
					local j = 0 -- 105
					while j < #uncommented do -- 105
						local char = __TS__StringAccess(uncommented, j) -- 106
						if quote ~= "" then -- 106
							if escaped then -- 106
								escaped = false -- 108
							elseif char == "\\" then -- 108
								escaped = true -- 109
							elseif char == quote then -- 109
								quote = "" -- 110
							end -- 110
							code = code .. " " -- 111
						elseif char == "\"" or char == "'" or char == "`" then -- 111
							quote = char -- 113
							code = code .. " " -- 114
						else -- 114
							code = code .. char -- 116
						end -- 116
						j = j + 1 -- 105
					end -- 105
				end -- 105
				for ____, ____value in ipairs(checks) do -- 119
					local token = ____value[1] -- 119
					local replacement = ____value[2] -- 119
					if (string.find(code, token, nil, true) or 0) - 1 >= 0 then -- 119
						return ((token .. " is unsupported in Dora TypeScript; ") .. replacement) .. ". The edit was not applied. Correct this replacement before continuing." -- 121
					end -- 121
				end -- 121
				if isTestFile then -- 121
					local compactCode = table.concat( -- 125
						__TS__StringSplit( -- 125
							table.concat( -- 125
								__TS__StringSplit(code, " "), -- 125
								"" -- 125
							), -- 125
							"\t" -- 125
						), -- 125
						"" -- 125
					) -- 125
					if (string.find(compactCode, "||true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "check(true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "assert(true", nil, true) or 0) - 1 >= 0 then -- 125
						return "Vacuous always-true assertions are not allowed in authored test files. Replace the tautology with a deterministic observable condition that can fail. The edit was not applied." -- 127
					end -- 127
				end -- 127
			end -- 127
			::__continue5:: -- 127
			i = i + 1 -- 98
		end -- 98
	end -- 98
	return nil -- 131
end -- 86
____exports.AGENT_TOOL_PROMPTS = { -- 187
	{ -- 188
		name = "read_file", -- 189
		roles = {"main", "sub"}, -- 190
		description = "Read a specific line range from a file.", -- 191
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to read."}, {name = "startLine", type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, -- 192
		rules = {"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative."}, -- 197
		parallelSafe = true -- 200
	}, -- 200
	{ -- 202
		name = "edit_file", -- 203
		roles = {"main", "sub"}, -- 204
		description = "Make changes to a file.", -- 205
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to edit."}, {name = "old_str", type = "string", required = true, description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, {name = "new_str", type = "string", required = true, description = "Replacement text or the full file content when rewriting or creating."}}, -- 206
		rules = { -- 211
			"old_str and new_str MUST be different.", -- 212
			"old_str must match existing text exactly when it is non-empty.", -- 213
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.", -- 214
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build.", -- 215
			"For Dora .ts/.tsx source, the engine rejects known unsupported constructs before writing: Math.random, Math.hypot, Math.imul, KeyName.Enter, and ReturnType<typeof DoraFactory>. Inject or implement a bounded RNG, use supported arithmetic/key names, and annotate Dora instances with X.Type." -- 216
		} -- 216
	}, -- 216
	{name = "delete_file", roles = {"main", "sub"}, description = "Remove a file.", parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}}}, -- 219
	{ -- 227
		name = "grep_files", -- 228
		roles = {"main", "sub"}, -- 229
		description = "Search text patterns inside files.", -- 230
		parameters = { -- 231
			{name = "path", type = "string", description = "Base directory or file path to search within."}, -- 232
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 233
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 234
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 235
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 236
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 237
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 238
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 239
		}, -- 239
		rules = { -- 241
			"`path` may point to either a directory or a single file.", -- 242
			"This is content search (grep), not filename search.", -- 243
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 244
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 245
			"`caseSensitive` defaults to false.", -- 246
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 247
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 248
		}, -- 248
		preExecutable = true, -- 250
		parallelSafe = true -- 251
	}, -- 251
	{ -- 253
		name = "glob_files", -- 254
		roles = {"main", "sub"}, -- 255
		description = "Enumerate files under a directory.", -- 256
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 257
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 262
		preExecutable = true, -- 266
		parallelSafe = true -- 267
	}, -- 267
	{ -- 269
		name = "search_dora_api", -- 270
		roles = {"main", "sub"}, -- 271
		description = "Search Dora SSR game engine docs and tutorials.", -- 272
		parameters = { -- 273
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 274
			{name = "docSource", type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials. Defaults to api."}, -- 275
			{name = "programmingLanguage", type = "string", enum = { -- 276
				"ts", -- 276
				"tsx", -- 276
				"lua", -- 276
				"yue", -- 276
				"teal", -- 276
				"tl", -- 276
				"wa" -- 276
			}, description = "Preferred language variant to search."}, -- 276
			{ -- 277
				name = "limit", -- 277
				type = "number", -- 277
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 277
			}, -- 277
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 278
		}, -- 278
		rules = { -- 280
			"`docSource` defaults to `api`. Use `tutorial` to search teaching docs.", -- 281
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 282
			"`useRegex` defaults to false whenever supported by a search tool.", -- 283
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 284
		}, -- 284
		preExecutable = true, -- 286
		parallelSafe = true -- 287
	}, -- 287
	{ -- 289
		name = "build", -- 290
		roles = {"main", "sub"}, -- 291
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 292
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 293
		rules = {"Read the result and then decide whether another action is needed."} -- 296
	}, -- 296
	{ -- 300
		name = "fetch_url", -- 301
		roles = {"main", "sub"}, -- 302
		description = "Download a single HTTP or HTTPS resource into the project.", -- 303
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 304
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds.", "Use execute_command with mode=git for Git operations such as clone, status, diff, add, commit, pull, fetch, and push."} -- 308
	}, -- 308
	{ -- 315
		name = "execute_command", -- 316
		roles = {"main", "sub"}, -- 317
		description = "Execute a controlled engine command.", -- 318
		parameters = { -- 319
			{ -- 320
				name = "mode", -- 320
				type = "string", -- 320
				required = true, -- 320
				enum = {"lua", "git"}, -- 320
				description = "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." -- 320
			}, -- 320
			{name = "code", type = "string", description = "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result."}, -- 321
			{name = "command", type = "string", description = "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported."}, -- 322
			{name = "cwd", type = "string", description = "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C."}, -- 323
			{name = "timeoutSeconds", type = "number", description = "Optional timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode can stop cooperative engine work but cannot interrupt a pure CPU loop that never yields."} -- 324
		}, -- 324
		rules = { -- 326
			"This tool is available only when the user enables command execution for the current Agent task.", -- 327
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 328
			"Lua mode runs with a temporary environment whose global lookups fall back to Dora APIs; global writes stay in that one command and are not shared with later commands.", -- 329
			"Lua mode exposes projectDir, refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). getEntryStatus() returns a table containing success and running booleans.", -- 330
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 331
			"Call refreshTree(\"relative/file\") after single-file changes, or refreshTree() after directory or bulk changes.", -- 332
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 333
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.", -- 334
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 335
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.", -- 336
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten." -- 337
		} -- 337
	}, -- 337
	{ -- 340
		name = "finish", -- 341
		roles = {"main", "sub"}, -- 342
		description = "End the task and provide a structured completion handoff.", -- 343
		parameters = { -- 344
			{name = "message", type = "string", required = true, description = "Final user-facing answer."}, -- 345
			{name = "outcome", type = "string", enum = {"completed", "partial", "blocked"}, description = "Work outcome. Sub agents must provide this; defaults to completed for compatibility."}, -- 346
			{name = "validation", type = "array", items = {type = "object", properties = {kind = {type = "string", enum = {"build", "runtime", "manual"}}, result = {type = "string", enum = {"passed", "failed", "not_run"}}, evidence = {type = "array", items = {type = "string"}}}, required = {"kind", "result"}}, description = "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."}, -- 347
			{name = "knownIssues", type = "array", items = {type = "string"}, description = "Known remaining issues or blockers. Sub agents must provide an array, which may be empty."}, -- 356
			{name = "assumptions", type = "array", items = {type = "string"}, description = "Material assumptions made during the work. Sub agents must provide an array, which may be empty."}, -- 357
			{name = "learningCandidates", type = "array", items = {type = "object", properties = {claim = {type = "string"}, scope = {type = "string", enum = {"file", "project", "engine"}}, evidence = {type = "array", items = {type = "string"}}, confidence = {type = "string", enum = {"observed", "inferred"}}}, required = {"claim", "scope", "confidence"}}, description = "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."} -- 358
		}, -- 358
		rules = {"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.", "Do not claim validation passed without concrete evidence from the corresponding tool result.", "Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration."} -- 369
	}, -- 369
	{ -- 375
		name = "list_sub_agents", -- 376
		roles = {"main"}, -- 377
		description = "Query sub-agent state under the current main session.", -- 378
		parameters = {{name = "status", type = "string", enum = { -- 379
			"active_or_recent", -- 380
			"running", -- 380
			"done", -- 380
			"failed", -- 380
			"all" -- 380
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 380
		rules = { -- 385
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 386
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 387
			"limit defaults to a small recent window. Use offset to page older items.", -- 388
			"query filters by title, goal, or summary text.", -- 389
			"After any successful spawn_sub_agent in the current task, this tool is unavailable for the rest of that task. Finish the turn instead; completion arrives through an asynchronous handoff." -- 390
		}, -- 390
		parallelSafe = true -- 392
	}, -- 392
	{ -- 394
		name = "spawn_sub_agent", -- 395
		roles = {"main"}, -- 396
		description = "Create and start a sub agent session for delegated implementation work.", -- 397
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 398
		rules = { -- 404
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 405
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 406
			"The spawned sub agent inherits the current session tool capabilities, including fetch_url and execute_command when enabled.", -- 407
			"title should be short and specific.", -- 408
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 409
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 410
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish the current turn and return control to the user while the sub agents keep running.", -- 411
			"After a successful spawn in the current task, do not call list_sub_agents, wait, join, or poll. Completion is delivered asynchronously as a later handoff.", -- 412
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.", -- 413
			"filesHint is an optional list of likely files or directories." -- 414
		} -- 414
	} -- 414
} -- 414
local DEFAULT_SCHEMA_CONTEXT = {searchDoraApiLimitMax = 20} -- 419
local function hasRole(tool, role) -- 423
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 424
end -- 423
local function getToolPrompt(name) -- 427
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 428
		if tool.name == name then -- 428
			return tool -- 429
		end -- 429
	end -- 429
	return nil -- 431
end -- 427
local function isToolCapabilityEnabled(tool, options) -- 434
	if not ____exports.isKnownToolName(tool.name) then -- 434
		return false -- 435
	end -- 435
	return __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 436
end -- 434
local function formatParameterList(tool) -- 439
	local parameters = tool.parameters or ({}) -- 440
	if #parameters == 0 then -- 440
		return "" -- 441
	end -- 441
	return table.concat( -- 442
		__TS__ArrayMap( -- 442
			parameters, -- 442
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 443
		), -- 443
		", " -- 444
	) -- 444
end -- 439
local function formatToolPrompt(tool, index, context) -- 447
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 448
	local parameterList = formatParameterList(tool) -- 449
	if parameterList ~= "" then -- 449
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 451
	end -- 451
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 453
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 454
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 455
	end -- 455
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 457
		lines[#lines + 1] = "\t- " .. rule -- 458
	end -- 458
	return table.concat(lines, "\n") -- 460
end -- 447
local function formatXMLRepairToolReference(tool) -- 463
	local parameterList = formatParameterList(tool) -- 464
	local params = parameterList ~= "" and parameterList or "none" -- 465
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 466
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 467
end -- 463
function ____exports.getAllowedToolsForRole(role, options) -- 474
	return __TS__ArrayMap( -- 475
		__TS__ArrayFilter( -- 475
			____exports.AGENT_TOOL_PROMPTS, -- 475
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 476
		), -- 476
		function(____, tool) return tool.name end -- 477
	) -- 477
end -- 474
function ____exports.buildCurrentToolAvailabilityPrompt(context) -- 480
	local taskTools = ____exports.getAllowedToolsForRole(context.role, {disabledAgentTools = context.taskDisabledAgentTools}) -- 481
	local currentTools = ____exports.getAllowedToolsForRole(context.role, {disabledAgentTools = context.currentDisabledAgentTools}) -- 484
	local unavailable = __TS__ArrayFilter( -- 487
		taskTools, -- 487
		function(____, tool) return __TS__ArrayIndexOf(currentTools, tool) < 0 end -- 487
	) -- 487
	local lines = { -- 488
		"Current tool availability:", -- 489
		"- unavailable: " .. (#unavailable > 0 and table.concat(unavailable, ", ") or "none") -- 490
	} -- 490
	if context.resumeRequiredTool ~= nil then -- 490
		lines[#lines + 1] = ("- next required tool: " .. context.resumeRequiredTool) .. "; the execution layer will reject every other tool" -- 493
	end -- 493
	if context.hasSpawnedSubAgentThisTask == true then -- 493
		lines[#lines + 1] = "- after delegation: do not poll or wait; dispatch other independent sub-agents if needed, do only bounded independent foreground work, then finish this turn" -- 496
	end -- 496
	if context.delegatedForegroundBudgetExhausted == true then -- 496
		lines[#lines + 1] = "- foreground budget exhausted: use only spawn_sub_agent or finish" -- 499
	end -- 499
	if context.freshProjectBuildPending == true then -- 499
		lines[#lines + 1] = context.freshProjectCodeFile ~= nil and ("- fresh small project: coherently rewrite " .. context.freshProjectCodeFile) .. ", then build before discovery or command validation" or "- fresh empty project: create the requested entry directly, then build before discovery or command validation" -- 502
	end -- 502
	if context.buildRepairPending == true then -- 502
		lines[#lines + 1] = "- compiler repair: fix the reported authored-file diagnostics directly, then build again" -- 507
	end -- 507
	if context.editBudgetExhausted == true then -- 507
		lines[#lines + 1] = "- edit budget exhausted: build before making more source edits" -- 510
	end -- 510
	if context.repeatedDeterministicTestFailure == true then -- 510
		lines[#lines + 1] = "- repeated deterministic failure: make one narrow source fix, build, and rerun once without broad discovery" -- 513
	end -- 513
	return table.concat(lines, "\n") -- 515
end -- 480
function ____exports.getToolPromptsForRole(role, options) -- 518
	return __TS__ArrayFilter( -- 522
		____exports.AGENT_TOOL_PROMPTS, -- 522
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 522
	) -- 522
end -- 518
local SUB_AGENT_REQUIRED_FINISH_PARAMS = { -- 529
	"message", -- 530
	"outcome", -- 531
	"validation", -- 532
	"knownIssues", -- 533
	"assumptions", -- 534
	"learningCandidates" -- 535
} -- 535
local function getDecisionToolPromptsForRole(role, options) -- 538
	local tools = ____exports.getToolPromptsForRole(role, options) -- 542
	if role ~= "sub" then -- 542
		return tools -- 543
	end -- 543
	return __TS__ArrayMap( -- 544
		tools, -- 544
		function(____, tool) return tool.name ~= "finish" and tool or __TS__ObjectAssign( -- 544
			{}, -- 544
			tool, -- 545
			{parameters = __TS__ArrayMap( -- 544
				tool.parameters or ({}), -- 546
				function(____, parameter) return __TS__ObjectAssign( -- 546
					{}, -- 546
					parameter, -- 547
					{required = __TS__ArrayIndexOf(SUB_AGENT_REQUIRED_FINISH_PARAMS, parameter.name) >= 0} -- 546
				) end -- 546
			)} -- 546
		) end -- 546
	) -- 546
end -- 538
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 553
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 558
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 559
	local sections = __TS__ArrayMap( -- 560
		tools, -- 560
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 560
	) -- 560
	if (options and options.includeXmlRules) == true then -- 560
		sections[#sections + 1] = "XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, fetch_url, and execute_command, include <tool>, <reason>, and <params>.\n- For finish, omit <reason> and include <message> plus every other required parameter shown above inside <params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 562
	end -- 562
	local body = table.concat(sections, "\n\n") -- 568
	return title ~= "" and (title .. "\n") .. body or body -- 569
end -- 553
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 572
	return ____exports.buildToolDefinitionsDetailed( -- 579
		getDecisionToolPromptsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools}), -- 580
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 584
	) -- 584
end -- 572
function ____exports.buildXMLRepairToolReference(role, options) -- 592
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools}) -- 593
	local ____array_22 = __TS__SparseArrayNew( -- 593
		"Allowed tools and XML params:", -- 595
		table.unpack(__TS__ArrayMap( -- 596
			tools, -- 596
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 596
		)) -- 596
	) -- 596
	__TS__SparseArrayPush( -- 596
		____array_22, -- 596
		"", -- 597
		"XML shape:", -- 598
		"- Wrap the decision in exactly one <tool_call> root.", -- 599
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 600
		"- For finish: include <tool>, omit <reason>, and include <message> plus every other required parameter shown above inside <params>.", -- 601
		"- Inside <params>, use one child tag per parameter name above." -- 602
	) -- 602
	local lines = {__TS__SparseArraySpread(____array_22)} -- 594
	return table.concat(lines, "\n") -- 604
end -- 592
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 607
	____exports.getToolPromptsForRole("sub"), -- 608
	{title = "Available tools:"} -- 609
) -- 609
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 612
	__TS__ArrayFilter( -- 613
		____exports.getToolPromptsForRole("main"), -- 613
		function(____, tool) return __TS__ArrayIndexOf( -- 614
			__TS__ArrayMap( -- 614
				____exports.getToolPromptsForRole("sub"), -- 614
				function(____, subTool) return subTool.name end -- 614
			), -- 614
			tool.name -- 614
		) < 0 end -- 614
	), -- 614
	{title = ""} -- 615
) -- 615
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 618
	__TS__ArrayFilter( -- 619
		____exports.AGENT_TOOL_PROMPTS, -- 619
		function(____, tool) return tool.name == "finish" end -- 619
	), -- 619
	{title = "", includeXmlRules = true} -- 620
) -- 620
function ____exports.canPreExecuteTool(tool) -- 623
	local prompt = getToolPrompt(tool) -- 624
	return (prompt and prompt.preExecutable) == true -- 625
end -- 623
function ____exports.canRunToolInParallel(tool) -- 628
	local prompt = getToolPrompt(tool) -- 629
	return (prompt and prompt.parallelSafe) == true -- 630
end -- 628
function ____exports.buildDecisionToolSchema(role, searchDoraApiLimitMax, options) -- 633
	local context = {searchDoraApiLimitMax = searchDoraApiLimitMax} -- 634
	return ____exports.buildDecisionToolSchemaForTools( -- 635
		getDecisionToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools}), -- 635
		context -- 638
	) -- 638
end -- 633
return ____exports -- 633