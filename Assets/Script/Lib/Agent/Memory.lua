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
local AGENT_DIR = Path(Content.appPath, ".agent") -- 8
--- Token 估算器
-- 
-- 提供简单高效的 token 估算功能。
-- 估算精度足够用于压缩触发判断。
____exports.TokenEstimator = __TS__Class() -- 58
local TokenEstimator = ____exports.TokenEstimator -- 58
TokenEstimator.name = "TokenEstimator" -- 58
function TokenEstimator.prototype.____constructor(self) -- 58
end -- 58
function TokenEstimator.estimate(self, text) -- 68
	if not text then -- 68
		return 0 -- 69
	end -- 69
	local chineseChars = utf8.len(text) -- 72
	if not chineseChars then -- 72
		return 0 -- 73
	end -- 73
	local otherChars = #text - chineseChars -- 75
	local tokens = math.ceil(chineseChars / self.CHINESE_CHARS_PER_TOKEN + otherChars / self.CHARS_PER_TOKEN) -- 77
	return math.max(1, tokens) -- 82
end -- 68
function TokenEstimator.estimateHistory(self, history, formatFunc) -- 88
	if not history or #history == 0 then -- 88
		return 0 -- 89
	end -- 89
	local text = formatFunc(history) -- 90
	return self:estimate(text) -- 91
end -- 88
function TokenEstimator.estimatePrompt(self, userQuery, history, systemPrompt, toolDefinitions, formatFunc) -- 97
	return self:estimate(userQuery) + self:estimateHistory(history, formatFunc) + self:estimate(systemPrompt) + self:estimate(toolDefinitions) -- 104
end -- 97
TokenEstimator.CHARS_PER_TOKEN = 4 -- 97
TokenEstimator.CHINESE_CHARS_PER_TOKEN = 1.5 -- 97
--- 双层存储管理器
-- 
-- 管理 MEMORY.md (长期记忆) 和 HISTORY.md (历史日志)
____exports.DualLayerStorage = __TS__Class() -- 118
local DualLayerStorage = ____exports.DualLayerStorage -- 118
DualLayerStorage.name = "DualLayerStorage" -- 118
function DualLayerStorage.prototype.____constructor(self, projectDir) -- 123
	self.projectDir = projectDir -- 124
	self.memoryPath = Path(self.projectDir, "MEMORY.md") -- 125
	self.historyPath = Path(AGENT_DIR, "HISTORY.md") -- 126
	self:ensureDir(AGENT_DIR) -- 129
end -- 123
function DualLayerStorage.prototype.ensureDir(self, dir) -- 132
	if not Content:exist(dir) then -- 132
		Content:mkdir(dir) -- 134
	end -- 134
end -- 132
function DualLayerStorage.prototype.readMemory(self) -- 143
	if not Content:exist(self.memoryPath) then -- 143
		return "" -- 145
	end -- 145
	return Content:load(self.memoryPath) -- 147
end -- 143
function DualLayerStorage.prototype.writeMemory(self, content) -- 153
	self:ensureDir(Path:getPath(self.memoryPath)) -- 154
	Content:save(self.memoryPath, content) -- 155
end -- 153
function DualLayerStorage.prototype.getMemoryContext(self) -- 161
	local memory = self:readMemory() -- 162
	if not memory then -- 162
		return "" -- 163
	end -- 163
	return "## Long-term Memory\n\n" .. memory -- 165
end -- 161
function DualLayerStorage.prototype.appendHistory(self, entry) -- 175
	self:ensureDir(Path:getPath(self.historyPath)) -- 176
	local existing = Content:exist(self.historyPath) and Content:load(self.historyPath) or "" -- 178
	Content:save(self.historyPath, (existing .. entry) .. "\n\n") -- 182
end -- 175
function DualLayerStorage.prototype.readHistory(self) -- 188
	if not Content:exist(self.historyPath) then -- 188
		return "" -- 190
	end -- 190
	return Content:load(self.historyPath) -- 192
end -- 188
function DualLayerStorage.prototype.searchHistory(self, keyword) -- 198
	local history = self:readHistory() -- 199
	if not history then -- 199
		return {} -- 200
	end -- 200
	local lines = __TS__StringSplit(history, "\n") -- 202
	local lowerKeyword = string.lower(keyword) -- 203
	return __TS__ArrayFilter( -- 205
		lines, -- 205
		function(____, line) return __TS__StringIncludes( -- 205
			string.lower(line), -- 206
			lowerKeyword -- 206
		) end -- 206
	) -- 206
