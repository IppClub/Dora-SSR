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
	toolDefinitionsDetailed = "Available tools:\n1. read_file: Read a specific line range from a file\n\t- Parameters: path, startLine(optional), endLine(optional)\n\t- Line starts with 1. startLine defaults to 1 and endLine defaults to 300.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= {{SEARCH_DORA_API_LIMIT_MAX}}.\n\n7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- After one build completes, do not run build again unless files were edited/deleted. Read the result and then finish or take corrective action.\n\n8. finish: End and summarize\n\t- Parameters: {}", -- 45
	decisionRulesPrompt = "Decision rules:\n- Choose exactly one next action.\n- Keep params shallow and valid for the selected tool.\n- Prefer reading/searching before editing when information is missing.\n- After any search tool returns candidate files or docs, use read_file to inspect relevant line ranges instead of repeatedly broadening search.\n- Use glob_files to discover candidate files. Use grep_files only when you need to search file contents.\n- If the user asked a question, prefer finishing only after you can answer it in the final response.", -- 90
	replyLanguageDirectiveZh = "Use Simplified Chinese for natural-language fields (message/summary).", -- 97
	replyLanguageDirectiveEn = "Use English for natural-language fields (message/summary).", -- 98
	toolCallingRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Retry with either one valid tool call.", -- 99
	yamlDecisionFormatPrompt = "Respond with exactly one YAML object. Do not include any prose before or after the YAML.\n\n```yaml\ntool: \"edit_file\"\nparams:\n\tpath: \"relative/path.ts\"\n\told_str: |-\n\t\tfunction oldName() {\n\t\t\tprint(\"old\");\n\t\t}\n\tnew_str: |-\n\t\tfunction newName() {\n\t\t\tprint(\"hello\");\n\t\t}\n```\n\nRules:\n- Use exactly one YAML object with keys: tool, params.\n- Multi-line strings use block scalars (`|`, `|-`, `>`).\n- If using a block scalar, all content lines must be indented consistently with tabs.\n- For nested multi-line fields (e.g. params.new_str), indent the block content deeper than the key line using tabs.\n- Keep params shallow and valid for the selected tool.\n- Use tabs for all indentation, never spaces.\n- If no more actions are needed, use tool: finish.", -- 100
	finalSummaryPrompt = "You are a coding assistant. Provide a concise summary of what you did.\n\nHere are the actions you performed:\n{{SUMMARY}}\n\nGenerate a response that:\n1. Explains what actions were taken and what was found/modified\n2. Speaks directly to the in a natural, friendly manner\n3. If the user asked a question, includes a direct answer\n4. Focuses on outcomes, not technical tool names\n\nIMPORTANT:\n- Be concise (1-3 sentences unless more detail is needed)\n- Do not mention internal details like tool names or step numbers\n{{LANGUAGE_DIRECTIVE}}", -- 124
	memoryCompressionSystemPrompt = "You are a memory consolidation agent. You MUST call the save_memory tool.\nDo not output any text besides the tool call.", -- 139
	memoryCompressionBodyPrompt = "### Current Memory (Long-term)\n\n{{CURRENT_MEMORY}}\n\n---\n\n### Actions to Process\n\n{{HISTORY_TEXT}}\n\n---\n\n### Task\n\nAnalyze the actions and update the memory. Follow these guidelines:\n\n1. Preserve Important Information\n\t- User preferences and settings\n\t- Key decisions and their rationale\n\t- Important technical details\n\t- Project-specific context\n\n2. Consolidate Redundant Information\n\t- Merge related entries\n\t- Remove outdated information\n\t- Summarize verbose sections\n\n3. Maintain Structure\n\t- Keep the markdown format\n\t- Preserve section headers\n\t- Use clear, concise language\n\n4. Create History Entry\n\t- Create a summary paragraph for HISTORY.md\n\t- Include timestamp and key topics\n\t- Make it grep-searchable\n\nCall the save_memory tool with your consolidated memory and history entry.",
	memoryCompressionToolCallingPrompt = "### Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content", -- 179
	memoryCompressionYamlPrompt = "### Output Format\n\nReturn exactly one YAML object:\n```yaml\nhistory_entry: \"Summary paragraph\"\nmemory_update: |-\n\tFull updated MEMORY.md content\n```\n\nRules:\n- Return YAML only, no prose before or after.\n- Use exactly two keys: history_entry, memory_update.\n- Use a block scalar for memory_update when it spans multiple lines.", -- 184
	memoryCompressionYamlRetryPrompt = "Previous response was invalid ({{LAST_ERROR}}). Return exactly one valid YAML object only." -- 197
} -- 197
local EXPOSED_PROMPT_PACK_KEYS = { -- 200
	"agentIdentityPrompt", -- 201
	"decisionIntroPrompt", -- 202
	"decisionRulesPrompt", -- 203
	"replyLanguageDirectiveZh", -- 204
	"replyLanguageDirectiveEn", -- 205
	"finalSummaryPrompt", -- 206
	"memoryCompressionBodyPrompt" -- 207
} -- 207
local ____array_0 = __TS__SparseArrayNew(table.unpack(EXPOSED_PROMPT_PACK_KEYS)) -- 207
__TS__SparseArrayPush(____array_0, "toolDefinitionsDetailed") -- 207
local OVERRIDABLE_PROMPT_PACK_KEYS = {__TS__SparseArraySpread(____array_0)} -- 210
local function replaceTemplateVars(template, vars) -- 215
	local output = template -- 216
	for key in pairs(vars) do -- 217
		output = table.concat( -- 218
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 218
			vars[key] or "" or "," -- 218
		) -- 218
	end -- 218
	return output -- 220
