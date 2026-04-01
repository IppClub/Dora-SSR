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
local emitAgentEvent, truncateText, getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, persistHistoryState, applyCompressedSessionState, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, emitAgentTaskFinishEvent, SEARCH_DORA_API_LIMIT_MAX -- 1
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
local ____SkillsLoader = require("Agent.SkillsLoader") -- 9
local createSkillsLoader = ____SkillsLoader.createSkillsLoader -- 9
function emitAgentEvent(shared, event) -- 195
	if shared.onEvent then -- 195
		do -- 195
			local function ____catch(____error) -- 195
				Log( -- 200
					"Error", -- 200
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 200
				) -- 200
			end -- 200
			local ____try, ____hasReturned = pcall(function() -- 200
				shared:onEvent(event) -- 198
			end) -- 198
			if not ____try then -- 198
				____catch(____hasReturned) -- 198
			end -- 198
		end -- 198
	end -- 198
end -- 198
function truncateText(text, maxLen) -- 433
	if #text <= maxLen then -- 433
		return text -- 434
	end -- 434
	local nextPos = utf8.offset(text, maxLen + 1) -- 435
	if nextPos == nil then -- 435
		return text -- 436
	end -- 436
	return string.sub(text, 1, nextPos - 1) .. "..." -- 437
end -- 437
function getReplyLanguageDirective(shared) -- 447
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 448
end -- 448
function replacePromptVars(template, vars) -- 453
	local output = template -- 454
	for key in pairs(vars) do -- 455
		output = table.concat( -- 456
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 456
			vars[key] or "" or "," -- 456
		) -- 456
	end -- 456
	return output -- 458
end -- 458
function getDecisionToolDefinitions(shared) -- 582
	local base = replacePromptVars( -- 583
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 584
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 585
	) -- 585
	if (shared and shared.decisionMode) ~= "xml" then -- 585
		return base -- 588
	end -- 588
	return base .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 590
end -- 590
function persistHistoryState(shared) -- 839
	shared.memory.compressor:getStorage():writeSessionState(shared.messages) -- 840
