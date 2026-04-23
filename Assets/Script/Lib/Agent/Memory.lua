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
local function isRecord(value) -- 8
	return type(value) == "table" -- 9
end -- 8
local function isArray(value) -- 12
	return __TS__ArrayIsArray(value) -- 13
end -- 12
local function clampSessionIndex(messages, index) -- 32
	if type(index) ~= "number" then -- 32
		return 0 -- 33
	end -- 33
	if index <= 0 then -- 33
		return 0 -- 34
	end -- 34
	return math.min( -- 35
		#messages, -- 35
		math.floor(index) -- 35
	) -- 35
end -- 32
local AGENT_CONFIG_DIR = ".agent" -- 38
local AGENT_PROMPTS_FILE = "AGENT.md" -- 39
local HISTORY_JSONL_FILE = "HISTORY.jsonl" -- 40
local HISTORY_MAX_RECORDS = 1000 -- 41
local SESSION_MAX_RECORDS = 1000 -- 42
local XML_DECISION_SCHEMA_EXAMPLE = "```xml\n<tool_call>\n\t<tool>edit_file</tool>\n\t<reason>Need to update the file content to implement the requested change.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<old_str>\nfunction oldName() {\n\tprint(\"old\");\n}\n\t\t</old_str>\n\t\t<new_str>\nfunction newName() {\n\tprint(\"hello\");\n}\n\t\t</new_str>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>read_file</tool>\n\t<reason>Need to inspect the current implementation before editing.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<startLine>1</startLine>\n\t\t<endLine>200</endLine>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>finish</tool>\n\t<params>\n\t\t<message>Final user-facing answer.</message>\n\t</params>\n</tool_call>\n```" -- 43
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 100
	agentIdentityPrompt = "### Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 101
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. 0 is invalid.\n\t- startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 114
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 161
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 162
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 163
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 164
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 177
	xmlDecisionSystemRepairPrompt = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only.", -- 208
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph\n\t- Include key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 219
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n### Actions to Process\n\n{{HISTORY_TEXT}}", -- 248
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 255
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update>\nFull updated MEMORY.md content\n\t</memory_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Use exactly two child tags: `<history_entry>` and `<memory_update>`.\n- Use CDATA for `<memory_update>` when it spans multiple lines or contains markdown/code.", -- 260
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 277
} -- 277
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn"} -- 280
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 280
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 280
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 286
local function replaceTemplateVars(template, vars) -- 291
	local output = template -- 292
	for key in pairs(vars) do -- 293
		output = table.concat( -- 294
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 294
			vars[key] or "" or "," -- 294
		) -- 294
	end -- 294
	return output -- 296
end -- 291
function ____exports.resolveAgentPromptPack(value) -- 299
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 300
	if value and not isArray(value) and isRecord(value) then -- 300
		do -- 300
			local i = 0 -- 304
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 304
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 305
				if type(value[key]) == "string" then -- 305
					merged[key] = value[key] -- 307
				end -- 307
				i = i + 1 -- 304
			end -- 304
		end -- 304
	end -- 304
	return merged -- 311
