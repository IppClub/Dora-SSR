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
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
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
function normalizeReasoningEffort(value) -- 1228
	if type(value) ~= "string" then -- 1228
		return nil -- 1229
	end -- 1229
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1230
	return normalized ~= "" and normalized or nil -- 1231
end -- 1231
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1242
	if not customOptions then -- 1242
		return options -- 1246
	end -- 1246
	local merged = __TS__ObjectAssign({}, options) -- 1247
	for key in pairs(customOptions) do -- 1248
		do -- 1248
			if key == "auxiliaryOptions" or key == "visionModel" then -- 1248
				goto __continue269 -- 1251
			end -- 1251
			local value = customOptions[key] -- 1252
			if value == json.null then -- 1252
				__TS__Delete(merged, key) -- 1254
			else -- 1254
				merged[key] = value -- 1256
			end -- 1256
		end -- 1256
		::__continue269:: -- 1256
	end -- 1256
	return merged -- 1259
end -- 1242
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
function ____exports.getInputTokenBudget(messages, options, config) -- 465
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 466
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 469
	local optionTokens = estimateOptionsTokens(options) -- 470
	local structuralOverhead = math.max(256, #messages * 16) -- 471
	return math.max(0, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 472
end -- 465
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 475
	if budgetTokens <= 0 or text == "" then -- 475
		return "" -- 476
	end -- 476
	local estimated = ____exports.estimateTextTokens(text) -- 477
	if estimated <= budgetTokens then -- 477
		return text -- 478
	end -- 478
	local marker = "\n...\n" -- 482
	if ____exports.estimateTextTokens(marker) > budgetTokens then -- 482
		return "" -- 483
	end -- 483
	local characters = utf8.len(text) -- 484
	if characters == nil then -- 484
		return "" -- 485
	end -- 485
	local low = 0 -- 486
	local high = characters -- 487
	local best = marker -- 488
	while low <= high do -- 488
		local keep = math.floor((low + high) / 2) -- 490
		local head = math.floor(keep * 0.35) -- 491
		local candidate = (utf8TakeHead(text, head) .. marker) .. utf8TakeTail(text, keep - head) -- 492
		if ____exports.estimateTextTokens(candidate) <= budgetTokens then -- 492
			best = candidate -- 494
			low = keep + 1 -- 495
		else -- 495
			high = keep - 1 -- 497
		end -- 497
	end -- 497
	return best -- 500
end -- 475
local function isXMLWhitespaceChar(ch) -- 503
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 504
end -- 503
local function findLineStart(value, from) -- 507
	local i = from -- 508
	while i >= 0 do -- 508
		if __TS__StringAccess(value, i) == "\n" then -- 508
			return i + 1 -- 510
		end -- 510
		i = i - 1 -- 511
	end -- 511
	return 0 -- 513
end -- 507
local function findLastLiteral(text, needle) -- 516
	if needle == "" then -- 516
		return #text -- 517
	end -- 517
	local last = -1 -- 518
	local from = 0 -- 519
	while from <= #text - #needle do -- 519
		local pos = (string.find( -- 521
			text, -- 521
			needle, -- 521
			math.max(from + 1, 1), -- 521
			true -- 521
		) or 0) - 1 -- 521
		if pos < 0 then -- 521
			break -- 522
		end -- 522
		last = pos -- 523
		from = pos + 1 -- 524
	end -- 524
	return last -- 526
end -- 516
local function unwrapXMLRawText(text) -- 529
	local trimmed = __TS__StringTrim(text) -- 530
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 530
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 532
	end -- 532
	return text -- 534
end -- 529
local function readSimpleXMLTagName(source, openStart, openEnd) -- 537
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 538
	if rawTag == "" then -- 538
		return { -- 540
			success = false, -- 540
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 540
		} -- 540
	end -- 540
	local selfClosing = false -- 542
	local tagText = rawTag -- 543
	if __TS__StringEndsWith(tagText, "/") then -- 543
		selfClosing = true -- 545
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 546
	end -- 546
	local tagName = "" -- 548
	do -- 548
		local i = 0 -- 549
		while i < #tagText do -- 549
			local ch = __TS__StringAccess(tagText, i) -- 550
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 550
				break -- 551
			end -- 551
			tagName = tagName .. ch -- 552
			i = i + 1 -- 549
		end -- 549
	end -- 549
	if tagName == "" then -- 549
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 555
	end -- 555
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 557
end -- 537
local function findMatchingXMLClose(source, tagName, contentStart) -- 560
	local sameOpenPrefix = "<" .. tagName -- 561
	local sameCloseToken = ("</" .. tagName) .. ">" -- 562
	local pos = contentStart -- 563
	local depth = 1 -- 564
	while pos < #source do -- 564
		do -- 564
			local lt = (string.find( -- 566
				source, -- 566
				"<", -- 566
				math.max(pos + 1, 1), -- 566
				true -- 566
			) or 0) - 1 -- 566
			if lt < 0 then -- 566
				break -- 567
			end -- 567
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 567
				local cdataEnd = (string.find( -- 569
					source, -- 569
					"]]>", -- 569
					math.max(lt + 9 + 1, 1), -- 569
					true -- 569
				) or 0) - 1 -- 569
				if cdataEnd < 0 then -- 569
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 570
				end -- 570
				pos = cdataEnd + 3 -- 571
				goto __continue133 -- 572
			end -- 572
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 575
					source, -- 575
					"-->",
					math.max(lt + 4 + 1, 1), -- 575
					true -- 575
				) or 0) - 1 -- 575
				if commentEnd < 0 then -- 575
					return {success = false, message = "invalid xml: unterminated comment"} -- 576
				end -- 576
				pos = commentEnd + 3 -- 577
				goto __continue133 -- 578
			end -- 578
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 578
				depth = depth - 1 -- 581
				if depth == 0 then -- 581
					return {success = true, closeStart = lt} -- 582
				end -- 582
				pos = lt + #sameCloseToken -- 583
				goto __continue133 -- 584
			end -- 584
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 584
				local openEnd = (string.find( -- 587
					source, -- 587
					">", -- 587
					math.max(lt + 1, 1), -- 587
					true -- 587
				) or 0) - 1 -- 587
				if openEnd < 0 then -- 587
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 588
				end -- 588
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 589
				if not tagInfo.success then -- 589
					return tagInfo -- 590
				end -- 590
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 590
					depth = depth + 1 -- 592
				end -- 592
				pos = openEnd + 1 -- 594
				goto __continue133 -- 595
			end -- 595
			local genericEnd = (string.find( -- 597
				source, -- 597
				">", -- 597
				math.max(lt + 1, 1), -- 597
				true -- 597
			) or 0) - 1 -- 597
			if genericEnd < 0 then -- 597
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 598
			end -- 598
			pos = genericEnd + 1 -- 599
		end -- 599
		::__continue133:: -- 599
	end -- 599
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 601
end -- 560
function ____exports.extractXMLFromText(text) -- 604
	local source = __TS__StringTrim(text) -- 605
	local function extractFencedBlock(fence) -- 606
		if not __TS__StringStartsWith(source, fence) then -- 606
			return nil -- 607
		end -- 607
		local firstLineEnd = (string.find( -- 608
			source, -- 608
			"\n", -- 608
			math.max(1, 1), -- 608
			true -- 608
		) or 0) - 1 -- 608
		if firstLineEnd < 0 then -- 608
			return nil -- 609
		end -- 609
		local searchPos = firstLineEnd + 1 -- 610
		local closingFencePositions = {} -- 611
		while searchPos < #source do -- 611
			local ____end = (string.find( -- 613
				source, -- 613
				"```", -- 613
				math.max(searchPos + 1, 1), -- 613
				true -- 613
			) or 0) - 1 -- 613
			if ____end < 0 then -- 613
				break -- 614
			end -- 614
			local lineStart = findLineStart(source, ____end - 1) -- 615
			local lineEnd = (string.find( -- 616
				source, -- 616
				"\n", -- 616
				math.max(____end + 1, 1), -- 616
				true -- 616
			) or 0) - 1 -- 616
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 617
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 617
				closingFencePositions[#closingFencePositions + 1] = ____end -- 619
			end -- 619
			searchPos = ____end + 1 -- 621
		end -- 621
		do -- 621
			local i = #closingFencePositions - 1 -- 623
			while i >= 0 do -- 623
				do -- 623
					local closingFencePos = closingFencePositions[i + 1] -- 624
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 625
					if afterFence ~= "" then -- 625
						goto __continue154 -- 626
					end -- 626
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 627
				end -- 627
				::__continue154:: -- 627
				i = i - 1 -- 623
			end -- 623
		end -- 623
		return nil -- 629
	end -- 606
	local xmlBlock = extractFencedBlock("```xml") -- 631
	if xmlBlock ~= nil then -- 631
		return xmlBlock -- 632
	end -- 632
	local genericBlock = extractFencedBlock("```") -- 633
	if genericBlock ~= nil then -- 633
		return genericBlock -- 634
	end -- 634
	return source -- 635
end -- 604
function ____exports.parseSimpleXMLChildren(source) -- 638
	local result = {} -- 639
	local pos = 0 -- 640
	while pos < #source do -- 640
		do -- 640
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 640
				pos = pos + 1 -- 642
			end -- 642
			if pos >= #source then -- 642
				break -- 643
			end -- 643
			if __TS__StringAccess(source, pos) ~= "<" then -- 643
				return { -- 645
					success = false, -- 645
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 645
				} -- 645
			end -- 645
			if __TS__StringStartsWith(source, "</", pos) then -- 645
				return { -- 648
					success = false, -- 648
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 648
				} -- 648
			end -- 648
			local openEnd = (string.find( -- 650
				source, -- 650
				">", -- 650
				math.max(pos + 1, 1), -- 650
				true -- 650
			) or 0) - 1 -- 650
			if openEnd < 0 then -- 650
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 652
			end -- 652
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 654
			if not tagInfo.success then -- 654
				return tagInfo -- 655
			end -- 655
			if tagInfo.selfClosing then -- 655
				result[tagInfo.tagName] = "" -- 657
				pos = openEnd + 1 -- 658
				goto __continue159 -- 659
			end -- 659
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 661
			if not closeRes.success then -- 661
				return closeRes -- 662
			end -- 662
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 663
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 664
			pos = closeRes.closeStart + #closeToken -- 665
		end -- 665
		::__continue159:: -- 665
	end -- 665
	return {success = true, obj = result} -- 667
end -- 638
function ____exports.parseXMLObjectFromText(text, rootTag) -- 670
	local xmlText = ____exports.extractXMLFromText(text) -- 671
	local rootOpen = ("<" .. rootTag) .. ">" -- 672
	local rootClose = ("</" .. rootTag) .. ">" -- 673
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 674
	local ____end = findLastLiteral(xmlText, rootClose) -- 675
	if start < 0 or ____end < start then -- 675
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 677
	end -- 677
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 679
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 680
	if beforeRoot ~= "" or afterRoot ~= "" then -- 680
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 682
	end -- 682
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 684
	return ____exports.parseSimpleXMLChildren(rootContent) -- 685
end -- 670
function ____exports.fitMessagesToContext(messages, options, config) -- 688
	local modelName = string.lower(config.model) -- 695
	local shouldEchoReasoningContent = __TS__ArraySome( -- 696
		messages, -- 696
		function(____, message) return type(message.reasoning_content) == "string" end -- 696
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 696
	local cloned = __TS__ArrayMap( -- 700
		messages, -- 700
		function(____, message) -- 700
			local clonedMessage = __TS__ObjectAssign({}, message) -- 701
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 701
				clonedMessage.reasoning_content = "" -- 707
			end -- 707
			return clonedMessage -- 709
		end -- 700
	) -- 700
	local budgetTokens = ____exports.getInputTokenBudget(cloned, options, config) -- 711
	local originalTokens = estimateMessagesTokens(cloned) -- 712
	if originalTokens <= budgetTokens then -- 712
		return { -- 714
			messages = cloned, -- 715
			trimmed = false, -- 716
			originalTokens = originalTokens, -- 717
			fittedTokens = originalTokens, -- 718
			budgetTokens = budgetTokens -- 719
		} -- 719
	end -- 719
	local function roleOverhead(message) -- 723
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 723
	end -- 723
	local fixedOverhead = 0 -- 724
	local contentIndexes = {} -- 725
	do -- 725
		local i = 0 -- 726
		while i < #cloned do -- 726
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 727
			contentIndexes[#contentIndexes + 1] = i -- 728
			i = i + 1 -- 726
		end -- 726
	end -- 726
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 730
	if #contentIndexes == 1 then -- 730
		local idx = contentIndexes[1] -- 732
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 733
		local fittedTokens = estimateMessagesTokens(cloned) -- 734
		return { -- 735
			messages = cloned, -- 736
			trimmed = true, -- 737
			originalTokens = originalTokens, -- 738
			fittedTokens = fittedTokens, -- 739
			budgetTokens = budgetTokens -- 740
		} -- 740
	end -- 740
	local nonSystemIndexes = {} -- 744
	local systemIndexes = {} -- 745
	do -- 745
		local i = 0 -- 746
		while i < #cloned do -- 746
			if cloned[i + 1].role == "system" then -- 746
				systemIndexes[#systemIndexes + 1] = i -- 747
			else -- 747
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 748
			end -- 748
			i = i + 1 -- 746
		end -- 746
	end -- 746
	local ____array_1 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 746
	__TS__SparseArrayPush( -- 746
		____array_1, -- 746
		table.unpack(systemIndexes) -- 750
	) -- 750
	local priorityIndexes = {__TS__SparseArraySpread(____array_1)} -- 750
	local remainingContentBudget = contentBudget -- 751
	do -- 751
		local i = #priorityIndexes - 1 -- 752
		while i >= 0 do -- 752
			local idx = priorityIndexes[i + 1] -- 753
			local message = cloned[idx + 1] -- 754
			local minBudget = message.role == "system" and 96 or 192 -- 755
			local target = math.max( -- 756
				minBudget, -- 756
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 756
			) -- 756
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 757
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 758
			remainingContentBudget = math.max(0, remainingContentBudget) -- 759
			i = i - 1 -- 752
		end -- 752
	end -- 752
	local fittedTokens = estimateMessagesTokens(cloned) -- 762
	if fittedTokens > budgetTokens then -- 762
		do -- 762
			local i = 0 -- 764
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 764
				local idx = priorityIndexes[i + 1] -- 765
				local message = cloned[idx + 1] -- 766
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 767
				local excess = fittedTokens - budgetTokens -- 768
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 769
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 770
				fittedTokens = estimateMessagesTokens(cloned) -- 771
				i = i + 1 -- 764
			end -- 764
		end -- 764
	end -- 764
	if fittedTokens > budgetTokens then -- 764
		do -- 764
			local i = 0 -- 775
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 775
				do -- 775
					local idx = priorityIndexes[i + 1] -- 776
					if cloned[idx + 1].role == "system" then -- 776
						goto __continue191 -- 777
					end -- 777
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 778
					fittedTokens = estimateMessagesTokens(cloned) -- 779
				end -- 779
				::__continue191:: -- 779
				i = i + 1 -- 775
			end -- 775
		end -- 775
	end -- 775
	return { -- 782
		messages = cloned, -- 783
		trimmed = true, -- 784
		originalTokens = originalTokens, -- 785
		fittedTokens = fittedTokens, -- 786
		budgetTokens = budgetTokens -- 787
	} -- 787
end -- 688
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken, studioGateway) -- 791
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 803
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 804
	local data = __TS__ObjectAssign({}, requestOptions, {model = model, messages = messages, stream = stream}) -- 805
	local studioRequestId = studioGateway and ____exports.createStudioModelRequestId() or nil -- 811
	if stopToken == nil then -- 811
		stopToken = {stopped = false} -- 812
	end -- 812
	return __TS__New( -- 813
		__TS__Promise, -- 813
		function(____, resolve, reject) -- 813
			local requestId = 0 -- 814
			local settled = false -- 815
			local function finishResolve(text) -- 816
				if settled then -- 816
					return -- 817
				end -- 817
				settled = true -- 818
				resolve(nil, text) -- 819
			end -- 816
			local function finishReject(err) -- 821
				if settled then -- 821
					return -- 822
				end -- 822
				settled = true -- 823
				reject(nil, err) -- 824
			end -- 821
			Director.systemScheduler:schedule(function() -- 826
				if not settled then -- 826
					if stopToken.stopped then -- 826
						if requestId ~= 0 then -- 826
							HttpClient:cancel(requestId) -- 830
							requestId = 0 -- 831
						end -- 831
						finishReject("request cancelled") -- 833
						return true -- 834
					end -- 834
					return false -- 836
				end -- 836
				return true -- 838
			end) -- 826
			Director.systemScheduler:schedule(once(function() -- 840
				emit( -- 841
					"LLM_IN", -- 841
					table.concat( -- 841
						__TS__ArrayMap( -- 841
							messages, -- 841
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 841
						), -- 841
						"\n" -- 841
					) -- 841
				) -- 841
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 842
				if jsonStr ~= nil then -- 842
					local headers = { -- 844
						"Authorization: Bearer " .. apiKey, -- 845
						"Content-Type: application/json", -- 846
						receiver and "Accept: text/event-stream" or "Accept: application/json", -- 847
						table.unpack(studioRequestId and ({"X-Studio-Model-Request-Id: " .. studioRequestId}) or ({})) -- 848
					} -- 848
					requestId = receiver and HttpClient:post( -- 850
						url, -- 851
						headers, -- 851
						jsonStr, -- 851
						requestTimeout, -- 851
						function(data) -- 851
							if stopToken.stopped then -- 851
								return true -- 852
							end -- 852
							return receiver(data) -- 853
						end, -- 851
						function(data) -- 854
							requestId = 0 -- 855
							if data ~= nil then -- 855
								finishResolve(data) -- 857
							else -- 857
								finishReject("failed to get http response") -- 859
							end -- 859
						end -- 854
					) or HttpClient:post( -- 854
						url, -- 862
						headers, -- 862
						jsonStr, -- 862
						requestTimeout, -- 862
						function(data) -- 862
							requestId = 0 -- 863
							if stopToken.stopped then -- 863
								finishReject("request cancelled") -- 865
								return -- 866
							end -- 866
							if data ~= nil then -- 866
								finishResolve(data) -- 869
							else -- 869
								finishReject("failed to get http response") -- 871
							end -- 871
						end -- 862
					) -- 862
					if requestId == 0 then -- 862
						finishReject("failed to schedule http request") -- 875
					elseif stopToken.stopped then -- 875
						HttpClient:cancel(requestId) -- 877
						requestId = 0 -- 878
						finishReject("request cancelled") -- 879
					end -- 879
				else -- 879
					finishReject(err) -- 882
				end -- 882
			end)) -- 840
		end -- 813
	) -- 813
end -- 791
function ____exports.createSSEJSONParser(opts) -- 892
	local buffer = "" -- 897
	local eventDataLines = {} -- 898
	local function flushEventIfAny() -- 900
		if #eventDataLines == 0 then -- 900
			return -- 901
		end -- 901
		local dataPayload = table.concat(eventDataLines, "\n") -- 903
		eventDataLines = {} -- 904
		if dataPayload == "[DONE]" then -- 904
			local ____opt_2 = opts.onDone -- 904
			if ____opt_2 ~= nil then -- 904
				____opt_2(dataPayload) -- 907
			end -- 907
			return -- 908
		end -- 908
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 911
		if err == nil then -- 911
			opts.onJSON(obj, dataPayload) -- 913
		else -- 913
			local ____opt_4 = opts.onError -- 913
			if ____opt_4 ~= nil then -- 913
				____opt_4(err, {raw = dataPayload}) -- 915
			end -- 915
		end -- 915
	end -- 900
	local function append(chunk) -- 919
		buffer = buffer .. chunk -- 920
	end -- 919
	local function drain(maxLines) -- 923
		local processedLines = 0 -- 924
		while maxLines == nil or processedLines < maxLines do -- 924
			do -- 924
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 926
				if nl < 0 then -- 926
					break -- 927
				end -- 927
				processedLines = processedLines + 1 -- 928
				local line = __TS__StringSlice(buffer, 0, nl) -- 930
				buffer = __TS__StringSlice(buffer, nl + 1) -- 931
				if __TS__StringEndsWith(line, "\r") then -- 931
					line = string.sub(line, 1, -2) -- 933
				end -- 933
				if line == "" then -- 933
					flushEventIfAny() -- 936
					goto __continue226 -- 937
				end -- 937
				if __TS__StringStartsWith(line, ":") then -- 937
					goto __continue226 -- 941
				end -- 941
				if __TS__StringStartsWith(line, "data:") then -- 941
					local v = string.sub(line, 6) -- 944
					if __TS__StringStartsWith(v, " ") then -- 944
						v = string.sub(v, 2) -- 945
					end -- 945
					eventDataLines[#eventDataLines + 1] = v -- 946
					goto __continue226 -- 947
				end -- 947
			end -- 947
			::__continue226:: -- 947
		end -- 947
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0 -- 950
	end -- 923
	local function feed(chunk) -- 953
		append(chunk) -- 954
		drain() -- 955
	end -- 953
	local function ____end() -- 958
		if #buffer > 0 then -- 958
			local line = buffer -- 960
			buffer = "" -- 961
			if __TS__StringEndsWith(line, "\r") then -- 961
				line = string.sub(line, 1, -2) -- 962
			end -- 962
			if __TS__StringStartsWith(line, "data:") then -- 962
				local v = string.sub(line, 6) -- 965
				if __TS__StringStartsWith(v, " ") then -- 965
					v = string.sub(v, 2) -- 966
				end -- 966
				eventDataLines[#eventDataLines + 1] = v -- 967
			end -- 967
		end -- 967
		flushEventIfAny() -- 970
	end -- 958
	local function discard() -- 973
		buffer = "" -- 974
		eventDataLines = {} -- 975
	end -- 973
	return { -- 978
		append = append, -- 978
		drain = drain, -- 978
		feed = feed, -- 978
		["end"] = ____end, -- 978
		discard = discard -- 978
	} -- 978
end -- 892
local SSE_PARSE_LINES_PER_FRAME = 256 -- 981
local function createScheduledSSEJSONParser(opts, isCancelled) -- 983
	local parser = ____exports.createSSEJSONParser(opts) -- 987
	local inputFinished = false -- 988
	local settled = false -- 989
	local resolveFinished -- 990
	local finished = __TS__New( -- 991
		__TS__Promise, -- 991
		function(____, resolve) -- 991
			resolveFinished = resolve -- 992
		end -- 991
	) -- 991
	local function settle() -- 994
		if settled then -- 994
			return -- 995
		end -- 995
		settled = true -- 996
		if resolveFinished ~= nil then -- 996
			resolveFinished() -- 997
		end -- 997
	end -- 994
	Director.systemScheduler:schedule(function() -- 999
		if settled then -- 999
			return true -- 1000
		end -- 1000
		if isCancelled and isCancelled() then -- 1000
			parser.discard() -- 1002
			settle() -- 1003
			return true -- 1004
		end -- 1004
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME) -- 1006
		if inputFinished and not hasMoreCompleteLines then -- 1006
			parser["end"]() -- 1008
			settle() -- 1009
			return true -- 1010
		end -- 1010
		return false -- 1012
	end) -- 999
	return { -- 1014
		append = parser.append, -- 1015
		finish = function() -- 1016
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1016
				inputFinished = true -- 1017
				__TS__Await(finished) -- 1018
			end) -- 1018
		end, -- 1016
		cancel = function() -- 1020
			parser.discard() -- 1021
			settle() -- 1022
		end -- 1020
	} -- 1020
end -- 983
function ____exports.extractLLMTokenUsage(response) -- 1118
	local usage = response and response.usage -- 1119
	if not usage or type(usage) ~= "table" then -- 1119
		return nil -- 1120
	end -- 1120
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1121
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1124
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1124
		return nil -- 1127
	end -- 1127
	local ____temp_17 -- 1128
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1128
		____temp_17 = usage.prompt_cache_hit_tokens -- 1129
	else -- 1129
		local ____temp_16 -- 1130
		local ____opt_12 = usage.prompt_tokens_details -- 1130
		if type(____opt_12 and ____opt_12.cached_tokens) == "number" then -- 1130
			____temp_16 = usage.prompt_tokens_details.cached_tokens -- 1131
		else -- 1131
			local ____opt_14 = usage.input_tokens_details -- 1131
			____temp_16 = type(____opt_14 and ____opt_14.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1132
		end -- 1132
		____temp_17 = ____temp_16 -- 1130
	end -- 1130
	local cachedInputTokens = ____temp_17 -- 1128
	local ____inputTokens_20 = inputTokens -- 1136
	local ____outputTokens_21 = outputTokens -- 1137
	local ____temp_22 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1138
	local ____temp_23 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1139
	local ____temp_24 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1140
	local ____opt_18 = usage.completion_tokens_details -- 1140
	return { -- 1135
		inputTokens = ____inputTokens_20, -- 1136
		outputTokens = ____outputTokens_21, -- 1137
		totalTokens = ____temp_22, -- 1138
		cachedInputTokens = ____temp_23, -- 1139
		cacheMissInputTokens = ____temp_24, -- 1140
		reasoningOutputTokens = type(____opt_18 and ____opt_18.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1143
	} -- 1143
end -- 1118
function ____exports.validateAgentLLMConfig(config) -- 1187
	local ____opt_25 = config.customOptions -- 1187
	local visionModel = ____opt_25 and ____opt_25.visionModel -- 1188
	if visionModel ~= nil and visionModel ~= json.null and type(visionModel) ~= "string" then -- 1188
		return {success = false, message = "视觉模型名称 visionModel 必须是字符串；留空使用默认行为。"} -- 1190
	end -- 1190
	local ____opt_27 = config.customOptions -- 1190
	local auxiliaryOptions = ____opt_27 and ____opt_27.auxiliaryOptions -- 1192
	local emptyOptions = type(auxiliaryOptions) == "table" and auxiliaryOptions ~= nil and auxiliaryOptions ~= json.null and #__TS__ObjectKeys(auxiliaryOptions) == 0 -- 1193
	if isPlainRecord(auxiliaryOptions) or emptyOptions then -- 1193
		return {success = true} -- 1199
	end -- 1199
	return {success = false, message = "LLM 配置的 customOptions 必须包含 auxiliaryOptions 对象（可以为空），请检查 LLM 配置"} -- 1201
end -- 1187
local function normalizeContextWindow(value) -- 1207
	if type(value) == "number" and value > 0 then -- 1207
		return math.floor(value) -- 1209
	end -- 1209
	return 64000 -- 1211
end -- 1207
local function normalizeLLMTemperature(value) -- 1214
	if type(value) == "number" then -- 1214
		return math.max( -- 1216
			0, -- 1216
			math.min(2, value) -- 1216
		) -- 1216
	end -- 1216
	return 0.1 -- 1218
end -- 1214
local function normalizeLLMMaxTokens(value) -- 1221
	if type(value) == "number" then -- 1221
		return math.max( -- 1223
			1, -- 1223
			math.floor(value) -- 1223
		) -- 1223
	end -- 1223
	return AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1225
end -- 1221
local function normalizeLLMCustomOptions(value) -- 1234
	if type(value) ~= "string" then -- 1234
		return nil -- 1235
	end -- 1235
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1236
	if text == "" then -- 1236
		return nil -- 1237
	end -- 1237
	local decoded = ____exports.safeJsonDecode(text) -- 1238
	return isPlainRecord(decoded) and decoded or nil -- 1239
end -- 1234
local function getLLMConfigRecords() -- 1262
	upgradeLLMConfig() -- 1263
	local rows = DB:query("select * from LLMConfig", true) -- 1264
	local records = {} -- 1265
	if rows and #rows > 1 then -- 1265
		do -- 1265
			local i = 1 -- 1267
			while i < #rows do -- 1267
				local record = {} -- 1268
				do -- 1268
					local c = 0 -- 1269
					while c < #rows[i + 1] do -- 1269
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1270
						c = c + 1 -- 1269
					end -- 1269
				end -- 1269
				records[#records + 1] = record -- 1272
				i = i + 1 -- 1267
			end -- 1267
		end -- 1267
	end -- 1267
	return records -- 1275
end -- 1262
function ____exports.getLLMConfigSummaries() -- 1285
	return __TS__ArrayFlatMap( -- 1286
		getLLMConfigRecords(), -- 1286
		function(____, record) -- 1286
			local id = record.id -- 1287
			local name = record.name -- 1288
			local model = record.model -- 1289
			if type(id) ~= "number" or type(name) ~= "string" or type(model) ~= "string" then -- 1289
				return {} -- 1290
			end -- 1290
			return {{id = id, name = name, model = model, active = record.active ~= 0}} -- 1291
		end -- 1286
	) -- 1286
end -- 1285
local function parseLLMConfig(config) -- 1295
	if not config then -- 1295
		return {success = false, message = "LLM config not found"} -- 1297
	end -- 1297
	local ____config_29 = config -- 1299
	local id = ____config_29.id -- 1299
	local url = ____config_29.url -- 1299
	local model = ____config_29.model -- 1299
	local api_key = ____config_29.api_key -- 1299
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1299
		return {success = false, message = "got invalid LLM config"} -- 1301
	end -- 1301
	return { -- 1303
		success = true, -- 1304
		id = id, -- 1305
		config = { -- 1306
			url = url, -- 1307
			model = model, -- 1308
			apiKey = api_key, -- 1309
			contextWindow = normalizeContextWindow(config.context_window), -- 1310
			temperature = normalizeLLMTemperature(config.temperature), -- 1311
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1312
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1313
			customOptions = normalizeLLMCustomOptions(config.custom_options) -- 1314
		} -- 1314
	} -- 1314
end -- 1295
function ____exports.getLLMConfig(configId) -- 1319
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1320
	if normalizedId == nil or normalizedId <= 0 then -- 1320
		return {success = false, message = "LLM config is not selected"} -- 1322
	end -- 1322
	return parseLLMConfig(__TS__ArrayFind( -- 1324
		getLLMConfigRecords(), -- 1324
		function(____, record) return record.id == normalizedId end -- 1324
	)) -- 1324
end -- 1319
function ____exports.getActiveLLMConfig() -- 1327
	local records = getLLMConfigRecords() -- 1328
	local config = __TS__ArrayFind( -- 1329
		records, -- 1329
		function(____, r) return r.active ~= 0 end -- 1329
	) -- 1329
	if not config then -- 1329
		return {success = false, message = "no active LLM config"} -- 1331
	end -- 1331
	return parseLLMConfig(config) -- 1333
end -- 1327
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1336
	local callEvent -- 1342
	if event.id ~= nil then -- 1342
		local id = event.id -- 1344
		callEvent = { -- 1345
			id = nil, -- 1346
			onData = function(data) -- 1347
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1348
				return event.stopToken.stopped -- 1349
			end, -- 1347
			onCancel = function(reason) -- 1351
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1352
			end, -- 1351
			onDone = function() -- 1354
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1355
			end -- 1354
		} -- 1354
	else -- 1354
		callEvent = event -- 1359
	end -- 1359
	local ____callEvent_30 = callEvent -- 1361
	local onData = ____callEvent_30.onData -- 1361
	local onDone = ____callEvent_30.onDone -- 1361
	local ____callEvent_31 = callEvent -- 1362
	local onCancel = ____callEvent_31.onCancel -- 1362
	local config = llmConfig or (function() -- 1363
		local configRes = ____exports.getActiveLLMConfig() -- 1364
		if not configRes.success then -- 1364
			if onCancel then -- 1364
				onCancel(configRes.message) -- 1366
			end -- 1366
			return nil -- 1367
		end -- 1367
		return configRes.config -- 1369
	end)() -- 1363
	if not config then -- 1363
		return {success = false, message = "no active LLM config"} -- 1372
	end -- 1372
	local url = config.url -- 1372
	local model = config.model -- 1372
	local apiKey = config.apiKey -- 1372
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1375
	if fitted.fittedTokens > fitted.budgetTokens then -- 1375
		return {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."} -- 1377
	end -- 1377
	if fitted.trimmed then -- 1377
		____exports.Log( -- 1380
			"Warn", -- 1380
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1380
		) -- 1380
	end -- 1380
	local stopLLM = false -- 1382
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1383
	local parser = createScheduledSSEJSONParser( -- 1386
		{onJSON = function(obj) -- 1386
			local result = onData(obj) -- 1388
			if result then -- 1388
				stopLLM = true -- 1390
				streamStopToken.stopped = true -- 1391
				streamStopToken.reason = "LLM Stopped" -- 1392
			end -- 1392
		end}, -- 1387
		function() return streamStopToken.stopped end -- 1395
	); -- 1395
	(function() -- 1396
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1396
			local ____try = __TS__AsyncAwaiter(function() -- 1396
				local result = __TS__Await(postLLM( -- 1398
					fitted.messages, -- 1398
					url, -- 1398
					apiKey, -- 1398
					model, -- 1398
					options, -- 1398
					true, -- 1398
					config.customOptions, -- 1398
					function(data) -- 1398
						if stopLLM then -- 1398
							if onCancel then -- 1398
								onCancel("LLM Stopped") -- 1401
								onCancel = nil -- 1402
							end -- 1402
							return true -- 1404
						end -- 1404
						parser.append(data) -- 1406
						return false -- 1407
					end, -- 1398
					streamStopToken, -- 1408
					config.studioGateway -- 1408
				)) -- 1408
				__TS__Await(parser.finish()) -- 1409
				if onDone then -- 1409
					onDone(result) -- 1411
				end -- 1411
			end) -- 1411
			____try = ____try.catch( -- 1411
				____try, -- 1411
				function(____, e) -- 1411
					return __TS__AsyncAwaiter(function() -- 1411
						parser.cancel() -- 1414
						stopLLM = true -- 1415
						if onCancel then -- 1415
							onCancel(tostring(e)) -- 1417
							onCancel = nil -- 1418
						end -- 1418
					end) -- 1418
				end -- 1418
			) -- 1418
			__TS__Await(____try) -- 1397
		end) -- 1397
	end)() -- 1396
	return {success = true} -- 1422
end -- 1336
local function mergeStreamToolCall(target, delta) -- 1425
	if type(delta.id) == "string" and delta.id ~= "" then -- 1425
		target.id = delta.id -- 1427
	end -- 1427
	if type(delta.type) == "string" and delta.type ~= "" then -- 1427
		target.type = delta.type -- 1430
	end -- 1430
	if delta["function"] then -- 1430
		if target["function"] == nil then -- 1430
			target["function"] = {} -- 1433
		end -- 1433
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1433
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1435
		end -- 1435
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1435
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1438
		end -- 1438
	end -- 1438
end -- 1425
local function isToolCallComplete(tc) -- 1443
	if type(tc.id) ~= "string" or tc.id == "" then -- 1443
		return false -- 1444
	end -- 1444
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1444
		return false -- 1445
	end -- 1445
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1445
		return false -- 1446
	end -- 1446
	local args = tc["function"].arguments -- 1447
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1447
		return false -- 1448
	end -- 1448
	local decoded = ____exports.safeJsonDecode(args) -- 1449
	return decoded ~= nil -- 1450
end -- 1443
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1453
	local delta = choice.delta or ({}) -- 1454
	local fullMessage = choice.message or ({}) -- 1455
	local message = acc.message -- 1456
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1457
	if type(role) == "string" and role ~= "" then -- 1457
		message.role = role -- 1461
	end -- 1461
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1463
	if type(content) == "string" and content ~= "" then -- 1463
		message.content = (message.content or "") .. content -- 1467
	end -- 1467
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1469
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1469
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1473
	end -- 1473
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1475
	if #toolCalls > 0 then -- 1475
		if message.tool_calls == nil then -- 1475
			message.tool_calls = {} -- 1479
		end -- 1479
		do -- 1479
			local i = 0 -- 1480
			while i < #toolCalls do -- 1480
				local item = toolCalls[i + 1] -- 1481
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1482
				local ____message_tool_calls_32, ____temp_33 = message.tool_calls, index + 1 -- 1482
				if ____message_tool_calls_32[____temp_33] == nil then -- 1482
					____message_tool_calls_32[____temp_33] = {} -- 1485
				end -- 1485
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1486
				if onToolCallReady and emittedToolCallIds then -- 1486
					local tc = message.tool_calls[index + 1] -- 1488
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1488
						emittedToolCallIds[tc.id] = true -- 1490
						onToolCallReady(tc) -- 1491
					end -- 1491
				end -- 1491
				i = i + 1 -- 1480
			end -- 1480
		end -- 1480
	end -- 1480
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1480
		acc.finish_reason = choice.finish_reason -- 1497
	end -- 1497
end -- 1453
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1501
	local indexes = __TS__ArraySort( -- 1510
		__TS__ArrayFilter( -- 1510
			__TS__ArrayMap( -- 1510
				__TS__ObjectKeys(states), -- 1510
				function(____, key) return __TS__Number(key) end -- 1511
			), -- 1511
			function(____, index) return __TS__NumberIsFinite(index) end -- 1512
		), -- 1512
		function(____, a, b) return a - b end -- 1513
	) -- 1513
	return { -- 1514
		id = id, -- 1515
		created = created, -- 1516
		object = object, -- 1517
		model = model, -- 1518
		choices = __TS__ArrayMap( -- 1519
			indexes, -- 1519
			function(____, index) -- 1519
				local state = states[index] -- 1520
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1521
			end -- 1519
		), -- 1519
		usage = usage, -- 1532
		error = providerError -- 1533
	} -- 1533
end -- 1501
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1537
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1537
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1548
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1549
		local resolvedConfig = config or (function() -- 1552
			local configRes = ____exports.getActiveLLMConfig() -- 1553
			if not configRes.success then -- 1553
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1555
				return nil -- 1556
			end -- 1556
			return configRes.config -- 1558
		end)() -- 1552
		if not resolvedConfig then -- 1552
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1552
		end -- 1552
		local url = resolvedConfig.url -- 1552
		local model = resolvedConfig.model -- 1552
		local apiKey = resolvedConfig.apiKey -- 1552
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1564
		if fitted.fittedTokens > fitted.budgetTokens then -- 1564
			return ____awaiter_resolve(nil, {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."}) -- 1564
		end -- 1564
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1568
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1569
		local ____model_38 = model -- 1572
		local ____url_39 = url -- 1572
		local ____temp_40 = #messages -- 1572
		local ____tostring_35 = tostring -- 1572
		local ____options_max_tokens_34 = options.max_tokens -- 1572
		if ____options_max_tokens_34 == nil then -- 1572
			____options_max_tokens_34 = "unset" -- 1572
		end -- 1572
		local ____tostring_35_result_41 = ____tostring_35(____options_max_tokens_34) -- 1572
		local ____tostring_37 = tostring -- 1572
		local ____options_temperature_36 = options.temperature -- 1572
		if ____options_temperature_36 == nil then -- 1572
			____options_temperature_36 = "unset" -- 1572
		end -- 1572
		____exports.Log( -- 1572
			"Info", -- 1572
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_38) .. " url=") .. ____url_39) .. " messages=") .. tostring(____temp_40)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_35_result_41) .. " temperature=") .. ____tostring_37(____options_temperature_36)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1572
		) -- 1572
		if stopToken and stopToken.stopped then -- 1572
			local reason = stopToken.reason or "request cancelled" -- 1574
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1575
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1575
		end -- 1575
		local ____hasReturned, ____returnValue -- 1575
		local ____try = __TS__AsyncAwaiter(function() -- 1575
			local states = {} -- 1579
			local emittedToolCallIds = {} -- 1580
			local responseId = nil -- 1581
			local responseCreated = nil -- 1582
			local responseObject = nil -- 1583
			local providerError -- 1584
			local responseUsage -- 1585
			local httpChunkCount = 0 -- 1586
			local rawStreamBytes = 0 -- 1587
			local rawStreamPreview = "" -- 1588
			local sseJSONChunkCount = 0 -- 1589
			local choiceJSONChunkCount = 0 -- 1590
			local emptyChoicesChunkCount = 0 -- 1591
			local missingChoicesChunkCount = 0 -- 1592
			local parseErrorCount = 0 -- 1593
			local doneChunkSeen = false -- 1594
			local lastJSONPreview = "" -- 1595
			local parser = createScheduledSSEJSONParser( -- 1596
				{ -- 1596
					onJSON = function(obj, raw) -- 1597
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1598
						lastJSONPreview = previewText(raw, 500) -- 1599
						if not obj or type(obj) ~= "table" then -- 1599
							return -- 1601
						end -- 1601
						local chunk = obj -- 1603
						if chunk.error then -- 1603
							providerError = chunk.error -- 1605
							____exports.Log( -- 1606
								"Warn", -- 1606
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1606
							) -- 1606
							return -- 1607
						end -- 1607
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1609
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1610
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1611
						if chunk.usage and type(chunk.usage) == "table" then -- 1611
							responseUsage = chunk.usage -- 1613
						end -- 1613
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1615
						if not __TS__ArrayIsArray(chunk.choices) then -- 1615
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1617
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1617
								____exports.Log( -- 1619
									"Warn", -- 1619
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1619
								) -- 1619
							end -- 1619
						elseif #choices == 0 then -- 1619
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1622
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1622
								____exports.Log( -- 1624
									"Warn", -- 1624
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1624
								) -- 1624
							end -- 1624
						else -- 1624
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1627
						end -- 1627
						do -- 1627
							local i = 0 -- 1629
							while i < #choices do -- 1629
								local choice = choices[i + 1] -- 1630
								local index = type(choice.index) == "number" and choice.index or i -- 1631
								if states[index] == nil then -- 1631
									states[index] = {index = index, message = {role = "assistant"}} -- 1632
								end -- 1632
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1636
								i = i + 1 -- 1629
							end -- 1629
						end -- 1629
						if onChunk ~= nil then -- 1629
							onChunk( -- 1638
								buildStreamResponse( -- 1639
									states, -- 1639
									model, -- 1639
									responseId, -- 1639
									responseCreated, -- 1639
									responseObject, -- 1639
									providerError, -- 1639
									responseUsage -- 1639
								), -- 1639
								{ -- 1640
									id = chunk.id or "", -- 1641
									created = chunk.created or 0, -- 1642
									object = chunk.object or "", -- 1643
									model = chunk.model or model, -- 1644
									choices = choices -- 1645
								} -- 1645
							) -- 1645
						end -- 1645
					end, -- 1597
					onDone = function() -- 1649
						doneChunkSeen = true -- 1650
					end, -- 1649
					onError = function(err, context) -- 1652
						parseErrorCount = parseErrorCount + 1 -- 1653
						____exports.Log( -- 1654
							"Warn", -- 1654
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1654
						) -- 1654
					end -- 1652
				}, -- 1652
				function() return (stopToken and stopToken.stopped) == true end -- 1656
			) -- 1656
			local ____try = __TS__AsyncAwaiter(function() -- 1656
				__TS__Await(postLLM( -- 1658
					fitted.messages, -- 1658
					url, -- 1658
					apiKey, -- 1658
					model, -- 1658
					options, -- 1658
					true, -- 1658
					resolvedConfig.customOptions, -- 1658
					function(data) -- 1658
						if stopToken and stopToken.stopped then -- 1658
							return true -- 1659
						end -- 1659
						httpChunkCount = httpChunkCount + 1 -- 1660
						rawStreamBytes = rawStreamBytes + #data -- 1661
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1661
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1663
						end -- 1663
						parser.append(data) -- 1665
						return false -- 1666
					end, -- 1658
					stopToken, -- 1667
					resolvedConfig.studioGateway -- 1667
				)) -- 1667
				__TS__Await(parser.finish()) -- 1668
			end) -- 1668
			____try = ____try.catch( -- 1668
				____try, -- 1668
				function(____, e) -- 1668
					return __TS__AsyncAwaiter(function() -- 1668
						parser.cancel() -- 1670
						error(e, 0) -- 1671
					end) -- 1671
				end -- 1671
			) -- 1671
			__TS__Await(____try) -- 1657
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1657
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1674
				if rawResponse and type(rawResponse) == "table" then -- 1674
					local rawResponseObj = rawResponse -- 1676
					if rawResponseObj.error then -- 1676
						providerError = rawResponseObj.error -- 1678
						lastJSONPreview = previewText( -- 1679
							normalizeLLMJSONResponse(rawStreamPreview), -- 1679
							500 -- 1679
						) -- 1679
						____exports.Log( -- 1680
							"Warn", -- 1680
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1680
						) -- 1680
					end -- 1680
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1680
						responseUsage = rawResponseObj.usage -- 1683
					end -- 1683
				end -- 1683
			end -- 1683
			local response = buildStreamResponse( -- 1687
				states, -- 1687
				model, -- 1687
				responseId, -- 1687
				responseCreated, -- 1687
				responseObject, -- 1687
				providerError, -- 1687
				responseUsage -- 1687
			) -- 1687
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1688
			local choiceCount = response.choices and #response.choices or 0 -- 1689
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1690
			____exports.Log( -- 1691
				"Info", -- 1691
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1691
			) -- 1691
			if not doneChunkSeen then -- 1691
				local rawPreview = previewText( -- 1693
					____exports.sanitizeUTF8(rawStreamPreview), -- 1693
					1200 -- 1693
				) -- 1693
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1694
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1695
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1696
				____hasReturned = true -- 1697
				____returnValue = { -- 1697
					success = false, -- 1698
					message = message, -- 1699
					raw = rawStreamPreview, -- 1700
					response = response, -- 1701
					tokenUsage = tokenUsage -- 1702
				} -- 1702
				return -- 1697
			end -- 1697
			if not response.choices or #response.choices == 0 then -- 1697
				local providerMessage = providerError and providerError.message or "" -- 1706
				local providerType = providerError and providerError.type or "" -- 1707
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1708
				local details = table.concat( -- 1711
					__TS__ArrayFilter( -- 1711
						{providerType, providerCode}, -- 1711
						function(____, part) return part ~= "" end -- 1711
					), -- 1711
					"/" -- 1711
				) -- 1711
				local rawPreview = previewText( -- 1712
					____exports.sanitizeUTF8(rawStreamPreview), -- 1712
					1200 -- 1712
				) -- 1712
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1713
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1714
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1717
				____hasReturned = true -- 1718
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1718
				return -- 1718
			end -- 1718
			____hasReturned = true -- 1725
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1725
			return -- 1725
		end) -- 1725
		____try = ____try.catch( -- 1725
			____try, -- 1725
			function(____, e) -- 1725
				return __TS__AsyncAwaiter(function() -- 1725
					if stopToken and stopToken.stopped then -- 1725
						local reason = stopToken.reason or "request cancelled" -- 1732
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1733
						____hasReturned = true -- 1734
						____returnValue = {success = false, message = reason} -- 1734
						return -- 1734
					end -- 1734
					____exports.Log( -- 1736
						"Error", -- 1736
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1736
					) -- 1736
					____hasReturned = true -- 1737
					____returnValue = { -- 1737
						success = false, -- 1737
						message = tostring(e) -- 1737
					} -- 1737
					return -- 1737
				end) -- 1737
			end -- 1737
		) -- 1737
		__TS__Await(____try) -- 1578
		if ____hasReturned then -- 1578
			return ____awaiter_resolve(nil, ____returnValue) -- 1578
		end -- 1578
	end) -- 1578
end -- 1537
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1741
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1741
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1747
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1748
		local resolvedConfig = config or (function() -- 1751
			local configRes = ____exports.getActiveLLMConfig() -- 1752
			if not configRes.success then -- 1752
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1754
				return nil -- 1755
			end -- 1755
			return configRes.config -- 1757
		end)() -- 1751
		if not resolvedConfig then -- 1751
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1751
		end -- 1751
		local url = resolvedConfig.url -- 1751
		local model = resolvedConfig.model -- 1751
		local apiKey = resolvedConfig.apiKey -- 1751
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1763
		if fitted.fittedTokens > fitted.budgetTokens then -- 1763
			return ____awaiter_resolve(nil, {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."}) -- 1763
		end -- 1763
		____exports.Log( -- 1767
			"Info", -- 1767
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1767
		) -- 1767
		if stopToken and stopToken.stopped then -- 1767
			local reason = stopToken.reason or "request cancelled" -- 1769
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1770
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1770
		end -- 1770
		local ____hasReturned, ____returnValue -- 1770
		local ____try = __TS__AsyncAwaiter(function() -- 1770
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1774
				fitted.messages, -- 1774
				url, -- 1774
				apiKey, -- 1774
				model, -- 1774
				options, -- 1774
				false, -- 1774
				resolvedConfig.customOptions, -- 1774
				nil, -- 1774
				stopToken, -- 1774
				resolvedConfig.studioGateway -- 1774
			))) -- 1774
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1775
			____exports.Log( -- 1776
				"Info", -- 1776
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1776
			) -- 1776
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1777
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1777
				local rawPreview = previewText(raw) -- 1779
				____exports.Log( -- 1780
					"Error", -- 1780
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1780
				) -- 1780
				____hasReturned = true -- 1781
				____returnValue = { -- 1781
					success = false, -- 1782
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1783
					raw = raw -- 1784
				} -- 1784
				return -- 1781
			end -- 1781
			local responseObj = response -- 1787
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1788
			____exports.Log( -- 1789
				"Info", -- 1789
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1789
			) -- 1789
			if not responseObj.choices or #responseObj.choices == 0 then -- 1789
				local providerError = responseObj.error -- 1791
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1792
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1795
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1798
				local details = table.concat( -- 1801
					__TS__ArrayFilter( -- 1801
						{providerType, providerCode}, -- 1801
						function(____, part) return part ~= "" end -- 1801
					), -- 1801
					"/" -- 1801
				) -- 1801
				local rawPreview = previewText(raw, 400) -- 1802
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1803
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1806
				____hasReturned = true -- 1807
				____returnValue = {success = false, message = message, raw = raw} -- 1807
				return -- 1807
			end -- 1807
			____hasReturned = true -- 1813
			____returnValue = {success = true, response = responseObj} -- 1813
			return -- 1813
		end) -- 1813
		____try = ____try.catch( -- 1813
			____try, -- 1813
			function(____, e) -- 1813
				return __TS__AsyncAwaiter(function() -- 1813
					if stopToken and stopToken.stopped then -- 1813
						local reason = stopToken.reason or "request cancelled" -- 1819
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1820
						____hasReturned = true -- 1821
						____returnValue = {success = false, message = reason} -- 1821
						return -- 1821
					end -- 1821
					____exports.Log( -- 1823
						"Error", -- 1823
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1823
					) -- 1823
					____hasReturned = true -- 1824
					____returnValue = { -- 1824
						success = false, -- 1824
						message = tostring(e) -- 1824
					} -- 1824
					return -- 1824
				end) -- 1824
			end -- 1824
		) -- 1824
		__TS__Await(____try) -- 1773
		if ____hasReturned then -- 1773
			return ____awaiter_resolve(nil, ____returnValue) -- 1773
		end -- 1773
	end) -- 1773
end -- 1741
return ____exports -- 1741