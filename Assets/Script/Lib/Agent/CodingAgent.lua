-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
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
local emitAgentEvent, truncateText, getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, persistHistoryState, applyCompressedSessionState, buildAgentSystemPrompt, buildXmlDecisionInstruction, emitAgentTaskFinishEvent, SEARCH_DORA_API_LIMIT_MAX -- 1
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
function emitAgentEvent(shared, event) -- 189
	if shared.onEvent then -- 189
		do -- 189
			local function ____catch(____error) -- 189
				Log( -- 194
					"Error", -- 194
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 194
				) -- 194
			end -- 194
			local ____try, ____hasReturned = pcall(function() -- 194
				shared:onEvent(event) -- 192
			end) -- 192
			if not ____try then -- 192
				____catch(____hasReturned) -- 192
			end -- 192
		end -- 192
	end -- 192
end -- 192
function truncateText(text, maxLen) -- 427
	if #text <= maxLen then -- 427
		return text -- 428
	end -- 428
	local nextPos = utf8.offset(text, maxLen + 1) -- 429
	if nextPos == nil then -- 429
		return text -- 430
	end -- 430
	return string.sub(text, 1, nextPos - 1) .. "..." -- 431
end -- 431
function getReplyLanguageDirective(shared) -- 441
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 442
end -- 442
function replacePromptVars(template, vars) -- 447
	local output = template -- 448
	for key in pairs(vars) do -- 449
		output = table.concat( -- 450
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 450
			vars[key] or "" or "," -- 450
		) -- 450
	end -- 450
	return output -- 452
end -- 452
function getDecisionToolDefinitions(shared) -- 576
	local base = replacePromptVars( -- 577
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 578
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 579
	) -- 579
	if (shared and shared.decisionMode) ~= "xml" then -- 579
		return base -- 582
	end -- 582
	return base .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 584
end -- 584
function persistHistoryState(shared) -- 833
	shared.memory.compressor:getStorage():writeSessionState(shared.messages) -- 834
