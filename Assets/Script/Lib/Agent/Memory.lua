-- [ts]: Memory.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
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
local ____Tools = require("Agent.Tools") -- 5
local sendWebIDEFileUpdate = ____Tools.sendWebIDEFileUpdate -- 5
local AGENT_CONFIG_DIR = ".agent" -- 16
local AGENT_PROMPTS_FILE = "AGENT.md" -- 17
local XML_DECISION_SCHEMA_EXAMPLE = "```xml\n<tool_call>\n\t<tool>edit_file</tool>\n\t<reason>Need to update the file content to implement the requested change.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<old_str><![CDATA[\nfunction oldName() {\n\tprint(\"old\");\n}\n]]></old_str>\n\t\t<new_str><![CDATA[\nfunction newName() {\n\tprint(\"hello\");\n}\n]]></new_str>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>read_file</tool>\n\t<reason>Need to inspect the current implementation before editing.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<startLine>1</startLine>\n\t\t<endLine>200</endLine>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>finish</tool>\n\t<params>\n\t\t<message>Final user-facing answer.</message>\n\t</params>\n</tool_call>\n```" -- 18
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 74
	agentIdentityPrompt = "### Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 75
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Line starts with 1. startLine defaults to 1 and endLine defaults to 300.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 88
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 134
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 135
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 136
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 137
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 150
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.", -- 181
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n### Actions to Process\n\n{{HISTORY_TEXT}}\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph for HISTORY.md\n\t- Include timestamp and key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 183
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 217
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update><![CDATA[\nFull updated MEMORY.md content\n]]></memory_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Use exactly two child tags: `<history_entry>` and `<memory_update>`.\n- Use CDATA for `<memory_update>` when it spans multiple lines or contains markdown/code.", -- 222
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 239
} -- 239
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn"} -- 242
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 242
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 242
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 248
local function replaceTemplateVars(template, vars) -- 253
	local output = template -- 254
	for key in pairs(vars) do -- 255
		output = table.concat( -- 256
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 256
			vars[key] or "" or "," -- 256
		) -- 256
	end -- 256
	return output -- 258
end -- 253
function ____exports.resolveAgentPromptPack(value) -- 261
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 262
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 262
		do -- 262
			local i = 0 -- 266
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 266
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 267
				if type(value[key]) == "string" then -- 267
					merged[key] = value[key] -- 269
				end -- 269
				i = i + 1 -- 266
			end -- 266
		end -- 266
	end -- 266
	return merged -- 273
