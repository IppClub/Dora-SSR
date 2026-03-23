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
local DEFAULT_AGENT_PROMPT = ____Memory.DEFAULT_AGENT_PROMPT -- 7
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
local function buildDecisionPrompt(shared, userQuery, historyText, memoryContext, agentPrompt) -- 899
	return ((((((((((agentPrompt or DEFAULT_AGENT_PROMPT) .. "\nGiven the request and action history, decide which tool to use next.\n\n") .. memoryContext) .. "\n\nUser request: ") .. userQuery) .. "\n\nHere are the actions you performed:\n") .. historyText) .. "\n\nAvailable tools:\n1. read_file: Read content from a file with pagination\n\t- Parameters: path (workspace-relative), offset(optional), limit(optional)\n\t- Prefer small reads and continue with a new offset (>= 1) when needed.\n1b. read_file_range: Read specific line range from a file\n\t- Parameters: path, startLine, endLine\n\t- Line starts with 1.\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. grep_files: Search text patterns inside files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional)\n\t- `path` may point to either a directory or a single file.\n\t- This is content search (grep), not filename search.\n\t- `pattern` matches file contents. `globs` only restrict which files are searched.\n\t- `useRegex` defaults to false. Set `useRegex=true` when `pattern` is a regular expression such as `^title:`.\n\t- `caseSensitive` defaults to false.\n\t- Use `|` inside pattern to separate alternative content queries; results are merged by union (OR), not AND.\n\t- Search results are intentionally capped. Refine the pattern or read a specific file next.\n\t- Use `offset` to continue browsing later pages of the same search.\n\t- Use `groupByFile=true` to rank candidate files before drilling into one file.\n\n5. glob_files: Enumerate files under a directory\n\t- Parameters: path, globs(optional), maxEntries(optional)\n\t- Use this to discover files by path, extension, or glob pattern.\n\t- Directory listings are intentionally capped. Narrow the path before expanding further.\n\n6. search_dora_api: Search Dora SSR game engine API docs\n\t- Parameters: pattern, programmingLanguage(ts/tsx/lua/yue/teal), limit(optional)\n\t- Use `|` inside pattern to separate alternative queries; results are merged by union (OR), not AND.\n\t- `useRegex` defaults to false whenever supported by a search tool.\n\t- `limit` restricts each individual pattern search and must be <= ") .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".\n\n7. build: Run build/checks for ts/tsx, teal, lua, yue, yarn\n\t- Parameters: path(optional)\n\t- After one build completes, do not run build again unless files were edited/deleted. Read the result and then finish or take corrective action.\n\n8. finish: End and summarize\n\t- Parameters: {}\n\nDecision rules:\n- Choose exactly one next action.\n- Keep params shallow and valid for the selected tool.\n- Prefer reading/searching before editing when information is missing.\n- After any search tool returns candidate files or docs, use read_file or read_file_range to inspect search result details instead of repeatedly broadening search.\n- Use glob_files to discover candidate files. Use grep_files only when you need to search file contents.\n- Use finish only when no more actions are needed.\n") .. getReplyLanguageDirective(shared) -- 900
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
		local agentPrompt = memory.compressor:getStorage():readAgentPrompt() -- 1113
		local uncompressedHistory = __TS__ArraySlice(input.history, memory.lastConsolidatedIndex) -- 1118
		local historyText = formatHistorySummaryForDecision(uncompressedHistory) -- 1119
		local prompt = buildDecisionPrompt( -- 1121
			input.shared, -- 1121
			input.userQuery, -- 1121
			historyText, -- 1121
			memoryContext, -- 1121
			agentPrompt -- 1121
		) -- 1121
		if shared.decisionMode == "tool_calling" then -- 1121
			Log( -- 1124
				"Info", -- 1124
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " history=") .. tostring(#uncompressedHistory) -- 1124
			) -- 1124
			local lastError = "tool calling validation failed" -- 1125
			local lastRaw = "" -- 1126
			do -- 1126
				local attempt = 0 -- 1127
				while attempt < shared.llmMaxTry do -- 1127
					Log( -- 1128
						"Info", -- 1128
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1128
					) -- 1128
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, prompt, attempt > 0 and lastError or nil)) -- 1129
					if shared.stopToken.stopped then -- 1129
						return ____awaiter_resolve( -- 1129
							nil, -- 1129
							{ -- 1135
								success = false, -- 1135
								message = getCancelledReason(shared) -- 1135
							} -- 1135
						) -- 1135
					end -- 1135
					if decision.success then -- 1135
						return ____awaiter_resolve(nil, decision) -- 1135
					end -- 1135
					lastError = decision.message -- 1140
					lastRaw = decision.raw or "" -- 1141
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1142
					attempt = attempt + 1 -- 1127
				end -- 1127
			end -- 1127
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1144
			return ____awaiter_resolve( -- 1144
				nil, -- 1144
				{ -- 1145
					success = false, -- 1145
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1145
				} -- 1145
			) -- 1145
		end -- 1145
		local yamlPrompt = prompt .. "\n\nRespond with one YAML object:\n```yaml\n'tool: \"edit_file\"\nreason: |-\n\tA readable multi-line explanation is allowed.\n\tKeep indentation consistent.\nparams:\n\tpath: \"relative/path.ts\"\n\told_str: |-\n\t\tfunction oldName() {\n\t\t\tprint(\"old\");\n\t\t}\n\tnew_str: |-\n\t\tfunction newName() {\n\t\t\tprint(\"hello\");\n\t\t}\n```\nStrict YAML formatting rules:\n- Return YAML only, no prose before/after.\n- Use exactly one YAML object with keys: tool, reason, params.\n- Multi-line strings are allowed using block scalars (`|`, `|-`, `>`).\n- If using a block scalar, all content lines must be indented consistently with tabs.\n- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.\n- Keep params shallow and valid for the selected tool.\n- Use tabs for all indentation, never spaces.\nIf no more actions are needed, use tool: finish." -- 1148
		local lastError = "yaml validation failed" -- 1177
		local lastRaw = "" -- 1178
		do -- 1178
			local attempt = 0 -- 1179
			while attempt < shared.llmMaxTry do -- 1179
				do -- 1179
					local feedback = attempt > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only and keep YAML indentation strictly consistent." or "" -- 1180
					local messages = {{role = "user", content = yamlPrompt .. feedback}} -- 1183
					local llmRes = __TS__Await(llm(shared, messages)) -- 1184
					if shared.stopToken.stopped then -- 1184
						return ____awaiter_resolve( -- 1184
							nil, -- 1184
							{ -- 1186
								success = false, -- 1186
								message = getCancelledReason(shared) -- 1186
							} -- 1186
						) -- 1186
					end -- 1186
					if not llmRes.success then -- 1186
						lastError = llmRes.message -- 1189
						goto __continue217 -- 1190
					end -- 1190
					lastRaw = llmRes.text -- 1192
					local parsed = parseYAMLObjectFromText(llmRes.text) -- 1193
					if not parsed.success then -- 1193
						lastError = parsed.message -- 1195
						goto __continue217 -- 1196
					end -- 1196
					local decision = parseDecisionObject(parsed.obj) -- 1198
					if not decision.success then -- 1198
						lastError = decision.message -- 1200
						goto __continue217 -- 1201
					end -- 1201
					local validation = validateDecision(decision.tool, decision.params, input.history) -- 1203
					if not validation.success then -- 1203
						lastError = validation.message -- 1205
						goto __continue217 -- 1206
					end -- 1206
					return ____awaiter_resolve(nil, decision) -- 1206
				end -- 1206
				::__continue217:: -- 1206
				attempt = attempt + 1 -- 1179
			end -- 1179
		end -- 1179
		return ____awaiter_resolve( -- 1179
			nil, -- 1179
			{ -- 1210
				success = false, -- 1210
				message = (("cannot produce valid decision yaml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1210
			} -- 1210
		) -- 1210
	end) -- 1210
end -- 1102
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1213
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1213
		local result = execRes -- 1214
		if not result.success then -- 1214
			shared.error = result.message -- 1216
			return ____awaiter_resolve(nil, "error") -- 1216
		end -- 1216
		emitAgentEvent(shared, { -- 1219
			type = "decision_made", -- 1220
			sessionId = shared.sessionId, -- 1221
			taskId = shared.taskId, -- 1222
			step = shared.step + 1, -- 1223
			tool = result.tool, -- 1224
			reason = result.reason, -- 1225
			params = result.params -- 1226
		}) -- 1226
		shared.lastDecision = {tool = result.tool, reason = result.reason, params = result.params} -- 1228
		local ____shared_history_15 = shared.history -- 1228
		____shared_history_15[#____shared_history_15 + 1] = { -- 1233
			step = shared.step + 1, -- 1234
			tool = result.tool, -- 1235
			reason = result.reason, -- 1236
			params = result.params, -- 1237
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1238
		} -- 1238
		return ____awaiter_resolve(nil, result.tool) -- 1238
	end) -- 1238
