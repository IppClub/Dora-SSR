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
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap -- 1
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
local AgentConfig = require("Agent.Config") -- 3
function ____exports.sanitizeUTF8(text) -- 351
	if text == "" then -- 351
		return "" -- 352
	end -- 352
	local remaining = text -- 353
	local output = "" -- 354
	while remaining ~= "" do -- 354
		local len, invalidPos = utf8.len(remaining) -- 356
		if len ~= nil then -- 356
			output = output .. remaining -- 358
			break -- 359
		end -- 359
		local badPos = type(invalidPos) == "number" and invalidPos or 1 -- 361
		if badPos > 1 then -- 361
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1) -- 363
		end -- 363
		remaining = __TS__StringSubstring(remaining, badPos) -- 365
	end -- 365
	return output -- 367
end -- 351
function normalizeReasoningEffort(value) -- 1210
	if type(value) ~= "string" then -- 1210
		return nil -- 1211
	end -- 1211
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1212
	return normalized ~= "" and normalized or nil -- 1213
end -- 1213
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1224
	if not customOptions then -- 1224
		return options -- 1228
	end -- 1228
	local merged = __TS__ObjectAssign({}, options) -- 1229
	for key in pairs(customOptions) do -- 1230
		do -- 1230
			if key == "auxiliaryOptions" then -- 1230
				goto __continue266 -- 1233
			end -- 1233
			local value = customOptions[key] -- 1234
			if value == json.null then -- 1234
				__TS__Delete(merged, key) -- 1236
			else -- 1236
				merged[key] = value -- 1238
			end -- 1238
		end -- 1238
		::__continue266:: -- 1238
	end -- 1238
	return merged -- 1241
end -- 1224
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
local STUDIO_MODEL_REQUEST_COUNTER = 0 -- 48
local function toBase36(value) -- 50
	if value <= 0 then -- 50
		return "0" -- 51
	end -- 51
	local remaining = math.floor(value) -- 52
	local out = "" -- 53
	while remaining > 0 do -- 53
		local digit = remaining % 36 -- 55
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out -- 56
		remaining = math.floor(remaining / 36) -- 57
	end -- 57
	return out -- 59
end -- 50
function ____exports.createLocalToolCallId() -- 62
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1 -- 63
	local timePart = toBase36(os.time()) -- 64
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER) -- 65
	return ("tc" .. timePart) .. counterPart -- 66
end -- 62
function ____exports.createStudioModelRequestId() -- 69
	STUDIO_MODEL_REQUEST_COUNTER = STUDIO_MODEL_REQUEST_COUNTER + 1 -- 70
	return ((("mr" .. toBase36(os.time())) .. toBase36(STUDIO_MODEL_REQUEST_COUNTER)) .. toBase36(math.floor(math.random() * 1000000000))) .. toBase36(math.floor(math.random() * 1000000000)) -- 73
end -- 69
local function normalizeCompletionText(value) -- 107
	if type(value) ~= "string" then -- 107
		return "" -- 108
	end -- 108
	return __TS__StringSlice( -- 109
		__TS__StringTrim(____exports.sanitizeUTF8(value)), -- 109
		0, -- 109
		AgentConfig.AGENT_LIMITS.completionTextMaxChars -- 109
	) -- 109
end -- 107
local function normalizeCompletionTextList(value, maxItems) -- 112
	if maxItems == nil then -- 112
		maxItems = AgentConfig.AGENT_LIMITS.completionListMaxItems -- 114
	end -- 114
	if not __TS__ArrayIsArray(value) then -- 114
		return {} -- 116
	end -- 116
	local items = {} -- 117
	do -- 117
		local i = 0 -- 118
		while i < #value and #items < maxItems do -- 118
			local item = normalizeCompletionText(value[i + 1]) -- 119
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 119
				items[#items + 1] = item -- 120
			end -- 120
			i = i + 1 -- 118
		end -- 118
	end -- 118
	return items -- 122
end -- 112
function ____exports.normalizeAgentCompletionReport(value) -- 125
	local row = value and not __TS__ArrayIsArray(value) and type(value) == "table" and value or ({}) -- 126
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 129
	local validation = {} -- 132
	if __TS__ArrayIsArray(row.validation) then -- 132
		do -- 132
			local i = 0 -- 134
			while i < #row.validation and #validation < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 134
				do -- 134
					local raw = row.validation[i + 1] -- 135
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 135
						goto __continue22 -- 136
					end -- 136
					local item = raw -- 137
					local kind = (item.kind == "runtime" or item.kind == "manual") and item.kind or (item.kind == "build" and "build" or nil) -- 138
					local result = (item.result == "passed" or item.result == "failed" or item.result == "not_run") and item.result or nil -- 139
					if kind == nil or result == nil then -- 139
						goto __continue22 -- 140
					end -- 140
					validation[#validation + 1] = { -- 141
						kind = kind, -- 142
						result = result, -- 143
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems) -- 144
					} -- 144
				end -- 144
				::__continue22:: -- 144
				i = i + 1 -- 134
			end -- 134
		end -- 134
	end -- 134
	local learningCandidates = {} -- 148
	if __TS__ArrayIsArray(row.learningCandidates) then -- 148
		do -- 148
			local i = 0 -- 150
			while i < #row.learningCandidates and #learningCandidates < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 150
				do -- 150
					local raw = row.learningCandidates[i + 1] -- 151
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 151
						goto __continue27 -- 152
					end -- 152
					local item = raw -- 153
					local claim = normalizeCompletionText(item.claim) -- 154
					if claim == "" then -- 154
						goto __continue27 -- 155
					end -- 155
					learningCandidates[#learningCandidates + 1] = { -- 156
						claim = claim, -- 157
						scope = (item.scope == "file" or item.scope == "engine") and item.scope or "project", -- 158
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems), -- 159
						confidence = item.confidence == "inferred" and "inferred" or "observed" -- 160
					} -- 160
				end -- 160
				::__continue27:: -- 160
				i = i + 1 -- 150
			end -- 150
		end -- 150
	end -- 150
	return { -- 164
		outcome = outcome, -- 165
		budgetExhausted = row.budgetExhausted == true, -- 166
		validation = validation, -- 167
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 168
		assumptions = normalizeCompletionTextList(row.assumptions), -- 169
		learningCandidates = learningCandidates -- 170
	} -- 170
end -- 125
function ____exports.replaceFirst(text, oldStr, newStr) -- 178
	if oldStr == "" then -- 178
		return text -- 179
	end -- 179
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 180
	if idx < 0 then -- 180
		return text -- 181
	end -- 181
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 182
end -- 178
local function getLeadingWhitespace(text) -- 185
	local i = 0 -- 186
	while i < #text do -- 186
		local ch = __TS__StringAccess(text, i) -- 188
		if ch ~= " " and ch ~= "\t" then -- 188
			break -- 189
		end -- 189
		i = i + 1 -- 190
	end -- 190
	return __TS__StringSubstring(text, 0, i) -- 192
