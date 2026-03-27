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
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local ____exports = {} -- 1
local toJson, truncateText, utf8TakeHead, summarizeUnknown, limitReadContentForHistory, pushLimitedMatches, formatHistorySummary, persistHistoryState, HISTORY_READ_FILE_MAX_CHARS, HISTORY_READ_FILE_MAX_LINES, HISTORY_SEARCH_FILES_MAX_MATCHES, HISTORY_SEARCH_DORA_API_MAX_MATCHES, HISTORY_LIST_FILES_MAX_ENTRIES -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Path = ____Dora.Path -- 2
local json = ____Dora.json -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local Content = ____Dora.Content -- 2
local wait = ____Dora.wait -- 2
local emit = ____Dora.emit -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local ____Utils = require("Agent.Utils") -- 4
local callLLMStream = ____Utils.callLLMStream -- 4
local callLLM = ____Utils.callLLM -- 4
local Log = ____Utils.Log -- 4
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 4
local estimateTextTokens = ____Utils.estimateTextTokens -- 4
local clipTextToTokenBudget = ____Utils.clipTextToTokenBudget -- 4
local Tools = require("Agent.Tools") -- 6
local yaml = require("yaml") -- 7
local ____Memory = require("Agent.Memory") -- 8
local MemoryCompressor = ____Memory.MemoryCompressor -- 8
local DEFAULT_AGENT_PROMPT_PACK = ____Memory.DEFAULT_AGENT_PROMPT_PACK -- 8
function toJson(value) -- 329
	local text, err = json.encode(value) -- 330
	if text ~= nil then -- 330
		return text -- 331
	end -- 331
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 332
end -- 332
function truncateText(text, maxLen) -- 335
	if #text <= maxLen then -- 335
		return text -- 336
	end -- 336
	local nextPos = utf8.offset(text, maxLen + 1) -- 337
	if nextPos == nil then -- 337
		return text -- 338
	end -- 338
	return string.sub(text, 1, nextPos - 1) .. "..." -- 339
end -- 339
function utf8TakeHead(text, maxChars) -- 342
	if maxChars <= 0 or text == "" then -- 342
		return "" -- 343
	end -- 343
	local nextPos = utf8.offset(text, maxChars + 1) -- 344
	if nextPos == nil then -- 344
		return text -- 345
	end -- 345
	return string.sub(text, 1, nextPos - 1) -- 346
end -- 346
function summarizeUnknown(value, maxLen) -- 359
	if maxLen == nil then -- 359
		maxLen = 320 -- 359
	end -- 359
	if value == nil then -- 359
		return "undefined" -- 360
	end -- 360
	if value == nil then -- 360
		return "null" -- 361
	end -- 361
	if type(value) == "string" then -- 361
		return __TS__StringReplace( -- 363
			truncateText(value, maxLen), -- 363
			"\n", -- 363
			"\\n" -- 363
		) -- 363
	end -- 363
	if type(value) == "number" or type(value) == "boolean" then -- 363
		return tostring(value) -- 366
	end -- 366
	return __TS__StringReplace( -- 368
		truncateText( -- 368
			toJson(value), -- 368
			maxLen -- 368
		), -- 368
		"\n", -- 368
		"\\n" -- 368
	) -- 368
