-- [ts]: Memory.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
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
local ____Tools = require("Agent.Tools") -- 4
local sendWebIDEFileUpdate = ____Tools.sendWebIDEFileUpdate -- 4
local yaml = require("yaml") -- 5
____exports.DEFAULT_AGENT_PROMPT = "You are a coding assistant that helps modify and navigate code." -- 9
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 59
local TokenEstimator = ____exports.TokenEstimator -- 59
TokenEstimator.name = "TokenEstimator" -- 59
function TokenEstimator.prototype.____constructor(self) -- 59
end -- 59
function TokenEstimator.estimate(self, text) -- 69
	if not text then -- 69
		return 0 -- 70
	end -- 70
	local chineseChars = utf8.len(text) -- 73
	if not chineseChars then -- 73
		return 0 -- 74
	end -- 74
	local otherChars = #text - chineseChars -- 76
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 78
	return math.max(1, tokens) -- 83
end -- 69
function TokenEstimator.estimateHistory(self, history, formatFunc) -- 89
	if not history or #history == 0 then -- 89
		return 0 -- 90
	end -- 90
	local text = formatFunc(history) -- 91
	return self:estimate(text) -- 92
end -- 89
function TokenEstimator.estimatePrompt(self, userQuery, history, systemPrompt, toolDefinitions, formatFunc) -- 98
	return self:estimate(userQuery) + self:estimateHistory(history, formatFunc) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 105
end -- 98
TokenEstimator.CHARS_PER_TOKEN = 4 -- 98
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 98
local function utf8TakeHead(text, maxChars) -- 114
	if maxChars <= 0 or text == "" then -- 114
		return "" -- 115
	end -- 115
	local nextPos = utf8.offset(text, maxChars + 1) -- 116
	if nextPos == nil then -- 116
		return text -- 117
	end -- 117
	return string.sub(text, 1, nextPos - 1) -- 118
end -- 114
local function utf8TakeTail(text, maxChars) -- 121
	if maxChars <= 0 or text == "" then -- 121
		return "" -- 122
	end -- 122
	local charLen = utf8.len(text) -- 123
	if charLen == false or charLen <= maxChars then -- 123
		return text -- 124
	end -- 124
	local startChar = math.max(1, charLen - maxChars + 1) -- 125
	local startPos = utf8.offset(text, startChar) -- 126
	if startPos == nil then -- 126
		return text -- 127
	end -- 127
	return string.sub(text, startPos) -- 128
end -- 121
--- 双层存储管理器
-- 
-- 管理 AGENT.md、MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 136
local DualLayerStorage = ____exports.DualLayerStorage -- 136
DualLayerStorage.name = "DualLayerStorage" -- 136
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 143
	self.projectDir = projectDir -- 144
	self.agentDir = Path(self.projectDir, ".agent") -- 145
	self.agentPath = Path(self.agentDir, "AGENT.md") -- 146
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 147
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 148
	self:ensureAgentFiles() -- 149
end -- 143
function DualLayerStorage.prototype.ensureDir(self, dir) -- 152
	if not Content:exist(dir) then -- 152
		Content:mkdir(dir) -- 154
	end -- 154
end -- 152
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 158
	if Content:exist(path) then -- 158
		return false -- 159
	end -- 159
	self:ensureDir(Path:getPath(path)) -- 160
	if not Content:save(path, content) then -- 160
		return false -- 162
	end -- 162
	sendWebIDEFileUpdate(path, true, content) -- 164
	return true -- 165
end -- 158
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 168
	self:ensureDir(self.agentDir) -- 169
	self:ensureFile(self.agentPath, ____exports.DEFAULT_AGENT_PROMPT .. "\n") -- 170
	self:ensureFile(self.memoryPath, "") -- 171
	self:ensureFile(self.historyPath, "") -- 172
end -- 168
function DualLayerStorage.prototype.readAgentPrompt(self) -- 175
	if not Content:exist(self.agentPath) then -- 175
		return ____exports.DEFAULT_AGENT_PROMPT -- 177
	end -- 177
	local prompt = Content:load(self.agentPath) -- 179
	return __TS__StringTrim(prompt) == "" and ____exports.DEFAULT_AGENT_PROMPT or prompt -- 180
