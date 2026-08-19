-- [ts]: HistoryProjection.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local ____exports = {} -- 1
local AgentUtils = require("Agent.Utils") -- 1
local AgentConfig = require("Agent.Config") -- 3
local function isRecord(value) -- 6
	return type(value) == "table" -- 7
end -- 6
local function isArray(value) -- 10
	return __TS__ArrayIsArray(value) -- 11
end -- 10
function ____exports.toJson(value, emptyAsArray) -- 14
	local text, err = AgentUtils.safeJsonEncode(value, false, emptyAsArray) -- 15
	if text ~= nil then -- 15
		return text -- 16
	end -- 16
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 17
end -- 14
function ____exports.truncateText(text, maxLen) -- 20
	local nextPos = utf8.offset(text, maxLen + 1) -- 21
	if nextPos == nil then -- 21
		return text -- 22
	end -- 22
	return string.sub(text, 1, nextPos - 1) .. "..." -- 23
end -- 20
local function utf8TakeHead(text, maxChars) -- 26
	if maxChars <= 0 or text == "" then -- 26
		return "" -- 27
	end -- 27
	local nextPos = utf8.offset(text, maxChars + 1) -- 28
	if nextPos == nil then -- 28
		return text -- 29
	end -- 29
	return string.sub(text, 1, nextPos - 1) -- 30
end -- 26
local function utf8TakeTail(text, maxChars) -- 33
	if maxChars <= 0 or text == "" then -- 33
		return "" -- 34
	end -- 34
	local charLength = utf8.len(text) -- 35
	if charLength == nil or charLength <= maxChars then -- 35
		return text -- 36
	end -- 36
	local startPos = utf8.offset( -- 37
		text, -- 37
		math.max(1, charLength - maxChars + 1) -- 37
	) -- 37
	if startPos == nil then -- 37
		return text -- 38
	end -- 38
	return string.sub(text, startPos) -- 39