end -- 834
function applyCompressedSessionState(shared, compressedCount, carryMessage) -- 837
	local remainingMessages = __TS__ArraySlice(shared.messages, compressedCount) -- 842
	if carryMessage then -- 842
		__TS__ArrayUnshift( -- 844
			remainingMessages, -- 844
			__TS__ObjectAssign( -- 844
				{}, -- 844
				carryMessage, -- 845
				{timestamp = carryMessage.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 844
			) -- 844
		) -- 844
	end -- 844
	shared.messages = remainingMessages -- 849
end -- 849
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1172
	if includeToolDefinitions == nil then -- 1172
		includeToolDefinitions = false -- 1172
	end -- 1172
	local sections = { -- 1173
		shared.promptPack.agentIdentityPrompt, -- 1174
		getReplyLanguageDirective(shared) -- 1175
	} -- 1175
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1177
	if memoryContext ~= "" then -- 1177
		sections[#sections + 1] = memoryContext -- 1179
	end -- 1179
	if includeToolDefinitions then -- 1179
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1182
		if shared.decisionMode == "xml" then -- 1182
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1184
		end -- 1184
	end -- 1184
	return table.concat(sections, "\n\n") -- 1187
end -- 1187
function buildXmlDecisionInstruction(shared, feedback) -- 1274
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 1275
end -- 1275
function emitAgentTaskFinishEvent(shared, success, message) -- 2198
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 2199
	emitAgentEvent(shared, { -- 2205
		type = "task_finished", -- 2206
		sessionId = shared.sessionId, -- 2207
		taskId = shared.taskId, -- 2208
		success = result.success, -- 2209
		message = result.message, -- 2210
		steps = result.steps -- 2211
	}) -- 2211
	return result -- 2213
end -- 2213
local function isRecord(value) -- 10
	return type(value) == "table" -- 11
end -- 10
local function isArray(value) -- 14
	return __TS__ArrayIsArray(value) -- 15
end -- 14
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 48
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 140
local HISTORY_READ_FILE_MAX_LINES = 300 -- 141
local READ_FILE_DEFAULT_LIMIT = 300 -- 142
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 143
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 144
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 145
SEARCH_DORA_API_LIMIT_MAX = 20 -- 146
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 147
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 148
local SEARCH_PREVIEW_CONTEXT = 80 -- 149
local function emitAgentStartEvent(shared, action) -- 199
	emitAgentEvent(shared, { -- 200
		type = "tool_started", -- 201
		sessionId = shared.sessionId, -- 202
		taskId = shared.taskId, -- 203
		step = action.step, -- 204
		tool = action.tool -- 205
	}) -- 205
end -- 199
local function emitAgentFinishEvent(shared, action) -- 209
	emitAgentEvent(shared, { -- 210
		type = "tool_finished", -- 211
		sessionId = shared.sessionId, -- 212
		taskId = shared.taskId, -- 213
		step = action.step, -- 214
		tool = action.tool, -- 215
		result = action.result or ({}) -- 216
	}) -- 216
end -- 209
local function getMemoryCompressionStartReason(shared) -- 220
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 221
end -- 220
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 226
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 227
end -- 226
local function getMemoryCompressionFailureReason(shared, ____error) -- 232
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 233
end -- 232
local function summarizeHistoryEntryPreview(text, maxChars) -- 238
	if maxChars == nil then -- 238
		maxChars = 180 -- 238
	end -- 238
	local trimmed = __TS__StringTrim(text) -- 239
	if trimmed == "" then -- 239
		return "" -- 240
	end -- 240
	return truncateText(trimmed, maxChars) -- 241
end -- 238
local function getCancelledReason(shared) -- 244
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 244
		return shared.stopToken.reason -- 245
	end -- 245
	return shared.useChineseResponse and "已取消" or "cancelled" -- 246
end -- 244
local function getMaxStepsReachedReason(shared) -- 249
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 250
end -- 249
local function getFailureSummaryFallback(shared, ____error) -- 255
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 256
end -- 255
local function finalizeAgentFailure(shared, ____error) -- 261
	if shared.stopToken.stopped then -- 261
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 263
		return emitAgentTaskFinishEvent( -- 264
			shared, -- 264
			false, -- 264
			getCancelledReason(shared) -- 264
		) -- 264
	end -- 264
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 266
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 267
end -- 261
local function getPromptCommand(prompt) -- 270
	local trimmed = __TS__StringTrim(prompt) -- 271
	if trimmed == "/compact" then -- 271
		return "compact" -- 272
	end -- 272
	if trimmed == "/reset" then -- 272
		return "reset" -- 273
	end -- 273
	return nil -- 274
end -- 270
function ____exports.truncateAgentUserPrompt(prompt) -- 277
	if not prompt then -- 277
		return "" -- 278
	end -- 278
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 278
		return prompt -- 279
	end -- 279
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 280
	if offset == nil then -- 280
		return prompt -- 281
	end -- 281
	return string.sub(prompt, 1, offset - 1) -- 282
end -- 277
local function canWriteStepLLMDebug(shared, stepId) -- 285
	if stepId == nil then -- 285
		stepId = shared.step + 1 -- 285
	end -- 285
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 286
end -- 285
local function ensureDirRecursive(dir) -- 293
	if not dir then -- 293
		return false -- 294
	end -- 294
	if Content:exist(dir) then -- 294
		return Content:isdir(dir) -- 295
	end -- 295
	local parent = Path:getPath(dir) -- 296
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 296
		return false -- 298
	end -- 298
	return Content:mkdir(dir) -- 300
end -- 293
local function encodeDebugJSON(value) -- 303
	local text, err = safeJsonEncode(value) -- 304
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 305
end -- 303
local function getStepLLMDebugDir(shared) -- 308
	return Path( -- 309
		shared.workingDir, -- 310
		".agent", -- 311
		tostring(shared.sessionId), -- 312
		tostring(shared.taskId) -- 313
	) -- 313
end -- 308
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 317
	return Path( -- 318
		getStepLLMDebugDir(shared), -- 318
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 318
	) -- 318
end -- 317
local function getLatestStepLLMDebugSeq(shared, stepId) -- 321
	if not canWriteStepLLMDebug(shared, stepId) then -- 321
		return 0 -- 322
	end -- 322
	local dir = getStepLLMDebugDir(shared) -- 323
	if not Content:exist(dir) or not Content:isdir(dir) then -- 323
		return 0 -- 324
	end -- 324
	local latest = 0 -- 325
	for ____, file in ipairs(Content:getFiles(dir)) do -- 326
		do -- 326
			local name = Path:getFilename(file) -- 327
			local seqText = string.match( -- 328
				name, -- 328
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 328
			) -- 328
			if seqText ~= nil then -- 328
				latest = math.max( -- 330
					latest, -- 330
					tonumber(seqText) -- 330
				) -- 330
				goto __continue39 -- 331
			end -- 331
			local legacyMatch = string.match( -- 333
				name, -- 333
				("^" .. tostring(stepId)) .. "_in%.md$" -- 333
			) -- 333
			if legacyMatch ~= nil then -- 333
				latest = math.max(latest, 1) -- 335
			end -- 335
		end -- 335
		::__continue39:: -- 335
	end -- 335
	return latest -- 338
end -- 321
local function writeStepLLMDebugFile(path, content) -- 341
	if not Content:save(path, content) then -- 341
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 343
		return false -- 344
	end -- 344
	return true -- 346
end -- 341
local function createStepLLMDebugPair(shared, stepId, inContent) -- 349
	if not canWriteStepLLMDebug(shared, stepId) then -- 349
		return 0 -- 350
	end -- 350
	local dir = getStepLLMDebugDir(shared) -- 351
	if not ensureDirRecursive(dir) then -- 351
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 353
		return 0 -- 354
	end -- 354
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 356
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 357
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 358
	if not writeStepLLMDebugFile(inPath, inContent) then -- 358
		return 0 -- 360
	end -- 360
	writeStepLLMDebugFile(outPath, "") -- 362
	return seq -- 363
end -- 349
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 366
	if not canWriteStepLLMDebug(shared, stepId) then -- 366
		return -- 367
	end -- 367
	local dir = getStepLLMDebugDir(shared) -- 368
	if not ensureDirRecursive(dir) then -- 368
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 370
		return -- 371
	end -- 371
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 373
	if latestSeq <= 0 then -- 373
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 375
		writeStepLLMDebugFile(outPath, content) -- 376
		return -- 377
	end -- 377
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 379
	writeStepLLMDebugFile(outPath, content) -- 380
end -- 366
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 383
	if not canWriteStepLLMDebug(shared, stepId) then -- 383
		return -- 384
	end -- 384
	local sections = { -- 385
		"# LLM Input", -- 386
		"session_id: " .. tostring(shared.sessionId), -- 387
		"task_id: " .. tostring(shared.taskId), -- 388
		"step_id: " .. tostring(stepId), -- 389
		"phase: " .. phase, -- 390
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 391
		"## Options", -- 392
		"```json", -- 393
		encodeDebugJSON(options), -- 394
		"```" -- 395
	} -- 395
	do -- 395
		local i = 0 -- 397
		while i < #messages do -- 397
			local message = messages[i + 1] -- 398
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 399
			sections[#sections + 1] = encodeDebugJSON(message) -- 400
			i = i + 1 -- 397
		end -- 397
	end -- 397
	createStepLLMDebugPair( -- 402
		shared, -- 402
		stepId, -- 402
		table.concat(sections, "\n") -- 402
	) -- 402
end -- 383
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 405
	if not canWriteStepLLMDebug(shared, stepId) then -- 405
		return -- 406
	end -- 406
	local ____array_0 = __TS__SparseArrayNew( -- 406
		"# LLM Output", -- 408
		"session_id: " .. tostring(shared.sessionId), -- 409
		"task_id: " .. tostring(shared.taskId), -- 410
		"step_id: " .. tostring(stepId), -- 411
		"phase: " .. phase, -- 412
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 413
		table.unpack(meta and ({ -- 414
			"## Meta", -- 414
			"```json", -- 414
			encodeDebugJSON(meta), -- 414
			"```" -- 414
		}) or ({})) -- 414
	) -- 414
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 414
	local sections = {__TS__SparseArraySpread(____array_0)} -- 407
	updateLatestStepLLMDebugOutput( -- 418
		shared, -- 418
		stepId, -- 418
		table.concat(sections, "\n") -- 418
	) -- 418
end -- 405
local function toJson(value) -- 421
	local text, err = safeJsonEncode(value) -- 422
	if text ~= nil then -- 422
		return text -- 423
	end -- 423
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 424
end -- 421
local function utf8TakeHead(text, maxChars) -- 434
	if maxChars <= 0 or text == "" then -- 434
		return "" -- 435
	end -- 435
	local nextPos = utf8.offset(text, maxChars + 1) -- 436
	if nextPos == nil then -- 436
		return text -- 437
	end -- 437
	return string.sub(text, 1, nextPos - 1) -- 438
end -- 434
local function limitReadContentForHistory(content, tool) -- 455
	local lines = __TS__StringSplit(content, "\n") -- 456
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 457
	local limitedByLines = overLineLimit and table.concat( -- 458
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 459
		"\n" -- 459
	) or content -- 459
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 459
		return content -- 462
	end -- 462
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 464
	local reasons = {} -- 467
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 467
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 468
	end -- 468
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 468
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 469
	end -- 469
	local hint = "Narrow the requested line range." -- 470
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 471
end -- 455
local function summarizeEditTextParamForHistory(value, key) -- 474
	if type(value) ~= "string" then -- 474
		return nil -- 475
	end -- 475
	local text = value -- 476
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 477
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 478
end -- 474
local function sanitizeReadResultForHistory(tool, result) -- 486
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 486
		return result -- 488
	end -- 488
	local clone = {} -- 490
	for key in pairs(result) do -- 491
		clone[key] = result[key] -- 492
	end -- 492
	clone.content = limitReadContentForHistory(result.content, tool) -- 494
	return clone -- 495
end -- 486
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 498
	local shown = math.min(#items, maxItems) -- 502
	local out = {} -- 503
	do -- 503
		local i = 0 -- 504
		while i < shown do -- 504
			local row = items[i + 1] -- 505
			out[#out + 1] = { -- 506
				file = row.file, -- 507
				line = row.line, -- 508
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 509
			} -- 509
			i = i + 1 -- 504
		end -- 504
	end -- 504
	return out -- 514
end -- 498
local function sanitizeSearchResultForHistory(tool, result) -- 517
	if result.success ~= true or not isArray(result.results) then -- 517
		return result -- 521
	end -- 521
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 521
		return result -- 522
	end -- 522
	local clone = {} -- 523
	for key in pairs(result) do -- 524
		clone[key] = result[key] -- 525
	end -- 525
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 527
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 528
	if tool == "grep_files" and isArray(result.groupedResults) then -- 528
		local grouped = result.groupedResults -- 533
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 534
		local sanitizedGroups = {} -- 535
		do -- 535
			local i = 0 -- 536
			while i < shown do -- 536
				local row = grouped[i + 1] -- 537
				sanitizedGroups[#sanitizedGroups + 1] = { -- 538
					file = row.file, -- 539
					totalMatches = row.totalMatches, -- 540
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 541
				} -- 541
				i = i + 1 -- 536
			end -- 536
		end -- 536
		clone.groupedResults = sanitizedGroups -- 546
	end -- 546
	return clone -- 548
end -- 517
local function sanitizeListFilesResultForHistory(result) -- 551
	if result.success ~= true or not isArray(result.files) then -- 551
		return result -- 552
	end -- 552
	local clone = {} -- 553
	for key in pairs(result) do -- 554
		clone[key] = result[key] -- 555
	end -- 555
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 557
	return clone -- 558
end -- 551
local function sanitizeActionParamsForHistory(tool, params) -- 561
	if tool ~= "edit_file" then -- 561
		return params -- 562
	end -- 562
	local clone = {} -- 563
	for key in pairs(params) do -- 564
		if key == "old_str" then -- 564
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 566
		elseif key == "new_str" then -- 566
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 568
		else -- 568
			clone[key] = params[key] -- 570
		end -- 570
	end -- 570
	return clone -- 573
end -- 561
local function maybeCompressHistory(shared) -- 593
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 593
		local ____shared_5 = shared -- 594
		local memory = ____shared_5.memory -- 594
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 595
		local changed = false -- 596
		do -- 596
			local round = 0 -- 597
			while round < maxRounds do -- 597
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 598
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 602
				if not memory.compressor:shouldCompress(shared.messages, systemPrompt, toolDefinitions) then -- 602
					if changed then -- 602
						persistHistoryState(shared) -- 611
					end -- 611
					return ____awaiter_resolve(nil) -- 611
				end -- 611
				local compressionRound = round + 1 -- 615
				shared.step = shared.step + 1 -- 616
				local stepId = shared.step -- 617
				local pendingMessages = #shared.messages -- 618
				emitAgentEvent( -- 619
					shared, -- 619
					{ -- 619
						type = "memory_compression_started", -- 620
						sessionId = shared.sessionId, -- 621
						taskId = shared.taskId, -- 622
						step = stepId, -- 623
						tool = "compress_memory", -- 624
						reason = getMemoryCompressionStartReason(shared), -- 625
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 626
					} -- 626
				) -- 626
				local result = __TS__Await(memory.compressor:compress( -- 632
					shared.messages, -- 633
					systemPrompt, -- 634
					toolDefinitions, -- 635
					shared.llmOptions, -- 636
					shared.llmMaxTry, -- 637
					shared.decisionMode, -- 638
					{ -- 639
						onInput = function(____, phase, messages, options) -- 640
							saveStepLLMDebugInput( -- 641
								shared, -- 641
								stepId, -- 641
								phase, -- 641
								messages, -- 641
								options -- 641
							) -- 641
						end, -- 640
						onOutput = function(____, phase, text, meta) -- 643
							saveStepLLMDebugOutput( -- 644
								shared, -- 644
								stepId, -- 644
								phase, -- 644
								text, -- 644
								meta -- 644
							) -- 644
						end -- 643
					} -- 643
				)) -- 643
				if not (result and result.success and result.compressedCount > 0) then -- 643
					emitAgentEvent( -- 649
						shared, -- 649
						{ -- 649
							type = "memory_compression_finished", -- 650
							sessionId = shared.sessionId, -- 651
							taskId = shared.taskId, -- 652
							step = stepId, -- 653
							tool = "compress_memory", -- 654
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 655
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 659
						} -- 659
					) -- 659
					if changed then -- 659
						persistHistoryState(shared) -- 667
					end -- 667
					return ____awaiter_resolve(nil) -- 667
				end -- 667
				emitAgentEvent( -- 671
					shared, -- 671
					{ -- 671
						type = "memory_compression_finished", -- 672
						sessionId = shared.sessionId, -- 673
						taskId = shared.taskId, -- 674
						step = stepId, -- 675
						tool = "compress_memory", -- 676
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 677
						result = { -- 678
							success = true, -- 679
							round = compressionRound, -- 680
							compressedCount = result.compressedCount, -- 681
							historyEntryPreview = summarizeHistoryEntryPreview(result.historyEntry) -- 682
						} -- 682
					} -- 682
				) -- 682
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 685
				changed = true -- 686
				Log( -- 687
					"Info", -- 687
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 687
				) -- 687
				round = round + 1 -- 597
			end -- 597
		end -- 597
		if changed then -- 597
			persistHistoryState(shared) -- 690
		end -- 690
	end) -- 690
end -- 593
local function compactAllHistory(shared) -- 694
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 694
		local ____shared_12 = shared -- 695
		local memory = ____shared_12.memory -- 695
		local rounds = 0 -- 696
		local totalCompressed = 0 -- 697
		while #shared.messages > 0 do -- 697
			if shared.stopToken.stopped then -- 697
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 700
				return ____awaiter_resolve( -- 700
					nil, -- 700
					emitAgentTaskFinishEvent( -- 701
						shared, -- 701
						false, -- 701
						getCancelledReason(shared) -- 701
					) -- 701
				) -- 701
			end -- 701
			local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 703
			local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 704
			rounds = rounds + 1 -- 707
			shared.step = shared.step + 1 -- 708
			local stepId = shared.step -- 709
			local pendingMessages = #shared.messages -- 710
			emitAgentEvent( -- 711
				shared, -- 711
				{ -- 711
					type = "memory_compression_started", -- 712
					sessionId = shared.sessionId, -- 713
					taskId = shared.taskId, -- 714
					step = stepId, -- 715
					tool = "compress_memory", -- 716
					reason = getMemoryCompressionStartReason(shared), -- 717
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 718
				} -- 718
			) -- 718
			local result = __TS__Await(memory.compressor:compress( -- 725
				shared.messages, -- 726
				systemPrompt, -- 727
				toolDefinitions, -- 728
				shared.llmOptions, -- 729
				shared.llmMaxTry, -- 730
				shared.decisionMode, -- 731
				{ -- 732
					onInput = function(____, phase, messages, options) -- 733
						saveStepLLMDebugInput( -- 734
							shared, -- 734
							stepId, -- 734
							phase, -- 734
							messages, -- 734
							options -- 734
						) -- 734
					end, -- 733
					onOutput = function(____, phase, text, meta) -- 736
						saveStepLLMDebugOutput( -- 737
							shared, -- 737
							stepId, -- 737
							phase, -- 737
							text, -- 737
							meta -- 737
						) -- 737
					end -- 736
				}, -- 736
				"budget_max" -- 740
			)) -- 740
			if not (result and result.success and result.compressedCount > 0) then -- 740
				emitAgentEvent( -- 743
					shared, -- 743
					{ -- 743
						type = "memory_compression_finished", -- 744
						sessionId = shared.sessionId, -- 745
						taskId = shared.taskId, -- 746
						step = stepId, -- 747
						tool = "compress_memory", -- 748
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 749
						result = { -- 753
							success = false, -- 754
							rounds = rounds, -- 755
							error = result and result.error or "compression returned no changes", -- 756
							compressedCount = result and result.compressedCount or 0, -- 757
							fullCompaction = true -- 758
						} -- 758
					} -- 758
				) -- 758
				return ____awaiter_resolve( -- 758
					nil, -- 758
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 761
				) -- 761
			end -- 761
			emitAgentEvent( -- 766
				shared, -- 766
				{ -- 766
					type = "memory_compression_finished", -- 767
					sessionId = shared.sessionId, -- 768
					taskId = shared.taskId, -- 769
					step = stepId, -- 770
					tool = "compress_memory", -- 771
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 772
					result = { -- 773
						success = true, -- 774
						round = rounds, -- 775
						compressedCount = result.compressedCount, -- 776
						historyEntryPreview = summarizeHistoryEntryPreview(result.historyEntry), -- 777
						fullCompaction = true -- 778
					} -- 778
				} -- 778
			) -- 778
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 781
			totalCompressed = totalCompressed + result.compressedCount -- 782
			persistHistoryState(shared) -- 783
			Log( -- 784
				"Info", -- 784
				((("[Memory] Full compaction compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 784
			) -- 784
		end -- 784
		Tools.setTaskStatus(shared.taskId, "DONE") -- 786
		return ____awaiter_resolve( -- 786
			nil, -- 786
			emitAgentTaskFinishEvent( -- 787
				shared, -- 788
				true, -- 789
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 790
			) -- 790
		) -- 790
	end) -- 790
end -- 694
local function resetSessionHistory(shared) -- 796
	shared.messages = {} -- 797
	persistHistoryState(shared) -- 798
	Tools.setTaskStatus(shared.taskId, "DONE") -- 799
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 800
end -- 796
local function isKnownToolName(name) -- 809
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 810
end -- 809
local function getFinishMessage(params, fallback) -- 820
	if fallback == nil then -- 820
		fallback = "" -- 820
	end -- 820
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 820
		return __TS__StringTrim(params.message) -- 822
	end -- 822
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 822
		return __TS__StringTrim(params.response) -- 825
	end -- 825
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 825
		return __TS__StringTrim(params.summary) -- 828
	end -- 828
	return __TS__StringTrim(fallback) -- 830
end -- 820
local function appendConversationMessage(shared, message) -- 852
	local ____shared_messages_21 = shared.messages -- 852
	____shared_messages_21[#____shared_messages_21 + 1] = __TS__ObjectAssign( -- 853
		{}, -- 853
		message, -- 854
		{ -- 853
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 855
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 856
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 857
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 858
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 859
		} -- 859
	) -- 859
end -- 852
local function ensureToolCallId(toolCallId) -- 863
	if toolCallId and toolCallId ~= "" then -- 863
		return toolCallId -- 864
	end -- 864
	return createLocalToolCallId() -- 865
end -- 863
local function appendToolResultMessage(shared, action) -- 868
	appendConversationMessage( -- 869
		shared, -- 869
		{ -- 869
			role = "tool", -- 870
			tool_call_id = action.toolCallId, -- 871
			name = action.tool, -- 872
			content = action.result and toJson(action.result) or "" -- 873
		} -- 873
	) -- 873
end -- 868
local function parseXMLToolCallObjectFromText(text) -- 877
	local children = parseXMLObjectFromText(text, "tool_call") -- 878
	if not children.success then -- 878
		return children -- 879
	end -- 879
	local rawObj = children.obj -- 880
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 881
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 882
	if not params.success then -- 882
		return {success = false, message = params.message} -- 886
	end -- 886
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 888
end -- 877
local function llm(shared, messages, phase) -- 907
	if phase == nil then -- 907
		phase = "decision_xml" -- 910
	end -- 910
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 910
		local stepId = shared.step + 1 -- 912
		saveStepLLMDebugInput( -- 913
			shared, -- 913
			stepId, -- 913
			phase, -- 913
			messages, -- 913
			shared.llmOptions -- 913
		) -- 913
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 914
		if res.success then -- 914
			local ____opt_26 = res.response.choices -- 914
			local ____opt_24 = ____opt_26 and ____opt_26[1] -- 914
			local ____opt_22 = ____opt_24 and ____opt_24.message -- 914
			local text = ____opt_22 and ____opt_22.content -- 916
			if text then -- 916
				saveStepLLMDebugOutput( -- 918
					shared, -- 918
					stepId, -- 918
					phase, -- 918
					text, -- 918
					{success = true} -- 918
				) -- 918
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 918
			else -- 918
				saveStepLLMDebugOutput( -- 921
					shared, -- 921
					stepId, -- 921
					phase, -- 921
					"empty LLM response", -- 921
					{success = false} -- 921
				) -- 921
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 921
			end -- 921
		else -- 921
			saveStepLLMDebugOutput( -- 925
				shared, -- 925
				stepId, -- 925
				phase, -- 925
				res.raw or res.message, -- 925
				{success = false} -- 925
			) -- 925
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 925
		end -- 925
	end) -- 925
end -- 907
local function parseDecisionObject(rawObj) -- 942
	if type(rawObj.tool) ~= "string" then -- 942
		return {success = false, message = "missing tool"} -- 943
	end -- 943
	local tool = rawObj.tool -- 944
	if not isKnownToolName(tool) then -- 944
		return {success = false, message = "unknown tool: " .. tool} -- 946
	end -- 946
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 948
	if tool ~= "finish" and (not reason or reason == "") then -- 948
		return {success = false, message = tool .. " requires top-level reason"} -- 952
	end -- 952
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 954
	return {success = true, tool = tool, params = params, reason = reason} -- 955
end -- 942
local function parseDecisionToolCall(functionName, rawObj) -- 963
	if not isKnownToolName(functionName) then -- 963
		return {success = false, message = "unknown tool: " .. functionName} -- 965
	end -- 965
	if rawObj == nil or rawObj == nil then -- 965
		return {success = true, tool = functionName, params = {}} -- 968
	end -- 968
	if not isRecord(rawObj) then -- 968
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 971
	end -- 971
	return {success = true, tool = functionName, params = rawObj} -- 973
end -- 963
local function getDecisionPath(params) -- 980
	if type(params.path) == "string" then -- 980
		return __TS__StringTrim(params.path) -- 981
	end -- 981
	if type(params.target_file) == "string" then -- 981
		return __TS__StringTrim(params.target_file) -- 982
	end -- 982
	return "" -- 983
end -- 980
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 986
	local num = __TS__Number(value) -- 987
	if not __TS__NumberIsFinite(num) then -- 987
		num = fallback -- 988
	end -- 988
	num = math.floor(num) -- 989
	if num < minValue then -- 989
		num = minValue -- 990
	end -- 990
	if maxValue ~= nil and num > maxValue then -- 990
		num = maxValue -- 991
	end -- 991
	return num -- 992
end -- 986
local function validateDecision(tool, params) -- 995
	if tool == "finish" then -- 995
		local message = getFinishMessage(params) -- 1000
		if message == "" then -- 1000
			return {success = false, message = "finish requires params.message"} -- 1001
		end -- 1001
		params.message = message -- 1002
		return {success = true, params = params} -- 1003
	end -- 1003
	if tool == "read_file" then -- 1003
		local path = getDecisionPath(params) -- 1007
		if path == "" then -- 1007
			return {success = false, message = "read_file requires path"} -- 1008
		end -- 1008
		params.path = path -- 1009
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 1010
		local ____params_endLine_28 = params.endLine -- 1011
		if ____params_endLine_28 == nil then -- 1011
			____params_endLine_28 = READ_FILE_DEFAULT_LIMIT -- 1011
		end -- 1011
		local endLineRaw = ____params_endLine_28 -- 1011
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 1012
		params.startLine = startLine -- 1013
		params.endLine = endLine -- 1014
		return {success = true, params = params} -- 1015
	end -- 1015
	if tool == "edit_file" then -- 1015
		local path = getDecisionPath(params) -- 1019
		if path == "" then -- 1019
			return {success = false, message = "edit_file requires path"} -- 1020
		end -- 1020
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1021
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1022
		params.path = path -- 1023
		params.old_str = oldStr -- 1024
		params.new_str = newStr -- 1025
		return {success = true, params = params} -- 1026
	end -- 1026
	if tool == "delete_file" then -- 1026
		local targetFile = getDecisionPath(params) -- 1030
		if targetFile == "" then -- 1030
			return {success = false, message = "delete_file requires target_file"} -- 1031
		end -- 1031
		params.target_file = targetFile -- 1032
		return {success = true, params = params} -- 1033
	end -- 1033
	if tool == "grep_files" then -- 1033
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1037
		if pattern == "" then -- 1037
			return {success = false, message = "grep_files requires pattern"} -- 1038
		end -- 1038
		params.pattern = pattern -- 1039
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1040
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1041
		return {success = true, params = params} -- 1042
	end -- 1042
	if tool == "search_dora_api" then -- 1042
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1046
		if pattern == "" then -- 1046
			return {success = false, message = "search_dora_api requires pattern"} -- 1047
		end -- 1047
		params.pattern = pattern -- 1048
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1049
		return {success = true, params = params} -- 1050
	end -- 1050
	if tool == "glob_files" then -- 1050
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1054
		return {success = true, params = params} -- 1055
	end -- 1055
	if tool == "build" then -- 1055
		local path = getDecisionPath(params) -- 1059
		if path ~= "" then -- 1059
			params.path = path -- 1061
		end -- 1061
		return {success = true, params = params} -- 1063
	end -- 1063
	return {success = true, params = params} -- 1066
end -- 995
local function createFunctionToolSchema(name, description, properties, required) -- 1069
	if required == nil then -- 1069
		required = {} -- 1073
	end -- 1073
	local parameters = {type = "object", properties = properties} -- 1075
	if #required > 0 then -- 1075
		parameters.required = required -- 1080
	end -- 1080
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1082
end -- 1069
local function buildDecisionToolSchema() -- 1092
	return { -- 1093
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Parameters: path, startLine(optional), endLine(optional). Line numbering starts with 1. startLine defaults to 1 and endLine defaults to 300.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "1-based starting line number. Defaults to 1."}, endLine = {type = "number", description = "1-based ending line number. Defaults to 300."}}, {"path"}), -- 1094
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 1104
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1114
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1122
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1126
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1127
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1128
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1129
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1130
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1131
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1132
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1133
		}, {"pattern"}), -- 1133
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1137
		createFunctionToolSchema( -- 1146
			"search_dora_api", -- 1147
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1147
			{ -- 1149
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1150
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1151
				programmingLanguage = {type = "string", enum = { -- 1152
					"ts", -- 1154
					"tsx", -- 1154
					"lua", -- 1154
					"yue", -- 1154
					"teal", -- 1154
					"tl", -- 1154
					"wa" -- 1154
				}, description = "Preferred language variant to search."}, -- 1154
				limit = { -- 1157
					type = "number", -- 1157
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1157
				}, -- 1157
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1158
			}, -- 1158
			{"pattern"} -- 1160
		), -- 1160
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}) -- 1162
	} -- 1162
