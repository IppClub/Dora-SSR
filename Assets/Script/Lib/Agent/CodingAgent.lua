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
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
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
local getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, persistHistoryState, buildAgentSystemPrompt, buildYamlDecisionInstruction, SEARCH_DORA_API_LIMIT_MAX -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Path = ____Dora.Path -- 2
local json = ____Dora.json -- 2
local Content = ____Dora.Content -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local ____Utils = require("Agent.Utils") -- 4
local callLLM = ____Utils.callLLM -- 4
local Log = ____Utils.Log -- 4
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 4
local createLocalToolCallId = ____Utils.createLocalToolCallId -- 4
local Tools = require("Agent.Tools") -- 6
local ____Memory = require("Agent.Memory") -- 7
local MemoryCompressor = ____Memory.MemoryCompressor -- 7
function getReplyLanguageDirective(shared) -- 364
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 365
end -- 365
function replacePromptVars(template, vars) -- 370
	local output = template -- 371
	for key in pairs(vars) do -- 372
		output = table.concat( -- 373
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 373
			vars[key] or "" or "," -- 373
		) -- 373
	end -- 373
	return output -- 375
end -- 375
function getDecisionToolDefinitions(shared) -- 500
	local base = replacePromptVars( -- 501
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 502
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 503
	) -- 503
	if (shared and shared.decisionMode) ~= "yaml" then -- 503
		return base -- 506
	end -- 506
	return base .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 508
