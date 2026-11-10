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
local ____exports = {} -- 1
local resolveText, getToolDescription, getToolRules, createFunctionToolSchemaFromDefinition -- 1
local ____JsonSchema = require("Agent.Tool.JsonSchema") -- 2
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
	local parameters = (tool.modelInputSchema or tool.inputSchema)(nil, context) -- 103
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
function ____exports.getToolDefinition(name) -- 459
	for ____, tool in ipairs(____exports.AGENT_TOOL_DEFINITIONS) do -- 460
		if tool.name == name then -- 460
			return tool -- 461
		end -- 461
	end -- 461
	return nil -- 463
end -- 459
function ____exports.isKnownToolName(name) -- 496
	return ____exports.getToolDefinition(name) ~= nil -- 497
end -- 496
function ____exports.buildDecisionToolSchemaForTools(tools, context) -- 594
	return __TS__ArrayMap( -- 595
		tools, -- 595
		function(____, tool) return createFunctionToolSchemaFromDefinition(tool, context) end -- 596
	) -- 596
end -- 594
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
local READ_FILE_PARAMETERS = {{ -- 115
	name = "reads", -- 117
	type = "array", -- 117
	required = true, -- 117
	minItems = 1, -- 117
	description = "A required non-empty ordered list of file ranges. For one file, supply a one-element array. There is no artificial item limit.", -- 118
	items = {type = "object", properties = {path = {type = "string", description = "Workspace or virtual path to read."}, startLine = {type = "number", description = "Starting line; defaults to 1."}, endLine = {type = "number", description = "Inclusive ending line. If omitted, read at most 300 lines from the resolved startLine, capped at EOF."}}, required = {"path"}, additionalProperties = false} -- 119
}} -- 119
local BUILD_PARAMETERS = {{ -- 132
	name = "paths", -- 133
	type = "array", -- 133
	required = true, -- 133
	minItems = 1, -- 133
	items = {type = "string"}, -- 133
	description = "A required non-empty ordered list of files or directories to build sequentially. Use '.' for the project root, including when building one target. There is no artificial item limit." -- 133
}} -- 133
local AGENT_TOOL_DEFINITION_SOURCES = { -- 136
	{ -- 137
		name = "read_file", -- 138
		roles = {"main", "sub"}, -- 139
		workModes = {"code", "plan"}, -- 140
		description = "Read one file range or an ordered batch of independent file ranges from the workspace, built-in documents, or the virtual engine log.", -- 141
		parameters = READ_FILE_PARAMETERS, -- 142
		modelInputSchema = function(____, context) return __TS__ObjectAssign( -- 143
			{}, -- 143
			createInputSchemaFromParameters(READ_FILE_PARAMETERS, context), -- 144
			{additionalProperties = false} -- 143
		) end, -- 143
		inputSchema = function(____, context) return { -- 149
			type = "object", -- 150
			properties = __TS__ObjectAssign( -- 151
				{}, -- 151
				createInputSchemaFromParameters(READ_FILE_PARAMETERS, context).properties, -- 152
				{path = {type = "string"}, startLine = {type = "number"}, endLine = {type = "number"}} -- 151
			), -- 151
			anyOf = {{required = {"path"}}, {required = {"reads"}}}, -- 157
			additionalProperties = false -- 158
		} end, -- 158
		rules = { -- 160
			"Always supply reads as a non-empty array. Each entry contains path and optional startLine/endLine. For example: {\"reads\":[{\"path\":\"init.ts\"}]}.", -- 161
			"Put independent files or ranges in the same reads array, in the order their results are needed.", -- 162
			"Batch ranges are independent and ordered. A failed read remains in results and does not discard successful reads.", -- 163
			"startLine defaults to 1. If endLine is omitted, read at most 300 lines from the resolved starting line (start + 299), capped at EOF. Negative indices count backward from EOF; explicit endLine=-1 reads through EOF. Line 0 is invalid.", -- 164
			"Read @dora_full_logs.txt to inspect the current Dora engine log snapshot; it is a read-only virtual path, not a workspace file.", -- 165
			"Image paths (.png/.jpg/.jpeg) are read as pictures: image-capable models see the image inline; text-only models receive metadata (path, size) only. Use this to inspect screenshots from previewGame or any project image.", -- 166
			"Paths returned by search_dora_doc are authoritative built-in documentation paths and can be read directly without modifying them." -- 167
		}, -- 167
		parallelSafe = true -- 169
	}, -- 169
	{ -- 171
		name = "edit_file", -- 172
		roles = {"main", "sub"}, -- 173
		workModes = {"code", "plan"}, -- 174
		description = "Make targeted edits with old_str anchors, apply an ordered best-effort batch of edits, or delete a file. Whole-file creation/rewrite belongs to write_file.", -- 175
		parameters = { -- 176
			{name = "path", type = "string", description = "Workspace-relative file path for the legacy single-edit form or delete, or the default path for batch entries that omit path."}, -- 177
			{name = "old_str", type = "string", description = "Legacy single-edit form: existing text to replace. If empty, rewrite the whole file or create it when missing."}, -- 178
			{name = "new_str", type = "string", description = "Legacy single-edit form: replacement text or complete file content."}, -- 179
			{ -- 180
				name = "edits", -- 181
				type = "array", -- 182
				minItems = 1, -- 183
				description = "Best-effort batch form: a non-empty array of ordered edit objects. May target multiple files or the same file repeatedly; a same-file edit sees the staged result of earlier successful entries.", -- 184
				items = {type = "object", properties = {path = {type = "string", description = "Workspace-relative file path to edit. May be omitted when the batch supplies a top-level default path."}, old_str = {type = "string", description = "Existing staged text to replace; empty rewrites or creates."}, new_str = {type = "string", description = "Replacement or complete file content."}}, required = {"old_str", "new_str"}, additionalProperties = false} -- 185
			}, -- 185
			{name = "delete", type = "boolean", description = "Set true to delete the file at `path`. Cannot be combined with old_str, new_str, or edits. Only single files; directories are rejected. Deletions create a checkpoint like any edit."} -- 196
		}, -- 196
		rules = { -- 198
			"Use path + old_str + new_str for one targeted edit; edits for a batch; or path + delete=true to remove one file. old_str must be a non-empty exact anchor; use write_file to create or rewrite whole files.", -- 199
			"Prefer one batch when several independent files or several known replacements can be changed coherently before the next build.", -- 200
			"Each batch entry succeeds or fails independently. Failed entries are reported and skipped; all successful staged results are committed together in one checkpoint.", -- 201
			"Repeated paths are allowed and execute in array order against content from earlier successful entries; the final successful content for each unique path is written once.", -- 202
			"old_str and new_str MUST be different.", -- 203
			"old_str must match existing text exactly when it is non-empty.", -- 204
			"Deletion is an explicit, separate call with delete=true and a path; a capped or missing listing never implies deletion, and directories cannot be deleted.", -- 205
			"Files under .agent/main are writable persistent memory for deliberate proactive updates. Record only durable project knowledge, user decisions, or a precise active checkpoint; these memory-only edits do not require a project build." -- 206
		} -- 206
	}, -- 206
	{ -- 209
		name = "write_file", -- 210
		roles = {"main", "sub"}, -- 211
		workModes = {"code", "plan"}, -- 212
		description = "Create a file or overwrite it with complete new content.", -- 213
		parameters = {{name = "path", type = "string", required = true, description = "Workspace-relative file path to create or overwrite."}, {name = "new_str", type = "string", required = true, description = "Complete file content. The file is replaced or created with exactly this content."}}, -- 214
		rules = {"Use this to create new files or rewrite a file completely.", "For targeted changes inside an existing file, prefer edit_file with an old_str anchor instead of rewriting the whole file.", "Each write creates a checkpoint like any edit."}, -- 218
		parallelSafe = false -- 223
	}, -- 223
	{ -- 225
		name = "grep_files", -- 226
		roles = {"main", "sub"}, -- 227
		workModes = {"code", "plan"}, -- 228
		description = "Search text patterns inside files, or enumerate files by name when pattern is omitted.", -- 229
		parameters = { -- 230
			{name = "path", type = "string", description = "Workspace directory, workspace file, or exact @dora-doc/... virtual document path to search within."}, -- 231
			{name = "pattern", type = "string", description = "Content pattern to search for. Omit it to enumerate matching files by `globs` under `path` instead of searching content."}, -- 232
			{name = "globs", type = "array", items = {type = "string"}, description = "File glob filters. With `pattern` they restrict which files are searched; without `pattern` they select which files are listed."}, -- 233
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."}, -- 234
			{name = "caseSensitive", type = "boolean", description = "Set true for case-sensitive matching."}, -- 235
			{name = "limit", type = "number", description = "Maximum number of content matches to return."}, -- 236
			{name = "offset", type = "number", description = "Offset for paginating result pages."}, -- 237
			{name = "groupByFile", type = "boolean", description = "Set true to rank candidate files before drilling into one file."}, -- 238
			{name = "maxEntries", type = "number", description = "Maximum number of entries when enumerating files without `pattern`."} -- 239
		}, -- 239
		rules = { -- 241
			"`path` may point to a workspace directory, workspace file, or an exact @dora-doc/... virtual document returned by search_dora_doc.", -- 242
			"With `pattern` this is content search (grep): `pattern` matches file contents and `globs` only restrict which files are searched.", -- 243
			"Without `pattern` this enumerates files by path, extension, or glob pattern; every matching file is returned even when files share a basename with different extensions, such as town.tsx, town.tmx, and town.png.", -- 244
			"A capped, truncated, or non-exact listing does not prove that a file is absent. Before reporting a missing file, use an exact glob for its path or extension and confirm the result is not truncated.", -- 245
			"`useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.", -- 246
			"`caseSensitive` defaults to false.", -- 247
			"Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.", -- 248
			"Search results and directory listings are intentionally capped. Refine the pattern, narrow the path, or read a specific file next." -- 249
		}, -- 249
		parallelSafe = true -- 251
	}, -- 251
	{ -- 253
		name = "search_dora_doc", -- 254
		roles = {"main", "sub"}, -- 255
		workModes = {"code", "plan"}, -- 256
		description = "Search one authoritative Dora, LÖVE, or TIC-80 documentation set.", -- 257
		parameters = { -- 258
			{name = "pattern", type = "string", required = true, description = "Query string to search for. Use | to express OR alternatives."}, -- 259
			{name = "docType", type = "string", enum = {"dora-tutorial", "dora-api", "love-api", "tic80-api"}, description = "Exact documentation set to search. Defaults to dora-api."}, -- 260
			{name = "programmingLanguage", type = "string", enum = { -- 261
				"ts", -- 261
				"tsx", -- 261
				"lua", -- 261
				"yue", -- 261
				"teal", -- 261
				"tl", -- 261
				"wa" -- 261
			}, description = "Preferred language variant to search."}, -- 261
			{ -- 262
				name = "limit", -- 262
				type = "number", -- 262
				description = function(context) return ("Maximum number of matches to return, up to " .. tostring(context.searchDoraDocLimitMax)) .. "." end -- 262
			}, -- 262
			{name = "useRegex", type = "boolean", description = "Set true when pattern is a regular expression."} -- 263
		}, -- 263
		rules = { -- 265
			"`docType` defaults to `dora-api`; select `dora-tutorial`, `love-api`, or `tic80-api` explicitly when needed.", -- 266
			"Each type searches only its matching files: Dora tutorials, Dora API definitions excluding Love/TIC-80, love.d.*, or tic80.d.*.", -- 267
			"Every result file uses the @dora-doc/<docType>/... namespace; it is readable with read_file and searchable with grep_files using the exact virtual path.", -- 268
			"Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.", -- 269
			"`useRegex` defaults to false whenever supported by a search tool.", -- 270
			function(context) return ("`limit` restricts each individual pattern search and must be <= " .. tostring(context.searchDoraDocLimitMax)) .. "." end -- 271
		}, -- 271
		parallelSafe = true -- 273
	}, -- 273
	{ -- 275
		name = "build", -- 276
		roles = {"main", "sub"}, -- 277
		workModes = {"code"}, -- 278
		description = "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn.", -- 279
		parameters = BUILD_PARAMETERS, -- 280
		modelInputSchema = function(____, context) return __TS__ObjectAssign( -- 281
			{}, -- 281
			createInputSchemaFromParameters(BUILD_PARAMETERS, context), -- 282
			{additionalProperties = false} -- 281
		) end, -- 281
		inputSchema = function(____, context) return { -- 286
			type = "object", -- 287
			properties = __TS__ObjectAssign( -- 288
				{}, -- 288
				createInputSchemaFromParameters(BUILD_PARAMETERS, context).properties, -- 289
				{path = {type = "string"}} -- 288
			), -- 288
			anyOf = {{required = {"path"}}, {required = {"paths"}}}, -- 292
			additionalProperties = false -- 293
		} end, -- 293
		rules = {"Always supply paths as a non-empty array, including one target. Use {\"paths\":[\".\"]} to build the project root.", "Prefer one common directory target when edited files share a root; otherwise include the required targets in order.", "Targets build sequentially and best-effort. A failed target does not discard earlier successful results.", "Read the result and then decide whether another action is needed."} -- 295
	}, -- 295
	{ -- 302
		name = "fetch_url", -- 303
		roles = {"main", "sub"}, -- 304
		workModes = {"code"}, -- 305
		description = "Download a single HTTP or HTTPS resource into the project.", -- 306
		parameters = {{name = "url", type = "string", required = true, description = "HTTP or HTTPS URL to download. Other schemes are rejected."}, {name = "target", type = "string", required = true, description = "Workspace-relative target file path. The target must not already exist."}}, -- 307
		rules = {"This tool is available only when the user enables fetch_url for the current Agent task.", "Targets must stay inside the current project and existing files or directories are not overwritten.", "Local, private, metadata, and literal-IP destinations are rejected. Downloads are limited to 32 MiB.", "This tool writes to a temporary file first, then moves it into place only after the GET succeeds."} -- 311
	}, -- 311
	{ -- 318
		name = "execute_command", -- 319
		roles = {"main", "sub"}, -- 320
		workModes = {"code"}, -- 321
		description = "Execute a controlled engine command.", -- 322
		parameters = { -- 323
			{ -- 324
				name = "mode", -- 324
				type = "string", -- 324
				required = true, -- 324
				enum = {"lua", "git"}, -- 324
				description = "Use lua for a short Lua snippet inside the Dora engine, or git for a supported Git command handled by the engine Git client." -- 324
			}, -- 324
			{name = "code", type = "string", description = "Raw Lua code to execute when mode is lua. YueScript is not supported. Use print(...) for output that should appear in the tool result."}, -- 325
			{name = "command", type = "string", description = "Git command to execute when mode is git. The command may start with git, but shell syntax, pipes, redirects, and git -C are not supported."}, -- 326
			{name = "cwd", type = "string", description = "Optional project-relative directory for non-clone git commands. Defaults to the project root. Use this for Git operations inside a cloned sub-repository instead of git -C."}, -- 327
			{name = "timeoutSeconds", type = "number", description = "Optional total command timeout. Defaults to 30 seconds for Lua and 600 seconds for Git. Lua mode also interrupts a command thread that occupies one game frame for 5 seconds, but cannot interrupt a blocking native call."} -- 328
		}, -- 328
		rules = { -- 330
			"This tool is available only when the user enables command execution for the current Agent task.", -- 331
			"Lua mode accepts raw Lua code only; do not send YueScript syntax.", -- 332
			"Lua mode runs with a temporary environment whose global writes stay in that one command. DB, HttpClient, and HttpServer are unavailable. Content exposes all engine methods through a project-scoped facade, including writes and async operations. All filesystem path arguments must be project-relative, without '..' or absolute paths; both source and destination are checked for copy/move/ZIP operations. Use Content:getDirs('.') for the project root. Colon and dot calls are supported. Text load/loadAsync retain readable-file checks. @dora-doc/..., @agent-skill/..., and @dora_full_logs.txt keep their read-only virtual meanings; they cannot be written, moved, or used as root/search directories. Virtual document reads use the task documentation language, and virtual search results retain their virtual file identifiers. assetPath, writablePath, and appPath initially return '.', and appPath is read-only. assetPath, writablePath, and searchPaths can be configured with project-relative directories for this command only; they never change the engine singleton. Relative reads use these local search paths and assetPath, while writes use local writablePath. clearPathCache is local and isAbsolutePath only inspects the supplied string.", -- 333
			"Lua command code is checked every 10,000 VM instructions against App.elapsedTime. A command thread that occupies one game frame for 5 seconds is interrupted; time spent yielded across frames does not accumulate toward this per-frame limit, and blocking native calls remain non-interruptible.", -- 334
			"Lua mode exposes projectDir, reportProgress(update), refreshTree(path?), getEntryStatus(), enterEntryAsync(entry), stopEntry(), and previewGame(opts). reportProgress accepts a table with progress from 0 to 1 plus optional stage and message. getEntryStatus() returns a table containing success and running booleans.", -- 335
			"Use previewGame only when the user asks for visual review or a visible result cannot be validated from source and deterministic runtime checks. Do not capture for documentation, refactoring, build-only, data-only, or nonvisual logic tasks. Normally capture once; a visual task may capture a baseline and one final comparison after batching edits. The hard task limit is 3 batches and 6 frames, with the third batch reserved for a failed attempt or high-confidence blocker. previewGame({entry = \"init.ts\", captureAtSeconds = {0.5, 2}}) accepts a built project-relative Lua, TypeScript, TSX, YueScript, Teal, or XML entry and resolves its generated Lua. captureAtSeconds must contain 1–3 strictly increasing values from 0 through 10. It runs the entry exclusively, saves PNG files under .agent/vision, and returns {success, message, files, frames, visionBudget}. A failed result is automatically reported as an execute_command failure, so read its message and correct the arguments instead of repeating them. Give the command timeoutSeconds at least 50. Do not mix previewGame with enterEntryAsync in the same command; pass returned paths to analyze_image.", -- 335
			"enterEntryAsync runs a built project-relative Lua entry as an isolated Agent test. The tool automatically stops an entry it started when the command succeeds, fails, is canceled, or times out.", -- 336
			"An Entry watchdog checks live Dora object and Lua-reference growth every frame and from the Lua instruction hook. Growth of 50,000 C++ objects or 10,000 Lua references stops the test, runs Entry cleanup, and returns the measured growth; replace such tests with bounded entities and fixed simulation steps.", -- 337
			"After a Lua command finishes, the Web IDE resource tree is refreshed automatically whenever the command accessed Content and did not call refreshTree itself, including commands that later fail, are canceled, or time out. Pure computation commands do not refresh the tree. refreshTree(\"relative/file\") or refreshTree() remains available for explicit updates.", -- 338
			"Lua mode returns only text printed with print(...). It does not return arbitrary Lua return values.", -- 339
			"Only one Agent command may own the Dora entry runtime at a time. If it is busy, retry later instead of waiting inside the command.", -- 340
			"Git mode uses the engine Git client, not a system shell. Supported commands follow Dora Git API support.", -- 341
			"Git mode accepts cwd for non-clone commands. cwd must be a project-relative existing directory. Do not use git -C.", -- 342
			"Git clone uses a temporary directory first, then moves into the project only after clone succeeds; existing targets are not overwritten.", -- 343
			"Git clone rejects local, private, metadata, and literal-IP destinations and discards repositories larger than 128 MiB.", -- 344
			"The Web IDE resource tree is refreshed automatically after every successful Git command." -- 345
		} -- 345
	}, -- 345
	{ -- 348
		name = "spawn_agent", -- 349
		roles = {"main"}, -- 350
		workModes = {"code"}, -- 351
		description = "Dispatch a sub agent for delegated work, or list sub-agent state when prompt is omitted.", -- 352
		parameters = { -- 353
			{name = "prompt", type = "string", description = "Spawn form: detailed, self-contained task prompt sent to the sub agent. Provide it with title to spawn; omit it to list sub-agent state instead."}, -- 354
			{name = "title", type = "string", description = "Spawn form: short tab title for the sub agent. Required when prompt is present; ignored otherwise."}, -- 355
			{name = "expectedOutput", type = "string", description = "Spawn form: optional expected result summary."}, -- 356
			{name = "filesHint", type = "array", items = {type = "string"}, description = "Spawn form: optional likely files or directories involved."}, -- 357
			{name = "status", type = "string", enum = { -- 358
				"active_or_recent", -- 358
				"running", -- 358
				"done", -- 358
				"failed", -- 358
				"all" -- 358
			}, description = "List form: optional status filter. Defaults to active_or_recent."}, -- 358
			{name = "limit", type = "number", description = "List form: maximum number of items to return. Defaults to 5."}, -- 359
			{name = "offset", type = "number", description = "List form: offset for paging older items."}, -- 360
			{name = "query", type = "string", description = "List form: optional text filter matched against title, goal, or summary."} -- 361
		}, -- 361
		rules = { -- 363
			"Two forms: prompt + title dispatches a new sub agent; prompt omitted lists sub-agent state. Never combine spawn fields with list filters.", -- 364
			"Use the spawn form for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks. For small focused edits, use edit_file/build directly in the current main-agent run.", -- 365
			"The spawned sub agent inherits the current session tool capabilities.", -- 366
			"prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files. title should be short and specific.", -- 367
			"Spawn is asynchronous and nonblocking. You may dispatch multiple independent sub agents in one response, subject to the concurrency limit.", -- 368
			"After dispatching all intended independent sub agents, complete at most three bounded foreground tool batches that do not depend on their results. Then finish this turn and return control to the user while the sub agents keep running.", -- 369
			"After any successful spawn in the current task, the list form is rejected for the rest of that task. Do not wait, join, or poll; completion arrives asynchronously as a later handoff.", -- 370
			"Use the list form only when you do not already know the current sub-agent status and need to inspect delegated work before deciding whether to dispatch more sub agents or read a result file.", -- 371
			"Avoid assigning overlapping files or dependent steps to concurrent sub agents unless the coordination boundary is explicit." -- 372
		} -- 372
	}, -- 372
	{ -- 375
		name = "ask_user", -- 376
		roles = {"main"}, -- 377
		workModes = {"plan"}, -- 378
		description = "Present a structured questionnaire and pause the Plan task until the user submits every required answer.", -- 379
		parameters = {{name = "title", type = "string", required = true, description = "Short questionnaire title."}, {name = "description", type = "string", description = "Optional context shown above the questions."}, { -- 380
			name = "questions", -- 384
			type = "array", -- 385
			required = true, -- 386
			description = "One to eight questions. Use single_choice, multiple_choice, or text. A single-choice question may recommend at most one option.", -- 387
			items = {type = "object", properties = { -- 388
				id = {type = "string"}, -- 391
				prompt = {type = "string"}, -- 392
				description = {type = "string"}, -- 393
				type = {type = "string", enum = {"single_choice", "multiple_choice", "text"}}, -- 394
				required = {type = "boolean"}, -- 395
				options = {type = "array", items = {type = "object", properties = {id = {type = "string"}, label = {type = "string"}, description = {type = "string"}, recommended = {type = "boolean", description = "Mark an option as recommended. Use at most one for single_choice; multiple_choice may mark any recommended set."}}, required = {"id", "label"}}}, -- 396
				placeholder = {type = "string"} -- 409
			}, required = {"id", "prompt", "type"}} -- 409
		}}, -- 409
		rules = { -- 415
			"Inspect the project before asking; do not ask for facts available through read_file, grep_files, or search_dora_doc.", -- 416
			"ask_user has no document-update prerequisite. Incorporate the answers into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish.", -- 417
			"For single_choice, mark at most one option recommended. For multiple_choice, recommended options form a suggested set.", -- 418
			"ask_user must be the only tool call in the response.", -- 419
			"The task pauses after the questionnaire is published and continues after the user submits answers or dismisses it.", -- 420
			"An answered or dismissed ask_user tool result contains authoritative user feedback. Apply answers when present; when dismissed, continue with reasonable assumptions and do not mechanically repeat the same questionnaire." -- 421
		} -- 421
	} -- 421
} -- 421
local function formatSchemaErrors(errors) -- 426
	return table.concat( -- 427
		__TS__ArrayMap( -- 427
			errors, -- 427
			function(____, item) return ((item.schemaPath ~= "" and item.schemaPath or "/") .. ": ") .. item.message end -- 427
		), -- 427
		"; " -- 427
	) -- 427
