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
local toJson, truncateText, utf8TakeHead, summarizeUnknown, limitReadContentForHistory, pushLimitedMatches, formatHistorySummary, HISTORY_READ_FILE_MAX_CHARS, HISTORY_READ_FILE_MAX_LINES, HISTORY_SEARCH_FILES_MAX_MATCHES, HISTORY_SEARCH_DORA_API_MAX_MATCHES, HISTORY_LIST_FILES_MAX_ENTRIES -- 1
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
local Tools = require("Agent.Tools") -- 5
local yaml = require("yaml") -- 6
local ____Memory = require("Agent.Memory") -- 7
local MemoryCompressor = ____Memory.MemoryCompressor -- 7
function toJson(value) -- 177
	local text, err = json.encode(value) -- 178
	if text ~= nil then -- 178
		return text -- 179
	end -- 179
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 180
end -- 180
function truncateText(text, maxLen) -- 183
	if #text <= maxLen then -- 183
		return text -- 184
	end -- 184
	local nextPos = utf8.offset(text, maxLen + 1) -- 185
	if nextPos == nil then -- 185
		return text -- 186
	end -- 186
	return string.sub(text, 1, nextPos - 1) .. "..." -- 187
end -- 187
function utf8TakeHead(text, maxChars) -- 190
	if maxChars <= 0 or text == "" then -- 190
		return "" -- 191
	end -- 191
	local nextPos = utf8.offset(text, maxChars + 1) -- 192
	if nextPos == nil then -- 192
		return text -- 193
	end -- 193
	return string.sub(text, 1, nextPos - 1) -- 194
end -- 194
function summarizeUnknown(value, maxLen) -- 207
	if maxLen == nil then -- 207
		maxLen = 320 -- 207
	end -- 207
	if value == nil then -- 207
		return "undefined" -- 208
	end -- 208
	if value == nil then -- 208
		return "null" -- 209
	end -- 209
	if type(value) == "string" then -- 209
		return __TS__StringReplace( -- 211
			truncateText(value, maxLen), -- 211
			"\n", -- 211
			"\\n" -- 211
		) -- 211
	end -- 211
	if type(value) == "number" or type(value) == "boolean" then -- 211
		return tostring(value) -- 214
	end -- 214
	return __TS__StringReplace( -- 216
		truncateText( -- 216
			toJson(value), -- 216
			maxLen -- 216
		), -- 216
		"\n", -- 216
		"\\n" -- 216
	) -- 216
