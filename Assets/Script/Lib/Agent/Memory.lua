-- [ts]: Memory.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
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
local ____Tools = require("Agent.Tools") -- 5
local sendWebIDEFileUpdate = ____Tools.sendWebIDEFileUpdate -- 5
local yaml = require("yaml") -- 6
____exports.DEFAULT_AGENT_PROMPT = "You are a coding assistant that helps modify and navigate code." -- 10
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 60
local TokenEstimator = ____exports.TokenEstimator -- 60
TokenEstimator.name = "TokenEstimator" -- 60
function TokenEstimator.prototype.____constructor(self) -- 60
end -- 60
function TokenEstimator.estimate(self, text) -- 70
	if not text then -- 70
		return 0 -- 71
	end -- 71
	local chineseChars = utf8.len(text) -- 74
	if not chineseChars then -- 74
		return 0 -- 75
	end -- 75
	local otherChars = #text - chineseChars -- 77
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 79
	return math.max(1, tokens) -- 84
end -- 70
function TokenEstimator.estimateHistory(self, history, formatFunc) -- 90
	if not history or #history == 0 then -- 90
		return 0 -- 91
	end -- 91
	local text = formatFunc(history) -- 92
	return self:estimate(text) -- 93
end -- 90
function TokenEstimator.estimatePrompt(self, userQuery, history, systemPrompt, toolDefinitions, formatFunc) -- 99
	return self:estimate(userQuery) + self:estimateHistory(history, formatFunc) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 106
end -- 99
TokenEstimator.CHARS_PER_TOKEN = 4 -- 99
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 99
local function utf8TakeHead(text, maxChars) -- 115
	if maxChars <= 0 or text == "" then -- 115
		return "" -- 116
	end -- 116
	local nextPos = utf8.offset(text, maxChars + 1) -- 117
	if nextPos == nil then -- 117
		return text -- 118
	end -- 118
	return string.sub(text, 1, nextPos - 1) -- 119
end -- 115
local function utf8TakeTail(text, maxChars) -- 122
	if maxChars <= 0 or text == "" then -- 122
		return "" -- 123
	end -- 123
	local charLen = utf8.len(text) -- 124
	if charLen == false or charLen <= maxChars then -- 124
		return text -- 125
	end -- 125
	local startChar = math.max(1, charLen - maxChars + 1) -- 126
	local startPos = utf8.offset(text, startChar) -- 127
	if startPos == nil then -- 127
		return text -- 128
	end -- 128
	return string.sub(text, startPos) -- 129
end -- 122
--- 双层存储管理器
-- 
-- 管理 AGENT.md、MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 137
local DualLayerStorage = ____exports.DualLayerStorage -- 137
DualLayerStorage.name = "DualLayerStorage" -- 137
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 145
	self.projectDir = projectDir -- 146
	self.agentDir = Path(self.projectDir, ".agent") -- 147
	self.agentPath = Path(self.agentDir, "AGENT.md") -- 148
	self.memoryPath = Path(self.agentDir, "MEMORY.md") -- 149
	self.historyPath = Path(self.agentDir, "HISTORY.md") -- 150
	self.sessionPath = Path(self.agentDir, "SESSION.jsonl") -- 151
	self:ensureAgentFiles() -- 152
end -- 145
function DualLayerStorage.prototype.ensureDir(self, dir) -- 155
	if not Content:exist(dir) then -- 155
		Content:mkdir(dir) -- 157
	end -- 157
end -- 155
function DualLayerStorage.prototype.ensureFile(self, path, content) -- 161
	if Content:exist(path) then -- 161
		return false -- 162
	end -- 162
	self:ensureDir(Path:getPath(path)) -- 163
	if not Content:save(path, content) then -- 163
		return false -- 165
	end -- 165
	sendWebIDEFileUpdate(path, true, content) -- 167
	return true -- 168