end -- 508
function persistHistoryState(shared) -- 579
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.memory.lastConsolidatedMessageIndex) -- 580
end -- 580
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1086
	if includeToolDefinitions == nil then -- 1086
		includeToolDefinitions = false -- 1086
	end -- 1086
	local sections = { -- 1087
		shared.promptPack.agentIdentityPrompt, -- 1088
		getReplyLanguageDirective(shared) -- 1089
	} -- 1089
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1091
	if memoryContext ~= "" then -- 1091
		sections[#sections + 1] = memoryContext -- 1093
	end -- 1093
	if includeToolDefinitions then -- 1093
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1096
		if shared.decisionMode == "yaml" then -- 1096
			sections[#sections + 1] = buildYamlDecisionInstruction(shared) -- 1098
		end -- 1098
	end -- 1098
	return table.concat(sections, "\n\n") -- 1101
end -- 1101
function buildYamlDecisionInstruction(shared, feedback) -- 1129
	return shared.promptPack.yamlDecisionFormatPrompt .. (feedback or "") -- 1130
end -- 1130
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
	local text, err = json.encode(value) -- 203
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
			sections[#sections + 1] = "role: " .. (message.role or "") -- 299
			sections[#sections + 1] = "" -- 300
			sections[#sections + 1] = message.content or "" -- 301
			i = i + 1 -- 296
		end -- 296
	end -- 296
	createStepLLMDebugPair( -- 303
		shared, -- 303
		stepId, -- 303
		table.concat(sections, "\n") -- 303
	) -- 303
end -- 282
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 306
	if not canWriteStepLLMDebug(shared, stepId) then -- 306
		return -- 307
	end -- 307
	local ____array_0 = __TS__SparseArrayNew( -- 307
		"# LLM Output", -- 309
		"session_id: " .. tostring(shared.sessionId), -- 310
		"task_id: " .. tostring(shared.taskId), -- 311
		"step_id: " .. tostring(stepId), -- 312
		"phase: " .. phase, -- 313
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 314
		table.unpack(meta and ({ -- 315
			"## Meta", -- 315
			"```json", -- 315
			encodeDebugJSON(meta), -- 315
			"```" -- 315
		}) or ({})) -- 315
	) -- 315
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 315
	local sections = {__TS__SparseArraySpread(____array_0)} -- 308
	updateLatestStepLLMDebugOutput( -- 319
		shared, -- 319
		stepId, -- 319
		table.concat(sections, "\n") -- 319
	) -- 319
end -- 306
local function toJson(value) -- 322
	local text, err = json.encode(value) -- 323
	if text ~= nil then -- 323
		return text -- 324
	end -- 324
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 325
end -- 322
local function truncateText(text, maxLen) -- 328
	if #text <= maxLen then -- 328
		return text -- 329
	end -- 329
	local nextPos = utf8.offset(text, maxLen + 1) -- 330
	if nextPos == nil then -- 330
		return text -- 331
	end -- 331
	return string.sub(text, 1, nextPos - 1) .. "..." -- 332
end -- 328
local function utf8TakeHead(text, maxChars) -- 335
	if maxChars <= 0 or text == "" then -- 335
		return "" -- 336
	end -- 336
	local nextPos = utf8.offset(text, maxChars + 1) -- 337
	if nextPos == nil then -- 337
		return text -- 338
	end -- 338
	return string.sub(text, 1, nextPos - 1) -- 339
end -- 335
local function utf8TakeTail(text, maxChars) -- 342
	if maxChars <= 0 or text == "" then -- 342
		return "" -- 343
	end -- 343
	local charLen = utf8.len(text) -- 344
	if charLen == false or charLen <= maxChars then -- 344
		return text -- 345
	end -- 345
	local startChar = math.max(1, charLen - maxChars + 1) -- 346
	local startPos = utf8.offset(text, startChar) -- 347
	if startPos == nil then -- 347
		return text -- 348
	end -- 348
	return string.sub(text, startPos) -- 349
end -- 342
local function summarizeUnknown(value, maxLen) -- 352
	if maxLen == nil then -- 352
		maxLen = 320 -- 352
	end -- 352
	if value == nil then -- 352
		return "undefined" -- 353
	end -- 353
	if value == nil then -- 353
		return "null" -- 354
	end -- 354
	if type(value) == "string" then -- 354
		return __TS__StringReplace( -- 356
			truncateText(value, maxLen), -- 356
			"\n", -- 356
			"\\n" -- 356
		) -- 356
	end -- 356
	if type(value) == "number" or type(value) == "boolean" then -- 356
		return tostring(value) -- 359
	end -- 359
	return __TS__StringReplace( -- 361
		truncateText( -- 361
			toJson(value), -- 361
			maxLen -- 361
		), -- 361
		"\n", -- 361
		"\\n" -- 361
	) -- 361
end -- 352
local function limitReadContentForHistory(content, tool) -- 378
	local lines = __TS__StringSplit(content, "\n") -- 379
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 380
	local limitedByLines = overLineLimit and table.concat( -- 381
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 382
		"\n" -- 382
	) or content -- 382
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 382
		return content -- 385
	end -- 385
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 387
	local reasons = {} -- 390
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 390
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 391
	end -- 391
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 391
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 392
	end -- 392
	local hint = "Narrow the requested line range." -- 393
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 394
end -- 378
local function summarizeEditTextParamForHistory(value, key) -- 397
	if type(value) ~= "string" then -- 397
		return nil -- 398
	end -- 398
	local text = value -- 399
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 400
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 401
end -- 397
local function sanitizeReadResultForHistory(tool, result) -- 409
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 409
		return result -- 411
	end -- 411
	local clone = {} -- 413
	for key in pairs(result) do -- 414
		clone[key] = result[key] -- 415
	end -- 415
	clone.content = limitReadContentForHistory(result.content, tool) -- 417
	return clone -- 418
end -- 409
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 421
	local shown = math.min(#items, maxItems) -- 425
	local out = {} -- 426
	do -- 426
		local i = 0 -- 427
		while i < shown do -- 427
			local row = items[i + 1] -- 428
			out[#out + 1] = { -- 429
				file = row.file, -- 430
				line = row.line, -- 431
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 432
			} -- 432
			i = i + 1 -- 427
		end -- 427
	end -- 427
	return out -- 437
end -- 421
local function sanitizeSearchResultForHistory(tool, result) -- 440
	if result.success ~= true or type(result.results) ~= "table" then -- 440
		return result -- 444
	end -- 444
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 444
		return result -- 445
	end -- 445
	local clone = {} -- 446
	for key in pairs(result) do -- 447
		clone[key] = result[key] -- 448
	end -- 448
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 450
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 451
	if tool == "grep_files" and type(result.groupedResults) == "table" then -- 451
		local grouped = result.groupedResults -- 456
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 457
		local sanitizedGroups = {} -- 458
		do -- 458
			local i = 0 -- 459
			while i < shown do -- 459
				local row = grouped[i + 1] -- 460
				sanitizedGroups[#sanitizedGroups + 1] = { -- 461
					file = row.file, -- 462
					totalMatches = row.totalMatches, -- 463
					matches = type(row.matches) == "table" and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 464
				} -- 464
				i = i + 1 -- 459
			end -- 459
		end -- 459
		clone.groupedResults = sanitizedGroups -- 469
	end -- 469
	return clone -- 471
end -- 440
local function sanitizeListFilesResultForHistory(result) -- 474
	if result.success ~= true or type(result.files) ~= "table" then -- 474
		return result -- 475
	end -- 475
	local clone = {} -- 476
	for key in pairs(result) do -- 477
		clone[key] = result[key] -- 478
	end -- 478
	local files = result.files -- 480
	clone.files = __TS__ArraySlice(files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 481
	return clone -- 482
end -- 474
local function sanitizeActionParamsForHistory(tool, params) -- 485
	if tool ~= "edit_file" then -- 485
		return params -- 486
	end -- 486
	local clone = {} -- 487
	for key in pairs(params) do -- 488
		if key == "old_str" then -- 488
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 490
		elseif key == "new_str" then -- 490
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 492
		else -- 492
			clone[key] = params[key] -- 494
		end -- 494
	end -- 494
	return clone -- 497
end -- 485
local function maybeCompressHistory(shared) -- 517
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 517
		local ____shared_5 = shared -- 518
		local memory = ____shared_5.memory -- 518
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 519
		local changed = false -- 520
		do -- 520
			local round = 0 -- 521
			while round < maxRounds do -- 521
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "yaml") -- 522
				if not memory.compressor:shouldCompress(shared.messages, memory.lastConsolidatedMessageIndex, systemPrompt, "") then -- 522
					return ____awaiter_resolve(nil) -- 522
				end -- 522
				local result = __TS__Await(memory.compressor:compress( -- 531
					shared.messages, -- 532
					memory.lastConsolidatedMessageIndex, -- 533
					systemPrompt, -- 534
					"", -- 535
					shared.llmOptions, -- 536
					shared.llmMaxTry, -- 537
					shared.decisionMode -- 538
				)) -- 538
				if not (result and result.success and result.compressedCount > 0) then -- 538
					if changed then -- 538
						persistHistoryState(shared) -- 542
					end -- 542
					return ____awaiter_resolve(nil) -- 542
				end -- 542
				memory.lastConsolidatedMessageIndex = memory.lastConsolidatedMessageIndex + result.compressedCount -- 546
				changed = true -- 547
				Log( -- 548
					"Info", -- 548
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(round + 1)) .. ")" -- 548
				) -- 548
				round = round + 1 -- 521
			end -- 521
		end -- 521
		if changed then -- 521
			persistHistoryState(shared) -- 551
		end -- 551
	end) -- 551
end -- 517
local function isKnownToolName(name) -- 555
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 556
end -- 555
local function getFinishMessage(params, fallback) -- 566
	if fallback == nil then -- 566
		fallback = "" -- 566
	end -- 566
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 566
		return __TS__StringTrim(params.message) -- 568
	end -- 568
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 568
		return __TS__StringTrim(params.response) -- 571
	end -- 571
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 571
		return __TS__StringTrim(params.summary) -- 574
	end -- 574
	return __TS__StringTrim(fallback) -- 576
end -- 566
local function appendConversationMessage(shared, message) -- 586
	local ____shared_messages_6 = shared.messages -- 586
	____shared_messages_6[#____shared_messages_6 + 1] = __TS__ObjectAssign( -- 587
		{}, -- 587
		message, -- 588
		{timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 587
	) -- 587
end -- 586
local function ensureToolCallId(toolCallId) -- 593
	if toolCallId and toolCallId ~= "" then -- 593
		return toolCallId -- 594
	end -- 594
	return createLocalToolCallId() -- 595
end -- 593
local function appendToolResultMessage(shared, action) -- 598
	appendConversationMessage( -- 599
		shared, -- 599
		{ -- 599
			role = "tool", -- 600
			tool_call_id = action.toolCallId, -- 601
			name = action.tool, -- 602
			content = action.result and toJson(action.result) or "" -- 603
		} -- 603
	) -- 603
end -- 598
local function extractYAMLFromText(text) -- 607
	local source = __TS__StringTrim(text) -- 608
	local function extractFencedBlock(fence) -- 609
		if not __TS__StringStartsWith(source, fence) then -- 609
			return nil -- 610
		end -- 610
		local fencePos = 0 -- 611
		local firstLineEnd = (string.find( -- 612
			source, -- 612
			"\n", -- 612
			math.max(fencePos + 1, 1), -- 612
			true -- 612
		) or 0) - 1 -- 612
		if firstLineEnd < 0 then -- 612
			return nil -- 613
		end -- 613
		local searchPos = firstLineEnd + 1 -- 614
		local closingFencePositions = {} -- 615
		while searchPos < #source do -- 615
			local lineEnd = (string.find( -- 617
				source, -- 617
				"\n", -- 617
				math.max(searchPos + 1, 1), -- 617
				true -- 617
			) or 0) - 1 -- 617
			local ____end = lineEnd >= 0 and lineEnd or #source -- 618
			local line = __TS__StringTrim(__TS__StringSlice(source, searchPos, ____end)) -- 619
			if line == "```" then -- 619
				closingFencePositions[#closingFencePositions + 1] = searchPos -- 621
			end -- 621
			searchPos = ____end + 1 -- 623
		end -- 623
		do -- 623
			local i = #closingFencePositions - 1 -- 625
			while i >= 0 do -- 625
				do -- 625
					local closingFencePos = closingFencePositions[i + 1] -- 626
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 627
					if afterFence ~= "" then -- 627
						goto __continue118 -- 628
					end -- 628
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 629
				end -- 629
				::__continue118:: -- 629
				i = i - 1 -- 625
			end -- 625
		end -- 625
		return nil -- 631
	end -- 609
	local xmlBlock = extractFencedBlock("```xml") -- 633
	if xmlBlock ~= nil then -- 633
		return xmlBlock -- 634
	end -- 634
	local genericBlock = extractFencedBlock("```") -- 635
	if genericBlock ~= nil then -- 635
		return genericBlock -- 636
	end -- 636
	return source -- 637
end -- 607
local function unwrapXMLRawText(text) -- 640
	local trimmed = __TS__StringTrim(text) -- 641
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 641
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 643
	end -- 643
	return text -- 645
end -- 640
local function isXMLWhitespaceChar(ch) -- 648
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 649
end -- 648
local function findLastLiteral(text, needle) -- 652
	if needle == "" then -- 652
		return #text -- 653
	end -- 653
	local last = -1 -- 654
	local from = 0 -- 655
	while from <= #text - #needle do -- 655
		local pos = (string.find( -- 657
			text, -- 657
			needle, -- 657
			math.max(from + 1, 1), -- 657
			true -- 657
		) or 0) - 1 -- 657
		if pos < 0 then -- 657
			break -- 658
		end -- 658
		last = pos -- 659
		from = pos + 1 -- 660
	end -- 660
	return last -- 662
end -- 652
local function readSimpleXMLTagName(source, openStart, openEnd) -- 665
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 666
	if rawTag == "" then -- 666
		return { -- 668
			success = false, -- 668
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 668
		} -- 668
	end -- 668
	local selfClosing = false -- 670
	local tagText = rawTag -- 671
	if __TS__StringEndsWith(tagText, "/") then -- 671
		selfClosing = true -- 673
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 674
	end -- 674
	local tagName = "" -- 676
	do -- 676
		local i = 0 -- 677
		while i < #tagText do -- 677
			local ch = __TS__StringAccess(tagText, i) -- 678
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 678
				break -- 679
			end -- 679
			tagName = tagName .. ch -- 680
			i = i + 1 -- 677
		end -- 677
	end -- 677
	if tagName == "" then -- 677
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 683
	end -- 683
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 685
end -- 665
local function findMatchingXMLClose(source, tagName, contentStart) -- 688
	local sameOpenPrefix = "<" .. tagName -- 689
	local sameCloseToken = ("</" .. tagName) .. ">" -- 690
	local pos = contentStart -- 691
	local depth = 1 -- 692
	while pos < #source do -- 692
		do -- 692
			local lt = (string.find( -- 694
				source, -- 694
				"<", -- 694
				math.max(pos + 1, 1), -- 694
				true -- 694
			) or 0) - 1 -- 694
			if lt < 0 then -- 694
				break -- 695
			end -- 695
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 695
				local cdataEnd = (string.find( -- 697
					source, -- 697
					"]]>", -- 697
					math.max(lt + 9 + 1, 1), -- 697
					true -- 697
				) or 0) - 1 -- 697
				if cdataEnd < 0 then -- 697
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 699
				end -- 699
				pos = cdataEnd + 3 -- 701
				goto __continue137 -- 702
			end -- 702
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 705
					source, -- 705
					"-->",
					math.max(lt + 4 + 1, 1), -- 705
					true -- 705
				) or 0) - 1 -- 705
				if commentEnd < 0 then -- 705
					return {success = false, message = "invalid xml: unterminated comment"} -- 707
				end -- 707
				pos = commentEnd + 3 -- 709
				goto __continue137 -- 710
			end -- 710
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 710
				depth = depth - 1 -- 713
				if depth == 0 then -- 713
					return {success = true, closeStart = lt} -- 715
				end -- 715
				pos = lt + #sameCloseToken -- 717
				goto __continue137 -- 718
			end -- 718
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 718
				local openEnd = (string.find( -- 721
					source, -- 721
					">", -- 721
					math.max(lt + 1, 1), -- 721
					true -- 721
				) or 0) - 1 -- 721
				if openEnd < 0 then -- 721
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 723
				end -- 723
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 725
				if not tagInfo.success then -- 725
					return tagInfo -- 726
				end -- 726
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 726
					depth = depth + 1 -- 728
				end -- 728
				pos = openEnd + 1 -- 730
				goto __continue137 -- 731
			end -- 731
			local genericEnd = (string.find( -- 733
				source, -- 733
				">", -- 733
				math.max(lt + 1, 1), -- 733
				true -- 733
			) or 0) - 1 -- 733
			if genericEnd < 0 then -- 733
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 735
			end -- 735
			pos = genericEnd + 1 -- 737
		end -- 737
		::__continue137:: -- 737
	end -- 737
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 739
end -- 688
local function parseSimpleXMLChildren(source) -- 742
	local result = {} -- 743
	local pos = 0 -- 744
	while pos < #source do -- 744
		do -- 744
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 744
				pos = pos + 1 -- 746
			end -- 746
			if pos >= #source then -- 746
				break -- 747
			end -- 747
			if __TS__StringAccess(source, pos) ~= "<" then -- 747
				return { -- 749
					success = false, -- 749
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 749
				} -- 749
			end -- 749
			if __TS__StringStartsWith(source, "</", pos) then -- 749
				return { -- 752
					success = false, -- 752
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 752
				} -- 752
			end -- 752
			local openEnd = (string.find( -- 754
				source, -- 754
				">", -- 754
				math.max(pos + 1, 1), -- 754
				true -- 754
			) or 0) - 1 -- 754
			if openEnd < 0 then -- 754
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 756
			end -- 756
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 758
			if not tagInfo.success then -- 758
				return tagInfo -- 759
			end -- 759
			if tagInfo.selfClosing then -- 759
				result[tagInfo.tagName] = "" -- 761
				pos = openEnd + 1 -- 762
				goto __continue151 -- 763
			end -- 763
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 765
			if not closeRes.success then -- 765
				return closeRes -- 766
			end -- 766
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 767
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 768
			pos = closeRes.closeStart + #closeToken -- 769
		end -- 769
		::__continue151:: -- 769
	end -- 769
	return {success = true, obj = result} -- 771
end -- 742
local function parseYAMLObjectFromText(text) -- 774
	local xmlText = extractYAMLFromText(text) -- 775
	local rootOpen = "<tool_call>" -- 776
	local rootClose = "</tool_call>" -- 777
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 778
	local ____end = findLastLiteral(xmlText, rootClose) -- 779
	if start < 0 or ____end < start then -- 779
		return {success = false, message = "invalid xml: missing <tool_call> root"} -- 781
	end -- 781
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 783
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 784
	if beforeRoot ~= "" or afterRoot ~= "" then -- 784
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 786
	end -- 786
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 788
	local children = parseSimpleXMLChildren(rootContent) -- 789
	if not children.success then -- 789
		return children -- 790
	end -- 790
	local rawObj = children.obj -- 791
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 792
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 793
	if not params.success then -- 793
		return {success = false, message = params.message} -- 797
	end -- 797
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 799
end -- 774
local function llm(shared, messages, phase) -- 818
	if phase == nil then -- 818
		phase = "decision_yaml" -- 821
	end -- 821
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 821
		local stepId = shared.step + 1 -- 823
		saveStepLLMDebugInput( -- 824
			shared, -- 824
			stepId, -- 824
			phase, -- 824
			messages, -- 824
			shared.llmOptions -- 824
		) -- 824
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 825
		if res.success then -- 825
			local ____opt_11 = res.response.choices -- 825
			local ____opt_9 = ____opt_11 and ____opt_11[1] -- 825
			local ____opt_7 = ____opt_9 and ____opt_9.message -- 825
			local text = ____opt_7 and ____opt_7.content -- 827
			if text then -- 827
				saveStepLLMDebugOutput( -- 829
					shared, -- 829
					stepId, -- 829
					phase, -- 829
					text, -- 829
					{success = true} -- 829
				) -- 829
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 829
			else -- 829
				saveStepLLMDebugOutput( -- 832
					shared, -- 832
					stepId, -- 832
					phase, -- 832
					"empty LLM response", -- 832
					{success = false} -- 832
				) -- 832
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 832
			end -- 832
		else -- 832
			saveStepLLMDebugOutput( -- 836
				shared, -- 836
				stepId, -- 836
				phase, -- 836
				res.raw or res.message, -- 836
				{success = false} -- 836
			) -- 836
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 836
		end -- 836
	end) -- 836
end -- 818
local function parseDecisionObject(rawObj) -- 853
	if type(rawObj.tool) ~= "string" then -- 853
		return {success = false, message = "missing tool"} -- 854
	end -- 854
	local tool = rawObj.tool -- 855
	if not isKnownToolName(tool) then -- 855
		return {success = false, message = "unknown tool: " .. tool} -- 857
	end -- 857
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 859
	if tool ~= "finish" and (not reason or reason == "") then -- 859
		return {success = false, message = tool .. " requires top-level reason"} -- 863
	end -- 863
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 865
	return {success = true, tool = tool, params = params, reason = reason} -- 866
end -- 853
local function parseDecisionToolCall(functionName, rawObj) -- 874
	if not isKnownToolName(functionName) then -- 874
		return {success = false, message = "unknown tool: " .. functionName} -- 876
	end -- 876
	if rawObj == nil or rawObj == nil then -- 876
		return {success = true, tool = functionName, params = {}} -- 879
	end -- 879
	if type(rawObj) ~= "table" then -- 879
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 882
	end -- 882
	return {success = true, tool = functionName, params = rawObj} -- 884
end -- 874
local function getDecisionPath(params) -- 891
	if type(params.path) == "string" then -- 891
		return __TS__StringTrim(params.path) -- 892
	end -- 892
	if type(params.target_file) == "string" then -- 892
		return __TS__StringTrim(params.target_file) -- 893
	end -- 893
	return "" -- 894
end -- 891
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 897
	local num = __TS__Number(value) -- 898
	if not __TS__NumberIsFinite(num) then -- 898
		num = fallback -- 899
	end -- 899
	num = math.floor(num) -- 900
	if num < minValue then -- 900
		num = minValue -- 901
	end -- 901
	if maxValue ~= nil and num > maxValue then -- 901
		num = maxValue -- 902
	end -- 902
	return num -- 903
end -- 897
local function validateDecision(tool, params) -- 906
	if tool == "finish" then -- 906
		local message = getFinishMessage(params) -- 911
		if message == "" then -- 911
			return {success = false, message = "finish requires params.message"} -- 912
		end -- 912
		params.message = message -- 913
		return {success = true, params = params} -- 914
	end -- 914
	if tool == "read_file" then -- 914
		local path = getDecisionPath(params) -- 918
		if path == "" then -- 918
			return {success = false, message = "read_file requires path"} -- 919
		end -- 919
		params.path = path -- 920
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 921
		local ____params_endLine_13 = params.endLine -- 922
		if ____params_endLine_13 == nil then -- 922
			____params_endLine_13 = READ_FILE_DEFAULT_LIMIT -- 922
		end -- 922
		local endLineRaw = ____params_endLine_13 -- 922
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 923
		params.startLine = startLine -- 924
		params.endLine = endLine -- 925
		return {success = true, params = params} -- 926
	end -- 926
	if tool == "edit_file" then -- 926
		local path = getDecisionPath(params) -- 930
		if path == "" then -- 930
			return {success = false, message = "edit_file requires path"} -- 931
		end -- 931
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 932
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 933
		if oldStr == newStr then -- 933
			return {success = false, message = "edit_file old_str and new_str must be different"} -- 935
		end -- 935
		params.path = path -- 937
		params.old_str = oldStr -- 938
		params.new_str = newStr -- 939
		return {success = true, params = params} -- 940
	end -- 940
	if tool == "delete_file" then -- 940
		local targetFile = getDecisionPath(params) -- 944
		if targetFile == "" then -- 944
			return {success = false, message = "delete_file requires target_file"} -- 945
		end -- 945
		params.target_file = targetFile -- 946
		return {success = true, params = params} -- 947
	end -- 947
	if tool == "grep_files" then -- 947
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 951
		if pattern == "" then -- 951
			return {success = false, message = "grep_files requires pattern"} -- 952
		end -- 952
		params.pattern = pattern -- 953
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 954
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 955
		return {success = true, params = params} -- 956
	end -- 956
	if tool == "search_dora_api" then -- 956
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 960
		if pattern == "" then -- 960
			return {success = false, message = "search_dora_api requires pattern"} -- 961
		end -- 961
		params.pattern = pattern -- 962
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 963
		return {success = true, params = params} -- 964
	end -- 964
	if tool == "glob_files" then -- 964
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 968
		return {success = true, params = params} -- 969
	end -- 969
	if tool == "build" then -- 969
		local path = getDecisionPath(params) -- 973
		if path ~= "" then -- 973
			params.path = path -- 975
		end -- 975
		return {success = true, params = params} -- 977
	end -- 977
	return {success = true, params = params} -- 980
end -- 906
local function createFunctionToolSchema(name, description, properties, required) -- 983
	if required == nil then -- 983
		required = {} -- 987
	end -- 987
	local parameters = {type = "object", properties = properties} -- 989
	if #required > 0 then -- 989
		parameters.required = required -- 994
	end -- 994
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 996
end -- 983
local function buildDecisionToolSchema() -- 1006
	return { -- 1007
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Parameters: path, startLine(optional), endLine(optional). Line numbering starts with 1. startLine defaults to 1 and endLine defaults to 300.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "1-based starting line number. Defaults to 1."}, endLine = {type = "number", description = "1-based ending line number. Defaults to 300."}}, {"path"}), -- 1008
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 1018
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1028
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1036
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1040
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1041
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1042
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1043
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1044
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1045
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1046
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1047
		}, {"pattern"}), -- 1047
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1051
		createFunctionToolSchema( -- 1060
			"search_dora_api", -- 1061
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1061
			{ -- 1063
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1064
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1065
				programmingLanguage = {type = "string", enum = { -- 1066
					"ts", -- 1068
					"tsx", -- 1068
					"lua", -- 1068
					"yue", -- 1068
					"teal", -- 1068
					"tl", -- 1068
					"wa" -- 1068
				}, description = "Preferred language variant to search."}, -- 1068
				limit = { -- 1071
					type = "number", -- 1071
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1071
				}, -- 1071
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1072
			}, -- 1072
			{"pattern"} -- 1074
		), -- 1074
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}) -- 1076
	} -- 1076