end -- 198
--- Memory 压缩器
-- 
-- 负责：
-- 1. 判断是否需要压缩
-- 2. 执行 LLM 压缩
-- 3. 更新存储
____exports.MemoryCompressor = __TS__Class() -- 219
local MemoryCompressor = ____exports.MemoryCompressor -- 219
MemoryCompressor.name = "MemoryCompressor" -- 219
function MemoryCompressor.prototype.____constructor(self, config) -- 226
	self.consecutiveFailures = 0 -- 222
	self.config = __TS__ObjectAssign({ -- 227
		contextWindow = 32000, -- 228
		compressionThreshold = 0.8, -- 229
		maxCompressionRounds = 3, -- 230
		maxTokensPerCompression = 20000, -- 231
		projectDir = AGENT_DIR -- 232
	}, config) -- 232
	self.storage = __TS__New(____exports.DualLayerStorage, self.config.projectDir) -- 235
end -- 226
function MemoryCompressor.prototype.shouldCompress(self, userQuery, history, lastConsolidatedIndex, systemPrompt, toolDefinitions, formatFunc) -- 241
	local uncompressedHistory = __TS__ArraySlice(history, lastConsolidatedIndex) -- 249
	local tokens = ____exports.TokenEstimator:estimatePrompt( -- 251
		userQuery, -- 252
		uncompressedHistory, -- 253
		systemPrompt, -- 254
		toolDefinitions, -- 255
		formatFunc -- 256
	) -- 256
	local threshold = self.config.contextWindow * self.config.compressionThreshold -- 259
	return tokens > threshold -- 261
end -- 241
function MemoryCompressor.prototype.compress(self, history, lastConsolidatedIndex, llmOptions, formatFunc, maxLLMTry, decisionMode) -- 267
	if decisionMode == nil then -- 267
		decisionMode = "tool_calling" -- 273
	end -- 273
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 273
		local toCompress = __TS__ArraySlice(history, lastConsolidatedIndex) -- 275
		if #toCompress == 0 then -- 275
			return ____awaiter_resolve(nil, nil) -- 275
		end -- 275
		local boundary = self:findCompressionBoundary(toCompress, formatFunc) -- 279
		local chunk = __TS__ArraySlice(toCompress, 0, boundary) -- 280
		if #chunk == 0 then -- 280
			return ____awaiter_resolve(nil, nil) -- 280
		end -- 280
		local currentMemory = self.storage:readMemory() -- 284
		local historyText = formatFunc(chunk) -- 285
		local ____try = __TS__AsyncAwaiter(function() -- 285
			local result = __TS__Await(self:callLLMForCompression( -- 289
				currentMemory, -- 290
				historyText, -- 291
				llmOptions, -- 292
				maxLLMTry or 3, -- 293
				decisionMode -- 294
			)) -- 294
			if result.success then -- 294
				self.storage:writeMemory(result.memoryUpdate) -- 299
				self.storage:appendHistory(result.historyEntry) -- 300
				self.consecutiveFailures = 0 -- 301
				return ____awaiter_resolve( -- 301
					nil, -- 301
					__TS__ObjectAssign({}, result, {compressedCount = #chunk}) -- 303
				) -- 303
			end -- 303
			return ____awaiter_resolve( -- 303
				nil, -- 303
				self:handleCompressionFailure(chunk, result.error or "Unknown error", formatFunc) -- 310
			) -- 310
		end) -- 310
		__TS__Await(____try.catch( -- 287
			____try, -- 287
			function(____, ____error) -- 287
				return ____awaiter_resolve( -- 287
					nil, -- 287
					self:handleCompressionFailure( -- 314
						chunk, -- 315
						__TS__InstanceOf(____error, Error) and ____error.message or "Unknown error", -- 316
						formatFunc -- 317
					) -- 317
				) -- 317
			end -- 317
		)) -- 317
	end) -- 317
end -- 267
function MemoryCompressor.prototype.findCompressionBoundary(self, history, formatFunc) -- 327
	local targetTokens = self.config.maxTokensPerCompression -- 331
	local accumulatedTokens = 0 -- 332
	do -- 332
		local i = 0 -- 334
		while i < #history do -- 334
			local record = history[i + 1] -- 335
			local tokens = ____exports.TokenEstimator:estimate(formatFunc({record})) -- 336
			accumulatedTokens = accumulatedTokens + tokens -- 340
			if accumulatedTokens > targetTokens then -- 340
				return math.max(1, i) -- 344
			end -- 344
			i = i + 1 -- 334
		end -- 334
	end -- 334
	return #history -- 348
end -- 327
function MemoryCompressor.prototype.callLLMForCompression(self, currentMemory, historyText, llmOptions, maxLLMTry, decisionMode) -- 354
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 354
		if decisionMode == "yaml" then -- 354
			return ____awaiter_resolve( -- 354
				nil, -- 354
				self:callLLMForCompressionByYAML(currentMemory, historyText, llmOptions, maxLLMTry) -- 362
			) -- 362
		end -- 362
		return ____awaiter_resolve( -- 362
			nil, -- 362
			self:callLLMForCompressionByToolCalling(currentMemory, historyText, llmOptions, maxLLMTry) -- 369
		) -- 369
	end) -- 369
