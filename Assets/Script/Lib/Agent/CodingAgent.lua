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
function toJson(value) -- 183
	local text, err = json.encode(value) -- 184
	if text ~= nil then -- 184
		return text -- 185
	end -- 185
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 186
end -- 186
function truncateText(text, maxLen) -- 189
	if #text <= maxLen then -- 189
		return text -- 190
	end -- 190
	local nextPos = utf8.offset(text, maxLen + 1) -- 191
	if nextPos == nil then -- 191
		return text -- 192
	end -- 192
	return string.sub(text, 1, nextPos - 1) .. "..." -- 193
end -- 193
function utf8TakeHead(text, maxChars) -- 196
	if maxChars <= 0 or text == "" then -- 196
		return "" -- 197
	end -- 197
	local nextPos = utf8.offset(text, maxChars + 1) -- 198
	if nextPos == nil then -- 198
		return text -- 199
	end -- 199
	return string.sub(text, 1, nextPos - 1) -- 200
end -- 200
function summarizeUnknown(value, maxLen) -- 213
	if maxLen == nil then -- 213
		maxLen = 320 -- 213
	end -- 213
	if value == nil then -- 213
		return "undefined" -- 214
	end -- 214
	if value == nil then -- 214
		return "null" -- 215
	end -- 215
	if type(value) == "string" then -- 215
		return __TS__StringReplace( -- 217
			truncateText(value, maxLen), -- 217
			"\n", -- 217
			"\\n" -- 217
		) -- 217
	end -- 217
	if type(value) == "number" or type(value) == "boolean" then -- 217
		return tostring(value) -- 220
	end -- 220
	return __TS__StringReplace( -- 222
		truncateText( -- 222
			toJson(value), -- 222
			maxLen -- 222
		), -- 222
		"\n", -- 222
		"\\n" -- 222
	) -- 222
