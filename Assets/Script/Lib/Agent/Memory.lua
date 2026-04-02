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
local ____Tools = require("Agent.Tools") -- 5
local sendWebIDEFileUpdate = ____Tools.sendWebIDEFileUpdate -- 5
local function isRecord(value) -- 7
	return type(value) == "table" -- 8
end -- 7
local function isArray(value) -- 11
	return __TS__ArrayIsArray(value) -- 12
end -- 11
local AGENT_CONFIG_DIR = ".agent" -- 23
local AGENT_PROMPTS_FILE = "AGENT.md" -- 24
local XML_DECISION_SCHEMA_EXAMPLE = "```xml\n<tool_call>\n\t<tool>edit_file</tool>\n\t<reason>Need to update the file content to implement the requested change.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<old_str>\nfunction oldName() {\n\tprint(\"old\");\n}\n\t\t</old_str>\n\t\t<new_str>\nfunction newName() {\n\tprint(\"hello\");\n}\n\t\t</new_str>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>read_file</tool>\n\t<reason>Need to inspect the current implementation before editing.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<startLine>1</startLine>\n\t\t<endLine>200</endLine>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>finish</tool>\n\t<params>\n\t\t<message>Final user-facing answer.</message>\n\t</params>\n</tool_call>\n```" -- 25
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 81
	agentIdentityPrompt = "### Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 82
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. 0 is invalid.\n\t- startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 95
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 142
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 143
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 144
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 145
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 158
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph for HISTORY.md\n\t- Include timestamp and key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 189
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n### Actions to Process\n\n{{HISTORY_TEXT}}", -- 218
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
____exports.TokenEstimator = __TS__Class() -- 500
local TokenEstimator = ____exports.TokenEstimator -- 500
TokenEstimator.name = "TokenEstimator" -- 500
function TokenEstimator.prototype.____constructor(self) -- 500
end -- 500
function TokenEstimator.estimate(self, text) -- 504
	if not text then -- 504
		return 0 -- 505
	end -- 505
	return App:estimateTokens(text) -- 506
end -- 504
function TokenEstimator.estimateMessages(self, messages) -- 509
	if not messages or #messages == 0 then -- 509
		return 0 -- 510
	end -- 510
	local total = 0 -- 511
	do -- 511
		local i = 0 -- 512
		while i < #messages do -- 512
			local message = messages[i + 1] -- 513
			total = total + self:estimate(message.role or "") -- 514
			total = total + self:estimate(message.content or "") -- 515
			total = total + self:estimate(message.name or "") -- 516
			total = total + self:estimate(message.tool_call_id or "") -- 517
			total = total + self:estimate(message.reasoning_content or "") -- 518
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 519
			total = total + self:estimate(toolCallsText or "") -- 520
			total = total + 8 -- 521
			i = i + 1 -- 512
		end -- 512
	end -- 512
	return total -- 523
end -- 509
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 526
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 531
end -- 526
local function encodeCompressionDebugJSON(value) -- 539
	local text, err = safeJsonEncode(value) -- 540
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 541
end -- 539
local function utf8TakeHead(text, maxChars) -- 544
	if maxChars <= 0 or text == "" then -- 544
		return "" -- 545
	end -- 545
	local nextPos = utf8.offset(text, maxChars + 1) -- 546
	if nextPos == nil then -- 546
		return text -- 547
	end -- 547
	return string.sub(text, 1, nextPos - 1) -- 548
end -- 544
local function utf8TakeTail(text, maxChars) -- 551
	if maxChars <= 0 or text == "" then -- 551
		return "" -- 552
	end -- 552
	local charLen = utf8.len(text) -- 553
	if charLen == nil or charLen <= maxChars then -- 553
		return text -- 554
	end -- 554
	local startChar = math.max(1, charLen - maxChars + 1) -- 555
	local startPos = utf8.offset(text, startChar) -- 556
	if startPos == nil then -- 556
		return text -- 557
	end -- 557
	return string.sub(text, startPos) -- 558
