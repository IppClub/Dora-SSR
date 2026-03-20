-- [ts]: Memory.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
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
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local json = ____Dora.json -- 2
local ____Utils = require("Agent.Utils") -- 3
local callLLM = ____Utils.callLLM -- 3
local yaml = require("yaml") -- 4
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 56
local TokenEstimator = ____exports.TokenEstimator -- 56
TokenEstimator.name = "TokenEstimator" -- 56
function TokenEstimator.prototype.____constructor(self) -- 56
end -- 56
function TokenEstimator.estimate(self, text) -- 66
	if not text then -- 66
		return 0 -- 67
	end -- 67
	local chineseChars = utf8.len(text) -- 70
	if not chineseChars then -- 70
		return 0 -- 71
	end -- 71
	local otherChars = #text - chineseChars -- 73
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 75
	return math.max(1, tokens) -- 80
end -- 66
function TokenEstimator.estimateHistory(self, history, formatFunc) -- 86
	if not history or #history == 0 then -- 86
		return 0 -- 87
	end -- 87
	local text = formatFunc(history) -- 88
	return self:estimate(text) -- 89
end -- 86
function TokenEstimator.estimatePrompt(self, userQuery, history, systemPrompt, toolDefinitions, formatFunc) -- 95
	return self:estimate(userQuery) + self:estimateHistory(history, formatFunc) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 102
end -- 95
TokenEstimator.CHARS_PER_TOKEN = 4 -- 95
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 95
local function utf8TakeHead(text, maxChars) -- 111
	if maxChars <= 0 or text == "" then -- 111
		return "" -- 112
	end -- 112
	local nextPos = utf8.offset(text, maxChars + 1) -- 113
	if nextPos == nil then -- 113
		return text -- 114
	end -- 114
	return string.sub(text, 1, nextPos - 1) -- 115
end -- 111
local function utf8TakeTail(text, maxChars) -- 118
	if maxChars <= 0 or text == "" then -- 118
		return "" -- 119
	end -- 119
	local charLen = utf8.len(text) -- 120
	if charLen == false or charLen <= maxChars then -- 120
		return text -- 121
	end -- 121
	local startChar = math.max(1, charLen - maxChars + 1) -- 122
	local startPos = utf8.offset(text, startChar) -- 123
	if startPos == nil then -- 123
		return text -- 124
	end -- 124
	return string.sub(text, startPos) -- 125
end -- 118
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 133
local DualLayerStorage = ____exports.DualLayerStorage -- 133
DualLayerStorage.name = "DualLayerStorage" -- 133
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 138
	self.projectDir = projectDir -- 139
	local agentDir = Path(self.projectDir, ".agent") -- 140
	self:ensureDir(agentDir) -- 142
	self.memoryPath = Path(agentDir, "MEMORY.md") -- 144
	self.historyPath = Path(agentDir, "HISTORY.md") -- 145
end -- 138
function DualLayerStorage.prototype.ensureDir(self, dir) -- 148
	if not Content:exist(dir) then -- 148
		Content:mkdir(dir) -- 150
	end -- 150
end -- 148
function DualLayerStorage.prototype.readMemory(self) -- 159
	if not Content:exist(self.memoryPath) then -- 159
		return "" -- 161
	end -- 161
	return Content:load(self.memoryPath) -- 163
end -- 159
function DualLayerStorage.prototype.writeMemory(self, content) -- 169
	self:ensureDir(Path:getPath(self.memoryPath)) -- 170
	Content:save(self.memoryPath, content) -- 171
end -- 169
function DualLayerStorage.prototype.getMemoryContext(self) -- 177
	local memory = self:readMemory() -- 178
	if not memory then -- 178
		return "" -- 179
	end -- 179
	return "## Long-term Memory\n\n" .. memory -- 181
