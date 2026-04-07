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
function emitAgentTaskFinishEvent(shared, success, message) -- 2227
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 2228
	emitAgentEvent(shared, { -- 2234
		type = "task_finished", -- 2235
		sessionId = shared.sessionId, -- 2236
		taskId = shared.taskId, -- 2237
		success = result.success, -- 2238
		message = result.message, -- 2239
		steps = result.steps -- 2240
	}) -- 2240
	return result -- 2242
end -- 2242
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
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 1335
end -- 1312
local function tryParseAndValidateDecision(rawText) -- 1347
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 1348
	if not parsed.success then -- 1348
		return {success = false, message = parsed.message, raw = rawText} -- 1350
	end -- 1350
	local decision = parseDecisionObject(parsed.obj) -- 1352
	if not decision.success then -- 1352
		return {success = false, message = decision.message, raw = rawText} -- 1354
	end -- 1354
	local validation = validateDecision(decision.tool, decision.params) -- 1356
	if not validation.success then -- 1356
		return {success = false, message = validation.message, raw = rawText} -- 1358
	end -- 1358
	decision.params = validation.params -- 1360
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 1361
	return decision -- 1362
end -- 1347
local function normalizeLineEndings(text) -- 1365
	local res = string.gsub(text, "\r\n", "\n") -- 1366
	res = string.gsub(res, "\r", "\n") -- 1367
	return res -- 1368
end -- 1365
local function countOccurrences(text, searchStr) -- 1371
	if searchStr == "" then -- 1371
		return 0 -- 1372
	end -- 1372
	local count = 0 -- 1373
	local pos = 0 -- 1374
	while true do -- 1374
		local idx = (string.find( -- 1376
			text, -- 1376
			searchStr, -- 1376
			math.max(pos + 1, 1), -- 1376
			true -- 1376
		) or 0) - 1 -- 1376
		if idx < 0 then -- 1376
			break -- 1377
		end -- 1377
		count = count + 1 -- 1378
		pos = idx + #searchStr -- 1379
	end -- 1379
	return count -- 1381
end -- 1371
local function replaceFirst(text, oldStr, newStr) -- 1384
	if oldStr == "" then -- 1384
		return text -- 1385
	end -- 1385
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 1386
	if idx < 0 then -- 1386
		return text -- 1387
	end -- 1387
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 1388
end -- 1384
local function splitLines(text) -- 1391
	return __TS__StringSplit(text, "\n") -- 1392
end -- 1391
local function getLeadingWhitespace(text) -- 1395
	local i = 0 -- 1396
	while i < #text do -- 1396
		local ch = __TS__StringAccess(text, i) -- 1398
		if ch ~= " " and ch ~= "\t" then -- 1398
			break -- 1399
		end -- 1399
		i = i + 1 -- 1400
	end -- 1400
	return __TS__StringSubstring(text, 0, i) -- 1402
