-- [ts]: Memory.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
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
local function buildMemoryLLMOptions(llmConfig, overrides) -- 11
	local options = {temperature = llmConfig.temperature or MEMORY_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or MEMORY_DEFAULT_LLM_MAX_TOKENS} -- 12
	if llmConfig.reasoningEffort then -- 12
		options.reasoning_effort = llmConfig.reasoningEffort -- 17
	end -- 17
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 19
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 19
		__TS__Delete(merged, "reasoning_effort") -- 24
	else -- 24
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 26
	end -- 26
	return merged -- 28
end -- 11
local function isRecord(value) -- 31
	return type(value) == "table" -- 32
end -- 31
local function isArray(value) -- 35
	return __TS__ArrayIsArray(value) -- 36
end -- 35
local function clampSessionIndex(messages, index) -- 64
	if type(index) ~= "number" then -- 64
		return 0 -- 65
	end -- 65
	if index <= 0 then -- 65
		return 0 -- 66
	end -- 66
	return math.min( -- 67
		#messages, -- 67
		math.floor(index) -- 67
	) -- 67
end -- 64
local AGENT_CONFIG_DIR = ".agent" -- 70
local AGENT_PROMPTS_FILE = "AGENT.md" -- 71
local HISTORY_JSONL_FILE = "HISTORY.jsonl" -- 72
local HISTORY_MAX_RECORDS = 1000 -- 73
local SESSION_MAX_RECORDS = 1000 -- 74
local SUB_AGENT_SPAWN_INFO_FILE = "SPAWN.json" -- 75
local SUB_AGENT_LEARNINGS_MAX_ITEMS = 10 -- 76
local SUB_AGENT_LEARNINGS_MAX_CHARS = 5000 -- 77
local SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 78
local SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 79
local DEFAULT_CORE_MEMORY_TEMPLATE = "# Core Memory\n\n## User Preferences\n\n## Stable Facts\n\n## Known Decisions\n\n## Known Issues\n" -- memory layers
local DEFAULT_PROJECT_MEMORY_TEMPLATE = "# Project Memory\n\n## Project Facts\n\n## Build And Run\n\n## Files And Architecture\n\n## Decisions\n\n## Known Issues\n" -- memory layers
local DEFAULT_SESSION_SUMMARY_TEMPLATE = "# Session Summary\n\n## Current Goal\n\n## Recent Progress\n\n## Open Issues\n" -- memory layers
local MEMORY_CONTEXT_DEFAULT_MAX_TOKENS = 4000 -- memory context
local MEMORY_CONTEXT_MIN_MAX_TOKENS = 800 -- memory context
local MEMORY_LAYER_MIN_TOKENS = 300 -- memory context
local XML_DECISION_SCHEMA_EXAMPLE = "```xml\n<tool_call>\n\t<tool>edit_file</tool>\n\t<reason>Need to update the file content to implement the requested change.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<old_str>\nfunction oldName() {\n\tprint(\"old\");\n}\n\t\t</old_str>\n\t\t<new_str>\nfunction newName() {\n\tprint(\"hello\");\n}\n\t\t</new_str>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>read_file</tool>\n\t<reason>Need to inspect the current implementation before editing.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<startLine>1</startLine>\n\t\t<endLine>200</endLine>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>finish</tool>\n\t<params>\n\t\t<message>Final user-facing answer.</message>\n\t</params>\n</tool_call>\n```" -- 80
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 137
	agentIdentityPrompt = "### Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 138
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. 0 is invalid.\n\t- startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 151
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 198
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 199
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with one or more valid tool calls.", -- 200
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 201
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 214
	xmlDecisionSystemRepairPrompt = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only.", -- 245
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\t- Separate updates into Core Memory, Project Memory, and Session Summary\n\n4. Create History Entry\n\t- Create a summary paragraph\n\t- Include key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 256
	memoryCompressionBodyPrompt = "### Current Core Memory\n\n{{CURRENT_MEMORY}}\n\n### Current Project Memory\n\n{{CURRENT_PROJECT_MEMORY}}\n\n### Current Session Summary\n\n{{CURRENT_SESSION_SUMMARY}}\n\n### Actions to Process\n\n{{HISTORY_TEXT}}", -- 285
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content (Core Memory only)\n- project_memory_update: optional full updated PROJECT_MEMORY.md content; omit or leave empty to keep the current content\n- session_summary_update: optional full updated SESSION_SUMMARY.md content; omit or leave empty to keep the current content", -- 292
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update>\nFull updated MEMORY.md content (Core Memory only)\n\t</memory_update>\n\t<project_memory_update>\nFull updated PROJECT_MEMORY.md content\n\t</project_memory_update>\n\t<session_summary_update>\nFull updated SESSION_SUMMARY.md content\n\t</session_summary_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Include `<history_entry>` and `<memory_update>`. `<project_memory_update>` and `<session_summary_update>` are optional; omit them to keep current content.\n- Use CDATA for markdown update fields when they span multiple lines or contain markdown/code.", -- 297
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 314
} -- 314
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn"} -- 317
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 317
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 317
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 323
local function replaceTemplateVars(template, vars) -- 328
	local output = template -- 329
	for key in pairs(vars) do -- 330
		output = table.concat( -- 331
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 331
			vars[key] or "" or "," -- 331
		) -- 331
	end -- 331
	return output -- 333
end -- 328
function ____exports.resolveAgentPromptPack(value) -- 336
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 337
	if value and not isArray(value) and isRecord(value) then -- 337
		do -- 337
			local i = 0 -- 341
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 341
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 342
				if type(value[key]) == "string" then -- 342
					merged[key] = value[key] -- 344
				end -- 344
				i = i + 1 -- 341
			end -- 341
		end -- 341
	end -- 341
	return merged -- 348