end -- 354
function MemoryCompressor.prototype.callLLMForCompressionByToolCalling(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 377
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 377
		local prompt = self:buildToolCallingCompressionPrompt(currentMemory, historyText) -- 383
		local tools = {{type = "function", ["function"] = {name = "save_memory", description = "Save the memory consolidation result to persistent storage.", parameters = {type = "object", properties = {history_entry = {type = "string", description = "A paragraph summarizing key events/decisions/topics. " .. "Include detail useful for grep search."}, memory_update = {type = "string", description = "Full updated long-term memory as markdown. " .. "Include all existing facts plus new ones."}}, required = {"history_entry", "memory_update"}}}}} -- 386
		local messages = {{role = "system", content = "You are a memory consolidation agent. You MUST call the save_memory tool."}, {role = "user", content = prompt}} -- 410
		local fn -- 421
		local argsText = "" -- 422
		do -- 422
			local i = 0 -- 423
			while i < maxLLMTry do -- 423
				local response = __TS__Await(callLLM( -- 425
					messages, -- 426
					__TS__ObjectAssign({}, llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "save_memory"}}}) -- 427
				)) -- 427
				if not response.success then -- 427
					return ____awaiter_resolve(nil, { -- 427
						success = false, -- 436
						memoryUpdate = currentMemory, -- 437
						historyEntry = "", -- 438
						compressedCount = 0, -- 439
						error = response.message -- 440
					}) -- 440
				end -- 440
				local choice = response.response.choices and response.response.choices[1] -- 444
				local message = choice and choice.message -- 445
				local toolCalls = message and message.tool_calls -- 446
				local toolCall = toolCalls and toolCalls[1] -- 447
				fn = toolCall and toolCall["function"] -- 448
				argsText = fn and type(fn.arguments) == "string" and fn.arguments or "" -- 449
				if fn ~= nil and #argsText > 0 then -- 449
					break -- 450
				end -- 450
				i = i + 1 -- 423
			end -- 423
		end -- 423
		if not fn or fn.name ~= "save_memory" then -- 423
			return ____awaiter_resolve(nil, { -- 423
				success = false, -- 455
				memoryUpdate = currentMemory, -- 456
				historyEntry = "", -- 457
				compressedCount = 0, -- 458
				error = "missing save_memory tool call" -- 459
			}) -- 459
		end -- 459
		if __TS__StringTrim(argsText) == "" then -- 459
			return ____awaiter_resolve(nil, { -- 459
				success = false, -- 465
				memoryUpdate = currentMemory, -- 466
				historyEntry = "", -- 467
				compressedCount = 0, -- 468
				error = "empty save_memory tool arguments" -- 469
			}) -- 469
		end -- 469
		local ____try = __TS__AsyncAwaiter(function() -- 469
			local args, err = json.decode(argsText) -- 475
			if err ~= nil or not args or type(args) ~= "table" then -- 475
				return ____awaiter_resolve( -- 475
					nil, -- 475
					{ -- 477
						success = false, -- 478
						memoryUpdate = currentMemory, -- 479
						historyEntry = "", -- 480
						compressedCount = 0, -- 481
						error = "Failed to parse tool arguments JSON: " .. tostring(err) -- 482
					} -- 482
				) -- 482
			end -- 482
			return ____awaiter_resolve( -- 482
				nil, -- 482
				self:buildCompressionResultFromObject(args, currentMemory) -- 486
			) -- 486
		end) -- 486
		__TS__Await(____try.catch( -- 474
			____try, -- 474
			function(____, ____error) -- 474
				return ____awaiter_resolve( -- 474
					nil, -- 474
					{ -- 491
						success = false, -- 492
						memoryUpdate = currentMemory, -- 493
						historyEntry = "", -- 494
						compressedCount = 0, -- 495
						error = "Failed to process LLM response: " .. (__TS__InstanceOf(____error, Error) and ____error.message or tostring(____error)) -- 496
					} -- 496
				) -- 496
			end -- 496
		)) -- 496
	end) -- 496