end -- 216
function limitReadContentForHistory(content, tool) -- 225
	local lines = __TS__StringSplit(content, "\n") -- 226
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 227
	local limitedByLines = overLineLimit and table.concat( -- 228
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 229
		"\n" -- 229
	) or content -- 229
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 229
		return content -- 232
	end -- 232
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 234
	local reasons = {} -- 237
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 237
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 238
	end -- 238
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 238
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 239
	end -- 239
	local hint = tool == "read_file" and "Use read_file_range for the exact section you need." or "Narrow the requested line range." -- 240
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 243
end -- 243
function pushLimitedMatches(lines, items, maxItems, mapper) -- 358
	local shown = math.min(#items, maxItems) -- 364
	do -- 364
		local j = 0 -- 365
		while j < shown do -- 365
			lines[#lines + 1] = mapper(items[j + 1], j) -- 366
			j = j + 1 -- 365
		end -- 365
	end -- 365
	if #items > shown then -- 365
		lines[#lines + 1] = ("  ... " .. tostring(#items - shown)) .. " more omitted" -- 369
	end -- 369
end -- 369
function formatHistorySummary(history) -- 436
	if #history == 0 then -- 436
		return "No previous actions." -- 438
	end -- 438
	local actions = history -- 440
	local lines = {} -- 441
	lines[#lines + 1] = "" -- 442
	do -- 442
		local i = 0 -- 443
		while i < #actions do -- 443
			local action = actions[i + 1] -- 444
			lines[#lines + 1] = ("Action " .. tostring(i + 1)) .. ":" -- 445
			lines[#lines + 1] = "- Tool: " .. action.tool -- 446
			lines[#lines + 1] = "- Reason: " .. action.reason -- 447
			if action.params and type(action.params) == "table" and ({next(action.params)}) ~= nil then -- 447
				lines[#lines + 1] = "- Parameters:" -- 449
				for key in pairs(action.params) do -- 450
					lines[#lines + 1] = (("  - " .. key) .. ": ") .. summarizeUnknown(action.params[key], 2000) -- 451
				end -- 451
			end -- 451
			if action.result and type(action.result) == "table" then -- 451
				local result = action.result -- 455
				local success = result.success == true -- 456
				if action.tool == "build" then -- 456
					if not success and type(result.message) == "string" then -- 456
						lines[#lines + 1] = "- Result: Failed" -- 459
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 1200) -- 460
					elseif type(result.messages) == "table" then -- 460
						local messages = result.messages -- 462
						local successCount = 0 -- 463
						local failedCount = 0 -- 464
						do -- 464
							local j = 0 -- 465
							while j < #messages do -- 465
								if messages[j + 1].success == true then -- 465
									successCount = successCount + 1 -- 466
								else -- 466
									failedCount = failedCount + 1 -- 467
								end -- 467
								j = j + 1 -- 465
							end -- 465
						end -- 465
						lines[#lines + 1] = "- Result: " .. (failedCount > 0 and "Completed With Errors" or "Success") -- 469
						lines[#lines + 1] = ((("- Build summary: " .. tostring(successCount)) .. " succeeded, ") .. tostring(failedCount)) .. " failed" -- 470
						if #messages > 0 then -- 470
							lines[#lines + 1] = "- Build details:" -- 472
							local shown = math.min(#messages, 12) -- 473
							do -- 473
								local j = 0 -- 474
								while j < shown do -- 474
									local item = messages[j + 1] -- 475
									local file = type(item.file) == "string" and item.file or "(unknown)" -- 476
									if item.success == true then -- 476
										lines[#lines + 1] = (("  " .. tostring(j + 1)) .. ". OK ") .. file -- 478
									else -- 478
										local message = type(item.message) == "string" and truncateText(item.message, 400) or "build failed" -- 480
										lines[#lines + 1] = (((("  " .. tostring(j + 1)) .. ". FAIL ") .. file) .. ": ") .. message -- 483
									end -- 483
									j = j + 1 -- 474
								end -- 474
							end -- 474
							if #messages > shown then -- 474
								lines[#lines + 1] = ("  ... " .. tostring(#messages - shown)) .. " more omitted" -- 487
							end -- 487
						end -- 487
					else -- 487
						lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 491
					end -- 491
				elseif action.tool == "read_file" or action.tool == "read_file_range" then -- 491
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 494
					if success and type(result.content) == "string" then -- 494
						lines[#lines + 1] = "- Content: " .. limitReadContentForHistory(result.content, action.tool) -- 496
						if result.startLine ~= nil or result.endLine ~= nil or result.totalLines ~= nil then -- 496
							lines[#lines + 1] = (((("- Range: " .. (result.startLine ~= nil and tostring(result.startLine) or "?")) .. "-") .. (result.endLine ~= nil and tostring(result.endLine) or "?")) .. " / total ") .. (result.totalLines ~= nil and tostring(result.totalLines) or "?") -- 498
						end -- 498
					elseif not success and type(result.message) == "string" then -- 498
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 600) -- 503
					end -- 503
				elseif action.tool == "grep_files" then -- 503
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 506
					if success and type(result.results) == "table" then -- 506
						local matches = result.results -- 508
						local totalMatches = type(result.totalResults) == "number" and result.totalResults or #matches -- 509
						lines[#lines + 1] = "- Matches: " .. tostring(totalMatches) -- 512
						if type(result.offset) == "number" and type(result.limit) == "number" then -- 512
							lines[#lines + 1] = (("- Page: offset=" .. tostring(result.offset)) .. " limit=") .. tostring(result.limit) -- 514
						end -- 514
						if result.hasMore == true and result.nextOffset ~= nil then -- 514
							lines[#lines + 1] = "- More: continue with offset=" .. tostring(result.nextOffset) -- 517
						end -- 517
						if type(result.groupedResults) == "table" then -- 517
							local groups = result.groupedResults -- 520
							lines[#lines + 1] = "- Groups:" -- 521
							pushLimitedMatches( -- 522
								lines, -- 522
								groups, -- 522
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 522
								function(g, index) -- 522
									local file = type(g.file) == "string" and g.file or "" -- 523
									local total = g.totalMatches ~= nil and tostring(g.totalMatches) or "?" -- 524
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. ": ") .. total) .. " matches" -- 525
								end -- 522
							) -- 522
						else -- 522
							pushLimitedMatches( -- 528
								lines, -- 528
								matches, -- 528
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 528
								function(m, index) -- 528
									local file = type(m.file) == "string" and m.file or "" -- 529
									local line = m.line ~= nil and tostring(m.line) or "" -- 530
									local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 531
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 532
								end -- 528
							) -- 528
						end -- 528
					end -- 528
				elseif action.tool == "search_dora_api" then -- 528
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 537
					if success and type(result.results) == "table" then -- 537
						local hits = result.results -- 539
						local totalHits = type(result.totalResults) == "number" and result.totalResults or #hits -- 540
						lines[#lines + 1] = "- Matches: " .. tostring(totalHits) -- 543
						pushLimitedMatches( -- 544
							lines, -- 544
							hits, -- 544
							HISTORY_SEARCH_DORA_API_MAX_MATCHES, -- 544
							function(m, index) -- 544
								local file = type(m.file) == "string" and m.file or "" -- 545
								local line = m.line ~= nil and tostring(m.line) or "" -- 546
								local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 547
								return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 548
							end -- 544
						) -- 544
					end -- 544
				elseif action.tool == "edit_file" then -- 544
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 552
					if success then -- 552
						if result.mode ~= nil then -- 552
							lines[#lines + 1] = "- Mode: " .. tostring(result.mode) -- 555
						end -- 555
						if result.replaced ~= nil then -- 555
							lines[#lines + 1] = "- Replaced: " .. tostring(result.replaced) -- 558
						end -- 558
					end -- 558
				elseif action.tool == "glob_files" then -- 558
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 562
					if success and type(result.files) == "table" then -- 562
						local files = result.files -- 564
						local totalEntries = type(result.totalEntries) == "number" and result.totalEntries or #files -- 565
						lines[#lines + 1] = "- Entries: " .. tostring(totalEntries) -- 568
						lines[#lines + 1] = "- Directory structure:" -- 569
						if #files > 0 then -- 569
							local shown = math.min(#files, HISTORY_LIST_FILES_MAX_ENTRIES) -- 571
							do -- 571
								local j = 0 -- 572
								while j < shown do -- 572
									lines[#lines + 1] = "  " .. files[j + 1] -- 573
									j = j + 1 -- 572
								end -- 572
							end -- 572
							if #files > shown then -- 572
								lines[#lines + 1] = ("  ... " .. tostring(#files - shown)) .. " more omitted" -- 576
							end -- 576
						else -- 576
							lines[#lines + 1] = "  (Empty or inaccessible directory)" -- 579
						end -- 579
					end -- 579
				else -- 579
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 583
					lines[#lines + 1] = "- Detail: " .. truncateText( -- 584
						toJson(result), -- 584
						4000 -- 584
					) -- 584
				end -- 584
			elseif action.result ~= nil then -- 584
				lines[#lines + 1] = "- Result: " .. summarizeUnknown(action.result, 3000) -- 587
			else -- 587
				lines[#lines + 1] = "- Result: pending" -- 589
			end -- 589
			if i < #actions - 1 then -- 589
				lines[#lines + 1] = "" -- 591
			end -- 591
			i = i + 1 -- 443
		end -- 443
	end -- 443
	return table.concat(lines, "\n") -- 593
end -- 593
HISTORY_READ_FILE_MAX_CHARS = 12000 -- 114
HISTORY_READ_FILE_MAX_LINES = 300 -- 115
local READ_FILE_DEFAULT_LIMIT = 300 -- 116
HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 117
HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 118
HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 119
local DECISION_HISTORY_MAX_CHARS = 16000 -- 120
local SEARCH_DORA_API_LIMIT_MAX = 20 -- 121
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 122
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 123
local function emitAgentEvent(shared, event) -- 166
	if shared.onEvent then -- 166
		shared:onEvent(event) -- 168
	end -- 168
end -- 166
local function getCancelledReason(shared) -- 172
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 172
		return shared.stopToken.reason -- 173
	end -- 173
	return shared.useChineseResponse and "已取消" or "cancelled" -- 174
end -- 172
local function utf8TakeTail(text, maxChars) -- 197
	if maxChars <= 0 or text == "" then -- 197
		return "" -- 198
	end -- 198
	local charLen = utf8.len(text) -- 199
	if charLen == false or charLen <= maxChars then -- 199
		return text -- 200
	end -- 200
	local startChar = math.max(1, charLen - maxChars + 1) -- 201
	local startPos = utf8.offset(text, startChar) -- 202
	if startPos == nil then -- 202
		return text -- 203
	end -- 203
	return string.sub(text, startPos) -- 204
end -- 197
local function getReplyLanguageDirective(shared) -- 219
	return shared.useChineseResponse and "Use Simplified Chinese for natural-language fields (reason/message/summary)." or "Use English for natural-language fields (reason/message/summary)." -- 220
end -- 219
local function summarizeEditTextParamForHistory(value, key) -- 246
	if type(value) ~= "string" then -- 246
		return nil -- 247
	end -- 247
	local text = value -- 248
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 249
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 250
end -- 246
local function sanitizeReadResultForHistory(tool, result) -- 258
	if tool ~= "read_file" and tool ~= "read_file_range" or result.success ~= true or type(result.content) ~= "string" then -- 258
		return result -- 260
	end -- 260
	local clone = {} -- 262
	for key in pairs(result) do -- 263
		clone[key] = result[key] -- 264
	end -- 264
	clone.content = limitReadContentForHistory(result.content, tool) -- 266
	return clone -- 267
end -- 258
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 270
	local shown = math.min(#items, maxItems) -- 274
	local out = {} -- 275
	do -- 275
		local i = 0 -- 276
		while i < shown do -- 276
			local row = items[i + 1] -- 277
			out[#out + 1] = { -- 278
				file = row.file, -- 279
				line = row.line, -- 280
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 281
			} -- 281
			i = i + 1 -- 276
		end -- 276
	end -- 276
	return out -- 286
end -- 270
local function sanitizeSearchResultForHistory(tool, result) -- 289
	if result.success ~= true or type(result.results) ~= "table" then -- 289
		return result -- 293
	end -- 293
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 293
		return result -- 294
	end -- 294
	local clone = {} -- 295
	for key in pairs(result) do -- 296
		clone[key] = result[key] -- 297
	end -- 297
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 299
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 300
	if tool == "grep_files" and type(result.groupedResults) == "table" then -- 300
		local grouped = result.groupedResults -- 305
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 306
		local sanitizedGroups = {} -- 307
		do -- 307
			local i = 0 -- 308
			while i < shown do -- 308
				local row = grouped[i + 1] -- 309
				sanitizedGroups[#sanitizedGroups + 1] = { -- 310
					file = row.file, -- 311
					totalMatches = row.totalMatches, -- 312
					matches = type(row.matches) == "table" and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 313
				} -- 313
				i = i + 1 -- 308
			end -- 308
		end -- 308
		clone.groupedResults = sanitizedGroups -- 318
	end -- 318
	return clone -- 320
end -- 289
local function sanitizeListFilesResultForHistory(result) -- 323
	if result.success ~= true or type(result.files) ~= "table" then -- 323
		return result -- 324
	end -- 324
	local clone = {} -- 325
	for key in pairs(result) do -- 326
		clone[key] = result[key] -- 327
	end -- 327
	local files = result.files -- 329
	clone.files = __TS__ArraySlice(files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 330
	return clone -- 331
end -- 323
local function sanitizeActionParamsForHistory(tool, params) -- 334
	if tool ~= "edit_file" then -- 334
		return params -- 335
	end -- 335
	local clone = {} -- 336
	for key in pairs(params) do -- 337
		if key == "old_str" then -- 337
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 339
		elseif key == "new_str" then -- 339
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 341
		else -- 341
			clone[key] = params[key] -- 343
		end -- 343
	end -- 343
	return clone -- 346
end -- 334
local function trimPromptContext(text, maxChars, label) -- 349
	if #text <= maxChars then -- 349
		return text -- 350
	end -- 350
	local keepHead = math.max( -- 351
		0, -- 351
		math.floor(maxChars * 0.35) -- 351
	) -- 351
	local keepTail = math.max(0, maxChars - keepHead) -- 352
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 353
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 354
	return (((((("[history summary truncated for " .. label) .. "; showing head and tail within ") .. tostring(maxChars)) .. " chars]\n") .. head) .. "\n...\n") .. tail -- 355
end -- 349
local function formatHistorySummaryForDecision(history) -- 373
	return trimPromptContext( -- 374
		formatHistorySummary(history), -- 374
		DECISION_HISTORY_MAX_CHARS, -- 374
		"decision" -- 374
	) -- 374
end -- 373
local function getDecisionSystemPrompt() -- 377
	return "You are a coding assistant that helps modify and navigate code." -- 378
end -- 377
local function getDecisionToolDefinitions() -- 381
	return "Available tools:\n1. read_file: Read content from a file with pagination\n1b. read_file_range: Read specific line range from a file\n2. edit_file: Make changes to a file\n3. delete_file: Remove a file\n4. grep_files: Search text patterns inside files\n5. glob_files: Enumerate files under a directory with optional glob filters\n6. search_dora_api: Search Dora SSR game engine API docs\n7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn\n8. finish: End and summarize" -- 382
end -- 381
local function maybeCompressHistory(shared) -- 394
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 394
		local ____shared_0 = shared -- 395
		local memory = ____shared_0.memory -- 395
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 396
		do -- 396
			local round = 0 -- 397
			while round < maxRounds do -- 397
				if not memory.compressor:shouldCompress( -- 397
					shared.userQuery, -- 399
					shared.history, -- 400
					memory.lastConsolidatedIndex, -- 401
					getDecisionSystemPrompt(), -- 402
					getDecisionToolDefinitions(), -- 403
					formatHistorySummary -- 404
				) then -- 404
					return ____awaiter_resolve(nil) -- 404
				end -- 404
				local result = __TS__Await(memory.compressor:compress( -- 408
					shared.history, -- 409
					memory.lastConsolidatedIndex, -- 410
					shared.llmOptions, -- 411
					formatHistorySummary, -- 412
					shared.llmMaxTry, -- 413
					shared.decisionMode -- 414
				)) -- 414
				if not (result and result.success and result.compressedCount > 0) then -- 414
					return ____awaiter_resolve(nil) -- 414
				end -- 414
				memory.lastConsolidatedIndex = memory.lastConsolidatedIndex + result.compressedCount -- 419
				Log( -- 420
					"Info", -- 420
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " history records (round ") .. tostring(round + 1)) .. ")" -- 420
				) -- 420
				round = round + 1 -- 397
			end -- 397
		end -- 397
	end) -- 397
end -- 394
local function isKnownToolName(name) -- 424
	return name == "read_file" or name == "read_file_range" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 425
end -- 424
local function extractYAMLFromText(text) -- 596
	local source = __TS__StringTrim(text) -- 597
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 598
	if yamlFencePos >= 0 then -- 598
		local from = yamlFencePos + #"```yaml" -- 600
		local ____end = (string.find( -- 601
			source, -- 601
			"```", -- 601
			math.max(from + 1, 1), -- 601
			true -- 601
		) or 0) - 1 -- 601
		if ____end > from then -- 601
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 602
		end -- 602
	end -- 602
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 604
	if ymlFencePos >= 0 then -- 604
		local from = ymlFencePos + #"```yml" -- 606
		local ____end = (string.find( -- 607
			source, -- 607
			"```", -- 607
			math.max(from + 1, 1), -- 607
			true -- 607
		) or 0) - 1 -- 607
		if ____end > from then -- 607
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 608
		end -- 608
	end -- 608
	local fencePos = (string.find(source, "```", nil, true) or 0) - 1 -- 610
	if fencePos >= 0 then -- 610
		local firstLineEnd = (string.find( -- 612
			source, -- 612
			"\n", -- 612
			math.max(fencePos + 1, 1), -- 612
			true -- 612
		) or 0) - 1 -- 612
		local ____end = (string.find( -- 613
			source, -- 613
			"```", -- 613
			math.max((firstLineEnd >= 0 and firstLineEnd + 1 or fencePos + 3) + 1, 1), -- 613
			true -- 613
		) or 0) - 1 -- 613
		if firstLineEnd >= 0 and ____end > firstLineEnd then -- 613
			return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, ____end)) -- 615
		end -- 615
	end -- 615
	return source -- 618
end -- 596
local function parseYAMLObjectFromText(text) -- 621
	local yamlText = extractYAMLFromText(text) -- 622
	local obj, err = yaml.parse(yamlText) -- 623
	if obj == nil or type(obj) ~= "table" then -- 623
		return { -- 625
			success = false, -- 625
			message = "invalid yaml: " .. tostring(err) -- 625
		} -- 625
	end -- 625
	return {success = true, obj = obj} -- 627
end -- 621
local function llm(shared, messages) -- 639
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 639
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken)) -- 640
		if res.success then -- 640
			local ____opt_5 = res.response.choices -- 640
			local ____opt_3 = ____opt_5 and ____opt_5[1] -- 640
			local ____opt_1 = ____opt_3 and ____opt_3.message -- 640
			local text = ____opt_1 and ____opt_1.content -- 642
			if text then -- 642
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 642
			else -- 642
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 642
			end -- 642
		else -- 642
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 642
		end -- 642
	end) -- 642
end -- 639
local function llmStream(shared, messages) -- 653
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 653
		local text = "" -- 654
		local cancelledReason -- 655
		local done = false -- 656
		if shared.stopToken.stopped then -- 656
			return ____awaiter_resolve( -- 656
				nil, -- 656
				{ -- 659
					success = false, -- 659
					message = getCancelledReason(shared), -- 659
					text = text -- 659
				} -- 659
			) -- 659
		end -- 659
		done = false -- 661
		cancelledReason = nil -- 662
		text = "" -- 663
		callLLMStream( -- 664
			messages, -- 665
			shared.llmOptions, -- 666
			{ -- 667
				id = nil, -- 668
				stopToken = shared.stopToken, -- 669
				onData = function(data) -- 670
					if shared.stopToken.stopped then -- 670
						return true -- 671
					end -- 671
					local choice = data.choices and data.choices[1] -- 672
					local delta = choice and choice.delta -- 673
					if delta and type(delta.content) == "string" then -- 673
						local content = delta.content -- 675
						text = text .. content -- 676
						emitAgentEvent(shared, { -- 677
							type = "summary_stream", -- 678
							sessionId = shared.sessionId, -- 679
							taskId = shared.taskId, -- 680
							textDelta = content, -- 681
							fullText = text -- 682
						}) -- 682
						local res = json.encode({name = "LLMStream", content = content}) -- 684
						if res ~= nil then -- 684
							emit("AppWS", "Send", res) -- 686
						end -- 686
					end -- 686
					return false -- 689
				end, -- 670
				onCancel = function(reason) -- 691
					cancelledReason = reason -- 692
					done = true -- 693
				end, -- 691
				onDone = function() -- 695
					done = true -- 696
				end -- 695
			} -- 695
		) -- 695
		__TS__Await(__TS__New( -- 701
			__TS__Promise, -- 701
			function(____, resolve) -- 701
				Director.systemScheduler:schedule(once(function() -- 702
					wait(function() return done or shared.stopToken.stopped end) -- 703
					resolve(nil) -- 704
				end)) -- 702
			end -- 701
		)) -- 701
		if shared.stopToken.stopped then -- 701
			cancelledReason = getCancelledReason(shared) -- 708
		end -- 708
		if not cancelledReason and text == "" then -- 708
			cancelledReason = "empty LLM output" -- 712
		end -- 712
		if cancelledReason then -- 712
			return ____awaiter_resolve(nil, {success = false, message = cancelledReason, text = text}) -- 712
		end -- 712
		return ____awaiter_resolve(nil, {success = true, text = text}) -- 712
	end) -- 712
end -- 653
local function parseDecisionObject(rawObj) -- 719
	if type(rawObj.tool) ~= "string" then -- 719
		return {success = false, message = "missing tool"} -- 720
	end -- 720
	local tool = rawObj.tool -- 721
	if not isKnownToolName(tool) then -- 721
		return {success = false, message = "unknown tool: " .. tool} -- 723
	end -- 723
	local reason = type(rawObj.reason) == "string" and rawObj.reason or "" -- 725
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 726
	return {success = true, tool = tool, reason = reason, params = params} -- 727
end -- 719
local function getDecisionPath(params) -- 730
	if type(params.path) == "string" then -- 730
		return __TS__StringTrim(params.path) -- 731
	end -- 731
	if type(params.target_file) == "string" then -- 731
		return __TS__StringTrim(params.target_file) -- 732
	end -- 732
	return "" -- 733
end -- 730
local function canRunBuildAgain(history, params) -- 736
	local currentPath = getDecisionPath(params) -- 737
	do -- 737
		local i = #history - 1 -- 738
		while i >= 0 do -- 738
			do -- 738
				local item = history[i + 1] -- 739
				if item.tool == "edit_file" or item.tool == "delete_file" then -- 739
					return true -- 741
				end -- 741
				if item.tool ~= "build" then -- 741
					goto __continue159 -- 743
				end -- 743
				local lastPath = getDecisionPath(item.params) -- 744
				if currentPath == "" or lastPath == "" or currentPath == lastPath then -- 744
					return false -- 746
				end -- 746
			end -- 746
			::__continue159:: -- 746
			i = i - 1 -- 738
		end -- 738
	end -- 738
	return true -- 749
end -- 736
local function validateDecision(tool, params, history) -- 752
	if tool == "finish" then -- 752
		return {success = true} -- 757
	end -- 757
	if tool == "read_file" then -- 757
		local path = getDecisionPath(params) -- 760
		if path == "" then -- 760
			return {success = false, message = "read_file requires path"} -- 761
		end -- 761
		local ____params_limit_7 = params.limit -- 762
		if ____params_limit_7 == nil then -- 762
			____params_limit_7 = READ_FILE_DEFAULT_LIMIT -- 762
		end -- 762
		local limit = __TS__Number(____params_limit_7) -- 762
		if limit <= 0 then -- 762
			return {success = false, message = "read_file limit must be > 0"} -- 763
		end -- 763
		local ____params_offset_8 = params.offset -- 764
		if ____params_offset_8 == nil then -- 764
			____params_offset_8 = 1 -- 764
		end -- 764
		local offset = __TS__Number(____params_offset_8) -- 764
		if offset <= 0 then -- 764
			return {success = false, message = "read_file offset must be > 0"} -- 765
		end -- 765
		return {success = true} -- 766
	end -- 766
	if tool == "read_file_range" then -- 766
		local path = getDecisionPath(params) -- 770
		if path == "" then -- 770
			return {success = false, message = "read_file_range requires path"} -- 771
		end -- 771
		local ____params_startLine_9 = params.startLine -- 772
		if ____params_startLine_9 == nil then -- 772
			____params_startLine_9 = 0 -- 772
		end -- 772
		local startLine = __TS__Number(____params_startLine_9) -- 772
		local ____params_endLine_10 = params.endLine -- 773
		if ____params_endLine_10 == nil then -- 773
			____params_endLine_10 = 0 -- 773
		end -- 773
		local endLine = __TS__Number(____params_endLine_10) -- 773
		if startLine <= 0 or endLine <= 0 then -- 773
			return {success = false, message = "read_file_range requires positive startLine and endLine"} -- 775
		end -- 775
		if endLine < startLine then -- 775
			return {success = false, message = "read_file_range endLine must be >= startLine"} -- 778
		end -- 778
		return {success = true} -- 780
	end -- 780
	if tool == "edit_file" then -- 780
		local path = getDecisionPath(params) -- 784
		if path == "" then -- 784
			return {success = false, message = "edit_file requires path"} -- 785
		end -- 785
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 786
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 787
		if oldStr == newStr then -- 787
			return {success = false, message = "edit_file old_str and new_str must be different"} -- 789
		end -- 789
		return {success = true} -- 791
	end -- 791
	if tool == "delete_file" then -- 791
		local targetFile = getDecisionPath(params) -- 795
		if targetFile == "" then -- 795
			return {success = false, message = "delete_file requires target_file"} -- 796
		end -- 796
		return {success = true} -- 797
	end -- 797
	if tool == "grep_files" then -- 797
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 801
		if pattern == "" then -- 801
			return {success = false, message = "grep_files requires pattern"} -- 802
		end -- 802
		local ____params_limit_11 = params.limit -- 803
		if ____params_limit_11 == nil then -- 803
			____params_limit_11 = SEARCH_FILES_LIMIT_DEFAULT -- 803
		end -- 803
		local limit = __TS__Number(____params_limit_11) -- 803
		if limit <= 0 then -- 803
			return {success = false, message = "grep_files limit must be > 0"} -- 804
		end -- 804
		local ____params_offset_12 = params.offset -- 805
		if ____params_offset_12 == nil then -- 805
			____params_offset_12 = 0 -- 805
		end -- 805
		local offset = __TS__Number(____params_offset_12) -- 805
		if offset < 0 then -- 805
			return {success = false, message = "grep_files offset must be >= 0"} -- 806
		end -- 806
		return {success = true} -- 807
	end -- 807
	if tool == "search_dora_api" then -- 807
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 811
		if pattern == "" then -- 811
			return {success = false, message = "search_dora_api requires pattern"} -- 812
		end -- 812
		local ____params_limit_13 = params.limit -- 813
		if ____params_limit_13 == nil then -- 813
			____params_limit_13 = 8 -- 813
		end -- 813
		local limit = __TS__Number(____params_limit_13) -- 813
		if limit <= 0 or limit > SEARCH_DORA_API_LIMIT_MAX then -- 813
			return { -- 815
				success = false, -- 815
				message = "search_dora_api limit must be between 1 and " .. tostring(SEARCH_DORA_API_LIMIT_MAX) -- 815
			} -- 815
		end -- 815
		return {success = true} -- 817
	end -- 817
	if tool == "glob_files" then -- 817
		local ____params_maxEntries_14 = params.maxEntries -- 821
		if ____params_maxEntries_14 == nil then -- 821
			____params_maxEntries_14 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 821
		end -- 821
		local maxEntries = __TS__Number(____params_maxEntries_14) -- 821
		if maxEntries <= 0 then -- 821
			return {success = false, message = "glob_files maxEntries must be > 0"} -- 822
		end -- 822
		return {success = true} -- 823
	end -- 823
	if tool == "build" then -- 823
		if history and not canRunBuildAgain(history, params) then -- 823
			return {success = false, message = "build has already completed; inspect the build result or finish before building again"} -- 828
		end -- 828
		return {success = true} -- 830
	end -- 830
	return {success = true} -- 833
end -- 752
local function buildDecisionToolSchema() -- 836
	return {{type = "function", ["function"] = {name = "next_step", description = "Choose the next coding action for the agent.", parameters = {type = "object", properties = {tool = {type = "string", enum = { -- 837
		"read_file", -- 848
		"read_file_range", -- 849
		"edit_file", -- 850
		"delete_file", -- 851
		"grep_files", -- 852
		"search_dora_api", -- 853
		"glob_files", -- 854
		"build", -- 855
		"finish" -- 856
	}}, reason = {type = "string", description = "Explain why this is the next best action."}, params = {type = "object", description = "Shallow parameter object for the selected tool.", properties = { -- 856
		path = {type = "string"}, -- 867
		target_file = {type = "string"}, -- 868
		old_str = {type = "string"}, -- 869
		new_str = {type = "string"}, -- 870
		pattern = {type = "string"}, -- 871
		globs = {type = "array", items = {type = "string"}}, -- 872
		useRegex = {type = "boolean"}, -- 876
		caseSensitive = {type = "boolean"}, -- 877
		includeContent = {type = "boolean"}, -- 878
		contentWindow = {type = "number"}, -- 879
		offset = {type = "number"}, -- 880
		groupByFile = {type = "boolean"}, -- 881
		programmingLanguage = {type = "string", enum = { -- 882
			"ts", -- 884
			"tsx", -- 884
			"lua", -- 884
			"yue", -- 884
			"teal" -- 884
		}}, -- 884
		limit = {type = "number"}, -- 886
		startLine = {type = "number"}, -- 887
		endLine = {type = "number"}, -- 888
		maxEntries = {type = "number"} -- 889
	}}}, required = {"tool", "reason", "params"}}}}} -- 889
end -- 836
local function buildDecisionPrompt(shared, userQuery, historyText, memoryContext) -- 899
	return (((((((("You are a coding assistant that helps modify and navigate code.\nGiven the request and action history, decide which tool to use next.\n\n" .. memoryContext) .. "\n\nUser request: ") .. userQuery) .. "\n\nHere are the actions you performed:\n") .. historyText) .. "\n\nAvailable tools:\n1. read_file: Read content from a file with pagination\n\t- Parameters: path (workspace-relative), offset(optional), limit(optional)\n\t- Prefer small reads and continue with a new offset (>= 1) when needed.\n1b. read_file_range: Read specific line range from a file\n\t- Parameters: path, startLine, endLine\n\t- Line starts with 1.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine API docs\n\t- Parameters: pattern, programmingLanguage(ts/tsx/lua/yue/teal), limit(optional)\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= ") .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".\n\n7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- After one build completes, do not run build again unless files were edited/deleted. Read the result and then finish or take corrective action.\n\n8. finish: End and summarize\n\t- Parameters: {}\n\nDecision rules:\n- Choose exactly one next action.\n- Keep params shallow and valid for the selected tool.\n- Prefer reading/searching before editing when information is missing.\n- After any search tool returns candidate files or docs, use read_file or read_file_range to inspect search result details instead of repeatedly broadening search.\n- Use glob_files to discover candidate files. Use grep_files only when you need to search file contents.\n- Use finish only when no more actions are needed.\n") .. getReplyLanguageDirective(shared) -- 900
end -- 899
local function replaceAllAndCount(text, oldStr, newStr) -- 968
	if oldStr == "" then -- 968
		return {content = text, replaced = 0} -- 969
	end -- 969
	local count = 0 -- 970
	local from = 0 -- 971
	while true do -- 971
		local idx = (string.find( -- 973
			text, -- 973
			oldStr, -- 973
			math.max(from + 1, 1), -- 973
			true -- 973
		) or 0) - 1 -- 973
		if idx < 0 then -- 973
			break -- 974
		end -- 974
		count = count + 1 -- 975
		from = idx + #oldStr -- 976
	end -- 976
	if count == 0 then -- 976
		return {content = text, replaced = 0} -- 978
	end -- 978
	return { -- 979
		content = table.concat( -- 980
			__TS__StringSplit(text, oldStr), -- 980
			newStr or "," -- 980
		), -- 980
		replaced = count -- 981
	} -- 981
end -- 968
local MainDecisionAgent = __TS__Class() -- 985
MainDecisionAgent.name = "MainDecisionAgent" -- 985
__TS__ClassExtends(MainDecisionAgent, Node) -- 985
function MainDecisionAgent.prototype.prep(self, shared) -- 986
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 986
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 986
			return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 986
		end -- 986
		__TS__Await(maybeCompressHistory(shared)) -- 995
		return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 995
	end) -- 995
end -- 986
function MainDecisionAgent.prototype.getSystemPrompt(self) -- 1004
	return getDecisionSystemPrompt() -- 1005
end -- 1004
function MainDecisionAgent.prototype.getToolDefinitions(self) -- 1008
	return getDecisionToolDefinitions() -- 1009
end -- 1008
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, prompt, lastError) -- 1012
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1012
		if shared.stopToken.stopped then -- 1012
			return ____awaiter_resolve( -- 1012
				nil, -- 1012
				{ -- 1018
					success = false, -- 1018
					message = getCancelledReason(shared) -- 1018
				} -- 1018
			) -- 1018
		end -- 1018
		Log( -- 1020
			"Info", -- 1020
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1020
		) -- 1020
		local tools = buildDecisionToolSchema() -- 1021
		local messages = { -- 1022
			{ -- 1023
				role = "system", -- 1024
				content = table.concat( -- 1025
					{ -- 1025
						"You are a coding assistant that must decide the next action by calling the next_step tool exactly once.", -- 1026
						"Do not answer with plain text.", -- 1027
						getReplyLanguageDirective(shared) -- 1028
					}, -- 1028
					"\n" -- 1029
				) -- 1029
			}, -- 1029
			{role = "user", content = lastError and ((prompt .. "\n\nPrevious tool call was invalid (") .. lastError) .. "). Retry with one valid next_step tool call only." or prompt} -- 1031
		} -- 1031
		local res = __TS__Await(callLLM( -- 1038
			messages, -- 1038
			__TS__ObjectAssign({}, shared.llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "next_step"}}}), -- 1038
			shared.stopToken -- 1042
		)) -- 1042
		if shared.stopToken.stopped then -- 1042
			return ____awaiter_resolve( -- 1042
				nil, -- 1042
				{ -- 1044
					success = false, -- 1044
					message = getCancelledReason(shared) -- 1044
				} -- 1044
			) -- 1044
		end -- 1044
		if not res.success then -- 1044
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1047
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1047
		end -- 1047
		local choice = res.response.choices and res.response.choices[1] -- 1050
		local message = choice and choice.message -- 1051
		local toolCalls = message and message.tool_calls -- 1052
		local toolCall = toolCalls and toolCalls[1] -- 1053
		local fn = toolCall and toolCall["function"] -- 1054
		local messageContent = message and type(message.content) == "string" and message.content or nil -- 1055
		Log( -- 1056
			"Info", -- 1056
			(((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0) -- 1056
		) -- 1056
		if not fn or fn.name ~= "next_step" then -- 1056
			Log("Error", "[CodingAgent] missing next_step tool call") -- 1058
			return ____awaiter_resolve(nil, {success = false, message = "missing next_step tool call", raw = messageContent}) -- 1058
		end -- 1058
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1065
		Log( -- 1066
			"Info", -- 1066
			(("[CodingAgent] tool-calling function=" .. fn.name) .. " args_len=") .. tostring(#argsText) -- 1066
		) -- 1066
		if __TS__StringTrim(argsText) == "" then -- 1066
			Log("Error", "[CodingAgent] empty next_step tool arguments") -- 1068
			return ____awaiter_resolve(nil, {success = false, message = "empty next_step tool arguments"}) -- 1068
		end -- 1068
		local rawObj, err = json.decode(argsText) -- 1071
		if err ~= nil or rawObj == nil or type(rawObj) ~= "table" then -- 1071
			Log( -- 1073
				"Error", -- 1073
				"[CodingAgent] invalid next_step tool arguments JSON: " .. tostring(err) -- 1073
			) -- 1073
			return ____awaiter_resolve( -- 1073
				nil, -- 1073
				{ -- 1074
					success = false, -- 1075
					message = "invalid next_step tool arguments: " .. tostring(err), -- 1076
					raw = argsText -- 1077
				} -- 1077
			) -- 1077
		end -- 1077
		local decision = parseDecisionObject(rawObj) -- 1080
		if not decision.success then -- 1080
			Log("Error", "[CodingAgent] invalid next_step tool arguments schema: " .. decision.message) -- 1082
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1082
		end -- 1082
		local validation = validateDecision(decision.tool, decision.params, shared.history) -- 1089
		if not validation.success then -- 1089
			Log("Error", "[CodingAgent] invalid next_step tool arguments values: " .. validation.message) -- 1091
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1091
		end -- 1091
		Log( -- 1098
			"Info", -- 1098
			(("[CodingAgent] tool-calling selected tool=" .. decision.tool) .. " reason_len=") .. tostring(#decision.reason) -- 1098
		) -- 1098
		return ____awaiter_resolve(nil, decision) -- 1098
	end) -- 1098
end -- 1012
function MainDecisionAgent.prototype.exec(self, input) -- 1102
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1102
		local shared = input.shared -- 1103
		if shared.stopToken.stopped then -- 1103
			return ____awaiter_resolve( -- 1103
				nil, -- 1103
				{ -- 1105
					success = false, -- 1105
					message = getCancelledReason(shared) -- 1105
				} -- 1105
			) -- 1105
		end -- 1105
		local memory = shared.memory -- 1105
		local memoryContext = memory.compressor:getStorage():getMemoryContext() -- 1110
		local uncompressedHistory = __TS__ArraySlice(input.history, memory.lastConsolidatedIndex) -- 1115
		local historyText = formatHistorySummaryForDecision(uncompressedHistory) -- 1116
		local prompt = buildDecisionPrompt(input.shared, input.userQuery, historyText, memoryContext) -- 1118
		if shared.decisionMode == "tool_calling" then -- 1118
			Log( -- 1121
				"Info", -- 1121
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " history=") .. tostring(#uncompressedHistory) -- 1121
			) -- 1121
			local lastError = "tool calling validation failed" -- 1122
			local lastRaw = "" -- 1123
			do -- 1123
				local attempt = 0 -- 1124
				while attempt < shared.llmMaxTry do -- 1124
					Log( -- 1125
						"Info", -- 1125
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1125
					) -- 1125
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, prompt, attempt > 0 and lastError or nil)) -- 1126
					if shared.stopToken.stopped then -- 1126
						return ____awaiter_resolve( -- 1126
							nil, -- 1126
							{ -- 1132
								success = false, -- 1132
								message = getCancelledReason(shared) -- 1132
							} -- 1132
						) -- 1132
					end -- 1132
					if decision.success then -- 1132
						return ____awaiter_resolve(nil, decision) -- 1132
					end -- 1132
					lastError = decision.message -- 1137
					lastRaw = decision.raw or "" -- 1138
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1139
					attempt = attempt + 1 -- 1124
				end -- 1124
			end -- 1124
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1141
			return ____awaiter_resolve( -- 1141
				nil, -- 1141
				{ -- 1142
					success = false, -- 1142
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1142
				} -- 1142
			) -- 1142
		end -- 1142
		local yamlPrompt = prompt .. "\n\nRespond with one YAML object:\n```yaml\n'tool: \"edit_file\"\nreason: |-\n\tA readable multi-line explanation is allowed.\n\tKeep indentation consistent.\nparams:\n\tpath: \"relative/path.ts\"\n\told_str: |-\n\t\tfunction oldName() {\n\t\t\tprint(\"old\");\n\t\t}\n\tnew_str: |-\n\t\tfunction newName() {\n\t\t\tprint(\"hello\");\n\t\t}\n```\nStrict YAML formatting rules:\n- Return YAML only, no prose before/after.\n- Use exactly one YAML object with keys: tool, reason, params.\n- Multi-line strings are allowed using block scalars (`|`, `|-`, `>`).\n- If using a block scalar, all content lines must be indented consistently with tabs.\n- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.\n- Keep params shallow and valid for the selected tool.\n- Use tabs for all indentation, never spaces.\nIf no more actions are needed, use tool: finish." -- 1145
		local lastError = "yaml validation failed" -- 1174
		local lastRaw = "" -- 1175
		do -- 1175
			local attempt = 0 -- 1176
			while attempt < shared.llmMaxTry do -- 1176
				do -- 1176
					local feedback = attempt > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only and keep YAML indentation strictly consistent." or "" -- 1177
					local messages = {{role = "user", content = yamlPrompt .. feedback}} -- 1180
					local llmRes = __TS__Await(llm(shared, messages)) -- 1181
					if shared.stopToken.stopped then -- 1181
						return ____awaiter_resolve( -- 1181
							nil, -- 1181
							{ -- 1183
								success = false, -- 1183
								message = getCancelledReason(shared) -- 1183
							} -- 1183
						) -- 1183
					end -- 1183
					if not llmRes.success then -- 1183
						lastError = llmRes.message -- 1186
						goto __continue217 -- 1187
					end -- 1187
					lastRaw = llmRes.text -- 1189
					local parsed = parseYAMLObjectFromText(llmRes.text) -- 1190
					if not parsed.success then -- 1190
						lastError = parsed.message -- 1192
						goto __continue217 -- 1193
					end -- 1193
					local decision = parseDecisionObject(parsed.obj) -- 1195
					if not decision.success then -- 1195
						lastError = decision.message -- 1197
						goto __continue217 -- 1198
					end -- 1198
					local validation = validateDecision(decision.tool, decision.params, input.history) -- 1200
					if not validation.success then -- 1200
						lastError = validation.message -- 1202
						goto __continue217 -- 1203
					end -- 1203
					return ____awaiter_resolve(nil, decision) -- 1203
				end -- 1203
				::__continue217:: -- 1203
				attempt = attempt + 1 -- 1176
			end -- 1176
		end -- 1176
		return ____awaiter_resolve( -- 1176
			nil, -- 1176
			{ -- 1207
				success = false, -- 1207
				message = (("cannot produce valid decision yaml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1207
			} -- 1207
		) -- 1207
	end) -- 1207
end -- 1102
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1210
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1210
		local result = execRes -- 1211
		if not result.success then -- 1211
			shared.error = result.message -- 1213
			return ____awaiter_resolve(nil, "error") -- 1213
		end -- 1213
		emitAgentEvent(shared, { -- 1216
			type = "decision_made", -- 1217
			sessionId = shared.sessionId, -- 1218
			taskId = shared.taskId, -- 1219
			step = shared.step + 1, -- 1220
			tool = result.tool, -- 1221
			reason = result.reason, -- 1222
			params = result.params -- 1223
		}) -- 1223
		shared.lastDecision = {tool = result.tool, reason = result.reason, params = result.params} -- 1225
		local ____shared_history_15 = shared.history -- 1225
		____shared_history_15[#____shared_history_15 + 1] = { -- 1230
			step = shared.step + 1, -- 1231
			tool = result.tool, -- 1232
			reason = result.reason, -- 1233
			params = result.params, -- 1234
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1235
		} -- 1235
		return ____awaiter_resolve(nil, result.tool) -- 1235
	end) -- 1235
end -- 1210
local ReadFileAction = __TS__Class() -- 1241
ReadFileAction.name = "ReadFileAction" -- 1241
__TS__ClassExtends(ReadFileAction, Node) -- 1241
function ReadFileAction.prototype.prep(self, shared) -- 1242
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1242
		local last = shared.history[#shared.history] -- 1243
		if not last then -- 1243
			error( -- 1244
				__TS__New(Error, "no history"), -- 1244
				0 -- 1244
			) -- 1244
		end -- 1244
		emitAgentEvent(shared, { -- 1245
			type = "tool_started", -- 1246
			sessionId = shared.sessionId, -- 1247
			taskId = shared.taskId, -- 1248
			step = shared.step + 1, -- 1249
			tool = last.tool -- 1250
		}) -- 1250
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1252
		if __TS__StringTrim(path) == "" then -- 1252
			error( -- 1255
				__TS__New(Error, "missing path"), -- 1255
				0 -- 1255
			) -- 1255
		end -- 1255
		if last.tool == "read_file_range" then -- 1255
			local ____path_20 = path -- 1258
			local ____last_tool_21 = last.tool -- 1259
			local ____shared_workingDir_22 = shared.workingDir -- 1260
			local ____last_params_startLine_16 = last.params.startLine -- 1262
			if ____last_params_startLine_16 == nil then -- 1262
				____last_params_startLine_16 = 1 -- 1262
			end -- 1262
			local ____TS__Number_result_19 = __TS__Number(____last_params_startLine_16) -- 1262
			local ____last_params_endLine_17 = last.params.endLine -- 1263
			if ____last_params_endLine_17 == nil then -- 1263
				____last_params_endLine_17 = last.params.startLine -- 1263
			end -- 1263
			local ____last_params_endLine_17_18 = ____last_params_endLine_17 -- 1263
			if ____last_params_endLine_17_18 == nil then -- 1263
				____last_params_endLine_17_18 = 1 -- 1263
			end -- 1263
			return ____awaiter_resolve( -- 1263
				nil, -- 1263
				{ -- 1257
					path = ____path_20, -- 1258
					tool = ____last_tool_21, -- 1259
					workDir = ____shared_workingDir_22, -- 1260
					range = { -- 1261
						startLine = ____TS__Number_result_19, -- 1262
						endLine = __TS__Number(____last_params_endLine_17_18) -- 1263
					} -- 1263
				} -- 1263
			) -- 1263
		end -- 1263
		local ____path_25 = path -- 1268
		local ____shared_workingDir_26 = shared.workingDir -- 1270
		local ____last_params_offset_23 = last.params.offset -- 1271
		if ____last_params_offset_23 == nil then -- 1271
			____last_params_offset_23 = 1 -- 1271
		end -- 1271
		local ____TS__Number_result_27 = __TS__Number(____last_params_offset_23) -- 1271
		local ____last_params_limit_24 = last.params.limit -- 1272
		if ____last_params_limit_24 == nil then -- 1272
			____last_params_limit_24 = READ_FILE_DEFAULT_LIMIT -- 1272
		end -- 1272
		return ____awaiter_resolve( -- 1272
			nil, -- 1272
			{ -- 1267
				path = ____path_25, -- 1268
				tool = "read_file", -- 1269
				workDir = ____shared_workingDir_26, -- 1270
				offset = ____TS__Number_result_27, -- 1271
				limit = __TS__Number(____last_params_limit_24) -- 1272
			} -- 1272
		) -- 1272
	end) -- 1272
end -- 1242
function ReadFileAction.prototype.exec(self, input) -- 1276
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1276
		if input.tool == "read_file_range" and input.range then -- 1276
			return ____awaiter_resolve( -- 1276
				nil, -- 1276
				Tools.readFileRange(input.workDir, input.path, input.range.startLine, input.range.endLine) -- 1278
			) -- 1278
		end -- 1278
		return ____awaiter_resolve( -- 1278
			nil, -- 1278
			Tools.readFile( -- 1280
				input.workDir, -- 1281
				input.path, -- 1282
				__TS__Number(input.offset or 1), -- 1283
				__TS__Number(input.limit or READ_FILE_DEFAULT_LIMIT) -- 1284
			) -- 1284
		) -- 1284
	end) -- 1284
end -- 1276
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1288
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1288
		local result = execRes -- 1289
		local last = shared.history[#shared.history] -- 1290
		if last ~= nil then -- 1290
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1292
			emitAgentEvent(shared, { -- 1293
				type = "tool_finished", -- 1294
				sessionId = shared.sessionId, -- 1295
				taskId = shared.taskId, -- 1296
				step = shared.step + 1, -- 1297
				tool = last.tool, -- 1298
				result = last.result -- 1299
			}) -- 1299
		end -- 1299
		__TS__Await(maybeCompressHistory(shared)) -- 1302
		shared.step = shared.step + 1 -- 1303
		return ____awaiter_resolve(nil, "main") -- 1303
	end) -- 1303
end -- 1288
local SearchFilesAction = __TS__Class() -- 1308
SearchFilesAction.name = "SearchFilesAction" -- 1308
__TS__ClassExtends(SearchFilesAction, Node) -- 1308
function SearchFilesAction.prototype.prep(self, shared) -- 1309
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1309
		local last = shared.history[#shared.history] -- 1310
		if not last then -- 1310
			error( -- 1311
				__TS__New(Error, "no history"), -- 1311
				0 -- 1311
			) -- 1311
		end -- 1311
		emitAgentEvent(shared, { -- 1312
			type = "tool_started", -- 1313
			sessionId = shared.sessionId, -- 1314
			taskId = shared.taskId, -- 1315
			step = shared.step + 1, -- 1316
			tool = last.tool -- 1317
		}) -- 1317
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1317
	end) -- 1317
end -- 1309
function SearchFilesAction.prototype.exec(self, input) -- 1322
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1322
		local params = input.params -- 1323
		local ____Tools_searchFiles_44 = Tools.searchFiles -- 1324
		local ____input_workDir_35 = input.workDir -- 1325
		local ____temp_36 = params.path or "" -- 1326
		local ____temp_37 = params.pattern or "" -- 1327
		local ____params_globs_38 = params.globs -- 1328
		local ____params_useRegex_39 = params.useRegex -- 1329
		local ____params_caseSensitive_40 = params.caseSensitive -- 1330
		local ____params_includeContent_41 = params.includeContent -- 1331
		local ____params_contentWindow_28 = params.contentWindow -- 1332
		if ____params_contentWindow_28 == nil then -- 1332
			____params_contentWindow_28 = 120 -- 1332
		end -- 1332
		local ____TS__Number_result_42 = __TS__Number(____params_contentWindow_28) -- 1332
		local ____math_max_31 = math.max -- 1333
		local ____math_floor_30 = math.floor -- 1333
		local ____params_limit_29 = params.limit -- 1333
		if ____params_limit_29 == nil then -- 1333
			____params_limit_29 = SEARCH_FILES_LIMIT_DEFAULT -- 1333
		end -- 1333
		local ____math_max_31_result_43 = ____math_max_31( -- 1333
			1, -- 1333
			____math_floor_30(__TS__Number(____params_limit_29)) -- 1333
		) -- 1333
		local ____math_max_34 = math.max -- 1334
		local ____math_floor_33 = math.floor -- 1334
		local ____params_offset_32 = params.offset -- 1334
		if ____params_offset_32 == nil then -- 1334
			____params_offset_32 = 0 -- 1334
		end -- 1334
		local result = __TS__Await(____Tools_searchFiles_44({ -- 1324
			workDir = ____input_workDir_35, -- 1325
			path = ____temp_36, -- 1326
			pattern = ____temp_37, -- 1327
			globs = ____params_globs_38, -- 1328
			useRegex = ____params_useRegex_39, -- 1329
			caseSensitive = ____params_caseSensitive_40, -- 1330
			includeContent = ____params_includeContent_41, -- 1331
			contentWindow = ____TS__Number_result_42, -- 1332
			limit = ____math_max_31_result_43, -- 1333
			offset = ____math_max_34( -- 1334
				0, -- 1334
				____math_floor_33(__TS__Number(____params_offset_32)) -- 1334
			), -- 1334
			groupByFile = params.groupByFile == true -- 1335
		})) -- 1335
		return ____awaiter_resolve(nil, result) -- 1335
	end) -- 1335
end -- 1322
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1340
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1340
		local last = shared.history[#shared.history] -- 1341
		if last ~= nil then -- 1341
			local result = execRes -- 1343
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1344
			emitAgentEvent(shared, { -- 1345
				type = "tool_finished", -- 1346
				sessionId = shared.sessionId, -- 1347
				taskId = shared.taskId, -- 1348
				step = shared.step + 1, -- 1349
				tool = last.tool, -- 1350
				result = last.result -- 1351
			}) -- 1351
		end -- 1351
		__TS__Await(maybeCompressHistory(shared)) -- 1354
		shared.step = shared.step + 1 -- 1355
		return ____awaiter_resolve(nil, "main") -- 1355
	end) -- 1355
end -- 1340
local SearchDoraAPIAction = __TS__Class() -- 1360
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1360
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1360
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1361
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1361
		local last = shared.history[#shared.history] -- 1362
		if not last then -- 1362
			error( -- 1363
				__TS__New(Error, "no history"), -- 1363
				0 -- 1363
			) -- 1363
		end -- 1363
		emitAgentEvent(shared, { -- 1364
			type = "tool_started", -- 1365
			sessionId = shared.sessionId, -- 1366
			taskId = shared.taskId, -- 1367
			step = shared.step + 1, -- 1368
			tool = last.tool -- 1369
		}) -- 1369
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1369
	end) -- 1369
end -- 1361
function SearchDoraAPIAction.prototype.exec(self, input) -- 1374
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1374
		local params = input.params -- 1375
		local ____Tools_searchDoraAPI_56 = Tools.searchDoraAPI -- 1376
		local ____temp_49 = params.pattern or "" -- 1377
		local ____temp_50 = input.useChineseResponse and "zh" or "en" -- 1378
		local ____temp_51 = params.programmingLanguage or "ts" -- 1379
		local ____math_min_47 = math.min -- 1380
		local ____math_max_46 = math.max -- 1380
		local ____params_limit_45 = params.limit -- 1380
		if ____params_limit_45 == nil then -- 1380
			____params_limit_45 = 8 -- 1380
		end -- 1380
		local ____math_min_47_result_52 = ____math_min_47( -- 1380
			SEARCH_DORA_API_LIMIT_MAX, -- 1380
			____math_max_46( -- 1380
				1, -- 1380
				__TS__Number(____params_limit_45) -- 1380
			) -- 1380
		) -- 1380
		local ____params_useRegex_53 = params.useRegex -- 1381
		local ____params_caseSensitive_54 = params.caseSensitive -- 1382
		local ____params_includeContent_55 = params.includeContent -- 1383
		local ____params_contentWindow_48 = params.contentWindow -- 1384
		if ____params_contentWindow_48 == nil then -- 1384
			____params_contentWindow_48 = 140 -- 1384
		end -- 1384
		local result = __TS__Await(____Tools_searchDoraAPI_56({ -- 1376
			pattern = ____temp_49, -- 1377
			docLanguage = ____temp_50, -- 1378
			programmingLanguage = ____temp_51, -- 1379
			limit = ____math_min_47_result_52, -- 1380
			useRegex = ____params_useRegex_53, -- 1381
			caseSensitive = ____params_caseSensitive_54, -- 1382
			includeContent = ____params_includeContent_55, -- 1383
			contentWindow = __TS__Number(____params_contentWindow_48) -- 1384
		})) -- 1384
		return ____awaiter_resolve(nil, result) -- 1384
	end) -- 1384
end -- 1374
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1389
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1389
		local last = shared.history[#shared.history] -- 1390
		if last ~= nil then -- 1390
			local result = execRes -- 1392
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1393
			emitAgentEvent(shared, { -- 1394
				type = "tool_finished", -- 1395
				sessionId = shared.sessionId, -- 1396
				taskId = shared.taskId, -- 1397
				step = shared.step + 1, -- 1398
				tool = last.tool, -- 1399
				result = last.result -- 1400
			}) -- 1400
		end -- 1400
		__TS__Await(maybeCompressHistory(shared)) -- 1403
		shared.step = shared.step + 1 -- 1404
		return ____awaiter_resolve(nil, "main") -- 1404
	end) -- 1404
end -- 1389
local ListFilesAction = __TS__Class() -- 1409
ListFilesAction.name = "ListFilesAction" -- 1409
__TS__ClassExtends(ListFilesAction, Node) -- 1409
function ListFilesAction.prototype.prep(self, shared) -- 1410
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1410
		local last = shared.history[#shared.history] -- 1411
		if not last then -- 1411
			error( -- 1412
				__TS__New(Error, "no history"), -- 1412
				0 -- 1412
			) -- 1412
		end -- 1412
		emitAgentEvent(shared, { -- 1413
			type = "tool_started", -- 1414
			sessionId = shared.sessionId, -- 1415
			taskId = shared.taskId, -- 1416
			step = shared.step + 1, -- 1417
			tool = last.tool -- 1418
		}) -- 1418
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1418
	end) -- 1418
end -- 1410
function ListFilesAction.prototype.exec(self, input) -- 1423
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1423
		local params = input.params -- 1424
		local ____Tools_listFiles_63 = Tools.listFiles -- 1425
		local ____input_workDir_60 = input.workDir -- 1426
		local ____temp_61 = params.path or "" -- 1427
		local ____params_globs_62 = params.globs -- 1428
		local ____math_max_59 = math.max -- 1429
		local ____math_floor_58 = math.floor -- 1429
		local ____params_maxEntries_57 = params.maxEntries -- 1429
		if ____params_maxEntries_57 == nil then -- 1429
			____params_maxEntries_57 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1429
		end -- 1429
		local result = ____Tools_listFiles_63({ -- 1425
			workDir = ____input_workDir_60, -- 1426
			path = ____temp_61, -- 1427
			globs = ____params_globs_62, -- 1428
			maxEntries = ____math_max_59( -- 1429
				1, -- 1429
				____math_floor_58(__TS__Number(____params_maxEntries_57)) -- 1429
			) -- 1429
		}) -- 1429
		return ____awaiter_resolve(nil, result) -- 1429
	end) -- 1429
end -- 1423
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1434
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1434
		local last = shared.history[#shared.history] -- 1435
		if last ~= nil then -- 1435
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1437
			emitAgentEvent(shared, { -- 1438
				type = "tool_finished", -- 1439
				sessionId = shared.sessionId, -- 1440
				taskId = shared.taskId, -- 1441
				step = shared.step + 1, -- 1442
				tool = last.tool, -- 1443
				result = last.result -- 1444
			}) -- 1444
		end -- 1444
		__TS__Await(maybeCompressHistory(shared)) -- 1447
		shared.step = shared.step + 1 -- 1448
		return ____awaiter_resolve(nil, "main") -- 1448
	end) -- 1448
end -- 1434
local DeleteFileAction = __TS__Class() -- 1453
DeleteFileAction.name = "DeleteFileAction" -- 1453
__TS__ClassExtends(DeleteFileAction, Node) -- 1453
function DeleteFileAction.prototype.prep(self, shared) -- 1454
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
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1464
		if __TS__StringTrim(targetFile) == "" then -- 1464
			error( -- 1467
				__TS__New(Error, "missing target_file"), -- 1467
				0 -- 1467
			) -- 1467
		end -- 1467
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1467
	end) -- 1467
end -- 1454
function DeleteFileAction.prototype.exec(self, input) -- 1471
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1471
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1472
		if not result.success then -- 1472
			return ____awaiter_resolve(nil, result) -- 1472
		end -- 1472
		return ____awaiter_resolve(nil, { -- 1472
			success = true, -- 1480
			changed = true, -- 1481
			mode = "delete", -- 1482
			checkpointId = result.checkpointId, -- 1483
			checkpointSeq = result.checkpointSeq, -- 1484
			files = {{path = input.targetFile, op = "delete"}} -- 1485
		}) -- 1485
	end) -- 1485
end -- 1471
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1489
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1489
		local last = shared.history[#shared.history] -- 1490
		if last ~= nil then -- 1490
			last.result = execRes -- 1492
			emitAgentEvent(shared, { -- 1493
				type = "tool_finished", -- 1494
				sessionId = shared.sessionId, -- 1495
				taskId = shared.taskId, -- 1496
				step = shared.step + 1, -- 1497
				tool = last.tool, -- 1498
				result = last.result -- 1499
			}) -- 1499
			local result = last.result -- 1501
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1501
				emitAgentEvent(shared, { -- 1506
					type = "checkpoint_created", -- 1507
					sessionId = shared.sessionId, -- 1508
					taskId = shared.taskId, -- 1509
					step = shared.step + 1, -- 1510
					tool = "delete_file", -- 1511
					checkpointId = result.checkpointId, -- 1512
					checkpointSeq = result.checkpointSeq, -- 1513
					files = result.files -- 1514
				}) -- 1514
			end -- 1514
		end -- 1514
		__TS__Await(maybeCompressHistory(shared)) -- 1518
		shared.step = shared.step + 1 -- 1519
		return ____awaiter_resolve(nil, "main") -- 1519
	end) -- 1519
end -- 1489
local BuildAction = __TS__Class() -- 1524
BuildAction.name = "BuildAction" -- 1524
__TS__ClassExtends(BuildAction, Node) -- 1524
function BuildAction.prototype.prep(self, shared) -- 1525
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1525
		local last = shared.history[#shared.history] -- 1526
		if not last then -- 1526
			error( -- 1527
				__TS__New(Error, "no history"), -- 1527
				0 -- 1527
			) -- 1527
		end -- 1527
		emitAgentEvent(shared, { -- 1528
			type = "tool_started", -- 1529
			sessionId = shared.sessionId, -- 1530
			taskId = shared.taskId, -- 1531
			step = shared.step + 1, -- 1532
			tool = last.tool -- 1533
		}) -- 1533
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1533
	end) -- 1533
end -- 1525
function BuildAction.prototype.exec(self, input) -- 1538
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1538
		local params = input.params -- 1539
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1540
		return ____awaiter_resolve(nil, result) -- 1540
	end) -- 1540
end -- 1538
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1547
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1547
		local last = shared.history[#shared.history] -- 1548
		if last ~= nil then -- 1548
			local followupHint = shared.useChineseResponse and "构建已完成，将根据结果做后续处理，不再重复构建。" or "Build completed. Shall handle the result instead of building again." -- 1550
			local reason = last.reason -- 1550
			last.reason = last.reason and last.reason ~= "" and (last.reason .. "\n") .. followupHint or followupHint -- 1554
			last.result = execRes -- 1557
			emitAgentEvent(shared, { -- 1558
				type = "tool_finished", -- 1559
				sessionId = shared.sessionId, -- 1560
				taskId = shared.taskId, -- 1561
				step = shared.step + 1, -- 1562
				tool = last.tool, -- 1563
				reason = reason, -- 1564
				result = last.result -- 1565
			}) -- 1565
		end -- 1565
		__TS__Await(maybeCompressHistory(shared)) -- 1568
		shared.step = shared.step + 1 -- 1569
		return ____awaiter_resolve(nil, "main") -- 1569
	end) -- 1569
end -- 1547
local EditFileAction = __TS__Class() -- 1574
EditFileAction.name = "EditFileAction" -- 1574
__TS__ClassExtends(EditFileAction, Node) -- 1574
function EditFileAction.prototype.prep(self, shared) -- 1575
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1575
		local last = shared.history[#shared.history] -- 1576
		if not last then -- 1576
			error( -- 1577
				__TS__New(Error, "no history"), -- 1577
				0 -- 1577
			) -- 1577
		end -- 1577
		emitAgentEvent(shared, { -- 1578
			type = "tool_started", -- 1579
			sessionId = shared.sessionId, -- 1580
			taskId = shared.taskId, -- 1581
			step = shared.step + 1, -- 1582
			tool = last.tool -- 1583
		}) -- 1583
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1585
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1588
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1589
		if __TS__StringTrim(path) == "" then -- 1589
			error( -- 1590
				__TS__New(Error, "missing path"), -- 1590
				0 -- 1590
			) -- 1590
		end -- 1590
		if oldStr == newStr then -- 1590
			error( -- 1591
				__TS__New(Error, "old_str and new_str must be different"), -- 1591
				0 -- 1591
			) -- 1591
		end -- 1591
		return ____awaiter_resolve(nil, { -- 1591
			path = path, -- 1592
			oldStr = oldStr, -- 1592
			newStr = newStr, -- 1592
			taskId = shared.taskId, -- 1592
			workDir = shared.workingDir -- 1592
		}) -- 1592
	end) -- 1592
end -- 1575
function EditFileAction.prototype.exec(self, input) -- 1595
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1595
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1596
		if not readRes.success then -- 1596
			if input.oldStr ~= "" then -- 1596
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1596
			end -- 1596
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1601
			if not createRes.success then -- 1601
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1601
			end -- 1601
			return ____awaiter_resolve(nil, { -- 1601
				success = true, -- 1609
				changed = true, -- 1610
				mode = "create", -- 1611
				replaced = 0, -- 1612
				checkpointId = createRes.checkpointId, -- 1613
				checkpointSeq = createRes.checkpointSeq, -- 1614
				files = {{path = input.path, op = "create"}} -- 1615
			}) -- 1615
		end -- 1615
		if input.oldStr == "" then -- 1615
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 1615
		end -- 1615
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 1622
		if replaceRes.replaced == 0 then -- 1622
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 1622
		end -- 1622
		if replaceRes.content == readRes.content then -- 1622
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 1622
		end -- 1622
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1635
		if not applyRes.success then -- 1635
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1635
		end -- 1635
		return ____awaiter_resolve(nil, { -- 1635
			success = true, -- 1643
			changed = true, -- 1644
			mode = "replace", -- 1645
			replaced = replaceRes.replaced, -- 1646
			checkpointId = applyRes.checkpointId, -- 1647
			checkpointSeq = applyRes.checkpointSeq, -- 1648
			files = {{path = input.path, op = "write"}} -- 1649
		}) -- 1649
	end) -- 1649
end -- 1595
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1653
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1653
		local last = shared.history[#shared.history] -- 1654
		if last ~= nil then -- 1654
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1656
			last.result = execRes -- 1657
			emitAgentEvent(shared, { -- 1658
				type = "tool_finished", -- 1659
				sessionId = shared.sessionId, -- 1660
				taskId = shared.taskId, -- 1661
				step = shared.step + 1, -- 1662
				tool = last.tool, -- 1663
				result = last.result -- 1664
			}) -- 1664
			local result = last.result -- 1666
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1666
				emitAgentEvent(shared, { -- 1671
					type = "checkpoint_created", -- 1672
					sessionId = shared.sessionId, -- 1673
					taskId = shared.taskId, -- 1674
					step = shared.step + 1, -- 1675
					tool = last.tool, -- 1676
					checkpointId = result.checkpointId, -- 1677
					checkpointSeq = result.checkpointSeq, -- 1678
					files = result.files -- 1679
				}) -- 1679
			end -- 1679
		end -- 1679
		__TS__Await(maybeCompressHistory(shared)) -- 1683
		shared.step = shared.step + 1 -- 1684
		return ____awaiter_resolve(nil, "main") -- 1684
	end) -- 1684
end -- 1653
local FormatResponseNode = __TS__Class() -- 1689
FormatResponseNode.name = "FormatResponseNode" -- 1689
__TS__ClassExtends(FormatResponseNode, Node) -- 1689
function FormatResponseNode.prototype.prep(self, shared) -- 1690
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1690
		local last = shared.history[#shared.history] -- 1691
		if last and last.tool == "finish" then -- 1691
			emitAgentEvent(shared, { -- 1693
				type = "tool_started", -- 1694
				sessionId = shared.sessionId, -- 1695
				taskId = shared.taskId, -- 1696
				step = shared.step + 1, -- 1697
				tool = last.tool -- 1698
			}) -- 1698
		end -- 1698
		return ____awaiter_resolve(nil, {history = shared.history, shared = shared}) -- 1698
	end) -- 1698
end -- 1690
function FormatResponseNode.prototype.exec(self, input) -- 1704
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1704
		if input.shared.stopToken.stopped then -- 1704
			return ____awaiter_resolve( -- 1704
				nil, -- 1704
				getCancelledReason(input.shared) -- 1706
			) -- 1706
		end -- 1706
		local history = input.history -- 1708
		if #history == 0 then -- 1708
			return ____awaiter_resolve(nil, "No actions were performed.") -- 1708
		end -- 1708
		local summary = formatHistorySummary(history) -- 1712
		local prompt = (("You are a coding assistant. Summarize what you did for the user.\n\nHere are the actions you performed:\n" .. summary) .. "\n\nGenerate a concise response that explains:\n1. What actions were taken\n2. What was found or modified\n3. Any next steps\n\nIMPORTANT:\n- Focus on outcomes, not tool names.\n- Speak directly to the user.\n") .. getReplyLanguageDirective(input.shared) -- 1713
		local res -- 1727
		do -- 1727
			local i = 0 -- 1728
			while i < input.shared.llmMaxTry do -- 1728
				res = __TS__Await(llmStream(input.shared, {{role = "user", content = prompt}})) -- 1729
				if res.success then -- 1729
					break -- 1730
				end -- 1730
				i = i + 1 -- 1728
			end -- 1728
		end -- 1728
		if not res then -- 1728
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败。" or "Completed, but failed to generate summary.") -- 1728
		end -- 1728
		if not res.success then -- 1728
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败：" .. res.message or "Completed, but failed to generate summary: " .. res.message) -- 1728
		end -- 1728
		return ____awaiter_resolve(nil, res.text) -- 1728
	end) -- 1728
end -- 1704
function FormatResponseNode.prototype.post(self, shared, _prepRes, execRes) -- 1743
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1743
		local last = shared.history[#shared.history] -- 1744
		if last and last.tool == "finish" then -- 1744
			last.result = {success = true, message = execRes} -- 1746
			emitAgentEvent(shared, { -- 1747
				type = "tool_finished", -- 1748
				sessionId = shared.sessionId, -- 1749
				taskId = shared.taskId, -- 1750
				step = shared.step + 1, -- 1751
				tool = last.tool, -- 1752
				result = last.result -- 1753
			}) -- 1753
			shared.step = shared.step + 1 -- 1755
		end -- 1755
		shared.response = execRes -- 1757
		shared.done = true -- 1758
		return ____awaiter_resolve(nil, nil) -- 1758
	end) -- 1758
end -- 1743
local CodingAgentFlow = __TS__Class() -- 1763
CodingAgentFlow.name = "CodingAgentFlow" -- 1763
__TS__ClassExtends(CodingAgentFlow, Flow) -- 1763
function CodingAgentFlow.prototype.____constructor(self) -- 1764
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 1765
	local read = __TS__New(ReadFileAction, 1, 0) -- 1766
	local search = __TS__New(SearchFilesAction, 1, 0) -- 1767
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 1768
	local list = __TS__New(ListFilesAction, 1, 0) -- 1769
	local del = __TS__New(DeleteFileAction, 1, 0) -- 1770
	local build = __TS__New(BuildAction, 1, 0) -- 1771
	local edit = __TS__New(EditFileAction, 1, 0) -- 1772
	local format = __TS__New(FormatResponseNode, 1, 0) -- 1773
	main:on("read_file", read) -- 1775
	main:on("read_file_range", read) -- 1776
	main:on("grep_files", search) -- 1777
	main:on("search_dora_api", searchDora) -- 1778
	main:on("glob_files", list) -- 1779
	main:on("delete_file", del) -- 1780
	main:on("build", build) -- 1781
	main:on("edit_file", edit) -- 1782
	main:on("finish", format) -- 1783
	main:on("error", format) -- 1784
	read:on("main", main) -- 1786
	search:on("main", main) -- 1787
	searchDora:on("main", main) -- 1788
	list:on("main", main) -- 1789
	del:on("main", main) -- 1790
	build:on("main", main) -- 1791
	edit:on("main", main) -- 1792
	Flow.prototype.____constructor(self, main) -- 1794
end -- 1764
local function runCodingAgentAsync(options) -- 1798
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1798
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 1798
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 1798
		end -- 1798
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 1802
		if not taskRes.success then -- 1802
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 1802
		end -- 1802
		local compressor = __TS__New(MemoryCompressor, {contextWindow = options.memoryContext or 32000, compressionThreshold = 0.8, projectDir = options.workDir}) -- 1810
		local shared = { -- 1816
			sessionId = options.sessionId, -- 1817
			taskId = taskRes.taskId, -- 1818
			maxSteps = math.max( -- 1819
				1, -- 1819
				math.floor(options.maxSteps or 40) -- 1819
			), -- 1819
			llmMaxTry = math.max( -- 1820
				1, -- 1820
				math.floor(options.llmMaxTry or 3) -- 1820
			), -- 1820
			step = 0, -- 1821
			done = false, -- 1822
			stopToken = options.stopToken or ({stopped = false}), -- 1823
			response = "", -- 1824
			userQuery = options.prompt, -- 1825
			workingDir = options.workDir, -- 1826
			useChineseResponse = options.useChineseResponse == true, -- 1827
			decisionMode = options.decisionMode == "yaml" and "yaml" or "tool_calling", -- 1828
			llmOptions = __TS__ObjectAssign({temperature = 0.2}, options.llmOptions or ({})), -- 1829
			onEvent = options.onEvent, -- 1833
			history = {}, -- 1834
			memory = {lastConsolidatedIndex = 0, compressor = compressor} -- 1836
		} -- 1836
		local ____try = __TS__AsyncAwaiter(function() -- 1836
			emitAgentEvent(shared, { -- 1843
				type = "task_started", -- 1844
				sessionId = shared.sessionId, -- 1845
				taskId = shared.taskId, -- 1846
				prompt = shared.userQuery, -- 1847
				workDir = shared.workingDir, -- 1848
				maxSteps = shared.maxSteps -- 1849
			}) -- 1849
			if shared.stopToken.stopped then -- 1849
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1852
				local result = { -- 1853
					success = false, -- 1853
					taskId = shared.taskId, -- 1853
					message = getCancelledReason(shared), -- 1853
					steps = shared.step -- 1853
				} -- 1853
				emitAgentEvent(shared, { -- 1854
					type = "task_finished", -- 1855
					sessionId = shared.sessionId, -- 1856
					taskId = shared.taskId, -- 1857
					success = false, -- 1858
					message = result.message, -- 1859
					steps = result.steps -- 1860
				}) -- 1860
				return ____awaiter_resolve(nil, result) -- 1860
			end -- 1860
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 1864
			local flow = __TS__New(CodingAgentFlow) -- 1865
			__TS__Await(flow:run(shared)) -- 1866
			if shared.stopToken.stopped then -- 1866
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1868
				local result = { -- 1869
					success = false, -- 1869
					taskId = shared.taskId, -- 1869
					message = getCancelledReason(shared), -- 1869
					steps = shared.step -- 1869
				} -- 1869
				emitAgentEvent(shared, { -- 1870
					type = "task_finished", -- 1871
					sessionId = shared.sessionId, -- 1872
					taskId = shared.taskId, -- 1873
					success = false, -- 1874
					message = result.message, -- 1875
					steps = result.steps -- 1876
				}) -- 1876
				return ____awaiter_resolve(nil, result) -- 1876
			end -- 1876
			if shared.error then -- 1876
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1881
				local result = {success = false, taskId = shared.taskId, message = shared.error, steps = shared.step} -- 1882
				emitAgentEvent(shared, { -- 1883
					type = "task_finished", -- 1884
					sessionId = shared.sessionId, -- 1885
					taskId = shared.taskId, -- 1886
					success = false, -- 1887
					message = result.message, -- 1888
					steps = result.steps -- 1889
				}) -- 1889
				return ____awaiter_resolve(nil, result) -- 1889
			end -- 1889
			Tools.setTaskStatus(shared.taskId, "DONE") -- 1893
			local result = {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step} -- 1894
			emitAgentEvent(shared, { -- 1900
				type = "task_finished", -- 1901
				sessionId = shared.sessionId, -- 1902
				taskId = shared.taskId, -- 1903
				success = true, -- 1904
				message = result.message, -- 1905
				steps = result.steps -- 1906
			}) -- 1906
			return ____awaiter_resolve(nil, result) -- 1906
		end) -- 1906
		__TS__Await(____try.catch( -- 1842
			____try, -- 1842
			function(____, e) -- 1842
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1910
				local result = { -- 1911
					success = false, -- 1911
					taskId = shared.taskId, -- 1911
					message = tostring(e), -- 1911
					steps = shared.step -- 1911
				} -- 1911
				emitAgentEvent(shared, { -- 1912
					type = "task_finished", -- 1913
					sessionId = shared.sessionId, -- 1914
					taskId = shared.taskId, -- 1915
					success = false, -- 1916
					message = result.message, -- 1917
					steps = result.steps -- 1918
				}) -- 1918
				return ____awaiter_resolve(nil, result) -- 1918
			end -- 1918
		)) -- 1918
	end) -- 1918
end -- 1798
function ____exports.runCodingAgent(options, callback) -- 1924
	local ____self_64 = runCodingAgentAsync(options) -- 1924
	____self_64["then"]( -- 1924
		____self_64, -- 1924
		function(____, result) return callback(result) end -- 1925
	) -- 1925
end -- 1924
return ____exports -- 1924