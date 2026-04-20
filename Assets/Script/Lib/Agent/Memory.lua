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
local AGENT_CONFIG_DIR = ".agent" -- 30
local AGENT_PROMPTS_FILE = "AGENT.md" -- 31
local HISTORY_JSONL_FILE = "HISTORY.jsonl" -- 32
local HISTORY_MAX_RECORDS = 1000 -- 33
local XML_DECISION_SCHEMA_EXAMPLE = "```xml\n<tool_call>\n\t<tool>edit_file</tool>\n\t<reason>Need to update the file content to implement the requested change.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<old_str>\nfunction oldName() {\n\tprint(\"old\");\n}\n\t\t</old_str>\n\t\t<new_str>\nfunction newName() {\n\tprint(\"hello\");\n}\n\t\t</new_str>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>read_file</tool>\n\t<reason>Need to inspect the current implementation before editing.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<startLine>1</startLine>\n\t\t<endLine>200</endLine>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>finish</tool>\n\t<params>\n\t\t<message>Final user-facing answer.</message>\n\t</params>\n</tool_call>\n```" -- 34
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 91
	agentIdentityPrompt = "### Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 92
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. 0 is invalid.\n\t- startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If old_str is empty, create the file when it doesn't exist, or clear and rewrite the whole file with new_str when it already exists\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 105
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 152
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 153
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 154
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 155
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 168
	xmlDecisionSystemRepairPrompt = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only.", -- 199
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph\n\t- Include key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 210
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n### Actions to Process\n\n{{HISTORY_TEXT}}", -- 239
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 246
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update>\nFull updated MEMORY.md content\n\t</memory_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Use exactly two child tags: `<history_entry>` and `<memory_update>`.\n- Use CDATA for `<memory_update>` when it spans multiple lines or contains markdown/code.", -- 251
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 268
} -- 268
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn"} -- 271
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 271
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 271
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 277
local function replaceTemplateVars(template, vars) -- 282
	local output = template -- 283
	for key in pairs(vars) do -- 284
		output = table.concat( -- 285
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 285
			vars[key] or "" or "," -- 285
		) -- 285
	end -- 285
	return output -- 287
end -- 282
function ____exports.resolveAgentPromptPack(value) -- 290
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 291
	if value and not isArray(value) and isRecord(value) then -- 291
		do -- 291
			local i = 0 -- 295
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 295
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 296
				if type(value[key]) == "string" then -- 296
					merged[key] = value[key] -- 298
				end -- 298
				i = i + 1 -- 295
			end -- 295
		end -- 295
	end -- 295
	return merged -- 302
