-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
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
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local ____exports = {} -- 1
local toJson, truncateText, utf8TakeHead, summarizeUnknown, limitReadContentForHistory, pushLimitedMatches, formatHistorySummary, persistHistoryState, HISTORY_READ_FILE_MAX_CHARS, HISTORY_READ_FILE_MAX_LINES, HISTORY_SEARCH_FILES_MAX_MATCHES, HISTORY_SEARCH_DORA_API_MAX_MATCHES, HISTORY_LIST_FILES_MAX_ENTRIES -- 1
local ____Dora = require("Dora") -- 2
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
local Tools = require("Agent.Tools") -- 6
local yaml = require("yaml") -- 7
local ____Memory = require("Agent.Memory") -- 8
local MemoryCompressor = ____Memory.MemoryCompressor -- 8
local DEFAULT_AGENT_PROMPT_PACK = ____Memory.DEFAULT_AGENT_PROMPT_PACK -- 8
function toJson(value) -- 221
	local text, err = json.encode(value) -- 222
	if text ~= nil then -- 222
		return text -- 223
	end -- 223
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 224
end -- 224
function truncateText(text, maxLen) -- 227
	if #text <= maxLen then -- 227
		return text -- 228
	end -- 228
	local nextPos = utf8.offset(text, maxLen + 1) -- 229
	if nextPos == nil then -- 229
		return text -- 230
	end -- 230
	return string.sub(text, 1, nextPos - 1) .. "..." -- 231
end -- 231
function utf8TakeHead(text, maxChars) -- 234
	if maxChars <= 0 or text == "" then -- 234
		return "" -- 235
	end -- 235
	local nextPos = utf8.offset(text, maxChars + 1) -- 236
	if nextPos == nil then -- 236
		return text -- 237
	end -- 237
	return string.sub(text, 1, nextPos - 1) -- 238
end -- 238
function summarizeUnknown(value, maxLen) -- 251
	if maxLen == nil then -- 251
		maxLen = 320 -- 251
	end -- 251
	if value == nil then -- 251
		return "undefined" -- 252
	end -- 252
	if value == nil then -- 252
		return "null" -- 253
	end -- 253
	if type(value) == "string" then -- 253
		return __TS__StringReplace( -- 255
			truncateText(value, maxLen), -- 255
			"\n", -- 255
			"\\n" -- 255
		) -- 255
	end -- 255
	if type(value) == "number" or type(value) == "boolean" then -- 255
		return tostring(value) -- 258
	end -- 258
	return __TS__StringReplace( -- 260
		truncateText( -- 260
			toJson(value), -- 260
			maxLen -- 260
		), -- 260
		"\n", -- 260
		"\\n" -- 260
	) -- 260