end -- 175
function DualLayerStorage.prototype.readMemory(self) -- 188
	if not Content:exist(self.memoryPath) then -- 188
		return "" -- 190
	end -- 190
	return Content:load(self.memoryPath) -- 192
end -- 188
function DualLayerStorage.prototype.writeMemory(self, content) -- 198
	self:ensureDir(Path:getPath(self.memoryPath)) -- 199
	Content:save(self.memoryPath, content) -- 200
end -- 198
function DualLayerStorage.prototype.getMemoryContext(self) -- 206
	local memory = self:readMemory() -- 207
	if not memory then -- 207
		return "" -- 208
	end -- 208
	return "## Long-term Memory\n\n" .. memory -- 210
end -- 206
function DualLayerStorage.prototype.appendHistory(self, entry) -- 220
	self:ensureDir(Path:getPath(self.historyPath)) -- 221
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 223
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 227
end -- 220
function DualLayerStorage.prototype.readHistory(self) -- 233
	if not Content:exist(self.historyPath) then -- 233
		return "" -- 235
	end -- 235
	return Content:load(self.historyPath) -- 237
end -- 233
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 243
	local history = self:readHistory() -- 244
	if not history then -- 244
		return {} -- 245
	end -- 245
	local lines = __TS__StringSplit(history, "\n") -- 247
	local lowerKeyword = string.lower(keyword) -- 248
	return __TS__ArrayFilter( -- 250
		lines, -- 250
		function(____, line) return __TS__StringIncludes( -- 250
			string.lower(line), -- 251
			lowerKeyword -- 251
		) end -- 251
	) -- 251
end -- 243
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 264
local MemoryCompressor = ____exports.MemoryCompressor -- 264
MemoryCompressor.name = "MemoryCompressor" -- 264
function MemoryCompressor.prototype.____constructor(self, config) -- 271
	self.consecutiveFailures = 0 -- 267
	self.config = __TS__ObjectAssign( -- 272
		{ -- 272
			contextWindow = 32000, -- 273
			compressionThreshold = 0.8, -- 274
			maxCompressionRounds = 3, -- 275
			maxTokensPerCompression = 20000, -- 276
			projectDir = config and config.projectDir or Path(Content.appPath, ".agent") -- 277
		}, -- 277
		config -- 278
	) -- 278
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 280
end -- 271
function MemoryCompressor.prototype.shouldCompress(self, userQuery, history, lastConsolidatedIndex, systemPrompt, toolDefinitions, formatFunc) -- 286
	local uncompressedHistory = __TS__ArraySlice(history, lastConsolidatedIndex) -- 294
	local tokens = ____exports.TokenEstimator:estimatePrompt( -- 296
		userQuery, -- 297
		uncompressedHistory, -- 298
		systemPrompt, -- 299
		toolDefinitions, -- 300
		formatFunc -- 301
	) -- 301
	local threshold = self.config.contextWindow * self.config.compressionThreshold -- 304
	return tokens > threshold -- 306
end -- 286
function MemoryCompressor.prototype.compress(self, history, lastConsolidatedIndex, llmOptions, formatFunc, maxLLMTry, decisionMode) -- 312
	if decisionMode == nil then -- 312
		decisionMode = "tool_calling" -- 318
	end -- 318
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 318
		local toCompress = __TS__ArraySlice(history, lastConsolidatedIndex) -- 320
		if #toCompress == 0 then -- 320
			return ____awaiter_resolve(nil, nil) -- 320
		end -- 320
		local boundary = self:findCompressionBoundary(toCompress, formatFunc) -- 324
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 325
		if #chunk == 0 then -- 325
			return ____awaiter_resolve(nil, nil) -- 325
		end -- 325
		local currentMemory = self.storage:readMemory() -- 329
		local historyText = formatFunc(chunk) -- 330
		local ____try = __TS__AsyncAwaiter(function() -- 330
			local result = __TS__Await(self:callLLMForCompression( -- 334
				currentMemory, -- 335
				historyText, -- 336
				llmOptions, -- 337
				maxLLMTry or 3, -- 338
				decisionMode -- 339
			)) -- 339
			if result.success then -- 339
				self.storage:writeMemory(result.memoryUpdate) -- 344
				self.storage:appendHistory(result.historyEntry) -- 345
				self.consecutiveFailures = 0 -- 346
				return ____awaiter_resolve( -- 346
					nil, -- 346
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 348
				) -- 348
			end -- 348
			return ____awaiter_resolve( -- 348
				nil, -- 348
				self:handleCompressionFailure(chunk, result.error or "Unknown error", formatFunc) -- 355
			) -- 355
		end) -- 355
		__TS__Await(____try.catch( -- 332
			____try, -- 332
			function(____, ____error) -- 332
				return ____awaiter_resolve( -- 332
					nil, -- 332
					self:handleCompressionFailure( -- 359
						chunk, -- 360
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error", -- 361
						formatFunc -- 362
					) -- 362
				) -- 362
			end -- 362
		)) -- 362
	end) -- 362