end -- 426
local function createToolDefinition(source) -- 430
	local definition = __TS__ObjectAssign( -- 431
		{}, -- 431
		source, -- 432
		{ -- 431
			inputSchema = source.inputSchema or (function(____, context) return createInputSchemaFromParameters(source.parameters, context) end), -- 433
			outputSchema = DEFAULT_TOOL_OUTPUT_SCHEMA, -- 434
			handler = AGENT_TOOL_HANDLERS[source.name], -- 435
			validateInput = AGENT_TOOL_VALIDATORS[source.name] -- 436
		} -- 436
	) -- 436
	local inputResult = compileJsonSchema(definition:inputSchema(DEFAULT_SCHEMA_CONTEXT)) -- 438
	if not inputResult.success then -- 438
		error( -- 440
			__TS__New( -- 440
				Error, -- 440
				(("Invalid input schema for " .. definition.name) .. ": ") .. formatSchemaErrors(inputResult.errors) -- 440
			), -- 440
			0 -- 440
		) -- 440
	end -- 440
	local outputResult = compileJsonSchema(definition.outputSchema) -- 442
	if not outputResult.success then -- 442
		error( -- 444
			__TS__New( -- 444
				Error, -- 444
				(("Invalid output schema for " .. definition.name) .. ": ") .. formatSchemaErrors(outputResult.errors) -- 444
			), -- 444
			0 -- 444
		) -- 444
	end -- 444
	return definition -- 446
