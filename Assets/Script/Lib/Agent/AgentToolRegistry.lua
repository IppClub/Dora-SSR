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
function ____exports.isKnownToolName(name) -- 536
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 537
end -- 536
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 690
	return __TS__ArrayMap( -- 691
		tools, -- 691
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 692
	) -- 692
end -- 690
BUILT_IN_AGENT_TOOL_NAMES = { -- 22
	"read_file", -- 23
	"edit_file", -- 24
	"delete_file", -- 25
	"grep_files", -- 26
	"search_dora_doc", -- 27
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
		description = "Read a specific line range from a workspace file, built-in document, or virtual engine log.", -- 183
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path, the virtual @dora_full_logs.txt engine log, or an exact @dora-doc/... path returned by search_dora_doc."}, {name = "startLine", type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, -- 184
		rules = {"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", "Read @dora_full_logs.txt to inspect the current Dora engine log snapshot; it is a read-only virtual path, not a workspace file.", "Paths returned by search_dora_doc are authoritative built-in documentation paths and can be read directly without modifying them."}, -- 189
		parallelSafe = true -- 194
	}, -- 194
	{ -- 196
		name = "edit_file", -- 197
		roles = {"main", "sub"}, -- 198
		workModes = {"code", "plan"}, -- 199
		description = "Make changes to a file.", -- 200
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to edit."}, {name = "old_str", type = "string", required = true, description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, {name = "new_str", type = "string", required = true, description = "Replacement text or the full file content when rewriting or creating."}}, -- 201
		rules = { -- 206
			"old_str and new_str MUST be different.", -- 207
			"old_str must match existing text exactly when it is non-empty.", -- 208
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.", -- 209
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build.", -- 210
			"For Dora .ts/.tsx source, the engine rejects known unsupported constructs before writing: Math.random, Math.hypot, Math.imul, KeyName.Enter, and ReturnType<typeof DoraFactory>. Inject or implement a bounded RNG, use supported arithmetic/key names, and annotate Dora instances with X.Type." -- 211
		} -- 211
	}, -- 211
	{ -- 214
		name = "delete_file", -- 215
		roles = {"main", "sub"}, -- 216
		workModes = {"code", "plan"}, -- 217
		description = "Remove a file.", -- 218
		parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}} -- 219
	}, -- 219
	{ -- 223
		name = "grep_files", -- 224
		roles = {"main", "sub"}, -- 225
		workModes = {"code", "plan"}, -- 226
		description = "Search text patterns inside files.", -- 227
		parameters = { -- 228
			{name = "path", type = "string", description = "Workspace directory, workspace file, or exact @dora-doc/... virtual document path to search within."}, -- 229
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 230
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 231
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 232
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 233
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 234
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 235
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 236
		}, -- 236
		rules = { -- 238
			"`path` may point to a workspace directory, workspace file, or an exact @dora-doc/... virtual document returned by search_dora_doc.", -- 239
			"This is content search (grep), not filename search.", -- 240
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 241
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 242
			"`caseSensitive` defaults to false.", -- 243
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 244
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 245
		}, -- 245
		parallelSafe = true -- 247
	}, -- 247
	{ -- 249
		name = "glob_files", -- 250
		roles = {"main", "sub"}, -- 251
		workModes = {"code", "plan"}, -- 252
		description = "Enumerate files under a directory.", -- 253
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 254
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 259
		parallelSafe = true -- 263
	}, -- 263
	{ -- 265
		name = "search_dora_doc", -- 266
		roles = {"main", "sub"}, -- 267
		workModes = {"code", "plan"}, -- 268
		description = "Search one authoritative Dora, LÖVE, or TIC-80 documentation set.", -- 269
		parameters = { -- 270
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 271
			{name = "docType", type = "string", enum = {"dora-tutorial", "dora-api", "love-api", "tic80-api"}, description = "Exact documentation set to search. Defaults to dora-api."}, -- 272
			{name = "programmingLanguage", type = "string", enum = { -- 273
				"ts", -- 273
				"tsx", -- 273
				"lua", -- 273
				"yue", -- 273
				"teal", -- 273
				"tl", -- 273
				"wa" -- 273
			}, description = "Preferred language variant to search."}, -- 273
			{ -- 274
				name = "limit", -- 274
				type = "number", -- 274
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraDocLimitMax)) .. "." end -- 274
			}, -- 274
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 275
		}, -- 275
		rules = { -- 277
			"`docType` defaults to `dora-api`; select `dora-tutorial`, `love-api`, or `tic80-api` explicitly when needed.", -- 278
			"Each type searches only its matching files: Dora tutorials, Dora API definitions excluding Love/TIC-80, love.d.*, or tic80.d.*.", -- 279
			"Every result file uses the @dora-doc/<docType>/... namespace; it is readable with read_file and searchable with grep_files using the exact virtual path.", -- 280
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 281
			"`useRegex` defaults to false whenever supported by a search tool.", -- 282
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraDocLimitMax)) .. "." end -- 283
		}, -- 283
		parallelSafe = true -- 285
	}, -- 285
	{ -- 287
		name = "build", -- 288
		roles = {"main", "sub"}, -- 289
		workModes = {"code"}, -- 290
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 291
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 292
		rules = {"Read the result and then decide whether another action is needed."} -- 295
	}, -- 295
	{ -- 299
		name = "fetch_url", -- 300
		roles = {"main", "sub"}, -- 301
		workModes = {"code"}, -- 302
		description = "Download a single HTTP or HTTPS resource into the project.", -- 303
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 304
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "Local, private, metadata, and literal-IP destinations are rejected. Downloads are limited to 32 MiB.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds."} -- 308
	}, -- 308
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
			{name = "timeoutSeconds", type = "number", description = "Optional total command timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode also interrupts a command thread that occupies one game frame for 5 seconds, but cannot interrupt a blocking native call."} -- 325
		}, -- 325
		rules = { -- 327
			"This tool is available only when the user enables command execution for the current Agent task.", -- 328
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 329
			"Lua mode runs with a temporary environment whose global writes stay in that one command. DB, HttpClient, HttpServer, and Content write operations are unavailable. Content supports only project-relative exist, isdir, getAttr, and load operations.", -- 330
			"Lua command code is checked every 10,000 VM instructions against App.elapsedTime. A command thread that occupies one game frame for 5 seconds is interrupted; time spent yielded across frames does not accumulate toward this per-frame limit, and blocking native calls remain non-interruptible.", -- 331
			"Lua mode exposes projectDir, reportProgress(update), refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). reportProgress accepts a table with progress from 0 to 1 plus optional stage and message. getEntryStatus() returns a table containing success and running booleans.", -- 332
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 333
			"An Entry watchdog checks live Dora object and Lua-reference growth every frame and from the Lua instruction hook. Growth of 50,000 C++ objects or 10,000 Lua references stops the test, runs Entry cleanup, and returns the measured growth; replace such tests with bounded entities and fixed simulation steps.", -- 334
			"After a Lua command finishes, the Web IDE resource tree is refreshed automatically whenever the command accessed Content and did not call refreshTree itself, including commands that later fail, are canceled, or time out. Pure computation commands do not refresh the tree. refreshTree(\"relative/file\") or refreshTree() remains available for explicit updates.", -- 335
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 336
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.", -- 337
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 338
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.", -- 339
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten.", -- 340
			"Git clone rejects local, private, metadata, and literal-IP destinations and discards repositories larger than 128 MiB.", -- 341
			"The Web IDE resource tree is refreshed automatically after every successful Git command." -- 342
		} -- 342
	}, -- 342
	{ -- 345
		name = "finish", -- 346
		roles = {"main", "sub"}, -- 347
		workModes = {"code", "plan"}, -- 348
		description = "End the task and provide a structured completion handoff.", -- 349
		parameters = { -- 350
			{name = "message", type = "string", required = true, description = "Final user-facing answer."}, -- 351
			{name = "outcome", type = "string", enum = {"completed", "partial", "blocked"}, description = "Work outcome. Sub agents must provide this; defaults to completed for compatibility."}, -- 352
			{name = "validation", type = "array", items = {type = "object", properties = {kind = {type = "string", enum = {"build", "runtime", "manual"}}, result = {type = "string", enum = {"passed", "failed", "not_run"}}, evidence = {type = "array", items = {type = "string"}}}, required = {"kind", "result"}}, description = "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."}, -- 353
			{name = "knownIssues", type = "array", items = {type = "string"}, description = "Known remaining issues or blockers. Sub agents must provide an array, which may be empty."}, -- 364
			{name = "assumptions", type = "array", items = {type = "string"}, description = "Material assumptions made during the work. Sub agents must provide an array, which may be empty."}, -- 365
			{name = "learningCandidates", type = "array", items = {type = "object", properties = {claim = {type = "string"}, scope = {type = "string", enum = {"file", "project", "engine"}}, evidence = {type = "array", items = {type = "string"}}, confidence = {type = "string", enum = {"observed", "inferred"}}}, required = {"claim", "scope", "confidence"}}, description = "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."} -- 366
		}, -- 366
		rules = {"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.", "Do not claim validation passed without concrete evidence from the corresponding tool result.", "Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration."} -- 379
	}, -- 379
	{ -- 385
		name = "list_sub_agents", -- 386
		roles = {"main"}, -- 387
		workModes = {"code"}, -- 388
		description = "Query sub-agent state under the current main session.", -- 389
		parameters = {{name = "status", type = "string", enum = { -- 390
			"active_or_recent", -- 391
			"running", -- 391
			"done", -- 391
			"failed", -- 391
			"all" -- 391
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 391
		rules = { -- 396
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 397
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 398
			"limit defaults to a small recent window. Use offset to page older items.", -- 399
			"query filters by title, goal, or summary text.", -- 400
			"After any successful spawn_sub_agent in the current task, this tool is unavailable for the rest of that task. Finish the turn instead; completion arrives through an asynchronous handoff." -- 401
		}, -- 401
		parallelSafe = true -- 403
	}, -- 403
	{ -- 405
		name = "spawn_sub_agent", -- 406
		roles = {"main"}, -- 407
		workModes = {"code"}, -- 408
		description = "Create and start a sub agent session for delegated implementation work.", -- 409
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 410
		rules = { -- 416
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 417
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 418
			"The spawned sub agent inherits the current session tool capabilities.", -- 419
			"title should be short and specific.", -- 420
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 421
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 422
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish the current turn and return control to the user while the sub agents keep running.", -- 423
			"After a successful spawn in the current task, do not call list_sub_agents, wait, join, or poll. Completion is delivered asynchronously as a later handoff.", -- 424
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.", -- 425
			"filesHint is an optional list of likely files or directories." -- 426
		} -- 426
	}, -- 426
	{ -- 429
		name = "ask_user", -- 430
		roles = {"main"}, -- 431
		workModes = {"plan"}, -- 432
		description = "Present a structured questionnaire and pause the Plan task until the user submits every required answer.", -- 433
		parameters = {{name = "title", type = "string", required = true, description = "Short questionnaire title."}, {name = "description", type = "string", description = "Optional context shown above the questions."}, { -- 434
			name = "questions", -- 438
			type = "array", -- 439
			required = true, -- 440
			description = "One to eight questions. Use single_choice, multiple_choice, or text. A single-choice question may recommend at most one option.", -- 441
			items = {type = "object", properties = { -- 442
				id = {type = "string"}, -- 445
				prompt = {type = "string"}, -- 446
				description = {type = "string"}, -- 447
				type = {type = "string", enum = {"single_choice", "multiple_choice", "text"}}, -- 448
				required = {type = "boolean"}, -- 449
				options = {type = "array", items = {type = "object", properties = {id = {type = "string"}, label = {type = "string"}, description = {type = "string"}, recommended = {type = "boolean", description = "Mark an option as recommended. Use at most one for single_choice; multiple_choice may mark any recommended set."}}, required = {"id", "label"}}}, -- 450
				placeholder = {type = "string"} -- 463
			}, required = {"id", "prompt", "type"}} -- 463
		}}, -- 463
		rules = { -- 469
			"Inspect the project before asking; do not ask for facts available through read_file, grep_files, glob_files, or search_dora_doc.", -- 470
			"ask_user has no document-update prerequisite. Incorporate the answers into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish.", -- 471
			"For single_choice, mark at most one option recommended. For multiple_choice, recommended options form a suggested set.", -- 472
			"ask_user must be the only tool call in the response.", -- 473
			"The task pauses after the questionnaire is published and continues after the user submits answers or dismisses it.", -- 474
			"An answered or dismissed ask_user tool result contains authoritative user feedback. Apply answers when present; when dismissed, continue with reasonable assumptions and do not mechanically repeat the same questionnaire." -- 475
		} -- 475
	} -- 475
} -- 475
local DEFAULT_SCHEMA_CONTEXT = {searchDoraDocLimitMax = 20} -- 480
local function hasRole(tool, role) -- 484
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 485
end -- 484
local function hasWorkMode(tool, workMode) -- 488
	return __TS__ArrayIndexOf(tool.workModes, workMode) >= 0 -- 489
end -- 488
local function getToolPrompt(name) -- 492
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 493
		if tool.name == name then -- 493
			return tool -- 494
		end -- 494
	end -- 494
	return nil -- 496
end -- 492
local function isToolCapabilityEnabled(tool, options) -- 499
	if not ____exports.isKnownToolName(tool.name) then -- 499
		return false -- 500
	end -- 500
	return hasWorkMode(tool, options and options.workMode or "code") and __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 501
end -- 499
local function formatParameterList(tool) -- 505
	local parameters = tool.parameters or ({}) -- 506
	if #parameters == 0 then -- 506
		return "" -- 507
	end -- 507
	return table.concat( -- 508
		__TS__ArrayMap( -- 508
			parameters, -- 508
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 509
		), -- 509
		", " -- 510
	) -- 510
end -- 505
local function formatToolPrompt(tool, index, context) -- 513
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 514
	local parameterList = formatParameterList(tool) -- 515
	if parameterList ~= "" then -- 515
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 517
	end -- 517
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 519
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 520
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 521
	end -- 521
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 523
		lines[#lines + 1] = "\t- " .. rule -- 524
	end -- 524
	return table.concat(lines, "\n") -- 526
end -- 513
local function formatXMLRepairToolReference(tool) -- 529
	local parameterList = formatParameterList(tool) -- 530
	local params = parameterList ~= "" and parameterList or "none" -- 531
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 532
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 533
end -- 529
function ____exports.getAllowedToolsForRole(role, options) -- 540
	return __TS__ArrayMap( -- 541
		__TS__ArrayFilter( -- 541
			____exports.AGENT_TOOL_PROMPTS, -- 541
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 542
		), -- 542
		function(____, tool) return tool.name end -- 543
	) -- 543
end -- 540
function ____exports.buildCurrentToolAvailabilityGuidance() -- 546
	return table.concat({"Current tool availability:", "- every tool defined in the current system prompt or exposed in the current tool schema is executable", "- capabilities disabled for this task are omitted from both the definitions and schema"}, "\n") -- 547
end -- 546
function ____exports.getToolPromptsForRole(role, options) -- 554
	return __TS__ArrayFilter( -- 559
		____exports.AGENT_TOOL_PROMPTS, -- 559
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 559
	) -- 559
end -- 554
local SUB_AGENT_REQUIRED_FINISH_PARAMS = { -- 566
	"message", -- 567
	"outcome", -- 568
	"validation", -- 569
	"knownIssues", -- 570
	"assumptions", -- 571
	"learningCandidates" -- 572
} -- 572
local function getDecisionToolPromptsForRole(role, options) -- 575
	local tools = ____exports.getToolPromptsForRole(role, options) -- 580
	if role ~= "sub" then -- 580
		return tools -- 581
	end -- 581
	return __TS__ArrayMap( -- 582
		tools, -- 582
		function(____, tool) return tool.name ~= "finish" and tool or __TS__ObjectAssign( -- 582
			{}, -- 582
			tool, -- 583
			{parameters = __TS__ArrayMap( -- 582
				tool.parameters or ({}), -- 584
				function(____, parameter) return __TS__ObjectAssign( -- 584
					{}, -- 584
					parameter, -- 585
					{required = __TS__ArrayIndexOf(SUB_AGENT_REQUIRED_FINISH_PARAMS, parameter.name) >= 0} -- 584
				) end -- 584
			)} -- 584
		) end -- 584
	) -- 584
end -- 575
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 591
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 596
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 597
	local sections = __TS__ArrayMap( -- 598
		tools, -- 598
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 598
	) -- 598
	if (options and options.includeXmlRules) == true then -- 598
		local reasonTools = table.concat( -- 600
			__TS__ArrayMap( -- 600
				__TS__ArrayFilter( -- 600
					tools, -- 600
					function(____, tool) return tool.name ~= "finish" end -- 601
				), -- 601
				function(____, tool) return tool.name end -- 602
			), -- 602
			", " -- 603
		) -- 603
		sections[#sections + 1] = ("XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For " .. (reasonTools ~= "" and reasonTools or "tools other than finish")) .. ", include <tool>, <reason>, and <params>.\n- For finish, omit <reason> and include <message> plus every other required parameter shown above inside <params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 604
	end -- 604
	local body = table.concat(sections, "\n\n") -- 610
	return title ~= "" and (title .. "\n") .. body or body -- 611
end -- 591
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 614
	return ____exports.buildToolDefinitionsDetailed( -- 622
		getDecisionToolPromptsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 623
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 628
	) -- 628
end -- 614
function ____exports.buildXMLRepairToolReference(role, options) -- 636
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}) -- 637
	local ____array_28 = __TS__SparseArrayNew( -- 637
		"Allowed tools and XML params:", -- 643
		table.unpack(__TS__ArrayMap( -- 644
			tools, -- 644
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 644
		)) -- 644
	) -- 644
	__TS__SparseArrayPush( -- 644
		____array_28, -- 644
		"", -- 645
		"XML shape:", -- 646
		"- Wrap the decision in exactly one <tool_call> root.", -- 647
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 648
		"- For finish: include <tool>, omit <reason>, and include <message> plus every other required parameter shown above inside <params>.", -- 649
		"- Inside <params>, use one child tag per parameter name above." -- 650
	) -- 650
	local lines = {__TS__SparseArraySpread(____array_28)} -- 642
	return table.concat(lines, "\n") -- 652
end -- 636
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 655
	____exports.getToolPromptsForRole("sub"), -- 656
	{title = "Available tools:"} -- 657
) -- 657
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 660
	__TS__ArrayFilter( -- 661
		____exports.getToolPromptsForRole("main"), -- 661
		function(____, tool) return __TS__ArrayIndexOf( -- 662
			__TS__ArrayMap( -- 662
				____exports.getToolPromptsForRole("sub"), -- 662
				function(____, subTool) return subTool.name end -- 662
			), -- 662
			tool.name -- 662
		) < 0 end -- 662
	), -- 662
	{title = ""} -- 663
) -- 663
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 666
	__TS__ArrayFilter( -- 667
		____exports.AGENT_TOOL_PROMPTS, -- 667
		function(____, tool) return tool.name == "finish" end -- 667
	), -- 667
	{title = "", includeXmlRules = true} -- 668
) -- 668
function ____exports.canPreExecuteTool(tool) -- 671
	local prompt = getToolPrompt(tool) -- 672
	return (prompt and prompt.preExecutable) == true -- 673
end -- 671
function ____exports.canRunToolInParallel(tool) -- 676
	local prompt = getToolPrompt(tool) -- 677
	return (prompt and prompt.parallelSafe) == true -- 678
end -- 676
function ____exports.buildDecisionToolSchema(role, searchDoraDocLimitMax, options) -- 681
	local context = {searchDoraDocLimitMax = searchDoraDocLimitMax} -- 682
	return ____exports.buildDecisionToolSchemaForTools( -- 683
		getDecisionToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 683
		context -- 687
	) -- 687
end -- 681
return ____exports -- 681