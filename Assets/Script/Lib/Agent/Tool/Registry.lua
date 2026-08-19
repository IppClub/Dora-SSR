-- [ts]: Registry.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local resolveText, getToolDescription, getToolRules, createFunctionToolSchemaFromDefinition -- 1
local ____JsonSchema = require("Agent.JsonSchema") -- 2
local compileJsonSchema = ____JsonSchema.compileJsonSchema -- 2
local ____Handlers = require("Agent.Tool.Handlers") -- 3
local AGENT_TOOL_HANDLERS = ____Handlers.AGENT_TOOL_HANDLERS -- 3
local ____Validation = require("Agent.Tool.Validation") -- 4
local AGENT_TOOL_VALIDATORS = ____Validation.AGENT_TOOL_VALIDATORS -- 4
function resolveText(value, context) -- 53
	return type(value) == "string" and value or value(context) -- 54
end -- 54
function getToolDescription(tool, context) -- 57
	return resolveText(tool.description, context) -- 58
end -- 58
function getToolRules(tool, context) -- 61
	return __TS__ArrayMap( -- 62
		tool.rules or ({}), -- 62
		function(____, rule) return resolveText(rule, context) end -- 62
	) -- 62
end -- 62
function createFunctionToolSchemaFromDefinition(tool, context) -- 102
	local parameters = tool:inputSchema(context) -- 103
	local rules = getToolRules(tool, context) -- 104
	return { -- 105
		type = "function", -- 106
		["function"] = { -- 107
			name = tool.name, -- 108
			description = table.concat( -- 109
				{ -- 109
					getToolDescription(tool, context), -- 109
					table.unpack(rules) -- 109
				}, -- 109
				" " -- 109
			), -- 109
			parameters = parameters -- 110
		} -- 110
	} -- 110
end -- 110
function ____exports.getToolDefinition(name) -- 484
	for ____, tool in ipairs(____exports.AGENT_TOOL_DEFINITIONS) do -- 485
		if tool.name == name then -- 485
			return tool -- 486
		end -- 486
	end -- 486
	return nil -- 488
end -- 484
function ____exports.isKnownToolName(name) -- 528
	return ____exports.getToolDefinition(name) ~= nil -- 529
end -- 528
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 687
	return __TS__ArrayMap( -- 688
		tools, -- 688
		function(____, tool) return createFunctionToolSchemaFromDefinition(tool, context) end -- 689
	) -- 689
end -- 687
local DEFAULT_SCHEMA_CONTEXT = {searchDoraDocLimitMax = 20} -- 41
local DEFAULT_TOOL_OUTPUT_SCHEMA = {type = "object", properties = {success = {type = "boolean"}}, required = {"success"}} -- 45
local function getParameterDescription(parameter, context) -- 65
	return resolveText(parameter.description, context) -- 66
