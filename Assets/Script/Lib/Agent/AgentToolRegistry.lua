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
function ____exports.isKnownToolName(name) -- 537
	return __TS__ArrayIndexOf(BUILT_IN_AGENT_TOOL_NAMES, name) >= 0 -- 538
end -- 537
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 691
	return __TS__ArrayMap( -- 692
		tools, -- 692
		function(____, tool) return tool.schema and tool:schema(context) or createFunctionToolSchemaFromPrompt(tool, context) end -- 693
	) -- 693
end -- 691
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
			{name = "path", type = "string", description = "Base directory or file path to search within."}, -- 229
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 230
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 231
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 232
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 233
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 234
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 235
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 236
		}, -- 236
		rules = { -- 238
			"`path` may point to either a directory or a single file.", -- 239
			"This is content search (grep), not filename search.", -- 240
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 241
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 242
			"`caseSensitive` defaults to false.", -- 243
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 244
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 245
		}, -- 245
		preExecutable = true, -- 247
		parallelSafe = true -- 248
	}, -- 248
	{ -- 250
		name = "glob_files", -- 251
		roles = {"main", "sub"}, -- 252
		workModes = {"code", "plan"}, -- 253
		description = "Enumerate files under a directory.", -- 254
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 255
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 260
		preExecutable = true, -- 264
		parallelSafe = true -- 265
	}, -- 265
	{ -- 267
		name = "search_dora_doc", -- 268
		roles = {"main", "sub"}, -- 269
		workModes = {"code", "plan"}, -- 270
		description = "Search one authoritative Dora, LÖVE, or TIC-80 documentation set.", -- 271
		parameters = { -- 272
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 273
			{name = "docType", type = "string", enum = {"dora-tutorial", "dora-api", "love-api", "tic80-api"}, description = "Exact documentation set to search. Defaults to dora-api."}, -- 274
			{name = "programmingLanguage", type = "string", enum = { -- 275
				"ts", -- 275
				"tsx", -- 275
				"lua", -- 275
				"yue", -- 275
				"teal", -- 275
				"tl", -- 275
				"wa" -- 275
			}, description = "Preferred language variant to search."}, -- 275
			{ -- 276
				name = "limit", -- 276
				type = "number", -- 276
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraDocLimitMax)) .. "." end -- 276
			}, -- 276
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 277
		}, -- 277
		rules = { -- 279
			"`docType` defaults to `dora-api`; select `dora-tutorial`, `love-api`, or `tic80-api` explicitly when needed.", -- 280
			"Each type searches only its matching files: Dora tutorials, Dora API definitions excluding Love/TIC-80, love.d.*, or tic80.d.*.", -- 281
			"Every result file uses the @dora-doc/<docType>/... namespace and is readable with read_file.", -- 282
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 283
			"`useRegex` defaults to false whenever supported by a search tool.", -- 284
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraDocLimitMax)) .. "." end -- 285
		}, -- 285
		preExecutable = true, -- 287
		parallelSafe = true -- 288
	}, -- 288
	{ -- 290
		name = "build", -- 291
		roles = {"main", "sub"}, -- 292
		workModes = {"code"}, -- 293
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 294
		parameters = {{name = "path", type = "string", description = "Optional workspace-relative file or directory to build."}}, -- 295
		rules = {"Read the result and then decide whether another action is needed."} -- 298
	}, -- 298
	{ -- 302
		name = "fetch_url", -- 303
		roles = {"main", "sub"}, -- 304
		workModes = {"code"}, -- 305
		description = "Download a single HTTP or HTTPS resource into the project.", -- 306
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 307
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds."} -- 311
	}, -- 311
	{ -- 317
		name = "execute_command", -- 318
		roles = {"main", "sub"}, -- 319
		workModes = {"code"}, -- 320
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
			{name = "timeoutSeconds", type = "number", description = "Optional total command timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode also interrupts a command thread that occupies one game frame for 5 seconds, but cannot interrupt a blocking native call."} -- 327
		}, -- 327
		rules = { -- 329
			"This tool is available only when the user enables command execution for the current Agent task.", -- 330
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 331
			"Lua mode runs with a temporary environment whose global lookups fall back to Dora APIs; global writes stay in that one command and are not shared with later commands.", -- 332
			"Lua command code is checked every 10,000 VM instructions against App.elapsedTime. A command thread that occupies one game frame for 5 seconds is interrupted; time spent yielded across frames does not accumulate toward this per-frame limit, and blocking native calls remain non-interruptible.", -- 333
			"Lua mode exposes projectDir, reportProgress(update), refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). reportProgress accepts a table with progress from 0 to 1 plus optional stage and message. getEntryStatus() returns a table containing success and running booleans.", -- 334
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 335
			"An Entry watchdog checks live Dora object and Lua-reference growth every frame and from the Lua instruction hook. Growth of 50,000 C++ objects or 10,000 Lua references stops the test, runs Entry cleanup, and returns the measured growth; replace such tests with bounded entities and fixed simulation steps.", -- 336
			"After a Lua command finishes, the Web IDE resource tree is refreshed automatically whenever the command accessed Content and did not call refreshTree itself, including commands that later fail, are canceled, or time out. Pure computation commands do not refresh the tree. refreshTree(\"relative/file\") or refreshTree() remains available for explicit updates.", -- 337
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 338
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.", -- 339
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 340
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.", -- 341
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten.", -- 342
			"The Web IDE resource tree is refreshed automatically after every successful Git command." -- 343
		} -- 343
	}, -- 343
	{ -- 346
		name = "finish", -- 347
		roles = {"main", "sub"}, -- 348
		workModes = {"code", "plan"}, -- 349
		description = "End the task and provide a structured completion handoff.", -- 350
		parameters = { -- 351
			{name = "message", type = "string", required = true, description = "Final user-facing answer."}, -- 352
			{name = "outcome", type = "string", enum = {"completed", "partial", "blocked"}, description = "Work outcome. Sub agents must provide this; defaults to completed for compatibility."}, -- 353
			{name = "validation", type = "array", items = {type = "object", properties = {kind = {type = "string", enum = {"build", "runtime", "manual"}}, result = {type = "string", enum = {"passed", "failed", "not_run"}}, evidence = {type = "array", items = {type = "string"}}}, required = {"kind", "result"}}, description = "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."}, -- 354
			{name = "knownIssues", type = "array", items = {type = "string"}, description = "Known remaining issues or blockers. Sub agents must provide an array, which may be empty."}, -- 365
			{name = "assumptions", type = "array", items = {type = "string"}, description = "Material assumptions made during the work. Sub agents must provide an array, which may be empty."}, -- 366
			{name = "learningCandidates", type = "array", items = {type = "object", properties = {claim = {type = "string"}, scope = {type = "string", enum = {"file", "project", "engine"}}, evidence = {type = "array", items = {type = "string"}}, confidence = {type = "string", enum = {"observed", "inferred"}}}, required = {"claim", "scope", "confidence"}}, description = "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."} -- 367
		}, -- 367
		rules = {"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.", "Do not claim validation passed without concrete evidence from the corresponding tool result.", "Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration."} -- 380
	}, -- 380
	{ -- 386
		name = "list_sub_agents", -- 387
		roles = {"main"}, -- 388
		workModes = {"code"}, -- 389
		description = "Query sub-agent state under the current main session.", -- 390
		parameters = {{name = "status", type = "string", enum = { -- 391
			"active_or_recent", -- 392
			"running", -- 392
			"done", -- 392
			"failed", -- 392
			"all" -- 392
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 392
		rules = { -- 397
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 398
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 399
			"limit defaults to a small recent window. Use offset to page older items.", -- 400
			"query filters by title, goal, or summary text.", -- 401
			"After any successful spawn_sub_agent in the current task, this tool is unavailable for the rest of that task. Finish the turn instead; completion arrives through an asynchronous handoff." -- 402
		}, -- 402
		parallelSafe = true -- 404
	}, -- 404
	{ -- 406
		name = "spawn_sub_agent", -- 407
		roles = {"main"}, -- 408
		workModes = {"code"}, -- 409
		description = "Create and start a sub agent session for delegated implementation work.", -- 410
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 411
		rules = { -- 417
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 418
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 419
			"The spawned sub agent inherits the current session tool capabilities.", -- 420
			"title should be short and specific.", -- 421
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 422
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 423
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish the current turn and return control to the user while the sub agents keep running.", -- 424
			"After a successful spawn in the current task, do not call list_sub_agents, wait, join, or poll. Completion is delivered asynchronously as a later handoff.", -- 425
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.", -- 426
			"filesHint is an optional list of likely files or directories." -- 427
		} -- 427
	}, -- 427
	{ -- 430
		name = "ask_user", -- 431
		roles = {"main"}, -- 432
		workModes = {"plan"}, -- 433
		description = "Present a structured questionnaire and pause the Plan task until the user submits every required answer.", -- 434
		parameters = {{name = "title", type = "string", required = true, description = "Short questionnaire title."}, {name = "description", type = "string", description = "Optional context shown above the questions."}, { -- 435
			name = "questions", -- 439
			type = "array", -- 440
			required = true, -- 441
			description = "One to eight questions. Use single_choice, multiple_choice, or text. A single-choice question may recommend at most one option.", -- 442
			items = {type = "object", properties = { -- 443
				id = {type = "string"}, -- 446
				prompt = {type = "string"}, -- 447
				description = {type = "string"}, -- 448
				type = {type = "string", enum = {"single_choice", "multiple_choice", "text"}}, -- 449
				required = {type = "boolean"}, -- 450
				options = {type = "array", items = {type = "object", properties = {id = {type = "string"}, label = {type = "string"}, description = {type = "string"}, recommended = {type = "boolean", description = "Mark an option as recommended. Use at most one for single_choice; multiple_choice may mark any recommended set."}}, required = {"id", "label"}}}, -- 451
				placeholder = {type = "string"} -- 464
			}, required = {"id", "prompt", "type"}} -- 464
		}}, -- 464
		rules = { -- 470
			"Inspect the project before asking; do not ask for facts available through read_file, grep_files, glob_files, or search_dora_doc.", -- 471
			"ask_user has no document-update prerequisite. Incorporate the answers into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish.", -- 472
			"For single_choice, mark at most one option recommended. For multiple_choice, recommended options form a suggested set.", -- 473
			"ask_user must be the only tool call in the response.", -- 474
			"The task pauses after the questionnaire is published and continues after the user submits answers or dismisses it.", -- 475
			"An answered or dismissed ask_user tool result contains authoritative user feedback. Apply answers when present; when dismissed, continue with reasonable assumptions and do not mechanically repeat the same questionnaire." -- 476
		} -- 476
	} -- 476
} -- 476
local DEFAULT_SCHEMA_CONTEXT = {searchDoraDocLimitMax = 20} -- 481
local function hasRole(tool, role) -- 485
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 486
end -- 485
local function hasWorkMode(tool, workMode) -- 489
	return __TS__ArrayIndexOf(tool.workModes, workMode) >= 0 -- 490
end -- 489
local function getToolPrompt(name) -- 493
	for ____, tool in ipairs(____exports.AGENT_TOOL_PROMPTS) do -- 494
		if tool.name == name then -- 494
			return tool -- 495
		end -- 495
	end -- 495
	return nil -- 497
end -- 493
local function isToolCapabilityEnabled(tool, options) -- 500
	if not ____exports.isKnownToolName(tool.name) then -- 500
		return false -- 501
	end -- 501
	return hasWorkMode(tool, options and options.workMode or "code") and __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 502
end -- 500
local function formatParameterList(tool) -- 506
	local parameters = tool.parameters or ({}) -- 507
	if #parameters == 0 then -- 507
		return "" -- 508
	end -- 508
	return table.concat( -- 509
		__TS__ArrayMap( -- 509
			parameters, -- 509
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 510
		), -- 510
		", " -- 511
	) -- 511
end -- 506
local function formatToolPrompt(tool, index, context) -- 514
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 515
	local parameterList = formatParameterList(tool) -- 516
	if parameterList ~= "" then -- 516
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 518
	end -- 518
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 520
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 521
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 522
	end -- 522
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 524
		lines[#lines + 1] = "\t- " .. rule -- 525
	end -- 525
	return table.concat(lines, "\n") -- 527
end -- 514
local function formatXMLRepairToolReference(tool) -- 530
	local parameterList = formatParameterList(tool) -- 531
	local params = parameterList ~= "" and parameterList or "none" -- 532
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 533
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 534
end -- 530
function ____exports.getAllowedToolsForRole(role, options) -- 541
	return __TS__ArrayMap( -- 542
		__TS__ArrayFilter( -- 542
			____exports.AGENT_TOOL_PROMPTS, -- 542
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 543
		), -- 543
		function(____, tool) return tool.name end -- 544
	) -- 544
end -- 541
function ____exports.buildCurrentToolAvailabilityGuidance() -- 547
	return table.concat({"Current tool availability:", "- every tool defined in the current system prompt or exposed in the current tool schema is executable", "- capabilities disabled for this task are omitted from both the definitions and schema"}, "\n") -- 548
end -- 547
function ____exports.getToolPromptsForRole(role, options) -- 555
	return __TS__ArrayFilter( -- 560
		____exports.AGENT_TOOL_PROMPTS, -- 560
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 560
	) -- 560
end -- 555
local SUB_AGENT_REQUIRED_FINISH_PARAMS = { -- 567
	"message", -- 568
	"outcome", -- 569
	"validation", -- 570
	"knownIssues", -- 571
	"assumptions", -- 572
	"learningCandidates" -- 573
} -- 573
local function getDecisionToolPromptsForRole(role, options) -- 576
	local tools = ____exports.getToolPromptsForRole(role, options) -- 581
	if role ~= "sub" then -- 581
		return tools -- 582
	end -- 582
	return __TS__ArrayMap( -- 583
		tools, -- 583
		function(____, tool) return tool.name ~= "finish" and tool or __TS__ObjectAssign( -- 583
			{}, -- 583
			tool, -- 584
			{parameters = __TS__ArrayMap( -- 583
				tool.parameters or ({}), -- 585
				function(____, parameter) return __TS__ObjectAssign( -- 585
					{}, -- 585
					parameter, -- 586
					{required = __TS__ArrayIndexOf(SUB_AGENT_REQUIRED_FINISH_PARAMS, parameter.name) >= 0} -- 585
				) end -- 585
			)} -- 585
		) end -- 585
	) -- 585
end -- 576
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 592
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 597
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 598
	local sections = __TS__ArrayMap( -- 599
		tools, -- 599
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 599
	) -- 599
	if (options and options.includeXmlRules) == true then -- 599
		local reasonTools = table.concat( -- 601
			__TS__ArrayMap( -- 601
				__TS__ArrayFilter( -- 601
					tools, -- 601
					function(____, tool) return tool.name ~= "finish" end -- 602
				), -- 602
				function(____, tool) return tool.name end -- 603
			), -- 603
			", " -- 604
		) -- 604
		sections[#sections + 1] = ("XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For " .. (reasonTools ~= "" and reasonTools or "tools other than finish")) .. ", include <tool>, <reason>, and <params>.\n- For finish, omit <reason> and include <message> plus every other required parameter shown above inside <params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 605
	end -- 605
	local body = table.concat(sections, "\n\n") -- 611
	return title ~= "" and (title .. "\n") .. body or body -- 612
end -- 592
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 615
	return ____exports.buildToolDefinitionsDetailed( -- 623
		getDecisionToolPromptsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 624
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 629
	) -- 629
end -- 615
function ____exports.buildXMLRepairToolReference(role, options) -- 637
	local tools = ____exports.getToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}) -- 638
	local ____array_28 = __TS__SparseArrayNew( -- 638
		"Allowed tools and XML params:", -- 644
		table.unpack(__TS__ArrayMap( -- 645
			tools, -- 645
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 645
		)) -- 645
	) -- 645
	__TS__SparseArrayPush( -- 645
		____array_28, -- 645
		"", -- 646
		"XML shape:", -- 647
		"- Wrap the decision in exactly one <tool_call> root.", -- 648
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 649
		"- For finish: include <tool>, omit <reason>, and include <message> plus every other required parameter shown above inside <params>.", -- 650
		"- Inside <params>, use one child tag per parameter name above." -- 651
	) -- 651
	local lines = {__TS__SparseArraySpread(____array_28)} -- 643
	return table.concat(lines, "\n") -- 653
end -- 637
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 656
	____exports.getToolPromptsForRole("sub"), -- 657
	{title = "Available tools:"} -- 658
) -- 658
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 661
	__TS__ArrayFilter( -- 662
		____exports.getToolPromptsForRole("main"), -- 662
		function(____, tool) return __TS__ArrayIndexOf( -- 663
			__TS__ArrayMap( -- 663
				____exports.getToolPromptsForRole("sub"), -- 663
				function(____, subTool) return subTool.name end -- 663
			), -- 663
			tool.name -- 663
		) < 0 end -- 663
	), -- 663
	{title = ""} -- 664
) -- 664
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 667
	__TS__ArrayFilter( -- 668
		____exports.AGENT_TOOL_PROMPTS, -- 668
		function(____, tool) return tool.name == "finish" end -- 668
	), -- 668
	{title = "", includeXmlRules = true} -- 669
) -- 669
function ____exports.canPreExecuteTool(tool) -- 672
	local prompt = getToolPrompt(tool) -- 673
	return (prompt and prompt.preExecutable) == true -- 674
end -- 672
function ____exports.canRunToolInParallel(tool) -- 677
	local prompt = getToolPrompt(tool) -- 678
	return (prompt and prompt.parallelSafe) == true -- 679
end -- 677
function ____exports.buildDecisionToolSchema(role, searchDoraDocLimitMax, options) -- 682
	local context = {searchDoraDocLimitMax = searchDoraDocLimitMax} -- 683
	return ____exports.buildDecisionToolSchemaForTools( -- 684
		getDecisionToolPromptsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 684
		context -- 688
	) -- 688
end -- 682
return ____exports -- 682