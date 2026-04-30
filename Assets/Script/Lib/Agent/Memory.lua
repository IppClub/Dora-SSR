-- [ts]: Memory.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__InstanceOf = ____lualib.__TS__InstanceOf -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local ____Utils = require("Agent.Utils") -- 3
local callLLM = ____Utils.callLLM -- 3
local Log = ____Utils.Log -- 3
local clipTextToTokenBudget = ____Utils.clipTextToTokenBudget -- 3
local parseXMLObjectFromText = ____Utils.parseXMLObjectFromText -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 3
local ____Utils = require("Agent.Utils") -- 4
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 4
local ____Tools = require("Agent.Tools") -- 6
local sendWebIDEFileUpdate = ____Tools.sendWebIDEFileUpdate -- 6
local MEMORY_DEFAULT_LLM_TEMPERATURE = 0.1 -- 8
local MEMORY_DEFAULT_LLM_MAX_TOKENS = 8192 -- 9
local MEMORY_DEFAULT_CONTEXT_WINDOW = 64000 -- 10
local AGENT_MEMORY_CONTEXT_MIN_TOKENS = 1200 -- 11
local AGENT_MEMORY_CONTEXT_WINDOW_RATIO = 0.08 -- 12
local COMPRESSION_RESERVED_OUTPUT_MIN_TOKENS = 2048 -- 13
local COMPRESSION_RESERVED_OUTPUT_CONTEXT_RATIO = 0.2 -- 14
local COMPRESSION_HISTORY_MIN_TOKENS = 1200 -- 15
local COMPRESSION_HISTORY_AVAILABLE_RATIO = 0.9 -- 16
local COMPRESSION_HISTORY_TRUNCATED_MIN_CHARS = 2000 -- 17
local COMPRESSION_HISTORY_TRUNCATED_HEAD_RATIO = 0.35 -- 18
local COMPRESSION_DYNAMIC_MIN_TOKENS = 1600 -- 19
local COMPRESSION_DYNAMIC_PROMPT_OVERHEAD_TOKENS = 256 -- 20
local COMPRESSION_SECTION_MEMORY_MIN_TOKENS = 320 -- 21
local COMPRESSION_SECTION_MEMORY_RATIO = 0.2 -- 22
local COMPRESSION_SECTION_SESSION_MIN_TOKENS = 240 -- 23
local COMPRESSION_SECTION_SESSION_RATIO = 0.15 -- 24
local COMPRESSION_SECTION_HISTORY_MIN_TOKENS = 800 -- 25
local COMPRESSION_SECTION_HISTORY_RATIO = 0.45 -- 26
local function buildMemoryLLMOptions(llmConfig, overrides) -- 28
	local options = {temperature = llmConfig.temperature or MEMORY_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or MEMORY_DEFAULT_LLM_MAX_TOKENS} -- 29
	if llmConfig.reasoningEffort then -- 29
		options.reasoning_effort = llmConfig.reasoningEffort -- 34
	end -- 34
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 36
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 36
		__TS__Delete(merged, "reasoning_effort") -- 41
	else -- 41
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 43
	end -- 43
	return merged -- 45
end -- 28
local function isRecord(value) -- 48
	return type(value) == "table" -- 49
end -- 48
local function isArray(value) -- 52
	return __TS__ArrayIsArray(value) -- 53
end -- 52
local function clampSessionIndex(messages, index) -- 81
	if type(index) ~= "number" then -- 81
		return 0 -- 82
	end -- 82
	if index <= 0 then -- 82
		return 0 -- 83
	end -- 83
	return math.min( -- 84
		#messages, -- 84
		math.floor(index) -- 84
	) -- 84
end -- 81
local AGENT_CONFIG_DIR = ".agent" -- 87
local AGENT_PROMPTS_FILE = "AGENT.md" -- 88
local NO_PROMPT_PACK_SECTIONS_ERROR = "no prompt pack sections found" -- 89
local HISTORY_JSONL_FILE = "HISTORY.jsonl" -- 90
local HISTORY_MAX_RECORDS = 1000 -- 91
local SESSION_MAX_RECORDS = 1000 -- 92
local SUB_AGENT_SPAWN_INFO_FILE = "SPAWN.json" -- 93
local SUB_AGENT_LEARNINGS_MAX_ITEMS = 10 -- 94
local SUB_AGENT_LEARNINGS_MAX_CHARS = 5000 -- 95
local SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 96
local SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 97
local DEFAULT_CORE_MEMORY_TEMPLATE = "## Core Memory\n\n### User Preferences\n\n### Stable Facts\n\n### Known Decisions\n\n### Known Issues\n" -- 98
local DEFAULT_PROJECT_MEMORY_TEMPLATE = "## Project Memory\n\n### Project Facts\n\n### Build And Run\n\n### Files And Architecture\n\n### Decisions\n\n### Known Issues\n" -- 108
local DEFAULT_SESSION_SUMMARY_TEMPLATE = "## Session Summary\n\n### Current Goal\n\n### Recent Progress\n\n### Open Issues\n" -- 120
local MEMORY_CONTEXT_DEFAULT_MAX_TOKENS = 4000 -- 128
local MEMORY_CONTEXT_MIN_MAX_TOKENS = 800 -- 129
local MEMORY_LAYER_MIN_TOKENS = 300 -- 130
local XML_DECISION_SCHEMA_EXAMPLE = "```xml\n<tool_call>\n\t<tool>edit_file</tool>\n\t<reason>Need to update the file content to implement the requested change.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<old_str>\nfunction oldName() {\n\tprint(\"old\");\n}\n\t\t</old_str>\n\t\t<new_str>\nfunction newName() {\n\tprint(\"hello\");\n}\n\t\t</new_str>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>read_file</tool>\n\t<reason>Need to inspect the current implementation before editing.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<startLine>1</startLine>\n\t\t<endLine>200</endLine>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>finish</tool>\n\t<params>\n\t\t<message>Final user-facing answer.</message>\n\t</params>\n</tool_call>\n```" -- 140
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 200
	agentIdentityPrompt = "# Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n# Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 201
	mainAgentRolePrompt = "# Agent Role\n\nYou are the main agent. Your job is to discuss plans with the user, inspect the codebase, make direct edits when that is the simplest path, and delegate larger or parallelizable implementation work by spawning sub agents.\n\nRules:\n- You may use the full toolset directly, including edit_file, delete_file, and build.\n- Use direct tools for small, focused, or user-interactive changes where staying in the current run gives the clearest result.\n- Use spawn_sub_agent for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n- Use list_sub_agents only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether another delegation is necessary or whether to read a result file.\n- Keep sub-agent titles short and specific.\n- The sub-agent prompt should be self-contained and executable, and should explain the exact task, constraints, expected output, and relevant files when known.\n- After spawn_sub_agent succeeds, immediately finish the current turn and tell the user the work has been delegated.\n- After a successful spawn_sub_agent, do not call list_sub_agents or any other tool in the same turn.\n- Treat the sub-agent completion result as an asynchronous handoff that should be continued in later conversation turns.", -- 214
	subAgentRolePrompt = "# Agent Role\n\nYou are a sub agent. Your job is to execute concrete implementation, editing, and build work delegated by the main agent.\n\nRules:\n- Focus on completing the delegated task end-to-end.\n- Use the available implementation tools directly when needed, including edit_file, delete_file, and build.\n- Documentation writing tasks are also part of your execution scope when delegated by the main agent.\n- Summaries should stay concise and execution-oriented.", -- 228
	functionCallingPrompt = "# Function Calling\n\nYou may return multiple tool calls in one response when the calls are independent and all results are useful before the next reasoning step.", -- 237
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. 0 is invalid.\n\t- startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 240
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 287
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 288
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with one or more valid tool calls.", -- 289
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 290
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 303
	xmlDecisionSystemRepairPrompt = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only.", -- 334
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\t- Separate updates into Core Memory, Project Memory, and Session Summary\n\n4. Create History Entry\n\t- Create a summary paragraph\n\t- Include key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 345
	memoryCompressionBodyPrompt = "# Current Core Memory\n\n{{CURRENT_MEMORY}}\n\n# Current Project Memory\n\n{{CURRENT_PROJECT_MEMORY}}\n\n# Current Session Summary\n\n{{CURRENT_SESSION_SUMMARY}}\n\n# Actions to Process\n\n{{HISTORY_TEXT}}", -- 375
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content (Core Memory only)\n- project_memory_update: optional full updated PROJECT_MEMORY.md content; omit or leave empty to keep the current content\n- session_summary_update: optional full updated SESSION_SUMMARY.md content; omit or leave empty to keep the current content", -- 390
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update>\nFull updated MEMORY.md content (Core Memory only)\n\t</memory_update>\n\t<project_memory_update>\nFull updated PROJECT_MEMORY.md content\n\t</project_memory_update>\n\t<session_summary_update>\nFull updated SESSION_SUMMARY.md content\n\t</session_summary_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Include `<history_entry>` and `<memory_update>`. `<project_memory_update>` and `<session_summary_update>` are optional; omit them to keep current content.\n- Use CDATA for markdown update fields when they span multiple lines or contain markdown/code.", -- 397
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 420
} -- 420
local EXPOSED_PROMPT_PACK_KEYS = { -- 423
	"agentIdentityPrompt", -- 424
	"mainAgentRolePrompt", -- 425
	"subAgentRolePrompt", -- 426
	"functionCallingPrompt", -- 427
	"toolDefinitionsDetailed", -- 428
	"replyLanguageDirectiveZh", -- 429
	"replyLanguageDirectiveEn", -- 430
	"toolCallingRetryPrompt", -- 431
	"xmlDecisionFormatPrompt", -- 432
	"xmlDecisionRepairPrompt", -- 433
	"xmlDecisionSystemRepairPrompt", -- 434
	"memoryCompressionSystemPrompt", -- 435
	"memoryCompressionBodyPrompt", -- 436
	"memoryCompressionToolCallingPrompt", -- 437
	"memoryCompressionXmlPrompt", -- 438
	"memoryCompressionXmlRetryPrompt" -- 439
} -- 439
local function replaceTemplateVars(template, vars) -- 442
	local output = template -- 443
	for key in pairs(vars) do -- 444
		output = table.concat( -- 445
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 445
			vars[key] or "" or "," -- 445
		) -- 445
	end -- 445
	return output -- 447
