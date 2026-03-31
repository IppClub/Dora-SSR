-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, persistHistoryState, buildAgentSystemPrompt, buildXmlDecisionInstruction, SEARCH_DORA_API_LIMIT_MAX -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Path = ____Dora.Path -- 2
local Content = ____Dora.Content -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local ____Utils = require("Agent.Utils") -- 4
local callLLM = ____Utils.callLLM -- 4
local Log = ____Utils.Log -- 4
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 4
local createLocalToolCallId = ____Utils.createLocalToolCallId -- 4
local parseSimpleXMLChildren = ____Utils.parseSimpleXMLChildren -- 4
local parseXMLObjectFromText = ____Utils.parseXMLObjectFromText -- 4
local safeJsonDecode = ____Utils.safeJsonDecode -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 4
local Tools = require("Agent.Tools") -- 6
local ____Memory = require("Agent.Memory") -- 7
local MemoryCompressor = ____Memory.MemoryCompressor -- 7
function getReplyLanguageDirective(shared) -- 369
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 370
end -- 370
function replacePromptVars(template, vars) -- 375
	local output = template -- 376
	for key in pairs(vars) do -- 377
		output = table.concat( -- 378
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 378
			vars[key] or "" or "," -- 378
		) -- 378
	end -- 378
	return output -- 380
end -- 380
function getDecisionToolDefinitions(shared) -- 504
	local base = replacePromptVars( -- 505
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 506
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 507
	) -- 507
	if (shared and shared.decisionMode) ~= "xml" then -- 507
		return base -- 510
	end -- 510
	return base .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 512
