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
function truncateText(text, maxLen) -- 418
	if #text <= maxLen then -- 418
		return text -- 419
	end -- 419
	local nextPos = utf8.offset(text, maxLen + 1) -- 420
	if nextPos == nil then -- 420
		return text -- 421
	end -- 421
	return string.sub(text, 1, nextPos - 1) .. "..." -- 422
end -- 422
function getReplyLanguageDirective(shared) -- 432
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 433
end -- 433
function replacePromptVars(template, vars) -- 438
	local output = template -- 439
	for key in pairs(vars) do -- 440
		output = table.concat( -- 441
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 441
			vars[key] or "" or "," -- 441
		) -- 441
	end -- 441
	return output -- 443
end -- 443
function getDecisionToolDefinitions(shared) -- 567
	local base = replacePromptVars( -- 568
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 569
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 570
	) -- 570
	if (shared and shared.decisionMode) ~= "xml" then -- 570
		return base -- 573
	end -- 573
	return base .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 575
end -- 575
function persistHistoryState(shared) -- 825
	shared.memory.compressor:getStorage():writeSessionState(shared.messages) -- 826
end -- 826
function applyCompressedSessionState(shared, compressedCount, carryMessage) -- 829
	local remainingMessages = __TS__ArraySlice(shared.messages, compressedCount) -- 834
	if carryMessage then -- 834
		__TS__ArrayUnshift( -- 836
			remainingMessages, -- 836
			__TS__ObjectAssign( -- 836
				{}, -- 836
				carryMessage, -- 837
				{timestamp = carryMessage.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 836
			) -- 836
		) -- 836
	end -- 836
	shared.messages = remainingMessages -- 841
end -- 841
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1164
	if includeToolDefinitions == nil then -- 1164
		includeToolDefinitions = false -- 1164
	end -- 1164
	local sections = { -- 1165
		shared.promptPack.agentIdentityPrompt, -- 1166
		getReplyLanguageDirective(shared) -- 1167
	} -- 1167
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1169
	if memoryContext ~= "" then -- 1169
		sections[#sections + 1] = memoryContext -- 1171
	end -- 1171
	if includeToolDefinitions then -- 1171
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1174
		if shared.decisionMode == "xml" then -- 1174
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1176
		end -- 1176
	end -- 1176
	return table.concat(sections, "\n\n") -- 1179
end -- 1179
function buildXmlDecisionInstruction(shared, feedback) -- 1266
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 1267
end -- 1267
function emitAgentTaskFinishEvent(shared, success, message) -- 2190
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 2191
	emitAgentEvent(shared, { -- 2197
		type = "task_finished", -- 2198
		sessionId = shared.sessionId, -- 2199
		taskId = shared.taskId, -- 2200
		success = result.success, -- 2201
		message = result.message, -- 2202
		steps = result.steps -- 2203
	}) -- 2203
	return result -- 2205
end -- 2205
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
local function getPromptCommand(prompt) -- 261
	local trimmed = __TS__StringTrim(prompt) -- 262
	if trimmed == "/compact" then -- 262
		return "compact" -- 263
	end -- 263
	if trimmed == "/reset" then -- 263
		return "reset" -- 264
	end -- 264
	return nil -- 265
end -- 261
function ____exports.truncateAgentUserPrompt(prompt) -- 268
	if not prompt then -- 268
		return "" -- 269
	end -- 269
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 269
		return prompt -- 270
	end -- 270
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 271
	if offset == nil then -- 271
		return prompt -- 272
	end -- 272
	return string.sub(prompt, 1, offset - 1) -- 273
end -- 268
local function canWriteStepLLMDebug(shared, stepId) -- 276
	if stepId == nil then -- 276
		stepId = shared.step + 1 -- 276
	end -- 276
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 277
end -- 276
local function ensureDirRecursive(dir) -- 284
	if not dir then -- 284
		return false -- 285
	end -- 285
	if Content:exist(dir) then -- 285
		return Content:isdir(dir) -- 286
	end -- 286
	local parent = Path:getPath(dir) -- 287
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 287
		return false -- 289
	end -- 289
	return Content:mkdir(dir) -- 291
end -- 284
local function encodeDebugJSON(value) -- 294
	local text, err = safeJsonEncode(value) -- 295
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 296
end -- 294
local function getStepLLMDebugDir(shared) -- 299
	return Path( -- 300
		shared.workingDir, -- 301
		".agent", -- 302
		tostring(shared.sessionId), -- 303
		tostring(shared.taskId) -- 304
	) -- 304
end -- 299
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 308
	return Path( -- 309
		getStepLLMDebugDir(shared), -- 309
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 309
	) -- 309
end -- 308
local function getLatestStepLLMDebugSeq(shared, stepId) -- 312
	if not canWriteStepLLMDebug(shared, stepId) then -- 312
		return 0 -- 313
	end -- 313
	local dir = getStepLLMDebugDir(shared) -- 314
	if not Content:exist(dir) or not Content:isdir(dir) then -- 314
		return 0 -- 315
	end -- 315
	local latest = 0 -- 316
	for ____, file in ipairs(Content:getFiles(dir)) do -- 317
		do -- 317
			local name = Path:getFilename(file) -- 318
			local seqText = string.match( -- 319
				name, -- 319
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 319
			) -- 319
			if seqText ~= nil then -- 319
				latest = math.max( -- 321
					latest, -- 321
					tonumber(seqText) -- 321
				) -- 321
				goto __continue37 -- 322
			end -- 322
			local legacyMatch = string.match( -- 324
				name, -- 324
				("^" .. tostring(stepId)) .. "_in%.md$" -- 324
			) -- 324
			if legacyMatch ~= nil then -- 324
				latest = math.max(latest, 1) -- 326
			end -- 326
		end -- 326
		::__continue37:: -- 326
	end -- 326
	return latest -- 329
end -- 312
local function writeStepLLMDebugFile(path, content) -- 332
	if not Content:save(path, content) then -- 332
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 334
		return false -- 335
	end -- 335
	return true -- 337
end -- 332
local function createStepLLMDebugPair(shared, stepId, inContent) -- 340
	if not canWriteStepLLMDebug(shared, stepId) then -- 340
		return 0 -- 341
	end -- 341
	local dir = getStepLLMDebugDir(shared) -- 342
	if not ensureDirRecursive(dir) then -- 342
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 344
		return 0 -- 345
	end -- 345
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 347
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 348
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 349
	if not writeStepLLMDebugFile(inPath, inContent) then -- 349
		return 0 -- 351
	end -- 351
	writeStepLLMDebugFile(outPath, "") -- 353
	return seq -- 354
end -- 340
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 357
	if not canWriteStepLLMDebug(shared, stepId) then -- 357
		return -- 358
	end -- 358
	local dir = getStepLLMDebugDir(shared) -- 359
	if not ensureDirRecursive(dir) then -- 359
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 361
		return -- 362
	end -- 362
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 364
	if latestSeq <= 0 then -- 364
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 366
		writeStepLLMDebugFile(outPath, content) -- 367
		return -- 368
	end -- 368
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 370
	writeStepLLMDebugFile(outPath, content) -- 371
end -- 357
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 374
	if not canWriteStepLLMDebug(shared, stepId) then -- 374
		return -- 375
	end -- 375
	local sections = { -- 376
		"# LLM Input", -- 377
		"session_id: " .. tostring(shared.sessionId), -- 378
		"task_id: " .. tostring(shared.taskId), -- 379
		"step_id: " .. tostring(stepId), -- 380
		"phase: " .. phase, -- 381
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 382
		"## Options", -- 383
		"```json", -- 384
		encodeDebugJSON(options), -- 385
		"```" -- 386
	} -- 386
	do -- 386
		local i = 0 -- 388
		while i < #messages do -- 388
			local message = messages[i + 1] -- 389
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 390
			sections[#sections + 1] = encodeDebugJSON(message) -- 391
			i = i + 1 -- 388
		end -- 388
	end -- 388
	createStepLLMDebugPair( -- 393
		shared, -- 393
		stepId, -- 393
		table.concat(sections, "\n") -- 393
	) -- 393
end -- 374
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 396
	if not canWriteStepLLMDebug(shared, stepId) then -- 396
		return -- 397
	end -- 397
	local ____array_0 = __TS__SparseArrayNew( -- 397
		"# LLM Output", -- 399
		"session_id: " .. tostring(shared.sessionId), -- 400
		"task_id: " .. tostring(shared.taskId), -- 401
		"step_id: " .. tostring(stepId), -- 402
		"phase: " .. phase, -- 403
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 404
		table.unpack(meta and ({ -- 405
			"## Meta", -- 405
			"```json", -- 405
			encodeDebugJSON(meta), -- 405
			"```" -- 405
		}) or ({})) -- 405
	) -- 405
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 405
	local sections = {__TS__SparseArraySpread(____array_0)} -- 398
	updateLatestStepLLMDebugOutput( -- 409
		shared, -- 409
		stepId, -- 409
		table.concat(sections, "\n") -- 409
	) -- 409
end -- 396
local function toJson(value) -- 412
	local text, err = safeJsonEncode(value) -- 413
	if text ~= nil then -- 413
		return text -- 414
	end -- 414
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 415
end -- 412
local function utf8TakeHead(text, maxChars) -- 425
	if maxChars <= 0 or text == "" then -- 425
		return "" -- 426
	end -- 426
	local nextPos = utf8.offset(text, maxChars + 1) -- 427
	if nextPos == nil then -- 427
		return text -- 428
	end -- 428
	return string.sub(text, 1, nextPos - 1) -- 429
end -- 425
local function limitReadContentForHistory(content, tool) -- 446
	local lines = __TS__StringSplit(content, "\n") -- 447
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 448
	local limitedByLines = overLineLimit and table.concat( -- 449
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 450
		"\n" -- 450
	) or content -- 450
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 450
		return content -- 453
	end -- 453
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 455
	local reasons = {} -- 458
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 458
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 459
	end -- 459
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 459
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 460
	end -- 460
	local hint = "Narrow the requested line range." -- 461
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 462
end -- 446
local function summarizeEditTextParamForHistory(value, key) -- 465
	if type(value) ~= "string" then -- 465
		return nil -- 466
	end -- 466
	local text = value -- 467
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 468
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 469
end -- 465
local function sanitizeReadResultForHistory(tool, result) -- 477
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 477
		return result -- 479
	end -- 479
	local clone = {} -- 481
	for key in pairs(result) do -- 482
		clone[key] = result[key] -- 483
	end -- 483
	clone.content = limitReadContentForHistory(result.content, tool) -- 485
	return clone -- 486
end -- 477
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 489
	local shown = math.min(#items, maxItems) -- 493
	local out = {} -- 494
	do -- 494
		local i = 0 -- 495
		while i < shown do -- 495
			local row = items[i + 1] -- 496
			out[#out + 1] = { -- 497
				file = row.file, -- 498
				line = row.line, -- 499
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 500
			} -- 500
			i = i + 1 -- 495
		end -- 495
	end -- 495
	return out -- 505
end -- 489
local function sanitizeSearchResultForHistory(tool, result) -- 508
	if result.success ~= true or not isArray(result.results) then -- 508
		return result -- 512
	end -- 512
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 512
		return result -- 513
	end -- 513
	local clone = {} -- 514
	for key in pairs(result) do -- 515
		clone[key] = result[key] -- 516
	end -- 516
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 518
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 519
	if tool == "grep_files" and isArray(result.groupedResults) then -- 519
		local grouped = result.groupedResults -- 524
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 525
		local sanitizedGroups = {} -- 526
		do -- 526
			local i = 0 -- 527
			while i < shown do -- 527
				local row = grouped[i + 1] -- 528
				sanitizedGroups[#sanitizedGroups + 1] = { -- 529
					file = row.file, -- 530
					totalMatches = row.totalMatches, -- 531
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 532
				} -- 532
				i = i + 1 -- 527
			end -- 527
		end -- 527
		clone.groupedResults = sanitizedGroups -- 537
	end -- 537
	return clone -- 539
end -- 508
local function sanitizeListFilesResultForHistory(result) -- 542
	if result.success ~= true or not isArray(result.files) then -- 542
		return result -- 543
	end -- 543
	local clone = {} -- 544
	for key in pairs(result) do -- 545
		clone[key] = result[key] -- 546
	end -- 546
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 548
	return clone -- 549
end -- 542
local function sanitizeActionParamsForHistory(tool, params) -- 552
	if tool ~= "edit_file" then -- 552
		return params -- 553
	end -- 553
	local clone = {} -- 554
	for key in pairs(params) do -- 555
		if key == "old_str" then -- 555
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 557
		elseif key == "new_str" then -- 557
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 559
		else -- 559
			clone[key] = params[key] -- 561
		end -- 561
	end -- 561
	return clone -- 564
end -- 552
local function maybeCompressHistory(shared) -- 584
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 584
		local ____shared_5 = shared -- 585
		local memory = ____shared_5.memory -- 585
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 586
		local changed = false -- 587
		do -- 587
			local round = 0 -- 588
			while round < maxRounds do -- 588
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 589
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 593
				if not memory.compressor:shouldCompress(shared.messages, systemPrompt, toolDefinitions) then -- 593
					if changed then -- 593
						persistHistoryState(shared) -- 602
					end -- 602
					return ____awaiter_resolve(nil) -- 602
				end -- 602
				local compressionRound = round + 1 -- 606
				shared.step = shared.step + 1 -- 607
				local stepId = shared.step -- 608
				local pendingMessages = #shared.messages -- 609
				emitAgentEvent( -- 610
					shared, -- 610
					{ -- 610
						type = "memory_compression_started", -- 611
						sessionId = shared.sessionId, -- 612
						taskId = shared.taskId, -- 613
						step = stepId, -- 614
						tool = "compress_memory", -- 615
						reason = getMemoryCompressionStartReason(shared), -- 616
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 617
					} -- 617
				) -- 617
				local result = __TS__Await(memory.compressor:compress( -- 623
					shared.messages, -- 624
					systemPrompt, -- 625
					toolDefinitions, -- 626
					shared.llmOptions, -- 627
					shared.llmMaxTry, -- 628
					shared.decisionMode, -- 629
					{ -- 630
						onInput = function(____, phase, messages, options) -- 631
							saveStepLLMDebugInput( -- 632
								shared, -- 632
								stepId, -- 632
								phase, -- 632
								messages, -- 632
								options -- 632
							) -- 632
						end, -- 631
						onOutput = function(____, phase, text, meta) -- 634
							saveStepLLMDebugOutput( -- 635
								shared, -- 635
								stepId, -- 635
								phase, -- 635
								text, -- 635
								meta -- 635
							) -- 635
						end -- 634
					} -- 634
				)) -- 634
				if not (result and result.success and result.compressedCount > 0) then -- 634
					emitAgentEvent( -- 640
						shared, -- 640
						{ -- 640
							type = "memory_compression_finished", -- 641
							sessionId = shared.sessionId, -- 642
							taskId = shared.taskId, -- 643
							step = stepId, -- 644
							tool = "compress_memory", -- 645
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 646
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 650
						} -- 650
					) -- 650
					if changed then -- 650
						persistHistoryState(shared) -- 658
					end -- 658
					return ____awaiter_resolve(nil) -- 658
				end -- 658
				emitAgentEvent( -- 662
					shared, -- 662
					{ -- 662
						type = "memory_compression_finished", -- 663
						sessionId = shared.sessionId, -- 664
						taskId = shared.taskId, -- 665
						step = stepId, -- 666
						tool = "compress_memory", -- 667
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 668
						result = { -- 669
							success = true, -- 670
							round = compressionRound, -- 671
							compressedCount = result.compressedCount, -- 672
							historyEntryPreview = summarizeHistoryEntryPreview(result.historyEntry) -- 673
						} -- 673
					} -- 673
				) -- 673
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 676
				changed = true -- 677
				Log( -- 678
					"Info", -- 678
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 678
				) -- 678
				round = round + 1 -- 588
			end -- 588
		end -- 588
		if changed then -- 588
			persistHistoryState(shared) -- 681
		end -- 681
	end) -- 681
end -- 584
local function compactAllHistory(shared) -- 685
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 685
		local ____shared_12 = shared -- 686
		local memory = ____shared_12.memory -- 686
		local rounds = 0 -- 687
		local totalCompressed = 0 -- 688
		while #shared.messages > 0 do -- 688
			if shared.stopToken.stopped then -- 688
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 691
				return ____awaiter_resolve( -- 691
					nil, -- 691
					emitAgentTaskFinishEvent( -- 692
						shared, -- 692
						false, -- 692
						getCancelledReason(shared) -- 692
					) -- 692
				) -- 692
			end -- 692
			local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 694
			local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 695
			rounds = rounds + 1 -- 698
			shared.step = shared.step + 1 -- 699
			local stepId = shared.step -- 700
			local pendingMessages = #shared.messages -- 701
			emitAgentEvent( -- 702
				shared, -- 702
				{ -- 702
					type = "memory_compression_started", -- 703
					sessionId = shared.sessionId, -- 704
					taskId = shared.taskId, -- 705
					step = stepId, -- 706
					tool = "compress_memory", -- 707
					reason = getMemoryCompressionStartReason(shared), -- 708
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 709
				} -- 709
			) -- 709
			local result = __TS__Await(memory.compressor:compress( -- 716
				shared.messages, -- 717
				systemPrompt, -- 718
				toolDefinitions, -- 719
				shared.llmOptions, -- 720
				shared.llmMaxTry, -- 721
				shared.decisionMode, -- 722
				{ -- 723
					onInput = function(____, phase, messages, options) -- 724
						saveStepLLMDebugInput( -- 725
							shared, -- 725
							stepId, -- 725
							phase, -- 725
							messages, -- 725
							options -- 725
						) -- 725
					end, -- 724
					onOutput = function(____, phase, text, meta) -- 727
						saveStepLLMDebugOutput( -- 728
							shared, -- 728
							stepId, -- 728
							phase, -- 728
							text, -- 728
							meta -- 728
						) -- 728
					end -- 727
				}, -- 727
				"budget_max" -- 731
			)) -- 731
			if not (result and result.success and result.compressedCount > 0) then -- 731
				emitAgentEvent( -- 734
					shared, -- 734
					{ -- 734
						type = "memory_compression_finished", -- 735
						sessionId = shared.sessionId, -- 736
						taskId = shared.taskId, -- 737
						step = stepId, -- 738
						tool = "compress_memory", -- 739
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 740
						result = { -- 744
							success = false, -- 745
							rounds = rounds, -- 746
							error = result and result.error or "compression returned no changes", -- 747
							compressedCount = result and result.compressedCount or 0, -- 748
							fullCompaction = true -- 749
						} -- 749
					} -- 749
				) -- 749
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 752
				return ____awaiter_resolve( -- 752
					nil, -- 752
					emitAgentTaskFinishEvent(shared, false, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 753
				) -- 753
			end -- 753
			emitAgentEvent( -- 758
				shared, -- 758
				{ -- 758
					type = "memory_compression_finished", -- 759
					sessionId = shared.sessionId, -- 760
					taskId = shared.taskId, -- 761
					step = stepId, -- 762
					tool = "compress_memory", -- 763
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 764
					result = { -- 765
						success = true, -- 766
						round = rounds, -- 767
						compressedCount = result.compressedCount, -- 768
						historyEntryPreview = summarizeHistoryEntryPreview(result.historyEntry), -- 769
						fullCompaction = true -- 770
					} -- 770
				} -- 770
			) -- 770
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 773
			totalCompressed = totalCompressed + result.compressedCount -- 774
			persistHistoryState(shared) -- 775
			Log( -- 776
				"Info", -- 776
				((("[Memory] Full compaction compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 776
			) -- 776
		end -- 776
		Tools.setTaskStatus(shared.taskId, "DONE") -- 778
		return ____awaiter_resolve( -- 778
			nil, -- 778
			emitAgentTaskFinishEvent( -- 779
				shared, -- 780
				true, -- 781
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 782
			) -- 782
		) -- 782
	end) -- 782
end -- 685
local function resetSessionHistory(shared) -- 788
	shared.messages = {} -- 789
	persistHistoryState(shared) -- 790
	Tools.setTaskStatus(shared.taskId, "DONE") -- 791
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 792
end -- 788
local function isKnownToolName(name) -- 801
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 802
end -- 801
local function getFinishMessage(params, fallback) -- 812
	if fallback == nil then -- 812
		fallback = "" -- 812
	end -- 812
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 812
		return __TS__StringTrim(params.message) -- 814
	end -- 814
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 814
		return __TS__StringTrim(params.response) -- 817
	end -- 817
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 817
		return __TS__StringTrim(params.summary) -- 820
	end -- 820
	return __TS__StringTrim(fallback) -- 822
end -- 812
local function appendConversationMessage(shared, message) -- 844
	local ____shared_messages_21 = shared.messages -- 844
	____shared_messages_21[#____shared_messages_21 + 1] = __TS__ObjectAssign( -- 845
		{}, -- 845
		message, -- 846
		{ -- 845
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 847
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 848
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 849
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 850
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 851
		} -- 851
	) -- 851
end -- 844
local function ensureToolCallId(toolCallId) -- 855
	if toolCallId and toolCallId ~= "" then -- 855
		return toolCallId -- 856
	end -- 856
	return createLocalToolCallId() -- 857
end -- 855
local function appendToolResultMessage(shared, action) -- 860
	appendConversationMessage( -- 861
		shared, -- 861
		{ -- 861
			role = "tool", -- 862
			tool_call_id = action.toolCallId, -- 863
			name = action.tool, -- 864
			content = action.result and toJson(action.result) or "" -- 865
		} -- 865
	) -- 865
end -- 860
local function parseXMLToolCallObjectFromText(text) -- 869
	local children = parseXMLObjectFromText(text, "tool_call") -- 870
	if not children.success then -- 870
		return children -- 871
	end -- 871
	local rawObj = children.obj -- 872
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 873
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 874
	if not params.success then -- 874
		return {success = false, message = params.message} -- 878
	end -- 878
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 880
end -- 869
local function llm(shared, messages, phase) -- 899
	if phase == nil then -- 899
		phase = "decision_xml" -- 902
	end -- 902
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 902
		local stepId = shared.step + 1 -- 904
		saveStepLLMDebugInput( -- 905
			shared, -- 905
			stepId, -- 905
			phase, -- 905
			messages, -- 905
			shared.llmOptions -- 905
		) -- 905
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 906
		if res.success then -- 906
			local ____opt_26 = res.response.choices -- 906
			local ____opt_24 = ____opt_26 and ____opt_26[1] -- 906
			local ____opt_22 = ____opt_24 and ____opt_24.message -- 906
			local text = ____opt_22 and ____opt_22.content -- 908
			if text then -- 908
				saveStepLLMDebugOutput( -- 910
					shared, -- 910
					stepId, -- 910
					phase, -- 910
					text, -- 910
					{success = true} -- 910
				) -- 910
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 910
			else -- 910
				saveStepLLMDebugOutput( -- 913
					shared, -- 913
					stepId, -- 913
					phase, -- 913
					"empty LLM response", -- 913
					{success = false} -- 913
				) -- 913
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 913
			end -- 913
		else -- 913
			saveStepLLMDebugOutput( -- 917
				shared, -- 917
				stepId, -- 917
				phase, -- 917
				res.raw or res.message, -- 917
				{success = false} -- 917
			) -- 917
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 917
		end -- 917
	end) -- 917
end -- 899
local function parseDecisionObject(rawObj) -- 934
	if type(rawObj.tool) ~= "string" then -- 934
		return {success = false, message = "missing tool"} -- 935
	end -- 935
	local tool = rawObj.tool -- 936
	if not isKnownToolName(tool) then -- 936
		return {success = false, message = "unknown tool: " .. tool} -- 938
	end -- 938
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 940
	if tool ~= "finish" and (not reason or reason == "") then -- 940
		return {success = false, message = tool .. " requires top-level reason"} -- 944
	end -- 944
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 946
	return {success = true, tool = tool, params = params, reason = reason} -- 947
end -- 934
local function parseDecisionToolCall(functionName, rawObj) -- 955
	if not isKnownToolName(functionName) then -- 955
		return {success = false, message = "unknown tool: " .. functionName} -- 957
	end -- 957
	if rawObj == nil or rawObj == nil then -- 957
		return {success = true, tool = functionName, params = {}} -- 960
	end -- 960
	if not isRecord(rawObj) then -- 960
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 963
	end -- 963
	return {success = true, tool = functionName, params = rawObj} -- 965
end -- 955
local function getDecisionPath(params) -- 972
	if type(params.path) == "string" then -- 972
		return __TS__StringTrim(params.path) -- 973
	end -- 973
	if type(params.target_file) == "string" then -- 973
		return __TS__StringTrim(params.target_file) -- 974
	end -- 974
	return "" -- 975
end -- 972
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 978
	local num = __TS__Number(value) -- 979
	if not __TS__NumberIsFinite(num) then -- 979
		num = fallback -- 980
	end -- 980
	num = math.floor(num) -- 981
	if num < minValue then -- 981
		num = minValue -- 982
	end -- 982
	if maxValue ~= nil and num > maxValue then -- 982
		num = maxValue -- 983
	end -- 983
	return num -- 984
end -- 978
local function validateDecision(tool, params) -- 987
	if tool == "finish" then -- 987
		local message = getFinishMessage(params) -- 992
		if message == "" then -- 992
			return {success = false, message = "finish requires params.message"} -- 993
		end -- 993
		params.message = message -- 994
		return {success = true, params = params} -- 995
	end -- 995
	if tool == "read_file" then -- 995
		local path = getDecisionPath(params) -- 999
		if path == "" then -- 999
			return {success = false, message = "read_file requires path"} -- 1000
		end -- 1000
		params.path = path -- 1001
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 1002
		local ____params_endLine_28 = params.endLine -- 1003
		if ____params_endLine_28 == nil then -- 1003
			____params_endLine_28 = READ_FILE_DEFAULT_LIMIT -- 1003
		end -- 1003
		local endLineRaw = ____params_endLine_28 -- 1003
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 1004
		params.startLine = startLine -- 1005
		params.endLine = endLine -- 1006
		return {success = true, params = params} -- 1007
	end -- 1007
	if tool == "edit_file" then -- 1007
		local path = getDecisionPath(params) -- 1011
		if path == "" then -- 1011
			return {success = false, message = "edit_file requires path"} -- 1012
		end -- 1012
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1013
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1014
		params.path = path -- 1015
		params.old_str = oldStr -- 1016
		params.new_str = newStr -- 1017
		return {success = true, params = params} -- 1018
	end -- 1018
	if tool == "delete_file" then -- 1018
		local targetFile = getDecisionPath(params) -- 1022
		if targetFile == "" then -- 1022
			return {success = false, message = "delete_file requires target_file"} -- 1023
		end -- 1023
		params.target_file = targetFile -- 1024
		return {success = true, params = params} -- 1025
	end -- 1025
	if tool == "grep_files" then -- 1025
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1029
		if pattern == "" then -- 1029
			return {success = false, message = "grep_files requires pattern"} -- 1030
		end -- 1030
		params.pattern = pattern -- 1031
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1032
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1033
		return {success = true, params = params} -- 1034
	end -- 1034
	if tool == "search_dora_api" then -- 1034
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1038
		if pattern == "" then -- 1038
			return {success = false, message = "search_dora_api requires pattern"} -- 1039
		end -- 1039
		params.pattern = pattern -- 1040
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1041
		return {success = true, params = params} -- 1042
	end -- 1042
	if tool == "glob_files" then -- 1042
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1046
		return {success = true, params = params} -- 1047
	end -- 1047
	if tool == "build" then -- 1047
		local path = getDecisionPath(params) -- 1051
		if path ~= "" then -- 1051
			params.path = path -- 1053
		end -- 1053
		return {success = true, params = params} -- 1055
	end -- 1055
	return {success = true, params = params} -- 1058
end -- 987
local function createFunctionToolSchema(name, description, properties, required) -- 1061
	if required == nil then -- 1061
		required = {} -- 1065
	end -- 1065
	local parameters = {type = "object", properties = properties} -- 1067
	if #required > 0 then -- 1067
		parameters.required = required -- 1072
	end -- 1072
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1074
end -- 1061
local function buildDecisionToolSchema() -- 1084
	return { -- 1085
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Parameters: path, startLine(optional), endLine(optional). Line numbering starts with 1. startLine defaults to 1 and endLine defaults to 300.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "1-based starting line number. Defaults to 1."}, endLine = {type = "number", description = "1-based ending line number. Defaults to 300."}}, {"path"}), -- 1086
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 1096
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1106
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1114
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1118
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1119
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1120
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1121
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1122
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1123
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1124
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1125
		}, {"pattern"}), -- 1125
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1129
		createFunctionToolSchema( -- 1138
			"search_dora_api", -- 1139
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1139
			{ -- 1141
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1142
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1143
				programmingLanguage = {type = "string", enum = { -- 1144
					"ts", -- 1146
					"tsx", -- 1146
					"lua", -- 1146
					"yue", -- 1146
					"teal", -- 1146
					"tl", -- 1146
					"wa" -- 1146
				}, description = "Preferred language variant to search."}, -- 1146
				limit = { -- 1149
					type = "number", -- 1149
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1149
				}, -- 1149
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1150
			}, -- 1150
			{"pattern"} -- 1152
		), -- 1152
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}) -- 1154
	} -- 1154
