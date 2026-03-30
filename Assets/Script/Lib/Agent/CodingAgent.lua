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
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
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
local yaml = require("yaml") -- 7
local ____Memory = require("Agent.Memory") -- 8
local MemoryCompressor = ____Memory.MemoryCompressor -- 8
function getReplyLanguageDirective(shared) -- 365
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 366
end -- 366
function replacePromptVars(template, vars) -- 371
	local output = template -- 372
	for key in pairs(vars) do -- 373
		output = table.concat( -- 374
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 374
			vars[key] or "" or "," -- 374
		) -- 374
	end -- 374
	return output -- 376
end -- 376
function getDecisionToolDefinitions(shared) -- 501
	local base = replacePromptVars( -- 502
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 503
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 504
	) -- 504
	if (shared and shared.decisionMode) ~= "yaml" then -- 504
		return base -- 507
	end -- 507
	return base .. "\n\nYAML mode object fields:\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include a top-level reason field with a short explanation for choosing that tool.\n- For finish, do not include reason. Use only tool and params.message." -- 509
end -- 509
function persistHistoryState(shared) -- 578
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.memory.lastConsolidatedMessageIndex) -- 579
end -- 579
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 931
	if includeToolDefinitions == nil then -- 931
		includeToolDefinitions = false -- 931
	end -- 931
	local sections = { -- 932
		shared.promptPack.agentIdentityPrompt, -- 933
		getReplyLanguageDirective(shared) -- 934
	} -- 934
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 936
	if memoryContext ~= "" then -- 936
		sections[#sections + 1] = memoryContext -- 938
	end -- 938
	if includeToolDefinitions then -- 938
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 941
		if shared.decisionMode == "yaml" then -- 941
			sections[#sections + 1] = buildYamlDecisionInstruction(shared) -- 943
		end -- 943
	end -- 943
	return table.concat(sections, "\n\n") -- 946
end -- 946
function buildYamlDecisionInstruction(shared, feedback) -- 974
	return shared.promptPack.yamlDecisionFormatPrompt .. (feedback or "") -- 975
end -- 975
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 110
local HISTORY_READ_FILE_MAX_LINES = 300 -- 111
local READ_FILE_DEFAULT_LIMIT = 300 -- 112
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 113
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 114
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 115
SEARCH_DORA_API_LIMIT_MAX = 20 -- 116
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 117
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 118
local SEARCH_PREVIEW_CONTEXT = 80 -- 119
local function emitAgentEvent(shared, event) -- 162
	if shared.onEvent then -- 162
		shared:onEvent(event) -- 164
	end -- 164
end -- 162
local function getCancelledReason(shared) -- 168
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 168
		return shared.stopToken.reason -- 169
	end -- 169
	return shared.useChineseResponse and "已取消" or "cancelled" -- 170
end -- 168
local function getMaxStepsReachedReason(shared) -- 173
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 174
end -- 173
local function getFailureSummaryFallback(shared, ____error) -- 179
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 180
end -- 179
local function canWriteStepLLMDebug(shared, stepId) -- 185
	if stepId == nil then -- 185
		stepId = shared.step + 1 -- 185
	end -- 185
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 186
end -- 185
local function ensureDirRecursive(dir) -- 193
	if not dir then -- 193
		return false -- 194
	end -- 194
	if Content:exist(dir) then -- 194
		return Content:isdir(dir) -- 195
	end -- 195
	local parent = Path:getPath(dir) -- 196
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 196
		return false -- 198
	end -- 198
	return Content:mkdir(dir) -- 200
end -- 193
local function encodeDebugJSON(value) -- 203
	local text, err = json.encode(value) -- 204
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 205
end -- 203
local function getStepLLMDebugDir(shared) -- 208
	return Path( -- 209
		shared.workingDir, -- 210
		".agent", -- 211
		tostring(shared.sessionId), -- 212
		tostring(shared.taskId) -- 213
	) -- 213
end -- 208
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 217
	return Path( -- 218
		getStepLLMDebugDir(shared), -- 218
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 218
	) -- 218
end -- 217
local function getLatestStepLLMDebugSeq(shared, stepId) -- 221
	if not canWriteStepLLMDebug(shared, stepId) then -- 221
		return 0 -- 222
	end -- 222
	local dir = getStepLLMDebugDir(shared) -- 223
	if not Content:exist(dir) or not Content:isdir(dir) then -- 223
		return 0 -- 224
	end -- 224
	local latest = 0 -- 225
	for ____, file in ipairs(Content:getFiles(dir)) do -- 226
		do -- 226
			local name = Path:getFilename(file) -- 227
			local seqText = string.match( -- 228
				name, -- 228
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 228
			) -- 228
			if seqText ~= nil then -- 228
				latest = math.max( -- 230
					latest, -- 230
					tonumber(seqText) -- 230
				) -- 230
				goto __continue19 -- 231
			end -- 231
			local legacyMatch = string.match( -- 233
				name, -- 233
				("^" .. tostring(stepId)) .. "_in%.md$" -- 233
			) -- 233
			if legacyMatch ~= nil then -- 233
				latest = math.max(latest, 1) -- 235
			end -- 235
		end -- 235
		::__continue19:: -- 235
	end -- 235
	return latest -- 238
end -- 221
local function writeStepLLMDebugFile(path, content) -- 241
	if not Content:save(path, content) then -- 241
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 243
		return false -- 244
	end -- 244
	return true -- 246
end -- 241
local function createStepLLMDebugPair(shared, stepId, inContent) -- 249
	if not canWriteStepLLMDebug(shared, stepId) then -- 249
		return 0 -- 250
	end -- 250
	local dir = getStepLLMDebugDir(shared) -- 251
	if not ensureDirRecursive(dir) then -- 251
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 253
		return 0 -- 254
	end -- 254
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 256
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 257
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 258
	if not writeStepLLMDebugFile(inPath, inContent) then -- 258
		return 0 -- 260
	end -- 260
	writeStepLLMDebugFile(outPath, "") -- 262
	return seq -- 263
end -- 249
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 266
	if not canWriteStepLLMDebug(shared, stepId) then -- 266
		return -- 267
	end -- 267
	local dir = getStepLLMDebugDir(shared) -- 268
	if not ensureDirRecursive(dir) then -- 268
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 270
		return -- 271
	end -- 271
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 273
	if latestSeq <= 0 then -- 273
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 275
		writeStepLLMDebugFile(outPath, content) -- 276
		return -- 277
	end -- 277
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 279
	writeStepLLMDebugFile(outPath, content) -- 280
end -- 266
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 283
	if not canWriteStepLLMDebug(shared, stepId) then -- 283
		return -- 284
	end -- 284
	local sections = { -- 285
		"# LLM Input", -- 286
		"session_id: " .. tostring(shared.sessionId), -- 287
		"task_id: " .. tostring(shared.taskId), -- 288
		"step_id: " .. tostring(stepId), -- 289
		"phase: " .. phase, -- 290
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 291
		"## Options", -- 292
		"```json", -- 293
		encodeDebugJSON(options), -- 294
		"```" -- 295
	} -- 295
	do -- 295
		local i = 0 -- 297
		while i < #messages do -- 297
			local message = messages[i + 1] -- 298
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 299
			sections[#sections + 1] = "role: " .. (message.role or "") -- 300
			sections[#sections + 1] = "" -- 301
			sections[#sections + 1] = message.content or "" -- 302
			i = i + 1 -- 297
		end -- 297
	end -- 297
	createStepLLMDebugPair( -- 304
		shared, -- 304
		stepId, -- 304
		table.concat(sections, "\n") -- 304
	) -- 304
end -- 283
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 307
	if not canWriteStepLLMDebug(shared, stepId) then -- 307
		return -- 308
	end -- 308
	local ____array_0 = __TS__SparseArrayNew( -- 308
		"# LLM Output", -- 310
		"session_id: " .. tostring(shared.sessionId), -- 311
		"task_id: " .. tostring(shared.taskId), -- 312
		"step_id: " .. tostring(stepId), -- 313
		"phase: " .. phase, -- 314
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 315
		table.unpack(meta and ({ -- 316
			"## Meta", -- 316
			"```json", -- 316
			encodeDebugJSON(meta), -- 316
			"```" -- 316
		}) or ({})) -- 316
	) -- 316
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 316
	local sections = {__TS__SparseArraySpread(____array_0)} -- 309
	updateLatestStepLLMDebugOutput( -- 320
		shared, -- 320
		stepId, -- 320
		table.concat(sections, "\n") -- 320
	) -- 320
end -- 307
local function toJson(value) -- 323
	local text, err = json.encode(value) -- 324
	if text ~= nil then -- 324
		return text -- 325
	end -- 325
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 326
end -- 323
local function truncateText(text, maxLen) -- 329
	if #text <= maxLen then -- 329
		return text -- 330
	end -- 330
	local nextPos = utf8.offset(text, maxLen + 1) -- 331
	if nextPos == nil then -- 331
		return text -- 332
	end -- 332
	return string.sub(text, 1, nextPos - 1) .. "..." -- 333
end -- 329
local function utf8TakeHead(text, maxChars) -- 336
	if maxChars <= 0 or text == "" then -- 336
		return "" -- 337
	end -- 337
	local nextPos = utf8.offset(text, maxChars + 1) -- 338
	if nextPos == nil then -- 338
		return text -- 339
	end -- 339
	return string.sub(text, 1, nextPos - 1) -- 340
end -- 336
local function utf8TakeTail(text, maxChars) -- 343
	if maxChars <= 0 or text == "" then -- 343
		return "" -- 344
	end -- 344
	local charLen = utf8.len(text) -- 345
	if charLen == false or charLen <= maxChars then -- 345
		return text -- 346
	end -- 346
	local startChar = math.max(1, charLen - maxChars + 1) -- 347
	local startPos = utf8.offset(text, startChar) -- 348
	if startPos == nil then -- 348
		return text -- 349
	end -- 349
	return string.sub(text, startPos) -- 350
end -- 343
local function summarizeUnknown(value, maxLen) -- 353
	if maxLen == nil then -- 353
		maxLen = 320 -- 353
	end -- 353
	if value == nil then -- 353
		return "undefined" -- 354
	end -- 354
	if value == nil then -- 354
		return "null" -- 355
	end -- 355
	if type(value) == "string" then -- 355
		return __TS__StringReplace( -- 357
			truncateText(value, maxLen), -- 357
			"\n", -- 357
			"\\n" -- 357
		) -- 357
	end -- 357
	if type(value) == "number" or type(value) == "boolean" then -- 357
		return tostring(value) -- 360
	end -- 360
	return __TS__StringReplace( -- 362
		truncateText( -- 362
			toJson(value), -- 362
			maxLen -- 362
		), -- 362
		"\n", -- 362
		"\\n" -- 362
	) -- 362
end -- 353
local function limitReadContentForHistory(content, tool) -- 379
	local lines = __TS__StringSplit(content, "\n") -- 380
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 381
	local limitedByLines = overLineLimit and table.concat( -- 382
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 383
		"\n" -- 383
	) or content -- 383
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 383
		return content -- 386
	end -- 386
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 388
	local reasons = {} -- 391
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 391
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 392
	end -- 392
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 392
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 393
	end -- 393
	local hint = "Narrow the requested line range." -- 394
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 395
end -- 379
local function summarizeEditTextParamForHistory(value, key) -- 398
	if type(value) ~= "string" then -- 398
		return nil -- 399
	end -- 399
	local text = value -- 400
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 401
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 402
end -- 398
local function sanitizeReadResultForHistory(tool, result) -- 410
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 410
		return result -- 412
	end -- 412
	local clone = {} -- 414
	for key in pairs(result) do -- 415
		clone[key] = result[key] -- 416
	end -- 416
	clone.content = limitReadContentForHistory(result.content, tool) -- 418
	return clone -- 419
end -- 410
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 422
	local shown = math.min(#items, maxItems) -- 426
	local out = {} -- 427
	do -- 427
		local i = 0 -- 428
		while i < shown do -- 428
			local row = items[i + 1] -- 429
			out[#out + 1] = { -- 430
				file = row.file, -- 431
				line = row.line, -- 432
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 433
			} -- 433
			i = i + 1 -- 428
		end -- 428
	end -- 428
	return out -- 438
end -- 422
local function sanitizeSearchResultForHistory(tool, result) -- 441
	if result.success ~= true or type(result.results) ~= "table" then -- 441
		return result -- 445
	end -- 445
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 445
		return result -- 446
	end -- 446
	local clone = {} -- 447
	for key in pairs(result) do -- 448
		clone[key] = result[key] -- 449
	end -- 449
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 451
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 452
	if tool == "grep_files" and type(result.groupedResults) == "table" then -- 452
		local grouped = result.groupedResults -- 457
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 458
		local sanitizedGroups = {} -- 459
		do -- 459
			local i = 0 -- 460
			while i < shown do -- 460
				local row = grouped[i + 1] -- 461
				sanitizedGroups[#sanitizedGroups + 1] = { -- 462
					file = row.file, -- 463
					totalMatches = row.totalMatches, -- 464
					matches = type(row.matches) == "table" and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 465
				} -- 465
				i = i + 1 -- 460
			end -- 460
		end -- 460
		clone.groupedResults = sanitizedGroups -- 470
	end -- 470
	return clone -- 472
end -- 441
local function sanitizeListFilesResultForHistory(result) -- 475
	if result.success ~= true or type(result.files) ~= "table" then -- 475
		return result -- 476
	end -- 476
	local clone = {} -- 477
	for key in pairs(result) do -- 478
		clone[key] = result[key] -- 479
	end -- 479
	local files = result.files -- 481
	clone.files = __TS__ArraySlice(files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 482
	return clone -- 483
end -- 475
local function sanitizeActionParamsForHistory(tool, params) -- 486
	if tool ~= "edit_file" then -- 486
		return params -- 487
	end -- 487
	local clone = {} -- 488
	for key in pairs(params) do -- 489
		if key == "old_str" then -- 489
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 491
		elseif key == "new_str" then -- 491
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 493
		else -- 493
			clone[key] = params[key] -- 495
		end -- 495
	end -- 495
	return clone -- 498
end -- 486
local function maybeCompressHistory(shared) -- 516
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 516
		local ____shared_5 = shared -- 517
		local memory = ____shared_5.memory -- 517
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 518
		local changed = false -- 519
		do -- 519
			local round = 0 -- 520
			while round < maxRounds do -- 520
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "yaml") -- 521
				if not memory.compressor:shouldCompress(shared.messages, memory.lastConsolidatedMessageIndex, systemPrompt, "") then -- 521
					return ____awaiter_resolve(nil) -- 521
				end -- 521
				local result = __TS__Await(memory.compressor:compress( -- 530
					shared.messages, -- 531
					memory.lastConsolidatedMessageIndex, -- 532
					systemPrompt, -- 533
					"", -- 534
					shared.llmOptions, -- 535
					shared.llmMaxTry, -- 536
					shared.decisionMode -- 537
				)) -- 537
				if not (result and result.success and result.compressedCount > 0) then -- 537
					if changed then -- 537
						persistHistoryState(shared) -- 541
					end -- 541
					return ____awaiter_resolve(nil) -- 541
				end -- 541
				memory.lastConsolidatedMessageIndex = memory.lastConsolidatedMessageIndex + result.compressedCount -- 545
				changed = true -- 546
				Log( -- 547
					"Info", -- 547
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(round + 1)) .. ")" -- 547
				) -- 547
				round = round + 1 -- 520
			end -- 520
		end -- 520
		if changed then -- 520
			persistHistoryState(shared) -- 550
		end -- 550
	end) -- 550
end -- 516
local function isKnownToolName(name) -- 554
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 555
end -- 554
local function getFinishMessage(params, fallback) -- 565
	if fallback == nil then -- 565
		fallback = "" -- 565
	end -- 565
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 565
		return __TS__StringTrim(params.message) -- 567
	end -- 567
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 567
		return __TS__StringTrim(params.response) -- 570
	end -- 570
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 570
		return __TS__StringTrim(params.summary) -- 573
	end -- 573
	return __TS__StringTrim(fallback) -- 575
end -- 565
local function appendConversationMessage(shared, message) -- 585
	local ____shared_messages_6 = shared.messages -- 585
	____shared_messages_6[#____shared_messages_6 + 1] = __TS__ObjectAssign( -- 586
		{}, -- 586
		message, -- 587
		{timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 586
	) -- 586
end -- 585
local function ensureToolCallId(toolCallId) -- 592
	if toolCallId and toolCallId ~= "" then -- 592
		return toolCallId -- 593
	end -- 593
	return createLocalToolCallId() -- 594
end -- 592
local function appendToolResultMessage(shared, action) -- 597
	appendConversationMessage( -- 598
		shared, -- 598
		{ -- 598
			role = "tool", -- 599
			tool_call_id = action.toolCallId, -- 600
			name = action.tool, -- 601
			content = action.result and toJson(action.result) or "" -- 602
		} -- 602
	) -- 602
end -- 597
local function extractYAMLFromText(text) -- 606
	local source = __TS__StringTrim(text) -- 607
	local function extractFencedBlock(fence) -- 608
		local fencePos = (string.find(source, fence, nil, true) or 0) - 1 -- 609
		if fencePos < 0 then -- 609
			return nil -- 610
		end -- 610
		local firstLineEnd = (string.find( -- 611
			source, -- 611
			"\n", -- 611
			math.max(fencePos + 1, 1), -- 611
			true -- 611
		) or 0) - 1 -- 611
		if firstLineEnd < 0 then -- 611
			return nil -- 612
		end -- 612
		local searchPos = firstLineEnd + 1 -- 613
		local closingFencePositions = {} -- 614
		while searchPos < #source do -- 614
			local lineEnd = (string.find( -- 616
				source, -- 616
				"\n", -- 616
				math.max(searchPos + 1, 1), -- 616
				true -- 616
			) or 0) - 1 -- 616
			local ____end = lineEnd >= 0 and lineEnd or #source -- 617
			local line = __TS__StringTrim(__TS__StringSlice(source, searchPos, ____end)) -- 618
			if line == "```" then -- 618
				closingFencePositions[#closingFencePositions + 1] = searchPos -- 620
			end -- 620
			searchPos = ____end + 1 -- 622
		end -- 622
		do -- 622
			local i = #closingFencePositions - 1 -- 624
			while i >= 0 do -- 624
				local candidate = __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePositions[i + 1])) -- 625
				local obj = yaml.parse(candidate) -- 626
				if obj ~= nil and type(obj) == "table" then -- 626
					return candidate -- 628
				end -- 628
				i = i - 1 -- 624
			end -- 624
		end -- 624
		if #closingFencePositions > 0 then -- 624
			return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePositions[#closingFencePositions])) -- 632
		end -- 632
		return nil -- 634
	end -- 608
	local yamlBlock = extractFencedBlock("```yaml") -- 636
	if yamlBlock ~= nil then -- 636
		return yamlBlock -- 637
	end -- 637
	local ymlBlock = extractFencedBlock("```yml") -- 638
	if ymlBlock ~= nil then -- 638
		return ymlBlock -- 639
	end -- 639
	local genericBlock = extractFencedBlock("```") -- 640
	if genericBlock ~= nil then -- 640
		return genericBlock -- 641
	end -- 641
	return source -- 642
end -- 606
local function parseYAMLObjectFromText(text) -- 645
	local yamlText = extractYAMLFromText(text) -- 646
	local obj, err = yaml.parse(yamlText) -- 647
	if obj == nil or type(obj) ~= "table" then -- 647
		return { -- 649
			success = false, -- 649
			message = "invalid yaml: " .. tostring(err) -- 649
		} -- 649
	end -- 649
	return {success = true, obj = obj} -- 651
end -- 645
local function llm(shared, messages, phase) -- 663
	if phase == nil then -- 663
		phase = "decision_yaml" -- 666
	end -- 666
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 666
		local stepId = shared.step + 1 -- 668
		saveStepLLMDebugInput( -- 669
			shared, -- 669
			stepId, -- 669
			phase, -- 669
			messages, -- 669
			shared.llmOptions -- 669
		) -- 669
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 670
		if res.success then -- 670
			local ____opt_11 = res.response.choices -- 670
			local ____opt_9 = ____opt_11 and ____opt_11[1] -- 670
			local ____opt_7 = ____opt_9 and ____opt_9.message -- 670
			local text = ____opt_7 and ____opt_7.content -- 672
			if text then -- 672
				saveStepLLMDebugOutput( -- 674
					shared, -- 674
					stepId, -- 674
					phase, -- 674
					text, -- 674
					{success = true} -- 674
				) -- 674
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 674
			else -- 674
				saveStepLLMDebugOutput( -- 677
					shared, -- 677
					stepId, -- 677
					phase, -- 677
					"empty LLM response", -- 677
					{success = false} -- 677
				) -- 677
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 677
			end -- 677
		else -- 677
			saveStepLLMDebugOutput( -- 681
				shared, -- 681
				stepId, -- 681
				phase, -- 681
				res.raw or res.message, -- 681
				{success = false} -- 681
			) -- 681
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 681
		end -- 681
	end) -- 681
end -- 663
local function parseDecisionObject(rawObj) -- 698
	if type(rawObj.tool) ~= "string" then -- 698
		return {success = false, message = "missing tool"} -- 699
	end -- 699
	local tool = rawObj.tool -- 700
	if not isKnownToolName(tool) then -- 700
		return {success = false, message = "unknown tool: " .. tool} -- 702
	end -- 702
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 704
	if tool ~= "finish" and (not reason or reason == "") then -- 704
		return {success = false, message = tool .. " requires top-level reason"} -- 708
	end -- 708
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 710
	return {success = true, tool = tool, params = params, reason = reason} -- 711
end -- 698
local function parseDecisionToolCall(functionName, rawObj) -- 719
	if not isKnownToolName(functionName) then -- 719
		return {success = false, message = "unknown tool: " .. functionName} -- 721
	end -- 721
	if rawObj == nil or rawObj == nil then -- 721
		return {success = true, tool = functionName, params = {}} -- 724
	end -- 724
	if type(rawObj) ~= "table" then -- 724
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 727
	end -- 727
	return {success = true, tool = functionName, params = rawObj} -- 729
end -- 719
local function getDecisionPath(params) -- 736
	if type(params.path) == "string" then -- 736
		return __TS__StringTrim(params.path) -- 737
	end -- 737
	if type(params.target_file) == "string" then -- 737
		return __TS__StringTrim(params.target_file) -- 738
	end -- 738
	return "" -- 739
end -- 736
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 742
	local num = __TS__Number(value) -- 743
	if not __TS__NumberIsFinite(num) then -- 743
		num = fallback -- 744
	end -- 744
	num = math.floor(num) -- 745
	if num < minValue then -- 745
		num = minValue -- 746
	end -- 746
	if maxValue ~= nil and num > maxValue then -- 746
		num = maxValue -- 747
	end -- 747
	return num -- 748
end -- 742
local function validateDecision(tool, params) -- 751
	if tool == "finish" then -- 751
		local message = getFinishMessage(params) -- 756
		if message == "" then -- 756
			return {success = false, message = "finish requires params.message"} -- 757
		end -- 757
		params.message = message -- 758
		return {success = true, params = params} -- 759
	end -- 759
	if tool == "read_file" then -- 759
		local path = getDecisionPath(params) -- 763
		if path == "" then -- 763
			return {success = false, message = "read_file requires path"} -- 764
		end -- 764
		params.path = path -- 765
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 766
		local ____params_endLine_13 = params.endLine -- 767
		if ____params_endLine_13 == nil then -- 767
			____params_endLine_13 = READ_FILE_DEFAULT_LIMIT -- 767
		end -- 767
		local endLineRaw = ____params_endLine_13 -- 767
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 768
		params.startLine = startLine -- 769
		params.endLine = endLine -- 770
		return {success = true, params = params} -- 771
	end -- 771
	if tool == "edit_file" then -- 771
		local path = getDecisionPath(params) -- 775
		if path == "" then -- 775
			return {success = false, message = "edit_file requires path"} -- 776
		end -- 776
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 777
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 778
		if oldStr == newStr then -- 778
			return {success = false, message = "edit_file old_str and new_str must be different"} -- 780
		end -- 780
		params.path = path -- 782
		params.old_str = oldStr -- 783
		params.new_str = newStr -- 784
		return {success = true, params = params} -- 785
	end -- 785
	if tool == "delete_file" then -- 785
		local targetFile = getDecisionPath(params) -- 789
		if targetFile == "" then -- 789
			return {success = false, message = "delete_file requires target_file"} -- 790
		end -- 790
		params.target_file = targetFile -- 791
		return {success = true, params = params} -- 792
	end -- 792
	if tool == "grep_files" then -- 792
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 796
		if pattern == "" then -- 796
			return {success = false, message = "grep_files requires pattern"} -- 797
		end -- 797
		params.pattern = pattern -- 798
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 799
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 800
		return {success = true, params = params} -- 801
	end -- 801
	if tool == "search_dora_api" then -- 801
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 805
		if pattern == "" then -- 805
			return {success = false, message = "search_dora_api requires pattern"} -- 806
		end -- 806
		params.pattern = pattern -- 807
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 808
		return {success = true, params = params} -- 809
	end -- 809
	if tool == "glob_files" then -- 809
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 813
		return {success = true, params = params} -- 814
	end -- 814
	if tool == "build" then -- 814
		local path = getDecisionPath(params) -- 818
		if path ~= "" then -- 818
			params.path = path -- 820
		end -- 820
		return {success = true, params = params} -- 822
	end -- 822
	return {success = true, params = params} -- 825
end -- 751
local function createFunctionToolSchema(name, description, properties, required) -- 828
	if required == nil then -- 828
		required = {} -- 832
	end -- 832
	local parameters = {type = "object", properties = properties} -- 834
	if #required > 0 then -- 834
		parameters.required = required -- 839
	end -- 839
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 841
end -- 828
local function buildDecisionToolSchema() -- 851
	return { -- 852
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Parameters: path, startLine(optional), endLine(optional). Line numbering starts with 1. startLine defaults to 1 and endLine defaults to 300.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "1-based starting line number. Defaults to 1."}, endLine = {type = "number", description = "1-based ending line number. Defaults to 300."}}, {"path"}), -- 853
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 863
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 873
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 881
			path = {type = "string", description = "Base directory or file path to search within."}, -- 885
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 886
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 887
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 888
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 889
			limit = {type = "number", description = "Maximum number of results to return."}, -- 890
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 891
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 892
		}, {"pattern"}), -- 892
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 896
		createFunctionToolSchema( -- 905
			"search_dora_api", -- 906
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 906
			{ -- 908
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 909
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 910
				programmingLanguage = {type = "string", enum = { -- 911
					"ts", -- 913
					"tsx", -- 913
					"lua", -- 913
					"yue", -- 913
					"teal", -- 913
					"tl", -- 913
					"wa" -- 913
				}, description = "Preferred language variant to search."}, -- 913
				limit = { -- 916
					type = "number", -- 916
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 916
				}, -- 916
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 917
			}, -- 917
			{"pattern"} -- 919
		), -- 919
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}) -- 921
	} -- 921
