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
local YAML_DECISION_SCHEMA_EXAMPLE = "```yaml\ntool: \"edit_file\"\nreason: \"Need to update the file content to implement the requested change.\"\nparams:\n  path: \"relative/path.ts\"\n  old_str: |2-\n    \t\tfunction oldName() {\n    \t\t\tprint(\"old\");\n    \t\t}\n  new_str: |2-\n    \t\tfunction newName() {\n    \t\t\tprint(\"hello\");\n    \t\t}\n```\n\n```yaml\ntool: \"read_file\"\nreason: \"Need to inspect the current implementation before editing.\"\nparams:\n  path: \"relative/path.ts\"\n  startLine: 1\n  endLine: 200\n```\n\n```yaml\ntool: \"finish\"\nparams:\n  message: \"Final user-facing answer.\"\n```" -- 19
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 64
	agentIdentityPrompt = "### Dora Agent (｡•̀ᴗ-)✧💕\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 65
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Line starts with 1. startLine defaults to 1 and endLine defaults to 300.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Do compiling and static checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- `path` can be workspace-relative file or directory to build.\n\t- Read the result and then decide whether another action is needed.\n\n8. finish: End the task and reply directly to the user\n\t- Parameters: message", -- 78
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 124
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 125
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 126
	yamlDecisionFormatPrompt = ("Respond with exactly one YAML object. Do not include any prose before or after the YAML.\n\n" .. YAML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one YAML object.\n- For every tool except finish, use exactly these top-level keys: tool, reason, params.\n- For finish, use exactly these top-level keys: tool, params.\n- Multi-line strings use block scalars (`|`, `|-`, `>`).\n- Use 2 spaces for YAML structural indentation. Do not use tabs to indent YAML keys.\n- If a multi-line string must preserve leading tabs or other leading whitespace on content lines, prefer a block scalar with an explicit indentation indicator `|2-`.\n- For nested multi-line fields (e.g. params.new_str), indent block-scalar content deeper than the key line using spaces for YAML structure.\n- Keep params shallow and valid for the selected tool.\n- If no more actions are needed, use tool: finish and put the final user-facing answer in params.message.", -- 127
	yamlDecisionRepairPrompt = ("Convert the tool call result below into exactly one valid YAML object.\n\nYAML schema example:\n" .. YAML_DECISION_SCHEMA_EXAMPLE) .. "\n\nRules:\n- Return exactly one YAML object.\n- Return YAML only. No prose before or after.\n- Keep the same tool name, reason, and parameter values as the source whenever possible.\n- For every tool except finish, use top-level keys: tool, reason, params.\n- For finish, use top-level keys: tool, params.\n- Multi-line string params should use block scalars when needed.\n- Use spaces for YAML structural indentation. Do not use tabs to indent YAML keys.\n- If a multi-line string must preserve leading tabs or other leading whitespace on content lines, prefer a block scalar with an explicit indentation indicator such as `|2-`.\n- Do not invent extra parameters.\n\nAvailable tools and params reference:\n\n{{TOOL_DEFINITIONS}}\n\n### Original Raw Output\n```\n{{ORIGINAL_RAW}}\n```\n\n{{CANDIDATE_SECTION}}### Repair Task\n- The current candidate is invalid because: {{LAST_ERROR}}\n- Repair only the formatting/schema so the result becomes one valid YAML object.\n- Keep the tool name and argument values aligned with the original raw output.\n- Retry attempt: {{ATTEMPT}}.\n- The next reply must differ from the previously rejected candidate.\n- Return YAML only, with no prose before or after.", -- 141
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.", -- 173
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n---\n\n### Actions to Process\n\n{{HISTORY_TEXT}}\n\n---\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph for HISTORY.md\n\t- Include timestamp and key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.",
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 213
	memoryCompressionYamlPrompt = "### Output Format\n\nReturn exactly one YAML object:\n```yaml\nhistory_entry: \"Summary paragraph\"\nmemory_update: |-\n\tFull updated MEMORY.md content\n```\n\nRules:\n- Return YAML only, no prose before or after.\n- Use exactly two keys: history_entry, memory_update.\n- Use a block scalar for memory_update when it spans multiple lines.", -- 218
	memoryCompressionYamlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid YAML object only." -- 231
} -- 231
local EXPOSED_PROMPT_PACK_KEYS = {"agentIdentityPrompt", "replyLanguageDirectiveZh", "replyLanguageDirectiveEn", "memoryCompressionBodyPrompt"} -- 234
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 234
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 234
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 241
local function replaceTemplateVars(template, vars) -- 246
	local output = template -- 247
	for key in pairs(vars) do -- 248
		output = table.concat( -- 249
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 249
			vars[key] or "" or "," -- 249
		) -- 249
	end -- 249
	return output -- 251
end -- 246
function ____exports.resolveAgentPromptPack(value) -- 254
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 255
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 255
		do -- 255
			local i = 0 -- 259
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 259
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 260
				if type(value[key]) == "string" then -- 260
					merged[key] = value[key] -- 262
				end -- 262
				i = i + 1 -- 259
			end -- 259
		end -- 259
	end -- 259
	return merged -- 266
