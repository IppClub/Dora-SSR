-- [ts]: Memory.ts
local ____lualib = require("lualib_bundle") -- 1
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
local ____Tools = require("Agent.Tools") -- 5
local sendWebIDEFileUpdate = ____Tools.sendWebIDEFileUpdate -- 5
local yaml = require("yaml") -- 6
____exports.DEFAULT_AGENT_PROMPT = "You are a coding assistant that helps modify and navigate code." -- 10
local AGENT_CONFIG_DIR = ".agent" -- 11
local AGENT_PROMPTS_FILE = "AGENT.md" -- 12
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 34
	agentIdentityPrompt = ____exports.DEFAULT_AGENT_PROMPT, -- 35
	decisionIntroPrompt = "Given the request and action history, decide which tool to use next.", -- 36
	toolDefinitionsShort = "Available tools:\n1. read_file: Read content from a file with pagination\n1b. read_file_range: Read specific line range from a file\n2. edit_file: Make changes to a file\n3. delete_file: Remove a file\n4. grep_files: Search text patterns inside files\n5. glob_files: Enumerate files under a directory with optional glob filters\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn\n8. finish: End and summarize", -- 37
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read content from a file with pagination\n\t- Parameters: path (workspace-relative), offset(optional), limit(optional)\n\t- Prefer small reads and continue with a new offset (>= 1) when needed.\n1b. read_file_range: Read specific line range from a file\n\t- Parameters: path, startLine, endLine\n\t- Line starts with 1.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- After one build completes, do not run build again unless files were edited/deleted. Read the result and then finish or take corrective action.\n\n8. finish: End and summarize\n\t- Parameters: {}", -- 47
	decisionRulesPrompt = "Decision rules:\n- Choose exactly one next action.\n- Keep params shallow and valid for the selected tool.\n- Prefer reading/searching before editing when information is missing.\n- After any search tool returns candidate files or docs, use read_file or read_file_range to inspect search result details instead of repeatedly broadening search.\n- Use glob_files to discover candidate files. Use grep_files only when you need to search file contents.\n- If the user asked a question, prefer finishing only after you can answer it in the final response.", -- 95
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (reason/message/summary).", -- 102
	replyLanguageDirectiveEn = "Use English for natural-language fields (reason/message/summary).", -- 103
	toolCallingSystemPrompt = "You are a coding assistant that must decide the next action by calling the next_step tool exactly once.", -- 104
	toolCallingNoPlainTextPrompt = "Do not answer with plain text.", -- 105
	toolCallingRetryPrompt = "Previous tool call was invalid ({{LAST_ERROR}}). Retry with one valid next_step tool call only.", -- 106
	yamlDecisionFormatPrompt = "Respond with one YAML object:\n```yaml\ntool: \"edit_file\"\nreason: |-\n\tA readable multi-line explanation is allowed.\n\tKeep indentation consistent.\nparams:\n\tpath: \"relative/path.ts\"\n\told_str: |-\n\t\tfunction oldName() {\n\t\t\tprint(\"old\");\n\t\t}\n\tnew_str: |-\n\t\tfunction newName() {\n\t\t\tprint(\"hello\");\n\t\t}\n```\nStrict YAML formatting rules:\n- Return YAML only, no prose before/after.\n- Use exactly one YAML object with keys: tool, reason, params.\n- Multi-line strings are allowed using block scalars (`|`, `|-`, `>`).\n- If using a block scalar, all content lines must be indented consistently with tabs.", -- 107
	finalSummaryPrompt = "You are a coding assistant. Summarize what you did for the user.\n\nHere are the actions you performed:\n{{SUMMARY}}\n\nGenerate a concise response that explains:\n1. What actions were taken\n2. What was found or modified\n3. Any next steps\n\nIMPORTANT:\n- Focus on outcomes, not tool names.\n- Speak directly to the user.\n- If the user asked a question, include a direct answer to that question in the response.\n{{LANGUAGE_DIRECTIVE}}", -- 129
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.", -- 144
	memoryCompressionBodyPrompt = "Process this conversation and consolidate it.\n\n### Current Long-term Memory\n{{CURRENT_MEMORY}}\n\n### Recent Actions to Process\n{{HISTORY_TEXT}}\n\n### Instructions\n\n1. **Analyze the conversation**:\n\t- What was the user trying to accomplish?\n\t- What tools were used and what were the results?\n\t- Were there any problems or solutions?\n\t- What decisions were made?\n\n2. **Update the long-term memory**:\n\t- Preserve all existing facts\n\t- Add new important information (user preferences, project context, decisions)\n\t- Remove outdated or redundant information\n\t- Keep the memory concise but complete\n\n3. **Create a history entry**:\n\t- Summarize key events, decisions, and outcomes\n\t- Include details useful for grep search\n\t- Format as a single paragraph", -- 145
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 171
	memoryCompressionYamlPrompt = "### Output Format\n\nReturn exactly one YAML object:\n```yaml\nhistory_entry: \"Summary paragraph\"\nmemory_update: |-\n\tFull updated MEMORY.md content\n```\n\nRules:\n- Return YAML only, no prose before or after.\n- Use exactly two keys: history_entry, memory_update.\n- Use a block scalar for memory_update when it spans multiple lines.", -- 176
	memoryCompressionYamlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid YAML object only." -- 189
} -- 189
____exports.PROMPT_PACK_KEYS = { -- 192
	"agentIdentityPrompt", -- 193
	"decisionIntroPrompt", -- 194
	"toolDefinitionsShort", -- 195
	"toolDefinitionsDetailed", -- 196
	"decisionRulesPrompt", -- 197
	"replyLanguageDirectiveZh", -- 198
	"replyLanguageDirectiveEn", -- 199
	"toolCallingSystemPrompt", -- 200
	"toolCallingNoPlainTextPrompt", -- 201
	"toolCallingRetryPrompt", -- 202
	"yamlDecisionFormatPrompt", -- 203
	"finalSummaryPrompt", -- 204
	"memoryCompressionSystemPrompt", -- 205
	"memoryCompressionBodyPrompt", -- 206
	"memoryCompressionToolCallingPrompt", -- 207
	"memoryCompressionYamlPrompt", -- 208
	"memoryCompressionYamlRetryPrompt" -- 209
} -- 209
local function replaceTemplateVars(template, vars) -- 212
	local output = template -- 213
	for key in pairs(vars) do -- 214
		output = table.concat( -- 215
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 215
			vars[key] or "" or "," -- 215
		) -- 215
	end -- 215
	return output -- 217
