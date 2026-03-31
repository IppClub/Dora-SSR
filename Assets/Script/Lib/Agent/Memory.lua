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
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local json = ____Dora.json -- 2
local ____Utils = require("Agent.Utils") -- 3
local callLLM = ____Utils.callLLM -- 3
local Log = ____Utils.Log -- 3
local clipTextToTokenBudget = ____Utils.clipTextToTokenBudget -- 3
local ____Tools = require("Agent.Tools") -- 5
local sendWebIDEFileUpdate = ____Tools.sendWebIDEFileUpdate -- 5
local yaml = require("yaml") -- 6
local AGENT_CONFIG_DIR = ".agent" -- 17
local AGENT_PROMPTS_FILE = "AGENT.md" -- 18
local YAML_DECISION_SCHEMA_EXAMPLE = "```xml\n<tool_call>\n\t<tool>edit_file</tool>\n\t<reason>Need to update the file content to implement the requested change.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<old_str>\nfunction oldName() {\n\tprint(\"old\");\n}\n\t\t</old_str>\n\t\t<new_str>\nfunction newName() {\n\tprint(\"hello\");\n}\n\t\t</new_str>\n  </params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>read_file</tool>\n\t<reason>Need to inspect the current implementation before editing.</reason>\n\t<params>\n\t\t<path>relative/path.ts</path>\n\t\t<startLine>1</startLine>\n\t\t<endLine>200</endLine>\n\t</params>\n</tool_call>\n```\n\n```xml\n<tool_call>\n\t<tool>finish</tool>\n\t<params>\n\t\t<message>Final user-facing answer.</message>\n\t</params>\n</tool_call>\n```" -- 19
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 75
	agentIdentityPrompt = "### Dora Agent\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 76
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Line starts with 1. startLine defaults to 1 and endLine defaults to 300.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 89
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 135
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 136
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 137
	yamlDecisionFormatPrompt = ("Respond with exactly one XML tool_call block. Do not include any prose before or after the XML.\n\n" .. YAML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one `<tool_call>...</tool_call>` block.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>`. Do not include `<reason>`.\n- Inside `<params>`, use one child tag per parameter, for example `<path>`, `<old_str>`, `<new_str>`.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- You do not need to escape normal code snippets, angle brackets, or newlines inside tag contents.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool finish and put the final user-facing answer in `<params><message>...</message></params>`.", -- 138
	yamlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid XML tool_call block.\n\nXML schema example:\n" .. YAML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one XML `<tool_call>...</tool_call>` block.\n- Return XML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, include `<tool>`, `<reason>`, and `<params>`.\n- For finish, include `<tool>` and `<params>` only.\n- Inside `<params>`, use one child tag per parameter.\n- All tag contents are treated as raw text by the parser. Preserve formatting exactly. Do not wrap content in CDATA unless needed explicitly.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid XML tool_call block.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return XML only, with no prose before or after.", -- 151
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.", -- 182
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n---\n\n### Actions to Process\n\n{{HISTORY_TEXT}}\n\n---\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph for HISTORY.md\n\t- Include timestamp and key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.",
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 222
	memoryCompressionYamlPrompt = "### Output Format\n\nReturn exactly one YAML object:\n```yaml\nhistory_entry: \"Summary paragraph\"\nmemory_update: |-\n\tFull updated MEMORY.md content\n```\n\nRules:\n- Return YAML only, no prose before or after.\n- Use exactly two keys: history_entry, memory_update.\n- Use a block scalar for memory_update when it spans multiple lines.", -- 227
	memoryCompressionYamlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid YAML object only." -- 240
} -- 240
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn", "memoryCompressionBodyPrompt"} -- 243
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 243
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 243
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 250
local function replaceTemplateVars(template, vars) -- 255
	local output = template -- 256
	for key in pairs(vars) do -- 257
		output = table.concat( -- 258
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 258
			vars[key] or "" or "," -- 258
		) -- 258
	end -- 258
	return output -- 260
end -- 255
function ____exports.resolveAgentPromptPack(value) -- 263
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 264
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 264
		do -- 264
			local i = 0 -- 268
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 268
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 269
				if type(value[key]) == "string" then -- 269
					merged[key] = value[key] -- 271
				end -- 271
				i = i + 1 -- 268
			end -- 268
		end -- 268
	end -- 268
	return merged -- 275
