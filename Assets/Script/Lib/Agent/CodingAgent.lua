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
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1194
	if includeToolDefinitions == nil then -- 1194
		includeToolDefinitions = false -- 1194
	end -- 1194
	local sections = { -- 1195
		shared.promptPack.agentIdentityPrompt, -- 1196
		getReplyLanguageDirective(shared) -- 1197
	} -- 1197
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1199
	if memoryContext ~= "" then -- 1199
		sections[#sections + 1] = memoryContext -- 1201
	end -- 1201
	if includeToolDefinitions then -- 1201
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1204
		if shared.decisionMode == "xml" then -- 1204
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1206
		end -- 1206
	end -- 1206
	local skillsSection = buildSkillsSection(shared) -- 1210
	if skillsSection ~= "" then -- 1210
		sections[#sections + 1] = skillsSection -- 1212
	end -- 1212
	return table.concat(sections, "\n\n") -- 1214
end -- 1214
function buildSkillsSection(shared) -- 1217
	local ____opt_28 = shared.skills -- 1217
	if not (____opt_28 and ____opt_28.loader) then -- 1217
		return "" -- 1219
	end -- 1219
	return shared.skills.loader:buildSkillsPromptSection() -- 1221
end -- 1221
function buildXmlDecisionInstruction(shared, feedback) -- 1308
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 1309
end -- 1309
function emitAgentTaskFinishEvent(shared, success, message) -- 2232
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 2233
	emitAgentEvent(shared, { -- 2239
		type = "task_finished", -- 2240
		sessionId = shared.sessionId, -- 2241
		taskId = shared.taskId, -- 2242
		success = result.success, -- 2243
		message = result.message, -- 2244
		steps = result.steps -- 2245
	}) -- 2245
	return result -- 2247
end -- 2247
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
local function parseReadLineParam(value, fallback, paramName) -- 1001
	local num = __TS__Number(value) -- 1006
	if not __TS__NumberIsFinite(num) then -- 1006
		num = fallback -- 1007
	end -- 1007
	num = math.floor(num) -- 1008
	if num == 0 then -- 1008
		return {success = false, message = paramName .. " cannot be 0"} -- 1010
	end -- 1010
	return {success = true, value = num} -- 1012
end -- 1001
local function validateDecision(tool, params) -- 1015
	if tool == "finish" then -- 1015
		local message = getFinishMessage(params) -- 1020
		if message == "" then -- 1020
			return {success = false, message = "finish requires params.message"} -- 1021
		end -- 1021
		params.message = message -- 1022
		return {success = true, params = params} -- 1023
	end -- 1023
	if tool == "read_file" then -- 1023
		local path = getDecisionPath(params) -- 1027
		if path == "" then -- 1027
			return {success = false, message = "read_file requires path"} -- 1028
		end -- 1028
		params.path = path -- 1029
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1030
		if not startLineRes.success then -- 1030
			return startLineRes -- 1031
		end -- 1031
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1032
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1033
		if not endLineRes.success then -- 1033
			return endLineRes -- 1034
		end -- 1034
		params.startLine = startLineRes.value -- 1035
		params.endLine = endLineRes.value -- 1036
		return {success = true, params = params} -- 1037
	end -- 1037
	if tool == "edit_file" then -- 1037
		local path = getDecisionPath(params) -- 1041
		if path == "" then -- 1041
			return {success = false, message = "edit_file requires path"} -- 1042
		end -- 1042
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1043
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1044
		params.path = path -- 1045
		params.old_str = oldStr -- 1046
		params.new_str = newStr -- 1047
		return {success = true, params = params} -- 1048
	end -- 1048
	if tool == "delete_file" then -- 1048
		local targetFile = getDecisionPath(params) -- 1052
		if targetFile == "" then -- 1052
			return {success = false, message = "delete_file requires target_file"} -- 1053
		end -- 1053
		params.target_file = targetFile -- 1054
		return {success = true, params = params} -- 1055
	end -- 1055
	if tool == "grep_files" then -- 1055
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1059
		if pattern == "" then -- 1059
			return {success = false, message = "grep_files requires pattern"} -- 1060
		end -- 1060
		params.pattern = pattern -- 1061
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1062
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1063
		return {success = true, params = params} -- 1064
	end -- 1064
	if tool == "search_dora_api" then -- 1064
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1068
		if pattern == "" then -- 1068
			return {success = false, message = "search_dora_api requires pattern"} -- 1069
		end -- 1069
		params.pattern = pattern -- 1070
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1071
		return {success = true, params = params} -- 1072
	end -- 1072
	if tool == "glob_files" then -- 1072
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1076
		return {success = true, params = params} -- 1077
	end -- 1077
	if tool == "build" then -- 1077
		local path = getDecisionPath(params) -- 1081
		if path ~= "" then -- 1081
			params.path = path -- 1083
		end -- 1083
		return {success = true, params = params} -- 1085
	end -- 1085
	return {success = true, params = params} -- 1088
end -- 1015
local function createFunctionToolSchema(name, description, properties, required) -- 1091
	if required == nil then -- 1091
		required = {} -- 1095
	end -- 1095
	local parameters = {type = "object", properties = properties} -- 1097
	if #required > 0 then -- 1097
		parameters.required = required -- 1102
	end -- 1102
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1104
end -- 1091
local function buildDecisionToolSchema() -- 1114
	return { -- 1115
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1116
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 1126
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1136
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1144
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1148
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1149
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1150
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1151
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1152
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1153
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1154
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1155
		}, {"pattern"}), -- 1155
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1159
		createFunctionToolSchema( -- 1168
			"search_dora_api", -- 1169
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1169
			{ -- 1171
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1172
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1173
				programmingLanguage = {type = "string", enum = { -- 1174
					"ts", -- 1176
					"tsx", -- 1176
					"lua", -- 1176
					"yue", -- 1176
					"teal", -- 1176
					"tl", -- 1176
					"wa" -- 1176
				}, description = "Preferred language variant to search."}, -- 1176
				limit = { -- 1179
					type = "number", -- 1179
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1179
				}, -- 1179
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1180
			}, -- 1180
			{"pattern"} -- 1182
		), -- 1182
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}) -- 1184
	} -- 1184
