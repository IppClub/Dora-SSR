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
function normalizeReasoningEffort(value) -- 1191
	if type(value) ~= "string" then -- 1191
		return nil -- 1192
	end -- 1192
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1193
	return normalized ~= "" and normalized or nil -- 1194
end -- 1194
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1205
	if not customOptions then -- 1205
		return options -- 1209
	end -- 1209
	local merged = __TS__ObjectAssign({}, options) -- 1210
	for key in pairs(customOptions) do -- 1211
		do -- 1211
			if key == "auxiliaryOptions" then -- 1211
				goto __continue265 -- 1214
			end -- 1214
			local value = customOptions[key] -- 1215
			if value == json.null then -- 1215
				__TS__Delete(merged, key) -- 1217
			else -- 1217
				merged[key] = value -- 1219
			end -- 1219
		end -- 1219
		::__continue265:: -- 1219
	end -- 1219
	return merged -- 1222
end -- 1205
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
	local function append(chunk) -- 890
		buffer = buffer .. chunk -- 891
	end -- 890
	local function drain(maxLines) -- 894
		local processedLines = 0 -- 895
		while maxLines == nil or processedLines < maxLines do -- 895
			do -- 895
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 897
				if nl < 0 then -- 897
					break -- 898
				end -- 898
				processedLines = processedLines + 1 -- 899
				local line = __TS__StringSlice(buffer, 0, nl) -- 901
				buffer = __TS__StringSlice(buffer, nl + 1) -- 902
				if __TS__StringEndsWith(line, "\r") then -- 902
					line = string.sub(line, 1, -2) -- 904
				end -- 904
				if line == "" then -- 904
					flushEventIfAny() -- 907
					goto __continue220 -- 908
				end -- 908
				if __TS__StringStartsWith(line, ":") then -- 908
					goto __continue220 -- 912
				end -- 912
				if __TS__StringStartsWith(line, "data:") then -- 912
					local v = string.sub(line, 6) -- 915
					if __TS__StringStartsWith(v, " ") then -- 915
						v = string.sub(v, 2) -- 916
					end -- 916
					eventDataLines[#eventDataLines + 1] = v -- 917
					goto __continue220 -- 918
				end -- 918
			end -- 918
			::__continue220:: -- 918
		end -- 918
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0 -- 921
	end -- 894
	local function feed(chunk) -- 924
		append(chunk) -- 925
		drain() -- 926
	end -- 924
	local function ____end() -- 929
		if #buffer > 0 then -- 929
			local line = buffer -- 931
			buffer = "" -- 932
			if __TS__StringEndsWith(line, "\r") then -- 932
				line = string.sub(line, 1, -2) -- 933
			end -- 933
			if __TS__StringStartsWith(line, "data:") then -- 933
				local v = string.sub(line, 6) -- 936
				if __TS__StringStartsWith(v, " ") then -- 936
					v = string.sub(v, 2) -- 937
				end -- 937
				eventDataLines[#eventDataLines + 1] = v -- 938
			end -- 938
		end -- 938
		flushEventIfAny() -- 941
	end -- 929
	local function discard() -- 944
		buffer = "" -- 945
		eventDataLines = {} -- 946
	end -- 944
	return { -- 949
		append = append, -- 949
		drain = drain, -- 949
		feed = feed, -- 949
		["end"] = ____end, -- 949
		discard = discard -- 949
	} -- 949
end -- 863
local SSE_PARSE_LINES_PER_FRAME = 256 -- 952
local function createScheduledSSEJSONParser(opts, isCancelled) -- 954
	local parser = ____exports.createSSEJSONParser(opts) -- 958
	local inputFinished = false -- 959
	local settled = false -- 960
	local resolveFinished -- 961
	local finished = __TS__New( -- 962
		__TS__Promise, -- 962
		function(____, resolve) -- 962
			resolveFinished = resolve -- 963
		end -- 962
	) -- 962
	local function settle() -- 965
		if settled then -- 965
			return -- 966
		end -- 966
		settled = true -- 967
		if resolveFinished ~= nil then -- 967
			resolveFinished() -- 968
		end -- 968
	end -- 965
	Director.systemScheduler:schedule(function() -- 970
		if settled then -- 970
			return true -- 971
		end -- 971
		if isCancelled and isCancelled() then -- 971
			parser.discard() -- 973
			settle() -- 974
			return true -- 975
		end -- 975
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME) -- 977
		if inputFinished and not hasMoreCompleteLines then -- 977
			parser["end"]() -- 979
			settle() -- 980
			return true -- 981
		end -- 981
		return false -- 983
	end) -- 970
	return { -- 985
		append = parser.append, -- 986
		finish = function() -- 987
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 987
				inputFinished = true -- 988
				__TS__Await(finished) -- 989
			end) -- 989
		end, -- 987
		cancel = function() -- 991
			parser.discard() -- 992
			settle() -- 993
		end -- 991
	} -- 991
