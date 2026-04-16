-- [ts]: Memory.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
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
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
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
local function isRecord(value) -- 8
	return type(value) == "table" -- 9
end -- 8
local function isArray(value) -- 12
	return __TS__ArrayIsArray(value) -- 13
end -- 12
local AGENT_CONFIG_DIR = ".agent" -- 55
local AGENT_PROMPTS_FILE = "AGENT.md" -- 56
local HISTORY_JSONL_FILE = "HISTORY.jsonl" -- 57
local HISTORY_MAX_RECORDS = 1000 -- 58
local XML_DECISION_SCHEMA_EXAMPLE = "```xml\n<tool_call>\n\t<tool>edit_file</tool>\n\t<reason>Need to update the file content to implement the requested change.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<old_str>\nfunction oldName() {\n\tprint(\"old\");\n}\n\t\t</old_str>\n\t\t<new_str>\nfunction newName() {\n\tprint(\"hello\");\n}\n\t\t</new_str>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>read_file</tool>\n\t<reason>Need to inspect the current implementation before editing.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<startLine>1</startLine>\n\t\t<endLine>200</endLine>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>finish</tool>\n\t<params>\n\t\t<message>Final user-facing answer.</message>\n\t</params>\n</tool_call>\n```" -- 59
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 116
	agentIdentityPrompt = "### Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 117
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. 0 is invalid.\n\t- startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 130
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 177
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 178
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 179
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 180
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 193
	xmlDecisionSystemRepairPrompt = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only.", -- 224
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph\n\t- Include key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 235
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n### Actions to Process\n\n{{HISTORY_TEXT}}", -- 264
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 271
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update>\nFull updated MEMORY.md content\n\t</memory_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Use exactly two child tags: `<history_entry>` and `<memory_update>`.\n- Use CDATA for `<memory_update>` when it spans multiple lines or contains markdown/code.", -- 276
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 293
} -- 293
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn"} -- 296
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 296
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 296
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 302
local function replaceTemplateVars(template, vars) -- 307
	local output = template -- 308
	for key in pairs(vars) do -- 309
		output = table.concat( -- 310
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 310
			vars[key] or "" or "," -- 310
		) -- 310
	end -- 310
	return output -- 312
end -- 307
function ____exports.resolveAgentPromptPack(value) -- 315
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 316
	if value and not isArray(value) and isRecord(value) then -- 316
		do -- 316
			local i = 0 -- 320
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 320
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 321
				if type(value[key]) == "string" then -- 321
					merged[key] = value[key] -- 323
				end -- 323
				i = i + 1 -- 320
			end -- 320
		end -- 320
	end -- 320
	return merged -- 327
