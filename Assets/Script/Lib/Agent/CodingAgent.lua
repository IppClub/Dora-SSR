-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
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
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
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
function getReplyLanguageDirective(shared) -- 362
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 363
end -- 363
function replacePromptVars(template, vars) -- 368
	local output = template -- 369
	for key in pairs(vars) do -- 370
		output = table.concat( -- 371
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 371
			vars[key] or "" or "," -- 371
		) -- 371
	end -- 371
	return output -- 373
end -- 373
function getDecisionToolDefinitions(shared) -- 498
	local base = replacePromptVars( -- 499
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 500
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 501
	) -- 501
	if (shared and shared.decisionMode) ~= "xml" then -- 501
		return base -- 504
	end -- 504
	return base .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 506
end -- 506
function persistHistoryState(shared) -- 583
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.memory.lastConsolidatedMessageIndex) -- 584
end -- 584
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 910
	if includeToolDefinitions == nil then -- 910
		includeToolDefinitions = false -- 910
	end -- 910
	local sections = { -- 911
		shared.promptPack.agentIdentityPrompt, -- 912
		getReplyLanguageDirective(shared) -- 913
	} -- 913
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 915
	if memoryContext ~= "" then -- 915
		sections[#sections + 1] = memoryContext -- 917
	end -- 917
	if includeToolDefinitions then -- 917
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 920
		if shared.decisionMode == "xml" then -- 920
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 922
		end -- 922
	end -- 922
	return table.concat(sections, "\n\n") -- 925
end -- 925
function buildXmlDecisionInstruction(shared, feedback) -- 953
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 954
end -- 954
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 109
local HISTORY_READ_FILE_MAX_LINES = 300 -- 110
local READ_FILE_DEFAULT_LIMIT = 300 -- 111
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 112
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 113
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 114
SEARCH_DORA_API_LIMIT_MAX = 20 -- 115
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 116
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 117
local SEARCH_PREVIEW_CONTEXT = 80 -- 118
local function emitAgentEvent(shared, event) -- 161
	if shared.onEvent then -- 161
		shared:onEvent(event) -- 163
	end -- 163
end -- 161
local function getCancelledReason(shared) -- 167
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 167
		return shared.stopToken.reason -- 168
	end -- 168
	return shared.useChineseResponse and "已取消" or "cancelled" -- 169
end -- 167
local function getMaxStepsReachedReason(shared) -- 172
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 173
end -- 172
local function getFailureSummaryFallback(shared, ____error) -- 178
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 179
end -- 178
local function canWriteStepLLMDebug(shared, stepId) -- 184
	if stepId == nil then -- 184
		stepId = shared.step + 1 -- 184
	end -- 184
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 185
end -- 184
local function ensureDirRecursive(dir) -- 192
	if not dir then -- 192
		return false -- 193
	end -- 193
	if Content:exist(dir) then -- 193
		return Content:isdir(dir) -- 194
	end -- 194
	local parent = Path:getPath(dir) -- 195
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 195
		return false -- 197
	end -- 197
	return Content:mkdir(dir) -- 199
end -- 192
local function encodeDebugJSON(value) -- 202
	local text, err = safeJsonEncode(value) -- 203
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 204
end -- 202
local function getStepLLMDebugDir(shared) -- 207
	return Path( -- 208
		shared.workingDir, -- 209
		".agent", -- 210
		tostring(shared.sessionId), -- 211
		tostring(shared.taskId) -- 212
	) -- 212
end -- 207
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 216
	return Path( -- 217
		getStepLLMDebugDir(shared), -- 217
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 217
	) -- 217
end -- 216
local function getLatestStepLLMDebugSeq(shared, stepId) -- 220
	if not canWriteStepLLMDebug(shared, stepId) then -- 220
		return 0 -- 221
	end -- 221
	local dir = getStepLLMDebugDir(shared) -- 222
	if not Content:exist(dir) or not Content:isdir(dir) then -- 222
		return 0 -- 223
	end -- 223
	local latest = 0 -- 224
	for ____, file in ipairs(Content:getFiles(dir)) do -- 225
		do -- 225
			local name = Path:getFilename(file) -- 226
			local seqText = string.match( -- 227
				name, -- 227
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 227
			) -- 227
			if seqText ~= nil then -- 227
				latest = math.max( -- 229
					latest, -- 229
					tonumber(seqText) -- 229
				) -- 229
				goto __continue19 -- 230
			end -- 230
			local legacyMatch = string.match( -- 232
				name, -- 232
				("^" .. tostring(stepId)) .. "_in%.md$" -- 232
			) -- 232
			if legacyMatch ~= nil then -- 232
				latest = math.max(latest, 1) -- 234
			end -- 234
		end -- 234
		::__continue19:: -- 234
	end -- 234
	return latest -- 237
end -- 220
local function writeStepLLMDebugFile(path, content) -- 240
	if not Content:save(path, content) then -- 240
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 242
		return false -- 243
	end -- 243
	return true -- 245
end -- 240
local function createStepLLMDebugPair(shared, stepId, inContent) -- 248
	if not canWriteStepLLMDebug(shared, stepId) then -- 248
		return 0 -- 249
	end -- 249
	local dir = getStepLLMDebugDir(shared) -- 250
	if not ensureDirRecursive(dir) then -- 250
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 252
		return 0 -- 253
	end -- 253
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 255
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 256
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 257
	if not writeStepLLMDebugFile(inPath, inContent) then -- 257
		return 0 -- 259
	end -- 259
	writeStepLLMDebugFile(outPath, "") -- 261
	return seq -- 262
end -- 248
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 265
	if not canWriteStepLLMDebug(shared, stepId) then -- 265
		return -- 266
	end -- 266
	local dir = getStepLLMDebugDir(shared) -- 267
	if not ensureDirRecursive(dir) then -- 267
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 269
		return -- 270
	end -- 270
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 272
	if latestSeq <= 0 then -- 272
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 274
		writeStepLLMDebugFile(outPath, content) -- 275
		return -- 276
	end -- 276
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 278
	writeStepLLMDebugFile(outPath, content) -- 279
end -- 265
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 282
	if not canWriteStepLLMDebug(shared, stepId) then -- 282
		return -- 283
	end -- 283
	local sections = { -- 284
		"# LLM Input", -- 285
		"session_id: " .. tostring(shared.sessionId), -- 286
		"task_id: " .. tostring(shared.taskId), -- 287
		"step_id: " .. tostring(stepId), -- 288
		"phase: " .. phase, -- 289
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 290
		"## Options", -- 291
		"```json", -- 292
		encodeDebugJSON(options), -- 293
		"```" -- 294
	} -- 294
	do -- 294
		local i = 0 -- 296
		while i < #messages do -- 296
			local message = messages[i + 1] -- 297
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 298
			sections[#sections + 1] = encodeDebugJSON(message) -- 299
			i = i + 1 -- 296
		end -- 296
	end -- 296
	createStepLLMDebugPair( -- 301
		shared, -- 301
		stepId, -- 301
		table.concat(sections, "\n") -- 301
	) -- 301
end -- 282
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 304
	if not canWriteStepLLMDebug(shared, stepId) then -- 304
		return -- 305
	end -- 305
	local ____array_0 = __TS__SparseArrayNew( -- 305
		"# LLM Output", -- 307
		"session_id: " .. tostring(shared.sessionId), -- 308
		"task_id: " .. tostring(shared.taskId), -- 309
		"step_id: " .. tostring(stepId), -- 310
		"phase: " .. phase, -- 311
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 312
		table.unpack(meta and ({ -- 313
			"## Meta", -- 313
			"```json", -- 313
			encodeDebugJSON(meta), -- 313
			"```" -- 313
		}) or ({})) -- 313
	) -- 313
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 313
	local sections = {__TS__SparseArraySpread(____array_0)} -- 306
	updateLatestStepLLMDebugOutput( -- 317
		shared, -- 317
		stepId, -- 317
		table.concat(sections, "\n") -- 317
	) -- 317
end -- 304
local function toJson(value) -- 320
	local text, err = safeJsonEncode(value) -- 321
	if text ~= nil then -- 321
		return text -- 322
	end -- 322
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 323
end -- 320
local function truncateText(text, maxLen) -- 326
	if #text <= maxLen then -- 326
		return text -- 327
	end -- 327
	local nextPos = utf8.offset(text, maxLen + 1) -- 328
	if nextPos == nil then -- 328
		return text -- 329
	end -- 329
	return string.sub(text, 1, nextPos - 1) .. "..." -- 330
end -- 326
local function utf8TakeHead(text, maxChars) -- 333
	if maxChars <= 0 or text == "" then -- 333
		return "" -- 334
	end -- 334
	local nextPos = utf8.offset(text, maxChars + 1) -- 335
	if nextPos == nil then -- 335
		return text -- 336
	end -- 336
	return string.sub(text, 1, nextPos - 1) -- 337
end -- 333
local function utf8TakeTail(text, maxChars) -- 340
	if maxChars <= 0 or text == "" then -- 340
		return "" -- 341
	end -- 341
	local charLen = utf8.len(text) -- 342
	if charLen == nil or charLen <= maxChars then -- 342
		return text -- 343
	end -- 343
	local startChar = math.max(1, charLen - maxChars + 1) -- 344
	local startPos = utf8.offset(text, startChar) -- 345
	if startPos == nil then -- 345
		return text -- 346
	end -- 346
	return string.sub(text, startPos) -- 347
end -- 340
local function summarizeUnknown(value, maxLen) -- 350
	if maxLen == nil then -- 350
		maxLen = 320 -- 350
	end -- 350
	if value == nil then -- 350
		return "undefined" -- 351
	end -- 351
	if value == nil then -- 351
		return "null" -- 352
	end -- 352
	if type(value) == "string" then -- 352
		return __TS__StringReplace( -- 354
			truncateText(value, maxLen), -- 354
			"\n", -- 354
			"\\n" -- 354
		) -- 354
	end -- 354
	if type(value) == "number" or type(value) == "boolean" then -- 354
		return tostring(value) -- 357
	end -- 357
	return __TS__StringReplace( -- 359
		truncateText( -- 359
			toJson(value), -- 359
			maxLen -- 359
		), -- 359
		"\n", -- 359
		"\\n" -- 359
	) -- 359
end -- 350
local function limitReadContentForHistory(content, tool) -- 376
	local lines = __TS__StringSplit(content, "\n") -- 377
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 378
	local limitedByLines = overLineLimit and table.concat( -- 379
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 380
		"\n" -- 380
	) or content -- 380
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 380
		return content -- 383
	end -- 383
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 385
	local reasons = {} -- 388
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 388
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 389
	end -- 389
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 389
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 390
	end -- 390
	local hint = "Narrow the requested line range." -- 391
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 392
end -- 376
local function summarizeEditTextParamForHistory(value, key) -- 395
	if type(value) ~= "string" then -- 395
		return nil -- 396
	end -- 396
	local text = value -- 397
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 398
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 399
end -- 395
local function sanitizeReadResultForHistory(tool, result) -- 407
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 407
		return result -- 409
	end -- 409
	local clone = {} -- 411
	for key in pairs(result) do -- 412
		clone[key] = result[key] -- 413
	end -- 413
	clone.content = limitReadContentForHistory(result.content, tool) -- 415
	return clone -- 416
end -- 407
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 419
	local shown = math.min(#items, maxItems) -- 423
	local out = {} -- 424
	do -- 424
		local i = 0 -- 425
		while i < shown do -- 425
			local row = items[i + 1] -- 426
			out[#out + 1] = { -- 427
				file = row.file, -- 428
				line = row.line, -- 429
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 430
			} -- 430
			i = i + 1 -- 425
		end -- 425
	end -- 425
	return out -- 435
end -- 419
local function sanitizeSearchResultForHistory(tool, result) -- 438
	if result.success ~= true or type(result.results) ~= "table" then -- 438
		return result -- 442
	end -- 442
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 442
		return result -- 443
	end -- 443
	local clone = {} -- 444
	for key in pairs(result) do -- 445
		clone[key] = result[key] -- 446
	end -- 446
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 448
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 449
	if tool == "grep_files" and type(result.groupedResults) == "table" then -- 449
		local grouped = result.groupedResults -- 454
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 455
		local sanitizedGroups = {} -- 456
		do -- 456
			local i = 0 -- 457
			while i < shown do -- 457
				local row = grouped[i + 1] -- 458
				sanitizedGroups[#sanitizedGroups + 1] = { -- 459
					file = row.file, -- 460
					totalMatches = row.totalMatches, -- 461
					matches = type(row.matches) == "table" and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 462
				} -- 462
				i = i + 1 -- 457
			end -- 457
		end -- 457
		clone.groupedResults = sanitizedGroups -- 467
	end -- 467
	return clone -- 469
end -- 438
local function sanitizeListFilesResultForHistory(result) -- 472
	if result.success ~= true or type(result.files) ~= "table" then -- 472
		return result -- 473
	end -- 473
	local clone = {} -- 474
	for key in pairs(result) do -- 475
		clone[key] = result[key] -- 476
	end -- 476
	local files = result.files -- 478
	clone.files = __TS__ArraySlice(files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 479
	return clone -- 480
end -- 472
local function sanitizeActionParamsForHistory(tool, params) -- 483
	if tool ~= "edit_file" then -- 483
		return params -- 484
	end -- 484
	local clone = {} -- 485
	for key in pairs(params) do -- 486
		if key == "old_str" then -- 486
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 488
		elseif key == "new_str" then -- 488
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 490
		else -- 490
			clone[key] = params[key] -- 492
		end -- 492
	end -- 492
	return clone -- 495
end -- 483
local function maybeCompressHistory(shared) -- 515
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 515
		local ____shared_5 = shared -- 516
		local memory = ____shared_5.memory -- 516
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 517
		local changed = false -- 518
		do -- 518
			local round = 0 -- 519
			while round < maxRounds do -- 519
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 520
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 524
				if not memory.compressor:shouldCompress(shared.messages, memory.lastConsolidatedMessageIndex, systemPrompt, toolDefinitions) then -- 524
					return ____awaiter_resolve(nil) -- 524
				end -- 524
				local result = __TS__Await(memory.compressor:compress( -- 535
					shared.messages, -- 536
					memory.lastConsolidatedMessageIndex, -- 537
					systemPrompt, -- 538
					toolDefinitions, -- 539
					shared.llmOptions, -- 540
					shared.llmMaxTry, -- 541
					shared.decisionMode -- 542
				)) -- 542
				if not (result and result.success and result.compressedCount > 0) then -- 542
					if changed then -- 542
						persistHistoryState(shared) -- 546
					end -- 546
					return ____awaiter_resolve(nil) -- 546
				end -- 546
				memory.lastConsolidatedMessageIndex = memory.lastConsolidatedMessageIndex + result.compressedCount -- 550
				changed = true -- 551
				Log( -- 552
					"Info", -- 552
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(round + 1)) .. ")" -- 552
				) -- 552
				round = round + 1 -- 519
			end -- 519
		end -- 519
		if changed then -- 519
			persistHistoryState(shared) -- 555
		end -- 555
	end) -- 555
end -- 515
local function isKnownToolName(name) -- 559
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 560
end -- 559
local function getFinishMessage(params, fallback) -- 570
	if fallback == nil then -- 570
		fallback = "" -- 570
	end -- 570
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 570
		return __TS__StringTrim(params.message) -- 572
	end -- 572
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 572
		return __TS__StringTrim(params.response) -- 575
	end -- 575
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 575
		return __TS__StringTrim(params.summary) -- 578
	end -- 578
	return __TS__StringTrim(fallback) -- 580
end -- 570
local function appendConversationMessage(shared, message) -- 590
	local ____shared_messages_6 = shared.messages -- 590
	____shared_messages_6[#____shared_messages_6 + 1] = __TS__ObjectAssign( -- 591
		{}, -- 591
		message, -- 592
		{ -- 591
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 593
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 594
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 595
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 596
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 597
		} -- 597
	) -- 597
end -- 590
local function ensureToolCallId(toolCallId) -- 601
	if toolCallId and toolCallId ~= "" then -- 601
		return toolCallId -- 602
	end -- 602
	return createLocalToolCallId() -- 603
end -- 601
local function appendToolResultMessage(shared, action) -- 606
	appendConversationMessage( -- 607
		shared, -- 607
		{ -- 607
			role = "tool", -- 608
			tool_call_id = action.toolCallId, -- 609
			name = action.tool, -- 610
			content = action.result and toJson(action.result) or "" -- 611
		} -- 611
	) -- 611
end -- 606
local function parseXMLToolCallObjectFromText(text) -- 615
	local children = parseXMLObjectFromText(text, "tool_call") -- 616
	if not children.success then -- 616
		return children -- 617
	end -- 617
	local rawObj = children.obj -- 618
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 619
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 620
	if not params.success then -- 620
		return {success = false, message = params.message} -- 624
	end -- 624
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 626
end -- 615
local function llm(shared, messages, phase) -- 645
	if phase == nil then -- 645
		phase = "decision_xml" -- 648
	end -- 648
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 648
		local stepId = shared.step + 1 -- 650
		saveStepLLMDebugInput( -- 651
			shared, -- 651
			stepId, -- 651
			phase, -- 651
			messages, -- 651
			shared.llmOptions -- 651
		) -- 651
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 652
		if res.success then -- 652
			local ____opt_11 = res.response.choices -- 652
			local ____opt_9 = ____opt_11 and ____opt_11[1] -- 652
			local ____opt_7 = ____opt_9 and ____opt_9.message -- 652
			local text = ____opt_7 and ____opt_7.content -- 654
			if text then -- 654
				saveStepLLMDebugOutput( -- 656
					shared, -- 656
					stepId, -- 656
					phase, -- 656
					text, -- 656
					{success = true} -- 656
				) -- 656
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 656
			else -- 656
				saveStepLLMDebugOutput( -- 659
					shared, -- 659
					stepId, -- 659
					phase, -- 659
					"empty LLM response", -- 659
					{success = false} -- 659
				) -- 659
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 659
			end -- 659
		else -- 659
			saveStepLLMDebugOutput( -- 663
				shared, -- 663
				stepId, -- 663
				phase, -- 663
				res.raw or res.message, -- 663
				{success = false} -- 663
			) -- 663
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 663
		end -- 663
	end) -- 663
end -- 645
local function parseDecisionObject(rawObj) -- 680
	if type(rawObj.tool) ~= "string" then -- 680
		return {success = false, message = "missing tool"} -- 681
	end -- 681
	local tool = rawObj.tool -- 682
	if not isKnownToolName(tool) then -- 682
		return {success = false, message = "unknown tool: " .. tool} -- 684
	end -- 684
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 686
	if tool ~= "finish" and (not reason or reason == "") then -- 686
		return {success = false, message = tool .. " requires top-level reason"} -- 690
	end -- 690
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 692
	return {success = true, tool = tool, params = params, reason = reason} -- 693
end -- 680
local function parseDecisionToolCall(functionName, rawObj) -- 701
	if not isKnownToolName(functionName) then -- 701
		return {success = false, message = "unknown tool: " .. functionName} -- 703
	end -- 703
	if rawObj == nil or rawObj == nil then -- 703
		return {success = true, tool = functionName, params = {}} -- 706
	end -- 706
	if type(rawObj) ~= "table" then -- 706
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 709
	end -- 709
	return {success = true, tool = functionName, params = rawObj} -- 711
end -- 701
local function getDecisionPath(params) -- 718
	if type(params.path) == "string" then -- 718
		return __TS__StringTrim(params.path) -- 719
	end -- 719
	if type(params.target_file) == "string" then -- 719
		return __TS__StringTrim(params.target_file) -- 720
	end -- 720
	return "" -- 721
end -- 718
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 724
	local num = __TS__Number(value) -- 725
	if not __TS__NumberIsFinite(num) then -- 725
		num = fallback -- 726
	end -- 726
	num = math.floor(num) -- 727
	if num < minValue then -- 727
		num = minValue -- 728
	end -- 728
	if maxValue ~= nil and num > maxValue then -- 728
		num = maxValue -- 729
	end -- 729
	return num -- 730
end -- 724
local function validateDecision(tool, params) -- 733
	if tool == "finish" then -- 733
		local message = getFinishMessage(params) -- 738
		if message == "" then -- 738
			return {success = false, message = "finish requires params.message"} -- 739
		end -- 739
		params.message = message -- 740
		return {success = true, params = params} -- 741
	end -- 741
	if tool == "read_file" then -- 741
		local path = getDecisionPath(params) -- 745
		if path == "" then -- 745
			return {success = false, message = "read_file requires path"} -- 746
		end -- 746
		params.path = path -- 747
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 748
		local ____params_endLine_13 = params.endLine -- 749
		if ____params_endLine_13 == nil then -- 749
			____params_endLine_13 = READ_FILE_DEFAULT_LIMIT -- 749
		end -- 749
		local endLineRaw = ____params_endLine_13 -- 749
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 750
		params.startLine = startLine -- 751
		params.endLine = endLine -- 752
		return {success = true, params = params} -- 753
	end -- 753
	if tool == "edit_file" then -- 753
		local path = getDecisionPath(params) -- 757
		if path == "" then -- 757
			return {success = false, message = "edit_file requires path"} -- 758
		end -- 758
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 759
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 760
		params.path = path -- 761
		params.old_str = oldStr -- 762
		params.new_str = newStr -- 763
		return {success = true, params = params} -- 764
	end -- 764
	if tool == "delete_file" then -- 764
		local targetFile = getDecisionPath(params) -- 768
		if targetFile == "" then -- 768
			return {success = false, message = "delete_file requires target_file"} -- 769
		end -- 769
		params.target_file = targetFile -- 770
		return {success = true, params = params} -- 771
	end -- 771
	if tool == "grep_files" then -- 771
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 775
		if pattern == "" then -- 775
			return {success = false, message = "grep_files requires pattern"} -- 776
		end -- 776
		params.pattern = pattern -- 777
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 778
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 779
		return {success = true, params = params} -- 780
	end -- 780
	if tool == "search_dora_api" then -- 780
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 784
		if pattern == "" then -- 784
			return {success = false, message = "search_dora_api requires pattern"} -- 785
		end -- 785
		params.pattern = pattern -- 786
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 787
		return {success = true, params = params} -- 788
	end -- 788
	if tool == "glob_files" then -- 788
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 792
		return {success = true, params = params} -- 793
	end -- 793
	if tool == "build" then -- 793
		local path = getDecisionPath(params) -- 797
		if path ~= "" then -- 797
			params.path = path -- 799
		end -- 799
		return {success = true, params = params} -- 801
	end -- 801
	return {success = true, params = params} -- 804
end -- 733
local function createFunctionToolSchema(name, description, properties, required) -- 807
	if required == nil then -- 807
		required = {} -- 811
	end -- 811
	local parameters = {type = "object", properties = properties} -- 813
	if #required > 0 then -- 813
		parameters.required = required -- 818
	end -- 818
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 820
end -- 807
local function buildDecisionToolSchema() -- 830
	return { -- 831
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Parameters: path, startLine(optional), endLine(optional). Line numbering starts with 1. startLine defaults to 1 and endLine defaults to 300.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "1-based starting line number. Defaults to 1."}, endLine = {type = "number", description = "1-based ending line number. Defaults to 300."}}, {"path"}), -- 832
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 842
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 852
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 860
			path = {type = "string", description = "Base directory or file path to search within."}, -- 864
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 865
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 866
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 867
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 868
			limit = {type = "number", description = "Maximum number of results to return."}, -- 869
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 870
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 871
		}, {"pattern"}), -- 871
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 875
		createFunctionToolSchema( -- 884
			"search_dora_api", -- 885
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 885
			{ -- 887
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 888
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 889
				programmingLanguage = {type = "string", enum = { -- 890
					"ts", -- 892
					"tsx", -- 892
					"lua", -- 892
					"yue", -- 892
					"teal", -- 892
					"tl", -- 892
					"wa" -- 892
				}, description = "Preferred language variant to search."}, -- 892
				limit = { -- 895
					type = "number", -- 895
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 895
				}, -- 895
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 896
			}, -- 896
			{"pattern"} -- 898
		), -- 898
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}) -- 900
	} -- 900