end -- 33
local function truncateHistoryText(text, maxChars, label) -- 42
	if maxChars <= 0 or text == "" then -- 42
		return "" -- 43
	end -- 43
	if #text <= maxChars then -- 43
		return text -- 44
	end -- 44
	local marker = ((("\n...[" .. label) .. " truncated; ") .. tostring(#text)) .. " chars total]...\n" -- 45
	local remaining = math.max(0, maxChars - #marker) -- 46
	local headChars = math.floor(remaining * 0.6) -- 47
	local tailChars = remaining - headChars -- 48
	return (utf8TakeHead(text, headChars) .. marker) .. utf8TakeTail(text, tailChars) -- 49
end -- 42
local function limitReadContentForHistory(content, startLine, endLine, totalLines, maxChars, maxLines, label) -- 52
	local sourceLineCount = endLine >= startLine and endLine - startLine + 1 or 0 -- 68
	local contentLines = __TS__StringSplit(content, "\n") -- 69
	local availableSourceLines = math.min(sourceLineCount, #contentLines) -- 70
	if #content <= maxChars and availableSourceLines <= maxLines then -- 70
		return {content = content, truncated = false, retainedStartLine = startLine, retainedEndLine = endLine} -- 72
	end -- 72
	local contentBudget = math.max(0, maxChars - 240) -- 83
	local candidateLines = math.min(availableSourceLines, maxLines) -- 84
	local retainedLines = {} -- 85
	local retainedChars = 0 -- 86
	do -- 86
		local i = 0 -- 87
		while i < candidateLines do -- 87
			local line = contentLines[i + 1] -- 88
			local nextChars = retainedChars + #line + (#retainedLines > 0 and 1 or 0) -- 89
			if nextChars > contentBudget then -- 89
				break -- 90
			end -- 90
			retainedLines[#retainedLines + 1] = line -- 91
			retainedChars = nextChars -- 92
			i = i + 1 -- 87
		end -- 87
	end -- 87
	local retainedEndLine = startLine + #retainedLines - 1 -- 95
	local partialLine -- 96
	local retainedContent = table.concat(retainedLines, "\n") -- 97
	if #retainedLines == 0 and candidateLines > 0 then -- 97
		partialLine = startLine -- 99
		retainedEndLine = startLine - 1 -- 100
		retainedContent = utf8TakeHead(contentLines[1], contentBudget) -- 101
	end -- 101
	local nextStartLine = retainedEndLine < endLine and retainedEndLine + 1 or nil -- 103
	local retainedRange = #retainedLines > 0 and (("complete lines " .. tostring(startLine)) .. "-") .. tostring(retainedEndLine) or (partialLine ~= nil and "a partial preview of overlong line " .. tostring(partialLine) or "no source lines") -- 104
	local continuation = nextStartLine ~= nil and (" Use read_file with startLine=" .. tostring(nextStartLine)) .. " and a narrower endLine to continue." or "" -- 109
	local marker = ((((((((((("[" .. label) .. " retained ") .. retainedRange) .. " of requested lines ") .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (") .. tostring(totalLines)) .. " lines total).") .. continuation) .. "]" -- 112
	return { -- 113
		content = retainedContent == "" and marker or (retainedContent .. "\n\n") .. marker, -- 114
		truncated = true, -- 115
		retainedStartLine = startLine, -- 116
		retainedEndLine = retainedEndLine, -- 117
		nextStartLine = nextStartLine, -- 118
		partialLine = partialLine -- 119
	} -- 119
end -- 52
local function summarizeEditTextParamForHistory(value, key) -- 123
	if type(value) ~= "string" then -- 123
		return nil -- 124
	end -- 124
	local text = value -- 125
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 126
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 127
end -- 123
function ____exports.sanitizeReadResultForHistory(tool, result) -- 135
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 135
		return result -- 137
	end -- 137
	local clone = {} -- 139
	for key in pairs(result) do -- 140
		clone[key] = result[key] -- 141
	end -- 141
	local startLine = type(result.startLine) == "number" and result.startLine or 1 -- 143
	local endLine = type(result.endLine) == "number" and result.endLine or startLine -- 144
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine -- 145
	local limited = limitReadContentForHistory( -- 146
		result.content, -- 147
		startLine, -- 148
		endLine, -- 149
		totalLines, -- 150
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars, -- 151
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines, -- 152
		"read_file history" -- 153
	) -- 153
	clone.content = limited.content -- 155
	if limited.truncated then -- 155
		clone.historyContentTruncated = true -- 157
		clone.historyRetainedStartLine = limited.retainedStartLine -- 158
		clone.historyRetainedEndLine = limited.retainedEndLine -- 159
		if limited.nextStartLine ~= nil then -- 159
			clone.historyNextStartLine = limited.nextStartLine -- 160
		end -- 160
		if limited.partialLine ~= nil then -- 160
			clone.historyPartialLine = limited.partialLine -- 161
		end -- 161
	end -- 161
	return clone -- 163
end -- 135
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 166
	local shown = math.min(#items, maxItems) -- 170
	local out = {} -- 171
	do -- 171
		local i = 0 -- 172
		while i < shown do -- 172
			local row = items[i + 1] -- 173
			out[#out + 1] = { -- 174
				file = row.file, -- 175
				line = row.line, -- 176
				content = type(row.content) == "string" and ____exports.truncateText(row.content, 240) or row.content -- 177
			} -- 177
			i = i + 1 -- 172
		end -- 172
	end -- 172
	return out -- 182
end -- 166
function ____exports.sanitizeSearchResultForHistory(tool, result) -- 185
	if result.success ~= true or not isArray(result.results) then -- 185
		return result -- 189
	end -- 189
	if tool ~= "grep_files" and tool ~= "search_dora_doc" then -- 189
		return result -- 190
	end -- 190
	local clone = {} -- 191
	for key in pairs(result) do -- 192
		clone[key] = result[key] -- 193
	end -- 193
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 195
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 196
	if tool == "grep_files" and isArray(result.groupedResults) then -- 196
		local grouped = result.groupedResults -- 201
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 202
		local sanitizedGroups = {} -- 203
		do -- 203
			local i = 0 -- 204
			while i < shown do -- 204
				local row = grouped[i + 1] -- 205
				sanitizedGroups[#sanitizedGroups + 1] = { -- 206
					file = row.file, -- 207
					totalMatches = row.totalMatches, -- 208
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 209
				} -- 209
				i = i + 1 -- 204
			end -- 204
		end -- 204
		clone.groupedResults = sanitizedGroups -- 214
	end -- 214
	return clone -- 216
end -- 185
function ____exports.sanitizeListFilesResultForHistory(result) -- 219
	if result.success ~= true or not isArray(result.files) then -- 219
		return result -- 220
	end -- 220
	local clone = {} -- 221
	for key in pairs(result) do -- 222
		clone[key] = result[key] -- 223
	end -- 223
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 225
	return clone -- 226
end -- 219
function ____exports.sanitizeBuildResultForHistory(result) -- 229
	if not isArray(result.messages) then -- 229
		return result -- 230
	end -- 230
	local clone = {} -- 231
	for key in pairs(result) do -- 232
		clone[key] = result[key] -- 233
	end -- 233
	local messages = result.messages -- 235
	local ordered = __TS__ArraySort( -- 236
		__TS__ArraySlice(messages), -- 236
		function(____, a, b) -- 236
			local aFailed = a.success ~= true -- 237
			local bFailed = b.success ~= true -- 238
			if aFailed == bFailed then -- 238
				return 0 -- 239
			end -- 239
			return aFailed and -1 or 1 -- 240
		end -- 236
	) -- 236
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 242
	local sanitized = {} -- 243
	do -- 243
		local i = 0 -- 244
		while i < shown do -- 244
			local item = ordered[i + 1] -- 245
			local next = {} -- 246
			for key in pairs(item) do -- 247
				local value = item[key] -- 248
				next[key] = key == "message" and type(value) == "string" and ____exports.truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 249
			end -- 249
			sanitized[#sanitized + 1] = next -- 253
			i = i + 1 -- 244
		end -- 244
	end -- 244
	clone.messages = sanitized -- 255
	if #ordered > shown then -- 255
		clone.truncatedMessages = #ordered - shown -- 257
	end -- 257
	return clone -- 259
end -- 229
function ____exports.sanitizeActionParamsForHistory(tool, params) -- 262
	if tool ~= "edit_file" then -- 262
		return params -- 263
	end -- 263
	local clone = {} -- 264
	for key in pairs(params) do -- 265
		if key == "old_str" then -- 265
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 267
		elseif key == "new_str" then -- 267
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 269
		elseif key == "edits" and isArray(params[key]) then -- 269
			clone.edits = __TS__ArrayMap( -- 271
				params[key], -- 271
				function(____, item) -- 271
					if not isRecord(item) or isArray(item) then -- 271
						return {invalid = true} -- 272
					end -- 272
					return { -- 273
						path = item.path, -- 274
						old_str_stats = summarizeEditTextParamForHistory(item.old_str, "old_str"), -- 275
						new_str_stats = summarizeEditTextParamForHistory(item.new_str, "new_str") -- 276
					} -- 276
				end -- 271
			) -- 271
		else -- 271
			clone[key] = params[key] -- 280
		end -- 280
	end -- 280
	return clone -- 283
end -- 262
local function projectEditResultForLLM(result) -- 286
	if result.success ~= true then -- 286
		local failed = {} -- 288
		for key in pairs(result) do -- 289
			local value = result[key] -- 290
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value -- 291
		end -- 291
		return failed -- 295
	end -- 295
	local projected = {} -- 297
	local scalarKeys = { -- 298
		"success", -- 299
		"changed", -- 299
		"mode", -- 299
		"checkpointId", -- 299
		"checkpointSeq", -- 299
		"checkpointed", -- 300
		"reversible", -- 300
		"binary", -- 300
		"actualSaved", -- 301
		"actualSavedCharacters", -- 301
		"currentFileExists", -- 301
		"currentCharacters", -- 301
		"currentState" -- 301
	} -- 301
	do -- 301
		local i = 0 -- 303
		while i < #scalarKeys do -- 303
			local key = scalarKeys[i + 1] -- 304
			if result[key] ~= nil then -- 304
				projected[key] = result[key] -- 305
			end -- 305
			i = i + 1 -- 303
		end -- 303
	end -- 303
	if isArray(result.files) then -- 303
		projected.files = result.files -- 307
	end -- 307
	if type(result.message) == "string" then -- 307
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 309
	end -- 309
	if type(result.guidance) == "string" then -- 309
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 316
	end -- 316
	if isArray(result.fileContext) then -- 316
		local summaries = {} -- 323
		do -- 323
			local i = 0 -- 324
			while i < #result.fileContext do -- 324
				do -- 324
					local item = result.fileContext[i + 1] -- 325
					if not isRecord(item) or isArray(item) then -- 325
						goto __continue81 -- 326
					end -- 326
					local summary = {} -- 327
					local keys = { -- 328
						"path", -- 329
						"op", -- 329
						"beforeExists", -- 329
						"afterExists", -- 329
						"beforeBytes", -- 329
						"afterBytes", -- 329
						"lineCount", -- 330
						"contentTruncated", -- 330
						"fileListTruncated" -- 330
					} -- 330
					do -- 330
						local j = 0 -- 332
						while j < #keys do -- 332
							local key = keys[j + 1] -- 333
							if item[key] ~= nil then -- 333
								summary[key] = item[key] -- 334
							end -- 334
							j = j + 1 -- 332
						end -- 332
					end -- 332
					summaries[#summaries + 1] = summary -- 336
				end -- 336
				::__continue81:: -- 336
				i = i + 1 -- 324
			end -- 324
		end -- 324
		if #summaries > 0 then -- 324
			projected.fileSummary = summaries -- 338
		end -- 338
	end -- 338
	if type(result.truncatedFileContextItems) == "number" then -- 338
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 341
	end -- 341
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 343
	return projected -- 344
end -- 286
local function projectBuildResultForLLM(result) -- 347
	if not isArray(result.messages) then -- 347
		return result -- 348
	end -- 348
	local projected = {} -- 349
	for key in pairs(result) do -- 350
		if key ~= "messages" then -- 350
			projected[key] = result[key] -- 351
		end -- 351
	end -- 351
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 353
	local shown = math.min(#result.messages, maxMessages) -- 354
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 355
	if #result.messages > shown then -- 355
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 357
	end -- 357
	return projected -- 359
end -- 347
local function projectCommandResultForLLM(result) -- 362
	local projected = {} -- 363
	for key in pairs(result) do -- 364
		local value = result[key] -- 365
		if key == "output" and type(value) == "string" then -- 365
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 367
		elseif key == "message" and type(value) == "string" then -- 367
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 373
		else -- 373
			projected[key] = value -- 379
		end -- 379
	end -- 379
	return projected -- 382
end -- 362
local function projectToolResultContentForLLM(tool, content) -- 385
	local decoded = AgentUtils.safeJsonDecode(content) -- 386
	if not isRecord(decoded) or isArray(decoded) then -- 386
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 388
	end -- 388
	local projected = decoded -- 394
	if tool == "edit_file" or tool == "delete_file" then -- 394
		projected = projectEditResultForLLM(decoded) -- 396
	elseif tool == "build" then -- 396
		projected = projectBuildResultForLLM(decoded) -- 398
	elseif tool == "execute_command" then -- 398
		projected = projectCommandResultForLLM(decoded) -- 400
	end -- 400
	local encoded = ____exports.toJson(projected, false) -- 402
	if tool == "read_file" then -- 402
		return encoded -- 405
	end -- 405
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 405
		return encoded -- 406
	end -- 406
	local fallback = { -- 407
		success = projected.success, -- 408
		llmHistoryTruncated = true, -- 409
		originalChars = #encoded, -- 410
		preview = truncateHistoryText( -- 411
			encoded, -- 412
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 413
			tool .. " result" -- 414
		) -- 414
	} -- 414
	return ____exports.toJson(fallback, false) -- 417
end -- 385
function ____exports.projectMessagesForLLMContext(messages) -- 419
	local projected = {} -- 423
	do -- 423
		local i = 0 -- 424
		while i < #messages do -- 424
			local message = messages[i + 1] -- 425
			local next = __TS__ObjectAssign({}, message) -- 426
			if message.role == "assistant" and (not message.tool_calls or #message.tool_calls == 0) then -- 426
				next.reasoning_content = nil -- 427
			end -- 427
			if message.role == "tool" and type(message.content) == "string" then -- 427
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 429
			end -- 429
			projected[#projected + 1] = next -- 431
			i = i + 1 -- 424
		end -- 424
	end -- 424
	return projected -- 433
end -- 419
function ____exports.projectMessagesForCompression(messages) -- 436
	local projected = ____exports.projectMessagesForLLMContext(messages) -- 437
	do -- 437
		local i = 0 -- 438
		while i < #projected do -- 438
			do -- 438
				local message = projected[i + 1] -- 439
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 439
					goto __continue114 -- 440
				end -- 440
				local changed = false -- 441
				local toolCalls = __TS__ArrayMap( -- 442
					message.tool_calls, -- 442
					function(____, toolCall) -- 442
						local fn = toolCall["function"] -- 443
						if (fn and fn.name) ~= "edit_file" or type(fn.arguments) ~= "string" then -- 443
							return toolCall -- 444
						end -- 444
						local decoded = AgentUtils.safeJsonDecode(fn.arguments) -- 445
						if not isRecord(decoded) or isArray(decoded) then -- 445
							return toolCall -- 446
						end -- 446
						changed = true -- 447
						return __TS__ObjectAssign( -- 448
							{}, -- 448
							toolCall, -- 449
							{["function"] = __TS__ObjectAssign( -- 448
								{}, -- 450
								fn, -- 451
								{arguments = ____exports.toJson( -- 450
									____exports.sanitizeActionParamsForHistory("edit_file", decoded), -- 452
									false -- 452
								)} -- 452
							)} -- 452
						) -- 452
					end -- 442
				) -- 442
				if changed then -- 442
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 456
				end -- 456
			end -- 456
			::__continue114:: -- 456
			i = i + 1 -- 438
		end -- 438
	end -- 438
	return projected -- 458
end -- 436
function ____exports.sanitizeMessagesForLLMInput(messages) -- 461
	local sanitized = {} -- 462
	local droppedAssistantToolCalls = 0 -- 463
	local droppedToolResults = 0 -- 464
	do -- 464
		local i = 0 -- 465
		while i < #messages do -- 465
			do -- 465
				local message = messages[i + 1] -- 466
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 466
					local requiredIds = {} -- 468
					do -- 468
						local j = 0 -- 469
						while j < #message.tool_calls do -- 469
							local toolCall = message.tool_calls[j + 1] -- 470
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 471
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 471
								requiredIds[#requiredIds + 1] = id -- 473
							end -- 473
							j = j + 1 -- 469
						end -- 469
					end -- 469
					if #requiredIds == 0 then -- 469
						sanitized[#sanitized + 1] = message -- 477
						goto __continue122 -- 478
					end -- 478
					local matchedIds = {} -- 480
					local matchedTools = {} -- 481
					local j = i + 1 -- 482
					while j < #messages do -- 482
						local toolMessage = messages[j + 1] -- 484
						if toolMessage.role ~= "tool" then -- 484
							break -- 485
						end -- 485
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 486
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 486
							matchedIds[toolCallId] = true -- 488
							matchedTools[#matchedTools + 1] = toolMessage -- 489
						else -- 489
							droppedToolResults = droppedToolResults + 1 -- 491
						end -- 491
						j = j + 1 -- 493
					end -- 493
					local complete = true -- 495
					do -- 495
						local j = 0 -- 496
						while j < #requiredIds do -- 496
							if matchedIds[requiredIds[j + 1]] ~= true then -- 496
								complete = false -- 498
								break -- 499
							end -- 499
							j = j + 1 -- 496
						end -- 496
					end -- 496
					if complete then -- 496
						__TS__ArrayPush( -- 503
							sanitized, -- 503
							message, -- 503
							table.unpack(matchedTools) -- 503
						) -- 503
					else -- 503
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 505
						droppedToolResults = droppedToolResults + #matchedTools -- 506
					end -- 506
					i = j - 1 -- 508
					goto __continue122 -- 509
				end -- 509
				if message.role == "tool" then -- 509
					droppedToolResults = droppedToolResults + 1 -- 512
					goto __continue122 -- 513
				end -- 513
				sanitized[#sanitized + 1] = message -- 515
			end -- 515
			::__continue122:: -- 515
			i = i + 1 -- 465
		end -- 465
	end -- 465
	return sanitized -- 517
end -- 461
return ____exports -- 461