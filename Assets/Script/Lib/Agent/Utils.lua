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
function ____exports.sanitizeUTF8(text) -- 358
	if text == "" then -- 358
		return "" -- 359
	end -- 359
	local remaining = text -- 360
	local output = "" -- 361
	while remaining ~= "" do -- 361
		local len, invalidPos = utf8.len(remaining) -- 363
		if len ~= nil then -- 363
			output = output .. remaining -- 365
			break -- 366
		end -- 366
		local badPos = type(invalidPos) == "number" and invalidPos or 1 -- 368
		if badPos > 1 then -- 368
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1) -- 370
		end -- 370
		remaining = __TS__StringSubstring(remaining, badPos) -- 372
	end -- 372
	return output -- 374
end -- 358
function normalizeReasoningEffort(value) -- 1232
	if type(value) ~= "string" then -- 1232
		return nil -- 1233
	end -- 1233
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1234
	return normalized ~= "" and normalized or nil -- 1235
end -- 1235
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1246
	if not customOptions then -- 1246
		return options -- 1250
	end -- 1250
	local merged = __TS__ObjectAssign({}, options) -- 1251
	for key in pairs(customOptions) do -- 1252
		do -- 1252
			if key == "auxiliaryOptions" then -- 1252
				goto __continue273 -- 1255
			end -- 1255
			local value = customOptions[key] -- 1256
			if value == json.null then -- 1256
				__TS__Delete(merged, key) -- 1258
			else -- 1258
				merged[key] = value -- 1260
			end -- 1260
		end -- 1260
		::__continue273:: -- 1260
	end -- 1260
	return merged -- 1263
end -- 1246
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
local TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz" -- 53
local TOOL_CALL_ID_COUNTER = 0 -- 54
local STUDIO_MODEL_REQUEST_COUNTER = 0 -- 55
local function toBase36(value) -- 57
	if value <= 0 then -- 57
		return "0" -- 58
	end -- 58
	local remaining = math.floor(value) -- 59
	local out = "" -- 60
	while remaining > 0 do -- 60
		local digit = remaining % 36 -- 62
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out -- 63
		remaining = math.floor(remaining / 36) -- 64
	end -- 64
	return out -- 66
end -- 57
function ____exports.createLocalToolCallId() -- 69
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1 -- 70
	local timePart = toBase36(os.time()) -- 71
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER) -- 72
	return ("tc" .. timePart) .. counterPart -- 73
end -- 69
function ____exports.createStudioModelRequestId() -- 76
	STUDIO_MODEL_REQUEST_COUNTER = STUDIO_MODEL_REQUEST_COUNTER + 1 -- 77
	return ((("mr" .. toBase36(os.time())) .. toBase36(STUDIO_MODEL_REQUEST_COUNTER)) .. toBase36(math.floor(math.random() * 1000000000))) .. toBase36(math.floor(math.random() * 1000000000)) -- 80
end -- 76
local function normalizeCompletionText(value) -- 114
	if type(value) ~= "string" then -- 114
		return "" -- 115
	end -- 115
	return __TS__StringSlice( -- 116
		__TS__StringTrim(____exports.sanitizeUTF8(value)), -- 116
		0, -- 116
		AgentConfig.AGENT_LIMITS.completionTextMaxChars -- 116
	) -- 116
end -- 114
local function normalizeCompletionTextList(value, maxItems) -- 119
	if maxItems == nil then -- 119
		maxItems = AgentConfig.AGENT_LIMITS.completionListMaxItems -- 121
	end -- 121
	if not __TS__ArrayIsArray(value) then -- 121
		return {} -- 123
	end -- 123
	local items = {} -- 124
	do -- 124
		local i = 0 -- 125
		while i < #value and #items < maxItems do -- 125
			local item = normalizeCompletionText(value[i + 1]) -- 126
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 126
				items[#items + 1] = item -- 127
			end -- 127
			i = i + 1 -- 125
		end -- 125
	end -- 125
	return items -- 129
end -- 119
function ____exports.normalizeAgentCompletionReport(value) -- 132
	local row = value and not __TS__ArrayIsArray(value) and type(value) == "table" and value or ({}) -- 133
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 136
	local validation = {} -- 139
	if __TS__ArrayIsArray(row.validation) then -- 139
		do -- 139
			local i = 0 -- 141
			while i < #row.validation and #validation < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 141
				do -- 141
					local raw = row.validation[i + 1] -- 142
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 142
						goto __continue22 -- 143
					end -- 143
					local item = raw -- 144
					local kind = (item.kind == "runtime" or item.kind == "manual") and item.kind or (item.kind == "build" and "build" or nil) -- 145
					local result = (item.result == "passed" or item.result == "failed" or item.result == "not_run") and item.result or nil -- 146
					if kind == nil or result == nil then -- 146
						goto __continue22 -- 147
					end -- 147
					validation[#validation + 1] = { -- 148
						kind = kind, -- 149
						result = result, -- 150
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems) -- 151
					} -- 151
				end -- 151
				::__continue22:: -- 151
				i = i + 1 -- 141
			end -- 141
		end -- 141
	end -- 141
	local learningCandidates = {} -- 155
	if __TS__ArrayIsArray(row.learningCandidates) then -- 155
		do -- 155
			local i = 0 -- 157
			while i < #row.learningCandidates and #learningCandidates < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 157
				do -- 157
					local raw = row.learningCandidates[i + 1] -- 158
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 158
						goto __continue27 -- 159
					end -- 159
					local item = raw -- 160
					local claim = normalizeCompletionText(item.claim) -- 161
					if claim == "" then -- 161
						goto __continue27 -- 162
					end -- 162
					learningCandidates[#learningCandidates + 1] = { -- 163
						claim = claim, -- 164
						scope = (item.scope == "file" or item.scope == "engine") and item.scope or "project", -- 165
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems), -- 166
						confidence = item.confidence == "inferred" and "inferred" or "observed" -- 167
					} -- 167
				end -- 167
				::__continue27:: -- 167
				i = i + 1 -- 157
			end -- 157
		end -- 157
	end -- 157
	return { -- 171
		outcome = outcome, -- 172
		budgetExhausted = row.budgetExhausted == true, -- 173
		validation = validation, -- 174
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 175
		assumptions = normalizeCompletionTextList(row.assumptions), -- 176
		learningCandidates = learningCandidates -- 177
	} -- 177
end -- 132
function ____exports.replaceFirst(text, oldStr, newStr) -- 185
	if oldStr == "" then -- 185
		return text -- 186
	end -- 186
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 187
	if idx < 0 then -- 187
		return text -- 188
	end -- 188
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 189
end -- 185
local function getLeadingWhitespace(text) -- 192
	local i = 0 -- 193
	while i < #text do -- 193
		local ch = __TS__StringAccess(text, i) -- 195
		if ch ~= " " and ch ~= "\t" then -- 195
			break -- 196
		end -- 196
		i = i + 1 -- 197
	end -- 197
	return __TS__StringSubstring(text, 0, i) -- 199