end -- 830
local function getUnconsolidatedMessages(shared) -- 928
	return __TS__ArraySlice(shared.messages, shared.memory.lastConsolidatedMessageIndex) -- 929
end -- 928
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 932
	if attempt == nil then -- 932
		attempt = 1 -- 932
	end -- 932
	local messages = { -- 933
		{ -- 934
			role = "system", -- 934
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 934
		}, -- 934
		table.unpack(getUnconsolidatedMessages(shared)) -- 935
	} -- 935
	if lastError and lastError ~= "" then -- 935
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 938
		messages[#messages + 1] = { -- 941
			role = "user", -- 942
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 943
		} -- 943
	end -- 943
	return messages -- 950
end -- 932
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 957
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 964
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 965
	local repairPrompt = replacePromptVars( -- 973
		shared.promptPack.xmlDecisionRepairPrompt, -- 973
		{ -- 973
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 974
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 975
			CANDIDATE_SECTION = candidateSection, -- 976
			LAST_ERROR = lastError, -- 977
			ATTEMPT = tostring(attempt) -- 978
		} -- 978
	) -- 978
	return {{role = "system", content = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only."}, {role = "user", content = repairPrompt}} -- 980
end -- 957
local function tryParseAndValidateDecision(rawText) -- 1002
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 1003
	if not parsed.success then -- 1003
		return {success = false, message = parsed.message, raw = rawText} -- 1005
	end -- 1005
	local decision = parseDecisionObject(parsed.obj) -- 1007
	if not decision.success then -- 1007
		return {success = false, message = decision.message, raw = rawText} -- 1009
	end -- 1009
	local validation = validateDecision(decision.tool, decision.params) -- 1011
	if not validation.success then -- 1011
		return {success = false, message = validation.message, raw = rawText} -- 1013
	end -- 1013
	decision.params = validation.params -- 1015
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 1016
	return decision -- 1017
end -- 1002
local function normalizeLineEndings(text) -- 1020
	local res = string.gsub(text, "\r\n", "\n") -- 1021
	res = string.gsub(res, "\r", "\n") -- 1022
	return res -- 1023
end -- 1020
local function countOccurrences(text, searchStr) -- 1026
	if searchStr == "" then -- 1026
		return 0 -- 1027
	end -- 1027
	local count = 0 -- 1028
	local pos = 0 -- 1029
	while true do -- 1029
		local idx = (string.find( -- 1031
			text, -- 1031
			searchStr, -- 1031
			math.max(pos + 1, 1), -- 1031
			true -- 1031
		) or 0) - 1 -- 1031
		if idx < 0 then -- 1031
			break -- 1032
		end -- 1032
		count = count + 1 -- 1033
		pos = idx + #searchStr -- 1034
	end -- 1034
	return count -- 1036
end -- 1026
local function replaceFirst(text, oldStr, newStr) -- 1039
	if oldStr == "" then -- 1039
		return text -- 1040
	end -- 1040
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 1041
	if idx < 0 then -- 1041
		return text -- 1042
	end -- 1042
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 1043
end -- 1039
local function splitLines(text) -- 1046
	return __TS__StringSplit(text, "\n") -- 1047
end -- 1046
local function getLeadingWhitespace(text) -- 1050
	local i = 0 -- 1051
	while i < #text do -- 1051
		local ch = __TS__StringAccess(text, i) -- 1053
		if ch ~= " " and ch ~= "\t" then -- 1053
			break -- 1054
		end -- 1054
		i = i + 1 -- 1055
	end -- 1055
	return __TS__StringSubstring(text, 0, i) -- 1057
end -- 1050
local function getCommonIndentPrefix(lines) -- 1060
	local common -- 1061
	do -- 1061
		local i = 0 -- 1062
		while i < #lines do -- 1062
			do -- 1062
				local line = lines[i + 1] -- 1063
				if __TS__StringTrim(line) == "" then -- 1063
					goto __continue180 -- 1064
				end -- 1064
				local indent = getLeadingWhitespace(line) -- 1065
				if common == nil then -- 1065
					common = indent -- 1067
					goto __continue180 -- 1068
				end -- 1068
				local j = 0 -- 1070
				local maxLen = math.min(#common, #indent) -- 1071
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 1071
					j = j + 1 -- 1073
				end -- 1073
				common = __TS__StringSubstring(common, 0, j) -- 1075
				if common == "" then -- 1075
					break -- 1076
				end -- 1076
			end -- 1076
			::__continue180:: -- 1076
			i = i + 1 -- 1062
		end -- 1062
	end -- 1062
	return common or "" -- 1078
end -- 1060
local function removeIndentPrefix(line, indent) -- 1081
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 1081
		return __TS__StringSubstring(line, #indent) -- 1083
	end -- 1083
	local lineIndent = getLeadingWhitespace(line) -- 1085
	local j = 0 -- 1086
	local maxLen = math.min(#lineIndent, #indent) -- 1087
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 1087
		j = j + 1 -- 1089
	end -- 1089
	return __TS__StringSubstring(line, j) -- 1091
end -- 1081
local function dedentLines(lines) -- 1094
	local indent = getCommonIndentPrefix(lines) -- 1095
	return { -- 1096
		indent = indent, -- 1097
		lines = __TS__ArrayMap( -- 1098
			lines, -- 1098
			function(____, line) return removeIndentPrefix(line, indent) end -- 1098
		) -- 1098
	} -- 1098
end -- 1094
local function joinLines(lines) -- 1102
	return table.concat(lines, "\n") -- 1103
end -- 1102
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 1106
	local contentLines = splitLines(content) -- 1111
	local oldLines = splitLines(oldStr) -- 1112
	if #oldLines == 0 then -- 1112
		return {success = false, message = "old_str not found in file"} -- 1114
	end -- 1114
	local dedentedOld = dedentLines(oldLines) -- 1116
	local dedentedOldText = joinLines(dedentedOld.lines) -- 1117
	local dedentedNew = dedentLines(splitLines(newStr)) -- 1118
	local matches = {} -- 1119
	do -- 1119
		local start = 0 -- 1120
		while start <= #contentLines - #oldLines do -- 1120
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 1121
			local dedentedCandidate = dedentLines(candidateLines) -- 1122
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 1122
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 1124
			end -- 1124
			start = start + 1 -- 1120
		end -- 1120
	end -- 1120
	if #matches == 0 then -- 1120
		return {success = false, message = "old_str not found in file"} -- 1132
	end -- 1132
	if #matches > 1 then -- 1132
		return { -- 1135
			success = false, -- 1136
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 1137
		} -- 1137
	end -- 1137
	local match = matches[1] -- 1140
	local rebuiltNewLines = __TS__ArrayMap( -- 1141
		dedentedNew.lines, -- 1141
		function(____, line) return line == "" and "" or match.indent .. line end -- 1141
	) -- 1141
	local ____array_14 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 1141
	__TS__SparseArrayPush( -- 1141
		____array_14, -- 1141
		table.unpack(rebuiltNewLines) -- 1144
	) -- 1144
	__TS__SparseArrayPush( -- 1144
		____array_14, -- 1144
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 1145
	) -- 1145
	local nextLines = {__TS__SparseArraySpread(____array_14)} -- 1142
	return { -- 1147
		success = true, -- 1147
		content = joinLines(nextLines) -- 1147
	} -- 1147
end -- 1106
local MainDecisionAgent = __TS__Class() -- 1150
MainDecisionAgent.name = "MainDecisionAgent" -- 1150
__TS__ClassExtends(MainDecisionAgent, Node) -- 1150
function MainDecisionAgent.prototype.prep(self, shared) -- 1151
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1151
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1151
			return ____awaiter_resolve(nil, {shared = shared}) -- 1151
		end -- 1151
		__TS__Await(maybeCompressHistory(shared)) -- 1156
		return ____awaiter_resolve(nil, {shared = shared}) -- 1156
	end) -- 1156
end -- 1151
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 1161
	if attempt == nil then -- 1161
		attempt = 1 -- 1164
	end -- 1164
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1164
		if shared.stopToken.stopped then -- 1164
			return ____awaiter_resolve( -- 1164
				nil, -- 1164
				{ -- 1168
					success = false, -- 1168
					message = getCancelledReason(shared) -- 1168
				} -- 1168
			) -- 1168
		end -- 1168
		Log( -- 1170
			"Info", -- 1170
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1170
		) -- 1170
		local tools = buildDecisionToolSchema() -- 1171
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1172
		local stepId = shared.step + 1 -- 1173
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1174
		saveStepLLMDebugInput( -- 1178
			shared, -- 1178
			stepId, -- 1178
			"decision_tool_calling", -- 1178
			messages, -- 1178
			llmOptions -- 1178
		) -- 1178
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1179
		if shared.stopToken.stopped then -- 1179
			return ____awaiter_resolve( -- 1179
				nil, -- 1179
				{ -- 1181
					success = false, -- 1181
					message = getCancelledReason(shared) -- 1181
				} -- 1181
			) -- 1181
		end -- 1181
		if not res.success then -- 1181
			saveStepLLMDebugOutput( -- 1184
				shared, -- 1184
				stepId, -- 1184
				"decision_tool_calling", -- 1184
				res.raw or res.message, -- 1184
				{success = false} -- 1184
			) -- 1184
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1185
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1185
		end -- 1185
		saveStepLLMDebugOutput( -- 1188
			shared, -- 1188
			stepId, -- 1188
			"decision_tool_calling", -- 1188
			encodeDebugJSON(res.response), -- 1188
			{success = true} -- 1188
		) -- 1188
		local choice = res.response.choices and res.response.choices[1] -- 1189
		local message = choice and choice.message -- 1190
		local toolCalls = message and message.tool_calls -- 1191
		local toolCall = toolCalls and toolCalls[1] -- 1192
		local fn = toolCall and toolCall["function"] -- 1193
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 1194
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1197
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1200
		Log( -- 1203
			"Info", -- 1203
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1203
		) -- 1203
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1203
			if messageContent and messageContent ~= "" then -- 1203
				Log( -- 1206
					"Info", -- 1206
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1206
				) -- 1206
				return ____awaiter_resolve(nil, { -- 1206
					success = true, -- 1208
					tool = "finish", -- 1209
					params = {}, -- 1210
					reason = messageContent, -- 1211
					reasoningContent = reasoningContent, -- 1212
					directSummary = messageContent -- 1213
				}) -- 1213
			end -- 1213
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1216
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1216
		end -- 1216
		local functionName = fn.name -- 1223
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1224
		Log( -- 1225
			"Info", -- 1225
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1225
		) -- 1225
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1226
			local rawObj, err = table.unpack( -- 1227
				safeJsonDecode(argsText), -- 1227
				1, -- 1227
				2 -- 1227
			) -- 1227
			if err ~= nil or rawObj == nil then -- 1227
				return {__error = tostring(err)} -- 1229
			end -- 1229
			return rawObj -- 1231
		end)() -- 1226
		if type(rawArgs) == "table" and rawArgs.__error ~= nil then -- 1226
			local err = tostring(rawArgs.__error) -- 1234
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1235
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1235
		end -- 1235
		p(rawArgs) -- 1242
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1243
		if not decision.success then -- 1243
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1245
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1245
		end -- 1245
		local validation = validateDecision(decision.tool, decision.params) -- 1252
		if not validation.success then -- 1252
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1254
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1254
		end -- 1254
		decision.params = validation.params -- 1261
		decision.toolCallId = ensureToolCallId(toolCallId) -- 1262
		decision.reason = messageContent -- 1263
		decision.reasoningContent = reasoningContent -- 1264
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1265
		return ____awaiter_resolve(nil, decision) -- 1265
	end) -- 1265
end -- 1161
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 1269
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1269
		Log( -- 1274
			"Info", -- 1274
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 1274
		) -- 1274
		local lastError = initialError -- 1275
		local candidateRaw = "" -- 1276
		do -- 1276
			local attempt = 0 -- 1277
			while attempt < shared.llmMaxTry do -- 1277
				do -- 1277
					Log( -- 1278
						"Info", -- 1278
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 1278
					) -- 1278
					local messages = buildXmlRepairMessages( -- 1279
						shared, -- 1280
						originalRaw, -- 1281
						candidateRaw, -- 1282
						lastError, -- 1283
						attempt + 1 -- 1284
					) -- 1284
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 1286
					if shared.stopToken.stopped then -- 1286
						return ____awaiter_resolve( -- 1286
							nil, -- 1286
							{ -- 1288
								success = false, -- 1288
								message = getCancelledReason(shared) -- 1288
							} -- 1288
						) -- 1288
					end -- 1288
					if not llmRes.success then -- 1288
						lastError = llmRes.message -- 1291
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 1292
						goto __continue214 -- 1293
					end -- 1293
					candidateRaw = llmRes.text -- 1295
					local decision = tryParseAndValidateDecision(candidateRaw) -- 1296
					if decision.success then -- 1296
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 1298
						return ____awaiter_resolve(nil, decision) -- 1298
					end -- 1298
					lastError = decision.message -- 1301
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 1302
				end -- 1302
				::__continue214:: -- 1302
				attempt = attempt + 1 -- 1277
			end -- 1277
		end -- 1277
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 1304
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 1304
	end) -- 1304
end -- 1269
function MainDecisionAgent.prototype.exec(self, input) -- 1312
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1312
		local shared = input.shared -- 1313
		if shared.stopToken.stopped then -- 1313
			return ____awaiter_resolve( -- 1313
				nil, -- 1313
				{ -- 1315
					success = false, -- 1315
					message = getCancelledReason(shared) -- 1315
				} -- 1315
			) -- 1315
		end -- 1315
		if shared.step >= shared.maxSteps then -- 1315
			Log( -- 1318
				"Warn", -- 1318
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1318
			) -- 1318
			return ____awaiter_resolve( -- 1318
				nil, -- 1318
				{ -- 1319
					success = false, -- 1319
					message = getMaxStepsReachedReason(shared) -- 1319
				} -- 1319
			) -- 1319
		end -- 1319
		if shared.decisionMode == "tool_calling" then -- 1319
			Log( -- 1323
				"Info", -- 1323
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 1323
			) -- 1323
			local lastError = "tool calling validation failed" -- 1324
			local lastRaw = "" -- 1325
			do -- 1325
				local attempt = 0 -- 1326
				while attempt < shared.llmMaxTry do -- 1326
					Log( -- 1327
						"Info", -- 1327
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1327
					) -- 1327
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 1328
					if shared.stopToken.stopped then -- 1328
						return ____awaiter_resolve( -- 1328
							nil, -- 1328
							{ -- 1335
								success = false, -- 1335
								message = getCancelledReason(shared) -- 1335
							} -- 1335
						) -- 1335
					end -- 1335
					if decision.success then -- 1335
						return ____awaiter_resolve(nil, decision) -- 1335
					end -- 1335
					lastError = decision.message -- 1340
					lastRaw = decision.raw or "" -- 1341
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1342
					attempt = attempt + 1 -- 1326
				end -- 1326
			end -- 1326
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1344
			return ____awaiter_resolve( -- 1344
				nil, -- 1344
				{ -- 1345
					success = false, -- 1345
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1345
				} -- 1345
			) -- 1345
		end -- 1345
		local lastError = "xml validation failed" -- 1348
		local lastRaw = "" -- 1349
		do -- 1349
			local attempt = 0 -- 1350
			while attempt < shared.llmMaxTry do -- 1350
				do -- 1350
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 1351
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 1359
					if shared.stopToken.stopped then -- 1359
						return ____awaiter_resolve( -- 1359
							nil, -- 1359
							{ -- 1361
								success = false, -- 1361
								message = getCancelledReason(shared) -- 1361
							} -- 1361
						) -- 1361
					end -- 1361
					if not llmRes.success then -- 1361
						lastError = llmRes.message -- 1364
						lastRaw = llmRes.text or "" -- 1365
						goto __continue227 -- 1366
					end -- 1366
					lastRaw = llmRes.text -- 1368
					local decision = tryParseAndValidateDecision(llmRes.text) -- 1369
					if decision.success then -- 1369
						return ____awaiter_resolve(nil, decision) -- 1369
					end -- 1369
					lastError = decision.message -- 1373
					return ____awaiter_resolve( -- 1373
						nil, -- 1373
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 1374
					) -- 1374
				end -- 1374
				::__continue227:: -- 1374
				attempt = attempt + 1 -- 1350
			end -- 1350
		end -- 1350
		return ____awaiter_resolve( -- 1350
			nil, -- 1350
			{ -- 1376
				success = false, -- 1376
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1376
			} -- 1376
		) -- 1376
	end) -- 1376