end -- 430
____exports.AGENT_TOOL_DEFINITIONS = __TS__ArrayMap( -- 449
	AGENT_TOOL_DEFINITION_SOURCES, -- 449
	function(____, source) return createToolDefinition(source) end -- 449
) -- 449
local function hasRole(tool, role) -- 451
	return __TS__ArrayIndexOf(tool.roles, role) >= 0 -- 452
end -- 451
local function hasWorkMode(tool, workMode) -- 455
	return __TS__ArrayIndexOf(tool.workModes, workMode) >= 0 -- 456
end -- 455
local function isToolCapabilityEnabled(tool, options) -- 466
	if not ____exports.isKnownToolName(tool.name) then -- 466
		return false -- 467
	end -- 467
	return hasWorkMode(tool, options and options.workMode or "code") and __TS__ArrayIndexOf(options and options.disabledAgentTools or ({}), tool.name) < 0 -- 468
end -- 466
local function formatParameterList(tool) -- 472
	local parameters = tool.parameters or ({}) -- 473
	if #parameters == 0 then -- 473
		return "" -- 474
	end -- 474
	return table.concat( -- 475
		__TS__ArrayMap( -- 475
			parameters, -- 475
			function(____, parameter) return parameter.required == true and parameter.name or parameter.name .. "(optional)" end -- 476
		), -- 476
		", " -- 477
	) -- 477