end -- 851
local function getUnconsolidatedMessages(shared) -- 949
	return __TS__ArraySlice(shared.messages, shared.memory.lastConsolidatedMessageIndex) -- 950
end -- 949
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 953
	if attempt == nil then -- 953
		attempt = 1 -- 953
	end -- 953
	local messages = { -- 954
		{ -- 955
			role = "system", -- 955
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "yaml") -- 955
		}, -- 955
		table.unpack(getUnconsolidatedMessages(shared)) -- 956
	} -- 956
	if lastError and lastError ~= "" then -- 956
		local retryHeader = shared.decisionMode == "yaml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 959
		messages[#messages + 1] = { -- 962
			role = "user", -- 963
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 964
		} -- 964
	end -- 964
	return messages -- 971
end -- 953
local function buildYamlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 978
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 985
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 986
	local repairPrompt = replacePromptVars( -- 994
		shared.promptPack.yamlDecisionRepairPrompt, -- 994
		{ -- 994
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 995
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 996
			CANDIDATE_SECTION = candidateSection, -- 997
			LAST_ERROR = lastError, -- 998
			ATTEMPT = tostring(attempt) -- 999
		} -- 999
	) -- 999
	return {{role = "system", content = "You repair invalid YAML tool decisions for the Dora coding agent.\n\nYour job is only to convert the provided raw decision output into exactly one valid YAML object with keys: tool, params.\n\nRequirements:\n- Preserve the original tool name and parameter values whenever possible.\n- If the raw output uses another tool-call syntax, convert that tool name and arguments into the YAML schema.\n- Do not make a new decision, do not change the intended action unless the input is structurally impossible to represent.\n- Only repair formatting and schema shape so the output becomes valid YAML.\n- Do not continue the conversation and do not add explanations.\n- Return YAML only."}, {role = "user", content = repairPrompt}} -- 1001