end -- 1084
local function sanitizeMessagesForLLMInput(messages) -- 1182
	local sanitized = {} -- 1183
	local droppedAssistantToolCalls = 0 -- 1184
	local droppedToolResults = 0 -- 1185
	do -- 1185
		local i = 0 -- 1186
		while i < #messages do -- 1186
			do -- 1186
				local message = messages[i + 1] -- 1187
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1187
					local requiredIds = {} -- 1189
					do -- 1189
						local j = 0 -- 1190
						while j < #message.tool_calls do -- 1190
							local toolCall = message.tool_calls[j + 1] -- 1191
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1192
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1192
								requiredIds[#requiredIds + 1] = id -- 1194
							end -- 1194
							j = j + 1 -- 1190
						end -- 1190
					end -- 1190
					if #requiredIds == 0 then -- 1190
						sanitized[#sanitized + 1] = message -- 1198
						goto __continue180 -- 1199
					end -- 1199
					local matchedIds = {} -- 1201
					local matchedTools = {} -- 1202
					local j = i + 1 -- 1203
					while j < #messages do -- 1203
						local toolMessage = messages[j + 1] -- 1205
						if toolMessage.role ~= "tool" then -- 1205
							break -- 1206
						end -- 1206
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1207
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1207
							matchedIds[toolCallId] = true -- 1209
							matchedTools[#matchedTools + 1] = toolMessage -- 1210
						else -- 1210
							droppedToolResults = droppedToolResults + 1 -- 1212
						end -- 1212
						j = j + 1 -- 1214
					end -- 1214
					local complete = true -- 1216
					do -- 1216
						local j = 0 -- 1217
						while j < #requiredIds do -- 1217
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1217
								complete = false -- 1219
								break -- 1220
							end -- 1220
							j = j + 1 -- 1217
						end -- 1217
					end -- 1217
					if complete then -- 1217
						__TS__ArrayPush( -- 1224
							sanitized, -- 1224
							message, -- 1224
							table.unpack(matchedTools) -- 1224
						) -- 1224
					else -- 1224
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1226
						droppedToolResults = droppedToolResults + #matchedTools -- 1227
					end -- 1227
					i = j - 1 -- 1229
					goto __continue180 -- 1230
				end -- 1230
				if message.role == "tool" then -- 1230
					droppedToolResults = droppedToolResults + 1 -- 1233
					goto __continue180 -- 1234
				end -- 1234
				sanitized[#sanitized + 1] = message -- 1236
			end -- 1236
			::__continue180:: -- 1236
			i = i + 1 -- 1186
		end -- 1186
	end -- 1186
	return sanitized -- 1238
end -- 1182
local function getUnconsolidatedMessages(shared) -- 1241
	return sanitizeMessagesForLLMInput(shared.messages) -- 1242
end -- 1241
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1245
	if attempt == nil then -- 1245
		attempt = 1 -- 1245
	end -- 1245
	local messages = { -- 1246
		{ -- 1247
			role = "system", -- 1247
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1247
		}, -- 1247
		table.unpack(getUnconsolidatedMessages(shared)) -- 1248
	} -- 1248
	if lastError and lastError ~= "" then -- 1248
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1251
		messages[#messages + 1] = { -- 1254
			role = "user", -- 1255
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1256
		} -- 1256
	end -- 1256
	return messages -- 1263
end -- 1245
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 1270
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 1277
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 1278
	local repairPrompt = replacePromptVars( -- 1286
		shared.promptPack.xmlDecisionRepairPrompt, -- 1286
		{ -- 1286
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 1287
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 1288
			CANDIDATE_SECTION = candidateSection, -- 1289
			LAST_ERROR = lastError, -- 1290
			ATTEMPT = tostring(attempt) -- 1291
		} -- 1291
	) -- 1291
	return {{role = "system", content = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only."}, {role = "user", content = repairPrompt}} -- 1293
end -- 1270
local function tryParseAndValidateDecision(rawText) -- 1315
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 1316
	if not parsed.success then -- 1316
		return {success = false, message = parsed.message, raw = rawText} -- 1318
	end -- 1318
	local decision = parseDecisionObject(parsed.obj) -- 1320
	if not decision.success then -- 1320
		return {success = false, message = decision.message, raw = rawText} -- 1322
	end -- 1322
	local validation = validateDecision(decision.tool, decision.params) -- 1324
	if not validation.success then -- 1324
		return {success = false, message = validation.message, raw = rawText} -- 1326
	end -- 1326
	decision.params = validation.params -- 1328
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 1329
	return decision -- 1330
end -- 1315
local function normalizeLineEndings(text) -- 1333
	local res = string.gsub(text, "\r\n", "\n") -- 1334
	res = string.gsub(res, "\r", "\n") -- 1335
	return res -- 1336
end -- 1333
local function countOccurrences(text, searchStr) -- 1339
	if searchStr == "" then -- 1339
		return 0 -- 1340
	end -- 1340
	local count = 0 -- 1341
	local pos = 0 -- 1342
	while true do -- 1342
		local idx = (string.find( -- 1344
			text, -- 1344
			searchStr, -- 1344
			math.max(pos + 1, 1), -- 1344
			true -- 1344
		) or 0) - 1 -- 1344
		if idx < 0 then -- 1344
			break -- 1345
		end -- 1345
		count = count + 1 -- 1346
		pos = idx + #searchStr -- 1347
	end -- 1347
	return count -- 1349
end -- 1339
local function replaceFirst(text, oldStr, newStr) -- 1352
	if oldStr == "" then -- 1352
		return text -- 1353
	end -- 1353
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 1354
	if idx < 0 then -- 1354
		return text -- 1355
	end -- 1355
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 1356
end -- 1352
local function splitLines(text) -- 1359
	return __TS__StringSplit(text, "\n") -- 1360
end -- 1359
local function getLeadingWhitespace(text) -- 1363
	local i = 0 -- 1364
	while i < #text do -- 1364
		local ch = __TS__StringAccess(text, i) -- 1366
		if ch ~= " " and ch ~= "\t" then -- 1366
			break -- 1367
		end -- 1367
		i = i + 1 -- 1368
	end -- 1368
	return __TS__StringSubstring(text, 0, i) -- 1370
end -- 1363
local function getCommonIndentPrefix(lines) -- 1373
	local common -- 1374
	do -- 1374
		local i = 0 -- 1375
		while i < #lines do -- 1375
			do -- 1375
				local line = lines[i + 1] -- 1376
				if __TS__StringTrim(line) == "" then -- 1376
					goto __continue219 -- 1377
				end -- 1377
				local indent = getLeadingWhitespace(line) -- 1378
				if common == nil then -- 1378
					common = indent -- 1380
					goto __continue219 -- 1381
				end -- 1381
				local j = 0 -- 1383
				local maxLen = math.min(#common, #indent) -- 1384
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 1384
					j = j + 1 -- 1386
				end -- 1386
				common = __TS__StringSubstring(common, 0, j) -- 1388
				if common == "" then -- 1388
					break -- 1389
				end -- 1389
			end -- 1389
			::__continue219:: -- 1389
			i = i + 1 -- 1375
		end -- 1375
	end -- 1375
	return common or "" -- 1391
end -- 1373
local function removeIndentPrefix(line, indent) -- 1394
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 1394
		return __TS__StringSubstring(line, #indent) -- 1396
	end -- 1396
	local lineIndent = getLeadingWhitespace(line) -- 1398
	local j = 0 -- 1399
	local maxLen = math.min(#lineIndent, #indent) -- 1400
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 1400
		j = j + 1 -- 1402
	end -- 1402
	return __TS__StringSubstring(line, j) -- 1404
end -- 1394
local function dedentLines(lines) -- 1407
	local indent = getCommonIndentPrefix(lines) -- 1408
	return { -- 1409
		indent = indent, -- 1410
		lines = __TS__ArrayMap( -- 1411
			lines, -- 1411
			function(____, line) return removeIndentPrefix(line, indent) end -- 1411
		) -- 1411
	} -- 1411
end -- 1407
local function joinLines(lines) -- 1415
	return table.concat(lines, "\n") -- 1416
end -- 1415
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 1419
	local contentLines = splitLines(content) -- 1424
	local oldLines = splitLines(oldStr) -- 1425
	if #oldLines == 0 then -- 1425
		return {success = false, message = "old_str not found in file"} -- 1427
	end -- 1427
	local dedentedOld = dedentLines(oldLines) -- 1429
	local dedentedOldText = joinLines(dedentedOld.lines) -- 1430
	local dedentedNew = dedentLines(splitLines(newStr)) -- 1431
	local matches = {} -- 1432
	do -- 1432
		local start = 0 -- 1433
		while start <= #contentLines - #oldLines do -- 1433
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 1434
			local dedentedCandidate = dedentLines(candidateLines) -- 1435
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 1435
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 1437
			end -- 1437
			start = start + 1 -- 1433
		end -- 1433
	end -- 1433
	if #matches == 0 then -- 1433
		return {success = false, message = "old_str not found in file"} -- 1445
	end -- 1445
	if #matches > 1 then -- 1445
		return { -- 1448
			success = false, -- 1449
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 1450
		} -- 1450
	end -- 1450
	local match = matches[1] -- 1453
	local rebuiltNewLines = __TS__ArrayMap( -- 1454
		dedentedNew.lines, -- 1454
		function(____, line) return line == "" and "" or match.indent .. line end -- 1454
	) -- 1454
	local ____array_31 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 1454
	__TS__SparseArrayPush( -- 1454
		____array_31, -- 1454
		table.unpack(rebuiltNewLines) -- 1457
	) -- 1457
	__TS__SparseArrayPush( -- 1457
		____array_31, -- 1457
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 1458
	) -- 1458
	local nextLines = {__TS__SparseArraySpread(____array_31)} -- 1455
	return { -- 1460
		success = true, -- 1460
		content = joinLines(nextLines) -- 1460
	} -- 1460
end -- 1419
local MainDecisionAgent = __TS__Class() -- 1463
MainDecisionAgent.name = "MainDecisionAgent" -- 1463
__TS__ClassExtends(MainDecisionAgent, Node) -- 1463
function MainDecisionAgent.prototype.prep(self, shared) -- 1464
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1464
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1464
			return ____awaiter_resolve(nil, {shared = shared}) -- 1464
		end -- 1464
		__TS__Await(maybeCompressHistory(shared)) -- 1469
		return ____awaiter_resolve(nil, {shared = shared}) -- 1469
	end) -- 1469
end -- 1464
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 1474
	if attempt == nil then -- 1474
		attempt = 1 -- 1477
	end -- 1477
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1477
		if shared.stopToken.stopped then -- 1477
			return ____awaiter_resolve( -- 1477
				nil, -- 1477
				{ -- 1481
					success = false, -- 1481
					message = getCancelledReason(shared) -- 1481
				} -- 1481
			) -- 1481
		end -- 1481
		Log( -- 1483
			"Info", -- 1483
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1483
		) -- 1483
		local tools = buildDecisionToolSchema() -- 1484
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1485
		local stepId = shared.step + 1 -- 1486
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1487
		saveStepLLMDebugInput( -- 1491
			shared, -- 1491
			stepId, -- 1491
			"decision_tool_calling", -- 1491
			messages, -- 1491
			llmOptions -- 1491
		) -- 1491
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1492
		if shared.stopToken.stopped then -- 1492
			return ____awaiter_resolve( -- 1492
				nil, -- 1492
				{ -- 1494
					success = false, -- 1494
					message = getCancelledReason(shared) -- 1494
				} -- 1494
			) -- 1494
		end -- 1494
		if not res.success then -- 1494
			saveStepLLMDebugOutput( -- 1497
				shared, -- 1497
				stepId, -- 1497
				"decision_tool_calling", -- 1497
				res.raw or res.message, -- 1497
				{success = false} -- 1497
			) -- 1497
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1498
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1498
		end -- 1498
		saveStepLLMDebugOutput( -- 1501
			shared, -- 1501
			stepId, -- 1501
			"decision_tool_calling", -- 1501
			encodeDebugJSON(res.response), -- 1501
			{success = true} -- 1501
		) -- 1501
		local choice = res.response.choices and res.response.choices[1] -- 1502
		local message = choice and choice.message -- 1503
		local toolCalls = message and message.tool_calls -- 1504
		local toolCall = toolCalls and toolCalls[1] -- 1505
		local fn = toolCall and toolCall["function"] -- 1506
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 1507
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1510
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1513
		Log( -- 1516
			"Info", -- 1516
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1516
		) -- 1516
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1516
			if messageContent and messageContent ~= "" then -- 1516
				Log( -- 1519
					"Info", -- 1519
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1519
				) -- 1519
				return ____awaiter_resolve(nil, { -- 1519
					success = true, -- 1521
					tool = "finish", -- 1522
					params = {}, -- 1523
					reason = messageContent, -- 1524
					reasoningContent = reasoningContent, -- 1525
					directSummary = messageContent -- 1526
				}) -- 1526
			end -- 1526
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1529
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1529
		end -- 1529
		local functionName = fn.name -- 1536
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1537
		Log( -- 1538
			"Info", -- 1538
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1538
		) -- 1538
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1539
			local rawObj, err = safeJsonDecode(argsText) -- 1540
			if err ~= nil or rawObj == nil then -- 1540
				return {__error = tostring(err)} -- 1542
			end -- 1542
			return rawObj -- 1544
		end)() -- 1539
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 1539
			local err = tostring(rawArgs.__error) -- 1547
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1548
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1548
		end -- 1548
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1555
		if not decision.success then -- 1555
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1557
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1557
		end -- 1557
		local validation = validateDecision(decision.tool, decision.params) -- 1564
		if not validation.success then -- 1564
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1566
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1566
		end -- 1566
		decision.params = validation.params -- 1573
		decision.toolCallId = ensureToolCallId(toolCallId) -- 1574
		decision.reason = messageContent -- 1575
		decision.reasoningContent = reasoningContent -- 1576
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1577
		return ____awaiter_resolve(nil, decision) -- 1577
	end) -- 1577
end -- 1474
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 1581
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1581
		Log( -- 1586
			"Info", -- 1586
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 1586
		) -- 1586
		local lastError = initialError -- 1587
		local candidateRaw = "" -- 1588
		do -- 1588
			local attempt = 0 -- 1589
			while attempt < shared.llmMaxTry do -- 1589
				do -- 1589
					Log( -- 1590
						"Info", -- 1590
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 1590
					) -- 1590
					local messages = buildXmlRepairMessages( -- 1591
						shared, -- 1592
						originalRaw, -- 1593
						candidateRaw, -- 1594
						lastError, -- 1595
						attempt + 1 -- 1596
					) -- 1596
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 1598
					if shared.stopToken.stopped then -- 1598
						return ____awaiter_resolve( -- 1598
							nil, -- 1598
							{ -- 1600
								success = false, -- 1600
								message = getCancelledReason(shared) -- 1600
							} -- 1600
						) -- 1600
					end -- 1600
					if not llmRes.success then -- 1600
						lastError = llmRes.message -- 1603
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 1604
						goto __continue253 -- 1605
					end -- 1605
					candidateRaw = llmRes.text -- 1607
					local decision = tryParseAndValidateDecision(candidateRaw) -- 1608
					if decision.success then -- 1608
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 1610
						return ____awaiter_resolve(nil, decision) -- 1610
					end -- 1610
					lastError = decision.message -- 1613
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 1614
				end -- 1614
				::__continue253:: -- 1614
				attempt = attempt + 1 -- 1589
			end -- 1589
		end -- 1589
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 1616
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 1616
	end) -- 1616
end -- 1581
function MainDecisionAgent.prototype.exec(self, input) -- 1624
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1624
		local shared = input.shared -- 1625
		if shared.stopToken.stopped then -- 1625
			return ____awaiter_resolve( -- 1625
				nil, -- 1625
				{ -- 1627
					success = false, -- 1627
					message = getCancelledReason(shared) -- 1627
				} -- 1627
			) -- 1627
		end -- 1627
		if shared.step >= shared.maxSteps then -- 1627
			Log( -- 1630
				"Warn", -- 1630
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1630
			) -- 1630
			return ____awaiter_resolve( -- 1630
				nil, -- 1630
				{ -- 1631
					success = false, -- 1631
					message = getMaxStepsReachedReason(shared) -- 1631
				} -- 1631
			) -- 1631
		end -- 1631
		if shared.decisionMode == "tool_calling" then -- 1631
			Log( -- 1635
				"Info", -- 1635
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 1635
			) -- 1635
			local lastError = "tool calling validation failed" -- 1636
			local lastRaw = "" -- 1637
			do -- 1637
				local attempt = 0 -- 1638
				while attempt < shared.llmMaxTry do -- 1638
					Log( -- 1639
						"Info", -- 1639
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1639
					) -- 1639
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 1640
					if shared.stopToken.stopped then -- 1640
						return ____awaiter_resolve( -- 1640
							nil, -- 1640
							{ -- 1647
								success = false, -- 1647
								message = getCancelledReason(shared) -- 1647
							} -- 1647
						) -- 1647
					end -- 1647
					if decision.success then -- 1647
						return ____awaiter_resolve(nil, decision) -- 1647
					end -- 1647
					lastError = decision.message -- 1652
					lastRaw = decision.raw or "" -- 1653
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1654
					attempt = attempt + 1 -- 1638
				end -- 1638
			end -- 1638
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1656
			return ____awaiter_resolve( -- 1656
				nil, -- 1656
				{ -- 1657
					success = false, -- 1657
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1657
				} -- 1657
			) -- 1657
		end -- 1657
		local lastError = "xml validation failed" -- 1660
		local lastRaw = "" -- 1661
		do -- 1661
			local attempt = 0 -- 1662
			while attempt < shared.llmMaxTry do -- 1662
				do -- 1662
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 1663
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 1671
					if shared.stopToken.stopped then -- 1671
						return ____awaiter_resolve( -- 1671
							nil, -- 1671
							{ -- 1673
								success = false, -- 1673
								message = getCancelledReason(shared) -- 1673
							} -- 1673
						) -- 1673
					end -- 1673
					if not llmRes.success then -- 1673
						lastError = llmRes.message -- 1676
						lastRaw = llmRes.text or "" -- 1677
						goto __continue266 -- 1678
					end -- 1678
					lastRaw = llmRes.text -- 1680
					local decision = tryParseAndValidateDecision(llmRes.text) -- 1681
					if decision.success then -- 1681
						return ____awaiter_resolve(nil, decision) -- 1681
					end -- 1681
					lastError = decision.message -- 1685
					return ____awaiter_resolve( -- 1685
						nil, -- 1685
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 1686
					) -- 1686
				end -- 1686
				::__continue266:: -- 1686
				attempt = attempt + 1 -- 1662
			end -- 1662
		end -- 1662
		return ____awaiter_resolve( -- 1662
			nil, -- 1662
			{ -- 1688
				success = false, -- 1688
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1688
			} -- 1688
		) -- 1688
	end) -- 1688
end -- 1624
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1691
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1691
		local result = execRes -- 1692
		if not result.success then -- 1692
			shared.error = result.message -- 1694
			shared.response = getFailureSummaryFallback(shared, result.message) -- 1695
			shared.done = true -- 1696
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 1697
			persistHistoryState(shared) -- 1701
			return ____awaiter_resolve(nil, "done") -- 1701
		end -- 1701
		if result.directSummary and result.directSummary ~= "" then -- 1701
			shared.response = result.directSummary -- 1705
			shared.done = true -- 1706
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 1707
			persistHistoryState(shared) -- 1712
			return ____awaiter_resolve(nil, "done") -- 1712
		end -- 1712
		if result.tool == "finish" then -- 1712
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 1716
			shared.response = finalMessage -- 1717
			shared.done = true -- 1718
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 1719
			persistHistoryState(shared) -- 1724
			return ____awaiter_resolve(nil, "done") -- 1724
		end -- 1724
		local toolCallId = ensureToolCallId(result.toolCallId) -- 1727
		shared.step = shared.step + 1 -- 1728
		local step = shared.step -- 1729
		emitAgentEvent(shared, { -- 1730
			type = "decision_made", -- 1731
			sessionId = shared.sessionId, -- 1732
			taskId = shared.taskId, -- 1733
			step = step, -- 1734
			tool = result.tool, -- 1735
			reason = result.reason, -- 1736
			reasoningContent = result.reasoningContent, -- 1737
			params = result.params -- 1738
		}) -- 1738
		local ____shared_history_32 = shared.history -- 1738
		____shared_history_32[#____shared_history_32 + 1] = { -- 1740
			step = step, -- 1741
			toolCallId = toolCallId, -- 1742
			tool = result.tool, -- 1743
			reason = result.reason or "", -- 1744
			reasoningContent = result.reasoningContent, -- 1745
			params = result.params, -- 1746
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1747
		} -- 1747
		appendConversationMessage( -- 1749
			shared, -- 1749
			{ -- 1749
				role = "assistant", -- 1750
				content = result.reason or "", -- 1751
				reasoning_content = result.reasoningContent, -- 1752
				tool_calls = {{ -- 1753
					id = toolCallId, -- 1754
					type = "function", -- 1755
					["function"] = { -- 1756
						name = result.tool, -- 1757
						arguments = toJson(result.params) -- 1758
					} -- 1758
				}} -- 1758
			} -- 1758
		) -- 1758
		persistHistoryState(shared) -- 1762
		return ____awaiter_resolve(nil, result.tool) -- 1762
	end) -- 1762
end -- 1691
local ReadFileAction = __TS__Class() -- 1767
ReadFileAction.name = "ReadFileAction" -- 1767
__TS__ClassExtends(ReadFileAction, Node) -- 1767
function ReadFileAction.prototype.prep(self, shared) -- 1768
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1768
		local last = shared.history[#shared.history] -- 1769
		if not last then -- 1769
			error( -- 1770
				__TS__New(Error, "no history"), -- 1770
				0 -- 1770
			) -- 1770
		end -- 1770
		emitAgentStartEvent(shared, last) -- 1771
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1772
		if __TS__StringTrim(path) == "" then -- 1772
			error( -- 1775
				__TS__New(Error, "missing path"), -- 1775
				0 -- 1775
			) -- 1775
		end -- 1775
		local ____path_35 = path -- 1777
		local ____shared_workingDir_36 = shared.workingDir -- 1779
		local ____temp_37 = shared.useChineseResponse and "zh" or "en" -- 1780
		local ____last_params_startLine_33 = last.params.startLine -- 1781
		if ____last_params_startLine_33 == nil then -- 1781
			____last_params_startLine_33 = 1 -- 1781
		end -- 1781
		local ____TS__Number_result_38 = __TS__Number(____last_params_startLine_33) -- 1781
		local ____last_params_endLine_34 = last.params.endLine -- 1782
		if ____last_params_endLine_34 == nil then -- 1782
			____last_params_endLine_34 = READ_FILE_DEFAULT_LIMIT -- 1782
		end -- 1782
		return ____awaiter_resolve( -- 1782
			nil, -- 1782
			{ -- 1776
				path = ____path_35, -- 1777
				tool = "read_file", -- 1778
				workDir = ____shared_workingDir_36, -- 1779
				docLanguage = ____temp_37, -- 1780
				startLine = ____TS__Number_result_38, -- 1781
				endLine = __TS__Number(____last_params_endLine_34) -- 1782
			} -- 1782
		) -- 1782
	end) -- 1782
end -- 1768
function ReadFileAction.prototype.exec(self, input) -- 1786
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1786
		return ____awaiter_resolve( -- 1786
			nil, -- 1786
			Tools.readFile( -- 1787
				input.workDir, -- 1788
				input.path, -- 1789
				__TS__Number(input.startLine or 1), -- 1790
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1791
				input.docLanguage -- 1792
			) -- 1792
		) -- 1792
	end) -- 1792
end -- 1786
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1796
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1796
		local result = execRes -- 1797
		local last = shared.history[#shared.history] -- 1798
		if last ~= nil then -- 1798
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1800
			appendToolResultMessage(shared, last) -- 1801
			emitAgentFinishEvent(shared, last) -- 1802
		end -- 1802
		persistHistoryState(shared) -- 1804
		__TS__Await(maybeCompressHistory(shared)) -- 1805
		persistHistoryState(shared) -- 1806
		return ____awaiter_resolve(nil, "main") -- 1806
	end) -- 1806
end -- 1796
local SearchFilesAction = __TS__Class() -- 1811
SearchFilesAction.name = "SearchFilesAction" -- 1811
__TS__ClassExtends(SearchFilesAction, Node) -- 1811
function SearchFilesAction.prototype.prep(self, shared) -- 1812
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1812
		local last = shared.history[#shared.history] -- 1813
		if not last then -- 1813
			error( -- 1814
				__TS__New(Error, "no history"), -- 1814
				0 -- 1814
			) -- 1814
		end -- 1814
		emitAgentStartEvent(shared, last) -- 1815
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1815
	end) -- 1815
end -- 1812
function SearchFilesAction.prototype.exec(self, input) -- 1819
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1819
		local params = input.params -- 1820
		local ____Tools_searchFiles_52 = Tools.searchFiles -- 1821
		local ____input_workDir_45 = input.workDir -- 1822
		local ____temp_46 = params.path or "" -- 1823
		local ____temp_47 = params.pattern or "" -- 1824
		local ____params_globs_48 = params.globs -- 1825
		local ____params_useRegex_49 = params.useRegex -- 1826
		local ____params_caseSensitive_50 = params.caseSensitive -- 1827
		local ____math_max_41 = math.max -- 1830
		local ____math_floor_40 = math.floor -- 1830
		local ____params_limit_39 = params.limit -- 1830
		if ____params_limit_39 == nil then -- 1830
			____params_limit_39 = SEARCH_FILES_LIMIT_DEFAULT -- 1830
		end -- 1830
		local ____math_max_41_result_51 = ____math_max_41( -- 1830
			1, -- 1830
			____math_floor_40(__TS__Number(____params_limit_39)) -- 1830
		) -- 1830
		local ____math_max_44 = math.max -- 1831
		local ____math_floor_43 = math.floor -- 1831
		local ____params_offset_42 = params.offset -- 1831
		if ____params_offset_42 == nil then -- 1831
			____params_offset_42 = 0 -- 1831
		end -- 1831
		local result = __TS__Await(____Tools_searchFiles_52({ -- 1821
			workDir = ____input_workDir_45, -- 1822
			path = ____temp_46, -- 1823
			pattern = ____temp_47, -- 1824
			globs = ____params_globs_48, -- 1825
			useRegex = ____params_useRegex_49, -- 1826
			caseSensitive = ____params_caseSensitive_50, -- 1827
			includeContent = true, -- 1828
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1829
			limit = ____math_max_41_result_51, -- 1830
			offset = ____math_max_44( -- 1831
				0, -- 1831
				____math_floor_43(__TS__Number(____params_offset_42)) -- 1831
			), -- 1831
			groupByFile = params.groupByFile == true -- 1832
		})) -- 1832
		return ____awaiter_resolve(nil, result) -- 1832
	end) -- 1832
end -- 1819
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1837
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1837
		local last = shared.history[#shared.history] -- 1838
		if last ~= nil then -- 1838
			local result = execRes -- 1840
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1841
			appendToolResultMessage(shared, last) -- 1842
			emitAgentFinishEvent(shared, last) -- 1843
		end -- 1843
		persistHistoryState(shared) -- 1845
		__TS__Await(maybeCompressHistory(shared)) -- 1846
		persistHistoryState(shared) -- 1847
		return ____awaiter_resolve(nil, "main") -- 1847
	end) -- 1847
end -- 1837
local SearchDoraAPIAction = __TS__Class() -- 1852
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1852
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1852
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1853
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1853
		local last = shared.history[#shared.history] -- 1854
		if not last then -- 1854
			error( -- 1855
				__TS__New(Error, "no history"), -- 1855
				0 -- 1855
			) -- 1855
		end -- 1855
		emitAgentStartEvent(shared, last) -- 1856
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1856
	end) -- 1856
end -- 1853
function SearchDoraAPIAction.prototype.exec(self, input) -- 1860
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1860
		local params = input.params -- 1861
		local ____Tools_searchDoraAPI_60 = Tools.searchDoraAPI -- 1862
		local ____temp_56 = params.pattern or "" -- 1863
		local ____temp_57 = params.docSource or "api" -- 1864
		local ____temp_58 = input.useChineseResponse and "zh" or "en" -- 1865
		local ____temp_59 = params.programmingLanguage or "ts" -- 1866
		local ____math_min_55 = math.min -- 1867
		local ____math_max_54 = math.max -- 1867
		local ____params_limit_53 = params.limit -- 1867
		if ____params_limit_53 == nil then -- 1867
			____params_limit_53 = 8 -- 1867
		end -- 1867
		local result = __TS__Await(____Tools_searchDoraAPI_60({ -- 1862
			pattern = ____temp_56, -- 1863
			docSource = ____temp_57, -- 1864
			docLanguage = ____temp_58, -- 1865
			programmingLanguage = ____temp_59, -- 1866
			limit = ____math_min_55( -- 1867
				SEARCH_DORA_API_LIMIT_MAX, -- 1867
				____math_max_54( -- 1867
					1, -- 1867
					__TS__Number(____params_limit_53) -- 1867
				) -- 1867
			), -- 1867
			useRegex = params.useRegex, -- 1868
			caseSensitive = false, -- 1869
			includeContent = true, -- 1870
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1871
		})) -- 1871
		return ____awaiter_resolve(nil, result) -- 1871
	end) -- 1871