end -- 1213
local ReadFileAction = __TS__Class() -- 1244
ReadFileAction.name = "ReadFileAction" -- 1244
__TS__ClassExtends(ReadFileAction, Node) -- 1244
function ReadFileAction.prototype.prep(self, shared) -- 1245
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1245
		local last = shared.history[#shared.history] -- 1246
		if not last then -- 1246
			error( -- 1247
				__TS__New(Error, "no history"), -- 1247
				0 -- 1247
			) -- 1247
		end -- 1247
		emitAgentEvent(shared, { -- 1248
			type = "tool_started", -- 1249
			sessionId = shared.sessionId, -- 1250
			taskId = shared.taskId, -- 1251
			step = shared.step + 1, -- 1252
			tool = last.tool -- 1253
		}) -- 1253
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1255
		if __TS__StringTrim(path) == "" then -- 1255
			error( -- 1258
				__TS__New(Error, "missing path"), -- 1258
				0 -- 1258
			) -- 1258
		end -- 1258
		if last.tool == "read_file_range" then -- 1258
			local ____path_20 = path -- 1261
			local ____last_tool_21 = last.tool -- 1262
			local ____shared_workingDir_22 = shared.workingDir -- 1263
			local ____last_params_startLine_16 = last.params.startLine -- 1265
			if ____last_params_startLine_16 == nil then -- 1265
				____last_params_startLine_16 = 1 -- 1265
			end -- 1265
			local ____TS__Number_result_19 = __TS__Number(____last_params_startLine_16) -- 1265
			local ____last_params_endLine_17 = last.params.endLine -- 1266
			if ____last_params_endLine_17 == nil then -- 1266
				____last_params_endLine_17 = last.params.startLine -- 1266
			end -- 1266
			local ____last_params_endLine_17_18 = ____last_params_endLine_17 -- 1266
			if ____last_params_endLine_17_18 == nil then -- 1266
				____last_params_endLine_17_18 = 1 -- 1266
			end -- 1266
			return ____awaiter_resolve( -- 1266
				nil, -- 1266
				{ -- 1260
					path = ____path_20, -- 1261
					tool = ____last_tool_21, -- 1262
					workDir = ____shared_workingDir_22, -- 1263
					range = { -- 1264
						startLine = ____TS__Number_result_19, -- 1265
						endLine = __TS__Number(____last_params_endLine_17_18) -- 1266
					} -- 1266
				} -- 1266
			) -- 1266
		end -- 1266
		local ____path_25 = path -- 1271
		local ____shared_workingDir_26 = shared.workingDir -- 1273
		local ____last_params_offset_23 = last.params.offset -- 1274
		if ____last_params_offset_23 == nil then -- 1274
			____last_params_offset_23 = 1 -- 1274
		end -- 1274
		local ____TS__Number_result_27 = __TS__Number(____last_params_offset_23) -- 1274
		local ____last_params_limit_24 = last.params.limit -- 1275
		if ____last_params_limit_24 == nil then -- 1275
			____last_params_limit_24 = READ_FILE_DEFAULT_LIMIT -- 1275
		end -- 1275
		return ____awaiter_resolve( -- 1275
			nil, -- 1275
			{ -- 1270
				path = ____path_25, -- 1271
				tool = "read_file", -- 1272
				workDir = ____shared_workingDir_26, -- 1273
				offset = ____TS__Number_result_27, -- 1274
				limit = __TS__Number(____last_params_limit_24) -- 1275
			} -- 1275
		) -- 1275
	end) -- 1275