end -- 551
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 566
local DualLayerStorage = ____exports.DualLayerStorage -- 566
DualLayerStorage.name = "DualLayerStorage" -- 566
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 573
	self.projectDir = projectDir -- 574
	self.agentDir = Path(self.projectDir, ".agent") -- 575
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 576
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 577
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 578
	self:ensureAgentFiles() -- 579
end -- 573
function DualLayerStorage.prototype.ensureDir(self, dir) -- 582
	if not Content:exist(dir) then -- 582
		Content:mkdir(dir) -- 584
	end -- 584
end -- 582
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 588
	if Content:exist(path) then -- 588
		return false -- 589
	end -- 589
	self:ensureDir(Path:getPath(path)) -- 590
	if not Content:save(path, content) then -- 590
		return false -- 592
	end -- 592
	sendWebIDEFileUpdate(path, true, content) -- 594
	return true -- 595
end -- 588
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 598
	self:ensureDir(self.agentDir) -- 599
	self:ensureFile(self.memoryPath, "") -- 600
	self:ensureFile(self.historyPath, "") -- 601
end -- 598
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 604
	local text = safeJsonEncode(value) -- 605
	return text -- 606
end -- 604
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 609
	local value = safeJsonDecode(text) -- 610
	return value -- 611
end -- 609
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 614
	if not value or isArray(value) or not isRecord(value) then -- 614
		return nil -- 615
	end -- 615
	local row = value -- 616
	local role = type(row.role) == "string" and row.role or "" -- 617
	if role == "" then -- 617
		return nil -- 618
	end -- 618
	local message = {role = role} -- 619
	if type(row.content) == "string" then -- 619
		message.content = sanitizeUTF8(row.content) -- 620
	end -- 620
	if type(row.name) == "string" then -- 620
		message.name = sanitizeUTF8(row.name) -- 621
	end -- 621
	if type(row.tool_call_id) == "string" then -- 621
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 622
	end -- 622
	if type(row.reasoning_content) == "string" then -- 622
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 623
	end -- 623
	if type(row.timestamp) == "string" then -- 623
		message.timestamp = sanitizeUTF8(row.timestamp) -- 624
	end -- 624
	if isArray(row.tool_calls) then -- 624
		message.tool_calls = row.tool_calls -- 626
	end -- 626
	return message -- 628
end -- 614
function DualLayerStorage.prototype.readMemory(self) -- 636
	if not Content:exist(self.memoryPath) then -- 636
		return "" -- 638
	end -- 638
	return Content:load(self.memoryPath) -- 640
end -- 636
function DualLayerStorage.prototype.writeMemory(self, content) -- 646
	self:ensureDir(Path:getPath(self.memoryPath)) -- 647
	Content:save(self.memoryPath, content) -- 648
end -- 646
function DualLayerStorage.prototype.getMemoryContext(self) -- 654
	local memory = self:readMemory() -- 655
	if not memory then -- 655
		return "" -- 656
	end -- 656
	return "### Long-term Memory\n\n" .. memory -- 658
end -- 654
function DualLayerStorage.prototype.appendHistory(self, entry) -- 668
	self:ensureDir(Path:getPath(self.historyPath)) -- 669
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 671
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 675
end -- 668
function DualLayerStorage.prototype.readHistory(self) -- 681
	if not Content:exist(self.historyPath) then -- 681
		return "" -- 683
	end -- 683
	return Content:load(self.historyPath) -- 685