end -- 222
function limitReadContentForHistory(content, tool) -- 239
	local lines = __TS__StringSplit(content, "\n") -- 240
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 241
	local limitedByLines = overLineLimit and table.concat( -- 242
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 243
		"\n" -- 243
	) or content -- 243
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 243
		return content -- 246
	end -- 246
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 248
	local reasons = {} -- 251
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 251
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 252
	end -- 252
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 252
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 253
	end -- 253
	local hint = tool == "read_file" and "Use read_file_range for the exact section you need." or "Narrow the requested line range." -- 254
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 257
end -- 257
function pushLimitedMatches(lines, items, maxItems, mapper) -- 372
	local shown = math.min(#items, maxItems) -- 378
	do -- 378
		local j = 0 -- 379
		while j < shown do -- 379
			lines[#lines + 1] = mapper(items[j + 1], j) -- 380
			j = j + 1 -- 379
		end -- 379
	end -- 379
	if #items > shown then -- 379
		lines[#lines + 1] = ("  ... " .. tostring(#items - shown)) .. " more omitted" -- 383
	end -- 383
end -- 383
function formatHistorySummary(history) -- 452
	if #history == 0 then -- 452
		return "No previous actions." -- 454
	end -- 454
	local actions = history -- 456
	local lines = {} -- 457
	lines[#lines + 1] = "" -- 458
	do -- 458
		local i = 0 -- 459
		while i < #actions do -- 459
			local action = actions[i + 1] -- 460
			lines[#lines + 1] = ("Action " .. tostring(i + 1)) .. ":" -- 461
			lines[#lines + 1] = "- Tool: " .. action.tool -- 462
			lines[#lines + 1] = "- Reason: " .. action.reason -- 463
			if action.params and type(action.params) == "table" and ({next(action.params)}) ~= nil then -- 463
				lines[#lines + 1] = "- Parameters:" -- 465
				for key in pairs(action.params) do -- 466
					lines[#lines + 1] = (("  - " .. key) .. ": ") .. summarizeUnknown(action.params[key], 2000) -- 467
				end -- 467
			end -- 467
			if action.result and type(action.result) == "table" then -- 467
				local result = action.result -- 471
				local success = result.success == true -- 472
				if action.tool == "build" then -- 472
					if not success and type(result.message) == "string" then -- 472
						lines[#lines + 1] = "- Result: Failed" -- 475
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 1200) -- 476
					elseif type(result.messages) == "table" then -- 476
						local messages = result.messages -- 478
						local successCount = 0 -- 479
						local failedCount = 0 -- 480
						do -- 480
							local j = 0 -- 481
							while j < #messages do -- 481
								if messages[j + 1].success == true then -- 481
									successCount = successCount + 1 -- 482
								else -- 482
									failedCount = failedCount + 1 -- 483
								end -- 483
								j = j + 1 -- 481
							end -- 481
						end -- 481
						lines[#lines + 1] = "- Result: " .. (failedCount > 0 and "Completed With Errors" or "Success") -- 485
						lines[#lines + 1] = ((("- Build summary: " .. tostring(successCount)) .. " succeeded, ") .. tostring(failedCount)) .. " failed" -- 486
						if #messages > 0 then -- 486
							lines[#lines + 1] = "- Build details:" -- 488
							local shown = math.min(#messages, 12) -- 489
							do -- 489
								local j = 0 -- 490
								while j < shown do -- 490
									local item = messages[j + 1] -- 491
									local file = type(item.file) == "string" and item.file or "(unknown)" -- 492
									if item.success == true then -- 492
										lines[#lines + 1] = (("  " .. tostring(j + 1)) .. ". OK ") .. file -- 494
									else -- 494
										local message = type(item.message) == "string" and truncateText(item.message, 400) or "build failed" -- 496
										lines[#lines + 1] = (((("  " .. tostring(j + 1)) .. ". FAIL ") .. file) .. ": ") .. message -- 499
									end -- 499
									j = j + 1 -- 490
								end -- 490
							end -- 490
							if #messages > shown then -- 490
								lines[#lines + 1] = ("  ... " .. tostring(#messages - shown)) .. " more omitted" -- 503
							end -- 503
						end -- 503
					else -- 503
						lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 507
					end -- 507
				elseif action.tool == "read_file" or action.tool == "read_file_range" then -- 507
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 510
					if success and type(result.content) == "string" then -- 510
						lines[#lines + 1] = "- Content: " .. limitReadContentForHistory(result.content, action.tool) -- 512
						if result.startLine ~= nil or result.endLine ~= nil or result.totalLines ~= nil then -- 512
							lines[#lines + 1] = (((("- Range: " .. (result.startLine ~= nil and tostring(result.startLine) or "?")) .. "-") .. (result.endLine ~= nil and tostring(result.endLine) or "?")) .. " / total ") .. (result.totalLines ~= nil and tostring(result.totalLines) or "?") -- 514
						end -- 514
					elseif not success and type(result.message) == "string" then -- 514
						lines[#lines + 1] = "- Error: " .. truncateText(result.message, 600) -- 519
					end -- 519
				elseif action.tool == "grep_files" then -- 519
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 522
					if success and type(result.results) == "table" then -- 522
						local matches = result.results -- 524
						local totalMatches = type(result.totalResults) == "number" and result.totalResults or #matches -- 525
						lines[#lines + 1] = "- Matches: " .. tostring(totalMatches) -- 528
						if type(result.offset) == "number" and type(result.limit) == "number" then -- 528
							lines[#lines + 1] = (("- Page: offset=" .. tostring(result.offset)) .. " limit=") .. tostring(result.limit) -- 530
						end -- 530
						if result.hasMore == true and result.nextOffset ~= nil then -- 530
							lines[#lines + 1] = "- More: continue with offset=" .. tostring(result.nextOffset) -- 533
						end -- 533
						if type(result.groupedResults) == "table" then -- 533
							local groups = result.groupedResults -- 536
							lines[#lines + 1] = "- Groups:" -- 537
							pushLimitedMatches( -- 538
								lines, -- 538
								groups, -- 538
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 538
								function(g, index) -- 538
									local file = type(g.file) == "string" and g.file or "" -- 539
									local total = g.totalMatches ~= nil and tostring(g.totalMatches) or "?" -- 540
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. ": ") .. total) .. " matches" -- 541
								end -- 538
							) -- 538
						else -- 538
							pushLimitedMatches( -- 544
								lines, -- 544
								matches, -- 544
								HISTORY_SEARCH_FILES_MAX_MATCHES, -- 544
								function(m, index) -- 544
									local file = type(m.file) == "string" and m.file or "" -- 545
									local line = m.line ~= nil and tostring(m.line) or "" -- 546
									local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 547
									return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 548
								end -- 544
							) -- 544
						end -- 544
					end -- 544
				elseif action.tool == "search_dora_api" then -- 544
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 553
					if success and type(result.results) == "table" then -- 553
						local hits = result.results -- 555
						local totalHits = type(result.totalResults) == "number" and result.totalResults or #hits -- 556
						lines[#lines + 1] = "- Matches: " .. tostring(totalHits) -- 559
						pushLimitedMatches( -- 560
							lines, -- 560
							hits, -- 560
							HISTORY_SEARCH_DORA_API_MAX_MATCHES, -- 560
							function(m, index) -- 560
								local file = type(m.file) == "string" and m.file or "" -- 561
								local line = m.line ~= nil and tostring(m.line) or "" -- 562
								local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 563
								return ((((("  " .. tostring(index + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 564
							end -- 560
						) -- 560
					end -- 560
				elseif action.tool == "edit_file" then -- 560
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 568
					if success then -- 568
						if result.mode ~= nil then -- 568
							lines[#lines + 1] = "- Mode: " .. tostring(result.mode) -- 571
						end -- 571
						if result.replaced ~= nil then -- 571
							lines[#lines + 1] = "- Replaced: " .. tostring(result.replaced) -- 574
						end -- 574
					end -- 574
				elseif action.tool == "glob_files" then -- 574
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 578
					if success and type(result.files) == "table" then -- 578
						local files = result.files -- 580
						local totalEntries = type(result.totalEntries) == "number" and result.totalEntries or #files -- 581
						lines[#lines + 1] = "- Entries: " .. tostring(totalEntries) -- 584
						lines[#lines + 1] = "- Directory structure:" -- 585
						if #files > 0 then -- 585
							local shown = math.min(#files, HISTORY_LIST_FILES_MAX_ENTRIES) -- 587
							do -- 587
								local j = 0 -- 588
								while j < shown do -- 588
									lines[#lines + 1] = "  " .. files[j + 1] -- 589
									j = j + 1 -- 588
								end -- 588
							end -- 588
							if #files > shown then -- 588
								lines[#lines + 1] = ("  ... " .. tostring(#files - shown)) .. " more omitted" -- 592
							end -- 592
						else -- 592
							lines[#lines + 1] = "  (Empty or inaccessible directory)" -- 595
						end -- 595
					end -- 595
				else -- 595
					lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 599
					lines[#lines + 1] = "- Detail: " .. truncateText( -- 600
						toJson(result), -- 600
						4000 -- 600
					) -- 600
				end -- 600
			elseif action.result ~= nil then -- 600
				lines[#lines + 1] = "- Result: " .. summarizeUnknown(action.result, 3000) -- 603
			else -- 603
				lines[#lines + 1] = "- Result: pending" -- 605
			end -- 605
			if i < #actions - 1 then -- 605
				lines[#lines + 1] = "" -- 607
			end -- 607
			i = i + 1 -- 459
		end -- 459
	end -- 459
	return table.concat(lines, "\n") -- 609
end -- 609
function persistHistoryState(shared) -- 612
	shared.memory.compressor:getStorage():writeSessionState(shared.history, shared.memory.lastConsolidatedIndex) -- 613
end -- 613
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
local function utf8TakeTail(text, maxChars) -- 203
	if maxChars <= 0 or text == "" then -- 203
		return "" -- 204
	end -- 204
	local charLen = utf8.len(text) -- 205
	if charLen == false or charLen <= maxChars then -- 205
		return text -- 206
	end -- 206
	local startChar = math.max(1, charLen - maxChars + 1) -- 207
	local startPos = utf8.offset(text, startChar) -- 208
	if startPos == nil then -- 208
		return text -- 209
	end -- 209
	return string.sub(text, startPos) -- 210
end -- 203
local function getReplyLanguageDirective(shared) -- 225
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 226
end -- 225
local function replacePromptVars(template, vars) -- 231
	local output = template -- 232
	for key in pairs(vars) do -- 233
		output = table.concat( -- 234
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 234
			vars[key] or "" or "," -- 234
		) -- 234
	end -- 234
	return output -- 236
end -- 231
local function summarizeEditTextParamForHistory(value, key) -- 260
	if type(value) ~= "string" then -- 260
		return nil -- 261
	end -- 261
	local text = value -- 262
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 263
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 264
end -- 260
local function sanitizeReadResultForHistory(tool, result) -- 272
	if tool ~= "read_file" and tool ~= "read_file_range" or result.success ~= true or type(result.content) ~= "string" then -- 272
		return result -- 274
	end -- 274
	local clone = {} -- 276
	for key in pairs(result) do -- 277
		clone[key] = result[key] -- 278
	end -- 278
	clone.content = limitReadContentForHistory(result.content, tool) -- 280
	return clone -- 281
end -- 272
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 284
	local shown = math.min(#items, maxItems) -- 288
	local out = {} -- 289
	do -- 289
		local i = 0 -- 290
		while i < shown do -- 290
			local row = items[i + 1] -- 291
			out[#out + 1] = { -- 292
				file = row.file, -- 293
				line = row.line, -- 294
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 295
			} -- 295
			i = i + 1 -- 290
		end -- 290
	end -- 290
	return out -- 300
end -- 284
local function sanitizeSearchResultForHistory(tool, result) -- 303
	if result.success ~= true or type(result.results) ~= "table" then -- 303
		return result -- 307
	end -- 307
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 307
		return result -- 308
	end -- 308
	local clone = {} -- 309
	for key in pairs(result) do -- 310
		clone[key] = result[key] -- 311
	end -- 311
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 313
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 314
	if tool == "grep_files" and type(result.groupedResults) == "table" then -- 314
		local grouped = result.groupedResults -- 319
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 320
		local sanitizedGroups = {} -- 321
		do -- 321
			local i = 0 -- 322
			while i < shown do -- 322
				local row = grouped[i + 1] -- 323
				sanitizedGroups[#sanitizedGroups + 1] = { -- 324
					file = row.file, -- 325
					totalMatches = row.totalMatches, -- 326
					matches = type(row.matches) == "table" and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 327
				} -- 327
				i = i + 1 -- 322
			end -- 322
		end -- 322
		clone.groupedResults = sanitizedGroups -- 332
	end -- 332
	return clone -- 334
end -- 303
local function sanitizeListFilesResultForHistory(result) -- 337
	if result.success ~= true or type(result.files) ~= "table" then -- 337
		return result -- 338
	end -- 338
	local clone = {} -- 339
	for key in pairs(result) do -- 340
		clone[key] = result[key] -- 341
	end -- 341
	local files = result.files -- 343
	clone.files = __TS__ArraySlice(files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 344
	return clone -- 345
end -- 337
local function sanitizeActionParamsForHistory(tool, params) -- 348
	if tool ~= "edit_file" then -- 348
		return params -- 349
	end -- 349
	local clone = {} -- 350
	for key in pairs(params) do -- 351
		if key == "old_str" then -- 351
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 353
		elseif key == "new_str" then -- 353
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 355
		else -- 355
			clone[key] = params[key] -- 357
		end -- 357
	end -- 357
	return clone -- 360
end -- 348
local function trimPromptContext(text, maxChars, label) -- 363
	if #text <= maxChars then -- 363
		return text -- 364
	end -- 364
	local keepHead = math.max( -- 365
		0, -- 365
		math.floor(maxChars * 0.35) -- 365
	) -- 365
	local keepTail = math.max(0, maxChars - keepHead) -- 366
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 367
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 368
	return (((((("[history summary truncated for " .. label) .. "; showing head and tail within ") .. tostring(maxChars)) .. " chars]\n") .. head) .. "\n...\n") .. tail -- 369
end -- 363
local function formatHistorySummaryForDecision(history) -- 387
	return trimPromptContext( -- 388
		formatHistorySummary(history), -- 388
		DECISION_HISTORY_MAX_CHARS, -- 388
		"decision" -- 388
	) -- 388
end -- 387
local function getDecisionSystemPrompt(shared) -- 391
	return shared and shared.promptPack.agentIdentityPrompt or DEFAULT_AGENT_PROMPT_PACK.agentIdentityPrompt -- 392
end -- 391
local function getDecisionToolDefinitions(shared) -- 395
	return replacePromptVars( -- 396
		shared and shared.promptPack.toolDefinitionsShort or DEFAULT_AGENT_PROMPT_PACK.toolDefinitionsShort, -- 397
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 398
	) -- 398
end -- 395
local function maybeCompressHistory(shared) -- 402
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 402
		local ____shared_4 = shared -- 403
		local memory = ____shared_4.memory -- 403
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 404
		local changed = false -- 405
		do -- 405
			local round = 0 -- 406
			while round < maxRounds do -- 406
				if not memory.compressor:shouldCompress( -- 406
					shared.userQuery, -- 408
					shared.history, -- 409
					memory.lastConsolidatedIndex, -- 410
					getDecisionSystemPrompt(shared), -- 411
					getDecisionToolDefinitions(shared), -- 412
					formatHistorySummary -- 413
				) then -- 413
					return ____awaiter_resolve(nil) -- 413
				end -- 413
				local result = __TS__Await(memory.compressor:compress( -- 417
					shared.history, -- 418
					memory.lastConsolidatedIndex, -- 419
					shared.llmOptions, -- 420
					formatHistorySummary, -- 421
					shared.llmMaxTry, -- 422
					shared.decisionMode -- 423
				)) -- 423
				if not (result and result.success and result.compressedCount > 0) then -- 423
					if changed then -- 423
						persistHistoryState(shared) -- 427
					end -- 427
					return ____awaiter_resolve(nil) -- 427
				end -- 427
				memory.lastConsolidatedIndex = memory.lastConsolidatedIndex + result.compressedCount -- 431
				changed = true -- 432
				Log( -- 433
					"Info", -- 433
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " history records (round ") .. tostring(round + 1)) .. ")" -- 433
				) -- 433
				round = round + 1 -- 406
			end -- 406
		end -- 406
		if changed then -- 406
			persistHistoryState(shared) -- 436
		end -- 436
	end) -- 436
end -- 402
local function isKnownToolName(name) -- 440
	return name == "read_file" or name == "read_file_range" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 441
end -- 440
local function extractYAMLFromText(text) -- 619
	local source = __TS__StringTrim(text) -- 620
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 621
	if yamlFencePos >= 0 then -- 621
		local from = yamlFencePos + #"```yaml" -- 623
		local ____end = (string.find( -- 624
			source, -- 624
			"```", -- 624
			math.max(from + 1, 1), -- 624
			true -- 624
		) or 0) - 1 -- 624
		if ____end > from then -- 624
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 625
		end -- 625
	end -- 625
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 627
	if ymlFencePos >= 0 then -- 627
		local from = ymlFencePos + #"```yml" -- 629
		local ____end = (string.find( -- 630
			source, -- 630
			"```", -- 630
			math.max(from + 1, 1), -- 630
			true -- 630
		) or 0) - 1 -- 630
		if ____end > from then -- 630
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 631
		end -- 631
	end -- 631
	local fencePos = (string.find(source, "```", nil, true) or 0) - 1 -- 633
	if fencePos >= 0 then -- 633
		local firstLineEnd = (string.find( -- 635
			source, -- 635
			"\n", -- 635
			math.max(fencePos + 1, 1), -- 635
			true -- 635
		) or 0) - 1 -- 635
		local ____end = (string.find( -- 636
			source, -- 636
			"```", -- 636
			math.max((firstLineEnd >= 0 and firstLineEnd + 1 or fencePos + 3) + 1, 1), -- 636
			true -- 636
		) or 0) - 1 -- 636
		if firstLineEnd >= 0 and ____end > firstLineEnd then -- 636
			return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, ____end)) -- 638
		end -- 638
	end -- 638
	return source -- 641
end -- 619
local function parseYAMLObjectFromText(text) -- 644
	local yamlText = extractYAMLFromText(text) -- 645
	local obj, err = yaml.parse(yamlText) -- 646
	if obj == nil or type(obj) ~= "table" then -- 646
		return { -- 648
			success = false, -- 648
			message = "invalid yaml: " .. tostring(err) -- 648
		} -- 648
	end -- 648
	return {success = true, obj = obj} -- 650
end -- 644
local function llm(shared, messages) -- 662
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 662
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 663
		if res.success then -- 663
			local ____opt_9 = res.response.choices -- 663
			local ____opt_7 = ____opt_9 and ____opt_9[1] -- 663
			local ____opt_5 = ____opt_7 and ____opt_7.message -- 663
			local text = ____opt_5 and ____opt_5.content -- 665
			if text then -- 665
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 665
			else -- 665
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 665
			end -- 665
		else -- 665
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 665
		end -- 665
	end) -- 665
end -- 662
local function llmStream(shared, messages) -- 676
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 676
		local text = "" -- 677
		local cancelledReason -- 678
		local done = false -- 679
		if shared.stopToken.stopped then -- 679
			return ____awaiter_resolve( -- 679
				nil, -- 679
				{ -- 682
					success = false, -- 682
					message = getCancelledReason(shared), -- 682
					text = text -- 682
				} -- 682
			) -- 682
		end -- 682
		done = false -- 684
		cancelledReason = nil -- 685
		text = "" -- 686
		callLLMStream( -- 687
			messages, -- 688
			shared.llmOptions, -- 689
			{ -- 690
				id = nil, -- 691
				stopToken = shared.stopToken, -- 692
				onData = function(data) -- 693
					if shared.stopToken.stopped then -- 693
						return true -- 694
					end -- 694
					local choice = data.choices and data.choices[1] -- 695
					local delta = choice and choice.delta -- 696
					if delta and type(delta.content) == "string" then -- 696
						local content = delta.content -- 698
						text = text .. content -- 699
						emitAgentEvent(shared, { -- 700
							type = "summary_stream", -- 701
							sessionId = shared.sessionId, -- 702
							taskId = shared.taskId, -- 703
							textDelta = content, -- 704
							fullText = text -- 705
						}) -- 705
						local res = json.encode({name = "LLMStream", content = content}) -- 707
						if res ~= nil then -- 707
							emit("AppWS", "Send", res) -- 709
						end -- 709
					end -- 709
					return false -- 712
				end, -- 693
				onCancel = function(reason) -- 714
					cancelledReason = reason -- 715
					done = true -- 716
				end, -- 714
				onDone = function() -- 718
					done = true -- 719
				end -- 718
			}, -- 718
			shared.llmConfig -- 722
		) -- 722
		__TS__Await(__TS__New( -- 725
			__TS__Promise, -- 725
			function(____, resolve) -- 725
				Director.systemScheduler:schedule(once(function() -- 726
					wait(function() return done or shared.stopToken.stopped end) -- 727
					resolve(nil) -- 728
				end)) -- 726
			end -- 725
		)) -- 725
		if shared.stopToken.stopped then -- 725
			cancelledReason = getCancelledReason(shared) -- 732
		end -- 732
		if not cancelledReason and text == "" then -- 732
			cancelledReason = "empty LLM output" -- 736
		end -- 736
		if cancelledReason then -- 736
			return ____awaiter_resolve(nil, {success = false, message = cancelledReason, text = text}) -- 736
		end -- 736
		return ____awaiter_resolve(nil, {success = true, text = text}) -- 736
	end) -- 736
end -- 676
local function parseDecisionObject(rawObj) -- 743
	if type(rawObj.tool) ~= "string" then -- 743
		return {success = false, message = "missing tool"} -- 744
	end -- 744
	local tool = rawObj.tool -- 745
	if not isKnownToolName(tool) then -- 745
		return {success = false, message = "unknown tool: " .. tool} -- 747
	end -- 747
	local reason = type(rawObj.reason) == "string" and rawObj.reason or "" -- 749
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 750
	return {success = true, tool = tool, reason = reason, params = params} -- 751
end -- 743
local function getDecisionPath(params) -- 754
	if type(params.path) == "string" then -- 754
		return __TS__StringTrim(params.path) -- 755
	end -- 755
	if type(params.target_file) == "string" then -- 755
		return __TS__StringTrim(params.target_file) -- 756
	end -- 756
	return "" -- 757
end -- 754
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 760
	local num = __TS__Number(value) -- 761
	if not __TS__NumberIsFinite(num) then -- 761
		num = fallback -- 762
	end -- 762
	num = math.floor(num) -- 763
	if num < minValue then -- 763
		num = minValue -- 764
	end -- 764
	if maxValue ~= nil and num > maxValue then -- 764
		num = maxValue -- 765
	end -- 765
	return num -- 766
end -- 760
local function validateDecision(tool, params, history) -- 769
	if tool == "finish" then -- 769
		return {success = true, params = params} -- 774
	end -- 774
	if tool == "read_file" then -- 774
		local path = getDecisionPath(params) -- 777
		if path == "" then -- 777
			return {success = false, message = "read_file requires path"} -- 778
		end -- 778
		params.path = path -- 779
		params.offset = clampIntegerParam(params.offset, 1, 1) -- 780
		params.limit = clampIntegerParam(params.limit, READ_FILE_DEFAULT_LIMIT, 1) -- 781
		return {success = true, params = params} -- 782
	end -- 782
	if tool == "read_file_range" then -- 782
		local path = getDecisionPath(params) -- 786
		if path == "" then -- 786
			return {success = false, message = "read_file_range requires path"} -- 787
		end -- 787
		local startLine = clampIntegerParam(params.startLine, 1, 1) -- 788
		local ____params_endLine_11 = params.endLine -- 789
		if ____params_endLine_11 == nil then -- 789
			____params_endLine_11 = startLine -- 789
		end -- 789
		local endLineRaw = ____params_endLine_11 -- 789
		local endLine = clampIntegerParam(endLineRaw, startLine, startLine) -- 790
		params.path = path -- 791
		params.startLine = startLine -- 792
		params.endLine = endLine -- 793
		return {success = true, params = params} -- 794
	end -- 794
	if tool == "edit_file" then -- 794
		local path = getDecisionPath(params) -- 798
		if path == "" then -- 798
			return {success = false, message = "edit_file requires path"} -- 799
		end -- 799
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 800
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 801
		if oldStr == newStr then -- 801
			return {success = false, message = "edit_file old_str and new_str must be different"} -- 803
		end -- 803
		params.path = path -- 805
		params.old_str = oldStr -- 806
		params.new_str = newStr -- 807
		return {success = true, params = params} -- 808
	end -- 808
	if tool == "delete_file" then -- 808
		local targetFile = getDecisionPath(params) -- 812
		if targetFile == "" then -- 812
			return {success = false, message = "delete_file requires target_file"} -- 813
		end -- 813
		params.target_file = targetFile -- 814
		return {success = true, params = params} -- 815
	end -- 815
	if tool == "grep_files" then -- 815
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 819
		if pattern == "" then -- 819
			return {success = false, message = "grep_files requires pattern"} -- 820
		end -- 820
		params.pattern = pattern -- 821
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 822
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 823
		return {success = true, params = params} -- 824
	end -- 824
	if tool == "search_dora_api" then -- 824
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 828
		if pattern == "" then -- 828
			return {success = false, message = "search_dora_api requires pattern"} -- 829
		end -- 829
		params.pattern = pattern -- 830
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 831
		return {success = true, params = params} -- 832
	end -- 832
	if tool == "glob_files" then -- 832
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 836
		return {success = true, params = params} -- 837
	end -- 837
	if tool == "build" then -- 837
		local path = getDecisionPath(params) -- 841
		if path ~= "" then -- 841
			params.path = path -- 843
		end -- 843
		return {success = true, params = params} -- 845
	end -- 845
	return {success = true, params = params} -- 848
end -- 769
local function buildDecisionToolSchema() -- 851
	return {{type = "function", ["function"] = {name = "next_step", description = "Choose the next coding action for the agent.", parameters = {type = "object", properties = {tool = {type = "string", enum = { -- 852
		"read_file", -- 863
		"read_file_range", -- 864
		"edit_file", -- 865
		"delete_file", -- 866
		"grep_files", -- 867
		"search_dora_api", -- 868
		"glob_files", -- 869
		"build", -- 870
		"finish" -- 871
	}}, reason = {type = "string", description = "Explain why this is the next best action."}, params = {type = "object", description = "Shallow parameter object for the selected tool.", properties = { -- 871
		path = {type = "string"}, -- 882
		target_file = {type = "string"}, -- 883
		old_str = {type = "string"}, -- 884
		new_str = {type = "string"}, -- 885
		pattern = {type = "string"}, -- 886
		globs = {type = "array", items = {type = "string"}}, -- 887
		useRegex = {type = "boolean"}, -- 891
		caseSensitive = {type = "boolean"}, -- 892
		offset = {type = "number"}, -- 893
		groupByFile = {type = "boolean"}, -- 894
		docSource = {type = "string", enum = {"api", "tutorial"}}, -- 895
		programmingLanguage = {type = "string", enum = { -- 899
			"ts", -- 901
			"tsx", -- 901
			"lua", -- 901
			"yue", -- 901
			"teal", -- 901
			"tl", -- 901
			"wa" -- 901
		}}, -- 901
		limit = {type = "number"}, -- 903
		startLine = {type = "number"}, -- 904
		endLine = {type = "number"}, -- 905
		maxEntries = {type = "number"} -- 906
	}}}, required = {"tool", "reason", "params"}}}}} -- 906
end -- 851
local function buildDecisionPrompt(shared, userQuery, historyText, memoryContext) -- 916
	return (((((((((((((shared.promptPack.agentIdentityPrompt .. "\n") .. shared.promptPack.decisionIntroPrompt) .. "\n\n") .. memoryContext) .. "\n\nUser request: ") .. userQuery) .. "\n\nHere are the actions you performed:\n") .. historyText) .. "\n\n") .. replacePromptVars( -- 917
		shared.promptPack.toolDefinitionsDetailed, -- 927
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 927
	)) .. "\n\n") .. shared.promptPack.decisionRulesPrompt) .. "\n") .. getReplyLanguageDirective(shared) -- 927
end -- 916
local function replaceAllAndCount(text, oldStr, newStr) -- 935
	if oldStr == "" then -- 935
		return {content = text, replaced = 0} -- 936
	end -- 936
	local count = 0 -- 937
	local from = 0 -- 938
	while true do -- 938
		local idx = (string.find( -- 940
			text, -- 940
			oldStr, -- 940
			math.max(from + 1, 1), -- 940
			true -- 940
		) or 0) - 1 -- 940
		if idx < 0 then -- 940
			break -- 941
		end -- 941
		count = count + 1 -- 942
		from = idx + #oldStr -- 943
	end -- 943
	if count == 0 then -- 943
		return {content = text, replaced = 0} -- 945
	end -- 945
	return { -- 946
		content = table.concat( -- 947
			__TS__StringSplit(text, oldStr), -- 947
			newStr or "," -- 947
		), -- 947
		replaced = count -- 948
	} -- 948
end -- 935
local MainDecisionAgent = __TS__Class() -- 952
MainDecisionAgent.name = "MainDecisionAgent" -- 952
__TS__ClassExtends(MainDecisionAgent, Node) -- 952
function MainDecisionAgent.prototype.prep(self, shared) -- 953
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 953
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 953
			return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 953
		end -- 953
		__TS__Await(maybeCompressHistory(shared)) -- 962
		return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 962
	end) -- 962
end -- 953
function MainDecisionAgent.prototype.getSystemPrompt(self) -- 971
	return getDecisionSystemPrompt() -- 972
end -- 971
function MainDecisionAgent.prototype.getToolDefinitions(self) -- 975
	return getDecisionToolDefinitions() -- 976
end -- 975
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, prompt, lastError) -- 979
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 979
		if shared.stopToken.stopped then -- 979
			return ____awaiter_resolve( -- 979
				nil, -- 979
				{ -- 985
					success = false, -- 985
					message = getCancelledReason(shared) -- 985
				} -- 985
			) -- 985
		end -- 985
		Log( -- 987
			"Info", -- 987
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 987
		) -- 987
		local tools = buildDecisionToolSchema() -- 988
		local messages = { -- 989
			{ -- 990
				role = "system", -- 991
				content = table.concat( -- 992
					{ -- 992
						shared.promptPack.toolCallingSystemPrompt, -- 993
						shared.promptPack.toolCallingNoPlainTextPrompt, -- 994
						getReplyLanguageDirective(shared) -- 995
					}, -- 995
					"\n" -- 996
				) -- 996
			}, -- 996
			{ -- 998
				role = "user", -- 999
				content = lastError and (prompt .. "\n\n") .. replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) or prompt -- 1000
			} -- 1000
		} -- 1000
		local res = __TS__Await(callLLM( -- 1005
			messages, -- 1005
			__TS__ObjectAssign({}, shared.llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "next_step"}}}), -- 1005
			shared.stopToken, -- 1009
			shared.llmConfig -- 1009
		)) -- 1009
		if shared.stopToken.stopped then -- 1009
			return ____awaiter_resolve( -- 1009
				nil, -- 1009
				{ -- 1011
					success = false, -- 1011
					message = getCancelledReason(shared) -- 1011
				} -- 1011
			) -- 1011
		end -- 1011
		if not res.success then -- 1011
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1014
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1014
		end -- 1014
		local choice = res.response.choices and res.response.choices[1] -- 1017
		local message = choice and choice.message -- 1018
		local toolCalls = message and message.tool_calls -- 1019
		local toolCall = toolCalls and toolCalls[1] -- 1020
		local fn = toolCall and toolCall["function"] -- 1021
		local messageContent = message and type(message.content) == "string" and message.content or nil -- 1022
		Log( -- 1023
			"Info", -- 1023
			(((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0) -- 1023
		) -- 1023
		if not fn or fn.name ~= "next_step" then -- 1023
			Log("Error", "[CodingAgent] missing next_step tool call") -- 1025
			return ____awaiter_resolve(nil, {success = false, message = "missing next_step tool call", raw = messageContent}) -- 1025
		end -- 1025
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 1032
		Log( -- 1033
			"Info", -- 1033
			(("[CodingAgent] tool-calling function=" .. fn.name) .. " args_len=") .. tostring(#argsText) -- 1033
		) -- 1033
		if __TS__StringTrim(argsText) == "" then -- 1033
			Log("Error", "[CodingAgent] empty next_step tool arguments") -- 1035
			return ____awaiter_resolve(nil, {success = false, message = "empty next_step tool arguments"}) -- 1035
		end -- 1035
		local rawObj, err = json.decode(argsText) -- 1038
		if err ~= nil or rawObj == nil or type(rawObj) ~= "table" then -- 1038
			Log( -- 1040
				"Error", -- 1040
				"[CodingAgent] invalid next_step tool arguments JSON: " .. tostring(err) -- 1040
			) -- 1040
			return ____awaiter_resolve( -- 1040
				nil, -- 1040
				{ -- 1041
					success = false, -- 1042
					message = "invalid next_step tool arguments: " .. tostring(err), -- 1043
					raw = argsText -- 1044
				} -- 1044
			) -- 1044
		end -- 1044
		local decision = parseDecisionObject(rawObj) -- 1047
		if not decision.success then -- 1047
			Log("Error", "[CodingAgent] invalid next_step tool arguments schema: " .. decision.message) -- 1049
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 1049
		end -- 1049
		local validation = validateDecision(decision.tool, decision.params, shared.history) -- 1056
		if not validation.success then -- 1056
			Log("Error", "[CodingAgent] invalid next_step tool arguments values: " .. validation.message) -- 1058
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 1058
		end -- 1058
		decision.params = validation.params -- 1065
		Log( -- 1066
			"Info", -- 1066
			(("[CodingAgent] tool-calling selected tool=" .. decision.tool) .. " reason_len=") .. tostring(#decision.reason) -- 1066
		) -- 1066
		return ____awaiter_resolve(nil, decision) -- 1066
	end) -- 1066
end -- 979
function MainDecisionAgent.prototype.exec(self, input) -- 1070
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1070
		local shared = input.shared -- 1071
		if shared.stopToken.stopped then -- 1071
			return ____awaiter_resolve( -- 1071
				nil, -- 1071
				{ -- 1073
					success = false, -- 1073
					message = getCancelledReason(shared) -- 1073
				} -- 1073
			) -- 1073
		end -- 1073
		local memory = shared.memory -- 1073
		local memoryContext = memory.compressor:getStorage():getMemoryContext() -- 1078
		local uncompressedHistory = __TS__ArraySlice(input.history, memory.lastConsolidatedIndex) -- 1083
		local historyText = formatHistorySummaryForDecision(uncompressedHistory) -- 1084
		local prompt = buildDecisionPrompt(input.shared, input.userQuery, historyText, memoryContext) -- 1086
		if shared.decisionMode == "tool_calling" then -- 1086
			Log( -- 1089
				"Info", -- 1089
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " history=") .. tostring(#uncompressedHistory) -- 1089
			) -- 1089
			local lastError = "tool calling validation failed" -- 1090
			local lastRaw = "" -- 1091
			do -- 1091
				local attempt = 0 -- 1092
				while attempt < shared.llmMaxTry do -- 1092
					Log( -- 1093
						"Info", -- 1093
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 1093
					) -- 1093
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, prompt, attempt > 0 and lastError or nil)) -- 1094
					if shared.stopToken.stopped then -- 1094
						return ____awaiter_resolve( -- 1094
							nil, -- 1094
							{ -- 1100
								success = false, -- 1100
								message = getCancelledReason(shared) -- 1100
							} -- 1100
						) -- 1100
					end -- 1100
					if decision.success then -- 1100
						return ____awaiter_resolve(nil, decision) -- 1100
					end -- 1100
					lastError = decision.message -- 1105
					lastRaw = decision.raw or "" -- 1106
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 1107
					attempt = attempt + 1 -- 1092
				end -- 1092
			end -- 1092
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 1109
			return ____awaiter_resolve( -- 1109
				nil, -- 1109
				{ -- 1110
					success = false, -- 1110
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1110
				} -- 1110
			) -- 1110
		end -- 1110
		local yamlPrompt = ((prompt .. "\n\n") .. shared.promptPack.yamlDecisionFormatPrompt) .. "\n- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.\n- Keep params shallow and valid for the selected tool.\n- Use tabs for all indentation, never spaces.\nIf no more actions are needed, use tool: finish." -- 1113
		local lastError = "yaml validation failed" -- 1121
		local lastRaw = "" -- 1122
		do -- 1122
			local attempt = 0 -- 1123
			while attempt < shared.llmMaxTry do -- 1123
				do -- 1123
					local feedback = attempt > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only and keep YAML indentation strictly consistent." or "" -- 1124
					local messages = {{role = "user", content = yamlPrompt .. feedback}} -- 1127
					local llmRes = __TS__Await(llm(shared, messages)) -- 1128
					if shared.stopToken.stopped then -- 1128
						return ____awaiter_resolve( -- 1128
							nil, -- 1128
							{ -- 1130
								success = false, -- 1130
								message = getCancelledReason(shared) -- 1130
							} -- 1130
						) -- 1130
					end -- 1130
					if not llmRes.success then -- 1130
						lastError = llmRes.message -- 1133
						goto __continue213 -- 1134
					end -- 1134
					lastRaw = llmRes.text -- 1136
					local parsed = parseYAMLObjectFromText(llmRes.text) -- 1137
					if not parsed.success then -- 1137
						lastError = parsed.message -- 1139
						goto __continue213 -- 1140
					end -- 1140
					local decision = parseDecisionObject(parsed.obj) -- 1142
					if not decision.success then -- 1142
						lastError = decision.message -- 1144
						goto __continue213 -- 1145
					end -- 1145
					local validation = validateDecision(decision.tool, decision.params, input.history) -- 1147
					if not validation.success then -- 1147
						lastError = validation.message -- 1149
						goto __continue213 -- 1150
					end -- 1150
					decision.params = validation.params -- 1152
					return ____awaiter_resolve(nil, decision) -- 1152
				end -- 1152
				::__continue213:: -- 1152
				attempt = attempt + 1 -- 1123
			end -- 1123
		end -- 1123
		return ____awaiter_resolve( -- 1123
			nil, -- 1123
			{ -- 1155
				success = false, -- 1155
				message = (("cannot produce valid decision yaml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 1155
			} -- 1155
		) -- 1155
	end) -- 1155
end -- 1070
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 1158
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1158
		local result = execRes -- 1159
		if not result.success then -- 1159
			shared.error = result.message -- 1161
			return ____awaiter_resolve(nil, "error") -- 1161
		end -- 1161
		emitAgentEvent(shared, { -- 1164
			type = "decision_made", -- 1165
			sessionId = shared.sessionId, -- 1166
			taskId = shared.taskId, -- 1167
			step = shared.step + 1, -- 1168
			tool = result.tool, -- 1169
			reason = result.reason, -- 1170
			params = result.params -- 1171
		}) -- 1171
		shared.lastDecision = {tool = result.tool, reason = result.reason, params = result.params} -- 1173
		local ____shared_history_12 = shared.history -- 1173
		____shared_history_12[#____shared_history_12 + 1] = { -- 1178
			step = #shared.history + 1, -- 1179
			tool = result.tool, -- 1180
			reason = result.reason, -- 1181
			params = result.params, -- 1182
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1183
		} -- 1183
		persistHistoryState(shared) -- 1185
		return ____awaiter_resolve(nil, result.tool) -- 1185
	end) -- 1185
end -- 1158
local ReadFileAction = __TS__Class() -- 1190
ReadFileAction.name = "ReadFileAction" -- 1190
__TS__ClassExtends(ReadFileAction, Node) -- 1190
function ReadFileAction.prototype.prep(self, shared) -- 1191
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1191
		local last = shared.history[#shared.history] -- 1192
		if not last then -- 1192
			error( -- 1193
				__TS__New(Error, "no history"), -- 1193
				0 -- 1193
			) -- 1193
		end -- 1193
		emitAgentEvent(shared, { -- 1194
			type = "tool_started", -- 1195
			sessionId = shared.sessionId, -- 1196
			taskId = shared.taskId, -- 1197
			step = shared.step + 1, -- 1198
			tool = last.tool -- 1199
		}) -- 1199
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1201
		if __TS__StringTrim(path) == "" then -- 1201
			error( -- 1204
				__TS__New(Error, "missing path"), -- 1204
				0 -- 1204
			) -- 1204
		end -- 1204
		if last.tool == "read_file_range" then -- 1204
			local ____path_17 = path -- 1207
			local ____last_tool_18 = last.tool -- 1208
			local ____shared_workingDir_19 = shared.workingDir -- 1209
			local ____temp_20 = shared.useChineseResponse and "zh" or "en" -- 1210
			local ____last_params_startLine_13 = last.params.startLine -- 1212
			if ____last_params_startLine_13 == nil then -- 1212
				____last_params_startLine_13 = 1 -- 1212
			end -- 1212
			local ____TS__Number_result_16 = __TS__Number(____last_params_startLine_13) -- 1212
			local ____last_params_endLine_14 = last.params.endLine -- 1213
			if ____last_params_endLine_14 == nil then -- 1213
				____last_params_endLine_14 = last.params.startLine -- 1213
			end -- 1213
			local ____last_params_endLine_14_15 = ____last_params_endLine_14 -- 1213
			if ____last_params_endLine_14_15 == nil then -- 1213
				____last_params_endLine_14_15 = 1 -- 1213
			end -- 1213
			return ____awaiter_resolve( -- 1213
				nil, -- 1213
				{ -- 1206
					path = ____path_17, -- 1207
					tool = ____last_tool_18, -- 1208
					workDir = ____shared_workingDir_19, -- 1209
					docLanguage = ____temp_20, -- 1210
					range = { -- 1211
						startLine = ____TS__Number_result_16, -- 1212
						endLine = __TS__Number(____last_params_endLine_14_15) -- 1213
					} -- 1213
				} -- 1213
			) -- 1213
		end -- 1213
		local ____path_23 = path -- 1218
		local ____shared_workingDir_24 = shared.workingDir -- 1220
		local ____temp_25 = shared.useChineseResponse and "zh" or "en" -- 1221
		local ____last_params_offset_21 = last.params.offset -- 1222
		if ____last_params_offset_21 == nil then -- 1222
			____last_params_offset_21 = 1 -- 1222
		end -- 1222
		local ____TS__Number_result_26 = __TS__Number(____last_params_offset_21) -- 1222
		local ____last_params_limit_22 = last.params.limit -- 1223
		if ____last_params_limit_22 == nil then -- 1223
			____last_params_limit_22 = READ_FILE_DEFAULT_LIMIT -- 1223
		end -- 1223
		return ____awaiter_resolve( -- 1223
			nil, -- 1223
			{ -- 1217
				path = ____path_23, -- 1218
				tool = "read_file", -- 1219
				workDir = ____shared_workingDir_24, -- 1220
				docLanguage = ____temp_25, -- 1221
				offset = ____TS__Number_result_26, -- 1222
				limit = __TS__Number(____last_params_limit_22) -- 1223
			} -- 1223
		) -- 1223
	end) -- 1223
end -- 1191
function ReadFileAction.prototype.exec(self, input) -- 1227
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1227
		if input.tool == "read_file_range" and input.range then -- 1227
			return ____awaiter_resolve( -- 1227
				nil, -- 1227
				Tools.readFileRange( -- 1229
					input.workDir, -- 1229
					input.path, -- 1229
					input.range.startLine, -- 1229
					input.range.endLine, -- 1229
					input.docLanguage -- 1229
				) -- 1229
			) -- 1229
		end -- 1229
		return ____awaiter_resolve( -- 1229
			nil, -- 1229
			Tools.readFile( -- 1231
				input.workDir, -- 1232
				input.path, -- 1233
				__TS__Number(input.offset or 1), -- 1234
				__TS__Number(input.limit or READ_FILE_DEFAULT_LIMIT), -- 1235
				input.docLanguage -- 1236
			) -- 1236
		) -- 1236
	end) -- 1236
end -- 1227
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1240
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1240
		local result = execRes -- 1241
		local last = shared.history[#shared.history] -- 1242
		if last ~= nil then -- 1242
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 1244
			emitAgentEvent(shared, { -- 1245
				type = "tool_finished", -- 1246
				sessionId = shared.sessionId, -- 1247
				taskId = shared.taskId, -- 1248
				step = shared.step + 1, -- 1249
				tool = last.tool, -- 1250
				result = last.result -- 1251
			}) -- 1251
		end -- 1251
		__TS__Await(maybeCompressHistory(shared)) -- 1254
		persistHistoryState(shared) -- 1255
		shared.step = shared.step + 1 -- 1256
		return ____awaiter_resolve(nil, "main") -- 1256
	end) -- 1256
end -- 1240
local SearchFilesAction = __TS__Class() -- 1261
SearchFilesAction.name = "SearchFilesAction" -- 1261
__TS__ClassExtends(SearchFilesAction, Node) -- 1261
function SearchFilesAction.prototype.prep(self, shared) -- 1262
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1262
		local last = shared.history[#shared.history] -- 1263
		if not last then -- 1263
			error( -- 1264
				__TS__New(Error, "no history"), -- 1264
				0 -- 1264
			) -- 1264
		end -- 1264
		emitAgentEvent(shared, { -- 1265
			type = "tool_started", -- 1266
			sessionId = shared.sessionId, -- 1267
			taskId = shared.taskId, -- 1268
			step = shared.step + 1, -- 1269
			tool = last.tool -- 1270
		}) -- 1270
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1270
	end) -- 1270
end -- 1262
function SearchFilesAction.prototype.exec(self, input) -- 1275
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1275
		local params = input.params -- 1276
		local ____Tools_searchFiles_40 = Tools.searchFiles -- 1277
		local ____input_workDir_33 = input.workDir -- 1278
		local ____temp_34 = params.path or "" -- 1279
		local ____temp_35 = params.pattern or "" -- 1280
		local ____params_globs_36 = params.globs -- 1281
		local ____params_useRegex_37 = params.useRegex -- 1282
		local ____params_caseSensitive_38 = params.caseSensitive -- 1283
		local ____math_max_29 = math.max -- 1286
		local ____math_floor_28 = math.floor -- 1286
		local ____params_limit_27 = params.limit -- 1286
		if ____params_limit_27 == nil then -- 1286
			____params_limit_27 = SEARCH_FILES_LIMIT_DEFAULT -- 1286
		end -- 1286
		local ____math_max_29_result_39 = ____math_max_29( -- 1286
			1, -- 1286
			____math_floor_28(__TS__Number(____params_limit_27)) -- 1286
		) -- 1286
		local ____math_max_32 = math.max -- 1287
		local ____math_floor_31 = math.floor -- 1287
		local ____params_offset_30 = params.offset -- 1287
		if ____params_offset_30 == nil then -- 1287
			____params_offset_30 = 0 -- 1287
		end -- 1287
		local result = __TS__Await(____Tools_searchFiles_40({ -- 1277
			workDir = ____input_workDir_33, -- 1278
			path = ____temp_34, -- 1279
			pattern = ____temp_35, -- 1280
			globs = ____params_globs_36, -- 1281
			useRegex = ____params_useRegex_37, -- 1282
			caseSensitive = ____params_caseSensitive_38, -- 1283
			includeContent = true, -- 1284
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 1285
			limit = ____math_max_29_result_39, -- 1286
			offset = ____math_max_32( -- 1287
				0, -- 1287
				____math_floor_31(__TS__Number(____params_offset_30)) -- 1287
			), -- 1287
			groupByFile = params.groupByFile == true -- 1288
		})) -- 1288
		return ____awaiter_resolve(nil, result) -- 1288
	end) -- 1288
end -- 1275
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1293
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1293
		local last = shared.history[#shared.history] -- 1294
		if last ~= nil then -- 1294
			local followupHint = shared.useChineseResponse and "然后读取搜索结果中相关的文件来了解详情。" or "Then read the relevant files from the search results to inspect the details." -- 1296
			if not __TS__StringIncludes(last.reason, followupHint) then -- 1296
				last.reason = __TS__StringTrim((last.reason .. " ") .. followupHint) -- 1300
			end -- 1300
			local result = execRes -- 1302
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1303
			emitAgentEvent(shared, { -- 1304
				type = "tool_finished", -- 1305
				sessionId = shared.sessionId, -- 1306
				taskId = shared.taskId, -- 1307
				step = shared.step + 1, -- 1308
				tool = last.tool, -- 1309
				result = last.result -- 1310
			}) -- 1310
		end -- 1310
		__TS__Await(maybeCompressHistory(shared)) -- 1313
		persistHistoryState(shared) -- 1314
		shared.step = shared.step + 1 -- 1315
		return ____awaiter_resolve(nil, "main") -- 1315
	end) -- 1315
end -- 1293
local SearchDoraAPIAction = __TS__Class() -- 1320
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 1320
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 1320
function SearchDoraAPIAction.prototype.prep(self, shared) -- 1321
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1321
		local last = shared.history[#shared.history] -- 1322
		if not last then -- 1322
			error( -- 1323
				__TS__New(Error, "no history"), -- 1323
				0 -- 1323
			) -- 1323
		end -- 1323
		emitAgentEvent(shared, { -- 1324
			type = "tool_started", -- 1325
			sessionId = shared.sessionId, -- 1326
			taskId = shared.taskId, -- 1327
			step = shared.step + 1, -- 1328
			tool = last.tool -- 1329
		}) -- 1329
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 1329
	end) -- 1329
end -- 1321
function SearchDoraAPIAction.prototype.exec(self, input) -- 1334
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1334
		local params = input.params -- 1335
		local ____Tools_searchDoraAPI_48 = Tools.searchDoraAPI -- 1336
		local ____temp_44 = params.pattern or "" -- 1337
		local ____temp_45 = params.docSource or "api" -- 1338
		local ____temp_46 = input.useChineseResponse and "zh" or "en" -- 1339
		local ____temp_47 = params.programmingLanguage or "ts" -- 1340
		local ____math_min_43 = math.min -- 1341
		local ____math_max_42 = math.max -- 1341
		local ____params_limit_41 = params.limit -- 1341
		if ____params_limit_41 == nil then -- 1341
			____params_limit_41 = 8 -- 1341
		end -- 1341
		local result = __TS__Await(____Tools_searchDoraAPI_48({ -- 1336
			pattern = ____temp_44, -- 1337
			docSource = ____temp_45, -- 1338
			docLanguage = ____temp_46, -- 1339
			programmingLanguage = ____temp_47, -- 1340
			limit = ____math_min_43( -- 1341
				SEARCH_DORA_API_LIMIT_MAX, -- 1341
				____math_max_42( -- 1341
					1, -- 1341
					__TS__Number(____params_limit_41) -- 1341
				) -- 1341
			), -- 1341
			useRegex = params.useRegex, -- 1342
			caseSensitive = false, -- 1343
			includeContent = true, -- 1344
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 1345
		})) -- 1345
		return ____awaiter_resolve(nil, result) -- 1345
	end) -- 1345
end -- 1334
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 1350
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1350
		local last = shared.history[#shared.history] -- 1351
		if last ~= nil then -- 1351
			local result = execRes -- 1353
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 1354
			emitAgentEvent(shared, { -- 1355
				type = "tool_finished", -- 1356
				sessionId = shared.sessionId, -- 1357
				taskId = shared.taskId, -- 1358
				step = shared.step + 1, -- 1359
				tool = last.tool, -- 1360
				result = last.result -- 1361
			}) -- 1361
		end -- 1361
		__TS__Await(maybeCompressHistory(shared)) -- 1364
		persistHistoryState(shared) -- 1365
		shared.step = shared.step + 1 -- 1366
		return ____awaiter_resolve(nil, "main") -- 1366
	end) -- 1366
end -- 1350
local ListFilesAction = __TS__Class() -- 1371
ListFilesAction.name = "ListFilesAction" -- 1371
__TS__ClassExtends(ListFilesAction, Node) -- 1371
function ListFilesAction.prototype.prep(self, shared) -- 1372
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1372
		local last = shared.history[#shared.history] -- 1373
		if not last then -- 1373
			error( -- 1374
				__TS__New(Error, "no history"), -- 1374
				0 -- 1374
			) -- 1374
		end -- 1374
		emitAgentEvent(shared, { -- 1375
			type = "tool_started", -- 1376
			sessionId = shared.sessionId, -- 1377
			taskId = shared.taskId, -- 1378
			step = shared.step + 1, -- 1379
			tool = last.tool -- 1380
		}) -- 1380
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1380
	end) -- 1380
end -- 1372
function ListFilesAction.prototype.exec(self, input) -- 1385
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1385
		local params = input.params -- 1386
		local ____Tools_listFiles_55 = Tools.listFiles -- 1387
		local ____input_workDir_52 = input.workDir -- 1388
		local ____temp_53 = params.path or "" -- 1389
		local ____params_globs_54 = params.globs -- 1390
		local ____math_max_51 = math.max -- 1391
		local ____math_floor_50 = math.floor -- 1391
		local ____params_maxEntries_49 = params.maxEntries -- 1391
		if ____params_maxEntries_49 == nil then -- 1391
			____params_maxEntries_49 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 1391
		end -- 1391
		local result = ____Tools_listFiles_55({ -- 1387
			workDir = ____input_workDir_52, -- 1388
			path = ____temp_53, -- 1389
			globs = ____params_globs_54, -- 1390
			maxEntries = ____math_max_51( -- 1391
				1, -- 1391
				____math_floor_50(__TS__Number(____params_maxEntries_49)) -- 1391
			) -- 1391
		}) -- 1391
		return ____awaiter_resolve(nil, result) -- 1391
	end) -- 1391
end -- 1385
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 1396
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1396
		local last = shared.history[#shared.history] -- 1397
		if last ~= nil then -- 1397
			last.result = sanitizeListFilesResultForHistory(execRes) -- 1399
			emitAgentEvent(shared, { -- 1400
				type = "tool_finished", -- 1401
				sessionId = shared.sessionId, -- 1402
				taskId = shared.taskId, -- 1403
				step = shared.step + 1, -- 1404
				tool = last.tool, -- 1405
				result = last.result -- 1406
			}) -- 1406
		end -- 1406
		__TS__Await(maybeCompressHistory(shared)) -- 1409
		persistHistoryState(shared) -- 1410
		shared.step = shared.step + 1 -- 1411
		return ____awaiter_resolve(nil, "main") -- 1411
	end) -- 1411
end -- 1396
local DeleteFileAction = __TS__Class() -- 1416
DeleteFileAction.name = "DeleteFileAction" -- 1416
__TS__ClassExtends(DeleteFileAction, Node) -- 1416
function DeleteFileAction.prototype.prep(self, shared) -- 1417
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1417
		local last = shared.history[#shared.history] -- 1418
		if not last then -- 1418
			error( -- 1419
				__TS__New(Error, "no history"), -- 1419
				0 -- 1419
			) -- 1419
		end -- 1419
		emitAgentEvent(shared, { -- 1420
			type = "tool_started", -- 1421
			sessionId = shared.sessionId, -- 1422
			taskId = shared.taskId, -- 1423
			step = shared.step + 1, -- 1424
			tool = last.tool -- 1425
		}) -- 1425
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 1427
		if __TS__StringTrim(targetFile) == "" then -- 1427
			error( -- 1430
				__TS__New(Error, "missing target_file"), -- 1430
				0 -- 1430
			) -- 1430
		end -- 1430
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 1430
	end) -- 1430
end -- 1417
function DeleteFileAction.prototype.exec(self, input) -- 1434
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1434
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 1435
		if not result.success then -- 1435
			return ____awaiter_resolve(nil, result) -- 1435
		end -- 1435
		return ____awaiter_resolve(nil, { -- 1435
			success = true, -- 1443
			changed = true, -- 1444
			mode = "delete", -- 1445
			checkpointId = result.checkpointId, -- 1446
			checkpointSeq = result.checkpointSeq, -- 1447
			files = {{path = input.targetFile, op = "delete"}} -- 1448
		}) -- 1448
	end) -- 1448
end -- 1434
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1452
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1452
		local last = shared.history[#shared.history] -- 1453
		if last ~= nil then -- 1453
			last.result = execRes -- 1455
			emitAgentEvent(shared, { -- 1456
				type = "tool_finished", -- 1457
				sessionId = shared.sessionId, -- 1458
				taskId = shared.taskId, -- 1459
				step = shared.step + 1, -- 1460
				tool = last.tool, -- 1461
				result = last.result -- 1462
			}) -- 1462
			local result = last.result -- 1464
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1464
				emitAgentEvent(shared, { -- 1469
					type = "checkpoint_created", -- 1470
					sessionId = shared.sessionId, -- 1471
					taskId = shared.taskId, -- 1472
					step = shared.step + 1, -- 1473
					tool = "delete_file", -- 1474
					checkpointId = result.checkpointId, -- 1475
					checkpointSeq = result.checkpointSeq, -- 1476
					files = result.files -- 1477
				}) -- 1477
			end -- 1477
		end -- 1477
		__TS__Await(maybeCompressHistory(shared)) -- 1481
		persistHistoryState(shared) -- 1482
		shared.step = shared.step + 1 -- 1483
		return ____awaiter_resolve(nil, "main") -- 1483
	end) -- 1483
end -- 1452
local BuildAction = __TS__Class() -- 1488
BuildAction.name = "BuildAction" -- 1488
__TS__ClassExtends(BuildAction, Node) -- 1488
function BuildAction.prototype.prep(self, shared) -- 1489
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1489
		local last = shared.history[#shared.history] -- 1490
		if not last then -- 1490
			error( -- 1491
				__TS__New(Error, "no history"), -- 1491
				0 -- 1491
			) -- 1491
		end -- 1491
		emitAgentEvent(shared, { -- 1492
			type = "tool_started", -- 1493
			sessionId = shared.sessionId, -- 1494
			taskId = shared.taskId, -- 1495
			step = shared.step + 1, -- 1496
			tool = last.tool -- 1497
		}) -- 1497
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 1497
	end) -- 1497
end -- 1489
function BuildAction.prototype.exec(self, input) -- 1502
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1502
		local params = input.params -- 1503
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 1504
		return ____awaiter_resolve(nil, result) -- 1504
	end) -- 1504
end -- 1502
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 1511
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1511
		local last = shared.history[#shared.history] -- 1512
		if last ~= nil then -- 1512
			local followupHint = shared.useChineseResponse and "构建已完成，将根据结果做后续处理，不再重复构建。" or "Build completed. Shall handle the result instead of building again." -- 1514
			local reason = last.reason -- 1514
			last.reason = last.reason and last.reason ~= "" and (last.reason .. "\n") .. followupHint or followupHint -- 1518
			last.result = execRes -- 1521
			emitAgentEvent(shared, { -- 1522
				type = "tool_finished", -- 1523
				sessionId = shared.sessionId, -- 1524
				taskId = shared.taskId, -- 1525
				step = shared.step + 1, -- 1526
				tool = last.tool, -- 1527
				reason = reason, -- 1528
				result = last.result -- 1529
			}) -- 1529
		end -- 1529
		__TS__Await(maybeCompressHistory(shared)) -- 1532
		persistHistoryState(shared) -- 1533
		shared.step = shared.step + 1 -- 1534
		return ____awaiter_resolve(nil, "main") -- 1534
	end) -- 1534
end -- 1511
local EditFileAction = __TS__Class() -- 1539
EditFileAction.name = "EditFileAction" -- 1539
__TS__ClassExtends(EditFileAction, Node) -- 1539
function EditFileAction.prototype.prep(self, shared) -- 1540
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1540
		local last = shared.history[#shared.history] -- 1541
		if not last then -- 1541
			error( -- 1542
				__TS__New(Error, "no history"), -- 1542
				0 -- 1542
			) -- 1542
		end -- 1542
		emitAgentEvent(shared, { -- 1543
			type = "tool_started", -- 1544
			sessionId = shared.sessionId, -- 1545
			taskId = shared.taskId, -- 1546
			step = shared.step + 1, -- 1547
			tool = last.tool -- 1548
		}) -- 1548
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 1550
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 1553
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 1554
		if __TS__StringTrim(path) == "" then -- 1554
			error( -- 1555
				__TS__New(Error, "missing path"), -- 1555
				0 -- 1555
			) -- 1555
		end -- 1555
		if oldStr == newStr then -- 1555
			error( -- 1556
				__TS__New(Error, "old_str and new_str must be different"), -- 1556
				0 -- 1556
			) -- 1556
		end -- 1556
		return ____awaiter_resolve(nil, { -- 1556
			path = path, -- 1557
			oldStr = oldStr, -- 1557
			newStr = newStr, -- 1557
			taskId = shared.taskId, -- 1557
			workDir = shared.workingDir -- 1557
		}) -- 1557
	end) -- 1557
end -- 1540
function EditFileAction.prototype.exec(self, input) -- 1560
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1560
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 1561
		if not readRes.success then -- 1561
			if input.oldStr ~= "" then -- 1561
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1561
			end -- 1561
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1566
			if not createRes.success then -- 1566
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1566
			end -- 1566
			return ____awaiter_resolve(nil, { -- 1566
				success = true, -- 1574
				changed = true, -- 1575
				mode = "create", -- 1576
				replaced = 0, -- 1577
				checkpointId = createRes.checkpointId, -- 1578
				checkpointSeq = createRes.checkpointSeq, -- 1579
				files = {{path = input.path, op = "create"}} -- 1580
			}) -- 1580
		end -- 1580
		if input.oldStr == "" then -- 1580
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 1580
		end -- 1580
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 1587
		if replaceRes.replaced == 0 then -- 1587
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 1587
		end -- 1587
		if replaceRes.content == readRes.content then -- 1587
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 1587
		end -- 1587
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1600
		if not applyRes.success then -- 1600
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1600
		end -- 1600
		return ____awaiter_resolve(nil, { -- 1600
			success = true, -- 1608
			changed = true, -- 1609
			mode = "replace", -- 1610
			replaced = replaceRes.replaced, -- 1611
			checkpointId = applyRes.checkpointId, -- 1612
			checkpointSeq = applyRes.checkpointSeq, -- 1613
			files = {{path = input.path, op = "write"}} -- 1614
		}) -- 1614
	end) -- 1614
end -- 1560
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1618
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1618
		local last = shared.history[#shared.history] -- 1619
		if last ~= nil then -- 1619
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1621
			last.result = execRes -- 1622
			emitAgentEvent(shared, { -- 1623
				type = "tool_finished", -- 1624
				sessionId = shared.sessionId, -- 1625
				taskId = shared.taskId, -- 1626
				step = shared.step + 1, -- 1627
				tool = last.tool, -- 1628
				result = last.result -- 1629
			}) -- 1629
			local result = last.result -- 1631
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and type(result.files) == "table" then -- 1631
				emitAgentEvent(shared, { -- 1636
					type = "checkpoint_created", -- 1637
					sessionId = shared.sessionId, -- 1638
					taskId = shared.taskId, -- 1639
					step = shared.step + 1, -- 1640
					tool = last.tool, -- 1641
					checkpointId = result.checkpointId, -- 1642
					checkpointSeq = result.checkpointSeq, -- 1643
					files = result.files -- 1644
				}) -- 1644
			end -- 1644
		end -- 1644
		__TS__Await(maybeCompressHistory(shared)) -- 1648
		persistHistoryState(shared) -- 1649
		shared.step = shared.step + 1 -- 1650
		return ____awaiter_resolve(nil, "main") -- 1650
	end) -- 1650
end -- 1618
local FormatResponseNode = __TS__Class() -- 1655
FormatResponseNode.name = "FormatResponseNode" -- 1655
__TS__ClassExtends(FormatResponseNode, Node) -- 1655
function FormatResponseNode.prototype.prep(self, shared) -- 1656
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1656
		local last = shared.history[#shared.history] -- 1657
		if last and last.tool == "finish" then -- 1657
			emitAgentEvent(shared, { -- 1659
				type = "tool_started", -- 1660
				sessionId = shared.sessionId, -- 1661
				taskId = shared.taskId, -- 1662
				step = shared.step + 1, -- 1663
				tool = last.tool -- 1664
			}) -- 1664
		end -- 1664
		return ____awaiter_resolve(nil, {history = shared.history, shared = shared}) -- 1664
	end) -- 1664
end -- 1656
function FormatResponseNode.prototype.exec(self, input) -- 1670
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1670
		if input.shared.stopToken.stopped then -- 1670
			return ____awaiter_resolve( -- 1670
				nil, -- 1670
				getCancelledReason(input.shared) -- 1672
			) -- 1672
		end -- 1672
		local history = input.history -- 1674
		if #history == 0 then -- 1674
			return ____awaiter_resolve(nil, "No actions were performed.") -- 1674
		end -- 1674
		local summary = formatHistorySummary(history) -- 1678
		local prompt = replacePromptVars( -- 1679
			input.shared.promptPack.finalSummaryPrompt, -- 1679
			{ -- 1679
				SUMMARY = summary, -- 1680
				LANGUAGE_DIRECTIVE = getReplyLanguageDirective(input.shared) -- 1681
			} -- 1681
		) -- 1681
		local res -- 1683
		do -- 1683
			local i = 0 -- 1684
			while i < input.shared.llmMaxTry do -- 1684
				res = __TS__Await(llmStream(input.shared, {{role = "user", content = prompt}})) -- 1685
				if res.success then -- 1685
					break -- 1686
				end -- 1686
				i = i + 1 -- 1684
			end -- 1684
		end -- 1684
		if not res then -- 1684
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败。" or "Completed, but failed to generate summary.") -- 1684
		end -- 1684
		if not res.success then -- 1684
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败：" .. res.message or "Completed, but failed to generate summary: " .. res.message) -- 1684
		end -- 1684
		return ____awaiter_resolve(nil, res.text) -- 1684
	end) -- 1684
end -- 1670
function FormatResponseNode.prototype.post(self, shared, _prepRes, execRes) -- 1699
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1699
		local last = shared.history[#shared.history] -- 1700
		if last and last.tool == "finish" then -- 1700
			last.result = {success = true, message = execRes} -- 1702
			emitAgentEvent(shared, { -- 1703
				type = "tool_finished", -- 1704
				sessionId = shared.sessionId, -- 1705
				taskId = shared.taskId, -- 1706
				step = shared.step + 1, -- 1707
				tool = last.tool, -- 1708
				result = last.result -- 1709
			}) -- 1709
			shared.step = shared.step + 1 -- 1711
		end -- 1711
		shared.response = execRes -- 1713
		shared.done = true -- 1714
		persistHistoryState(shared) -- 1715
		return ____awaiter_resolve(nil, nil) -- 1715
	end) -- 1715
end -- 1699
local CodingAgentFlow = __TS__Class() -- 1720
CodingAgentFlow.name = "CodingAgentFlow" -- 1720
__TS__ClassExtends(CodingAgentFlow, Flow) -- 1720
function CodingAgentFlow.prototype.____constructor(self) -- 1721
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 1722
	local read = __TS__New(ReadFileAction, 1, 0) -- 1723
	local search = __TS__New(SearchFilesAction, 1, 0) -- 1724
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 1725
	local list = __TS__New(ListFilesAction, 1, 0) -- 1726
	local del = __TS__New(DeleteFileAction, 1, 0) -- 1727
	local build = __TS__New(BuildAction, 1, 0) -- 1728
	local edit = __TS__New(EditFileAction, 1, 0) -- 1729
	local format = __TS__New(FormatResponseNode, 1, 0) -- 1730
	main:on("read_file", read) -- 1732
	main:on("read_file_range", read) -- 1733
	main:on("grep_files", search) -- 1734
	main:on("search_dora_api", searchDora) -- 1735
	main:on("glob_files", list) -- 1736
	main:on("delete_file", del) -- 1737
	main:on("build", build) -- 1738
	main:on("edit_file", edit) -- 1739
	main:on("finish", format) -- 1740
	main:on("error", format) -- 1741
	read:on("main", main) -- 1743
	search:on("main", main) -- 1744
	searchDora:on("main", main) -- 1745
	list:on("main", main) -- 1746
	del:on("main", main) -- 1747
	build:on("main", main) -- 1748
	edit:on("main", main) -- 1749
	Flow.prototype.____constructor(self, main) -- 1751
end -- 1721
local function runCodingAgentAsync(options) -- 1755
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1755
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 1755
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 1755
		end -- 1755
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 1759
		if not llmConfigRes.success then -- 1759
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 1759
		end -- 1759
		local llmConfig = llmConfigRes.config -- 1765
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 1766
		if not taskRes.success then -- 1766
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 1766
		end -- 1766
		local compressor = __TS__New(MemoryCompressor, { -- 1773
			compressionThreshold = 0.8, -- 1774
			maxCompressionRounds = 3, -- 1775
			maxTokensPerCompression = 20000, -- 1776
			projectDir = options.workDir, -- 1777
			llmConfig = llmConfig, -- 1778
			promptPack = options.promptPack -- 1779
		}) -- 1779
		local persistedSession = compressor:getStorage():readSessionState() -- 1781
		local promptPack = compressor:getPromptPack() -- 1782
		local shared = { -- 1784
			sessionId = options.sessionId, -- 1785
			taskId = taskRes.taskId, -- 1786
			maxSteps = math.max( -- 1787
				1, -- 1787
				math.floor(options.maxSteps or 40) -- 1787
			), -- 1787
			llmMaxTry = math.max( -- 1788
				1, -- 1788
				math.floor(options.llmMaxTry or 3) -- 1788
			), -- 1788
			step = 0, -- 1789
			done = false, -- 1790
			stopToken = options.stopToken or ({stopped = false}), -- 1791
			response = "", -- 1792
			userQuery = options.prompt, -- 1793
			workingDir = options.workDir, -- 1794
			useChineseResponse = options.useChineseResponse == true, -- 1795
			decisionMode = options.decisionMode == "yaml" and "yaml" or "tool_calling", -- 1796
			llmOptions = __TS__ObjectAssign({temperature = 0.2}, options.llmOptions or ({})), -- 1797
			llmConfig = llmConfig, -- 1801
			onEvent = options.onEvent, -- 1802
			promptPack = promptPack, -- 1803
			history = persistedSession.history, -- 1804
			memory = {lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, compressor = compressor} -- 1806
		} -- 1806
		local ____try = __TS__AsyncAwaiter(function() -- 1806
			emitAgentEvent(shared, { -- 1813
				type = "task_started", -- 1814
				sessionId = shared.sessionId, -- 1815
				taskId = shared.taskId, -- 1816
				prompt = shared.userQuery, -- 1817
				workDir = shared.workingDir, -- 1818
				maxSteps = shared.maxSteps -- 1819
			}) -- 1819
			if shared.stopToken.stopped then -- 1819
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1822
				local result = { -- 1823
					success = false, -- 1823
					taskId = shared.taskId, -- 1823
					message = getCancelledReason(shared), -- 1823
					steps = shared.step -- 1823
				} -- 1823
				emitAgentEvent(shared, { -- 1824
					type = "task_finished", -- 1825
					sessionId = shared.sessionId, -- 1826
					taskId = shared.taskId, -- 1827
					success = false, -- 1828
					message = result.message, -- 1829
					steps = result.steps -- 1830
				}) -- 1830
				return ____awaiter_resolve(nil, result) -- 1830
			end -- 1830
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 1834
			local flow = __TS__New(CodingAgentFlow) -- 1835
			__TS__Await(flow:run(shared)) -- 1836
			if shared.stopToken.stopped then -- 1836
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1838
				local result = { -- 1839
					success = false, -- 1839
					taskId = shared.taskId, -- 1839
					message = getCancelledReason(shared), -- 1839
					steps = shared.step -- 1839
				} -- 1839
				emitAgentEvent(shared, { -- 1840
					type = "task_finished", -- 1841
					sessionId = shared.sessionId, -- 1842
					taskId = shared.taskId, -- 1843
					success = false, -- 1844
					message = result.message, -- 1845
					steps = result.steps -- 1846
				}) -- 1846
				return ____awaiter_resolve(nil, result) -- 1846
			end -- 1846
			if shared.error then -- 1846
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1851
				local result = {success = false, taskId = shared.taskId, message = shared.error, steps = shared.step} -- 1852
				emitAgentEvent(shared, { -- 1853
					type = "task_finished", -- 1854
					sessionId = shared.sessionId, -- 1855
					taskId = shared.taskId, -- 1856
					success = false, -- 1857
					message = result.message, -- 1858
					steps = result.steps -- 1859
				}) -- 1859
				return ____awaiter_resolve(nil, result) -- 1859
			end -- 1859
			Tools.setTaskStatus(shared.taskId, "DONE") -- 1863
			local result = {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step} -- 1864
			emitAgentEvent(shared, { -- 1870
				type = "task_finished", -- 1871
				sessionId = shared.sessionId, -- 1872
				taskId = shared.taskId, -- 1873
				success = true, -- 1874
				message = result.message, -- 1875
				steps = result.steps -- 1876
			}) -- 1876
			return ____awaiter_resolve(nil, result) -- 1876
		end) -- 1876
		__TS__Await(____try.catch( -- 1812
			____try, -- 1812
			function(____, e) -- 1812
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1880
				local result = { -- 1881
					success = false, -- 1881
					taskId = shared.taskId, -- 1881
					message = tostring(e), -- 1881
					steps = shared.step -- 1881
				} -- 1881
				emitAgentEvent(shared, { -- 1882
					type = "task_finished", -- 1883
					sessionId = shared.sessionId, -- 1884
					taskId = shared.taskId, -- 1885
					success = false, -- 1886
					message = result.message, -- 1887
					steps = result.steps -- 1888
				}) -- 1888
				return ____awaiter_resolve(nil, result) -- 1888
			end -- 1888
		)) -- 1888
	end) -- 1888
end -- 1755
function ____exports.runCodingAgent(options, callback) -- 1894
	local ____self_56 = runCodingAgentAsync(options) -- 1894
	____self_56["then"]( -- 1894
		____self_56, -- 1894
		function(____, result) return callback(result) end -- 1895
	) -- 1895
end -- 1894
return ____exports -- 1894