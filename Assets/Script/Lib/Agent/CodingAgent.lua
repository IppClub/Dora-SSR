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
local DEFAULT_AGENT_PROMPT = ____Memory.DEFAULT_AGENT_PROMPT -- 8
function toJson(value) -- 180
	local text, err = json.encode(value) -- 181
	if text ~= nil then -- 181
		return text -- 182
	end -- 182
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 183
end -- 183
function truncateText(text, maxLen) -- 186
	if #text <= maxLen then -- 186
		return text -- 187
	end -- 187
	local nextPos = utf8.offset(text, maxLen + 1) -- 188
	if nextPos == nil then -- 188
		return text -- 189
	end -- 189
	return string.sub(text, 1, nextPos - 1) .. "..." -- 190
end -- 190
function utf8TakeHead(text, maxChars) -- 193
	if maxChars <= 0 or text == "" then -- 193
		return "" -- 194
	end -- 194
	local nextPos = utf8.offset(text, maxChars + 1) -- 195
	if nextPos == nil then -- 195
		return text -- 196
	end -- 196
	return string.sub(text, 1, nextPos - 1) -- 197
end -- 197
function summarizeUnknown(value, maxLen) -- 210
	if maxLen == nil then -- 210
		maxLen = 320 -- 210
	end -- 210
	if value == nil then -- 210
		return "undefined" -- 211
	end -- 211
	if value == nil then -- 211
		return "null" -- 212
	end -- 212
	if type(value) == "string" then -- 212
		return __TS__StringReplace( -- 214
			truncateText(value, maxLen), -- 214
			"\n", -- 214
			"\\n" -- 214
		) -- 214
	end -- 214
	if type(value) == "number" or type(value) == "boolean" then -- 214
		return tostring(value) -- 217
	end -- 217
	return __TS__StringReplace( -- 219
		truncateText( -- 219
			toJson(value), -- 219
			maxLen -- 219
		), -- 219
		"\n", -- 219
		"\\n" -- 219
	) -- 219
