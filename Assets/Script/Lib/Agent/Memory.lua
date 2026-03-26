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
function MemoryCompressor.prototype.compress(self, userQuery, history, lastConsolidatedIndex, llmOptions, formatFunc, maxLLMTry, decisionMode) -- 777
	if decisionMode == nil then -- 777
		decisionMode = "tool_calling" -- 784
	end -- 784
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 784
		local toCompress = __TS__ArraySlice(history, lastConsolidatedIndex) -- 786
		if #toCompress == 0 then -- 786
			return ____awaiter_resolve(nil, nil) -- 786
		end -- 786
		local boundary = self:findCompressionBoundary(toCompress, formatFunc) -- 790
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 791
		if #chunk == 0 then -- 791
			return ____awaiter_resolve(nil, nil) -- 791
		end -- 791
		local currentMemory = self.storage:readMemory() -- 795
		local historyText = formatFunc(chunk) -- 796
		local ____try = __TS__AsyncAwaiter(function() -- 796
			local result = __TS__Await(self:callLLMForCompression( -- 800
				currentMemory, -- 801
				historyText, -- 802
				llmOptions, -- 803
				maxLLMTry or 3, -- 804
				decisionMode -- 805
			)) -- 805
			if result.success then -- 805
				self.storage:writeMemory(result.memoryUpdate) -- 810
				self.storage:appendHistory(result.historyEntry) -- 811
				self.consecutiveFailures = 0 -- 812
				return ____awaiter_resolve( -- 812
					nil, -- 812
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 814
				) -- 814
			end -- 814
			return ____awaiter_resolve( -- 814
				nil, -- 814
				self:handleCompressionFailure(userQuery, chunk, result.error or "Unknown error") -- 821
			) -- 821
		end) -- 821
		__TS__Await(____try.catch( -- 798
			____try, -- 798
			function(____, ____error) -- 798
				return ____awaiter_resolve( -- 798
					nil, -- 798
					self:handleCompressionFailure( -- 825
						userQuery, -- 826
						chunk, -- 827
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 828
					) -- 828
				) -- 828
			end -- 828
		)) -- 828
	end) -- 828
end -- 777
function MemoryCompressor.prototype.findCompressionBoundary(self, history, formatFunc) -- 838
	local targetTokens = self.config.maxTokensPerCompression -- 842
	local accumulatedTokens = 0 -- 843
	do -- 843
		local i = 0 -- 845
		while i < #history do -- 845
			local record = history[i + 1] -- 846
			local tokens = ____exports.TokenEstimator:estimate(formatFunc({record})) -- 847
			accumulatedTokens = accumulatedTokens + tokens -- 851
			if accumulatedTokens > targetTokens then -- 851
				return math.max(1, i) -- 855
			end -- 855
			i = i + 1 -- 845
		end -- 845
	end -- 845
	return #history -- 859
end -- 838
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 865
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 865
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 872
		if decisionMode == "yaml" then -- 872
			return ____awaiter_resolve( -- 872
				nil, -- 872
				self:callLLMForCompressionByYAML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 874
			) -- 874
		end -- 874
		return ____awaiter_resolve( -- 874
			nil, -- 874
			self:callLLMForCompressionByToolCalling(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 881
		) -- 881
	end) -- 881
end -- 865
function MemoryCompressor.prototype.getContextWindow(self) -- 889
	return math.max(4000, self.config.llmConfig.contextWindow) -- 890
end -- 889
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 893
	local contextWindow = self:getContextWindow() -- 894
	local reservedOutputTokens = math.max( -- 895
		2048, -- 895
		math.floor(contextWindow * 0.2) -- 895
	) -- 895
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBody("", "")) -- 896
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 897
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 898
	return math.max( -- 899
		1200, -- 899
		math.floor(available * 0.9) -- 899
	) -- 899