end -- 1395
local function getCommonIndentPrefix(lines) -- 1405
	local common -- 1406
	do -- 1406
		local i = 0 -- 1407
		while i < #lines do -- 1407
			do -- 1407
				local line = lines[i + 1] -- 1408
				if __TS__StringTrim(line) == "" then -- 1408
					goto __continue229 -- 1409
				end -- 1409
				local indent = getLeadingWhitespace(line) -- 1410
				if common == nil then -- 1410
					common = indent -- 1412
					goto __continue229 -- 1413
				end -- 1413
				local j = 0 -- 1415
				local maxLen = math.min(#common, #indent) -- 1416
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 1416
					j = j + 1 -- 1418
				end -- 1418
				common = __TS__StringSubstring(common, 0, j) -- 1420
				if common == "" then -- 1420
					break -- 1421
				end -- 1421
			end -- 1421
			::__continue229:: -- 1421
			i = i + 1 -- 1407
		end -- 1407
	end -- 1407
	return common or "" -- 1423
end -- 1405
local function removeIndentPrefix(line, indent) -- 1426
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 1426
		return __TS__StringSubstring(line, #indent) -- 1428
	end -- 1428
	local lineIndent = getLeadingWhitespace(line) -- 1430
	local j = 0 -- 1431
	local maxLen = math.min(#lineIndent, #indent) -- 1432
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 1432
		j = j + 1 -- 1434
	end -- 1434
	return __TS__StringSubstring(line, j) -- 1436
end -- 1426
local function dedentLines(lines) -- 1439
	local indent = getCommonIndentPrefix(lines) -- 1440
	return { -- 1441
		indent = indent, -- 1442
		lines = __TS__ArrayMap( -- 1443
			lines, -- 1443
			function(____, line) return removeIndentPrefix(line, indent) end -- 1443
		) -- 1443
	} -- 1443
end -- 1439
local function joinLines(lines) -- 1447
	return table.concat(lines, "\n") -- 1448
end -- 1447
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 1451
	local contentLines = splitLines(content) -- 1456
	local oldLines = splitLines(oldStr) -- 1457
	if #oldLines == 0 then -- 1457
		return {success = false, message = "old_str not found in file"} -- 1459
	end -- 1459
	local dedentedOld = dedentLines(oldLines) -- 1461
	local dedentedOldText = joinLines(dedentedOld.lines) -- 1462
	local dedentedNew = dedentLines(splitLines(newStr)) -- 1463
	local matches = {} -- 1464
	do -- 1464
		local start = 0 -- 1465
		while start <= #contentLines - #oldLines do -- 1465
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 1466
			local dedentedCandidate = dedentLines(candidateLines) -- 1467
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 1467
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 1469
			end -- 1469
			start = start + 1 -- 1465
		end -- 1465
	end -- 1465
	if #matches == 0 then -- 1465
		return {success = false, message = "old_str not found in file"} -- 1477
	end -- 1477
	if #matches > 1 then -- 1477
		return { -- 1480
			success = false, -- 1481
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 1482
		} -- 1482
	end -- 1482
	local match = matches[1] -- 1485
	local rebuiltNewLines = __TS__ArrayMap( -- 1486
		dedentedNew.lines, -- 1486
		function(____, line) return line == "" and "" or match.indent .. line end -- 1486
	) -- 1486
	local ____array_32 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 1486
	__TS__SparseArrayPush( -- 1486
		____array_32, -- 1486
		table.unpack(rebuiltNewLines) -- 1489
	) -- 1489
	__TS__SparseArrayPush( -- 1489
		____array_32, -- 1489
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 1490
	) -- 1490
	local nextLines = {__TS__SparseArraySpread(____array_32)} -- 1487
	return { -- 1492
		success = true, -- 1492
		content = joinLines(nextLines) -- 1492
	} -- 1492
end -- 1451
local MainDecisionAgent = __TS__Class() -- 1495
MainDecisionAgent.name = "MainDecisionAgent" -- 1495
__TS__ClassExtends(MainDecisionAgent, Node) -- 1495
function MainDecisionAgent.prototype.prep(self, shared) -- 1496
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1496
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1496
			return ____awaiter_resolve(nil, {shared = shared}) -- 1496
		end -- 1496
		__TS__Await(maybeCompressHistory(shared)) -- 1501
		return ____awaiter_resolve(nil, {shared = shared}) -- 1501
	end) -- 1501
end -- 1496
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 1506
	if attempt == nil then -- 1506
		attempt = 1 -- 1509
	end -- 1509
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1509
		if shared.stopToken.stopped then -- 1509
			return ____awaiter_resolve( -- 1509
				nil, -- 1509
				{ -- 1513
					success = false, -- 1513
					message = getCancelledReason(shared) -- 1513
				} -- 1513
			) -- 1513
		end -- 1513
		Log( -- 1515
			"Info", -- 1515
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1515
		) -- 1515
		local tools = buildDecisionToolSchema() -- 1516
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1517
		local stepId = shared.step + 1 -- 1518
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1519
		saveStepLLMDebugInput( -- 1523
			shared, -- 1523
			stepId, -- 1523
			"decision_tool_calling", -- 1523
			messages, -- 1523
			llmOptions -- 1523
		) -- 1523
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1524
		if shared.stopToken.stopped then -- 1524
			return ____awaiter_resolve( -- 1524
				nil, -- 1524
				{ -- 1526
					success = false, -- 1526
					message = getCancelledReason(shared) -- 1526
				} -- 1526
			) -- 1526
		end -- 1526
		if not res.success then -- 1526
			saveStepLLMDebugOutput( -- 1529
				shared, -- 1529
				stepId, -- 1529
				"decision_tool_calling", -- 1529
				res.raw or res.message, -- 1529
				{success = false} -- 1529
			) -- 1529
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1530
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1530
		end -- 1530
		saveStepLLMDebugOutput( -- 1533
			shared, -- 1533
			stepId, -- 1533
			"decision_tool_calling", -- 1533
			encodeDebugJSON(res.response), -- 1533
			{success = true} -- 1533
		) -- 1533
		local choice = res.response.choices and res.response.choices[1] -- 1534
		local message = choice and choice.message -- 1535
		local toolCalls = message and message.tool_calls -- 1536
		local toolCall = toolCalls and toolCalls[1] -- 1537
		local fn = toolCall and toolCall["function"] -- 1538
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 1539
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1542
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1545
		Log( -- 1548
			"Info", -- 1548
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1548
		) -- 1548
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1548
			if messageContent and messageContent ~= "" then -- 1548
				Log( -- 1551
					"Info", -- 1551
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1551
				) -- 1551
				return ____awaiter_resolve(nil, { -- 1551
					success = true, -- 1553
					tool = "finish", -- 1554
					params = {}, -- 1555
					reason = messageContent, -- 1556
					reasoningContent = reasoningContent, -- 1557
					directSummary = messageContent -- 1558
				}) -- 1558
			end -- 1558
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1561
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1561
		end -- 1561
		local functionName = fn.name -- 1568
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1569
		Log( -- 1570
			"Info", -- 1570
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1570
		) -- 1570
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1571
			local rawObj, err = safeJsonDecode(argsText) -- 1572
			if err ~= nil or rawObj == nil then -- 1572
				return {__error = tostring(err)} -- 1574
			end -- 1574
			return rawObj -- 1576
		end)() -- 1571
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 1571
			local err = tostring(rawArgs.__error) -- 1579
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1580
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1580
		end -- 1580
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1587
		if not decision.success then -- 1587
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1589
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1589
		end -- 1589
		local validation = validateDecision(decision.tool, decision.params) -- 1596
		if not validation.success then -- 1596
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1598
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1598
		end -- 1598
		decision.params = validation.params -- 1605
		decision.toolCallId = ensureToolCallId(toolCallId) -- 1606
		decision.reason = messageContent -- 1607
		decision.reasoningContent = reasoningContent -- 1608
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1609
		return ____awaiter_resolve(nil, decision) -- 1609
	end) -- 1609