end -- 954
function ____exports.extractLLMTokenUsage(response) -- 1089
	local usage = response and response.usage -- 1090
	if not usage or type(usage) ~= "table" then -- 1090
		return nil -- 1091
	end -- 1091
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1092
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1095
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1095
		return nil -- 1098
	end -- 1098
	local ____temp_17 -- 1099
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1099
		____temp_17 = usage.prompt_cache_hit_tokens -- 1100
	else -- 1100
		local ____temp_16 -- 1101
		local ____opt_12 = usage.prompt_tokens_details -- 1101
		if type(____opt_12 and ____opt_12.cached_tokens) == "number" then -- 1101
			____temp_16 = usage.prompt_tokens_details.cached_tokens -- 1102
		else -- 1102
			local ____opt_14 = usage.input_tokens_details -- 1102
			____temp_16 = type(____opt_14 and ____opt_14.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1103
		end -- 1103
		____temp_17 = ____temp_16 -- 1101
	end -- 1101
	local cachedInputTokens = ____temp_17 -- 1099
	local ____inputTokens_20 = inputTokens -- 1107
	local ____outputTokens_21 = outputTokens -- 1108
	local ____temp_22 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1109
	local ____temp_23 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1110
	local ____temp_24 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1111
	local ____opt_18 = usage.completion_tokens_details -- 1111
	return { -- 1106
		inputTokens = ____inputTokens_20, -- 1107
		outputTokens = ____outputTokens_21, -- 1108
		totalTokens = ____temp_22, -- 1109
		cachedInputTokens = ____temp_23, -- 1110
		cacheMissInputTokens = ____temp_24, -- 1111
		reasoningOutputTokens = type(____opt_18 and ____opt_18.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1114
	} -- 1114
end -- 1089
function ____exports.validateAgentLLMConfig(config) -- 1153
	local ____opt_25 = config.customOptions -- 1153
	local auxiliaryOptions = ____opt_25 and ____opt_25.auxiliaryOptions -- 1154
	if isPlainRecord(auxiliaryOptions) then -- 1154
		for _key in pairs(auxiliaryOptions) do -- 1156
			return {success = true} -- 1157
		end -- 1157
	end -- 1157
	return {success = false, message = "LLM 配置的 customOptions 必须包含非空 auxiliaryOptions，请检查 LLM 配置"} -- 1160
end -- 1153
local function normalizeContextWindow(value) -- 1166
	if type(value) == "number" and value > 0 then -- 1166
		return math.floor(value) -- 1168
	end -- 1168
	return 64000 -- 1170
end -- 1166
local function normalizeSupportsFunctionCalling(value) -- 1173
	return value == nil or value ~= 0 -- 1174
end -- 1173
local function normalizeLLMTemperature(value) -- 1177
	if type(value) == "number" then -- 1177
		return math.max( -- 1179
			0, -- 1179
			math.min(2, value) -- 1179
		) -- 1179
	end -- 1179
	return 0.1 -- 1181
end -- 1177
local function normalizeLLMMaxTokens(value) -- 1184
	if type(value) == "number" then -- 1184
		return math.max( -- 1186
			1, -- 1186
			math.floor(value) -- 1186
		) -- 1186
	end -- 1186
	return 8192 -- 1188
end -- 1184
local function normalizeLLMCustomOptions(value) -- 1197
	if type(value) ~= "string" then -- 1197
		return nil -- 1198
	end -- 1198
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1199
	if text == "" then -- 1199
		return nil -- 1200
	end -- 1200
	local decoded = ____exports.safeJsonDecode(text) -- 1201
	return isPlainRecord(decoded) and decoded or nil -- 1202
end -- 1197
local function getLLMConfigRecords() -- 1225
	local rows = DB:query("select * from LLMConfig", true) -- 1226
	local records = {} -- 1227
	if rows and #rows > 1 then -- 1227
		do -- 1227
			local i = 1 -- 1229
			while i < #rows do -- 1229
				local record = {} -- 1230
				do -- 1230
					local c = 0 -- 1231
					while c < #rows[i + 1] do -- 1231
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1232
						c = c + 1 -- 1231
					end -- 1231
				end -- 1231
				records[#records + 1] = record -- 1234
				i = i + 1 -- 1229
			end -- 1229
		end -- 1229
	end -- 1229
	return records -- 1237
end -- 1225
local function parseLLMConfig(config) -- 1240
	if not config then -- 1240
		return {success = false, message = "LLM config not found"} -- 1242
	end -- 1242
	local ____config_27 = config -- 1244
	local id = ____config_27.id -- 1244
	local url = ____config_27.url -- 1244
	local model = ____config_27.model -- 1244
	local api_key = ____config_27.api_key -- 1244
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1244
		return {success = false, message = "got invalid LLM config"} -- 1246
	end -- 1246
	return { -- 1248
		success = true, -- 1249
		config = { -- 1250
			url = url, -- 1251
			model = model, -- 1252
			apiKey = api_key, -- 1253
			contextWindow = normalizeContextWindow(config.context_window), -- 1254
			temperature = normalizeLLMTemperature(config.temperature), -- 1255
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1256
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1257
			customOptions = normalizeLLMCustomOptions(config.custom_options), -- 1258
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 1259
		} -- 1259
	} -- 1259
end -- 1240
function ____exports.getLLMConfig(configId) -- 1264
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1265
	if normalizedId == nil or normalizedId <= 0 then -- 1265
		return {success = false, message = "LLM config is not selected"} -- 1267
	end -- 1267
	return parseLLMConfig(__TS__ArrayFind( -- 1269
		getLLMConfigRecords(), -- 1269
		function(____, record) return record.id == normalizedId end -- 1269
	)) -- 1269
end -- 1264
function ____exports.getActiveLLMConfig() -- 1272
	local records = getLLMConfigRecords() -- 1273
	local config = __TS__ArrayFind( -- 1274
		records, -- 1274
		function(____, r) return r.active ~= 0 end -- 1274
	) -- 1274
	if not config then -- 1274
		return {success = false, message = "no active LLM config"} -- 1276
	end -- 1276
	return parseLLMConfig(config) -- 1278
end -- 1272
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1281
	local callEvent -- 1287
	if event.id ~= nil then -- 1287
		local id = event.id -- 1289
		callEvent = { -- 1290
			id = nil, -- 1291
			onData = function(data) -- 1292
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1293
				return event.stopToken.stopped -- 1294
			end, -- 1292
			onCancel = function(reason) -- 1296
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1297
			end, -- 1296
			onDone = function() -- 1299
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1300
			end -- 1299
		} -- 1299
	else -- 1299
		callEvent = event -- 1304
	end -- 1304
	local ____callEvent_28 = callEvent -- 1306
	local onData = ____callEvent_28.onData -- 1306
	local onDone = ____callEvent_28.onDone -- 1306
	local ____callEvent_29 = callEvent -- 1307
	local onCancel = ____callEvent_29.onCancel -- 1307
	local config = llmConfig or (function() -- 1308
		local configRes = ____exports.getActiveLLMConfig() -- 1309
		if not configRes.success then -- 1309
			if onCancel then -- 1309
				onCancel(configRes.message) -- 1311
			end -- 1311
			return nil -- 1312
		end -- 1312
		return configRes.config -- 1314
	end)() -- 1308
	if not config then -- 1308
		return {success = false, message = "no active LLM config"} -- 1317
	end -- 1317
	local url = config.url -- 1317
	local model = config.model -- 1317
	local apiKey = config.apiKey -- 1317
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1320
	if fitted.trimmed then -- 1320
		____exports.Log( -- 1322
			"Warn", -- 1322
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1322
		) -- 1322
	end -- 1322
	local stopLLM = false -- 1324
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1325
	local parser = createScheduledSSEJSONParser( -- 1328
		{onJSON = function(obj) -- 1328
			local result = onData(obj) -- 1330
			if result then -- 1330
				stopLLM = true -- 1332
				streamStopToken.stopped = true -- 1333
				streamStopToken.reason = "LLM Stopped" -- 1334
			end -- 1334
		end}, -- 1329
		function() return streamStopToken.stopped end -- 1337
	); -- 1337
	(function() -- 1338
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1338
			local ____try = __TS__AsyncAwaiter(function() -- 1338
				local result = __TS__Await(postLLM( -- 1340
					fitted.messages, -- 1340
					url, -- 1340
					apiKey, -- 1340
					model, -- 1340
					options, -- 1340
					true, -- 1340
					config.customOptions, -- 1340
					function(data) -- 1340
						if stopLLM then -- 1340
							if onCancel then -- 1340
								onCancel("LLM Stopped") -- 1343
								onCancel = nil -- 1344
							end -- 1344
							return true -- 1346
						end -- 1346
						parser.append(data) -- 1348
						return false -- 1349
					end, -- 1340
					streamStopToken -- 1350
				)) -- 1350
				__TS__Await(parser.finish()) -- 1351
				if onDone then -- 1351
					onDone(result) -- 1353
				end -- 1353
			end) -- 1353
			____try = ____try.catch( -- 1353
				____try, -- 1353
				function(____, e) -- 1353
					return __TS__AsyncAwaiter(function() -- 1353
						parser.cancel() -- 1356
						stopLLM = true -- 1357
						if onCancel then -- 1357
							onCancel(tostring(e)) -- 1359
							onCancel = nil -- 1360
						end -- 1360
					end) -- 1360
				end -- 1360
			) -- 1360
			__TS__Await(____try) -- 1339
		end) -- 1339
	end)() -- 1338
	return {success = true} -- 1364
end -- 1281
local function mergeStreamToolCall(target, delta) -- 1367
	if type(delta.id) == "string" and delta.id ~= "" then -- 1367
		target.id = delta.id -- 1369
	end -- 1369
	if type(delta.type) == "string" and delta.type ~= "" then -- 1369
		target.type = delta.type -- 1372
	end -- 1372
	if delta["function"] then -- 1372
		if target["function"] == nil then -- 1372
			target["function"] = {} -- 1375
		end -- 1375
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1375
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1377
		end -- 1377
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1377
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1380
		end -- 1380
	end -- 1380
end -- 1367
local function isToolCallComplete(tc) -- 1385
	if type(tc.id) ~= "string" or tc.id == "" then -- 1385
		return false -- 1386
	end -- 1386
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1386
		return false -- 1387
	end -- 1387
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1387
		return false -- 1388
	end -- 1388
	local args = tc["function"].arguments -- 1389
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1389
		return false -- 1390
	end -- 1390
	local decoded = ____exports.safeJsonDecode(args) -- 1391
	return decoded ~= nil -- 1392
end -- 1385
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1395
	local delta = choice.delta or ({}) -- 1396
	local fullMessage = choice.message or ({}) -- 1397
	local message = acc.message -- 1398
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1399
	if type(role) == "string" and role ~= "" then -- 1399
		message.role = role -- 1403
	end -- 1403
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1405
	if type(content) == "string" and content ~= "" then -- 1405
		message.content = (message.content or "") .. content -- 1409
	end -- 1409
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1411
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1411
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1415
	end -- 1415
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1417
	if #toolCalls > 0 then -- 1417
		if message.tool_calls == nil then -- 1417
			message.tool_calls = {} -- 1421
		end -- 1421
		do -- 1421
			local i = 0 -- 1422
			while i < #toolCalls do -- 1422
				local item = toolCalls[i + 1] -- 1423
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1424
				local ____message_tool_calls_30, ____temp_31 = message.tool_calls, index + 1 -- 1424
				if ____message_tool_calls_30[____temp_31] == nil then -- 1424
					____message_tool_calls_30[____temp_31] = {} -- 1427
				end -- 1427
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1428
				if onToolCallReady and emittedToolCallIds then -- 1428
					local tc = message.tool_calls[index + 1] -- 1430
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1430
						emittedToolCallIds[tc.id] = true -- 1432
						onToolCallReady(tc) -- 1433
					end -- 1433
				end -- 1433
				i = i + 1 -- 1422
			end -- 1422
		end -- 1422
	end -- 1422
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1422
		acc.finish_reason = choice.finish_reason -- 1439
	end -- 1439
end -- 1395
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1443
	local indexes = __TS__ArraySort( -- 1452
		__TS__ArrayFilter( -- 1452
			__TS__ArrayMap( -- 1452
				__TS__ObjectKeys(states), -- 1452
				function(____, key) return __TS__Number(key) end -- 1453
			), -- 1453
			function(____, index) return __TS__NumberIsFinite(index) end -- 1454
		), -- 1454
		function(____, a, b) return a - b end -- 1455
	) -- 1455
	return { -- 1456
		id = id, -- 1457
		created = created, -- 1458
		object = object, -- 1459
		model = model, -- 1460
		choices = __TS__ArrayMap( -- 1461
			indexes, -- 1461
			function(____, index) -- 1461
				local state = states[index] -- 1462
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1463
			end -- 1461
		), -- 1461
		usage = usage, -- 1474
		error = providerError -- 1475
	} -- 1475
end -- 1443
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1479
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1479
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1490
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1491
		local resolvedConfig = config or (function() -- 1494
			local configRes = ____exports.getActiveLLMConfig() -- 1495
			if not configRes.success then -- 1495
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1497
				return nil -- 1498
			end -- 1498
			return configRes.config -- 1500
		end)() -- 1494
		if not resolvedConfig then -- 1494
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1494
		end -- 1494
		local url = resolvedConfig.url -- 1494
		local model = resolvedConfig.model -- 1494
		local apiKey = resolvedConfig.apiKey -- 1494
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1506
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1507
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1508
		local ____model_36 = model -- 1511
		local ____url_37 = url -- 1511
		local ____temp_38 = #messages -- 1511
		local ____tostring_33 = tostring -- 1511
		local ____options_max_tokens_32 = options.max_tokens -- 1511
		if ____options_max_tokens_32 == nil then -- 1511
			____options_max_tokens_32 = "unset" -- 1511
		end -- 1511
		local ____tostring_33_result_39 = ____tostring_33(____options_max_tokens_32) -- 1511
		local ____tostring_35 = tostring -- 1511
		local ____options_temperature_34 = options.temperature -- 1511
		if ____options_temperature_34 == nil then -- 1511
			____options_temperature_34 = "unset" -- 1511
		end -- 1511
		____exports.Log( -- 1511
			"Info", -- 1511
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_36) .. " url=") .. ____url_37) .. " messages=") .. tostring(____temp_38)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_33_result_39) .. " temperature=") .. ____tostring_35(____options_temperature_34)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1511
		) -- 1511
		if stopToken and stopToken.stopped then -- 1511
			local reason = stopToken.reason or "request cancelled" -- 1513
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1514
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1514
		end -- 1514
		local ____hasReturned, ____returnValue -- 1514
		local ____try = __TS__AsyncAwaiter(function() -- 1514
			local states = {} -- 1518
			local emittedToolCallIds = {} -- 1519
			local responseId = nil -- 1520
			local responseCreated = nil -- 1521
			local responseObject = nil -- 1522
			local providerError -- 1523
			local responseUsage -- 1524
			local httpChunkCount = 0 -- 1525
			local rawStreamBytes = 0 -- 1526
			local rawStreamPreview = "" -- 1527
			local sseJSONChunkCount = 0 -- 1528
			local choiceJSONChunkCount = 0 -- 1529
			local emptyChoicesChunkCount = 0 -- 1530
			local missingChoicesChunkCount = 0 -- 1531
			local parseErrorCount = 0 -- 1532
			local doneChunkSeen = false -- 1533
			local lastJSONPreview = "" -- 1534
			local parser = createScheduledSSEJSONParser( -- 1535
				{ -- 1535
					onJSON = function(obj, raw) -- 1536
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1537
						lastJSONPreview = previewText(raw, 500) -- 1538
						if not obj or type(obj) ~= "table" then -- 1538
							return -- 1540
						end -- 1540
						local chunk = obj -- 1542
						if chunk.error then -- 1542
							providerError = chunk.error -- 1544
							____exports.Log( -- 1545
								"Warn", -- 1545
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1545
							) -- 1545
							return -- 1546
						end -- 1546
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1548
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1549
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1550
						if chunk.usage and type(chunk.usage) == "table" then -- 1550
							responseUsage = chunk.usage -- 1552
						end -- 1552
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1554
						if not __TS__ArrayIsArray(chunk.choices) then -- 1554
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1556
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1556
								____exports.Log( -- 1558
									"Warn", -- 1558
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1558
								) -- 1558
							end -- 1558
						elseif #choices == 0 then -- 1558
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1561
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1561
								____exports.Log( -- 1563
									"Warn", -- 1563
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1563
								) -- 1563
							end -- 1563
						else -- 1563
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1566
						end -- 1566
						do -- 1566
							local i = 0 -- 1568
							while i < #choices do -- 1568
								local choice = choices[i + 1] -- 1569
								local index = type(choice.index) == "number" and choice.index or i -- 1570
								if states[index] == nil then -- 1570
									states[index] = {index = index, message = {role = "assistant"}} -- 1571
								end -- 1571
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1575
								i = i + 1 -- 1568
							end -- 1568
						end -- 1568
						if onChunk ~= nil then -- 1568
							onChunk( -- 1577
								buildStreamResponse( -- 1578
									states, -- 1578
									model, -- 1578
									responseId, -- 1578
									responseCreated, -- 1578
									responseObject, -- 1578
									providerError, -- 1578
									responseUsage -- 1578
								), -- 1578
								{ -- 1579
									id = chunk.id or "", -- 1580
									created = chunk.created or 0, -- 1581
									object = chunk.object or "", -- 1582
									model = chunk.model or model, -- 1583
									choices = choices -- 1584
								} -- 1584
							) -- 1584
						end -- 1584
					end, -- 1536
					onDone = function() -- 1588
						doneChunkSeen = true -- 1589
					end, -- 1588
					onError = function(err, context) -- 1591
						parseErrorCount = parseErrorCount + 1 -- 1592
						____exports.Log( -- 1593
							"Warn", -- 1593
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1593
						) -- 1593
					end -- 1591
				}, -- 1591
				function() return (stopToken and stopToken.stopped) == true end -- 1595
			) -- 1595
			local ____try = __TS__AsyncAwaiter(function() -- 1595
				__TS__Await(postLLM( -- 1597
					fitted.messages, -- 1597
					url, -- 1597
					apiKey, -- 1597
					model, -- 1597
					options, -- 1597
					true, -- 1597
					resolvedConfig.customOptions, -- 1597
					function(data) -- 1597
						if stopToken and stopToken.stopped then -- 1597
							return true -- 1598
						end -- 1598
						httpChunkCount = httpChunkCount + 1 -- 1599
						rawStreamBytes = rawStreamBytes + #data -- 1600
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1600
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1602
						end -- 1602
						parser.append(data) -- 1604
						return false -- 1605
					end, -- 1597
					stopToken -- 1606
				)) -- 1606
				__TS__Await(parser.finish()) -- 1607
			end) -- 1607
			____try = ____try.catch( -- 1607
				____try, -- 1607
				function(____, e) -- 1607
					return __TS__AsyncAwaiter(function() -- 1607
						parser.cancel() -- 1609
						error(e, 0) -- 1610
					end) -- 1610
				end -- 1610
			) -- 1610
			__TS__Await(____try) -- 1596
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1596
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1613
				if rawResponse and type(rawResponse) == "table" then -- 1613
					local rawResponseObj = rawResponse -- 1615
					if rawResponseObj.error then -- 1615
						providerError = rawResponseObj.error -- 1617
						lastJSONPreview = previewText( -- 1618
							normalizeLLMJSONResponse(rawStreamPreview), -- 1618
							500 -- 1618
						) -- 1618
						____exports.Log( -- 1619
							"Warn", -- 1619
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1619
						) -- 1619
					end -- 1619
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1619
						responseUsage = rawResponseObj.usage -- 1622
					end -- 1622
				end -- 1622
			end -- 1622
			local response = buildStreamResponse( -- 1626
				states, -- 1626
				model, -- 1626
				responseId, -- 1626
				responseCreated, -- 1626
				responseObject, -- 1626
				providerError, -- 1626
				responseUsage -- 1626
			) -- 1626
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1627
			local choiceCount = response.choices and #response.choices or 0 -- 1628
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1629
			____exports.Log( -- 1630
				"Info", -- 1630
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1630
			) -- 1630
			if not doneChunkSeen then -- 1630
				local rawPreview = previewText( -- 1632
					____exports.sanitizeUTF8(rawStreamPreview), -- 1632
					1200 -- 1632
				) -- 1632
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1633
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1634
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1635
				____hasReturned = true -- 1636
				____returnValue = { -- 1636
					success = false, -- 1637
					message = message, -- 1638
					raw = rawStreamPreview, -- 1639
					response = response, -- 1640
					tokenUsage = tokenUsage -- 1641
				} -- 1641
				return -- 1636
			end -- 1636
			if not response.choices or #response.choices == 0 then -- 1636
				local providerMessage = providerError and providerError.message or "" -- 1645
				local providerType = providerError and providerError.type or "" -- 1646
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1647
				local details = table.concat( -- 1650
					__TS__ArrayFilter( -- 1650
						{providerType, providerCode}, -- 1650
						function(____, part) return part ~= "" end -- 1650
					), -- 1650
					"/" -- 1650
				) -- 1650
				local rawPreview = previewText( -- 1651
					____exports.sanitizeUTF8(rawStreamPreview), -- 1651
					1200 -- 1651
				) -- 1651
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1652
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1653
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1656
				____hasReturned = true -- 1657
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1657
				return -- 1657
			end -- 1657
			____hasReturned = true -- 1664
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1664
			return -- 1664
		end) -- 1664
		____try = ____try.catch( -- 1664
			____try, -- 1664
			function(____, e) -- 1664
				return __TS__AsyncAwaiter(function() -- 1664
					if stopToken and stopToken.stopped then -- 1664
						local reason = stopToken.reason or "request cancelled" -- 1671
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1672
						____hasReturned = true -- 1673
						____returnValue = {success = false, message = reason} -- 1673
						return -- 1673
					end -- 1673
					____exports.Log( -- 1675
						"Error", -- 1675
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1675
					) -- 1675
					____hasReturned = true -- 1676
					____returnValue = { -- 1676
						success = false, -- 1676
						message = tostring(e) -- 1676
					} -- 1676
					return -- 1676
				end) -- 1676
			end -- 1676
		) -- 1676
		__TS__Await(____try) -- 1517
		if ____hasReturned then -- 1517
			return ____awaiter_resolve(nil, ____returnValue) -- 1517
		end -- 1517
	end) -- 1517
