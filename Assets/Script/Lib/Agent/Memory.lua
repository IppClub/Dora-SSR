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
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 82
	agentIdentityPrompt = "### Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 83
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. 0 is invalid.\n\t- startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 96
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 143
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 144
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 145
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 146
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 159
	xmlDecisionSystemRepairPrompt = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only.", -- 190
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph for HISTORY.md\n\t- Include timestamp and key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 201
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n### Actions to Process\n\n{{HISTORY_TEXT}}", -- 230
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 237
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update>\nFull updated MEMORY.md content\n\t</memory_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Use exactly two child tags: `<history_entry>` and `<memory_update>`.\n- Use CDATA for `<memory_update>` when it spans multiple lines or contains markdown/code.", -- 242
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 259
} -- 259
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn"} -- 262
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 262
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 262
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 268
local function replaceTemplateVars(template, vars) -- 273
	local output = template -- 274
	for key in pairs(vars) do -- 275
		output = table.concat( -- 276
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 276
			vars[key] or "" or "," -- 276
		) -- 276
	end -- 276
	return output -- 278
end -- 273
function ____exports.resolveAgentPromptPack(value) -- 281
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 282
	if value and not isArray(value) and isRecord(value) then -- 282
		do -- 282
			local i = 0 -- 286
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 286
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 287
				if type(value[key]) == "string" then -- 287
					merged[key] = value[key] -- 289
				end -- 289
				i = i + 1 -- 286
			end -- 286
		end -- 286
	end -- 286
	return merged -- 293