end -- 840
function applyCompressedSessionState(shared, compressedCount, carryMessage) -- 843
	local remainingMessages = __TS__ArraySlice(shared.messages, compressedCount) -- 848
	if carryMessage then -- 848
		__TS__ArrayUnshift( -- 850
			remainingMessages, -- 850
			__TS__ObjectAssign( -- 850
				{}, -- 850
				carryMessage, -- 851
				{timestamp = carryMessage.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 850
			) -- 850
		) -- 850
	end -- 850
	shared.messages = remainingMessages -- 855
end -- 855
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1178
	if includeToolDefinitions == nil then -- 1178
		includeToolDefinitions = false -- 1178
	end -- 1178
	local sections = { -- 1179
		shared.promptPack.agentIdentityPrompt, -- 1180
		getReplyLanguageDirective(shared) -- 1181
	} -- 1181
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1183
	if memoryContext ~= "" then -- 1183
		sections[#sections + 1] = memoryContext -- 1185
	end -- 1185
	if includeToolDefinitions then -- 1185
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1188
		if shared.decisionMode == "xml" then -- 1188
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1190
		end -- 1190
	end -- 1190
	local skillsSection = buildSkillsSection(shared) -- 1194
	if skillsSection ~= "" then -- 1194
		sections[#sections + 1] = skillsSection -- 1196
	end -- 1196
	return table.concat(sections, "\n\n") -- 1198
end -- 1198
function buildSkillsSection(shared) -- 1201
	local ____opt_29 = shared.skills -- 1201
	if not (____opt_29 and ____opt_29.loader) then -- 1201
		return "" -- 1203
	end -- 1203
	return shared.skills.loader:buildSkillsPromptSection() -- 1205
end -- 1205
function buildXmlDecisionInstruction(shared, feedback) -- 1292
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 1293
end -- 1293
function emitAgentTaskFinishEvent(shared, success, message) -- 2216
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 2217
	emitAgentEvent(shared, { -- 2223
		type = "task_finished", -- 2224
		sessionId = shared.sessionId, -- 2225
		taskId = shared.taskId, -- 2226
		success = result.success, -- 2227
		message = result.message, -- 2228
		steps = result.steps -- 2229
	}) -- 2229
	return result -- 2231
end -- 2231
local function isRecord(value) -- 11
	return type(value) == "table" -- 12
end -- 11
local function isArray(value) -- 15
	return __TS__ArrayIsArray(value) -- 16
end -- 15
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 49
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 141
local HISTORY_READ_FILE_MAX_LINES = 300 -- 142
local READ_FILE_DEFAULT_LIMIT = 300 -- 143
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 144
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 145
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 146
SEARCH_DORA_API_LIMIT_MAX = 20 -- 147
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 148
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 149
local SEARCH_PREVIEW_CONTEXT = 80 -- 150
local function emitAgentStartEvent(shared, action) -- 205
	emitAgentEvent(shared, { -- 206
		type = "tool_started", -- 207
		sessionId = shared.sessionId, -- 208
		taskId = shared.taskId, -- 209
		step = action.step, -- 210
		tool = action.tool -- 211
	}) -- 211
end -- 205
local function emitAgentFinishEvent(shared, action) -- 215
	emitAgentEvent(shared, { -- 216
		type = "tool_finished", -- 217
		sessionId = shared.sessionId, -- 218
		taskId = shared.taskId, -- 219
		step = action.step, -- 220
		tool = action.tool, -- 221
		result = action.result or ({}) -- 222
	}) -- 222
end -- 215
local function getMemoryCompressionStartReason(shared) -- 226
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 227
end -- 226
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 232
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 233
end -- 232
local function getMemoryCompressionFailureReason(shared, ____error) -- 238
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 239
end -- 238
local function summarizeHistoryEntryPreview(text, maxChars) -- 244
	if maxChars == nil then -- 244
		maxChars = 180 -- 244
	end -- 244
	local trimmed = __TS__StringTrim(text) -- 245
	if trimmed == "" then -- 245
		return "" -- 246
	end -- 246
	return truncateText(trimmed, maxChars) -- 247
end -- 244
local function getCancelledReason(shared) -- 250
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 250
		return shared.stopToken.reason -- 251
	end -- 251
	return shared.useChineseResponse and "已取消" or "cancelled" -- 252
end -- 250
local function getMaxStepsReachedReason(shared) -- 255
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 256
end -- 255
local function getFailureSummaryFallback(shared, ____error) -- 261
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 262
end -- 261
local function finalizeAgentFailure(shared, ____error) -- 267
	if shared.stopToken.stopped then -- 267
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 269
		return emitAgentTaskFinishEvent( -- 270
			shared, -- 270
			false, -- 270
			getCancelledReason(shared) -- 270
		) -- 270
	end -- 270
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 272
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 273
end -- 267
local function getPromptCommand(prompt) -- 276
	local trimmed = __TS__StringTrim(prompt) -- 277
	if trimmed == "/compact" then -- 277
		return "compact" -- 278
	end -- 278
	if trimmed == "/reset" then -- 278
		return "reset" -- 279
	end -- 279
	return nil -- 280
end -- 276
function ____exports.truncateAgentUserPrompt(prompt) -- 283
	if not prompt then -- 283
		return "" -- 284
	end -- 284
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 284
		return prompt -- 285
	end -- 285
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 286
	if offset == nil then -- 286
		return prompt -- 287
	end -- 287
	return string.sub(prompt, 1, offset - 1) -- 288
end -- 283
local function canWriteStepLLMDebug(shared, stepId) -- 291
	if stepId == nil then -- 291
		stepId = shared.step + 1 -- 291
	end -- 291
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 292
end -- 291
local function ensureDirRecursive(dir) -- 299
	if not dir then -- 299
		return false -- 300
	end -- 300
	if Content:exist(dir) then -- 300
		return Content:isdir(dir) -- 301
	end -- 301
	local parent = Path:getPath(dir) -- 302
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 302
		return false -- 304
	end -- 304
	return Content:mkdir(dir) -- 306
end -- 299
local function encodeDebugJSON(value) -- 309
	local text, err = safeJsonEncode(value) -- 310
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 311
end -- 309
local function getStepLLMDebugDir(shared) -- 314
	return Path( -- 315
		shared.workingDir, -- 316
		".agent", -- 317
		tostring(shared.sessionId), -- 318
		tostring(shared.taskId) -- 319
	) -- 319
end -- 314
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 323
	return Path( -- 324
		getStepLLMDebugDir(shared), -- 324
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 324
	) -- 324
end -- 323
local function getLatestStepLLMDebugSeq(shared, stepId) -- 327
	if not canWriteStepLLMDebug(shared, stepId) then -- 327
		return 0 -- 328
	end -- 328
	local dir = getStepLLMDebugDir(shared) -- 329
	if not Content:exist(dir) or not Content:isdir(dir) then -- 329
		return 0 -- 330
	end -- 330
	local latest = 0 -- 331
	for ____, file in ipairs(Content:getFiles(dir)) do -- 332
		do -- 332
			local name = Path:getFilename(file) -- 333
			local seqText = string.match( -- 334
				name, -- 334
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 334
			) -- 334
			if seqText ~= nil then -- 334
				latest = math.max( -- 336
					latest, -- 336
					tonumber(seqText) -- 336
				) -- 336
				goto __continue39 -- 337
			end -- 337
			local legacyMatch = string.match( -- 339
				name, -- 339
				("^" .. tostring(stepId)) .. "_in%.md$" -- 339
			) -- 339
			if legacyMatch ~= nil then -- 339
				latest = math.max(latest, 1) -- 341
			end -- 341
		end -- 341
		::__continue39:: -- 341
	end -- 341
	return latest -- 344
end -- 327
local function writeStepLLMDebugFile(path, content) -- 347
	if not Content:save(path, content) then -- 347
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 349
		return false -- 350
	end -- 350
	return true -- 352
end -- 347
local function createStepLLMDebugPair(shared, stepId, inContent) -- 355
	if not canWriteStepLLMDebug(shared, stepId) then -- 355
		return 0 -- 356
	end -- 356
	local dir = getStepLLMDebugDir(shared) -- 357
	if not ensureDirRecursive(dir) then -- 357
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 359
		return 0 -- 360
	end -- 360
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 362
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 363
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 364
	if not writeStepLLMDebugFile(inPath, inContent) then -- 364
		return 0 -- 366
	end -- 366
	writeStepLLMDebugFile(outPath, "") -- 368
	return seq -- 369
end -- 355
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 372
	if not canWriteStepLLMDebug(shared, stepId) then -- 372
		return -- 373
	end -- 373
	local dir = getStepLLMDebugDir(shared) -- 374
	if not ensureDirRecursive(dir) then -- 374
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 376
		return -- 377
	end -- 377
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 379
	if latestSeq <= 0 then -- 379
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 381
		writeStepLLMDebugFile(outPath, content) -- 382
		return -- 383
	end -- 383
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 385
	writeStepLLMDebugFile(outPath, content) -- 386
end -- 372
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 389
	if not canWriteStepLLMDebug(shared, stepId) then -- 389
		return -- 390
	end -- 390
	local sections = { -- 391
		"# LLM Input", -- 392
		"session_id: " .. tostring(shared.sessionId), -- 393
		"task_id: " .. tostring(shared.taskId), -- 394
		"step_id: " .. tostring(stepId), -- 395
		"phase: " .. phase, -- 396
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 397
		"## Options", -- 398
		"```json", -- 399
		encodeDebugJSON(options), -- 400
		"```" -- 401
	} -- 401
	do -- 401
		local i = 0 -- 403
		while i < #messages do -- 403
			local message = messages[i + 1] -- 404
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 405
			sections[#sections + 1] = encodeDebugJSON(message) -- 406
			i = i + 1 -- 403
		end -- 403
	end -- 403
	createStepLLMDebugPair( -- 408
		shared, -- 408
		stepId, -- 408
		table.concat(sections, "\n") -- 408
	) -- 408
end -- 389
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 411
	if not canWriteStepLLMDebug(shared, stepId) then -- 411
		return -- 412
	end -- 412
	local ____array_0 = __TS__SparseArrayNew( -- 412
		"# LLM Output", -- 414
		"session_id: " .. tostring(shared.sessionId), -- 415
		"task_id: " .. tostring(shared.taskId), -- 416
		"step_id: " .. tostring(stepId), -- 417
		"phase: " .. phase, -- 418
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 419
		table.unpack(meta and ({ -- 420
			"## Meta", -- 420
			"```json", -- 420
			encodeDebugJSON(meta), -- 420
			"```" -- 420
		}) or ({})) -- 420
	) -- 420
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 420
	local sections = {__TS__SparseArraySpread(____array_0)} -- 413
	updateLatestStepLLMDebugOutput( -- 424
		shared, -- 424
		stepId, -- 424
		table.concat(sections, "\n") -- 424
	) -- 424
end -- 411
local function toJson(value) -- 427
	local text, err = safeJsonEncode(value) -- 428
	if text ~= nil then -- 428
		return text -- 429
	end -- 429
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 430
end -- 427
local function utf8TakeHead(text, maxChars) -- 440
	if maxChars <= 0 or text == "" then -- 440
		return "" -- 441
	end -- 441
	local nextPos = utf8.offset(text, maxChars + 1) -- 442
	if nextPos == nil then -- 442
		return text -- 443
	end -- 443
	return string.sub(text, 1, nextPos - 1) -- 444
end -- 440
local function limitReadContentForHistory(content, tool) -- 461
	local lines = __TS__StringSplit(content, "\n") -- 462
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 463
	local limitedByLines = overLineLimit and table.concat( -- 464
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 465
		"\n" -- 465
	) or content -- 465
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 465
		return content -- 468
	end -- 468
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 470
	local reasons = {} -- 473
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 473
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 474
	end -- 474
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 474
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 475
	end -- 475
	local hint = "Narrow the requested line range." -- 476
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 477
end -- 461
local function summarizeEditTextParamForHistory(value, key) -- 480
	if type(value) ~= "string" then -- 480
		return nil -- 481
	end -- 481
	local text = value -- 482
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 483
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 484
end -- 480
local function sanitizeReadResultForHistory(tool, result) -- 492
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 492
		return result -- 494
	end -- 494
	local clone = {} -- 496
	for key in pairs(result) do -- 497
		clone[key] = result[key] -- 498
	end -- 498
	clone.content = limitReadContentForHistory(result.content, tool) -- 500
	return clone -- 501
end -- 492
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 504
	local shown = math.min(#items, maxItems) -- 508
	local out = {} -- 509
	do -- 509
		local i = 0 -- 510
		while i < shown do -- 510
			local row = items[i + 1] -- 511
			out[#out + 1] = { -- 512
				file = row.file, -- 513
				line = row.line, -- 514
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 515
			} -- 515
			i = i + 1 -- 510
		end -- 510
	end -- 510
	return out -- 520
end -- 504
local function sanitizeSearchResultForHistory(tool, result) -- 523
	if result.success ~= true or not isArray(result.results) then -- 523
		return result -- 527
	end -- 527
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 527
		return result -- 528
	end -- 528
	local clone = {} -- 529
	for key in pairs(result) do -- 530
		clone[key] = result[key] -- 531
	end -- 531
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 533
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 534
	if tool == "grep_files" and isArray(result.groupedResults) then -- 534
		local grouped = result.groupedResults -- 539
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 540
		local sanitizedGroups = {} -- 541
		do -- 541
			local i = 0 -- 542
			while i < shown do -- 542
				local row = grouped[i + 1] -- 543
				sanitizedGroups[#sanitizedGroups + 1] = { -- 544
					file = row.file, -- 545
					totalMatches = row.totalMatches, -- 546
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 547
				} -- 547
				i = i + 1 -- 542
			end -- 542
		end -- 542
		clone.groupedResults = sanitizedGroups -- 552
	end -- 552
	return clone -- 554
end -- 523
local function sanitizeListFilesResultForHistory(result) -- 557
	if result.success ~= true or not isArray(result.files) then -- 557
		return result -- 558
	end -- 558
	local clone = {} -- 559
	for key in pairs(result) do -- 560
		clone[key] = result[key] -- 561
	end -- 561
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 563
	return clone -- 564
end -- 557
local function sanitizeActionParamsForHistory(tool, params) -- 567
	if tool ~= "edit_file" then -- 567
		return params -- 568
	end -- 568
	local clone = {} -- 569
	for key in pairs(params) do -- 570
		if key == "old_str" then -- 570
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 572
		elseif key == "new_str" then -- 572
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 574
		else -- 574
			clone[key] = params[key] -- 576
		end -- 576
	end -- 576
	return clone -- 579
end -- 567
local function maybeCompressHistory(shared) -- 599
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 599
		local ____shared_5 = shared -- 600
		local memory = ____shared_5.memory -- 600
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 601
		local changed = false -- 602
		do -- 602
			local round = 0 -- 603
			while round < maxRounds do -- 603
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 604
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 608
				if not memory.compressor:shouldCompress(shared.messages, systemPrompt, toolDefinitions) then -- 608
					if changed then -- 608
						persistHistoryState(shared) -- 617
					end -- 617
					return ____awaiter_resolve(nil) -- 617
				end -- 617
				local compressionRound = round + 1 -- 621
				shared.step = shared.step + 1 -- 622
				local stepId = shared.step -- 623
				local pendingMessages = #shared.messages -- 624
				emitAgentEvent( -- 625
					shared, -- 625
					{ -- 625
						type = "memory_compression_started", -- 626
						sessionId = shared.sessionId, -- 627
						taskId = shared.taskId, -- 628
						step = stepId, -- 629
						tool = "compress_memory", -- 630
						reason = getMemoryCompressionStartReason(shared), -- 631
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 632
					} -- 632
				) -- 632
				local result = __TS__Await(memory.compressor:compress( -- 638
					shared.messages, -- 639
					systemPrompt, -- 640
					toolDefinitions, -- 641
					shared.llmOptions, -- 642
					shared.llmMaxTry, -- 643
					shared.decisionMode, -- 644
					{ -- 645
						onInput = function(____, phase, messages, options) -- 646
							saveStepLLMDebugInput( -- 647
								shared, -- 647
								stepId, -- 647
								phase, -- 647
								messages, -- 647
								options -- 647
							) -- 647
						end, -- 646
						onOutput = function(____, phase, text, meta) -- 649
							saveStepLLMDebugOutput( -- 650
								shared, -- 650
								stepId, -- 650
								phase, -- 650
								text, -- 650
								meta -- 650
							) -- 650
						end -- 649
					} -- 649
				)) -- 649
				if not (result and result.success and result.compressedCount > 0) then -- 649
					emitAgentEvent( -- 655
						shared, -- 655
						{ -- 655
							type = "memory_compression_finished", -- 656
							sessionId = shared.sessionId, -- 657
							taskId = shared.taskId, -- 658
							step = stepId, -- 659
							tool = "compress_memory", -- 660
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 661
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 665
						} -- 665
					) -- 665
					if changed then -- 665
						persistHistoryState(shared) -- 673
					end -- 673
					return ____awaiter_resolve(nil) -- 673
				end -- 673
				emitAgentEvent( -- 677
					shared, -- 677
					{ -- 677
						type = "memory_compression_finished", -- 678
						sessionId = shared.sessionId, -- 679
						taskId = shared.taskId, -- 680
						step = stepId, -- 681
						tool = "compress_memory", -- 682
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 683
						result = { -- 684
							success = true, -- 685
							round = compressionRound, -- 686
							compressedCount = result.compressedCount, -- 687
							historyEntryPreview = summarizeHistoryEntryPreview(result.historyEntry) -- 688
						} -- 688
					} -- 688
				) -- 688
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 691
				changed = true -- 692
				Log( -- 693
					"Info", -- 693
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 693
				) -- 693
				round = round + 1 -- 603
			end -- 603
		end -- 603
		if changed then -- 603
			persistHistoryState(shared) -- 696
		end -- 696
	end) -- 696
end -- 599
local function compactAllHistory(shared) -- 700
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 700
		local ____shared_12 = shared -- 701
		local memory = ____shared_12.memory -- 701
		local rounds = 0 -- 702
		local totalCompressed = 0 -- 703
		while #shared.messages > 0 do -- 703
			if shared.stopToken.stopped then -- 703
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 706
				return ____awaiter_resolve( -- 706
					nil, -- 706
					emitAgentTaskFinishEvent( -- 707
						shared, -- 707
						false, -- 707
						getCancelledReason(shared) -- 707
					) -- 707
				) -- 707
			end -- 707
			local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 709
			local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 710
			rounds = rounds + 1 -- 713
			shared.step = shared.step + 1 -- 714
			local stepId = shared.step -- 715
			local pendingMessages = #shared.messages -- 716
			emitAgentEvent( -- 717
				shared, -- 717
				{ -- 717
					type = "memory_compression_started", -- 718
					sessionId = shared.sessionId, -- 719
					taskId = shared.taskId, -- 720
					step = stepId, -- 721
					tool = "compress_memory", -- 722
					reason = getMemoryCompressionStartReason(shared), -- 723
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 724
				} -- 724
			) -- 724
			local result = __TS__Await(memory.compressor:compress( -- 731
				shared.messages, -- 732
				systemPrompt, -- 733
				toolDefinitions, -- 734
				shared.llmOptions, -- 735
				shared.llmMaxTry, -- 736
				shared.decisionMode, -- 737
				{ -- 738
					onInput = function(____, phase, messages, options) -- 739
						saveStepLLMDebugInput( -- 740
							shared, -- 740
							stepId, -- 740
							phase, -- 740
							messages, -- 740
							options -- 740
						) -- 740
					end, -- 739
					onOutput = function(____, phase, text, meta) -- 742
						saveStepLLMDebugOutput( -- 743
							shared, -- 743
							stepId, -- 743
							phase, -- 743
							text, -- 743
							meta -- 743
						) -- 743
					end -- 742
				}, -- 742
				"budget_max" -- 746
			)) -- 746
			if not (result and result.success and result.compressedCount > 0) then -- 746
				emitAgentEvent( -- 749
					shared, -- 749
					{ -- 749
						type = "memory_compression_finished", -- 750
						sessionId = shared.sessionId, -- 751
						taskId = shared.taskId, -- 752
						step = stepId, -- 753
						tool = "compress_memory", -- 754
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 755
						result = { -- 759
							success = false, -- 760
							rounds = rounds, -- 761
							error = result and result.error or "compression returned no changes", -- 762
							compressedCount = result and result.compressedCount or 0, -- 763
							fullCompaction = true -- 764
						} -- 764
					} -- 764
				) -- 764
				return ____awaiter_resolve( -- 764
					nil, -- 764
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 767
				) -- 767
			end -- 767
			emitAgentEvent( -- 772
				shared, -- 772
				{ -- 772
					type = "memory_compression_finished", -- 773
					sessionId = shared.sessionId, -- 774
					taskId = shared.taskId, -- 775
					step = stepId, -- 776
					tool = "compress_memory", -- 777
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 778
					result = { -- 779
						success = true, -- 780
						round = rounds, -- 781
						compressedCount = result.compressedCount, -- 782
						historyEntryPreview = summarizeHistoryEntryPreview(result.historyEntry), -- 783
						fullCompaction = true -- 784
					} -- 784
				} -- 784
			) -- 784
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 787
			totalCompressed = totalCompressed + result.compressedCount -- 788
			persistHistoryState(shared) -- 789
			Log( -- 790
				"Info", -- 790
				((("[Memory] Full compaction compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 790
			) -- 790
		end -- 790
		Tools.setTaskStatus(shared.taskId, "DONE") -- 792
		return ____awaiter_resolve( -- 792
			nil, -- 792
			emitAgentTaskFinishEvent( -- 793
				shared, -- 794
				true, -- 795
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 796
			) -- 796
		) -- 796
	end) -- 796
end -- 700
local function resetSessionHistory(shared) -- 802
	shared.messages = {} -- 803
	persistHistoryState(shared) -- 804
	Tools.setTaskStatus(shared.taskId, "DONE") -- 805
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 806
end -- 802
local function isKnownToolName(name) -- 815
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 816
end -- 815
local function getFinishMessage(params, fallback) -- 826
	if fallback == nil then -- 826
		fallback = "" -- 826
	end -- 826
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 826
		return __TS__StringTrim(params.message) -- 828
	end -- 828
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 828
		return __TS__StringTrim(params.response) -- 831
	end -- 831
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 831
		return __TS__StringTrim(params.summary) -- 834
	end -- 834
	return __TS__StringTrim(fallback) -- 836
end -- 826
local function appendConversationMessage(shared, message) -- 858
	local ____shared_messages_21 = shared.messages -- 858
	____shared_messages_21[#____shared_messages_21 + 1] = __TS__ObjectAssign( -- 859
		{}, -- 859
		message, -- 860
		{ -- 859
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 861
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 862
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 863
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 864
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 865
		} -- 865
	) -- 865
end -- 858
local function ensureToolCallId(toolCallId) -- 869
	if toolCallId and toolCallId ~= "" then -- 869
		return toolCallId -- 870
	end -- 870
	return createLocalToolCallId() -- 871
end -- 869
local function appendToolResultMessage(shared, action) -- 874
	appendConversationMessage( -- 875
		shared, -- 875
		{ -- 875
			role = "tool", -- 876
			tool_call_id = action.toolCallId, -- 877
			name = action.tool, -- 878
			content = action.result and toJson(action.result) or "" -- 879
		} -- 879
	) -- 879
end -- 874
local function parseXMLToolCallObjectFromText(text) -- 883
	local children = parseXMLObjectFromText(text, "tool_call") -- 884
	if not children.success then -- 884
		return children -- 885
	end -- 885
	local rawObj = children.obj -- 886
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 887
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 888
	if not params.success then -- 888
		return {success = false, message = params.message} -- 892
	end -- 892
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 894
end -- 883
local function llm(shared, messages, phase) -- 913
	if phase == nil then -- 913
		phase = "decision_xml" -- 916
	end -- 916
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 916
		local stepId = shared.step + 1 -- 918
		saveStepLLMDebugInput( -- 919
			shared, -- 919
			stepId, -- 919
			phase, -- 919
			messages, -- 919
			shared.llmOptions -- 919
		) -- 919
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 920
		if res.success then -- 920
			local ____opt_26 = res.response.choices -- 920
			local ____opt_24 = ____opt_26 and ____opt_26[1] -- 920
			local ____opt_22 = ____opt_24 and ____opt_24.message -- 920
			local text = ____opt_22 and ____opt_22.content -- 922
			if text then -- 922
				saveStepLLMDebugOutput( -- 924
					shared, -- 924
					stepId, -- 924
					phase, -- 924
					text, -- 924
					{success = true} -- 924
				) -- 924
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 924
			else -- 924
				saveStepLLMDebugOutput( -- 927
					shared, -- 927
					stepId, -- 927
					phase, -- 927
					"empty LLM response", -- 927
					{success = false} -- 927
				) -- 927
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 927
			end -- 927
		else -- 927
			saveStepLLMDebugOutput( -- 931
				shared, -- 931
				stepId, -- 931
				phase, -- 931
				res.raw or res.message, -- 931
				{success = false} -- 931
			) -- 931
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 931
		end -- 931
	end) -- 931
end -- 913
local function parseDecisionObject(rawObj) -- 948
	if type(rawObj.tool) ~= "string" then -- 948
		return {success = false, message = "missing tool"} -- 949
	end -- 949
	local tool = rawObj.tool -- 950
	if not isKnownToolName(tool) then -- 950
		return {success = false, message = "unknown tool: " .. tool} -- 952
	end -- 952
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 954
	if tool ~= "finish" and (not reason or reason == "") then -- 954
		return {success = false, message = tool .. " requires top-level reason"} -- 958
	end -- 958
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 960
	return {success = true, tool = tool, params = params, reason = reason} -- 961
end -- 948
local function parseDecisionToolCall(functionName, rawObj) -- 969
	if not isKnownToolName(functionName) then -- 969
		return {success = false, message = "unknown tool: " .. functionName} -- 971
	end -- 971
	if rawObj == nil or rawObj == nil then -- 971
		return {success = true, tool = functionName, params = {}} -- 974
	end -- 974
	if not isRecord(rawObj) then -- 974
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 977
	end -- 977
	return {success = true, tool = functionName, params = rawObj} -- 979
end -- 969
local function getDecisionPath(params) -- 986
	if type(params.path) == "string" then -- 986
		return __TS__StringTrim(params.path) -- 987
	end -- 987
	if type(params.target_file) == "string" then -- 987
		return __TS__StringTrim(params.target_file) -- 988
	end -- 988
	return "" -- 989
end -- 986
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 992
	local num = __TS__Number(value) -- 993
	if not __TS__NumberIsFinite(num) then -- 993
		num = fallback -- 994
	end -- 994
	num = math.floor(num) -- 995
	if num < minValue then -- 995
		num = minValue -- 996
	end -- 996
	if maxValue ~= nil and num > maxValue then -- 996
		num = maxValue -- 997
	end -- 997
	return num -- 998
end -- 992
local function validateDecision(tool, params) -- 1001
	if tool == "finish" then -- 1001
		local message = getFinishMessage(params) -- 1006
		if message == "" then -- 1006
			return {success = false, message = "finish requires params.message"} -- 1007
		end -- 1007
		params.message = message -- 1008
		return {success = true, params = params} -- 1009
	end -- 1009
	if tool == "read_file" then -- 1009
		local path = getDecisionPath(params) -- 1013
		if path == "" then -- 1013
			return {success = false, message = "read_file requires path"} -- 1014
		end -- 1014
		params.path = path -- 1015
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 1016
		local ____params_endLine_28 = params.endLine -- 1017
		if ____params_endLine_28 == nil then -- 1017
			____params_endLine_28 = READ_FILE_DEFAULT_LIMIT -- 1017
		end -- 1017
		local endLineRaw = ____params_endLine_28 -- 1017
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 1018
		params.startLine = startLine -- 1019
		params.endLine = endLine -- 1020
		return {success = true, params = params} -- 1021
	end -- 1021
	if tool == "edit_file" then -- 1021
		local path = getDecisionPath(params) -- 1025
		if path == "" then -- 1025
			return {success = false, message = "edit_file requires path"} -- 1026
		end -- 1026
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1027
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1028
		params.path = path -- 1029
		params.old_str = oldStr -- 1030
		params.new_str = newStr -- 1031
		return {success = true, params = params} -- 1032
	end -- 1032
	if tool == "delete_file" then -- 1032
		local targetFile = getDecisionPath(params) -- 1036
		if targetFile == "" then -- 1036
			return {success = false, message = "delete_file requires target_file"} -- 1037
		end -- 1037
		params.target_file = targetFile -- 1038
		return {success = true, params = params} -- 1039
	end -- 1039
	if tool == "grep_files" then -- 1039
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1043
		if pattern == "" then -- 1043
			return {success = false, message = "grep_files requires pattern"} -- 1044
		end -- 1044
		params.pattern = pattern -- 1045
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1046
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1047
		return {success = true, params = params} -- 1048
	end -- 1048
	if tool == "search_dora_api" then -- 1048
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1052
		if pattern == "" then -- 1052
			return {success = false, message = "search_dora_api requires pattern"} -- 1053
		end -- 1053
		params.pattern = pattern -- 1054
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1055
		return {success = true, params = params} -- 1056
	end -- 1056
	if tool == "glob_files" then -- 1056
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1060
		return {success = true, params = params} -- 1061
	end -- 1061
	if tool == "build" then -- 1061
		local path = getDecisionPath(params) -- 1065
		if path ~= "" then -- 1065
			params.path = path -- 1067
		end -- 1067
		return {success = true, params = params} -- 1069
	end -- 1069
	return {success = true, params = params} -- 1072
end -- 1001
local function createFunctionToolSchema(name, description, properties, required) -- 1075
	if required == nil then -- 1075
		required = {} -- 1079
	end -- 1079
	local parameters = {type = "object", properties = properties} -- 1081
	if #required > 0 then -- 1081
		parameters.required = required -- 1086
	end -- 1086
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1088
end -- 1075
local function buildDecisionToolSchema() -- 1098
	return { -- 1099
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Parameters: path, startLine(optional), endLine(optional). Line numbering starts with 1. startLine defaults to 1 and endLine defaults to 300.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "1-based starting line number. Defaults to 1."}, endLine = {type = "number", description = "1-based ending line number. Defaults to 300."}}, {"path"}), -- 1100
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 1110
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1120
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1128
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1132
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1133
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1134
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1135
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1136
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1137
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1138
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1139
		}, {"pattern"}), -- 1139
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1143
		createFunctionToolSchema( -- 1152
			"search_dora_api", -- 1153
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1153
			{ -- 1155
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1156
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1157
				programmingLanguage = {type = "string", enum = { -- 1158
					"ts", -- 1160
					"tsx", -- 1160
					"lua", -- 1160
					"yue", -- 1160
					"teal", -- 1160
					"tl", -- 1160
					"wa" -- 1160
				}, description = "Preferred language variant to search."}, -- 1160
				limit = { -- 1163
					type = "number", -- 1163
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1163
				}, -- 1163
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1164
			}, -- 1164
			{"pattern"} -- 1166
		), -- 1166
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}) -- 1168
	} -- 1168
