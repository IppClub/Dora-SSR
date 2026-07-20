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
function resolveText(value, context) -- 142
	return type(value) == "string" and value or value(context) -- 143
end -- 143
function getToolDescription(tool, context) -- 146
	return resolveText(tool.description, context) -- 147
end -- 147
function getToolRules(tool, context) -- 150
	return __TS__ArrayMap( -- 151
		tool.rules or ({}), -- 151
		function(____, rule) return resolveText(rule, context) end -- 151
	) -- 151
end -- 151
function getParameterDescription(parameter, context) -- 154
	return resolveText(parameter.description, context) -- 155
end -- 155
function createFunctionToolSchemaFromPrompt(tool, context) -- 158
	local properties = {} -- 159
	local required = {} -- 160
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 161
		local property = { -- 162
			type = parameter.type, -- 163
			description = getParameterDescription(parameter, context) -- 164
		} -- 164
		if parameter.enum ~= nil then -- 164
			property.enum = parameter.enum -- 167
		end -- 167
		if parameter.items ~= nil then -- 167
			property.items = parameter.items -- 170
		end -- 170
		properties[parameter.name] = property -- 172
		if parameter.required == true then -- 172
			required[#required + 1] = parameter.name -- 174
		end -- 174
	end -- 174
	local parameters = {type = "object", properties = properties} -- 177
	if #required > 0 then -- 177
		parameters.required = required -- 182
	end -- 182
	local rules = getToolRules(tool, context) -- 184
	return { -- 185
		type = "function", -- 186
		["function"] = { -- 187
			name = tool.name, -- 188
			description = table.concat( -- 189
				{ -- 189
					getToolDescription(tool, context), -- 189
					table.unpack(rules) -- 189
				}, -- 189
				" " -- 189
			), -- 189
			parameters = parameters -- 190
		} -- 190
	} -- 190
end -- 190
function ____exports.isKnownToolName(name) -- 547
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 548
end -- 547
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 701
	return __TS__ArrayMap( -- 702
		tools, -- 702
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 703
	) -- 703
end -- 701
BUILT_IN_AGENT_TOOL_NAMES = { -- 22
	"read_file", -- 23
	"edit_file", -- 24
	"delete_file", -- 25
	"grep_files", -- 26
	"search_dora_api", -- 27
	"glob_files", -- 28
	"build", -- 29
	"fetch_url", -- 30
	"execute_command", -- 31
	"list_sub_agents", -- 32
	"spawn_sub_agent", -- 33
	"ask_user", -- 34
	"finish" -- 35
} -- 35
function ____exports.findUnsupportedDoraTsEdit(path, newStr) -- 94
	local normalized = string.lower(path) -- 95
	if not (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tsx")) or __TS__StringEndsWith(normalized, ".d.ts") then -- 95
		return nil -- 96
	end -- 96
	local isTestFile = __TS__StringEndsWith(normalized, "test.ts") or __TS__StringEndsWith(normalized, "test.tsx") -- 97
	local checks = { -- 98
		{"Math.random", "inject a deterministic RNG or use supported bounded arithmetic"}, -- 99
		{"Math.hypot", "use Math.sqrt(x * x + y * y)"}, -- 100
		{"Math.imul", "use ordinary bounded multiplication"}, -- 101
		{"KeyName.Enter", "use a declared Dora KeyName such as Space, Up, A, D, Left, or Right"}, -- 102
		{"ReturnType<typeof", "annotate Dora factory instances with X.Type"} -- 103
	} -- 103
	local lines = __TS__StringSplit(newStr, "\n") -- 105
	do -- 105
		local i = 0 -- 106
		while i < #lines do -- 106
			do -- 106
				local trimmed = __TS__StringTrim(lines[i + 1]) -- 107
				if __TS__StringStartsWith(trimmed, "//") or __TS__StringStartsWith(trimmed, "/*") or __TS__StringStartsWith(trimmed, "*") then -- 107
					goto __continue5 -- 108
				end -- 108
				local uncommented = __TS__StringSplit(lines[i + 1], "//")[1] or "" -- 109
				local code = "" -- 110
				local quote = "" -- 111
				local escaped = false -- 112
				do -- 112
					local j = 0 -- 113
					while j < #uncommented do -- 113
						local char = __TS__StringAccess(uncommented, j) -- 114
						if quote ~= "" then -- 114
							if escaped then -- 114
								escaped = false -- 116
							elseif char == "\\" then -- 116
								escaped = true -- 117
							elseif char == quote then -- 117
								quote = "" -- 118
							end -- 118
							code = code .. " " -- 119
						elseif char == "\"" or char == "'" or char == "`" then -- 119
							quote = char -- 121
							code = code .. " " -- 122
						else -- 122
							code = code .. char -- 124
						end -- 124
						j = j + 1 -- 113
					end -- 113
				end -- 113
				for ____, ____value in ipairs(checks) do -- 127
					local token = ____value[1] -- 127
					local replacement = ____value[2] -- 127
					if (string.find(code, token, nil, true) or 0) - 1 >= 0 then -- 127
						return ((token .. " is unsupported in Dora TypeScript; ") .. replacement) .. ". The edit was not applied. Correct this replacement before continuing." -- 129
					end -- 129
				end -- 129
				if isTestFile then -- 129
					local compactCode = table.concat( -- 133
						__TS__StringSplit( -- 133
							table.concat( -- 133
								__TS__StringSplit(code, " "), -- 133
								"" -- 133
							), -- 133
							"\t" -- 133
						), -- 133
						"" -- 133
					) -- 133
					if (string.find(compactCode, "||true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "check(true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "assert(true", nil, true) or 0) - 1 >= 0 then -- 133
						return "Vacuous always-true assertions are not allowed in authored test files. Replace the tautology with a deterministic observable condition that can fail. The edit was not applied." -- 135
					end -- 135
				end -- 135
			end -- 135
			::__continue5:: -- 135
			i = i + 1 -- 106
		end -- 106
	end -- 106
	return nil -- 139
end -- 94
____exports.AGENT_TOOL_PROMPTS = { -- 195
	{ -- 196
		name = "read_file", -- 197
		roles = {"main", "sub"}, -- 198
		workModes = {"code", "plan"}, -- 199
		description = "Read a specific line range from a file.", -- 200
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to read, or an exact @dora-doc/... path returned by search_dora_api."}, {name = "startLine", type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, -- 201
		rules = {"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", "Paths returned by search_dora_api are authoritative built-in documentation paths and can be read directly without modifying them."}, -- 206
		parallelSafe = true -- 210
	}, -- 210
	{ -- 212
		name = "edit_file", -- 213
		roles = {"main", "sub"}, -- 214
		workModes = {"code", "plan"}, -- 215
		description = "Make changes to a file.", -- 216
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to edit."}, {name = "old_str", type = "string", required = true, description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, {name = "new_str", type = "string", required = true, description = "Replacement text or the full file content when rewriting or creating."}}, -- 217
		rules = { -- 222
			"old_str and new_str MUST be different.", -- 223
			"old_str must match existing text exactly when it is non-empty.", -- 224
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.", -- 225
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build.", -- 226
			"For Dora .ts/.tsx source, the engine rejects known unsupported constructs before writing: Math.random, Math.hypot, Math.imul, KeyName.Enter, and ReturnType<typeof DoraFactory>. Inject or implement a bounded RNG, use supported arithmetic/key names, and annotate Dora instances with X.Type." -- 227
		} -- 227
	}, -- 227
	{ -- 230
		name = "delete_file", -- 231
		roles = {"main", "sub"}, -- 232
		workModes = {"code", "plan"}, -- 233
		description = "Remove a file.", -- 234
		parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}} -- 235
	}, -- 235
	{ -- 239
		name = "grep_files", -- 240
		roles = {"main", "sub"}, -- 241
		workModes = {"code", "plan"}, -- 242
		description = "Search text patterns inside files.", -- 243
		parameters = { -- 244
			{name = "path", type = "string", description = "Base directory or file path to search within."}, -- 245
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 246
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 247
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 248
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 249
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 250
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 251
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 252
		}, -- 252
		rules = { -- 254
			"`path` may point to either a directory or a single file.", -- 255
			"This is content search (grep), not filename search.", -- 256
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 257
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 258
			"`caseSensitive` defaults to false.", -- 259
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 260
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 261
		}, -- 261
		preExecutable = true, -- 263
		parallelSafe = true -- 264
	}, -- 264
	{ -- 266
		name = "glob_files", -- 267
		roles = {"main", "sub"}, -- 268
		workModes = {"code", "plan"}, -- 269
		description = "Enumerate files under a directory.", -- 270
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 271
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 276
		preExecutable = true, -- 280
		parallelSafe = true -- 281
	}, -- 281
	{ -- 283
		name = "search_dora_api", -- 284
		roles = {"main", "sub"}, -- 285
		workModes = {"code", "plan"}, -- 286
		description = "Search Dora SSR game engine docs and tutorials.", -- 287
		parameters = { -- 288
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 289
			{name = "docSource", type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials. Defaults to api."}, -- 290
			{name = "programmingLanguage", type = "string", enum = { -- 291
				"ts", -- 291
				"tsx", -- 291
				"lua", -- 291
				"yue", -- 291
				"teal", -- 291
				"tl", -- 291
				"wa" -- 291
			}, description = "Preferred language variant to search."}, -- 291
			{ -- 292
				name = "limit", -- 292
				type = "number", -- 292
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 292
			}, -- 292
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 293
		}, -- 293
		rules = { -- 295
			"`docSource` defaults to `api`. Use `tutorial` to search teaching docs.", -- 296
			"Every result file uses the @dora-doc/api/... or @dora-doc/tutorial/... namespace and is readable with read_file.", -- 297
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 298
			"`useRegex` defaults to false whenever supported by a search tool.", -- 299
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 300
		}, -- 300
		preExecutable = true, -- 302
		parallelSafe = true -- 303
	}, -- 303
	{ -- 305
		name = "build", -- 306
		roles = {"main", "sub"}, -- 307
		workModes = {"code"}, -- 308
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 309
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 310
		rules = {"Read the result and then decide whether another action is needed."} -- 313
	}, -- 313
	{ -- 317
		name = "fetch_url", -- 318
		roles = {"main", "sub"}, -- 319
		workModes = {"code"}, -- 320
		description = "Download a single HTTP or HTTPS resource into the project.", -- 321
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 322
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds."} -- 326
	}, -- 326
	{ -- 332
		name = "execute_command", -- 333
		roles = {"main", "sub"}, -- 334
		workModes = {"code"}, -- 335
		description = "Execute a controlled engine command.", -- 336
		parameters = { -- 337
			{ -- 338
				name = "mode", -- 338
				type = "string", -- 338
				required = true, -- 338
				enum = {"lua", "git"}, -- 338
				description = "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." -- 338
			}, -- 338
			{name = "code", type = "string", description = "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result."}, -- 339
			{name = "command", type = "string", description = "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported."}, -- 340
			{name = "cwd", type = "string", description = "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C."}, -- 341
			{name = "timeoutSeconds", type = "number", description = "Optional timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode can stop cooperative engine work but cannot interrupt a pure CPU loop that never yields."} -- 342
		}, -- 342
		rules = { -- 344
			"This tool is available only when the user enables command execution for the current Agent task.", -- 345
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 346
			"Lua mode runs with a temporary environment whose global lookups fall back to Dora APIs; global writes stay in that one command and are not shared with later commands.", -- 347
			"Lua mode exposes projectDir, refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). getEntryStatus() returns a table containing success and running booleans.", -- 348
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 349
			"Call refreshTree(\"relative/file\") after single-file changes, or refreshTree() after directory or bulk changes.", -- 350
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 351
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.", -- 352
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 353
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.", -- 354
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten." -- 355
		} -- 355
	}, -- 355
	{ -- 358
		name = "finish", -- 359
		roles = {"main", "sub"}, -- 360
		workModes = {"code", "plan"}, -- 361
		description = "End the task and provide a structured completion handoff.", -- 362
		parameters = { -- 363
			{name = "message", type = "string", required = true, description = "Final user-facing answer."}, -- 364
			{name = "outcome", type = "string", enum = {"completed", "partial", "blocked"}, description = "Work outcome. Sub agents must provide this; defaults to completed for compatibility."}, -- 365
			{name = "validation", type = "array", items = {type = "object", properties = {kind = {type = "string", enum = {"build", "runtime", "manual"}}, result = {type = "string", enum = {"passed", "failed", "not_run"}}, evidence = {type = "array", items = {type = "string"}}}, required = {"kind", "result"}}, description = "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."}, -- 366
			{name = "knownIssues", type = "array", items = {type = "string"}, description = "Known remaining issues or blockers. Sub agents must provide an array, which may be empty."}, -- 375
			{name = "assumptions", type = "array", items = {type = "string"}, description = "Material assumptions made during the work. Sub agents must provide an array, which may be empty."}, -- 376
			{name = "learningCandidates", type = "array", items = {type = "object", properties = {claim = {type = "string"}, scope = {type = "string", enum = {"file", "project", "engine"}}, evidence = {type = "array", items = {type = "string"}}, confidence = {type = "string", enum = {"observed", "inferred"}}}, required = {"claim", "scope", "confidence"}}, description = "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."} -- 377
		}, -- 377
		rules = {"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.", "Do not claim validation passed without concrete evidence from the corresponding tool result.", "Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration."} -- 388
	}, -- 388
	{ -- 394
		name = "list_sub_agents", -- 395
		roles = {"main"}, -- 396
		workModes = {"code"}, -- 397
		description = "Query sub-agent state under the current main session.", -- 398
		parameters = {{name = "status", type = "string", enum = { -- 399
			"active_or_recent", -- 400
			"running", -- 400
			"done", -- 400
			"failed", -- 400
			"all" -- 400
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 400
		rules = { -- 405
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 406
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 407
			"limit defaults to a small recent window. Use offset to page older items.", -- 408
			"query filters by title, goal, or summary text.", -- 409
			"After any successful spawn_sub_agent in the current task, this tool is unavailable for the rest of that task. Finish the turn instead; completion arrives through an asynchronous handoff." -- 410
		}, -- 410
		parallelSafe = true -- 412
	}, -- 412
	{ -- 414
		name = "spawn_sub_agent", -- 415
		roles = {"main"}, -- 416
		workModes = {"code"}, -- 417
		description = "Create and start a sub agent session for delegated implementation work.", -- 418
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 419
		rules = { -- 425
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 426
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 427
			"The spawned sub agent inherits the current session tool capabilities.", -- 428
			"title should be short and specific.", -- 429
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 430
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 431
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish the current turn and return control to the user while the sub agents keep running.", -- 432
			"After a successful spawn in the current task, do not call list_sub_agents, wait, join, or poll. Completion is delivered asynchronously as a later handoff.", -- 433
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.", -- 434
			"filesHint is an optional list of likely files or directories." -- 435
		} -- 435
	}, -- 435
	{ -- 438
		name = "ask_user", -- 439
		roles = {"main"}, -- 440
		workModes = {"plan"}, -- 441
		description = "Present a structured questionnaire and pause the Plan task until the user submits every required answer.", -- 442
		parameters = {{name = "title", type = "string", required = true, description = "Short questionnaire title."}, {name = "description", type = "string", description = "Optional context shown above the questions."}, { -- 443
			name = "questions", -- 447
			type = "array", -- 448
			required = true, -- 449
			description = "One to eight questions. Use single_choice, multiple_choice, or text. A single-choice question may recommend at most one option. A multiple-choice question may recommend a set no larger than maxSelections.", -- 450
			items = {type = "object", properties = { -- 451
				id = {type = "string"}, -- 454
				prompt = {type = "string"}, -- 455
				description = {type = "string"}, -- 456
				type = {type = "string", enum = {"single_choice", "multiple_choice", "text"}}, -- 457
				required = {type = "boolean"}, -- 458
				options = {type = "array", items = {type = "object", properties = {id = {type = "string"}, label = {type = "string"}, description = {type = "string"}, recommended = {type = "boolean", description = "Mark an option as recommended. Use at most one for single_choice; multiple_choice may mark a recommended set no larger than maxSelections."}}, required = {"id", "label"}}}, -- 459
				allowOther = {type = "boolean"}, -- 472
				placeholder = {type = "string"}, -- 473
				minSelections = {type = "number"}, -- 474
				maxSelections = {type = "number"} -- 475
			}, required = {"id", "prompt", "type"}} -- 475
		}}, -- 475
		rules = { -- 481
			"Inspect the project before asking; do not ask for facts available through read_file, grep_files, glob_files, or search_dora_api.", -- 482
			"ask_user has no document-update prerequisite. Incorporate the answers into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish.", -- 483
			"For single_choice, mark at most one option recommended. For multiple_choice, recommended options form a suggested set and must not exceed maxSelections.", -- 484
			"ask_user must be the only tool call in the response.", -- 485
			"The task pauses after the questionnaire is published and continues only after the user submits valid feedback." -- 486
		} -- 486
	} -- 486
} -- 486
local DEFAULT_SCHEMA_CONTEXT = {searchDoraApiLimitMax = 20} -- 491
local function hasRole(tool, role) -- 495
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 496
end -- 495
local function hasWorkMode(tool, workMode) -- 499
	return __TS__ArrayIndexOf(tool.workModes, workMode) >= 0 -- 500
end -- 499
local function getToolPrompt(name) -- 503
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 504
		if tool.name == name then -- 504
			return tool -- 505
		end -- 505
	end -- 505
	return nil -- 507
end -- 503
local function isToolCapabilityEnabled(tool, options) -- 510
	if not ____exports.isKnownToolName(tool.name) then -- 510
		return false -- 511
	end -- 511
	return hasWorkMode(tool, options and options.workMode or "code") and __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 512
end -- 510
local function formatParameterList(tool) -- 516
	local parameters = tool.parameters or ({}) -- 517
	if #parameters == 0 then -- 517
		return "" -- 518
	end -- 518
	return table.concat( -- 519
		__TS__ArrayMap( -- 519
			parameters, -- 519
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 520
		), -- 520
		", " -- 521
	) -- 521
end -- 516
local function formatToolPrompt(tool, index, context) -- 524
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 525
	local parameterList = formatParameterList(tool) -- 526
	if parameterList ~= "" then -- 526
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 528
	end -- 528
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 530
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 531
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 532
	end -- 532
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 534
		lines[#lines + 1] = "\t- " .. rule -- 535
	end -- 535
	return table.concat(lines, "\n") -- 537
end -- 524
local function formatXMLRepairToolReference(tool) -- 540
	local parameterList = formatParameterList(tool) -- 541
	local params = parameterList ~= "" and parameterList or "none" -- 542
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 543
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 544
end -- 540
function ____exports.getAllowedToolsForRole(role, options) -- 551
	return __TS__ArrayMap( -- 552
		__TS__ArrayFilter( -- 552
			____exports.AGENT_TOOL_PROMPTS, -- 552
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 553
		), -- 553
		function(____, tool) return tool.name end -- 554
	) -- 554
end -- 551
function ____exports.buildCurrentToolAvailabilityPrompt(_context) -- 557
	return table.concat({"Current tool availability:", "- every tool defined below or exposed in the current tool schema is executable", "- capabilities disabled for this task are omitted from both the definitions and schema"}, "\n") -- 558
end -- 557
function ____exports.getToolPromptsForRole(role, options) -- 565
	return __TS__ArrayFilter( -- 570
		____exports.AGENT_TOOL_PROMPTS, -- 570
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 570
	) -- 570
end -- 565
local SUB_AGENT_REQUIRED_FINISH_PARAMS = { -- 577
	"message", -- 578
	"outcome", -- 579
	"validation", -- 580
	"knownIssues", -- 581
	"assumptions", -- 582
	"learningCandidates" -- 583
} -- 583
local function getDecisionToolPromptsForRole(role, options) -- 586
	local tools = ____exports.getToolPromptsForRole(role, options) -- 591
	if role ~= "sub" then -- 591
		return tools -- 592
	end -- 592
	return __TS__ArrayMap( -- 593
		tools, -- 593
		function(____, tool) return tool.name ~= "finish" and tool or __TS__ObjectAssign( -- 593
			{}, -- 593
			tool, -- 594
			{parameters = __TS__ArrayMap( -- 593
				tool.parameters or ({}), -- 595
				function(____, parameter) return __TS__ObjectAssign( -- 595
					{}, -- 595
					parameter, -- 596
					{required = __TS__ArrayIndexOf(SUB_AGENT_REQUIRED_FINISH_PARAMS, parameter.name) >= 0} -- 595
				) end -- 595
			)} -- 595
		) end -- 595
	) -- 595
end -- 586
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 602
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 607
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 608
	local sections = __TS__ArrayMap( -- 609
		tools, -- 609
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 609
	) -- 609
	if (options and options.includeXmlRules) == true then -- 609
		local reasonTools = table.concat( -- 611
			__TS__ArrayMap( -- 611
				__TS__ArrayFilter( -- 611
					tools, -- 611
					function(____, tool) return tool.name ~= "finish" end -- 612
				), -- 612
				function(____, tool) return tool.name end -- 613
			), -- 613
			", " -- 614
		) -- 614
		sections[#sections + 1] = ("XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For " .. (reasonTools ~= "" and reasonTools or "tools other than finish")) .. ", include <tool>, <reason>, and <params>.\n- For finish, omit <reason> and include <message> plus every other required parameter shown above inside <params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 615
	end -- 615
	local body = table.concat(sections, "\n\n") -- 621
	return title ~= "" and (title .. "\n") .. body or body -- 622
end -- 602
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 625
	return ____exports.buildToolDefinitionsDetailed( -- 633
		getDecisionToolPromptsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 634
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 639
	) -- 639
end -- 625
function ____exports.buildXMLRepairToolReference(role, options) -- 647
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}) -- 648
	local ____array_28 = __TS__SparseArrayNew( -- 648
		"Allowed tools and XML params:", -- 654
		table.unpack(__TS__ArrayMap( -- 655
			tools, -- 655
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 655
		)) -- 655
	) -- 655
	__TS__SparseArrayPush( -- 655
		____array_28, -- 655
		"", -- 656
		"XML shape:", -- 657
		"- Wrap the decision in exactly one <tool_call> root.", -- 658
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 659
		"- For finish: include <tool>, omit <reason>, and include <message> plus every other required parameter shown above inside <params>.", -- 660
		"- Inside <params>, use one child tag per parameter name above." -- 661
	) -- 661
	local lines = {__TS__SparseArraySpread(____array_28)} -- 653
	return table.concat(lines, "\n") -- 663
end -- 647
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 666
	____exports.getToolPromptsForRole("sub"), -- 667
	{title = "Available tools:"} -- 668
) -- 668
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 671
	__TS__ArrayFilter( -- 672
		____exports.getToolPromptsForRole("main"), -- 672
		function(____, tool) return __TS__ArrayIndexOf( -- 673
			__TS__ArrayMap( -- 673
				____exports.getToolPromptsForRole("sub"), -- 673
				function(____, subTool) return subTool.name end -- 673
			), -- 673
			tool.name -- 673
		) < 0 end -- 673
	), -- 673
	{title = ""} -- 674
) -- 674
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 677
	__TS__ArrayFilter( -- 678
		____exports.AGENT_TOOL_PROMPTS, -- 678
		function(____, tool) return tool.name == "finish" end -- 678
	), -- 678
	{title = "", includeXmlRules = true} -- 679
) -- 679
function ____exports.canPreExecuteTool(tool) -- 682
	local prompt = getToolPrompt(tool) -- 683
	return (prompt and prompt.preExecutable) == true -- 684
end -- 682
function ____exports.canRunToolInParallel(tool) -- 687
	local prompt = getToolPrompt(tool) -- 688
	return (prompt and prompt.parallelSafe) == true -- 689
end -- 687
function ____exports.buildDecisionToolSchema(role, searchDoraApiLimitMax, options) -- 692
	local context = {searchDoraApiLimitMax = searchDoraApiLimitMax} -- 693
	return ____exports.buildDecisionToolSchemaForTools( -- 694
		getDecisionToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 694
		context -- 698
	) -- 698
end -- 692
return ____exports -- 692