end -- 512
function persistHistoryState(shared) -- 589
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.memory.lastConsolidatedMessageIndex) -- 590
end -- 590
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 916
	if includeToolDefinitions == nil then -- 916
		includeToolDefinitions = false -- 916
	end -- 916
	local sections = { -- 917
		shared.promptPack.agentIdentityPrompt, -- 918
		getReplyLanguageDirective(shared) -- 919
	} -- 919
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 921
	if memoryContext ~= "" then -- 921
		sections[#sections + 1] = memoryContext -- 923
	end -- 923
	if includeToolDefinitions then -- 923
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 926
		if shared.decisionMode == "xml" then -- 926
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 928
		end -- 928
	end -- 928
	return table.concat(sections, "\n\n") -- 931
end -- 931
function buildXmlDecisionInstruction(shared, feedback) -- 959
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 960
end -- 960
local function isRecord(value) -- 10
	return type(value) == "table" -- 11
end -- 10
local function isArray(value) -- 14
	return __TS__ArrayIsArray(value) -- 15
end -- 14
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 117
local HISTORY_READ_FILE_MAX_LINES = 300 -- 118
local READ_FILE_DEFAULT_LIMIT = 300 -- 119
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 120
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 121
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 122
SEARCH_DORA_API_LIMIT_MAX = 20 -- 123
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 124
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 125
local SEARCH_PREVIEW_CONTEXT = 80 -- 126
local function emitAgentEvent(shared, event) -- 169
	if shared.onEvent then -- 169
		shared:onEvent(event) -- 171
	end -- 171
end -- 169
local function emitAgentStartEvent(shared, action) -- 175
	emitAgentEvent(shared, { -- 176
		type = "tool_started", -- 177
		sessionId = shared.sessionId, -- 178
		taskId = shared.taskId, -- 179
		step = shared.step + 1, -- 180
		tool = action.tool -- 181
	}) -- 181
end -- 175
local function emitAgentFinishEvent(shared, action) -- 185
	emitAgentEvent(shared, { -- 186
		type = "tool_finished", -- 187
		sessionId = shared.sessionId, -- 188
		taskId = shared.taskId, -- 189
		step = shared.step + 1, -- 190
		tool = action.tool, -- 191
		result = action.result or ({}) -- 192
	}) -- 192
end -- 185
local function getCancelledReason(shared) -- 196
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 196
		return shared.stopToken.reason -- 197
	end -- 197
	return shared.useChineseResponse and "已取消" or "cancelled" -- 198
end -- 196
local function getMaxStepsReachedReason(shared) -- 201
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 202
end -- 201
local function getFailureSummaryFallback(shared, ____error) -- 207
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 208
end -- 207
local function canWriteStepLLMDebug(shared, stepId) -- 213
	if stepId == nil then -- 213
		stepId = shared.step + 1 -- 213
	end -- 213
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 214
end -- 213
local function ensureDirRecursive(dir) -- 221
	if not dir then -- 221
		return false -- 222
	end -- 222
	if Content:exist(dir) then -- 222
		return Content:isdir(dir) -- 223
	end -- 223
	local parent = Path:getPath(dir) -- 224
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 224
		return false -- 226
	end -- 226
	return Content:mkdir(dir) -- 228
end -- 221
local function encodeDebugJSON(value) -- 231
	local text, err = safeJsonEncode(value) -- 232
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 233
end -- 231
local function getStepLLMDebugDir(shared) -- 236
	return Path( -- 237
		shared.workingDir, -- 238
		".agent", -- 239
		tostring(shared.sessionId), -- 240
		tostring(shared.taskId) -- 241
	) -- 241
end -- 236
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 245
	return Path( -- 246
		getStepLLMDebugDir(shared), -- 246
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 246
	) -- 246
end -- 245
local function getLatestStepLLMDebugSeq(shared, stepId) -- 249
	if not canWriteStepLLMDebug(shared, stepId) then -- 249
		return 0 -- 250
	end -- 250
	local dir = getStepLLMDebugDir(shared) -- 251
	if not Content:exist(dir) or not Content:isdir(dir) then -- 251
		return 0 -- 252
	end -- 252
	local latest = 0 -- 253
	for ____, file in ipairs(Content:getFiles(dir)) do -- 254
		do -- 254
			local name = Path:getFilename(file) -- 255
			local seqText = string.match( -- 256
				name, -- 256
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 256
			) -- 256
			if seqText ~= nil then -- 256
				latest = math.max( -- 258
					latest, -- 258
					tonumber(seqText) -- 258
				) -- 258
				goto __continue23 -- 259
			end -- 259
			local legacyMatch = string.match( -- 261
				name, -- 261
				("^" .. tostring(stepId)) .. "_in%.md$" -- 261
			) -- 261
			if legacyMatch ~= nil then -- 261
				latest = math.max(latest, 1) -- 263
			end -- 263
		end -- 263
		::__continue23:: -- 263
	end -- 263
	return latest -- 266
end -- 249
local function writeStepLLMDebugFile(path, content) -- 269
	if not Content:save(path, content) then -- 269
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 271
		return false -- 272
	end -- 272
	return true -- 274
end -- 269
local function createStepLLMDebugPair(shared, stepId, inContent) -- 277
	if not canWriteStepLLMDebug(shared, stepId) then -- 277
		return 0 -- 278
	end -- 278
	local dir = getStepLLMDebugDir(shared) -- 279
	if not ensureDirRecursive(dir) then -- 279
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 281
		return 0 -- 282
	end -- 282
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 284
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 285
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 286
	if not writeStepLLMDebugFile(inPath, inContent) then -- 286
		return 0 -- 288
	end -- 288
	writeStepLLMDebugFile(outPath, "") -- 290
	return seq -- 291
end -- 277
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 294
	if not canWriteStepLLMDebug(shared, stepId) then -- 294
		return -- 295
	end -- 295
	local dir = getStepLLMDebugDir(shared) -- 296
	if not ensureDirRecursive(dir) then -- 296
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 298
		return -- 299
	end -- 299
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 301
	if latestSeq <= 0 then -- 301
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 303
		writeStepLLMDebugFile(outPath, content) -- 304
		return -- 305
	end -- 305
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 307
	writeStepLLMDebugFile(outPath, content) -- 308
end -- 294
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 311
	if not canWriteStepLLMDebug(shared, stepId) then -- 311
		return -- 312
	end -- 312
	local sections = { -- 313
		"# LLM Input", -- 314
		"session_id: " .. tostring(shared.sessionId), -- 315
		"task_id: " .. tostring(shared.taskId), -- 316
		"step_id: " .. tostring(stepId), -- 317
		"phase: " .. phase, -- 318
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 319
		"## Options", -- 320
		"```json", -- 321
		encodeDebugJSON(options), -- 322
		"```" -- 323
	} -- 323
	do -- 323
		local i = 0 -- 325
		while i < #messages do -- 325
			local message = messages[i + 1] -- 326
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 327
			sections[#sections + 1] = encodeDebugJSON(message) -- 328
			i = i + 1 -- 325
		end -- 325
	end -- 325
	createStepLLMDebugPair( -- 330
		shared, -- 330
		stepId, -- 330
		table.concat(sections, "\n") -- 330
	) -- 330
end -- 311
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 333
	if not canWriteStepLLMDebug(shared, stepId) then -- 333
		return -- 334
	end -- 334
	local ____array_0 = __TS__SparseArrayNew( -- 334
		"# LLM Output", -- 336
		"session_id: " .. tostring(shared.sessionId), -- 337
		"task_id: " .. tostring(shared.taskId), -- 338
		"step_id: " .. tostring(stepId), -- 339
		"phase: " .. phase, -- 340
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 341
		table.unpack(meta and ({ -- 342
			"## Meta", -- 342
			"```json", -- 342
			encodeDebugJSON(meta), -- 342
			"```" -- 342
		}) or ({})) -- 342
	) -- 342
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 342
	local sections = {__TS__SparseArraySpread(____array_0)} -- 335
	updateLatestStepLLMDebugOutput( -- 346
		shared, -- 346
		stepId, -- 346
		table.concat(sections, "\n") -- 346
	) -- 346
end -- 333
local function toJson(value) -- 349
	local text, err = safeJsonEncode(value) -- 350
	if text ~= nil then -- 350
		return text -- 351
	end -- 351
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 352
end -- 349
local function truncateText(text, maxLen) -- 355
	if #text <= maxLen then -- 355
		return text -- 356
	end -- 356
	local nextPos = utf8.offset(text, maxLen + 1) -- 357
	if nextPos == nil then -- 357
		return text -- 358
	end -- 358
	return string.sub(text, 1, nextPos - 1) .. "..." -- 359
end -- 355
local function utf8TakeHead(text, maxChars) -- 362
	if maxChars <= 0 or text == "" then -- 362
		return "" -- 363
	end -- 363
	local nextPos = utf8.offset(text, maxChars + 1) -- 364
	if nextPos == nil then -- 364
		return text -- 365
	end -- 365
	return string.sub(text, 1, nextPos - 1) -- 366
end -- 362
local function limitReadContentForHistory(content, tool) -- 383
	local lines = __TS__StringSplit(content, "\n") -- 384
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 385
	local limitedByLines = overLineLimit and table.concat( -- 386
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 387
		"\n" -- 387
	) or content -- 387
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 387
		return content -- 390
	end -- 390
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 392
	local reasons = {} -- 395
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 395
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 396
	end -- 396
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 396
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 397
	end -- 397
	local hint = "Narrow the requested line range." -- 398
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 399
end -- 383
local function summarizeEditTextParamForHistory(value, key) -- 402
	if type(value) ~= "string" then -- 402
		return nil -- 403
	end -- 403
	local text = value -- 404
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 405
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 406
end -- 402
local function sanitizeReadResultForHistory(tool, result) -- 414
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 414
		return result -- 416
	end -- 416
	local clone = {} -- 418
	for key in pairs(result) do -- 419
		clone[key] = result[key] -- 420
	end -- 420
	clone.content = limitReadContentForHistory(result.content, tool) -- 422
	return clone -- 423
end -- 414
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 426
	local shown = math.min(#items, maxItems) -- 430
	local out = {} -- 431
	do -- 431
		local i = 0 -- 432
		while i < shown do -- 432
			local row = items[i + 1] -- 433
			out[#out + 1] = { -- 434
				file = row.file, -- 435
				line = row.line, -- 436
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 437
			} -- 437
			i = i + 1 -- 432
		end -- 432
	end -- 432
	return out -- 442
end -- 426
local function sanitizeSearchResultForHistory(tool, result) -- 445
	if result.success ~= true or not isArray(result.results) then -- 445
		return result -- 449
	end -- 449
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 449
		return result -- 450
	end -- 450
	local clone = {} -- 451
	for key in pairs(result) do -- 452
		clone[key] = result[key] -- 453
	end -- 453
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 455
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 456
	if tool == "grep_files" and isArray(result.groupedResults) then -- 456
		local grouped = result.groupedResults -- 461
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 462
		local sanitizedGroups = {} -- 463
		do -- 463
			local i = 0 -- 464
			while i < shown do -- 464
				local row = grouped[i + 1] -- 465
				sanitizedGroups[#sanitizedGroups + 1] = { -- 466
					file = row.file, -- 467
					totalMatches = row.totalMatches, -- 468
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 469
				} -- 469
				i = i + 1 -- 464
			end -- 464
		end -- 464
		clone.groupedResults = sanitizedGroups -- 474
	end -- 474
	return clone -- 476
end -- 445
local function sanitizeListFilesResultForHistory(result) -- 479
	if result.success ~= true or not isArray(result.files) then -- 479
		return result -- 480
	end -- 480
	local clone = {} -- 481
	for key in pairs(result) do -- 482
		clone[key] = result[key] -- 483
	end -- 483
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 485
	return clone -- 486
end -- 479
local function sanitizeActionParamsForHistory(tool, params) -- 489
	if tool ~= "edit_file" then -- 489
		return params -- 490
	end -- 490
	local clone = {} -- 491
	for key in pairs(params) do -- 492
		if key == "old_str" then -- 492
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 494
		elseif key == "new_str" then -- 494
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 496
		else -- 496
			clone[key] = params[key] -- 498
		end -- 498
	end -- 498
	return clone -- 501
end -- 489
local function maybeCompressHistory(shared) -- 521
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 521
		local ____shared_5 = shared -- 522
		local memory = ____shared_5.memory -- 522
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 523
		local changed = false -- 524
		do -- 524
			local round = 0 -- 525
			while round < maxRounds do -- 525
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 526
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 530
				if not memory.compressor:shouldCompress(shared.messages, memory.lastConsolidatedMessageIndex, systemPrompt, toolDefinitions) then -- 530
					return ____awaiter_resolve(nil) -- 530
				end -- 530
				local result = __TS__Await(memory.compressor:compress( -- 541
					shared.messages, -- 542
					memory.lastConsolidatedMessageIndex, -- 543
					systemPrompt, -- 544
					toolDefinitions, -- 545
					shared.llmOptions, -- 546
					shared.llmMaxTry, -- 547
					shared.decisionMode -- 548
				)) -- 548
				if not (result and result.success and result.compressedCount > 0) then -- 548
					if changed then -- 548
						persistHistoryState(shared) -- 552
					end -- 552
					return ____awaiter_resolve(nil) -- 552
				end -- 552
				memory.lastConsolidatedMessageIndex = memory.lastConsolidatedMessageIndex + result.compressedCount -- 556
				changed = true -- 557
				Log( -- 558
					"Info", -- 558
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(round + 1)) .. ")" -- 558
				) -- 558
				round = round + 1 -- 525
			end -- 525
		end -- 525
		if changed then -- 525
			persistHistoryState(shared) -- 561
		end -- 561
	end) -- 561
end -- 521
local function isKnownToolName(name) -- 565
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 566
end -- 565
local function getFinishMessage(params, fallback) -- 576
	if fallback == nil then -- 576
		fallback = "" -- 576
	end -- 576
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 576
		return __TS__StringTrim(params.message) -- 578
	end -- 578
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 578
		return __TS__StringTrim(params.response) -- 581
	end -- 581
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 581
		return __TS__StringTrim(params.summary) -- 584
	end -- 584
	return __TS__StringTrim(fallback) -- 586
end -- 576
local function appendConversationMessage(shared, message) -- 596
	local ____shared_messages_6 = shared.messages -- 596
	____shared_messages_6[#____shared_messages_6 + 1] = __TS__ObjectAssign( -- 597
		{}, -- 597
		message, -- 598
		{ -- 597
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 599
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 600
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 601
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 602
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 603
		} -- 603
	) -- 603
end -- 596
local function ensureToolCallId(toolCallId) -- 607
	if toolCallId and toolCallId ~= "" then -- 607
		return toolCallId -- 608
	end -- 608
	return createLocalToolCallId() -- 609
end -- 607
local function appendToolResultMessage(shared, action) -- 612
	appendConversationMessage( -- 613
		shared, -- 613
		{ -- 613
			role = "tool", -- 614
			tool_call_id = action.toolCallId, -- 615
			name = action.tool, -- 616
			content = action.result and toJson(action.result) or "" -- 617
		} -- 617
	) -- 617
end -- 612
local function parseXMLToolCallObjectFromText(text) -- 621
	local children = parseXMLObjectFromText(text, "tool_call") -- 622
	if not children.success then -- 622
		return children -- 623
	end -- 623
	local rawObj = children.obj -- 624
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 625
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 626
	if not params.success then -- 626
		return {success = false, message = params.message} -- 630
	end -- 630
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 632
end -- 621
local function llm(shared, messages, phase) -- 651
	if phase == nil then -- 651
		phase = "decision_xml" -- 654
	end -- 654
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 654
		local stepId = shared.step + 1 -- 656
		saveStepLLMDebugInput( -- 657
			shared, -- 657
			stepId, -- 657
			phase, -- 657
			messages, -- 657
			shared.llmOptions -- 657
		) -- 657
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 658
		if res.success then -- 658
			local ____opt_11 = res.response.choices -- 658
			local ____opt_9 = ____opt_11 and ____opt_11[1] -- 658
			local ____opt_7 = ____opt_9 and ____opt_9.message -- 658
			local text = ____opt_7 and ____opt_7.content -- 660
			if text then -- 660
				saveStepLLMDebugOutput( -- 662
					shared, -- 662
					stepId, -- 662
					phase, -- 662
					text, -- 662
					{success = true} -- 662
				) -- 662
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 662
			else -- 662
				saveStepLLMDebugOutput( -- 665
					shared, -- 665
					stepId, -- 665
					phase, -- 665
					"empty LLM response", -- 665
					{success = false} -- 665
				) -- 665
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 665
			end -- 665
		else -- 665
			saveStepLLMDebugOutput( -- 669
				shared, -- 669
				stepId, -- 669
				phase, -- 669
				res.raw or res.message, -- 669
				{success = false} -- 669
			) -- 669
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 669
		end -- 669
	end) -- 669