end -- 161
function DualLayerStorage.prototype.ensureAgentFiles(self) -- 171
	self:ensureDir(self.agentDir) -- 172
	self:ensureFile(self.agentPath, ____exports.DEFAULT_AGENT_PROMPT .. "\n") -- 173
	self:ensureFile(self.memoryPath, "") -- 174
	self:ensureFile(self.historyPath, "") -- 175
end -- 171
function DualLayerStorage.prototype.encodeJsonLine(self, value) -- 178
	local text = json.encode(value) -- 179
	return text -- 180
end -- 178
function DualLayerStorage.prototype.decodeJsonLine(self, text) -- 183
	local value = json.decode(text) -- 184
	return value -- 185
end -- 183
function DualLayerStorage.prototype.decodeActionRecord(self, value) -- 188
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 188
		return nil -- 189
	end -- 189
	local row = value -- 190
	local tool = type(row.tool) == "string" and row.tool or "" -- 191
	local reason = type(row.reason) == "string" and row.reason or "" -- 192
	local timestamp = type(row.timestamp) == "string" and row.timestamp or "" -- 193
	if tool == "" or timestamp == "" then -- 193
		return nil -- 194
	end -- 194
	local params = row.params and not __TS__ArrayIsArray(row.params) and type(row.params) == "table" and row.params or ({}) -- 195
	local result = row.result and not __TS__ArrayIsArray(row.result) and type(row.result) == "table" and row.result or nil -- 198
	local ____math_max_2 = math.max -- 202
	local ____math_floor_1 = math.floor -- 202
	local ____row_step_0 = row.step -- 202
	if ____row_step_0 == nil then -- 202
		____row_step_0 = 1 -- 202
	end -- 202
	return { -- 201
		step = ____math_max_2( -- 202
			1, -- 202
			____math_floor_1(__TS__Number(____row_step_0)) -- 202
		), -- 202
		tool = tool, -- 203
		reason = reason, -- 204
		params = params, -- 205
		result = result, -- 206
		timestamp = timestamp -- 207
	} -- 207
end -- 188
function DualLayerStorage.prototype.readAgentPrompt(self) -- 211
	if not Content:exist(self.agentPath) then -- 211
		return ____exports.DEFAULT_AGENT_PROMPT -- 213
	end -- 213
	local prompt = Content:load(self.agentPath) -- 215
	return __TS__StringTrim(prompt) == "" and ____exports.DEFAULT_AGENT_PROMPT or prompt -- 216
end -- 211
function DualLayerStorage.prototype.readMemory(self) -- 224
	if not Content:exist(self.memoryPath) then -- 224
		return "" -- 226
	end -- 226
	return Content:load(self.memoryPath) -- 228
end -- 224
function DualLayerStorage.prototype.writeMemory(self, content) -- 234
	self:ensureDir(Path:getPath(self.memoryPath)) -- 235
	Content:save(self.memoryPath, content) -- 236
end -- 234
function DualLayerStorage.prototype.getMemoryContext(self) -- 242
	local memory = self:readMemory() -- 243
	if not memory then -- 243
		return "" -- 244
	end -- 244
	return "## Long-term Memory\n\n" .. memory -- 246
end -- 242
function DualLayerStorage.prototype.appendHistory(self, entry) -- 256
	self:ensureDir(Path:getPath(self.historyPath)) -- 257
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 259
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 263
end -- 256
function DualLayerStorage.prototype.readHistory(self) -- 269
	if not Content:exist(self.historyPath) then -- 269
		return "" -- 271
	end -- 271
	return Content:load(self.historyPath) -- 273