end -- 177
function DualLayerStorage.prototype.appendHistory(self, entry) -- 191
	self:ensureDir(Path:getPath(self.historyPath)) -- 192
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 194
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 198
end -- 191
function DualLayerStorage.prototype.readHistory(self) -- 204
	if not Content:exist(self.historyPath) then -- 204
		return "" -- 206
	end -- 206
	return Content:load(self.historyPath) -- 208
end -- 204
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 214
	local history = self:readHistory() -- 215
	if not history then -- 215
		return {} -- 216
	end -- 216
	local lines = __TS__StringSplit(history, "\n") -- 218
	local lowerKeyword = string.lower(keyword) -- 219
	return __TS__ArrayFilter( -- 221
		lines, -- 221
		function(____, line) return __TS__StringIncludes( -- 221
			string.lower(line), -- 222
			lowerKeyword -- 222
		) end -- 222
	) -- 222
end -- 214
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 235
local MemoryCompressor = ____exports.MemoryCompressor -- 235
MemoryCompressor.name = "MemoryCompressor" -- 235
function MemoryCompressor.prototype.____constructor(self, config) -- 242
	self.consecutiveFailures = 0 -- 238
	self.config = __TS__ObjectAssign( -- 243
		{ -- 243
			contextWindow = 32000, -- 244
			compressionThreshold = 0.8, -- 245
			maxCompressionRounds = 3, -- 246
			maxTokensPerCompression = 20000, -- 247
			projectDir = config and config.projectDir or Path(Content.appPath, ".agent") -- 248
		}, -- 248
		config -- 249
	) -- 249
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 251
end -- 242
function MemoryCompressor.prototype.shouldCompress(self, userQuery, history, lastConsolidatedIndex, systemPrompt, toolDefinitions, formatFunc) -- 257
	local uncompressedHistory = __TS__ArraySlice(history, lastConsolidatedIndex) -- 265
	local tokens = ____exports.TokenEstimator:estimatePrompt( -- 267
		userQuery, -- 268
		uncompressedHistory, -- 269
		systemPrompt, -- 270
		toolDefinitions, -- 271
		formatFunc -- 272
	) -- 272
	local threshold = self.config.contextWindow * self.config.compressionThreshold -- 275
	return tokens > threshold -- 277
end -- 257
function MemoryCompressor.prototype.compress(self, history, lastConsolidatedIndex, llmOptions, formatFunc, maxLLMTry, decisionMode) -- 283
	if decisionMode == nil then -- 283
		decisionMode = "tool_calling" -- 289
	end -- 289
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 289
		local toCompress = __TS__ArraySlice(history, lastConsolidatedIndex) -- 291
		if #toCompress == 0 then -- 291
			return ____awaiter_resolve(nil, nil) -- 291
		end -- 291
		local boundary = self:findCompressionBoundary(toCompress, formatFunc) -- 295
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 296
		if #chunk == 0 then -- 296
			return ____awaiter_resolve(nil, nil) -- 296
		end -- 296
		local currentMemory = self.storage:readMemory() -- 300
		local historyText = formatFunc(chunk) -- 301
		local ____try = __TS__AsyncAwaiter(function() -- 301
			local result = __TS__Await(self:callLLMForCompression( -- 305
				currentMemory, -- 306
				historyText, -- 307
				llmOptions, -- 308
				maxLLMTry or 3, -- 309
				decisionMode -- 310
			)) -- 310
			if result.success then -- 310
				self.storage:writeMemory(result.memoryUpdate) -- 315
				self.storage:appendHistory(result.historyEntry) -- 316
				self.consecutiveFailures = 0 -- 317
				return ____awaiter_resolve( -- 317
					nil, -- 317
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 319
				) -- 319
			end -- 319
			return ____awaiter_resolve( -- 319
				nil, -- 319
				self:handleCompressionFailure(chunk, result.error or "Unknown error", formatFunc) -- 326
			) -- 326
		end) -- 326
		__TS__Await(____try.catch( -- 303
			____try, -- 303
			function(____, ____error) -- 303
				return ____awaiter_resolve( -- 303
					nil, -- 303
					self:handleCompressionFailure( -- 330
						chunk, -- 331
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error", -- 332
						formatFunc -- 333
					) -- 333
				) -- 333
			end -- 333
		)) -- 333
	end) -- 333