end -- 377
function MemoryCompressor.prototype.callLLMForCompressionByYAML(self, currentMemory, historyText, llmOptions, maxLLMTry) -- 501
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 501
		local prompt = self:buildYAMLCompressionPrompt(currentMemory, historyText) -- 507
		local lastError = "invalid yaml response" -- 508
		do -- 508
			local i = 0 -- 510
			while i < maxLLMTry do -- 510
				do -- 510
					local feedback = i > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only." or "" -- 511
					local response = __TS__Await(callLLM({{role = "user", content = prompt .. feedback}}, llmOptions)) -- 514
					if not response.success then -- 514
						return ____awaiter_resolve(nil, { -- 514
							success = false, -- 521
							memoryUpdate = currentMemory, -- 522
							historyEntry = "", -- 523
							compressedCount = 0, -- 524
							error = response.message -- 525
						}) -- 525
					end -- 525
					local choice = response.response.choices and response.response.choices[1] -- 529
					local message = choice and choice.message -- 530
					local text = message and type(message.content) == "string" and message.content or "" -- 531
					if __TS__StringTrim(text) == "" then -- 531
						lastError = "empty yaml response" -- 533
						goto __continue49 -- 534
					end -- 534
					local parsed = self:parseCompressionYAMLObject(text, currentMemory) -- 537
					if parsed.success then -- 537
						return ____awaiter_resolve(nil, parsed) -- 537
					end -- 537
					lastError = parsed.error or "invalid yaml response" -- 541
				end -- 541
				::__continue49:: -- 541
				i = i + 1 -- 510
			end -- 510
		end -- 510
		return ____awaiter_resolve(nil, { -- 510
			success = false, -- 545
			memoryUpdate = currentMemory, -- 546
			historyEntry = "", -- 547
			compressedCount = 0, -- 548
			error = lastError -- 549
		}) -- 549
	end) -- 549
end -- 501
function MemoryCompressor.prototype.buildCompressionPromptBody(self, currentMemory, historyText) -- 556
	return ((("Process this conversation and consolidate it.\n\n## Current Long-term Memory\n" .. (currentMemory or "(empty)")) .. "\n\n## Recent Actions to Process\n") .. historyText) .. "\n\n## Instructions\n\n1. **Analyze the conversation**:\n\t- What was the user trying to accomplish?\n\t- What tools were used and what were the results?\n\t- Were there any problems or solutions?\n\t- What decisions were made?\n\n2. **Update the long-term memory**:\n\t- Preserve all existing facts\n\t- Add new important information (user preferences, project context, decisions)\n\t- Remove outdated or redundant information\n\t- Keep the memory concise but complete\n\n3. **Create a history entry**:\n\t- Summarize key events, decisions, and outcomes\n\t- Include details useful for grep search\n\t- Format as a single paragraph\n" -- 557
end -- 556
function MemoryCompressor.prototype.buildToolCallingCompressionPrompt(self, currentMemory, historyText) -- 586
	return self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n## Output Format\n\nCall the save_memory tool with:\n- history_entry: the summary paragraph without timestamp\n- memory_update: the full updated MEMORY.md content" -- 587
end -- 586
function MemoryCompressor.prototype.buildYAMLCompressionPrompt(self, currentMemory, historyText) -- 596
	return self:buildCompressionPromptBody(currentMemory, historyText) .. "\n\n## Output Format\n\nReturn exactly one YAML object:\n```yaml\nhistory_entry: \"Summary paragraph\"\nmemory_update: |-\n\tFull updated MEMORY.md content\n```\n\nRules:\n- Return YAML only, no prose before or after.\n- Use exactly two keys: history_entry, memory_update.\n- Use a block scalar for memory_update when it spans multiple lines." -- 597
