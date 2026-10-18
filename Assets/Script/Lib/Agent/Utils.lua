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
local AgentConfig = require("Agent.Config.Defaults") -- 3
local ____LLMConfigMigration = require("Agent.Config.LLMConfigMigration") -- 4
local upgradeLLMConfig = ____LLMConfigMigration.upgradeLLMConfig -- 4
function ____exports.sanitizeUTF8(text) -- 352
	if text == "" then -- 352
		return "" -- 353
	end -- 353
	local remaining = text -- 354
	local output = "" -- 355
	while remaining ~= "" do -- 355
		local len, invalidPos = utf8.len(remaining) -- 357
		if len ~= nil then -- 357
			output = output .. remaining -- 359
			break -- 360
		end -- 360
		local badPos = type(invalidPos) == "number" and invalidPos or 1 -- 362
		if badPos > 1 then -- 362
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1) -- 364
		end -- 364
		remaining = __TS__StringSubstring(remaining, badPos) -- 366
	end -- 366
	return output -- 368
end -- 352
function normalizeReasoningEffort(value) -- 1211
	if type(value) ~= "string" then -- 1211
		return nil -- 1212
	end -- 1212
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1213
	return normalized ~= "" and normalized or nil -- 1214
end -- 1214
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1225
	if not customOptions then -- 1225
		return options -- 1229
	end -- 1229
	local merged = __TS__ObjectAssign({}, options) -- 1230
	for key in pairs(customOptions) do -- 1231
		do -- 1231
			if key == "auxiliaryOptions" then -- 1231
				goto __continue266 -- 1234
			end -- 1234
			local value = customOptions[key] -- 1235
			if value == json.null then -- 1235
				__TS__Delete(merged, key) -- 1237
			else -- 1237
				merged[key] = value -- 1239
			end -- 1239
		end -- 1239
		::__continue266:: -- 1239
	end -- 1239
	return merged -- 1242
end -- 1225
local LOG_LEVEL = App.debugging and 3 or 2 -- 6
function ____exports.setLogLevel(level) -- 7
	LOG_LEVEL = level -- 8
end -- 7
local LLM_TIMEOUT = 600 -- 11
local LLM_STREAM_TIMEOUT = 600 -- 12
local LLM_STREAM_RAW_DEBUG_MAX = 12000 -- 13
local LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT = 5 -- 14
____exports.Log = function(____type, msg) -- 16
	if LOG_LEVEL < 1 then -- 16
		return -- 17
	elseif LOG_LEVEL < 2 and (____type == "Info" or ____type == "Warn") then -- 17
		return -- 18
	elseif LOG_LEVEL < 3 and ____type == "Info" then -- 18
		return -- 19
	end -- 19
	DoraLog(____type, msg) -- 20
end -- 16
local TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz" -- 47
local TOOL_CALL_ID_COUNTER = 0 -- 48
local STUDIO_MODEL_REQUEST_COUNTER = 0 -- 49
local function toBase36(value) -- 51
	if value <= 0 then -- 51
		return "0" -- 52
	end -- 52
	local remaining = math.floor(value) -- 53
	local out = "" -- 54
	while remaining > 0 do -- 54
		local digit = remaining % 36 -- 56
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out -- 57
		remaining = math.floor(remaining / 36) -- 58
	end -- 58
	return out -- 60
end -- 51
function ____exports.createLocalToolCallId() -- 63
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1 -- 64
	local timePart = toBase36(os.time()) -- 65
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER) -- 66
	return ("tc" .. timePart) .. counterPart -- 67
end -- 63
function ____exports.createStudioModelRequestId() -- 70
	STUDIO_MODEL_REQUEST_COUNTER = STUDIO_MODEL_REQUEST_COUNTER + 1 -- 71
	return ((("mr" .. toBase36(os.time())) .. toBase36(STUDIO_MODEL_REQUEST_COUNTER)) .. toBase36(math.floor(math.random() * 1000000000))) .. toBase36(math.floor(math.random() * 1000000000)) -- 74
end -- 70
local function normalizeCompletionText(value) -- 108
	if type(value) ~= "string" then -- 108
		return "" -- 109
	end -- 109
	return __TS__StringSlice( -- 110
		__TS__StringTrim(____exports.sanitizeUTF8(value)), -- 110
		0, -- 110
		AgentConfig.AGENT_LIMITS.completionTextMaxChars -- 110
	) -- 110
end -- 108
local function normalizeCompletionTextList(value, maxItems) -- 113
	if maxItems == nil then -- 113
		maxItems = AgentConfig.AGENT_LIMITS.completionListMaxItems -- 115
	end -- 115
	if not __TS__ArrayIsArray(value) then -- 115
		return {} -- 117
	end -- 117
	local items = {} -- 118
	do -- 118
		local i = 0 -- 119
		while i < #value and #items < maxItems do -- 119
			local item = normalizeCompletionText(value[i + 1]) -- 120
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 120
				items[#items + 1] = item -- 121
			end -- 121
			i = i + 1 -- 119
		end -- 119
	end -- 119
	return items -- 123
end -- 113
function ____exports.normalizeAgentCompletionReport(value) -- 126
	local row = value and not __TS__ArrayIsArray(value) and type(value) == "table" and value or ({}) -- 127
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 130
	local validation = {} -- 133
	if __TS__ArrayIsArray(row.validation) then -- 133
		do -- 133
			local i = 0 -- 135
			while i < #row.validation and #validation < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 135
				do -- 135
					local raw = row.validation[i + 1] -- 136
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 136
						goto __continue22 -- 137
					end -- 137
					local item = raw -- 138
					local kind = (item.kind == "runtime" or item.kind == "manual") and item.kind or (item.kind == "build" and "build" or nil) -- 139
					local result = (item.result == "passed" or item.result == "failed" or item.result == "not_run") and item.result or nil -- 140
					if kind == nil or result == nil then -- 140
						goto __continue22 -- 141
					end -- 141
					validation[#validation + 1] = { -- 142
						kind = kind, -- 143
						result = result, -- 144
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems) -- 145
					} -- 145
				end -- 145
				::__continue22:: -- 145
				i = i + 1 -- 135
			end -- 135
		end -- 135
	end -- 135
	local learningCandidates = {} -- 149
	if __TS__ArrayIsArray(row.learningCandidates) then -- 149
		do -- 149
			local i = 0 -- 151
			while i < #row.learningCandidates and #learningCandidates < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 151
				do -- 151
					local raw = row.learningCandidates[i + 1] -- 152
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 152
						goto __continue27 -- 153
					end -- 153
					local item = raw -- 154
					local claim = normalizeCompletionText(item.claim) -- 155
					if claim == "" then -- 155
						goto __continue27 -- 156
					end -- 156
					learningCandidates[#learningCandidates + 1] = { -- 157
						claim = claim, -- 158
						scope = (item.scope == "file" or item.scope == "engine") and item.scope or "project", -- 159
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems), -- 160
						confidence = item.confidence == "inferred" and "inferred" or "observed" -- 161
					} -- 161
				end -- 161
				::__continue27:: -- 161
				i = i + 1 -- 151
			end -- 151
		end -- 151
	end -- 151
	return { -- 165
		outcome = outcome, -- 166
		budgetExhausted = row.budgetExhausted == true, -- 167
		validation = validation, -- 168
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 169
		assumptions = normalizeCompletionTextList(row.assumptions), -- 170
		learningCandidates = learningCandidates -- 171
	} -- 171
end -- 126
function ____exports.replaceFirst(text, oldStr, newStr) -- 179
	if oldStr == "" then -- 179
		return text -- 180
	end -- 180
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 181
	if idx < 0 then -- 181
		return text -- 182
	end -- 182
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 183
end -- 179
local function getLeadingWhitespace(text) -- 186
	local i = 0 -- 187
	while i < #text do -- 187
		local ch = __TS__StringAccess(text, i) -- 189
		if ch ~= " " and ch ~= "\t" then -- 189
			break -- 190
		end -- 190
		i = i + 1 -- 191
	end -- 191
	return __TS__StringSubstring(text, 0, i) -- 193