end -- 283
function MemoryCompressor.prototype.findCompressionBoundary(self, history, formatFunc) -- 343
	local targetTokens = self.config.maxTokensPerCompression -- 347
	local accumulatedTokens = 0 -- 348
	do -- 348
		local i = 0 -- 350
		while i < #history do -- 350
			local record = history[i + 1] -- 351
			local tokens = ____exports.TokenEstimator:estimate(formatFunc({record})) -- 352
			accumulatedTokens = accumulatedTokens + tokens -- 356
			if accumulatedTokens > targetTokens then -- 356
				return math.max(1, i) -- 360
			end -- 360
			i = i + 1 -- 350
		end -- 350
	end -- 350
	return #history -- 364
end -- 343
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 370
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 370
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 377
		if decisionMode == "yaml" then -- 377
			return ____awaiter_resolve( -- 377
				nil, -- 377
				self:callLLMForCompressionByYAML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 379
			) -- 379
		end -- 379
		return ____awaiter_resolve( -- 379
			nil, -- 379
			self:callLLMForCompressionByToolCalling(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 386
		) -- 386
	end) -- 386
end -- 370
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 394
	local contextWindow = math.max(4000, self.config.contextWindow) -- 395
	local reservedOutputTokens = math.max( -- 396
		2048, -- 396
		math.floor(contextWindow * 0.2) -- 396
	) -- 396
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBody("", "")) -- 397
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 398
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 399
	return math.max( -- 400
		1200, -- 400
		math.floor(available * 0.9) -- 400
	) -- 400
end -- 394
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 403
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 404
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 405
	if historyTokens <= tokenBudget then -- 405
		return historyText -- 406
	end -- 406
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 407
	local targetChars = math.max( -- 410
		2000, -- 410
		math.floor(tokenBudget * charsPerToken) -- 410
	) -- 410
	local keepHead = math.max( -- 411
		0, -- 411
		math.floor(targetChars * 0.35) -- 411
	) -- 411
	local keepTail = math.max(0, targetChars - keepHead) -- 412
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 413
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 414
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 415
end -- 403
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 418
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 418
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 424
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 427
		local messages = {{role = "system", content = "You are a memory consolidation agent. You MUST call the save_memory tool."}, {role = "user", content = prompt}} -- 451
		local fn -- 462
		local argsText = "" -- 463
		do -- 463
			local i = 0 -- 464
			while i < maxLLMTry do -- 464
				local response = __TS__Await(callLLM( -- 466
					messages, -- 467
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 468
				)) -- 468
				if not response.success then -- 468
					return ____awaiter_resolve(nil, { -- 468
						success = false, -- 477
						memoryUpdate = currentMemory, -- 478
						historyEntry = "", -- 479
						compressedCount = 0, -- 480
						error = response.message -- 481
					}) -- 481
				end -- 481
				local choice = response.response.choices and response.response.choices[1] -- 485
				local message = choice and choice.message -- 486
				local toolCalls = message and message.tool_calls -- 487
				local toolCall = toolCalls and toolCalls[1] -- 488
				fn = toolCall and toolCall["function"] -- 489
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 490
				if fn ~= nil and #argsText > 0 then -- 490
					break -- 491
				end -- 491
				i = i + 1 -- 464
			end -- 464
		end -- 464
		if not fn or fn.name ~= "save_memory" then -- 464
			return ____awaiter_resolve(nil, { -- 464
				success = false, -- 496
				memoryUpdate = currentMemory, -- 497
				historyEntry = "", -- 498
				compressedCount = 0, -- 499
				error = "missing save_memory tool call" -- 500
			}) -- 500
		end -- 500
		if __TS__StringTrim(argsText) == "" then -- 500
			return ____awaiter_resolve(nil, { -- 500
				success = false, -- 506
				memoryUpdate = currentMemory, -- 507
				historyEntry = "", -- 508
				compressedCount = 0, -- 509
				error = "empty save_memory tool arguments" -- 510
			}) -- 510
		end -- 510
		local ____try = __TS__AsyncAwaiter(function() -- 510
			local args, err = json.decode(argsText) -- 516
			if err ~= nil or not args or type(args) ~= "table" then -- 516
				return ____awaiter_resolve( -- 516
					nil, -- 516
					{ -- 518
						success = false, -- 519
						memoryUpdate = currentMemory, -- 520
						historyEntry = "", -- 521
						compressedCount = 0, -- 522
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 523
					} -- 523
				) -- 523
			end -- 523
			return ____awaiter_resolve( -- 523
				nil, -- 523
				self:buildCompressionResultFromObject(args, currentMemory) -- 527
			) -- 527
		end) -- 527
		__TS__Await(____try.catch( -- 515
			____try, -- 515
			function(____, ____error) -- 515
				return ____awaiter_resolve( -- 515
					nil, -- 515
					{ -- 532
						success = false, -- 533
						memoryUpdate = currentMemory, -- 534
						historyEntry = "", -- 535
						compressedCount = 0, -- 536
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 537
					} -- 537
				) -- 537
			end -- 537
		)) -- 537
	end) -- 537