end -- 1006
local function getUnconsolidatedMessages(shared) -- 1104
	return __TS__ArraySlice(shared.messages, shared.memory.lastConsolidatedMessageIndex) -- 1105
end -- 1104
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1108
	if attempt == nil then -- 1108
		attempt = 1 -- 1108
	end -- 1108
	local messages = { -- 1109
		{ -- 1110
			role = "system", -- 1110
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "yaml") -- 1110
		}, -- 1110
		table.unpack(getUnconsolidatedMessages(shared)) -- 1111
	} -- 1111
	if lastError and lastError ~= "" then -- 1111
		local retryHeader = shared.decisionMode == "yaml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1114
		messages[#messages + 1] = { -- 1117
			role = "user", -- 1118
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1119
		} -- 1119
	end -- 1119
	return messages -- 1126
end -- 1108
local function buildYamlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 1133
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 1140
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 1141
	local repairPrompt = replacePromptVars( -- 1149
		shared.promptPack.yamlDecisionRepairPrompt, -- 1149
		{ -- 1149
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 1150
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 1151
			CANDIDATE_SECTION = candidateSection, -- 1152
			LAST_ERROR = lastError, -- 1153
			ATTEMPT = tostring(attempt) -- 1154
		} -- 1154
	) -- 1154
	return {{role = "system", content = "You repair invalid XML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid XML <tool_call> block.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the XML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid XML.\n- Do not continue the conversation and do not add explanations.\n- Return XML only."}, {role = "user", content = repairPrompt}} -- 1156