end -- 1506
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 1613
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1613
		Log( -- 1618
			"Info", -- 1618
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 1618
		) -- 1618
		local lastError = initialError -- 1619
		local candidateRaw = "" -- 1620
		do -- 1620
			local attempt = 0 -- 1621
			while attempt < shared.llmMaxTry do -- 1621
				do -- 1621
					Log( -- 1622
						"Info", -- 1622
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 1622
					) -- 1622
					local messages = buildXmlRepairMessages( -- 1623
						shared, -- 1624
						originalRaw, -- 1625
						candidateRaw, -- 1626
						lastError, -- 1627
						attempt + 1 -- 1628
					) -- 1628
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 1630
					if shared.stopToken.stopped then -- 1630
						return ____awaiter_resolve( -- 1630
							nil, -- 1630
							{ -- 1632
								success = false, -- 1632
								message = getCancelledReason(shared) -- 1632
							} -- 1632
						) -- 1632
					end -- 1632
					if not llmRes.success then -- 1632
						lastError = llmRes.message -- 1635
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 1636
						goto __continue263 -- 1637
					end -- 1637
					candidateRaw = llmRes.text -- 1639
					local decision = tryParseAndValidateDecision(candidateRaw) -- 1640
					if decision.success then -- 1640
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 1642
						return ____awaiter_resolve(nil, decision) -- 1642
					end -- 1642
					lastError = decision.message -- 1645
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 1646
				end -- 1646
				::__continue263:: -- 1646
				attempt = attempt + 1 -- 1621
			end -- 1621
		end -- 1621
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 1648
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 1648
	end) -- 1648
end -- 1613
function MainDecisionAgent.prototype.exec(self, input) -- 1656
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1656
		local shared = input.shared -- 1657
		if shared.stopToken.stopped then -- 1657
			return ____awaiter_resolve( -- 1657
				nil, -- 1657
				{ -- 1659
					success = false, -- 1659
					message = getCancelledReason(shared) -- 1659
				} -- 1659
			) -- 1659
		end -- 1659
		if shared.step >= shared.maxSteps then -- 1659
			Log( -- 1662
				"Warn", -- 1662
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1662
			) -- 1662
			return ____awaiter_resolve( -- 1662
				nil, -- 1662
				{ -- 1663
					success = false, -- 1663
					message = getMaxStepsReachedReason(shared) -- 1663
				} -- 1663
			) -- 1663
		end -- 1663
		if shared.decisionMode == "tool_calling" then -- 1663
			Log( -- 1667
				"Info", -- 1667
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 1667
			) -- 1667
			local lastError = "tool calling validation failed" -- 1668
			local lastRaw = "" -- 1669
			do -- 1669
				local attempt = 0 -- 1670
				while attempt < shared.llmMaxTry do -- 1670
					Log( -- 1671
						"Info", -- 1671
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1671
					) -- 1671
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 1672
					if shared.stopToken.stopped then -- 1672
						return ____awaiter_resolve( -- 1672
							nil, -- 1672
							{ -- 1679
								success = false, -- 1679
								message = getCancelledReason(shared) -- 1679
							} -- 1679
						) -- 1679
					end -- 1679
					if decision.success then -- 1679
						return ____awaiter_resolve(nil, decision) -- 1679
					end -- 1679
					lastError = decision.message -- 1684
					lastRaw = decision.raw or "" -- 1685
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1686
					attempt = attempt + 1 -- 1670
				end -- 1670
			end -- 1670
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1688
			return ____awaiter_resolve( -- 1688
				nil, -- 1688
				{ -- 1689
					success = false, -- 1689
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1689
				} -- 1689
			) -- 1689
		end -- 1689
		local lastError = "xml validation failed" -- 1692
		local lastRaw = "" -- 1693
		do -- 1693
			local attempt = 0 -- 1694
			while attempt < shared.llmMaxTry do -- 1694
				do -- 1694
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 1695
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 1703
					if shared.stopToken.stopped then -- 1703
						return ____awaiter_resolve( -- 1703
							nil, -- 1703
							{ -- 1705
								success = false, -- 1705
								message = getCancelledReason(shared) -- 1705
							} -- 1705
						) -- 1705
					end -- 1705
					if not llmRes.success then -- 1705
						lastError = llmRes.message -- 1708
						lastRaw = llmRes.text or "" -- 1709
						goto __continue276 -- 1710
					end -- 1710
					lastRaw = llmRes.text -- 1712
					local decision = tryParseAndValidateDecision(llmRes.text) -- 1713
					if decision.success then -- 1713
						return ____awaiter_resolve(nil, decision) -- 1713
					end -- 1713
					lastError = decision.message -- 1717
					return ____awaiter_resolve( -- 1717
						nil, -- 1717
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 1718
					) -- 1718
				end -- 1718
				::__continue276:: -- 1718
				attempt = attempt + 1 -- 1694
			end -- 1694
		end -- 1694
		return ____awaiter_resolve( -- 1694
			nil, -- 1694
			{ -- 1720
				success = false, -- 1720
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1720
			} -- 1720
		) -- 1720
	end) -- 1720
