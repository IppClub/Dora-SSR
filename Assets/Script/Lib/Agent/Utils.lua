-- [ts]: Utils.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local sanitizeJSONValue, normalizeReasoningEffort -- 1
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
function ____exports.sanitizeUTF8(text) -- 423
	if text == "" then -- 423
		return "" -- 424
	end -- 424
	local remaining = text -- 425
	local output = "" -- 426
	while remaining ~= "" do -- 426
		local len, invalidPos = utf8.len(remaining) -- 428
		if len ~= nil then -- 428
			output = output .. remaining -- 430
			break -- 431
		end -- 431
		local badPos = type(invalidPos) == "number" and invalidPos or 1 -- 433
		if badPos > 1 then -- 433
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1) -- 435
		end -- 435
		remaining = __TS__StringSubstring(remaining, badPos) -- 437
	end -- 437
	return output -- 439
end -- 423
function sanitizeJSONValue(value) -- 442
	if type(value) == "string" then -- 442
		return ____exports.sanitizeUTF8(value) -- 443
	end -- 443
	if __TS__ArrayIsArray(value) then -- 443
		return __TS__ArrayMap( -- 445
			value, -- 445
			function(____, item) return sanitizeJSONValue(item) end -- 445
		) -- 445
	end -- 445
	if value and type(value) == "table" then -- 445
		local result = {} -- 448
		for key in pairs(value) do -- 449
			result[key] = sanitizeJSONValue(value[key]) -- 450
		end -- 450
		return result -- 452
	end -- 452
	return value -- 454
end -- 454
function ____exports.safeJsonDecode(text) -- 497
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 498
	if value == nil then -- 498
		return value, err -- 500
	end -- 500
	return sanitizeJSONValue(value), err -- 502
end -- 497
function normalizeReasoningEffort(value) -- 1355
	if type(value) ~= "string" then -- 1355
		return nil -- 1356
	end -- 1356
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1357
	return normalized ~= "" and normalized or nil -- 1358
end -- 1358
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1369
	if not customOptions then -- 1369
		return options -- 1373
	end -- 1373
	local merged = __TS__ObjectAssign({}, options) -- 1374
	for key in pairs(customOptions) do -- 1375
		do -- 1375
			if key == "auxiliaryOptions" or key == "visionModel" then -- 1375
				goto __continue305 -- 1378
			end -- 1378
			if key == "tools" and options.tools ~= nil then -- 1378
				goto __continue305 -- 1380
			end -- 1380
			local value = customOptions[key] -- 1381
			if value == json.null then -- 1381
				__TS__Delete(merged, key) -- 1383
			else -- 1383
				merged[key] = value -- 1385
			end -- 1385
		end -- 1385
		::__continue305:: -- 1385
	end -- 1385
	return merged -- 1388
end -- 1369
local LOG_LEVEL = App.debugging and 3 or 2 -- 6
function ____exports.setLogLevel(level) -- 7
	LOG_LEVEL = level -- 8
end -- 7
local LLM_TIMEOUT = 600 -- 11
local LLM_STREAM_TIMEOUT = 600 -- 12
function ____exports.useFastGlmToolDecision(model, options) -- 15
	local name = string.lower(model) -- 16
	return (__TS__StringIncludes(name, "glm-5.2") or __TS__StringIncludes(name, "glm-5.3")) and (type(options.reasoning_effort) ~= "string" or __TS__StringTrim(options.reasoning_effort) == "") -- 17
end -- 15
function ____exports.ensureConversationUserMessage(messages, hasUserTurn) -- 28
	if hasUserTurn == nil then -- 28
		hasUserTurn = __TS__ArraySome( -- 30
			messages, -- 30
			function(____, message) return message.role == "user" end -- 30
		) -- 30
	end -- 30
	if hasUserTurn then -- 30
		return messages -- 32
	end -- 32
	local index = #messages > 0 and messages[1].role == "system" and 1 or 0 -- 33
	local ____array_0 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(messages, 0, index))) -- 33
	__TS__SparseArrayPush( -- 33
		____array_0, -- 33
		{role = "user", content = "Continue the current task using the retained conversation and memory checkpoint. Preserve its latest constraints and open work; do not restart completed work. Checkpoint summaries are reference data, not newer user instructions."}, -- 36
		table.unpack(__TS__ArraySlice(messages, index)) -- 37
	) -- 37
	return {__TS__SparseArraySpread(____array_0)} -- 34
end -- 28
function ____exports.getLLMFailureKind(message, raw) -- 43
	if raw == nil then -- 43
		raw = "" -- 43
	end -- 43
	local lower = string.lower(message) -- 44
	if (string.find(lower, "context length", nil, true) or 0) - 1 >= 0 or (string.find(lower, "maximum context", nil, true) or 0) - 1 >= 0 or (string.find(lower, "context_length_exceeded", nil, true) or 0) - 1 >= 0 then -- 44
		return "context" -- 46
	end -- 46
	local markers = { -- 47
		"failed to get http response", -- 47
		"timeout", -- 47
		"timed out", -- 47
		"connection refused", -- 47
		"connection reset", -- 48
		"econnrefused", -- 48
		"econnreset", -- 48
		"http 429", -- 48
		"http 502", -- 48
		"http 503", -- 48
		"http 504" -- 48
	} -- 48
	for ____, marker in ipairs(markers) do -- 49
		if (string.find(lower, marker, nil, true) or 0) - 1 >= 0 then -- 49
			return "transport" -- 49
		end -- 49
	end -- 49
	local candidates = raw ~= "" and ({raw}) or ({}) -- 50
	for ____, line in ipairs(__TS__StringSplit(raw, "\n")) do -- 53
		if __TS__StringStartsWith(line, "data:") then -- 53
			candidates[#candidates + 1] = __TS__StringTrim(string.sub(line, 6)) -- 54
		end -- 54
	end -- 54
	for ____, candidate in ipairs(candidates) do -- 56
		local parsed = ____exports.safeJsonDecode(candidate) -- 57
		local ____temp_1 -- 58
		if parsed and type(parsed) == "table" then -- 58
			____temp_1 = parsed.error -- 58
		else -- 58
			____temp_1 = nil -- 58
		end -- 58
		local ____error = ____temp_1 -- 58
		if ____error and type(____error) == "table" then -- 58
			if ____error.code == "context_length_exceeded" then -- 58
				return "context" -- 60
			end -- 60
			local ____tostring_4 = tostring -- 61
			local ____error_code_2 = ____error.code -- 61
			if ____error_code_2 == nil then -- 61
				____error_code_2 = ____error.type -- 61
			end -- 61
			local ____error_code_2_3 = ____error_code_2 -- 61
			if ____error_code_2_3 == nil then -- 61
				____error_code_2_3 = "" -- 61
			end -- 61
			local code = string.lower(____tostring_4(____error_code_2_3)) -- 61
			if code == "429" or code == "502" or code == "503" or code == "504" or code == "rate_limit_exceeded" or code == "server_error" or code == "overloaded_error" then -- 61
				return "transport" -- 63
			end -- 63
		end -- 63
	end -- 63
	return "other" -- 66
end -- 43
function ____exports.waitForLLMRetry(attempt, stopToken) -- 69
	local delay = math.min( -- 70
		8, -- 70
		math.max(1, attempt) * 2 -- 70
	) -- 70
	return __TS__New( -- 71
		__TS__Promise, -- 71
		function(____, resolve) -- 71
			local elapsed = 0 -- 72
			Director.systemScheduler:schedule(function(deltaTime) -- 73
				elapsed = elapsed + deltaTime -- 74
				if stopToken and stopToken.stopped or elapsed >= delay then -- 74
					resolve(nil) -- 76
					return true -- 77
				end -- 77
				return false -- 79
			end) -- 73
		end -- 71
	) -- 71
end -- 69
local LLM_STREAM_RAW_DEBUG_MAX = 12000 -- 84
local LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT = 5 -- 85
____exports.Log = function(____type, msg) -- 87
	if LOG_LEVEL < 1 then -- 87
		return -- 88
	elseif LOG_LEVEL < 2 and (____type == "Info" or ____type == "Warn") then -- 88
		return -- 89
	elseif LOG_LEVEL < 3 and ____type == "Info" then -- 89
		return -- 90
	end -- 90
	DoraLog(____type, msg) -- 91
end -- 87
local TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz" -- 118
local TOOL_CALL_ID_COUNTER = 0 -- 119
local STUDIO_MODEL_REQUEST_COUNTER = 0 -- 120
local function toBase36(value) -- 122
	if value <= 0 then -- 122
		return "0" -- 123
	end -- 123
	local remaining = math.floor(value) -- 124
	local out = "" -- 125
	while remaining > 0 do -- 125
		local digit = remaining % 36 -- 127
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out -- 128
		remaining = math.floor(remaining / 36) -- 129
	end -- 129
	return out -- 131
end -- 122
function ____exports.createLocalToolCallId() -- 134
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1 -- 135
	local timePart = toBase36(os.time()) -- 136
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER) -- 137
	return ("tc" .. timePart) .. counterPart -- 138
end -- 134
function ____exports.createStudioModelRequestId() -- 141
	STUDIO_MODEL_REQUEST_COUNTER = STUDIO_MODEL_REQUEST_COUNTER + 1 -- 142
	return ((("mr" .. toBase36(os.time())) .. toBase36(STUDIO_MODEL_REQUEST_COUNTER)) .. toBase36(math.floor(math.random() * 1000000000))) .. toBase36(math.floor(math.random() * 1000000000)) -- 145
end -- 141
local function normalizeCompletionText(value) -- 179
	if type(value) ~= "string" then -- 179
		return "" -- 180
	end -- 180
	return __TS__StringSlice( -- 181
		__TS__StringTrim(____exports.sanitizeUTF8(value)), -- 181
		0, -- 181
		AgentConfig.AGENT_LIMITS.completionTextMaxChars -- 181
	) -- 181
