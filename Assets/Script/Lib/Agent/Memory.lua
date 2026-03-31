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
local function isRecord(value) -- 7
	return type(value) == "table" -- 8
end -- 7
local function isArray(value) -- 11
	return __TS__ArrayIsArray(value) -- 12
end -- 11
local AGENT_CONFIG_DIR = ".agent" -- 24
local AGENT_PROMPTS_FILE = "AGENT.md" -- 25
local XML_DECISION_SCHEMA_EXAMPLE = "```xml\n<tool_call>\n\t<tool>edit_file</tool>\n\t<reason>Need to update the file content to implement the requested change.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<old_str>\nfunction oldName() {\n\tprint(\"old\");\n}\n\t\t</old_str>\n\t\t<new_str>\nfunction newName() {\n\tprint(\"hello\");\n}\n\t\t</new_str>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>read_file</tool>\n\t<reason>Need to inspect the current implementation before editing.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<startLine>1</startLine>\n\t\t<endLine>200</endLine>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>finish</tool>\n\t<params>\n\t\t<message>Final user-facing answer.</message>\n\t</params>\n</tool_call>\n```" -- 26
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 82
	agentIdentityPrompt = "### Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 83
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Line starts with 1. startLine defaults to 1 and endLine defaults to 300.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 96
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 142
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 143
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 144
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 145
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 158
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.", -- 189
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n### Actions to Process\n\n{{HISTORY_TEXT}}\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph for HISTORY.md\n\t- Include timestamp and key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 191
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 225
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update>\nFull updated MEMORY.md content\n\t</memory_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Use exactly two child tags: `<history_entry>` and `<memory_update>`.\n- Use CDATA for `<memory_update>` when it spans multiple lines or contains markdown/code.", -- 230
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 247
} -- 247
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn"} -- 250
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 250
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 250
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 256
local function replaceTemplateVars(template, vars) -- 261
	local output = template -- 262
	for key in pairs(vars) do -- 263
		output = table.concat( -- 264
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 264
			vars[key] or "" or "," -- 264
		) -- 264
	end -- 264
	return output -- 266
end -- 261
function ____exports.resolveAgentPromptPack(value) -- 269
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 270
	if value and not isArray(value) and isRecord(value) then -- 270
		do -- 270
			local i = 0 -- 274
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 274
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 275
				if type(value[key]) == "string" then -- 275
					merged[key] = value[key] -- 277
				end -- 277
				i = i + 1 -- 274
			end -- 274
		end -- 274
	end -- 274
	return merged -- 281