end -- 1656
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1723
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1723
		local result = execRes -- 1724
		if not result.success then -- 1724
			if shared.stopToken.stopped then -- 1724
				shared.error = getCancelledReason(shared) -- 1727
				shared.done = true -- 1728
				return ____awaiter_resolve(nil, "done") -- 1728
			end -- 1728
			shared.error = result.message -- 1731
			shared.response = getFailureSummaryFallback(shared, result.message) -- 1732
			shared.done = true -- 1733
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 1734
			persistHistoryState(shared) -- 1738
			return ____awaiter_resolve(nil, "done") -- 1738
		end -- 1738
		if result.directSummary and result.directSummary ~= "" then -- 1738
			shared.response = result.directSummary -- 1742
			shared.done = true -- 1743
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 1744
			persistHistoryState(shared) -- 1749
			return ____awaiter_resolve(nil, "done") -- 1749
		end -- 1749
		if result.tool == "finish" then -- 1749
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 1753
			shared.response = finalMessage -- 1754
			shared.done = true -- 1755
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 1756
			persistHistoryState(shared) -- 1761
			return ____awaiter_resolve(nil, "done") -- 1761
		end -- 1761
		local toolCallId = ensureToolCallId(result.toolCallId) -- 1764
		shared.step = shared.step + 1 -- 1765
		local step = shared.step -- 1766
		emitAgentEvent(shared, { -- 1767
			type = "decision_made", -- 1768
			sessionId = shared.sessionId, -- 1769
			taskId = shared.taskId, -- 1770
			step = step, -- 1771
			tool = result.tool, -- 1772
			reason = result.reason, -- 1773
			reasoningContent = result.reasoningContent, -- 1774
			params = result.params -- 1775
		}) -- 1775
		local ____shared_history_33 = shared.history -- 1775
		____shared_history_33[#____shared_history_33 + 1] = { -- 1777
			step = step, -- 1778
			toolCallId = toolCallId, -- 1779
			tool = result.tool, -- 1780
			reason = result.reason or "", -- 1781
			reasoningContent = result.reasoningContent, -- 1782
			params = result.params, -- 1783
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1784
		} -- 1784
		appendConversationMessage( -- 1786
			shared, -- 1786
			{ -- 1786
				role = "assistant", -- 1787
				content = result.reason or "", -- 1788
				reasoning_content = result.reasoningContent, -- 1789
				tool_calls = {{ -- 1790
					id = toolCallId, -- 1791
					type = "function", -- 1792
					["function"] = { -- 1793
						name = result.tool, -- 1794
						arguments = toJson(result.params) -- 1795
					} -- 1795
				}} -- 1795
			} -- 1795
		) -- 1795
		persistHistoryState(shared) -- 1799
		return ____awaiter_resolve(nil, result.tool) -- 1799
	end) -- 1799
end -- 1723
local ReadFileAction = __TS__Class() -- 1804
ReadFileAction.name = "ReadFileAction" -- 1804
__TS__ClassExtends(ReadFileAction, Node) -- 1804
function ReadFileAction.prototype.prep(self, shared) -- 1805
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1805
		local last = shared.history[#shared.history] -- 1806
		if not last then -- 1806
			error( -- 1807
				__TS__New(Error, "no history"), -- 1807
				0 -- 1807
			) -- 1807
		end -- 1807
		emitAgentStartEvent(shared, last) -- 1808
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1809
		if __TS__StringTrim(path) == "" then -- 1809
			error( -- 1812
				__TS__New(Error, "missing path"), -- 1812
				0 -- 1812
			) -- 1812
		end -- 1812
		local ____path_36 = path -- 1814
		local ____shared_workingDir_37 = shared.workingDir -- 1816
		local ____temp_38 = shared.useChineseResponse and "zh" or "en" -- 1817
		local ____last_params_startLine_34 = last.params.startLine -- 1818
		if ____last_params_startLine_34 == nil then -- 1818
			____last_params_startLine_34 = 1 -- 1818
		end -- 1818
		local ____TS__Number_result_39 = __TS__Number(____last_params_startLine_34) -- 1818
		local ____last_params_endLine_35 = last.params.endLine -- 1819
		if ____last_params_endLine_35 == nil then -- 1819
			____last_params_endLine_35 = READ_FILE_DEFAULT_LIMIT -- 1819
		end -- 1819
		return ____awaiter_resolve( -- 1819
			nil, -- 1819
			{ -- 1813
				path = ____path_36, -- 1814
				tool = "read_file", -- 1815
				workDir = ____shared_workingDir_37, -- 1816
				docLanguage = ____temp_38, -- 1817
				startLine = ____TS__Number_result_39, -- 1818
				endLine = __TS__Number(____last_params_endLine_35) -- 1819
			} -- 1819
		) -- 1819
	end) -- 1819
end -- 1805
function ReadFileAction.prototype.exec(self, input) -- 1823
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1823
		return ____awaiter_resolve( -- 1823
			nil, -- 1823
			Tools.readFile( -- 1824
				input.workDir, -- 1825
				input.path, -- 1826
				__TS__Number(input.startLine or 1), -- 1827
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1828
				input.docLanguage -- 1829
			) -- 1829
		) -- 1829
	end) -- 1829
end -- 1823
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1833
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1833
		local result = execRes -- 1834
		local last = shared.history[#shared.history] -- 1835
		if last ~= nil then -- 1835
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1837
			appendToolResultMessage(shared, last) -- 1838
			emitAgentFinishEvent(shared, last) -- 1839
		end -- 1839
		persistHistoryState(shared) -- 1841
		__TS__Await(maybeCompressHistory(shared)) -- 1842
		persistHistoryState(shared) -- 1843
		return ____awaiter_resolve(nil, "main") -- 1843
	end) -- 1843
end -- 1833
local SearchFilesAction = __TS__Class() -- 1848
SearchFilesAction.name = "SearchFilesAction" -- 1848
__TS__ClassExtends(SearchFilesAction, Node) -- 1848
function SearchFilesAction.prototype.prep(self, shared) -- 1849
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1849
		local last = shared.history[#shared.history] -- 1850
		if not last then -- 1850
			error( -- 1851
				__TS__New(Error, "no history"), -- 1851
				0 -- 1851
			) -- 1851
		end -- 1851
		emitAgentStartEvent(shared, last) -- 1852
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1852
	end) -- 1852
