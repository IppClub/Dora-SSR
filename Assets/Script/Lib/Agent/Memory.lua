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
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 202
	agentIdentityPrompt = "# Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n# Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 203
	mainAgentRolePrompt = "# Agent Role\n\nYou are the main agent. Your job is to discuss plans with the user, inspect the codebase, make direct edits when that is the simplest path, and delegate larger or parallelizable implementation work by spawning sub agents.\n\nRules:\n- You may use the full toolset directly, including edit_file, delete_file, and build.\n- Use direct tools for small, focused, or user-interactive changes where staying in the current run gives the clearest result.\n- Use spawn_sub_agent for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n- Use list_sub_agents only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether another delegation is necessary or whether to read a result file.\n- Keep sub-agent titles short and specific.\n- The sub-agent prompt should be self-contained and executable, and should explain the exact task, constraints, expected output, and relevant files when known.\n- After spawn_sub_agent succeeds, immediately finish the current turn and tell the user the work has been delegated.\n- After a successful spawn_sub_agent, do not call list_sub_agents or any other tool in the same turn.\n- Treat the sub-agent completion result as an asynchronous handoff that should be continued in later conversation turns.", -- 216
	subAgentRolePrompt = "# Agent Role\n\nYou are a sub agent. Your job is to execute concrete implementation, editing, and build work delegated by the main agent.\n\nRules:\n- Focus on completing the delegated task end-to-end.\n- Use the available implementation tools directly when needed, including edit_file, delete_file, and build.\n- Documentation writing tasks are also part of your execution scope when delegated by the main agent.\n- Summaries should stay concise and execution-oriented.", -- 230
	functionCallingPrompt = "# Function Calling\n\nYou may return multiple tool calls in one response when the calls are independent and all results are useful before the next reasoning step.", -- 239
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. 0 is invalid.\n\t- startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.", -- 242
	mainAgentToolDefinitionsDetailed = "\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories.", -- 286
	xmlToolDefinitionsDetailed = "\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text.", -- 306
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 316
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 317
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with one or more valid tool calls.", -- 318
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 319
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 332
	xmlDecisionSystemRepairPrompt = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only.", -- 363
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\t- Separate updates into Core Memory, Project Memory, and Session Summary\n\n4. Create History Entry\n\t- Create a summary paragraph\n\t- Include key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 374
	memoryCompressionBodyPrompt = "# Current Core Memory\n\n{{CURRENT_MEMORY}}\n\n# Current Project Memory\n\n{{CURRENT_PROJECT_MEMORY}}\n\n# Current Session Summary\n\n{{CURRENT_SESSION_SUMMARY}}\n\n# Actions to Process\n\n{{HISTORY_TEXT}}", -- 404
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content (Core Memory only)\n- project_memory_update: optional full updated PROJECT_MEMORY.md content; omit or leave empty to keep the current content\n- session_summary_update: optional full updated SESSION_SUMMARY.md content; omit or leave empty to keep the current content", -- 419
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update>\nFull updated MEMORY.md content (Core Memory only)\n\t</memory_update>\n\t<project_memory_update>\nFull updated PROJECT_MEMORY.md content\n\t</project_memory_update>\n\t<session_summary_update>\nFull updated SESSION_SUMMARY.md content\n\t</session_summary_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Include `<history_entry>` and `<memory_update>`. `<project_memory_update>` and `<session_summary_update>` are optional; omit them to keep current content.\n- Use CDATA for markdown update fields when they span multiple lines or contain markdown/code.", -- 426
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 449
} -- 449
local EXPOSED_PROMPT_PACK_KEYS = { -- 452
	"agentIdentityPrompt", -- 453
	"mainAgentRolePrompt", -- 454
	"subAgentRolePrompt", -- 455
	"replyLanguageDirectiveZh", -- 456
	"replyLanguageDirectiveEn" -- 457
} -- 457
local INTERNAL_PROMPT_PACK_KEYS = { -- 460
	"functionCallingPrompt", -- 461
	"toolDefinitionsDetailed", -- 462
	"mainAgentToolDefinitionsDetailed", -- 463
	"xmlToolDefinitionsDetailed", -- 464
	"toolCallingRetryPrompt", -- 465
	"xmlDecisionFormatPrompt", -- 466
	"xmlDecisionRepairPrompt", -- 467
	"xmlDecisionSystemRepairPrompt", -- 468
	"memoryCompressionSystemPrompt", -- 469
	"memoryCompressionBodyPrompt", -- 470
	"memoryCompressionToolCallingPrompt", -- 471
	"memoryCompressionXmlPrompt", -- 472
	"memoryCompressionXmlRetryPrompt" -- 473
} -- 473
local function replaceTemplateVars(template, vars) -- 476
	local output = template -- 477
	for key in pairs(vars) do -- 478
		output = table.concat( -- 479
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 479
			vars[key] or "" or "," -- 479
		) -- 479
	end -- 479
	return output -- 481
end -- 476
function ____exports.resolveAgentPromptPack(value) -- 484
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 485
	if value and not isArray(value) and isRecord(value) then -- 485
		do -- 485
			local i = 0 -- 489
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 489
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 490
				if type(value[key]) == "string" then -- 490
					merged[key] = value[key] -- 492
				end -- 492
				i = i + 1 -- 489
			end -- 489
		end -- 489
	end -- 489
	return merged -- 496