end -- 290
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 305
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 306
	local lines = {} -- 307
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 308
	lines[#lines + 1] = "" -- 309
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 310
	lines[#lines + 1] = "" -- 311
	do -- 311
		local i = 0 -- 312
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 312
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 313
			lines[#lines + 1] = "## " .. key -- 314
			local text = pack[key] -- 315
			local split = __TS__StringSplit(text, "\n") -- 316
			do -- 316
				local j = 0 -- 317
				while j < #split do -- 317
					lines[#lines + 1] = split[j + 1] -- 318
					j = j + 1 -- 317
				end -- 317
			end -- 317
			lines[#lines + 1] = "" -- 320
			i = i + 1 -- 312
		end -- 312
	end -- 312
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 322
end -- 305
local function getPromptPackConfigPath(projectRoot) -- 325
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 326
end -- 325
local function ensurePromptPackConfig(projectRoot) -- 329
	local path = getPromptPackConfigPath(projectRoot) -- 330
	if Content:exist(path) then -- 330
		return nil -- 331
	end -- 331
	local dir = Path:getPath(path) -- 332
	if not Content:exist(dir) then -- 332
		Content:mkdir(dir) -- 334
	end -- 334
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 336
	if not Content:save(path, content) then -- 336
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 338
	end -- 338
	sendWebIDEFileUpdate(path, true, content) -- 340
	return nil -- 341
end -- 329
local function parsePromptPackMarkdown(text) -- 344
	if not text or __TS__StringTrim(text) == "" then -- 344
		return { -- 351
			value = {}, -- 352
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 353
			unknown = {} -- 354
		} -- 354
	end -- 354
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 357
	local lines = __TS__StringSplit(normalized, "\n") -- 358
	local sections = {} -- 359
	local unknown = {} -- 360
	local currentHeading = "" -- 361
	local function isKnownPromptPackKey(name) -- 362
		do -- 362
			local i = 0 -- 363
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 363
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 363
					return true -- 364
				end -- 364
				i = i + 1 -- 363
			end -- 363
		end -- 363
		return false -- 366
	end -- 362
	do -- 362
		local i = 0 -- 368
		while i < #lines do -- 368
			do -- 368
				local line = lines[i + 1] -- 369
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 370
				if matchedHeading ~= nil then -- 370
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 372
					if isKnownPromptPackKey(heading) then -- 372
						currentHeading = heading -- 374
						if sections[currentHeading] == nil then -- 374
							sections[currentHeading] = {} -- 376
						end -- 376
						goto __continue29 -- 378
					end -- 378
					if currentHeading == "" then -- 378
						unknown[#unknown + 1] = heading -- 381
						goto __continue29 -- 382
					end -- 382
				end -- 382
				if currentHeading ~= "" then -- 382
					local ____sections_currentHeading_1 = sections[currentHeading] -- 382
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 386
				end -- 386
			end -- 386
			::__continue29:: -- 386
			i = i + 1 -- 368
		end -- 368
	end -- 368
	local value = {} -- 389
	local missing = {} -- 390
	do -- 390
		local i = 0 -- 391
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 391
			do -- 391
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 392
				local section = sections[key] -- 393
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 394
				if body == "" then -- 394
					missing[#missing + 1] = key -- 396
					goto __continue36 -- 397
				end -- 397
				value[key] = body -- 399
			end -- 399
			::__continue36:: -- 399
			i = i + 1 -- 391
		end -- 391
	end -- 391
	if #__TS__ObjectKeys(sections) == 0 then -- 391
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 402
	end -- 402
	return {value = value, missing = missing, unknown = unknown} -- 408
end -- 344
function ____exports.loadAgentPromptPack(projectRoot) -- 411
	local path = getPromptPackConfigPath(projectRoot) -- 412
	local warnings = {} -- 413
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 414
	if ensureWarning and ensureWarning ~= "" then -- 414
		warnings[#warnings + 1] = ensureWarning -- 416
	end -- 416
	if not Content:exist(path) then -- 416
		return { -- 419
			pack = ____exports.resolveAgentPromptPack(), -- 420
			warnings = warnings, -- 421
			path = path -- 422
		} -- 422
	end -- 422
	local text = Content:load(path) -- 425
	if not text or __TS__StringTrim(text) == "" then -- 425
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 427
		return { -- 428
			pack = ____exports.resolveAgentPromptPack(), -- 429
			warnings = warnings, -- 430
			path = path -- 431
		} -- 431
	end -- 431
	local parsed = parsePromptPackMarkdown(text) -- 434
	if parsed.error or not parsed.value then -- 434
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 436
		return { -- 437
			pack = ____exports.resolveAgentPromptPack(), -- 438
			warnings = warnings, -- 439
			path = path -- 440
		} -- 440
	end -- 440
	if #parsed.unknown > 0 then -- 440
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 444
	end -- 444
	if #parsed.missing > 0 then -- 444
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 447
	end -- 447
	return { -- 449
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 450
		warnings = warnings, -- 451
		path = path -- 452
	} -- 452
end -- 411
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 527
local TokenEstimator = ____exports.TokenEstimator -- 527
TokenEstimator.name = "TokenEstimator" -- 527
function TokenEstimator.prototype.____constructor(self) -- 527
end -- 527
function TokenEstimator.estimate(self, text) -- 531
	if not text then -- 531
		return 0 -- 532
	end -- 532
	return App:estimateTokens(text) -- 533
end -- 531
function TokenEstimator.estimateMessages(self, messages) -- 536
	if not messages or #messages == 0 then -- 536
		return 0 -- 537
	end -- 537
	local total = 0 -- 538
	do -- 538
		local i = 0 -- 539
		while i < #messages do -- 539
			local message = messages[i + 1] -- 540
			total = total + self:estimate(message.role or "") -- 541
			total = total + self:estimate(message.content or "") -- 542
			total = total + self:estimate(message.name or "") -- 543
			total = total + self:estimate(message.tool_call_id or "") -- 544
			total = total + self:estimate(message.reasoning_content or "") -- 545
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 546
			total = total + self:estimate(toolCallsText or "") -- 547
			total = total + 8 -- 548
			i = i + 1 -- 539
		end -- 539
	end -- 539
	return total -- 550
end -- 536
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 553
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 558
end -- 553
local function encodeCompressionDebugJSON(value) -- 566
	local text, err = safeJsonEncode(value) -- 567
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 568
end -- 566
local function utf8TakeHead(text, maxChars) -- 571
	if maxChars <= 0 or text == "" then -- 571
		return "" -- 572
	end -- 572
	local nextPos = utf8.offset(text, maxChars + 1) -- 573
	if nextPos == nil then -- 573
		return text -- 574
	end -- 574
	return string.sub(text, 1, nextPos - 1) -- 575
end -- 571
local function utf8TakeTail(text, maxChars) -- 578
	if maxChars <= 0 or text == "" then -- 578
		return "" -- 579
	end -- 579
	local charLen = utf8.len(text) -- 580
	if charLen == nil or charLen <= maxChars then -- 580
		return text -- 581
	end -- 581
	local startChar = math.max(1, charLen - maxChars + 1) -- 582
	local startPos = utf8.offset(text, startChar) -- 583
	if startPos == nil then -- 583
		return text -- 584
	end -- 584
	return string.sub(text, startPos) -- 585
end -- 578
local function ensureDirRecursive(dir) -- 588
	if not dir or dir == "" then -- 588
		return false -- 589
	end -- 589
	if Content:exist(dir) then -- 589
		return Content:isdir(dir) -- 590
	end -- 590
	local parent = Path:getPath(dir) -- 591
	if parent and parent ~= dir and not Content:exist(parent) then -- 591
		if not ensureDirRecursive(parent) then -- 591
			return false -- 594
		end -- 594
	end -- 594
	return Content:mkdir(dir) -- 597
end -- 588
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.jsonl (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 605
local DualLayerStorage = ____exports.DualLayerStorage -- 605
DualLayerStorage.name = "DualLayerStorage" -- 605
function DualLayerStorage.prototype.____constructor(self, projectDir, scope) -- 613
	if scope == nil then -- 613
		scope = "" -- 613
	end -- 613
	self.projectDir = projectDir -- 614
	self.agentRootDir = Path(self.projectDir, ".agent") -- 615
	self.agentDir = scope ~= "" and Path(self.agentRootDir, scope) or self.agentRootDir -- 616
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 619
	self.historyPath = Path(self.agentDir, HISTORY_JSONL_FILE) -- 620
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 621
	self:ensureAgentFiles() -- 622
end -- 613
function DualLayerStorage.prototype.ensureDir(self, dir) -- 625
	if not Content:exist(dir) then -- 625
		ensureDirRecursive(dir) -- 627
	end -- 627
end -- 625
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 631
	if Content:exist(path) then -- 631
		return false -- 632
	end -- 632
	self:ensureDir(Path:getPath(path)) -- 633
	if not Content:save(path, content) then -- 633
		return false -- 635
	end -- 635
	sendWebIDEFileUpdate(path, true, content) -- 637
	return true -- 638
end -- 631
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 641
	self:ensureDir(self.agentRootDir) -- 642
	self:ensureDir(self.agentDir) -- 643
	self:ensureFile(self.memoryPath, "") -- 644
	self:ensureFile(self.historyPath, "") -- 645
end -- 641
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 648
	local text = safeJsonEncode(value) -- 649
	return text -- 650
end -- 648
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 653
	local value = safeJsonDecode(text) -- 654
	return value -- 655
end -- 653
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 658
	if not value or isArray(value) or not isRecord(value) then -- 658
		return nil -- 659
	end -- 659
	local row = value -- 660
	local role = type(row.role) == "string" and row.role or "" -- 661
	if role == "" then -- 661
		return nil -- 662
	end -- 662
	local message = {role = role} -- 663
	if type(row.content) == "string" then -- 663
		message.content = sanitizeUTF8(row.content) -- 664
	end -- 664
	if type(row.name) == "string" then -- 664
		message.name = sanitizeUTF8(row.name) -- 665
	end -- 665
	if type(row.tool_call_id) == "string" then -- 665
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 666
	end -- 666
	if type(row.reasoning_content) == "string" then -- 666
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 667
	end -- 667
	if type(row.timestamp) == "string" then -- 667
		message.timestamp = sanitizeUTF8(row.timestamp) -- 668
	end -- 668
	if isArray(row.tool_calls) then -- 668
		message.tool_calls = row.tool_calls -- 670
	end -- 670
	return message -- 672
end -- 658
function DualLayerStorage.prototype.decodeHistoryRecord(self, value) -- 675
	if not value or isArray(value) or not isRecord(value) then -- 675
		return nil -- 676
	end -- 676
	local row = value -- 677
	local ts = type(row.ts) == "string" and __TS__StringTrim(row.ts) ~= "" and sanitizeUTF8(row.ts) or "" -- 678
	local summary = type(row.summary) == "string" and __TS__StringTrim(row.summary) ~= "" and sanitizeUTF8(row.summary) or nil -- 681
	local rawArchive = type(row.rawArchive) == "string" and __TS__StringTrim(row.rawArchive) ~= "" and sanitizeUTF8(row.rawArchive) or nil -- 684
	if ts == "" or summary == nil and rawArchive == nil then -- 684
		return nil -- 687
	end -- 687
	local record = {ts = ts, summary = summary, rawArchive = rawArchive} -- 688
	return record -- 693
end -- 675
function DualLayerStorage.prototype.readHistoryRecords(self) -- 696
	if not Content:exist(self.historyPath) then -- 696
		return {} -- 698
	end -- 698
	local text = Content:load(self.historyPath) -- 700
	if not text or __TS__StringTrim(text) == "" then -- 700
		return {} -- 702
	end -- 702
	local lines = __TS__StringSplit(text, "\n") -- 704
	local records = {} -- 705
	do -- 705
		local i = 0 -- 706
		while i < #lines do -- 706
			do -- 706
				local line = __TS__StringTrim(lines[i + 1]) -- 707
				if line == "" then -- 707
					goto __continue92 -- 708
				end -- 708
				local decoded = self:decodeJsonLine(line) -- 709
				local record = self:decodeHistoryRecord(decoded) -- 710
				if record then -- 710
					records[#records + 1] = record -- 712
				end -- 712
			end -- 712
			::__continue92:: -- 712
			i = i + 1 -- 706
		end -- 706
	end -- 706
	return records -- 715
end -- 696
function DualLayerStorage.prototype.saveHistoryRecords(self, records) -- 718
	self:ensureDir(Path:getPath(self.historyPath)) -- 719
	local normalized = #records > HISTORY_MAX_RECORDS and __TS__ArraySlice(records, #records - HISTORY_MAX_RECORDS) or records -- 720
	local lines = {} -- 723
	do -- 723
		local i = 0 -- 724
		while i < #normalized do -- 724
			local line = self:encodeJsonLine(normalized[i + 1]) -- 725
			if line then -- 725
				lines[#lines + 1] = line -- 727
			end -- 727
			i = i + 1 -- 724
		end -- 724
	end -- 724
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 730
	Content:save(self.historyPath, content) -- 731
	sendWebIDEFileUpdate(self.historyPath, true, content) -- 732
end -- 718
function DualLayerStorage.prototype.readMemory(self) -- 740
	if not Content:exist(self.memoryPath) then -- 740
		return "" -- 742
	end -- 742
	return Content:load(self.memoryPath) -- 744
end -- 740
function DualLayerStorage.prototype.writeMemory(self, content) -- 750
	self:ensureDir(Path:getPath(self.memoryPath)) -- 751
	Content:save(self.memoryPath, content) -- 752
end -- 750
function DualLayerStorage.prototype.getMemoryContext(self) -- 758
	local memory = self:readMemory() -- 759
	if not memory then -- 759
		return "" -- 760
	end -- 760
	return "### Long-term Memory\n\n" .. memory -- 762
end -- 758
function DualLayerStorage.prototype.appendHistoryRecord(self, record) -- 769
	local records = self:readHistoryRecords() -- 770
	records[#records + 1] = record -- 771
	self:saveHistoryRecords(records) -- 772
end -- 769
function DualLayerStorage.prototype.readSessionState(self) -- 775
	if not Content:exist(self.sessionPath) then -- 775
		return {messages = {}} -- 777
	end -- 777
	local text = Content:load(self.sessionPath) -- 779
	if not text or __TS__StringTrim(text) == "" then -- 779
		return {messages = {}} -- 781
	end -- 781
	local lines = __TS__StringSplit(text, "\n") -- 783
	local messages = {} -- 784
	do -- 784
		local i = 0 -- 785
		while i < #lines do -- 785
			do -- 785
				local line = __TS__StringTrim(lines[i + 1]) -- 786
				if line == "" then -- 786
					goto __continue109 -- 787
				end -- 787
				local data = self:decodeJsonLine(line) -- 788
				if not data or isArray(data) or not isRecord(data) then -- 788
					goto __continue109 -- 789
				end -- 789
				local row = data -- 790
				local ____self_decodeConversationMessage_3 = self.decodeConversationMessage -- 791
				local ____row_message_2 = row.message -- 791
				if ____row_message_2 == nil then -- 791
					____row_message_2 = row -- 791
				end -- 791
				local message = ____self_decodeConversationMessage_3(self, ____row_message_2) -- 791
				if message then -- 791
					messages[#messages + 1] = message -- 793
				end -- 793
			end -- 793
			::__continue109:: -- 793
			i = i + 1 -- 785
		end -- 785
	end -- 785
	return {messages = messages} -- 796
end -- 775
function DualLayerStorage.prototype.writeSessionState(self, messages) -- 799
	if messages == nil then -- 799
		messages = {} -- 799
	end -- 799
	self:ensureDir(Path:getPath(self.sessionPath)) -- 800
	local lines = {} -- 801
	do -- 801
		local i = 0 -- 802
		while i < #messages do -- 802
			local line = self:encodeJsonLine({_type = "message", message = messages[i + 1]}) -- 803
			if line then -- 803
				lines[#lines + 1] = line -- 808
			end -- 808
			i = i + 1 -- 802
		end -- 802
	end -- 802
	local content = table.concat(lines, "\n") .. "\n" -- 811
	Content:save(self.sessionPath, content) -- 812
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 813
end -- 799
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 825
local MemoryCompressor = ____exports.MemoryCompressor -- 825
MemoryCompressor.name = "MemoryCompressor" -- 825
function MemoryCompressor.prototype.____constructor(self, config) -- 832
	self.consecutiveFailures = 0 -- 828
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 833
	do -- 833
		local i = 0 -- 834
		while i < #loadedPromptPack.warnings do -- 834
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 835
			i = i + 1 -- 834
		end -- 834
	end -- 834
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 837
	self.config = __TS__ObjectAssign( -- 840
		{}, -- 840
		config, -- 841
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 840
	) -- 840
	self.config.compressionThreshold = math.min( -- 847
		1, -- 847
		math.max(0.05, self.config.compressionThreshold) -- 847
	) -- 847
	self.config.compressionTargetThreshold = math.min( -- 848
		self.config.compressionThreshold, -- 849
		math.max(0.05, self.config.compressionTargetThreshold) -- 850
	) -- 850
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir, self.config.scope or "") -- 852
end -- 832
function MemoryCompressor.prototype.getPromptPack(self) -- 855
	return self.config.promptPack -- 856
end -- 855
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 862
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 867
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 873
	return messageTokens > threshold -- 875
end -- 862
function MemoryCompressor.prototype.compress(self, messages, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode, systemPrompt, toolDefinitions) -- 881
	if decisionMode == nil then -- 881
		decisionMode = "tool_calling" -- 885
	end -- 885
	if boundaryMode == nil then -- 885
		boundaryMode = "default" -- 887
	end -- 887
	if systemPrompt == nil then -- 887
		systemPrompt = "" -- 888
	end -- 888
	if toolDefinitions == nil then -- 888
		toolDefinitions = "" -- 889
	end -- 889
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 889
		local toCompress = messages -- 891
		if #toCompress == 0 then -- 891
			return ____awaiter_resolve(nil, nil) -- 891
		end -- 891
		local currentMemory = self.storage:readMemory() -- 893
		local boundary = self:findCompressionBoundary( -- 895
			toCompress, -- 896
			currentMemory, -- 897
			boundaryMode, -- 898
			systemPrompt, -- 899
			toolDefinitions -- 900
		) -- 900
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 902
		if #chunk == 0 then -- 902
			return ____awaiter_resolve(nil, nil) -- 902
		end -- 902
		local historyText = self:formatMessagesForCompression(chunk) -- 905
		local ____try = __TS__AsyncAwaiter(function() -- 905
			local result = __TS__Await(self:callLLMForCompression( -- 909
				currentMemory, -- 910
				historyText, -- 911
				llmOptions, -- 912
				maxLLMTry or 3, -- 913
				decisionMode, -- 914
				debugContext -- 915
			)) -- 915
			if result.success then -- 915
				self.storage:writeMemory(result.memoryUpdate) -- 920
				if result.ts then -- 920
					self.storage:appendHistoryRecord({ts = result.ts, summary = result.summary}) -- 922
				end -- 922
				self.consecutiveFailures = 0 -- 927
				return ____awaiter_resolve( -- 927
					nil, -- 927
					__TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessage = boundary.carryMessage}) -- 929
				) -- 929
			end -- 929
			return ____awaiter_resolve( -- 929
				nil, -- 929
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 937
			) -- 937
		end) -- 937
		__TS__Await(____try.catch( -- 907
			____try, -- 907
			function(____, ____error) -- 907
				return ____awaiter_resolve( -- 907
					nil, -- 907
					self:handleCompressionFailure( -- 940
						chunk, -- 940
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 940
					) -- 940
				) -- 940
			end -- 940
		)) -- 940
	end) -- 940
end -- 881
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode, systemPrompt, toolDefinitions) -- 949
	local targetTokens = boundaryMode == "budget_max" and math.max( -- 956
		1, -- 957
		self:getCompressionHistoryTokenBudget(currentMemory) -- 957
	) or math.max( -- 957
		1, -- 958
		self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 958
	) -- 958
	local accumulatedTokens = 0 -- 959
	local lastSafeBoundary = 0 -- 960
	local lastSafeBoundaryWithinBudget = 0 -- 961
	local lastClosedBoundary = 0 -- 962
	local lastClosedBoundaryWithinBudget = 0 -- 963
	local pendingToolCalls = {} -- 964
	local pendingToolCallCount = 0 -- 965
	local exceededBudget = false -- 966
	do -- 966
		local i = 0 -- 968
		while i < #messages do -- 968
			local message = messages[i + 1] -- 969
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 970
			accumulatedTokens = accumulatedTokens + tokens -- 971
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 971
				do -- 971
					local j = 0 -- 974
					while j < #message.tool_calls do -- 974
						local toolCallEntry = message.tool_calls[j + 1] -- 975
						local idValue = toolCallEntry.id -- 976
						local id = type(idValue) == "string" and idValue or "" -- 977
						if id ~= "" and not pendingToolCalls[id] then -- 977
							pendingToolCalls[id] = true -- 979
							pendingToolCallCount = pendingToolCallCount + 1 -- 980
						end -- 980
						j = j + 1 -- 974
					end -- 974
				end -- 974
			end -- 974
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 974
				pendingToolCalls[message.tool_call_id] = false -- 986
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 987
			end -- 987
			local isAtEnd = i >= #messages - 1 -- 990
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 991
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 992
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 993
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 994
			if isSafeBoundary then -- 994
				lastSafeBoundary = i + 1 -- 996
				if accumulatedTokens <= targetTokens then -- 996
					lastSafeBoundaryWithinBudget = i + 1 -- 998
				end -- 998
			end -- 998
			if isClosedToolBoundary then -- 998
				lastClosedBoundary = i + 1 -- 1002
				if accumulatedTokens <= targetTokens then -- 1002
					lastClosedBoundaryWithinBudget = i + 1 -- 1004
				end -- 1004
			end -- 1004
			if accumulatedTokens > targetTokens and not exceededBudget then -- 1004
				exceededBudget = true -- 1009
			end -- 1009
			if exceededBudget and isSafeBoundary then -- 1009
				return self:buildCarryBoundary(messages, i + 1) -- 1014
			end -- 1014
			i = i + 1 -- 968
		end -- 968
	end -- 968
	if lastSafeBoundaryWithinBudget > 0 then -- 968
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 1019
	end -- 1019
	if lastSafeBoundary > 0 then -- 1019
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 1022
	end -- 1022
	if lastClosedBoundaryWithinBudget > 0 then -- 1022
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 1025
	end -- 1025
	if lastClosedBoundary > 0 then -- 1025
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 1028
	end -- 1028
	local fallback = math.min(#messages, 1) -- 1030
	return {chunkEnd = fallback, compressedCount = fallback} -- 1031
end -- 949
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 1034
	local carryUserIndex = -1 -- 1035
	do -- 1035
		local i = 0 -- 1036
		while i < chunkEnd do -- 1036
			if messages[i + 1].role == "user" then -- 1036
				carryUserIndex = i -- 1038
			end -- 1038
			i = i + 1 -- 1036
		end -- 1036
	end -- 1036
	if carryUserIndex < 0 then -- 1036
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 1042
	end -- 1042
	return { -- 1044
		chunkEnd = chunkEnd, -- 1045
		compressedCount = chunkEnd, -- 1046
		carryMessage = __TS__ObjectAssign({}, messages[carryUserIndex + 1]) -- 1047
	} -- 1047
end -- 1034
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 1053
	local lines = {} -- 1054
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 1055
	if message.name and message.name ~= "" then -- 1055
		lines[#lines + 1] = "name=" .. message.name -- 1056
	end -- 1056
	if message.tool_call_id and message.tool_call_id ~= "" then -- 1056
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1057
	end -- 1057
	if message.reasoning_content and message.reasoning_content ~= "" then -- 1057
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1058
	end -- 1058
	if message.tool_calls and #message.tool_calls > 0 then -- 1058
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 1060
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1061
	end -- 1061
	if message.content and message.content ~= "" then -- 1061
		lines[#lines + 1] = message.content -- 1063
	end -- 1063
	local prefix = index > 0 and "\n\n" or "" -- 1064
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 1065
end -- 1053
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages, systemPrompt, toolDefinitions) -- 1068
	local currentTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 1073
	local threshold = self:getContextWindow() * self.config.compressionTargetThreshold -- 1078
	local overflow = math.max(0, currentTokens - threshold) -- 1079
	if overflow <= 0 then -- 1079
		return math.max( -- 1081
			1, -- 1081
			self:estimateCompressionMessageTokens(messages[1], 0) -- 1081
		) -- 1081
	end -- 1081
	local safetyMargin = math.max( -- 1083
		64, -- 1083
		math.floor(threshold * 0.01) -- 1083
	) -- 1083
	return overflow + safetyMargin -- 1084
end -- 1068
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1087
	local lines = {} -- 1088
	do -- 1088
		local i = 0 -- 1089
		while i < #messages do -- 1089
			local message = messages[i + 1] -- 1090
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1091
			if message.name and message.name ~= "" then -- 1091
				lines[#lines + 1] = "name=" .. message.name -- 1092
			end -- 1092
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1092
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1093
			end -- 1093
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1093
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1094
			end -- 1094
			if message.tool_calls and #message.tool_calls > 0 then -- 1094
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1096
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1097
			end -- 1097
			if message.content and message.content ~= "" then -- 1097
				lines[#lines + 1] = message.content -- 1099
			end -- 1099
			if i < #messages - 1 then -- 1099
				lines[#lines + 1] = "" -- 1100
			end -- 1100
			i = i + 1 -- 1089
		end -- 1089
	end -- 1089
	return table.concat(lines, "\n") -- 1102
end -- 1087
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1108
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1108
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1116
		if decisionMode == "xml" then -- 1116
			return ____awaiter_resolve( -- 1116
				nil, -- 1116
				self:callLLMForCompressionByXML( -- 1118
					currentMemory, -- 1119
					boundedHistoryText, -- 1120
					llmOptions, -- 1121
					maxLLMTry, -- 1122
					debugContext -- 1123
				) -- 1123
			) -- 1123
		end -- 1123
		return ____awaiter_resolve( -- 1123
			nil, -- 1123
			self:callLLMForCompressionByToolCalling( -- 1126
				currentMemory, -- 1127
				boundedHistoryText, -- 1128
				llmOptions, -- 1129
				maxLLMTry, -- 1130
				debugContext -- 1131
			) -- 1131
		) -- 1131
	end) -- 1131
end -- 1108
function MemoryCompressor.prototype.getContextWindow(self) -- 1135
	return math.max(4000, self.config.llmConfig.contextWindow) -- 1136
end -- 1135
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1139
	local contextWindow = self:getContextWindow() -- 1140
	local reservedOutputTokens = math.max( -- 1141
		2048, -- 1141
		math.floor(contextWindow * 0.2) -- 1141
	) -- 1141
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1142
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1143
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1144
	return math.max( -- 1145
		1200, -- 1145
		math.floor(available * 0.9) -- 1145
	) -- 1145
end -- 1139
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1148
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1149
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1150
	if historyTokens <= tokenBudget then -- 1150
		return historyText -- 1151
	end -- 1151
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1152
	local targetChars = math.max( -- 1155
		2000, -- 1155
		math.floor(tokenBudget * charsPerToken) -- 1155
	) -- 1155
	local keepHead = math.max( -- 1156
		0, -- 1156
		math.floor(targetChars * 0.35) -- 1156
	) -- 1156
	local keepTail = math.max(0, targetChars - keepHead) -- 1157
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1158
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1159
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1160
end -- 1148
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1163
	local contextWindow = self:getContextWindow() -- 1167
	local reservedOutputTokens = math.max( -- 1168
		2048, -- 1168
		math.floor(contextWindow * 0.2) -- 1168
	) -- 1168
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1169
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1170
	local boundedMemory = clipTextToTokenBudget( -- 1171
		currentMemory or "(empty)", -- 1171
		math.max( -- 1171
			320, -- 1171
			math.floor(dynamicBudget * 0.35) -- 1171
		) -- 1171
	) -- 1171
	local boundedHistory = clipTextToTokenBudget( -- 1172
		historyText, -- 1172
		math.max( -- 1172
			800, -- 1172
			math.floor(dynamicBudget * 0.65) -- 1172
		) -- 1172
	) -- 1172
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 1173
end -- 1163
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1179
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1179
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1186
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 1189
		local messages = { -- 1213
			{ -- 1214
				role = "system", -- 1215
				content = self:buildToolCallingCompressionSystemPrompt() -- 1216
			}, -- 1216
			{role = "user", content = prompt} -- 1218
		} -- 1218
		local fn -- 1224
		local argsText = "" -- 1225
		do -- 1225
			local i = 0 -- 1226
			while i < maxLLMTry do -- 1226
				local ____opt_4 = debugContext and debugContext.onInput -- 1226
				if ____opt_4 ~= nil then -- 1226
					____opt_4( -- 1227
						debugContext, -- 1227
						"memory_compression_tool_calling", -- 1227
						messages, -- 1227
						__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 1227
					) -- 1227
				end -- 1227
				local response = __TS__Await(callLLM( -- 1233
					messages, -- 1234
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1235
					nil, -- 1240
					self.config.llmConfig -- 1241
				)) -- 1241
				if not response.success then -- 1241
					local ____opt_8 = debugContext and debugContext.onOutput -- 1241
					if ____opt_8 ~= nil then -- 1241
						____opt_8(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false}) -- 1245
					end -- 1245
					return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1245
				end -- 1245
				local ____opt_12 = debugContext and debugContext.onOutput -- 1245
				if ____opt_12 ~= nil then -- 1245
					____opt_12( -- 1253
						debugContext, -- 1253
						"memory_compression_tool_calling", -- 1253
						encodeCompressionDebugJSON(response.response), -- 1253
						{success = true} -- 1253
					) -- 1253
				end -- 1253
				local choice = response.response.choices and response.response.choices[1] -- 1255
				local message = choice and choice.message -- 1256
				local toolCalls = message and message.tool_calls -- 1257
				local toolCall = toolCalls and toolCalls[1] -- 1258
				fn = toolCall and toolCall["function"] -- 1259
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1260
				if fn ~= nil and #argsText > 0 then -- 1260
					break -- 1261
				end -- 1261
				i = i + 1 -- 1226
			end -- 1226
		end -- 1226
		if not fn or fn.name ~= "save_memory" then -- 1226
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing save_memory tool call"}) -- 1226
		end -- 1226
		if __TS__StringTrim(argsText) == "" then -- 1226
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "empty save_memory tool arguments"}) -- 1226
		end -- 1226
		local ____try = __TS__AsyncAwaiter(function() -- 1226
			local args, err = safeJsonDecode(argsText) -- 1284
			if err ~= nil or not args or type(args) ~= "table" then -- 1284
				return ____awaiter_resolve( -- 1284
					nil, -- 1284
					{ -- 1286
						success = false, -- 1287
						memoryUpdate = currentMemory, -- 1288
						compressedCount = 0, -- 1289
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1290
					} -- 1290
				) -- 1290
			end -- 1290
			return ____awaiter_resolve( -- 1290
				nil, -- 1290
				self:buildCompressionResultFromObject(args, currentMemory) -- 1294
			) -- 1294
		end) -- 1294
		__TS__Await(____try.catch( -- 1283
			____try, -- 1283
			function(____, ____error) -- 1283
				return ____awaiter_resolve( -- 1283
					nil, -- 1283
					{ -- 1299
						success = false, -- 1300
						memoryUpdate = currentMemory, -- 1301
						compressedCount = 0, -- 1302
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1303
					} -- 1303
				) -- 1303
			end -- 1303
		)) -- 1303
	end) -- 1303
end -- 1179
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1308
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1308
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1315
		local lastError = "invalid xml response" -- 1316
		do -- 1316
			local i = 0 -- 1318
			while i < maxLLMTry do -- 1318
				do -- 1318
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1319
					local requestMessages = { -- 1324
						{ -- 1325
							role = "system", -- 1325
							content = self:buildXMLCompressionSystemPrompt() -- 1325
						}, -- 1325
						{role = "user", content = prompt .. feedback} -- 1326
					} -- 1326
					local ____opt_16 = debugContext and debugContext.onInput -- 1326
					if ____opt_16 ~= nil then -- 1326
						____opt_16(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1328
					end -- 1328
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1329
					if not response.success then -- 1329
						local ____opt_20 = debugContext and debugContext.onOutput -- 1329
						if ____opt_20 ~= nil then -- 1329
							____opt_20(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1337
						end -- 1337
						return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1337
					end -- 1337
					local choice = response.response.choices and response.response.choices[1] -- 1346
					local message = choice and choice.message -- 1347
					local text = message and type(message.content) == "string" and message.content or "" -- 1348
					local ____opt_24 = debugContext and debugContext.onOutput -- 1348
					if ____opt_24 ~= nil then -- 1348
						____opt_24( -- 1349
							debugContext, -- 1349
							"memory_compression_xml", -- 1349
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1349
							{success = true} -- 1349
						) -- 1349
					end -- 1349
					if __TS__StringTrim(text) == "" then -- 1349
						lastError = "empty xml response" -- 1351
						goto __continue188 -- 1352
					end -- 1352
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1355
					if parsed.success then -- 1355
						return ____awaiter_resolve(nil, parsed) -- 1355
					end -- 1355
					lastError = parsed.error or "invalid xml response" -- 1359
				end -- 1359
				::__continue188:: -- 1359
				i = i + 1 -- 1318
			end -- 1318
		end -- 1318
		return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = lastError}) -- 1318
	end) -- 1318
end -- 1308
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1373
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1374
end -- 1373
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1380
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1381
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1382
end -- 1380
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 1388
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 1389
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 1392
end -- 1388
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 1399
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1400
end -- 1399
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 1405
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1406
end -- 1405
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1411
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1412
	if not parsed.success then -- 1412
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = parsed.message} -- 1414
	end -- 1414
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 1421
end -- 1411
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1427
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1431
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1432
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1432
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing history_entry or memory_update"} -- 1434
	end -- 1434
	local ts = os.date("%Y-%m-%d %H:%M") -- 1441
	return { -- 1442
		success = true, -- 1443
		memoryUpdate = memoryBody, -- 1444
		ts = ts, -- 1445
		summary = historyEntry, -- 1446
		compressedCount = 0 -- 1447
	} -- 1447
end -- 1427
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1454
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1458
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1458
		local archived = self:rawArchive(chunk) -- 1461
		self.consecutiveFailures = 0 -- 1462
		return { -- 1464
			success = true, -- 1465
			memoryUpdate = self.storage:readMemory(), -- 1466
			ts = archived.ts, -- 1467
			compressedCount = #chunk -- 1468
		} -- 1468
	end -- 1468
	return { -- 1472
		success = false, -- 1473
		memoryUpdate = self.storage:readMemory(), -- 1474
		compressedCount = 0, -- 1475
		error = ____error -- 1476
	} -- 1476
end -- 1454
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1483
	local ts = os.date("%Y-%m-%d %H:%M") -- 1484
	local rawArchive = self:formatMessagesForCompression(chunk) -- 1485
	self.storage:appendHistoryRecord({ts = ts, rawArchive = rawArchive}) -- 1486
	return {ts = ts} -- 1490
end -- 1483
function MemoryCompressor.prototype.getStorage(self) -- 1496
	return self.storage -- 1497
end -- 1496
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1500
	return math.max( -- 1501
		1, -- 1501
		math.floor(self.config.maxCompressionRounds) -- 1501
	) -- 1501
end -- 1500
MemoryCompressor.MAX_FAILURES = 3 -- 1500
function ____exports.compactSessionMemoryScope(options) -- 1505
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1505
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 1514
		if not llmConfigRes.success then -- 1514
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 1514
		end -- 1514
		local compressor = __TS__New(____exports.MemoryCompressor, { -- 1520
			compressionThreshold = 0.8, -- 1521
			compressionTargetThreshold = 0.5, -- 1522
			maxCompressionRounds = 3, -- 1523
			projectDir = options.projectDir, -- 1524
			llmConfig = llmConfigRes.config, -- 1525
			promptPack = options.promptPack, -- 1526
			scope = options.scope -- 1527
		}) -- 1527
		local storage = compressor:getStorage() -- 1529
		local messages = storage:readSessionState().messages -- 1530
		local llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})) -- 1531
		while #messages > 0 do -- 1531
			local result = __TS__Await(compressor:compress( -- 1537
				messages, -- 1538
				llmOptions, -- 1539
				math.max( -- 1540
					1, -- 1540
					math.floor(options.llmMaxTry or 5) -- 1540
				), -- 1540
				options.decisionMode or "tool_calling", -- 1541
				nil, -- 1542
				"budget_max" -- 1543
			)) -- 1543
			if not (result and result.success and result.compressedCount > 0) then -- 1543
				return ____awaiter_resolve(nil, {success = false, message = result and result.error or "memory compaction produced no progress"}) -- 1543
			end -- 1543
			local remainingMessages = __TS__ArraySlice(messages, result.compressedCount) -- 1551
			if result.carryMessage then -- 1551
				__TS__ArrayUnshift( -- 1553
					remainingMessages, -- 1553
					__TS__ObjectAssign( -- 1553
						{}, -- 1553
						result.carryMessage, -- 1554
						{timestamp = result.carryMessage.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 1553
					) -- 1553
				) -- 1553
			end -- 1553
			messages = remainingMessages -- 1558
			storage:writeSessionState(messages) -- 1559
		end -- 1559
		return ____awaiter_resolve(nil, {success = true, remainingMessages = #messages}) -- 1559
	end) -- 1559
end -- 1505
return ____exports -- 1505