end -- 269
function DualLayerStorage.prototype.readSessionState(self) -- 276
	if not Content:exist(self.sessionPath) then -- 276
		return {history = {}, lastConsolidatedIndex = 0} -- 278
	end -- 278
	local text = Content:load(self.sessionPath) -- 280
	if not text or __TS__StringTrim(text) == "" then -- 280
		return {history = {}, lastConsolidatedIndex = 0} -- 282
	end -- 282
	local lines = __TS__StringSplit(text, "\n") -- 284
	local history = {} -- 285
	local lastConsolidatedIndex = 0 -- 286
	do -- 286
		local i = 0 -- 287
		while i < #lines do -- 287
			do -- 287
				local line = __TS__StringTrim(lines[i + 1]) -- 288
				if line == "" then -- 288
					goto __continue42 -- 289
				end -- 289
				local data = self:decodeJsonLine(line) -- 290
				if not data or __TS__ArrayIsArray(data) or type(data) ~= "table" then -- 290
					goto __continue42 -- 291
				end -- 291
				local row = data -- 292
				if row._type == "metadata" then -- 292
					local ____math_max_5 = math.max -- 294
					local ____math_floor_4 = math.floor -- 294
					local ____row_lastConsolidatedIndex_3 = row.lastConsolidatedIndex -- 294
					if ____row_lastConsolidatedIndex_3 == nil then -- 294
						____row_lastConsolidatedIndex_3 = 0 -- 294
					end -- 294
					lastConsolidatedIndex = ____math_max_5( -- 294
						0, -- 294
						____math_floor_4(__TS__Number(____row_lastConsolidatedIndex_3)) -- 294
					) -- 294
					goto __continue42 -- 295
				end -- 295
				local record = self:decodeActionRecord(row) -- 297
				if record then -- 297
					history[#history + 1] = record -- 299
				end -- 299
			end -- 299
			::__continue42:: -- 299
			i = i + 1 -- 287
		end -- 287
	end -- 287
	return { -- 302
		history = history, -- 303
		lastConsolidatedIndex = math.min(lastConsolidatedIndex, #history) -- 304
	} -- 304
end -- 276
function DualLayerStorage.prototype.writeSessionState(self, history, lastConsolidatedIndex) -- 308
	self:ensureDir(Path:getPath(self.sessionPath)) -- 309
	local lines = {} -- 310
	local meta = self:encodeJsonLine({ -- 311
		_type = "metadata", -- 312
		lastConsolidatedIndex = math.min( -- 313
			math.max( -- 313
				0, -- 313
				math.floor(lastConsolidatedIndex) -- 313
			), -- 313
			#history -- 313
		) -- 313
	}) -- 313
	if meta then -- 313
		lines[#lines + 1] = meta -- 316
	end -- 316
	do -- 316
		local i = 0 -- 318
		while i < #history do -- 318
			local line = self:encodeJsonLine(history[i + 1]) -- 319
			if line then -- 319
				lines[#lines + 1] = line -- 321
			end -- 321
			i = i + 1 -- 318
		end -- 318
	end -- 318
	local content = table.concat(lines, "\n") .. "\n" -- 324
	Content:save(self.sessionPath, content) -- 325
	sendWebIDEFileUpdate(self.sessionPath, true, content) -- 326
end -- 308
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 332
	local history = self:readHistory() -- 333
	if not history then -- 333
		return {} -- 334
	end -- 334
	local lines = __TS__StringSplit(history, "\n") -- 336
	local lowerKeyword = string.lower(keyword) -- 337
	return __TS__ArrayFilter( -- 339
		lines, -- 339
		function(____, line) return __TS__StringIncludes( -- 339
			string.lower(line), -- 340
			lowerKeyword -- 340
		) end -- 340
	) -- 340
end -- 332
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 353
local MemoryCompressor = ____exports.MemoryCompressor -- 353
MemoryCompressor.name = "MemoryCompressor" -- 353
function MemoryCompressor.prototype.____constructor(self, config) -- 360
	self.consecutiveFailures = 0 -- 356
	self.config = config -- 361
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 362
end -- 360
function MemoryCompressor.prototype.shouldCompress(self, userQuery, history, lastConsolidatedIndex, systemPrompt, toolDefinitions, formatFunc) -- 368
	local uncompressedHistory = __TS__ArraySlice(history, lastConsolidatedIndex) -- 376
	local tokens = ____exports.TokenEstimator:estimatePrompt( -- 378
		userQuery, -- 379
		uncompressedHistory, -- 380
		systemPrompt, -- 381
		toolDefinitions, -- 382
		formatFunc -- 383
	) -- 383
	local threshold = self:getContextWindow() * self.config.compressionThreshold -- 386
	return tokens > threshold -- 388
end -- 368
function MemoryCompressor.prototype.compress(self, history, lastConsolidatedIndex, llmOptions, formatFunc, maxLLMTry, decisionMode) -- 394
	if decisionMode == nil then -- 394
		decisionMode = "tool_calling" -- 400
	end -- 400
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 400
		local toCompress = __TS__ArraySlice(history, lastConsolidatedIndex) -- 402
		if #toCompress == 0 then -- 402
			return ____awaiter_resolve(nil, nil) -- 402
		end -- 402
		local boundary = self:findCompressionBoundary(toCompress, formatFunc) -- 406
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 407
		if #chunk == 0 then -- 407
			return ____awaiter_resolve(nil, nil) -- 407
		end -- 407
		local currentMemory = self.storage:readMemory() -- 411
		local historyText = formatFunc(chunk) -- 412
		local ____try = __TS__AsyncAwaiter(function() -- 412
			local result = __TS__Await(self:callLLMForCompression( -- 416
				currentMemory, -- 417
				historyText, -- 418
				llmOptions, -- 419
				maxLLMTry or 3, -- 420
				decisionMode -- 421
			)) -- 421
			if result.success then -- 421
				self.storage:writeMemory(result.memoryUpdate) -- 426
				self.storage:appendHistory(result.historyEntry) -- 427
				self.consecutiveFailures = 0 -- 428
				return ____awaiter_resolve( -- 428
					nil, -- 428
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 430
				) -- 430
			end -- 430
			return ____awaiter_resolve( -- 430
				nil, -- 430
				self:handleCompressionFailure(chunk, result.error or "Unknown error", formatFunc) -- 437
			) -- 437
		end) -- 437
		__TS__Await(____try.catch( -- 414
			____try, -- 414
			function(____, ____error) -- 414
				return ____awaiter_resolve( -- 414
					nil, -- 414
					self:handleCompressionFailure( -- 441
						chunk, -- 442
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error", -- 443
						formatFunc -- 444
					) -- 444
				) -- 444
			end -- 444
		)) -- 444
	end) -- 444
end -- 394
function MemoryCompressor.prototype.findCompressionBoundary(self, history, formatFunc) -- 454
	local targetTokens = self.config.maxTokensPerCompression -- 458
	local accumulatedTokens = 0 -- 459
	do -- 459
		local i = 0 -- 461
		while i < #history do -- 461
			local record = history[i + 1] -- 462
			local tokens = ____exports.TokenEstimator:estimate(formatFunc({record})) -- 463
			accumulatedTokens = accumulatedTokens + tokens -- 467
			if accumulatedTokens > targetTokens then -- 467
				return math.max(1, i) -- 471
			end -- 471
			i = i + 1 -- 461
		end -- 461
	end -- 461
	return #history -- 475
end -- 454
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 481
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 481
		local boundedHistoryText = self:boundCompressionHistoryText(currentMemory, historyText) -- 488
		if decisionMode == "yaml" then -- 488
			return ____awaiter_resolve( -- 488
				nil, -- 488
				self:callLLMForCompressionByYAML(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 490
			) -- 490
		end -- 490
		return ____awaiter_resolve( -- 490
			nil, -- 490
			self:callLLMForCompressionByToolCalling(currentMemory, boundedHistoryText, llmOptions, maxLLMTry) -- 497
		) -- 497
	end) -- 497
end -- 481
function MemoryCompressor.prototype.getContextWindow(self) -- 505
	return math.max(4000, self.config.llmConfig.contextWindow) -- 506
end -- 505
function MemoryCompressor.prototype.getCompressionHistoryTokenBudget(self, currentMemory) -- 509
	local contextWindow = self:getContextWindow() -- 510
	local reservedOutputTokens = math.max( -- 511
		2048, -- 511
		math.floor(contextWindow * 0.2) -- 511
	) -- 511
	local staticPromptTokens = ____exports.TokenEstimator:estimate(self:buildCompressionPromptBody("", "")) -- 512
	local memoryTokens = ____exports.TokenEstimator:estimate(currentMemory) -- 513
	local available = contextWindow - reservedOutputTokens - staticPromptTokens - memoryTokens -- 514
	return math.max( -- 515
		1200, -- 515
		math.floor(available * 0.9) -- 515
	) -- 515
end -- 509
function MemoryCompressor.prototype.boundCompressionHistoryText(self, currentMemory, historyText) -- 518
	local historyTokens = ____exports.TokenEstimator:estimate(historyText) -- 519
	local tokenBudget = self:getCompressionHistoryTokenBudget(currentMemory) -- 520
	if historyTokens <= tokenBudget then -- 520
		return historyText -- 521
	end -- 521
	local charsPerToken = historyTokens > 0 and #historyText / historyTokens or 4 -- 522
	local targetChars = math.max( -- 525
		2000, -- 525
		math.floor(tokenBudget * charsPerToken) -- 525
	) -- 525
	local keepHead = math.max( -- 526
		0, -- 526
		math.floor(targetChars * 0.35) -- 526
	) -- 526
	local keepTail = math.max(0, targetChars - keepHead) -- 527
	local head = keepHead > 0 and utf8TakeHead(historyText, keepHead) or "" -- 528
	local tail = keepTail > 0 and utf8TakeTail(historyText, keepTail) or "" -- 529
	return (((((("[compression history truncated to fit context window; token_budget=" .. tostring(tokenBudget)) .. ", original_tokens=") .. tostring(historyTokens)) .. "]\n") .. head) .. "\n...\n") .. tail -- 530
end -- 518
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 533
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 533
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 539
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 542
		local messages = {{role = "system", content = "You are a memory consolidation agent. You MUST call the save_memory tool."}, {role = "user", content = prompt}} -- 566
		local fn -- 577
		local argsText = "" -- 578
		do -- 578
			local i = 0 -- 579
			while i < maxLLMTry do -- 579
				local response = __TS__Await(callLLM( -- 581
					messages, -- 582
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}), -- 583
					nil, -- 588
					self.config.llmConfig -- 589
				)) -- 589
				if not response.success then -- 589
					return ____awaiter_resolve(nil, { -- 589
						success = false, -- 594
						memoryUpdate = currentMemory, -- 595
						historyEntry = "", -- 596
						compressedCount = 0, -- 597
						error = response.message -- 598
					}) -- 598
				end -- 598
				local choice = response.response.choices and response.response.choices[1] -- 602
				local message = choice and choice.message -- 603
				local toolCalls = message and message.tool_calls -- 604
				local toolCall = toolCalls and toolCalls[1] -- 605
				fn = toolCall and toolCall["function"] -- 606
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 607
				if fn ~= nil and #argsText > 0 then -- 607
					break -- 608
				end -- 608
				i = i + 1 -- 579
			end -- 579
		end -- 579
		if not fn or fn.name ~= "save_memory" then -- 579
			return ____awaiter_resolve(nil, { -- 579
				success = false, -- 613
				memoryUpdate = currentMemory, -- 614
				historyEntry = "", -- 615
				compressedCount = 0, -- 616
				error = "missing save_memory tool call" -- 617
			}) -- 617
		end -- 617
		if __TS__StringTrim(argsText) == "" then -- 617
			return ____awaiter_resolve(nil, { -- 617
				success = false, -- 623
				memoryUpdate = currentMemory, -- 624
				historyEntry = "", -- 625
				compressedCount = 0, -- 626
				error = "empty save_memory tool arguments" -- 627
			}) -- 627
		end -- 627
		local ____try = __TS__AsyncAwaiter(function() -- 627
			local args, err = json.decode(argsText) -- 633
			if err ~= nil or not args or type(args) ~= "table" then -- 633
				return ____awaiter_resolve( -- 633
					nil, -- 633
					{ -- 635
						success = false, -- 636
						memoryUpdate = currentMemory, -- 637
						historyEntry = "", -- 638
						compressedCount = 0, -- 639
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 640
					} -- 640
				) -- 640
			end -- 640
			return ____awaiter_resolve( -- 640
				nil, -- 640
				self:buildCompressionResultFromObject(args, currentMemory) -- 644
			) -- 644
		end) -- 644
		__TS__Await(____try.catch( -- 632
			____try, -- 632
			function(____, ____error) -- 632
				return ____awaiter_resolve( -- 632
					nil, -- 632
					{ -- 649
						success = false, -- 650
						memoryUpdate = currentMemory, -- 651
						historyEntry = "", -- 652
						compressedCount = 0, -- 653
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 654
					} -- 654
				) -- 654
			end -- 654
		)) -- 654
	end) -- 654
