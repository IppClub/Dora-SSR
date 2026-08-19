-- [ts]: Utils.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local ____exports = {} -- 1
local normalizeReasoningEffort -- 1
local ____Dora = require("Dora") -- 2
local json = ____Dora.json -- 2
local HttpClient = ____Dora.HttpClient -- 2
local DB = ____Dora.DB -- 2
local emit = ____Dora.emit -- 2
local DoraLog = ____Dora.Log -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local App = ____Dora.App -- 2
local AgentConfig = require("Agent.AgentConfig") -- 3
function ____exports.sanitizeUTF8(text) -- 343
	if not text then -- 343
		return "" -- 344
	end -- 344
	local remaining = text -- 345
	local output = "" -- 346
	while remaining ~= "" do -- 346
		local len, invalidPos = utf8.len(remaining) -- 348
		if len ~= nil then -- 348
			output = output .. remaining -- 350
			break -- 351
		end -- 351
		local badPos = type(invalidPos) == "number" and invalidPos or 1 -- 353
		if badPos > 1 then -- 353
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1) -- 355
		end -- 355
		remaining = __TS__StringSubstring(remaining, badPos) -- 357
	end -- 357
	return output -- 359
end -- 343
function normalizeReasoningEffort(value) -- 1193
	if type(value) ~= "string" then -- 1193
		return nil -- 1194
	end -- 1194
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1195
	return normalized ~= "" and normalized or nil -- 1196
end -- 1196
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1207
	if not customOptions then -- 1207
		return options -- 1211
	end -- 1211
	local merged = __TS__ObjectAssign({}, options) -- 1212
	for key in pairs(customOptions) do -- 1213
		do -- 1213
			if key == "auxiliaryOptions" then -- 1213
				goto __continue265 -- 1216
			end -- 1216
			local value = customOptions[key] -- 1217
			if value == json.null then -- 1217
				__TS__Delete(merged, key) -- 1219
			else -- 1219
				merged[key] = value -- 1221
			end -- 1221
		end -- 1221
		::__continue265:: -- 1221
	end -- 1221
	return merged -- 1224
end -- 1207
local LOG_LEVEL = App.debugging and 3 or 2 -- 5
function ____exports.setLogLevel(level) -- 6
	LOG_LEVEL = level -- 7
end -- 6
local LLM_TIMEOUT = 600 -- 10
local LLM_STREAM_TIMEOUT = 600 -- 11
local LLM_STREAM_RAW_DEBUG_MAX = 12000 -- 12
local LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT = 5 -- 13
____exports.Log = function(____type, msg) -- 15
	if LOG_LEVEL < 1 then -- 15
		return -- 16
	elseif LOG_LEVEL < 2 and (____type == "Info" or ____type == "Warn") then -- 16
		return -- 17
	elseif LOG_LEVEL < 3 and ____type == "Info" then -- 17
		return -- 18
	end -- 18
	DoraLog(____type, msg) -- 19
end -- 15
local TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz" -- 46
local TOOL_CALL_ID_COUNTER = 0 -- 47
local function toBase36(value) -- 49
	if value <= 0 then -- 49
		return "0" -- 50
	end -- 50
	local remaining = math.floor(value) -- 51
	local out = "" -- 52
	while remaining > 0 do -- 52
		local digit = remaining % 36 -- 54
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out -- 55
		remaining = math.floor(remaining / 36) -- 56
	end -- 56
	return out -- 58
end -- 49
function ____exports.createLocalToolCallId() -- 61
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1 -- 62
	local timePart = toBase36(os.time()) -- 63
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER) -- 64
	return ("tc" .. timePart) .. counterPart -- 65
end -- 61
local function normalizeCompletionText(value) -- 99
	if type(value) ~= "string" then -- 99
		return "" -- 100
	end -- 100
	return __TS__StringSlice( -- 101
		__TS__StringTrim(____exports.sanitizeUTF8(value)), -- 101
		0, -- 101
		AgentConfig.AGENT_LIMITS.completionTextMaxChars -- 101
	) -- 101
end -- 99
local function normalizeCompletionTextList(value, maxItems) -- 104
	if maxItems == nil then -- 104
		maxItems = AgentConfig.AGENT_LIMITS.completionListMaxItems -- 106
	end -- 106
	if not __TS__ArrayIsArray(value) then -- 106
		return {} -- 108
	end -- 108
	local items = {} -- 109
	do -- 109
		local i = 0 -- 110
		while i < #value and #items < maxItems do -- 110
			local item = normalizeCompletionText(value[i + 1]) -- 111
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 111
				items[#items + 1] = item -- 112
			end -- 112
			i = i + 1 -- 110
		end -- 110
	end -- 110
	return items -- 114
end -- 104
function ____exports.normalizeAgentCompletionReport(value) -- 117
	local row = value and not __TS__ArrayIsArray(value) and type(value) == "table" and value or ({}) -- 118
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 121
	local validation = {} -- 124
	if __TS__ArrayIsArray(row.validation) then -- 124
		do -- 124
			local i = 0 -- 126
			while i < #row.validation and #validation < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 126
				do -- 126
					local raw = row.validation[i + 1] -- 127
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 127
						goto __continue21 -- 128
					end -- 128
					local item = raw -- 129
					local kind = (item.kind == "runtime" or item.kind == "manual") and item.kind or (item.kind == "build" and "build" or nil) -- 130
					local result = (item.result == "passed" or item.result == "failed" or item.result == "not_run") and item.result or nil -- 131
					if kind == nil or result == nil then -- 131
						goto __continue21 -- 132
					end -- 132
					validation[#validation + 1] = { -- 133
						kind = kind, -- 134
						result = result, -- 135
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems) -- 136
					} -- 136
				end -- 136
				::__continue21:: -- 136
				i = i + 1 -- 126
			end -- 126
		end -- 126
	end -- 126
	local learningCandidates = {} -- 140
	if __TS__ArrayIsArray(row.learningCandidates) then -- 140
		do -- 140
			local i = 0 -- 142
			while i < #row.learningCandidates and #learningCandidates < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 142
				do -- 142
					local raw = row.learningCandidates[i + 1] -- 143
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 143
						goto __continue26 -- 144
					end -- 144
					local item = raw -- 145
					local claim = normalizeCompletionText(item.claim) -- 146
					if claim == "" then -- 146
						goto __continue26 -- 147
					end -- 147
					learningCandidates[#learningCandidates + 1] = { -- 148
						claim = claim, -- 149
						scope = (item.scope == "file" or item.scope == "engine") and item.scope or "project", -- 150
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems), -- 151
						confidence = item.confidence == "inferred" and "inferred" or "observed" -- 152
					} -- 152
				end -- 152
				::__continue26:: -- 152
				i = i + 1 -- 142
			end -- 142
		end -- 142
	end -- 142
	return { -- 156
		outcome = outcome, -- 157
		budgetExhausted = row.budgetExhausted == true, -- 158
		validation = validation, -- 159
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 160
		assumptions = normalizeCompletionTextList(row.assumptions), -- 161
		learningCandidates = learningCandidates -- 162
	} -- 162
end -- 117
function ____exports.replaceFirst(text, oldStr, newStr) -- 170
	if oldStr == "" then -- 170
		return text -- 171
	end -- 171
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 172
	if idx < 0 then -- 172
		return text -- 173
	end -- 173
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 174
end -- 170
local function getLeadingWhitespace(text) -- 177
	local i = 0 -- 178
	while i < #text do -- 178
		local ch = __TS__StringAccess(text, i) -- 180
		if ch ~= " " and ch ~= "\t" then -- 180
			break -- 181
		end -- 181
		i = i + 1 -- 182
	end -- 182
	return __TS__StringSubstring(text, 0, i) -- 184
