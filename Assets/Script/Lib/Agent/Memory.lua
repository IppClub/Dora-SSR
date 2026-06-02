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
	"replyLanguageDirectiveZh", -- 427
	"replyLanguageDirectiveEn" -- 428
} -- 428
local INTERNAL_PROMPT_PACK_KEYS = { -- 431
	"functionCallingPrompt", -- 432
	"toolDefinitionsDetailed", -- 433
	"toolCallingRetryPrompt", -- 434
	"xmlDecisionFormatPrompt", -- 435
	"xmlDecisionRepairPrompt", -- 436
	"xmlDecisionSystemRepairPrompt", -- 437
	"memoryCompressionSystemPrompt", -- 438
	"memoryCompressionBodyPrompt", -- 439
	"memoryCompressionToolCallingPrompt", -- 440
	"memoryCompressionXmlPrompt", -- 441
	"memoryCompressionXmlRetryPrompt" -- 442
} -- 442
local function replaceTemplateVars(template, vars) -- 445
	local output = template -- 446
	for key in pairs(vars) do -- 447
		output = table.concat( -- 448
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 448
			vars[key] or "" or "," -- 448
		) -- 448
	end -- 448
	return output -- 450
end -- 445
function ____exports.resolveAgentPromptPack(value) -- 453
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 454
	if value and not isArray(value) and isRecord(value) then -- 454
		do -- 454
			local i = 0 -- 458
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 458
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 459
				if type(value[key]) == "string" then -- 459
					merged[key] = value[key] -- 461
				end -- 461
				i = i + 1 -- 458
			end -- 458
		end -- 458
	end -- 458
	return merged -- 465