end -- 1312
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1379
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1379
		local result = execRes -- 1380
		if not result.success then -- 1380
			shared.error = result.message -- 1382
			shared.response = getFailureSummaryFallback(shared, result.message) -- 1383
			shared.done = true -- 1384
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 1385
			persistHistoryState(shared) -- 1389
			return ____awaiter_resolve(nil, "done") -- 1389
		end -- 1389
		if result.directSummary and result.directSummary ~= "" then -- 1389
			shared.response = result.directSummary -- 1393
			shared.done = true -- 1394
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 1395
			persistHistoryState(shared) -- 1400
			return ____awaiter_resolve(nil, "done") -- 1400
		end -- 1400
		if result.tool == "finish" then -- 1400
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 1404
			shared.response = finalMessage -- 1405
			shared.done = true -- 1406
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 1407
			persistHistoryState(shared) -- 1412
			return ____awaiter_resolve(nil, "done") -- 1412
		end -- 1412
		emitAgentEvent(shared, { -- 1415
			type = "decision_made", -- 1416
			sessionId = shared.sessionId, -- 1417
			taskId = shared.taskId, -- 1418
			step = shared.step + 1, -- 1419
			tool = result.tool, -- 1420
			reason = result.reason, -- 1421
			reasoningContent = result.reasoningContent, -- 1422
			params = result.params -- 1423
		}) -- 1423
		local toolCallId = ensureToolCallId(result.toolCallId) -- 1425
		local ____shared_history_15 = shared.history -- 1425
		____shared_history_15[#____shared_history_15 + 1] = { -- 1426
			step = #shared.history + 1, -- 1427
			toolCallId = toolCallId, -- 1428
			tool = result.tool, -- 1429
			reason = result.reason or "", -- 1430
			reasoningContent = result.reasoningContent, -- 1431
			params = result.params, -- 1432
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1433
		} -- 1433
		appendConversationMessage( -- 1435
			shared, -- 1435
			{ -- 1435
				role = "assistant", -- 1436
				content = result.reason or "", -- 1437
				reasoning_content = result.reasoningContent, -- 1438
				tool_calls = {{ -- 1439
					id = toolCallId, -- 1440
					type = "function", -- 1441
					["function"] = { -- 1442
						name = result.tool, -- 1443
						arguments = toJson(result.params) -- 1444
					} -- 1444
				}} -- 1444
			} -- 1444
		) -- 1444
		persistHistoryState(shared) -- 1448
		return ____awaiter_resolve(nil, result.tool) -- 1448
	end) -- 1448