end -- 978
local function tryParseAndValidateDecision(rawText) -- 1023
	local parsed = parseYAMLObjectFromText(rawText) -- 1024
	if not parsed.success then -- 1024
		return {success = false, message = parsed.message, raw = rawText} -- 1026
	end -- 1026
	local decision = parseDecisionObject(parsed.obj) -- 1028
	if not decision.success then -- 1028
		return {success = false, message = decision.message, raw = rawText} -- 1030
	end -- 1030
	local validation = validateDecision(decision.tool, decision.params) -- 1032
	if not validation.success then -- 1032
		return {success = false, message = validation.message, raw = rawText} -- 1034
	end -- 1034
	decision.params = validation.params -- 1036
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 1037
	return decision -- 1038
end -- 1023
local function normalizeLineEndings(text) -- 1041
	return table.concat( -- 1042
		__TS__StringSplit( -- 1042
			table.concat( -- 1042
				__TS__StringSplit(text, "\r\n"), -- 1042
				"\n" -- 1042
			), -- 1042
			"\r" -- 1042
		), -- 1042
		"\n" -- 1042
	) -- 1042
end -- 1041
local function replaceAllAndCount(text, oldStr, newStr) -- 1045
	text = normalizeLineEndings(text) -- 1046
	oldStr = normalizeLineEndings(oldStr) -- 1047
	newStr = normalizeLineEndings(newStr) -- 1048
	if oldStr == "" then -- 1048
		return {content = text, replaced = 0} -- 1049
	end -- 1049
	local count = 0 -- 1050
	local from = 0 -- 1051
	while true do -- 1051
		local idx = (string.find( -- 1053
			text, -- 1053
			oldStr, -- 1053
			math.max(from + 1, 1), -- 1053
			true -- 1053
		) or 0) - 1 -- 1053
		if idx < 0 then -- 1053
			break -- 1054
		end -- 1054
		count = count + 1 -- 1055
		from = idx + #oldStr -- 1056
	end -- 1056
	if count == 0 then -- 1056
		return {content = text, replaced = 0} -- 1058
	end -- 1058
	return { -- 1059
		content = table.concat( -- 1060
			__TS__StringSplit(text, oldStr), -- 1060
			newStr or "," -- 1060
		), -- 1060
		replaced = count -- 1061
	} -- 1061