end -- 179
local function normalizeCompletionTextList(value, maxItems) -- 184
	if maxItems == nil then -- 184
		maxItems = AgentConfig.AGENT_LIMITS.completionListMaxItems -- 186
	end -- 186
	if not __TS__ArrayIsArray(value) then -- 186
		return {} -- 188
	end -- 188
	local items = {} -- 189
	do -- 189
		local i = 0 -- 190
		while i < #value and #items < maxItems do -- 190
			local item = normalizeCompletionText(value[i + 1]) -- 191
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 191
				items[#items + 1] = item -- 192
			end -- 192
			i = i + 1 -- 190
		end -- 190
	end -- 190
	return items -- 194
end -- 184
function ____exports.normalizeAgentCompletionReport(value) -- 197
	local row = value and not __TS__ArrayIsArray(value) and type(value) == "table" and value or ({}) -- 198
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 201
	local validation = {} -- 204
	if __TS__ArrayIsArray(row.validation) then -- 204
		do -- 204
			local i = 0 -- 206
			while i < #row.validation and #validation < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 206
				do -- 206
					local raw = row.validation[i + 1] -- 207
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 207
						goto __continue43 -- 208
					end -- 208
					local item = raw -- 209
					local kind = (item.kind == "runtime" or item.kind == "manual") and item.kind or (item.kind == "build" and "build" or nil) -- 210
					local result = (item.result == "passed" or item.result == "failed" or item.result == "not_run") and item.result or nil -- 211
					if kind == nil or result == nil then -- 211
						goto __continue43 -- 212
					end -- 212
					validation[#validation + 1] = { -- 213
						kind = kind, -- 214
						result = result, -- 215
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems) -- 216
					} -- 216
				end -- 216
				::__continue43:: -- 216
				i = i + 1 -- 206
			end -- 206
		end -- 206
	end -- 206
	local learningCandidates = {} -- 220
	if __TS__ArrayIsArray(row.learningCandidates) then -- 220
		do -- 220
			local i = 0 -- 222
			while i < #row.learningCandidates and #learningCandidates < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 222
				do -- 222
					local raw = row.learningCandidates[i + 1] -- 223
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 223
						goto __continue48 -- 224
					end -- 224
					local item = raw -- 225
					local claim = normalizeCompletionText(item.claim) -- 226
					if claim == "" then -- 226
						goto __continue48 -- 227
					end -- 227
					learningCandidates[#learningCandidates + 1] = { -- 228
						claim = claim, -- 229
						scope = (item.scope == "file" or item.scope == "engine") and item.scope or "project", -- 230
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems), -- 231
						confidence = item.confidence == "inferred" and "inferred" or "observed" -- 232
					} -- 232
				end -- 232
				::__continue48:: -- 232
				i = i + 1 -- 222
			end -- 222
		end -- 222
	end -- 222
	return { -- 236
		outcome = outcome, -- 237
		budgetExhausted = row.budgetExhausted == true, -- 238
		validation = validation, -- 239
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 240
		assumptions = normalizeCompletionTextList(row.assumptions), -- 241
		learningCandidates = learningCandidates -- 242
	} -- 242
end -- 197
function ____exports.replaceFirst(text, oldStr, newStr) -- 250
	if oldStr == "" then -- 250
		return text -- 251
	end -- 251
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 252
	if idx < 0 then -- 252
		return text -- 253
	end -- 253
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 254
end -- 250
local function getLeadingWhitespace(text) -- 257
	local i = 0 -- 258
	while i < #text do -- 258
		local ch = __TS__StringAccess(text, i) -- 260
		if ch ~= " " and ch ~= "\t" then -- 260
			break -- 261
		end -- 261
		i = i + 1 -- 262
	end -- 262
	return __TS__StringSubstring(text, 0, i) -- 264