end -- 893
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 902
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 903
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 904
	if historyTokens <= tokenBudget then -- 904
		return historyText -- 905
	end -- 905
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 906
	local targetChars = math.max( -- 909
		2000, -- 909
		math.floor(tokenBudget * charsPerToken) -- 909
	) -- 909
	local keepHead = math.max( -- 910
		0, -- 910
		math.floor(targetChars * 0.35) -- 910
	) -- 910
	local keepTail = math.max(0, targetChars - keepHead) -- 911
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 912
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 913
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 914
end -- 902
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 917
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 917
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 923
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 926
		local messages = {{role = "system", content = self.config.promptPack.memoryCompressionSystemPrompt}, {role = "user", content = prompt}} -- 950
		local fn -- 961
		local argsText = "" -- 962
		do -- 962
			local i = 0 -- 963
			while i < maxLLMTry do -- 963
				local response = __TS__Await(callLLM( -- 965
					messages, -- 966
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 967
					nil, -- 972
					self.config.llmConfig -- 973
				)) -- 973
				if not response.success then -- 973
					return ____awaiter_resolve(nil, { -- 973
						success = false, -- 978
						memoryUpdate = currentMemory, -- 979
						historyEntry = "", -- 980
						compressedCount = 0, -- 981
						error = response.message -- 982
					}) -- 982
				end -- 982
				local choice = response.response.choices and response.response.choices[1] -- 986
				local message = choice and choice.message -- 987
				local toolCalls = message and message.tool_calls -- 988
				local toolCall = toolCalls and toolCalls[1] -- 989
				fn = toolCall and toolCall["function"] -- 990
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 991
				if fn ~= nil and #argsText > 0 then -- 991
					break -- 992
				end -- 992
				i = i + 1 -- 963
			end -- 963
		end -- 963
		if not fn or fn.name ~= "save_memory" then -- 963
			return ____awaiter_resolve(nil, { -- 963
				success = false, -- 997
				memoryUpdate = currentMemory, -- 998
				historyEntry = "", -- 999
				compressedCount = 0, -- 1000
				error = "missing save_memory tool call" -- 1001
			}) -- 1001
		end -- 1001
		if __TS__StringTrim(argsText) == "" then -- 1001
			return ____awaiter_resolve(nil, { -- 1001
				success = false, -- 1007
				memoryUpdate = currentMemory, -- 1008
				historyEntry = "", -- 1009
				compressedCount = 0, -- 1010
				error = "empty save_memory tool arguments" -- 1011
			}) -- 1011
		end -- 1011
		local ____try = __TS__AsyncAwaiter(function() -- 1011
			local args, err = json.decode(argsText) -- 1017
			if err ~= nil or not args or type(args) ~= "table" then -- 1017
				return ____awaiter_resolve( -- 1017
					nil, -- 1017
					{ -- 1019
						success = false, -- 1020
						memoryUpdate = currentMemory, -- 1021
						historyEntry = "", -- 1022
						compressedCount = 0, -- 1023
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1024
					} -- 1024
				) -- 1024
			end -- 1024
			return ____awaiter_resolve( -- 1024
				nil, -- 1024
				self:buildCompressionResultFromObject(args, currentMemory) -- 1028
			) -- 1028
		end) -- 1028
		__TS__Await(____try.catch( -- 1016
			____try, -- 1016
			function(____, ____error) -- 1016
				return ____awaiter_resolve( -- 1016
					nil, -- 1016
					{ -- 1033
						success = false, -- 1034
						memoryUpdate = currentMemory, -- 1035
						historyEntry = "", -- 1036
						compressedCount = 0, -- 1037
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1038
					} -- 1038
				) -- 1038
			end -- 1038
		)) -- 1038
	end) -- 1038
end -- 917
function MemoryCompressor.prototype.callLLMForCompressionByYAML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1043
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1043
		local prompt = self:buildYAMLCompressionPrompt(currentMemory, historyText) -- 1049
		local lastError = "invalid yaml response" -- 1050
		do -- 1050
			local i = 0 -- 1052
			while i < maxLLMTry do -- 1052
				do -- 1052
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionYamlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1053
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions, nil, self.config.llmConfig)) -- 1058
					if not response.success then -- 1058
						return ____awaiter_resolve(nil, { -- 1058
							success = false, -- 1067
							memoryUpdate = currentMemory, -- 1068
							historyEntry = "", -- 1069
							compressedCount = 0, -- 1070
							error = response.message -- 1071
						}) -- 1071
					end -- 1071
					local choice = response.response.choices and response.response.choices[1] -- 1075
					local message = choice and choice.message -- 1076
					local text = message and type(message.content) == "string" and message.content or "" -- 1077
					if __TS__StringTrim(text) == "" then -- 1077
						lastError = "empty yaml response" -- 1079
						goto __continue128 -- 1080
					end -- 1080
					local parsed = self:parseCompressionYAMLObject(text, currentMemory) -- 1083
					if parsed.success then -- 1083
						return ____awaiter_resolve(nil, parsed) -- 1083
					end -- 1083
					lastError = parsed.error or "invalid yaml response" -- 1087
				end -- 1087
				::__continue128:: -- 1087
				i = i + 1 -- 1052
			end -- 1052
		end -- 1052
		return ____awaiter_resolve(nil, { -- 1052
			success = false, -- 1091
			memoryUpdate = currentMemory, -- 1092
			historyEntry = "", -- 1093
			compressedCount = 0, -- 1094
			error = lastError -- 1095
		}) -- 1095
	end) -- 1095