end -- 651
local function parseDecisionObject(rawObj) -- 686
	if type(rawObj.tool) ~= "string" then -- 686
		return {success = false, message = "missing tool"} -- 687
	end -- 687
	local tool = rawObj.tool -- 688
	if not isKnownToolName(tool) then -- 688
		return {success = false, message = "unknown tool: " .. tool} -- 690
	end -- 690
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 692
	if tool ~= "finish" and (not reason or reason == "") then -- 692
		return {success = false, message = tool .. " requires top-level reason"} -- 696
	end -- 696
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 698
	return {success = true, tool = tool, params = params, reason = reason} -- 699
end -- 686
local function parseDecisionToolCall(functionName, rawObj) -- 707
	if not isKnownToolName(functionName) then -- 707
		return {success = false, message = "unknown tool: " .. functionName} -- 709
	end -- 709
	if rawObj == nil or rawObj == nil then -- 709
		return {success = true, tool = functionName, params = {}} -- 712
	end -- 712
	if not isRecord(rawObj) then -- 712
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 715
	end -- 715
	return {success = true, tool = functionName, params = rawObj} -- 717
end -- 707
local function getDecisionPath(params) -- 724
	if type(params.path) == "string" then -- 724
		return __TS__StringTrim(params.path) -- 725
	end -- 725
	if type(params.target_file) == "string" then -- 725
		return __TS__StringTrim(params.target_file) -- 726
	end -- 726
	return "" -- 727
end -- 724
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 730
	local num = __TS__Number(value) -- 731
	if not __TS__NumberIsFinite(num) then -- 731
		num = fallback -- 732
	end -- 732
	num = math.floor(num) -- 733
	if num < minValue then -- 733
		num = minValue -- 734
	end -- 734
	if maxValue ~= nil and num > maxValue then -- 734
		num = maxValue -- 735
	end -- 735
	return num -- 736
end -- 730
local function validateDecision(tool, params) -- 739
	if tool == "finish" then -- 739
		local message = getFinishMessage(params) -- 744
		if message == "" then -- 744
			return {success = false, message = "finish requires params.message"} -- 745
		end -- 745
		params.message = message -- 746
		return {success = true, params = params} -- 747
	end -- 747
	if tool == "read_file" then -- 747
		local path = getDecisionPath(params) -- 751
		if path == "" then -- 751
			return {success = false, message = "read_file requires path"} -- 752
		end -- 752
		params.path = path -- 753
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 754
		local ____params_endLine_13 = params.endLine -- 755
		if ____params_endLine_13 == nil then -- 755
			____params_endLine_13 = READ_FILE_DEFAULT_LIMIT -- 755
		end -- 755
		local endLineRaw = ____params_endLine_13 -- 755
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 756
		params.startLine = startLine -- 757
		params.endLine = endLine -- 758
		return {success = true, params = params} -- 759
	end -- 759
	if tool == "edit_file" then -- 759
		local path = getDecisionPath(params) -- 763
		if path == "" then -- 763
			return {success = false, message = "edit_file requires path"} -- 764
		end -- 764
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 765
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 766
		params.path = path -- 767
		params.old_str = oldStr -- 768
		params.new_str = newStr -- 769
		return {success = true, params = params} -- 770
	end -- 770
	if tool == "delete_file" then -- 770
		local targetFile = getDecisionPath(params) -- 774
		if targetFile == "" then -- 774
			return {success = false, message = "delete_file requires target_file"} -- 775
		end -- 775
		params.target_file = targetFile -- 776
		return {success = true, params = params} -- 777
	end -- 777
	if tool == "grep_files" then -- 777
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 781
		if pattern == "" then -- 781
			return {success = false, message = "grep_files requires pattern"} -- 782
		end -- 782
		params.pattern = pattern -- 783
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 784
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 785
		return {success = true, params = params} -- 786
	end -- 786
	if tool == "search_dora_api" then -- 786
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 790
		if pattern == "" then -- 790
			return {success = false, message = "search_dora_api requires pattern"} -- 791
		end -- 791
		params.pattern = pattern -- 792
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 793
		return {success = true, params = params} -- 794
	end -- 794
	if tool == "glob_files" then -- 794
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 798
		return {success = true, params = params} -- 799
	end -- 799
	if tool == "build" then -- 799
		local path = getDecisionPath(params) -- 803
		if path ~= "" then -- 803
			params.path = path -- 805
		end -- 805
		return {success = true, params = params} -- 807
	end -- 807
	return {success = true, params = params} -- 810
end -- 739
local function createFunctionToolSchema(name, description, properties, required) -- 813
	if required == nil then -- 813
		required = {} -- 817
	end -- 817
	local parameters = {type = "object", properties = properties} -- 819
	if #required > 0 then -- 819
		parameters.required = required -- 824
	end -- 824
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 826
end -- 813
local function buildDecisionToolSchema() -- 836
	return { -- 837
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Parameters: path, startLine(optional), endLine(optional). Line numbering starts with 1. startLine defaults to 1 and endLine defaults to 300.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "1-based starting line number. Defaults to 1."}, endLine = {type = "number", description = "1-based ending line number. Defaults to 300."}}, {"path"}), -- 838
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 848
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 858
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 866
			path = {type = "string", description = "Base directory or file path to search within."}, -- 870
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 871
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 872
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 873
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 874
			limit = {type = "number", description = "Maximum number of results to return."}, -- 875
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 876
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 877
		}, {"pattern"}), -- 877
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 881
		createFunctionToolSchema( -- 890
			"search_dora_api", -- 891
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 891
			{ -- 893
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 894
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 895
				programmingLanguage = {type = "string", enum = { -- 896
					"ts", -- 898
					"tsx", -- 898
					"lua", -- 898
					"yue", -- 898
					"teal", -- 898
					"tl", -- 898
					"wa" -- 898
				}, description = "Preferred language variant to search."}, -- 898
				limit = { -- 901
					type = "number", -- 901
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 901
				}, -- 901
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 902
			}, -- 902
			{"pattern"} -- 904
		), -- 904
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}) -- 906
	} -- 906
end -- 836
local function getUnconsolidatedMessages(shared) -- 934
	return __TS__ArraySlice(shared.messages, shared.memory.lastConsolidatedMessageIndex) -- 935
end -- 934
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 938
	if attempt == nil then -- 938
		attempt = 1 -- 938
	end -- 938
	local messages = { -- 939
		{ -- 940
			role = "system", -- 940
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 940
		}, -- 940
		table.unpack(getUnconsolidatedMessages(shared)) -- 941
	} -- 941
	if lastError and lastError ~= "" then -- 941
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 944
		messages[#messages + 1] = { -- 947
			role = "user", -- 948
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 949
		} -- 949
	end -- 949
	return messages -- 956