end -- 312
function MemoryCompressor.prototype.findCompressionBoundary(self, history, formatFunc) -- 372
	local targetTokens = self.config.maxTokensPerCompression -- 376
	local accumulatedTokens = 0 -- 377
	do -- 377
		local i = 0 -- 379
		while i < #history do -- 379
			local record = history[i + 1] -- 380
			local tokens = ____exports.TokenEstimator:estimate(formatFunc({record})) -- 381
			accumulatedTokens = accumulatedTokens + tokens -- 385
			if accumulatedTokens > targetTokens then -- 385
				return math.max(1, i) -- 389
			end -- 389
			i = i + 1 -- 379
		end -- 379
	end -- 379
	return #history -- 393
end -- 372
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 399
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 399
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 406
		if decisionMode == "yaml" then -- 406
			return ____awaiter_resolve( -- 406
				nil, -- 406
				self:callLLMForCompressionByYAML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 408
			) -- 408
		end -- 408
		return ____awaiter_resolve( -- 408
			nil, -- 408
			self:callLLMForCompressionByToolCalling(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 415
		) -- 415
	end) -- 415
end -- 399
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 423
	local contextWindow = math.max(4000, self.config.contextWindow) -- 424
	local reservedOutputTokens = math.max( -- 425
		2048, -- 425
		math.floor(contextWindow * 0.2) -- 425
	) -- 425
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBody("", "")) -- 426
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 427
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 428
	return math.max( -- 429
		1200, -- 429
		math.floor(available * 0.9) -- 429
	) -- 429
end -- 423
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 432
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 433
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 434
	if historyTokens <= tokenBudget then -- 434
		return historyText -- 435
	end -- 435
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 436
	local targetChars = math.max( -- 439
		2000, -- 439
		math.floor(tokenBudget * charsPerToken) -- 439
	) -- 439
	local keepHead = math.max( -- 440
		0, -- 440
		math.floor(targetChars * 0.35) -- 440
	) -- 440
	local keepTail = math.max(0, targetChars - keepHead) -- 441
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 442
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 443
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 444
end -- 432
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 447
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 447
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 453
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 456
		local messages = {{role = "system", content = "You are a memory consolidation agent. You MUST call the save_memory tool."}, {role = "user", content = prompt}} -- 480
		local fn -- 491
		local argsText = "" -- 492
		do -- 492
			local i = 0 -- 493
			while i < maxLLMTry do -- 493
				local response = __TS__Await(callLLM( -- 495
					messages, -- 496
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 497
				)) -- 497
				if not response.success then -- 497
					return ____awaiter_resolve(nil, { -- 497
						success = false, -- 506
						memoryUpdate = currentMemory, -- 507
						historyEntry = "", -- 508
						compressedCount = 0, -- 509
						error = response.message -- 510
					}) -- 510
				end -- 510
				local choice = response.response.choices and response.response.choices[1] -- 514
				local message = choice and choice.message -- 515
				local toolCalls = message and message.tool_calls -- 516
				local toolCall = toolCalls and toolCalls[1] -- 517
				fn = toolCall and toolCall["function"] -- 518
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 519
				if fn ~= nil and #argsText > 0 then -- 519
					break -- 520
				end -- 520
				i = i + 1 -- 493
			end -- 493
		end -- 493
		if not fn or fn.name ~= "save_memory" then -- 493
			return ____awaiter_resolve(nil, { -- 493
				success = false, -- 525
				memoryUpdate = currentMemory, -- 526
				historyEntry = "", -- 527
				compressedCount = 0, -- 528
				error = "missing save_memory tool call" -- 529
			}) -- 529
		end -- 529
		if __TS__StringTrim(argsText) == "" then -- 529
			return ____awaiter_resolve(nil, { -- 529
				success = false, -- 535
				memoryUpdate = currentMemory, -- 536
				historyEntry = "", -- 537
				compressedCount = 0, -- 538
				error = "empty save_memory tool arguments" -- 539
			}) -- 539
		end -- 539
		local ____try = __TS__AsyncAwaiter(function() -- 539
			local args, err = json.decode(argsText) -- 545
			if err ~= nil or not args or type(args) ~= "table" then -- 545
				return ____awaiter_resolve( -- 545
					nil, -- 545
					{ -- 547
						success = false, -- 548
						memoryUpdate = currentMemory, -- 549
						historyEntry = "", -- 550
						compressedCount = 0, -- 551
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 552
					} -- 552
				) -- 552
			end -- 552
			return ____awaiter_resolve( -- 552
				nil, -- 552
				self:buildCompressionResultFromObject(args, currentMemory) -- 556
			) -- 556
		end) -- 556
		__TS__Await(____try.catch( -- 544
			____try, -- 544
			function(____, ____error) -- 544
				return ____awaiter_resolve( -- 544
					nil, -- 544
					{ -- 561
						success = false, -- 562
						memoryUpdate = currentMemory, -- 563
						historyEntry = "", -- 564
						compressedCount = 0, -- 565
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 566
					} -- 566
				) -- 566
			end -- 566
		)) -- 566
	end) -- 566