end -- 1098
local function sanitizeMessagesForLLMInput(messages) -- 1208
	local sanitized = {} -- 1209
	local droppedAssistantToolCalls = 0 -- 1210
	local droppedToolResults = 0 -- 1211
	do -- 1211
		local i = 0 -- 1212
		while i < #messages do -- 1212
			do -- 1212
				local message = messages[i + 1] -- 1213
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1213
					local requiredIds = {} -- 1215
					do -- 1215
						local j = 0 -- 1216
						while j < #message.tool_calls do -- 1216
							local toolCall = message.tool_calls[j + 1] -- 1217
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1218
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1218
								requiredIds[#requiredIds + 1] = id -- 1220
							end -- 1220
							j = j + 1 -- 1216
						end -- 1216
					end -- 1216
					if #requiredIds == 0 then -- 1216
						sanitized[#sanitized + 1] = message -- 1224
						goto __continue185 -- 1225
					end -- 1225
					local matchedIds = {} -- 1227
					local matchedTools = {} -- 1228
					local j = i + 1 -- 1229
					while j < #messages do -- 1229
						local toolMessage = messages[j + 1] -- 1231
						if toolMessage.role ~= "tool" then -- 1231
							break -- 1232
						end -- 1232
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1233
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1233
							matchedIds[toolCallId] = true -- 1235
							matchedTools[#matchedTools + 1] = toolMessage -- 1236
						else -- 1236
							droppedToolResults = droppedToolResults + 1 -- 1238
						end -- 1238
						j = j + 1 -- 1240
					end -- 1240
					local complete = true -- 1242
					do -- 1242
						local j = 0 -- 1243
						while j < #requiredIds do -- 1243
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1243
								complete = false -- 1245
								break -- 1246
							end -- 1246
							j = j + 1 -- 1243
						end -- 1243
					end -- 1243
					if complete then -- 1243
						__TS__ArrayPush( -- 1250
							sanitized, -- 1250
							message, -- 1250
							table.unpack(matchedTools) -- 1250
						) -- 1250
					else -- 1250
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1252
						droppedToolResults = droppedToolResults + #matchedTools -- 1253
					end -- 1253
					i = j - 1 -- 1255
					goto __continue185 -- 1256
				end -- 1256
				if message.role == "tool" then -- 1256
					droppedToolResults = droppedToolResults + 1 -- 1259
					goto __continue185 -- 1260
				end -- 1260
				sanitized[#sanitized + 1] = message -- 1262
			end -- 1262
			::__continue185:: -- 1262
			i = i + 1 -- 1212
		end -- 1212
	end -- 1212
	return sanitized -- 1264
end -- 1208
local function getUnconsolidatedMessages(shared) -- 1267
	return sanitizeMessagesForLLMInput(shared.messages) -- 1268
end -- 1267
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1271
	if attempt == nil then -- 1271
		attempt = 1 -- 1271
	end -- 1271
	local messages = { -- 1272
		{ -- 1273
			role = "system", -- 1273
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1273
		}, -- 1273
		table.unpack(getUnconsolidatedMessages(shared)) -- 1274
	} -- 1274
	if lastError and lastError ~= "" then -- 1274
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1277
		messages[#messages + 1] = { -- 1280
			role = "user", -- 1281
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1282
		} -- 1282
	end -- 1282
	return messages -- 1289
end -- 1271
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 1296
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 1303
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 1304
	local repairPrompt = replacePromptVars( -- 1312
		shared.promptPack.xmlDecisionRepairPrompt, -- 1312
		{ -- 1312
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 1313
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 1314
			CANDIDATE_SECTION = candidateSection, -- 1315
			LAST_ERROR = lastError, -- 1316
			ATTEMPT = tostring(attempt) -- 1317
		} -- 1317
	) -- 1317
	return {{role = "system", content = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only."}, {role = "user", content = repairPrompt}} -- 1319
end -- 1296
local function tryParseAndValidateDecision(rawText) -- 1341
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 1342
	if not parsed.success then -- 1342
		return {success = false, message = parsed.message, raw = rawText} -- 1344
	end -- 1344
	local decision = parseDecisionObject(parsed.obj) -- 1346
	if not decision.success then -- 1346
		return {success = false, message = decision.message, raw = rawText} -- 1348
	end -- 1348
	local validation = validateDecision(decision.tool, decision.params) -- 1350
	if not validation.success then -- 1350
		return {success = false, message = validation.message, raw = rawText} -- 1352
	end -- 1352
	decision.params = validation.params -- 1354
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 1355
	return decision -- 1356
end -- 1341
local function normalizeLineEndings(text) -- 1359
	local res = string.gsub(text, "\r\n", "\n") -- 1360
	res = string.gsub(res, "\r", "\n") -- 1361
	return res -- 1362
end -- 1359
local function countOccurrences(text, searchStr) -- 1365
	if searchStr == "" then -- 1365
		return 0 -- 1366
	end -- 1366
	local count = 0 -- 1367
	local pos = 0 -- 1368
	while true do -- 1368
		local idx = (string.find( -- 1370
			text, -- 1370
			searchStr, -- 1370
			math.max(pos + 1, 1), -- 1370
			true -- 1370
		) or 0) - 1 -- 1370
		if idx < 0 then -- 1370
			break -- 1371
		end -- 1371
		count = count + 1 -- 1372
		pos = idx + #searchStr -- 1373
	end -- 1373
	return count -- 1375
end -- 1365
local function replaceFirst(text, oldStr, newStr) -- 1378
	if oldStr == "" then -- 1378
		return text -- 1379
	end -- 1379
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 1380
	if idx < 0 then -- 1380
		return text -- 1381
	end -- 1381
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 1382
end -- 1378
local function splitLines(text) -- 1385
	return __TS__StringSplit(text, "\n") -- 1386
end -- 1385
local function getLeadingWhitespace(text) -- 1389
	local i = 0 -- 1390
	while i < #text do -- 1390
		local ch = __TS__StringAccess(text, i) -- 1392
		if ch ~= " " and ch ~= "\t" then -- 1392
			break -- 1393
		end -- 1393
		i = i + 1 -- 1394
	end -- 1394
	return __TS__StringSubstring(text, 0, i) -- 1396
end -- 1389
local function getCommonIndentPrefix(lines) -- 1399
	local common -- 1400
	do -- 1400
		local i = 0 -- 1401
		while i < #lines do -- 1401
			do -- 1401
				local line = lines[i + 1] -- 1402
				if __TS__StringTrim(line) == "" then -- 1402
					goto __continue224 -- 1403
				end -- 1403
				local indent = getLeadingWhitespace(line) -- 1404
				if common == nil then -- 1404
					common = indent -- 1406
					goto __continue224 -- 1407
				end -- 1407
				local j = 0 -- 1409
				local maxLen = math.min(#common, #indent) -- 1410
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 1410
					j = j + 1 -- 1412
				end -- 1412
				common = __TS__StringSubstring(common, 0, j) -- 1414
				if common == "" then -- 1414
					break -- 1415
				end -- 1415
			end -- 1415
			::__continue224:: -- 1415
			i = i + 1 -- 1401
		end -- 1401
	end -- 1401
	return common or "" -- 1417
end -- 1399
local function removeIndentPrefix(line, indent) -- 1420
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 1420
		return __TS__StringSubstring(line, #indent) -- 1422
	end -- 1422
	local lineIndent = getLeadingWhitespace(line) -- 1424
	local j = 0 -- 1425
	local maxLen = math.min(#lineIndent, #indent) -- 1426
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 1426
		j = j + 1 -- 1428
	end -- 1428
	return __TS__StringSubstring(line, j) -- 1430
end -- 1420
local function dedentLines(lines) -- 1433
	local indent = getCommonIndentPrefix(lines) -- 1434
	return { -- 1435
		indent = indent, -- 1436
		lines = __TS__ArrayMap( -- 1437
			lines, -- 1437
			function(____, line) return removeIndentPrefix(line, indent) end -- 1437
		) -- 1437
	} -- 1437
end -- 1433
local function joinLines(lines) -- 1441
	return table.concat(lines, "\n") -- 1442
end -- 1441
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 1445
	local contentLines = splitLines(content) -- 1450
	local oldLines = splitLines(oldStr) -- 1451
	if #oldLines == 0 then -- 1451
		return {success = false, message = "old_str not found in file"} -- 1453
	end -- 1453
	local dedentedOld = dedentLines(oldLines) -- 1455
	local dedentedOldText = joinLines(dedentedOld.lines) -- 1456
	local dedentedNew = dedentLines(splitLines(newStr)) -- 1457
	local matches = {} -- 1458
	do -- 1458
		local start = 0 -- 1459
		while start <= #contentLines - #oldLines do -- 1459
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 1460
			local dedentedCandidate = dedentLines(candidateLines) -- 1461
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 1461
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 1463
			end -- 1463
			start = start + 1 -- 1459
		end -- 1459
	end -- 1459
	if #matches == 0 then -- 1459
		return {success = false, message = "old_str not found in file"} -- 1471
	end -- 1471
	if #matches > 1 then -- 1471
		return { -- 1474
			success = false, -- 1475
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 1476
		} -- 1476
	end -- 1476
	local match = matches[1] -- 1479
	local rebuiltNewLines = __TS__ArrayMap( -- 1480
		dedentedNew.lines, -- 1480
		function(____, line) return line == "" and "" or match.indent .. line end -- 1480
	) -- 1480
	local ____array_33 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 1480
	__TS__SparseArrayPush( -- 1480
		____array_33, -- 1480
		table.unpack(rebuiltNewLines) -- 1483
	) -- 1483
	__TS__SparseArrayPush( -- 1483
		____array_33, -- 1483
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 1484
	) -- 1484
	local nextLines = {__TS__SparseArraySpread(____array_33)} -- 1481
	return { -- 1486
		success = true, -- 1486
		content = joinLines(nextLines) -- 1486
	} -- 1486
end -- 1445
local MainDecisionAgent = __TS__Class() -- 1489
MainDecisionAgent.name = "MainDecisionAgent" -- 1489
__TS__ClassExtends(MainDecisionAgent, Node) -- 1489
function MainDecisionAgent.prototype.prep(self, shared) -- 1490
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1490
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1490
			return ____awaiter_resolve(nil, {shared = shared}) -- 1490
		end -- 1490
		__TS__Await(maybeCompressHistory(shared)) -- 1495
		return ____awaiter_resolve(nil, {shared = shared}) -- 1495
	end) -- 1495
end -- 1490
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 1500
	if attempt == nil then -- 1500
		attempt = 1 -- 1503
	end -- 1503
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1503
		if shared.stopToken.stopped then -- 1503
			return ____awaiter_resolve( -- 1503
				nil, -- 1503
				{ -- 1507
					success = false, -- 1507
					message = getCancelledReason(shared) -- 1507
				} -- 1507
			) -- 1507
		end -- 1507
		Log( -- 1509
			"Info", -- 1509
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1509
		) -- 1509
		local tools = buildDecisionToolSchema() -- 1510
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1511
		local stepId = shared.step + 1 -- 1512
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1513
		saveStepLLMDebugInput( -- 1517
			shared, -- 1517
			stepId, -- 1517
			"decision_tool_calling", -- 1517
			messages, -- 1517
			llmOptions -- 1517
		) -- 1517
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1518
		if shared.stopToken.stopped then -- 1518
			return ____awaiter_resolve( -- 1518
				nil, -- 1518
				{ -- 1520
					success = false, -- 1520
					message = getCancelledReason(shared) -- 1520
				} -- 1520
			) -- 1520
		end -- 1520
		if not res.success then -- 1520
			saveStepLLMDebugOutput( -- 1523
				shared, -- 1523
				stepId, -- 1523
				"decision_tool_calling", -- 1523
				res.raw or res.message, -- 1523
				{success = false} -- 1523
			) -- 1523
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1524
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1524
		end -- 1524
		saveStepLLMDebugOutput( -- 1527
			shared, -- 1527
			stepId, -- 1527
			"decision_tool_calling", -- 1527
			encodeDebugJSON(res.response), -- 1527
			{success = true} -- 1527
		) -- 1527
		local choice = res.response.choices and res.response.choices[1] -- 1528
		local message = choice and choice.message -- 1529
		local toolCalls = message and message.tool_calls -- 1530
		local toolCall = toolCalls and toolCalls[1] -- 1531
		local fn = toolCall and toolCall["function"] -- 1532
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 1533
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1536
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1539
		Log( -- 1542
			"Info", -- 1542
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1542
		) -- 1542
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1542
			if messageContent and messageContent ~= "" then -- 1542
				Log( -- 1545
					"Info", -- 1545
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1545
				) -- 1545
				return ____awaiter_resolve(nil, { -- 1545
					success = true, -- 1547
					tool = "finish", -- 1548
					params = {}, -- 1549
					reason = messageContent, -- 1550
					reasoningContent = reasoningContent, -- 1551
					directSummary = messageContent -- 1552
				}) -- 1552
			end -- 1552
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1555
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1555
		end -- 1555
		local functionName = fn.name -- 1562
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1563
		Log( -- 1564
			"Info", -- 1564
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1564
		) -- 1564
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1565
			local rawObj, err = safeJsonDecode(argsText) -- 1566
			if err ~= nil or rawObj == nil then -- 1566
				return {__error = tostring(err)} -- 1568
			end -- 1568
			return rawObj -- 1570
		end)() -- 1565
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 1565
			local err = tostring(rawArgs.__error) -- 1573
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1574
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1574
		end -- 1574
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1581
		if not decision.success then -- 1581
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1583
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1583
		end -- 1583
		local validation = validateDecision(decision.tool, decision.params) -- 1590
		if not validation.success then -- 1590
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1592
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1592
		end -- 1592
		decision.params = validation.params -- 1599
		decision.toolCallId = ensureToolCallId(toolCallId) -- 1600
		decision.reason = messageContent -- 1601
		decision.reasoningContent = reasoningContent -- 1602
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1603
		return ____awaiter_resolve(nil, decision) -- 1603
	end) -- 1603
end -- 1500
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 1607
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1607
		Log( -- 1612
			"Info", -- 1612
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 1612
		) -- 1612
		local lastError = initialError -- 1613
		local candidateRaw = "" -- 1614
		do -- 1614
			local attempt = 0 -- 1615
			while attempt < shared.llmMaxTry do -- 1615
				do -- 1615
					Log( -- 1616
						"Info", -- 1616
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 1616
					) -- 1616
					local messages = buildXmlRepairMessages( -- 1617
						shared, -- 1618
						originalRaw, -- 1619
						candidateRaw, -- 1620
						lastError, -- 1621
						attempt + 1 -- 1622
					) -- 1622
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 1624
					if shared.stopToken.stopped then -- 1624
						return ____awaiter_resolve( -- 1624
							nil, -- 1624
							{ -- 1626
								success = false, -- 1626
								message = getCancelledReason(shared) -- 1626
							} -- 1626
						) -- 1626
					end -- 1626
					if not llmRes.success then -- 1626
						lastError = llmRes.message -- 1629
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 1630
						goto __continue258 -- 1631
					end -- 1631
					candidateRaw = llmRes.text -- 1633
					local decision = tryParseAndValidateDecision(candidateRaw) -- 1634
					if decision.success then -- 1634
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 1636
						return ____awaiter_resolve(nil, decision) -- 1636
					end -- 1636
					lastError = decision.message -- 1639
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 1640
				end -- 1640
				::__continue258:: -- 1640
				attempt = attempt + 1 -- 1615
			end -- 1615
		end -- 1615
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 1642
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 1642
	end) -- 1642
end -- 1607
function MainDecisionAgent.prototype.exec(self, input) -- 1650
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1650
		local shared = input.shared -- 1651
		if shared.stopToken.stopped then -- 1651
			return ____awaiter_resolve( -- 1651
				nil, -- 1651
				{ -- 1653
					success = false, -- 1653
					message = getCancelledReason(shared) -- 1653
				} -- 1653
			) -- 1653
		end -- 1653
		if shared.step >= shared.maxSteps then -- 1653
			Log( -- 1656
				"Warn", -- 1656
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1656
			) -- 1656
			return ____awaiter_resolve( -- 1656
				nil, -- 1656
				{ -- 1657
					success = false, -- 1657
					message = getMaxStepsReachedReason(shared) -- 1657
				} -- 1657
			) -- 1657
		end -- 1657
		if shared.decisionMode == "tool_calling" then -- 1657
			Log( -- 1661
				"Info", -- 1661
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 1661
			) -- 1661
			local lastError = "tool calling validation failed" -- 1662
			local lastRaw = "" -- 1663
			do -- 1663
				local attempt = 0 -- 1664
				while attempt < shared.llmMaxTry do -- 1664
					Log( -- 1665
						"Info", -- 1665
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1665
					) -- 1665
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 1666
					if shared.stopToken.stopped then -- 1666
						return ____awaiter_resolve( -- 1666
							nil, -- 1666
							{ -- 1673
								success = false, -- 1673
								message = getCancelledReason(shared) -- 1673
							} -- 1673
						) -- 1673
					end -- 1673
					if decision.success then -- 1673
						return ____awaiter_resolve(nil, decision) -- 1673
					end -- 1673
					lastError = decision.message -- 1678
					lastRaw = decision.raw or "" -- 1679
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1680
					attempt = attempt + 1 -- 1664
				end -- 1664
			end -- 1664
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1682
			return ____awaiter_resolve( -- 1682
				nil, -- 1682
				{ -- 1683
					success = false, -- 1683
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1683
				} -- 1683
			) -- 1683
		end -- 1683
		local lastError = "xml validation failed" -- 1686
		local lastRaw = "" -- 1687
		do -- 1687
			local attempt = 0 -- 1688
			while attempt < shared.llmMaxTry do -- 1688
				do -- 1688
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 1689
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 1697
					if shared.stopToken.stopped then -- 1697
						return ____awaiter_resolve( -- 1697
							nil, -- 1697
							{ -- 1699
								success = false, -- 1699
								message = getCancelledReason(shared) -- 1699
							} -- 1699
						) -- 1699
					end -- 1699
					if not llmRes.success then -- 1699
						lastError = llmRes.message -- 1702
						lastRaw = llmRes.text or "" -- 1703
						goto __continue271 -- 1704
					end -- 1704
					lastRaw = llmRes.text -- 1706
					local decision = tryParseAndValidateDecision(llmRes.text) -- 1707
					if decision.success then -- 1707
						return ____awaiter_resolve(nil, decision) -- 1707
					end -- 1707
					lastError = decision.message -- 1711
					return ____awaiter_resolve( -- 1711
						nil, -- 1711
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 1712
					) -- 1712
				end -- 1712
				::__continue271:: -- 1712
				attempt = attempt + 1 -- 1688
			end -- 1688
		end -- 1688
		return ____awaiter_resolve( -- 1688
			nil, -- 1688
			{ -- 1714
				success = false, -- 1714
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1714
			} -- 1714
		) -- 1714
	end) -- 1714
end -- 1650
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1717
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1717
		local result = execRes -- 1718
		if not result.success then -- 1718
			shared.error = result.message -- 1720
			shared.response = getFailureSummaryFallback(shared, result.message) -- 1721
			shared.done = true -- 1722
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 1723
			persistHistoryState(shared) -- 1727
			return ____awaiter_resolve(nil, "done") -- 1727
		end -- 1727
		if result.directSummary and result.directSummary ~= "" then -- 1727
			shared.response = result.directSummary -- 1731
			shared.done = true -- 1732
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 1733
			persistHistoryState(shared) -- 1738
			return ____awaiter_resolve(nil, "done") -- 1738
		end -- 1738
		if result.tool == "finish" then -- 1738
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 1742
			shared.response = finalMessage -- 1743
			shared.done = true -- 1744
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 1745
			persistHistoryState(shared) -- 1750
			return ____awaiter_resolve(nil, "done") -- 1750
		end -- 1750
		local toolCallId = ensureToolCallId(result.toolCallId) -- 1753
		shared.step = shared.step + 1 -- 1754
		local step = shared.step -- 1755
		emitAgentEvent(shared, { -- 1756
			type = "decision_made", -- 1757
			sessionId = shared.sessionId, -- 1758
			taskId = shared.taskId, -- 1759
			step = step, -- 1760
			tool = result.tool, -- 1761
			reason = result.reason, -- 1762
			reasoningContent = result.reasoningContent, -- 1763
			params = result.params -- 1764
		}) -- 1764
		local ____shared_history_34 = shared.history -- 1764
		____shared_history_34[#____shared_history_34 + 1] = { -- 1766
			step = step, -- 1767
			toolCallId = toolCallId, -- 1768
			tool = result.tool, -- 1769
			reason = result.reason or "", -- 1770
			reasoningContent = result.reasoningContent, -- 1771
			params = result.params, -- 1772
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1773
		} -- 1773
		appendConversationMessage( -- 1775
			shared, -- 1775
			{ -- 1775
				role = "assistant", -- 1776
				content = result.reason or "", -- 1777
				reasoning_content = result.reasoningContent, -- 1778
				tool_calls = {{ -- 1779
					id = toolCallId, -- 1780
					type = "function", -- 1781
					["function"] = { -- 1782
						name = result.tool, -- 1783
						arguments = toJson(result.params) -- 1784
					} -- 1784
				}} -- 1784
			} -- 1784
		) -- 1784
		persistHistoryState(shared) -- 1788
		return ____awaiter_resolve(nil, result.tool) -- 1788
	end) -- 1788
end -- 1717
local ReadFileAction = __TS__Class() -- 1793
ReadFileAction.name = "ReadFileAction" -- 1793
__TS__ClassExtends(ReadFileAction, Node) -- 1793
function ReadFileAction.prototype.prep(self, shared) -- 1794
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1794
		local last = shared.history[#shared.history] -- 1795
		if not last then -- 1795
			error( -- 1796
				__TS__New(Error, "no history"), -- 1796
				0 -- 1796
			) -- 1796
		end -- 1796
		emitAgentStartEvent(shared, last) -- 1797
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1798
		if __TS__StringTrim(path) == "" then -- 1798
			error( -- 1801
				__TS__New(Error, "missing path"), -- 1801
				0 -- 1801
			) -- 1801
		end -- 1801
		local ____path_37 = path -- 1803
		local ____shared_workingDir_38 = shared.workingDir -- 1805
		local ____temp_39 = shared.useChineseResponse and "zh" or "en" -- 1806
		local ____last_params_startLine_35 = last.params.startLine -- 1807
		if ____last_params_startLine_35 == nil then -- 1807
			____last_params_startLine_35 = 1 -- 1807
		end -- 1807
		local ____TS__Number_result_40 = __TS__Number(____last_params_startLine_35) -- 1807
		local ____last_params_endLine_36 = last.params.endLine -- 1808
		if ____last_params_endLine_36 == nil then -- 1808
			____last_params_endLine_36 = READ_FILE_DEFAULT_LIMIT -- 1808
		end -- 1808
		return ____awaiter_resolve( -- 1808
			nil, -- 1808
			{ -- 1802
				path = ____path_37, -- 1803
				tool = "read_file", -- 1804
				workDir = ____shared_workingDir_38, -- 1805
				docLanguage = ____temp_39, -- 1806
				startLine = ____TS__Number_result_40, -- 1807
				endLine = __TS__Number(____last_params_endLine_36) -- 1808
			} -- 1808
		) -- 1808
	end) -- 1808
end -- 1794
function ReadFileAction.prototype.exec(self, input) -- 1812
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1812
		return ____awaiter_resolve( -- 1812
			nil, -- 1812
			Tools.readFile( -- 1813
				input.workDir, -- 1814
				input.path, -- 1815
				__TS__Number(input.startLine or 1), -- 1816
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1817
				input.docLanguage -- 1818
			) -- 1818
		) -- 1818
	end) -- 1818
end -- 1812
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1822
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1822
		local result = execRes -- 1823
		local last = shared.history[#shared.history] -- 1824
		if last ~= nil then -- 1824
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1826
			appendToolResultMessage(shared, last) -- 1827
			emitAgentFinishEvent(shared, last) -- 1828
		end -- 1828
		persistHistoryState(shared) -- 1830
		__TS__Await(maybeCompressHistory(shared)) -- 1831
		persistHistoryState(shared) -- 1832
		return ____awaiter_resolve(nil, "main") -- 1832
	end) -- 1832
end -- 1822
local SearchFilesAction = __TS__Class() -- 1837
SearchFilesAction.name = "SearchFilesAction" -- 1837
__TS__ClassExtends(SearchFilesAction, Node) -- 1837
function SearchFilesAction.prototype.prep(self, shared) -- 1838
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1838
		local last = shared.history[#shared.history] -- 1839
		if not last then -- 1839
			error( -- 1840
				__TS__New(Error, "no history"), -- 1840
				0 -- 1840
			) -- 1840
		end -- 1840
		emitAgentStartEvent(shared, last) -- 1841
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1841
	end) -- 1841
end -- 1838
function SearchFilesAction.prototype.exec(self, input) -- 1845
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1845
		local params = input.params -- 1846
		local ____Tools_searchFiles_54 = Tools.searchFiles -- 1847
		local ____input_workDir_47 = input.workDir -- 1848
		local ____temp_48 = params.path or "" -- 1849
		local ____temp_49 = params.pattern or "" -- 1850
		local ____params_globs_50 = params.globs -- 1851
		local ____params_useRegex_51 = params.useRegex -- 1852
		local ____params_caseSensitive_52 = params.caseSensitive -- 1853
		local ____math_max_43 = math.max -- 1856
		local ____math_floor_42 = math.floor -- 1856
		local ____params_limit_41 = params.limit -- 1856
		if ____params_limit_41 == nil then -- 1856
			____params_limit_41 = SEARCH_FILES_LIMIT_DEFAULT -- 1856
		end -- 1856
		local ____math_max_43_result_53 = ____math_max_43( -- 1856
			1, -- 1856
			____math_floor_42(__TS__Number(____params_limit_41)) -- 1856
		) -- 1856
		local ____math_max_46 = math.max -- 1857
		local ____math_floor_45 = math.floor -- 1857
		local ____params_offset_44 = params.offset -- 1857
		if ____params_offset_44 == nil then -- 1857
			____params_offset_44 = 0 -- 1857
		end -- 1857
		local result = __TS__Await(____Tools_searchFiles_54({ -- 1847
			workDir = ____input_workDir_47, -- 1848
			path = ____temp_48, -- 1849
			pattern = ____temp_49, -- 1850
			globs = ____params_globs_50, -- 1851
			useRegex = ____params_useRegex_51, -- 1852
			caseSensitive = ____params_caseSensitive_52, -- 1853
			includeContent = true, -- 1854
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1855
			limit = ____math_max_43_result_53, -- 1856
			offset = ____math_max_46( -- 1857
				0, -- 1857
				____math_floor_45(__TS__Number(____params_offset_44)) -- 1857
			), -- 1857
			groupByFile = params.groupByFile == true -- 1858
		})) -- 1858
		return ____awaiter_resolve(nil, result) -- 1858
	end) -- 1858
end -- 1845
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1863
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1863
		local last = shared.history[#shared.history] -- 1864
		if last ~= nil then -- 1864
			local result = execRes -- 1866
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1867
			appendToolResultMessage(shared, last) -- 1868
			emitAgentFinishEvent(shared, last) -- 1869
		end -- 1869
		persistHistoryState(shared) -- 1871
		__TS__Await(maybeCompressHistory(shared)) -- 1872
		persistHistoryState(shared) -- 1873
		return ____awaiter_resolve(nil, "main") -- 1873
	end) -- 1873
end -- 1863
local SearchDoraAPIAction = __TS__Class() -- 1878
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1878
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1878
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1879
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1879
		local last = shared.history[#shared.history] -- 1880
		if not last then -- 1880
			error( -- 1881
				__TS__New(Error, "no history"), -- 1881
				0 -- 1881
			) -- 1881
		end -- 1881
		emitAgentStartEvent(shared, last) -- 1882
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1882
	end) -- 1882
end -- 1879
function SearchDoraAPIAction.prototype.exec(self, input) -- 1886
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1886
		local params = input.params -- 1887
		local ____Tools_searchDoraAPI_62 = Tools.searchDoraAPI -- 1888
		local ____temp_58 = params.pattern or "" -- 1889
		local ____temp_59 = params.docSource or "api" -- 1890
		local ____temp_60 = input.useChineseResponse and "zh" or "en" -- 1891
		local ____temp_61 = params.programmingLanguage or "ts" -- 1892
		local ____math_min_57 = math.min -- 1893
		local ____math_max_56 = math.max -- 1893
		local ____params_limit_55 = params.limit -- 1893
		if ____params_limit_55 == nil then -- 1893
			____params_limit_55 = 8 -- 1893
		end -- 1893
		local result = __TS__Await(____Tools_searchDoraAPI_62({ -- 1888
			pattern = ____temp_58, -- 1889
			docSource = ____temp_59, -- 1890
			docLanguage = ____temp_60, -- 1891
			programmingLanguage = ____temp_61, -- 1892
			limit = ____math_min_57( -- 1893
				SEARCH_DORA_API_LIMIT_MAX, -- 1893
				____math_max_56( -- 1893
					1, -- 1893
					__TS__Number(____params_limit_55) -- 1893
				) -- 1893
			), -- 1893
			useRegex = params.useRegex, -- 1894
			caseSensitive = false, -- 1895
			includeContent = true, -- 1896
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1897
		})) -- 1897
		return ____awaiter_resolve(nil, result) -- 1897
	end) -- 1897