end -- 938
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 963
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 970
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 971
	local repairPrompt = replacePromptVars( -- 979
		shared.promptPack.xmlDecisionRepairPrompt, -- 979
		{ -- 979
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 980
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 981
			CANDIDATE_SECTION = candidateSection, -- 982
			LAST_ERROR = lastError, -- 983
			ATTEMPT = tostring(attempt) -- 984
		} -- 984
	) -- 984
	return {{role = "system", content = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only."}, {role = "user", content = repairPrompt}} -- 986
end -- 963
local function tryParseAndValidateDecision(rawText) -- 1008
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 1009
	if not parsed.success then -- 1009
		return {success = false, message = parsed.message, raw = rawText} -- 1011
	end -- 1011
	local decision = parseDecisionObject(parsed.obj) -- 1013
	if not decision.success then -- 1013
		return {success = false, message = decision.message, raw = rawText} -- 1015
	end -- 1015
	local validation = validateDecision(decision.tool, decision.params) -- 1017
	if not validation.success then -- 1017
		return {success = false, message = validation.message, raw = rawText} -- 1019
	end -- 1019
	decision.params = validation.params -- 1021
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 1022
	return decision -- 1023
end -- 1008
local function normalizeLineEndings(text) -- 1026
	local res = string.gsub(text, "\r\n", "\n") -- 1027
	res = string.gsub(res, "\r", "\n") -- 1028
	return res -- 1029
end -- 1026
local function countOccurrences(text, searchStr) -- 1032
	if searchStr == "" then -- 1032
		return 0 -- 1033
	end -- 1033
	local count = 0 -- 1034
	local pos = 0 -- 1035
	while true do -- 1035
		local idx = (string.find( -- 1037
			text, -- 1037
			searchStr, -- 1037
			math.max(pos + 1, 1), -- 1037
			true -- 1037
		) or 0) - 1 -- 1037
		if idx < 0 then -- 1037
			break -- 1038
		end -- 1038
		count = count + 1 -- 1039
		pos = idx + #searchStr -- 1040
	end -- 1040
	return count -- 1042
end -- 1032
local function replaceFirst(text, oldStr, newStr) -- 1045
	if oldStr == "" then -- 1045
		return text -- 1046
	end -- 1046
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 1047
	if idx < 0 then -- 1047
		return text -- 1048
	end -- 1048
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 1049
end -- 1045
local function splitLines(text) -- 1052
	return __TS__StringSplit(text, "\n") -- 1053
end -- 1052
local function getLeadingWhitespace(text) -- 1056
	local i = 0 -- 1057
	while i < #text do -- 1057
		local ch = __TS__StringAccess(text, i) -- 1059
		if ch ~= " " and ch ~= "\t" then -- 1059
			break -- 1060
		end -- 1060
		i = i + 1 -- 1061
	end -- 1061
	return __TS__StringSubstring(text, 0, i) -- 1063
end -- 1056
local function getCommonIndentPrefix(lines) -- 1066
	local common -- 1067
	do -- 1067
		local i = 0 -- 1068
		while i < #lines do -- 1068
			do -- 1068
				local line = lines[i + 1] -- 1069
				if __TS__StringTrim(line) == "" then -- 1069
					goto __continue175 -- 1070
				end -- 1070
				local indent = getLeadingWhitespace(line) -- 1071
				if common == nil then -- 1071
					common = indent -- 1073
					goto __continue175 -- 1074
				end -- 1074
				local j = 0 -- 1076
				local maxLen = math.min(#common, #indent) -- 1077
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 1077
					j = j + 1 -- 1079
				end -- 1079
				common = __TS__StringSubstring(common, 0, j) -- 1081
				if common == "" then -- 1081
					break -- 1082
				end -- 1082
			end -- 1082
			::__continue175:: -- 1082
			i = i + 1 -- 1068
		end -- 1068
	end -- 1068
	return common or "" -- 1084
end -- 1066
local function removeIndentPrefix(line, indent) -- 1087
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 1087
		return __TS__StringSubstring(line, #indent) -- 1089
	end -- 1089
	local lineIndent = getLeadingWhitespace(line) -- 1091
	local j = 0 -- 1092
	local maxLen = math.min(#lineIndent, #indent) -- 1093
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 1093
		j = j + 1 -- 1095
	end -- 1095
	return __TS__StringSubstring(line, j) -- 1097
end -- 1087
local function dedentLines(lines) -- 1100
	local indent = getCommonIndentPrefix(lines) -- 1101
	return { -- 1102
		indent = indent, -- 1103
		lines = __TS__ArrayMap( -- 1104
			lines, -- 1104
			function(____, line) return removeIndentPrefix(line, indent) end -- 1104
		) -- 1104
	} -- 1104
end -- 1100
local function joinLines(lines) -- 1108
	return table.concat(lines, "\n") -- 1109
end -- 1108
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 1112
	local contentLines = splitLines(content) -- 1117
	local oldLines = splitLines(oldStr) -- 1118
	if #oldLines == 0 then -- 1118
		return {success = false, message = "old_str not found in file"} -- 1120
	end -- 1120
	local dedentedOld = dedentLines(oldLines) -- 1122
	local dedentedOldText = joinLines(dedentedOld.lines) -- 1123
	local dedentedNew = dedentLines(splitLines(newStr)) -- 1124
	local matches = {} -- 1125
	do -- 1125
		local start = 0 -- 1126
		while start <= #contentLines - #oldLines do -- 1126
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 1127
			local dedentedCandidate = dedentLines(candidateLines) -- 1128
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 1128
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 1130
			end -- 1130
			start = start + 1 -- 1126
		end -- 1126
	end -- 1126
	if #matches == 0 then -- 1126
		return {success = false, message = "old_str not found in file"} -- 1138
	end -- 1138
	if #matches > 1 then -- 1138
		return { -- 1141
			success = false, -- 1142
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 1143
		} -- 1143
	end -- 1143
	local match = matches[1] -- 1146
	local rebuiltNewLines = __TS__ArrayMap( -- 1147
		dedentedNew.lines, -- 1147
		function(____, line) return line == "" and "" or match.indent .. line end -- 1147
	) -- 1147
	local ____array_14 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 1147
	__TS__SparseArrayPush( -- 1147
		____array_14, -- 1147
		table.unpack(rebuiltNewLines) -- 1150
	) -- 1150
	__TS__SparseArrayPush( -- 1150
		____array_14, -- 1150
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 1151
	) -- 1151
	local nextLines = {__TS__SparseArraySpread(____array_14)} -- 1148
	return { -- 1153
		success = true, -- 1153
		content = joinLines(nextLines) -- 1153
	} -- 1153
end -- 1112
local MainDecisionAgent = __TS__Class() -- 1156
MainDecisionAgent.name = "MainDecisionAgent" -- 1156
__TS__ClassExtends(MainDecisionAgent, Node) -- 1156
function MainDecisionAgent.prototype.prep(self, shared) -- 1157
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1157
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1157
			return ____awaiter_resolve(nil, {shared = shared}) -- 1157
		end -- 1157
		__TS__Await(maybeCompressHistory(shared)) -- 1162
		return ____awaiter_resolve(nil, {shared = shared}) -- 1162
	end) -- 1162
end -- 1157
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 1167
	if attempt == nil then -- 1167
		attempt = 1 -- 1170
	end -- 1170
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1170
		if shared.stopToken.stopped then -- 1170
			return ____awaiter_resolve( -- 1170
				nil, -- 1170
				{ -- 1174
					success = false, -- 1174
					message = getCancelledReason(shared) -- 1174
				} -- 1174
			) -- 1174
		end -- 1174
		Log( -- 1176
			"Info", -- 1176
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1176
		) -- 1176
		local tools = buildDecisionToolSchema() -- 1177
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1178
		local stepId = shared.step + 1 -- 1179
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1180
		saveStepLLMDebugInput( -- 1184
			shared, -- 1184
			stepId, -- 1184
			"decision_tool_calling", -- 1184
			messages, -- 1184
			llmOptions -- 1184
		) -- 1184
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1185
		if shared.stopToken.stopped then -- 1185
			return ____awaiter_resolve( -- 1185
				nil, -- 1185
				{ -- 1187
					success = false, -- 1187
					message = getCancelledReason(shared) -- 1187
				} -- 1187
			) -- 1187
		end -- 1187
		if not res.success then -- 1187
			saveStepLLMDebugOutput( -- 1190
				shared, -- 1190
				stepId, -- 1190
				"decision_tool_calling", -- 1190
				res.raw or res.message, -- 1190
				{success = false} -- 1190
			) -- 1190
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1191
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1191
		end -- 1191
		saveStepLLMDebugOutput( -- 1194
			shared, -- 1194
			stepId, -- 1194
			"decision_tool_calling", -- 1194
			encodeDebugJSON(res.response), -- 1194
			{success = true} -- 1194
		) -- 1194
		local choice = res.response.choices and res.response.choices[1] -- 1195
		local message = choice and choice.message -- 1196
		local toolCalls = message and message.tool_calls -- 1197
		local toolCall = toolCalls and toolCalls[1] -- 1198
		local fn = toolCall and toolCall["function"] -- 1199
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 1200
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1203
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1206
		Log( -- 1209
			"Info", -- 1209
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1209
		) -- 1209
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1209
			if messageContent and messageContent ~= "" then -- 1209
				Log( -- 1212
					"Info", -- 1212
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1212
				) -- 1212
				return ____awaiter_resolve(nil, { -- 1212
					success = true, -- 1214
					tool = "finish", -- 1215
					params = {}, -- 1216
					reason = messageContent, -- 1217
					reasoningContent = reasoningContent, -- 1218
					directSummary = messageContent -- 1219
				}) -- 1219
			end -- 1219
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1222
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1222
		end -- 1222
		local functionName = fn.name -- 1229
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1230
		Log( -- 1231
			"Info", -- 1231
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1231
		) -- 1231
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1232
			local rawObj, err = safeJsonDecode(argsText) -- 1233
			if err ~= nil or rawObj == nil then -- 1233
				return {__error = tostring(err)} -- 1235
			end -- 1235
			return rawObj -- 1237
		end)() -- 1232
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 1232
			local err = tostring(rawArgs.__error) -- 1240
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1241
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1241
		end -- 1241
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1248
		if not decision.success then -- 1248
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1250
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1250
		end -- 1250
		local validation = validateDecision(decision.tool, decision.params) -- 1257
		if not validation.success then -- 1257
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1259
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1259
		end -- 1259
		decision.params = validation.params -- 1266
		decision.toolCallId = ensureToolCallId(toolCallId) -- 1267
		decision.reason = messageContent -- 1268
		decision.reasoningContent = reasoningContent -- 1269
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1270
		return ____awaiter_resolve(nil, decision) -- 1270
	end) -- 1270
end -- 1167
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 1274
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1274
		Log( -- 1279
			"Info", -- 1279
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 1279
		) -- 1279
		local lastError = initialError -- 1280
		local candidateRaw = "" -- 1281
		do -- 1281
			local attempt = 0 -- 1282
			while attempt < shared.llmMaxTry do -- 1282
				do -- 1282
					Log( -- 1283
						"Info", -- 1283
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 1283
					) -- 1283
					local messages = buildXmlRepairMessages( -- 1284
						shared, -- 1285
						originalRaw, -- 1286
						candidateRaw, -- 1287
						lastError, -- 1288
						attempt + 1 -- 1289
					) -- 1289
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 1291
					if shared.stopToken.stopped then -- 1291
						return ____awaiter_resolve( -- 1291
							nil, -- 1291
							{ -- 1293
								success = false, -- 1293
								message = getCancelledReason(shared) -- 1293
							} -- 1293
						) -- 1293
					end -- 1293
					if not llmRes.success then -- 1293
						lastError = llmRes.message -- 1296
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 1297
						goto __continue209 -- 1298
					end -- 1298
					candidateRaw = llmRes.text -- 1300
					local decision = tryParseAndValidateDecision(candidateRaw) -- 1301
					if decision.success then -- 1301
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 1303
						return ____awaiter_resolve(nil, decision) -- 1303
					end -- 1303
					lastError = decision.message -- 1306
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 1307
				end -- 1307
				::__continue209:: -- 1307
				attempt = attempt + 1 -- 1282
			end -- 1282
		end -- 1282
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 1309
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 1309
	end) -- 1309
end -- 1274
function MainDecisionAgent.prototype.exec(self, input) -- 1317
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1317
		local shared = input.shared -- 1318
		if shared.stopToken.stopped then -- 1318
			return ____awaiter_resolve( -- 1318
				nil, -- 1318
				{ -- 1320
					success = false, -- 1320
					message = getCancelledReason(shared) -- 1320
				} -- 1320
			) -- 1320
		end -- 1320
		if shared.step >= shared.maxSteps then -- 1320
			Log( -- 1323
				"Warn", -- 1323
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1323
			) -- 1323
			return ____awaiter_resolve( -- 1323
				nil, -- 1323
				{ -- 1324
					success = false, -- 1324
					message = getMaxStepsReachedReason(shared) -- 1324
				} -- 1324
			) -- 1324
		end -- 1324
		if shared.decisionMode == "tool_calling" then -- 1324
			Log( -- 1328
				"Info", -- 1328
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 1328
			) -- 1328
			local lastError = "tool calling validation failed" -- 1329
			local lastRaw = "" -- 1330
			do -- 1330
				local attempt = 0 -- 1331
				while attempt < shared.llmMaxTry do -- 1331
					Log( -- 1332
						"Info", -- 1332
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1332
					) -- 1332
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 1333
					if shared.stopToken.stopped then -- 1333
						return ____awaiter_resolve( -- 1333
							nil, -- 1333
							{ -- 1340
								success = false, -- 1340
								message = getCancelledReason(shared) -- 1340
							} -- 1340
						) -- 1340
					end -- 1340
					if decision.success then -- 1340
						return ____awaiter_resolve(nil, decision) -- 1340
					end -- 1340
					lastError = decision.message -- 1345
					lastRaw = decision.raw or "" -- 1346
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1347
					attempt = attempt + 1 -- 1331
				end -- 1331
			end -- 1331
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1349
			return ____awaiter_resolve( -- 1349
				nil, -- 1349
				{ -- 1350
					success = false, -- 1350
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1350
				} -- 1350
			) -- 1350
		end -- 1350
		local lastError = "xml validation failed" -- 1353
		local lastRaw = "" -- 1354
		do -- 1354
			local attempt = 0 -- 1355
			while attempt < shared.llmMaxTry do -- 1355
				do -- 1355
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 1356
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 1364
					if shared.stopToken.stopped then -- 1364
						return ____awaiter_resolve( -- 1364
							nil, -- 1364
							{ -- 1366
								success = false, -- 1366
								message = getCancelledReason(shared) -- 1366
							} -- 1366
						) -- 1366
					end -- 1366
					if not llmRes.success then -- 1366
						lastError = llmRes.message -- 1369
						lastRaw = llmRes.text or "" -- 1370
						goto __continue222 -- 1371
					end -- 1371
					lastRaw = llmRes.text -- 1373
					local decision = tryParseAndValidateDecision(llmRes.text) -- 1374
					if decision.success then -- 1374
						return ____awaiter_resolve(nil, decision) -- 1374
					end -- 1374
					lastError = decision.message -- 1378
					return ____awaiter_resolve( -- 1378
						nil, -- 1378
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 1379
					) -- 1379
				end -- 1379
				::__continue222:: -- 1379
				attempt = attempt + 1 -- 1355
			end -- 1355
		end -- 1355
		return ____awaiter_resolve( -- 1355
			nil, -- 1355
			{ -- 1381
				success = false, -- 1381
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1381
			} -- 1381
		) -- 1381
	end) -- 1381
