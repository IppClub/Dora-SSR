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
local ____Tools = require("Agent.Tools") -- 5
local sendWebIDEFileUpdate = ____Tools.sendWebIDEFileUpdate -- 5
local function isRecord(value) -- 7
	return type(value) == "table" -- 8
end -- 7
local function isArray(value) -- 11
	return __TS__ArrayIsArray(value) -- 12
end -- 11
local AGENT_CONFIG_DIR = ".agent" -- 29
local AGENT_PROMPTS_FILE = "AGENT.md" -- 30
local HISTORY_JSONL_FILE = "HISTORY.jsonl" -- 31
local HISTORY_MAX_RECORDS = 1000 -- 32
local XML_DECISION_SCHEMA_EXAMPLE = "```xml\n<tool_call>\n\t<tool>edit_file</tool>\n\t<reason>Need to update the file content to implement the requested change.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<old_str>\nfunction oldName() {\n\tprint(\"old\");\n}\n\t\t</old_str>\n\t\t<new_str>\nfunction newName() {\n\tprint(\"hello\");\n}\n\t\t</new_str>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>read_file</tool>\n\t<reason>Need to inspect the current implementation before editing.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<startLine>1</startLine>\n\t\t<endLine>200</endLine>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>finish</tool>\n\t<params>\n\t\t<message>Final user-facing answer.</message>\n\t</params>\n</tool_call>\n```" -- 33
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 90
	agentIdentityPrompt = "### Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 91
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. 0 is invalid.\n\t- startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 104
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 151
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 152
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 153
	xmlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 154
	xmlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. XML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 167
	xmlDecisionSystemRepairPrompt = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only.", -- 198
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph\n\t- Include key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.", -- 209
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n### Actions to Process\n\n{{HISTORY_TEXT}}", -- 238
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 245
	memoryCompressionXmlPrompt = "### Output Format\n\nReturn exactly one XML block:\n```xml\n<memory_update_result>\n\t<history_entry>Summary paragraph</history_entry>\n\t<memory_update>\nFull updated MEMORY.md content\n\t</memory_update>\n</memory_update_result>\n```\n\nRules:\n- Return XML only, no prose before or after.\n- Use exactly one root tag: `<memory_update_result>`.\n- Use exactly two child tags: `<history_entry>` and `<memory_update>`.\n- Use CDATA for `<memory_update>` when it spans multiple lines or contains markdown/code.", -- 250
	memoryCompressionXmlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid XML memory_update_result block only." -- 267
} -- 267
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn"} -- 270
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 270
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 270
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 276
local function replaceTemplateVars(template, vars) -- 281
	local output = template -- 282
	for key in pairs(vars) do -- 283
		output = table.concat( -- 284
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 284
			vars[key] or "" or "," -- 284
		) -- 284
	end -- 284
	return output -- 286
end -- 281
function ____exports.resolveAgentPromptPack(value) -- 289
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 290
	if value and not isArray(value) and isRecord(value) then -- 290
		do -- 290
			local i = 0 -- 294
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 294
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 295
				if type(value[key]) == "string" then -- 295
					merged[key] = value[key] -- 297
				end -- 297
				i = i + 1 -- 294
			end -- 294
		end -- 294
	end -- 294
	return merged -- 301