end -- 263
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 278
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 279
	local lines = {} -- 280
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 281
	lines[#lines + 1] = "" -- 282
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 283
	lines[#lines + 1] = "" -- 284
	do -- 284
		local i = 0 -- 285
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 285
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 286
			lines[#lines + 1] = "## " .. key -- 287
			local text = pack[key] -- 288
			local split = __TS__StringSplit(text, "\n") -- 289
			do -- 289
				local j = 0 -- 290
				while j < #split do -- 290
					lines[#lines + 1] = split[j + 1] -- 291
					j = j + 1 -- 290
				end -- 290
			end -- 290
			lines[#lines + 1] = "" -- 293
			i = i + 1 -- 285
		end -- 285
	end -- 285
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 295
end -- 278
local function getPromptPackConfigPath(projectRoot) -- 298
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 299
end -- 298
local function ensurePromptPackConfig(projectRoot) -- 302
	local path = getPromptPackConfigPath(projectRoot) -- 303
	if Content:exist(path) then -- 303
		return nil -- 304
	end -- 304
	local dir = Path:getPath(path) -- 305
	if not Content:exist(dir) then -- 305
		Content:mkdir(dir) -- 307
	end -- 307
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 309
	if not Content:save(path, content) then -- 309
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 311
	end -- 311
	sendWebIDEFileUpdate(path, true, content) -- 313
	return nil -- 314
end -- 302
local function parsePromptPackMarkdown(text) -- 317
	if not text or __TS__StringTrim(text) == "" then -- 317
		return { -- 324
			value = {}, -- 325
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 326
			unknown = {} -- 327
		} -- 327
	end -- 327
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 330
	local lines = __TS__StringSplit(normalized, "\n") -- 331
	local sections = {} -- 332
	local unknown = {} -- 333
	local currentHeading = "" -- 334
	local function isKnownPromptPackKey(name) -- 335
		do -- 335
			local i = 0 -- 336
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 336
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 336
					return true -- 337
				end -- 337
				i = i + 1 -- 336
			end -- 336
		end -- 336
		return false -- 339
	end -- 335
	do -- 335
		local i = 0 -- 341
		while i < #lines do -- 341
			do -- 341
				local line = lines[i + 1] -- 342
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 343
				if matchedHeading ~= nil then -- 343
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 345
					if isKnownPromptPackKey(heading) then -- 345
						currentHeading = heading -- 347
						if sections[currentHeading] == nil then -- 347
							sections[currentHeading] = {} -- 349
						end -- 349
						goto __continue27 -- 351
					end -- 351
					if currentHeading == "" then -- 351
						unknown[#unknown + 1] = heading -- 354
						goto __continue27 -- 355
					end -- 355
				end -- 355
				if currentHeading ~= "" then -- 355
					local ____sections_currentHeading_1 = sections[currentHeading] -- 355
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 359
				end -- 359
			end -- 359
			::__continue27:: -- 359
			i = i + 1 -- 341
		end -- 341
	end -- 341
	local value = {} -- 362
	local missing = {} -- 363
	do -- 363
		local i = 0 -- 364
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 364
			do -- 364
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 365
				local section = sections[key] -- 366
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 367
				if body == "" then -- 367
					missing[#missing + 1] = key -- 369
					goto __continue34 -- 370
				end -- 370
				value[key] = body -- 372
			end -- 372
			::__continue34:: -- 372
			i = i + 1 -- 364
		end -- 364
	end -- 364
	if #__TS__ObjectKeys(sections) == 0 then -- 364
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 375
	end -- 375
	return {value = value, missing = missing, unknown = unknown} -- 381
end -- 317
function ____exports.loadAgentPromptPack(projectRoot) -- 384
	local path = getPromptPackConfigPath(projectRoot) -- 385
	local warnings = {} -- 386
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 387
	if ensureWarning and ensureWarning ~= "" then -- 387
		warnings[#warnings + 1] = ensureWarning -- 389
	end -- 389
	if not Content:exist(path) then -- 389
		return { -- 392
			pack = ____exports.resolveAgentPromptPack(), -- 393
			warnings = warnings, -- 394
			path = path -- 395
		} -- 395
	end -- 395
	local text = Content:load(path) -- 398
	if not text or __TS__StringTrim(text) == "" then -- 398
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 400
		return { -- 401
			pack = ____exports.resolveAgentPromptPack(), -- 402
			warnings = warnings, -- 403
			path = path -- 404
		} -- 404
	end -- 404
	local parsed = parsePromptPackMarkdown(text) -- 407
	if parsed.error or not parsed.value then -- 407
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 409
		return { -- 410
			pack = ____exports.resolveAgentPromptPack(), -- 411
			warnings = warnings, -- 412
			path = path -- 413
		} -- 413
	end -- 413
	if #parsed.unknown > 0 then -- 413
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 417
	end -- 417
	if #parsed.missing > 0 then -- 417
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 420
	end -- 420
	return { -- 422
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 423
		warnings = warnings, -- 424
		path = path -- 425
	} -- 425
end -- 384
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 480
local TokenEstimator = ____exports.TokenEstimator -- 480
TokenEstimator.name = "TokenEstimator" -- 480
function TokenEstimator.prototype.____constructor(self) -- 480
end -- 480
function TokenEstimator.estimate(self, text) -- 490
	if not text then -- 490
		return 0 -- 491
	end -- 491
	local chineseChars = utf8.len(text) -- 494
	if not chineseChars then -- 494
		return 0 -- 495
	end -- 495
	local otherChars = #text - chineseChars -- 497
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 499
	return math.max(1, tokens) -- 504
end -- 490
function TokenEstimator.estimateMessages(self, messages) -- 507
	if not messages or #messages == 0 then -- 507
		return 0 -- 508
	end -- 508
	local total = 0 -- 509
	do -- 509
		local i = 0 -- 510
		while i < #messages do -- 510
			local message = messages[i + 1] -- 511
			total = total + self:estimate(message.role or "") -- 512
			total = total + self:estimate(message.content or "") -- 513
			total = total + self:estimate(message.name or "") -- 514
			total = total + self:estimate(message.tool_call_id or "") -- 515
			total = total + self:estimate(message.reasoning_content or "") -- 516
			local toolCallsText = json.encode(message.tool_calls or ({})) -- 517
			total = total + self:estimate(toolCallsText or "") -- 518
			total = total + 8 -- 519
			i = i + 1 -- 510
		end -- 510
	end -- 510
	return total -- 521
end -- 507
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 524
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 529
end -- 524
TokenEstimator.CHARS_PER_TOKEN = 4 -- 524
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 524
local function utf8TakeHead(text, maxChars) -- 537
	if maxChars <= 0 or text == "" then -- 537
		return "" -- 538
	end -- 538
	local nextPos = utf8.offset(text, maxChars + 1) -- 539
	if nextPos == nil then -- 539
		return text -- 540
	end -- 540
	return string.sub(text, 1, nextPos - 1) -- 541
end -- 537
local function utf8TakeTail(text, maxChars) -- 544
	if maxChars <= 0 or text == "" then -- 544
		return "" -- 545
	end -- 545
	local charLen = utf8.len(text) -- 546
	if charLen == false or charLen <= maxChars then -- 546
		return text -- 547
	end -- 547
	local startChar = math.max(1, charLen - maxChars + 1) -- 548
	local startPos = utf8.offset(text, startChar) -- 549
	if startPos == nil then -- 549
		return text -- 550
	end -- 550
	return string.sub(text, startPos) -- 551
end -- 544
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 559
local DualLayerStorage = ____exports.DualLayerStorage -- 559
DualLayerStorage.name = "DualLayerStorage" -- 559
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 566
	self.projectDir = projectDir -- 567
	self.agentDir = Path(self.projectDir, ".agent") -- 568
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 569
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 570
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 571
	self:ensureAgentFiles() -- 572
end -- 566
function DualLayerStorage.prototype.ensureDir(self, dir) -- 575
	if not Content:exist(dir) then -- 575
		Content:mkdir(dir) -- 577
	end -- 577
end -- 575
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 581
	if Content:exist(path) then -- 581
		return false -- 582
	end -- 582
	self:ensureDir(Path:getPath(path)) -- 583
	if not Content:save(path, content) then -- 583
		return false -- 585
	end -- 585
	sendWebIDEFileUpdate(path, true, content) -- 587
	return true -- 588
end -- 581
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 591
	self:ensureDir(self.agentDir) -- 592
	self:ensureFile(self.memoryPath, "") -- 593
	self:ensureFile(self.historyPath, "") -- 594
end -- 591
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 597
	local text = json.encode(value) -- 598
	return text -- 599
end -- 597
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 602
	local value = json.decode(text) -- 603
	return value -- 604
end -- 602
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 607
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 607
		return nil -- 608
	end -- 608
	local row = value -- 609
	local role = type(row.role) == "string" and row.role or "" -- 610
	if role == "" then -- 610
		return nil -- 611
	end -- 611
	local message = {role = role} -- 612
	if type(row.content) == "string" then -- 612
		message.content = row.content -- 613
	end -- 613
	if type(row.name) == "string" then -- 613
		message.name = row.name -- 614
	end -- 614
	if type(row.tool_call_id) == "string" then -- 614
		message.tool_call_id = row.tool_call_id -- 615
	end -- 615
	if type(row.reasoning_content) == "string" then -- 615
		message.reasoning_content = row.reasoning_content -- 616
	end -- 616
	if type(row.timestamp) == "string" then -- 616
		message.timestamp = row.timestamp -- 617
	end -- 617
	if type(row.tool_calls) == "table" then -- 617
		message.tool_calls = row.tool_calls -- 619
	end -- 619
	return message -- 621
end -- 607
function DualLayerStorage.prototype.readMemory(self) -- 629
	if not Content:exist(self.memoryPath) then -- 629
		return "" -- 631
	end -- 631
	return Content:load(self.memoryPath) -- 633
end -- 629
function DualLayerStorage.prototype.writeMemory(self, content) -- 639
	self:ensureDir(Path:getPath(self.memoryPath)) -- 640
	Content:save(self.memoryPath, content) -- 641
end -- 639
function DualLayerStorage.prototype.getMemoryContext(self) -- 647
	local memory = self:readMemory() -- 648
	if not memory then -- 648
		return "" -- 649
	end -- 649
	return "### Long-term Memory\n\n" .. memory -- 651
end -- 647
function DualLayerStorage.prototype.appendHistory(self, entry) -- 661
	self:ensureDir(Path:getPath(self.historyPath)) -- 662
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 664
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 668
end -- 661
function DualLayerStorage.prototype.readHistory(self) -- 674
	if not Content:exist(self.historyPath) then -- 674
		return "" -- 676
	end -- 676
	return Content:load(self.historyPath) -- 678
end -- 674
function DualLayerStorage.prototype.readSessionState(self) -- 681
	if not Content:exist(self.sessionPath) then -- 681
		return {messages = {}, lastConsolidatedMessageIndex = 0} -- 683
	end -- 683
	local text = Content:load(self.sessionPath) -- 685
	if not text or __TS__StringTrim(text) == "" then -- 685
		return {messages = {}, lastConsolidatedMessageIndex = 0} -- 687
	end -- 687
	local lines = __TS__StringSplit(text, "\n") -- 689
	local messages = {} -- 690
	local lastConsolidatedMessageIndex = 0 -- 691
	do -- 691
		local i = 0 -- 692
		while i < #lines do -- 692
			do -- 692
				local line = __TS__StringTrim(lines[i + 1]) -- 693
				if line == "" then -- 693
					goto __continue90 -- 694
				end -- 694
				local data = self:decodeJsonLine(line) -- 695
				if not data or __TS__ArrayIsArray(data) or type(data) ~= "table" then -- 695
					goto __continue90 -- 696
				end -- 696
				local row = data -- 697
				if row._type == "metadata" then -- 697
					local ____math_max_4 = math.max -- 699
					local ____math_floor_3 = math.floor -- 699
					local ____row_lastConsolidatedMessageIndex_2 = row.lastConsolidatedMessageIndex -- 699
					if ____row_lastConsolidatedMessageIndex_2 == nil then -- 699
						____row_lastConsolidatedMessageIndex_2 = 0 -- 699
					end -- 699
					lastConsolidatedMessageIndex = ____math_max_4( -- 699
						0, -- 699
						____math_floor_3(__TS__Number(____row_lastConsolidatedMessageIndex_2)) -- 699
					) -- 699
					goto __continue90 -- 700
				end -- 700
				local ____self_decodeConversationMessage_6 = self.decodeConversationMessage -- 702
				local ____row_message_5 = row.message -- 702
				if ____row_message_5 == nil then -- 702
					____row_message_5 = row -- 702
				end -- 702
				local message = ____self_decodeConversationMessage_6(self, ____row_message_5) -- 702
				if message then -- 702
					messages[#messages + 1] = message -- 704
				end -- 704
			end -- 704
			::__continue90:: -- 704
			i = i + 1 -- 692
		end -- 692
	end -- 692
	return { -- 707
		messages = messages, -- 708
		lastConsolidatedMessageIndex = math.min(lastConsolidatedMessageIndex, #messages) -- 709
	} -- 709
end -- 681
function DualLayerStorage.prototype.writeSessionState(self, messages, lastConsolidatedMessageIndex) -- 713
	if messages == nil then -- 713
		messages = {} -- 714
	end -- 714
	if lastConsolidatedMessageIndex == nil then -- 714
		lastConsolidatedMessageIndex = 0 -- 715
	end -- 715
	self:ensureDir(Path:getPath(self.sessionPath)) -- 717
	local lines = {} -- 718
	local meta = self:encodeJsonLine({ -- 719
		_type = "metadata", -- 720
		lastConsolidatedMessageIndex = math.min( -- 721
			math.max( -- 721
				0, -- 721
				math.floor(lastConsolidatedMessageIndex) -- 721
			), -- 721
			#messages -- 721
		) -- 721
	}) -- 721
	if meta then -- 721
		lines[#lines + 1] = meta -- 724
	end -- 724
	do -- 724
		local i = 0 -- 726
		while i < #messages do -- 726
			local line = self:encodeJsonLine({_type = "message", message = messages[i + 1]}) -- 727
			if line then -- 727
				lines[#lines + 1] = line -- 732
			end -- 732
			i = i + 1 -- 726
		end -- 726
	end -- 726
	local content = table.concat(lines, "\n") .. "\n" -- 735
	Content:save(self.sessionPath, content) -- 736
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 737
end -- 713
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 743
	local history = self:readHistory() -- 744
	if not history then -- 744
		return {} -- 745
	end -- 745
	local lines = __TS__StringSplit(history, "\n") -- 747
	local lowerKeyword = string.lower(keyword) -- 748
	return __TS__ArrayFilter( -- 750
		lines, -- 750
		function(____, line) return __TS__StringIncludes( -- 750
			string.lower(line), -- 751
			lowerKeyword -- 751
		) end -- 751
	) -- 751
end -- 743
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 764
local MemoryCompressor = ____exports.MemoryCompressor -- 764
MemoryCompressor.name = "MemoryCompressor" -- 764
function MemoryCompressor.prototype.____constructor(self, config) -- 771
	self.consecutiveFailures = 0 -- 767
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 772
	do -- 772
		local i = 0 -- 773
		while i < #loadedPromptPack.warnings do -- 773
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 774
			i = i + 1 -- 773
		end -- 773
	end -- 773
	local overridePack = config.promptPack and not __TS__ArrayIsArray(config.promptPack) and type(config.promptPack) == "table" and config.promptPack or nil -- 776
	self.config = __TS__ObjectAssign( -- 779
		{}, -- 779
		config, -- 780
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 779
	) -- 779
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 786
end -- 771
function MemoryCompressor.prototype.getPromptPack(self) -- 789
	return self.config.promptPack -- 790
end -- 789
function MemoryCompressor.prototype.shouldCompress(self, messages, lastConsolidatedMessageIndex, systemPrompt, toolDefinitions) -- 796
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages( -- 802
		__TS__ArraySlice(messages, lastConsolidatedMessageIndex), -- 803
		systemPrompt, -- 804
		toolDefinitions -- 805
	) -- 805
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 808
	return messageTokens > threshold -- 810
end -- 796
function MemoryCompressor.prototype.compress(self, messages, lastConsolidatedMessageIndex, systemPrompt, toolDefinitions, llmOptions, maxLLMTry, decisionMode) -- 816
	if decisionMode == nil then -- 816
		decisionMode = "tool_calling" -- 823
	end -- 823
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 823
		local toCompress = __TS__ArraySlice(messages, lastConsolidatedMessageIndex) -- 825
		if #toCompress == 0 then -- 825
			return ____awaiter_resolve(nil, nil) -- 825
		end -- 825
		local boundary = self:findCompressionBoundary(toCompress, systemPrompt, toolDefinitions) -- 828
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 833
		if #chunk == 0 then -- 833
			return ____awaiter_resolve(nil, nil) -- 833
		end -- 833
		local currentMemory = self.storage:readMemory() -- 837
		local historyText = self:formatMessagesForCompression(chunk) -- 838
		local ____try = __TS__AsyncAwaiter(function() -- 838
			local result = __TS__Await(self:callLLMForCompression( -- 842
				currentMemory, -- 843
				historyText, -- 844
				llmOptions, -- 845
				maxLLMTry or 3, -- 846
				decisionMode -- 847
			)) -- 847
			if result.success then -- 847
				self.storage:writeMemory(result.memoryUpdate) -- 852
				self.storage:appendHistory(result.historyEntry) -- 853
				self.consecutiveFailures = 0 -- 854
				return ____awaiter_resolve( -- 854
					nil, -- 854
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 856
				) -- 856
			end -- 856
			return ____awaiter_resolve( -- 856
				nil, -- 856
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 863
			) -- 863
		end) -- 863
		__TS__Await(____try.catch( -- 840
			____try, -- 840
			function(____, ____error) -- 840
				return ____awaiter_resolve( -- 840
					nil, -- 840
					self:handleCompressionFailure( -- 866
						chunk, -- 866
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 866
					) -- 866
				) -- 866
			end -- 866
		)) -- 866
	end) -- 866
end -- 816
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, systemPrompt, toolDefinitions) -- 875
	local requiredTokens = self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 880
	local targetTokens = math.min( -- 881
		self.config.maxTokensPerCompression, -- 882
		math.max(1, requiredTokens) -- 883
	) -- 883
	local accumulatedTokens = 0 -- 885
	local lastSafeBoundary = 0 -- 886
	local pendingToolCalls = {} -- 887
	local pendingToolCallCount = 0 -- 888
	do -- 888
		local i = 0 -- 890
		while i < #messages do -- 890
			local message = messages[i + 1] -- 891
			local tokens = ____exports.TokenEstimator:estimatePromptMessages({message}, "", "") -- 892
			accumulatedTokens = accumulatedTokens + tokens -- 893
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 893
				do -- 893
					local j = 0 -- 896
					while j < #message.tool_calls do -- 896
						local toolCallEntry = message.tool_calls[j + 1] -- 897
						local ____temp_7 -- 898
						if toolCallEntry and not __TS__ArrayIsArray(toolCallEntry) and type(toolCallEntry) == "table" then -- 898
							____temp_7 = toolCallEntry.id -- 903
						else -- 903
							____temp_7 = nil -- 904
						end -- 904
						local idValue = ____temp_7 -- 898
						local id = type(idValue) == "string" and idValue or "" -- 905
						if id ~= "" and pendingToolCalls[id] ~= true then -- 905
							pendingToolCalls[id] = true -- 907
							pendingToolCallCount = pendingToolCallCount + 1 -- 908
						end -- 908
						j = j + 1 -- 896
					end -- 896
				end -- 896
			end -- 896
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] == true then -- 896
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
			i = i + 1 -- 890
		end -- 890
	end -- 890
	if lastSafeBoundary > 0 then -- 890
		return lastSafeBoundary -- 931
	end -- 931
	return math.min(#messages, 1) -- 932
end -- 875
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
				local toolCallsText = json.encode(message.tool_calls) -- 966
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
		if decisionMode == "yaml" then -- 985
			return ____awaiter_resolve( -- 985
				nil, -- 985
				self:callLLMForCompressionByYAML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 987
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
			local args, err = json.decode(argsText) -- 1146
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
function MemoryCompressor.prototype.callLLMForCompressionByYAML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1172
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1172
		local prompt = self:buildYAMLCompressionPrompt(currentMemory, historyText) -- 1178
		local lastError = "invalid yaml response" -- 1179
		do -- 1179
			local i = 0 -- 1181
			while i < maxLLMTry do -- 1181
				do -- 1181
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionYamlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1182
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
						lastError = "empty yaml response" -- 1208
						goto __continue155 -- 1209
					end -- 1209
					local parsed = self:parseCompressionYAMLObject(text, currentMemory) -- 1212
					if parsed.success then -- 1212
						return ____awaiter_resolve(nil, parsed) -- 1212
					end -- 1212
					lastError = parsed.error or "invalid yaml response" -- 1216
				end -- 1216
				::__continue155:: -- 1216
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
function MemoryCompressor.prototype.buildYAMLCompressionPrompt(self, currentMemory, historyText) -- 1252
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionYamlPrompt -- 1253
end -- 1252
function MemoryCompressor.prototype.extractYAMLFromText(self, text) -- 1258
	local source = __TS__StringTrim(text) -- 1259
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 1260
	if yamlFencePos >= 0 then -- 1260
		local from = yamlFencePos + #"```yaml" -- 1262
		local ____end = (string.find( -- 1263
			source, -- 1263
			"```", -- 1263
			math.max(from + 1, 1), -- 1263
			true -- 1263
		) or 0) - 1 -- 1263
		if ____end > from then -- 1263
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1264
		end -- 1264
	end -- 1264
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 1266
	if ymlFencePos >= 0 then -- 1266
		local from = ymlFencePos + #"```yml" -- 1268
		local ____end = (string.find( -- 1269
			source, -- 1269
			"```", -- 1269
			math.max(from + 1, 1), -- 1269
			true -- 1269
		) or 0) - 1 -- 1269
		if ____end > from then -- 1269
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1270
		end -- 1270
	end -- 1270
	return source -- 1272
end -- 1258
function MemoryCompressor.prototype.parseCompressionYAMLObject(self, text, currentMemory) -- 1275
	local yamlText = self:extractYAMLFromText(text) -- 1276
	local obj, err = yaml.parse(yamlText) -- 1277
	if not obj or type(obj) ~= "table" then -- 1277
		return { -- 1279
			success = false, -- 1280
			memoryUpdate = currentMemory, -- 1281
			historyEntry = "", -- 1282
			compressedCount = 0, -- 1283
			error = "invalid yaml: " .. tostring(err) -- 1284
		} -- 1284
	end -- 1284
	return self:buildCompressionResultFromObject(obj, currentMemory) -- 1287
end -- 1275
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1293
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1297
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1298
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1298
		return { -- 1300
			success = false, -- 1301
			memoryUpdate = currentMemory, -- 1302
			historyEntry = "", -- 1303
			compressedCount = 0, -- 1304
			error = "missing history_entry or memory_update" -- 1305
		} -- 1305
	end -- 1305
	local ts = os.date("%Y-%m-%d %H:%M") -- 1308
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1309
end -- 1293
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1320
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1324
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1324
		self:rawArchive(chunk) -- 1327
		self.consecutiveFailures = 0 -- 1328
		return { -- 1330
			success = true, -- 1331
			memoryUpdate = self.storage:readMemory(), -- 1332
			historyEntry = "[RAW ARCHIVE] Detailed history not recorded", -- 1333
			compressedCount = #chunk -- 1334
		} -- 1334
	end -- 1334
	return { -- 1338
		success = false, -- 1339
		memoryUpdate = self.storage:readMemory(), -- 1340
		historyEntry = "", -- 1341
		compressedCount = 0, -- 1342
		error = ____error -- 1343
	} -- 1343
end -- 1320
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1350
	local ts = os.date("%Y-%m-%d %H:%M") -- 1351
	local firstUserMessage -- 1352
	do -- 1352
		local i = 0 -- 1353
		while i < #chunk do -- 1353
			if chunk[i + 1].role == "user" then -- 1353
				firstUserMessage = chunk[i + 1] -- 1355
				break -- 1356
			end -- 1356
			i = i + 1 -- 1353
		end -- 1353
	end -- 1353
	local prompt = firstUserMessage and firstUserMessage.content and __TS__StringTrim(firstUserMessage.content) ~= "" and __TS__StringReplace( -- 1359
		__TS__StringTrim(firstUserMessage.content), -- 1360
		"\n", -- 1360
		" " -- 1360
	) or "(empty prompt)" -- 1360
	local compactPrompt = #prompt > 160 and string.sub(prompt, 1, 160) .. "..." or prompt -- 1362
	self.storage:appendHistory(((((("[" .. ts) .. "] [RAW ARCHIVE] prompt=\"") .. compactPrompt) .. "\" (") .. tostring(#chunk)) .. " messages, compression failed; detailed history not recorded)") -- 1363
end -- 1350
function MemoryCompressor.prototype.getStorage(self) -- 1371
	return self.storage -- 1372
end -- 1371
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1375
	return math.max( -- 1376
		1, -- 1376
		math.floor(self.config.maxCompressionRounds) -- 1376
	) -- 1376
end -- 1375
MemoryCompressor.MAX_FAILURES = 3 -- 1375
return ____exports -- 1375