end -- 1860
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1876
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1876
		local last = shared.history[#shared.history] -- 1877
		if last ~= nil then -- 1877
			local result = execRes -- 1879
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1880
			appendToolResultMessage(shared, last) -- 1881
			emitAgentFinishEvent(shared, last) -- 1882
		end -- 1882
		persistHistoryState(shared) -- 1884
		__TS__Await(maybeCompressHistory(shared)) -- 1885
		persistHistoryState(shared) -- 1886
		return ____awaiter_resolve(nil, "main") -- 1886
	end) -- 1886
end -- 1876
local ListFilesAction = __TS__Class() -- 1891
ListFilesAction.name = "ListFilesAction" -- 1891
__TS__ClassExtends(ListFilesAction, Node) -- 1891
function ListFilesAction.prototype.prep(self, shared) -- 1892
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1892
		local last = shared.history[#shared.history] -- 1893
		if not last then -- 1893
			error( -- 1894
				__TS__New(Error, "no history"), -- 1894
				0 -- 1894
			) -- 1894
		end -- 1894
		emitAgentStartEvent(shared, last) -- 1895
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1895
	end) -- 1895
end -- 1892
function ListFilesAction.prototype.exec(self, input) -- 1899
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1899
		local params = input.params -- 1900
		local ____Tools_listFiles_67 = Tools.listFiles -- 1901
		local ____input_workDir_64 = input.workDir -- 1902
		local ____temp_65 = params.path or "" -- 1903
		local ____params_globs_66 = params.globs -- 1904
		local ____math_max_63 = math.max -- 1905
		local ____math_floor_62 = math.floor -- 1905
		local ____params_maxEntries_61 = params.maxEntries -- 1905
		if ____params_maxEntries_61 == nil then -- 1905
			____params_maxEntries_61 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1905
		end -- 1905
		local result = ____Tools_listFiles_67({ -- 1901
			workDir = ____input_workDir_64, -- 1902
			path = ____temp_65, -- 1903
			globs = ____params_globs_66, -- 1904
			maxEntries = ____math_max_63( -- 1905
				1, -- 1905
				____math_floor_62(__TS__Number(____params_maxEntries_61)) -- 1905
			) -- 1905
		}) -- 1905
		return ____awaiter_resolve(nil, result) -- 1905
	end) -- 1905