end -- 1133
local function tryParseAndValidateDecision(rawText) -- 1178
	local parsed = parseYAMLObjectFromText(rawText) -- 1179
	if not parsed.success then -- 1179
		return {success = false, message = parsed.message, raw = rawText} -- 1181
	end -- 1181
	local decision = parseDecisionObject(parsed.obj) -- 1183
	if not decision.success then -- 1183
		return {success = false, message = decision.message, raw = rawText} -- 1185
	end -- 1185
	local validation = validateDecision(decision.tool, decision.params) -- 1187
	if not validation.success then -- 1187
		return {success = false, message = validation.message, raw = rawText} -- 1189
	end -- 1189
	decision.params = validation.params -- 1191
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 1192
	return decision -- 1193
end -- 1178
local function normalizeLineEndings(text) -- 1196
	return table.concat( -- 1197
		__TS__StringSplit( -- 1197
			table.concat( -- 1197
				__TS__StringSplit(text, "\r\n"), -- 1197
				"\n" -- 1197
			), -- 1197
			"\r" -- 1197
		), -- 1197
		"\n" -- 1197
	) -- 1197
end -- 1196
local function replaceAllAndCount(text, oldStr, newStr) -- 1200
	text = normalizeLineEndings(text) -- 1201
	oldStr = normalizeLineEndings(oldStr) -- 1202
	newStr = normalizeLineEndings(newStr) -- 1203
	if oldStr == "" then -- 1203
		return {content = text, replaced = 0} -- 1204
	end -- 1204
	local count = 0 -- 1205
	local from = 0 -- 1206
	while true do -- 1206
		local idx = (string.find( -- 1208
			text, -- 1208
			oldStr, -- 1208
			math.max(from + 1, 1), -- 1208
			true -- 1208
		) or 0) - 1 -- 1208
		if idx < 0 then -- 1208
			break -- 1209
		end -- 1209
		count = count + 1 -- 1210
		from = idx + #oldStr -- 1211
	end -- 1211
	if count == 0 then -- 1211
		return {content = text, replaced = 0} -- 1213
	end -- 1213
	return { -- 1214
		content = table.concat( -- 1215
			__TS__StringSplit(text, oldStr), -- 1215
			newStr or "," -- 1215
		), -- 1215
		replaced = count -- 1216
	} -- 1216
end -- 1200
local MainDecisionAgent = __TS__Class() -- 1220
MainDecisionAgent.name = "MainDecisionAgent" -- 1220
__TS__ClassExtends(MainDecisionAgent, Node) -- 1220
function MainDecisionAgent.prototype.prep(self, shared) -- 1221
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1221
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1221
			return ____awaiter_resolve(nil, {shared = shared}) -- 1221
		end -- 1221
		__TS__Await(maybeCompressHistory(shared)) -- 1226
		return ____awaiter_resolve(nil, {shared = shared}) -- 1226
	end) -- 1226
end -- 1221
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 1231
	if attempt == nil then -- 1231
		attempt = 1 -- 1234
	end -- 1234
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1234
		if shared.stopToken.stopped then -- 1234
			return ____awaiter_resolve( -- 1234
				nil, -- 1234
				{ -- 1238
					success = false, -- 1238
					message = getCancelledReason(shared) -- 1238
				} -- 1238
			) -- 1238
		end -- 1238
		Log( -- 1240
			"Info", -- 1240
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1240
		) -- 1240
		local tools = buildDecisionToolSchema() -- 1241
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1242
		local stepId = shared.step + 1 -- 1243
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1244
		saveStepLLMDebugInput( -- 1248
			shared, -- 1248
			stepId, -- 1248
			"decision_tool_calling", -- 1248
			messages, -- 1248
			llmOptions -- 1248
		) -- 1248
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1249
		if shared.stopToken.stopped then -- 1249
			return ____awaiter_resolve( -- 1249
				nil, -- 1249
				{ -- 1251
					success = false, -- 1251
					message = getCancelledReason(shared) -- 1251
				} -- 1251
			) -- 1251
		end -- 1251
		if not res.success then -- 1251
			saveStepLLMDebugOutput( -- 1254
				shared, -- 1254
				stepId, -- 1254
				"decision_tool_calling", -- 1254
				res.raw or res.message, -- 1254
				{success = false} -- 1254
			) -- 1254
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1255
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1255
		end -- 1255
		saveStepLLMDebugOutput( -- 1258
			shared, -- 1258
			stepId, -- 1258
			"decision_tool_calling", -- 1258
			encodeDebugJSON(res.response), -- 1258
			{success = true} -- 1258
		) -- 1258
		local choice = res.response.choices and res.response.choices[1] -- 1259
		local message = choice and choice.message -- 1260
		local toolCalls = message and message.tool_calls -- 1261
		local toolCall = toolCalls and toolCalls[1] -- 1262
		local fn = toolCall and toolCall["function"] -- 1263
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 1264
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1267
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1270
		Log( -- 1273
			"Info", -- 1273
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1273
		) -- 1273
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1273
			if messageContent and messageContent ~= "" then -- 1273
				Log( -- 1276
					"Info", -- 1276
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1276
				) -- 1276
				return ____awaiter_resolve(nil, { -- 1276
					success = true, -- 1278
					tool = "finish", -- 1279
					params = {}, -- 1280
					reason = messageContent, -- 1281
					reasoningContent = reasoningContent, -- 1282
					directSummary = messageContent -- 1283
				}) -- 1283
			end -- 1283
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1286
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1286
		end -- 1286
		local functionName = fn.name -- 1293
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1294
		Log( -- 1295
			"Info", -- 1295
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1295
		) -- 1295
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1296
			local rawObj, err = json.decode(argsText) -- 1297
			if err ~= nil or rawObj == nil then -- 1297
				return {__error = tostring(err)} -- 1299
			end -- 1299
			return rawObj -- 1301
		end)() -- 1296
		if type(rawArgs) == "table" and rawArgs.__error ~= nil then -- 1296
			local err = tostring(rawArgs.__error) -- 1304
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1305
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1305
		end -- 1305
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1312
		if not decision.success then -- 1312
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1314
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1314
		end -- 1314
		local validation = validateDecision(decision.tool, decision.params) -- 1321
		if not validation.success then -- 1321
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1323
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1323
		end -- 1323
		decision.params = validation.params -- 1330
		decision.toolCallId = ensureToolCallId(toolCallId) -- 1331
		decision.reason = messageContent -- 1332
		decision.reasoningContent = reasoningContent -- 1333
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1334
		return ____awaiter_resolve(nil, decision) -- 1334
	end) -- 1334