end -- 453
function ____exports.renderDefaultAgentPromptPackMarkdown(overrides) -- 468
	local lines = {} -- 469
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 470
	lines[#lines + 1] = "" -- 471
	lines[#lines + 1] = "Edit the content under each `##` heading. Tool-calling and decision-format prompts are kept in code and are not exposed here." -- 472
	lines[#lines + 1] = "" -- 473
	do -- 473
		local i = 0 -- 474
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 474
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 475
			lines[#lines + 1] = ("## `" .. key) .. "`" -- 476
			local text = type(overrides and overrides[key]) == "string" and overrides[key] or ____exports.DEFAULT_AGENT_PROMPT_PACK[key] -- 477
			local split = __TS__StringSplit(text, "\n") -- 480
			do -- 480
				local j = 0 -- 481
				while j < #split do -- 481
					lines[#lines + 1] = split[j + 1] -- 482
					j = j + 1 -- 481
				end -- 481
			end -- 481
			lines[#lines + 1] = "" -- 484
			i = i + 1 -- 474
		end -- 474
	end -- 474
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 486
end -- 468
local function getPromptPackConfigPath(projectRoot) -- 489
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 490
end -- 489
local function ensurePromptPackConfig(projectRoot) -- 493
	local path = getPromptPackConfigPath(projectRoot) -- 494
	if Content:exist(path) then -- 494
		return nil -- 495
	end -- 495
	local dir = Path:getPath(path) -- 496
	if not Content:exist(dir) then -- 496
		Content:mkdir(dir) -- 498
	end -- 498
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 500
	if not Content:save(path, content) then -- 500
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 502
	end -- 502
	sendWebIDEFileUpdate(path, true, content) -- 504
	return nil -- 505
end -- 493
local function rewriteDefaultPromptPackConfig(path, overrides) -- 508
	local content = ____exports.renderDefaultAgentPromptPackMarkdown(overrides) -- 509
	if not Content:save(path, content) then -- 509
		return ("Failed to recreate default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 511
	end -- 511
	sendWebIDEFileUpdate(path, true, content) -- 513
	return nil -- 514
end -- 508
local function parsePromptPackMarkdown(text) -- 517
	if not text or __TS__StringTrim(text) == "" then -- 517
		return { -- 525
			value = {}, -- 526
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 527
			unknown = {}, -- 528
			removed = {} -- 529
		} -- 529
	end -- 529
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 532
	local lines = __TS__StringSplit(normalized, "\n") -- 533
	local sections = {} -- 534
	local unknown = {} -- 535
	local removed = {} -- 536
	local currentHeading = "" -- 537
	local function isKnownPromptPackKey(name) -- 538
		do -- 538
			local i = 0 -- 539
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 539
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 539
					return true -- 540
				end -- 540
				i = i + 1 -- 539
			end -- 539
		end -- 539
		return false -- 542
	end -- 538
	local function isInternalPromptPackKey(name) -- 544
		do -- 544
			local i = 0 -- 545
			while i < #INTERNAL_PROMPT_PACK_KEYS do -- 545
				if INTERNAL_PROMPT_PACK_KEYS[i + 1] == name then -- 545
					return true -- 546
				end -- 546
				i = i + 1 -- 545
			end -- 545
		end -- 545
		return false -- 548
	end -- 544
	do -- 544
		local i = 0 -- 550
		while i < #lines do -- 550
			do -- 550
				local line = lines[i + 1] -- 551
				local matchedHeading = string.match(line, "^##[ \t]+`([^`]+)`[ \t]*$") -- 552
				if matchedHeading ~= nil then -- 552
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 554
					if isKnownPromptPackKey(heading) then -- 554
						currentHeading = heading -- 556
						if sections[currentHeading] == nil then -- 556
							sections[currentHeading] = {} -- 558
						end -- 558
						goto __continue42 -- 560
					end -- 560
					if isInternalPromptPackKey(heading) then -- 560
						currentHeading = "" -- 563
						removed[#removed + 1] = heading -- 564
						goto __continue42 -- 565
					end -- 565
					unknown[#unknown + 1] = heading -- 567
					currentHeading = "" -- 568
					goto __continue42 -- 569
				end -- 569
				if currentHeading ~= "" then -- 569
					local ____sections_currentHeading_2 = sections[currentHeading] -- 569
					____sections_currentHeading_2[#____sections_currentHeading_2 + 1] = line -- 572
				end -- 572
			end -- 572
			::__continue42:: -- 572
			i = i + 1 -- 550
		end -- 550
	end -- 550
	local value = {} -- 575
	local missing = {} -- 576
	do -- 576
		local i = 0 -- 577
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 577
			do -- 577
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 578
				local section = sections[key] -- 579
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 580
				if body == "" then -- 580
					missing[#missing + 1] = key -- 582
					goto __continue49 -- 583
				end -- 583
				value[key] = body -- 585
			end -- 585
			::__continue49:: -- 585
			i = i + 1 -- 577
		end -- 577
	end -- 577
	if #__TS__ObjectKeys(sections) == 0 then -- 577
		return {error = NO_PROMPT_PACK_SECTIONS_ERROR, missing = missing, unknown = unknown, removed = removed} -- 588
	end -- 588
	return {value = value, missing = missing, unknown = unknown, removed = removed} -- 595
end -- 517
function ____exports.loadAgentPromptPack(projectRoot) -- 598
	local path = getPromptPackConfigPath(projectRoot) -- 599
	local warnings = {} -- 600
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 601
	if ensureWarning and ensureWarning ~= "" then -- 601
		warnings[#warnings + 1] = ensureWarning -- 603
	end -- 603
	if not Content:exist(path) then -- 603
		return { -- 606
			pack = ____exports.resolveAgentPromptPack(), -- 607
			warnings = warnings, -- 608
			path = path -- 609
		} -- 609
	end -- 609
	local text = Content:load(path) -- 612
	if not text or __TS__StringTrim(text) == "" then -- 612
		local rewriteWarning = rewriteDefaultPromptPackConfig(path) -- 614
		if rewriteWarning then -- 614
			warnings[#warnings + 1] = rewriteWarning -- 616
		else -- 616
			warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Recreated default prompt config." -- 618
		end -- 618
		return { -- 620
			pack = ____exports.resolveAgentPromptPack(), -- 621
			warnings = warnings, -- 622
			path = path -- 623
		} -- 623
	end -- 623
	local parsed = parsePromptPackMarkdown(text) -- 626
	if parsed.error == NO_PROMPT_PACK_SECTIONS_ERROR then -- 626
		local rewriteWarning = rewriteDefaultPromptPackConfig(path) -- 628
		if rewriteWarning then -- 628
			warnings[#warnings + 1] = rewriteWarning -- 630
		else -- 630
			warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " has no prompt sections. Recreated default prompt config." -- 632
		end -- 632
		return { -- 634
			pack = ____exports.resolveAgentPromptPack(), -- 635
			warnings = warnings, -- 636
			path = path -- 637
		} -- 637
	end -- 637
	if parsed.error or not parsed.value then -- 637
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 641
		return { -- 642
			pack = ____exports.resolveAgentPromptPack(), -- 643
			warnings = warnings, -- 644
			path = path -- 645
		} -- 645
	end -- 645
	if #parsed.unknown > 0 then -- 645
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 649
	end -- 649
	if #parsed.missing > 0 then -- 649
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 652
	end -- 652
	if #parsed.removed > 0 then -- 652
		local rewriteWarning = rewriteDefaultPromptPackConfig(path, parsed.value) -- 655
		if rewriteWarning then -- 655
			warnings[#warnings + 1] = rewriteWarning -- 657
		else -- 657
			warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contained internal tool/system prompt sections and was rewritten without them: ") .. table.concat(parsed.removed, ", ")) .. "." -- 659
		end -- 659
	end -- 659
	return { -- 662
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 663
		warnings = warnings, -- 664
		path = path -- 665
	} -- 665
end -- 598
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 746
local TokenEstimator = ____exports.TokenEstimator -- 746
TokenEstimator.name = "TokenEstimator" -- 746
function TokenEstimator.prototype.____constructor(self) -- 746
end -- 746
function TokenEstimator.estimate(self, text) -- 750
	if text == "" then -- 750
		return 0 -- 751
	end -- 751
	return App:estimateTokens(text) -- 752
end -- 750
function TokenEstimator.estimateMessages(self, messages) -- 755
	if messages == nil or #messages == 0 then -- 755
		return 0 -- 756
	end -- 756
	local total = 0 -- 757
	do -- 757
		local i = 0 -- 758
		while i < #messages do -- 758
			local message = messages[i + 1] -- 759
			total = total + self:estimate(message.role or "") -- 760
			total = total + self:estimate(message.content or "") -- 761
			total = total + self:estimate(message.name or "") -- 762
			total = total + self:estimate(message.tool_call_id or "") -- 763
			total = total + self:estimate(message.reasoning_content or "") -- 764
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 765
			total = total + self:estimate(toolCallsText or "") -- 766
			total = total + 8 -- 767
			i = i + 1 -- 758
		end -- 758
	end -- 758
	return total -- 769
end -- 755
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 772
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 777
end -- 772
local function encodeCompressionDebugJSON(value) -- 785
	local text, err = safeJsonEncode(value) -- 786
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 787
end -- 785
local function utf8TakeHead(text, maxChars) -- 790
	if maxChars <= 0 or text == "" then -- 790
		return "" -- 791
	end -- 791
	local nextPos = utf8.offset(text, maxChars + 1) -- 792
	if nextPos == nil then -- 792
		return text -- 793
	end -- 793
	return string.sub(text, 1, nextPos - 1) -- 794
end -- 790
local function utf8TakeTail(text, maxChars) -- 797
	if maxChars <= 0 or text == "" then -- 797
		return "" -- 798
	end -- 798
	local charLen = utf8.len(text) -- 799
	if charLen == nil or charLen <= maxChars then -- 799
		return text -- 800
	end -- 800
	local startChar = math.max(1, charLen - maxChars + 1) -- 801
	local startPos = utf8.offset(text, startChar) -- 802
	if startPos == nil then -- 802
		return text -- 803
	end -- 803
	return string.sub(text, startPos) -- 804
end -- 797
local function ensureDirRecursive(dir) -- 807
	if not dir or dir == "" then -- 807
		return false -- 808
	end -- 808
	if Content:exist(dir) then -- 808
		return Content:isdir(dir) -- 809
	end -- 809
	local parent = Path:getPath(dir) -- 810
	if parent and parent ~= dir and not Content:exist(parent) then -- 810
		if not ensureDirRecursive(parent) then -- 810
			return false -- 813
		end -- 813
	end -- 813
	return Content:mkdir(dir) -- 816
end -- 807
local function normalizeMemoryFileContent(content, template, importedSectionTitle) -- 819
	local safeContent = type(content) == "string" and sanitizeUTF8(content) or "" -- 820
	local trimmed = __TS__StringTrim(safeContent) -- 821
	if trimmed == "" then -- 821
		return template -- 822
	end -- 822
	if (string.find(trimmed, "\n## ", nil, true) or 0) - 1 >= 0 or (string.find(trimmed, "\n# ", nil, true) or 0) - 1 >= 0 or string.sub(trimmed, 1, 3) == "## " or string.sub(trimmed, 1, 2) == "# " then -- 822
		return safeContent -- 824
	end -- 824
	return ((((__TS__StringTrim(template) .. "\n\n## ") .. importedSectionTitle) .. "\n\n") .. trimmed) .. "\n" -- 826
end -- 819
local function splitMemorySections(text) -- 829
	local sections = {} -- 830
	local lines = __TS__StringSplit( -- 831
		sanitizeUTF8(text or ""), -- 831
		"\n" -- 831
	) -- 831
	local title = "Overview" -- 832
	local bodyLines = {} -- 833
	local index = 0 -- 834
	local function flush() -- 835
		local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 836
		if body ~= "" then -- 836
			local fullText = title == "Overview" and body or (("## " .. title) .. "\n\n") .. body -- 838
			sections[#sections + 1] = { -- 839
				title = title, -- 839
				body = body, -- 839
				fullText = fullText, -- 839
				index = index, -- 839
				score = 0 -- 839
			} -- 839
			index = index + 1 -- 840
		end -- 840
	end -- 835
	do -- 835
		local i = 0 -- 843
		while i < #lines do -- 843
			do -- 843
				local line = lines[i + 1] -- 844
				if string.sub(line, 1, 3) == "## " then -- 844
					flush() -- 846
					title = __TS__StringTrim(string.sub(line, 4)) -- 847
					bodyLines = {} -- 848
				elseif string.sub(line, 1, 2) == "# " then -- 848
					goto __continue95 -- 850
				else -- 850
					bodyLines[#bodyLines + 1] = line -- 852
				end -- 852
			end -- 852
			::__continue95:: -- 852
			i = i + 1 -- 843
		end -- 843
	end -- 843
	flush() -- 855
	return sections -- 856
end -- 829
local function collectQueryTerms(query) -- 859
	local terms = {} -- 860
	local lower = string.lower(sanitizeUTF8(query or "")) -- 861
	local current = "" -- 862
	local function pushCurrent() -- 863
		local word = __TS__StringTrim(current) -- 864
		if #word >= 2 and __TS__ArrayIndexOf(terms, word) < 0 then -- 864
			terms[#terms + 1] = word -- 866
		end -- 866
		current = "" -- 868
	end -- 863
	do -- 863
		local i = 0 -- 870
		while i < #lower do -- 870
			local ch = __TS__StringCharAt(lower, i) -- 871
			local code = __TS__StringCharCodeAt(lower, i) -- 872
			local isAsciiWord = code >= 48 and code <= 57 or code >= 97 and code <= 122 or ch == "_" or ch == "-" or ch == "." -- 873
			if isAsciiWord then -- 873
				current = current .. ch -- 875
			else -- 875
				pushCurrent() -- 877
				if code > 127 and __TS__ArrayIndexOf(terms, ch) < 0 then -- 877
					terms[#terms + 1] = ch -- 878
				end -- 878
			end -- 878
			i = i + 1 -- 870
		end -- 870
	end -- 870
	pushCurrent() -- 881
	return terms -- 882
end -- 859
local function countOccurrences(text, term) -- 885
	if text == "" or term == "" then -- 885
		return 0 -- 886
	end -- 886
	local count = 0 -- 887
	local start = 0 -- 888
	while true do -- 888
		local pos = (string.find( -- 890
			text, -- 890
			term, -- 890
			math.max(start + 1, 1), -- 890
			true -- 890
		) or 0) - 1 -- 890
		if pos < 0 then -- 890
			break -- 891
		end -- 891
		count = count + 1 -- 892
		start = pos + #term -- 893
	end -- 893
	return count -- 895
end -- 885
local function scoreMemorySection(section, terms) -- 898
	local titleLower = string.lower(section.title) -- 899
	local bodyLower = string.lower(section.body) -- 900
	local score = 0 -- 901
	do -- 901
		local i = 0 -- 902
		while i < #terms do -- 902
			local term = terms[i + 1] -- 903
			score = score + countOccurrences(titleLower, term) * 6 -- 904
			score = score + countOccurrences(bodyLower, term) -- 905
			i = i + 1 -- 902
		end -- 902
	end -- 902
	if (string.find(titleLower, "user preference", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "stable fact", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "known decision", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "known issue", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "current goal", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "recent progress", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "build and run", nil, true) or 0) - 1 >= 0 then -- 902
		score = score + (#terms > 0 and 1 or 3) -- 916
	end -- 916
	return score -- 918
end -- 898
local function selectRelevantMemoryText(text, query, maxTokens) -- 921
	local sections = splitMemorySections(text) -- 922
	if #sections == 0 then -- 922
		return "" -- 923
	end -- 923
	local budget = math.max(MEMORY_LAYER_MIN_TOKENS, maxTokens) -- 924
	local terms = collectQueryTerms(query) -- 925
	do -- 925
		local i = 0 -- 926
		while i < #sections do -- 926
			sections[i + 1].score = scoreMemorySection(sections[i + 1], terms) -- 927
			i = i + 1 -- 926
		end -- 926
	end -- 926
	local ranked = __TS__ArraySlice(sections) -- 929
	__TS__ArraySort( -- 930
		ranked, -- 930
		function(____, a, b) -- 930
			if a.score ~= b.score then -- 930
				return b.score - a.score -- 931
			end -- 931
			return a.index - b.index -- 932
		end -- 930
	) -- 930
	local selected = {} -- 934
	local used = 0 -- 935
	do -- 935
		local i = 0 -- 936
		while i < #ranked do -- 936
			do -- 936
				local section = ranked[i + 1] -- 937
				if #terms > 0 and section.score <= 0 then -- 937
					goto __continue122 -- 938
				end -- 938
				local cost = ____exports.TokenEstimator:estimate(section.fullText) + 12 -- 939
				if #selected > 0 and used + cost > budget then -- 939
					goto __continue122 -- 940
				end -- 940
				selected[#selected + 1] = section -- 941
				used = used + cost -- 942
				if used >= budget then -- 942
					break -- 943
				end -- 943
			end -- 943
			::__continue122:: -- 943
			i = i + 1 -- 936
		end -- 936
	end -- 936
	if #selected == 0 then -- 936
		do -- 936
			local i = 0 -- 946
			while i < #sections do -- 946
				do -- 946
					local section = sections[i + 1] -- 947
					local cost = ____exports.TokenEstimator:estimate(section.fullText) + 12 -- 948
					if #selected > 0 and used + cost > budget then -- 948
						goto __continue128 -- 949
					end -- 949
					selected[#selected + 1] = section -- 950
					used = used + cost -- 951
					if used >= budget then -- 951
						break -- 952
					end -- 952
				end -- 952
				::__continue128:: -- 952
				i = i + 1 -- 946
			end -- 946
		end -- 946
	end -- 946
	__TS__ArraySort( -- 955
		selected, -- 955
		function(____, a, b) return a.index - b.index end -- 955
	) -- 955
	return table.concat( -- 956
		__TS__ArrayMap( -- 956
			selected, -- 956
			function(____, section) return section.fullText end -- 956
		), -- 956
		"\n\n" -- 956
	) -- 956
end -- 921
local function formatMemoryLayer(title, content) -- 959
	local trimmed = __TS__StringTrim(sanitizeUTF8(content or "")) -- 960
	if trimmed == "" then -- 960
		return "" -- 961
	end -- 961
	return (("#### " .. title) .. "\n\n") .. trimmed -- 962
end -- 959
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.jsonl (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 970
local DualLayerStorage = ____exports.DualLayerStorage -- 970
DualLayerStorage.name = "DualLayerStorage" -- 970
function DualLayerStorage.prototype.____constructor(self, projectDir, scope) -- 981
	if scope == nil then -- 981
		scope = "" -- 981
	end -- 981
	self.projectDir = projectDir -- 982
	self.scope = scope -- 983
	self.agentRootDir = Path(self.projectDir, ".agent") -- 984
	self.agentDir = scope ~= "" and Path(self.agentRootDir, scope) or self.agentRootDir -- 985
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 988
	self.projectMemoryPath = Path(self.agentDir, "PROJECT_MEMORY.md") -- 989
	self.sessionSummaryPath = Path(self.agentDir, "SESSION_SUMMARY.md") -- 990
	self.historyPath = Path(self.agentDir, HISTORY_JSONL_FILE) -- 991
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 992
	self:ensureAgentFiles() -- 993
end -- 981
function DualLayerStorage.prototype.ensureDir(self, dir) -- 996
	if not Content:exist(dir) then -- 996
		ensureDirRecursive(dir) -- 998
	end -- 998
end -- 996
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 1002
	if Content:exist(path) then -- 1002
		return false -- 1003
	end -- 1003
	self:ensureDir(Path:getPath(path)) -- 1004
	if not Content:save(path, content) then -- 1004
		return false -- 1006
	end -- 1006
	sendWebIDEFileUpdate(path, true, content) -- 1008
	return true -- 1009
end -- 1002
function DualLayerStorage.prototype.ensureStructuredMemoryFile(self, path, template) -- 1012
	if not Content:exist(path) then -- 1012
		self:ensureFile(path, template) -- 1014
		return -- 1015
	end -- 1015
	local current = Content:load(path) -- 1017
	if type(current) ~= "string" or __TS__StringTrim(current) == "" then -- 1017
		Content:save(path, template) -- 1019
		sendWebIDEFileUpdate(path, true, template) -- 1020
	end -- 1020
end -- 1012
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 1024
	self:ensureDir(self.agentRootDir) -- 1025
	self:ensureDir(self.agentDir) -- 1026
	self:ensureStructuredMemoryFile(self.memoryPath, DEFAULT_CORE_MEMORY_TEMPLATE) -- 1027
	self:ensureStructuredMemoryFile(self.projectMemoryPath, DEFAULT_PROJECT_MEMORY_TEMPLATE) -- 1028
	self:ensureStructuredMemoryFile(self.sessionSummaryPath, DEFAULT_SESSION_SUMMARY_TEMPLATE) -- 1029
	self:ensureFile(self.historyPath, "") -- 1030
end -- 1024
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 1033
	local text = safeJsonEncode(value) -- 1034
	return text -- 1035
end -- 1033
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 1038
	local value = safeJsonDecode(text) -- 1039
	return value -- 1040
end -- 1038
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 1043
	if not value or isArray(value) or not isRecord(value) then -- 1043
		return nil -- 1044
	end -- 1044
	local row = value -- 1045
	local role = type(row.role) == "string" and row.role or "" -- 1046
	if role == "" then -- 1046
		return nil -- 1047
	end -- 1047
	local message = {role = role} -- 1048
	if type(row.content) == "string" then -- 1048
		message.content = sanitizeUTF8(row.content) -- 1049
	end -- 1049
	if type(row.name) == "string" then -- 1049
		message.name = sanitizeUTF8(row.name) -- 1050
	end -- 1050
	if type(row.tool_call_id) == "string" then -- 1050
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 1051
	end -- 1051
	if type(row.reasoning_content) == "string" then -- 1051
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 1052
	end -- 1052
	if type(row.timestamp) == "string" then -- 1052
		message.timestamp = sanitizeUTF8(row.timestamp) -- 1053
	end -- 1053
	if isArray(row.tool_calls) then -- 1053
		message.tool_calls = row.tool_calls -- 1055
	end -- 1055
	return message -- 1057
end -- 1043
function DualLayerStorage.prototype.decodeHistoryRecord(self, value) -- 1060
	if not value or isArray(value) or not isRecord(value) then -- 1060
		return nil -- 1061
	end -- 1061
	local row = value -- 1062
	local ts = type(row.ts) == "string" and __TS__StringTrim(row.ts) ~= "" and sanitizeUTF8(row.ts) or "" -- 1063
	local summary = type(row.summary) == "string" and __TS__StringTrim(row.summary) ~= "" and sanitizeUTF8(row.summary) or nil -- 1066
	local rawArchive = type(row.rawArchive) == "string" and __TS__StringTrim(row.rawArchive) ~= "" and sanitizeUTF8(row.rawArchive) or nil -- 1069
	if ts == "" or summary == nil and rawArchive == nil then -- 1069
		return nil -- 1072
	end -- 1072
	local record = {ts = ts, summary = summary, rawArchive = rawArchive} -- 1073
	return record -- 1078
end -- 1060
function DualLayerStorage.prototype.readSpawnInfo(self, path) -- 1081
	if not Content:exist(path) then -- 1081
		return nil -- 1082
	end -- 1082
	local text = Content:load(path) -- 1083
	if not text or __TS__StringTrim(text) == "" then -- 1083
		return nil -- 1084
	end -- 1084
	local value = safeJsonDecode(text) -- 1085
	if value and not isArray(value) and isRecord(value) then -- 1085
		return value -- 1087
	end -- 1087
	return nil -- 1089
end -- 1081
function DualLayerStorage.prototype.normalizeEvidence(self, value) -- 1092
	local evidence = {} -- 1093
	if not isArray(value) then -- 1093
		return evidence -- 1094
	end -- 1094
	do -- 1094
		local i = 0 -- 1095
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1095
			local item = type(value[i + 1]) == "string" and __TS__StringTrim(sanitizeUTF8(value[i + 1])) or "" -- 1096
			if item ~= "" and __TS__ArrayIndexOf(evidence, item) < 0 then -- 1096
				evidence[#evidence + 1] = item -- 1098
			end -- 1098
			i = i + 1 -- 1095
		end -- 1095
	end -- 1095
	return evidence -- 1101
end -- 1092
function DualLayerStorage.prototype.decodeSubAgentLearning(self, value, fallbackSortTs) -- 1104
	if not value or isArray(value) or not isRecord(value) then -- 1104
		return nil -- 1105
	end -- 1105
	local sourceSessionId = type(value.sourceSessionId) == "number" and math.floor(value.sourceSessionId) or 0 -- 1106
	local sourceTaskId = type(value.sourceTaskId) == "number" and math.floor(value.sourceTaskId) or 0 -- 1107
	local content = type(value.content) == "string" and utf8TakeHead( -- 1108
		__TS__StringTrim(sanitizeUTF8(value.content)), -- 1109
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1109
	) or "" -- 1109
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 1109
		return nil -- 1111
	end -- 1111
	return { -- 1112
		sourceSessionId = sourceSessionId, -- 1113
		sourceTaskId = sourceTaskId, -- 1114
		content = content, -- 1115
		evidence = self:normalizeEvidence(value.evidence), -- 1116
		createdAt = type(value.createdAt) == "string" and __TS__StringTrim(sanitizeUTF8(value.createdAt)) or "", -- 1117
		sortTs = fallbackSortTs -- 1118
	} -- 1118
end -- 1104
function DualLayerStorage.prototype.readSubAgentLearningEntries(self) -- 1122
	if self.scope ~= "" and self.scope ~= "main" then -- 1122
		return {} -- 1123
	end -- 1123
	local subAgentsDir = Path(self.agentRootDir, "subagents") -- 1124
	if not Content:exist(subAgentsDir) or not Content:isdir(subAgentsDir) then -- 1124
		return {} -- 1125
	end -- 1125
	local entries = {} -- 1126
	local seen = {} -- 1127
	for ____, rawPath in ipairs(Content:getDirs(subAgentsDir)) do -- 1128
		do -- 1128
			local dir = Content:isAbsolutePath(rawPath) and rawPath or Path(subAgentsDir, rawPath) -- 1129
			if not Content:exist(dir) or not Content:isdir(dir) then -- 1129
				goto __continue174 -- 1130
			end -- 1130
			local info = self:readSpawnInfo(Path(dir, SUB_AGENT_SPAWN_INFO_FILE)) -- 1131
			if info == nil or info.success ~= true then -- 1131
				goto __continue174 -- 1132
			end -- 1132
			local fallbackSortTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or 0 -- 1133
			local entry = self:decodeSubAgentLearning(info.memoryEntry, fallbackSortTs) -- 1134
			if entry == nil then -- 1134
				goto __continue174 -- 1135
			end -- 1135
			local key = (tostring(entry.sourceSessionId) .. ":") .. tostring(entry.sourceTaskId) -- 1136
			if seen[key] then -- 1136
				goto __continue174 -- 1137
			end -- 1137
			seen[key] = true -- 1138
			entries[#entries + 1] = entry -- 1139
		end -- 1139
		::__continue174:: -- 1139
	end -- 1139
	__TS__ArraySort( -- 1141
		entries, -- 1141
		function(____, a, b) return b.sortTs - a.sortTs end -- 1141
	) -- 1141
	return entries -- 1142
end -- 1122
function DualLayerStorage.prototype.buildSubAgentLearningsContext(self) -- 1145
	local entries = self:readSubAgentLearningEntries() -- 1146
	if #entries == 0 then -- 1146
		return "" -- 1147
	end -- 1147
	local lines = {"## Sub-Agent Learnings", ""} -- 1148
	local totalChars = 0 -- 1149
	local count = 0 -- 1150
	do -- 1150
		local i = 0 -- 1151
		while i < #entries and count < SUB_AGENT_LEARNINGS_MAX_ITEMS do -- 1151
			local entry = entries[i + 1] -- 1152
			local evidence = #entry.evidence > 0 and "\n  Evidence: " .. table.concat(entry.evidence, ", ") or "" -- 1153
			local line = ((((("- [sub-agent:" .. tostring(entry.sourceSessionId)) .. "/task:") .. tostring(entry.sourceTaskId)) .. "] ") .. entry.content) .. evidence -- 1154
			if totalChars + #line > SUB_AGENT_LEARNINGS_MAX_CHARS then -- 1154
				break -- 1155
			end -- 1155
			lines[#lines + 1] = line -- 1156
			totalChars = totalChars + #line -- 1157
			count = count + 1 -- 1158
			i = i + 1 -- 1151
		end -- 1151
	end -- 1151
	return count > 0 and table.concat(lines, "\n") or "" -- 1160
end -- 1145
function DualLayerStorage.prototype.readHistoryRecords(self) -- 1163
	if not Content:exist(self.historyPath) then -- 1163
		return {} -- 1165
	end -- 1165
	local text = Content:load(self.historyPath) -- 1167
	if not text or __TS__StringTrim(text) == "" then -- 1167
		return {} -- 1169
	end -- 1169
	local lines = __TS__StringSplit(text, "\n") -- 1171
	local records = {} -- 1172
	do -- 1172
		local i = 0 -- 1173
		while i < #lines do -- 1173
			do -- 1173
				local line = __TS__StringTrim(lines[i + 1]) -- 1174
				if line == "" then -- 1174
					goto __continue190 -- 1175
				end -- 1175
				local decoded = self:decodeJsonLine(line) -- 1176
				local record = self:decodeHistoryRecord(decoded) -- 1177
				if record ~= nil then -- 1177
					records[#records + 1] = record -- 1179
				end -- 1179
			end -- 1179
			::__continue190:: -- 1179
			i = i + 1 -- 1173
		end -- 1173
	end -- 1173
	return records -- 1182
end -- 1163
function DualLayerStorage.prototype.saveHistoryRecords(self, records) -- 1185
	self:ensureDir(Path:getPath(self.historyPath)) -- 1186
	local normalized = #records > HISTORY_MAX_RECORDS and __TS__ArraySlice(records, #records - HISTORY_MAX_RECORDS) or records -- 1187
	local lines = {} -- 1190
	do -- 1190
		local i = 0 -- 1191
		while i < #normalized do -- 1191
			local line = self:encodeJsonLine(normalized[i + 1]) -- 1192
			if type(line) == "string" and line ~= "" then -- 1192
				lines[#lines + 1] = line -- 1194
			end -- 1194
			i = i + 1 -- 1191
		end -- 1191
	end -- 1191
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 1197
	Content:save(self.historyPath, content) -- 1198
	sendWebIDEFileUpdate(self.historyPath, true, content) -- 1199
end -- 1185
function DualLayerStorage.prototype.readMemory(self) -- 1207
	if not Content:exist(self.memoryPath) then -- 1207
		return DEFAULT_CORE_MEMORY_TEMPLATE -- 1209
	end -- 1209
	return normalizeMemoryFileContent( -- 1211
		Content:load(self.memoryPath), -- 1211
		DEFAULT_CORE_MEMORY_TEMPLATE, -- 1211
		"Imported Notes" -- 1211
	) -- 1211
end -- 1207
function DualLayerStorage.prototype.writeMemory(self, content) -- 1217
	local normalized = normalizeMemoryFileContent(content, DEFAULT_CORE_MEMORY_TEMPLATE, "Imported Notes") -- 1218
	self:ensureDir(Path:getPath(self.memoryPath)) -- 1219
	Content:save(self.memoryPath, normalized) -- 1220
	sendWebIDEFileUpdate(self.memoryPath, true, normalized) -- 1221
end -- 1217
function DualLayerStorage.prototype.readProjectMemory(self) -- 1224
	if not Content:exist(self.projectMemoryPath) then -- 1224
		return DEFAULT_PROJECT_MEMORY_TEMPLATE -- 1226
	end -- 1226
	return normalizeMemoryFileContent( -- 1228
		Content:load(self.projectMemoryPath), -- 1228
		DEFAULT_PROJECT_MEMORY_TEMPLATE, -- 1228
		"Imported Project Notes" -- 1228
	) -- 1228
end -- 1224
function DualLayerStorage.prototype.writeProjectMemory(self, content) -- 1231
	local normalized = normalizeMemoryFileContent(content, DEFAULT_PROJECT_MEMORY_TEMPLATE, "Imported Project Notes") -- 1232
	self:ensureDir(Path:getPath(self.projectMemoryPath)) -- 1233
	Content:save(self.projectMemoryPath, normalized) -- 1234
	sendWebIDEFileUpdate(self.projectMemoryPath, true, normalized) -- 1235
end -- 1231
function DualLayerStorage.prototype.readSessionSummary(self) -- 1238
	if not Content:exist(self.sessionSummaryPath) then -- 1238
		return DEFAULT_SESSION_SUMMARY_TEMPLATE -- 1240
	end -- 1240
	return normalizeMemoryFileContent( -- 1242
		Content:load(self.sessionSummaryPath), -- 1242
		DEFAULT_SESSION_SUMMARY_TEMPLATE, -- 1242
		"Imported Session Notes" -- 1242
	) -- 1242
end -- 1238
function DualLayerStorage.prototype.writeSessionSummary(self, content) -- 1245
	local normalized = normalizeMemoryFileContent(content, DEFAULT_SESSION_SUMMARY_TEMPLATE, "Imported Session Notes") -- 1246
	self:ensureDir(Path:getPath(self.sessionSummaryPath)) -- 1247
	Content:save(self.sessionSummaryPath, normalized) -- 1248
	sendWebIDEFileUpdate(self.sessionSummaryPath, true, normalized) -- 1249
end -- 1245
function DualLayerStorage.prototype.getRelevantMemoryContext(self, query, maxTokens) -- 1255
	if query == nil then -- 1255
		query = "" -- 1255
	end -- 1255
	if maxTokens == nil then -- 1255
		maxTokens = MEMORY_CONTEXT_DEFAULT_MAX_TOKENS -- 1255
	end -- 1255
	local budget = math.max( -- 1256
		MEMORY_CONTEXT_MIN_MAX_TOKENS, -- 1256
		math.floor(maxTokens) -- 1256
	) -- 1256
	local coreBudget = math.floor(budget * 0.3) -- 1257
	local projectBudget = math.floor(budget * 0.35) -- 1258
	local sessionBudget = math.floor(budget * 0.2) -- 1259
	local subAgentBudget = math.max(0, budget - coreBudget - projectBudget - sessionBudget - 160) -- 1260
	local sections = {} -- 1261
	local core = formatMemoryLayer( -- 1262
		"Core Memory", -- 1262
		selectRelevantMemoryText( -- 1262
			self:readMemory(), -- 1262
			query, -- 1262
			coreBudget -- 1262
		) -- 1262
	) -- 1262
	if core ~= "" then -- 1262
		sections[#sections + 1] = core -- 1263
	end -- 1263
	local project = formatMemoryLayer( -- 1264
		"Project Memory", -- 1264
		selectRelevantMemoryText( -- 1264
			self:readProjectMemory(), -- 1264
			query, -- 1264
			projectBudget -- 1264
		) -- 1264
	) -- 1264
	if project ~= "" then -- 1264
		sections[#sections + 1] = project -- 1265
	end -- 1265
	local session = formatMemoryLayer( -- 1266
		"Session Summary", -- 1266
		selectRelevantMemoryText( -- 1266
			self:readSessionSummary(), -- 1266
			query, -- 1266
			sessionBudget -- 1266
		) -- 1266
	) -- 1266
	if session ~= "" then -- 1266
		sections[#sections + 1] = session -- 1267
	end -- 1267
	local subAgentLearnings = self:buildSubAgentLearningsContext() -- 1268
	if subAgentLearnings ~= "" then -- 1268
		sections[#sections + 1] = formatMemoryLayer( -- 1270
			"Sub-Agent Learnings", -- 1270
			clipTextToTokenBudget(subAgentLearnings, subAgentBudget > 0 and subAgentBudget or MEMORY_LAYER_MIN_TOKENS) -- 1270
		) -- 1270
	end -- 1270
	if #sections == 0 then -- 1270
		return "" -- 1272
	end -- 1272
	local output = "### Relevant Memory\n\n" .. table.concat(sections, "\n\n") -- 1273
	return ____exports.TokenEstimator:estimate(output) > budget and clipTextToTokenBudget(output, budget) or output -- 1274
end -- 1255
function DualLayerStorage.prototype.getMemoryContext(self, query, maxTokens) -- 1280
	if query == nil then -- 1280
		query = "" -- 1280
	end -- 1280
	if maxTokens == nil then -- 1280
		maxTokens = MEMORY_CONTEXT_DEFAULT_MAX_TOKENS -- 1280
	end -- 1280
	return self:getRelevantMemoryContext(query, maxTokens) -- 1281
end -- 1280
function DualLayerStorage.prototype.appendHistoryRecord(self, record) -- 1286
	local records = self:readHistoryRecords() -- 1287
	records[#records + 1] = record -- 1288
	self:saveHistoryRecords(records) -- 1289
end -- 1286
function DualLayerStorage.prototype.readSessionState(self) -- 1292
	if not Content:exist(self.sessionPath) then -- 1292
		return {messages = {}, lastConsolidatedIndex = 0} -- 1294
	end -- 1294
	local text = Content:load(self.sessionPath) -- 1296
	if not text or __TS__StringTrim(text) == "" then -- 1296
		return {messages = {}, lastConsolidatedIndex = 0} -- 1298
	end -- 1298
	local lines = __TS__StringSplit(text, "\n") -- 1300
	local messages = {} -- 1301
	local lastConsolidatedIndex = 0 -- 1302
	local carryMessageIndex = nil -- 1303
	do -- 1303
		local i = 0 -- 1304
		while i < #lines do -- 1304
			do -- 1304
				local line = __TS__StringTrim(lines[i + 1]) -- 1305
				if line == "" then -- 1305
					goto __continue218 -- 1306
				end -- 1306
				local data = self:decodeJsonLine(line) -- 1307
				if not data or isArray(data) or not isRecord(data) then -- 1307
					goto __continue218 -- 1308
				end -- 1308
				local row = data -- 1309
				if type(row.lastConsolidatedIndex) == "number" then -- 1309
					lastConsolidatedIndex = math.floor(row.lastConsolidatedIndex) -- 1311
					if type(row.carryMessageIndex) == "number" then -- 1311
						carryMessageIndex = math.floor(row.carryMessageIndex) -- 1313
					end -- 1313
					goto __continue218 -- 1315
				end -- 1315
				local ____self_decodeConversationMessage_4 = self.decodeConversationMessage -- 1317
				local ____row_message_3 = row.message -- 1317
				if ____row_message_3 == nil then -- 1317
					____row_message_3 = row -- 1317
				end -- 1317
				local message = ____self_decodeConversationMessage_4(self, ____row_message_3) -- 1317
				if message ~= nil then -- 1317
					messages[#messages + 1] = message -- 1319
				end -- 1319
			end -- 1319
			::__continue218:: -- 1319
			i = i + 1 -- 1304
		end -- 1304
	end -- 1304
	local normalizedLastConsolidatedIndex = clampSessionIndex(messages, lastConsolidatedIndex) -- 1322
	local normalizedCarryMessageIndex = type(carryMessageIndex) == "number" and carryMessageIndex >= 0 and carryMessageIndex < normalizedLastConsolidatedIndex and carryMessageIndex < #messages and math.floor(carryMessageIndex) or nil -- 1323
	return {messages = messages, lastConsolidatedIndex = normalizedLastConsolidatedIndex, carryMessageIndex = normalizedCarryMessageIndex} -- 1329
end -- 1292
function DualLayerStorage.prototype.writeSessionState(self, messages, lastConsolidatedIndex, carryMessageIndex) -- 1336
	if messages == nil then -- 1336
		messages = {} -- 1337
	end -- 1337
	if lastConsolidatedIndex == nil then -- 1337
		lastConsolidatedIndex = 0 -- 1338
	end -- 1338
	self:ensureDir(Path:getPath(self.sessionPath)) -- 1341
	local lines = {} -- 1342
	local dropCount = #messages > SESSION_MAX_RECORDS and #messages - SESSION_MAX_RECORDS or 0 -- 1343
	local normalizedMessages = dropCount > 0 and __TS__ArraySlice(messages, dropCount) or messages -- 1346
	local normalizedLastConsolidatedIndex = clampSessionIndex(normalizedMessages, lastConsolidatedIndex - dropCount) -- 1349
	local normalizedCarryMessageIndex = type(carryMessageIndex) == "number" and carryMessageIndex - dropCount >= 0 and carryMessageIndex - dropCount < normalizedLastConsolidatedIndex and carryMessageIndex - dropCount < #normalizedMessages and math.floor(carryMessageIndex - dropCount) or nil -- 1353
	local stateLine = self:encodeJsonLine({lastConsolidatedIndex = normalizedLastConsolidatedIndex, carryMessageIndex = normalizedCarryMessageIndex}) -- 1359
	if type(stateLine) == "string" and stateLine ~= "" then -- 1359
		lines[#lines + 1] = stateLine -- 1364
	end -- 1364
	do -- 1364
		local i = 0 -- 1366
		while i < #normalizedMessages do -- 1366
			local line = self:encodeJsonLine({message = normalizedMessages[i + 1]}) -- 1367
			if type(line) == "string" and line ~= "" then -- 1367
				lines[#lines + 1] = line -- 1371
			end -- 1371
			i = i + 1 -- 1366
		end -- 1366
	end -- 1366
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 1374
	Content:save(self.sessionPath, content) -- 1375
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 1376
end -- 1336
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 1388
local MemoryCompressor = ____exports.MemoryCompressor -- 1388
MemoryCompressor.name = "MemoryCompressor" -- 1388
function MemoryCompressor.prototype.____constructor(self, config) -- 1395
	self.consecutiveFailures = 0 -- 1391
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 1396
	do -- 1396
		local i = 0 -- 1397
		while i < #loadedPromptPack.warnings do -- 1397
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 1398
			i = i + 1 -- 1397
		end -- 1397
	end -- 1397
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 1400
	self.config = __TS__ObjectAssign( -- 1403
		{}, -- 1403
		config, -- 1404
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 1403
	) -- 1403
	self.config.compressionThreshold = math.min( -- 1410
		1, -- 1410
		math.max(0.05, self.config.compressionThreshold) -- 1410
	) -- 1410
	self.config.compressionTargetThreshold = math.min( -- 1411
		self.config.compressionThreshold, -- 1412
		math.max(0.05, self.config.compressionTargetThreshold) -- 1413
	) -- 1413
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir, self.config.scope or "") -- 1415
end -- 1395
function MemoryCompressor.prototype.getPromptPack(self) -- 1418
	return self.config.promptPack -- 1419
end -- 1418
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 1425
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1430
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 1436
	return messageTokens > threshold -- 1438
end -- 1425
function MemoryCompressor.prototype.compress(self, messages, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode, systemPrompt, toolDefinitions) -- 1444
	if decisionMode == nil then -- 1444
		decisionMode = "tool_calling" -- 1448
	end -- 1448
	if boundaryMode == nil then -- 1448
		boundaryMode = "default" -- 1450
	end -- 1450
	if systemPrompt == nil then -- 1450
		systemPrompt = "" -- 1451
	end -- 1451
	if toolDefinitions == nil then -- 1451
		toolDefinitions = "" -- 1452
	end -- 1452
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1452
		local toCompress = messages -- 1454
		if #toCompress == 0 then -- 1454
			return ____awaiter_resolve(nil, nil) -- 1454
		end -- 1454
		local currentMemory = self.storage:readMemory() -- 1456
		local boundary = self:findCompressionBoundary( -- 1458
			toCompress, -- 1459
			currentMemory, -- 1460
			boundaryMode, -- 1461
			systemPrompt, -- 1462
			toolDefinitions -- 1463
		) -- 1463
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 1465
		if #chunk == 0 then -- 1465
			return ____awaiter_resolve(nil, nil) -- 1465
		end -- 1465
		local historyText = self:formatMessagesForCompression(chunk) -- 1468
		local ____hasReturned, ____returnValue -- 1468
		local ____try = __TS__AsyncAwaiter(function() -- 1468
			local result = __TS__Await(self:callLLMForCompression( -- 1472
				currentMemory, -- 1473
				historyText, -- 1474
				llmOptions, -- 1475
				maxLLMTry or 3, -- 1476
				decisionMode, -- 1477
				debugContext -- 1478
			)) -- 1478
			if result.success then -- 1478
				self.storage:writeMemory(result.memoryUpdate) -- 1483
				if type(result.projectMemoryUpdate) == "string" then -- 1483
					self.storage:writeProjectMemory(result.projectMemoryUpdate) -- 1485
				end -- 1485
				if type(result.sessionSummaryUpdate) == "string" then -- 1485
					self.storage:writeSessionSummary(result.sessionSummaryUpdate) -- 1488
				end -- 1488
				if result.ts then -- 1488
					self.storage:appendHistoryRecord({ts = result.ts, summary = result.summary}) -- 1491
				end -- 1491
				self.consecutiveFailures = 0 -- 1496
				____hasReturned = true -- 1498
				____returnValue = __TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessageIndex = boundary.carryMessageIndex}) -- 1498
				return -- 1498
			end -- 1498
			____hasReturned = true -- 1506
			____returnValue = self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 1506
			return -- 1506
		end) -- 1506
		____try = ____try.catch( -- 1506
			____try, -- 1506
			function(____, ____error) -- 1506
				return __TS__AsyncAwaiter(function() -- 1506
					____hasReturned = true -- 1509
					____returnValue = self:handleCompressionFailure( -- 1509
						chunk, -- 1509
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 1509
					) -- 1509
					return -- 1509
				end) -- 1509
			end -- 1509
		) -- 1509
		__TS__Await(____try) -- 1470
		if ____hasReturned then -- 1470
			return ____awaiter_resolve(nil, ____returnValue) -- 1470
		end -- 1470
	end) -- 1470
end -- 1444
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode, systemPrompt, toolDefinitions) -- 1518
	local targetTokens = boundaryMode == "budget_max" and math.max( -- 1525
		1, -- 1526
		self:getCompressionHistoryTokenBudget(currentMemory) -- 1526
	) or math.max( -- 1526
		1, -- 1527
		self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 1527
	) -- 1527
	local accumulatedTokens = 0 -- 1528
	local lastSafeBoundary = 0 -- 1529
	local lastSafeBoundaryWithinBudget = 0 -- 1530
	local lastClosedBoundary = 0 -- 1531
	local lastClosedBoundaryWithinBudget = 0 -- 1532
	local pendingToolCalls = {} -- 1533
	local pendingToolCallCount = 0 -- 1534
	local exceededBudget = false -- 1535
	do -- 1535
		local i = 0 -- 1537
		while i < #messages do -- 1537
			local message = messages[i + 1] -- 1538
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 1539
			accumulatedTokens = accumulatedTokens + tokens -- 1540
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1540
				do -- 1540
					local j = 0 -- 1543
					while j < #message.tool_calls do -- 1543
						local toolCallEntry = message.tool_calls[j + 1] -- 1544
						local idValue = toolCallEntry.id -- 1545
						local id = type(idValue) == "string" and idValue or "" -- 1546
						if id ~= "" and not pendingToolCalls[id] then -- 1546
							pendingToolCalls[id] = true -- 1548
							pendingToolCallCount = pendingToolCallCount + 1 -- 1549
						end -- 1549
						j = j + 1 -- 1543
					end -- 1543
				end -- 1543
			end -- 1543
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 1543
				pendingToolCalls[message.tool_call_id] = false -- 1555
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 1556
			end -- 1556
			local isAtEnd = i >= #messages - 1 -- 1559
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 1560
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 1561
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 1562
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 1563
			if isSafeBoundary then -- 1563
				lastSafeBoundary = i + 1 -- 1565
				if accumulatedTokens <= targetTokens then -- 1565
					lastSafeBoundaryWithinBudget = i + 1 -- 1567
				end -- 1567
			end -- 1567
			if isClosedToolBoundary then -- 1567
				lastClosedBoundary = i + 1 -- 1571
				if accumulatedTokens <= targetTokens then -- 1571
					lastClosedBoundaryWithinBudget = i + 1 -- 1573
				end -- 1573
			end -- 1573
			if accumulatedTokens > targetTokens and not exceededBudget then -- 1573
				exceededBudget = true -- 1578
			end -- 1578
			if exceededBudget and isSafeBoundary then -- 1578
				return self:buildCarryBoundary(messages, i + 1) -- 1583
			end -- 1583
			i = i + 1 -- 1537
		end -- 1537
	end -- 1537
	if lastSafeBoundaryWithinBudget > 0 then -- 1537
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 1588
	end -- 1588
	if lastSafeBoundary > 0 then -- 1588
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 1591
	end -- 1591
	if lastClosedBoundaryWithinBudget > 0 then -- 1591
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 1594
	end -- 1594
	if lastClosedBoundary > 0 then -- 1594
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 1597
	end -- 1597
	local fallback = math.min(#messages, 1) -- 1599
	return {chunkEnd = fallback, compressedCount = fallback} -- 1600
end -- 1518
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 1603
	local carryUserIndex = -1 -- 1604
	do -- 1604
		local i = 0 -- 1605
		while i < chunkEnd do -- 1605
			if messages[i + 1].role == "user" then -- 1605
				carryUserIndex = i -- 1607
			end -- 1607
			i = i + 1 -- 1605
		end -- 1605
	end -- 1605
	if carryUserIndex < 0 then -- 1605
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 1611
	end -- 1611
	return {chunkEnd = chunkEnd, compressedCount = chunkEnd, carryMessageIndex = carryUserIndex} -- 1613
end -- 1603
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 1620
	local lines = {} -- 1621
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 1622
	if message.name and message.name ~= "" then -- 1622
		lines[#lines + 1] = "name=" .. message.name -- 1623
	end -- 1623
	if message.tool_call_id and message.tool_call_id ~= "" then -- 1623
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1624
	end -- 1624
	if message.reasoning_content and message.reasoning_content ~= "" then -- 1624
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1625
	end -- 1625
	if message.tool_calls and #message.tool_calls > 0 then -- 1625
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 1627
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1628
	end -- 1628
	if message.content and message.content ~= "" then -- 1628
		lines[#lines + 1] = message.content -- 1630
	end -- 1630
	local prefix = index > 0 and "\n\n" or "" -- 1631
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 1632
end -- 1620
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages, systemPrompt, toolDefinitions) -- 1635
	local currentTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1640
	local threshold = self:getContextWindow() * self.config.compressionTargetThreshold -- 1645
	local overflow = math.max(0, currentTokens - threshold) -- 1646
	if overflow <= 0 then -- 1646
		return math.max( -- 1648
			1, -- 1648
			self:estimateCompressionMessageTokens(messages[1], 0) -- 1648
		) -- 1648
	end -- 1648
	local safetyMargin = math.max( -- 1650
		64, -- 1650
		math.floor(threshold * 0.01) -- 1650
	) -- 1650
	return overflow + safetyMargin -- 1651
end -- 1635
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1654
	local lines = {} -- 1655
	do -- 1655
		local i = 0 -- 1656
		while i < #messages do -- 1656
			local message = messages[i + 1] -- 1657
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1658
			if message.name and message.name ~= "" then -- 1658
				lines[#lines + 1] = "name=" .. message.name -- 1659
			end -- 1659
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1659
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1660
			end -- 1660
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1660
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1661
			end -- 1661
			if message.tool_calls and #message.tool_calls > 0 then -- 1661
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1663
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1664
			end -- 1664
			if message.content and message.content ~= "" then -- 1664
				lines[#lines + 1] = message.content -- 1666
			end -- 1666
			if i < #messages - 1 then -- 1666
				lines[#lines + 1] = "" -- 1667
			end -- 1667
			i = i + 1 -- 1656
		end -- 1656
	end -- 1656
	return table.concat(lines, "\n") -- 1669
end -- 1654
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1675
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1675
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1683
		if decisionMode == "xml" then -- 1683
			return ____awaiter_resolve( -- 1683
				nil, -- 1683
				self:callLLMForCompressionByXML( -- 1685
					currentMemory, -- 1686
					boundedHistoryText, -- 1687
					llmOptions, -- 1688
					maxLLMTry, -- 1689
					debugContext -- 1690
				) -- 1690
			) -- 1690
		end -- 1690
		return ____awaiter_resolve( -- 1690
			nil, -- 1690
			self:callLLMForCompressionByToolCalling( -- 1693
				currentMemory, -- 1694
				boundedHistoryText, -- 1695
				llmOptions, -- 1696
				maxLLMTry, -- 1697
				debugContext -- 1698
			) -- 1698
		) -- 1698
	end) -- 1698
end -- 1675
function MemoryCompressor.prototype.getContextWindow(self) -- 1702
	return math.max(MEMORY_DEFAULT_CONTEXT_WINDOW, self.config.llmConfig.contextWindow) -- 1703
end -- 1702
function MemoryCompressor.prototype.getMemoryContextBudget(self) -- 1706
	local contextWindow = math.max(MEMORY_DEFAULT_CONTEXT_WINDOW, self.config.llmConfig.contextWindow) -- 1707
	return math.max( -- 1708
		AGENT_MEMORY_CONTEXT_MIN_TOKENS, -- 1709
		math.floor(contextWindow * AGENT_MEMORY_CONTEXT_WINDOW_RATIO) -- 1710
	) -- 1710
end -- 1706
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1714
	local contextWindow = self:getContextWindow() -- 1715
	local reservedOutputTokens = math.max( -- 1716
		COMPRESSION_RESERVED_OUTPUT_MIN_TOKENS, -- 1717
		math.floor(contextWindow * COMPRESSION_RESERVED_OUTPUT_CONTEXT_RATIO) -- 1718
	) -- 1718
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1720
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1721
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1722
	return math.max( -- 1723
		COMPRESSION_HISTORY_MIN_TOKENS, -- 1724
		math.floor(available * COMPRESSION_HISTORY_AVAILABLE_RATIO) -- 1725
	) -- 1725
end -- 1714
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1729
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1730
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1731
	if historyTokens <= tokenBudget then -- 1731
		return historyText -- 1732
	end -- 1732
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1733
	local targetChars = math.max( -- 1736
		COMPRESSION_HISTORY_TRUNCATED_MIN_CHARS, -- 1737
		math.floor(tokenBudget * charsPerToken) -- 1738
	) -- 1738
	local keepHead = math.max( -- 1740
		0, -- 1740
		math.floor(targetChars * COMPRESSION_HISTORY_TRUNCATED_HEAD_RATIO) -- 1740
	) -- 1740
	local keepTail = math.max(0, targetChars - keepHead) -- 1741
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1742
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1743
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1744
end -- 1729
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1747
	local contextWindow = self:getContextWindow() -- 1753
	local reservedOutputTokens = math.max( -- 1754
		COMPRESSION_RESERVED_OUTPUT_MIN_TOKENS, -- 1755
		math.floor(contextWindow * COMPRESSION_RESERVED_OUTPUT_CONTEXT_RATIO) -- 1756
	) -- 1756
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1758
	local dynamicBudget = math.max(COMPRESSION_DYNAMIC_MIN_TOKENS, contextWindow - reservedOutputTokens - staticPromptTokens - COMPRESSION_DYNAMIC_PROMPT_OVERHEAD_TOKENS) -- 1759
	local boundedMemory = clipTextToTokenBudget( -- 1763
		currentMemory or "(empty)", -- 1763
		math.max( -- 1763
			COMPRESSION_SECTION_MEMORY_MIN_TOKENS, -- 1764
			math.floor(dynamicBudget * COMPRESSION_SECTION_MEMORY_RATIO) -- 1765
		) -- 1765
	) -- 1765
	local boundedProjectMemory = clipTextToTokenBudget( -- 1767
		self.storage:readProjectMemory() or "(empty)", -- 1767
		math.max( -- 1767
			COMPRESSION_SECTION_MEMORY_MIN_TOKENS, -- 1768
			math.floor(dynamicBudget * COMPRESSION_SECTION_MEMORY_RATIO) -- 1769
		) -- 1769
	) -- 1769
	local boundedSessionSummary = clipTextToTokenBudget( -- 1771
		self.storage:readSessionSummary() or "(empty)", -- 1771
		math.max( -- 1771
			COMPRESSION_SECTION_SESSION_MIN_TOKENS, -- 1772
			math.floor(dynamicBudget * COMPRESSION_SECTION_SESSION_RATIO) -- 1773
		) -- 1773
	) -- 1773
	local boundedHistory = clipTextToTokenBudget( -- 1775
		historyText, -- 1775
		math.max( -- 1775
			COMPRESSION_SECTION_HISTORY_MIN_TOKENS, -- 1776
			math.floor(dynamicBudget * COMPRESSION_SECTION_HISTORY_RATIO) -- 1777
		) -- 1777
	) -- 1777
	return {currentMemory = boundedMemory, currentProjectMemory = boundedProjectMemory, currentSessionSummary = boundedSessionSummary, historyText = boundedHistory} -- 1779
end -- 1747
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1787
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1787
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1794
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated MEMORY.md as markdown. Core memory only: user preferences, stable facts, decisions, known issues."}, project_memory_update = {type = "string", description = "Full updated PROJECT_MEMORY.md as markdown. Project facts, build/run, files/architecture, project decisions and issues."}, session_summary_update = {type = "string", description = "Full updated SESSION_SUMMARY.md as markdown. Current goal, recent progress, and open issues for this session."}}, required = {"history_entry", "memory_update"}}}}} -- 1797
		local lastError = "missing save_memory tool call" -- 1828
		do -- 1828
			local i = 0 -- 1829
			while i < maxLLMTry do -- 1829
				do -- 1829
					local feedback = i > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). You must call the save_memory tool. Do not write prose. Required arguments: history_entry and memory_update. Optional arguments: project_memory_update and session_summary_update." or "" -- 1830
					local messages = { -- 1833
						{ -- 1834
							role = "system", -- 1835
							content = self:buildToolCallingCompressionSystemPrompt() -- 1836
						}, -- 1836
						{role = "user", content = prompt .. feedback} -- 1838
					} -- 1838
					local requestOptions = __TS__ObjectAssign({}, llmOptions, {tools = tools}) -- 1843
					__TS__Delete(requestOptions, "tool_choice") -- 1849
					local ____opt_5 = debugContext and debugContext.onInput -- 1849
					if ____opt_5 ~= nil then -- 1849
						____opt_5(debugContext, "memory_compression_tool_calling", messages, requestOptions) -- 1850
					end -- 1850
					local response = __TS__Await(callLLM(messages, requestOptions, nil, self.config.llmConfig)) -- 1851
					if not response.success then -- 1851
						lastError = response.message -- 1859
						local ____opt_9 = debugContext and debugContext.onOutput -- 1859
						if ____opt_9 ~= nil then -- 1859
							____opt_9(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false, attempt = i + 1, error = lastError}) -- 1860
						end -- 1860
						Log( -- 1861
							"Warn", -- 1861
							(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " failed: ") .. response.message -- 1861
						) -- 1861
						goto __continue293 -- 1862
					end -- 1862
					local ____opt_13 = debugContext and debugContext.onOutput -- 1862
					if ____opt_13 ~= nil then -- 1862
						____opt_13( -- 1864
							debugContext, -- 1864
							"memory_compression_tool_calling", -- 1864
							encodeCompressionDebugJSON(response.response), -- 1864
							{success = true, attempt = i + 1} -- 1864
						) -- 1864
					end -- 1864
					local choice = response.response.choices and response.response.choices[1] -- 1866
					local message = choice and choice.message -- 1867
					local toolCalls = message and message.tool_calls -- 1868
					local toolCall = toolCalls and toolCalls[1] -- 1869
					local fn = toolCall and toolCall["function"] -- 1870
					local argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1871
					if not fn or fn.name ~= "save_memory" then -- 1871
						local contentPreview = message and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" and "; content=" .. utf8TakeHead( -- 1873
							__TS__StringTrim(message.content), -- 1874
							240 -- 1874
						) or "" -- 1874
						lastError = "missing save_memory tool call" .. contentPreview -- 1876
						Log( -- 1877
							"Warn", -- 1877
							(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " invalid: ") .. lastError -- 1877
						) -- 1877
						goto __continue293 -- 1878
					end -- 1878
					if __TS__StringTrim(argsText) == "" then -- 1878
						lastError = "empty save_memory tool arguments" -- 1881
						Log( -- 1882
							"Warn", -- 1882
							(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " invalid: ") .. lastError -- 1882
						) -- 1882
						goto __continue293 -- 1883
					end -- 1883
					local args, err = safeJsonDecode(argsText) -- 1886
					if err ~= nil or not args or type(args) ~= "table" then -- 1886
						lastError = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1888
						Log( -- 1889
							"Warn", -- 1889
							(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " invalid: ") .. lastError -- 1889
						) -- 1889
						goto __continue293 -- 1890
					end -- 1890
					local ____hasReturned, ____returnValue -- 1890
					local ____try = __TS__AsyncAwaiter(function() -- 1890
						local result = self:buildCompressionResultFromObject(args, currentMemory) -- 1894
						if result.success then -- 1894
							____hasReturned = true -- 1898
							____returnValue = result -- 1898
							return -- 1898
						end -- 1898
						lastError = result.error or "invalid save_memory arguments" -- 1899
						Log( -- 1900
							"Warn", -- 1900
							(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " invalid: ") .. lastError -- 1900
						) -- 1900
					end) -- 1900
					____try = ____try.catch( -- 1900
						____try, -- 1900
						function(____, ____error) -- 1900
							return __TS__AsyncAwaiter(function() -- 1900
								lastError = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1902
								Log( -- 1903
									"Warn", -- 1903
									(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " invalid: ") .. lastError -- 1903
								) -- 1903
							end) -- 1903
						end -- 1903
					) -- 1903
					__TS__Await(____try) -- 1893
					if ____hasReturned then -- 1893
						return ____awaiter_resolve(nil, ____returnValue) -- 1893
					end -- 1893
				end -- 1893
				::__continue293:: -- 1893
				i = i + 1 -- 1829
			end -- 1829
		end -- 1829
		Log( -- 1907
			"Warn", -- 1907
			(("[Memory] compression tool-calling exhausted " .. tostring(maxLLMTry)) .. " retries, falling back to XML: ") .. lastError -- 1907
		) -- 1907
		return ____awaiter_resolve( -- 1907
			nil, -- 1907
			self:callLLMForCompressionByXML( -- 1908
				currentMemory, -- 1909
				historyText, -- 1910
				llmOptions, -- 1911
				maxLLMTry, -- 1912
				debugContext -- 1913
			) -- 1913
		) -- 1913
	end) -- 1913
end -- 1787
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1917
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1917
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1924
		local lastError = "invalid xml response" -- 1925
		do -- 1925
			local i = 0 -- 1927
			while i < maxLLMTry do -- 1927
				do -- 1927
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1928
					local requestMessages = { -- 1933
						{ -- 1934
							role = "system", -- 1934
							content = self:buildXMLCompressionSystemPrompt() -- 1934
						}, -- 1934
						{role = "user", content = prompt .. feedback} -- 1935
					} -- 1935
					local ____opt_17 = debugContext and debugContext.onInput -- 1935
					if ____opt_17 ~= nil then -- 1935
						____opt_17(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1937
					end -- 1937
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1938
					if not response.success then -- 1938
						local ____opt_21 = debugContext and debugContext.onOutput -- 1938
						if ____opt_21 ~= nil then -- 1938
							____opt_21(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1946
						end -- 1946
						return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1946
					end -- 1946
					local choice = response.response.choices and response.response.choices[1] -- 1955
					local message = choice and choice.message -- 1956
					local text = message and type(message.content) == "string" and message.content or "" -- 1957
					local ____opt_25 = debugContext and debugContext.onOutput -- 1957
					if ____opt_25 ~= nil then -- 1957
						____opt_25( -- 1958
							debugContext, -- 1958
							"memory_compression_xml", -- 1958
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1958
							{success = true} -- 1958
						) -- 1958
					end -- 1958
					if __TS__StringTrim(text) == "" then -- 1958
						lastError = "empty xml response" -- 1960
						goto __continue303 -- 1961
					end -- 1961
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1964
					if parsed.success then -- 1964
						return ____awaiter_resolve(nil, parsed) -- 1964
					end -- 1964
					lastError = parsed.error or "invalid xml response" -- 1968
				end -- 1968
				::__continue303:: -- 1968
				i = i + 1 -- 1927
			end -- 1927
		end -- 1927
		return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = lastError}) -- 1927
	end) -- 1927
end -- 1917
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1982
	return replaceTemplateVars( -- 1983
		self.config.promptPack.memoryCompressionBodyPrompt, -- 1983
		{ -- 1983
			CURRENT_MEMORY = currentMemory or "(empty)", -- 1984
			CURRENT_PROJECT_MEMORY = self.storage:readProjectMemory() or "(empty)", -- 1985
			CURRENT_SESSION_SUMMARY = self.storage:readSessionSummary() or "(empty)", -- 1986
			HISTORY_TEXT = historyText -- 1987
		} -- 1987
	) -- 1987
end -- 1982
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1991
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1992
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, CURRENT_PROJECT_MEMORY = bounded.currentProjectMemory, CURRENT_SESSION_SUMMARY = bounded.currentSessionSummary, HISTORY_TEXT = bounded.historyText}) -- 1993
end -- 1991
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 2001
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 2002
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 2005
end -- 2001
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 2012
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 2013
end -- 2012
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 2018
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 2019
end -- 2018
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 2024
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 2025
	if not parsed.success then -- 2025
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = parsed.message} -- 2027
	end -- 2027
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 2034
end -- 2024
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 2040
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 2044
	local memoryBody = type(obj.memory_update) == "string" and __TS__StringTrim(obj.memory_update) ~= "" and obj.memory_update or currentMemory -- 2045
	local projectMemoryBody = type(obj.project_memory_update) == "string" and __TS__StringTrim(obj.project_memory_update) ~= "" and obj.project_memory_update or self.storage:readProjectMemory() -- 2048
	local sessionSummaryBody = type(obj.session_summary_update) == "string" and __TS__StringTrim(obj.session_summary_update) ~= "" and obj.session_summary_update or self.storage:readSessionSummary() -- 2051
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 2051
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing history_entry or memory_update"} -- 2055
	end -- 2055
	local ts = os.date("%Y-%m-%d %H:%M") -- 2062
	return { -- 2063
		success = true, -- 2064
		memoryUpdate = memoryBody, -- 2065
		projectMemoryUpdate = projectMemoryBody, -- 2066
		sessionSummaryUpdate = sessionSummaryBody, -- 2067
		ts = ts, -- 2068
		summary = historyEntry, -- 2069
		compressedCount = 0 -- 2070
	} -- 2070
end -- 2040
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 2077
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 2081
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 2081
		local archived = self:rawArchive(chunk) -- 2084
		self.consecutiveFailures = 0 -- 2085
		return { -- 2087
			success = true, -- 2088
			memoryUpdate = self.storage:readMemory(), -- 2089
			ts = archived.ts, -- 2090
			compressedCount = #chunk -- 2091
		} -- 2091
	end -- 2091
	return { -- 2095
		success = false, -- 2096
		memoryUpdate = self.storage:readMemory(), -- 2097
		compressedCount = 0, -- 2098
		error = ____error -- 2099
	} -- 2099
end -- 2077
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 2106
	local ts = os.date("%Y-%m-%d %H:%M") -- 2107
	local rawArchive = self:formatMessagesForCompression(chunk) -- 2108
	self.storage:appendHistoryRecord({ts = ts, rawArchive = rawArchive}) -- 2109
	return {ts = ts} -- 2113
end -- 2106
function MemoryCompressor.prototype.getStorage(self) -- 2119
	return self.storage -- 2120
end -- 2119
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 2123
	return math.max( -- 2124
		1, -- 2124
		math.floor(self.config.maxCompressionRounds) -- 2124
	) -- 2124
end -- 2123
MemoryCompressor.MAX_FAILURES = 3 -- 2123
function ____exports.compactSessionMemoryScope(options) -- 2128
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2128
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2137
		if not llmConfigRes.success then -- 2137
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2137
		end -- 2137
		local compressor = __TS__New(____exports.MemoryCompressor, { -- 2143
			compressionThreshold = 0.8, -- 2144
			compressionTargetThreshold = 0.5, -- 2145
			maxCompressionRounds = 3, -- 2146
			projectDir = options.projectDir, -- 2147
			llmConfig = llmConfigRes.config, -- 2148
			promptPack = options.promptPack, -- 2149
			scope = options.scope -- 2150
		}) -- 2150
		local storage = compressor:getStorage() -- 2152
		local persistedSession = storage:readSessionState() -- 2153
		local messages = persistedSession.messages -- 2154
		local lastConsolidatedIndex = persistedSession.lastConsolidatedIndex -- 2155
		local carryMessageIndex = persistedSession.carryMessageIndex -- 2156
		local llmOptions = buildMemoryLLMOptions(llmConfigRes.config, options.llmOptions) -- 2157
		while lastConsolidatedIndex < #messages do -- 2157
			local activeMessages = {} -- 2159
			if type(carryMessageIndex) == "number" and carryMessageIndex >= 0 and carryMessageIndex < lastConsolidatedIndex and carryMessageIndex < #messages then -- 2159
				activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, messages[carryMessageIndex + 1]) -- 2166
			end -- 2166
			do -- 2166
				local i = lastConsolidatedIndex -- 2170
				while i < #messages do -- 2170
					activeMessages[#activeMessages + 1] = messages[i + 1] -- 2171
					i = i + 1 -- 2170
				end -- 2170
			end -- 2170
			local result = __TS__Await(compressor:compress( -- 2173
				activeMessages, -- 2174
				llmOptions, -- 2175
				math.max( -- 2176
					1, -- 2176
					math.floor(options.llmMaxTry or 5) -- 2176
				), -- 2176
				options.decisionMode or "tool_calling", -- 2177
				nil, -- 2178
				"budget_max" -- 2179
			)) -- 2179
			if not (result and result.success and result.compressedCount > 0) then -- 2179
				return ____awaiter_resolve(nil, {success = false, message = result and result.error or "memory compaction produced no progress"}) -- 2179
			end -- 2179
			local syntheticPrefixCount = #activeMessages > 0 and lastConsolidatedIndex < #messages and activeMessages[1] ~= messages[lastConsolidatedIndex + 1] and 1 or 0 -- 2187
			local realCompressedCount = math.max(0, result.compressedCount - syntheticPrefixCount) -- 2192
			lastConsolidatedIndex = math.min(#messages, lastConsolidatedIndex + realCompressedCount) -- 2193
			if type(result.carryMessageIndex) == "number" then -- 2193
				if syntheticPrefixCount > 0 and result.carryMessageIndex == 0 then -- 2193
				else -- 2193
					local carryOffset = syntheticPrefixCount > 0 and result.carryMessageIndex - 1 or result.carryMessageIndex -- 2198
					carryMessageIndex = carryOffset >= 0 and lastConsolidatedIndex - realCompressedCount + carryOffset or nil -- 2201
				end -- 2201
			else -- 2201
				carryMessageIndex = nil -- 2206
			end -- 2206
			if type(carryMessageIndex) == "number" and (carryMessageIndex < 0 or carryMessageIndex >= lastConsolidatedIndex or carryMessageIndex >= #messages) then -- 2206
				carryMessageIndex = nil -- 2212
			end -- 2212
			storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2214
		end -- 2214
		return ____awaiter_resolve(nil, {success = true, remainingMessages = #messages - lastConsolidatedIndex}) -- 2214
	end) -- 2214
end -- 2128
return ____exports -- 2128