end -- 260
function limitReadContentForHistory(content, tool) -- 277
	local lines = __TS__StringSplit(content, "\n") -- 278
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 279
	local limitedByLines = overLineLimit and table.concat( -- 280
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 281
		"\n" -- 281
	) or content -- 281
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 281
		return content -- 284
	end -- 284
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 286
	local reasons = {} -- 289
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 289
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 290
	end -- 290
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 290
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 291
	end -- 291
	local hint = tool == "read_file" and "Use read_file_range for the exact section you need." or "Narrow the requested line range." -- 292
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 295
end -- 295
function pushLimitedMatches(lines, items, maxItems, mapper) -- 410
	local shown = math.min(#items, maxItems) -- 416
	do -- 416
		local j = 0 -- 417
		while j < shown do -- 417
			lines[#lines + 1] = mapper(items[j + 1], j) -- 418
			j = j + 1 -- 417
		end -- 417
	end -- 417
	if #items > shown then -- 417
		lines[#lines + 1] = ("  ... " .. tostring(#items - shown)) .. " more omitted" -- 421
	end -- 421
end -- 421
function formatHistorySummary(history) -- 491
	if #history == 0 then -- 491
		return "No previous actions." -- 493
	end -- 493
	local actions = history -- 495
	local lines = {} -- 496
	lines[#lines + 1] = "" -- 497
	do -- 497
		local i = 0 -- 498
		while i < #actions do -- 498
			local action = actions[i + 1] -- 499
			lines[#lines + 1] = ("Action " .. tostring(i + 1)) .. ":" -- 500
			lines[#lines + 1] = "- Tool: " .. action.tool -- 501
			lines[#lines + 1] = "- Reason: " .. action.reason -- 502
			if action.params and type(action.params) == "table" and ({next(action.params)}) ~= nil then -- 502
				lines[#lines + 1] = "- Parameters:" -- 504
				for key in pairs(action.params) do -- 505
					lines[#lines + 1] = (("  - " .. key) .. ": ") .. summarizeUnknown(action.params[key], 2000) -- 506
				end -- 506
			end -- 506
			if action.result and type(action.result) == "table" then -- 506
				local result = action.result -- 510
				local success = result.success == true -- 511
				if action.tool == "build" then -- 511
					if not success and type(result.message) == "string" then -- 511
						lines[#lines + 1] = "- Result: Failed" -- 514
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 1200) -- 515
					elseif type(result.messages) == "table" then -- 515
						local messages = result.messages -- 517
						local successCount = 0 -- 518
						local failedCount = 0 -- 519
						do -- 519
							local j = 0 -- 520
							while j < #messages do -- 520
								if messages[j + 1].success == true then -- 520
									successCount = successCount + 1 -- 521
								else -- 521
									failedCount = failedCount + 1 -- 522
								end -- 522
								j = j + 1 -- 520
							end -- 520
						end -- 520
						lines[#lines + 1] = "- Result: " .. (failedCount > 0 and "Completed With Errors" or "Success") -- 524
						lines[#lines + 1] = ((("- Build summary: " .. tostring(successCount)) .. " succeeded, ") .. tostring(failedCount)) .. " failed" -- 525
						if #messages > 0 then -- 525
							lines[#lines + 1] = "- Build details:" -- 527
							local shown = math.min(#messages, 12) -- 528
							do -- 528
								local j = 0 -- 529
								while j < shown do -- 529
									local item = messages[j + 1] -- 530
									local file = type(item.file) == "string" and item.file or "(unknown)" -- 531
									if item.success == true then -- 531
										lines[#lines + 1] = (("  " .. tostring(j + 1)) .. ". OK ") .. file -- 533
									else -- 533
										local message = type(item.message) == "string" and truncateText(item.message, 400) or "build failed" -- 535
										lines[#lines + 1] = (((("  " .. tostring(j + 1)) .. ". FAIL ") .. file) .. ": ") .. message -- 538
									end -- 538
									j = j + 1 -- 529
								end -- 529
							end -- 529
							if #messages > shown then -- 529
								lines[#lines + 1] = ("  ... " .. tostring(#messages - shown)) .. " more omitted" -- 542
							end -- 542
						end -- 542
					else -- 542
						lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 546
					end -- 546
				elseif action.tool == "read_file" or action.tool == "read_file_range" then -- 546
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 549
					if success and type(result.content) == "string" then -- 549
						lines[#lines + 1] = "- Content:" -- 551
						lines[#lines + 1] = limitReadContentForHistory(result.content, action.tool) -- 552
						if result.startLine ~= nil or result.endLine ~= nil or result.totalLines ~= nil then -- 552
							lines[#lines + 1] = (((("- Range: " .. (result.startLine ~= nil and tostring(result.startLine) or "?")) .. "-") .. (result.endLine ~= nil and tostring(result.endLine) or "?")) .. " / total ") .. (result.totalLines ~= nil and tostring(result.totalLines) or "?") -- 554
						end -- 554
					elseif not success and type(result.message) == "string" then -- 554
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 600) -- 559
					end -- 559
				elseif action.tool == "grep_files" then -- 559
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 562
					if success and type(result.results) == "table" then -- 562
						local matches = result.results -- 564
						local totalMatches = type(result.totalResults) == "number" and result.totalResults or #matches -- 565
						lines[#lines + 1] = "- Matches: " .. tostring(totalMatches) -- 568
						lines[#lines + 1] = "- Next: Immediately read the relevant file from the potentially related results to gather more information." -- 569
						if type(result.offset) == "number" and type(result.limit) == "number" then -- 569
							lines[#lines + 1] = (("- Page: offset=" .. tostring(result.offset)) .. " limit=") .. tostring(result.limit) -- 571
						end -- 571
						if result.hasMore == true and result.nextOffset ~= nil then -- 571
							lines[#lines + 1] = "- More: continue with offset=" .. tostring(result.nextOffset) -- 574
						end -- 574
						if type(result.groupedResults) == "table" then -- 574
							local groups = result.groupedResults -- 577
							lines[#lines + 1] = "- Groups:" -- 578
							pushLimitedMatches( -- 579
								lines, -- 579
								groups, -- 579
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 579
								function(g, index) -- 579
									local file = type(g.file) == "string" and g.file or "" -- 580
									local total = g.totalMatches ~= nil and tostring(g.totalMatches) or "?" -- 581
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. ": ") .. total) .. " matches" -- 582
								end -- 579
							) -- 579
						else -- 579
							pushLimitedMatches( -- 585
								lines, -- 585
								matches, -- 585
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 585
								function(m, index) -- 585
									local file = type(m.file) == "string" and m.file or "" -- 586
									local line = m.line ~= nil and tostring(m.line) or "" -- 587
									local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 588
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 589
								end -- 585
							) -- 585
						end -- 585
					end -- 585
				elseif action.tool == "search_dora_api" then -- 585
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 594
					if success and type(result.results) == "table" then -- 594
						local hits = result.results -- 596
						local totalHits = type(result.totalResults) == "number" and result.totalResults or #hits -- 597
						lines[#lines + 1] = "- Matches: " .. tostring(totalHits) -- 600
						pushLimitedMatches( -- 601
							lines, -- 601
							hits, -- 601
							HISTORY_SEARCH_DORA_API_MAX_MATCHES, -- 601
							function(m, index) -- 601
								local file = type(m.file) == "string" and m.file or "" -- 602
								local line = m.line ~= nil and tostring(m.line) or "" -- 603
								local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 604
								return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 605
							end -- 601
						) -- 601
					end -- 601
				elseif action.tool == "edit_file" then -- 601
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 609
					if success then -- 609
						if result.mode ~= nil then -- 609
							lines[#lines + 1] = "- Mode: " .. tostring(result.mode) -- 612
						end -- 612
						if result.replaced ~= nil then -- 612
							lines[#lines + 1] = "- Replaced: " .. tostring(result.replaced) -- 615
						end -- 615
					end -- 615
				elseif action.tool == "glob_files" then -- 615
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 619
					if success and type(result.files) == "table" then -- 619
						local files = result.files -- 621
						local totalEntries = type(result.totalEntries) == "number" and result.totalEntries or #files -- 622
						lines[#lines + 1] = "- Entries: " .. tostring(totalEntries) -- 625
						lines[#lines + 1] = "- Next: Immediately read the relevant file snippets from the potentially related results to gather more information." -- 626
						lines[#lines + 1] = "- Directory structure:" -- 627
						if #files > 0 then -- 627
							local shown = math.min(#files, HISTORY_LIST_FILES_MAX_ENTRIES) -- 629
							do -- 629
								local j = 0 -- 630
								while j < shown do -- 630
									lines[#lines + 1] = "  " .. files[j + 1] -- 631
									j = j + 1 -- 630
								end -- 630
							end -- 630
							if #files > shown then -- 630
								lines[#lines + 1] = ("  ... " .. tostring(#files - shown)) .. " more omitted" -- 634
							end -- 634
						else -- 634
							lines[#lines + 1] = "  (Empty or inaccessible directory)" -- 637
						end -- 637
					end -- 637
				else -- 637
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 641
					lines[#lines + 1] = "- Detail: " .. truncateText( -- 642
						toJson(result), -- 642
						4000 -- 642
					) -- 642
				end -- 642
			elseif action.result ~= nil then -- 642
				lines[#lines + 1] = "- Result: " .. summarizeUnknown(action.result, 3000) -- 645
			else -- 645
				lines[#lines + 1] = "- Result: pending" -- 647
			end -- 647
			if i < #actions - 1 then -- 647
				lines[#lines + 1] = "" -- 649
			end -- 649
			i = i + 1 -- 498
		end -- 498
	end -- 498
	return table.concat(lines, "\n") -- 651
end -- 651
function persistHistoryState(shared) -- 654
	shared.memory.compressor:getStorage():writeSessionState(shared.history, shared.memory.lastConsolidatedIndex) -- 655
end -- 655
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
local function emitAgentEvent(shared, event) -- 172
	if shared.onEvent then -- 172
		shared:onEvent(event) -- 174
	end -- 174
end -- 172
local function getCancelledReason(shared) -- 178
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 178
		return shared.stopToken.reason -- 179
	end -- 179
	return shared.useChineseResponse and "已取消" or "cancelled" -- 180
end -- 178
local function getMaxStepsReachedReason(shared) -- 183
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 184
end -- 183
local function getFailureSummaryFallback(shared, ____error) -- 189
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 190
end -- 189
local function areDecisionParamsEqual(a, b) -- 195
	if a == b then -- 195
		return true -- 196
	end -- 196
	if a == nil or b == nil or a == nil or b == nil then -- 196
		return a == b -- 197
	end -- 197
	local typeA = type(a) -- 198
	local typeB = type(b) -- 199
	if typeA ~= typeB then -- 199
		return false -- 200
	end -- 200
	if typeA == "table" then -- 200
		local tableA = a -- 202
		local tableB = b -- 203
		for key in pairs(tableA) do -- 204
			if not areDecisionParamsEqual(tableA[key], tableB[key]) then -- 204
				return false -- 205
			end -- 205
		end -- 205
		for key in pairs(tableB) do -- 207
			if tableA[key] == nil then -- 207
				return false -- 208
			end -- 208
		end -- 208
		return true -- 210
	end -- 210
	return tostring(a) == tostring(b) -- 212
end -- 195
local function isDuplicateDecision(shared, tool, params) -- 215
	local previous = shared.lastDecision -- 216
	if not previous then -- 216
		return false -- 217
	end -- 217
	return previous.tool == tool and areDecisionParamsEqual(previous.params, params) -- 218
end -- 215
local function utf8TakeTail(text, maxChars) -- 241
	if maxChars <= 0 or text == "" then -- 241
		return "" -- 242
	end -- 242
	local charLen = utf8.len(text) -- 243
	if charLen == false or charLen <= maxChars then -- 243
		return text -- 244
	end -- 244
	local startChar = math.max(1, charLen - maxChars + 1) -- 245
	local startPos = utf8.offset(text, startChar) -- 246
	if startPos == nil then -- 246
		return text -- 247
	end -- 247
	return string.sub(text, startPos) -- 248
end -- 241
local function getReplyLanguageDirective(shared) -- 263
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 264
end -- 263
local function replacePromptVars(template, vars) -- 269
	local output = template -- 270
	for key in pairs(vars) do -- 271
		output = table.concat( -- 272
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 272
			vars[key] or "" or "," -- 272
		) -- 272
	end -- 272
	return output -- 274
end -- 269
local function summarizeEditTextParamForHistory(value, key) -- 298
	if type(value) ~= "string" then -- 298
		return nil -- 299
	end -- 299
	local text = value -- 300
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 301
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 302
end -- 298
local function sanitizeReadResultForHistory(tool, result) -- 310
	if tool ~= "read_file" and tool ~= "read_file_range" or result.success ~= true or type(result.content) ~= "string" then -- 310
		return result -- 312
	end -- 312
	local clone = {} -- 314
	for key in pairs(result) do -- 315
		clone[key] = result[key] -- 316
	end -- 316
	clone.content = limitReadContentForHistory(result.content, tool) -- 318
	return clone -- 319
end -- 310
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 322
	local shown = math.min(#items, maxItems) -- 326
	local out = {} -- 327
	do -- 327
		local i = 0 -- 328
		while i < shown do -- 328
			local row = items[i + 1] -- 329
			out[#out + 1] = { -- 330
				file = row.file, -- 331
				line = row.line, -- 332
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 333
			} -- 333
			i = i + 1 -- 328
		end -- 328
	end -- 328
	return out -- 338
end -- 322
local function sanitizeSearchResultForHistory(tool, result) -- 341
	if result.success ~= true or type(result.results) ~= "table" then -- 341
		return result -- 345
	end -- 345
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 345
		return result -- 346
	end -- 346
	local clone = {} -- 347
	for key in pairs(result) do -- 348
		clone[key] = result[key] -- 349
	end -- 349
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 351
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 352
	if tool == "grep_files" and type(result.groupedResults) == "table" then -- 352
		local grouped = result.groupedResults -- 357
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 358
		local sanitizedGroups = {} -- 359
		do -- 359
			local i = 0 -- 360
			while i < shown do -- 360
				local row = grouped[i + 1] -- 361
				sanitizedGroups[#sanitizedGroups + 1] = { -- 362
					file = row.file, -- 363
					totalMatches = row.totalMatches, -- 364
					matches = type(row.matches) == "table" and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 365
				} -- 365
				i = i + 1 -- 360
			end -- 360
		end -- 360
		clone.groupedResults = sanitizedGroups -- 370
	end -- 370
	return clone -- 372
end -- 341
local function sanitizeListFilesResultForHistory(result) -- 375
	if result.success ~= true or type(result.files) ~= "table" then -- 375
		return result -- 376
	end -- 376
	local clone = {} -- 377
	for key in pairs(result) do -- 378
		clone[key] = result[key] -- 379
	end -- 379
	local files = result.files -- 381
	clone.files = __TS__ArraySlice(files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 382
	return clone -- 383
end -- 375
local function sanitizeActionParamsForHistory(tool, params) -- 386
	if tool ~= "edit_file" then -- 386
		return params -- 387
	end -- 387
	local clone = {} -- 388
	for key in pairs(params) do -- 389
		if key == "old_str" then -- 389
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 391
		elseif key == "new_str" then -- 391
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 393
		else -- 393
			clone[key] = params[key] -- 395
		end -- 395
	end -- 395
	return clone -- 398
end -- 386
local function trimPromptContext(text, maxChars, label) -- 401
	if #text <= maxChars then -- 401
		return text -- 402
	end -- 402
	local keepHead = math.max( -- 403
		0, -- 403
		math.floor(maxChars * 0.35) -- 403
	) -- 403
	local keepTail = math.max(0, maxChars - keepHead) -- 404
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 405
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 406
	return (((((("[history summary truncated for " .. label) .. "; showing head and tail within ") .. tostring(maxChars)) .. " chars]\n") .. head) .. "\n...\n") .. tail -- 407
end -- 401
local function formatHistorySummaryForDecision(history) -- 425
	return trimPromptContext( -- 426
		formatHistorySummary(history), -- 426
		DECISION_HISTORY_MAX_CHARS, -- 426
		"decision" -- 426
	) -- 426
end -- 425
local function getDecisionSystemPrompt(shared) -- 429
	return shared and shared.promptPack.agentIdentityPrompt or DEFAULT_AGENT_PROMPT_PACK.agentIdentityPrompt -- 430
end -- 429
local function getDecisionToolDefinitions(shared) -- 433
	return replacePromptVars( -- 434
		shared and shared.promptPack.toolDefinitionsShort or DEFAULT_AGENT_PROMPT_PACK.toolDefinitionsShort, -- 435
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 436
	) -- 436
end -- 433
local function maybeCompressHistory(shared) -- 440
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 440
		local ____shared_4 = shared -- 441
		local memory = ____shared_4.memory -- 441
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 442
		local changed = false -- 443
		do -- 443
			local round = 0 -- 444
			while round < maxRounds do -- 444
				if not memory.compressor:shouldCompress( -- 444
					shared.userQuery, -- 446
					shared.history, -- 447
					memory.lastConsolidatedIndex, -- 448
					getDecisionSystemPrompt(shared), -- 449
					getDecisionToolDefinitions(shared), -- 450
					formatHistorySummary -- 451
				) then -- 451
					return ____awaiter_resolve(nil) -- 451
				end -- 451
				local result = __TS__Await(memory.compressor:compress( -- 455
					shared.userQuery, -- 456
					shared.history, -- 457
					memory.lastConsolidatedIndex, -- 458
					shared.llmOptions, -- 459
					formatHistorySummary, -- 460
					shared.llmMaxTry, -- 461
					shared.decisionMode -- 462
				)) -- 462
				if not (result and result.success and result.compressedCount > 0) then -- 462
					if changed then -- 462
						persistHistoryState(shared) -- 466
					end -- 466
					return ____awaiter_resolve(nil) -- 466
				end -- 466
				memory.lastConsolidatedIndex = memory.lastConsolidatedIndex + result.compressedCount -- 470
				changed = true -- 471
				Log( -- 472
					"Info", -- 472
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " history records (round ") .. tostring(round + 1)) .. ")" -- 472
				) -- 472
				round = round + 1 -- 444
			end -- 444
		end -- 444
		if changed then -- 444
			persistHistoryState(shared) -- 475
		end -- 475
	end) -- 475
end -- 440
local function isKnownToolName(name) -- 479
	return name == "read_file" or name == "read_file_range" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 480
end -- 479
local function extractYAMLFromText(text) -- 661
	local source = __TS__StringTrim(text) -- 662
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 663
	if yamlFencePos >= 0 then -- 663
		local from = yamlFencePos + #"```yaml" -- 665
		local ____end = (string.find( -- 666
			source, -- 666
			"```", -- 666
			math.max(from + 1, 1), -- 666
			true -- 666
		) or 0) - 1 -- 666
		if ____end > from then -- 666
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 667
		end -- 667
	end -- 667
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 669
	if ymlFencePos >= 0 then -- 669
		local from = ymlFencePos + #"```yml" -- 671
		local ____end = (string.find( -- 672
			source, -- 672
			"```", -- 672
			math.max(from + 1, 1), -- 672
			true -- 672
		) or 0) - 1 -- 672
		if ____end > from then -- 672
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 673
		end -- 673
	end -- 673
	local fencePos = (string.find(source, "```", nil, true) or 0) - 1 -- 675
	if fencePos >= 0 then -- 675
		local firstLineEnd = (string.find( -- 677
			source, -- 677
			"\n", -- 677
			math.max(fencePos + 1, 1), -- 677
			true -- 677
		) or 0) - 1 -- 677
		local ____end = (string.find( -- 678
			source, -- 678
			"```", -- 678
			math.max((firstLineEnd >= 0 and firstLineEnd + 1 or fencePos + 3) + 1, 1), -- 678
			true -- 678
		) or 0) - 1 -- 678
		if firstLineEnd >= 0 and ____end > firstLineEnd then -- 678
			return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, ____end)) -- 680
		end -- 680
	end -- 680
	return source -- 683
end -- 661
local function parseYAMLObjectFromText(text) -- 686
	local yamlText = extractYAMLFromText(text) -- 687
	local obj, err = yaml.parse(yamlText) -- 688
	if obj == nil or type(obj) ~= "table" then -- 688
		return { -- 690
			success = false, -- 690
			message = "invalid yaml: " .. tostring(err) -- 690
		} -- 690
	end -- 690
	return {success = true, obj = obj} -- 692
end -- 686
local function llm(shared, messages) -- 704
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 704
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 705
		if res.success then -- 705
			local ____opt_9 = res.response.choices -- 705
			local ____opt_7 = ____opt_9 and ____opt_9[1] -- 705
			local ____opt_5 = ____opt_7 and ____opt_7.message -- 705
			local text = ____opt_5 and ____opt_5.content -- 707
			if text then -- 707
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 707
			else -- 707
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 707
			end -- 707
		else -- 707
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 707
		end -- 707
	end) -- 707
end -- 704
local function llmStream(shared, messages) -- 718
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 718
		local text = "" -- 719
		local cancelledReason -- 720
		local done = false -- 721
		if shared.stopToken.stopped then -- 721
			return ____awaiter_resolve( -- 721
				nil, -- 721
				{ -- 724
					success = false, -- 724
					message = getCancelledReason(shared), -- 724
					text = text -- 724
				} -- 724
			) -- 724
		end -- 724
		done = false -- 726
		cancelledReason = nil -- 727
		text = "" -- 728
		callLLMStream( -- 729
			messages, -- 730
			shared.llmOptions, -- 731
			{ -- 732
				id = nil, -- 733
				stopToken = shared.stopToken, -- 734
				onData = function(data) -- 735
					if shared.stopToken.stopped then -- 735
						return true -- 736
					end -- 736
					local choice = data.choices and data.choices[1] -- 737
					local delta = choice and choice.delta -- 738
					if delta and type(delta.content) == "string" then -- 738
						local content = delta.content -- 740
						text = text .. content -- 741
						emitAgentEvent(shared, { -- 742
							type = "summary_stream", -- 743
							sessionId = shared.sessionId, -- 744
							taskId = shared.taskId, -- 745
							textDelta = content, -- 746
							fullText = text -- 747
						}) -- 747
						local res = json.encode({name = "LLMStream", content = content}) -- 749
						if res ~= nil then -- 749
							emit("AppWS", "Send", res) -- 751
						end -- 751
					end -- 751
					return false -- 754
				end, -- 735
				onCancel = function(reason) -- 756
					cancelledReason = reason -- 757
					done = true -- 758
				end, -- 756
				onDone = function() -- 760
					done = true -- 761
				end -- 760
			}, -- 760
			shared.llmConfig -- 764
		) -- 764
		__TS__Await(__TS__New( -- 767
			__TS__Promise, -- 767
			function(____, resolve) -- 767
				Director.systemScheduler:schedule(once(function() -- 768
					wait(function() return done or shared.stopToken.stopped end) -- 769
					resolve(nil) -- 770
				end)) -- 768
			end -- 767
		)) -- 767
		if shared.stopToken.stopped then -- 767
			cancelledReason = getCancelledReason(shared) -- 774
		end -- 774
		if not cancelledReason and text == "" then -- 774
			cancelledReason = "empty LLM output" -- 778
		end -- 778
		if cancelledReason then -- 778
			return ____awaiter_resolve(nil, {success = false, message = cancelledReason, text = text}) -- 778
		end -- 778
		return ____awaiter_resolve(nil, {success = true, text = text}) -- 778
	end) -- 778
end -- 718
local function parseDecisionObject(rawObj) -- 785
	if type(rawObj.tool) ~= "string" then -- 785
		return {success = false, message = "missing tool"} -- 786
	end -- 786
	local tool = rawObj.tool -- 787
	if not isKnownToolName(tool) then -- 787
		return {success = false, message = "unknown tool: " .. tool} -- 789
	end -- 789
	local reason = type(rawObj.reason) == "string" and rawObj.reason or "" -- 791
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 792
	return {success = true, tool = tool, reason = reason, params = params} -- 793
end -- 785
local function getDecisionPath(params) -- 796
	if type(params.path) == "string" then -- 796
		return __TS__StringTrim(params.path) -- 797
	end -- 797
	if type(params.target_file) == "string" then -- 797
		return __TS__StringTrim(params.target_file) -- 798
	end -- 798
	return "" -- 799
end -- 796
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 802
	local num = __TS__Number(value) -- 803
	if not __TS__NumberIsFinite(num) then -- 803
		num = fallback -- 804
	end -- 804
	num = math.floor(num) -- 805
	if num < minValue then -- 805
		num = minValue -- 806
	end -- 806
	if maxValue ~= nil and num > maxValue then -- 806
		num = maxValue -- 807
	end -- 807
	return num -- 808
end -- 802
local function validateDecision(tool, params) -- 811
	if tool == "finish" then -- 811
		return {success = true, params = params} -- 815
	end -- 815
	if tool == "read_file" then -- 815
		local path = getDecisionPath(params) -- 818
		if path == "" then -- 818
			return {success = false, message = "read_file requires path"} -- 819
		end -- 819
		params.path = path -- 820
		params.offset = clampIntegerParam(params.offset, 1, 1) -- 821
		params.limit = clampIntegerParam(params.limit, READ_FILE_DEFAULT_LIMIT, 1) -- 822
		return {success = true, params = params} -- 823
	end -- 823
	if tool == "read_file_range" then -- 823
		local path = getDecisionPath(params) -- 827
		if path == "" then -- 827
			return {success = false, message = "read_file_range requires path"} -- 828
		end -- 828
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 829
		local ____params_endLine_11 = params.endLine -- 830
		if ____params_endLine_11 == nil then -- 830
			____params_endLine_11 = startLine -- 830
		end -- 830
		local endLineRaw = ____params_endLine_11 -- 830
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 831
		params.path = path -- 832
		params.startLine = startLine -- 833
		params.endLine = endLine -- 834
		return {success = true, params = params} -- 835
	end -- 835
	if tool == "edit_file" then -- 835
		local path = getDecisionPath(params) -- 839
		if path == "" then -- 839
			return {success = false, message = "edit_file requires path"} -- 840
		end -- 840
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 841
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 842
		if oldStr == newStr then -- 842
			return {success = false, message = "edit_file old_str and new_str must be different"} -- 844
		end -- 844
		params.path = path -- 846
		params.old_str = oldStr -- 847
		params.new_str = newStr -- 848
		return {success = true, params = params} -- 849
	end -- 849
	if tool == "delete_file" then -- 849
		local targetFile = getDecisionPath(params) -- 853
		if targetFile == "" then -- 853
			return {success = false, message = "delete_file requires target_file"} -- 854
		end -- 854
		params.target_file = targetFile -- 855
		return {success = true, params = params} -- 856
	end -- 856
	if tool == "grep_files" then -- 856
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 860
		if pattern == "" then -- 860
			return {success = false, message = "grep_files requires pattern"} -- 861
		end -- 861
		params.pattern = pattern -- 862
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 863
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 864
		return {success = true, params = params} -- 865
	end -- 865
	if tool == "search_dora_api" then -- 865
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 869
		if pattern == "" then -- 869
			return {success = false, message = "search_dora_api requires pattern"} -- 870
		end -- 870
		params.pattern = pattern -- 871
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 872
		return {success = true, params = params} -- 873
	end -- 873
	if tool == "glob_files" then -- 873
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 877
		return {success = true, params = params} -- 878
	end -- 878
	if tool == "build" then -- 878
		local path = getDecisionPath(params) -- 882
		if path ~= "" then -- 882
			params.path = path -- 884
		end -- 884
		return {success = true, params = params} -- 886
	end -- 886
	return {success = true, params = params} -- 889
end -- 811
local function buildDecisionToolSchema() -- 892
	return {{type = "function", ["function"] = {name = "next_step", description = "Choose the next coding action for the agent.", parameters = {type = "object", properties = {tool = {type = "string", enum = { -- 893
		"read_file", -- 904
		"read_file_range", -- 905
		"edit_file", -- 906
		"delete_file", -- 907
		"grep_files", -- 908
		"search_dora_api", -- 909
		"glob_files", -- 910
		"build", -- 911
		"finish" -- 912
	}}, reason = {type = "string", description = "Explain why this is the next best action."}, params = {type = "object", description = "Shallow parameter object for the selected tool.", properties = { -- 912
		path = {type = "string"}, -- 923
		target_file = {type = "string"}, -- 924
		old_str = {type = "string"}, -- 925
		new_str = {type = "string"}, -- 926
		pattern = {type = "string"}, -- 927
		globs = {type = "array", items = {type = "string"}}, -- 928
		useRegex = {type = "boolean"}, -- 932
		caseSensitive = {type = "boolean"}, -- 933
		offset = {type = "number"}, -- 934
		groupByFile = {type = "boolean"}, -- 935
		docSource = {type = "string", enum = {"api", "tutorial"}}, -- 936
		programmingLanguage = {type = "string", enum = { -- 940
			"ts", -- 942
			"tsx", -- 942
			"lua", -- 942
			"yue", -- 942
			"teal", -- 942
			"tl", -- 942
			"wa" -- 942
		}}, -- 942
		limit = {type = "number"}, -- 944
		startLine = {type = "number"}, -- 945
		endLine = {type = "number"}, -- 946
		maxEntries = {type = "number"} -- 947
	}}}, required = {"tool", "reason", "params"}}}}} -- 947
end -- 892
local function buildDecisionPrompt(shared, userQuery, historyText, memoryContext) -- 957
	return (((((((((((((shared.promptPack.agentIdentityPrompt .. "\n") .. shared.promptPack.decisionIntroPrompt) .. "\n\n") .. memoryContext) .. "\n\nUser request: ") .. userQuery) .. "\n\nHere are the actions you performed:\n") .. historyText) .. "\n\n") .. replacePromptVars( -- 958
		shared.promptPack.toolDefinitionsDetailed, -- 968
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 968
	)) .. "\n\n") .. shared.promptPack.decisionRulesPrompt) .. "\n") .. getReplyLanguageDirective(shared) -- 968
end -- 957
local function replaceAllAndCount(text, oldStr, newStr) -- 976
	if oldStr == "" then -- 976
		return {content = text, replaced = 0} -- 977
	end -- 977
	local count = 0 -- 978
	local from = 0 -- 979
	while true do -- 979
		local idx = (string.find( -- 981
			text, -- 981
			oldStr, -- 981
			math.max(from + 1, 1), -- 981
			true -- 981
		) or 0) - 1 -- 981
		if idx < 0 then -- 981
			break -- 982
		end -- 982
		count = count + 1 -- 983
		from = idx + #oldStr -- 984
	end -- 984
	if count == 0 then -- 984
		return {content = text, replaced = 0} -- 986
	end -- 986
	return { -- 987
		content = table.concat( -- 988
			__TS__StringSplit(text, oldStr), -- 988
			newStr or "," -- 988
		), -- 988
		replaced = count -- 989
	} -- 989
end -- 976
local MainDecisionAgent = __TS__Class() -- 993
MainDecisionAgent.name = "MainDecisionAgent" -- 993
__TS__ClassExtends(MainDecisionAgent, Node) -- 993
function MainDecisionAgent.prototype.prep(self, shared) -- 994
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 994
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 994
			return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 994
		end -- 994
		__TS__Await(maybeCompressHistory(shared)) -- 1003
		return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 1003
	end) -- 1003
end -- 994
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, prompt, lastError, attempt, lastRaw) -- 1012
	if attempt == nil then -- 1012
		attempt = 1 -- 1016
	end -- 1016
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1016
		if shared.stopToken.stopped then -- 1016
			return ____awaiter_resolve( -- 1016
				nil, -- 1016
				{ -- 1020
					success = false, -- 1020
					message = getCancelledReason(shared) -- 1020
				} -- 1020
			) -- 1020
		end -- 1020
		Log( -- 1022
			"Info", -- 1022
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1022
		) -- 1022
		local tools = buildDecisionToolSchema() -- 1023
		local messages = { -- 1024
			{ -- 1025
				role = "system", -- 1026
				content = table.concat( -- 1027
					{ -- 1027
						shared.promptPack.toolCallingSystemPrompt, -- 1028
						shared.promptPack.toolCallingNoPlainTextPrompt, -- 1029
						getReplyLanguageDirective(shared) -- 1030
					}, -- 1030
					"\n" -- 1031
				) -- 1031
			}, -- 1031
			{ -- 1033
				role = "user", -- 1034
				content = lastError and (((((prompt .. "\n\n") .. replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError})) .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") or prompt -- 1035
			} -- 1035
		} -- 1035
		local res = __TS__Await(callLLM( -- 1044
			messages, -- 1044
			__TS__ObjectAssign({}, shared.llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "next_step"}}}), -- 1044
			shared.stopToken, -- 1048
			shared.llmConfig -- 1048
		)) -- 1048
		if shared.stopToken.stopped then -- 1048
			return ____awaiter_resolve( -- 1048
				nil, -- 1048
				{ -- 1050
					success = false, -- 1050
					message = getCancelledReason(shared) -- 1050
				} -- 1050
			) -- 1050
		end -- 1050
		if not res.success then -- 1050
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1053
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1053
		end -- 1053
		local choice = res.response.choices and res.response.choices[1] -- 1056
		local message = choice and choice.message -- 1057
		local toolCalls = message and message.tool_calls -- 1058
		local toolCall = toolCalls and toolCalls[1] -- 1059
		local fn = toolCall and toolCall["function"] -- 1060
		local messageContent = message and type(message.content) == "string" and message.content or nil -- 1061
		Log( -- 1062
			"Info", -- 1062
			(((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0) -- 1062
		) -- 1062
		if not fn or fn.name ~= "next_step" then -- 1062
			Log("Error", "[CodingAgent] missing next_step tool call") -- 1064
			return ____awaiter_resolve(nil, {success = false, message = "missing next_step tool call", raw = messageContent}) -- 1064
		end -- 1064
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1071
		Log( -- 1072
			"Info", -- 1072
			(("[CodingAgent] tool-calling function=" .. fn.name) .. " args_len=") .. tostring(#argsText) -- 1072
		) -- 1072
		if __TS__StringTrim(argsText) == "" then -- 1072
			Log("Error", "[CodingAgent] empty next_step tool arguments") -- 1074
			return ____awaiter_resolve(nil, {success = false, message = "empty next_step tool arguments"}) -- 1074
		end -- 1074
		local rawObj, err = json.decode(argsText) -- 1077
		if err ~= nil or rawObj == nil or type(rawObj) ~= "table" then -- 1077
			Log( -- 1079
				"Error", -- 1079
				"[CodingAgent] invalid next_step tool arguments JSON: " .. tostring(err) -- 1079
			) -- 1079
			return ____awaiter_resolve( -- 1079
				nil, -- 1079
				{ -- 1080
					success = false, -- 1081
					message = "invalid next_step tool arguments: " .. tostring(err), -- 1082
					raw = argsText -- 1083
				} -- 1083
			) -- 1083
		end -- 1083
		local decision = parseDecisionObject(rawObj) -- 1086
		if not decision.success then -- 1086
			Log("Error", "[CodingAgent] invalid next_step tool arguments schema: " .. decision.message) -- 1088
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1088
		end -- 1088
		local validation = validateDecision(decision.tool, decision.params) -- 1095
		if not validation.success then -- 1095
			Log("Error", "[CodingAgent] invalid next_step tool arguments values: " .. validation.message) -- 1097
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1097
		end -- 1097
		decision.params = validation.params -- 1104
		Log( -- 1105
			"Info", -- 1105
			(("[CodingAgent] tool-calling selected tool=" .. decision.tool) .. " reason_len=") .. tostring(#decision.reason) -- 1105
		) -- 1105
		return ____awaiter_resolve(nil, decision) -- 1105
	end) -- 1105
end -- 1012
function MainDecisionAgent.prototype.exec(self, input) -- 1109
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1109
		local shared = input.shared -- 1110
		if shared.stopToken.stopped then -- 1110
			return ____awaiter_resolve( -- 1110
				nil, -- 1110
				{ -- 1112
					success = false, -- 1112
					message = getCancelledReason(shared) -- 1112
				} -- 1112
			) -- 1112
		end -- 1112
		if shared.step >= shared.maxSteps then -- 1112
			Log( -- 1115
				"Warn", -- 1115
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 1115
			) -- 1115
			return ____awaiter_resolve( -- 1115
				nil, -- 1115
				{ -- 1116
					success = false, -- 1116
					message = getMaxStepsReachedReason(shared) -- 1116
				} -- 1116
			) -- 1116
		end -- 1116
		local memory = shared.memory -- 1116
		local memoryContext = memory.compressor:getStorage():getMemoryContext() -- 1121
		local uncompressedHistory = __TS__ArraySlice(input.history, memory.lastConsolidatedIndex) -- 1126
		local historyText = formatHistorySummaryForDecision(uncompressedHistory) -- 1127
		local prompt = buildDecisionPrompt(input.shared, input.userQuery, historyText, memoryContext) -- 1129
		if shared.decisionMode == "tool_calling" then -- 1129
			Log( -- 1132
				"Info", -- 1132
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " history=") .. tostring(#uncompressedHistory) -- 1132
			) -- 1132
			local lastError = "tool calling validation failed" -- 1133
			local lastRaw = "" -- 1134
			do -- 1134
				local attempt = 0 -- 1135
				while attempt < shared.llmMaxTry do -- 1135
					do -- 1135
						Log( -- 1136
							"Info", -- 1136
							"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1136
						) -- 1136
						local decision = __TS__Await(self:callDecisionByToolCalling( -- 1137
							shared, -- 1138
							prompt, -- 1139
							attempt > 0 and lastError or nil, -- 1140
							attempt + 1, -- 1141
							lastRaw -- 1142
						)) -- 1142
						if shared.stopToken.stopped then -- 1142
							return ____awaiter_resolve( -- 1142
								nil, -- 1142
								{ -- 1145
									success = false, -- 1145
									message = getCancelledReason(shared) -- 1145
								} -- 1145
							) -- 1145
						end -- 1145
						if decision.success then -- 1145
							if isDuplicateDecision(shared, decision.tool, decision.params) then -- 1145
								lastError = ("duplicate decision rejected: " .. decision.tool) .. " with identical params as previous step" -- 1149
								lastRaw = truncateText( -- 1150
									toJson({tool = decision.tool, params = decision.params}), -- 1150
									400 -- 1150
								) -- 1150
								Log("Warn", "[CodingAgent] duplicate decision rejected tool=" .. decision.tool) -- 1151
								goto __continue223 -- 1152
							end -- 1152
							return ____awaiter_resolve(nil, decision) -- 1152
						end -- 1152
						lastError = decision.message -- 1156
						lastRaw = decision.raw or "" -- 1157
						Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1158
					end -- 1158
					::__continue223:: -- 1158
					attempt = attempt + 1 -- 1135
				end -- 1135
			end -- 1135
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1160
			return ____awaiter_resolve( -- 1160
				nil, -- 1160
				{ -- 1161
					success = false, -- 1161
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1161
				} -- 1161
			) -- 1161
		end -- 1161
		local yamlPrompt = ((prompt .. "\n\n") .. shared.promptPack.yamlDecisionFormatPrompt) .. "\n- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.\n- Keep params shallow and valid for the selected tool.\n- Use tabs for all indentation, never spaces.\nIf no more actions are needed, use tool: finish." -- 1164
		local lastError = "yaml validation failed" -- 1172
		local lastRaw = "" -- 1173
		do -- 1173
			local attempt = 0 -- 1174
			while attempt < shared.llmMaxTry do -- 1174
				do -- 1174
					local feedback = attempt > 0 and (((("\n\nPrevious response was invalid (" .. lastError) .. "). Retry attempt: ") .. tostring(attempt + 1)) .. ". Return exactly one valid YAML object only and keep YAML indentation strictly consistent. The next reply must differ from the rejected one.") .. (lastRaw ~= "" and "\nLast rejected output summary: " .. truncateText(lastRaw, 300) or "") or "" -- 1175
					local messages = {{role = "user", content = yamlPrompt .. feedback}} -- 1178
					local llmRes = __TS__Await(llm(shared, messages)) -- 1179
					if shared.stopToken.stopped then -- 1179
						return ____awaiter_resolve( -- 1179
							nil, -- 1179
							{ -- 1181
								success = false, -- 1181
								message = getCancelledReason(shared) -- 1181
							} -- 1181
						) -- 1181
					end -- 1181
					if not llmRes.success then -- 1181
						lastError = llmRes.message -- 1184
						goto __continue228 -- 1185
					end -- 1185
					lastRaw = llmRes.text -- 1187
					local parsed = parseYAMLObjectFromText(llmRes.text) -- 1188
					if not parsed.success then -- 1188
						lastError = parsed.message -- 1190
						goto __continue228 -- 1191
					end -- 1191
					local decision = parseDecisionObject(parsed.obj) -- 1193
					if not decision.success then -- 1193
						lastError = decision.message -- 1195
						goto __continue228 -- 1196
					end -- 1196
					local validation = validateDecision(decision.tool, decision.params) -- 1198
					if not validation.success then -- 1198
						lastError = validation.message -- 1200
						goto __continue228 -- 1201
					end -- 1201
					decision.params = validation.params -- 1203
					if isDuplicateDecision(shared, decision.tool, decision.params) then -- 1203
						lastError = ("duplicate decision rejected: " .. decision.tool) .. " with identical params as previous step" -- 1205
						lastRaw = truncateText( -- 1206
							toJson({tool = decision.tool, params = decision.params}), -- 1206
							400 -- 1206
						) -- 1206
						Log("Warn", "[CodingAgent] duplicate yaml decision rejected tool=" .. decision.tool) -- 1207
						goto __continue228 -- 1208
					end -- 1208
					return ____awaiter_resolve(nil, decision) -- 1208
				end -- 1208
				::__continue228:: -- 1208
				attempt = attempt + 1 -- 1174
			end -- 1174
		end -- 1174
		return ____awaiter_resolve( -- 1174
			nil, -- 1174
			{ -- 1212
				success = false, -- 1212
				message = (("cannot produce valid decision yaml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1212
			} -- 1212
		) -- 1212
	end) -- 1212
end -- 1109
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1215
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1215
		local result = execRes -- 1216
		if not result.success then -- 1216
			shared.error = result.message -- 1218
			return ____awaiter_resolve(nil, "error") -- 1218
		end -- 1218
		emitAgentEvent(shared, { -- 1221
			type = "decision_made", -- 1222
			sessionId = shared.sessionId, -- 1223
			taskId = shared.taskId, -- 1224
			step = shared.step + 1, -- 1225
			tool = result.tool, -- 1226
			reason = result.reason, -- 1227
			params = result.params -- 1228
		}) -- 1228
		shared.lastDecision = {tool = result.tool, reason = result.reason, params = result.params} -- 1230
		local ____shared_history_12 = shared.history -- 1230
		____shared_history_12[#____shared_history_12 + 1] = { -- 1235
			step = #shared.history + 1, -- 1236
			tool = result.tool, -- 1237
			reason = result.reason, -- 1238
			params = result.params, -- 1239
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1240
		} -- 1240
		persistHistoryState(shared) -- 1242
		return ____awaiter_resolve(nil, result.tool) -- 1242
	end) -- 1242
end -- 1215
local ReadFileAction = __TS__Class() -- 1247
ReadFileAction.name = "ReadFileAction" -- 1247
__TS__ClassExtends(ReadFileAction, Node) -- 1247
function ReadFileAction.prototype.prep(self, shared) -- 1248
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1248
		local last = shared.history[#shared.history] -- 1249
		if not last then -- 1249
			error( -- 1250
				__TS__New(Error, "no history"), -- 1250
				0 -- 1250
			) -- 1250
		end -- 1250
		emitAgentEvent(shared, { -- 1251
			type = "tool_started", -- 1252
			sessionId = shared.sessionId, -- 1253
			taskId = shared.taskId, -- 1254
			step = shared.step + 1, -- 1255
			tool = last.tool -- 1256
		}) -- 1256
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1258
		if __TS__StringTrim(path) == "" then -- 1258
			error( -- 1261
				__TS__New(Error, "missing path"), -- 1261
				0 -- 1261
			) -- 1261
		end -- 1261
		if last.tool == "read_file_range" then -- 1261
			local ____path_17 = path -- 1264
			local ____last_tool_18 = last.tool -- 1265
			local ____shared_workingDir_19 = shared.workingDir -- 1266
			local ____temp_20 = shared.useChineseResponse and "zh" or "en" -- 1267
			local ____last_params_startLine_13 = last.params.startLine -- 1269
			if ____last_params_startLine_13 == nil then -- 1269
				____last_params_startLine_13 = 1 -- 1269
			end -- 1269
			local ____TS__Number_result_16 = __TS__Number(____last_params_startLine_13) -- 1269
			local ____last_params_endLine_14 = last.params.endLine -- 1270
			if ____last_params_endLine_14 == nil then -- 1270
				____last_params_endLine_14 = last.params.startLine -- 1270
			end -- 1270
			local ____last_params_endLine_14_15 = ____last_params_endLine_14 -- 1270
			if ____last_params_endLine_14_15 == nil then -- 1270
				____last_params_endLine_14_15 = 1 -- 1270
			end -- 1270
			return ____awaiter_resolve( -- 1270
				nil, -- 1270
				{ -- 1263
					path = ____path_17, -- 1264
					tool = ____last_tool_18, -- 1265
					workDir = ____shared_workingDir_19, -- 1266
					docLanguage = ____temp_20, -- 1267
					range = { -- 1268
						startLine = ____TS__Number_result_16, -- 1269
						endLine = __TS__Number(____last_params_endLine_14_15) -- 1270
					} -- 1270
				} -- 1270
			) -- 1270
		end -- 1270
		local ____path_23 = path -- 1275
		local ____shared_workingDir_24 = shared.workingDir -- 1277
		local ____temp_25 = shared.useChineseResponse and "zh" or "en" -- 1278
		local ____last_params_offset_21 = last.params.offset -- 1279
		if ____last_params_offset_21 == nil then -- 1279
			____last_params_offset_21 = 1 -- 1279
		end -- 1279
		local ____TS__Number_result_26 = __TS__Number(____last_params_offset_21) -- 1279
		local ____last_params_limit_22 = last.params.limit -- 1280
		if ____last_params_limit_22 == nil then -- 1280
			____last_params_limit_22 = READ_FILE_DEFAULT_LIMIT -- 1280
		end -- 1280
		return ____awaiter_resolve( -- 1280
			nil, -- 1280
			{ -- 1274
				path = ____path_23, -- 1275
				tool = "read_file", -- 1276
				workDir = ____shared_workingDir_24, -- 1277
				docLanguage = ____temp_25, -- 1278
				offset = ____TS__Number_result_26, -- 1279
				limit = __TS__Number(____last_params_limit_22) -- 1280
			} -- 1280
		) -- 1280
	end) -- 1280
end -- 1248
function ReadFileAction.prototype.exec(self, input) -- 1284
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1284
		if input.tool == "read_file_range" and input.range then -- 1284
			return ____awaiter_resolve( -- 1284
				nil, -- 1284
				Tools.readFileRange( -- 1286
					input.workDir, -- 1286
					input.path, -- 1286
					input.range.startLine, -- 1286
					input.range.endLine, -- 1286
					input.docLanguage -- 1286
				) -- 1286
			) -- 1286
		end -- 1286
		return ____awaiter_resolve( -- 1286
			nil, -- 1286
			Tools.readFile( -- 1288
				input.workDir, -- 1289
				input.path, -- 1290
				__TS__Number(input.offset or 1), -- 1291
				__TS__Number(input.limit or READ_FILE_DEFAULT_LIMIT), -- 1292
				input.docLanguage -- 1293
			) -- 1293
		) -- 1293
	end) -- 1293
end -- 1284
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1297
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1297
		local result = execRes -- 1298
		local last = shared.history[#shared.history] -- 1299
		if last ~= nil then -- 1299
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1301
			emitAgentEvent(shared, { -- 1302
				type = "tool_finished", -- 1303
				sessionId = shared.sessionId, -- 1304
				taskId = shared.taskId, -- 1305
				step = shared.step + 1, -- 1306
				tool = last.tool, -- 1307
				result = last.result -- 1308
			}) -- 1308
		end -- 1308
		__TS__Await(maybeCompressHistory(shared)) -- 1311
		persistHistoryState(shared) -- 1312
		shared.step = shared.step + 1 -- 1313
		return ____awaiter_resolve(nil, "main") -- 1313
	end) -- 1313
end -- 1297
local SearchFilesAction = __TS__Class() -- 1318
SearchFilesAction.name = "SearchFilesAction" -- 1318
__TS__ClassExtends(SearchFilesAction, Node) -- 1318
function SearchFilesAction.prototype.prep(self, shared) -- 1319
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1319
		local last = shared.history[#shared.history] -- 1320
		if not last then -- 1320
			error( -- 1321
				__TS__New(Error, "no history"), -- 1321
				0 -- 1321
			) -- 1321
		end -- 1321
		emitAgentEvent(shared, { -- 1322
			type = "tool_started", -- 1323
			sessionId = shared.sessionId, -- 1324
			taskId = shared.taskId, -- 1325
			step = shared.step + 1, -- 1326
			tool = last.tool -- 1327
		}) -- 1327
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1327
	end) -- 1327
end -- 1319
function SearchFilesAction.prototype.exec(self, input) -- 1332
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1332
		local params = input.params -- 1333
		local ____Tools_searchFiles_40 = Tools.searchFiles -- 1334
		local ____input_workDir_33 = input.workDir -- 1335
		local ____temp_34 = params.path or "" -- 1336
		local ____temp_35 = params.pattern or "" -- 1337
		local ____params_globs_36 = params.globs -- 1338
		local ____params_useRegex_37 = params.useRegex -- 1339
		local ____params_caseSensitive_38 = params.caseSensitive -- 1340
		local ____math_max_29 = math.max -- 1343
		local ____math_floor_28 = math.floor -- 1343
		local ____params_limit_27 = params.limit -- 1343
		if ____params_limit_27 == nil then -- 1343
			____params_limit_27 = SEARCH_FILES_LIMIT_DEFAULT -- 1343
		end -- 1343
		local ____math_max_29_result_39 = ____math_max_29( -- 1343
			1, -- 1343
			____math_floor_28(__TS__Number(____params_limit_27)) -- 1343
		) -- 1343
		local ____math_max_32 = math.max -- 1344
		local ____math_floor_31 = math.floor -- 1344
		local ____params_offset_30 = params.offset -- 1344
		if ____params_offset_30 == nil then -- 1344
			____params_offset_30 = 0 -- 1344
		end -- 1344
		local result = __TS__Await(____Tools_searchFiles_40({ -- 1334
			workDir = ____input_workDir_33, -- 1335
			path = ____temp_34, -- 1336
			pattern = ____temp_35, -- 1337
			globs = ____params_globs_36, -- 1338
			useRegex = ____params_useRegex_37, -- 1339
			caseSensitive = ____params_caseSensitive_38, -- 1340
			includeContent = true, -- 1341
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1342
			limit = ____math_max_29_result_39, -- 1343
			offset = ____math_max_32( -- 1344
				0, -- 1344
				____math_floor_31(__TS__Number(____params_offset_30)) -- 1344
			), -- 1344
			groupByFile = params.groupByFile == true -- 1345
		})) -- 1345
		return ____awaiter_resolve(nil, result) -- 1345
	end) -- 1345
end -- 1332
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1350
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1350
		local last = shared.history[#shared.history] -- 1351
		if last ~= nil then -- 1351
			local followupHint = shared.useChineseResponse and "然后读取搜索结果中相关的文件来了解详情。" or "Then read the relevant files from the search results to inspect the details." -- 1353
			if not __TS__StringIncludes(last.reason, followupHint) then -- 1353
				last.reason = __TS__StringTrim((last.reason .. " ") .. followupHint) -- 1357
			end -- 1357
			local result = execRes -- 1359
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1360
			emitAgentEvent(shared, { -- 1361
				type = "tool_finished", -- 1362
				sessionId = shared.sessionId, -- 1363
				taskId = shared.taskId, -- 1364
				step = shared.step + 1, -- 1365
				tool = last.tool, -- 1366
				result = last.result -- 1367
			}) -- 1367
		end -- 1367
		__TS__Await(maybeCompressHistory(shared)) -- 1370
		persistHistoryState(shared) -- 1371
		shared.step = shared.step + 1 -- 1372
		return ____awaiter_resolve(nil, "main") -- 1372
	end) -- 1372
end -- 1350
local SearchDoraAPIAction = __TS__Class() -- 1377
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1377
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1377
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1378
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1378
		local last = shared.history[#shared.history] -- 1379
		if not last then -- 1379
			error( -- 1380
				__TS__New(Error, "no history"), -- 1380
				0 -- 1380
			) -- 1380
		end -- 1380
		emitAgentEvent(shared, { -- 1381
			type = "tool_started", -- 1382
			sessionId = shared.sessionId, -- 1383
			taskId = shared.taskId, -- 1384
			step = shared.step + 1, -- 1385
			tool = last.tool -- 1386
		}) -- 1386
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1386
	end) -- 1386
end -- 1378
function SearchDoraAPIAction.prototype.exec(self, input) -- 1391
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1391
		local params = input.params -- 1392
		local ____Tools_searchDoraAPI_48 = Tools.searchDoraAPI -- 1393
		local ____temp_44 = params.pattern or "" -- 1394
		local ____temp_45 = params.docSource or "api" -- 1395
		local ____temp_46 = input.useChineseResponse and "zh" or "en" -- 1396
		local ____temp_47 = params.programmingLanguage or "ts" -- 1397
		local ____math_min_43 = math.min -- 1398
		local ____math_max_42 = math.max -- 1398
		local ____params_limit_41 = params.limit -- 1398
		if ____params_limit_41 == nil then -- 1398
			____params_limit_41 = 8 -- 1398
		end -- 1398
		local result = __TS__Await(____Tools_searchDoraAPI_48({ -- 1393
			pattern = ____temp_44, -- 1394
			docSource = ____temp_45, -- 1395
			docLanguage = ____temp_46, -- 1396
			programmingLanguage = ____temp_47, -- 1397
			limit = ____math_min_43( -- 1398
				SEARCH_DORA_API_LIMIT_MAX, -- 1398
				____math_max_42( -- 1398
					1, -- 1398
					__TS__Number(____params_limit_41) -- 1398
				) -- 1398
			), -- 1398
			useRegex = params.useRegex, -- 1399
			caseSensitive = false, -- 1400
			includeContent = true, -- 1401
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1402
		})) -- 1402
		return ____awaiter_resolve(nil, result) -- 1402
	end) -- 1402
end -- 1391
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1407
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1407
		local last = shared.history[#shared.history] -- 1408
		if last ~= nil then -- 1408
			local result = execRes -- 1410
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1411
			emitAgentEvent(shared, { -- 1412
				type = "tool_finished", -- 1413
				sessionId = shared.sessionId, -- 1414
				taskId = shared.taskId, -- 1415
				step = shared.step + 1, -- 1416
				tool = last.tool, -- 1417
				result = last.result -- 1418
			}) -- 1418
		end -- 1418
		__TS__Await(maybeCompressHistory(shared)) -- 1421
		persistHistoryState(shared) -- 1422
		shared.step = shared.step + 1 -- 1423
		return ____awaiter_resolve(nil, "main") -- 1423
	end) -- 1423
end -- 1407
local ListFilesAction = __TS__Class() -- 1428
ListFilesAction.name = "ListFilesAction" -- 1428
__TS__ClassExtends(ListFilesAction, Node) -- 1428
function ListFilesAction.prototype.prep(self, shared) -- 1429
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1429
		local last = shared.history[#shared.history] -- 1430
		if not last then -- 1430
			error( -- 1431
				__TS__New(Error, "no history"), -- 1431
				0 -- 1431
			) -- 1431
		end -- 1431
		emitAgentEvent(shared, { -- 1432
			type = "tool_started", -- 1433
			sessionId = shared.sessionId, -- 1434
			taskId = shared.taskId, -- 1435
			step = shared.step + 1, -- 1436
			tool = last.tool -- 1437
		}) -- 1437
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1437
	end) -- 1437
end -- 1429
function ListFilesAction.prototype.exec(self, input) -- 1442
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1442
		local params = input.params -- 1443
		local ____Tools_listFiles_55 = Tools.listFiles -- 1444
		local ____input_workDir_52 = input.workDir -- 1445
		local ____temp_53 = params.path or "" -- 1446
		local ____params_globs_54 = params.globs -- 1447
		local ____math_max_51 = math.max -- 1448
		local ____math_floor_50 = math.floor -- 1448
		local ____params_maxEntries_49 = params.maxEntries -- 1448
		if ____params_maxEntries_49 == nil then -- 1448
			____params_maxEntries_49 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1448
		end -- 1448
		local result = ____Tools_listFiles_55({ -- 1444
			workDir = ____input_workDir_52, -- 1445
			path = ____temp_53, -- 1446
			globs = ____params_globs_54, -- 1447
			maxEntries = ____math_max_51( -- 1448
				1, -- 1448
				____math_floor_50(__TS__Number(____params_maxEntries_49)) -- 1448
			) -- 1448
		}) -- 1448
		return ____awaiter_resolve(nil, result) -- 1448
	end) -- 1448
end -- 1442
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1453
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1453
		local last = shared.history[#shared.history] -- 1454
		if last ~= nil then -- 1454
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1456
			emitAgentEvent(shared, { -- 1457
				type = "tool_finished", -- 1458
				sessionId = shared.sessionId, -- 1459
				taskId = shared.taskId, -- 1460
				step = shared.step + 1, -- 1461
				tool = last.tool, -- 1462
				result = last.result -- 1463
			}) -- 1463
		end -- 1463
		__TS__Await(maybeCompressHistory(shared)) -- 1466
		persistHistoryState(shared) -- 1467
		shared.step = shared.step + 1 -- 1468
		return ____awaiter_resolve(nil, "main") -- 1468
	end) -- 1468
end -- 1453
local DeleteFileAction = __TS__Class() -- 1473
DeleteFileAction.name = "DeleteFileAction" -- 1473
__TS__ClassExtends(DeleteFileAction, Node) -- 1473
function DeleteFileAction.prototype.prep(self, shared) -- 1474
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1474
		local last = shared.history[#shared.history] -- 1475
		if not last then -- 1475
			error( -- 1476
				__TS__New(Error, "no history"), -- 1476
				0 -- 1476
			) -- 1476
		end -- 1476
		emitAgentEvent(shared, { -- 1477
			type = "tool_started", -- 1478
			sessionId = shared.sessionId, -- 1479
			taskId = shared.taskId, -- 1480
			step = shared.step + 1, -- 1481
			tool = last.tool -- 1482
		}) -- 1482
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1484
		if __TS__StringTrim(targetFile) == "" then -- 1484
			error( -- 1487
				__TS__New(Error, "missing target_file"), -- 1487
				0 -- 1487
			) -- 1487
		end -- 1487
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1487
	end) -- 1487
end -- 1474
function DeleteFileAction.prototype.exec(self, input) -- 1491
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1491
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1492
		if not result.success then -- 1492
			return ____awaiter_resolve(nil, result) -- 1492
		end -- 1492
		return ____awaiter_resolve(nil, { -- 1492
			success = true, -- 1500
			changed = true, -- 1501
			mode = "delete", -- 1502
			checkpointId = result.checkpointId, -- 1503
			checkpointSeq = result.checkpointSeq, -- 1504
			files = {{path = input.targetFile, op = "delete"}} -- 1505
		}) -- 1505
	end) -- 1505
end -- 1491
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1509
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1509
		local last = shared.history[#shared.history] -- 1510
		if last ~= nil then -- 1510
			last.result = execRes -- 1512
			emitAgentEvent(shared, { -- 1513
				type = "tool_finished", -- 1514
				sessionId = shared.sessionId, -- 1515
				taskId = shared.taskId, -- 1516
				step = shared.step + 1, -- 1517
				tool = last.tool, -- 1518
				result = last.result -- 1519
			}) -- 1519
			local result = last.result -- 1521
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1521
				emitAgentEvent(shared, { -- 1526
					type = "checkpoint_created", -- 1527
					sessionId = shared.sessionId, -- 1528
					taskId = shared.taskId, -- 1529
					step = shared.step + 1, -- 1530
					tool = "delete_file", -- 1531
					checkpointId = result.checkpointId, -- 1532
					checkpointSeq = result.checkpointSeq, -- 1533
					files = result.files -- 1534
				}) -- 1534
			end -- 1534
		end -- 1534
		__TS__Await(maybeCompressHistory(shared)) -- 1538
		persistHistoryState(shared) -- 1539
		shared.step = shared.step + 1 -- 1540
		return ____awaiter_resolve(nil, "main") -- 1540
	end) -- 1540
end -- 1509
local BuildAction = __TS__Class() -- 1545
BuildAction.name = "BuildAction" -- 1545
__TS__ClassExtends(BuildAction, Node) -- 1545
function BuildAction.prototype.prep(self, shared) -- 1546
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1546
		local last = shared.history[#shared.history] -- 1547
		if not last then -- 1547
			error( -- 1548
				__TS__New(Error, "no history"), -- 1548
				0 -- 1548
			) -- 1548
		end -- 1548
		emitAgentEvent(shared, { -- 1549
			type = "tool_started", -- 1550
			sessionId = shared.sessionId, -- 1551
			taskId = shared.taskId, -- 1552
			step = shared.step + 1, -- 1553
			tool = last.tool -- 1554
		}) -- 1554
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1554
	end) -- 1554
end -- 1546
function BuildAction.prototype.exec(self, input) -- 1559
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1559
		local params = input.params -- 1560
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1561
		return ____awaiter_resolve(nil, result) -- 1561
	end) -- 1561
end -- 1559
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1568
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1568
		local last = shared.history[#shared.history] -- 1569
		if last ~= nil then -- 1569
			local followupHint = shared.useChineseResponse and "构建已完成，将根据结果做后续处理，不再重复构建。" or "Build completed. Shall handle the result instead of building again." -- 1571
			local reason = last.reason -- 1571
			last.reason = last.reason and last.reason ~= "" and (last.reason .. "\n") .. followupHint or followupHint -- 1575
			last.result = execRes -- 1578
			emitAgentEvent(shared, { -- 1579
				type = "tool_finished", -- 1580
				sessionId = shared.sessionId, -- 1581
				taskId = shared.taskId, -- 1582
				step = shared.step + 1, -- 1583
				tool = last.tool, -- 1584
				reason = reason, -- 1585
				result = last.result -- 1586
			}) -- 1586
		end -- 1586
		__TS__Await(maybeCompressHistory(shared)) -- 1589
		persistHistoryState(shared) -- 1590
		shared.step = shared.step + 1 -- 1591
		return ____awaiter_resolve(nil, "main") -- 1591
	end) -- 1591
end -- 1568
local EditFileAction = __TS__Class() -- 1596
EditFileAction.name = "EditFileAction" -- 1596
__TS__ClassExtends(EditFileAction, Node) -- 1596
function EditFileAction.prototype.prep(self, shared) -- 1597
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1597
		local last = shared.history[#shared.history] -- 1598
		if not last then -- 1598
			error( -- 1599
				__TS__New(Error, "no history"), -- 1599
				0 -- 1599
			) -- 1599
		end -- 1599
		emitAgentEvent(shared, { -- 1600
			type = "tool_started", -- 1601
			sessionId = shared.sessionId, -- 1602
			taskId = shared.taskId, -- 1603
			step = shared.step + 1, -- 1604
			tool = last.tool -- 1605
		}) -- 1605
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1607
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1610
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1611
		if __TS__StringTrim(path) == "" then -- 1611
			error( -- 1612
				__TS__New(Error, "missing path"), -- 1612
				0 -- 1612
			) -- 1612
		end -- 1612
		if oldStr == newStr then -- 1612
			error( -- 1613
				__TS__New(Error, "old_str and new_str must be different"), -- 1613
				0 -- 1613
			) -- 1613
		end -- 1613
		return ____awaiter_resolve(nil, { -- 1613
			path = path, -- 1614
			oldStr = oldStr, -- 1614
			newStr = newStr, -- 1614
			taskId = shared.taskId, -- 1614
			workDir = shared.workingDir -- 1614
		}) -- 1614
	end) -- 1614
end -- 1597
function EditFileAction.prototype.exec(self, input) -- 1617
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1617
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1618
		if not readRes.success then -- 1618
			if input.oldStr ~= "" then -- 1618
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1618
			end -- 1618
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1623
			if not createRes.success then -- 1623
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1623
			end -- 1623
			return ____awaiter_resolve(nil, { -- 1623
				success = true, -- 1631
				changed = true, -- 1632
				mode = "create", -- 1633
				replaced = 0, -- 1634
				checkpointId = createRes.checkpointId, -- 1635
				checkpointSeq = createRes.checkpointSeq, -- 1636
				files = {{path = input.path, op = "create"}} -- 1637
			}) -- 1637
		end -- 1637
		if input.oldStr == "" then -- 1637
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 1637
		end -- 1637
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 1644
		if replaceRes.replaced == 0 then -- 1644
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 1644
		end -- 1644
		if replaceRes.content == readRes.content then -- 1644
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 1644
		end -- 1644
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1657
		if not applyRes.success then -- 1657
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1657
		end -- 1657
		return ____awaiter_resolve(nil, { -- 1657
			success = true, -- 1665
			changed = true, -- 1666
			mode = "replace", -- 1667
			replaced = replaceRes.replaced, -- 1668
			checkpointId = applyRes.checkpointId, -- 1669
			checkpointSeq = applyRes.checkpointSeq, -- 1670
			files = {{path = input.path, op = "write"}} -- 1671
		}) -- 1671
	end) -- 1671
end -- 1617
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1675
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1675
		local last = shared.history[#shared.history] -- 1676
		if last ~= nil then -- 1676
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1678
			last.result = execRes -- 1679
			emitAgentEvent(shared, { -- 1680
				type = "tool_finished", -- 1681
				sessionId = shared.sessionId, -- 1682
				taskId = shared.taskId, -- 1683
				step = shared.step + 1, -- 1684
				tool = last.tool, -- 1685
				result = last.result -- 1686
			}) -- 1686
			local result = last.result -- 1688
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1688
				emitAgentEvent(shared, { -- 1693
					type = "checkpoint_created", -- 1694
					sessionId = shared.sessionId, -- 1695
					taskId = shared.taskId, -- 1696
					step = shared.step + 1, -- 1697
					tool = last.tool, -- 1698
					checkpointId = result.checkpointId, -- 1699
					checkpointSeq = result.checkpointSeq, -- 1700
					files = result.files -- 1701
				}) -- 1701
			end -- 1701
		end -- 1701
		__TS__Await(maybeCompressHistory(shared)) -- 1705
		persistHistoryState(shared) -- 1706
		shared.step = shared.step + 1 -- 1707
		return ____awaiter_resolve(nil, "main") -- 1707
	end) -- 1707
end -- 1675
local FormatResponseNode = __TS__Class() -- 1712
FormatResponseNode.name = "FormatResponseNode" -- 1712
__TS__ClassExtends(FormatResponseNode, Node) -- 1712
function FormatResponseNode.prototype.prep(self, shared) -- 1713
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1713
		local last = shared.history[#shared.history] -- 1714
		if last and last.tool == "finish" then -- 1714
			emitAgentEvent(shared, { -- 1716
				type = "tool_started", -- 1717
				sessionId = shared.sessionId, -- 1718
				taskId = shared.taskId, -- 1719
				step = shared.step + 1, -- 1720
				tool = last.tool -- 1721
			}) -- 1721
		end -- 1721
		return ____awaiter_resolve(nil, {history = shared.history, shared = shared}) -- 1721
	end) -- 1721
end -- 1713
function FormatResponseNode.prototype.exec(self, input) -- 1727
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1727
		if input.shared.stopToken.stopped then -- 1727
			return ____awaiter_resolve( -- 1727
				nil, -- 1727
				getCancelledReason(input.shared) -- 1729
			) -- 1729
		end -- 1729
		local failureNote = input.shared.error and input.shared.error ~= "" and (input.shared.useChineseResponse and "\n\n本次任务因以下错误结束，请在总结中明确说明：\n" .. input.shared.error or "\n\nThis task ended with the following error. Make sure the summary states it clearly:\n" .. input.shared.error) or "" -- 1731
		local history = input.history -- 1736
		if #history == 0 then -- 1736
			if input.shared.error and input.shared.error ~= "" then -- 1736
				return ____awaiter_resolve( -- 1736
					nil, -- 1736
					getFailureSummaryFallback(input.shared, input.shared.error) -- 1739
				) -- 1739
			end -- 1739
			return ____awaiter_resolve(nil, "No actions were performed.") -- 1739
		end -- 1739
		local summary = formatHistorySummary(history) -- 1743
		local prompt = replacePromptVars( -- 1744
			input.shared.promptPack.finalSummaryPrompt, -- 1744
			{ -- 1744
				SUMMARY = summary, -- 1745
				LANGUAGE_DIRECTIVE = getReplyLanguageDirective(input.shared) -- 1746
			} -- 1746
		) .. failureNote -- 1746
		local res -- 1748
		do -- 1748
			local i = 0 -- 1749
			while i < input.shared.llmMaxTry do -- 1749
				res = __TS__Await(llmStream(input.shared, {{role = "user", content = prompt}})) -- 1750
				if res.success then -- 1750
					break -- 1751
				end -- 1751
				i = i + 1 -- 1749
			end -- 1749
		end -- 1749
		if not res then -- 1749
			return ____awaiter_resolve( -- 1749
				nil, -- 1749
				input.shared.error and input.shared.error ~= "" and getFailureSummaryFallback(input.shared, input.shared.error) or (input.shared.useChineseResponse and "执行完成，但生成总结失败。" or "Completed, but failed to generate summary.") -- 1754
			) -- 1754
		end -- 1754
		if not res.success then -- 1754
			return ____awaiter_resolve( -- 1754
				nil, -- 1754
				input.shared.error and input.shared.error ~= "" and getFailureSummaryFallback(input.shared, input.shared.error) or (input.shared.useChineseResponse and "执行完成，但生成总结失败：" .. res.message or "Completed, but failed to generate summary: " .. res.message) -- 1761
			) -- 1761
		end -- 1761
		return ____awaiter_resolve(nil, res.text) -- 1761
	end) -- 1761
end -- 1727
function FormatResponseNode.prototype.post(self, shared, _prepRes, execRes) -- 1770
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1770
		local last = shared.history[#shared.history] -- 1771
		if last and last.tool == "finish" then -- 1771
			last.result = {success = true, message = execRes} -- 1773
			emitAgentEvent(shared, { -- 1774
				type = "tool_finished", -- 1775
				sessionId = shared.sessionId, -- 1776
				taskId = shared.taskId, -- 1777
				step = shared.step + 1, -- 1778
				tool = last.tool, -- 1779
				result = last.result -- 1780
			}) -- 1780
			shared.step = shared.step + 1 -- 1782
		end -- 1782
		shared.response = execRes -- 1784
		shared.done = true -- 1785
		persistHistoryState(shared) -- 1786
		return ____awaiter_resolve(nil, nil) -- 1786
	end) -- 1786
end -- 1770
local CodingAgentFlow = __TS__Class() -- 1791
CodingAgentFlow.name = "CodingAgentFlow" -- 1791
__TS__ClassExtends(CodingAgentFlow, Flow) -- 1791
function CodingAgentFlow.prototype.____constructor(self) -- 1792
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 1793
	local read = __TS__New(ReadFileAction, 1, 0) -- 1794
	local search = __TS__New(SearchFilesAction, 1, 0) -- 1795
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 1796
	local list = __TS__New(ListFilesAction, 1, 0) -- 1797
	local del = __TS__New(DeleteFileAction, 1, 0) -- 1798
	local build = __TS__New(BuildAction, 1, 0) -- 1799
	local edit = __TS__New(EditFileAction, 1, 0) -- 1800
	local format = __TS__New(FormatResponseNode, 1, 0) -- 1801
	main:on("read_file", read) -- 1803
	main:on("read_file_range", read) -- 1804
	main:on("grep_files", search) -- 1805
	main:on("search_dora_api", searchDora) -- 1806
	main:on("glob_files", list) -- 1807
	main:on("delete_file", del) -- 1808
	main:on("build", build) -- 1809
	main:on("edit_file", edit) -- 1810
	main:on("finish", format) -- 1811
	main:on("error", format) -- 1812
	read:on("main", main) -- 1814
	search:on("main", main) -- 1815
	searchDora:on("main", main) -- 1816
	list:on("main", main) -- 1817
	del:on("main", main) -- 1818
	build:on("main", main) -- 1819
	edit:on("main", main) -- 1820
	Flow.prototype.____constructor(self, main) -- 1822
end -- 1792
local function runCodingAgentAsync(options) -- 1826
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1826
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 1826
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 1826
		end -- 1826
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 1830
		if not llmConfigRes.success then -- 1830
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 1830
		end -- 1830
		local llmConfig = llmConfigRes.config -- 1836
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 1837
		if not taskRes.success then -- 1837
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 1837
		end -- 1837
		local compressor = __TS__New(MemoryCompressor, { -- 1844
			compressionThreshold = 0.8, -- 1845
			maxCompressionRounds = 3, -- 1846
			maxTokensPerCompression = 20000, -- 1847
			projectDir = options.workDir, -- 1848
			llmConfig = llmConfig, -- 1849
			promptPack = options.promptPack -- 1850
		}) -- 1850
		local persistedSession = compressor:getStorage():readSessionState() -- 1852
		local promptPack = compressor:getPromptPack() -- 1853
		local shared = { -- 1855
			sessionId = options.sessionId, -- 1856
			taskId = taskRes.taskId, -- 1857
			maxSteps = math.max( -- 1858
				1, -- 1858
				math.floor(options.maxSteps or 40) -- 1858
			), -- 1858
			llmMaxTry = math.max( -- 1859
				1, -- 1859
				math.floor(options.llmMaxTry or 3) -- 1859
			), -- 1859
			step = 0, -- 1860
			done = false, -- 1861
			stopToken = options.stopToken or ({stopped = false}), -- 1862
			response = "", -- 1863
			userQuery = options.prompt, -- 1864
			workingDir = options.workDir, -- 1865
			useChineseResponse = options.useChineseResponse == true, -- 1866
			decisionMode = options.decisionMode == "yaml" and "yaml" or "tool_calling", -- 1867
			llmOptions = __TS__ObjectAssign({temperature = 0.2}, options.llmOptions or ({})), -- 1868
			llmConfig = llmConfig, -- 1872
			onEvent = options.onEvent, -- 1873
			promptPack = promptPack, -- 1874
			history = persistedSession.history, -- 1875
			memory = {lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, compressor = compressor} -- 1877
		} -- 1877
		local ____try = __TS__AsyncAwaiter(function() -- 1877
			emitAgentEvent(shared, { -- 1884
				type = "task_started", -- 1885
				sessionId = shared.sessionId, -- 1886
				taskId = shared.taskId, -- 1887
				prompt = shared.userQuery, -- 1888
				workDir = shared.workingDir, -- 1889
				maxSteps = shared.maxSteps -- 1890
			}) -- 1890
			if shared.stopToken.stopped then -- 1890
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1893
				local result = { -- 1894
					success = false, -- 1894
					taskId = shared.taskId, -- 1894
					message = getCancelledReason(shared), -- 1894
					steps = shared.step -- 1894
				} -- 1894
				emitAgentEvent(shared, { -- 1895
					type = "task_finished", -- 1896
					sessionId = shared.sessionId, -- 1897
					taskId = shared.taskId, -- 1898
					success = false, -- 1899
					message = result.message, -- 1900
					steps = result.steps -- 1901
				}) -- 1901
				return ____awaiter_resolve(nil, result) -- 1901
			end -- 1901
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 1905
			local flow = __TS__New(CodingAgentFlow) -- 1906
			__TS__Await(flow:run(shared)) -- 1907
			if shared.stopToken.stopped then -- 1907
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1909
				local result = { -- 1910
					success = false, -- 1910
					taskId = shared.taskId, -- 1910
					message = getCancelledReason(shared), -- 1910
					steps = shared.step -- 1910
				} -- 1910
				emitAgentEvent(shared, { -- 1911
					type = "task_finished", -- 1912
					sessionId = shared.sessionId, -- 1913
					taskId = shared.taskId, -- 1914
					success = false, -- 1915
					message = result.message, -- 1916
					steps = result.steps -- 1917
				}) -- 1917
				return ____awaiter_resolve(nil, result) -- 1917
			end -- 1917
			if shared.error then -- 1917
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1922
				local result = {success = false, taskId = shared.taskId, message = shared.response and shared.response ~= "" and shared.response or shared.error, steps = shared.step} -- 1923
				emitAgentEvent(shared, { -- 1929
					type = "task_finished", -- 1930
					sessionId = shared.sessionId, -- 1931
					taskId = shared.taskId, -- 1932
					success = false, -- 1933
					message = result.message, -- 1934
					steps = result.steps -- 1935
				}) -- 1935
				return ____awaiter_resolve(nil, result) -- 1935
			end -- 1935
			Tools.setTaskStatus(shared.taskId, "DONE") -- 1939
			local result = {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step} -- 1940
			emitAgentEvent(shared, { -- 1946
				type = "task_finished", -- 1947
				sessionId = shared.sessionId, -- 1948
				taskId = shared.taskId, -- 1949
				success = true, -- 1950
				message = result.message, -- 1951
				steps = result.steps -- 1952
			}) -- 1952
			return ____awaiter_resolve(nil, result) -- 1952
		end) -- 1952
		__TS__Await(____try.catch( -- 1883
			____try, -- 1883
			function(____, e) -- 1883
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1956
				local result = { -- 1957
					success = false, -- 1957
					taskId = shared.taskId, -- 1957
					message = tostring(e), -- 1957
					steps = shared.step -- 1957
				} -- 1957
				emitAgentEvent(shared, { -- 1958
					type = "task_finished", -- 1959
					sessionId = shared.sessionId, -- 1960
					taskId = shared.taskId, -- 1961
					success = false, -- 1962
					message = result.message, -- 1963
					steps = result.steps -- 1964
				}) -- 1964
				return ____awaiter_resolve(nil, result) -- 1964
			end -- 1964
		)) -- 1964
	end) -- 1964
end -- 1826
function ____exports.runCodingAgent(options, callback) -- 1970
	local ____self_56 = runCodingAgentAsync(options) -- 1970
	____self_56["then"]( -- 1970
		____self_56, -- 1970
		function(____, result) return callback(result) end -- 1971
	) -- 1971
end -- 1970
return ____exports -- 1970