end -- 1245
function ReadFileAction.prototype.exec(self, input) -- 1279
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1279
		if input.tool == "read_file_range" and input.range then -- 1279
			return ____awaiter_resolve( -- 1279
				nil, -- 1279
				Tools.readFileRange(input.workDir, input.path, input.range.startLine, input.range.endLine) -- 1281
			) -- 1281
		end -- 1281
		return ____awaiter_resolve( -- 1281
			nil, -- 1281
			Tools.readFile( -- 1283
				input.workDir, -- 1284
				input.path, -- 1285
				__TS__Number(input.offset or 1), -- 1286
				__TS__Number(input.limit or READ_FILE_DEFAULT_LIMIT) -- 1287
			) -- 1287
		) -- 1287
	end) -- 1287
end -- 1279
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1291
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1291
		local result = execRes -- 1292
		local last = shared.history[#shared.history] -- 1293
		if last ~= nil then -- 1293
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1295
			emitAgentEvent(shared, { -- 1296
				type = "tool_finished", -- 1297
				sessionId = shared.sessionId, -- 1298
				taskId = shared.taskId, -- 1299
				step = shared.step + 1, -- 1300
				tool = last.tool, -- 1301
				result = last.result -- 1302
			}) -- 1302
		end -- 1302
		__TS__Await(maybeCompressHistory(shared)) -- 1305
		shared.step = shared.step + 1 -- 1306
		return ____awaiter_resolve(nil, "main") -- 1306
	end) -- 1306
end -- 1291
local SearchFilesAction = __TS__Class() -- 1311
SearchFilesAction.name = "SearchFilesAction" -- 1311
__TS__ClassExtends(SearchFilesAction, Node) -- 1311
function SearchFilesAction.prototype.prep(self, shared) -- 1312
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1312
		local last = shared.history[#shared.history] -- 1313
		if not last then -- 1313
			error( -- 1314
				__TS__New(Error, "no history"), -- 1314
				0 -- 1314
			) -- 1314
		end -- 1314
		emitAgentEvent(shared, { -- 1315
			type = "tool_started", -- 1316
			sessionId = shared.sessionId, -- 1317
			taskId = shared.taskId, -- 1318
			step = shared.step + 1, -- 1319
			tool = last.tool -- 1320
		}) -- 1320
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1320
	end) -- 1320
end -- 1312
function SearchFilesAction.prototype.exec(self, input) -- 1325
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1325
		local params = input.params -- 1326
		local ____Tools_searchFiles_44 = Tools.searchFiles -- 1327
		local ____input_workDir_35 = input.workDir -- 1328
		local ____temp_36 = params.path or "" -- 1329
		local ____temp_37 = params.pattern or "" -- 1330
		local ____params_globs_38 = params.globs -- 1331
		local ____params_useRegex_39 = params.useRegex -- 1332
		local ____params_caseSensitive_40 = params.caseSensitive -- 1333
		local ____params_includeContent_41 = params.includeContent -- 1334
		local ____params_contentWindow_28 = params.contentWindow -- 1335
		if ____params_contentWindow_28 == nil then -- 1335
			____params_contentWindow_28 = 120 -- 1335
		end -- 1335
		local ____TS__Number_result_42 = __TS__Number(____params_contentWindow_28) -- 1335
		local ____math_max_31 = math.max -- 1336
		local ____math_floor_30 = math.floor -- 1336
		local ____params_limit_29 = params.limit -- 1336
		if ____params_limit_29 == nil then -- 1336
			____params_limit_29 = SEARCH_FILES_LIMIT_DEFAULT -- 1336
		end -- 1336
		local ____math_max_31_result_43 = ____math_max_31( -- 1336
			1, -- 1336
			____math_floor_30(__TS__Number(____params_limit_29)) -- 1336
		) -- 1336
		local ____math_max_34 = math.max -- 1337
		local ____math_floor_33 = math.floor -- 1337
		local ____params_offset_32 = params.offset -- 1337
		if ____params_offset_32 == nil then -- 1337
			____params_offset_32 = 0 -- 1337
		end -- 1337
		local result = __TS__Await(____Tools_searchFiles_44({ -- 1327
			workDir = ____input_workDir_35, -- 1328
			path = ____temp_36, -- 1329
			pattern = ____temp_37, -- 1330
			globs = ____params_globs_38, -- 1331
			useRegex = ____params_useRegex_39, -- 1332
			caseSensitive = ____params_caseSensitive_40, -- 1333
			includeContent = ____params_includeContent_41, -- 1334
			contentWindow = ____TS__Number_result_42, -- 1335
			limit = ____math_max_31_result_43, -- 1336
			offset = ____math_max_34( -- 1337
				0, -- 1337
				____math_floor_33(__TS__Number(____params_offset_32)) -- 1337
			), -- 1337
			groupByFile = params.groupByFile == true -- 1338
		})) -- 1338
		return ____awaiter_resolve(nil, result) -- 1338
	end) -- 1338