end -- 1899
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1910
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1910
		local last = shared.history[#shared.history] -- 1911
		if last ~= nil then -- 1911
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1913
			appendToolResultMessage(shared, last) -- 1914
			emitAgentFinishEvent(shared, last) -- 1915
		end -- 1915
		persistHistoryState(shared) -- 1917
		__TS__Await(maybeCompressHistory(shared)) -- 1918
		persistHistoryState(shared) -- 1919
		return ____awaiter_resolve(nil, "main") -- 1919
	end) -- 1919
end -- 1910
local DeleteFileAction = __TS__Class() -- 1924
DeleteFileAction.name = "DeleteFileAction" -- 1924
__TS__ClassExtends(DeleteFileAction, Node) -- 1924
function DeleteFileAction.prototype.prep(self, shared) -- 1925
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1925
		local last = shared.history[#shared.history] -- 1926
		if not last then -- 1926
			error( -- 1927
				__TS__New(Error, "no history"), -- 1927
				0 -- 1927
			) -- 1927
		end -- 1927
		emitAgentStartEvent(shared, last) -- 1928
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1929
		if __TS__StringTrim(targetFile) == "" then -- 1929
			error( -- 1932
				__TS__New(Error, "missing target_file"), -- 1932
				0 -- 1932
			) -- 1932
		end -- 1932
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1932
	end) -- 1932