end -- 269
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 284
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 285
	local lines = {} -- 286
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 287
	lines[#lines + 1] = "" -- 288
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 289
	lines[#lines + 1] = "" -- 290
	do -- 290
		local i = 0 -- 291
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 291
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 292
			lines[#lines + 1] = "## " .. key -- 293
			local text = pack[key] -- 294
			local split = __TS__StringSplit(text, "\n") -- 295
			do -- 295
				local j = 0 -- 296
				while j < #split do -- 296
					lines[#lines + 1] = split[j + 1] -- 297
					j = j + 1 -- 296
				end -- 296
			end -- 296
			lines[#lines + 1] = "" -- 299
			i = i + 1 -- 291
		end -- 291
	end -- 291
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 301
end -- 284
local function getPromptPackConfigPath(projectRoot) -- 304
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 305
end -- 304
local function ensurePromptPackConfig(projectRoot) -- 308
	local path = getPromptPackConfigPath(projectRoot) -- 309
	if Content:exist(path) then -- 309
		return nil -- 310
	end -- 310
	local dir = Path:getPath(path) -- 311
	if not Content:exist(dir) then -- 311
		Content:mkdir(dir) -- 313
	end -- 313
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 315
	if not Content:save(path, content) then -- 315
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 317
	end -- 317
	sendWebIDEFileUpdate(path, true, content) -- 319
	return nil -- 320
end -- 308
local function parsePromptPackMarkdown(text) -- 323
	if not text or __TS__StringTrim(text) == "" then -- 323
		return { -- 330
			value = {}, -- 331
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 332
			unknown = {} -- 333
		} -- 333
	end -- 333
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 336
	local lines = __TS__StringSplit(normalized, "\n") -- 337
	local sections = {} -- 338
	local unknown = {} -- 339
	local currentHeading = "" -- 340
	local function isKnownPromptPackKey(name) -- 341
		do -- 341
			local i = 0 -- 342
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 342
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 342
					return true -- 343
				end -- 343
				i = i + 1 -- 342
			end -- 342
		end -- 342
		return false -- 345
	end -- 341
	do -- 341
		local i = 0 -- 347
		while i < #lines do -- 347
			do -- 347
				local line = lines[i + 1] -- 348
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 349
				if matchedHeading ~= nil then -- 349
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 351
					if isKnownPromptPackKey(heading) then -- 351
						currentHeading = heading -- 353
						if sections[currentHeading] == nil then -- 353
							sections[currentHeading] = {} -- 355
						end -- 355
						goto __continue29 -- 357
					end -- 357
					if currentHeading == "" then -- 357
						unknown[#unknown + 1] = heading -- 360
						goto __continue29 -- 361
					end -- 361
				end -- 361
				if currentHeading ~= "" then -- 361
					local ____sections_currentHeading_1 = sections[currentHeading] -- 361
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 365
				end -- 365
			end -- 365
			::__continue29:: -- 365
			i = i + 1 -- 347
		end -- 347
	end -- 347
	local value = {} -- 368
	local missing = {} -- 369
	do -- 369
		local i = 0 -- 370
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 370
			do -- 370
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 371
				local section = sections[key] -- 372
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 373
				if body == "" then -- 373
					missing[#missing + 1] = key -- 375
					goto __continue36 -- 376
				end -- 376
				value[key] = body -- 378
			end -- 378
			::__continue36:: -- 378
			i = i + 1 -- 370
		end -- 370
	end -- 370
	if #__TS__ObjectKeys(sections) == 0 then -- 370
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 381
	end -- 381
	return {value = value, missing = missing, unknown = unknown} -- 387
end -- 323
function ____exports.loadAgentPromptPack(projectRoot) -- 390
	local path = getPromptPackConfigPath(projectRoot) -- 391
	local warnings = {} -- 392
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 393
	if ensureWarning and ensureWarning ~= "" then -- 393
		warnings[#warnings + 1] = ensureWarning -- 395
	end -- 395
	if not Content:exist(path) then -- 395
		return { -- 398
			pack = ____exports.resolveAgentPromptPack(), -- 399
			warnings = warnings, -- 400
			path = path -- 401
		} -- 401
	end -- 401
	local text = Content:load(path) -- 404
	if not text or __TS__StringTrim(text) == "" then -- 404
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 406
		return { -- 407
			pack = ____exports.resolveAgentPromptPack(), -- 408
			warnings = warnings, -- 409
			path = path -- 410
		} -- 410
	end -- 410
	local parsed = parsePromptPackMarkdown(text) -- 413
	if parsed.error or not parsed.value then -- 413
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 415
		return { -- 416
			pack = ____exports.resolveAgentPromptPack(), -- 417
			warnings = warnings, -- 418
			path = path -- 419
		} -- 419
	end -- 419
	if #parsed.unknown > 0 then -- 419
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 423
	end -- 423
	if #parsed.missing > 0 then -- 423
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 426
	end -- 426
	return { -- 428
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 429
		warnings = warnings, -- 430
		path = path -- 431
	} -- 431
end -- 390
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 486
local TokenEstimator = ____exports.TokenEstimator -- 486
TokenEstimator.name = "TokenEstimator" -- 486
function TokenEstimator.prototype.____constructor(self) -- 486
end -- 486
function TokenEstimator.estimate(self, text) -- 496
	if not text then -- 496
		return 0 -- 497
	end -- 497
	local chineseChars = utf8.len(text) -- 500
	if not chineseChars then -- 500
		return 0 -- 501
	end -- 501
	local otherChars = #text - chineseChars -- 503
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 505
	return math.max(1, tokens) -- 510
end -- 496
function TokenEstimator.estimateMessages(self, messages) -- 513
	if not messages or #messages == 0 then -- 513
		return 0 -- 514
	end -- 514
	local total = 0 -- 515
	do -- 515
		local i = 0 -- 516
		while i < #messages do -- 516
			local message = messages[i + 1] -- 517
			total = total + self:estimate(message.role or "") -- 518
			total = total + self:estimate(message.content or "") -- 519
			total = total + self:estimate(message.name or "") -- 520
			total = total + self:estimate(message.tool_call_id or "") -- 521
			total = total + self:estimate(message.reasoning_content or "") -- 522
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 523
			total = total + self:estimate(toolCallsText or "") -- 524
			total = total + 8 -- 525
			i = i + 1 -- 516
		end -- 516
	end -- 516
	return total -- 527
end -- 513
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 530
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 535
end -- 530
TokenEstimator.CHARS_PER_TOKEN = 4 -- 530
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 530
local function utf8TakeHead(text, maxChars) -- 543
	if maxChars <= 0 or text == "" then -- 543
		return "" -- 544
	end -- 544
	local nextPos = utf8.offset(text, maxChars + 1) -- 545
	if nextPos == nil then -- 545
		return text -- 546
	end -- 546
	return string.sub(text, 1, nextPos - 1) -- 547
end -- 543
local function utf8TakeTail(text, maxChars) -- 550
	if maxChars <= 0 or text == "" then -- 550
		return "" -- 551
	end -- 551
	local charLen = utf8.len(text) -- 552
	if charLen == nil or charLen <= maxChars then -- 552
		return text -- 553
	end -- 553
	local startChar = math.max(1, charLen - maxChars + 1) -- 554
	local startPos = utf8.offset(text, startChar) -- 555
	if startPos == nil then -- 555
		return text -- 556
	end -- 556
	return string.sub(text, startPos) -- 557
end -- 550
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 565
local DualLayerStorage = ____exports.DualLayerStorage -- 565
DualLayerStorage.name = "DualLayerStorage" -- 565
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 572
	self.projectDir = projectDir -- 573
	self.agentDir = Path(self.projectDir, ".agent") -- 574
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 575
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 576
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 577
	self:ensureAgentFiles() -- 578
end -- 572
function DualLayerStorage.prototype.ensureDir(self, dir) -- 581
	if not Content:exist(dir) then -- 581
		Content:mkdir(dir) -- 583
	end -- 583
end -- 581
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 587
	if Content:exist(path) then -- 587
		return false -- 588
	end -- 588
	self:ensureDir(Path:getPath(path)) -- 589
	if not Content:save(path, content) then -- 589
		return false -- 591
	end -- 591
	sendWebIDEFileUpdate(path, true, content) -- 593
	return true -- 594
end -- 587
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 597
	self:ensureDir(self.agentDir) -- 598
	self:ensureFile(self.memoryPath, "") -- 599
	self:ensureFile(self.historyPath, "") -- 600
end -- 597
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 603
	local text = safeJsonEncode(value) -- 604
	return text -- 605
end -- 603
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 608
	local value = safeJsonDecode(text) -- 609
	return value -- 610
end -- 608
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 613
	if not value or isArray(value) or not isRecord(value) then -- 613
		return nil -- 614
	end -- 614
	local row = value -- 615
	local role = type(row.role) == "string" and row.role or "" -- 616
	if role == "" then -- 616
		return nil -- 617
	end -- 617
	local message = {role = role} -- 618
	if type(row.content) == "string" then -- 618
		message.content = sanitizeUTF8(row.content) -- 619
	end -- 619
	if type(row.name) == "string" then -- 619
		message.name = sanitizeUTF8(row.name) -- 620
	end -- 620
	if type(row.tool_call_id) == "string" then -- 620
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 621
	end -- 621
	if type(row.reasoning_content) == "string" then -- 621
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 622
	end -- 622
	if type(row.timestamp) == "string" then -- 622
		message.timestamp = sanitizeUTF8(row.timestamp) -- 623
	end -- 623
	if isArray(row.tool_calls) then -- 623
		message.tool_calls = row.tool_calls -- 625
	end -- 625
	return message -- 627
end -- 613
function DualLayerStorage.prototype.readMemory(self) -- 635
	if not Content:exist(self.memoryPath) then -- 635
		return "" -- 637
	end -- 637
	return Content:load(self.memoryPath) -- 639
end -- 635
function DualLayerStorage.prototype.writeMemory(self, content) -- 645
	self:ensureDir(Path:getPath(self.memoryPath)) -- 646
	Content:save(self.memoryPath, content) -- 647
end -- 645
function DualLayerStorage.prototype.getMemoryContext(self) -- 653
	local memory = self:readMemory() -- 654
	if not memory then -- 654
		return "" -- 655
	end -- 655
	return "### Long-term Memory\n\n" .. memory -- 657
end -- 653
function DualLayerStorage.prototype.appendHistory(self, entry) -- 667
	self:ensureDir(Path:getPath(self.historyPath)) -- 668
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 670
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 674
end -- 667
function DualLayerStorage.prototype.readHistory(self) -- 680
	if not Content:exist(self.historyPath) then -- 680
		return "" -- 682
	end -- 682
	return Content:load(self.historyPath) -- 684
end -- 680
function DualLayerStorage.prototype.readSessionState(self) -- 687
	if not Content:exist(self.sessionPath) then -- 687
		return {messages = {}, lastConsolidatedMessageIndex = 0} -- 689
	end -- 689
	local text = Content:load(self.sessionPath) -- 691
	if not text or __TS__StringTrim(text) == "" then -- 691
		return {messages = {}, lastConsolidatedMessageIndex = 0} -- 693
	end -- 693
	local lines = __TS__StringSplit(text, "\n") -- 695
	local messages = {} -- 696
	local lastConsolidatedMessageIndex = 0 -- 697
	do -- 697
		local i = 0 -- 698
		while i < #lines do -- 698
			do -- 698
				local line = __TS__StringTrim(lines[i + 1]) -- 699
				if line == "" then -- 699
					goto __continue92 -- 700
				end -- 700
				local data = self:decodeJsonLine(line) -- 701
				if not data or isArray(data) or not isRecord(data) then -- 701
					goto __continue92 -- 702
				end -- 702
				local row = data -- 703
				if row._type == "metadata" then -- 703
					local ____math_max_4 = math.max -- 705
					local ____math_floor_3 = math.floor -- 705
					local ____row_lastConsolidatedMessageIndex_2 = row.lastConsolidatedMessageIndex -- 705
					if ____row_lastConsolidatedMessageIndex_2 == nil then -- 705
						____row_lastConsolidatedMessageIndex_2 = 0 -- 705
					end -- 705
					lastConsolidatedMessageIndex = ____math_max_4( -- 705
						0, -- 705
						____math_floor_3(__TS__Number(____row_lastConsolidatedMessageIndex_2)) -- 705
					) -- 705
					goto __continue92 -- 706
				end -- 706
				local ____self_decodeConversationMessage_6 = self.decodeConversationMessage -- 708
				local ____row_message_5 = row.message -- 708
				if ____row_message_5 == nil then -- 708
					____row_message_5 = row -- 708
				end -- 708
				local message = ____self_decodeConversationMessage_6(self, ____row_message_5) -- 708
				if message then -- 708
					messages[#messages + 1] = message -- 710
				end -- 710
			end -- 710
			::__continue92:: -- 710
			i = i + 1 -- 698
		end -- 698
	end -- 698
	return { -- 713
		messages = messages, -- 714
		lastConsolidatedMessageIndex = math.min(lastConsolidatedMessageIndex, #messages) -- 715
	} -- 715
end -- 687
function DualLayerStorage.prototype.writeSessionState(self, messages, lastConsolidatedMessageIndex) -- 719
	if messages == nil then -- 719
		messages = {} -- 720
	end -- 720
	if lastConsolidatedMessageIndex == nil then -- 720
		lastConsolidatedMessageIndex = 0 -- 721
	end -- 721
	self:ensureDir(Path:getPath(self.sessionPath)) -- 723
	local lines = {} -- 724
	local meta = self:encodeJsonLine({ -- 725
		_type = "metadata", -- 726
		lastConsolidatedMessageIndex = math.min( -- 727
			math.max( -- 727
				0, -- 727
				math.floor(lastConsolidatedMessageIndex) -- 727
			), -- 727
			#messages -- 727
		) -- 727
	}) -- 727
	if meta then -- 727
		lines[#lines + 1] = meta -- 730
	end -- 730
	do -- 730
		local i = 0 -- 732
		while i < #messages do -- 732
			local line = self:encodeJsonLine({_type = "message", message = messages[i + 1]}) -- 733
			if line then -- 733
				lines[#lines + 1] = line -- 738
			end -- 738
			i = i + 1 -- 732
		end -- 732
	end -- 732
	local content = table.concat(lines, "\n") .. "\n" -- 741
	Content:save(self.sessionPath, content) -- 742
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 743
end -- 719
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 749
	local history = self:readHistory() -- 750
	if not history then -- 750
		return {} -- 751
	end -- 751
	local lines = __TS__StringSplit(history, "\n") -- 753
	local lowerKeyword = string.lower(keyword) -- 754
	return __TS__ArrayFilter( -- 756
		lines, -- 756
		function(____, line) return __TS__StringIncludes( -- 756
			string.lower(line), -- 757
			lowerKeyword -- 757
		) end -- 757
	) -- 757
end -- 749
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 770
local MemoryCompressor = ____exports.MemoryCompressor -- 770
MemoryCompressor.name = "MemoryCompressor" -- 770
function MemoryCompressor.prototype.____constructor(self, config) -- 777
	self.consecutiveFailures = 0 -- 773
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 778
	do -- 778
		local i = 0 -- 779
		while i < #loadedPromptPack.warnings do -- 779
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 780
			i = i + 1 -- 779
		end -- 779
	end -- 779
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 782
	self.config = __TS__ObjectAssign( -- 785
		{}, -- 785
		config, -- 786
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 785
	) -- 785
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 792
end -- 777
function MemoryCompressor.prototype.getPromptPack(self) -- 795
	return self.config.promptPack -- 796
end -- 795
function MemoryCompressor.prototype.shouldCompress(self, messages, lastConsolidatedMessageIndex, systemPrompt, toolDefinitions) -- 802
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages( -- 808
		__TS__ArraySlice(messages, lastConsolidatedMessageIndex), -- 809
		systemPrompt, -- 810
		toolDefinitions -- 811
	) -- 811
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 814
	return messageTokens > threshold -- 816
end -- 802
function MemoryCompressor.prototype.compress(self, messages, lastConsolidatedMessageIndex, systemPrompt, toolDefinitions, llmOptions, maxLLMTry, decisionMode) -- 822
	if decisionMode == nil then -- 822
		decisionMode = "tool_calling" -- 829
	end -- 829
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 829
		local toCompress = __TS__ArraySlice(messages, lastConsolidatedMessageIndex) -- 831
		if #toCompress == 0 then -- 831
			return ____awaiter_resolve(nil, nil) -- 831
		end -- 831
		local boundary = self:findCompressionBoundary(toCompress, systemPrompt, toolDefinitions) -- 834
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 839
		if #chunk == 0 then -- 839
			return ____awaiter_resolve(nil, nil) -- 839
		end -- 839
		local currentMemory = self.storage:readMemory() -- 843
		local historyText = self:formatMessagesForCompression(chunk) -- 844
		local ____try = __TS__AsyncAwaiter(function() -- 844
			local result = __TS__Await(self:callLLMForCompression( -- 848
				currentMemory, -- 849
				historyText, -- 850
				llmOptions, -- 851
				maxLLMTry or 3, -- 852
				decisionMode -- 853
			)) -- 853
			if result.success then -- 853
				self.storage:writeMemory(result.memoryUpdate) -- 858
				self.storage:appendHistory(result.historyEntry) -- 859
				self.consecutiveFailures = 0 -- 860
				return ____awaiter_resolve( -- 860
					nil, -- 860
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 862
				) -- 862
			end -- 862
			return ____awaiter_resolve( -- 862
				nil, -- 862
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 869
			) -- 869
		end) -- 869
		__TS__Await(____try.catch( -- 846
			____try, -- 846
			function(____, ____error) -- 846
				return ____awaiter_resolve( -- 846
					nil, -- 846
					self:handleCompressionFailure( -- 872
						chunk, -- 872
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 872
					) -- 872
				) -- 872
			end -- 872
		)) -- 872
	end) -- 872
end -- 822
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, systemPrompt, toolDefinitions) -- 881
	local requiredTokens = self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 886
	local targetTokens = math.min( -- 887
		self.config.maxTokensPerCompression, -- 888
		math.max(1, requiredTokens) -- 889
	) -- 889
	local accumulatedTokens = 0 -- 891
	local lastSafeBoundary = 0 -- 892
	local pendingToolCalls = {} -- 893
	local pendingToolCallCount = 0 -- 894
	do -- 894
		local i = 0 -- 896
		while i < #messages do -- 896
			local message = messages[i + 1] -- 897
			local tokens = ____exports.TokenEstimator:estimatePromptMessages({message}, "", "") -- 898
			accumulatedTokens = accumulatedTokens + tokens -- 899
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 899
				do -- 899
					local j = 0 -- 902
					while j < #message.tool_calls do -- 902
						local toolCallEntry = message.tool_calls[j + 1] -- 903
						local idValue = toolCallEntry.id -- 904
						local id = type(idValue) == "string" and idValue or "" -- 905
						if id ~= "" and not pendingToolCalls[id] then -- 905
							pendingToolCalls[id] = true -- 907
							pendingToolCallCount = pendingToolCallCount + 1 -- 908
						end -- 908
						j = j + 1 -- 902
					end -- 902
				end -- 902
			end -- 902
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 902
				pendingToolCalls[message.tool_call_id] = false -- 914
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 915
			end -- 915
			local isAtEnd = i >= #messages - 1 -- 918
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 919
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 920
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 921
			if isSafeBoundary then -- 921
				lastSafeBoundary = i + 1 -- 923
			end -- 923
			if accumulatedTokens >= targetTokens and isSafeBoundary then -- 923
				return i + 1 -- 927
			end -- 927
			i = i + 1 -- 896
		end -- 896
	end -- 896
	if lastSafeBoundary > 0 then -- 896
		return lastSafeBoundary -- 931
	end -- 931
	return math.min(#messages, 1) -- 932
end -- 881
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages, systemPrompt, toolDefinitions) -- 935
	local currentTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 940
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 945
	local overflow = math.max(0, currentTokens - threshold) -- 946
	if overflow <= 0 then -- 946
		return math.min( -- 948
			self.config.maxTokensPerCompression, -- 949
			math.max( -- 950
				1, -- 950
				____exports.TokenEstimator:estimatePromptMessages( -- 950
					__TS__ArraySlice(messages, 0, 1), -- 950
					"", -- 950
					"" -- 950
				) -- 950
			) -- 950
		) -- 950
	end -- 950
	local safetyMargin = math.max( -- 953
		64, -- 953
		math.floor(threshold * 0.01) -- 953
	) -- 953
	return math.min(self.config.maxTokensPerCompression, overflow + safetyMargin) -- 954
end -- 935
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 957
	local lines = {} -- 958
	do -- 958
		local i = 0 -- 959
		while i < #messages do -- 959
			local message = messages[i + 1] -- 960
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 961
			if message.name and message.name ~= "" then -- 961
				lines[#lines + 1] = "name=" .. message.name -- 962
			end -- 962
			if message.tool_call_id and message.tool_call_id ~= "" then -- 962
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 963
			end -- 963
			if message.reasoning_content and message.reasoning_content ~= "" then -- 963
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 964
			end -- 964
			if message.tool_calls and #message.tool_calls > 0 then -- 964
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 966
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 967
			end -- 967
			if message.content and message.content ~= "" then -- 967
				lines[#lines + 1] = message.content -- 969
			end -- 969
			if i < #messages - 1 then -- 969
				lines[#lines + 1] = "" -- 970
			end -- 970
			i = i + 1 -- 959
		end -- 959
	end -- 959
	return table.concat(lines, "\n") -- 972
end -- 957
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 978
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 978
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 985
		if decisionMode == "xml" then -- 985
			return ____awaiter_resolve( -- 985
				nil, -- 985
				self:callLLMForCompressionByXML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 987
			) -- 987
		end -- 987
		return ____awaiter_resolve( -- 987
			nil, -- 987
			self:callLLMForCompressionByToolCalling(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 994
		) -- 994
	end) -- 994
end -- 978
function MemoryCompressor.prototype.getContextWindow(self) -- 1002
	return math.max(4000, self.config.llmConfig.contextWindow) -- 1003
end -- 1002
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1006
	local contextWindow = self:getContextWindow() -- 1007
	local reservedOutputTokens = math.max( -- 1008
		2048, -- 1008
		math.floor(contextWindow * 0.2) -- 1008
	) -- 1008
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBodyRaw("", "")) -- 1009
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1010
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1011
	return math.max( -- 1012
		1200, -- 1012
		math.floor(available * 0.9) -- 1012
	) -- 1012
end -- 1006
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1015
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1016
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1017
	if historyTokens <= tokenBudget then -- 1017
		return historyText -- 1018
	end -- 1018
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1019
	local targetChars = math.max( -- 1022
		2000, -- 1022
		math.floor(tokenBudget * charsPerToken) -- 1022
	) -- 1022
	local keepHead = math.max( -- 1023
		0, -- 1023
		math.floor(targetChars * 0.35) -- 1023
	) -- 1023
	local keepTail = math.max(0, targetChars - keepHead) -- 1024
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1025
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1026
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1027
end -- 1015
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1030
	local contextWindow = self:getContextWindow() -- 1034
	local reservedOutputTokens = math.max( -- 1035
		2048, -- 1035
		math.floor(contextWindow * 0.2) -- 1035
	) -- 1035
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBodyRaw("", "")) -- 1036
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1037
	local boundedMemory = clipTextToTokenBudget( -- 1038
		currentMemory or "(empty)", -- 1038
		math.max( -- 1038
			320, -- 1038
			math.floor(dynamicBudget * 0.35) -- 1038
		) -- 1038
	) -- 1038
	local boundedHistory = clipTextToTokenBudget( -- 1039
		historyText, -- 1039
		math.max( -- 1039
			800, -- 1039
			math.floor(dynamicBudget * 0.65) -- 1039
		) -- 1039
	) -- 1039
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 1040
end -- 1030
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1046
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1046
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 1052
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 1055
		local messages = {{role = "system", content = self.config.promptPack.memoryCompressionSystemPrompt}, {role = "user", content = prompt}} -- 1079
		local fn -- 1090
		local argsText = "" -- 1091
		do -- 1091
			local i = 0 -- 1092
			while i < maxLLMTry do -- 1092
				local response = __TS__Await(callLLM( -- 1094
					messages, -- 1095
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1096
					nil, -- 1101
					self.config.llmConfig -- 1102
				)) -- 1102
				if not response.success then -- 1102
					return ____awaiter_resolve(nil, { -- 1102
						success = false, -- 1107
						memoryUpdate = currentMemory, -- 1108
						historyEntry = "", -- 1109
						compressedCount = 0, -- 1110
						error = response.message -- 1111
					}) -- 1111
				end -- 1111
				local choice = response.response.choices and response.response.choices[1] -- 1115
				local message = choice and choice.message -- 1116
				local toolCalls = message and message.tool_calls -- 1117
				local toolCall = toolCalls and toolCalls[1] -- 1118
				fn = toolCall and toolCall["function"] -- 1119
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1120
				if fn ~= nil and #argsText > 0 then -- 1120
					break -- 1121
				end -- 1121
				i = i + 1 -- 1092
			end -- 1092
		end -- 1092
		if not fn or fn.name ~= "save_memory" then -- 1092
			return ____awaiter_resolve(nil, { -- 1092
				success = false, -- 1126
				memoryUpdate = currentMemory, -- 1127
				historyEntry = "", -- 1128
				compressedCount = 0, -- 1129
				error = "missing save_memory tool call" -- 1130
			}) -- 1130
		end -- 1130
		if __TS__StringTrim(argsText) == "" then -- 1130
			return ____awaiter_resolve(nil, { -- 1130
				success = false, -- 1136
				memoryUpdate = currentMemory, -- 1137
				historyEntry = "", -- 1138
				compressedCount = 0, -- 1139
				error = "empty save_memory tool arguments" -- 1140
			}) -- 1140
		end -- 1140
		local ____try = __TS__AsyncAwaiter(function() -- 1140
			local args, err = safeJsonDecode(argsText) -- 1146
			if err ~= nil or not args or type(args) ~= "table" then -- 1146
				return ____awaiter_resolve( -- 1146
					nil, -- 1146
					{ -- 1148
						success = false, -- 1149
						memoryUpdate = currentMemory, -- 1150
						historyEntry = "", -- 1151
						compressedCount = 0, -- 1152
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1153
					} -- 1153
				) -- 1153
			end -- 1153
			return ____awaiter_resolve( -- 1153
				nil, -- 1153
				self:buildCompressionResultFromObject(args, currentMemory) -- 1157
			) -- 1157
		end) -- 1157
		__TS__Await(____try.catch( -- 1145
			____try, -- 1145
			function(____, ____error) -- 1145
				return ____awaiter_resolve( -- 1145
					nil, -- 1145
					{ -- 1162
						success = false, -- 1163
						memoryUpdate = currentMemory, -- 1164
						historyEntry = "", -- 1165
						compressedCount = 0, -- 1166
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1167
					} -- 1167
				) -- 1167
			end -- 1167
		)) -- 1167
	end) -- 1167
end -- 1046
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1172
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1172
		local prompt = self:buildXMLCompressionPrompt(currentMemory, historyText) -- 1178
		local lastError = "invalid xml response" -- 1179
		do -- 1179
			local i = 0 -- 1181
			while i < maxLLMTry do -- 1181
				do -- 1181
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1182
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions, nil, self.config.llmConfig)) -- 1187
					if not response.success then -- 1187
						return ____awaiter_resolve(nil, { -- 1187
							success = false, -- 1196
							memoryUpdate = currentMemory, -- 1197
							historyEntry = "", -- 1198
							compressedCount = 0, -- 1199
							error = response.message -- 1200
						}) -- 1200
					end -- 1200
					local choice = response.response.choices and response.response.choices[1] -- 1204
					local message = choice and choice.message -- 1205
					local text = message and type(message.content) == "string" and message.content or "" -- 1206
					if __TS__StringTrim(text) == "" then -- 1206
						lastError = "empty xml response" -- 1208
						goto __continue157 -- 1209
					end -- 1209
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1212
					if parsed.success then -- 1212
						return ____awaiter_resolve(nil, parsed) -- 1212
					end -- 1212
					lastError = parsed.error or "invalid xml response" -- 1216
				end -- 1216
				::__continue157:: -- 1216
				i = i + 1 -- 1181
			end -- 1181
		end -- 1181
		return ____awaiter_resolve(nil, { -- 1181
			success = false, -- 1220
			memoryUpdate = currentMemory, -- 1221
			historyEntry = "", -- 1222
			compressedCount = 0, -- 1223
			error = lastError -- 1224
		}) -- 1224
	end) -- 1224
end -- 1172
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1231
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1232
end -- 1231
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1238
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1239
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1240
end -- 1238
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 1246
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1247
end -- 1246
function MemoryCompressor.prototype.buildXMLCompressionPrompt(self, currentMemory, historyText) -- 1252
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1253
end -- 1252
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1258
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1259
	if not parsed.success then -- 1259
		return { -- 1261
			success = false, -- 1262
			memoryUpdate = currentMemory, -- 1263
			historyEntry = "", -- 1264
			compressedCount = 0, -- 1265
			error = parsed.message -- 1266
		} -- 1266
	end -- 1266
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 1269
end -- 1258
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1275
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1279
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1280
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1280
		return { -- 1282
			success = false, -- 1283
			memoryUpdate = currentMemory, -- 1284
			historyEntry = "", -- 1285
			compressedCount = 0, -- 1286
			error = "missing history_entry or memory_update" -- 1287
		} -- 1287
	end -- 1287
	local ts = os.date("%Y-%m-%d %H:%M") -- 1290
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1291
end -- 1275
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1302
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1306
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1306
		self:rawArchive(chunk) -- 1309
		self.consecutiveFailures = 0 -- 1310
		return { -- 1312
			success = true, -- 1313
			memoryUpdate = self.storage:readMemory(), -- 1314
			historyEntry = "[RAW ARCHIVE] Detailed history not recorded", -- 1315
			compressedCount = #chunk -- 1316
		} -- 1316
	end -- 1316
	return { -- 1320
		success = false, -- 1321
		memoryUpdate = self.storage:readMemory(), -- 1322
		historyEntry = "", -- 1323
		compressedCount = 0, -- 1324
		error = ____error -- 1325
	} -- 1325
end -- 1302
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1332
	local ts = os.date("%Y-%m-%d %H:%M") -- 1333
	local firstUserMessage -- 1334
	do -- 1334
		local i = 0 -- 1335
		while i < #chunk do -- 1335
			if chunk[i + 1].role == "user" then -- 1335
				firstUserMessage = chunk[i + 1] -- 1337
				break -- 1338
			end -- 1338
			i = i + 1 -- 1335
		end -- 1335
	end -- 1335
	local prompt = firstUserMessage and firstUserMessage.content and __TS__StringTrim(firstUserMessage.content) ~= "" and __TS__StringReplace( -- 1341
		__TS__StringTrim(firstUserMessage.content), -- 1342
		"\n", -- 1342
		" " -- 1342
	) or "(empty prompt)" -- 1342
	local compactPrompt = #prompt > 160 and string.sub(prompt, 1, 160) .. "..." or prompt -- 1344
	self.storage:appendHistory(((((("[" .. ts) .. "] [RAW ARCHIVE] prompt=\"") .. compactPrompt) .. "\" (") .. tostring(#chunk)) .. " messages, compression failed; detailed history not recorded)") -- 1345
end -- 1332
function MemoryCompressor.prototype.getStorage(self) -- 1353
	return self.storage -- 1354
end -- 1353
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1357
	return math.max( -- 1358
		1, -- 1358
		math.floor(self.config.maxCompressionRounds) -- 1358
	) -- 1358
end -- 1357
MemoryCompressor.MAX_FAILURES = 3 -- 1357
return ____exports -- 1357