end -- 1045
local MainDecisionAgent = __TS__Class() -- 1065
MainDecisionAgent.name = "MainDecisionAgent" -- 1065
__TS__ClassExtends(MainDecisionAgent, Node) -- 1065
function MainDecisionAgent.prototype.prep(self, shared) -- 1066
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1066
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1066
			return ____awaiter_resolve(nil, {shared = shared}) -- 1066
		end -- 1066
		__TS__Await(maybeCompressHistory(shared)) -- 1071
		return ____awaiter_resolve(nil, {shared = shared}) -- 1071
	end) -- 1071
end -- 1066
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 1076
	if attempt == nil then -- 1076
		attempt = 1 -- 1079
	end -- 1079
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1079
		if shared.stopToken.stopped then -- 1079
			return ____awaiter_resolve( -- 1079
				nil, -- 1079
				{ -- 1083
					success = false, -- 1083
					message = getCancelledReason(shared) -- 1083
				} -- 1083
			) -- 1083
		end -- 1083
		Log( -- 1085
			"Info", -- 1085
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1085
		) -- 1085
		local tools = buildDecisionToolSchema() -- 1086
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1087
		local stepId = shared.step + 1 -- 1088
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1089
		saveStepLLMDebugInput( -- 1093
			shared, -- 1093
			stepId, -- 1093
			"decision_tool_calling", -- 1093
			messages, -- 1093
			llmOptions -- 1093
		) -- 1093
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1094
		if shared.stopToken.stopped then -- 1094
			return ____awaiter_resolve( -- 1094
				nil, -- 1094
				{ -- 1096
					success = false, -- 1096
					message = getCancelledReason(shared) -- 1096
				} -- 1096
			) -- 1096
		end -- 1096
		if not res.success then -- 1096
			saveStepLLMDebugOutput( -- 1099
				shared, -- 1099
				stepId, -- 1099
				"decision_tool_calling", -- 1099
				res.raw or res.message, -- 1099
				{success = false} -- 1099
			) -- 1099
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1100
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1100
		end -- 1100
		saveStepLLMDebugOutput( -- 1103
			shared, -- 1103
			stepId, -- 1103
			"decision_tool_calling", -- 1103
			encodeDebugJSON(res.response), -- 1103
			{success = true} -- 1103
		) -- 1103
		local choice = res.response.choices and res.response.choices[1] -- 1104
		local message = choice and choice.message -- 1105
		local toolCalls = message and message.tool_calls -- 1106
		local toolCall = toolCalls and toolCalls[1] -- 1107
		local fn = toolCall and toolCall["function"] -- 1108
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 1109
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1112
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1115
		Log( -- 1118
			"Info", -- 1118
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1118
		) -- 1118
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1118
			if messageContent and messageContent ~= "" then -- 1118
				Log( -- 1121
					"Info", -- 1121
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1121
				) -- 1121
				return ____awaiter_resolve(nil, { -- 1121
					success = true, -- 1123
					tool = "finish", -- 1124
					params = {}, -- 1125
					reason = messageContent, -- 1126
					reasoningContent = reasoningContent, -- 1127
					directSummary = messageContent -- 1128
				}) -- 1128
			end -- 1128
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1131
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1131
		end -- 1131
		local functionName = fn.name -- 1138
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1139
		Log( -- 1140
			"Info", -- 1140
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1140
		) -- 1140
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1141
			local rawObj, err = json.decode(argsText) -- 1142
			if err ~= nil or rawObj == nil then -- 1142
				return {__error = tostring(err)} -- 1144
			end -- 1144
			return rawObj -- 1146
		end)() -- 1141
		if type(rawArgs) == "table" and rawArgs.__error ~= nil then -- 1141
			local err = tostring(rawArgs.__error) -- 1149
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1150
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1150
		end -- 1150
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1157
		if not decision.success then -- 1157
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1159
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1159
		end -- 1159
		local validation = validateDecision(decision.tool, decision.params) -- 1166
		if not validation.success then -- 1166
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1168
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1168
		end -- 1168
		decision.params = validation.params -- 1175
		decision.toolCallId = ensureToolCallId(toolCallId) -- 1176
		decision.reason = messageContent -- 1177
		decision.reasoningContent = reasoningContent -- 1178
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1179
		return ____awaiter_resolve(nil, decision) -- 1179
	end) -- 1179