end -- 1849
function SearchFilesAction.prototype.exec(self, input) -- 1856
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1856
		local params = input.params -- 1857
		local ____Tools_searchFiles_53 = Tools.searchFiles -- 1858
		local ____input_workDir_46 = input.workDir -- 1859
		local ____temp_47 = params.path or "" -- 1860
		local ____temp_48 = params.pattern or "" -- 1861
		local ____params_globs_49 = params.globs -- 1862
		local ____params_useRegex_50 = params.useRegex -- 1863
		local ____params_caseSensitive_51 = params.caseSensitive -- 1864
		local ____math_max_42 = math.max -- 1867
		local ____math_floor_41 = math.floor -- 1867
		local ____params_limit_40 = params.limit -- 1867
		if ____params_limit_40 == nil then -- 1867
			____params_limit_40 = SEARCH_FILES_LIMIT_DEFAULT -- 1867
		end -- 1867
		local ____math_max_42_result_52 = ____math_max_42( -- 1867
			1, -- 1867
			____math_floor_41(__TS__Number(____params_limit_40)) -- 1867
		) -- 1867
		local ____math_max_45 = math.max -- 1868
		local ____math_floor_44 = math.floor -- 1868
		local ____params_offset_43 = params.offset -- 1868
		if ____params_offset_43 == nil then -- 1868
			____params_offset_43 = 0 -- 1868
		end -- 1868
		local result = __TS__Await(____Tools_searchFiles_53({ -- 1858
			workDir = ____input_workDir_46, -- 1859
			path = ____temp_47, -- 1860
			pattern = ____temp_48, -- 1861
			globs = ____params_globs_49, -- 1862
			useRegex = ____params_useRegex_50, -- 1863
			caseSensitive = ____params_caseSensitive_51, -- 1864
			includeContent = true, -- 1865
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1866
			limit = ____math_max_42_result_52, -- 1867
			offset = ____math_max_45( -- 1868
				0, -- 1868
				____math_floor_44(__TS__Number(____params_offset_43)) -- 1868
			), -- 1868
			groupByFile = params.groupByFile == true -- 1869
		})) -- 1869
		return ____awaiter_resolve(nil, result) -- 1869
	end) -- 1869
end -- 1856
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1874
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1874
		local last = shared.history[#shared.history] -- 1875
		if last ~= nil then -- 1875
			local result = execRes -- 1877
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1878
			appendToolResultMessage(shared, last) -- 1879
			emitAgentFinishEvent(shared, last) -- 1880
		end -- 1880
		persistHistoryState(shared) -- 1882
		__TS__Await(maybeCompressHistory(shared)) -- 1883
		persistHistoryState(shared) -- 1884
		return ____awaiter_resolve(nil, "main") -- 1884
	end) -- 1884
end -- 1874
local SearchDoraAPIAction = __TS__Class() -- 1889
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1889
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1889
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1890
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1890
		local last = shared.history[#shared.history] -- 1891
		if not last then -- 1891
			error( -- 1892
				__TS__New(Error, "no history"), -- 1892
				0 -- 1892
			) -- 1892
		end -- 1892
		emitAgentStartEvent(shared, last) -- 1893
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1893
	end) -- 1893
end -- 1890
function SearchDoraAPIAction.prototype.exec(self, input) -- 1897
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1897
		local params = input.params -- 1898
		local ____Tools_searchDoraAPI_61 = Tools.searchDoraAPI -- 1899
		local ____temp_57 = params.pattern or "" -- 1900
		local ____temp_58 = params.docSource or "api" -- 1901
		local ____temp_59 = input.useChineseResponse and "zh" or "en" -- 1902
		local ____temp_60 = params.programmingLanguage or "ts" -- 1903
		local ____math_min_56 = math.min -- 1904
		local ____math_max_55 = math.max -- 1904
		local ____params_limit_54 = params.limit -- 1904
		if ____params_limit_54 == nil then -- 1904
			____params_limit_54 = 8 -- 1904
		end -- 1904
		local result = __TS__Await(____Tools_searchDoraAPI_61({ -- 1899
			pattern = ____temp_57, -- 1900
			docSource = ____temp_58, -- 1901
			docLanguage = ____temp_59, -- 1902
			programmingLanguage = ____temp_60, -- 1903
			limit = ____math_min_56( -- 1904
				SEARCH_DORA_API_LIMIT_MAX, -- 1904
				____math_max_55( -- 1904
					1, -- 1904
					__TS__Number(____params_limit_54) -- 1904
				) -- 1904
			), -- 1904
			useRegex = params.useRegex, -- 1905
			caseSensitive = false, -- 1906
			includeContent = true, -- 1907
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1908
		})) -- 1908
		return ____awaiter_resolve(nil, result) -- 1908
	end) -- 1908
end -- 1897
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1913
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1913
		local last = shared.history[#shared.history] -- 1914
		if last ~= nil then -- 1914
			local result = execRes -- 1916
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1917
			appendToolResultMessage(shared, last) -- 1918
			emitAgentFinishEvent(shared, last) -- 1919
		end -- 1919
		persistHistoryState(shared) -- 1921
		__TS__Await(maybeCompressHistory(shared)) -- 1922
		persistHistoryState(shared) -- 1923
		return ____awaiter_resolve(nil, "main") -- 1923
	end) -- 1923
end -- 1913
local ListFilesAction = __TS__Class() -- 1928
ListFilesAction.name = "ListFilesAction" -- 1928
__TS__ClassExtends(ListFilesAction, Node) -- 1928
function ListFilesAction.prototype.prep(self, shared) -- 1929
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1929
		local last = shared.history[#shared.history] -- 1930
		if not last then -- 1930
			error( -- 1931
				__TS__New(Error, "no history"), -- 1931
				0 -- 1931
			) -- 1931
		end -- 1931
		emitAgentStartEvent(shared, last) -- 1932
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1932
	end) -- 1932
