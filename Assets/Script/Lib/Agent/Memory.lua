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
local AGENT_CONFIG_DIR = ".agent" -- 10
local AGENT_PROMPTS_FILE = "AGENT.md" -- 11
____exports.DEFAULT_AGENT_PROMPT_PACK = { -- 30
	agentIdentityPrompt = "### Dora Agent (｡•̀ᴗ-)✧💕\n\nYou are a coding assistant that helps modify and navigate code in the Dora SSR game engine project.\n\n### Guidelines\n\n- State intent before tool calls, but NEVER predict or claim results before receiving them.\n- Before modifying a file, read it first. Do not assume files or directories exist.\n- After writing or editing a file, re-read it if accuracy matters.\n- If a tool call fails, analyze the error before retrying with a different approach.\n- Ask for clarification when the request is ambiguous.\n- Prefer reading and searching before editing when information is missing.\n- Focus on outcomes, not tool names. Speak directly to the user.", -- 31
	decisionIntroPrompt = "Given the request and action history, decide which tool to use next.", -- 44
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Line starts with 1. startLine defaults to 1 and endLine defaults to 300.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- After one build completes, do not run build again unless files were edited/deleted. Read the result and then finish or take corrective action.\n\n8. finish: End and summarize\n\t- Parameters: {}\n\n9. message: Send a short user-facing progress update\n\t- Parameters: content\n\t- Use this only when you need to say something to the user before continuing with more tool decisions.", -- 45
	decisionRulesPrompt = "Decision rules:\n- Choose exactly one next action.\n- Keep params shallow and valid for the selected tool.\n- Prefer reading/searching before editing when information is missing.\n- After any search tool returns candidate files or docs, use read_file to inspect relevant line ranges instead of repeatedly broadening search.\n- Use glob_files to discover candidate files. Use grep_files only when you need to search file contents.\n- If the user asked a question, prefer finishing only after you can answer it in the final response.", -- 94
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 101
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 102
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 103
	yamlDecisionFormatPrompt = "Respond with exactly one YAML object. Do not include any prose before or after the YAML.\n\n```yaml\ntool: \"edit_file\"\nparams:\n\tpath: \"relative/path.ts\"\n\told_str: |-\n\t\tfunction oldName() {\n\t\t\tprint(\"old\");\n\t\t}\n\tnew_str: |-\n\t\tfunction newName() {\n\t\t\tprint(\"hello\");\n\t\t}\n```\n\nRules:\n- Use exactly one YAML object with keys: tool, params.\n- Multi-line strings use block scalars (`|`, `|-`, `>`).\n- If using a block scalar, all content lines must be indented consistently with tabs.\n- For nested multi-line fields (e.g. params.new_str), indent the block content deeper than the key line using tabs.\n- Keep params shallow and valid for the selected tool.\n- Use tabs for all indentation, never spaces.\n- If no more actions are needed, use tool: finish.", -- 104
	finalSummaryPrompt = "You are a coding assistant. Provide a concise summary of what you did.\n\nHere are the actions you performed:\n{{SUMMARY}}\n\nGenerate a response that:\n1. Explains what actions were taken and what was found/modified\n2. Speaks directly to the in a natural, friendly manner\n3. If the user asked a question, includes a direct answer\n4. Focuses on outcomes, not technical tool names\n\nIMPORTANT:\n- Be concise (1-3 sentences unless more detail is needed)\n- Do not mention internal details like tool names or step numbers\n{{LANGUAGE_DIRECTIVE}}", -- 128
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.", -- 143
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n---\n\n### Actions to Process\n\n{{HISTORY_TEXT}}\n\n---\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph for HISTORY.md\n\t- Include timestamp and key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.",
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 183
	memoryCompressionYamlPrompt = "### Output Format\n\nReturn exactly one YAML object:\n```yaml\nhistory_entry: \"Summary paragraph\"\nmemory_update: |-\n\tFull updated MEMORY.md content\n```\n\nRules:\n- Return YAML only, no prose before or after.\n- Use exactly two keys: history_entry, memory_update.\n- Use a block scalar for memory_update when it spans multiple lines.", -- 188
	memoryCompressionYamlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid YAML object only." -- 201
} -- 201
local EXPOSED_PROMPT_PACK_KEYS = { -- 204
	"agentIdentityPrompt", -- 205
	"decisionIntroPrompt", -- 206
	"decisionRulesPrompt", -- 207
	"replyLanguageDirectiveZh", -- 208
	"replyLanguageDirectiveEn", -- 209
	"finalSummaryPrompt", -- 210
	"memoryCompressionBodyPrompt" -- 211
} -- 211
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 211
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 211
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 214
local function replaceTemplateVars(template, vars) -- 219
	local output = template -- 220
	for key in pairs(vars) do -- 221
		output = table.concat( -- 222
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 222
			vars[key] or "" or "," -- 222
		) -- 222
	end -- 222
	return output -- 224