end -- 533
function MemoryCompressor.prototype.callLLMForCompressionByYAML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 659
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 659
		local prompt = self:buildYAMLCompressionPrompt(currentMemory, historyText) -- 665
		local lastError = "invalid yaml response" -- 666
		do -- 666
			local i = 0 -- 668
			while i < maxLLMTry do -- 668
				do -- 668
					local feedback = i > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only." or "" -- 669
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions, nil, self.config.llmConfig)) -- 672
					if not response.success then -- 672
						return ____awaiter_resolve(nil, { -- 672
							success = false, -- 681
							memoryUpdate = currentMemory, -- 682
							historyEntry = "", -- 683
							compressedCount = 0, -- 684
							error = response.message -- 685
						}) -- 685
					end -- 685
					local choice = response.response.choices and response.response.choices[1] -- 689
					local message = choice and choice.message -- 690
					local text = message and type(message.content) == "string" and message.content or "" -- 691
					if __TS__StringTrim(text) == "" then -- 691
						lastError = "empty yaml response" -- 693
						goto __continue85 -- 694
					end -- 694
					local parsed = self:parseCompressionYAMLObject(text, currentMemory) -- 697
					if parsed.success then -- 697
						return ____awaiter_resolve(nil, parsed) -- 697
					end -- 697
					lastError = parsed.error or "invalid yaml response" -- 701
				end -- 701
				::__continue85:: -- 701
				i = i + 1 -- 668
			end -- 668
		end -- 668
		return ____awaiter_resolve(nil, { -- 668
			success = false, -- 705
			memoryUpdate = currentMemory, -- 706
			historyEntry = "", -- 707
			compressedCount = 0, -- 708
			error = lastError -- 709
		}) -- 709
	end) -- 709