end -- 1043
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1102
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1103
end -- 1102
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 1109
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1110
end -- 1109
function MemoryCompressor.prototype.buildYAMLCompressionPrompt(self, currentMemory, historyText) -- 1115
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionYamlPrompt -- 1116
end -- 1115
function MemoryCompressor.prototype.extractYAMLFromText(self, text) -- 1121
	local source = __TS__StringTrim(text) -- 1122
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 1123
	if yamlFencePos >= 0 then -- 1123
		local from = yamlFencePos + #"```yaml" -- 1125
		local ____end = (string.find( -- 1126
			source, -- 1126
			"```", -- 1126
			math.max(from + 1, 1), -- 1126
			true -- 1126
		) or 0) - 1 -- 1126
		if ____end > from then -- 1126
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1127
		end -- 1127
	end -- 1127
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 1129
	if ymlFencePos >= 0 then -- 1129
		local from = ymlFencePos + #"```yml" -- 1131
		local ____end = (string.find( -- 1132
			source, -- 1132
			"```", -- 1132
			math.max(from + 1, 1), -- 1132
			true -- 1132
		) or 0) - 1 -- 1132
		if ____end > from then -- 1132
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1133
		end -- 1133
	end -- 1133
	return source -- 1135
end -- 1121
function MemoryCompressor.prototype.parseCompressionYAMLObject(self, text, currentMemory) -- 1138
	local yamlText = self:extractYAMLFromText(text) -- 1139
	local obj, err = yaml.parse(yamlText) -- 1140
	if not obj or type(obj) ~= "table" then -- 1140
		return { -- 1142
			success = false, -- 1143
			memoryUpdate = currentMemory, -- 1144
			historyEntry = "", -- 1145
			compressedCount = 0, -- 1146
			error = "invalid yaml: " .. tostring(err) -- 1147
		} -- 1147
	end -- 1147
	return self:buildCompressionResultFromObject(obj, currentMemory) -- 1150
end -- 1138
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1156
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1160
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1161
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1161
		return { -- 1163
			success = false, -- 1164
			memoryUpdate = currentMemory, -- 1165
			historyEntry = "", -- 1166
			compressedCount = 0, -- 1167
			error = "missing history_entry or memory_update" -- 1168
		} -- 1168
	end -- 1168
	local ts = os.date("%Y-%m-%d %H:%M") -- 1171
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1172
end -- 1156
function MemoryCompressor.prototype.handleCompressionFailure(self, userQuery, chunk, ____error) -- 1183
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1188
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1188
		self:rawArchive(userQuery, chunk) -- 1192
		self.consecutiveFailures = 0 -- 1193
		return { -- 1195
			success = true, -- 1196
			memoryUpdate = self.storage:readMemory(), -- 1197
			historyEntry = "[RAW ARCHIVE] Detailed history not recorded", -- 1198
			compressedCount = #chunk -- 1199
		} -- 1199
	end -- 1199
	return { -- 1203
		success = false, -- 1204
		memoryUpdate = self.storage:readMemory(), -- 1205
		historyEntry = "", -- 1206
		compressedCount = 0, -- 1207
		error = ____error -- 1208
	} -- 1208
end -- 1183
function MemoryCompressor.prototype.rawArchive(self, userQuery, chunk) -- 1215
	local ts = os.date("%Y-%m-%d %H:%M") -- 1216
	local prompt = __TS__StringTrim(userQuery) ~= "" and __TS__StringReplace( -- 1217
		__TS__StringTrim(userQuery), -- 1218
		"\n", -- 1218
		" " -- 1218
	) or "(empty prompt)" -- 1218
	local compactPrompt = #prompt > 160 and string.sub(prompt, 1, 160) .. "..." or prompt -- 1220
	self.storage:appendHistory(((((("[" .. ts) .. "] [RAW ARCHIVE] prompt=\"") .. compactPrompt) .. "\" (") .. tostring(#chunk)) .. " actions, compression failed; detailed history not recorded)") -- 1221
end -- 1215
function MemoryCompressor.prototype.getStorage(self) -- 1229
	return self.storage -- 1230
end -- 1229
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1233
	return math.max( -- 1234
		1, -- 1234
		math.floor(self.config.maxCompressionRounds) -- 1234
	) -- 1234
end -- 1233
MemoryCompressor.MAX_FAILURES = 3 -- 1233
return ____exports -- 1233