end -- 1929
function ListFilesAction.prototype.exec(self, input) -- 1936
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1936
		local params = input.params -- 1937
		local ____Tools_listFiles_68 = Tools.listFiles -- 1938
		local ____input_workDir_65 = input.workDir -- 1939
		local ____temp_66 = params.path or "" -- 1940
		local ____params_globs_67 = params.globs -- 1941
		local ____math_max_64 = math.max -- 1942
		local ____math_floor_63 = math.floor -- 1942
		local ____params_maxEntries_62 = params.maxEntries -- 1942
		if ____params_maxEntries_62 == nil then -- 1942
			____params_maxEntries_62 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1942
		end -- 1942
		local result = ____Tools_listFiles_68({ -- 1938
			workDir = ____input_workDir_65, -- 1939
			path = ____temp_66, -- 1940
			globs = ____params_globs_67, -- 1941
			maxEntries = ____math_max_64( -- 1942
				1, -- 1942
				____math_floor_63(__TS__Number(____params_maxEntries_62)) -- 1942
			) -- 1942
		}) -- 1942
		return ____awaiter_resolve(nil, result) -- 1942
	end) -- 1942
end -- 1936
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1947
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1947
		local last = shared.history[#shared.history] -- 1948
		if last ~= nil then -- 1948
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1950
			appendToolResultMessage(shared, last) -- 1951
			emitAgentFinishEvent(shared, last) -- 1952
		end -- 1952
		persistHistoryState(shared) -- 1954
		__TS__Await(maybeCompressHistory(shared)) -- 1955
		persistHistoryState(shared) -- 1956
		return ____awaiter_resolve(nil, "main") -- 1956
	end) -- 1956
end -- 1947
local DeleteFileAction = __TS__Class() -- 1961
DeleteFileAction.name = "DeleteFileAction" -- 1961
__TS__ClassExtends(DeleteFileAction, Node) -- 1961
function DeleteFileAction.prototype.prep(self, shared) -- 1962
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1962
		local last = shared.history[#shared.history] -- 1963
		if not last then -- 1963
			error( -- 1964
				__TS__New(Error, "no history"), -- 1964
				0 -- 1964
			) -- 1964
		end -- 1964
		emitAgentStartEvent(shared, last) -- 1965
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1966
		if __TS__StringTrim(targetFile) == "" then -- 1966
			error( -- 1969
				__TS__New(Error, "missing target_file"), -- 1969
				0 -- 1969
			) -- 1969
		end -- 1969
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1969
	end) -- 1969
end -- 1962
function DeleteFileAction.prototype.exec(self, input) -- 1973
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1973
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1974
		if not result.success then -- 1974
			return ____awaiter_resolve(nil, result) -- 1974
		end -- 1974
		return ____awaiter_resolve(nil, { -- 1974
			success = true, -- 1982
			changed = true, -- 1983
			mode = "delete", -- 1984
			checkpointId = result.checkpointId, -- 1985
			checkpointSeq = result.checkpointSeq, -- 1986
			files = {{path = input.targetFile, op = "delete"}} -- 1987
		}) -- 1987
	end) -- 1987
end -- 1973
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1991
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1991
		local last = shared.history[#shared.history] -- 1992
		if last ~= nil then -- 1992
			last.result = execRes -- 1994
			appendToolResultMessage(shared, last) -- 1995
			emitAgentFinishEvent(shared, last) -- 1996
			local result = last.result -- 1997
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 1997
				emitAgentEvent(shared, { -- 2002
					type = "checkpoint_created", -- 2003
					sessionId = shared.sessionId, -- 2004
					taskId = shared.taskId, -- 2005
					step = last.step, -- 2006
					tool = "delete_file", -- 2007
					checkpointId = result.checkpointId, -- 2008
					checkpointSeq = result.checkpointSeq, -- 2009
					files = result.files -- 2010
				}) -- 2010
			end -- 2010
		end -- 2010
		persistHistoryState(shared) -- 2014
		__TS__Await(maybeCompressHistory(shared)) -- 2015
		persistHistoryState(shared) -- 2016
		return ____awaiter_resolve(nil, "main") -- 2016
	end) -- 2016
end -- 1991
local BuildAction = __TS__Class() -- 2021
BuildAction.name = "BuildAction" -- 2021
__TS__ClassExtends(BuildAction, Node) -- 2021
function BuildAction.prototype.prep(self, shared) -- 2022
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2022
		local last = shared.history[#shared.history] -- 2023
		if not last then -- 2023
			error( -- 2024
				__TS__New(Error, "no history"), -- 2024
				0 -- 2024
			) -- 2024
		end -- 2024
		emitAgentStartEvent(shared, last) -- 2025
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2025
	end) -- 2025
end -- 2022
function BuildAction.prototype.exec(self, input) -- 2029
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2029
		local params = input.params -- 2030
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2031
		return ____awaiter_resolve(nil, result) -- 2031
	end) -- 2031
end -- 2029
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2038
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2038
		local last = shared.history[#shared.history] -- 2039
		if last ~= nil then -- 2039
			last.result = execRes -- 2041
			appendToolResultMessage(shared, last) -- 2042
			emitAgentFinishEvent(shared, last) -- 2043
		end -- 2043
		persistHistoryState(shared) -- 2045
		__TS__Await(maybeCompressHistory(shared)) -- 2046
		persistHistoryState(shared) -- 2047
		return ____awaiter_resolve(nil, "main") -- 2047
	end) -- 2047