end -- 1114
local function sanitizeMessagesForLLMInput(messages) -- 1224
	local sanitized = {} -- 1225
	local droppedAssistantToolCalls = 0 -- 1226
	local droppedToolResults = 0 -- 1227
	do -- 1227
		local i = 0 -- 1228
		while i < #messages do -- 1228
			do -- 1228
				local message = messages[i + 1] -- 1229
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1229
					local requiredIds = {} -- 1231
					do -- 1231
						local j = 0 -- 1232
						while j < #message.tool_calls do -- 1232
							local toolCall = message.tool_calls[j + 1] -- 1233
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1234
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1234
								requiredIds[#requiredIds + 1] = id -- 1236
							end -- 1236
							j = j + 1 -- 1232
						end -- 1232
					end -- 1232
					if #requiredIds == 0 then -- 1232
						sanitized[#sanitized + 1] = message -- 1240
						goto __continue190 -- 1241
					end -- 1241
					local matchedIds = {} -- 1243
					local matchedTools = {} -- 1244
					local j = i + 1 -- 1245
					while j < #messages do -- 1245
						local toolMessage = messages[j + 1] -- 1247
						if toolMessage.role ~= "tool" then -- 1247
							break -- 1248
						end -- 1248
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1249
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1249
							matchedIds[toolCallId] = true -- 1251
							matchedTools[#matchedTools + 1] = toolMessage -- 1252
						else -- 1252
							droppedToolResults = droppedToolResults + 1 -- 1254
						end -- 1254
						j = j + 1 -- 1256
					end -- 1256
					local complete = true -- 1258
					do -- 1258
						local j = 0 -- 1259
						while j < #requiredIds do -- 1259
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1259
								complete = false -- 1261
								break -- 1262
							end -- 1262
							j = j + 1 -- 1259
						end -- 1259
					end -- 1259
					if complete then -- 1259
						__TS__ArrayPush( -- 1266
							sanitized, -- 1266
							message, -- 1266
							table.unpack(matchedTools) -- 1266
						) -- 1266
					else -- 1266
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1268
						droppedToolResults = droppedToolResults + #matchedTools -- 1269
					end -- 1269
					i = j - 1 -- 1271
					goto __continue190 -- 1272
				end -- 1272
				if message.role == "tool" then -- 1272
					droppedToolResults = droppedToolResults + 1 -- 1275
					goto __continue190 -- 1276
				end -- 1276
				sanitized[#sanitized + 1] = message -- 1278
			end -- 1278
			::__continue190:: -- 1278
			i = i + 1 -- 1228
		end -- 1228
	end -- 1228
	return sanitized -- 1280
end -- 1224
local function getUnconsolidatedMessages(shared) -- 1283
	return sanitizeMessagesForLLMInput(shared.messages) -- 1284
end -- 1283
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1287
	if attempt == nil then -- 1287
		attempt = 1 -- 1287
	end -- 1287
	local messages = { -- 1288
		{ -- 1289
			role = "system", -- 1289
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1289
		}, -- 1289
		table.unpack(getUnconsolidatedMessages(shared)) -- 1290
	} -- 1290
	if lastError and lastError ~= "" then -- 1290
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1293
		messages[#messages + 1] = { -- 1296
			role = "user", -- 1297
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1298
		} -- 1298
	end -- 1298
	return messages -- 1305
end -- 1287
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 1312
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 1319
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 1320
	local repairPrompt = replacePromptVars( -- 1328
		shared.promptPack.xmlDecisionRepairPrompt, -- 1328
		{ -- 1328
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 1329
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 1330
			CANDIDATE_SECTION = candidateSection, -- 1331
			LAST_ERROR = lastError, -- 1332
			ATTEMPT = tostring(attempt) -- 1333
		} -- 1333
	) -- 1333
	return {{role = "system", content = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only."}, {role = "user", content = repairPrompt}} -- 1335
end -- 1312
local function tryParseAndValidateDecision(rawText) -- 1357
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 1358
	if not parsed.success then -- 1358
		return {success = false, message = parsed.message, raw = rawText} -- 1360
	end -- 1360
	local decision = parseDecisionObject(parsed.obj) -- 1362
	if not decision.success then -- 1362
		return {success = false, message = decision.message, raw = rawText} -- 1364
	end -- 1364
	local validation = validateDecision(decision.tool, decision.params) -- 1366
	if not validation.success then -- 1366
		return {success = false, message = validation.message, raw = rawText} -- 1368
	end -- 1368
	decision.params = validation.params -- 1370
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 1371
	return decision -- 1372
end -- 1357
local function normalizeLineEndings(text) -- 1375
	local res = string.gsub(text, "\r\n", "\n") -- 1376
	res = string.gsub(res, "\r", "\n") -- 1377
	return res -- 1378
end -- 1375
local function countOccurrences(text, searchStr) -- 1381
	if searchStr == "" then -- 1381
		return 0 -- 1382
	end -- 1382
	local count = 0 -- 1383
	local pos = 0 -- 1384
	while true do -- 1384
		local idx = (string.find( -- 1386
			text, -- 1386
			searchStr, -- 1386
			math.max(pos + 1, 1), -- 1386
			true -- 1386
		) or 0) - 1 -- 1386
		if idx < 0 then -- 1386
			break -- 1387
		end -- 1387
		count = count + 1 -- 1388
		pos = idx + #searchStr -- 1389
	end -- 1389
	return count -- 1391
end -- 1381
local function replaceFirst(text, oldStr, newStr) -- 1394
	if oldStr == "" then -- 1394
		return text -- 1395
	end -- 1395
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 1396
	if idx < 0 then -- 1396
		return text -- 1397
	end -- 1397
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 1398
end -- 1394
local function splitLines(text) -- 1401
	return __TS__StringSplit(text, "\n") -- 1402
end -- 1401
local function getLeadingWhitespace(text) -- 1405
	local i = 0 -- 1406
	while i < #text do -- 1406
		local ch = __TS__StringAccess(text, i) -- 1408
		if ch ~= " " and ch ~= "\t" then -- 1408
			break -- 1409
		end -- 1409
		i = i + 1 -- 1410
	end -- 1410
	return __TS__StringSubstring(text, 0, i) -- 1412
end -- 1405
local function getCommonIndentPrefix(lines) -- 1415
	local common -- 1416
	do -- 1416
		local i = 0 -- 1417
		while i < #lines do -- 1417
			do -- 1417
				local line = lines[i + 1] -- 1418
				if __TS__StringTrim(line) == "" then -- 1418
					goto __continue229 -- 1419
				end -- 1419
				local indent = getLeadingWhitespace(line) -- 1420
				if common == nil then -- 1420
					common = indent -- 1422
					goto __continue229 -- 1423
				end -- 1423
				local j = 0 -- 1425
				local maxLen = math.min(#common, #indent) -- 1426
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 1426
					j = j + 1 -- 1428
				end -- 1428
				common = __TS__StringSubstring(common, 0, j) -- 1430
				if common == "" then -- 1430
					break -- 1431
				end -- 1431
			end -- 1431
			::__continue229:: -- 1431
			i = i + 1 -- 1417
		end -- 1417
	end -- 1417
	return common or "" -- 1433
end -- 1415
local function removeIndentPrefix(line, indent) -- 1436
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 1436
		return __TS__StringSubstring(line, #indent) -- 1438
	end -- 1438
	local lineIndent = getLeadingWhitespace(line) -- 1440
	local j = 0 -- 1441
	local maxLen = math.min(#lineIndent, #indent) -- 1442
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 1442
		j = j + 1 -- 1444
	end -- 1444
	return __TS__StringSubstring(line, j) -- 1446
end -- 1436
local function dedentLines(lines) -- 1449
	local indent = getCommonIndentPrefix(lines) -- 1450
	return { -- 1451
		indent = indent, -- 1452
		lines = __TS__ArrayMap( -- 1453
			lines, -- 1453
			function(____, line) return removeIndentPrefix(line, indent) end -- 1453
		) -- 1453
	} -- 1453
end -- 1449
local function joinLines(lines) -- 1457
	return table.concat(lines, "\n") -- 1458
end -- 1457
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 1461
	local contentLines = splitLines(content) -- 1466
	local oldLines = splitLines(oldStr) -- 1467
	if #oldLines == 0 then -- 1467
		return {success = false, message = "old_str not found in file"} -- 1469
	end -- 1469
	local dedentedOld = dedentLines(oldLines) -- 1471
	local dedentedOldText = joinLines(dedentedOld.lines) -- 1472
	local dedentedNew = dedentLines(splitLines(newStr)) -- 1473
	local matches = {} -- 1474
	do -- 1474
		local start = 0 -- 1475
		while start <= #contentLines - #oldLines do -- 1475
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 1476
			local dedentedCandidate = dedentLines(candidateLines) -- 1477
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 1477
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 1479
			end -- 1479
			start = start + 1 -- 1475
		end -- 1475
	end -- 1475
	if #matches == 0 then -- 1475
		return {success = false, message = "old_str not found in file"} -- 1487
	end -- 1487
	if #matches > 1 then -- 1487
		return { -- 1490
			success = false, -- 1491
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 1492
		} -- 1492
	end -- 1492
	local match = matches[1] -- 1495
	local rebuiltNewLines = __TS__ArrayMap( -- 1496
		dedentedNew.lines, -- 1496
		function(____, line) return line == "" and "" or match.indent .. line end -- 1496
	) -- 1496
	local ____array_32 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 1496
	__TS__SparseArrayPush( -- 1496
		____array_32, -- 1496
		table.unpack(rebuiltNewLines) -- 1499
	) -- 1499
	__TS__SparseArrayPush( -- 1499
		____array_32, -- 1499
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 1500
	) -- 1500
	local nextLines = {__TS__SparseArraySpread(____array_32)} -- 1497
	return { -- 1502
		success = true, -- 1502
		content = joinLines(nextLines) -- 1502
	} -- 1502
end -- 1461
local MainDecisionAgent = __TS__Class() -- 1505
MainDecisionAgent.name = "MainDecisionAgent" -- 1505
__TS__ClassExtends(MainDecisionAgent, Node) -- 1505
function MainDecisionAgent.prototype.prep(self, shared) -- 1506
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1506
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1506
			return ____awaiter_resolve(nil, {shared = shared}) -- 1506
		end -- 1506
		__TS__Await(maybeCompressHistory(shared)) -- 1511
		return ____awaiter_resolve(nil, {shared = shared}) -- 1511
	end) -- 1511
end -- 1506
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 1516
	if attempt == nil then -- 1516
		attempt = 1 -- 1519
	end -- 1519
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1519
		if shared.stopToken.stopped then -- 1519
			return ____awaiter_resolve( -- 1519
				nil, -- 1519
				{ -- 1523
					success = false, -- 1523
					message = getCancelledReason(shared) -- 1523
				} -- 1523
			) -- 1523
		end -- 1523
		Log( -- 1525
			"Info", -- 1525
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1525
		) -- 1525
		local tools = buildDecisionToolSchema() -- 1526
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1527
		local stepId = shared.step + 1 -- 1528
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1529
		saveStepLLMDebugInput( -- 1533
			shared, -- 1533
			stepId, -- 1533
			"decision_tool_calling", -- 1533
			messages, -- 1533
			llmOptions -- 1533
		) -- 1533
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1534
		if shared.stopToken.stopped then -- 1534
			return ____awaiter_resolve( -- 1534
				nil, -- 1534
				{ -- 1536
					success = false, -- 1536
					message = getCancelledReason(shared) -- 1536
				} -- 1536
			) -- 1536
		end -- 1536
		if not res.success then -- 1536
			saveStepLLMDebugOutput( -- 1539
				shared, -- 1539
				stepId, -- 1539
				"decision_tool_calling", -- 1539
				res.raw or res.message, -- 1539
				{success = false} -- 1539
			) -- 1539
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1540
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1540
		end -- 1540
		saveStepLLMDebugOutput( -- 1543
			shared, -- 1543
			stepId, -- 1543
			"decision_tool_calling", -- 1543
			encodeDebugJSON(res.response), -- 1543
			{success = true} -- 1543
		) -- 1543
		local choice = res.response.choices and res.response.choices[1] -- 1544
		local message = choice and choice.message -- 1545
		local toolCalls = message and message.tool_calls -- 1546
		local toolCall = toolCalls and toolCalls[1] -- 1547
		local fn = toolCall and toolCall["function"] -- 1548
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 1549
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1552
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1555
		Log( -- 1558
			"Info", -- 1558
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1558
		) -- 1558
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1558
			if messageContent and messageContent ~= "" then -- 1558
				Log( -- 1561
					"Info", -- 1561
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1561
				) -- 1561
				return ____awaiter_resolve(nil, { -- 1561
					success = true, -- 1563
					tool = "finish", -- 1564
					params = {}, -- 1565
					reason = messageContent, -- 1566
					reasoningContent = reasoningContent, -- 1567
					directSummary = messageContent -- 1568
				}) -- 1568
			end -- 1568
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1571
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1571
		end -- 1571
		local functionName = fn.name -- 1578
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1579
		Log( -- 1580
			"Info", -- 1580
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1580
		) -- 1580
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1581
			local rawObj, err = safeJsonDecode(argsText) -- 1582
			if err ~= nil or rawObj == nil then -- 1582
				return {__error = tostring(err)} -- 1584
			end -- 1584
			return rawObj -- 1586
		end)() -- 1581
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 1581
			local err = tostring(rawArgs.__error) -- 1589
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1590
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1590
		end -- 1590
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1597
		if not decision.success then -- 1597
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1599
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1599
		end -- 1599
		local validation = validateDecision(decision.tool, decision.params) -- 1606
		if not validation.success then -- 1606
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1608
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1608
		end -- 1608
		decision.params = validation.params -- 1615
		decision.toolCallId = ensureToolCallId(toolCallId) -- 1616
		decision.reason = messageContent -- 1617
		decision.reasoningContent = reasoningContent -- 1618
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1619
		return ____awaiter_resolve(nil, decision) -- 1619
	end) -- 1619
end -- 1516
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 1623
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1623
		Log( -- 1628
			"Info", -- 1628
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 1628
		) -- 1628
		local lastError = initialError -- 1629
		local candidateRaw = "" -- 1630
		do -- 1630
			local attempt = 0 -- 1631
			while attempt < shared.llmMaxTry do -- 1631
				do -- 1631
					Log( -- 1632
						"Info", -- 1632
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 1632
					) -- 1632
					local messages = buildXmlRepairMessages( -- 1633
						shared, -- 1634
						originalRaw, -- 1635
						candidateRaw, -- 1636
						lastError, -- 1637
						attempt + 1 -- 1638
					) -- 1638
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 1640
					if shared.stopToken.stopped then -- 1640
						return ____awaiter_resolve( -- 1640
							nil, -- 1640
							{ -- 1642
								success = false, -- 1642
								message = getCancelledReason(shared) -- 1642
							} -- 1642
						) -- 1642
					end -- 1642
					if not llmRes.success then -- 1642
						lastError = llmRes.message -- 1645
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 1646
						goto __continue263 -- 1647
					end -- 1647
					candidateRaw = llmRes.text -- 1649
					local decision = tryParseAndValidateDecision(candidateRaw) -- 1650
					if decision.success then -- 1650
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 1652
						return ____awaiter_resolve(nil, decision) -- 1652
					end -- 1652
					lastError = decision.message -- 1655
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 1656
				end -- 1656
				::__continue263:: -- 1656
				attempt = attempt + 1 -- 1631
			end -- 1631
		end -- 1631
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 1658
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 1658
	end) -- 1658
end -- 1623
function MainDecisionAgent.prototype.exec(self, input) -- 1666
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1666
		local shared = input.shared -- 1667
		if shared.stopToken.stopped then -- 1667
			return ____awaiter_resolve( -- 1667
				nil, -- 1667
				{ -- 1669
					success = false, -- 1669
					message = getCancelledReason(shared) -- 1669
				} -- 1669
			) -- 1669
		end -- 1669
		if shared.step >= shared.maxSteps then -- 1669
			Log( -- 1672
				"Warn", -- 1672
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1672
			) -- 1672
			return ____awaiter_resolve( -- 1672
				nil, -- 1672
				{ -- 1673
					success = false, -- 1673
					message = getMaxStepsReachedReason(shared) -- 1673
				} -- 1673
			) -- 1673
		end -- 1673
		if shared.decisionMode == "tool_calling" then -- 1673
			Log( -- 1677
				"Info", -- 1677
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 1677
			) -- 1677
			local lastError = "tool calling validation failed" -- 1678
			local lastRaw = "" -- 1679
			do -- 1679
				local attempt = 0 -- 1680
				while attempt < shared.llmMaxTry do -- 1680
					Log( -- 1681
						"Info", -- 1681
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1681
					) -- 1681
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 1682
					if shared.stopToken.stopped then -- 1682
						return ____awaiter_resolve( -- 1682
							nil, -- 1682
							{ -- 1689
								success = false, -- 1689
								message = getCancelledReason(shared) -- 1689
							} -- 1689
						) -- 1689
					end -- 1689
					if decision.success then -- 1689
						return ____awaiter_resolve(nil, decision) -- 1689
					end -- 1689
					lastError = decision.message -- 1694
					lastRaw = decision.raw or "" -- 1695
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1696
					attempt = attempt + 1 -- 1680
				end -- 1680
			end -- 1680
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1698
			return ____awaiter_resolve( -- 1698
				nil, -- 1698
				{ -- 1699
					success = false, -- 1699
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1699
				} -- 1699
			) -- 1699
		end -- 1699
		local lastError = "xml validation failed" -- 1702
		local lastRaw = "" -- 1703
		do -- 1703
			local attempt = 0 -- 1704
			while attempt < shared.llmMaxTry do -- 1704
				do -- 1704
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 1705
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 1713
					if shared.stopToken.stopped then -- 1713
						return ____awaiter_resolve( -- 1713
							nil, -- 1713
							{ -- 1715
								success = false, -- 1715
								message = getCancelledReason(shared) -- 1715
							} -- 1715
						) -- 1715
					end -- 1715
					if not llmRes.success then -- 1715
						lastError = llmRes.message -- 1718
						lastRaw = llmRes.text or "" -- 1719
						goto __continue276 -- 1720
					end -- 1720
					lastRaw = llmRes.text -- 1722
					local decision = tryParseAndValidateDecision(llmRes.text) -- 1723
					if decision.success then -- 1723
						return ____awaiter_resolve(nil, decision) -- 1723
					end -- 1723
					lastError = decision.message -- 1727
					return ____awaiter_resolve( -- 1727
						nil, -- 1727
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 1728
					) -- 1728
				end -- 1728
				::__continue276:: -- 1728
				attempt = attempt + 1 -- 1704
			end -- 1704
		end -- 1704
		return ____awaiter_resolve( -- 1704
			nil, -- 1704
			{ -- 1730
				success = false, -- 1730
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1730
			} -- 1730
		) -- 1730
	end) -- 1730
end -- 1666
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1733
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1733
		local result = execRes -- 1734
		if not result.success then -- 1734
			shared.error = result.message -- 1736
			shared.response = getFailureSummaryFallback(shared, result.message) -- 1737
			shared.done = true -- 1738
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 1739
			persistHistoryState(shared) -- 1743
			return ____awaiter_resolve(nil, "done") -- 1743
		end -- 1743
		if result.directSummary and result.directSummary ~= "" then -- 1743
			shared.response = result.directSummary -- 1747
			shared.done = true -- 1748
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 1749
			persistHistoryState(shared) -- 1754
			return ____awaiter_resolve(nil, "done") -- 1754
		end -- 1754
		if result.tool == "finish" then -- 1754
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 1758
			shared.response = finalMessage -- 1759
			shared.done = true -- 1760
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 1761
			persistHistoryState(shared) -- 1766
			return ____awaiter_resolve(nil, "done") -- 1766
		end -- 1766
		local toolCallId = ensureToolCallId(result.toolCallId) -- 1769
		shared.step = shared.step + 1 -- 1770
		local step = shared.step -- 1771
		emitAgentEvent(shared, { -- 1772
			type = "decision_made", -- 1773
			sessionId = shared.sessionId, -- 1774
			taskId = shared.taskId, -- 1775
			step = step, -- 1776
			tool = result.tool, -- 1777
			reason = result.reason, -- 1778
			reasoningContent = result.reasoningContent, -- 1779
			params = result.params -- 1780
		}) -- 1780
		local ____shared_history_33 = shared.history -- 1780
		____shared_history_33[#____shared_history_33 + 1] = { -- 1782
			step = step, -- 1783
			toolCallId = toolCallId, -- 1784
			tool = result.tool, -- 1785
			reason = result.reason or "", -- 1786
			reasoningContent = result.reasoningContent, -- 1787
			params = result.params, -- 1788
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1789
		} -- 1789
		appendConversationMessage( -- 1791
			shared, -- 1791
			{ -- 1791
				role = "assistant", -- 1792
				content = result.reason or "", -- 1793
				reasoning_content = result.reasoningContent, -- 1794
				tool_calls = {{ -- 1795
					id = toolCallId, -- 1796
					type = "function", -- 1797
					["function"] = { -- 1798
						name = result.tool, -- 1799
						arguments = toJson(result.params) -- 1800
					} -- 1800
				}} -- 1800
			} -- 1800
		) -- 1800
		persistHistoryState(shared) -- 1804
		return ____awaiter_resolve(nil, result.tool) -- 1804
	end) -- 1804
end -- 1733
local ReadFileAction = __TS__Class() -- 1809
ReadFileAction.name = "ReadFileAction" -- 1809
__TS__ClassExtends(ReadFileAction, Node) -- 1809
function ReadFileAction.prototype.prep(self, shared) -- 1810
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1810
		local last = shared.history[#shared.history] -- 1811
		if not last then -- 1811
			error( -- 1812
				__TS__New(Error, "no history"), -- 1812
				0 -- 1812
			) -- 1812
		end -- 1812
		emitAgentStartEvent(shared, last) -- 1813
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1814
		if __TS__StringTrim(path) == "" then -- 1814
			error( -- 1817
				__TS__New(Error, "missing path"), -- 1817
				0 -- 1817
			) -- 1817
		end -- 1817
		local ____path_36 = path -- 1819
		local ____shared_workingDir_37 = shared.workingDir -- 1821
		local ____temp_38 = shared.useChineseResponse and "zh" or "en" -- 1822
		local ____last_params_startLine_34 = last.params.startLine -- 1823
		if ____last_params_startLine_34 == nil then -- 1823
			____last_params_startLine_34 = 1 -- 1823
		end -- 1823
		local ____TS__Number_result_39 = __TS__Number(____last_params_startLine_34) -- 1823
		local ____last_params_endLine_35 = last.params.endLine -- 1824
		if ____last_params_endLine_35 == nil then -- 1824
			____last_params_endLine_35 = READ_FILE_DEFAULT_LIMIT -- 1824
		end -- 1824
		return ____awaiter_resolve( -- 1824
			nil, -- 1824
			{ -- 1818
				path = ____path_36, -- 1819
				tool = "read_file", -- 1820
				workDir = ____shared_workingDir_37, -- 1821
				docLanguage = ____temp_38, -- 1822
				startLine = ____TS__Number_result_39, -- 1823
				endLine = __TS__Number(____last_params_endLine_35) -- 1824
			} -- 1824
		) -- 1824
	end) -- 1824
end -- 1810
function ReadFileAction.prototype.exec(self, input) -- 1828
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1828
		return ____awaiter_resolve( -- 1828
			nil, -- 1828
			Tools.readFile( -- 1829
				input.workDir, -- 1830
				input.path, -- 1831
				__TS__Number(input.startLine or 1), -- 1832
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1833
				input.docLanguage -- 1834
			) -- 1834
		) -- 1834
	end) -- 1834
end -- 1828
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1838
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1838
		local result = execRes -- 1839
		local last = shared.history[#shared.history] -- 1840
		if last ~= nil then -- 1840
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1842
			appendToolResultMessage(shared, last) -- 1843
			emitAgentFinishEvent(shared, last) -- 1844
		end -- 1844
		persistHistoryState(shared) -- 1846
		__TS__Await(maybeCompressHistory(shared)) -- 1847
		persistHistoryState(shared) -- 1848
		return ____awaiter_resolve(nil, "main") -- 1848
	end) -- 1848
end -- 1838
local SearchFilesAction = __TS__Class() -- 1853
SearchFilesAction.name = "SearchFilesAction" -- 1853
__TS__ClassExtends(SearchFilesAction, Node) -- 1853
function SearchFilesAction.prototype.prep(self, shared) -- 1854
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1854
		local last = shared.history[#shared.history] -- 1855
		if not last then -- 1855
			error( -- 1856
				__TS__New(Error, "no history"), -- 1856
				0 -- 1856
			) -- 1856
		end -- 1856
		emitAgentStartEvent(shared, last) -- 1857
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1857
	end) -- 1857
end -- 1854
function SearchFilesAction.prototype.exec(self, input) -- 1861
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1861
		local params = input.params -- 1862
		local ____Tools_searchFiles_53 = Tools.searchFiles -- 1863
		local ____input_workDir_46 = input.workDir -- 1864
		local ____temp_47 = params.path or "" -- 1865
		local ____temp_48 = params.pattern or "" -- 1866
		local ____params_globs_49 = params.globs -- 1867
		local ____params_useRegex_50 = params.useRegex -- 1868
		local ____params_caseSensitive_51 = params.caseSensitive -- 1869
		local ____math_max_42 = math.max -- 1872
		local ____math_floor_41 = math.floor -- 1872
		local ____params_limit_40 = params.limit -- 1872
		if ____params_limit_40 == nil then -- 1872
			____params_limit_40 = SEARCH_FILES_LIMIT_DEFAULT -- 1872
		end -- 1872
		local ____math_max_42_result_52 = ____math_max_42( -- 1872
			1, -- 1872
			____math_floor_41(__TS__Number(____params_limit_40)) -- 1872
		) -- 1872
		local ____math_max_45 = math.max -- 1873
		local ____math_floor_44 = math.floor -- 1873
		local ____params_offset_43 = params.offset -- 1873
		if ____params_offset_43 == nil then -- 1873
			____params_offset_43 = 0 -- 1873
		end -- 1873
		local result = __TS__Await(____Tools_searchFiles_53({ -- 1863
			workDir = ____input_workDir_46, -- 1864
			path = ____temp_47, -- 1865
			pattern = ____temp_48, -- 1866
			globs = ____params_globs_49, -- 1867
			useRegex = ____params_useRegex_50, -- 1868
			caseSensitive = ____params_caseSensitive_51, -- 1869
			includeContent = true, -- 1870
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1871
			limit = ____math_max_42_result_52, -- 1872
			offset = ____math_max_45( -- 1873
				0, -- 1873
				____math_floor_44(__TS__Number(____params_offset_43)) -- 1873
			), -- 1873
			groupByFile = params.groupByFile == true -- 1874
		})) -- 1874
		return ____awaiter_resolve(nil, result) -- 1874
	end) -- 1874
end -- 1861
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1879
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1879
		local last = shared.history[#shared.history] -- 1880
		if last ~= nil then -- 1880
			local result = execRes -- 1882
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1883
			appendToolResultMessage(shared, last) -- 1884
			emitAgentFinishEvent(shared, last) -- 1885
		end -- 1885
		persistHistoryState(shared) -- 1887
		__TS__Await(maybeCompressHistory(shared)) -- 1888
		persistHistoryState(shared) -- 1889
		return ____awaiter_resolve(nil, "main") -- 1889
	end) -- 1889
end -- 1879
local SearchDoraAPIAction = __TS__Class() -- 1894
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1894
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1894
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1895
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1895
		local last = shared.history[#shared.history] -- 1896
		if not last then -- 1896
			error( -- 1897
				__TS__New(Error, "no history"), -- 1897
				0 -- 1897
			) -- 1897
		end -- 1897
		emitAgentStartEvent(shared, last) -- 1898
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1898
	end) -- 1898
end -- 1895
function SearchDoraAPIAction.prototype.exec(self, input) -- 1902
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1902
		local params = input.params -- 1903
		local ____Tools_searchDoraAPI_61 = Tools.searchDoraAPI -- 1904
		local ____temp_57 = params.pattern or "" -- 1905
		local ____temp_58 = params.docSource or "api" -- 1906
		local ____temp_59 = input.useChineseResponse and "zh" or "en" -- 1907
		local ____temp_60 = params.programmingLanguage or "ts" -- 1908
		local ____math_min_56 = math.min -- 1909
		local ____math_max_55 = math.max -- 1909
		local ____params_limit_54 = params.limit -- 1909
		if ____params_limit_54 == nil then -- 1909
			____params_limit_54 = 8 -- 1909
		end -- 1909
		local result = __TS__Await(____Tools_searchDoraAPI_61({ -- 1904
			pattern = ____temp_57, -- 1905
			docSource = ____temp_58, -- 1906
			docLanguage = ____temp_59, -- 1907
			programmingLanguage = ____temp_60, -- 1908
			limit = ____math_min_56( -- 1909
				SEARCH_DORA_API_LIMIT_MAX, -- 1909
				____math_max_55( -- 1909
					1, -- 1909
					__TS__Number(____params_limit_54) -- 1909
				) -- 1909
			), -- 1909
			useRegex = params.useRegex, -- 1910
			caseSensitive = false, -- 1911
			includeContent = true, -- 1912
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1913
		})) -- 1913
		return ____awaiter_resolve(nil, result) -- 1913
	end) -- 1913