end -- 596
function MemoryCompressor.prototype.extractYAMLFromText(self, text) -- 614
	local source = __TS__StringTrim(text) -- 615
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 616
	if yamlFencePos >= 0 then -- 616
		local from = yamlFencePos + #"```yaml" -- 618
		local ____end = (string.find( -- 619
			source, -- 619
			"```", -- 619
			math.max(from + 1, 1), -- 619
			true -- 619
		) or 0) - 1 -- 619
		if ____end > from then -- 619
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 620
		end -- 620
	end -- 620
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 622
	if ymlFencePos >= 0 then -- 622
		local from = ymlFencePos + #"```yml" -- 624
		local ____end = (string.find( -- 625
			source, -- 625
			"```", -- 625
			math.max(from + 1, 1), -- 625
			true -- 625
		) or 0) - 1 -- 625
		if ____end > from then -- 625
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 626
		end -- 626
	end -- 626
	return source -- 628
end -- 614
function MemoryCompressor.prototype.parseCompressionYAMLObject(self, text, currentMemory) -- 631
	local yamlText = self:extractYAMLFromText(text) -- 632
	local obj, err = yaml.parse(yamlText) -- 633
	if not obj or type(obj) ~= "table" then -- 633
		return { -- 635
			success = false, -- 636
			memoryUpdate = currentMemory, -- 637
			historyEntry = "", -- 638
			compressedCount = 0, -- 639
			error = "invalid yaml: " .. tostring(err) -- 640
		} -- 640
	end -- 640
	return self:buildCompressionResultFromObject(obj, currentMemory) -- 643
end -- 631
function MemoryCompressor.prototype.buildCompressionResultFromObject(self, obj, currentMemory) -- 649
	local historyEntry = type(obj.history_entry) == "string" and obj.history_entry or "" -- 653
	local memoryBody = type(obj.memory_update) == "string" and obj.memory_update or currentMemory -- 654
	if __TS__StringTrim(historyEntry) == "" or __TS__StringTrim(memoryBody) == "" then -- 654
		return { -- 656
			success = false, -- 657
			memoryUpdate = currentMemory, -- 658
			historyEntry = "", -- 659
			compressedCount = 0, -- 660
			error = "missing history_entry or memory_update" -- 661
		} -- 661
	end -- 661
	local ts = os.date("%Y-%m-%d %H:%M") -- 664
	return {success = true, memoryUpdate = memoryBody, historyEntry = (("[" .. ts) .. "] ") .. historyEntry, compressedCount = 0} -- 665
end -- 649
function MemoryCompressor.prototype.handleCompressionFailure(self, chunk, ____error, formatFunc) -- 676
	self.consecutiveFailures = self.consecutiveFailures + 1 -- 681
	if self.consecutiveFailures >= ____exports.MemoryCompressor.MAX_FAILURES then -- 681
		self:rawArchive(chunk, formatFunc) -- 685
		self.consecutiveFailures = 0 -- 686
		return { -- 688
			success = true, -- 689
			memoryUpdate = self.storage:readMemory(), -- 690
			historyEntry = "[RAW ARCHIVE] See HISTORY.md for details", -- 691
			compressedCount = #chunk -- 692
		} -- 692
	end -- 692
	return { -- 696
		success = false, -- 697
		memoryUpdate = self.storage:readMemory(), -- 698
		historyEntry = "", -- 699
		compressedCount = 0, -- 700
		error = ____error -- 701
	} -- 701
end -- 676
function MemoryCompressor.prototype.rawArchive(self, chunk, formatFunc) -- 708
	local ts = os.date("%Y-%m-%d %H:%M") -- 709
	local text = formatFunc(chunk) -- 710
	self.storage:appendHistory((((("[" .. ts) .. "] [RAW ARCHIVE] ") .. tostring(#chunk)) .. " actions (compression failed)\n") .. ("---\n" .. text) .. "\n---")
end -- 708
function MemoryCompressor.prototype.getStorage(self) -- 721
	return self.storage -- 722
end -- 721
MemoryCompressor.MAX_FAILURES = 3 -- 721
return ____exports -- 721