end -- 1231
function MainDecisionAgent.prototype.repairDecisionYaml(self, shared, originalRaw, initialError) -- 1338
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1338
		Log( -- 1343
			"Info", -- 1343
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 1343
		) -- 1343
		local lastError = initialError -- 1344
		local candidateRaw = "" -- 1345
		do -- 1345
			local attempt = 0 -- 1346
			while attempt < shared.llmMaxTry do -- 1346
				do -- 1346
					Log( -- 1347
						"Info", -- 1347
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 1347
					) -- 1347
					local messages = buildYamlRepairMessages( -- 1348
						shared, -- 1349
						originalRaw, -- 1350
						candidateRaw, -- 1351
						lastError, -- 1352
						attempt + 1 -- 1353
					) -- 1353
					local llmRes = __TS__Await(llm(shared, messages, "decision_yaml_repair")) -- 1355
					if shared.stopToken.stopped then -- 1355
						return ____awaiter_resolve( -- 1355
							nil, -- 1355
							{ -- 1357
								success = false, -- 1357
								message = getCancelledReason(shared) -- 1357
							} -- 1357
						) -- 1357
					end -- 1357
					if not llmRes.success then -- 1357
						lastError = llmRes.message -- 1360
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 1361
						goto __continue239 -- 1362
					end -- 1362
					candidateRaw = llmRes.text -- 1364
					local decision = tryParseAndValidateDecision(candidateRaw) -- 1365
					if decision.success then -- 1365
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 1367
						return ____awaiter_resolve(nil, decision) -- 1367
					end -- 1367
					lastError = decision.message -- 1370
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 1371
				end -- 1371
				::__continue239:: -- 1371
				attempt = attempt + 1 -- 1346
			end -- 1346
		end -- 1346
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 1373
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 1373
	end) -- 1373
end -- 1338
function MainDecisionAgent.prototype.exec(self, input) -- 1381
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1381
		local shared = input.shared -- 1382
		if shared.stopToken.stopped then -- 1382
			return ____awaiter_resolve( -- 1382
				nil, -- 1382
				{ -- 1384
					success = false, -- 1384
					message = getCancelledReason(shared) -- 1384
				} -- 1384
			) -- 1384
		end -- 1384
		if shared.step >= shared.maxSteps then -- 1384
			Log( -- 1387
				"Warn", -- 1387
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1387
			) -- 1387
			return ____awaiter_resolve( -- 1387
				nil, -- 1387
				{ -- 1388
					success = false, -- 1388
					message = getMaxStepsReachedReason(shared) -- 1388
				} -- 1388
			) -- 1388
		end -- 1388
		if shared.decisionMode == "tool_calling" then -- 1388
			Log( -- 1392
				"Info", -- 1392
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 1392
			) -- 1392
			local lastError = "tool calling validation failed" -- 1393
			local lastRaw = "" -- 1394
			do -- 1394
				local attempt = 0 -- 1395
				while attempt < shared.llmMaxTry do -- 1395
					Log( -- 1396
						"Info", -- 1396
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1396
					) -- 1396
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 1397
					if shared.stopToken.stopped then -- 1397
						return ____awaiter_resolve( -- 1397
							nil, -- 1397
							{ -- 1404
								success = false, -- 1404
								message = getCancelledReason(shared) -- 1404
							} -- 1404
						) -- 1404
					end -- 1404
					if decision.success then -- 1404
						return ____awaiter_resolve(nil, decision) -- 1404
					end -- 1404
					lastError = decision.message -- 1409
					lastRaw = decision.raw or "" -- 1410
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1411
					attempt = attempt + 1 -- 1395
				end -- 1395
			end -- 1395
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1413
			return ____awaiter_resolve( -- 1413
				nil, -- 1413
				{ -- 1414
					success = false, -- 1414
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1414
				} -- 1414
			) -- 1414
		end -- 1414
		local lastError = "xml validation failed" -- 1417
		local lastRaw = "" -- 1418
		do -- 1418
			local attempt = 0 -- 1419
			while attempt < shared.llmMaxTry do -- 1419
				do -- 1419
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 1420
					local llmRes = __TS__Await(llm(shared, messages, "decision_yaml")) -- 1428
					if shared.stopToken.stopped then -- 1428
						return ____awaiter_resolve( -- 1428
							nil, -- 1428
							{ -- 1430
								success = false, -- 1430
								message = getCancelledReason(shared) -- 1430
							} -- 1430
						) -- 1430
					end -- 1430
					if not llmRes.success then -- 1430
						lastError = llmRes.message -- 1433
						lastRaw = llmRes.text or "" -- 1434
						goto __continue252 -- 1435
					end -- 1435
					lastRaw = llmRes.text -- 1437
					local decision = tryParseAndValidateDecision(llmRes.text) -- 1438
					if decision.success then -- 1438
						return ____awaiter_resolve(nil, decision) -- 1438
					end -- 1438
					lastError = decision.message -- 1442
					return ____awaiter_resolve( -- 1442
						nil, -- 1442
						self:repairDecisionYaml(shared, llmRes.text, lastError) -- 1443
					) -- 1443
				end -- 1443
				::__continue252:: -- 1443
				attempt = attempt + 1 -- 1419
			end -- 1419
		end -- 1419
		return ____awaiter_resolve( -- 1419
			nil, -- 1419
			{ -- 1445
				success = false, -- 1445
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1445
			} -- 1445
		) -- 1445
	end) -- 1445
end -- 1381
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1448
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1448
		local result = execRes -- 1449
		if not result.success then -- 1449
			shared.error = result.message -- 1451
			shared.response = getFailureSummaryFallback(shared, result.message) -- 1452
			shared.done = true -- 1453
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 1454
			persistHistoryState(shared) -- 1458
			return ____awaiter_resolve(nil, "done") -- 1458
		end -- 1458
		if result.directSummary and result.directSummary ~= "" then -- 1458
			shared.response = result.directSummary -- 1462
			shared.done = true -- 1463
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 1464
			persistHistoryState(shared) -- 1469
			return ____awaiter_resolve(nil, "done") -- 1469
		end -- 1469
		if result.tool == "finish" then -- 1469
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 1473
			shared.response = finalMessage -- 1474
			shared.done = true -- 1475
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 1476
			persistHistoryState(shared) -- 1481
			return ____awaiter_resolve(nil, "done") -- 1481
		end -- 1481
		emitAgentEvent(shared, { -- 1484
			type = "decision_made", -- 1485
			sessionId = shared.sessionId, -- 1486
			taskId = shared.taskId, -- 1487
			step = shared.step + 1, -- 1488
			tool = result.tool, -- 1489
			reason = result.reason, -- 1490
			reasoningContent = result.reasoningContent, -- 1491
			params = result.params -- 1492
		}) -- 1492
		local toolCallId = ensureToolCallId(result.toolCallId) -- 1494
		local ____shared_history_14 = shared.history -- 1494
		____shared_history_14[#____shared_history_14 + 1] = { -- 1495
			step = #shared.history + 1, -- 1496
			toolCallId = toolCallId, -- 1497
			tool = result.tool, -- 1498
			reason = result.reason or "", -- 1499
			reasoningContent = result.reasoningContent, -- 1500
			params = result.params, -- 1501
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1502
		} -- 1502
		appendConversationMessage( -- 1504
			shared, -- 1504
			{ -- 1504
				role = "assistant", -- 1505
				content = result.reason or "", -- 1506
				reasoning_content = result.reasoningContent, -- 1507
				tool_calls = {{ -- 1508
					id = toolCallId, -- 1509
					type = "function", -- 1510
					["function"] = { -- 1511
						name = result.tool, -- 1512
						arguments = toJson(result.params) -- 1513
					} -- 1513
				}} -- 1513
			} -- 1513
		) -- 1513
		persistHistoryState(shared) -- 1517
		return ____awaiter_resolve(nil, result.tool) -- 1517
	end) -- 1517
end -- 1448
local ReadFileAction = __TS__Class() -- 1522
ReadFileAction.name = "ReadFileAction" -- 1522
__TS__ClassExtends(ReadFileAction, Node) -- 1522
function ReadFileAction.prototype.prep(self, shared) -- 1523
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1523
		local last = shared.history[#shared.history] -- 1524
		if not last then -- 1524
			error( -- 1525
				__TS__New(Error, "no history"), -- 1525
				0 -- 1525
			) -- 1525
		end -- 1525
		emitAgentEvent(shared, { -- 1526
			type = "tool_started", -- 1527
			sessionId = shared.sessionId, -- 1528
			taskId = shared.taskId, -- 1529
			step = shared.step + 1, -- 1530
			tool = last.tool -- 1531
		}) -- 1531
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1533
		if __TS__StringTrim(path) == "" then -- 1533
			error( -- 1536
				__TS__New(Error, "missing path"), -- 1536
				0 -- 1536
			) -- 1536
		end -- 1536
		local ____path_17 = path -- 1538
		local ____shared_workingDir_18 = shared.workingDir -- 1540
		local ____temp_19 = shared.useChineseResponse and "zh" or "en" -- 1541
		local ____last_params_startLine_15 = last.params.startLine -- 1542
		if ____last_params_startLine_15 == nil then -- 1542
			____last_params_startLine_15 = 1 -- 1542
		end -- 1542
		local ____TS__Number_result_20 = __TS__Number(____last_params_startLine_15) -- 1542
		local ____last_params_endLine_16 = last.params.endLine -- 1543
		if ____last_params_endLine_16 == nil then -- 1543
			____last_params_endLine_16 = READ_FILE_DEFAULT_LIMIT -- 1543
		end -- 1543
		return ____awaiter_resolve( -- 1543
			nil, -- 1543
			{ -- 1537
				path = ____path_17, -- 1538
				tool = "read_file", -- 1539
				workDir = ____shared_workingDir_18, -- 1540
				docLanguage = ____temp_19, -- 1541
				startLine = ____TS__Number_result_20, -- 1542
				endLine = __TS__Number(____last_params_endLine_16) -- 1543
			} -- 1543
		) -- 1543
	end) -- 1543