end -- 1317
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1384
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1384
		local result = execRes -- 1385
		if not result.success then -- 1385
			shared.error = result.message -- 1387
			shared.response = getFailureSummaryFallback(shared, result.message) -- 1388
			shared.done = true -- 1389
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 1390
			persistHistoryState(shared) -- 1394
			return ____awaiter_resolve(nil, "done") -- 1394
		end -- 1394
		if result.directSummary and result.directSummary ~= "" then -- 1394
			shared.response = result.directSummary -- 1398
			shared.done = true -- 1399
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 1400
			persistHistoryState(shared) -- 1405
			return ____awaiter_resolve(nil, "done") -- 1405
		end -- 1405
		if result.tool == "finish" then -- 1405
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 1409
			shared.response = finalMessage -- 1410
			shared.done = true -- 1411
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 1412
			persistHistoryState(shared) -- 1417
			return ____awaiter_resolve(nil, "done") -- 1417
		end -- 1417
		emitAgentEvent(shared, { -- 1420
			type = "decision_made", -- 1421
			sessionId = shared.sessionId, -- 1422
			taskId = shared.taskId, -- 1423
			step = shared.step + 1, -- 1424
			tool = result.tool, -- 1425
			reason = result.reason, -- 1426
			reasoningContent = result.reasoningContent, -- 1427
			params = result.params -- 1428
		}) -- 1428
		local toolCallId = ensureToolCallId(result.toolCallId) -- 1430
		local ____shared_history_15 = shared.history -- 1430
		____shared_history_15[#____shared_history_15 + 1] = { -- 1431
			step = #shared.history + 1, -- 1432
			toolCallId = toolCallId, -- 1433
			tool = result.tool, -- 1434
			reason = result.reason or "", -- 1435
			reasoningContent = result.reasoningContent, -- 1436
			params = result.params, -- 1437
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1438
		} -- 1438
		appendConversationMessage( -- 1440
			shared, -- 1440
			{ -- 1440
				role = "assistant", -- 1441
				content = result.reason or "", -- 1442
				reasoning_content = result.reasoningContent, -- 1443
				tool_calls = {{ -- 1444
					id = toolCallId, -- 1445
					type = "function", -- 1446
					["function"] = { -- 1447
						name = result.tool, -- 1448
						arguments = toJson(result.params) -- 1449
					} -- 1449
				}} -- 1449
			} -- 1449
		) -- 1449
		persistHistoryState(shared) -- 1453
		return ____awaiter_resolve(nil, result.tool) -- 1453
	end) -- 1453