end -- 1076
function MainDecisionAgent.prototype.repairDecisionYaml(self, shared, originalRaw, initialError) -- 1183
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1183
		Log( -- 1188
			"Info", -- 1188
			(("[CodingAgent] yaml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 1188
		) -- 1188
		local lastError = initialError -- 1189
		local candidateRaw = "" -- 1190
		do -- 1190
			local attempt = 0 -- 1191
			while attempt < shared.llmMaxTry do -- 1191
				do -- 1191
					Log( -- 1192
						"Info", -- 1192
						"[CodingAgent] yaml repair attempt=" .. tostring(attempt + 1) -- 1192
					) -- 1192
					local messages = buildYamlRepairMessages( -- 1193
						shared, -- 1194
						originalRaw, -- 1195
						candidateRaw, -- 1196
						lastError, -- 1197
						attempt + 1 -- 1198
					) -- 1198
					local llmRes = __TS__Await(llm(shared, messages, "decision_yaml_repair")) -- 1200
					if shared.stopToken.stopped then -- 1200
						return ____awaiter_resolve( -- 1200
							nil, -- 1200
							{ -- 1202
								success = false, -- 1202
								message = getCancelledReason(shared) -- 1202
							} -- 1202
						) -- 1202
					end -- 1202
					if not llmRes.success then -- 1202
						lastError = llmRes.message -- 1205
						Log("Error", "[CodingAgent] yaml repair attempt failed: " .. lastError) -- 1206
						goto __continue200 -- 1207
					end -- 1207
					candidateRaw = llmRes.text -- 1209
					local decision = tryParseAndValidateDecision(candidateRaw) -- 1210
					if decision.success then -- 1210
						Log("Info", "[CodingAgent] yaml repair succeeded tool=" .. decision.tool) -- 1212
						return ____awaiter_resolve(nil, decision) -- 1212
					end -- 1212
					lastError = decision.message -- 1215
					Log("Error", "[CodingAgent] yaml repair candidate invalid: " .. lastError) -- 1216
				end -- 1216
				::__continue200:: -- 1216
				attempt = attempt + 1 -- 1191
			end -- 1191
		end -- 1191
		Log("Error", "[CodingAgent] yaml repair exhausted retries: " .. lastError) -- 1218
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision yaml: " .. lastError, raw = candidateRaw}) -- 1218
	end) -- 1218
end -- 1183
function MainDecisionAgent.prototype.exec(self, input) -- 1226
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1226
		local shared = input.shared -- 1227
		if shared.stopToken.stopped then -- 1227
			return ____awaiter_resolve( -- 1227
				nil, -- 1227
				{ -- 1229
					success = false, -- 1229
					message = getCancelledReason(shared) -- 1229
				} -- 1229
			) -- 1229
		end -- 1229
		if shared.step >= shared.maxSteps then -- 1229
			Log( -- 1232
				"Warn", -- 1232
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1232
			) -- 1232
			return ____awaiter_resolve( -- 1232
				nil, -- 1232
				{ -- 1233
					success = false, -- 1233
					message = getMaxStepsReachedReason(shared) -- 1233
				} -- 1233
			) -- 1233
		end -- 1233
		if shared.decisionMode == "tool_calling" then -- 1233
			Log( -- 1237
				"Info", -- 1237
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 1237
			) -- 1237
			local lastError = "tool calling validation failed" -- 1238
			local lastRaw = "" -- 1239
			do -- 1239
				local attempt = 0 -- 1240
				while attempt < shared.llmMaxTry do -- 1240
					Log( -- 1241
						"Info", -- 1241
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1241
					) -- 1241
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 1242
					if shared.stopToken.stopped then -- 1242
						return ____awaiter_resolve( -- 1242
							nil, -- 1242
							{ -- 1249
								success = false, -- 1249
								message = getCancelledReason(shared) -- 1249
							} -- 1249
						) -- 1249
					end -- 1249
					if decision.success then -- 1249
						return ____awaiter_resolve(nil, decision) -- 1249
					end -- 1249
					lastError = decision.message -- 1254
					lastRaw = decision.raw or "" -- 1255
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1256
					attempt = attempt + 1 -- 1240
				end -- 1240
			end -- 1240
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1258
			return ____awaiter_resolve( -- 1258
				nil, -- 1258
				{ -- 1259
					success = false, -- 1259
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1259
				} -- 1259
			) -- 1259
		end -- 1259
		local lastError = "yaml validation failed" -- 1262
		local lastRaw = "" -- 1263
		do -- 1263
			local attempt = 0 -- 1264
			while attempt < shared.llmMaxTry do -- 1264
				do -- 1264
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 1265
					local llmRes = __TS__Await(llm(shared, messages, "decision_yaml")) -- 1273
					if shared.stopToken.stopped then -- 1273
						return ____awaiter_resolve( -- 1273
							nil, -- 1273
							{ -- 1275
								success = false, -- 1275
								message = getCancelledReason(shared) -- 1275
							} -- 1275
						) -- 1275
					end -- 1275
					if not llmRes.success then -- 1275
						lastError = llmRes.message -- 1278
						lastRaw = llmRes.text or "" -- 1279
						goto __continue213 -- 1280
					end -- 1280
					lastRaw = llmRes.text -- 1282
					local decision = tryParseAndValidateDecision(llmRes.text) -- 1283
					if decision.success then -- 1283
						return ____awaiter_resolve(nil, decision) -- 1283
					end -- 1283
					lastError = decision.message -- 1287
					return ____awaiter_resolve( -- 1287
						nil, -- 1287
						self:repairDecisionYaml(shared, llmRes.text, lastError) -- 1288
					) -- 1288
				end -- 1288
				::__continue213:: -- 1288
				attempt = attempt + 1 -- 1264
			end -- 1264
		end -- 1264
		return ____awaiter_resolve( -- 1264
			nil, -- 1264
			{ -- 1290
				success = false, -- 1290
				message = (("cannot produce valid decision yaml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1290
			} -- 1290
		) -- 1290
	end) -- 1290
end -- 1226
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1293
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1293
		local result = execRes -- 1294
		if not result.success then -- 1294
			shared.error = result.message -- 1296
			shared.response = getFailureSummaryFallback(shared, result.message) -- 1297
			shared.done = true -- 1298
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 1299
			persistHistoryState(shared) -- 1303
			return ____awaiter_resolve(nil, "done") -- 1303
		end -- 1303
		if result.directSummary and result.directSummary ~= "" then -- 1303
			shared.response = result.directSummary -- 1307
			shared.done = true -- 1308
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 1309
			persistHistoryState(shared) -- 1314
			return ____awaiter_resolve(nil, "done") -- 1314
		end -- 1314
		if result.tool == "finish" then -- 1314
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 1318
			shared.response = finalMessage -- 1319
			shared.done = true -- 1320
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 1321
			persistHistoryState(shared) -- 1326
			return ____awaiter_resolve(nil, "done") -- 1326
		end -- 1326
		emitAgentEvent(shared, { -- 1329
			type = "decision_made", -- 1330
			sessionId = shared.sessionId, -- 1331
			taskId = shared.taskId, -- 1332
			step = shared.step + 1, -- 1333
			tool = result.tool, -- 1334
			reason = result.reason, -- 1335
			reasoningContent = result.reasoningContent, -- 1336
			params = result.params -- 1337
		}) -- 1337
		local toolCallId = ensureToolCallId(result.toolCallId) -- 1339
		local ____shared_history_14 = shared.history -- 1339
		____shared_history_14[#____shared_history_14 + 1] = { -- 1340
			step = #shared.history + 1, -- 1341
			toolCallId = toolCallId, -- 1342
			tool = result.tool, -- 1343
			reason = result.reason or "", -- 1344
			reasoningContent = result.reasoningContent, -- 1345
			params = result.params, -- 1346
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1347
		} -- 1347
		appendConversationMessage( -- 1349
			shared, -- 1349
			{ -- 1349
				role = "assistant", -- 1350
				content = result.reason or "", -- 1351
				reasoning_content = result.reasoningContent, -- 1352
				tool_calls = {{ -- 1353
					id = toolCallId, -- 1354
					type = "function", -- 1355
					["function"] = { -- 1356
						name = result.tool, -- 1357
						arguments = toJson(result.params) -- 1358
					} -- 1358
				}} -- 1358
			} -- 1358
		) -- 1358
		persistHistoryState(shared) -- 1362
		return ____awaiter_resolve(nil, result.tool) -- 1362
	end) -- 1362
end -- 1293
local ReadFileAction = __TS__Class() -- 1367
ReadFileAction.name = "ReadFileAction" -- 1367
__TS__ClassExtends(ReadFileAction, Node) -- 1367
function ReadFileAction.prototype.prep(self, shared) -- 1368
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1368
		local last = shared.history[#shared.history] -- 1369
		if not last then -- 1369
			error( -- 1370
				__TS__New(Error, "no history"), -- 1370
				0 -- 1370
			) -- 1370
		end -- 1370
		emitAgentEvent(shared, { -- 1371
			type = "tool_started", -- 1372
			sessionId = shared.sessionId, -- 1373
			taskId = shared.taskId, -- 1374
			step = shared.step + 1, -- 1375
			tool = last.tool -- 1376
		}) -- 1376
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1378
		if __TS__StringTrim(path) == "" then -- 1378
			error( -- 1381
				__TS__New(Error, "missing path"), -- 1381
				0 -- 1381
			) -- 1381
		end -- 1381
		local ____path_17 = path -- 1383
		local ____shared_workingDir_18 = shared.workingDir -- 1385
		local ____temp_19 = shared.useChineseResponse and "zh" or "en" -- 1386
		local ____last_params_startLine_15 = last.params.startLine -- 1387
		if ____last_params_startLine_15 == nil then -- 1387
			____last_params_startLine_15 = 1 -- 1387
		end -- 1387
		local ____TS__Number_result_20 = __TS__Number(____last_params_startLine_15) -- 1387
		local ____last_params_endLine_16 = last.params.endLine -- 1388
		if ____last_params_endLine_16 == nil then -- 1388
			____last_params_endLine_16 = READ_FILE_DEFAULT_LIMIT -- 1388
		end -- 1388
		return ____awaiter_resolve( -- 1388
			nil, -- 1388
			{ -- 1382
				path = ____path_17, -- 1383
				tool = "read_file", -- 1384
				workDir = ____shared_workingDir_18, -- 1385
				docLanguage = ____temp_19, -- 1386
				startLine = ____TS__Number_result_20, -- 1387
				endLine = __TS__Number(____last_params_endLine_16) -- 1388
			} -- 1388
		) -- 1388
	end) -- 1388
end -- 1368
function ReadFileAction.prototype.exec(self, input) -- 1392
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1392
		return ____awaiter_resolve( -- 1392
			nil, -- 1392
			Tools.readFile( -- 1393
				input.workDir, -- 1394
				input.path, -- 1395
				__TS__Number(input.startLine or 1), -- 1396
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1397
				input.docLanguage -- 1398
			) -- 1398
		) -- 1398
	end) -- 1398