end -- 315
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 330
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 331
	local lines = {} -- 332
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 333
	lines[#lines + 1] = "" -- 334
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 335
	lines[#lines + 1] = "" -- 336
	do -- 336
		local i = 0 -- 337
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 337
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 338
			lines[#lines + 1] = "## " .. key -- 339
			local text = pack[key] -- 340
			local split = __TS__StringSplit(text, "\n") -- 341
			do -- 341
				local j = 0 -- 342
				while j < #split do -- 342
					lines[#lines + 1] = split[j + 1] -- 343
					j = j + 1 -- 342
				end -- 342
			end -- 342
			lines[#lines + 1] = "" -- 345
			i = i + 1 -- 337
		end -- 337
	end -- 337
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 347
end -- 330
local function getPromptPackConfigPath(projectRoot) -- 350
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 351
end -- 350
local function ensurePromptPackConfig(projectRoot) -- 354
	local path = getPromptPackConfigPath(projectRoot) -- 355
	if Content:exist(path) then -- 355
		return nil -- 356
	end -- 356
	local dir = Path:getPath(path) -- 357
	if not Content:exist(dir) then -- 357
		Content:mkdir(dir) -- 359
	end -- 359
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 361
	if not Content:save(path, content) then -- 361
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 363
	end -- 363
	sendWebIDEFileUpdate(path, true, content) -- 365
	return nil -- 366
end -- 354
local function parsePromptPackMarkdown(text) -- 369
	if not text or __TS__StringTrim(text) == "" then -- 369
		return { -- 376
			value = {}, -- 377
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 378
			unknown = {} -- 379
		} -- 379
	end -- 379
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 382
	local lines = __TS__StringSplit(normalized, "\n") -- 383
	local sections = {} -- 384
	local unknown = {} -- 385
	local currentHeading = "" -- 386
	local function isKnownPromptPackKey(name) -- 387
		do -- 387
			local i = 0 -- 388
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 388
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 388
					return true -- 389
				end -- 389
				i = i + 1 -- 388
			end -- 388
		end -- 388
		return false -- 391
	end -- 387
	do -- 387
		local i = 0 -- 393
		while i < #lines do -- 393
			do -- 393
				local line = lines[i + 1] -- 394
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 395
				if matchedHeading ~= nil then -- 395
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 397
					if isKnownPromptPackKey(heading) then -- 397
						currentHeading = heading -- 399
						if sections[currentHeading] == nil then -- 399
							sections[currentHeading] = {} -- 401
						end -- 401
						goto __continue29 -- 403
					end -- 403
					if currentHeading == "" then -- 403
						unknown[#unknown + 1] = heading -- 406
						goto __continue29 -- 407
					end -- 407
				end -- 407
				if currentHeading ~= "" then -- 407
					local ____sections_currentHeading_1 = sections[currentHeading] -- 407
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 411
				end -- 411
			end -- 411
			::__continue29:: -- 411
			i = i + 1 -- 393
		end -- 393
	end -- 393
	local value = {} -- 414
	local missing = {} -- 415
	do -- 415
		local i = 0 -- 416
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 416
			do -- 416
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 417
				local section = sections[key] -- 418
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 419
				if body == "" then -- 419
					missing[#missing + 1] = key -- 421
					goto __continue36 -- 422
				end -- 422
				value[key] = body -- 424
			end -- 424
			::__continue36:: -- 424
			i = i + 1 -- 416
		end -- 416
	end -- 416
	if #__TS__ObjectKeys(sections) == 0 then -- 416
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 427
	end -- 427
	return {value = value, missing = missing, unknown = unknown} -- 433
end -- 369
function ____exports.loadAgentPromptPack(projectRoot) -- 436
	local path = getPromptPackConfigPath(projectRoot) -- 437
	local warnings = {} -- 438
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 439
	if ensureWarning and ensureWarning ~= "" then -- 439
		warnings[#warnings + 1] = ensureWarning -- 441
	end -- 441
	if not Content:exist(path) then -- 441
		return { -- 444
			pack = ____exports.resolveAgentPromptPack(), -- 445
			warnings = warnings, -- 446
			path = path -- 447
		} -- 447
	end -- 447
	local text = Content:load(path) -- 450
	if not text or __TS__StringTrim(text) == "" then -- 450
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 452
		return { -- 453
			pack = ____exports.resolveAgentPromptPack(), -- 454
			warnings = warnings, -- 455
			path = path -- 456
		} -- 456
	end -- 456
	local parsed = parsePromptPackMarkdown(text) -- 459
	if parsed.error or not parsed.value then -- 459
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 461
		return { -- 462
			pack = ____exports.resolveAgentPromptPack(), -- 463
			warnings = warnings, -- 464
			path = path -- 465
		} -- 465
	end -- 465
	if #parsed.unknown > 0 then -- 465
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 469
	end -- 469
	if #parsed.missing > 0 then -- 469
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 472
	end -- 472
	return { -- 474
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 475
		warnings = warnings, -- 476
		path = path -- 477
	} -- 477
end -- 436
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 552
local TokenEstimator = ____exports.TokenEstimator -- 552
TokenEstimator.name = "TokenEstimator" -- 552
function TokenEstimator.prototype.____constructor(self) -- 552
end -- 552
function TokenEstimator.estimate(self, text) -- 556
	if not text then -- 556
		return 0 -- 557
	end -- 557
	return App:estimateTokens(text) -- 558
end -- 556
function TokenEstimator.estimateMessages(self, messages) -- 561
	if not messages or #messages == 0 then -- 561
		return 0 -- 562
	end -- 562
	local total = 0 -- 563
	do -- 563
		local i = 0 -- 564
		while i < #messages do -- 564
			local message = messages[i + 1] -- 565
			total = total + self:estimate(message.role or "") -- 566
			total = total + self:estimate(message.content or "") -- 567
			total = total + self:estimate(message.name or "") -- 568
			total = total + self:estimate(message.tool_call_id or "") -- 569
			total = total + self:estimate(message.reasoning_content or "") -- 570
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 571
			total = total + self:estimate(toolCallsText or "") -- 572
			total = total + 8 -- 573
			i = i + 1 -- 564
		end -- 564
	end -- 564
	return total -- 575
end -- 561
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 578
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 583
end -- 578
local function encodeCompressionDebugJSON(value) -- 591
	local text, err = safeJsonEncode(value) -- 592
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 593
end -- 591
local function utf8TakeHead(text, maxChars) -- 596
	if maxChars <= 0 or text == "" then -- 596
		return "" -- 597
	end -- 597
	local nextPos = utf8.offset(text, maxChars + 1) -- 598
	if nextPos == nil then -- 598
		return text -- 599
	end -- 599
	return string.sub(text, 1, nextPos - 1) -- 600
end -- 596
local function utf8TakeTail(text, maxChars) -- 603
	if maxChars <= 0 or text == "" then -- 603
		return "" -- 604
	end -- 604
	local charLen = utf8.len(text) -- 605
	if charLen == nil or charLen <= maxChars then -- 605
		return text -- 606
	end -- 606
	local startChar = math.max(1, charLen - maxChars + 1) -- 607
	local startPos = utf8.offset(text, startChar) -- 608
	if startPos == nil then -- 608
		return text -- 609
	end -- 609
	return string.sub(text, startPos) -- 610
end -- 603
local function ensureDirRecursive(dir) -- 613
	if not dir or dir == "" then -- 613
		return false -- 614
	end -- 614
	if Content:exist(dir) then -- 614
		return Content:isdir(dir) -- 615
	end -- 615
	local parent = Path:getPath(dir) -- 616
	if parent and parent ~= dir and not Content:exist(parent) then -- 616
		if not ensureDirRecursive(parent) then -- 616
			return false -- 619
		end -- 619
	end -- 619
	return Content:mkdir(dir) -- 622
end -- 613
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.jsonl (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 630
local DualLayerStorage = ____exports.DualLayerStorage -- 630
DualLayerStorage.name = "DualLayerStorage" -- 630
function DualLayerStorage.prototype.____constructor(self, projectDir, scope) -- 638
	if scope == nil then -- 638
		scope = "" -- 638
	end -- 638
	self.projectDir = projectDir -- 639
	self.agentRootDir = Path(self.projectDir, ".agent") -- 640
	self.agentDir = scope ~= "" and Path(self.agentRootDir, scope) or self.agentRootDir -- 641
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 644
	self.historyPath = Path(self.agentDir, HISTORY_JSONL_FILE) -- 645
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 646
	self:ensureAgentFiles() -- 647
end -- 638
function DualLayerStorage.prototype.ensureDir(self, dir) -- 650
	if not Content:exist(dir) then -- 650
		ensureDirRecursive(dir) -- 652
	end -- 652
end -- 650
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 656
	if Content:exist(path) then -- 656
		return false -- 657
	end -- 657
	self:ensureDir(Path:getPath(path)) -- 658
	if not Content:save(path, content) then -- 658
		return false -- 660
	end -- 660
	sendWebIDEFileUpdate(path, true, content) -- 662
	return true -- 663
end -- 656
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 666
	self:ensureDir(self.agentRootDir) -- 667
	self:ensureDir(self.agentDir) -- 668
	self:ensureFile(self.memoryPath, "") -- 669
	self:ensureFile(self.historyPath, "") -- 670
end -- 666
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 673
	local text = safeJsonEncode(value) -- 674
	return text -- 675
end -- 673
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 678
	local value = safeJsonDecode(text) -- 679
	return value -- 680
end -- 678
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 683
	if not value or isArray(value) or not isRecord(value) then -- 683
		return nil -- 684
	end -- 684
	local row = value -- 685
	local role = type(row.role) == "string" and row.role or "" -- 686
	if role == "" then -- 686
		return nil -- 687
	end -- 687
	local message = {role = role} -- 688
	if type(row.content) == "string" then -- 688
		message.content = sanitizeUTF8(row.content) -- 689
	end -- 689
	if type(row.name) == "string" then -- 689
		message.name = sanitizeUTF8(row.name) -- 690
	end -- 690
	if type(row.tool_call_id) == "string" then -- 690
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 691
	end -- 691
	if type(row.reasoning_content) == "string" then -- 691
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 692
	end -- 692
	if type(row.timestamp) == "string" then -- 692
		message.timestamp = sanitizeUTF8(row.timestamp) -- 693
	end -- 693
	if isArray(row.tool_calls) then -- 693
		message.tool_calls = row.tool_calls -- 695
	end -- 695
	return message -- 697
end -- 683
function DualLayerStorage.prototype.decodeHistoryRecord(self, value) -- 700
	if not value or isArray(value) or not isRecord(value) then -- 700
		return nil -- 701
	end -- 701
	local row = value -- 702
	local ts = type(row.ts) == "string" and __TS__StringTrim(row.ts) ~= "" and sanitizeUTF8(row.ts) or "" -- 703
	local summary = type(row.summary) == "string" and __TS__StringTrim(row.summary) ~= "" and sanitizeUTF8(row.summary) or nil -- 706
	local rawArchive = type(row.rawArchive) == "string" and __TS__StringTrim(row.rawArchive) ~= "" and sanitizeUTF8(row.rawArchive) or nil -- 709
	if ts == "" or summary == nil and rawArchive == nil then -- 709
		return nil -- 712
	end -- 712
	local record = {ts = ts, summary = summary, rawArchive = rawArchive} -- 713
	return record -- 718
end -- 700
function DualLayerStorage.prototype.readHistoryRecords(self) -- 721
	if not Content:exist(self.historyPath) then -- 721
		return {} -- 723
	end -- 723
	local text = Content:load(self.historyPath) -- 725
	if not text or __TS__StringTrim(text) == "" then -- 725
		return {} -- 727
	end -- 727
	local lines = __TS__StringSplit(text, "\n") -- 729
	local records = {} -- 730
	do -- 730
		local i = 0 -- 731
		while i < #lines do -- 731
			do -- 731
				local line = __TS__StringTrim(lines[i + 1]) -- 732
				if line == "" then -- 732
					goto __continue92 -- 733
				end -- 733
				local decoded = self:decodeJsonLine(line) -- 734
				local record = self:decodeHistoryRecord(decoded) -- 735
				if record then -- 735
					records[#records + 1] = record -- 737
				end -- 737
			end -- 737
			::__continue92:: -- 737
			i = i + 1 -- 731
		end -- 731
	end -- 731
	return records -- 740
end -- 721
function DualLayerStorage.prototype.saveHistoryRecords(self, records) -- 743
	self:ensureDir(Path:getPath(self.historyPath)) -- 744
	local normalized = #records > HISTORY_MAX_RECORDS and __TS__ArraySlice(records, #records - HISTORY_MAX_RECORDS) or records -- 745
	local lines = {} -- 748
	do -- 748
		local i = 0 -- 749
		while i < #normalized do -- 749
			local line = self:encodeJsonLine(normalized[i + 1]) -- 750
			if line then -- 750
				lines[#lines + 1] = line -- 752
			end -- 752
			i = i + 1 -- 749
		end -- 749
	end -- 749
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 755
	Content:save(self.historyPath, content) -- 756
	sendWebIDEFileUpdate(self.historyPath, true, content) -- 757
end -- 743
function DualLayerStorage.prototype.readMemory(self) -- 765
	if not Content:exist(self.memoryPath) then -- 765
		return "" -- 767
	end -- 767
	return Content:load(self.memoryPath) -- 769
end -- 765
function DualLayerStorage.prototype.writeMemory(self, content) -- 775
	self:ensureDir(Path:getPath(self.memoryPath)) -- 776
	Content:save(self.memoryPath, content) -- 777
end -- 775
function DualLayerStorage.prototype.getMemoryContext(self) -- 783
	local memory = self:readMemory() -- 784
	if not memory then -- 784
		return "" -- 785
	end -- 785
	return "### Long-term Memory\n\n" .. memory -- 787
end -- 783
function DualLayerStorage.prototype.appendHistoryRecord(self, record) -- 794
	local records = self:readHistoryRecords() -- 795
	records[#records + 1] = record -- 796
	self:saveHistoryRecords(records) -- 797
end -- 794
function DualLayerStorage.prototype.readSessionState(self) -- 800
	if not Content:exist(self.sessionPath) then -- 800
		return {messages = {}} -- 802
	end -- 802
	local text = Content:load(self.sessionPath) -- 804
	if not text or __TS__StringTrim(text) == "" then -- 804
		return {messages = {}} -- 806
	end -- 806
	local lines = __TS__StringSplit(text, "\n") -- 808
	local messages = {} -- 809
	do -- 809
		local i = 0 -- 810
		while i < #lines do -- 810
			do -- 810
				local line = __TS__StringTrim(lines[i + 1]) -- 811
				if line == "" then -- 811
					goto __continue109 -- 812
				end -- 812
				local data = self:decodeJsonLine(line) -- 813
				if not data or isArray(data) or not isRecord(data) then -- 813
					goto __continue109 -- 814
				end -- 814
				local row = data -- 815
				local ____self_decodeConversationMessage_3 = self.decodeConversationMessage -- 816
				local ____row_message_2 = row.message -- 816
				if ____row_message_2 == nil then -- 816
					____row_message_2 = row -- 816
				end -- 816
				local message = ____self_decodeConversationMessage_3(self, ____row_message_2) -- 816
				if message then -- 816
					messages[#messages + 1] = message -- 818
				end -- 818
			end -- 818
			::__continue109:: -- 818
			i = i + 1 -- 810
		end -- 810
	end -- 810
	return {messages = messages} -- 821
end -- 800
function DualLayerStorage.prototype.writeSessionState(self, messages) -- 824
	if messages == nil then -- 824
		messages = {} -- 824
	end -- 824
	self:ensureDir(Path:getPath(self.sessionPath)) -- 825
	local lines = {} -- 826
	do -- 826
		local i = 0 -- 827
		while i < #messages do -- 827
			local line = self:encodeJsonLine({_type = "message", message = messages[i + 1]}) -- 828
			if line then -- 828
				lines[#lines + 1] = line -- 833
			end -- 833
			i = i + 1 -- 827
		end -- 827
	end -- 827
	local content = table.concat(lines, "\n") .. "\n" -- 836
	Content:save(self.sessionPath, content) -- 837
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 838
end -- 824
____exports.MemoryMergeQueue = __TS__Class() -- 842
local MemoryMergeQueue = ____exports.MemoryMergeQueue -- 842
MemoryMergeQueue.name = "MemoryMergeQueue" -- 842
function MemoryMergeQueue.prototype.____constructor(self, projectDir) -- 845
	self.queueDir = Path(projectDir, ".agent", "memory-merge-queue") -- 846
	self:ensureQueueDir() -- 847
end -- 845
function MemoryMergeQueue.prototype.ensureQueueDir(self) -- 850
	if not Content:exist(self.queueDir) then -- 850
		ensureDirRecursive(self.queueDir) -- 852
	end -- 852
end -- 850
function MemoryMergeQueue.prototype.encodeJson(self, value) -- 856
	local text = safeJsonEncode(value) -- 857
	return text -- 858
end -- 856
function MemoryMergeQueue.prototype.decodeJson(self, text) -- 861
	local value = safeJsonDecode(text) -- 862
	return value -- 863
end -- 861
function MemoryMergeQueue.prototype.sanitizeJobRecord(self, value, path) -- 866
	if not value or isArray(value) or not isRecord(value) then -- 866
		return nil -- 867
	end -- 867
	local row = value -- 868
	local jobId = type(row.jobId) == "string" and sanitizeUTF8(row.jobId) or "" -- 869
	local rootAgentId = type(row.rootAgentId) == "string" and sanitizeUTF8(row.rootAgentId) or "" -- 870
	local sourceAgentId = type(row.sourceAgentId) == "string" and sanitizeUTF8(row.sourceAgentId) or "" -- 871
	local sourceTitle = type(row.sourceTitle) == "string" and sanitizeUTF8(row.sourceTitle) or "" -- 872
	local createdAt = type(row.createdAt) == "string" and sanitizeUTF8(row.createdAt) or "" -- 873
	local spawnValue = row.spawn -- 874
	local memoryValue = row.memory -- 875
	if jobId == "" or rootAgentId == "" or sourceAgentId == "" or sourceTitle == "" or createdAt == "" then -- 875
		return nil -- 877
	end -- 877
	if not spawnValue or isArray(spawnValue) or not isRecord(spawnValue) then -- 877
		return nil -- 879
	end -- 879
	if not memoryValue or isArray(memoryValue) or not isRecord(memoryValue) then -- 879
		return nil -- 880
	end -- 880
	local prompt = type(spawnValue.prompt) == "string" and sanitizeUTF8(spawnValue.prompt) or "" -- 881
	local goal = type(spawnValue.goal) == "string" and sanitizeUTF8(spawnValue.goal) or "" -- 882
	local expectedOutput = type(spawnValue.expectedOutput) == "string" and sanitizeUTF8(spawnValue.expectedOutput) or nil -- 883
	local filesHint = isArray(spawnValue.filesHint) and __TS__ArrayMap( -- 886
		__TS__ArrayFilter( -- 887
			spawnValue.filesHint, -- 887
			function(____, item) return type(item) == "string" end -- 888
		), -- 888
		function(____, item) return sanitizeUTF8(item) end -- 889
	) or nil -- 889
	local finalMemory = type(memoryValue.finalMemory) == "string" and sanitizeUTF8(memoryValue.finalMemory) or "" -- 891
	if prompt == "" or goal == "" or __TS__StringTrim(finalMemory) == "" then -- 891
		return nil -- 895
	end -- 895
	return { -- 897
		jobId = jobId, -- 898
		rootAgentId = rootAgentId, -- 899
		sourceAgentId = sourceAgentId, -- 900
		sourceTitle = sourceTitle, -- 901
		createdAt = createdAt, -- 902
		spawn = {prompt = prompt, goal = goal, expectedOutput = expectedOutput, filesHint = filesHint}, -- 903
		memory = {finalMemory = finalMemory}, -- 909
		attempts = type(row.attempts) == "number" and math.max( -- 912
			0, -- 912
			math.floor(row.attempts) -- 912
		) or nil, -- 912
		lastError = type(row.lastError) == "string" and sanitizeUTF8(row.lastError) or nil, -- 913
		path = path -- 914
	} -- 914
end -- 866
function MemoryMergeQueue.prototype.toPersistedJob(self, job) -- 918
	return { -- 919
		jobId = job.jobId, -- 920
		rootAgentId = job.rootAgentId, -- 921
		sourceAgentId = job.sourceAgentId, -- 922
		sourceTitle = job.sourceTitle, -- 923
		createdAt = job.createdAt, -- 924
		spawn = {prompt = job.spawn.prompt, goal = job.spawn.goal, expectedOutput = job.spawn.expectedOutput, filesHint = job.spawn.filesHint}, -- 925
		memory = {finalMemory = job.memory.finalMemory}, -- 931
		attempts = job.attempts, -- 934
		lastError = job.lastError -- 935
	} -- 935
end -- 918
function MemoryMergeQueue.prototype.listJobs(self) -- 939
	self:ensureQueueDir() -- 940
	if not Content:exist(self.queueDir) or not Content:isdir(self.queueDir) then -- 940
		return {} -- 942
	end -- 942
	local jobs = {} -- 944
	local files = Content:getFiles(self.queueDir) or ({}) -- 945
	__TS__ArraySort(files) -- 946
	do -- 946
		local i = 0 -- 947
		while i < #files do -- 947
			do -- 947
				local rawPath = files[i + 1] -- 948
				local ext = Path:getExt(rawPath) -- 949
				if ext ~= "json" then -- 949
					goto __continue134 -- 950
				end -- 950
				local path = Path(self.queueDir, rawPath) -- 951
				local text = Content:load(path) -- 952
				if not text or __TS__StringTrim(text) == "" then -- 952
					goto __continue134 -- 953
				end -- 953
				local job = self:sanitizeJobRecord( -- 954
					self:decodeJson(text), -- 954
					path -- 954
				) -- 954
				if job then -- 954
					jobs[#jobs + 1] = job -- 956
				else -- 956
					Log("Warn", "[MemoryMergeQueue] Ignored invalid job file: " .. path) -- 958
				end -- 958
			end -- 958
			::__continue134:: -- 958
			i = i + 1 -- 947
		end -- 947
	end -- 947
	__TS__ArraySort( -- 961
		jobs, -- 961
		function(____, a, b) return a.jobId < b.jobId and -1 or (a.jobId > b.jobId and 1 or 0) end -- 961
	) -- 961
	return jobs -- 962
end -- 939
function MemoryMergeQueue.prototype.readOldestJob(self) -- 965
	local jobs = self:listJobs() -- 966
	return #jobs > 0 and jobs[1] or nil -- 967
end -- 965
function MemoryMergeQueue.prototype.writeJob(self, job) -- 970
	self:ensureQueueDir() -- 971
	local path = Path( -- 972
		self.queueDir, -- 972
		sanitizeUTF8(job.jobId) .. ".json" -- 972
	) -- 972
	local text = self:encodeJson(self:toPersistedJob(job)) -- 973
	if not text then -- 973
		return {success = false, message = "failed to encode memory merge job"} -- 975
	end -- 975
	if not Content:save(path, text .. "\n") then -- 975
		return {success = false, message = "failed to save memory merge job: " .. path} -- 978
	end -- 978
	sendWebIDEFileUpdate(path, true, text .. "\n") -- 980
	return {success = true, path = path} -- 981
end -- 970
function MemoryMergeQueue.prototype.updateJobFailure(self, job, ____error) -- 984
	return self:writeJob(__TS__ObjectAssign( -- 985
		{}, -- 985
		job, -- 986
		{ -- 985
			attempts = math.max( -- 987
				0, -- 987
				math.floor(job.attempts or 0) -- 987
			) + 1, -- 987
			lastError = sanitizeUTF8(____error) -- 988
		} -- 988
	)).success -- 988
end -- 984
function MemoryMergeQueue.prototype.deleteJob(self, path) -- 992
	if not path or not Content:exist(path) then -- 992
		return true -- 993
	end -- 993
	local ok = Content:remove(path) -- 994
	if ok then -- 994
		sendWebIDEFileUpdate(path, false, "") -- 996
	end -- 996
	return ok -- 998
end -- 992
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 1010
local MemoryCompressor = ____exports.MemoryCompressor -- 1010
MemoryCompressor.name = "MemoryCompressor" -- 1010
function MemoryCompressor.prototype.____constructor(self, config) -- 1018
	self.consecutiveFailures = 0 -- 1014
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 1019
	do -- 1019
		local i = 0 -- 1020
		while i < #loadedPromptPack.warnings do -- 1020
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 1021
			i = i + 1 -- 1020
		end -- 1020
	end -- 1020
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 1023
	self.config = __TS__ObjectAssign( -- 1026
		{}, -- 1026
		config, -- 1027
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 1026
	) -- 1026
	self.config.compressionThreshold = math.min( -- 1033
		1, -- 1033
		math.max(0.05, self.config.compressionThreshold) -- 1033
	) -- 1033
	self.config.compressionTargetThreshold = math.min( -- 1034
		self.config.compressionThreshold, -- 1035
		math.max(0.05, self.config.compressionTargetThreshold) -- 1036
	) -- 1036
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir, self.config.scope or "") -- 1038
	self.mergeQueue = __TS__New(____exports.MemoryMergeQueue, self.config.projectDir) -- 1039
end -- 1018
function MemoryCompressor.prototype.getPromptPack(self) -- 1042
	return self.config.promptPack -- 1043
end -- 1042
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 1049
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1054
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 1060
	return messageTokens > threshold -- 1062
end -- 1049
function MemoryCompressor.prototype.compress(self, messages, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode, systemPrompt, toolDefinitions) -- 1068
	if decisionMode == nil then -- 1068
		decisionMode = "tool_calling" -- 1072
	end -- 1072
	if boundaryMode == nil then -- 1072
		boundaryMode = "default" -- 1074
	end -- 1074
	if systemPrompt == nil then -- 1074
		systemPrompt = "" -- 1075
	end -- 1075
	if toolDefinitions == nil then -- 1075
		toolDefinitions = "" -- 1076
	end -- 1076
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1076
		local toCompress = messages -- 1078
		if #toCompress == 0 then -- 1078
			return ____awaiter_resolve(nil, nil) -- 1078
		end -- 1078
		local currentMemory = self.storage:readMemory() -- 1080
		local boundary = self:findCompressionBoundary( -- 1082
			toCompress, -- 1083
			currentMemory, -- 1084
			boundaryMode, -- 1085
			systemPrompt, -- 1086
			toolDefinitions -- 1087
		) -- 1087
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 1089
		if #chunk == 0 then -- 1089
			return ____awaiter_resolve(nil, nil) -- 1089
		end -- 1089
		local historyText = self:formatMessagesForCompression(chunk) -- 1092
		local ____try = __TS__AsyncAwaiter(function() -- 1092
			local result = __TS__Await(self:callLLMForCompression( -- 1096
				currentMemory, -- 1097
				historyText, -- 1098
				llmOptions, -- 1099
				maxLLMTry or 3, -- 1100
				decisionMode, -- 1101
				debugContext -- 1102
			)) -- 1102
			if result.success then -- 1102
				self.storage:writeMemory(result.memoryUpdate) -- 1107
				if result.ts then -- 1107
					self.storage:appendHistoryRecord({ts = result.ts, summary = result.summary}) -- 1109
				end -- 1109
				self.consecutiveFailures = 0 -- 1114
				return ____awaiter_resolve( -- 1114
					nil, -- 1114
					__TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessage = boundary.carryMessage}) -- 1116
				) -- 1116
			end -- 1116
			return ____awaiter_resolve( -- 1116
				nil, -- 1116
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 1124
			) -- 1124
		end) -- 1124
		__TS__Await(____try.catch( -- 1094
			____try, -- 1094
			function(____, ____error) -- 1094
				return ____awaiter_resolve( -- 1094
					nil, -- 1094
					self:handleCompressionFailure( -- 1127
						chunk, -- 1127
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 1127
					) -- 1127
				) -- 1127
			end -- 1127
		)) -- 1127
	end) -- 1127
end -- 1068
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode, systemPrompt, toolDefinitions) -- 1136
	local targetTokens = boundaryMode == "budget_max" and math.max( -- 1143
		1, -- 1144
		self:getCompressionHistoryTokenBudget(currentMemory) -- 1144
	) or math.max( -- 1144
		1, -- 1145
		self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 1145
	) -- 1145
	local accumulatedTokens = 0 -- 1146
	local lastSafeBoundary = 0 -- 1147
	local lastSafeBoundaryWithinBudget = 0 -- 1148
	local lastClosedBoundary = 0 -- 1149
	local lastClosedBoundaryWithinBudget = 0 -- 1150
	local pendingToolCalls = {} -- 1151
	local pendingToolCallCount = 0 -- 1152
	local exceededBudget = false -- 1153
	do -- 1153
		local i = 0 -- 1155
		while i < #messages do -- 1155
			local message = messages[i + 1] -- 1156
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 1157
			accumulatedTokens = accumulatedTokens + tokens -- 1158
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1158
				do -- 1158
					local j = 0 -- 1161
					while j < #message.tool_calls do -- 1161
						local toolCallEntry = message.tool_calls[j + 1] -- 1162
						local idValue = toolCallEntry.id -- 1163
						local id = type(idValue) == "string" and idValue or "" -- 1164
						if id ~= "" and not pendingToolCalls[id] then -- 1164
							pendingToolCalls[id] = true -- 1166
							pendingToolCallCount = pendingToolCallCount + 1 -- 1167
						end -- 1167
						j = j + 1 -- 1161
					end -- 1161
				end -- 1161
			end -- 1161
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 1161
				pendingToolCalls[message.tool_call_id] = false -- 1173
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 1174
			end -- 1174
			local isAtEnd = i >= #messages - 1 -- 1177
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 1178
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 1179
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 1180
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 1181
			if isSafeBoundary then -- 1181
				lastSafeBoundary = i + 1 -- 1183
				if accumulatedTokens <= targetTokens then -- 1183
					lastSafeBoundaryWithinBudget = i + 1 -- 1185
				end -- 1185
			end -- 1185
			if isClosedToolBoundary then -- 1185
				lastClosedBoundary = i + 1 -- 1189
				if accumulatedTokens <= targetTokens then -- 1189
					lastClosedBoundaryWithinBudget = i + 1 -- 1191
				end -- 1191
			end -- 1191
			if accumulatedTokens > targetTokens and not exceededBudget then -- 1191
				exceededBudget = true -- 1196
			end -- 1196
			if exceededBudget and isSafeBoundary then -- 1196
				return self:buildCarryBoundary(messages, i + 1) -- 1201
			end -- 1201
			i = i + 1 -- 1155
		end -- 1155
	end -- 1155
	if lastSafeBoundaryWithinBudget > 0 then -- 1155
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 1206
	end -- 1206
	if lastSafeBoundary > 0 then -- 1206
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 1209
	end -- 1209
	if lastClosedBoundaryWithinBudget > 0 then -- 1209
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 1212
	end -- 1212
	if lastClosedBoundary > 0 then -- 1212
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 1215
	end -- 1215
	local fallback = math.min(#messages, 1) -- 1217
	return {chunkEnd = fallback, compressedCount = fallback} -- 1218
end -- 1136
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 1221
	local carryUserIndex = -1 -- 1222
	do -- 1222
		local i = 0 -- 1223
		while i < chunkEnd do -- 1223
			if messages[i + 1].role == "user" then -- 1223
				carryUserIndex = i -- 1225
			end -- 1225
			i = i + 1 -- 1223
		end -- 1223
	end -- 1223
	if carryUserIndex < 0 then -- 1223
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 1229
	end -- 1229
	return { -- 1231
		chunkEnd = chunkEnd, -- 1232
		compressedCount = chunkEnd, -- 1233
		carryMessage = __TS__ObjectAssign({}, messages[carryUserIndex + 1]) -- 1234
	} -- 1234
end -- 1221
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 1240
	local lines = {} -- 1241
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 1242
	if message.name and message.name ~= "" then -- 1242
		lines[#lines + 1] = "name=" .. message.name -- 1243
	end -- 1243
	if message.tool_call_id and message.tool_call_id ~= "" then -- 1243
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1244
	end -- 1244
	if message.reasoning_content and message.reasoning_content ~= "" then -- 1244
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1245
	end -- 1245
	if message.tool_calls and #message.tool_calls > 0 then -- 1245
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 1247
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1248
	end -- 1248
	if message.content and message.content ~= "" then -- 1248
		lines[#lines + 1] = message.content -- 1250
	end -- 1250
	local prefix = index > 0 and "\n\n" or "" -- 1251
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 1252
end -- 1240
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages, systemPrompt, toolDefinitions) -- 1255
	local currentTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1260
	local threshold = self:getContextWindow() * self.config.compressionTargetThreshold -- 1265
	local overflow = math.max(0, currentTokens - threshold) -- 1266
	if overflow <= 0 then -- 1266
		return math.max( -- 1268
			1, -- 1268
			self:estimateCompressionMessageTokens(messages[1], 0) -- 1268
		) -- 1268
	end -- 1268
	local safetyMargin = math.max( -- 1270
		64, -- 1270
		math.floor(threshold * 0.01) -- 1270
	) -- 1270
	return overflow + safetyMargin -- 1271
end -- 1255
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1274
	local lines = {} -- 1275
	do -- 1275
		local i = 0 -- 1276
		while i < #messages do -- 1276
			local message = messages[i + 1] -- 1277
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1278
			if message.name and message.name ~= "" then -- 1278
				lines[#lines + 1] = "name=" .. message.name -- 1279
			end -- 1279
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1279
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1280
			end -- 1280
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1280
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1281
			end -- 1281
			if message.tool_calls and #message.tool_calls > 0 then -- 1281
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1283
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1284
			end -- 1284
			if message.content and message.content ~= "" then -- 1284
				lines[#lines + 1] = message.content -- 1286
			end -- 1286
			if i < #messages - 1 then -- 1286
				lines[#lines + 1] = "" -- 1287
			end -- 1287
			i = i + 1 -- 1276
		end -- 1276
	end -- 1276
	return table.concat(lines, "\n") -- 1289
end -- 1274
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1295
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1295
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1303
		if decisionMode == "xml" then -- 1303
			return ____awaiter_resolve( -- 1303
				nil, -- 1303
				self:callLLMForCompressionByXML( -- 1305
					currentMemory, -- 1306
					boundedHistoryText, -- 1307
					llmOptions, -- 1308
					maxLLMTry, -- 1309
					debugContext -- 1310
				) -- 1310
			) -- 1310
		end -- 1310
		return ____awaiter_resolve( -- 1310
			nil, -- 1310
			self:callLLMForCompressionByToolCalling( -- 1313
				currentMemory, -- 1314
				boundedHistoryText, -- 1315
				llmOptions, -- 1316
				maxLLMTry, -- 1317
				debugContext -- 1318
			) -- 1318
		) -- 1318
	end) -- 1318
end -- 1295
function MemoryCompressor.prototype.getContextWindow(self) -- 1322
	return math.max(4000, self.config.llmConfig.contextWindow) -- 1323
end -- 1322
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1326
	local contextWindow = self:getContextWindow() -- 1327
	local reservedOutputTokens = math.max( -- 1328
		2048, -- 1328
		math.floor(contextWindow * 0.2) -- 1328
	) -- 1328
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1329
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1330
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1331
	return math.max( -- 1332
		1200, -- 1332
		math.floor(available * 0.9) -- 1332
	) -- 1332
end -- 1326
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1335
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1336
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1337
	if historyTokens <= tokenBudget then -- 1337
		return historyText -- 1338
	end -- 1338
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1339
	local targetChars = math.max( -- 1342
		2000, -- 1342
		math.floor(tokenBudget * charsPerToken) -- 1342
	) -- 1342
	local keepHead = math.max( -- 1343
		0, -- 1343
		math.floor(targetChars * 0.35) -- 1343
	) -- 1343
	local keepTail = math.max(0, targetChars - keepHead) -- 1344
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1345
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1346
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1347
end -- 1335
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1350
	local contextWindow = self:getContextWindow() -- 1354
	local reservedOutputTokens = math.max( -- 1355
		2048, -- 1355
		math.floor(contextWindow * 0.2) -- 1355
	) -- 1355
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1356
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1357
	local boundedMemory = clipTextToTokenBudget( -- 1358
		currentMemory or "(empty)", -- 1358
		math.max( -- 1358
			320, -- 1358
			math.floor(dynamicBudget * 0.35) -- 1358
		) -- 1358
	) -- 1358
	local boundedHistory = clipTextToTokenBudget( -- 1359
		historyText, -- 1359
		math.max( -- 1359
			800, -- 1359
			math.floor(dynamicBudget * 0.65) -- 1359
		) -- 1359
	) -- 1359
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 1360
end -- 1350
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1366
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1366
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1373
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 1376
		local messages = { -- 1400
			{ -- 1401
				role = "system", -- 1402
				content = self:buildToolCallingCompressionSystemPrompt() -- 1403
			}, -- 1403
			{role = "user", content = prompt} -- 1405
		} -- 1405
		local fn -- 1411
		local argsText = "" -- 1412
		do -- 1412
			local i = 0 -- 1413
			while i < maxLLMTry do -- 1413
				local ____opt_4 = debugContext and debugContext.onInput -- 1413
				if ____opt_4 ~= nil then -- 1413
					____opt_4( -- 1414
						debugContext, -- 1414
						"memory_compression_tool_calling", -- 1414
						messages, -- 1414
						__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 1414
					) -- 1414
				end -- 1414
				local response = __TS__Await(callLLM( -- 1420
					messages, -- 1421
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1422
					nil, -- 1427
					self.config.llmConfig -- 1428
				)) -- 1428
				if not response.success then -- 1428
					local ____opt_8 = debugContext and debugContext.onOutput -- 1428
					if ____opt_8 ~= nil then -- 1428
						____opt_8(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false}) -- 1432
					end -- 1432
					return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1432
				end -- 1432
				local ____opt_12 = debugContext and debugContext.onOutput -- 1432
				if ____opt_12 ~= nil then -- 1432
					____opt_12( -- 1440
						debugContext, -- 1440
						"memory_compression_tool_calling", -- 1440
						encodeCompressionDebugJSON(response.response), -- 1440
						{success = true} -- 1440
					) -- 1440
				end -- 1440
				local choice = response.response.choices and response.response.choices[1] -- 1442
				local message = choice and choice.message -- 1443
				local toolCalls = message and message.tool_calls -- 1444
				local toolCall = toolCalls and toolCalls[1] -- 1445
				fn = toolCall and toolCall["function"] -- 1446
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1447
				if fn ~= nil and #argsText > 0 then -- 1447
					break -- 1448
				end -- 1448
				i = i + 1 -- 1413
			end -- 1413
		end -- 1413
		if not fn or fn.name ~= "save_memory" then -- 1413
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing save_memory tool call"}) -- 1413
		end -- 1413
		if __TS__StringTrim(argsText) == "" then -- 1413
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "empty save_memory tool arguments"}) -- 1413
		end -- 1413
		local ____try = __TS__AsyncAwaiter(function() -- 1413
			local args, err = safeJsonDecode(argsText) -- 1471
			if err ~= nil or not args or type(args) ~= "table" then -- 1471
				return ____awaiter_resolve( -- 1471
					nil, -- 1471
					{ -- 1473
						success = false, -- 1474
						memoryUpdate = currentMemory, -- 1475
						compressedCount = 0, -- 1476
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1477
					} -- 1477
				) -- 1477
			end -- 1477
			return ____awaiter_resolve( -- 1477
				nil, -- 1477
				self:buildCompressionResultFromObject(args, currentMemory) -- 1481
			) -- 1481
		end) -- 1481
		__TS__Await(____try.catch( -- 1470
			____try, -- 1470
			function(____, ____error) -- 1470
				return ____awaiter_resolve( -- 1470
					nil, -- 1470
					{ -- 1486
						success = false, -- 1487
						memoryUpdate = currentMemory, -- 1488
						compressedCount = 0, -- 1489
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1490
					} -- 1490
				) -- 1490
			end -- 1490
		)) -- 1490
	end) -- 1490
end -- 1366
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1495
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1495
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1502
		local lastError = "invalid xml response" -- 1503
		do -- 1503
			local i = 0 -- 1505
			while i < maxLLMTry do -- 1505
				do -- 1505
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1506
					local requestMessages = { -- 1511
						{ -- 1512
							role = "system", -- 1512
							content = self:buildXMLCompressionSystemPrompt() -- 1512
						}, -- 1512
						{role = "user", content = prompt .. feedback} -- 1513
					} -- 1513
					local ____opt_16 = debugContext and debugContext.onInput -- 1513
					if ____opt_16 ~= nil then -- 1513
						____opt_16(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1515
					end -- 1515
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1516
					if not response.success then -- 1516
						local ____opt_20 = debugContext and debugContext.onOutput -- 1516
						if ____opt_20 ~= nil then -- 1516
							____opt_20(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1524
						end -- 1524
						return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1524
					end -- 1524
					local choice = response.response.choices and response.response.choices[1] -- 1533
					local message = choice and choice.message -- 1534
					local text = message and type(message.content) == "string" and message.content or "" -- 1535
					local ____opt_24 = debugContext and debugContext.onOutput -- 1535
					if ____opt_24 ~= nil then -- 1535
						____opt_24( -- 1536
							debugContext, -- 1536
							"memory_compression_xml", -- 1536
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1536
							{success = true} -- 1536
						) -- 1536
					end -- 1536
					if __TS__StringTrim(text) == "" then -- 1536
						lastError = "empty xml response" -- 1538
						goto __continue219 -- 1539
					end -- 1539
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1542
					if parsed.success then -- 1542
						return ____awaiter_resolve(nil, parsed) -- 1542
					end -- 1542
					lastError = parsed.error or "invalid xml response" -- 1546
				end -- 1546
				::__continue219:: -- 1546
				i = i + 1 -- 1505
			end -- 1505
		end -- 1505
		return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = lastError}) -- 1505
	end) -- 1505
end -- 1495
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1560
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1561
end -- 1560
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1567
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1568
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1569
end -- 1567
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 1575
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 1576
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 1579
end -- 1575
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 1586
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1587
end -- 1586
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 1592
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1593
end -- 1592
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1598
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1599
	if not parsed.success then -- 1599
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = parsed.message} -- 1601
	end -- 1601
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 1608
end -- 1598
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1614
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1618
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1619
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1619
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing history_entry or memory_update"} -- 1621
	end -- 1621
	local ts = os.date("%Y-%m-%d %H:%M") -- 1628
	return { -- 1629
		success = true, -- 1630
		memoryUpdate = memoryBody, -- 1631
		ts = ts, -- 1632
		summary = historyEntry, -- 1633
		compressedCount = 0 -- 1634
	} -- 1634
end -- 1614
function MemoryCompressor.prototype.formatMemoryMergeJobForCompression(self, job) -- 1638
	local lines = { -- 1639
		"### Sub-Agent Memory Handoff", -- 1640
		"job_id=" .. job.jobId, -- 1641
		"root_agent_id=" .. job.rootAgentId, -- 1642
		"source_agent_id=" .. job.sourceAgentId, -- 1643
		"source_title=" .. job.sourceTitle, -- 1644
		"created_at=" .. job.createdAt, -- 1645
		"", -- 1646
		"### Spawn Task", -- 1647
		"prompt=" .. job.spawn.prompt, -- 1648
		"goal=" .. job.spawn.goal -- 1649
	} -- 1649
	if job.spawn.expectedOutput and job.spawn.expectedOutput ~= "" then -- 1649
		lines[#lines + 1] = "expected_output=" .. job.spawn.expectedOutput -- 1652
	end -- 1652
	if job.spawn.filesHint and #job.spawn.filesHint > 0 then -- 1652
		lines[#lines + 1] = "files_hint=" .. table.concat(job.spawn.filesHint, ", ") -- 1655
	end -- 1655
	__TS__ArrayPush(lines, "", "### Final Sub-Agent Memory", job.memory.finalMemory) -- 1657
	return table.concat(lines, "\n") -- 1658
end -- 1638
function MemoryCompressor.prototype.mergeSubAgentMemory(self, job, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1661
	if maxLLMTry == nil then -- 1661
		maxLLMTry = 3 -- 1664
	end -- 1664
	if decisionMode == nil then -- 1664
		decisionMode = "tool_calling" -- 1665
	end -- 1665
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1665
		local currentMemory = self.storage:readMemory() -- 1668
		local historyText = self:formatMemoryMergeJobForCompression(job) -- 1669
		local result = __TS__Await(self:callLLMForCompression( -- 1670
			currentMemory, -- 1671
			historyText, -- 1672
			llmOptions, -- 1673
			maxLLMTry, -- 1674
			decisionMode, -- 1675
			debugContext -- 1676
		)) -- 1676
		if not result.success then -- 1676
			return ____awaiter_resolve(nil, result) -- 1676
		end -- 1676
		self.storage:writeMemory(result.memoryUpdate) -- 1681
		if result.ts then -- 1681
			self.storage:appendHistoryRecord({ts = result.ts, summary = result.summary}) -- 1683
		end -- 1683
		self.consecutiveFailures = 0 -- 1688
		return ____awaiter_resolve(nil, result) -- 1688
	end) -- 1688
end -- 1661
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1695
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1699
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1699
		local archived = self:rawArchive(chunk) -- 1702
		self.consecutiveFailures = 0 -- 1703
		return { -- 1705
			success = true, -- 1706
			memoryUpdate = self.storage:readMemory(), -- 1707
			ts = archived.ts, -- 1708
			compressedCount = #chunk -- 1709
		} -- 1709
	end -- 1709
	return { -- 1713
		success = false, -- 1714
		memoryUpdate = self.storage:readMemory(), -- 1715
		compressedCount = 0, -- 1716
		error = ____error -- 1717
	} -- 1717
end -- 1695
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1724
	local ts = os.date("%Y-%m-%d %H:%M") -- 1725
	local rawArchive = self:formatMessagesForCompression(chunk) -- 1726
	self.storage:appendHistoryRecord({ts = ts, rawArchive = rawArchive}) -- 1727
	return {ts = ts} -- 1731
end -- 1724
function MemoryCompressor.prototype.getStorage(self) -- 1737
	return self.storage -- 1738
end -- 1737
function MemoryCompressor.prototype.getMergeQueue(self) -- 1741
	return self.mergeQueue -- 1742
end -- 1741
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1745
	return math.max( -- 1746
		1, -- 1746
		math.floor(self.config.maxCompressionRounds) -- 1746
	) -- 1746
end -- 1745
MemoryCompressor.MAX_FAILURES = 3 -- 1745
function ____exports.compactSessionMemoryScope(options) -- 1750
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1750
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 1759
		if not llmConfigRes.success then -- 1759
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 1759
		end -- 1759
		local compressor = __TS__New(____exports.MemoryCompressor, { -- 1765
			compressionThreshold = 0.8, -- 1766
			compressionTargetThreshold = 0.5, -- 1767
			maxCompressionRounds = 3, -- 1768
			projectDir = options.projectDir, -- 1769
			llmConfig = llmConfigRes.config, -- 1770
			promptPack = options.promptPack, -- 1771
			scope = options.scope -- 1772
		}) -- 1772
		local storage = compressor:getStorage() -- 1774
		local messages = storage:readSessionState().messages -- 1775
		local llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})) -- 1776
		while #messages > 0 do -- 1776
			local result = __TS__Await(compressor:compress( -- 1782
				messages, -- 1783
				llmOptions, -- 1784
				math.max( -- 1785
					1, -- 1785
					math.floor(options.llmMaxTry or 5) -- 1785
				), -- 1785
				options.decisionMode or "tool_calling", -- 1786
				nil, -- 1787
				"budget_max" -- 1788
			)) -- 1788
			if not (result and result.success and result.compressedCount > 0) then -- 1788
				return ____awaiter_resolve(nil, {success = false, message = result and result.error or "memory compaction produced no progress"}) -- 1788
			end -- 1788
			local remainingMessages = __TS__ArraySlice(messages, result.compressedCount) -- 1796
			if result.carryMessage then -- 1796
				__TS__ArrayUnshift( -- 1798
					remainingMessages, -- 1798
					__TS__ObjectAssign( -- 1798
						{}, -- 1798
						result.carryMessage, -- 1799
						{timestamp = result.carryMessage.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 1798
					) -- 1798
				) -- 1798
			end -- 1798
			messages = remainingMessages -- 1803
			storage:writeSessionState(messages) -- 1804
		end -- 1804
		return ____awaiter_resolve(nil, {success = true, remainingMessages = #messages}) -- 1804
	end) -- 1804
end -- 1750
return ____exports -- 1750