end -- 2038
local EditFileAction = __TS__Class() -- 2052
EditFileAction.name = "EditFileAction" -- 2052
__TS__ClassExtends(EditFileAction, Node) -- 2052
function EditFileAction.prototype.prep(self, shared) -- 2053
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2053
		local last = shared.history[#shared.history] -- 2054
		if not last then -- 2054
			error( -- 2055
				__TS__New(Error, "no history"), -- 2055
				0 -- 2055
			) -- 2055
		end -- 2055
		emitAgentStartEvent(shared, last) -- 2056
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2057
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2060
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2061
		if __TS__StringTrim(path) == "" then -- 2061
			error( -- 2062
				__TS__New(Error, "missing path"), -- 2062
				0 -- 2062
			) -- 2062
		end -- 2062
		return ____awaiter_resolve(nil, { -- 2062
			path = path, -- 2063
			oldStr = oldStr, -- 2063
			newStr = newStr, -- 2063
			taskId = shared.taskId, -- 2063
			workDir = shared.workingDir -- 2063
		}) -- 2063
	end) -- 2063
end -- 2053
function EditFileAction.prototype.exec(self, input) -- 2066
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2066
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 2067
		if not readRes.success then -- 2067
			if input.oldStr ~= "" then -- 2067
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 2067
			end -- 2067
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2072
			if not createRes.success then -- 2072
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 2072
			end -- 2072
			return ____awaiter_resolve(nil, { -- 2072
				success = true, -- 2080
				changed = true, -- 2081
				mode = "create", -- 2082
				checkpointId = createRes.checkpointId, -- 2083
				checkpointSeq = createRes.checkpointSeq, -- 2084
				files = {{path = input.path, op = "create"}} -- 2085
			}) -- 2085
		end -- 2085
		if input.oldStr == "" then -- 2085
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2089
			if not overwriteRes.success then -- 2089
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 2089
			end -- 2089
			return ____awaiter_resolve(nil, { -- 2089
				success = true, -- 2097
				changed = true, -- 2098
				mode = "overwrite", -- 2099
				checkpointId = overwriteRes.checkpointId, -- 2100
				checkpointSeq = overwriteRes.checkpointSeq, -- 2101
				files = {{path = input.path, op = "write"}} -- 2102
			}) -- 2102
		end -- 2102
		local normalizedContent = normalizeLineEndings(readRes.content) -- 2107
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 2108
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 2109
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 2112
		if occurrences == 0 then -- 2112
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2114
			if not indentTolerant.success then -- 2114
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 2114
			end -- 2114
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 2118
			if not applyRes.success then -- 2118
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2118
			end -- 2118
			return ____awaiter_resolve(nil, { -- 2118
				success = true, -- 2126
				changed = true, -- 2127
				mode = "replace_indent_tolerant", -- 2128
				checkpointId = applyRes.checkpointId, -- 2129
				checkpointSeq = applyRes.checkpointSeq, -- 2130
				files = {{path = input.path, op = "write"}} -- 2131
			}) -- 2131
		end -- 2131
		if occurrences > 1 then -- 2131
			return ____awaiter_resolve( -- 2131
				nil, -- 2131
				{ -- 2135
					success = false, -- 2135
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 2135
				} -- 2135
			) -- 2135
		end -- 2135
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2139
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2140
		if not applyRes.success then -- 2140
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2140
		end -- 2140
		return ____awaiter_resolve(nil, { -- 2140
			success = true, -- 2148
			changed = true, -- 2149
			mode = "replace", -- 2150
			checkpointId = applyRes.checkpointId, -- 2151
			checkpointSeq = applyRes.checkpointSeq, -- 2152
			files = {{path = input.path, op = "write"}} -- 2153
		}) -- 2153
	end) -- 2153
end -- 2066
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2157
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2157
		local last = shared.history[#shared.history] -- 2158
		if last ~= nil then -- 2158
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 2160
			last.result = execRes -- 2161
			appendToolResultMessage(shared, last) -- 2162
			emitAgentFinishEvent(shared, last) -- 2163
			local result = last.result -- 2164
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2164
				emitAgentEvent(shared, { -- 2169
					type = "checkpoint_created", -- 2170
					sessionId = shared.sessionId, -- 2171
					taskId = shared.taskId, -- 2172
					step = last.step, -- 2173
					tool = last.tool, -- 2174
					checkpointId = result.checkpointId, -- 2175
					checkpointSeq = result.checkpointSeq, -- 2176
					files = result.files -- 2177
				}) -- 2177
			end -- 2177
		end -- 2177
		persistHistoryState(shared) -- 2181
		__TS__Await(maybeCompressHistory(shared)) -- 2182
		persistHistoryState(shared) -- 2183
		return ____awaiter_resolve(nil, "main") -- 2183
	end) -- 2183
end -- 2157
local EndNode = __TS__Class() -- 2188
EndNode.name = "EndNode" -- 2188
__TS__ClassExtends(EndNode, Node) -- 2188
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 2189
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2189
		return ____awaiter_resolve(nil, nil) -- 2189
	end) -- 2189
end -- 2189
local CodingAgentFlow = __TS__Class() -- 2194
CodingAgentFlow.name = "CodingAgentFlow" -- 2194
__TS__ClassExtends(CodingAgentFlow, Flow) -- 2194
function CodingAgentFlow.prototype.____constructor(self) -- 2195
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 2196
	local read = __TS__New(ReadFileAction, 1, 0) -- 2197
	local search = __TS__New(SearchFilesAction, 1, 0) -- 2198
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 2199
	local list = __TS__New(ListFilesAction, 1, 0) -- 2200
	local del = __TS__New(DeleteFileAction, 1, 0) -- 2201
	local build = __TS__New(BuildAction, 1, 0) -- 2202
	local edit = __TS__New(EditFileAction, 1, 0) -- 2203
	local done = __TS__New(EndNode, 1, 0) -- 2204
	main:on("read_file", read) -- 2206
	main:on("grep_files", search) -- 2207
	main:on("search_dora_api", searchDora) -- 2208
	main:on("glob_files", list) -- 2209
	main:on("delete_file", del) -- 2210
	main:on("build", build) -- 2211
	main:on("edit_file", edit) -- 2212
	main:on("done", done) -- 2213
	read:on("main", main) -- 2215
	search:on("main", main) -- 2216
	searchDora:on("main", main) -- 2217
	list:on("main", main) -- 2218
	del:on("main", main) -- 2219
	build:on("main", main) -- 2220
	edit:on("main", main) -- 2221
	Flow.prototype.____constructor(self, main) -- 2223