end -- 65
local function createInputSchemaFromParameters(parameters, context) -- 69
	local properties = {} -- 73
	local required = {} -- 74
	for ____, parameter in ipairs(parameters or ({})) do -- 75
		local property = { -- 76
			type = parameter.type, -- 77
			description = getParameterDescription(parameter, context) -- 78
		} -- 78
		if parameter.enum ~= nil then -- 78
			property.enum = parameter.enum -- 81
		end -- 81
		if parameter.items ~= nil then -- 81
			property.items = parameter.items -- 84
		end -- 84
		if parameter.minItems ~= nil then -- 84
			property.minItems = parameter.minItems -- 86
		end -- 86
		properties[parameter.name] = property -- 87
		if parameter.required == true then -- 87
			required[#required + 1] = parameter.name -- 89
		end -- 89
	end -- 89
	local schema = {type = "object", properties = properties} -- 92
	if #required > 0 then -- 92
		schema.required = required -- 97
	end -- 97
	return schema -- 99
end -- 69
local AGENT_TOOL_DEFINITION_SOURCES = { -- 115
	{ -- 116
		name = "read_file", -- 117
		roles = {"main", "sub"}, -- 118
		workModes = {"code", "plan"}, -- 119
		description = "Read one or more independent file ranges in one call.", -- 120
		parameters = {{ -- 121
			name = "reads", -- 123
			type = "array", -- 123
			required = true, -- 123
			minItems = 1, -- 123
			description = "Non-empty independent file ranges. Use one item for a single read. No artificial item limit; keep ranges narrow enough to remain useful in context.", -- 124
			items = {type = "object", properties = {path = {type = "string", description = "Workspace or virtual path to read."}, startLine = {type = "number", description = "Starting line; defaults to 1."}, endLine = {type = "number", description = "Ending line; default follows startLine."}}, required = {"path"}, additionalProperties = false} -- 125
		}}, -- 125
		rules = { -- 136
			"Always use reads, including for a single range. When several known files or ranges are needed before the next decision, put them in the same array.", -- 137
			"Batch ranges are independent and ordered. A failed read remains in results and does not discard successful reads.", -- 138
			"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", -- 139
			"Read @dora_full_logs.txt to inspect the current Dora engine log snapshot; it is a read-only virtual path, not a workspace file.", -- 140
			"Paths returned by search_dora_doc are authoritative built-in documentation paths and can be read directly without modifying them." -- 141
		}, -- 141
		parallelSafe = true -- 143
	}, -- 143
	{ -- 145
		name = "edit_file", -- 146
		roles = {"main", "sub"}, -- 147
		workModes = {"code", "plan"}, -- 148
		description = "Make one file edit, or apply an ordered best-effort batch of file edits in one call. A batch may use a shared top-level path.", -- 149
		parameters = {{name = "path", type = "string", description = "Workspace-relative file path for the legacy single-edit form, or the default path for batch entries that omit path."}, {name = "old_str", type = "string", description = "Legacy single-edit form: existing text to replace. If empty, rewrite the whole file or create it when missing."}, {name = "new_str", type = "string", description = "Legacy single-edit form: replacement text or complete file content."}, { -- 150
			name = "edits", -- 155
			type = "array", -- 156
			minItems = 1, -- 157
			description = "Best-effort batch form: a non-empty array of ordered edit objects. May target multiple files or the same file repeatedly; a same-file edit sees the staged result of earlier successful entries.", -- 158
			items = {type = "object", properties = {path = {type = "string", description = "Workspace-relative file path to edit. May be omitted when the batch supplies a top-level default path."}, old_str = {type = "string", description = "Existing staged text to replace; empty rewrites or creates."}, new_str = {type = "string", description = "Replacement or complete file content."}}, required = {"old_str", "new_str"}, additionalProperties = false} -- 159
		}}, -- 159
		rules = { -- 171
			"Use path + old_str + new_str for one edit; edits for a batch with per-entry paths; or path + edits when all or some batch entries share a default path. Do not combine edits with top-level old_str/new_str.", -- 172
			"Prefer one batch when several independent files or several known replacements can be changed coherently before the next build.", -- 173
			"Each batch entry succeeds or fails independently. Failed entries are reported and skipped; all successful staged results are committed together in one checkpoint.", -- 174
			"Repeated paths are allowed and execute in array order against content from earlier successful entries; the final successful content for each unique path is written once.", -- 175
			"old_str and new_str MUST be different.", -- 176
			"old_str must match existing text exactly when it is non-empty.", -- 177
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.", -- 178
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build." -- 179
		} -- 179
	}, -- 179
	{ -- 182
		name = "delete_file", -- 183
		roles = {"main", "sub"}, -- 184
		workModes = {"code", "plan"}, -- 185
		description = "Remove a file.", -- 186
		parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}} -- 187
	}, -- 187
	{ -- 191
		name = "grep_files", -- 192
		roles = {"main", "sub"}, -- 193
		workModes = {"code", "plan"}, -- 194
		description = "Search text patterns inside files.", -- 195
		parameters = { -- 196
			{name = "path", type = "string", description = "Workspace directory, workspace file, or exact @dora-doc/... virtual document path to search within."}, -- 197
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 198
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 199
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 200
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 201
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 202
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 203
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 204
		}, -- 204
		rules = { -- 206
			"`path` may point to a workspace directory, workspace file, or an exact @dora-doc/... virtual document returned by search_dora_doc.", -- 207
			"This is content search (grep), not filename search.", -- 208
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 209
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 210
			"`caseSensitive` defaults to false.", -- 211
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 212
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 213
		}, -- 213
		parallelSafe = true -- 215
	}, -- 215
	{ -- 217
		name = "glob_files", -- 218
		roles = {"main", "sub"}, -- 219
		workModes = {"code", "plan"}, -- 220
		description = "Enumerate files under a directory.", -- 221
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 222
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 227
		parallelSafe = true -- 231
	}, -- 231
	{ -- 233
		name = "search_dora_doc", -- 234
		roles = {"main", "sub"}, -- 235
		workModes = {"code", "plan"}, -- 236
		description = "Search one authoritative Dora, LÖVE, or TIC-80 documentation set.", -- 237
		parameters = { -- 238
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 239
			{name = "docType", type = "string", enum = {"dora-tutorial", "dora-api", "love-api", "tic80-api"}, description = "Exact documentation set to search. Defaults to dora-api."}, -- 240
			{name = "programmingLanguage", type = "string", enum = { -- 241
				"ts", -- 241
				"tsx", -- 241
				"lua", -- 241
				"yue", -- 241
				"teal", -- 241
				"tl", -- 241
				"wa" -- 241
			}, description = "Preferred language variant to search."}, -- 241
			{ -- 242
				name = "limit", -- 242
				type = "number", -- 242
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraDocLimitMax)) .. "." end -- 242
			}, -- 242
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 243
		}, -- 243
		rules = { -- 245
			"`docType` defaults to `dora-api`; select `dora-tutorial`, `love-api`, or `tic80-api` explicitly when needed.", -- 246
			"Each type searches only its matching files: Dora tutorials, Dora API definitions excluding Love/TIC-80, love.d.*, or tic80.d.*.", -- 247
			"Every result file uses the @dora-doc/<docType>/... namespace; it is readable with read_file and searchable with grep_files using the exact virtual path.", -- 248
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 249
			"`useRegex` defaults to false whenever supported by a search tool.", -- 250
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraDocLimitMax)) .. "." end -- 251
		}, -- 251
		parallelSafe = true -- 253
	}, -- 253
	{ -- 255
		name = "build", -- 256
		roles = {"main", "sub"}, -- 257
		workModes = {"code"}, -- 258
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 259
		parameters = {{ -- 260
			name = "paths", -- 261
			type = "array", -- 261
			required = true, -- 261
			minItems = 1, -- 261
			items = {type = "string"}, -- 261
			description = "Independent files or directories to build sequentially in one call. Use one item for a single target and '.' for the project root." -- 261
		}}, -- 261
		rules = {"Always use paths, including for a single target. Use paths: ['.'] to build the project root.", "Prefer one directory target when edited files share a root. Otherwise put all targets in one paths array.", "Batch targets build sequentially and best-effort. A failed target does not discard earlier successful build results.", "Read the result and then decide whether another action is needed."} -- 263
	}, -- 263
	{ -- 270
		name = "fetch_url", -- 271
		roles = {"main", "sub"}, -- 272
		workModes = {"code"}, -- 273
		description = "Download a single HTTP or HTTPS resource into the project.", -- 274
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 275
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "Local, private, metadata, and literal-IP destinations are rejected. Downloads are limited to 32 MiB.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds."} -- 279
	}, -- 279
	{ -- 286
		name = "execute_command", -- 287
		roles = {"main", "sub"}, -- 288
		workModes = {"code"}, -- 289
		description = "Execute a controlled engine command.", -- 290
		parameters = { -- 291
			{ -- 292
				name = "mode", -- 292
				type = "string", -- 292
				required = true, -- 292
				enum = {"lua", "git"}, -- 292
				description = "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." -- 292
			}, -- 292
			{name = "code", type = "string", description = "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result."}, -- 293
			{name = "command", type = "string", description = "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported."}, -- 294
			{name = "cwd", type = "string", description = "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C."}, -- 295
			{name = "timeoutSeconds", type = "number", description = "Optional total command timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode also interrupts a command thread that occupies one game frame for 5 seconds, but cannot interrupt a blocking native call."} -- 296
		}, -- 296
		rules = { -- 298
			"This tool is available only when the user enables command execution for the current Agent task.", -- 299
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 300
			"Lua mode runs with a temporary environment whose global writes stay in that one command. DB, HttpClient, HttpServer, and Content write operations are unavailable. Content supports only project-relative exist, isdir, getAttr, and load operations.", -- 301
			"Lua command code is checked every 10,000 VM instructions against App.elapsedTime. A command thread that occupies one game frame for 5 seconds is interrupted; time spent yielded across frames does not accumulate toward this per-frame limit, and blocking native calls remain non-interruptible.", -- 302
			"Lua mode exposes projectDir, reportProgress(update), refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). reportProgress accepts a table with progress from 0 to 1 plus optional stage and message. getEntryStatus() returns a table containing success and running booleans.", -- 303
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 304
			"An Entry watchdog checks live Dora object and Lua-reference growth every frame and from the Lua instruction hook. Growth of 50,000 C++ objects or 10,000 Lua references stops the test, runs Entry cleanup, and returns the measured growth; replace such tests with bounded entities and fixed simulation steps.", -- 305
			"After a Lua command finishes, the Web IDE resource tree is refreshed automatically whenever the command accessed Content and did not call refreshTree itself, including commands that later fail, are canceled, or time out. Pure computation commands do not refresh the tree. refreshTree(\"relative/file\") or refreshTree() remains available for explicit updates.", -- 306
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 307
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.", -- 308
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 309
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.", -- 310
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten.", -- 311
			"Git clone rejects local, private, metadata, and literal-IP destinations and discards repositories larger than 128 MiB.", -- 312
			"The Web IDE resource tree is refreshed automatically after every successful Git command." -- 313
		} -- 313
	}, -- 313
	{ -- 316
		name = "finish", -- 317
		roles = {"sub"}, -- 318
		workModes = {"code", "plan"}, -- 319
		description = "Conclude a sub-agent task and provide a structured completion handoff to its parent.", -- 320
		parameters = { -- 321
			{name = "message", type = "string", required = true, description = "Concise handoff summary for the parent agent."}, -- 322
			{ -- 323
				name = "outcome", -- 323
				type = "string", -- 323
				required = true, -- 323
				enum = {"completed", "partial", "blocked"}, -- 323
				description = "Sub-agent work outcome." -- 323
			}, -- 323
			{name = "validation", type = "array", items = {type = "object", properties = {kind = {type = "string", enum = {"build", "runtime", "manual"}}, result = {type = "string", enum = {"passed", "failed", "not_run"}}, evidence = {type = "array", items = {type = "string"}}}, required = {"kind", "result"}}, description = "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."}, -- 324
			{name = "knownIssues", type = "array", items = {type = "string"}, description = "Known remaining issues or blockers. Sub agents must provide an array, which may be empty."}, -- 335
			{name = "assumptions", type = "array", items = {type = "string"}, description = "Material assumptions made during the work. Sub agents must provide an array, which may be empty."}, -- 336
			{name = "learningCandidates", type = "array", items = {type = "object", properties = {claim = {type = "string"}, scope = {type = "string", enum = {"file", "project", "engine"}}, evidence = {type = "array", items = {type = "string"}}, confidence = {type = "string", enum = {"observed", "inferred"}}}, required = {"claim", "scope", "confidence"}}, description = "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."} -- 337
		}, -- 337
		rules = {"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.", "Do not claim validation passed without concrete evidence from the corresponding tool result.", "Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration."} -- 350
	}, -- 350
	{ -- 356
		name = "list_sub_agents", -- 357
		roles = {"main"}, -- 358
		workModes = {"code"}, -- 359
		description = "Query sub-agent state under the current main session.", -- 360
		parameters = {{name = "status", type = "string", enum = { -- 361
			"active_or_recent", -- 362
			"running", -- 362
			"done", -- 362
			"failed", -- 362
			"all" -- 362
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 362
		rules = { -- 367
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 368
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 369
			"limit defaults to a small recent window. Use offset to page older items.", -- 370
			"query filters by title, goal, or summary text.", -- 371
			"After any successful spawn_sub_agent in the current task, this tool is unavailable for the rest of that task. Finish the turn instead; completion arrives through an asynchronous handoff." -- 372
		}, -- 372
		parallelSafe = true -- 374
	}, -- 374
	{ -- 376
		name = "spawn_sub_agent", -- 377
		roles = {"main"}, -- 378
		workModes = {"code"}, -- 379
		description = "Create and start a sub agent session for delegated implementation work.", -- 380
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 381
		rules = { -- 387
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 388
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 389
			"The spawned sub agent inherits the current session tool capabilities.", -- 390
			"title should be short and specific.", -- 391
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 392
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 393
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish the current turn and return control to the user while the sub agents keep running.", -- 394
			"After a successful spawn in the current task, do not call list_sub_agents, wait, join, or poll. Completion is delivered asynchronously as a later handoff.", -- 395
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.", -- 396
			"filesHint is an optional list of likely files or directories." -- 397
		} -- 397
	}, -- 397
	{ -- 400
		name = "ask_user", -- 401
		roles = {"main"}, -- 402
		workModes = {"plan"}, -- 403
		description = "Present a structured questionnaire and pause the Plan task until the user submits every required answer.", -- 404
		parameters = {{name = "title", type = "string", required = true, description = "Short questionnaire title."}, {name = "description", type = "string", description = "Optional context shown above the questions."}, { -- 405
			name = "questions", -- 409
			type = "array", -- 410
			required = true, -- 411
			description = "One to eight questions. Use single_choice, multiple_choice, or text. A single-choice question may recommend at most one option.", -- 412
			items = {type = "object", properties = { -- 413
				id = {type = "string"}, -- 416
				prompt = {type = "string"}, -- 417
				description = {type = "string"}, -- 418
				type = {type = "string", enum = {"single_choice", "multiple_choice", "text"}}, -- 419
				required = {type = "boolean"}, -- 420
				options = {type = "array", items = {type = "object", properties = {id = {type = "string"}, label = {type = "string"}, description = {type = "string"}, recommended = {type = "boolean", description = "Mark an option as recommended. Use at most one for single_choice; multiple_choice may mark any recommended set."}}, required = {"id", "label"}}}, -- 421
				placeholder = {type = "string"} -- 434
			}, required = {"id", "prompt", "type"}} -- 434
		}}, -- 434
		rules = { -- 440
			"Inspect the project before asking; do not ask for facts available through read_file, grep_files, glob_files, or search_dora_doc.", -- 441
			"ask_user has no document-update prerequisite. Incorporate the answers into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish.", -- 442
			"For single_choice, mark at most one option recommended. For multiple_choice, recommended options form a suggested set.", -- 443
			"ask_user must be the only tool call in the response.", -- 444
			"The task pauses after the questionnaire is published and continues after the user submits answers or dismisses it.", -- 445
			"An answered or dismissed ask_user tool result contains authoritative user feedback. Apply answers when present; when dismissed, continue with reasonable assumptions and do not mechanically repeat the same questionnaire." -- 446
		} -- 446
	} -- 446
} -- 446
local function formatSchemaErrors(errors) -- 451
	return table.concat( -- 452
		__TS__ArrayMap( -- 452
			errors, -- 452
			function(____, item) return ((item.schemaPath ~= "" and item.schemaPath or "/") .. ": ") .. item.message end -- 452
		), -- 452
		"; " -- 452
	) -- 452
end -- 451
local function createToolDefinition(source) -- 455
	local definition = __TS__ObjectAssign( -- 456
		{}, -- 456
		source, -- 457
		{ -- 456
			inputSchema = function(____, context) return createInputSchemaFromParameters(source.parameters, context) end, -- 458
			outputSchema = DEFAULT_TOOL_OUTPUT_SCHEMA, -- 459
			handler = AGENT_TOOL_HANDLERS[source.name], -- 460
			validateInput = AGENT_TOOL_VALIDATORS[source.name] -- 461
		} -- 461
	) -- 461
	local inputResult = compileJsonSchema(definition:inputSchema(DEFAULT_SCHEMA_CONTEXT)) -- 463
	if not inputResult.success then -- 463
		error( -- 465
			__TS__New( -- 465
				Error, -- 465
				(("Invalid input schema for " .. definition.name) .. ": ") .. formatSchemaErrors(inputResult.errors) -- 465
			), -- 465
			0 -- 465
		) -- 465
	end -- 465
	local outputResult = compileJsonSchema(definition.outputSchema) -- 467
	if not outputResult.success then -- 467
		error( -- 469
			__TS__New( -- 469
				Error, -- 469
				(("Invalid output schema for " .. definition.name) .. ": ") .. formatSchemaErrors(outputResult.errors) -- 469
			), -- 469
			0 -- 469
		) -- 469
	end -- 469
	return definition -- 471
end -- 455
____exports.AGENT_TOOL_DEFINITIONS = __TS__ArrayMap( -- 474
	AGENT_TOOL_DEFINITION_SOURCES, -- 474
	function(____, source) return createToolDefinition(source) end -- 474
) -- 474
local function hasRole(tool, role) -- 476
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 477
end -- 476
local function hasWorkMode(tool, workMode) -- 480
	return __TS__ArrayIndexOf(tool.workModes, workMode) >= 0 -- 481
end -- 480
local function isToolCapabilityEnabled(tool, options) -- 491
	if not ____exports.isKnownToolName(tool.name) then -- 491
		return false -- 492
	end -- 492
	return hasWorkMode(tool, options and options.workMode or "code") and __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 493
end -- 491
local function formatParameterList(tool) -- 497
	local parameters = tool.parameters or ({}) -- 498
	if #parameters == 0 then -- 498
		return "" -- 499
	end -- 499
	return table.concat( -- 500
		__TS__ArrayMap( -- 500
			parameters, -- 500
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 501
		), -- 501
		", " -- 502
	) -- 502
end -- 497
local function formatToolPrompt(tool, index, context) -- 505
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 506
	local parameterList = formatParameterList(tool) -- 507
	if parameterList ~= "" then -- 507
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 509
	end -- 509
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 511
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 512
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 513
	end -- 513
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 515
		lines[#lines + 1] = "\t- " .. rule -- 516
	end -- 516
	return table.concat(lines, "\n") -- 518
end -- 505
local function formatXMLRepairToolReference(tool) -- 521
	local parameterList = formatParameterList(tool) -- 522
	local params = parameterList ~= "" and parameterList or "none" -- 523
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 524
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 525
end -- 521
function ____exports.getAllowedToolsForRole(role, options) -- 532
	return __TS__ArrayMap( -- 533
		__TS__ArrayFilter( -- 533
			____exports.AGENT_TOOL_DEFINITIONS, -- 533
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 534
		), -- 534
		function(____, tool) return tool.name end -- 535
	) -- 535
end -- 532
function ____exports.buildCurrentToolAvailabilityGuidance() -- 538
	return table.concat({"Current tool availability:", "- every tool defined in the current system prompt or exposed in the current tool schema is executable", "- capabilities disabled for this task are omitted from both the definitions and schema"}, "\n") -- 539
end -- 538
function ____exports.getToolDefinitionsForRole(role, options) -- 546
	return __TS__ArrayFilter( -- 551
		____exports.AGENT_TOOL_DEFINITIONS, -- 551
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 551
	) -- 551
end -- 546
local SUB_AGENT_REQUIRED_FINISH_PARAMS = { -- 558
	"message", -- 559
	"outcome", -- 560
	"validation", -- 561
	"knownIssues", -- 562
	"assumptions", -- 563
	"learningCandidates" -- 564
} -- 564
local function getDecisionToolDefinitionsForRole(role, options) -- 567
	local tools = ____exports.getToolDefinitionsForRole(role, options) -- 572
	if role ~= "sub" then -- 572
		return tools -- 573
	end -- 573
	return __TS__ArrayMap( -- 574
		tools, -- 574
		function(____, tool) -- 574
			if tool.name ~= "finish" then -- 574
				return tool -- 575
			end -- 575
			local parameters = __TS__ArrayMap( -- 576
				tool.parameters or ({}), -- 576
				function(____, parameter) return __TS__ObjectAssign( -- 576
					{}, -- 576
					parameter, -- 577
					{required = __TS__ArrayIndexOf(SUB_AGENT_REQUIRED_FINISH_PARAMS, parameter.name) >= 0} -- 576
				) end -- 576
			) -- 576
			return __TS__ObjectAssign( -- 580
				{}, -- 580
				tool, -- 581
				{ -- 580
					parameters = parameters, -- 582
					inputSchema = function(____, context) return createInputSchemaFromParameters(parameters, context) end -- 583
				} -- 583
			) -- 583
		end -- 574
	) -- 574
end -- 567
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
		getDecisionToolDefinitionsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 620
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 625
	) -- 625
end -- 611
function ____exports.buildXMLRepairToolReference(role, options) -- 633
	local tools = ____exports.getToolDefinitionsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}) -- 634
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
	____exports.getToolDefinitionsForRole("sub"), -- 653
	{title = "Available tools:"} -- 654
) -- 654
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 657
	__TS__ArrayFilter( -- 658
		____exports.getToolDefinitionsForRole("main"), -- 658
		function(____, tool) return __TS__ArrayIndexOf( -- 659
			__TS__ArrayMap( -- 659
				____exports.getToolDefinitionsForRole("sub"), -- 659
				function(____, subTool) return subTool.name end -- 659
			), -- 659
			tool.name -- 659
		) < 0 end -- 659
	), -- 659
	{title = ""} -- 660
) -- 660
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 663
	__TS__ArrayFilter( -- 664
		____exports.AGENT_TOOL_DEFINITIONS, -- 664
		function(____, tool) return tool.name == "finish" end -- 664
	), -- 664
	{title = "", includeXmlRules = true} -- 665
) -- 665
function ____exports.canPreExecuteTool(tool) -- 668
	local definition = ____exports.getToolDefinition(tool) -- 669
	return (definition and definition.preExecutable) == true -- 670
end -- 668
function ____exports.canRunToolInParallel(tool) -- 673
	local definition = ____exports.getToolDefinition(tool) -- 674
	return (definition and definition.parallelSafe) == true -- 675
end -- 673
function ____exports.buildDecisionToolSchema(role, searchDoraDocLimitMax, options) -- 678
	local context = {searchDoraDocLimitMax = searchDoraDocLimitMax} -- 679
	return ____exports.buildDecisionToolSchemaForTools( -- 680
		getDecisionToolDefinitionsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 680
		context -- 684
	) -- 684
end -- 678
return ____exports -- 678