end -- 1902
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1918
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1918
		local last = shared.history[#shared.history] -- 1919
		if last ~= nil then -- 1919
			local result = execRes -- 1921
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1922
			appendToolResultMessage(shared, last) -- 1923
			emitAgentFinishEvent(shared, last) -- 1924
		end -- 1924
		persistHistoryState(shared) -- 1926
		__TS__Await(maybeCompressHistory(shared)) -- 1927
		persistHistoryState(shared) -- 1928
		return ____awaiter_resolve(nil, "main") -- 1928
	end) -- 1928
end -- 1918
local ListFilesAction = __TS__Class() -- 1933
ListFilesAction.name = "ListFilesAction" -- 1933
__TS__ClassExtends(ListFilesAction, Node) -- 1933
function ListFilesAction.prototype.prep(self, shared) -- 1934
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1934
		local last = shared.history[#shared.history] -- 1935
		if not last then -- 1935
			error( -- 1936
				__TS__New(Error, "no history"), -- 1936
				0 -- 1936
			) -- 1936
		end -- 1936
		emitAgentStartEvent(shared, last) -- 1937
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1937
	end) -- 1937
end -- 1934
function ListFilesAction.prototype.exec(self, input) -- 1941
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1941
		local params = input.params -- 1942
		local ____Tools_listFiles_68 = Tools.listFiles -- 1943
		local ____input_workDir_65 = input.workDir -- 1944
		local ____temp_66 = params.path or "" -- 1945
		local ____params_globs_67 = params.globs -- 1946
		local ____math_max_64 = math.max -- 1947
		local ____math_floor_63 = math.floor -- 1947
		local ____params_maxEntries_62 = params.maxEntries -- 1947
		if ____params_maxEntries_62 == nil then -- 1947
			____params_maxEntries_62 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1947
		end -- 1947
		local result = ____Tools_listFiles_68({ -- 1943
			workDir = ____input_workDir_65, -- 1944
			path = ____temp_66, -- 1945
			globs = ____params_globs_67, -- 1946
			maxEntries = ____math_max_64( -- 1947
				1, -- 1947
				____math_floor_63(__TS__Number(____params_maxEntries_62)) -- 1947
			) -- 1947
		}) -- 1947
		return ____awaiter_resolve(nil, result) -- 1947
	end) -- 1947