end -- 1886
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1902
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1902
		local last = shared.history[#shared.history] -- 1903
		if last ~= nil then -- 1903
			local result = execRes -- 1905
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1906
			appendToolResultMessage(shared, last) -- 1907
			emitAgentFinishEvent(shared, last) -- 1908
		end -- 1908
		persistHistoryState(shared) -- 1910
		__TS__Await(maybeCompressHistory(shared)) -- 1911
		persistHistoryState(shared) -- 1912
		return ____awaiter_resolve(nil, "main") -- 1912
	end) -- 1912
end -- 1902
local ListFilesAction = __TS__Class() -- 1917
ListFilesAction.name = "ListFilesAction" -- 1917
__TS__ClassExtends(ListFilesAction, Node) -- 1917
function ListFilesAction.prototype.prep(self, shared) -- 1918
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1918
		local last = shared.history[#shared.history] -- 1919
		if not last then -- 1919
			error( -- 1920
				__TS__New(Error, "no history"), -- 1920
				0 -- 1920
			) -- 1920
		end -- 1920
		emitAgentStartEvent(shared, last) -- 1921
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1921
	end) -- 1921
end -- 1918
function ListFilesAction.prototype.exec(self, input) -- 1925
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1925
		local params = input.params -- 1926
		local ____Tools_listFiles_69 = Tools.listFiles -- 1927
		local ____input_workDir_66 = input.workDir -- 1928
		local ____temp_67 = params.path or "" -- 1929
		local ____params_globs_68 = params.globs -- 1930
		local ____math_max_65 = math.max -- 1931
		local ____math_floor_64 = math.floor -- 1931
		local ____params_maxEntries_63 = params.maxEntries -- 1931
		if ____params_maxEntries_63 == nil then -- 1931
			____params_maxEntries_63 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1931
		end -- 1931
		local result = ____Tools_listFiles_69({ -- 1927
			workDir = ____input_workDir_66, -- 1928
			path = ____temp_67, -- 1929
			globs = ____params_globs_68, -- 1930
			maxEntries = ____math_max_65( -- 1931
				1, -- 1931
				____math_floor_64(__TS__Number(____params_maxEntries_63)) -- 1931
			) -- 1931
		}) -- 1931
		return ____awaiter_resolve(nil, result) -- 1931
	end) -- 1931