end -- 1325
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1343
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1343
		local last = shared.history[#shared.history] -- 1344
		if last ~= nil then -- 1344
			local result = execRes -- 1346
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1347
			emitAgentEvent(shared, { -- 1348
				type = "tool_finished", -- 1349
				sessionId = shared.sessionId, -- 1350
				taskId = shared.taskId, -- 1351
				step = shared.step + 1, -- 1352
				tool = last.tool, -- 1353
				result = last.result -- 1354
			}) -- 1354
		end -- 1354
		__TS__Await(maybeCompressHistory(shared)) -- 1357
		shared.step = shared.step + 1 -- 1358
		return ____awaiter_resolve(nil, "main") -- 1358
	end) -- 1358
end -- 1343
local SearchDoraAPIAction = __TS__Class() -- 1363
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1363
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1363
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1364
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1364
		local last = shared.history[#shared.history] -- 1365
		if not last then -- 1365
			error( -- 1366
				__TS__New(Error, "no history"), -- 1366
				0 -- 1366
			) -- 1366
		end -- 1366
		emitAgentEvent(shared, { -- 1367
			type = "tool_started", -- 1368
			sessionId = shared.sessionId, -- 1369
			taskId = shared.taskId, -- 1370
			step = shared.step + 1, -- 1371
			tool = last.tool -- 1372
		}) -- 1372
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1372
	end) -- 1372
end -- 1364
function SearchDoraAPIAction.prototype.exec(self, input) -- 1377
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1377
		local params = input.params -- 1378
		local ____Tools_searchDoraAPI_56 = Tools.searchDoraAPI -- 1379
		local ____temp_49 = params.pattern or "" -- 1380
		local ____temp_50 = input.useChineseResponse and "zh" or "en" -- 1381
		local ____temp_51 = params.programmingLanguage or "ts" -- 1382
		local ____math_min_47 = math.min -- 1383
		local ____math_max_46 = math.max -- 1383
		local ____params_limit_45 = params.limit -- 1383
		if ____params_limit_45 == nil then -- 1383
			____params_limit_45 = 8 -- 1383
		end -- 1383
		local ____math_min_47_result_52 = ____math_min_47( -- 1383
			SEARCH_DORA_API_LIMIT_MAX, -- 1383
			____math_max_46( -- 1383
				1, -- 1383
				__TS__Number(____params_limit_45) -- 1383
			) -- 1383
		) -- 1383
		local ____params_useRegex_53 = params.useRegex -- 1384
		local ____params_caseSensitive_54 = params.caseSensitive -- 1385
		local ____params_includeContent_55 = params.includeContent -- 1386
		local ____params_contentWindow_48 = params.contentWindow -- 1387
		if ____params_contentWindow_48 == nil then -- 1387
			____params_contentWindow_48 = 140 -- 1387
		end -- 1387
		local result = __TS__Await(____Tools_searchDoraAPI_56({ -- 1379
			pattern = ____temp_49, -- 1380
			docLanguage = ____temp_50, -- 1381
			programmingLanguage = ____temp_51, -- 1382
			limit = ____math_min_47_result_52, -- 1383
			useRegex = ____params_useRegex_53, -- 1384
			caseSensitive = ____params_caseSensitive_54, -- 1385
			includeContent = ____params_includeContent_55, -- 1386
			contentWindow = __TS__Number(____params_contentWindow_48) -- 1387
		})) -- 1387
		return ____awaiter_resolve(nil, result) -- 1387
	end) -- 1387
end -- 1377
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1392
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1392
		local last = shared.history[#shared.history] -- 1393
		if last ~= nil then -- 1393
			local result = execRes -- 1395
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1396
			emitAgentEvent(shared, { -- 1397
				type = "tool_finished", -- 1398
				sessionId = shared.sessionId, -- 1399
				taskId = shared.taskId, -- 1400
				step = shared.step + 1, -- 1401
				tool = last.tool, -- 1402
				result = last.result -- 1403
			}) -- 1403
		end -- 1403
		__TS__Await(maybeCompressHistory(shared)) -- 1406
		shared.step = shared.step + 1 -- 1407
		return ____awaiter_resolve(nil, "main") -- 1407
	end) -- 1407