end -- 1092
local function sanitizeMessagesForLLMInput(messages) -- 1190
	local sanitized = {} -- 1191
	local droppedAssistantToolCalls = 0 -- 1192
	local droppedToolResults = 0 -- 1193
	do -- 1193
		local i = 0 -- 1194
		while i < #messages do -- 1194
			do -- 1194
				local message = messages[i + 1] -- 1195
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1195
					local requiredIds = {} -- 1197
					do -- 1197
						local j = 0 -- 1198
						while j < #message.tool_calls do -- 1198
							local toolCall = message.tool_calls[j + 1] -- 1199
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1200
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1200
								requiredIds[#requiredIds + 1] = id -- 1202
							end -- 1202
							j = j + 1 -- 1198
						end -- 1198
					end -- 1198
					if #requiredIds == 0 then -- 1198
						sanitized[#sanitized + 1] = message -- 1206
						goto __continue182 -- 1207
					end -- 1207
					local matchedIds = {} -- 1209
					local matchedTools = {} -- 1210
					local j = i + 1 -- 1211
					while j < #messages do -- 1211
						local toolMessage = messages[j + 1] -- 1213
						if toolMessage.role ~= "tool" then -- 1213
							break -- 1214
						end -- 1214
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1215
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1215
							matchedIds[toolCallId] = true -- 1217
							matchedTools[#matchedTools + 1] = toolMessage -- 1218
						else -- 1218
							droppedToolResults = droppedToolResults + 1 -- 1220
						end -- 1220
						j = j + 1 -- 1222
					end -- 1222
					local complete = true -- 1224
					do -- 1224
						local j = 0 -- 1225
						while j < #requiredIds do -- 1225
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1225
								complete = false -- 1227
								break -- 1228
							end -- 1228
							j = j + 1 -- 1225
						end -- 1225
					end -- 1225
					if complete then -- 1225
						__TS__ArrayPush( -- 1232
							sanitized, -- 1232
							message, -- 1232
							table.unpack(matchedTools) -- 1232
						) -- 1232
					else -- 1232
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1234
						droppedToolResults = droppedToolResults + #matchedTools -- 1235
					end -- 1235
					i = j - 1 -- 1237
					goto __continue182 -- 1238
				end -- 1238
				if message.role == "tool" then -- 1238
					droppedToolResults = droppedToolResults + 1 -- 1241
					goto __continue182 -- 1242
				end -- 1242
				sanitized[#sanitized + 1] = message -- 1244
			end -- 1244
			::__continue182:: -- 1244
			i = i + 1 -- 1194
		end -- 1194
	end -- 1194
	return sanitized -- 1246
end -- 1190
local function getUnconsolidatedMessages(shared) -- 1249
	return sanitizeMessagesForLLMInput(shared.messages) -- 1250
end -- 1249
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1253
	if attempt == nil then -- 1253
		attempt = 1 -- 1253
	end -- 1253
	local messages = { -- 1254
		{ -- 1255
			role = "system", -- 1255
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1255
		}, -- 1255
		table.unpack(getUnconsolidatedMessages(shared)) -- 1256
	} -- 1256
	if lastError and lastError ~= "" then -- 1256
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1259
		messages[#messages + 1] = { -- 1262
			role = "user", -- 1263
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1264
		} -- 1264
	end -- 1264
	return messages -- 1271
end -- 1253
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 1278
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 1285
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 1286
	local repairPrompt = replacePromptVars( -- 1294
		shared.promptPack.xmlDecisionRepairPrompt, -- 1294
		{ -- 1294
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 1295
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 1296
			CANDIDATE_SECTION = candidateSection, -- 1297
			LAST_ERROR = lastError, -- 1298
			ATTEMPT = tostring(attempt) -- 1299
		} -- 1299
	) -- 1299
	return {{role = "system", content = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only."}, {role = "user", content = repairPrompt}} -- 1301
end -- 1278
local function tryParseAndValidateDecision(rawText) -- 1323
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 1324
	if not parsed.success then -- 1324
		return {success = false, message = parsed.message, raw = rawText} -- 1326
	end -- 1326
	local decision = parseDecisionObject(parsed.obj) -- 1328
	if not decision.success then -- 1328
		return {success = false, message = decision.message, raw = rawText} -- 1330
	end -- 1330
	local validation = validateDecision(decision.tool, decision.params) -- 1332
	if not validation.success then -- 1332
		return {success = false, message = validation.message, raw = rawText} -- 1334
	end -- 1334
	decision.params = validation.params -- 1336
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 1337
	return decision -- 1338
end -- 1323
local function normalizeLineEndings(text) -- 1341
	local res = string.gsub(text, "\r\n", "\n") -- 1342
	res = string.gsub(res, "\r", "\n") -- 1343
	return res -- 1344
end -- 1341
local function countOccurrences(text, searchStr) -- 1347
	if searchStr == "" then -- 1347
		return 0 -- 1348
	end -- 1348
	local count = 0 -- 1349
	local pos = 0 -- 1350
	while true do -- 1350
		local idx = (string.find( -- 1352
			text, -- 1352
			searchStr, -- 1352
			math.max(pos + 1, 1), -- 1352
			true -- 1352
		) or 0) - 1 -- 1352
		if idx < 0 then -- 1352
			break -- 1353
		end -- 1353
		count = count + 1 -- 1354
		pos = idx + #searchStr -- 1355
	end -- 1355
	return count -- 1357
end -- 1347
local function replaceFirst(text, oldStr, newStr) -- 1360
	if oldStr == "" then -- 1360
		return text -- 1361
	end -- 1361
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 1362
	if idx < 0 then -- 1362
		return text -- 1363
	end -- 1363
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 1364
end -- 1360
local function splitLines(text) -- 1367
	return __TS__StringSplit(text, "\n") -- 1368
end -- 1367
local function getLeadingWhitespace(text) -- 1371
	local i = 0 -- 1372
	while i < #text do -- 1372
		local ch = __TS__StringAccess(text, i) -- 1374
		if ch ~= " " and ch ~= "\t" then -- 1374
			break -- 1375
		end -- 1375
		i = i + 1 -- 1376
	end -- 1376
	return __TS__StringSubstring(text, 0, i) -- 1378
end -- 1371
local function getCommonIndentPrefix(lines) -- 1381
	local common -- 1382
	do -- 1382
		local i = 0 -- 1383
		while i < #lines do -- 1383
			do -- 1383
				local line = lines[i + 1] -- 1384
				if __TS__StringTrim(line) == "" then -- 1384
					goto __continue221 -- 1385
				end -- 1385
				local indent = getLeadingWhitespace(line) -- 1386
				if common == nil then -- 1386
					common = indent -- 1388
					goto __continue221 -- 1389
				end -- 1389
				local j = 0 -- 1391
				local maxLen = math.min(#common, #indent) -- 1392
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 1392
					j = j + 1 -- 1394
				end -- 1394
				common = __TS__StringSubstring(common, 0, j) -- 1396
				if common == "" then -- 1396
					break -- 1397
				end -- 1397
			end -- 1397
			::__continue221:: -- 1397
			i = i + 1 -- 1383
		end -- 1383
	end -- 1383
	return common or "" -- 1399
end -- 1381
local function removeIndentPrefix(line, indent) -- 1402
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 1402
		return __TS__StringSubstring(line, #indent) -- 1404
	end -- 1404
	local lineIndent = getLeadingWhitespace(line) -- 1406
	local j = 0 -- 1407
	local maxLen = math.min(#lineIndent, #indent) -- 1408
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 1408
		j = j + 1 -- 1410
	end -- 1410
	return __TS__StringSubstring(line, j) -- 1412
end -- 1402
local function dedentLines(lines) -- 1415
	local indent = getCommonIndentPrefix(lines) -- 1416
	return { -- 1417
		indent = indent, -- 1418
		lines = __TS__ArrayMap( -- 1419
			lines, -- 1419
			function(____, line) return removeIndentPrefix(line, indent) end -- 1419
		) -- 1419
	} -- 1419
end -- 1415
local function joinLines(lines) -- 1423
	return table.concat(lines, "\n") -- 1424
end -- 1423
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 1427
	local contentLines = splitLines(content) -- 1432
	local oldLines = splitLines(oldStr) -- 1433
	if #oldLines == 0 then -- 1433
		return {success = false, message = "old_str not found in file"} -- 1435
	end -- 1435
	local dedentedOld = dedentLines(oldLines) -- 1437
	local dedentedOldText = joinLines(dedentedOld.lines) -- 1438
	local dedentedNew = dedentLines(splitLines(newStr)) -- 1439
	local matches = {} -- 1440
	do -- 1440
		local start = 0 -- 1441
		while start <= #contentLines - #oldLines do -- 1441
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 1442
			local dedentedCandidate = dedentLines(candidateLines) -- 1443
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 1443
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 1445
			end -- 1445
			start = start + 1 -- 1441
		end -- 1441
	end -- 1441
	if #matches == 0 then -- 1441
		return {success = false, message = "old_str not found in file"} -- 1453
	end -- 1453
	if #matches > 1 then -- 1453
		return { -- 1456
			success = false, -- 1457
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 1458
		} -- 1458
	end -- 1458
	local match = matches[1] -- 1461
	local rebuiltNewLines = __TS__ArrayMap( -- 1462
		dedentedNew.lines, -- 1462
		function(____, line) return line == "" and "" or match.indent .. line end -- 1462
	) -- 1462
	local ____array_31 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 1462
	__TS__SparseArrayPush( -- 1462
		____array_31, -- 1462
		table.unpack(rebuiltNewLines) -- 1465
	) -- 1465
	__TS__SparseArrayPush( -- 1465
		____array_31, -- 1465
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 1466
	) -- 1466
	local nextLines = {__TS__SparseArraySpread(____array_31)} -- 1463
	return { -- 1468
		success = true, -- 1468
		content = joinLines(nextLines) -- 1468
	} -- 1468
end -- 1427
local MainDecisionAgent = __TS__Class() -- 1471
MainDecisionAgent.name = "MainDecisionAgent" -- 1471
__TS__ClassExtends(MainDecisionAgent, Node) -- 1471
function MainDecisionAgent.prototype.prep(self, shared) -- 1472
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1472
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1472
			return ____awaiter_resolve(nil, {shared = shared}) -- 1472
		end -- 1472
		__TS__Await(maybeCompressHistory(shared)) -- 1477
		return ____awaiter_resolve(nil, {shared = shared}) -- 1477
	end) -- 1477
end -- 1472
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 1482
	if attempt == nil then -- 1482
		attempt = 1 -- 1485
	end -- 1485
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1485
		if shared.stopToken.stopped then -- 1485
			return ____awaiter_resolve( -- 1485
				nil, -- 1485
				{ -- 1489
					success = false, -- 1489
					message = getCancelledReason(shared) -- 1489
				} -- 1489
			) -- 1489
		end -- 1489
		Log( -- 1491
			"Info", -- 1491
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1491
		) -- 1491
		local tools = buildDecisionToolSchema() -- 1492
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1493
		local stepId = shared.step + 1 -- 1494
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1495
		saveStepLLMDebugInput( -- 1499
			shared, -- 1499
			stepId, -- 1499
			"decision_tool_calling", -- 1499
			messages, -- 1499
			llmOptions -- 1499
		) -- 1499
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1500
		if shared.stopToken.stopped then -- 1500
			return ____awaiter_resolve( -- 1500
				nil, -- 1500
				{ -- 1502
					success = false, -- 1502
					message = getCancelledReason(shared) -- 1502
				} -- 1502
			) -- 1502
		end -- 1502
		if not res.success then -- 1502
			saveStepLLMDebugOutput( -- 1505
				shared, -- 1505
				stepId, -- 1505
				"decision_tool_calling", -- 1505
				res.raw or res.message, -- 1505
				{success = false} -- 1505
			) -- 1505
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1506
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1506
		end -- 1506
		saveStepLLMDebugOutput( -- 1509
			shared, -- 1509
			stepId, -- 1509
			"decision_tool_calling", -- 1509
			encodeDebugJSON(res.response), -- 1509
			{success = true} -- 1509
		) -- 1509
		local choice = res.response.choices and res.response.choices[1] -- 1510
		local message = choice and choice.message -- 1511
		local toolCalls = message and message.tool_calls -- 1512
		local toolCall = toolCalls and toolCalls[1] -- 1513
		local fn = toolCall and toolCall["function"] -- 1514
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 1515
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1518
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1521
		Log( -- 1524
			"Info", -- 1524
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1524
		) -- 1524
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1524
			if messageContent and messageContent ~= "" then -- 1524
				Log( -- 1527
					"Info", -- 1527
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1527
				) -- 1527
				return ____awaiter_resolve(nil, { -- 1527
					success = true, -- 1529
					tool = "finish", -- 1530
					params = {}, -- 1531
					reason = messageContent, -- 1532
					reasoningContent = reasoningContent, -- 1533
					directSummary = messageContent -- 1534
				}) -- 1534
			end -- 1534
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1537
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1537
		end -- 1537
		local functionName = fn.name -- 1544
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1545
		Log( -- 1546
			"Info", -- 1546
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1546
		) -- 1546
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1547
			local rawObj, err = safeJsonDecode(argsText) -- 1548
			if err ~= nil or rawObj == nil then -- 1548
				return {__error = tostring(err)} -- 1550
			end -- 1550
			return rawObj -- 1552
		end)() -- 1547
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 1547
			local err = tostring(rawArgs.__error) -- 1555
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1556
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1556
		end -- 1556
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1563
		if not decision.success then -- 1563
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1565
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1565
		end -- 1565
		local validation = validateDecision(decision.tool, decision.params) -- 1572
		if not validation.success then -- 1572
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1574
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1574
		end -- 1574
		decision.params = validation.params -- 1581
		decision.toolCallId = ensureToolCallId(toolCallId) -- 1582
		decision.reason = messageContent -- 1583
		decision.reasoningContent = reasoningContent -- 1584
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1585
		return ____awaiter_resolve(nil, decision) -- 1585
	end) -- 1585
end -- 1482
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 1589
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1589
		Log( -- 1594
			"Info", -- 1594
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 1594
		) -- 1594
		local lastError = initialError -- 1595
		local candidateRaw = "" -- 1596
		do -- 1596
			local attempt = 0 -- 1597
			while attempt < shared.llmMaxTry do -- 1597
				do -- 1597
					Log( -- 1598
						"Info", -- 1598
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 1598
					) -- 1598
					local messages = buildXmlRepairMessages( -- 1599
						shared, -- 1600
						originalRaw, -- 1601
						candidateRaw, -- 1602
						lastError, -- 1603
						attempt + 1 -- 1604
					) -- 1604
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 1606
					if shared.stopToken.stopped then -- 1606
						return ____awaiter_resolve( -- 1606
							nil, -- 1606
							{ -- 1608
								success = false, -- 1608
								message = getCancelledReason(shared) -- 1608
							} -- 1608
						) -- 1608
					end -- 1608
					if not llmRes.success then -- 1608
						lastError = llmRes.message -- 1611
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 1612
						goto __continue255 -- 1613
					end -- 1613
					candidateRaw = llmRes.text -- 1615
					local decision = tryParseAndValidateDecision(candidateRaw) -- 1616
					if decision.success then -- 1616
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 1618
						return ____awaiter_resolve(nil, decision) -- 1618
					end -- 1618
					lastError = decision.message -- 1621
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 1622
				end -- 1622
				::__continue255:: -- 1622
				attempt = attempt + 1 -- 1597
			end -- 1597
		end -- 1597
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 1624
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 1624
	end) -- 1624
end -- 1589
function MainDecisionAgent.prototype.exec(self, input) -- 1632
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1632
		local shared = input.shared -- 1633
		if shared.stopToken.stopped then -- 1633
			return ____awaiter_resolve( -- 1633
				nil, -- 1633
				{ -- 1635
					success = false, -- 1635
					message = getCancelledReason(shared) -- 1635
				} -- 1635
			) -- 1635
		end -- 1635
		if shared.step >= shared.maxSteps then -- 1635
			Log( -- 1638
				"Warn", -- 1638
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1638
			) -- 1638
			return ____awaiter_resolve( -- 1638
				nil, -- 1638
				{ -- 1639
					success = false, -- 1639
					message = getMaxStepsReachedReason(shared) -- 1639
				} -- 1639
			) -- 1639
		end -- 1639
		if shared.decisionMode == "tool_calling" then -- 1639
			Log( -- 1643
				"Info", -- 1643
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 1643
			) -- 1643
			local lastError = "tool calling validation failed" -- 1644
			local lastRaw = "" -- 1645
			do -- 1645
				local attempt = 0 -- 1646
				while attempt < shared.llmMaxTry do -- 1646
					Log( -- 1647
						"Info", -- 1647
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1647
					) -- 1647
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 1648
					if shared.stopToken.stopped then -- 1648
						return ____awaiter_resolve( -- 1648
							nil, -- 1648
							{ -- 1655
								success = false, -- 1655
								message = getCancelledReason(shared) -- 1655
							} -- 1655
						) -- 1655
					end -- 1655
					if decision.success then -- 1655
						return ____awaiter_resolve(nil, decision) -- 1655
					end -- 1655
					lastError = decision.message -- 1660
					lastRaw = decision.raw or "" -- 1661
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1662
					attempt = attempt + 1 -- 1646
				end -- 1646
			end -- 1646
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1664
			return ____awaiter_resolve( -- 1664
				nil, -- 1664
				{ -- 1665
					success = false, -- 1665
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1665
				} -- 1665
			) -- 1665
		end -- 1665
		local lastError = "xml validation failed" -- 1668
		local lastRaw = "" -- 1669
		do -- 1669
			local attempt = 0 -- 1670
			while attempt < shared.llmMaxTry do -- 1670
				do -- 1670
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 1671
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 1679
					if shared.stopToken.stopped then -- 1679
						return ____awaiter_resolve( -- 1679
							nil, -- 1679
							{ -- 1681
								success = false, -- 1681
								message = getCancelledReason(shared) -- 1681
							} -- 1681
						) -- 1681
					end -- 1681
					if not llmRes.success then -- 1681
						lastError = llmRes.message -- 1684
						lastRaw = llmRes.text or "" -- 1685
						goto __continue268 -- 1686
					end -- 1686
					lastRaw = llmRes.text -- 1688
					local decision = tryParseAndValidateDecision(llmRes.text) -- 1689
					if decision.success then -- 1689
						return ____awaiter_resolve(nil, decision) -- 1689
					end -- 1689
					lastError = decision.message -- 1693
					return ____awaiter_resolve( -- 1693
						nil, -- 1693
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 1694
					) -- 1694
				end -- 1694
				::__continue268:: -- 1694
				attempt = attempt + 1 -- 1670
			end -- 1670
		end -- 1670
		return ____awaiter_resolve( -- 1670
			nil, -- 1670
			{ -- 1696
				success = false, -- 1696
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1696
			} -- 1696
		) -- 1696
	end) -- 1696
end -- 1632
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1699
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1699
		local result = execRes -- 1700
		if not result.success then -- 1700
			shared.error = result.message -- 1702
			shared.response = getFailureSummaryFallback(shared, result.message) -- 1703
			shared.done = true -- 1704
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 1705
			persistHistoryState(shared) -- 1709
			return ____awaiter_resolve(nil, "done") -- 1709
		end -- 1709
		if result.directSummary and result.directSummary ~= "" then -- 1709
			shared.response = result.directSummary -- 1713
			shared.done = true -- 1714
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 1715
			persistHistoryState(shared) -- 1720
			return ____awaiter_resolve(nil, "done") -- 1720
		end -- 1720
		if result.tool == "finish" then -- 1720
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 1724
			shared.response = finalMessage -- 1725
			shared.done = true -- 1726
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 1727
			persistHistoryState(shared) -- 1732
			return ____awaiter_resolve(nil, "done") -- 1732
		end -- 1732
		local toolCallId = ensureToolCallId(result.toolCallId) -- 1735
		shared.step = shared.step + 1 -- 1736
		local step = shared.step -- 1737
		emitAgentEvent(shared, { -- 1738
			type = "decision_made", -- 1739
			sessionId = shared.sessionId, -- 1740
			taskId = shared.taskId, -- 1741
			step = step, -- 1742
			tool = result.tool, -- 1743
			reason = result.reason, -- 1744
			reasoningContent = result.reasoningContent, -- 1745
			params = result.params -- 1746
		}) -- 1746
		local ____shared_history_32 = shared.history -- 1746
		____shared_history_32[#____shared_history_32 + 1] = { -- 1748
			step = step, -- 1749
			toolCallId = toolCallId, -- 1750
			tool = result.tool, -- 1751
			reason = result.reason or "", -- 1752
			reasoningContent = result.reasoningContent, -- 1753
			params = result.params, -- 1754
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1755
		} -- 1755
		appendConversationMessage( -- 1757
			shared, -- 1757
			{ -- 1757
				role = "assistant", -- 1758
				content = result.reason or "", -- 1759
				reasoning_content = result.reasoningContent, -- 1760
				tool_calls = {{ -- 1761
					id = toolCallId, -- 1762
					type = "function", -- 1763
					["function"] = { -- 1764
						name = result.tool, -- 1765
						arguments = toJson(result.params) -- 1766
					} -- 1766
				}} -- 1766
			} -- 1766
		) -- 1766
		persistHistoryState(shared) -- 1770
		return ____awaiter_resolve(nil, result.tool) -- 1770
	end) -- 1770
end -- 1699
local ReadFileAction = __TS__Class() -- 1775
ReadFileAction.name = "ReadFileAction" -- 1775
__TS__ClassExtends(ReadFileAction, Node) -- 1775
function ReadFileAction.prototype.prep(self, shared) -- 1776
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1776
		local last = shared.history[#shared.history] -- 1777
		if not last then -- 1777
			error( -- 1778
				__TS__New(Error, "no history"), -- 1778
				0 -- 1778
			) -- 1778
		end -- 1778
		emitAgentStartEvent(shared, last) -- 1779
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1780
		if __TS__StringTrim(path) == "" then -- 1780
			error( -- 1783
				__TS__New(Error, "missing path"), -- 1783
				0 -- 1783
			) -- 1783
		end -- 1783
		local ____path_35 = path -- 1785
		local ____shared_workingDir_36 = shared.workingDir -- 1787
		local ____temp_37 = shared.useChineseResponse and "zh" or "en" -- 1788
		local ____last_params_startLine_33 = last.params.startLine -- 1789
		if ____last_params_startLine_33 == nil then -- 1789
			____last_params_startLine_33 = 1 -- 1789
		end -- 1789
		local ____TS__Number_result_38 = __TS__Number(____last_params_startLine_33) -- 1789
		local ____last_params_endLine_34 = last.params.endLine -- 1790
		if ____last_params_endLine_34 == nil then -- 1790
			____last_params_endLine_34 = READ_FILE_DEFAULT_LIMIT -- 1790
		end -- 1790
		return ____awaiter_resolve( -- 1790
			nil, -- 1790
			{ -- 1784
				path = ____path_35, -- 1785
				tool = "read_file", -- 1786
				workDir = ____shared_workingDir_36, -- 1787
				docLanguage = ____temp_37, -- 1788
				startLine = ____TS__Number_result_38, -- 1789
				endLine = __TS__Number(____last_params_endLine_34) -- 1790
			} -- 1790
		) -- 1790
	end) -- 1790
end -- 1776
function ReadFileAction.prototype.exec(self, input) -- 1794
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1794
		return ____awaiter_resolve( -- 1794
			nil, -- 1794
			Tools.readFile( -- 1795
				input.workDir, -- 1796
				input.path, -- 1797
				__TS__Number(input.startLine or 1), -- 1798
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1799
				input.docLanguage -- 1800
			) -- 1800
		) -- 1800
	end) -- 1800
end -- 1794
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1804
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1804
		local result = execRes -- 1805
		local last = shared.history[#shared.history] -- 1806
		if last ~= nil then -- 1806
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1808
			appendToolResultMessage(shared, last) -- 1809
			emitAgentFinishEvent(shared, last) -- 1810
		end -- 1810
		persistHistoryState(shared) -- 1812
		__TS__Await(maybeCompressHistory(shared)) -- 1813
		persistHistoryState(shared) -- 1814
		return ____awaiter_resolve(nil, "main") -- 1814
	end) -- 1814
end -- 1804
local SearchFilesAction = __TS__Class() -- 1819
SearchFilesAction.name = "SearchFilesAction" -- 1819
__TS__ClassExtends(SearchFilesAction, Node) -- 1819
function SearchFilesAction.prototype.prep(self, shared) -- 1820
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1820
		local last = shared.history[#shared.history] -- 1821
		if not last then -- 1821
			error( -- 1822
				__TS__New(Error, "no history"), -- 1822
				0 -- 1822
			) -- 1822
		end -- 1822
		emitAgentStartEvent(shared, last) -- 1823
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1823
	end) -- 1823
end -- 1820
function SearchFilesAction.prototype.exec(self, input) -- 1827
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1827
		local params = input.params -- 1828
		local ____Tools_searchFiles_52 = Tools.searchFiles -- 1829
		local ____input_workDir_45 = input.workDir -- 1830
		local ____temp_46 = params.path or "" -- 1831
		local ____temp_47 = params.pattern or "" -- 1832
		local ____params_globs_48 = params.globs -- 1833
		local ____params_useRegex_49 = params.useRegex -- 1834
		local ____params_caseSensitive_50 = params.caseSensitive -- 1835
		local ____math_max_41 = math.max -- 1838
		local ____math_floor_40 = math.floor -- 1838
		local ____params_limit_39 = params.limit -- 1838
		if ____params_limit_39 == nil then -- 1838
			____params_limit_39 = SEARCH_FILES_LIMIT_DEFAULT -- 1838
		end -- 1838
		local ____math_max_41_result_51 = ____math_max_41( -- 1838
			1, -- 1838
			____math_floor_40(__TS__Number(____params_limit_39)) -- 1838
		) -- 1838
		local ____math_max_44 = math.max -- 1839
		local ____math_floor_43 = math.floor -- 1839
		local ____params_offset_42 = params.offset -- 1839
		if ____params_offset_42 == nil then -- 1839
			____params_offset_42 = 0 -- 1839
		end -- 1839
		local result = __TS__Await(____Tools_searchFiles_52({ -- 1829
			workDir = ____input_workDir_45, -- 1830
			path = ____temp_46, -- 1831
			pattern = ____temp_47, -- 1832
			globs = ____params_globs_48, -- 1833
			useRegex = ____params_useRegex_49, -- 1834
			caseSensitive = ____params_caseSensitive_50, -- 1835
			includeContent = true, -- 1836
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1837
			limit = ____math_max_41_result_51, -- 1838
			offset = ____math_max_44( -- 1839
				0, -- 1839
				____math_floor_43(__TS__Number(____params_offset_42)) -- 1839
			), -- 1839
			groupByFile = params.groupByFile == true -- 1840
		})) -- 1840
		return ____awaiter_resolve(nil, result) -- 1840
	end) -- 1840
end -- 1827
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1845
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1845
		local last = shared.history[#shared.history] -- 1846
		if last ~= nil then -- 1846
			local result = execRes -- 1848
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1849
			appendToolResultMessage(shared, last) -- 1850
			emitAgentFinishEvent(shared, last) -- 1851
		end -- 1851
		persistHistoryState(shared) -- 1853
		__TS__Await(maybeCompressHistory(shared)) -- 1854
		persistHistoryState(shared) -- 1855
		return ____awaiter_resolve(nil, "main") -- 1855
	end) -- 1855
end -- 1845
local SearchDoraAPIAction = __TS__Class() -- 1860
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1860
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1860
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1861
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1861
		local last = shared.history[#shared.history] -- 1862
		if not last then -- 1862
			error( -- 1863
				__TS__New(Error, "no history"), -- 1863
				0 -- 1863
			) -- 1863
		end -- 1863
		emitAgentStartEvent(shared, last) -- 1864
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1864
	end) -- 1864
end -- 1861
function SearchDoraAPIAction.prototype.exec(self, input) -- 1868
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1868
		local params = input.params -- 1869
		local ____Tools_searchDoraAPI_60 = Tools.searchDoraAPI -- 1870
		local ____temp_56 = params.pattern or "" -- 1871
		local ____temp_57 = params.docSource or "api" -- 1872
		local ____temp_58 = input.useChineseResponse and "zh" or "en" -- 1873
		local ____temp_59 = params.programmingLanguage or "ts" -- 1874
		local ____math_min_55 = math.min -- 1875
		local ____math_max_54 = math.max -- 1875
		local ____params_limit_53 = params.limit -- 1875
		if ____params_limit_53 == nil then -- 1875
			____params_limit_53 = 8 -- 1875
		end -- 1875
		local result = __TS__Await(____Tools_searchDoraAPI_60({ -- 1870
			pattern = ____temp_56, -- 1871
			docSource = ____temp_57, -- 1872
			docLanguage = ____temp_58, -- 1873
			programmingLanguage = ____temp_59, -- 1874
			limit = ____math_min_55( -- 1875
				SEARCH_DORA_API_LIMIT_MAX, -- 1875
				____math_max_54( -- 1875
					1, -- 1875
					__TS__Number(____params_limit_53) -- 1875
				) -- 1875
			), -- 1875
			useRegex = params.useRegex, -- 1876
			caseSensitive = false, -- 1877
			includeContent = true, -- 1878
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1879
		})) -- 1879
		return ____awaiter_resolve(nil, result) -- 1879
	end) -- 1879
