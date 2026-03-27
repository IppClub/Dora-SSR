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
function toJson(value) -- 330
	local text, err = json.encode(value) -- 331
	if text ~= nil then -- 331
		return text -- 332
	end -- 332
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 333
end -- 333
function truncateText(text, maxLen) -- 336
	if #text <= maxLen then -- 336
		return text -- 337
	end -- 337
	local nextPos = utf8.offset(text, maxLen + 1) -- 338
	if nextPos == nil then -- 338
		return text -- 339
	end -- 339
	return string.sub(text, 1, nextPos - 1) .. "..." -- 340
end -- 340
function utf8TakeHead(text, maxChars) -- 343
	if maxChars <= 0 or text == "" then -- 343
		return "" -- 344
	end -- 344
	local nextPos = utf8.offset(text, maxChars + 1) -- 345
	if nextPos == nil then -- 345
		return text -- 346
	end -- 346
	return string.sub(text, 1, nextPos - 1) -- 347
end -- 347
function summarizeUnknown(value, maxLen) -- 360
	if maxLen == nil then -- 360
		maxLen = 320 -- 360
	end -- 360
	if value == nil then -- 360
		return "undefined" -- 361
	end -- 361
	if value == nil then -- 361
		return "null" -- 362
	end -- 362
	if type(value) == "string" then -- 362
		return __TS__StringReplace( -- 364
			truncateText(value, maxLen), -- 364
			"\n", -- 364
			"\\n" -- 364
		) -- 364
	end -- 364
	if type(value) == "number" or type(value) == "boolean" then -- 364
		return tostring(value) -- 367
	end -- 367
	return __TS__StringReplace( -- 369
		truncateText( -- 369
			toJson(value), -- 369
			maxLen -- 369
		), -- 369
		"\n", -- 369
		"\\n" -- 369
	) -- 369