end -- 1925
function DeleteFileAction.prototype.exec(self, input) -- 1936
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1936
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1937
		if not result.success then -- 1937
			return ____awaiter_resolve(nil, result) -- 1937
		end -- 1937
		return ____awaiter_resolve(nil, { -- 1937
			success = true, -- 1945
			changed = true, -- 1946
			mode = "delete", -- 1947
			checkpointId = result.checkpointId, -- 1948
			checkpointSeq = result.checkpointSeq, -- 1949
			files = {{path = input.targetFile, op = "delete"}} -- 1950
		}) -- 1950
	end) -- 1950
end -- 1936
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1954
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1954
		local last = shared.history[#shared.history] -- 1955
		if last ~= nil then -- 1955
			last.result = execRes -- 1957
			appendToolResultMessage(shared, last) -- 1958
			emitAgentFinishEvent(shared, last) -- 1959
			local result = last.result -- 1960
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 1960
				emitAgentEvent(shared, { -- 1965
					type = "checkpoint_created", -- 1966
					sessionId = shared.sessionId, -- 1967
					taskId = shared.taskId, -- 1968
					step = last.step, -- 1969
					tool = "delete_file", -- 1970
					checkpointId = result.checkpointId, -- 1971
					checkpointSeq = result.checkpointSeq, -- 1972
					files = result.files -- 1973
				}) -- 1973
			end -- 1973
		end -- 1973
		persistHistoryState(shared) -- 1977
		__TS__Await(maybeCompressHistory(shared)) -- 1978
		persistHistoryState(shared) -- 1979
		return ____awaiter_resolve(nil, "main") -- 1979
	end) -- 1979