end -- 1379
local ReadFileAction = __TS__Class() -- 1453
ReadFileAction.name = "ReadFileAction" -- 1453
__TS__ClassExtends(ReadFileAction, Node) -- 1453
function ReadFileAction.prototype.prep(self, shared) -- 1454
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1454
		local last = shared.history[#shared.history] -- 1455
		if not last then -- 1455
			error( -- 1456
				__TS__New(Error, "no history"), -- 1456
				0 -- 1456
			) -- 1456
		end -- 1456
		emitAgentEvent(shared, { -- 1457
			type = "tool_started", -- 1458
			sessionId = shared.sessionId, -- 1459
			taskId = shared.taskId, -- 1460
			step = shared.step + 1, -- 1461
			tool = last.tool -- 1462
		}) -- 1462
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1464
		if __TS__StringTrim(path) == "" then -- 1464
			error( -- 1467
				__TS__New(Error, "missing path"), -- 1467
				0 -- 1467
			) -- 1467
		end -- 1467
		local ____path_18 = path -- 1469
		local ____shared_workingDir_19 = shared.workingDir -- 1471
		local ____temp_20 = shared.useChineseResponse and "zh" or "en" -- 1472
		local ____last_params_startLine_16 = last.params.startLine -- 1473
		if ____last_params_startLine_16 == nil then -- 1473
			____last_params_startLine_16 = 1 -- 1473
		end -- 1473
		local ____TS__Number_result_21 = __TS__Number(____last_params_startLine_16) -- 1473
		local ____last_params_endLine_17 = last.params.endLine -- 1474
		if ____last_params_endLine_17 == nil then -- 1474
			____last_params_endLine_17 = READ_FILE_DEFAULT_LIMIT -- 1474
		end -- 1474
		return ____awaiter_resolve( -- 1474
			nil, -- 1474
			{ -- 1468
				path = ____path_18, -- 1469
				tool = "read_file", -- 1470
				workDir = ____shared_workingDir_19, -- 1471
				docLanguage = ____temp_20, -- 1472
				startLine = ____TS__Number_result_21, -- 1473
				endLine = __TS__Number(____last_params_endLine_17) -- 1474
			} -- 1474
		) -- 1474
	end) -- 1474