end -- 447
function MemoryCompressor.prototype.callLLMForCompressionByYAML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 571
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 571
		local prompt = self:buildYAMLCompressionPrompt(currentMemory, historyText) -- 577
		local lastError = "invalid yaml response" -- 578
		do -- 578
			local i = 0 -- 580
			while i < maxLLMTry do -- 580
				do -- 580
					local feedback = i > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only." or "" -- 581
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions)) -- 584
					if not response.success then -- 584
						return ____awaiter_resolve(nil, { -- 584
							success = false, -- 591
							memoryUpdate = currentMemory, -- 592
							historyEntry = "", -- 593
							compressedCount = 0, -- 594
							error = response.message -- 595
						}) -- 595
					end -- 595
					local choice = response.response.choices and response.response.choices[1] -- 599
					local message = choice and choice.message -- 600
					local text = message and type(message.content) == "string" and message.content or "" -- 601
					if __TS__StringTrim(text) == "" then -- 601
						lastError = "empty yaml response" -- 603
						goto __continue65 -- 604
					end -- 604
					local parsed = self:parseCompressionYAMLObject(text, currentMemory) -- 607
					if parsed.success then -- 607
						return ____awaiter_resolve(nil, parsed) -- 607
					end -- 607
					lastError = parsed.error or "invalid yaml response" -- 611
				end -- 611
				::__continue65:: -- 611
				i = i + 1 -- 580
			end -- 580
		end -- 580
		return ____awaiter_resolve(nil, { -- 580
			success = false, -- 615
			memoryUpdate = currentMemory, -- 616
			historyEntry = "", -- 617
			compressedCount = 0, -- 618
			error = lastError -- 619
		}) -- 619
	end) -- 619
end -- 571
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 626
	return ((("Process this conversation and consolidate it.\n\n## Current Long-term Memory\n" .. (currentMemory or "(empty)")) .. "\n\n## Recent Actions to Process\n") .. historyText) .. "\n\n## Instructions\n\n1. **Analyze the conversation**:\n\t- What was the user trying to accomplish?\n\t- What tools were used and what were the results?\n\t- Were there any problems or solutions?\n\t- What decisions were made?\n\n2. **Update the long-term memory**:\n\t- Preserve all existing facts\n\t- Add new important information (user preferences, project context, decisions)\n\t- Remove outdated or redundant information\n\t- Keep the memory concise but complete\n\n3. **Create a history entry**:\n\t- Summarize key events, decisions, and outcomes\n\t- Include details useful for grep search\n\t- Format as a single paragraph\n" -- 627