end -- 659
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 716
	return ((("Process this conversation and consolidate it.\n\n## Current Long-term Memory\n" .. (currentMemory or "(empty)")) .. "\n\n## Recent Actions to Process\n") .. historyText) .. "\n\n## Instructions\n\n1. **Analyze the conversation**:\n\t- What was the user trying to accomplish?\n\t- What tools were used and what were the results?\n\t- Were there any problems or solutions?\n\t- What decisions were made?\n\n2. **Update the long-term memory**:\n\t- Preserve all existing facts\n\t- Add new important information (user preferences, project context, decisions)\n\t- Remove outdated or redundant information\n\t- Keep the memory concise but complete\n\n3. **Create a history entry**:\n\t- Summarize key events, decisions, and outcomes\n\t- Include details useful for grep search\n\t- Format as a single paragraph\n" -- 717
end -- 716
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 746
	return self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n## Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content" -- 747
end -- 746
function MemoryCompressor.prototype.buildYAMLCompressionPrompt(self, currentMemory, historyText) -- 756
	return self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n## Output Format\n\nReturn exactly one YAML object:\n```yaml\nhistory_entry: \"Summary paragraph\"\nmemory_update: |-\n\tFull updated MEMORY.md content\n```\n\nRules:\n- Return YAML only, no prose before or after.\n- Use exactly two keys: history_entry, memory_update.\n- Use a block scalar for memory_update when it spans multiple lines." -- 757