end -- 1392
local ListFilesAction = __TS__Class() -- 1412
ListFilesAction.name = "ListFilesAction" -- 1412
__TS__ClassExtends(ListFilesAction, Node) -- 1412
function ListFilesAction.prototype.prep(self, shared) -- 1413
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1413
		local last = shared.history[#shared.history] -- 1414
		if not last then -- 1414
			error( -- 1415
				__TS__New(Error, "no history"), -- 1415
				0 -- 1415
			) -- 1415
		end -- 1415
		emitAgentEvent(shared, { -- 1416
			type = "tool_started", -- 1417
			sessionId = shared.sessionId, -- 1418
			taskId = shared.taskId, -- 1419
			step = shared.step + 1, -- 1420
			tool = last.tool -- 1421
		}) -- 1421
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1421
	end) -- 1421
end -- 1413
function ListFilesAction.prototype.exec(self, input) -- 1426
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1426
		local params = input.params -- 1427
		local ____Tools_listFiles_63 = Tools.listFiles -- 1428
		local ____input_workDir_60 = input.workDir -- 1429
		local ____temp_61 = params.path or "" -- 1430
		local ____params_globs_62 = params.globs -- 1431
		local ____math_max_59 = math.max -- 1432
		local ____math_floor_58 = math.floor -- 1432
		local ____params_maxEntries_57 = params.maxEntries -- 1432
		if ____params_maxEntries_57 == nil then -- 1432
			____params_maxEntries_57 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1432
		end -- 1432
		local result = ____Tools_listFiles_63({ -- 1428
			workDir = ____input_workDir_60, -- 1429
			path = ____temp_61, -- 1430
			globs = ____params_globs_62, -- 1431
			maxEntries = ____math_max_59( -- 1432
				1, -- 1432
				____math_floor_58(__TS__Number(____params_maxEntries_57)) -- 1432
			) -- 1432
		}) -- 1432
		return ____awaiter_resolve(nil, result) -- 1432
	end) -- 1432
end -- 1426
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1437
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1437
		local last = shared.history[#shared.history] -- 1438
		if last ~= nil then -- 1438
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1440
			emitAgentEvent(shared, { -- 1441
				type = "tool_finished", -- 1442
				sessionId = shared.sessionId, -- 1443
				taskId = shared.taskId, -- 1444
				step = shared.step + 1, -- 1445
				tool = last.tool, -- 1446
				result = last.result -- 1447
			}) -- 1447
		end -- 1447
		__TS__Await(maybeCompressHistory(shared)) -- 1450
		shared.step = shared.step + 1 -- 1451
		return ____awaiter_resolve(nil, "main") -- 1451
	end) -- 1451
end -- 1437
local DeleteFileAction = __TS__Class() -- 1456
DeleteFileAction.name = "DeleteFileAction" -- 1456
__TS__ClassExtends(DeleteFileAction, Node) -- 1456
function DeleteFileAction.prototype.prep(self, shared) -- 1457
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1457
		local last = shared.history[#shared.history] -- 1458
		if not last then -- 1458
			error( -- 1459
				__TS__New(Error, "no history"), -- 1459
				0 -- 1459
			) -- 1459
		end -- 1459
		emitAgentEvent(shared, { -- 1460
			type = "tool_started", -- 1461
			sessionId = shared.sessionId, -- 1462
			taskId = shared.taskId, -- 1463
			step = shared.step + 1, -- 1464
			tool = last.tool -- 1465
		}) -- 1465
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1467
		if __TS__StringTrim(targetFile) == "" then -- 1467
			error( -- 1470
				__TS__New(Error, "missing target_file"), -- 1470
				0 -- 1470
			) -- 1470
		end -- 1470
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1470
	end) -- 1470
end -- 1457
function DeleteFileAction.prototype.exec(self, input) -- 1474
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1474
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1475
		if not result.success then -- 1475
			return ____awaiter_resolve(nil, result) -- 1475
		end -- 1475
		return ____awaiter_resolve(nil, { -- 1475
			success = true, -- 1483
			changed = true, -- 1484
			mode = "delete", -- 1485
			checkpointId = result.checkpointId, -- 1486
			checkpointSeq = result.checkpointSeq, -- 1487
			files = {{path = input.targetFile, op = "delete"}} -- 1488
		}) -- 1488
	end) -- 1488
end -- 1474
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1492
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1492
		local last = shared.history[#shared.history] -- 1493
		if last ~= nil then -- 1493
			last.result = execRes -- 1495
			emitAgentEvent(shared, { -- 1496
				type = "tool_finished", -- 1497
				sessionId = shared.sessionId, -- 1498
				taskId = shared.taskId, -- 1499
				step = shared.step + 1, -- 1500
				tool = last.tool, -- 1501
				result = last.result -- 1502
			}) -- 1502
			local result = last.result -- 1504
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1504
				emitAgentEvent(shared, { -- 1509
					type = "checkpoint_created", -- 1510
					sessionId = shared.sessionId, -- 1511
					taskId = shared.taskId, -- 1512
					step = shared.step + 1, -- 1513
					tool = "delete_file", -- 1514
					checkpointId = result.checkpointId, -- 1515
					checkpointSeq = result.checkpointSeq, -- 1516
					files = result.files -- 1517
				}) -- 1517
			end -- 1517
		end -- 1517
		__TS__Await(maybeCompressHistory(shared)) -- 1521
		shared.step = shared.step + 1 -- 1522
		return ____awaiter_resolve(nil, "main") -- 1522
	end) -- 1522