end -- 1384
local ReadFileAction = __TS__Class() -- 1458
ReadFileAction.name = "ReadFileAction" -- 1458
__TS__ClassExtends(ReadFileAction, Node) -- 1458
function ReadFileAction.prototype.prep(self, shared) -- 1459
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1459
		local last = shared.history[#shared.history] -- 1460
		if not last then -- 1460
			error( -- 1461
				__TS__New(Error, "no history"), -- 1461
				0 -- 1461
			) -- 1461
		end -- 1461
		emitAgentStartEvent(shared, last) -- 1462
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1463
		if __TS__StringTrim(path) == "" then -- 1463
			error( -- 1466
				__TS__New(Error, "missing path"), -- 1466
				0 -- 1466
			) -- 1466
		end -- 1466
		local ____path_18 = path -- 1468
		local ____shared_workingDir_19 = shared.workingDir -- 1470
		local ____temp_20 = shared.useChineseResponse and "zh" or "en" -- 1471
		local ____last_params_startLine_16 = last.params.startLine -- 1472
		if ____last_params_startLine_16 == nil then -- 1472
			____last_params_startLine_16 = 1 -- 1472
		end -- 1472
		local ____TS__Number_result_21 = __TS__Number(____last_params_startLine_16) -- 1472
		local ____last_params_endLine_17 = last.params.endLine -- 1473
		if ____last_params_endLine_17 == nil then -- 1473
			____last_params_endLine_17 = READ_FILE_DEFAULT_LIMIT -- 1473
		end -- 1473
		return ____awaiter_resolve( -- 1473
			nil, -- 1473
			{ -- 1467
				path = ____path_18, -- 1468
				tool = "read_file", -- 1469
				workDir = ____shared_workingDir_19, -- 1470
				docLanguage = ____temp_20, -- 1471
				startLine = ____TS__Number_result_21, -- 1472
				endLine = __TS__Number(____last_params_endLine_17) -- 1473
			} -- 1473
		) -- 1473
	end) -- 1473
end -- 1459
function ReadFileAction.prototype.exec(self, input) -- 1477
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1477
		return ____awaiter_resolve( -- 1477
			nil, -- 1477
			Tools.readFile( -- 1478
				input.workDir, -- 1479
				input.path, -- 1480
				__TS__Number(input.startLine or 1), -- 1481
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1482
				input.docLanguage -- 1483
			) -- 1483
		) -- 1483
	end) -- 1483
end -- 1477
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1487
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1487
		local result = execRes -- 1488
		local last = shared.history[#shared.history] -- 1489
		if last ~= nil then -- 1489
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1491
			appendToolResultMessage(shared, last) -- 1492
			emitAgentFinishEvent(shared, last) -- 1493
		end -- 1493
		__TS__Await(maybeCompressHistory(shared)) -- 1495
		persistHistoryState(shared) -- 1496
		shared.step = shared.step + 1 -- 1497
		return ____awaiter_resolve(nil, "main") -- 1497
	end) -- 1497
end -- 1487
local SearchFilesAction = __TS__Class() -- 1502
SearchFilesAction.name = "SearchFilesAction" -- 1502
__TS__ClassExtends(SearchFilesAction, Node) -- 1502
function SearchFilesAction.prototype.prep(self, shared) -- 1503
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1503
		local last = shared.history[#shared.history] -- 1504
		if not last then -- 1504
			error( -- 1505
				__TS__New(Error, "no history"), -- 1505
				0 -- 1505
			) -- 1505
		end -- 1505
		emitAgentStartEvent(shared, last) -- 1506
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1506
	end) -- 1506
end -- 1503
function SearchFilesAction.prototype.exec(self, input) -- 1510
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1510
		local params = input.params -- 1511
		local ____Tools_searchFiles_35 = Tools.searchFiles -- 1512
		local ____input_workDir_28 = input.workDir -- 1513
		local ____temp_29 = params.path or "" -- 1514
		local ____temp_30 = params.pattern or "" -- 1515
		local ____params_globs_31 = params.globs -- 1516
		local ____params_useRegex_32 = params.useRegex -- 1517
		local ____params_caseSensitive_33 = params.caseSensitive -- 1518
		local ____math_max_24 = math.max -- 1521
		local ____math_floor_23 = math.floor -- 1521
		local ____params_limit_22 = params.limit -- 1521
		if ____params_limit_22 == nil then -- 1521
			____params_limit_22 = SEARCH_FILES_LIMIT_DEFAULT -- 1521
		end -- 1521
		local ____math_max_24_result_34 = ____math_max_24( -- 1521
			1, -- 1521
			____math_floor_23(__TS__Number(____params_limit_22)) -- 1521
		) -- 1521
		local ____math_max_27 = math.max -- 1522
		local ____math_floor_26 = math.floor -- 1522
		local ____params_offset_25 = params.offset -- 1522
		if ____params_offset_25 == nil then -- 1522
			____params_offset_25 = 0 -- 1522
		end -- 1522
		local result = __TS__Await(____Tools_searchFiles_35({ -- 1512
			workDir = ____input_workDir_28, -- 1513
			path = ____temp_29, -- 1514
			pattern = ____temp_30, -- 1515
			globs = ____params_globs_31, -- 1516
			useRegex = ____params_useRegex_32, -- 1517
			caseSensitive = ____params_caseSensitive_33, -- 1518
			includeContent = true, -- 1519
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1520
			limit = ____math_max_24_result_34, -- 1521
			offset = ____math_max_27( -- 1522
				0, -- 1522
				____math_floor_26(__TS__Number(____params_offset_25)) -- 1522
			), -- 1522
			groupByFile = params.groupByFile == true -- 1523
		})) -- 1523
		return ____awaiter_resolve(nil, result) -- 1523
	end) -- 1523
end -- 1510
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1528
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1528
		local last = shared.history[#shared.history] -- 1529
		if last ~= nil then -- 1529
			local result = execRes -- 1531
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1532
			appendToolResultMessage(shared, last) -- 1533
			emitAgentFinishEvent(shared, last) -- 1534
		end -- 1534
		__TS__Await(maybeCompressHistory(shared)) -- 1536
		persistHistoryState(shared) -- 1537
		shared.step = shared.step + 1 -- 1538
		return ____awaiter_resolve(nil, "main") -- 1538
	end) -- 1538
end -- 1528
local SearchDoraAPIAction = __TS__Class() -- 1543
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1543
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1543
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1544
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1544
		local last = shared.history[#shared.history] -- 1545
		if not last then -- 1545
			error( -- 1546
				__TS__New(Error, "no history"), -- 1546
				0 -- 1546
			) -- 1546
		end -- 1546
		emitAgentStartEvent(shared, last) -- 1547
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1547
	end) -- 1547
end -- 1544
function SearchDoraAPIAction.prototype.exec(self, input) -- 1551
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1551
		local params = input.params -- 1552
		local ____Tools_searchDoraAPI_43 = Tools.searchDoraAPI -- 1553
		local ____temp_39 = params.pattern or "" -- 1554
		local ____temp_40 = params.docSource or "api" -- 1555
		local ____temp_41 = input.useChineseResponse and "zh" or "en" -- 1556
		local ____temp_42 = params.programmingLanguage or "ts" -- 1557
		local ____math_min_38 = math.min -- 1558
		local ____math_max_37 = math.max -- 1558
		local ____params_limit_36 = params.limit -- 1558
		if ____params_limit_36 == nil then -- 1558
			____params_limit_36 = 8 -- 1558
		end -- 1558
		local result = __TS__Await(____Tools_searchDoraAPI_43({ -- 1553
			pattern = ____temp_39, -- 1554
			docSource = ____temp_40, -- 1555
			docLanguage = ____temp_41, -- 1556
			programmingLanguage = ____temp_42, -- 1557
			limit = ____math_min_38( -- 1558
				SEARCH_DORA_API_LIMIT_MAX, -- 1558
				____math_max_37( -- 1558
					1, -- 1558
					__TS__Number(____params_limit_36) -- 1558
				) -- 1558
			), -- 1558
			useRegex = params.useRegex, -- 1559
			caseSensitive = false, -- 1560
			includeContent = true, -- 1561
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1562
		})) -- 1562
		return ____awaiter_resolve(nil, result) -- 1562
	end) -- 1562
end -- 1551
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1567
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1567
		local last = shared.history[#shared.history] -- 1568
		if last ~= nil then -- 1568
			local result = execRes -- 1570
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1571
			appendToolResultMessage(shared, last) -- 1572
			emitAgentFinishEvent(shared, last) -- 1573
		end -- 1573
		__TS__Await(maybeCompressHistory(shared)) -- 1575
		persistHistoryState(shared) -- 1576
		shared.step = shared.step + 1 -- 1577
		return ____awaiter_resolve(nil, "main") -- 1577
	end) -- 1577