end -- 1941
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1952
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1952
		local last = shared.history[#shared.history] -- 1953
		if last ~= nil then -- 1953
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1955
			appendToolResultMessage(shared, last) -- 1956
			emitAgentFinishEvent(shared, last) -- 1957
		end -- 1957
		persistHistoryState(shared) -- 1959
		__TS__Await(maybeCompressHistory(shared)) -- 1960
		persistHistoryState(shared) -- 1961
		return ____awaiter_resolve(nil, "main") -- 1961
	end) -- 1961
end -- 1952
local DeleteFileAction = __TS__Class() -- 1966
DeleteFileAction.name = "DeleteFileAction" -- 1966
__TS__ClassExtends(DeleteFileAction, Node) -- 1966
function DeleteFileAction.prototype.prep(self, shared) -- 1967
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1967
		local last = shared.history[#shared.history] -- 1968
		if not last then -- 1968
			error( -- 1969
				__TS__New(Error, "no history"), -- 1969
				0 -- 1969
			) -- 1969
		end -- 1969
		emitAgentStartEvent(shared, last) -- 1970
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1971
		if __TS__StringTrim(targetFile) == "" then -- 1971
			error( -- 1974
				__TS__New(Error, "missing target_file"), -- 1974
				0 -- 1974
			) -- 1974
		end -- 1974
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1974
	end) -- 1974