end -- 1523
function ReadFileAction.prototype.exec(self, input) -- 1547
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1547
		return ____awaiter_resolve( -- 1547
			nil, -- 1547
			Tools.readFile( -- 1548
				input.workDir, -- 1549
				input.path, -- 1550
				__TS__Number(input.startLine or 1), -- 1551
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1552
				input.docLanguage -- 1553
			) -- 1553
		) -- 1553
	end) -- 1553
end -- 1547
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1557
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1557
		local result = execRes -- 1558
		local last = shared.history[#shared.history] -- 1559
		if last ~= nil then -- 1559
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1561
			appendToolResultMessage(shared, last) -- 1562
			emitAgentEvent(shared, { -- 1563
				type = "tool_finished", -- 1564
				sessionId = shared.sessionId, -- 1565
				taskId = shared.taskId, -- 1566
				step = shared.step + 1, -- 1567
				tool = last.tool, -- 1568
				result = last.result -- 1569
			}) -- 1569
		end -- 1569
		__TS__Await(maybeCompressHistory(shared)) -- 1572
		persistHistoryState(shared) -- 1573
		shared.step = shared.step + 1 -- 1574
		return ____awaiter_resolve(nil, "main") -- 1574
	end) -- 1574
end -- 1557
local SearchFilesAction = __TS__Class() -- 1579
SearchFilesAction.name = "SearchFilesAction" -- 1579
__TS__ClassExtends(SearchFilesAction, Node) -- 1579
function SearchFilesAction.prototype.prep(self, shared) -- 1580
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1580
		local last = shared.history[#shared.history] -- 1581
		if not last then -- 1581
			error( -- 1582
				__TS__New(Error, "no history"), -- 1582
				0 -- 1582
			) -- 1582
		end -- 1582
		emitAgentEvent(shared, { -- 1583
			type = "tool_started", -- 1584
			sessionId = shared.sessionId, -- 1585
			taskId = shared.taskId, -- 1586
			step = shared.step + 1, -- 1587
			tool = last.tool -- 1588
		}) -- 1588
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1588
	end) -- 1588
end -- 1580
function SearchFilesAction.prototype.exec(self, input) -- 1593
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1593
		local params = input.params -- 1594
		local ____Tools_searchFiles_34 = Tools.searchFiles -- 1595
		local ____input_workDir_27 = input.workDir -- 1596
		local ____temp_28 = params.path or "" -- 1597
		local ____temp_29 = params.pattern or "" -- 1598
		local ____params_globs_30 = params.globs -- 1599
		local ____params_useRegex_31 = params.useRegex -- 1600
		local ____params_caseSensitive_32 = params.caseSensitive -- 1601
		local ____math_max_23 = math.max -- 1604
		local ____math_floor_22 = math.floor -- 1604
		local ____params_limit_21 = params.limit -- 1604
		if ____params_limit_21 == nil then -- 1604
			____params_limit_21 = SEARCH_FILES_LIMIT_DEFAULT -- 1604
		end -- 1604
		local ____math_max_23_result_33 = ____math_max_23( -- 1604
			1, -- 1604
			____math_floor_22(__TS__Number(____params_limit_21)) -- 1604
		) -- 1604
		local ____math_max_26 = math.max -- 1605
		local ____math_floor_25 = math.floor -- 1605
		local ____params_offset_24 = params.offset -- 1605
		if ____params_offset_24 == nil then -- 1605
			____params_offset_24 = 0 -- 1605
		end -- 1605
		local result = __TS__Await(____Tools_searchFiles_34({ -- 1595
			workDir = ____input_workDir_27, -- 1596
			path = ____temp_28, -- 1597
			pattern = ____temp_29, -- 1598
			globs = ____params_globs_30, -- 1599
			useRegex = ____params_useRegex_31, -- 1600
			caseSensitive = ____params_caseSensitive_32, -- 1601
			includeContent = true, -- 1602
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1603
			limit = ____math_max_23_result_33, -- 1604
			offset = ____math_max_26( -- 1605
				0, -- 1605
				____math_floor_25(__TS__Number(____params_offset_24)) -- 1605
			), -- 1605
			groupByFile = params.groupByFile == true -- 1606
		})) -- 1606
		return ____awaiter_resolve(nil, result) -- 1606
	end) -- 1606
end -- 1593
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1611
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1611
		local last = shared.history[#shared.history] -- 1612
		if last ~= nil then -- 1612
			local result = execRes -- 1614
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1615
			appendToolResultMessage(shared, last) -- 1616
			emitAgentEvent(shared, { -- 1617
				type = "tool_finished", -- 1618
				sessionId = shared.sessionId, -- 1619
				taskId = shared.taskId, -- 1620
				step = shared.step + 1, -- 1621
				tool = last.tool, -- 1622
				result = last.result -- 1623
			}) -- 1623
		end -- 1623
		__TS__Await(maybeCompressHistory(shared)) -- 1626
		persistHistoryState(shared) -- 1627
		shared.step = shared.step + 1 -- 1628
		return ____awaiter_resolve(nil, "main") -- 1628
	end) -- 1628
end -- 1611
local SearchDoraAPIAction = __TS__Class() -- 1633
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1633
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1633
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1634
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1634
		local last = shared.history[#shared.history] -- 1635
		if not last then -- 1635
			error( -- 1636
				__TS__New(Error, "no history"), -- 1636
				0 -- 1636
			) -- 1636
		end -- 1636
		emitAgentEvent(shared, { -- 1637
			type = "tool_started", -- 1638
			sessionId = shared.sessionId, -- 1639
			taskId = shared.taskId, -- 1640
			step = shared.step + 1, -- 1641
			tool = last.tool -- 1642
		}) -- 1642
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1642
	end) -- 1642
end -- 1634
function SearchDoraAPIAction.prototype.exec(self, input) -- 1647
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1647
		local params = input.params -- 1648
		local ____Tools_searchDoraAPI_42 = Tools.searchDoraAPI -- 1649
		local ____temp_38 = params.pattern or "" -- 1650
		local ____temp_39 = params.docSource or "api" -- 1651
		local ____temp_40 = input.useChineseResponse and "zh" or "en" -- 1652
		local ____temp_41 = params.programmingLanguage or "ts" -- 1653
		local ____math_min_37 = math.min -- 1654
		local ____math_max_36 = math.max -- 1654
		local ____params_limit_35 = params.limit -- 1654
		if ____params_limit_35 == nil then -- 1654
			____params_limit_35 = 8 -- 1654
		end -- 1654
		local result = __TS__Await(____Tools_searchDoraAPI_42({ -- 1649
			pattern = ____temp_38, -- 1650
			docSource = ____temp_39, -- 1651
			docLanguage = ____temp_40, -- 1652
			programmingLanguage = ____temp_41, -- 1653
			limit = ____math_min_37( -- 1654
				SEARCH_DORA_API_LIMIT_MAX, -- 1654
				____math_max_36( -- 1654
					1, -- 1654
					__TS__Number(____params_limit_35) -- 1654
				) -- 1654
			), -- 1654
			useRegex = params.useRegex, -- 1655
			caseSensitive = false, -- 1656
			includeContent = true, -- 1657
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1658
		})) -- 1658
		return ____awaiter_resolve(nil, result) -- 1658
	end) -- 1658
end -- 1647
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1663
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1663
		local last = shared.history[#shared.history] -- 1664
		if last ~= nil then -- 1664
			local result = execRes -- 1666
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1667
			appendToolResultMessage(shared, last) -- 1668
			emitAgentEvent(shared, { -- 1669
				type = "tool_finished", -- 1670
				sessionId = shared.sessionId, -- 1671
				taskId = shared.taskId, -- 1672
				step = shared.step + 1, -- 1673
				tool = last.tool, -- 1674
				result = last.result -- 1675
			}) -- 1675
		end -- 1675
		__TS__Await(maybeCompressHistory(shared)) -- 1678
		persistHistoryState(shared) -- 1679
		shared.step = shared.step + 1 -- 1680
		return ____awaiter_resolve(nil, "main") -- 1680
	end) -- 1680
end -- 1663
local ListFilesAction = __TS__Class() -- 1685
ListFilesAction.name = "ListFilesAction" -- 1685
__TS__ClassExtends(ListFilesAction, Node) -- 1685
function ListFilesAction.prototype.prep(self, shared) -- 1686
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1686
		local last = shared.history[#shared.history] -- 1687
		if not last then -- 1687
			error( -- 1688
				__TS__New(Error, "no history"), -- 1688
				0 -- 1688
			) -- 1688
		end -- 1688
		emitAgentEvent(shared, { -- 1689
			type = "tool_started", -- 1690
			sessionId = shared.sessionId, -- 1691
			taskId = shared.taskId, -- 1692
			step = shared.step + 1, -- 1693
			tool = last.tool -- 1694
		}) -- 1694
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1694
	end) -- 1694