end -- 1479
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1680
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1680
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1686
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1687
		local resolvedConfig = config or (function() -- 1690
			local configRes = ____exports.getActiveLLMConfig() -- 1691
			if not configRes.success then -- 1691
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1693
				return nil -- 1694
			end -- 1694
			return configRes.config -- 1696
		end)() -- 1690
		if not resolvedConfig then -- 1690
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1690
		end -- 1690
		local url = resolvedConfig.url -- 1690
		local model = resolvedConfig.model -- 1690
		local apiKey = resolvedConfig.apiKey -- 1690
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1702
		____exports.Log( -- 1703
			"Info", -- 1703
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1703
		) -- 1703
		if stopToken and stopToken.stopped then -- 1703
			local reason = stopToken.reason or "request cancelled" -- 1705
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1706
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1706
		end -- 1706
		local ____hasReturned, ____returnValue -- 1706
		local ____try = __TS__AsyncAwaiter(function() -- 1706
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1710
				fitted.messages, -- 1710
				url, -- 1710
				apiKey, -- 1710
				model, -- 1710
				options, -- 1710
				false, -- 1710
				resolvedConfig.customOptions, -- 1710
				nil, -- 1710
				stopToken -- 1710
			))) -- 1710
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1711
			____exports.Log( -- 1712
				"Info", -- 1712
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1712
			) -- 1712
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1713
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1713
				local rawPreview = previewText(raw) -- 1715
				____exports.Log( -- 1716
					"Error", -- 1716
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1716
				) -- 1716
				____hasReturned = true -- 1717
				____returnValue = { -- 1717
					success = false, -- 1718
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1719
					raw = raw -- 1720
				} -- 1720
				return -- 1717
			end -- 1717
			local responseObj = response -- 1723
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1724
			____exports.Log( -- 1725
				"Info", -- 1725
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1725
			) -- 1725
			if not responseObj.choices or #responseObj.choices == 0 then -- 1725
				local providerError = responseObj.error -- 1727
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1728
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1731
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1734
				local details = table.concat( -- 1737
					__TS__ArrayFilter( -- 1737
						{providerType, providerCode}, -- 1737
						function(____, part) return part ~= "" end -- 1737
					), -- 1737
					"/" -- 1737
				) -- 1737
				local rawPreview = previewText(raw, 400) -- 1738
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1739
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1742
				____hasReturned = true -- 1743
				____returnValue = {success = false, message = message, raw = raw} -- 1743
				return -- 1743
			end -- 1743
			____hasReturned = true -- 1749
			____returnValue = {success = true, response = responseObj} -- 1749
			return -- 1749
		end) -- 1749
		____try = ____try.catch( -- 1749
			____try, -- 1749
			function(____, e) -- 1749
				return __TS__AsyncAwaiter(function() -- 1749
					if stopToken and stopToken.stopped then -- 1749
						local reason = stopToken.reason or "request cancelled" -- 1755
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1756
						____hasReturned = true -- 1757
						____returnValue = {success = false, message = reason} -- 1757
						return -- 1757
					end -- 1757
					____exports.Log( -- 1759
						"Error", -- 1759
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1759
					) -- 1759
					____hasReturned = true -- 1760
					____returnValue = { -- 1760
						success = false, -- 1760
						message = tostring(e) -- 1760
					} -- 1760
					return -- 1760
				end) -- 1760
			end -- 1760
		) -- 1760
		__TS__Await(____try) -- 1709
		if ____hasReturned then -- 1709
			return ____awaiter_resolve(nil, ____returnValue) -- 1709
		end -- 1709
	end) -- 1709
end -- 1680
return ____exports -- 1680