end -- 1454
function ReadFileAction.prototype.exec(self, input) -- 1478
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1478
		return ____awaiter_resolve( -- 1478
			nil, -- 1478
			Tools.readFile( -- 1479
				input.workDir, -- 1480
				input.path, -- 1481
				__TS__Number(input.startLine or 1), -- 1482
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1483
				input.docLanguage -- 1484
			) -- 1484
		) -- 1484
	end) -- 1484
end -- 1478
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1488
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1488
		local result = execRes -- 1489
		local last = shared.history[#shared.history] -- 1490
		if last ~= nil then -- 1490
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1492
			appendToolResultMessage(shared, last) -- 1493
			emitAgentEvent(shared, { -- 1494
				type = "tool_finished", -- 1495
				sessionId = shared.sessionId, -- 1496
				taskId = shared.taskId, -- 1497
				step = shared.step + 1, -- 1498
				tool = last.tool, -- 1499
				result = last.result -- 1500
			}) -- 1500
		end -- 1500
		__TS__Await(maybeCompressHistory(shared)) -- 1503
		persistHistoryState(shared) -- 1504
		shared.step = shared.step + 1 -- 1505
		return ____awaiter_resolve(nil, "main") -- 1505
	end) -- 1505
end -- 1488
local SearchFilesAction = __TS__Class() -- 1510
SearchFilesAction.name = "SearchFilesAction" -- 1510
__TS__ClassExtends(SearchFilesAction, Node) -- 1510
function SearchFilesAction.prototype.prep(self, shared) -- 1511
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1511
		local last = shared.history[#shared.history] -- 1512
		if not last then -- 1512
			error( -- 1513
				__TS__New(Error, "no history"), -- 1513
				0 -- 1513
			) -- 1513
		end -- 1513
		emitAgentEvent(shared, { -- 1514
			type = "tool_started", -- 1515
			sessionId = shared.sessionId, -- 1516
			taskId = shared.taskId, -- 1517
			step = shared.step + 1, -- 1518
			tool = last.tool -- 1519
		}) -- 1519
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1519
	end) -- 1519
