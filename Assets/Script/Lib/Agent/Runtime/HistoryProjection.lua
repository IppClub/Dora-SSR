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
local AgentUtils = require("Agent.Utils") -- 2
local AgentConfig = require("Agent.Config.Defaults") -- 4
--- Frontend lifecycle stays on the step; the model receives only the build outcome.
function ____exports.projectBuildResultForModel(result, execution) -- 602
	if execution ~= nil and execution.status ~= "DONE" or result.failureKind == "tool" or type(result.code) == "string" then -- 602
		return {message = "Build tool call failed: " .. (type(result.message) == "string" and result.message or "unknown failure")} -- 604
	end -- 604
	return result -- 606
end -- 602
local function isRecord(value) -- 7
	return type(value) == "table" -- 8
end -- 7
local function isArray(value) -- 11
	return __TS__ArrayIsArray(value) -- 12
end -- 11
function ____exports.toJson(value, emptyAsArray) -- 15
	local text, err = AgentUtils.safeJsonEncode(value, false, emptyAsArray) -- 16
	if text ~= nil then -- 16
		return text -- 17
	end -- 17
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 18
end -- 15
function ____exports.truncateText(text, maxLen) -- 21
	local nextPos = utf8.offset(text, maxLen + 1) -- 22
	if nextPos == nil then -- 22
		return text -- 23
	end -- 23
	return string.sub(text, 1, nextPos - 1) .. "..." -- 24
end -- 21
local function utf8TakeHead(text, maxChars) -- 27
	if maxChars <= 0 or text == "" then -- 27
		return "" -- 28
	end -- 28
	local nextPos = utf8.offset(text, maxChars + 1) -- 29
	if nextPos == nil then -- 29
		return text -- 30
	end -- 30
	return string.sub(text, 1, nextPos - 1) -- 31
end -- 27
local function utf8TakeTail(text, maxChars) -- 34
	if maxChars <= 0 or text == "" then -- 34
		return "" -- 35
	end -- 35
	local charLength = utf8.len(text) -- 36
	if charLength == nil or charLength <= maxChars then -- 36
		return text -- 37
	end -- 37
	local startPos = utf8.offset( -- 38
		text, -- 38
		math.max(1, charLength - maxChars + 1) -- 38
	) -- 38
	if startPos == nil then -- 38
		return text -- 39
	end -- 39
	return string.sub(text, startPos) -- 40