end -- 418
function MemoryCompressor.prototype.callLLMForCompressionByYAML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 542
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 542
		local prompt = self:buildYAMLCompressionPrompt(currentMemory, historyText) -- 548
		local lastError = "invalid yaml response" -- 549
		do -- 549
			local i = 0 -- 551
			while i < maxLLMTry do -- 551
				do -- 551
					local feedback = i > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only." or "" -- 552
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions)) -- 555
					if not response.success then -- 555
						return ____awaiter_resolve(nil, { -- 555
							success = false, -- 562
							memoryUpdate = currentMemory, -- 563
							historyEntry = "", -- 564
							compressedCount = 0, -- 565
							error = response.message -- 566
						}) -- 566
					end -- 566
					local choice = response.response.choices and response.response.choices[1] -- 570
					local message = choice and choice.message -- 571
					local text = message and type(message.content) == "string" and message.content or "" -- 572
					if __TS__StringTrim(text) == "" then -- 572
						lastError = "empty yaml response" -- 574
						goto __continue59 -- 575
					end -- 575
					local parsed = self:parseCompressionYAMLObject(text, currentMemory) -- 578
					if parsed.success then -- 578
						return ____awaiter_resolve(nil, parsed) -- 578
					end -- 578
					lastError = parsed.error or "invalid yaml response" -- 582
				end -- 582
				::__continue59:: -- 582
				i = i + 1 -- 551
			end -- 551
		end -- 551
		return ____awaiter_resolve(nil, { -- 551
			success = false, -- 586
			memoryUpdate = currentMemory, -- 587
			historyEntry = "", -- 588
			compressedCount = 0, -- 589
			error = lastError -- 590
		}) -- 590
	end) -- 590
end -- 542
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 597
	return ((("Process this conversation and consolidate it.\n\n## Current Long-term Memory\n" .. (currentMemory or "(empty)")) .. "\n\n## Recent Actions to Process\n") .. historyText) .. "\n\n## Instructions\n\n1. **Analyze the conversation**:\n\t- What was the user trying to accomplish?\n\t- What tools were used and what were the results?\n\t- Were there any problems or solutions?\n\t- What decisions were made?\n\n2. **Update the long-term memory**:\n\t- Preserve all existing facts\n\t- Add new important information (user preferences, project context, decisions)\n\t- Remove outdated or redundant information\n\t- Keep the memory concise but complete\n\n3. **Create a history entry**:\n\t- Summarize key events, decisions, and outcomes\n\t- Include details useful for grep search\n\t- Format as a single paragraph\n" -- 598
end -- 597
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 627
	return self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n## Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content" -- 628
