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
function resolveText(value, context) -- 136
	return type(value) == "string" and value or value(context) -- 137
end -- 137
function getToolDescription(tool, context) -- 140
	return resolveText(tool.description, context) -- 141
end -- 141
function getToolRules(tool, context) -- 144
	return __TS__ArrayMap( -- 145
		tool.rules or ({}), -- 145
		function(____, rule) return resolveText(rule, context) end -- 145
	) -- 145
end -- 145
function getParameterDescription(parameter, context) -- 148
	return resolveText(parameter.description, context) -- 149
end -- 149
function createFunctionToolSchemaFromPrompt(tool, context) -- 152
	local properties = {} -- 153
	local required = {} -- 154
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 155
		local property = { -- 156
			type = parameter.type, -- 157
			description = getParameterDescription(parameter, context) -- 158
		} -- 158
		if parameter.enum ~= nil then -- 158
			property.enum = parameter.enum -- 161
		end -- 161
		if parameter.items ~= nil then -- 161
			property.items = parameter.items -- 164
		end -- 164
		properties[parameter.name] = property -- 166
		if parameter.required == true then -- 166
			required[#required + 1] = parameter.name -- 168
		end -- 168
	end -- 168
	local parameters = {type = "object", properties = properties} -- 171
	if #required > 0 then -- 171
		parameters.required = required -- 176
	end -- 176
	local rules = getToolRules(tool, context) -- 178
	return { -- 179
		type = "function", -- 180
		["function"] = { -- 181
			name = tool.name, -- 182
			description = table.concat( -- 183
				{ -- 183
					getToolDescription(tool, context), -- 183
					table.unpack(rules) -- 183
				}, -- 183
				" " -- 183
			), -- 183
			parameters = parameters -- 184
		} -- 184
	} -- 184
end -- 184
function ____exports.isKnownToolName(name) -- 473
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 474
end -- 473
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 618
	return __TS__ArrayMap( -- 619
		tools, -- 619
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 620
	) -- 620
end -- 618
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
function ____exports.findUnsupportedDoraTsEdit(path, newStr) -- 88
	local normalized = string.lower(path) -- 89
	if not (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tsx")) or __TS__StringEndsWith(normalized, ".d.ts") then -- 89
		return nil -- 90
	end -- 90
	local isTestFile = __TS__StringEndsWith(normalized, "test.ts") or __TS__StringEndsWith(normalized, "test.tsx") -- 91
	local checks = { -- 92
		{"Math.random", "inject a deterministic RNG or use supported bounded arithmetic"}, -- 93
		{"Math.hypot", "use Math.sqrt(x * x + y * y)"}, -- 94
		{"Math.imul", "use ordinary bounded multiplication"}, -- 95
		{"KeyName.Enter", "use a declared Dora KeyName such as Space, Up, A, D, Left, or Right"}, -- 96
		{"ReturnType<typeof", "annotate Dora factory instances with X.Type"} -- 97
	} -- 97
	local lines = __TS__StringSplit(newStr, "\n") -- 99
	do -- 99
		local i = 0 -- 100
		while i < #lines do -- 100
			do -- 100
				local trimmed = __TS__StringTrim(lines[i + 1]) -- 101
				if __TS__StringStartsWith(trimmed, "//") or __TS__StringStartsWith(trimmed, "/*") or __TS__StringStartsWith(trimmed, "*") then -- 101
					goto __continue5 -- 102
				end -- 102
				local uncommented = __TS__StringSplit(lines[i + 1], "//")[1] or "" -- 103
				local code = "" -- 104
				local quote = "" -- 105
				local escaped = false -- 106
				do -- 106
					local j = 0 -- 107
					while j < #uncommented do -- 107
						local char = __TS__StringAccess(uncommented, j) -- 108
						if quote ~= "" then -- 108
							if escaped then -- 108
								escaped = false -- 110
							elseif char == "\\" then -- 110
								escaped = true -- 111
							elseif char == quote then -- 111
								quote = "" -- 112
							end -- 112
							code = code .. " " -- 113
						elseif char == "\"" or char == "'" or char == "`" then -- 113
							quote = char -- 115
							code = code .. " " -- 116
						else -- 116
							code = code .. char -- 118
						end -- 118
						j = j + 1 -- 107
					end -- 107
				end -- 107
				for ____, ____value in ipairs(checks) do -- 121
					local token = ____value[1] -- 121
					local replacement = ____value[2] -- 121
					if (string.find(code, token, nil, true) or 0) - 1 >= 0 then -- 121
						return ((token .. " is unsupported in Dora TypeScript; ") .. replacement) .. ". The edit was not applied. Correct this replacement before continuing." -- 123
					end -- 123
				end -- 123
				if isTestFile then -- 123
					local compactCode = table.concat( -- 127
						__TS__StringSplit( -- 127
							table.concat( -- 127
								__TS__StringSplit(code, " "), -- 127
								"" -- 127
							), -- 127
							"\t" -- 127
						), -- 127
						"" -- 127
					) -- 127
					if (string.find(compactCode, "||true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "check(true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "assert(true", nil, true) or 0) - 1 >= 0 then -- 127
						return "Vacuous always-true assertions are not allowed in authored test files. Replace the tautology with a deterministic observable condition that can fail. The edit was not applied." -- 129
					end -- 129
				end -- 129
			end -- 129
			::__continue5:: -- 129
			i = i + 1 -- 100
		end -- 100
	end -- 100
	return nil -- 133
end -- 88
____exports.AGENT_TOOL_PROMPTS = { -- 189
	{ -- 190
		name = "read_file", -- 191
		roles = {"main", "sub"}, -- 192
		description = "Read a specific line range from a file.", -- 193
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to read, or an exact @dora-doc/... path returned by search_dora_api."}, {name = "startLine", type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, -- 194
		rules = {"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", "Paths returned by search_dora_api are authoritative built-in documentation paths and can be read directly without modifying them."}, -- 199
		parallelSafe = true -- 203
	}, -- 203
	{ -- 205
		name = "edit_file", -- 206
		roles = {"main", "sub"}, -- 207
		description = "Make changes to a file.", -- 208
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to edit."}, {name = "old_str", type = "string", required = true, description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, {name = "new_str", type = "string", required = true, description = "Replacement text or the full file content when rewriting or creating."}}, -- 209
		rules = { -- 214
			"old_str and new_str MUST be different.", -- 215
			"old_str must match existing text exactly when it is non-empty.", -- 216
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.", -- 217
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build.", -- 218
			"For Dora .ts/.tsx source, the engine rejects known unsupported constructs before writing: Math.random, Math.hypot, Math.imul, KeyName.Enter, and ReturnType<typeof DoraFactory>. Inject or implement a bounded RNG, use supported arithmetic/key names, and annotate Dora instances with X.Type." -- 219
		} -- 219
	}, -- 219
	{name = "delete_file", roles = {"main", "sub"}, description = "Remove a file.", parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}}}, -- 222
	{ -- 230
		name = "grep_files", -- 231
		roles = {"main", "sub"}, -- 232
		description = "Search text patterns inside files.", -- 233
		parameters = { -- 234
			{name = "path", type = "string", description = "Base directory or file path to search within."}, -- 235
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 236
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 237
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 238
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 239
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 240
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 241
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 242
		}, -- 242
		rules = { -- 244
			"`path` may point to either a directory or a single file.", -- 245
			"This is content search (grep), not filename search.", -- 246
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 247
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 248
			"`caseSensitive` defaults to false.", -- 249
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 250
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 251
		}, -- 251
		preExecutable = true, -- 253
		parallelSafe = true -- 254
	}, -- 254
	{ -- 256
		name = "glob_files", -- 257
		roles = {"main", "sub"}, -- 258
		description = "Enumerate files under a directory.", -- 259
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 260
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 265
		preExecutable = true, -- 269
		parallelSafe = true -- 270
	}, -- 270
	{ -- 272
		name = "search_dora_api", -- 273
		roles = {"main", "sub"}, -- 274
		description = "Search Dora SSR game engine docs and tutorials.", -- 275
		parameters = { -- 276
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 277
			{name = "docSource", type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials. Defaults to api."}, -- 278
			{name = "programmingLanguage", type = "string", enum = { -- 279
				"ts", -- 279
				"tsx", -- 279
				"lua", -- 279
				"yue", -- 279
				"teal", -- 279
				"tl", -- 279
				"wa" -- 279
			}, description = "Preferred language variant to search."}, -- 279
			{ -- 280
				name = "limit", -- 280
				type = "number", -- 280
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 280
			}, -- 280
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 281
		}, -- 281
		rules = { -- 283
			"`docSource` defaults to `api`. Use `tutorial` to search teaching docs.", -- 284
			"Every result file uses the @dora-doc/api/... or @dora-doc/tutorial/... namespace and is readable with read_file.", -- 285
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 286
			"`useRegex` defaults to false whenever supported by a search tool.", -- 287
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 288
		}, -- 288
		preExecutable = true, -- 290
		parallelSafe = true -- 291
	}, -- 291
	{ -- 293
		name = "build", -- 294
		roles = {"main", "sub"}, -- 295
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 296
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 297
		rules = {"Read the result and then decide whether another action is needed."} -- 300
	}, -- 300
	{ -- 304
		name = "fetch_url", -- 305
		roles = {"main", "sub"}, -- 306
		description = "Download a single HTTP or HTTPS resource into the project.", -- 307
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 308
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds."} -- 312
	}, -- 312
	{ -- 318
		name = "execute_command", -- 319
		roles = {"main", "sub"}, -- 320
		description = "Execute a controlled engine command.", -- 321
		parameters = { -- 322
			{ -- 323
				name = "mode", -- 323
				type = "string", -- 323
				required = true, -- 323
				enum = {"lua", "git"}, -- 323
				description = "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." -- 323
			}, -- 323
			{name = "code", type = "string", description = "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result."}, -- 324
			{name = "command", type = "string", description = "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported."}, -- 325
			{name = "cwd", type = "string", description = "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C."}, -- 326
			{name = "timeoutSeconds", type = "number", description = "Optional timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode can stop cooperative engine work but cannot interrupt a pure CPU loop that never yields."} -- 327
		}, -- 327
		rules = { -- 329
			"This tool is available only when the user enables command execution for the current Agent task.", -- 330
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 331
			"Lua mode runs with a temporary environment whose global lookups fall back to Dora APIs; global writes stay in that one command and are not shared with later commands.", -- 332
			"Lua mode exposes projectDir, refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). getEntryStatus() returns a table containing success and running booleans.", -- 333
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 334
			"Call refreshTree(\"relative/file\") after single-file changes, or refreshTree() after directory or bulk changes.", -- 335
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 336
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.", -- 337
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 338
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.", -- 339
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten." -- 340
		} -- 340
	}, -- 340
	{ -- 343
		name = "finish", -- 344
		roles = {"main", "sub"}, -- 345
		description = "End the task and provide a structured completion handoff.", -- 346
		parameters = { -- 347
			{name = "message", type = "string", required = true, description = "Final user-facing answer."}, -- 348
			{name = "outcome", type = "string", enum = {"completed", "partial", "blocked"}, description = "Work outcome. Sub agents must provide this; defaults to completed for compatibility."}, -- 349
			{name = "validation", type = "array", items = {type = "object", properties = {kind = {type = "string", enum = {"build", "runtime", "manual"}}, result = {type = "string", enum = {"passed", "failed", "not_run"}}, evidence = {type = "array", items = {type = "string"}}}, required = {"kind", "result"}}, description = "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."}, -- 350
			{name = "knownIssues", type = "array", items = {type = "string"}, description = "Known remaining issues or blockers. Sub agents must provide an array, which may be empty."}, -- 359
			{name = "assumptions", type = "array", items = {type = "string"}, description = "Material assumptions made during the work. Sub agents must provide an array, which may be empty."}, -- 360
			{name = "learningCandidates", type = "array", items = {type = "object", properties = {claim = {type = "string"}, scope = {type = "string", enum = {"file", "project", "engine"}}, evidence = {type = "array", items = {type = "string"}}, confidence = {type = "string", enum = {"observed", "inferred"}}}, required = {"claim", "scope", "confidence"}}, description = "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."} -- 361
		}, -- 361
		rules = {"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.", "Do not claim validation passed without concrete evidence from the corresponding tool result.", "Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration."} -- 372
	}, -- 372
	{ -- 378
		name = "list_sub_agents", -- 379
		roles = {"main"}, -- 380
		description = "Query sub-agent state under the current main session.", -- 381
		parameters = {{name = "status", type = "string", enum = { -- 382
			"active_or_recent", -- 383
			"running", -- 383
			"done", -- 383
			"failed", -- 383
			"all" -- 383
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 383
		rules = { -- 388
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 389
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 390
			"limit defaults to a small recent window. Use offset to page older items.", -- 391
			"query filters by title, goal, or summary text.", -- 392
			"After any successful spawn_sub_agent in the current task, this tool is unavailable for the rest of that task. Finish the turn instead; completion arrives through an asynchronous handoff." -- 393
		}, -- 393
		parallelSafe = true -- 395
	}, -- 395
	{ -- 397
		name = "spawn_sub_agent", -- 398
		roles = {"main"}, -- 399
		description = "Create and start a sub agent session for delegated implementation work.", -- 400
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 401
		rules = { -- 407
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 408
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 409
			"The spawned sub agent inherits the current session tool capabilities.", -- 410
			"title should be short and specific.", -- 411
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 412
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 413
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish the current turn and return control to the user while the sub agents keep running.", -- 414
			"After a successful spawn in the current task, do not call list_sub_agents, wait, join, or poll. Completion is delivered asynchronously as a later handoff.", -- 415
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.", -- 416
			"filesHint is an optional list of likely files or directories." -- 417
		} -- 417
	} -- 417
} -- 417
local DEFAULT_SCHEMA_CONTEXT = {searchDoraApiLimitMax = 20} -- 422
local function hasRole(tool, role) -- 426
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 427
end -- 426
local function getToolPrompt(name) -- 430
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 431
		if tool.name == name then -- 431
			return tool -- 432
		end -- 432
	end -- 432
	return nil -- 434
end -- 430
local function isToolCapabilityEnabled(tool, options) -- 437
	if not ____exports.isKnownToolName(tool.name) then -- 437
		return false -- 438
	end -- 438
	return __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 439
end -- 437
local function formatParameterList(tool) -- 442
	local parameters = tool.parameters or ({}) -- 443
	if #parameters == 0 then -- 443
		return "" -- 444
	end -- 444
	return table.concat( -- 445
		__TS__ArrayMap( -- 445
			parameters, -- 445
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 446
		), -- 446
		", " -- 447
	) -- 447
end -- 442
local function formatToolPrompt(tool, index, context) -- 450
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 451
	local parameterList = formatParameterList(tool) -- 452
	if parameterList ~= "" then -- 452
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 454
	end -- 454
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 456
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 457
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 458
	end -- 458
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 460
		lines[#lines + 1] = "\t- " .. rule -- 461
	end -- 461
	return table.concat(lines, "\n") -- 463
end -- 450
local function formatXMLRepairToolReference(tool) -- 466
	local parameterList = formatParameterList(tool) -- 467
	local params = parameterList ~= "" and parameterList or "none" -- 468
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 469
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 470
end -- 466
function ____exports.getAllowedToolsForRole(role, options) -- 477
	return __TS__ArrayMap( -- 478
		__TS__ArrayFilter( -- 478
			____exports.AGENT_TOOL_PROMPTS, -- 478
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 479
		), -- 479
		function(____, tool) return tool.name end -- 480
	) -- 480
end -- 477
function ____exports.buildCurrentToolAvailabilityPrompt(_context) -- 483
	return table.concat({"Current tool availability:", "- every tool defined below or exposed in the current tool schema is executable", "- capabilities disabled for this task are omitted from both the definitions and schema"}, "\n") -- 484
end -- 483
function ____exports.getToolPromptsForRole(role, options) -- 491
	return __TS__ArrayFilter( -- 495
		____exports.AGENT_TOOL_PROMPTS, -- 495
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 495
	) -- 495
end -- 491
local SUB_AGENT_REQUIRED_FINISH_PARAMS = { -- 502
	"message", -- 503
	"outcome", -- 504
	"validation", -- 505
	"knownIssues", -- 506
	"assumptions", -- 507
	"learningCandidates" -- 508
} -- 508
local function getDecisionToolPromptsForRole(role, options) -- 511
	local tools = ____exports.getToolPromptsForRole(role, options) -- 515
	if role ~= "sub" then -- 515
		return tools -- 516
	end -- 516
	return __TS__ArrayMap( -- 517
		tools, -- 517
		function(____, tool) return tool.name ~= "finish" and tool or __TS__ObjectAssign( -- 517
			{}, -- 517
			tool, -- 518
			{parameters = __TS__ArrayMap( -- 517
				tool.parameters or ({}), -- 519
				function(____, parameter) return __TS__ObjectAssign( -- 519
					{}, -- 519
					parameter, -- 520
					{required = __TS__ArrayIndexOf(SUB_AGENT_REQUIRED_FINISH_PARAMS, parameter.name) >= 0} -- 519
				) end -- 519
			)} -- 519
		) end -- 519
	) -- 519
end -- 511
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 526
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 531
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 532
	local sections = __TS__ArrayMap( -- 533
		tools, -- 533
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 533
	) -- 533
	if (options and options.includeXmlRules) == true then -- 533
		local reasonTools = table.concat( -- 535
			__TS__ArrayMap( -- 535
				__TS__ArrayFilter( -- 535
					tools, -- 535
					function(____, tool) return tool.name ~= "finish" end -- 536
				), -- 536
				function(____, tool) return tool.name end -- 537
			), -- 537
			", " -- 538
		) -- 538
		sections[#sections + 1] = ("XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For " .. (reasonTools ~= "" and reasonTools or "tools other than finish")) .. ", include <tool>, <reason>, and <params>.\n- For finish, omit <reason> and include <message> plus every other required parameter shown above inside <params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 539
	end -- 539
	local body = table.concat(sections, "\n\n") -- 545
	return title ~= "" and (title .. "\n") .. body or body -- 546
end -- 526
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 549
	return ____exports.buildToolDefinitionsDetailed( -- 556
		getDecisionToolPromptsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools}), -- 557
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 561
	) -- 561
end -- 549
function ____exports.buildXMLRepairToolReference(role, options) -- 569
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools}) -- 570
	local ____array_22 = __TS__SparseArrayNew( -- 570
		"Allowed tools and XML params:", -- 572
		table.unpack(__TS__ArrayMap( -- 573
			tools, -- 573
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 573
		)) -- 573
	) -- 573
	__TS__SparseArrayPush( -- 573
		____array_22, -- 573
		"", -- 574
		"XML shape:", -- 575
		"- Wrap the decision in exactly one <tool_call> root.", -- 576
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 577
		"- For finish: include <tool>, omit <reason>, and include <message> plus every other required parameter shown above inside <params>.", -- 578
		"- Inside <params>, use one child tag per parameter name above." -- 579
	) -- 579
	local lines = {__TS__SparseArraySpread(____array_22)} -- 571
	return table.concat(lines, "\n") -- 581
end -- 569
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 584
	____exports.getToolPromptsForRole("sub"), -- 585
	{title = "Available tools:"} -- 586
) -- 586
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 589
	__TS__ArrayFilter( -- 590
		____exports.getToolPromptsForRole("main"), -- 590
		function(____, tool) return __TS__ArrayIndexOf( -- 591
			__TS__ArrayMap( -- 591
				____exports.getToolPromptsForRole("sub"), -- 591
				function(____, subTool) return subTool.name end -- 591
			), -- 591
			tool.name -- 591
		) < 0 end -- 591
	), -- 591
	{title = ""} -- 592
) -- 592
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 595
	__TS__ArrayFilter( -- 596
		____exports.AGENT_TOOL_PROMPTS, -- 596
		function(____, tool) return tool.name == "finish" end -- 596
	), -- 596
	{title = "", includeXmlRules = true} -- 597
) -- 597
function ____exports.canPreExecuteTool(tool) -- 600
	local prompt = getToolPrompt(tool) -- 601
	return (prompt and prompt.preExecutable) == true -- 602
end -- 600
function ____exports.canRunToolInParallel(tool) -- 605
	local prompt = getToolPrompt(tool) -- 606
	return (prompt and prompt.parallelSafe) == true -- 607
end -- 605
function ____exports.buildDecisionToolSchema(role, searchDoraApiLimitMax, options) -- 610
	local context = {searchDoraApiLimitMax = searchDoraApiLimitMax} -- 611
	return ____exports.buildDecisionToolSchemaForTools( -- 612
		getDecisionToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools}), -- 612
		context -- 615
	) -- 615
end -- 610
return ____exports -- 610