end -- 756
function MemoryCompressor.prototype.extractYAMLFromText(self, text) -- 774
	local source = __TS__StringTrim(text) -- 775
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 776
	if yamlFencePos >= 0 then -- 776
		local from = yamlFencePos + #"```yaml" -- 778
		local ____end = (string.find( -- 779
			source, -- 779
			"```", -- 779
			math.max(from + 1, 1), -- 779
			true -- 779
		) or 0) - 1 -- 779
		if ____end > from then -- 779
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 780
		end -- 780
	end -- 780
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 782
	if ymlFencePos >= 0 then -- 782
		local from = ymlFencePos + #"```yml" -- 784
		local ____end = (string.find( -- 785
			source, -- 785
			"```", -- 785
			math.max(from + 1, 1), -- 785
			true -- 785
		) or 0) - 1 -- 785
		if ____end > from then -- 785
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 786
		end -- 786
	end -- 786
	return source -- 788
end -- 774
function MemoryCompressor.prototype.parseCompressionYAMLObject(self, text, currentMemory) -- 791
	local yamlText = self:extractYAMLFromText(text) -- 792
	local obj, err = yaml.parse(yamlText) -- 793
	if not obj or type(obj) ~= "table" then -- 793
		return { -- 795
			success = false, -- 796
			memoryUpdate = currentMemory, -- 797
			historyEntry = "", -- 798
			compressedCount = 0, -- 799
			error = "invalid yaml: " .. tostring(err) -- 800
		} -- 800
	end -- 800
	return self:buildCompressionResultFromObject(obj, currentMemory) -- 803