end -- 626
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 656
	return self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n## Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content" -- 657
end -- 656
function MemoryCompressor.prototype.buildYAMLCompressionPrompt(self, currentMemory, historyText) -- 666
	return self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n## Output Format\n\nReturn exactly one YAML object:\n```yaml\nhistory_entry: \"Summary paragraph\"\nmemory_update: |-\n\tFull updated MEMORY.md content\n```\n\nRules:\n- Return YAML only, no prose before or after.\n- Use exactly two keys: history_entry, memory_update.\n- Use a block scalar for memory_update when it spans multiple lines." -- 667
end -- 666
function MemoryCompressor.prototype.extractYAMLFromText(self, text) -- 684
	local source = __TS__StringTrim(text) -- 685
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 686
	if yamlFencePos >= 0 then -- 686
		local from = yamlFencePos + #"```yaml" -- 688
		local ____end = (string.find( -- 689
			source, -- 689
			"```", -- 689
			math.max(from + 1, 1), -- 689
			true -- 689
		) or 0) - 1 -- 689
		if ____end > from then -- 689
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 690
		end -- 690
	end -- 690
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 692
	if ymlFencePos >= 0 then -- 692
		local from = ymlFencePos + #"```yml" -- 694
		local ____end = (string.find( -- 695
			source, -- 695
			"```", -- 695
			math.max(from + 1, 1), -- 695
			true -- 695
		) or 0) - 1 -- 695
		if ____end > from then -- 695
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 696
		end -- 696
	end -- 696
	return source -- 698
end -- 684
function MemoryCompressor.prototype.parseCompressionYAMLObject(self, text, currentMemory) -- 701
	local yamlText = self:extractYAMLFromText(text) -- 702
	local obj, err = yaml.parse(yamlText) -- 703
	if not obj or type(obj) ~= "table" then -- 703
		return { -- 705
			success = false, -- 706
			memoryUpdate = currentMemory, -- 707
			historyEntry = "", -- 708
			compressedCount = 0, -- 709
			error = "invalid yaml: " .. tostring(err) -- 710
		} -- 710
	end -- 710
	return self:buildCompressionResultFromObject(obj, currentMemory) -- 713
end -- 701
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 719
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 723
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 724
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 724
		return { -- 726
			success = false, -- 727
			memoryUpdate = currentMemory, -- 728
			historyEntry = "", -- 729
			compressedCount = 0, -- 730
			error = "missing history_entry or memory_update" -- 731
		} -- 731
	end -- 731
	local ts = os.date("%Y-%m-%d %H:%M") -- 734
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 735
end -- 719
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error, formatFunc) -- 746
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 751
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 751
		self:rawArchive(chunk, formatFunc) -- 755
		self.consecutiveFailures = 0 -- 756
		return { -- 758
			success = true, -- 759
			memoryUpdate = self.storage:readMemory(), -- 760
			historyEntry = "[RAW ARCHIVE] See HISTORY.md for details", -- 761
			compressedCount = #chunk -- 762
		} -- 762
	end -- 762
	return { -- 766
		success = false, -- 767
		memoryUpdate = self.storage:readMemory(), -- 768
		historyEntry = "", -- 769
		compressedCount = 0, -- 770
		error = ____error -- 771
	} -- 771
end -- 746
function MemoryCompressor.prototype.rawArchive(self, chunk, formatFunc) -- 778
	local ts = os.date("%Y-%m-%d %H:%M") -- 779
	local text = formatFunc(chunk) -- 780
	self.storage:appendHistory((((("[" .. ts) .. "] [RAW ARCHIVE] ") .. tostring(#chunk)) .. " actions (compression failed)\n") .. ("---\n" .. text) .. "\n---")
end -- 778
function MemoryCompressor.prototype.getStorage(self) -- 791
	return self.storage -- 792
end -- 791
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 795
	return math.max( -- 796
		1, -- 796
		math.floor(self.config.maxCompressionRounds) -- 796
	) -- 796
end -- 795
MemoryCompressor.MAX_FAILURES = 3 -- 795
return ____exports -- 795