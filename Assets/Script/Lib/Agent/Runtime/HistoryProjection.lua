-- [ts]: HistoryProjection.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
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
local function sanitizeOneReadResultForHistory(result) -- 135
	if result.success ~= true or type(result.content) ~= "string" then -- 135
		return result -- 136
	end -- 136
	local clone = {} -- 137
	for key in pairs(result) do -- 138
		clone[key] = result[key] -- 139
	end -- 139
	local startLine = type(result.startLine) == "number" and result.startLine or 1 -- 141
	local endLine = type(result.endLine) == "number" and result.endLine or startLine -- 142
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine -- 143
	local limited = limitReadContentForHistory( -- 144
		result.content, -- 145
		startLine, -- 146
		endLine, -- 147
		totalLines, -- 148
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars, -- 149
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines, -- 150
		"read_file history" -- 151
	) -- 151
	clone.content = limited.content -- 153
	if limited.truncated then -- 153
		clone.historyContentTruncated = true -- 155
		clone.historyRetainedStartLine = limited.retainedStartLine -- 156
		clone.historyRetainedEndLine = limited.retainedEndLine -- 157
		if limited.nextStartLine ~= nil then -- 157
			clone.historyNextStartLine = limited.nextStartLine -- 158
		end -- 158
		if limited.partialLine ~= nil then -- 158
			clone.historyPartialLine = limited.partialLine -- 159
		end -- 159
	end -- 159
	return clone -- 161
end -- 135
function ____exports.sanitizeReadResultForHistory(tool, result) -- 164
	if tool ~= "read_file" then -- 164
		return result -- 165
	end -- 165
	if not __TS__ArrayIsArray(result.results) then -- 165
		return sanitizeOneReadResultForHistory(result) -- 166
	end -- 166
	local clone = {} -- 167
	for key in pairs(result) do -- 168
		clone[key] = result[key] -- 168
	end -- 168
	clone.results = __TS__ArrayMap( -- 169
		result.results, -- 169
		function(____, item) return isRecord(item) and not isArray(item) and sanitizeOneReadResultForHistory(item) or item end -- 169
	) -- 169
	return clone -- 172