end -- 442
function ____exports.resolveAgentPromptPack(value) -- 450
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 451
	if value and not isArray(value) and isRecord(value) then -- 451
		do -- 451
			local i = 0 -- 455
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 455
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 456
				if type(value[key]) == "string" then -- 456
					merged[key] = value[key] -- 458
				end -- 458
				i = i + 1 -- 455
			end -- 455
		end -- 455
	end -- 455
	return merged -- 462
end -- 450
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 465
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 466
	local lines = {} -- 467
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 468
	lines[#lines + 1] = "" -- 469
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 470
	lines[#lines + 1] = "" -- 471
	do -- 471
		local i = 0 -- 472
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 472
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 473
			lines[#lines + 1] = ("## `" .. key) .. "`" -- 474
			local text = pack[key] -- 475
			local split = __TS__StringSplit(text, "\n") -- 476
			do -- 476
				local j = 0 -- 477
				while j < #split do -- 477
					lines[#lines + 1] = split[j + 1] -- 478
					j = j + 1 -- 477
				end -- 477
			end -- 477
			lines[#lines + 1] = "" -- 480
			i = i + 1 -- 472
		end -- 472
	end -- 472
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 482
end -- 465
local function getPromptPackConfigPath(projectRoot) -- 485
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 486
end -- 485
local function ensurePromptPackConfig(projectRoot) -- 489
	local path = getPromptPackConfigPath(projectRoot) -- 490
	if Content:exist(path) then -- 490
		return nil -- 491
	end -- 491
	local dir = Path:getPath(path) -- 492
	if not Content:exist(dir) then -- 492
		Content:mkdir(dir) -- 494
	end -- 494
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 496
	if not Content:save(path, content) then -- 496
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 498
	end -- 498
	sendWebIDEFileUpdate(path, true, content) -- 500
	return nil -- 501
end -- 489
local function rewriteDefaultPromptPackConfig(path) -- 504
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 505
	if not Content:save(path, content) then -- 505
		return ("Failed to recreate default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 507
	end -- 507
	sendWebIDEFileUpdate(path, true, content) -- 509
	return nil -- 510
end -- 504
local function parsePromptPackMarkdown(text) -- 513
	if not text or __TS__StringTrim(text) == "" then -- 513
		return { -- 520
			value = {}, -- 521
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 522
			unknown = {} -- 523
		} -- 523
	end -- 523
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 526
	local lines = __TS__StringSplit(normalized, "\n") -- 527
	local sections = {} -- 528
	local unknown = {} -- 529
	local currentHeading = "" -- 530
	local function isKnownPromptPackKey(name) -- 531
		do -- 531
			local i = 0 -- 532
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 532
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 532
					return true -- 533
				end -- 533
				i = i + 1 -- 532
			end -- 532
		end -- 532
		return false -- 535
	end -- 531
	do -- 531
		local i = 0 -- 537
		while i < #lines do -- 537
			do -- 537
				local line = lines[i + 1] -- 538
				local matchedHeading = string.match(line, "^##[ \t]+`([^`]+)`[ \t]*$") -- 539
				if matchedHeading ~= nil then -- 539
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 541
					if isKnownPromptPackKey(heading) then -- 541
						currentHeading = heading -- 543
						if sections[currentHeading] == nil then -- 543
							sections[currentHeading] = {} -- 545
						end -- 545
						goto __continue38 -- 547
					end -- 547
					unknown[#unknown + 1] = heading -- 549
					goto __continue38 -- 550
				end -- 550
				if currentHeading ~= "" then -- 550
					local ____sections_currentHeading_0 = sections[currentHeading] -- 550
					____sections_currentHeading_0[#____sections_currentHeading_0 + 1] = line -- 553
				end -- 553
			end -- 553
			::__continue38:: -- 553
			i = i + 1 -- 537
		end -- 537
	end -- 537
	local value = {} -- 556
	local missing = {} -- 557
	do -- 557
		local i = 0 -- 558
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 558
			do -- 558
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 559
				local section = sections[key] -- 560
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 561
				if body == "" then -- 561
					missing[#missing + 1] = key -- 563
					goto __continue44 -- 564
				end -- 564
				value[key] = body -- 566
			end -- 566
			::__continue44:: -- 566
			i = i + 1 -- 558
		end -- 558
	end -- 558
	if #__TS__ObjectKeys(sections) == 0 then -- 558
		return {error = NO_PROMPT_PACK_SECTIONS_ERROR, missing = missing, unknown = unknown} -- 569
	end -- 569
	return {value = value, missing = missing, unknown = unknown} -- 575
end -- 513
function ____exports.loadAgentPromptPack(projectRoot) -- 578
	local path = getPromptPackConfigPath(projectRoot) -- 579
	local warnings = {} -- 580
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 581
	if ensureWarning and ensureWarning ~= "" then -- 581
		warnings[#warnings + 1] = ensureWarning -- 583
	end -- 583
	if not Content:exist(path) then -- 583
		return { -- 586
			pack = ____exports.resolveAgentPromptPack(), -- 587
			warnings = warnings, -- 588
			path = path -- 589
		} -- 589
	end -- 589
	local text = Content:load(path) -- 592
	if not text or __TS__StringTrim(text) == "" then -- 592
		local rewriteWarning = rewriteDefaultPromptPackConfig(path) -- 594
		if rewriteWarning then -- 594
			warnings[#warnings + 1] = rewriteWarning -- 596
		else -- 596
			warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Recreated default prompt config." -- 598
		end -- 598
		return { -- 600
			pack = ____exports.resolveAgentPromptPack(), -- 601
			warnings = warnings, -- 602
			path = path -- 603
		} -- 603
	end -- 603
	local parsed = parsePromptPackMarkdown(text) -- 606
	if parsed.error == NO_PROMPT_PACK_SECTIONS_ERROR then -- 606
		local rewriteWarning = rewriteDefaultPromptPackConfig(path) -- 608
		if rewriteWarning then -- 608
			warnings[#warnings + 1] = rewriteWarning -- 610
		else -- 610
			warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " has no prompt sections. Recreated default prompt config." -- 612
		end -- 612
		return { -- 614
			pack = ____exports.resolveAgentPromptPack(), -- 615
			warnings = warnings, -- 616
			path = path -- 617
		} -- 617
	end -- 617
	if parsed.error or not parsed.value then -- 617
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 621
		return { -- 622
			pack = ____exports.resolveAgentPromptPack(), -- 623
			warnings = warnings, -- 624
			path = path -- 625
		} -- 625
	end -- 625
	if #parsed.unknown > 0 then -- 625
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 629
	end -- 629
	if #parsed.missing > 0 then -- 629
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 632
	end -- 632
	return { -- 634
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 635
		warnings = warnings, -- 636
		path = path -- 637
	} -- 637
end -- 578
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 718
local TokenEstimator = ____exports.TokenEstimator -- 718
TokenEstimator.name = "TokenEstimator" -- 718
function TokenEstimator.prototype.____constructor(self) -- 718
end -- 718
function TokenEstimator.estimate(self, text) -- 722
	if text == "" then -- 722
		return 0 -- 723
	end -- 723
	return App:estimateTokens(text) -- 724
end -- 722
function TokenEstimator.estimateMessages(self, messages) -- 727
	if messages == nil or #messages == 0 then -- 727
		return 0 -- 728
	end -- 728
	local total = 0 -- 729
	do -- 729
		local i = 0 -- 730
		while i < #messages do -- 730
			local message = messages[i + 1] -- 731
			total = total + self:estimate(message.role or "") -- 732
			total = total + self:estimate(message.content or "") -- 733
			total = total + self:estimate(message.name or "") -- 734
			total = total + self:estimate(message.tool_call_id or "") -- 735
			total = total + self:estimate(message.reasoning_content or "") -- 736
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 737
			total = total + self:estimate(toolCallsText or "") -- 738
			total = total + 8 -- 739
			i = i + 1 -- 730
		end -- 730
	end -- 730
	return total -- 741
end -- 727
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 744
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 749
end -- 744
local function encodeCompressionDebugJSON(value) -- 757
	local text, err = safeJsonEncode(value) -- 758
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 759
end -- 757
local function utf8TakeHead(text, maxChars) -- 762
	if maxChars <= 0 or text == "" then -- 762
		return "" -- 763
	end -- 763
	local nextPos = utf8.offset(text, maxChars + 1) -- 764
	if nextPos == nil then -- 764
		return text -- 765
	end -- 765
	return string.sub(text, 1, nextPos - 1) -- 766
end -- 762
local function utf8TakeTail(text, maxChars) -- 769
	if maxChars <= 0 or text == "" then -- 769
		return "" -- 770
	end -- 770
	local charLen = utf8.len(text) -- 771
	if charLen == nil or charLen <= maxChars then -- 771
		return text -- 772
	end -- 772
	local startChar = math.max(1, charLen - maxChars + 1) -- 773
	local startPos = utf8.offset(text, startChar) -- 774
	if startPos == nil then -- 774
		return text -- 775
	end -- 775
	return string.sub(text, startPos) -- 776
end -- 769
local function ensureDirRecursive(dir) -- 779
	if not dir or dir == "" then -- 779
		return false -- 780
	end -- 780
	if Content:exist(dir) then -- 780
		return Content:isdir(dir) -- 781
	end -- 781
	local parent = Path:getPath(dir) -- 782
	if parent and parent ~= dir and not Content:exist(parent) then -- 782
		if not ensureDirRecursive(parent) then -- 782
			return false -- 785
		end -- 785
	end -- 785
	return Content:mkdir(dir) -- 788
end -- 779
local function normalizeMemoryFileContent(content, template, importedSectionTitle) -- 791
	local safeContent = type(content) == "string" and sanitizeUTF8(content) or "" -- 792
	local trimmed = __TS__StringTrim(safeContent) -- 793
	if trimmed == "" then -- 793
		return template -- 794
	end -- 794
	if (string.find(trimmed, "\n## ", nil, true) or 0) - 1 >= 0 or (string.find(trimmed, "\n# ", nil, true) or 0) - 1 >= 0 or string.sub(trimmed, 1, 3) == "## " or string.sub(trimmed, 1, 2) == "# " then -- 794
		return safeContent -- 796
	end -- 796
	return ((((__TS__StringTrim(template) .. "\n\n## ") .. importedSectionTitle) .. "\n\n") .. trimmed) .. "\n" -- 798
end -- 791
local function splitMemorySections(text) -- 801
	local sections = {} -- 802
	local lines = __TS__StringSplit( -- 803
		sanitizeUTF8(text or ""), -- 803
		"\n" -- 803
	) -- 803
	local title = "Overview" -- 804
	local bodyLines = {} -- 805
	local index = 0 -- 806
	local function flush() -- 807
		local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 808
		if body ~= "" then -- 808
			local fullText = title == "Overview" and body or (("## " .. title) .. "\n\n") .. body -- 810
			sections[#sections + 1] = { -- 811
				title = title, -- 811
				body = body, -- 811
				fullText = fullText, -- 811
				index = index, -- 811
				score = 0 -- 811
			} -- 811
			index = index + 1 -- 812
		end -- 812
	end -- 807
	do -- 807
		local i = 0 -- 815
		while i < #lines do -- 815
			do -- 815
				local line = lines[i + 1] -- 816
				if string.sub(line, 1, 3) == "## " then -- 816
					flush() -- 818
					title = __TS__StringTrim(string.sub(line, 4)) -- 819
					bodyLines = {} -- 820
				elseif string.sub(line, 1, 2) == "# " then -- 820
					goto __continue87 -- 822
				else -- 822
					bodyLines[#bodyLines + 1] = line -- 824
				end -- 824
			end -- 824
			::__continue87:: -- 824
			i = i + 1 -- 815
		end -- 815
	end -- 815
	flush() -- 827
	return sections -- 828
end -- 801
local function collectQueryTerms(query) -- 831
	local terms = {} -- 832
	local lower = string.lower(sanitizeUTF8(query or "")) -- 833
	local current = "" -- 834
	local function pushCurrent() -- 835
		local word = __TS__StringTrim(current) -- 836
		if #word >= 2 and __TS__ArrayIndexOf(terms, word) < 0 then -- 836
			terms[#terms + 1] = word -- 838
		end -- 838
		current = "" -- 840
	end -- 835
	do -- 835
		local i = 0 -- 842
		while i < #lower do -- 842
			local ch = __TS__StringCharAt(lower, i) -- 843
			local code = __TS__StringCharCodeAt(lower, i) -- 844
			local isAsciiWord = code >= 48 and code <= 57 or code >= 97 and code <= 122 or ch == "_" or ch == "-" or ch == "." -- 845
			if isAsciiWord then -- 845
				current = current .. ch -- 847
			else -- 847
				pushCurrent() -- 849
				if code > 127 and __TS__ArrayIndexOf(terms, ch) < 0 then -- 849
					terms[#terms + 1] = ch -- 850
				end -- 850
			end -- 850
			i = i + 1 -- 842
		end -- 842
	end -- 842
	pushCurrent() -- 853
	return terms -- 854
end -- 831
local function countOccurrences(text, term) -- 857
	if text == "" or term == "" then -- 857
		return 0 -- 858
	end -- 858
	local count = 0 -- 859
	local start = 0 -- 860
	while true do -- 860
		local pos = (string.find( -- 862
			text, -- 862
			term, -- 862
			math.max(start + 1, 1), -- 862
			true -- 862
		) or 0) - 1 -- 862
		if pos < 0 then -- 862
			break -- 863
		end -- 863
		count = count + 1 -- 864
		start = pos + #term -- 865
	end -- 865
	return count -- 867
end -- 857
local function scoreMemorySection(section, terms) -- 870
	local titleLower = string.lower(section.title) -- 871
	local bodyLower = string.lower(section.body) -- 872
	local score = 0 -- 873
	do -- 873
		local i = 0 -- 874
		while i < #terms do -- 874
			local term = terms[i + 1] -- 875
			score = score + countOccurrences(titleLower, term) * 6 -- 876
			score = score + countOccurrences(bodyLower, term) -- 877
			i = i + 1 -- 874
		end -- 874
	end -- 874
	if (string.find(titleLower, "user preference", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "stable fact", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "known decision", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "known issue", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "current goal", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "recent progress", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "build and run", nil, true) or 0) - 1 >= 0 then -- 874
		score = score + (#terms > 0 and 1 or 3) -- 888
	end -- 888
	return score -- 890
end -- 870
local function selectRelevantMemoryText(text, query, maxTokens) -- 893
	local sections = splitMemorySections(text) -- 894
	if #sections == 0 then -- 894
		return "" -- 895
	end -- 895
	local budget = math.max(MEMORY_LAYER_MIN_TOKENS, maxTokens) -- 896
	local terms = collectQueryTerms(query) -- 897
	do -- 897
		local i = 0 -- 898
		while i < #sections do -- 898
			sections[i + 1].score = scoreMemorySection(sections[i + 1], terms) -- 899
			i = i + 1 -- 898
		end -- 898
	end -- 898
	local ranked = __TS__ArraySlice(sections) -- 901
	__TS__ArraySort( -- 902
		ranked, -- 902
		function(____, a, b) -- 902
			if a.score ~= b.score then -- 902
				return b.score - a.score -- 903
			end -- 903
			return a.index - b.index -- 904
		end -- 902
	) -- 902
	local selected = {} -- 906
	local used = 0 -- 907
	do -- 907
		local i = 0 -- 908
		while i < #ranked do -- 908
			do -- 908
				local section = ranked[i + 1] -- 909
				if #terms > 0 and section.score <= 0 then -- 909
					goto __continue114 -- 910
				end -- 910
				local cost = ____exports.TokenEstimator:estimate(section.fullText) + 12 -- 911
				if #selected > 0 and used + cost > budget then -- 911
					goto __continue114 -- 912
				end -- 912
				selected[#selected + 1] = section -- 913
				used = used + cost -- 914
				if used >= budget then -- 914
					break -- 915
				end -- 915
			end -- 915
			::__continue114:: -- 915
			i = i + 1 -- 908
		end -- 908
	end -- 908
	if #selected == 0 then -- 908
		do -- 908
			local i = 0 -- 918
			while i < #sections do -- 918
				do -- 918
					local section = sections[i + 1] -- 919
					local cost = ____exports.TokenEstimator:estimate(section.fullText) + 12 -- 920
					if #selected > 0 and used + cost > budget then -- 920
						goto __continue120 -- 921
					end -- 921
					selected[#selected + 1] = section -- 922
					used = used + cost -- 923
					if used >= budget then -- 923
						break -- 924
					end -- 924
				end -- 924
				::__continue120:: -- 924
				i = i + 1 -- 918
			end -- 918
		end -- 918
	end -- 918
	__TS__ArraySort( -- 927
		selected, -- 927
		function(____, a, b) return a.index - b.index end -- 927
	) -- 927
	return table.concat( -- 928
		__TS__ArrayMap( -- 928
			selected, -- 928
			function(____, section) return section.fullText end -- 928
		), -- 928
		"\n\n" -- 928
	) -- 928
end -- 893
local function formatMemoryLayer(title, content) -- 931
	local trimmed = __TS__StringTrim(sanitizeUTF8(content or "")) -- 932
	if trimmed == "" then -- 932
		return "" -- 933
	end -- 933
	return (("#### " .. title) .. "\n\n") .. trimmed -- 934
end -- 931
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.jsonl (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 942
local DualLayerStorage = ____exports.DualLayerStorage -- 942
DualLayerStorage.name = "DualLayerStorage" -- 942
function DualLayerStorage.prototype.____constructor(self, projectDir, scope) -- 953
	if scope == nil then -- 953
		scope = "" -- 953
	end -- 953
	self.projectDir = projectDir -- 954
	self.scope = scope -- 955
	self.agentRootDir = Path(self.projectDir, ".agent") -- 956
	self.agentDir = scope ~= "" and Path(self.agentRootDir, scope) or self.agentRootDir -- 957
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 960
	self.projectMemoryPath = Path(self.agentDir, "PROJECT_MEMORY.md") -- 961
	self.sessionSummaryPath = Path(self.agentDir, "SESSION_SUMMARY.md") -- 962
	self.historyPath = Path(self.agentDir, HISTORY_JSONL_FILE) -- 963
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 964
	self:ensureAgentFiles() -- 965
end -- 953
function DualLayerStorage.prototype.ensureDir(self, dir) -- 968
	if not Content:exist(dir) then -- 968
		ensureDirRecursive(dir) -- 970
	end -- 970
end -- 968
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 974
	if Content:exist(path) then -- 974
		return false -- 975
	end -- 975
	self:ensureDir(Path:getPath(path)) -- 976
	if not Content:save(path, content) then -- 976
		return false -- 978
	end -- 978
	sendWebIDEFileUpdate(path, true, content) -- 980
	return true -- 981
end -- 974
function DualLayerStorage.prototype.ensureStructuredMemoryFile(self, path, template) -- 984
	if not Content:exist(path) then -- 984
		self:ensureFile(path, template) -- 986
		return -- 987
	end -- 987
	local current = Content:load(path) -- 989
	if type(current) ~= "string" or __TS__StringTrim(current) == "" then -- 989
		Content:save(path, template) -- 991
		sendWebIDEFileUpdate(path, true, template) -- 992
	end -- 992
end -- 984
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 996
	self:ensureDir(self.agentRootDir) -- 997
	self:ensureDir(self.agentDir) -- 998
	self:ensureStructuredMemoryFile(self.memoryPath, DEFAULT_CORE_MEMORY_TEMPLATE) -- 999
	self:ensureStructuredMemoryFile(self.projectMemoryPath, DEFAULT_PROJECT_MEMORY_TEMPLATE) -- 1000
	self:ensureStructuredMemoryFile(self.sessionSummaryPath, DEFAULT_SESSION_SUMMARY_TEMPLATE) -- 1001
	self:ensureFile(self.historyPath, "") -- 1002
end -- 996
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 1005
	local text = safeJsonEncode(value) -- 1006
	return text -- 1007
end -- 1005
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 1010
	local value = safeJsonDecode(text) -- 1011
	return value -- 1012
end -- 1010
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 1015
	if not value or isArray(value) or not isRecord(value) then -- 1015
		return nil -- 1016
	end -- 1016
	local row = value -- 1017
	local role = type(row.role) == "string" and row.role or "" -- 1018
	if role == "" then -- 1018
		return nil -- 1019
	end -- 1019
	local message = {role = role} -- 1020
	if type(row.content) == "string" then -- 1020
		message.content = sanitizeUTF8(row.content) -- 1021
	end -- 1021
	if type(row.name) == "string" then -- 1021
		message.name = sanitizeUTF8(row.name) -- 1022
	end -- 1022
	if type(row.tool_call_id) == "string" then -- 1022
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 1023
	end -- 1023
	if type(row.reasoning_content) == "string" then -- 1023
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 1024
	end -- 1024
	if type(row.timestamp) == "string" then -- 1024
		message.timestamp = sanitizeUTF8(row.timestamp) -- 1025
	end -- 1025
	if isArray(row.tool_calls) then -- 1025
		message.tool_calls = row.tool_calls -- 1027
	end -- 1027
	return message -- 1029
end -- 1015
function DualLayerStorage.prototype.decodeHistoryRecord(self, value) -- 1032
	if not value or isArray(value) or not isRecord(value) then -- 1032
		return nil -- 1033
	end -- 1033
	local row = value -- 1034
	local ts = type(row.ts) == "string" and __TS__StringTrim(row.ts) ~= "" and sanitizeUTF8(row.ts) or "" -- 1035
	local summary = type(row.summary) == "string" and __TS__StringTrim(row.summary) ~= "" and sanitizeUTF8(row.summary) or nil -- 1038
	local rawArchive = type(row.rawArchive) == "string" and __TS__StringTrim(row.rawArchive) ~= "" and sanitizeUTF8(row.rawArchive) or nil -- 1041
	if ts == "" or summary == nil and rawArchive == nil then -- 1041
		return nil -- 1044
	end -- 1044
	local record = {ts = ts, summary = summary, rawArchive = rawArchive} -- 1045
	return record -- 1050
end -- 1032
function DualLayerStorage.prototype.readSpawnInfo(self, path) -- 1053
	if not Content:exist(path) then -- 1053
		return nil -- 1054
	end -- 1054
	local text = Content:load(path) -- 1055
	if not text or __TS__StringTrim(text) == "" then -- 1055
		return nil -- 1056
	end -- 1056
	local value = safeJsonDecode(text) -- 1057
	if value and not isArray(value) and isRecord(value) then -- 1057
		return value -- 1059
	end -- 1059
	return nil -- 1061
end -- 1053
function DualLayerStorage.prototype.normalizeEvidence(self, value) -- 1064
	local evidence = {} -- 1065
	if not isArray(value) then -- 1065
		return evidence -- 1066
	end -- 1066
	do -- 1066
		local i = 0 -- 1067
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1067
			local item = type(value[i + 1]) == "string" and __TS__StringTrim(sanitizeUTF8(value[i + 1])) or "" -- 1068
			if item ~= "" and __TS__ArrayIndexOf(evidence, item) < 0 then -- 1068
				evidence[#evidence + 1] = item -- 1070
			end -- 1070
			i = i + 1 -- 1067
		end -- 1067
	end -- 1067
	return evidence -- 1073
end -- 1064
function DualLayerStorage.prototype.decodeSubAgentLearning(self, value, fallbackSortTs) -- 1076
	if not value or isArray(value) or not isRecord(value) then -- 1076
		return nil -- 1077
	end -- 1077
	local sourceSessionId = type(value.sourceSessionId) == "number" and math.floor(value.sourceSessionId) or 0 -- 1078
	local sourceTaskId = type(value.sourceTaskId) == "number" and math.floor(value.sourceTaskId) or 0 -- 1079
	local content = type(value.content) == "string" and utf8TakeHead( -- 1080
		__TS__StringTrim(sanitizeUTF8(value.content)), -- 1081
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1081
	) or "" -- 1081
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 1081
		return nil -- 1083
	end -- 1083
	return { -- 1084
		sourceSessionId = sourceSessionId, -- 1085
		sourceTaskId = sourceTaskId, -- 1086
		content = content, -- 1087
		evidence = self:normalizeEvidence(value.evidence), -- 1088
		createdAt = type(value.createdAt) == "string" and __TS__StringTrim(sanitizeUTF8(value.createdAt)) or "", -- 1089
		sortTs = fallbackSortTs -- 1090
	} -- 1090
end -- 1076
function DualLayerStorage.prototype.readSubAgentLearningEntries(self) -- 1094
	if self.scope ~= "" and self.scope ~= "main" then -- 1094
		return {} -- 1095
	end -- 1095
	local subAgentsDir = Path(self.agentRootDir, "subagents") -- 1096
	if not Content:exist(subAgentsDir) or not Content:isdir(subAgentsDir) then -- 1096
		return {} -- 1097
	end -- 1097
	local entries = {} -- 1098
	local seen = {} -- 1099
	for ____, rawPath in ipairs(Content:getDirs(subAgentsDir)) do -- 1100
		do -- 1100
			local dir = Content:isAbsolutePath(rawPath) and rawPath or Path(subAgentsDir, rawPath) -- 1101
			if not Content:exist(dir) or not Content:isdir(dir) then -- 1101
				goto __continue166 -- 1102
			end -- 1102
			local info = self:readSpawnInfo(Path(dir, SUB_AGENT_SPAWN_INFO_FILE)) -- 1103
			if info == nil or info.success ~= true then -- 1103
				goto __continue166 -- 1104
			end -- 1104
			local fallbackSortTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or 0 -- 1105
			local entry = self:decodeSubAgentLearning(info.memoryEntry, fallbackSortTs) -- 1106
			if entry == nil then -- 1106
				goto __continue166 -- 1107
			end -- 1107
			local key = (tostring(entry.sourceSessionId) .. ":") .. tostring(entry.sourceTaskId) -- 1108
			if seen[key] then -- 1108
				goto __continue166 -- 1109
			end -- 1109
			seen[key] = true -- 1110
			entries[#entries + 1] = entry -- 1111
		end -- 1111
		::__continue166:: -- 1111
	end -- 1111
	__TS__ArraySort( -- 1113
		entries, -- 1113
		function(____, a, b) return b.sortTs - a.sortTs end -- 1113
	) -- 1113
	return entries -- 1114
end -- 1094
function DualLayerStorage.prototype.buildSubAgentLearningsContext(self) -- 1117
	local entries = self:readSubAgentLearningEntries() -- 1118
	if #entries == 0 then -- 1118
		return "" -- 1119
	end -- 1119
	local lines = {"## Sub-Agent Learnings", ""} -- 1120
	local totalChars = 0 -- 1121
	local count = 0 -- 1122
	do -- 1122
		local i = 0 -- 1123
		while i < #entries and count < SUB_AGENT_LEARNINGS_MAX_ITEMS do -- 1123
			local entry = entries[i + 1] -- 1124
			local evidence = #entry.evidence > 0 and "\n  Evidence: " .. table.concat(entry.evidence, ", ") or "" -- 1125
			local line = ((((("- [sub-agent:" .. tostring(entry.sourceSessionId)) .. "/task:") .. tostring(entry.sourceTaskId)) .. "] ") .. entry.content) .. evidence -- 1126
			if totalChars + #line > SUB_AGENT_LEARNINGS_MAX_CHARS then -- 1126
				break -- 1127
			end -- 1127
			lines[#lines + 1] = line -- 1128
			totalChars = totalChars + #line -- 1129
			count = count + 1 -- 1130
			i = i + 1 -- 1123
		end -- 1123
	end -- 1123
	return count > 0 and table.concat(lines, "\n") or "" -- 1132
end -- 1117
function DualLayerStorage.prototype.readHistoryRecords(self) -- 1135
	if not Content:exist(self.historyPath) then -- 1135
		return {} -- 1137
	end -- 1137
	local text = Content:load(self.historyPath) -- 1139
	if not text or __TS__StringTrim(text) == "" then -- 1139
		return {} -- 1141
	end -- 1141
	local lines = __TS__StringSplit(text, "\n") -- 1143
	local records = {} -- 1144
	do -- 1144
		local i = 0 -- 1145
		while i < #lines do -- 1145
			do -- 1145
				local line = __TS__StringTrim(lines[i + 1]) -- 1146
				if line == "" then -- 1146
					goto __continue182 -- 1147
				end -- 1147
				local decoded = self:decodeJsonLine(line) -- 1148
				local record = self:decodeHistoryRecord(decoded) -- 1149
				if record ~= nil then -- 1149
					records[#records + 1] = record -- 1151
				end -- 1151
			end -- 1151
			::__continue182:: -- 1151
			i = i + 1 -- 1145
		end -- 1145
	end -- 1145
	return records -- 1154
end -- 1135
function DualLayerStorage.prototype.saveHistoryRecords(self, records) -- 1157
	self:ensureDir(Path:getPath(self.historyPath)) -- 1158
	local normalized = #records > HISTORY_MAX_RECORDS and __TS__ArraySlice(records, #records - HISTORY_MAX_RECORDS) or records -- 1159
	local lines = {} -- 1162
	do -- 1162
		local i = 0 -- 1163
		while i < #normalized do -- 1163
			local line = self:encodeJsonLine(normalized[i + 1]) -- 1164
			if type(line) == "string" and line ~= "" then -- 1164
				lines[#lines + 1] = line -- 1166
			end -- 1166
			i = i + 1 -- 1163
		end -- 1163
	end -- 1163
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 1169
	Content:save(self.historyPath, content) -- 1170
	sendWebIDEFileUpdate(self.historyPath, true, content) -- 1171
end -- 1157
function DualLayerStorage.prototype.readMemory(self) -- 1179
	if not Content:exist(self.memoryPath) then -- 1179
		return DEFAULT_CORE_MEMORY_TEMPLATE -- 1181
	end -- 1181
	return normalizeMemoryFileContent( -- 1183
		Content:load(self.memoryPath), -- 1183
		DEFAULT_CORE_MEMORY_TEMPLATE, -- 1183
		"Imported Notes" -- 1183
	) -- 1183
end -- 1179
function DualLayerStorage.prototype.writeMemory(self, content) -- 1189
	local normalized = normalizeMemoryFileContent(content, DEFAULT_CORE_MEMORY_TEMPLATE, "Imported Notes") -- 1190
	self:ensureDir(Path:getPath(self.memoryPath)) -- 1191
	Content:save(self.memoryPath, normalized) -- 1192
	sendWebIDEFileUpdate(self.memoryPath, true, normalized) -- 1193
end -- 1189
function DualLayerStorage.prototype.readProjectMemory(self) -- 1196
	if not Content:exist(self.projectMemoryPath) then -- 1196
		return DEFAULT_PROJECT_MEMORY_TEMPLATE -- 1198
	end -- 1198
	return normalizeMemoryFileContent( -- 1200
		Content:load(self.projectMemoryPath), -- 1200
		DEFAULT_PROJECT_MEMORY_TEMPLATE, -- 1200
		"Imported Project Notes" -- 1200
	) -- 1200
end -- 1196
function DualLayerStorage.prototype.writeProjectMemory(self, content) -- 1203
	local normalized = normalizeMemoryFileContent(content, DEFAULT_PROJECT_MEMORY_TEMPLATE, "Imported Project Notes") -- 1204
	self:ensureDir(Path:getPath(self.projectMemoryPath)) -- 1205
	Content:save(self.projectMemoryPath, normalized) -- 1206
	sendWebIDEFileUpdate(self.projectMemoryPath, true, normalized) -- 1207
end -- 1203
function DualLayerStorage.prototype.readSessionSummary(self) -- 1210
	if not Content:exist(self.sessionSummaryPath) then -- 1210
		return DEFAULT_SESSION_SUMMARY_TEMPLATE -- 1212
	end -- 1212
	return normalizeMemoryFileContent( -- 1214
		Content:load(self.sessionSummaryPath), -- 1214
		DEFAULT_SESSION_SUMMARY_TEMPLATE, -- 1214
		"Imported Session Notes" -- 1214
	) -- 1214
end -- 1210
function DualLayerStorage.prototype.writeSessionSummary(self, content) -- 1217
	local normalized = normalizeMemoryFileContent(content, DEFAULT_SESSION_SUMMARY_TEMPLATE, "Imported Session Notes") -- 1218
	self:ensureDir(Path:getPath(self.sessionSummaryPath)) -- 1219
	Content:save(self.sessionSummaryPath, normalized) -- 1220
	sendWebIDEFileUpdate(self.sessionSummaryPath, true, normalized) -- 1221
end -- 1217
function DualLayerStorage.prototype.getRelevantMemoryContext(self, query, maxTokens) -- 1227
	if query == nil then -- 1227
		query = "" -- 1227
	end -- 1227
	if maxTokens == nil then -- 1227
		maxTokens = MEMORY_CONTEXT_DEFAULT_MAX_TOKENS -- 1227
	end -- 1227
	local budget = math.max( -- 1228
		MEMORY_CONTEXT_MIN_MAX_TOKENS, -- 1228
		math.floor(maxTokens) -- 1228
	) -- 1228
	local coreBudget = math.floor(budget * 0.3) -- 1229
	local projectBudget = math.floor(budget * 0.35) -- 1230
	local sessionBudget = math.floor(budget * 0.2) -- 1231
	local subAgentBudget = math.max(0, budget - coreBudget - projectBudget - sessionBudget - 160) -- 1232
	local sections = {} -- 1233
	local core = formatMemoryLayer( -- 1234
		"Core Memory", -- 1234
		selectRelevantMemoryText( -- 1234
			self:readMemory(), -- 1234
			query, -- 1234
			coreBudget -- 1234
		) -- 1234
	) -- 1234
	if core ~= "" then -- 1234
		sections[#sections + 1] = core -- 1235
	end -- 1235
	local project = formatMemoryLayer( -- 1236
		"Project Memory", -- 1236
		selectRelevantMemoryText( -- 1236
			self:readProjectMemory(), -- 1236
			query, -- 1236
			projectBudget -- 1236
		) -- 1236
	) -- 1236
	if project ~= "" then -- 1236
		sections[#sections + 1] = project -- 1237
	end -- 1237
	local session = formatMemoryLayer( -- 1238
		"Session Summary", -- 1238
		selectRelevantMemoryText( -- 1238
			self:readSessionSummary(), -- 1238
			query, -- 1238
			sessionBudget -- 1238
		) -- 1238
	) -- 1238
	if session ~= "" then -- 1238
		sections[#sections + 1] = session -- 1239
	end -- 1239
	local subAgentLearnings = self:buildSubAgentLearningsContext() -- 1240
	if subAgentLearnings ~= "" then -- 1240
		sections[#sections + 1] = formatMemoryLayer( -- 1242
			"Sub-Agent Learnings", -- 1242
			clipTextToTokenBudget(subAgentLearnings, subAgentBudget > 0 and subAgentBudget or MEMORY_LAYER_MIN_TOKENS) -- 1242
		) -- 1242
	end -- 1242
	if #sections == 0 then -- 1242
		return "" -- 1244
	end -- 1244
	local output = "### Relevant Memory\n\n" .. table.concat(sections, "\n\n") -- 1245
	return ____exports.TokenEstimator:estimate(output) > budget and clipTextToTokenBudget(output, budget) or output -- 1246
end -- 1227
function DualLayerStorage.prototype.getMemoryContext(self, query, maxTokens) -- 1252
	if query == nil then -- 1252
		query = "" -- 1252
	end -- 1252
	if maxTokens == nil then -- 1252
		maxTokens = MEMORY_CONTEXT_DEFAULT_MAX_TOKENS -- 1252
	end -- 1252
	return self:getRelevantMemoryContext(query, maxTokens) -- 1253
end -- 1252
function DualLayerStorage.prototype.appendHistoryRecord(self, record) -- 1258
	local records = self:readHistoryRecords() -- 1259
	records[#records + 1] = record -- 1260
	self:saveHistoryRecords(records) -- 1261
end -- 1258
function DualLayerStorage.prototype.readSessionState(self) -- 1264
	if not Content:exist(self.sessionPath) then -- 1264
		return {messages = {}, lastConsolidatedIndex = 0} -- 1266
	end -- 1266
	local text = Content:load(self.sessionPath) -- 1268
	if not text or __TS__StringTrim(text) == "" then -- 1268
		return {messages = {}, lastConsolidatedIndex = 0} -- 1270
	end -- 1270
	local lines = __TS__StringSplit(text, "\n") -- 1272
	local messages = {} -- 1273
	local lastConsolidatedIndex = 0 -- 1274
	local carryMessageIndex = nil -- 1275
	do -- 1275
		local i = 0 -- 1276
		while i < #lines do -- 1276
			do -- 1276
				local line = __TS__StringTrim(lines[i + 1]) -- 1277
				if line == "" then -- 1277
					goto __continue210 -- 1278
				end -- 1278
				local data = self:decodeJsonLine(line) -- 1279
				if not data or isArray(data) or not isRecord(data) then -- 1279
					goto __continue210 -- 1280
				end -- 1280
				local row = data -- 1281
				if type(row.lastConsolidatedIndex) == "number" then -- 1281
					lastConsolidatedIndex = math.floor(row.lastConsolidatedIndex) -- 1283
					if type(row.carryMessageIndex) == "number" then -- 1283
						carryMessageIndex = math.floor(row.carryMessageIndex) -- 1285
					end -- 1285
					goto __continue210 -- 1287
				end -- 1287
				local ____self_decodeConversationMessage_2 = self.decodeConversationMessage -- 1289
				local ____row_message_1 = row.message -- 1289
				if ____row_message_1 == nil then -- 1289
					____row_message_1 = row -- 1289
				end -- 1289
				local message = ____self_decodeConversationMessage_2(self, ____row_message_1) -- 1289
				if message ~= nil then -- 1289
					messages[#messages + 1] = message -- 1291
				end -- 1291
			end -- 1291
			::__continue210:: -- 1291
			i = i + 1 -- 1276
		end -- 1276
	end -- 1276
	local normalizedLastConsolidatedIndex = clampSessionIndex(messages, lastConsolidatedIndex) -- 1294
	local normalizedCarryMessageIndex = type(carryMessageIndex) == "number" and carryMessageIndex >= 0 and carryMessageIndex < normalizedLastConsolidatedIndex and carryMessageIndex < #messages and math.floor(carryMessageIndex) or nil -- 1295
	return {messages = messages, lastConsolidatedIndex = normalizedLastConsolidatedIndex, carryMessageIndex = normalizedCarryMessageIndex} -- 1301
end -- 1264
function DualLayerStorage.prototype.writeSessionState(self, messages, lastConsolidatedIndex, carryMessageIndex) -- 1308
	if messages == nil then -- 1308
		messages = {} -- 1309
	end -- 1309
	if lastConsolidatedIndex == nil then -- 1309
		lastConsolidatedIndex = 0 -- 1310
	end -- 1310
	self:ensureDir(Path:getPath(self.sessionPath)) -- 1313
	local lines = {} -- 1314
	local dropCount = #messages > SESSION_MAX_RECORDS and #messages - SESSION_MAX_RECORDS or 0 -- 1315
	local normalizedMessages = dropCount > 0 and __TS__ArraySlice(messages, dropCount) or messages -- 1318
	local normalizedLastConsolidatedIndex = clampSessionIndex(normalizedMessages, lastConsolidatedIndex - dropCount) -- 1321
	local normalizedCarryMessageIndex = type(carryMessageIndex) == "number" and carryMessageIndex - dropCount >= 0 and carryMessageIndex - dropCount < normalizedLastConsolidatedIndex and carryMessageIndex - dropCount < #normalizedMessages and math.floor(carryMessageIndex - dropCount) or nil -- 1325
	local stateLine = self:encodeJsonLine({lastConsolidatedIndex = normalizedLastConsolidatedIndex, carryMessageIndex = normalizedCarryMessageIndex}) -- 1331
	if type(stateLine) == "string" and stateLine ~= "" then -- 1331
		lines[#lines + 1] = stateLine -- 1336
	end -- 1336
	do -- 1336
		local i = 0 -- 1338
		while i < #normalizedMessages do -- 1338
			local line = self:encodeJsonLine({message = normalizedMessages[i + 1]}) -- 1339
			if type(line) == "string" and line ~= "" then -- 1339
				lines[#lines + 1] = line -- 1343
			end -- 1343
			i = i + 1 -- 1338
		end -- 1338
	end -- 1338
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 1346
	Content:save(self.sessionPath, content) -- 1347
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 1348
end -- 1308
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 1360
local MemoryCompressor = ____exports.MemoryCompressor -- 1360
MemoryCompressor.name = "MemoryCompressor" -- 1360
function MemoryCompressor.prototype.____constructor(self, config) -- 1367
	self.consecutiveFailures = 0 -- 1363
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 1368
	do -- 1368
		local i = 0 -- 1369
		while i < #loadedPromptPack.warnings do -- 1369
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 1370
			i = i + 1 -- 1369
		end -- 1369
	end -- 1369
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 1372
	self.config = __TS__ObjectAssign( -- 1375
		{}, -- 1375
		config, -- 1376
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 1375
	) -- 1375
	self.config.compressionThreshold = math.min( -- 1382
		1, -- 1382
		math.max(0.05, self.config.compressionThreshold) -- 1382
	) -- 1382
	self.config.compressionTargetThreshold = math.min( -- 1383
		self.config.compressionThreshold, -- 1384
		math.max(0.05, self.config.compressionTargetThreshold) -- 1385
	) -- 1385
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir, self.config.scope or "") -- 1387
end -- 1367
function MemoryCompressor.prototype.getPromptPack(self) -- 1390
	return self.config.promptPack -- 1391
end -- 1390
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 1397
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1402
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 1408
	return messageTokens > threshold -- 1410
end -- 1397
function MemoryCompressor.prototype.compress(self, messages, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode, systemPrompt, toolDefinitions) -- 1416
	if decisionMode == nil then -- 1416
		decisionMode = "tool_calling" -- 1420
	end -- 1420
	if boundaryMode == nil then -- 1420
		boundaryMode = "default" -- 1422
	end -- 1422
	if systemPrompt == nil then -- 1422
		systemPrompt = "" -- 1423
	end -- 1423
	if toolDefinitions == nil then -- 1423
		toolDefinitions = "" -- 1424
	end -- 1424
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1424
		local toCompress = messages -- 1426
		if #toCompress == 0 then -- 1426
			return ____awaiter_resolve(nil, nil) -- 1426
		end -- 1426
		local currentMemory = self.storage:readMemory() -- 1428
		local boundary = self:findCompressionBoundary( -- 1430
			toCompress, -- 1431
			currentMemory, -- 1432
			boundaryMode, -- 1433
			systemPrompt, -- 1434
			toolDefinitions -- 1435
		) -- 1435
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 1437
		if #chunk == 0 then -- 1437
			return ____awaiter_resolve(nil, nil) -- 1437
		end -- 1437
		local historyText = self:formatMessagesForCompression(chunk) -- 1440
		local ____try = __TS__AsyncAwaiter(function() -- 1440
			local result = __TS__Await(self:callLLMForCompression( -- 1444
				currentMemory, -- 1445
				historyText, -- 1446
				llmOptions, -- 1447
				maxLLMTry or 3, -- 1448
				decisionMode, -- 1449
				debugContext -- 1450
			)) -- 1450
			if result.success then -- 1450
				self.storage:writeMemory(result.memoryUpdate) -- 1455
				if type(result.projectMemoryUpdate) == "string" then -- 1455
					self.storage:writeProjectMemory(result.projectMemoryUpdate) -- 1457
				end -- 1457
				if type(result.sessionSummaryUpdate) == "string" then -- 1457
					self.storage:writeSessionSummary(result.sessionSummaryUpdate) -- 1460
				end -- 1460
				if result.ts then -- 1460
					self.storage:appendHistoryRecord({ts = result.ts, summary = result.summary}) -- 1463
				end -- 1463
				self.consecutiveFailures = 0 -- 1468
				return ____awaiter_resolve( -- 1468
					nil, -- 1468
					__TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessageIndex = boundary.carryMessageIndex}) -- 1470
				) -- 1470
			end -- 1470
			return ____awaiter_resolve( -- 1470
				nil, -- 1470
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 1478
			) -- 1478
		end) -- 1478
		__TS__Await(____try.catch( -- 1442
			____try, -- 1442
			function(____, ____error) -- 1442
				return ____awaiter_resolve( -- 1442
					nil, -- 1442
					self:handleCompressionFailure( -- 1481
						chunk, -- 1481
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 1481
					) -- 1481
				) -- 1481
			end -- 1481
		)) -- 1481
	end) -- 1481
end -- 1416
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode, systemPrompt, toolDefinitions) -- 1490
	local targetTokens = boundaryMode == "budget_max" and math.max( -- 1497
		1, -- 1498
		self:getCompressionHistoryTokenBudget(currentMemory) -- 1498
	) or math.max( -- 1498
		1, -- 1499
		self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 1499
	) -- 1499
	local accumulatedTokens = 0 -- 1500
	local lastSafeBoundary = 0 -- 1501
	local lastSafeBoundaryWithinBudget = 0 -- 1502
	local lastClosedBoundary = 0 -- 1503
	local lastClosedBoundaryWithinBudget = 0 -- 1504
	local pendingToolCalls = {} -- 1505
	local pendingToolCallCount = 0 -- 1506
	local exceededBudget = false -- 1507
	do -- 1507
		local i = 0 -- 1509
		while i < #messages do -- 1509
			local message = messages[i + 1] -- 1510
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 1511
			accumulatedTokens = accumulatedTokens + tokens -- 1512
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1512
				do -- 1512
					local j = 0 -- 1515
					while j < #message.tool_calls do -- 1515
						local toolCallEntry = message.tool_calls[j + 1] -- 1516
						local idValue = toolCallEntry.id -- 1517
						local id = type(idValue) == "string" and idValue or "" -- 1518
						if id ~= "" and not pendingToolCalls[id] then -- 1518
							pendingToolCalls[id] = true -- 1520
							pendingToolCallCount = pendingToolCallCount + 1 -- 1521
						end -- 1521
						j = j + 1 -- 1515
					end -- 1515
				end -- 1515
			end -- 1515
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 1515
				pendingToolCalls[message.tool_call_id] = false -- 1527
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 1528
			end -- 1528
			local isAtEnd = i >= #messages - 1 -- 1531
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 1532
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 1533
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 1534
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 1535
			if isSafeBoundary then -- 1535
				lastSafeBoundary = i + 1 -- 1537
				if accumulatedTokens <= targetTokens then -- 1537
					lastSafeBoundaryWithinBudget = i + 1 -- 1539
				end -- 1539
			end -- 1539
			if isClosedToolBoundary then -- 1539
				lastClosedBoundary = i + 1 -- 1543
				if accumulatedTokens <= targetTokens then -- 1543
					lastClosedBoundaryWithinBudget = i + 1 -- 1545
				end -- 1545
			end -- 1545
			if accumulatedTokens > targetTokens and not exceededBudget then -- 1545
				exceededBudget = true -- 1550
			end -- 1550
			if exceededBudget and isSafeBoundary then -- 1550
				return self:buildCarryBoundary(messages, i + 1) -- 1555
			end -- 1555
			i = i + 1 -- 1509
		end -- 1509
	end -- 1509
	if lastSafeBoundaryWithinBudget > 0 then -- 1509
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 1560
	end -- 1560
	if lastSafeBoundary > 0 then -- 1560
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 1563
	end -- 1563
	if lastClosedBoundaryWithinBudget > 0 then -- 1563
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 1566
	end -- 1566
	if lastClosedBoundary > 0 then -- 1566
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 1569
	end -- 1569
	local fallback = math.min(#messages, 1) -- 1571
	return {chunkEnd = fallback, compressedCount = fallback} -- 1572
end -- 1490
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 1575
	local carryUserIndex = -1 -- 1576
	do -- 1576
		local i = 0 -- 1577
		while i < chunkEnd do -- 1577
			if messages[i + 1].role == "user" then -- 1577
				carryUserIndex = i -- 1579
			end -- 1579
			i = i + 1 -- 1577
		end -- 1577
	end -- 1577
	if carryUserIndex < 0 then -- 1577
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 1583
	end -- 1583
	return {chunkEnd = chunkEnd, compressedCount = chunkEnd, carryMessageIndex = carryUserIndex} -- 1585
end -- 1575
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 1592
	local lines = {} -- 1593
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 1594
	if message.name and message.name ~= "" then -- 1594
		lines[#lines + 1] = "name=" .. message.name -- 1595
	end -- 1595
	if message.tool_call_id and message.tool_call_id ~= "" then -- 1595
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1596
	end -- 1596
	if message.reasoning_content and message.reasoning_content ~= "" then -- 1596
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1597
	end -- 1597
	if message.tool_calls and #message.tool_calls > 0 then -- 1597
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 1599
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1600
	end -- 1600
	if message.content and message.content ~= "" then -- 1600
		lines[#lines + 1] = message.content -- 1602
	end -- 1602
	local prefix = index > 0 and "\n\n" or "" -- 1603
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 1604
end -- 1592
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages, systemPrompt, toolDefinitions) -- 1607
	local currentTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1612
	local threshold = self:getContextWindow() * self.config.compressionTargetThreshold -- 1617
	local overflow = math.max(0, currentTokens - threshold) -- 1618
	if overflow <= 0 then -- 1618
		return math.max( -- 1620
			1, -- 1620
			self:estimateCompressionMessageTokens(messages[1], 0) -- 1620
		) -- 1620
	end -- 1620
	local safetyMargin = math.max( -- 1622
		64, -- 1622
		math.floor(threshold * 0.01) -- 1622
	) -- 1622
	return overflow + safetyMargin -- 1623
end -- 1607
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1626
	local lines = {} -- 1627
	do -- 1627
		local i = 0 -- 1628
		while i < #messages do -- 1628
			local message = messages[i + 1] -- 1629
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1630
			if message.name and message.name ~= "" then -- 1630
				lines[#lines + 1] = "name=" .. message.name -- 1631
			end -- 1631
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1631
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1632
			end -- 1632
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1632
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1633
			end -- 1633
			if message.tool_calls and #message.tool_calls > 0 then -- 1633
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1635
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1636
			end -- 1636
			if message.content and message.content ~= "" then -- 1636
				lines[#lines + 1] = message.content -- 1638
			end -- 1638
			if i < #messages - 1 then -- 1638
				lines[#lines + 1] = "" -- 1639
			end -- 1639
			i = i + 1 -- 1628
		end -- 1628
	end -- 1628
	return table.concat(lines, "\n") -- 1641
end -- 1626
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1647
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1647
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1655
		if decisionMode == "xml" then -- 1655
			return ____awaiter_resolve( -- 1655
				nil, -- 1655
				self:callLLMForCompressionByXML( -- 1657
					currentMemory, -- 1658
					boundedHistoryText, -- 1659
					llmOptions, -- 1660
					maxLLMTry, -- 1661
					debugContext -- 1662
				) -- 1662
			) -- 1662
		end -- 1662
		return ____awaiter_resolve( -- 1662
			nil, -- 1662
			self:callLLMForCompressionByToolCalling( -- 1665
				currentMemory, -- 1666
				boundedHistoryText, -- 1667
				llmOptions, -- 1668
				maxLLMTry, -- 1669
				debugContext -- 1670
			) -- 1670
		) -- 1670
	end) -- 1670
end -- 1647
function MemoryCompressor.prototype.getContextWindow(self) -- 1674
	return math.max(MEMORY_DEFAULT_CONTEXT_WINDOW, self.config.llmConfig.contextWindow) -- 1675
end -- 1674
function MemoryCompressor.prototype.getMemoryContextBudget(self) -- 1678
	local contextWindow = math.max(MEMORY_DEFAULT_CONTEXT_WINDOW, self.config.llmConfig.contextWindow) -- 1679
	return math.max( -- 1680
		AGENT_MEMORY_CONTEXT_MIN_TOKENS, -- 1681
		math.floor(contextWindow * AGENT_MEMORY_CONTEXT_WINDOW_RATIO) -- 1682
	) -- 1682
end -- 1678
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1686
	local contextWindow = self:getContextWindow() -- 1687
	local reservedOutputTokens = math.max( -- 1688
		COMPRESSION_RESERVED_OUTPUT_MIN_TOKENS, -- 1689
		math.floor(contextWindow * COMPRESSION_RESERVED_OUTPUT_CONTEXT_RATIO) -- 1690
	) -- 1690
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1692
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1693
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1694
	return math.max( -- 1695
		COMPRESSION_HISTORY_MIN_TOKENS, -- 1696
		math.floor(available * COMPRESSION_HISTORY_AVAILABLE_RATIO) -- 1697
	) -- 1697
end -- 1686
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1701
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1702
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1703
	if historyTokens <= tokenBudget then -- 1703
		return historyText -- 1704
	end -- 1704
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1705
	local targetChars = math.max( -- 1708
		COMPRESSION_HISTORY_TRUNCATED_MIN_CHARS, -- 1709
		math.floor(tokenBudget * charsPerToken) -- 1710
	) -- 1710
	local keepHead = math.max( -- 1712
		0, -- 1712
		math.floor(targetChars * COMPRESSION_HISTORY_TRUNCATED_HEAD_RATIO) -- 1712
	) -- 1712
	local keepTail = math.max(0, targetChars - keepHead) -- 1713
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1714
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1715
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1716
end -- 1701
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1719
	local contextWindow = self:getContextWindow() -- 1725
	local reservedOutputTokens = math.max( -- 1726
		COMPRESSION_RESERVED_OUTPUT_MIN_TOKENS, -- 1727
		math.floor(contextWindow * COMPRESSION_RESERVED_OUTPUT_CONTEXT_RATIO) -- 1728
	) -- 1728
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1730
	local dynamicBudget = math.max(COMPRESSION_DYNAMIC_MIN_TOKENS, contextWindow - reservedOutputTokens - staticPromptTokens - COMPRESSION_DYNAMIC_PROMPT_OVERHEAD_TOKENS) -- 1731
	local boundedMemory = clipTextToTokenBudget( -- 1735
		currentMemory or "(empty)", -- 1735
		math.max( -- 1735
			COMPRESSION_SECTION_MEMORY_MIN_TOKENS, -- 1736
			math.floor(dynamicBudget * COMPRESSION_SECTION_MEMORY_RATIO) -- 1737
		) -- 1737
	) -- 1737
	local boundedProjectMemory = clipTextToTokenBudget( -- 1739
		self.storage:readProjectMemory() or "(empty)", -- 1739
		math.max( -- 1739
			COMPRESSION_SECTION_MEMORY_MIN_TOKENS, -- 1740
			math.floor(dynamicBudget * COMPRESSION_SECTION_MEMORY_RATIO) -- 1741
		) -- 1741
	) -- 1741
	local boundedSessionSummary = clipTextToTokenBudget( -- 1743
		self.storage:readSessionSummary() or "(empty)", -- 1743
		math.max( -- 1743
			COMPRESSION_SECTION_SESSION_MIN_TOKENS, -- 1744
			math.floor(dynamicBudget * COMPRESSION_SECTION_SESSION_RATIO) -- 1745
		) -- 1745
	) -- 1745
	local boundedHistory = clipTextToTokenBudget( -- 1747
		historyText, -- 1747
		math.max( -- 1747
			COMPRESSION_SECTION_HISTORY_MIN_TOKENS, -- 1748
			math.floor(dynamicBudget * COMPRESSION_SECTION_HISTORY_RATIO) -- 1749
		) -- 1749
	) -- 1749
	return {currentMemory = boundedMemory, currentProjectMemory = boundedProjectMemory, currentSessionSummary = boundedSessionSummary, historyText = boundedHistory} -- 1751
end -- 1719
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1759
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1759
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1766
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated MEMORY.md as markdown. Core memory only: user preferences, stable facts, decisions, known issues."}, project_memory_update = {type = "string", description = "Full updated PROJECT_MEMORY.md as markdown. Project facts, build/run, files/architecture, project decisions and issues."}, session_summary_update = {type = "string", description = "Full updated SESSION_SUMMARY.md as markdown. Current goal, recent progress, and open issues for this session."}}, required = {"history_entry", "memory_update"}}}}} -- 1769
		local messages = { -- 1800
			{ -- 1801
				role = "system", -- 1802
				content = self:buildToolCallingCompressionSystemPrompt() -- 1803
			}, -- 1803
			{role = "user", content = prompt} -- 1805
		} -- 1805
		local fn -- 1811
		local argsText = "" -- 1812
		do -- 1812
			local i = 0 -- 1813
			while i < maxLLMTry do -- 1813
				local requestOptions = __TS__ObjectAssign({}, llmOptions, {tools = tools}) -- 1814
				requestOptions.tool_choice = nil -- 1818
				local ____opt_3 = debugContext and debugContext.onInput -- 1814
				if ____opt_3 ~= nil then -- 1814
					____opt_3(debugContext, "memory_compression_tool_calling", messages, requestOptions) -- 1818
				end -- 1818
				local response = __TS__Await(callLLM(messages, requestOptions, nil, self.config.llmConfig)) -- 1820
				if not response.success then -- 1820
					local ____opt_7 = debugContext and debugContext.onOutput -- 1820
					if ____opt_7 ~= nil then -- 1820
						____opt_7(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false}) -- 1828
					end -- 1828
					return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1828
				end -- 1828
				local ____opt_11 = debugContext and debugContext.onOutput -- 1828
				if ____opt_11 ~= nil then -- 1828
					____opt_11( -- 1836
						debugContext, -- 1836
						"memory_compression_tool_calling", -- 1836
						encodeCompressionDebugJSON(response.response), -- 1836
						{success = true} -- 1836
					) -- 1836
				end -- 1836
				local choice = response.response.choices and response.response.choices[1] -- 1838
				local message = choice and choice.message -- 1839
				local toolCalls = message and message.tool_calls -- 1840
				local toolCall = toolCalls and toolCalls[1] -- 1841
				fn = toolCall and toolCall["function"] -- 1842
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1843
				if fn ~= nil and #argsText > 0 then -- 1843
					break -- 1844
				end -- 1844
				i = i + 1 -- 1813
			end -- 1813
		end -- 1813
		if not fn or fn.name ~= "save_memory" then -- 1813
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing save_memory tool call"}) -- 1813
		end -- 1813
		if __TS__StringTrim(argsText) == "" then -- 1813
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "empty save_memory tool arguments"}) -- 1813
		end -- 1813
		local ____try = __TS__AsyncAwaiter(function() -- 1813
			local args, err = safeJsonDecode(argsText) -- 1867
			if err ~= nil or not args or type(args) ~= "table" then -- 1867
				return ____awaiter_resolve( -- 1867
					nil, -- 1867
					{ -- 1869
						success = false, -- 1870
						memoryUpdate = currentMemory, -- 1871
						compressedCount = 0, -- 1872
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1873
					} -- 1873
				) -- 1873
			end -- 1873
			return ____awaiter_resolve( -- 1873
				nil, -- 1873
				self:buildCompressionResultFromObject(args, currentMemory) -- 1877
			) -- 1877
		end) -- 1877
		__TS__Await(____try.catch( -- 1866
			____try, -- 1866
			function(____, ____error) -- 1866
				return ____awaiter_resolve( -- 1866
					nil, -- 1866
					{ -- 1882
						success = false, -- 1883
						memoryUpdate = currentMemory, -- 1884
						compressedCount = 0, -- 1885
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1886
					} -- 1886
				) -- 1886
			end -- 1886
		)) -- 1886
	end) -- 1886
end -- 1759
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1891
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1891
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1898
		local lastError = "invalid xml response" -- 1899
		do -- 1899
			local i = 0 -- 1901
			while i < maxLLMTry do -- 1901
				do -- 1901
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1902
					local requestMessages = { -- 1907
						{ -- 1908
							role = "system", -- 1908
							content = self:buildXMLCompressionSystemPrompt() -- 1908
						}, -- 1908
						{role = "user", content = prompt .. feedback} -- 1909
					} -- 1909
					local ____opt_15 = debugContext and debugContext.onInput -- 1909
					if ____opt_15 ~= nil then -- 1909
						____opt_15(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1911
					end -- 1911
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1912
					if not response.success then -- 1912
						local ____opt_19 = debugContext and debugContext.onOutput -- 1912
						if ____opt_19 ~= nil then -- 1912
							____opt_19(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1920
						end -- 1920
						return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1920
					end -- 1920
					local choice = response.response.choices and response.response.choices[1] -- 1929
					local message = choice and choice.message -- 1930
					local text = message and type(message.content) == "string" and message.content or "" -- 1931
					local ____opt_23 = debugContext and debugContext.onOutput -- 1931
					if ____opt_23 ~= nil then -- 1931
						____opt_23( -- 1932
							debugContext, -- 1932
							"memory_compression_xml", -- 1932
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1932
							{success = true} -- 1932
						) -- 1932
					end -- 1932
					if __TS__StringTrim(text) == "" then -- 1932
						lastError = "empty xml response" -- 1934
						goto __continue295 -- 1935
					end -- 1935
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1938
					if parsed.success then -- 1938
						return ____awaiter_resolve(nil, parsed) -- 1938
					end -- 1938
					lastError = parsed.error or "invalid xml response" -- 1942
				end -- 1942
				::__continue295:: -- 1942
				i = i + 1 -- 1901
			end -- 1901
		end -- 1901
		return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = lastError}) -- 1901
	end) -- 1901
end -- 1891
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1956
	return replaceTemplateVars( -- 1957
		self.config.promptPack.memoryCompressionBodyPrompt, -- 1957
		{ -- 1957
			CURRENT_MEMORY = currentMemory or "(empty)", -- 1958
			CURRENT_PROJECT_MEMORY = self.storage:readProjectMemory() or "(empty)", -- 1959
			CURRENT_SESSION_SUMMARY = self.storage:readSessionSummary() or "(empty)", -- 1960
			HISTORY_TEXT = historyText -- 1961
		} -- 1961
	) -- 1961
end -- 1956
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1965
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1966
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, CURRENT_PROJECT_MEMORY = bounded.currentProjectMemory, CURRENT_SESSION_SUMMARY = bounded.currentSessionSummary, HISTORY_TEXT = bounded.historyText}) -- 1967
end -- 1965
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 1975
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 1976
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 1979
end -- 1975
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 1986
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1987
end -- 1986
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 1992
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1993
end -- 1992
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1998
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1999
	if not parsed.success then -- 1999
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = parsed.message} -- 2001
	end -- 2001
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 2008
end -- 1998
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 2014
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 2018
	local memoryBody = type(obj.memory_update) == "string" and __TS__StringTrim(obj.memory_update) ~= "" and obj.memory_update or currentMemory -- 2019
	local projectMemoryBody = type(obj.project_memory_update) == "string" and __TS__StringTrim(obj.project_memory_update) ~= "" and obj.project_memory_update or self.storage:readProjectMemory() -- 2022
	local sessionSummaryBody = type(obj.session_summary_update) == "string" and __TS__StringTrim(obj.session_summary_update) ~= "" and obj.session_summary_update or self.storage:readSessionSummary() -- 2025
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 2025
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing history_entry or memory_update"} -- 2029
	end -- 2029
	local ts = os.date("%Y-%m-%d %H:%M") -- 2036
	return { -- 2037
		success = true, -- 2038
		memoryUpdate = memoryBody, -- 2039
		projectMemoryUpdate = projectMemoryBody, -- 2040
		sessionSummaryUpdate = sessionSummaryBody, -- 2041
		ts = ts, -- 2042
		summary = historyEntry, -- 2043
		compressedCount = 0 -- 2044
	} -- 2044
end -- 2014
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 2051
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 2055
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 2055
		local archived = self:rawArchive(chunk) -- 2058
		self.consecutiveFailures = 0 -- 2059
		return { -- 2061
			success = true, -- 2062
			memoryUpdate = self.storage:readMemory(), -- 2063
			ts = archived.ts, -- 2064
			compressedCount = #chunk -- 2065
		} -- 2065
	end -- 2065
	return { -- 2069
		success = false, -- 2070
		memoryUpdate = self.storage:readMemory(), -- 2071
		compressedCount = 0, -- 2072
		error = ____error -- 2073
	} -- 2073
end -- 2051
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 2080
	local ts = os.date("%Y-%m-%d %H:%M") -- 2081
	local rawArchive = self:formatMessagesForCompression(chunk) -- 2082
	self.storage:appendHistoryRecord({ts = ts, rawArchive = rawArchive}) -- 2083
	return {ts = ts} -- 2087
end -- 2080
function MemoryCompressor.prototype.getStorage(self) -- 2093
	return self.storage -- 2094
end -- 2093
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 2097
	return math.max( -- 2098
		1, -- 2098
		math.floor(self.config.maxCompressionRounds) -- 2098
	) -- 2098
end -- 2097
MemoryCompressor.MAX_FAILURES = 3 -- 2097
function ____exports.compactSessionMemoryScope(options) -- 2102
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2102
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2111
		if not llmConfigRes.success then -- 2111
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2111
		end -- 2111
		local compressor = __TS__New(____exports.MemoryCompressor, { -- 2117
			compressionThreshold = 0.8, -- 2118
			compressionTargetThreshold = 0.5, -- 2119
			maxCompressionRounds = 3, -- 2120
			projectDir = options.projectDir, -- 2121
			llmConfig = llmConfigRes.config, -- 2122
			promptPack = options.promptPack, -- 2123
			scope = options.scope -- 2124
		}) -- 2124
		local storage = compressor:getStorage() -- 2126
		local persistedSession = storage:readSessionState() -- 2127
		local messages = persistedSession.messages -- 2128
		local lastConsolidatedIndex = persistedSession.lastConsolidatedIndex -- 2129
		local carryMessageIndex = persistedSession.carryMessageIndex -- 2130
		local llmOptions = buildMemoryLLMOptions(llmConfigRes.config, options.llmOptions) -- 2131
		while lastConsolidatedIndex < #messages do -- 2131
			local activeMessages = {} -- 2133
			if type(carryMessageIndex) == "number" and carryMessageIndex >= 0 and carryMessageIndex < lastConsolidatedIndex and carryMessageIndex < #messages then -- 2133
				activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, messages[carryMessageIndex + 1]) -- 2140
			end -- 2140
			do -- 2140
				local i = lastConsolidatedIndex -- 2144
				while i < #messages do -- 2144
					activeMessages[#activeMessages + 1] = messages[i + 1] -- 2145
					i = i + 1 -- 2144
				end -- 2144
			end -- 2144
			local result = __TS__Await(compressor:compress( -- 2147
				activeMessages, -- 2148
				llmOptions, -- 2149
				math.max( -- 2150
					1, -- 2150
					math.floor(options.llmMaxTry or 5) -- 2150
				), -- 2150
				options.decisionMode or "tool_calling", -- 2151
				nil, -- 2152
				"budget_max" -- 2153
			)) -- 2153
			if not (result and result.success and result.compressedCount > 0) then -- 2153
				return ____awaiter_resolve(nil, {success = false, message = result and result.error or "memory compaction produced no progress"}) -- 2153
			end -- 2153
			local syntheticPrefixCount = #activeMessages > 0 and lastConsolidatedIndex < #messages and activeMessages[1] ~= messages[lastConsolidatedIndex + 1] and 1 or 0 -- 2161
			local realCompressedCount = math.max(0, result.compressedCount - syntheticPrefixCount) -- 2166
			lastConsolidatedIndex = math.min(#messages, lastConsolidatedIndex + realCompressedCount) -- 2167
			if type(result.carryMessageIndex) == "number" then -- 2167
				if syntheticPrefixCount > 0 and result.carryMessageIndex == 0 then -- 2167
				else -- 2167
					local carryOffset = syntheticPrefixCount > 0 and result.carryMessageIndex - 1 or result.carryMessageIndex -- 2172
					carryMessageIndex = carryOffset >= 0 and lastConsolidatedIndex - realCompressedCount + carryOffset or nil -- 2175
				end -- 2175
			else -- 2175
				carryMessageIndex = nil -- 2180
			end -- 2180
			if type(carryMessageIndex) == "number" and (carryMessageIndex < 0 or carryMessageIndex >= lastConsolidatedIndex or carryMessageIndex >= #messages) then -- 2180
				carryMessageIndex = nil -- 2186
			end -- 2186
			storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2188
		end -- 2188
		return ____awaiter_resolve(nil, {success = true, remainingMessages = #messages - lastConsolidatedIndex}) -- 2188
	end) -- 2188
end -- 2102
return ____exports -- 2102