end -- 299
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 314
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 315
	local lines = {} -- 316
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 317
	lines[#lines + 1] = "" -- 318
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 319
	lines[#lines + 1] = "" -- 320
	do -- 320
		local i = 0 -- 321
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 321
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 322
			lines[#lines + 1] = "## " .. key -- 323
			local text = pack[key] -- 324
			local split = __TS__StringSplit(text, "\n") -- 325
			do -- 325
				local j = 0 -- 326
				while j < #split do -- 326
					lines[#lines + 1] = split[j + 1] -- 327
					j = j + 1 -- 326
				end -- 326
			end -- 326
			lines[#lines + 1] = "" -- 329
			i = i + 1 -- 321
		end -- 321
	end -- 321
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 331
end -- 314
local function getPromptPackConfigPath(projectRoot) -- 334
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 335
end -- 334
local function ensurePromptPackConfig(projectRoot) -- 338
	local path = getPromptPackConfigPath(projectRoot) -- 339
	if Content:exist(path) then -- 339
		return nil -- 340
	end -- 340
	local dir = Path:getPath(path) -- 341
	if not Content:exist(dir) then -- 341
		Content:mkdir(dir) -- 343
	end -- 343
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 345
	if not Content:save(path, content) then -- 345
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 347
	end -- 347
	sendWebIDEFileUpdate(path, true, content) -- 349
	return nil -- 350
end -- 338
local function parsePromptPackMarkdown(text) -- 353
	if not text or __TS__StringTrim(text) == "" then -- 353
		return { -- 360
			value = {}, -- 361
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 362
			unknown = {} -- 363
		} -- 363
	end -- 363
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 366
	local lines = __TS__StringSplit(normalized, "\n") -- 367
	local sections = {} -- 368
	local unknown = {} -- 369
	local currentHeading = "" -- 370
	local function isKnownPromptPackKey(name) -- 371
		do -- 371
			local i = 0 -- 372
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 372
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 372
					return true -- 373
				end -- 373
				i = i + 1 -- 372
			end -- 372
		end -- 372
		return false -- 375
	end -- 371
	do -- 371
		local i = 0 -- 377
		while i < #lines do -- 377
			do -- 377
				local line = lines[i + 1] -- 378
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 379
				if matchedHeading ~= nil then -- 379
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 381
					if isKnownPromptPackKey(heading) then -- 381
						currentHeading = heading -- 383
						if sections[currentHeading] == nil then -- 383
							sections[currentHeading] = {} -- 385
						end -- 385
						goto __continue32 -- 387
					end -- 387
					if currentHeading == "" then -- 387
						unknown[#unknown + 1] = heading -- 390
						goto __continue32 -- 391
					end -- 391
				end -- 391
				if currentHeading ~= "" then -- 391
					local ____sections_currentHeading_1 = sections[currentHeading] -- 391
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 395
				end -- 395
			end -- 395
			::__continue32:: -- 395
			i = i + 1 -- 377
		end -- 377
	end -- 377
	local value = {} -- 398
	local missing = {} -- 399
	do -- 399
		local i = 0 -- 400
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 400
			do -- 400
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 401
				local section = sections[key] -- 402
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 403
				if body == "" then -- 403
					missing[#missing + 1] = key -- 405
					goto __continue39 -- 406
				end -- 406
				value[key] = body -- 408
			end -- 408
			::__continue39:: -- 408
			i = i + 1 -- 400
		end -- 400
	end -- 400
	if #__TS__ObjectKeys(sections) == 0 then -- 400
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 411
	end -- 411
	return {value = value, missing = missing, unknown = unknown} -- 417
end -- 353
function ____exports.loadAgentPromptPack(projectRoot) -- 420
	local path = getPromptPackConfigPath(projectRoot) -- 421
	local warnings = {} -- 422
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 423
	if ensureWarning and ensureWarning ~= "" then -- 423
		warnings[#warnings + 1] = ensureWarning -- 425
	end -- 425
	if not Content:exist(path) then -- 425
		return { -- 428
			pack = ____exports.resolveAgentPromptPack(), -- 429
			warnings = warnings, -- 430
			path = path -- 431
		} -- 431
	end -- 431
	local text = Content:load(path) -- 434
	if not text or __TS__StringTrim(text) == "" then -- 434
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 436
		return { -- 437
			pack = ____exports.resolveAgentPromptPack(), -- 438
			warnings = warnings, -- 439
			path = path -- 440
		} -- 440
	end -- 440
	local parsed = parsePromptPackMarkdown(text) -- 443
	if parsed.error or not parsed.value then -- 443
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 445
		return { -- 446
			pack = ____exports.resolveAgentPromptPack(), -- 447
			warnings = warnings, -- 448
			path = path -- 449
		} -- 449
	end -- 449
	if #parsed.unknown > 0 then -- 449
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 453
	end -- 453
	if #parsed.missing > 0 then -- 453
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 456
	end -- 456
	return { -- 458
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 459
		warnings = warnings, -- 460
		path = path -- 461
	} -- 461
end -- 420
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 536
local TokenEstimator = ____exports.TokenEstimator -- 536
TokenEstimator.name = "TokenEstimator" -- 536
function TokenEstimator.prototype.____constructor(self) -- 536
end -- 536
function TokenEstimator.estimate(self, text) -- 540
	if not text then -- 540
		return 0 -- 541
	end -- 541
	return App:estimateTokens(text) -- 542
end -- 540
function TokenEstimator.estimateMessages(self, messages) -- 545
	if not messages or #messages == 0 then -- 545
		return 0 -- 546
	end -- 546
	local total = 0 -- 547
	do -- 547
		local i = 0 -- 548
		while i < #messages do -- 548
			local message = messages[i + 1] -- 549
			total = total + self:estimate(message.role or "") -- 550
			total = total + self:estimate(message.content or "") -- 551
			total = total + self:estimate(message.name or "") -- 552
			total = total + self:estimate(message.tool_call_id or "") -- 553
			total = total + self:estimate(message.reasoning_content or "") -- 554
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 555
			total = total + self:estimate(toolCallsText or "") -- 556
			total = total + 8 -- 557
			i = i + 1 -- 548
		end -- 548
	end -- 548
	return total -- 559
end -- 545
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 562
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 567
end -- 562
local function encodeCompressionDebugJSON(value) -- 575
	local text, err = safeJsonEncode(value) -- 576
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 577
end -- 575
local function utf8TakeHead(text, maxChars) -- 580
	if maxChars <= 0 or text == "" then -- 580
		return "" -- 581
	end -- 581
	local nextPos = utf8.offset(text, maxChars + 1) -- 582
	if nextPos == nil then -- 582
		return text -- 583
	end -- 583
	return string.sub(text, 1, nextPos - 1) -- 584
end -- 580
local function utf8TakeTail(text, maxChars) -- 587
	if maxChars <= 0 or text == "" then -- 587
		return "" -- 588
	end -- 588
	local charLen = utf8.len(text) -- 589
	if charLen == nil or charLen <= maxChars then -- 589
		return text -- 590
	end -- 590
	local startChar = math.max(1, charLen - maxChars + 1) -- 591
	local startPos = utf8.offset(text, startChar) -- 592
	if startPos == nil then -- 592
		return text -- 593
	end -- 593
	return string.sub(text, startPos) -- 594
end -- 587
local function ensureDirRecursive(dir) -- 597
	if not dir or dir == "" then -- 597
		return false -- 598
	end -- 598
	if Content:exist(dir) then -- 598
		return Content:isdir(dir) -- 599
	end -- 599
	local parent = Path:getPath(dir) -- 600
	if parent and parent ~= dir and not Content:exist(parent) then -- 600
		if not ensureDirRecursive(parent) then -- 600
			return false -- 603
		end -- 603
	end -- 603
	return Content:mkdir(dir) -- 606
end -- 597
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.jsonl (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 614
local DualLayerStorage = ____exports.DualLayerStorage -- 614
DualLayerStorage.name = "DualLayerStorage" -- 614
function DualLayerStorage.prototype.____constructor(self, projectDir, scope) -- 622
	if scope == nil then -- 622
		scope = "" -- 622
	end -- 622
	self.projectDir = projectDir -- 623
	self.agentRootDir = Path(self.projectDir, ".agent") -- 624
	self.agentDir = scope ~= "" and Path(self.agentRootDir, scope) or self.agentRootDir -- 625
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 628
	self.historyPath = Path(self.agentDir, HISTORY_JSONL_FILE) -- 629
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 630
	self:ensureAgentFiles() -- 631
end -- 622
function DualLayerStorage.prototype.ensureDir(self, dir) -- 634
	if not Content:exist(dir) then -- 634
		ensureDirRecursive(dir) -- 636
	end -- 636
end -- 634
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 640
	if Content:exist(path) then -- 640
		return false -- 641
	end -- 641
	self:ensureDir(Path:getPath(path)) -- 642
	if not Content:save(path, content) then -- 642
		return false -- 644
	end -- 644
	sendWebIDEFileUpdate(path, true, content) -- 646
	return true -- 647
end -- 640
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 650
	self:ensureDir(self.agentRootDir) -- 651
	self:ensureDir(self.agentDir) -- 652
	self:ensureFile(self.memoryPath, "") -- 653
	self:ensureFile(self.historyPath, "") -- 654
end -- 650
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 657
	local text = safeJsonEncode(value) -- 658
	return text -- 659
end -- 657
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 662
	local value = safeJsonDecode(text) -- 663
	return value -- 664
end -- 662
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 667
	if not value or isArray(value) or not isRecord(value) then -- 667
		return nil -- 668
	end -- 668
	local row = value -- 669
	local role = type(row.role) == "string" and row.role or "" -- 670
	if role == "" then -- 670
		return nil -- 671
	end -- 671
	local message = {role = role} -- 672
	if type(row.content) == "string" then -- 672
		message.content = sanitizeUTF8(row.content) -- 673
	end -- 673
	if type(row.name) == "string" then -- 673
		message.name = sanitizeUTF8(row.name) -- 674
	end -- 674
	if type(row.tool_call_id) == "string" then -- 674
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 675
	end -- 675
	if type(row.reasoning_content) == "string" then -- 675
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 676
	end -- 676
	if type(row.timestamp) == "string" then -- 676
		message.timestamp = sanitizeUTF8(row.timestamp) -- 677
	end -- 677
	if isArray(row.tool_calls) then -- 677
		message.tool_calls = row.tool_calls -- 679
	end -- 679
	return message -- 681
end -- 667
function DualLayerStorage.prototype.decodeHistoryRecord(self, value) -- 684
	if not value or isArray(value) or not isRecord(value) then -- 684
		return nil -- 685
	end -- 685
	local row = value -- 686
	local ts = type(row.ts) == "string" and __TS__StringTrim(row.ts) ~= "" and sanitizeUTF8(row.ts) or "" -- 687
	local summary = type(row.summary) == "string" and __TS__StringTrim(row.summary) ~= "" and sanitizeUTF8(row.summary) or nil -- 690
	local rawArchive = type(row.rawArchive) == "string" and __TS__StringTrim(row.rawArchive) ~= "" and sanitizeUTF8(row.rawArchive) or nil -- 693
	if ts == "" or summary == nil and rawArchive == nil then -- 693
		return nil -- 696
	end -- 696
	local record = {ts = ts, summary = summary, rawArchive = rawArchive} -- 697
	return record -- 702
end -- 684
function DualLayerStorage.prototype.readHistoryRecords(self) -- 705
	if not Content:exist(self.historyPath) then -- 705
		return {} -- 707
	end -- 707
	local text = Content:load(self.historyPath) -- 709
	if not text or __TS__StringTrim(text) == "" then -- 709
		return {} -- 711
	end -- 711
	local lines = __TS__StringSplit(text, "\n") -- 713
	local records = {} -- 714
	do -- 714
		local i = 0 -- 715
		while i < #lines do -- 715
			do -- 715
				local line = __TS__StringTrim(lines[i + 1]) -- 716
				if line == "" then -- 716
					goto __continue95 -- 717
				end -- 717
				local decoded = self:decodeJsonLine(line) -- 718
				local record = self:decodeHistoryRecord(decoded) -- 719
				if record then -- 719
					records[#records + 1] = record -- 721
				end -- 721
			end -- 721
			::__continue95:: -- 721
			i = i + 1 -- 715
		end -- 715
	end -- 715
	return records -- 724
end -- 705
function DualLayerStorage.prototype.saveHistoryRecords(self, records) -- 727
	self:ensureDir(Path:getPath(self.historyPath)) -- 728
	local normalized = #records > HISTORY_MAX_RECORDS and __TS__ArraySlice(records, #records - HISTORY_MAX_RECORDS) or records -- 729
	local lines = {} -- 732
	do -- 732
		local i = 0 -- 733
		while i < #normalized do -- 733
			local line = self:encodeJsonLine(normalized[i + 1]) -- 734
			if line then -- 734
				lines[#lines + 1] = line -- 736
			end -- 736
			i = i + 1 -- 733
		end -- 733
	end -- 733
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 739
	Content:save(self.historyPath, content) -- 740
	sendWebIDEFileUpdate(self.historyPath, true, content) -- 741
end -- 727
function DualLayerStorage.prototype.readMemory(self) -- 749
	if not Content:exist(self.memoryPath) then -- 749
		return "" -- 751
	end -- 751
	return Content:load(self.memoryPath) -- 753
end -- 749
function DualLayerStorage.prototype.writeMemory(self, content) -- 759
	self:ensureDir(Path:getPath(self.memoryPath)) -- 760
	Content:save(self.memoryPath, content) -- 761
end -- 759
function DualLayerStorage.prototype.getMemoryContext(self) -- 767
	local memory = self:readMemory() -- 768
	if not memory then -- 768
		return "" -- 769
	end -- 769
	return "### Long-term Memory\n\n" .. memory -- 771
end -- 767
function DualLayerStorage.prototype.appendHistoryRecord(self, record) -- 778
	local records = self:readHistoryRecords() -- 779
	records[#records + 1] = record -- 780
	self:saveHistoryRecords(records) -- 781
end -- 778
function DualLayerStorage.prototype.readSessionState(self) -- 784
	if not Content:exist(self.sessionPath) then -- 784
		return {messages = {}, lastConsolidatedIndex = 0} -- 786
	end -- 786
	local text = Content:load(self.sessionPath) -- 788
	if not text or __TS__StringTrim(text) == "" then -- 788
		return {messages = {}, lastConsolidatedIndex = 0} -- 790
	end -- 790
	local lines = __TS__StringSplit(text, "\n") -- 792
	local messages = {} -- 793
	local lastConsolidatedIndex = 0 -- 794
	local carryMessageIndex = nil -- 795
	do -- 795
		local i = 0 -- 796
		while i < #lines do -- 796
			do -- 796
				local line = __TS__StringTrim(lines[i + 1]) -- 797
				if line == "" then -- 797
					goto __continue112 -- 798
				end -- 798
				local data = self:decodeJsonLine(line) -- 799
				if not data or isArray(data) or not isRecord(data) then -- 799
					goto __continue112 -- 800
				end -- 800
				local row = data -- 801
				if type(row.lastConsolidatedIndex) == "number" then -- 801
					lastConsolidatedIndex = math.floor(row.lastConsolidatedIndex) -- 803
					if type(row.carryMessageIndex) == "number" then -- 803
						carryMessageIndex = math.floor(row.carryMessageIndex) -- 805
					end -- 805
					goto __continue112 -- 807
				end -- 807
				local ____self_decodeConversationMessage_3 = self.decodeConversationMessage -- 809
				local ____row_message_2 = row.message -- 809
				if ____row_message_2 == nil then -- 809
					____row_message_2 = row -- 809
				end -- 809
				local message = ____self_decodeConversationMessage_3(self, ____row_message_2) -- 809
				if message then -- 809
					messages[#messages + 1] = message -- 811
				end -- 811
			end -- 811
			::__continue112:: -- 811
			i = i + 1 -- 796
		end -- 796
	end -- 796
	local normalizedLastConsolidatedIndex = clampSessionIndex(messages, lastConsolidatedIndex) -- 814
	local normalizedCarryMessageIndex = type(carryMessageIndex) == "number" and carryMessageIndex >= 0 and carryMessageIndex < normalizedLastConsolidatedIndex and carryMessageIndex < #messages and math.floor(carryMessageIndex) or nil -- 815
	return {messages = messages, lastConsolidatedIndex = normalizedLastConsolidatedIndex, carryMessageIndex = normalizedCarryMessageIndex} -- 821
end -- 784
function DualLayerStorage.prototype.writeSessionState(self, messages, lastConsolidatedIndex, carryMessageIndex) -- 828
	if messages == nil then -- 828
		messages = {} -- 829
	end -- 829
	if lastConsolidatedIndex == nil then -- 829
		lastConsolidatedIndex = 0 -- 830
	end -- 830
	self:ensureDir(Path:getPath(self.sessionPath)) -- 833
	local lines = {} -- 834
	local dropCount = #messages > SESSION_MAX_RECORDS and #messages - SESSION_MAX_RECORDS or 0 -- 835
	local normalizedMessages = dropCount > 0 and __TS__ArraySlice(messages, dropCount) or messages -- 838
	local normalizedLastConsolidatedIndex = clampSessionIndex(normalizedMessages, lastConsolidatedIndex - dropCount) -- 841
	local normalizedCarryMessageIndex = type(carryMessageIndex) == "number" and carryMessageIndex - dropCount >= 0 and carryMessageIndex - dropCount < normalizedLastConsolidatedIndex and carryMessageIndex - dropCount < #normalizedMessages and math.floor(carryMessageIndex - dropCount) or nil -- 845
	local stateLine = self:encodeJsonLine({lastConsolidatedIndex = normalizedLastConsolidatedIndex, carryMessageIndex = normalizedCarryMessageIndex}) -- 851
	if stateLine then -- 851
		lines[#lines + 1] = stateLine -- 856
	end -- 856
	do -- 856
		local i = 0 -- 858
		while i < #normalizedMessages do -- 858
			local line = self:encodeJsonLine({message = normalizedMessages[i + 1]}) -- 859
			if line then -- 859
				lines[#lines + 1] = line -- 863
			end -- 863
			i = i + 1 -- 858
		end -- 858
	end -- 858
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 866
	Content:save(self.sessionPath, content) -- 867
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 868
end -- 828
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 880
local MemoryCompressor = ____exports.MemoryCompressor -- 880
MemoryCompressor.name = "MemoryCompressor" -- 880
function MemoryCompressor.prototype.____constructor(self, config) -- 887
	self.consecutiveFailures = 0 -- 883
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 888
	do -- 888
		local i = 0 -- 889
		while i < #loadedPromptPack.warnings do -- 889
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 890
			i = i + 1 -- 889
		end -- 889
	end -- 889
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 892
	self.config = __TS__ObjectAssign( -- 895
		{}, -- 895
		config, -- 896
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 895
	) -- 895
	self.config.compressionThreshold = math.min( -- 902
		1, -- 902
		math.max(0.05, self.config.compressionThreshold) -- 902
	) -- 902
	self.config.compressionTargetThreshold = math.min( -- 903
		self.config.compressionThreshold, -- 904
		math.max(0.05, self.config.compressionTargetThreshold) -- 905
	) -- 905
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir, self.config.scope or "") -- 907
end -- 887
function MemoryCompressor.prototype.getPromptPack(self) -- 910
	return self.config.promptPack -- 911
end -- 910
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 917
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 922
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 928
	return messageTokens > threshold -- 930
end -- 917
function MemoryCompressor.prototype.compress(self, messages, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode, systemPrompt, toolDefinitions) -- 936
	if decisionMode == nil then -- 936
		decisionMode = "tool_calling" -- 940
	end -- 940
	if boundaryMode == nil then -- 940
		boundaryMode = "default" -- 942
	end -- 942
	if systemPrompt == nil then -- 942
		systemPrompt = "" -- 943
	end -- 943
	if toolDefinitions == nil then -- 943
		toolDefinitions = "" -- 944
	end -- 944
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 944
		local toCompress = messages -- 946
		if #toCompress == 0 then -- 946
			return ____awaiter_resolve(nil, nil) -- 946
		end -- 946
		local currentMemory = self.storage:readMemory() -- 948
		local boundary = self:findCompressionBoundary( -- 950
			toCompress, -- 951
			currentMemory, -- 952
			boundaryMode, -- 953
			systemPrompt, -- 954
			toolDefinitions -- 955
		) -- 955
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 957
		if #chunk == 0 then -- 957
			return ____awaiter_resolve(nil, nil) -- 957
		end -- 957
		local historyText = self:formatMessagesForCompression(chunk) -- 960
		local ____try = __TS__AsyncAwaiter(function() -- 960
			local result = __TS__Await(self:callLLMForCompression( -- 964
				currentMemory, -- 965
				historyText, -- 966
				llmOptions, -- 967
				maxLLMTry or 3, -- 968
				decisionMode, -- 969
				debugContext -- 970
			)) -- 970
			if result.success then -- 970
				self.storage:writeMemory(result.memoryUpdate) -- 975
				if result.ts then -- 975
					self.storage:appendHistoryRecord({ts = result.ts, summary = result.summary}) -- 977
				end -- 977
				self.consecutiveFailures = 0 -- 982
				return ____awaiter_resolve( -- 982
					nil, -- 982
					__TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessageIndex = boundary.carryMessageIndex}) -- 984
				) -- 984
			end -- 984
			return ____awaiter_resolve( -- 984
				nil, -- 984
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 992
			) -- 992
		end) -- 992
		__TS__Await(____try.catch( -- 962
			____try, -- 962
			function(____, ____error) -- 962
				return ____awaiter_resolve( -- 962
					nil, -- 962
					self:handleCompressionFailure( -- 995
						chunk, -- 995
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 995
					) -- 995
				) -- 995
			end -- 995
		)) -- 995
	end) -- 995
end -- 936
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode, systemPrompt, toolDefinitions) -- 1004
	local targetTokens = boundaryMode == "budget_max" and math.max( -- 1011
		1, -- 1012
		self:getCompressionHistoryTokenBudget(currentMemory) -- 1012
	) or math.max( -- 1012
		1, -- 1013
		self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 1013
	) -- 1013
	local accumulatedTokens = 0 -- 1014
	local lastSafeBoundary = 0 -- 1015
	local lastSafeBoundaryWithinBudget = 0 -- 1016
	local lastClosedBoundary = 0 -- 1017
	local lastClosedBoundaryWithinBudget = 0 -- 1018
	local pendingToolCalls = {} -- 1019
	local pendingToolCallCount = 0 -- 1020
	local exceededBudget = false -- 1021
	do -- 1021
		local i = 0 -- 1023
		while i < #messages do -- 1023
			local message = messages[i + 1] -- 1024
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 1025
			accumulatedTokens = accumulatedTokens + tokens -- 1026
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1026
				do -- 1026
					local j = 0 -- 1029
					while j < #message.tool_calls do -- 1029
						local toolCallEntry = message.tool_calls[j + 1] -- 1030
						local idValue = toolCallEntry.id -- 1031
						local id = type(idValue) == "string" and idValue or "" -- 1032
						if id ~= "" and not pendingToolCalls[id] then -- 1032
							pendingToolCalls[id] = true -- 1034
							pendingToolCallCount = pendingToolCallCount + 1 -- 1035
						end -- 1035
						j = j + 1 -- 1029
					end -- 1029
				end -- 1029
			end -- 1029
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 1029
				pendingToolCalls[message.tool_call_id] = false -- 1041
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 1042
			end -- 1042
			local isAtEnd = i >= #messages - 1 -- 1045
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 1046
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 1047
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 1048
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 1049
			if isSafeBoundary then -- 1049
				lastSafeBoundary = i + 1 -- 1051
				if accumulatedTokens <= targetTokens then -- 1051
					lastSafeBoundaryWithinBudget = i + 1 -- 1053
				end -- 1053
			end -- 1053
			if isClosedToolBoundary then -- 1053
				lastClosedBoundary = i + 1 -- 1057
				if accumulatedTokens <= targetTokens then -- 1057
					lastClosedBoundaryWithinBudget = i + 1 -- 1059
				end -- 1059
			end -- 1059
			if accumulatedTokens > targetTokens and not exceededBudget then -- 1059
				exceededBudget = true -- 1064
			end -- 1064
			if exceededBudget and isSafeBoundary then -- 1064
				return self:buildCarryBoundary(messages, i + 1) -- 1069
			end -- 1069
			i = i + 1 -- 1023
		end -- 1023
	end -- 1023
	if lastSafeBoundaryWithinBudget > 0 then -- 1023
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 1074
	end -- 1074
	if lastSafeBoundary > 0 then -- 1074
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 1077
	end -- 1077
	if lastClosedBoundaryWithinBudget > 0 then -- 1077
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 1080
	end -- 1080
	if lastClosedBoundary > 0 then -- 1080
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 1083
	end -- 1083
	local fallback = math.min(#messages, 1) -- 1085
	return {chunkEnd = fallback, compressedCount = fallback} -- 1086
end -- 1004
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 1089
	local carryUserIndex = -1 -- 1090
	do -- 1090
		local i = 0 -- 1091
		while i < chunkEnd do -- 1091
			if messages[i + 1].role == "user" then -- 1091
				carryUserIndex = i -- 1093
			end -- 1093
			i = i + 1 -- 1091
		end -- 1091
	end -- 1091
	if carryUserIndex < 0 then -- 1091
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 1097
	end -- 1097
	return {chunkEnd = chunkEnd, compressedCount = chunkEnd, carryMessageIndex = carryUserIndex} -- 1099
end -- 1089
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 1106
	local lines = {} -- 1107
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 1108
	if message.name and message.name ~= "" then -- 1108
		lines[#lines + 1] = "name=" .. message.name -- 1109
	end -- 1109
	if message.tool_call_id and message.tool_call_id ~= "" then -- 1109
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1110
	end -- 1110
	if message.reasoning_content and message.reasoning_content ~= "" then -- 1110
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1111
	end -- 1111
	if message.tool_calls and #message.tool_calls > 0 then -- 1111
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 1113
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1114
	end -- 1114
	if message.content and message.content ~= "" then -- 1114
		lines[#lines + 1] = message.content -- 1116
	end -- 1116
	local prefix = index > 0 and "\n\n" or "" -- 1117
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 1118
end -- 1106
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages, systemPrompt, toolDefinitions) -- 1121
	local currentTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1126
	local threshold = self:getContextWindow() * self.config.compressionTargetThreshold -- 1131
	local overflow = math.max(0, currentTokens - threshold) -- 1132
	if overflow <= 0 then -- 1132
		return math.max( -- 1134
			1, -- 1134
			self:estimateCompressionMessageTokens(messages[1], 0) -- 1134
		) -- 1134
	end -- 1134
	local safetyMargin = math.max( -- 1136
		64, -- 1136
		math.floor(threshold * 0.01) -- 1136
	) -- 1136
	return overflow + safetyMargin -- 1137
end -- 1121
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1140
	local lines = {} -- 1141
	do -- 1141
		local i = 0 -- 1142
		while i < #messages do -- 1142
			local message = messages[i + 1] -- 1143
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1144
			if message.name and message.name ~= "" then -- 1144
				lines[#lines + 1] = "name=" .. message.name -- 1145
			end -- 1145
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1145
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1146
			end -- 1146
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1146
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1147
			end -- 1147
			if message.tool_calls and #message.tool_calls > 0 then -- 1147
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1149
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1150
			end -- 1150
			if message.content and message.content ~= "" then -- 1150
				lines[#lines + 1] = message.content -- 1152
			end -- 1152
			if i < #messages - 1 then -- 1152
				lines[#lines + 1] = "" -- 1153
			end -- 1153
			i = i + 1 -- 1142
		end -- 1142
	end -- 1142
	return table.concat(lines, "\n") -- 1155
end -- 1140
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1161
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1161
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1169
		if decisionMode == "xml" then -- 1169
			return ____awaiter_resolve( -- 1169
				nil, -- 1169
				self:callLLMForCompressionByXML( -- 1171
					currentMemory, -- 1172
					boundedHistoryText, -- 1173
					llmOptions, -- 1174
					maxLLMTry, -- 1175
					debugContext -- 1176
				) -- 1176
			) -- 1176
		end -- 1176
		return ____awaiter_resolve( -- 1176
			nil, -- 1176
			self:callLLMForCompressionByToolCalling( -- 1179
				currentMemory, -- 1180
				boundedHistoryText, -- 1181
				llmOptions, -- 1182
				maxLLMTry, -- 1183
				debugContext -- 1184
			) -- 1184
		) -- 1184
	end) -- 1184
end -- 1161
function MemoryCompressor.prototype.getContextWindow(self) -- 1188
	return math.max(4000, self.config.llmConfig.contextWindow) -- 1189
end -- 1188
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1192
	local contextWindow = self:getContextWindow() -- 1193
	local reservedOutputTokens = math.max( -- 1194
		2048, -- 1194
		math.floor(contextWindow * 0.2) -- 1194
	) -- 1194
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1195
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1196
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1197
	return math.max( -- 1198
		1200, -- 1198
		math.floor(available * 0.9) -- 1198
	) -- 1198
end -- 1192
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1201
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1202
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1203
	if historyTokens <= tokenBudget then -- 1203
		return historyText -- 1204
	end -- 1204
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1205
	local targetChars = math.max( -- 1208
		2000, -- 1208
		math.floor(tokenBudget * charsPerToken) -- 1208
	) -- 1208
	local keepHead = math.max( -- 1209
		0, -- 1209
		math.floor(targetChars * 0.35) -- 1209
	) -- 1209
	local keepTail = math.max(0, targetChars - keepHead) -- 1210
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1211
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1212
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1213
end -- 1201
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1216
	local contextWindow = self:getContextWindow() -- 1220
	local reservedOutputTokens = math.max( -- 1221
		2048, -- 1221
		math.floor(contextWindow * 0.2) -- 1221
	) -- 1221
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1222
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1223
	local boundedMemory = clipTextToTokenBudget( -- 1224
		currentMemory or "(empty)", -- 1224
		math.max( -- 1224
			320, -- 1224
			math.floor(dynamicBudget * 0.35) -- 1224
		) -- 1224
	) -- 1224
	local boundedHistory = clipTextToTokenBudget( -- 1225
		historyText, -- 1225
		math.max( -- 1225
			800, -- 1225
			math.floor(dynamicBudget * 0.65) -- 1225
		) -- 1225
	) -- 1225
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 1226
end -- 1216
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1232
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1232
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1239
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 1242
		local messages = { -- 1266
			{ -- 1267
				role = "system", -- 1268
				content = self:buildToolCallingCompressionSystemPrompt() -- 1269
			}, -- 1269
			{role = "user", content = prompt} -- 1271
		} -- 1271
		local fn -- 1277
		local argsText = "" -- 1278
		do -- 1278
			local i = 0 -- 1279
			while i < maxLLMTry do -- 1279
				local ____opt_4 = debugContext and debugContext.onInput -- 1279
				if ____opt_4 ~= nil then -- 1279
					____opt_4( -- 1280
						debugContext, -- 1280
						"memory_compression_tool_calling", -- 1280
						messages, -- 1280
						__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 1280
					) -- 1280
				end -- 1280
				local response = __TS__Await(callLLM( -- 1286
					messages, -- 1287
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1288
					nil, -- 1293
					self.config.llmConfig -- 1294
				)) -- 1294
				if not response.success then -- 1294
					local ____opt_8 = debugContext and debugContext.onOutput -- 1294
					if ____opt_8 ~= nil then -- 1294
						____opt_8(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false}) -- 1298
					end -- 1298
					return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1298
				end -- 1298
				local ____opt_12 = debugContext and debugContext.onOutput -- 1298
				if ____opt_12 ~= nil then -- 1298
					____opt_12( -- 1306
						debugContext, -- 1306
						"memory_compression_tool_calling", -- 1306
						encodeCompressionDebugJSON(response.response), -- 1306
						{success = true} -- 1306
					) -- 1306
				end -- 1306
				local choice = response.response.choices and response.response.choices[1] -- 1308
				local message = choice and choice.message -- 1309
				local toolCalls = message and message.tool_calls -- 1310
				local toolCall = toolCalls and toolCalls[1] -- 1311
				fn = toolCall and toolCall["function"] -- 1312
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1313
				if fn ~= nil and #argsText > 0 then -- 1313
					break -- 1314
				end -- 1314
				i = i + 1 -- 1279
			end -- 1279
		end -- 1279
		if not fn or fn.name ~= "save_memory" then -- 1279
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing save_memory tool call"}) -- 1279
		end -- 1279
		if __TS__StringTrim(argsText) == "" then -- 1279
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "empty save_memory tool arguments"}) -- 1279
		end -- 1279
		local ____try = __TS__AsyncAwaiter(function() -- 1279
			local args, err = safeJsonDecode(argsText) -- 1337
			if err ~= nil or not args or type(args) ~= "table" then -- 1337
				return ____awaiter_resolve( -- 1337
					nil, -- 1337
					{ -- 1339
						success = false, -- 1340
						memoryUpdate = currentMemory, -- 1341
						compressedCount = 0, -- 1342
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1343
					} -- 1343
				) -- 1343
			end -- 1343
			return ____awaiter_resolve( -- 1343
				nil, -- 1343
				self:buildCompressionResultFromObject(args, currentMemory) -- 1347
			) -- 1347
		end) -- 1347
		__TS__Await(____try.catch( -- 1336
			____try, -- 1336
			function(____, ____error) -- 1336
				return ____awaiter_resolve( -- 1336
					nil, -- 1336
					{ -- 1352
						success = false, -- 1353
						memoryUpdate = currentMemory, -- 1354
						compressedCount = 0, -- 1355
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1356
					} -- 1356
				) -- 1356
			end -- 1356
		)) -- 1356
	end) -- 1356
end -- 1232
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1361
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1361
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1368
		local lastError = "invalid xml response" -- 1369
		do -- 1369
			local i = 0 -- 1371
			while i < maxLLMTry do -- 1371
				do -- 1371
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1372
					local requestMessages = { -- 1377
						{ -- 1378
							role = "system", -- 1378
							content = self:buildXMLCompressionSystemPrompt() -- 1378
						}, -- 1378
						{role = "user", content = prompt .. feedback} -- 1379
					} -- 1379
					local ____opt_16 = debugContext and debugContext.onInput -- 1379
					if ____opt_16 ~= nil then -- 1379
						____opt_16(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1381
					end -- 1381
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1382
					if not response.success then -- 1382
						local ____opt_20 = debugContext and debugContext.onOutput -- 1382
						if ____opt_20 ~= nil then -- 1382
							____opt_20(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1390
						end -- 1390
						return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1390
					end -- 1390
					local choice = response.response.choices and response.response.choices[1] -- 1399
					local message = choice and choice.message -- 1400
					local text = message and type(message.content) == "string" and message.content or "" -- 1401
					local ____opt_24 = debugContext and debugContext.onOutput -- 1401
					if ____opt_24 ~= nil then -- 1401
						____opt_24( -- 1402
							debugContext, -- 1402
							"memory_compression_xml", -- 1402
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1402
							{success = true} -- 1402
						) -- 1402
					end -- 1402
					if __TS__StringTrim(text) == "" then -- 1402
						lastError = "empty xml response" -- 1404
						goto __continue194 -- 1405
					end -- 1405
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1408
					if parsed.success then -- 1408
						return ____awaiter_resolve(nil, parsed) -- 1408
					end -- 1408
					lastError = parsed.error or "invalid xml response" -- 1412
				end -- 1412
				::__continue194:: -- 1412
				i = i + 1 -- 1371
			end -- 1371
		end -- 1371
		return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = lastError}) -- 1371
	end) -- 1371
end -- 1361
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1426
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1427
end -- 1426
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1433
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1434
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1435
end -- 1433
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 1441
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 1442
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 1445
end -- 1441
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 1452
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1453
end -- 1452
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 1458
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1459
end -- 1458
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1464
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1465
	if not parsed.success then -- 1465
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = parsed.message} -- 1467
	end -- 1467
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 1474
end -- 1464
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1480
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1484
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1485
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1485
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing history_entry or memory_update"} -- 1487
	end -- 1487
	local ts = os.date("%Y-%m-%d %H:%M") -- 1494
	return { -- 1495
		success = true, -- 1496
		memoryUpdate = memoryBody, -- 1497
		ts = ts, -- 1498
		summary = historyEntry, -- 1499
		compressedCount = 0 -- 1500
	} -- 1500
end -- 1480
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1507
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1511
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1511
		local archived = self:rawArchive(chunk) -- 1514
		self.consecutiveFailures = 0 -- 1515
		return { -- 1517
			success = true, -- 1518
			memoryUpdate = self.storage:readMemory(), -- 1519
			ts = archived.ts, -- 1520
			compressedCount = #chunk -- 1521
		} -- 1521
	end -- 1521
	return { -- 1525
		success = false, -- 1526
		memoryUpdate = self.storage:readMemory(), -- 1527
		compressedCount = 0, -- 1528
		error = ____error -- 1529
	} -- 1529
end -- 1507
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1536
	local ts = os.date("%Y-%m-%d %H:%M") -- 1537
	local rawArchive = self:formatMessagesForCompression(chunk) -- 1538
	self.storage:appendHistoryRecord({ts = ts, rawArchive = rawArchive}) -- 1539
	return {ts = ts} -- 1543
end -- 1536
function MemoryCompressor.prototype.getStorage(self) -- 1549
	return self.storage -- 1550
end -- 1549
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1553
	return math.max( -- 1554
		1, -- 1554
		math.floor(self.config.maxCompressionRounds) -- 1554
	) -- 1554
end -- 1553
MemoryCompressor.MAX_FAILURES = 3 -- 1553
function ____exports.compactSessionMemoryScope(options) -- 1558
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1558
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 1567
		if not llmConfigRes.success then -- 1567
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 1567
		end -- 1567
		local compressor = __TS__New(____exports.MemoryCompressor, { -- 1573
			compressionThreshold = 0.8, -- 1574
			compressionTargetThreshold = 0.5, -- 1575
			maxCompressionRounds = 3, -- 1576
			projectDir = options.projectDir, -- 1577
			llmConfig = llmConfigRes.config, -- 1578
			promptPack = options.promptPack, -- 1579
			scope = options.scope -- 1580
		}) -- 1580
		local storage = compressor:getStorage() -- 1582
		local persistedSession = storage:readSessionState() -- 1583
		local messages = persistedSession.messages -- 1584
		local lastConsolidatedIndex = persistedSession.lastConsolidatedIndex -- 1585
		local carryMessageIndex = persistedSession.carryMessageIndex -- 1586
		local llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})) -- 1587
		while lastConsolidatedIndex < #messages do -- 1587
			local activeMessages = {} -- 1593
			if type(carryMessageIndex) == "number" and carryMessageIndex >= 0 and carryMessageIndex < lastConsolidatedIndex and carryMessageIndex < #messages then -- 1593
				activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, messages[carryMessageIndex + 1]) -- 1600
			end -- 1600
			do -- 1600
				local i = lastConsolidatedIndex -- 1604
				while i < #messages do -- 1604
					activeMessages[#activeMessages + 1] = messages[i + 1] -- 1605
					i = i + 1 -- 1604
				end -- 1604
			end -- 1604
			local result = __TS__Await(compressor:compress( -- 1607
				activeMessages, -- 1608
				llmOptions, -- 1609
				math.max( -- 1610
					1, -- 1610
					math.floor(options.llmMaxTry or 5) -- 1610
				), -- 1610
				options.decisionMode or "tool_calling", -- 1611
				nil, -- 1612
				"budget_max" -- 1613
			)) -- 1613
			if not (result and result.success and result.compressedCount > 0) then -- 1613
				return ____awaiter_resolve(nil, {success = false, message = result and result.error or "memory compaction produced no progress"}) -- 1613
			end -- 1613
			local syntheticPrefixCount = #activeMessages > 0 and lastConsolidatedIndex < #messages and activeMessages[1] ~= messages[lastConsolidatedIndex + 1] and 1 or 0 -- 1621
			local realCompressedCount = math.max(0, result.compressedCount - syntheticPrefixCount) -- 1626
			lastConsolidatedIndex = math.min(#messages, lastConsolidatedIndex + realCompressedCount) -- 1627
			if type(result.carryMessageIndex) == "number" then -- 1627
				if syntheticPrefixCount > 0 and result.carryMessageIndex == 0 then -- 1627
				else -- 1627
					local carryOffset = syntheticPrefixCount > 0 and result.carryMessageIndex - 1 or result.carryMessageIndex -- 1632
					carryMessageIndex = carryOffset >= 0 and lastConsolidatedIndex - realCompressedCount + carryOffset or nil -- 1635
				end -- 1635
			else -- 1635
				carryMessageIndex = nil -- 1640
			end -- 1640
			if type(carryMessageIndex) == "number" and (carryMessageIndex < 0 or carryMessageIndex >= lastConsolidatedIndex or carryMessageIndex >= #messages) then -- 1640
				carryMessageIndex = nil -- 1646
			end -- 1646
			storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1648
		end -- 1648
		return ____awaiter_resolve(nil, {success = true, remainingMessages = #messages - lastConsolidatedIndex}) -- 1648
	end) -- 1648
end -- 1558
return ____exports -- 1558