end -- 1925
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1936
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1936
		local last = shared.history[#shared.history] -- 1937
		if last ~= nil then -- 1937
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1939
			appendToolResultMessage(shared, last) -- 1940
			emitAgentFinishEvent(shared, last) -- 1941
		end -- 1941
		persistHistoryState(shared) -- 1943
		__TS__Await(maybeCompressHistory(shared)) -- 1944
		persistHistoryState(shared) -- 1945
		return ____awaiter_resolve(nil, "main") -- 1945
	end) -- 1945
end -- 1936
local DeleteFileAction = __TS__Class() -- 1950
DeleteFileAction.name = "DeleteFileAction" -- 1950
__TS__ClassExtends(DeleteFileAction, Node) -- 1950
function DeleteFileAction.prototype.prep(self, shared) -- 1951
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1951
		local last = shared.history[#shared.history] -- 1952
		if not last then -- 1952
			error( -- 1953
				__TS__New(Error, "no history"), -- 1953
				0 -- 1953
			) -- 1953
		end -- 1953
		emitAgentStartEvent(shared, last) -- 1954
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1955
		if __TS__StringTrim(targetFile) == "" then -- 1955
			error( -- 1958
				__TS__New(Error, "missing target_file"), -- 1958
				0 -- 1958
			) -- 1958
		end -- 1958
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1958
	end) -- 1958