end -- 261
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 276
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 277
	local lines = {} -- 278
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 279
	lines[#lines + 1] = "" -- 280
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 281
	lines[#lines + 1] = "" -- 282
	do -- 282
		local i = 0 -- 283
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 283
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 284
			lines[#lines + 1] = "## " .. key -- 285
			local text = pack[key] -- 286
			local split = __TS__StringSplit(text, "\n") -- 287
			do -- 287
				local j = 0 -- 288
				while j < #split do -- 288
					lines[#lines + 1] = split[j + 1] -- 289
					j = j + 1 -- 288
				end -- 288
			end -- 288
			lines[#lines + 1] = "" -- 291
			i = i + 1 -- 283
		end -- 283
	end -- 283
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 293
end -- 276
local function getPromptPackConfigPath(projectRoot) -- 296
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 297
end -- 296
local function ensurePromptPackConfig(projectRoot) -- 300
	local path = getPromptPackConfigPath(projectRoot) -- 301
	if Content:exist(path) then -- 301
		return nil -- 302
	end -- 302
	local dir = Path:getPath(path) -- 303
	if not Content:exist(dir) then -- 303
		Content:mkdir(dir) -- 305
	end -- 305
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 307
	if not Content:save(path, content) then -- 307
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 309
	end -- 309
	sendWebIDEFileUpdate(path, true, content) -- 311
	return nil -- 312
end -- 300
local function parsePromptPackMarkdown(text) -- 315
	if not text or __TS__StringTrim(text) == "" then -- 315
		return { -- 322
			value = {}, -- 323
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 324
			unknown = {} -- 325
		} -- 325
	end -- 325
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 328
	local lines = __TS__StringSplit(normalized, "\n") -- 329
	local sections = {} -- 330
	local unknown = {} -- 331
	local currentHeading = "" -- 332
	local function isKnownPromptPackKey(name) -- 333
		do -- 333
			local i = 0 -- 334
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 334
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 334
					return true -- 335
				end -- 335
				i = i + 1 -- 334
			end -- 334
		end -- 334
		return false -- 337
	end -- 333
	do -- 333
		local i = 0 -- 339
		while i < #lines do -- 339
			do -- 339
				local line = lines[i + 1] -- 340
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 341
				if matchedHeading ~= nil then -- 341
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 343
					if isKnownPromptPackKey(heading) then -- 343
						currentHeading = heading -- 345
						if sections[currentHeading] == nil then -- 345
							sections[currentHeading] = {} -- 347
						end -- 347
						goto __continue27 -- 349
					end -- 349
					if currentHeading == "" then -- 349
						unknown[#unknown + 1] = heading -- 352
						goto __continue27 -- 353
					end -- 353
				end -- 353
				if currentHeading ~= "" then -- 353
					local ____sections_currentHeading_1 = sections[currentHeading] -- 353
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 357
				end -- 357
			end -- 357
			::__continue27:: -- 357
			i = i + 1 -- 339
		end -- 339
	end -- 339
	local value = {} -- 360
	local missing = {} -- 361
	do -- 361
		local i = 0 -- 362
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 362
			do -- 362
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 363
				local section = sections[key] -- 364
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 365
				if body == "" then -- 365
					missing[#missing + 1] = key -- 367
					goto __continue34 -- 368
				end -- 368
				value[key] = body -- 370
			end -- 370
			::__continue34:: -- 370
			i = i + 1 -- 362
		end -- 362
	end -- 362
	if #__TS__ObjectKeys(sections) == 0 then -- 362
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 373
	end -- 373
	return {value = value, missing = missing, unknown = unknown} -- 379
end -- 315
function ____exports.loadAgentPromptPack(projectRoot) -- 382
	local path = getPromptPackConfigPath(projectRoot) -- 383
	local warnings = {} -- 384
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 385
	if ensureWarning and ensureWarning ~= "" then -- 385
		warnings[#warnings + 1] = ensureWarning -- 387
	end -- 387
	if not Content:exist(path) then -- 387
		return { -- 390
			pack = ____exports.resolveAgentPromptPack(), -- 391
			warnings = warnings, -- 392
			path = path -- 393
		} -- 393
	end -- 393
	local text = Content:load(path) -- 396
	if not text or __TS__StringTrim(text) == "" then -- 396
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 398
		return { -- 399
			pack = ____exports.resolveAgentPromptPack(), -- 400
			warnings = warnings, -- 401
			path = path -- 402
		} -- 402
	end -- 402
	local parsed = parsePromptPackMarkdown(text) -- 405
	if parsed.error or not parsed.value then -- 405
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 407
		return { -- 408
			pack = ____exports.resolveAgentPromptPack(), -- 409
			warnings = warnings, -- 410
			path = path -- 411
		} -- 411
	end -- 411
	if #parsed.unknown > 0 then -- 411
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 415
	end -- 415
	if #parsed.missing > 0 then -- 415
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 418
	end -- 418
	return { -- 420
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 421
		warnings = warnings, -- 422
		path = path -- 423
	} -- 423
end -- 382
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 478
local TokenEstimator = ____exports.TokenEstimator -- 478
TokenEstimator.name = "TokenEstimator" -- 478
function TokenEstimator.prototype.____constructor(self) -- 478
end -- 478
function TokenEstimator.estimate(self, text) -- 488
	if not text then -- 488
		return 0 -- 489
	end -- 489
	local chineseChars = utf8.len(text) -- 492
	if not chineseChars then -- 492
		return 0 -- 493
	end -- 493
	local otherChars = #text - chineseChars -- 495
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 497
	return math.max(1, tokens) -- 502
end -- 488
function TokenEstimator.estimateMessages(self, messages) -- 505
	if not messages or #messages == 0 then -- 505
		return 0 -- 506
	end -- 506
	local total = 0 -- 507
	do -- 507
		local i = 0 -- 508
		while i < #messages do -- 508
			local message = messages[i + 1] -- 509
			total = total + self:estimate(message.role or "") -- 510
			total = total + self:estimate(message.content or "") -- 511
			total = total + self:estimate(message.name or "") -- 512
			total = total + self:estimate(message.tool_call_id or "") -- 513
			total = total + self:estimate(message.reasoning_content or "") -- 514
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 515
			total = total + self:estimate(toolCallsText or "") -- 516
			total = total + 8 -- 517
			i = i + 1 -- 508
		end -- 508
	end -- 508
	return total -- 519
end -- 505
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 522
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 527
end -- 522
TokenEstimator.CHARS_PER_TOKEN = 4 -- 522
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 522
local function utf8TakeHead(text, maxChars) -- 535
	if maxChars <= 0 or text == "" then -- 535
		return "" -- 536
	end -- 536
	local nextPos = utf8.offset(text, maxChars + 1) -- 537
	if nextPos == nil then -- 537
		return text -- 538
	end -- 538
	return string.sub(text, 1, nextPos - 1) -- 539
end -- 535
local function utf8TakeTail(text, maxChars) -- 542
	if maxChars <= 0 or text == "" then -- 542
		return "" -- 543
	end -- 543
	local charLen = utf8.len(text) -- 544
	if charLen == nil or charLen <= maxChars then -- 544
		return text -- 545
	end -- 545
	local startChar = math.max(1, charLen - maxChars + 1) -- 546
	local startPos = utf8.offset(text, startChar) -- 547
	if startPos == nil then -- 547
		return text -- 548
	end -- 548
	return string.sub(text, startPos) -- 549
end -- 542
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 557
local DualLayerStorage = ____exports.DualLayerStorage -- 557
DualLayerStorage.name = "DualLayerStorage" -- 557
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 564
	self.projectDir = projectDir -- 565
	self.agentDir = Path(self.projectDir, ".agent") -- 566
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 567
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 568
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 569
	self:ensureAgentFiles() -- 570
end -- 564
function DualLayerStorage.prototype.ensureDir(self, dir) -- 573
	if not Content:exist(dir) then -- 573
		Content:mkdir(dir) -- 575
	end -- 575
end -- 573
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 579
	if Content:exist(path) then -- 579
		return false -- 580
	end -- 580
	self:ensureDir(Path:getPath(path)) -- 581
	if not Content:save(path, content) then -- 581
		return false -- 583
	end -- 583
	sendWebIDEFileUpdate(path, true, content) -- 585
	return true -- 586
end -- 579
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 589
	self:ensureDir(self.agentDir) -- 590
	self:ensureFile(self.memoryPath, "") -- 591
	self:ensureFile(self.historyPath, "") -- 592
end -- 589
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 595
	local text = safeJsonEncode(value) -- 596
	return text -- 597
end -- 595
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 600
	local value = table.unpack( -- 601
		safeJsonDecode(text), -- 601
		1, -- 601
		1 -- 601
	) -- 601
	return value -- 602
end -- 600
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 605
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 605
		return nil -- 606
	end -- 606
	local row = value -- 607
	local role = type(row.role) == "string" and row.role or "" -- 608
	if role == "" then -- 608
		return nil -- 609
	end -- 609
	local message = {role = role} -- 610
	if type(row.content) == "string" then -- 610
		message.content = sanitizeUTF8(row.content) -- 611
	end -- 611
	if type(row.name) == "string" then -- 611
		message.name = sanitizeUTF8(row.name) -- 612
	end -- 612
	if type(row.tool_call_id) == "string" then -- 612
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 613
	end -- 613
	if type(row.reasoning_content) == "string" then -- 613
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 614
	end -- 614
	if type(row.timestamp) == "string" then -- 614
		message.timestamp = sanitizeUTF8(row.timestamp) -- 615
	end -- 615
	if type(row.tool_calls) == "table" then -- 615
		message.tool_calls = row.tool_calls -- 617
	end -- 617
	return message -- 619
end -- 605
function DualLayerStorage.prototype.readMemory(self) -- 627
	if not Content:exist(self.memoryPath) then -- 627
		return "" -- 629
	end -- 629
	return Content:load(self.memoryPath) -- 631
end -- 627
function DualLayerStorage.prototype.writeMemory(self, content) -- 637
	self:ensureDir(Path:getPath(self.memoryPath)) -- 638
	Content:save(self.memoryPath, content) -- 639
end -- 637
function DualLayerStorage.prototype.getMemoryContext(self) -- 645
	local memory = self:readMemory() -- 646
	if not memory then -- 646
		return "" -- 647
	end -- 647
	return "### Long-term Memory\n\n" .. memory -- 649
end -- 645
function DualLayerStorage.prototype.appendHistory(self, entry) -- 659
	self:ensureDir(Path:getPath(self.historyPath)) -- 660
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 662
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 666
end -- 659
function DualLayerStorage.prototype.readHistory(self) -- 672
	if not Content:exist(self.historyPath) then -- 672
		return "" -- 674
	end -- 674
	return Content:load(self.historyPath) -- 676
end -- 672
function DualLayerStorage.prototype.readSessionState(self) -- 679
	if not Content:exist(self.sessionPath) then -- 679
		return {messages = {}, lastConsolidatedMessageIndex = 0} -- 681
	end -- 681
	local text = Content:load(self.sessionPath) -- 683
	if not text or __TS__StringTrim(text) == "" then -- 683
		return {messages = {}, lastConsolidatedMessageIndex = 0} -- 685
	end -- 685
	local lines = __TS__StringSplit(text, "\n") -- 687
	local messages = {} -- 688
	local lastConsolidatedMessageIndex = 0 -- 689
	do -- 689
		local i = 0 -- 690
		while i < #lines do -- 690
			do -- 690
				local line = __TS__StringTrim(lines[i + 1]) -- 691
				if line == "" then -- 691
					goto __continue90 -- 692
				end -- 692
				local data = self:decodeJsonLine(line) -- 693
				if not data or __TS__ArrayIsArray(data) or type(data) ~= "table" then -- 693
					goto __continue90 -- 694
				end -- 694
				local row = data -- 695
				if row._type == "metadata" then -- 695
					local ____math_max_4 = math.max -- 697
					local ____math_floor_3 = math.floor -- 697
					local ____row_lastConsolidatedMessageIndex_2 = row.lastConsolidatedMessageIndex -- 697
					if ____row_lastConsolidatedMessageIndex_2 == nil then -- 697
						____row_lastConsolidatedMessageIndex_2 = 0 -- 697
					end -- 697
					lastConsolidatedMessageIndex = ____math_max_4( -- 697
						0, -- 697
						____math_floor_3(__TS__Number(____row_lastConsolidatedMessageIndex_2)) -- 697
					) -- 697
					goto __continue90 -- 698
				end -- 698
				local ____self_decodeConversationMessage_6 = self.decodeConversationMessage -- 700
				local ____row_message_5 = row.message -- 700
				if ____row_message_5 == nil then -- 700
					____row_message_5 = row -- 700
				end -- 700
				local message = ____self_decodeConversationMessage_6(self, ____row_message_5) -- 700
				if message then -- 700
					messages[#messages + 1] = message -- 702
				end -- 702
			end -- 702
			::__continue90:: -- 702
			i = i + 1 -- 690
		end -- 690
	end -- 690
	return { -- 705
		messages = messages, -- 706
		lastConsolidatedMessageIndex = math.min(lastConsolidatedMessageIndex, #messages) -- 707
	} -- 707
end -- 679
function DualLayerStorage.prototype.writeSessionState(self, messages, lastConsolidatedMessageIndex) -- 711
	if messages == nil then -- 711
		messages = {} -- 712
	end -- 712
	if lastConsolidatedMessageIndex == nil then -- 712
		lastConsolidatedMessageIndex = 0 -- 713
	end -- 713
	self:ensureDir(Path:getPath(self.sessionPath)) -- 715
	local lines = {} -- 716
	local meta = self:encodeJsonLine({ -- 717
		_type = "metadata", -- 718
		lastConsolidatedMessageIndex = math.min( -- 719
			math.max( -- 719
				0, -- 719
				math.floor(lastConsolidatedMessageIndex) -- 719
			), -- 719
			#messages -- 719
		) -- 719
	}) -- 719
	if meta then -- 719
		lines[#lines + 1] = meta -- 722
	end -- 722
	do -- 722
		local i = 0 -- 724
		while i < #messages do -- 724
			local line = self:encodeJsonLine({_type = "message", message = messages[i + 1]}) -- 725
			if line then -- 725
				lines[#lines + 1] = line -- 730
			end -- 730
			i = i + 1 -- 724
		end -- 724
	end -- 724
	local content = table.concat(lines, "\n") .. "\n" -- 733
	Content:save(self.sessionPath, content) -- 734
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 735
end -- 711
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 741
	local history = self:readHistory() -- 742
	if not history then -- 742
		return {} -- 743
	end -- 743
	local lines = __TS__StringSplit(history, "\n") -- 745
	local lowerKeyword = string.lower(keyword) -- 746
	return __TS__ArrayFilter( -- 748
		lines, -- 748
		function(____, line) return __TS__StringIncludes( -- 748
			string.lower(line), -- 749
			lowerKeyword -- 749
		) end -- 749
	) -- 749
end -- 741
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 762
local MemoryCompressor = ____exports.MemoryCompressor -- 762
MemoryCompressor.name = "MemoryCompressor" -- 762
function MemoryCompressor.prototype.____constructor(self, config) -- 769
	self.consecutiveFailures = 0 -- 765
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 770
	do -- 770
		local i = 0 -- 771
		while i < #loadedPromptPack.warnings do -- 771
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 772
			i = i + 1 -- 771
		end -- 771
	end -- 771
	local overridePack = config.promptPack and not __TS__ArrayIsArray(config.promptPack) and type(config.promptPack) == "table" and config.promptPack or nil -- 774
	self.config = __TS__ObjectAssign( -- 777
		{}, -- 777
		config, -- 778
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 777
	) -- 777
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 784
end -- 769
function MemoryCompressor.prototype.getPromptPack(self) -- 787
	return self.config.promptPack -- 788
end -- 787
function MemoryCompressor.prototype.shouldCompress(self, messages, lastConsolidatedMessageIndex, systemPrompt, toolDefinitions) -- 794
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages( -- 800
		__TS__ArraySlice(messages, lastConsolidatedMessageIndex), -- 801
		systemPrompt, -- 802
		toolDefinitions -- 803
	) -- 803
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 806
	return messageTokens > threshold -- 808
end -- 794
function MemoryCompressor.prototype.compress(self, messages, lastConsolidatedMessageIndex, systemPrompt, toolDefinitions, llmOptions, maxLLMTry, decisionMode) -- 814
	if decisionMode == nil then -- 814
		decisionMode = "tool_calling" -- 821
	end -- 821
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 821
		local toCompress = __TS__ArraySlice(messages, lastConsolidatedMessageIndex) -- 823
		if #toCompress == 0 then -- 823
			return ____awaiter_resolve(nil, nil) -- 823
		end -- 823
		local boundary = self:findCompressionBoundary(toCompress, systemPrompt, toolDefinitions) -- 826
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 831
		if #chunk == 0 then -- 831
			return ____awaiter_resolve(nil, nil) -- 831
		end -- 831
		local currentMemory = self.storage:readMemory() -- 835
		local historyText = self:formatMessagesForCompression(chunk) -- 836
		local ____try = __TS__AsyncAwaiter(function() -- 836
			local result = __TS__Await(self:callLLMForCompression( -- 840
				currentMemory, -- 841
				historyText, -- 842
				llmOptions, -- 843
				maxLLMTry or 3, -- 844
				decisionMode -- 845
			)) -- 845
			if result.success then -- 845
				self.storage:writeMemory(result.memoryUpdate) -- 850
				self.storage:appendHistory(result.historyEntry) -- 851
				self.consecutiveFailures = 0 -- 852
				return ____awaiter_resolve( -- 852
					nil, -- 852
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 854
				) -- 854
			end -- 854
			return ____awaiter_resolve( -- 854
				nil, -- 854
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 861
			) -- 861
		end) -- 861
		__TS__Await(____try.catch( -- 838
			____try, -- 838
			function(____, ____error) -- 838
				return ____awaiter_resolve( -- 838
					nil, -- 838
					self:handleCompressionFailure( -- 864
						chunk, -- 864
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 864
					) -- 864
				) -- 864
			end -- 864
		)) -- 864
	end) -- 864
end -- 814
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, systemPrompt, toolDefinitions) -- 873
	local requiredTokens = self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 878
	local targetTokens = math.min( -- 879
		self.config.maxTokensPerCompression, -- 880
		math.max(1, requiredTokens) -- 881
	) -- 881
	local accumulatedTokens = 0 -- 883
	local lastSafeBoundary = 0 -- 884
	local pendingToolCalls = {} -- 885
	local pendingToolCallCount = 0 -- 886
	do -- 886
		local i = 0 -- 888
		while i < #messages do -- 888
			local message = messages[i + 1] -- 889
			local tokens = ____exports.TokenEstimator:estimatePromptMessages({message}, "", "") -- 890
			accumulatedTokens = accumulatedTokens + tokens -- 891
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 891
				do -- 891
					local j = 0 -- 894
					while j < #message.tool_calls do -- 894
						local toolCallEntry = message.tool_calls[j + 1] -- 895
						local ____temp_7 -- 896
						if toolCallEntry and not __TS__ArrayIsArray(toolCallEntry) and type(toolCallEntry) == "table" then -- 896
							____temp_7 = toolCallEntry.id -- 901
						else -- 901
							____temp_7 = nil -- 902
						end -- 902
						local idValue = ____temp_7 -- 896
						local id = type(idValue) == "string" and idValue or "" -- 903
						if id ~= "" and pendingToolCalls[id] ~= true then -- 903
							pendingToolCalls[id] = true -- 905
							pendingToolCallCount = pendingToolCallCount + 1 -- 906
						end -- 906
						j = j + 1 -- 894
					end -- 894
				end -- 894
			end -- 894
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] == true then -- 894
				pendingToolCalls[message.tool_call_id] = false -- 912
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 913
			end -- 913
			local isAtEnd = i >= #messages - 1 -- 916
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 917
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 918
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 919
			if isSafeBoundary then -- 919
				lastSafeBoundary = i + 1 -- 921
			end -- 921
			if accumulatedTokens >= targetTokens and isSafeBoundary then -- 921
				return i + 1 -- 925
			end -- 925
			i = i + 1 -- 888
		end -- 888
	end -- 888
	if lastSafeBoundary > 0 then -- 888
		return lastSafeBoundary -- 929
	end -- 929
	return math.min(#messages, 1) -- 930
end -- 873
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages, systemPrompt, toolDefinitions) -- 933
	local currentTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 938
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 943
	local overflow = math.max(0, currentTokens - threshold) -- 944
	if overflow <= 0 then -- 944
		return math.min( -- 946
			self.config.maxTokensPerCompression, -- 947
			math.max( -- 948
				1, -- 948
				____exports.TokenEstimator:estimatePromptMessages( -- 948
					__TS__ArraySlice(messages, 0, 1), -- 948
					"", -- 948
					"" -- 948
				) -- 948
			) -- 948
		) -- 948
	end -- 948
	local safetyMargin = math.max( -- 951
		64, -- 951
		math.floor(threshold * 0.01) -- 951
	) -- 951
	return math.min(self.config.maxTokensPerCompression, overflow + safetyMargin) -- 952
end -- 933
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 955
	local lines = {} -- 956
	do -- 956
		local i = 0 -- 957
		while i < #messages do -- 957
			local message = messages[i + 1] -- 958
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 959
			if message.name and message.name ~= "" then -- 959
				lines[#lines + 1] = "name=" .. message.name -- 960
			end -- 960
			if message.tool_call_id and message.tool_call_id ~= "" then -- 960
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 961
			end -- 961
			if message.reasoning_content and message.reasoning_content ~= "" then -- 961
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 962
			end -- 962
			if message.tool_calls and #message.tool_calls > 0 then -- 962
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 964
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 965
			end -- 965
			if message.content and message.content ~= "" then -- 965
				lines[#lines + 1] = message.content -- 967
			end -- 967
			if i < #messages - 1 then -- 967
				lines[#lines + 1] = "" -- 968
			end -- 968
			i = i + 1 -- 957
		end -- 957
	end -- 957
	return table.concat(lines, "\n") -- 970
end -- 955
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 976
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 976
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 983
		if decisionMode == "xml" then -- 983
			return ____awaiter_resolve( -- 983
				nil, -- 983
				self:callLLMForCompressionByXML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 985
			) -- 985
		end -- 985
		return ____awaiter_resolve( -- 985
			nil, -- 985
			self:callLLMForCompressionByToolCalling(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 992
		) -- 992
	end) -- 992
end -- 976
function MemoryCompressor.prototype.getContextWindow(self) -- 1000
	return math.max(4000, self.config.llmConfig.contextWindow) -- 1001
end -- 1000
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1004
	local contextWindow = self:getContextWindow() -- 1005
	local reservedOutputTokens = math.max( -- 1006
		2048, -- 1006
		math.floor(contextWindow * 0.2) -- 1006
	) -- 1006
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBodyRaw("", "")) -- 1007
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1008
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1009
	return math.max( -- 1010
		1200, -- 1010
		math.floor(available * 0.9) -- 1010
	) -- 1010
end -- 1004
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1013
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1014
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1015
	if historyTokens <= tokenBudget then -- 1015
		return historyText -- 1016
	end -- 1016
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1017
	local targetChars = math.max( -- 1020
		2000, -- 1020
		math.floor(tokenBudget * charsPerToken) -- 1020
	) -- 1020
	local keepHead = math.max( -- 1021
		0, -- 1021
		math.floor(targetChars * 0.35) -- 1021
	) -- 1021
	local keepTail = math.max(0, targetChars - keepHead) -- 1022
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1023
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1024
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1025
end -- 1013
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1028
	local contextWindow = self:getContextWindow() -- 1032
	local reservedOutputTokens = math.max( -- 1033
		2048, -- 1033
		math.floor(contextWindow * 0.2) -- 1033
	) -- 1033
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBodyRaw("", "")) -- 1034
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1035
	local boundedMemory = clipTextToTokenBudget( -- 1036
		currentMemory or "(empty)", -- 1036
		math.max( -- 1036
			320, -- 1036
			math.floor(dynamicBudget * 0.35) -- 1036
		) -- 1036
	) -- 1036
	local boundedHistory = clipTextToTokenBudget( -- 1037
		historyText, -- 1037
		math.max( -- 1037
			800, -- 1037
			math.floor(dynamicBudget * 0.65) -- 1037
		) -- 1037
	) -- 1037
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 1038
end -- 1028
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1044
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1044
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 1050
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 1053
		local messages = {{role = "system", content = self.config.promptPack.memoryCompressionSystemPrompt}, {role = "user", content = prompt}} -- 1077
		local fn -- 1088
		local argsText = "" -- 1089
		do -- 1089
			local i = 0 -- 1090
			while i < maxLLMTry do -- 1090
				local response = __TS__Await(callLLM( -- 1092
					messages, -- 1093
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1094
					nil, -- 1099
					self.config.llmConfig -- 1100
				)) -- 1100
				if not response.success then -- 1100
					return ____awaiter_resolve(nil, { -- 1100
						success = false, -- 1105
						memoryUpdate = currentMemory, -- 1106
						historyEntry = "", -- 1107
						compressedCount = 0, -- 1108
						error = response.message -- 1109
					}) -- 1109
				end -- 1109
				local choice = response.response.choices and response.response.choices[1] -- 1113
				local message = choice and choice.message -- 1114
				local toolCalls = message and message.tool_calls -- 1115
				local toolCall = toolCalls and toolCalls[1] -- 1116
				fn = toolCall and toolCall["function"] -- 1117
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1118
				if fn ~= nil and #argsText > 0 then -- 1118
					break -- 1119
				end -- 1119
				i = i + 1 -- 1090
			end -- 1090
		end -- 1090
		if not fn or fn.name ~= "save_memory" then -- 1090
			return ____awaiter_resolve(nil, { -- 1090
				success = false, -- 1124
				memoryUpdate = currentMemory, -- 1125
				historyEntry = "", -- 1126
				compressedCount = 0, -- 1127
				error = "missing save_memory tool call" -- 1128
			}) -- 1128
		end -- 1128
		if __TS__StringTrim(argsText) == "" then -- 1128
			return ____awaiter_resolve(nil, { -- 1128
				success = false, -- 1134
				memoryUpdate = currentMemory, -- 1135
				historyEntry = "", -- 1136
				compressedCount = 0, -- 1137
				error = "empty save_memory tool arguments" -- 1138
			}) -- 1138
		end -- 1138
		local ____try = __TS__AsyncAwaiter(function() -- 1138
			local args, err = table.unpack( -- 1144
				safeJsonDecode(argsText), -- 1144
				1, -- 1144
				2 -- 1144
			) -- 1144
			if err ~= nil or not args or type(args) ~= "table" then -- 1144
				return ____awaiter_resolve( -- 1144
					nil, -- 1144
					{ -- 1146
						success = false, -- 1147
						memoryUpdate = currentMemory, -- 1148
						historyEntry = "", -- 1149
						compressedCount = 0, -- 1150
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1151
					} -- 1151
				) -- 1151
			end -- 1151
			return ____awaiter_resolve( -- 1151
				nil, -- 1151
				self:buildCompressionResultFromObject(args, currentMemory) -- 1155
			) -- 1155
		end) -- 1155
		__TS__Await(____try.catch( -- 1143
			____try, -- 1143
			function(____, ____error) -- 1143
				return ____awaiter_resolve( -- 1143
					nil, -- 1143
					{ -- 1160
						success = false, -- 1161
						memoryUpdate = currentMemory, -- 1162
						historyEntry = "", -- 1163
						compressedCount = 0, -- 1164
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1165
					} -- 1165
				) -- 1165
			end -- 1165
		)) -- 1165
	end) -- 1165
end -- 1044
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1170
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1170
		local prompt = self:buildXMLCompressionPrompt(currentMemory, historyText) -- 1176
		local lastError = "invalid xml response" -- 1177
		do -- 1177
			local i = 0 -- 1179
			while i < maxLLMTry do -- 1179
				do -- 1179
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1180
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions, nil, self.config.llmConfig)) -- 1185
					if not response.success then -- 1185
						return ____awaiter_resolve(nil, { -- 1185
							success = false, -- 1194
							memoryUpdate = currentMemory, -- 1195
							historyEntry = "", -- 1196
							compressedCount = 0, -- 1197
							error = response.message -- 1198
						}) -- 1198
					end -- 1198
					local choice = response.response.choices and response.response.choices[1] -- 1202
					local message = choice and choice.message -- 1203
					local text = message and type(message.content) == "string" and message.content or "" -- 1204
					if __TS__StringTrim(text) == "" then -- 1204
						lastError = "empty xml response" -- 1206
						goto __continue155 -- 1207
					end -- 1207
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1210
					if parsed.success then -- 1210
						return ____awaiter_resolve(nil, parsed) -- 1210
					end -- 1210
					lastError = parsed.error or "invalid xml response" -- 1214
				end -- 1214
				::__continue155:: -- 1214
				i = i + 1 -- 1179
			end -- 1179
		end -- 1179
		return ____awaiter_resolve(nil, { -- 1179
			success = false, -- 1218
			memoryUpdate = currentMemory, -- 1219
			historyEntry = "", -- 1220
			compressedCount = 0, -- 1221
			error = lastError -- 1222
		}) -- 1222
	end) -- 1222
end -- 1170
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1229
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1230
end -- 1229
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1236
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1237
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1238
end -- 1236
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 1244
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1245
end -- 1244
function MemoryCompressor.prototype.buildXMLCompressionPrompt(self, currentMemory, historyText) -- 1250
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1251
end -- 1250
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1256
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1257
	if not parsed.success then -- 1257
		return { -- 1259
			success = false, -- 1260
			memoryUpdate = currentMemory, -- 1261
			historyEntry = "", -- 1262
			compressedCount = 0, -- 1263
			error = parsed.message -- 1264
		} -- 1264
	end -- 1264
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 1267
end -- 1256
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1273
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1277
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1278
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1278
		return { -- 1280
			success = false, -- 1281
			memoryUpdate = currentMemory, -- 1282
			historyEntry = "", -- 1283
			compressedCount = 0, -- 1284
			error = "missing history_entry or memory_update" -- 1285
		} -- 1285
	end -- 1285
	local ts = os.date("%Y-%m-%d %H:%M") -- 1288
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1289
end -- 1273
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1300
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1304
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1304
		self:rawArchive(chunk) -- 1307
		self.consecutiveFailures = 0 -- 1308
		return { -- 1310
			success = true, -- 1311
			memoryUpdate = self.storage:readMemory(), -- 1312
			historyEntry = "[RAW ARCHIVE] Detailed history not recorded", -- 1313
			compressedCount = #chunk -- 1314
		} -- 1314
	end -- 1314
	return { -- 1318
		success = false, -- 1319
		memoryUpdate = self.storage:readMemory(), -- 1320
		historyEntry = "", -- 1321
		compressedCount = 0, -- 1322
		error = ____error -- 1323
	} -- 1323
end -- 1300
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1330
	local ts = os.date("%Y-%m-%d %H:%M") -- 1331
	local firstUserMessage -- 1332
	do -- 1332
		local i = 0 -- 1333
		while i < #chunk do -- 1333
			if chunk[i + 1].role == "user" then -- 1333
				firstUserMessage = chunk[i + 1] -- 1335
				break -- 1336
			end -- 1336
			i = i + 1 -- 1333
		end -- 1333
	end -- 1333
	local prompt = firstUserMessage and firstUserMessage.content and __TS__StringTrim(firstUserMessage.content) ~= "" and __TS__StringReplace( -- 1339
		__TS__StringTrim(firstUserMessage.content), -- 1340
		"\n", -- 1340
		" " -- 1340
	) or "(empty prompt)" -- 1340
	local compactPrompt = #prompt > 160 and string.sub(prompt, 1, 160) .. "..." or prompt -- 1342
	self.storage:appendHistory(((((("[" .. ts) .. "] [RAW ARCHIVE] prompt=\"") .. compactPrompt) .. "\" (") .. tostring(#chunk)) .. " messages, compression failed; detailed history not recorded)") -- 1343
end -- 1330
function MemoryCompressor.prototype.getStorage(self) -- 1351
	return self.storage -- 1352
end -- 1351
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1355
	return math.max( -- 1356
		1, -- 1356
		math.floor(self.config.maxCompressionRounds) -- 1356
	) -- 1356
end -- 1355
MemoryCompressor.MAX_FAILURES = 3 -- 1355
return ____exports -- 1355