end -- 185
local function getCommonIndentPrefix(lines) -- 195
	local common -- 196
	do -- 196
		local i = 0 -- 197
		while i < #lines do -- 197
			do -- 197
				local line = lines[i + 1] -- 198
				if __TS__StringTrim(line) == "" then -- 198
					goto __continue38 -- 199
				end -- 199
				local indent = getLeadingWhitespace(line) -- 200
				if common == nil then -- 200
					common = indent -- 202
					goto __continue38 -- 203
				end -- 203
				local j = 0 -- 205
				local maxLen = math.min(#common, #indent) -- 206
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 206
					j = j + 1 -- 208
				end -- 208
				common = __TS__StringSubstring(common, 0, j) -- 210
				if common == "" then -- 210
					break -- 211
				end -- 211
			end -- 211
			::__continue38:: -- 211
			i = i + 1 -- 197
		end -- 197
	end -- 197
	return common or "" -- 213
end -- 195
local function removeIndentPrefix(line, indent) -- 216
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 216
		return __TS__StringSubstring(line, #indent) -- 218
	end -- 218
	local lineIndent = getLeadingWhitespace(line) -- 220
	local j = 0 -- 221
	local maxLen = math.min(#lineIndent, #indent) -- 222
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 222
		j = j + 1 -- 224
	end -- 224
	return __TS__StringSubstring(line, j) -- 226
end -- 216
local function dedentLines(lines) -- 229
	local indent = getCommonIndentPrefix(lines) -- 230
	return { -- 231
		indent = indent, -- 232
		lines = __TS__ArrayMap( -- 233
			lines, -- 233
			function(____, line) return removeIndentPrefix(line, indent) end -- 233
		) -- 233
	} -- 233
end -- 229
local function findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 237
	local function foldWhitespace(text, withMap) -- 243
		local parts = {} -- 244
		local map = {} -- 245
		local i = 0 -- 246
		while i < #text do -- 246
			local ch = __TS__StringAccess(text, i) -- 248
			if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 248
				local start = i -- 250
				while i < #text do -- 250
					local next = __TS__StringAccess(text, i) -- 252
					if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 252
						break -- 253
					end -- 253
					i = i + 1 -- 254
				end -- 254
				parts[#parts + 1] = " " -- 256
				if withMap then -- 256
					map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 257
				end -- 257
			else -- 257
				parts[#parts + 1] = ch -- 259
				if withMap then -- 259
					map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 260
				end -- 260
				i = i + 1 -- 261
			end -- 261
		end -- 261
		return { -- 264
			text = table.concat(parts, ""), -- 264
			map = map -- 264
		} -- 264
	end -- 243
	local foldedContent = foldWhitespace(content, true) -- 266
	local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 267
	if foldedOld == "" then -- 267
		return {success = false, message = "old_str not found in file"} -- 269
	end -- 269
	local matches = {} -- 271
	local pos = 0 -- 272
	while true do -- 272
		local idx = (string.find( -- 274
			foldedContent.text, -- 274
			foldedOld, -- 274
			math.max(pos + 1, 1), -- 274
			true -- 274
		) or 0) - 1 -- 274
		if idx < 0 then -- 274
			break -- 275
		end -- 275
		local lastIdx = idx + #foldedOld - 1 -- 276
		local startMap = foldedContent.map[idx + 1] -- 277
		local endMap = foldedContent.map[lastIdx + 1] -- 278
		if startMap ~= nil and endMap ~= nil then -- 278
			matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 280
		end -- 280
		pos = idx + #foldedOld -- 282
	end -- 282
	if #matches == 0 then -- 282
		return {success = false, message = "old_str not found in file"} -- 285
	end -- 285
	if #matches > 1 then -- 285
		return { -- 288
			success = false, -- 289
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 290
		} -- 290
	end -- 290
	local match = matches[1] -- 293
	return { -- 294
		success = true, -- 295
		content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 296
	} -- 296
end -- 237
function ____exports.findIndentTolerantReplacement(content, oldStr, newStr) -- 300
	local contentLines = __TS__StringSplit(content, "\n") -- 305
	local oldLines = __TS__StringSplit(oldStr, "\n") -- 306
	if #oldLines == 0 then -- 306
		return {success = false, message = "old_str not found in file"} -- 308
	end -- 308
	local dedentedOld = dedentLines(oldLines) -- 310
	local dedentedOldText = table.concat(dedentedOld.lines, "\n") -- 311
	local dedentedNew = dedentLines(__TS__StringSplit(newStr, "\n")) -- 312
	local matches = {} -- 313
	do -- 313
		local start = 0 -- 314
		while start <= #contentLines - #oldLines do -- 314
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 315
			local dedentedCandidate = dedentLines(candidateLines) -- 316
			if table.concat(dedentedCandidate.lines, "\n") == dedentedOldText then -- 316
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 318
			end -- 318
			start = start + 1 -- 314
		end -- 314
	end -- 314
	if #matches == 0 then -- 314
		return findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 326
	end -- 326
	if #matches > 1 then -- 326
		return { -- 329
			success = false, -- 330
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 331
		} -- 331
	end -- 331
	local match = matches[1] -- 334
	local rebuiltNewLines = __TS__ArrayMap( -- 335
		dedentedNew.lines, -- 335
		function(____, line) return line == "" and "" or match.indent .. line end -- 335
	) -- 335
	local ____array_0 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 335
	__TS__SparseArrayPush( -- 335
		____array_0, -- 335
		table.unpack(rebuiltNewLines) -- 338
	) -- 338
	__TS__SparseArrayPush( -- 338
		____array_0, -- 338
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 339
	) -- 339
	local nextLines = {__TS__SparseArraySpread(____array_0)} -- 336
	return { -- 341
		success = true, -- 341
		content = table.concat(nextLines, "\n") -- 341
	} -- 341
end -- 300
local function previewText(text, maxLen) -- 344
	if maxLen == nil then -- 344
		maxLen = 200 -- 344
	end -- 344
	if text == "" then -- 344
		return "" -- 345
	end -- 345
	local compact = __TS__StringReplace( -- 346
		__TS__StringReplace(text, "\r", "\\r"), -- 346
		"\n", -- 346
		"\\n" -- 346
	) -- 346
	if #compact <= maxLen then -- 346
		return compact -- 347
	end -- 347
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 348
end -- 344
local function sanitizeJSONValue(value) -- 370
	if type(value) == "string" then -- 370
		return ____exports.sanitizeUTF8(value) -- 371
	end -- 371
	if __TS__ArrayIsArray(value) then -- 371
		return __TS__ArrayMap( -- 373
			value, -- 373
			function(____, item) return sanitizeJSONValue(item) end -- 373
		) -- 373
	end -- 373
	if value and type(value) == "table" then -- 373
		local result = {} -- 376
		for key in pairs(value) do -- 377
			result[key] = sanitizeJSONValue(value[key]) -- 378
		end -- 378
		return result -- 380
	end -- 380
	return value -- 382
end -- 370
function ____exports.safeJsonEncode(value, format, emptyAsArray, numAsStr, maxDepth) -- 385
	if format == nil then -- 385
		format = false -- 385
	end -- 385
	if emptyAsArray == nil then -- 385
		emptyAsArray = true -- 385
	end -- 385
	if numAsStr == nil then -- 385
		numAsStr = false -- 385
	end -- 385
	if maxDepth == nil then -- 385
		maxDepth = 128 -- 385
	end -- 385
	return json.encode( -- 386
		sanitizeJSONValue(value), -- 387
		format, -- 388
		emptyAsArray, -- 389
		numAsStr, -- 390
		maxDepth -- 391
	) -- 391
end -- 385
function ____exports.safeJsonDecode(text) -- 395
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 396
	if value == nil then -- 396
		return value, err -- 398
	end -- 398
	return sanitizeJSONValue(value), err -- 400
end -- 395
local function isPlainRecord(value) -- 403
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 404
end -- 403
local function normalizeLLMJSONResponse(text) -- 407
	return __TS__StringTrim(text) -- 408
end -- 407
local function utf8TakeHead(text, maxChars) -- 411
	if maxChars <= 0 or text == "" then -- 411
		return "" -- 412
	end -- 412
	local nextPos = utf8.offset(text, maxChars + 1) -- 413
	if nextPos == nil then -- 413
		return text -- 414
	end -- 414
	return string.sub(text, 1, nextPos - 1) -- 415
end -- 411
local function utf8TakeTail(text, maxChars) -- 418
	if maxChars <= 0 or text == "" then -- 418
		return "" -- 419
	end -- 419
	local charLen = utf8.len(text) -- 420
	if charLen == nil or charLen <= maxChars then -- 420
		return text -- 421
	end -- 421
	local startChar = math.max(1, charLen - maxChars + 1) -- 422
	local startPos = utf8.offset(text, startChar) -- 423
	if startPos == nil then -- 423
		return text -- 424
	end -- 424
	return string.sub(text, startPos) -- 425
end -- 418
function ____exports.estimateTextTokens(text) -- 428
	if text == "" then -- 428
		return 0 -- 429
	end -- 429
	return App:estimateTokens(text) -- 430
end -- 428
local function estimateMessagesTokens(messages) -- 433
	local total = 0 -- 434
	do -- 434
		local i = 0 -- 435
		while i < #messages do -- 435
			local message = messages[i + 1] -- 436
			total = total + 8 -- 437
			total = total + ____exports.estimateTextTokens(message.role or "") -- 438
			total = total + ____exports.estimateTextTokens(message.content or "") -- 439
			total = total + ____exports.estimateTextTokens(message.name or "") -- 440
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 441
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 442
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({})) -- 443
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 444
			i = i + 1 -- 435
		end -- 435
	end -- 435
	return total -- 446
end -- 433
local function estimateOptionsTokens(options) -- 449
	local text = ____exports.safeJsonEncode(options) -- 450
	return text and ____exports.estimateTextTokens(text) or 0 -- 451
end -- 449
local function getReservedOutputTokens(options, contextWindow) -- 454
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 455
	if explicitMax > 0 then -- 455
		return math.max(256, explicitMax) -- 460
	end -- 460
	return math.max( -- 461
		1024, -- 461
		math.floor(contextWindow * 0.2) -- 461
	) -- 461
end -- 454
local function getInputTokenBudget(messages, options, config) -- 464
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 465
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 468
	local optionTokens = estimateOptionsTokens(options) -- 469
	local structuralOverhead = math.max(256, #messages * 16) -- 470
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 471
end -- 464
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 474
	if budgetTokens <= 0 or text == "" then -- 474
		return "" -- 475
	end -- 475
	local estimated = ____exports.estimateTextTokens(text) -- 476
	if estimated <= budgetTokens then -- 476
		return text -- 477
	end -- 477
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 478
	local targetChars = math.max( -- 479
		200, -- 479
		math.floor(budgetTokens * charsPerToken) -- 479
	) -- 479
	local keepHead = math.max( -- 480
		0, -- 480
		math.floor(targetChars * 0.35) -- 480
	) -- 480
	local keepTail = math.max(0, targetChars - keepHead) -- 481
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 482
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 483
	return (head .. "\n...\n") .. tail -- 484
end -- 474
local function isXMLWhitespaceChar(ch) -- 487
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 488
end -- 487
local function findLineStart(value, from) -- 491
	local i = from -- 492
	while i >= 0 do -- 492
		if __TS__StringAccess(value, i) == "\n" then -- 492
			return i + 1 -- 494
		end -- 494
		i = i - 1 -- 495
	end -- 495
	return 0 -- 497
end -- 491
local function findLastLiteral(text, needle) -- 500
	if needle == "" then -- 500
		return #text -- 501
	end -- 501
	local last = -1 -- 502
	local from = 0 -- 503
	while from <= #text - #needle do -- 503
		local pos = (string.find( -- 505
			text, -- 505
			needle, -- 505
			math.max(from + 1, 1), -- 505
			true -- 505
		) or 0) - 1 -- 505
		if pos < 0 then -- 505
			break -- 506
		end -- 506
		last = pos -- 507
		from = pos + 1 -- 508
	end -- 508
	return last -- 510
end -- 500
local function unwrapXMLRawText(text) -- 513
	local trimmed = __TS__StringTrim(text) -- 514
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 514
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 516
	end -- 516
	return text -- 518
end -- 513
local function readSimpleXMLTagName(source, openStart, openEnd) -- 521
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 522
	if rawTag == "" then -- 522
		return { -- 524
			success = false, -- 524
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 524
		} -- 524
	end -- 524
	local selfClosing = false -- 526
	local tagText = rawTag -- 527
	if __TS__StringEndsWith(tagText, "/") then -- 527
		selfClosing = true -- 529
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 530
	end -- 530
	local tagName = "" -- 532
	do -- 532
		local i = 0 -- 533
		while i < #tagText do -- 533
			local ch = __TS__StringAccess(tagText, i) -- 534
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 534
				break -- 535
			end -- 535
			tagName = tagName .. ch -- 536
			i = i + 1 -- 533
		end -- 533
	end -- 533
	if tagName == "" then -- 533
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 539
	end -- 539
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 541
end -- 521
local function findMatchingXMLClose(source, tagName, contentStart) -- 544
	local sameOpenPrefix = "<" .. tagName -- 545
	local sameCloseToken = ("</" .. tagName) .. ">" -- 546
	local pos = contentStart -- 547
	local depth = 1 -- 548
	while pos < #source do -- 548
		do -- 548
			local lt = (string.find( -- 550
				source, -- 550
				"<", -- 550
				math.max(pos + 1, 1), -- 550
				true -- 550
			) or 0) - 1 -- 550
			if lt < 0 then -- 550
				break -- 551
			end -- 551
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 551
				local cdataEnd = (string.find( -- 553
					source, -- 553
					"]]>", -- 553
					math.max(lt + 9 + 1, 1), -- 553
					true -- 553
				) or 0) - 1 -- 553
				if cdataEnd < 0 then -- 553
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 554
				end -- 554
				pos = cdataEnd + 3 -- 555
				goto __continue128 -- 556
			end -- 556
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 559
					source, -- 559
					"-->",
					math.max(lt + 4 + 1, 1), -- 559
					true -- 559
				) or 0) - 1 -- 559
				if commentEnd < 0 then -- 559
					return {success = false, message = "invalid xml: unterminated comment"} -- 560
				end -- 560
				pos = commentEnd + 3 -- 561
				goto __continue128 -- 562
			end -- 562
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 562
				depth = depth - 1 -- 565
				if depth == 0 then -- 565
					return {success = true, closeStart = lt} -- 566
				end -- 566
				pos = lt + #sameCloseToken -- 567
				goto __continue128 -- 568
			end -- 568
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 568
				local openEnd = (string.find( -- 571
					source, -- 571
					">", -- 571
					math.max(lt + 1, 1), -- 571
					true -- 571
				) or 0) - 1 -- 571
				if openEnd < 0 then -- 571
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 572
				end -- 572
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 573
				if not tagInfo.success then -- 573
					return tagInfo -- 574
				end -- 574
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 574
					depth = depth + 1 -- 576
				end -- 576
				pos = openEnd + 1 -- 578
				goto __continue128 -- 579
			end -- 579
			local genericEnd = (string.find( -- 581
				source, -- 581
				">", -- 581
				math.max(lt + 1, 1), -- 581
				true -- 581
			) or 0) - 1 -- 581
			if genericEnd < 0 then -- 581
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 582
			end -- 582
			pos = genericEnd + 1 -- 583
		end -- 583
		::__continue128:: -- 583
	end -- 583
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 585
end -- 544
function ____exports.extractXMLFromText(text) -- 588
	local source = __TS__StringTrim(text) -- 589
	local function extractFencedBlock(fence) -- 590
		if not __TS__StringStartsWith(source, fence) then -- 590
			return nil -- 591
		end -- 591
		local firstLineEnd = (string.find( -- 592
			source, -- 592
			"\n", -- 592
			math.max(1, 1), -- 592
			true -- 592
		) or 0) - 1 -- 592
		if firstLineEnd < 0 then -- 592
			return nil -- 593
		end -- 593
		local searchPos = firstLineEnd + 1 -- 594
		local closingFencePositions = {} -- 595
		while searchPos < #source do -- 595
			local ____end = (string.find( -- 597
				source, -- 597
				"```", -- 597
				math.max(searchPos + 1, 1), -- 597
				true -- 597
			) or 0) - 1 -- 597
			if ____end < 0 then -- 597
				break -- 598
			end -- 598
			local lineStart = findLineStart(source, ____end - 1) -- 599
			local lineEnd = (string.find( -- 600
				source, -- 600
				"\n", -- 600
				math.max(____end + 1, 1), -- 600
				true -- 600
			) or 0) - 1 -- 600
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 601
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 601
				closingFencePositions[#closingFencePositions + 1] = ____end -- 603
			end -- 603
			searchPos = ____end + 1 -- 605
		end -- 605
		do -- 605
			local i = #closingFencePositions - 1 -- 607
			while i >= 0 do -- 607
				do -- 607
					local closingFencePos = closingFencePositions[i + 1] -- 608
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 609
					if afterFence ~= "" then -- 609
						goto __continue149 -- 610
					end -- 610
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 611
				end -- 611
				::__continue149:: -- 611
				i = i - 1 -- 607
			end -- 607
		end -- 607
		return nil -- 613
	end -- 590
	local xmlBlock = extractFencedBlock("```xml") -- 615
	if xmlBlock ~= nil then -- 615
		return xmlBlock -- 616
	end -- 616
	local genericBlock = extractFencedBlock("```") -- 617
	if genericBlock ~= nil then -- 617
		return genericBlock -- 618
	end -- 618
	return source -- 619
end -- 588
function ____exports.parseSimpleXMLChildren(source) -- 622
	local result = {} -- 623
	local pos = 0 -- 624
	while pos < #source do -- 624
		do -- 624
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 624
				pos = pos + 1 -- 626
			end -- 626
			if pos >= #source then -- 626
				break -- 627
			end -- 627
			if __TS__StringAccess(source, pos) ~= "<" then -- 627
				return { -- 629
					success = false, -- 629
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 629
				} -- 629
			end -- 629
			if __TS__StringStartsWith(source, "</", pos) then -- 629
				return { -- 632
					success = false, -- 632
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 632
				} -- 632
			end -- 632
			local openEnd = (string.find( -- 634
				source, -- 634
				">", -- 634
				math.max(pos + 1, 1), -- 634
				true -- 634
			) or 0) - 1 -- 634
			if openEnd < 0 then -- 634
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 636
			end -- 636
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 638
			if not tagInfo.success then -- 638
				return tagInfo -- 639
			end -- 639
			if tagInfo.selfClosing then -- 639
				result[tagInfo.tagName] = "" -- 641
				pos = openEnd + 1 -- 642
				goto __continue154 -- 643
			end -- 643
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 645
			if not closeRes.success then -- 645
				return closeRes -- 646
			end -- 646
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 647
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 648
			pos = closeRes.closeStart + #closeToken -- 649
		end -- 649
		::__continue154:: -- 649
	end -- 649
	return {success = true, obj = result} -- 651
end -- 622
function ____exports.parseXMLObjectFromText(text, rootTag) -- 654
	local xmlText = ____exports.extractXMLFromText(text) -- 655
	local rootOpen = ("<" .. rootTag) .. ">" -- 656
	local rootClose = ("</" .. rootTag) .. ">" -- 657
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 658
	local ____end = findLastLiteral(xmlText, rootClose) -- 659
	if start < 0 or ____end < start then -- 659
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 661
	end -- 661
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 663
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 664
	if beforeRoot ~= "" or afterRoot ~= "" then -- 664
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 666
	end -- 666
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 668
	return ____exports.parseSimpleXMLChildren(rootContent) -- 669
end -- 654
function ____exports.fitMessagesToContext(messages, options, config) -- 672
	local modelName = string.lower(config.model) -- 679
	local shouldEchoReasoningContent = __TS__ArraySome( -- 680
		messages, -- 680
		function(____, message) return type(message.reasoning_content) == "string" end -- 680
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 680
	local cloned = __TS__ArrayMap( -- 684
		messages, -- 684
		function(____, message) -- 684
			local clonedMessage = __TS__ObjectAssign({}, message) -- 685
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 685
				clonedMessage.reasoning_content = "" -- 691
			end -- 691
			return clonedMessage -- 693
		end -- 684
	) -- 684
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 695
	local originalTokens = estimateMessagesTokens(cloned) -- 696
	if originalTokens <= budgetTokens then -- 696
		return { -- 698
			messages = cloned, -- 699
			trimmed = false, -- 700
			originalTokens = originalTokens, -- 701
			fittedTokens = originalTokens, -- 702
			budgetTokens = budgetTokens -- 703
		} -- 703
	end -- 703
	local function roleOverhead(message) -- 707
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 707
	end -- 707
	local fixedOverhead = 0 -- 708
	local contentIndexes = {} -- 709
	do -- 709
		local i = 0 -- 710
		while i < #cloned do -- 710
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 711
			contentIndexes[#contentIndexes + 1] = i -- 712
			i = i + 1 -- 710
		end -- 710
	end -- 710
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 714
	if #contentIndexes == 1 then -- 714
		local idx = contentIndexes[1] -- 716
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 717
		local fittedTokens = estimateMessagesTokens(cloned) -- 718
		return { -- 719
			messages = cloned, -- 720
			trimmed = true, -- 721
			originalTokens = originalTokens, -- 722
			fittedTokens = fittedTokens, -- 723
			budgetTokens = budgetTokens -- 724
		} -- 724
	end -- 724
	local nonSystemIndexes = {} -- 728
	local systemIndexes = {} -- 729
	do -- 729
		local i = 0 -- 730
		while i < #cloned do -- 730
			if cloned[i + 1].role == "system" then -- 730
				systemIndexes[#systemIndexes + 1] = i -- 731
			else -- 731
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 732
			end -- 732
			i = i + 1 -- 730
		end -- 730
	end -- 730
	local ____array_1 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 730
	__TS__SparseArrayPush( -- 730
		____array_1, -- 730
		table.unpack(systemIndexes) -- 734
	) -- 734
	local priorityIndexes = {__TS__SparseArraySpread(____array_1)} -- 734
	local remainingContentBudget = contentBudget -- 735
	do -- 735
		local i = #priorityIndexes - 1 -- 736
		while i >= 0 do -- 736
			local idx = priorityIndexes[i + 1] -- 737
			local message = cloned[idx + 1] -- 738
			local minBudget = message.role == "system" and 96 or 192 -- 739
			local target = math.max( -- 740
				minBudget, -- 740
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 740
			) -- 740
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 741
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 742
			remainingContentBudget = math.max(0, remainingContentBudget) -- 743
			i = i - 1 -- 736
		end -- 736
	end -- 736
	local fittedTokens = estimateMessagesTokens(cloned) -- 746
	if fittedTokens > budgetTokens then -- 746
		do -- 746
			local i = 0 -- 748
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 748
				local idx = priorityIndexes[i + 1] -- 749
				local message = cloned[idx + 1] -- 750
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 751
				local excess = fittedTokens - budgetTokens -- 752
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 753
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 754
				fittedTokens = estimateMessagesTokens(cloned) -- 755
				i = i + 1 -- 748
			end -- 748
		end -- 748
	end -- 748
	if fittedTokens > budgetTokens then -- 748
		do -- 748
			local i = 0 -- 759
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 759
				do -- 759
					local idx = priorityIndexes[i + 1] -- 760
					if cloned[idx + 1].role == "system" then -- 760
						goto __continue186 -- 761
					end -- 761
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 762
					fittedTokens = estimateMessagesTokens(cloned) -- 763
				end -- 763
				::__continue186:: -- 763
				i = i + 1 -- 759
			end -- 759
		end -- 759
	end -- 759
	return { -- 766
		messages = cloned, -- 767
		trimmed = true, -- 768
		originalTokens = originalTokens, -- 769
		fittedTokens = fittedTokens, -- 770
		budgetTokens = budgetTokens -- 771
	} -- 771
end -- 672
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken, studioGateway) -- 775
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 787
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 788
	local data = __TS__ObjectAssign({}, requestOptions, {model = model, messages = messages, stream = stream}) -- 789
	local studioRequestId = studioGateway and ____exports.createStudioModelRequestId() or nil -- 795
	if stopToken == nil then -- 795
		stopToken = {stopped = false} -- 796
	end -- 796
	return __TS__New( -- 797
		__TS__Promise, -- 797
		function(____, resolve, reject) -- 797
			local requestId = 0 -- 798
			local settled = false -- 799
			local function finishResolve(text) -- 800
				if settled then -- 800
					return -- 801
				end -- 801
				settled = true -- 802
				resolve(nil, text) -- 803
			end -- 800
			local function finishReject(err) -- 805
				if settled then -- 805
					return -- 806
				end -- 806
				settled = true -- 807
				reject(nil, err) -- 808
			end -- 805
			Director.systemScheduler:schedule(function() -- 810
				if not settled then -- 810
					if stopToken.stopped then -- 810
						if requestId ~= 0 then -- 810
							HttpClient:cancel(requestId) -- 814
							requestId = 0 -- 815
						end -- 815
						finishReject("request cancelled") -- 817
						return true -- 818
					end -- 818
					return false -- 820
				end -- 820
				return true -- 822
			end) -- 810
			Director.systemScheduler:schedule(once(function() -- 824
				emit( -- 825
					"LLM_IN", -- 825
					table.concat( -- 825
						__TS__ArrayMap( -- 825
							messages, -- 825
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 825
						), -- 825
						"\n" -- 825
					) -- 825
				) -- 825
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 826
				if jsonStr ~= nil then -- 826
					local headers = { -- 828
						"Authorization: Bearer " .. apiKey, -- 829
						"Content-Type: application/json", -- 830
						receiver and "Accept: text/event-stream" or "Accept: application/json", -- 831
						table.unpack(studioRequestId and ({"X-Studio-Model-Request-Id: " .. studioRequestId}) or ({})) -- 832
					} -- 832
					requestId = receiver and HttpClient:post( -- 834
						url, -- 835
						headers, -- 835
						jsonStr, -- 835
						requestTimeout, -- 835
						function(data) -- 835
							if stopToken.stopped then -- 835
								return true -- 836
							end -- 836
							return receiver(data) -- 837
						end, -- 835
						function(data) -- 838
							requestId = 0 -- 839
							if data ~= nil then -- 839
								finishResolve(data) -- 841
							else -- 841
								finishReject("failed to get http response") -- 843
							end -- 843
						end -- 838
					) or HttpClient:post( -- 838
						url, -- 846
						headers, -- 846
						jsonStr, -- 846
						requestTimeout, -- 846
						function(data) -- 846
							requestId = 0 -- 847
							if stopToken.stopped then -- 847
								finishReject("request cancelled") -- 849
								return -- 850
							end -- 850
							if data ~= nil then -- 850
								finishResolve(data) -- 853
							else -- 853
								finishReject("failed to get http response") -- 855
							end -- 855
						end -- 846
					) -- 846
					if requestId == 0 then -- 846
						finishReject("failed to schedule http request") -- 859
					elseif stopToken.stopped then -- 859
						HttpClient:cancel(requestId) -- 861
						requestId = 0 -- 862
						finishReject("request cancelled") -- 863
					end -- 863
				else -- 863
					finishReject(err) -- 866
				end -- 866
			end)) -- 824
		end -- 797
	) -- 797
end -- 775
function ____exports.createSSEJSONParser(opts) -- 876
	local buffer = "" -- 881
	local eventDataLines = {} -- 882
	local function flushEventIfAny() -- 884
		if #eventDataLines == 0 then -- 884
			return -- 885
		end -- 885
		local dataPayload = table.concat(eventDataLines, "\n") -- 887
		eventDataLines = {} -- 888
		if dataPayload == "[DONE]" then -- 888
			local ____opt_2 = opts.onDone -- 888
			if ____opt_2 ~= nil then -- 888
				____opt_2(dataPayload) -- 891
			end -- 891
			return -- 892
		end -- 892
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 895
		if err == nil then -- 895
			opts.onJSON(obj, dataPayload) -- 897
		else -- 897
			local ____opt_4 = opts.onError -- 897
			if ____opt_4 ~= nil then -- 897
				____opt_4(err, {raw = dataPayload}) -- 899
			end -- 899
		end -- 899
	end -- 884
	local function append(chunk) -- 903
		buffer = buffer .. chunk -- 904
	end -- 903
	local function drain(maxLines) -- 907
		local processedLines = 0 -- 908
		while maxLines == nil or processedLines < maxLines do -- 908
			do -- 908
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 910
				if nl < 0 then -- 910
					break -- 911
				end -- 911
				processedLines = processedLines + 1 -- 912
				local line = __TS__StringSlice(buffer, 0, nl) -- 914
				buffer = __TS__StringSlice(buffer, nl + 1) -- 915
				if __TS__StringEndsWith(line, "\r") then -- 915
					line = string.sub(line, 1, -2) -- 917
				end -- 917
				if line == "" then -- 917
					flushEventIfAny() -- 920
					goto __continue221 -- 921
				end -- 921
				if __TS__StringStartsWith(line, ":") then -- 921
					goto __continue221 -- 925
				end -- 925
				if __TS__StringStartsWith(line, "data:") then -- 925
					local v = string.sub(line, 6) -- 928
					if __TS__StringStartsWith(v, " ") then -- 928
						v = string.sub(v, 2) -- 929
					end -- 929
					eventDataLines[#eventDataLines + 1] = v -- 930
					goto __continue221 -- 931
				end -- 931
			end -- 931
			::__continue221:: -- 931
		end -- 931
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0 -- 934
	end -- 907
	local function feed(chunk) -- 937
		append(chunk) -- 938
		drain() -- 939
	end -- 937
	local function ____end() -- 942
		if #buffer > 0 then -- 942
			local line = buffer -- 944
			buffer = "" -- 945
			if __TS__StringEndsWith(line, "\r") then -- 945
				line = string.sub(line, 1, -2) -- 946
			end -- 946
			if __TS__StringStartsWith(line, "data:") then -- 946
				local v = string.sub(line, 6) -- 949
				if __TS__StringStartsWith(v, " ") then -- 949
					v = string.sub(v, 2) -- 950
				end -- 950
				eventDataLines[#eventDataLines + 1] = v -- 951
			end -- 951
		end -- 951
		flushEventIfAny() -- 954
	end -- 942
	local function discard() -- 957
		buffer = "" -- 958
		eventDataLines = {} -- 959
	end -- 957
	return { -- 962
		append = append, -- 962
		drain = drain, -- 962
		feed = feed, -- 962
		["end"] = ____end, -- 962
		discard = discard -- 962
	} -- 962
end -- 876
local SSE_PARSE_LINES_PER_FRAME = 256 -- 965
local function createScheduledSSEJSONParser(opts, isCancelled) -- 967
	local parser = ____exports.createSSEJSONParser(opts) -- 971
	local inputFinished = false -- 972
	local settled = false -- 973
	local resolveFinished -- 974
	local finished = __TS__New( -- 975
		__TS__Promise, -- 975
		function(____, resolve) -- 975
			resolveFinished = resolve -- 976
		end -- 975
	) -- 975
	local function settle() -- 978
		if settled then -- 978
			return -- 979
		end -- 979
		settled = true -- 980
		if resolveFinished ~= nil then -- 980
			resolveFinished() -- 981
		end -- 981
	end -- 978
	Director.systemScheduler:schedule(function() -- 983
		if settled then -- 983
			return true -- 984
		end -- 984
		if isCancelled and isCancelled() then -- 984
			parser.discard() -- 986
			settle() -- 987
			return true -- 988
		end -- 988
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME) -- 990
		if inputFinished and not hasMoreCompleteLines then -- 990
			parser["end"]() -- 992
			settle() -- 993
			return true -- 994
		end -- 994
		return false -- 996
	end) -- 983
	return { -- 998
		append = parser.append, -- 999
		finish = function() -- 1000
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1000
				inputFinished = true -- 1001
				__TS__Await(finished) -- 1002
			end) -- 1002
		end, -- 1000
		cancel = function() -- 1004
			parser.discard() -- 1005
			settle() -- 1006
		end -- 1004
	} -- 1004
end -- 967
function ____exports.extractLLMTokenUsage(response) -- 1102
	local usage = response and response.usage -- 1103
	if not usage or type(usage) ~= "table" then -- 1103
		return nil -- 1104
	end -- 1104
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1105
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1108
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1108
		return nil -- 1111
	end -- 1111
	local ____temp_17 -- 1112
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1112
		____temp_17 = usage.prompt_cache_hit_tokens -- 1113
	else -- 1113
		local ____temp_16 -- 1114
		local ____opt_12 = usage.prompt_tokens_details -- 1114
		if type(____opt_12 and ____opt_12.cached_tokens) == "number" then -- 1114
			____temp_16 = usage.prompt_tokens_details.cached_tokens -- 1115
		else -- 1115
			local ____opt_14 = usage.input_tokens_details -- 1115
			____temp_16 = type(____opt_14 and ____opt_14.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1116
		end -- 1116
		____temp_17 = ____temp_16 -- 1114
	end -- 1114
	local cachedInputTokens = ____temp_17 -- 1112
	local ____inputTokens_20 = inputTokens -- 1120
	local ____outputTokens_21 = outputTokens -- 1121
	local ____temp_22 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1122
	local ____temp_23 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1123
	local ____temp_24 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1124
	local ____opt_18 = usage.completion_tokens_details -- 1124
	return { -- 1119
		inputTokens = ____inputTokens_20, -- 1120
		outputTokens = ____outputTokens_21, -- 1121
		totalTokens = ____temp_22, -- 1122
		cachedInputTokens = ____temp_23, -- 1123
		cacheMissInputTokens = ____temp_24, -- 1124
		reasoningOutputTokens = type(____opt_18 and ____opt_18.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1127
	} -- 1127
end -- 1102
function ____exports.validateAgentLLMConfig(config) -- 1172
	local ____opt_25 = config.customOptions -- 1172
	local auxiliaryOptions = ____opt_25 and ____opt_25.auxiliaryOptions -- 1173
	if isPlainRecord(auxiliaryOptions) then -- 1173
		for _key in pairs(auxiliaryOptions) do -- 1175
			return {success = true} -- 1176
		end -- 1176
	end -- 1176
	return {success = false, message = "LLM 配置的 customOptions 必须包含非空 auxiliaryOptions，请检查 LLM 配置"} -- 1179
end -- 1172
local function normalizeContextWindow(value) -- 1185
	if type(value) == "number" and value > 0 then -- 1185
		return math.floor(value) -- 1187
	end -- 1187
	return 64000 -- 1189
end -- 1185
local function normalizeSupportsFunctionCalling(value) -- 1192
	return value == nil or value ~= 0 -- 1193
end -- 1192
local function normalizeLLMTemperature(value) -- 1196
	if type(value) == "number" then -- 1196
		return math.max( -- 1198
			0, -- 1198
			math.min(2, value) -- 1198
		) -- 1198
	end -- 1198
	return 0.1 -- 1200
end -- 1196
local function normalizeLLMMaxTokens(value) -- 1203
	if type(value) == "number" then -- 1203
		return math.max( -- 1205
			1, -- 1205
			math.floor(value) -- 1205
		) -- 1205
	end -- 1205
	return 8192 -- 1207
end -- 1203
local function normalizeLLMCustomOptions(value) -- 1216
	if type(value) ~= "string" then -- 1216
		return nil -- 1217
	end -- 1217
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1218
	if text == "" then -- 1218
		return nil -- 1219
	end -- 1219
	local decoded = ____exports.safeJsonDecode(text) -- 1220
	return isPlainRecord(decoded) and decoded or nil -- 1221
end -- 1216
local function getLLMConfigRecords() -- 1244
	local rows = DB:query("select * from LLMConfig", true) -- 1245
	local records = {} -- 1246
	if rows and #rows > 1 then -- 1246
		do -- 1246
			local i = 1 -- 1248
			while i < #rows do -- 1248
				local record = {} -- 1249
				do -- 1249
					local c = 0 -- 1250
					while c < #rows[i + 1] do -- 1250
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1251
						c = c + 1 -- 1250
					end -- 1250
				end -- 1250
				records[#records + 1] = record -- 1253
				i = i + 1 -- 1248
			end -- 1248
		end -- 1248
	end -- 1248
	return records -- 1256
end -- 1244
function ____exports.getLLMConfigSummaries() -- 1266
	return __TS__ArrayFlatMap( -- 1267
		getLLMConfigRecords(), -- 1267
		function(____, record) -- 1267
			local id = record.id -- 1268
			local name = record.name -- 1269
			local model = record.model -- 1270
			if type(id) ~= "number" or type(name) ~= "string" or type(model) ~= "string" then -- 1270
				return {} -- 1271
			end -- 1271
			return {{id = id, name = name, model = model, active = record.active ~= 0}} -- 1272
		end -- 1267
	) -- 1267
end -- 1266
local function parseLLMConfig(config) -- 1276
	if not config then -- 1276
		return {success = false, message = "LLM config not found"} -- 1278
	end -- 1278
	local ____config_27 = config -- 1280
	local id = ____config_27.id -- 1280
	local url = ____config_27.url -- 1280
	local model = ____config_27.model -- 1280
	local api_key = ____config_27.api_key -- 1280
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1280
		return {success = false, message = "got invalid LLM config"} -- 1282
	end -- 1282
	return { -- 1284
		success = true, -- 1285
		id = id, -- 1286
		config = { -- 1287
			url = url, -- 1288
			model = model, -- 1289
			apiKey = api_key, -- 1290
			contextWindow = normalizeContextWindow(config.context_window), -- 1291
			temperature = normalizeLLMTemperature(config.temperature), -- 1292
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1293
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1294
			customOptions = normalizeLLMCustomOptions(config.custom_options), -- 1295
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 1296
		} -- 1296
	} -- 1296
end -- 1276
function ____exports.getLLMConfig(configId) -- 1301
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1302
	if normalizedId == nil or normalizedId <= 0 then -- 1302
		return {success = false, message = "LLM config is not selected"} -- 1304
	end -- 1304
	return parseLLMConfig(__TS__ArrayFind( -- 1306
		getLLMConfigRecords(), -- 1306
		function(____, record) return record.id == normalizedId end -- 1306
	)) -- 1306
end -- 1301
function ____exports.getActiveLLMConfig() -- 1309
	local records = getLLMConfigRecords() -- 1310
	local config = __TS__ArrayFind( -- 1311
		records, -- 1311
		function(____, r) return r.active ~= 0 end -- 1311
	) -- 1311
	if not config then -- 1311
		return {success = false, message = "no active LLM config"} -- 1313
	end -- 1313
	return parseLLMConfig(config) -- 1315
end -- 1309
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1318
	local callEvent -- 1324
	if event.id ~= nil then -- 1324
		local id = event.id -- 1326
		callEvent = { -- 1327
			id = nil, -- 1328
			onData = function(data) -- 1329
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1330
				return event.stopToken.stopped -- 1331
			end, -- 1329
			onCancel = function(reason) -- 1333
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1334
			end, -- 1333
			onDone = function() -- 1336
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1337
			end -- 1336
		} -- 1336
	else -- 1336
		callEvent = event -- 1341
	end -- 1341
	local ____callEvent_28 = callEvent -- 1343
	local onData = ____callEvent_28.onData -- 1343
	local onDone = ____callEvent_28.onDone -- 1343
	local ____callEvent_29 = callEvent -- 1344
	local onCancel = ____callEvent_29.onCancel -- 1344
	local config = llmConfig or (function() -- 1345
		local configRes = ____exports.getActiveLLMConfig() -- 1346
		if not configRes.success then -- 1346
			if onCancel then -- 1346
				onCancel(configRes.message) -- 1348
			end -- 1348
			return nil -- 1349
		end -- 1349
		return configRes.config -- 1351
	end)() -- 1345
	if not config then -- 1345
		return {success = false, message = "no active LLM config"} -- 1354
	end -- 1354
	local url = config.url -- 1354
	local model = config.model -- 1354
	local apiKey = config.apiKey -- 1354
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1357
	if fitted.trimmed then -- 1357
		____exports.Log( -- 1359
			"Warn", -- 1359
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1359
		) -- 1359
	end -- 1359
	local stopLLM = false -- 1361
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1362
	local parser = createScheduledSSEJSONParser( -- 1365
		{onJSON = function(obj) -- 1365
			local result = onData(obj) -- 1367
			if result then -- 1367
				stopLLM = true -- 1369
				streamStopToken.stopped = true -- 1370
				streamStopToken.reason = "LLM Stopped" -- 1371
			end -- 1371
		end}, -- 1366
		function() return streamStopToken.stopped end -- 1374
	); -- 1374
	(function() -- 1375
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1375
			local ____try = __TS__AsyncAwaiter(function() -- 1375
				local result = __TS__Await(postLLM( -- 1377
					fitted.messages, -- 1377
					url, -- 1377
					apiKey, -- 1377
					model, -- 1377
					options, -- 1377
					true, -- 1377
					config.customOptions, -- 1377
					function(data) -- 1377
						if stopLLM then -- 1377
							if onCancel then -- 1377
								onCancel("LLM Stopped") -- 1380
								onCancel = nil -- 1381
							end -- 1381
							return true -- 1383
						end -- 1383
						parser.append(data) -- 1385
						return false -- 1386
					end, -- 1377
					streamStopToken, -- 1387
					config.studioGateway -- 1387
				)) -- 1387
				__TS__Await(parser.finish()) -- 1388
				if onDone then -- 1388
					onDone(result) -- 1390
				end -- 1390
			end) -- 1390
			____try = ____try.catch( -- 1390
				____try, -- 1390
				function(____, e) -- 1390
					return __TS__AsyncAwaiter(function() -- 1390
						parser.cancel() -- 1393
						stopLLM = true -- 1394
						if onCancel then -- 1394
							onCancel(tostring(e)) -- 1396
							onCancel = nil -- 1397
						end -- 1397
					end) -- 1397
				end -- 1397
			) -- 1397
			__TS__Await(____try) -- 1376
		end) -- 1376
	end)() -- 1375
	return {success = true} -- 1401
end -- 1318
local function mergeStreamToolCall(target, delta) -- 1404
	if type(delta.id) == "string" and delta.id ~= "" then -- 1404
		target.id = delta.id -- 1406
	end -- 1406
	if type(delta.type) == "string" and delta.type ~= "" then -- 1406
		target.type = delta.type -- 1409
	end -- 1409
	if delta["function"] then -- 1409
		if target["function"] == nil then -- 1409
			target["function"] = {} -- 1412
		end -- 1412
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1412
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1414
		end -- 1414
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1414
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1417
		end -- 1417
	end -- 1417
end -- 1404
local function isToolCallComplete(tc) -- 1422
	if type(tc.id) ~= "string" or tc.id == "" then -- 1422
		return false -- 1423
	end -- 1423
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1423
		return false -- 1424
	end -- 1424
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1424
		return false -- 1425
	end -- 1425
	local args = tc["function"].arguments -- 1426
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1426
		return false -- 1427
	end -- 1427
	local decoded = ____exports.safeJsonDecode(args) -- 1428
	return decoded ~= nil -- 1429
end -- 1422
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1432
	local delta = choice.delta or ({}) -- 1433
	local fullMessage = choice.message or ({}) -- 1434
	local message = acc.message -- 1435
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1436
	if type(role) == "string" and role ~= "" then -- 1436
		message.role = role -- 1440
	end -- 1440
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1442
	if type(content) == "string" and content ~= "" then -- 1442
		message.content = (message.content or "") .. content -- 1446
	end -- 1446
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1448
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1448
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1452
	end -- 1452
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1454
	if #toolCalls > 0 then -- 1454
		if message.tool_calls == nil then -- 1454
			message.tool_calls = {} -- 1458
		end -- 1458
		do -- 1458
			local i = 0 -- 1459
			while i < #toolCalls do -- 1459
				local item = toolCalls[i + 1] -- 1460
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1461
				local ____message_tool_calls_30, ____temp_31 = message.tool_calls, index + 1 -- 1461
				if ____message_tool_calls_30[____temp_31] == nil then -- 1461
					____message_tool_calls_30[____temp_31] = {} -- 1464
				end -- 1464
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1465
				if onToolCallReady and emittedToolCallIds then -- 1465
					local tc = message.tool_calls[index + 1] -- 1467
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1467
						emittedToolCallIds[tc.id] = true -- 1469
						onToolCallReady(tc) -- 1470
					end -- 1470
				end -- 1470
				i = i + 1 -- 1459
			end -- 1459
		end -- 1459
	end -- 1459
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1459
		acc.finish_reason = choice.finish_reason -- 1476
	end -- 1476
end -- 1432
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1480
	local indexes = __TS__ArraySort( -- 1489
		__TS__ArrayFilter( -- 1489
			__TS__ArrayMap( -- 1489
				__TS__ObjectKeys(states), -- 1489
				function(____, key) return __TS__Number(key) end -- 1490
			), -- 1490
			function(____, index) return __TS__NumberIsFinite(index) end -- 1491
		), -- 1491
		function(____, a, b) return a - b end -- 1492
	) -- 1492
	return { -- 1493
		id = id, -- 1494
		created = created, -- 1495
		object = object, -- 1496
		model = model, -- 1497
		choices = __TS__ArrayMap( -- 1498
			indexes, -- 1498
			function(____, index) -- 1498
				local state = states[index] -- 1499
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1500
			end -- 1498
		), -- 1498
		usage = usage, -- 1511
		error = providerError -- 1512
	} -- 1512
end -- 1480
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1516
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1516
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1527
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1528
		local resolvedConfig = config or (function() -- 1531
			local configRes = ____exports.getActiveLLMConfig() -- 1532
			if not configRes.success then -- 1532
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1534
				return nil -- 1535
			end -- 1535
			return configRes.config -- 1537
		end)() -- 1531
		if not resolvedConfig then -- 1531
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1531
		end -- 1531
		local url = resolvedConfig.url -- 1531
		local model = resolvedConfig.model -- 1531
		local apiKey = resolvedConfig.apiKey -- 1531
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1543
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1544
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1545
		local ____model_36 = model -- 1548
		local ____url_37 = url -- 1548
		local ____temp_38 = #messages -- 1548
		local ____tostring_33 = tostring -- 1548
		local ____options_max_tokens_32 = options.max_tokens -- 1548
		if ____options_max_tokens_32 == nil then -- 1548
			____options_max_tokens_32 = "unset" -- 1548
		end -- 1548
		local ____tostring_33_result_39 = ____tostring_33(____options_max_tokens_32) -- 1548
		local ____tostring_35 = tostring -- 1548
		local ____options_temperature_34 = options.temperature -- 1548
		if ____options_temperature_34 == nil then -- 1548
			____options_temperature_34 = "unset" -- 1548
		end -- 1548
		____exports.Log( -- 1548
			"Info", -- 1548
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_36) .. " url=") .. ____url_37) .. " messages=") .. tostring(____temp_38)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_33_result_39) .. " temperature=") .. ____tostring_35(____options_temperature_34)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1548
		) -- 1548
		if stopToken and stopToken.stopped then -- 1548
			local reason = stopToken.reason or "request cancelled" -- 1550
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1551
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1551
		end -- 1551
		local ____hasReturned, ____returnValue -- 1551
		local ____try = __TS__AsyncAwaiter(function() -- 1551
			local states = {} -- 1555
			local emittedToolCallIds = {} -- 1556
			local responseId = nil -- 1557
			local responseCreated = nil -- 1558
			local responseObject = nil -- 1559
			local providerError -- 1560
			local responseUsage -- 1561
			local httpChunkCount = 0 -- 1562
			local rawStreamBytes = 0 -- 1563
			local rawStreamPreview = "" -- 1564
			local sseJSONChunkCount = 0 -- 1565
			local choiceJSONChunkCount = 0 -- 1566
			local emptyChoicesChunkCount = 0 -- 1567
			local missingChoicesChunkCount = 0 -- 1568
			local parseErrorCount = 0 -- 1569
			local doneChunkSeen = false -- 1570
			local lastJSONPreview = "" -- 1571
			local parser = createScheduledSSEJSONParser( -- 1572
				{ -- 1572
					onJSON = function(obj, raw) -- 1573
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1574
						lastJSONPreview = previewText(raw, 500) -- 1575
						if not obj or type(obj) ~= "table" then -- 1575
							return -- 1577
						end -- 1577
						local chunk = obj -- 1579
						if chunk.error then -- 1579
							providerError = chunk.error -- 1581
							____exports.Log( -- 1582
								"Warn", -- 1582
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1582
							) -- 1582
							return -- 1583
						end -- 1583
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1585
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1586
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1587
						if chunk.usage and type(chunk.usage) == "table" then -- 1587
							responseUsage = chunk.usage -- 1589
						end -- 1589
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1591
						if not __TS__ArrayIsArray(chunk.choices) then -- 1591
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1593
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1593
								____exports.Log( -- 1595
									"Warn", -- 1595
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1595
								) -- 1595
							end -- 1595
						elseif #choices == 0 then -- 1595
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1598
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1598
								____exports.Log( -- 1600
									"Warn", -- 1600
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1600
								) -- 1600
							end -- 1600
						else -- 1600
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1603
						end -- 1603
						do -- 1603
							local i = 0 -- 1605
							while i < #choices do -- 1605
								local choice = choices[i + 1] -- 1606
								local index = type(choice.index) == "number" and choice.index or i -- 1607
								if states[index] == nil then -- 1607
									states[index] = {index = index, message = {role = "assistant"}} -- 1608
								end -- 1608
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1612
								i = i + 1 -- 1605
							end -- 1605
						end -- 1605
						if onChunk ~= nil then -- 1605
							onChunk( -- 1614
								buildStreamResponse( -- 1615
									states, -- 1615
									model, -- 1615
									responseId, -- 1615
									responseCreated, -- 1615
									responseObject, -- 1615
									providerError, -- 1615
									responseUsage -- 1615
								), -- 1615
								{ -- 1616
									id = chunk.id or "", -- 1617
									created = chunk.created or 0, -- 1618
									object = chunk.object or "", -- 1619
									model = chunk.model or model, -- 1620
									choices = choices -- 1621
								} -- 1621
							) -- 1621
						end -- 1621
					end, -- 1573
					onDone = function() -- 1625
						doneChunkSeen = true -- 1626
					end, -- 1625
					onError = function(err, context) -- 1628
						parseErrorCount = parseErrorCount + 1 -- 1629
						____exports.Log( -- 1630
							"Warn", -- 1630
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1630
						) -- 1630
					end -- 1628
				}, -- 1628
				function() return (stopToken and stopToken.stopped) == true end -- 1632
			) -- 1632
			local ____try = __TS__AsyncAwaiter(function() -- 1632
				__TS__Await(postLLM( -- 1634
					fitted.messages, -- 1634
					url, -- 1634
					apiKey, -- 1634
					model, -- 1634
					options, -- 1634
					true, -- 1634
					resolvedConfig.customOptions, -- 1634
					function(data) -- 1634
						if stopToken and stopToken.stopped then -- 1634
							return true -- 1635
						end -- 1635
						httpChunkCount = httpChunkCount + 1 -- 1636
						rawStreamBytes = rawStreamBytes + #data -- 1637
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1637
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1639
						end -- 1639
						parser.append(data) -- 1641
						return false -- 1642
					end, -- 1634
					stopToken, -- 1643
					resolvedConfig.studioGateway -- 1643
				)) -- 1643
				__TS__Await(parser.finish()) -- 1644
			end) -- 1644
			____try = ____try.catch( -- 1644
				____try, -- 1644
				function(____, e) -- 1644
					return __TS__AsyncAwaiter(function() -- 1644
						parser.cancel() -- 1646
						error(e, 0) -- 1647
					end) -- 1647
				end -- 1647
			) -- 1647
			__TS__Await(____try) -- 1633
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1633
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1650
				if rawResponse and type(rawResponse) == "table" then -- 1650
					local rawResponseObj = rawResponse -- 1652
					if rawResponseObj.error then -- 1652
						providerError = rawResponseObj.error -- 1654
						lastJSONPreview = previewText( -- 1655
							normalizeLLMJSONResponse(rawStreamPreview), -- 1655
							500 -- 1655
						) -- 1655
						____exports.Log( -- 1656
							"Warn", -- 1656
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1656
						) -- 1656
					end -- 1656
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1656
						responseUsage = rawResponseObj.usage -- 1659
					end -- 1659
				end -- 1659
			end -- 1659
			local response = buildStreamResponse( -- 1663
				states, -- 1663
				model, -- 1663
				responseId, -- 1663
				responseCreated, -- 1663
				responseObject, -- 1663
				providerError, -- 1663
				responseUsage -- 1663
			) -- 1663
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1664
			local choiceCount = response.choices and #response.choices or 0 -- 1665
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1666
			____exports.Log( -- 1667
				"Info", -- 1667
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1667
			) -- 1667
			if not doneChunkSeen then -- 1667
				local rawPreview = previewText( -- 1669
					____exports.sanitizeUTF8(rawStreamPreview), -- 1669
					1200 -- 1669
				) -- 1669
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1670
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1671
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1672
				____hasReturned = true -- 1673
				____returnValue = { -- 1673
					success = false, -- 1674
					message = message, -- 1675
					raw = rawStreamPreview, -- 1676
					response = response, -- 1677
					tokenUsage = tokenUsage -- 1678
				} -- 1678
				return -- 1673
			end -- 1673
			if not response.choices or #response.choices == 0 then -- 1673
				local providerMessage = providerError and providerError.message or "" -- 1682
				local providerType = providerError and providerError.type or "" -- 1683
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1684
				local details = table.concat( -- 1687
					__TS__ArrayFilter( -- 1687
						{providerType, providerCode}, -- 1687
						function(____, part) return part ~= "" end -- 1687
					), -- 1687
					"/" -- 1687
				) -- 1687
				local rawPreview = previewText( -- 1688
					____exports.sanitizeUTF8(rawStreamPreview), -- 1688
					1200 -- 1688
				) -- 1688
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1689
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1690
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1693
				____hasReturned = true -- 1694
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1694
				return -- 1694
			end -- 1694
			____hasReturned = true -- 1701
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1701
			return -- 1701
		end) -- 1701
		____try = ____try.catch( -- 1701
			____try, -- 1701
			function(____, e) -- 1701
				return __TS__AsyncAwaiter(function() -- 1701
					if stopToken and stopToken.stopped then -- 1701
						local reason = stopToken.reason or "request cancelled" -- 1708
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1709
						____hasReturned = true -- 1710
						____returnValue = {success = false, message = reason} -- 1710
						return -- 1710
					end -- 1710
					____exports.Log( -- 1712
						"Error", -- 1712
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1712
					) -- 1712
					____hasReturned = true -- 1713
					____returnValue = { -- 1713
						success = false, -- 1713
						message = tostring(e) -- 1713
					} -- 1713
					return -- 1713
				end) -- 1713
			end -- 1713
		) -- 1713
		__TS__Await(____try) -- 1554
		if ____hasReturned then -- 1554
			return ____awaiter_resolve(nil, ____returnValue) -- 1554
		end -- 1554
	end) -- 1554
end -- 1516
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1717
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1717
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1723
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1724
		local resolvedConfig = config or (function() -- 1727
			local configRes = ____exports.getActiveLLMConfig() -- 1728
			if not configRes.success then -- 1728
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1730
				return nil -- 1731
			end -- 1731
			return configRes.config -- 1733
		end)() -- 1727
		if not resolvedConfig then -- 1727
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1727
		end -- 1727
		local url = resolvedConfig.url -- 1727
		local model = resolvedConfig.model -- 1727
		local apiKey = resolvedConfig.apiKey -- 1727
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1739
		____exports.Log( -- 1740
			"Info", -- 1740
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1740
		) -- 1740
		if stopToken and stopToken.stopped then -- 1740
			local reason = stopToken.reason or "request cancelled" -- 1742
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1743
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1743
		end -- 1743
		local ____hasReturned, ____returnValue -- 1743
		local ____try = __TS__AsyncAwaiter(function() -- 1743
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1747
				fitted.messages, -- 1747
				url, -- 1747
				apiKey, -- 1747
				model, -- 1747
				options, -- 1747
				false, -- 1747
				resolvedConfig.customOptions, -- 1747
				nil, -- 1747
				stopToken, -- 1747
				resolvedConfig.studioGateway -- 1747
			))) -- 1747
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1748
			____exports.Log( -- 1749
				"Info", -- 1749
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1749
			) -- 1749
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1750
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1750
				local rawPreview = previewText(raw) -- 1752
				____exports.Log( -- 1753
					"Error", -- 1753
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1753
				) -- 1753
				____hasReturned = true -- 1754
				____returnValue = { -- 1754
					success = false, -- 1755
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1756
					raw = raw -- 1757
				} -- 1757
				return -- 1754
			end -- 1754
			local responseObj = response -- 1760
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1761
			____exports.Log( -- 1762
				"Info", -- 1762
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1762
			) -- 1762
			if not responseObj.choices or #responseObj.choices == 0 then -- 1762
				local providerError = responseObj.error -- 1764
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1765
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1768
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1771
				local details = table.concat( -- 1774
					__TS__ArrayFilter( -- 1774
						{providerType, providerCode}, -- 1774
						function(____, part) return part ~= "" end -- 1774
					), -- 1774
					"/" -- 1774
				) -- 1774
				local rawPreview = previewText(raw, 400) -- 1775
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1776
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1779
				____hasReturned = true -- 1780
				____returnValue = {success = false, message = message, raw = raw} -- 1780
				return -- 1780
			end -- 1780
			____hasReturned = true -- 1786
			____returnValue = {success = true, response = responseObj} -- 1786
			return -- 1786
		end) -- 1786
		____try = ____try.catch( -- 1786
			____try, -- 1786
			function(____, e) -- 1786
				return __TS__AsyncAwaiter(function() -- 1786
					if stopToken and stopToken.stopped then -- 1786
						local reason = stopToken.reason or "request cancelled" -- 1792
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1793
						____hasReturned = true -- 1794
						____returnValue = {success = false, message = reason} -- 1794
						return -- 1794
					end -- 1794
					____exports.Log( -- 1796
						"Error", -- 1796
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1796
					) -- 1796
					____hasReturned = true -- 1797
					____returnValue = { -- 1797
						success = false, -- 1797
						message = tostring(e) -- 1797
					} -- 1797
					return -- 1797
				end) -- 1797
			end -- 1797
		) -- 1797
		__TS__Await(____try) -- 1746
		if ____hasReturned then -- 1746
			return ____awaiter_resolve(nil, ____returnValue) -- 1746
		end -- 1746
	end) -- 1746
end -- 1717
return ____exports -- 1717