end -- 177
local function getCommonIndentPrefix(lines) -- 187
	local common -- 188
	do -- 188
		local i = 0 -- 189
		while i < #lines do -- 189
			do -- 189
				local line = lines[i + 1] -- 190
				if __TS__StringTrim(line) == "" then -- 190
					goto __continue37 -- 191
				end -- 191
				local indent = getLeadingWhitespace(line) -- 192
				if common == nil then -- 192
					common = indent -- 194
					goto __continue37 -- 195
				end -- 195
				local j = 0 -- 197
				local maxLen = math.min(#common, #indent) -- 198
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 198
					j = j + 1 -- 200
				end -- 200
				common = __TS__StringSubstring(common, 0, j) -- 202
				if common == "" then -- 202
					break -- 203
				end -- 203
			end -- 203
			::__continue37:: -- 203
			i = i + 1 -- 189
		end -- 189
	end -- 189
	return common or "" -- 205
end -- 187
local function removeIndentPrefix(line, indent) -- 208
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 208
		return __TS__StringSubstring(line, #indent) -- 210
	end -- 210
	local lineIndent = getLeadingWhitespace(line) -- 212
	local j = 0 -- 213
	local maxLen = math.min(#lineIndent, #indent) -- 214
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 214
		j = j + 1 -- 216
	end -- 216
	return __TS__StringSubstring(line, j) -- 218
end -- 208
local function dedentLines(lines) -- 221
	local indent = getCommonIndentPrefix(lines) -- 222
	return { -- 223
		indent = indent, -- 224
		lines = __TS__ArrayMap( -- 225
			lines, -- 225
			function(____, line) return removeIndentPrefix(line, indent) end -- 225
		) -- 225
	} -- 225
end -- 221
local function findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 229
	local function foldWhitespace(text, withMap) -- 235
		local parts = {} -- 236
		local map = {} -- 237
		local i = 0 -- 238
		while i < #text do -- 238
			local ch = __TS__StringAccess(text, i) -- 240
			if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 240
				local start = i -- 242
				while i < #text do -- 242
					local next = __TS__StringAccess(text, i) -- 244
					if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 244
						break -- 245
					end -- 245
					i = i + 1 -- 246
				end -- 246
				parts[#parts + 1] = " " -- 248
				if withMap then -- 248
					map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 249
				end -- 249
			else -- 249
				parts[#parts + 1] = ch -- 251
				if withMap then -- 251
					map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 252
				end -- 252
				i = i + 1 -- 253
			end -- 253
		end -- 253
		return { -- 256
			text = table.concat(parts, ""), -- 256
			map = map -- 256
		} -- 256
	end -- 235
	local foldedContent = foldWhitespace(content, true) -- 258
	local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 259
	if foldedOld == "" then -- 259
		return {success = false, message = "old_str not found in file"} -- 261
	end -- 261
	local matches = {} -- 263
	local pos = 0 -- 264
	while true do -- 264
		local idx = (string.find( -- 266
			foldedContent.text, -- 266
			foldedOld, -- 266
			math.max(pos + 1, 1), -- 266
			true -- 266
		) or 0) - 1 -- 266
		if idx < 0 then -- 266
			break -- 267
		end -- 267
		local lastIdx = idx + #foldedOld - 1 -- 268
		local startMap = foldedContent.map[idx + 1] -- 269
		local endMap = foldedContent.map[lastIdx + 1] -- 270
		if startMap ~= nil and endMap ~= nil then -- 270
			matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 272
		end -- 272
		pos = idx + #foldedOld -- 274
	end -- 274
	if #matches == 0 then -- 274
		return {success = false, message = "old_str not found in file"} -- 277
	end -- 277
	if #matches > 1 then -- 277
		return { -- 280
			success = false, -- 281
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 282
		} -- 282
	end -- 282
	local match = matches[1] -- 285
	return { -- 286
		success = true, -- 287
		content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 288
	} -- 288
end -- 229
function ____exports.findIndentTolerantReplacement(content, oldStr, newStr) -- 292
	local contentLines = __TS__StringSplit(content, "\n") -- 297
	local oldLines = __TS__StringSplit(oldStr, "\n") -- 298
	if #oldLines == 0 then -- 298
		return {success = false, message = "old_str not found in file"} -- 300
	end -- 300
	local dedentedOld = dedentLines(oldLines) -- 302
	local dedentedOldText = table.concat(dedentedOld.lines, "\n") -- 303
	local dedentedNew = dedentLines(__TS__StringSplit(newStr, "\n")) -- 304
	local matches = {} -- 305
	do -- 305
		local start = 0 -- 306
		while start <= #contentLines - #oldLines do -- 306
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 307
			local dedentedCandidate = dedentLines(candidateLines) -- 308
			if table.concat(dedentedCandidate.lines, "\n") == dedentedOldText then -- 308
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 310
			end -- 310
			start = start + 1 -- 306
		end -- 306
	end -- 306
	if #matches == 0 then -- 306
		return findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 318
	end -- 318
	if #matches > 1 then -- 318
		return { -- 321
			success = false, -- 322
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 323
		} -- 323
	end -- 323
	local match = matches[1] -- 326
	local rebuiltNewLines = __TS__ArrayMap( -- 327
		dedentedNew.lines, -- 327
		function(____, line) return line == "" and "" or match.indent .. line end -- 327
	) -- 327
	local ____array_0 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 327
	__TS__SparseArrayPush( -- 327
		____array_0, -- 327
		table.unpack(rebuiltNewLines) -- 330
	) -- 330
	__TS__SparseArrayPush( -- 330
		____array_0, -- 330
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 331
	) -- 331
	local nextLines = {__TS__SparseArraySpread(____array_0)} -- 328
	return { -- 333
		success = true, -- 333
		content = table.concat(nextLines, "\n") -- 333
	} -- 333
end -- 292
local function previewText(text, maxLen) -- 336
	if maxLen == nil then -- 336
		maxLen = 200 -- 336
	end -- 336
	if not text then -- 336
		return "" -- 337
	end -- 337
	local compact = __TS__StringReplace( -- 338
		__TS__StringReplace(text, "\r", "\\r"), -- 338
		"\n", -- 338
		"\\n" -- 338
	) -- 338
	if #compact <= maxLen then -- 338
		return compact -- 339
	end -- 339
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 340
end -- 336
local function sanitizeJSONValue(value) -- 362
	if type(value) == "string" then -- 362
		return ____exports.sanitizeUTF8(value) -- 363
	end -- 363
	if __TS__ArrayIsArray(value) then -- 363
		return __TS__ArrayMap( -- 365
			value, -- 365
			function(____, item) return sanitizeJSONValue(item) end -- 365
		) -- 365
	end -- 365
	if value and type(value) == "table" then -- 365
		local result = {} -- 368
		for key in pairs(value) do -- 369
			result[key] = sanitizeJSONValue(value[key]) -- 370
		end -- 370
		return result -- 372
	end -- 372
	return value -- 374
end -- 362
function ____exports.safeJsonEncode(value, format, emptyAsArray, numAsStr, maxDepth) -- 377
	if format == nil then -- 377
		format = false -- 377
	end -- 377
	if emptyAsArray == nil then -- 377
		emptyAsArray = true -- 377
	end -- 377
	if numAsStr == nil then -- 377
		numAsStr = false -- 377
	end -- 377
	if maxDepth == nil then -- 377
		maxDepth = 128 -- 377
	end -- 377
	return json.encode( -- 378
		sanitizeJSONValue(value), -- 379
		format, -- 380
		emptyAsArray, -- 381
		numAsStr, -- 382
		maxDepth -- 383
	) -- 383
end -- 377
function ____exports.safeJsonDecode(text) -- 387
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 388
	if value == nil then -- 388
		return value, err -- 390
	end -- 390
	return sanitizeJSONValue(value), err -- 392
end -- 387
local function isPlainRecord(value) -- 395
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 396
end -- 395
local function normalizeLLMJSONResponse(text) -- 399
	return __TS__StringTrim(text) -- 400
end -- 399
local function utf8TakeHead(text, maxChars) -- 403
	if maxChars <= 0 or text == "" then -- 403
		return "" -- 404
	end -- 404
	local nextPos = utf8.offset(text, maxChars + 1) -- 405
	if nextPos == nil then -- 405
		return text -- 406
	end -- 406
	return string.sub(text, 1, nextPos - 1) -- 407
end -- 403
local function utf8TakeTail(text, maxChars) -- 410
	if maxChars <= 0 or text == "" then -- 410
		return "" -- 411
	end -- 411
	local charLen = utf8.len(text) -- 412
	if charLen == nil or charLen <= maxChars then -- 412
		return text -- 413
	end -- 413
	local startChar = math.max(1, charLen - maxChars + 1) -- 414
	local startPos = utf8.offset(text, startChar) -- 415
	if startPos == nil then -- 415
		return text -- 416
	end -- 416
	return string.sub(text, startPos) -- 417
end -- 410
function ____exports.estimateTextTokens(text) -- 420
	if not text then -- 420
		return 0 -- 421
	end -- 421
	return App:estimateTokens(text) -- 422
end -- 420
local function estimateMessagesTokens(messages) -- 425
	local total = 0 -- 426
	do -- 426
		local i = 0 -- 427
		while i < #messages do -- 427
			local message = messages[i + 1] -- 428
			total = total + 8 -- 429
			total = total + ____exports.estimateTextTokens(message.role or "") -- 430
			total = total + ____exports.estimateTextTokens(message.content or "") -- 431
			total = total + ____exports.estimateTextTokens(message.name or "") -- 432
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 433
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 434
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({})) -- 435
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 436
			i = i + 1 -- 427
		end -- 427
	end -- 427
	return total -- 438
end -- 425
local function estimateOptionsTokens(options) -- 441
	local text = ____exports.safeJsonEncode(options) -- 442
	return text and ____exports.estimateTextTokens(text) or 0 -- 443
end -- 441
local function getReservedOutputTokens(options, contextWindow) -- 446
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 447
	if explicitMax > 0 then -- 447
		return math.max(256, explicitMax) -- 452
	end -- 452
	return math.max( -- 453
		1024, -- 453
		math.floor(contextWindow * 0.2) -- 453
	) -- 453
end -- 446
local function getInputTokenBudget(messages, options, config) -- 456
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 457
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 460
	local optionTokens = estimateOptionsTokens(options) -- 461
	local structuralOverhead = math.max(256, #messages * 16) -- 462
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 463
end -- 456
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 466
	if budgetTokens <= 0 or text == "" then -- 466
		return "" -- 467
	end -- 467
	local estimated = ____exports.estimateTextTokens(text) -- 468
	if estimated <= budgetTokens then -- 468
		return text -- 469
	end -- 469
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 470
	local targetChars = math.max( -- 471
		200, -- 471
		math.floor(budgetTokens * charsPerToken) -- 471
	) -- 471
	local keepHead = math.max( -- 472
		0, -- 472
		math.floor(targetChars * 0.35) -- 472
	) -- 472
	local keepTail = math.max(0, targetChars - keepHead) -- 473
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 474
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 475
	return (head .. "\n...\n") .. tail -- 476
end -- 466
local function isXMLWhitespaceChar(ch) -- 479
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 480
end -- 479
local function findLineStart(value, from) -- 483
	local i = from -- 484
	while i >= 0 do -- 484
		if __TS__StringAccess(value, i) == "\n" then -- 484
			return i + 1 -- 486
		end -- 486
		i = i - 1 -- 487
	end -- 487
	return 0 -- 489
end -- 483
local function findLastLiteral(text, needle) -- 492
	if needle == "" then -- 492
		return #text -- 493
	end -- 493
	local last = -1 -- 494
	local from = 0 -- 495
	while from <= #text - #needle do -- 495
		local pos = (string.find( -- 497
			text, -- 497
			needle, -- 497
			math.max(from + 1, 1), -- 497
			true -- 497
		) or 0) - 1 -- 497
		if pos < 0 then -- 497
			break -- 498
		end -- 498
		last = pos -- 499
		from = pos + 1 -- 500
	end -- 500
	return last -- 502
end -- 492
local function unwrapXMLRawText(text) -- 505
	local trimmed = __TS__StringTrim(text) -- 506
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 506
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 508
	end -- 508
	return text -- 510
end -- 505
local function readSimpleXMLTagName(source, openStart, openEnd) -- 513
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 514
	if rawTag == "" then -- 514
		return { -- 516
			success = false, -- 516
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 516
		} -- 516
	end -- 516
	local selfClosing = false -- 518
	local tagText = rawTag -- 519
	if __TS__StringEndsWith(tagText, "/") then -- 519
		selfClosing = true -- 521
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 522
	end -- 522
	local tagName = "" -- 524
	do -- 524
		local i = 0 -- 525
		while i < #tagText do -- 525
			local ch = __TS__StringAccess(tagText, i) -- 526
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 526
				break -- 527
			end -- 527
			tagName = tagName .. ch -- 528
			i = i + 1 -- 525
		end -- 525
	end -- 525
	if tagName == "" then -- 525
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 531
	end -- 531
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 533
end -- 513
local function findMatchingXMLClose(source, tagName, contentStart) -- 536
	local sameOpenPrefix = "<" .. tagName -- 537
	local sameCloseToken = ("</" .. tagName) .. ">" -- 538
	local pos = contentStart -- 539
	local depth = 1 -- 540
	while pos < #source do -- 540
		do -- 540
			local lt = (string.find( -- 542
				source, -- 542
				"<", -- 542
				math.max(pos + 1, 1), -- 542
				true -- 542
			) or 0) - 1 -- 542
			if lt < 0 then -- 542
				break -- 543
			end -- 543
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 543
				local cdataEnd = (string.find( -- 545
					source, -- 545
					"]]>", -- 545
					math.max(lt + 9 + 1, 1), -- 545
					true -- 545
				) or 0) - 1 -- 545
				if cdataEnd < 0 then -- 545
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 546
				end -- 546
				pos = cdataEnd + 3 -- 547
				goto __continue127 -- 548
			end -- 548
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 551
					source, -- 551
					"-->",
					math.max(lt + 4 + 1, 1), -- 551
					true -- 551
				) or 0) - 1 -- 551
				if commentEnd < 0 then -- 551
					return {success = false, message = "invalid xml: unterminated comment"} -- 552
				end -- 552
				pos = commentEnd + 3 -- 553
				goto __continue127 -- 554
			end -- 554
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 554
				depth = depth - 1 -- 557
				if depth == 0 then -- 557
					return {success = true, closeStart = lt} -- 558
				end -- 558
				pos = lt + #sameCloseToken -- 559
				goto __continue127 -- 560
			end -- 560
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 560
				local openEnd = (string.find( -- 563
					source, -- 563
					">", -- 563
					math.max(lt + 1, 1), -- 563
					true -- 563
				) or 0) - 1 -- 563
				if openEnd < 0 then -- 563
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 564
				end -- 564
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 565
				if not tagInfo.success then -- 565
					return tagInfo -- 566
				end -- 566
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 566
					depth = depth + 1 -- 568
				end -- 568
				pos = openEnd + 1 -- 570
				goto __continue127 -- 571
			end -- 571
			local genericEnd = (string.find( -- 573
				source, -- 573
				">", -- 573
				math.max(lt + 1, 1), -- 573
				true -- 573
			) or 0) - 1 -- 573
			if genericEnd < 0 then -- 573
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 574
			end -- 574
			pos = genericEnd + 1 -- 575
		end -- 575
		::__continue127:: -- 575
	end -- 575
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 577
end -- 536
function ____exports.extractXMLFromText(text) -- 580
	local source = __TS__StringTrim(text) -- 581
	local function extractFencedBlock(fence) -- 582
		if not __TS__StringStartsWith(source, fence) then -- 582
			return nil -- 583
		end -- 583
		local firstLineEnd = (string.find( -- 584
			source, -- 584
			"\n", -- 584
			math.max(1, 1), -- 584
			true -- 584
		) or 0) - 1 -- 584
		if firstLineEnd < 0 then -- 584
			return nil -- 585
		end -- 585
		local searchPos = firstLineEnd + 1 -- 586
		local closingFencePositions = {} -- 587
		while searchPos < #source do -- 587
			local ____end = (string.find( -- 589
				source, -- 589
				"```", -- 589
				math.max(searchPos + 1, 1), -- 589
				true -- 589
			) or 0) - 1 -- 589
			if ____end < 0 then -- 589
				break -- 590
			end -- 590
			local lineStart = findLineStart(source, ____end - 1) -- 591
			local lineEnd = (string.find( -- 592
				source, -- 592
				"\n", -- 592
				math.max(____end + 1, 1), -- 592
				true -- 592
			) or 0) - 1 -- 592
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 593
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 593
				closingFencePositions[#closingFencePositions + 1] = ____end -- 595
			end -- 595
			searchPos = ____end + 1 -- 597
		end -- 597
		do -- 597
			local i = #closingFencePositions - 1 -- 599
			while i >= 0 do -- 599
				do -- 599
					local closingFencePos = closingFencePositions[i + 1] -- 600
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 601
					if afterFence ~= "" then -- 601
						goto __continue148 -- 602
					end -- 602
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 603
				end -- 603
				::__continue148:: -- 603
				i = i - 1 -- 599
			end -- 599
		end -- 599
		return nil -- 605
	end -- 582
	local xmlBlock = extractFencedBlock("```xml") -- 607
	if xmlBlock ~= nil then -- 607
		return xmlBlock -- 608
	end -- 608
	local genericBlock = extractFencedBlock("```") -- 609
	if genericBlock ~= nil then -- 609
		return genericBlock -- 610
	end -- 610
	return source -- 611
end -- 580
function ____exports.parseSimpleXMLChildren(source) -- 614
	local result = {} -- 615
	local pos = 0 -- 616
	while pos < #source do -- 616
		do -- 616
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 616
				pos = pos + 1 -- 618
			end -- 618
			if pos >= #source then -- 618
				break -- 619
			end -- 619
			if __TS__StringAccess(source, pos) ~= "<" then -- 619
				return { -- 621
					success = false, -- 621
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 621
				} -- 621
			end -- 621
			if __TS__StringStartsWith(source, "</", pos) then -- 621
				return { -- 624
					success = false, -- 624
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 624
				} -- 624
			end -- 624
			local openEnd = (string.find( -- 626
				source, -- 626
				">", -- 626
				math.max(pos + 1, 1), -- 626
				true -- 626
			) or 0) - 1 -- 626
			if openEnd < 0 then -- 626
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 628
			end -- 628
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 630
			if not tagInfo.success then -- 630
				return tagInfo -- 631
			end -- 631
			if tagInfo.selfClosing then -- 631
				result[tagInfo.tagName] = "" -- 633
				pos = openEnd + 1 -- 634
				goto __continue153 -- 635
			end -- 635
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 637
			if not closeRes.success then -- 637
				return closeRes -- 638
			end -- 638
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 639
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 640
			pos = closeRes.closeStart + #closeToken -- 641
		end -- 641
		::__continue153:: -- 641
	end -- 641
	return {success = true, obj = result} -- 643
end -- 614
function ____exports.parseXMLObjectFromText(text, rootTag) -- 646
	local xmlText = ____exports.extractXMLFromText(text) -- 647
	local rootOpen = ("<" .. rootTag) .. ">" -- 648
	local rootClose = ("</" .. rootTag) .. ">" -- 649
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 650
	local ____end = findLastLiteral(xmlText, rootClose) -- 651
	if start < 0 or ____end < start then -- 651
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 653
	end -- 653
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 655
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 656
	if beforeRoot ~= "" or afterRoot ~= "" then -- 656
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 658
	end -- 658
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 660
	return ____exports.parseSimpleXMLChildren(rootContent) -- 661
end -- 646
function ____exports.fitMessagesToContext(messages, options, config) -- 664
	local modelName = string.lower(config.model) -- 671
	local shouldEchoReasoningContent = __TS__ArraySome( -- 672
		messages, -- 672
		function(____, message) return type(message.reasoning_content) == "string" end -- 672
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 672
	local cloned = __TS__ArrayMap( -- 676
		messages, -- 676
		function(____, message) -- 676
			local clonedMessage = __TS__ObjectAssign({}, message) -- 677
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 677
				clonedMessage.reasoning_content = "" -- 683
			end -- 683
			return clonedMessage -- 685
		end -- 676
	) -- 676
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 687
	local originalTokens = estimateMessagesTokens(cloned) -- 688
	if originalTokens <= budgetTokens then -- 688
		return { -- 690
			messages = cloned, -- 691
			trimmed = false, -- 692
			originalTokens = originalTokens, -- 693
			fittedTokens = originalTokens, -- 694
			budgetTokens = budgetTokens -- 695
		} -- 695
	end -- 695
	local function roleOverhead(message) -- 699
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 699
	end -- 699
	local fixedOverhead = 0 -- 700
	local contentIndexes = {} -- 701
	do -- 701
		local i = 0 -- 702
		while i < #cloned do -- 702
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 703
			contentIndexes[#contentIndexes + 1] = i -- 704
			i = i + 1 -- 702
		end -- 702
	end -- 702
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 706
	if #contentIndexes == 1 then -- 706
		local idx = contentIndexes[1] -- 708
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 709
		local fittedTokens = estimateMessagesTokens(cloned) -- 710
		return { -- 711
			messages = cloned, -- 712
			trimmed = true, -- 713
			originalTokens = originalTokens, -- 714
			fittedTokens = fittedTokens, -- 715
			budgetTokens = budgetTokens -- 716
		} -- 716
	end -- 716
	local nonSystemIndexes = {} -- 720
	local systemIndexes = {} -- 721
	do -- 721
		local i = 0 -- 722
		while i < #cloned do -- 722
			if cloned[i + 1].role == "system" then -- 722
				systemIndexes[#systemIndexes + 1] = i -- 723
			else -- 723
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 724
			end -- 724
			i = i + 1 -- 722
		end -- 722
	end -- 722
	local ____array_1 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 722
	__TS__SparseArrayPush( -- 722
		____array_1, -- 722
		table.unpack(systemIndexes) -- 726
	) -- 726
	local priorityIndexes = {__TS__SparseArraySpread(____array_1)} -- 726
	local remainingContentBudget = contentBudget -- 727
	do -- 727
		local i = #priorityIndexes - 1 -- 728
		while i >= 0 do -- 728
			local idx = priorityIndexes[i + 1] -- 729
			local message = cloned[idx + 1] -- 730
			local minBudget = message.role == "system" and 96 or 192 -- 731
			local target = math.max( -- 732
				minBudget, -- 732
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 732
			) -- 732
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 733
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 734
			remainingContentBudget = math.max(0, remainingContentBudget) -- 735
			i = i - 1 -- 728
		end -- 728
	end -- 728
	local fittedTokens = estimateMessagesTokens(cloned) -- 738
	if fittedTokens > budgetTokens then -- 738
		do -- 738
			local i = 0 -- 740
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 740
				local idx = priorityIndexes[i + 1] -- 741
				local message = cloned[idx + 1] -- 742
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 743
				local excess = fittedTokens - budgetTokens -- 744
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 745
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 746
				fittedTokens = estimateMessagesTokens(cloned) -- 747
				i = i + 1 -- 740
			end -- 740
		end -- 740
	end -- 740
	if fittedTokens > budgetTokens then -- 740
		do -- 740
			local i = 0 -- 751
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 751
				do -- 751
					local idx = priorityIndexes[i + 1] -- 752
					if cloned[idx + 1].role == "system" then -- 752
						goto __continue185 -- 753
					end -- 753
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 754
					fittedTokens = estimateMessagesTokens(cloned) -- 755
				end -- 755
				::__continue185:: -- 755
				i = i + 1 -- 751
			end -- 751
		end -- 751
	end -- 751
	return { -- 758
		messages = cloned, -- 759
		trimmed = true, -- 760
		originalTokens = originalTokens, -- 761
		fittedTokens = fittedTokens, -- 762
		budgetTokens = budgetTokens -- 763
	} -- 763
end -- 664
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken) -- 767
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 778
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 779
	local data = __TS__ObjectAssign({}, requestOptions, {model = model, messages = messages, stream = stream}) -- 780
	if stopToken == nil then -- 780
		stopToken = {stopped = false} -- 786
	end -- 786
	return __TS__New( -- 787
		__TS__Promise, -- 787
		function(____, resolve, reject) -- 787
			local requestId = 0 -- 788
			local settled = false -- 789
			local function finishResolve(text) -- 790
				if settled then -- 790
					return -- 791
				end -- 791
				settled = true -- 792
				resolve(nil, text) -- 793
			end -- 790
			local function finishReject(err) -- 795
				if settled then -- 795
					return -- 796
				end -- 796
				settled = true -- 797
				reject(nil, err) -- 798
			end -- 795
			Director.systemScheduler:schedule(function() -- 800
				if not settled then -- 800
					if stopToken.stopped then -- 800
						if requestId ~= 0 then -- 800
							HttpClient:cancel(requestId) -- 804
							requestId = 0 -- 805
						end -- 805
						finishReject("request cancelled") -- 807
						return true -- 808
					end -- 808
					return false -- 810
				end -- 810
				return true -- 812
			end) -- 800
			Director.systemScheduler:schedule(once(function() -- 814
				emit( -- 815
					"LLM_IN", -- 815
					table.concat( -- 815
						__TS__ArrayMap( -- 815
							messages, -- 815
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 815
						), -- 815
						"\n" -- 815
					) -- 815
				) -- 815
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 816
				if jsonStr ~= nil then -- 816
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", receiver and "Accept: text/event-stream" or "Accept: application/json"} -- 818
					requestId = receiver and HttpClient:post( -- 823
						url, -- 824
						headers, -- 824
						jsonStr, -- 824
						requestTimeout, -- 824
						function(data) -- 824
							if stopToken.stopped then -- 824
								return true -- 825
							end -- 825
							return receiver(data) -- 826
						end, -- 824
						function(data) -- 827
							requestId = 0 -- 828
							if data ~= nil then -- 828
								finishResolve(data) -- 830
							else -- 830
								finishReject("failed to get http response") -- 832
							end -- 832
						end -- 827
					) or HttpClient:post( -- 827
						url, -- 835
						headers, -- 835
						jsonStr, -- 835
						requestTimeout, -- 835
						function(data) -- 835
							requestId = 0 -- 836
							if stopToken.stopped then -- 836
								finishReject("request cancelled") -- 838
								return -- 839
							end -- 839
							if data ~= nil then -- 839
								finishResolve(data) -- 842
							else -- 842
								finishReject("failed to get http response") -- 844
							end -- 844
						end -- 835
					) -- 835
					if requestId == 0 then -- 835
						finishReject("failed to schedule http request") -- 848
					elseif stopToken.stopped then -- 848
						HttpClient:cancel(requestId) -- 850
						requestId = 0 -- 851
						finishReject("request cancelled") -- 852
					end -- 852
				else -- 852
					finishReject(err) -- 855
				end -- 855
			end)) -- 814
		end -- 787
	) -- 787
end -- 767
function ____exports.createSSEJSONParser(opts) -- 865
	local buffer = "" -- 870
	local eventDataLines = {} -- 871
	local function flushEventIfAny() -- 873
		if #eventDataLines == 0 then -- 873
			return -- 874
		end -- 874
		local dataPayload = table.concat(eventDataLines, "\n") -- 876
		eventDataLines = {} -- 877
		if dataPayload == "[DONE]" then -- 877
			local ____opt_2 = opts.onDone -- 877
			if ____opt_2 ~= nil then -- 877
				____opt_2(dataPayload) -- 880
			end -- 880
			return -- 881
		end -- 881
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 884
		if err == nil then -- 884
			opts.onJSON(obj, dataPayload) -- 886
		else -- 886
			local ____opt_4 = opts.onError -- 886
			if ____opt_4 ~= nil then -- 886
				____opt_4(err, {raw = dataPayload}) -- 888
			end -- 888
		end -- 888
	end -- 873
	local function append(chunk) -- 892
		buffer = buffer .. chunk -- 893
	end -- 892
	local function drain(maxLines) -- 896
		local processedLines = 0 -- 897
		while maxLines == nil or processedLines < maxLines do -- 897
			do -- 897
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 899
				if nl < 0 then -- 899
					break -- 900
				end -- 900
				processedLines = processedLines + 1 -- 901
				local line = __TS__StringSlice(buffer, 0, nl) -- 903
				buffer = __TS__StringSlice(buffer, nl + 1) -- 904
				if __TS__StringEndsWith(line, "\r") then -- 904
					line = string.sub(line, 1, -2) -- 906
				end -- 906
				if line == "" then -- 906
					flushEventIfAny() -- 909
					goto __continue220 -- 910
				end -- 910
				if __TS__StringStartsWith(line, ":") then -- 910
					goto __continue220 -- 914
				end -- 914
				if __TS__StringStartsWith(line, "data:") then -- 914
					local v = string.sub(line, 6) -- 917
					if __TS__StringStartsWith(v, " ") then -- 917
						v = string.sub(v, 2) -- 918
					end -- 918
					eventDataLines[#eventDataLines + 1] = v -- 919
					goto __continue220 -- 920
				end -- 920
			end -- 920
			::__continue220:: -- 920
		end -- 920
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0 -- 923
	end -- 896
	local function feed(chunk) -- 926
		append(chunk) -- 927
		drain() -- 928
	end -- 926
	local function ____end() -- 931
		if #buffer > 0 then -- 931
			local line = buffer -- 933
			buffer = "" -- 934
			if __TS__StringEndsWith(line, "\r") then -- 934
				line = string.sub(line, 1, -2) -- 935
			end -- 935
			if __TS__StringStartsWith(line, "data:") then -- 935
				local v = string.sub(line, 6) -- 938
				if __TS__StringStartsWith(v, " ") then -- 938
					v = string.sub(v, 2) -- 939
				end -- 939
				eventDataLines[#eventDataLines + 1] = v -- 940
			end -- 940
		end -- 940
		flushEventIfAny() -- 943
	end -- 931
	local function discard() -- 946
		buffer = "" -- 947
		eventDataLines = {} -- 948
	end -- 946
	return { -- 951
		append = append, -- 951
		drain = drain, -- 951
		feed = feed, -- 951
		["end"] = ____end, -- 951
		discard = discard -- 951
	} -- 951
end -- 865
local SSE_PARSE_LINES_PER_FRAME = 256 -- 954
local function createScheduledSSEJSONParser(opts, isCancelled) -- 956
	local parser = ____exports.createSSEJSONParser(opts) -- 960
	local inputFinished = false -- 961
	local settled = false -- 962
	local resolveFinished -- 963
	local finished = __TS__New( -- 964
		__TS__Promise, -- 964
		function(____, resolve) -- 964
			resolveFinished = resolve -- 965
		end -- 964
	) -- 964
	local function settle() -- 967
		if settled then -- 967
			return -- 968
		end -- 968
		settled = true -- 969
		if resolveFinished ~= nil then -- 969
			resolveFinished() -- 970
		end -- 970
	end -- 967
	Director.systemScheduler:schedule(function() -- 972
		if settled then -- 972
			return true -- 973
		end -- 973
		if isCancelled and isCancelled() then -- 973
			parser.discard() -- 975
			settle() -- 976
			return true -- 977
		end -- 977
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME) -- 979
		if inputFinished and not hasMoreCompleteLines then -- 979
			parser["end"]() -- 981
			settle() -- 982
			return true -- 983
		end -- 983
		return false -- 985
	end) -- 972
	return { -- 987
		append = parser.append, -- 988
		finish = function() -- 989
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 989
				inputFinished = true -- 990
				__TS__Await(finished) -- 991
			end) -- 991
		end, -- 989
		cancel = function() -- 993
			parser.discard() -- 994
			settle() -- 995
		end -- 993
	} -- 993
end -- 956
function ____exports.extractLLMTokenUsage(response) -- 1091
	local usage = response and response.usage -- 1092
	if not usage or type(usage) ~= "table" then -- 1092
		return nil -- 1093
	end -- 1093
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1094
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1097
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1097
		return nil -- 1100
	end -- 1100
	local ____temp_17 -- 1101
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1101
		____temp_17 = usage.prompt_cache_hit_tokens -- 1102
	else -- 1102
		local ____temp_16 -- 1103
		local ____opt_12 = usage.prompt_tokens_details -- 1103
		if type(____opt_12 and ____opt_12.cached_tokens) == "number" then -- 1103
			____temp_16 = usage.prompt_tokens_details.cached_tokens -- 1104
		else -- 1104
			local ____opt_14 = usage.input_tokens_details -- 1104
			____temp_16 = type(____opt_14 and ____opt_14.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1105
		end -- 1105
		____temp_17 = ____temp_16 -- 1103
	end -- 1103
	local cachedInputTokens = ____temp_17 -- 1101
	local ____inputTokens_20 = inputTokens -- 1109
	local ____outputTokens_21 = outputTokens -- 1110
	local ____temp_22 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1111
	local ____temp_23 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1112
	local ____temp_24 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1113
	local ____opt_18 = usage.completion_tokens_details -- 1113
	return { -- 1108
		inputTokens = ____inputTokens_20, -- 1109
		outputTokens = ____outputTokens_21, -- 1110
		totalTokens = ____temp_22, -- 1111
		cachedInputTokens = ____temp_23, -- 1112
		cacheMissInputTokens = ____temp_24, -- 1113
		reasoningOutputTokens = type(____opt_18 and ____opt_18.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1116
	} -- 1116
end -- 1091
function ____exports.validateAgentLLMConfig(config) -- 1155
	local ____opt_25 = config.customOptions -- 1155
	local auxiliaryOptions = ____opt_25 and ____opt_25.auxiliaryOptions -- 1156
	if isPlainRecord(auxiliaryOptions) then -- 1156
		for _key in pairs(auxiliaryOptions) do -- 1158
			return {success = true} -- 1159
		end -- 1159
	end -- 1159
	return {success = false, message = "LLM 配置的 customOptions 必须包含非空 auxiliaryOptions，请检查 LLM 配置"} -- 1162
end -- 1155
local function normalizeContextWindow(value) -- 1168
	if type(value) == "number" and value > 0 then -- 1168
		return math.floor(value) -- 1170
	end -- 1170
	return 64000 -- 1172
end -- 1168
local function normalizeSupportsFunctionCalling(value) -- 1175
	return value == nil or value ~= 0 -- 1176
end -- 1175
local function normalizeLLMTemperature(value) -- 1179
	if type(value) == "number" then -- 1179
		return math.max( -- 1181
			0, -- 1181
			math.min(2, value) -- 1181
		) -- 1181
	end -- 1181
	return 0.1 -- 1183
end -- 1179
local function normalizeLLMMaxTokens(value) -- 1186
	if type(value) == "number" then -- 1186
		return math.max( -- 1188
			1, -- 1188
			math.floor(value) -- 1188
		) -- 1188
	end -- 1188
	return 8192 -- 1190
end -- 1186
local function normalizeLLMCustomOptions(value) -- 1199
	if type(value) ~= "string" then -- 1199
		return nil -- 1200
	end -- 1200
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1201
	if text == "" then -- 1201
		return nil -- 1202
	end -- 1202
	local decoded = ____exports.safeJsonDecode(text) -- 1203
	return isPlainRecord(decoded) and decoded or nil -- 1204
end -- 1199
local function getLLMConfigRecords() -- 1227
	local rows = DB:query("select * from LLMConfig", true) -- 1228
	local records = {} -- 1229
	if rows and #rows > 1 then -- 1229
		do -- 1229
			local i = 1 -- 1231
			while i < #rows do -- 1231
				local record = {} -- 1232
				do -- 1232
					local c = 0 -- 1233
					while c < #rows[i + 1] do -- 1233
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1234
						c = c + 1 -- 1233
					end -- 1233
				end -- 1233
				records[#records + 1] = record -- 1236
				i = i + 1 -- 1231
			end -- 1231
		end -- 1231
	end -- 1231
	return records -- 1239
end -- 1227
local function parseLLMConfig(config) -- 1242
	if not config then -- 1242
		return {success = false, message = "LLM config not found"} -- 1244
	end -- 1244
	local ____config_27 = config -- 1246
	local id = ____config_27.id -- 1246
	local url = ____config_27.url -- 1246
	local model = ____config_27.model -- 1246
	local api_key = ____config_27.api_key -- 1246
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1246
		return {success = false, message = "got invalid LLM config"} -- 1248
	end -- 1248
	return { -- 1250
		success = true, -- 1251
		config = { -- 1252
			url = url, -- 1253
			model = model, -- 1254
			apiKey = api_key, -- 1255
			contextWindow = normalizeContextWindow(config.context_window), -- 1256
			temperature = normalizeLLMTemperature(config.temperature), -- 1257
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1258
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1259
			customOptions = normalizeLLMCustomOptions(config.custom_options), -- 1260
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 1261
		} -- 1261
	} -- 1261
end -- 1242
function ____exports.getLLMConfig(configId) -- 1266
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1267
	if normalizedId == nil or normalizedId <= 0 then -- 1267
		return {success = false, message = "LLM config is not selected"} -- 1269
	end -- 1269
	return parseLLMConfig(__TS__ArrayFind( -- 1271
		getLLMConfigRecords(), -- 1271
		function(____, record) return record.id == normalizedId end -- 1271
	)) -- 1271
end -- 1266
function ____exports.getActiveLLMConfig() -- 1274
	local records = getLLMConfigRecords() -- 1275
	local config = __TS__ArrayFind( -- 1276
		records, -- 1276
		function(____, r) return r.active ~= 0 end -- 1276
	) -- 1276
	if not config then -- 1276
		return {success = false, message = "no active LLM config"} -- 1278
	end -- 1278
	return parseLLMConfig(config) -- 1280
end -- 1274
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1283
	local callEvent -- 1289
	if event.id ~= nil then -- 1289
		local id = event.id -- 1291
		callEvent = { -- 1292
			id = nil, -- 1293
			onData = function(data) -- 1294
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1295
				return event.stopToken.stopped -- 1296
			end, -- 1294
			onCancel = function(reason) -- 1298
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1299
			end, -- 1298
			onDone = function() -- 1301
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1302
			end -- 1301
		} -- 1301
	else -- 1301
		callEvent = event -- 1306
	end -- 1306
	local ____callEvent_28 = callEvent -- 1308
	local onData = ____callEvent_28.onData -- 1308
	local onDone = ____callEvent_28.onDone -- 1308
	local ____callEvent_29 = callEvent -- 1309
	local onCancel = ____callEvent_29.onCancel -- 1309
	local config = llmConfig or (function() -- 1310
		local configRes = ____exports.getActiveLLMConfig() -- 1311
		if not configRes.success then -- 1311
			if onCancel then -- 1311
				onCancel(configRes.message) -- 1313
			end -- 1313
			return nil -- 1314
		end -- 1314
		return configRes.config -- 1316
	end)() -- 1310
	if not config then -- 1310
		return {success = false, message = "no active LLM config"} -- 1319
	end -- 1319
	local url = config.url -- 1319
	local model = config.model -- 1319
	local apiKey = config.apiKey -- 1319
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1322
	if fitted.trimmed then -- 1322
		____exports.Log( -- 1324
			"Warn", -- 1324
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1324
		) -- 1324
	end -- 1324
	local stopLLM = false -- 1326
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1327
	local parser = createScheduledSSEJSONParser( -- 1330
		{onJSON = function(obj) -- 1330
			local result = onData(obj) -- 1332
			if result then -- 1332
				stopLLM = true -- 1334
				streamStopToken.stopped = true -- 1335
				streamStopToken.reason = "LLM Stopped" -- 1336
			end -- 1336
		end}, -- 1331
		function() return streamStopToken.stopped end -- 1339
	); -- 1339
	(function() -- 1340
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1340
			local ____try = __TS__AsyncAwaiter(function() -- 1340
				local result = __TS__Await(postLLM( -- 1342
					fitted.messages, -- 1342
					url, -- 1342
					apiKey, -- 1342
					model, -- 1342
					options, -- 1342
					true, -- 1342
					config.customOptions, -- 1342
					function(data) -- 1342
						if stopLLM then -- 1342
							if onCancel then -- 1342
								onCancel("LLM Stopped") -- 1345
								onCancel = nil -- 1346
							end -- 1346
							return true -- 1348
						end -- 1348
						parser.append(data) -- 1350
						return false -- 1351
					end, -- 1342
					streamStopToken -- 1352
				)) -- 1352
				__TS__Await(parser.finish()) -- 1353
				if onDone then -- 1353
					onDone(result) -- 1355
				end -- 1355
			end) -- 1355
			____try = ____try.catch( -- 1355
				____try, -- 1355
				function(____, e) -- 1355
					return __TS__AsyncAwaiter(function() -- 1355
						parser.cancel() -- 1358
						stopLLM = true -- 1359
						if onCancel then -- 1359
							onCancel(tostring(e)) -- 1361
							onCancel = nil -- 1362
						end -- 1362
					end) -- 1362
				end -- 1362
			) -- 1362
			__TS__Await(____try) -- 1341
		end) -- 1341
	end)() -- 1340
	return {success = true} -- 1366
end -- 1283
local function mergeStreamToolCall(target, delta) -- 1369
	if type(delta.id) == "string" and delta.id ~= "" then -- 1369
		target.id = delta.id -- 1371
	end -- 1371
	if type(delta.type) == "string" and delta.type ~= "" then -- 1371
		target.type = delta.type -- 1374
	end -- 1374
	if delta["function"] then -- 1374
		if target["function"] == nil then -- 1374
			target["function"] = {} -- 1377
		end -- 1377
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1377
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1379
		end -- 1379
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1379
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1382
		end -- 1382
	end -- 1382
end -- 1369
local function isToolCallComplete(tc) -- 1387
	if type(tc.id) ~= "string" or tc.id == "" then -- 1387
		return false -- 1388
	end -- 1388
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1388
		return false -- 1389
	end -- 1389
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1389
		return false -- 1390
	end -- 1390
	local args = tc["function"].arguments -- 1391
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1391
		return false -- 1392
	end -- 1392
	local decoded = ____exports.safeJsonDecode(args) -- 1393
	return decoded ~= nil -- 1394
end -- 1387
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1397
	local delta = choice.delta or ({}) -- 1398
	local fullMessage = choice.message or ({}) -- 1399
	local message = acc.message -- 1400
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1401
	if type(role) == "string" and role ~= "" then -- 1401
		message.role = role -- 1405
	end -- 1405
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1407
	if type(content) == "string" and content ~= "" then -- 1407
		message.content = (message.content or "") .. content -- 1411
	end -- 1411
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1413
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1413
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1417
	end -- 1417
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1419
	if #toolCalls > 0 then -- 1419
		if message.tool_calls == nil then -- 1419
			message.tool_calls = {} -- 1423
		end -- 1423
		do -- 1423
			local i = 0 -- 1424
			while i < #toolCalls do -- 1424
				local item = toolCalls[i + 1] -- 1425
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1426
				local ____message_tool_calls_30, ____temp_31 = message.tool_calls, index + 1 -- 1426
				if ____message_tool_calls_30[____temp_31] == nil then -- 1426
					____message_tool_calls_30[____temp_31] = {} -- 1429
				end -- 1429
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1430
				if onToolCallReady and emittedToolCallIds then -- 1430
					local tc = message.tool_calls[index + 1] -- 1432
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1432
						emittedToolCallIds[tc.id] = true -- 1434
						onToolCallReady(tc) -- 1435
					end -- 1435
				end -- 1435
				i = i + 1 -- 1424
			end -- 1424
		end -- 1424
	end -- 1424
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1424
		acc.finish_reason = choice.finish_reason -- 1441
	end -- 1441
end -- 1397
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1445
	local indexes = __TS__ArraySort( -- 1454
		__TS__ArrayFilter( -- 1454
			__TS__ArrayMap( -- 1454
				__TS__ObjectKeys(states), -- 1454
				function(____, key) return __TS__Number(key) end -- 1455
			), -- 1455
			function(____, index) return __TS__NumberIsFinite(index) end -- 1456
		), -- 1456
		function(____, a, b) return a - b end -- 1457
	) -- 1457
	return { -- 1458
		id = id, -- 1459
		created = created, -- 1460
		object = object, -- 1461
		model = model, -- 1462
		choices = __TS__ArrayMap( -- 1463
			indexes, -- 1463
			function(____, index) -- 1463
				local state = states[index] -- 1464
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1465
			end -- 1463
		), -- 1463
		usage = usage, -- 1476
		error = providerError -- 1477
	} -- 1477
end -- 1445
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1481
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1481
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1492
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1493
		local resolvedConfig = config or (function() -- 1496
			local configRes = ____exports.getActiveLLMConfig() -- 1497
			if not configRes.success then -- 1497
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1499
				return nil -- 1500
			end -- 1500
			return configRes.config -- 1502
		end)() -- 1496
		if not resolvedConfig then -- 1496
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1496
		end -- 1496
		local url = resolvedConfig.url -- 1496
		local model = resolvedConfig.model -- 1496
		local apiKey = resolvedConfig.apiKey -- 1496
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1508
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1509
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1510
		local ____model_36 = model -- 1513
		local ____url_37 = url -- 1513
		local ____temp_38 = #messages -- 1513
		local ____tostring_33 = tostring -- 1513
		local ____options_max_tokens_32 = options.max_tokens -- 1513
		if ____options_max_tokens_32 == nil then -- 1513
			____options_max_tokens_32 = "unset" -- 1513
		end -- 1513
		local ____tostring_33_result_39 = ____tostring_33(____options_max_tokens_32) -- 1513
		local ____tostring_35 = tostring -- 1513
		local ____options_temperature_34 = options.temperature -- 1513
		if ____options_temperature_34 == nil then -- 1513
			____options_temperature_34 = "unset" -- 1513
		end -- 1513
		____exports.Log( -- 1513
			"Info", -- 1513
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_36) .. " url=") .. ____url_37) .. " messages=") .. tostring(____temp_38)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_33_result_39) .. " temperature=") .. ____tostring_35(____options_temperature_34)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1513
		) -- 1513
		if stopToken and stopToken.stopped then -- 1513
			local reason = stopToken.reason or "request cancelled" -- 1515
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1516
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1516
		end -- 1516
		local ____hasReturned, ____returnValue -- 1516
		local ____try = __TS__AsyncAwaiter(function() -- 1516
			local states = {} -- 1520
			local emittedToolCallIds = {} -- 1521
			local responseId = nil -- 1522
			local responseCreated = nil -- 1523
			local responseObject = nil -- 1524
			local providerError -- 1525
			local responseUsage -- 1526
			local httpChunkCount = 0 -- 1527
			local rawStreamBytes = 0 -- 1528
			local rawStreamPreview = "" -- 1529
			local sseJSONChunkCount = 0 -- 1530
			local choiceJSONChunkCount = 0 -- 1531
			local emptyChoicesChunkCount = 0 -- 1532
			local missingChoicesChunkCount = 0 -- 1533
			local parseErrorCount = 0 -- 1534
			local doneChunkSeen = false -- 1535
			local lastJSONPreview = "" -- 1536
			local parser = createScheduledSSEJSONParser( -- 1537
				{ -- 1537
					onJSON = function(obj, raw) -- 1538
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1539
						lastJSONPreview = previewText(raw, 500) -- 1540
						if not obj or type(obj) ~= "table" then -- 1540
							return -- 1542
						end -- 1542
						local chunk = obj -- 1544
						if chunk.error then -- 1544
							providerError = chunk.error -- 1546
							____exports.Log( -- 1547
								"Warn", -- 1547
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1547
							) -- 1547
							return -- 1548
						end -- 1548
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1550
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1551
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1552
						if chunk.usage and type(chunk.usage) == "table" then -- 1552
							responseUsage = chunk.usage -- 1554
						end -- 1554
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1556
						if not __TS__ArrayIsArray(chunk.choices) then -- 1556
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1558
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1558
								____exports.Log( -- 1560
									"Warn", -- 1560
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1560
								) -- 1560
							end -- 1560
						elseif #choices == 0 then -- 1560
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1563
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1563
								____exports.Log( -- 1565
									"Warn", -- 1565
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1565
								) -- 1565
							end -- 1565
						else -- 1565
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1568
						end -- 1568
						do -- 1568
							local i = 0 -- 1570
							while i < #choices do -- 1570
								local choice = choices[i + 1] -- 1571
								local index = type(choice.index) == "number" and choice.index or i -- 1572
								if states[index] == nil then -- 1572
									states[index] = {index = index, message = {role = "assistant"}} -- 1573
								end -- 1573
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1577
								i = i + 1 -- 1570
							end -- 1570
						end -- 1570
						if onChunk ~= nil then -- 1570
							onChunk( -- 1579
								buildStreamResponse( -- 1580
									states, -- 1580
									model, -- 1580
									responseId, -- 1580
									responseCreated, -- 1580
									responseObject, -- 1580
									providerError, -- 1580
									responseUsage -- 1580
								), -- 1580
								{ -- 1581
									id = chunk.id or "", -- 1582
									created = chunk.created or 0, -- 1583
									object = chunk.object or "", -- 1584
									model = chunk.model or model, -- 1585
									choices = choices -- 1586
								} -- 1586
							) -- 1586
						end -- 1586
					end, -- 1538
					onDone = function() -- 1590
						doneChunkSeen = true -- 1591
					end, -- 1590
					onError = function(err, context) -- 1593
						parseErrorCount = parseErrorCount + 1 -- 1594
						____exports.Log( -- 1595
							"Warn", -- 1595
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1595
						) -- 1595
					end -- 1593
				}, -- 1593
				function() return (stopToken and stopToken.stopped) == true end -- 1597
			) -- 1597
			local ____try = __TS__AsyncAwaiter(function() -- 1597
				__TS__Await(postLLM( -- 1599
					fitted.messages, -- 1599
					url, -- 1599
					apiKey, -- 1599
					model, -- 1599
					options, -- 1599
					true, -- 1599
					resolvedConfig.customOptions, -- 1599
					function(data) -- 1599
						if stopToken and stopToken.stopped then -- 1599
							return true -- 1600
						end -- 1600
						httpChunkCount = httpChunkCount + 1 -- 1601
						rawStreamBytes = rawStreamBytes + #data -- 1602
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1602
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1604
						end -- 1604
						parser.append(data) -- 1606
						return false -- 1607
					end, -- 1599
					stopToken -- 1608
				)) -- 1608
				__TS__Await(parser.finish()) -- 1609
			end) -- 1609
			____try = ____try.catch( -- 1609
				____try, -- 1609
				function(____, e) -- 1609
					return __TS__AsyncAwaiter(function() -- 1609
						parser.cancel() -- 1611
						error(e, 0) -- 1612
					end) -- 1612
				end -- 1612
			) -- 1612
			__TS__Await(____try) -- 1598
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1598
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1615
				if rawResponse and type(rawResponse) == "table" then -- 1615
					local rawResponseObj = rawResponse -- 1617
					if rawResponseObj.error then -- 1617
						providerError = rawResponseObj.error -- 1619
						lastJSONPreview = previewText( -- 1620
							normalizeLLMJSONResponse(rawStreamPreview), -- 1620
							500 -- 1620
						) -- 1620
						____exports.Log( -- 1621
							"Warn", -- 1621
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1621
						) -- 1621
					end -- 1621
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1621
						responseUsage = rawResponseObj.usage -- 1624
					end -- 1624
				end -- 1624
			end -- 1624
			local response = buildStreamResponse( -- 1628
				states, -- 1628
				model, -- 1628
				responseId, -- 1628
				responseCreated, -- 1628
				responseObject, -- 1628
				providerError, -- 1628
				responseUsage -- 1628
			) -- 1628
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1629
			local choiceCount = response.choices and #response.choices or 0 -- 1630
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1631
			____exports.Log( -- 1632
				"Info", -- 1632
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1632
			) -- 1632
			if not doneChunkSeen then -- 1632
				local rawPreview = previewText( -- 1634
					____exports.sanitizeUTF8(rawStreamPreview), -- 1634
					1200 -- 1634
				) -- 1634
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1635
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1636
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1637
				____hasReturned = true -- 1638
				____returnValue = { -- 1638
					success = false, -- 1639
					message = message, -- 1640
					raw = rawStreamPreview, -- 1641
					response = response, -- 1642
					tokenUsage = tokenUsage -- 1643
				} -- 1643
				return -- 1638
			end -- 1638
			if not response.choices or #response.choices == 0 then -- 1638
				local providerMessage = providerError and providerError.message or "" -- 1647
				local providerType = providerError and providerError.type or "" -- 1648
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1649
				local details = table.concat( -- 1652
					__TS__ArrayFilter( -- 1652
						{providerType, providerCode}, -- 1652
						function(____, part) return part ~= "" end -- 1652
					), -- 1652
					"/" -- 1652
				) -- 1652
				local rawPreview = previewText( -- 1653
					____exports.sanitizeUTF8(rawStreamPreview), -- 1653
					1200 -- 1653
				) -- 1653
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1654
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1655
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1658
				____hasReturned = true -- 1659
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1659
				return -- 1659
			end -- 1659
			____hasReturned = true -- 1666
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1666
			return -- 1666
		end) -- 1666
		____try = ____try.catch( -- 1666
			____try, -- 1666
			function(____, e) -- 1666
				return __TS__AsyncAwaiter(function() -- 1666
					if stopToken and stopToken.stopped then -- 1666
						local reason = stopToken.reason or "request cancelled" -- 1673
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1674
						____hasReturned = true -- 1675
						____returnValue = {success = false, message = reason} -- 1675
						return -- 1675
					end -- 1675
					____exports.Log( -- 1677
						"Error", -- 1677
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1677
					) -- 1677
					____hasReturned = true -- 1678
					____returnValue = { -- 1678
						success = false, -- 1678
						message = tostring(e) -- 1678
					} -- 1678
					return -- 1678
				end) -- 1678
			end -- 1678
		) -- 1678
		__TS__Await(____try) -- 1519
		if ____hasReturned then -- 1519
			return ____awaiter_resolve(nil, ____returnValue) -- 1519
		end -- 1519
	end) -- 1519
end -- 1481
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1682
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1682
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1688
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1689
		local resolvedConfig = config or (function() -- 1692
			local configRes = ____exports.getActiveLLMConfig() -- 1693
			if not configRes.success then -- 1693
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1695
				return nil -- 1696
			end -- 1696
			return configRes.config -- 1698
		end)() -- 1692
		if not resolvedConfig then -- 1692
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1692
		end -- 1692
		local url = resolvedConfig.url -- 1692
		local model = resolvedConfig.model -- 1692
		local apiKey = resolvedConfig.apiKey -- 1692
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1704
		____exports.Log( -- 1705
			"Info", -- 1705
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1705
		) -- 1705
		if stopToken and stopToken.stopped then -- 1705
			local reason = stopToken.reason or "request cancelled" -- 1707
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1708
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1708
		end -- 1708
		local ____hasReturned, ____returnValue -- 1708
		local ____try = __TS__AsyncAwaiter(function() -- 1708
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1712
				fitted.messages, -- 1712
				url, -- 1712
				apiKey, -- 1712
				model, -- 1712
				options, -- 1712
				false, -- 1712
				resolvedConfig.customOptions, -- 1712
				nil, -- 1712
				stopToken -- 1712
			))) -- 1712
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1713
			____exports.Log( -- 1714
				"Info", -- 1714
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1714
			) -- 1714
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1715
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1715
				local rawPreview = previewText(raw) -- 1717
				____exports.Log( -- 1718
					"Error", -- 1718
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1718
				) -- 1718
				____hasReturned = true -- 1719
				____returnValue = { -- 1719
					success = false, -- 1720
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1721
					raw = raw -- 1722
				} -- 1722
				return -- 1719
			end -- 1719
			local responseObj = response -- 1725
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1726
			____exports.Log( -- 1727
				"Info", -- 1727
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1727
			) -- 1727
			if not responseObj.choices or #responseObj.choices == 0 then -- 1727
				local providerError = responseObj.error -- 1729
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1730
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1733
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1736
				local details = table.concat( -- 1739
					__TS__ArrayFilter( -- 1739
						{providerType, providerCode}, -- 1739
						function(____, part) return part ~= "" end -- 1739
					), -- 1739
					"/" -- 1739
				) -- 1739
				local rawPreview = previewText(raw, 400) -- 1740
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1741
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1744
				____hasReturned = true -- 1745
				____returnValue = {success = false, message = message, raw = raw} -- 1745
				return -- 1745
			end -- 1745
			____hasReturned = true -- 1751
			____returnValue = {success = true, response = responseObj} -- 1751
			return -- 1751
		end) -- 1751
		____try = ____try.catch( -- 1751
			____try, -- 1751
			function(____, e) -- 1751
				return __TS__AsyncAwaiter(function() -- 1751
					if stopToken and stopToken.stopped then -- 1751
						local reason = stopToken.reason or "request cancelled" -- 1757
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1758
						____hasReturned = true -- 1759
						____returnValue = {success = false, message = reason} -- 1759
						return -- 1759
					end -- 1759
					____exports.Log( -- 1761
						"Error", -- 1761
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1761
					) -- 1761
					____hasReturned = true -- 1762
					____returnValue = { -- 1762
						success = false, -- 1762
						message = tostring(e) -- 1762
					} -- 1762
					return -- 1762
				end) -- 1762
			end -- 1762
		) -- 1762
		__TS__Await(____try) -- 1711
		if ____hasReturned then -- 1711
			return ____awaiter_resolve(nil, ____returnValue) -- 1711
		end -- 1711
	end) -- 1711
end -- 1682
return ____exports -- 1682