end -- 1967
function DeleteFileAction.prototype.exec(self, input) -- 1978
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1978
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1979
		if not result.success then -- 1979
			return ____awaiter_resolve(nil, result) -- 1979
		end -- 1979
		return ____awaiter_resolve(nil, { -- 1979
			success = true, -- 1987
			changed = true, -- 1988
			mode = "delete", -- 1989
			checkpointId = result.checkpointId, -- 1990
			checkpointSeq = result.checkpointSeq, -- 1991
			files = {{path = input.targetFile, op = "delete"}} -- 1992
		}) -- 1992
	end) -- 1992
end -- 1978
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1996
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1996
		local last = shared.history[#shared.history] -- 1997
		if last ~= nil then -- 1997
			last.result = execRes -- 1999
			appendToolResultMessage(shared, last) -- 2000
			emitAgentFinishEvent(shared, last) -- 2001
			local result = last.result -- 2002
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2002
				emitAgentEvent(shared, { -- 2007
					type = "checkpoint_created", -- 2008
					sessionId = shared.sessionId, -- 2009
					taskId = shared.taskId, -- 2010
					step = last.step, -- 2011
					tool = "delete_file", -- 2012
					checkpointId = result.checkpointId, -- 2013
					checkpointSeq = result.checkpointSeq, -- 2014
					files = result.files -- 2015
				}) -- 2015
			end -- 2015
		end -- 2015
		persistHistoryState(shared) -- 2019
		__TS__Await(maybeCompressHistory(shared)) -- 2020
		persistHistoryState(shared) -- 2021
		return ____awaiter_resolve(nil, "main") -- 2021
	end) -- 2021