end -- 281
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 296
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 297
	local lines = {} -- 298
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 299
	lines[#lines + 1] = "" -- 300
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 301
	lines[#lines + 1] = "" -- 302
	do -- 302
		local i = 0 -- 303
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 303
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 304
			lines[#lines + 1] = "## " .. key -- 305
			local text = pack[key] -- 306
			local split = __TS__StringSplit(text, "\n") -- 307
			do -- 307
				local j = 0 -- 308
				while j < #split do -- 308
					lines[#lines + 1] = split[j + 1] -- 309
					j = j + 1 -- 308
				end -- 308
			end -- 308
			lines[#lines + 1] = "" -- 311
			i = i + 1 -- 303
		end -- 303
	end -- 303
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 313
end -- 296
local function getPromptPackConfigPath(projectRoot) -- 316
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 317
end -- 316
local function ensurePromptPackConfig(projectRoot) -- 320
	local path = getPromptPackConfigPath(projectRoot) -- 321
	if Content:exist(path) then -- 321
		return nil -- 322
	end -- 322
	local dir = Path:getPath(path) -- 323
	if not Content:exist(dir) then -- 323
		Content:mkdir(dir) -- 325
	end -- 325
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 327
	if not Content:save(path, content) then -- 327
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 329
	end -- 329
	sendWebIDEFileUpdate(path, true, content) -- 331
	return nil -- 332
end -- 320
local function parsePromptPackMarkdown(text) -- 335
	if not text or __TS__StringTrim(text) == "" then -- 335
		return { -- 342
			value = {}, -- 343
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 344
			unknown = {} -- 345
		} -- 345
	end -- 345
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 348
	local lines = __TS__StringSplit(normalized, "\n") -- 349
	local sections = {} -- 350
	local unknown = {} -- 351
	local currentHeading = "" -- 352
	local function isKnownPromptPackKey(name) -- 353
		do -- 353
			local i = 0 -- 354
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 354
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 354
					return true -- 355
				end -- 355
				i = i + 1 -- 354
			end -- 354
		end -- 354
		return false -- 357
	end -- 353
	do -- 353
		local i = 0 -- 359
		while i < #lines do -- 359
			do -- 359
				local line = lines[i + 1] -- 360
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 361
				if matchedHeading ~= nil then -- 361
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 363
					if isKnownPromptPackKey(heading) then -- 363
						currentHeading = heading -- 365
						if sections[currentHeading] == nil then -- 365
							sections[currentHeading] = {} -- 367
						end -- 367
						goto __continue29 -- 369
					end -- 369
					if currentHeading == "" then -- 369
						unknown[#unknown + 1] = heading -- 372
						goto __continue29 -- 373
					end -- 373
				end -- 373
				if currentHeading ~= "" then -- 373
					local ____sections_currentHeading_1 = sections[currentHeading] -- 373
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 377
				end -- 377
			end -- 377
			::__continue29:: -- 377
			i = i + 1 -- 359
		end -- 359
	end -- 359
	local value = {} -- 380
	local missing = {} -- 381
	do -- 381
		local i = 0 -- 382
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 382
			do -- 382
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 383
				local section = sections[key] -- 384
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 385
				if body == "" then -- 385
					missing[#missing + 1] = key -- 387
					goto __continue36 -- 388
				end -- 388
				value[key] = body -- 390
			end -- 390
			::__continue36:: -- 390
			i = i + 1 -- 382
		end -- 382
	end -- 382
	if #__TS__ObjectKeys(sections) == 0 then -- 382
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 393
	end -- 393
	return {value = value, missing = missing, unknown = unknown} -- 399
end -- 335
function ____exports.loadAgentPromptPack(projectRoot) -- 402
	local path = getPromptPackConfigPath(projectRoot) -- 403
	local warnings = {} -- 404
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 405
	if ensureWarning and ensureWarning ~= "" then -- 405
		warnings[#warnings + 1] = ensureWarning -- 407
	end -- 407
	if not Content:exist(path) then -- 407
		return { -- 410
			pack = ____exports.resolveAgentPromptPack(), -- 411
			warnings = warnings, -- 412
			path = path -- 413
		} -- 413
	end -- 413
	local text = Content:load(path) -- 416
	if not text or __TS__StringTrim(text) == "" then -- 416
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 418
		return { -- 419
			pack = ____exports.resolveAgentPromptPack(), -- 420
			warnings = warnings, -- 421
			path = path -- 422
		} -- 422
	end -- 422
	local parsed = parsePromptPackMarkdown(text) -- 425
	if parsed.error or not parsed.value then -- 425
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 427
		return { -- 428
			pack = ____exports.resolveAgentPromptPack(), -- 429
			warnings = warnings, -- 430
			path = path -- 431
		} -- 431
	end -- 431
	if #parsed.unknown > 0 then -- 431
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 435
	end -- 435
	if #parsed.missing > 0 then -- 435
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 438
	end -- 438
	return { -- 440
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 441
		warnings = warnings, -- 442
		path = path -- 443
	} -- 443
end -- 402
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 512
local TokenEstimator = ____exports.TokenEstimator -- 512
TokenEstimator.name = "TokenEstimator" -- 512
function TokenEstimator.prototype.____constructor(self) -- 512
end -- 512
function TokenEstimator.estimate(self, text) -- 516
	if not text then -- 516
		return 0 -- 517
	end -- 517
	return App:estimateTokens(text) -- 518
end -- 516
function TokenEstimator.estimateMessages(self, messages) -- 521
	if not messages or #messages == 0 then -- 521
		return 0 -- 522
	end -- 522
	local total = 0 -- 523
	do -- 523
		local i = 0 -- 524
		while i < #messages do -- 524
			local message = messages[i + 1] -- 525
			total = total + self:estimate(message.role or "") -- 526
			total = total + self:estimate(message.content or "") -- 527
			total = total + self:estimate(message.name or "") -- 528
			total = total + self:estimate(message.tool_call_id or "") -- 529
			total = total + self:estimate(message.reasoning_content or "") -- 530
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 531
			total = total + self:estimate(toolCallsText or "") -- 532
			total = total + 8 -- 533
			i = i + 1 -- 524
		end -- 524
	end -- 524
	return total -- 535
end -- 521
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 538
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 543
end -- 538
local function encodeCompressionDebugJSON(value) -- 551
	local text, err = safeJsonEncode(value) -- 552
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 553
end -- 551
local function utf8TakeHead(text, maxChars) -- 556
	if maxChars <= 0 or text == "" then -- 556
		return "" -- 557
	end -- 557
	local nextPos = utf8.offset(text, maxChars + 1) -- 558
	if nextPos == nil then -- 558
		return text -- 559
	end -- 559
	return string.sub(text, 1, nextPos - 1) -- 560
end -- 556
local function utf8TakeTail(text, maxChars) -- 563
	if maxChars <= 0 or text == "" then -- 563
		return "" -- 564
	end -- 564
	local charLen = utf8.len(text) -- 565
	if charLen == nil or charLen <= maxChars then -- 565
		return text -- 566
	end -- 566
	local startChar = math.max(1, charLen - maxChars + 1) -- 567
	local startPos = utf8.offset(text, startChar) -- 568
	if startPos == nil then -- 568
		return text -- 569
	end -- 569
	return string.sub(text, startPos) -- 570
end -- 563
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 578
local DualLayerStorage = ____exports.DualLayerStorage -- 578
DualLayerStorage.name = "DualLayerStorage" -- 578
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 585
	self.projectDir = projectDir -- 586
	self.agentDir = Path(self.projectDir, ".agent") -- 587
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 588
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 589
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 590
	self:ensureAgentFiles() -- 591
end -- 585
function DualLayerStorage.prototype.ensureDir(self, dir) -- 594
	if not Content:exist(dir) then -- 594
		Content:mkdir(dir) -- 596
	end -- 596
end -- 594
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 600
	if Content:exist(path) then -- 600
		return false -- 601
	end -- 601
	self:ensureDir(Path:getPath(path)) -- 602
	if not Content:save(path, content) then -- 602
		return false -- 604
	end -- 604
	sendWebIDEFileUpdate(path, true, content) -- 606
	return true -- 607
end -- 600
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 610
	self:ensureDir(self.agentDir) -- 611
	self:ensureFile(self.memoryPath, "") -- 612
	self:ensureFile(self.historyPath, "") -- 613
end -- 610
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 616
	local text = safeJsonEncode(value) -- 617
	return text -- 618
end -- 616
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 621
	local value = safeJsonDecode(text) -- 622
	return value -- 623
end -- 621
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 626
	if not value or isArray(value) or not isRecord(value) then -- 626
		return nil -- 627
	end -- 627
	local row = value -- 628
	local role = type(row.role) == "string" and row.role or "" -- 629
	if role == "" then -- 629
		return nil -- 630
	end -- 630
	local message = {role = role} -- 631
	if type(row.content) == "string" then -- 631
		message.content = sanitizeUTF8(row.content) -- 632
	end -- 632
	if type(row.name) == "string" then -- 632
		message.name = sanitizeUTF8(row.name) -- 633
	end -- 633
	if type(row.tool_call_id) == "string" then -- 633
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 634
	end -- 634
	if type(row.reasoning_content) == "string" then -- 634
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 635
	end -- 635
	if type(row.timestamp) == "string" then -- 635
		message.timestamp = sanitizeUTF8(row.timestamp) -- 636
	end -- 636
	if isArray(row.tool_calls) then -- 636
		message.tool_calls = row.tool_calls -- 638
	end -- 638
	return message -- 640
end -- 626
function DualLayerStorage.prototype.readMemory(self) -- 648
	if not Content:exist(self.memoryPath) then -- 648
		return "" -- 650
	end -- 650
	return Content:load(self.memoryPath) -- 652
end -- 648
function DualLayerStorage.prototype.writeMemory(self, content) -- 658
	self:ensureDir(Path:getPath(self.memoryPath)) -- 659
	Content:save(self.memoryPath, content) -- 660
end -- 658
function DualLayerStorage.prototype.getMemoryContext(self) -- 666
	local memory = self:readMemory() -- 667
	if not memory then -- 667
		return "" -- 668
	end -- 668
	return "### Long-term Memory\n\n" .. memory -- 670
end -- 666
function DualLayerStorage.prototype.appendHistory(self, entry) -- 680
	self:ensureDir(Path:getPath(self.historyPath)) -- 681
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 683
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 687
end -- 680
function DualLayerStorage.prototype.readHistory(self) -- 693
	if not Content:exist(self.historyPath) then -- 693
		return "" -- 695
	end -- 695
	return Content:load(self.historyPath) -- 697
end -- 693
function DualLayerStorage.prototype.readSessionState(self) -- 700
	if not Content:exist(self.sessionPath) then -- 700
		return {messages = {}} -- 702
	end -- 702
	local text = Content:load(self.sessionPath) -- 704
	if not text or __TS__StringTrim(text) == "" then -- 704
		return {messages = {}} -- 706
	end -- 706
	local lines = __TS__StringSplit(text, "\n") -- 708
	local messages = {} -- 709
	do -- 709
		local i = 0 -- 710
		while i < #lines do -- 710
			do -- 710
				local line = __TS__StringTrim(lines[i + 1]) -- 711
				if line == "" then -- 711
					goto __continue92 -- 712
				end -- 712
				local data = self:decodeJsonLine(line) -- 713
				if not data or isArray(data) or not isRecord(data) then -- 713
					goto __continue92 -- 714
				end -- 714
				local row = data -- 715
				local ____self_decodeConversationMessage_3 = self.decodeConversationMessage -- 716
				local ____row_message_2 = row.message -- 716
				if ____row_message_2 == nil then -- 716
					____row_message_2 = row -- 716
				end -- 716
				local message = ____self_decodeConversationMessage_3(self, ____row_message_2) -- 716
				if message then -- 716
					messages[#messages + 1] = message -- 718
				end -- 718
			end -- 718
			::__continue92:: -- 718
			i = i + 1 -- 710
		end -- 710
	end -- 710
	return {messages = messages} -- 721
end -- 700
function DualLayerStorage.prototype.writeSessionState(self, messages) -- 724
	if messages == nil then -- 724
		messages = {} -- 724
	end -- 724
	self:ensureDir(Path:getPath(self.sessionPath)) -- 725
	local lines = {} -- 726
	do -- 726
		local i = 0 -- 727
		while i < #messages do -- 727
			local line = self:encodeJsonLine({_type = "message", message = messages[i + 1]}) -- 728
			if line then -- 728
				lines[#lines + 1] = line -- 733
			end -- 733
			i = i + 1 -- 727
		end -- 727
	end -- 727
	local content = table.concat(lines, "\n") .. "\n" -- 736
	Content:save(self.sessionPath, content) -- 737
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 738
end -- 724
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 744
	local history = self:readHistory() -- 745
	if not history then -- 745
		return {} -- 746
	end -- 746
	local lines = __TS__StringSplit(history, "\n") -- 748
	local lowerKeyword = string.lower(keyword) -- 749
	return __TS__ArrayFilter( -- 751
		lines, -- 751
		function(____, line) return __TS__StringIncludes( -- 751
			string.lower(line), -- 752
			lowerKeyword -- 752
		) end -- 752
	) -- 752
end -- 744
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 765
local MemoryCompressor = ____exports.MemoryCompressor -- 765
MemoryCompressor.name = "MemoryCompressor" -- 765
function MemoryCompressor.prototype.____constructor(self, config) -- 772
	self.consecutiveFailures = 0 -- 768
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 773
	do -- 773
		local i = 0 -- 774
		while i < #loadedPromptPack.warnings do -- 774
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 775
			i = i + 1 -- 774
		end -- 774
	end -- 774
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 777
	self.config = __TS__ObjectAssign( -- 780
		{}, -- 780
		config, -- 781
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 780
	) -- 780
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 787
end -- 772
function MemoryCompressor.prototype.getPromptPack(self) -- 790
	return self.config.promptPack -- 791
end -- 790
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 797
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 802
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 808
	return messageTokens > threshold -- 810
end -- 797
function MemoryCompressor.prototype.compress(self, messages, systemPrompt, toolDefinitions, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode) -- 816
	if decisionMode == nil then -- 816
		decisionMode = "tool_calling" -- 822
	end -- 822
	if boundaryMode == nil then -- 822
		boundaryMode = "default" -- 824
	end -- 824
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 824
		local toCompress = messages -- 826
		if #toCompress == 0 then -- 826
			return ____awaiter_resolve(nil, nil) -- 826
		end -- 826
		local currentMemory = self.storage:readMemory() -- 828
		local boundary = self:findCompressionBoundary(toCompress, currentMemory, boundaryMode) -- 830
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 835
		if #chunk == 0 then -- 835
			return ____awaiter_resolve(nil, nil) -- 835
		end -- 835
		local historyText = self:formatMessagesForCompression(chunk) -- 838
		local ____try = __TS__AsyncAwaiter(function() -- 838
			local result = __TS__Await(self:callLLMForCompression( -- 842
				currentMemory, -- 843
				historyText, -- 844
				llmOptions, -- 845
				maxLLMTry or 3, -- 846
				decisionMode, -- 847
				debugContext -- 848
			)) -- 848
			if result.success then -- 848
				self.storage:writeMemory(result.memoryUpdate) -- 853
				self.storage:appendHistory(result.historyEntry) -- 854
				self.consecutiveFailures = 0 -- 855
				return ____awaiter_resolve( -- 855
					nil, -- 855
					__TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessage = boundary.carryMessage}) -- 857
				) -- 857
			end -- 857
			return ____awaiter_resolve( -- 857
				nil, -- 857
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 865
			) -- 865
		end) -- 865
		__TS__Await(____try.catch( -- 840
			____try, -- 840
			function(____, ____error) -- 840
				return ____awaiter_resolve( -- 840
					nil, -- 840
					self:handleCompressionFailure( -- 868
						chunk, -- 868
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 868
					) -- 868
				) -- 868
			end -- 868
		)) -- 868
	end) -- 868
end -- 816
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode) -- 877
	local targetTokens = boundaryMode == "budget_max" and math.min( -- 882
		self.config.maxTokensPerCompression, -- 884
		math.max( -- 885
			1, -- 885
			self:getCompressionHistoryTokenBudget(currentMemory) -- 885
		) -- 885
	) or math.min( -- 885
		self.config.maxTokensPerCompression, -- 888
		math.max( -- 889
			1, -- 889
			self:getRequiredCompressionTokens(messages) -- 889
		) -- 889
	) -- 889
	local accumulatedTokens = 0 -- 891
	local lastSafeBoundary = 0 -- 892
	local lastSafeBoundaryWithinBudget = 0 -- 893
	local lastClosedBoundary = 0 -- 894
	local lastClosedBoundaryWithinBudget = 0 -- 895
	local pendingToolCalls = {} -- 896
	local pendingToolCallCount = 0 -- 897
	local exceededBudget = false -- 898
	do -- 898
		local i = 0 -- 900
		while i < #messages do -- 900
			local message = messages[i + 1] -- 901
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 902
			accumulatedTokens = accumulatedTokens + tokens -- 903
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 903
				do -- 903
					local j = 0 -- 906
					while j < #message.tool_calls do -- 906
						local toolCallEntry = message.tool_calls[j + 1] -- 907
						local idValue = toolCallEntry.id -- 908
						local id = type(idValue) == "string" and idValue or "" -- 909
						if id ~= "" and not pendingToolCalls[id] then -- 909
							pendingToolCalls[id] = true -- 911
							pendingToolCallCount = pendingToolCallCount + 1 -- 912
						end -- 912
						j = j + 1 -- 906
					end -- 906
				end -- 906
			end -- 906
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 906
				pendingToolCalls[message.tool_call_id] = false -- 918
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 919
			end -- 919
			local isAtEnd = i >= #messages - 1 -- 922
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 923
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 924
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 925
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 926
			if isSafeBoundary then -- 926
				lastSafeBoundary = i + 1 -- 928
				if accumulatedTokens <= targetTokens then -- 928
					lastSafeBoundaryWithinBudget = i + 1 -- 930
				end -- 930
			end -- 930
			if isClosedToolBoundary then -- 930
				lastClosedBoundary = i + 1 -- 934
				if accumulatedTokens <= targetTokens then -- 934
					lastClosedBoundaryWithinBudget = i + 1 -- 936
				end -- 936
			end -- 936
			if accumulatedTokens > targetTokens and not exceededBudget then -- 936
				exceededBudget = true -- 941
			end -- 941
			if exceededBudget and isSafeBoundary then -- 941
				return self:buildCarryBoundary(messages, i + 1) -- 946
			end -- 946
			i = i + 1 -- 900
		end -- 900
	end -- 900
	if lastSafeBoundaryWithinBudget > 0 then -- 900
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 951
	end -- 951
	if lastSafeBoundary > 0 then -- 951
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 954
	end -- 954
	if lastClosedBoundaryWithinBudget > 0 then -- 954
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 957
	end -- 957
	if lastClosedBoundary > 0 then -- 957
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 960
	end -- 960
	local fallback = math.min(#messages, 1) -- 962
	return {chunkEnd = fallback, compressedCount = fallback} -- 963
end -- 877
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 966
	local carryUserIndex = -1 -- 967
	do -- 967
		local i = 0 -- 968
		while i < chunkEnd do -- 968
			if messages[i + 1].role == "user" then -- 968
				carryUserIndex = i -- 970
			end -- 970
			i = i + 1 -- 968
		end -- 968
	end -- 968
	if carryUserIndex < 0 then -- 968
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 974
	end -- 974
	return { -- 976
		chunkEnd = chunkEnd, -- 977
		compressedCount = chunkEnd, -- 978
		carryMessage = __TS__ObjectAssign({}, messages[carryUserIndex + 1]) -- 979
	} -- 979
end -- 966
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 985
	local lines = {} -- 986
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 987
	if message.name and message.name ~= "" then -- 987
		lines[#lines + 1] = "name=" .. message.name -- 988
	end -- 988
	if message.tool_call_id and message.tool_call_id ~= "" then -- 988
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 989
	end -- 989
	if message.reasoning_content and message.reasoning_content ~= "" then -- 989
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 990
	end -- 990
	if message.tool_calls and #message.tool_calls > 0 then -- 990
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 992
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 993
	end -- 993
	if message.content and message.content ~= "" then -- 993
		lines[#lines + 1] = message.content -- 995
	end -- 995
	local prefix = index > 0 and "\n\n" or "" -- 996
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 997
end -- 985
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages) -- 1000
	local currentTokens = ____exports.TokenEstimator:estimate(self:formatMessagesForCompression(messages)) -- 1001
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 1002
	local overflow = math.max(0, currentTokens - threshold) -- 1003
	if overflow <= 0 then -- 1003
		return math.min( -- 1005
			self.config.maxTokensPerCompression, -- 1006
			math.max( -- 1007
				1, -- 1007
				self:estimateCompressionMessageTokens(messages[1], 0) -- 1007
			) -- 1007
		) -- 1007
	end -- 1007
	local safetyMargin = math.max( -- 1010
		64, -- 1010
		math.floor(threshold * 0.01) -- 1010
	) -- 1010
	return math.min(self.config.maxTokensPerCompression, overflow + safetyMargin) -- 1011
end -- 1000
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1014
	local lines = {} -- 1015
	do -- 1015
		local i = 0 -- 1016
		while i < #messages do -- 1016
			local message = messages[i + 1] -- 1017
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1018
			if message.name and message.name ~= "" then -- 1018
				lines[#lines + 1] = "name=" .. message.name -- 1019
			end -- 1019
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1019
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1020
			end -- 1020
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1020
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1021
			end -- 1021
			if message.tool_calls and #message.tool_calls > 0 then -- 1021
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1023
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1024
			end -- 1024
			if message.content and message.content ~= "" then -- 1024
				lines[#lines + 1] = message.content -- 1026
			end -- 1026
			if i < #messages - 1 then -- 1026
				lines[#lines + 1] = "" -- 1027
			end -- 1027
			i = i + 1 -- 1016
		end -- 1016
	end -- 1016
	return table.concat(lines, "\n") -- 1029
end -- 1014
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1035
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1035
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1043
		if decisionMode == "xml" then -- 1043
			return ____awaiter_resolve( -- 1043
				nil, -- 1043
				self:callLLMForCompressionByXML( -- 1045
					currentMemory, -- 1046
					boundedHistoryText, -- 1047
					llmOptions, -- 1048
					maxLLMTry, -- 1049
					debugContext -- 1050
				) -- 1050
			) -- 1050
		end -- 1050
		return ____awaiter_resolve( -- 1050
			nil, -- 1050
			self:callLLMForCompressionByToolCalling( -- 1053
				currentMemory, -- 1054
				boundedHistoryText, -- 1055
				llmOptions, -- 1056
				maxLLMTry, -- 1057
				debugContext -- 1058
			) -- 1058
		) -- 1058
	end) -- 1058
end -- 1035
function MemoryCompressor.prototype.getContextWindow(self) -- 1062
	return math.max(4000, self.config.llmConfig.contextWindow) -- 1063
end -- 1062
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1066
	local contextWindow = self:getContextWindow() -- 1067
	local reservedOutputTokens = math.max( -- 1068
		2048, -- 1068
		math.floor(contextWindow * 0.2) -- 1068
	) -- 1068
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1069
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1070
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1071
	return math.max( -- 1072
		1200, -- 1072
		math.floor(available * 0.9) -- 1072
	) -- 1072
end -- 1066
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1075
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1076
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1077
	if historyTokens <= tokenBudget then -- 1077
		return historyText -- 1078
	end -- 1078
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1079
	local targetChars = math.max( -- 1082
		2000, -- 1082
		math.floor(tokenBudget * charsPerToken) -- 1082
	) -- 1082
	local keepHead = math.max( -- 1083
		0, -- 1083
		math.floor(targetChars * 0.35) -- 1083
	) -- 1083
	local keepTail = math.max(0, targetChars - keepHead) -- 1084
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1085
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1086
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1087
end -- 1075
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1090
	local contextWindow = self:getContextWindow() -- 1094
	local reservedOutputTokens = math.max( -- 1095
		2048, -- 1095
		math.floor(contextWindow * 0.2) -- 1095
	) -- 1095
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1096
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1097
	local boundedMemory = clipTextToTokenBudget( -- 1098
		currentMemory or "(empty)", -- 1098
		math.max( -- 1098
			320, -- 1098
			math.floor(dynamicBudget * 0.35) -- 1098
		) -- 1098
	) -- 1098
	local boundedHistory = clipTextToTokenBudget( -- 1099
		historyText, -- 1099
		math.max( -- 1099
			800, -- 1099
			math.floor(dynamicBudget * 0.65) -- 1099
		) -- 1099
	) -- 1099
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 1100
end -- 1090
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1106
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1106
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1113
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 1116
		local messages = { -- 1140
			{ -- 1141
				role = "system", -- 1142
				content = self:buildToolCallingCompressionSystemPrompt() -- 1143
			}, -- 1143
			{role = "user", content = prompt} -- 1145
		} -- 1145
		local fn -- 1151
		local argsText = "" -- 1152
		do -- 1152
			local i = 0 -- 1153
			while i < maxLLMTry do -- 1153
				local ____opt_4 = debugContext and debugContext.onInput -- 1153
				if ____opt_4 ~= nil then -- 1153
					____opt_4( -- 1154
						debugContext, -- 1154
						"memory_compression_tool_calling", -- 1154
						messages, -- 1154
						__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 1154
					) -- 1154
				end -- 1154
				local response = __TS__Await(callLLM( -- 1160
					messages, -- 1161
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1162
					nil, -- 1167
					self.config.llmConfig -- 1168
				)) -- 1168
				if not response.success then -- 1168
					local ____opt_8 = debugContext and debugContext.onOutput -- 1168
					if ____opt_8 ~= nil then -- 1168
						____opt_8(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false}) -- 1172
					end -- 1172
					return ____awaiter_resolve(nil, { -- 1172
						success = false, -- 1174
						memoryUpdate = currentMemory, -- 1175
						historyEntry = "", -- 1176
						compressedCount = 0, -- 1177
						error = response.message -- 1178
					}) -- 1178
				end -- 1178
				local ____opt_12 = debugContext and debugContext.onOutput -- 1178
				if ____opt_12 ~= nil then -- 1178
					____opt_12( -- 1181
						debugContext, -- 1181
						"memory_compression_tool_calling", -- 1181
						encodeCompressionDebugJSON(response.response), -- 1181
						{success = true} -- 1181
					) -- 1181
				end -- 1181
				local choice = response.response.choices and response.response.choices[1] -- 1183
				local message = choice and choice.message -- 1184
				local toolCalls = message and message.tool_calls -- 1185
				local toolCall = toolCalls and toolCalls[1] -- 1186
				fn = toolCall and toolCall["function"] -- 1187
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1188
				if fn ~= nil and #argsText > 0 then -- 1188
					break -- 1189
				end -- 1189
				i = i + 1 -- 1153
			end -- 1153
		end -- 1153
		if not fn or fn.name ~= "save_memory" then -- 1153
			return ____awaiter_resolve(nil, { -- 1153
				success = false, -- 1194
				memoryUpdate = currentMemory, -- 1195
				historyEntry = "", -- 1196
				compressedCount = 0, -- 1197
				error = "missing save_memory tool call" -- 1198
			}) -- 1198
		end -- 1198
		if __TS__StringTrim(argsText) == "" then -- 1198
			return ____awaiter_resolve(nil, { -- 1198
				success = false, -- 1204
				memoryUpdate = currentMemory, -- 1205
				historyEntry = "", -- 1206
				compressedCount = 0, -- 1207
				error = "empty save_memory tool arguments" -- 1208
			}) -- 1208
		end -- 1208
		local ____try = __TS__AsyncAwaiter(function() -- 1208
			local args, err = safeJsonDecode(argsText) -- 1214
			if err ~= nil or not args or type(args) ~= "table" then -- 1214
				return ____awaiter_resolve( -- 1214
					nil, -- 1214
					{ -- 1216
						success = false, -- 1217
						memoryUpdate = currentMemory, -- 1218
						historyEntry = "", -- 1219
						compressedCount = 0, -- 1220
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1221
					} -- 1221
				) -- 1221
			end -- 1221
			return ____awaiter_resolve( -- 1221
				nil, -- 1221
				self:buildCompressionResultFromObject(args, currentMemory) -- 1225
			) -- 1225
		end) -- 1225
		__TS__Await(____try.catch( -- 1213
			____try, -- 1213
			function(____, ____error) -- 1213
				return ____awaiter_resolve( -- 1213
					nil, -- 1213
					{ -- 1230
						success = false, -- 1231
						memoryUpdate = currentMemory, -- 1232
						historyEntry = "", -- 1233
						compressedCount = 0, -- 1234
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1235
					} -- 1235
				) -- 1235
			end -- 1235
		)) -- 1235
	end) -- 1235
end -- 1106
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1240
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1240
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1247
		local lastError = "invalid xml response" -- 1248
		do -- 1248
			local i = 0 -- 1250
			while i < maxLLMTry do -- 1250
				do -- 1250
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1251
					local requestMessages = { -- 1256
						{ -- 1257
							role = "system", -- 1257
							content = self:buildXMLCompressionSystemPrompt() -- 1257
						}, -- 1257
						{role = "user", content = prompt .. feedback} -- 1258
					} -- 1258
					local ____opt_16 = debugContext and debugContext.onInput -- 1258
					if ____opt_16 ~= nil then -- 1258
						____opt_16(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1260
					end -- 1260
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1261
					if not response.success then -- 1261
						local ____opt_20 = debugContext and debugContext.onOutput -- 1261
						if ____opt_20 ~= nil then -- 1261
							____opt_20(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1269
						end -- 1269
						return ____awaiter_resolve(nil, { -- 1269
							success = false, -- 1271
							memoryUpdate = currentMemory, -- 1272
							historyEntry = "", -- 1273
							compressedCount = 0, -- 1274
							error = response.message -- 1275
						}) -- 1275
					end -- 1275
					local choice = response.response.choices and response.response.choices[1] -- 1279
					local message = choice and choice.message -- 1280
					local text = message and type(message.content) == "string" and message.content or "" -- 1281
					local ____opt_24 = debugContext and debugContext.onOutput -- 1281
					if ____opt_24 ~= nil then -- 1281
						____opt_24( -- 1282
							debugContext, -- 1282
							"memory_compression_xml", -- 1282
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1282
							{success = true} -- 1282
						) -- 1282
					end -- 1282
					if __TS__StringTrim(text) == "" then -- 1282
						lastError = "empty xml response" -- 1284
						goto __continue173 -- 1285
					end -- 1285
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1288
					if parsed.success then -- 1288
						return ____awaiter_resolve(nil, parsed) -- 1288
					end -- 1288
					lastError = parsed.error or "invalid xml response" -- 1292
				end -- 1292
				::__continue173:: -- 1292
				i = i + 1 -- 1250
			end -- 1250
		end -- 1250
		return ____awaiter_resolve(nil, { -- 1250
			success = false, -- 1296
			memoryUpdate = currentMemory, -- 1297
			historyEntry = "", -- 1298
			compressedCount = 0, -- 1299
			error = lastError -- 1300
		}) -- 1300
	end) -- 1300
end -- 1240
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1307
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1308
end -- 1307
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1314
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1315
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1316
end -- 1314
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 1322
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 1323
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 1326
end -- 1322
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 1333
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1334
end -- 1333
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 1339
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1340
end -- 1339
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1345
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1346
	if not parsed.success then -- 1346
		return { -- 1348
			success = false, -- 1349
			memoryUpdate = currentMemory, -- 1350
			historyEntry = "", -- 1351
			compressedCount = 0, -- 1352
			error = parsed.message -- 1353
		} -- 1353
	end -- 1353
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 1356
end -- 1345
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1362
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1366
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1367
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1367
		return { -- 1369
			success = false, -- 1370
			memoryUpdate = currentMemory, -- 1371
			historyEntry = "", -- 1372
			compressedCount = 0, -- 1373
			error = "missing history_entry or memory_update" -- 1374
		} -- 1374
	end -- 1374
	local ts = os.date("%Y-%m-%d %H:%M") -- 1377
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1378
end -- 1362
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1389
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1393
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1393
		self:rawArchive(chunk) -- 1396
		self.consecutiveFailures = 0 -- 1397
		return { -- 1399
			success = true, -- 1400
			memoryUpdate = self.storage:readMemory(), -- 1401
			historyEntry = "[RAW ARCHIVE] Detailed history not recorded", -- 1402
			compressedCount = #chunk -- 1403
		} -- 1403
	end -- 1403
	return { -- 1407
		success = false, -- 1408
		memoryUpdate = self.storage:readMemory(), -- 1409
		historyEntry = "", -- 1410
		compressedCount = 0, -- 1411
		error = ____error -- 1412
	} -- 1412
end -- 1389
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1419
	local ts = os.date("%Y-%m-%d %H:%M") -- 1420
	local firstUserMessage -- 1421
	do -- 1421
		local i = 0 -- 1422
		while i < #chunk do -- 1422
			if chunk[i + 1].role == "user" then -- 1422
				firstUserMessage = chunk[i + 1] -- 1424
				break -- 1425
			end -- 1425
			i = i + 1 -- 1422
		end -- 1422
	end -- 1422
	local prompt = firstUserMessage and firstUserMessage.content and __TS__StringTrim(firstUserMessage.content) ~= "" and __TS__StringReplace( -- 1428
		__TS__StringTrim(firstUserMessage.content), -- 1429
		"\n", -- 1429
		" " -- 1429
	) or "(empty prompt)" -- 1429
	local compactPrompt = #prompt > 160 and string.sub(prompt, 1, 160) .. "..." or prompt -- 1431
	self.storage:appendHistory(((((("[" .. ts) .. "] [RAW ARCHIVE] prompt=\"") .. compactPrompt) .. "\" (") .. tostring(#chunk)) .. " messages, compression failed; detailed history not recorded)") -- 1432
end -- 1419
function MemoryCompressor.prototype.getStorage(self) -- 1440
	return self.storage -- 1441
end -- 1440
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1444
	return math.max( -- 1445
		1, -- 1445
		math.floor(self.config.maxCompressionRounds) -- 1445
	) -- 1445
end -- 1444
MemoryCompressor.MAX_FAILURES = 3 -- 1444
return ____exports -- 1444