end -- 1492
local BuildAction = __TS__Class() -- 1527
BuildAction.name = "BuildAction" -- 1527
__TS__ClassExtends(BuildAction, Node) -- 1527
function BuildAction.prototype.prep(self, shared) -- 1528
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1528
		local last = shared.history[#shared.history] -- 1529
		if not last then -- 1529
			error( -- 1530
				__TS__New(Error, "no history"), -- 1530
				0 -- 1530
			) -- 1530
		end -- 1530
		emitAgentEvent(shared, { -- 1531
			type = "tool_started", -- 1532
			sessionId = shared.sessionId, -- 1533
			taskId = shared.taskId, -- 1534
			step = shared.step + 1, -- 1535
			tool = last.tool -- 1536
		}) -- 1536
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1536
	end) -- 1536
end -- 1528
function BuildAction.prototype.exec(self, input) -- 1541
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1541
		local params = input.params -- 1542
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1543
		return ____awaiter_resolve(nil, result) -- 1543
	end) -- 1543
end -- 1541
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1550
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1550
		local last = shared.history[#shared.history] -- 1551
		if last ~= nil then -- 1551
			local followupHint = shared.useChineseResponse and "构建已完成，将根据结果做后续处理，不再重复构建。" or "Build completed. Shall handle the result instead of building again." -- 1553
			local reason = last.reason -- 1553
			last.reason = last.reason and last.reason ~= "" and (last.reason .. "\n") .. followupHint or followupHint -- 1557
			last.result = execRes -- 1560
			emitAgentEvent(shared, { -- 1561
				type = "tool_finished", -- 1562
				sessionId = shared.sessionId, -- 1563
				taskId = shared.taskId, -- 1564
				step = shared.step + 1, -- 1565
				tool = last.tool, -- 1566
				reason = reason, -- 1567
				result = last.result -- 1568
			}) -- 1568
		end -- 1568
		__TS__Await(maybeCompressHistory(shared)) -- 1571
		shared.step = shared.step + 1 -- 1572
		return ____awaiter_resolve(nil, "main") -- 1572
	end) -- 1572
end -- 1550
local EditFileAction = __TS__Class() -- 1577
EditFileAction.name = "EditFileAction" -- 1577
__TS__ClassExtends(EditFileAction, Node) -- 1577
function EditFileAction.prototype.prep(self, shared) -- 1578
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1578
		local last = shared.history[#shared.history] -- 1579
		if not last then -- 1579
			error( -- 1580
				__TS__New(Error, "no history"), -- 1580
				0 -- 1580
			) -- 1580
		end -- 1580
		emitAgentEvent(shared, { -- 1581
			type = "tool_started", -- 1582
			sessionId = shared.sessionId, -- 1583
			taskId = shared.taskId, -- 1584
			step = shared.step + 1, -- 1585
			tool = last.tool -- 1586
		}) -- 1586
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1588
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1591
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1592
		if __TS__StringTrim(path) == "" then -- 1592
			error( -- 1593
				__TS__New(Error, "missing path"), -- 1593
				0 -- 1593
			) -- 1593
		end -- 1593
		if oldStr == newStr then -- 1593
			error( -- 1594
				__TS__New(Error, "old_str and new_str must be different"), -- 1594
				0 -- 1594
			) -- 1594
		end -- 1594
		return ____awaiter_resolve(nil, { -- 1594
			path = path, -- 1595
			oldStr = oldStr, -- 1595
			newStr = newStr, -- 1595
			taskId = shared.taskId, -- 1595
			workDir = shared.workingDir -- 1595
		}) -- 1595
	end) -- 1595
end -- 1578
function EditFileAction.prototype.exec(self, input) -- 1598
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1598
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1599
		if not readRes.success then -- 1599
			if input.oldStr ~= "" then -- 1599
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1599
			end -- 1599
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1604
			if not createRes.success then -- 1604
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1604
			end -- 1604
			return ____awaiter_resolve(nil, { -- 1604
				success = true, -- 1612
				changed = true, -- 1613
				mode = "create", -- 1614
				replaced = 0, -- 1615
				checkpointId = createRes.checkpointId, -- 1616
				checkpointSeq = createRes.checkpointSeq, -- 1617
				files = {{path = input.path, op = "create"}} -- 1618
			}) -- 1618
		end -- 1618
		if input.oldStr == "" then -- 1618
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 1618
		end -- 1618
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 1625
		if replaceRes.replaced == 0 then -- 1625
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 1625
		end -- 1625
		if replaceRes.content == readRes.content then -- 1625
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 1625
		end -- 1625
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1638
		if not applyRes.success then -- 1638
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1638
		end -- 1638
		return ____awaiter_resolve(nil, { -- 1638
			success = true, -- 1646
			changed = true, -- 1647
			mode = "replace", -- 1648
			replaced = replaceRes.replaced, -- 1649
			checkpointId = applyRes.checkpointId, -- 1650
			checkpointSeq = applyRes.checkpointSeq, -- 1651
			files = {{path = input.path, op = "write"}} -- 1652
		}) -- 1652
	end) -- 1652
end -- 1598
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1656
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1656
		local last = shared.history[#shared.history] -- 1657
		if last ~= nil then -- 1657
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1659
			last.result = execRes -- 1660
			emitAgentEvent(shared, { -- 1661
				type = "tool_finished", -- 1662
				sessionId = shared.sessionId, -- 1663
				taskId = shared.taskId, -- 1664
				step = shared.step + 1, -- 1665
				tool = last.tool, -- 1666
				result = last.result -- 1667
			}) -- 1667
			local result = last.result -- 1669
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1669
				emitAgentEvent(shared, { -- 1674
					type = "checkpoint_created", -- 1675
					sessionId = shared.sessionId, -- 1676
					taskId = shared.taskId, -- 1677
					step = shared.step + 1, -- 1678
					tool = last.tool, -- 1679
					checkpointId = result.checkpointId, -- 1680
					checkpointSeq = result.checkpointSeq, -- 1681
					files = result.files -- 1682
				}) -- 1682
			end -- 1682
		end -- 1682
		__TS__Await(maybeCompressHistory(shared)) -- 1686
		shared.step = shared.step + 1 -- 1687
		return ____awaiter_resolve(nil, "main") -- 1687
	end) -- 1687
