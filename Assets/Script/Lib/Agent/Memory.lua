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
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Line starts with 1. startLine defaults to 1 and endLine defaults to 300.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 95
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 141
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 142
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 143
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 144
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 157
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph for HISTORY.md\n\t- Include timestamp and key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 188
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n### Actions to Process\n\n{{HISTORY_TEXT}}", -- 217
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 224
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update>\nFull updated MEMORY.md content\n\t</memory_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Use exactly two child tags: `<history_entry>` and `<memory_update>`.\n- Use CDATA for `<memory_update>` when it spans multiple lines or contains markdown/code.", -- 229
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 246
} -- 246
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn"} -- 249
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 249
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 249
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 255
local function replaceTemplateVars(template, vars) -- 260
	local output = template -- 261
	for key in pairs(vars) do -- 262
		output = table.concat( -- 263
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 263
			vars[key] or "" or "," -- 263
		) -- 263
	end -- 263
	return output -- 265
end -- 260
function ____exports.resolveAgentPromptPack(value) -- 268
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 269
	if value and not isArray(value) and isRecord(value) then -- 269
		do -- 269
			local i = 0 -- 273
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 273
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 274
				if type(value[key]) == "string" then -- 274
					merged[key] = value[key] -- 276
				end -- 276
				i = i + 1 -- 273
			end -- 273
		end -- 273
	end -- 273
	return merged -- 280