end -- 1686
function ListFilesAction.prototype.exec(self, input) -- 1699
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1699
		local params = input.params -- 1700
		local ____Tools_listFiles_49 = Tools.listFiles -- 1701
		local ____input_workDir_46 = input.workDir -- 1702
		local ____temp_47 = params.path or "" -- 1703
		local ____params_globs_48 = params.globs -- 1704
		local ____math_max_45 = math.max -- 1705
		local ____math_floor_44 = math.floor -- 1705
		local ____params_maxEntries_43 = params.maxEntries -- 1705
		if ____params_maxEntries_43 == nil then -- 1705
			____params_maxEntries_43 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1705
		end -- 1705
		local result = ____Tools_listFiles_49({ -- 1701
			workDir = ____input_workDir_46, -- 1702
			path = ____temp_47, -- 1703
			globs = ____params_globs_48, -- 1704
			maxEntries = ____math_max_45( -- 1705
				1, -- 1705
				____math_floor_44(__TS__Number(____params_maxEntries_43)) -- 1705
			) -- 1705
		}) -- 1705
		return ____awaiter_resolve(nil, result) -- 1705
	end) -- 1705
end -- 1699
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1710
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1710
		local last = shared.history[#shared.history] -- 1711
		if last ~= nil then -- 1711
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1713
			appendToolResultMessage(shared, last) -- 1714
			emitAgentEvent(shared, { -- 1715
				type = "tool_finished", -- 1716
				sessionId = shared.sessionId, -- 1717
				taskId = shared.taskId, -- 1718
				step = shared.step + 1, -- 1719
				tool = last.tool, -- 1720
				result = last.result -- 1721
			}) -- 1721
		end -- 1721
		__TS__Await(maybeCompressHistory(shared)) -- 1724
		persistHistoryState(shared) -- 1725
		shared.step = shared.step + 1 -- 1726
		return ____awaiter_resolve(nil, "main") -- 1726
	end) -- 1726
end -- 1710
local DeleteFileAction = __TS__Class() -- 1731
DeleteFileAction.name = "DeleteFileAction" -- 1731
__TS__ClassExtends(DeleteFileAction, Node) -- 1731
function DeleteFileAction.prototype.prep(self, shared) -- 1732
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1732
		local last = shared.history[#shared.history] -- 1733
		if not last then -- 1733
			error( -- 1734
				__TS__New(Error, "no history"), -- 1734
				0 -- 1734
			) -- 1734
		end -- 1734
		emitAgentEvent(shared, { -- 1735
			type = "tool_started", -- 1736
			sessionId = shared.sessionId, -- 1737
			taskId = shared.taskId, -- 1738
			step = shared.step + 1, -- 1739
			tool = last.tool -- 1740
		}) -- 1740
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1742
		if __TS__StringTrim(targetFile) == "" then -- 1742
			error( -- 1745
				__TS__New(Error, "missing target_file"), -- 1745
				0 -- 1745
			) -- 1745
		end -- 1745
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1745
	end) -- 1745
end -- 1732
function DeleteFileAction.prototype.exec(self, input) -- 1749
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1749
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1750
		if not result.success then -- 1750
			return ____awaiter_resolve(nil, result) -- 1750
		end -- 1750
		return ____awaiter_resolve(nil, { -- 1750
			success = true, -- 1758
			changed = true, -- 1759
			mode = "delete", -- 1760
			checkpointId = result.checkpointId, -- 1761
			checkpointSeq = result.checkpointSeq, -- 1762
			files = {{path = input.targetFile, op = "delete"}} -- 1763
		}) -- 1763
	end) -- 1763
end -- 1749
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1767
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1767
		local last = shared.history[#shared.history] -- 1768
		if last ~= nil then -- 1768
			last.result = execRes -- 1770
			appendToolResultMessage(shared, last) -- 1771
			emitAgentEvent(shared, { -- 1772
				type = "tool_finished", -- 1773
				sessionId = shared.sessionId, -- 1774
				taskId = shared.taskId, -- 1775
				step = shared.step + 1, -- 1776
				tool = last.tool, -- 1777
				result = last.result -- 1778
			}) -- 1778
			local result = last.result -- 1780
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1780
				emitAgentEvent(shared, { -- 1785
					type = "checkpoint_created", -- 1786
					sessionId = shared.sessionId, -- 1787
					taskId = shared.taskId, -- 1788
					step = shared.step + 1, -- 1789
					tool = "delete_file", -- 1790
					checkpointId = result.checkpointId, -- 1791
					checkpointSeq = result.checkpointSeq, -- 1792
					files = result.files -- 1793
				}) -- 1793
			end -- 1793
		end -- 1793
		__TS__Await(maybeCompressHistory(shared)) -- 1797
		persistHistoryState(shared) -- 1798
		shared.step = shared.step + 1 -- 1799
		return ____awaiter_resolve(nil, "main") -- 1799
	end) -- 1799
end -- 1767
local BuildAction = __TS__Class() -- 1804
BuildAction.name = "BuildAction" -- 1804
__TS__ClassExtends(BuildAction, Node) -- 1804
function BuildAction.prototype.prep(self, shared) -- 1805
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1805
		local last = shared.history[#shared.history] -- 1806
		if not last then -- 1806
			error( -- 1807
				__TS__New(Error, "no history"), -- 1807
				0 -- 1807
			) -- 1807
		end -- 1807
		emitAgentEvent(shared, { -- 1808
			type = "tool_started", -- 1809
			sessionId = shared.sessionId, -- 1810
			taskId = shared.taskId, -- 1811
			step = shared.step + 1, -- 1812
			tool = last.tool -- 1813
		}) -- 1813
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1813
	end) -- 1813
end -- 1805
function BuildAction.prototype.exec(self, input) -- 1818
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1818
		local params = input.params -- 1819
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1820
		return ____awaiter_resolve(nil, result) -- 1820
	end) -- 1820
end -- 1818
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1827
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1827
		local last = shared.history[#shared.history] -- 1828
		if last ~= nil then -- 1828
			last.result = execRes -- 1830
			appendToolResultMessage(shared, last) -- 1831
			emitAgentEvent(shared, { -- 1832
				type = "tool_finished", -- 1833
				sessionId = shared.sessionId, -- 1834
				taskId = shared.taskId, -- 1835
				step = shared.step + 1, -- 1836
				tool = last.tool, -- 1837
				result = last.result -- 1838
			}) -- 1838
		end -- 1838
		__TS__Await(maybeCompressHistory(shared)) -- 1841
		persistHistoryState(shared) -- 1842
		shared.step = shared.step + 1 -- 1843
		return ____awaiter_resolve(nil, "main") -- 1843
	end) -- 1843
end -- 1827
local EditFileAction = __TS__Class() -- 1848
EditFileAction.name = "EditFileAction" -- 1848
__TS__ClassExtends(EditFileAction, Node) -- 1848
function EditFileAction.prototype.prep(self, shared) -- 1849
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1849
		local last = shared.history[#shared.history] -- 1850
		if not last then -- 1850
			error( -- 1851
				__TS__New(Error, "no history"), -- 1851
				0 -- 1851
			) -- 1851
		end -- 1851
		emitAgentEvent(shared, { -- 1852
			type = "tool_started", -- 1853
			sessionId = shared.sessionId, -- 1854
			taskId = shared.taskId, -- 1855
			step = shared.step + 1, -- 1856
			tool = last.tool -- 1857
		}) -- 1857
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1859
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1862
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1863
		if __TS__StringTrim(path) == "" then -- 1863
			error( -- 1864
				__TS__New(Error, "missing path"), -- 1864
				0 -- 1864
			) -- 1864
		end -- 1864
		if oldStr == newStr then -- 1864
			error( -- 1865
				__TS__New(Error, "old_str and new_str must be different"), -- 1865
				0 -- 1865
			) -- 1865
		end -- 1865
		return ____awaiter_resolve(nil, { -- 1865
			path = path, -- 1866
			oldStr = oldStr, -- 1866
			newStr = newStr, -- 1866
			taskId = shared.taskId, -- 1866
			workDir = shared.workingDir -- 1866
		}) -- 1866
	end) -- 1866
end -- 1849
function EditFileAction.prototype.exec(self, input) -- 1869
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1869
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1870
		if not readRes.success then -- 1870
			if input.oldStr ~= "" then -- 1870
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1870
			end -- 1870
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1875
			if not createRes.success then -- 1875
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1875
			end -- 1875
			return ____awaiter_resolve(nil, { -- 1875
				success = true, -- 1883
				changed = true, -- 1884
				mode = "create", -- 1885
				replaced = 0, -- 1886
				checkpointId = createRes.checkpointId, -- 1887
				checkpointSeq = createRes.checkpointSeq, -- 1888
				files = {{path = input.path, op = "create"}} -- 1889
			}) -- 1889
		end -- 1889
		if input.oldStr == "" then -- 1889
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 1889
		end -- 1889
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 1896
		if replaceRes.replaced == 0 then -- 1896
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 1896
		end -- 1896
		if replaceRes.content == readRes.content then -- 1896
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 1896
		end -- 1896
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1909
		if not applyRes.success then -- 1909
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1909
		end -- 1909
		return ____awaiter_resolve(nil, { -- 1909
			success = true, -- 1917
			changed = true, -- 1918
			mode = "replace", -- 1919
			replaced = replaceRes.replaced, -- 1920
			checkpointId = applyRes.checkpointId, -- 1921
			checkpointSeq = applyRes.checkpointSeq, -- 1922
			files = {{path = input.path, op = "write"}} -- 1923
		}) -- 1923
	end) -- 1923