end -- 369
function limitReadContentForHistory(content, tool) -- 386
	local lines = __TS__StringSplit(content, "\n") -- 387
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 388
	local limitedByLines = overLineLimit and table.concat( -- 389
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 390
		"\n" -- 390
	) or content -- 390
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 390
		return content -- 393
	end -- 393
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 395
	local reasons = {} -- 398
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 398
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 399
	end -- 399
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 399
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 400
	end -- 400
	local hint = "Narrow the requested line range." -- 401
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 402
end -- 402
function pushLimitedMatches(lines, items, maxItems, mapper) -- 517
	local shown = math.min(#items, maxItems) -- 523
	do -- 523
		local j = 0 -- 524
		while j < shown do -- 524
			lines[#lines + 1] = mapper(items[j + 1], j) -- 525
			j = j + 1 -- 524
		end -- 524
	end -- 524
	if #items > shown then -- 524
		lines[#lines + 1] = ("  ... " .. tostring(#items - shown)) .. " more omitted" -- 528
	end -- 528
end -- 528
function formatHistorySummary(history) -- 598
	if #history == 0 then -- 598
		return "No previous actions." -- 600
	end -- 600
	local actions = history -- 602
	local lines = {} -- 603
	lines[#lines + 1] = "" -- 604
	do -- 604
		local i = 0 -- 605
		while i < #actions do -- 605
			local action = actions[i + 1] -- 606
			lines[#lines + 1] = ("Action " .. tostring(i + 1)) .. ":" -- 607
			lines[#lines + 1] = "- Tool: " .. action.tool -- 608
			if action.params and type(action.params) == "table" and ({next(action.params)}) ~= nil then -- 608
				lines[#lines + 1] = "- Parameters:" -- 610
				for key in pairs(action.params) do -- 611
					lines[#lines + 1] = (("  - " .. key) .. ": ") .. summarizeUnknown(action.params[key], 2000) -- 612
				end -- 612
			end -- 612
			if action.result and type(action.result) == "table" then -- 612
				local result = action.result -- 616
				local success = result.success == true -- 617
				if action.tool == "build" then -- 617
					if not success and type(result.message) == "string" then -- 617
						lines[#lines + 1] = "- Result: Failed" -- 620
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 1200) -- 621
					elseif type(result.messages) == "table" then -- 621
						local messages = result.messages -- 623
						local successCount = 0 -- 624
						local failedCount = 0 -- 625
						do -- 625
							local j = 0 -- 626
							while j < #messages do -- 626
								if messages[j + 1].success == true then -- 626
									successCount = successCount + 1 -- 627
								else -- 627
									failedCount = failedCount + 1 -- 628
								end -- 628
								j = j + 1 -- 626
							end -- 626
						end -- 626
						lines[#lines + 1] = "- Result: " .. (failedCount > 0 and "Completed With Errors" or "Success") -- 630
						lines[#lines + 1] = ((("- Build summary: " .. tostring(successCount)) .. " succeeded, ") .. tostring(failedCount)) .. " failed" -- 631
						if #messages > 0 then -- 631
							lines[#lines + 1] = "- Build details:" -- 633
							local shown = math.min(#messages, 12) -- 634
							do -- 634
								local j = 0 -- 635
								while j < shown do -- 635
									local item = messages[j + 1] -- 636
									local file = type(item.file) == "string" and item.file or "(unknown)" -- 637
									if item.success == true then -- 637
										lines[#lines + 1] = (("  " .. tostring(j + 1)) .. ". OK ") .. file -- 639
									else -- 639
										local message = type(item.message) == "string" and truncateText(item.message, 400) or "build failed" -- 641
										lines[#lines + 1] = (((("  " .. tostring(j + 1)) .. ". FAIL ") .. file) .. ": ") .. message -- 644
									end -- 644
									j = j + 1 -- 635
								end -- 635
							end -- 635
							if #messages > shown then -- 635
								lines[#lines + 1] = ("  ... " .. tostring(#messages - shown)) .. " more omitted" -- 648
							end -- 648
						end -- 648
					else -- 648
						lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 652
					end -- 652
				elseif action.tool == "read_file" then -- 652
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 655
					if success and type(result.content) == "string" then -- 655
						lines[#lines + 1] = "- Content:" -- 657
						lines[#lines + 1] = limitReadContentForHistory(result.content, action.tool) -- 658
						if result.startLine ~= nil or result.endLine ~= nil or result.totalLines ~= nil then -- 658
							lines[#lines + 1] = (((("- Range: " .. (result.startLine ~= nil and tostring(result.startLine) or "?")) .. "-") .. (result.endLine ~= nil and tostring(result.endLine) or "?")) .. " / total ") .. (result.totalLines ~= nil and tostring(result.totalLines) or "?") -- 660
						end -- 660
					elseif not success and type(result.message) == "string" then -- 660
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 600) -- 665
					end -- 665
				elseif action.tool == "grep_files" then -- 665
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 668
					if success and type(result.results) == "table" then -- 668
						local matches = result.results -- 670
						local totalMatches = type(result.totalResults) == "number" and result.totalResults or #matches -- 671
						lines[#lines + 1] = "- Matches: " .. tostring(totalMatches) -- 674
						lines[#lines + 1] = "- Next: Immediately read the relevant file from the potentially related results to gather more information." -- 675
						if type(result.offset) == "number" and type(result.limit) == "number" then -- 675
							lines[#lines + 1] = (("- Page: offset=" .. tostring(result.offset)) .. " limit=") .. tostring(result.limit) -- 677
						end -- 677
						if result.hasMore == true and result.nextOffset ~= nil then -- 677
							lines[#lines + 1] = "- More: continue with offset=" .. tostring(result.nextOffset) -- 680
						end -- 680
						if type(result.groupedResults) == "table" then -- 680
							local groups = result.groupedResults -- 683
							lines[#lines + 1] = "- Groups:" -- 684
							pushLimitedMatches( -- 685
								lines, -- 685
								groups, -- 685
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 685
								function(g, index) -- 685
									local file = type(g.file) == "string" and g.file or "" -- 686
									local total = g.totalMatches ~= nil and tostring(g.totalMatches) or "?" -- 687
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. ": ") .. total) .. " matches" -- 688
								end -- 685
							) -- 685
						else -- 685
							pushLimitedMatches( -- 691
								lines, -- 691
								matches, -- 691
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 691
								function(m, index) -- 691
									local file = type(m.file) == "string" and m.file or "" -- 692
									local line = m.line ~= nil and tostring(m.line) or "" -- 693
									local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 694
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 695
								end -- 691
							) -- 691
						end -- 691
					end -- 691
				elseif action.tool == "search_dora_api" then -- 691
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 700
					if success and type(result.results) == "table" then -- 700
						local hits = result.results -- 702
						local totalHits = type(result.totalResults) == "number" and result.totalResults or #hits -- 703
						lines[#lines + 1] = "- Matches: " .. tostring(totalHits) -- 706
						pushLimitedMatches( -- 707
							lines, -- 707
							hits, -- 707
							HISTORY_SEARCH_DORA_API_MAX_MATCHES, -- 707
							function(m, index) -- 707
								local file = type(m.file) == "string" and m.file or "" -- 708
								local line = m.line ~= nil and tostring(m.line) or "" -- 709
								local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 710
								return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 711
							end -- 707
						) -- 707
					end -- 707
				elseif action.tool == "edit_file" then -- 707
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 715
					if success then -- 715
						if result.mode ~= nil then -- 715
							lines[#lines + 1] = "- Mode: " .. tostring(result.mode) -- 718
						end -- 718
						if result.replaced ~= nil then -- 718
							lines[#lines + 1] = "- Replaced: " .. tostring(result.replaced) -- 721
						end -- 721
					end -- 721
				elseif action.tool == "glob_files" then -- 721
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 725
					if success and type(result.files) == "table" then -- 725
						local files = result.files -- 727
						local totalEntries = type(result.totalEntries) == "number" and result.totalEntries or #files -- 728
						lines[#lines + 1] = "- Entries: " .. tostring(totalEntries) -- 731
						lines[#lines + 1] = "- Next: Immediately read the relevant file snippets from the potentially related results to gather more information." -- 732
						lines[#lines + 1] = "- Directory structure:" -- 733
						if #files > 0 then -- 733
							local shown = math.min(#files, HISTORY_LIST_FILES_MAX_ENTRIES) -- 735
							do -- 735
								local j = 0 -- 736
								while j < shown do -- 736
									lines[#lines + 1] = "  " .. files[j + 1] -- 737
									j = j + 1 -- 736
								end -- 736
							end -- 736
							if #files > shown then -- 736
								lines[#lines + 1] = ("  ... " .. tostring(#files - shown)) .. " more omitted" -- 740
							end -- 740
						else -- 740
							lines[#lines + 1] = "  (Empty or inaccessible directory)" -- 743
						end -- 743
					end -- 743
				elseif action.tool == "message" then -- 743
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 747
					if success and type(result.message) == "string" then -- 747
						lines[#lines + 1] = "- Message: " .. truncateText(result.message, 1200) -- 749
					elseif not success and type(result.message) == "string" then -- 749
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 600) -- 751
					end -- 751
				else -- 751
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 754
					lines[#lines + 1] = "- Detail: " .. truncateText( -- 755
						toJson(result), -- 755
						4000 -- 755
					) -- 755
				end -- 755
			elseif action.result ~= nil then -- 755
				lines[#lines + 1] = "- Result: " .. summarizeUnknown(action.result, 3000) -- 758
			else -- 758
				lines[#lines + 1] = "- Result: pending" -- 760
			end -- 760
			if i < #actions - 1 then -- 760
				lines[#lines + 1] = "" -- 762
			end -- 762
			i = i + 1 -- 605
		end -- 605
	end -- 605
	return table.concat(lines, "\n") -- 764
end -- 764
function persistHistoryState(shared) -- 767
	shared.memory.compressor:getStorage():writeSessionState(shared.history, shared.memory.lastConsolidatedIndex) -- 768
end -- 768
HISTORY_READ_FILE_MAX_CHARS = 12000 -- 118
HISTORY_READ_FILE_MAX_LINES = 300 -- 119
local READ_FILE_DEFAULT_LIMIT = 300 -- 120
HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 121
HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 122
HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 123
local DECISION_HISTORY_MAX_CHARS = 16000 -- 124
local SEARCH_DORA_API_LIMIT_MAX = 20 -- 125
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 126
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 127
local SEARCH_PREVIEW_CONTEXT = 80 -- 128
local function emitAgentEvent(shared, event) -- 169
	if shared.onEvent then -- 169
		shared:onEvent(event) -- 171
	end -- 171
end -- 169
local function getCancelledReason(shared) -- 175
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 175
		return shared.stopToken.reason -- 176
	end -- 176
	return shared.useChineseResponse and "已取消" or "cancelled" -- 177
end -- 175
local function getMaxStepsReachedReason(shared) -- 180
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 181
end -- 180
local function getFailureSummaryFallback(shared, ____error) -- 186
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 187
end -- 186
local function canWriteStepLLMDebug(shared, stepId) -- 192
	if stepId == nil then -- 192
		stepId = shared.step + 1 -- 192
	end -- 192
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 193
end -- 192
local function ensureDirRecursive(dir) -- 200
	if not dir then -- 200
		return false -- 201
	end -- 201
	if Content:exist(dir) then -- 201
		return Content:isdir(dir) -- 202
	end -- 202
	local parent = Path:getPath(dir) -- 203
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 203
		return false -- 205
	end -- 205
	return Content:mkdir(dir) -- 207
end -- 200
local function encodeDebugJSON(value) -- 210
	local text, err = json.encode(value) -- 211
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 212
end -- 210
local function getStepLLMDebugDir(shared) -- 215
	return Path( -- 216
		shared.workingDir, -- 217
		".agent", -- 218
		tostring(shared.sessionId), -- 219
		tostring(shared.taskId) -- 220
	) -- 220
end -- 215
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 224
	return Path( -- 225
		getStepLLMDebugDir(shared), -- 225
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 225
	) -- 225
end -- 224
local function getLatestStepLLMDebugSeq(shared, stepId) -- 228
	if not canWriteStepLLMDebug(shared, stepId) then -- 228
		return 0 -- 229
	end -- 229
	local dir = getStepLLMDebugDir(shared) -- 230
	if not Content:exist(dir) or not Content:isdir(dir) then -- 230
		return 0 -- 231
	end -- 231
	local latest = 0 -- 232
	for ____, file in ipairs(Content:getFiles(dir)) do -- 233
		do -- 233
			local name = Path:getFilename(file) -- 234
			local seqText = string.match( -- 235
				name, -- 235
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 235
			) -- 235
			if seqText ~= nil then -- 235
				latest = math.max( -- 237
					latest, -- 237
					tonumber(seqText) -- 237
				) -- 237
				goto __continue19 -- 238
			end -- 238
			local legacyMatch = string.match( -- 240
				name, -- 240
				("^" .. tostring(stepId)) .. "_in%.md$" -- 240
			) -- 240
			if legacyMatch ~= nil then -- 240
				latest = math.max(latest, 1) -- 242
			end -- 242
		end -- 242
		::__continue19:: -- 242
	end -- 242
	return latest -- 245
end -- 228
local function writeStepLLMDebugFile(path, content) -- 248
	if not Content:save(path, content) then -- 248
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 250
		return false -- 251
	end -- 251
	return true -- 253
end -- 248
local function createStepLLMDebugPair(shared, stepId, inContent) -- 256
	if not canWriteStepLLMDebug(shared, stepId) then -- 256
		return 0 -- 257
	end -- 257
	local dir = getStepLLMDebugDir(shared) -- 258
	if not ensureDirRecursive(dir) then -- 258
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 260
		return 0 -- 261
	end -- 261
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 263
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 264
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 265
	if not writeStepLLMDebugFile(inPath, inContent) then -- 265
		return 0 -- 267
	end -- 267
	writeStepLLMDebugFile(outPath, "") -- 269
	return seq -- 270
end -- 256
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 273
	if not canWriteStepLLMDebug(shared, stepId) then -- 273
		return -- 274
	end -- 274
	local dir = getStepLLMDebugDir(shared) -- 275
	if not ensureDirRecursive(dir) then -- 275
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 277
		return -- 278
	end -- 278
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 280
	if latestSeq <= 0 then -- 280
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 282
		writeStepLLMDebugFile(outPath, content) -- 283
		return -- 284
	end -- 284
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 286
	writeStepLLMDebugFile(outPath, content) -- 287
end -- 273
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 290
	if not canWriteStepLLMDebug(shared, stepId) then -- 290
		return -- 291
	end -- 291
	local sections = { -- 292
		"# LLM Input", -- 293
		"session_id: " .. tostring(shared.sessionId), -- 294
		"task_id: " .. tostring(shared.taskId), -- 295
		"step_id: " .. tostring(stepId), -- 296
		"phase: " .. phase, -- 297
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 298
		"## Options", -- 299
		"```json", -- 300
		encodeDebugJSON(options), -- 301
		"```" -- 302
	} -- 302
	do -- 302
		local i = 0 -- 304
		while i < #messages do -- 304
			local message = messages[i + 1] -- 305
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 306
			sections[#sections + 1] = "role: " .. (message.role or "") -- 307
			sections[#sections + 1] = "" -- 308
			sections[#sections + 1] = message.content or "" -- 309
			i = i + 1 -- 304
		end -- 304
	end -- 304
	createStepLLMDebugPair( -- 311
		shared, -- 311
		stepId, -- 311
		table.concat(sections, "\n") -- 311
	) -- 311
end -- 290
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 314
	if not canWriteStepLLMDebug(shared, stepId) then -- 314
		return -- 315
	end -- 315
	local ____array_0 = __TS__SparseArrayNew( -- 315
		"# LLM Output", -- 317
		"session_id: " .. tostring(shared.sessionId), -- 318
		"task_id: " .. tostring(shared.taskId), -- 319
		"step_id: " .. tostring(stepId), -- 320
		"phase: " .. phase, -- 321
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 322
		table.unpack(meta and ({ -- 323
			"## Meta", -- 323
			"```json", -- 323
			encodeDebugJSON(meta), -- 323
			"```" -- 323
		}) or ({})) -- 323
	) -- 323
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 323
	local sections = {__TS__SparseArraySpread(____array_0)} -- 316
	updateLatestStepLLMDebugOutput( -- 327
		shared, -- 327
		stepId, -- 327
		table.concat(sections, "\n") -- 327
	) -- 327
end -- 314
local function utf8TakeTail(text, maxChars) -- 350
	if maxChars <= 0 or text == "" then -- 350
		return "" -- 351
	end -- 351
	local charLen = utf8.len(text) -- 352
	if charLen == false or charLen <= maxChars then -- 352
		return text -- 353
	end -- 353
	local startChar = math.max(1, charLen - maxChars + 1) -- 354
	local startPos = utf8.offset(text, startChar) -- 355
	if startPos == nil then -- 355
		return text -- 356
	end -- 356
	return string.sub(text, startPos) -- 357
end -- 350
local function getReplyLanguageDirective(shared) -- 372
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 373
end -- 372
local function replacePromptVars(template, vars) -- 378
	local output = template -- 379
	for key in pairs(vars) do -- 380
		output = table.concat( -- 381
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 381
			vars[key] or "" or "," -- 381
		) -- 381
	end -- 381
	return output -- 383
end -- 378
local function summarizeEditTextParamForHistory(value, key) -- 405
	if type(value) ~= "string" then -- 405
		return nil -- 406
	end -- 406
	local text = value -- 407
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 408
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 409
end -- 405
local function sanitizeReadResultForHistory(tool, result) -- 417
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 417
		return result -- 419
	end -- 419
	local clone = {} -- 421
	for key in pairs(result) do -- 422
		clone[key] = result[key] -- 423
	end -- 423
	clone.content = limitReadContentForHistory(result.content, tool) -- 425
	return clone -- 426
end -- 417
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 429
	local shown = math.min(#items, maxItems) -- 433
	local out = {} -- 434
	do -- 434
		local i = 0 -- 435
		while i < shown do -- 435
			local row = items[i + 1] -- 436
			out[#out + 1] = { -- 437
				file = row.file, -- 438
				line = row.line, -- 439
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 440
			} -- 440
			i = i + 1 -- 435
		end -- 435
	end -- 435
	return out -- 445
end -- 429
local function sanitizeSearchResultForHistory(tool, result) -- 448
	if result.success ~= true or type(result.results) ~= "table" then -- 448
		return result -- 452
	end -- 452
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 452
		return result -- 453
	end -- 453
	local clone = {} -- 454
	for key in pairs(result) do -- 455
		clone[key] = result[key] -- 456
	end -- 456
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 458
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 459
	if tool == "grep_files" and type(result.groupedResults) == "table" then -- 459
		local grouped = result.groupedResults -- 464
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 465
		local sanitizedGroups = {} -- 466
		do -- 466
			local i = 0 -- 467
			while i < shown do -- 467
				local row = grouped[i + 1] -- 468
				sanitizedGroups[#sanitizedGroups + 1] = { -- 469
					file = row.file, -- 470
					totalMatches = row.totalMatches, -- 471
					matches = type(row.matches) == "table" and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 472
				} -- 472
				i = i + 1 -- 467
			end -- 467
		end -- 467
		clone.groupedResults = sanitizedGroups -- 477
	end -- 477
	return clone -- 479
end -- 448
local function sanitizeListFilesResultForHistory(result) -- 482
	if result.success ~= true or type(result.files) ~= "table" then -- 482
		return result -- 483
	end -- 483
	local clone = {} -- 484
	for key in pairs(result) do -- 485
		clone[key] = result[key] -- 486
	end -- 486
	local files = result.files -- 488
	clone.files = __TS__ArraySlice(files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 489
	return clone -- 490
end -- 482
local function sanitizeActionParamsForHistory(tool, params) -- 493
	if tool ~= "edit_file" then -- 493
		return params -- 494
	end -- 494
	local clone = {} -- 495
	for key in pairs(params) do -- 496
		if key == "old_str" then -- 496
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 498
		elseif key == "new_str" then -- 498
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 500
		else -- 500
			clone[key] = params[key] -- 502
		end -- 502
	end -- 502
	return clone -- 505
end -- 493
local function trimPromptContext(text, maxChars, label) -- 508
	if #text <= maxChars then -- 508
		return text -- 509
	end -- 509
	local keepHead = math.max( -- 510
		0, -- 510
		math.floor(maxChars * 0.35) -- 510
	) -- 510
	local keepTail = math.max(0, maxChars - keepHead) -- 511
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 512
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 513
	return (((((("[history summary truncated for " .. label) .. "; showing head and tail within ") .. tostring(maxChars)) .. " chars]\n") .. head) .. "\n...\n") .. tail -- 514
end -- 508
local function formatHistorySummaryForDecision(history) -- 532
	return trimPromptContext( -- 533
		formatHistorySummary(history), -- 533
		DECISION_HISTORY_MAX_CHARS, -- 533
		"decision" -- 533
	) -- 533
end -- 532
local function getDecisionSystemPrompt(shared) -- 536
	return shared and shared.promptPack.agentIdentityPrompt or DEFAULT_AGENT_PROMPT_PACK.agentIdentityPrompt -- 537
end -- 536
local function getDecisionToolDefinitions(shared) -- 540
	return replacePromptVars( -- 541
		shared and shared.promptPack.toolDefinitionsDetailed or DEFAULT_AGENT_PROMPT_PACK.toolDefinitionsDetailed, -- 542
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 543
	) -- 543
end -- 540
local function maybeCompressHistory(shared) -- 547
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 547
		local ____shared_5 = shared -- 548
		local memory = ____shared_5.memory -- 548
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 549
		local changed = false -- 550
		do -- 550
			local round = 0 -- 551
			while round < maxRounds do -- 551
				if not memory.compressor:shouldCompress( -- 551
					shared.userQuery, -- 553
					shared.history, -- 554
					memory.lastConsolidatedIndex, -- 555
					getDecisionSystemPrompt(shared), -- 556
					getDecisionToolDefinitions(shared), -- 557
					formatHistorySummary -- 558
				) then -- 558
					return ____awaiter_resolve(nil) -- 558
				end -- 558
				local result = __TS__Await(memory.compressor:compress( -- 562
					shared.userQuery, -- 563
					shared.history, -- 564
					memory.lastConsolidatedIndex, -- 565
					shared.llmOptions, -- 566
					formatHistorySummary, -- 567
					shared.llmMaxTry, -- 568
					shared.decisionMode -- 569
				)) -- 569
				if not (result and result.success and result.compressedCount > 0) then -- 569
					if changed then -- 569
						persistHistoryState(shared) -- 573
					end -- 573
					return ____awaiter_resolve(nil) -- 573
				end -- 573
				memory.lastConsolidatedIndex = memory.lastConsolidatedIndex + result.compressedCount -- 577
				changed = true -- 578
				Log( -- 579
					"Info", -- 579
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " history records (round ") .. tostring(round + 1)) .. ")" -- 579
				) -- 579
				round = round + 1 -- 551
			end -- 551
		end -- 551
		if changed then -- 551
			persistHistoryState(shared) -- 582
		end -- 582
	end) -- 582
end -- 547
local function isKnownToolName(name) -- 586
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "message" or name == "finish" -- 587
end -- 586
local function extractYAMLFromText(text) -- 774
	local source = __TS__StringTrim(text) -- 775
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 776
	if yamlFencePos >= 0 then -- 776
		local from = yamlFencePos + #"```yaml" -- 778
		local ____end = (string.find( -- 779
			source, -- 779
			"```", -- 779
			math.max(from + 1, 1), -- 779
			true -- 779
		) or 0) - 1 -- 779
		if ____end > from then -- 779
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 780
		end -- 780
	end -- 780
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 782
	if ymlFencePos >= 0 then -- 782
		local from = ymlFencePos + #"```yml" -- 784
		local ____end = (string.find( -- 785
			source, -- 785
			"```", -- 785
			math.max(from + 1, 1), -- 785
			true -- 785
		) or 0) - 1 -- 785
		if ____end > from then -- 785
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 786
		end -- 786
	end -- 786
	local fencePos = (string.find(source, "```", nil, true) or 0) - 1 -- 788
	if fencePos >= 0 then -- 788
		local firstLineEnd = (string.find( -- 790
			source, -- 790
			"\n", -- 790
			math.max(fencePos + 1, 1), -- 790
			true -- 790
		) or 0) - 1 -- 790
		local ____end = (string.find( -- 791
			source, -- 791
			"```", -- 791
			math.max((firstLineEnd >= 0 and firstLineEnd + 1 or fencePos + 3) + 1, 1), -- 791
			true -- 791
		) or 0) - 1 -- 791
		if firstLineEnd >= 0 and ____end > firstLineEnd then -- 791
			return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, ____end)) -- 793
		end -- 793
	end -- 793
	return source -- 796
end -- 774
local function parseYAMLObjectFromText(text) -- 799
	local yamlText = extractYAMLFromText(text) -- 800
	local obj, err = yaml.parse(yamlText) -- 801
	if obj == nil or type(obj) ~= "table" then -- 801
		return { -- 803
			success = false, -- 803
			message = "invalid yaml: " .. tostring(err) -- 803
		} -- 803
	end -- 803
	return {success = true, obj = obj} -- 805
end -- 799
local function llm(shared, messages) -- 817
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 817
		local stepId = shared.step + 1 -- 818
		saveStepLLMDebugInput( -- 819
			shared, -- 819
			stepId, -- 819
			"decision_yaml", -- 819
			messages, -- 819
			shared.llmOptions -- 819
		) -- 819
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 820
		if res.success then -- 820
			local ____opt_10 = res.response.choices -- 820
			local ____opt_8 = ____opt_10 and ____opt_10[1] -- 820
			local ____opt_6 = ____opt_8 and ____opt_8.message -- 820
			local text = ____opt_6 and ____opt_6.content -- 822
			if text then -- 822
				saveStepLLMDebugOutput( -- 824
					shared, -- 824
					stepId, -- 824
					"decision_yaml", -- 824
					text, -- 824
					{success = true} -- 824
				) -- 824
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 824
			else -- 824
				saveStepLLMDebugOutput( -- 827
					shared, -- 827
					stepId, -- 827
					"decision_yaml", -- 827
					"empty LLM response", -- 827
					{success = false} -- 827
				) -- 827
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 827
			end -- 827
		else -- 827
			saveStepLLMDebugOutput( -- 831
				shared, -- 831
				stepId, -- 831
				"decision_yaml", -- 831
				res.raw or res.message, -- 831
				{success = false} -- 831
			) -- 831
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 831
		end -- 831
	end) -- 831
end -- 817
local function llmStream(shared, messages) -- 836
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 836
		local text = "" -- 837
		local cancelledReason -- 838
		local done = false -- 839
		if shared.stopToken.stopped then -- 839
			return ____awaiter_resolve( -- 839
				nil, -- 839
				{ -- 842
					success = false, -- 842
					message = getCancelledReason(shared), -- 842
					text = text -- 842
				} -- 842
			) -- 842
		end -- 842
		done = false -- 844
		cancelledReason = nil -- 845
		text = "" -- 846
		local stepId = shared.step -- 847
		saveStepLLMDebugInput( -- 848
			shared, -- 848
			stepId, -- 848
			"final_summary", -- 848
			messages, -- 848
			shared.llmOptions -- 848
		) -- 848
		callLLMStream( -- 849
			messages, -- 850
			shared.llmOptions, -- 851
			{ -- 852
				id = nil, -- 853
				stopToken = shared.stopToken, -- 854
				onData = function(data) -- 855
					if shared.stopToken.stopped then -- 855
						return true -- 856
					end -- 856
					local choice = data.choices and data.choices[1] -- 857
					local delta = choice and choice.delta -- 858
					if delta and type(delta.content) == "string" then -- 858
						local content = delta.content -- 860
						text = text .. content -- 861
						emitAgentEvent(shared, { -- 862
							type = "summary_stream", -- 863
							sessionId = shared.sessionId, -- 864
							taskId = shared.taskId, -- 865
							textDelta = content, -- 866
							fullText = text -- 867
						}) -- 867
						local res = json.encode({name = "LLMStream", content = content}) -- 869
						if res ~= nil then -- 869
							emit("AppWS", "Send", res) -- 871
						end -- 871
					end -- 871
					return false -- 874
				end, -- 855
				onCancel = function(reason) -- 876
					cancelledReason = reason -- 877
					done = true -- 878
				end, -- 876
				onDone = function() -- 880
					done = true -- 881
				end -- 880
			}, -- 880
			shared.llmConfig -- 884
		) -- 884
		__TS__Await(__TS__New( -- 887
			__TS__Promise, -- 887
			function(____, resolve) -- 887
				Director.systemScheduler:schedule(once(function() -- 888
					wait(function() return done or shared.stopToken.stopped end) -- 889
					resolve(nil) -- 890
				end)) -- 888
			end -- 887
		)) -- 887
		if shared.stopToken.stopped then -- 887
			cancelledReason = getCancelledReason(shared) -- 894
		end -- 894
		if not cancelledReason and text == "" then -- 894
			cancelledReason = "empty LLM output" -- 898
		end -- 898
		saveStepLLMDebugOutput( -- 900
			shared, -- 900
			stepId, -- 900
			"final_summary", -- 900
			cancelledReason and (("CANCELLED: " .. cancelledReason) .. "\n\n") .. text or text, -- 900
			{stream = true, cancelled = cancelledReason ~= nil} -- 900
		) -- 900
		if cancelledReason then -- 900
			return ____awaiter_resolve(nil, {success = false, message = cancelledReason, text = text}) -- 900
		end -- 900
		return ____awaiter_resolve(nil, {success = true, text = text}) -- 900
	end) -- 900
end -- 836
local function parseDecisionObject(rawObj) -- 920
	if type(rawObj.tool) ~= "string" then -- 920
		return {success = false, message = "missing tool"} -- 921
	end -- 921
	local tool = rawObj.tool -- 922
	if not isKnownToolName(tool) then -- 922
		return {success = false, message = "unknown tool: " .. tool} -- 924
	end -- 924
	if tool == "message" then -- 924
		return {success = false, message = "message is not a callable tool"} -- 927
	end -- 927
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 929
	return {success = true, tool = tool, params = params} -- 930
end -- 920
local function parseDecisionToolCall(functionName, rawObj) -- 933
	if not isKnownToolName(functionName) then -- 933
		return {success = false, message = "unknown tool: " .. functionName} -- 935
	end -- 935
	if functionName == "message" then -- 935
		return {success = false, message = "message is not a callable tool"} -- 938
	end -- 938
	if rawObj == nil or rawObj == nil then -- 938
		return {success = true, tool = functionName, params = {}} -- 941
	end -- 941
	if type(rawObj) ~= "table" then -- 941
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 944
	end -- 944
	return {success = true, tool = functionName, params = rawObj} -- 946
end -- 933
local function getDecisionPath(params) -- 953
	if type(params.path) == "string" then -- 953
		return __TS__StringTrim(params.path) -- 954
	end -- 954
	if type(params.target_file) == "string" then -- 954
		return __TS__StringTrim(params.target_file) -- 955
	end -- 955
	return "" -- 956
end -- 953
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 959
	local num = __TS__Number(value) -- 960
	if not __TS__NumberIsFinite(num) then -- 960
		num = fallback -- 961
	end -- 961
	num = math.floor(num) -- 962
	if num < minValue then -- 962
		num = minValue -- 963
	end -- 963
	if maxValue ~= nil and num > maxValue then -- 963
		num = maxValue -- 964
	end -- 964
	return num -- 965
end -- 959
local function validateDecision(tool, params) -- 968
	if tool == "finish" then -- 968
		return {success = true, params = params} -- 972
	end -- 972
	if tool == "read_file" then -- 972
		local path = getDecisionPath(params) -- 975
		if path == "" then -- 975
			return {success = false, message = "read_file requires path"} -- 976
		end -- 976
		params.path = path -- 977
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 978
		local ____params_endLine_12 = params.endLine -- 979
		if ____params_endLine_12 == nil then -- 979
			____params_endLine_12 = READ_FILE_DEFAULT_LIMIT -- 979
		end -- 979
		local endLineRaw = ____params_endLine_12 -- 979
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 980
		params.startLine = startLine -- 981
		params.endLine = endLine -- 982
		return {success = true, params = params} -- 983
	end -- 983
	if tool == "edit_file" then -- 983
		local path = getDecisionPath(params) -- 987
		if path == "" then -- 987
			return {success = false, message = "edit_file requires path"} -- 988
		end -- 988
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 989
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 990
		if oldStr == newStr then -- 990
			return {success = false, message = "edit_file old_str and new_str must be different"} -- 992
		end -- 992
		params.path = path -- 994
		params.old_str = oldStr -- 995
		params.new_str = newStr -- 996
		return {success = true, params = params} -- 997
	end -- 997
	if tool == "delete_file" then -- 997
		local targetFile = getDecisionPath(params) -- 1001
		if targetFile == "" then -- 1001
			return {success = false, message = "delete_file requires target_file"} -- 1002
		end -- 1002
		params.target_file = targetFile -- 1003
		return {success = true, params = params} -- 1004
	end -- 1004
	if tool == "grep_files" then -- 1004
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1008
		if pattern == "" then -- 1008
			return {success = false, message = "grep_files requires pattern"} -- 1009
		end -- 1009
		params.pattern = pattern -- 1010
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1011
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1012
		return {success = true, params = params} -- 1013
	end -- 1013
	if tool == "search_dora_api" then -- 1013
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1017
		if pattern == "" then -- 1017
			return {success = false, message = "search_dora_api requires pattern"} -- 1018
		end -- 1018
		params.pattern = pattern -- 1019
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1020
		return {success = true, params = params} -- 1021
	end -- 1021
	if tool == "glob_files" then -- 1021
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1025
		return {success = true, params = params} -- 1026
	end -- 1026
	if tool == "build" then -- 1026
		local path = getDecisionPath(params) -- 1030
		if path ~= "" then -- 1030
			params.path = path -- 1032
		end -- 1032
		return {success = true, params = params} -- 1034
	end -- 1034
	return {success = true, params = params} -- 1037
end -- 968
local function createFunctionToolSchema(name, description, properties, required) -- 1040
	if required == nil then -- 1040
		required = {} -- 1044
	end -- 1044
	local parameters = {type = "object", properties = properties} -- 1046
	if #required > 0 then -- 1046
		parameters.required = required -- 1051
	end -- 1051
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1053
end -- 1040
local function buildDecisionToolSchema() -- 1063
	return { -- 1064
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Parameters: path, startLine(optional), endLine(optional). Line numbering starts with 1. startLine defaults to 1 and endLine defaults to 300.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "1-based starting line number. Defaults to 1."}, endLine = {type = "number", description = "1-based ending line number. Defaults to 300."}}, {"path"}), -- 1065
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 1075
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1085
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1093
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1097
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1098
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1099
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1100
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1101
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1102
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1103
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1104
		}, {"pattern"}), -- 1104
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1108
		createFunctionToolSchema( -- 1117
			"search_dora_api", -- 1118
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1118
			{ -- 1120
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1121
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1122
				programmingLanguage = {type = "string", enum = { -- 1123
					"ts", -- 1125
					"tsx", -- 1125
					"lua", -- 1125
					"yue", -- 1125
					"teal", -- 1125
					"tl", -- 1125
					"wa" -- 1125
				}, description = "Preferred language variant to search."}, -- 1125
				limit = { -- 1128
					type = "number", -- 1128
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1128
				}, -- 1128
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1129
			}, -- 1129
			{"pattern"} -- 1131
		), -- 1131
		createFunctionToolSchema("build", "Run build/checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). After one build completes, do not run build again unless files were edited or deleted. Read the result and then finish or take corrective action.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 1133
		createFunctionToolSchema("finish", "End the task and let the agent summarize the outcome.", {}) -- 1140
	} -- 1140
end -- 1063
local function buildDecisionPrompt(shared, userQuery, historyText, memoryContext) -- 1148
	local toolDefinitions = shared.decisionMode == "yaml" and replacePromptVars( -- 1149
		shared.promptPack.toolDefinitionsDetailed, -- 1150
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1150
	) or "" -- 1150
	local memorySection = memoryContext -- 1154
	local toolSection = toolDefinitions ~= "" and "### Available Tools\n\n" .. toolDefinitions or "" -- 1155
	local staticPrompt = (((((shared.promptPack.decisionIntroPrompt .. "\n\n") .. memorySection) .. "\n\n### Current User Request\n\n### Action History\n\n") .. toolSection) .. "\n\n### Decision Rules\n\n") .. shared.promptPack.decisionRulesPrompt -- 1160
	local contextWindow = math.max(4000, shared.llmConfig.contextWindow) -- 1173
	local reservedOutputTokens = math.max( -- 1174
		1024, -- 1174
		math.floor(contextWindow * 0.2) -- 1174
	) -- 1174
	local staticTokens = estimateTextTokens(staticPrompt) -- 1175
	local dynamicBudget = math.max(1200, contextWindow - reservedOutputTokens - staticTokens - 256) -- 1176
	local boundedUserQuery = clipTextToTokenBudget( -- 1177
		userQuery, -- 1177
		math.max( -- 1177
			400, -- 1177
			math.floor(dynamicBudget * 0.4) -- 1177
		) -- 1177
	) -- 1177
	local boundedHistory = clipTextToTokenBudget( -- 1178
		historyText, -- 1178
		math.max( -- 1178
			400, -- 1178
			math.floor(dynamicBudget * 0.35) -- 1178
		) -- 1178
	) -- 1178
	local boundedMemory = clipTextToTokenBudget( -- 1179
		memoryContext, -- 1179
		math.max( -- 1179
			240, -- 1179
			math.floor(dynamicBudget * 0.25) -- 1179
		) -- 1179
	) -- 1179
	local boundedMemorySection = boundedMemory ~= "" and boundedMemory .. "\n" or "" -- 1180
	local toolSectionText = toolDefinitions ~= "" and ("### Available Tools\n\n" .. toolDefinitions) .. "\n" or "" -- 1184
	return (((((((((shared.promptPack.decisionIntroPrompt .. "\n\n") .. boundedMemorySection) .. "### Current User Request\n\n") .. boundedUserQuery) .. "\n\n### Action History\n\n") .. boundedHistory) .. "\n\n") .. toolSectionText) .. "### Decision Rules\n\n") .. shared.promptPack.decisionRulesPrompt -- 1190
end -- 1148
local function normalizeLineEndings(text) -- 1205
	return table.concat( -- 1206
		__TS__StringSplit( -- 1206
			table.concat( -- 1206
				__TS__StringSplit(text, "\r\n"), -- 1206
				"\n" -- 1206
			), -- 1206
			"\r" -- 1206
		), -- 1206
		"\n" -- 1206
	) -- 1206
end -- 1205
local function replaceAllAndCount(text, oldStr, newStr) -- 1209
	text = normalizeLineEndings(text) -- 1210
	oldStr = normalizeLineEndings(oldStr) -- 1211
	newStr = normalizeLineEndings(newStr) -- 1212
	if oldStr == "" then -- 1212
		return {content = text, replaced = 0} -- 1213
	end -- 1213
	local count = 0 -- 1214
	local from = 0 -- 1215
	while true do -- 1215
		local idx = (string.find( -- 1217
			text, -- 1217
			oldStr, -- 1217
			math.max(from + 1, 1), -- 1217
			true -- 1217
		) or 0) - 1 -- 1217
		if idx < 0 then -- 1217
			break -- 1218
		end -- 1218
		count = count + 1 -- 1219
		from = idx + #oldStr -- 1220
	end -- 1220
	if count == 0 then -- 1220
		return {content = text, replaced = 0} -- 1222
	end -- 1222
	return { -- 1223
		content = table.concat( -- 1224
			__TS__StringSplit(text, oldStr), -- 1224
			newStr or "," -- 1224
		), -- 1224
		replaced = count -- 1225
	} -- 1225
end -- 1209
local MainDecisionAgent = __TS__Class() -- 1229
MainDecisionAgent.name = "MainDecisionAgent" -- 1229
__TS__ClassExtends(MainDecisionAgent, Node) -- 1229
function MainDecisionAgent.prototype.prep(self, shared) -- 1230
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1230
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1230
			return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 1230
		end -- 1230
		__TS__Await(maybeCompressHistory(shared)) -- 1239
		return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 1239
	end) -- 1239
end -- 1230
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, prompt, lastError, attempt, lastRaw) -- 1248
	if attempt == nil then -- 1248
		attempt = 1 -- 1252
	end -- 1252
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1252
		if shared.stopToken.stopped then -- 1252
			return ____awaiter_resolve( -- 1252
				nil, -- 1252
				{ -- 1256
					success = false, -- 1256
					message = getCancelledReason(shared) -- 1256
				} -- 1256
			) -- 1256
		end -- 1256
		Log( -- 1258
			"Info", -- 1258
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1258
		) -- 1258
		local tools = buildDecisionToolSchema() -- 1259
		local messages = { -- 1260
			{ -- 1261
				role = "system", -- 1262
				content = table.concat( -- 1263
					{ -- 1263
						shared.promptPack.agentIdentityPrompt, -- 1264
						getReplyLanguageDirective(shared) -- 1265
					}, -- 1265
					"\n" -- 1266
				) -- 1266
			}, -- 1266
			{ -- 1268
				role = "user", -- 1269
				content = lastError and (((((prompt .. "\n\n") .. replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError})) .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") or prompt -- 1270
			} -- 1270
		} -- 1270
		local stepId = shared.step + 1 -- 1279
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1280
		saveStepLLMDebugInput( -- 1284
			shared, -- 1284
			stepId, -- 1284
			"decision_tool_calling", -- 1284
			messages, -- 1284
			llmOptions -- 1284
		) -- 1284
		local res = __TS__Await(callLLM(messages, llmOptions, shared.stopToken, shared.llmConfig)) -- 1285
		if shared.stopToken.stopped then -- 1285
			return ____awaiter_resolve( -- 1285
				nil, -- 1285
				{ -- 1287
					success = false, -- 1287
					message = getCancelledReason(shared) -- 1287
				} -- 1287
			) -- 1287
		end -- 1287
		if not res.success then -- 1287
			saveStepLLMDebugOutput( -- 1290
				shared, -- 1290
				stepId, -- 1290
				"decision_tool_calling", -- 1290
				res.raw or res.message, -- 1290
				{success = false} -- 1290
			) -- 1290
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1291
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1291
		end -- 1291
		saveStepLLMDebugOutput( -- 1294
			shared, -- 1294
			stepId, -- 1294
			"decision_tool_calling", -- 1294
			encodeDebugJSON(res.response), -- 1294
			{success = true} -- 1294
		) -- 1294
		local choice = res.response.choices and res.response.choices[1] -- 1295
		local message = choice and choice.message -- 1296
		local toolCalls = message and message.tool_calls -- 1297
		local toolCall = toolCalls and toolCalls[1] -- 1298
		local fn = toolCall and toolCall["function"] -- 1299
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 1300
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 1303
		Log( -- 1306
			"Info", -- 1306
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 1306
		) -- 1306
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 1306
			if messageContent and messageContent ~= "" then -- 1306
				Log( -- 1309
					"Info", -- 1309
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 1309
				) -- 1309
				return ____awaiter_resolve(nil, { -- 1309
					success = true, -- 1311
					tool = "finish", -- 1312
					params = {}, -- 1313
					reason = messageContent, -- 1314
					reasoningContent = reasoningContent, -- 1315
					directSummary = messageContent -- 1316
				}) -- 1316
			end -- 1316
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 1319
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 1319
		end -- 1319
		local functionName = fn.name -- 1326
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1327
		Log( -- 1328
			"Info", -- 1328
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 1328
		) -- 1328
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 1329
			local rawObj, err = json.decode(argsText) -- 1330
			if err ~= nil or rawObj == nil then -- 1330
				return {__error = tostring(err)} -- 1332
			end -- 1332
			return rawObj -- 1334
		end)() -- 1329
		if type(rawArgs) == "table" and rawArgs.__error ~= nil then -- 1329
			local err = tostring(rawArgs.__error) -- 1337
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 1338
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 1338
		end -- 1338
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 1345
		if not decision.success then -- 1345
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 1347
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1347
		end -- 1347
		local validation = validateDecision(decision.tool, decision.params) -- 1354
		if not validation.success then -- 1354
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 1356
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1356
		end -- 1356
		decision.params = validation.params -- 1363
		decision.reason = messageContent -- 1364
		decision.reasoningContent = reasoningContent -- 1365
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 1366
		return ____awaiter_resolve(nil, decision) -- 1366
	end) -- 1366
end -- 1248
function MainDecisionAgent.prototype.exec(self, input) -- 1370
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1370
		local shared = input.shared -- 1371
		if shared.stopToken.stopped then -- 1371
			return ____awaiter_resolve( -- 1371
				nil, -- 1371
				{ -- 1373
					success = false, -- 1373
					message = getCancelledReason(shared) -- 1373
				} -- 1373
			) -- 1373
		end -- 1373
		if shared.step >= shared.maxSteps then -- 1373
			Log( -- 1376
				"Warn", -- 1376
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1376
			) -- 1376
			return ____awaiter_resolve( -- 1376
				nil, -- 1376
				{ -- 1377
					success = false, -- 1377
					message = getMaxStepsReachedReason(shared) -- 1377
				} -- 1377
			) -- 1377
		end -- 1377
		local memory = shared.memory -- 1377
		local memoryContext = memory.compressor:getStorage():getMemoryContext() -- 1382
		local uncompressedHistory = __TS__ArraySlice(input.history, memory.lastConsolidatedIndex) -- 1387
		local historyText = formatHistorySummaryForDecision(uncompressedHistory) -- 1388
		local prompt = buildDecisionPrompt(input.shared, input.userQuery, historyText, memoryContext) -- 1390
		if shared.decisionMode == "tool_calling" then -- 1390
			Log( -- 1393
				"Info", -- 1393
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " history=") .. tostring(#uncompressedHistory) -- 1393
			) -- 1393
			local lastError = "tool calling validation failed" -- 1394
			local lastRaw = "" -- 1395
			do -- 1395
				local attempt = 0 -- 1396
				while attempt < shared.llmMaxTry do -- 1396
					Log( -- 1397
						"Info", -- 1397
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1397
					) -- 1397
					local decision = __TS__Await(self:callDecisionByToolCalling( -- 1398
						shared, -- 1399
						prompt, -- 1400
						attempt > 0 and lastError or nil, -- 1401
						attempt + 1, -- 1402
						lastRaw -- 1403
					)) -- 1403
					if shared.stopToken.stopped then -- 1403
						return ____awaiter_resolve( -- 1403
							nil, -- 1403
							{ -- 1406
								success = false, -- 1406
								message = getCancelledReason(shared) -- 1406
							} -- 1406
						) -- 1406
					end -- 1406
					if decision.success then -- 1406
						return ____awaiter_resolve(nil, decision) -- 1406
					end -- 1406
					lastError = decision.message -- 1411
					lastRaw = decision.raw or "" -- 1412
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1413
					attempt = attempt + 1 -- 1396
				end -- 1396
			end -- 1396
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1415
			return ____awaiter_resolve( -- 1415
				nil, -- 1415
				{ -- 1416
					success = false, -- 1416
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1416
				} -- 1416
			) -- 1416
		end -- 1416
		local yamlPrompt = ((prompt .. "\n\n") .. shared.promptPack.yamlDecisionFormatPrompt) .. "\n- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.\n- Keep params shallow and valid for the selected tool.\n- Use tabs for all indentation, never spaces.\nIf no more actions are needed, use tool: finish." -- 1419
		local lastError = "yaml validation failed" -- 1427
		local lastRaw = "" -- 1428
		do -- 1428
			local attempt = 0 -- 1429
			while attempt < shared.llmMaxTry do -- 1429
				do -- 1429
					local feedback = attempt > 0 and (((("\n\nPrevious response was invalid (" .. lastError) .. "). Retry attempt: ") .. tostring(attempt + 1)) .. ". Return exactly one valid YAML object only and keep YAML indentation strictly consistent. The next reply must differ from the rejected one.") .. (lastRaw ~= "" and "\nLast rejected output summary: " .. truncateText(lastRaw, 300) or "") or "" -- 1430
					local messages = {{role = "user", content = yamlPrompt .. feedback}} -- 1433
					local llmRes = __TS__Await(llm(shared, messages)) -- 1434
					if shared.stopToken.stopped then -- 1434
						return ____awaiter_resolve( -- 1434
							nil, -- 1434
							{ -- 1436
								success = false, -- 1436
								message = getCancelledReason(shared) -- 1436
							} -- 1436
						) -- 1436
					end -- 1436
					if not llmRes.success then -- 1436
						lastError = llmRes.message -- 1439
						goto __continue257 -- 1440
					end -- 1440
					lastRaw = llmRes.text -- 1442
					local parsed = parseYAMLObjectFromText(llmRes.text) -- 1443
					if not parsed.success then -- 1443
						lastError = parsed.message -- 1445
						goto __continue257 -- 1446
					end -- 1446
					local decision = parseDecisionObject(parsed.obj) -- 1448
					if not decision.success then -- 1448
						lastError = decision.message -- 1450
						goto __continue257 -- 1451
					end -- 1451
					local validation = validateDecision(decision.tool, decision.params) -- 1453
					if not validation.success then -- 1453
						lastError = validation.message -- 1455
						goto __continue257 -- 1456
					end -- 1456
					decision.params = validation.params -- 1458
					return ____awaiter_resolve(nil, decision) -- 1458
				end -- 1458
				::__continue257:: -- 1458
				attempt = attempt + 1 -- 1429
			end -- 1429
		end -- 1429
		return ____awaiter_resolve( -- 1429
			nil, -- 1429
			{ -- 1461
				success = false, -- 1461
				message = (("cannot produce valid decision yaml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1461
			} -- 1461
		) -- 1461
	end) -- 1461
end -- 1370
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1464
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1464
		local result = execRes -- 1465
		if not result.success then -- 1465
			shared.error = result.message -- 1467
			return ____awaiter_resolve(nil, "error") -- 1467
		end -- 1467
		if result.directSummary and result.directSummary ~= "" then -- 1467
			shared.response = result.directSummary -- 1471
			shared.done = true -- 1472
			persistHistoryState(shared) -- 1473
			return ____awaiter_resolve(nil, nil) -- 1473
		end -- 1473
		emitAgentEvent(shared, { -- 1476
			type = "decision_made", -- 1477
			sessionId = shared.sessionId, -- 1478
			taskId = shared.taskId, -- 1479
			step = shared.step + 1, -- 1480
			tool = result.tool, -- 1481
			reason = result.reason, -- 1482
			reasoningContent = result.reasoningContent, -- 1483
			params = result.params -- 1484
		}) -- 1484
		local ____shared_history_13 = shared.history -- 1484
		____shared_history_13[#____shared_history_13 + 1] = { -- 1486
			step = #shared.history + 1, -- 1487
			tool = result.tool, -- 1488
			reason = result.reason or "", -- 1489
			reasoningContent = result.reasoningContent, -- 1490
			params = result.params, -- 1491
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1492
		} -- 1492
		persistHistoryState(shared) -- 1494
		return ____awaiter_resolve(nil, result.tool) -- 1494
	end) -- 1494
end -- 1464
local ReadFileAction = __TS__Class() -- 1499
ReadFileAction.name = "ReadFileAction" -- 1499
__TS__ClassExtends(ReadFileAction, Node) -- 1499
function ReadFileAction.prototype.prep(self, shared) -- 1500
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1500
		local last = shared.history[#shared.history] -- 1501
		if not last then -- 1501
			error( -- 1502
				__TS__New(Error, "no history"), -- 1502
				0 -- 1502
			) -- 1502
		end -- 1502
		emitAgentEvent(shared, { -- 1503
			type = "tool_started", -- 1504
			sessionId = shared.sessionId, -- 1505
			taskId = shared.taskId, -- 1506
			step = shared.step + 1, -- 1507
			tool = last.tool -- 1508
		}) -- 1508
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1510
		if __TS__StringTrim(path) == "" then -- 1510
			error( -- 1513
				__TS__New(Error, "missing path"), -- 1513
				0 -- 1513
			) -- 1513
		end -- 1513
		local ____path_16 = path -- 1515
		local ____shared_workingDir_17 = shared.workingDir -- 1517
		local ____temp_18 = shared.useChineseResponse and "zh" or "en" -- 1518
		local ____last_params_startLine_14 = last.params.startLine -- 1519
		if ____last_params_startLine_14 == nil then -- 1519
			____last_params_startLine_14 = 1 -- 1519
		end -- 1519
		local ____TS__Number_result_19 = __TS__Number(____last_params_startLine_14) -- 1519
		local ____last_params_endLine_15 = last.params.endLine -- 1520
		if ____last_params_endLine_15 == nil then -- 1520
			____last_params_endLine_15 = READ_FILE_DEFAULT_LIMIT -- 1520
		end -- 1520
		return ____awaiter_resolve( -- 1520
			nil, -- 1520
			{ -- 1514
				path = ____path_16, -- 1515
				tool = "read_file", -- 1516
				workDir = ____shared_workingDir_17, -- 1517
				docLanguage = ____temp_18, -- 1518
				startLine = ____TS__Number_result_19, -- 1519
				endLine = __TS__Number(____last_params_endLine_15) -- 1520
			} -- 1520
		) -- 1520
	end) -- 1520
end -- 1500
function ReadFileAction.prototype.exec(self, input) -- 1524
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1524
		return ____awaiter_resolve( -- 1524
			nil, -- 1524
			Tools.readFile( -- 1525
				input.workDir, -- 1526
				input.path, -- 1527
				__TS__Number(input.startLine or 1), -- 1528
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 1529
				input.docLanguage -- 1530
			) -- 1530
		) -- 1530
	end) -- 1530
end -- 1524
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1534
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1534
		local result = execRes -- 1535
		local last = shared.history[#shared.history] -- 1536
		if last ~= nil then -- 1536
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1538
			emitAgentEvent(shared, { -- 1539
				type = "tool_finished", -- 1540
				sessionId = shared.sessionId, -- 1541
				taskId = shared.taskId, -- 1542
				step = shared.step + 1, -- 1543
				tool = last.tool, -- 1544
				result = last.result -- 1545
			}) -- 1545
		end -- 1545
		__TS__Await(maybeCompressHistory(shared)) -- 1548
		persistHistoryState(shared) -- 1549
		shared.step = shared.step + 1 -- 1550
		return ____awaiter_resolve(nil, "main") -- 1550
	end) -- 1550
end -- 1534
local SearchFilesAction = __TS__Class() -- 1555
SearchFilesAction.name = "SearchFilesAction" -- 1555
__TS__ClassExtends(SearchFilesAction, Node) -- 1555
function SearchFilesAction.prototype.prep(self, shared) -- 1556
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1556
		local last = shared.history[#shared.history] -- 1557
		if not last then -- 1557
			error( -- 1558
				__TS__New(Error, "no history"), -- 1558
				0 -- 1558
			) -- 1558
		end -- 1558
		emitAgentEvent(shared, { -- 1559
			type = "tool_started", -- 1560
			sessionId = shared.sessionId, -- 1561
			taskId = shared.taskId, -- 1562
			step = shared.step + 1, -- 1563
			tool = last.tool -- 1564
		}) -- 1564
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1564
	end) -- 1564
end -- 1556
function SearchFilesAction.prototype.exec(self, input) -- 1569
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1569
		local params = input.params -- 1570
		local ____Tools_searchFiles_33 = Tools.searchFiles -- 1571
		local ____input_workDir_26 = input.workDir -- 1572
		local ____temp_27 = params.path or "" -- 1573
		local ____temp_28 = params.pattern or "" -- 1574
		local ____params_globs_29 = params.globs -- 1575
		local ____params_useRegex_30 = params.useRegex -- 1576
		local ____params_caseSensitive_31 = params.caseSensitive -- 1577
		local ____math_max_22 = math.max -- 1580
		local ____math_floor_21 = math.floor -- 1580
		local ____params_limit_20 = params.limit -- 1580
		if ____params_limit_20 == nil then -- 1580
			____params_limit_20 = SEARCH_FILES_LIMIT_DEFAULT -- 1580
		end -- 1580
		local ____math_max_22_result_32 = ____math_max_22( -- 1580
			1, -- 1580
			____math_floor_21(__TS__Number(____params_limit_20)) -- 1580
		) -- 1580
		local ____math_max_25 = math.max -- 1581
		local ____math_floor_24 = math.floor -- 1581
		local ____params_offset_23 = params.offset -- 1581
		if ____params_offset_23 == nil then -- 1581
			____params_offset_23 = 0 -- 1581
		end -- 1581
		local result = __TS__Await(____Tools_searchFiles_33({ -- 1571
			workDir = ____input_workDir_26, -- 1572
			path = ____temp_27, -- 1573
			pattern = ____temp_28, -- 1574
			globs = ____params_globs_29, -- 1575
			useRegex = ____params_useRegex_30, -- 1576
			caseSensitive = ____params_caseSensitive_31, -- 1577
			includeContent = true, -- 1578
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1579
			limit = ____math_max_22_result_32, -- 1580
			offset = ____math_max_25( -- 1581
				0, -- 1581
				____math_floor_24(__TS__Number(____params_offset_23)) -- 1581
			), -- 1581
			groupByFile = params.groupByFile == true -- 1582
		})) -- 1582
		return ____awaiter_resolve(nil, result) -- 1582
	end) -- 1582
end -- 1569
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1587
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1587
		local last = shared.history[#shared.history] -- 1588
		if last ~= nil then -- 1588
			local result = execRes -- 1590
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1591
			emitAgentEvent(shared, { -- 1592
				type = "tool_finished", -- 1593
				sessionId = shared.sessionId, -- 1594
				taskId = shared.taskId, -- 1595
				step = shared.step + 1, -- 1596
				tool = last.tool, -- 1597
				result = last.result -- 1598
			}) -- 1598
		end -- 1598
		__TS__Await(maybeCompressHistory(shared)) -- 1601
		persistHistoryState(shared) -- 1602
		shared.step = shared.step + 1 -- 1603
		return ____awaiter_resolve(nil, "main") -- 1603
	end) -- 1603
end -- 1587
local SearchDoraAPIAction = __TS__Class() -- 1608
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1608
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1608
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1609
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1609
		local last = shared.history[#shared.history] -- 1610
		if not last then -- 1610
			error( -- 1611
				__TS__New(Error, "no history"), -- 1611
				0 -- 1611
			) -- 1611
		end -- 1611
		emitAgentEvent(shared, { -- 1612
			type = "tool_started", -- 1613
			sessionId = shared.sessionId, -- 1614
			taskId = shared.taskId, -- 1615
			step = shared.step + 1, -- 1616
			tool = last.tool -- 1617
		}) -- 1617
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1617
	end) -- 1617
end -- 1609
function SearchDoraAPIAction.prototype.exec(self, input) -- 1622
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1622
		local params = input.params -- 1623
		local ____Tools_searchDoraAPI_41 = Tools.searchDoraAPI -- 1624
		local ____temp_37 = params.pattern or "" -- 1625
		local ____temp_38 = params.docSource or "api" -- 1626
		local ____temp_39 = input.useChineseResponse and "zh" or "en" -- 1627
		local ____temp_40 = params.programmingLanguage or "ts" -- 1628
		local ____math_min_36 = math.min -- 1629
		local ____math_max_35 = math.max -- 1629
		local ____params_limit_34 = params.limit -- 1629
		if ____params_limit_34 == nil then -- 1629
			____params_limit_34 = 8 -- 1629
		end -- 1629
		local result = __TS__Await(____Tools_searchDoraAPI_41({ -- 1624
			pattern = ____temp_37, -- 1625
			docSource = ____temp_38, -- 1626
			docLanguage = ____temp_39, -- 1627
			programmingLanguage = ____temp_40, -- 1628
			limit = ____math_min_36( -- 1629
				SEARCH_DORA_API_LIMIT_MAX, -- 1629
				____math_max_35( -- 1629
					1, -- 1629
					__TS__Number(____params_limit_34) -- 1629
				) -- 1629
			), -- 1629
			useRegex = params.useRegex, -- 1630
			caseSensitive = false, -- 1631
			includeContent = true, -- 1632
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1633
		})) -- 1633
		return ____awaiter_resolve(nil, result) -- 1633
	end) -- 1633
end -- 1622
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1638
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1638
		local last = shared.history[#shared.history] -- 1639
		if last ~= nil then -- 1639
			local result = execRes -- 1641
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1642
			emitAgentEvent(shared, { -- 1643
				type = "tool_finished", -- 1644
				sessionId = shared.sessionId, -- 1645
				taskId = shared.taskId, -- 1646
				step = shared.step + 1, -- 1647
				tool = last.tool, -- 1648
				result = last.result -- 1649
			}) -- 1649
		end -- 1649
		__TS__Await(maybeCompressHistory(shared)) -- 1652
		persistHistoryState(shared) -- 1653
		shared.step = shared.step + 1 -- 1654
		return ____awaiter_resolve(nil, "main") -- 1654
	end) -- 1654
end -- 1638
local ListFilesAction = __TS__Class() -- 1659
ListFilesAction.name = "ListFilesAction" -- 1659
__TS__ClassExtends(ListFilesAction, Node) -- 1659
function ListFilesAction.prototype.prep(self, shared) -- 1660
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1660
		local last = shared.history[#shared.history] -- 1661
		if not last then -- 1661
			error( -- 1662
				__TS__New(Error, "no history"), -- 1662
				0 -- 1662
			) -- 1662
		end -- 1662
		emitAgentEvent(shared, { -- 1663
			type = "tool_started", -- 1664
			sessionId = shared.sessionId, -- 1665
			taskId = shared.taskId, -- 1666
			step = shared.step + 1, -- 1667
			tool = last.tool -- 1668
		}) -- 1668
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1668
	end) -- 1668
end -- 1660
function ListFilesAction.prototype.exec(self, input) -- 1673
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1673
		local params = input.params -- 1674
		local ____Tools_listFiles_48 = Tools.listFiles -- 1675
		local ____input_workDir_45 = input.workDir -- 1676
		local ____temp_46 = params.path or "" -- 1677
		local ____params_globs_47 = params.globs -- 1678
		local ____math_max_44 = math.max -- 1679
		local ____math_floor_43 = math.floor -- 1679
		local ____params_maxEntries_42 = params.maxEntries -- 1679
		if ____params_maxEntries_42 == nil then -- 1679
			____params_maxEntries_42 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1679
		end -- 1679
		local result = ____Tools_listFiles_48({ -- 1675
			workDir = ____input_workDir_45, -- 1676
			path = ____temp_46, -- 1677
			globs = ____params_globs_47, -- 1678
			maxEntries = ____math_max_44( -- 1679
				1, -- 1679
				____math_floor_43(__TS__Number(____params_maxEntries_42)) -- 1679
			) -- 1679
		}) -- 1679
		return ____awaiter_resolve(nil, result) -- 1679
	end) -- 1679
end -- 1673
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1684
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1684
		local last = shared.history[#shared.history] -- 1685
		if last ~= nil then -- 1685
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1687
			emitAgentEvent(shared, { -- 1688
				type = "tool_finished", -- 1689
				sessionId = shared.sessionId, -- 1690
				taskId = shared.taskId, -- 1691
				step = shared.step + 1, -- 1692
				tool = last.tool, -- 1693
				result = last.result -- 1694
			}) -- 1694
		end -- 1694
		__TS__Await(maybeCompressHistory(shared)) -- 1697
		persistHistoryState(shared) -- 1698
		shared.step = shared.step + 1 -- 1699
		return ____awaiter_resolve(nil, "main") -- 1699
	end) -- 1699
end -- 1684
local DeleteFileAction = __TS__Class() -- 1704
DeleteFileAction.name = "DeleteFileAction" -- 1704
__TS__ClassExtends(DeleteFileAction, Node) -- 1704
function DeleteFileAction.prototype.prep(self, shared) -- 1705
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1705
		local last = shared.history[#shared.history] -- 1706
		if not last then -- 1706
			error( -- 1707
				__TS__New(Error, "no history"), -- 1707
				0 -- 1707
			) -- 1707
		end -- 1707
		emitAgentEvent(shared, { -- 1708
			type = "tool_started", -- 1709
			sessionId = shared.sessionId, -- 1710
			taskId = shared.taskId, -- 1711
			step = shared.step + 1, -- 1712
			tool = last.tool -- 1713
		}) -- 1713
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1715
		if __TS__StringTrim(targetFile) == "" then -- 1715
			error( -- 1718
				__TS__New(Error, "missing target_file"), -- 1718
				0 -- 1718
			) -- 1718
		end -- 1718
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1718
	end) -- 1718
end -- 1705
function DeleteFileAction.prototype.exec(self, input) -- 1722
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1722
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1723
		if not result.success then -- 1723
			return ____awaiter_resolve(nil, result) -- 1723
		end -- 1723
		return ____awaiter_resolve(nil, { -- 1723
			success = true, -- 1731
			changed = true, -- 1732
			mode = "delete", -- 1733
			checkpointId = result.checkpointId, -- 1734
			checkpointSeq = result.checkpointSeq, -- 1735
			files = {{path = input.targetFile, op = "delete"}} -- 1736
		}) -- 1736
	end) -- 1736
end -- 1722
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1740
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1740
		local last = shared.history[#shared.history] -- 1741
		if last ~= nil then -- 1741
			last.result = execRes -- 1743
			emitAgentEvent(shared, { -- 1744
				type = "tool_finished", -- 1745
				sessionId = shared.sessionId, -- 1746
				taskId = shared.taskId, -- 1747
				step = shared.step + 1, -- 1748
				tool = last.tool, -- 1749
				result = last.result -- 1750
			}) -- 1750
			local result = last.result -- 1752
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1752
				emitAgentEvent(shared, { -- 1757
					type = "checkpoint_created", -- 1758
					sessionId = shared.sessionId, -- 1759
					taskId = shared.taskId, -- 1760
					step = shared.step + 1, -- 1761
					tool = "delete_file", -- 1762
					checkpointId = result.checkpointId, -- 1763
					checkpointSeq = result.checkpointSeq, -- 1764
					files = result.files -- 1765
				}) -- 1765
			end -- 1765
		end -- 1765
		__TS__Await(maybeCompressHistory(shared)) -- 1769
		persistHistoryState(shared) -- 1770
		shared.step = shared.step + 1 -- 1771
		return ____awaiter_resolve(nil, "main") -- 1771
	end) -- 1771
end -- 1740
local BuildAction = __TS__Class() -- 1776
BuildAction.name = "BuildAction" -- 1776
__TS__ClassExtends(BuildAction, Node) -- 1776
function BuildAction.prototype.prep(self, shared) -- 1777
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1777
		local last = shared.history[#shared.history] -- 1778
		if not last then -- 1778
			error( -- 1779
				__TS__New(Error, "no history"), -- 1779
				0 -- 1779
			) -- 1779
		end -- 1779
		emitAgentEvent(shared, { -- 1780
			type = "tool_started", -- 1781
			sessionId = shared.sessionId, -- 1782
			taskId = shared.taskId, -- 1783
			step = shared.step + 1, -- 1784
			tool = last.tool -- 1785
		}) -- 1785
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1785
	end) -- 1785
end -- 1777
function BuildAction.prototype.exec(self, input) -- 1790
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1790
		local params = input.params -- 1791
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1792
		return ____awaiter_resolve(nil, result) -- 1792
	end) -- 1792
end -- 1790
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1799
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1799
		local last = shared.history[#shared.history] -- 1800
		if last ~= nil then -- 1800
			last.result = execRes -- 1802
			emitAgentEvent(shared, { -- 1803
				type = "tool_finished", -- 1804
				sessionId = shared.sessionId, -- 1805
				taskId = shared.taskId, -- 1806
				step = shared.step + 1, -- 1807
				tool = last.tool, -- 1808
				result = last.result -- 1809
			}) -- 1809
		end -- 1809
		__TS__Await(maybeCompressHistory(shared)) -- 1812
		persistHistoryState(shared) -- 1813
		shared.step = shared.step + 1 -- 1814
		return ____awaiter_resolve(nil, "main") -- 1814
	end) -- 1814
end -- 1799
local EditFileAction = __TS__Class() -- 1819
EditFileAction.name = "EditFileAction" -- 1819
__TS__ClassExtends(EditFileAction, Node) -- 1819
function EditFileAction.prototype.prep(self, shared) -- 1820
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1820
		local last = shared.history[#shared.history] -- 1821
		if not last then -- 1821
			error( -- 1822
				__TS__New(Error, "no history"), -- 1822
				0 -- 1822
			) -- 1822
		end -- 1822
		emitAgentEvent(shared, { -- 1823
			type = "tool_started", -- 1824
			sessionId = shared.sessionId, -- 1825
			taskId = shared.taskId, -- 1826
			step = shared.step + 1, -- 1827
			tool = last.tool -- 1828
		}) -- 1828
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1830
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1833
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1834
		if __TS__StringTrim(path) == "" then -- 1834
			error( -- 1835
				__TS__New(Error, "missing path"), -- 1835
				0 -- 1835
			) -- 1835
		end -- 1835
		if oldStr == newStr then -- 1835
			error( -- 1836
				__TS__New(Error, "old_str and new_str must be different"), -- 1836
				0 -- 1836
			) -- 1836
		end -- 1836
		return ____awaiter_resolve(nil, { -- 1836
			path = path, -- 1837
			oldStr = oldStr, -- 1837
			newStr = newStr, -- 1837
			taskId = shared.taskId, -- 1837
			workDir = shared.workingDir -- 1837
		}) -- 1837
	end) -- 1837
end -- 1820
function EditFileAction.prototype.exec(self, input) -- 1840
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1840
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1841
		if not readRes.success then -- 1841
			if input.oldStr ~= "" then -- 1841
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1841
			end -- 1841
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1846
			if not createRes.success then -- 1846
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1846
			end -- 1846
			return ____awaiter_resolve(nil, { -- 1846
				success = true, -- 1854
				changed = true, -- 1855
				mode = "create", -- 1856
				replaced = 0, -- 1857
				checkpointId = createRes.checkpointId, -- 1858
				checkpointSeq = createRes.checkpointSeq, -- 1859
				files = {{path = input.path, op = "create"}} -- 1860
			}) -- 1860
		end -- 1860
		if input.oldStr == "" then -- 1860
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 1860
		end -- 1860
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 1867
		if replaceRes.replaced == 0 then -- 1867
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 1867
		end -- 1867
		if replaceRes.content == readRes.content then -- 1867
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 1867
		end -- 1867
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1880
		if not applyRes.success then -- 1880
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1880
		end -- 1880
		return ____awaiter_resolve(nil, { -- 1880
			success = true, -- 1888
			changed = true, -- 1889
			mode = "replace", -- 1890
			replaced = replaceRes.replaced, -- 1891
			checkpointId = applyRes.checkpointId, -- 1892
			checkpointSeq = applyRes.checkpointSeq, -- 1893
			files = {{path = input.path, op = "write"}} -- 1894
		}) -- 1894
	end) -- 1894
end -- 1840
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1898
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1898
		local last = shared.history[#shared.history] -- 1899
		if last ~= nil then -- 1899
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1901
			last.result = execRes -- 1902
			emitAgentEvent(shared, { -- 1903
				type = "tool_finished", -- 1904
				sessionId = shared.sessionId, -- 1905
				taskId = shared.taskId, -- 1906
				step = shared.step + 1, -- 1907
				tool = last.tool, -- 1908
				result = last.result -- 1909
			}) -- 1909
			local result = last.result -- 1911
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1911
				emitAgentEvent(shared, { -- 1916
					type = "checkpoint_created", -- 1917
					sessionId = shared.sessionId, -- 1918
					taskId = shared.taskId, -- 1919
					step = shared.step + 1, -- 1920
					tool = last.tool, -- 1921
					checkpointId = result.checkpointId, -- 1922
					checkpointSeq = result.checkpointSeq, -- 1923
					files = result.files -- 1924
				}) -- 1924
			end -- 1924
		end -- 1924
		__TS__Await(maybeCompressHistory(shared)) -- 1928
		persistHistoryState(shared) -- 1929
		shared.step = shared.step + 1 -- 1930
		return ____awaiter_resolve(nil, "main") -- 1930
	end) -- 1930
end -- 1898
local FormatResponseNode = __TS__Class() -- 1935
FormatResponseNode.name = "FormatResponseNode" -- 1935
__TS__ClassExtends(FormatResponseNode, Node) -- 1935
function FormatResponseNode.prototype.prep(self, shared) -- 1936
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1936
		local last = shared.history[#shared.history] -- 1937
		if last and last.tool == "finish" then -- 1937
			emitAgentEvent(shared, { -- 1939
				type = "tool_started", -- 1940
				sessionId = shared.sessionId, -- 1941
				taskId = shared.taskId, -- 1942
				step = shared.step + 1, -- 1943
				tool = last.tool -- 1944
			}) -- 1944
		end -- 1944
		return ____awaiter_resolve(nil, {history = shared.history, shared = shared}) -- 1944
	end) -- 1944
end -- 1936
function FormatResponseNode.prototype.exec(self, input) -- 1950
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1950
		if input.shared.stopToken.stopped then -- 1950
			return ____awaiter_resolve( -- 1950
				nil, -- 1950
				getCancelledReason(input.shared) -- 1952
			) -- 1952
		end -- 1952
		local failureNote = input.shared.error and input.shared.error ~= "" and (input.shared.useChineseResponse and "\n\n本次任务因以下错误结束，请在总结中明确说明：\n" .. input.shared.error or "\n\nThis task ended with the following error. Make sure the summary states it clearly:\n" .. input.shared.error) or "" -- 1954
		local history = input.history -- 1959
		if #history == 0 then -- 1959
			if input.shared.error and input.shared.error ~= "" then -- 1959
				return ____awaiter_resolve( -- 1959
					nil, -- 1959
					getFailureSummaryFallback(input.shared, input.shared.error) -- 1962
				) -- 1962
			end -- 1962
			return ____awaiter_resolve(nil, "No actions were performed.") -- 1962
		end -- 1962
		local summary = formatHistorySummary(history) -- 1966
		local staticPrompt = replacePromptVars( -- 1967
			input.shared.promptPack.finalSummaryPrompt, -- 1967
			{ -- 1967
				SUMMARY = "", -- 1968
				LANGUAGE_DIRECTIVE = getReplyLanguageDirective(input.shared) -- 1969
			} -- 1969
		) -- 1969
		local contextWindow = math.max(4000, input.shared.llmConfig.contextWindow) -- 1971
		local reservedOutputTokens = math.max( -- 1972
			1024, -- 1972
			math.floor(contextWindow * 0.2) -- 1972
		) -- 1972
		local staticTokens = estimateTextTokens(staticPrompt) -- 1973
		local failureTokens = estimateTextTokens(failureNote) -- 1974
		local summaryBudget = math.max(400, contextWindow - reservedOutputTokens - staticTokens - failureTokens - 256) -- 1975
		local boundedSummary = clipTextToTokenBudget(summary, summaryBudget) -- 1976
		local prompt = replacePromptVars( -- 1977
			input.shared.promptPack.finalSummaryPrompt, -- 1977
			{ -- 1977
				SUMMARY = boundedSummary, -- 1978
				LANGUAGE_DIRECTIVE = getReplyLanguageDirective(input.shared) -- 1979
			} -- 1979
		) .. failureNote -- 1979
		local res -- 1981
		do -- 1981
			local i = 0 -- 1982
			while i < input.shared.llmMaxTry do -- 1982
				res = __TS__Await(llmStream(input.shared, {{role = "user", content = prompt}})) -- 1983
				if res.success then -- 1983
					break -- 1984
				end -- 1984
				i = i + 1 -- 1982
			end -- 1982
		end -- 1982
		if not res then -- 1982
			return ____awaiter_resolve( -- 1982
				nil, -- 1982
				input.shared.error and input.shared.error ~= "" and getFailureSummaryFallback(input.shared, input.shared.error) or (input.shared.useChineseResponse and "执行完成，但生成总结失败。" or "Completed, but failed to generate summary.") -- 1987
			) -- 1987
		end -- 1987
		if not res.success then -- 1987
			return ____awaiter_resolve( -- 1987
				nil, -- 1987
				input.shared.error and input.shared.error ~= "" and getFailureSummaryFallback(input.shared, input.shared.error) or (input.shared.useChineseResponse and "执行完成，但生成总结失败：" .. res.message or "Completed, but failed to generate summary: " .. res.message) -- 1994
			) -- 1994
		end -- 1994
		return ____awaiter_resolve(nil, res.text) -- 1994
	end) -- 1994
end -- 1950
function FormatResponseNode.prototype.post(self, shared, _prepRes, execRes) -- 2003
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2003
		local last = shared.history[#shared.history] -- 2004
		if last and last.tool == "finish" then -- 2004
			last.result = {success = true, message = execRes} -- 2006
			emitAgentEvent(shared, { -- 2007
				type = "tool_finished", -- 2008
				sessionId = shared.sessionId, -- 2009
				taskId = shared.taskId, -- 2010
				step = shared.step + 1, -- 2011
				tool = last.tool, -- 2012
				result = last.result -- 2013
			}) -- 2013
			shared.step = shared.step + 1 -- 2015
		end -- 2015
		shared.response = execRes -- 2017
		shared.done = true -- 2018
		persistHistoryState(shared) -- 2019
		return ____awaiter_resolve(nil, nil) -- 2019
	end) -- 2019
end -- 2003
local CodingAgentFlow = __TS__Class() -- 2024
CodingAgentFlow.name = "CodingAgentFlow" -- 2024
__TS__ClassExtends(CodingAgentFlow, Flow) -- 2024
function CodingAgentFlow.prototype.____constructor(self) -- 2025
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 2026
	local read = __TS__New(ReadFileAction, 1, 0) -- 2027
	local search = __TS__New(SearchFilesAction, 1, 0) -- 2028
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 2029
	local list = __TS__New(ListFilesAction, 1, 0) -- 2030
	local del = __TS__New(DeleteFileAction, 1, 0) -- 2031
	local build = __TS__New(BuildAction, 1, 0) -- 2032
	local edit = __TS__New(EditFileAction, 1, 0) -- 2033
	local format = __TS__New(FormatResponseNode, 1, 0) -- 2034
	main:on("read_file", read) -- 2036
	main:on("grep_files", search) -- 2037
	main:on("search_dora_api", searchDora) -- 2038
	main:on("glob_files", list) -- 2039
	main:on("delete_file", del) -- 2040
	main:on("build", build) -- 2041
	main:on("edit_file", edit) -- 2042
	main:on("finish", format) -- 2043
	main:on("error", format) -- 2044
	read:on("main", main) -- 2046
	search:on("main", main) -- 2047
	searchDora:on("main", main) -- 2048
	list:on("main", main) -- 2049
	del:on("main", main) -- 2050
	build:on("main", main) -- 2051
	edit:on("main", main) -- 2052
	Flow.prototype.____constructor(self, main) -- 2054
end -- 2025
local function runCodingAgentAsync(options) -- 2058
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2058
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 2058
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 2058
		end -- 2058
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2062
		if not llmConfigRes.success then -- 2062
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2062
		end -- 2062
		local llmConfig = llmConfigRes.config -- 2068
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 2069
		if not taskRes.success then -- 2069
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 2069
		end -- 2069
		local compressor = __TS__New(MemoryCompressor, { -- 2076
			compressionThreshold = 0.8, -- 2077
			maxCompressionRounds = 3, -- 2078
			maxTokensPerCompression = 20000, -- 2079
			projectDir = options.workDir, -- 2080
			llmConfig = llmConfig, -- 2081
			promptPack = options.promptPack -- 2082
		}) -- 2082
		local persistedSession = compressor:getStorage():readSessionState() -- 2084
		local promptPack = compressor:getPromptPack() -- 2085
		local shared = { -- 2087
			sessionId = options.sessionId, -- 2088
			taskId = taskRes.taskId, -- 2089
			maxSteps = math.max( -- 2090
				1, -- 2090
				math.floor(options.maxSteps or 40) -- 2090
			), -- 2090
			llmMaxTry = math.max( -- 2091
				1, -- 2091
				math.floor(options.llmMaxTry or 3) -- 2091
			), -- 2091
			step = 0, -- 2092
			done = false, -- 2093
			stopToken = options.stopToken or ({stopped = false}), -- 2094
			response = "", -- 2095
			userQuery = options.prompt, -- 2096
			workingDir = options.workDir, -- 2097
			useChineseResponse = options.useChineseResponse == true, -- 2098
			decisionMode = options.decisionMode == "yaml" and "yaml" or "tool_calling", -- 2099
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 2100
			llmConfig = llmConfig, -- 2105
			onEvent = options.onEvent, -- 2106
			promptPack = promptPack, -- 2107
			history = persistedSession.history, -- 2108
			memory = {lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, compressor = compressor} -- 2110
		} -- 2110
		local ____try = __TS__AsyncAwaiter(function() -- 2110
			emitAgentEvent(shared, { -- 2117
				type = "task_started", -- 2118
				sessionId = shared.sessionId, -- 2119
				taskId = shared.taskId, -- 2120
				prompt = shared.userQuery, -- 2121
				workDir = shared.workingDir, -- 2122
				maxSteps = shared.maxSteps -- 2123
			}) -- 2123
			if shared.stopToken.stopped then -- 2123
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2126
				local result = { -- 2127
					success = false, -- 2127
					taskId = shared.taskId, -- 2127
					message = getCancelledReason(shared), -- 2127
					steps = shared.step -- 2127
				} -- 2127
				emitAgentEvent(shared, { -- 2128
					type = "task_finished", -- 2129
					sessionId = shared.sessionId, -- 2130
					taskId = shared.taskId, -- 2131
					success = false, -- 2132
					message = result.message, -- 2133
					steps = result.steps -- 2134
				}) -- 2134
				return ____awaiter_resolve(nil, result) -- 2134
			end -- 2134
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 2138
			local flow = __TS__New(CodingAgentFlow) -- 2139
			__TS__Await(flow:run(shared)) -- 2140
			if shared.stopToken.stopped then -- 2140
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2142
				local result = { -- 2143
					success = false, -- 2143
					taskId = shared.taskId, -- 2143
					message = getCancelledReason(shared), -- 2143
					steps = shared.step -- 2143
				} -- 2143
				emitAgentEvent(shared, { -- 2144
					type = "task_finished", -- 2145
					sessionId = shared.sessionId, -- 2146
					taskId = shared.taskId, -- 2147
					success = false, -- 2148
					message = result.message, -- 2149
					steps = result.steps -- 2150
				}) -- 2150
				return ____awaiter_resolve(nil, result) -- 2150
			end -- 2150
			if shared.error then -- 2150
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 2155
				local result = {success = false, taskId = shared.taskId, message = shared.response and shared.response ~= "" and shared.response or shared.error, steps = shared.step} -- 2156
				emitAgentEvent(shared, { -- 2162
					type = "task_finished", -- 2163
					sessionId = shared.sessionId, -- 2164
					taskId = shared.taskId, -- 2165
					success = false, -- 2166
					message = result.message, -- 2167
					steps = result.steps -- 2168
				}) -- 2168
				return ____awaiter_resolve(nil, result) -- 2168
			end -- 2168
			Tools.setTaskStatus(shared.taskId, "DONE") -- 2172
			local result = {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step} -- 2173
			emitAgentEvent(shared, { -- 2179
				type = "task_finished", -- 2180
				sessionId = shared.sessionId, -- 2181
				taskId = shared.taskId, -- 2182
				success = true, -- 2183
				message = result.message, -- 2184
				steps = result.steps -- 2185
			}) -- 2185
			return ____awaiter_resolve(nil, result) -- 2185
		end) -- 2185
		__TS__Await(____try.catch( -- 2116
			____try, -- 2116
			function(____, e) -- 2116
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 2189
				local result = { -- 2190
					success = false, -- 2190
					taskId = shared.taskId, -- 2190
					message = tostring(e), -- 2190
					steps = shared.step -- 2190
				} -- 2190
				emitAgentEvent(shared, { -- 2191
					type = "task_finished", -- 2192
					sessionId = shared.sessionId, -- 2193
					taskId = shared.taskId, -- 2194
					success = false, -- 2195
					message = result.message, -- 2196
					steps = result.steps -- 2197
				}) -- 2197
				return ____awaiter_resolve(nil, result) -- 2197
			end -- 2197
		)) -- 2197
	end) -- 2197
end -- 2058
function ____exports.runCodingAgent(options, callback) -- 2203
	local ____self_49 = runCodingAgentAsync(options) -- 2203
	____self_49["then"]( -- 2203
		____self_49, -- 2203
		function(____, result) return callback(result) end -- 2204
	) -- 2204
end -- 2203
return ____exports -- 2203