end -- 1392
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1402
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1402
		local result = execRes -- 1403
		local last = shared.history[#shared.history] -- 1404
		if last ~= nil then -- 1404
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1406
			appendToolResultMessage(shared, last) -- 1407
			emitAgentEvent(shared, { -- 1408
				type = "tool_finished", -- 1409
				sessionId = shared.sessionId, -- 1410
				taskId = shared.taskId, -- 1411
				step = shared.step + 1, -- 1412
				tool = last.tool, -- 1413
				result = last.result -- 1414
			}) -- 1414
		end -- 1414
		__TS__Await(maybeCompressHistory(shared)) -- 1417
		persistHistoryState(shared) -- 1418
		shared.step = shared.step + 1 -- 1419
		return ____awaiter_resolve(nil, "main") -- 1419
	end) -- 1419
end -- 1402
local SearchFilesAction = __TS__Class() -- 1424
SearchFilesAction.name = "SearchFilesAction" -- 1424
__TS__ClassExtends(SearchFilesAction, Node) -- 1424
function SearchFilesAction.prototype.prep(self, shared) -- 1425
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1425
		local last = shared.history[#shared.history] -- 1426
		if not last then -- 1426
			error( -- 1427
				__TS__New(Error, "no history"), -- 1427
				0 -- 1427
			) -- 1427
		end -- 1427
		emitAgentEvent(shared, { -- 1428
			type = "tool_started", -- 1429
			sessionId = shared.sessionId, -- 1430
			taskId = shared.taskId, -- 1431
			step = shared.step + 1, -- 1432
			tool = last.tool -- 1433
		}) -- 1433
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1433
	end) -- 1433
end -- 1425
function SearchFilesAction.prototype.exec(self, input) -- 1438
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1438
		local params = input.params -- 1439
		local ____Tools_searchFiles_34 = Tools.searchFiles -- 1440
		local ____input_workDir_27 = input.workDir -- 1441
		local ____temp_28 = params.path or "" -- 1442
		local ____temp_29 = params.pattern or "" -- 1443
		local ____params_globs_30 = params.globs -- 1444
		local ____params_useRegex_31 = params.useRegex -- 1445
		local ____params_caseSensitive_32 = params.caseSensitive -- 1446
		local ____math_max_23 = math.max -- 1449
		local ____math_floor_22 = math.floor -- 1449
		local ____params_limit_21 = params.limit -- 1449
		if ____params_limit_21 == nil then -- 1449
			____params_limit_21 = SEARCH_FILES_LIMIT_DEFAULT -- 1449
		end -- 1449
		local ____math_max_23_result_33 = ____math_max_23( -- 1449
			1, -- 1449
			____math_floor_22(__TS__Number(____params_limit_21)) -- 1449
		) -- 1449
		local ____math_max_26 = math.max -- 1450
		local ____math_floor_25 = math.floor -- 1450
		local ____params_offset_24 = params.offset -- 1450
		if ____params_offset_24 == nil then -- 1450
			____params_offset_24 = 0 -- 1450
		end -- 1450
		local result = __TS__Await(____Tools_searchFiles_34({ -- 1440
			workDir = ____input_workDir_27, -- 1441
			path = ____temp_28, -- 1442
			pattern = ____temp_29, -- 1443
			globs = ____params_globs_30, -- 1444
			useRegex = ____params_useRegex_31, -- 1445
			caseSensitive = ____params_caseSensitive_32, -- 1446
			includeContent = true, -- 1447
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1448
			limit = ____math_max_23_result_33, -- 1449
			offset = ____math_max_26( -- 1450
				0, -- 1450
				____math_floor_25(__TS__Number(____params_offset_24)) -- 1450
			), -- 1450
			groupByFile = params.groupByFile == true -- 1451
		})) -- 1451
		return ____awaiter_resolve(nil, result) -- 1451
	end) -- 1451
end -- 1438
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1456
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1456
		local last = shared.history[#shared.history] -- 1457
		if last ~= nil then -- 1457
			local result = execRes -- 1459
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1460
			appendToolResultMessage(shared, last) -- 1461
			emitAgentEvent(shared, { -- 1462
				type = "tool_finished", -- 1463
				sessionId = shared.sessionId, -- 1464
				taskId = shared.taskId, -- 1465
				step = shared.step + 1, -- 1466
				tool = last.tool, -- 1467
				result = last.result -- 1468
			}) -- 1468
		end -- 1468
		__TS__Await(maybeCompressHistory(shared)) -- 1471
		persistHistoryState(shared) -- 1472
		shared.step = shared.step + 1 -- 1473
		return ____awaiter_resolve(nil, "main") -- 1473
	end) -- 1473
end -- 1456
local SearchDoraAPIAction = __TS__Class() -- 1478
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1478
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1478
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1479
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1479
		local last = shared.history[#shared.history] -- 1480
		if not last then -- 1480
			error( -- 1481
				__TS__New(Error, "no history"), -- 1481
				0 -- 1481
			) -- 1481
		end -- 1481
		emitAgentEvent(shared, { -- 1482
			type = "tool_started", -- 1483
			sessionId = shared.sessionId, -- 1484
			taskId = shared.taskId, -- 1485
			step = shared.step + 1, -- 1486
			tool = last.tool -- 1487
		}) -- 1487
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1487
	end) -- 1487
end -- 1479
function SearchDoraAPIAction.prototype.exec(self, input) -- 1492
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1492
		local params = input.params -- 1493
		local ____Tools_searchDoraAPI_42 = Tools.searchDoraAPI -- 1494
		local ____temp_38 = params.pattern or "" -- 1495
		local ____temp_39 = params.docSource or "api" -- 1496
		local ____temp_40 = input.useChineseResponse and "zh" or "en" -- 1497
		local ____temp_41 = params.programmingLanguage or "ts" -- 1498
		local ____math_min_37 = math.min -- 1499
		local ____math_max_36 = math.max -- 1499
		local ____params_limit_35 = params.limit -- 1499
		if ____params_limit_35 == nil then -- 1499
			____params_limit_35 = 8 -- 1499
		end -- 1499
		local result = __TS__Await(____Tools_searchDoraAPI_42({ -- 1494
			pattern = ____temp_38, -- 1495
			docSource = ____temp_39, -- 1496
			docLanguage = ____temp_40, -- 1497
			programmingLanguage = ____temp_41, -- 1498
			limit = ____math_min_37( -- 1499
				SEARCH_DORA_API_LIMIT_MAX, -- 1499
				____math_max_36( -- 1499
					1, -- 1499
					__TS__Number(____params_limit_35) -- 1499
				) -- 1499
			), -- 1499
			useRegex = params.useRegex, -- 1500
			caseSensitive = false, -- 1501
			includeContent = true, -- 1502
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1503
		})) -- 1503
		return ____awaiter_resolve(nil, result) -- 1503
	end) -- 1503
end -- 1492
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1508
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1508
		local last = shared.history[#shared.history] -- 1509
		if last ~= nil then -- 1509
			local result = execRes -- 1511
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1512
			appendToolResultMessage(shared, last) -- 1513
			emitAgentEvent(shared, { -- 1514
				type = "tool_finished", -- 1515
				sessionId = shared.sessionId, -- 1516
				taskId = shared.taskId, -- 1517
				step = shared.step + 1, -- 1518
				tool = last.tool, -- 1519
				result = last.result -- 1520
			}) -- 1520
		end -- 1520
		__TS__Await(maybeCompressHistory(shared)) -- 1523
		persistHistoryState(shared) -- 1524
		shared.step = shared.step + 1 -- 1525
		return ____awaiter_resolve(nil, "main") -- 1525
	end) -- 1525
end -- 1508
local ListFilesAction = __TS__Class() -- 1530
ListFilesAction.name = "ListFilesAction" -- 1530
__TS__ClassExtends(ListFilesAction, Node) -- 1530
function ListFilesAction.prototype.prep(self, shared) -- 1531
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1531
		local last = shared.history[#shared.history] -- 1532
		if not last then -- 1532
			error( -- 1533
				__TS__New(Error, "no history"), -- 1533
				0 -- 1533
			) -- 1533
		end -- 1533
		emitAgentEvent(shared, { -- 1534
			type = "tool_started", -- 1535
			sessionId = shared.sessionId, -- 1536
			taskId = shared.taskId, -- 1537
			step = shared.step + 1, -- 1538
			tool = last.tool -- 1539
		}) -- 1539
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1539
	end) -- 1539