end -- 289
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 304
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 305
	local lines = {} -- 306
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 307
	lines[#lines + 1] = "" -- 308
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 309
	lines[#lines + 1] = "" -- 310
	do -- 310
		local i = 0 -- 311
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 311
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 312
			lines[#lines + 1] = "## " .. key -- 313
			local text = pack[key] -- 314
			local split = __TS__StringSplit(text, "\n") -- 315
			do -- 315
				local j = 0 -- 316
				while j < #split do -- 316
					lines[#lines + 1] = split[j + 1] -- 317
					j = j + 1 -- 316
				end -- 316
			end -- 316
			lines[#lines + 1] = "" -- 319
			i = i + 1 -- 311
		end -- 311
	end -- 311
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 321
end -- 304
local function getPromptPackConfigPath(projectRoot) -- 324
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 325
end -- 324
local function ensurePromptPackConfig(projectRoot) -- 328
	local path = getPromptPackConfigPath(projectRoot) -- 329
	if Content:exist(path) then -- 329
		return nil -- 330
	end -- 330
	local dir = Path:getPath(path) -- 331
	if not Content:exist(dir) then -- 331
		Content:mkdir(dir) -- 333
	end -- 333
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 335
	if not Content:save(path, content) then -- 335
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 337
	end -- 337
	sendWebIDEFileUpdate(path, true, content) -- 339
	return nil -- 340
end -- 328
local function parsePromptPackMarkdown(text) -- 343
	if not text or __TS__StringTrim(text) == "" then -- 343
		return { -- 350
			value = {}, -- 351
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 352
			unknown = {} -- 353
		} -- 353
	end -- 353
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 356
	local lines = __TS__StringSplit(normalized, "\n") -- 357
	local sections = {} -- 358
	local unknown = {} -- 359
	local currentHeading = "" -- 360
	local function isKnownPromptPackKey(name) -- 361
		do -- 361
			local i = 0 -- 362
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 362
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 362
					return true -- 363
				end -- 363
				i = i + 1 -- 362
			end -- 362
		end -- 362
		return false -- 365
	end -- 361
	do -- 361
		local i = 0 -- 367
		while i < #lines do -- 367
			do -- 367
				local line = lines[i + 1] -- 368
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 369
				if matchedHeading ~= nil then -- 369
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 371
					if isKnownPromptPackKey(heading) then -- 371
						currentHeading = heading -- 373
						if sections[currentHeading] == nil then -- 373
							sections[currentHeading] = {} -- 375
						end -- 375
						goto __continue29 -- 377
					end -- 377
					if currentHeading == "" then -- 377
						unknown[#unknown + 1] = heading -- 380
						goto __continue29 -- 381
					end -- 381
				end -- 381
				if currentHeading ~= "" then -- 381
					local ____sections_currentHeading_1 = sections[currentHeading] -- 381
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 385
				end -- 385
			end -- 385
			::__continue29:: -- 385
			i = i + 1 -- 367
		end -- 367
	end -- 367
	local value = {} -- 388
	local missing = {} -- 389
	do -- 389
		local i = 0 -- 390
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 390
			do -- 390
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 391
				local section = sections[key] -- 392
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 393
				if body == "" then -- 393
					missing[#missing + 1] = key -- 395
					goto __continue36 -- 396
				end -- 396
				value[key] = body -- 398
			end -- 398
			::__continue36:: -- 398
			i = i + 1 -- 390
		end -- 390
	end -- 390
	if #__TS__ObjectKeys(sections) == 0 then -- 390
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 401
	end -- 401
	return {value = value, missing = missing, unknown = unknown} -- 407
end -- 343
function ____exports.loadAgentPromptPack(projectRoot) -- 410
	local path = getPromptPackConfigPath(projectRoot) -- 411
	local warnings = {} -- 412
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 413
	if ensureWarning and ensureWarning ~= "" then -- 413
		warnings[#warnings + 1] = ensureWarning -- 415
	end -- 415
	if not Content:exist(path) then -- 415
		return { -- 418
			pack = ____exports.resolveAgentPromptPack(), -- 419
			warnings = warnings, -- 420
			path = path -- 421
		} -- 421
	end -- 421
	local text = Content:load(path) -- 424
	if not text or __TS__StringTrim(text) == "" then -- 424
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 426
		return { -- 427
			pack = ____exports.resolveAgentPromptPack(), -- 428
			warnings = warnings, -- 429
			path = path -- 430
		} -- 430
	end -- 430
	local parsed = parsePromptPackMarkdown(text) -- 433
	if parsed.error or not parsed.value then -- 433
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 435
		return { -- 436
			pack = ____exports.resolveAgentPromptPack(), -- 437
			warnings = warnings, -- 438
			path = path -- 439
		} -- 439
	end -- 439
	if #parsed.unknown > 0 then -- 439
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 443
	end -- 443
	if #parsed.missing > 0 then -- 443
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 446
	end -- 446
	return { -- 448
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 449
		warnings = warnings, -- 450
		path = path -- 451
	} -- 451
end -- 410
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 520
local TokenEstimator = ____exports.TokenEstimator -- 520
TokenEstimator.name = "TokenEstimator" -- 520
function TokenEstimator.prototype.____constructor(self) -- 520
end -- 520
function TokenEstimator.estimate(self, text) -- 524
	if not text then -- 524
		return 0 -- 525
	end -- 525
	return App:estimateTokens(text) -- 526
end -- 524
function TokenEstimator.estimateMessages(self, messages) -- 529
	if not messages or #messages == 0 then -- 529
		return 0 -- 530
	end -- 530
	local total = 0 -- 531
	do -- 531
		local i = 0 -- 532
		while i < #messages do -- 532
			local message = messages[i + 1] -- 533
			total = total + self:estimate(message.role or "") -- 534
			total = total + self:estimate(message.content or "") -- 535
			total = total + self:estimate(message.name or "") -- 536
			total = total + self:estimate(message.tool_call_id or "") -- 537
			total = total + self:estimate(message.reasoning_content or "") -- 538
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 539
			total = total + self:estimate(toolCallsText or "") -- 540
			total = total + 8 -- 541
			i = i + 1 -- 532
		end -- 532
	end -- 532
	return total -- 543
end -- 529
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 546
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 551
end -- 546
local function encodeCompressionDebugJSON(value) -- 559
	local text, err = safeJsonEncode(value) -- 560
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 561
end -- 559
local function utf8TakeHead(text, maxChars) -- 564
	if maxChars <= 0 or text == "" then -- 564
		return "" -- 565
	end -- 565
	local nextPos = utf8.offset(text, maxChars + 1) -- 566
	if nextPos == nil then -- 566
		return text -- 567
	end -- 567
	return string.sub(text, 1, nextPos - 1) -- 568
end -- 564
local function utf8TakeTail(text, maxChars) -- 571
	if maxChars <= 0 or text == "" then -- 571
		return "" -- 572
	end -- 572
	local charLen = utf8.len(text) -- 573
	if charLen == nil or charLen <= maxChars then -- 573
		return text -- 574
	end -- 574
	local startChar = math.max(1, charLen - maxChars + 1) -- 575
	local startPos = utf8.offset(text, startChar) -- 576
	if startPos == nil then -- 576
		return text -- 577
	end -- 577
	return string.sub(text, startPos) -- 578
end -- 571
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.jsonl (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 586
local DualLayerStorage = ____exports.DualLayerStorage -- 586
DualLayerStorage.name = "DualLayerStorage" -- 586
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 593
	self.projectDir = projectDir -- 594
	self.agentDir = Path(self.projectDir, ".agent") -- 595
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 596
	self.historyPath = Path(self.agentDir, HISTORY_JSONL_FILE) -- 597
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 598
	self:ensureAgentFiles() -- 599
end -- 593
function DualLayerStorage.prototype.ensureDir(self, dir) -- 602
	if not Content:exist(dir) then -- 602
		Content:mkdir(dir) -- 604
	end -- 604
end -- 602
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 608
	if Content:exist(path) then -- 608
		return false -- 609
	end -- 609
	self:ensureDir(Path:getPath(path)) -- 610
	if not Content:save(path, content) then -- 610
		return false -- 612
	end -- 612
	sendWebIDEFileUpdate(path, true, content) -- 614
	return true -- 615
end -- 608
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 618
	self:ensureDir(self.agentDir) -- 619
	self:ensureFile(self.memoryPath, "") -- 620
	self:ensureFile(self.historyPath, "") -- 621
end -- 618
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 624
	local text = safeJsonEncode(value) -- 625
	return text -- 626
end -- 624
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 629
	local value = safeJsonDecode(text) -- 630
	return value -- 631
end -- 629
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 634
	if not value or isArray(value) or not isRecord(value) then -- 634
		return nil -- 635
	end -- 635
	local row = value -- 636
	local role = type(row.role) == "string" and row.role or "" -- 637
	if role == "" then -- 637
		return nil -- 638
	end -- 638
	local message = {role = role} -- 639
	if type(row.content) == "string" then -- 639
		message.content = sanitizeUTF8(row.content) -- 640
	end -- 640
	if type(row.name) == "string" then -- 640
		message.name = sanitizeUTF8(row.name) -- 641
	end -- 641
	if type(row.tool_call_id) == "string" then -- 641
		message.tool_call_id = sanitizeUTF8(row.tool_call_id) -- 642
	end -- 642
	if type(row.reasoning_content) == "string" then -- 642
		message.reasoning_content = sanitizeUTF8(row.reasoning_content) -- 643
	end -- 643
	if type(row.timestamp) == "string" then -- 643
		message.timestamp = sanitizeUTF8(row.timestamp) -- 644
	end -- 644
	if isArray(row.tool_calls) then -- 644
		message.tool_calls = row.tool_calls -- 646
	end -- 646
	return message -- 648
end -- 634
function DualLayerStorage.prototype.decodeHistoryRecord(self, value) -- 651
	if not value or isArray(value) or not isRecord(value) then -- 651
		return nil -- 652
	end -- 652
	local row = value -- 653
	local ts = type(row.ts) == "string" and __TS__StringTrim(row.ts) ~= "" and sanitizeUTF8(row.ts) or "" -- 654
	local summary = type(row.summary) == "string" and __TS__StringTrim(row.summary) ~= "" and sanitizeUTF8(row.summary) or nil -- 657
	local rawArchive = type(row.rawArchive) == "string" and __TS__StringTrim(row.rawArchive) ~= "" and sanitizeUTF8(row.rawArchive) or nil -- 660
	if ts == "" or summary == nil and rawArchive == nil then -- 660
		return nil -- 663
	end -- 663
	local record = {ts = ts, summary = summary, rawArchive = rawArchive} -- 664
	return record -- 669
end -- 651
function DualLayerStorage.prototype.readHistoryRecords(self) -- 672
	if not Content:exist(self.historyPath) then -- 672
		return {} -- 674
	end -- 674
	local text = Content:load(self.historyPath) -- 676
	if not text or __TS__StringTrim(text) == "" then -- 676
		return {} -- 678
	end -- 678
	local lines = __TS__StringSplit(text, "\n") -- 680
	local records = {} -- 681
	do -- 681
		local i = 0 -- 682
		while i < #lines do -- 682
			do -- 682
				local line = __TS__StringTrim(lines[i + 1]) -- 683
				if line == "" then -- 683
					goto __continue87 -- 684
				end -- 684
				local decoded = self:decodeJsonLine(line) -- 685
				local record = self:decodeHistoryRecord(decoded) -- 686
				if record then -- 686
					records[#records + 1] = record -- 688
				end -- 688
			end -- 688
			::__continue87:: -- 688
			i = i + 1 -- 682
		end -- 682
	end -- 682
	return records -- 691
end -- 672
function DualLayerStorage.prototype.saveHistoryRecords(self, records) -- 694
	self:ensureDir(Path:getPath(self.historyPath)) -- 695
	local normalized = #records > HISTORY_MAX_RECORDS and __TS__ArraySlice(records, #records - HISTORY_MAX_RECORDS) or records -- 696
	local lines = {} -- 699
	do -- 699
		local i = 0 -- 700
		while i < #normalized do -- 700
			local line = self:encodeJsonLine(normalized[i + 1]) -- 701
			if line then -- 701
				lines[#lines + 1] = line -- 703
			end -- 703
			i = i + 1 -- 700
		end -- 700
	end -- 700
	local content = #lines > 0 and table.concat(lines, "\n") .. "\n" or "" -- 706
	Content:save(self.historyPath, content) -- 707
	sendWebIDEFileUpdate(self.historyPath, true, content) -- 708
end -- 694
function DualLayerStorage.prototype.readMemory(self) -- 716
	if not Content:exist(self.memoryPath) then -- 716
		return "" -- 718
	end -- 718
	return Content:load(self.memoryPath) -- 720
end -- 716
function DualLayerStorage.prototype.writeMemory(self, content) -- 726
	self:ensureDir(Path:getPath(self.memoryPath)) -- 727
	Content:save(self.memoryPath, content) -- 728
end -- 726
function DualLayerStorage.prototype.getMemoryContext(self) -- 734
	local memory = self:readMemory() -- 735
	if not memory then -- 735
		return "" -- 736
	end -- 736
	return "### Long-term Memory\n\n" .. memory -- 738
end -- 734
function DualLayerStorage.prototype.appendHistoryRecord(self, record) -- 745
	local records = self:readHistoryRecords() -- 746
	records[#records + 1] = record -- 747
	self:saveHistoryRecords(records) -- 748
end -- 745
function DualLayerStorage.prototype.readSessionState(self) -- 751
	if not Content:exist(self.sessionPath) then -- 751
		return {messages = {}} -- 753
	end -- 753
	local text = Content:load(self.sessionPath) -- 755
	if not text or __TS__StringTrim(text) == "" then -- 755
		return {messages = {}} -- 757
	end -- 757
	local lines = __TS__StringSplit(text, "\n") -- 759
	local messages = {} -- 760
	do -- 760
		local i = 0 -- 761
		while i < #lines do -- 761
			do -- 761
				local line = __TS__StringTrim(lines[i + 1]) -- 762
				if line == "" then -- 762
					goto __continue104 -- 763
				end -- 763
				local data = self:decodeJsonLine(line) -- 764
				if not data or isArray(data) or not isRecord(data) then -- 764
					goto __continue104 -- 765
				end -- 765
				local row = data -- 766
				local ____self_decodeConversationMessage_3 = self.decodeConversationMessage -- 767
				local ____row_message_2 = row.message -- 767
				if ____row_message_2 == nil then -- 767
					____row_message_2 = row -- 767
				end -- 767
				local message = ____self_decodeConversationMessage_3(self, ____row_message_2) -- 767
				if message then -- 767
					messages[#messages + 1] = message -- 769
				end -- 769
			end -- 769
			::__continue104:: -- 769
			i = i + 1 -- 761
		end -- 761
	end -- 761
	return {messages = messages} -- 772
end -- 751
function DualLayerStorage.prototype.writeSessionState(self, messages) -- 775
	if messages == nil then -- 775
		messages = {} -- 775
	end -- 775
	self:ensureDir(Path:getPath(self.sessionPath)) -- 776
	local lines = {} -- 777
	do -- 777
		local i = 0 -- 778
		while i < #messages do -- 778
			local line = self:encodeJsonLine({_type = "message", message = messages[i + 1]}) -- 779
			if line then -- 779
				lines[#lines + 1] = line -- 784
			end -- 784
			i = i + 1 -- 778
		end -- 778
	end -- 778
	local content = table.concat(lines, "\n") .. "\n" -- 787
	Content:save(self.sessionPath, content) -- 788
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 789
end -- 775
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 801
local MemoryCompressor = ____exports.MemoryCompressor -- 801
MemoryCompressor.name = "MemoryCompressor" -- 801
function MemoryCompressor.prototype.____constructor(self, config) -- 808
	self.consecutiveFailures = 0 -- 804
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 809
	do -- 809
		local i = 0 -- 810
		while i < #loadedPromptPack.warnings do -- 810
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 811
			i = i + 1 -- 810
		end -- 810
	end -- 810
	local overridePack = config.promptPack and not isArray(config.promptPack) and isRecord(config.promptPack) and config.promptPack or nil -- 813
	self.config = __TS__ObjectAssign( -- 816
		{}, -- 816
		config, -- 817
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 816
	) -- 816
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 823
end -- 808
function MemoryCompressor.prototype.getPromptPack(self) -- 826
	return self.config.promptPack -- 827
end -- 826
function MemoryCompressor.prototype.shouldCompress(self, messages, systemPrompt, toolDefinitions) -- 833
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 838
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 844
	return messageTokens > threshold -- 846
end -- 833
function MemoryCompressor.prototype.compress(self, messages, systemPrompt, toolDefinitions, llmOptions, maxLLMTry, decisionMode, debugContext, boundaryMode) -- 852
	if decisionMode == nil then -- 852
		decisionMode = "tool_calling" -- 858
	end -- 858
	if boundaryMode == nil then -- 858
		boundaryMode = "default" -- 860
	end -- 860
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 860
		local toCompress = messages -- 862
		if #toCompress == 0 then -- 862
			return ____awaiter_resolve(nil, nil) -- 862
		end -- 862
		local currentMemory = self.storage:readMemory() -- 864
		local boundary = self:findCompressionBoundary(toCompress, currentMemory, boundaryMode) -- 866
		local chunk = __TS__ArraySlice(toCompress, 0, boundary.chunkEnd) -- 871
		if #chunk == 0 then -- 871
			return ____awaiter_resolve(nil, nil) -- 871
		end -- 871
		local historyText = self:formatMessagesForCompression(chunk) -- 874
		local ____try = __TS__AsyncAwaiter(function() -- 874
			local result = __TS__Await(self:callLLMForCompression( -- 878
				currentMemory, -- 879
				historyText, -- 880
				llmOptions, -- 881
				maxLLMTry or 3, -- 882
				decisionMode, -- 883
				debugContext -- 884
			)) -- 884
			if result.success then -- 884
				self.storage:writeMemory(result.memoryUpdate) -- 889
				if result.ts then -- 889
					self.storage:appendHistoryRecord({ts = result.ts, summary = result.summary}) -- 891
				end -- 891
				self.consecutiveFailures = 0 -- 896
				return ____awaiter_resolve( -- 896
					nil, -- 896
					__TS__ObjectAssign({}, result, {compressedCount = boundary.compressedCount, carryMessage = boundary.carryMessage}) -- 898
				) -- 898
			end -- 898
			return ____awaiter_resolve( -- 898
				nil, -- 898
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 906
			) -- 906
		end) -- 906
		__TS__Await(____try.catch( -- 876
			____try, -- 876
			function(____, ____error) -- 876
				return ____awaiter_resolve( -- 876
					nil, -- 876
					self:handleCompressionFailure( -- 909
						chunk, -- 909
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 909
					) -- 909
				) -- 909
			end -- 909
		)) -- 909
	end) -- 909
end -- 852
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, currentMemory, boundaryMode) -- 918
	local targetTokens = boundaryMode == "budget_max" and math.max( -- 923
		1, -- 924
		self:getCompressionHistoryTokenBudget(currentMemory) -- 924
	) or math.max( -- 924
		1, -- 925
		self:getRequiredCompressionTokens(messages) -- 925
	) -- 925
	local accumulatedTokens = 0 -- 926
	local lastSafeBoundary = 0 -- 927
	local lastSafeBoundaryWithinBudget = 0 -- 928
	local lastClosedBoundary = 0 -- 929
	local lastClosedBoundaryWithinBudget = 0 -- 930
	local pendingToolCalls = {} -- 931
	local pendingToolCallCount = 0 -- 932
	local exceededBudget = false -- 933
	do -- 933
		local i = 0 -- 935
		while i < #messages do -- 935
			local message = messages[i + 1] -- 936
			local tokens = self:estimateCompressionMessageTokens(message, i) -- 937
			accumulatedTokens = accumulatedTokens + tokens -- 938
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 938
				do -- 938
					local j = 0 -- 941
					while j < #message.tool_calls do -- 941
						local toolCallEntry = message.tool_calls[j + 1] -- 942
						local idValue = toolCallEntry.id -- 943
						local id = type(idValue) == "string" and idValue or "" -- 944
						if id ~= "" and not pendingToolCalls[id] then -- 944
							pendingToolCalls[id] = true -- 946
							pendingToolCallCount = pendingToolCallCount + 1 -- 947
						end -- 947
						j = j + 1 -- 941
					end -- 941
				end -- 941
			end -- 941
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] then -- 941
				pendingToolCalls[message.tool_call_id] = false -- 953
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 954
			end -- 954
			local isAtEnd = i >= #messages - 1 -- 957
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 958
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 959
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 960
			local isClosedToolBoundary = pendingToolCallCount == 0 and i > 0 -- 961
			if isSafeBoundary then -- 961
				lastSafeBoundary = i + 1 -- 963
				if accumulatedTokens <= targetTokens then -- 963
					lastSafeBoundaryWithinBudget = i + 1 -- 965
				end -- 965
			end -- 965
			if isClosedToolBoundary then -- 965
				lastClosedBoundary = i + 1 -- 969
				if accumulatedTokens <= targetTokens then -- 969
					lastClosedBoundaryWithinBudget = i + 1 -- 971
				end -- 971
			end -- 971
			if accumulatedTokens > targetTokens and not exceededBudget then -- 971
				exceededBudget = true -- 976
			end -- 976
			if exceededBudget and isSafeBoundary then -- 976
				return self:buildCarryBoundary(messages, i + 1) -- 981
			end -- 981
			i = i + 1 -- 935
		end -- 935
	end -- 935
	if lastSafeBoundaryWithinBudget > 0 then -- 935
		return {chunkEnd = lastSafeBoundaryWithinBudget, compressedCount = lastSafeBoundaryWithinBudget} -- 986
	end -- 986
	if lastSafeBoundary > 0 then -- 986
		return {chunkEnd = lastSafeBoundary, compressedCount = lastSafeBoundary} -- 989
	end -- 989
	if lastClosedBoundaryWithinBudget > 0 then -- 989
		return self:buildCarryBoundary(messages, lastClosedBoundaryWithinBudget) -- 992
	end -- 992
	if lastClosedBoundary > 0 then -- 992
		return self:buildCarryBoundary(messages, lastClosedBoundary) -- 995
	end -- 995
	local fallback = math.min(#messages, 1) -- 997
	return {chunkEnd = fallback, compressedCount = fallback} -- 998
end -- 918
function MemoryCompressor.prototype.buildCarryBoundary(self, messages, chunkEnd) -- 1001
	local carryUserIndex = -1 -- 1002
	do -- 1002
		local i = 0 -- 1003
		while i < chunkEnd do -- 1003
			if messages[i + 1].role == "user" then -- 1003
				carryUserIndex = i -- 1005
			end -- 1005
			i = i + 1 -- 1003
		end -- 1003
	end -- 1003
	if carryUserIndex < 0 then -- 1003
		return {chunkEnd = chunkEnd, compressedCount = chunkEnd} -- 1009
	end -- 1009
	return { -- 1011
		chunkEnd = chunkEnd, -- 1012
		compressedCount = chunkEnd, -- 1013
		carryMessage = __TS__ObjectAssign({}, messages[carryUserIndex + 1]) -- 1014
	} -- 1014
end -- 1001
function MemoryCompressor.prototype.estimateCompressionMessageTokens(self, message, index) -- 1020
	local lines = {} -- 1021
	lines[#lines + 1] = (("Message " .. tostring(index + 1)) .. ": role=") .. message.role -- 1022
	if message.name and message.name ~= "" then -- 1022
		lines[#lines + 1] = "name=" .. message.name -- 1023
	end -- 1023
	if message.tool_call_id and message.tool_call_id ~= "" then -- 1023
		lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1024
	end -- 1024
	if message.reasoning_content and message.reasoning_content ~= "" then -- 1024
		lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1025
	end -- 1025
	if message.tool_calls and #message.tool_calls > 0 then -- 1025
		local toolCallsText = safeJsonEncode(message.tool_calls) -- 1027
		lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1028
	end -- 1028
	if message.content and message.content ~= "" then -- 1028
		lines[#lines + 1] = message.content -- 1030
	end -- 1030
	local prefix = index > 0 and "\n\n" or "" -- 1031
	return ____exports.TokenEstimator:estimate(prefix .. table.concat(lines, "\n")) -- 1032
end -- 1020
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages) -- 1035
	local currentTokens = ____exports.TokenEstimator:estimate(self:formatMessagesForCompression(messages)) -- 1036
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 1037
	local overflow = math.max(0, currentTokens - threshold) -- 1038
	if overflow <= 0 then -- 1038
		return math.max( -- 1040
			1, -- 1040
			self:estimateCompressionMessageTokens(messages[1], 0) -- 1040
		) -- 1040
	end -- 1040
	local safetyMargin = math.max( -- 1042
		64, -- 1042
		math.floor(threshold * 0.01) -- 1042
	) -- 1042
	return overflow + safetyMargin -- 1043
end -- 1035
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 1046
	local lines = {} -- 1047
	do -- 1047
		local i = 0 -- 1048
		while i < #messages do -- 1048
			local message = messages[i + 1] -- 1049
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 1050
			if message.name and message.name ~= "" then -- 1050
				lines[#lines + 1] = "name=" .. message.name -- 1051
			end -- 1051
			if message.tool_call_id and message.tool_call_id ~= "" then -- 1051
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 1052
			end -- 1052
			if message.reasoning_content and message.reasoning_content ~= "" then -- 1052
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 1053
			end -- 1053
			if message.tool_calls and #message.tool_calls > 0 then -- 1053
				local toolCallsText = safeJsonEncode(message.tool_calls) -- 1055
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 1056
			end -- 1056
			if message.content and message.content ~= "" then -- 1056
				lines[#lines + 1] = message.content -- 1058
			end -- 1058
			if i < #messages - 1 then -- 1058
				lines[#lines + 1] = "" -- 1059
			end -- 1059
			i = i + 1 -- 1048
		end -- 1048
	end -- 1048
	return table.concat(lines, "\n") -- 1061
end -- 1046
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode, debugContext) -- 1067
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1067
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 1075
		if decisionMode == "xml" then -- 1075
			return ____awaiter_resolve( -- 1075
				nil, -- 1075
				self:callLLMForCompressionByXML( -- 1077
					currentMemory, -- 1078
					boundedHistoryText, -- 1079
					llmOptions, -- 1080
					maxLLMTry, -- 1081
					debugContext -- 1082
				) -- 1082
			) -- 1082
		end -- 1082
		return ____awaiter_resolve( -- 1082
			nil, -- 1082
			self:callLLMForCompressionByToolCalling( -- 1085
				currentMemory, -- 1086
				boundedHistoryText, -- 1087
				llmOptions, -- 1088
				maxLLMTry, -- 1089
				debugContext -- 1090
			) -- 1090
		) -- 1090
	end) -- 1090
end -- 1067
function MemoryCompressor.prototype.getContextWindow(self) -- 1094
	return math.max(4000, self.config.llmConfig.contextWindow) -- 1095
end -- 1094
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 1098
	local contextWindow = self:getContextWindow() -- 1099
	local reservedOutputTokens = math.max( -- 1100
		2048, -- 1100
		math.floor(contextWindow * 0.2) -- 1100
	) -- 1100
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1101
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1102
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1103
	return math.max( -- 1104
		1200, -- 1104
		math.floor(available * 0.9) -- 1104
	) -- 1104
end -- 1098
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1107
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1108
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1109
	if historyTokens <= tokenBudget then -- 1109
		return historyText -- 1110
	end -- 1110
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1111
	local targetChars = math.max( -- 1114
		2000, -- 1114
		math.floor(tokenBudget * charsPerToken) -- 1114
	) -- 1114
	local keepHead = math.max( -- 1115
		0, -- 1115
		math.floor(targetChars * 0.35) -- 1115
	) -- 1115
	local keepTail = math.max(0, targetChars - keepHead) -- 1116
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1117
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1118
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1119
end -- 1107
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1122
	local contextWindow = self:getContextWindow() -- 1126
	local reservedOutputTokens = math.max( -- 1127
		2048, -- 1127
		math.floor(contextWindow * 0.2) -- 1127
	) -- 1127
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionStaticPrompt("tool_calling")) -- 1128
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1129
	local boundedMemory = clipTextToTokenBudget( -- 1130
		currentMemory or "(empty)", -- 1130
		math.max( -- 1130
			320, -- 1130
			math.floor(dynamicBudget * 0.35) -- 1130
		) -- 1130
	) -- 1130
	local boundedHistory = clipTextToTokenBudget( -- 1131
		historyText, -- 1131
		math.max( -- 1131
			800, -- 1131
			math.floor(dynamicBudget * 0.65) -- 1131
		) -- 1131
	) -- 1131
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 1132
end -- 1122
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1138
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1138
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1145
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 1148
		local messages = { -- 1172
			{ -- 1173
				role = "system", -- 1174
				content = self:buildToolCallingCompressionSystemPrompt() -- 1175
			}, -- 1175
			{role = "user", content = prompt} -- 1177
		} -- 1177
		local fn -- 1183
		local argsText = "" -- 1184
		do -- 1184
			local i = 0 -- 1185
			while i < maxLLMTry do -- 1185
				local ____opt_4 = debugContext and debugContext.onInput -- 1185
				if ____opt_4 ~= nil then -- 1185
					____opt_4( -- 1186
						debugContext, -- 1186
						"memory_compression_tool_calling", -- 1186
						messages, -- 1186
						__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 1186
					) -- 1186
				end -- 1186
				local response = __TS__Await(callLLM( -- 1192
					messages, -- 1193
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1194
					nil, -- 1199
					self.config.llmConfig -- 1200
				)) -- 1200
				if not response.success then -- 1200
					local ____opt_8 = debugContext and debugContext.onOutput -- 1200
					if ____opt_8 ~= nil then -- 1200
						____opt_8(debugContext, "memory_compression_tool_calling", response.raw or response.message, {success = false}) -- 1204
					end -- 1204
					return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1204
				end -- 1204
				local ____opt_12 = debugContext and debugContext.onOutput -- 1204
				if ____opt_12 ~= nil then -- 1204
					____opt_12( -- 1212
						debugContext, -- 1212
						"memory_compression_tool_calling", -- 1212
						encodeCompressionDebugJSON(response.response), -- 1212
						{success = true} -- 1212
					) -- 1212
				end -- 1212
				local choice = response.response.choices and response.response.choices[1] -- 1214
				local message = choice and choice.message -- 1215
				local toolCalls = message and message.tool_calls -- 1216
				local toolCall = toolCalls and toolCalls[1] -- 1217
				fn = toolCall and toolCall["function"] -- 1218
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1219
				if fn ~= nil and #argsText > 0 then -- 1219
					break -- 1220
				end -- 1220
				i = i + 1 -- 1185
			end -- 1185
		end -- 1185
		if not fn or fn.name ~= "save_memory" then -- 1185
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing save_memory tool call"}) -- 1185
		end -- 1185
		if __TS__StringTrim(argsText) == "" then -- 1185
			return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "empty save_memory tool arguments"}) -- 1185
		end -- 1185
		local ____try = __TS__AsyncAwaiter(function() -- 1185
			local args, err = safeJsonDecode(argsText) -- 1243
			if err ~= nil or not args or type(args) ~= "table" then -- 1243
				return ____awaiter_resolve( -- 1243
					nil, -- 1243
					{ -- 1245
						success = false, -- 1246
						memoryUpdate = currentMemory, -- 1247
						compressedCount = 0, -- 1248
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1249
					} -- 1249
				) -- 1249
			end -- 1249
			return ____awaiter_resolve( -- 1249
				nil, -- 1249
				self:buildCompressionResultFromObject(args, currentMemory) -- 1253
			) -- 1253
		end) -- 1253
		__TS__Await(____try.catch( -- 1242
			____try, -- 1242
			function(____, ____error) -- 1242
				return ____awaiter_resolve( -- 1242
					nil, -- 1242
					{ -- 1258
						success = false, -- 1259
						memoryUpdate = currentMemory, -- 1260
						compressedCount = 0, -- 1261
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1262
					} -- 1262
				) -- 1262
			end -- 1262
		)) -- 1262
	end) -- 1262
end -- 1138
function MemoryCompressor.prototype.callLLMForCompressionByXML(self, currentMemory, historyText, llmOptions, maxLLMTry, debugContext) -- 1267
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1267
		local prompt = self:buildCompressionPromptBody(currentMemory, historyText) -- 1274
		local lastError = "invalid xml response" -- 1275
		do -- 1275
			local i = 0 -- 1277
			while i < maxLLMTry do -- 1277
				do -- 1277
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionXmlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1278
					local requestMessages = { -- 1283
						{ -- 1284
							role = "system", -- 1284
							content = self:buildXMLCompressionSystemPrompt() -- 1284
						}, -- 1284
						{role = "user", content = prompt .. feedback} -- 1285
					} -- 1285
					local ____opt_16 = debugContext and debugContext.onInput -- 1285
					if ____opt_16 ~= nil then -- 1285
						____opt_16(debugContext, "memory_compression_xml", requestMessages, llmOptions) -- 1287
					end -- 1287
					local response = __TS__Await(callLLM(requestMessages, llmOptions, nil, self.config.llmConfig)) -- 1288
					if not response.success then -- 1288
						local ____opt_20 = debugContext and debugContext.onOutput -- 1288
						if ____opt_20 ~= nil then -- 1288
							____opt_20(debugContext, "memory_compression_xml", response.raw or response.message, {success = false}) -- 1296
						end -- 1296
						return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = response.message}) -- 1296
					end -- 1296
					local choice = response.response.choices and response.response.choices[1] -- 1305
					local message = choice and choice.message -- 1306
					local text = message and type(message.content) == "string" and message.content or "" -- 1307
					local ____opt_24 = debugContext and debugContext.onOutput -- 1307
					if ____opt_24 ~= nil then -- 1307
						____opt_24( -- 1308
							debugContext, -- 1308
							"memory_compression_xml", -- 1308
							text ~= "" and text or encodeCompressionDebugJSON(response.response), -- 1308
							{success = true} -- 1308
						) -- 1308
					end -- 1308
					if __TS__StringTrim(text) == "" then -- 1308
						lastError = "empty xml response" -- 1310
						goto __continue183 -- 1311
					end -- 1311
					local parsed = self:parseCompressionXMLObject(text, currentMemory) -- 1314
					if parsed.success then -- 1314
						return ____awaiter_resolve(nil, parsed) -- 1314
					end -- 1314
					lastError = parsed.error or "invalid xml response" -- 1318
				end -- 1318
				::__continue183:: -- 1318
				i = i + 1 -- 1277
			end -- 1277
		end -- 1277
		return ____awaiter_resolve(nil, {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = lastError}) -- 1277
	end) -- 1277
end -- 1267
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1332
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1333
end -- 1332
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1339
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1340
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1341
end -- 1339
function MemoryCompressor.prototype.buildCompressionStaticPrompt(self, mode) -- 1347
	local formatPrompt = mode == "xml" and self.config.promptPack.memoryCompressionXmlPrompt or self.config.promptPack.memoryCompressionToolCallingPrompt -- 1348
	return (((self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. formatPrompt) .. "\n\n") .. self:buildCompressionPromptBodyRaw("", "") -- 1351
end -- 1347
function MemoryCompressor.prototype.buildToolCallingCompressionSystemPrompt(self) -- 1358
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1359
end -- 1358
function MemoryCompressor.prototype.buildXMLCompressionSystemPrompt(self) -- 1364
	return (self.config.promptPack.memoryCompressionSystemPrompt .. "\n\n") .. self.config.promptPack.memoryCompressionXmlPrompt -- 1365
end -- 1364
function MemoryCompressor.prototype.parseCompressionXMLObject(self, text, currentMemory) -- 1370
	local parsed = parseXMLObjectFromText(text, "memory_update_result") -- 1371
	if not parsed.success then -- 1371
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = parsed.message} -- 1373
	end -- 1373
	return self:buildCompressionResultFromObject(parsed.obj, currentMemory) -- 1380
end -- 1370
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1386
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1390
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1391
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1391
		return {success = false, memoryUpdate = currentMemory, compressedCount = 0, error = "missing history_entry or memory_update"} -- 1393
	end -- 1393
	local ts = os.date("%Y-%m-%d %H:%M") -- 1400
	return { -- 1401
		success = true, -- 1402
		memoryUpdate = memoryBody, -- 1403
		ts = ts, -- 1404
		summary = historyEntry, -- 1405
		compressedCount = 0 -- 1406
	} -- 1406
end -- 1386
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1413
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1417
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1417
		local archived = self:rawArchive(chunk) -- 1420
		self.consecutiveFailures = 0 -- 1421
		return { -- 1423
			success = true, -- 1424
			memoryUpdate = self.storage:readMemory(), -- 1425
			ts = archived.ts, -- 1426
			compressedCount = #chunk -- 1427
		} -- 1427
	end -- 1427
	return { -- 1431
		success = false, -- 1432
		memoryUpdate = self.storage:readMemory(), -- 1433
		compressedCount = 0, -- 1434
		error = ____error -- 1435
	} -- 1435
end -- 1413
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1442
	local ts = os.date("%Y-%m-%d %H:%M") -- 1443
	local rawArchive = self:formatMessagesForCompression(chunk) -- 1444
	self.storage:appendHistoryRecord({ts = ts, rawArchive = rawArchive}) -- 1445
	return {ts = ts} -- 1449
end -- 1442
function MemoryCompressor.prototype.getStorage(self) -- 1455
	return self.storage -- 1456
end -- 1455
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1459
	return math.max( -- 1460
		1, -- 1460
		math.floor(self.config.maxCompressionRounds) -- 1460
	) -- 1460
end -- 1459
MemoryCompressor.MAX_FAILURES = 3 -- 1459
return ____exports -- 1459