end -- 1567
local ListFilesAction = __TS__Class() -- 1582
ListFilesAction.name = "ListFilesAction" -- 1582
__TS__ClassExtends(ListFilesAction, Node) -- 1582
function ListFilesAction.prototype.prep(self, shared) -- 1583
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1583
		local last = shared.history[#shared.history] -- 1584
		if not last then -- 1584
			error( -- 1585
				__TS__New(Error, "no history"), -- 1585
				0 -- 1585
			) -- 1585
		end -- 1585
		emitAgentStartEvent(shared, last) -- 1586
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1586
	end) -- 1586
end -- 1583
function ListFilesAction.prototype.exec(self, input) -- 1590
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1590
		local params = input.params -- 1591
		local ____Tools_listFiles_50 = Tools.listFiles -- 1592
		local ____input_workDir_47 = input.workDir -- 1593
		local ____temp_48 = params.path or "" -- 1594
		local ____params_globs_49 = params.globs -- 1595
		local ____math_max_46 = math.max -- 1596
		local ____math_floor_45 = math.floor -- 1596
		local ____params_maxEntries_44 = params.maxEntries -- 1596
		if ____params_maxEntries_44 == nil then -- 1596
			____params_maxEntries_44 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1596
		end -- 1596
		local result = ____Tools_listFiles_50({ -- 1592
			workDir = ____input_workDir_47, -- 1593
			path = ____temp_48, -- 1594
			globs = ____params_globs_49, -- 1595
			maxEntries = ____math_max_46( -- 1596
				1, -- 1596
				____math_floor_45(__TS__Number(____params_maxEntries_44)) -- 1596
			) -- 1596
		}) -- 1596
		return ____awaiter_resolve(nil, result) -- 1596
	end) -- 1596
end -- 1590
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1601
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1601
		local last = shared.history[#shared.history] -- 1602
		if last ~= nil then -- 1602
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1604
			appendToolResultMessage(shared, last) -- 1605
			emitAgentFinishEvent(shared, last) -- 1606
		end -- 1606
		__TS__Await(maybeCompressHistory(shared)) -- 1608
		persistHistoryState(shared) -- 1609
		shared.step = shared.step + 1 -- 1610
		return ____awaiter_resolve(nil, "main") -- 1610
	end) -- 1610
end -- 1601
local DeleteFileAction = __TS__Class() -- 1615
DeleteFileAction.name = "DeleteFileAction" -- 1615
__TS__ClassExtends(DeleteFileAction, Node) -- 1615
function DeleteFileAction.prototype.prep(self, shared) -- 1616
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1616
		local last = shared.history[#shared.history] -- 1617
		if not last then -- 1617
			error( -- 1618
				__TS__New(Error, "no history"), -- 1618
				0 -- 1618
			) -- 1618
		end -- 1618
		emitAgentStartEvent(shared, last) -- 1619
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1620
		if __TS__StringTrim(targetFile) == "" then -- 1620
			error( -- 1623
				__TS__New(Error, "missing target_file"), -- 1623
				0 -- 1623
			) -- 1623
		end -- 1623
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1623
	end) -- 1623
end -- 1616
function DeleteFileAction.prototype.exec(self, input) -- 1627
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1627
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1628
		if not result.success then -- 1628
			return ____awaiter_resolve(nil, result) -- 1628
		end -- 1628
		return ____awaiter_resolve(nil, { -- 1628
			success = true, -- 1636
			changed = true, -- 1637
			mode = "delete", -- 1638
			checkpointId = result.checkpointId, -- 1639
			checkpointSeq = result.checkpointSeq, -- 1640
			files = {{path = input.targetFile, op = "delete"}} -- 1641
		}) -- 1641
	end) -- 1641
end -- 1627
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1645
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1645
		local last = shared.history[#shared.history] -- 1646
		if last ~= nil then -- 1646
			last.result = execRes -- 1648
			appendToolResultMessage(shared, last) -- 1649
			emitAgentFinishEvent(shared, last) -- 1650
			local result = last.result -- 1651
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 1651
				emitAgentEvent(shared, { -- 1656
					type = "checkpoint_created", -- 1657
					sessionId = shared.sessionId, -- 1658
					taskId = shared.taskId, -- 1659
					step = shared.step + 1, -- 1660
					tool = "delete_file", -- 1661
					checkpointId = result.checkpointId, -- 1662
					checkpointSeq = result.checkpointSeq, -- 1663
					files = result.files -- 1664
				}) -- 1664
			end -- 1664
		end -- 1664
		__TS__Await(maybeCompressHistory(shared)) -- 1668
		persistHistoryState(shared) -- 1669
		shared.step = shared.step + 1 -- 1670
		return ____awaiter_resolve(nil, "main") -- 1670
	end) -- 1670
end -- 1645
local BuildAction = __TS__Class() -- 1675
BuildAction.name = "BuildAction" -- 1675
__TS__ClassExtends(BuildAction, Node) -- 1675
function BuildAction.prototype.prep(self, shared) -- 1676
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1676
		local last = shared.history[#shared.history] -- 1677
		if not last then -- 1677
			error( -- 1678
				__TS__New(Error, "no history"), -- 1678
				0 -- 1678
			) -- 1678
		end -- 1678
		emitAgentStartEvent(shared, last) -- 1679
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1679
	end) -- 1679
end -- 1676
function BuildAction.prototype.exec(self, input) -- 1683
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1683
		local params = input.params -- 1684
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1685
		return ____awaiter_resolve(nil, result) -- 1685
	end) -- 1685
end -- 1683
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1692
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1692
		local last = shared.history[#shared.history] -- 1693
		if last ~= nil then -- 1693
			last.result = execRes -- 1695
			appendToolResultMessage(shared, last) -- 1696
			emitAgentFinishEvent(shared, last) -- 1697
		end -- 1697
		__TS__Await(maybeCompressHistory(shared)) -- 1699
		persistHistoryState(shared) -- 1700
		shared.step = shared.step + 1 -- 1701
		return ____awaiter_resolve(nil, "main") -- 1701
	end) -- 1701
end -- 1692
local EditFileAction = __TS__Class() -- 1706
EditFileAction.name = "EditFileAction" -- 1706
__TS__ClassExtends(EditFileAction, Node) -- 1706
function EditFileAction.prototype.prep(self, shared) -- 1707
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1707
		local last = shared.history[#shared.history] -- 1708
		if not last then -- 1708
			error( -- 1709
				__TS__New(Error, "no history"), -- 1709
				0 -- 1709
			) -- 1709
		end -- 1709
		emitAgentStartEvent(shared, last) -- 1710
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1711
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1714
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1715
		if __TS__StringTrim(path) == "" then -- 1715
			error( -- 1716
				__TS__New(Error, "missing path"), -- 1716
				0 -- 1716
			) -- 1716
		end -- 1716
		return ____awaiter_resolve(nil, { -- 1716
			path = path, -- 1717
			oldStr = oldStr, -- 1717
			newStr = newStr, -- 1717
			taskId = shared.taskId, -- 1717
			workDir = shared.workingDir -- 1717
		}) -- 1717
	end) -- 1717
end -- 1707
function EditFileAction.prototype.exec(self, input) -- 1720
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1720
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1721
		if not readRes.success then -- 1721
			if input.oldStr ~= "" then -- 1721
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1721
			end -- 1721
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1726
			if not createRes.success then -- 1726
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1726
			end -- 1726
			return ____awaiter_resolve(nil, { -- 1726
				success = true, -- 1734
				changed = true, -- 1735
				mode = "create", -- 1736
				checkpointId = createRes.checkpointId, -- 1737
				checkpointSeq = createRes.checkpointSeq, -- 1738
				files = {{path = input.path, op = "create"}} -- 1739
			}) -- 1739
		end -- 1739
		if input.oldStr == "" then -- 1739
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1743
			if not overwriteRes.success then -- 1743
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 1743
			end -- 1743
			return ____awaiter_resolve(nil, { -- 1743
				success = true, -- 1751
				changed = true, -- 1752
				mode = "overwrite", -- 1753
				checkpointId = overwriteRes.checkpointId, -- 1754
				checkpointSeq = overwriteRes.checkpointSeq, -- 1755
				files = {{path = input.path, op = "write"}} -- 1756
			}) -- 1756
		end -- 1756
		local normalizedContent = normalizeLineEndings(readRes.content) -- 1761
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 1762
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 1763
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 1766
		if occurrences == 0 then -- 1766
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 1768
			if not indentTolerant.success then -- 1768
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 1768
			end -- 1768
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 1772
			if not applyRes.success then -- 1772
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1772
			end -- 1772
			return ____awaiter_resolve(nil, { -- 1772
				success = true, -- 1780
				changed = true, -- 1781
				mode = "replace_indent_tolerant", -- 1782
				checkpointId = applyRes.checkpointId, -- 1783
				checkpointSeq = applyRes.checkpointSeq, -- 1784
				files = {{path = input.path, op = "write"}} -- 1785
			}) -- 1785
		end -- 1785
		if occurrences > 1 then -- 1785
			return ____awaiter_resolve( -- 1785
				nil, -- 1785
				{ -- 1789
					success = false, -- 1789
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 1789
				} -- 1789
			) -- 1789
		end -- 1789
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 1793
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1794
		if not applyRes.success then -- 1794
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1794
		end -- 1794
		return ____awaiter_resolve(nil, { -- 1794
			success = true, -- 1802
			changed = true, -- 1803
			mode = "replace", -- 1804
			checkpointId = applyRes.checkpointId, -- 1805
			checkpointSeq = applyRes.checkpointSeq, -- 1806
			files = {{path = input.path, op = "write"}} -- 1807
		}) -- 1807
	end) -- 1807