end -- 219
function ____exports.resolveAgentPromptPack(value) -- 227
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 228
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 228
		do -- 228
			local i = 0 -- 232
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 232
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 233
				if type(value[key]) == "string" then -- 233
					merged[key] = value[key] -- 235
				end -- 235
				i = i + 1 -- 232
			end -- 232
		end -- 232
	end -- 232
	return merged -- 239
end -- 227
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 242
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 243
	local lines = {} -- 244
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 245
	lines[#lines + 1] = "" -- 246
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 247
	lines[#lines + 1] = "" -- 248
	do -- 248
		local i = 0 -- 249
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 249
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 250
			lines[#lines + 1] = "## " .. key -- 251
			local text = pack[key] -- 252
			local split = __TS__StringSplit(text, "\n") -- 253
			do -- 253
				local j = 0 -- 254
				while j < #split do -- 254
					lines[#lines + 1] = split[j + 1] -- 255
					j = j + 1 -- 254
				end -- 254
			end -- 254
			lines[#lines + 1] = "" -- 257
			i = i + 1 -- 249
		end -- 249
	end -- 249
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 259
end -- 242
local function getPromptPackConfigPath(projectRoot) -- 262
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 263
end -- 262
local function ensurePromptPackConfig(projectRoot) -- 266
	local path = getPromptPackConfigPath(projectRoot) -- 267
	if Content:exist(path) then -- 267
		return nil -- 268
	end -- 268
	local dir = Path:getPath(path) -- 269
	if not Content:exist(dir) then -- 269
		Content:mkdir(dir) -- 271
	end -- 271
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 273
	if not Content:save(path, content) then -- 273
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 275
	end -- 275
	sendWebIDEFileUpdate(path, true, content) -- 277
	return nil -- 278
end -- 266
local function parsePromptPackMarkdown(text) -- 281
	if not text or __TS__StringTrim(text) == "" then -- 281
		return { -- 288
			value = {}, -- 289
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 290
			unknown = {} -- 291
		} -- 291
	end -- 291
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 294
	local lines = __TS__StringSplit(normalized, "\n") -- 295
	local sections = {} -- 296
	local unknown = {} -- 297
	local currentHeading = "" -- 298
	local function isKnownPromptPackKey(name) -- 299
		do -- 299
			local i = 0 -- 300
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 300
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 300
					return true -- 301
				end -- 301
				i = i + 1 -- 300
			end -- 300
		end -- 300
		return false -- 303
	end -- 299
	do -- 299
		local i = 0 -- 305
		while i < #lines do -- 305
			do -- 305
				local line = lines[i + 1] -- 306
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 307
				if matchedHeading ~= nil then -- 307
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 309
					if isKnownPromptPackKey(heading) then -- 309
						currentHeading = heading -- 311
						if sections[currentHeading] == nil then -- 311
							sections[currentHeading] = {} -- 313
						end -- 313
						goto __continue27 -- 315
					end -- 315
					if currentHeading == "" then -- 315
						unknown[#unknown + 1] = heading -- 318
						goto __continue27 -- 319
					end -- 319
				end -- 319
				if currentHeading ~= "" then -- 319
					local ____sections_currentHeading_1 = sections[currentHeading] -- 319
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 323
				end -- 323
			end -- 323
			::__continue27:: -- 323
			i = i + 1 -- 305
		end -- 305
	end -- 305
	local value = {} -- 326
	local missing = {} -- 327
	do -- 327
		local i = 0 -- 328
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 328
			do -- 328
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 329
				local section = sections[key] -- 330
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 331
				if body == "" then -- 331
					missing[#missing + 1] = key -- 333
					goto __continue34 -- 334
				end -- 334
				value[key] = body -- 336
			end -- 336
			::__continue34:: -- 336
			i = i + 1 -- 328
		end -- 328
	end -- 328
	if #__TS__ObjectKeys(sections) == 0 then -- 328
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 339
	end -- 339
	return {value = value, missing = missing, unknown = unknown} -- 345
end -- 281
function ____exports.loadAgentPromptPack(projectRoot) -- 348
	local path = getPromptPackConfigPath(projectRoot) -- 349
	local warnings = {} -- 350
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 351
	if ensureWarning and ensureWarning ~= "" then -- 351
		warnings[#warnings + 1] = ensureWarning -- 353
	end -- 353
	if not Content:exist(path) then -- 353
		return { -- 356
			pack = ____exports.resolveAgentPromptPack(), -- 357
			warnings = warnings, -- 358
			path = path -- 359
		} -- 359
	end -- 359
	local text = Content:load(path) -- 362
	if not text or __TS__StringTrim(text) == "" then -- 362
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 364
		return { -- 365
			pack = ____exports.resolveAgentPromptPack(), -- 366
			warnings = warnings, -- 367
			path = path -- 368
		} -- 368
	end -- 368
	local parsed = parsePromptPackMarkdown(text) -- 371
	if parsed.error or not parsed.value then -- 371
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 373
		return { -- 374
			pack = ____exports.resolveAgentPromptPack(), -- 375
			warnings = warnings, -- 376
			path = path -- 377
		} -- 377
	end -- 377
	if #parsed.unknown > 0 then -- 377
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 381
	end -- 381
	if #parsed.missing > 0 then -- 381
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 384
	end -- 384
	return { -- 386
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 387
		warnings = warnings, -- 388
		path = path -- 389
	} -- 389
end -- 348
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 444
local TokenEstimator = ____exports.TokenEstimator -- 444
TokenEstimator.name = "TokenEstimator" -- 444
function TokenEstimator.prototype.____constructor(self) -- 444
end -- 444
function TokenEstimator.estimate(self, text) -- 454
	if not text then -- 454
		return 0 -- 455
	end -- 455
	local chineseChars = utf8.len(text) -- 458
	if not chineseChars then -- 458
		return 0 -- 459
	end -- 459
	local otherChars = #text - chineseChars -- 461
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 463
	return math.max(1, tokens) -- 468
end -- 454
function TokenEstimator.estimateHistory(self, history, formatFunc) -- 474
	if not history or #history == 0 then -- 474
		return 0 -- 475
	end -- 475
	local text = formatFunc(history) -- 476
	return self:estimate(text) -- 477
end -- 474
function TokenEstimator.estimatePrompt(self, userQuery, history, systemPrompt, toolDefinitions, formatFunc) -- 483
	return self:estimate(userQuery) + self:estimateHistory(history, formatFunc) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 490
end -- 483
TokenEstimator.CHARS_PER_TOKEN = 4 -- 483
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 483
local function utf8TakeHead(text, maxChars) -- 499
	if maxChars <= 0 or text == "" then -- 499
		return "" -- 500
	end -- 500
	local nextPos = utf8.offset(text, maxChars + 1) -- 501
	if nextPos == nil then -- 501
		return text -- 502
	end -- 502
	return string.sub(text, 1, nextPos - 1) -- 503
end -- 499
local function utf8TakeTail(text, maxChars) -- 506
	if maxChars <= 0 or text == "" then -- 506
		return "" -- 507
	end -- 507
	local charLen = utf8.len(text) -- 508
	if charLen == false or charLen <= maxChars then -- 508
		return text -- 509
	end -- 509
	local startChar = math.max(1, charLen - maxChars + 1) -- 510
	local startPos = utf8.offset(text, startChar) -- 511
	if startPos == nil then -- 511
		return text -- 512
	end -- 512
	return string.sub(text, startPos) -- 513
end -- 506
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 521
local DualLayerStorage = ____exports.DualLayerStorage -- 521
DualLayerStorage.name = "DualLayerStorage" -- 521
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 528
	self.projectDir = projectDir -- 529
	self.agentDir = Path(self.projectDir, ".agent") -- 530
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 531
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 532
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 533
	self:ensureAgentFiles() -- 534
end -- 528
function DualLayerStorage.prototype.ensureDir(self, dir) -- 537
	if not Content:exist(dir) then -- 537
		Content:mkdir(dir) -- 539
	end -- 539
end -- 537
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 543
	if Content:exist(path) then -- 543
		return false -- 544
	end -- 544
	self:ensureDir(Path:getPath(path)) -- 545
	if not Content:save(path, content) then -- 545
		return false -- 547
	end -- 547
	sendWebIDEFileUpdate(path, true, content) -- 549
	return true -- 550
end -- 543
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 553
	self:ensureDir(self.agentDir) -- 554
	self:ensureFile(self.memoryPath, "") -- 555
	self:ensureFile(self.historyPath, "") -- 556
end -- 553
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 559
	local text = json.encode(value) -- 560
	return text -- 561
end -- 559
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 564
	local value = json.decode(text) -- 565
	return value -- 566
end -- 564
function DualLayerStorage.prototype.decodeActionRecord(self, value) -- 569
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 569
		return nil -- 570
	end -- 570
	local row = value -- 571
	local tool = type(row.tool) == "string" and row.tool or "" -- 572
	local reason = type(row.reason) == "string" and row.reason or "" -- 573
	local timestamp = type(row.timestamp) == "string" and row.timestamp or "" -- 574
	if tool == "" or timestamp == "" then -- 574
		return nil -- 575
	end -- 575
	local params = row.params and not __TS__ArrayIsArray(row.params) and type(row.params) == "table" and row.params or ({}) -- 576
	local result = row.result and not __TS__ArrayIsArray(row.result) and type(row.result) == "table" and row.result or nil -- 579
	local ____math_max_4 = math.max -- 583
	local ____math_floor_3 = math.floor -- 583
	local ____row_step_2 = row.step -- 583
	if ____row_step_2 == nil then -- 583
		____row_step_2 = 1 -- 583
	end -- 583
	return { -- 582
		step = ____math_max_4( -- 583
			1, -- 583
			____math_floor_3(__TS__Number(____row_step_2)) -- 583
		), -- 583
		tool = tool, -- 584
		reason = reason, -- 585
		params = params, -- 586
		result = result, -- 587
		timestamp = timestamp -- 588
	} -- 588
end -- 569
function DualLayerStorage.prototype.readMemory(self) -- 597
	if not Content:exist(self.memoryPath) then -- 597
		return "" -- 599
	end -- 599
	return Content:load(self.memoryPath) -- 601
end -- 597
function DualLayerStorage.prototype.writeMemory(self, content) -- 607
	self:ensureDir(Path:getPath(self.memoryPath)) -- 608
	Content:save(self.memoryPath, content) -- 609
end -- 607
function DualLayerStorage.prototype.getMemoryContext(self) -- 615
	local memory = self:readMemory() -- 616
	if not memory then -- 616
		return "" -- 617
	end -- 617
	return "### Long-term Memory\n\n" .. memory -- 619
end -- 615
function DualLayerStorage.prototype.appendHistory(self, entry) -- 629
	self:ensureDir(Path:getPath(self.historyPath)) -- 630
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 632
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 636
end -- 629
function DualLayerStorage.prototype.readHistory(self) -- 642
	if not Content:exist(self.historyPath) then -- 642
		return "" -- 644
	end -- 644
	return Content:load(self.historyPath) -- 646
end -- 642
function DualLayerStorage.prototype.readSessionState(self) -- 649
	if not Content:exist(self.sessionPath) then -- 649
		return {history = {}, lastConsolidatedIndex = 0} -- 651
	end -- 651
	local text = Content:load(self.sessionPath) -- 653
	if not text or __TS__StringTrim(text) == "" then -- 653
		return {history = {}, lastConsolidatedIndex = 0} -- 655
	end -- 655
	local lines = __TS__StringSplit(text, "\n") -- 657
	local history = {} -- 658
	local lastConsolidatedIndex = 0 -- 659
	do -- 659
		local i = 0 -- 660
		while i < #lines do -- 660
			do -- 660
				local line = __TS__StringTrim(lines[i + 1]) -- 661
				if line == "" then -- 661
					goto __continue82 -- 662
				end -- 662
				local data = self:decodeJsonLine(line) -- 663
				if not data or __TS__ArrayIsArray(data) or type(data) ~= "table" then -- 663
					goto __continue82 -- 664
				end -- 664
				local row = data -- 665
				if row._type == "metadata" then -- 665
					local ____math_max_7 = math.max -- 667
					local ____math_floor_6 = math.floor -- 667
					local ____row_lastConsolidatedIndex_5 = row.lastConsolidatedIndex -- 667
					if ____row_lastConsolidatedIndex_5 == nil then -- 667
						____row_lastConsolidatedIndex_5 = 0 -- 667
					end -- 667
					lastConsolidatedIndex = ____math_max_7( -- 667
						0, -- 667
						____math_floor_6(__TS__Number(____row_lastConsolidatedIndex_5)) -- 667
					) -- 667
					goto __continue82 -- 668
				end -- 668
				local record = self:decodeActionRecord(row) -- 670
				if record then -- 670
					history[#history + 1] = record -- 672
				end -- 672
			end -- 672
			::__continue82:: -- 672
			i = i + 1 -- 660
		end -- 660
	end -- 660
	return { -- 675
		history = history, -- 676
		lastConsolidatedIndex = math.min(lastConsolidatedIndex, #history) -- 677
	} -- 677
end -- 649
function DualLayerStorage.prototype.writeSessionState(self, history, lastConsolidatedIndex) -- 681
	self:ensureDir(Path:getPath(self.sessionPath)) -- 682
	local lines = {} -- 683
	local meta = self:encodeJsonLine({ -- 684
		_type = "metadata", -- 685
		lastConsolidatedIndex = math.min( -- 686
			math.max( -- 686
				0, -- 686
				math.floor(lastConsolidatedIndex) -- 686
			), -- 686
			#history -- 686
		) -- 686
	}) -- 686
	if meta then -- 686
		lines[#lines + 1] = meta -- 689
	end -- 689
	do -- 689
		local i = 0 -- 691
		while i < #history do -- 691
			local line = self:encodeJsonLine(history[i + 1]) -- 692
			if line then -- 692
				lines[#lines + 1] = line -- 694
			end -- 694
			i = i + 1 -- 691
		end -- 691
	end -- 691
	local content = table.concat(lines, "\n") .. "\n" -- 697
	Content:save(self.sessionPath, content) -- 698
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 699
end -- 681
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 705
	local history = self:readHistory() -- 706
	if not history then -- 706
		return {} -- 707
	end -- 707
	local lines = __TS__StringSplit(history, "\n") -- 709
	local lowerKeyword = string.lower(keyword) -- 710
	return __TS__ArrayFilter( -- 712
		lines, -- 712
		function(____, line) return __TS__StringIncludes( -- 712
			string.lower(line), -- 713
			lowerKeyword -- 713
		) end -- 713
	) -- 713
end -- 705
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 726
local MemoryCompressor = ____exports.MemoryCompressor -- 726
MemoryCompressor.name = "MemoryCompressor" -- 726
function MemoryCompressor.prototype.____constructor(self, config) -- 733
	self.consecutiveFailures = 0 -- 729
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 734
	do -- 734
		local i = 0 -- 735
		while i < #loadedPromptPack.warnings do -- 735
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 736
			i = i + 1 -- 735
		end -- 735
	end -- 735
	local overridePack = config.promptPack and not __TS__ArrayIsArray(config.promptPack) and type(config.promptPack) == "table" and config.promptPack or nil -- 738
	self.config = __TS__ObjectAssign( -- 741
		{}, -- 741
		config, -- 742
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 741
	) -- 741
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 748
end -- 733
function MemoryCompressor.prototype.getPromptPack(self) -- 751
	return self.config.promptPack -- 752
end -- 751
function MemoryCompressor.prototype.shouldCompress(self, userQuery, history, lastConsolidatedIndex, systemPrompt, toolDefinitions, formatFunc) -- 758
	local uncompressedHistory = __TS__ArraySlice(history, lastConsolidatedIndex) -- 766
	local tokens = ____exports.TokenEstimator:estimatePrompt( -- 768
		userQuery, -- 769
		uncompressedHistory, -- 770
		systemPrompt, -- 771
		toolDefinitions, -- 772
		formatFunc -- 773
	) -- 773
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 776
	return tokens > threshold -- 778
end -- 758
function MemoryCompressor.prototype.compress(self, userQuery, history, lastConsolidatedIndex, llmOptions, formatFunc, maxLLMTry, decisionMode) -- 784
	if decisionMode == nil then -- 784
		decisionMode = "tool_calling" -- 791
	end -- 791
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 791
		local toCompress = __TS__ArraySlice(history, lastConsolidatedIndex) -- 793
		if #toCompress == 0 then -- 793
			return ____awaiter_resolve(nil, nil) -- 793
		end -- 793
		local boundary = self:findCompressionBoundary(toCompress, formatFunc) -- 797
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 798
		if #chunk == 0 then -- 798
			return ____awaiter_resolve(nil, nil) -- 798
		end -- 798
		local currentMemory = self.storage:readMemory() -- 802
		local historyText = formatFunc(chunk) -- 803
		local ____try = __TS__AsyncAwaiter(function() -- 803
			local result = __TS__Await(self:callLLMForCompression( -- 807
				currentMemory, -- 808
				historyText, -- 809
				llmOptions, -- 810
				maxLLMTry or 3, -- 811
				decisionMode -- 812
			)) -- 812
			if result.success then -- 812
				self.storage:writeMemory(result.memoryUpdate) -- 817
				self.storage:appendHistory(result.historyEntry) -- 818
				self.consecutiveFailures = 0 -- 819
				return ____awaiter_resolve( -- 819
					nil, -- 819
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 821
				) -- 821
			end -- 821
			return ____awaiter_resolve( -- 821
				nil, -- 821
				self:handleCompressionFailure(userQuery, chunk, result.error or "Unknown error") -- 828
			) -- 828
		end) -- 828
		__TS__Await(____try.catch( -- 805
			____try, -- 805
			function(____, ____error) -- 805
				return ____awaiter_resolve( -- 805
					nil, -- 805
					self:handleCompressionFailure( -- 832
						userQuery, -- 833
						chunk, -- 834
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 835
					) -- 835
				) -- 835
			end -- 835
		)) -- 835
	end) -- 835
end -- 784
function MemoryCompressor.prototype.findCompressionBoundary(self, history, formatFunc) -- 845
	local targetTokens = self.config.maxTokensPerCompression -- 849
	local accumulatedTokens = 0 -- 850
	do -- 850
		local i = 0 -- 852
		while i < #history do -- 852
			local record = history[i + 1] -- 853
			local tokens = ____exports.TokenEstimator:estimate(formatFunc({record})) -- 854
			accumulatedTokens = accumulatedTokens + tokens -- 858
			if accumulatedTokens > targetTokens then -- 858
				return math.max(1, i) -- 862
			end -- 862
			i = i + 1 -- 852
		end -- 852
	end -- 852
	return #history -- 866
end -- 845
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 872
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 872
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 879
		if decisionMode == "yaml" then -- 879
			return ____awaiter_resolve( -- 879
				nil, -- 879
				self:callLLMForCompressionByYAML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 881
			) -- 881
		end -- 881
		return ____awaiter_resolve( -- 881
			nil, -- 881
			self:callLLMForCompressionByToolCalling(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 888
		) -- 888
	end) -- 888
end -- 872
function MemoryCompressor.prototype.getContextWindow(self) -- 896
	return math.max(4000, self.config.llmConfig.contextWindow) -- 897
end -- 896
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 900
	local contextWindow = self:getContextWindow() -- 901
	local reservedOutputTokens = math.max( -- 902
		2048, -- 902
		math.floor(contextWindow * 0.2) -- 902
	) -- 902
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBodyRaw("", "")) -- 903
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 904
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 905
	return math.max( -- 906
		1200, -- 906
		math.floor(available * 0.9) -- 906
	) -- 906
end -- 900
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 909
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 910
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 911
	if historyTokens <= tokenBudget then -- 911
		return historyText -- 912
	end -- 912
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 913
	local targetChars = math.max( -- 916
		2000, -- 916
		math.floor(tokenBudget * charsPerToken) -- 916
	) -- 916
	local keepHead = math.max( -- 917
		0, -- 917
		math.floor(targetChars * 0.35) -- 917
	) -- 917
	local keepTail = math.max(0, targetChars - keepHead) -- 918
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 919
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 920
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 921
end -- 909
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 924
	local contextWindow = self:getContextWindow() -- 928
	local reservedOutputTokens = math.max( -- 929
		2048, -- 929
		math.floor(contextWindow * 0.2) -- 929
	) -- 929
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBodyRaw("", "")) -- 930
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 931
	local boundedMemory = clipTextToTokenBudget( -- 932
		currentMemory or "(empty)", -- 932
		math.max( -- 932
			320, -- 932
			math.floor(dynamicBudget * 0.35) -- 932
		) -- 932
	) -- 932
	local boundedHistory = clipTextToTokenBudget( -- 933
		historyText, -- 933
		math.max( -- 933
			800, -- 933
			math.floor(dynamicBudget * 0.65) -- 933
		) -- 933
	) -- 933
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 934
end -- 924
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 940
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 940
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 946
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 949
		local messages = {{role = "system", content = self.config.promptPack.memoryCompressionSystemPrompt}, {role = "user", content = prompt}} -- 973
		local fn -- 984
		local argsText = "" -- 985
		do -- 985
			local i = 0 -- 986
			while i < maxLLMTry do -- 986
				local response = __TS__Await(callLLM( -- 988
					messages, -- 989
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 990
					nil, -- 995
					self.config.llmConfig -- 996
				)) -- 996
				if not response.success then -- 996
					return ____awaiter_resolve(nil, { -- 996
						success = false, -- 1001
						memoryUpdate = currentMemory, -- 1002
						historyEntry = "", -- 1003
						compressedCount = 0, -- 1004
						error = response.message -- 1005
					}) -- 1005
				end -- 1005
				local choice = response.response.choices and response.response.choices[1] -- 1009
				local message = choice and choice.message -- 1010
				local toolCalls = message and message.tool_calls -- 1011
				local toolCall = toolCalls and toolCalls[1] -- 1012
				fn = toolCall and toolCall["function"] -- 1013
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1014
				if fn ~= nil and #argsText > 0 then -- 1014
					break -- 1015
				end -- 1015
				i = i + 1 -- 986
			end -- 986
		end -- 986
		if not fn or fn.name ~= "save_memory" then -- 986
			return ____awaiter_resolve(nil, { -- 986
				success = false, -- 1020
				memoryUpdate = currentMemory, -- 1021
				historyEntry = "", -- 1022
				compressedCount = 0, -- 1023
				error = "missing save_memory tool call" -- 1024
			}) -- 1024
		end -- 1024
		if __TS__StringTrim(argsText) == "" then -- 1024
			return ____awaiter_resolve(nil, { -- 1024
				success = false, -- 1030
				memoryUpdate = currentMemory, -- 1031
				historyEntry = "", -- 1032
				compressedCount = 0, -- 1033
				error = "empty save_memory tool arguments" -- 1034
			}) -- 1034
		end -- 1034
		local ____try = __TS__AsyncAwaiter(function() -- 1034
			local args, err = json.decode(argsText) -- 1040
			if err ~= nil or not args or type(args) ~= "table" then -- 1040
				return ____awaiter_resolve( -- 1040
					nil, -- 1040
					{ -- 1042
						success = false, -- 1043
						memoryUpdate = currentMemory, -- 1044
						historyEntry = "", -- 1045
						compressedCount = 0, -- 1046
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1047
					} -- 1047
				) -- 1047
			end -- 1047
			return ____awaiter_resolve( -- 1047
				nil, -- 1047
				self:buildCompressionResultFromObject(args, currentMemory) -- 1051
			) -- 1051
		end) -- 1051
		__TS__Await(____try.catch( -- 1039
			____try, -- 1039
			function(____, ____error) -- 1039
				return ____awaiter_resolve( -- 1039
					nil, -- 1039
					{ -- 1056
						success = false, -- 1057
						memoryUpdate = currentMemory, -- 1058
						historyEntry = "", -- 1059
						compressedCount = 0, -- 1060
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1061
					} -- 1061
				) -- 1061
			end -- 1061
		)) -- 1061
	end) -- 1061
end -- 940
function MemoryCompressor.prototype.callLLMForCompressionByYAML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1066
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1066
		local prompt = self:buildYAMLCompressionPrompt(currentMemory, historyText) -- 1072
		local lastError = "invalid yaml response" -- 1073
		do -- 1073
			local i = 0 -- 1075
			while i < maxLLMTry do -- 1075
				do -- 1075
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionYamlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1076
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions, nil, self.config.llmConfig)) -- 1081
					if not response.success then -- 1081
						return ____awaiter_resolve(nil, { -- 1081
							success = false, -- 1090
							memoryUpdate = currentMemory, -- 1091
							historyEntry = "", -- 1092
							compressedCount = 0, -- 1093
							error = response.message -- 1094
						}) -- 1094
					end -- 1094
					local choice = response.response.choices and response.response.choices[1] -- 1098
					local message = choice and choice.message -- 1099
					local text = message and type(message.content) == "string" and message.content or "" -- 1100
					if __TS__StringTrim(text) == "" then -- 1100
						lastError = "empty yaml response" -- 1102
						goto __continue129 -- 1103
					end -- 1103
					local parsed = self:parseCompressionYAMLObject(text, currentMemory) -- 1106
					if parsed.success then -- 1106
						return ____awaiter_resolve(nil, parsed) -- 1106
					end -- 1106
					lastError = parsed.error or "invalid yaml response" -- 1110
				end -- 1110
				::__continue129:: -- 1110
				i = i + 1 -- 1075
			end -- 1075
		end -- 1075
		return ____awaiter_resolve(nil, { -- 1075
			success = false, -- 1114
			memoryUpdate = currentMemory, -- 1115
			historyEntry = "", -- 1116
			compressedCount = 0, -- 1117
			error = lastError -- 1118
		}) -- 1118
	end) -- 1118
end -- 1066
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1125
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1126
end -- 1125
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1132
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1133
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1134
end -- 1132
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 1140
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1141
end -- 1140
function MemoryCompressor.prototype.buildYAMLCompressionPrompt(self, currentMemory, historyText) -- 1146
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionYamlPrompt -- 1147
end -- 1146
function MemoryCompressor.prototype.extractYAMLFromText(self, text) -- 1152
	local source = __TS__StringTrim(text) -- 1153
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 1154
	if yamlFencePos >= 0 then -- 1154
		local from = yamlFencePos + #"```yaml" -- 1156
		local ____end = (string.find( -- 1157
			source, -- 1157
			"```", -- 1157
			math.max(from + 1, 1), -- 1157
			true -- 1157
		) or 0) - 1 -- 1157
		if ____end > from then -- 1157
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1158
		end -- 1158
	end -- 1158
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 1160
	if ymlFencePos >= 0 then -- 1160
		local from = ymlFencePos + #"```yml" -- 1162
		local ____end = (string.find( -- 1163
			source, -- 1163
			"```", -- 1163
			math.max(from + 1, 1), -- 1163
			true -- 1163
		) or 0) - 1 -- 1163
		if ____end > from then -- 1163
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1164
		end -- 1164
	end -- 1164
	return source -- 1166
end -- 1152
function MemoryCompressor.prototype.parseCompressionYAMLObject(self, text, currentMemory) -- 1169
	local yamlText = self:extractYAMLFromText(text) -- 1170
	local obj, err = yaml.parse(yamlText) -- 1171
	if not obj or type(obj) ~= "table" then -- 1171
		return { -- 1173
			success = false, -- 1174
			memoryUpdate = currentMemory, -- 1175
			historyEntry = "", -- 1176
			compressedCount = 0, -- 1177
			error = "invalid yaml: " .. tostring(err) -- 1178
		} -- 1178
	end -- 1178
	return self:buildCompressionResultFromObject(obj, currentMemory) -- 1181
end -- 1169
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1187
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1191
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1192
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1192
		return { -- 1194
			success = false, -- 1195
			memoryUpdate = currentMemory, -- 1196
			historyEntry = "", -- 1197
			compressedCount = 0, -- 1198
			error = "missing history_entry or memory_update" -- 1199
		} -- 1199
	end -- 1199
	local ts = os.date("%Y-%m-%d %H:%M") -- 1202
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1203
end -- 1187
function MemoryCompressor.prototype.handleCompressionFailure(self, userQuery, chunk, ____error) -- 1214
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1219
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1219
		self:rawArchive(userQuery, chunk) -- 1223
		self.consecutiveFailures = 0 -- 1224
		return { -- 1226
			success = true, -- 1227
			memoryUpdate = self.storage:readMemory(), -- 1228
			historyEntry = "[RAW ARCHIVE] Detailed history not recorded", -- 1229
			compressedCount = #chunk -- 1230
		} -- 1230
	end -- 1230
	return { -- 1234
		success = false, -- 1235
		memoryUpdate = self.storage:readMemory(), -- 1236
		historyEntry = "", -- 1237
		compressedCount = 0, -- 1238
		error = ____error -- 1239
	} -- 1239
end -- 1214
function MemoryCompressor.prototype.rawArchive(self, userQuery, chunk) -- 1246
	local ts = os.date("%Y-%m-%d %H:%M") -- 1247
	local prompt = __TS__StringTrim(userQuery) ~= "" and __TS__StringReplace( -- 1248
		__TS__StringTrim(userQuery), -- 1249
		"\n", -- 1249
		" " -- 1249
	) or "(empty prompt)" -- 1249
	local compactPrompt = #prompt > 160 and string.sub(prompt, 1, 160) .. "..." or prompt -- 1251
	self.storage:appendHistory(((((("[" .. ts) .. "] [RAW ARCHIVE] prompt=\"") .. compactPrompt) .. "\" (") .. tostring(#chunk)) .. " actions, compression failed; detailed history not recorded)") -- 1252
end -- 1246
function MemoryCompressor.prototype.getStorage(self) -- 1260
	return self.storage -- 1261
end -- 1260
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1264
	return math.max( -- 1265
		1, -- 1265
		math.floor(self.config.maxCompressionRounds) -- 1265
	) -- 1265
end -- 1264
MemoryCompressor.MAX_FAILURES = 3 -- 1264
return ____exports -- 1264