end -- 192
local function getCommonIndentPrefix(lines) -- 202
	local common -- 203
	do -- 203
		local i = 0 -- 204
		while i < #lines do -- 204
			do -- 204
				local line = lines[i + 1] -- 205
				if __TS__StringTrim(line) == "" then -- 205
					goto __continue38 -- 206
				end -- 206
				local indent = getLeadingWhitespace(line) -- 207
				if common == nil then -- 207
					common = indent -- 209
					goto __continue38 -- 210
				end -- 210
				local j = 0 -- 212
				local maxLen = math.min(#common, #indent) -- 213
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 213
					j = j + 1 -- 215
				end -- 215
				common = __TS__StringSubstring(common, 0, j) -- 217
				if common == "" then -- 217
					break -- 218
				end -- 218
			end -- 218
			::__continue38:: -- 218
			i = i + 1 -- 204
		end -- 204
	end -- 204
	return common or "" -- 220
end -- 202
local function removeIndentPrefix(line, indent) -- 223
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 223
		return __TS__StringSubstring(line, #indent) -- 225
	end -- 225
	local lineIndent = getLeadingWhitespace(line) -- 227
	local j = 0 -- 228
	local maxLen = math.min(#lineIndent, #indent) -- 229
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 229
		j = j + 1 -- 231
	end -- 231
	return __TS__StringSubstring(line, j) -- 233
end -- 223
local function dedentLines(lines) -- 236
	local indent = getCommonIndentPrefix(lines) -- 237
	return { -- 238
		indent = indent, -- 239
		lines = __TS__ArrayMap( -- 240
			lines, -- 240
			function(____, line) return removeIndentPrefix(line, indent) end -- 240
		) -- 240
	} -- 240
end -- 236
local function findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 244
	local function foldWhitespace(text, withMap) -- 250
		local parts = {} -- 251
		local map = {} -- 252
		local i = 0 -- 253
		while i < #text do -- 253
			local ch = __TS__StringAccess(text, i) -- 255
			if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 255
				local start = i -- 257
				while i < #text do -- 257
					local next = __TS__StringAccess(text, i) -- 259
					if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 259
						break -- 260
					end -- 260
					i = i + 1 -- 261
				end -- 261
				parts[#parts + 1] = " " -- 263
				if withMap then -- 263
					map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 264
				end -- 264
			else -- 264
				parts[#parts + 1] = ch -- 266
				if withMap then -- 266
					map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 267
				end -- 267
				i = i + 1 -- 268
			end -- 268
		end -- 268
		return { -- 271
			text = table.concat(parts, ""), -- 271
			map = map -- 271
		} -- 271
	end -- 250
	local foldedContent = foldWhitespace(content, true) -- 273
	local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 274
	if foldedOld == "" then -- 274
		return {success = false, message = "old_str not found in file"} -- 276
	end -- 276
	local matches = {} -- 278
	local pos = 0 -- 279
	while true do -- 279
		local idx = (string.find( -- 281
			foldedContent.text, -- 281
			foldedOld, -- 281
			math.max(pos + 1, 1), -- 281
			true -- 281
		) or 0) - 1 -- 281
		if idx < 0 then -- 281
			break -- 282
		end -- 282
		local lastIdx = idx + #foldedOld - 1 -- 283
		local startMap = foldedContent.map[idx + 1] -- 284
		local endMap = foldedContent.map[lastIdx + 1] -- 285
		if startMap ~= nil and endMap ~= nil then -- 285
			matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 287
		end -- 287
		pos = idx + #foldedOld -- 289
	end -- 289
	if #matches == 0 then -- 289
		return {success = false, message = "old_str not found in file"} -- 292
	end -- 292
	if #matches > 1 then -- 292
		return { -- 295
			success = false, -- 296
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 297
		} -- 297
	end -- 297
	local match = matches[1] -- 300
	return { -- 301
		success = true, -- 302
		content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 303
	} -- 303
end -- 244
function ____exports.findIndentTolerantReplacement(content, oldStr, newStr) -- 307
	local contentLines = __TS__StringSplit(content, "\n") -- 312
	local oldLines = __TS__StringSplit(oldStr, "\n") -- 313
	if #oldLines == 0 then -- 313
		return {success = false, message = "old_str not found in file"} -- 315
	end -- 315
	local dedentedOld = dedentLines(oldLines) -- 317
	local dedentedOldText = table.concat(dedentedOld.lines, "\n") -- 318
	local dedentedNew = dedentLines(__TS__StringSplit(newStr, "\n")) -- 319
	local matches = {} -- 320
	do -- 320
		local start = 0 -- 321
		while start <= #contentLines - #oldLines do -- 321
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 322
			local dedentedCandidate = dedentLines(candidateLines) -- 323
			if table.concat(dedentedCandidate.lines, "\n") == dedentedOldText then -- 323
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 325
			end -- 325
			start = start + 1 -- 321
		end -- 321
	end -- 321
	if #matches == 0 then -- 321
		return findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 333
	end -- 333
	if #matches > 1 then -- 333
		return { -- 336
			success = false, -- 337
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 338
		} -- 338
	end -- 338
	local match = matches[1] -- 341
	local rebuiltNewLines = __TS__ArrayMap( -- 342
		dedentedNew.lines, -- 342
		function(____, line) return line == "" and "" or match.indent .. line end -- 342
	) -- 342
	local ____array_0 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 342
	__TS__SparseArrayPush( -- 342
		____array_0, -- 342
		table.unpack(rebuiltNewLines) -- 345
	) -- 345
	__TS__SparseArrayPush( -- 345
		____array_0, -- 345
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 346
	) -- 346
	local nextLines = {__TS__SparseArraySpread(____array_0)} -- 343
	return { -- 348
		success = true, -- 348
		content = table.concat(nextLines, "\n") -- 348
	} -- 348
end -- 307
local function previewText(text, maxLen) -- 351
	if maxLen == nil then -- 351
		maxLen = 200 -- 351
	end -- 351
	if text == "" then -- 351
		return "" -- 352
	end -- 352
	local compact = __TS__StringReplace( -- 353
		__TS__StringReplace(text, "\r", "\\r"), -- 353
		"\n", -- 353
		"\\n" -- 353
	) -- 353
	if #compact <= maxLen then -- 353
		return compact -- 354
	end -- 354
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 355
end -- 351
local function sanitizeJSONValue(value) -- 377
	if type(value) == "string" then -- 377
		return ____exports.sanitizeUTF8(value) -- 378
	end -- 378
	if __TS__ArrayIsArray(value) then -- 378
		return __TS__ArrayMap( -- 380
			value, -- 380
			function(____, item) return sanitizeJSONValue(item) end -- 380
		) -- 380
	end -- 380
	if value and type(value) == "table" then -- 380
		local result = {} -- 383
		for key in pairs(value) do -- 384
			result[key] = sanitizeJSONValue(value[key]) -- 385
		end -- 385
		return result -- 387
	end -- 387
	return value -- 389
end -- 377
function ____exports.safeJsonEncode(value, format, emptyAsArray, numAsStr, maxDepth) -- 392
	if format == nil then -- 392
		format = false -- 392
	end -- 392
	if emptyAsArray == nil then -- 392
		emptyAsArray = true -- 392
	end -- 392
	if numAsStr == nil then -- 392
		numAsStr = false -- 392
	end -- 392
	if maxDepth == nil then -- 392
		maxDepth = 128 -- 392
	end -- 392
	return json.encode( -- 393
		sanitizeJSONValue(value), -- 394
		format, -- 395
		emptyAsArray, -- 396
		numAsStr, -- 397
		maxDepth -- 398
	) -- 398
end -- 392
function ____exports.safeJsonDecode(text) -- 402
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 403
	if value == nil then -- 403
		return value, err -- 405
	end -- 405
	return sanitizeJSONValue(value), err -- 407
end -- 402
local function isPlainRecord(value) -- 410
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 411
end -- 410
local function normalizeLLMJSONResponse(text) -- 414
	return __TS__StringTrim(text) -- 415
end -- 414
local function utf8TakeHead(text, maxChars) -- 418
	if maxChars <= 0 or text == "" then -- 418
		return "" -- 419
	end -- 419
	local nextPos = utf8.offset(text, maxChars + 1) -- 420
	if nextPos == nil then -- 420
		return text -- 421
	end -- 421
	return string.sub(text, 1, nextPos - 1) -- 422
end -- 418
local function utf8TakeTail(text, maxChars) -- 425
	if maxChars <= 0 or text == "" then -- 425
		return "" -- 426
	end -- 426
	local charLen = utf8.len(text) -- 427
	if charLen == nil or charLen <= maxChars then -- 427
		return text -- 428
	end -- 428
	local startChar = math.max(1, charLen - maxChars + 1) -- 429
	local startPos = utf8.offset(text, startChar) -- 430
	if startPos == nil then -- 430
		return text -- 431
	end -- 431
	return string.sub(text, startPos) -- 432
end -- 425
function ____exports.estimateTextTokens(text) -- 435
	if text == "" then -- 435
		return 0 -- 436
	end -- 436
	return App:estimateTokens(text) -- 437
end -- 435
local function stringifyMessageContent(content) -- 440
	if type(content) == "string" then -- 440
		return content -- 441
	end -- 441
	if __TS__ArrayIsArray(content) then -- 441
		local parts = {} -- 443
		for ____, block in ipairs(content) do -- 444
			if block.type == "text" and block.text ~= nil then -- 444
				parts[#parts + 1] = block.text -- 445
			elseif block.type == "image_url" then -- 445
				parts[#parts + 1] = "[image]" -- 446
			end -- 446
		end -- 446
		return table.concat(parts, "\n") -- 448
	end -- 448
	return "" -- 450
end -- 440
local function estimateMessagesTokens(messages) -- 453
	local total = 0 -- 454
	do -- 454
		local i = 0 -- 455
		while i < #messages do -- 455
			local message = messages[i + 1] -- 456
			total = total + 8 -- 457
			total = total + ____exports.estimateTextTokens(message.role or "") -- 458
			total = total + ____exports.estimateTextTokens(type(message.content) == "string" and message.content or stringifyMessageContent(message.content)) -- 459
			total = total + ____exports.estimateTextTokens(message.name or "") -- 460
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 461
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 462
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({})) -- 463
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 464
			i = i + 1 -- 455
		end -- 455
	end -- 455
	return total -- 466
end -- 453
local function estimateOptionsTokens(options) -- 469
	local text = ____exports.safeJsonEncode(options) -- 470
	return text and ____exports.estimateTextTokens(text) or 0 -- 471
end -- 469
local function getReservedOutputTokens(options, contextWindow) -- 474
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 475
	if explicitMax > 0 then -- 475
		return math.max(256, explicitMax) -- 480
	end -- 480
	return math.max( -- 481
		1024, -- 481
		math.floor(contextWindow * 0.2) -- 481
	) -- 481
end -- 474
local function getInputTokenBudget(messages, options, config) -- 484
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 485
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 488
	local optionTokens = estimateOptionsTokens(options) -- 489
	local structuralOverhead = math.max(256, #messages * 16) -- 490
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 491
end -- 484
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 494
	if budgetTokens <= 0 or text == "" then -- 494
		return "" -- 495
	end -- 495
	local estimated = ____exports.estimateTextTokens(text) -- 496
	if estimated <= budgetTokens then -- 496
		return text -- 497
	end -- 497
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 498
	local targetChars = math.max( -- 499
		200, -- 499
		math.floor(budgetTokens * charsPerToken) -- 499
	) -- 499
	local keepHead = math.max( -- 500
		0, -- 500
		math.floor(targetChars * 0.35) -- 500
	) -- 500
	local keepTail = math.max(0, targetChars - keepHead) -- 501
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 502
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 503
	return (head .. "\n...\n") .. tail -- 504
end -- 494
local function isXMLWhitespaceChar(ch) -- 507
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 508
end -- 507
local function findLineStart(value, from) -- 511
	local i = from -- 512
	while i >= 0 do -- 512
		if __TS__StringAccess(value, i) == "\n" then -- 512
			return i + 1 -- 514
		end -- 514
		i = i - 1 -- 515
	end -- 515
	return 0 -- 517
end -- 511
local function findLastLiteral(text, needle) -- 520
	if needle == "" then -- 520
		return #text -- 521
	end -- 521
	local last = -1 -- 522
	local from = 0 -- 523
	while from <= #text - #needle do -- 523
		local pos = (string.find( -- 525
			text, -- 525
			needle, -- 525
			math.max(from + 1, 1), -- 525
			true -- 525
		) or 0) - 1 -- 525
		if pos < 0 then -- 525
			break -- 526
		end -- 526
		last = pos -- 527
		from = pos + 1 -- 528
	end -- 528
	return last -- 530
end -- 520
local function unwrapXMLRawText(text) -- 533
	local trimmed = __TS__StringTrim(text) -- 534
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 534
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 536
	end -- 536
	return text -- 538
end -- 533
local function readSimpleXMLTagName(source, openStart, openEnd) -- 541
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 542
	if rawTag == "" then -- 542
		return { -- 544
			success = false, -- 544
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 544
		} -- 544
	end -- 544
	local selfClosing = false -- 546
	local tagText = rawTag -- 547
	if __TS__StringEndsWith(tagText, "/") then -- 547
		selfClosing = true -- 549
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 550
	end -- 550
	local tagName = "" -- 552
	do -- 552
		local i = 0 -- 553
		while i < #tagText do -- 553
			local ch = __TS__StringAccess(tagText, i) -- 554
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 554
				break -- 555
			end -- 555
			tagName = tagName .. ch -- 556
			i = i + 1 -- 553
		end -- 553
	end -- 553
	if tagName == "" then -- 553
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 559
	end -- 559
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 561
end -- 541
local function findMatchingXMLClose(source, tagName, contentStart) -- 564
	local sameOpenPrefix = "<" .. tagName -- 565
	local sameCloseToken = ("</" .. tagName) .. ">" -- 566
	local pos = contentStart -- 567
	local depth = 1 -- 568
	while pos < #source do -- 568
		do -- 568
			local lt = (string.find( -- 570
				source, -- 570
				"<", -- 570
				math.max(pos + 1, 1), -- 570
				true -- 570
			) or 0) - 1 -- 570
			if lt < 0 then -- 570
				break -- 571
			end -- 571
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 571
				local cdataEnd = (string.find( -- 573
					source, -- 573
					"]]>", -- 573
					math.max(lt + 9 + 1, 1), -- 573
					true -- 573
				) or 0) - 1 -- 573
				if cdataEnd < 0 then -- 573
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 574
				end -- 574
				pos = cdataEnd + 3 -- 575
				goto __continue135 -- 576
			end -- 576
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 579
					source, -- 579
					"-->",
					math.max(lt + 4 + 1, 1), -- 579
					true -- 579
				) or 0) - 1 -- 579
				if commentEnd < 0 then -- 579
					return {success = false, message = "invalid xml: unterminated comment"} -- 580
				end -- 580
				pos = commentEnd + 3 -- 581
				goto __continue135 -- 582
			end -- 582
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 582
				depth = depth - 1 -- 585
				if depth == 0 then -- 585
					return {success = true, closeStart = lt} -- 586
				end -- 586
				pos = lt + #sameCloseToken -- 587
				goto __continue135 -- 588
			end -- 588
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 588
				local openEnd = (string.find( -- 591
					source, -- 591
					">", -- 591
					math.max(lt + 1, 1), -- 591
					true -- 591
				) or 0) - 1 -- 591
				if openEnd < 0 then -- 591
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 592
				end -- 592
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 593
				if not tagInfo.success then -- 593
					return tagInfo -- 594
				end -- 594
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 594
					depth = depth + 1 -- 596
				end -- 596
				pos = openEnd + 1 -- 598
				goto __continue135 -- 599
			end -- 599
			local genericEnd = (string.find( -- 601
				source, -- 601
				">", -- 601
				math.max(lt + 1, 1), -- 601
				true -- 601
			) or 0) - 1 -- 601
			if genericEnd < 0 then -- 601
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 602
			end -- 602
			pos = genericEnd + 1 -- 603
		end -- 603
		::__continue135:: -- 603
	end -- 603
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 605
end -- 564
function ____exports.extractXMLFromText(text) -- 608
	local source = __TS__StringTrim(text) -- 609
	local function extractFencedBlock(fence) -- 610
		if not __TS__StringStartsWith(source, fence) then -- 610
			return nil -- 611
		end -- 611
		local firstLineEnd = (string.find( -- 612
			source, -- 612
			"\n", -- 612
			math.max(1, 1), -- 612
			true -- 612
		) or 0) - 1 -- 612
		if firstLineEnd < 0 then -- 612
			return nil -- 613
		end -- 613
		local searchPos = firstLineEnd + 1 -- 614
		local closingFencePositions = {} -- 615
		while searchPos < #source do -- 615
			local ____end = (string.find( -- 617
				source, -- 617
				"```", -- 617
				math.max(searchPos + 1, 1), -- 617
				true -- 617
			) or 0) - 1 -- 617
			if ____end < 0 then -- 617
				break -- 618
			end -- 618
			local lineStart = findLineStart(source, ____end - 1) -- 619
			local lineEnd = (string.find( -- 620
				source, -- 620
				"\n", -- 620
				math.max(____end + 1, 1), -- 620
				true -- 620
			) or 0) - 1 -- 620
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 621
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 621
				closingFencePositions[#closingFencePositions + 1] = ____end -- 623
			end -- 623
			searchPos = ____end + 1 -- 625
		end -- 625
		do -- 625
			local i = #closingFencePositions - 1 -- 627
			while i >= 0 do -- 627
				do -- 627
					local closingFencePos = closingFencePositions[i + 1] -- 628
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 629
					if afterFence ~= "" then -- 629
						goto __continue156 -- 630
					end -- 630
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 631
				end -- 631
				::__continue156:: -- 631
				i = i - 1 -- 627
			end -- 627
		end -- 627
		return nil -- 633
	end -- 610
	local xmlBlock = extractFencedBlock("```xml") -- 635
	if xmlBlock ~= nil then -- 635
		return xmlBlock -- 636
	end -- 636
	local genericBlock = extractFencedBlock("```") -- 637
	if genericBlock ~= nil then -- 637
		return genericBlock -- 638
	end -- 638
	return source -- 639
end -- 608
function ____exports.parseSimpleXMLChildren(source) -- 642
	local result = {} -- 643
	local pos = 0 -- 644
	while pos < #source do -- 644
		do -- 644
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 644
				pos = pos + 1 -- 646
			end -- 646
			if pos >= #source then -- 646
				break -- 647
			end -- 647
			if __TS__StringAccess(source, pos) ~= "<" then -- 647
				return { -- 649
					success = false, -- 649
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 649
				} -- 649
			end -- 649
			if __TS__StringStartsWith(source, "</", pos) then -- 649
				return { -- 652
					success = false, -- 652
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 652
				} -- 652
			end -- 652
			local openEnd = (string.find( -- 654
				source, -- 654
				">", -- 654
				math.max(pos + 1, 1), -- 654
				true -- 654
			) or 0) - 1 -- 654
			if openEnd < 0 then -- 654
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 656
			end -- 656
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 658
			if not tagInfo.success then -- 658
				return tagInfo -- 659
			end -- 659
			if tagInfo.selfClosing then -- 659
				result[tagInfo.tagName] = "" -- 661
				pos = openEnd + 1 -- 662
				goto __continue161 -- 663
			end -- 663
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 665
			if not closeRes.success then -- 665
				return closeRes -- 666
			end -- 666
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 667
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 668
			pos = closeRes.closeStart + #closeToken -- 669
		end -- 669
		::__continue161:: -- 669
	end -- 669
	return {success = true, obj = result} -- 671
end -- 642
function ____exports.parseXMLObjectFromText(text, rootTag) -- 674
	local xmlText = ____exports.extractXMLFromText(text) -- 675
	local rootOpen = ("<" .. rootTag) .. ">" -- 676
	local rootClose = ("</" .. rootTag) .. ">" -- 677
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 678
	local ____end = findLastLiteral(xmlText, rootClose) -- 679
	if start < 0 or ____end < start then -- 679
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 681
	end -- 681
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 683
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 684
	if beforeRoot ~= "" or afterRoot ~= "" then -- 684
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 686
	end -- 686
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 688
	return ____exports.parseSimpleXMLChildren(rootContent) -- 689
end -- 674
function ____exports.fitMessagesToContext(messages, options, config) -- 692
	local modelName = string.lower(config.model) -- 699
	local shouldEchoReasoningContent = __TS__ArraySome( -- 700
		messages, -- 700
		function(____, message) return type(message.reasoning_content) == "string" end -- 700
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 700
	local cloned = __TS__ArrayMap( -- 704
		messages, -- 704
		function(____, message) -- 704
			local clonedMessage = __TS__ObjectAssign({}, message) -- 705
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 705
				clonedMessage.reasoning_content = "" -- 711
			end -- 711
			return clonedMessage -- 713
		end -- 704
	) -- 704
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 715
	local originalTokens = estimateMessagesTokens(cloned) -- 716
	if originalTokens <= budgetTokens then -- 716
		return { -- 718
			messages = cloned, -- 719
			trimmed = false, -- 720
			originalTokens = originalTokens, -- 721
			fittedTokens = originalTokens, -- 722
			budgetTokens = budgetTokens -- 723
		} -- 723
	end -- 723
	local function roleOverhead(message) -- 727
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 727
	end -- 727
	local fixedOverhead = 0 -- 728
	local contentIndexes = {} -- 729
	do -- 729
		local i = 0 -- 730
		while i < #cloned do -- 730
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 731
			contentIndexes[#contentIndexes + 1] = i -- 732
			i = i + 1 -- 730
		end -- 730
	end -- 730
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 734
	if #contentIndexes == 1 then -- 734
		local idx = contentIndexes[1] -- 736
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget( -- 737
			type(cloned[idx + 1].content) == "string" and cloned[idx + 1].content or stringifyMessageContent(cloned[idx + 1].content), -- 737
			contentBudget -- 737
		) -- 737
		local fittedTokens = estimateMessagesTokens(cloned) -- 738
		return { -- 739
			messages = cloned, -- 740
			trimmed = true, -- 741
			originalTokens = originalTokens, -- 742
			fittedTokens = fittedTokens, -- 743
			budgetTokens = budgetTokens -- 744
		} -- 744
	end -- 744
	local nonSystemIndexes = {} -- 748
	local systemIndexes = {} -- 749
	do -- 749
		local i = 0 -- 750
		while i < #cloned do -- 750
			if cloned[i + 1].role == "system" then -- 750
				systemIndexes[#systemIndexes + 1] = i -- 751
			else -- 751
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 752
			end -- 752
			i = i + 1 -- 750
		end -- 750
	end -- 750
	local ____array_1 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 750
	__TS__SparseArrayPush( -- 750
		____array_1, -- 750
		table.unpack(systemIndexes) -- 754
	) -- 754
	local priorityIndexes = {__TS__SparseArraySpread(____array_1)} -- 754
	local remainingContentBudget = contentBudget -- 755
	do -- 755
		local i = #priorityIndexes - 1 -- 756
		while i >= 0 do -- 756
			local idx = priorityIndexes[i + 1] -- 757
			local message = cloned[idx + 1] -- 758
			local minBudget = message.role == "system" and 96 or 192 -- 759
			local target = math.max( -- 760
				minBudget, -- 760
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 760
			) -- 760
			message.content = ____exports.clipTextToTokenBudget( -- 761
				type(message.content) == "string" and message.content or stringifyMessageContent(message.content), -- 761
				target -- 761
			) -- 761
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(type(message.content) == "string" and message.content or stringifyMessageContent(message.content)) -- 762
			remainingContentBudget = math.max(0, remainingContentBudget) -- 763
			i = i - 1 -- 756
		end -- 756
	end -- 756
	local fittedTokens = estimateMessagesTokens(cloned) -- 766
	if fittedTokens > budgetTokens then -- 766
		do -- 766
			local i = 0 -- 768
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 768
				local idx = priorityIndexes[i + 1] -- 769
				local message = cloned[idx + 1] -- 770
				local currentTokens = ____exports.estimateTextTokens(type(message.content) == "string" and message.content or stringifyMessageContent(message.content)) -- 771
				local excess = fittedTokens - budgetTokens -- 772
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 773
				message.content = ____exports.clipTextToTokenBudget( -- 774
					type(message.content) == "string" and message.content or stringifyMessageContent(message.content), -- 774
					nextBudget -- 774
				) -- 774
				fittedTokens = estimateMessagesTokens(cloned) -- 775
				i = i + 1 -- 768
			end -- 768
		end -- 768
	end -- 768
	if fittedTokens > budgetTokens then -- 768
		do -- 768
			local i = 0 -- 779
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 779
				do -- 779
					local idx = priorityIndexes[i + 1] -- 780
					if cloned[idx + 1].role == "system" then -- 780
						goto __continue193 -- 781
					end -- 781
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget( -- 782
						type(cloned[idx + 1].content) == "string" and cloned[idx + 1].content or stringifyMessageContent(cloned[idx + 1].content), -- 782
						48 -- 782
					) -- 782
					fittedTokens = estimateMessagesTokens(cloned) -- 783
				end -- 783
				::__continue193:: -- 783
				i = i + 1 -- 779
			end -- 779
		end -- 779
	end -- 779
	return { -- 786
		messages = cloned, -- 787
		trimmed = true, -- 788
		originalTokens = originalTokens, -- 789
		fittedTokens = fittedTokens, -- 790
		budgetTokens = budgetTokens -- 791
	} -- 791
end -- 692
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken, studioGateway) -- 795
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 807
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 808
	local data = __TS__ObjectAssign({}, requestOptions, {model = model, messages = messages, stream = stream}) -- 809
	local studioRequestId = studioGateway and ____exports.createStudioModelRequestId() or nil -- 815
	if stopToken == nil then -- 815
		stopToken = {stopped = false} -- 816
	end -- 816
	return __TS__New( -- 817
		__TS__Promise, -- 817
		function(____, resolve, reject) -- 817
			local requestId = 0 -- 818
			local settled = false -- 819
			local function finishResolve(text) -- 820
				if settled then -- 820
					return -- 821
				end -- 821
				settled = true -- 822
				resolve(nil, text) -- 823
			end -- 820
			local function finishReject(err) -- 825
				if settled then -- 825
					return -- 826
				end -- 826
				settled = true -- 827
				reject(nil, err) -- 828
			end -- 825
			Director.systemScheduler:schedule(function() -- 830
				if not settled then -- 830
					if stopToken.stopped then -- 830
						if requestId ~= 0 then -- 830
							HttpClient:cancel(requestId) -- 834
							requestId = 0 -- 835
						end -- 835
						finishReject("request cancelled") -- 837
						return true -- 838
					end -- 838
					return false -- 840
				end -- 840
				return true -- 842
			end) -- 830
			Director.systemScheduler:schedule(once(function() -- 844
				emit( -- 845
					"LLM_IN", -- 845
					table.concat( -- 845
						__TS__ArrayMap( -- 845
							messages, -- 845
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 845
						), -- 845
						"\n" -- 845
					) -- 845
				) -- 845
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 846
				if jsonStr ~= nil then -- 846
					local headers = { -- 848
						"Authorization: Bearer " .. apiKey, -- 849
						"Content-Type: application/json", -- 850
						receiver and "Accept: text/event-stream" or "Accept: application/json", -- 851
						table.unpack(studioRequestId and ({"X-Studio-Model-Request-Id: " .. studioRequestId}) or ({})) -- 852
					} -- 852
					requestId = receiver and HttpClient:post( -- 854
						url, -- 855
						headers, -- 855
						jsonStr, -- 855
						requestTimeout, -- 855
						function(data) -- 855
							if stopToken.stopped then -- 855
								return true -- 856
							end -- 856
							return receiver(data) -- 857
						end, -- 855
						function(data) -- 858
							requestId = 0 -- 859
							if data ~= nil then -- 859
								finishResolve(data) -- 861
							else -- 861
								finishReject("failed to get http response") -- 863
							end -- 863
						end -- 858
					) or HttpClient:post( -- 858
						url, -- 866
						headers, -- 866
						jsonStr, -- 866
						requestTimeout, -- 866
						function(data) -- 866
							requestId = 0 -- 867
							if stopToken.stopped then -- 867
								finishReject("request cancelled") -- 869
								return -- 870
							end -- 870
							if data ~= nil then -- 870
								finishResolve(data) -- 873
							else -- 873
								finishReject("failed to get http response") -- 875
							end -- 875
						end -- 866
					) -- 866
					if requestId == 0 then -- 866
						finishReject("failed to schedule http request") -- 879
					elseif stopToken.stopped then -- 879
						HttpClient:cancel(requestId) -- 881
						requestId = 0 -- 882
						finishReject("request cancelled") -- 883
					end -- 883
				else -- 883
					finishReject(err) -- 886
				end -- 886
			end)) -- 844
		end -- 817
	) -- 817
end -- 795
function ____exports.createSSEJSONParser(opts) -- 896
	local buffer = "" -- 901
	local eventDataLines = {} -- 902
	local function flushEventIfAny() -- 904
		if #eventDataLines == 0 then -- 904
			return -- 905
		end -- 905
		local dataPayload = table.concat(eventDataLines, "\n") -- 907
		eventDataLines = {} -- 908
		if dataPayload == "[DONE]" then -- 908
			local ____opt_2 = opts.onDone -- 908
			if ____opt_2 ~= nil then -- 908
				____opt_2(dataPayload) -- 911
			end -- 911
			return -- 912
		end -- 912
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 915
		if err == nil then -- 915
			opts.onJSON(obj, dataPayload) -- 917
		else -- 917
			local ____opt_4 = opts.onError -- 917
			if ____opt_4 ~= nil then -- 917
				____opt_4(err, {raw = dataPayload}) -- 919
			end -- 919
		end -- 919
	end -- 904
	local function append(chunk) -- 923
		buffer = buffer .. chunk -- 924
	end -- 923
	local function drain(maxLines) -- 927
		local processedLines = 0 -- 928
		while maxLines == nil or processedLines < maxLines do -- 928
			do -- 928
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 930
				if nl < 0 then -- 930
					break -- 931
				end -- 931
				processedLines = processedLines + 1 -- 932
				local line = __TS__StringSlice(buffer, 0, nl) -- 934
				buffer = __TS__StringSlice(buffer, nl + 1) -- 935
				if __TS__StringEndsWith(line, "\r") then -- 935
					line = string.sub(line, 1, -2) -- 937
				end -- 937
				if line == "" then -- 937
					flushEventIfAny() -- 940
					goto __continue228 -- 941
				end -- 941
				if __TS__StringStartsWith(line, ":") then -- 941
					goto __continue228 -- 945
				end -- 945
				if __TS__StringStartsWith(line, "data:") then -- 945
					local v = string.sub(line, 6) -- 948
					if __TS__StringStartsWith(v, " ") then -- 948
						v = string.sub(v, 2) -- 949
					end -- 949
					eventDataLines[#eventDataLines + 1] = v -- 950
					goto __continue228 -- 951
				end -- 951
			end -- 951
			::__continue228:: -- 951
		end -- 951
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0 -- 954
	end -- 927
	local function feed(chunk) -- 957
		append(chunk) -- 958
		drain() -- 959
	end -- 957
	local function ____end() -- 962
		if #buffer > 0 then -- 962
			local line = buffer -- 964
			buffer = "" -- 965
			if __TS__StringEndsWith(line, "\r") then -- 965
				line = string.sub(line, 1, -2) -- 966
			end -- 966
			if __TS__StringStartsWith(line, "data:") then -- 966
				local v = string.sub(line, 6) -- 969
				if __TS__StringStartsWith(v, " ") then -- 969
					v = string.sub(v, 2) -- 970
				end -- 970
				eventDataLines[#eventDataLines + 1] = v -- 971
			end -- 971
		end -- 971
		flushEventIfAny() -- 974
	end -- 962
	local function discard() -- 977
		buffer = "" -- 978
		eventDataLines = {} -- 979
	end -- 977
	return { -- 982
		append = append, -- 982
		drain = drain, -- 982
		feed = feed, -- 982
		["end"] = ____end, -- 982
		discard = discard -- 982
	} -- 982
end -- 896
local SSE_PARSE_LINES_PER_FRAME = 256 -- 985
local function createScheduledSSEJSONParser(opts, isCancelled) -- 987
	local parser = ____exports.createSSEJSONParser(opts) -- 991
	local inputFinished = false -- 992
	local settled = false -- 993
	local resolveFinished -- 994
	local finished = __TS__New( -- 995
		__TS__Promise, -- 995
		function(____, resolve) -- 995
			resolveFinished = resolve -- 996
		end -- 995
	) -- 995
	local function settle() -- 998
		if settled then -- 998
			return -- 999
		end -- 999
		settled = true -- 1000
		if resolveFinished ~= nil then -- 1000
			resolveFinished() -- 1001
		end -- 1001
	end -- 998
	Director.systemScheduler:schedule(function() -- 1003
		if settled then -- 1003
			return true -- 1004
		end -- 1004
		if isCancelled and isCancelled() then -- 1004
			parser.discard() -- 1006
			settle() -- 1007
			return true -- 1008
		end -- 1008
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME) -- 1010
		if inputFinished and not hasMoreCompleteLines then -- 1010
			parser["end"]() -- 1012
			settle() -- 1013
			return true -- 1014
		end -- 1014
		return false -- 1016
	end) -- 1003
	return { -- 1018
		append = parser.append, -- 1019
		finish = function() -- 1020
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1020
				inputFinished = true -- 1021
				__TS__Await(finished) -- 1022
			end) -- 1022
		end, -- 1020
		cancel = function() -- 1024
			parser.discard() -- 1025
			settle() -- 1026
		end -- 1024
	} -- 1024
end -- 987
function ____exports.extractLLMTokenUsage(response) -- 1122
	local usage = response and response.usage -- 1123
	if not usage or type(usage) ~= "table" then -- 1123
		return nil -- 1124
	end -- 1124
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1125
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1128
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1128
		return nil -- 1131
	end -- 1131
	local ____temp_17 -- 1132
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1132
		____temp_17 = usage.prompt_cache_hit_tokens -- 1133
	else -- 1133
		local ____temp_16 -- 1134
		local ____opt_12 = usage.prompt_tokens_details -- 1134
		if type(____opt_12 and ____opt_12.cached_tokens) == "number" then -- 1134
			____temp_16 = usage.prompt_tokens_details.cached_tokens -- 1135
		else -- 1135
			local ____opt_14 = usage.input_tokens_details -- 1135
			____temp_16 = type(____opt_14 and ____opt_14.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1136
		end -- 1136
		____temp_17 = ____temp_16 -- 1134
	end -- 1134
	local cachedInputTokens = ____temp_17 -- 1132
	local ____inputTokens_20 = inputTokens -- 1140
	local ____outputTokens_21 = outputTokens -- 1141
	local ____temp_22 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1142
	local ____temp_23 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1143
	local ____temp_24 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1144
	local ____opt_18 = usage.completion_tokens_details -- 1144
	return { -- 1139
		inputTokens = ____inputTokens_20, -- 1140
		outputTokens = ____outputTokens_21, -- 1141
		totalTokens = ____temp_22, -- 1142
		cachedInputTokens = ____temp_23, -- 1143
		cacheMissInputTokens = ____temp_24, -- 1144
		reasoningOutputTokens = type(____opt_18 and ____opt_18.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1147
	} -- 1147
end -- 1122
function ____exports.validateAgentLLMConfig(config) -- 1194
	local ____opt_25 = config.customOptions -- 1194
	local auxiliaryOptions = ____opt_25 and ____opt_25.auxiliaryOptions -- 1195
	if isPlainRecord(auxiliaryOptions) then -- 1195
		for _key in pairs(auxiliaryOptions) do -- 1197
			return {success = true} -- 1198
		end -- 1198
	end -- 1198
	return {success = false, message = "LLM 配置的 customOptions 必须包含非空 auxiliaryOptions，请检查 LLM 配置"} -- 1201
end -- 1194
local function normalizeContextWindow(value) -- 1207
	if type(value) == "number" and value > 0 then -- 1207
		return math.floor(value) -- 1209
	end -- 1209
	return 64000 -- 1211
end -- 1207
local function normalizeSupportsFunctionCalling(value) -- 1214
	return value == nil or value ~= 0 -- 1215
end -- 1214
local function normalizeLLMTemperature(value) -- 1218
	if type(value) == "number" then -- 1218
		return math.max( -- 1220
			0, -- 1220
			math.min(2, value) -- 1220
		) -- 1220
	end -- 1220
	return 0.1 -- 1222
end -- 1218
local function normalizeLLMMaxTokens(value) -- 1225
	if type(value) == "number" then -- 1225
		return math.max( -- 1227
			1, -- 1227
			math.floor(value) -- 1227
		) -- 1227
	end -- 1227
	return AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1229
end -- 1225
local function normalizeLLMCustomOptions(value) -- 1238
	if type(value) ~= "string" then -- 1238
		return nil -- 1239
	end -- 1239
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1240
	if text == "" then -- 1240
		return nil -- 1241
	end -- 1241
	local decoded = ____exports.safeJsonDecode(text) -- 1242
	return isPlainRecord(decoded) and decoded or nil -- 1243
end -- 1238
local function getLLMConfigRecords() -- 1266
	upgradeLLMConfig() -- 1267
	local rows = DB:query("select * from LLMConfig", true) -- 1268
	local records = {} -- 1269
	if rows and #rows > 1 then -- 1269
		do -- 1269
			local i = 1 -- 1271
			while i < #rows do -- 1271
				local record = {} -- 1272
				do -- 1272
					local c = 0 -- 1273
					while c < #rows[i + 1] do -- 1273
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1274
						c = c + 1 -- 1273
					end -- 1273
				end -- 1273
				records[#records + 1] = record -- 1276
				i = i + 1 -- 1271
			end -- 1271
		end -- 1271
	end -- 1271
	return records -- 1279
end -- 1266
function ____exports.getLLMConfigSummaries() -- 1289
	return __TS__ArrayFlatMap( -- 1290
		getLLMConfigRecords(), -- 1290
		function(____, record) -- 1290
			local id = record.id -- 1291
			local name = record.name -- 1292
			local model = record.model -- 1293
			if type(id) ~= "number" or type(name) ~= "string" or type(model) ~= "string" then -- 1293
				return {} -- 1294
			end -- 1294
			return {{id = id, name = name, model = model, active = record.active ~= 0}} -- 1295
		end -- 1290
	) -- 1290
end -- 1289
local function parseLLMConfig(config) -- 1299
	if not config then -- 1299
		return {success = false, message = "LLM config not found"} -- 1301
	end -- 1301
	local ____config_27 = config -- 1303
	local id = ____config_27.id -- 1303
	local url = ____config_27.url -- 1303
	local model = ____config_27.model -- 1303
	local api_key = ____config_27.api_key -- 1303
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1303
		return {success = false, message = "got invalid LLM config"} -- 1305
	end -- 1305
	return { -- 1307
		success = true, -- 1308
		id = id, -- 1309
		config = { -- 1310
			url = url, -- 1311
			model = model, -- 1312
			apiKey = api_key, -- 1313
			contextWindow = normalizeContextWindow(config.context_window), -- 1314
			temperature = normalizeLLMTemperature(config.temperature), -- 1315
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1316
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1317
			customOptions = normalizeLLMCustomOptions(config.custom_options), -- 1318
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 1319
		} -- 1319
	} -- 1319
end -- 1299
function ____exports.getLLMConfig(configId) -- 1324
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1325
	if normalizedId == nil or normalizedId <= 0 then -- 1325
		return {success = false, message = "LLM config is not selected"} -- 1327
	end -- 1327
	return parseLLMConfig(__TS__ArrayFind( -- 1329
		getLLMConfigRecords(), -- 1329
		function(____, record) return record.id == normalizedId end -- 1329
	)) -- 1329
end -- 1324
function ____exports.getActiveLLMConfig() -- 1332
	local records = getLLMConfigRecords() -- 1333
	local config = __TS__ArrayFind( -- 1334
		records, -- 1334
		function(____, r) return r.active ~= 0 end -- 1334
	) -- 1334
	if not config then -- 1334
		return {success = false, message = "no active LLM config"} -- 1336
	end -- 1336
	return parseLLMConfig(config) -- 1338
end -- 1332
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1341
	local callEvent -- 1347
	if event.id ~= nil then -- 1347
		local id = event.id -- 1349
		callEvent = { -- 1350
			id = nil, -- 1351
			onData = function(data) -- 1352
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1353
				return event.stopToken.stopped -- 1354
			end, -- 1352
			onCancel = function(reason) -- 1356
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1357
			end, -- 1356
			onDone = function() -- 1359
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1360
			end -- 1359
		} -- 1359
	else -- 1359
		callEvent = event -- 1364
	end -- 1364
	local ____callEvent_28 = callEvent -- 1366
	local onData = ____callEvent_28.onData -- 1366
	local onDone = ____callEvent_28.onDone -- 1366
	local ____callEvent_29 = callEvent -- 1367
	local onCancel = ____callEvent_29.onCancel -- 1367
	local config = llmConfig or (function() -- 1368
		local configRes = ____exports.getActiveLLMConfig() -- 1369
		if not configRes.success then -- 1369
			if onCancel then -- 1369
				onCancel(configRes.message) -- 1371
			end -- 1371
			return nil -- 1372
		end -- 1372
		return configRes.config -- 1374
	end)() -- 1368
	if not config then -- 1368
		return {success = false, message = "no active LLM config"} -- 1377
	end -- 1377
	local url = config.url -- 1377
	local model = config.model -- 1377
	local apiKey = config.apiKey -- 1377
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1380
	if fitted.trimmed then -- 1380
		____exports.Log( -- 1382
			"Warn", -- 1382
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1382
		) -- 1382
	end -- 1382
	local stopLLM = false -- 1384
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1385
	local parser = createScheduledSSEJSONParser( -- 1388
		{onJSON = function(obj) -- 1388
			local result = onData(obj) -- 1390
			if result then -- 1390
				stopLLM = true -- 1392
				streamStopToken.stopped = true -- 1393
				streamStopToken.reason = "LLM Stopped" -- 1394
			end -- 1394
		end}, -- 1389
		function() return streamStopToken.stopped end -- 1397
	); -- 1397
	(function() -- 1398
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1398
			local ____try = __TS__AsyncAwaiter(function() -- 1398
				local result = __TS__Await(postLLM( -- 1400
					fitted.messages, -- 1400
					url, -- 1400
					apiKey, -- 1400
					model, -- 1400
					options, -- 1400
					true, -- 1400
					config.customOptions, -- 1400
					function(data) -- 1400
						if stopLLM then -- 1400
							if onCancel then -- 1400
								onCancel("LLM Stopped") -- 1403
								onCancel = nil -- 1404
							end -- 1404
							return true -- 1406
						end -- 1406
						parser.append(data) -- 1408
						return false -- 1409
					end, -- 1400
					streamStopToken, -- 1410
					config.studioGateway -- 1410
				)) -- 1410
				__TS__Await(parser.finish()) -- 1411
				if onDone then -- 1411
					onDone(result) -- 1413
				end -- 1413
			end) -- 1413
			____try = ____try.catch( -- 1413
				____try, -- 1413
				function(____, e) -- 1413
					return __TS__AsyncAwaiter(function() -- 1413
						parser.cancel() -- 1416
						stopLLM = true -- 1417
						if onCancel then -- 1417
							onCancel(tostring(e)) -- 1419
							onCancel = nil -- 1420
						end -- 1420
					end) -- 1420
				end -- 1420
			) -- 1420
			__TS__Await(____try) -- 1399
		end) -- 1399
	end)() -- 1398
	return {success = true} -- 1424
end -- 1341
local function mergeStreamToolCall(target, delta) -- 1427
	if type(delta.id) == "string" and delta.id ~= "" then -- 1427
		target.id = delta.id -- 1429
	end -- 1429
	if type(delta.type) == "string" and delta.type ~= "" then -- 1429
		target.type = delta.type -- 1432
	end -- 1432
	if delta["function"] then -- 1432
		if target["function"] == nil then -- 1432
			target["function"] = {} -- 1435
		end -- 1435
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1435
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1437
		end -- 1437
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1437
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1440
		end -- 1440
	end -- 1440
end -- 1427
local function isToolCallComplete(tc) -- 1445
	if type(tc.id) ~= "string" or tc.id == "" then -- 1445
		return false -- 1446
	end -- 1446
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1446
		return false -- 1447
	end -- 1447
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1447
		return false -- 1448
	end -- 1448
	local args = tc["function"].arguments -- 1449
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1449
		return false -- 1450
	end -- 1450
	local decoded = ____exports.safeJsonDecode(args) -- 1451
	return decoded ~= nil -- 1452
end -- 1445
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1455
	local delta = choice.delta or ({}) -- 1456
	local fullMessage = choice.message or ({}) -- 1457
	local message = acc.message -- 1458
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1459
	if type(role) == "string" and role ~= "" then -- 1459
		message.role = role -- 1463
	end -- 1463
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1465
	if type(content) == "string" and content ~= "" then -- 1465
		message.content = (message.content or "") .. content -- 1469
	end -- 1469
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1471
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1471
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1475
	end -- 1475
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1477
	if #toolCalls > 0 then -- 1477
		if message.tool_calls == nil then -- 1477
			message.tool_calls = {} -- 1481
		end -- 1481
		do -- 1481
			local i = 0 -- 1482
			while i < #toolCalls do -- 1482
				local item = toolCalls[i + 1] -- 1483
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1484
				local ____message_tool_calls_30, ____temp_31 = message.tool_calls, index + 1 -- 1484
				if ____message_tool_calls_30[____temp_31] == nil then -- 1484
					____message_tool_calls_30[____temp_31] = {} -- 1487
				end -- 1487
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1488
				if onToolCallReady and emittedToolCallIds then -- 1488
					local tc = message.tool_calls[index + 1] -- 1490
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1490
						emittedToolCallIds[tc.id] = true -- 1492
						onToolCallReady(tc) -- 1493
					end -- 1493
				end -- 1493
				i = i + 1 -- 1482
			end -- 1482
		end -- 1482
	end -- 1482
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1482
		acc.finish_reason = choice.finish_reason -- 1499
	end -- 1499
end -- 1455
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1503
	local indexes = __TS__ArraySort( -- 1512
		__TS__ArrayFilter( -- 1512
			__TS__ArrayMap( -- 1512
				__TS__ObjectKeys(states), -- 1512
				function(____, key) return __TS__Number(key) end -- 1513
			), -- 1513
			function(____, index) return __TS__NumberIsFinite(index) end -- 1514
		), -- 1514
		function(____, a, b) return a - b end -- 1515
	) -- 1515
	return { -- 1516
		id = id, -- 1517
		created = created, -- 1518
		object = object, -- 1519
		model = model, -- 1520
		choices = __TS__ArrayMap( -- 1521
			indexes, -- 1521
			function(____, index) -- 1521
				local state = states[index] -- 1522
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1523
			end -- 1521
		), -- 1521
		usage = usage, -- 1534
		error = providerError -- 1535
	} -- 1535
end -- 1503
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1539
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1539
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1550
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1551
		local resolvedConfig = config or (function() -- 1554
			local configRes = ____exports.getActiveLLMConfig() -- 1555
			if not configRes.success then -- 1555
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1557
				return nil -- 1558
			end -- 1558
			return configRes.config -- 1560
		end)() -- 1554
		if not resolvedConfig then -- 1554
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1554
		end -- 1554
		local url = resolvedConfig.url -- 1554
		local model = resolvedConfig.model -- 1554
		local apiKey = resolvedConfig.apiKey -- 1554
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1566
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1567
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1568
		local ____model_36 = model -- 1571
		local ____url_37 = url -- 1571
		local ____temp_38 = #messages -- 1571
		local ____tostring_33 = tostring -- 1571
		local ____options_max_tokens_32 = options.max_tokens -- 1571
		if ____options_max_tokens_32 == nil then -- 1571
			____options_max_tokens_32 = "unset" -- 1571
		end -- 1571
		local ____tostring_33_result_39 = ____tostring_33(____options_max_tokens_32) -- 1571
		local ____tostring_35 = tostring -- 1571
		local ____options_temperature_34 = options.temperature -- 1571
		if ____options_temperature_34 == nil then -- 1571
			____options_temperature_34 = "unset" -- 1571
		end -- 1571
		____exports.Log( -- 1571
			"Info", -- 1571
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_36) .. " url=") .. ____url_37) .. " messages=") .. tostring(____temp_38)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_33_result_39) .. " temperature=") .. ____tostring_35(____options_temperature_34)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1571
		) -- 1571
		if stopToken and stopToken.stopped then -- 1571
			local reason = stopToken.reason or "request cancelled" -- 1573
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1574
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1574
		end -- 1574
		local ____hasReturned, ____returnValue -- 1574
		local ____try = __TS__AsyncAwaiter(function() -- 1574
			local states = {} -- 1578
			local emittedToolCallIds = {} -- 1579
			local responseId = nil -- 1580
			local responseCreated = nil -- 1581
			local responseObject = nil -- 1582
			local providerError -- 1583
			local responseUsage -- 1584
			local httpChunkCount = 0 -- 1585
			local rawStreamBytes = 0 -- 1586
			local rawStreamPreview = "" -- 1587
			local sseJSONChunkCount = 0 -- 1588
			local choiceJSONChunkCount = 0 -- 1589
			local emptyChoicesChunkCount = 0 -- 1590
			local missingChoicesChunkCount = 0 -- 1591
			local parseErrorCount = 0 -- 1592
			local doneChunkSeen = false -- 1593
			local lastJSONPreview = "" -- 1594
			local parser = createScheduledSSEJSONParser( -- 1595
				{ -- 1595
					onJSON = function(obj, raw) -- 1596
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1597
						lastJSONPreview = previewText(raw, 500) -- 1598
						if not obj or type(obj) ~= "table" then -- 1598
							return -- 1600
						end -- 1600
						local chunk = obj -- 1602
						if chunk.error then -- 1602
							providerError = chunk.error -- 1604
							____exports.Log( -- 1605
								"Warn", -- 1605
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1605
							) -- 1605
							return -- 1606
						end -- 1606
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1608
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1609
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1610
						if chunk.usage and type(chunk.usage) == "table" then -- 1610
							responseUsage = chunk.usage -- 1612
						end -- 1612
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1614
						if not __TS__ArrayIsArray(chunk.choices) then -- 1614
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1616
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1616
								____exports.Log( -- 1618
									"Warn", -- 1618
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1618
								) -- 1618
							end -- 1618
						elseif #choices == 0 then -- 1618
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1621
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1621
								____exports.Log( -- 1623
									"Warn", -- 1623
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1623
								) -- 1623
							end -- 1623
						else -- 1623
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1626
						end -- 1626
						do -- 1626
							local i = 0 -- 1628
							while i < #choices do -- 1628
								local choice = choices[i + 1] -- 1629
								local index = type(choice.index) == "number" and choice.index or i -- 1630
								if states[index] == nil then -- 1630
									states[index] = {index = index, message = {role = "assistant"}} -- 1631
								end -- 1631
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1635
								i = i + 1 -- 1628
							end -- 1628
						end -- 1628
						if onChunk ~= nil then -- 1628
							onChunk( -- 1637
								buildStreamResponse( -- 1638
									states, -- 1638
									model, -- 1638
									responseId, -- 1638
									responseCreated, -- 1638
									responseObject, -- 1638
									providerError, -- 1638
									responseUsage -- 1638
								), -- 1638
								{ -- 1639
									id = chunk.id or "", -- 1640
									created = chunk.created or 0, -- 1641
									object = chunk.object or "", -- 1642
									model = chunk.model or model, -- 1643
									choices = choices -- 1644
								} -- 1644
							) -- 1644
						end -- 1644
					end, -- 1596
					onDone = function() -- 1648
						doneChunkSeen = true -- 1649
					end, -- 1648
					onError = function(err, context) -- 1651
						parseErrorCount = parseErrorCount + 1 -- 1652
						____exports.Log( -- 1653
							"Warn", -- 1653
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1653
						) -- 1653
					end -- 1651
				}, -- 1651
				function() return (stopToken and stopToken.stopped) == true end -- 1655
			) -- 1655
			local ____try = __TS__AsyncAwaiter(function() -- 1655
				__TS__Await(postLLM( -- 1657
					fitted.messages, -- 1657
					url, -- 1657
					apiKey, -- 1657
					model, -- 1657
					options, -- 1657
					true, -- 1657
					resolvedConfig.customOptions, -- 1657
					function(data) -- 1657
						if stopToken and stopToken.stopped then -- 1657
							return true -- 1658
						end -- 1658
						httpChunkCount = httpChunkCount + 1 -- 1659
						rawStreamBytes = rawStreamBytes + #data -- 1660
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1660
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1662
						end -- 1662
						parser.append(data) -- 1664
						return false -- 1665
					end, -- 1657
					stopToken, -- 1666
					resolvedConfig.studioGateway -- 1666
				)) -- 1666
				__TS__Await(parser.finish()) -- 1667
			end) -- 1667
			____try = ____try.catch( -- 1667
				____try, -- 1667
				function(____, e) -- 1667
					return __TS__AsyncAwaiter(function() -- 1667
						parser.cancel() -- 1669
						error(e, 0) -- 1670
					end) -- 1670
				end -- 1670
			) -- 1670
			__TS__Await(____try) -- 1656
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1656
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1673
				if rawResponse and type(rawResponse) == "table" then -- 1673
					local rawResponseObj = rawResponse -- 1675
					if rawResponseObj.error then -- 1675
						providerError = rawResponseObj.error -- 1677
						lastJSONPreview = previewText( -- 1678
							normalizeLLMJSONResponse(rawStreamPreview), -- 1678
							500 -- 1678
						) -- 1678
						____exports.Log( -- 1679
							"Warn", -- 1679
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1679
						) -- 1679
					end -- 1679
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1679
						responseUsage = rawResponseObj.usage -- 1682
					end -- 1682
				end -- 1682
			end -- 1682
			local response = buildStreamResponse( -- 1686
				states, -- 1686
				model, -- 1686
				responseId, -- 1686
				responseCreated, -- 1686
				responseObject, -- 1686
				providerError, -- 1686
				responseUsage -- 1686
			) -- 1686
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1687
			local choiceCount = response.choices and #response.choices or 0 -- 1688
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1689
			____exports.Log( -- 1690
				"Info", -- 1690
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1690
			) -- 1690
			if not doneChunkSeen then -- 1690
				local rawPreview = previewText( -- 1692
					____exports.sanitizeUTF8(rawStreamPreview), -- 1692
					1200 -- 1692
				) -- 1692
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1693
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1694
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1695
				____hasReturned = true -- 1696
				____returnValue = { -- 1696
					success = false, -- 1697
					message = message, -- 1698
					raw = rawStreamPreview, -- 1699
					response = response, -- 1700
					tokenUsage = tokenUsage -- 1701
				} -- 1701
				return -- 1696
			end -- 1696
			if not response.choices or #response.choices == 0 then -- 1696
				local providerMessage = providerError and providerError.message or "" -- 1705
				local providerType = providerError and providerError.type or "" -- 1706
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1707
				local details = table.concat( -- 1710
					__TS__ArrayFilter( -- 1710
						{providerType, providerCode}, -- 1710
						function(____, part) return part ~= "" end -- 1710
					), -- 1710
					"/" -- 1710
				) -- 1710
				local rawPreview = previewText( -- 1711
					____exports.sanitizeUTF8(rawStreamPreview), -- 1711
					1200 -- 1711
				) -- 1711
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1712
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1713
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1716
				____hasReturned = true -- 1717
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1717
				return -- 1717
			end -- 1717
			____hasReturned = true -- 1724
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1724
			return -- 1724
		end) -- 1724
		____try = ____try.catch( -- 1724
			____try, -- 1724
			function(____, e) -- 1724
				return __TS__AsyncAwaiter(function() -- 1724
					if stopToken and stopToken.stopped then -- 1724
						local reason = stopToken.reason or "request cancelled" -- 1731
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1732
						____hasReturned = true -- 1733
						____returnValue = {success = false, message = reason} -- 1733
						return -- 1733
					end -- 1733
					____exports.Log( -- 1735
						"Error", -- 1735
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1735
					) -- 1735
					____hasReturned = true -- 1736
					____returnValue = { -- 1736
						success = false, -- 1736
						message = tostring(e) -- 1736
					} -- 1736
					return -- 1736
				end) -- 1736
			end -- 1736
		) -- 1736
		__TS__Await(____try) -- 1577
		if ____hasReturned then -- 1577
			return ____awaiter_resolve(nil, ____returnValue) -- 1577
		end -- 1577
	end) -- 1577
end -- 1539
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1740
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1740
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1746
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1747
		local resolvedConfig = config or (function() -- 1750
			local configRes = ____exports.getActiveLLMConfig() -- 1751
			if not configRes.success then -- 1751
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1753
				return nil -- 1754
			end -- 1754
			return configRes.config -- 1756
		end)() -- 1750
		if not resolvedConfig then -- 1750
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1750
		end -- 1750
		local url = resolvedConfig.url -- 1750
		local model = resolvedConfig.model -- 1750
		local apiKey = resolvedConfig.apiKey -- 1750
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1762
		____exports.Log( -- 1763
			"Info", -- 1763
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1763
		) -- 1763
		if stopToken and stopToken.stopped then -- 1763
			local reason = stopToken.reason or "request cancelled" -- 1765
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1766
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1766
		end -- 1766
		local ____hasReturned, ____returnValue -- 1766
		local ____try = __TS__AsyncAwaiter(function() -- 1766
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1770
				fitted.messages, -- 1770
				url, -- 1770
				apiKey, -- 1770
				model, -- 1770
				options, -- 1770
				false, -- 1770
				resolvedConfig.customOptions, -- 1770
				nil, -- 1770
				stopToken, -- 1770
				resolvedConfig.studioGateway -- 1770
			))) -- 1770
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1771
			____exports.Log( -- 1772
				"Info", -- 1772
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1772
			) -- 1772
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1773
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1773
				local rawPreview = previewText(raw) -- 1775
				____exports.Log( -- 1776
					"Error", -- 1776
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1776
				) -- 1776
				____hasReturned = true -- 1777
				____returnValue = { -- 1777
					success = false, -- 1778
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1779
					raw = raw -- 1780
				} -- 1780
				return -- 1777
			end -- 1777
			local responseObj = response -- 1783
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1784
			____exports.Log( -- 1785
				"Info", -- 1785
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1785
			) -- 1785
			if not responseObj.choices or #responseObj.choices == 0 then -- 1785
				local providerError = responseObj.error -- 1787
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1788
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1791
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1794
				local details = table.concat( -- 1797
					__TS__ArrayFilter( -- 1797
						{providerType, providerCode}, -- 1797
						function(____, part) return part ~= "" end -- 1797
					), -- 1797
					"/" -- 1797
				) -- 1797
				local rawPreview = previewText(raw, 400) -- 1798
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1799
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1802
				____hasReturned = true -- 1803
				____returnValue = {success = false, message = message, raw = raw} -- 1803
				return -- 1803
			end -- 1803
			____hasReturned = true -- 1809
			____returnValue = {success = true, response = responseObj} -- 1809
			return -- 1809
		end) -- 1809
		____try = ____try.catch( -- 1809
			____try, -- 1809
			function(____, e) -- 1809
				return __TS__AsyncAwaiter(function() -- 1809
					if stopToken and stopToken.stopped then -- 1809
						local reason = stopToken.reason or "request cancelled" -- 1815
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1816
						____hasReturned = true -- 1817
						____returnValue = {success = false, message = reason} -- 1817
						return -- 1817
					end -- 1817
					____exports.Log( -- 1819
						"Error", -- 1819
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1819
					) -- 1819
					____hasReturned = true -- 1820
					____returnValue = { -- 1820
						success = false, -- 1820
						message = tostring(e) -- 1820
					} -- 1820
					return -- 1820
				end) -- 1820
			end -- 1820
		) -- 1820
		__TS__Await(____try) -- 1769
		if ____hasReturned then -- 1769
			return ____awaiter_resolve(nil, ____returnValue) -- 1769
		end -- 1769
	end) -- 1769
end -- 1740
return ____exports -- 1740