end -- 484
function ____exports.renderDefaultAgentPromptPackMarkdown(overrides) -- 499
	local lines = {} -- 500
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 501
	lines[#lines + 1] = "" -- 502
	lines[#lines + 1] = "Edit the content under each `##` heading. Tool-calling and decision-format prompts are kept in code and are not exposed here." -- 503
	lines[#lines + 1] = "" -- 504
	do -- 504
		local i = 0 -- 505
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 505
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 506
			lines[#lines + 1] = ("## `" .. key) .. "`" -- 507
			local text = type(overrides and overrides[key]) == "string" and overrides[key] or ____exports.DEFAULT_AGENT_PROMPT_PACK[key] -- 508
			local split = __TS__StringSplit(text, "\n") -- 511
			do -- 511
				local j = 0 -- 512
				while j < #split do -- 512
					lines[#lines + 1] = split[j + 1] -- 513
					j = j + 1 -- 512
				end -- 512
			end -- 512
			lines[#lines + 1] = "" -- 515
			i = i + 1 -- 505
		end -- 505
	end -- 505
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 517
end -- 499
local function getPromptPackConfigPath(projectRoot) -- 520
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 521
end -- 520
local function ensurePromptPackConfig(projectRoot) -- 524
	local path = getPromptPackConfigPath(projectRoot) -- 525
	if Content:exist(path) then -- 525
		return nil -- 526
	end -- 526
	local dir = Path:getPath(path) -- 527
	if not Content:exist(dir) then -- 527
		Content:mkdir(dir) -- 529
	end -- 529
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 531
	if not Content:save(path, content) then -- 531
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 533
	end -- 533
	sendWebIDEFileUpdate(path, true, content) -- 535
	return nil -- 536
end -- 524
local function rewriteDefaultPromptPackConfig(path, overrides) -- 539
	local content = ____exports.renderDefaultAgentPromptPackMarkdown(overrides) -- 540
	if not Content:save(path, content) then -- 540
		return ("Failed to recreate default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 542
	end -- 542
	sendWebIDEFileUpdate(path, true, content) -- 544
	return nil -- 545
end -- 539
local function parsePromptPackMarkdown(text) -- 548
	if not text or __TS__StringTrim(text) == "" then -- 548
		return { -- 556
			value = {}, -- 557
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 558
			unknown = {}, -- 559
			removed = {} -- 560
		} -- 560
	end -- 560
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 563
	local lines = __TS__StringSplit(normalized, "\n") -- 564
	local sections = {} -- 565
	local unknown = {} -- 566
	local removed = {} -- 567
	local currentHeading = "" -- 568
	local function isKnownPromptPackKey(name) -- 569
		do -- 569
			local i = 0 -- 570
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 570
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 570
					return true -- 571
				end -- 571
				i = i + 1 -- 570
			end -- 570
		end -- 570
		return false -- 573
	end -- 569
	local function isInternalPromptPackKey(name) -- 575
		do -- 575
			local i = 0 -- 576
			while i < #INTERNAL_PROMPT_PACK_KEYS do -- 576
				if INTERNAL_PROMPT_PACK_KEYS[i + 1] == name then -- 576
					return true -- 577
				end -- 577
				i = i + 1 -- 576
			end -- 576
		end -- 576
		return false -- 579
	end -- 575
	do -- 575
		local i = 0 -- 581
		while i < #lines do -- 581
			do -- 581
				local line = lines[i + 1] -- 582
				local matchedHeading = string.match(line, "^##[ \t]+`([^`]+)`[ \t]*$") -- 583
				if matchedHeading ~= nil then -- 583
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 585
					if isKnownPromptPackKey(heading) then -- 585
						currentHeading = heading -- 587
						if sections[currentHeading] == nil then -- 587
							sections[currentHeading] = {} -- 589
						end -- 589
						goto __continue42 -- 591
					end -- 591
					if isInternalPromptPackKey(heading) then -- 591
						currentHeading = "" -- 594
						removed[#removed + 1] = heading -- 595
						goto __continue42 -- 596
					end -- 596
					unknown[#unknown + 1] = heading -- 598
					currentHeading = "" -- 599
					goto __continue42 -- 600
				end -- 600
				if currentHeading ~= "" then -- 600
					local ____sections_currentHeading_2 = sections[currentHeading] -- 600
					____sections_currentHeading_2[#____sections_currentHeading_2 + 1] = line -- 603
				end -- 603
			end -- 603
			::__continue42:: -- 603
			i = i + 1 -- 581
		end -- 581
	end -- 581
	local value = {} -- 606
	local missing = {} -- 607
	do -- 607
		local i = 0 -- 608
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 608
			do -- 608
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 609
				local section = sections[key] -- 610
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 611
				if body == "" then -- 611
					missing[#missing + 1] = key -- 613
					goto __continue49 -- 614
				end -- 614
				value[key] = body -- 616
			end -- 616
			::__continue49:: -- 616
			i = i + 1 -- 608
		end -- 608
	end -- 608
	if #__TS__ObjectKeys(sections) == 0 then -- 608
		return {error = NO_PROMPT_PACK_SECTIONS_ERROR, missing = missing, unknown = unknown, removed = removed} -- 619
	end -- 619
	return {value = value, missing = missing, unknown = unknown, removed = removed} -- 626
end -- 548
function ____exports.loadAgentPromptPack(projectRoot) -- 629
	local path = getPromptPackConfigPath(projectRoot) -- 630
	local warnings = {} -- 631
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 632
	if ensureWarning and ensureWarning ~= "" then -- 632
		warnings[#warnings + 1] = ensureWarning -- 634
	end -- 634
	if not Content:exist(path) then -- 634
		return { -- 637
			pack = ____exports.resolveAgentPromptPack(), -- 638
			warnings = warnings, -- 639
			path = path -- 640
		} -- 640
	end -- 640
	local text = Content:load(path) -- 643
	if not text or __TS__StringTrim(text) == "" then -- 643
		local rewriteWarning = rewriteDefaultPromptPackConfig(path) -- 645
		if rewriteWarning then -- 645
			warnings[#warnings + 1] = rewriteWarning -- 647
		else -- 647
			warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Recreated default prompt config." -- 649
		end -- 649
		return { -- 651
			pack = ____exports.resolveAgentPromptPack(), -- 652
			warnings = warnings, -- 653
			path = path -- 654
		} -- 654
	end -- 654
	local parsed = parsePromptPackMarkdown(text) -- 657
	if parsed.error == NO_PROMPT_PACK_SECTIONS_ERROR then -- 657
		local rewriteWarning = rewriteDefaultPromptPackConfig(path) -- 659
		if rewriteWarning then -- 659
			warnings[#warnings + 1] = rewriteWarning -- 661
		else -- 661
			warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " has no prompt sections. Recreated default prompt config." -- 663
		end -- 663
		return { -- 665
			pack = ____exports.resolveAgentPromptPack(), -- 666
			warnings = warnings, -- 667
			path = path -- 668
		} -- 668
	end -- 668
	if parsed.error or not parsed.value then -- 668
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 672
		return { -- 673
			pack = ____exports.resolveAgentPromptPack(), -- 674
			warnings = warnings, -- 675
			path = path -- 676
		} -- 676
	end -- 676
	if #parsed.unknown > 0 then -- 676
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 680
	end -- 680
	if #parsed.missing > 0 then -- 680
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 683
	end -- 683
	if #parsed.removed > 0 then -- 683
		local rewriteWarning = rewriteDefaultPromptPackConfig(path, parsed.value) -- 686
		if rewriteWarning then -- 686
			warnings[#warnings + 1] = rewriteWarning -- 688
		else -- 688
			warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contained internal tool/system prompt sections and was rewritten without them: ") .. table.concat(parsed.removed, ", ")) .. "." -- 690
		end -- 690
	end -- 690
	return { -- 693
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 694
		warnings = warnings, -- 695
		path = path -- 696
	} -- 696
end -- 629
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 777
local TokenEstimator = ____exports.TokenEstimator -- 777
TokenEstimator.name = "TokenEstimator" -- 777
function TokenEstimator.prototype.____constructor(self) -- 777
end -- 777
function TokenEstimator.estimate(self, text) -- 781
	if text == "" then -- 781
		return 0 -- 782
	end -- 782
	return App:estimateTokens(text) -- 783
end -- 781
function TokenEstimator.estimateMessages(self, messages) -- 786
	if messages == nil or #messages == 0 then -- 786
		return 0 -- 787
	end -- 787
	local total = 0 -- 788
	do -- 788
		local i = 0 -- 789
		while i < #messages do -- 789
			local message = messages[i + 1] -- 790
			total = total + self:estimate(message.role or "") -- 791
			total = total + self:estimate(message.content or "") -- 792
			total = total + self:estimate(message.name or "") -- 793
			total = total + self:estimate(message.tool_call_id or "") -- 794
			total = total + self:estimate(message.reasoning_content or "") -- 795
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 796
			total = total + self:estimate(toolCallsText or "") -- 797
			total = total + 8 -- 798
			i = i + 1 -- 789
		end -- 789
	end -- 789
	return total -- 800
end -- 786
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 803
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 808
end -- 803
local function encodeCompressionDebugJSON(value) -- 816
	local text, err = safeJsonEncode(value) -- 817
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 818
end -- 816
local function utf8TakeHead(text, maxChars) -- 821
	if maxChars <= 0 or text == "" then -- 821
		return "" -- 822
	end -- 822
	local nextPos = utf8.offset(text, maxChars + 1) -- 823
	if nextPos == nil then -- 823
		return text -- 824
	end -- 824
	return string.sub(text, 1, nextPos - 1) -- 825
end -- 821
local function utf8TakeTail(text, maxChars) -- 828
	if maxChars <= 0 or text == "" then -- 828
		return "" -- 829
	end -- 829
	local charLen = utf8.len(text) -- 830
	if charLen == nil or charLen <= maxChars then -- 830
		return text -- 831
	end -- 831
	local startChar = math.max(1, charLen - maxChars + 1) -- 832
	local startPos = utf8.offset(text, startChar) -- 833
	if startPos == nil then -- 833
		return text -- 834
	end -- 834
	return string.sub(text, startPos) -- 835
end -- 828
local function ensureDirRecursive(dir) -- 838
	if not dir or dir == "" then -- 838
		return false -- 839
	end -- 839
	if Content:exist(dir) then -- 839
		return Content:isdir(dir) -- 840
	end -- 840
	local parent = Path:getPath(dir) -- 841
	if parent and parent ~= dir and not Content:exist(parent) then -- 841
		if not ensureDirRecursive(parent) then -- 841
			return false -- 844
		end -- 844
	end -- 844
	return Content:mkdir(dir) -- 847
end -- 838
local function normalizeMemoryFileContent(content, template, importedSectionTitle) -- 850
	local safeContent = type(content) == "string" and sanitizeUTF8(content) or "" -- 851
	local trimmed = __TS__StringTrim(safeContent) -- 852
	if trimmed == "" then -- 852
		return template -- 853
	end -- 853
	if (string.find(trimmed, "\n## ", nil, true) or 0) - 1 >= 0 or (string.find(trimmed, "\n# ", nil, true) or 0) - 1 >= 0 or string.sub(trimmed, 1, 3) == "## " or string.sub(trimmed, 1, 2) == "# " then -- 853
		return safeContent -- 855
	end -- 855
	return ((((__TS__StringTrim(template) .. "\n\n## ") .. importedSectionTitle) .. "\n\n") .. trimmed) .. "\n" -- 857
end -- 850
local function splitMemorySections(text) -- 860
	local sections = {} -- 861
	local lines = __TS__StringSplit( -- 862
		sanitizeUTF8(text or ""), -- 862
		"\n" -- 862
	) -- 862
	local title = "Overview" -- 863
	local bodyLines = {} -- 864
	local index = 0 -- 865
	local function flush() -- 866
		local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 867
		if body ~= "" then -- 867
			local fullText = title == "Overview" and body or (("## " .. title) .. "\n\n") .. body -- 869
			sections[#sections + 1] = { -- 870
				title = title, -- 870
				body = body, -- 870
				fullText = fullText, -- 870
				index = index, -- 870
				score = 0 -- 870
			} -- 870
			index = index + 1 -- 871
		end -- 871
	end -- 866
	do -- 866
		local i = 0 -- 874
		while i < #lines do -- 874
			do -- 874
				local line = lines[i + 1] -- 875
				if string.sub(line, 1, 3) == "## " then -- 875
					flush() -- 877
					title = __TS__StringTrim(string.sub(line, 4)) -- 878
					bodyLines = {} -- 879
				elseif string.sub(line, 1, 2) == "# " then -- 879
					goto __continue95 -- 881
				else -- 881
					bodyLines[#bodyLines + 1] = line -- 883
				end -- 883
			end -- 883
			::__continue95:: -- 883
			i = i + 1 -- 874
		end -- 874
	end -- 874
	flush() -- 886
	return sections -- 887
end -- 860
local function collectQueryTerms(query) -- 890
	local terms = {} -- 891
	local lower = string.lower(sanitizeUTF8(query or "")) -- 892
	local current = "" -- 893
	local function pushCurrent() -- 894
		local word = __TS__StringTrim(current) -- 895
		if #word >= 2 and __TS__ArrayIndexOf(terms, word) < 0 then -- 895
			terms[#terms + 1] = word -- 897
		end -- 897
		current = "" -- 899
	end -- 894
	do -- 894
		local i = 0 -- 901
		while i < #lower do -- 901
			local ch = __TS__StringCharAt(lower, i) -- 902
			local code = __TS__StringCharCodeAt(lower, i) -- 903
			local isAsciiWord = code >= 48 and code <= 57 or code >= 97 and code <= 122 or ch == "_" or ch == "-" or ch == "." -- 904
			if isAsciiWord then -- 904
				current = current .. ch -- 906
			else -- 906
				pushCurrent() -- 908
				if code > 127 and __TS__ArrayIndexOf(terms, ch) < 0 then -- 908
					terms[#terms + 1] = ch -- 909
				end -- 909
			end -- 909
			i = i + 1 -- 901
		end -- 901
	end -- 901
	pushCurrent() -- 912
	return terms -- 913
end -- 890
local function countOccurrences(text, term) -- 916
	if text == "" or term == "" then -- 916
		return 0 -- 917
	end -- 917
	local count = 0 -- 918
	local start = 0 -- 919
	while true do -- 919
		local pos = (string.find( -- 921
			text, -- 921
			term, -- 921
			math.max(start + 1, 1), -- 921
			true -- 921
		) or 0) - 1 -- 921
		if pos < 0 then -- 921
			break -- 922
		end -- 922
		count = count + 1 -- 923
		start = pos + #term -- 924
	end -- 924
	return count -- 926
end -- 916
local function scoreMemorySection(section, terms) -- 929
	local titleLower = string.lower(section.title) -- 930
	local bodyLower = string.lower(section.body) -- 931
	local score = 0 -- 932
	do -- 932
		local i = 0 -- 933
		while i < #terms do -- 933
			local term = terms[i + 1] -- 934
			score = score + countOccurrences(titleLower, term) * 6 -- 935
			score = score + countOccurrences(bodyLower, term) -- 936
			i = i + 1 -- 933
		end -- 933
	end -- 933
	if (string.find(titleLower, "user preference", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "stable fact", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "known decision", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "known issue", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "current goal", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "recent progress", nil, true) or 0) - 1 >= 0 or (string.find(titleLower, "build and run", nil, true) or 0) - 1 >= 0 then -- 933
		score = score + (#terms > 0 and 1 or 3) -- 947
	end -- 947
	return score -- 949
end -- 929
local function selectRelevantMemoryText(text, query, maxTokens) -- 952
	local sections = splitMemorySections(text) -- 953
	if #sections == 0 then -- 953
		return "" -- 954
	end -- 954
	local budget = math.max(MEMORY_LAYER_MIN_TOKENS, maxTokens) -- 955
	local terms = collectQueryTerms(query) -- 956
	do -- 956
		local i = 0 -- 957
		while i < #sections do -- 957
			sections[i + 1].score = scoreMemorySection(sections[i + 1], terms) -- 958
			i = i + 1 -- 957
		end -- 957
	end -- 957
	local ranked = __TS__ArraySlice(sections) -- 960
	__TS__ArraySort( -- 961
		ranked, -- 961
		function(____, a, b) -- 961
			if a.score ~= b.score then -- 961
				return b.score - a.score -- 962
			end -- 962
			return a.index - b.index -- 963
		end -- 961
	) -- 961
	local selected = {} -- 965
	local used = 0 -- 966
	do -- 966
		local i = 0 -- 967
		while i < #ranked do -- 967
			do -- 967
				local section = ranked[i + 1] -- 968
				if #terms > 0 and section.score <= 0 then -- 968
					goto __continue122 -- 969
				end -- 969
				local cost = ____exports.TokenEstimator:estimate(section.fullText) + 12 -- 970
				if #selected > 0 and used + cost > budget then -- 970
					goto __continue122 -- 971
				end -- 971
				selected[#selected + 1] = section -- 972
				used = used + cost -- 973
				if used >= budget then -- 973
					break -- 974
				end -- 974
			end -- 974
			::__continue122:: -- 974
			i = i + 1 -- 967
		end -- 967
	end -- 967
	if #selected == 0 then -- 967
		do -- 967
			local i = 0 -- 977
			while i < #sections do -- 977
				do -- 977
					local section = sections[i + 1] -- 978
					local cost = ____exports.TokenEstimator:estimate(section.fullText) + 12 -- 979
					if #selected > 0 and used + cost > budget then -- 979
						goto __continue128 -- 980
					end -- 980
					selected[#selected + 1] = section -- 981
					used = used + cost -- 982
					if used >= budget then -- 982
						break -- 983
					end -- 983
				end -- 983
				::__continue128:: -- 983
				i = i + 1 -- 977
			end -- 977
		end -- 977
	end -- 977
	__TS__ArraySort( -- 986
		selected, -- 986
		function(____, a, b) return a.index - b.index end -- 986
	) -- 986
	return table.concat( -- 987
		__TS__ArrayMap( -- 987
			selected, -- 987
			function(____, section) return section.fullText end -- 987
		), -- 987
		"\n\n" -- 987
	) -- 987
end -- 952
local function formatMemoryLayer(title, content) -- 990
	local trimmed = __TS__StringTrim(sanitizeUTF8(content or "")) -- 991
	if trimmed == "" then -- 991
		return "" -- 992
	end -- 992
	return (("#### " .. title) .. "\n\n") .. trimmed -- 993
end -- 990
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.jsonl (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 1001
local DualLayerStorage = ____exports.DualLayerStorage -- 1001
DualLayerStorage.name = "DualLayerStorage" -- 1001
function DualLayerStorage.prototype.____constructor(self, projectDir, scope) -- 1012
	if scope == nil then -- 1012
		scope = "" -- 1012
	end -- 1012
	self.projectDir = projectDir -- 1013
	self.scope = scope -- 1014
	self.agentRootDir = Path(self.projectDir, ".agent") -- 1015
	self.agentDir = scope ~= "" and Path(self.agentRootDir, scope) or self.agentRootDir -- 1016
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 1019
	self.projectMemoryPath = Path(self.agentDir, "PROJECT_MEMORY.md") -- 1020
	self.sessionSummaryPath = Path(self.agentDir, "SESSION_SUMMARY.md") -- 1021
	self.historyPath = Path(self.agentDir, HISTORY_JSONL_FILE) -- 1022
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 1023
	self:ensureAgentFiles() -- 1024
end -- 1012
function DualLayerStorage.prototype.ensureDir(self, dir) -- 1027
	if not Content:exist(dir) then -- 1027
		ensureDirRecursive(dir) -- 1029
	end -- 1029
end -- 1027
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 1033
	if Content:exist(path) then -- 1033
		return false -- 1034
	end -- 1034
	self:ensureDir(Path:getPath(path)) -- 1035
	if not Content:save(path, content) then -- 1035
		return false -- 1037
	end -- 1037
	sendWebIDEFileUpdate(path, true, content) -- 1039
	return true -- 1040
end -- 1033
function DualLayerStorage.prototype.ensureStructuredMemoryFile(self, path, template) -- 1043
	if not Content:exist(path) then -- 1043
		self:ensureFile(path, template) -- 1045
		return -- 1046
	end -- 1046
	local current = Content:load(path) -- 1048
	if type(current) ~= "string" or __TS__StringTrim(current) == "" then -- 1048
		Content:save(path, template) -- 1050
		sendWebIDEFileUpdate(path, true, template) -- 1051
	end -- 1051
end -- 1043
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 1055
	self:ensureDir(self.agentRootDir) -- 1056
	self:ensureDir(self.agentDir) -- 1057
	self:ensureStructuredMemoryFile(self.memoryPath, DEFAULT_CORE_MEMORY_TEMPLATE) -- 1058
	self:ensureStructuredMemoryFile(self.projectMemoryPath, DEFAULT_PROJECT_MEMORY_TEMPLATE) -- 1059
	self:ensureStructuredMemoryFile(self.sessionSummaryPath, DEFAULT_SESSION_SUMMARY_TEMPLATE) -- 1060
	self:ensureFile(self.historyPath, "") -- 1061
end -- 1055
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 1064
	local text = safeJsonEncode(value) -- 1065
	return text -- 1066
end -- 1064
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 1069
	local value = safeJsonDecode(text) -- 1070
	return value -- 1071
end -- 1069
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 1074
	if not value or isArray(value) or not isRecord(value) then -- 1074
		return nil -- 1075
	end -- 1075
	local row = value -- 1076
	local role = type(row.role) == "string" and row.role or "" -- 1077
	if role == "" then -- 1077
		return nil -- 1078
	end -- 1078
	local message = {role = role} -- 1079
	if type(row.content) == "string" then -- 1079
		message.content = sanitizeUTF8(row.content) -- 1080
	end -- 1080
	if type(row.name) == "string" then -- 1080
		message.name = sanitizeUTF8(row.name) -- 1081
	end -- 1081
	if type(row.tool_call_id) == "string" then -- 1081
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 1082
	end -- 1082
	if type(row.reasoning_content) == "string" then -- 1082
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 1083
	end -- 1083
	if type(row.timestamp) == "string" then -- 1083
		message.timestamp = sanitizeUTF8(row.timestamp) -- 1084
	end -- 1084
	if isArray(row.tool_calls) then -- 1084
		message.tool_calls = row.tool_calls -- 1086
	end -- 1086
	return message -- 1088
end -- 1074
function DualLayerStorage.prototype.decodeHistoryRecord(self, value) -- 1091
	if not value or isArray(value) or not isRecord(value) then -- 1091
		return nil -- 1092
	end -- 1092
	local row = value -- 1093
	local ts = type(row.ts) == "string" and __TS__StringTrim(row.ts) ~= "" and sanitizeUTF8(row.ts) or "" -- 1094
	local summary = type(row.summary) == "string" and __TS__StringTrim(row.summary) ~= "" and sanitizeUTF8(row.summary) or nil -- 1097
	local rawArchive = type(row.rawArchive) == "string" and __TS__StringTrim(row.rawArchive) ~= "" and sanitizeUTF8(row.rawArchive) or nil -- 1100
	if ts == "" or summary == nil and rawArchive == nil then -- 1100
		return nil -- 1103
	end -- 1103
	local record = {ts = ts, summary = summary, rawArchive = rawArchive} -- 1104
	return record -- 1109
end -- 1091
function DualLayerStorage.prototype.readSpawnInfo(self, path) -- 1112
	if not Content:exist(path) then -- 1112
		return nil -- 1113
	end -- 1113
	local text = Content:load(path) -- 1114
	if not text or __TS__StringTrim(text) == "" then -- 1114
		return nil -- 1115
	end -- 1115
	local value = safeJsonDecode(text) -- 1116
	if value and not isArray(value) and isRecord(value) then -- 1116
		return value -- 1118
	end -- 1118
	return nil -- 1120
end -- 1112
function DualLayerStorage.prototype.normalizeEvidence(self, value) -- 1123
	local evidence = {} -- 1124
	if not isArray(value) then -- 1124
		return evidence -- 1125
	end -- 1125
	do -- 1125
		local i = 0 -- 1126
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1126
			local item = type(value[i + 1]) == "string" and __TS__StringTrim(sanitizeUTF8(value[i + 1])) or "" -- 1127
			if item ~= "" and __TS__ArrayIndexOf(evidence, item) < 0 then -- 1127
				evidence[#evidence + 1] = item -- 1129
			end -- 1129
			i = i + 1 -- 1126
		end -- 1126
	end -- 1126
	return evidence -- 1132
end -- 1123
function DualLayerStorage.prototype.decodeSubAgentLearning(self, value, fallbackSortTs) -- 1135
	if not value or isArray(value) or not isRecord(value) then -- 1135
		return nil -- 1136
	end -- 1136
	local sourceSessionId = type(value.sourceSessionId) == "number" and math.floor(value.sourceSessionId) or 0 -- 1137
	local sourceTaskId = type(value.sourceTaskId) == "number" and math.floor(value.sourceTaskId) or 0 -- 1138
	local content = type(value.content) == "string" and utf8TakeHead( -- 1139
		__TS__StringTrim(sanitizeUTF8(value.content)), -- 1140
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1140
	) or "" -- 1140
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 1140
		return nil -- 1142
	end -- 1142
	return { -- 1143
		sourceSessionId = sourceSessionId, -- 1144
		sourceTaskId = sourceTaskId, -- 1145
		content = content, -- 1146
		evidence = self:normalizeEvidence(value.evidence), -- 1147
		createdAt = type(value.createdAt) == "string" and __TS__StringTrim(sanitizeUTF8(value.createdAt)) or "", -- 1148
		sortTs = fallbackSortTs -- 1149
	} -- 1149
end -- 1135
function DualLayerStorage.prototype.readSubAgentLearningEntries(self) -- 1153
	if self.scope ~= "" and self.scope ~= "main" then -- 1153
		return {} -- 1154
	end -- 1154
	local subAgentsDir = Path(self.agentRootDir, "subagents") -- 1155
	if not Content:exist(subAgentsDir) or not Content:isdir(subAgentsDir) then -- 1155
		return {} -- 1156
	end -- 1156
	local entries = {} -- 1157
	local seen = {} -- 1158
	for ____, rawPath in ipairs(Content:getDirs(subAgentsDir)) do -- 1159
		do -- 1159
			local dir = Content:isAbsolutePath(rawPath) and rawPath or Path(subAgentsDir, rawPath) -- 1160
			if not Content:exist(dir) or not Content:isdir(dir) then -- 1160
				goto __continue174 -- 1161
			end -- 1161
			local info = self:readSpawnInfo(Path(dir, SUB_AGENT_SPAWN_INFO_FILE)) -- 1162
			if info == nil or info.success ~= true then -- 1162
				goto __continue174 -- 1163
			end -- 1163
			local fallbackSortTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or 0 -- 1164
			local entry = self:decodeSubAgentLearning(info.memoryEntry, fallbackSortTs) -- 1165
			if entry == nil then -- 1165
				goto __continue174 -- 1166
			end -- 1166
			local key = (tostring(entry.sourceSessionId) .. ":") .. tostring(entry.sourceTaskId) -- 1167
			if seen[key] then -- 1167
				goto __continue174 -- 1168
			end -- 1168
			seen[key] = true -- 1169
			entries[#entries + 1] = entry -- 1170
		end -- 1170
		::__continue174:: -- 1170
	end -- 1170
	__TS__ArraySort( -- 1172
		entries, -- 1172
		function(____, a, b) return b.sortTs - a.sortTs end -- 1172
	) -- 1172
	return entries -- 1173
end -- 1153
function DualLayerStorage.prototype.buildSubAgentLearningsContext(self) -- 1176
	local entries = self:readSubAgentLearningEntries() -- 1177
	if #entries == 0 then -- 1177
		return "" -- 1178
	end -- 1178
	local lines = {"## Sub-Agent Learnings", ""} -- 1179
	local totalChars = 0 -- 1180
	local count = 0 -- 1181
	do -- 1181
		local i = 0 -- 1182
		while i < #entries and count < SUB_AGENT_LEARNINGS_MAX_ITEMS do -- 1182
			local entry = entries[i + 1] -- 1183
			local evidence = #entry.evidence > 0 and "\n  Evidence: " .. table.concat(entry.evidence, ", ") or "" -- 1184
			local line = ((((("- [sub-agent:" .. tostring(entry.sourceSessionId)) .. "/task:") .. tostring(entry.sourceTaskId)) .. "] ") .. entry.content) .. evidence -- 1185
			if totalChars + #line > SUB_AGENT_LEARNINGS_MAX_CHARS then -- 1185
				break -- 1186
			end -- 1186
			lines[#lines + 1] = line -- 1187
			totalChars = totalChars + #line -- 1188
			count = count + 1 -- 1189
			i = i + 1 -- 1182
		end -- 1182
	end -- 1182
	return count > 0 and table.concat(lines, "\n") or "" -- 1191
end -- 1176
function DualLayerStorage.prototype.readHistoryRecords(self) -- 1194
	if not Content:exist(self.historyPath) then -- 1194
		return {} -- 1196
	end -- 1196
	local text = Content:load(self.historyPath) -- 1198
	if not text or __TS__StringTrim(text) == "" then -- 1198
		return {} -- 1200
	end -- 1200
	local lines = __TS__StringSplit(text, "\n") -- 1202
	local records = {} -- 1203
	do -- 1203
		local i = 0 -- 1204
		while i < #lines do -- 1204
			do -- 1204
				local line = __TS__StringTrim(lines[i + 1]) -- 1205
				if line == "" then -- 1205
					goto __continue190 -- 1206
				end -- 1206
				local decoded = self:decodeJsonLine(line) -- 1207
				local record = self:decodeHistoryRecord(decoded) -- 1208
				if record ~= nil then -- 1208
					records[#records + 1] = record -- 1210
				end -- 1210
			end -- 1210
			::__continue190:: -- 1210
			i = i + 1 -- 1204
		end -- 1204
	end -- 1204
	return records -- 1213
end -- 1194
function DualLayerStorage.prototype.saveHistoryRecords(self, records) -- 1216
	self:ensureDir(Path:getPath(self.historyPath)) -- 1217
	local normalized = #records > HISTORY_MAX_RECORDS and __TS__ArraySlice(records, #records - HISTORY_MAX_RECORDS) or records -- 1218
	local lines = {} -- 1221
	do -- 1221
		local i = 0 -- 1222
		while i < #normalized do -- 1222
			local line = self:encodeJsonLine(normalized[i + 1]) -- 1223
			if type(line) == "string" and line ~= "" then -- 1223
				lines[#lines + 1] = line -- 1225
			end -- 1225
			i = i + 1 -- 1222
		end -- 1222
	end -- 1222
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 1228
	Content:save(self.historyPath, content) -- 1229
	sendWebIDEFileUpdate(self.historyPath, true, content) -- 1230
end -- 1216
function DualLayerStorage.prototype.readMemory(self) -- 1238
	if not Content:exist(self.memoryPath) then -- 1238
		return DEFAULT_CORE_MEMORY_TEMPLATE -- 1240
	end -- 1240
	return normalizeMemoryFileContent( -- 1242
		Content:load(self.memoryPath), -- 1242
		DEFAULT_CORE_MEMORY_TEMPLATE, -- 1242
		"Imported Notes" -- 1242
	) -- 1242
end -- 1238
function DualLayerStorage.prototype.writeMemory(self, content) -- 1248
	local normalized = normalizeMemoryFileContent(content, DEFAULT_CORE_MEMORY_TEMPLATE, "Imported Notes") -- 1249
	self:ensureDir(Path:getPath(self.memoryPath)) -- 1250
	Content:save(self.memoryPath, normalized) -- 1251
	sendWebIDEFileUpdate(self.memoryPath, true, normalized) -- 1252
end -- 1248
function DualLayerStorage.prototype.readProjectMemory(self) -- 1255
	if not Content:exist(self.projectMemoryPath) then -- 1255
		return DEFAULT_PROJECT_MEMORY_TEMPLATE -- 1257
	end -- 1257
	return normalizeMemoryFileContent( -- 1259
		Content:load(self.projectMemoryPath), -- 1259
		DEFAULT_PROJECT_MEMORY_TEMPLATE, -- 1259
		"Imported Project Notes" -- 1259
	) -- 1259
end -- 1255
function DualLayerStorage.prototype.writeProjectMemory(self, content) -- 1262
	local normalized = normalizeMemoryFileContent(content, DEFAULT_PROJECT_MEMORY_TEMPLATE, "Imported Project Notes") -- 1263
	self:ensureDir(Path:getPath(self.projectMemoryPath)) -- 1264
	Content:save(self.projectMemoryPath, normalized) -- 1265
	sendWebIDEFileUpdate(self.projectMemoryPath, true, normalized) -- 1266
end -- 1262
function DualLayerStorage.prototype.readSessionSummary(self) -- 1269
	if not Content:exist(self.sessionSummaryPath) then -- 1269
		return DEFAULT_SESSION_SUMMARY_TEMPLATE -- 1271
	end -- 1271
	return normalizeMemoryFileContent( -- 1273
		Content:load(self.sessionSummaryPath), -- 1273
		DEFAULT_SESSION_SUMMARY_TEMPLATE, -- 1273
		"Imported Session Notes" -- 1273
	) -- 1273
end -- 1269
function DualLayerStorage.prototype.writeSessionSummary(self, content) -- 1276
	local normalized = normalizeMemoryFileContent(content, DEFAULT_SESSION_SUMMARY_TEMPLATE, "Imported Session Notes") -- 1277
	self:ensureDir(Path:getPath(self.sessionSummaryPath)) -- 1278
	Content:save(self.sessionSummaryPath, normalized) -- 1279
	sendWebIDEFileUpdate(self.sessionSummaryPath, true, normalized) -- 1280
end -- 1276
function DualLayerStorage.prototype.getRelevantMemoryContext(self, query, maxTokens) -- 1286
	if query == nil then -- 1286
		query = "" -- 1286
	end -- 1286
	if maxTokens == nil then -- 1286
		maxTokens = MEMORY_CONTEXT_DEFAULT_MAX_TOKENS -- 1286
	end -- 1286
	local budget = math.max( -- 1287
		MEMORY_CONTEXT_MIN_MAX_TOKENS, -- 1287
		math.floor(maxTokens) -- 1287
	) -- 1287
	local coreBudget = math.floor(budget * 0.3) -- 1288
	local projectBudget = math.floor(budget * 0.35) -- 1289
	local sessionBudget = math.floor(budget * 0.2) -- 1290
	local subAgentBudget = math.max(0, budget - coreBudget - projectBudget - sessionBudget - 160) -- 1291
	local sections = {} -- 1292
	local core = formatMemoryLayer( -- 1293
		"Core Memory", -- 1293
		selectRelevantMemoryText( -- 1293
			self:readMemory(), -- 1293
			query, -- 1293
			coreBudget -- 1293
		) -- 1293
	) -- 1293
	if core ~= "" then -- 1293
		sections[#sections + 1] = core -- 1294
	end -- 1294
	local project = formatMemoryLayer( -- 1295
		"Project Memory", -- 1295
		selectRelevantMemoryText( -- 1295
			self:readProjectMemory(), -- 1295
			query, -- 1295
			projectBudget -- 1295
		) -- 1295
	) -- 1295
	if project ~= "" then -- 1295
		sections[#sections + 1] = project -- 1296
	end -- 1296
	local session = formatMemoryLayer( -- 1297
		"Session Summary", -- 1297
		selectRelevantMemoryText( -- 1297
			self:readSessionSummary(), -- 1297
			query, -- 1297
			sessionBudget -- 1297
		) -- 1297
	) -- 1297
	if session ~= "" then -- 1297
		sections[#sections + 1] = session -- 1298
	end -- 1298
	local subAgentLearnings = self:buildSubAgentLearningsContext() -- 1299
	if subAgentLearnings ~= "" then -- 1299
		sections[#sections + 1] = formatMemoryLayer( -- 1301
			"Sub-Agent Learnings", -- 1301
			clipTextToTokenBudget(subAgentLearnings, subAgentBudget > 0 and subAgentBudget or MEMORY_LAYER_MIN_TOKENS) -- 1301
		) -- 1301
	end -- 1301
	if #sections == 0 then -- 1301
		return "" -- 1303
	end -- 1303
	local output = "### Relevant Memory\n\n" .. table.concat(sections, "\n\n") -- 1304
	return ____exports.TokenEstimator:estimate(output) > budget and clipTextToTokenBudget(output, budget) or output -- 1305
end -- 1286
function DualLayerStorage.prototype.getMemoryContext(self, query, maxTokens) -- 1311
	if query == nil then -- 1311
		query = "" -- 1311
	end -- 1311
	if maxTokens == nil then -- 1311
		maxTokens = MEMORY_CONTEXT_DEFAULT_MAX_TOKENS -- 1311
	end -- 1311
	return self:getRelevantMemoryContext(query, maxTokens) -- 1312
end -- 1311
function DualLayerStorage.prototype.appendHistoryRecord(self, record) -- 1317
	local records = self:readHistoryRecords() -- 1318
	records[#records + 1] = record -- 1319
	self:saveHistoryRecords(records) -- 1320
end -- 1317
function DualLayerStorage.prototype.readSessionState(self) -- 1323
	if not Content:exist(self.sessionPath) then -- 1323
		return {messages = {}, lastConsolidatedIndex = 0} -- 1325
	end -- 1325
	local text = Content:load(self.sessionPath) -- 1327
	if not text or __TS__StringTrim(text) == "" then -- 1327
		return {messages = {}, lastConsolidatedIndex = 0} -- 1329
	end -- 1329
	local lines = __TS__StringSplit(text, "\n") -- 1331
	local messages = {} -- 1332
	local lastConsolidatedIndex = 0 -- 1333
	local carryMessageIndex = nil -- 1334
	do -- 1334
		local i = 0 -- 1335
		while i < #lines do -- 1335
			do -- 1335
				local line = __TS__StringTrim(lines[i + 1]) -- 1336
				if line == "" then -- 1336
					goto __continue218 -- 1337
				end -- 1337
				local data = self:decodeJsonLine(line) -- 1338
				if not data or isArray(data) or not isRecord(data) then -- 1338
					goto __continue218 -- 1339
				end -- 1339
				local row = data -- 1340
				if type(row.lastConsolidatedIndex) == "number" then -- 1340
					lastConsolidatedIndex = math.floor(row.lastConsolidatedIndex) -- 1342
					if type(row.carryMessageIndex) == "number" then -- 1342
						carryMessageIndex = math.floor(row.carryMessageIndex) -- 1344
					end -- 1344
					goto __continue218 -- 1346
				end -- 1346
				local ____self_decodeConversationMessage_4 = self.decodeConversationMessage -- 1348
				local ____row_message_3 = row.message -- 1348
				if ____row_message_3 == nil then -- 1348
					____row_message_3 = row -- 1348
				end -- 1348
				local message = ____self_decodeConversationMessage_4(self, ____row_message_3) -- 1348
				if message ~= nil then -- 1348
					messages[#messages + 1] = message -- 1350
				end -- 1350
			end -- 1350
			::__continue218:: -- 1350
			i = i + 1 -- 1335
		end -- 1335
	end -- 1335
	local normalizedLastConsolidatedIndex = clampSessionIndex(messages, lastConsolidatedIndex) -- 1353
	local normalizedCarryMessageIndex = type(carryMessageIndex) == "number" and carryMessageIndex >= 0 and carryMessageIndex < normalizedLastConsolidatedIndex and carryMessageIndex < #messages and math.floor(carryMessageIndex) or nil -- 1354
	return {messages = messages, lastConsolidatedIndex = normalizedLastConsolidatedIndex, carryMessageIndex = normalizedCarryMessageIndex} -- 1360
end -- 1323
function DualLayerStorage.prototype.writeSessionState(self, messages, lastConsolidatedIndex, carryMessageIndex) -- 1367
	if messages == nil then -- 1367
		messages = {} -- 1368
	end -- 1368
	if lastConsolidatedIndex == nil then -- 1368
		lastConsolidatedIndex = 0 -- 1369
	end -- 1369
	self:ensureDir(Path:getPath(self.sessionPath)) -- 1372
	local lines = {} -- 1373
	local dropCount = #messages > SESSION_MAX_RECORDS and #messages - SESSION_MAX_RECORDS or 0 -- 1374
	local normalizedMessages = dropCount > 0 and __TS__ArraySlice(messages, dropCount) or messages -- 1377
	local normalizedLastConsolidatedIndex = clampSessionIndex(normalizedMessages, lastConsolidatedIndex - dropCount) -- 1380
	local normalizedCarryMessageIndex = type(carryMessageIndex) == "number" and carryMessageIndex - dropCount >= 0 and carryMessageIndex - dropCount < normalizedLastConsolidatedIndex and carryMessageIndex - dropCount < #normalizedMessages and math.floor(carryMessageIndex - dropCount) or nil -- 1384
	local stateLine = self:encodeJsonLine({lastConsolidatedIndex = normalizedLastConsolidatedIndex, carryMessageIndex = normalizedCarryMessageIndex}) -- 1390
	if type(stateLine) == "string" and stateLine ~= "" then -- 1390
		lines[#lines + 1] = stateLine -- 1395
	end -- 1395
	do -- 1395
		local i = 0 -- 1397
		while i < #normalizedMessages do -- 1397
			local line = self:encodeJsonLine({message = normalizedMessages[i + 1]}) -- 1398
			if type(line) == "string" and line ~= "" then -- 1398
				lines[#lines + 1] = line -- 1402
			end -- 1402
			i = i + 1 -- 1397
		end -- 1397
	end -- 1397
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 1405
	Content:save(self.sessionPath, content) -- 1406
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 1407
end -- 1367
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 1419
local MemoryCompressor = ____exports.MemoryCompressor -- 1419
MemoryCompressor.name = "MemoryCompressor" -- 1419
function MemoryCompressor.prototype.____constructor(self, config) -- 1426
	self.consecutiveFailures = 0 -- 1422
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 1427
	do -- 1427
		local i = 0 -- 1428
		while i < #loadedPromptPack.warnings do -- 1428
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 1429
			i = i + 1 -- 1428
		end -- 1428
	end -- 1428
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 1431
	self.config = __TS__ObjectAssign( -- 1434
		{}, -- 1434
		config, -- 1435
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 1434
	) -- 1434
	self.config.compressionThreshold = math.min( -- 1441
		1, -- 1441
		math.max(0.05, self.config.compressionThreshold) -- 1441
	) -- 1441
	self.config.compressionTargetThreshold = math.min( -- 1442
		self.config.compressionThreshold, -- 1443
		math.max(0.05, self.config.compressionTargetThreshold) -- 1444
	) -- 1444
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir, self.config.scope or "") -- 1446
end -- 1426
function MemoryCompressor.prototype.getPromptPack(self) -- 1449
	return self.config.promptPack -- 1450
end -- 1449
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 1456
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1461
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 1467
	return messageTokens > threshold -- 1469
end -- 1456
function MemoryCompressor.prototype.compress(self, messages, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode, systemPrompt, toolDefinitions) -- 1475
	if decisionMode == nil then -- 1475
		decisionMode = "tool_calling" -- 1479
	end -- 1479
	if boundaryMode == nil then -- 1479
		boundaryMode = "default" -- 1481
	end -- 1481
	if systemPrompt == nil then -- 1481
		systemPrompt = "" -- 1482
	end -- 1482
	if toolDefinitions == nil then -- 1482
		toolDefinitions = "" -- 1483
	end -- 1483
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1483
		local toCompress = messages -- 1485
		if #toCompress == 0 then -- 1485
			return ____awaiter_resolve(nil, nil) -- 1485
		end -- 1485
		local currentMemory = self.storage:readMemory() -- 1487
		local boundary = self:findCompressionBoundary( -- 1489
			toCompress, -- 1490
			currentMemory, -- 1491
			boundaryMode, -- 1492
			systemPrompt, -- 1493
			toolDefinitions -- 1494
		) -- 1494
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 1496
		if #chunk == 0 then -- 1496
			return ____awaiter_resolve(nil, nil) -- 1496
		end -- 1496
		local historyText = self:formatMessagesForCompression(chunk) -- 1499
		local ____hasReturned, ____returnValue -- 1499
		local ____try = __TS__AsyncAwaiter(function() -- 1499
			local result = __TS__Await(self:callLLMForCompression( -- 1503
				currentMemory, -- 1504
				historyText, -- 1505
				llmOptions, -- 1506
				maxLLMTry or 3, -- 1507
				decisionMode, -- 1508
				debugContext -- 1509
			)) -- 1509
			if result.success then -- 1509
				self.storage:writeMemory(result.memoryUpdate) -- 1514
				if type(result.projectMemoryUpdate) == "string" then -- 1514
					self.storage:writeProjectMemory(result.projectMemoryUpdate) -- 1516
				end -- 1516
				if type(result.sessionSummaryUpdate) == "string" then -- 1516
					self.storage:writeSessionSummary(result.sessionSummaryUpdate) -- 1519
				end -- 1519
				if result.ts then -- 1519
					self.storage:appendHistoryRecord({ts = result.ts, summary = result.summary}) -- 1522
				end -- 1522
				self.consecutiveFailures = 0 -- 1527
				____hasReturned = true -- 1529
				____returnValue = __TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessageIndex = boundary.carryMessageIndex}) -- 1529
				return -- 1529
			end -- 1529
			____hasReturned = true -- 1537
			____returnValue = self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 1537
			return -- 1537
		end) -- 1537
		____try = ____try.catch( -- 1537
			____try, -- 1537
			function(____, ____error) -- 1537
				return __TS__AsyncAwaiter(function() -- 1537
					____hasReturned = true -- 1540
					____returnValue = self:handleCompressionFailure( -- 1540
						chunk, -- 1540
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 1540
					) -- 1540
					return -- 1540
				end) -- 1540
			end -- 1540
		) -- 1540
		__TS__Await(____try) -- 1501
		if ____hasReturned then -- 1501
			return ____awaiter_resolve(nil, ____returnValue) -- 1501
		end -- 1501
	end) -- 1501
end -- 1475
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode, systemPrompt, toolDefinitions) -- 1549
	local targetTokens = boundaryMode == "budget_max" and math.max( -- 1556
		1, -- 1557
		self:getCompressionHistoryTokenBudget(currentMemory) -- 1557
	) or math.max( -- 1557
		1, -- 1558
		self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 1558
	) -- 1558
	local accumulatedTokens = 0 -- 1559
	local lastSafeBoundary = 0 -- 1560
	local lastSafeBoundaryWithinBudget = 0 -- 1561
	local lastClosedBoundary = 0 -- 1562
	local lastClosedBoundaryWithinBudget = 0 -- 1563
	local pendingToolCalls = {} -- 1564
	local pendingToolCallCount = 0 -- 1565
	local exceededBudget = false -- 1566
	do -- 1566
		local i = 0 -- 1568
		while i < #messages do -- 1568
			local message = messages[i + 1] -- 1569
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 1570
			accumulatedTokens = accumulatedTokens + tokens -- 1571
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1571
				do -- 1571
					local j = 0 -- 1574
					while j < #message.tool_calls do -- 1574
						local toolCallEntry = message.tool_calls[j + 1] -- 1575
						local idValue = toolCallEntry.id -- 1576
						local id = type(idValue) == "string" and idValue or "" -- 1577
						if id ~= "" and not pendingToolCalls[id] then -- 1577
							pendingToolCalls[id] = true -- 1579
							pendingToolCallCount = pendingToolCallCount + 1 -- 1580
						end -- 1580
						j = j + 1 -- 1574
					end -- 1574
				end -- 1574
			end -- 1574
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 1574
				pendingToolCalls[message.tool_call_id] = false -- 1586
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 1587
			end -- 1587
			local isAtEnd = i >= #messages - 1 -- 1590
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 1591
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 1592
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 1593
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 1594
			if isSafeBoundary then -- 1594
				lastSafeBoundary = i + 1 -- 1596
				if accumulatedTokens <= targetTokens then -- 1596
					lastSafeBoundaryWithinBudget = i + 1 -- 1598
				end -- 1598
			end -- 1598
			if isClosedToolBoundary then -- 1598
				lastClosedBoundary = i + 1 -- 1602
				if accumulatedTokens <= targetTokens then -- 1602
					lastClosedBoundaryWithinBudget = i + 1 -- 1604
				end -- 1604
			end -- 1604
			if accumulatedTokens > targetTokens and not exceededBudget then -- 1604
				exceededBudget = true -- 1609
			end -- 1609
			if exceededBudget and isSafeBoundary then -- 1609
				return self:buildCarryBoundary(messages, i + 1) -- 1614
			end -- 1614
			i = i + 1 -- 1568
		end -- 1568
	end -- 1568
	if lastSafeBoundaryWithinBudget > 0 then -- 1568
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 1619
	end -- 1619
	if lastSafeBoundary > 0 then -- 1619
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 1622
	end -- 1622
	if lastClosedBoundaryWithinBudget > 0 then -- 1622
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 1625
	end -- 1625
	if lastClosedBoundary > 0 then -- 1625
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 1628
	end -- 1628
	local fallback = math.min(#messages, 1) -- 1630
	return {chunkEnd = fallback, compressedCount = fallback} -- 1631
end -- 1549
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 1634
	local carryUserIndex = -1 -- 1635
	do -- 1635
		local i = 0 -- 1636
		while i < chunkEnd do -- 1636
			if messages[i + 1].role == "user" then -- 1636
				carryUserIndex = i -- 1638
			end -- 1638
			i = i + 1 -- 1636
		end -- 1636
	end -- 1636
	if carryUserIndex < 0 then -- 1636
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 1642
	end -- 1642
	return {chunkEnd = chunkEnd, compressedCount = chunkEnd, carryMessageIndex = carryUserIndex} -- 1644
end -- 1634
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 1651
	local lines = {} -- 1652
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 1653
	if message.name and message.name ~= "" then -- 1653
		lines[#lines + 1] = "name=" .. message.name -- 1654
	end -- 1654
	if message.tool_call_id and message.tool_call_id ~= "" then -- 1654
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1655
	end -- 1655
	if message.reasoning_content and message.reasoning_content ~= "" then -- 1655
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1656
	end -- 1656
	if message.tool_calls and #message.tool_calls > 0 then -- 1656
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 1658
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1659
	end -- 1659
	if message.content and message.content ~= "" then -- 1659
		lines[#lines + 1] = message.content -- 1661
	end -- 1661
	local prefix = index > 0 and "\n\n" or "" -- 1662
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 1663
end -- 1651
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages, systemPrompt, toolDefinitions) -- 1666
	local currentTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1671
	local threshold = self:getContextWindow() * self.config.compressionTargetThreshold -- 1676
	local overflow = math.max(0, currentTokens - threshold) -- 1677
	if overflow <= 0 then -- 1677
		return math.max( -- 1679
			1, -- 1679
			self:estimateCompressionMessageTokens(messages[1], 0) -- 1679
		) -- 1679
	end -- 1679
	local safetyMargin = math.max( -- 1681
		64, -- 1681
		math.floor(threshold * 0.01) -- 1681
	) -- 1681
	return overflow + safetyMargin -- 1682
end -- 1666
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1685
	local lines = {} -- 1686
	do -- 1686
		local i = 0 -- 1687
		while i < #messages do -- 1687
			local message = messages[i + 1] -- 1688
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1689
			if message.name and message.name ~= "" then -- 1689
				lines[#lines + 1] = "name=" .. message.name -- 1690
			end -- 1690
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1690
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1691
			end -- 1691
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1691
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1692
			end -- 1692
			if message.tool_calls and #message.tool_calls > 0 then -- 1692
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1694
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1695
			end -- 1695
			if message.content and message.content ~= "" then -- 1695
				lines[#lines + 1] = message.content -- 1697
			end -- 1697
			if i < #messages - 1 then -- 1697
				lines[#lines + 1] = "" -- 1698
			end -- 1698
			i = i + 1 -- 1687
		end -- 1687
	end -- 1687
	return table.concat(lines, "\n") -- 1700
end -- 1685
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1706
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1706
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1714
		if decisionMode == "xml" then -- 1714
			return ____awaiter_resolve( -- 1714
				nil, -- 1714
				self:callLLMForCompressionByXML( -- 1716
					currentMemory, -- 1717
					boundedHistoryText, -- 1718
					llmOptions, -- 1719
					maxLLMTry, -- 1720
					debugContext -- 1721
				) -- 1721
			) -- 1721
		end -- 1721
		return ____awaiter_resolve( -- 1721
			nil, -- 1721
			self:callLLMForCompressionByToolCalling( -- 1724
				currentMemory, -- 1725
				boundedHistoryText, -- 1726
				llmOptions, -- 1727
				maxLLMTry, -- 1728
				debugContext -- 1729
			) -- 1729
		) -- 1729
	end) -- 1729
end -- 1706
function MemoryCompressor.prototype.getContextWindow(self) -- 1733
	return math.max(MEMORY_DEFAULT_CONTEXT_WINDOW, self.config.llmConfig.contextWindow) -- 1734
end -- 1733
function MemoryCompressor.prototype.getMemoryContextBudget(self) -- 1737
	local contextWindow = math.max(MEMORY_DEFAULT_CONTEXT_WINDOW, self.config.llmConfig.contextWindow) -- 1738
	return math.max( -- 1739
		AGENT_MEMORY_CONTEXT_MIN_TOKENS, -- 1740
		math.floor(contextWindow * AGENT_MEMORY_CONTEXT_WINDOW_RATIO) -- 1741
	) -- 1741
end -- 1737
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1745
	local contextWindow = self:getContextWindow() -- 1746
	local reservedOutputTokens = math.max( -- 1747
		COMPRESSION_RESERVED_OUTPUT_MIN_TOKENS, -- 1748
		math.floor(contextWindow * COMPRESSION_RESERVED_OUTPUT_CONTEXT_RATIO) -- 1749
	) -- 1749
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1751
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1752
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1753
	return math.max( -- 1754
		COMPRESSION_HISTORY_MIN_TOKENS, -- 1755
		math.floor(available * COMPRESSION_HISTORY_AVAILABLE_RATIO) -- 1756
	) -- 1756
end -- 1745
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1760
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1761
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1762
	if historyTokens <= tokenBudget then -- 1762
		return historyText -- 1763
	end -- 1763
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1764
	local targetChars = math.max( -- 1767
		COMPRESSION_HISTORY_TRUNCATED_MIN_CHARS, -- 1768
		math.floor(tokenBudget * charsPerToken) -- 1769
	) -- 1769
	local keepHead = math.max( -- 1771
		0, -- 1771
		math.floor(targetChars * COMPRESSION_HISTORY_TRUNCATED_HEAD_RATIO) -- 1771
	) -- 1771
	local keepTail = math.max(0, targetChars - keepHead) -- 1772
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1773
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1774
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1775
end -- 1760
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1778
	local contextWindow = self:getContextWindow() -- 1784
	local reservedOutputTokens = math.max( -- 1785
		COMPRESSION_RESERVED_OUTPUT_MIN_TOKENS, -- 1786
		math.floor(contextWindow * COMPRESSION_RESERVED_OUTPUT_CONTEXT_RATIO) -- 1787
	) -- 1787
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1789
	local dynamicBudget = math.max(COMPRESSION_DYNAMIC_MIN_TOKENS, contextWindow - reservedOutputTokens - staticPromptTokens - COMPRESSION_DYNAMIC_PROMPT_OVERHEAD_TOKENS) -- 1790
	local boundedMemory = clipTextToTokenBudget( -- 1794
		currentMemory or "(empty)", -- 1794
		math.max( -- 1794
			COMPRESSION_SECTION_MEMORY_MIN_TOKENS, -- 1795
			math.floor(dynamicBudget * COMPRESSION_SECTION_MEMORY_RATIO) -- 1796
		) -- 1796
	) -- 1796
	local boundedProjectMemory = clipTextToTokenBudget( -- 1798
		self.storage:readProjectMemory() or "(empty)", -- 1798
		math.max( -- 1798
			COMPRESSION_SECTION_MEMORY_MIN_TOKENS, -- 1799
			math.floor(dynamicBudget * COMPRESSION_SECTION_MEMORY_RATIO) -- 1800
		) -- 1800
	) -- 1800
	local boundedSessionSummary = clipTextToTokenBudget( -- 1802
		self.storage:readSessionSummary() or "(empty)", -- 1802
		math.max( -- 1802
			COMPRESSION_SECTION_SESSION_MIN_TOKENS, -- 1803
			math.floor(dynamicBudget * COMPRESSION_SECTION_SESSION_RATIO) -- 1804
		) -- 1804
	) -- 1804
	local boundedHistory = clipTextToTokenBudget( -- 1806
		historyText, -- 1806
		math.max( -- 1806
			COMPRESSION_SECTION_HISTORY_MIN_TOKENS, -- 1807
			math.floor(dynamicBudget * COMPRESSION_SECTION_HISTORY_RATIO) -- 1808
		) -- 1808
	) -- 1808
	return {currentMemory = boundedMemory, currentProjectMemory = boundedProjectMemory, currentSessionSummary = boundedSessionSummary, historyText = boundedHistory} -- 1810
end -- 1778
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1818
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1818
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1825
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated MEMORY.md as markdown. Core memory only: user preferences, stable facts, decisions, known issues."}, project_memory_update = {type = "string", description = "Full updated PROJECT_MEMORY.md as markdown. Project facts, build/run, files/architecture, project decisions and issues."}, session_summary_update = {type = "string", description = "Full updated SESSION_SUMMARY.md as markdown. Current goal, recent progress, and open issues for this session."}}, required = {"history_entry", "memory_update"}}}}} -- 1828
		local lastError = "missing save_memory tool call" -- 1859
		do -- 1859
			local i = 0 -- 1860
			while i < maxLLMTry do -- 1860
				do -- 1860
					local feedback = i > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). You must call the save_memory tool. Do not write prose. Required arguments: history_entry and memory_update. Optional arguments: project_memory_update and session_summary_update." or "" -- 1861
					local messages = { -- 1864
						{ -- 1865
							role = "system", -- 1866
							content = self:buildToolCallingCompressionSystemPrompt() -- 1867
						}, -- 1867
						{role = "user", content = prompt .. feedback} -- 1869
					} -- 1869
					local requestOptions = __TS__ObjectAssign({}, llmOptions, {tools = tools}) -- 1874
					__TS__Delete(requestOptions, "tool_choice") -- 1880
					local ____opt_5 = debugContext and debugContext.onInput -- 1880
					if ____opt_5 ~= nil then -- 1880
						____opt_5(debugContext, "memory_compression_tool_calling", messages, requestOptions) -- 1881
					end -- 1881
					local response = __TS__Await(callLLM(messages, requestOptions, nil, self.config.llmConfig)) -- 1882
					if not response.success then -- 1882
						lastError = response.message -- 1890
						local ____opt_9 = debugContext and debugContext.onOutput -- 1890
						if ____opt_9 ~= nil then -- 1890
							____opt_9(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false, attempt = i + 1, error = lastError}) -- 1891
						end -- 1891
						Log( -- 1892
							"Warn", -- 1892
							(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " failed: ") .. response.message -- 1892
						) -- 1892
						goto __continue293 -- 1893
					end -- 1893
					local ____opt_13 = debugContext and debugContext.onOutput -- 1893
					if ____opt_13 ~= nil then -- 1893
						____opt_13( -- 1895
							debugContext, -- 1895
							"memory_compression_tool_calling", -- 1895
							encodeCompressionDebugJSON(response.response), -- 1895
							{success = true, attempt = i + 1} -- 1895
						) -- 1895
					end -- 1895
					local choice = response.response.choices and response.response.choices[1] -- 1897
					local message = choice and choice.message -- 1898
					local toolCalls = message and message.tool_calls -- 1899
					local toolCall = toolCalls and toolCalls[1] -- 1900
					local fn = toolCall and toolCall["function"] -- 1901
					local argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1902
					if not fn or fn.name ~= "save_memory" then -- 1902
						local contentPreview = message and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" and "; content=" .. utf8TakeHead( -- 1904
							__TS__StringTrim(message.content), -- 1905
							240 -- 1905
						) or "" -- 1905
						lastError = "missing save_memory tool call" .. contentPreview -- 1907
						Log( -- 1908
							"Warn", -- 1908
							(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " invalid: ") .. lastError -- 1908
						) -- 1908
						goto __continue293 -- 1909
					end -- 1909
					if __TS__StringTrim(argsText) == "" then -- 1909
						lastError = "empty save_memory tool arguments" -- 1912
						Log( -- 1913
							"Warn", -- 1913
							(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " invalid: ") .. lastError -- 1913
						) -- 1913
						goto __continue293 -- 1914
					end -- 1914
					local args, err = safeJsonDecode(argsText) -- 1917
					if err ~= nil or not args or type(args) ~= "table" then -- 1917
						lastError = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1919
						Log( -- 1920
							"Warn", -- 1920
							(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " invalid: ") .. lastError -- 1920
						) -- 1920
						goto __continue293 -- 1921
					end -- 1921
					local ____hasReturned, ____returnValue -- 1921
					local ____try = __TS__AsyncAwaiter(function() -- 1921
						local result = self:buildCompressionResultFromObject(args, currentMemory) -- 1925
						if result.success then -- 1925
							____hasReturned = true -- 1929
							____returnValue = result -- 1929
							return -- 1929
						end -- 1929
						lastError = result.error or "invalid save_memory arguments" -- 1930
						Log( -- 1931
							"Warn", -- 1931
							(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " invalid: ") .. lastError -- 1931
						) -- 1931
					end) -- 1931
					____try = ____try.catch( -- 1931
						____try, -- 1931
						function(____, ____error) -- 1931
							return __TS__AsyncAwaiter(function() -- 1931
								lastError = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1933
								Log( -- 1934
									"Warn", -- 1934
									(((("[Memory] compression tool-calling attempt " .. tostring(i + 1)) .. "/") .. tostring(maxLLMTry)) .. " invalid: ") .. lastError -- 1934
								) -- 1934
							end) -- 1934
						end -- 1934
					) -- 1934
					__TS__Await(____try) -- 1924
					if ____hasReturned then -- 1924
						return ____awaiter_resolve(nil, ____returnValue) -- 1924
					end -- 1924
				end -- 1924
				::__continue293:: -- 1924
				i = i + 1 -- 1860
			end -- 1860
		end -- 1860
		Log( -- 1938
			"Warn", -- 1938
			(("[Memory] compression tool-calling exhausted " .. tostring(maxLLMTry)) .. " retries, falling back to XML: ") .. lastError -- 1938
		) -- 1938
		return ____awaiter_resolve( -- 1938
			nil, -- 1938
			self:callLLMForCompressionByXML( -- 1939
				currentMemory, -- 1940
				historyText, -- 1941
				llmOptions, -- 1942
				maxLLMTry, -- 1943
				debugContext -- 1944
			) -- 1944
		) -- 1944
	end) -- 1944
end -- 1818
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1948
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1948
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1955
		local lastError = "invalid xml response" -- 1956
		do -- 1956
			local i = 0 -- 1958
			while i < maxLLMTry do -- 1958
				do -- 1958
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1959
					local requestMessages = { -- 1964
						{ -- 1965
							role = "system", -- 1965
							content = self:buildXMLCompressionSystemPrompt() -- 1965
						}, -- 1965
						{role = "user", content = prompt .. feedback} -- 1966
					} -- 1966
					local ____opt_17 = debugContext and debugContext.onInput -- 1966
					if ____opt_17 ~= nil then -- 1966
						____opt_17(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1968
					end -- 1968
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1969
					if not response.success then -- 1969
						local ____opt_21 = debugContext and debugContext.onOutput -- 1969
						if ____opt_21 ~= nil then -- 1969
							____opt_21(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1977
						end -- 1977
						return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1977
					end -- 1977
					local choice = response.response.choices and response.response.choices[1] -- 1986
					local message = choice and choice.message -- 1987
					local text = message and type(message.content) == "string" and message.content or "" -- 1988
					local ____opt_25 = debugContext and debugContext.onOutput -- 1988
					if ____opt_25 ~= nil then -- 1988
						____opt_25( -- 1989
							debugContext, -- 1989
							"memory_compression_xml", -- 1989
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1989
							{success = true} -- 1989
						) -- 1989
					end -- 1989
					if __TS__StringTrim(text) == "" then -- 1989
						lastError = "empty xml response" -- 1991
						goto __continue303 -- 1992
					end -- 1992
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1995
					if parsed.success then -- 1995
						return ____awaiter_resolve(nil, parsed) -- 1995
					end -- 1995
					lastError = parsed.error or "invalid xml response" -- 1999
				end -- 1999
				::__continue303:: -- 1999
				i = i + 1 -- 1958
			end -- 1958
		end -- 1958
		return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = lastError}) -- 1958
	end) -- 1958
end -- 1948
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 2013
	return replaceTemplateVars( -- 2014
		self.config.promptPack.memoryCompressionBodyPrompt, -- 2014
		{ -- 2014
			CURRENT_MEMORY = currentMemory or "(empty)", -- 2015
			CURRENT_PROJECT_MEMORY = self.storage:readProjectMemory() or "(empty)", -- 2016
			CURRENT_SESSION_SUMMARY = self.storage:readSessionSummary() or "(empty)", -- 2017
			HISTORY_TEXT = historyText -- 2018
		} -- 2018
	) -- 2018
end -- 2013
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 2022
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 2023
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, CURRENT_PROJECT_MEMORY = bounded.currentProjectMemory, CURRENT_SESSION_SUMMARY = bounded.currentSessionSummary, HISTORY_TEXT = bounded.historyText}) -- 2024
end -- 2022
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 2032
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 2033
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 2036
end -- 2032
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 2043
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 2044
end -- 2043
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 2049
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 2050
end -- 2049
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 2055
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 2056
	if not parsed.success then -- 2056
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = parsed.message} -- 2058
	end -- 2058
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 2065
end -- 2055
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 2071
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 2075
	local memoryBody = type(obj.memory_update) == "string" and __TS__StringTrim(obj.memory_update) ~= "" and obj.memory_update or currentMemory -- 2076
	local projectMemoryBody = type(obj.project_memory_update) == "string" and __TS__StringTrim(obj.project_memory_update) ~= "" and obj.project_memory_update or self.storage:readProjectMemory() -- 2079
	local sessionSummaryBody = type(obj.session_summary_update) == "string" and __TS__StringTrim(obj.session_summary_update) ~= "" and obj.session_summary_update or self.storage:readSessionSummary() -- 2082
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 2082
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing history_entry or memory_update"} -- 2086
	end -- 2086
	local ts = os.date("%Y-%m-%d %H:%M") -- 2093
	return { -- 2094
		success = true, -- 2095
		memoryUpdate = memoryBody, -- 2096
		projectMemoryUpdate = projectMemoryBody, -- 2097
		sessionSummaryUpdate = sessionSummaryBody, -- 2098
		ts = ts, -- 2099
		summary = historyEntry, -- 2100
		compressedCount = 0 -- 2101
	} -- 2101
end -- 2071
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 2108
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 2112
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 2112
		local archived = self:rawArchive(chunk) -- 2115
		self.consecutiveFailures = 0 -- 2116
		return { -- 2118
			success = true, -- 2119
			memoryUpdate = self.storage:readMemory(), -- 2120
			ts = archived.ts, -- 2121
			compressedCount = #chunk -- 2122
		} -- 2122
	end -- 2122
	return { -- 2126
		success = false, -- 2127
		memoryUpdate = self.storage:readMemory(), -- 2128
		compressedCount = 0, -- 2129
		error = ____error -- 2130
	} -- 2130
end -- 2108
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 2137
	local ts = os.date("%Y-%m-%d %H:%M") -- 2138
	local rawArchive = self:formatMessagesForCompression(chunk) -- 2139
	self.storage:appendHistoryRecord({ts = ts, rawArchive = rawArchive}) -- 2140
	return {ts = ts} -- 2144
end -- 2137
function MemoryCompressor.prototype.getStorage(self) -- 2150
	return self.storage -- 2151
end -- 2150
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 2154
	return math.max( -- 2155
		1, -- 2155
		math.floor(self.config.maxCompressionRounds) -- 2155
	) -- 2155
end -- 2154
MemoryCompressor.MAX_FAILURES = 3 -- 2154
function ____exports.compactSessionMemoryScope(options) -- 2159
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2159
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2168
		if not llmConfigRes.success then -- 2168
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2168
		end -- 2168
		local compressor = __TS__New(____exports.MemoryCompressor, { -- 2174
			compressionThreshold = 0.8, -- 2175
			compressionTargetThreshold = 0.5, -- 2176
			maxCompressionRounds = 3, -- 2177
			projectDir = options.projectDir, -- 2178
			llmConfig = llmConfigRes.config, -- 2179
			promptPack = options.promptPack, -- 2180
			scope = options.scope -- 2181
		}) -- 2181
		local storage = compressor:getStorage() -- 2183
		local persistedSession = storage:readSessionState() -- 2184
		local messages = persistedSession.messages -- 2185
		local lastConsolidatedIndex = persistedSession.lastConsolidatedIndex -- 2186
		local carryMessageIndex = persistedSession.carryMessageIndex -- 2187
		local llmOptions = buildMemoryLLMOptions(llmConfigRes.config, options.llmOptions) -- 2188
		while lastConsolidatedIndex < #messages do -- 2188
			local activeMessages = {} -- 2190
			if type(carryMessageIndex) == "number" and carryMessageIndex >= 0 and carryMessageIndex < lastConsolidatedIndex and carryMessageIndex < #messages then -- 2190
				activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, messages[carryMessageIndex + 1]) -- 2197
			end -- 2197
			do -- 2197
				local i = lastConsolidatedIndex -- 2201
				while i < #messages do -- 2201
					activeMessages[#activeMessages + 1] = messages[i + 1] -- 2202
					i = i + 1 -- 2201
				end -- 2201
			end -- 2201
			local result = __TS__Await(compressor:compress( -- 2204
				activeMessages, -- 2205
				llmOptions, -- 2206
				math.max( -- 2207
					1, -- 2207
					math.floor(options.llmMaxTry or 5) -- 2207
				), -- 2207
				options.decisionMode or "tool_calling", -- 2208
				nil, -- 2209
				"budget_max" -- 2210
			)) -- 2210
			if not (result and result.success and result.compressedCount > 0) then -- 2210
				return ____awaiter_resolve(nil, {success = false, message = result and result.error or "memory compaction produced no progress"}) -- 2210
			end -- 2210
			local syntheticPrefixCount = #activeMessages > 0 and lastConsolidatedIndex < #messages and activeMessages[1] ~= messages[lastConsolidatedIndex + 1] and 1 or 0 -- 2218
			local realCompressedCount = math.max(0, result.compressedCount - syntheticPrefixCount) -- 2223
			lastConsolidatedIndex = math.min(#messages, lastConsolidatedIndex + realCompressedCount) -- 2224
			if type(result.carryMessageIndex) == "number" then -- 2224
				if syntheticPrefixCount > 0 and result.carryMessageIndex == 0 then -- 2224
				else -- 2224
					local carryOffset = syntheticPrefixCount > 0 and result.carryMessageIndex - 1 or result.carryMessageIndex -- 2229
					carryMessageIndex = carryOffset >= 0 and lastConsolidatedIndex - realCompressedCount + carryOffset or nil -- 2232
				end -- 2232
			else -- 2232
				carryMessageIndex = nil -- 2237
			end -- 2237
			if type(carryMessageIndex) == "number" and (carryMessageIndex < 0 or carryMessageIndex >= lastConsolidatedIndex or carryMessageIndex >= #messages) then -- 2237
				carryMessageIndex = nil -- 2243
			end -- 2243
			storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2245
		end -- 2245
		return ____awaiter_resolve(nil, {success = true, remainingMessages = #messages - lastConsolidatedIndex}) -- 2245
	end) -- 2245
end -- 2159
return ____exports -- 2159