end -- 627
function MemoryCompressor.prototype.buildYAMLCompressionPrompt(self, currentMemory, historyText) -- 637
	return self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n## Output Format\n\nReturn exactly one YAML object:\n```yaml\nhistory_entry: \"Summary paragraph\"\nmemory_update: |-\n\tFull updated MEMORY.md content\n```\n\nRules:\n- Return YAML only, no prose before or after.\n- Use exactly two keys: history_entry, memory_update.\n- Use a block scalar for memory_update when it spans multiple lines." -- 638
end -- 637
function MemoryCompressor.prototype.extractYAMLFromText(self, text) -- 655
	local source = __TS__StringTrim(text) -- 656
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 657
	if yamlFencePos >= 0 then -- 657
		local from = yamlFencePos + #"```yaml" -- 659
		local ____end = (string.find( -- 660
			source, -- 660
			"```", -- 660
			math.max(from + 1, 1), -- 660
			true -- 660
		) or 0) - 1 -- 660
		if ____end > from then -- 660
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 661
		end -- 661
	end -- 661
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 663
	if ymlFencePos >= 0 then -- 663
		local from = ymlFencePos + #"```yml" -- 665
		local ____end = (string.find( -- 666
			source, -- 666
			"```", -- 666
			math.max(from + 1, 1), -- 666
			true -- 666
		) or 0) - 1 -- 666
		if ____end > from then -- 666
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 667
		end -- 667
	end -- 667
	return source -- 669
end -- 655
function MemoryCompressor.prototype.parseCompressionYAMLObject(self, text, currentMemory) -- 672
	local yamlText = self:extractYAMLFromText(text) -- 673
	local obj, err = yaml.parse(yamlText) -- 674
	if not obj or type(obj) ~= "table" then -- 674
		return { -- 676
			success = false, -- 677
			memoryUpdate = currentMemory, -- 678
			historyEntry = "", -- 679
			compressedCount = 0, -- 680
			error = "invalid yaml: " .. tostring(err) -- 681
		} -- 681
	end -- 681
	return self:buildCompressionResultFromObject(obj, currentMemory) -- 684
end -- 672
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 690
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 694
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 695
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 695
		return { -- 697
			success = false, -- 698
			memoryUpdate = currentMemory, -- 699
			historyEntry = "", -- 700
			compressedCount = 0, -- 701
			error = "missing history_entry or memory_update" -- 702
		} -- 702
	end -- 702
	local ts = os.date("%Y-%m-%d %H:%M") -- 705
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 706
end -- 690
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error, formatFunc) -- 717
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 722
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 722
		self:rawArchive(chunk, formatFunc) -- 726
		self.consecutiveFailures = 0 -- 727
		return { -- 729
			success = true, -- 730
			memoryUpdate = self.storage:readMemory(), -- 731
			historyEntry = "[RAW ARCHIVE] See HISTORY.md for details", -- 732
			compressedCount = #chunk -- 733
		} -- 733
	end -- 733
	return { -- 737
		success = false, -- 738
		memoryUpdate = self.storage:readMemory(), -- 739
		historyEntry = "", -- 740
		compressedCount = 0, -- 741
		error = ____error -- 742
	} -- 742
end -- 717
function MemoryCompressor.prototype.rawArchive(self, chunk, formatFunc) -- 749
	local ts = os.date("%Y-%m-%d %H:%M") -- 750
	local text = formatFunc(chunk) -- 751
	self.storage:appendHistory((((("[" .. ts) .. "] [RAW ARCHIVE] ") .. tostring(#chunk)) .. " actions (compression failed)\n") .. ("---\n" .. text) .. "\n---")
end -- 749
function MemoryCompressor.prototype.getStorage(self) -- 762
	return self.storage -- 763
end -- 762
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 766
	return math.max( -- 767
		1, -- 767
		math.floor(self.config.maxCompressionRounds) -- 767
	) -- 767
end -- 766
MemoryCompressor.MAX_FAILURES = 3 -- 766
return ____exports -- 766