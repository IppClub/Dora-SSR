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
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
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
function ____exports.sanitizeUTF8(text) -- 341
	if not text then -- 341
		return "" -- 342
	end -- 342
	local remaining = text -- 343
	local output = "" -- 344
	while remaining ~= "" do -- 344
		local len, invalidPos = utf8.len(remaining) -- 346
		if len ~= nil then -- 346
			output = output .. remaining -- 348
			break -- 349
		end -- 349
		local badPos = type(invalidPos) == "number" and invalidPos or 1 -- 351
		if badPos > 1 then -- 351
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1) -- 353
		end -- 353
		remaining = __TS__StringSubstring(remaining, badPos) -- 355
	end -- 355
	return output -- 357
end -- 341
function normalizeReasoningEffort(value) -- 1117
	if type(value) ~= "string" then -- 1117
		return nil -- 1118
	end -- 1118
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1119
	return normalized ~= "" and normalized or nil -- 1120
end -- 1120
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1131
	if not customOptions then -- 1131
		return options -- 1135
	end -- 1135
	local merged = __TS__ObjectAssign({}, options) -- 1136
	for key in pairs(customOptions) do -- 1137
		local value = customOptions[key] -- 1138
		if value == json.null then -- 1138
			__TS__Delete(merged, key) -- 1140
		else -- 1140
			merged[key] = value -- 1142
		end -- 1142
	end -- 1142
	return merged -- 1145
end -- 1131
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
local function normalizeCompletionText(value) -- 98
	if type(value) ~= "string" then -- 98
		return "" -- 99
	end -- 99
	return __TS__StringSlice( -- 100
		__TS__StringTrim(____exports.sanitizeUTF8(value)), -- 100
		0, -- 100
		AgentConfig.AGENT_LIMITS.completionTextMaxChars -- 100
	) -- 100
end -- 98
local function normalizeCompletionTextList(value, maxItems) -- 103
	if maxItems == nil then -- 103
		maxItems = AgentConfig.AGENT_LIMITS.completionListMaxItems -- 105
	end -- 105
	if not __TS__ArrayIsArray(value) then -- 105
		return {} -- 107
	end -- 107
	local items = {} -- 108
	do -- 108
		local i = 0 -- 109
		while i < #value and #items < maxItems do -- 109
			local item = normalizeCompletionText(value[i + 1]) -- 110
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 110
				items[#items + 1] = item -- 111
			end -- 111
			i = i + 1 -- 109
		end -- 109
	end -- 109
	return items -- 113
end -- 103
function ____exports.normalizeAgentCompletionReport(value) -- 116
	local row = value and not __TS__ArrayIsArray(value) and type(value) == "table" and value or ({}) -- 117
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 120
	local validation = {} -- 123
	if __TS__ArrayIsArray(row.validation) then -- 123
		do -- 123
			local i = 0 -- 125
			while i < #row.validation and #validation < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 125
				do -- 125
					local raw = row.validation[i + 1] -- 126
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 126
						goto __continue21 -- 127
					end -- 127
					local item = raw -- 128
					local kind = (item.kind == "runtime" or item.kind == "manual") and item.kind or (item.kind == "build" and "build" or nil) -- 129
					local result = (item.result == "passed" or item.result == "failed" or item.result == "not_run") and item.result or nil -- 130
					if kind == nil or result == nil then -- 130
						goto __continue21 -- 131
					end -- 131
					validation[#validation + 1] = { -- 132
						kind = kind, -- 133
						result = result, -- 134
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems) -- 135
					} -- 135
				end -- 135
				::__continue21:: -- 135
				i = i + 1 -- 125
			end -- 125
		end -- 125
	end -- 125
	local learningCandidates = {} -- 139
	if __TS__ArrayIsArray(row.learningCandidates) then -- 139
		do -- 139
			local i = 0 -- 141
			while i < #row.learningCandidates and #learningCandidates < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 141
				do -- 141
					local raw = row.learningCandidates[i + 1] -- 142
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 142
						goto __continue26 -- 143
					end -- 143
					local item = raw -- 144
					local claim = normalizeCompletionText(item.claim) -- 145
					if claim == "" then -- 145
						goto __continue26 -- 146
					end -- 146
					learningCandidates[#learningCandidates + 1] = { -- 147
						claim = claim, -- 148
						scope = (item.scope == "file" or item.scope == "engine") and item.scope or "project", -- 149
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems), -- 150
						confidence = item.confidence == "inferred" and "inferred" or "observed" -- 151
					} -- 151
				end -- 151
				::__continue26:: -- 151
				i = i + 1 -- 141
			end -- 141
		end -- 141
	end -- 141
	return { -- 155
		outcome = outcome, -- 156
		validation = validation, -- 157
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 158
		assumptions = normalizeCompletionTextList(row.assumptions), -- 159
		learningCandidates = learningCandidates -- 160
	} -- 160
end -- 116
function ____exports.replaceFirst(text, oldStr, newStr) -- 168
	if oldStr == "" then -- 168
		return text -- 169
	end -- 169
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 170
	if idx < 0 then -- 170
		return text -- 171
	end -- 171
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 172
end -- 168
local function getLeadingWhitespace(text) -- 175
	local i = 0 -- 176
	while i < #text do -- 176
		local ch = __TS__StringAccess(text, i) -- 178
		if ch ~= " " and ch ~= "\t" then -- 178
			break -- 179
		end -- 179
		i = i + 1 -- 180
	end -- 180
	return __TS__StringSubstring(text, 0, i) -- 182