end -- 1868
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1884
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1884
		local last = shared.history[#shared.history] -- 1885
		if last ~= nil then -- 1885
			local result = execRes -- 1887
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1888
			appendToolResultMessage(shared, last) -- 1889
			emitAgentFinishEvent(shared, last) -- 1890
		end -- 1890
		persistHistoryState(shared) -- 1892
		__TS__Await(maybeCompressHistory(shared)) -- 1893
		persistHistoryState(shared) -- 1894
		return ____awaiter_resolve(nil, "main") -- 1894
	end) -- 1894
end -- 1884
local ListFilesAction = __TS__Class() -- 1899
ListFilesAction.name = "ListFilesAction" -- 1899
__TS__ClassExtends(ListFilesAction, Node) -- 1899
function ListFilesAction.prototype.prep(self, shared) -- 1900
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1900
		local last = shared.history[#shared.history] -- 1901
		if not last then -- 1901
			error( -- 1902
				__TS__New(Error, "no history"), -- 1902
				0 -- 1902
			) -- 1902
		end -- 1902
		emitAgentStartEvent(shared, last) -- 1903
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1903
	end) -- 1903
end -- 1900
function ListFilesAction.prototype.exec(self, input) -- 1907
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1907
		local params = input.params -- 1908
		local ____Tools_listFiles_67 = Tools.listFiles -- 1909
		local ____input_workDir_64 = input.workDir -- 1910
		local ____temp_65 = params.path or "" -- 1911
		local ____params_globs_66 = params.globs -- 1912
		local ____math_max_63 = math.max -- 1913
		local ____math_floor_62 = math.floor -- 1913
		local ____params_maxEntries_61 = params.maxEntries -- 1913
		if ____params_maxEntries_61 == nil then -- 1913
			____params_maxEntries_61 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1913
		end -- 1913
		local result = ____Tools_listFiles_67({ -- 1909
			workDir = ____input_workDir_64, -- 1910
			path = ____temp_65, -- 1911
			globs = ____params_globs_66, -- 1912
			maxEntries = ____math_max_63( -- 1913
				1, -- 1913
				____math_floor_62(__TS__Number(____params_maxEntries_61)) -- 1913
			) -- 1913
		}) -- 1913
		return ____awaiter_resolve(nil, result) -- 1913
	end) -- 1913
