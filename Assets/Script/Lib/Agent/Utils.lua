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
function normalizeReasoningEffort(value) -- 1206
	if type(value) ~= "string" then -- 1206
		return nil -- 1207
	end -- 1207
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1208
	return normalized ~= "" and normalized or nil -- 1209
end -- 1209
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1220
	if not customOptions then -- 1220
		return options -- 1224
	end -- 1224
	local merged = __TS__ObjectAssign({}, options) -- 1225
	for key in pairs(customOptions) do -- 1226
		do -- 1226
			if key == "auxiliaryOptions" then -- 1226
				goto __continue265 -- 1229
			end -- 1229
			local value = customOptions[key] -- 1230
			if value == json.null then -- 1230
				__TS__Delete(merged, key) -- 1232
			else -- 1232
				merged[key] = value -- 1234
			end -- 1234
		end -- 1234
		::__continue265:: -- 1234
	end -- 1234
	return merged -- 1237
end -- 1220
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
local function normalizeLLMTemperature(value) -- 1192
	if type(value) == "number" then -- 1192
		return math.max( -- 1194
			0, -- 1194
			math.min(2, value) -- 1194
		) -- 1194
	end -- 1194
	return 0.1 -- 1196
end -- 1192
local function normalizeLLMMaxTokens(value) -- 1199
	if type(value) == "number" then -- 1199
		return math.max( -- 1201
			1, -- 1201
			math.floor(value) -- 1201
		) -- 1201
	end -- 1201
	return AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1203
end -- 1199
local function normalizeLLMCustomOptions(value) -- 1212
	if type(value) ~= "string" then -- 1212
		return nil -- 1213
	end -- 1213
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1214
	if text == "" then -- 1214
		return nil -- 1215
	end -- 1215
	local decoded = ____exports.safeJsonDecode(text) -- 1216
	return isPlainRecord(decoded) and decoded or nil -- 1217