end -- 1996
local BuildAction = __TS__Class() -- 2026
BuildAction.name = "BuildAction" -- 2026
__TS__ClassExtends(BuildAction, Node) -- 2026
function BuildAction.prototype.prep(self, shared) -- 2027
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2027
		local last = shared.history[#shared.history] -- 2028
		if not last then -- 2028
			error( -- 2029
				__TS__New(Error, "no history"), -- 2029
				0 -- 2029
			) -- 2029
		end -- 2029
		emitAgentStartEvent(shared, last) -- 2030
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2030
	end) -- 2030
end -- 2027
function BuildAction.prototype.exec(self, input) -- 2034
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2034
		local params = input.params -- 2035
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2036
		return ____awaiter_resolve(nil, result) -- 2036
	end) -- 2036
end -- 2034
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2043
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2043
		local last = shared.history[#shared.history] -- 2044
		if last ~= nil then -- 2044
			last.result = execRes -- 2046
			appendToolResultMessage(shared, last) -- 2047
			emitAgentFinishEvent(shared, last) -- 2048
		end -- 2048
		persistHistoryState(shared) -- 2050
		__TS__Await(maybeCompressHistory(shared)) -- 2051
		persistHistoryState(shared) -- 2052
		return ____awaiter_resolve(nil, "main") -- 2052
	end) -- 2052