end -- 254
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 269
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 270
	local lines = {} -- 271
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 272
	lines[#lines + 1] = "" -- 273
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 274
	lines[#lines + 1] = "" -- 275
	do -- 275
		local i = 0 -- 276
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 276
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 277
			lines[#lines + 1] = "## " .. key -- 278
			local text = pack[key] -- 279
			local split = __TS__StringSplit(text, "\n") -- 280
			do -- 280
				local j = 0 -- 281
				while j < #split do -- 281
					lines[#lines + 1] = split[j + 1] -- 282
					j = j + 1 -- 281
				end -- 281
			end -- 281
			lines[#lines + 1] = "" -- 284
			i = i + 1 -- 276
		end -- 276
	end -- 276
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 286
end -- 269
local function getPromptPackConfigPath(projectRoot) -- 289
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 290
end -- 289
local function ensurePromptPackConfig(projectRoot) -- 293
	local path = getPromptPackConfigPath(projectRoot) -- 294
	if Content:exist(path) then -- 294
		return nil -- 295
	end -- 295
	local dir = Path:getPath(path) -- 296
	if not Content:exist(dir) then -- 296
		Content:mkdir(dir) -- 298
	end -- 298
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 300
	if not Content:save(path, content) then -- 300
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 302
	end -- 302
	sendWebIDEFileUpdate(path, true, content) -- 304
	return nil -- 305
end -- 293
local function parsePromptPackMarkdown(text) -- 308
	if not text or __TS__StringTrim(text) == "" then -- 308
		return { -- 315
			value = {}, -- 316
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 317
			unknown = {} -- 318
		} -- 318
	end -- 318
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 321
	local lines = __TS__StringSplit(normalized, "\n") -- 322
	local sections = {} -- 323
	local unknown = {} -- 324
	local currentHeading = "" -- 325
	local function isKnownPromptPackKey(name) -- 326
		do -- 326
			local i = 0 -- 327
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 327
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 327
					return true -- 328
				end -- 328
				i = i + 1 -- 327
			end -- 327
		end -- 327
		return false -- 330
	end -- 326
	do -- 326
		local i = 0 -- 332
		while i < #lines do -- 332
			do -- 332
				local line = lines[i + 1] -- 333
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 334
				if matchedHeading ~= nil then -- 334
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 336
					if isKnownPromptPackKey(heading) then -- 336
						currentHeading = heading -- 338
						if sections[currentHeading] == nil then -- 338
							sections[currentHeading] = {} -- 340
						end -- 340
						goto __continue27 -- 342
					end -- 342
					if currentHeading == "" then -- 342
						unknown[#unknown + 1] = heading -- 345
						goto __continue27 -- 346
					end -- 346
				end -- 346
				if currentHeading ~= "" then -- 346
					local ____sections_currentHeading_1 = sections[currentHeading] -- 346
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 350
				end -- 350
			end -- 350
			::__continue27:: -- 350
			i = i + 1 -- 332
		end -- 332
	end -- 332
	local value = {} -- 353
	local missing = {} -- 354
	do -- 354
		local i = 0 -- 355
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 355
			do -- 355
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 356
				local section = sections[key] -- 357
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 358
				if body == "" then -- 358
					missing[#missing + 1] = key -- 360
					goto __continue34 -- 361
				end -- 361
				value[key] = body -- 363
			end -- 363
			::__continue34:: -- 363
			i = i + 1 -- 355
		end -- 355
	end -- 355
	if #__TS__ObjectKeys(sections) == 0 then -- 355
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 366
	end -- 366
	return {value = value, missing = missing, unknown = unknown} -- 372
end -- 308
function ____exports.loadAgentPromptPack(projectRoot) -- 375
	local path = getPromptPackConfigPath(projectRoot) -- 376
	local warnings = {} -- 377
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 378
	if ensureWarning and ensureWarning ~= "" then -- 378
		warnings[#warnings + 1] = ensureWarning -- 380
	end -- 380
	if not Content:exist(path) then -- 380
		return { -- 383
			pack = ____exports.resolveAgentPromptPack(), -- 384
			warnings = warnings, -- 385
			path = path -- 386
		} -- 386
	end -- 386
	local text = Content:load(path) -- 389
	if not text or __TS__StringTrim(text) == "" then -- 389
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 391
		return { -- 392
			pack = ____exports.resolveAgentPromptPack(), -- 393
			warnings = warnings, -- 394
			path = path -- 395
		} -- 395
	end -- 395
	local parsed = parsePromptPackMarkdown(text) -- 398
	if parsed.error or not parsed.value then -- 398
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 400
		return { -- 401
			pack = ____exports.resolveAgentPromptPack(), -- 402
			warnings = warnings, -- 403
			path = path -- 404
		} -- 404
	end -- 404
	if #parsed.unknown > 0 then -- 404
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 408
	end -- 408
	if #parsed.missing > 0 then -- 408
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 411
	end -- 411
	return { -- 413
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 414
		warnings = warnings, -- 415
		path = path -- 416
	} -- 416
end -- 375
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 471
local TokenEstimator = ____exports.TokenEstimator -- 471
TokenEstimator.name = "TokenEstimator" -- 471
function TokenEstimator.prototype.____constructor(self) -- 471
end -- 471
function TokenEstimator.estimate(self, text) -- 481
	if not text then -- 481
		return 0 -- 482
	end -- 482
	local chineseChars = utf8.len(text) -- 485
	if not chineseChars then -- 485
		return 0 -- 486
	end -- 486
	local otherChars = #text - chineseChars -- 488
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 490
	return math.max(1, tokens) -- 495
end -- 481
function TokenEstimator.estimateMessages(self, messages) -- 498
	if not messages or #messages == 0 then -- 498
		return 0 -- 499
	end -- 499
	local total = 0 -- 500
	do -- 500
		local i = 0 -- 501
		while i < #messages do -- 501
			local message = messages[i + 1] -- 502
			total = total + self:estimate(message.role or "") -- 503
			total = total + self:estimate(message.content or "") -- 504
			total = total + self:estimate(message.name or "") -- 505
			total = total + self:estimate(message.tool_call_id or "") -- 506
			total = total + self:estimate(message.reasoning_content or "") -- 507
			local toolCallsText = json.encode(message.tool_calls or ({})) -- 508
			total = total + self:estimate(toolCallsText or "") -- 509
			total = total + 8 -- 510
			i = i + 1 -- 501
		end -- 501
	end -- 501
	return total -- 512
end -- 498
function TokenEstimator.estimatePromptMessages(self, messages, systemPrompt, toolDefinitions) -- 515
	return self:estimateMessages(messages) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 520
end -- 515
TokenEstimator.CHARS_PER_TOKEN = 4 -- 515
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 515
local function utf8TakeHead(text, maxChars) -- 528
	if maxChars <= 0 or text == "" then -- 528
		return "" -- 529
	end -- 529
	local nextPos = utf8.offset(text, maxChars + 1) -- 530
	if nextPos == nil then -- 530
		return text -- 531
	end -- 531
	return string.sub(text, 1, nextPos - 1) -- 532
end -- 528
local function utf8TakeTail(text, maxChars) -- 535
	if maxChars <= 0 or text == "" then -- 535
		return "" -- 536
	end -- 536
	local charLen = utf8.len(text) -- 537
	if charLen == false or charLen <= maxChars then -- 537
		return text -- 538
	end -- 538
	local startChar = math.max(1, charLen - maxChars + 1) -- 539
	local startPos = utf8.offset(text, startChar) -- 540
	if startPos == nil then -- 540
		return text -- 541
	end -- 541
	return string.sub(text, startPos) -- 542
end -- 535
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 550
local DualLayerStorage = ____exports.DualLayerStorage -- 550
DualLayerStorage.name = "DualLayerStorage" -- 550
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 557
	self.projectDir = projectDir -- 558
	self.agentDir = Path(self.projectDir, ".agent") -- 559
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 560
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 561
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 562
	self:ensureAgentFiles() -- 563
end -- 557
function DualLayerStorage.prototype.ensureDir(self, dir) -- 566
	if not Content:exist(dir) then -- 566
		Content:mkdir(dir) -- 568
	end -- 568
end -- 566
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 572
	if Content:exist(path) then -- 572
		return false -- 573
	end -- 573
	self:ensureDir(Path:getPath(path)) -- 574
	if not Content:save(path, content) then -- 574
		return false -- 576
	end -- 576
	sendWebIDEFileUpdate(path, true, content) -- 578
	return true -- 579
end -- 572
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 582
	self:ensureDir(self.agentDir) -- 583
	self:ensureFile(self.memoryPath, "") -- 584
	self:ensureFile(self.historyPath, "") -- 585
end -- 582
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 588
	local text = json.encode(value) -- 589
	return text -- 590
end -- 588
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 593
	local value = json.decode(text) -- 594
	return value -- 595
end -- 593
function DualLayerStorage.prototype.decodeConversationMessage(self, value) -- 598
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 598
		return nil -- 599
	end -- 599
	local row = value -- 600
	local role = type(row.role) == "string" and row.role or "" -- 601
	if role == "" then -- 601
		return nil -- 602
	end -- 602
	local message = {role = role} -- 603
	if type(row.content) == "string" then -- 603
		message.content = row.content -- 604
	end -- 604
	if type(row.name) == "string" then -- 604
		message.name = row.name -- 605
	end -- 605
	if type(row.tool_call_id) == "string" then -- 605
		message.tool_call_id = row.tool_call_id -- 606
	end -- 606
	if type(row.reasoning_content) == "string" then -- 606
		message.reasoning_content = row.reasoning_content -- 607
	end -- 607
	if type(row.timestamp) == "string" then -- 607
		message.timestamp = row.timestamp -- 608
	end -- 608
	if type(row.tool_calls) == "table" then -- 608
		message.tool_calls = row.tool_calls -- 610
	end -- 610
	return message -- 612
end -- 598
function DualLayerStorage.prototype.readMemory(self) -- 620
	if not Content:exist(self.memoryPath) then -- 620
		return "" -- 622
	end -- 622
	return Content:load(self.memoryPath) -- 624
end -- 620
function DualLayerStorage.prototype.writeMemory(self, content) -- 630
	self:ensureDir(Path:getPath(self.memoryPath)) -- 631
	Content:save(self.memoryPath, content) -- 632
end -- 630
function DualLayerStorage.prototype.getMemoryContext(self) -- 638
	local memory = self:readMemory() -- 639
	if not memory then -- 639
		return "" -- 640
	end -- 640
	return "### Long-term Memory\n\n" .. memory -- 642
end -- 638
function DualLayerStorage.prototype.appendHistory(self, entry) -- 652
	self:ensureDir(Path:getPath(self.historyPath)) -- 653
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 655
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 659
end -- 652
function DualLayerStorage.prototype.readHistory(self) -- 665
	if not Content:exist(self.historyPath) then -- 665
		return "" -- 667
	end -- 667
	return Content:load(self.historyPath) -- 669
end -- 665
function DualLayerStorage.prototype.readSessionState(self) -- 672
	if not Content:exist(self.sessionPath) then -- 672
		return {messages = {}, lastConsolidatedMessageIndex = 0} -- 674
	end -- 674
	local text = Content:load(self.sessionPath) -- 676
	if not text or __TS__StringTrim(text) == "" then -- 676
		return {messages = {}, lastConsolidatedMessageIndex = 0} -- 678
	end -- 678
	local lines = __TS__StringSplit(text, "\n") -- 680
	local messages = {} -- 681
	local lastConsolidatedMessageIndex = 0 -- 682
	do -- 682
		local i = 0 -- 683
		while i < #lines do -- 683
			do -- 683
				local line = __TS__StringTrim(lines[i + 1]) -- 684
				if line == "" then -- 684
					goto __continue90 -- 685
				end -- 685
				local data = self:decodeJsonLine(line) -- 686
				if not data or __TS__ArrayIsArray(data) or type(data) ~= "table" then -- 686
					goto __continue90 -- 687
				end -- 687
				local row = data -- 688
				if row._type == "metadata" then -- 688
					local ____math_max_4 = math.max -- 690
					local ____math_floor_3 = math.floor -- 690
					local ____row_lastConsolidatedMessageIndex_2 = row.lastConsolidatedMessageIndex -- 690
					if ____row_lastConsolidatedMessageIndex_2 == nil then -- 690
						____row_lastConsolidatedMessageIndex_2 = 0 -- 690
					end -- 690
					lastConsolidatedMessageIndex = ____math_max_4( -- 690
						0, -- 690
						____math_floor_3(__TS__Number(____row_lastConsolidatedMessageIndex_2)) -- 690
					) -- 690
					goto __continue90 -- 691
				end -- 691
				local ____self_decodeConversationMessage_6 = self.decodeConversationMessage -- 693
				local ____row_message_5 = row.message -- 693
				if ____row_message_5 == nil then -- 693
					____row_message_5 = row -- 693
				end -- 693
				local message = ____self_decodeConversationMessage_6(self, ____row_message_5) -- 693
				if message then -- 693
					messages[#messages + 1] = message -- 695
				end -- 695
			end -- 695
			::__continue90:: -- 695
			i = i + 1 -- 683
		end -- 683
	end -- 683
	return { -- 698
		messages = messages, -- 699
		lastConsolidatedMessageIndex = math.min(lastConsolidatedMessageIndex, #messages) -- 700
	} -- 700
end -- 672
function DualLayerStorage.prototype.writeSessionState(self, messages, lastConsolidatedMessageIndex) -- 704
	if messages == nil then -- 704
		messages = {} -- 705
	end -- 705
	if lastConsolidatedMessageIndex == nil then -- 705
		lastConsolidatedMessageIndex = 0 -- 706
	end -- 706
	self:ensureDir(Path:getPath(self.sessionPath)) -- 708
	local lines = {} -- 709
	local meta = self:encodeJsonLine({ -- 710
		_type = "metadata", -- 711
		lastConsolidatedMessageIndex = math.min( -- 712
			math.max( -- 712
				0, -- 712
				math.floor(lastConsolidatedMessageIndex) -- 712
			), -- 712
			#messages -- 712
		) -- 712
	}) -- 712
	if meta then -- 712
		lines[#lines + 1] = meta -- 715
	end -- 715
	do -- 715
		local i = 0 -- 717
		while i < #messages do -- 717
			local line = self:encodeJsonLine({_type = "message", message = messages[i + 1]}) -- 718
			if line then -- 718
				lines[#lines + 1] = line -- 723
			end -- 723
			i = i + 1 -- 717
		end -- 717
	end -- 717
	local content = table.concat(lines, "\n") .. "\n" -- 726
	Content:save(self.sessionPath, content) -- 727
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 728
end -- 704
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 734
	local history = self:readHistory() -- 735
	if not history then -- 735
		return {} -- 736
	end -- 736
	local lines = __TS__StringSplit(history, "\n") -- 738
	local lowerKeyword = string.lower(keyword) -- 739
	return __TS__ArrayFilter( -- 741
		lines, -- 741
		function(____, line) return __TS__StringIncludes( -- 741
			string.lower(line), -- 742
			lowerKeyword -- 742
		) end -- 742
	) -- 742
end -- 734
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 755
local MemoryCompressor = ____exports.MemoryCompressor -- 755
MemoryCompressor.name = "MemoryCompressor" -- 755
function MemoryCompressor.prototype.____constructor(self, config) -- 762
	self.consecutiveFailures = 0 -- 758
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 763
	do -- 763
		local i = 0 -- 764
		while i < #loadedPromptPack.warnings do -- 764
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 765
			i = i + 1 -- 764
		end -- 764
	end -- 764
	local overridePack = config.promptPack and not __TS__ArrayIsArray(config.promptPack) and type(config.promptPack) == "table" and config.promptPack or nil -- 767
	self.config = __TS__ObjectAssign( -- 770
		{}, -- 770
		config, -- 771
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 770
	) -- 770
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 777
end -- 762
function MemoryCompressor.prototype.getPromptPack(self) -- 780
	return self.config.promptPack -- 781
end -- 780
function MemoryCompressor.prototype.shouldCompress(self, messages, lastConsolidatedMessageIndex, systemPrompt, toolDefinitions) -- 787
	local messageTokens = ____exports.TokenEstimator:estimatePromptMessages( -- 793
		__TS__ArraySlice(messages, lastConsolidatedMessageIndex), -- 794
		systemPrompt, -- 795
		toolDefinitions -- 796
	) -- 796
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 799
	return messageTokens > threshold -- 801
end -- 787
function MemoryCompressor.prototype.compress(self, messages, lastConsolidatedMessageIndex, systemPrompt, toolDefinitions, llmOptions, maxLLMTry, decisionMode) -- 807
	if decisionMode == nil then -- 807
		decisionMode = "tool_calling" -- 814
	end -- 814
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 814
		local toCompress = __TS__ArraySlice(messages, lastConsolidatedMessageIndex) -- 816
		if #toCompress == 0 then -- 816
			return ____awaiter_resolve(nil, nil) -- 816
		end -- 816
		local boundary = self:findCompressionBoundary(toCompress, systemPrompt, toolDefinitions) -- 819
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 824
		if #chunk == 0 then -- 824
			return ____awaiter_resolve(nil, nil) -- 824
		end -- 824
		local currentMemory = self.storage:readMemory() -- 828
		local historyText = self:formatMessagesForCompression(chunk) -- 829
		local ____try = __TS__AsyncAwaiter(function() -- 829
			local result = __TS__Await(self:callLLMForCompression( -- 833
				currentMemory, -- 834
				historyText, -- 835
				llmOptions, -- 836
				maxLLMTry or 3, -- 837
				decisionMode -- 838
			)) -- 838
			if result.success then -- 838
				self.storage:writeMemory(result.memoryUpdate) -- 843
				self.storage:appendHistory(result.historyEntry) -- 844
				self.consecutiveFailures = 0 -- 845
				return ____awaiter_resolve( -- 845
					nil, -- 845
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 847
				) -- 847
			end -- 847
			return ____awaiter_resolve( -- 847
				nil, -- 847
				self:handleCompressionFailure(chunk, result.error or "Unknown error") -- 854
			) -- 854
		end) -- 854
		__TS__Await(____try.catch( -- 831
			____try, -- 831
			function(____, ____error) -- 831
				return ____awaiter_resolve( -- 831
					nil, -- 831
					self:handleCompressionFailure( -- 857
						chunk, -- 857
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 857
					) -- 857
				) -- 857
			end -- 857
		)) -- 857
	end) -- 857
end -- 807
function MemoryCompressor.prototype.findCompressionBoundary(self, messages, systemPrompt, toolDefinitions) -- 866
	local requiredTokens = self:getRequiredCompressionTokens(messages, systemPrompt, toolDefinitions) -- 871
	local targetTokens = math.min( -- 872
		self.config.maxTokensPerCompression, -- 873
		math.max(1, requiredTokens) -- 874
	) -- 874
	local accumulatedTokens = 0 -- 876
	local lastSafeBoundary = 0 -- 877
	local pendingToolCalls = {} -- 878
	local pendingToolCallCount = 0 -- 879
	do -- 879
		local i = 0 -- 881
		while i < #messages do -- 881
			local message = messages[i + 1] -- 882
			local tokens = ____exports.TokenEstimator:estimatePromptMessages({message}, "", "") -- 883
			accumulatedTokens = accumulatedTokens + tokens -- 884
			if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 884
				do -- 884
					local j = 0 -- 887
					while j < #message.tool_calls do -- 887
						local toolCallEntry = message.tool_calls[j + 1] -- 888
						local ____temp_7 -- 889
						if toolCallEntry and not __TS__ArrayIsArray(toolCallEntry) and type(toolCallEntry) == "table" then -- 889
							____temp_7 = toolCallEntry.id -- 894
						else -- 894
							____temp_7 = nil -- 895
						end -- 895
						local idValue = ____temp_7 -- 889
						local id = type(idValue) == "string" and idValue or "" -- 896
						if id ~= "" and pendingToolCalls[id] ~= true then -- 896
							pendingToolCalls[id] = true -- 898
							pendingToolCallCount = pendingToolCallCount + 1 -- 899
						end -- 899
						j = j + 1 -- 887
					end -- 887
				end -- 887
			end -- 887
			if message.role == "tool" and message.tool_call_id and pendingToolCalls[message.tool_call_id] == true then -- 887
				pendingToolCalls[message.tool_call_id] = false -- 905
				pendingToolCallCount = math.max(0, pendingToolCallCount - 1) -- 906
			end -- 906
			local isAtEnd = i >= #messages - 1 -- 909
			local nextRole = not isAtEnd and messages[i + 1 + 1].role or "" -- 910
			local isUserTurnBoundary = not isAtEnd and nextRole == "user" -- 911
			local isSafeBoundary = pendingToolCallCount == 0 and (isAtEnd or isUserTurnBoundary) -- 912
			if isSafeBoundary then -- 912
				lastSafeBoundary = i + 1 -- 914
			end -- 914
			if accumulatedTokens >= targetTokens and isSafeBoundary then -- 914
				return i + 1 -- 918
			end -- 918
			i = i + 1 -- 881
		end -- 881
	end -- 881
	if lastSafeBoundary > 0 then -- 881
		return lastSafeBoundary -- 922
	end -- 922
	return math.min(#messages, 1) -- 923
end -- 866
function MemoryCompressor.prototype.getRequiredCompressionTokens(self, messages, systemPrompt, toolDefinitions) -- 926
	local currentTokens = ____exports.TokenEstimator:estimatePromptMessages(messages, systemPrompt, toolDefinitions) -- 931
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 936
	local overflow = math.max(0, currentTokens - threshold) -- 937
	if overflow <= 0 then -- 937
		return math.min( -- 939
			self.config.maxTokensPerCompression, -- 940
			math.max( -- 941
				1, -- 941
				____exports.TokenEstimator:estimatePromptMessages( -- 941
					__TS__ArraySlice(messages, 0, 1), -- 941
					"", -- 941
					"" -- 941
				) -- 941
			) -- 941
		) -- 941
	end -- 941
	local safetyMargin = math.max( -- 944
		64, -- 944
		math.floor(threshold * 0.01) -- 944
	) -- 944
	return math.min(self.config.maxTokensPerCompression, overflow + safetyMargin) -- 945
end -- 926
function MemoryCompressor.prototype.formatMessagesForCompression(self, messages) -- 948
	local lines = {} -- 949
	do -- 949
		local i = 0 -- 950
		while i < #messages do -- 950
			local message = messages[i + 1] -- 951
			lines[#lines + 1] = (("Message " .. tostring(i + 1)) .. ": role=") .. message.role -- 952
			if message.name and message.name ~= "" then -- 952
				lines[#lines + 1] = "name=" .. message.name -- 953
			end -- 953
			if message.tool_call_id and message.tool_call_id ~= "" then -- 953
				lines[#lines + 1] = "tool_call_id=" .. message.tool_call_id -- 954
			end -- 954
			if message.reasoning_content and message.reasoning_content ~= "" then -- 954
				lines[#lines + 1] = "reasoning=" .. message.reasoning_content -- 955
			end -- 955
			if message.tool_calls and #message.tool_calls > 0 then -- 955
				local toolCallsText = json.encode(message.tool_calls) -- 957
				lines[#lines + 1] = "tool_calls=" .. (toolCallsText or "") -- 958
			end -- 958
			if message.content and message.content ~= "" then -- 958
				lines[#lines + 1] = message.content -- 960
			end -- 960
			if i < #messages - 1 then -- 960
				lines[#lines + 1] = "" -- 961
			end -- 961
			i = i + 1 -- 950
		end -- 950
	end -- 950
	return table.concat(lines, "\n") -- 963
end -- 948
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 969
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 969
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 976
		if decisionMode == "yaml" then -- 976
			return ____awaiter_resolve( -- 976
				nil, -- 976
				self:callLLMForCompressionByYAML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 978
			) -- 978
		end -- 978
		return ____awaiter_resolve( -- 978
			nil, -- 978
			self:callLLMForCompressionByToolCalling(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 985
		) -- 985
	end) -- 985
end -- 969
function MemoryCompressor.prototype.getContextWindow(self) -- 993
	return math.max(4000, self.config.llmConfig.contextWindow) -- 994
end -- 993
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 997
	local contextWindow = self:getContextWindow() -- 998
	local reservedOutputTokens = math.max( -- 999
		2048, -- 999
		math.floor(contextWindow * 0.2) -- 999
	) -- 999
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBodyRaw("", "")) -- 1000
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 1001
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 1002
	return math.max( -- 1003
		1200, -- 1003
		math.floor(available * 0.9) -- 1003
	) -- 1003
end -- 997
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 1006
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 1007
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 1008
	if historyTokens <= tokenBudget then -- 1008
		return historyText -- 1009
	end -- 1009
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 1010
	local targetChars = math.max( -- 1013
		2000, -- 1013
		math.floor(tokenBudget * charsPerToken) -- 1013
	) -- 1013
	local keepHead = math.max( -- 1014
		0, -- 1014
		math.floor(targetChars * 0.35) -- 1014
	) -- 1014
	local keepTail = math.max(0, targetChars - keepHead) -- 1015
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 1016
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 1017
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 1018
end -- 1006
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 1021
	local contextWindow = self:getContextWindow() -- 1025
	local reservedOutputTokens = math.max( -- 1026
		2048, -- 1026
		math.floor(contextWindow * 0.2) -- 1026
	) -- 1026
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBodyRaw("", "")) -- 1027
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 1028
	local boundedMemory = clipTextToTokenBudget( -- 1029
		currentMemory or "(empty)", -- 1029
		math.max( -- 1029
			320, -- 1029
			math.floor(dynamicBudget * 0.35) -- 1029
		) -- 1029
	) -- 1029
	local boundedHistory = clipTextToTokenBudget( -- 1030
		historyText, -- 1030
		math.max( -- 1030
			800, -- 1030
			math.floor(dynamicBudget * 0.65) -- 1030
		) -- 1030
	) -- 1030
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 1031
end -- 1021
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1037
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1037
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 1043
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 1046
		local messages = {{role = "system", content = self.config.promptPack.memoryCompressionSystemPrompt}, {role = "user", content = prompt}} -- 1070
		local fn -- 1081
		local argsText = "" -- 1082
		do -- 1082
			local i = 0 -- 1083
			while i < maxLLMTry do -- 1083
				local response = __TS__Await(callLLM( -- 1085
					messages, -- 1086
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 1087
					nil, -- 1092
					self.config.llmConfig -- 1093
				)) -- 1093
				if not response.success then -- 1093
					return ____awaiter_resolve(nil, { -- 1093
						success = false, -- 1098
						memoryUpdate = currentMemory, -- 1099
						historyEntry = "", -- 1100
						compressedCount = 0, -- 1101
						error = response.message -- 1102
					}) -- 1102
				end -- 1102
				local choice = response.response.choices and response.response.choices[1] -- 1106
				local message = choice and choice.message -- 1107
				local toolCalls = message and message.tool_calls -- 1108
				local toolCall = toolCalls and toolCalls[1] -- 1109
				fn = toolCall and toolCall["function"] -- 1110
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1111
				if fn ~= nil and #argsText > 0 then -- 1111
					break -- 1112
				end -- 1112
				i = i + 1 -- 1083
			end -- 1083
		end -- 1083
		if not fn or fn.name ~= "save_memory" then -- 1083
			return ____awaiter_resolve(nil, { -- 1083
				success = false, -- 1117
				memoryUpdate = currentMemory, -- 1118
				historyEntry = "", -- 1119
				compressedCount = 0, -- 1120
				error = "missing save_memory tool call" -- 1121
			}) -- 1121
		end -- 1121
		if __TS__StringTrim(argsText) == "" then -- 1121
			return ____awaiter_resolve(nil, { -- 1121
				success = false, -- 1127
				memoryUpdate = currentMemory, -- 1128
				historyEntry = "", -- 1129
				compressedCount = 0, -- 1130
				error = "empty save_memory tool arguments" -- 1131
			}) -- 1131
		end -- 1131
		local ____try = __TS__AsyncAwaiter(function() -- 1131
			local args, err = json.decode(argsText) -- 1137
			if err ~= nil or not args or type(args) ~= "table" then -- 1137
				return ____awaiter_resolve( -- 1137
					nil, -- 1137
					{ -- 1139
						success = false, -- 1140
						memoryUpdate = currentMemory, -- 1141
						historyEntry = "", -- 1142
						compressedCount = 0, -- 1143
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1144
					} -- 1144
				) -- 1144
			end -- 1144
			return ____awaiter_resolve( -- 1144
				nil, -- 1144
				self:buildCompressionResultFromObject(args, currentMemory) -- 1148
			) -- 1148
		end) -- 1148
		__TS__Await(____try.catch( -- 1136
			____try, -- 1136
			function(____, ____error) -- 1136
				return ____awaiter_resolve( -- 1136
					nil, -- 1136
					{ -- 1153
						success = false, -- 1154
						memoryUpdate = currentMemory, -- 1155
						historyEntry = "", -- 1156
						compressedCount = 0, -- 1157
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1158
					} -- 1158
				) -- 1158
			end -- 1158
		)) -- 1158
	end) -- 1158
end -- 1037
function MemoryCompressor.prototype.callLLMForCompressionByYAML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1163
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1163
		local prompt = self:buildYAMLCompressionPrompt(currentMemory, historyText) -- 1169
		local lastError = "invalid yaml response" -- 1170
		do -- 1170
			local i = 0 -- 1172
			while i < maxLLMTry do -- 1172
				do -- 1172
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionYamlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1173
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions, nil, self.config.llmConfig)) -- 1178
					if not response.success then -- 1178
						return ____awaiter_resolve(nil, { -- 1178
							success = false, -- 1187
							memoryUpdate = currentMemory, -- 1188
							historyEntry = "", -- 1189
							compressedCount = 0, -- 1190
							error = response.message -- 1191
						}) -- 1191
					end -- 1191
					local choice = response.response.choices and response.response.choices[1] -- 1195
					local message = choice and choice.message -- 1196
					local text = message and type(message.content) == "string" and message.content or "" -- 1197
					if __TS__StringTrim(text) == "" then -- 1197
						lastError = "empty yaml response" -- 1199
						goto __continue155 -- 1200
					end -- 1200
					local parsed = self:parseCompressionYAMLObject(text, currentMemory) -- 1203
					if parsed.success then -- 1203
						return ____awaiter_resolve(nil, parsed) -- 1203
					end -- 1203
					lastError = parsed.error or "invalid yaml response" -- 1207
				end -- 1207
				::__continue155:: -- 1207
				i = i + 1 -- 1172
			end -- 1172
		end -- 1172
		return ____awaiter_resolve(nil, { -- 1172
			success = false, -- 1211
			memoryUpdate = currentMemory, -- 1212
			historyEntry = "", -- 1213
			compressedCount = 0, -- 1214
			error = lastError -- 1215
		}) -- 1215
	end) -- 1215
end -- 1163
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1222
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1223
end -- 1222
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1229
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1230
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1231
end -- 1229
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 1237
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1238
end -- 1237
function MemoryCompressor.prototype.buildYAMLCompressionPrompt(self, currentMemory, historyText) -- 1243
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionYamlPrompt -- 1244
end -- 1243
function MemoryCompressor.prototype.extractYAMLFromText(self, text) -- 1249
	local source = __TS__StringTrim(text) -- 1250
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 1251
	if yamlFencePos >= 0 then -- 1251
		local from = yamlFencePos + #"```yaml" -- 1253
		local ____end = (string.find( -- 1254
			source, -- 1254
			"```", -- 1254
			math.max(from + 1, 1), -- 1254
			true -- 1254
		) or 0) - 1 -- 1254
		if ____end > from then -- 1254
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1255
		end -- 1255
	end -- 1255
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 1257
	if ymlFencePos >= 0 then -- 1257
		local from = ymlFencePos + #"```yml" -- 1259
		local ____end = (string.find( -- 1260
			source, -- 1260
			"```", -- 1260
			math.max(from + 1, 1), -- 1260
			true -- 1260
		) or 0) - 1 -- 1260
		if ____end > from then -- 1260
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1261
		end -- 1261
	end -- 1261
	return source -- 1263
end -- 1249
function MemoryCompressor.prototype.parseCompressionYAMLObject(self, text, currentMemory) -- 1266
	local yamlText = self:extractYAMLFromText(text) -- 1267
	local obj, err = yaml.parse(yamlText) -- 1268
	if not obj or type(obj) ~= "table" then -- 1268
		return { -- 1270
			success = false, -- 1271
			memoryUpdate = currentMemory, -- 1272
			historyEntry = "", -- 1273
			compressedCount = 0, -- 1274
			error = "invalid yaml: " .. tostring(err) -- 1275
		} -- 1275
	end -- 1275
	return self:buildCompressionResultFromObject(obj, currentMemory) -- 1278
end -- 1266
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1284
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1288
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1289
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1289
		return { -- 1291
			success = false, -- 1292
			memoryUpdate = currentMemory, -- 1293
			historyEntry = "", -- 1294
			compressedCount = 0, -- 1295
			error = "missing history_entry or memory_update" -- 1296
		} -- 1296
	end -- 1296
	local ts = os.date("%Y-%m-%d %H:%M") -- 1299
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1300
end -- 1284
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error) -- 1311
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1315
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1315
		self:rawArchive(chunk) -- 1318
		self.consecutiveFailures = 0 -- 1319
		return { -- 1321
			success = true, -- 1322
			memoryUpdate = self.storage:readMemory(), -- 1323
			historyEntry = "[RAW ARCHIVE] Detailed history not recorded", -- 1324
			compressedCount = #chunk -- 1325
		} -- 1325
	end -- 1325
	return { -- 1329
		success = false, -- 1330
		memoryUpdate = self.storage:readMemory(), -- 1331
		historyEntry = "", -- 1332
		compressedCount = 0, -- 1333
		error = ____error -- 1334
	} -- 1334
end -- 1311
function MemoryCompressor.prototype.rawArchive(self, chunk) -- 1341
	local ts = os.date("%Y-%m-%d %H:%M") -- 1342
	local firstUserMessage -- 1343
	do -- 1343
		local i = 0 -- 1344
		while i < #chunk do -- 1344
			if chunk[i + 1].role == "user" then -- 1344
				firstUserMessage = chunk[i + 1] -- 1346
				break -- 1347
			end -- 1347
			i = i + 1 -- 1344
		end -- 1344
	end -- 1344
	local prompt = firstUserMessage and firstUserMessage.content and __TS__StringTrim(firstUserMessage.content) ~= "" and __TS__StringReplace( -- 1350
		__TS__StringTrim(firstUserMessage.content), -- 1351
		"\n", -- 1351
		" " -- 1351
	) or "(empty prompt)" -- 1351
	local compactPrompt = #prompt > 160 and string.sub(prompt, 1, 160) .. "..." or prompt -- 1353
	self.storage:appendHistory(((((("[" .. ts) .. "] [RAW ARCHIVE] prompt=\"") .. compactPrompt) .. "\" (") .. tostring(#chunk)) .. " messages, compression failed; detailed history not recorded)") -- 1354
end -- 1341
function MemoryCompressor.prototype.getStorage(self) -- 1362
	return self.storage -- 1363
end -- 1362
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1366
	return math.max( -- 1367
		1, -- 1367
		math.floor(self.config.maxCompressionRounds) -- 1367
	) -- 1367
end -- 1366
MemoryCompressor.MAX_FAILURES = 3 -- 1366
return ____exports -- 1366