end -- 268
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 283
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 284
	local lines = {} -- 285
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 286
	lines[#lines + 1] = "" -- 287
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 288
	lines[#lines + 1] = "" -- 289
	do -- 289
		local i = 0 -- 290
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 290
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 291
			lines[#lines + 1] = "## " .. key -- 292
			local text = pack[key] -- 293
			local split = __TS__StringSplit(text, "\n") -- 294
			do -- 294
				local j = 0 -- 295
				while j < #split do -- 295
					lines[#lines + 1] = split[j + 1] -- 296
					j = j + 1 -- 295
				end -- 295
			end -- 295
			lines[#lines + 1] = "" -- 298
			i = i + 1 -- 290
		end -- 290
	end -- 290
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 300
end -- 283
local function getPromptPackConfigPath(projectRoot) -- 303
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 304
end -- 303
local function ensurePromptPackConfig(projectRoot) -- 307
	local path = getPromptPackConfigPath(projectRoot) -- 308
	if Content:exist(path) then -- 308
		return nil -- 309
	end -- 309
	local dir = Path:getPath(path) -- 310
	if not Content:exist(dir) then -- 310
		Content:mkdir(dir) -- 312
	end -- 312
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 314
	if not Content:save(path, content) then -- 314
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 316
	end -- 316
	sendWebIDEFileUpdate(path, true, content) -- 318
	return nil -- 319
end -- 307
local function parsePromptPackMarkdown(text) -- 322
	if not text or __TS__StringTrim(text) == "" then -- 322
		return { -- 329
			value = {}, -- 330
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 331
			unknown = {} -- 332
		} -- 332
	end -- 332
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 335
	local lines = __TS__StringSplit(normalized, "\n") -- 336
	local sections = {} -- 337
	local unknown = {} -- 338
	local currentHeading = "" -- 339
	local function isKnownPromptPackKey(name) -- 340
		do -- 340
			local i = 0 -- 341
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 341
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 341
					return true -- 342
				end -- 342
				i = i + 1 -- 341
			end -- 341
		end -- 341
		return false -- 344
	end -- 340
	do -- 340
		local i = 0 -- 346
		while i < #lines do -- 346
			do -- 346
				local line = lines[i + 1] -- 347
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 348
				if matchedHeading ~= nil then -- 348
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 350
					if isKnownPromptPackKey(heading) then -- 350
						currentHeading = heading -- 352
						if sections[currentHeading] == nil then -- 352
							sections[currentHeading] = {} -- 354
						end -- 354
						goto __continue29 -- 356
					end -- 356
					if currentHeading == "" then -- 356
						unknown[#unknown + 1] = heading -- 359
						goto __continue29 -- 360
					end -- 360
				end -- 360
				if currentHeading ~= "" then -- 360
					local ____sections_currentHeading_1 = sections[currentHeading] -- 360
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 364
				end -- 364
			end -- 364
			::__continue29:: -- 364
			i = i + 1 -- 346
		end -- 346
	end -- 346
	local value = {} -- 367
	local missing = {} -- 368
	do -- 368
		local i = 0 -- 369
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 369
			do -- 369
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 370
				local section = sections[key] -- 371
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 372
				if body == "" then -- 372
					missing[#missing + 1] = key -- 374
					goto __continue36 -- 375
				end -- 375
				value[key] = body -- 377
			end -- 377
			::__continue36:: -- 377
			i = i + 1 -- 369
		end -- 369
	end -- 369
	if #__TS__ObjectKeys(sections) == 0 then -- 369
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 380
	end -- 380
	return {value = value, missing = missing, unknown = unknown} -- 386
end -- 322
function ____exports.loadAgentPromptPack(projectRoot) -- 389
	local path = getPromptPackConfigPath(projectRoot) -- 390
	local warnings = {} -- 391
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 392
	if ensureWarning and ensureWarning ~= "" then -- 392
		warnings[#warnings + 1] = ensureWarning -- 394
	end -- 394
	if not Content:exist(path) then -- 394
		return { -- 397
			pack = ____exports.resolveAgentPromptPack(), -- 398
			warnings = warnings, -- 399
			path = path -- 400
		} -- 400
	end -- 400
	local text = Content:load(path) -- 403
	if not text or __TS__StringTrim(text) == "" then -- 403
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 405
		return { -- 406
			pack = ____exports.resolveAgentPromptPack(), -- 407
			warnings = warnings, -- 408
			path = path -- 409
		} -- 409
	end -- 409
	local parsed = parsePromptPackMarkdown(text) -- 412
	if parsed.error or not parsed.value then -- 412
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 414
		return { -- 415
			pack = ____exports.resolveAgentPromptPack(), -- 416
			warnings = warnings, -- 417
			path = path -- 418
		} -- 418
	end -- 418
	if #parsed.unknown > 0 then -- 418
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 422
	end -- 422
	if #parsed.missing > 0 then -- 422
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 425
	end -- 425
	return { -- 427
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 428
		warnings = warnings, -- 429
		path = path -- 430
	} -- 430
end -- 389
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 499
local TokenEstimator = ____exports.TokenEstimator -- 499
TokenEstimator.name = "TokenEstimator" -- 499
function TokenEstimator.prototype.____constructor(self) -- 499
end -- 499
function TokenEstimator.estimate(self, text) -- 503
	if not text then -- 503
		return 0 -- 504
	end -- 504
	return App:estimateTokens(text) -- 505
end -- 503
function TokenEstimator.estimateMessages(self, messages) -- 508
	if not messages or #messages == 0 then -- 508
		return 0 -- 509
	end -- 509
	local total = 0 -- 510
	do -- 510
		local i = 0 -- 511
		while i < #messages do -- 511
			local message = messages[i + 1] -- 512
			total = total + self:estimate(message.role or "") -- 513
			total = total + self:estimate(message.content or "") -- 514
			total = total + self:estimate(message.name or "") -- 515
			total = total + self:estimate(message.tool_call_id or "") -- 516
			total = total + self:estimate(message.reasoning_content or "") -- 517
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 518
			total = total + self:estimate(toolCallsText or "") -- 519
			total = total + 8 -- 520
			i = i + 1 -- 511
		end -- 511
	end -- 511
	return total -- 522
end -- 508
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 525
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 530
end -- 525
local function encodeCompressionDebugJSON(value) -- 538
	local text, err = safeJsonEncode(value) -- 539
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 540
end -- 538
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
		return {messages = {}} -- 689
	end -- 689
	local text = Content:load(self.sessionPath) -- 691
	if not text or __TS__StringTrim(text) == "" then -- 691
		return {messages = {}} -- 693
	end -- 693
	local lines = __TS__StringSplit(text, "\n") -- 695
	local messages = {} -- 696
	do -- 696
		local i = 0 -- 697
		while i < #lines do -- 697
			do -- 697
				local line = __TS__StringTrim(lines[i + 1]) -- 698
				if line == "" then -- 698
					goto __continue92 -- 699
				end -- 699
				local data = self:decodeJsonLine(line) -- 700
				if not data or isArray(data) or not isRecord(data) then -- 700
					goto __continue92 -- 701
				end -- 701
				local row = data -- 702
				local ____self_decodeConversationMessage_3 = self.decodeConversationMessage -- 703
				local ____row_message_2 = row.message -- 703
				if ____row_message_2 == nil then -- 703
					____row_message_2 = row -- 703
				end -- 703
				local message = ____self_decodeConversationMessage_3(self, ____row_message_2) -- 703
				if message then -- 703
					messages[#messages + 1] = message -- 705
				end -- 705
			end -- 705
			::__continue92:: -- 705
			i = i + 1 -- 697
		end -- 697
	end -- 697
	return {messages = messages} -- 708
end -- 687
function DualLayerStorage.prototype.writeSessionState(self, messages) -- 711
	if messages == nil then -- 711
		messages = {} -- 711
	end -- 711
	self:ensureDir(Path:getPath(self.sessionPath)) -- 712
	local lines = {} -- 713
	do -- 713
		local i = 0 -- 714
		while i < #messages do -- 714
			local line = self:encodeJsonLine({_type = "message", message = messages[i + 1]}) -- 715
			if line then -- 715
				lines[#lines + 1] = line -- 720
			end -- 720
			i = i + 1 -- 714
		end -- 714
	end -- 714
	local content = table.concat(lines, "\n") .. "\n" -- 723
	Content:save(self.sessionPath, content) -- 724
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 725
end -- 711
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 731
	local history = self:readHistory() -- 732
	if not history then -- 732
		return {} -- 733
	end -- 733
	local lines = __TS__StringSplit(history, "\n") -- 735
	local lowerKeyword = string.lower(keyword) -- 736
	return __TS__ArrayFilter( -- 738
		lines, -- 738
		function(____, line) return __TS__StringIncludes( -- 738
			string.lower(line), -- 739
			lowerKeyword -- 739
		) end -- 739
	) -- 739
end -- 731
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 752
local MemoryCompressor = ____exports.MemoryCompressor -- 752
MemoryCompressor.name = "MemoryCompressor" -- 752
function MemoryCompressor.prototype.____constructor(self, config) -- 759
	self.consecutiveFailures = 0 -- 755
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 760
	do -- 760
		local i = 0 -- 761
		while i < #loadedPromptPack.warnings do -- 761
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 762
			i = i + 1 -- 761
		end -- 761
	end -- 761
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 764
	self.config = __TS__ObjectAssign( -- 767
		{}, -- 767
		config, -- 768
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 767
	) -- 767
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 774
end -- 759
function MemoryCompressor.prototype.getPromptPack(self) -- 777
	return self.config.promptPack -- 778
end -- 777
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 784
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 789
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 795
	return messageTokens > threshold -- 797
end -- 784
function MemoryCompressor.prototype.compress(self, messages, systemPrompt, toolDefinitions, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode) -- 803
	if decisionMode == nil then -- 803
		decisionMode = "tool_calling" -- 809
	end -- 809
	if boundaryMode == nil then -- 809
		boundaryMode = "default" -- 811
	end -- 811
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 811
		local toCompress = messages -- 813
		if #toCompress == 0 then -- 813
			return ____awaiter_resolve(nil, nil) -- 813
		end -- 813
		local currentMemory = self.storage:readMemory() -- 815
		local boundary = self:findCompressionBoundary(toCompress, currentMemory, boundaryMode) -- 817
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 822
		if #chunk == 0 then -- 822
			return ____awaiter_resolve(nil, nil) -- 822
		end -- 822
		local historyText = self:formatMessagesForCompression(chunk) -- 825
		local ____try = __TS__AsyncAwaiter(function() -- 825
			local result = __TS__Await(self:callLLMForCompression( -- 829
				currentMemory, -- 830
				historyText, -- 831
				llmOptions, -- 832
				maxLLMTry or 3, -- 833
				decisionMode, -- 834
				debugContext -- 835
			)) -- 835
			if result.success then -- 835
				self.storage:writeMemory(result.memoryUpdate) -- 840
				self.storage:appendHistory(result.historyEntry) -- 841
				self.consecutiveFailures = 0 -- 842
				return ____awaiter_resolve( -- 842
					nil, -- 842
					__TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessage = boundary.carryMessage}) -- 844
				) -- 844
			end -- 844
			return ____awaiter_resolve( -- 844
				nil, -- 844
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 852
			) -- 852
		end) -- 852
		__TS__Await(____try.catch( -- 827
			____try, -- 827
			function(____, ____error) -- 827
				return ____awaiter_resolve( -- 827
					nil, -- 827
					self:handleCompressionFailure( -- 855
						chunk, -- 855
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 855
					) -- 855
				) -- 855
			end -- 855
		)) -- 855
	end) -- 855
end -- 803
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode) -- 864
	local targetTokens = boundaryMode == "budget_max" and math.min( -- 869
		self.config.maxTokensPerCompression, -- 871
		math.max( -- 872
			1, -- 872
			self:getCompressionHistoryTokenBudget(currentMemory) -- 872
		) -- 872
	) or math.min( -- 872
		self.config.maxTokensPerCompression, -- 875
		math.max( -- 876
			1, -- 876
			self:getRequiredCompressionTokens(messages) -- 876
		) -- 876
	) -- 876
	local accumulatedTokens = 0 -- 878
	local lastSafeBoundary = 0 -- 879
	local lastSafeBoundaryWithinBudget = 0 -- 880
	local lastClosedBoundary = 0 -- 881
	local lastClosedBoundaryWithinBudget = 0 -- 882
	local pendingToolCalls = {} -- 883
	local pendingToolCallCount = 0 -- 884
	do -- 884
		local i = 0 -- 886
		while i < #messages do -- 886
			local message = messages[i + 1] -- 887
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 888
			accumulatedTokens = accumulatedTokens + tokens -- 889
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 889
				do -- 889
					local j = 0 -- 892
					while j < #message.tool_calls do -- 892
						local toolCallEntry = message.tool_calls[j + 1] -- 893
						local idValue = toolCallEntry.id -- 894
						local id = type(idValue) == "string" and idValue or "" -- 895
						if id ~= "" and not pendingToolCalls[id] then -- 895
							pendingToolCalls[id] = true -- 897
							pendingToolCallCount = pendingToolCallCount + 1 -- 898
						end -- 898
						j = j + 1 -- 892
					end -- 892
				end -- 892
			end -- 892
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 892
				pendingToolCalls[message.tool_call_id] = false -- 904
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 905
			end -- 905
			local isAtEnd = i >= #messages - 1 -- 908
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 909
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 910
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 911
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 912
			if isSafeBoundary then -- 912
				lastSafeBoundary = i + 1 -- 914
				if accumulatedTokens <= targetTokens then -- 914
					lastSafeBoundaryWithinBudget = i + 1 -- 916
				end -- 916
			end -- 916
			if isClosedToolBoundary then -- 916
				lastClosedBoundary = i + 1 -- 920
				if accumulatedTokens <= targetTokens then -- 920
					lastClosedBoundaryWithinBudget = i + 1 -- 922
				end -- 922
			end -- 922
			if accumulatedTokens > targetTokens then -- 922
				if lastSafeBoundaryWithinBudget > 0 then -- 922
					return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 928
				end -- 928
				if boundaryMode == "budget_max" then -- 928
					if lastClosedBoundaryWithinBudget > 0 then -- 928
						return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 932
					end -- 932
					if lastClosedBoundary > 0 then -- 932
						return self:buildCarryBoundary(messages, lastClosedBoundary) -- 935
					end -- 935
				end -- 935
				if lastSafeBoundary > 0 then -- 935
					return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 939
				end -- 939
				if lastClosedBoundaryWithinBudget > 0 then -- 939
					return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 942
				end -- 942
				if lastClosedBoundary > 0 then -- 942
					return self:buildCarryBoundary(messages, lastClosedBoundary) -- 945
				end -- 945
				return { -- 947
					chunkEnd = math.min(#messages, 1), -- 947
					compressedCount = math.min(#messages, 1) -- 947
				} -- 947
			end -- 947
			i = i + 1 -- 886
		end -- 886
	end -- 886
	if lastSafeBoundaryWithinBudget > 0 then -- 886
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 952
	end -- 952
	if lastSafeBoundary > 0 then -- 952
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 955
	end -- 955
	if lastClosedBoundaryWithinBudget > 0 then -- 955
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 958
	end -- 958
	if lastClosedBoundary > 0 then -- 958
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 961
	end -- 961
	local fallback = math.min(#messages, 1) -- 963
	return {chunkEnd = fallback, compressedCount = fallback} -- 964
end -- 864
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 967
	local carryUserIndex = -1 -- 968
	do -- 968
		local i = 0 -- 969
		while i < chunkEnd do -- 969
			if messages[i + 1].role == "user" then -- 969
				carryUserIndex = i -- 971
			end -- 971
			i = i + 1 -- 969
		end -- 969
	end -- 969
	if carryUserIndex < 0 then -- 969
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 975
	end -- 975
	return { -- 977
		chunkEnd = chunkEnd, -- 978
		compressedCount = chunkEnd, -- 979
		carryMessage = __TS__ObjectAssign({}, messages[carryUserIndex + 1]) -- 980
	} -- 980
end -- 967
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 986
	local lines = {} -- 987
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 988
	if message.name and message.name ~= "" then -- 988
		lines[#lines + 1] = "name=" .. message.name -- 989
	end -- 989
	if message.tool_call_id and message.tool_call_id ~= "" then -- 989
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 990
	end -- 990
	if message.reasoning_content and message.reasoning_content ~= "" then -- 990
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 991
	end -- 991
	if message.tool_calls and #message.tool_calls > 0 then -- 991
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 993
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 994
	end -- 994
	if message.content and message.content ~= "" then -- 994
		lines[#lines + 1] = message.content -- 996
	end -- 996
	local prefix = index > 0 and "\n\n" or "" -- 997
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 998
end -- 986
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages) -- 1001
	local currentTokens = ____exports.TokenEstimator:estimate(self:formatMessagesForCompression(messages)) -- 1002
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 1003
	local overflow = math.max(0, currentTokens - threshold) -- 1004
	if overflow <= 0 then -- 1004
		return math.min( -- 1006
			self.config.maxTokensPerCompression, -- 1007
			math.max( -- 1008
				1, -- 1008
				self:estimateCompressionMessageTokens(messages[1], 0) -- 1008
			) -- 1008
		) -- 1008
	end -- 1008
	local safetyMargin = math.max( -- 1011
		64, -- 1011
		math.floor(threshold * 0.01) -- 1011
	) -- 1011
	return math.min(self.config.maxTokensPerCompression, overflow + safetyMargin) -- 1012
end -- 1001
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1015
	local lines = {} -- 1016
	do -- 1016
		local i = 0 -- 1017
		while i < #messages do -- 1017
			local message = messages[i + 1] -- 1018
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1019
			if message.name and message.name ~= "" then -- 1019
				lines[#lines + 1] = "name=" .. message.name -- 1020
			end -- 1020
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1020
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1021
			end -- 1021
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1021
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1022
			end -- 1022
			if message.tool_calls and #message.tool_calls > 0 then -- 1022
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1024
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1025
			end -- 1025
			if message.content and message.content ~= "" then -- 1025
				lines[#lines + 1] = message.content -- 1027
			end -- 1027
			if i < #messages - 1 then -- 1027
				lines[#lines + 1] = "" -- 1028
			end -- 1028
			i = i + 1 -- 1017
		end -- 1017
	end -- 1017
	return table.concat(lines, "\n") -- 1030
end -- 1015
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1036
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1036
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1044
		if decisionMode == "xml" then -- 1044
			return ____awaiter_resolve( -- 1044
				nil, -- 1044
				self:callLLMForCompressionByXML( -- 1046
					currentMemory, -- 1047
					boundedHistoryText, -- 1048
					llmOptions, -- 1049
					maxLLMTry, -- 1050
					debugContext -- 1051
				) -- 1051
			) -- 1051
		end -- 1051
		return ____awaiter_resolve( -- 1051
			nil, -- 1051
			self:callLLMForCompressionByToolCalling( -- 1054
				currentMemory, -- 1055
				boundedHistoryText, -- 1056
				llmOptions, -- 1057
				maxLLMTry, -- 1058
				debugContext -- 1059
			) -- 1059
		) -- 1059
	end) -- 1059
end -- 1036
function MemoryCompressor.prototype.getContextWindow(self) -- 1063
	return math.max(4000, self.config.llmConfig.contextWindow) -- 1064
end -- 1063
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1067
	local contextWindow = self:getContextWindow() -- 1068
	local reservedOutputTokens = math.max( -- 1069
		2048, -- 1069
		math.floor(contextWindow * 0.2) -- 1069
	) -- 1069
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1070
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1071
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1072
	return math.max( -- 1073
		1200, -- 1073
		math.floor(available * 0.9) -- 1073
	) -- 1073
end -- 1067
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1076
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1077
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1078
	if historyTokens <= tokenBudget then -- 1078
		return historyText -- 1079
	end -- 1079
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1080
	local targetChars = math.max( -- 1083
		2000, -- 1083
		math.floor(tokenBudget * charsPerToken) -- 1083
	) -- 1083
	local keepHead = math.max( -- 1084
		0, -- 1084
		math.floor(targetChars * 0.35) -- 1084
	) -- 1084
	local keepTail = math.max(0, targetChars - keepHead) -- 1085
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1086
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1087
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1088
end -- 1076
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1091
	local contextWindow = self:getContextWindow() -- 1095
	local reservedOutputTokens = math.max( -- 1096
		2048, -- 1096
		math.floor(contextWindow * 0.2) -- 1096
	) -- 1096
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1097
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1098
	local boundedMemory = clipTextToTokenBudget( -- 1099
		currentMemory or "(empty)", -- 1099
		math.max( -- 1099
			320, -- 1099
			math.floor(dynamicBudget * 0.35) -- 1099
		) -- 1099
	) -- 1099
	local boundedHistory = clipTextToTokenBudget( -- 1100
		historyText, -- 1100
		math.max( -- 1100
			800, -- 1100
			math.floor(dynamicBudget * 0.65) -- 1100
		) -- 1100
	) -- 1100
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 1101
end -- 1091
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1107
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1107
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1114
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 1117
		local messages = { -- 1141
			{ -- 1142
				role = "system", -- 1143
				content = self:buildToolCallingCompressionSystemPrompt() -- 1144
			}, -- 1144
			{role = "user", content = prompt} -- 1146
		} -- 1146
		local fn -- 1152
		local argsText = "" -- 1153
		do -- 1153
			local i = 0 -- 1154
			while i < maxLLMTry do -- 1154
				local ____opt_4 = debugContext and debugContext.onInput -- 1154
				if ____opt_4 ~= nil then -- 1154
					____opt_4( -- 1155
						debugContext, -- 1155
						"memory_compression_tool_calling", -- 1155
						messages, -- 1155
						__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 1155
					) -- 1155
				end -- 1155
				local response = __TS__Await(callLLM( -- 1161
					messages, -- 1162
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1163
					nil, -- 1168
					self.config.llmConfig -- 1169
				)) -- 1169
				if not response.success then -- 1169
					local ____opt_8 = debugContext and debugContext.onOutput -- 1169
					if ____opt_8 ~= nil then -- 1169
						____opt_8(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false}) -- 1173
					end -- 1173
					return ____awaiter_resolve(nil, { -- 1173
						success = false, -- 1175
						memoryUpdate = currentMemory, -- 1176
						historyEntry = "", -- 1177
						compressedCount = 0, -- 1178
						error = response.message -- 1179
					}) -- 1179
				end -- 1179
				local ____opt_12 = debugContext and debugContext.onOutput -- 1179
				if ____opt_12 ~= nil then -- 1179
					____opt_12( -- 1182
						debugContext, -- 1182
						"memory_compression_tool_calling", -- 1182
						encodeCompressionDebugJSON(response.response), -- 1182
						{success = true} -- 1182
					) -- 1182
				end -- 1182
				local choice = response.response.choices and response.response.choices[1] -- 1184
				local message = choice and choice.message -- 1185
				local toolCalls = message and message.tool_calls -- 1186
				local toolCall = toolCalls and toolCalls[1] -- 1187
				fn = toolCall and toolCall["function"] -- 1188
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1189
				if fn ~= nil and #argsText > 0 then -- 1189
					break -- 1190
				end -- 1190
				i = i + 1 -- 1154
			end -- 1154
		end -- 1154
		if not fn or fn.name ~= "save_memory" then -- 1154
			return ____awaiter_resolve(nil, { -- 1154
				success = false, -- 1195
				memoryUpdate = currentMemory, -- 1196
				historyEntry = "", -- 1197
				compressedCount = 0, -- 1198
				error = "missing save_memory tool call" -- 1199
			}) -- 1199
		end -- 1199
		if __TS__StringTrim(argsText) == "" then -- 1199
			return ____awaiter_resolve(nil, { -- 1199
				success = false, -- 1205
				memoryUpdate = currentMemory, -- 1206
				historyEntry = "", -- 1207
				compressedCount = 0, -- 1208
				error = "empty save_memory tool arguments" -- 1209
			}) -- 1209
		end -- 1209
		local ____try = __TS__AsyncAwaiter(function() -- 1209
			local args, err = safeJsonDecode(argsText) -- 1215
			if err ~= nil or not args or type(args) ~= "table" then -- 1215
				return ____awaiter_resolve( -- 1215
					nil, -- 1215
					{ -- 1217
						success = false, -- 1218
						memoryUpdate = currentMemory, -- 1219
						historyEntry = "", -- 1220
						compressedCount = 0, -- 1221
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1222
					} -- 1222
				) -- 1222
			end -- 1222
			return ____awaiter_resolve( -- 1222
				nil, -- 1222
				self:buildCompressionResultFromObject(args, currentMemory) -- 1226
			) -- 1226
		end) -- 1226
		__TS__Await(____try.catch( -- 1214
			____try, -- 1214
			function(____, ____error) -- 1214
				return ____awaiter_resolve( -- 1214
					nil, -- 1214
					{ -- 1231
						success = false, -- 1232
						memoryUpdate = currentMemory, -- 1233
						historyEntry = "", -- 1234
						compressedCount = 0, -- 1235
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1236
					} -- 1236
				) -- 1236
			end -- 1236
		)) -- 1236
	end) -- 1236
end -- 1107
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1241
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1241
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1248
		local lastError = "invalid xml response" -- 1249
		do -- 1249
			local i = 0 -- 1251
			while i < maxLLMTry do -- 1251
				do -- 1251
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1252
					local requestMessages = { -- 1257
						{ -- 1258
							role = "system", -- 1258
							content = self:buildXMLCompressionSystemPrompt() -- 1258
						}, -- 1258
						{role = "user", content = prompt .. feedback} -- 1259
					} -- 1259
					local ____opt_16 = debugContext and debugContext.onInput -- 1259
					if ____opt_16 ~= nil then -- 1259
						____opt_16(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1261
					end -- 1261
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1262
					if not response.success then -- 1262
						local ____opt_20 = debugContext and debugContext.onOutput -- 1262
						if ____opt_20 ~= nil then -- 1262
							____opt_20(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1270
						end -- 1270
						return ____awaiter_resolve(nil, { -- 1270
							success = false, -- 1272
							memoryUpdate = currentMemory, -- 1273
							historyEntry = "", -- 1274
							compressedCount = 0, -- 1275
							error = response.message -- 1276
						}) -- 1276
					end -- 1276
					local choice = response.response.choices and response.response.choices[1] -- 1280
					local message = choice and choice.message -- 1281
					local text = message and type(message.content) == "string" and message.content or "" -- 1282
					local ____opt_24 = debugContext and debugContext.onOutput -- 1282
					if ____opt_24 ~= nil then -- 1282
						____opt_24( -- 1283
							debugContext, -- 1283
							"memory_compression_xml", -- 1283
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1283
							{success = true} -- 1283
						) -- 1283
					end -- 1283
					if __TS__StringTrim(text) == "" then -- 1283
						lastError = "empty xml response" -- 1285
						goto __continue179 -- 1286
					end -- 1286
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1289
					if parsed.success then -- 1289
						return ____awaiter_resolve(nil, parsed) -- 1289
					end -- 1289
					lastError = parsed.error or "invalid xml response" -- 1293
				end -- 1293
				::__continue179:: -- 1293
				i = i + 1 -- 1251
			end -- 1251
		end -- 1251
		return ____awaiter_resolve(nil, { -- 1251
			success = false, -- 1297
			memoryUpdate = currentMemory, -- 1298
			historyEntry = "", -- 1299
			compressedCount = 0, -- 1300
			error = lastError -- 1301
		}) -- 1301
	end) -- 1301
end -- 1241
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1308
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1309
end -- 1308
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1315
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1316
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1317
end -- 1315
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 1323
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 1324
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 1327
end -- 1323
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 1334
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1335
end -- 1334
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 1340
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1341
end -- 1340
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1346
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1347
	if not parsed.success then -- 1347
		return { -- 1349
			success = false, -- 1350
			memoryUpdate = currentMemory, -- 1351
			historyEntry = "", -- 1352
			compressedCount = 0, -- 1353
			error = parsed.message -- 1354
		} -- 1354
	end -- 1354
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 1357
end -- 1346
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1363
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1367
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1368
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1368
		return { -- 1370
			success = false, -- 1371
			memoryUpdate = currentMemory, -- 1372
			historyEntry = "", -- 1373
			compressedCount = 0, -- 1374
			error = "missing history_entry or memory_update" -- 1375
		} -- 1375
	end -- 1375
	local ts = os.date("%Y-%m-%d %H:%M") -- 1378
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1379
end -- 1363
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1390
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1394
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1394
		self:rawArchive(chunk) -- 1397
		self.consecutiveFailures = 0 -- 1398
		return { -- 1400
			success = true, -- 1401
			memoryUpdate = self.storage:readMemory(), -- 1402
			historyEntry = "[RAW ARCHIVE] Detailed history not recorded", -- 1403
			compressedCount = #chunk -- 1404
		} -- 1404
	end -- 1404
	return { -- 1408
		success = false, -- 1409
		memoryUpdate = self.storage:readMemory(), -- 1410
		historyEntry = "", -- 1411
		compressedCount = 0, -- 1412
		error = ____error -- 1413
	} -- 1413
end -- 1390
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1420
	local ts = os.date("%Y-%m-%d %H:%M") -- 1421
	local firstUserMessage -- 1422
	do -- 1422
		local i = 0 -- 1423
		while i < #chunk do -- 1423
			if chunk[i + 1].role == "user" then -- 1423
				firstUserMessage = chunk[i + 1] -- 1425
				break -- 1426
			end -- 1426
			i = i + 1 -- 1423
		end -- 1423
	end -- 1423
	local prompt = firstUserMessage and firstUserMessage.content and __TS__StringTrim(firstUserMessage.content) ~= "" and __TS__StringReplace( -- 1429
		__TS__StringTrim(firstUserMessage.content), -- 1430
		"\n", -- 1430
		" " -- 1430
	) or "(empty prompt)" -- 1430
	local compactPrompt = #prompt > 160 and string.sub(prompt, 1, 160) .. "..." or prompt -- 1432
	self.storage:appendHistory(((((("[" .. ts) .. "] [RAW ARCHIVE] prompt=\"") .. compactPrompt) .. "\" (") .. tostring(#chunk)) .. " messages, compression failed; detailed history not recorded)") -- 1433
end -- 1420
function MemoryCompressor.prototype.getStorage(self) -- 1441
	return self.storage -- 1442
end -- 1441
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1445
	return math.max( -- 1446
		1, -- 1446
		math.floor(self.config.maxCompressionRounds) -- 1446
	) -- 1446
end -- 1445
MemoryCompressor.MAX_FAILURES = 3 -- 1445
return ____exports -- 1445