end -- 1869
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1927
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1927
		local last = shared.history[#shared.history] -- 1928
		if last ~= nil then -- 1928
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1930
			last.result = execRes -- 1931
			appendToolResultMessage(shared, last) -- 1932
			emitAgentEvent(shared, { -- 1933
				type = "tool_finished", -- 1934
				sessionId = shared.sessionId, -- 1935
				taskId = shared.taskId, -- 1936
				step = shared.step + 1, -- 1937
				tool = last.tool, -- 1938
				result = last.result -- 1939
			}) -- 1939
			local result = last.result -- 1941
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1941
				emitAgentEvent(shared, { -- 1946
					type = "checkpoint_created", -- 1947
					sessionId = shared.sessionId, -- 1948
					taskId = shared.taskId, -- 1949
					step = shared.step + 1, -- 1950
					tool = last.tool, -- 1951
					checkpointId = result.checkpointId, -- 1952
					checkpointSeq = result.checkpointSeq, -- 1953
					files = result.files -- 1954
				}) -- 1954
			end -- 1954
		end -- 1954
		__TS__Await(maybeCompressHistory(shared)) -- 1958
		persistHistoryState(shared) -- 1959
		shared.step = shared.step + 1 -- 1960
		return ____awaiter_resolve(nil, "main") -- 1960
	end) -- 1960
end -- 1927
local EndNode = __TS__Class() -- 1965
EndNode.name = "EndNode" -- 1965
__TS__ClassExtends(EndNode, Node) -- 1965
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 1966
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1966
		return ____awaiter_resolve(nil, nil) -- 1966
	end) -- 1966
end -- 1966
local CodingAgentFlow = __TS__Class() -- 1971
CodingAgentFlow.name = "CodingAgentFlow" -- 1971
__TS__ClassExtends(CodingAgentFlow, Flow) -- 1971
function CodingAgentFlow.prototype.____constructor(self) -- 1972
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 1973
	local read = __TS__New(ReadFileAction, 1, 0) -- 1974
	local search = __TS__New(SearchFilesAction, 1, 0) -- 1975
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 1976
	local list = __TS__New(ListFilesAction, 1, 0) -- 1977
	local del = __TS__New(DeleteFileAction, 1, 0) -- 1978
	local build = __TS__New(BuildAction, 1, 0) -- 1979
	local edit = __TS__New(EditFileAction, 1, 0) -- 1980
	local done = __TS__New(EndNode, 1, 0) -- 1981
	main:on("read_file", read) -- 1983
	main:on("grep_files", search) -- 1984
	main:on("search_dora_api", searchDora) -- 1985
	main:on("glob_files", list) -- 1986
	main:on("delete_file", del) -- 1987
	main:on("build", build) -- 1988
	main:on("edit_file", edit) -- 1989
	main:on("done", done) -- 1990
	read:on("main", main) -- 1992
	search:on("main", main) -- 1993
	searchDora:on("main", main) -- 1994
	list:on("main", main) -- 1995
	del:on("main", main) -- 1996
	build:on("main", main) -- 1997
	edit:on("main", main) -- 1998
	Flow.prototype.____constructor(self, main) -- 2000
end -- 1972
local function runCodingAgentAsync(options) -- 2004
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2004
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 2004
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 2004
		end -- 2004
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2008
		if not llmConfigRes.success then -- 2008
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2008
		end -- 2008
		local llmConfig = llmConfigRes.config -- 2014
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 2015
		if not taskRes.success then -- 2015
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 2015
		end -- 2015
		local compressor = __TS__New(MemoryCompressor, { -- 2022
			compressionThreshold = 0.8, -- 2023
			maxCompressionRounds = 3, -- 2024
			maxTokensPerCompression = 20000, -- 2025
			projectDir = options.workDir, -- 2026
			llmConfig = llmConfig, -- 2027
			promptPack = options.promptPack -- 2028
		}) -- 2028
		local persistedSession = compressor:getStorage():readSessionState() -- 2030
		local promptPack = compressor:getPromptPack() -- 2031
		local shared = { -- 2033
			sessionId = options.sessionId, -- 2034
			taskId = taskRes.taskId, -- 2035
			maxSteps = math.max( -- 2036
				1, -- 2036
				math.floor(options.maxSteps or 40) -- 2036
			), -- 2036
			llmMaxTry = math.max( -- 2037
				1, -- 2037
				math.floor(options.llmMaxTry or 3) -- 2037
			), -- 2037
			step = 0, -- 2038
			done = false, -- 2039
			stopToken = options.stopToken or ({stopped = false}), -- 2040
			response = "", -- 2041
			userQuery = options.prompt, -- 2042
			workingDir = options.workDir, -- 2043
			useChineseResponse = options.useChineseResponse == true, -- 2044
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "yaml"), -- 2045
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 2048
			llmConfig = llmConfig, -- 2053
			onEvent = options.onEvent, -- 2054
			promptPack = promptPack, -- 2055
			history = {}, -- 2056
			messages = persistedSession.messages, -- 2057
			memory = {lastConsolidatedMessageIndex = persistedSession.lastConsolidatedMessageIndex, compressor = compressor} -- 2059
		} -- 2059
		appendConversationMessage(shared, {role = "user", content = options.prompt}) -- 2064
		persistHistoryState(shared) -- 2068
		local ____try = __TS__AsyncAwaiter(function() -- 2068
			emitAgentEvent(shared, { -- 2071
				type = "task_started", -- 2072
				sessionId = shared.sessionId, -- 2073
				taskId = shared.taskId, -- 2074
				prompt = shared.userQuery, -- 2075
				workDir = shared.workingDir, -- 2076
				maxSteps = shared.maxSteps -- 2077
			}) -- 2077
			if shared.stopToken.stopped then -- 2077
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2080
				local result = { -- 2081
					success = false, -- 2081
					taskId = shared.taskId, -- 2081
					message = getCancelledReason(shared), -- 2081
					steps = shared.step -- 2081
				} -- 2081
				emitAgentEvent(shared, { -- 2082
					type = "task_finished", -- 2083
					sessionId = shared.sessionId, -- 2084
					taskId = shared.taskId, -- 2085
					success = false, -- 2086
					message = result.message, -- 2087
					steps = result.steps -- 2088
				}) -- 2088
				return ____awaiter_resolve(nil, result) -- 2088
			end -- 2088
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 2092
			local flow = __TS__New(CodingAgentFlow) -- 2093
			__TS__Await(flow:run(shared)) -- 2094
			if shared.stopToken.stopped then -- 2094
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2096
				local result = { -- 2097
					success = false, -- 2097
					taskId = shared.taskId, -- 2097
					message = getCancelledReason(shared), -- 2097
					steps = shared.step -- 2097
				} -- 2097
				emitAgentEvent(shared, { -- 2098
					type = "task_finished", -- 2099
					sessionId = shared.sessionId, -- 2100
					taskId = shared.taskId, -- 2101
					success = false, -- 2102
					message = result.message, -- 2103
					steps = result.steps -- 2104
				}) -- 2104
				return ____awaiter_resolve(nil, result) -- 2104
			end -- 2104
			if shared.error then -- 2104
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 2109
				local result = {success = false, taskId = shared.taskId, message = shared.response and shared.response ~= "" and shared.response or shared.error, steps = shared.step} -- 2110
				emitAgentEvent(shared, { -- 2116
					type = "task_finished", -- 2117
					sessionId = shared.sessionId, -- 2118
					taskId = shared.taskId, -- 2119
					success = false, -- 2120
					message = result.message, -- 2121
					steps = result.steps -- 2122
				}) -- 2122
				return ____awaiter_resolve(nil, result) -- 2122
			end -- 2122
			Tools.setTaskStatus(shared.taskId, "DONE") -- 2126
			local result = {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step} -- 2127
			emitAgentEvent(shared, { -- 2133
				type = "task_finished", -- 2134
				sessionId = shared.sessionId, -- 2135
				taskId = shared.taskId, -- 2136
				success = true, -- 2137
				message = result.message, -- 2138
				steps = result.steps -- 2139
			}) -- 2139
			return ____awaiter_resolve(nil, result) -- 2139
		end) -- 2139
		__TS__Await(____try.catch( -- 2070
			____try, -- 2070
			function(____, e) -- 2070
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 2143
				local result = { -- 2144
					success = false, -- 2144
					taskId = shared.taskId, -- 2144
					message = tostring(e), -- 2144
					steps = shared.step -- 2144
				} -- 2144
				emitAgentEvent(shared, { -- 2145
					type = "task_finished", -- 2146
					sessionId = shared.sessionId, -- 2147
					taskId = shared.taskId, -- 2148
					success = false, -- 2149
					message = result.message, -- 2150
					steps = result.steps -- 2151
				}) -- 2151
				return ____awaiter_resolve(nil, result) -- 2151
			end -- 2151
		)) -- 2151
	end) -- 2151
end -- 2004
function ____exports.runCodingAgent(options, callback) -- 2157
	local ____self_50 = runCodingAgentAsync(options) -- 2157
	____self_50["then"]( -- 2157
		____self_50, -- 2157
		function(____, result) return callback(result) end -- 2158
	) -- 2158
end -- 2157
return ____exports -- 2157