end -- 175
local function getCommonIndentPrefix(lines) -- 185
	local common -- 186
	do -- 186
		local i = 0 -- 187
		while i < #lines do -- 187
			do -- 187
				local line = lines[i + 1] -- 188
				if __TS__StringTrim(line) == "" then -- 188
					goto __continue37 -- 189
				end -- 189
				local indent = getLeadingWhitespace(line) -- 190
				if common == nil then -- 190
					common = indent -- 192
					goto __continue37 -- 193
				end -- 193
				local j = 0 -- 195
				local maxLen = math.min(#common, #indent) -- 196
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 196
					j = j + 1 -- 198
				end -- 198
				common = __TS__StringSubstring(common, 0, j) -- 200
				if common == "" then -- 200
					break -- 201
				end -- 201
			end -- 201
			::__continue37:: -- 201
			i = i + 1 -- 187
		end -- 187
	end -- 187
	return common or "" -- 203
end -- 185
local function removeIndentPrefix(line, indent) -- 206
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 206
		return __TS__StringSubstring(line, #indent) -- 208
	end -- 208
	local lineIndent = getLeadingWhitespace(line) -- 210
	local j = 0 -- 211
	local maxLen = math.min(#lineIndent, #indent) -- 212
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 212
		j = j + 1 -- 214
	end -- 214
	return __TS__StringSubstring(line, j) -- 216
end -- 206
local function dedentLines(lines) -- 219
	local indent = getCommonIndentPrefix(lines) -- 220
	return { -- 221
		indent = indent, -- 222
		lines = __TS__ArrayMap( -- 223
			lines, -- 223
			function(____, line) return removeIndentPrefix(line, indent) end -- 223
		) -- 223
	} -- 223
end -- 219
local function findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 227
	local function foldWhitespace(text, withMap) -- 233
		local parts = {} -- 234
		local map = {} -- 235
		local i = 0 -- 236
		while i < #text do -- 236
			local ch = __TS__StringAccess(text, i) -- 238
			if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 238
				local start = i -- 240
				while i < #text do -- 240
					local next = __TS__StringAccess(text, i) -- 242
					if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 242
						break -- 243
					end -- 243
					i = i + 1 -- 244
				end -- 244
				parts[#parts + 1] = " " -- 246
				if withMap then -- 246
					map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 247
				end -- 247
			else -- 247
				parts[#parts + 1] = ch -- 249
				if withMap then -- 249
					map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 250
				end -- 250
				i = i + 1 -- 251
			end -- 251
		end -- 251
		return { -- 254
			text = table.concat(parts, ""), -- 254
			map = map -- 254
		} -- 254
	end -- 233
	local foldedContent = foldWhitespace(content, true) -- 256
	local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 257
	if foldedOld == "" then -- 257
		return {success = false, message = "old_str not found in file"} -- 259
	end -- 259
	local matches = {} -- 261
	local pos = 0 -- 262
	while true do -- 262
		local idx = (string.find( -- 264
			foldedContent.text, -- 264
			foldedOld, -- 264
			math.max(pos + 1, 1), -- 264
			true -- 264
		) or 0) - 1 -- 264
		if idx < 0 then -- 264
			break -- 265
		end -- 265
		local lastIdx = idx + #foldedOld - 1 -- 266
		local startMap = foldedContent.map[idx + 1] -- 267
		local endMap = foldedContent.map[lastIdx + 1] -- 268
		if startMap ~= nil and endMap ~= nil then -- 268
			matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 270
		end -- 270
		pos = idx + #foldedOld -- 272
	end -- 272
	if #matches == 0 then -- 272
		return {success = false, message = "old_str not found in file"} -- 275
	end -- 275
	if #matches > 1 then -- 275
		return { -- 278
			success = false, -- 279
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 280
		} -- 280
	end -- 280
	local match = matches[1] -- 283
	return { -- 284
		success = true, -- 285
		content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 286
	} -- 286
end -- 227
function ____exports.findIndentTolerantReplacement(content, oldStr, newStr) -- 290
	local contentLines = __TS__StringSplit(content, "\n") -- 295
	local oldLines = __TS__StringSplit(oldStr, "\n") -- 296
	if #oldLines == 0 then -- 296
		return {success = false, message = "old_str not found in file"} -- 298
	end -- 298
	local dedentedOld = dedentLines(oldLines) -- 300
	local dedentedOldText = table.concat(dedentedOld.lines, "\n") -- 301
	local dedentedNew = dedentLines(__TS__StringSplit(newStr, "\n")) -- 302
	local matches = {} -- 303
	do -- 303
		local start = 0 -- 304
		while start <= #contentLines - #oldLines do -- 304
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 305
			local dedentedCandidate = dedentLines(candidateLines) -- 306
			if table.concat(dedentedCandidate.lines, "\n") == dedentedOldText then -- 306
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 308
			end -- 308
			start = start + 1 -- 304
		end -- 304
	end -- 304
	if #matches == 0 then -- 304
		return findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 316
	end -- 316
	if #matches > 1 then -- 316
		return { -- 319
			success = false, -- 320
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 321
		} -- 321
	end -- 321
	local match = matches[1] -- 324
	local rebuiltNewLines = __TS__ArrayMap( -- 325
		dedentedNew.lines, -- 325
		function(____, line) return line == "" and "" or match.indent .. line end -- 325
	) -- 325
	local ____array_0 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 325
	__TS__SparseArrayPush( -- 325
		____array_0, -- 325
		table.unpack(rebuiltNewLines) -- 328
	) -- 328
	__TS__SparseArrayPush( -- 328
		____array_0, -- 328
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 329
	) -- 329
	local nextLines = {__TS__SparseArraySpread(____array_0)} -- 326
	return { -- 331
		success = true, -- 331
		content = table.concat(nextLines, "\n") -- 331
	} -- 331
end -- 290
local function previewText(text, maxLen) -- 334
	if maxLen == nil then -- 334
		maxLen = 200 -- 334
	end -- 334
	if not text then -- 334
		return "" -- 335
	end -- 335
	local compact = __TS__StringReplace( -- 336
		__TS__StringReplace(text, "\r", "\\r"), -- 336
		"\n", -- 336
		"\\n" -- 336
	) -- 336
	if #compact <= maxLen then -- 336
		return compact -- 337
	end -- 337
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 338
end -- 334
local function sanitizeJSONValue(value) -- 360
	if type(value) == "string" then -- 360
		return ____exports.sanitizeUTF8(value) -- 361
	end -- 361
	if __TS__ArrayIsArray(value) then -- 361
		return __TS__ArrayMap( -- 363
			value, -- 363
			function(____, item) return sanitizeJSONValue(item) end -- 363
		) -- 363
	end -- 363
	if value and type(value) == "table" then -- 363
		local result = {} -- 366
		for key in pairs(value) do -- 367
			result[key] = sanitizeJSONValue(value[key]) -- 368
		end -- 368
		return result -- 370
	end -- 370
	return value -- 372
end -- 360
function ____exports.safeJsonEncode(value, format, emptyAsArray, numAsStr, maxDepth) -- 375
	if format == nil then -- 375
		format = false -- 375
	end -- 375
	if emptyAsArray == nil then -- 375
		emptyAsArray = true -- 375
	end -- 375
	if numAsStr == nil then -- 375
		numAsStr = false -- 375
	end -- 375
	if maxDepth == nil then -- 375
		maxDepth = 128 -- 375
	end -- 375
	return json.encode( -- 376
		sanitizeJSONValue(value), -- 377
		format, -- 378
		emptyAsArray, -- 379
		numAsStr, -- 380
		maxDepth -- 381
	) -- 381
end -- 375
function ____exports.safeJsonDecode(text) -- 385
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 386
	if value == nil then -- 386
		return value, err -- 388
	end -- 388
	return sanitizeJSONValue(value), err -- 390
end -- 385
local function isPlainRecord(value) -- 393
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 394
end -- 393
local function normalizeLLMJSONResponse(text) -- 397
	return __TS__StringTrim(text) -- 398
end -- 397
local function utf8TakeHead(text, maxChars) -- 401
	if maxChars <= 0 or text == "" then -- 401
		return "" -- 402
	end -- 402
	local nextPos = utf8.offset(text, maxChars + 1) -- 403
	if nextPos == nil then -- 403
		return text -- 404
	end -- 404
	return string.sub(text, 1, nextPos - 1) -- 405
end -- 401
local function utf8TakeTail(text, maxChars) -- 408
	if maxChars <= 0 or text == "" then -- 408
		return "" -- 409
	end -- 409
	local charLen = utf8.len(text) -- 410
	if charLen == nil or charLen <= maxChars then -- 410
		return text -- 411
	end -- 411
	local startChar = math.max(1, charLen - maxChars + 1) -- 412
	local startPos = utf8.offset(text, startChar) -- 413
	if startPos == nil then -- 413
		return text -- 414
	end -- 414
	return string.sub(text, startPos) -- 415
end -- 408
function ____exports.estimateTextTokens(text) -- 418
	if not text then -- 418
		return 0 -- 419
	end -- 419
	return App:estimateTokens(text) -- 420
end -- 418
local function estimateMessagesTokens(messages) -- 423
	local total = 0 -- 424
	do -- 424
		local i = 0 -- 425
		while i < #messages do -- 425
			local message = messages[i + 1] -- 426
			total = total + 8 -- 427
			total = total + ____exports.estimateTextTokens(message.role or "") -- 428
			total = total + ____exports.estimateTextTokens(message.content or "") -- 429
			total = total + ____exports.estimateTextTokens(message.name or "") -- 430
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 431
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 432
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({})) -- 433
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 434
			i = i + 1 -- 425
		end -- 425
	end -- 425
	return total -- 436
end -- 423
local function estimateOptionsTokens(options) -- 439
	local text = ____exports.safeJsonEncode(options) -- 440
	return text and ____exports.estimateTextTokens(text) or 0 -- 441
end -- 439
local function getReservedOutputTokens(options, contextWindow) -- 444
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 445
	if explicitMax > 0 then -- 445
		return math.max(256, explicitMax) -- 450
	end -- 450
	return math.max( -- 451
		1024, -- 451
		math.floor(contextWindow * 0.2) -- 451
	) -- 451
end -- 444
local function getInputTokenBudget(messages, options, config) -- 454
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 455
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 458
	local optionTokens = estimateOptionsTokens(options) -- 459
	local structuralOverhead = math.max(256, #messages * 16) -- 460
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 461
end -- 454
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 464
	if budgetTokens <= 0 or text == "" then -- 464
		return "" -- 465
	end -- 465
	local estimated = ____exports.estimateTextTokens(text) -- 466
	if estimated <= budgetTokens then -- 466
		return text -- 467
	end -- 467
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 468
	local targetChars = math.max( -- 469
		200, -- 469
		math.floor(budgetTokens * charsPerToken) -- 469
	) -- 469
	local keepHead = math.max( -- 470
		0, -- 470
		math.floor(targetChars * 0.35) -- 470
	) -- 470
	local keepTail = math.max(0, targetChars - keepHead) -- 471
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 472
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 473
	return (head .. "\n...\n") .. tail -- 474
end -- 464
local function isXMLWhitespaceChar(ch) -- 477
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 478
end -- 477
local function findLineStart(value, from) -- 481
	local i = from -- 482
	while i >= 0 do -- 482
		if __TS__StringAccess(value, i) == "\n" then -- 482
			return i + 1 -- 484
		end -- 484
		i = i - 1 -- 485
	end -- 485
	return 0 -- 487
end -- 481
local function findLastLiteral(text, needle) -- 490
	if needle == "" then -- 490
		return #text -- 491
	end -- 491
	local last = -1 -- 492
	local from = 0 -- 493
	while from <= #text - #needle do -- 493
		local pos = (string.find( -- 495
			text, -- 495
			needle, -- 495
			math.max(from + 1, 1), -- 495
			true -- 495
		) or 0) - 1 -- 495
		if pos < 0 then -- 495
			break -- 496
		end -- 496
		last = pos -- 497
		from = pos + 1 -- 498
	end -- 498
	return last -- 500
end -- 490
local function unwrapXMLRawText(text) -- 503
	local trimmed = __TS__StringTrim(text) -- 504
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 504
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 506
	end -- 506
	return text -- 508
end -- 503
local function readSimpleXMLTagName(source, openStart, openEnd) -- 511
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 512
	if rawTag == "" then -- 512
		return { -- 514
			success = false, -- 514
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 514
		} -- 514
	end -- 514
	local selfClosing = false -- 516
	local tagText = rawTag -- 517
	if __TS__StringEndsWith(tagText, "/") then -- 517
		selfClosing = true -- 519
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 520
	end -- 520
	local tagName = "" -- 522
	do -- 522
		local i = 0 -- 523
		while i < #tagText do -- 523
			local ch = __TS__StringAccess(tagText, i) -- 524
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 524
				break -- 525
			end -- 525
			tagName = tagName .. ch -- 526
			i = i + 1 -- 523
		end -- 523
	end -- 523
	if tagName == "" then -- 523
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 529
	end -- 529
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 531
end -- 511
local function findMatchingXMLClose(source, tagName, contentStart) -- 534
	local sameOpenPrefix = "<" .. tagName -- 535
	local sameCloseToken = ("</" .. tagName) .. ">" -- 536
	local pos = contentStart -- 537
	local depth = 1 -- 538
	while pos < #source do -- 538
		do -- 538
			local lt = (string.find( -- 540
				source, -- 540
				"<", -- 540
				math.max(pos + 1, 1), -- 540
				true -- 540
			) or 0) - 1 -- 540
			if lt < 0 then -- 540
				break -- 541
			end -- 541
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 541
				local cdataEnd = (string.find( -- 543
					source, -- 543
					"]]>", -- 543
					math.max(lt + 9 + 1, 1), -- 543
					true -- 543
				) or 0) - 1 -- 543
				if cdataEnd < 0 then -- 543
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 544
				end -- 544
				pos = cdataEnd + 3 -- 545
				goto __continue127 -- 546
			end -- 546
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 549
					source, -- 549
					"-->",
					math.max(lt + 4 + 1, 1), -- 549
					true -- 549
				) or 0) - 1 -- 549
				if commentEnd < 0 then -- 549
					return {success = false, message = "invalid xml: unterminated comment"} -- 550
				end -- 550
				pos = commentEnd + 3 -- 551
				goto __continue127 -- 552
			end -- 552
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 552
				depth = depth - 1 -- 555
				if depth == 0 then -- 555
					return {success = true, closeStart = lt} -- 556
				end -- 556
				pos = lt + #sameCloseToken -- 557
				goto __continue127 -- 558
			end -- 558
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 558
				local openEnd = (string.find( -- 561
					source, -- 561
					">", -- 561
					math.max(lt + 1, 1), -- 561
					true -- 561
				) or 0) - 1 -- 561
				if openEnd < 0 then -- 561
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 562
				end -- 562
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 563
				if not tagInfo.success then -- 563
					return tagInfo -- 564
				end -- 564
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 564
					depth = depth + 1 -- 566
				end -- 566
				pos = openEnd + 1 -- 568
				goto __continue127 -- 569
			end -- 569
			local genericEnd = (string.find( -- 571
				source, -- 571
				">", -- 571
				math.max(lt + 1, 1), -- 571
				true -- 571
			) or 0) - 1 -- 571
			if genericEnd < 0 then -- 571
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 572
			end -- 572
			pos = genericEnd + 1 -- 573
		end -- 573
		::__continue127:: -- 573
	end -- 573
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 575
end -- 534
function ____exports.extractXMLFromText(text) -- 578
	local source = __TS__StringTrim(text) -- 579
	local function extractFencedBlock(fence) -- 580
		if not __TS__StringStartsWith(source, fence) then -- 580
			return nil -- 581
		end -- 581
		local firstLineEnd = (string.find( -- 582
			source, -- 582
			"\n", -- 582
			math.max(1, 1), -- 582
			true -- 582
		) or 0) - 1 -- 582
		if firstLineEnd < 0 then -- 582
			return nil -- 583
		end -- 583
		local searchPos = firstLineEnd + 1 -- 584
		local closingFencePositions = {} -- 585
		while searchPos < #source do -- 585
			local ____end = (string.find( -- 587
				source, -- 587
				"```", -- 587
				math.max(searchPos + 1, 1), -- 587
				true -- 587
			) or 0) - 1 -- 587
			if ____end < 0 then -- 587
				break -- 588
			end -- 588
			local lineStart = findLineStart(source, ____end - 1) -- 589
			local lineEnd = (string.find( -- 590
				source, -- 590
				"\n", -- 590
				math.max(____end + 1, 1), -- 590
				true -- 590
			) or 0) - 1 -- 590
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 591
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 591
				closingFencePositions[#closingFencePositions + 1] = ____end -- 593
			end -- 593
			searchPos = ____end + 1 -- 595
		end -- 595
		do -- 595
			local i = #closingFencePositions - 1 -- 597
			while i >= 0 do -- 597
				do -- 597
					local closingFencePos = closingFencePositions[i + 1] -- 598
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 599
					if afterFence ~= "" then -- 599
						goto __continue148 -- 600
					end -- 600
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 601
				end -- 601
				::__continue148:: -- 601
				i = i - 1 -- 597
			end -- 597
		end -- 597
		return nil -- 603
	end -- 580
	local xmlBlock = extractFencedBlock("```xml") -- 605
	if xmlBlock ~= nil then -- 605
		return xmlBlock -- 606
	end -- 606
	local genericBlock = extractFencedBlock("```") -- 607
	if genericBlock ~= nil then -- 607
		return genericBlock -- 608
	end -- 608
	return source -- 609
end -- 578
function ____exports.parseSimpleXMLChildren(source) -- 612
	local result = {} -- 613
	local pos = 0 -- 614
	while pos < #source do -- 614
		do -- 614
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 614
				pos = pos + 1 -- 616
			end -- 616
			if pos >= #source then -- 616
				break -- 617
			end -- 617
			if __TS__StringAccess(source, pos) ~= "<" then -- 617
				return { -- 619
					success = false, -- 619
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 619
				} -- 619
			end -- 619
			if __TS__StringStartsWith(source, "</", pos) then -- 619
				return { -- 622
					success = false, -- 622
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 622
				} -- 622
			end -- 622
			local openEnd = (string.find( -- 624
				source, -- 624
				">", -- 624
				math.max(pos + 1, 1), -- 624
				true -- 624
			) or 0) - 1 -- 624
			if openEnd < 0 then -- 624
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 626
			end -- 626
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 628
			if not tagInfo.success then -- 628
				return tagInfo -- 629
			end -- 629
			if tagInfo.selfClosing then -- 629
				result[tagInfo.tagName] = "" -- 631
				pos = openEnd + 1 -- 632
				goto __continue153 -- 633
			end -- 633
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 635
			if not closeRes.success then -- 635
				return closeRes -- 636
			end -- 636
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 637
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 638
			pos = closeRes.closeStart + #closeToken -- 639
		end -- 639
		::__continue153:: -- 639
	end -- 639
	return {success = true, obj = result} -- 641
end -- 612
function ____exports.parseXMLObjectFromText(text, rootTag) -- 644
	local xmlText = ____exports.extractXMLFromText(text) -- 645
	local rootOpen = ("<" .. rootTag) .. ">" -- 646
	local rootClose = ("</" .. rootTag) .. ">" -- 647
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 648
	local ____end = findLastLiteral(xmlText, rootClose) -- 649
	if start < 0 or ____end < start then -- 649
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 651
	end -- 651
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 653
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 654
	if beforeRoot ~= "" or afterRoot ~= "" then -- 654
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 656
	end -- 656
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 658
	return ____exports.parseSimpleXMLChildren(rootContent) -- 659
end -- 644
function ____exports.fitMessagesToContext(messages, options, config) -- 662
	local modelName = string.lower(config.model) -- 669
	local shouldEchoReasoningContent = __TS__ArraySome( -- 670
		messages, -- 670
		function(____, message) return type(message.reasoning_content) == "string" end -- 670
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 670
	local cloned = __TS__ArrayMap( -- 674
		messages, -- 674
		function(____, message) -- 674
			local clonedMessage = __TS__ObjectAssign({}, message) -- 675
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 675
				clonedMessage.reasoning_content = "" -- 681
			end -- 681
			return clonedMessage -- 683
		end -- 674
	) -- 674
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 685
	local originalTokens = estimateMessagesTokens(cloned) -- 686
	if originalTokens <= budgetTokens then -- 686
		return { -- 688
			messages = cloned, -- 689
			trimmed = false, -- 690
			originalTokens = originalTokens, -- 691
			fittedTokens = originalTokens, -- 692
			budgetTokens = budgetTokens -- 693
		} -- 693
	end -- 693
	local function roleOverhead(message) -- 697
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 697
	end -- 697
	local fixedOverhead = 0 -- 698
	local contentIndexes = {} -- 699
	do -- 699
		local i = 0 -- 700
		while i < #cloned do -- 700
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 701
			contentIndexes[#contentIndexes + 1] = i -- 702
			i = i + 1 -- 700
		end -- 700
	end -- 700
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 704
	if #contentIndexes == 1 then -- 704
		local idx = contentIndexes[1] -- 706
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 707
		local fittedTokens = estimateMessagesTokens(cloned) -- 708
		return { -- 709
			messages = cloned, -- 710
			trimmed = true, -- 711
			originalTokens = originalTokens, -- 712
			fittedTokens = fittedTokens, -- 713
			budgetTokens = budgetTokens -- 714
		} -- 714
	end -- 714
	local nonSystemIndexes = {} -- 718
	local systemIndexes = {} -- 719
	do -- 719
		local i = 0 -- 720
		while i < #cloned do -- 720
			if cloned[i + 1].role == "system" then -- 720
				systemIndexes[#systemIndexes + 1] = i -- 721
			else -- 721
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 722
			end -- 722
			i = i + 1 -- 720
		end -- 720
	end -- 720
	local ____array_1 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 720
	__TS__SparseArrayPush( -- 720
		____array_1, -- 720
		table.unpack(systemIndexes) -- 724
	) -- 724
	local priorityIndexes = {__TS__SparseArraySpread(____array_1)} -- 724
	local remainingContentBudget = contentBudget -- 725
	do -- 725
		local i = #priorityIndexes - 1 -- 726
		while i >= 0 do -- 726
			local idx = priorityIndexes[i + 1] -- 727
			local message = cloned[idx + 1] -- 728
			local minBudget = message.role == "system" and 96 or 192 -- 729
			local target = math.max( -- 730
				minBudget, -- 730
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 730
			) -- 730
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 731
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 732
			remainingContentBudget = math.max(0, remainingContentBudget) -- 733
			i = i - 1 -- 726
		end -- 726
	end -- 726
	local fittedTokens = estimateMessagesTokens(cloned) -- 736
	if fittedTokens > budgetTokens then -- 736
		do -- 736
			local i = 0 -- 738
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 738
				local idx = priorityIndexes[i + 1] -- 739
				local message = cloned[idx + 1] -- 740
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 741
				local excess = fittedTokens - budgetTokens -- 742
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 743
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 744
				fittedTokens = estimateMessagesTokens(cloned) -- 745
				i = i + 1 -- 738
			end -- 738
		end -- 738
	end -- 738
	if fittedTokens > budgetTokens then -- 738
		do -- 738
			local i = 0 -- 749
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 749
				do -- 749
					local idx = priorityIndexes[i + 1] -- 750
					if cloned[idx + 1].role == "system" then -- 750
						goto __continue185 -- 751
					end -- 751
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 752
					fittedTokens = estimateMessagesTokens(cloned) -- 753
				end -- 753
				::__continue185:: -- 753
				i = i + 1 -- 749
			end -- 749
		end -- 749
	end -- 749
	return { -- 756
		messages = cloned, -- 757
		trimmed = true, -- 758
		originalTokens = originalTokens, -- 759
		fittedTokens = fittedTokens, -- 760
		budgetTokens = budgetTokens -- 761
	} -- 761
end -- 662
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken) -- 765
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 776
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 777
	local data = __TS__ObjectAssign({}, requestOptions, {model = model, messages = messages, stream = stream}) -- 778
	if stopToken == nil then -- 778
		stopToken = {stopped = false} -- 784
	end -- 784
	return __TS__New( -- 785
		__TS__Promise, -- 785
		function(____, resolve, reject) -- 785
			local requestId = 0 -- 786
			local settled = false -- 787
			local function finishResolve(text) -- 788
				if settled then -- 788
					return -- 789
				end -- 789
				settled = true -- 790
				resolve(nil, text) -- 791
			end -- 788
			local function finishReject(err) -- 793
				if settled then -- 793
					return -- 794
				end -- 794
				settled = true -- 795
				reject(nil, err) -- 796
			end -- 793
			Director.systemScheduler:schedule(function() -- 798
				if not settled then -- 798
					if stopToken.stopped then -- 798
						if requestId ~= 0 then -- 798
							HttpClient:cancel(requestId) -- 802
							requestId = 0 -- 803
						end -- 803
						finishReject("request cancelled") -- 805
						return true -- 806
					end -- 806
					return false -- 808
				end -- 808
				return true -- 810
			end) -- 798
			Director.systemScheduler:schedule(once(function() -- 812
				emit( -- 813
					"LLM_IN", -- 813
					table.concat( -- 813
						__TS__ArrayMap( -- 813
							messages, -- 813
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 813
						), -- 813
						"\n" -- 813
					) -- 813
				) -- 813
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 814
				if jsonStr ~= nil then -- 814
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", receiver and "Accept: text/event-stream" or "Accept: application/json"} -- 816
					requestId = receiver and HttpClient:post( -- 821
						url, -- 822
						headers, -- 822
						jsonStr, -- 822
						requestTimeout, -- 822
						function(data) -- 822
							if stopToken.stopped then -- 822
								return true -- 823
							end -- 823
							return receiver(data) -- 824
						end, -- 822
						function(data) -- 825
							requestId = 0 -- 826
							if data ~= nil then -- 826
								finishResolve(data) -- 828
							else -- 828
								finishReject("failed to get http response") -- 830
							end -- 830
						end -- 825
					) or HttpClient:post( -- 825
						url, -- 833
						headers, -- 833
						jsonStr, -- 833
						requestTimeout, -- 833
						function(data) -- 833
							requestId = 0 -- 834
							if stopToken.stopped then -- 834
								finishReject("request cancelled") -- 836
								return -- 837
							end -- 837
							if data ~= nil then -- 837
								finishResolve(data) -- 840
							else -- 840
								finishReject("failed to get http response") -- 842
							end -- 842
						end -- 833
					) -- 833
					if requestId == 0 then -- 833
						finishReject("failed to schedule http request") -- 846
					elseif stopToken.stopped then -- 846
						HttpClient:cancel(requestId) -- 848
						requestId = 0 -- 849
						finishReject("request cancelled") -- 850
					end -- 850
				else -- 850
					finishReject(err) -- 853
				end -- 853
			end)) -- 812
		end -- 785
	) -- 785
end -- 765
function ____exports.createSSEJSONParser(opts) -- 863
	local buffer = "" -- 868
	local eventDataLines = {} -- 869
	local function flushEventIfAny() -- 871
		if #eventDataLines == 0 then -- 871
			return -- 872
		end -- 872
		local dataPayload = table.concat(eventDataLines, "\n") -- 874
		eventDataLines = {} -- 875
		if dataPayload == "[DONE]" then -- 875
			local ____opt_2 = opts.onDone -- 875
			if ____opt_2 ~= nil then -- 875
				____opt_2(dataPayload) -- 878
			end -- 878
			return -- 879
		end -- 879
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 882
		if err == nil then -- 882
			opts.onJSON(obj, dataPayload) -- 884
		else -- 884
			local ____opt_4 = opts.onError -- 884
			if ____opt_4 ~= nil then -- 884
				____opt_4(err, {raw = dataPayload}) -- 886
			end -- 886
		end -- 886
	end -- 871
	local function feed(chunk) -- 890
		buffer = buffer .. chunk -- 891
		while true do -- 891
			do -- 891
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 894
				if nl < 0 then -- 894
					break -- 895
				end -- 895
				local line = __TS__StringSlice(buffer, 0, nl) -- 897
				buffer = __TS__StringSlice(buffer, nl + 1) -- 898
				if __TS__StringEndsWith(line, "\r") then -- 898
					line = string.sub(line, 1, -2) -- 900
				end -- 900
				if line == "" then -- 900
					flushEventIfAny() -- 903
					goto __continue219 -- 904
				end -- 904
				if __TS__StringStartsWith(line, ":") then -- 904
					goto __continue219 -- 908
				end -- 908
				if __TS__StringStartsWith(line, "data:") then -- 908
					local v = string.sub(line, 6) -- 911
					if __TS__StringStartsWith(v, " ") then -- 911
						v = string.sub(v, 2) -- 912
					end -- 912
					eventDataLines[#eventDataLines + 1] = v -- 913
					goto __continue219 -- 914
				end -- 914
			end -- 914
			::__continue219:: -- 914
		end -- 914
	end -- 890
	local function ____end() -- 919
		if #buffer > 0 then -- 919
			local line = buffer -- 921
			buffer = "" -- 922
			if __TS__StringEndsWith(line, "\r") then -- 922
				line = string.sub(line, 1, -2) -- 923
			end -- 923
			if __TS__StringStartsWith(line, "data:") then -- 923
				local v = string.sub(line, 6) -- 926
				if __TS__StringStartsWith(v, " ") then -- 926
					v = string.sub(v, 2) -- 927
				end -- 927
				eventDataLines[#eventDataLines + 1] = v -- 928
			end -- 928
		end -- 928
		flushEventIfAny() -- 931
	end -- 919
	return {feed = feed, ["end"] = ____end} -- 934
end -- 863
function ____exports.extractLLMTokenUsage(response) -- 1028
	local usage = response and response.usage -- 1029
	if not usage or type(usage) ~= "table" then -- 1029
		return nil -- 1030
	end -- 1030
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1031
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1034
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1034
		return nil -- 1037
	end -- 1037
	local ____temp_13 -- 1038
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1038
		____temp_13 = usage.prompt_cache_hit_tokens -- 1039
	else -- 1039
		local ____temp_12 -- 1040
		local ____opt_8 = usage.prompt_tokens_details -- 1040
		if type(____opt_8 and ____opt_8.cached_tokens) == "number" then -- 1040
			____temp_12 = usage.prompt_tokens_details.cached_tokens -- 1041
		else -- 1041
			local ____opt_10 = usage.input_tokens_details -- 1041
			____temp_12 = type(____opt_10 and ____opt_10.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1042
		end -- 1042
		____temp_13 = ____temp_12 -- 1040
	end -- 1040
	local cachedInputTokens = ____temp_13 -- 1038
	local ____inputTokens_16 = inputTokens -- 1046
	local ____outputTokens_17 = outputTokens -- 1047
	local ____temp_18 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1048
	local ____temp_19 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1049
	local ____temp_20 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1050
	local ____opt_14 = usage.completion_tokens_details -- 1050
	return { -- 1045
		inputTokens = ____inputTokens_16, -- 1046
		outputTokens = ____outputTokens_17, -- 1047
		totalTokens = ____temp_18, -- 1048
		cachedInputTokens = ____temp_19, -- 1049
		cacheMissInputTokens = ____temp_20, -- 1050
		reasoningOutputTokens = type(____opt_14 and ____opt_14.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1053
	} -- 1053
end -- 1028
local function normalizeContextWindow(value) -- 1092
	if type(value) == "number" and value > 0 then -- 1092
		return math.floor(value) -- 1094
	end -- 1094
	return 64000 -- 1096
end -- 1092
local function normalizeSupportsFunctionCalling(value) -- 1099
	return value == nil or value ~= 0 -- 1100
end -- 1099
local function normalizeLLMTemperature(value) -- 1103
	if type(value) == "number" then -- 1103
		return math.max( -- 1105
			0, -- 1105
			math.min(2, value) -- 1105
		) -- 1105
	end -- 1105
	return 0.1 -- 1107
end -- 1103
local function normalizeLLMMaxTokens(value) -- 1110
	if type(value) == "number" then -- 1110
		return math.max( -- 1112
			1, -- 1112
			math.floor(value) -- 1112
		) -- 1112
	end -- 1112
	return 8192 -- 1114
end -- 1110
local function normalizeLLMCustomOptions(value) -- 1123
	if type(value) ~= "string" then -- 1123
		return nil -- 1124
	end -- 1124
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1125
	if text == "" then -- 1125
		return nil -- 1126
	end -- 1126
	local decoded = ____exports.safeJsonDecode(text) -- 1127
	return isPlainRecord(decoded) and decoded or nil -- 1128
end -- 1123
local function getLLMConfigRecords() -- 1148
	local rows = DB:query("select * from LLMConfig", true) -- 1149
	local records = {} -- 1150
	if rows and #rows > 1 then -- 1150
		do -- 1150
			local i = 1 -- 1152
			while i < #rows do -- 1152
				local record = {} -- 1153
				do -- 1153
					local c = 0 -- 1154
					while c < #rows[i + 1] do -- 1154
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1155
						c = c + 1 -- 1154
					end -- 1154
				end -- 1154
				records[#records + 1] = record -- 1157
				i = i + 1 -- 1152
			end -- 1152
		end -- 1152
	end -- 1152
	return records -- 1160
end -- 1148
local function parseLLMConfig(config) -- 1163
	if not config then -- 1163
		return {success = false, message = "LLM config not found"} -- 1165
	end -- 1165
	local ____config_21 = config -- 1167
	local id = ____config_21.id -- 1167
	local url = ____config_21.url -- 1167
	local model = ____config_21.model -- 1167
	local api_key = ____config_21.api_key -- 1167
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1167
		return {success = false, message = "got invalid LLM config"} -- 1169
	end -- 1169
	return { -- 1171
		success = true, -- 1172
		config = { -- 1173
			url = url, -- 1174
			model = model, -- 1175
			apiKey = api_key, -- 1176
			contextWindow = normalizeContextWindow(config.context_window), -- 1177
			temperature = normalizeLLMTemperature(config.temperature), -- 1178
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1179
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1180
			customOptions = normalizeLLMCustomOptions(config.custom_options), -- 1181
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 1182
		} -- 1182
	} -- 1182
end -- 1163
function ____exports.getLLMConfig(configId) -- 1187
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1188
	if normalizedId == nil or normalizedId <= 0 then -- 1188
		return {success = false, message = "LLM config is not selected"} -- 1190
	end -- 1190
	return parseLLMConfig(__TS__ArrayFind( -- 1192
		getLLMConfigRecords(), -- 1192
		function(____, record) return record.id == normalizedId end -- 1192
	)) -- 1192
end -- 1187
function ____exports.getActiveLLMConfig() -- 1195
	local records = getLLMConfigRecords() -- 1196
	local config = __TS__ArrayFind( -- 1197
		records, -- 1197
		function(____, r) return r.active ~= 0 end -- 1197
	) -- 1197
	if not config then -- 1197
		return {success = false, message = "no active LLM config"} -- 1199
	end -- 1199
	return parseLLMConfig(config) -- 1201
end -- 1195
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1204
	local callEvent -- 1210
	if event.id ~= nil then -- 1210
		local id = event.id -- 1212
		callEvent = { -- 1213
			id = nil, -- 1214
			onData = function(data) -- 1215
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1216
				return event.stopToken.stopped -- 1217
			end, -- 1215
			onCancel = function(reason) -- 1219
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1220
			end, -- 1219
			onDone = function() -- 1222
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1223
			end -- 1222
		} -- 1222
	else -- 1222
		callEvent = event -- 1227
	end -- 1227
	local ____callEvent_22 = callEvent -- 1229
	local onData = ____callEvent_22.onData -- 1229
	local onDone = ____callEvent_22.onDone -- 1229
	local ____callEvent_23 = callEvent -- 1230
	local onCancel = ____callEvent_23.onCancel -- 1230
	local config = llmConfig or (function() -- 1231
		local configRes = ____exports.getActiveLLMConfig() -- 1232
		if not configRes.success then -- 1232
			if onCancel then -- 1232
				onCancel(configRes.message) -- 1234
			end -- 1234
			return nil -- 1235
		end -- 1235
		return configRes.config -- 1237
	end)() -- 1231
	if not config then -- 1231
		return {success = false, message = "no active LLM config"} -- 1240
	end -- 1240
	local url = config.url -- 1240
	local model = config.model -- 1240
	local apiKey = config.apiKey -- 1240
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1243
	if fitted.trimmed then -- 1243
		____exports.Log( -- 1245
			"Warn", -- 1245
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1245
		) -- 1245
	end -- 1245
	local stopLLM = false -- 1247
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 1248
		local result = onData(obj) -- 1250
		if result then -- 1250
			stopLLM = result -- 1251
		end -- 1251
	end}); -- 1249
	(function() -- 1254
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1254
			local ____try = __TS__AsyncAwaiter(function() -- 1254
				local ____array_25 = __TS__SparseArrayNew( -- 1254
					fitted.messages, -- 1256
					url, -- 1256
					apiKey, -- 1256
					model, -- 1256
					options, -- 1256
					true, -- 1256
					config.customOptions, -- 1256
					function(data) -- 1256
						if stopLLM then -- 1256
							if onCancel then -- 1256
								onCancel("LLM Stopped") -- 1259
								onCancel = nil -- 1260
							end -- 1260
							return true -- 1262
						end -- 1262
						parser.feed(data) -- 1264
						return false -- 1265
					end -- 1256
				) -- 1256
				local ____temp_24 -- 1266
				if event.stopToken ~= nil then -- 1266
					____temp_24 = event.stopToken -- 1266
				else -- 1266
					____temp_24 = nil -- 1266
				end -- 1266
				__TS__SparseArrayPush(____array_25, ____temp_24) -- 1266
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_25))) -- 1256
				parser["end"]() -- 1267
				if onDone then -- 1267
					onDone(result) -- 1269
				end -- 1269
			end) -- 1269
			____try = ____try.catch( -- 1269
				____try, -- 1269
				function(____, e) -- 1269
					return __TS__AsyncAwaiter(function() -- 1269
						stopLLM = true -- 1272
						if onCancel then -- 1272
							onCancel(tostring(e)) -- 1274
							onCancel = nil -- 1275
						end -- 1275
					end) -- 1275
				end -- 1275
			) -- 1275
			__TS__Await(____try) -- 1255
		end) -- 1255
	end)() -- 1254
	return {success = true} -- 1279
end -- 1204
local function mergeStreamToolCall(target, delta) -- 1282
	if type(delta.id) == "string" and delta.id ~= "" then -- 1282
		target.id = delta.id -- 1284
	end -- 1284
	if type(delta.type) == "string" and delta.type ~= "" then -- 1284
		target.type = delta.type -- 1287
	end -- 1287
	if delta["function"] then -- 1287
		if target["function"] == nil then -- 1287
			target["function"] = {} -- 1290
		end -- 1290
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1290
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1292
		end -- 1292
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1292
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1295
		end -- 1295
	end -- 1295
end -- 1282
local function isToolCallComplete(tc) -- 1300
	if type(tc.id) ~= "string" or tc.id == "" then -- 1300
		return false -- 1301
	end -- 1301
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1301
		return false -- 1302
	end -- 1302
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1302
		return false -- 1303
	end -- 1303
	local args = tc["function"].arguments -- 1304
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1304
		return false -- 1305
	end -- 1305
	local decoded = ____exports.safeJsonDecode(args) -- 1306
	return decoded ~= nil -- 1307
end -- 1300
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1310
	local delta = choice.delta or ({}) -- 1311
	local fullMessage = choice.message or ({}) -- 1312
	local message = acc.message -- 1313
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1314
	if type(role) == "string" and role ~= "" then -- 1314
		message.role = role -- 1318
	end -- 1318
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1320
	if type(content) == "string" and content ~= "" then -- 1320
		message.content = (message.content or "") .. content -- 1324
	end -- 1324
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1326
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1326
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1330
	end -- 1330
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1332
	if #toolCalls > 0 then -- 1332
		if message.tool_calls == nil then -- 1332
			message.tool_calls = {} -- 1336
		end -- 1336
		do -- 1336
			local i = 0 -- 1337
			while i < #toolCalls do -- 1337
				local item = toolCalls[i + 1] -- 1338
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1339
				local ____message_tool_calls_26, ____temp_27 = message.tool_calls, index + 1 -- 1339
				if ____message_tool_calls_26[____temp_27] == nil then -- 1339
					____message_tool_calls_26[____temp_27] = {} -- 1342
				end -- 1342
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1343
				if onToolCallReady and emittedToolCallIds then -- 1343
					local tc = message.tool_calls[index + 1] -- 1345
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1345
						emittedToolCallIds[tc.id] = true -- 1347
						onToolCallReady(tc) -- 1348
					end -- 1348
				end -- 1348
				i = i + 1 -- 1337
			end -- 1337
		end -- 1337
	end -- 1337
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1337
		acc.finish_reason = choice.finish_reason -- 1354
	end -- 1354
end -- 1310
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1358
	local indexes = __TS__ArraySort( -- 1367
		__TS__ArrayFilter( -- 1367
			__TS__ArrayMap( -- 1367
				__TS__ObjectKeys(states), -- 1367
				function(____, key) return __TS__Number(key) end -- 1368
			), -- 1368
			function(____, index) return __TS__NumberIsFinite(index) end -- 1369
		), -- 1369
		function(____, a, b) return a - b end -- 1370
	) -- 1370
	return { -- 1371
		id = id, -- 1372
		created = created, -- 1373
		object = object, -- 1374
		model = model, -- 1375
		choices = __TS__ArrayMap( -- 1376
			indexes, -- 1376
			function(____, index) -- 1376
				local state = states[index] -- 1377
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1378
			end -- 1376
		), -- 1376
		usage = usage, -- 1389
		error = providerError -- 1390
	} -- 1390
end -- 1358
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1394
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1394
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1405
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1406
		local resolvedConfig = config or (function() -- 1409
			local configRes = ____exports.getActiveLLMConfig() -- 1410
			if not configRes.success then -- 1410
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1412
				return nil -- 1413
			end -- 1413
			return configRes.config -- 1415
		end)() -- 1409
		if not resolvedConfig then -- 1409
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1409
		end -- 1409
		local url = resolvedConfig.url -- 1409
		local model = resolvedConfig.model -- 1409
		local apiKey = resolvedConfig.apiKey -- 1409
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1421
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1422
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1423
		local ____model_32 = model -- 1426
		local ____url_33 = url -- 1426
		local ____temp_34 = #messages -- 1426
		local ____tostring_29 = tostring -- 1426
		local ____options_max_tokens_28 = options.max_tokens -- 1426
		if ____options_max_tokens_28 == nil then -- 1426
			____options_max_tokens_28 = "unset" -- 1426
		end -- 1426
		local ____tostring_29_result_35 = ____tostring_29(____options_max_tokens_28) -- 1426
		local ____tostring_31 = tostring -- 1426
		local ____options_temperature_30 = options.temperature -- 1426
		if ____options_temperature_30 == nil then -- 1426
			____options_temperature_30 = "unset" -- 1426
		end -- 1426
		____exports.Log( -- 1426
			"Info", -- 1426
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_32) .. " url=") .. ____url_33) .. " messages=") .. tostring(____temp_34)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_29_result_35) .. " temperature=") .. ____tostring_31(____options_temperature_30)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1426
		) -- 1426
		if stopToken and stopToken.stopped then -- 1426
			local reason = stopToken.reason or "request cancelled" -- 1428
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1429
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1429
		end -- 1429
		local ____hasReturned, ____returnValue -- 1429
		local ____try = __TS__AsyncAwaiter(function() -- 1429
			local states = {} -- 1433
			local emittedToolCallIds = {} -- 1434
			local responseId = nil -- 1435
			local responseCreated = nil -- 1436
			local responseObject = nil -- 1437
			local providerError -- 1438
			local responseUsage -- 1439
			local httpChunkCount = 0 -- 1440
			local rawStreamBytes = 0 -- 1441
			local rawStreamPreview = "" -- 1442
			local sseJSONChunkCount = 0 -- 1443
			local choiceJSONChunkCount = 0 -- 1444
			local emptyChoicesChunkCount = 0 -- 1445
			local missingChoicesChunkCount = 0 -- 1446
			local parseErrorCount = 0 -- 1447
			local doneChunkSeen = false -- 1448
			local lastJSONPreview = "" -- 1449
			local parser = ____exports.createSSEJSONParser({ -- 1450
				onJSON = function(obj, raw) -- 1451
					sseJSONChunkCount = sseJSONChunkCount + 1 -- 1452
					lastJSONPreview = previewText(raw, 500) -- 1453
					if not obj or type(obj) ~= "table" then -- 1453
						return -- 1455
					end -- 1455
					local chunk = obj -- 1457
					if chunk.error then -- 1457
						providerError = chunk.error -- 1459
						____exports.Log( -- 1460
							"Warn", -- 1460
							"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1460
						) -- 1460
						return -- 1461
					end -- 1461
					responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1463
					responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1464
					responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1465
					if chunk.usage and type(chunk.usage) == "table" then -- 1465
						responseUsage = chunk.usage -- 1467
					end -- 1467
					local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1469
					if not __TS__ArrayIsArray(chunk.choices) then -- 1469
						missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1471
						if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1471
							____exports.Log( -- 1473
								"Warn", -- 1473
								"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1473
							) -- 1473
						end -- 1473
					elseif #choices == 0 then -- 1473
						emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1476
						if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1476
							____exports.Log( -- 1478
								"Warn", -- 1478
								"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1478
							) -- 1478
						end -- 1478
					else -- 1478
						choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1481
					end -- 1481
					do -- 1481
						local i = 0 -- 1483
						while i < #choices do -- 1483
							local choice = choices[i + 1] -- 1484
							local index = type(choice.index) == "number" and choice.index or i -- 1485
							if states[index] == nil then -- 1485
								states[index] = {index = index, message = {role = "assistant"}} -- 1486
							end -- 1486
							mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1490
							i = i + 1 -- 1483
						end -- 1483
					end -- 1483
					if onChunk ~= nil then -- 1483
						onChunk( -- 1492
							buildStreamResponse( -- 1493
								states, -- 1493
								model, -- 1493
								responseId, -- 1493
								responseCreated, -- 1493
								responseObject, -- 1493
								providerError, -- 1493
								responseUsage -- 1493
							), -- 1493
							{ -- 1494
								id = chunk.id or "", -- 1495
								created = chunk.created or 0, -- 1496
								object = chunk.object or "", -- 1497
								model = chunk.model or model, -- 1498
								choices = choices -- 1499
							} -- 1499
						) -- 1499
					end -- 1499
				end, -- 1451
				onDone = function() -- 1503
					doneChunkSeen = true -- 1504
				end, -- 1503
				onError = function(err, context) -- 1506
					parseErrorCount = parseErrorCount + 1 -- 1507
					____exports.Log( -- 1508
						"Warn", -- 1508
						(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1508
					) -- 1508
				end -- 1506
			}) -- 1506
			__TS__Await(postLLM( -- 1511
				fitted.messages, -- 1511
				url, -- 1511
				apiKey, -- 1511
				model, -- 1511
				options, -- 1511
				true, -- 1511
				resolvedConfig.customOptions, -- 1511
				function(data) -- 1511
					if stopToken and stopToken.stopped then -- 1511
						return true -- 1512
					end -- 1512
					httpChunkCount = httpChunkCount + 1 -- 1513
					rawStreamBytes = rawStreamBytes + #data -- 1514
					if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1514
						rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1516
					end -- 1516
					parser.feed(data) -- 1518
					return false -- 1519
				end, -- 1511
				stopToken -- 1520
			)) -- 1520
			parser["end"]() -- 1521
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1521
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1523
				if rawResponse and type(rawResponse) == "table" then -- 1523
					local rawResponseObj = rawResponse -- 1525
					if rawResponseObj.error then -- 1525
						providerError = rawResponseObj.error -- 1527
						lastJSONPreview = previewText( -- 1528
							normalizeLLMJSONResponse(rawStreamPreview), -- 1528
							500 -- 1528
						) -- 1528
						____exports.Log( -- 1529
							"Warn", -- 1529
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1529
						) -- 1529
					end -- 1529
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1529
						responseUsage = rawResponseObj.usage -- 1532
					end -- 1532
				end -- 1532
			end -- 1532
			local response = buildStreamResponse( -- 1536
				states, -- 1536
				model, -- 1536
				responseId, -- 1536
				responseCreated, -- 1536
				responseObject, -- 1536
				providerError, -- 1536
				responseUsage -- 1536
			) -- 1536
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1537
			local choiceCount = response.choices and #response.choices or 0 -- 1538
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1539
			____exports.Log( -- 1540
				"Info", -- 1540
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1540
			) -- 1540
			if not doneChunkSeen then -- 1540
				local rawPreview = previewText( -- 1542
					____exports.sanitizeUTF8(rawStreamPreview), -- 1542
					1200 -- 1542
				) -- 1542
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1543
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1544
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1545
				____hasReturned = true -- 1546
				____returnValue = { -- 1546
					success = false, -- 1547
					message = message, -- 1548
					raw = rawStreamPreview, -- 1549
					response = response, -- 1550
					tokenUsage = tokenUsage -- 1551
				} -- 1551
				return -- 1546
			end -- 1546
			if not response.choices or #response.choices == 0 then -- 1546
				local providerMessage = providerError and providerError.message or "" -- 1555
				local providerType = providerError and providerError.type or "" -- 1556
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1557
				local details = table.concat( -- 1560
					__TS__ArrayFilter( -- 1560
						{providerType, providerCode}, -- 1560
						function(____, part) return part ~= "" end -- 1560
					), -- 1560
					"/" -- 1560
				) -- 1560
				local rawPreview = previewText( -- 1561
					____exports.sanitizeUTF8(rawStreamPreview), -- 1561
					1200 -- 1561
				) -- 1561
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1562
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1563
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1566
				____hasReturned = true -- 1567
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1567
				return -- 1567
			end -- 1567
			____hasReturned = true -- 1574
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1574
			return -- 1574
		end) -- 1574
		____try = ____try.catch( -- 1574
			____try, -- 1574
			function(____, e) -- 1574
				return __TS__AsyncAwaiter(function() -- 1574
					if stopToken and stopToken.stopped then -- 1574
						local reason = stopToken.reason or "request cancelled" -- 1581
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1582
						____hasReturned = true -- 1583
						____returnValue = {success = false, message = reason} -- 1583
						return -- 1583
					end -- 1583
					____exports.Log( -- 1585
						"Error", -- 1585
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1585
					) -- 1585
					____hasReturned = true -- 1586
					____returnValue = { -- 1586
						success = false, -- 1586
						message = tostring(e) -- 1586
					} -- 1586
					return -- 1586
				end) -- 1586
			end -- 1586
		) -- 1586
		__TS__Await(____try) -- 1432
		if ____hasReturned then -- 1432
			return ____awaiter_resolve(nil, ____returnValue) -- 1432
		end -- 1432
	end) -- 1432