end -- 1531
function ListFilesAction.prototype.exec(self, input) -- 1544
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1544
		local params = input.params -- 1545
		local ____Tools_listFiles_49 = Tools.listFiles -- 1546
		local ____input_workDir_46 = input.workDir -- 1547
		local ____temp_47 = params.path or "" -- 1548
		local ____params_globs_48 = params.globs -- 1549
		local ____math_max_45 = math.max -- 1550
		local ____math_floor_44 = math.floor -- 1550
		local ____params_maxEntries_43 = params.maxEntries -- 1550
		if ____params_maxEntries_43 == nil then -- 1550
			____params_maxEntries_43 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1550
		end -- 1550
		local result = ____Tools_listFiles_49({ -- 1546
			workDir = ____input_workDir_46, -- 1547
			path = ____temp_47, -- 1548
			globs = ____params_globs_48, -- 1549
			maxEntries = ____math_max_45( -- 1550
				1, -- 1550
				____math_floor_44(__TS__Number(____params_maxEntries_43)) -- 1550
			) -- 1550
		}) -- 1550
		return ____awaiter_resolve(nil, result) -- 1550
	end) -- 1550
end -- 1544
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1555
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1555
		local last = shared.history[#shared.history] -- 1556
		if last ~= nil then -- 1556
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1558
			appendToolResultMessage(shared, last) -- 1559
			emitAgentEvent(shared, { -- 1560
				type = "tool_finished", -- 1561
				sessionId = shared.sessionId, -- 1562
				taskId = shared.taskId, -- 1563
				step = shared.step + 1, -- 1564
				tool = last.tool, -- 1565
				result = last.result -- 1566
			}) -- 1566
		end -- 1566
		__TS__Await(maybeCompressHistory(shared)) -- 1569
		persistHistoryState(shared) -- 1570
		shared.step = shared.step + 1 -- 1571
		return ____awaiter_resolve(nil, "main") -- 1571
	end) -- 1571
end -- 1555
local DeleteFileAction = __TS__Class() -- 1576
DeleteFileAction.name = "DeleteFileAction" -- 1576
__TS__ClassExtends(DeleteFileAction, Node) -- 1576
function DeleteFileAction.prototype.prep(self, shared) -- 1577
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1577
		local last = shared.history[#shared.history] -- 1578
		if not last then -- 1578
			error( -- 1579
				__TS__New(Error, "no history"), -- 1579
				0 -- 1579
			) -- 1579
		end -- 1579
		emitAgentEvent(shared, { -- 1580
			type = "tool_started", -- 1581
			sessionId = shared.sessionId, -- 1582
			taskId = shared.taskId, -- 1583
			step = shared.step + 1, -- 1584
			tool = last.tool -- 1585
		}) -- 1585
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1587
		if __TS__StringTrim(targetFile) == "" then -- 1587
			error( -- 1590
				__TS__New(Error, "missing target_file"), -- 1590
				0 -- 1590
			) -- 1590
		end -- 1590
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1590
	end) -- 1590
end -- 1577
function DeleteFileAction.prototype.exec(self, input) -- 1594
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1594
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1595
		if not result.success then -- 1595
			return ____awaiter_resolve(nil, result) -- 1595
		end -- 1595
		return ____awaiter_resolve(nil, { -- 1595
			success = true, -- 1603
			changed = true, -- 1604
			mode = "delete", -- 1605
			checkpointId = result.checkpointId, -- 1606
			checkpointSeq = result.checkpointSeq, -- 1607
			files = {{path = input.targetFile, op = "delete"}} -- 1608
		}) -- 1608
	end) -- 1608
end -- 1594
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1612
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1612
		local last = shared.history[#shared.history] -- 1613
		if last ~= nil then -- 1613
			last.result = execRes -- 1615
			appendToolResultMessage(shared, last) -- 1616
			emitAgentEvent(shared, { -- 1617
				type = "tool_finished", -- 1618
				sessionId = shared.sessionId, -- 1619
				taskId = shared.taskId, -- 1620
				step = shared.step + 1, -- 1621
				tool = last.tool, -- 1622
				result = last.result -- 1623
			}) -- 1623
			local result = last.result -- 1625
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1625
				emitAgentEvent(shared, { -- 1630
					type = "checkpoint_created", -- 1631
					sessionId = shared.sessionId, -- 1632
					taskId = shared.taskId, -- 1633
					step = shared.step + 1, -- 1634
					tool = "delete_file", -- 1635
					checkpointId = result.checkpointId, -- 1636
					checkpointSeq = result.checkpointSeq, -- 1637
					files = result.files -- 1638
				}) -- 1638
			end -- 1638
		end -- 1638
		__TS__Await(maybeCompressHistory(shared)) -- 1642
		persistHistoryState(shared) -- 1643
		shared.step = shared.step + 1 -- 1644
		return ____awaiter_resolve(nil, "main") -- 1644
	end) -- 1644
end -- 1612
local BuildAction = __TS__Class() -- 1649
BuildAction.name = "BuildAction" -- 1649
__TS__ClassExtends(BuildAction, Node) -- 1649
function BuildAction.prototype.prep(self, shared) -- 1650
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1650
		local last = shared.history[#shared.history] -- 1651
		if not last then -- 1651
			error( -- 1652
				__TS__New(Error, "no history"), -- 1652
				0 -- 1652
			) -- 1652
		end -- 1652
		emitAgentEvent(shared, { -- 1653
			type = "tool_started", -- 1654
			sessionId = shared.sessionId, -- 1655
			taskId = shared.taskId, -- 1656
			step = shared.step + 1, -- 1657
			tool = last.tool -- 1658
		}) -- 1658
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1658
	end) -- 1658
end -- 1650
function BuildAction.prototype.exec(self, input) -- 1663
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1663
		local params = input.params -- 1664
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1665
		return ____awaiter_resolve(nil, result) -- 1665
	end) -- 1665
end -- 1663
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1672
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1672
		local last = shared.history[#shared.history] -- 1673
		if last ~= nil then -- 1673
			last.result = execRes -- 1675
			appendToolResultMessage(shared, last) -- 1676
			emitAgentEvent(shared, { -- 1677
				type = "tool_finished", -- 1678
				sessionId = shared.sessionId, -- 1679
				taskId = shared.taskId, -- 1680
				step = shared.step + 1, -- 1681
				tool = last.tool, -- 1682
				result = last.result -- 1683
			}) -- 1683
		end -- 1683
		__TS__Await(maybeCompressHistory(shared)) -- 1686
		persistHistoryState(shared) -- 1687
		shared.step = shared.step + 1 -- 1688
		return ____awaiter_resolve(nil, "main") -- 1688
	end) -- 1688
end -- 1672
local EditFileAction = __TS__Class() -- 1693
EditFileAction.name = "EditFileAction" -- 1693
__TS__ClassExtends(EditFileAction, Node) -- 1693
function EditFileAction.prototype.prep(self, shared) -- 1694
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1694
		local last = shared.history[#shared.history] -- 1695
		if not last then -- 1695
			error( -- 1696
				__TS__New(Error, "no history"), -- 1696
				0 -- 1696
			) -- 1696
		end -- 1696
		emitAgentEvent(shared, { -- 1697
			type = "tool_started", -- 1698
			sessionId = shared.sessionId, -- 1699
			taskId = shared.taskId, -- 1700
			step = shared.step + 1, -- 1701
			tool = last.tool -- 1702
		}) -- 1702
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1704
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1707
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1708
		if __TS__StringTrim(path) == "" then -- 1708
			error( -- 1709
				__TS__New(Error, "missing path"), -- 1709
				0 -- 1709
			) -- 1709
		end -- 1709
		if oldStr == newStr then -- 1709
			error( -- 1710
				__TS__New(Error, "old_str and new_str must be different"), -- 1710
				0 -- 1710
			) -- 1710
		end -- 1710
		return ____awaiter_resolve(nil, { -- 1710
			path = path, -- 1711
			oldStr = oldStr, -- 1711
			newStr = newStr, -- 1711
			taskId = shared.taskId, -- 1711
			workDir = shared.workingDir -- 1711
		}) -- 1711
	end) -- 1711
end -- 1694
function EditFileAction.prototype.exec(self, input) -- 1714
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1714
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1715
		if not readRes.success then -- 1715
			if input.oldStr ~= "" then -- 1715
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1715
			end -- 1715
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1720
			if not createRes.success then -- 1720
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1720
			end -- 1720
			return ____awaiter_resolve(nil, { -- 1720
				success = true, -- 1728
				changed = true, -- 1729
				mode = "create", -- 1730
				replaced = 0, -- 1731
				checkpointId = createRes.checkpointId, -- 1732
				checkpointSeq = createRes.checkpointSeq, -- 1733
				files = {{path = input.path, op = "create"}} -- 1734
			}) -- 1734
		end -- 1734
		if input.oldStr == "" then -- 1734
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 1734
		end -- 1734
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 1741
		if replaceRes.replaced == 0 then -- 1741
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 1741
		end -- 1741
		if replaceRes.content == readRes.content then -- 1741
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 1741
		end -- 1741
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1754
		if not applyRes.success then -- 1754
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1754
		end -- 1754
		return ____awaiter_resolve(nil, { -- 1754
			success = true, -- 1762
			changed = true, -- 1763
			mode = "replace", -- 1764
			replaced = replaceRes.replaced, -- 1765
			checkpointId = applyRes.checkpointId, -- 1766
			checkpointSeq = applyRes.checkpointSeq, -- 1767
			files = {{path = input.path, op = "write"}} -- 1768
		}) -- 1768
	end) -- 1768