end -- 791
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 809
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 813
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 814
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 814
		return { -- 816
			success = false, -- 817
			memoryUpdate = currentMemory, -- 818
			historyEntry = "", -- 819
			compressedCount = 0, -- 820
			error = "missing history_entry or memory_update" -- 821
		} -- 821
	end -- 821
	local ts = os.date("%Y-%m-%d %H:%M") -- 824
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 825
end -- 809
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error, formatFunc) -- 836
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 841
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 841
		self:rawArchive(chunk, formatFunc) -- 845
		self.consecutiveFailures = 0 -- 846
		return { -- 848
			success = true, -- 849
			memoryUpdate = self.storage:readMemory(), -- 850
			historyEntry = "[RAW ARCHIVE] See HISTORY.md for details", -- 851
			compressedCount = #chunk -- 852
		} -- 852
	end -- 852
	return { -- 856
		success = false, -- 857
		memoryUpdate = self.storage:readMemory(), -- 858
		historyEntry = "", -- 859
		compressedCount = 0, -- 860
		error = ____error -- 861
	} -- 861
end -- 836
function MemoryCompressor.prototype.rawArchive(self, chunk, formatFunc) -- 868
	local ts = os.date("%Y-%m-%d %H:%M") -- 869
	local text = formatFunc(chunk) -- 870
	self.storage:appendHistory((((("[" .. ts) .. "] [RAW ARCHIVE] ") .. tostring(#chunk)) .. " actions (compression failed)\n") .. ("---\n" .. text) .. "\n---")
end -- 868
function MemoryCompressor.prototype.getStorage(self) -- 881
	return self.storage -- 882
end -- 881
function MemoryCompressor.prototype.getMaxCompressionRounds(self) -- 885
	return math.max( -- 886
		1, -- 886
		math.floor(self.config.maxCompressionRounds) -- 886
	) -- 886
end -- 885
MemoryCompressor.MAX_FAILURES = 3 -- 885
return ____exports -- 885