end -- 1212
local function getLLMConfigRecords() -- 1240
	upgradeLLMConfig() -- 1241
	local rows = DB:query("select * from LLMConfig", true) -- 1242
	local records = {} -- 1243
	if rows and #rows > 1 then -- 1243
		do -- 1243
			local i = 1 -- 1245
			while i < #rows do -- 1245
				local record = {} -- 1246
				do -- 1246
					local c = 0 -- 1247
					while c < #rows[i + 1] do -- 1247
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1248
						c = c + 1 -- 1247
					end -- 1247
				end -- 1247
				records[#records + 1] = record -- 1250
				i = i + 1 -- 1245
			end -- 1245
		end -- 1245
	end -- 1245
	return records -- 1253
end -- 1240
function ____exports.getLLMConfigSummaries() -- 1263
	return __TS__ArrayFlatMap( -- 1264
		getLLMConfigRecords(), -- 1264
		function(____, record) -- 1264
			local id = record.id -- 1265
			local name = record.name -- 1266
			local model = record.model -- 1267
			if type(id) ~= "number" or type(name) ~= "string" or type(model) ~= "string" then -- 1267
				return {} -- 1268
			end -- 1268
			return {{id = id, name = name, model = model, active = record.active ~= 0}} -- 1269
		end -- 1264
	) -- 1264
end -- 1263
local function parseLLMConfig(config) -- 1273
	if not config then -- 1273
		return {success = false, message = "LLM config not found"} -- 1275
	end -- 1275
	local ____config_27 = config -- 1277
	local id = ____config_27.id -- 1277
	local url = ____config_27.url -- 1277
	local model = ____config_27.model -- 1277
	local api_key = ____config_27.api_key -- 1277
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1277
		return {success = false, message = "got invalid LLM config"} -- 1279
	end -- 1279
	return { -- 1281
		success = true, -- 1282
		id = id, -- 1283
		config = { -- 1284
			url = url, -- 1285
			model = model, -- 1286
			apiKey = api_key, -- 1287
			contextWindow = normalizeContextWindow(config.context_window), -- 1288
			temperature = normalizeLLMTemperature(config.temperature), -- 1289
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1290
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1291
			customOptions = normalizeLLMCustomOptions(config.custom_options) -- 1292
		} -- 1292
	} -- 1292
end -- 1273
function ____exports.getLLMConfig(configId) -- 1297
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1298
	if normalizedId == nil or normalizedId <= 0 then -- 1298
		return {success = false, message = "LLM config is not selected"} -- 1300
	end -- 1300
	return parseLLMConfig(__TS__ArrayFind( -- 1302
		getLLMConfigRecords(), -- 1302
		function(____, record) return record.id == normalizedId end -- 1302
	)) -- 1302
end -- 1297
function ____exports.getActiveLLMConfig() -- 1305
	local records = getLLMConfigRecords() -- 1306
	local config = __TS__ArrayFind( -- 1307
		records, -- 1307
		function(____, r) return r.active ~= 0 end -- 1307
	) -- 1307
	if not config then -- 1307
		return {success = false, message = "no active LLM config"} -- 1309
	end -- 1309
	return parseLLMConfig(config) -- 1311
end -- 1305
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1314
	local callEvent -- 1320
	if event.id ~= nil then -- 1320
		local id = event.id -- 1322
		callEvent = { -- 1323
			id = nil, -- 1324
			onData = function(data) -- 1325
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1326
				return event.stopToken.stopped -- 1327
			end, -- 1325
			onCancel = function(reason) -- 1329
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1330
			end, -- 1329
			onDone = function() -- 1332
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1333
			end -- 1332
		} -- 1332
	else -- 1332
		callEvent = event -- 1337
	end -- 1337
	local ____callEvent_28 = callEvent -- 1339
	local onData = ____callEvent_28.onData -- 1339
	local onDone = ____callEvent_28.onDone -- 1339
	local ____callEvent_29 = callEvent -- 1340
	local onCancel = ____callEvent_29.onCancel -- 1340
	local config = llmConfig or (function() -- 1341
		local configRes = ____exports.getActiveLLMConfig() -- 1342
		if not configRes.success then -- 1342
			if onCancel then -- 1342
				onCancel(configRes.message) -- 1344
			end -- 1344
			return nil -- 1345
		end -- 1345
		return configRes.config -- 1347
	end)() -- 1341
	if not config then -- 1341
		return {success = false, message = "no active LLM config"} -- 1350
	end -- 1350
	local url = config.url -- 1350
	local model = config.model -- 1350
	local apiKey = config.apiKey -- 1350
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1353
	if fitted.trimmed then -- 1353
		____exports.Log( -- 1355
			"Warn", -- 1355
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1355
		) -- 1355
	end -- 1355
	local stopLLM = false -- 1357
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1358
	local parser = createScheduledSSEJSONParser( -- 1361
		{onJSON = function(obj) -- 1361
			local result = onData(obj) -- 1363
			if result then -- 1363
				stopLLM = true -- 1365
				streamStopToken.stopped = true -- 1366
				streamStopToken.reason = "LLM Stopped" -- 1367
			end -- 1367
		end}, -- 1362
		function() return streamStopToken.stopped end -- 1370
	); -- 1370
	(function() -- 1371
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1371
			local ____try = __TS__AsyncAwaiter(function() -- 1371
				local result = __TS__Await(postLLM( -- 1373
					fitted.messages, -- 1373
					url, -- 1373
					apiKey, -- 1373
					model, -- 1373
					options, -- 1373
					true, -- 1373
					config.customOptions, -- 1373
					function(data) -- 1373
						if stopLLM then -- 1373
							if onCancel then -- 1373
								onCancel("LLM Stopped") -- 1376
								onCancel = nil -- 1377
							end -- 1377
							return true -- 1379
						end -- 1379
						parser.append(data) -- 1381
						return false -- 1382
					end, -- 1373
					streamStopToken, -- 1383
					config.studioGateway -- 1383
				)) -- 1383
				__TS__Await(parser.finish()) -- 1384
				if onDone then -- 1384
					onDone(result) -- 1386
				end -- 1386
			end) -- 1386
			____try = ____try.catch( -- 1386
				____try, -- 1386
				function(____, e) -- 1386
					return __TS__AsyncAwaiter(function() -- 1386
						parser.cancel() -- 1389
						stopLLM = true -- 1390
						if onCancel then -- 1390
							onCancel(tostring(e)) -- 1392
							onCancel = nil -- 1393
						end -- 1393
					end) -- 1393
				end -- 1393
			) -- 1393
			__TS__Await(____try) -- 1372
		end) -- 1372
	end)() -- 1371
	return {success = true} -- 1397
