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
function resolveText(value, context) -- 54
	return type(value) == "string" and value or value(context) -- 55
end -- 55
function getToolDescription(tool, context) -- 58
	return resolveText(tool.description, context) -- 59
end -- 59
function getToolRules(tool, context) -- 62
	return __TS__ArrayMap( -- 63
		tool.rules or ({}), -- 63
		function(____, rule) return resolveText(rule, context) end -- 63
	) -- 63
end -- 63
function createFunctionToolSchemaFromDefinition(tool, context) -- 103
	local parameters = tool:inputSchema(context) -- 104
	local rules = getToolRules(tool, context) -- 105
	return { -- 106
		type = "function", -- 107
		["function"] = { -- 108
			name = tool.name, -- 109
			description = table.concat( -- 110
				{ -- 110
					getToolDescription(tool, context), -- 110
					table.unpack(rules) -- 110
				}, -- 110
				" " -- 110
			), -- 110
			parameters = parameters -- 111
		} -- 111
	} -- 111
end -- 111
function ____exports.getToolDefinition(name) -- 524
	for ____, tool in ipairs(____exports.AGENT_TOOL_DEFINITIONS) do -- 525
		if tool.name == name then -- 525
			return tool -- 526
		end -- 526
	end -- 526
	return nil -- 528
end -- 524
function ____exports.isKnownToolName(name) -- 568
	return ____exports.getToolDefinition(name) ~= nil -- 569
end -- 568
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 727
	return __TS__ArrayMap( -- 728
		tools, -- 728
		function(____, tool) return createFunctionToolSchemaFromDefinition(tool, context) end -- 729
	) -- 729
end -- 727
local DEFAULT_SCHEMA_CONTEXT = {searchDoraDocLimitMax = 20} -- 42
local DEFAULT_TOOL_OUTPUT_SCHEMA = {type = "object", properties = {success = {type = "boolean"}}, required = {"success"}} -- 46
local function getParameterDescription(parameter, context) -- 66
	return resolveText(parameter.description, context) -- 67