end -- 1907
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1918
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1918
		local last = shared.history[#shared.history] -- 1919
		if last ~= nil then -- 1919
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1921
			appendToolResultMessage(shared, last) -- 1922
			emitAgentFinishEvent(shared, last) -- 1923
		end -- 1923
		persistHistoryState(shared) -- 1925
		__TS__Await(maybeCompressHistory(shared)) -- 1926
		persistHistoryState(shared) -- 1927
		return ____awaiter_resolve(nil, "main") -- 1927
	end) -- 1927
end -- 1918
local DeleteFileAction = __TS__Class() -- 1932
DeleteFileAction.name = "DeleteFileAction" -- 1932
__TS__ClassExtends(DeleteFileAction, Node) -- 1932
function DeleteFileAction.prototype.prep(self, shared) -- 1933
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1933
		local last = shared.history[#shared.history] -- 1934
		if not last then -- 1934
			error( -- 1935
				__TS__New(Error, "no history"), -- 1935
				0 -- 1935
			) -- 1935
		end -- 1935
		emitAgentStartEvent(shared, last) -- 1936
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1937
		if __TS__StringTrim(targetFile) == "" then -- 1937
			error( -- 1940
				__TS__New(Error, "missing target_file"), -- 1940
				0 -- 1940
			) -- 1940
		end -- 1940
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1940
	end) -- 1940