end -- 1314
local function mergeStreamToolCall(target, delta) -- 1400
	if type(delta.id) == "string" and delta.id ~= "" then -- 1400
		target.id = delta.id -- 1402
	end -- 1402
	if type(delta.type) == "string" and delta.type ~= "" then -- 1402
		target.type = delta.type -- 1405
	end -- 1405
	if delta["function"] then -- 1405
		if target["function"] == nil then -- 1405
			target["function"] = {} -- 1408
		end -- 1408
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1408
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1410
		end -- 1410
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1410
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1413
		end -- 1413
	end -- 1413
end -- 1400
local function isToolCallComplete(tc) -- 1418
	if type(tc.id) ~= "string" or tc.id == "" then -- 1418
		return false -- 1419
	end -- 1419
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1419
		return false -- 1420
	end -- 1420
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1420
		return false -- 1421
	end -- 1421
	local args = tc["function"].arguments -- 1422
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1422
		return false -- 1423
	end -- 1423
	local decoded = ____exports.safeJsonDecode(args) -- 1424
	return decoded ~= nil -- 1425
end -- 1418
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1428
	local delta = choice.delta or ({}) -- 1429
	local fullMessage = choice.message or ({}) -- 1430
	local message = acc.message -- 1431
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1432
	if type(role) == "string" and role ~= "" then -- 1432
		message.role = role -- 1436
	end -- 1436
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1438
	if type(content) == "string" and content ~= "" then -- 1438
		message.content = (message.content or "") .. content -- 1442
	end -- 1442
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1444
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1444
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1448
	end -- 1448
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1450
	if #toolCalls > 0 then -- 1450
		if message.tool_calls == nil then -- 1450
			message.tool_calls = {} -- 1454
		end -- 1454
		do -- 1454
			local i = 0 -- 1455
			while i < #toolCalls do -- 1455
				local item = toolCalls[i + 1] -- 1456
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1457
				local ____message_tool_calls_30, ____temp_31 = message.tool_calls, index + 1 -- 1457
				if ____message_tool_calls_30[____temp_31] == nil then -- 1457
					____message_tool_calls_30[____temp_31] = {} -- 1460
				end -- 1460
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1461
				if onToolCallReady and emittedToolCallIds then -- 1461
					local tc = message.tool_calls[index + 1] -- 1463
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1463
						emittedToolCallIds[tc.id] = true -- 1465
						onToolCallReady(tc) -- 1466
					end -- 1466
				end -- 1466
				i = i + 1 -- 1455
			end -- 1455
		end -- 1455
	end -- 1455
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1455
		acc.finish_reason = choice.finish_reason -- 1472
	end -- 1472
end -- 1428
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1476
	local indexes = __TS__ArraySort( -- 1485
		__TS__ArrayFilter( -- 1485
			__TS__ArrayMap( -- 1485
				__TS__ObjectKeys(states), -- 1485
				function(____, key) return __TS__Number(key) end -- 1486
			), -- 1486
			function(____, index) return __TS__NumberIsFinite(index) end -- 1487
		), -- 1487
		function(____, a, b) return a - b end -- 1488
	) -- 1488
	return { -- 1489
		id = id, -- 1490
		created = created, -- 1491
		object = object, -- 1492
		model = model, -- 1493
		choices = __TS__ArrayMap( -- 1494
			indexes, -- 1494
			function(____, index) -- 1494
				local state = states[index] -- 1495
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1496
			end -- 1494
		), -- 1494
		usage = usage, -- 1507
		error = providerError -- 1508
	} -- 1508