end -- 1951
function DeleteFileAction.prototype.exec(self, input) -- 1962
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1962
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1963
		if not result.success then -- 1963
			return ____awaiter_resolve(nil, result) -- 1963
		end -- 1963
		return ____awaiter_resolve(nil, { -- 1963
			success = true, -- 1971
			changed = true, -- 1972
			mode = "delete", -- 1973
			checkpointId = result.checkpointId, -- 1974
			checkpointSeq = result.checkpointSeq, -- 1975
			files = {{path = input.targetFile, op = "delete"}} -- 1976
		}) -- 1976
	end) -- 1976
end -- 1962
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1980
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1980
		local last = shared.history[#shared.history] -- 1981
		if last ~= nil then -- 1981
			last.result = execRes -- 1983
			appendToolResultMessage(shared, last) -- 1984
			emitAgentFinishEvent(shared, last) -- 1985
			local result = last.result -- 1986
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 1986
				emitAgentEvent(shared, { -- 1991
					type = "checkpoint_created", -- 1992
					sessionId = shared.sessionId, -- 1993
					taskId = shared.taskId, -- 1994
					step = last.step, -- 1995
					tool = "delete_file", -- 1996
					checkpointId = result.checkpointId, -- 1997
					checkpointSeq = result.checkpointSeq, -- 1998
					files = result.files -- 1999
				}) -- 1999
			end -- 1999
		end -- 1999
		persistHistoryState(shared) -- 2003
		__TS__Await(maybeCompressHistory(shared)) -- 2004
		persistHistoryState(shared) -- 2005
		return ____awaiter_resolve(nil, "main") -- 2005
	end) -- 2005