end -- 1720
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1811
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1811
		local last = shared.history[#shared.history] -- 1812
		if last ~= nil then -- 1812
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1814
			last.result = execRes -- 1815
			appendToolResultMessage(shared, last) -- 1816
			emitAgentFinishEvent(shared, last) -- 1817
			local result = last.result -- 1818
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 1818
				emitAgentEvent(shared, { -- 1823
					type = "checkpoint_created", -- 1824
					sessionId = shared.sessionId, -- 1825
					taskId = shared.taskId, -- 1826
					step = shared.step + 1, -- 1827
					tool = last.tool, -- 1828
					checkpointId = result.checkpointId, -- 1829
					checkpointSeq = result.checkpointSeq, -- 1830
					files = result.files -- 1831
				}) -- 1831
			end -- 1831
		end -- 1831
		__TS__Await(maybeCompressHistory(shared)) -- 1835
		persistHistoryState(shared) -- 1836
		shared.step = shared.step + 1 -- 1837
		return ____awaiter_resolve(nil, "main") -- 1837
	end) -- 1837
end -- 1811
local EndNode = __TS__Class() -- 1842
EndNode.name = "EndNode" -- 1842
__TS__ClassExtends(EndNode, Node) -- 1842
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 1843
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1843
		return ____awaiter_resolve(nil, nil) -- 1843
	end) -- 1843
end -- 1843
local CodingAgentFlow = __TS__Class() -- 1848
CodingAgentFlow.name = "CodingAgentFlow" -- 1848
__TS__ClassExtends(CodingAgentFlow, Flow) -- 1848
function CodingAgentFlow.prototype.____constructor(self) -- 1849
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 1850
	local read = __TS__New(ReadFileAction, 1, 0) -- 1851
	local search = __TS__New(SearchFilesAction, 1, 0) -- 1852
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 1853
	local list = __TS__New(ListFilesAction, 1, 0) -- 1854
	local del = __TS__New(DeleteFileAction, 1, 0) -- 1855
	local build = __TS__New(BuildAction, 1, 0) -- 1856
	local edit = __TS__New(EditFileAction, 1, 0) -- 1857
	local done = __TS__New(EndNode, 1, 0) -- 1858
	main:on("read_file", read) -- 1860
	main:on("grep_files", search) -- 1861
	main:on("search_dora_api", searchDora) -- 1862
	main:on("glob_files", list) -- 1863
	main:on("delete_file", del) -- 1864
	main:on("build", build) -- 1865
	main:on("edit_file", edit) -- 1866
	main:on("done", done) -- 1867
	read:on("main", main) -- 1869
	search:on("main", main) -- 1870
	searchDora:on("main", main) -- 1871
	list:on("main", main) -- 1872
	del:on("main", main) -- 1873
	build:on("main", main) -- 1874
	edit:on("main", main) -- 1875
	Flow.prototype.____constructor(self, main) -- 1877
end -- 1849
local function emitAgentTaskFinishEvent(shared, success, message) -- 1881
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 1882
	emitAgentEvent(shared, { -- 1888
		type = "task_finished", -- 1889
		sessionId = shared.sessionId, -- 1890
		taskId = shared.taskId, -- 1891
		success = result.success, -- 1892
		message = result.message, -- 1893
		steps = result.steps -- 1894
	}) -- 1894
	return result -- 1896
end -- 1881
local function runCodingAgentAsync(options) -- 1899
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1899
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 1899
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 1899
		end -- 1899
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 1903
		if not llmConfigRes.success then -- 1903
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 1903
		end -- 1903
		local llmConfig = llmConfigRes.config -- 1909
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 1910
		if not taskRes.success then -- 1910
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 1910
		end -- 1910
		local compressor = __TS__New(MemoryCompressor, { -- 1917
			compressionThreshold = 0.8, -- 1918
			maxCompressionRounds = 3, -- 1919
			maxTokensPerCompression = 20000, -- 1920
			projectDir = options.workDir, -- 1921
			llmConfig = llmConfig, -- 1922
			promptPack = options.promptPack -- 1923
		}) -- 1923
		local persistedSession = compressor:getStorage():readSessionState() -- 1925
		local promptPack = compressor:getPromptPack() -- 1926
		local shared = { -- 1928
			sessionId = options.sessionId, -- 1929
			taskId = taskRes.taskId, -- 1930
			maxSteps = math.max( -- 1931
				1, -- 1931
				math.floor(options.maxSteps or 40) -- 1931
			), -- 1931
			llmMaxTry = math.max( -- 1932
				1, -- 1932
				math.floor(options.llmMaxTry or 3) -- 1932
			), -- 1932
			step = 0, -- 1933
			done = false, -- 1934
			stopToken = options.stopToken or ({stopped = false}), -- 1935
			response = "", -- 1936
			userQuery = options.prompt, -- 1937
			workingDir = options.workDir, -- 1938
			useChineseResponse = options.useChineseResponse == true, -- 1939
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 1940
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 1943
			llmConfig = llmConfig, -- 1948
			onEvent = options.onEvent, -- 1949
			promptPack = promptPack, -- 1950
			history = {}, -- 1951
			messages = persistedSession.messages, -- 1952
			memory = {lastConsolidatedMessageIndex = persistedSession.lastConsolidatedMessageIndex, compressor = compressor} -- 1954
		} -- 1954
		appendConversationMessage(shared, {role = "user", content = options.prompt}) -- 1959
		persistHistoryState(shared) -- 1963
		local ____try = __TS__AsyncAwaiter(function() -- 1963
			emitAgentEvent(shared, { -- 1966
				type = "task_started", -- 1967
				sessionId = shared.sessionId, -- 1968
				taskId = shared.taskId, -- 1969
				prompt = shared.userQuery, -- 1970
				workDir = shared.workingDir, -- 1971
				maxSteps = shared.maxSteps -- 1972
			}) -- 1972
			if shared.stopToken.stopped then -- 1972
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1975
				return ____awaiter_resolve( -- 1975
					nil, -- 1975
					emitAgentTaskFinishEvent( -- 1976
						shared, -- 1976
						false, -- 1976
						getCancelledReason(shared) -- 1976
					) -- 1976
				) -- 1976
			end -- 1976
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 1978
			local flow = __TS__New(CodingAgentFlow) -- 1979
			__TS__Await(flow:run(shared)) -- 1980
			if shared.stopToken.stopped then -- 1980
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1982
				return ____awaiter_resolve( -- 1982
					nil, -- 1982
					emitAgentTaskFinishEvent( -- 1983
						shared, -- 1983
						false, -- 1983
						getCancelledReason(shared) -- 1983
					) -- 1983
				) -- 1983
			end -- 1983
			if shared.error then -- 1983
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1986
				return ____awaiter_resolve( -- 1986
					nil, -- 1986
					emitAgentTaskFinishEvent(shared, false, shared.response and shared.response ~= "" and shared.response or shared.error) -- 1987
				) -- 1987
			end -- 1987
			Tools.setTaskStatus(shared.taskId, "DONE") -- 1990
			return ____awaiter_resolve( -- 1990
				nil, -- 1990
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 1991
			) -- 1991
		end) -- 1991
		__TS__Await(____try.catch( -- 1965
			____try, -- 1965
			function(____, e) -- 1965
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1994
				return ____awaiter_resolve( -- 1994
					nil, -- 1994
					emitAgentTaskFinishEvent( -- 1995
						shared, -- 1995
						false, -- 1995
						tostring(e) -- 1995
					) -- 1995
				) -- 1995
			end -- 1995
		)) -- 1995
	end) -- 1995
end -- 1899
function ____exports.runCodingAgent(options, callback) -- 1999
	local ____self_51 = runCodingAgentAsync(options) -- 1999
	____self_51["then"]( -- 1999
		____self_51, -- 1999
		function(____, result) return callback(result) end -- 2000
	) -- 2000
end -- 1999
return ____exports -- 1999