end -- 1714
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1772
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1772
		local last = shared.history[#shared.history] -- 1773
		if last ~= nil then -- 1773
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1775
			last.result = execRes -- 1776
			appendToolResultMessage(shared, last) -- 1777
			emitAgentEvent(shared, { -- 1778
				type = "tool_finished", -- 1779
				sessionId = shared.sessionId, -- 1780
				taskId = shared.taskId, -- 1781
				step = shared.step + 1, -- 1782
				tool = last.tool, -- 1783
				result = last.result -- 1784
			}) -- 1784
			local result = last.result -- 1786
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1786
				emitAgentEvent(shared, { -- 1791
					type = "checkpoint_created", -- 1792
					sessionId = shared.sessionId, -- 1793
					taskId = shared.taskId, -- 1794
					step = shared.step + 1, -- 1795
					tool = last.tool, -- 1796
					checkpointId = result.checkpointId, -- 1797
					checkpointSeq = result.checkpointSeq, -- 1798
					files = result.files -- 1799
				}) -- 1799
			end -- 1799
		end -- 1799
		__TS__Await(maybeCompressHistory(shared)) -- 1803
		persistHistoryState(shared) -- 1804
		shared.step = shared.step + 1 -- 1805
		return ____awaiter_resolve(nil, "main") -- 1805
	end) -- 1805
end -- 1772
local EndNode = __TS__Class() -- 1810
EndNode.name = "EndNode" -- 1810
__TS__ClassExtends(EndNode, Node) -- 1810
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 1811
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1811
		return ____awaiter_resolve(nil, nil) -- 1811
	end) -- 1811
end -- 1811
local CodingAgentFlow = __TS__Class() -- 1816
CodingAgentFlow.name = "CodingAgentFlow" -- 1816
__TS__ClassExtends(CodingAgentFlow, Flow) -- 1816
function CodingAgentFlow.prototype.____constructor(self) -- 1817
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 1818
	local read = __TS__New(ReadFileAction, 1, 0) -- 1819
	local search = __TS__New(SearchFilesAction, 1, 0) -- 1820
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 1821
	local list = __TS__New(ListFilesAction, 1, 0) -- 1822
	local del = __TS__New(DeleteFileAction, 1, 0) -- 1823
	local build = __TS__New(BuildAction, 1, 0) -- 1824
	local edit = __TS__New(EditFileAction, 1, 0) -- 1825
	local done = __TS__New(EndNode, 1, 0) -- 1826
	main:on("read_file", read) -- 1828
	main:on("grep_files", search) -- 1829
	main:on("search_dora_api", searchDora) -- 1830
	main:on("glob_files", list) -- 1831
	main:on("delete_file", del) -- 1832
	main:on("build", build) -- 1833
	main:on("edit_file", edit) -- 1834
	main:on("done", done) -- 1835
	read:on("main", main) -- 1837
	search:on("main", main) -- 1838
	searchDora:on("main", main) -- 1839
	list:on("main", main) -- 1840
	del:on("main", main) -- 1841
	build:on("main", main) -- 1842
	edit:on("main", main) -- 1843
	Flow.prototype.____constructor(self, main) -- 1845
end -- 1817
local function runCodingAgentAsync(options) -- 1849
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1849
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 1849
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 1849
		end -- 1849
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 1853
		if not llmConfigRes.success then -- 1853
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 1853
		end -- 1853
		local llmConfig = llmConfigRes.config -- 1859
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 1860
		if not taskRes.success then -- 1860
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 1860
		end -- 1860
		local compressor = __TS__New(MemoryCompressor, { -- 1867
			compressionThreshold = 0.8, -- 1868
			maxCompressionRounds = 3, -- 1869
			maxTokensPerCompression = 20000, -- 1870
			projectDir = options.workDir, -- 1871
			llmConfig = llmConfig, -- 1872
			promptPack = options.promptPack -- 1873
		}) -- 1873
		local persistedSession = compressor:getStorage():readSessionState() -- 1875
		local promptPack = compressor:getPromptPack() -- 1876
		local shared = { -- 1878
			sessionId = options.sessionId, -- 1879
			taskId = taskRes.taskId, -- 1880
			maxSteps = math.max( -- 1881
				1, -- 1881
				math.floor(options.maxSteps or 40) -- 1881
			), -- 1881
			llmMaxTry = math.max( -- 1882
				1, -- 1882
				math.floor(options.llmMaxTry or 3) -- 1882
			), -- 1882
			step = 0, -- 1883
			done = false, -- 1884
			stopToken = options.stopToken or ({stopped = false}), -- 1885
			response = "", -- 1886
			userQuery = options.prompt, -- 1887
			workingDir = options.workDir, -- 1888
			useChineseResponse = options.useChineseResponse == true, -- 1889
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "yaml"), -- 1890
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 1893
			llmConfig = llmConfig, -- 1898
			onEvent = options.onEvent, -- 1899
			promptPack = promptPack, -- 1900
			history = {}, -- 1901
			messages = persistedSession.messages, -- 1902
			memory = {lastConsolidatedMessageIndex = persistedSession.lastConsolidatedMessageIndex, compressor = compressor} -- 1904
		} -- 1904
		appendConversationMessage(shared, {role = "user", content = options.prompt}) -- 1909
		persistHistoryState(shared) -- 1913
		local ____try = __TS__AsyncAwaiter(function() -- 1913
			emitAgentEvent(shared, { -- 1916
				type = "task_started", -- 1917
				sessionId = shared.sessionId, -- 1918
				taskId = shared.taskId, -- 1919
				prompt = shared.userQuery, -- 1920
				workDir = shared.workingDir, -- 1921
				maxSteps = shared.maxSteps -- 1922
			}) -- 1922
			if shared.stopToken.stopped then -- 1922
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1925
				local result = { -- 1926
					success = false, -- 1926
					taskId = shared.taskId, -- 1926
					message = getCancelledReason(shared), -- 1926
					steps = shared.step -- 1926
				} -- 1926
				emitAgentEvent(shared, { -- 1927
					type = "task_finished", -- 1928
					sessionId = shared.sessionId, -- 1929
					taskId = shared.taskId, -- 1930
					success = false, -- 1931
					message = result.message, -- 1932
					steps = result.steps -- 1933
				}) -- 1933
				return ____awaiter_resolve(nil, result) -- 1933
			end -- 1933
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 1937
			local flow = __TS__New(CodingAgentFlow) -- 1938
			__TS__Await(flow:run(shared)) -- 1939
			if shared.stopToken.stopped then -- 1939
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1941
				local result = { -- 1942
					success = false, -- 1942
					taskId = shared.taskId, -- 1942
					message = getCancelledReason(shared), -- 1942
					steps = shared.step -- 1942
				} -- 1942
				emitAgentEvent(shared, { -- 1943
					type = "task_finished", -- 1944
					sessionId = shared.sessionId, -- 1945
					taskId = shared.taskId, -- 1946
					success = false, -- 1947
					message = result.message, -- 1948
					steps = result.steps -- 1949
				}) -- 1949
				return ____awaiter_resolve(nil, result) -- 1949
			end -- 1949
			if shared.error then -- 1949
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1954
				local result = {success = false, taskId = shared.taskId, message = shared.response and shared.response ~= "" and shared.response or shared.error, steps = shared.step} -- 1955
				emitAgentEvent(shared, { -- 1961
					type = "task_finished", -- 1962
					sessionId = shared.sessionId, -- 1963
					taskId = shared.taskId, -- 1964
					success = false, -- 1965
					message = result.message, -- 1966
					steps = result.steps -- 1967
				}) -- 1967
				return ____awaiter_resolve(nil, result) -- 1967
			end -- 1967
			Tools.setTaskStatus(shared.taskId, "DONE") -- 1971
			local result = {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step} -- 1972
			emitAgentEvent(shared, { -- 1978
				type = "task_finished", -- 1979
				sessionId = shared.sessionId, -- 1980
				taskId = shared.taskId, -- 1981
				success = true, -- 1982
				message = result.message, -- 1983
				steps = result.steps -- 1984
			}) -- 1984
			return ____awaiter_resolve(nil, result) -- 1984
		end) -- 1984
		__TS__Await(____try.catch( -- 1915
			____try, -- 1915
			function(____, e) -- 1915
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1988
				local result = { -- 1989
					success = false, -- 1989
					taskId = shared.taskId, -- 1989
					message = tostring(e), -- 1989
					steps = shared.step -- 1989
				} -- 1989
				emitAgentEvent(shared, { -- 1990
					type = "task_finished", -- 1991
					sessionId = shared.sessionId, -- 1992
					taskId = shared.taskId, -- 1993
					success = false, -- 1994
					message = result.message, -- 1995
					steps = result.steps -- 1996
				}) -- 1996
				return ____awaiter_resolve(nil, result) -- 1996
			end -- 1996
		)) -- 1996
	end) -- 1996
end -- 1849
function ____exports.runCodingAgent(options, callback) -- 2002
	local ____self_50 = runCodingAgentAsync(options) -- 2002
	____self_50["then"]( -- 2002
		____self_50, -- 2002
		function(____, result) return callback(result) end -- 2003
	) -- 2003
end -- 2002
return ____exports -- 2002