end -- 1980
local BuildAction = __TS__Class() -- 2010
BuildAction.name = "BuildAction" -- 2010
__TS__ClassExtends(BuildAction, Node) -- 2010
function BuildAction.prototype.prep(self, shared) -- 2011
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2011
		local last = shared.history[#shared.history] -- 2012
		if not last then -- 2012
			error( -- 2013
				__TS__New(Error, "no history"), -- 2013
				0 -- 2013
			) -- 2013
		end -- 2013
		emitAgentStartEvent(shared, last) -- 2014
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2014
	end) -- 2014
end -- 2011
function BuildAction.prototype.exec(self, input) -- 2018
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2018
		local params = input.params -- 2019
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2020
		return ____awaiter_resolve(nil, result) -- 2020
	end) -- 2020
end -- 2018
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2027
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2027
		local last = shared.history[#shared.history] -- 2028
		if last ~= nil then -- 2028
			last.result = execRes -- 2030
			appendToolResultMessage(shared, last) -- 2031
			emitAgentFinishEvent(shared, last) -- 2032
		end -- 2032
		persistHistoryState(shared) -- 2034
		__TS__Await(maybeCompressHistory(shared)) -- 2035
		persistHistoryState(shared) -- 2036
		return ____awaiter_resolve(nil, "main") -- 2036
	end) -- 2036
end -- 2027
local EditFileAction = __TS__Class() -- 2041
EditFileAction.name = "EditFileAction" -- 2041
__TS__ClassExtends(EditFileAction, Node) -- 2041
function EditFileAction.prototype.prep(self, shared) -- 2042
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2042
		local last = shared.history[#shared.history] -- 2043
		if not last then -- 2043
			error( -- 2044
				__TS__New(Error, "no history"), -- 2044
				0 -- 2044
			) -- 2044
		end -- 2044
		emitAgentStartEvent(shared, last) -- 2045
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2046
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2049
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2050
		if __TS__StringTrim(path) == "" then -- 2050
			error( -- 2051
				__TS__New(Error, "missing path"), -- 2051
				0 -- 2051
			) -- 2051
		end -- 2051
		return ____awaiter_resolve(nil, { -- 2051
			path = path, -- 2052
			oldStr = oldStr, -- 2052
			newStr = newStr, -- 2052
			taskId = shared.taskId, -- 2052
			workDir = shared.workingDir -- 2052
		}) -- 2052
	end) -- 2052