end -- 681
function DualLayerStorage.prototype.readSessionState(self) -- 688
	if not Content:exist(self.sessionPath) then -- 688
		return {messages = {}} -- 690
	end -- 690
	local text = Content:load(self.sessionPath) -- 692
	if not text or __TS__StringTrim(text) == "" then -- 692
		return {messages = {}} -- 694
	end -- 694
	local lines = __TS__StringSplit(text, "\n") -- 696
	local messages = {} -- 697
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
				local ____self_decodeConversationMessage_3 = self.decodeConversationMessage -- 704
				local ____row_message_2 = row.message -- 704
				if ____row_message_2 == nil then -- 704
					____row_message_2 = row -- 704
				end -- 704
				local message = ____self_decodeConversationMessage_3(self, ____row_message_2) -- 704
				if message then -- 704
					messages[#messages + 1] = message -- 706
				end -- 706
			end -- 706
			::__continue92:: -- 706
			i = i + 1 -- 698
		end -- 698
	end -- 698
	return {messages = messages} -- 709
end -- 688
function DualLayerStorage.prototype.writeSessionState(self, messages) -- 712
	if messages == nil then -- 712
		messages = {} -- 712
	end -- 712
	self:ensureDir(Path:getPath(self.sessionPath)) -- 713
	local lines = {} -- 714
	do -- 714
		local i = 0 -- 715
		while i < #messages do -- 715
			local line = self:encodeJsonLine({_type = "message", message = messages[i + 1]}) -- 716
			if line then -- 716
				lines[#lines + 1] = line -- 721
			end -- 721
			i = i + 1 -- 715
		end -- 715
	end -- 715
	local content = table.concat(lines, "\n") .. "\n" -- 724
	Content:save(self.sessionPath, content) -- 725
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 726
end -- 712
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 732
	local history = self:readHistory() -- 733
	if not history then -- 733
		return {} -- 734
	end -- 734
	local lines = __TS__StringSplit(history, "\n") -- 736
	local lowerKeyword = string.lower(keyword) -- 737
	return __TS__ArrayFilter( -- 739
		lines, -- 739
		function(____, line) return __TS__StringIncludes( -- 739
			string.lower(line), -- 740
			lowerKeyword -- 740
		) end -- 740
	) -- 740
end -- 732
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 753
local MemoryCompressor = ____exports.MemoryCompressor -- 753
MemoryCompressor.name = "MemoryCompressor" -- 753
function MemoryCompressor.prototype.____constructor(self, config) -- 760
	self.consecutiveFailures = 0 -- 756
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 761
	do -- 761
		local i = 0 -- 762
		while i < #loadedPromptPack.warnings do -- 762
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 763
			i = i + 1 -- 762
		end -- 762
	end -- 762
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 765
	self.config = __TS__ObjectAssign( -- 768
		{}, -- 768
		config, -- 769
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 768
	) -- 768
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 775
end -- 760
function MemoryCompressor.prototype.getPromptPack(self) -- 778
	return self.config.promptPack -- 779
end -- 778
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 785
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 790
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 796
	return messageTokens > threshold -- 798
end -- 785
function MemoryCompressor.prototype.compress(self, messages, systemPrompt, toolDefinitions, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode) -- 804
	if decisionMode == nil then -- 804
		decisionMode = "tool_calling" -- 810
	end -- 810
	if boundaryMode == nil then -- 810
		boundaryMode = "default" -- 812
	end -- 812
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 812
		local toCompress = messages -- 814
		if #toCompress == 0 then -- 814
			return ____awaiter_resolve(nil, nil) -- 814
		end -- 814
		local currentMemory = self.storage:readMemory() -- 816
		local boundary = self:findCompressionBoundary(toCompress, currentMemory, boundaryMode) -- 818
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 823
		if #chunk == 0 then -- 823
			return ____awaiter_resolve(nil, nil) -- 823
		end -- 823
		local historyText = self:formatMessagesForCompression(chunk) -- 826
		local ____try = __TS__AsyncAwaiter(function() -- 826
			local result = __TS__Await(self:callLLMForCompression( -- 830
				currentMemory, -- 831
				historyText, -- 832
				llmOptions, -- 833
				maxLLMTry or 3, -- 834
				decisionMode, -- 835
				debugContext -- 836
			)) -- 836
			if result.success then -- 836
				self.storage:writeMemory(result.memoryUpdate) -- 841
				self.storage:appendHistory(result.historyEntry) -- 842
				self.consecutiveFailures = 0 -- 843
				return ____awaiter_resolve( -- 843
					nil, -- 843
					__TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessage = boundary.carryMessage}) -- 845
				) -- 845
			end -- 845
			return ____awaiter_resolve( -- 845
				nil, -- 845
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 853
			) -- 853
		end) -- 853
		__TS__Await(____try.catch( -- 828
			____try, -- 828
			function(____, ____error) -- 828
				return ____awaiter_resolve( -- 828
					nil, -- 828
					self:handleCompressionFailure( -- 856
						chunk, -- 856
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 856
					) -- 856
				) -- 856
			end -- 856
		)) -- 856
	end) -- 856