end -- 1476
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1512
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1512
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1523
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1524
		local resolvedConfig = config or (function() -- 1527
			local configRes = ____exports.getActiveLLMConfig() -- 1528
			if not configRes.success then -- 1528
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1530
				return nil -- 1531
			end -- 1531
			return configRes.config -- 1533
		end)() -- 1527
		if not resolvedConfig then -- 1527
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1527
		end -- 1527
		local url = resolvedConfig.url -- 1527
		local model = resolvedConfig.model -- 1527
		local apiKey = resolvedConfig.apiKey -- 1527
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1539
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1540
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1541
		local ____model_36 = model -- 1544
		local ____url_37 = url -- 1544
		local ____temp_38 = #messages -- 1544
		local ____tostring_33 = tostring -- 1544
		local ____options_max_tokens_32 = options.max_tokens -- 1544
		if ____options_max_tokens_32 == nil then -- 1544
			____options_max_tokens_32 = "unset" -- 1544
		end -- 1544
		local ____tostring_33_result_39 = ____tostring_33(____options_max_tokens_32) -- 1544
		local ____tostring_35 = tostring -- 1544
		local ____options_temperature_34 = options.temperature -- 1544
		if ____options_temperature_34 == nil then -- 1544
			____options_temperature_34 = "unset" -- 1544
		end -- 1544
		____exports.Log( -- 1544
			"Info", -- 1544
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_36) .. " url=") .. ____url_37) .. " messages=") .. tostring(____temp_38)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_33_result_39) .. " temperature=") .. ____tostring_35(____options_temperature_34)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1544
		) -- 1544
		if stopToken and stopToken.stopped then -- 1544
			local reason = stopToken.reason or "request cancelled" -- 1546
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1547
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1547
		end -- 1547
		local ____hasReturned, ____returnValue -- 1547
		local ____try = __TS__AsyncAwaiter(function() -- 1547
			local states = {} -- 1551
			local emittedToolCallIds = {} -- 1552
			local responseId = nil -- 1553
			local responseCreated = nil -- 1554
			local responseObject = nil -- 1555
			local providerError -- 1556
			local responseUsage -- 1557
			local httpChunkCount = 0 -- 1558
			local rawStreamBytes = 0 -- 1559
			local rawStreamPreview = "" -- 1560
			local sseJSONChunkCount = 0 -- 1561
			local choiceJSONChunkCount = 0 -- 1562
			local emptyChoicesChunkCount = 0 -- 1563
			local missingChoicesChunkCount = 0 -- 1564
			local parseErrorCount = 0 -- 1565
			local doneChunkSeen = false -- 1566
			local lastJSONPreview = "" -- 1567
			local parser = createScheduledSSEJSONParser( -- 1568
				{ -- 1568
					onJSON = function(obj, raw) -- 1569
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1570
						lastJSONPreview = previewText(raw, 500) -- 1571
						if not obj or type(obj) ~= "table" then -- 1571
							return -- 1573
						end -- 1573
						local chunk = obj -- 1575
						if chunk.error then -- 1575
							providerError = chunk.error -- 1577
							____exports.Log( -- 1578
								"Warn", -- 1578
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1578
							) -- 1578
							return -- 1579
						end -- 1579
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1581
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1582
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1583
						if chunk.usage and type(chunk.usage) == "table" then -- 1583
							responseUsage = chunk.usage -- 1585
						end -- 1585
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1587
						if not __TS__ArrayIsArray(chunk.choices) then -- 1587
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1589
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1589
								____exports.Log( -- 1591
									"Warn", -- 1591
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1591
								) -- 1591
							end -- 1591
						elseif #choices == 0 then -- 1591
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1594
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1594
								____exports.Log( -- 1596
									"Warn", -- 1596
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1596
								) -- 1596
							end -- 1596
						else -- 1596
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1599
						end -- 1599
						do -- 1599
							local i = 0 -- 1601
							while i < #choices do -- 1601
								local choice = choices[i + 1] -- 1602
								local index = type(choice.index) == "number" and choice.index or i -- 1603
								if states[index] == nil then -- 1603
									states[index] = {index = index, message = {role = "assistant"}} -- 1604
								end -- 1604
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1608
								i = i + 1 -- 1601
							end -- 1601
						end -- 1601
						if onChunk ~= nil then -- 1601
							onChunk( -- 1610
								buildStreamResponse( -- 1611
									states, -- 1611
									model, -- 1611
									responseId, -- 1611
									responseCreated, -- 1611
									responseObject, -- 1611
									providerError, -- 1611
									responseUsage -- 1611
								), -- 1611
								{ -- 1612
									id = chunk.id or "", -- 1613
									created = chunk.created or 0, -- 1614
									object = chunk.object or "", -- 1615
									model = chunk.model or model, -- 1616
									choices = choices -- 1617
								} -- 1617
							) -- 1617
						end -- 1617
					end, -- 1569
					onDone = function() -- 1621
						doneChunkSeen = true -- 1622
					end, -- 1621
					onError = function(err, context) -- 1624
						parseErrorCount = parseErrorCount + 1 -- 1625
						____exports.Log( -- 1626
							"Warn", -- 1626
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1626
						) -- 1626
					end -- 1624
				}, -- 1624
				function() return (stopToken and stopToken.stopped) == true end -- 1628
			) -- 1628
			local ____try = __TS__AsyncAwaiter(function() -- 1628
				__TS__Await(postLLM( -- 1630
					fitted.messages, -- 1630
					url, -- 1630
					apiKey, -- 1630
					model, -- 1630
					options, -- 1630
					true, -- 1630
					resolvedConfig.customOptions, -- 1630
					function(data) -- 1630
						if stopToken and stopToken.stopped then -- 1630
							return true -- 1631
						end -- 1631
						httpChunkCount = httpChunkCount + 1 -- 1632
						rawStreamBytes = rawStreamBytes + #data -- 1633
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1633
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1635
						end -- 1635
						parser.append(data) -- 1637
						return false -- 1638
					end, -- 1630
					stopToken, -- 1639
					resolvedConfig.studioGateway -- 1639
				)) -- 1639
				__TS__Await(parser.finish()) -- 1640
			end) -- 1640
			____try = ____try.catch( -- 1640
				____try, -- 1640
				function(____, e) -- 1640
					return __TS__AsyncAwaiter(function() -- 1640
						parser.cancel() -- 1642
						error(e, 0) -- 1643
					end) -- 1643
				end -- 1643
			) -- 1643
			__TS__Await(____try) -- 1629
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1629
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1646
				if rawResponse and type(rawResponse) == "table" then -- 1646
					local rawResponseObj = rawResponse -- 1648
					if rawResponseObj.error then -- 1648
						providerError = rawResponseObj.error -- 1650
						lastJSONPreview = previewText( -- 1651
							normalizeLLMJSONResponse(rawStreamPreview), -- 1651
							500 -- 1651
						) -- 1651
						____exports.Log( -- 1652
							"Warn", -- 1652
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1652
						) -- 1652
					end -- 1652
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1652
						responseUsage = rawResponseObj.usage -- 1655
					end -- 1655
				end -- 1655
			end -- 1655
			local response = buildStreamResponse( -- 1659
				states, -- 1659
				model, -- 1659
				responseId, -- 1659
				responseCreated, -- 1659
				responseObject, -- 1659
				providerError, -- 1659
				responseUsage -- 1659
			) -- 1659
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1660
			local choiceCount = response.choices and #response.choices or 0 -- 1661
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1662
			____exports.Log( -- 1663
				"Info", -- 1663
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1663
			) -- 1663
			if not doneChunkSeen then -- 1663
				local rawPreview = previewText( -- 1665
					____exports.sanitizeUTF8(rawStreamPreview), -- 1665
					1200 -- 1665
				) -- 1665
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1666
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1667
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1668
				____hasReturned = true -- 1669
				____returnValue = { -- 1669
					success = false, -- 1670
					message = message, -- 1671
					raw = rawStreamPreview, -- 1672
					response = response, -- 1673
					tokenUsage = tokenUsage -- 1674
				} -- 1674
				return -- 1669
			end -- 1669
			if not response.choices or #response.choices == 0 then -- 1669
				local providerMessage = providerError and providerError.message or "" -- 1678
				local providerType = providerError and providerError.type or "" -- 1679
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1680
				local details = table.concat( -- 1683
					__TS__ArrayFilter( -- 1683
						{providerType, providerCode}, -- 1683
						function(____, part) return part ~= "" end -- 1683
					), -- 1683
					"/" -- 1683
				) -- 1683
				local rawPreview = previewText( -- 1684
					____exports.sanitizeUTF8(rawStreamPreview), -- 1684
					1200 -- 1684
				) -- 1684
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1685
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1686
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1689
				____hasReturned = true -- 1690
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1690
				return -- 1690
			end -- 1690
			____hasReturned = true -- 1697
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1697
			return -- 1697
		end) -- 1697
		____try = ____try.catch( -- 1697
			____try, -- 1697
			function(____, e) -- 1697
				return __TS__AsyncAwaiter(function() -- 1697
					if stopToken and stopToken.stopped then -- 1697
						local reason = stopToken.reason or "request cancelled" -- 1704
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1705
						____hasReturned = true -- 1706
						____returnValue = {success = false, message = reason} -- 1706
						return -- 1706
					end -- 1706
					____exports.Log( -- 1708
						"Error", -- 1708
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1708
					) -- 1708
					____hasReturned = true -- 1709
					____returnValue = { -- 1709
						success = false, -- 1709
						message = tostring(e) -- 1709
					} -- 1709
					return -- 1709
				end) -- 1709
			end -- 1709
		) -- 1709
		__TS__Await(____try) -- 1550
		if ____hasReturned then -- 1550
			return ____awaiter_resolve(nil, ____returnValue) -- 1550
		end -- 1550
	end) -- 1550