end -- 1656
local FormatResponseNode = __TS__Class() -- 1692
FormatResponseNode.name = "FormatResponseNode" -- 1692
__TS__ClassExtends(FormatResponseNode, Node) -- 1692
function FormatResponseNode.prototype.prep(self, shared) -- 1693
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1693
		local last = shared.history[#shared.history] -- 1694
		if last and last.tool == "finish" then -- 1694
			emitAgentEvent(shared, { -- 1696
				type = "tool_started", -- 1697
				sessionId = shared.sessionId, -- 1698
				taskId = shared.taskId, -- 1699
				step = shared.step + 1, -- 1700
				tool = last.tool -- 1701
			}) -- 1701
		end -- 1701
		return ____awaiter_resolve(nil, {history = shared.history, shared = shared}) -- 1701
	end) -- 1701
end -- 1693
function FormatResponseNode.prototype.exec(self, input) -- 1707
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1707
		if input.shared.stopToken.stopped then -- 1707
			return ____awaiter_resolve( -- 1707
				nil, -- 1707
				getCancelledReason(input.shared) -- 1709
			) -- 1709
		end -- 1709
		local history = input.history -- 1711
		if #history == 0 then -- 1711
			return ____awaiter_resolve(nil, "No actions were performed.") -- 1711
		end -- 1711
		local summary = formatHistorySummary(history) -- 1715
		local prompt = (("You are a coding assistant. Summarize what you did for the user.\n\nHere are the actions you performed:\n" .. summary) .. "\n\nGenerate a concise response that explains:\n1. What actions were taken\n2. What was found or modified\n3. Any next steps\n\nIMPORTANT:\n- Focus on outcomes, not tool names.\n- Speak directly to the user.\n") .. getReplyLanguageDirective(input.shared) -- 1716
		local res -- 1730
		do -- 1730
			local i = 0 -- 1731
			while i < input.shared.llmMaxTry do -- 1731
				res = __TS__Await(llmStream(input.shared, {{role = "user", content = prompt}})) -- 1732
				if res.success then -- 1732
					break -- 1733
				end -- 1733
				i = i + 1 -- 1731
			end -- 1731
		end -- 1731
		if not res then -- 1731
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败。" or "Completed, but failed to generate summary.") -- 1731
		end -- 1731
		if not res.success then -- 1731
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败：" .. res.message or "Completed, but failed to generate summary: " .. res.message) -- 1731
		end -- 1731
		return ____awaiter_resolve(nil, res.text) -- 1731
	end) -- 1731
end -- 1707
function FormatResponseNode.prototype.post(self, shared, _prepRes, execRes) -- 1746
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1746
		local last = shared.history[#shared.history] -- 1747
		if last and last.tool == "finish" then -- 1747
			last.result = {success = true, message = execRes} -- 1749
			emitAgentEvent(shared, { -- 1750
				type = "tool_finished", -- 1751
				sessionId = shared.sessionId, -- 1752
				taskId = shared.taskId, -- 1753
				step = shared.step + 1, -- 1754
				tool = last.tool, -- 1755
				result = last.result -- 1756
			}) -- 1756
			shared.step = shared.step + 1 -- 1758
		end -- 1758
		shared.response = execRes -- 1760
		shared.done = true -- 1761
		return ____awaiter_resolve(nil, nil) -- 1761
	end) -- 1761
end -- 1746
local CodingAgentFlow = __TS__Class() -- 1766
CodingAgentFlow.name = "CodingAgentFlow" -- 1766
__TS__ClassExtends(CodingAgentFlow, Flow) -- 1766
function CodingAgentFlow.prototype.____constructor(self) -- 1767
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 1768
	local read = __TS__New(ReadFileAction, 1, 0) -- 1769
	local search = __TS__New(SearchFilesAction, 1, 0) -- 1770
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 1771
	local list = __TS__New(ListFilesAction, 1, 0) -- 1772
	local del = __TS__New(DeleteFileAction, 1, 0) -- 1773
	local build = __TS__New(BuildAction, 1, 0) -- 1774
	local edit = __TS__New(EditFileAction, 1, 0) -- 1775
	local format = __TS__New(FormatResponseNode, 1, 0) -- 1776
	main:on("read_file", read) -- 1778
	main:on("read_file_range", read) -- 1779
	main:on("grep_files", search) -- 1780
	main:on("search_dora_api", searchDora) -- 1781
	main:on("glob_files", list) -- 1782
	main:on("delete_file", del) -- 1783
	main:on("build", build) -- 1784
	main:on("edit_file", edit) -- 1785
	main:on("finish", format) -- 1786
	main:on("error", format) -- 1787
	read:on("main", main) -- 1789
	search:on("main", main) -- 1790
	searchDora:on("main", main) -- 1791
	list:on("main", main) -- 1792
	del:on("main", main) -- 1793
	build:on("main", main) -- 1794
	edit:on("main", main) -- 1795
	Flow.prototype.____constructor(self, main) -- 1797