end -- 1933
function DeleteFileAction.prototype.exec(self, input) -- 1944
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1944
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1945
		if not result.success then -- 1945
			return ____awaiter_resolve(nil, result) -- 1945
		end -- 1945
		return ____awaiter_resolve(nil, { -- 1945
			success = true, -- 1953
			changed = true, -- 1954
			mode = "delete", -- 1955
			checkpointId = result.checkpointId, -- 1956
			checkpointSeq = result.checkpointSeq, -- 1957
			files = {{path = input.targetFile, op = "delete"}} -- 1958
		}) -- 1958
	end) -- 1958
end -- 1944
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1962
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1962
		local last = shared.history[#shared.history] -- 1963
		if last ~= nil then -- 1963
			last.result = execRes -- 1965
			appendToolResultMessage(shared, last) -- 1966
			emitAgentFinishEvent(shared, last) -- 1967
			local result = last.result -- 1968
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 1968
				emitAgentEvent(shared, { -- 1973
					type = "checkpoint_created", -- 1974
					sessionId = shared.sessionId, -- 1975
					taskId = shared.taskId, -- 1976
					step = last.step, -- 1977
					tool = "delete_file", -- 1978
					checkpointId = result.checkpointId, -- 1979
					checkpointSeq = result.checkpointSeq, -- 1980
					files = result.files -- 1981
				}) -- 1981
			end -- 1981
		end -- 1981
		persistHistoryState(shared) -- 1985
		__TS__Await(maybeCompressHistory(shared)) -- 1986
		persistHistoryState(shared) -- 1987
		return ____awaiter_resolve(nil, "main") -- 1987
	end) -- 1987