end -- 1512
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1713
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1713
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1719
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1720
		local resolvedConfig = config or (function() -- 1723
			local configRes = ____exports.getActiveLLMConfig() -- 1724
			if not configRes.success then -- 1724
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1726
				return nil -- 1727
			end -- 1727
			return configRes.config -- 1729
		end)() -- 1723
		if not resolvedConfig then -- 1723
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1723
		end -- 1723
		local url = resolvedConfig.url -- 1723
		local model = resolvedConfig.model -- 1723
		local apiKey = resolvedConfig.apiKey -- 1723
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1735
		____exports.Log( -- 1736
			"Info", -- 1736
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1736
		) -- 1736
		if stopToken and stopToken.stopped then -- 1736
			local reason = stopToken.reason or "request cancelled" -- 1738
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1739
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1739
		end -- 1739
		local ____hasReturned, ____returnValue -- 1739
		local ____try = __TS__AsyncAwaiter(function() -- 1739
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1743
				fitted.messages, -- 1743
				url, -- 1743
				apiKey, -- 1743
				model, -- 1743
				options, -- 1743
				false, -- 1743
				resolvedConfig.customOptions, -- 1743
				nil, -- 1743
				stopToken, -- 1743
				resolvedConfig.studioGateway -- 1743
			))) -- 1743
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1744
			____exports.Log( -- 1745
				"Info", -- 1745
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1745
			) -- 1745
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1746
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1746
				local rawPreview = previewText(raw) -- 1748
				____exports.Log( -- 1749
					"Error", -- 1749
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1749
				) -- 1749
				____hasReturned = true -- 1750
				____returnValue = { -- 1750
					success = false, -- 1751
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1752
					raw = raw -- 1753
				} -- 1753
				return -- 1750
			end -- 1750
			local responseObj = response -- 1756
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1757
			____exports.Log( -- 1758
				"Info", -- 1758
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1758
			) -- 1758
			if not responseObj.choices or #responseObj.choices == 0 then -- 1758
				local providerError = responseObj.error -- 1760
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1761
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1764
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1767
				local details = table.concat( -- 1770
					__TS__ArrayFilter( -- 1770
						{providerType, providerCode}, -- 1770
						function(____, part) return part ~= "" end -- 1770
					), -- 1770
					"/" -- 1770
				) -- 1770
				local rawPreview = previewText(raw, 400) -- 1771
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1772
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1775
				____hasReturned = true -- 1776
				____returnValue = {success = false, message = message, raw = raw} -- 1776
				return -- 1776
			end -- 1776
			____hasReturned = true -- 1782
			____returnValue = {success = true, response = responseObj} -- 1782
			return -- 1782
		end) -- 1782
		____try = ____try.catch( -- 1782
			____try, -- 1782
			function(____, e) -- 1782
				return __TS__AsyncAwaiter(function() -- 1782
					if stopToken and stopToken.stopped then -- 1782
						local reason = stopToken.reason or "request cancelled" -- 1788
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1789
						____hasReturned = true -- 1790
						____returnValue = {success = false, message = reason} -- 1790
						return -- 1790
					end -- 1790
					____exports.Log( -- 1792
						"Error", -- 1792
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1792
					) -- 1792
					____hasReturned = true -- 1793
					____returnValue = { -- 1793
						success = false, -- 1793
						message = tostring(e) -- 1793
					} -- 1793
					return -- 1793
				end) -- 1793
			end -- 1793
		) -- 1793
		__TS__Await(____try) -- 1742
		if ____hasReturned then -- 1742
			return ____awaiter_resolve(nil, ____returnValue) -- 1742
		end -- 1742
	end) -- 1742
end -- 1713
return ____exports -- 1713