end -- 2195
local function runCodingAgentAsync(options) -- 2245
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2245
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 2245
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 2245
		end -- 2245
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 2249
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2250
		if not llmConfigRes.success then -- 2250
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2250
		end -- 2250
		local llmConfig = llmConfigRes.config -- 2256
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 2257
		if not taskRes.success then -- 2257
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 2257
		end -- 2257
		local compressor = __TS__New(MemoryCompressor, { -- 2264
			compressionThreshold = 0.8, -- 2265
			maxCompressionRounds = 3, -- 2266
			maxTokensPerCompression = 20000, -- 2267
			projectDir = options.workDir, -- 2268
			llmConfig = llmConfig, -- 2269
			promptPack = options.promptPack -- 2270
		}) -- 2270
		local persistedSession = compressor:getStorage():readSessionState() -- 2272
		local promptPack = compressor:getPromptPack() -- 2273
		local shared = { -- 2275
			sessionId = options.sessionId, -- 2276
			taskId = taskRes.taskId, -- 2277
			maxSteps = math.max( -- 2278
				1, -- 2278
				math.floor(options.maxSteps or 50) -- 2278
			), -- 2278
			llmMaxTry = math.max( -- 2279
				1, -- 2279
				math.floor(options.llmMaxTry or 3) -- 2279
			), -- 2279
			step = 0, -- 2280
			done = false, -- 2281
			stopToken = options.stopToken or ({stopped = false}), -- 2282
			response = "", -- 2283
			userQuery = normalizedPrompt, -- 2284
			workingDir = options.workDir, -- 2285
			useChineseResponse = options.useChineseResponse == true, -- 2286
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 2287
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 2290
			llmConfig = llmConfig, -- 2295
			onEvent = options.onEvent, -- 2296
			promptPack = promptPack, -- 2297
			history = {}, -- 2298
			messages = persistedSession.messages, -- 2299
			memory = {compressor = compressor}, -- 2301
			skills = {loader = createSkillsLoader({projectDir = options.workDir})} -- 2305
		} -- 2305
		local ____try = __TS__AsyncAwaiter(function() -- 2305
			emitAgentEvent(shared, { -- 2313
				type = "task_started", -- 2314
				sessionId = shared.sessionId, -- 2315
				taskId = shared.taskId, -- 2316
				prompt = shared.userQuery, -- 2317
				workDir = shared.workingDir, -- 2318
				maxSteps = shared.maxSteps -- 2319
			}) -- 2319
			if shared.stopToken.stopped then -- 2319
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2322
				return ____awaiter_resolve( -- 2322
					nil, -- 2322
					emitAgentTaskFinishEvent( -- 2323
						shared, -- 2323
						false, -- 2323
						getCancelledReason(shared) -- 2323
					) -- 2323
				) -- 2323
			end -- 2323
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 2325
			local promptCommand = getPromptCommand(shared.userQuery) -- 2326
			if promptCommand == "reset" then -- 2326
				return ____awaiter_resolve( -- 2326
					nil, -- 2326
					resetSessionHistory(shared) -- 2328
				) -- 2328
			end -- 2328
			if promptCommand == "compact" then -- 2328
				return ____awaiter_resolve( -- 2328
					nil, -- 2328
					__TS__Await(compactAllHistory(shared)) -- 2331
				) -- 2331
			end -- 2331
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 2333
			persistHistoryState(shared) -- 2337
			local flow = __TS__New(CodingAgentFlow) -- 2338
			__TS__Await(flow:run(shared)) -- 2339
			if shared.stopToken.stopped then -- 2339
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2341
				return ____awaiter_resolve( -- 2341
					nil, -- 2341
					emitAgentTaskFinishEvent( -- 2342
						shared, -- 2342
						false, -- 2342
						getCancelledReason(shared) -- 2342
					) -- 2342
				) -- 2342
			end -- 2342
			if shared.error then -- 2342
				return ____awaiter_resolve( -- 2342
					nil, -- 2342
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 2345
				) -- 2345
			end -- 2345
			Tools.setTaskStatus(shared.taskId, "DONE") -- 2348
			return ____awaiter_resolve( -- 2348
				nil, -- 2348
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 2349
			) -- 2349
		end) -- 2349
		__TS__Await(____try.catch( -- 2312
			____try, -- 2312
			function(____, e) -- 2312
				return ____awaiter_resolve( -- 2312
					nil, -- 2312
					finalizeAgentFailure( -- 2352
						shared, -- 2352
						tostring(e) -- 2352
					) -- 2352
				) -- 2352
			end -- 2352
		)) -- 2352
	end) -- 2352
end -- 2245
function ____exports.runCodingAgent(options, callback) -- 2356
	local ____self_69 = runCodingAgentAsync(options) -- 2356
	____self_69["then"]( -- 2356
		____self_69, -- 2356
		function(____, result) return callback(result) end -- 2357
	) -- 2357
end -- 2356
return ____exports -- 2356