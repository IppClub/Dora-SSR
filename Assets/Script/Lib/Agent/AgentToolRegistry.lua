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
function resolveText(value, context) -- 125
	return type(value) == "string" and value or value(context) -- 126
end -- 126
function getToolDescription(tool, context) -- 129
	return resolveText(tool.description, context) -- 130
end -- 130
function getToolRules(tool, context) -- 133
	return __TS__ArrayMap( -- 134
		tool.rules or ({}), -- 134
		function(____, rule) return resolveText(rule, context) end -- 134
	) -- 134
end -- 134
function getParameterDescription(parameter, context) -- 137
	return resolveText(parameter.description, context) -- 138
end -- 138
function createFunctionToolSchemaFromPrompt(tool, context) -- 141
	local properties = {} -- 142
	local required = {} -- 143
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 144
		local property = { -- 145
			type = parameter.type, -- 146
			description = getParameterDescription(parameter, context) -- 147
		} -- 147
		if parameter.enum ~= nil then -- 147
			property.enum = parameter.enum -- 150
		end -- 150
		if parameter.items ~= nil then -- 150
			property.items = parameter.items -- 153
		end -- 153
		properties[parameter.name] = property -- 155
		if parameter.required == true then -- 155
			required[#required + 1] = parameter.name -- 157
		end -- 157
	end -- 157
	local parameters = {type = "object", properties = properties} -- 160
	if #required > 0 then -- 160
		parameters.required = required -- 165
	end -- 165
	local rules = getToolRules(tool, context) -- 167
	return { -- 168
		type = "function", -- 169
		["function"] = { -- 170
			name = tool.name, -- 171
			description = table.concat( -- 172
				{ -- 172
					getToolDescription(tool, context), -- 172
					table.unpack(rules) -- 172
				}, -- 172
				" " -- 172
			), -- 172
			parameters = parameters -- 173
		} -- 173
	} -- 173
end -- 173
function ____exports.isKnownToolName(name) -- 533
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 534
end -- 533
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 687
	return __TS__ArrayMap( -- 688
		tools, -- 688
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 689
	) -- 689
end -- 687
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
function ____exports.findUnsupportedDoraTsEdit(path, newStr) -- 77
	local normalized = string.lower(path) -- 78
	if not (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tsx")) or __TS__StringEndsWith(normalized, ".d.ts") then -- 78
		return nil -- 79
	end -- 79
	local isTestFile = __TS__StringEndsWith(normalized, "test.ts") or __TS__StringEndsWith(normalized, "test.tsx") -- 80
	local checks = { -- 81
		{"Math.random", "inject a deterministic RNG or use supported bounded arithmetic"}, -- 82
		{"Math.hypot", "use Math.sqrt(x * x + y * y)"}, -- 83
		{"Math.imul", "use ordinary bounded multiplication"}, -- 84
		{"KeyName.Enter", "use a declared Dora KeyName such as Space, Up, A, D, Left, or Right"}, -- 85
		{"ReturnType<typeof", "annotate Dora factory instances with X.Type"} -- 86
	} -- 86
	local lines = __TS__StringSplit(newStr, "\n") -- 88
	do -- 88
		local i = 0 -- 89
		while i < #lines do -- 89
			do -- 89
				local trimmed = __TS__StringTrim(lines[i + 1]) -- 90
				if __TS__StringStartsWith(trimmed, "//") or __TS__StringStartsWith(trimmed, "/*") or __TS__StringStartsWith(trimmed, "*") then -- 90
					goto __continue5 -- 91
				end -- 91
				local uncommented = __TS__StringSplit(lines[i + 1], "//")[1] or "" -- 92
				local code = "" -- 93
				local quote = "" -- 94
				local escaped = false -- 95
				do -- 95
					local j = 0 -- 96
					while j < #uncommented do -- 96
						local char = __TS__StringAccess(uncommented, j) -- 97
						if quote ~= "" then -- 97
							if escaped then -- 97
								escaped = false -- 99
							elseif char == "\\" then -- 99
								escaped = true -- 100
							elseif char == quote then -- 100
								quote = "" -- 101
							end -- 101
							code = code .. " " -- 102
						elseif char == "\"" or char == "'" or char == "`" then -- 102
							quote = char -- 104
							code = code .. " " -- 105
						else -- 105
							code = code .. char -- 107
						end -- 107
						j = j + 1 -- 96
					end -- 96
				end -- 96
				for ____, ____value in ipairs(checks) do -- 110
					local token = ____value[1] -- 110
					local replacement = ____value[2] -- 110
					if (string.find(code, token, nil, true) or 0) - 1 >= 0 then -- 110
						return ((token .. " is unsupported in Dora TypeScript; ") .. replacement) .. ". The edit was not applied. Correct this replacement before continuing." -- 112
					end -- 112
				end -- 112
				if isTestFile then -- 112
					local compactCode = table.concat( -- 116
						__TS__StringSplit( -- 116
							table.concat( -- 116
								__TS__StringSplit(code, " "), -- 116
								"" -- 116
							), -- 116
							"\t" -- 116
						), -- 116
						"" -- 116
					) -- 116
					if (string.find(compactCode, "||true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "check(true", nil, true) or 0) - 1 >= 0 or (string.find(compactCode, "assert(true", nil, true) or 0) - 1 >= 0 then -- 116
						return "Vacuous always-true assertions are not allowed in authored test files. Replace the tautology with a deterministic observable condition that can fail. The edit was not applied." -- 118
					end -- 118
				end -- 118
			end -- 118
			::__continue5:: -- 118
			i = i + 1 -- 89
		end -- 89
	end -- 89
	return nil -- 122
end -- 77
____exports.AGENT_TOOL_PROMPTS = { -- 178
	{ -- 179
		name = "read_file", -- 180
		roles = {"main", "sub"}, -- 181
		workModes = {"code", "plan"}, -- 182
		description = "Read a specific line range from a file.", -- 183
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to read, or an exact @dora-doc/... path returned by search_dora_api."}, {name = "startLine", type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, -- 184
		rules = {"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", "Paths returned by search_dora_api are authoritative built-in documentation paths and can be read directly without modifying them."}, -- 189
		parallelSafe = true -- 193
	}, -- 193
	{ -- 195
		name = "edit_file", -- 196
		roles = {"main", "sub"}, -- 197
		workModes = {"code", "plan"}, -- 198
		description = "Make changes to a file.", -- 199
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to edit."}, {name = "old_str", type = "string", required = true, description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, {name = "new_str", type = "string", required = true, description = "Replacement text or the full file content when rewriting or creating."}}, -- 200
		rules = { -- 205
			"old_str and new_str MUST be different.", -- 206
			"old_str must match existing text exactly when it is non-empty.", -- 207
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.", -- 208
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build.", -- 209
			"For Dora .ts/.tsx source, the engine rejects known unsupported constructs before writing: Math.random, Math.hypot, Math.imul, KeyName.Enter, and ReturnType<typeof DoraFactory>. Inject or implement a bounded RNG, use supported arithmetic/key names, and annotate Dora instances with X.Type." -- 210
		} -- 210
	}, -- 210
	{ -- 213
		name = "delete_file", -- 214
		roles = {"main", "sub"}, -- 215
		workModes = {"code", "plan"}, -- 216
		description = "Remove a file.", -- 217
		parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}} -- 218
	}, -- 218
	{ -- 222
		name = "grep_files", -- 223
		roles = {"main", "sub"}, -- 224
		workModes = {"code", "plan"}, -- 225
		description = "Search text patterns inside files.", -- 226
		parameters = { -- 227
			{name = "path", type = "string", description = "Base directory or file path to search within."}, -- 228
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 229
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 230
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 231
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 232
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 233
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 234
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 235
		}, -- 235
		rules = { -- 237
			"`path` may point to either a directory or a single file.", -- 238
			"This is content search (grep), not filename search.", -- 239
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 240
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 241
			"`caseSensitive` defaults to false.", -- 242
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 243
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 244
		}, -- 244
		preExecutable = true, -- 246
		parallelSafe = true -- 247
	}, -- 247
	{ -- 249
		name = "glob_files", -- 250
		roles = {"main", "sub"}, -- 251
		workModes = {"code", "plan"}, -- 252
		description = "Enumerate files under a directory.", -- 253
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 254
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 259
		preExecutable = true, -- 263
		parallelSafe = true -- 264
	}, -- 264
	{ -- 266
		name = "search_dora_api", -- 267
		roles = {"main", "sub"}, -- 268
		workModes = {"code", "plan"}, -- 269
		description = "Search Dora SSR game engine docs and tutorials.", -- 270
		parameters = { -- 271
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 272
			{name = "docSource", type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials. Defaults to api."}, -- 273
			{name = "programmingLanguage", type = "string", enum = { -- 274
				"ts", -- 274
				"tsx", -- 274
				"lua", -- 274
				"yue", -- 274
				"teal", -- 274
				"tl", -- 274
				"wa" -- 274
			}, description = "Preferred language variant to search."}, -- 274
			{ -- 275
				name = "limit", -- 275
				type = "number", -- 275
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 275
			}, -- 275
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 276
		}, -- 276
		rules = { -- 278
			"`docSource` defaults to `api`. Use `tutorial` to search teaching docs.", -- 279
			"Every result file uses the @dora-doc/api/... or @dora-doc/tutorial/... namespace and is readable with read_file.", -- 280
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 281
			"`useRegex` defaults to false whenever supported by a search tool.", -- 282
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraApiLimitMax)) .. "." end -- 283
		}, -- 283
		preExecutable = true, -- 285
		parallelSafe = true -- 286
	}, -- 286
	{ -- 288
		name = "build", -- 289
		roles = {"main", "sub"}, -- 290
		workModes = {"code"}, -- 291
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 292
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 293
		rules = {"Read the result and then decide whether another action is needed."} -- 296
	}, -- 296
	{ -- 300
		name = "fetch_url", -- 301
		roles = {"main", "sub"}, -- 302
		workModes = {"code"}, -- 303
		description = "Download a single HTTP or HTTPS resource into the project.", -- 304
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 305
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds."} -- 309
	}, -- 309
	{ -- 315
		name = "execute_command", -- 316
		roles = {"main", "sub"}, -- 317
		workModes = {"code"}, -- 318
		description = "Execute a controlled engine command.", -- 319
		parameters = { -- 320
			{ -- 321
				name = "mode", -- 321
				type = "string", -- 321
				required = true, -- 321
				enum = {"lua", "git"}, -- 321
				description = "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." -- 321
			}, -- 321
			{name = "code", type = "string", description = "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result."}, -- 322
			{name = "command", type = "string", description = "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported."}, -- 323
			{name = "cwd", type = "string", description = "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C."}, -- 324
			{name = "timeoutSeconds", type = "number", description = "Optional timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode uses an instruction hook to interrupt pure Lua loops that do not yield, but cannot interrupt a blocking native call."} -- 325
		}, -- 325
		rules = { -- 327
			"This tool is available only when the user enables command execution for the current Agent task.", -- 328
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 329
			"Lua mode runs with a temporary environment whose global lookups fall back to Dora APIs; global writes stay in that one command and are not shared with later commands.", -- 330
			"Lua command code is checked every 10,000 VM instructions against App.runningTime. A pure Lua loop is interrupted at the timeout; blocking native calls remain non-interruptible.", -- 331
			"Lua mode exposes projectDir, refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). getEntryStatus() returns a table containing success and running booleans.", -- 332
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 333
			"An Entry watchdog checks live Dora object and Lua-reference growth every frame. Growth of 50,000 C++ objects or 10,000 Lua references stops the test, runs Entry cleanup, and returns the measured growth; replace such tests with bounded entities and fixed simulation steps.", -- 334
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
		workModes = {"code", "plan"}, -- 346
		description = "End the task and provide a structured completion handoff.", -- 347
		parameters = { -- 348
			{name = "message", type = "string", required = true, description = "Final user-facing answer."}, -- 349
			{name = "outcome", type = "string", enum = {"completed", "partial", "blocked"}, description = "Work outcome. Sub agents must provide this; defaults to completed for compatibility."}, -- 350
			{name = "validation", type = "array", items = {type = "object", properties = {kind = {type = "string", enum = {"build", "runtime", "manual"}}, result = {type = "string", enum = {"passed", "failed", "not_run"}}, evidence = {type = "array", items = {type = "string"}}}, required = {"kind", "result"}}, description = "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."}, -- 351
			{name = "knownIssues", type = "array", items = {type = "string"}, description = "Known remaining issues or blockers. Sub agents must provide an array, which may be empty."}, -- 360
			{name = "assumptions", type = "array", items = {type = "string"}, description = "Material assumptions made during the work. Sub agents must provide an array, which may be empty."}, -- 361
			{name = "learningCandidates", type = "array", items = {type = "object", properties = {claim = {type = "string"}, scope = {type = "string", enum = {"file", "project", "engine"}}, evidence = {type = "array", items = {type = "string"}}, confidence = {type = "string", enum = {"observed", "inferred"}}}, required = {"claim", "scope", "confidence"}}, description = "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."} -- 362
		}, -- 362
		rules = {"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.", "Do not claim validation passed without concrete evidence from the corresponding tool result.", "Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration."} -- 373
	}, -- 373
	{ -- 379
		name = "list_sub_agents", -- 380
		roles = {"main"}, -- 381
		workModes = {"code"}, -- 382
		description = "Query sub-agent state under the current main session.", -- 383
		parameters = {{name = "status", type = "string", enum = { -- 384
			"active_or_recent", -- 385
			"running", -- 385
			"done", -- 385
			"failed", -- 385
			"all" -- 385
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 385
		rules = { -- 390
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 391
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 392
			"limit defaults to a small recent window. Use offset to page older items.", -- 393
			"query filters by title, goal, or summary text.", -- 394
			"After any successful spawn_sub_agent in the current task, this tool is unavailable for the rest of that task. Finish the turn instead; completion arrives through an asynchronous handoff." -- 395
		}, -- 395
		parallelSafe = true -- 397
	}, -- 397
	{ -- 399
		name = "spawn_sub_agent", -- 400
		roles = {"main"}, -- 401
		workModes = {"code"}, -- 402
		description = "Create and start a sub agent session for delegated implementation work.", -- 403
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 404
		rules = { -- 410
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 411
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 412
			"The spawned sub agent inherits the current session tool capabilities.", -- 413
			"title should be short and specific.", -- 414
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 415
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 416
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish the current turn and return control to the user while the sub agents keep running.", -- 417
			"After a successful spawn in the current task, do not call list_sub_agents, wait, join, or poll. Completion is delivered asynchronously as a later handoff.", -- 418
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.", -- 419
			"filesHint is an optional list of likely files or directories." -- 420
		} -- 420
	}, -- 420
	{ -- 423
		name = "ask_user", -- 424
		roles = {"main"}, -- 425
		workModes = {"plan"}, -- 426
		description = "Present a structured questionnaire and pause the Plan task until the user submits every required answer.", -- 427
		parameters = {{name = "title", type = "string", required = true, description = "Short questionnaire title."}, {name = "description", type = "string", description = "Optional context shown above the questions."}, { -- 428
			name = "questions", -- 432
			type = "array", -- 433
			required = true, -- 434
			description = "One to eight questions. Use single_choice, multiple_choice, or text. A single-choice question may recommend at most one option. A multiple-choice question may recommend a set no larger than maxSelections.", -- 435
			items = {type = "object", properties = { -- 436
				id = {type = "string"}, -- 439
				prompt = {type = "string"}, -- 440
				description = {type = "string"}, -- 441
				type = {type = "string", enum = {"single_choice", "multiple_choice", "text"}}, -- 442
				required = {type = "boolean"}, -- 443
				options = {type = "array", items = {type = "object", properties = {id = {type = "string"}, label = {type = "string"}, description = {type = "string"}, recommended = {type = "boolean", description = "Mark an option as recommended. Use at most one for single_choice; multiple_choice may mark a recommended set no larger than maxSelections."}}, required = {"id", "label"}}}, -- 444
				allowOther = {type = "boolean"}, -- 457
				placeholder = {type = "string"}, -- 458
				minSelections = {type = "number"}, -- 459
				maxSelections = {type = "number"} -- 460
			}, required = {"id", "prompt", "type"}} -- 460
		}}, -- 460
		rules = { -- 466
			"Inspect the project before asking; do not ask for facts available through read_file, grep_files, glob_files, or search_dora_api.", -- 467
			"ask_user has no document-update prerequisite. Incorporate the answers into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish.", -- 468
			"For single_choice, mark at most one option recommended. For multiple_choice, recommended options form a suggested set and must not exceed maxSelections.", -- 469
			"ask_user must be the only tool call in the response.", -- 470
			"The task pauses after the questionnaire is published and continues after the user submits answers or dismisses it.", -- 471
			"An answered or dismissed ask_user tool result contains authoritative user feedback. Apply answers when present; when dismissed, continue with reasonable assumptions and do not mechanically repeat the same questionnaire." -- 472
		} -- 472
	} -- 472
} -- 472
local DEFAULT_SCHEMA_CONTEXT = {searchDoraApiLimitMax = 20} -- 477
local function hasRole(tool, role) -- 481
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 482
end -- 481
local function hasWorkMode(tool, workMode) -- 485
	return __TS__ArrayIndexOf(tool.workModes, workMode) >= 0 -- 486
end -- 485
local function getToolPrompt(name) -- 489
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 490
		if tool.name == name then -- 490
			return tool -- 491
		end -- 491
	end -- 491
	return nil -- 493
end -- 489
local function isToolCapabilityEnabled(tool, options) -- 496
	if not ____exports.isKnownToolName(tool.name) then -- 496
		return false -- 497
	end -- 497
	return hasWorkMode(tool, options and options.workMode or "code") and __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 498
end -- 496
local function formatParameterList(tool) -- 502
	local parameters = tool.parameters or ({}) -- 503
	if #parameters == 0 then -- 503
		return "" -- 504
	end -- 504
	return table.concat( -- 505
		__TS__ArrayMap( -- 505
			parameters, -- 505
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 506
		), -- 506
		", " -- 507
	) -- 507
end -- 502
local function formatToolPrompt(tool, index, context) -- 510
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 511
	local parameterList = formatParameterList(tool) -- 512
	if parameterList ~= "" then -- 512
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 514
	end -- 514
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 516
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 517
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 518
	end -- 518
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 520
		lines[#lines + 1] = "\t- " .. rule -- 521
	end -- 521
	return table.concat(lines, "\n") -- 523
end -- 510
local function formatXMLRepairToolReference(tool) -- 526
	local parameterList = formatParameterList(tool) -- 527
	local params = parameterList ~= "" and parameterList or "none" -- 528
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 529
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 530
end -- 526
function ____exports.getAllowedToolsForRole(role, options) -- 537
	return __TS__ArrayMap( -- 538
		__TS__ArrayFilter( -- 538
			____exports.AGENT_TOOL_PROMPTS, -- 538
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 539
		), -- 539
		function(____, tool) return tool.name end -- 540
	) -- 540
end -- 537
function ____exports.buildCurrentToolAvailabilityGuidance() -- 543
	return table.concat({"Current tool availability:", "- every tool defined in the current system prompt or exposed in the current tool schema is executable", "- capabilities disabled for this task are omitted from both the definitions and schema"}, "\n") -- 544
end -- 543
function ____exports.getToolPromptsForRole(role, options) -- 551
	return __TS__ArrayFilter( -- 556
		____exports.AGENT_TOOL_PROMPTS, -- 556
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 556
	) -- 556
end -- 551
local SUB_AGENT_REQUIRED_FINISH_PARAMS = { -- 563
	"message", -- 564
	"outcome", -- 565
	"validation", -- 566
	"knownIssues", -- 567
	"assumptions", -- 568
	"learningCandidates" -- 569
} -- 569
local function getDecisionToolPromptsForRole(role, options) -- 572
	local tools = ____exports.getToolPromptsForRole(role, options) -- 577
	if role ~= "sub" then -- 577
		return tools -- 578
	end -- 578
	return __TS__ArrayMap( -- 579
		tools, -- 579
		function(____, tool) return tool.name ~= "finish" and tool or __TS__ObjectAssign( -- 579
			{}, -- 579
			tool, -- 580
			{parameters = __TS__ArrayMap( -- 579
				tool.parameters or ({}), -- 581
				function(____, parameter) return __TS__ObjectAssign( -- 581
					{}, -- 581
					parameter, -- 582
					{required = __TS__ArrayIndexOf(SUB_AGENT_REQUIRED_FINISH_PARAMS, parameter.name) >= 0} -- 581
				) end -- 581
			)} -- 581
		) end -- 581
	) -- 581
end -- 572
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 588
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 593
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 594
	local sections = __TS__ArrayMap( -- 595
		tools, -- 595
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 595
	) -- 595
	if (options and options.includeXmlRules) == true then -- 595
		local reasonTools = table.concat( -- 597
			__TS__ArrayMap( -- 597
				__TS__ArrayFilter( -- 597
					tools, -- 597
					function(____, tool) return tool.name ~= "finish" end -- 598
				), -- 598
				function(____, tool) return tool.name end -- 599
			), -- 599
			", " -- 600
		) -- 600
		sections[#sections + 1] = ("XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For " .. (reasonTools ~= "" and reasonTools or "tools other than finish")) .. ", include <tool>, <reason>, and <params>.\n- For finish, omit <reason> and include <message> plus every other required parameter shown above inside <params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 601
	end -- 601
	local body = table.concat(sections, "\n\n") -- 607
	return title ~= "" and (title .. "\n") .. body or body -- 608
end -- 588
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 611
	return ____exports.buildToolDefinitionsDetailed( -- 619
		getDecisionToolPromptsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 620
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 625
	) -- 625
end -- 611
function ____exports.buildXMLRepairToolReference(role, options) -- 633
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}) -- 634
	local ____array_28 = __TS__SparseArrayNew( -- 634
		"Allowed tools and XML params:", -- 640
		table.unpack(__TS__ArrayMap( -- 641
			tools, -- 641
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 641
		)) -- 641
	) -- 641
	__TS__SparseArrayPush( -- 641
		____array_28, -- 641
		"", -- 642
		"XML shape:", -- 643
		"- Wrap the decision in exactly one <tool_call> root.", -- 644
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 645
		"- For finish: include <tool>, omit <reason>, and include <message> plus every other required parameter shown above inside <params>.", -- 646
		"- Inside <params>, use one child tag per parameter name above." -- 647
	) -- 647
	local lines = {__TS__SparseArraySpread(____array_28)} -- 639
	return table.concat(lines, "\n") -- 649
end -- 633
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 652
	____exports.getToolPromptsForRole("sub"), -- 653
	{title = "Available tools:"} -- 654
) -- 654
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 657
	__TS__ArrayFilter( -- 658
		____exports.getToolPromptsForRole("main"), -- 658
		function(____, tool) return __TS__ArrayIndexOf( -- 659
			__TS__ArrayMap( -- 659
				____exports.getToolPromptsForRole("sub"), -- 659
				function(____, subTool) return subTool.name end -- 659
			), -- 659
			tool.name -- 659
		) < 0 end -- 659
	), -- 659
	{title = ""} -- 660
) -- 660
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 663
	__TS__ArrayFilter( -- 664
		____exports.AGENT_TOOL_PROMPTS, -- 664
		function(____, tool) return tool.name == "finish" end -- 664
	), -- 664
	{title = "", includeXmlRules = true} -- 665
) -- 665
function ____exports.canPreExecuteTool(tool) -- 668
	local prompt = getToolPrompt(tool) -- 669
	return (prompt and prompt.preExecutable) == true -- 670
end -- 668
function ____exports.canRunToolInParallel(tool) -- 673
	local prompt = getToolPrompt(tool) -- 674
	return (prompt and prompt.parallelSafe) == true -- 675
end -- 673
function ____exports.buildDecisionToolSchema(role, searchDoraApiLimitMax, options) -- 678
	local context = {searchDoraApiLimitMax = searchDoraApiLimitMax} -- 679
	return ____exports.buildDecisionToolSchemaForTools( -- 680
		getDecisionToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 680
		context -- 684
	) -- 684
end -- 678
return ____exports -- 678