end -- 1954
local BuildAction = __TS__Class() -- 1984
BuildAction.name = "BuildAction" -- 1984
__TS__ClassExtends(BuildAction, Node) -- 1984
function BuildAction.prototype.prep(self, shared) -- 1985
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1985
		local last = shared.history[#shared.history] -- 1986
		if not last then -- 1986
			error( -- 1987
				__TS__New(Error, "no history"), -- 1987
				0 -- 1987
			) -- 1987
		end -- 1987
		emitAgentStartEvent(shared, last) -- 1988
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1988
	end) -- 1988
end -- 1985
function BuildAction.prototype.exec(self, input) -- 1992
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1992
		local params = input.params -- 1993
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1994
		return ____awaiter_resolve(nil, result) -- 1994
	end) -- 1994
end -- 1992
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2001
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2001
		local last = shared.history[#shared.history] -- 2002
		if last ~= nil then -- 2002
			last.result = execRes -- 2004
			appendToolResultMessage(shared, last) -- 2005
			emitAgentFinishEvent(shared, last) -- 2006
		end -- 2006
		persistHistoryState(shared) -- 2008
		__TS__Await(maybeCompressHistory(shared)) -- 2009
		persistHistoryState(shared) -- 2010
		return ____awaiter_resolve(nil, "main") -- 2010
	end) -- 2010