end -- 2043
local EditFileAction = __TS__Class() -- 2057
EditFileAction.name = "EditFileAction" -- 2057
__TS__ClassExtends(EditFileAction, Node) -- 2057
function EditFileAction.prototype.prep(self, shared) -- 2058
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2058
		local last = shared.history[#shared.history] -- 2059
		if not last then -- 2059
			error( -- 2060
				__TS__New(Error, "no history"), -- 2060
				0 -- 2060
			) -- 2060
		end -- 2060
		emitAgentStartEvent(shared, last) -- 2061
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2062
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2065
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2066
		if __TS__StringTrim(path) == "" then -- 2066
			error( -- 2067
				__TS__New(Error, "missing path"), -- 2067
				0 -- 2067
			) -- 2067
		end -- 2067
		return ____awaiter_resolve(nil, { -- 2067
			path = path, -- 2068
			oldStr = oldStr, -- 2068
			newStr = newStr, -- 2068
			taskId = shared.taskId, -- 2068
			workDir = shared.workingDir -- 2068
		}) -- 2068
	end) -- 2068
end -- 2058
function EditFileAction.prototype.exec(self, input) -- 2071
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2071
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 2072
		if not readRes.success then -- 2072
			if input.oldStr ~= "" then -- 2072
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 2072
			end -- 2072
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2077
			if not createRes.success then -- 2077
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 2077
			end -- 2077
			return ____awaiter_resolve(nil, { -- 2077
				success = true, -- 2085
				changed = true, -- 2086
				mode = "create", -- 2087
				checkpointId = createRes.checkpointId, -- 2088
				checkpointSeq = createRes.checkpointSeq, -- 2089
				files = {{path = input.path, op = "create"}} -- 2090
			}) -- 2090
		end -- 2090
		if input.oldStr == "" then -- 2090
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2094
			if not overwriteRes.success then -- 2094
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 2094
			end -- 2094
			return ____awaiter_resolve(nil, { -- 2094
				success = true, -- 2102
				changed = true, -- 2103
				mode = "overwrite", -- 2104
				checkpointId = overwriteRes.checkpointId, -- 2105
				checkpointSeq = overwriteRes.checkpointSeq, -- 2106
				files = {{path = input.path, op = "write"}} -- 2107
			}) -- 2107
		end -- 2107
		local normalizedContent = normalizeLineEndings(readRes.content) -- 2112
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 2113
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 2114
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 2117
		if occurrences == 0 then -- 2117
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2119
			if not indentTolerant.success then -- 2119
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 2119
			end -- 2119
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 2123
			if not applyRes.success then -- 2123
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2123
			end -- 2123
			return ____awaiter_resolve(nil, { -- 2123
				success = true, -- 2131
				changed = true, -- 2132
				mode = "replace_indent_tolerant", -- 2133
				checkpointId = applyRes.checkpointId, -- 2134
				checkpointSeq = applyRes.checkpointSeq, -- 2135
				files = {{path = input.path, op = "write"}} -- 2136
			}) -- 2136
		end -- 2136
		if occurrences > 1 then -- 2136
			return ____awaiter_resolve( -- 2136
				nil, -- 2136
				{ -- 2140
					success = false, -- 2140
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 2140
				} -- 2140
			) -- 2140
		end -- 2140
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2144
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2145
		if not applyRes.success then -- 2145
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2145
		end -- 2145
		return ____awaiter_resolve(nil, { -- 2145
			success = true, -- 2153
			changed = true, -- 2154
			mode = "replace", -- 2155
			checkpointId = applyRes.checkpointId, -- 2156
			checkpointSeq = applyRes.checkpointSeq, -- 2157
			files = {{path = input.path, op = "write"}} -- 2158
		}) -- 2158
	end) -- 2158
end -- 2071
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2162
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2162
		local last = shared.history[#shared.history] -- 2163
		if last ~= nil then -- 2163
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 2165
			last.result = execRes -- 2166
			appendToolResultMessage(shared, last) -- 2167
			emitAgentFinishEvent(shared, last) -- 2168
			local result = last.result -- 2169
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2169
				emitAgentEvent(shared, { -- 2174
					type = "checkpoint_created", -- 2175
					sessionId = shared.sessionId, -- 2176
					taskId = shared.taskId, -- 2177
					step = last.step, -- 2178
					tool = last.tool, -- 2179
					checkpointId = result.checkpointId, -- 2180
					checkpointSeq = result.checkpointSeq, -- 2181
					files = result.files -- 2182
				}) -- 2182
			end -- 2182
		end -- 2182
		persistHistoryState(shared) -- 2186
		__TS__Await(maybeCompressHistory(shared)) -- 2187
		persistHistoryState(shared) -- 2188
		return ____awaiter_resolve(nil, "main") -- 2188
	end) -- 2188