end -- 1962
local BuildAction = __TS__Class() -- 1992
BuildAction.name = "BuildAction" -- 1992
__TS__ClassExtends(BuildAction, Node) -- 1992
function BuildAction.prototype.prep(self, shared) -- 1993
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1993
		local last = shared.history[#shared.history] -- 1994
		if not last then -- 1994
			error( -- 1995
				__TS__New(Error, "no history"), -- 1995
				0 -- 1995
			) -- 1995
		end -- 1995
		emitAgentStartEvent(shared, last) -- 1996
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1996
	end) -- 1996
end -- 1993
function BuildAction.prototype.exec(self, input) -- 2000
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2000
		local params = input.params -- 2001
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2002
		return ____awaiter_resolve(nil, result) -- 2002
	end) -- 2002
end -- 2000
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2009
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2009
		local last = shared.history[#shared.history] -- 2010
		if last ~= nil then -- 2010
			last.result = execRes -- 2012
			appendToolResultMessage(shared, last) -- 2013
			emitAgentFinishEvent(shared, last) -- 2014
		end -- 2014
		persistHistoryState(shared) -- 2016
		__TS__Await(maybeCompressHistory(shared)) -- 2017
		persistHistoryState(shared) -- 2018
		return ____awaiter_resolve(nil, "main") -- 2018
	end) -- 2018
end -- 2009
local EditFileAction = __TS__Class() -- 2023
EditFileAction.name = "EditFileAction" -- 2023
__TS__ClassExtends(EditFileAction, Node) -- 2023
function EditFileAction.prototype.prep(self, shared) -- 2024
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2024
		local last = shared.history[#shared.history] -- 2025
		if not last then -- 2025
			error( -- 2026
				__TS__New(Error, "no history"), -- 2026
				0 -- 2026
			) -- 2026
		end -- 2026
		emitAgentStartEvent(shared, last) -- 2027
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2028
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2031
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2032
		if __TS__StringTrim(path) == "" then -- 2032
			error( -- 2033
				__TS__New(Error, "missing path"), -- 2033
				0 -- 2033
			) -- 2033
		end -- 2033
		return ____awaiter_resolve(nil, { -- 2033
			path = path, -- 2034
			oldStr = oldStr, -- 2034
			newStr = newStr, -- 2034
			taskId = shared.taskId, -- 2034
			workDir = shared.workingDir -- 2034
		}) -- 2034
	end) -- 2034