end -- 215
function ____exports.resolveAgentPromptPack(value) -- 223
	local merged = __TS__ObjectAssign({}, ____exports.DEFAULT_AGENT_PROMPT_PACK) -- 224
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 224
		do -- 224
			local i = 0 -- 228
			while i < #OVERRIDABLE_PROMPT_PACK_KEYS do -- 228
				local key = OVERRIDABLE_PROMPT_PACK_KEYS[i + 1] -- 229
				if type(value[key]) == "string" then -- 229
					merged[key] = value[key] -- 231
				end -- 231
				i = i + 1 -- 228
			end -- 228
		end -- 228
	end -- 228
	return merged -- 235
end -- 223
function ____exports.renderDefaultAgentPromptPackMarkdown() -- 238
	local pack = ____exports.DEFAULT_AGENT_PROMPT_PACK -- 239
	local lines = {} -- 240
	lines[#lines + 1] = "# Dora Agent Prompt Configuration" -- 241
	lines[#lines + 1] = "" -- 242
	lines[#lines + 1] = "Edit the content under each `##` heading. Missing sections fall back to built-in defaults." -- 243
	lines[#lines + 1] = "" -- 244
	do -- 244
		local i = 0 -- 245
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 245
			local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 246
			lines[#lines + 1] = "## " .. key -- 247
			local text = pack[key] -- 248
			local split = __TS__StringSplit(text, "\n") -- 249
			do -- 249
				local j = 0 -- 250
				while j < #split do -- 250
					lines[#lines + 1] = split[j + 1] -- 251
					j = j + 1 -- 250
				end -- 250
			end -- 250
			lines[#lines + 1] = "" -- 253
			i = i + 1 -- 245
		end -- 245
	end -- 245
	return __TS__StringTrim(table.concat(lines, "\n")) .. "\n" -- 255
end -- 238
local function getPromptPackConfigPath(projectRoot) -- 258
	return Path(projectRoot, AGENT_CONFIG_DIR, AGENT_PROMPTS_FILE) -- 259
end -- 258
local function ensurePromptPackConfig(projectRoot) -- 262
	local path = getPromptPackConfigPath(projectRoot) -- 263
	if Content:exist(path) then -- 263
		return nil -- 264
	end -- 264
	local dir = Path:getPath(path) -- 265
	if not Content:exist(dir) then -- 265
		Content:mkdir(dir) -- 267
	end -- 267
	local content = ____exports.renderDefaultAgentPromptPackMarkdown() -- 269
	if not Content:save(path, content) then -- 269
		return ("Failed to create default Agent prompt config at " .. path) .. ". Using built-in defaults for this run." -- 271
	end -- 271
	sendWebIDEFileUpdate(path, true, content) -- 273
	return nil -- 274
end -- 262
local function parsePromptPackMarkdown(text) -- 277
	if not text or __TS__StringTrim(text) == "" then -- 277
		return { -- 284
			value = {}, -- 285
			missing = {table.unpack(EXPOSED_PROMPT_PACK_KEYS)}, -- 286
			unknown = {} -- 287
		} -- 287
	end -- 287
	local normalized = __TS__StringReplace(text, "\r\n", "\n") -- 290
	local lines = __TS__StringSplit(normalized, "\n") -- 291
	local sections = {} -- 292
	local unknown = {} -- 293
	local currentHeading = "" -- 294
	local function isKnownPromptPackKey(name) -- 295
		do -- 295
			local i = 0 -- 296
			while i < #EXPOSED_PROMPT_PACK_KEYS do -- 296
				if EXPOSED_PROMPT_PACK_KEYS[i + 1] == name then -- 296
					return true -- 297
				end -- 297
				i = i + 1 -- 296
			end -- 296
		end -- 296
		return false -- 299
	end -- 295
	do -- 295
		local i = 0 -- 301
		while i < #lines do -- 301
			do -- 301
				local line = lines[i + 1] -- 302
				local matchedHeading = string.match(line, "^##[ \t]+(.+)$") -- 303
				if matchedHeading ~= nil then -- 303
					local heading = __TS__StringTrim(tostring(matchedHeading)) -- 305
					if isKnownPromptPackKey(heading) then -- 305
						currentHeading = heading -- 307
						if sections[currentHeading] == nil then -- 307
							sections[currentHeading] = {} -- 309
						end -- 309
						goto __continue27 -- 311
					end -- 311
					if currentHeading == "" then -- 311
						unknown[#unknown + 1] = heading -- 314
						goto __continue27 -- 315
					end -- 315
				end -- 315
				if currentHeading ~= "" then -- 315
					local ____sections_currentHeading_1 = sections[currentHeading] -- 315
					____sections_currentHeading_1[#____sections_currentHeading_1 + 1] = line -- 319
				end -- 319
			end -- 319
			::__continue27:: -- 319
			i = i + 1 -- 301
		end -- 301
	end -- 301
	local value = {} -- 322
	local missing = {} -- 323
	do -- 323
		local i = 0 -- 324
		while i < #EXPOSED_PROMPT_PACK_KEYS do -- 324
			do -- 324
				local key = EXPOSED_PROMPT_PACK_KEYS[i + 1] -- 325
				local section = sections[key] -- 326
				local body = section ~= nil and __TS__StringTrim(table.concat(section, "\n")) or "" -- 327
				if body == "" then -- 327
					missing[#missing + 1] = key -- 329
					goto __continue34 -- 330
				end -- 330
				value[key] = body -- 332
			end -- 332
			::__continue34:: -- 332
			i = i + 1 -- 324
		end -- 324
	end -- 324
	if #__TS__ObjectKeys(sections) == 0 then -- 324
		return {error = "no ## sections found", unknown = unknown, missing = missing} -- 335
	end -- 335
	return {value = value, missing = missing, unknown = unknown} -- 341
end -- 277
function ____exports.loadAgentPromptPack(projectRoot) -- 344
	local path = getPromptPackConfigPath(projectRoot) -- 345
	local warnings = {} -- 346
	local ensureWarning = ensurePromptPackConfig(projectRoot) -- 347
	if ensureWarning and ensureWarning ~= "" then -- 347
		warnings[#warnings + 1] = ensureWarning -- 349
	end -- 349
	if not Content:exist(path) then -- 349
		return { -- 352
			pack = ____exports.resolveAgentPromptPack(), -- 353
			warnings = warnings, -- 354
			path = path -- 355
		} -- 355
	end -- 355
	local text = Content:load(path) -- 358
	if not text or __TS__StringTrim(text) == "" then -- 358
		warnings[#warnings + 1] = ("Agent prompt config at " .. path) .. " is empty. Using built-in defaults for this run." -- 360
		return { -- 361
			pack = ____exports.resolveAgentPromptPack(), -- 362
			warnings = warnings, -- 363
			path = path -- 364
		} -- 364
	end -- 364
	local parsed = parsePromptPackMarkdown(text) -- 367
	if parsed.error or not parsed.value then -- 367
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is invalid (") .. (parsed.error or "parse failed")) .. "). Using built-in defaults for this run." -- 369
		return { -- 370
			pack = ____exports.resolveAgentPromptPack(), -- 371
			warnings = warnings, -- 372
			path = path -- 373
		} -- 373
	end -- 373
	if #parsed.unknown > 0 then -- 373
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " contains unrecognized sections: ") .. table.concat(parsed.unknown, ", ")) .. "." -- 377
	end -- 377
	if #parsed.missing > 0 then -- 377
		warnings[#warnings + 1] = ((("Agent prompt config at " .. path) .. " is missing sections: ") .. table.concat(parsed.missing, ", ")) .. ". Built-in defaults were used for those sections." -- 380
	end -- 380
	return { -- 382
		pack = ____exports.resolveAgentPromptPack(parsed.value), -- 383
		warnings = warnings, -- 384
		path = path -- 385
	} -- 385
end -- 344
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 440
local TokenEstimator = ____exports.TokenEstimator -- 440
TokenEstimator.name = "TokenEstimator" -- 440
function TokenEstimator.prototype.____constructor(self) -- 440
end -- 440
function TokenEstimator.estimate(self, text) -- 450
	if not text then -- 450
		return 0 -- 451
	end -- 451
	local chineseChars = utf8.len(text) -- 454
	if not chineseChars then -- 454
		return 0 -- 455
	end -- 455
	local otherChars = #text - chineseChars -- 457
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 459
	return math.max(1, tokens) -- 464
end -- 450
function TokenEstimator.estimateHistory(self, history, formatFunc) -- 470
	if not history or #history == 0 then -- 470
		return 0 -- 471
	end -- 471
	local text = formatFunc(history) -- 472
	return self:estimate(text) -- 473
end -- 470
function TokenEstimator.estimatePrompt(self, userQuery, history, systemPrompt, toolDefinitions, formatFunc) -- 479
	return self:estimate(userQuery) + self:estimateHistory(history, formatFunc) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 486
end -- 479
TokenEstimator.CHARS_PER_TOKEN = 4 -- 479
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 479
local function utf8TakeHead(text, maxChars) -- 495
	if maxChars <= 0 or text == "" then -- 495
		return "" -- 496
	end -- 496
	local nextPos = utf8.offset(text, maxChars + 1) -- 497
	if nextPos == nil then -- 497
		return text -- 498
	end -- 498
	return string.sub(text, 1, nextPos - 1) -- 499
end -- 495
local function utf8TakeTail(text, maxChars) -- 502
	if maxChars <= 0 or text == "" then -- 502
		return "" -- 503
	end -- 503
	local charLen = utf8.len(text) -- 504
	if charLen == false or charLen <= maxChars then -- 504
		return text -- 505
	end -- 505
	local startChar = math.max(1, charLen - maxChars + 1) -- 506
	local startPos = utf8.offset(text, startChar) -- 507
	if startPos == nil then -- 507
		return text -- 508
	end -- 508
	return string.sub(text, startPos) -- 509
end -- 502
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 517
local DualLayerStorage = ____exports.DualLayerStorage -- 517
DualLayerStorage.name = "DualLayerStorage" -- 517
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 524
	self.projectDir = projectDir -- 525
	self.agentDir = Path(self.projectDir, ".agent") -- 526
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 527
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 528
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 529
	self:ensureAgentFiles() -- 530
end -- 524
function DualLayerStorage.prototype.ensureDir(self, dir) -- 533
	if not Content:exist(dir) then -- 533
		Content:mkdir(dir) -- 535
	end -- 535
end -- 533
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 539
	if Content:exist(path) then -- 539
		return false -- 540
	end -- 540
	self:ensureDir(Path:getPath(path)) -- 541
	if not Content:save(path, content) then -- 541
		return false -- 543
	end -- 543
	sendWebIDEFileUpdate(path, true, content) -- 545
	return true -- 546
end -- 539
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 549
	self:ensureDir(self.agentDir) -- 550
	self:ensureFile(self.memoryPath, "") -- 551
	self:ensureFile(self.historyPath, "") -- 552
end -- 549
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 555
	local text = json.encode(value) -- 556
	return text -- 557
end -- 555
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 560
	local value = json.decode(text) -- 561
	return value -- 562
end -- 560
function DualLayerStorage.prototype.decodeActionRecord(self, value) -- 565
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 565
		return nil -- 566
	end -- 566
	local row = value -- 567
	local tool = type(row.tool) == "string" and row.tool or "" -- 568
	local reason = type(row.reason) == "string" and row.reason or "" -- 569
	local timestamp = type(row.timestamp) == "string" and row.timestamp or "" -- 570
	if tool == "" or timestamp == "" then -- 570
		return nil -- 571
	end -- 571
	local params = row.params and not __TS__ArrayIsArray(row.params) and type(row.params) == "table" and row.params or ({}) -- 572
	local result = row.result and not __TS__ArrayIsArray(row.result) and type(row.result) == "table" and row.result or nil -- 575
	local ____math_max_4 = math.max -- 579
	local ____math_floor_3 = math.floor -- 579
	local ____row_step_2 = row.step -- 579
	if ____row_step_2 == nil then -- 579
		____row_step_2 = 1 -- 579
	end -- 579
	return { -- 578
		step = ____math_max_4( -- 579
			1, -- 579
			____math_floor_3(__TS__Number(____row_step_2)) -- 579
		), -- 579
		tool = tool, -- 580
		reason = reason, -- 581
		params = params, -- 582
		result = result, -- 583
		timestamp = timestamp -- 584
	} -- 584
end -- 565
function DualLayerStorage.prototype.readMemory(self) -- 593
	if not Content:exist(self.memoryPath) then -- 593
		return "" -- 595
	end -- 595
	return Content:load(self.memoryPath) -- 597
end -- 593
function DualLayerStorage.prototype.writeMemory(self, content) -- 603
	self:ensureDir(Path:getPath(self.memoryPath)) -- 604
	Content:save(self.memoryPath, content) -- 605
end -- 603
function DualLayerStorage.prototype.getMemoryContext(self) -- 611
	local memory = self:readMemory() -- 612
	if not memory then -- 612
		return "" -- 613
	end -- 613
	return "### Long-term Memory\n\n" .. memory -- 615
end -- 611
function DualLayerStorage.prototype.appendHistory(self, entry) -- 625
	self:ensureDir(Path:getPath(self.historyPath)) -- 626
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 628
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 632
end -- 625
function DualLayerStorage.prototype.readHistory(self) -- 638
	if not Content:exist(self.historyPath) then -- 638
		return "" -- 640
	end -- 640
	return Content:load(self.historyPath) -- 642
end -- 638
function DualLayerStorage.prototype.readSessionState(self) -- 645
	if not Content:exist(self.sessionPath) then -- 645
		return {history = {}, lastConsolidatedIndex = 0} -- 647
	end -- 647
	local text = Content:load(self.sessionPath) -- 649
	if not text or __TS__StringTrim(text) == "" then -- 649
		return {history = {}, lastConsolidatedIndex = 0} -- 651
	end -- 651
	local lines = __TS__StringSplit(text, "\n") -- 653
	local history = {} -- 654
	local lastConsolidatedIndex = 0 -- 655
	do -- 655
		local i = 0 -- 656
		while i < #lines do -- 656
			do -- 656
				local line = __TS__StringTrim(lines[i + 1]) -- 657
				if line == "" then -- 657
					goto __continue82 -- 658
				end -- 658
				local data = self:decodeJsonLine(line) -- 659
				if not data or __TS__ArrayIsArray(data) or type(data) ~= "table" then -- 659
					goto __continue82 -- 660
				end -- 660
				local row = data -- 661
				if row._type == "metadata" then -- 661
					local ____math_max_7 = math.max -- 663
					local ____math_floor_6 = math.floor -- 663
					local ____row_lastConsolidatedIndex_5 = row.lastConsolidatedIndex -- 663
					if ____row_lastConsolidatedIndex_5 == nil then -- 663
						____row_lastConsolidatedIndex_5 = 0 -- 663
					end -- 663
					lastConsolidatedIndex = ____math_max_7( -- 663
						0, -- 663
						____math_floor_6(__TS__Number(____row_lastConsolidatedIndex_5)) -- 663
					) -- 663
					goto __continue82 -- 664
				end -- 664
				local record = self:decodeActionRecord(row) -- 666
				if record then -- 666
					history[#history + 1] = record -- 668
				end -- 668
			end -- 668
			::__continue82:: -- 668
			i = i + 1 -- 656
		end -- 656
	end -- 656
	return { -- 671
		history = history, -- 672
		lastConsolidatedIndex = math.min(lastConsolidatedIndex, #history) -- 673
	} -- 673
end -- 645
function DualLayerStorage.prototype.writeSessionState(self, history, lastConsolidatedIndex) -- 677
	self:ensureDir(Path:getPath(self.sessionPath)) -- 678
	local lines = {} -- 679
	local meta = self:encodeJsonLine({ -- 680
		_type = "metadata", -- 681
		lastConsolidatedIndex = math.min( -- 682
			math.max( -- 682
				0, -- 682
				math.floor(lastConsolidatedIndex) -- 682
			), -- 682
			#history -- 682
		) -- 682
	}) -- 682
	if meta then -- 682
		lines[#lines + 1] = meta -- 685
	end -- 685
	do -- 685
		local i = 0 -- 687
		while i < #history do -- 687
			local line = self:encodeJsonLine(history[i + 1]) -- 688
			if line then -- 688
				lines[#lines + 1] = line -- 690
			end -- 690
			i = i + 1 -- 687
		end -- 687
	end -- 687
	local content = table.concat(lines, "\n") .. "\n" -- 693
	Content:save(self.sessionPath, content) -- 694
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 695
end -- 677
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 701
	local history = self:readHistory() -- 702
	if not history then -- 702
		return {} -- 703
	end -- 703
	local lines = __TS__StringSplit(history, "\n") -- 705
	local lowerKeyword = string.lower(keyword) -- 706
	return __TS__ArrayFilter( -- 708
		lines, -- 708
		function(____, line) return __TS__StringIncludes( -- 708
			string.lower(line), -- 709
			lowerKeyword -- 709
		) end -- 709
	) -- 709
end -- 701
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 722
local MemoryCompressor = ____exports.MemoryCompressor -- 722
MemoryCompressor.name = "MemoryCompressor" -- 722
function MemoryCompressor.prototype.____constructor(self, config) -- 729
	self.consecutiveFailures = 0 -- 725
	local loadedPromptPack = ____exports.loadAgentPromptPack(config.projectDir) -- 730
	do -- 730
		local i = 0 -- 731
		while i < #loadedPromptPack.warnings do -- 731
			Log("Warn", "[Agent] " .. loadedPromptPack.warnings[i + 1]) -- 732
			i = i + 1 -- 731
		end -- 731
	end -- 731
	local overridePack = config.promptPack and not __TS__ArrayIsArray(config.promptPack) and type(config.promptPack) == "table" and config.promptPack or nil -- 734
	self.config = __TS__ObjectAssign( -- 737
		{}, -- 737
		config, -- 738
		{promptPack = ____exports.resolveAgentPromptPack(__TS__ObjectAssign({}, loadedPromptPack.pack, overridePack or ({})))} -- 737
	) -- 737
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 744
end -- 729
function MemoryCompressor.prototype.getPromptPack(self) -- 747
	return self.config.promptPack -- 748
end -- 747
function MemoryCompressor.prototype.shouldCompress(self, userQuery, history, lastConsolidatedIndex, systemPrompt, toolDefinitions, formatFunc) -- 754
	local uncompressedHistory = __TS__ArraySlice(history, lastConsolidatedIndex) -- 762
	local tokens = ____exports.TokenEstimator:estimatePrompt( -- 764
		userQuery, -- 765
		uncompressedHistory, -- 766
		systemPrompt, -- 767
		toolDefinitions, -- 768
		formatFunc -- 769
	) -- 769
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 772
	return tokens > threshold -- 774
end -- 754
function MemoryCompressor.prototype.compress(self, userQuery, history, lastConsolidatedIndex, llmOptions, formatFunc, maxLLMTry, decisionMode) -- 780
	if decisionMode == nil then -- 780
		decisionMode = "tool_calling" -- 787
	end -- 787
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 787
		local toCompress = __TS__ArraySlice(history, lastConsolidatedIndex) -- 789
		if #toCompress == 0 then -- 789
			return ____awaiter_resolve(nil, nil) -- 789
		end -- 789
		local boundary = self:findCompressionBoundary(toCompress, formatFunc) -- 793
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 794
		if #chunk == 0 then -- 794
			return ____awaiter_resolve(nil, nil) -- 794
		end -- 794
		local currentMemory = self.storage:readMemory() -- 798
		local historyText = formatFunc(chunk) -- 799
		local ____try = __TS__AsyncAwaiter(function() -- 799
			local result = __TS__Await(self:callLLMForCompression( -- 803
				currentMemory, -- 804
				historyText, -- 805
				llmOptions, -- 806
				maxLLMTry or 3, -- 807
				decisionMode -- 808
			)) -- 808
			if result.success then -- 808
				self.storage:writeMemory(result.memoryUpdate) -- 813
				self.storage:appendHistory(result.historyEntry) -- 814
				self.consecutiveFailures = 0 -- 815
				return ____awaiter_resolve( -- 815
					nil, -- 815
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 817
				) -- 817
			end -- 817
			return ____awaiter_resolve( -- 817
				nil, -- 817
				self:handleCompressionFailure(userQuery, chunk, result.error or "Unknown error") -- 824
			) -- 824
		end) -- 824
		__TS__Await(____try.catch( -- 801
			____try, -- 801
			function(____, ____error) -- 801
				return ____awaiter_resolve( -- 801
					nil, -- 801
					self:handleCompressionFailure( -- 828
						userQuery, -- 829
						chunk, -- 830
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error" -- 831
					) -- 831
				) -- 831
			end -- 831
		)) -- 831
	end) -- 831
end -- 780
function MemoryCompressor.prototype.findCompressionBoundary(self, history, formatFunc) -- 841
	local targetTokens = self.config.maxTokensPerCompression -- 845
	local accumulatedTokens = 0 -- 846
	do -- 846
		local i = 0 -- 848
		while i < #history do -- 848
			local record = history[i + 1] -- 849
			local tokens = ____exports.TokenEstimator:estimate(formatFunc({record})) -- 850
			accumulatedTokens = accumulatedTokens + tokens -- 854
			if accumulatedTokens > targetTokens then -- 854
				return math.max(1, i) -- 858
			end -- 858
			i = i + 1 -- 848
		end -- 848
	end -- 848
	return #history -- 862
end -- 841
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 868
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 868
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 875
		if decisionMode == "yaml" then -- 875
			return ____awaiter_resolve( -- 875
				nil, -- 875
				self:callLLMForCompressionByYAML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 877
			) -- 877
		end -- 877
		return ____awaiter_resolve( -- 877
			nil, -- 877
			self:callLLMForCompressionByToolCalling(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 884
		) -- 884
	end) -- 884
end -- 868
function MemoryCompressor.prototype.getContextWindow(self) -- 892
	return math.max(4000, self.config.llmConfig.contextWindow) -- 893
end -- 892
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 896
	local contextWindow = self:getContextWindow() -- 897
	local reservedOutputTokens = math.max( -- 898
		2048, -- 898
		math.floor(contextWindow * 0.2) -- 898
	) -- 898
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBodyRaw("", "")) -- 899
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 900
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 901
	return math.max( -- 902
		1200, -- 902
		math.floor(available * 0.9) -- 902
	) -- 902
end -- 896
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 905
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 906
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 907
	if historyTokens <= tokenBudget then -- 907
		return historyText -- 908
	end -- 908
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 909
	local targetChars = math.max( -- 912
		2000, -- 912
		math.floor(tokenBudget * charsPerToken) -- 912
	) -- 912
	local keepHead = math.max( -- 913
		0, -- 913
		math.floor(targetChars * 0.35) -- 913
	) -- 913
	local keepTail = math.max(0, targetChars - keepHead) -- 914
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 915
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 916
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 917
end -- 905
function MemoryCompressor.prototype.buildBoundedCompressionSections(self, currentMemory, historyText) -- 920
	local contextWindow = self:getContextWindow() -- 924
	local reservedOutputTokens = math.max( -- 925
		2048, -- 925
		math.floor(contextWindow * 0.2) -- 925
	) -- 925
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBodyRaw("", "")) -- 926
	local dynamicBudget = math.max(1600, contextWindow - reservedOutputTokens - staticPromptTokens - 256) -- 927
	local boundedMemory = clipTextToTokenBudget( -- 928
		currentMemory or "(empty)", -- 928
		math.max( -- 928
			320, -- 928
			math.floor(dynamicBudget * 0.35) -- 928
		) -- 928
	) -- 928
	local boundedHistory = clipTextToTokenBudget( -- 929
		historyText, -- 929
		math.max( -- 929
			800, -- 929
			math.floor(dynamicBudget * 0.65) -- 929
		) -- 929
	) -- 929
	return {currentMemory = boundedMemory, historyText = boundedHistory} -- 930
end -- 920
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 936
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 936
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 942
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 945
		local messages = {{role = "system", content = self.config.promptPack.memoryCompressionSystemPrompt}, {role = "user", content = prompt}} -- 969
		local fn -- 980
		local argsText = "" -- 981
		do -- 981
			local i = 0 -- 982
			while i < maxLLMTry do -- 982
				local response = __TS__Await(callLLM( -- 984
					messages, -- 985
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 986
					nil, -- 991
					self.config.llmConfig -- 992
				)) -- 992
				if not response.success then -- 992
					return ____awaiter_resolve(nil, { -- 992
						success = false, -- 997
						memoryUpdate = currentMemory, -- 998
						historyEntry = "", -- 999
						compressedCount = 0, -- 1000
						error = response.message -- 1001
					}) -- 1001
				end -- 1001
				local choice = response.response.choices and response.response.choices[1] -- 1005
				local message = choice and choice.message -- 1006
				local toolCalls = message and message.tool_calls -- 1007
				local toolCall = toolCalls and toolCalls[1] -- 1008
				fn = toolCall and toolCall["function"] -- 1009
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 1010
				if fn ~= nil and #argsText > 0 then -- 1010
					break -- 1011
				end -- 1011
				i = i + 1 -- 982
			end -- 982
		end -- 982
		if not fn or fn.name ~= "save_memory" then -- 982
			return ____awaiter_resolve(nil, { -- 982
				success = false, -- 1016
				memoryUpdate = currentMemory, -- 1017
				historyEntry = "", -- 1018
				compressedCount = 0, -- 1019
				error = "missing save_memory tool call" -- 1020
			}) -- 1020
		end -- 1020
		if __TS__StringTrim(argsText) == "" then -- 1020
			return ____awaiter_resolve(nil, { -- 1020
				success = false, -- 1026
				memoryUpdate = currentMemory, -- 1027
				historyEntry = "", -- 1028
				compressedCount = 0, -- 1029
				error = "empty save_memory tool arguments" -- 1030
			}) -- 1030
		end -- 1030
		local ____try = __TS__AsyncAwaiter(function() -- 1030
			local args, err = json.decode(argsText) -- 1036
			if err ~= nil or not args or type(args) ~= "table" then -- 1036
				return ____awaiter_resolve( -- 1036
					nil, -- 1036
					{ -- 1038
						success = false, -- 1039
						memoryUpdate = currentMemory, -- 1040
						historyEntry = "", -- 1041
						compressedCount = 0, -- 1042
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 1043
					} -- 1043
				) -- 1043
			end -- 1043
			return ____awaiter_resolve( -- 1043
				nil, -- 1043
				self:buildCompressionResultFromObject(args, currentMemory) -- 1047
			) -- 1047
		end) -- 1047
		__TS__Await(____try.catch( -- 1035
			____try, -- 1035
			function(____, ____error) -- 1035
				return ____awaiter_resolve( -- 1035
					nil, -- 1035
					{ -- 1052
						success = false, -- 1053
						memoryUpdate = currentMemory, -- 1054
						historyEntry = "", -- 1055
						compressedCount = 0, -- 1056
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 1057
					} -- 1057
				) -- 1057
			end -- 1057
		)) -- 1057
	end) -- 1057
end -- 936
function MemoryCompressor.prototype.callLLMForCompressionByYAML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 1062
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1062
		local prompt = self:buildYAMLCompressionPrompt(currentMemory, historyText) -- 1068
		local lastError = "invalid yaml response" -- 1069
		do -- 1069
			local i = 0 -- 1071
			while i < maxLLMTry do -- 1071
				do -- 1071
					local feedback = i > 0 and "\n\n" .. replaceTemplateVars(self.config.promptPack.memoryCompressionYamlRetryPrompt, {LAST_ERROR = lastError}) or "" -- 1072
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions, nil, self.config.llmConfig)) -- 1077
					if not response.success then -- 1077
						return ____awaiter_resolve(nil, { -- 1077
							success = false, -- 1086
							memoryUpdate = currentMemory, -- 1087
							historyEntry = "", -- 1088
							compressedCount = 0, -- 1089
							error = response.message -- 1090
						}) -- 1090
					end -- 1090
					local choice = response.response.choices and response.response.choices[1] -- 1094
					local message = choice and choice.message -- 1095
					local text = message and type(message.content) == "string" and message.content or "" -- 1096
					if __TS__StringTrim(text) == "" then -- 1096
						lastError = "empty yaml response" -- 1098
						goto __continue129 -- 1099
					end -- 1099
					local parsed = self:parseCompressionYAMLObject(text, currentMemory) -- 1102
					if parsed.success then -- 1102
						return ____awaiter_resolve(nil, parsed) -- 1102
					end -- 1102
					lastError = parsed.error or "invalid yaml response" -- 1106
				end -- 1106
				::__continue129:: -- 1106
				i = i + 1 -- 1071
			end -- 1071
		end -- 1071
		return ____awaiter_resolve(nil, { -- 1071
			success = false, -- 1110
			memoryUpdate = currentMemory, -- 1111
			historyEntry = "", -- 1112
			compressedCount = 0, -- 1113
			error = lastError -- 1114
		}) -- 1114
	end) -- 1114
end -- 1062
function MemoryCompressor.prototype.buildCompressionPromptBodyRaw(self, currentMemory, historyText) -- 1121
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = currentMemory or "(empty)", HISTORY_TEXT = historyText}) -- 1122
end -- 1121
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 1128
	local bounded = self:buildBoundedCompressionSections(currentMemory, historyText) -- 1129
	return replaceTemplateVars(self.config.promptPack.memoryCompressionBodyPrompt, {CURRENT_MEMORY = bounded.currentMemory, HISTORY_TEXT = bounded.historyText}) -- 1130
end -- 1128
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 1136
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionToolCallingPrompt -- 1137
end -- 1136
function MemoryCompressor.prototype.buildYAMLCompressionPrompt(self, currentMemory, historyText) -- 1142
	return (self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n") .. self.config.promptPack.memoryCompressionYamlPrompt -- 1143
end -- 1142
function MemoryCompressor.prototype.extractYAMLFromText(self, text) -- 1148
	local source = __TS__StringTrim(text) -- 1149
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 1150
	if yamlFencePos >= 0 then -- 1150
		local from = yamlFencePos + #"```yaml" -- 1152
		local ____end = (string.find( -- 1153
			source, -- 1153
			"```", -- 1153
			math.max(from + 1, 1), -- 1153
			true -- 1153
		) or 0) - 1 -- 1153
		if ____end > from then -- 1153
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1154
		end -- 1154
	end -- 1154
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 1156
	if ymlFencePos >= 0 then -- 1156
		local from = ymlFencePos + #"```yml" -- 1158
		local ____end = (string.find( -- 1159
			source, -- 1159
			"```", -- 1159
			math.max(from + 1, 1), -- 1159
			true -- 1159
		) or 0) - 1 -- 1159
		if ____end > from then -- 1159
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 1160
		end -- 1160
	end -- 1160
	return source -- 1162
end -- 1148
function MemoryCompressor.prototype.parseCompressionYAMLObject(self, text, currentMemory) -- 1165
	local yamlText = self:extractYAMLFromText(text) -- 1166
	local obj, err = yaml.parse(yamlText) -- 1167
	if not obj or type(obj) ~= "table" then -- 1167
		return { -- 1169
			success = false, -- 1170
			memoryUpdate = currentMemory, -- 1171
			historyEntry = "", -- 1172
			compressedCount = 0, -- 1173
			error = "invalid yaml: " .. tostring(err) -- 1174
		} -- 1174
	end -- 1174
	return self:buildCompressionResultFromObject(obj, currentMemory) -- 1177
end -- 1165
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 1183
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 1187
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 1188
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 1188
		return { -- 1190
			success = false, -- 1191
			memoryUpdate = currentMemory, -- 1192
			historyEntry = "", -- 1193
			compressedCount = 0, -- 1194
			error = "missing history_entry or memory_update" -- 1195
		} -- 1195
	end -- 1195
	local ts = os.date("%Y-%m-%d %H:%M") -- 1198
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 1199
end -- 1183
function MemoryCompressor.prototype.handleCompressionFailure(self, userQuery, chunk, ____error) -- 1210
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 1215
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 1215
		self:rawArchive(userQuery, chunk) -- 1219
		self.consecutiveFailures = 0 -- 1220
		return { -- 1222
			success = true, -- 1223
			memoryUpdate = self.storage:readMemory(), -- 1224
			historyEntry = "[RAW ARCHIVE] Detailed history not recorded", -- 1225
			compressedCount = #chunk -- 1226
		} -- 1226
	end -- 1226
	return { -- 1230
		success = false, -- 1231
		memoryUpdate = self.storage:readMemory(), -- 1232
		historyEntry = "", -- 1233
		compressedCount = 0, -- 1234
		error = ____error -- 1235
	} -- 1235
end -- 1210
function MemoryCompressor.prototype.rawArchive(self, userQuery, chunk) -- 1242
	local ts = os.date("%Y-%m-%d %H:%M") -- 1243
	local prompt = __TS__StringTrim(userQuery) ~= "" and __TS__StringReplace( -- 1244
		__TS__StringTrim(userQuery), -- 1245
		"\n", -- 1245
		" " -- 1245
	) or "(empty prompt)" -- 1245
	local compactPrompt = #prompt > 160 and string.sub(prompt, 1, 160) .. "..." or prompt -- 1247
	self.storage:appendHistory(((((("[" .. ts) .. "] [RAW ARCHIVE] prompt=\"") .. compactPrompt) .. "\" (") .. tostring(#chunk)) .. " actions, compression failed; detailed history not recorded)") -- 1248
end -- 1242
function MemoryCompressor.prototype.getStorage(self) -- 1256
	return self.storage -- 1257
end -- 1256
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 1260
	return math.max( -- 1261
		1, -- 1261
		math.floor(self.config.maxCompressionRounds) -- 1261
	) -- 1261
end -- 1260
MemoryCompressor.MAX_FAILURES = 3 -- 1260
return ____exports -- 1260