end -- 2001
local EditFileAction = __TS__Class() -- 2015
EditFileAction.name = "EditFileAction" -- 2015
__TS__ClassExtends(EditFileAction, Node) -- 2015
function EditFileAction.prototype.prep(self, shared) -- 2016
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2016
		local last = shared.history[#shared.history] -- 2017
		if not last then -- 2017
			error( -- 2018
				__TS__New(Error, "no history"), -- 2018
				0 -- 2018
			) -- 2018
		end -- 2018
		emitAgentStartEvent(shared, last) -- 2019
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2020
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2023
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2024
		if __TS__StringTrim(path) == "" then -- 2024
			error( -- 2025
				__TS__New(Error, "missing path"), -- 2025
				0 -- 2025
			) -- 2025
		end -- 2025
		return ____awaiter_resolve(nil, { -- 2025
			path = path, -- 2026
			oldStr = oldStr, -- 2026
			newStr = newStr, -- 2026
			taskId = shared.taskId, -- 2026
			workDir = shared.workingDir -- 2026
		}) -- 2026
	end) -- 2026
end -- 2016
function EditFileAction.prototype.exec(self, input) -- 2029
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2029
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 2030
		if not readRes.success then -- 2030
			if input.oldStr ~= "" then -- 2030
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 2030
			end -- 2030
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2035
			if not createRes.success then -- 2035
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 2035
			end -- 2035
			return ____awaiter_resolve(nil, { -- 2035
				success = true, -- 2043
				changed = true, -- 2044
				mode = "create", -- 2045
				checkpointId = createRes.checkpointId, -- 2046
				checkpointSeq = createRes.checkpointSeq, -- 2047
				files = {{path = input.path, op = "create"}} -- 2048
			}) -- 2048
		end -- 2048
		if input.oldStr == "" then -- 2048
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2052
			if not overwriteRes.success then -- 2052
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 2052
			end -- 2052
			return ____awaiter_resolve(nil, { -- 2052
				success = true, -- 2060
				changed = true, -- 2061
				mode = "overwrite", -- 2062
				checkpointId = overwriteRes.checkpointId, -- 2063
				checkpointSeq = overwriteRes.checkpointSeq, -- 2064
				files = {{path = input.path, op = "write"}} -- 2065
			}) -- 2065
		end -- 2065
		local normalizedContent = normalizeLineEndings(readRes.content) -- 2070
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 2071
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 2072
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 2075
		if occurrences == 0 then -- 2075
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2077
			if not indentTolerant.success then -- 2077
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 2077
			end -- 2077
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 2081
			if not applyRes.success then -- 2081
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2081
			end -- 2081
			return ____awaiter_resolve(nil, { -- 2081
				success = true, -- 2089
				changed = true, -- 2090
				mode = "replace_indent_tolerant", -- 2091
				checkpointId = applyRes.checkpointId, -- 2092
				checkpointSeq = applyRes.checkpointSeq, -- 2093
				files = {{path = input.path, op = "write"}} -- 2094
			}) -- 2094
		end -- 2094
		if occurrences > 1 then -- 2094
			return ____awaiter_resolve( -- 2094
				nil, -- 2094
				{ -- 2098
					success = false, -- 2098
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 2098
				} -- 2098
			) -- 2098
		end -- 2098
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2102
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2103
		if not applyRes.success then -- 2103
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2103
		end -- 2103
		return ____awaiter_resolve(nil, { -- 2103
			success = true, -- 2111
			changed = true, -- 2112
			mode = "replace", -- 2113
			checkpointId = applyRes.checkpointId, -- 2114
			checkpointSeq = applyRes.checkpointSeq, -- 2115
			files = {{path = input.path, op = "write"}} -- 2116
		}) -- 2116
	end) -- 2116