end -- 804
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode) -- 865
	local targetTokens = boundaryMode == "budget_max" and math.min( -- 870
		self.config.maxTokensPerCompression, -- 872
		math.max( -- 873
			1, -- 873
			self:getCompressionHistoryTokenBudget(currentMemory) -- 873
		) -- 873
	) or math.min( -- 873
		self.config.maxTokensPerCompression, -- 876
		math.max( -- 877
			1, -- 877
			self:getRequiredCompressionTokens(messages) -- 877
		) -- 877
	) -- 877
	local accumulatedTokens = 0 -- 879
	local lastSafeBoundary = 0 -- 880
	local lastSafeBoundaryWithinBudget = 0 -- 881
	local lastClosedBoundary = 0 -- 882
	local lastClosedBoundaryWithinBudget = 0 -- 883
	local pendingToolCalls = {} -- 884
	local pendingToolCallCount = 0 -- 885
	do -- 885
		local i = 0 -- 887
		while i < #messages do -- 887
			local message = messages[i + 1] -- 888
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 889
			accumulatedTokens = accumulatedTokens + tokens -- 890
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 890
				do -- 890
					local j = 0 -- 893
					while j < #message.tool_calls do -- 893
						local toolCallEntry = message.tool_calls[j + 1] -- 894
						local idValue = toolCallEntry.id -- 895
						local id = type(idValue) == "string" and idValue or "" -- 896
						if id ~= "" and not pendingToolCalls[id] then -- 896
							pendingToolCalls[id] = true -- 898
							pendingToolCallCount = pendingToolCallCount + 1 -- 899
						end -- 899
						j = j + 1 -- 893
					end -- 893
				end -- 893
			end -- 893
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 893
				pendingToolCalls[message.tool_call_id] = false -- 905
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 906
			end -- 906
			local isAtEnd = i >= #messages - 1 -- 909
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 910
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 911
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 912
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 913
			if isSafeBoundary then -- 913
				lastSafeBoundary = i + 1 -- 915
				if accumulatedTokens <= targetTokens then -- 915
					lastSafeBoundaryWithinBudget = i + 1 -- 917
				end -- 917
			end -- 917
			if isClosedToolBoundary then -- 917
				lastClosedBoundary = i + 1 -- 921
				if accumulatedTokens <= targetTokens then -- 921
					lastClosedBoundaryWithinBudget = i + 1 -- 923
				end -- 923
			end -- 923
			if accumulatedTokens > targetTokens then -- 923
				if lastSafeBoundaryWithinBudget > 0 then -- 923
					return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 929
				end -- 929
				if boundaryMode == "budget_max" then -- 929
					if lastClosedBoundaryWithinBudget > 0 then -- 929
						return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 933
					end -- 933
					if lastClosedBoundary > 0 then -- 933
						return self:buildCarryBoundary(messages, lastClosedBoundary) -- 936
					end -- 936
				end -- 936
				if lastSafeBoundary > 0 then -- 936
					return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 940
				end -- 940
				if lastClosedBoundaryWithinBudget > 0 then -- 940
					return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 943
				end -- 943
				if lastClosedBoundary > 0 then -- 943
					return self:buildCarryBoundary(messages, lastClosedBoundary) -- 946
				end -- 946
				return { -- 948
					chunkEnd = math.min(#messages, 1), -- 948
					compressedCount = math.min(#messages, 1) -- 948
				} -- 948
			end -- 948
			i = i + 1 -- 887
		end -- 887
	end -- 887
	if lastSafeBoundaryWithinBudget > 0 then -- 887
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 953
	end -- 953
	if lastSafeBoundary > 0 then -- 953
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 956
	end -- 956
	if lastClosedBoundaryWithinBudget > 0 then -- 956
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 959
	end -- 959
	if lastClosedBoundary > 0 then -- 959
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 962
	end -- 962
	local fallback = math.min(#messages, 1) -- 964
	return {chunkEnd = fallback, compressedCount = fallback} -- 965
end -- 865
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 968
	local carryUserIndex = -1 -- 969
	do -- 969
		local i = 0 -- 970
		while i < chunkEnd do -- 970
			if messages[i + 1].role == "user" then -- 970
				carryUserIndex = i -- 972
			end -- 972
			i = i + 1 -- 970
		end -- 970
	end -- 970
	if carryUserIndex < 0 then -- 970
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 976
	end -- 976
	return { -- 978
		chunkEnd = chunkEnd, -- 979
		compressedCount = chunkEnd, -- 980
		carryMessage = __TS__ObjectAssign({}, messages[carryUserIndex + 1]) -- 981
	} -- 981
end -- 968
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 987
	local lines = {} -- 988
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 989
	if message.name and message.name ~= "" then -- 989
		lines[#lines + 1] = "name=" .. message.name -- 990
	end -- 990
	if message.tool_call_id and message.tool_call_id ~= "" then -- 990
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 991
	end -- 991
	if message.reasoning_content and message.reasoning_content ~= "" then -- 991
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 992
	end -- 992
	if message.tool_calls and #message.tool_calls > 0 then -- 992
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 994
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 995
	end -- 995
	if message.content and message.content ~= "" then -- 995
		lines[#lines + 1] = message.content -- 997
	end -- 997
	local prefix = index > 0 and "\n\n" or "" -- 998
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 999
end -- 987
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages) -- 1002
	local currentTokens = ____exports.TokenEstimator:estimate(self:formatMessagesForCompression(messages)) -- 1003
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 1004
	local overflow = math.max(0, currentTokens - threshold) -- 1005
	if overflow <= 0 then -- 1005
		return math.min( -- 1007
			self.config.maxTokensPerCompression, -- 1008
			math.max( -- 1009
				1, -- 1009
				self:estimateCompressionMessageTokens(messages[1], 0) -- 1009
			) -- 1009
		) -- 1009
	end -- 1009
	local safetyMargin = math.max( -- 1012
		64, -- 1012
		math.floor(threshold * 0.01) -- 1012
	) -- 1012
	return math.min(self.config.maxTokensPerCompression, overflow + safetyMargin) -- 1013
end -- 1002
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1016
	local lines = {} -- 1017
	do -- 1017
		local i = 0 -- 1018
		while i < #messages do -- 1018
			local message = messages[i + 1] -- 1019
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1020
			if message.name and message.name ~= "" then -- 1020
				lines[#lines + 1] = "name=" .. message.name -- 1021
			end -- 1021
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1021
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1022
			end -- 1022
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1022
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1023
			end -- 1023
			if message.tool_calls and #message.tool_calls > 0 then -- 1023
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1025
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1026
			end -- 1026
			if message.content and message.content ~= "" then -- 1026
				lines[#lines + 1] = message.content -- 1028
			end -- 1028
			if i < #messages - 1 then -- 1028
				lines[#lines + 1] = "" -- 1029
			end -- 1029
			i = i + 1 -- 1018
		end -- 1018
	end -- 1018
	return table.concat(lines, "\n") -- 1031
end -- 1016
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1037
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1037
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1045
		if decisionMode == "xml" then -- 1045
			return ____awaiter_resolve( -- 1045
				nil, -- 1045
				self:callLLMForCompressionByXML( -- 1047
					currentMemory, -- 1048
					boundedHistoryText, -- 1049
					llmOptions, -- 1050
					maxLLMTry, -- 1051
					debugContext -- 1052
				) -- 1052
			) -- 1052
		end -- 1052
		return ____awaiter_resolve( -- 1052
			nil, -- 1052
			self:callLLMForCompressionByToolCalling( -- 1055
				currentMemory, -- 1056
				boundedHistoryText, -- 1057
				llmOptions, -- 1058
				maxLLMTry, -- 1059
				debugContext -- 1060
			) -- 1060
		) -- 1060
	end) -- 1060
end -- 1037
function MemoryCompressor.prototype.getContextWindow(self) -- 1064
	return math.max(4000, self.config.llmConfig.contextWindow) -- 1065
end -- 1064
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1068
	local contextWindow = self:getContextWindow() -- 1069
	local reservedOutputTokens = math.max( -- 1070
		2048, -- 1070
		math.floor(contextWindow * 0.2) -- 1070
	) -- 1070
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1071
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1072
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1073
	return math.max( -- 1074
		1200, -- 1074
		math.floor(available * 0.9) -- 1074
	) -- 1074
end -- 1068
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1077
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1078
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1079
	if historyTokens <= tokenBudget then -- 1079
		return historyText -- 1080
	end -- 1080
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1081
	local targetChars = math.max( -- 1084
		2000, -- 1084
		math.floor(tokenBudget * charsPerToken) -- 1084
	) -- 1084
	local keepHead = math.max( -- 1085
		0, -- 1085
		math.floor(targetChars * 0.35) -- 1085
	) -- 1085
	local keepTail = math.max(0, targetChars - keepHead) -- 1086
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1087
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1088
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1089
end -- 1077
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1092
	local contextWindow = self:getContextWindow() -- 1096
	local reservedOutputTokens = math.max( -- 1097
		2048, -- 1097
		math.floor(contextWindow * 0.2) -- 1097
	) -- 1097
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1098
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1099
	local boundedMemory = clipTextToTokenBudget( -- 1100
		currentMemory or "(empty)", -- 1100
		math.max( -- 1100
			320, -- 1100
			math.floor(dynamicBudget * 0.35) -- 1100
		) -- 1100
	) -- 1100
	local boundedHistory = clipTextToTokenBudget( -- 1101
		historyText, -- 1101
		math.max( -- 1101
			800, -- 1101
			math.floor(dynamicBudget * 0.65) -- 1101
		) -- 1101
	) -- 1101
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 1102
end -- 1092
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1108
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1108
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1115
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 1118
		local messages = { -- 1142
			{ -- 1143
				role = "system", -- 1144
				content = self:buildToolCallingCompressionSystemPrompt() -- 1145
			}, -- 1145
			{role = "user", content = prompt} -- 1147
		} -- 1147
		local fn -- 1153
		local argsText = "" -- 1154
		do -- 1154
			local i = 0 -- 1155
			while i < maxLLMTry do -- 1155
				local ____opt_4 = debugContext and debugContext.onInput -- 1155
				if ____opt_4 ~= nil then -- 1155
					____opt_4( -- 1156
						debugContext, -- 1156
						"memory_compression_tool_calling", -- 1156
						messages, -- 1156
						__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 1156
					) -- 1156
				end -- 1156
				local response = __TS__Await(callLLM( -- 1162
					messages, -- 1163
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1164
					nil, -- 1169
					self.config.llmConfig -- 1170
				)) -- 1170
				if not response.success then -- 1170
					local ____opt_8 = debugContext and debugContext.onOutput -- 1170
					if ____opt_8 ~= nil then -- 1170
						____opt_8(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false}) -- 1174
					end -- 1174
					return ____awaiter_resolve(nil, { -- 1174
						success = false, -- 1176
						memoryUpdate = currentMemory, -- 1177
						historyEntry = "", -- 1178
						compressedCount = 0, -- 1179
						error = response.message -- 1180
					}) -- 1180
				end -- 1180
				local ____opt_12 = debugContext and debugContext.onOutput -- 1180
				if ____opt_12 ~= nil then -- 1180
					____opt_12( -- 1183
						debugContext, -- 1183
						"memory_compression_tool_calling", -- 1183
						encodeCompressionDebugJSON(response.response), -- 1183
						{success = true} -- 1183
					) -- 1183
				end -- 1183
				local choice = response.response.choices and response.response.choices[1] -- 1185
				local message = choice and choice.message -- 1186
				local toolCalls = message and message.tool_calls -- 1187
				local toolCall = toolCalls and toolCalls[1] -- 1188
				fn = toolCall and toolCall["function"] -- 1189
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1190
				if fn ~= nil and #argsText > 0 then -- 1190
					break -- 1191
				end -- 1191
				i = i + 1 -- 1155
			end -- 1155
		end -- 1155
		if not fn or fn.name ~= "save_memory" then -- 1155
			return ____awaiter_resolve(nil, { -- 1155
				success = false, -- 1196
				memoryUpdate = currentMemory, -- 1197
				historyEntry = "", -- 1198
				compressedCount = 0, -- 1199
				error = "missing save_memory tool call" -- 1200
			}) -- 1200
		end -- 1200
		if __TS__StringTrim(argsText) == "" then -- 1200
			return ____awaiter_resolve(nil, { -- 1200
				success = false, -- 1206
				memoryUpdate = currentMemory, -- 1207
				historyEntry = "", -- 1208
				compressedCount = 0, -- 1209
				error = "empty save_memory tool arguments" -- 1210
			}) -- 1210
		end -- 1210
		local ____try = __TS__AsyncAwaiter(function() -- 1210
			local args, err = safeJsonDecode(argsText) -- 1216
			if err ~= nil or not args or type(args) ~= "table" then -- 1216
				return ____awaiter_resolve( -- 1216
					nil, -- 1216
					{ -- 1218
						success = false, -- 1219
						memoryUpdate = currentMemory, -- 1220
						historyEntry = "", -- 1221
						compressedCount = 0, -- 1222
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1223
					} -- 1223
				) -- 1223
			end -- 1223
			return ____awaiter_resolve( -- 1223
				nil, -- 1223
				self:buildCompressionResultFromObject(args, currentMemory) -- 1227
			) -- 1227
		end) -- 1227
		__TS__Await(____try.catch( -- 1215
			____try, -- 1215
			function(____, ____error) -- 1215
				return ____awaiter_resolve( -- 1215
					nil, -- 1215
					{ -- 1232
						success = false, -- 1233
						memoryUpdate = currentMemory, -- 1234
						historyEntry = "", -- 1235
						compressedCount = 0, -- 1236
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1237
					} -- 1237
				) -- 1237
			end -- 1237
		)) -- 1237
	end) -- 1237
end -- 1108
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1242
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1242
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1249
		local lastError = "invalid xml response" -- 1250
		do -- 1250
			local i = 0 -- 1252
			while i < maxLLMTry do -- 1252
				do -- 1252
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1253
					local requestMessages = { -- 1258
						{ -- 1259
							role = "system", -- 1259
							content = self:buildXMLCompressionSystemPrompt() -- 1259
						}, -- 1259
						{role = "user", content = prompt .. feedback} -- 1260
					} -- 1260
					local ____opt_16 = debugContext and debugContext.onInput -- 1260
					if ____opt_16 ~= nil then -- 1260
						____opt_16(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1262
					end -- 1262
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1263
					if not response.success then -- 1263
						local ____opt_20 = debugContext and debugContext.onOutput -- 1263
						if ____opt_20 ~= nil then -- 1263
							____opt_20(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1271
						end -- 1271
						return ____awaiter_resolve(nil, { -- 1271
							success = false, -- 1273
							memoryUpdate = currentMemory, -- 1274
							historyEntry = "", -- 1275
							compressedCount = 0, -- 1276
							error = response.message -- 1277
						}) -- 1277
					end -- 1277
					local choice = response.response.choices and response.response.choices[1] -- 1281
					local message = choice and choice.message -- 1282
					local text = message and type(message.content) == "string" and message.content or "" -- 1283
					local ____opt_24 = debugContext and debugContext.onOutput -- 1283
					if ____opt_24 ~= nil then -- 1283
						____opt_24( -- 1284
							debugContext, -- 1284
							"memory_compression_xml", -- 1284
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1284
							{success = true} -- 1284
						) -- 1284
					end -- 1284
					if __TS__StringTrim(text) == "" then -- 1284
						lastError = "empty xml response" -- 1286
						goto __continue179 -- 1287
					end -- 1287
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1290
					if parsed.success then -- 1290
						return ____awaiter_resolve(nil, parsed) -- 1290
					end -- 1290
					lastError = parsed.error or "invalid xml response" -- 1294
				end -- 1294
				::__continue179:: -- 1294
				i = i + 1 -- 1252
			end -- 1252
		end -- 1252
		return ____awaiter_resolve(nil, { -- 1252
			success = false, -- 1298
			memoryUpdate = currentMemory, -- 1299
			historyEntry = "", -- 1300
			compressedCount = 0, -- 1301
			error = lastError -- 1302
		}) -- 1302
	end) -- 1302
end -- 1242
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1309
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1310
end -- 1309
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1316
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1317
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1318
end -- 1316
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 1324
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 1325
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 1328
end -- 1324
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 1335
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1336
end -- 1335
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 1341
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1342
end -- 1341
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1347
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1348
	if not parsed.success then -- 1348
		return { -- 1350
			success = false, -- 1351
			memoryUpdate = currentMemory, -- 1352
			historyEntry = "", -- 1353
			compressedCount = 0, -- 1354
			error = parsed.message -- 1355
		} -- 1355
	end -- 1355
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 1358
end -- 1347
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1364
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1368
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1369
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1369
		return { -- 1371
			success = false, -- 1372
			memoryUpdate = currentMemory, -- 1373
			historyEntry = "", -- 1374
			compressedCount = 0, -- 1375
			error = "missing history_entry or memory_update" -- 1376
		} -- 1376
	end -- 1376
	local ts = os.date("%Y-%m-%d %H:%M") -- 1379
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1380
end -- 1364
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1391
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1395
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1395
		self:rawArchive(chunk) -- 1398
		self.consecutiveFailures = 0 -- 1399
		return { -- 1401
			success = true, -- 1402
			memoryUpdate = self.storage:readMemory(), -- 1403
			historyEntry = "[RAW ARCHIVE] Detailed history not recorded", -- 1404
			compressedCount = #chunk -- 1405
		} -- 1405
	end -- 1405
	return { -- 1409
		success = false, -- 1410
		memoryUpdate = self.storage:readMemory(), -- 1411
		historyEntry = "", -- 1412
		compressedCount = 0, -- 1413
		error = ____error -- 1414
	} -- 1414
end -- 1391
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1421
	local ts = os.date("%Y-%m-%d %H:%M") -- 1422
	local firstUserMessage -- 1423
	do -- 1423
		local i = 0 -- 1424
		while i < #chunk do -- 1424
			if chunk[i + 1].role == "user" then -- 1424
				firstUserMessage = chunk[i + 1] -- 1426
				break -- 1427
			end -- 1427
			i = i + 1 -- 1424
		end -- 1424
	end -- 1424
	local prompt = firstUserMessage and firstUserMessage.content and __TS__StringTrim(firstUserMessage.content) ~= "" and __TS__StringReplace( -- 1430
		__TS__StringTrim(firstUserMessage.content), -- 1431
		"\n", -- 1431
		" " -- 1431
	) or "(empty prompt)" -- 1431
	local compactPrompt = #prompt > 160 and string.sub(prompt, 1, 160) .. "..." or prompt -- 1433
	self.storage:appendHistory(((((("[" .. ts) .. "] [RAW ARCHIVE] prompt=\"") .. compactPrompt) .. "\" (") .. tostring(#chunk)) .. " messages, compression failed; detailed history not recorded)") -- 1434
end -- 1421
function MemoryCompressor.prototype.getStorage(self) -- 1442
	return self.storage -- 1443
end -- 1442
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1446
	return math.max( -- 1447
		1, -- 1447
		math.floor(self.config.maxCompressionRounds) -- 1447
	) -- 1447
end -- 1446
MemoryCompressor.MAX_FAILURES = 3 -- 1446
return ____exports -- 1446