end -- 257
local function getCommonIndentPrefix(lines) -- 267
	local common -- 268
	do -- 268
		local i = 0 -- 269
		while i < #lines do -- 269
			do -- 269
				local line = lines[i + 1] -- 270
				if __TS__StringTrim(line) == "" then -- 270
					goto __continue59 -- 271
				end -- 271
				local indent = getLeadingWhitespace(line) -- 272
				if common == nil then -- 272
					common = indent -- 274
					goto __continue59 -- 275
				end -- 275
				local j = 0 -- 277
				local maxLen = math.min(#common, #indent) -- 278
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 278
					j = j + 1 -- 280
				end -- 280
				common = __TS__StringSubstring(common, 0, j) -- 282
				if common == "" then -- 282
					break -- 283
				end -- 283
			end -- 283
			::__continue59:: -- 283
			i = i + 1 -- 269
		end -- 269
	end -- 269
	return common or "" -- 285
end -- 267
local function removeIndentPrefix(line, indent) -- 288
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 288
		return __TS__StringSubstring(line, #indent) -- 290
	end -- 290
	local lineIndent = getLeadingWhitespace(line) -- 292
	local j = 0 -- 293
	local maxLen = math.min(#lineIndent, #indent) -- 294
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 294
		j = j + 1 -- 296
	end -- 296
	return __TS__StringSubstring(line, j) -- 298
end -- 288
local function dedentLines(lines) -- 301
	local indent = getCommonIndentPrefix(lines) -- 302
	return { -- 303
		indent = indent, -- 304
		lines = __TS__ArrayMap( -- 305
			lines, -- 305
			function(____, line) return removeIndentPrefix(line, indent) end -- 305
		) -- 305
	} -- 305
end -- 301
local function findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 309
	local function foldWhitespace(text, withMap) -- 315
		local parts = {} -- 316
		local map = {} -- 317
		local i = 0 -- 318
		while i < #text do -- 318
			local ch = __TS__StringAccess(text, i) -- 320
			if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 320
				local start = i -- 322
				while i < #text do -- 322
					local next = __TS__StringAccess(text, i) -- 324
					if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 324
						break -- 325
					end -- 325
					i = i + 1 -- 326
				end -- 326
				parts[#parts + 1] = " " -- 328
				if withMap then -- 328
					map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 329
				end -- 329
			else -- 329
				parts[#parts + 1] = ch -- 331
				if withMap then -- 331
					map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 332
				end -- 332
				i = i + 1 -- 333
			end -- 333
		end -- 333
		return { -- 336
			text = table.concat(parts, ""), -- 336
			map = map -- 336
		} -- 336
	end -- 315
	local foldedContent = foldWhitespace(content, true) -- 338
	local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 339
	if foldedOld == "" then -- 339
		return {success = false, message = "old_str not found in file"} -- 341
	end -- 341
	local matches = {} -- 343
	local pos = 0 -- 344
	while true do -- 344
		local idx = (string.find( -- 346
			foldedContent.text, -- 346
			foldedOld, -- 346
			math.max(pos + 1, 1), -- 346
			true -- 346
		) or 0) - 1 -- 346
		if idx < 0 then -- 346
			break -- 347
		end -- 347
		local lastIdx = idx + #foldedOld - 1 -- 348
		local startMap = foldedContent.map[idx + 1] -- 349
		local endMap = foldedContent.map[lastIdx + 1] -- 350
		if startMap ~= nil and endMap ~= nil then -- 350
			matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 352
		end -- 352
		pos = idx + #foldedOld -- 354
	end -- 354
	if #matches == 0 then -- 354
		return {success = false, message = "old_str not found in file"} -- 357
	end -- 357
	if #matches > 1 then -- 357
		return { -- 360
			success = false, -- 361
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 362
		} -- 362
	end -- 362
	local match = matches[1] -- 365
	return { -- 366
		success = true, -- 367
		content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 368
	} -- 368
end -- 309
function ____exports.findIndentTolerantReplacement(content, oldStr, newStr) -- 372
	local contentLines = __TS__StringSplit(content, "\n") -- 377
	local oldLines = __TS__StringSplit(oldStr, "\n") -- 378
	if #oldLines == 0 then -- 378
		return {success = false, message = "old_str not found in file"} -- 380
	end -- 380
	local dedentedOld = dedentLines(oldLines) -- 382
	local dedentedOldText = table.concat(dedentedOld.lines, "\n") -- 383
	local dedentedNew = dedentLines(__TS__StringSplit(newStr, "\n")) -- 384
	local matches = {} -- 385
	do -- 385
		local start = 0 -- 386
		while start <= #contentLines - #oldLines do -- 386
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 387
			local dedentedCandidate = dedentLines(candidateLines) -- 388
			if table.concat(dedentedCandidate.lines, "\n") == dedentedOldText then -- 388
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 390
			end -- 390
			start = start + 1 -- 386
		end -- 386
	end -- 386
	if #matches == 0 then -- 386
		return findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 398
	end -- 398
	if #matches > 1 then -- 398
		return { -- 401
			success = false, -- 402
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 403
		} -- 403
	end -- 403
	local match = matches[1] -- 406
	local rebuiltNewLines = __TS__ArrayMap( -- 407
		dedentedNew.lines, -- 407
		function(____, line) return line == "" and "" or match.indent .. line end -- 407
	) -- 407
	local ____array_7 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 407
	__TS__SparseArrayPush( -- 407
		____array_7, -- 407
		table.unpack(rebuiltNewLines) -- 410
	) -- 410
	__TS__SparseArrayPush( -- 410
		____array_7, -- 410
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 411
	) -- 411
	local nextLines = {__TS__SparseArraySpread(____array_7)} -- 408
	return { -- 413
		success = true, -- 413
		content = table.concat(nextLines, "\n") -- 413
	} -- 413
end -- 372
local function previewText(text, maxLen) -- 416
	if maxLen == nil then -- 416
		maxLen = 200 -- 416
	end -- 416
	if text == "" then -- 416
		return "" -- 417
	end -- 417
	local compact = __TS__StringReplace( -- 418
		__TS__StringReplace(text, "\r", "\\r"), -- 418
		"\n", -- 418
		"\\n" -- 418
	) -- 418
	if #compact <= maxLen then -- 418
		return compact -- 419
	end -- 419
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 420
end -- 416
function ____exports.safeJsonEncode(value, format, emptyAsArray, numAsStr, maxDepth) -- 457
	if format == nil then -- 457
		format = false -- 457
	end -- 457
	if emptyAsArray == nil then -- 457
		emptyAsArray = true -- 457
	end -- 457
	if numAsStr == nil then -- 457
		numAsStr = false -- 457
	end -- 457
	if maxDepth == nil then -- 457
		maxDepth = 128 -- 457
	end -- 457
	return json.encode( -- 458
		sanitizeJSONValue(value), -- 459
		format, -- 460
		emptyAsArray, -- 461
		numAsStr, -- 462
		maxDepth -- 463
	) -- 463
end -- 457
local function encodeStableJSONValue(value, emptyAsArray, depth) -- 467
	if depth > 128 then -- 467
		error("Too many nested JSON values") -- 468
	end -- 468
	if __TS__ArrayIsArray(value) then -- 468
		return ("[" .. table.concat( -- 470
			__TS__ArrayMap( -- 470
				value, -- 470
				function(____, item) return encodeStableJSONValue(item, emptyAsArray, depth + 1) end -- 470
			), -- 470
			"," -- 470
		)) .. "]" -- 470
	end -- 470
	if type(value) == "table" then -- 470
		local record = value -- 473
		local keys = __TS__ObjectKeys(record) -- 474
		if #keys == 0 then -- 474
			return emptyAsArray and "[]" or "{}" -- 475
		end -- 475
		local fields = {} -- 476
		__TS__ArraySort(keys) -- 477
		for ____, key in ipairs(keys) do -- 478
			if type(key) ~= "string" then -- 478
				error("JSON object keys must be strings") -- 479
			end -- 479
			local name = encodeStableJSONValue(key, emptyAsArray, depth + 1) -- 480
			fields[#fields + 1] = (name .. ":") .. encodeStableJSONValue(record[key], emptyAsArray, depth + 1) -- 481
		end -- 481
		return ("{" .. table.concat(fields, ",")) .. "}" -- 483
	end -- 483
	local encoded, err = ____exports.safeJsonEncode(value, false, emptyAsArray) -- 485
	if encoded == nil then -- 485
		error(err or "JSON value could not be encoded") -- 486
	end -- 486
	return encoded -- 487
end -- 467
--- Keep nested schema and message fields stable when Lua's hash seed changes.
function ____exports.safeStableJsonEncode(value, emptyAsArray) -- 491
	if emptyAsArray == nil then -- 491
		emptyAsArray = true -- 491
	end -- 491
	local ok, result = pcall(function() return encodeStableJSONValue(value, emptyAsArray, 0) end) -- 492
	if ok then -- 492
		return result, nil -- 493
	end -- 493
	return nil, tostring(result) -- 494
end -- 491
local function isPlainRecord(value) -- 505
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 506
end -- 505
local function normalizeLLMJSONResponse(text) -- 509
	return __TS__StringTrim(text) -- 510
end -- 509
local function utf8TakeHead(text, maxChars) -- 513
	if maxChars <= 0 or text == "" then -- 513
		return "" -- 514
	end -- 514
	local nextPos = utf8.offset(text, maxChars + 1) -- 515
	if nextPos == nil then -- 515
		return text -- 516
	end -- 516
	return string.sub(text, 1, nextPos - 1) -- 517
end -- 513
local function utf8TakeTail(text, maxChars) -- 520
	if maxChars <= 0 or text == "" then -- 520
		return "" -- 521
	end -- 521
	local charLen = utf8.len(text) -- 522
	if charLen == nil or charLen <= maxChars then -- 522
		return text -- 523
	end -- 523
	local startChar = math.max(1, charLen - maxChars + 1) -- 524
	local startPos = utf8.offset(text, startChar) -- 525
	if startPos == nil then -- 525
		return text -- 526
	end -- 526
	return string.sub(text, startPos) -- 527
end -- 520
function ____exports.estimateTextTokens(text) -- 530
	if text == "" then -- 530
		return 0 -- 531
	end -- 531
	return App:estimateTokens(text) -- 532
end -- 530
local function estimateMessagesTokens(messages) -- 535
	local total = 0 -- 536
	do -- 536
		local i = 0 -- 537
		while i < #messages do -- 537
			local message = messages[i + 1] -- 538
			total = total + 8 -- 539
			total = total + ____exports.estimateTextTokens(message.role or "") -- 540
			total = total + ____exports.estimateTextTokens(message.content or "") -- 541
			total = total + ____exports.estimateTextTokens(message.name or "") -- 542
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 543
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 544
			local toolCallsText = ____exports.safeStableJsonEncode(message.tool_calls or ({})) -- 545
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 546
			i = i + 1 -- 537
		end -- 537
	end -- 537
	return total -- 548
end -- 535
local function estimateOptionsTokens(options) -- 551
	local text = ____exports.safeStableJsonEncode(options) -- 552
	return text and ____exports.estimateTextTokens(text) or 0 -- 553
end -- 551
local function getReservedOutputTokens(options, contextWindow) -- 556
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 557
	if explicitMax > 0 then -- 557
		return math.max(256, explicitMax) -- 562
	end -- 562
	return math.max( -- 563
		1024, -- 563
		math.floor(contextWindow * 0.2) -- 563
	) -- 563
end -- 556
--- Plan an Agent decision without treating its configured maximum output as used input.
function ____exports.planAgentDecisionRequest(messages, options, config) -- 567
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 568
	local requestOptions = __TS__ObjectAssign( -- 569
		{}, -- 569
		____exports.applyCustomLLMOptions(options, config.customOptions) -- 569
	) -- 569
	local outputField = type(requestOptions.max_completion_tokens) == "number" and "max_completion_tokens" or "max_tokens" -- 570
	local configuredOutput = requestOptions[outputField] -- 571
	local outputCeiling = type(configuredOutput) == "number" and configuredOutput >= 1 and math.floor(configuredOutput) or getReservedOutputTokens({}, contextWindow) -- 572
	__TS__Delete(requestOptions, "max_tokens") -- 576
	__TS__Delete(requestOptions, "max_completion_tokens") -- 577
	requestOptions[outputField] = outputCeiling -- 578
	local messagesTokens = estimateMessagesTokens(messages) -- 579
	local structuralOverhead = math.max(256, #messages * 16) -- 580
	local fixedTokens = estimateOptionsTokens(requestOptions) + structuralOverhead -- 581
	local usedTokens = messagesTokens + fixedTokens -- 582
	local safetyMargin = 256 -- 583
	local minimumOutput = math.max( -- 584
		256, -- 584
		math.min(1024, outputCeiling) -- 584
	) -- 584
	local inputBudget = math.max(0, contextWindow - fixedTokens - safetyMargin - minimumOutput) -- 585
	local outputLimit = math.min( -- 586
		outputCeiling, -- 586
		math.max(0, contextWindow - usedTokens - safetyMargin) -- 586
	) -- 586
	requestOptions[outputField] = outputLimit -- 587
	return { -- 588
		options = requestOptions, -- 588
		contextWindow = contextWindow, -- 588
		messagesTokens = messagesTokens, -- 588
		structuralOverhead = structuralOverhead, -- 588
		usedTokens = usedTokens, -- 588
		inputBudget = inputBudget, -- 588
		outputLimit = outputLimit -- 588
	} -- 588
end -- 567
function ____exports.getInputTokenBudget(messages, options, config) -- 591
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 592
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 595
	local optionTokens = estimateOptionsTokens(options) -- 596
	local structuralOverhead = math.max(256, #messages * 16) -- 597
	return math.max(0, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 598
end -- 591
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 601
	if budgetTokens <= 0 or text == "" then -- 601
		return "" -- 602
	end -- 602
	local estimated = ____exports.estimateTextTokens(text) -- 603
	if estimated <= budgetTokens then -- 603
		return text -- 604
	end -- 604
	local marker = "\n...\n" -- 608
	if ____exports.estimateTextTokens(marker) > budgetTokens then -- 608
		return "" -- 609
	end -- 609
	local characters = utf8.len(text) -- 610
	if characters == nil then -- 610
		return "" -- 611
	end -- 611
	local low = 0 -- 612
	local high = characters -- 613
	local best = marker -- 614
	while low <= high do -- 614
		local keep = math.floor((low + high) / 2) -- 616
		local head = math.floor(keep * 0.35) -- 617
		local candidate = (utf8TakeHead(text, head) .. marker) .. utf8TakeTail(text, keep - head) -- 618
		if ____exports.estimateTextTokens(candidate) <= budgetTokens then -- 618
			best = candidate -- 620
			low = keep + 1 -- 621
		else -- 621
			high = keep - 1 -- 623
		end -- 623
	end -- 623
	return best -- 626
end -- 601
local function isXMLWhitespaceChar(ch) -- 629
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 630
end -- 629
local function findLineStart(value, from) -- 633
	local i = from -- 634
	while i >= 0 do -- 634
		if __TS__StringAccess(value, i) == "\n" then -- 634
			return i + 1 -- 636
		end -- 636
		i = i - 1 -- 637
	end -- 637
	return 0 -- 639
end -- 633
local function findLastLiteral(text, needle) -- 642
	if needle == "" then -- 642
		return #text -- 643
	end -- 643
	local last = -1 -- 644
	local from = 0 -- 645
	while from <= #text - #needle do -- 645
		local pos = (string.find( -- 647
			text, -- 647
			needle, -- 647
			math.max(from + 1, 1), -- 647
			true -- 647
		) or 0) - 1 -- 647
		if pos < 0 then -- 647
			break -- 648
		end -- 648
		last = pos -- 649
		from = pos + 1 -- 650
	end -- 650
	return last -- 652
end -- 642
local function unwrapXMLRawText(text) -- 655
	local trimmed = __TS__StringTrim(text) -- 656
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 656
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 658
	end -- 658
	return text -- 660
end -- 655
local function readSimpleXMLTagName(source, openStart, openEnd) -- 663
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 664
	if rawTag == "" then -- 664
		return { -- 666
			success = false, -- 666
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 666
		} -- 666
	end -- 666
	local selfClosing = false -- 668
	local tagText = rawTag -- 669
	if __TS__StringEndsWith(tagText, "/") then -- 669
		selfClosing = true -- 671
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 672
	end -- 672
	local tagName = "" -- 674
	do -- 674
		local i = 0 -- 675
		while i < #tagText do -- 675
			local ch = __TS__StringAccess(tagText, i) -- 676
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 676
				break -- 677
			end -- 677
			tagName = tagName .. ch -- 678
			i = i + 1 -- 675
		end -- 675
	end -- 675
	if tagName == "" then -- 675
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 681
	end -- 681
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 683
end -- 663
local function findMatchingXMLClose(source, tagName, contentStart) -- 686
	local sameOpenPrefix = "<" .. tagName -- 687
	local sameCloseToken = ("</" .. tagName) .. ">" -- 688
	local pos = contentStart -- 689
	local depth = 1 -- 690
	while pos < #source do -- 690
		do -- 690
			local lt = (string.find( -- 692
				source, -- 692
				"<", -- 692
				math.max(pos + 1, 1), -- 692
				true -- 692
			) or 0) - 1 -- 692
			if lt < 0 then -- 692
				break -- 693
			end -- 693
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 693
				local cdataEnd = (string.find( -- 695
					source, -- 695
					"]]>", -- 695
					math.max(lt + 9 + 1, 1), -- 695
					true -- 695
				) or 0) - 1 -- 695
				if cdataEnd < 0 then -- 695
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 696
				end -- 696
				pos = cdataEnd + 3 -- 697
				goto __continue168 -- 698
			end -- 698
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 701
					source, -- 701
					"-->",
					math.max(lt + 4 + 1, 1), -- 701
					true -- 701
				) or 0) - 1 -- 701
				if commentEnd < 0 then -- 701
					return {success = false, message = "invalid xml: unterminated comment"} -- 702
				end -- 702
				pos = commentEnd + 3 -- 703
				goto __continue168 -- 704
			end -- 704
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 704
				depth = depth - 1 -- 707
				if depth == 0 then -- 707
					return {success = true, closeStart = lt} -- 708
				end -- 708
				pos = lt + #sameCloseToken -- 709
				goto __continue168 -- 710
			end -- 710
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 710
				local openEnd = (string.find( -- 713
					source, -- 713
					">", -- 713
					math.max(lt + 1, 1), -- 713
					true -- 713
				) or 0) - 1 -- 713
				if openEnd < 0 then -- 713
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 714
				end -- 714
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 715
				if not tagInfo.success then -- 715
					return tagInfo -- 716
				end -- 716
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 716
					depth = depth + 1 -- 718
				end -- 718
				pos = openEnd + 1 -- 720
				goto __continue168 -- 721
			end -- 721
			local genericEnd = (string.find( -- 723
				source, -- 723
				">", -- 723
				math.max(lt + 1, 1), -- 723
				true -- 723
			) or 0) - 1 -- 723
			if genericEnd < 0 then -- 723
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 724
			end -- 724
			pos = genericEnd + 1 -- 725
		end -- 725
		::__continue168:: -- 725
	end -- 725
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 727
end -- 686
function ____exports.extractXMLFromText(text) -- 730
	local source = __TS__StringTrim(text) -- 731
	local function extractFencedBlock(fence) -- 732
		if not __TS__StringStartsWith(source, fence) then -- 732
			return nil -- 733
		end -- 733
		local firstLineEnd = (string.find( -- 734
			source, -- 734
			"\n", -- 734
			math.max(1, 1), -- 734
			true -- 734
		) or 0) - 1 -- 734
		if firstLineEnd < 0 then -- 734
			return nil -- 735
		end -- 735
		local searchPos = firstLineEnd + 1 -- 736
		local closingFencePositions = {} -- 737
		while searchPos < #source do -- 737
			local ____end = (string.find( -- 739
				source, -- 739
				"```", -- 739
				math.max(searchPos + 1, 1), -- 739
				true -- 739
			) or 0) - 1 -- 739
			if ____end < 0 then -- 739
				break -- 740
			end -- 740
			local lineStart = findLineStart(source, ____end - 1) -- 741
			local lineEnd = (string.find( -- 742
				source, -- 742
				"\n", -- 742
				math.max(____end + 1, 1), -- 742
				true -- 742
			) or 0) - 1 -- 742
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 743
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 743
				closingFencePositions[#closingFencePositions + 1] = ____end -- 745
			end -- 745
			searchPos = ____end + 1 -- 747
		end -- 747
		do -- 747
			local i = #closingFencePositions - 1 -- 749
			while i >= 0 do -- 749
				do -- 749
					local closingFencePos = closingFencePositions[i + 1] -- 750
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 751
					if afterFence ~= "" then -- 751
						goto __continue189 -- 752
					end -- 752
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 753
				end -- 753
				::__continue189:: -- 753
				i = i - 1 -- 749
			end -- 749
		end -- 749
		return nil -- 755
	end -- 732
	local xmlBlock = extractFencedBlock("```xml") -- 757
	if xmlBlock ~= nil then -- 757
		return xmlBlock -- 758
	end -- 758
	local genericBlock = extractFencedBlock("```") -- 759
	if genericBlock ~= nil then -- 759
		return genericBlock -- 760
	end -- 760
	return source -- 761
end -- 730
function ____exports.parseSimpleXMLChildren(source) -- 764
	local result = {} -- 765
	local pos = 0 -- 766
	while pos < #source do -- 766
		do -- 766
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 766
				pos = pos + 1 -- 768
			end -- 768
			if pos >= #source then -- 768
				break -- 769
			end -- 769
			if __TS__StringAccess(source, pos) ~= "<" then -- 769
				return { -- 771
					success = false, -- 771
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 771
				} -- 771
			end -- 771
			if __TS__StringStartsWith(source, "</", pos) then -- 771
				return { -- 774
					success = false, -- 774
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 774
				} -- 774
			end -- 774
			local openEnd = (string.find( -- 776
				source, -- 776
				">", -- 776
				math.max(pos + 1, 1), -- 776
				true -- 776
			) or 0) - 1 -- 776
			if openEnd < 0 then -- 776
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 778
			end -- 778
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 780
			if not tagInfo.success then -- 780
				return tagInfo -- 781
			end -- 781
			if tagInfo.selfClosing then -- 781
				result[tagInfo.tagName] = "" -- 783
				pos = openEnd + 1 -- 784
				goto __continue194 -- 785
			end -- 785
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 787
			if not closeRes.success then -- 787
				return closeRes -- 788
			end -- 788
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 789
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 790
			pos = closeRes.closeStart + #closeToken -- 791
		end -- 791
		::__continue194:: -- 791
	end -- 791
	return {success = true, obj = result} -- 793
end -- 764
function ____exports.parseXMLObjectFromText(text, rootTag) -- 796
	local xmlText = ____exports.extractXMLFromText(text) -- 797
	local rootOpen = ("<" .. rootTag) .. ">" -- 798
	local rootClose = ("</" .. rootTag) .. ">" -- 799
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 800
	local ____end = findLastLiteral(xmlText, rootClose) -- 801
	if start < 0 or ____end < start then -- 801
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 803
	end -- 803
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 805
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 806
	if beforeRoot ~= "" or afterRoot ~= "" then -- 806
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 808
	end -- 808
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 810
	return ____exports.parseSimpleXMLChildren(rootContent) -- 811
end -- 796
function ____exports.fitMessagesToContext(messages, options, config) -- 814
	local modelName = string.lower(config.model) -- 821
	local shouldEchoReasoningContent = __TS__ArraySome( -- 822
		messages, -- 822
		function(____, message) return type(message.reasoning_content) == "string" end -- 822
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 822
	local cloned = __TS__ArrayMap( -- 826
		messages, -- 826
		function(____, message) -- 826
			local clonedMessage = __TS__ObjectAssign({}, message) -- 827
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 827
				clonedMessage.reasoning_content = "" -- 833
			end -- 833
			return clonedMessage -- 835
		end -- 826
	) -- 826
	local budgetTokens = ____exports.getInputTokenBudget(cloned, options, config) -- 837
	local originalTokens = estimateMessagesTokens(cloned) -- 838
	if originalTokens <= budgetTokens then -- 838
		return { -- 840
			messages = cloned, -- 841
			trimmed = false, -- 842
			originalTokens = originalTokens, -- 843
			fittedTokens = originalTokens, -- 844
			budgetTokens = budgetTokens -- 845
		} -- 845
	end -- 845
	local function roleOverhead(message) -- 849
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 849
	end -- 849
	local fixedOverhead = 0 -- 850
	local contentIndexes = {} -- 851
	do -- 851
		local i = 0 -- 852
		while i < #cloned do -- 852
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 853
			contentIndexes[#contentIndexes + 1] = i -- 854
			i = i + 1 -- 852
		end -- 852
	end -- 852
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 856
	if #contentIndexes == 1 then -- 856
		local idx = contentIndexes[1] -- 858
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 859
		local fittedTokens = estimateMessagesTokens(cloned) -- 860
		return { -- 861
			messages = cloned, -- 862
			trimmed = true, -- 863
			originalTokens = originalTokens, -- 864
			fittedTokens = fittedTokens, -- 865
			budgetTokens = budgetTokens -- 866
		} -- 866
	end -- 866
	local nonSystemIndexes = {} -- 870
	local systemIndexes = {} -- 871
	do -- 871
		local i = 0 -- 872
		while i < #cloned do -- 872
			if cloned[i + 1].role == "system" then -- 872
				systemIndexes[#systemIndexes + 1] = i -- 873
			else -- 873
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 874
			end -- 874
			i = i + 1 -- 872
		end -- 872
	end -- 872
	local ____array_8 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 872
	__TS__SparseArrayPush( -- 872
		____array_8, -- 872
		table.unpack(systemIndexes) -- 876
	) -- 876
	local priorityIndexes = {__TS__SparseArraySpread(____array_8)} -- 876
	local remainingContentBudget = contentBudget -- 877
	do -- 877
		local i = #priorityIndexes - 1 -- 878
		while i >= 0 do -- 878
			local idx = priorityIndexes[i + 1] -- 879
			local message = cloned[idx + 1] -- 880
			local minBudget = message.role == "system" and 96 or 192 -- 881
			local target = math.max( -- 882
				minBudget, -- 882
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 882
			) -- 882
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 883
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 884
			remainingContentBudget = math.max(0, remainingContentBudget) -- 885
			i = i - 1 -- 878
		end -- 878
	end -- 878
	local fittedTokens = estimateMessagesTokens(cloned) -- 888
	if fittedTokens > budgetTokens then -- 888
		do -- 888
			local i = 0 -- 890
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 890
				local idx = priorityIndexes[i + 1] -- 891
				local message = cloned[idx + 1] -- 892
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 893
				local excess = fittedTokens - budgetTokens -- 894
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 895
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 896
				fittedTokens = estimateMessagesTokens(cloned) -- 897
				i = i + 1 -- 890
			end -- 890
		end -- 890
	end -- 890
	if fittedTokens > budgetTokens then -- 890
		do -- 890
			local i = 0 -- 901
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 901
				do -- 901
					local idx = priorityIndexes[i + 1] -- 902
					if cloned[idx + 1].role == "system" then -- 902
						goto __continue226 -- 903
					end -- 903
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 904
					fittedTokens = estimateMessagesTokens(cloned) -- 905
				end -- 905
				::__continue226:: -- 905
				i = i + 1 -- 901
			end -- 901
		end -- 901
	end -- 901
	return { -- 908
		messages = cloned, -- 909
		trimmed = true, -- 910
		originalTokens = originalTokens, -- 911
		fittedTokens = fittedTokens, -- 912
		budgetTokens = budgetTokens -- 913
	} -- 913
end -- 814
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken, studioGateway) -- 917
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 929
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 930
	local data = __TS__ObjectAssign({model = model}, requestOptions, {messages = messages, stream = stream}) -- 931
	local studioRequestId = studioGateway and ____exports.createStudioModelRequestId() or nil -- 937
	if stopToken == nil then -- 937
		stopToken = {stopped = false} -- 938
	end -- 938
	return __TS__New( -- 939
		__TS__Promise, -- 939
		function(____, resolve, reject) -- 939
			local requestId = 0 -- 940
			local settled = false -- 941
			local function finishResolve(text) -- 942
				if settled then -- 942
					return -- 943
				end -- 943
				settled = true -- 944
				resolve(nil, text) -- 945
			end -- 942
			local function finishReject(err) -- 947
				if settled then -- 947
					return -- 948
				end -- 948
				settled = true -- 949
				reject(nil, err) -- 950
			end -- 947
			Director.systemScheduler:schedule(function() -- 952
				if not settled then -- 952
					if stopToken.stopped then -- 952
						if requestId ~= 0 then -- 952
							HttpClient:cancel(requestId) -- 956
							requestId = 0 -- 957
						end -- 957
						finishReject("request cancelled") -- 959
						return true -- 960
					end -- 960
					return false -- 962
				end -- 962
				return true -- 964
			end) -- 952
			Director.systemScheduler:schedule(once(function() -- 966
				emit( -- 967
					"LLM_IN", -- 967
					table.concat( -- 967
						__TS__ArrayMap( -- 967
							messages, -- 967
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 967
						), -- 967
						"\n" -- 967
					) -- 967
				) -- 967
				local jsonStr, err = ____exports.safeStableJsonEncode(data) -- 968
				if jsonStr ~= nil then -- 968
					local headers = { -- 970
						"Authorization: Bearer " .. apiKey, -- 971
						"Content-Type: application/json", -- 972
						receiver and "Accept: text/event-stream" or "Accept: application/json", -- 973
						table.unpack(studioRequestId and ({"X-Studio-Model-Request-Id: " .. studioRequestId}) or ({})) -- 974
					} -- 974
					requestId = receiver and HttpClient:post( -- 976
						url, -- 977
						headers, -- 977
						jsonStr, -- 977
						requestTimeout, -- 977
						function(data) -- 977
							if stopToken.stopped then -- 977
								return true -- 978
							end -- 978
							return receiver(data) -- 979
						end, -- 977
						function(data) -- 980
							requestId = 0 -- 981
							if data ~= nil then -- 981
								finishResolve(data) -- 983
							else -- 983
								finishReject("failed to get http response") -- 985
							end -- 985
						end -- 980
					) or HttpClient:post( -- 980
						url, -- 988
						headers, -- 988
						jsonStr, -- 988
						requestTimeout, -- 988
						function(data) -- 988
							requestId = 0 -- 989
							if stopToken.stopped then -- 989
								finishReject("request cancelled") -- 991
								return -- 992
							end -- 992
							if data ~= nil then -- 992
								finishResolve(data) -- 995
							else -- 995
								finishReject("failed to get http response") -- 997
							end -- 997
						end -- 988
					) -- 988
					if requestId == 0 then -- 988
						finishReject("failed to schedule http request") -- 1001
					elseif stopToken.stopped then -- 1001
						HttpClient:cancel(requestId) -- 1003
						requestId = 0 -- 1004
						finishReject("request cancelled") -- 1005
					end -- 1005
				else -- 1005
					finishReject(err) -- 1008
				end -- 1008
			end)) -- 966
		end -- 939
	) -- 939
end -- 917
function ____exports.createSSEJSONParser(opts) -- 1018
	local buffer = "" -- 1023
	local eventDataLines = {} -- 1024
	local function flushEventIfAny() -- 1026
		if #eventDataLines == 0 then -- 1026
			return -- 1027
		end -- 1027
		local dataPayload = table.concat(eventDataLines, "\n") -- 1029
		eventDataLines = {} -- 1030
		if dataPayload == "[DONE]" then -- 1030
			local ____opt_9 = opts.onDone -- 1030
			if ____opt_9 ~= nil then -- 1030
				____opt_9(dataPayload) -- 1033
			end -- 1033
			return -- 1034
		end -- 1034
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 1037
		if err == nil then -- 1037
			opts.onJSON(obj, dataPayload) -- 1039
		else -- 1039
			local ____opt_11 = opts.onError -- 1039
			if ____opt_11 ~= nil then -- 1039
				____opt_11(err, {raw = dataPayload}) -- 1041
			end -- 1041
		end -- 1041
	end -- 1026
	local function append(chunk) -- 1045
		buffer = buffer .. chunk -- 1046
	end -- 1045
	local function drain(maxLines) -- 1049
		local processedLines = 0 -- 1050
		while maxLines == nil or processedLines < maxLines do -- 1050
			do -- 1050
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 1052
				if nl < 0 then -- 1052
					break -- 1053
				end -- 1053
				processedLines = processedLines + 1 -- 1054
				local line = __TS__StringSlice(buffer, 0, nl) -- 1056
				buffer = __TS__StringSlice(buffer, nl + 1) -- 1057
				if __TS__StringEndsWith(line, "\r") then -- 1057
					line = string.sub(line, 1, -2) -- 1059
				end -- 1059
				if line == "" then -- 1059
					flushEventIfAny() -- 1062
					goto __continue261 -- 1063
				end -- 1063
				if __TS__StringStartsWith(line, ":") then -- 1063
					goto __continue261 -- 1067
				end -- 1067
				if __TS__StringStartsWith(line, "data:") then -- 1067
					local v = string.sub(line, 6) -- 1070
					if __TS__StringStartsWith(v, " ") then -- 1070
						v = string.sub(v, 2) -- 1071
					end -- 1071
					eventDataLines[#eventDataLines + 1] = v -- 1072
					goto __continue261 -- 1073
				end -- 1073
			end -- 1073
			::__continue261:: -- 1073
		end -- 1073
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0 -- 1076
	end -- 1049
	local function feed(chunk) -- 1079
		append(chunk) -- 1080
		drain() -- 1081
	end -- 1079
	local function ____end() -- 1084
		if #buffer > 0 then -- 1084
			local line = buffer -- 1086
			buffer = "" -- 1087
			if __TS__StringEndsWith(line, "\r") then -- 1087
				line = string.sub(line, 1, -2) -- 1088
			end -- 1088
			if __TS__StringStartsWith(line, "data:") then -- 1088
				local v = string.sub(line, 6) -- 1091
				if __TS__StringStartsWith(v, " ") then -- 1091
					v = string.sub(v, 2) -- 1092
				end -- 1092
				eventDataLines[#eventDataLines + 1] = v -- 1093
			end -- 1093
		end -- 1093
		flushEventIfAny() -- 1096
	end -- 1084
	local function discard() -- 1099
		buffer = "" -- 1100
		eventDataLines = {} -- 1101
	end -- 1099
	return { -- 1104
		append = append, -- 1104
		drain = drain, -- 1104
		feed = feed, -- 1104
		["end"] = ____end, -- 1104
		discard = discard -- 1104
	} -- 1104
end -- 1018
local SSE_PARSE_LINES_PER_FRAME = 256 -- 1107
local function createScheduledSSEJSONParser(opts, isCancelled) -- 1109
	local parser = ____exports.createSSEJSONParser(opts) -- 1113
	local inputFinished = false -- 1114
	local settled = false -- 1115
	local resolveFinished -- 1116
	local finished = __TS__New( -- 1117
		__TS__Promise, -- 1117
		function(____, resolve) -- 1117
			resolveFinished = resolve -- 1118
		end -- 1117
	) -- 1117
	local function settle() -- 1120
		if settled then -- 1120
			return -- 1121
		end -- 1121
		settled = true -- 1122
		if resolveFinished ~= nil then -- 1122
			resolveFinished() -- 1123
		end -- 1123
	end -- 1120
	Director.systemScheduler:schedule(function() -- 1125
		if settled then -- 1125
			return true -- 1126
		end -- 1126
		if isCancelled and isCancelled() then -- 1126
			parser.discard() -- 1128
			settle() -- 1129
			return true -- 1130
		end -- 1130
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME) -- 1132
		if inputFinished and not hasMoreCompleteLines then -- 1132
			parser["end"]() -- 1134
			settle() -- 1135
			return true -- 1136
		end -- 1136
		return false -- 1138
	end) -- 1125
	return { -- 1140
		append = parser.append, -- 1141
		finish = function() -- 1142
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1142
				inputFinished = true -- 1143
				__TS__Await(finished) -- 1144
			end) -- 1144
		end, -- 1142
		cancel = function() -- 1146
			parser.discard() -- 1147
			settle() -- 1148
		end -- 1146
	} -- 1146
end -- 1109
function ____exports.extractLLMTokenUsage(response) -- 1244
	local usage = response and response.usage -- 1245
	if not usage or type(usage) ~= "table" then -- 1245
		return nil -- 1246
	end -- 1246
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1247
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1250
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1250
		return nil -- 1253
	end -- 1253
	local ____temp_24 -- 1254
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1254
		____temp_24 = usage.prompt_cache_hit_tokens -- 1255
	else -- 1255
		local ____temp_23 -- 1256
		local ____opt_19 = usage.prompt_tokens_details -- 1256
		if type(____opt_19 and ____opt_19.cached_tokens) == "number" then -- 1256
			____temp_23 = usage.prompt_tokens_details.cached_tokens -- 1257
		else -- 1257
			local ____opt_21 = usage.input_tokens_details -- 1257
			____temp_23 = type(____opt_21 and ____opt_21.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1258
		end -- 1258
		____temp_24 = ____temp_23 -- 1256
	end -- 1256
	local cachedInputTokens = ____temp_24 -- 1254
	local ____inputTokens_27 = inputTokens -- 1262
	local ____outputTokens_28 = outputTokens -- 1263
	local ____temp_29 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1264
	local ____temp_30 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1265
	local ____temp_31 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1266
	local ____opt_25 = usage.completion_tokens_details -- 1266
	return { -- 1261
		inputTokens = ____inputTokens_27, -- 1262
		outputTokens = ____outputTokens_28, -- 1263
		totalTokens = ____temp_29, -- 1264
		cachedInputTokens = ____temp_30, -- 1265
		cacheMissInputTokens = ____temp_31, -- 1266
		reasoningOutputTokens = type(____opt_25 and ____opt_25.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1269
	} -- 1269
end -- 1244
function ____exports.validateAgentLLMConfig(config) -- 1313
	local ____opt_32 = config.customOptions -- 1313
	local visionModel = ____opt_32 and ____opt_32.visionModel -- 1314
	if visionModel ~= nil and visionModel ~= json.null and type(visionModel) ~= "string" then -- 1314
		return {success = false, message = "视觉模型名称 visionModel 必须是字符串；留空使用默认行为。"} -- 1316
	end -- 1316
	local ____opt_34 = config.customOptions -- 1316
	local auxiliaryOptions = ____opt_34 and ____opt_34.auxiliaryOptions -- 1318
	if auxiliaryOptions == nil then -- 1318
		return {success = true} -- 1319
	end -- 1319
	local emptyOptions = type(auxiliaryOptions) == "table" and auxiliaryOptions ~= nil and auxiliaryOptions ~= json.null and #__TS__ObjectKeys(auxiliaryOptions) == 0 -- 1320
	if isPlainRecord(auxiliaryOptions) or emptyOptions then -- 1320
		return {success = true} -- 1326
	end -- 1326
	return {success = false, message = "LLM 配置的 auxiliaryOptions 如有填写必须是对象（可以为空），请检查 LLM 配置"} -- 1328
end -- 1313
local function normalizeContextWindow(value) -- 1334
	if type(value) == "number" and value > 0 then -- 1334
		return math.floor(value) -- 1336
	end -- 1336
	return 64000 -- 1338
end -- 1334
local function normalizeLLMTemperature(value) -- 1341
	if type(value) == "number" then -- 1341
		return math.max( -- 1343
			0, -- 1343
			math.min(2, value) -- 1343
		) -- 1343
	end -- 1343
	return 0.1 -- 1345
end -- 1341
local function normalizeLLMMaxTokens(value) -- 1348
	if type(value) == "number" then -- 1348
		return math.max( -- 1350
			1, -- 1350
			math.floor(value) -- 1350
		) -- 1350
	end -- 1350
	return AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1352
end -- 1348
local function normalizeLLMCustomOptions(value) -- 1361
	if type(value) ~= "string" then -- 1361
		return nil -- 1362
	end -- 1362
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1363
	if text == "" then -- 1363
		return nil -- 1364
	end -- 1364
	local decoded = ____exports.safeJsonDecode(text) -- 1365
	return isPlainRecord(decoded) and decoded or nil -- 1366
end -- 1361
function ____exports.getLLMConfigRecords() -- 1391
	upgradeLLMConfig() -- 1392
	local rows = DB:query("select * from LLMConfig", true) -- 1393
	local records = {} -- 1394
	if rows and #rows > 1 then -- 1394
		do -- 1394
			local i = 1 -- 1396
			while i < #rows do -- 1396
				local record = {} -- 1397
				do -- 1397
					local c = 0 -- 1398
					while c < #rows[i + 1] do -- 1398
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1399
						c = c + 1 -- 1398
					end -- 1398
				end -- 1398
				records[#records + 1] = record -- 1401
				i = i + 1 -- 1396
			end -- 1396
		end -- 1396
	end -- 1396
	return records -- 1404
end -- 1391
function ____exports.getLLMConfigSummaries() -- 1414
	return __TS__ArrayFlatMap( -- 1415
		____exports.getLLMConfigRecords(), -- 1415
		function(____, record) -- 1415
			local id = record.id -- 1416
			local name = record.name -- 1417
			local model = record.model -- 1418
			if type(id) ~= "number" or type(name) ~= "string" or type(model) ~= "string" then -- 1418
				return {} -- 1419
			end -- 1419
			return {{id = id, name = name, model = model, active = record.active ~= 0}} -- 1420
		end -- 1415
	) -- 1415
end -- 1414
local function parseLLMConfig(config) -- 1424
	if not config then -- 1424
		return {success = false, message = "LLM config not found"} -- 1426
	end -- 1426
	local ____config_36 = config -- 1428
	local id = ____config_36.id -- 1428
	local url = ____config_36.url -- 1428
	local model = ____config_36.model -- 1428
	local api_key = ____config_36.api_key -- 1428
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1428
		return {success = false, message = "got invalid LLM config"} -- 1430
	end -- 1430
	return { -- 1432
		success = true, -- 1433
		id = id, -- 1434
		config = { -- 1435
			url = url, -- 1436
			model = model, -- 1437
			apiKey = api_key, -- 1438
			contextWindow = normalizeContextWindow(config.context_window), -- 1439
			temperature = normalizeLLMTemperature(config.temperature), -- 1440
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1441
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1442
			customOptions = normalizeLLMCustomOptions(config.custom_options) -- 1443
		} -- 1443
	} -- 1443
end -- 1424
function ____exports.getSavedLLMConfigs() -- 1448
	local records = ____exports.getLLMConfigRecords() -- 1449
	__TS__ArraySort( -- 1451
		records, -- 1451
		function(____, a, b) -- 1451
			local activeOrder = __TS__Number(b.active ~= 0) - __TS__Number(a.active ~= 0) -- 1452
			return activeOrder ~= 0 and activeOrder or __TS__Number(a.id) - __TS__Number(b.id) -- 1453
		end -- 1451
	) -- 1451
	return __TS__ArrayFlatMap( -- 1455
		records, -- 1455
		function(____, record) -- 1455
			local result = parseLLMConfig(record) -- 1456
			return result.success and ({result.config}) or ({}) -- 1457
		end -- 1455
	) -- 1455
end -- 1448
function ____exports.getLLMConfig(configId) -- 1461
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1462
	if normalizedId == nil or normalizedId <= 0 then -- 1462
		return {success = false, message = "LLM config is not selected"} -- 1464
	end -- 1464
	return parseLLMConfig(__TS__ArrayFind( -- 1466
		____exports.getLLMConfigRecords(), -- 1466
		function(____, record) return record.id == normalizedId end -- 1466
	)) -- 1466
end -- 1461
function ____exports.getActiveLLMConfig() -- 1469
	local records = ____exports.getLLMConfigRecords() -- 1470
	local config = __TS__ArrayFind( -- 1471
		records, -- 1471
		function(____, r) return r.active ~= 0 end -- 1471
	) -- 1471
	if not config then -- 1471
		return {success = false, message = "no active LLM config"} -- 1473
	end -- 1473
	return parseLLMConfig(config) -- 1475
end -- 1469
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1478
	local callEvent -- 1484
	if event.id ~= nil then -- 1484
		local id = event.id -- 1486
		callEvent = { -- 1487
			id = nil, -- 1488
			onData = function(data) -- 1489
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1490
				return event.stopToken.stopped -- 1491
			end, -- 1489
			onCancel = function(reason) -- 1493
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1494
			end, -- 1493
			onDone = function() -- 1496
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1497
			end -- 1496
		} -- 1496
	else -- 1496
		callEvent = event -- 1501
	end -- 1501
	local ____callEvent_37 = callEvent -- 1503
	local onData = ____callEvent_37.onData -- 1503
	local onDone = ____callEvent_37.onDone -- 1503
	local ____callEvent_38 = callEvent -- 1504
	local onCancel = ____callEvent_38.onCancel -- 1504
	local config = llmConfig or (function() -- 1505
		local configRes = ____exports.getActiveLLMConfig() -- 1506
		if not configRes.success then -- 1506
			if onCancel then -- 1506
				onCancel(configRes.message) -- 1508
			end -- 1508
			return nil -- 1509
		end -- 1509
		return configRes.config -- 1511
	end)() -- 1505
	if not config then -- 1505
		return {success = false, message = "no active LLM config"} -- 1514
	end -- 1514
	local url = config.url -- 1514
	local model = config.model -- 1514
	local apiKey = config.apiKey -- 1514
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1517
	if fitted.fittedTokens > fitted.budgetTokens then -- 1517
		return {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."} -- 1519
	end -- 1519
	if fitted.trimmed then -- 1519
		____exports.Log( -- 1522
			"Warn", -- 1522
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1522
		) -- 1522
	end -- 1522
	local stopLLM = false -- 1524
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1525
	local parser = createScheduledSSEJSONParser( -- 1528
		{onJSON = function(obj) -- 1528
			local result = onData(obj) -- 1530
			if result then -- 1530
				stopLLM = true -- 1532
				streamStopToken.stopped = true -- 1533
				streamStopToken.reason = "LLM Stopped" -- 1534
			end -- 1534
		end}, -- 1529
		function() return streamStopToken.stopped end -- 1537
	); -- 1537
	(function() -- 1538
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1538
			local ____try = __TS__AsyncAwaiter(function() -- 1538
				local result = __TS__Await(postLLM( -- 1540
					fitted.messages, -- 1540
					url, -- 1540
					apiKey, -- 1540
					model, -- 1540
					options, -- 1540
					true, -- 1540
					config.customOptions, -- 1540
					function(data) -- 1540
						if stopLLM then -- 1540
							if onCancel then -- 1540
								onCancel("LLM Stopped") -- 1543
								onCancel = nil -- 1544
							end -- 1544
							return true -- 1546
						end -- 1546
						parser.append(data) -- 1548
						return false -- 1549
					end, -- 1540
					streamStopToken, -- 1550
					config.studioGateway -- 1550
				)) -- 1550
				__TS__Await(parser.finish()) -- 1551
				if onDone then -- 1551
					onDone(result) -- 1553
				end -- 1553
			end) -- 1553
			____try = ____try.catch( -- 1553
				____try, -- 1553
				function(____, e) -- 1553
					return __TS__AsyncAwaiter(function() -- 1553
						parser.cancel() -- 1556
						stopLLM = true -- 1557
						if onCancel then -- 1557
							onCancel(tostring(e)) -- 1559
							onCancel = nil -- 1560
						end -- 1560
					end) -- 1560
				end -- 1560
			) -- 1560
			__TS__Await(____try) -- 1539
		end) -- 1539
	end)() -- 1538
	return {success = true} -- 1564
end -- 1478
local function mergeStreamToolCall(target, delta) -- 1567
	if type(delta.id) == "string" and delta.id ~= "" then -- 1567
		target.id = delta.id -- 1569
	end -- 1569
	if type(delta.type) == "string" and delta.type ~= "" then -- 1569
		target.type = delta.type -- 1572
	end -- 1572
	if delta["function"] then -- 1572
		if target["function"] == nil then -- 1572
			target["function"] = {} -- 1575
		end -- 1575
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1575
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1577
		end -- 1577
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1577
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1580
		end -- 1580
	end -- 1580
end -- 1567
local function isToolCallComplete(tc) -- 1585
	if type(tc.id) ~= "string" or tc.id == "" then -- 1585
		return false -- 1586
	end -- 1586
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1586
		return false -- 1587
	end -- 1587
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1587
		return false -- 1588
	end -- 1588
	local args = tc["function"].arguments -- 1589
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1589
		return false -- 1590
	end -- 1590
	local decoded = ____exports.safeJsonDecode(args) -- 1591
	return decoded ~= nil -- 1592
end -- 1585
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1595
	local delta = choice.delta or ({}) -- 1596
	local fullMessage = choice.message or ({}) -- 1597
	local message = acc.message -- 1598
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1599
	if type(role) == "string" and role ~= "" then -- 1599
		message.role = role -- 1603
	end -- 1603
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1605
	if type(content) == "string" and content ~= "" then -- 1605
		message.content = (message.content or "") .. content -- 1609
	end -- 1609
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1611
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1611
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1615
	end -- 1615
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1617
	if #toolCalls > 0 then -- 1617
		if message.tool_calls == nil then -- 1617
			message.tool_calls = {} -- 1621
		end -- 1621
		do -- 1621
			local i = 0 -- 1622
			while i < #toolCalls do -- 1622
				local item = toolCalls[i + 1] -- 1623
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1624
				local ____message_tool_calls_39, ____temp_40 = message.tool_calls, index + 1 -- 1624
				if ____message_tool_calls_39[____temp_40] == nil then -- 1624
					____message_tool_calls_39[____temp_40] = {} -- 1627
				end -- 1627
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1628
				if onToolCallReady and emittedToolCallIds then -- 1628
					local tc = message.tool_calls[index + 1] -- 1630
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1630
						emittedToolCallIds[tc.id] = true -- 1632
						onToolCallReady(tc) -- 1633
					end -- 1633
				end -- 1633
				i = i + 1 -- 1622
			end -- 1622
		end -- 1622
	end -- 1622
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1622
		acc.finish_reason = choice.finish_reason -- 1639
	end -- 1639
end -- 1595
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1643
	local indexes = __TS__ArraySort( -- 1652
		__TS__ArrayFilter( -- 1652
			__TS__ArrayMap( -- 1652
				__TS__ObjectKeys(states), -- 1652
				function(____, key) return __TS__Number(key) end -- 1653
			), -- 1653
			function(____, index) return __TS__NumberIsFinite(index) end -- 1654
		), -- 1654
		function(____, a, b) return a - b end -- 1655
	) -- 1655
	return { -- 1656
		id = id, -- 1657
		created = created, -- 1658
		object = object, -- 1659
		model = model, -- 1660
		choices = __TS__ArrayMap( -- 1661
			indexes, -- 1661
			function(____, index) -- 1661
				local state = states[index] -- 1662
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1663
			end -- 1661
		), -- 1661
		usage = usage, -- 1674
		error = providerError -- 1675
	} -- 1675
end -- 1643
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1679
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1679
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1690
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1691
		local resolvedConfig = config or (function() -- 1694
			local configRes = ____exports.getActiveLLMConfig() -- 1695
			if not configRes.success then -- 1695
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1697
				return nil -- 1698
			end -- 1698
			return configRes.config -- 1700
		end)() -- 1694
		if not resolvedConfig then -- 1694
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1694
		end -- 1694
		local url = resolvedConfig.url -- 1694
		local model = resolvedConfig.model -- 1694
		local apiKey = resolvedConfig.apiKey -- 1694
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1706
		if fitted.fittedTokens > fitted.budgetTokens then -- 1706
			return ____awaiter_resolve(nil, {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."}) -- 1706
		end -- 1706
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1710
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1711
		local ____model_45 = model -- 1714
		local ____url_46 = url -- 1714
		local ____temp_47 = #messages -- 1714
		local ____tostring_42 = tostring -- 1714
		local ____options_max_tokens_41 = options.max_tokens -- 1714
		if ____options_max_tokens_41 == nil then -- 1714
			____options_max_tokens_41 = "unset" -- 1714
		end -- 1714
		local ____tostring_42_result_48 = ____tostring_42(____options_max_tokens_41) -- 1714
		local ____tostring_44 = tostring -- 1714
		local ____options_temperature_43 = options.temperature -- 1714
		if ____options_temperature_43 == nil then -- 1714
			____options_temperature_43 = "unset" -- 1714
		end -- 1714
		____exports.Log( -- 1714
			"Info", -- 1714
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_45) .. " url=") .. ____url_46) .. " messages=") .. tostring(____temp_47)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_42_result_48) .. " temperature=") .. ____tostring_44(____options_temperature_43)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1714
		) -- 1714
		if stopToken and stopToken.stopped then -- 1714
			local reason = stopToken.reason or "request cancelled" -- 1716
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1717
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1717
		end -- 1717
		local ____hasReturned, ____returnValue -- 1717
		local ____try = __TS__AsyncAwaiter(function() -- 1717
			local states = {} -- 1721
			local emittedToolCallIds = {} -- 1722
			local responseId = nil -- 1723
			local responseCreated = nil -- 1724
			local responseObject = nil -- 1725
			local providerError -- 1726
			local responseUsage -- 1727
			local httpChunkCount = 0 -- 1728
			local rawStreamBytes = 0 -- 1729
			local rawStreamPreview = "" -- 1730
			local sseJSONChunkCount = 0 -- 1731
			local choiceJSONChunkCount = 0 -- 1732
			local emptyChoicesChunkCount = 0 -- 1733
			local missingChoicesChunkCount = 0 -- 1734
			local parseErrorCount = 0 -- 1735
			local doneChunkSeen = false -- 1736
			local lastJSONPreview = "" -- 1737
			local parser = createScheduledSSEJSONParser( -- 1738
				{ -- 1738
					onJSON = function(obj, raw) -- 1739
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1740
						lastJSONPreview = previewText(raw, 500) -- 1741
						if not obj or type(obj) ~= "table" then -- 1741
							return -- 1743
						end -- 1743
						local chunk = obj -- 1745
						if chunk.error then -- 1745
							providerError = chunk.error -- 1747
							____exports.Log( -- 1748
								"Warn", -- 1748
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1748
							) -- 1748
							return -- 1749
						end -- 1749
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1751
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1752
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1753
						if chunk.usage and type(chunk.usage) == "table" then -- 1753
							responseUsage = chunk.usage -- 1755
						end -- 1755
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1757
						if not __TS__ArrayIsArray(chunk.choices) then -- 1757
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1759
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1759
								____exports.Log( -- 1761
									"Warn", -- 1761
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1761
								) -- 1761
							end -- 1761
						elseif #choices == 0 then -- 1761
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1764
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1764
								____exports.Log( -- 1766
									"Warn", -- 1766
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1766
								) -- 1766
							end -- 1766
						else -- 1766
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1769
						end -- 1769
						do -- 1769
							local i = 0 -- 1771
							while i < #choices do -- 1771
								local choice = choices[i + 1] -- 1772
								local index = type(choice.index) == "number" and choice.index or i -- 1773
								if states[index] == nil then -- 1773
									states[index] = {index = index, message = {role = "assistant"}} -- 1774
								end -- 1774
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1778
								i = i + 1 -- 1771
							end -- 1771
						end -- 1771
						if onChunk ~= nil then -- 1771
							onChunk( -- 1780
								buildStreamResponse( -- 1781
									states, -- 1781
									model, -- 1781
									responseId, -- 1781
									responseCreated, -- 1781
									responseObject, -- 1781
									providerError, -- 1781
									responseUsage -- 1781
								), -- 1781
								{ -- 1782
									id = chunk.id or "", -- 1783
									created = chunk.created or 0, -- 1784
									object = chunk.object or "", -- 1785
									model = chunk.model or model, -- 1786
									choices = choices -- 1787
								} -- 1787
							) -- 1787
						end -- 1787
					end, -- 1739
					onDone = function() -- 1791
						doneChunkSeen = true -- 1792
					end, -- 1791
					onError = function(err, context) -- 1794
						parseErrorCount = parseErrorCount + 1 -- 1795
						____exports.Log( -- 1796
							"Warn", -- 1796
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1796
						) -- 1796
					end -- 1794
				}, -- 1794
				function() return (stopToken and stopToken.stopped) == true end -- 1798
			) -- 1798
			local ____try = __TS__AsyncAwaiter(function() -- 1798
				__TS__Await(postLLM( -- 1800
					fitted.messages, -- 1800
					url, -- 1800
					apiKey, -- 1800
					model, -- 1800
					options, -- 1800
					true, -- 1800
					resolvedConfig.customOptions, -- 1800
					function(data) -- 1800
						if stopToken and stopToken.stopped then -- 1800
							return true -- 1801
						end -- 1801
						httpChunkCount = httpChunkCount + 1 -- 1802
						rawStreamBytes = rawStreamBytes + #data -- 1803
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1803
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1805
						end -- 1805
						parser.append(data) -- 1807
						return false -- 1808
					end, -- 1800
					stopToken, -- 1809
					resolvedConfig.studioGateway -- 1809
				)) -- 1809
				__TS__Await(parser.finish()) -- 1810
			end) -- 1810
			____try = ____try.catch( -- 1810
				____try, -- 1810
				function(____, e) -- 1810
					return __TS__AsyncAwaiter(function() -- 1810
						parser.cancel() -- 1812
						error(e, 0) -- 1813
					end) -- 1813
				end -- 1813
			) -- 1813
			__TS__Await(____try) -- 1799
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1799
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1816
				if rawResponse and type(rawResponse) == "table" then -- 1816
					local rawResponseObj = rawResponse -- 1818
					if rawResponseObj.error then -- 1818
						providerError = rawResponseObj.error -- 1820
						lastJSONPreview = previewText( -- 1821
							normalizeLLMJSONResponse(rawStreamPreview), -- 1821
							500 -- 1821
						) -- 1821
						____exports.Log( -- 1822
							"Warn", -- 1822
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1822
						) -- 1822
					end -- 1822
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1822
						responseUsage = rawResponseObj.usage -- 1825
					end -- 1825
				end -- 1825
			end -- 1825
			local response = buildStreamResponse( -- 1829
				states, -- 1829
				model, -- 1829
				responseId, -- 1829
				responseCreated, -- 1829
				responseObject, -- 1829
				providerError, -- 1829
				responseUsage -- 1829
			) -- 1829
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1830
			local choiceCount = response.choices and #response.choices or 0 -- 1831
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1832
			____exports.Log( -- 1833
				"Info", -- 1833
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1833
			) -- 1833
			if not doneChunkSeen then -- 1833
				local rawPreview = previewText( -- 1835
					____exports.sanitizeUTF8(rawStreamPreview), -- 1835
					1200 -- 1835
				) -- 1835
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1836
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1837
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1838
				____hasReturned = true -- 1839
				____returnValue = { -- 1839
					success = false, -- 1840
					message = message, -- 1841
					raw = rawStreamPreview, -- 1842
					response = response, -- 1843
					tokenUsage = tokenUsage -- 1844
				} -- 1844
				return -- 1839
			end -- 1839
			if not response.choices or #response.choices == 0 then -- 1839
				local providerMessage = providerError and providerError.message or "" -- 1848
				local providerType = providerError and providerError.type or "" -- 1849
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1850
				local details = table.concat( -- 1853
					__TS__ArrayFilter( -- 1853
						{providerType, providerCode}, -- 1853
						function(____, part) return part ~= "" end -- 1853
					), -- 1853
					"/" -- 1853
				) -- 1853
				local rawPreview = previewText( -- 1854
					____exports.sanitizeUTF8(rawStreamPreview), -- 1854
					1200 -- 1854
				) -- 1854
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1855
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1856
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1859
				____hasReturned = true -- 1860
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1860
				return -- 1860
			end -- 1860
			____hasReturned = true -- 1867
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1867
			return -- 1867
		end) -- 1867
		____try = ____try.catch( -- 1867
			____try, -- 1867
			function(____, e) -- 1867
				return __TS__AsyncAwaiter(function() -- 1867
					if stopToken and stopToken.stopped then -- 1867
						local reason = stopToken.reason or "request cancelled" -- 1874
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1875
						____hasReturned = true -- 1876
						____returnValue = {success = false, message = reason} -- 1876
						return -- 1876
					end -- 1876
					____exports.Log( -- 1878
						"Error", -- 1878
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1878
					) -- 1878
					____hasReturned = true -- 1879
					____returnValue = { -- 1879
						success = false, -- 1879
						message = tostring(e) -- 1879
					} -- 1879
					return -- 1879
				end) -- 1879
			end -- 1879
		) -- 1879
		__TS__Await(____try) -- 1720
		if ____hasReturned then -- 1720
			return ____awaiter_resolve(nil, ____returnValue) -- 1720
		end -- 1720
	end) -- 1720
end -- 1679
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1883
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1883
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1889
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1890
		local resolvedConfig = config or (function() -- 1893
			local configRes = ____exports.getActiveLLMConfig() -- 1894
			if not configRes.success then -- 1894
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1896
				return nil -- 1897
			end -- 1897
			return configRes.config -- 1899
		end)() -- 1893
		if not resolvedConfig then -- 1893
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1893
		end -- 1893
		local url = resolvedConfig.url -- 1893
		local model = resolvedConfig.model -- 1893
		local apiKey = resolvedConfig.apiKey -- 1893
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1905
		if fitted.fittedTokens > fitted.budgetTokens then -- 1905
			return ____awaiter_resolve(nil, {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."}) -- 1905
		end -- 1905
		____exports.Log( -- 1909
			"Info", -- 1909
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1909
		) -- 1909
		if stopToken and stopToken.stopped then -- 1909
			local reason = stopToken.reason or "request cancelled" -- 1911
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1912
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1912
		end -- 1912
		local ____hasReturned, ____returnValue -- 1912
		local ____try = __TS__AsyncAwaiter(function() -- 1912
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1916
				fitted.messages, -- 1916
				url, -- 1916
				apiKey, -- 1916
				model, -- 1916
				options, -- 1916
				false, -- 1916
				resolvedConfig.customOptions, -- 1916
				nil, -- 1916
				stopToken, -- 1916
				resolvedConfig.studioGateway -- 1916
			))) -- 1916
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1917
			____exports.Log( -- 1918
				"Info", -- 1918
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1918
			) -- 1918
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1919
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1919
				local rawPreview = previewText(raw) -- 1921
				____exports.Log( -- 1922
					"Error", -- 1922
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1922
				) -- 1922
				____hasReturned = true -- 1923
				____returnValue = { -- 1923
					success = false, -- 1924
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1925
					raw = raw -- 1926
				} -- 1926
				return -- 1923
			end -- 1923
			local responseObj = response -- 1929
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1930
			____exports.Log( -- 1931
				"Info", -- 1931
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1931
			) -- 1931
			if not responseObj.choices or #responseObj.choices == 0 then -- 1931
				local providerError = responseObj.error -- 1933
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1934
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1937
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1940
				local details = table.concat( -- 1943
					__TS__ArrayFilter( -- 1943
						{providerType, providerCode}, -- 1943
						function(____, part) return part ~= "" end -- 1943
					), -- 1943
					"/" -- 1943
				) -- 1943
				local rawPreview = previewText(raw, 400) -- 1944
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1945
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1948
				____hasReturned = true -- 1949
				____returnValue = {success = false, message = message, raw = raw} -- 1949
				return -- 1949
			end -- 1949
			____hasReturned = true -- 1955
			____returnValue = {success = true, response = responseObj} -- 1955
			return -- 1955
		end) -- 1955
		____try = ____try.catch( -- 1955
			____try, -- 1955
			function(____, e) -- 1955
				return __TS__AsyncAwaiter(function() -- 1955
					if stopToken and stopToken.stopped then -- 1955
						local reason = stopToken.reason or "request cancelled" -- 1961
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1962
						____hasReturned = true -- 1963
						____returnValue = {success = false, message = reason} -- 1963
						return -- 1963
					end -- 1963
					____exports.Log( -- 1965
						"Error", -- 1965
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1965
					) -- 1965
					____hasReturned = true -- 1966
					____returnValue = { -- 1966
						success = false, -- 1966
						message = tostring(e) -- 1966
					} -- 1966
					return -- 1966
				end) -- 1966
			end -- 1966
		) -- 1966
		__TS__Await(____try) -- 1915
		if ____hasReturned then -- 1915
			return ____awaiter_resolve(nil, ____returnValue) -- 1915
		end -- 1915
	end) -- 1915
end -- 1883
return ____exports -- 1883