end -- 1767
local function runCodingAgentAsync(options) -- 1801
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1801
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 1801
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 1801
		end -- 1801
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 1805
		if not taskRes.success then -- 1805
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 1805
		end -- 1805
		local compressor = __TS__New(MemoryCompressor, {contextWindow = options.memoryContext or 32000, compressionThreshold = 0.8, projectDir = options.workDir}) -- 1813
		local shared = { -- 1819
			sessionId = options.sessionId, -- 1820
			taskId = taskRes.taskId, -- 1821
			maxSteps = math.max( -- 1822
				1, -- 1822
				math.floor(options.maxSteps or 40) -- 1822
			), -- 1822
			llmMaxTry = math.max( -- 1823
				1, -- 1823
				math.floor(options.llmMaxTry or 3) -- 1823
			), -- 1823
			step = 0, -- 1824
			done = false, -- 1825
			stopToken = options.stopToken or ({stopped = false}), -- 1826
			response = "", -- 1827
			userQuery = options.prompt, -- 1828
			workingDir = options.workDir, -- 1829
			useChineseResponse = options.useChineseResponse == true, -- 1830
			decisionMode = options.decisionMode == "yaml" and "yaml" or "tool_calling", -- 1831
			llmOptions = __TS__ObjectAssign({temperature = 0.2}, options.llmOptions or ({})), -- 1832
			onEvent = options.onEvent, -- 1836
			history = {}, -- 1837
			memory = {lastConsolidatedIndex = 0, compressor = compressor} -- 1839
		} -- 1839
		local ____try = __TS__AsyncAwaiter(function() -- 1839
			emitAgentEvent(shared, { -- 1846
				type = "task_started", -- 1847
				sessionId = shared.sessionId, -- 1848
				taskId = shared.taskId, -- 1849
				prompt = shared.userQuery, -- 1850
				workDir = shared.workingDir, -- 1851
				maxSteps = shared.maxSteps -- 1852
			}) -- 1852
			if shared.stopToken.stopped then -- 1852
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1855
				local result = { -- 1856
					success = false, -- 1856
					taskId = shared.taskId, -- 1856
					message = getCancelledReason(shared), -- 1856
					steps = shared.step -- 1856
				} -- 1856
				emitAgentEvent(shared, { -- 1857
					type = "task_finished", -- 1858
					sessionId = shared.sessionId, -- 1859
					taskId = shared.taskId, -- 1860
					success = false, -- 1861
					message = result.message, -- 1862
					steps = result.steps -- 1863
				}) -- 1863
				return ____awaiter_resolve(nil, result) -- 1863
			end -- 1863
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 1867
			local flow = __TS__New(CodingAgentFlow) -- 1868
			__TS__Await(flow:run(shared)) -- 1869
			if shared.stopToken.stopped then -- 1869
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1871
				local result = { -- 1872
					success = false, -- 1872
					taskId = shared.taskId, -- 1872
					message = getCancelledReason(shared), -- 1872
					steps = shared.step -- 1872
				} -- 1872
				emitAgentEvent(shared, { -- 1873
					type = "task_finished", -- 1874
					sessionId = shared.sessionId, -- 1875
					taskId = shared.taskId, -- 1876
					success = false, -- 1877
					message = result.message, -- 1878
					steps = result.steps -- 1879
				}) -- 1879
				return ____awaiter_resolve(nil, result) -- 1879
			end -- 1879
			if shared.error then -- 1879
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1884
				local result = {success = false, taskId = shared.taskId, message = shared.error, steps = shared.step} -- 1885
				emitAgentEvent(shared, { -- 1886
					type = "task_finished", -- 1887
					sessionId = shared.sessionId, -- 1888
					taskId = shared.taskId, -- 1889
					success = false, -- 1890
					message = result.message, -- 1891
					steps = result.steps -- 1892
				}) -- 1892
				return ____awaiter_resolve(nil, result) -- 1892
			end -- 1892
			Tools.setTaskStatus(shared.taskId, "DONE") -- 1896
			local result = {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step} -- 1897
			emitAgentEvent(shared, { -- 1903
				type = "task_finished", -- 1904
				sessionId = shared.sessionId, -- 1905
				taskId = shared.taskId, -- 1906
				success = true, -- 1907
				message = result.message, -- 1908
				steps = result.steps -- 1909
			}) -- 1909
			return ____awaiter_resolve(nil, result) -- 1909
		end) -- 1909
		__TS__Await(____try.catch( -- 1845
			____try, -- 1845
			function(____, e) -- 1845
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1913
				local result = { -- 1914
					success = false, -- 1914
					taskId = shared.taskId, -- 1914
					message = tostring(e), -- 1914
					steps = shared.step -- 1914
				} -- 1914
				emitAgentEvent(shared, { -- 1915
					type = "task_finished", -- 1916
					sessionId = shared.sessionId, -- 1917
					taskId = shared.taskId, -- 1918
					success = false, -- 1919
					message = result.message, -- 1920
					steps = result.steps -- 1921
				}) -- 1921
				return ____awaiter_resolve(nil, result) -- 1921
			end -- 1921
		)) -- 1921
	end) -- 1921
end -- 1801
function ____exports.runCodingAgent(options, callback) -- 1927
	local ____self_64 = runCodingAgentAsync(options) -- 1927
	____self_64["then"]( -- 1927
		____self_64, -- 1927
		function(____, result) return callback(result) end -- 1928
	) -- 1928
end -- 1927
return ____exports -- 1927