end -- 1394
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1590
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1590
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1596
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1597
		local resolvedConfig = config or (function() -- 1600
			local configRes = ____exports.getActiveLLMConfig() -- 1601
			if not configRes.success then -- 1601
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1603
				return nil -- 1604
			end -- 1604
			return configRes.config -- 1606
		end)() -- 1600
		if not resolvedConfig then -- 1600
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1600
		end -- 1600
		local url = resolvedConfig.url -- 1600
		local model = resolvedConfig.model -- 1600
		local apiKey = resolvedConfig.apiKey -- 1600
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1612
		____exports.Log( -- 1613
			"Info", -- 1613
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1613
		) -- 1613
		if stopToken and stopToken.stopped then -- 1613
			local reason = stopToken.reason or "request cancelled" -- 1615
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1616
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1616
		end -- 1616
		local ____hasReturned, ____returnValue -- 1616
		local ____try = __TS__AsyncAwaiter(function() -- 1616
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1620
				fitted.messages, -- 1620
				url, -- 1620
				apiKey, -- 1620
				model, -- 1620
				options, -- 1620
				false, -- 1620
				resolvedConfig.customOptions, -- 1620
				nil, -- 1620
				stopToken -- 1620
			))) -- 1620
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1621
			____exports.Log( -- 1622
				"Info", -- 1622
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1622
			) -- 1622
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1623
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1623
				local rawPreview = previewText(raw) -- 1625
				____exports.Log( -- 1626
					"Error", -- 1626
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1626
				) -- 1626
				____hasReturned = true -- 1627
				____returnValue = { -- 1627
					success = false, -- 1628
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1629
					raw = raw -- 1630
				} -- 1630
				return -- 1627
			end -- 1627
			local responseObj = response -- 1633
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1634
			____exports.Log( -- 1635
				"Info", -- 1635
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1635
			) -- 1635
			if not responseObj.choices or #responseObj.choices == 0 then -- 1635
				local providerError = responseObj.error -- 1637
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1638
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1641
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1644
				local details = table.concat( -- 1647
					__TS__ArrayFilter( -- 1647
						{providerType, providerCode}, -- 1647
						function(____, part) return part ~= "" end -- 1647
					), -- 1647
					"/" -- 1647
				) -- 1647
				local rawPreview = previewText(raw, 400) -- 1648
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1649
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1652
				____hasReturned = true -- 1653
				____returnValue = {success = false, message = message, raw = raw} -- 1653
				return -- 1653
			end -- 1653
			____hasReturned = true -- 1659
			____returnValue = {success = true, response = responseObj} -- 1659
			return -- 1659
		end) -- 1659
		____try = ____try.catch( -- 1659
			____try, -- 1659
			function(____, e) -- 1659
				return __TS__AsyncAwaiter(function() -- 1659
					if stopToken and stopToken.stopped then -- 1659
						local reason = stopToken.reason or "request cancelled" -- 1665
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1666
						____hasReturned = true -- 1667
						____returnValue = {success = false, message = reason} -- 1667
						return -- 1667
					end -- 1667
					____exports.Log( -- 1669
						"Error", -- 1669
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1669
					) -- 1669
					____hasReturned = true -- 1670
					____returnValue = { -- 1670
						success = false, -- 1670
						message = tostring(e) -- 1670
					} -- 1670
					return -- 1670
				end) -- 1670
			end -- 1670
		) -- 1670
		__TS__Await(____try) -- 1619
		if ____hasReturned then -- 1619
			return ____awaiter_resolve(nil, ____returnValue) -- 1619
		end -- 1619
	end) -- 1619
end -- 1590
return ____exports -- 1590