end -- 1511
function SearchFilesAction.prototype.exec(self, input) -- 1524
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1524
		local params = input.params -- 1525
		local ____Tools_searchFiles_35 = Tools.searchFiles -- 1526
		local ____input_workDir_28 = input.workDir -- 1527
		local ____temp_29 = params.path or "" -- 1528
		local ____temp_30 = params.pattern or "" -- 1529
		local ____params_globs_31 = params.globs -- 1530
		local ____params_useRegex_32 = params.useRegex -- 1531
		local ____params_caseSensitive_33 = params.caseSensitive -- 1532
		local ____math_max_24 = math.max -- 1535
		local ____math_floor_23 = math.floor -- 1535
		local ____params_limit_22 = params.limit -- 1535
		if ____params_limit_22 == nil then -- 1535
			____params_limit_22 = SEARCH_FILES_LIMIT_DEFAULT -- 1535
		end -- 1535
		local ____math_max_24_result_34 = ____math_max_24( -- 1535
			1, -- 1535
			____math_floor_23(__TS__Number(____params_limit_22)) -- 1535
		) -- 1535
		local ____math_max_27 = math.max -- 1536
		local ____math_floor_26 = math.floor -- 1536
		local ____params_offset_25 = params.offset -- 1536
		if ____params_offset_25 == nil then -- 1536
			____params_offset_25 = 0 -- 1536
		end -- 1536
		local result = __TS__Await(____Tools_searchFiles_35({ -- 1526
			workDir = ____input_workDir_28, -- 1527
			path = ____temp_29, -- 1528
			pattern = ____temp_30, -- 1529
			globs = ____params_globs_31, -- 1530
			useRegex = ____params_useRegex_32, -- 1531
			caseSensitive = ____params_caseSensitive_33, -- 1532
			includeContent = true, -- 1533
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1534
			limit = ____math_max_24_result_34, -- 1535
			offset = ____math_max_27( -- 1536
				0, -- 1536
				____math_floor_26(__TS__Number(____params_offset_25)) -- 1536
			), -- 1536
			groupByFile = params.groupByFile == true -- 1537
		})) -- 1537
		return ____awaiter_resolve(nil, result) -- 1537
	end) -- 1537
end -- 1524
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1542
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1542
		local last = shared.history[#shared.history] -- 1543
		if last ~= nil then -- 1543
			local result = execRes -- 1545
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1546
			appendToolResultMessage(shared, last) -- 1547
			emitAgentEvent(shared, { -- 1548
				type = "tool_finished", -- 1549
				sessionId = shared.sessionId, -- 1550
				taskId = shared.taskId, -- 1551
				step = shared.step + 1, -- 1552
				tool = last.tool, -- 1553
				result = last.result -- 1554
			}) -- 1554
		end -- 1554
		__TS__Await(maybeCompressHistory(shared)) -- 1557
		persistHistoryState(shared) -- 1558
		shared.step = shared.step + 1 -- 1559
		return ____awaiter_resolve(nil, "main") -- 1559
	end) -- 1559
end -- 1542
local SearchDoraAPIAction = __TS__Class() -- 1564
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1564
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1564
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1565
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1565
		local last = shared.history[#shared.history] -- 1566
		if not last then -- 1566
			error( -- 1567
				__TS__New(Error, "no history"), -- 1567
				0 -- 1567
			) -- 1567
		end -- 1567
		emitAgentEvent(shared, { -- 1568
			type = "tool_started", -- 1569
			sessionId = shared.sessionId, -- 1570
			taskId = shared.taskId, -- 1571
			step = shared.step + 1, -- 1572
			tool = last.tool -- 1573
		}) -- 1573
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1573
	end) -- 1573
end -- 1565
function SearchDoraAPIAction.prototype.exec(self, input) -- 1578
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1578
		local params = input.params -- 1579
		local ____Tools_searchDoraAPI_43 = Tools.searchDoraAPI -- 1580
		local ____temp_39 = params.pattern or "" -- 1581
		local ____temp_40 = params.docSource or "api" -- 1582
		local ____temp_41 = input.useChineseResponse and "zh" or "en" -- 1583
		local ____temp_42 = params.programmingLanguage or "ts" -- 1584
		local ____math_min_38 = math.min -- 1585
		local ____math_max_37 = math.max -- 1585
		local ____params_limit_36 = params.limit -- 1585
		if ____params_limit_36 == nil then -- 1585
			____params_limit_36 = 8 -- 1585
		end -- 1585
		local result = __TS__Await(____Tools_searchDoraAPI_43({ -- 1580
			pattern = ____temp_39, -- 1581
			docSource = ____temp_40, -- 1582
			docLanguage = ____temp_41, -- 1583
			programmingLanguage = ____temp_42, -- 1584
			limit = ____math_min_38( -- 1585
				SEARCH_DORA_API_LIMIT_MAX, -- 1585
				____math_max_37( -- 1585
					1, -- 1585
					__TS__Number(____params_limit_36) -- 1585
				) -- 1585
			), -- 1585
			useRegex = params.useRegex, -- 1586
			caseSensitive = false, -- 1587
			includeContent = true, -- 1588
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1589
		})) -- 1589
		return ____awaiter_resolve(nil, result) -- 1589
	end) -- 1589
end -- 1578
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1594
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1594
		local last = shared.history[#shared.history] -- 1595
		if last ~= nil then -- 1595
			local result = execRes -- 1597
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1598
			appendToolResultMessage(shared, last) -- 1599
			emitAgentEvent(shared, { -- 1600
				type = "tool_finished", -- 1601
				sessionId = shared.sessionId, -- 1602
				taskId = shared.taskId, -- 1603
				step = shared.step + 1, -- 1604
				tool = last.tool, -- 1605
				result = last.result -- 1606
			}) -- 1606
		end -- 1606
		__TS__Await(maybeCompressHistory(shared)) -- 1609
		persistHistoryState(shared) -- 1610
		shared.step = shared.step + 1 -- 1611
		return ____awaiter_resolve(nil, "main") -- 1611
	end) -- 1611
end -- 1594
local ListFilesAction = __TS__Class() -- 1616
ListFilesAction.name = "ListFilesAction" -- 1616
__TS__ClassExtends(ListFilesAction, Node) -- 1616
function ListFilesAction.prototype.prep(self, shared) -- 1617
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1617
		local last = shared.history[#shared.history] -- 1618
		if not last then -- 1618
			error( -- 1619
				__TS__New(Error, "no history"), -- 1619
				0 -- 1619
			) -- 1619
		end -- 1619
		emitAgentEvent(shared, { -- 1620
			type = "tool_started", -- 1621
			sessionId = shared.sessionId, -- 1622
			taskId = shared.taskId, -- 1623
			step = shared.step + 1, -- 1624
			tool = last.tool -- 1625
		}) -- 1625
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1625
	end) -- 1625
end -- 1617
function ListFilesAction.prototype.exec(self, input) -- 1630
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1630
		local params = input.params -- 1631
		local ____Tools_listFiles_50 = Tools.listFiles -- 1632
		local ____input_workDir_47 = input.workDir -- 1633
		local ____temp_48 = params.path or "" -- 1634
		local ____params_globs_49 = params.globs -- 1635
		local ____math_max_46 = math.max -- 1636
		local ____math_floor_45 = math.floor -- 1636
		local ____params_maxEntries_44 = params.maxEntries -- 1636
		if ____params_maxEntries_44 == nil then -- 1636
			____params_maxEntries_44 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1636
		end -- 1636
		local result = ____Tools_listFiles_50({ -- 1632
			workDir = ____input_workDir_47, -- 1633
			path = ____temp_48, -- 1634
			globs = ____params_globs_49, -- 1635
			maxEntries = ____math_max_46( -- 1636
				1, -- 1636
				____math_floor_45(__TS__Number(____params_maxEntries_44)) -- 1636
			) -- 1636
		}) -- 1636
		return ____awaiter_resolve(nil, result) -- 1636
	end) -- 1636