end -- 472
local function formatToolPrompt(tool, index, context) -- 480
	local lines = {(((tostring(index + 1) .. ". ") .. tool.name) .. ": ") .. getToolDescription(tool, context)} -- 481
	local parameterList = formatParameterList(tool) -- 482
	if parameterList ~= "" then -- 482
		lines[#lines + 1] = "\t- Parameters: " .. parameterList -- 484
	end -- 484
	for ____, parameter in ipairs(tool.parameters or ({})) do -- 486
		local label = parameter.required == true and parameter.name or parameter.name .. "(optional)" -- 487
		lines[#lines + 1] = (("\t- " .. label) .. ": ") .. getParameterDescription(parameter, context) -- 488
	end -- 488
	for ____, rule in ipairs(getToolRules(tool, context)) do -- 490
		lines[#lines + 1] = "\t- " .. rule -- 491
	end -- 491
	return table.concat(lines, "\n") -- 493
end -- 480
function ____exports.getAllowedToolsForRole(role, options) -- 500
	return __TS__ArrayMap( -- 501
		__TS__ArrayFilter( -- 501
			____exports.AGENT_TOOL_DEFINITIONS, -- 501
			function(____, tool) return hasRole(tool, role) and ____exports.isKnownToolName(tool.name) and isToolCapabilityEnabled(tool, options) end -- 502
		), -- 502
		function(____, tool) return tool.name end -- 503
	) -- 503
end -- 500
function ____exports.buildCurrentToolAvailabilityGuidance() -- 506
	return table.concat({"Current tool availability:", "- every tool defined in the current system prompt or exposed in the current tool schema is executable", "- capabilities disabled for this task are omitted from both the definitions and schema"}, "\n") -- 507
end -- 506
function ____exports.getToolDefinitionsForRole(role, options) -- 514
	return __TS__ArrayFilter( -- 519
		____exports.AGENT_TOOL_DEFINITIONS, -- 519
		function(____, tool) return hasRole(tool, role) and isToolCapabilityEnabled(tool, options) end -- 519
	) -- 519
end -- 514
local function getDecisionToolDefinitionsForRole(role, options) -- 525
	return ____exports.getToolDefinitionsForRole(role, options) -- 530
end -- 525
function ____exports.buildToolDefinitionsDetailed(tools, options) -- 533
	local title = (options and options.title) ~= nil and options.title or "Available tools:" -- 537
	local context = options and options.context or DEFAULT_SCHEMA_CONTEXT -- 538
	local sections = __TS__ArrayMap( -- 539
		tools, -- 539
		function(____, tool, index) return formatToolPrompt(tool, index, context) end -- 539
	) -- 539
	local body = table.concat(sections, "\n\n") -- 540
	return title ~= "" and (title .. "\n") .. body or body -- 541
end -- 533
function ____exports.buildRoleToolDefinitionsDetailed(role, options) -- 544
	return ____exports.buildToolDefinitionsDetailed( -- 551
		getDecisionToolDefinitionsForRole(role, {includeFinish = options and options.includeFinish, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 552
		{title = options and options.title, context = options and options.context} -- 557
	) -- 557
end -- 544
____exports.AGENT_TOOL_DEFINITIONS_DETAILED = ____exports.buildToolDefinitionsDetailed( -- 564
	____exports.getToolDefinitionsForRole("sub"), -- 565
	{title = "Available tools:"} -- 566
) -- 566
____exports.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = "\n" .. ____exports.buildToolDefinitionsDetailed( -- 569
	__TS__ArrayFilter( -- 570
		____exports.getToolDefinitionsForRole("main"), -- 570
		function(____, tool) return __TS__ArrayIndexOf( -- 571
			__TS__ArrayMap( -- 571
				____exports.getToolDefinitionsForRole("sub"), -- 571
				function(____, subTool) return subTool.name end -- 571
			), -- 571
			tool.name -- 571
		) < 0 end -- 571
	), -- 571
	{title = ""} -- 572
) -- 572
function ____exports.canPreExecuteTool(tool) -- 575
	local definition = ____exports.getToolDefinition(tool) -- 576
	return (definition and definition.preExecutable) == true -- 577
end -- 575
function ____exports.canRunToolInParallel(tool) -- 580
	local definition = ____exports.getToolDefinition(tool) -- 581
	return (definition and definition.parallelSafe) == true -- 582
end -- 580
function ____exports.buildDecisionToolSchema(role, searchDoraDocLimitMax, options) -- 585
	local context = {searchDoraDocLimitMax = searchDoraDocLimitMax} -- 586
	return ____exports.buildDecisionToolSchemaForTools( -- 587
		getDecisionToolDefinitionsForRole(role, {includeFinish = true, disabledAgentTools = options and options.disabledAgentTools, workMode = options and options.workMode}), -- 587
		context -- 591
	) -- 591
end -- 585
return ____exports -- 585