end -- 34
local function truncateHistoryText(text, maxChars, label) -- 43
	if maxChars <= 0 or text == "" then -- 43
		return "" -- 44
	end -- 44
	if #text <= maxChars then -- 44
		return text -- 45
	end -- 45
	local marker = ((("\n...[" .. label) .. " truncated; ") .. tostring(#text)) .. " chars total]...\n" -- 46
	local remaining = math.max(0, maxChars - #marker) -- 47
	local headChars = math.floor(remaining * 0.6) -- 48
	local tailChars = remaining - headChars -- 49
	return (utf8TakeHead(text, headChars) .. marker) .. utf8TakeTail(text, tailChars) -- 50
end -- 43
local function limitReadContentForHistory(content, startLine, endLine, totalLines, maxChars, maxLines, label) -- 53
	local sourceLineCount = endLine >= startLine and endLine - startLine + 1 or 0 -- 69
	local contentLines = __TS__StringSplit(content, "\n") -- 70
	local availableSourceLines = math.min(sourceLineCount, #contentLines) -- 71
	if #content <= maxChars and availableSourceLines <= maxLines then -- 71
		return {content = content, truncated = false, retainedStartLine = startLine, retainedEndLine = endLine} -- 73
	end -- 73
	local contentBudget = math.max(0, maxChars - 240) -- 84
	local candidateLines = math.min(availableSourceLines, maxLines) -- 85
	local retainedLines = {} -- 86
	local retainedChars = 0 -- 87
	do -- 87
		local i = 0 -- 88
		while i < candidateLines do -- 88
			local line = contentLines[i + 1] -- 89
			local nextChars = retainedChars + #line + (#retainedLines > 0 and 1 or 0) -- 90
			if nextChars > contentBudget then -- 90
				break -- 91
			end -- 91
			retainedLines[#retainedLines + 1] = line -- 92
			retainedChars = nextChars -- 93
			i = i + 1 -- 88
		end -- 88
	end -- 88
	local retainedEndLine = startLine + #retainedLines - 1 -- 96
	local partialLine -- 97
	local retainedContent = table.concat(retainedLines, "\n") -- 98
	if #retainedLines == 0 and candidateLines > 0 then -- 98
		partialLine = startLine -- 100
		retainedEndLine = startLine - 1 -- 101
		retainedContent = utf8TakeHead(contentLines[1], contentBudget) -- 102
	end -- 102
	local nextStartLine = retainedEndLine < endLine and retainedEndLine + 1 or nil -- 104
	local retainedRange = #retainedLines > 0 and (("complete lines " .. tostring(startLine)) .. "-") .. tostring(retainedEndLine) or (partialLine ~= nil and "a partial preview of overlong line " .. tostring(partialLine) or "no source lines") -- 105
	local continuation = nextStartLine ~= nil and (" Use read_file with startLine=" .. tostring(nextStartLine)) .. " and a narrower endLine to continue." or "" -- 110
	local marker = ((((((((((("[" .. label) .. " retained ") .. retainedRange) .. " of requested lines ") .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (") .. tostring(totalLines)) .. " lines total).") .. continuation) .. "]" -- 113
	return { -- 114
		content = retainedContent == "" and marker or (retainedContent .. "\n\n") .. marker, -- 115
		truncated = true, -- 116
		retainedStartLine = startLine, -- 117
		retainedEndLine = retainedEndLine, -- 118
		nextStartLine = nextStartLine, -- 119
		partialLine = partialLine -- 120
	} -- 120
end -- 53
local function summarizeEditTextParamForHistory(value, key) -- 124
	if type(value) ~= "string" then -- 124
		return nil -- 125
	end -- 125
	local text = value -- 126
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 127
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 128
end -- 124
local function sanitizeOneReadResultForHistory(result) -- 136
	if result.success ~= true or type(result.content) ~= "string" then -- 136
		return result -- 137
	end -- 137
	local clone = {} -- 138
	for key in pairs(result) do -- 139
		clone[key] = result[key] -- 140
	end -- 140
	local startLine = type(result.startLine) == "number" and result.startLine or 1 -- 142
	local endLine = type(result.endLine) == "number" and result.endLine or startLine -- 143
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine -- 144
	local limited = limitReadContentForHistory( -- 145
		result.content, -- 146
		startLine, -- 147
		endLine, -- 148
		totalLines, -- 149
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars, -- 150
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines, -- 151
		"read_file history" -- 152
	) -- 152
	clone.content = limited.content -- 154
	if limited.truncated then -- 154
		clone.historyContentTruncated = true -- 156
		clone.historyRetainedStartLine = limited.retainedStartLine -- 157
		clone.historyRetainedEndLine = limited.retainedEndLine -- 158
		if limited.nextStartLine ~= nil then -- 158
			clone.historyNextStartLine = limited.nextStartLine -- 159
		end -- 159
		if limited.partialLine ~= nil then -- 159
			clone.historyPartialLine = limited.partialLine -- 160
		end -- 160
	end -- 160
	return clone -- 162
end -- 136
function ____exports.sanitizeReadResultForHistory(tool, result) -- 165
	if tool ~= "read_file" then -- 165
		return result -- 166
	end -- 166
	if not __TS__ArrayIsArray(result.results) then -- 166
		return sanitizeOneReadResultForHistory(result) -- 167
	end -- 167
	local clone = {} -- 168
	for key in pairs(result) do -- 169
		clone[key] = result[key] -- 169
	end -- 169
	clone.results = __TS__ArrayMap( -- 170
		result.results, -- 170
		function(____, item) return isRecord(item) and not isArray(item) and sanitizeOneReadResultForHistory(item) or item end -- 170
	) -- 170
	return clone -- 173
end -- 165
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 176
	local shown = math.min(#items, maxItems) -- 180
	local out = {} -- 181
	do -- 181
		local i = 0 -- 182
		while i < shown do -- 182
			local row = items[i + 1] -- 183
			out[#out + 1] = { -- 184
				file = row.file, -- 185
				line = row.line, -- 186
				content = type(row.content) == "string" and ____exports.truncateText(row.content, 240) or row.content -- 187
			} -- 187
			i = i + 1 -- 182
		end -- 182
	end -- 182
	return out -- 192
end -- 176
function ____exports.sanitizeSearchResultForHistory(tool, result) -- 195
	if result.success ~= true or not isArray(result.results) then -- 195
		return result -- 199
	end -- 199
	if tool ~= "grep_files" and tool ~= "search_dora_doc" then -- 199
		return result -- 200
	end -- 200
	local clone = {} -- 201
	for key in pairs(result) do -- 202
		clone[key] = result[key] -- 203
	end -- 203
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 205
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 206
	if tool == "grep_files" and isArray(result.groupedResults) then -- 206
		local grouped = result.groupedResults -- 211
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 212
		local sanitizedGroups = {} -- 213
		do -- 213
			local i = 0 -- 214
			while i < shown do -- 214
				local row = grouped[i + 1] -- 215
				sanitizedGroups[#sanitizedGroups + 1] = { -- 216
					file = row.file, -- 217
					totalMatches = row.totalMatches, -- 218
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 219
				} -- 219
				i = i + 1 -- 214
			end -- 214
		end -- 214
		clone.groupedResults = sanitizedGroups -- 224
	end -- 224
	return clone -- 226
end -- 195
function ____exports.sanitizeListFilesResultForHistory(result) -- 229
	if result.success ~= true or not isArray(result.files) then -- 229
		return result -- 230
	end -- 230
	local clone = {} -- 231
	for key in pairs(result) do -- 232
		clone[key] = result[key] -- 233
	end -- 233
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 235
	return clone -- 236
end -- 229
function ____exports.sanitizeBuildResultForHistory(result) -- 239
	if not isArray(result.messages) then -- 239
		return result -- 240
	end -- 240
	local clone = {} -- 241
	for key in pairs(result) do -- 242
		clone[key] = result[key] -- 243
	end -- 243
	local messages = result.messages -- 245
	local ordered = __TS__ArraySort( -- 246
		__TS__ArraySlice(messages), -- 246
		function(____, a, b) -- 246
			local aFailed = a.success ~= true -- 247
			local bFailed = b.success ~= true -- 248
			if aFailed == bFailed then -- 248
				return 0 -- 249
			end -- 249
			return aFailed and -1 or 1 -- 250
		end -- 246
	) -- 246
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 252
	local sanitized = {} -- 253
	do -- 253
		local i = 0 -- 254
		while i < shown do -- 254
			local item = ordered[i + 1] -- 255
			local next = {} -- 256
			for key in pairs(item) do -- 257
				local value = item[key] -- 258
				next[key] = key == "message" and type(value) == "string" and ____exports.truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 259
			end -- 259
			sanitized[#sanitized + 1] = next -- 263
			i = i + 1 -- 254
		end -- 254
	end -- 254
	clone.messages = sanitized -- 265
	if #ordered > shown then -- 265
		clone.truncatedMessages = #ordered - shown -- 267
	end -- 267
	return clone -- 269
end -- 239
function ____exports.sanitizeActionParamsForHistory(tool, params) -- 272
	if tool ~= "edit_file" then -- 272
		return params -- 273
	end -- 273
	local clone = {} -- 274
	for key in pairs(params) do -- 275
		if key == "old_str" then -- 275
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 277
		elseif key == "new_str" then -- 277
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 279
		elseif key == "edits" and isArray(params[key]) then -- 279
			clone.edits = __TS__ArrayMap( -- 281
				params[key], -- 281
				function(____, item) -- 281
					if not isRecord(item) or isArray(item) then -- 281
						return {invalid = true} -- 282
					end -- 282
					return { -- 283
						path = item.path, -- 284
						old_str_stats = summarizeEditTextParamForHistory(item.old_str, "old_str"), -- 285
						new_str_stats = summarizeEditTextParamForHistory(item.new_str, "new_str") -- 286
					} -- 286
				end -- 281
			) -- 281
		else -- 281
			clone[key] = params[key] -- 290
		end -- 290
	end -- 290
	return clone -- 293
end -- 272
local function projectEditResultForLLM(result) -- 296
	if result.success ~= true then -- 296
		local failed = {} -- 298
		for key in pairs(result) do -- 299
			local value = result[key] -- 300
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value -- 301
		end -- 301
		return failed -- 305
	end -- 305
	local projected = {} -- 307
	local scalarKeys = { -- 308
		"success", -- 309
		"changed", -- 309
		"mode", -- 309
		"checkpointId", -- 309
		"checkpointSeq", -- 309
		"checkpointed", -- 310
		"reversible", -- 310
		"binary", -- 310
		"actualSaved", -- 311
		"actualSavedCharacters", -- 311
		"currentFileExists", -- 311
		"currentCharacters", -- 311
		"currentState" -- 311
	} -- 311
	do -- 311
		local i = 0 -- 313
		while i < #scalarKeys do -- 313
			local key = scalarKeys[i + 1] -- 314
			if result[key] ~= nil then -- 314
				projected[key] = result[key] -- 315
			end -- 315
			i = i + 1 -- 313
		end -- 313
	end -- 313
	if isArray(result.files) then -- 313
		projected.files = result.files -- 317
	end -- 317
	if type(result.message) == "string" then -- 317
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 319
	end -- 319
	if type(result.guidance) == "string" then -- 319
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 326
	end -- 326
	if isArray(result.fileContext) then -- 326
		local summaries = {} -- 333
		do -- 333
			local i = 0 -- 334
			while i < #result.fileContext do -- 334
				do -- 334
					local item = result.fileContext[i + 1] -- 335
					if not isRecord(item) or isArray(item) then -- 335
						goto __continue87 -- 336
					end -- 336
					local summary = {} -- 337
					local keys = { -- 338
						"path", -- 339
						"op", -- 339
						"beforeExists", -- 339
						"afterExists", -- 339
						"beforeBytes", -- 339
						"afterBytes", -- 339
						"lineCount", -- 340
						"contentTruncated", -- 340
						"fileListTruncated" -- 340
					} -- 340
					do -- 340
						local j = 0 -- 342
						while j < #keys do -- 342
							local key = keys[j + 1] -- 343
							if item[key] ~= nil then -- 343
								summary[key] = item[key] -- 344
							end -- 344
							j = j + 1 -- 342
						end -- 342
					end -- 342
					summaries[#summaries + 1] = summary -- 346
				end -- 346
				::__continue87:: -- 346
				i = i + 1 -- 334
			end -- 334
		end -- 334
		if #summaries > 0 then -- 334
			projected.fileSummary = summaries -- 348
		end -- 348
	end -- 348
	if type(result.truncatedFileContextItems) == "number" then -- 348
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 351
	end -- 351
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 353
	return projected -- 354
end -- 296
local function projectOneBuildResultForLLM(result) -- 357
	if not isArray(result.messages) then -- 357
		return result -- 358
	end -- 358
	local projected = {} -- 359
	for key in pairs(result) do -- 360
		if key ~= "messages" then -- 360
			projected[key] = result[key] -- 361
		end -- 361
	end -- 361
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 363
	local shown = math.min(#result.messages, maxMessages) -- 364
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 365
	if #result.messages > shown then -- 365
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 367
	end -- 367
	return projected -- 369
end -- 357
local function projectBuildResultForLLM(result) -- 372
	if type(result.code) == "string" or result.failureKind == "tool" then -- 372
		return ____exports.projectBuildResultForModel(result) -- 376
	end -- 376
	if not isArray(result.results) then -- 376
		return projectOneBuildResultForLLM(result) -- 378
	end -- 378
	local projected = {} -- 379
	for key in pairs(result) do -- 380
		if key ~= "results" then -- 380
			projected[key] = result[key] -- 381
		end -- 381
	end -- 381
	projected.results = __TS__ArrayMap( -- 383
		result.results, -- 383
		function(____, item) return isRecord(item) and not isArray(item) and projectOneBuildResultForLLM(item) or item end -- 383
	) -- 383
	return projected -- 386
end -- 372
local function projectCommandResultForLLM(result) -- 389
	local projected = {} -- 390
	for key in pairs(result) do -- 391
		local value = result[key] -- 392
		if key == "output" and type(value) == "string" then -- 392
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 394
		elseif key == "message" and type(value) == "string" then -- 394
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 400
		else -- 400
			projected[key] = value -- 406
		end -- 406
	end -- 406
	return projected -- 409
end -- 389
local function sanitizeVisionActionParamsForCompression(params) -- 412
	local projected = {} -- 413
	if type(params.question) == "string" then -- 413
		projected.question = params.question -- 414
	end -- 414
	if type(params.criteria) == "string" then -- 414
		projected.criteria = params.criteria -- 415
	end -- 415
	if isArray(params.paths) then -- 415
		projected.imageCount = #params.paths -- 416
	end -- 416
	return projected -- 417
end -- 412
local function projectVisionResultForCompression(content) -- 420
	local decoded = AgentUtils.safeJsonDecode(content) -- 421
	if not isRecord(decoded) or isArray(decoded) then -- 421
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.compressionVisionReportMaxChars, "vision result") -- 423
	end -- 423
	local projected = {} -- 429
	if decoded.success ~= nil then -- 429
		projected.success = decoded.success -- 430
	end -- 430
	if type(decoded.report) == "string" then -- 430
		projected.report = truncateHistoryText(decoded.report, AgentConfig.AGENT_LIMITS.compressionVisionReportMaxChars, "vision report") -- 432
	end -- 432
	if type(decoded.message) == "string" then -- 432
		projected.message = truncateHistoryText(decoded.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "vision message") -- 439
	end -- 439
	if decoded.cancelled ~= nil then -- 439
		projected.cancelled = decoded.cancelled -- 445
	end -- 445
	return ____exports.toJson(projected, false) -- 446
end -- 420
local function projectToolResultContentForLLM(tool, content) -- 449
	local decoded = AgentUtils.safeJsonDecode(content) -- 450
	if not isRecord(decoded) or isArray(decoded) then -- 450
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 452
	end -- 452
	local projected = decoded -- 458
	if tool == "edit_file" or tool == "delete_file" then -- 458
		projected = projectEditResultForLLM(decoded) -- 460
	elseif tool == "build" then -- 460
		projected = projectBuildResultForLLM(decoded) -- 462
	elseif tool == "execute_command" then -- 462
		projected = projectCommandResultForLLM(decoded) -- 464
	end -- 464
	local encoded = ____exports.toJson(projected, false) -- 466
	if tool == "read_file" then -- 466
		return encoded -- 469
	end -- 469
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 469
		return encoded -- 470
	end -- 470
	local fallback = { -- 471
		success = projected.success, -- 472
		llmHistoryTruncated = true, -- 473
		originalChars = #encoded, -- 474
		preview = truncateHistoryText( -- 475
			encoded, -- 476
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 477
			tool .. " result" -- 478
		) -- 478
	} -- 478
	return ____exports.toJson(fallback, false) -- 481
end -- 449
function ____exports.projectMessagesForLLMContext(messages) -- 483
	local projected = {} -- 487
	do -- 487
		local i = 0 -- 488
		while i < #messages do -- 488
			local message = messages[i + 1] -- 489
			local next = __TS__ObjectAssign({}, message) -- 490
			if message.role == "assistant" and (not message.tool_calls or #message.tool_calls == 0) then -- 490
				next.reasoning_content = nil -- 491
			end -- 491
			if message.role == "tool" and type(message.content) == "string" then -- 491
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 493
			end -- 493
			projected[#projected + 1] = next -- 495
			i = i + 1 -- 488
		end -- 488
	end -- 488
	return projected -- 497
end -- 483
function ____exports.projectMessagesForCompression(messages) -- 500
	local projected = ____exports.projectMessagesForLLMContext(messages) -- 501
	local visionCallIds = {} -- 502
	do -- 502
		local i = 0 -- 503
		while i < #projected do -- 503
			do -- 503
				local message = projected[i + 1] -- 504
				if message.role == "tool" and type(message.content) == "string" and (message.name == "analyze_image" or type(message.tool_call_id) == "string" and visionCallIds[message.tool_call_id] == true) then -- 504
					local ____opt_0 = messages[i + 1] -- 504
					local rawOriginalContent = ____opt_0 and ____opt_0.content -- 511
					local originalContent = type(rawOriginalContent) == "string" and rawOriginalContent or message.content -- 512
					projected[i + 1] = __TS__ObjectAssign( -- 513
						{}, -- 513
						message, -- 513
						{content = projectVisionResultForCompression(originalContent)} -- 513
					) -- 513
					goto __continue137 -- 514
				end -- 514
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 514
					goto __continue137 -- 516
				end -- 516
				local changed = false -- 517
				local toolCalls = __TS__ArrayMap( -- 518
					message.tool_calls, -- 518
					function(____, toolCall) -- 518
						local fn = toolCall["function"] -- 519
						if (fn and fn.name) == "analyze_image" and type(toolCall.id) == "string" and toolCall.id ~= "" then -- 519
							visionCallIds[toolCall.id] = true -- 521
						end -- 521
						if (fn and fn.name) ~= "edit_file" and (fn and fn.name) ~= "analyze_image" or type(fn.arguments) ~= "string" then -- 521
							return toolCall -- 523
						end -- 523
						local decoded = AgentUtils.safeJsonDecode(fn.arguments) -- 524
						if not isRecord(decoded) or isArray(decoded) then -- 524
							return toolCall -- 525
						end -- 525
						changed = true -- 526
						return __TS__ObjectAssign( -- 527
							{}, -- 527
							toolCall, -- 528
							{["function"] = __TS__ObjectAssign( -- 527
								{}, -- 529
								fn, -- 530
								{arguments = ____exports.toJson( -- 529
									fn.name == "analyze_image" and sanitizeVisionActionParamsForCompression(decoded) or ____exports.sanitizeActionParamsForHistory("edit_file", decoded), -- 531
									false -- 533
								)} -- 533
							)} -- 533
						) -- 533
					end -- 518
				) -- 518
				if changed then -- 518
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 537
				end -- 537
			end -- 537
			::__continue137:: -- 537
			i = i + 1 -- 503
		end -- 503
	end -- 503
	return projected -- 539
end -- 500
function ____exports.sanitizeMessagesForLLMInput(messages) -- 542
	local sanitized = {} -- 543
	local droppedAssistantToolCalls = 0 -- 544
	local droppedToolResults = 0 -- 545
	do -- 545
		local i = 0 -- 546
		while i < #messages do -- 546
			do -- 546
				local message = messages[i + 1] -- 547
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 547
					local requiredIds = {} -- 549
					do -- 549
						local j = 0 -- 550
						while j < #message.tool_calls do -- 550
							local toolCall = message.tool_calls[j + 1] -- 551
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 552
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 552
								requiredIds[#requiredIds + 1] = id -- 554
							end -- 554
							j = j + 1 -- 550
						end -- 550
					end -- 550
					if #requiredIds == 0 then -- 550
						sanitized[#sanitized + 1] = message -- 558
						goto __continue147 -- 559
					end -- 559
					local matchedIds = {} -- 561
					local matchedTools = {} -- 562
					local j = i + 1 -- 563
					while j < #messages do -- 563
						local toolMessage = messages[j + 1] -- 565
						if toolMessage.role ~= "tool" then -- 565
							break -- 566
						end -- 566
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 567
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 567
							matchedIds[toolCallId] = true -- 569
							matchedTools[#matchedTools + 1] = toolMessage -- 570
						else -- 570
							droppedToolResults = droppedToolResults + 1 -- 572
						end -- 572
						j = j + 1 -- 574
					end -- 574
					local complete = true -- 576
					do -- 576
						local j = 0 -- 577
						while j < #requiredIds do -- 577
							if matchedIds[requiredIds[j + 1]] ~= true then -- 577
								complete = false -- 579
								break -- 580
							end -- 580
							j = j + 1 -- 577
						end -- 577
					end -- 577
					if complete then -- 577
						__TS__ArrayPush( -- 584
							sanitized, -- 584
							message, -- 584
							table.unpack(matchedTools) -- 584
						) -- 584
					else -- 584
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 586
						droppedToolResults = droppedToolResults + #matchedTools -- 587
					end -- 587
					i = j - 1 -- 589
					goto __continue147 -- 590
				end -- 590
				if message.role == "tool" then -- 590
					droppedToolResults = droppedToolResults + 1 -- 593
					goto __continue147 -- 594
				end -- 594
				sanitized[#sanitized + 1] = message -- 596
			end -- 596
			::__continue147:: -- 596
			i = i + 1 -- 546
		end -- 546
	end -- 546
	return sanitized -- 598
end -- 542
return ____exports -- 542