end -- 164
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 175
	local shown = math.min(#items, maxItems) -- 179
	local out = {} -- 180
	do -- 180
		local i = 0 -- 181
		while i < shown do -- 181
			local row = items[i + 1] -- 182
			out[#out + 1] = { -- 183
				file = row.file, -- 184
				line = row.line, -- 185
				content = type(row.content) == "string" and ____exports.truncateText(row.content, 240) or row.content -- 186
			} -- 186
			i = i + 1 -- 181
		end -- 181
	end -- 181
	return out -- 191
end -- 175
function ____exports.sanitizeSearchResultForHistory(tool, result) -- 194
	if result.success ~= true or not isArray(result.results) then -- 194
		return result -- 198
	end -- 198
	if tool ~= "grep_files" and tool ~= "search_dora_doc" then -- 198
		return result -- 199
	end -- 199
	local clone = {} -- 200
	for key in pairs(result) do -- 201
		clone[key] = result[key] -- 202
	end -- 202
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 204
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 205
	if tool == "grep_files" and isArray(result.groupedResults) then -- 205
		local grouped = result.groupedResults -- 210
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 211
		local sanitizedGroups = {} -- 212
		do -- 212
			local i = 0 -- 213
			while i < shown do -- 213
				local row = grouped[i + 1] -- 214
				sanitizedGroups[#sanitizedGroups + 1] = { -- 215
					file = row.file, -- 216
					totalMatches = row.totalMatches, -- 217
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 218
				} -- 218
				i = i + 1 -- 213
			end -- 213
		end -- 213
		clone.groupedResults = sanitizedGroups -- 223
	end -- 223
	return clone -- 225
end -- 194
function ____exports.sanitizeListFilesResultForHistory(result) -- 228
	if result.success ~= true or not isArray(result.files) then -- 228
		return result -- 229
	end -- 229
	local clone = {} -- 230
	for key in pairs(result) do -- 231
		clone[key] = result[key] -- 232
	end -- 232
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 234
	return clone -- 235
end -- 228
function ____exports.sanitizeBuildResultForHistory(result) -- 238
	if not isArray(result.messages) then -- 238
		return result -- 239
	end -- 239
	local clone = {} -- 240
	for key in pairs(result) do -- 241
		clone[key] = result[key] -- 242
	end -- 242
	local messages = result.messages -- 244
	local ordered = __TS__ArraySort( -- 245
		__TS__ArraySlice(messages), -- 245
		function(____, a, b) -- 245
			local aFailed = a.success ~= true -- 246
			local bFailed = b.success ~= true -- 247
			if aFailed == bFailed then -- 247
				return 0 -- 248
			end -- 248
			return aFailed and -1 or 1 -- 249
		end -- 245
	) -- 245
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 251
	local sanitized = {} -- 252
	do -- 252
		local i = 0 -- 253
		while i < shown do -- 253
			local item = ordered[i + 1] -- 254
			local next = {} -- 255
			for key in pairs(item) do -- 256
				local value = item[key] -- 257
				next[key] = key == "message" and type(value) == "string" and ____exports.truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 258
			end -- 258
			sanitized[#sanitized + 1] = next -- 262
			i = i + 1 -- 253
		end -- 253
	end -- 253
	clone.messages = sanitized -- 264
	if #ordered > shown then -- 264
		clone.truncatedMessages = #ordered - shown -- 266
	end -- 266
	return clone -- 268
end -- 238
function ____exports.sanitizeActionParamsForHistory(tool, params) -- 271
	if tool ~= "edit_file" then -- 271
		return params -- 272
	end -- 272
	local clone = {} -- 273
	for key in pairs(params) do -- 274
		if key == "old_str" then -- 274
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 276
		elseif key == "new_str" then -- 276
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 278
		elseif key == "edits" and isArray(params[key]) then -- 278
			clone.edits = __TS__ArrayMap( -- 280
				params[key], -- 280
				function(____, item) -- 280
					if not isRecord(item) or isArray(item) then -- 280
						return {invalid = true} -- 281
					end -- 281
					return { -- 282
						path = item.path, -- 283
						old_str_stats = summarizeEditTextParamForHistory(item.old_str, "old_str"), -- 284
						new_str_stats = summarizeEditTextParamForHistory(item.new_str, "new_str") -- 285
					} -- 285
				end -- 280
			) -- 280
		else -- 280
			clone[key] = params[key] -- 289
		end -- 289
	end -- 289
	return clone -- 292
end -- 271
local function projectEditResultForLLM(result) -- 295
	if result.success ~= true then -- 295
		local failed = {} -- 297
		for key in pairs(result) do -- 298
			local value = result[key] -- 299
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value -- 300
		end -- 300
		return failed -- 304
	end -- 304
	local projected = {} -- 306
	local scalarKeys = { -- 307
		"success", -- 308
		"changed", -- 308
		"mode", -- 308
		"checkpointId", -- 308
		"checkpointSeq", -- 308
		"checkpointed", -- 309
		"reversible", -- 309
		"binary", -- 309
		"actualSaved", -- 310
		"actualSavedCharacters", -- 310
		"currentFileExists", -- 310
		"currentCharacters", -- 310
		"currentState" -- 310
	} -- 310
	do -- 310
		local i = 0 -- 312
		while i < #scalarKeys do -- 312
			local key = scalarKeys[i + 1] -- 313
			if result[key] ~= nil then -- 313
				projected[key] = result[key] -- 314
			end -- 314
			i = i + 1 -- 312
		end -- 312
	end -- 312
	if isArray(result.files) then -- 312
		projected.files = result.files -- 316
	end -- 316
	if type(result.message) == "string" then -- 316
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 318
	end -- 318
	if type(result.guidance) == "string" then -- 318
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 325
	end -- 325
	if isArray(result.fileContext) then -- 325
		local summaries = {} -- 332
		do -- 332
			local i = 0 -- 333
			while i < #result.fileContext do -- 333
				do -- 333
					local item = result.fileContext[i + 1] -- 334
					if not isRecord(item) or isArray(item) then -- 334
						goto __continue87 -- 335
					end -- 335
					local summary = {} -- 336
					local keys = { -- 337
						"path", -- 338
						"op", -- 338
						"beforeExists", -- 338
						"afterExists", -- 338
						"beforeBytes", -- 338
						"afterBytes", -- 338
						"lineCount", -- 339
						"contentTruncated", -- 339
						"fileListTruncated" -- 339
					} -- 339
					do -- 339
						local j = 0 -- 341
						while j < #keys do -- 341
							local key = keys[j + 1] -- 342
							if item[key] ~= nil then -- 342
								summary[key] = item[key] -- 343
							end -- 343
							j = j + 1 -- 341
						end -- 341
					end -- 341
					summaries[#summaries + 1] = summary -- 345
				end -- 345
				::__continue87:: -- 345
				i = i + 1 -- 333
			end -- 333
		end -- 333
		if #summaries > 0 then -- 333
			projected.fileSummary = summaries -- 347
		end -- 347
	end -- 347
	if type(result.truncatedFileContextItems) == "number" then -- 347
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 350
	end -- 350
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 352
	return projected -- 353
end -- 295
local function projectOneBuildResultForLLM(result) -- 356
	if not isArray(result.messages) then -- 356
		return result -- 357
	end -- 357
	local projected = {} -- 358
	for key in pairs(result) do -- 359
		if key ~= "messages" then -- 359
			projected[key] = result[key] -- 360
		end -- 360
	end -- 360
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 362
	local shown = math.min(#result.messages, maxMessages) -- 363
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 364
	if #result.messages > shown then -- 364
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 366
	end -- 366
	return projected -- 368
end -- 356
local function projectBuildResultForLLM(result) -- 371
	if not isArray(result.results) then -- 371
		return projectOneBuildResultForLLM(result) -- 372
	end -- 372
	local projected = {} -- 373
	for key in pairs(result) do -- 374
		if key ~= "results" then -- 374
			projected[key] = result[key] -- 375
		end -- 375
	end -- 375
	projected.results = __TS__ArrayMap( -- 377
		result.results, -- 377
		function(____, item) return isRecord(item) and not isArray(item) and projectOneBuildResultForLLM(item) or item end -- 377
	) -- 377
	return projected -- 380
end -- 371
local function projectCommandResultForLLM(result) -- 383
	local projected = {} -- 384
	for key in pairs(result) do -- 385
		local value = result[key] -- 386
		if key == "output" and type(value) == "string" then -- 386
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 388
		elseif key == "message" and type(value) == "string" then -- 388
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 394
		else -- 394
			projected[key] = value -- 400
		end -- 400
	end -- 400
	return projected -- 403
end -- 383
local function projectToolResultContentForLLM(tool, content) -- 406
	local decoded = AgentUtils.safeJsonDecode(content) -- 407
	if not isRecord(decoded) or isArray(decoded) then -- 407
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 409
	end -- 409
	local projected = decoded -- 415
	if tool == "edit_file" or tool == "delete_file" then -- 415
		projected = projectEditResultForLLM(decoded) -- 417
	elseif tool == "build" then -- 417
		projected = projectBuildResultForLLM(decoded) -- 419
	elseif tool == "execute_command" then -- 419
		projected = projectCommandResultForLLM(decoded) -- 421
	end -- 421
	local encoded = ____exports.toJson(projected, false) -- 423
	if tool == "read_file" then -- 423
		return encoded -- 426
	end -- 426
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 426
		return encoded -- 427
	end -- 427
	local fallback = { -- 428
		success = projected.success, -- 429
		llmHistoryTruncated = true, -- 430
		originalChars = #encoded, -- 431
		preview = truncateHistoryText( -- 432
			encoded, -- 433
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 434
			tool .. " result" -- 435
		) -- 435
	} -- 435
	return ____exports.toJson(fallback, false) -- 438
end -- 406
function ____exports.projectMessagesForLLMContext(messages) -- 440
	local projected = {} -- 444
	do -- 444
		local i = 0 -- 445
		while i < #messages do -- 445
			local message = messages[i + 1] -- 446
			local next = __TS__ObjectAssign({}, message) -- 447
			if message.role == "assistant" and (not message.tool_calls or #message.tool_calls == 0) then -- 447
				next.reasoning_content = nil -- 448
			end -- 448
			if message.role == "tool" and type(message.content) == "string" then -- 448
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 450
			end -- 450
			projected[#projected + 1] = next -- 452
			i = i + 1 -- 445
		end -- 445
	end -- 445
	return projected -- 454
end -- 440
function ____exports.projectMessagesForCompression(messages) -- 457
	local projected = ____exports.projectMessagesForLLMContext(messages) -- 458
	do -- 458
		local i = 0 -- 459
		while i < #projected do -- 459
			do -- 459
				local message = projected[i + 1] -- 460
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 460
					goto __continue126 -- 461
				end -- 461
				local changed = false -- 462
				local toolCalls = __TS__ArrayMap( -- 463
					message.tool_calls, -- 463
					function(____, toolCall) -- 463
						local fn = toolCall["function"] -- 464
						if (fn and fn.name) ~= "edit_file" or type(fn.arguments) ~= "string" then -- 464
							return toolCall -- 465
						end -- 465
						local decoded = AgentUtils.safeJsonDecode(fn.arguments) -- 466
						if not isRecord(decoded) or isArray(decoded) then -- 466
							return toolCall -- 467
						end -- 467
						changed = true -- 468
						return __TS__ObjectAssign( -- 469
							{}, -- 469
							toolCall, -- 470
							{["function"] = __TS__ObjectAssign( -- 469
								{}, -- 471
								fn, -- 472
								{arguments = ____exports.toJson( -- 471
									____exports.sanitizeActionParamsForHistory("edit_file", decoded), -- 473
									false -- 473
								)} -- 473
							)} -- 473
						) -- 473
					end -- 463
				) -- 463
				if changed then -- 463
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 477
				end -- 477
			end -- 477
			::__continue126:: -- 477
			i = i + 1 -- 459
		end -- 459
	end -- 459
	return projected -- 479
end -- 457
function ____exports.sanitizeMessagesForLLMInput(messages) -- 482
	local sanitized = {} -- 483
	local droppedAssistantToolCalls = 0 -- 484
	local droppedToolResults = 0 -- 485
	do -- 485
		local i = 0 -- 486
		while i < #messages do -- 486
			do -- 486
				local message = messages[i + 1] -- 487
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 487
					local requiredIds = {} -- 489
					do -- 489
						local j = 0 -- 490
						while j < #message.tool_calls do -- 490
							local toolCall = message.tool_calls[j + 1] -- 491
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 492
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 492
								requiredIds[#requiredIds + 1] = id -- 494
							end -- 494
							j = j + 1 -- 490
						end -- 490
					end -- 490
					if #requiredIds == 0 then -- 490
						sanitized[#sanitized + 1] = message -- 498
						goto __continue134 -- 499
					end -- 499
					local matchedIds = {} -- 501
					local matchedTools = {} -- 502
					local j = i + 1 -- 503
					while j < #messages do -- 503
						local toolMessage = messages[j + 1] -- 505
						if toolMessage.role ~= "tool" then -- 505
							break -- 506
						end -- 506
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 507
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 507
							matchedIds[toolCallId] = true -- 509
							matchedTools[#matchedTools + 1] = toolMessage -- 510
						else -- 510
							droppedToolResults = droppedToolResults + 1 -- 512
						end -- 512
						j = j + 1 -- 514
					end -- 514
					local complete = true -- 516
					do -- 516
						local j = 0 -- 517
						while j < #requiredIds do -- 517
							if matchedIds[requiredIds[j + 1]] ~= true then -- 517
								complete = false -- 519
								break -- 520
							end -- 520
							j = j + 1 -- 517
						end -- 517
					end -- 517
					if complete then -- 517
						__TS__ArrayPush( -- 524
							sanitized, -- 524
							message, -- 524
							table.unpack(matchedTools) -- 524
						) -- 524
					else -- 524
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 526
						droppedToolResults = droppedToolResults + #matchedTools -- 527
					end -- 527
					i = j - 1 -- 529
					goto __continue134 -- 530
				end -- 530
				if message.role == "tool" then -- 530
					droppedToolResults = droppedToolResults + 1 -- 533
					goto __continue134 -- 534
				end -- 534
				sanitized[#sanitized + 1] = message -- 536
			end -- 536
			::__continue134:: -- 536
			i = i + 1 -- 486
		end -- 486
	end -- 486
	return sanitized -- 538
end -- 482
return ____exports -- 482