end -- 2042
function EditFileAction.prototype.exec(self, input) -- 2055
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2055
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 2056
		if not readRes.success then -- 2056
			if input.oldStr ~= "" then -- 2056
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 2056
			end -- 2056
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2061
			if not createRes.success then -- 2061
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 2061
			end -- 2061
			return ____awaiter_resolve(nil, { -- 2061
				success = true, -- 2069
				changed = true, -- 2070
				mode = "create", -- 2071
				checkpointId = createRes.checkpointId, -- 2072
				checkpointSeq = createRes.checkpointSeq, -- 2073
				files = {{path = input.path, op = "create"}} -- 2074
			}) -- 2074
		end -- 2074
		if input.oldStr == "" then -- 2074
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2078
			if not overwriteRes.success then -- 2078
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 2078
			end -- 2078
			return ____awaiter_resolve(nil, { -- 2078
				success = true, -- 2086
				changed = true, -- 2087
				mode = "overwrite", -- 2088
				checkpointId = overwriteRes.checkpointId, -- 2089
				checkpointSeq = overwriteRes.checkpointSeq, -- 2090
				files = {{path = input.path, op = "write"}} -- 2091
			}) -- 2091
		end -- 2091
		local normalizedContent = normalizeLineEndings(readRes.content) -- 2096
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 2097
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 2098
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 2101
		if occurrences == 0 then -- 2101
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2103
			if not indentTolerant.success then -- 2103
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 2103
			end -- 2103
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 2107
			if not applyRes.success then -- 2107
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2107
			end -- 2107
			return ____awaiter_resolve(nil, { -- 2107
				success = true, -- 2115
				changed = true, -- 2116
				mode = "replace_indent_tolerant", -- 2117
				checkpointId = applyRes.checkpointId, -- 2118
				checkpointSeq = applyRes.checkpointSeq, -- 2119
				files = {{path = input.path, op = "write"}} -- 2120
			}) -- 2120
		end -- 2120
		if occurrences > 1 then -- 2120
			return ____awaiter_resolve( -- 2120
				nil, -- 2120
				{ -- 2124
					success = false, -- 2124
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 2124
				} -- 2124
			) -- 2124
		end -- 2124
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2128
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2129
		if not applyRes.success then -- 2129
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2129
		end -- 2129
		return ____awaiter_resolve(nil, { -- 2129
			success = true, -- 2137
			changed = true, -- 2138
			mode = "replace", -- 2139
			checkpointId = applyRes.checkpointId, -- 2140
			checkpointSeq = applyRes.checkpointSeq, -- 2141
			files = {{path = input.path, op = "write"}} -- 2142
		}) -- 2142
	end) -- 2142
end -- 2055
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2146
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2146
		local last = shared.history[#shared.history] -- 2147
		if last ~= nil then -- 2147
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 2149
			last.result = execRes -- 2150
			appendToolResultMessage(shared, last) -- 2151
			emitAgentFinishEvent(shared, last) -- 2152
			local result = last.result -- 2153
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2153
				emitAgentEvent(shared, { -- 2158
					type = "checkpoint_created", -- 2159
					sessionId = shared.sessionId, -- 2160
					taskId = shared.taskId, -- 2161
					step = last.step, -- 2162
					tool = last.tool, -- 2163
					checkpointId = result.checkpointId, -- 2164
					checkpointSeq = result.checkpointSeq, -- 2165
					files = result.files -- 2166
				}) -- 2166
			end -- 2166
		end -- 2166
		persistHistoryState(shared) -- 2170
		__TS__Await(maybeCompressHistory(shared)) -- 2171
		persistHistoryState(shared) -- 2172
		return ____awaiter_resolve(nil, "main") -- 2172
	end) -- 2172
end -- 2146
local EndNode = __TS__Class() -- 2177
EndNode.name = "EndNode" -- 2177
__TS__ClassExtends(EndNode, Node) -- 2177
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 2178
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2178
		return ____awaiter_resolve(nil, nil) -- 2178
	end) -- 2178
end -- 2178
local CodingAgentFlow = __TS__Class() -- 2183
CodingAgentFlow.name = "CodingAgentFlow" -- 2183
__TS__ClassExtends(CodingAgentFlow, Flow) -- 2183
function CodingAgentFlow.prototype.____constructor(self) -- 2184
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 2185
	local read = __TS__New(ReadFileAction, 1, 0) -- 2186
	local search = __TS__New(SearchFilesAction, 1, 0) -- 2187
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 2188
	local list = __TS__New(ListFilesAction, 1, 0) -- 2189
	local del = __TS__New(DeleteFileAction, 1, 0) -- 2190
	local build = __TS__New(BuildAction, 1, 0) -- 2191
	local edit = __TS__New(EditFileAction, 1, 0) -- 2192
	local done = __TS__New(EndNode, 1, 0) -- 2193
	main:on("read_file", read) -- 2195
	main:on("grep_files", search) -- 2196
	main:on("search_dora_api", searchDora) -- 2197
	main:on("glob_files", list) -- 2198
	main:on("delete_file", del) -- 2199
	main:on("build", build) -- 2200
	main:on("edit_file", edit) -- 2201
	main:on("done", done) -- 2202
	read:on("main", main) -- 2204
	search:on("main", main) -- 2205
	searchDora:on("main", main) -- 2206
	list:on("main", main) -- 2207
	del:on("main", main) -- 2208
	build:on("main", main) -- 2209
	edit:on("main", main) -- 2210
	Flow.prototype.____constructor(self, main) -- 2212
end -- 2184
local function runCodingAgentAsync(options) -- 2234
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2234
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 2234
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 2234
		end -- 2234
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 2238
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2239
		if not llmConfigRes.success then -- 2239
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2239
		end -- 2239
		local llmConfig = llmConfigRes.config -- 2245
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 2246
		if not taskRes.success then -- 2246
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 2246
		end -- 2246
		local compressor = __TS__New(MemoryCompressor, { -- 2253
			compressionThreshold = 0.8, -- 2254
			maxCompressionRounds = 3, -- 2255
			maxTokensPerCompression = 20000, -- 2256
			projectDir = options.workDir, -- 2257
			llmConfig = llmConfig, -- 2258
			promptPack = options.promptPack -- 2259
		}) -- 2259
		local persistedSession = compressor:getStorage():readSessionState() -- 2261
		local promptPack = compressor:getPromptPack() -- 2262
		local shared = { -- 2264
			sessionId = options.sessionId, -- 2265
			taskId = taskRes.taskId, -- 2266
			maxSteps = math.max( -- 2267
				1, -- 2267
				math.floor(options.maxSteps or 50) -- 2267
			), -- 2267
			llmMaxTry = math.max( -- 2268
				1, -- 2268
				math.floor(options.llmMaxTry or 3) -- 2268
			), -- 2268
			step = 0, -- 2269
			done = false, -- 2270
			stopToken = options.stopToken or ({stopped = false}), -- 2271
			response = "", -- 2272
			userQuery = normalizedPrompt, -- 2273
			workingDir = options.workDir, -- 2274
			useChineseResponse = options.useChineseResponse == true, -- 2275
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 2276
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 2279
			llmConfig = llmConfig, -- 2284
			onEvent = options.onEvent, -- 2285
			promptPack = promptPack, -- 2286
			history = {}, -- 2287
			messages = persistedSession.messages, -- 2288
			memory = {compressor = compressor}, -- 2290
			skills = {loader = createSkillsLoader({projectDir = options.workDir})} -- 2294
		} -- 2294
		local ____try = __TS__AsyncAwaiter(function() -- 2294
			emitAgentEvent(shared, { -- 2302
				type = "task_started", -- 2303
				sessionId = shared.sessionId, -- 2304
				taskId = shared.taskId, -- 2305
				prompt = shared.userQuery, -- 2306
				workDir = shared.workingDir, -- 2307
				maxSteps = shared.maxSteps -- 2308
			}) -- 2308
			if shared.stopToken.stopped then -- 2308
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2311
				return ____awaiter_resolve( -- 2311
					nil, -- 2311
					emitAgentTaskFinishEvent( -- 2312
						shared, -- 2312
						false, -- 2312
						getCancelledReason(shared) -- 2312
					) -- 2312
				) -- 2312
			end -- 2312
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 2314
			local promptCommand = getPromptCommand(shared.userQuery) -- 2315
			if promptCommand == "reset" then -- 2315
				return ____awaiter_resolve( -- 2315
					nil, -- 2315
					resetSessionHistory(shared) -- 2317
				) -- 2317
			end -- 2317
			if promptCommand == "compact" then -- 2317
				return ____awaiter_resolve( -- 2317
					nil, -- 2317
					__TS__Await(compactAllHistory(shared)) -- 2320
				) -- 2320
			end -- 2320
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 2322
			persistHistoryState(shared) -- 2326
			local flow = __TS__New(CodingAgentFlow) -- 2327
			__TS__Await(flow:run(shared)) -- 2328
			if shared.stopToken.stopped then -- 2328
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2330
				return ____awaiter_resolve( -- 2330
					nil, -- 2330
					emitAgentTaskFinishEvent( -- 2331
						shared, -- 2331
						false, -- 2331
						getCancelledReason(shared) -- 2331
					) -- 2331
				) -- 2331
			end -- 2331
			if shared.error then -- 2331
				return ____awaiter_resolve( -- 2331
					nil, -- 2331
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 2334
				) -- 2334
			end -- 2334
			Tools.setTaskStatus(shared.taskId, "DONE") -- 2337
			return ____awaiter_resolve( -- 2337
				nil, -- 2337
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 2338
			) -- 2338
		end) -- 2338
		__TS__Await(____try.catch( -- 2301
			____try, -- 2301
			function(____, e) -- 2301
				return ____awaiter_resolve( -- 2301
					nil, -- 2301
					finalizeAgentFailure( -- 2341
						shared, -- 2341
						tostring(e) -- 2341
					) -- 2341
				) -- 2341
			end -- 2341
		)) -- 2341
	end) -- 2341
end -- 2234
function ____exports.runCodingAgent(options, callback) -- 2345
	local ____self_70 = runCodingAgentAsync(options) -- 2345
	____self_70["then"]( -- 2345
		____self_70, -- 2345
		function(____, result) return callback(result) end -- 2346
	) -- 2346
end -- 2345
return ____exports -- 2345