end -- 1630
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1641
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1641
		local last = shared.history[#shared.history] -- 1642
		if last ~= nil then -- 1642
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1644
			appendToolResultMessage(shared, last) -- 1645
			emitAgentEvent(shared, { -- 1646
				type = "tool_finished", -- 1647
				sessionId = shared.sessionId, -- 1648
				taskId = shared.taskId, -- 1649
				step = shared.step + 1, -- 1650
				tool = last.tool, -- 1651
				result = last.result -- 1652
			}) -- 1652
		end -- 1652
		__TS__Await(maybeCompressHistory(shared)) -- 1655
		persistHistoryState(shared) -- 1656
		shared.step = shared.step + 1 -- 1657
		return ____awaiter_resolve(nil, "main") -- 1657
	end) -- 1657
end -- 1641
local DeleteFileAction = __TS__Class() -- 1662
DeleteFileAction.name = "DeleteFileAction" -- 1662
__TS__ClassExtends(DeleteFileAction, Node) -- 1662
function DeleteFileAction.prototype.prep(self, shared) -- 1663
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1663
		local last = shared.history[#shared.history] -- 1664
		if not last then -- 1664
			error( -- 1665
				__TS__New(Error, "no history"), -- 1665
				0 -- 1665
			) -- 1665
		end -- 1665
		emitAgentEvent(shared, { -- 1666
			type = "tool_started", -- 1667
			sessionId = shared.sessionId, -- 1668
			taskId = shared.taskId, -- 1669
			step = shared.step + 1, -- 1670
			tool = last.tool -- 1671
		}) -- 1671
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1673
		if __TS__StringTrim(targetFile) == "" then -- 1673
			error( -- 1676
				__TS__New(Error, "missing target_file"), -- 1676
				0 -- 1676
			) -- 1676
		end -- 1676
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1676
	end) -- 1676
end -- 1663
function DeleteFileAction.prototype.exec(self, input) -- 1680
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1680
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1681
		if not result.success then -- 1681
			return ____awaiter_resolve(nil, result) -- 1681
		end -- 1681
		return ____awaiter_resolve(nil, { -- 1681
			success = true, -- 1689
			changed = true, -- 1690
			mode = "delete", -- 1691
			checkpointId = result.checkpointId, -- 1692
			checkpointSeq = result.checkpointSeq, -- 1693
			files = {{path = input.targetFile, op = "delete"}} -- 1694
		}) -- 1694
	end) -- 1694
end -- 1680
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1698
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1698
		local last = shared.history[#shared.history] -- 1699
		if last ~= nil then -- 1699
			last.result = execRes -- 1701
			appendToolResultMessage(shared, last) -- 1702
			emitAgentEvent(shared, { -- 1703
				type = "tool_finished", -- 1704
				sessionId = shared.sessionId, -- 1705
				taskId = shared.taskId, -- 1706
				step = shared.step + 1, -- 1707
				tool = last.tool, -- 1708
				result = last.result -- 1709
			}) -- 1709
			local result = last.result -- 1711
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1711
				emitAgentEvent(shared, { -- 1716
					type = "checkpoint_created", -- 1717
					sessionId = shared.sessionId, -- 1718
					taskId = shared.taskId, -- 1719
					step = shared.step + 1, -- 1720
					tool = "delete_file", -- 1721
					checkpointId = result.checkpointId, -- 1722
					checkpointSeq = result.checkpointSeq, -- 1723
					files = result.files -- 1724
				}) -- 1724
			end -- 1724
		end -- 1724
		__TS__Await(maybeCompressHistory(shared)) -- 1728
		persistHistoryState(shared) -- 1729
		shared.step = shared.step + 1 -- 1730
		return ____awaiter_resolve(nil, "main") -- 1730
	end) -- 1730
end -- 1698
local BuildAction = __TS__Class() -- 1735
BuildAction.name = "BuildAction" -- 1735
__TS__ClassExtends(BuildAction, Node) -- 1735
function BuildAction.prototype.prep(self, shared) -- 1736
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1736
		local last = shared.history[#shared.history] -- 1737
		if not last then -- 1737
			error( -- 1738
				__TS__New(Error, "no history"), -- 1738
				0 -- 1738
			) -- 1738
		end -- 1738
		emitAgentEvent(shared, { -- 1739
			type = "tool_started", -- 1740
			sessionId = shared.sessionId, -- 1741
			taskId = shared.taskId, -- 1742
			step = shared.step + 1, -- 1743
			tool = last.tool -- 1744
		}) -- 1744
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1744
	end) -- 1744
end -- 1736
function BuildAction.prototype.exec(self, input) -- 1749
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1749
		local params = input.params -- 1750
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1751
		return ____awaiter_resolve(nil, result) -- 1751
	end) -- 1751
end -- 1749
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1758
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1758
		local last = shared.history[#shared.history] -- 1759
		if last ~= nil then -- 1759
			last.result = execRes -- 1761
			appendToolResultMessage(shared, last) -- 1762
			emitAgentEvent(shared, { -- 1763
				type = "tool_finished", -- 1764
				sessionId = shared.sessionId, -- 1765
				taskId = shared.taskId, -- 1766
				step = shared.step + 1, -- 1767
				tool = last.tool, -- 1768
				result = last.result -- 1769
			}) -- 1769
		end -- 1769
		__TS__Await(maybeCompressHistory(shared)) -- 1772
		persistHistoryState(shared) -- 1773
		shared.step = shared.step + 1 -- 1774
		return ____awaiter_resolve(nil, "main") -- 1774
	end) -- 1774
end -- 1758
local EditFileAction = __TS__Class() -- 1779
EditFileAction.name = "EditFileAction" -- 1779
__TS__ClassExtends(EditFileAction, Node) -- 1779
function EditFileAction.prototype.prep(self, shared) -- 1780
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1780
		local last = shared.history[#shared.history] -- 1781
		if not last then -- 1781
			error( -- 1782
				__TS__New(Error, "no history"), -- 1782
				0 -- 1782
			) -- 1782
		end -- 1782
		emitAgentEvent(shared, { -- 1783
			type = "tool_started", -- 1784
			sessionId = shared.sessionId, -- 1785
			taskId = shared.taskId, -- 1786
			step = shared.step + 1, -- 1787
			tool = last.tool -- 1788
		}) -- 1788
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1790
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1793
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1794
		if __TS__StringTrim(path) == "" then -- 1794
			error( -- 1795
				__TS__New(Error, "missing path"), -- 1795
				0 -- 1795
			) -- 1795
		end -- 1795
		return ____awaiter_resolve(nil, { -- 1795
			path = path, -- 1796
			oldStr = oldStr, -- 1796
			newStr = newStr, -- 1796
			taskId = shared.taskId, -- 1796
			workDir = shared.workingDir -- 1796
		}) -- 1796
	end) -- 1796
end -- 1780
function EditFileAction.prototype.exec(self, input) -- 1799
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1799
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1800
		if not readRes.success then -- 1800
			if input.oldStr ~= "" then -- 1800
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1800
			end -- 1800
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1805
			if not createRes.success then -- 1805
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1805
			end -- 1805
			return ____awaiter_resolve(nil, { -- 1805
				success = true, -- 1813
				changed = true, -- 1814
				mode = "create", -- 1815
				checkpointId = createRes.checkpointId, -- 1816
				checkpointSeq = createRes.checkpointSeq, -- 1817
				files = {{path = input.path, op = "create"}} -- 1818
			}) -- 1818
		end -- 1818
		if input.oldStr == "" then -- 1818
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1822
			if not overwriteRes.success then -- 1822
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 1822
			end -- 1822
			return ____awaiter_resolve(nil, { -- 1822
				success = true, -- 1830
				changed = true, -- 1831
				mode = "overwrite", -- 1832
				checkpointId = overwriteRes.checkpointId, -- 1833
				checkpointSeq = overwriteRes.checkpointSeq, -- 1834
				files = {{path = input.path, op = "write"}} -- 1835
			}) -- 1835
		end -- 1835
		local normalizedContent = normalizeLineEndings(readRes.content) -- 1840
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 1841
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 1842
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 1845
		if occurrences == 0 then -- 1845
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 1847
			if not indentTolerant.success then -- 1847
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 1847
			end -- 1847
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 1851
			if not applyRes.success then -- 1851
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1851
			end -- 1851
			return ____awaiter_resolve(nil, { -- 1851
				success = true, -- 1859
				changed = true, -- 1860
				mode = "replace_indent_tolerant", -- 1861
				checkpointId = applyRes.checkpointId, -- 1862
				checkpointSeq = applyRes.checkpointSeq, -- 1863
				files = {{path = input.path, op = "write"}} -- 1864
			}) -- 1864
		end -- 1864
		if occurrences > 1 then -- 1864
			return ____awaiter_resolve( -- 1864
				nil, -- 1864
				{ -- 1868
					success = false, -- 1868
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 1868
				} -- 1868
			) -- 1868
		end -- 1868
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 1872
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1873
		if not applyRes.success then -- 1873
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1873
		end -- 1873
		return ____awaiter_resolve(nil, { -- 1873
			success = true, -- 1881
			changed = true, -- 1882
			mode = "replace", -- 1883
			checkpointId = applyRes.checkpointId, -- 1884
			checkpointSeq = applyRes.checkpointSeq, -- 1885
			files = {{path = input.path, op = "write"}} -- 1886
		}) -- 1886
	end) -- 1886