end -- 186
local function getCommonIndentPrefix(lines) -- 196
	local common -- 197
	do -- 197
		local i = 0 -- 198
		while i < #lines do -- 198
			do -- 198
				local line = lines[i + 1] -- 199
				if __TS__StringTrim(line) == "" then -- 199
					goto __continue38 -- 200
				end -- 200
				local indent = getLeadingWhitespace(line) -- 201
				if common == nil then -- 201
					common = indent -- 203
					goto __continue38 -- 204
				end -- 204
				local j = 0 -- 206
				local maxLen = math.min(#common, #indent) -- 207
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 207
					j = j + 1 -- 209
				end -- 209
				common = __TS__StringSubstring(common, 0, j) -- 211
				if common == "" then -- 211
					break -- 212
				end -- 212
			end -- 212
			::__continue38:: -- 212
			i = i + 1 -- 198
		end -- 198
	end -- 198
	return common or "" -- 214
end -- 196
local function removeIndentPrefix(line, indent) -- 217
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 217
		return __TS__StringSubstring(line, #indent) -- 219
	end -- 219
	local lineIndent = getLeadingWhitespace(line) -- 221
	local j = 0 -- 222
	local maxLen = math.min(#lineIndent, #indent) -- 223
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 223
		j = j + 1 -- 225
	end -- 225
	return __TS__StringSubstring(line, j) -- 227
end -- 217
local function dedentLines(lines) -- 230
	local indent = getCommonIndentPrefix(lines) -- 231
	return { -- 232
		indent = indent, -- 233
		lines = __TS__ArrayMap( -- 234
			lines, -- 234
			function(____, line) return removeIndentPrefix(line, indent) end -- 234
		) -- 234
	} -- 234
end -- 230
local function findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 238
	local function foldWhitespace(text, withMap) -- 244
		local parts = {} -- 245
		local map = {} -- 246
		local i = 0 -- 247
		while i < #text do -- 247
			local ch = __TS__StringAccess(text, i) -- 249
			if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 249
				local start = i -- 251
				while i < #text do -- 251
					local next = __TS__StringAccess(text, i) -- 253
					if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 253
						break -- 254
					end -- 254
					i = i + 1 -- 255
				end -- 255
				parts[#parts + 1] = " " -- 257
				if withMap then -- 257
					map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 258
				end -- 258
			else -- 258
				parts[#parts + 1] = ch -- 260
				if withMap then -- 260
					map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 261
				end -- 261
				i = i + 1 -- 262
			end -- 262
		end -- 262
		return { -- 265
			text = table.concat(parts, ""), -- 265
			map = map -- 265
		} -- 265
	end -- 244
	local foldedContent = foldWhitespace(content, true) -- 267
	local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 268
	if foldedOld == "" then -- 268
		return {success = false, message = "old_str not found in file"} -- 270
	end -- 270
	local matches = {} -- 272
	local pos = 0 -- 273
	while true do -- 273
		local idx = (string.find( -- 275
			foldedContent.text, -- 275
			foldedOld, -- 275
			math.max(pos + 1, 1), -- 275
			true -- 275
		) or 0) - 1 -- 275
		if idx < 0 then -- 275
			break -- 276
		end -- 276
		local lastIdx = idx + #foldedOld - 1 -- 277
		local startMap = foldedContent.map[idx + 1] -- 278
		local endMap = foldedContent.map[lastIdx + 1] -- 279
		if startMap ~= nil and endMap ~= nil then -- 279
			matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 281
		end -- 281
		pos = idx + #foldedOld -- 283
	end -- 283
	if #matches == 0 then -- 283
		return {success = false, message = "old_str not found in file"} -- 286
	end -- 286
	if #matches > 1 then -- 286
		return { -- 289
			success = false, -- 290
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 291
		} -- 291
	end -- 291
	local match = matches[1] -- 294
	return { -- 295
		success = true, -- 296
		content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 297
	} -- 297
end -- 238
function ____exports.findIndentTolerantReplacement(content, oldStr, newStr) -- 301
	local contentLines = __TS__StringSplit(content, "\n") -- 306
	local oldLines = __TS__StringSplit(oldStr, "\n") -- 307
	if #oldLines == 0 then -- 307
		return {success = false, message = "old_str not found in file"} -- 309
	end -- 309
	local dedentedOld = dedentLines(oldLines) -- 311
	local dedentedOldText = table.concat(dedentedOld.lines, "\n") -- 312
	local dedentedNew = dedentLines(__TS__StringSplit(newStr, "\n")) -- 313
	local matches = {} -- 314
	do -- 314
		local start = 0 -- 315
		while start <= #contentLines - #oldLines do -- 315
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 316
			local dedentedCandidate = dedentLines(candidateLines) -- 317
			if table.concat(dedentedCandidate.lines, "\n") == dedentedOldText then -- 317
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 319
			end -- 319
			start = start + 1 -- 315
		end -- 315
	end -- 315
	if #matches == 0 then -- 315
		return findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 327
	end -- 327
	if #matches > 1 then -- 327
		return { -- 330
			success = false, -- 331
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 332
		} -- 332
	end -- 332
	local match = matches[1] -- 335
	local rebuiltNewLines = __TS__ArrayMap( -- 336
		dedentedNew.lines, -- 336
		function(____, line) return line == "" and "" or match.indent .. line end -- 336
	) -- 336
	local ____array_0 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 336
	__TS__SparseArrayPush( -- 336
		____array_0, -- 336
		table.unpack(rebuiltNewLines) -- 339
	) -- 339
	__TS__SparseArrayPush( -- 339
		____array_0, -- 339
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 340
	) -- 340
	local nextLines = {__TS__SparseArraySpread(____array_0)} -- 337
	return { -- 342
		success = true, -- 342
		content = table.concat(nextLines, "\n") -- 342
	} -- 342
end -- 301
local function previewText(text, maxLen) -- 345
	if maxLen == nil then -- 345
		maxLen = 200 -- 345
	end -- 345
	if text == "" then -- 345
		return "" -- 346
	end -- 346
	local compact = __TS__StringReplace( -- 347
		__TS__StringReplace(text, "\r", "\\r"), -- 347
		"\n", -- 347
		"\\n" -- 347
	) -- 347
	if #compact <= maxLen then -- 347
		return compact -- 348
	end -- 348
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 349
end -- 345
local function sanitizeJSONValue(value) -- 371
	if type(value) == "string" then -- 371
		return ____exports.sanitizeUTF8(value) -- 372
	end -- 372
	if __TS__ArrayIsArray(value) then -- 372
		return __TS__ArrayMap( -- 374
			value, -- 374
			function(____, item) return sanitizeJSONValue(item) end -- 374
		) -- 374
	end -- 374
	if value and type(value) == "table" then -- 374
		local result = {} -- 377
		for key in pairs(value) do -- 378
			result[key] = sanitizeJSONValue(value[key]) -- 379
		end -- 379
		return result -- 381
	end -- 381
	return value -- 383
end -- 371
function ____exports.safeJsonEncode(value, format, emptyAsArray, numAsStr, maxDepth) -- 386
	if format == nil then -- 386
		format = false -- 386
	end -- 386
	if emptyAsArray == nil then -- 386
		emptyAsArray = true -- 386
	end -- 386
	if numAsStr == nil then -- 386
		numAsStr = false -- 386
	end -- 386
	if maxDepth == nil then -- 386
		maxDepth = 128 -- 386
	end -- 386
	return json.encode( -- 387
		sanitizeJSONValue(value), -- 388
		format, -- 389
		emptyAsArray, -- 390
		numAsStr, -- 391
		maxDepth -- 392
	) -- 392
end -- 386
function ____exports.safeJsonDecode(text) -- 396
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 397
	if value == nil then -- 397
		return value, err -- 399
	end -- 399
	return sanitizeJSONValue(value), err -- 401
end -- 396
local function isPlainRecord(value) -- 404
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 405
end -- 404
local function normalizeLLMJSONResponse(text) -- 408
	return __TS__StringTrim(text) -- 409
end -- 408
local function utf8TakeHead(text, maxChars) -- 412
	if maxChars <= 0 or text == "" then -- 412
		return "" -- 413
	end -- 413
	local nextPos = utf8.offset(text, maxChars + 1) -- 414
	if nextPos == nil then -- 414
		return text -- 415
	end -- 415
	return string.sub(text, 1, nextPos - 1) -- 416
end -- 412
local function utf8TakeTail(text, maxChars) -- 419
	if maxChars <= 0 or text == "" then -- 419
		return "" -- 420
	end -- 420
	local charLen = utf8.len(text) -- 421
	if charLen == nil or charLen <= maxChars then -- 421
		return text -- 422
	end -- 422
	local startChar = math.max(1, charLen - maxChars + 1) -- 423
	local startPos = utf8.offset(text, startChar) -- 424
	if startPos == nil then -- 424
		return text -- 425
	end -- 425
	return string.sub(text, startPos) -- 426
end -- 419
function ____exports.estimateTextTokens(text) -- 429
	if text == "" then -- 429
		return 0 -- 430
	end -- 430
	return App:estimateTokens(text) -- 431
end -- 429
local function estimateMessagesTokens(messages) -- 434
	local total = 0 -- 435
	do -- 435
		local i = 0 -- 436
		while i < #messages do -- 436
			local message = messages[i + 1] -- 437
			total = total + 8 -- 438
			total = total + ____exports.estimateTextTokens(message.role or "") -- 439
			total = total + ____exports.estimateTextTokens(message.content or "") -- 440
			total = total + ____exports.estimateTextTokens(message.name or "") -- 441
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 442
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 443
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({})) -- 444
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 445
			i = i + 1 -- 436
		end -- 436
	end -- 436
	return total -- 447
end -- 434
local function estimateOptionsTokens(options) -- 450
	local text = ____exports.safeJsonEncode(options) -- 451
	return text and ____exports.estimateTextTokens(text) or 0 -- 452
end -- 450
local function getReservedOutputTokens(options, contextWindow) -- 455
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 456
	if explicitMax > 0 then -- 456
		return math.max(256, explicitMax) -- 461
	end -- 461
	return math.max( -- 462
		1024, -- 462
		math.floor(contextWindow * 0.2) -- 462
	) -- 462
end -- 455
local function getInputTokenBudget(messages, options, config) -- 465
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 466
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 469
	local optionTokens = estimateOptionsTokens(options) -- 470
	local structuralOverhead = math.max(256, #messages * 16) -- 471
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 472
end -- 465
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 475
	if budgetTokens <= 0 or text == "" then -- 475
		return "" -- 476
	end -- 476
	local estimated = ____exports.estimateTextTokens(text) -- 477
	if estimated <= budgetTokens then -- 477
		return text -- 478
	end -- 478
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 479
	local targetChars = math.max( -- 480
		200, -- 480
		math.floor(budgetTokens * charsPerToken) -- 480
	) -- 480
	local keepHead = math.max( -- 481
		0, -- 481
		math.floor(targetChars * 0.35) -- 481
	) -- 481
	local keepTail = math.max(0, targetChars - keepHead) -- 482
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 483
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 484
	return (head .. "\n...\n") .. tail -- 485
end -- 475
local function isXMLWhitespaceChar(ch) -- 488
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 489
end -- 488
local function findLineStart(value, from) -- 492
	local i = from -- 493
	while i >= 0 do -- 493
		if __TS__StringAccess(value, i) == "\n" then -- 493
			return i + 1 -- 495
		end -- 495
		i = i - 1 -- 496
	end -- 496
	return 0 -- 498
end -- 492
local function findLastLiteral(text, needle) -- 501
	if needle == "" then -- 501
		return #text -- 502
	end -- 502
	local last = -1 -- 503
	local from = 0 -- 504
	while from <= #text - #needle do -- 504
		local pos = (string.find( -- 506
			text, -- 506
			needle, -- 506
			math.max(from + 1, 1), -- 506
			true -- 506
		) or 0) - 1 -- 506
		if pos < 0 then -- 506
			break -- 507
		end -- 507
		last = pos -- 508
		from = pos + 1 -- 509
	end -- 509
	return last -- 511
end -- 501
local function unwrapXMLRawText(text) -- 514
	local trimmed = __TS__StringTrim(text) -- 515
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 515
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 517
	end -- 517
	return text -- 519
end -- 514
local function readSimpleXMLTagName(source, openStart, openEnd) -- 522
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 523
	if rawTag == "" then -- 523
		return { -- 525
			success = false, -- 525
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 525
		} -- 525
	end -- 525
	local selfClosing = false -- 527
	local tagText = rawTag -- 528
	if __TS__StringEndsWith(tagText, "/") then -- 528
		selfClosing = true -- 530
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 531
	end -- 531
	local tagName = "" -- 533
	do -- 533
		local i = 0 -- 534
		while i < #tagText do -- 534
			local ch = __TS__StringAccess(tagText, i) -- 535
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 535
				break -- 536
			end -- 536
			tagName = tagName .. ch -- 537
			i = i + 1 -- 534
		end -- 534
	end -- 534
	if tagName == "" then -- 534
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 540
	end -- 540
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 542
end -- 522
local function findMatchingXMLClose(source, tagName, contentStart) -- 545
	local sameOpenPrefix = "<" .. tagName -- 546
	local sameCloseToken = ("</" .. tagName) .. ">" -- 547
	local pos = contentStart -- 548
	local depth = 1 -- 549
	while pos < #source do -- 549
		do -- 549
			local lt = (string.find( -- 551
				source, -- 551
				"<", -- 551
				math.max(pos + 1, 1), -- 551
				true -- 551
			) or 0) - 1 -- 551
			if lt < 0 then -- 551
				break -- 552
			end -- 552
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 552
				local cdataEnd = (string.find( -- 554
					source, -- 554
					"]]>", -- 554
					math.max(lt + 9 + 1, 1), -- 554
					true -- 554
				) or 0) - 1 -- 554
				if cdataEnd < 0 then -- 554
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 555
				end -- 555
				pos = cdataEnd + 3 -- 556
				goto __continue128 -- 557
			end -- 557
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 560
					source, -- 560
					"-->",
					math.max(lt + 4 + 1, 1), -- 560
					true -- 560
				) or 0) - 1 -- 560
				if commentEnd < 0 then -- 560
					return {success = false, message = "invalid xml: unterminated comment"} -- 561
				end -- 561
				pos = commentEnd + 3 -- 562
				goto __continue128 -- 563
			end -- 563
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 563
				depth = depth - 1 -- 566
				if depth == 0 then -- 566
					return {success = true, closeStart = lt} -- 567
				end -- 567
				pos = lt + #sameCloseToken -- 568
				goto __continue128 -- 569
			end -- 569
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 569
				local openEnd = (string.find( -- 572
					source, -- 572
					">", -- 572
					math.max(lt + 1, 1), -- 572
					true -- 572
				) or 0) - 1 -- 572
				if openEnd < 0 then -- 572
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 573
				end -- 573
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 574
				if not tagInfo.success then -- 574
					return tagInfo -- 575
				end -- 575
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 575
					depth = depth + 1 -- 577
				end -- 577
				pos = openEnd + 1 -- 579
				goto __continue128 -- 580
			end -- 580
			local genericEnd = (string.find( -- 582
				source, -- 582
				">", -- 582
				math.max(lt + 1, 1), -- 582
				true -- 582
			) or 0) - 1 -- 582
			if genericEnd < 0 then -- 582
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 583
			end -- 583
			pos = genericEnd + 1 -- 584
		end -- 584
		::__continue128:: -- 584
	end -- 584
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 586
end -- 545
function ____exports.extractXMLFromText(text) -- 589
	local source = __TS__StringTrim(text) -- 590
	local function extractFencedBlock(fence) -- 591
		if not __TS__StringStartsWith(source, fence) then -- 591
			return nil -- 592
		end -- 592
		local firstLineEnd = (string.find( -- 593
			source, -- 593
			"\n", -- 593
			math.max(1, 1), -- 593
			true -- 593
		) or 0) - 1 -- 593
		if firstLineEnd < 0 then -- 593
			return nil -- 594
		end -- 594
		local searchPos = firstLineEnd + 1 -- 595
		local closingFencePositions = {} -- 596
		while searchPos < #source do -- 596
			local ____end = (string.find( -- 598
				source, -- 598
				"```", -- 598
				math.max(searchPos + 1, 1), -- 598
				true -- 598
			) or 0) - 1 -- 598
			if ____end < 0 then -- 598
				break -- 599
			end -- 599
			local lineStart = findLineStart(source, ____end - 1) -- 600
			local lineEnd = (string.find( -- 601
				source, -- 601
				"\n", -- 601
				math.max(____end + 1, 1), -- 601
				true -- 601
			) or 0) - 1 -- 601
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 602
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 602
				closingFencePositions[#closingFencePositions + 1] = ____end -- 604
			end -- 604
			searchPos = ____end + 1 -- 606
		end -- 606
		do -- 606
			local i = #closingFencePositions - 1 -- 608
			while i >= 0 do -- 608
				do -- 608
					local closingFencePos = closingFencePositions[i + 1] -- 609
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 610
					if afterFence ~= "" then -- 610
						goto __continue149 -- 611
					end -- 611
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 612
				end -- 612
				::__continue149:: -- 612
				i = i - 1 -- 608
			end -- 608
		end -- 608
		return nil -- 614
	end -- 591
	local xmlBlock = extractFencedBlock("```xml") -- 616
	if xmlBlock ~= nil then -- 616
		return xmlBlock -- 617
	end -- 617
	local genericBlock = extractFencedBlock("```") -- 618
	if genericBlock ~= nil then -- 618
		return genericBlock -- 619
	end -- 619
	return source -- 620
end -- 589
function ____exports.parseSimpleXMLChildren(source) -- 623
	local result = {} -- 624
	local pos = 0 -- 625
	while pos < #source do -- 625
		do -- 625
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 625
				pos = pos + 1 -- 627
			end -- 627
			if pos >= #source then -- 627
				break -- 628
			end -- 628
			if __TS__StringAccess(source, pos) ~= "<" then -- 628
				return { -- 630
					success = false, -- 630
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 630
				} -- 630
			end -- 630
			if __TS__StringStartsWith(source, "</", pos) then -- 630
				return { -- 633
					success = false, -- 633
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 633
				} -- 633
			end -- 633
			local openEnd = (string.find( -- 635
				source, -- 635
				">", -- 635
				math.max(pos + 1, 1), -- 635
				true -- 635
			) or 0) - 1 -- 635
			if openEnd < 0 then -- 635
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 637
			end -- 637
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 639
			if not tagInfo.success then -- 639
				return tagInfo -- 640
			end -- 640
			if tagInfo.selfClosing then -- 640
				result[tagInfo.tagName] = "" -- 642
				pos = openEnd + 1 -- 643
				goto __continue154 -- 644
			end -- 644
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 646
			if not closeRes.success then -- 646
				return closeRes -- 647
			end -- 647
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 648
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 649
			pos = closeRes.closeStart + #closeToken -- 650
		end -- 650
		::__continue154:: -- 650
	end -- 650
	return {success = true, obj = result} -- 652
end -- 623
function ____exports.parseXMLObjectFromText(text, rootTag) -- 655
	local xmlText = ____exports.extractXMLFromText(text) -- 656
	local rootOpen = ("<" .. rootTag) .. ">" -- 657
	local rootClose = ("</" .. rootTag) .. ">" -- 658
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 659
	local ____end = findLastLiteral(xmlText, rootClose) -- 660
	if start < 0 or ____end < start then -- 660
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 662
	end -- 662
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 664
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 665
	if beforeRoot ~= "" or afterRoot ~= "" then -- 665
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 667
	end -- 667
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 669
	return ____exports.parseSimpleXMLChildren(rootContent) -- 670
end -- 655
function ____exports.fitMessagesToContext(messages, options, config) -- 673
	local modelName = string.lower(config.model) -- 680
	local shouldEchoReasoningContent = __TS__ArraySome( -- 681
		messages, -- 681
		function(____, message) return type(message.reasoning_content) == "string" end -- 681
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 681
	local cloned = __TS__ArrayMap( -- 685
		messages, -- 685
		function(____, message) -- 685
			local clonedMessage = __TS__ObjectAssign({}, message) -- 686
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 686
				clonedMessage.reasoning_content = "" -- 692
			end -- 692
			return clonedMessage -- 694
		end -- 685
	) -- 685
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 696
	local originalTokens = estimateMessagesTokens(cloned) -- 697
	if originalTokens <= budgetTokens then -- 697
		return { -- 699
			messages = cloned, -- 700
			trimmed = false, -- 701
			originalTokens = originalTokens, -- 702
			fittedTokens = originalTokens, -- 703
			budgetTokens = budgetTokens -- 704
		} -- 704
	end -- 704
	local function roleOverhead(message) -- 708
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 708
	end -- 708
	local fixedOverhead = 0 -- 709
	local contentIndexes = {} -- 710
	do -- 710
		local i = 0 -- 711
		while i < #cloned do -- 711
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 712
			contentIndexes[#contentIndexes + 1] = i -- 713
			i = i + 1 -- 711
		end -- 711
	end -- 711
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 715
	if #contentIndexes == 1 then -- 715
		local idx = contentIndexes[1] -- 717
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 718
		local fittedTokens = estimateMessagesTokens(cloned) -- 719
		return { -- 720
			messages = cloned, -- 721
			trimmed = true, -- 722
			originalTokens = originalTokens, -- 723
			fittedTokens = fittedTokens, -- 724
			budgetTokens = budgetTokens -- 725
		} -- 725
	end -- 725
	local nonSystemIndexes = {} -- 729
	local systemIndexes = {} -- 730
	do -- 730
		local i = 0 -- 731
		while i < #cloned do -- 731
			if cloned[i + 1].role == "system" then -- 731
				systemIndexes[#systemIndexes + 1] = i -- 732
			else -- 732
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 733
			end -- 733
			i = i + 1 -- 731
		end -- 731
	end -- 731
	local ____array_1 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 731
	__TS__SparseArrayPush( -- 731
		____array_1, -- 731
		table.unpack(systemIndexes) -- 735
	) -- 735
	local priorityIndexes = {__TS__SparseArraySpread(____array_1)} -- 735
	local remainingContentBudget = contentBudget -- 736
	do -- 736
		local i = #priorityIndexes - 1 -- 737
		while i >= 0 do -- 737
			local idx = priorityIndexes[i + 1] -- 738
			local message = cloned[idx + 1] -- 739
			local minBudget = message.role == "system" and 96 or 192 -- 740
			local target = math.max( -- 741
				minBudget, -- 741
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 741
			) -- 741
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 742
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 743
			remainingContentBudget = math.max(0, remainingContentBudget) -- 744
			i = i - 1 -- 737
		end -- 737
	end -- 737
	local fittedTokens = estimateMessagesTokens(cloned) -- 747
	if fittedTokens > budgetTokens then -- 747
		do -- 747
			local i = 0 -- 749
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 749
				local idx = priorityIndexes[i + 1] -- 750
				local message = cloned[idx + 1] -- 751
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 752
				local excess = fittedTokens - budgetTokens -- 753
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 754
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 755
				fittedTokens = estimateMessagesTokens(cloned) -- 756
				i = i + 1 -- 749
			end -- 749
		end -- 749
	end -- 749
	if fittedTokens > budgetTokens then -- 749
		do -- 749
			local i = 0 -- 760
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 760
				do -- 760
					local idx = priorityIndexes[i + 1] -- 761
					if cloned[idx + 1].role == "system" then -- 761
						goto __continue186 -- 762
					end -- 762
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 763
					fittedTokens = estimateMessagesTokens(cloned) -- 764
				end -- 764
				::__continue186:: -- 764
				i = i + 1 -- 760
			end -- 760
		end -- 760
	end -- 760
	return { -- 767
		messages = cloned, -- 768
		trimmed = true, -- 769
		originalTokens = originalTokens, -- 770
		fittedTokens = fittedTokens, -- 771
		budgetTokens = budgetTokens -- 772
	} -- 772
end -- 673
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken, studioGateway) -- 776
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 788
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 789
	local data = __TS__ObjectAssign({}, requestOptions, {model = model, messages = messages, stream = stream}) -- 790
	local studioRequestId = studioGateway and ____exports.createStudioModelRequestId() or nil -- 796
	if stopToken == nil then -- 796
		stopToken = {stopped = false} -- 797
	end -- 797
	return __TS__New( -- 798
		__TS__Promise, -- 798
		function(____, resolve, reject) -- 798
			local requestId = 0 -- 799
			local settled = false -- 800
			local function finishResolve(text) -- 801
				if settled then -- 801
					return -- 802
				end -- 802
				settled = true -- 803
				resolve(nil, text) -- 804
			end -- 801
			local function finishReject(err) -- 806
				if settled then -- 806
					return -- 807
				end -- 807
				settled = true -- 808
				reject(nil, err) -- 809
			end -- 806
			Director.systemScheduler:schedule(function() -- 811
				if not settled then -- 811
					if stopToken.stopped then -- 811
						if requestId ~= 0 then -- 811
							HttpClient:cancel(requestId) -- 815
							requestId = 0 -- 816
						end -- 816
						finishReject("request cancelled") -- 818
						return true -- 819
					end -- 819
					return false -- 821
				end -- 821
				return true -- 823
			end) -- 811
			Director.systemScheduler:schedule(once(function() -- 825
				emit( -- 826
					"LLM_IN", -- 826
					table.concat( -- 826
						__TS__ArrayMap( -- 826
							messages, -- 826
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 826
						), -- 826
						"\n" -- 826
					) -- 826
				) -- 826
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 827
				if jsonStr ~= nil then -- 827
					local headers = { -- 829
						"Authorization: Bearer " .. apiKey, -- 830
						"Content-Type: application/json", -- 831
						receiver and "Accept: text/event-stream" or "Accept: application/json", -- 832
						table.unpack(studioRequestId and ({"X-Studio-Model-Request-Id: " .. studioRequestId}) or ({})) -- 833
					} -- 833
					requestId = receiver and HttpClient:post( -- 835
						url, -- 836
						headers, -- 836
						jsonStr, -- 836
						requestTimeout, -- 836
						function(data) -- 836
							if stopToken.stopped then -- 836
								return true -- 837
							end -- 837
							return receiver(data) -- 838
						end, -- 836
						function(data) -- 839
							requestId = 0 -- 840
							if data ~= nil then -- 840
								finishResolve(data) -- 842
							else -- 842
								finishReject("failed to get http response") -- 844
							end -- 844
						end -- 839
					) or HttpClient:post( -- 839
						url, -- 847
						headers, -- 847
						jsonStr, -- 847
						requestTimeout, -- 847
						function(data) -- 847
							requestId = 0 -- 848
							if stopToken.stopped then -- 848
								finishReject("request cancelled") -- 850
								return -- 851
							end -- 851
							if data ~= nil then -- 851
								finishResolve(data) -- 854
							else -- 854
								finishReject("failed to get http response") -- 856
							end -- 856
						end -- 847
					) -- 847
					if requestId == 0 then -- 847
						finishReject("failed to schedule http request") -- 860
					elseif stopToken.stopped then -- 860
						HttpClient:cancel(requestId) -- 862
						requestId = 0 -- 863
						finishReject("request cancelled") -- 864
					end -- 864
				else -- 864
					finishReject(err) -- 867
				end -- 867
			end)) -- 825
		end -- 798
	) -- 798
end -- 776
function ____exports.createSSEJSONParser(opts) -- 877
	local buffer = "" -- 882
	local eventDataLines = {} -- 883
	local function flushEventIfAny() -- 885
		if #eventDataLines == 0 then -- 885
			return -- 886
		end -- 886
		local dataPayload = table.concat(eventDataLines, "\n") -- 888
		eventDataLines = {} -- 889
		if dataPayload == "[DONE]" then -- 889
			local ____opt_2 = opts.onDone -- 889
			if ____opt_2 ~= nil then -- 889
				____opt_2(dataPayload) -- 892
			end -- 892
			return -- 893
		end -- 893
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 896
		if err == nil then -- 896
			opts.onJSON(obj, dataPayload) -- 898
		else -- 898
			local ____opt_4 = opts.onError -- 898
			if ____opt_4 ~= nil then -- 898
				____opt_4(err, {raw = dataPayload}) -- 900
			end -- 900
		end -- 900
	end -- 885
	local function append(chunk) -- 904
		buffer = buffer .. chunk -- 905
	end -- 904
	local function drain(maxLines) -- 908
		local processedLines = 0 -- 909
		while maxLines == nil or processedLines < maxLines do -- 909
			do -- 909
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 911
				if nl < 0 then -- 911
					break -- 912
				end -- 912
				processedLines = processedLines + 1 -- 913
				local line = __TS__StringSlice(buffer, 0, nl) -- 915
				buffer = __TS__StringSlice(buffer, nl + 1) -- 916
				if __TS__StringEndsWith(line, "\r") then -- 916
					line = string.sub(line, 1, -2) -- 918
				end -- 918
				if line == "" then -- 918
					flushEventIfAny() -- 921
					goto __continue221 -- 922
				end -- 922
				if __TS__StringStartsWith(line, ":") then -- 922
					goto __continue221 -- 926
				end -- 926
				if __TS__StringStartsWith(line, "data:") then -- 926
					local v = string.sub(line, 6) -- 929
					if __TS__StringStartsWith(v, " ") then -- 929
						v = string.sub(v, 2) -- 930
					end -- 930
					eventDataLines[#eventDataLines + 1] = v -- 931
					goto __continue221 -- 932
				end -- 932
			end -- 932
			::__continue221:: -- 932
		end -- 932
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0 -- 935
	end -- 908
	local function feed(chunk) -- 938
		append(chunk) -- 939
		drain() -- 940
	end -- 938
	local function ____end() -- 943
		if #buffer > 0 then -- 943
			local line = buffer -- 945
			buffer = "" -- 946
			if __TS__StringEndsWith(line, "\r") then -- 946
				line = string.sub(line, 1, -2) -- 947
			end -- 947
			if __TS__StringStartsWith(line, "data:") then -- 947
				local v = string.sub(line, 6) -- 950
				if __TS__StringStartsWith(v, " ") then -- 950
					v = string.sub(v, 2) -- 951
				end -- 951
				eventDataLines[#eventDataLines + 1] = v -- 952
			end -- 952
		end -- 952
		flushEventIfAny() -- 955
	end -- 943
	local function discard() -- 958
		buffer = "" -- 959
		eventDataLines = {} -- 960
	end -- 958
	return { -- 963
		append = append, -- 963
		drain = drain, -- 963
		feed = feed, -- 963
		["end"] = ____end, -- 963
		discard = discard -- 963
	} -- 963
end -- 877
local SSE_PARSE_LINES_PER_FRAME = 256 -- 966
local function createScheduledSSEJSONParser(opts, isCancelled) -- 968
	local parser = ____exports.createSSEJSONParser(opts) -- 972
	local inputFinished = false -- 973
	local settled = false -- 974
	local resolveFinished -- 975
	local finished = __TS__New( -- 976
		__TS__Promise, -- 976
		function(____, resolve) -- 976
			resolveFinished = resolve -- 977
		end -- 976
	) -- 976
	local function settle() -- 979
		if settled then -- 979
			return -- 980
		end -- 980
		settled = true -- 981
		if resolveFinished ~= nil then -- 981
			resolveFinished() -- 982
		end -- 982
	end -- 979
	Director.systemScheduler:schedule(function() -- 984
		if settled then -- 984
			return true -- 985
		end -- 985
		if isCancelled and isCancelled() then -- 985
			parser.discard() -- 987
			settle() -- 988
			return true -- 989
		end -- 989
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME) -- 991
		if inputFinished and not hasMoreCompleteLines then -- 991
			parser["end"]() -- 993
			settle() -- 994
			return true -- 995
		end -- 995
		return false -- 997
	end) -- 984
	return { -- 999
		append = parser.append, -- 1000
		finish = function() -- 1001
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1001
				inputFinished = true -- 1002
				__TS__Await(finished) -- 1003
			end) -- 1003
		end, -- 1001
		cancel = function() -- 1005
			parser.discard() -- 1006
			settle() -- 1007
		end -- 1005
	} -- 1005
end -- 968
function ____exports.extractLLMTokenUsage(response) -- 1103
	local usage = response and response.usage -- 1104
	if not usage or type(usage) ~= "table" then -- 1104
		return nil -- 1105
	end -- 1105
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1106
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1109
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1109
		return nil -- 1112
	end -- 1112
	local ____temp_17 -- 1113
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1113
		____temp_17 = usage.prompt_cache_hit_tokens -- 1114
	else -- 1114
		local ____temp_16 -- 1115
		local ____opt_12 = usage.prompt_tokens_details -- 1115
		if type(____opt_12 and ____opt_12.cached_tokens) == "number" then -- 1115
			____temp_16 = usage.prompt_tokens_details.cached_tokens -- 1116
		else -- 1116
			local ____opt_14 = usage.input_tokens_details -- 1116
			____temp_16 = type(____opt_14 and ____opt_14.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1117
		end -- 1117
		____temp_17 = ____temp_16 -- 1115
	end -- 1115
	local cachedInputTokens = ____temp_17 -- 1113
	local ____inputTokens_20 = inputTokens -- 1121
	local ____outputTokens_21 = outputTokens -- 1122
	local ____temp_22 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1123
	local ____temp_23 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1124
	local ____temp_24 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1125
	local ____opt_18 = usage.completion_tokens_details -- 1125
	return { -- 1120
		inputTokens = ____inputTokens_20, -- 1121
		outputTokens = ____outputTokens_21, -- 1122
		totalTokens = ____temp_22, -- 1123
		cachedInputTokens = ____temp_23, -- 1124
		cacheMissInputTokens = ____temp_24, -- 1125
		reasoningOutputTokens = type(____opt_18 and ____opt_18.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1128
	} -- 1128
end -- 1103
function ____exports.validateAgentLLMConfig(config) -- 1173
	local ____opt_25 = config.customOptions -- 1173
	local auxiliaryOptions = ____opt_25 and ____opt_25.auxiliaryOptions -- 1174
	if isPlainRecord(auxiliaryOptions) then -- 1174
		for _key in pairs(auxiliaryOptions) do -- 1176
			return {success = true} -- 1177
		end -- 1177
	end -- 1177
	return {success = false, message = "LLM 配置的 customOptions 必须包含非空 auxiliaryOptions，请检查 LLM 配置"} -- 1180
end -- 1173
local function normalizeContextWindow(value) -- 1186
	if type(value) == "number" and value > 0 then -- 1186
		return math.floor(value) -- 1188
	end -- 1188
	return 64000 -- 1190
end -- 1186
local function normalizeSupportsFunctionCalling(value) -- 1193
	return value == nil or value ~= 0 -- 1194
end -- 1193
local function normalizeLLMTemperature(value) -- 1197
	if type(value) == "number" then -- 1197
		return math.max( -- 1199
			0, -- 1199
			math.min(2, value) -- 1199
		) -- 1199
	end -- 1199
	return 0.1 -- 1201
end -- 1197
local function normalizeLLMMaxTokens(value) -- 1204
	if type(value) == "number" then -- 1204
		return math.max( -- 1206
			1, -- 1206
			math.floor(value) -- 1206
		) -- 1206
	end -- 1206
	return AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1208
end -- 1204
local function normalizeLLMCustomOptions(value) -- 1217
	if type(value) ~= "string" then -- 1217
		return nil -- 1218
	end -- 1218
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1219
	if text == "" then -- 1219
		return nil -- 1220
	end -- 1220
	local decoded = ____exports.safeJsonDecode(text) -- 1221
	return isPlainRecord(decoded) and decoded or nil -- 1222
end -- 1217
local function getLLMConfigRecords() -- 1245
	upgradeLLMConfig() -- 1246
	local rows = DB:query("select * from LLMConfig", true) -- 1247
	local records = {} -- 1248
	if rows and #rows > 1 then -- 1248
		do -- 1248
			local i = 1 -- 1250
			while i < #rows do -- 1250
				local record = {} -- 1251
				do -- 1251
					local c = 0 -- 1252
					while c < #rows[i + 1] do -- 1252
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1253
						c = c + 1 -- 1252
					end -- 1252
				end -- 1252
				records[#records + 1] = record -- 1255
				i = i + 1 -- 1250
			end -- 1250
		end -- 1250
	end -- 1250
	return records -- 1258
end -- 1245
function ____exports.getLLMConfigSummaries() -- 1268
	return __TS__ArrayFlatMap( -- 1269
		getLLMConfigRecords(), -- 1269
		function(____, record) -- 1269
			local id = record.id -- 1270
			local name = record.name -- 1271
			local model = record.model -- 1272
			if type(id) ~= "number" or type(name) ~= "string" or type(model) ~= "string" then -- 1272
				return {} -- 1273
			end -- 1273
			return {{id = id, name = name, model = model, active = record.active ~= 0}} -- 1274
		end -- 1269
	) -- 1269
end -- 1268
local function parseLLMConfig(config) -- 1278
	if not config then -- 1278
		return {success = false, message = "LLM config not found"} -- 1280
	end -- 1280
	local ____config_27 = config -- 1282
	local id = ____config_27.id -- 1282
	local url = ____config_27.url -- 1282
	local model = ____config_27.model -- 1282
	local api_key = ____config_27.api_key -- 1282
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1282
		return {success = false, message = "got invalid LLM config"} -- 1284
	end -- 1284
	return { -- 1286
		success = true, -- 1287
		id = id, -- 1288
		config = { -- 1289
			url = url, -- 1290
			model = model, -- 1291
			apiKey = api_key, -- 1292
			contextWindow = normalizeContextWindow(config.context_window), -- 1293
			temperature = normalizeLLMTemperature(config.temperature), -- 1294
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1295
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1296
			customOptions = normalizeLLMCustomOptions(config.custom_options), -- 1297
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 1298
		} -- 1298
	} -- 1298
end -- 1278
function ____exports.getLLMConfig(configId) -- 1303
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1304
	if normalizedId == nil or normalizedId <= 0 then -- 1304
		return {success = false, message = "LLM config is not selected"} -- 1306
	end -- 1306
	return parseLLMConfig(__TS__ArrayFind( -- 1308
		getLLMConfigRecords(), -- 1308
		function(____, record) return record.id == normalizedId end -- 1308
	)) -- 1308
end -- 1303
function ____exports.getActiveLLMConfig() -- 1311
	local records = getLLMConfigRecords() -- 1312
	local config = __TS__ArrayFind( -- 1313
		records, -- 1313
		function(____, r) return r.active ~= 0 end -- 1313
	) -- 1313
	if not config then -- 1313
		return {success = false, message = "no active LLM config"} -- 1315
	end -- 1315
	return parseLLMConfig(config) -- 1317
end -- 1311
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1320
	local callEvent -- 1326
	if event.id ~= nil then -- 1326
		local id = event.id -- 1328
		callEvent = { -- 1329
			id = nil, -- 1330
			onData = function(data) -- 1331
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1332
				return event.stopToken.stopped -- 1333
			end, -- 1331
			onCancel = function(reason) -- 1335
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1336
			end, -- 1335
			onDone = function() -- 1338
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1339
			end -- 1338
		} -- 1338
	else -- 1338
		callEvent = event -- 1343
	end -- 1343
	local ____callEvent_28 = callEvent -- 1345
	local onData = ____callEvent_28.onData -- 1345
	local onDone = ____callEvent_28.onDone -- 1345
	local ____callEvent_29 = callEvent -- 1346
	local onCancel = ____callEvent_29.onCancel -- 1346
	local config = llmConfig or (function() -- 1347
		local configRes = ____exports.getActiveLLMConfig() -- 1348
		if not configRes.success then -- 1348
			if onCancel then -- 1348
				onCancel(configRes.message) -- 1350
			end -- 1350
			return nil -- 1351
		end -- 1351
		return configRes.config -- 1353
	end)() -- 1347
	if not config then -- 1347
		return {success = false, message = "no active LLM config"} -- 1356
	end -- 1356
	local url = config.url -- 1356
	local model = config.model -- 1356
	local apiKey = config.apiKey -- 1356
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1359
	if fitted.trimmed then -- 1359
		____exports.Log( -- 1361
			"Warn", -- 1361
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1361
		) -- 1361
	end -- 1361
	local stopLLM = false -- 1363
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1364
	local parser = createScheduledSSEJSONParser( -- 1367
		{onJSON = function(obj) -- 1367
			local result = onData(obj) -- 1369
			if result then -- 1369
				stopLLM = true -- 1371
				streamStopToken.stopped = true -- 1372
				streamStopToken.reason = "LLM Stopped" -- 1373
			end -- 1373
		end}, -- 1368
		function() return streamStopToken.stopped end -- 1376
	); -- 1376
	(function() -- 1377
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1377
			local ____try = __TS__AsyncAwaiter(function() -- 1377
				local result = __TS__Await(postLLM( -- 1379
					fitted.messages, -- 1379
					url, -- 1379
					apiKey, -- 1379
					model, -- 1379
					options, -- 1379
					true, -- 1379
					config.customOptions, -- 1379
					function(data) -- 1379
						if stopLLM then -- 1379
							if onCancel then -- 1379
								onCancel("LLM Stopped") -- 1382
								onCancel = nil -- 1383
							end -- 1383
							return true -- 1385
						end -- 1385
						parser.append(data) -- 1387
						return false -- 1388
					end, -- 1379
					streamStopToken, -- 1389
					config.studioGateway -- 1389
				)) -- 1389
				__TS__Await(parser.finish()) -- 1390
				if onDone then -- 1390
					onDone(result) -- 1392
				end -- 1392
			end) -- 1392
			____try = ____try.catch( -- 1392
				____try, -- 1392
				function(____, e) -- 1392
					return __TS__AsyncAwaiter(function() -- 1392
						parser.cancel() -- 1395
						stopLLM = true -- 1396
						if onCancel then -- 1396
							onCancel(tostring(e)) -- 1398
							onCancel = nil -- 1399
						end -- 1399
					end) -- 1399
				end -- 1399
			) -- 1399
			__TS__Await(____try) -- 1378
		end) -- 1378
	end)() -- 1377
	return {success = true} -- 1403
end -- 1320
local function mergeStreamToolCall(target, delta) -- 1406
	if type(delta.id) == "string" and delta.id ~= "" then -- 1406
		target.id = delta.id -- 1408
	end -- 1408
	if type(delta.type) == "string" and delta.type ~= "" then -- 1408
		target.type = delta.type -- 1411
	end -- 1411
	if delta["function"] then -- 1411
		if target["function"] == nil then -- 1411
			target["function"] = {} -- 1414
		end -- 1414
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1414
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1416
		end -- 1416
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1416
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1419
		end -- 1419
	end -- 1419
end -- 1406
local function isToolCallComplete(tc) -- 1424
	if type(tc.id) ~= "string" or tc.id == "" then -- 1424
		return false -- 1425
	end -- 1425
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1425
		return false -- 1426
	end -- 1426
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1426
		return false -- 1427
	end -- 1427
	local args = tc["function"].arguments -- 1428
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1428
		return false -- 1429
	end -- 1429
	local decoded = ____exports.safeJsonDecode(args) -- 1430
	return decoded ~= nil -- 1431
end -- 1424
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1434
	local delta = choice.delta or ({}) -- 1435
	local fullMessage = choice.message or ({}) -- 1436
	local message = acc.message -- 1437
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1438
	if type(role) == "string" and role ~= "" then -- 1438
		message.role = role -- 1442
	end -- 1442
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1444
	if type(content) == "string" and content ~= "" then -- 1444
		message.content = (message.content or "") .. content -- 1448
	end -- 1448
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1450
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1450
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1454
	end -- 1454
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1456
	if #toolCalls > 0 then -- 1456
		if message.tool_calls == nil then -- 1456
			message.tool_calls = {} -- 1460
		end -- 1460
		do -- 1460
			local i = 0 -- 1461
			while i < #toolCalls do -- 1461
				local item = toolCalls[i + 1] -- 1462
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1463
				local ____message_tool_calls_30, ____temp_31 = message.tool_calls, index + 1 -- 1463
				if ____message_tool_calls_30[____temp_31] == nil then -- 1463
					____message_tool_calls_30[____temp_31] = {} -- 1466
				end -- 1466
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1467
				if onToolCallReady and emittedToolCallIds then -- 1467
					local tc = message.tool_calls[index + 1] -- 1469
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1469
						emittedToolCallIds[tc.id] = true -- 1471
						onToolCallReady(tc) -- 1472
					end -- 1472
				end -- 1472
				i = i + 1 -- 1461
			end -- 1461
		end -- 1461
	end -- 1461
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1461
		acc.finish_reason = choice.finish_reason -- 1478
	end -- 1478
end -- 1434
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1482
	local indexes = __TS__ArraySort( -- 1491
		__TS__ArrayFilter( -- 1491
			__TS__ArrayMap( -- 1491
				__TS__ObjectKeys(states), -- 1491
				function(____, key) return __TS__Number(key) end -- 1492
			), -- 1492
			function(____, index) return __TS__NumberIsFinite(index) end -- 1493
		), -- 1493
		function(____, a, b) return a - b end -- 1494
	) -- 1494
	return { -- 1495
		id = id, -- 1496
		created = created, -- 1497
		object = object, -- 1498
		model = model, -- 1499
		choices = __TS__ArrayMap( -- 1500
			indexes, -- 1500
			function(____, index) -- 1500
				local state = states[index] -- 1501
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1502
			end -- 1500
		), -- 1500
		usage = usage, -- 1513
		error = providerError -- 1514
	} -- 1514
end -- 1482
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1518
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1518
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1529
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1530
		local resolvedConfig = config or (function() -- 1533
			local configRes = ____exports.getActiveLLMConfig() -- 1534
			if not configRes.success then -- 1534
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1536
				return nil -- 1537
			end -- 1537
			return configRes.config -- 1539
		end)() -- 1533
		if not resolvedConfig then -- 1533
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1533
		end -- 1533
		local url = resolvedConfig.url -- 1533
		local model = resolvedConfig.model -- 1533
		local apiKey = resolvedConfig.apiKey -- 1533
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1545
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1546
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1547
		local ____model_36 = model -- 1550
		local ____url_37 = url -- 1550
		local ____temp_38 = #messages -- 1550
		local ____tostring_33 = tostring -- 1550
		local ____options_max_tokens_32 = options.max_tokens -- 1550
		if ____options_max_tokens_32 == nil then -- 1550
			____options_max_tokens_32 = "unset" -- 1550
		end -- 1550
		local ____tostring_33_result_39 = ____tostring_33(____options_max_tokens_32) -- 1550
		local ____tostring_35 = tostring -- 1550
		local ____options_temperature_34 = options.temperature -- 1550
		if ____options_temperature_34 == nil then -- 1550
			____options_temperature_34 = "unset" -- 1550
		end -- 1550
		____exports.Log( -- 1550
			"Info", -- 1550
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_36) .. " url=") .. ____url_37) .. " messages=") .. tostring(____temp_38)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_33_result_39) .. " temperature=") .. ____tostring_35(____options_temperature_34)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1550
		) -- 1550
		if stopToken and stopToken.stopped then -- 1550
			local reason = stopToken.reason or "request cancelled" -- 1552
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1553
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1553
		end -- 1553
		local ____hasReturned, ____returnValue -- 1553
		local ____try = __TS__AsyncAwaiter(function() -- 1553
			local states = {} -- 1557
			local emittedToolCallIds = {} -- 1558
			local responseId = nil -- 1559
			local responseCreated = nil -- 1560
			local responseObject = nil -- 1561
			local providerError -- 1562
			local responseUsage -- 1563
			local httpChunkCount = 0 -- 1564
			local rawStreamBytes = 0 -- 1565
			local rawStreamPreview = "" -- 1566
			local sseJSONChunkCount = 0 -- 1567
			local choiceJSONChunkCount = 0 -- 1568
			local emptyChoicesChunkCount = 0 -- 1569
			local missingChoicesChunkCount = 0 -- 1570
			local parseErrorCount = 0 -- 1571
			local doneChunkSeen = false -- 1572
			local lastJSONPreview = "" -- 1573
			local parser = createScheduledSSEJSONParser( -- 1574
				{ -- 1574
					onJSON = function(obj, raw) -- 1575
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1576
						lastJSONPreview = previewText(raw, 500) -- 1577
						if not obj or type(obj) ~= "table" then -- 1577
							return -- 1579
						end -- 1579
						local chunk = obj -- 1581
						if chunk.error then -- 1581
							providerError = chunk.error -- 1583
							____exports.Log( -- 1584
								"Warn", -- 1584
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1584
							) -- 1584
							return -- 1585
						end -- 1585
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1587
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1588
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1589
						if chunk.usage and type(chunk.usage) == "table" then -- 1589
							responseUsage = chunk.usage -- 1591
						end -- 1591
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1593
						if not __TS__ArrayIsArray(chunk.choices) then -- 1593
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1595
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1595
								____exports.Log( -- 1597
									"Warn", -- 1597
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1597
								) -- 1597
							end -- 1597
						elseif #choices == 0 then -- 1597
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1600
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1600
								____exports.Log( -- 1602
									"Warn", -- 1602
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1602
								) -- 1602
							end -- 1602
						else -- 1602
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1605
						end -- 1605
						do -- 1605
							local i = 0 -- 1607
							while i < #choices do -- 1607
								local choice = choices[i + 1] -- 1608
								local index = type(choice.index) == "number" and choice.index or i -- 1609
								if states[index] == nil then -- 1609
									states[index] = {index = index, message = {role = "assistant"}} -- 1610
								end -- 1610
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1614
								i = i + 1 -- 1607
							end -- 1607
						end -- 1607
						if onChunk ~= nil then -- 1607
							onChunk( -- 1616
								buildStreamResponse( -- 1617
									states, -- 1617
									model, -- 1617
									responseId, -- 1617
									responseCreated, -- 1617
									responseObject, -- 1617
									providerError, -- 1617
									responseUsage -- 1617
								), -- 1617
								{ -- 1618
									id = chunk.id or "", -- 1619
									created = chunk.created or 0, -- 1620
									object = chunk.object or "", -- 1621
									model = chunk.model or model, -- 1622
									choices = choices -- 1623
								} -- 1623
							) -- 1623
						end -- 1623
					end, -- 1575
					onDone = function() -- 1627
						doneChunkSeen = true -- 1628
					end, -- 1627
					onError = function(err, context) -- 1630
						parseErrorCount = parseErrorCount + 1 -- 1631
						____exports.Log( -- 1632
							"Warn", -- 1632
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1632
						) -- 1632
					end -- 1630
				}, -- 1630
				function() return (stopToken and stopToken.stopped) == true end -- 1634
			) -- 1634
			local ____try = __TS__AsyncAwaiter(function() -- 1634
				__TS__Await(postLLM( -- 1636
					fitted.messages, -- 1636
					url, -- 1636
					apiKey, -- 1636
					model, -- 1636
					options, -- 1636
					true, -- 1636
					resolvedConfig.customOptions, -- 1636
					function(data) -- 1636
						if stopToken and stopToken.stopped then -- 1636
							return true -- 1637
						end -- 1637
						httpChunkCount = httpChunkCount + 1 -- 1638
						rawStreamBytes = rawStreamBytes + #data -- 1639
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1639
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1641
						end -- 1641
						parser.append(data) -- 1643
						return false -- 1644
					end, -- 1636
					stopToken, -- 1645
					resolvedConfig.studioGateway -- 1645
				)) -- 1645
				__TS__Await(parser.finish()) -- 1646
			end) -- 1646
			____try = ____try.catch( -- 1646
				____try, -- 1646
				function(____, e) -- 1646
					return __TS__AsyncAwaiter(function() -- 1646
						parser.cancel() -- 1648
						error(e, 0) -- 1649
					end) -- 1649
				end -- 1649
			) -- 1649
			__TS__Await(____try) -- 1635
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1635
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1652
				if rawResponse and type(rawResponse) == "table" then -- 1652
					local rawResponseObj = rawResponse -- 1654
					if rawResponseObj.error then -- 1654
						providerError = rawResponseObj.error -- 1656
						lastJSONPreview = previewText( -- 1657
							normalizeLLMJSONResponse(rawStreamPreview), -- 1657
							500 -- 1657
						) -- 1657
						____exports.Log( -- 1658
							"Warn", -- 1658
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1658
						) -- 1658
					end -- 1658
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1658
						responseUsage = rawResponseObj.usage -- 1661
					end -- 1661
				end -- 1661
			end -- 1661
			local response = buildStreamResponse( -- 1665
				states, -- 1665
				model, -- 1665
				responseId, -- 1665
				responseCreated, -- 1665
				responseObject, -- 1665
				providerError, -- 1665
				responseUsage -- 1665
			) -- 1665
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1666
			local choiceCount = response.choices and #response.choices or 0 -- 1667
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1668
			____exports.Log( -- 1669
				"Info", -- 1669
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1669
			) -- 1669
			if not doneChunkSeen then -- 1669
				local rawPreview = previewText( -- 1671
					____exports.sanitizeUTF8(rawStreamPreview), -- 1671
					1200 -- 1671
				) -- 1671
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1672
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1673
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1674
				____hasReturned = true -- 1675
				____returnValue = { -- 1675
					success = false, -- 1676
					message = message, -- 1677
					raw = rawStreamPreview, -- 1678
					response = response, -- 1679
					tokenUsage = tokenUsage -- 1680
				} -- 1680
				return -- 1675
			end -- 1675
			if not response.choices or #response.choices == 0 then -- 1675
				local providerMessage = providerError and providerError.message or "" -- 1684
				local providerType = providerError and providerError.type or "" -- 1685
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1686
				local details = table.concat( -- 1689
					__TS__ArrayFilter( -- 1689
						{providerType, providerCode}, -- 1689
						function(____, part) return part ~= "" end -- 1689
					), -- 1689
					"/" -- 1689
				) -- 1689
				local rawPreview = previewText( -- 1690
					____exports.sanitizeUTF8(rawStreamPreview), -- 1690
					1200 -- 1690
				) -- 1690
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1691
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1692
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1695
				____hasReturned = true -- 1696
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1696
				return -- 1696
			end -- 1696
			____hasReturned = true -- 1703
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1703
			return -- 1703
		end) -- 1703
		____try = ____try.catch( -- 1703
			____try, -- 1703
			function(____, e) -- 1703
				return __TS__AsyncAwaiter(function() -- 1703
					if stopToken and stopToken.stopped then -- 1703
						local reason = stopToken.reason or "request cancelled" -- 1710
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1711
						____hasReturned = true -- 1712
						____returnValue = {success = false, message = reason} -- 1712
						return -- 1712
					end -- 1712
					____exports.Log( -- 1714
						"Error", -- 1714
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1714
					) -- 1714
					____hasReturned = true -- 1715
					____returnValue = { -- 1715
						success = false, -- 1715
						message = tostring(e) -- 1715
					} -- 1715
					return -- 1715
				end) -- 1715
			end -- 1715
		) -- 1715
		__TS__Await(____try) -- 1556
		if ____hasReturned then -- 1556
			return ____awaiter_resolve(nil, ____returnValue) -- 1556
		end -- 1556
	end) -- 1556
end -- 1518
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1719
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1719
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1725
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1726
		local resolvedConfig = config or (function() -- 1729
			local configRes = ____exports.getActiveLLMConfig() -- 1730
			if not configRes.success then -- 1730
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1732
				return nil -- 1733
			end -- 1733
			return configRes.config -- 1735
		end)() -- 1729
		if not resolvedConfig then -- 1729
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1729
		end -- 1729
		local url = resolvedConfig.url -- 1729
		local model = resolvedConfig.model -- 1729
		local apiKey = resolvedConfig.apiKey -- 1729
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1741
		____exports.Log( -- 1742
			"Info", -- 1742
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1742
		) -- 1742
		if stopToken and stopToken.stopped then -- 1742
			local reason = stopToken.reason or "request cancelled" -- 1744
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1745
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1745
		end -- 1745
		local ____hasReturned, ____returnValue -- 1745
		local ____try = __TS__AsyncAwaiter(function() -- 1745
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1749
				fitted.messages, -- 1749
				url, -- 1749
				apiKey, -- 1749
				model, -- 1749
				options, -- 1749
				false, -- 1749
				resolvedConfig.customOptions, -- 1749
				nil, -- 1749
				stopToken, -- 1749
				resolvedConfig.studioGateway -- 1749
			))) -- 1749
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1750
			____exports.Log( -- 1751
				"Info", -- 1751
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1751
			) -- 1751
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1752
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1752
				local rawPreview = previewText(raw) -- 1754
				____exports.Log( -- 1755
					"Error", -- 1755
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1755
				) -- 1755
				____hasReturned = true -- 1756
				____returnValue = { -- 1756
					success = false, -- 1757
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1758
					raw = raw -- 1759
				} -- 1759
				return -- 1756
			end -- 1756
			local responseObj = response -- 1762
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1763
			____exports.Log( -- 1764
				"Info", -- 1764
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1764
			) -- 1764
			if not responseObj.choices or #responseObj.choices == 0 then -- 1764
				local providerError = responseObj.error -- 1766
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1767
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1770
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1773
				local details = table.concat( -- 1776
					__TS__ArrayFilter( -- 1776
						{providerType, providerCode}, -- 1776
						function(____, part) return part ~= "" end -- 1776
					), -- 1776
					"/" -- 1776
				) -- 1776
				local rawPreview = previewText(raw, 400) -- 1777
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1778
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1781
				____hasReturned = true -- 1782
				____returnValue = {success = false, message = message, raw = raw} -- 1782
				return -- 1782
			end -- 1782
			____hasReturned = true -- 1788
			____returnValue = {success = true, response = responseObj} -- 1788
			return -- 1788
		end) -- 1788
		____try = ____try.catch( -- 1788
			____try, -- 1788
			function(____, e) -- 1788
				return __TS__AsyncAwaiter(function() -- 1788
					if stopToken and stopToken.stopped then -- 1788
						local reason = stopToken.reason or "request cancelled" -- 1794
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1795
						____hasReturned = true -- 1796
						____returnValue = {success = false, message = reason} -- 1796
						return -- 1796
					end -- 1796
					____exports.Log( -- 1798
						"Error", -- 1798
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1798
					) -- 1798
					____hasReturned = true -- 1799
					____returnValue = { -- 1799
						success = false, -- 1799
						message = tostring(e) -- 1799
					} -- 1799
					return -- 1799
				end) -- 1799
			end -- 1799
		) -- 1799
		__TS__Await(____try) -- 1748
		if ____hasReturned then -- 1748
			return ____awaiter_resolve(nil, ____returnValue) -- 1748
		end -- 1748
	end) -- 1748
end -- 1719
return ____exports -- 1719