end -- 212
function ____exports.resolveAgentPromptPack(value) -- 220
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 221
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 221
		do -- 221
			local i = 0 -- 225
			while i < #____exports.PROMPT_PACK_KEYS do -- 225
				local key = ____exports.PROMPT_PACK_KEYS[i + 1] -- 226
				if type(value[key]) == "string" then -- 226
					merged[key] = value[key] -- 228
				end -- 228
				i = i + 1 -- 225
			end -- 225
		end -- 225
	end -- 225
	return merged -- 232
end -- 220
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 235
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 236
	local lines = {} -- 237
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 238
	lines[#lines + 1] = "" -- 239
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 240
	lines[#lines + 1] = "" -- 241
	do -- 241
		local i = 0 -- 242
		while i < #____exports.PROMPT_PACK_KEYS do -- 242
			local key = ____exports.PROMPT_PACK_KEYS[i + 1] -- 243
			lines[#lines + 1] = "## " .. key -- 244
			local text = pack[key] -- 245
			local split = __TS__StringSplit(text, "\n") -- 246
			do -- 246
				local j = 0 -- 247
				while j < #split do -- 247
					lines[#lines + 1] = split[j + 1] -- 248
					j = j + 1 -- 247
				end -- 247
			end -- 247
			lines[#lines + 1] = "" -- 250
			i = i + 1 -- 242
		end -- 242
	end -- 242
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 252
end -- 235
local function getPromptPackConfigPath(projectRoot) -- 255
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 256
end -- 255
local function ensurePromptPackConfig(projectRoot) -- 259
	local path = getPromptPackConfigPath(projectRoot) -- 260
	if Content:exist(path) then -- 260
		return nil -- 261
	end -- 261
	local dir = Path:getPath(path) -- 262
	if not Content:exist(dir) then -- 262
		Content:mkdir(dir) -- 264
	end -- 264
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 266
	if not Content:save(path, content) then -- 266
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 268
	end -- 268
	sendWebIDEFileUpdate(path, true, content) -- 270
	return nil -- 271
end -- 259
local function parsePromptPackMarkdown(text) -- 274
	if not text or __TS__StringTrim(text) == "" then -- 274
		return { -- 281
			value = {}, -- 282
			missing = {table.unpack(____exports.PROMPT_PACK_KEYS)}, -- 283
			unknown = {} -- 284
		} -- 284
	end -- 284
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 287
	local lines = __TS__StringSplit(normalized, "\n") -- 288
	local sections = {} -- 289
	local unknown = {} -- 290
	local currentHeading = "" -- 291
	local function isKnownPromptPackKey(name) -- 292
		do -- 292
			local i = 0 -- 293
			while i < #____exports.PROMPT_PACK_KEYS do -- 293
				if ____exports.PROMPT_PACK_KEYS[i + 1] == name then -- 293
					return true -- 294
				end -- 294
				i = i + 1 -- 293
			end -- 293
		end -- 293
		return false -- 296
	end -- 292
	do -- 292
		local i = 0 -- 298
		while i < #lines do -- 298
			do -- 298
				local line = lines[i + 1] -- 299
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 300
				if matchedHeading ~= nil then -- 300
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 302
					if isKnownPromptPackKey(heading) then -- 302
						currentHeading = heading -- 304
						if sections[currentHeading] == nil then -- 304
							sections[currentHeading] = {} -- 306
						end -- 306
						goto __continue27 -- 308
					end -- 308
					if currentHeading == "" then -- 308
						unknown[#unknown + 1] = heading -- 311
						goto __continue27 -- 312
					end -- 312
				end -- 312
				if currentHeading ~= "" then -- 312
					local ____sections_currentHeading_0 = sections[currentHeading] -- 312
					____sections_currentHeading_0[#____sections_currentHeading_0 + 1] = line -- 316
				end -- 316
			end -- 316
			::__continue27:: -- 316
			i = i + 1 -- 298
		end -- 298
	end -- 298
	local value = {} -- 319
	local missing = {} -- 320
	do -- 320
		local i = 0 -- 321
		while i < #____exports.PROMPT_PACK_KEYS do -- 321
			do -- 321
				local key = ____exports.PROMPT_PACK_KEYS[i + 1] -- 322
				local section = sections[key] -- 323
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 324
				if body == "" then -- 324
					missing[#missing + 1] = key -- 326
					goto __continue34 -- 327
				end -- 327
				value[key] = body -- 329
			end -- 329
			::__continue34:: -- 329
			i = i + 1 -- 321
		end -- 321
	end -- 321
	if #__TS__ObjectKeys(sections) == 0 then -- 321
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 332
	end -- 332
	return {value = value, missing = missing, unknown = unknown} -- 338
end -- 274
function ____exports.loadAgentPromptPack(projectRoot) -- 341
	local path = getPromptPackConfigPath(projectRoot) -- 342
	local warnings = {} -- 343
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 344
	if ensureWarning and ensureWarning ~= "" then -- 344
		warnings[#warnings + 1] = ensureWarning -- 346
	end -- 346
	if not Content:exist(path) then -- 346
		return { -- 349
			pack = ____exports.resolveAgentPromptPack(), -- 350
			warnings = warnings, -- 351
			path = path -- 352
		} -- 352
	end -- 352
	local text = Content:load(path) -- 355
	if not text or __TS__StringTrim(text) == "" then -- 355
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 357
		return { -- 358
			pack = ____exports.resolveAgentPromptPack(), -- 359
			warnings = warnings, -- 360
			path = path -- 361
		} -- 361
	end -- 361
	local parsed = parsePromptPackMarkdown(text) -- 364
	if parsed.error or not parsed.value then -- 364
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 366
		return { -- 367
			pack = ____exports.resolveAgentPromptPack(), -- 368
			warnings = warnings, -- 369
			path = path -- 370
		} -- 370
	end -- 370
	if #parsed.unknown > 0 then -- 370
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 374
	end -- 374
	if #parsed.missing > 0 then -- 374
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 377
	end -- 377
	return { -- 379
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 380
		warnings = warnings, -- 381
		path = path -- 382
	} -- 382
end -- 341
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 437
local TokenEstimator = ____exports.TokenEstimator -- 437
TokenEstimator.name = "TokenEstimator" -- 437
function TokenEstimator.prototype.____constructor(self) -- 437
end -- 437
function TokenEstimator.estimate(self, text) -- 447
	if not text then -- 447
		return 0 -- 448
	end -- 448
	local chineseChars = utf8.len(text) -- 451
	if not chineseChars then -- 451
		return 0 -- 452
	end -- 452
	local otherChars = #text - chineseChars -- 454
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 456
	return math.max(1, tokens) -- 461
end -- 447
function TokenEstimator.estimateHistory(self, history, formatFunc) -- 467
	if not history or #history == 0 then -- 467
		return 0 -- 468
	end -- 468
	local text = formatFunc(history) -- 469
	return self:estimate(text) -- 470
end -- 467
function TokenEstimator.estimatePrompt(self, userQuery, history, systemPrompt, toolDefinitions, formatFunc) -- 476
	return self:estimate(userQuery) + self:estimateHistory(history, formatFunc) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 483
end -- 476
TokenEstimator.CHARS_PER_TOKEN = 4 -- 476
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 476
local function utf8TakeHead(text, maxChars) -- 492
	if maxChars <= 0 or text == "" then -- 492
		return "" -- 493
	end -- 493
	local nextPos = utf8.offset(text, maxChars + 1) -- 494
	if nextPos == nil then -- 494
		return text -- 495
	end -- 495
	return string.sub(text, 1, nextPos - 1) -- 496
end -- 492
local function utf8TakeTail(text, maxChars) -- 499
	if maxChars <= 0 or text == "" then -- 499
		return "" -- 500
	end -- 500
	local charLen = utf8.len(text) -- 501
	if charLen == false or charLen <= maxChars then -- 501
		return text -- 502
	end -- 502
	local startChar = math.max(1, charLen - maxChars + 1) -- 503
	local startPos = utf8.offset(text, startChar) -- 504
	if startPos == nil then -- 504
		return text -- 505
	end -- 505
	return string.sub(text, startPos) -- 506
end -- 499
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 514
local DualLayerStorage = ____exports.DualLayerStorage -- 514
DualLayerStorage.name = "DualLayerStorage" -- 514
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 521
	self.projectDir = projectDir -- 522
	self.agentDir = Path(self.projectDir, ".agent") -- 523
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 524
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 525
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 526
	self:ensureAgentFiles() -- 527
end -- 521
function DualLayerStorage.prototype.ensureDir(self, dir) -- 530
	if not Content:exist(dir) then -- 530
		Content:mkdir(dir) -- 532
	end -- 532
end -- 530
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 536
	if Content:exist(path) then -- 536
		return false -- 537
	end -- 537
	self:ensureDir(Path:getPath(path)) -- 538
	if not Content:save(path, content) then -- 538
		return false -- 540
	end -- 540
	sendWebIDEFileUpdate(path, true, content) -- 542
	return true -- 543
end -- 536
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 546
	self:ensureDir(self.agentDir) -- 547
	self:ensureFile(self.memoryPath, "") -- 548
	self:ensureFile(self.historyPath, "") -- 549
end -- 546
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 552
	local text = json.encode(value) -- 553
	return text -- 554
end -- 552
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 557
	local value = json.decode(text) -- 558
	return value -- 559
end -- 557
function DualLayerStorage.prototype.decodeActionRecord(self, value) -- 562
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 562
		return nil -- 563
	end -- 563
	local row = value -- 564
	local tool = type(row.tool) == "string" and row.tool or "" -- 565
	local reason = type(row.reason) == "string" and row.reason or "" -- 566
	local timestamp = type(row.timestamp) == "string" and row.timestamp or "" -- 567
	if tool == "" or timestamp == "" then -- 567
		return nil -- 568
	end -- 568
	local params = row.params and not __TS__ArrayIsArray(row.params) and type(row.params) == "table" and row.params or ({}) -- 569
	local result = row.result and not __TS__ArrayIsArray(row.result) and type(row.result) == "table" and row.result or nil -- 572
	local ____math_max_3 = math.max -- 576
	local ____math_floor_2 = math.floor -- 576
	local ____row_step_1 = row.step -- 576
	if ____row_step_1 == nil then -- 576
		____row_step_1 = 1 -- 576
	end -- 576
	return { -- 575
		step = ____math_max_3( -- 576
			1, -- 576
			____math_floor_2(__TS__Number(____row_step_1)) -- 576
		), -- 576
		tool = tool, -- 577
		reason = reason, -- 578
		params = params, -- 579
		result = result, -- 580
		timestamp = timestamp -- 581
	} -- 581
end -- 562
function DualLayerStorage.prototype.readMemory(self) -- 590
	if not Content:exist(self.memoryPath) then -- 590
		return "" -- 592
	end -- 592
	return Content:load(self.memoryPath) -- 594
end -- 590
function DualLayerStorage.prototype.writeMemory(self, content) -- 600
	self:ensureDir(Path:getPath(self.memoryPath)) -- 601
	Content:save(self.memoryPath, content) -- 602
end -- 600
function DualLayerStorage.prototype.getMemoryContext(self) -- 608
	local memory = self:readMemory() -- 609
	if not memory then -- 609
		return "" -- 610
	end -- 610
	return "### Long-term Memory\n\n" .. memory -- 612
end -- 608
function DualLayerStorage.prototype.appendHistory(self, entry) -- 622
	self:ensureDir(Path:getPath(self.historyPath)) -- 623
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 625
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 629
end -- 622
function DualLayerStorage.prototype.readHistory(self) -- 635
	if not Content:exist(self.historyPath) then -- 635
		return "" -- 637
	end -- 637
	return Content:load(self.historyPath) -- 639
end -- 635
function DualLayerStorage.prototype.readSessionState(self) -- 642
	if not Content:exist(self.sessionPath) then -- 642
		return {history = {}, lastConsolidatedIndex = 0} -- 644
	end -- 644
	local text = Content:load(self.sessionPath) -- 646
	if not text or __TS__StringTrim(text) == "" then -- 646
		return {history = {}, lastConsolidatedIndex = 0} -- 648
	end -- 648
	local lines = __TS__StringSplit(text, "\n") -- 650
	local history = {} -- 651
	local lastConsolidatedIndex = 0 -- 652
	do -- 652
		local i = 0 -- 653
		while i < #lines do -- 653
			do -- 653
				local line = __TS__StringTrim(lines[i + 1]) -- 654
				if line == "" then -- 654
					goto __continue82 -- 655
				end -- 655
				local data = self:decodeJsonLine(line) -- 656
				if not data or __TS__ArrayIsArray(data) or type(data) ~= "table" then -- 656
					goto __continue82 -- 657
				end -- 657
				local row = data -- 658
				if row._type == "metadata" then -- 658
					local ____math_max_6 = math.max -- 660
					local ____math_floor_5 = math.floor -- 660
					local ____row_lastConsolidatedIndex_4 = row.lastConsolidatedIndex -- 660
					if ____row_lastConsolidatedIndex_4 == nil then -- 660
						____row_lastConsolidatedIndex_4 = 0 -- 660
					end -- 660
					lastConsolidatedIndex = ____math_max_6( -- 660
						0, -- 660
						____math_floor_5(__TS__Number(____row_lastConsolidatedIndex_4)) -- 660
					) -- 660
					goto __continue82 -- 661
				end -- 661
				local record = self:decodeActionRecord(row) -- 663
				if record then -- 663
					history[#history + 1] = record -- 665
				end -- 665
			end -- 665
			::__continue82:: -- 665
			i = i + 1 -- 653
		end -- 653
	end -- 653
	return { -- 668
		history = history, -- 669
		lastConsolidatedIndex = math.min(lastConsolidatedIndex, #history) -- 670
	} -- 670
end -- 642
function DualLayerStorage.prototype.writeSessionState(self, history, lastConsolidatedIndex) -- 674
	self:ensureDir(Path:getPath(self.sessionPath)) -- 675
	local lines = {} -- 676
	local meta = self:encodeJsonLine({ -- 677
		_type = "metadata", -- 678
		lastConsolidatedIndex = math.min( -- 679
			math.max( -- 679
				0, -- 679
				math.floor(lastConsolidatedIndex) -- 679
			), -- 679
			#history -- 679
		) -- 679
	}) -- 679
	if meta then -- 679
		lines[#lines + 1] = meta -- 682
	end -- 682
	do -- 682
		local i = 0 -- 684
		while i < #history do -- 684
			local line = self:encodeJsonLine(history[i + 1]) -- 685
			if line then -- 685
				lines[#lines + 1] = line -- 687
			end -- 687
			i = i + 1 -- 684
		end -- 684
	end -- 684
	local content = table.concat(lines, "\n") .. "\n" -- 690
	Content:save(self.sessionPath, content) -- 691
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 692
end -- 674
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 698
	local history = self:readHistory() -- 699
	if not history then -- 699
		return {} -- 700
	end -- 700
	local lines = __TS__StringSplit(history, "\n") -- 702
	local lowerKeyword = string.lower(keyword) -- 703
	return __TS__ArrayFilter( -- 705
		lines, -- 705
		function(____, line) return __TS__StringIncludes( -- 705
			string.lower(line), -- 706
			lowerKeyword -- 706
		) end -- 706
	) -- 706
end -- 698
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 719
local MemoryCompressor = ____exports.MemoryCompressor -- 719
MemoryCompressor.name = "MemoryCompressor" -- 719
function MemoryCompressor.prototype.____constructor(self, config) -- 726
	self.consecutiveFailures = 0 -- 722
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 727
	do -- 727
		local i = 0 -- 728
		while i < #loadedPromptPack.warnings do -- 728
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 729
			i = i + 1 -- 728
		end -- 728
	end -- 728
	local overridePack = config.promptPack and not __TS__ArrayIsArray(config.promptPack) and type(config.promptPack) == "table" and config.promptPack or nil -- 731
	self.config = __TS__ObjectAssign( -- 734
		{}, -- 734
		config, -- 735
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 734
	) -- 734
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 741
end -- 726
function MemoryCompressor.prototype.getPromptPack(self) -- 744
	return self.config.promptPack -- 745
end -- 744
function MemoryCompressor.prototype.shouldCompress(self, userQuery, history, lastConsolidatedIndex, systemPrompt, toolDefinitions, formatFunc) -- 751
	local uncompressedHistory = __TS__ArraySlice(history, lastConsolidatedIndex) -- 759
	local tokens = ____exports.TokenEstimator:estimatePrompt( -- 761
		userQuery, -- 762
		uncompressedHistory, -- 763
		systemPrompt, -- 764
		toolDefinitions, -- 765
		formatFunc -- 766
	) -- 766
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 769
	return tokens > threshold -- 771
end -- 751
function MemoryCompressor.prototype.compress(self, history, lastConsolidatedIndex, llmOptions, formatFunc, maxLLMTry, decisionMode) -- 777
	if decisionMode == nil then -- 777
		decisionMode = "tool_calling" -- 783
	end -- 783
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 783
		local toCompress = __TS__ArraySlice(history, lastConsolidatedIndex) -- 785
		if #toCompress == 0 then -- 785
			return ____awaiter_resolve(nil, nil) -- 785
		end -- 785
		local boundary = self:findCompressionBoundary(toCompress, formatFunc) -- 789
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 790
		if #chunk == 0 then -- 790
			return ____awaiter_resolve(nil, nil) -- 790
		end -- 790
		local currentMemory = self.storage:readMemory() -- 794
		local historyText = formatFunc(chunk) -- 795
		local ____try = __TS__AsyncAwaiter(function() -- 795
			local result = __TS__Await(self:callLLMForCompression( -- 799
				currentMemory, -- 800
				historyText, -- 801
				llmOptions, -- 802
				maxLLMTry or 3, -- 803
				decisionMode -- 804
			)) -- 804
			if result.success then -- 804
				self.storage:writeMemory(result.memoryUpdate) -- 809
				self.storage:appendHistory(result.historyEntry) -- 810
				self.consecutiveFailures = 0 -- 811
				return ____awaiter_resolve( -- 811
					nil, -- 811
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 813
				) -- 813
			end -- 813
			return ____awaiter_resolve( -- 813
				nil, -- 813
				self:handleCompressionFailure(chunk, result.error or "Unknown error", formatFunc) -- 820
			) -- 820
		end) -- 820
		__TS__Await(____try.catch( -- 797
			____try, -- 797
			function(____, ____error) -- 797
				return ____awaiter_resolve( -- 797
					nil, -- 797
					self:handleCompressionFailure( -- 824
						chunk, -- 825
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error", -- 826
						formatFunc -- 827
					) -- 827
				) -- 827
			end -- 827
		)) -- 827
	end) -- 827
end -- 777
function MemoryCompressor.prototype.findCompressionBoundary(self, history, formatFunc) -- 837
	local targetTokens = self.config.maxTokensPerCompression -- 841
	local accumulatedTokens = 0 -- 842
	do -- 842
		local i = 0 -- 844
		while i < #history do -- 844
			local record = history[i + 1] -- 845
			local tokens = ____exports.TokenEstimator:estimate(formatFunc({record})) -- 846
			accumulatedTokens = accumulatedTokens + tokens -- 850
			if accumulatedTokens > targetTokens then -- 850
				return math.max(1, i) -- 854
			end -- 854
			i = i + 1 -- 844
		end -- 844
	end -- 844
	return #history -- 858
end -- 837
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 864
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 864
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 871
		if decisionMode == "yaml" then -- 871
			return ____awaiter_resolve( -- 871
				nil, -- 871
				self:callLLMForCompressionByYAML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 873
			) -- 873
		end -- 873
		return ____awaiter_resolve( -- 873
			nil, -- 873
			self:callLLMForCompressionByToolCalling(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 880
		) -- 880
	end) -- 880
end -- 864
function MemoryCompressor.prototype.getContextWindow(self) -- 888
	return math.max(4000, self.config.llmConfig.contextWindow) -- 889
end -- 888
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 892
	local contextWindow = self:getContextWindow() -- 893
	local reservedOutputTokens = math.max( -- 894
		2048, -- 894
		math.floor(contextWindow * 0.2) -- 894
	) -- 894
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBody("", "")) -- 895
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 896
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 897
	return math.max( -- 898
		1200, -- 898
		math.floor(available * 0.9) -- 898
	) -- 898
end -- 892
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 901
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 902
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 903
	if historyTokens <= tokenBudget then -- 903
		return historyText -- 904
	end -- 904
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 905
	local targetChars = math.max( -- 908
		2000, -- 908
		math.floor(tokenBudget * charsPerToken) -- 908
	) -- 908
	local keepHead = math.max( -- 909
		0, -- 909
		math.floor(targetChars * 0.35) -- 909
	) -- 909
	local keepTail = math.max(0, targetChars - keepHead) -- 910
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 911
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 912
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 913
end -- 901
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 916
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 916
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 922
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 925
		local messages = {{role = "system", content = self.config.promptPack.memoryCompressionSystemPrompt}, {role = "user", content = prompt}} -- 949
		local fn -- 960
		local argsText = "" -- 961
		do -- 961
			local i = 0 -- 962
			while i < maxLLMTry do -- 962
				local response = __TS__Await(callLLM( -- 964
					messages, -- 965
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 966
					nil, -- 971
					self.config.llmConfig -- 972
				)) -- 972
				if not response.success then -- 972
					return ____awaiter_resolve(nil, { -- 972
						success = false, -- 977
						memoryUpdate = currentMemory, -- 978
						historyEntry = "", -- 979
						compressedCount = 0, -- 980
						error = response.message -- 981
					}) -- 981
				end -- 981
				local choice = response.response.choices and response.response.choices[1] -- 985
				local message = choice and choice.message -- 986
				local toolCalls = message and message.tool_calls -- 987
				local toolCall = toolCalls and toolCalls[1] -- 988
				fn = toolCall and toolCall["function"] -- 989
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 990
				if fn ~= nil and #argsText > 0 then -- 990
					break -- 991
				end -- 991
				i = i + 1 -- 962
			end -- 962
		end -- 962
		if not fn or fn.name ~= "save_memory" then -- 962
			return ____awaiter_resolve(nil, { -- 962
				success = false, -- 996
				memoryUpdate = currentMemory, -- 997
				historyEntry = "", -- 998
				compressedCount = 0, -- 999
				error = "missing save_memory tool call" -- 1000
			}) -- 1000
		end -- 1000
		if __TS__StringTrim(argsText) == "" then -- 1000
			return ____awaiter_resolve(nil, { -- 1000
				success = false, -- 1006
				memoryUpdate = currentMemory, -- 1007
				historyEntry = "", -- 1008
				compressedCount = 0, -- 1009
				error = "empty save_memory tool arguments" -- 1010
			}) -- 1010
		end -- 1010
		local ____try = __TS__AsyncAwaiter(function() -- 1010
			local args, err = json.decode(argsText) -- 1016
			if err ~= nil or not args or type(args) ~= "table" then -- 1016
				return ____awaiter_resolve( -- 1016
					nil, -- 1016
					{ -- 1018
						success = false, -- 1019
						memoryUpdate = currentMemory, -- 1020
						historyEntry = "", -- 1021
						compressedCount = 0, -- 1022
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1023
					} -- 1023
				) -- 1023
			end -- 1023
			return ____awaiter_resolve( -- 1023
				nil, -- 1023
				self:buildCompressionResultFromObject(args, currentMemory) -- 1027
			) -- 1027
		end) -- 1027
		__TS__Await(____try.catch( -- 1015
			____try, -- 1015
			function(____, ____error) -- 1015
				return ____awaiter_resolve( -- 1015
					nil, -- 1015
					{ -- 1032
						success = false, -- 1033
						memoryUpdate = currentMemory, -- 1034
						historyEntry = "", -- 1035
						compressedCount = 0, -- 1036
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1037
					} -- 1037
				) -- 1037
			end -- 1037
		)) -- 1037
	end) -- 1037
end -- 916
function MemoryCompressor.prototype.callLLMForCompressionByYAML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1042
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1042
		local prompt = self:buildYAMLCompressionPrompt(currentMemory, historyText) -- 1048
		local lastError = "invalid yaml response" -- 1049
		do -- 1049
			local i = 0 -- 1051
			while i < maxLLMTry do -- 1051
				do -- 1051
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionYamlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1052
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions, nil, self.config.llmConfig)) -- 1057
					if not response.success then -- 1057
						return ____awaiter_resolve(nil, { -- 1057
							success = false, -- 1066
							memoryUpdate = currentMemory, -- 1067
							historyEntry = "", -- 1068
							compressedCount = 0, -- 1069
							error = response.message -- 1070
						}) -- 1070
					end -- 1070
					local choice = response.response.choices and response.response.choices[1] -- 1074
					local message = choice and choice.message -- 1075
					local text = message and type(message.content) == "string" and message.content or "" -- 1076
					if __TS__StringTrim(text) == "" then -- 1076
						lastError = "empty yaml response" -- 1078
						goto __continue128 -- 1079
					end -- 1079
					local parsed = self:parseCompressionYAMLObject(text, currentMemory) -- 1082
					if parsed.success then -- 1082
						return ____awaiter_resolve(nil, parsed) -- 1082
					end -- 1082
					lastError = parsed.error or "invalid yaml response" -- 1086
				end -- 1086
				::__continue128:: -- 1086
				i = i + 1 -- 1051
			end -- 1051
		end -- 1051
		return ____awaiter_resolve(nil, { -- 1051
			success = false, -- 1090
			memoryUpdate = currentMemory, -- 1091
			historyEntry = "", -- 1092
			compressedCount = 0, -- 1093
			error = lastError -- 1094
		}) -- 1094
	end) -- 1094
end -- 1042
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1101
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1102
end -- 1101
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 1108
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1109
end -- 1108
function MemoryCompressor.prototype.buildYAMLCompressionPrompt(self, currentMemory, historyText) -- 1114
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionYamlPrompt -- 1115
end -- 1114
function MemoryCompressor.prototype.extractYAMLFromText(self, text) -- 1120
	local source = __TS__StringTrim(text) -- 1121
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 1122
	if yamlFencePos >= 0 then -- 1122
		local from = yamlFencePos + #"```yaml" -- 1124
		local ____end = (string.find( -- 1125
			source, -- 1125
			"```", -- 1125
			math.max(from + 1, 1), -- 1125
			true -- 1125
		) or 0) - 1 -- 1125
		if ____end > from then -- 1125
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1126
		end -- 1126
	end -- 1126
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 1128
	if ymlFencePos >= 0 then -- 1128
		local from = ymlFencePos + #"```yml" -- 1130
		local ____end = (string.find( -- 1131
			source, -- 1131
			"```", -- 1131
			math.max(from + 1, 1), -- 1131
			true -- 1131
		) or 0) - 1 -- 1131
		if ____end > from then -- 1131
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1132
		end -- 1132
	end -- 1132
	return source -- 1134
end -- 1120
function MemoryCompressor.prototype.parseCompressionYAMLObject(self, text, currentMemory) -- 1137
	local yamlText = self:extractYAMLFromText(text) -- 1138
	local obj, err = yaml.parse(yamlText) -- 1139
	if not obj or type(obj) ~= "table" then -- 1139
		return { -- 1141
			success = false, -- 1142
			memoryUpdate = currentMemory, -- 1143
			historyEntry = "", -- 1144
			compressedCount = 0, -- 1145
			error = "invalid yaml: " .. tostring(err) -- 1146
		} -- 1146
	end -- 1146
	return self:buildCompressionResultFromObject(obj, currentMemory) -- 1149
end -- 1137
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1155
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1159
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1160
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1160
		return { -- 1162
			success = false, -- 1163
			memoryUpdate = currentMemory, -- 1164
			historyEntry = "", -- 1165
			compressedCount = 0, -- 1166
			error = "missing history_entry or memory_update" -- 1167
		} -- 1167
	end -- 1167
	local ts = os.date("%Y-%m-%d %H:%M") -- 1170
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1171
end -- 1155
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error, formatFunc) -- 1182
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1187
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1187
		self:rawArchive(chunk, formatFunc) -- 1191
		self.consecutiveFailures = 0 -- 1192
		return { -- 1194
			success = true, -- 1195
			memoryUpdate = self.storage:readMemory(), -- 1196
			historyEntry = "[RAW ARCHIVE] See HISTORY.md for details", -- 1197
			compressedCount = #chunk -- 1198
		} -- 1198
	end -- 1198
	return { -- 1202
		success = false, -- 1203
		memoryUpdate = self.storage:readMemory(), -- 1204
		historyEntry = "", -- 1205
		compressedCount = 0, -- 1206
		error = ____error -- 1207
	} -- 1207
end -- 1182
function MemoryCompressor.prototype.rawArchive(self, chunk, formatFunc) -- 1214
	local ts = os.date("%Y-%m-%d %H:%M") -- 1215
	local text = formatFunc(chunk) -- 1216
	self.storage:appendHistory((((("[" .. ts) .. "] [RAW ARCHIVE] ") .. tostring(#chunk)) .. " actions (compression failed)\n") .. ("---\n" .. text) .. "\n---")
end -- 1214
function MemoryCompressor.prototype.getStorage(self) -- 1227
	return self.storage -- 1228
end -- 1227
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1231
	return math.max( -- 1232
		1, -- 1232
		math.floor(self.config.maxCompressionRounds) -- 1232
	) -- 1232
end -- 1231
MemoryCompressor.MAX_FAILURES = 3 -- 1231
return ____exports -- 1231