end -- 219
function limitReadContentForHistory(content, tool) -- 228
	local lines = __TS__StringSplit(content, "\n") -- 229
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 230
	local limitedByLines = overLineLimit and table.concat( -- 231
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 232
		"\n" -- 232
	) or content -- 232
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 232
		return content -- 235
	end -- 235
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 237
	local reasons = {} -- 240
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 240
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 241
	end -- 241
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 241
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 242
	end -- 242
	local hint = tool == "read_file" and "Use read_file_range for the exact section you need." or "Narrow the requested line range." -- 243
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 246
end -- 246
function pushLimitedMatches(lines, items, maxItems, mapper) -- 361
	local shown = math.min(#items, maxItems) -- 367
	do -- 367
		local j = 0 -- 368
		while j < shown do -- 368
			lines[#lines + 1] = mapper(items[j + 1], j) -- 369
			j = j + 1 -- 368
		end -- 368
	end -- 368
	if #items > shown then -- 368
		lines[#lines + 1] = ("  ... " .. tostring(#items - shown)) .. " more omitted" -- 372
	end -- 372
end -- 372
function formatHistorySummary(history) -- 447
	if #history == 0 then -- 447
		return "No previous actions." -- 449
	end -- 449
	local actions = history -- 451
	local lines = {} -- 452
	lines[#lines + 1] = "" -- 453
	do -- 453
		local i = 0 -- 454
		while i < #actions do -- 454
			local action = actions[i + 1] -- 455
			lines[#lines + 1] = ("Action " .. tostring(i + 1)) .. ":" -- 456
			lines[#lines + 1] = "- Tool: " .. action.tool -- 457
			lines[#lines + 1] = "- Reason: " .. action.reason -- 458
			if action.params and type(action.params) == "table" and ({next(action.params)}) ~= nil then -- 458
				lines[#lines + 1] = "- Parameters:" -- 460
				for key in pairs(action.params) do -- 461
					lines[#lines + 1] = (("  - " .. key) .. ": ") .. summarizeUnknown(action.params[key], 2000) -- 462
				end -- 462
			end -- 462
			if action.result and type(action.result) == "table" then -- 462
				local result = action.result -- 466
				local success = result.success == true -- 467
				if action.tool == "build" then -- 467
					if not success and type(result.message) == "string" then -- 467
						lines[#lines + 1] = "- Result: Failed" -- 470
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 1200) -- 471
					elseif type(result.messages) == "table" then -- 471
						local messages = result.messages -- 473
						local successCount = 0 -- 474
						local failedCount = 0 -- 475
						do -- 475
							local j = 0 -- 476
							while j < #messages do -- 476
								if messages[j + 1].success == true then -- 476
									successCount = successCount + 1 -- 477
								else -- 477
									failedCount = failedCount + 1 -- 478
								end -- 478
								j = j + 1 -- 476
							end -- 476
						end -- 476
						lines[#lines + 1] = "- Result: " .. (failedCount > 0 and "Completed With Errors" or "Success") -- 480
						lines[#lines + 1] = ((("- Build summary: " .. tostring(successCount)) .. " succeeded, ") .. tostring(failedCount)) .. " failed" -- 481
						if #messages > 0 then -- 481
							lines[#lines + 1] = "- Build details:" -- 483
							local shown = math.min(#messages, 12) -- 484
							do -- 484
								local j = 0 -- 485
								while j < shown do -- 485
									local item = messages[j + 1] -- 486
									local file = type(item.file) == "string" and item.file or "(unknown)" -- 487
									if item.success == true then -- 487
										lines[#lines + 1] = (("  " .. tostring(j + 1)) .. ". OK ") .. file -- 489
									else -- 489
										local message = type(item.message) == "string" and truncateText(item.message, 400) or "build failed" -- 491
										lines[#lines + 1] = (((("  " .. tostring(j + 1)) .. ". FAIL ") .. file) .. ": ") .. message -- 494
									end -- 494
									j = j + 1 -- 485
								end -- 485
							end -- 485
							if #messages > shown then -- 485
								lines[#lines + 1] = ("  ... " .. tostring(#messages - shown)) .. " more omitted" -- 498
							end -- 498
						end -- 498
					else -- 498
						lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 502
					end -- 502
				elseif action.tool == "read_file" or action.tool == "read_file_range" then -- 502
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 505
					if success and type(result.content) == "string" then -- 505
						lines[#lines + 1] = "- Content: " .. limitReadContentForHistory(result.content, action.tool) -- 507
						if result.startLine ~= nil or result.endLine ~= nil or result.totalLines ~= nil then -- 507
							lines[#lines + 1] = (((("- Range: " .. (result.startLine ~= nil and tostring(result.startLine) or "?")) .. "-") .. (result.endLine ~= nil and tostring(result.endLine) or "?")) .. " / total ") .. (result.totalLines ~= nil and tostring(result.totalLines) or "?") -- 509
						end -- 509
					elseif not success and type(result.message) == "string" then -- 509
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 600) -- 514
					end -- 514
				elseif action.tool == "grep_files" then -- 514
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 517
					if success and type(result.results) == "table" then -- 517
						local matches = result.results -- 519
						local totalMatches = type(result.totalResults) == "number" and result.totalResults or #matches -- 520
						lines[#lines + 1] = "- Matches: " .. tostring(totalMatches) -- 523
						if type(result.offset) == "number" and type(result.limit) == "number" then -- 523
							lines[#lines + 1] = (("- Page: offset=" .. tostring(result.offset)) .. " limit=") .. tostring(result.limit) -- 525
						end -- 525
						if result.hasMore == true and result.nextOffset ~= nil then -- 525
							lines[#lines + 1] = "- More: continue with offset=" .. tostring(result.nextOffset) -- 528
						end -- 528
						if type(result.groupedResults) == "table" then -- 528
							local groups = result.groupedResults -- 531
							lines[#lines + 1] = "- Groups:" -- 532
							pushLimitedMatches( -- 533
								lines, -- 533
								groups, -- 533
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 533
								function(g, index) -- 533
									local file = type(g.file) == "string" and g.file or "" -- 534
									local total = g.totalMatches ~= nil and tostring(g.totalMatches) or "?" -- 535
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. ": ") .. total) .. " matches" -- 536
								end -- 533
							) -- 533
						else -- 533
							pushLimitedMatches( -- 539
								lines, -- 539
								matches, -- 539
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 539
								function(m, index) -- 539
									local file = type(m.file) == "string" and m.file or "" -- 540
									local line = m.line ~= nil and tostring(m.line) or "" -- 541
									local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 542
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 543
								end -- 539
							) -- 539
						end -- 539
					end -- 539
				elseif action.tool == "search_dora_api" then -- 539
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 548
					if success and type(result.results) == "table" then -- 548
						local hits = result.results -- 550
						local totalHits = type(result.totalResults) == "number" and result.totalResults or #hits -- 551
						lines[#lines + 1] = "- Matches: " .. tostring(totalHits) -- 554
						pushLimitedMatches( -- 555
							lines, -- 555
							hits, -- 555
							HISTORY_SEARCH_DORA_API_MAX_MATCHES, -- 555
							function(m, index) -- 555
								local file = type(m.file) == "string" and m.file or "" -- 556
								local line = m.line ~= nil and tostring(m.line) or "" -- 557
								local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 558
								return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 559
							end -- 555
						) -- 555
					end -- 555
				elseif action.tool == "edit_file" then -- 555
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 563
					if success then -- 563
						if result.mode ~= nil then -- 563
							lines[#lines + 1] = "- Mode: " .. tostring(result.mode) -- 566
						end -- 566
						if result.replaced ~= nil then -- 566
							lines[#lines + 1] = "- Replaced: " .. tostring(result.replaced) -- 569
						end -- 569
					end -- 569
				elseif action.tool == "glob_files" then -- 569
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 573
					if success and type(result.files) == "table" then -- 573
						local files = result.files -- 575
						local totalEntries = type(result.totalEntries) == "number" and result.totalEntries or #files -- 576
						lines[#lines + 1] = "- Entries: " .. tostring(totalEntries) -- 579
						lines[#lines + 1] = "- Directory structure:" -- 580
						if #files > 0 then -- 580
							local shown = math.min(#files, HISTORY_LIST_FILES_MAX_ENTRIES) -- 582
							do -- 582
								local j = 0 -- 583
								while j < shown do -- 583
									lines[#lines + 1] = "  " .. files[j + 1] -- 584
									j = j + 1 -- 583
								end -- 583
							end -- 583
							if #files > shown then -- 583
								lines[#lines + 1] = ("  ... " .. tostring(#files - shown)) .. " more omitted" -- 587
							end -- 587
						else -- 587
							lines[#lines + 1] = "  (Empty or inaccessible directory)" -- 590
						end -- 590
					end -- 590
				else -- 590
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 594
					lines[#lines + 1] = "- Detail: " .. truncateText( -- 595
						toJson(result), -- 595
						4000 -- 595
					) -- 595
				end -- 595
			elseif action.result ~= nil then -- 595
				lines[#lines + 1] = "- Result: " .. summarizeUnknown(action.result, 3000) -- 598
			else -- 598
				lines[#lines + 1] = "- Result: pending" -- 600
			end -- 600
			if i < #actions - 1 then -- 600
				lines[#lines + 1] = "" -- 602
			end -- 602
			i = i + 1 -- 454
		end -- 454
	end -- 454
	return table.concat(lines, "\n") -- 604
end -- 604
function persistHistoryState(shared) -- 607
	shared.memory.compressor:getStorage():writeSessionState(shared.history, shared.memory.lastConsolidatedIndex) -- 608
end -- 608
HISTORY_READ_FILE_MAX_CHARS = 12000 -- 115
HISTORY_READ_FILE_MAX_LINES = 300 -- 116
local READ_FILE_DEFAULT_LIMIT = 300 -- 117
HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 118
HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 119
HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 120
local DECISION_HISTORY_MAX_CHARS = 16000 -- 121
local SEARCH_DORA_API_LIMIT_MAX = 20 -- 122
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 123
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 124
local SEARCH_PREVIEW_CONTEXT = 80 -- 125
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
local function utf8TakeTail(text, maxChars) -- 200
	if maxChars <= 0 or text == "" then -- 200
		return "" -- 201
	end -- 201
	local charLen = utf8.len(text) -- 202
	if charLen == false or charLen <= maxChars then -- 202
		return text -- 203
	end -- 203
	local startChar = math.max(1, charLen - maxChars + 1) -- 204
	local startPos = utf8.offset(text, startChar) -- 205
	if startPos == nil then -- 205
		return text -- 206
	end -- 206
	return string.sub(text, startPos) -- 207
end -- 200
local function getReplyLanguageDirective(shared) -- 222
	return shared.useChineseResponse and "Use Simplified Chinese for natural-language fields (reason/message/summary)." or "Use English for natural-language fields (reason/message/summary)." -- 223
end -- 222
local function summarizeEditTextParamForHistory(value, key) -- 249
	if type(value) ~= "string" then -- 249
		return nil -- 250
	end -- 250
	local text = value -- 251
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 252
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 253
end -- 249
local function sanitizeReadResultForHistory(tool, result) -- 261
	if tool ~= "read_file" and tool ~= "read_file_range" or result.success ~= true or type(result.content) ~= "string" then -- 261
		return result -- 263
	end -- 263
	local clone = {} -- 265
	for key in pairs(result) do -- 266
		clone[key] = result[key] -- 267
	end -- 267
	clone.content = limitReadContentForHistory(result.content, tool) -- 269
	return clone -- 270
end -- 261
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 273
	local shown = math.min(#items, maxItems) -- 277
	local out = {} -- 278
	do -- 278
		local i = 0 -- 279
		while i < shown do -- 279
			local row = items[i + 1] -- 280
			out[#out + 1] = { -- 281
				file = row.file, -- 282
				line = row.line, -- 283
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 284
			} -- 284
			i = i + 1 -- 279
		end -- 279
	end -- 279
	return out -- 289
end -- 273
local function sanitizeSearchResultForHistory(tool, result) -- 292
	if result.success ~= true or type(result.results) ~= "table" then -- 292
		return result -- 296
	end -- 296
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 296
		return result -- 297
	end -- 297
	local clone = {} -- 298
	for key in pairs(result) do -- 299
		clone[key] = result[key] -- 300
	end -- 300
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 302
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 303
	if tool == "grep_files" and type(result.groupedResults) == "table" then -- 303
		local grouped = result.groupedResults -- 308
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 309
		local sanitizedGroups = {} -- 310
		do -- 310
			local i = 0 -- 311
			while i < shown do -- 311
				local row = grouped[i + 1] -- 312
				sanitizedGroups[#sanitizedGroups + 1] = { -- 313
					file = row.file, -- 314
					totalMatches = row.totalMatches, -- 315
					matches = type(row.matches) == "table" and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 316
				} -- 316
				i = i + 1 -- 311
			end -- 311
		end -- 311
		clone.groupedResults = sanitizedGroups -- 321
	end -- 321
	return clone -- 323
end -- 292
local function sanitizeListFilesResultForHistory(result) -- 326
	if result.success ~= true or type(result.files) ~= "table" then -- 326
		return result -- 327
	end -- 327
	local clone = {} -- 328
	for key in pairs(result) do -- 329
		clone[key] = result[key] -- 330
	end -- 330
	local files = result.files -- 332
	clone.files = __TS__ArraySlice(files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 333
	return clone -- 334
end -- 326
local function sanitizeActionParamsForHistory(tool, params) -- 337
	if tool ~= "edit_file" then -- 337
		return params -- 338
	end -- 338
	local clone = {} -- 339
	for key in pairs(params) do -- 340
		if key == "old_str" then -- 340
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 342
		elseif key == "new_str" then -- 342
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 344
		else -- 344
			clone[key] = params[key] -- 346
		end -- 346
	end -- 346
	return clone -- 349
end -- 337
local function trimPromptContext(text, maxChars, label) -- 352
	if #text <= maxChars then -- 352
		return text -- 353
	end -- 353
	local keepHead = math.max( -- 354
		0, -- 354
		math.floor(maxChars * 0.35) -- 354
	) -- 354
	local keepTail = math.max(0, maxChars - keepHead) -- 355
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 356
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 357
	return (((((("[history summary truncated for " .. label) .. "; showing head and tail within ") .. tostring(maxChars)) .. " chars]\n") .. head) .. "\n...\n") .. tail -- 358
end -- 352
local function formatHistorySummaryForDecision(history) -- 376
	return trimPromptContext( -- 377
		formatHistorySummary(history), -- 377
		DECISION_HISTORY_MAX_CHARS, -- 377
		"decision" -- 377
	) -- 377
end -- 376
local function getDecisionSystemPrompt() -- 380
	return "You are a coding assistant that helps modify and navigate code." -- 381
end -- 380
local function getDecisionToolDefinitions() -- 384
	return "Available tools:\n1. read_file: Read content from a file with pagination\n1b. read_file_range: Read specific line range from a file\n2. edit_file: Make changes to a file\n3. delete_file: Remove a file\n4. grep_files: Search text patterns inside files\n5. glob_files: Enumerate files under a directory with optional glob filters\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn\n8. finish: End and summarize" -- 385
end -- 384
local function maybeCompressHistory(shared) -- 397
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 397
		local ____shared_0 = shared -- 398
		local memory = ____shared_0.memory -- 398
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 399
		local changed = false -- 400
		do -- 400
			local round = 0 -- 401
			while round < maxRounds do -- 401
				if not memory.compressor:shouldCompress( -- 401
					shared.userQuery, -- 403
					shared.history, -- 404
					memory.lastConsolidatedIndex, -- 405
					getDecisionSystemPrompt(), -- 406
					getDecisionToolDefinitions(), -- 407
					formatHistorySummary -- 408
				) then -- 408
					return ____awaiter_resolve(nil) -- 408
				end -- 408
				local result = __TS__Await(memory.compressor:compress( -- 412
					shared.history, -- 413
					memory.lastConsolidatedIndex, -- 414
					shared.llmOptions, -- 415
					formatHistorySummary, -- 416
					shared.llmMaxTry, -- 417
					shared.decisionMode -- 418
				)) -- 418
				if not (result and result.success and result.compressedCount > 0) then -- 418
					if changed then -- 418
						persistHistoryState(shared) -- 422
					end -- 422
					return ____awaiter_resolve(nil) -- 422
				end -- 422
				memory.lastConsolidatedIndex = memory.lastConsolidatedIndex + result.compressedCount -- 426
				changed = true -- 427
				Log( -- 428
					"Info", -- 428
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " history records (round ") .. tostring(round + 1)) .. ")" -- 428
				) -- 428
				round = round + 1 -- 401
			end -- 401
		end -- 401
		if changed then -- 401
			persistHistoryState(shared) -- 431
		end -- 431
	end) -- 431
end -- 397
local function isKnownToolName(name) -- 435
	return name == "read_file" or name == "read_file_range" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 436
end -- 435
local function extractYAMLFromText(text) -- 614
	local source = __TS__StringTrim(text) -- 615
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 616
	if yamlFencePos >= 0 then -- 616
		local from = yamlFencePos + #"```yaml" -- 618
		local ____end = (string.find( -- 619
			source, -- 619
			"```", -- 619
			math.max(from + 1, 1), -- 619
			true -- 619
		) or 0) - 1 -- 619
		if ____end > from then -- 619
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 620
		end -- 620
	end -- 620
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 622
	if ymlFencePos >= 0 then -- 622
		local from = ymlFencePos + #"```yml" -- 624
		local ____end = (string.find( -- 625
			source, -- 625
			"```", -- 625
			math.max(from + 1, 1), -- 625
			true -- 625
		) or 0) - 1 -- 625
		if ____end > from then -- 625
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 626
		end -- 626
	end -- 626
	local fencePos = (string.find(source, "```", nil, true) or 0) - 1 -- 628
	if fencePos >= 0 then -- 628
		local firstLineEnd = (string.find( -- 630
			source, -- 630
			"\n", -- 630
			math.max(fencePos + 1, 1), -- 630
			true -- 630
		) or 0) - 1 -- 630
		local ____end = (string.find( -- 631
			source, -- 631
			"```", -- 631
			math.max((firstLineEnd >= 0 and firstLineEnd + 1 or fencePos + 3) + 1, 1), -- 631
			true -- 631
		) or 0) - 1 -- 631
		if firstLineEnd >= 0 and ____end > firstLineEnd then -- 631
			return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, ____end)) -- 633
		end -- 633
	end -- 633
	return source -- 636
end -- 614
local function parseYAMLObjectFromText(text) -- 639
	local yamlText = extractYAMLFromText(text) -- 640
	local obj, err = yaml.parse(yamlText) -- 641
	if obj == nil or type(obj) ~= "table" then -- 641
		return { -- 643
			success = false, -- 643
			message = "invalid yaml: " .. tostring(err) -- 643
		} -- 643
	end -- 643
	return {success = true, obj = obj} -- 645
end -- 639
local function llm(shared, messages) -- 657
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 657
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 658
		if res.success then -- 658
			local ____opt_5 = res.response.choices -- 658
			local ____opt_3 = ____opt_5 and ____opt_5[1] -- 658
			local ____opt_1 = ____opt_3 and ____opt_3.message -- 658
			local text = ____opt_1 and ____opt_1.content -- 660
			if text then -- 660
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 660
			else -- 660
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 660
			end -- 660
		else -- 660
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 660
		end -- 660
	end) -- 660
end -- 657
local function llmStream(shared, messages) -- 671
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 671
		local text = "" -- 672
		local cancelledReason -- 673
		local done = false -- 674
		if shared.stopToken.stopped then -- 674
			return ____awaiter_resolve( -- 674
				nil, -- 674
				{ -- 677
					success = false, -- 677
					message = getCancelledReason(shared), -- 677
					text = text -- 677
				} -- 677
			) -- 677
		end -- 677
		done = false -- 679
		cancelledReason = nil -- 680
		text = "" -- 681
		callLLMStream( -- 682
			messages, -- 683
			shared.llmOptions, -- 684
			{ -- 685
				id = nil, -- 686
				stopToken = shared.stopToken, -- 687
				onData = function(data) -- 688
					if shared.stopToken.stopped then -- 688
						return true -- 689
					end -- 689
					local choice = data.choices and data.choices[1] -- 690
					local delta = choice and choice.delta -- 691
					if delta and type(delta.content) == "string" then -- 691
						local content = delta.content -- 693
						text = text .. content -- 694
						emitAgentEvent(shared, { -- 695
							type = "summary_stream", -- 696
							sessionId = shared.sessionId, -- 697
							taskId = shared.taskId, -- 698
							textDelta = content, -- 699
							fullText = text -- 700
						}) -- 700
						local res = json.encode({name = "LLMStream", content = content}) -- 702
						if res ~= nil then -- 702
							emit("AppWS", "Send", res) -- 704
						end -- 704
					end -- 704
					return false -- 707
				end, -- 688
				onCancel = function(reason) -- 709
					cancelledReason = reason -- 710
					done = true -- 711
				end, -- 709
				onDone = function() -- 713
					done = true -- 714
				end -- 713
			}, -- 713
			shared.llmConfig -- 717
		) -- 717
		__TS__Await(__TS__New( -- 720
			__TS__Promise, -- 720
			function(____, resolve) -- 720
				Director.systemScheduler:schedule(once(function() -- 721
					wait(function() return done or shared.stopToken.stopped end) -- 722
					resolve(nil) -- 723
				end)) -- 721
			end -- 720
		)) -- 720
		if shared.stopToken.stopped then -- 720
			cancelledReason = getCancelledReason(shared) -- 727
		end -- 727
		if not cancelledReason and text == "" then -- 727
			cancelledReason = "empty LLM output" -- 731
		end -- 731
		if cancelledReason then -- 731
			return ____awaiter_resolve(nil, {success = false, message = cancelledReason, text = text}) -- 731
		end -- 731
		return ____awaiter_resolve(nil, {success = true, text = text}) -- 731
	end) -- 731
end -- 671
local function parseDecisionObject(rawObj) -- 738
	if type(rawObj.tool) ~= "string" then -- 738
		return {success = false, message = "missing tool"} -- 739
	end -- 739
	local tool = rawObj.tool -- 740
	if not isKnownToolName(tool) then -- 740
		return {success = false, message = "unknown tool: " .. tool} -- 742
	end -- 742
	local reason = type(rawObj.reason) == "string" and rawObj.reason or "" -- 744
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 745
	return {success = true, tool = tool, reason = reason, params = params} -- 746
end -- 738
local function getDecisionPath(params) -- 749
	if type(params.path) == "string" then -- 749
		return __TS__StringTrim(params.path) -- 750
	end -- 750
	if type(params.target_file) == "string" then -- 750
		return __TS__StringTrim(params.target_file) -- 751
	end -- 751
	return "" -- 752
end -- 749
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 755
	local num = __TS__Number(value) -- 756
	if not __TS__NumberIsFinite(num) then -- 756
		num = fallback -- 757
	end -- 757
	num = math.floor(num) -- 758
	if num < minValue then -- 758
		num = minValue -- 759
	end -- 759
	if maxValue ~= nil and num > maxValue then -- 759
		num = maxValue -- 760
	end -- 760
	return num -- 761
end -- 755
local function validateDecision(tool, params, history) -- 764
	if tool == "finish" then -- 764
		return {success = true, params = params} -- 769
	end -- 769
	if tool == "read_file" then -- 769
		local path = getDecisionPath(params) -- 772
		if path == "" then -- 772
			return {success = false, message = "read_file requires path"} -- 773
		end -- 773
		params.path = path -- 774
		params.offset = clampIntegerParam(params.offset, 1, 1) -- 775
		params.limit = clampIntegerParam(params.limit, READ_FILE_DEFAULT_LIMIT, 1) -- 776
		return {success = true, params = params} -- 777
	end -- 777
	if tool == "read_file_range" then -- 777
		local path = getDecisionPath(params) -- 781
		if path == "" then -- 781
			return {success = false, message = "read_file_range requires path"} -- 782
		end -- 782
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 783
		local ____params_endLine_7 = params.endLine -- 784
		if ____params_endLine_7 == nil then -- 784
			____params_endLine_7 = startLine -- 784
		end -- 784
		local endLineRaw = ____params_endLine_7 -- 784
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 785
		params.path = path -- 786
		params.startLine = startLine -- 787
		params.endLine = endLine -- 788
		return {success = true, params = params} -- 789
	end -- 789
	if tool == "edit_file" then -- 789
		local path = getDecisionPath(params) -- 793
		if path == "" then -- 793
			return {success = false, message = "edit_file requires path"} -- 794
		end -- 794
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 795
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 796
		if oldStr == newStr then -- 796
			return {success = false, message = "edit_file old_str and new_str must be different"} -- 798
		end -- 798
		params.path = path -- 800
		params.old_str = oldStr -- 801
		params.new_str = newStr -- 802
		return {success = true, params = params} -- 803
	end -- 803
	if tool == "delete_file" then -- 803
		local targetFile = getDecisionPath(params) -- 807
		if targetFile == "" then -- 807
			return {success = false, message = "delete_file requires target_file"} -- 808
		end -- 808
		params.target_file = targetFile -- 809
		return {success = true, params = params} -- 810
	end -- 810
	if tool == "grep_files" then -- 810
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 814
		if pattern == "" then -- 814
			return {success = false, message = "grep_files requires pattern"} -- 815
		end -- 815
		params.pattern = pattern -- 816
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 817
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 818
		return {success = true, params = params} -- 819
	end -- 819
	if tool == "search_dora_api" then -- 819
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 823
		if pattern == "" then -- 823
			return {success = false, message = "search_dora_api requires pattern"} -- 824
		end -- 824
		params.pattern = pattern -- 825
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 826
		return {success = true, params = params} -- 827
	end -- 827
	if tool == "glob_files" then -- 827
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 831
		return {success = true, params = params} -- 832
	end -- 832
	if tool == "build" then -- 832
		local path = getDecisionPath(params) -- 836
		if path ~= "" then -- 836
			params.path = path -- 838
		end -- 838
		return {success = true, params = params} -- 840
	end -- 840
	return {success = true, params = params} -- 843
end -- 764
local function buildDecisionToolSchema() -- 846
	return {{type = "function", ["function"] = {name = "next_step", description = "Choose the next coding action for the agent.", parameters = {type = "object", properties = {tool = {type = "string", enum = { -- 847
		"read_file", -- 858
		"read_file_range", -- 859
		"edit_file", -- 860
		"delete_file", -- 861
		"grep_files", -- 862
		"search_dora_api", -- 863
		"glob_files", -- 864
		"build", -- 865
		"finish" -- 866
	}}, reason = {type = "string", description = "Explain why this is the next best action."}, params = {type = "object", description = "Shallow parameter object for the selected tool.", properties = { -- 866
		path = {type = "string"}, -- 877
		target_file = {type = "string"}, -- 878
		old_str = {type = "string"}, -- 879
		new_str = {type = "string"}, -- 880
		pattern = {type = "string"}, -- 881
		globs = {type = "array", items = {type = "string"}}, -- 882
		useRegex = {type = "boolean"}, -- 886
		caseSensitive = {type = "boolean"}, -- 887
		offset = {type = "number"}, -- 888
		groupByFile = {type = "boolean"}, -- 889
		docSource = {type = "string", enum = {"api", "tutorial"}}, -- 890
		programmingLanguage = {type = "string", enum = { -- 894
			"ts", -- 896
			"tsx", -- 896
			"lua", -- 896
			"yue", -- 896
			"teal", -- 896
			"tl", -- 896
			"wa" -- 896
		}}, -- 896
		limit = {type = "number"}, -- 898
		startLine = {type = "number"}, -- 899
		endLine = {type = "number"}, -- 900
		maxEntries = {type = "number"} -- 901
	}}}, required = {"tool", "reason", "params"}}}}} -- 901
end -- 846
local function buildDecisionPrompt(shared, userQuery, historyText, memoryContext, agentPrompt) -- 911
	return ((((((((((agentPrompt or DEFAULT_AGENT_PROMPT) .. "\nGiven the request and action history, decide which tool to use next.\n\n") .. memoryContext) .. "\n\nUser request: ") .. userQuery) .. "\n\nHere are the actions you performed:\n") .. historyText) .. "\n\nAvailable tools:\n1. read_file: Read content from a file with pagination\n\t- Parameters: path (workspace-relative), offset(optional), limit(optional)\n\t- Prefer small reads and continue with a new offset (>= 1) when needed.\n1b. read_file_range: Read specific line range from a file\n\t- Parameters: path, startLine, endLine\n\t- Line starts with 1.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine docs and tutorials\n\t- Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional)\n\t- `docSource` defaults to `api`. Use `tutorial` to search teaching docs.\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= ") .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".\n\n7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- After one build completes, do not run build again unless files were edited/deleted. Read the result and then finish or take corrective action.\n\n8. finish: End and summarize\n\t- Parameters: {}\n\nDecision rules:\n- Choose exactly one next action.\n- Keep params shallow and valid for the selected tool.\n- Prefer reading/searching before editing when information is missing.\n- After any search tool returns candidate files or docs, use read_file or read_file_range to inspect search result details instead of repeatedly broadening search.\n- Use glob_files to discover candidate files. Use grep_files only when you need to search file contents.\n- If the user asked a question, prefer finishing only after you can answer it in the final response.\n") .. getReplyLanguageDirective(shared) -- 912
end -- 911
local function replaceAllAndCount(text, oldStr, newStr) -- 981
	if oldStr == "" then -- 981
		return {content = text, replaced = 0} -- 982
	end -- 982
	local count = 0 -- 983
	local from = 0 -- 984
	while true do -- 984
		local idx = (string.find( -- 986
			text, -- 986
			oldStr, -- 986
			math.max(from + 1, 1), -- 986
			true -- 986
		) or 0) - 1 -- 986
		if idx < 0 then -- 986
			break -- 987
		end -- 987
		count = count + 1 -- 988
		from = idx + #oldStr -- 989
	end -- 989
	if count == 0 then -- 989
		return {content = text, replaced = 0} -- 991
	end -- 991
	return { -- 992
		content = table.concat( -- 993
			__TS__StringSplit(text, oldStr), -- 993
			newStr or "," -- 993
		), -- 993
		replaced = count -- 994
	} -- 994
end -- 981
local MainDecisionAgent = __TS__Class() -- 998
MainDecisionAgent.name = "MainDecisionAgent" -- 998
__TS__ClassExtends(MainDecisionAgent, Node) -- 998
function MainDecisionAgent.prototype.prep(self, shared) -- 999
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 999
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 999
			return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 999
		end -- 999
		__TS__Await(maybeCompressHistory(shared)) -- 1008
		return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 1008
	end) -- 1008
end -- 999
function MainDecisionAgent.prototype.getSystemPrompt(self) -- 1017
	return getDecisionSystemPrompt() -- 1018
end -- 1017
function MainDecisionAgent.prototype.getToolDefinitions(self) -- 1021
	return getDecisionToolDefinitions() -- 1022
end -- 1021
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, prompt, lastError) -- 1025
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1025
		if shared.stopToken.stopped then -- 1025
			return ____awaiter_resolve( -- 1025
				nil, -- 1025
				{ -- 1031
					success = false, -- 1031
					message = getCancelledReason(shared) -- 1031
				} -- 1031
			) -- 1031
		end -- 1031
		Log( -- 1033
			"Info", -- 1033
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1033
		) -- 1033
		local tools = buildDecisionToolSchema() -- 1034
		local messages = { -- 1035
			{ -- 1036
				role = "system", -- 1037
				content = table.concat( -- 1038
					{ -- 1038
						"You are a coding assistant that must decide the next action by calling the next_step tool exactly once.", -- 1039
						"Do not answer with plain text.", -- 1040
						getReplyLanguageDirective(shared) -- 1041
					}, -- 1041
					"\n" -- 1042
				) -- 1042
			}, -- 1042
			{role = "user", content = lastError and ((prompt .. "\n\nPrevious tool call was invalid (") .. lastError) .. "). Retry with one valid next_step tool call only." or prompt} -- 1044
		} -- 1044
		local res = __TS__Await(callLLM( -- 1051
			messages, -- 1051
			__TS__ObjectAssign({}, shared.llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "next_step"}}}), -- 1051
			shared.stopToken, -- 1055
			shared.llmConfig -- 1055
		)) -- 1055
		if shared.stopToken.stopped then -- 1055
			return ____awaiter_resolve( -- 1055
				nil, -- 1055
				{ -- 1057
					success = false, -- 1057
					message = getCancelledReason(shared) -- 1057
				} -- 1057
			) -- 1057
		end -- 1057
		if not res.success then -- 1057
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1060
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1060
		end -- 1060
		local choice = res.response.choices and res.response.choices[1] -- 1063
		local message = choice and choice.message -- 1064
		local toolCalls = message and message.tool_calls -- 1065
		local toolCall = toolCalls and toolCalls[1] -- 1066
		local fn = toolCall and toolCall["function"] -- 1067
		local messageContent = message and type(message.content) == "string" and message.content or nil -- 1068
		Log( -- 1069
			"Info", -- 1069
			(((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0) -- 1069
		) -- 1069
		if not fn or fn.name ~= "next_step" then -- 1069
			Log("Error", "[CodingAgent] missing next_step tool call") -- 1071
			return ____awaiter_resolve(nil, {success = false, message = "missing next_step tool call", raw = messageContent}) -- 1071
		end -- 1071
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1078
		Log( -- 1079
			"Info", -- 1079
			(("[CodingAgent] tool-calling function=" .. fn.name) .. " args_len=") .. tostring(#argsText) -- 1079
		) -- 1079
		if __TS__StringTrim(argsText) == "" then -- 1079
			Log("Error", "[CodingAgent] empty next_step tool arguments") -- 1081
			return ____awaiter_resolve(nil, {success = false, message = "empty next_step tool arguments"}) -- 1081
		end -- 1081
		local rawObj, err = json.decode(argsText) -- 1084
		if err ~= nil or rawObj == nil or type(rawObj) ~= "table" then -- 1084
			Log( -- 1086
				"Error", -- 1086
				"[CodingAgent] invalid next_step tool arguments JSON: " .. tostring(err) -- 1086
			) -- 1086
			return ____awaiter_resolve( -- 1086
				nil, -- 1086
				{ -- 1087
					success = false, -- 1088
					message = "invalid next_step tool arguments: " .. tostring(err), -- 1089
					raw = argsText -- 1090
				} -- 1090
			) -- 1090
		end -- 1090
		local decision = parseDecisionObject(rawObj) -- 1093
		if not decision.success then -- 1093
			Log("Error", "[CodingAgent] invalid next_step tool arguments schema: " .. decision.message) -- 1095
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1095
		end -- 1095
		local validation = validateDecision(decision.tool, decision.params, shared.history) -- 1102
		if not validation.success then -- 1102
			Log("Error", "[CodingAgent] invalid next_step tool arguments values: " .. validation.message) -- 1104
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1104
		end -- 1104
		decision.params = validation.params -- 1111
		Log( -- 1112
			"Info", -- 1112
			(("[CodingAgent] tool-calling selected tool=" .. decision.tool) .. " reason_len=") .. tostring(#decision.reason) -- 1112
		) -- 1112
		return ____awaiter_resolve(nil, decision) -- 1112
	end) -- 1112
end -- 1025
function MainDecisionAgent.prototype.exec(self, input) -- 1116
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1116
		local shared = input.shared -- 1117
		if shared.stopToken.stopped then -- 1117
			return ____awaiter_resolve( -- 1117
				nil, -- 1117
				{ -- 1119
					success = false, -- 1119
					message = getCancelledReason(shared) -- 1119
				} -- 1119
			) -- 1119
		end -- 1119
		local memory = shared.memory -- 1119
		local memoryContext = memory.compressor:getStorage():getMemoryContext() -- 1124
		local agentPrompt = memory.compressor:getStorage():readAgentPrompt() -- 1127
		local uncompressedHistory = __TS__ArraySlice(input.history, memory.lastConsolidatedIndex) -- 1132
		local historyText = formatHistorySummaryForDecision(uncompressedHistory) -- 1133
		local prompt = buildDecisionPrompt( -- 1135
			input.shared, -- 1135
			input.userQuery, -- 1135
			historyText, -- 1135
			memoryContext, -- 1135
			agentPrompt -- 1135
		) -- 1135
		if shared.decisionMode == "tool_calling" then -- 1135
			Log( -- 1138
				"Info", -- 1138
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " history=") .. tostring(#uncompressedHistory) -- 1138
			) -- 1138
			local lastError = "tool calling validation failed" -- 1139
			local lastRaw = "" -- 1140
			do -- 1140
				local attempt = 0 -- 1141
				while attempt < shared.llmMaxTry do -- 1141
					Log( -- 1142
						"Info", -- 1142
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1142
					) -- 1142
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, prompt, attempt > 0 and lastError or nil)) -- 1143
					if shared.stopToken.stopped then -- 1143
						return ____awaiter_resolve( -- 1143
							nil, -- 1143
							{ -- 1149
								success = false, -- 1149
								message = getCancelledReason(shared) -- 1149
							} -- 1149
						) -- 1149
					end -- 1149
					if decision.success then -- 1149
						return ____awaiter_resolve(nil, decision) -- 1149
					end -- 1149
					lastError = decision.message -- 1154
					lastRaw = decision.raw or "" -- 1155
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1156
					attempt = attempt + 1 -- 1141
				end -- 1141
			end -- 1141
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1158
			return ____awaiter_resolve( -- 1158
				nil, -- 1158
				{ -- 1159
					success = false, -- 1159
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1159
				} -- 1159
			) -- 1159
		end -- 1159
		local yamlPrompt = prompt .. "\n\nRespond with one YAML object:\n```yaml\n'tool: \"edit_file\"\nreason: |-\n\tA readable multi-line explanation is allowed.\n\tKeep indentation consistent.\nparams:\n\tpath: \"relative/path.ts\"\n\told_str: |-\n\t\tfunction oldName() {\n\t\t\tprint(\"old\");\n\t\t}\n\tnew_str: |-\n\t\tfunction newName() {\n\t\t\tprint(\"hello\");\n\t\t}\n```\nStrict YAML formatting rules:\n- Return YAML only, no prose before/after.\n- Use exactly one YAML object with keys: tool, reason, params.\n- Multi-line strings are allowed using block scalars (`|`, `|-`, `>`).\n- If using a block scalar, all content lines must be indented consistently with tabs.\n- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.\n- Keep params shallow and valid for the selected tool.\n- Use tabs for all indentation, never spaces.\nIf no more actions are needed, use tool: finish." -- 1162
		local lastError = "yaml validation failed" -- 1191
		local lastRaw = "" -- 1192
		do -- 1192
			local attempt = 0 -- 1193
			while attempt < shared.llmMaxTry do -- 1193
				do -- 1193
					local feedback = attempt > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only and keep YAML indentation strictly consistent." or "" -- 1194
					local messages = {{role = "user", content = yamlPrompt .. feedback}} -- 1197
					local llmRes = __TS__Await(llm(shared, messages)) -- 1198
					if shared.stopToken.stopped then -- 1198
						return ____awaiter_resolve( -- 1198
							nil, -- 1198
							{ -- 1200
								success = false, -- 1200
								message = getCancelledReason(shared) -- 1200
							} -- 1200
						) -- 1200
					end -- 1200
					if not llmRes.success then -- 1200
						lastError = llmRes.message -- 1203
						goto __continue210 -- 1204
					end -- 1204
					lastRaw = llmRes.text -- 1206
					local parsed = parseYAMLObjectFromText(llmRes.text) -- 1207
					if not parsed.success then -- 1207
						lastError = parsed.message -- 1209
						goto __continue210 -- 1210
					end -- 1210
					local decision = parseDecisionObject(parsed.obj) -- 1212
					if not decision.success then -- 1212
						lastError = decision.message -- 1214
						goto __continue210 -- 1215
					end -- 1215
					local validation = validateDecision(decision.tool, decision.params, input.history) -- 1217
					if not validation.success then -- 1217
						lastError = validation.message -- 1219
						goto __continue210 -- 1220
					end -- 1220
					decision.params = validation.params -- 1222
					return ____awaiter_resolve(nil, decision) -- 1222
				end -- 1222
				::__continue210:: -- 1222
				attempt = attempt + 1 -- 1193
			end -- 1193
		end -- 1193
		return ____awaiter_resolve( -- 1193
			nil, -- 1193
			{ -- 1225
				success = false, -- 1225
				message = (("cannot produce valid decision yaml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1225
			} -- 1225
		) -- 1225
	end) -- 1225
end -- 1116
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1228
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1228
		local result = execRes -- 1229
		if not result.success then -- 1229
			shared.error = result.message -- 1231
			return ____awaiter_resolve(nil, "error") -- 1231
		end -- 1231
		emitAgentEvent(shared, { -- 1234
			type = "decision_made", -- 1235
			sessionId = shared.sessionId, -- 1236
			taskId = shared.taskId, -- 1237
			step = shared.step + 1, -- 1238
			tool = result.tool, -- 1239
			reason = result.reason, -- 1240
			params = result.params -- 1241
		}) -- 1241
		shared.lastDecision = {tool = result.tool, reason = result.reason, params = result.params} -- 1243
		local ____shared_history_8 = shared.history -- 1243
		____shared_history_8[#____shared_history_8 + 1] = { -- 1248
			step = #shared.history + 1, -- 1249
			tool = result.tool, -- 1250
			reason = result.reason, -- 1251
			params = result.params, -- 1252
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1253
		} -- 1253
		persistHistoryState(shared) -- 1255
		return ____awaiter_resolve(nil, result.tool) -- 1255
	end) -- 1255
end -- 1228
local ReadFileAction = __TS__Class() -- 1260
ReadFileAction.name = "ReadFileAction" -- 1260
__TS__ClassExtends(ReadFileAction, Node) -- 1260
function ReadFileAction.prototype.prep(self, shared) -- 1261
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1261
		local last = shared.history[#shared.history] -- 1262
		if not last then -- 1262
			error( -- 1263
				__TS__New(Error, "no history"), -- 1263
				0 -- 1263
			) -- 1263
		end -- 1263
		emitAgentEvent(shared, { -- 1264
			type = "tool_started", -- 1265
			sessionId = shared.sessionId, -- 1266
			taskId = shared.taskId, -- 1267
			step = shared.step + 1, -- 1268
			tool = last.tool -- 1269
		}) -- 1269
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1271
		if __TS__StringTrim(path) == "" then -- 1271
			error( -- 1274
				__TS__New(Error, "missing path"), -- 1274
				0 -- 1274
			) -- 1274
		end -- 1274
		if last.tool == "read_file_range" then -- 1274
			local ____path_13 = path -- 1277
			local ____last_tool_14 = last.tool -- 1278
			local ____shared_workingDir_15 = shared.workingDir -- 1279
			local ____temp_16 = shared.useChineseResponse and "zh" or "en" -- 1280
			local ____last_params_startLine_9 = last.params.startLine -- 1282
			if ____last_params_startLine_9 == nil then -- 1282
				____last_params_startLine_9 = 1 -- 1282
			end -- 1282
			local ____TS__Number_result_12 = __TS__Number(____last_params_startLine_9) -- 1282
			local ____last_params_endLine_10 = last.params.endLine -- 1283
			if ____last_params_endLine_10 == nil then -- 1283
				____last_params_endLine_10 = last.params.startLine -- 1283
			end -- 1283
			local ____last_params_endLine_10_11 = ____last_params_endLine_10 -- 1283
			if ____last_params_endLine_10_11 == nil then -- 1283
				____last_params_endLine_10_11 = 1 -- 1283
			end -- 1283
			return ____awaiter_resolve( -- 1283
				nil, -- 1283
				{ -- 1276
					path = ____path_13, -- 1277
					tool = ____last_tool_14, -- 1278
					workDir = ____shared_workingDir_15, -- 1279
					docLanguage = ____temp_16, -- 1280
					range = { -- 1281
						startLine = ____TS__Number_result_12, -- 1282
						endLine = __TS__Number(____last_params_endLine_10_11) -- 1283
					} -- 1283
				} -- 1283
			) -- 1283
		end -- 1283
		local ____path_19 = path -- 1288
		local ____shared_workingDir_20 = shared.workingDir -- 1290
		local ____temp_21 = shared.useChineseResponse and "zh" or "en" -- 1291
		local ____last_params_offset_17 = last.params.offset -- 1292
		if ____last_params_offset_17 == nil then -- 1292
			____last_params_offset_17 = 1 -- 1292
		end -- 1292
		local ____TS__Number_result_22 = __TS__Number(____last_params_offset_17) -- 1292
		local ____last_params_limit_18 = last.params.limit -- 1293
		if ____last_params_limit_18 == nil then -- 1293
			____last_params_limit_18 = READ_FILE_DEFAULT_LIMIT -- 1293
		end -- 1293
		return ____awaiter_resolve( -- 1293
			nil, -- 1293
			{ -- 1287
				path = ____path_19, -- 1288
				tool = "read_file", -- 1289
				workDir = ____shared_workingDir_20, -- 1290
				docLanguage = ____temp_21, -- 1291
				offset = ____TS__Number_result_22, -- 1292
				limit = __TS__Number(____last_params_limit_18) -- 1293
			} -- 1293
		) -- 1293
	end) -- 1293
end -- 1261
function ReadFileAction.prototype.exec(self, input) -- 1297
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1297
		if input.tool == "read_file_range" and input.range then -- 1297
			return ____awaiter_resolve( -- 1297
				nil, -- 1297
				Tools.readFileRange( -- 1299
					input.workDir, -- 1299
					input.path, -- 1299
					input.range.startLine, -- 1299
					input.range.endLine, -- 1299
					input.docLanguage -- 1299
				) -- 1299
			) -- 1299
		end -- 1299
		return ____awaiter_resolve( -- 1299
			nil, -- 1299
			Tools.readFile( -- 1301
				input.workDir, -- 1302
				input.path, -- 1303
				__TS__Number(input.offset or 1), -- 1304
				__TS__Number(input.limit or READ_FILE_DEFAULT_LIMIT), -- 1305
				input.docLanguage -- 1306
			) -- 1306
		) -- 1306
	end) -- 1306
end -- 1297
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1310
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1310
		local result = execRes -- 1311
		local last = shared.history[#shared.history] -- 1312
		if last ~= nil then -- 1312
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1314
			emitAgentEvent(shared, { -- 1315
				type = "tool_finished", -- 1316
				sessionId = shared.sessionId, -- 1317
				taskId = shared.taskId, -- 1318
				step = shared.step + 1, -- 1319
				tool = last.tool, -- 1320
				result = last.result -- 1321
			}) -- 1321
		end -- 1321
		__TS__Await(maybeCompressHistory(shared)) -- 1324
		persistHistoryState(shared) -- 1325
		shared.step = shared.step + 1 -- 1326
		return ____awaiter_resolve(nil, "main") -- 1326
	end) -- 1326
end -- 1310
local SearchFilesAction = __TS__Class() -- 1331
SearchFilesAction.name = "SearchFilesAction" -- 1331
__TS__ClassExtends(SearchFilesAction, Node) -- 1331
function SearchFilesAction.prototype.prep(self, shared) -- 1332
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1332
		local last = shared.history[#shared.history] -- 1333
		if not last then -- 1333
			error( -- 1334
				__TS__New(Error, "no history"), -- 1334
				0 -- 1334
			) -- 1334
		end -- 1334
		emitAgentEvent(shared, { -- 1335
			type = "tool_started", -- 1336
			sessionId = shared.sessionId, -- 1337
			taskId = shared.taskId, -- 1338
			step = shared.step + 1, -- 1339
			tool = last.tool -- 1340
		}) -- 1340
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1340
	end) -- 1340
end -- 1332
function SearchFilesAction.prototype.exec(self, input) -- 1345
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1345
		local params = input.params -- 1346
		local ____Tools_searchFiles_36 = Tools.searchFiles -- 1347
		local ____input_workDir_29 = input.workDir -- 1348
		local ____temp_30 = params.path or "" -- 1349
		local ____temp_31 = params.pattern or "" -- 1350
		local ____params_globs_32 = params.globs -- 1351
		local ____params_useRegex_33 = params.useRegex -- 1352
		local ____params_caseSensitive_34 = params.caseSensitive -- 1353
		local ____math_max_25 = math.max -- 1356
		local ____math_floor_24 = math.floor -- 1356
		local ____params_limit_23 = params.limit -- 1356
		if ____params_limit_23 == nil then -- 1356
			____params_limit_23 = SEARCH_FILES_LIMIT_DEFAULT -- 1356
		end -- 1356
		local ____math_max_25_result_35 = ____math_max_25( -- 1356
			1, -- 1356
			____math_floor_24(__TS__Number(____params_limit_23)) -- 1356
		) -- 1356
		local ____math_max_28 = math.max -- 1357
		local ____math_floor_27 = math.floor -- 1357
		local ____params_offset_26 = params.offset -- 1357
		if ____params_offset_26 == nil then -- 1357
			____params_offset_26 = 0 -- 1357
		end -- 1357
		local result = __TS__Await(____Tools_searchFiles_36({ -- 1347
			workDir = ____input_workDir_29, -- 1348
			path = ____temp_30, -- 1349
			pattern = ____temp_31, -- 1350
			globs = ____params_globs_32, -- 1351
			useRegex = ____params_useRegex_33, -- 1352
			caseSensitive = ____params_caseSensitive_34, -- 1353
			includeContent = true, -- 1354
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1355
			limit = ____math_max_25_result_35, -- 1356
			offset = ____math_max_28( -- 1357
				0, -- 1357
				____math_floor_27(__TS__Number(____params_offset_26)) -- 1357
			), -- 1357
			groupByFile = params.groupByFile == true -- 1358
		})) -- 1358
		return ____awaiter_resolve(nil, result) -- 1358
	end) -- 1358
end -- 1345
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1363
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1363
		local last = shared.history[#shared.history] -- 1364
		if last ~= nil then -- 1364
			local followupHint = shared.useChineseResponse and "然后读取搜索结果中相关的文件来了解详情。" or "Then read the relevant files from the search results to inspect the details." -- 1366
			if not __TS__StringIncludes(last.reason, followupHint) then -- 1366
				last.reason = __TS__StringTrim((last.reason .. " ") .. followupHint) -- 1370
			end -- 1370
			local result = execRes -- 1372
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1373
			emitAgentEvent(shared, { -- 1374
				type = "tool_finished", -- 1375
				sessionId = shared.sessionId, -- 1376
				taskId = shared.taskId, -- 1377
				step = shared.step + 1, -- 1378
				tool = last.tool, -- 1379
				result = last.result -- 1380
			}) -- 1380
		end -- 1380
		__TS__Await(maybeCompressHistory(shared)) -- 1383
		persistHistoryState(shared) -- 1384
		shared.step = shared.step + 1 -- 1385
		return ____awaiter_resolve(nil, "main") -- 1385
	end) -- 1385
end -- 1363
local SearchDoraAPIAction = __TS__Class() -- 1390
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1390
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1390
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1391
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1391
		local last = shared.history[#shared.history] -- 1392
		if not last then -- 1392
			error( -- 1393
				__TS__New(Error, "no history"), -- 1393
				0 -- 1393
			) -- 1393
		end -- 1393
		emitAgentEvent(shared, { -- 1394
			type = "tool_started", -- 1395
			sessionId = shared.sessionId, -- 1396
			taskId = shared.taskId, -- 1397
			step = shared.step + 1, -- 1398
			tool = last.tool -- 1399
		}) -- 1399
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1399
	end) -- 1399
end -- 1391
function SearchDoraAPIAction.prototype.exec(self, input) -- 1404
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1404
		local params = input.params -- 1405
		local ____Tools_searchDoraAPI_44 = Tools.searchDoraAPI -- 1406
		local ____temp_40 = params.pattern or "" -- 1407
		local ____temp_41 = params.docSource or "api" -- 1408
		local ____temp_42 = input.useChineseResponse and "zh" or "en" -- 1409
		local ____temp_43 = params.programmingLanguage or "ts" -- 1410
		local ____math_min_39 = math.min -- 1411
		local ____math_max_38 = math.max -- 1411
		local ____params_limit_37 = params.limit -- 1411
		if ____params_limit_37 == nil then -- 1411
			____params_limit_37 = 8 -- 1411
		end -- 1411
		local result = __TS__Await(____Tools_searchDoraAPI_44({ -- 1406
			pattern = ____temp_40, -- 1407
			docSource = ____temp_41, -- 1408
			docLanguage = ____temp_42, -- 1409
			programmingLanguage = ____temp_43, -- 1410
			limit = ____math_min_39( -- 1411
				SEARCH_DORA_API_LIMIT_MAX, -- 1411
				____math_max_38( -- 1411
					1, -- 1411
					__TS__Number(____params_limit_37) -- 1411
				) -- 1411
			), -- 1411
			useRegex = params.useRegex, -- 1412
			caseSensitive = false, -- 1413
			includeContent = true, -- 1414
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1415
		})) -- 1415
		return ____awaiter_resolve(nil, result) -- 1415
	end) -- 1415
end -- 1404
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1420
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1420
		local last = shared.history[#shared.history] -- 1421
		if last ~= nil then -- 1421
			local result = execRes -- 1423
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1424
			emitAgentEvent(shared, { -- 1425
				type = "tool_finished", -- 1426
				sessionId = shared.sessionId, -- 1427
				taskId = shared.taskId, -- 1428
				step = shared.step + 1, -- 1429
				tool = last.tool, -- 1430
				result = last.result -- 1431
			}) -- 1431
		end -- 1431
		__TS__Await(maybeCompressHistory(shared)) -- 1434
		persistHistoryState(shared) -- 1435
		shared.step = shared.step + 1 -- 1436
		return ____awaiter_resolve(nil, "main") -- 1436
	end) -- 1436
end -- 1420
local ListFilesAction = __TS__Class() -- 1441
ListFilesAction.name = "ListFilesAction" -- 1441
__TS__ClassExtends(ListFilesAction, Node) -- 1441
function ListFilesAction.prototype.prep(self, shared) -- 1442
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1442
		local last = shared.history[#shared.history] -- 1443
		if not last then -- 1443
			error( -- 1444
				__TS__New(Error, "no history"), -- 1444
				0 -- 1444
			) -- 1444
		end -- 1444
		emitAgentEvent(shared, { -- 1445
			type = "tool_started", -- 1446
			sessionId = shared.sessionId, -- 1447
			taskId = shared.taskId, -- 1448
			step = shared.step + 1, -- 1449
			tool = last.tool -- 1450
		}) -- 1450
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1450
	end) -- 1450
end -- 1442
function ListFilesAction.prototype.exec(self, input) -- 1455
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1455
		local params = input.params -- 1456
		local ____Tools_listFiles_51 = Tools.listFiles -- 1457
		local ____input_workDir_48 = input.workDir -- 1458
		local ____temp_49 = params.path or "" -- 1459
		local ____params_globs_50 = params.globs -- 1460
		local ____math_max_47 = math.max -- 1461
		local ____math_floor_46 = math.floor -- 1461
		local ____params_maxEntries_45 = params.maxEntries -- 1461
		if ____params_maxEntries_45 == nil then -- 1461
			____params_maxEntries_45 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1461
		end -- 1461
		local result = ____Tools_listFiles_51({ -- 1457
			workDir = ____input_workDir_48, -- 1458
			path = ____temp_49, -- 1459
			globs = ____params_globs_50, -- 1460
			maxEntries = ____math_max_47( -- 1461
				1, -- 1461
				____math_floor_46(__TS__Number(____params_maxEntries_45)) -- 1461
			) -- 1461
		}) -- 1461
		return ____awaiter_resolve(nil, result) -- 1461
	end) -- 1461
end -- 1455
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1466
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1466
		local last = shared.history[#shared.history] -- 1467
		if last ~= nil then -- 1467
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1469
			emitAgentEvent(shared, { -- 1470
				type = "tool_finished", -- 1471
				sessionId = shared.sessionId, -- 1472
				taskId = shared.taskId, -- 1473
				step = shared.step + 1, -- 1474
				tool = last.tool, -- 1475
				result = last.result -- 1476
			}) -- 1476
		end -- 1476
		__TS__Await(maybeCompressHistory(shared)) -- 1479
		persistHistoryState(shared) -- 1480
		shared.step = shared.step + 1 -- 1481
		return ____awaiter_resolve(nil, "main") -- 1481
	end) -- 1481
end -- 1466
local DeleteFileAction = __TS__Class() -- 1486
DeleteFileAction.name = "DeleteFileAction" -- 1486
__TS__ClassExtends(DeleteFileAction, Node) -- 1486
function DeleteFileAction.prototype.prep(self, shared) -- 1487
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1487
		local last = shared.history[#shared.history] -- 1488
		if not last then -- 1488
			error( -- 1489
				__TS__New(Error, "no history"), -- 1489
				0 -- 1489
			) -- 1489
		end -- 1489
		emitAgentEvent(shared, { -- 1490
			type = "tool_started", -- 1491
			sessionId = shared.sessionId, -- 1492
			taskId = shared.taskId, -- 1493
			step = shared.step + 1, -- 1494
			tool = last.tool -- 1495
		}) -- 1495
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1497
		if __TS__StringTrim(targetFile) == "" then -- 1497
			error( -- 1500
				__TS__New(Error, "missing target_file"), -- 1500
				0 -- 1500
			) -- 1500
		end -- 1500
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1500
	end) -- 1500
end -- 1487
function DeleteFileAction.prototype.exec(self, input) -- 1504
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1504
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1505
		if not result.success then -- 1505
			return ____awaiter_resolve(nil, result) -- 1505
		end -- 1505
		return ____awaiter_resolve(nil, { -- 1505
			success = true, -- 1513
			changed = true, -- 1514
			mode = "delete", -- 1515
			checkpointId = result.checkpointId, -- 1516
			checkpointSeq = result.checkpointSeq, -- 1517
			files = {{path = input.targetFile, op = "delete"}} -- 1518
		}) -- 1518
	end) -- 1518
end -- 1504
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1522
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1522
		local last = shared.history[#shared.history] -- 1523
		if last ~= nil then -- 1523
			last.result = execRes -- 1525
			emitAgentEvent(shared, { -- 1526
				type = "tool_finished", -- 1527
				sessionId = shared.sessionId, -- 1528
				taskId = shared.taskId, -- 1529
				step = shared.step + 1, -- 1530
				tool = last.tool, -- 1531
				result = last.result -- 1532
			}) -- 1532
			local result = last.result -- 1534
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1534
				emitAgentEvent(shared, { -- 1539
					type = "checkpoint_created", -- 1540
					sessionId = shared.sessionId, -- 1541
					taskId = shared.taskId, -- 1542
					step = shared.step + 1, -- 1543
					tool = "delete_file", -- 1544
					checkpointId = result.checkpointId, -- 1545
					checkpointSeq = result.checkpointSeq, -- 1546
					files = result.files -- 1547
				}) -- 1547
			end -- 1547
		end -- 1547
		__TS__Await(maybeCompressHistory(shared)) -- 1551
		persistHistoryState(shared) -- 1552
		shared.step = shared.step + 1 -- 1553
		return ____awaiter_resolve(nil, "main") -- 1553
	end) -- 1553
end -- 1522
local BuildAction = __TS__Class() -- 1558
BuildAction.name = "BuildAction" -- 1558
__TS__ClassExtends(BuildAction, Node) -- 1558
function BuildAction.prototype.prep(self, shared) -- 1559
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1559
		local last = shared.history[#shared.history] -- 1560
		if not last then -- 1560
			error( -- 1561
				__TS__New(Error, "no history"), -- 1561
				0 -- 1561
			) -- 1561
		end -- 1561
		emitAgentEvent(shared, { -- 1562
			type = "tool_started", -- 1563
			sessionId = shared.sessionId, -- 1564
			taskId = shared.taskId, -- 1565
			step = shared.step + 1, -- 1566
			tool = last.tool -- 1567
		}) -- 1567
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1567
	end) -- 1567
end -- 1559
function BuildAction.prototype.exec(self, input) -- 1572
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1572
		local params = input.params -- 1573
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1574
		return ____awaiter_resolve(nil, result) -- 1574
	end) -- 1574
end -- 1572
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1581
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1581
		local last = shared.history[#shared.history] -- 1582
		if last ~= nil then -- 1582
			local followupHint = shared.useChineseResponse and "构建已完成，将根据结果做后续处理，不再重复构建。" or "Build completed. Shall handle the result instead of building again." -- 1584
			local reason = last.reason -- 1584
			last.reason = last.reason and last.reason ~= "" and (last.reason .. "\n") .. followupHint or followupHint -- 1588
			last.result = execRes -- 1591
			emitAgentEvent(shared, { -- 1592
				type = "tool_finished", -- 1593
				sessionId = shared.sessionId, -- 1594
				taskId = shared.taskId, -- 1595
				step = shared.step + 1, -- 1596
				tool = last.tool, -- 1597
				reason = reason, -- 1598
				result = last.result -- 1599
			}) -- 1599
		end -- 1599
		__TS__Await(maybeCompressHistory(shared)) -- 1602
		persistHistoryState(shared) -- 1603
		shared.step = shared.step + 1 -- 1604
		return ____awaiter_resolve(nil, "main") -- 1604
	end) -- 1604
end -- 1581
local EditFileAction = __TS__Class() -- 1609
EditFileAction.name = "EditFileAction" -- 1609
__TS__ClassExtends(EditFileAction, Node) -- 1609
function EditFileAction.prototype.prep(self, shared) -- 1610
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1610
		local last = shared.history[#shared.history] -- 1611
		if not last then -- 1611
			error( -- 1612
				__TS__New(Error, "no history"), -- 1612
				0 -- 1612
			) -- 1612
		end -- 1612
		emitAgentEvent(shared, { -- 1613
			type = "tool_started", -- 1614
			sessionId = shared.sessionId, -- 1615
			taskId = shared.taskId, -- 1616
			step = shared.step + 1, -- 1617
			tool = last.tool -- 1618
		}) -- 1618
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1620
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1623
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1624
		if __TS__StringTrim(path) == "" then -- 1624
			error( -- 1625
				__TS__New(Error, "missing path"), -- 1625
				0 -- 1625
			) -- 1625
		end -- 1625
		if oldStr == newStr then -- 1625
			error( -- 1626
				__TS__New(Error, "old_str and new_str must be different"), -- 1626
				0 -- 1626
			) -- 1626
		end -- 1626
		return ____awaiter_resolve(nil, { -- 1626
			path = path, -- 1627
			oldStr = oldStr, -- 1627
			newStr = newStr, -- 1627
			taskId = shared.taskId, -- 1627
			workDir = shared.workingDir -- 1627
		}) -- 1627
	end) -- 1627
end -- 1610
function EditFileAction.prototype.exec(self, input) -- 1630
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1630
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1631
		if not readRes.success then -- 1631
			if input.oldStr ~= "" then -- 1631
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1631
			end -- 1631
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1636
			if not createRes.success then -- 1636
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1636
			end -- 1636
			return ____awaiter_resolve(nil, { -- 1636
				success = true, -- 1644
				changed = true, -- 1645
				mode = "create", -- 1646
				replaced = 0, -- 1647
				checkpointId = createRes.checkpointId, -- 1648
				checkpointSeq = createRes.checkpointSeq, -- 1649
				files = {{path = input.path, op = "create"}} -- 1650
			}) -- 1650
		end -- 1650
		if input.oldStr == "" then -- 1650
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 1650
		end -- 1650
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 1657
		if replaceRes.replaced == 0 then -- 1657
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 1657
		end -- 1657
		if replaceRes.content == readRes.content then -- 1657
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 1657
		end -- 1657
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1670
		if not applyRes.success then -- 1670
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1670
		end -- 1670
		return ____awaiter_resolve(nil, { -- 1670
			success = true, -- 1678
			changed = true, -- 1679
			mode = "replace", -- 1680
			replaced = replaceRes.replaced, -- 1681
			checkpointId = applyRes.checkpointId, -- 1682
			checkpointSeq = applyRes.checkpointSeq, -- 1683
			files = {{path = input.path, op = "write"}} -- 1684
		}) -- 1684
	end) -- 1684
end -- 1630
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1688
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1688
		local last = shared.history[#shared.history] -- 1689
		if last ~= nil then -- 1689
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1691
			last.result = execRes -- 1692
			emitAgentEvent(shared, { -- 1693
				type = "tool_finished", -- 1694
				sessionId = shared.sessionId, -- 1695
				taskId = shared.taskId, -- 1696
				step = shared.step + 1, -- 1697
				tool = last.tool, -- 1698
				result = last.result -- 1699
			}) -- 1699
			local result = last.result -- 1701
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1701
				emitAgentEvent(shared, { -- 1706
					type = "checkpoint_created", -- 1707
					sessionId = shared.sessionId, -- 1708
					taskId = shared.taskId, -- 1709
					step = shared.step + 1, -- 1710
					tool = last.tool, -- 1711
					checkpointId = result.checkpointId, -- 1712
					checkpointSeq = result.checkpointSeq, -- 1713
					files = result.files -- 1714
				}) -- 1714
			end -- 1714
		end -- 1714
		__TS__Await(maybeCompressHistory(shared)) -- 1718
		persistHistoryState(shared) -- 1719
		shared.step = shared.step + 1 -- 1720
		return ____awaiter_resolve(nil, "main") -- 1720
	end) -- 1720
end -- 1688
local FormatResponseNode = __TS__Class() -- 1725
FormatResponseNode.name = "FormatResponseNode" -- 1725
__TS__ClassExtends(FormatResponseNode, Node) -- 1725
function FormatResponseNode.prototype.prep(self, shared) -- 1726
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1726
		local last = shared.history[#shared.history] -- 1727
		if last and last.tool == "finish" then -- 1727
			emitAgentEvent(shared, { -- 1729
				type = "tool_started", -- 1730
				sessionId = shared.sessionId, -- 1731
				taskId = shared.taskId, -- 1732
				step = shared.step + 1, -- 1733
				tool = last.tool -- 1734
			}) -- 1734
		end -- 1734
		return ____awaiter_resolve(nil, {history = shared.history, shared = shared}) -- 1734
	end) -- 1734
end -- 1726
function FormatResponseNode.prototype.exec(self, input) -- 1740
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1740
		if input.shared.stopToken.stopped then -- 1740
			return ____awaiter_resolve( -- 1740
				nil, -- 1740
				getCancelledReason(input.shared) -- 1742
			) -- 1742
		end -- 1742
		local history = input.history -- 1744
		if #history == 0 then -- 1744
			return ____awaiter_resolve(nil, "No actions were performed.") -- 1744
		end -- 1744
		local summary = formatHistorySummary(history) -- 1748
		local prompt = (("You are a coding assistant. Summarize what you did for the user.\n\nHere are the actions you performed:\n" .. summary) .. "\n\nGenerate a concise response that explains:\n1. What actions were taken\n2. What was found or modified\n3. Any next steps\n\nIMPORTANT:\n- Focus on outcomes, not tool names.\n- Speak directly to the user.\n- If the user asked a question, include a direct answer to that question in the response.\n") .. getReplyLanguageDirective(input.shared) -- 1749
		local res -- 1764
		do -- 1764
			local i = 0 -- 1765
			while i < input.shared.llmMaxTry do -- 1765
				res = __TS__Await(llmStream(input.shared, {{role = "user", content = prompt}})) -- 1766
				if res.success then -- 1766
					break -- 1767
				end -- 1767
				i = i + 1 -- 1765
			end -- 1765
		end -- 1765
		if not res then -- 1765
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败。" or "Completed, but failed to generate summary.") -- 1765
		end -- 1765
		if not res.success then -- 1765
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败：" .. res.message or "Completed, but failed to generate summary: " .. res.message) -- 1765
		end -- 1765
		return ____awaiter_resolve(nil, res.text) -- 1765
	end) -- 1765
end -- 1740
function FormatResponseNode.prototype.post(self, shared, _prepRes, execRes) -- 1780
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1780
		local last = shared.history[#shared.history] -- 1781
		if last and last.tool == "finish" then -- 1781
			last.result = {success = true, message = execRes} -- 1783
			emitAgentEvent(shared, { -- 1784
				type = "tool_finished", -- 1785
				sessionId = shared.sessionId, -- 1786
				taskId = shared.taskId, -- 1787
				step = shared.step + 1, -- 1788
				tool = last.tool, -- 1789
				result = last.result -- 1790
			}) -- 1790
			shared.step = shared.step + 1 -- 1792
		end -- 1792
		shared.response = execRes -- 1794
		shared.done = true -- 1795
		persistHistoryState(shared) -- 1796
		return ____awaiter_resolve(nil, nil) -- 1796
	end) -- 1796
end -- 1780
local CodingAgentFlow = __TS__Class() -- 1801
CodingAgentFlow.name = "CodingAgentFlow" -- 1801
__TS__ClassExtends(CodingAgentFlow, Flow) -- 1801
function CodingAgentFlow.prototype.____constructor(self) -- 1802
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 1803
	local read = __TS__New(ReadFileAction, 1, 0) -- 1804
	local search = __TS__New(SearchFilesAction, 1, 0) -- 1805
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 1806
	local list = __TS__New(ListFilesAction, 1, 0) -- 1807
	local del = __TS__New(DeleteFileAction, 1, 0) -- 1808
	local build = __TS__New(BuildAction, 1, 0) -- 1809
	local edit = __TS__New(EditFileAction, 1, 0) -- 1810
	local format = __TS__New(FormatResponseNode, 1, 0) -- 1811
	main:on("read_file", read) -- 1813
	main:on("read_file_range", read) -- 1814
	main:on("grep_files", search) -- 1815
	main:on("search_dora_api", searchDora) -- 1816
	main:on("glob_files", list) -- 1817
	main:on("delete_file", del) -- 1818
	main:on("build", build) -- 1819
	main:on("edit_file", edit) -- 1820
	main:on("finish", format) -- 1821
	main:on("error", format) -- 1822
	read:on("main", main) -- 1824
	search:on("main", main) -- 1825
	searchDora:on("main", main) -- 1826
	list:on("main", main) -- 1827
	del:on("main", main) -- 1828
	build:on("main", main) -- 1829
	edit:on("main", main) -- 1830
	Flow.prototype.____constructor(self, main) -- 1832
end -- 1802
local function runCodingAgentAsync(options) -- 1836
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1836
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 1836
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 1836
		end -- 1836
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 1840
		if not llmConfigRes.success then -- 1840
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 1840
		end -- 1840
		local llmConfig = llmConfigRes.config -- 1846
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 1847
		if not taskRes.success then -- 1847
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 1847
		end -- 1847
		local compressor = __TS__New(MemoryCompressor, { -- 1855
			compressionThreshold = 0.8, -- 1856
			maxCompressionRounds = 3, -- 1857
			maxTokensPerCompression = 20000, -- 1858
			projectDir = options.workDir, -- 1859
			llmConfig = llmConfig -- 1860
		}) -- 1860
		local persistedSession = compressor:getStorage():readSessionState() -- 1862
		local shared = { -- 1864
			sessionId = options.sessionId, -- 1865
			taskId = taskRes.taskId, -- 1866
			maxSteps = math.max( -- 1867
				1, -- 1867
				math.floor(options.maxSteps or 40) -- 1867
			), -- 1867
			llmMaxTry = math.max( -- 1868
				1, -- 1868
				math.floor(options.llmMaxTry or 3) -- 1868
			), -- 1868
			step = 0, -- 1869
			done = false, -- 1870
			stopToken = options.stopToken or ({stopped = false}), -- 1871
			response = "", -- 1872
			userQuery = options.prompt, -- 1873
			workingDir = options.workDir, -- 1874
			useChineseResponse = options.useChineseResponse == true, -- 1875
			decisionMode = options.decisionMode == "yaml" and "yaml" or "tool_calling", -- 1876
			llmOptions = __TS__ObjectAssign({temperature = 0.2}, options.llmOptions or ({})), -- 1877
			llmConfig = llmConfig, -- 1881
			onEvent = options.onEvent, -- 1882
			history = persistedSession.history, -- 1883
			memory = {lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, compressor = compressor} -- 1885
		} -- 1885
		local ____try = __TS__AsyncAwaiter(function() -- 1885
			emitAgentEvent(shared, { -- 1892
				type = "task_started", -- 1893
				sessionId = shared.sessionId, -- 1894
				taskId = shared.taskId, -- 1895
				prompt = shared.userQuery, -- 1896
				workDir = shared.workingDir, -- 1897
				maxSteps = shared.maxSteps -- 1898
			}) -- 1898
			if shared.stopToken.stopped then -- 1898
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1901
				local result = { -- 1902
					success = false, -- 1902
					taskId = shared.taskId, -- 1902
					message = getCancelledReason(shared), -- 1902
					steps = shared.step -- 1902
				} -- 1902
				emitAgentEvent(shared, { -- 1903
					type = "task_finished", -- 1904
					sessionId = shared.sessionId, -- 1905
					taskId = shared.taskId, -- 1906
					success = false, -- 1907
					message = result.message, -- 1908
					steps = result.steps -- 1909
				}) -- 1909
				return ____awaiter_resolve(nil, result) -- 1909
			end -- 1909
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 1913
			local flow = __TS__New(CodingAgentFlow) -- 1914
			__TS__Await(flow:run(shared)) -- 1915
			if shared.stopToken.stopped then -- 1915
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1917
				local result = { -- 1918
					success = false, -- 1918
					taskId = shared.taskId, -- 1918
					message = getCancelledReason(shared), -- 1918
					steps = shared.step -- 1918
				} -- 1918
				emitAgentEvent(shared, { -- 1919
					type = "task_finished", -- 1920
					sessionId = shared.sessionId, -- 1921
					taskId = shared.taskId, -- 1922
					success = false, -- 1923
					message = result.message, -- 1924
					steps = result.steps -- 1925
				}) -- 1925
				return ____awaiter_resolve(nil, result) -- 1925
			end -- 1925
			if shared.error then -- 1925
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1930
				local result = {success = false, taskId = shared.taskId, message = shared.error, steps = shared.step} -- 1931
				emitAgentEvent(shared, { -- 1932
					type = "task_finished", -- 1933
					sessionId = shared.sessionId, -- 1934
					taskId = shared.taskId, -- 1935
					success = false, -- 1936
					message = result.message, -- 1937
					steps = result.steps -- 1938
				}) -- 1938
				return ____awaiter_resolve(nil, result) -- 1938
			end -- 1938
			Tools.setTaskStatus(shared.taskId, "DONE") -- 1942
			local result = {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step} -- 1943
			emitAgentEvent(shared, { -- 1949
				type = "task_finished", -- 1950
				sessionId = shared.sessionId, -- 1951
				taskId = shared.taskId, -- 1952
				success = true, -- 1953
				message = result.message, -- 1954
				steps = result.steps -- 1955
			}) -- 1955
			return ____awaiter_resolve(nil, result) -- 1955
		end) -- 1955
		__TS__Await(____try.catch( -- 1891
			____try, -- 1891
			function(____, e) -- 1891
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1959
				local result = { -- 1960
					success = false, -- 1960
					taskId = shared.taskId, -- 1960
					message = tostring(e), -- 1960
					steps = shared.step -- 1960
				} -- 1960
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
		)) -- 1967
	end) -- 1967
end -- 1836
function ____exports.runCodingAgent(options, callback) -- 1973
	local ____self_52 = runCodingAgentAsync(options) -- 1973
	____self_52["then"]( -- 1973
		____self_52, -- 1973
		function(____, result) return callback(result) end -- 1974
	) -- 1974
end -- 1973
return ____exports -- 1973