end -- 368
function limitReadContentForHistory(content, tool) -- 385
	local lines = __TS__StringSplit(content, "\n") -- 386
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 387
	local limitedByLines = overLineLimit and table.concat( -- 388
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 389
		"\n" -- 389
	) or content -- 389
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 389
		return content -- 392
	end -- 392
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 394
	local reasons = {} -- 397
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 397
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 398
	end -- 398
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 398
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 399
	end -- 399
	local hint = "Narrow the requested line range." -- 400
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 401
end -- 401
function pushLimitedMatches(lines, items, maxItems, mapper) -- 516
	local shown = math.min(#items, maxItems) -- 522
	do -- 522
		local j = 0 -- 523
		while j < shown do -- 523
			lines[#lines + 1] = mapper(items[j + 1], j) -- 524
			j = j + 1 -- 523
		end -- 523
	end -- 523
	if #items > shown then -- 523
		lines[#lines + 1] = ("  ... " .. tostring(#items - shown)) .. " more omitted" -- 527
	end -- 527
end -- 527
function formatHistorySummary(history) -- 596
	if #history == 0 then -- 596
		return "No previous actions." -- 598
	end -- 598
	local actions = history -- 600
	local lines = {} -- 601
	lines[#lines + 1] = "" -- 602
	do -- 602
		local i = 0 -- 603
		while i < #actions do -- 603
			local action = actions[i + 1] -- 604
			lines[#lines + 1] = ("Action " .. tostring(i + 1)) .. ":" -- 605
			lines[#lines + 1] = "- Tool: " .. action.tool -- 606
			if action.params and type(action.params) == "table" and ({next(action.params)}) ~= nil then -- 606
				lines[#lines + 1] = "- Parameters:" -- 608
				for key in pairs(action.params) do -- 609
					lines[#lines + 1] = (("  - " .. key) .. ": ") .. summarizeUnknown(action.params[key], 2000) -- 610
				end -- 610
			end -- 610
			if action.result and type(action.result) == "table" then -- 610
				local result = action.result -- 614
				local success = result.success == true -- 615
				if action.tool == "build" then -- 615
					if not success and type(result.message) == "string" then -- 615
						lines[#lines + 1] = "- Result: Failed" -- 618
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 1200) -- 619
					elseif type(result.messages) == "table" then -- 619
						local messages = result.messages -- 621
						local successCount = 0 -- 622
						local failedCount = 0 -- 623
						do -- 623
							local j = 0 -- 624
							while j < #messages do -- 624
								if messages[j + 1].success == true then -- 624
									successCount = successCount + 1 -- 625
								else -- 625
									failedCount = failedCount + 1 -- 626
								end -- 626
								j = j + 1 -- 624
							end -- 624
						end -- 624
						lines[#lines + 1] = "- Result: " .. (failedCount > 0 and "Completed With Errors" or "Success") -- 628
						lines[#lines + 1] = ((("- Build summary: " .. tostring(successCount)) .. " succeeded, ") .. tostring(failedCount)) .. " failed" -- 629
						if #messages > 0 then -- 629
							lines[#lines + 1] = "- Build details:" -- 631
							local shown = math.min(#messages, 12) -- 632
							do -- 632
								local j = 0 -- 633
								while j < shown do -- 633
									local item = messages[j + 1] -- 634
									local file = type(item.file) == "string" and item.file or "(unknown)" -- 635
									if item.success == true then -- 635
										lines[#lines + 1] = (("  " .. tostring(j + 1)) .. ". OK ") .. file -- 637
									else -- 637
										local message = type(item.message) == "string" and truncateText(item.message, 400) or "build failed" -- 639
										lines[#lines + 1] = (((("  " .. tostring(j + 1)) .. ". FAIL ") .. file) .. ": ") .. message -- 642
									end -- 642
									j = j + 1 -- 633
								end -- 633
							end -- 633
							if #messages > shown then -- 633
								lines[#lines + 1] = ("  ... " .. tostring(#messages - shown)) .. " more omitted" -- 646
							end -- 646
						end -- 646
					else -- 646
						lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 650
					end -- 650
				elseif action.tool == "read_file" then -- 650
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 653
					if success and type(result.content) == "string" then -- 653
						lines[#lines + 1] = "- Content:" -- 655
						lines[#lines + 1] = limitReadContentForHistory(result.content, action.tool) -- 656
						if result.startLine ~= nil or result.endLine ~= nil or result.totalLines ~= nil then -- 656
							lines[#lines + 1] = (((("- Range: " .. (result.startLine ~= nil and tostring(result.startLine) or "?")) .. "-") .. (result.endLine ~= nil and tostring(result.endLine) or "?")) .. " / total ") .. (result.totalLines ~= nil and tostring(result.totalLines) or "?") -- 658
						end -- 658
					elseif not success and type(result.message) == "string" then -- 658
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 600) -- 663
					end -- 663
				elseif action.tool == "grep_files" then -- 663
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 666
					if success and type(result.results) == "table" then -- 666
						local matches = result.results -- 668
						local totalMatches = type(result.totalResults) == "number" and result.totalResults or #matches -- 669
						lines[#lines + 1] = "- Matches: " .. tostring(totalMatches) -- 672
						lines[#lines + 1] = "- Next: Immediately read the relevant file from the potentially related results to gather more information." -- 673
						if type(result.offset) == "number" and type(result.limit) == "number" then -- 673
							lines[#lines + 1] = (("- Page: offset=" .. tostring(result.offset)) .. " limit=") .. tostring(result.limit) -- 675
						end -- 675
						if result.hasMore == true and result.nextOffset ~= nil then -- 675
							lines[#lines + 1] = "- More: continue with offset=" .. tostring(result.nextOffset) -- 678
						end -- 678
						if type(result.groupedResults) == "table" then -- 678
							local groups = result.groupedResults -- 681
							lines[#lines + 1] = "- Groups:" -- 682
							pushLimitedMatches( -- 683
								lines, -- 683
								groups, -- 683
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 683
								function(g, index) -- 683
									local file = type(g.file) == "string" and g.file or "" -- 684
									local total = g.totalMatches ~= nil and tostring(g.totalMatches) or "?" -- 685
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. ": ") .. total) .. " matches" -- 686
								end -- 683
							) -- 683
						else -- 683
							pushLimitedMatches( -- 689
								lines, -- 689
								matches, -- 689
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 689
								function(m, index) -- 689
									local file = type(m.file) == "string" and m.file or "" -- 690
									local line = m.line ~= nil and tostring(m.line) or "" -- 691
									local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 692
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 693
								end -- 689
							) -- 689
						end -- 689
					end -- 689
				elseif action.tool == "search_dora_api" then -- 689
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 698
					if success and type(result.results) == "table" then -- 698
						local hits = result.results -- 700
						local totalHits = type(result.totalResults) == "number" and result.totalResults or #hits -- 701
						lines[#lines + 1] = "- Matches: " .. tostring(totalHits) -- 704
						pushLimitedMatches( -- 705
							lines, -- 705
							hits, -- 705
							HISTORY_SEARCH_DORA_API_MAX_MATCHES, -- 705
							function(m, index) -- 705
								local file = type(m.file) == "string" and m.file or "" -- 706
								local line = m.line ~= nil and tostring(m.line) or "" -- 707
								local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 708
								return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 709
							end -- 705
						) -- 705
					end -- 705
				elseif action.tool == "edit_file" then -- 705
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 713
					if success then -- 713
						if result.mode ~= nil then -- 713
							lines[#lines + 1] = "- Mode: " .. tostring(result.mode) -- 716
						end -- 716
						if result.replaced ~= nil then -- 716
							lines[#lines + 1] = "- Replaced: " .. tostring(result.replaced) -- 719
						end -- 719
					end -- 719
				elseif action.tool == "glob_files" then -- 719
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 723
					if success and type(result.files) == "table" then -- 723
						local files = result.files -- 725
						local totalEntries = type(result.totalEntries) == "number" and result.totalEntries or #files -- 726
						lines[#lines + 1] = "- Entries: " .. tostring(totalEntries) -- 729
						lines[#lines + 1] = "- Next: Immediately read the relevant file snippets from the potentially related results to gather more information." -- 730
						lines[#lines + 1] = "- Directory structure:" -- 731
						if #files > 0 then -- 731
							local shown = math.min(#files, HISTORY_LIST_FILES_MAX_ENTRIES) -- 733
							do -- 733
								local j = 0 -- 734
								while j < shown do -- 734
									lines[#lines + 1] = "  " .. files[j + 1] -- 735
									j = j + 1 -- 734
								end -- 734
							end -- 734
							if #files > shown then -- 734
								lines[#lines + 1] = ("  ... " .. tostring(#files - shown)) .. " more omitted" -- 738
							end -- 738
						else -- 738
							lines[#lines + 1] = "  (Empty or inaccessible directory)" -- 741
						end -- 741
					end -- 741
				else -- 741
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 745
					lines[#lines + 1] = "- Detail: " .. truncateText( -- 746
						toJson(result), -- 746
						4000 -- 746
					) -- 746
				end -- 746
			elseif action.result ~= nil then -- 746
				lines[#lines + 1] = "- Result: " .. summarizeUnknown(action.result, 3000) -- 749
			else -- 749
				lines[#lines + 1] = "- Result: pending" -- 751
			end -- 751
			if i < #actions - 1 then -- 751
				lines[#lines + 1] = "" -- 753
			end -- 753
			i = i + 1 -- 603
		end -- 603
	end -- 603
	return table.concat(lines, "\n") -- 755
end -- 755
function persistHistoryState(shared) -- 758
	shared.memory.compressor:getStorage():writeSessionState(shared.history, shared.memory.lastConsolidatedIndex) -- 759
end -- 759
HISTORY_READ_FILE_MAX_CHARS = 12000 -- 117
HISTORY_READ_FILE_MAX_LINES = 300 -- 118
local READ_FILE_DEFAULT_LIMIT = 300 -- 119
HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 120
HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 121
HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 122
local DECISION_HISTORY_MAX_CHARS = 16000 -- 123
local SEARCH_DORA_API_LIMIT_MAX = 20 -- 124
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 125
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 126
local SEARCH_PREVIEW_CONTEXT = 80 -- 127
local function emitAgentEvent(shared, event) -- 168
	if shared.onEvent then -- 168
		shared:onEvent(event) -- 170
	end -- 170
end -- 168
local function getCancelledReason(shared) -- 174
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 174
		return shared.stopToken.reason -- 175
	end -- 175
	return shared.useChineseResponse and "已取消" or "cancelled" -- 176
end -- 174
local function getMaxStepsReachedReason(shared) -- 179
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 180
end -- 179
local function getFailureSummaryFallback(shared, ____error) -- 185
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 186
end -- 185
local function canWriteStepLLMDebug(shared, stepId) -- 191
	if stepId == nil then -- 191
		stepId = shared.step + 1 -- 191
	end -- 191
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 192
end -- 191
local function ensureDirRecursive(dir) -- 199
	if not dir then -- 199
		return false -- 200
	end -- 200
	if Content:exist(dir) then -- 200
		return Content:isdir(dir) -- 201
	end -- 201
	local parent = Path:getPath(dir) -- 202
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 202
		return false -- 204
	end -- 204
	return Content:mkdir(dir) -- 206
end -- 199
local function encodeDebugJSON(value) -- 209
	local text, err = json.encode(value) -- 210
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 211
end -- 209
local function getStepLLMDebugDir(shared) -- 214
	return Path( -- 215
		shared.workingDir, -- 216
		".agent", -- 217
		tostring(shared.sessionId), -- 218
		tostring(shared.taskId) -- 219
	) -- 219
end -- 214
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 223
	return Path( -- 224
		getStepLLMDebugDir(shared), -- 224
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 224
	) -- 224
end -- 223
local function getLatestStepLLMDebugSeq(shared, stepId) -- 227
	if not canWriteStepLLMDebug(shared, stepId) then -- 227
		return 0 -- 228
	end -- 228
	local dir = getStepLLMDebugDir(shared) -- 229
	if not Content:exist(dir) or not Content:isdir(dir) then -- 229
		return 0 -- 230
	end -- 230
	local latest = 0 -- 231
	for ____, file in ipairs(Content:getFiles(dir)) do -- 232
		do -- 232
			local name = Path:getFilename(file) -- 233
			local seqText = string.match( -- 234
				name, -- 234
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 234
			) -- 234
			if seqText ~= nil then -- 234
				latest = math.max( -- 236
					latest, -- 236
					tonumber(seqText) -- 236
				) -- 236
				goto __continue19 -- 237
			end -- 237
			local legacyMatch = string.match( -- 239
				name, -- 239
				("^" .. tostring(stepId)) .. "_in%.md$" -- 239
			) -- 239
			if legacyMatch ~= nil then -- 239
				latest = math.max(latest, 1) -- 241
			end -- 241
		end -- 241
		::__continue19:: -- 241
	end -- 241
	return latest -- 244
end -- 227
local function writeStepLLMDebugFile(path, content) -- 247
	if not Content:save(path, content) then -- 247
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 249
		return false -- 250
	end -- 250
	return true -- 252
end -- 247
local function createStepLLMDebugPair(shared, stepId, inContent) -- 255
	if not canWriteStepLLMDebug(shared, stepId) then -- 255
		return 0 -- 256
	end -- 256
	local dir = getStepLLMDebugDir(shared) -- 257
	if not ensureDirRecursive(dir) then -- 257
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 259
		return 0 -- 260
	end -- 260
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 262
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 263
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 264
	if not writeStepLLMDebugFile(inPath, inContent) then -- 264
		return 0 -- 266
	end -- 266
	writeStepLLMDebugFile(outPath, "") -- 268
	return seq -- 269
end -- 255
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 272
	if not canWriteStepLLMDebug(shared, stepId) then -- 272
		return -- 273
	end -- 273
	local dir = getStepLLMDebugDir(shared) -- 274
	if not ensureDirRecursive(dir) then -- 274
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 276
		return -- 277
	end -- 277
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 279
	if latestSeq <= 0 then -- 279
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 281
		writeStepLLMDebugFile(outPath, content) -- 282
		return -- 283
	end -- 283
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 285
	writeStepLLMDebugFile(outPath, content) -- 286
end -- 272
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 289
	if not canWriteStepLLMDebug(shared, stepId) then -- 289
		return -- 290
	end -- 290
	local sections = { -- 291
		"# LLM Input", -- 292
		"session_id: " .. tostring(shared.sessionId), -- 293
		"task_id: " .. tostring(shared.taskId), -- 294
		"step_id: " .. tostring(stepId), -- 295
		"phase: " .. phase, -- 296
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 297
		"## Options", -- 298
		"```json", -- 299
		encodeDebugJSON(options), -- 300
		"```" -- 301
	} -- 301
	do -- 301
		local i = 0 -- 303
		while i < #messages do -- 303
			local message = messages[i + 1] -- 304
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 305
			sections[#sections + 1] = "role: " .. (message.role or "") -- 306
			sections[#sections + 1] = "" -- 307
			sections[#sections + 1] = message.content or "" -- 308
			i = i + 1 -- 303
		end -- 303
	end -- 303
	createStepLLMDebugPair( -- 310
		shared, -- 310
		stepId, -- 310
		table.concat(sections, "\n") -- 310
	) -- 310
end -- 289
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 313
	if not canWriteStepLLMDebug(shared, stepId) then -- 313
		return -- 314
	end -- 314
	local ____array_0 = __TS__SparseArrayNew( -- 314
		"# LLM Output", -- 316
		"session_id: " .. tostring(shared.sessionId), -- 317
		"task_id: " .. tostring(shared.taskId), -- 318
		"step_id: " .. tostring(stepId), -- 319
		"phase: " .. phase, -- 320
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 321
		table.unpack(meta and ({ -- 322
			"## Meta", -- 322
			"```json", -- 322
			encodeDebugJSON(meta), -- 322
			"```" -- 322
		}) or ({})) -- 322
	) -- 322
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 322
	local sections = {__TS__SparseArraySpread(____array_0)} -- 315
	updateLatestStepLLMDebugOutput( -- 326
		shared, -- 326
		stepId, -- 326
		table.concat(sections, "\n") -- 326
	) -- 326
end -- 313
local function utf8TakeTail(text, maxChars) -- 349
	if maxChars <= 0 or text == "" then -- 349
		return "" -- 350
	end -- 350
	local charLen = utf8.len(text) -- 351
	if charLen == false or charLen <= maxChars then -- 351
		return text -- 352
	end -- 352
	local startChar = math.max(1, charLen - maxChars + 1) -- 353
	local startPos = utf8.offset(text, startChar) -- 354
	if startPos == nil then -- 354
		return text -- 355
	end -- 355
	return string.sub(text, startPos) -- 356
end -- 349
local function getReplyLanguageDirective(shared) -- 371
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 372
end -- 371
local function replacePromptVars(template, vars) -- 377
	local output = template -- 378
	for key in pairs(vars) do -- 379
		output = table.concat( -- 380
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 380
			vars[key] or "" or "," -- 380
		) -- 380
	end -- 380
	return output -- 382
end -- 377
local function summarizeEditTextParamForHistory(value, key) -- 404
	if type(value) ~= "string" then -- 404
		return nil -- 405
	end -- 405
	local text = value -- 406
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 407
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 408
end -- 404
local function sanitizeReadResultForHistory(tool, result) -- 416
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 416
		return result -- 418
	end -- 418
	local clone = {} -- 420
	for key in pairs(result) do -- 421
		clone[key] = result[key] -- 422
	end -- 422
	clone.content = limitReadContentForHistory(result.content, tool) -- 424
	return clone -- 425
end -- 416
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 428
	local shown = math.min(#items, maxItems) -- 432
	local out = {} -- 433
	do -- 433
		local i = 0 -- 434
		while i < shown do -- 434
			local row = items[i + 1] -- 435
			out[#out + 1] = { -- 436
				file = row.file, -- 437
				line = row.line, -- 438
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 439
			} -- 439
			i = i + 1 -- 434
		end -- 434
	end -- 434
	return out -- 444
end -- 428
local function sanitizeSearchResultForHistory(tool, result) -- 447
	if result.success ~= true or type(result.results) ~= "table" then -- 447
		return result -- 451
	end -- 451
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 451
		return result -- 452
	end -- 452
	local clone = {} -- 453
	for key in pairs(result) do -- 454
		clone[key] = result[key] -- 455
	end -- 455
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 457
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 458
	if tool == "grep_files" and type(result.groupedResults) == "table" then -- 458
		local grouped = result.groupedResults -- 463
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 464
		local sanitizedGroups = {} -- 465
		do -- 465
			local i = 0 -- 466
			while i < shown do -- 466
				local row = grouped[i + 1] -- 467
				sanitizedGroups[#sanitizedGroups + 1] = { -- 468
					file = row.file, -- 469
					totalMatches = row.totalMatches, -- 470
					matches = type(row.matches) == "table" and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 471
				} -- 471
				i = i + 1 -- 466
			end -- 466
		end -- 466
		clone.groupedResults = sanitizedGroups -- 476
	end -- 476
	return clone -- 478
end -- 447
local function sanitizeListFilesResultForHistory(result) -- 481
	if result.success ~= true or type(result.files) ~= "table" then -- 481
		return result -- 482
	end -- 482
	local clone = {} -- 483
	for key in pairs(result) do -- 484
		clone[key] = result[key] -- 485
	end -- 485
	local files = result.files -- 487
	clone.files = __TS__ArraySlice(files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 488
	return clone -- 489
end -- 481
local function sanitizeActionParamsForHistory(tool, params) -- 492
	if tool ~= "edit_file" then -- 492
		return params -- 493
	end -- 493
	local clone = {} -- 494
	for key in pairs(params) do -- 495
		if key == "old_str" then -- 495
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 497
		elseif key == "new_str" then -- 497
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 499
		else -- 499
			clone[key] = params[key] -- 501
		end -- 501
	end -- 501
	return clone -- 504
end -- 492
local function trimPromptContext(text, maxChars, label) -- 507
	if #text <= maxChars then -- 507
		return text -- 508
	end -- 508
	local keepHead = math.max( -- 509
		0, -- 509
		math.floor(maxChars * 0.35) -- 509
	) -- 509
	local keepTail = math.max(0, maxChars - keepHead) -- 510
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 511
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 512
	return (((((("[history summary truncated for " .. label) .. "; showing head and tail within ") .. tostring(maxChars)) .. " chars]\n") .. head) .. "\n...\n") .. tail -- 513
end -- 507
local function formatHistorySummaryForDecision(history) -- 531
	return trimPromptContext( -- 532
		formatHistorySummary(history), -- 532
		DECISION_HISTORY_MAX_CHARS, -- 532
		"decision" -- 532
	) -- 532
end -- 531
local function getDecisionSystemPrompt(shared) -- 535
	return shared and shared.promptPack.agentIdentityPrompt or DEFAULT_AGENT_PROMPT_PACK.agentIdentityPrompt -- 536
end -- 535
local function getDecisionToolDefinitions(shared) -- 539
	return replacePromptVars( -- 540
		shared and shared.promptPack.toolDefinitionsDetailed or DEFAULT_AGENT_PROMPT_PACK.toolDefinitionsDetailed, -- 541
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 542
	) -- 542
end -- 539
local function maybeCompressHistory(shared) -- 546
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 546
		local ____shared_5 = shared -- 547
		local memory = ____shared_5.memory -- 547
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 548
		local changed = false -- 549
		do -- 549
			local round = 0 -- 550
			while round < maxRounds do -- 550
				if not memory.compressor:shouldCompress( -- 550
					shared.userQuery, -- 552
					shared.history, -- 553
					memory.lastConsolidatedIndex, -- 554
					getDecisionSystemPrompt(shared), -- 555
					getDecisionToolDefinitions(shared), -- 556
					formatHistorySummary -- 557
				) then -- 557
					return ____awaiter_resolve(nil) -- 557
				end -- 557
				local result = __TS__Await(memory.compressor:compress( -- 561
					shared.userQuery, -- 562
					shared.history, -- 563
					memory.lastConsolidatedIndex, -- 564
					shared.llmOptions, -- 565
					formatHistorySummary, -- 566
					shared.llmMaxTry, -- 567
					shared.decisionMode -- 568
				)) -- 568
				if not (result and result.success and result.compressedCount > 0) then -- 568
					if changed then -- 568
						persistHistoryState(shared) -- 572
					end -- 572
					return ____awaiter_resolve(nil) -- 572
				end -- 572
				memory.lastConsolidatedIndex = memory.lastConsolidatedIndex + result.compressedCount -- 576
				changed = true -- 577
				Log( -- 578
					"Info", -- 578
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " history records (round ") .. tostring(round + 1)) .. ")" -- 578
				) -- 578
				round = round + 1 -- 550
			end -- 550
		end -- 550
		if changed then -- 550
			persistHistoryState(shared) -- 581
		end -- 581
	end) -- 581
end -- 546
local function isKnownToolName(name) -- 585
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 586
end -- 585
local function extractYAMLFromText(text) -- 765
	local source = __TS__StringTrim(text) -- 766
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 767
	if yamlFencePos >= 0 then -- 767
		local from = yamlFencePos + #"```yaml" -- 769
		local ____end = (string.find( -- 770
			source, -- 770
			"```", -- 770
			math.max(from + 1, 1), -- 770
			true -- 770
		) or 0) - 1 -- 770
		if ____end > from then -- 770
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 771
		end -- 771
	end -- 771
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 773
	if ymlFencePos >= 0 then -- 773
		local from = ymlFencePos + #"```yml" -- 775
		local ____end = (string.find( -- 776
			source, -- 776
			"```", -- 776
			math.max(from + 1, 1), -- 776
			true -- 776
		) or 0) - 1 -- 776
		if ____end > from then -- 776
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 777
		end -- 777
	end -- 777
	local fencePos = (string.find(source, "```", nil, true) or 0) - 1 -- 779
	if fencePos >= 0 then -- 779
		local firstLineEnd = (string.find( -- 781
			source, -- 781
			"\n", -- 781
			math.max(fencePos + 1, 1), -- 781
			true -- 781
		) or 0) - 1 -- 781
		local ____end = (string.find( -- 782
			source, -- 782
			"```", -- 782
			math.max((firstLineEnd >= 0 and firstLineEnd + 1 or fencePos + 3) + 1, 1), -- 782
			true -- 782
		) or 0) - 1 -- 782
		if firstLineEnd >= 0 and ____end > firstLineEnd then -- 782
			return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, ____end)) -- 784
		end -- 784
	end -- 784
	return source -- 787
end -- 765
local function parseYAMLObjectFromText(text) -- 790
	local yamlText = extractYAMLFromText(text) -- 791
	local obj, err = yaml.parse(yamlText) -- 792
	if obj == nil or type(obj) ~= "table" then -- 792
		return { -- 794
			success = false, -- 794
			message = "invalid yaml: " .. tostring(err) -- 794
		} -- 794
	end -- 794
	return {success = true, obj = obj} -- 796
end -- 790
local function llm(shared, messages) -- 808
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 808
		local stepId = shared.step + 1 -- 809
		saveStepLLMDebugInput( -- 810
			shared, -- 810
			stepId, -- 810
			"decision_yaml", -- 810
			messages, -- 810
			shared.llmOptions -- 810
		) -- 810
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 811
		if res.success then -- 811
			local ____opt_10 = res.response.choices -- 811
			local ____opt_8 = ____opt_10 and ____opt_10[1] -- 811
			local ____opt_6 = ____opt_8 and ____opt_8.message -- 811
			local text = ____opt_6 and ____opt_6.content -- 813
			if text then -- 813
				saveStepLLMDebugOutput( -- 815
					shared, -- 815
					stepId, -- 815
					"decision_yaml", -- 815
					text, -- 815
					{success = true} -- 815
				) -- 815
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 815
			else -- 815
				saveStepLLMDebugOutput( -- 818
					shared, -- 818
					stepId, -- 818
					"decision_yaml", -- 818
					"empty LLM response", -- 818
					{success = false} -- 818
				) -- 818
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 818
			end -- 818
		else -- 818
			saveStepLLMDebugOutput( -- 822
				shared, -- 822
				stepId, -- 822
				"decision_yaml", -- 822
				res.raw or res.message, -- 822
				{success = false} -- 822
			) -- 822
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 822
		end -- 822
	end) -- 822
end -- 808
local function llmStream(shared, messages) -- 827
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 827
		local text = "" -- 828
		local cancelledReason -- 829
		local done = false -- 830
		if shared.stopToken.stopped then -- 830
			return ____awaiter_resolve( -- 830
				nil, -- 830
				{ -- 833
					success = false, -- 833
					message = getCancelledReason(shared), -- 833
					text = text -- 833
				} -- 833
			) -- 833
		end -- 833
		done = false -- 835
		cancelledReason = nil -- 836
		text = "" -- 837
		local stepId = shared.step -- 838
		saveStepLLMDebugInput( -- 839
			shared, -- 839
			stepId, -- 839
			"final_summary", -- 839
			messages, -- 839
			shared.llmOptions -- 839
		) -- 839
		callLLMStream( -- 840
			messages, -- 841
			shared.llmOptions, -- 842
			{ -- 843
				id = nil, -- 844
				stopToken = shared.stopToken, -- 845
				onData = function(data) -- 846
					if shared.stopToken.stopped then -- 846
						return true -- 847
					end -- 847
					local choice = data.choices and data.choices[1] -- 848
					local delta = choice and choice.delta -- 849
					if delta and type(delta.content) == "string" then -- 849
						local content = delta.content -- 851
						text = text .. content -- 852
						emitAgentEvent(shared, { -- 853
							type = "summary_stream", -- 854
							sessionId = shared.sessionId, -- 855
							taskId = shared.taskId, -- 856
							textDelta = content, -- 857
							fullText = text -- 858
						}) -- 858
						local res = json.encode({name = "LLMStream", content = content}) -- 860
						if res ~= nil then -- 860
							emit("AppWS", "Send", res) -- 862
						end -- 862
					end -- 862
					return false -- 865
				end, -- 846
				onCancel = function(reason) -- 867
					cancelledReason = reason -- 868
					done = true -- 869
				end, -- 867
				onDone = function() -- 871
					done = true -- 872
				end -- 871
			}, -- 871
			shared.llmConfig -- 875
		) -- 875
		__TS__Await(__TS__New( -- 878
			__TS__Promise, -- 878
			function(____, resolve) -- 878
				Director.systemScheduler:schedule(once(function() -- 879
					wait(function() return done or shared.stopToken.stopped end) -- 880
					resolve(nil) -- 881
				end)) -- 879
			end -- 878
		)) -- 878
		if shared.stopToken.stopped then -- 878
			cancelledReason = getCancelledReason(shared) -- 885
		end -- 885
		if not cancelledReason and text == "" then -- 885
			cancelledReason = "empty LLM output" -- 889
		end -- 889
		saveStepLLMDebugOutput( -- 891
			shared, -- 891
			stepId, -- 891
			"final_summary", -- 891
			cancelledReason and (("CANCELLED: " .. cancelledReason) .. "\n\n") .. text or text, -- 891
			{stream = true, cancelled = cancelledReason ~= nil} -- 891
		) -- 891
		if cancelledReason then -- 891
			return ____awaiter_resolve(nil, {success = false, message = cancelledReason, text = text}) -- 891
		end -- 891
		return ____awaiter_resolve(nil, {success = true, text = text}) -- 891
	end) -- 891
end -- 827
local function parseDecisionObject(rawObj) -- 911
	if type(rawObj.tool) ~= "string" then -- 911
		return {success = false, message = "missing tool"} -- 912
	end -- 912
	local tool = rawObj.tool -- 913
	if not isKnownToolName(tool) then -- 913
		return {success = false, message = "unknown tool: " .. tool} -- 915
	end -- 915
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 917
	return {success = true, tool = tool, params = params} -- 918
end -- 911
local function parseDecisionToolCall(functionName, rawObj) -- 921
	if not isKnownToolName(functionName) then -- 921
		return {success = false, message = "unknown tool: " .. functionName} -- 923
	end -- 923
	if rawObj == nil or rawObj == nil then -- 923
		return {success = true, tool = functionName, params = {}} -- 926
	end -- 926
	if type(rawObj) ~= "table" then -- 926
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 929
	end -- 929
	return {success = true, tool = functionName, params = rawObj} -- 931
end -- 921
local function getDecisionPath(params) -- 938
	if type(params.path) == "string" then -- 938
		return __TS__StringTrim(params.path) -- 939
	end -- 939
	if type(params.target_file) == "string" then -- 939
		return __TS__StringTrim(params.target_file) -- 940
	end -- 940
	return "" -- 941
end -- 938
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 944
	local num = __TS__Number(value) -- 945
	if not __TS__NumberIsFinite(num) then -- 945
		num = fallback -- 946
	end -- 946
	num = math.floor(num) -- 947
	if num < minValue then -- 947
		num = minValue -- 948
	end -- 948
	if maxValue ~= nil and num > maxValue then -- 948
		num = maxValue -- 949
	end -- 949
	return num -- 950
end -- 944
local function validateDecision(tool, params) -- 953
	if tool == "finish" then -- 953
		return {success = true, params = params} -- 957
	end -- 957
	if tool == "read_file" then -- 957
		local path = getDecisionPath(params) -- 960
		if path == "" then -- 960
			return {success = false, message = "read_file requires path"} -- 961
		end -- 961
		params.path = path -- 962
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 963
		local ____params_endLine_12 = params.endLine -- 964
		if ____params_endLine_12 == nil then -- 964
			____params_endLine_12 = READ_FILE_DEFAULT_LIMIT -- 964
		end -- 964
		local endLineRaw = ____params_endLine_12 -- 964
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 965
		params.startLine = startLine -- 966
		params.endLine = endLine -- 967
		return {success = true, params = params} -- 968
	end -- 968
	if tool == "edit_file" then -- 968
		local path = getDecisionPath(params) -- 972
		if path == "" then -- 972
			return {success = false, message = "edit_file requires path"} -- 973
		end -- 973
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 974
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 975
		if oldStr == newStr then -- 975
			return {success = false, message = "edit_file old_str and new_str must be different"} -- 977
		end -- 977
		params.path = path -- 979
		params.old_str = oldStr -- 980
		params.new_str = newStr -- 981
		return {success = true, params = params} -- 982
	end -- 982
	if tool == "delete_file" then -- 982
		local targetFile = getDecisionPath(params) -- 986
		if targetFile == "" then -- 986
			return {success = false, message = "delete_file requires target_file"} -- 987
		end -- 987
		params.target_file = targetFile -- 988
		return {success = true, params = params} -- 989
	end -- 989
	if tool == "grep_files" then -- 989
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 993
		if pattern == "" then -- 993
			return {success = false, message = "grep_files requires pattern"} -- 994
		end -- 994
		params.pattern = pattern -- 995
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 996
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 997
		return {success = true, params = params} -- 998
	end -- 998
	if tool == "search_dora_api" then -- 998
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1002
		if pattern == "" then -- 1002
			return {success = false, message = "search_dora_api requires pattern"} -- 1003
		end -- 1003
		params.pattern = pattern -- 1004
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1005
		return {success = true, params = params} -- 1006
	end -- 1006
	if tool == "glob_files" then -- 1006
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1010
		return {success = true, params = params} -- 1011
	end -- 1011
	if tool == "build" then -- 1011
		local path = getDecisionPath(params) -- 1015
		if path ~= "" then -- 1015
			params.path = path -- 1017
		end -- 1017
		return {success = true, params = params} -- 1019
	end -- 1019
	return {success = true, params = params} -- 1022
end -- 953
local function createFunctionToolSchema(name, description, properties, required) -- 1025
	if required == nil then -- 1025
		required = {} -- 1029
	end -- 1029
	local parameters = {type = "object", properties = properties} -- 1031
	if #required > 0 then -- 1031
		parameters.required = required -- 1036
	end -- 1036
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1038
end -- 1025
local function buildDecisionToolSchema() -- 1048
	return { -- 1049
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Parameters: path, startLine(optional), endLine(optional). Line numbering starts with 1. startLine defaults to 1 and endLine defaults to 300.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "1-based starting line number. Defaults to 1."}, endLine = {type = "number", description = "1-based ending line number. Defaults to 300."}}, {"path"}), -- 1050
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 1060
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1070
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1078
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1082
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1083
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1084
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1085
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1086
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1087
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1088
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1089
		}, {"pattern"}), -- 1089
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1093
		createFunctionToolSchema( -- 1102
			"search_dora_api", -- 1103
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1103
			{ -- 1105
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1106
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1107
				programmingLanguage = {type = "string", enum = { -- 1108
					"ts", -- 1110
					"tsx", -- 1110
					"lua", -- 1110
					"yue", -- 1110
					"teal", -- 1110
					"tl", -- 1110
					"wa" -- 1110
				}, description = "Preferred language variant to search."}, -- 1110
				limit = { -- 1113
					type = "number", -- 1113
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1113
				}, -- 1113
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1114
			}, -- 1114
			{"pattern"} -- 1116
		), -- 1116
		createFunctionToolSchema("build", "Run build/checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). After one build completes, do not run build again unless files were edited or deleted. Read the result and then finish or take corrective action.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 1118
		createFunctionToolSchema("finish", "End the task and let the agent summarize the outcome.", {}) -- 1125
	} -- 1125
end -- 1048
local function buildDecisionPrompt(shared, userQuery, historyText, memoryContext) -- 1133
	local toolDefinitions = shared.decisionMode == "yaml" and replacePromptVars( -- 1134
		shared.promptPack.toolDefinitionsDetailed, -- 1135
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1135
	) or "" -- 1135
	local memorySection = memoryContext -- 1139
	local toolSection = toolDefinitions ~= "" and "### Available Tools\n\n" .. toolDefinitions or "" -- 1140
	local staticPrompt = (((((shared.promptPack.decisionIntroPrompt .. "\n\n") .. memorySection) .. "\n\n### Current User Request\n\n### Action History\n\n") .. toolSection) .. "\n\n### Decision Rules\n\n") .. shared.promptPack.decisionRulesPrompt -- 1145
	local contextWindow = math.max(4000, shared.llmConfig.contextWindow) -- 1158
	local reservedOutputTokens = math.max( -- 1159
		1024, -- 1159
		math.floor(contextWindow * 0.2) -- 1159
	) -- 1159
	local staticTokens = estimateTextTokens(staticPrompt) -- 1160
	local dynamicBudget = math.max(1200, contextWindow - reservedOutputTokens - staticTokens - 256) -- 1161
	local boundedUserQuery = clipTextToTokenBudget( -- 1162
		userQuery, -- 1162
		math.max( -- 1162
			400, -- 1162
			math.floor(dynamicBudget * 0.4) -- 1162
		) -- 1162
	) -- 1162
	local boundedHistory = clipTextToTokenBudget( -- 1163
		historyText, -- 1163
		math.max( -- 1163
			400, -- 1163
			math.floor(dynamicBudget * 0.35) -- 1163
		) -- 1163
	) -- 1163
	local boundedMemory = clipTextToTokenBudget( -- 1164
		memoryContext, -- 1164
		math.max( -- 1164
			240, -- 1164
			math.floor(dynamicBudget * 0.25) -- 1164
		) -- 1164
	) -- 1164
	local boundedMemorySection = boundedMemory ~= "" and boundedMemory .. "\n" or "" -- 1165
	local toolSectionText = toolDefinitions ~= "" and ("### Available Tools\n\n" .. toolDefinitions) .. "\n" or "" -- 1169
	return (((((((((shared.promptPack.decisionIntroPrompt .. "\n\n") .. boundedMemorySection) .. "### Current User Request\n\n") .. boundedUserQuery) .. "\n\n### Action History\n\n") .. boundedHistory) .. "\n\n") .. toolSectionText) .. "### Decision Rules\n\n") .. shared.promptPack.decisionRulesPrompt -- 1175
end -- 1133
local function normalizeLineEndings(text) -- 1190
	return table.concat( -- 1191
		__TS__StringSplit( -- 1191
			table.concat( -- 1191
				__TS__StringSplit(text, "\r\n"), -- 1191
				"\n" -- 1191
			), -- 1191
			"\r" -- 1191
		), -- 1191
		"\n" -- 1191
	) -- 1191
end -- 1190
local function replaceAllAndCount(text, oldStr, newStr) -- 1194
	text = normalizeLineEndings(text) -- 1195
	oldStr = normalizeLineEndings(oldStr) -- 1196
	newStr = normalizeLineEndings(newStr) -- 1197
	if oldStr == "" then -- 1197
		return {content = text, replaced = 0} -- 1198
	end -- 1198
	local count = 0 -- 1199
	local from = 0 -- 1200
	while true do -- 1200
		local idx = (string.find( -- 1202
			text, -- 1202
			oldStr, -- 1202
			math.max(from + 1, 1), -- 1202
			true -- 1202
		) or 0) - 1 -- 1202
		if idx < 0 then -- 1202
			break -- 1203
		end -- 1203
		count = count + 1 -- 1204
		from = idx + #oldStr -- 1205
	end -- 1205
	if count == 0 then -- 1205
		return {content = text, replaced = 0} -- 1207
	end -- 1207
	return { -- 1208
		content = table.concat( -- 1209
			__TS__StringSplit(text, oldStr), -- 1209
			newStr or "," -- 1209
		), -- 1209
		replaced = count -- 1210
	} -- 1210
end -- 1194
local MainDecisionAgent = __TS__Class() -- 1214
MainDecisionAgent.name = "MainDecisionAgent" -- 1214
__TS__ClassExtends(MainDecisionAgent, Node) -- 1214
function MainDecisionAgent.prototype.prep(self, shared) -- 1215
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1215
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1215
			return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 1215
		end -- 1215
		__TS__Await(maybeCompressHistory(shared)) -- 1224
		return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 1224
	end) -- 1224
end -- 1215
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, prompt, lastError, attempt, lastRaw) -- 1233
	if attempt == nil then -- 1233
		attempt = 1 -- 1237
	end -- 1237
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1237
		if shared.stopToken.stopped then -- 1237
			return ____awaiter_resolve( -- 1237
				nil, -- 1237
				{ -- 1241
					success = false, -- 1241
					message = getCancelledReason(shared) -- 1241
				} -- 1241
			) -- 1241
		end -- 1241
		Log( -- 1243
			"Info", -- 1243
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1243
		) -- 1243
		local tools = buildDecisionToolSchema() -- 1244
		local messages = { -- 1245
			{ -- 1246
				role = "system", -- 1247
				content = table.concat( -- 1248
					{ -- 1248
						shared.promptPack.agentIdentityPrompt, -- 1249
						getReplyLanguageDirective(shared) -- 1250
					}, -- 1250
					"\n" -- 1251
				) -- 1251
			}, -- 1251
			{ -- 1253
				role = "user", -- 1254
				content = lastError and (((((prompt .. "\n\n") .. replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError})) .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") or prompt -- 1255
			} -- 1255
		} -- 1255
		local stepId = shared.step + 1 -- 1264
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1265
		saveStepLLMDebugInput( -- 1269
			shared, -- 1269
			stepId, -- 1269
			"decision_tool_calling", -- 1269
			messages, -- 1269
			llmOptions -- 1269
		) -- 1269
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1270
		if shared.stopToken.stopped then -- 1270
			return ____awaiter_resolve( -- 1270
				nil, -- 1270
				{ -- 1272
					success = false, -- 1272
					message = getCancelledReason(shared) -- 1272
				} -- 1272
			) -- 1272
		end -- 1272
		if not res.success then -- 1272
			saveStepLLMDebugOutput( -- 1275
				shared, -- 1275
				stepId, -- 1275
				"decision_tool_calling", -- 1275
				res.raw or res.message, -- 1275
				{success = false} -- 1275
			) -- 1275
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1276
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1276
		end -- 1276
		saveStepLLMDebugOutput( -- 1279
			shared, -- 1279
			stepId, -- 1279
			"decision_tool_calling", -- 1279
			encodeDebugJSON(res.response), -- 1279
			{success = true} -- 1279
		) -- 1279
		local choice = res.response.choices and res.response.choices[1] -- 1280
		local message = choice and choice.message -- 1281
		local toolCalls = message and message.tool_calls -- 1282
		local toolCall = toolCalls and toolCalls[1] -- 1283
		local fn = toolCall and toolCall["function"] -- 1284
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1285
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1288
		Log( -- 1291
			"Info", -- 1291
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1291
		) -- 1291
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1291
			if messageContent and messageContent ~= "" then -- 1291
				Log( -- 1294
					"Info", -- 1294
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1294
				) -- 1294
				return ____awaiter_resolve(nil, { -- 1294
					success = true, -- 1296
					tool = "finish", -- 1297
					params = {}, -- 1298
					reason = messageContent, -- 1299
					reasoningContent = reasoningContent, -- 1300
					directSummary = messageContent -- 1301
				}) -- 1301
			end -- 1301
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1304
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1304
		end -- 1304
		local functionName = fn.name -- 1311
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1312
		Log( -- 1313
			"Info", -- 1313
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1313
		) -- 1313
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1314
			local rawObj, err = json.decode(argsText) -- 1315
			if err ~= nil or rawObj == nil then -- 1315
				return {__error = tostring(err)} -- 1317
			end -- 1317
			return rawObj -- 1319
		end)() -- 1314
		if type(rawArgs) == "table" and rawArgs.__error ~= nil then -- 1314
			local err = tostring(rawArgs.__error) -- 1322
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1323
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1323
		end -- 1323
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1330
		if not decision.success then -- 1330
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1332
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1332
		end -- 1332
		local validation = validateDecision(decision.tool, decision.params) -- 1339
		if not validation.success then -- 1339
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1341
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1341
		end -- 1341
		decision.params = validation.params -- 1348
		decision.reason = messageContent -- 1349
		decision.reasoningContent = reasoningContent -- 1350
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1351
		return ____awaiter_resolve(nil, decision) -- 1351
	end) -- 1351
end -- 1233
function MainDecisionAgent.prototype.exec(self, input) -- 1355
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1355
		local shared = input.shared -- 1356
		if shared.stopToken.stopped then -- 1356
			return ____awaiter_resolve( -- 1356
				nil, -- 1356
				{ -- 1358
					success = false, -- 1358
					message = getCancelledReason(shared) -- 1358
				} -- 1358
			) -- 1358
		end -- 1358
		if shared.step >= shared.maxSteps then -- 1358
			Log( -- 1361
				"Warn", -- 1361
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1361
			) -- 1361
			return ____awaiter_resolve( -- 1361
				nil, -- 1361
				{ -- 1362
					success = false, -- 1362
					message = getMaxStepsReachedReason(shared) -- 1362
				} -- 1362
			) -- 1362
		end -- 1362
		local memory = shared.memory -- 1362
		local memoryContext = memory.compressor:getStorage():getMemoryContext() -- 1367
		local uncompressedHistory = __TS__ArraySlice(input.history, memory.lastConsolidatedIndex) -- 1372
		local historyText = formatHistorySummaryForDecision(uncompressedHistory) -- 1373
		local prompt = buildDecisionPrompt(input.shared, input.userQuery, historyText, memoryContext) -- 1375
		if shared.decisionMode == "tool_calling" then -- 1375
			Log( -- 1378
				"Info", -- 1378
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " history=") .. tostring(#uncompressedHistory) -- 1378
			) -- 1378
			local lastError = "tool calling validation failed" -- 1379
			local lastRaw = "" -- 1380
			do -- 1380
				local attempt = 0 -- 1381
				while attempt < shared.llmMaxTry do -- 1381
					Log( -- 1382
						"Info", -- 1382
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1382
					) -- 1382
					local decision = __TS__Await(self:callDecisionByToolCalling( -- 1383
						shared, -- 1384
						prompt, -- 1385
						attempt > 0 and lastError or nil, -- 1386
						attempt + 1, -- 1387
						lastRaw -- 1388
					)) -- 1388
					if shared.stopToken.stopped then -- 1388
						return ____awaiter_resolve( -- 1388
							nil, -- 1388
							{ -- 1391
								success = false, -- 1391
								message = getCancelledReason(shared) -- 1391
							} -- 1391
						) -- 1391
					end -- 1391
					if decision.success then -- 1391
						return ____awaiter_resolve(nil, decision) -- 1391
					end -- 1391
					lastError = decision.message -- 1396
					lastRaw = decision.raw or "" -- 1397
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1398
					attempt = attempt + 1 -- 1381
				end -- 1381
			end -- 1381
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1400
			return ____awaiter_resolve( -- 1400
				nil, -- 1400
				{ -- 1401
					success = false, -- 1401
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1401
				} -- 1401
			) -- 1401
		end -- 1401
		local yamlPrompt = ((prompt .. "\n\n") .. shared.promptPack.yamlDecisionFormatPrompt) .. "\n- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.\n- Keep params shallow and valid for the selected tool.\n- Use tabs for all indentation, never spaces.\nIf no more actions are needed, use tool: finish." -- 1404
		local lastError = "yaml validation failed" -- 1412
		local lastRaw = "" -- 1413
		do -- 1413
			local attempt = 0 -- 1414
			while attempt < shared.llmMaxTry do -- 1414
				do -- 1414
					local feedback = attempt > 0 and (((("\n\nPrevious response was invalid (" .. lastError) .. "). Retry attempt: ") .. tostring(attempt + 1)) .. ". Return exactly one valid YAML object only and keep YAML indentation strictly consistent. The next reply must differ from the rejected one.") .. (lastRaw ~= "" and "\nLast rejected output summary: " .. truncateText(lastRaw, 300) or "") or "" -- 1415
					local messages = {{role = "user", content = yamlPrompt .. feedback}} -- 1418
					local llmRes = __TS__Await(llm(shared, messages)) -- 1419
					if shared.stopToken.stopped then -- 1419
						return ____awaiter_resolve( -- 1419
							nil, -- 1419
							{ -- 1421
								success = false, -- 1421
								message = getCancelledReason(shared) -- 1421
							} -- 1421
						) -- 1421
					end -- 1421
					if not llmRes.success then -- 1421
						lastError = llmRes.message -- 1424
						goto __continue252 -- 1425
					end -- 1425
					lastRaw = llmRes.text -- 1427
					local parsed = parseYAMLObjectFromText(llmRes.text) -- 1428
					if not parsed.success then -- 1428
						lastError = parsed.message -- 1430
						goto __continue252 -- 1431
					end -- 1431
					local decision = parseDecisionObject(parsed.obj) -- 1433
					if not decision.success then -- 1433
						lastError = decision.message -- 1435
						goto __continue252 -- 1436
					end -- 1436
					local validation = validateDecision(decision.tool, decision.params) -- 1438
					if not validation.success then -- 1438
						lastError = validation.message -- 1440
						goto __continue252 -- 1441
					end -- 1441
					decision.params = validation.params -- 1443
					return ____awaiter_resolve(nil, decision) -- 1443
				end -- 1443
				::__continue252:: -- 1443
				attempt = attempt + 1 -- 1414
			end -- 1414
		end -- 1414
		return ____awaiter_resolve( -- 1414
			nil, -- 1414
			{ -- 1446
				success = false, -- 1446
				message = (("cannot produce valid decision yaml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1446
			} -- 1446
		) -- 1446
	end) -- 1446
end -- 1355
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1449
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1449
		local result = execRes -- 1450
		if not result.success then -- 1450
			shared.error = result.message -- 1452
			return ____awaiter_resolve(nil, "error") -- 1452
		end -- 1452
		if result.directSummary and result.directSummary ~= "" then -- 1452
			shared.response = result.directSummary -- 1456
			shared.done = true -- 1457
			persistHistoryState(shared) -- 1458
			return ____awaiter_resolve(nil, nil) -- 1458
		end -- 1458
		emitAgentEvent(shared, { -- 1461
			type = "decision_made", -- 1462
			sessionId = shared.sessionId, -- 1463
			taskId = shared.taskId, -- 1464
			step = shared.step + 1, -- 1465
			tool = result.tool, -- 1466
			reason = result.reason, -- 1467
			reasoningContent = result.reasoningContent, -- 1468
			params = result.params -- 1469
		}) -- 1469
		local ____shared_history_13 = shared.history -- 1469
		____shared_history_13[#____shared_history_13 + 1] = { -- 1471
			step = #shared.history + 1, -- 1472
			tool = result.tool, -- 1473
			reason = result.reason or "", -- 1474
			reasoningContent = result.reasoningContent, -- 1475
			params = result.params, -- 1476
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1477
		} -- 1477
		persistHistoryState(shared) -- 1479
		return ____awaiter_resolve(nil, result.tool) -- 1479
	end) -- 1479
end -- 1449
local ReadFileAction = __TS__Class() -- 1484
ReadFileAction.name = "ReadFileAction" -- 1484
__TS__ClassExtends(ReadFileAction, Node) -- 1484
function ReadFileAction.prototype.prep(self, shared) -- 1485
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1485
		local last = shared.history[#shared.history] -- 1486
		if not last then -- 1486
			error( -- 1487
				__TS__New(Error, "no history"), -- 1487
				0 -- 1487
			) -- 1487
		end -- 1487
		emitAgentEvent(shared, { -- 1488
			type = "tool_started", -- 1489
			sessionId = shared.sessionId, -- 1490
			taskId = shared.taskId, -- 1491
			step = shared.step + 1, -- 1492
			tool = last.tool -- 1493
		}) -- 1493
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1495
		if __TS__StringTrim(path) == "" then -- 1495
			error( -- 1498
				__TS__New(Error, "missing path"), -- 1498
				0 -- 1498
			) -- 1498
		end -- 1498
		local ____path_16 = path -- 1500
		local ____shared_workingDir_17 = shared.workingDir -- 1502
		local ____temp_18 = shared.useChineseResponse and "zh" or "en" -- 1503
		local ____last_params_startLine_14 = last.params.startLine -- 1504
		if ____last_params_startLine_14 == nil then -- 1504
			____last_params_startLine_14 = 1 -- 1504
		end -- 1504
		local ____TS__Number_result_19 = __TS__Number(____last_params_startLine_14) -- 1504
		local ____last_params_endLine_15 = last.params.endLine -- 1505
		if ____last_params_endLine_15 == nil then -- 1505
			____last_params_endLine_15 = READ_FILE_DEFAULT_LIMIT -- 1505
		end -- 1505
		return ____awaiter_resolve( -- 1505
			nil, -- 1505
			{ -- 1499
				path = ____path_16, -- 1500
				tool = "read_file", -- 1501
				workDir = ____shared_workingDir_17, -- 1502
				docLanguage = ____temp_18, -- 1503
				startLine = ____TS__Number_result_19, -- 1504
				endLine = __TS__Number(____last_params_endLine_15) -- 1505
			} -- 1505
		) -- 1505
	end) -- 1505
end -- 1485
function ReadFileAction.prototype.exec(self, input) -- 1509
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1509
		return ____awaiter_resolve( -- 1509
			nil, -- 1509
			Tools.readFile( -- 1510
				input.workDir, -- 1511
				input.path, -- 1512
				__TS__Number(input.startLine or 1), -- 1513
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1514
				input.docLanguage -- 1515
			) -- 1515
		) -- 1515
	end) -- 1515
end -- 1509
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1519
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1519
		local result = execRes -- 1520
		local last = shared.history[#shared.history] -- 1521
		if last ~= nil then -- 1521
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1523
			emitAgentEvent(shared, { -- 1524
				type = "tool_finished", -- 1525
				sessionId = shared.sessionId, -- 1526
				taskId = shared.taskId, -- 1527
				step = shared.step + 1, -- 1528
				tool = last.tool, -- 1529
				result = last.result -- 1530
			}) -- 1530
		end -- 1530
		__TS__Await(maybeCompressHistory(shared)) -- 1533
		persistHistoryState(shared) -- 1534
		shared.step = shared.step + 1 -- 1535
		return ____awaiter_resolve(nil, "main") -- 1535
	end) -- 1535
end -- 1519
local SearchFilesAction = __TS__Class() -- 1540
SearchFilesAction.name = "SearchFilesAction" -- 1540
__TS__ClassExtends(SearchFilesAction, Node) -- 1540
function SearchFilesAction.prototype.prep(self, shared) -- 1541
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1541
		local last = shared.history[#shared.history] -- 1542
		if not last then -- 1542
			error( -- 1543
				__TS__New(Error, "no history"), -- 1543
				0 -- 1543
			) -- 1543
		end -- 1543
		emitAgentEvent(shared, { -- 1544
			type = "tool_started", -- 1545
			sessionId = shared.sessionId, -- 1546
			taskId = shared.taskId, -- 1547
			step = shared.step + 1, -- 1548
			tool = last.tool -- 1549
		}) -- 1549
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1549
	end) -- 1549
end -- 1541
function SearchFilesAction.prototype.exec(self, input) -- 1554
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1554
		local params = input.params -- 1555
		local ____Tools_searchFiles_33 = Tools.searchFiles -- 1556
		local ____input_workDir_26 = input.workDir -- 1557
		local ____temp_27 = params.path or "" -- 1558
		local ____temp_28 = params.pattern or "" -- 1559
		local ____params_globs_29 = params.globs -- 1560
		local ____params_useRegex_30 = params.useRegex -- 1561
		local ____params_caseSensitive_31 = params.caseSensitive -- 1562
		local ____math_max_22 = math.max -- 1565
		local ____math_floor_21 = math.floor -- 1565
		local ____params_limit_20 = params.limit -- 1565
		if ____params_limit_20 == nil then -- 1565
			____params_limit_20 = SEARCH_FILES_LIMIT_DEFAULT -- 1565
		end -- 1565
		local ____math_max_22_result_32 = ____math_max_22( -- 1565
			1, -- 1565
			____math_floor_21(__TS__Number(____params_limit_20)) -- 1565
		) -- 1565
		local ____math_max_25 = math.max -- 1566
		local ____math_floor_24 = math.floor -- 1566
		local ____params_offset_23 = params.offset -- 1566
		if ____params_offset_23 == nil then -- 1566
			____params_offset_23 = 0 -- 1566
		end -- 1566
		local result = __TS__Await(____Tools_searchFiles_33({ -- 1556
			workDir = ____input_workDir_26, -- 1557
			path = ____temp_27, -- 1558
			pattern = ____temp_28, -- 1559
			globs = ____params_globs_29, -- 1560
			useRegex = ____params_useRegex_30, -- 1561
			caseSensitive = ____params_caseSensitive_31, -- 1562
			includeContent = true, -- 1563
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1564
			limit = ____math_max_22_result_32, -- 1565
			offset = ____math_max_25( -- 1566
				0, -- 1566
				____math_floor_24(__TS__Number(____params_offset_23)) -- 1566
			), -- 1566
			groupByFile = params.groupByFile == true -- 1567
		})) -- 1567
		return ____awaiter_resolve(nil, result) -- 1567
	end) -- 1567
end -- 1554
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1572
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1572
		local last = shared.history[#shared.history] -- 1573
		if last ~= nil then -- 1573
			local result = execRes -- 1575
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1576
			emitAgentEvent(shared, { -- 1577
				type = "tool_finished", -- 1578
				sessionId = shared.sessionId, -- 1579
				taskId = shared.taskId, -- 1580
				step = shared.step + 1, -- 1581
				tool = last.tool, -- 1582
				result = last.result -- 1583
			}) -- 1583
		end -- 1583
		__TS__Await(maybeCompressHistory(shared)) -- 1586
		persistHistoryState(shared) -- 1587
		shared.step = shared.step + 1 -- 1588
		return ____awaiter_resolve(nil, "main") -- 1588
	end) -- 1588
end -- 1572
local SearchDoraAPIAction = __TS__Class() -- 1593
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1593
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1593
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1594
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1594
		local last = shared.history[#shared.history] -- 1595
		if not last then -- 1595
			error( -- 1596
				__TS__New(Error, "no history"), -- 1596
				0 -- 1596
			) -- 1596
		end -- 1596
		emitAgentEvent(shared, { -- 1597
			type = "tool_started", -- 1598
			sessionId = shared.sessionId, -- 1599
			taskId = shared.taskId, -- 1600
			step = shared.step + 1, -- 1601
			tool = last.tool -- 1602
		}) -- 1602
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1602
	end) -- 1602
end -- 1594
function SearchDoraAPIAction.prototype.exec(self, input) -- 1607
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1607
		local params = input.params -- 1608
		local ____Tools_searchDoraAPI_41 = Tools.searchDoraAPI -- 1609
		local ____temp_37 = params.pattern or "" -- 1610
		local ____temp_38 = params.docSource or "api" -- 1611
		local ____temp_39 = input.useChineseResponse and "zh" or "en" -- 1612
		local ____temp_40 = params.programmingLanguage or "ts" -- 1613
		local ____math_min_36 = math.min -- 1614
		local ____math_max_35 = math.max -- 1614
		local ____params_limit_34 = params.limit -- 1614
		if ____params_limit_34 == nil then -- 1614
			____params_limit_34 = 8 -- 1614
		end -- 1614
		local result = __TS__Await(____Tools_searchDoraAPI_41({ -- 1609
			pattern = ____temp_37, -- 1610
			docSource = ____temp_38, -- 1611
			docLanguage = ____temp_39, -- 1612
			programmingLanguage = ____temp_40, -- 1613
			limit = ____math_min_36( -- 1614
				SEARCH_DORA_API_LIMIT_MAX, -- 1614
				____math_max_35( -- 1614
					1, -- 1614
					__TS__Number(____params_limit_34) -- 1614
				) -- 1614
			), -- 1614
			useRegex = params.useRegex, -- 1615
			caseSensitive = false, -- 1616
			includeContent = true, -- 1617
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1618
		})) -- 1618
		return ____awaiter_resolve(nil, result) -- 1618
	end) -- 1618
end -- 1607
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1623
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1623
		local last = shared.history[#shared.history] -- 1624
		if last ~= nil then -- 1624
			local result = execRes -- 1626
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1627
			emitAgentEvent(shared, { -- 1628
				type = "tool_finished", -- 1629
				sessionId = shared.sessionId, -- 1630
				taskId = shared.taskId, -- 1631
				step = shared.step + 1, -- 1632
				tool = last.tool, -- 1633
				result = last.result -- 1634
			}) -- 1634
		end -- 1634
		__TS__Await(maybeCompressHistory(shared)) -- 1637
		persistHistoryState(shared) -- 1638
		shared.step = shared.step + 1 -- 1639
		return ____awaiter_resolve(nil, "main") -- 1639
	end) -- 1639
end -- 1623
local ListFilesAction = __TS__Class() -- 1644
ListFilesAction.name = "ListFilesAction" -- 1644
__TS__ClassExtends(ListFilesAction, Node) -- 1644
function ListFilesAction.prototype.prep(self, shared) -- 1645
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1645
		local last = shared.history[#shared.history] -- 1646
		if not last then -- 1646
			error( -- 1647
				__TS__New(Error, "no history"), -- 1647
				0 -- 1647
			) -- 1647
		end -- 1647
		emitAgentEvent(shared, { -- 1648
			type = "tool_started", -- 1649
			sessionId = shared.sessionId, -- 1650
			taskId = shared.taskId, -- 1651
			step = shared.step + 1, -- 1652
			tool = last.tool -- 1653
		}) -- 1653
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1653
	end) -- 1653
end -- 1645
function ListFilesAction.prototype.exec(self, input) -- 1658
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1658
		local params = input.params -- 1659
		local ____Tools_listFiles_48 = Tools.listFiles -- 1660
		local ____input_workDir_45 = input.workDir -- 1661
		local ____temp_46 = params.path or "" -- 1662
		local ____params_globs_47 = params.globs -- 1663
		local ____math_max_44 = math.max -- 1664
		local ____math_floor_43 = math.floor -- 1664
		local ____params_maxEntries_42 = params.maxEntries -- 1664
		if ____params_maxEntries_42 == nil then -- 1664
			____params_maxEntries_42 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1664
		end -- 1664
		local result = ____Tools_listFiles_48({ -- 1660
			workDir = ____input_workDir_45, -- 1661
			path = ____temp_46, -- 1662
			globs = ____params_globs_47, -- 1663
			maxEntries = ____math_max_44( -- 1664
				1, -- 1664
				____math_floor_43(__TS__Number(____params_maxEntries_42)) -- 1664
			) -- 1664
		}) -- 1664
		return ____awaiter_resolve(nil, result) -- 1664
	end) -- 1664
end -- 1658
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1669
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1669
		local last = shared.history[#shared.history] -- 1670
		if last ~= nil then -- 1670
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1672
			emitAgentEvent(shared, { -- 1673
				type = "tool_finished", -- 1674
				sessionId = shared.sessionId, -- 1675
				taskId = shared.taskId, -- 1676
				step = shared.step + 1, -- 1677
				tool = last.tool, -- 1678
				result = last.result -- 1679
			}) -- 1679
		end -- 1679
		__TS__Await(maybeCompressHistory(shared)) -- 1682
		persistHistoryState(shared) -- 1683
		shared.step = shared.step + 1 -- 1684
		return ____awaiter_resolve(nil, "main") -- 1684
	end) -- 1684
end -- 1669
local DeleteFileAction = __TS__Class() -- 1689
DeleteFileAction.name = "DeleteFileAction" -- 1689
__TS__ClassExtends(DeleteFileAction, Node) -- 1689
function DeleteFileAction.prototype.prep(self, shared) -- 1690
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1690
		local last = shared.history[#shared.history] -- 1691
		if not last then -- 1691
			error( -- 1692
				__TS__New(Error, "no history"), -- 1692
				0 -- 1692
			) -- 1692
		end -- 1692
		emitAgentEvent(shared, { -- 1693
			type = "tool_started", -- 1694
			sessionId = shared.sessionId, -- 1695
			taskId = shared.taskId, -- 1696
			step = shared.step + 1, -- 1697
			tool = last.tool -- 1698
		}) -- 1698
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1700
		if __TS__StringTrim(targetFile) == "" then -- 1700
			error( -- 1703
				__TS__New(Error, "missing target_file"), -- 1703
				0 -- 1703
			) -- 1703
		end -- 1703
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1703
	end) -- 1703
end -- 1690
function DeleteFileAction.prototype.exec(self, input) -- 1707
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1707
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1708
		if not result.success then -- 1708
			return ____awaiter_resolve(nil, result) -- 1708
		end -- 1708
		return ____awaiter_resolve(nil, { -- 1708
			success = true, -- 1716
			changed = true, -- 1717
			mode = "delete", -- 1718
			checkpointId = result.checkpointId, -- 1719
			checkpointSeq = result.checkpointSeq, -- 1720
			files = {{path = input.targetFile, op = "delete"}} -- 1721
		}) -- 1721
	end) -- 1721
end -- 1707
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1725
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1725
		local last = shared.history[#shared.history] -- 1726
		if last ~= nil then -- 1726
			last.result = execRes -- 1728
			emitAgentEvent(shared, { -- 1729
				type = "tool_finished", -- 1730
				sessionId = shared.sessionId, -- 1731
				taskId = shared.taskId, -- 1732
				step = shared.step + 1, -- 1733
				tool = last.tool, -- 1734
				result = last.result -- 1735
			}) -- 1735
			local result = last.result -- 1737
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1737
				emitAgentEvent(shared, { -- 1742
					type = "checkpoint_created", -- 1743
					sessionId = shared.sessionId, -- 1744
					taskId = shared.taskId, -- 1745
					step = shared.step + 1, -- 1746
					tool = "delete_file", -- 1747
					checkpointId = result.checkpointId, -- 1748
					checkpointSeq = result.checkpointSeq, -- 1749
					files = result.files -- 1750
				}) -- 1750
			end -- 1750
		end -- 1750
		__TS__Await(maybeCompressHistory(shared)) -- 1754
		persistHistoryState(shared) -- 1755
		shared.step = shared.step + 1 -- 1756
		return ____awaiter_resolve(nil, "main") -- 1756
	end) -- 1756
end -- 1725
local BuildAction = __TS__Class() -- 1761
BuildAction.name = "BuildAction" -- 1761
__TS__ClassExtends(BuildAction, Node) -- 1761
function BuildAction.prototype.prep(self, shared) -- 1762
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1762
		local last = shared.history[#shared.history] -- 1763
		if not last then -- 1763
			error( -- 1764
				__TS__New(Error, "no history"), -- 1764
				0 -- 1764
			) -- 1764
		end -- 1764
		emitAgentEvent(shared, { -- 1765
			type = "tool_started", -- 1766
			sessionId = shared.sessionId, -- 1767
			taskId = shared.taskId, -- 1768
			step = shared.step + 1, -- 1769
			tool = last.tool -- 1770
		}) -- 1770
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1770
	end) -- 1770
end -- 1762
function BuildAction.prototype.exec(self, input) -- 1775
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1775
		local params = input.params -- 1776
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1777
		return ____awaiter_resolve(nil, result) -- 1777
	end) -- 1777
end -- 1775
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1784
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1784
		local last = shared.history[#shared.history] -- 1785
		if last ~= nil then -- 1785
			last.result = execRes -- 1787
			emitAgentEvent(shared, { -- 1788
				type = "tool_finished", -- 1789
				sessionId = shared.sessionId, -- 1790
				taskId = shared.taskId, -- 1791
				step = shared.step + 1, -- 1792
				tool = last.tool, -- 1793
				result = last.result -- 1794
			}) -- 1794
		end -- 1794
		__TS__Await(maybeCompressHistory(shared)) -- 1797
		persistHistoryState(shared) -- 1798
		shared.step = shared.step + 1 -- 1799
		return ____awaiter_resolve(nil, "main") -- 1799
	end) -- 1799
end -- 1784
local EditFileAction = __TS__Class() -- 1804
EditFileAction.name = "EditFileAction" -- 1804
__TS__ClassExtends(EditFileAction, Node) -- 1804
function EditFileAction.prototype.prep(self, shared) -- 1805
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
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1815
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1818
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1819
		if __TS__StringTrim(path) == "" then -- 1819
			error( -- 1820
				__TS__New(Error, "missing path"), -- 1820
				0 -- 1820
			) -- 1820
		end -- 1820
		if oldStr == newStr then -- 1820
			error( -- 1821
				__TS__New(Error, "old_str and new_str must be different"), -- 1821
				0 -- 1821
			) -- 1821
		end -- 1821
		return ____awaiter_resolve(nil, { -- 1821
			path = path, -- 1822
			oldStr = oldStr, -- 1822
			newStr = newStr, -- 1822
			taskId = shared.taskId, -- 1822
			workDir = shared.workingDir -- 1822
		}) -- 1822
	end) -- 1822
end -- 1805
function EditFileAction.prototype.exec(self, input) -- 1825
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1825
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1826
		if not readRes.success then -- 1826
			if input.oldStr ~= "" then -- 1826
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1826
			end -- 1826
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1831
			if not createRes.success then -- 1831
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1831
			end -- 1831
			return ____awaiter_resolve(nil, { -- 1831
				success = true, -- 1839
				changed = true, -- 1840
				mode = "create", -- 1841
				replaced = 0, -- 1842
				checkpointId = createRes.checkpointId, -- 1843
				checkpointSeq = createRes.checkpointSeq, -- 1844
				files = {{path = input.path, op = "create"}} -- 1845
			}) -- 1845
		end -- 1845
		if input.oldStr == "" then -- 1845
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 1845
		end -- 1845
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 1852
		if replaceRes.replaced == 0 then -- 1852
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 1852
		end -- 1852
		if replaceRes.content == readRes.content then -- 1852
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 1852
		end -- 1852
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1865
		if not applyRes.success then -- 1865
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1865
		end -- 1865
		return ____awaiter_resolve(nil, { -- 1865
			success = true, -- 1873
			changed = true, -- 1874
			mode = "replace", -- 1875
			replaced = replaceRes.replaced, -- 1876
			checkpointId = applyRes.checkpointId, -- 1877
			checkpointSeq = applyRes.checkpointSeq, -- 1878
			files = {{path = input.path, op = "write"}} -- 1879
		}) -- 1879
	end) -- 1879
end -- 1825
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1883
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1883
		local last = shared.history[#shared.history] -- 1884
		if last ~= nil then -- 1884
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1886
			last.result = execRes -- 1887
			emitAgentEvent(shared, { -- 1888
				type = "tool_finished", -- 1889
				sessionId = shared.sessionId, -- 1890
				taskId = shared.taskId, -- 1891
				step = shared.step + 1, -- 1892
				tool = last.tool, -- 1893
				result = last.result -- 1894
			}) -- 1894
			local result = last.result -- 1896
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1896
				emitAgentEvent(shared, { -- 1901
					type = "checkpoint_created", -- 1902
					sessionId = shared.sessionId, -- 1903
					taskId = shared.taskId, -- 1904
					step = shared.step + 1, -- 1905
					tool = last.tool, -- 1906
					checkpointId = result.checkpointId, -- 1907
					checkpointSeq = result.checkpointSeq, -- 1908
					files = result.files -- 1909
				}) -- 1909
			end -- 1909
		end -- 1909
		__TS__Await(maybeCompressHistory(shared)) -- 1913
		persistHistoryState(shared) -- 1914
		shared.step = shared.step + 1 -- 1915
		return ____awaiter_resolve(nil, "main") -- 1915
	end) -- 1915
end -- 1883
local FormatResponseNode = __TS__Class() -- 1920
FormatResponseNode.name = "FormatResponseNode" -- 1920
__TS__ClassExtends(FormatResponseNode, Node) -- 1920
function FormatResponseNode.prototype.prep(self, shared) -- 1921
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1921
		local last = shared.history[#shared.history] -- 1922
		if last and last.tool == "finish" then -- 1922
			emitAgentEvent(shared, { -- 1924
				type = "tool_started", -- 1925
				sessionId = shared.sessionId, -- 1926
				taskId = shared.taskId, -- 1927
				step = shared.step + 1, -- 1928
				tool = last.tool -- 1929
			}) -- 1929
		end -- 1929
		return ____awaiter_resolve(nil, {history = shared.history, shared = shared}) -- 1929
	end) -- 1929
end -- 1921
function FormatResponseNode.prototype.exec(self, input) -- 1935
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1935
		if input.shared.stopToken.stopped then -- 1935
			return ____awaiter_resolve( -- 1935
				nil, -- 1935
				getCancelledReason(input.shared) -- 1937
			) -- 1937
		end -- 1937
		local failureNote = input.shared.error and input.shared.error ~= "" and (input.shared.useChineseResponse and "\n\n本次任务因以下错误结束，请在总结中明确说明：\n" .. input.shared.error or "\n\nThis task ended with the following error. Make sure the summary states it clearly:\n" .. input.shared.error) or "" -- 1939
		local history = input.history -- 1944
		if #history == 0 then -- 1944
			if input.shared.error and input.shared.error ~= "" then -- 1944
				return ____awaiter_resolve( -- 1944
					nil, -- 1944
					getFailureSummaryFallback(input.shared, input.shared.error) -- 1947
				) -- 1947
			end -- 1947
			return ____awaiter_resolve(nil, "No actions were performed.") -- 1947
		end -- 1947
		local summary = formatHistorySummary(history) -- 1951
		local staticPrompt = replacePromptVars( -- 1952
			input.shared.promptPack.finalSummaryPrompt, -- 1952
			{ -- 1952
				SUMMARY = "", -- 1953
				LANGUAGE_DIRECTIVE = getReplyLanguageDirective(input.shared) -- 1954
			} -- 1954
		) -- 1954
		local contextWindow = math.max(4000, input.shared.llmConfig.contextWindow) -- 1956
		local reservedOutputTokens = math.max( -- 1957
			1024, -- 1957
			math.floor(contextWindow * 0.2) -- 1957
		) -- 1957
		local staticTokens = estimateTextTokens(staticPrompt) -- 1958
		local failureTokens = estimateTextTokens(failureNote) -- 1959
		local summaryBudget = math.max(400, contextWindow - reservedOutputTokens - staticTokens - failureTokens - 256) -- 1960
		local boundedSummary = clipTextToTokenBudget(summary, summaryBudget) -- 1961
		local prompt = replacePromptVars( -- 1962
			input.shared.promptPack.finalSummaryPrompt, -- 1962
			{ -- 1962
				SUMMARY = boundedSummary, -- 1963
				LANGUAGE_DIRECTIVE = getReplyLanguageDirective(input.shared) -- 1964
			} -- 1964
		) .. failureNote -- 1964
		local res -- 1966
		do -- 1966
			local i = 0 -- 1967
			while i < input.shared.llmMaxTry do -- 1967
				res = __TS__Await(llmStream(input.shared, {{role = "user", content = prompt}})) -- 1968
				if res.success then -- 1968
					break -- 1969
				end -- 1969
				i = i + 1 -- 1967
			end -- 1967
		end -- 1967
		if not res then -- 1967
			return ____awaiter_resolve( -- 1967
				nil, -- 1967
				input.shared.error and input.shared.error ~= "" and getFailureSummaryFallback(input.shared, input.shared.error) or (input.shared.useChineseResponse and "执行完成，但生成总结失败。" or "Completed, but failed to generate summary.") -- 1972
			) -- 1972
		end -- 1972
		if not res.success then -- 1972
			return ____awaiter_resolve( -- 1972
				nil, -- 1972
				input.shared.error and input.shared.error ~= "" and getFailureSummaryFallback(input.shared, input.shared.error) or (input.shared.useChineseResponse and "执行完成，但生成总结失败：" .. res.message or "Completed, but failed to generate summary: " .. res.message) -- 1979
			) -- 1979
		end -- 1979
		return ____awaiter_resolve(nil, res.text) -- 1979
	end) -- 1979
end -- 1935
function FormatResponseNode.prototype.post(self, shared, _prepRes, execRes) -- 1988
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1988
		local last = shared.history[#shared.history] -- 1989
		if last and last.tool == "finish" then -- 1989
			last.result = {success = true, message = execRes} -- 1991
			emitAgentEvent(shared, { -- 1992
				type = "tool_finished", -- 1993
				sessionId = shared.sessionId, -- 1994
				taskId = shared.taskId, -- 1995
				step = shared.step + 1, -- 1996
				tool = last.tool, -- 1997
				result = last.result -- 1998
			}) -- 1998
			shared.step = shared.step + 1 -- 2000
		end -- 2000
		shared.response = execRes -- 2002
		shared.done = true -- 2003
		persistHistoryState(shared) -- 2004
		return ____awaiter_resolve(nil, nil) -- 2004
	end) -- 2004
end -- 1988
local CodingAgentFlow = __TS__Class() -- 2009
CodingAgentFlow.name = "CodingAgentFlow" -- 2009
__TS__ClassExtends(CodingAgentFlow, Flow) -- 2009
function CodingAgentFlow.prototype.____constructor(self) -- 2010
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 2011
	local read = __TS__New(ReadFileAction, 1, 0) -- 2012
	local search = __TS__New(SearchFilesAction, 1, 0) -- 2013
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 2014
	local list = __TS__New(ListFilesAction, 1, 0) -- 2015
	local del = __TS__New(DeleteFileAction, 1, 0) -- 2016
	local build = __TS__New(BuildAction, 1, 0) -- 2017
	local edit = __TS__New(EditFileAction, 1, 0) -- 2018
	local format = __TS__New(FormatResponseNode, 1, 0) -- 2019
	main:on("read_file", read) -- 2021
	main:on("grep_files", search) -- 2022
	main:on("search_dora_api", searchDora) -- 2023
	main:on("glob_files", list) -- 2024
	main:on("delete_file", del) -- 2025
	main:on("build", build) -- 2026
	main:on("edit_file", edit) -- 2027
	main:on("finish", format) -- 2028
	main:on("error", format) -- 2029
	read:on("main", main) -- 2031
	search:on("main", main) -- 2032
	searchDora:on("main", main) -- 2033
	list:on("main", main) -- 2034
	del:on("main", main) -- 2035
	build:on("main", main) -- 2036
	edit:on("main", main) -- 2037
	Flow.prototype.____constructor(self, main) -- 2039
end -- 2010
local function runCodingAgentAsync(options) -- 2043
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2043
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 2043
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 2043
		end -- 2043
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2047
		if not llmConfigRes.success then -- 2047
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2047
		end -- 2047
		local llmConfig = llmConfigRes.config -- 2053
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 2054
		if not taskRes.success then -- 2054
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 2054
		end -- 2054
		local compressor = __TS__New(MemoryCompressor, { -- 2061
			compressionThreshold = 0.8, -- 2062
			maxCompressionRounds = 3, -- 2063
			maxTokensPerCompression = 20000, -- 2064
			projectDir = options.workDir, -- 2065
			llmConfig = llmConfig, -- 2066
			promptPack = options.promptPack -- 2067
		}) -- 2067
		local persistedSession = compressor:getStorage():readSessionState() -- 2069
		local promptPack = compressor:getPromptPack() -- 2070
		local shared = { -- 2072
			sessionId = options.sessionId, -- 2073
			taskId = taskRes.taskId, -- 2074
			maxSteps = math.max( -- 2075
				1, -- 2075
				math.floor(options.maxSteps or 40) -- 2075
			), -- 2075
			llmMaxTry = math.max( -- 2076
				1, -- 2076
				math.floor(options.llmMaxTry or 3) -- 2076
			), -- 2076
			step = 0, -- 2077
			done = false, -- 2078
			stopToken = options.stopToken or ({stopped = false}), -- 2079
			response = "", -- 2080
			userQuery = options.prompt, -- 2081
			workingDir = options.workDir, -- 2082
			useChineseResponse = options.useChineseResponse == true, -- 2083
			decisionMode = options.decisionMode == "yaml" and "yaml" or "tool_calling", -- 2084
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 2085
			llmConfig = llmConfig, -- 2090
			onEvent = options.onEvent, -- 2091
			promptPack = promptPack, -- 2092
			history = persistedSession.history, -- 2093
			memory = {lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, compressor = compressor} -- 2095
		} -- 2095
		local ____try = __TS__AsyncAwaiter(function() -- 2095
			emitAgentEvent(shared, { -- 2102
				type = "task_started", -- 2103
				sessionId = shared.sessionId, -- 2104
				taskId = shared.taskId, -- 2105
				prompt = shared.userQuery, -- 2106
				workDir = shared.workingDir, -- 2107
				maxSteps = shared.maxSteps -- 2108
			}) -- 2108
			if shared.stopToken.stopped then -- 2108
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2111
				local result = { -- 2112
					success = false, -- 2112
					taskId = shared.taskId, -- 2112
					message = getCancelledReason(shared), -- 2112
					steps = shared.step -- 2112
				} -- 2112
				emitAgentEvent(shared, { -- 2113
					type = "task_finished", -- 2114
					sessionId = shared.sessionId, -- 2115
					taskId = shared.taskId, -- 2116
					success = false, -- 2117
					message = result.message, -- 2118
					steps = result.steps -- 2119
				}) -- 2119
				return ____awaiter_resolve(nil, result) -- 2119
			end -- 2119
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 2123
			local flow = __TS__New(CodingAgentFlow) -- 2124
			__TS__Await(flow:run(shared)) -- 2125
			if shared.stopToken.stopped then -- 2125
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2127
				local result = { -- 2128
					success = false, -- 2128
					taskId = shared.taskId, -- 2128
					message = getCancelledReason(shared), -- 2128
					steps = shared.step -- 2128
				} -- 2128
				emitAgentEvent(shared, { -- 2129
					type = "task_finished", -- 2130
					sessionId = shared.sessionId, -- 2131
					taskId = shared.taskId, -- 2132
					success = false, -- 2133
					message = result.message, -- 2134
					steps = result.steps -- 2135
				}) -- 2135
				return ____awaiter_resolve(nil, result) -- 2135
			end -- 2135
			if shared.error then -- 2135
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 2140
				local result = {success = false, taskId = shared.taskId, message = shared.response and shared.response ~= "" and shared.response or shared.error, steps = shared.step} -- 2141
				emitAgentEvent(shared, { -- 2147
					type = "task_finished", -- 2148
					sessionId = shared.sessionId, -- 2149
					taskId = shared.taskId, -- 2150
					success = false, -- 2151
					message = result.message, -- 2152
					steps = result.steps -- 2153
				}) -- 2153
				return ____awaiter_resolve(nil, result) -- 2153
			end -- 2153
			Tools.setTaskStatus(shared.taskId, "DONE") -- 2157
			local result = {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step} -- 2158
			emitAgentEvent(shared, { -- 2164
				type = "task_finished", -- 2165
				sessionId = shared.sessionId, -- 2166
				taskId = shared.taskId, -- 2167
				success = true, -- 2168
				message = result.message, -- 2169
				steps = result.steps -- 2170
			}) -- 2170
			return ____awaiter_resolve(nil, result) -- 2170
		end) -- 2170
		__TS__Await(____try.catch( -- 2101
			____try, -- 2101
			function(____, e) -- 2101
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 2174
				local result = { -- 2175
					success = false, -- 2175
					taskId = shared.taskId, -- 2175
					message = tostring(e), -- 2175
					steps = shared.step -- 2175
				} -- 2175
				emitAgentEvent(shared, { -- 2176
					type = "task_finished", -- 2177
					sessionId = shared.sessionId, -- 2178
					taskId = shared.taskId, -- 2179
					success = false, -- 2180
					message = result.message, -- 2181
					steps = result.steps -- 2182
				}) -- 2182
				return ____awaiter_resolve(nil, result) -- 2182
			end -- 2182
		)) -- 2182
	end) -- 2182
end -- 2043
function ____exports.runCodingAgent(options, callback) -- 2188
	local ____self_49 = runCodingAgentAsync(options) -- 2188
	____self_49["then"]( -- 2188
		____self_49, -- 2188
		function(____, result) return callback(result) end -- 2189
	) -- 2189
end -- 2188
return ____exports -- 2188