end -- 2024
function EditFileAction.prototype.exec(self, input) -- 2037
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2037
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 2038
		if not readRes.success then -- 2038
			if input.oldStr ~= "" then -- 2038
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 2038
			end -- 2038
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2043
			if not createRes.success then -- 2043
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 2043
			end -- 2043
			return ____awaiter_resolve(nil, { -- 2043
				success = true, -- 2051
				changed = true, -- 2052
				mode = "create", -- 2053
				checkpointId = createRes.checkpointId, -- 2054
				checkpointSeq = createRes.checkpointSeq, -- 2055
				files = {{path = input.path, op = "create"}} -- 2056
			}) -- 2056
		end -- 2056
		if input.oldStr == "" then -- 2056
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2060
			if not overwriteRes.success then -- 2060
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 2060
			end -- 2060
			return ____awaiter_resolve(nil, { -- 2060
				success = true, -- 2068
				changed = true, -- 2069
				mode = "overwrite", -- 2070
				checkpointId = overwriteRes.checkpointId, -- 2071
				checkpointSeq = overwriteRes.checkpointSeq, -- 2072
				files = {{path = input.path, op = "write"}} -- 2073
			}) -- 2073
		end -- 2073
		local normalizedContent = normalizeLineEndings(readRes.content) -- 2078
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 2079
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 2080
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 2083
		if occurrences == 0 then -- 2083
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2085
			if not indentTolerant.success then -- 2085
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 2085
			end -- 2085
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 2089
			if not applyRes.success then -- 2089
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2089
			end -- 2089
			return ____awaiter_resolve(nil, { -- 2089
				success = true, -- 2097
				changed = true, -- 2098
				mode = "replace_indent_tolerant", -- 2099
				checkpointId = applyRes.checkpointId, -- 2100
				checkpointSeq = applyRes.checkpointSeq, -- 2101
				files = {{path = input.path, op = "write"}} -- 2102
			}) -- 2102
		end -- 2102
		if occurrences > 1 then -- 2102
			return ____awaiter_resolve( -- 2102
				nil, -- 2102
				{ -- 2106
					success = false, -- 2106
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 2106
				} -- 2106
			) -- 2106
		end -- 2106
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2110
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2111
		if not applyRes.success then -- 2111
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2111
		end -- 2111
		return ____awaiter_resolve(nil, { -- 2111
			success = true, -- 2119
			changed = true, -- 2120
			mode = "replace", -- 2121
			checkpointId = applyRes.checkpointId, -- 2122
			checkpointSeq = applyRes.checkpointSeq, -- 2123
			files = {{path = input.path, op = "write"}} -- 2124
		}) -- 2124
	end) -- 2124
end -- 2037
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2128
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2128
		local last = shared.history[#shared.history] -- 2129
		if last ~= nil then -- 2129
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 2131
			last.result = execRes -- 2132
			appendToolResultMessage(shared, last) -- 2133
			emitAgentFinishEvent(shared, last) -- 2134
			local result = last.result -- 2135
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2135
				emitAgentEvent(shared, { -- 2140
					type = "checkpoint_created", -- 2141
					sessionId = shared.sessionId, -- 2142
					taskId = shared.taskId, -- 2143
					step = last.step, -- 2144
					tool = last.tool, -- 2145
					checkpointId = result.checkpointId, -- 2146
					checkpointSeq = result.checkpointSeq, -- 2147
					files = result.files -- 2148
				}) -- 2148
			end -- 2148
		end -- 2148
		persistHistoryState(shared) -- 2152
		__TS__Await(maybeCompressHistory(shared)) -- 2153
		persistHistoryState(shared) -- 2154
		return ____awaiter_resolve(nil, "main") -- 2154
	end) -- 2154
end -- 2128
local EndNode = __TS__Class() -- 2159
EndNode.name = "EndNode" -- 2159
__TS__ClassExtends(EndNode, Node) -- 2159
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 2160
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2160
		return ____awaiter_resolve(nil, nil) -- 2160
	end) -- 2160
end -- 2160
local CodingAgentFlow = __TS__Class() -- 2165
CodingAgentFlow.name = "CodingAgentFlow" -- 2165
__TS__ClassExtends(CodingAgentFlow, Flow) -- 2165
function CodingAgentFlow.prototype.____constructor(self) -- 2166
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 2167
	local read = __TS__New(ReadFileAction, 1, 0) -- 2168
	local search = __TS__New(SearchFilesAction, 1, 0) -- 2169
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 2170
	local list = __TS__New(ListFilesAction, 1, 0) -- 2171
	local del = __TS__New(DeleteFileAction, 1, 0) -- 2172
	local build = __TS__New(BuildAction, 1, 0) -- 2173
	local edit = __TS__New(EditFileAction, 1, 0) -- 2174
	local done = __TS__New(EndNode, 1, 0) -- 2175
	main:on("read_file", read) -- 2177
	main:on("grep_files", search) -- 2178
	main:on("search_dora_api", searchDora) -- 2179
	main:on("glob_files", list) -- 2180
	main:on("delete_file", del) -- 2181
	main:on("build", build) -- 2182
	main:on("edit_file", edit) -- 2183
	main:on("done", done) -- 2184
	read:on("main", main) -- 2186
	search:on("main", main) -- 2187
	searchDora:on("main", main) -- 2188
	list:on("main", main) -- 2189
	del:on("main", main) -- 2190
	build:on("main", main) -- 2191
	edit:on("main", main) -- 2192
	Flow.prototype.____constructor(self, main) -- 2194
end -- 2166
local function runCodingAgentAsync(options) -- 2216
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2216
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 2216
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 2216
		end -- 2216
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 2220
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2221
		if not llmConfigRes.success then -- 2221
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2221
		end -- 2221
		local llmConfig = llmConfigRes.config -- 2227
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 2228
		if not taskRes.success then -- 2228
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 2228
		end -- 2228
		local compressor = __TS__New(MemoryCompressor, { -- 2235
			compressionThreshold = 0.8, -- 2236
			maxCompressionRounds = 3, -- 2237
			maxTokensPerCompression = 20000, -- 2238
			projectDir = options.workDir, -- 2239
			llmConfig = llmConfig, -- 2240
			promptPack = options.promptPack -- 2241
		}) -- 2241
		local persistedSession = compressor:getStorage():readSessionState() -- 2243
		local promptPack = compressor:getPromptPack() -- 2244
		local shared = { -- 2246
			sessionId = options.sessionId, -- 2247
			taskId = taskRes.taskId, -- 2248
			maxSteps = math.max( -- 2249
				1, -- 2249
				math.floor(options.maxSteps or 50) -- 2249
			), -- 2249
			llmMaxTry = math.max( -- 2250
				1, -- 2250
				math.floor(options.llmMaxTry or 3) -- 2250
			), -- 2250
			step = 0, -- 2251
			done = false, -- 2252
			stopToken = options.stopToken or ({stopped = false}), -- 2253
			response = "", -- 2254
			userQuery = normalizedPrompt, -- 2255
			workingDir = options.workDir, -- 2256
			useChineseResponse = options.useChineseResponse == true, -- 2257
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 2258
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 2261
			llmConfig = llmConfig, -- 2266
			onEvent = options.onEvent, -- 2267
			promptPack = promptPack, -- 2268
			history = {}, -- 2269
			messages = persistedSession.messages, -- 2270
			memory = {compressor = compressor} -- 2272
		} -- 2272
		local ____try = __TS__AsyncAwaiter(function() -- 2272
			emitAgentEvent(shared, { -- 2278
				type = "task_started", -- 2279
				sessionId = shared.sessionId, -- 2280
				taskId = shared.taskId, -- 2281
				prompt = shared.userQuery, -- 2282
				workDir = shared.workingDir, -- 2283
				maxSteps = shared.maxSteps -- 2284
			}) -- 2284
			if shared.stopToken.stopped then -- 2284
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2287
				return ____awaiter_resolve( -- 2287
					nil, -- 2287
					emitAgentTaskFinishEvent( -- 2288
						shared, -- 2288
						false, -- 2288
						getCancelledReason(shared) -- 2288
					) -- 2288
				) -- 2288
			end -- 2288
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 2290
			local promptCommand = getPromptCommand(shared.userQuery) -- 2291
			if promptCommand == "reset" then -- 2291
				return ____awaiter_resolve( -- 2291
					nil, -- 2291
					resetSessionHistory(shared) -- 2293
				) -- 2293
			end -- 2293
			if promptCommand == "compact" then -- 2293
				return ____awaiter_resolve( -- 2293
					nil, -- 2293
					__TS__Await(compactAllHistory(shared)) -- 2296
				) -- 2296
			end -- 2296
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 2298
			persistHistoryState(shared) -- 2302
			local flow = __TS__New(CodingAgentFlow) -- 2303
			__TS__Await(flow:run(shared)) -- 2304
			if shared.stopToken.stopped then -- 2304
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2306
				return ____awaiter_resolve( -- 2306
					nil, -- 2306
					emitAgentTaskFinishEvent( -- 2307
						shared, -- 2307
						false, -- 2307
						getCancelledReason(shared) -- 2307
					) -- 2307
				) -- 2307
			end -- 2307
			if shared.error then -- 2307
				return ____awaiter_resolve( -- 2307
					nil, -- 2307
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 2310
				) -- 2310
			end -- 2310
			Tools.setTaskStatus(shared.taskId, "DONE") -- 2313
			return ____awaiter_resolve( -- 2313
				nil, -- 2313
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 2314
			) -- 2314
		end) -- 2314
		__TS__Await(____try.catch( -- 2277
			____try, -- 2277
			function(____, e) -- 2277
				return ____awaiter_resolve( -- 2277
					nil, -- 2277
					finalizeAgentFailure( -- 2317
						shared, -- 2317
						tostring(e) -- 2317
					) -- 2317
				) -- 2317
			end -- 2317
		)) -- 2317
	end) -- 2317
end -- 2216
function ____exports.runCodingAgent(options, callback) -- 2321
	local ____self_68 = runCodingAgentAsync(options) -- 2321
	____self_68["then"]( -- 2321
		____self_68, -- 2321
		function(____, result) return callback(result) end -- 2322
	) -- 2322
end -- 2321
return ____exports -- 2321