end -- 1799
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1890
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1890
		local last = shared.history[#shared.history] -- 1891
		if last ~= nil then -- 1891
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1893
			last.result = execRes -- 1894
			appendToolResultMessage(shared, last) -- 1895
			emitAgentEvent(shared, { -- 1896
				type = "tool_finished", -- 1897
				sessionId = shared.sessionId, -- 1898
				taskId = shared.taskId, -- 1899
				step = shared.step + 1, -- 1900
				tool = last.tool, -- 1901
				result = last.result -- 1902
			}) -- 1902
			local result = last.result -- 1904
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and __TS__ArrayIsArray(result.files) then -- 1904
				emitAgentEvent(shared, { -- 1909
					type = "checkpoint_created", -- 1910
					sessionId = shared.sessionId, -- 1911
					taskId = shared.taskId, -- 1912
					step = shared.step + 1, -- 1913
					tool = last.tool, -- 1914
					checkpointId = result.checkpointId, -- 1915
					checkpointSeq = result.checkpointSeq, -- 1916
					files = result.files -- 1917
				}) -- 1917
			end -- 1917
		end -- 1917
		__TS__Await(maybeCompressHistory(shared)) -- 1921
		persistHistoryState(shared) -- 1922
		shared.step = shared.step + 1 -- 1923
		return ____awaiter_resolve(nil, "main") -- 1923
	end) -- 1923
end -- 1890
local EndNode = __TS__Class() -- 1928
EndNode.name = "EndNode" -- 1928
__TS__ClassExtends(EndNode, Node) -- 1928
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 1929
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1929
		return ____awaiter_resolve(nil, nil) -- 1929
	end) -- 1929
end -- 1929
local CodingAgentFlow = __TS__Class() -- 1934
CodingAgentFlow.name = "CodingAgentFlow" -- 1934
__TS__ClassExtends(CodingAgentFlow, Flow) -- 1934
function CodingAgentFlow.prototype.____constructor(self) -- 1935
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 1936
	local read = __TS__New(ReadFileAction, 1, 0) -- 1937
	local search = __TS__New(SearchFilesAction, 1, 0) -- 1938
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 1939
	local list = __TS__New(ListFilesAction, 1, 0) -- 1940
	local del = __TS__New(DeleteFileAction, 1, 0) -- 1941
	local build = __TS__New(BuildAction, 1, 0) -- 1942
	local edit = __TS__New(EditFileAction, 1, 0) -- 1943
	local done = __TS__New(EndNode, 1, 0) -- 1944
	main:on("read_file", read) -- 1946
	main:on("grep_files", search) -- 1947
	main:on("search_dora_api", searchDora) -- 1948
	main:on("glob_files", list) -- 1949
	main:on("delete_file", del) -- 1950
	main:on("build", build) -- 1951
	main:on("edit_file", edit) -- 1952
	main:on("done", done) -- 1953
	read:on("main", main) -- 1955
	search:on("main", main) -- 1956
	searchDora:on("main", main) -- 1957
	list:on("main", main) -- 1958
	del:on("main", main) -- 1959
	build:on("main", main) -- 1960
	edit:on("main", main) -- 1961
	Flow.prototype.____constructor(self, main) -- 1963
end -- 1935
local function runCodingAgentAsync(options) -- 1967
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1967
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 1967
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 1967
		end -- 1967
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 1971
		if not llmConfigRes.success then -- 1971
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 1971
		end -- 1971
		local llmConfig = llmConfigRes.config -- 1977
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 1978
		if not taskRes.success then -- 1978
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 1978
		end -- 1978
		local compressor = __TS__New(MemoryCompressor, { -- 1985
			compressionThreshold = 0.8, -- 1986
			maxCompressionRounds = 3, -- 1987
			maxTokensPerCompression = 20000, -- 1988
			projectDir = options.workDir, -- 1989
			llmConfig = llmConfig, -- 1990
			promptPack = options.promptPack -- 1991
		}) -- 1991
		local persistedSession = compressor:getStorage():readSessionState() -- 1993
		local promptPack = compressor:getPromptPack() -- 1994
		local shared = { -- 1996
			sessionId = options.sessionId, -- 1997
			taskId = taskRes.taskId, -- 1998
			maxSteps = math.max( -- 1999
				1, -- 1999
				math.floor(options.maxSteps or 40) -- 1999
			), -- 1999
			llmMaxTry = math.max( -- 2000
				1, -- 2000
				math.floor(options.llmMaxTry or 3) -- 2000
			), -- 2000
			step = 0, -- 2001
			done = false, -- 2002
			stopToken = options.stopToken or ({stopped = false}), -- 2003
			response = "", -- 2004
			userQuery = options.prompt, -- 2005
			workingDir = options.workDir, -- 2006
			useChineseResponse = options.useChineseResponse == true, -- 2007
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 2008
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 2011
			llmConfig = llmConfig, -- 2016
			onEvent = options.onEvent, -- 2017
			promptPack = promptPack, -- 2018
			history = {}, -- 2019
			messages = persistedSession.messages, -- 2020
			memory = {lastConsolidatedMessageIndex = persistedSession.lastConsolidatedMessageIndex, compressor = compressor} -- 2022
		} -- 2022
		appendConversationMessage(shared, {role = "user", content = options.prompt}) -- 2027
		persistHistoryState(shared) -- 2031
		local ____try = __TS__AsyncAwaiter(function() -- 2031
			emitAgentEvent(shared, { -- 2034
				type = "task_started", -- 2035
				sessionId = shared.sessionId, -- 2036
				taskId = shared.taskId, -- 2037
				prompt = shared.userQuery, -- 2038
				workDir = shared.workingDir, -- 2039
				maxSteps = shared.maxSteps -- 2040
			}) -- 2040
			if shared.stopToken.stopped then -- 2040
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2043
				local result = { -- 2044
					success = false, -- 2044
					taskId = shared.taskId, -- 2044
					message = getCancelledReason(shared), -- 2044
					steps = shared.step -- 2044
				} -- 2044
				emitAgentEvent(shared, { -- 2045
					type = "task_finished", -- 2046
					sessionId = shared.sessionId, -- 2047
					taskId = shared.taskId, -- 2048
					success = false, -- 2049
					message = result.message, -- 2050
					steps = result.steps -- 2051
				}) -- 2051
				return ____awaiter_resolve(nil, result) -- 2051
			end -- 2051
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 2055
			local flow = __TS__New(CodingAgentFlow) -- 2056
			__TS__Await(flow:run(shared)) -- 2057
			if shared.stopToken.stopped then -- 2057
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2059
				local result = { -- 2060
					success = false, -- 2060
					taskId = shared.taskId, -- 2060
					message = getCancelledReason(shared), -- 2060
					steps = shared.step -- 2060
				} -- 2060
				emitAgentEvent(shared, { -- 2061
					type = "task_finished", -- 2062
					sessionId = shared.sessionId, -- 2063
					taskId = shared.taskId, -- 2064
					success = false, -- 2065
					message = result.message, -- 2066
					steps = result.steps -- 2067
				}) -- 2067
				return ____awaiter_resolve(nil, result) -- 2067
			end -- 2067
			if shared.error then -- 2067
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 2072
				local result = {success = false, taskId = shared.taskId, message = shared.response and shared.response ~= "" and shared.response or shared.error, steps = shared.step} -- 2073
				emitAgentEvent(shared, { -- 2079
					type = "task_finished", -- 2080
					sessionId = shared.sessionId, -- 2081
					taskId = shared.taskId, -- 2082
					success = false, -- 2083
					message = result.message, -- 2084
					steps = result.steps -- 2085
				}) -- 2085
				return ____awaiter_resolve(nil, result) -- 2085
			end -- 2085
			Tools.setTaskStatus(shared.taskId, "DONE") -- 2089
			local result = {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step} -- 2090
			emitAgentEvent(shared, { -- 2096
				type = "task_finished", -- 2097
				sessionId = shared.sessionId, -- 2098
				taskId = shared.taskId, -- 2099
				success = true, -- 2100
				message = result.message, -- 2101
				steps = result.steps -- 2102
			}) -- 2102
			return ____awaiter_resolve(nil, result) -- 2102
		end) -- 2102
		__TS__Await(____try.catch( -- 2033
			____try, -- 2033
			function(____, e) -- 2033
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 2106
				local result = { -- 2107
					success = false, -- 2107
					taskId = shared.taskId, -- 2107
					message = tostring(e), -- 2107
					steps = shared.step -- 2107
				} -- 2107
				emitAgentEvent(shared, { -- 2108
					type = "task_finished", -- 2109
					sessionId = shared.sessionId, -- 2110
					taskId = shared.taskId, -- 2111
					success = false, -- 2112
					message = result.message, -- 2113
					steps = result.steps -- 2114
				}) -- 2114
				return ____awaiter_resolve(nil, result) -- 2114
			end -- 2114
		)) -- 2114
	end) -- 2114
end -- 1967
function ____exports.runCodingAgent(options, callback) -- 2120
	local ____self_51 = runCodingAgentAsync(options) -- 2120
	____self_51["then"]( -- 2120
		____self_51, -- 2120
		function(____, result) return callback(result) end -- 2121
	) -- 2121
end -- 2120
return ____exports -- 2120