end -- 2029
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2120
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2120
		local last = shared.history[#shared.history] -- 2121
		if last ~= nil then -- 2121
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 2123
			last.result = execRes -- 2124
			appendToolResultMessage(shared, last) -- 2125
			emitAgentFinishEvent(shared, last) -- 2126
			local result = last.result -- 2127
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2127
				emitAgentEvent(shared, { -- 2132
					type = "checkpoint_created", -- 2133
					sessionId = shared.sessionId, -- 2134
					taskId = shared.taskId, -- 2135
					step = last.step, -- 2136
					tool = last.tool, -- 2137
					checkpointId = result.checkpointId, -- 2138
					checkpointSeq = result.checkpointSeq, -- 2139
					files = result.files -- 2140
				}) -- 2140
			end -- 2140
		end -- 2140
		persistHistoryState(shared) -- 2144
		__TS__Await(maybeCompressHistory(shared)) -- 2145
		persistHistoryState(shared) -- 2146
		return ____awaiter_resolve(nil, "main") -- 2146
	end) -- 2146
end -- 2120
local EndNode = __TS__Class() -- 2151
EndNode.name = "EndNode" -- 2151
__TS__ClassExtends(EndNode, Node) -- 2151
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 2152
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2152
		return ____awaiter_resolve(nil, nil) -- 2152
	end) -- 2152
end -- 2152
local CodingAgentFlow = __TS__Class() -- 2157
CodingAgentFlow.name = "CodingAgentFlow" -- 2157
__TS__ClassExtends(CodingAgentFlow, Flow) -- 2157
function CodingAgentFlow.prototype.____constructor(self) -- 2158
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 2159
	local read = __TS__New(ReadFileAction, 1, 0) -- 2160
	local search = __TS__New(SearchFilesAction, 1, 0) -- 2161
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 2162
	local list = __TS__New(ListFilesAction, 1, 0) -- 2163
	local del = __TS__New(DeleteFileAction, 1, 0) -- 2164
	local build = __TS__New(BuildAction, 1, 0) -- 2165
	local edit = __TS__New(EditFileAction, 1, 0) -- 2166
	local done = __TS__New(EndNode, 1, 0) -- 2167
	main:on("read_file", read) -- 2169
	main:on("grep_files", search) -- 2170
	main:on("search_dora_api", searchDora) -- 2171
	main:on("glob_files", list) -- 2172
	main:on("delete_file", del) -- 2173
	main:on("build", build) -- 2174
	main:on("edit_file", edit) -- 2175
	main:on("done", done) -- 2176
	read:on("main", main) -- 2178
	search:on("main", main) -- 2179
	searchDora:on("main", main) -- 2180
	list:on("main", main) -- 2181
	del:on("main", main) -- 2182
	build:on("main", main) -- 2183
	edit:on("main", main) -- 2184
	Flow.prototype.____constructor(self, main) -- 2186
end -- 2158
local function runCodingAgentAsync(options) -- 2208
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2208
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 2208
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 2208
		end -- 2208
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 2212
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2213
		if not llmConfigRes.success then -- 2213
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2213
		end -- 2213
		local llmConfig = llmConfigRes.config -- 2219
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 2220
		if not taskRes.success then -- 2220
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 2220
		end -- 2220
		local compressor = __TS__New(MemoryCompressor, { -- 2227
			compressionThreshold = 0.8, -- 2228
			maxCompressionRounds = 3, -- 2229
			maxTokensPerCompression = 20000, -- 2230
			projectDir = options.workDir, -- 2231
			llmConfig = llmConfig, -- 2232
			promptPack = options.promptPack -- 2233
		}) -- 2233
		local persistedSession = compressor:getStorage():readSessionState() -- 2235
		local promptPack = compressor:getPromptPack() -- 2236
		local shared = { -- 2238
			sessionId = options.sessionId, -- 2239
			taskId = taskRes.taskId, -- 2240
			maxSteps = math.max( -- 2241
				1, -- 2241
				math.floor(options.maxSteps or 50) -- 2241
			), -- 2241
			llmMaxTry = math.max( -- 2242
				1, -- 2242
				math.floor(options.llmMaxTry or 3) -- 2242
			), -- 2242
			step = 0, -- 2243
			done = false, -- 2244
			stopToken = options.stopToken or ({stopped = false}), -- 2245
			response = "", -- 2246
			userQuery = normalizedPrompt, -- 2247
			workingDir = options.workDir, -- 2248
			useChineseResponse = options.useChineseResponse == true, -- 2249
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 2250
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 2253
			llmConfig = llmConfig, -- 2258
			onEvent = options.onEvent, -- 2259
			promptPack = promptPack, -- 2260
			history = {}, -- 2261
			messages = persistedSession.messages, -- 2262
			memory = {compressor = compressor} -- 2264
		} -- 2264
		local ____try = __TS__AsyncAwaiter(function() -- 2264
			emitAgentEvent(shared, { -- 2270
				type = "task_started", -- 2271
				sessionId = shared.sessionId, -- 2272
				taskId = shared.taskId, -- 2273
				prompt = shared.userQuery, -- 2274
				workDir = shared.workingDir, -- 2275
				maxSteps = shared.maxSteps -- 2276
			}) -- 2276
			if shared.stopToken.stopped then -- 2276
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2279
				return ____awaiter_resolve( -- 2279
					nil, -- 2279
					emitAgentTaskFinishEvent( -- 2280
						shared, -- 2280
						false, -- 2280
						getCancelledReason(shared) -- 2280
					) -- 2280
				) -- 2280
			end -- 2280
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 2282
			local promptCommand = getPromptCommand(shared.userQuery) -- 2283
			if promptCommand == "reset" then -- 2283
				return ____awaiter_resolve( -- 2283
					nil, -- 2283
					resetSessionHistory(shared) -- 2285
				) -- 2285
			end -- 2285
			if promptCommand == "compact" then -- 2285
				return ____awaiter_resolve( -- 2285
					nil, -- 2285
					__TS__Await(compactAllHistory(shared)) -- 2288
				) -- 2288
			end -- 2288
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 2290
			persistHistoryState(shared) -- 2294
			local flow = __TS__New(CodingAgentFlow) -- 2295
			__TS__Await(flow:run(shared)) -- 2296
			if shared.stopToken.stopped then -- 2296
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2298
				return ____awaiter_resolve( -- 2298
					nil, -- 2298
					emitAgentTaskFinishEvent( -- 2299
						shared, -- 2299
						false, -- 2299
						getCancelledReason(shared) -- 2299
					) -- 2299
				) -- 2299
			end -- 2299
			if shared.error then -- 2299
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 2302
				return ____awaiter_resolve( -- 2302
					nil, -- 2302
					emitAgentTaskFinishEvent(shared, false, shared.response and shared.response ~= "" and shared.response or shared.error) -- 2303
				) -- 2303
			end -- 2303
			Tools.setTaskStatus(shared.taskId, "DONE") -- 2306
			return ____awaiter_resolve( -- 2306
				nil, -- 2306
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 2307
			) -- 2307
		end) -- 2307
		__TS__Await(____try.catch( -- 2269
			____try, -- 2269
			function(____, e) -- 2269
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 2310
				return ____awaiter_resolve( -- 2310
					nil, -- 2310
					emitAgentTaskFinishEvent( -- 2311
						shared, -- 2311
						false, -- 2311
						tostring(e) -- 2311
					) -- 2311
				) -- 2311
			end -- 2311
		)) -- 2311
	end) -- 2311
end -- 2208
function ____exports.runCodingAgent(options, callback) -- 2315
	local ____self_68 = runCodingAgentAsync(options) -- 2315
	____self_68["then"]( -- 2315
		____self_68, -- 2315
		function(____, result) return callback(result) end -- 2316
	) -- 2316
end -- 2315
return ____exports -- 2315