end -- 66
local function createInputSchemaFromParameters(parameters, context) -- 70
	local properties = {} -- 74
	local required = {} -- 75
	for ____, parameter in ipairs(parameters or ({})) do -- 76
		local property = { -- 77
			type = parameter.type, -- 78
			description = getParameterDescription(parameter, context) -- 79
		} -- 79
		if parameter.enum ~= nil then -- 79
			property.enum = parameter.enum -- 82
		end -- 82
		if parameter.items ~= nil then -- 82
			property.items = parameter.items -- 85
		end -- 85
		if parameter.minItems ~= nil then -- 85
			property.minItems = parameter.minItems -- 87
		end -- 87
		properties[parameter.name] = property -- 88
		if parameter.required == true then -- 88
			required[#required + 1] = parameter.name -- 90
		end -- 90
	end -- 90
	local schema = {type = "object", properties = properties} -- 93
	if #required > 0 then -- 93
		schema.required = required -- 98
	end -- 98
	return schema -- 100
end -- 70
local READ_FILE_PARAMETERS = {{name = "path", type = "string", description = "Single-read form: workspace-relative file path, the virtual @dora_full_logs.txt engine log, or an exact @dora-doc/... path returned by search_dora_doc."}, {name = "startLine", type = "number", description = "Single-read starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, {name = "endLine", type = "number", description = "Single-read ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}, { -- 116
	name = "reads", -- 121
	type = "array", -- 121
	minItems = 1, -- 121
	description = "Batch-read form: a non-empty ordered list of independent file ranges. There is no artificial item limit.", -- 122
	items = {type = "object", properties = {path = {type = "string", description = "Workspace or virtual path to read."}, startLine = {type = "number", description = "Starting line; defaults to 1."}, endLine = {type = "number", description = "Ending line; default follows startLine."}}, required = {"path"}, additionalProperties = false} -- 123
}} -- 123
local BUILD_PARAMETERS = {{ -- 136
	name = "paths", -- 137
	type = "array", -- 137
	minItems = 1, -- 137
	items = {type = "string"}, -- 137
	description = "Preferred form: a non-empty ordered list of files or directories to build sequentially. Use '.' for the project root. There is no artificial item limit." -- 137
}, {name = "path", type = "string", description = "Single-target compatibility form for existing sessions. New calls should prefer paths."}} -- 137
local AGENT_TOOL_DEFINITION_SOURCES = { -- 141
	{ -- 142
		name = "read_file", -- 143
		roles = {"main", "sub"}, -- 144
		workModes = {"code", "plan"}, -- 145
		description = "Read one file range or an ordered batch of independent file ranges from the workspace, built-in documents, or the virtual engine log.", -- 146
		parameters = READ_FILE_PARAMETERS, -- 147
		inputSchema = function(____, context) -- 148
			local generated = createInputSchemaFromParameters(READ_FILE_PARAMETERS, context) -- 149
			local properties = generated.properties -- 150
			local schema = {type = "object", properties = properties, additionalProperties = false, anyOf = {{required = {"path"}}, {required = {"reads"}}}} -- 151
			return schema -- 160
		end, -- 148
		rules = { -- 162
			"Use path/startLine/endLine for one range, reads for a batch, or combine both forms. When combined, the top-level path range is read first, followed by reads in array order.", -- 163
			"When several independent files or ranges are already known, either use reads or return multiple read_file tool calls in the same response.", -- 164
			"Batch ranges are independent and ordered. A failed read remains in results and does not discard successful reads.", -- 165
			"startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", -- 166
			"Read @dora_full_logs.txt to inspect the current Dora engine log snapshot; it is a read-only virtual path, not a workspace file.", -- 167
			"Paths returned by search_dora_doc are authoritative built-in documentation paths and can be read directly without modifying them." -- 168
		}, -- 168
		parallelSafe = true -- 170
	}, -- 170
	{ -- 172
		name = "edit_file", -- 173
		roles = {"main", "sub"}, -- 174
		workModes = {"code", "plan"}, -- 175
		description = "Make one file edit, or apply an ordered best-effort batch of file edits in one call. A batch may use a shared top-level path.", -- 176
		parameters = {{name = "path", type = "string", description = "Workspace-relative file path for the legacy single-edit form, or the default path for batch entries that omit path."}, {name = "old_str", type = "string", description = "Legacy single-edit form: existing text to replace. If empty, rewrite the whole file or create it when missing."}, {name = "new_str", type = "string", description = "Legacy single-edit form: replacement text or complete file content."}, { -- 177
			name = "edits", -- 182
			type = "array", -- 183
			minItems = 1, -- 184
			description = "Best-effort batch form: a non-empty array of ordered edit objects. May target multiple files or the same file repeatedly; a same-file edit sees the staged result of earlier successful entries.", -- 185
			items = {type = "object", properties = {path = {type = "string", description = "Workspace-relative file path to edit. May be omitted when the batch supplies a top-level default path."}, old_str = {type = "string", description = "Existing staged text to replace; empty rewrites or creates."}, new_str = {type = "string", description = "Replacement or complete file content."}}, required = {"old_str", "new_str"}, additionalProperties = false} -- 186
		}}, -- 186
		rules = { -- 198
			"Use path + old_str + new_str for one edit; edits for a batch with per-entry paths; or path + edits when all or some batch entries share a default path. Do not combine edits with top-level old_str/new_str.", -- 199
			"Prefer one batch when several independent files or several known replacements can be changed coherently before the next build.", -- 200
			"Each batch entry succeeds or fails independently. Failed entries are reported and skipped; all successful staged results are committed together in one checkpoint.", -- 201
			"Repeated paths are allowed and execute in array order against content from earlier successful entries; the final successful content for each unique path is written once.", -- 202
			"old_str and new_str MUST be different.", -- 203
			"old_str must match existing text exactly when it is non-empty.", -- 204
			"If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists.", -- 205
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build." -- 206
		} -- 206
	}, -- 206
	{ -- 209
		name = "delete_file", -- 210
		roles = {"main", "sub"}, -- 211
		workModes = {"code", "plan"}, -- 212
		description = "Remove a file.", -- 213
		parameters = {{name = "target_file", type = "string", required = true, description = "Workspace-relative file path to delete."}} -- 214
	}, -- 214
	{ -- 218
		name = "grep_files", -- 219
		roles = {"main", "sub"}, -- 220
		workModes = {"code", "plan"}, -- 221
		description = "Search text patterns inside files.", -- 222
		parameters = { -- 223
			{name = "path", type = "string", description = "Workspace directory, workspace file, or exact @dora-doc/... virtual document path to search within."}, -- 224
			{name = "pattern", type = "string", required = true, description = "Content pattern to search for. Use | to express OR alternatives."}, -- 225
			{name = "globs", type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 226
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 227
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 228
			{name = "limit", type = "number", description = "Maximum number of results to return."}, -- 229
			{name = "offset", type = "number", description = "Offset for paginating later result pages."}, -- 230
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 231
		}, -- 231
		rules = { -- 233
			"`path` may point to a workspace directory, workspace file, or an exact @dora-doc/... virtual document returned by search_dora_doc.", -- 234
			"This is content search (grep), not filename search.", -- 235
			"`pattern` matches file contents. `globs` only restrict which files are searched.", -- 236
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 237
			"`caseSensitive` defaults to false.", -- 238
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 239
			"Search results are intentionally capped. Refine the pattern or read a specific file next." -- 240
		}, -- 240
		parallelSafe = true -- 242
	}, -- 242
	{ -- 244
		name = "glob_files", -- 245
		roles = {"main", "sub"}, -- 246
		workModes = {"code", "plan"}, -- 247
		description = "Enumerate files under a directory.", -- 248
		parameters = {{name = "path", type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, {name = "globs", type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, {name = "maxEntries", type = "number", description = "Maximum number of entries to return."}}, -- 249
		rules = {"Use this to discover files by path, extension, or glob pattern.", "Directory listings are intentionally capped. Narrow the path before expanding further."}, -- 254
		parallelSafe = true -- 258
	}, -- 258
	{ -- 260
		name = "search_dora_doc", -- 261
		roles = {"main", "sub"}, -- 262
		workModes = {"code", "plan"}, -- 263
		description = "Search one authoritative Dora, LÖVE, or TIC-80 documentation set.", -- 264
		parameters = { -- 265
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 266
			{name = "docType", type = "string", enum = {"dora-tutorial", "dora-api", "love-api", "tic80-api"}, description = "Exact documentation set to search. Defaults to dora-api."}, -- 267
			{name = "programmingLanguage", type = "string", enum = { -- 268
				"ts", -- 268
				"tsx", -- 268
				"lua", -- 268
				"yue", -- 268
				"teal", -- 268
				"tl", -- 268
				"wa" -- 268
			}, description = "Preferred language variant to search."}, -- 268
			{ -- 269
				name = "limit", -- 269
				type = "number", -- 269
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraDocLimitMax)) .. "." end -- 269
			}, -- 269
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 270
		}, -- 270
		rules = { -- 272
			"`docType` defaults to `dora-api`; select `dora-tutorial`, `love-api`, or `tic80-api` explicitly when needed.", -- 273
			"Each type searches only its matching files: Dora tutorials, Dora API definitions excluding Love/TIC-80, love.d.*, or tic80.d.*.", -- 274
			"Every result file uses the @dora-doc/<docType>/... namespace; it is readable with read_file and searchable with grep_files using the exact virtual path.", -- 275
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 276
			"`useRegex` defaults to false whenever supported by a search tool.", -- 277
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraDocLimitMax)) .. "." end -- 278
		}, -- 278
		parallelSafe = true -- 280
	}, -- 280
	{ -- 282
		name = "build", -- 283
		roles = {"main", "sub"}, -- 284
		workModes = {"code"}, -- 285
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 286
		parameters = BUILD_PARAMETERS, -- 287
		inputSchema = function(____, context) -- 288
			local generated = createInputSchemaFromParameters(BUILD_PARAMETERS, context) -- 289
			local properties = generated.properties -- 290
			local schema = {type = "object", properties = properties, additionalProperties = false, anyOf = {{required = {"paths"}}, {required = {"path"}}}} -- 291
			return schema -- 300
		end, -- 288
		rules = { -- 302
			"Prefer paths for all new calls, including one target. Use paths: ['.'] to build the project root.", -- 303
			"The single path form remains accepted for existing sessions and may be combined with paths. When combined, path builds first, followed by paths in array order.", -- 304
			"Prefer one common directory target when edited files share a root; otherwise include the required targets in order.", -- 305
			"Targets build sequentially and best-effort. A failed target does not discard earlier successful results.", -- 306
			"Read the result and then decide whether another action is needed." -- 307
		} -- 307
	}, -- 307
	{ -- 310
		name = "fetch_url", -- 311
		roles = {"main", "sub"}, -- 312
		workModes = {"code"}, -- 313
		description = "Download a single HTTP or HTTPS resource into the project.", -- 314
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 315
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "Local, private, metadata, and literal-IP destinations are rejected. Downloads are limited to 32 MiB.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds."} -- 319
	}, -- 319
	{ -- 326
		name = "execute_command", -- 327
		roles = {"main", "sub"}, -- 328
		workModes = {"code"}, -- 329
		description = "Execute a controlled engine command.", -- 330
		parameters = { -- 331
			{ -- 332
				name = "mode", -- 332
				type = "string", -- 332
				required = true, -- 332
				enum = {"lua", "git"}, -- 332
				description = "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." -- 332
			}, -- 332
			{name = "code", type = "string", description = "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result."}, -- 333
			{name = "command", type = "string", description = "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported."}, -- 334
			{name = "cwd", type = "string", description = "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C."}, -- 335
			{name = "timeoutSeconds", type = "number", description = "Optional total command timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode also interrupts a command thread that occupies one game frame for 5 seconds, but cannot interrupt a blocking native call."} -- 336
		}, -- 336
		rules = { -- 338
			"This tool is available only when the user enables command execution for the current Agent task.", -- 339
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 340
			"Lua mode runs with a temporary environment whose global writes stay in that one command. DB, HttpClient, HttpServer, and Content write operations are unavailable. Content supports only project-relative exist, isdir, getAttr, and load operations.", -- 341
			"Lua command code is checked every 10,000 VM instructions against App.elapsedTime. A command thread that occupies one game frame for 5 seconds is interrupted; time spent yielded across frames does not accumulate toward this per-frame limit, and blocking native calls remain non-interruptible.", -- 342
			"Lua mode exposes projectDir, reportProgress(update), refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), and stopEntry(). reportProgress accepts a table with progress from 0 to 1 plus optional stage and message. getEntryStatus() returns a table containing success and running booleans.", -- 343
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 344
			"An Entry watchdog checks live Dora object and Lua-reference growth every frame and from the Lua instruction hook. Growth of 50,000 C++ objects or 10,000 Lua references stops the test, runs Entry cleanup, and returns the measured growth; replace such tests with bounded entities and fixed simulation steps.", -- 345
			"After a Lua command finishes, the Web IDE resource tree is refreshed automatically whenever the command accessed Content and did not call refreshTree itself, including commands that later fail, are canceled, or time out. Pure computation commands do not refresh the tree. refreshTree(\"relative/file\") or refreshTree() remains available for explicit updates.", -- 346
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 347
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.", -- 348
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 349
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.", -- 350
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten.", -- 351
			"Git clone rejects local, private, metadata, and literal-IP destinations and discards repositories larger than 128 MiB.", -- 352
			"The Web IDE resource tree is refreshed automatically after every successful Git command." -- 353
		} -- 353
	}, -- 353
	{ -- 356
		name = "finish", -- 357
		roles = {"sub"}, -- 358
		workModes = {"code", "plan"}, -- 359
		description = "Conclude a sub-agent task and provide a structured completion handoff to its parent.", -- 360
		parameters = { -- 361
			{name = "message", type = "string", required = true, description = "Concise handoff summary for the parent agent."}, -- 362
			{ -- 363
				name = "outcome", -- 363
				type = "string", -- 363
				required = true, -- 363
				enum = {"completed", "partial", "blocked"}, -- 363
				description = "Sub-agent work outcome." -- 363
			}, -- 363
			{name = "validation", type = "array", items = {type = "object", properties = {kind = {type = "string", enum = {"build", "runtime", "manual"}}, result = {type = "string", enum = {"passed", "failed", "not_run"}}, evidence = {type = "array", items = {type = "string"}}}, required = {"kind", "result"}}, description = "Validation performed. Sub agents must provide an array, using not_run when a relevant check was not run."}, -- 364
			{name = "knownIssues", type = "array", items = {type = "string"}, description = "Known remaining issues or blockers. Sub agents must provide an array, which may be empty."}, -- 375
			{name = "assumptions", type = "array", items = {type = "string"}, description = "Material assumptions made during the work. Sub agents must provide an array, which may be empty."}, -- 376
			{name = "learningCandidates", type = "array", items = {type = "object", properties = {claim = {type = "string"}, scope = {type = "string", enum = {"file", "project", "engine"}}, evidence = {type = "array", items = {type = "string"}}, confidence = {type = "string", enum = {"observed", "inferred"}}}, required = {"claim", "scope", "confidence"}}, description = "Durable, evidence-backed facts worth sharing with later agents. Sub agents must provide an array, which may be empty."} -- 377
		}, -- 377
		rules = {"Sub agents must explicitly report outcome, validation, knownIssues, assumptions, and learningCandidates.", "Do not claim validation passed without concrete evidence from the corresponding tool result.", "Use learningCandidates only for durable facts, constraints, or project conventions; omit generic progress narration."} -- 390
	}, -- 390
	{ -- 396
		name = "list_sub_agents", -- 397
		roles = {"main"}, -- 398
		workModes = {"code"}, -- 399
		description = "Query sub-agent state under the current main session.", -- 400
		parameters = {{name = "status", type = "string", enum = { -- 401
			"active_or_recent", -- 402
			"running", -- 402
			"done", -- 402
			"failed", -- 402
			"all" -- 402
		}, description = "Optional status filter. Defaults to active_or_recent."}, {name = "limit", type = "number", description = "Maximum number of items to return. Defaults to 5."}, {name = "offset", type = "number", description = "Offset for paging older items."}, {name = "query", type = "string", description = "Optional text filter matched against title, goal, or summary."}}, -- 402
		rules = { -- 407
			"Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.", -- 408
			"status defaults to active_or_recent and may also be running, done, failed, or all.", -- 409
			"limit defaults to a small recent window. Use offset to page older items.", -- 410
			"query filters by title, goal, or summary text.", -- 411
			"After any successful spawn_sub_agent in the current task, this tool is unavailable for the rest of that task. Finish the turn instead; completion arrives through an asynchronous handoff." -- 412
		}, -- 412
		parallelSafe = true -- 414
	}, -- 414
	{ -- 416
		name = "spawn_sub_agent", -- 417
		roles = {"main"}, -- 418
		workModes = {"code"}, -- 419
		description = "Create and start a sub agent session for delegated implementation work.", -- 420
		parameters = {{name = "title", type = "string", required = true, description = "Short tab title for the sub agent."}, {name = "prompt", type = "string", required = true, description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, {name = "expectedOutput", type = "string", description = "Optional expected result summary."}, {name = "filesHint", type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, -- 421
		rules = { -- 427
			"Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.", -- 428
			"For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.", -- 429
			"The spawned sub agent inherits the current session tool capabilities.", -- 430
			"title should be short and specific.", -- 431
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.", -- 432
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 433
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish the current turn and return control to the user while the sub agents keep running.", -- 434
			"After a successful spawn in the current task, do not call list_sub_agents, wait, join, or poll. Completion is delivered asynchronously as a later handoff.", -- 435
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit.", -- 436
			"filesHint is an optional list of likely files or directories." -- 437
		} -- 437
	}, -- 437
	{ -- 440
		name = "ask_user", -- 441
		roles = {"main"}, -- 442
		workModes = {"plan"}, -- 443
		description = "Present a structured questionnaire and pause the Plan task until the user submits every required answer.", -- 444
		parameters = {{name = "title", type = "string", required = true, description = "Short questionnaire title."}, {name = "description", type = "string", description = "Optional context shown above the questions."}, { -- 445
			name = "questions", -- 449
			type = "array", -- 450
			required = true, -- 451
			description = "One to eight questions. Use single_choice, multiple_choice, or text. A single-choice question may recommend at most one option.", -- 452
			items = {type = "object", properties = { -- 453
				id = {type = "string"}, -- 456
				prompt = {type = "string"}, -- 457
				description = {type = "string"}, -- 458
				type = {type = "string", enum = {"single_choice", "multiple_choice", "text"}}, -- 459
				required = {type = "boolean"}, -- 460
				options = {type = "array", items = {type = "object", properties = {id = {type = "string"}, label = {type = "string"}, description = {type = "string"}, recommended = {type = "boolean", description = "Mark an option as recommended. Use at most one for single_choice; multiple_choice may mark any recommended set."}}, required = {"id", "label"}}}, -- 461
				placeholder = {type = "string"} -- 474
			}, required = {"id", "prompt", "type"}} -- 474
		}}, -- 474
		rules = { -- 480
			"Inspect the project before asking; do not ask for facts available through read_file, grep_files, glob_files, or search_dora_doc.", -- 481
			"ask_user has no document-update prerequisite. Incorporate the answers into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish.", -- 482
			"For single_choice, mark at most one option recommended. For multiple_choice, recommended options form a suggested set.", -- 483
			"ask_user must be the only tool call in the response.", -- 484
			"The task pauses after the questionnaire is published and continues after the user submits answers or dismisses it.", -- 485
			"An answered or dismissed ask_user tool result contains authoritative user feedback. Apply answers when present; when dismissed, continue with reasonable assumptions and do not mechanically repeat the same questionnaire." -- 486
		} -- 486
	} -- 486
} -- 486
local function formatSchemaErrors(errors) -- 491
	return table.concat( -- 492
		__TS__ArrayMap( -- 492
			errors, -- 492
			function(____, item) return ((item.schemaPath ~= "" and item.schemaPath or "/") .. ": ") .. item.message end -- 492
		), -- 492
		"; " -- 492
	) -- 492
end -- 491
local function createToolDefinition(source) -- 495
	local definition = __TS__ObjectAssign( -- 496
		{}, -- 496
		source, -- 497
		{ -- 496
			inputSchema = source.inputSchema or (function(____, context) return createInputSchemaFromParameters(source.parameters, context) end), -- 498
			outputSchema = DEFAULT_TOOL_OUTPUT_SCHEMA, -- 499
			handler = AGENT_TOOL_HANDLERS[source.name], -- 500
			validateInput = AGENT_TOOL_VALIDATORS[source.name] -- 501
		} -- 501
	) -- 501
	local inputResult = compileJsonSchema(definition:inputSchema(DEFAULT_SCHEMA_CONTEXT)) -- 503
	if not inputResult.success then -- 503
		error( -- 505
			__TS__New( -- 505
				Error, -- 505
				(("Invalid input schema for " .. definition.name) .. ": ") .. formatSchemaErrors(inputResult.errors) -- 505
			), -- 505
			0 -- 505
		) -- 505
	end -- 505
	local outputResult = compileJsonSchema(definition.outputSchema) -- 507
	if not outputResult.success then -- 507
		error( -- 509
			__TS__New( -- 509
				Error, -- 509
				(("Invalid output schema for " .. definition.name) .. ": ") .. formatSchemaErrors(outputResult.errors) -- 509
			), -- 509
			0 -- 509
		) -- 509
	end -- 509
	return definition -- 511
end -- 495
____exports.AGENT_TOOL_DEFINITIONS = __TS__ArrayMap( -- 514
	AGENT_TOOL_DEFINITION_SOURCES, -- 514
	function(____, source) return createToolDefinition(source) end -- 514
) -- 514
local function hasRole(tool, role) -- 516
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 517
end -- 516
local function hasWorkMode(tool, workMode) -- 520
	return __TS__ArrayIndexOf(tool.workModes, workMode) >= 0 -- 521
end -- 520
local function isToolCapabilityEnabled(tool, options) -- 531
	if not ____exports.isKnownToolName(tool.name) then -- 531
		return false -- 532
	end -- 532
	return hasWorkMode(tool, options and options.workMode or "code") and __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 533
end -- 531
local function formatParameterList(tool) -- 537
	local parameters = tool.parameters or ({}) -- 538
	if #parameters == 0 then -- 538
		return "" -- 539
	end -- 539
	return table.concat( -- 540
		__TS__ArrayMap( -- 540
			parameters, -- 540
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 541
		), -- 541
		", " -- 542
	) -- 542
end -- 537
local function formatToolPrompt(tool, index, context) -- 545
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 546
	local parameterList = formatParameterList(tool) -- 547
	if parameterList ~= "" then -- 547
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 549
	end -- 549
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 551
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 552
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 553
	end -- 553
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 555
		lines[#lines + 1] = "\t- " .. rule -- 556
	end -- 556
	return table.concat(lines, "\n") -- 558
end -- 545
local function formatXMLRepairToolReference(tool) -- 561
	local parameterList = formatParameterList(tool) -- 562
	local params = parameterList ~= "" and parameterList or "none" -- 563
	local reason = tool.name == "finish" and "no reason tag" or "reason tag required" -- 564
	return (((("- " .. tool.name) .. ": params: ") .. params) .. "; ") .. reason -- 565
end -- 561
function ____exports.getAllowedToolsForRole(role, options) -- 572
	return __TS__ArrayMap( -- 573
		__TS__ArrayFilter( -- 573
			____exports.AGENT_TOOL_DEFINITIONS, -- 573
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 574
		), -- 574
		function(____, tool) return tool.name end -- 575
	) -- 575
end -- 572
function ____exports.buildCurrentToolAvailabilityGuidance() -- 578
	return table.concat({"Current tool availability:", "- every tool defined in the current system prompt or exposed in the current tool schema is executable", "- capabilities disabled for this task are omitted from both the definitions and schema"}, "\n") -- 579
end -- 578
function ____exports.getToolDefinitionsForRole(role, options) -- 586
	return __TS__ArrayFilter( -- 591
		____exports.AGENT_TOOL_DEFINITIONS, -- 591
		function(____, tool) return hasRole(tool, role) and ((options and options.includeFinish) == true or tool.name ~= "finish") and isToolCapabilityEnabled(tool, options) end -- 591
	) -- 591
end -- 586
local SUB_AGENT_REQUIRED_FINISH_PARAMS = { -- 598
	"message", -- 599
	"outcome", -- 600
	"validation", -- 601
	"knownIssues", -- 602
	"assumptions", -- 603
	"learningCandidates" -- 604
} -- 604
local function getDecisionToolDefinitionsForRole(role, options) -- 607
	local tools = ____exports.getToolDefinitionsForRole(role, options) -- 612
	if role ~= "sub" then -- 612
		return tools -- 613
	end -- 613
	return __TS__ArrayMap( -- 614
		tools, -- 614
		function(____, tool) -- 614
			if tool.name ~= "finish" then -- 614
				return tool -- 615
			end -- 615
			local parameters = __TS__ArrayMap( -- 616
				tool.parameters or ({}), -- 616
				function(____, parameter) return __TS__ObjectAssign( -- 616
					{}, -- 616
					parameter, -- 617
					{required = __TS__ArrayIndexOf(SUB_AGENT_REQUIRED_FINISH_PARAMS, parameter.name) >= 0} -- 616
				) end -- 616
			) -- 616
			return __TS__ObjectAssign( -- 620
				{}, -- 620
				tool, -- 621
				{ -- 620
					parameters = parameters, -- 622
					inputSchema = function(____, context) return createInputSchemaFromParameters(parameters, context) end -- 623
				} -- 623
			) -- 623
		end -- 614
	) -- 614
end -- 607
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 628
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 633
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 634
	local sections = __TS__ArrayMap( -- 635
		tools, -- 635
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 635
	) -- 635
	if (options and options.includeXmlRules) == true then -- 635
		local reasonTools = table.concat( -- 637
			__TS__ArrayMap( -- 637
				__TS__ArrayFilter( -- 637
					tools, -- 637
					function(____, tool) return tool.name ~= "finish" end -- 638
				), -- 638
				function(____, tool) return tool.name end -- 639
			), -- 639
			", " -- 640
		) -- 640
		sections[#sections + 1] = ("XML mode object fields:\n- Use a single root tag: <tool_call>.\n- For " .. (reasonTools ~= "" and reasonTools or "tools other than finish")) .. ", include <tool>, <reason>, and <params>.\n- For finish, omit <reason> and include <message> plus every other required parameter shown above inside <params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 641
	end -- 641
	local body = table.concat(sections, "\n\n") -- 647
	return title ~= "" and (title .. "\n") .. body or body -- 648
end -- 628
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 651
	return ____exports.buildToolDefinitionsDetailed( -- 659
		getDecisionToolDefinitionsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 660
		{title = options and options.title, includeXmlRules = options and options.includeXmlRules, context = options and options.context} -- 665
	) -- 665
end -- 651
function ____exports.buildXMLRepairToolReference(role, options) -- 673
	local tools = ____exports.getToolDefinitionsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}) -- 674
	local ____array_28 = __TS__SparseArrayNew( -- 674
		"Allowed tools and XML params:", -- 680
		table.unpack(__TS__ArrayMap( -- 681
			tools, -- 681
			function(____, tool) return formatXMLRepairToolReference(tool) end -- 681
		)) -- 681
	) -- 681
	__TS__SparseArrayPush( -- 681
		____array_28, -- 681
		"", -- 682
		"XML shape:", -- 683
		"- Wrap the decision in exactly one <tool_call> root.", -- 684
		"- For tools except finish: include <tool>, <reason>, and <params>.", -- 685
		"- For finish: include <tool>, omit <reason>, and include <message> plus every other required parameter shown above inside <params>.", -- 686
		"- Inside <params>, use one child tag per parameter name above." -- 687
	) -- 687
	local lines = {__TS__SparseArraySpread(____array_28)} -- 679
	return table.concat(lines, "\n") -- 689
end -- 673
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 692
	____exports.getToolDefinitionsForRole("sub"), -- 693
	{title = "Available tools:"} -- 694
) -- 694
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 697
	__TS__ArrayFilter( -- 698
		____exports.getToolDefinitionsForRole("main"), -- 698
		function(____, tool) return __TS__ArrayIndexOf( -- 699
			__TS__ArrayMap( -- 699
				____exports.getToolDefinitionsForRole("sub"), -- 699
				function(____, subTool) return subTool.name end -- 699
			), -- 699
			tool.name -- 699
		) < 0 end -- 699
	), -- 699
	{title = ""} -- 700
) -- 700
____exports.XML_TOOL_DEFINITIONS_DETAILED = "\n\n" .. ____exports.buildToolDefinitionsDetailed( -- 703
	__TS__ArrayFilter( -- 704
		____exports.AGENT_TOOL_DEFINITIONS, -- 704
		function(____, tool) return tool.name == "finish" end -- 704
	), -- 704
	{title = "", includeXmlRules = true} -- 705
) -- 705
function ____exports.canPreExecuteTool(tool) -- 708
	local definition = ____exports.getToolDefinition(tool) -- 709
	return (definition and definition.preExecutable) == true -- 710
end -- 708
function ____exports.canRunToolInParallel(tool) -- 713
	local definition = ____exports.getToolDefinition(tool) -- 714
	return (definition and definition.parallelSafe) == true -- 715
end -- 713
function ____exports.buildDecisionToolSchema(role, searchDoraDocLimitMax, options) -- 718
	local context = {searchDoraDocLimitMax = searchDoraDocLimitMax} -- 719
	return ____exports.buildDecisionToolSchemaForTools( -- 720
		getDecisionToolDefinitionsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 720
		context -- 724
	) -- 724
end -- 718
return ____exports -- 718