end -- 2162
local EndNode = __TS__Class() -- 2193
EndNode.name = "EndNode" -- 2193
__TS__ClassExtends(EndNode, Node) -- 2193
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 2194
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2194
		return ____awaiter_resolve(nil, nil) -- 2194
	end) -- 2194
end -- 2194
local CodingAgentFlow = __TS__Class() -- 2199
CodingAgentFlow.name = "CodingAgentFlow" -- 2199
__TS__ClassExtends(CodingAgentFlow, Flow) -- 2199
function CodingAgentFlow.prototype.____constructor(self) -- 2200
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 2201
	local read = __TS__New(ReadFileAction, 1, 0) -- 2202
	local search = __TS__New(SearchFilesAction, 1, 0) -- 2203
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 2204
	local list = __TS__New(ListFilesAction, 1, 0) -- 2205
	local del = __TS__New(DeleteFileAction, 1, 0) -- 2206
	local build = __TS__New(BuildAction, 1, 0) -- 2207
	local edit = __TS__New(EditFileAction, 1, 0) -- 2208
	local done = __TS__New(EndNode, 1, 0) -- 2209
	main:on("read_file", read) -- 2211
	main:on("grep_files", search) -- 2212
	main:on("search_dora_api", searchDora) -- 2213
	main:on("glob_files", list) -- 2214
	main:on("delete_file", del) -- 2215
	main:on("build", build) -- 2216
	main:on("edit_file", edit) -- 2217
	main:on("done", done) -- 2218
	read:on("main", main) -- 2220
	search:on("main", main) -- 2221
	searchDora:on("main", main) -- 2222
	list:on("main", main) -- 2223
	del:on("main", main) -- 2224
	build:on("main", main) -- 2225
	edit:on("main", main) -- 2226
	Flow.prototype.____constructor(self, main) -- 2228
end -- 2200
local function runCodingAgentAsync(options) -- 2250
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2250
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 2250
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 2250
		end -- 2250
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 2254
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2255
		if not llmConfigRes.success then -- 2255
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2255
		end -- 2255
		local llmConfig = llmConfigRes.config -- 2261
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 2262
		if not taskRes.success then -- 2262
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 2262
		end -- 2262
		local compressor = __TS__New(MemoryCompressor, { -- 2269
			compressionThreshold = 0.8, -- 2270
			maxCompressionRounds = 3, -- 2271
			maxTokensPerCompression = 20000, -- 2272
			projectDir = options.workDir, -- 2273
			llmConfig = llmConfig, -- 2274
			promptPack = options.promptPack -- 2275
		}) -- 2275
		local persistedSession = compressor:getStorage():readSessionState() -- 2277
		local promptPack = compressor:getPromptPack() -- 2278
		local shared = { -- 2280
			sessionId = options.sessionId, -- 2281
			taskId = taskRes.taskId, -- 2282
			maxSteps = math.max( -- 2283
				1, -- 2283
				math.floor(options.maxSteps or 50) -- 2283
			), -- 2283
			llmMaxTry = math.max( -- 2284
				1, -- 2284
				math.floor(options.llmMaxTry or 3) -- 2284
			), -- 2284
			step = 0, -- 2285
			done = false, -- 2286
			stopToken = options.stopToken or ({stopped = false}), -- 2287
			response = "", -- 2288
			userQuery = normalizedPrompt, -- 2289
			workingDir = options.workDir, -- 2290
			useChineseResponse = options.useChineseResponse == true, -- 2291
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 2292
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 2295
			llmConfig = llmConfig, -- 2300
			onEvent = options.onEvent, -- 2301
			promptPack = promptPack, -- 2302
			history = {}, -- 2303
			messages = persistedSession.messages, -- 2304
			memory = {compressor = compressor}, -- 2306
			skills = {loader = createSkillsLoader({projectDir = options.workDir})} -- 2310
		} -- 2310
		local ____try = __TS__AsyncAwaiter(function() -- 2310
			emitAgentEvent(shared, { -- 2318
				type = "task_started", -- 2319
				sessionId = shared.sessionId, -- 2320
				taskId = shared.taskId, -- 2321
				prompt = shared.userQuery, -- 2322
				workDir = shared.workingDir, -- 2323
				maxSteps = shared.maxSteps -- 2324
			}) -- 2324
			if shared.stopToken.stopped then -- 2324
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2327
				return ____awaiter_resolve( -- 2327
					nil, -- 2327
					emitAgentTaskFinishEvent( -- 2328
						shared, -- 2328
						false, -- 2328
						getCancelledReason(shared) -- 2328
					) -- 2328
				) -- 2328
			end -- 2328
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 2330
			local promptCommand = getPromptCommand(shared.userQuery) -- 2331
			if promptCommand == "reset" then -- 2331
				return ____awaiter_resolve( -- 2331
					nil, -- 2331
					resetSessionHistory(shared) -- 2333
				) -- 2333
			end -- 2333
			if promptCommand == "compact" then -- 2333
				return ____awaiter_resolve( -- 2333
					nil, -- 2333
					__TS__Await(compactAllHistory(shared)) -- 2336
				) -- 2336
			end -- 2336
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 2338
			persistHistoryState(shared) -- 2342
			local flow = __TS__New(CodingAgentFlow) -- 2343
			__TS__Await(flow:run(shared)) -- 2344
			if shared.stopToken.stopped then -- 2344
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2346
				return ____awaiter_resolve( -- 2346
					nil, -- 2346
					emitAgentTaskFinishEvent( -- 2347
						shared, -- 2347
						false, -- 2347
						getCancelledReason(shared) -- 2347
					) -- 2347
				) -- 2347
			end -- 2347
			if shared.error then -- 2347
				return ____awaiter_resolve( -- 2347
					nil, -- 2347
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 2350
				) -- 2350
			end -- 2350
			Tools.setTaskStatus(shared.taskId, "DONE") -- 2353
			return ____awaiter_resolve( -- 2353
				nil, -- 2353
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 2354
			) -- 2354
		end) -- 2354
		__TS__Await(____try.catch( -- 2317
			____try, -- 2317
			function(____, e) -- 2317
				return ____awaiter_resolve( -- 2317
					nil, -- 2317
					finalizeAgentFailure( -- 2357
						shared, -- 2357
						tostring(e) -- 2357
					) -- 2357
				) -- 2357
			end -- 2357
		)) -- 2357
	end) -- 2357
end -- 2250
function ____exports.runCodingAgent(options, callback) -- 2361
	local ____self_69 = runCodingAgentAsync(options) -- 2361
	____self_69["then"]( -- 2361
		____self_69, -- 2361
		function(____, result) return callback(result) end -- 2362
	) -- 2362
end -- 2361
return ____exports -- 2361