end -- 336
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 351
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 352
	local lines = {} -- 353
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 354
	lines[#lines + 1] = "" -- 355
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 356
	lines[#lines + 1] = "" -- 357
	do -- 357
		local i = 0 -- 358
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 358
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 359
			lines[#lines + 1] = "## " .. key -- 360
			local text = pack[key] -- 361
			local split = __TS__StringSplit(text, "\n") -- 362
			do -- 362
				local j = 0 -- 363
				while j < #split do -- 363
					lines[#lines + 1] = split[j + 1] -- 364
					j = j + 1 -- 363
				end -- 363
			end -- 363
			lines[#lines + 1] = "" -- 366
			i = i + 1 -- 358
		end -- 358
	end -- 358
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 368
end -- 351
local function getPromptPackConfigPath(projectRoot) -- 371
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 372
end -- 371
local function ensurePromptPackConfig(projectRoot) -- 375
	local path = getPromptPackConfigPath(projectRoot) -- 376
	if Content:exist(path) then -- 376
		return nil -- 377
	end -- 377
	local dir = Path:getPath(path) -- 378
	if not Content:exist(dir) then -- 378
		Content:mkdir(dir) -- 380
	end -- 380
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 382
	if not Content:save(path, content) then -- 382
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 384
	end -- 384
	sendWebIDEFileUpdate(path, true, content) -- 386
	return nil -- 387
end -- 375
local function parsePromptPackMarkdown(text) -- 390
	if not text or __TS__StringTrim(text) == "" then -- 390
		return { -- 397
			value = {}, -- 398
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 399
			unknown = {} -- 400
		} -- 400
	end -- 400
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 403
	local lines = __TS__StringSplit(normalized, "\n") -- 404
	local sections = {} -- 405
	local unknown = {} -- 406
	local currentHeading = "" -- 407
	local function isKnownPromptPackKey(name) -- 408
		do -- 408
			local i = 0 -- 409
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 409
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 409
					return true -- 410
				end -- 410
				i = i + 1 -- 409
			end -- 409
		end -- 409
		return false -- 412
	end -- 408
	do -- 408
		local i = 0 -- 414
		while i < #lines do -- 414
			do -- 414
				local line = lines[i + 1] -- 415
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 416
				if matchedHeading ~= nil then -- 416
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 418
					if isKnownPromptPackKey(heading) then -- 418
						currentHeading = heading -- 420
						if sections[currentHeading] == nil then -- 420
							sections[currentHeading] = {} -- 422
						end -- 422
						goto __continue36 -- 424
					end -- 424
					if currentHeading == "" then -- 424
						unknown[#unknown + 1] = heading -- 427
						goto __continue36 -- 428
					end -- 428
				end -- 428
				if currentHeading ~= "" then -- 428
					local ____sections_currentHeading_1 = sections[currentHeading] -- 428
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 432
				end -- 432
			end -- 432
			::__continue36:: -- 432
			i = i + 1 -- 414
		end -- 414
	end -- 414
	local value = {} -- 435
	local missing = {} -- 436
	do -- 436
		local i = 0 -- 437
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 437
			do -- 437
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 438
				local section = sections[key] -- 439
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 440
				if body == "" then -- 440
					missing[#missing + 1] = key -- 442
					goto __continue43 -- 443
				end -- 443
				value[key] = body -- 445
			end -- 445
			::__continue43:: -- 445
			i = i + 1 -- 437
		end -- 437
	end -- 437
	if #__TS__ObjectKeys(sections) == 0 then -- 437
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 448
	end -- 448
	return {value = value, missing = missing, unknown = unknown} -- 454
end -- 390
function ____exports.loadAgentPromptPack(projectRoot) -- 457
	local path = getPromptPackConfigPath(projectRoot) -- 458
	local warnings = {} -- 459
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 460
	if ensureWarning and ensureWarning ~= "" then -- 460
		warnings[#warnings + 1] = ensureWarning -- 462
	end -- 462
	if not Content:exist(path) then -- 462
		return { -- 465
			pack = ____exports.resolveAgentPromptPack(), -- 466
			warnings = warnings, -- 467
			path = path -- 468
		} -- 468
	end -- 468
	local text = Content:load(path) -- 471
	if not text or __TS__StringTrim(text) == "" then -- 471
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 473
		return { -- 474
			pack = ____exports.resolveAgentPromptPack(), -- 475
			warnings = warnings, -- 476
			path = path -- 477
		} -- 477
	end -- 477
	local parsed = parsePromptPackMarkdown(text) -- 480
	if parsed.error or not parsed.value then -- 480
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 482
		return { -- 483
			pack = ____exports.resolveAgentPromptPack(), -- 484
			warnings = warnings, -- 485
			path = path -- 486
		} -- 486
	end -- 486
	if #parsed.unknown > 0 then -- 486
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 490
	end -- 490
	if #parsed.missing > 0 then -- 490
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 493
	end -- 493
	return { -- 495
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 496
		warnings = warnings, -- 497
		path = path -- 498
	} -- 498
end -- 457
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 573
local TokenEstimator = ____exports.TokenEstimator -- 573
TokenEstimator.name = "TokenEstimator" -- 573
function TokenEstimator.prototype.____constructor(self) -- 573
end -- 573
function TokenEstimator.estimate(self, text) -- 577
	if text == "" then -- 577
		return 0 -- 578
	end -- 578
	return App:estimateTokens(text) -- 579
end -- 577
function TokenEstimator.estimateMessages(self, messages) -- 582
	if messages == nil or #messages == 0 then -- 582
		return 0 -- 583
	end -- 583
	local total = 0 -- 584
	do -- 584
		local i = 0 -- 585
		while i < #messages do -- 585
			local message = messages[i + 1] -- 586
			total = total + self:estimate(message.role or "") -- 587
			total = total + self:estimate(message.content or "") -- 588
			total = total + self:estimate(message.name or "") -- 589
			total = total + self:estimate(message.tool_call_id or "") -- 590
			total = total + self:estimate(message.reasoning_content or "") -- 591
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 592
			total = total + self:estimate(toolCallsText or "") -- 593
			total = total + 8 -- 594
			i = i + 1 -- 585
		end -- 585
	end -- 585
	return total -- 596
end -- 582
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 599
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 604
end -- 599
local function encodeCompressionDebugJSON(value) -- 612
	local text, err = safeJsonEncode(value) -- 613
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 614
end -- 612
local function utf8TakeHead(text, maxChars) -- 617
	if maxChars <= 0 or text == "" then -- 617
		return "" -- 618
	end -- 618
	local nextPos = utf8.offset(text, maxChars + 1) -- 619
	if nextPos == nil then -- 619
		return text -- 620
	end -- 620
	return string.sub(text, 1, nextPos - 1) -- 621
end -- 617
local function utf8TakeTail(text, maxChars) -- 624
	if maxChars <= 0 or text == "" then -- 624
		return "" -- 625
	end -- 625
	local charLen = utf8.len(text) -- 626
	if charLen == nil or charLen <= maxChars then -- 626
		return text -- 627
	end -- 627
	local startChar = math.max(1, charLen - maxChars + 1) -- 628
	local startPos = utf8.offset(text, startChar) -- 629
	if startPos == nil then -- 629
		return text -- 630
	end -- 630
	return string.sub(text, startPos) -- 631
end -- 624
local function ensureDirRecursive(dir) -- 634
	if not dir or dir == "" then -- 634
		return false -- 635
	end -- 635
	if Content:exist(dir) then -- 635
		return Content:isdir(dir) -- 636
	end -- 636
	local parent = Path:getPath(dir) -- 637
	if parent and parent ~= dir and not Content:exist(parent) then -- 637
		if not ensureDirRecursive(parent) then -- 637
			return false -- 640
		end -- 640
	end -- 640
	return Content:mkdir(dir) -- 643
end -- 634
local function normalizeMemoryFileContent(content, template, importedSectionTitle)
	local safeContent = type(content) == "string" and sanitizeUTF8(content) or ""
	local trimmed = __TS__StringTrim(safeContent)
	if trimmed == "" then
		return template
	end
	if string.find(trimmed, "\n## ", 1, true) or string.find(trimmed, "\n# ", 1, true) or string.sub(trimmed, 1, 3) == "## " or string.sub(trimmed, 1, 2) == "# " then
		return safeContent
	end
	return (((__TS__StringTrim(template) .. "\n\n## ") .. importedSectionTitle) .. "\n\n") .. trimmed .. "\n"
end

local function splitMemorySections(text)
	local sections = {}
	local safeText = sanitizeUTF8(type(text) == "string" and text or "")
	local lines = __TS__StringSplit(safeText, "\n")
	local title = "Overview"
	local bodyLines = {}
	local index = 0
	local function flush()
		local body = __TS__StringTrim(table.concat(bodyLines, "\n"))
		if body ~= "" then
			local fullText = title == "Overview" and body or ((("## " .. title) .. "\n\n") .. body)
			sections[#sections + 1] = {title = title, body = body, fullText = fullText, index = index, score = 0}
			index = index + 1
		end
	end
	do
		local i = 0
		while i < #lines do
			local line = lines[i + 1]
			if string.sub(line, 1, 3) == "## " then
				flush()
				title = __TS__StringTrim(string.sub(line, 4))
				bodyLines = {}
			elseif string.sub(line, 1, 2) == "# " then
				-- skip top-level document title
			else
				bodyLines[#bodyLines + 1] = line
			end
			i = i + 1
		end
	end
	flush()
	return sections
end

local function collectQueryTerms(query)
	local terms = {}
	local lower = string.lower(sanitizeUTF8(type(query) == "string" and query or ""))
	local current = ""
	local function pushCurrent()
		local word = __TS__StringTrim(current)
		if #word >= 2 and __TS__ArrayIndexOf(terms, word) < 0 then
			terms[#terms + 1] = word
		end
		current = ""
	end
	do
		local i = 1
		while i <= #lower do
			local ch = string.sub(lower, i, i)
			local code = string.byte(ch) or 0
			local isAsciiWord = (code >= 48 and code <= 57) or (code >= 97 and code <= 122) or ch == "_" or ch == "-" or ch == "."
			if isAsciiWord then
				current = current .. ch
			else
				pushCurrent()
				if code > 127 and __TS__ArrayIndexOf(terms, ch) < 0 then
					terms[#terms + 1] = ch
				end
			end
			i = i + 1
		end
	end
	pushCurrent()
	return terms
end

local function countOccurrences(text, term)
	if text == "" or term == "" then
		return 0
	end
	local count = 0
	local start = 1
	while true do
		local pos = string.find(text, term, start, true)
		if not pos then
			break
		end
		count = count + 1
		start = pos + #term
	end
	return count
end

local function scoreMemorySection(section, terms)
	local titleLower = string.lower(section.title or "")
	local bodyLower = string.lower(section.body or "")
	local score = 0
	do
		local i = 0
		while i < #terms do
			local term = terms[i + 1]
			score = score + countOccurrences(titleLower, term) * 6
			score = score + countOccurrences(bodyLower, term)
			i = i + 1
		end
	end
	if string.find(titleLower, "user preference", 1, true) or string.find(titleLower, "stable fact", 1, true) or string.find(titleLower, "known decision", 1, true) or string.find(titleLower, "known issue", 1, true) or string.find(titleLower, "current goal", 1, true) or string.find(titleLower, "recent progress", 1, true) or string.find(titleLower, "build and run", 1, true) then
		score = score + (#terms > 0 and 1 or 3)
	end
	return score
end

local function selectRelevantMemoryText(text, query, maxTokens)
	local sections = splitMemorySections(text)
	if #sections == 0 then
		return ""
	end
	local budget = math.max(MEMORY_LAYER_MIN_TOKENS, maxTokens or 0)
	local terms = collectQueryTerms(query)
	do
		local i = 0
		while i < #sections do
			sections[i + 1].score = scoreMemorySection(sections[i + 1], terms)
			i = i + 1
		end
	end
	local ranked = __TS__ArraySlice(sections, 0)
	table.sort(ranked, function(a, b)
		if a.score ~= b.score then
			return a.score > b.score
		end
		return a.index < b.index
	end)
	local selected = {}
	local used = 0
	do
		local i = 0
		while i < #ranked do
			local section = ranked[i + 1]
			if not (#terms > 0 and section.score <= 0) then
				local cost = ____exports.TokenEstimator:estimate(section.fullText) + 12
				if not (#selected > 0 and used + cost > budget) then
					selected[#selected + 1] = section
					used = used + cost
					if used >= budget then
						break
					end
				end
			end
			i = i + 1
		end
	end
	if #selected == 0 then
		do
			local i = 0
			while i < #sections do
				local section = sections[i + 1]
				local cost = ____exports.TokenEstimator:estimate(section.fullText) + 12
				if not (#selected > 0 and used + cost > budget) then
					selected[#selected + 1] = section
					used = used + cost
					if used >= budget then
						break
					end
				end
				i = i + 1
			end
		end
	end
	table.sort(selected, function(a, b) return a.index < b.index end)
	local lines = {}
	do
		local i = 0
		while i < #selected do
			lines[#lines + 1] = selected[i + 1].fullText
			i = i + 1
		end
	end
	return table.concat(lines, "\n\n")
end

local function formatMemoryLayer(title, content)
	local trimmed = __TS__StringTrim(sanitizeUTF8(type(content) == "string" and content or ""))
	if trimmed == "" then
		return ""
	end
	return (("#### " .. title) .. "\n\n") .. trimmed
end
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.jsonl (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 651
local DualLayerStorage = ____exports.DualLayerStorage -- 651
DualLayerStorage.name = "DualLayerStorage" -- 651
function DualLayerStorage.prototype.____constructor(self, projectDir, scope) -- 660
	if scope == nil then -- 660
		scope = "" -- 660
	end -- 660
	self.projectDir = projectDir -- 661
	self.scope = scope -- 662
	self.agentRootDir = Path(self.projectDir, ".agent") -- 663
	self.agentDir = scope ~= "" and Path(self.agentRootDir, scope) or self.agentRootDir -- 664
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 667
	self.projectMemoryPath = Path(self.agentDir, "PROJECT_MEMORY.md") -- memory layers
	self.sessionSummaryPath = Path(self.agentDir, "SESSION_SUMMARY.md") -- memory layers
	self.historyPath = Path(self.agentDir, HISTORY_JSONL_FILE) -- 668
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 669
	self:ensureAgentFiles() -- 670
end -- 660
function DualLayerStorage.prototype.ensureDir(self, dir) -- 673
	if not Content:exist(dir) then -- 673
		ensureDirRecursive(dir) -- 675
	end -- 675
end -- 673
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 679
	if Content:exist(path) then -- 679
		return false -- 680
	end -- 680
	self:ensureDir(Path:getPath(path)) -- 681
	if not Content:save(path, content) then -- 681
		return false -- 683
	end -- 683
	sendWebIDEFileUpdate(path, true, content) -- 685
	return true -- 686
end -- 679
function DualLayerStorage.prototype.ensureStructuredMemoryFile(self, path, template) -- memory layers
	if not Content:exist(path) then
		self:ensureFile(path, template)
		return
	end
	local current = Content:load(path)
	if type(current) ~= "string" or __TS__StringTrim(current) == "" then
		Content:save(path, template)
		sendWebIDEFileUpdate(path, true, template)
	end
end
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 689
	self:ensureDir(self.agentRootDir) -- 690
	self:ensureDir(self.agentDir) -- 691
	self:ensureStructuredMemoryFile(self.memoryPath, DEFAULT_CORE_MEMORY_TEMPLATE) -- memory layers
	self:ensureStructuredMemoryFile(self.projectMemoryPath, DEFAULT_PROJECT_MEMORY_TEMPLATE) -- memory layers
	self:ensureStructuredMemoryFile(self.sessionSummaryPath, DEFAULT_SESSION_SUMMARY_TEMPLATE) -- memory layers
	self:ensureFile(self.historyPath, "") -- 693
end -- 689
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 696
	local text = safeJsonEncode(value) -- 697
	return text -- 698
end -- 696
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 701
	local value = safeJsonDecode(text) -- 702
	return value -- 703
end -- 701
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 706
	if not value or isArray(value) or not isRecord(value) then -- 706
		return nil -- 707
	end -- 707
	local row = value -- 708
	local role = type(row.role) == "string" and row.role or "" -- 709
	if role == "" then -- 709
		return nil -- 710
	end -- 710
	local message = {role = role} -- 711
	if type(row.content) == "string" then -- 711
		message.content = sanitizeUTF8(row.content) -- 712
	end -- 712
	if type(row.name) == "string" then -- 712
		message.name = sanitizeUTF8(row.name) -- 713
	end -- 713
	if type(row.tool_call_id) == "string" then -- 713
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 714
	end -- 714
	if type(row.reasoning_content) == "string" then -- 714
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 715
	end -- 715
	if type(row.timestamp) == "string" then -- 715
		message.timestamp = sanitizeUTF8(row.timestamp) -- 716
	end -- 716
	if isArray(row.tool_calls) then -- 716
		message.tool_calls = row.tool_calls -- 718
	end -- 718
	return message -- 720
end -- 706
function DualLayerStorage.prototype.decodeHistoryRecord(self, value) -- 723
	if not value or isArray(value) or not isRecord(value) then -- 723
		return nil -- 724
	end -- 724
	local row = value -- 725
	local ts = type(row.ts) == "string" and __TS__StringTrim(row.ts) ~= "" and sanitizeUTF8(row.ts) or "" -- 726
	local summary = type(row.summary) == "string" and __TS__StringTrim(row.summary) ~= "" and sanitizeUTF8(row.summary) or nil -- 729
	local rawArchive = type(row.rawArchive) == "string" and __TS__StringTrim(row.rawArchive) ~= "" and sanitizeUTF8(row.rawArchive) or nil -- 732
	if ts == "" or summary == nil and rawArchive == nil then -- 732
		return nil -- 735
	end -- 735
	local record = {ts = ts, summary = summary, rawArchive = rawArchive} -- 736
	return record -- 741
end -- 723
function DualLayerStorage.prototype.readSpawnInfo(self, path) -- 744
	if not Content:exist(path) then -- 744
		return nil -- 745
	end -- 745
	local text = Content:load(path) -- 746
	if not text or __TS__StringTrim(text) == "" then -- 746
		return nil -- 747
	end -- 747
	local value = safeJsonDecode(text) -- 748
	if value and not isArray(value) and isRecord(value) then -- 748
		return value -- 750
	end -- 750
	return nil -- 752
end -- 744
function DualLayerStorage.prototype.normalizeEvidence(self, value) -- 755
	local evidence = {} -- 756
	if not isArray(value) then -- 756
		return evidence -- 757
	end -- 757
	do -- 757
		local i = 0 -- 758
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 758
			local item = type(value[i + 1]) == "string" and __TS__StringTrim(sanitizeUTF8(value[i + 1])) or "" -- 759
			if item ~= "" and __TS__ArrayIndexOf(evidence, item) < 0 then -- 759
				evidence[#evidence + 1] = item -- 761
			end -- 761
			i = i + 1 -- 758
		end -- 758
	end -- 758
	return evidence -- 764
end -- 755
function DualLayerStorage.prototype.decodeSubAgentLearning(self, value, fallbackSortTs) -- 767
	if not value or isArray(value) or not isRecord(value) then -- 767
		return nil -- 768
	end -- 768
	local sourceSessionId = type(value.sourceSessionId) == "number" and math.floor(value.sourceSessionId) or 0 -- 769
	local sourceTaskId = type(value.sourceTaskId) == "number" and math.floor(value.sourceTaskId) or 0 -- 770
	local content = type(value.content) == "string" and utf8TakeHead( -- 771
		__TS__StringTrim(sanitizeUTF8(value.content)), -- 772
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 772
	) or "" -- 772
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 772
		return nil -- 774
	end -- 774
	return { -- 775
		sourceSessionId = sourceSessionId, -- 776
		sourceTaskId = sourceTaskId, -- 777
		content = content, -- 778
		evidence = self:normalizeEvidence(value.evidence), -- 779
		createdAt = type(value.createdAt) == "string" and __TS__StringTrim(sanitizeUTF8(value.createdAt)) or "", -- 780
		sortTs = fallbackSortTs -- 781
	} -- 781
end -- 767
function DualLayerStorage.prototype.readSubAgentLearningEntries(self) -- 785
	if self.scope ~= "" and self.scope ~= "main" then -- 785
		return {} -- 786
	end -- 786
	local subAgentsDir = Path(self.agentRootDir, "subagents") -- 787
	if not Content:exist(subAgentsDir) or not Content:isdir(subAgentsDir) then -- 787
		return {} -- 788
	end -- 788
	local entries = {} -- 789
	local seen = {} -- 790
	for ____, rawPath in ipairs(Content:getDirs(subAgentsDir)) do -- 791
		do -- 791
			local dir = Content:isAbsolutePath(rawPath) and rawPath or Path(subAgentsDir, rawPath) -- 792
			if not Content:exist(dir) or not Content:isdir(dir) then -- 792
				goto __continue110 -- 793
			end -- 793
			local info = self:readSpawnInfo(Path(dir, SUB_AGENT_SPAWN_INFO_FILE)) -- 794
			if info == nil or info.success ~= true then -- 794
				goto __continue110 -- 795
			end -- 795
			local fallbackSortTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or 0 -- 796
			local entry = self:decodeSubAgentLearning(info.memoryEntry, fallbackSortTs) -- 797
			if entry == nil then -- 797
				goto __continue110 -- 798
			end -- 798
			local key = (tostring(entry.sourceSessionId) .. ":") .. tostring(entry.sourceTaskId) -- 799
			if seen[key] then -- 799
				goto __continue110 -- 800
			end -- 800
			seen[key] = true -- 801
			entries[#entries + 1] = entry -- 802
		end -- 802
		::__continue110:: -- 802
	end -- 802
	__TS__ArraySort( -- 804
		entries, -- 804
		function(____, a, b) return b.sortTs - a.sortTs end -- 804
	) -- 804
	return entries -- 805
end -- 785
function DualLayerStorage.prototype.buildSubAgentLearningsContext(self) -- 808
	local entries = self:readSubAgentLearningEntries() -- 809
	if #entries == 0 then -- 809
		return "" -- 810
	end -- 810
	local lines = {"## Sub-Agent Learnings", ""} -- 811
	local totalChars = 0 -- 812
	local count = 0 -- 813
	do -- 813
		local i = 0 -- 814
		while i < #entries and count < SUB_AGENT_LEARNINGS_MAX_ITEMS do -- 814
			local entry = entries[i + 1] -- 815
			local evidence = #entry.evidence > 0 and "\n  Evidence: " .. table.concat(entry.evidence, ", ") or "" -- 816
			local line = ((((("- [sub-agent:" .. tostring(entry.sourceSessionId)) .. "/task:") .. tostring(entry.sourceTaskId)) .. "] ") .. entry.content) .. evidence -- 817
			if totalChars + #line > SUB_AGENT_LEARNINGS_MAX_CHARS then -- 817
				break -- 818
			end -- 818
			lines[#lines + 1] = line -- 819
			totalChars = totalChars + #line -- 820
			count = count + 1 -- 821
			i = i + 1 -- 814
		end -- 814
	end -- 814
	return count > 0 and table.concat(lines, "\n") or "" -- 823
end -- 808
function DualLayerStorage.prototype.readHistoryRecords(self) -- 826
	if not Content:exist(self.historyPath) then -- 826
		return {} -- 828
	end -- 828
	local text = Content:load(self.historyPath) -- 830
	if not text or __TS__StringTrim(text) == "" then -- 830
		return {} -- 832
	end -- 832
	local lines = __TS__StringSplit(text, "\n") -- 834
	local records = {} -- 835
	do -- 835
		local i = 0 -- 836
		while i < #lines do -- 836
			do -- 836
				local line = __TS__StringTrim(lines[i + 1]) -- 837
				if line == "" then -- 837
					goto __continue126 -- 838
				end -- 838
				local decoded = self:decodeJsonLine(line) -- 839
				local record = self:decodeHistoryRecord(decoded) -- 840
				if record ~= nil then -- 840
					records[#records + 1] = record -- 842
				end -- 842
			end -- 842
			::__continue126:: -- 842
			i = i + 1 -- 836
		end -- 836
	end -- 836
	return records -- 845
end -- 826
function DualLayerStorage.prototype.saveHistoryRecords(self, records) -- 848
	self:ensureDir(Path:getPath(self.historyPath)) -- 849
	local normalized = #records > HISTORY_MAX_RECORDS and __TS__ArraySlice(records, #records - HISTORY_MAX_RECORDS) or records -- 850
	local lines = {} -- 853
	do -- 853
		local i = 0 -- 854
		while i < #normalized do -- 854
			local line = self:encodeJsonLine(normalized[i + 1]) -- 855
			if type(line) == "string" and line ~= "" then -- 855
				lines[#lines + 1] = line -- 857
			end -- 857
			i = i + 1 -- 854
		end -- 854
	end -- 854
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 860
	Content:save(self.historyPath, content) -- 861
	sendWebIDEFileUpdate(self.historyPath, true, content) -- 862
end -- 848
function DualLayerStorage.prototype.readMemory(self) -- structured memory
	if not Content:exist(self.memoryPath) then
		return DEFAULT_CORE_MEMORY_TEMPLATE
	end
	return normalizeMemoryFileContent(Content:load(self.memoryPath), DEFAULT_CORE_MEMORY_TEMPLATE, "Imported Notes")
end
function DualLayerStorage.prototype.writeMemory(self, content) -- structured memory
	local normalized = normalizeMemoryFileContent(content, DEFAULT_CORE_MEMORY_TEMPLATE, "Imported Notes")
	self:ensureDir(Path:getPath(self.memoryPath))
	Content:save(self.memoryPath, normalized)
	sendWebIDEFileUpdate(self.memoryPath, true, normalized)
end
function DualLayerStorage.prototype.readProjectMemory(self) -- structured memory
	if not Content:exist(self.projectMemoryPath) then
		return DEFAULT_PROJECT_MEMORY_TEMPLATE
	end
	return normalizeMemoryFileContent(Content:load(self.projectMemoryPath), DEFAULT_PROJECT_MEMORY_TEMPLATE, "Imported Project Notes")
end
function DualLayerStorage.prototype.writeProjectMemory(self, content) -- structured memory
	local normalized = normalizeMemoryFileContent(content, DEFAULT_PROJECT_MEMORY_TEMPLATE, "Imported Project Notes")
	self:ensureDir(Path:getPath(self.projectMemoryPath))
	Content:save(self.projectMemoryPath, normalized)
	sendWebIDEFileUpdate(self.projectMemoryPath, true, normalized)
end
function DualLayerStorage.prototype.readSessionSummary(self) -- structured memory
	if not Content:exist(self.sessionSummaryPath) then
		return DEFAULT_SESSION_SUMMARY_TEMPLATE
	end
	return normalizeMemoryFileContent(Content:load(self.sessionSummaryPath), DEFAULT_SESSION_SUMMARY_TEMPLATE, "Imported Session Notes")
end
function DualLayerStorage.prototype.writeSessionSummary(self, content) -- structured memory
	local normalized = normalizeMemoryFileContent(content, DEFAULT_SESSION_SUMMARY_TEMPLATE, "Imported Session Notes")
	self:ensureDir(Path:getPath(self.sessionSummaryPath))
	Content:save(self.sessionSummaryPath, normalized)
	sendWebIDEFileUpdate(self.sessionSummaryPath, true, normalized)
end
function DualLayerStorage.prototype.getRelevantMemoryContext(self, query, maxTokens) -- structured memory
	if query == nil then
		query = ""
	end
	if maxTokens == nil then
		maxTokens = MEMORY_CONTEXT_DEFAULT_MAX_TOKENS
	end
	local budget = math.max(MEMORY_CONTEXT_MIN_MAX_TOKENS, math.floor(maxTokens))
	local coreBudget = math.floor(budget * 0.3)
	local projectBudget = math.floor(budget * 0.35)
	local sessionBudget = math.floor(budget * 0.2)
	local subAgentBudget = math.max(0, budget - coreBudget - projectBudget - sessionBudget - 160)
	local sections = {}
	local core = formatMemoryLayer("Core Memory", selectRelevantMemoryText(self:readMemory(), query, coreBudget))
	if core ~= "" then
		sections[#sections + 1] = core
	end
	local project = formatMemoryLayer("Project Memory", selectRelevantMemoryText(self:readProjectMemory(), query, projectBudget))
	if project ~= "" then
		sections[#sections + 1] = project
	end
	local session = formatMemoryLayer("Session Summary", selectRelevantMemoryText(self:readSessionSummary(), query, sessionBudget))
	if session ~= "" then
		sections[#sections + 1] = session
	end
	local subAgentLearnings = self:buildSubAgentLearningsContext()
	if subAgentLearnings ~= "" then
		sections[#sections + 1] = formatMemoryLayer("Sub-Agent Learnings", clipTextToTokenBudget(subAgentLearnings, subAgentBudget > 0 and subAgentBudget or MEMORY_LAYER_MIN_TOKENS))
	end
	if #sections == 0 then
		return ""
	end
	local output = "### Relevant Memory\n\n" .. table.concat(sections, "\n\n")
	return ____exports.TokenEstimator:estimate(output) > budget and clipTextToTokenBudget(output, budget) or output
end
function DualLayerStorage.prototype.getMemoryContext(self, query, maxTokens) -- structured memory compatibility
	if query == nil then
		query = ""
	end
	if maxTokens == nil then
		maxTokens = MEMORY_CONTEXT_DEFAULT_MAX_TOKENS
	end
	return self:getRelevantMemoryContext(query, maxTokens)
end
function DualLayerStorage.prototype.appendHistoryRecord(self, record) -- 905
	local records = self:readHistoryRecords() -- 906
	records[#records + 1] = record -- 907
	self:saveHistoryRecords(records) -- 908
end -- 905
function DualLayerStorage.prototype.readSessionState(self) -- 911
	if not Content:exist(self.sessionPath) then -- 911
		return {messages = {}, lastConsolidatedIndex = 0} -- 913
	end -- 913
	local text = Content:load(self.sessionPath) -- 915
	if not text or __TS__StringTrim(text) == "" then -- 915
		return {messages = {}, lastConsolidatedIndex = 0} -- 917
	end -- 917
	local lines = __TS__StringSplit(text, "\n") -- 919
	local messages = {} -- 920
	local lastConsolidatedIndex = 0 -- 921
	local carryMessageIndex = nil -- 922
	do -- 922
		local i = 0 -- 923
		while i < #lines do -- 923
			do -- 923
				local line = __TS__StringTrim(lines[i + 1]) -- 924
				if line == "" then -- 924
					goto __continue145 -- 925
				end -- 925
				local data = self:decodeJsonLine(line) -- 926
				if not data or isArray(data) or not isRecord(data) then -- 926
					goto __continue145 -- 927
				end -- 927
				local row = data -- 928
				if type(row.lastConsolidatedIndex) == "number" then -- 928
					lastConsolidatedIndex = math.floor(row.lastConsolidatedIndex) -- 930
					if type(row.carryMessageIndex) == "number" then -- 930
						carryMessageIndex = math.floor(row.carryMessageIndex) -- 932
					end -- 932
					goto __continue145 -- 934
				end -- 934
				local ____self_decodeConversationMessage_3 = self.decodeConversationMessage -- 936
				local ____row_message_2 = row.message -- 936
				if ____row_message_2 == nil then -- 936
					____row_message_2 = row -- 936
				end -- 936
				local message = ____self_decodeConversationMessage_3(self, ____row_message_2) -- 936
				if message ~= nil then -- 936
					messages[#messages + 1] = message -- 938
				end -- 938
			end -- 938
			::__continue145:: -- 938
			i = i + 1 -- 923
		end -- 923
	end -- 923
	local normalizedLastConsolidatedIndex = clampSessionIndex(messages, lastConsolidatedIndex) -- 941
	local normalizedCarryMessageIndex = type(carryMessageIndex) == "number" and carryMessageIndex >= 0 and carryMessageIndex < normalizedLastConsolidatedIndex and carryMessageIndex < #messages and math.floor(carryMessageIndex) or nil -- 942
	return {messages = messages, lastConsolidatedIndex = normalizedLastConsolidatedIndex, carryMessageIndex = normalizedCarryMessageIndex} -- 948
end -- 911
function DualLayerStorage.prototype.writeSessionState(self, messages, lastConsolidatedIndex, carryMessageIndex) -- 955
	if messages == nil then -- 955
		messages = {} -- 956
	end -- 956
	if lastConsolidatedIndex == nil then -- 956
		lastConsolidatedIndex = 0 -- 957
	end -- 957
	self:ensureDir(Path:getPath(self.sessionPath)) -- 960
	local lines = {} -- 961
	local dropCount = #messages > SESSION_MAX_RECORDS and #messages - SESSION_MAX_RECORDS or 0 -- 962
	local normalizedMessages = dropCount > 0 and __TS__ArraySlice(messages, dropCount) or messages -- 965
	local normalizedLastConsolidatedIndex = clampSessionIndex(normalizedMessages, lastConsolidatedIndex - dropCount) -- 968
	local normalizedCarryMessageIndex = type(carryMessageIndex) == "number" and carryMessageIndex - dropCount >= 0 and carryMessageIndex - dropCount < normalizedLastConsolidatedIndex and carryMessageIndex - dropCount < #normalizedMessages and math.floor(carryMessageIndex - dropCount) or nil -- 972
	local stateLine = self:encodeJsonLine({lastConsolidatedIndex = normalizedLastConsolidatedIndex, carryMessageIndex = normalizedCarryMessageIndex}) -- 978
	if type(stateLine) == "string" and stateLine ~= "" then -- 978
		lines[#lines + 1] = stateLine -- 983
	end -- 983
	do -- 983
		local i = 0 -- 985
		while i < #normalizedMessages do -- 985
			local line = self:encodeJsonLine({message = normalizedMessages[i + 1]}) -- 986
			if type(line) == "string" and line ~= "" then -- 986
				lines[#lines + 1] = line -- 990
			end -- 990
			i = i + 1 -- 985
		end -- 985
	end -- 985
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 993
	Content:save(self.sessionPath, content) -- 994
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 995
end -- 955
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 1007
local MemoryCompressor = ____exports.MemoryCompressor -- 1007
MemoryCompressor.name = "MemoryCompressor" -- 1007
function MemoryCompressor.prototype.____constructor(self, config) -- 1014
	self.consecutiveFailures = 0 -- 1010
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 1015
	do -- 1015
		local i = 0 -- 1016
		while i < #loadedPromptPack.warnings do -- 1016
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 1017
			i = i + 1 -- 1016
		end -- 1016
	end -- 1016
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 1019
	self.config = __TS__ObjectAssign( -- 1022
		{}, -- 1022
		config, -- 1023
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 1022
	) -- 1022
	self.config.compressionThreshold = math.min( -- 1029
		1, -- 1029
		math.max(0.05, self.config.compressionThreshold) -- 1029
	) -- 1029
	self.config.compressionTargetThreshold = math.min( -- 1030
		self.config.compressionThreshold, -- 1031
		math.max(0.05, self.config.compressionTargetThreshold) -- 1032
	) -- 1032
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir, self.config.scope or "") -- 1034
end -- 1014
function MemoryCompressor.prototype.getPromptPack(self) -- 1037
	return self.config.promptPack -- 1038
end -- 1037
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 1044
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1049
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 1055
	return messageTokens > threshold -- 1057
end -- 1044
function MemoryCompressor.prototype.compress(self, messages, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode, systemPrompt, toolDefinitions) -- 1063
	if decisionMode == nil then -- 1063
		decisionMode = "tool_calling" -- 1067
	end -- 1067
	if boundaryMode == nil then -- 1067
		boundaryMode = "default" -- 1069
	end -- 1069
	if systemPrompt == nil then -- 1069
		systemPrompt = "" -- 1070
	end -- 1070
	if toolDefinitions == nil then -- 1070
		toolDefinitions = "" -- 1071
	end -- 1071
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1071
		local toCompress = messages -- 1073
		if #toCompress == 0 then -- 1073
			return ____awaiter_resolve(nil, nil) -- 1073
		end -- 1073
		local currentMemory = self.storage:readMemory() -- 1075
		local boundary = self:findCompressionBoundary( -- 1077
			toCompress, -- 1078
			currentMemory, -- 1079
			boundaryMode, -- 1080
			systemPrompt, -- 1081
			toolDefinitions -- 1082
		) -- 1082
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 1084
		if #chunk == 0 then -- 1084
			return ____awaiter_resolve(nil, nil) -- 1084
		end -- 1084
		local historyText = self:formatMessagesForCompression(chunk) -- 1087
		local ____try = __TS__AsyncAwaiter(function() -- 1087
			local result = __TS__Await(self:callLLMForCompression( -- 1091
				currentMemory, -- 1092
				historyText, -- 1093
				llmOptions, -- 1094
				maxLLMTry or 3, -- 1095
				decisionMode, -- 1096
				debugContext -- 1097
			)) -- 1097
			if result.success then -- 1097
				self.storage:writeMemory(result.memoryUpdate) -- 1102
				if type(result.projectMemoryUpdate) == "string" then -- memory layers
					self.storage:writeProjectMemory(result.projectMemoryUpdate) -- memory layers
				end -- memory layers
				if type(result.sessionSummaryUpdate) == "string" then -- memory layers
					self.storage:writeSessionSummary(result.sessionSummaryUpdate) -- memory layers
				end -- memory layers
				if result.ts then -- 1102
					self.storage:appendHistoryRecord({ts = result.ts, summary = result.summary}) -- 1104
				end -- 1104
				self.consecutiveFailures = 0 -- 1109
				return ____awaiter_resolve( -- 1109
					nil, -- 1109
					__TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessageIndex = boundary.carryMessageIndex}) -- 1111
				) -- 1111
			end -- 1111
			return ____awaiter_resolve( -- 1111
				nil, -- 1111
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 1119
			) -- 1119
		end) -- 1119
		__TS__Await(____try.catch( -- 1089
			____try, -- 1089
			function(____, ____error) -- 1089
				return ____awaiter_resolve( -- 1089
					nil, -- 1089
					self:handleCompressionFailure( -- 1122
						chunk, -- 1122
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 1122
					) -- 1122
				) -- 1122
			end -- 1122
		)) -- 1122
	end) -- 1122
end -- 1063
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode, systemPrompt, toolDefinitions) -- 1131
	local targetTokens = boundaryMode == "budget_max" and math.max( -- 1138
		1, -- 1139
		self:getCompressionHistoryTokenBudget(currentMemory) -- 1139
	) or math.max( -- 1139
		1, -- 1140
		self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 1140
	) -- 1140
	local accumulatedTokens = 0 -- 1141
	local lastSafeBoundary = 0 -- 1142
	local lastSafeBoundaryWithinBudget = 0 -- 1143
	local lastClosedBoundary = 0 -- 1144
	local lastClosedBoundaryWithinBudget = 0 -- 1145
	local pendingToolCalls = {} -- 1146
	local pendingToolCallCount = 0 -- 1147
	local exceededBudget = false -- 1148
	do -- 1148
		local i = 0 -- 1150
		while i < #messages do -- 1150
			local message = messages[i + 1] -- 1151
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 1152
			accumulatedTokens = accumulatedTokens + tokens -- 1153
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1153
				do -- 1153
					local j = 0 -- 1156
					while j < #message.tool_calls do -- 1156
						local toolCallEntry = message.tool_calls[j + 1] -- 1157
						local idValue = toolCallEntry.id -- 1158
						local id = type(idValue) == "string" and idValue or "" -- 1159
						if id ~= "" and not pendingToolCalls[id] then -- 1159
							pendingToolCalls[id] = true -- 1161
							pendingToolCallCount = pendingToolCallCount + 1 -- 1162
						end -- 1162
						j = j + 1 -- 1156
					end -- 1156
				end -- 1156
			end -- 1156
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 1156
				pendingToolCalls[message.tool_call_id] = false -- 1168
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 1169
			end -- 1169
			local isAtEnd = i >= #messages - 1 -- 1172
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 1173
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 1174
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 1175
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 1176
			if isSafeBoundary then -- 1176
				lastSafeBoundary = i + 1 -- 1178
				if accumulatedTokens <= targetTokens then -- 1178
					lastSafeBoundaryWithinBudget = i + 1 -- 1180
				end -- 1180
			end -- 1180
			if isClosedToolBoundary then -- 1180
				lastClosedBoundary = i + 1 -- 1184
				if accumulatedTokens <= targetTokens then -- 1184
					lastClosedBoundaryWithinBudget = i + 1 -- 1186
				end -- 1186
			end -- 1186
			if accumulatedTokens > targetTokens and not exceededBudget then -- 1186
				exceededBudget = true -- 1191
			end -- 1191
			if exceededBudget and isSafeBoundary then -- 1191
				return self:buildCarryBoundary(messages, i + 1) -- 1196
			end -- 1196
			i = i + 1 -- 1150
		end -- 1150
	end -- 1150
	if lastSafeBoundaryWithinBudget > 0 then -- 1150
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 1201
	end -- 1201
	if lastSafeBoundary > 0 then -- 1201
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 1204
	end -- 1204
	if lastClosedBoundaryWithinBudget > 0 then -- 1204
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 1207
	end -- 1207
	if lastClosedBoundary > 0 then -- 1207
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 1210
	end -- 1210
	local fallback = math.min(#messages, 1) -- 1212
	return {chunkEnd = fallback, compressedCount = fallback} -- 1213
end -- 1131
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 1216
	local carryUserIndex = -1 -- 1217
	do -- 1217
		local i = 0 -- 1218
		while i < chunkEnd do -- 1218
			if messages[i + 1].role == "user" then -- 1218
				carryUserIndex = i -- 1220
			end -- 1220
			i = i + 1 -- 1218
		end -- 1218
	end -- 1218
	if carryUserIndex < 0 then -- 1218
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 1224
	end -- 1224
	return {chunkEnd = chunkEnd, compressedCount = chunkEnd, carryMessageIndex = carryUserIndex} -- 1226
end -- 1216
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 1233
	local lines = {} -- 1234
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 1235
	if message.name and message.name ~= "" then -- 1235
		lines[#lines + 1] = "name=" .. message.name -- 1236
	end -- 1236
	if message.tool_call_id and message.tool_call_id ~= "" then -- 1236
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1237
	end -- 1237
	if message.reasoning_content and message.reasoning_content ~= "" then -- 1237
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1238
	end -- 1238
	if message.tool_calls and #message.tool_calls > 0 then -- 1238
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 1240
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1241
	end -- 1241
	if message.content and message.content ~= "" then -- 1241
		lines[#lines + 1] = message.content -- 1243
	end -- 1243
	local prefix = index > 0 and "\n\n" or "" -- 1244
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 1245
end -- 1233
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages, systemPrompt, toolDefinitions) -- 1248
	local currentTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1253
	local threshold = self:getContextWindow() * self.config.compressionTargetThreshold -- 1258
	local overflow = math.max(0, currentTokens - threshold) -- 1259
	if overflow <= 0 then -- 1259
		return math.max( -- 1261
			1, -- 1261
			self:estimateCompressionMessageTokens(messages[1], 0) -- 1261
		) -- 1261
	end -- 1261
	local safetyMargin = math.max( -- 1263
		64, -- 1263
		math.floor(threshold * 0.01) -- 1263
	) -- 1263
	return overflow + safetyMargin -- 1264
end -- 1248
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1267
	local lines = {} -- 1268
	do -- 1268
		local i = 0 -- 1269
		while i < #messages do -- 1269
			local message = messages[i + 1] -- 1270
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1271
			if message.name and message.name ~= "" then -- 1271
				lines[#lines + 1] = "name=" .. message.name -- 1272
			end -- 1272
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1272
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1273
			end -- 1273
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1273
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1274
			end -- 1274
			if message.tool_calls and #message.tool_calls > 0 then -- 1274
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1276
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1277
			end -- 1277
			if message.content and message.content ~= "" then -- 1277
				lines[#lines + 1] = message.content -- 1279
			end -- 1279
			if i < #messages - 1 then -- 1279
				lines[#lines + 1] = "" -- 1280
			end -- 1280
			i = i + 1 -- 1269
		end -- 1269
	end -- 1269
	return table.concat(lines, "\n") -- 1282
end -- 1267
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1288
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1288
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1296
		if decisionMode == "xml" then -- 1296
			return ____awaiter_resolve( -- 1296
				nil, -- 1296
				self:callLLMForCompressionByXML( -- 1298
					currentMemory, -- 1299
					boundedHistoryText, -- 1300
					llmOptions, -- 1301
					maxLLMTry, -- 1302
					debugContext -- 1303
				) -- 1303
			) -- 1303
		end -- 1303
		return ____awaiter_resolve( -- 1303
			nil, -- 1303
			self:callLLMForCompressionByToolCalling( -- 1306
				currentMemory, -- 1307
				boundedHistoryText, -- 1308
				llmOptions, -- 1309
				maxLLMTry, -- 1310
				debugContext -- 1311
			) -- 1311
		) -- 1311
	end) -- 1311
end -- 1288
function MemoryCompressor.prototype.getContextWindow(self) -- 1315
	return math.max(64000, self.config.llmConfig.contextWindow) -- 1316
end -- 1315
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1319
	local contextWindow = self:getContextWindow() -- 1320
	local reservedOutputTokens = math.max( -- 1321
		2048, -- 1321
		math.floor(contextWindow * 0.2) -- 1321
	) -- 1321
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1322
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1323
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1324
	return math.max( -- 1325
		1200, -- 1325
		math.floor(available * 0.9) -- 1325
	) -- 1325
end -- 1319
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1328
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1329
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1330
	if historyTokens <= tokenBudget then -- 1330
		return historyText -- 1331
	end -- 1331
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1332
	local targetChars = math.max( -- 1335
		2000, -- 1335
		math.floor(tokenBudget * charsPerToken) -- 1335
	) -- 1335
	local keepHead = math.max( -- 1336
		0, -- 1336
		math.floor(targetChars * 0.35) -- 1336
	) -- 1336
	local keepTail = math.max(0, targetChars - keepHead) -- 1337
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1338
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1339
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1340
end -- 1328
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1343
	local contextWindow = self:getContextWindow() -- 1347
	local reservedOutputTokens = math.max(2048, math.floor(contextWindow * 0.2)) -- 1348
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1349
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1350
	local boundedMemory = clipTextToTokenBudget(currentMemory or "(empty)", math.max(320, math.floor(dynamicBudget * 0.2))) -- memory layers
	local boundedProjectMemory = clipTextToTokenBudget(self.storage:readProjectMemory() or "(empty)", math.max(320, math.floor(dynamicBudget * 0.2))) -- memory layers
	local boundedSessionSummary = clipTextToTokenBudget(self.storage:readSessionSummary() or "(empty)", math.max(240, math.floor(dynamicBudget * 0.15))) -- memory layers
	local boundedHistory = clipTextToTokenBudget(historyText, math.max(800, math.floor(dynamicBudget * 0.45))) -- memory layers
	return {currentMemory = boundedMemory, currentProjectMemory = boundedProjectMemory, currentSessionSummary = boundedSessionSummary, historyText = boundedHistory} -- memory layers
end -- 1343
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1359
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1359
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1366
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated MEMORY.md as markdown. Core memory only: user preferences, stable facts, decisions, known issues."}, project_memory_update = {type = "string", description = "Full updated PROJECT_MEMORY.md as markdown. Project facts, build/run, files/architecture, project decisions and issues."}, session_summary_update = {type = "string", description = "Full updated SESSION_SUMMARY.md as markdown. Current goal, recent progress, and open issues for this session."}}, required = {"history_entry", "memory_update"}}}}} -- 1369
		local messages = { -- 1393
			{ -- 1394
				role = "system", -- 1395
				content = self:buildToolCallingCompressionSystemPrompt() -- 1396
			}, -- 1396
			{role = "user", content = prompt} -- 1398
		} -- 1398
		local fn -- 1404
		local argsText = "" -- 1405
		do -- 1405
			local i = 0 -- 1406
			while i < maxLLMTry do -- 1406
				local ____opt_4 = debugContext and debugContext.onInput -- 1406
				if ____opt_4 ~= nil then -- 1406
					____opt_4( -- 1407
						debugContext, -- 1407
						"memory_compression_tool_calling", -- 1407
						messages, -- 1407
						__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 1407
					) -- 1407
				end -- 1407
				local response = __TS__Await(callLLM( -- 1413
					messages, -- 1414
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1415
					nil, -- 1420
					self.config.llmConfig -- 1421
				)) -- 1421
				if not response.success then -- 1421
					local ____opt_8 = debugContext and debugContext.onOutput -- 1421
					if ____opt_8 ~= nil then -- 1421
						____opt_8(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false}) -- 1425
					end -- 1425
					return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1425
				end -- 1425
				local ____opt_12 = debugContext and debugContext.onOutput -- 1425
				if ____opt_12 ~= nil then -- 1425
					____opt_12( -- 1433
						debugContext, -- 1433
						"memory_compression_tool_calling", -- 1433
						encodeCompressionDebugJSON(response.response), -- 1433
						{success = true} -- 1433
					) -- 1433
				end -- 1433
				local choice = response.response.choices and response.response.choices[1] -- 1435
				local message = choice and choice.message -- 1436
				local toolCalls = message and message.tool_calls -- 1437
				local toolCall = toolCalls and toolCalls[1] -- 1438
				fn = toolCall and toolCall["function"] -- 1439
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1440
				if fn ~= nil and #argsText > 0 then -- 1440
					break -- 1441
				end -- 1441
				i = i + 1 -- 1406
			end -- 1406
		end -- 1406
		if not fn or fn.name ~= "save_memory" then -- 1406
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing save_memory tool call"}) -- 1406
		end -- 1406
		if __TS__StringTrim(argsText) == "" then -- 1406
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "empty save_memory tool arguments"}) -- 1406
		end -- 1406
		local ____try = __TS__AsyncAwaiter(function() -- 1406
			local args, err = safeJsonDecode(argsText) -- 1464
			if err ~= nil or not args or type(args) ~= "table" then -- 1464
				return ____awaiter_resolve( -- 1464
					nil, -- 1464
					{ -- 1466
						success = false, -- 1467
						memoryUpdate = currentMemory, -- 1468
						compressedCount = 0, -- 1469
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1470
					} -- 1470
				) -- 1470
			end -- 1470
			return ____awaiter_resolve( -- 1470
				nil, -- 1470
				self:buildCompressionResultFromObject(args, currentMemory) -- 1474
			) -- 1474
		end) -- 1474
		__TS__Await(____try.catch( -- 1463
			____try, -- 1463
			function(____, ____error) -- 1463
				return ____awaiter_resolve( -- 1463
					nil, -- 1463
					{ -- 1479
						success = false, -- 1480
						memoryUpdate = currentMemory, -- 1481
						compressedCount = 0, -- 1482
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1483
					} -- 1483
				) -- 1483
			end -- 1483
		)) -- 1483
	end) -- 1483
end -- 1359
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1488
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1488
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1495
		local lastError = "invalid xml response" -- 1496
		do -- 1496
			local i = 0 -- 1498
			while i < maxLLMTry do -- 1498
				do -- 1498
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1499
					local requestMessages = { -- 1504
						{ -- 1505
							role = "system", -- 1505
							content = self:buildXMLCompressionSystemPrompt() -- 1505
						}, -- 1505
						{role = "user", content = prompt .. feedback} -- 1506
					} -- 1506
					local ____opt_16 = debugContext and debugContext.onInput -- 1506
					if ____opt_16 ~= nil then -- 1506
						____opt_16(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1508
					end -- 1508
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1509
					if not response.success then -- 1509
						local ____opt_20 = debugContext and debugContext.onOutput -- 1509
						if ____opt_20 ~= nil then -- 1509
							____opt_20(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1517
						end -- 1517
						return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1517
					end -- 1517
					local choice = response.response.choices and response.response.choices[1] -- 1526
					local message = choice and choice.message -- 1527
					local text = message and type(message.content) == "string" and message.content or "" -- 1528
					local ____opt_24 = debugContext and debugContext.onOutput -- 1528
					if ____opt_24 ~= nil then -- 1528
						____opt_24( -- 1529
							debugContext, -- 1529
							"memory_compression_xml", -- 1529
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1529
							{success = true} -- 1529
						) -- 1529
					end -- 1529
					if __TS__StringTrim(text) == "" then -- 1529
						lastError = "empty xml response" -- 1531
						goto __continue227 -- 1532
					end -- 1532
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1535
					if parsed.success then -- 1535
						return ____awaiter_resolve(nil, parsed) -- 1535
					end -- 1535
					lastError = parsed.error or "invalid xml response" -- 1539
				end -- 1539
				::__continue227:: -- 1539
				i = i + 1 -- 1498
			end -- 1498
		end -- 1498
		return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = lastError}) -- 1498
	end) -- 1498
end -- 1488
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1553
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", CURRENT_PROJECT_MEMORY = self.storage:readProjectMemory() or "(empty)", CURRENT_SESSION_SUMMARY = self.storage:readSessionSummary() or "(empty)", HISTORY_TEXT = historyText}) -- 1554
end -- 1553
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1560
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1561
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, CURRENT_PROJECT_MEMORY = bounded.currentProjectMemory, CURRENT_SESSION_SUMMARY = bounded.currentSessionSummary, HISTORY_TEXT = bounded.historyText}) -- 1562
end -- 1560
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 1568
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 1569
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 1572
end -- 1568
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 1579
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1580
end -- 1579
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 1585
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1586
end -- 1585
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1591
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1592
	if not parsed.success then -- 1592
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = parsed.message} -- 1594
	end -- 1594
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 1601
end -- 1591
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1607
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1611
	local memoryBody = type(obj.memory_update) == "string" and __TS__StringTrim(obj.memory_update) ~= "" and obj.memory_update or currentMemory -- 1612
	local projectMemoryBody = type(obj.project_memory_update) == "string" and __TS__StringTrim(obj.project_memory_update) ~= "" and obj.project_memory_update or self.storage:readProjectMemory() -- memory layers
	local sessionSummaryBody = type(obj.session_summary_update) == "string" and __TS__StringTrim(obj.session_summary_update) ~= "" and obj.session_summary_update or self.storage:readSessionSummary() -- memory layers
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- memory layers
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing history_entry or memory_update"} -- memory layers
	end -- memory layers
	local ts = os.date("%Y-%m-%d %H:%M") -- 1621
	return { -- 1622
		success = true, -- 1623
		memoryUpdate = memoryBody, -- 1624
		projectMemoryUpdate = projectMemoryBody, -- memory layers
		sessionSummaryUpdate = sessionSummaryBody, -- memory layers
		ts = ts, -- 1625
		summary = historyEntry, -- 1626
		compressedCount = 0 -- 1627
	} -- 1627
end -- 1607
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1634
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1638
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1638
		local archived = self:rawArchive(chunk) -- 1641
		self.consecutiveFailures = 0 -- 1642
		return { -- 1644
			success = true, -- 1645
			memoryUpdate = self.storage:readMemory(), -- 1646
			ts = archived.ts, -- 1647
			compressedCount = #chunk -- 1648
		} -- 1648
	end -- 1648
	return { -- 1652
		success = false, -- 1653
		memoryUpdate = self.storage:readMemory(), -- 1654
		compressedCount = 0, -- 1655
		error = ____error -- 1656
	} -- 1656
end -- 1634
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1663
	local ts = os.date("%Y-%m-%d %H:%M") -- 1664
	local rawArchive = self:formatMessagesForCompression(chunk) -- 1665
	self.storage:appendHistoryRecord({ts = ts, rawArchive = rawArchive}) -- 1666
	return {ts = ts} -- 1670
end -- 1663
function MemoryCompressor.prototype.getStorage(self) -- 1676
	return self.storage -- 1677
end -- 1676
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1680
	return math.max( -- 1681
		1, -- 1681
		math.floor(self.config.maxCompressionRounds) -- 1681
	) -- 1681
end -- 1680
MemoryCompressor.MAX_FAILURES = 3 -- 1680
function ____exports.compactSessionMemoryScope(options) -- 1685
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1685
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 1694
		if not llmConfigRes.success then -- 1694
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 1694
		end -- 1694
		local compressor = __TS__New(____exports.MemoryCompressor, { -- 1700
			compressionThreshold = 0.8, -- 1701
			compressionTargetThreshold = 0.5, -- 1702
			maxCompressionRounds = 3, -- 1703
			projectDir = options.projectDir, -- 1704
			llmConfig = llmConfigRes.config, -- 1705
			promptPack = options.promptPack, -- 1706
			scope = options.scope -- 1707
		}) -- 1707
		local storage = compressor:getStorage() -- 1709
		local persistedSession = storage:readSessionState() -- 1710
		local messages = persistedSession.messages -- 1711
		local lastConsolidatedIndex = persistedSession.lastConsolidatedIndex -- 1712
		local carryMessageIndex = persistedSession.carryMessageIndex -- 1713
		local llmOptions = buildMemoryLLMOptions(llmConfigRes.config, options.llmOptions) -- 1714
		while lastConsolidatedIndex < #messages do -- 1714
			local activeMessages = {} -- 1716
			if type(carryMessageIndex) == "number" and carryMessageIndex >= 0 and carryMessageIndex < lastConsolidatedIndex and carryMessageIndex < #messages then -- 1716
				activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, messages[carryMessageIndex + 1]) -- 1723
			end -- 1723
			do -- 1723
				local i = lastConsolidatedIndex -- 1727
				while i < #messages do -- 1727
					activeMessages[#activeMessages + 1] = messages[i + 1] -- 1728
					i = i + 1 -- 1727
				end -- 1727
			end -- 1727
			local result = __TS__Await(compressor:compress( -- 1730
				activeMessages, -- 1731
				llmOptions, -- 1732
				math.max( -- 1733
					1, -- 1733
					math.floor(options.llmMaxTry or 5) -- 1733
				), -- 1733
				options.decisionMode or "tool_calling", -- 1734
				nil, -- 1735
				"budget_max" -- 1736
			)) -- 1736
			if not (result and result.success and result.compressedCount > 0) then -- 1736
				return ____awaiter_resolve(nil, {success = false, message = result and result.error or "memory compaction produced no progress"}) -- 1736
			end -- 1736
			local syntheticPrefixCount = #activeMessages > 0 and lastConsolidatedIndex < #messages and activeMessages[1] ~= messages[lastConsolidatedIndex + 1] and 1 or 0 -- 1744
			local realCompressedCount = math.max(0, result.compressedCount - syntheticPrefixCount) -- 1749
			lastConsolidatedIndex = math.min(#messages, lastConsolidatedIndex + realCompressedCount) -- 1750
			if type(result.carryMessageIndex) == "number" then -- 1750
				if syntheticPrefixCount > 0 and result.carryMessageIndex == 0 then -- 1750
				else -- 1750
					local carryOffset = syntheticPrefixCount > 0 and result.carryMessageIndex - 1 or result.carryMessageIndex -- 1755
					carryMessageIndex = carryOffset >= 0 and lastConsolidatedIndex - realCompressedCount + carryOffset or nil -- 1758
				end -- 1758
			else -- 1758
				carryMessageIndex = nil -- 1763
			end -- 1763
			if type(carryMessageIndex) == "number" and (carryMessageIndex < 0 or carryMessageIndex >= lastConsolidatedIndex or carryMessageIndex >= #messages) then -- 1763
				carryMessageIndex = nil -- 1769
			end -- 1769
			storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1771
		end -- 1771
		return ____awaiter_resolve(nil, {success = true, remainingMessages = #messages - lastConsolidatedIndex}) -- 1771
	end) -- 1771
end -- 1685
return ____exports -- 1685