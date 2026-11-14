-- [ts]: Utils.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
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
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
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
function ____exports.sanitizeUTF8(text) -- 418
	if text == "" then -- 418
		return "" -- 419
	end -- 419
	local remaining = text -- 420
	local output = "" -- 421
	while remaining ~= "" do -- 421
		local len, invalidPos = utf8.len(remaining) -- 423
		if len ~= nil then -- 423
			output = output .. remaining -- 425
			break -- 426
		end -- 426
		local badPos = type(invalidPos) == "number" and invalidPos or 1 -- 428
		if badPos > 1 then -- 428
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1) -- 430
		end -- 430
		remaining = __TS__StringSubstring(remaining, badPos) -- 432
	end -- 432
	return output -- 434
end -- 418
function sanitizeJSONValue(value) -- 437
	if type(value) == "string" then -- 437
		return ____exports.sanitizeUTF8(value) -- 438
	end -- 438
	if __TS__ArrayIsArray(value) then -- 438
		return __TS__ArrayMap( -- 440
			value, -- 440
			function(____, item) return sanitizeJSONValue(item) end -- 440
		) -- 440
	end -- 440
	if value and type(value) == "table" then -- 440
		local result = {} -- 443
		for key in pairs(value) do -- 444
			result[key] = sanitizeJSONValue(value[key]) -- 445
		end -- 445
		return result -- 447
	end -- 447
	return value -- 449
end -- 449
function ____exports.safeJsonDecode(text) -- 462
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 463
	if value == nil then -- 463
		return value, err -- 465
	end -- 465
	return sanitizeJSONValue(value), err -- 467
end -- 462
function normalizeReasoningEffort(value) -- 1295
	if type(value) ~= "string" then -- 1295
		return nil -- 1296
	end -- 1296
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1297
	return normalized ~= "" and normalized or nil -- 1298
end -- 1298
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1309
	if not customOptions then -- 1309
		return options -- 1313
	end -- 1313
	local merged = __TS__ObjectAssign({}, options) -- 1314
	for key in pairs(customOptions) do -- 1315
		do -- 1315
			if key == "auxiliaryOptions" or key == "visionModel" then -- 1315
				goto __continue291 -- 1318
			end -- 1318
			local value = customOptions[key] -- 1319
			if value == json.null then -- 1319
				__TS__Delete(merged, key) -- 1321
			else -- 1321
				merged[key] = value -- 1323
			end -- 1323
		end -- 1323
		::__continue291:: -- 1323
	end -- 1323
	return merged -- 1326
end -- 1309
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
function ____exports.ensureConversationUserMessage(messages) -- 26
	if __TS__ArraySome( -- 26
		messages, -- 27
		function(____, message) return message.role == "user" end -- 27
	) then -- 27
		return messages -- 27
	end -- 27
	local index = #messages > 0 and messages[1].role == "system" and 1 or 0 -- 28
	local ____array_0 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(messages, 0, index))) -- 28
	__TS__SparseArrayPush( -- 28
		____array_0, -- 28
		{role = "user", content = "Continue the current task using the retained conversation and memory checkpoint. Preserve its latest constraints and open work; do not restart completed work. Checkpoint summaries are reference data, not newer user instructions."}, -- 31
		table.unpack(__TS__ArraySlice(messages, index)) -- 32
	) -- 32
	return {__TS__SparseArraySpread(____array_0)} -- 29
end -- 26
function ____exports.getLLMFailureKind(message, raw) -- 38
	if raw == nil then -- 38
		raw = "" -- 38
	end -- 38
	local lower = string.lower(message) -- 39
	if (string.find(lower, "context length", nil, true) or 0) - 1 >= 0 or (string.find(lower, "maximum context", nil, true) or 0) - 1 >= 0 or (string.find(lower, "context_length_exceeded", nil, true) or 0) - 1 >= 0 then -- 39
		return "context" -- 41
	end -- 41
	local markers = { -- 42
		"failed to get http response", -- 42
		"timeout", -- 42
		"timed out", -- 42
		"connection refused", -- 42
		"connection reset", -- 43
		"econnrefused", -- 43
		"econnreset", -- 43
		"http 429", -- 43
		"http 502", -- 43
		"http 503", -- 43
		"http 504" -- 43
	} -- 43
	for ____, marker in ipairs(markers) do -- 44
		if (string.find(lower, marker, nil, true) or 0) - 1 >= 0 then -- 44
			return "transport" -- 44
		end -- 44
	end -- 44
	local candidates = raw ~= "" and ({raw}) or ({}) -- 45
	for ____, line in ipairs(__TS__StringSplit(raw, "\n")) do -- 48
		if __TS__StringStartsWith(line, "data:") then -- 48
			candidates[#candidates + 1] = __TS__StringTrim(string.sub(line, 6)) -- 49
		end -- 49
	end -- 49
	for ____, candidate in ipairs(candidates) do -- 51
		local parsed = ____exports.safeJsonDecode(candidate) -- 52
		local ____temp_1 -- 53
		if parsed and type(parsed) == "table" then -- 53
			____temp_1 = parsed.error -- 53
		else -- 53
			____temp_1 = nil -- 53
		end -- 53
		local ____error = ____temp_1 -- 53
		if ____error and type(____error) == "table" then -- 53
			if ____error.code == "context_length_exceeded" then -- 53
				return "context" -- 55
			end -- 55
			local ____tostring_4 = tostring -- 56
			local ____error_code_2 = ____error.code -- 56
			if ____error_code_2 == nil then -- 56
				____error_code_2 = ____error.type -- 56
			end -- 56
			local ____error_code_2_3 = ____error_code_2 -- 56
			if ____error_code_2_3 == nil then -- 56
				____error_code_2_3 = "" -- 56
			end -- 56
			local code = string.lower(____tostring_4(____error_code_2_3)) -- 56
			if code == "429" or code == "502" or code == "503" or code == "504" or code == "rate_limit_exceeded" or code == "server_error" or code == "overloaded_error" then -- 56
				return "transport" -- 58
			end -- 58
		end -- 58
	end -- 58
	return "other" -- 61
end -- 38
function ____exports.waitForLLMRetry(attempt, stopToken) -- 64
	local delay = math.min( -- 65
		8, -- 65
		math.max(1, attempt) * 2 -- 65
	) -- 65
	return __TS__New( -- 66
		__TS__Promise, -- 66
		function(____, resolve) -- 66
			local elapsed = 0 -- 67
			Director.systemScheduler:schedule(function(deltaTime) -- 68
				elapsed = elapsed + deltaTime -- 69
				if stopToken and stopToken.stopped or elapsed >= delay then -- 69
					resolve(nil) -- 71
					return true -- 72
				end -- 72
				return false -- 74
			end) -- 68
		end -- 66
	) -- 66
end -- 64
local LLM_STREAM_RAW_DEBUG_MAX = 12000 -- 79
local LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT = 5 -- 80
____exports.Log = function(____type, msg) -- 82
	if LOG_LEVEL < 1 then -- 82
		return -- 83
	elseif LOG_LEVEL < 2 and (____type == "Info" or ____type == "Warn") then -- 83
		return -- 84
	elseif LOG_LEVEL < 3 and ____type == "Info" then -- 84
		return -- 85
	end -- 85
	DoraLog(____type, msg) -- 86
end -- 82
local TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz" -- 113
local TOOL_CALL_ID_COUNTER = 0 -- 114
local STUDIO_MODEL_REQUEST_COUNTER = 0 -- 115
local function toBase36(value) -- 117
	if value <= 0 then -- 117
		return "0" -- 118
	end -- 118
	local remaining = math.floor(value) -- 119
	local out = "" -- 120
	while remaining > 0 do -- 120
		local digit = remaining % 36 -- 122
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out -- 123
		remaining = math.floor(remaining / 36) -- 124
	end -- 124
	return out -- 126
end -- 117
function ____exports.createLocalToolCallId() -- 129
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1 -- 130
	local timePart = toBase36(os.time()) -- 131
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER) -- 132
	return ("tc" .. timePart) .. counterPart -- 133
end -- 129
function ____exports.createStudioModelRequestId() -- 136
	STUDIO_MODEL_REQUEST_COUNTER = STUDIO_MODEL_REQUEST_COUNTER + 1 -- 137
	return ((("mr" .. toBase36(os.time())) .. toBase36(STUDIO_MODEL_REQUEST_COUNTER)) .. toBase36(math.floor(math.random() * 1000000000))) .. toBase36(math.floor(math.random() * 1000000000)) -- 140
end -- 136
local function normalizeCompletionText(value) -- 174
	if type(value) ~= "string" then -- 174
		return "" -- 175
	end -- 175
	return __TS__StringSlice( -- 176
		__TS__StringTrim(____exports.sanitizeUTF8(value)), -- 176
		0, -- 176
		AgentConfig.AGENT_LIMITS.completionTextMaxChars -- 176
	) -- 176
end -- 174
local function normalizeCompletionTextList(value, maxItems) -- 179
	if maxItems == nil then -- 179
		maxItems = AgentConfig.AGENT_LIMITS.completionListMaxItems -- 181
	end -- 181
	if not __TS__ArrayIsArray(value) then -- 181
		return {} -- 183
	end -- 183
	local items = {} -- 184
	do -- 184
		local i = 0 -- 185
		while i < #value and #items < maxItems do -- 185
			local item = normalizeCompletionText(value[i + 1]) -- 186
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 186
				items[#items + 1] = item -- 187
			end -- 187
			i = i + 1 -- 185
		end -- 185
	end -- 185
	return items -- 189
end -- 179
function ____exports.normalizeAgentCompletionReport(value) -- 192
	local row = value and not __TS__ArrayIsArray(value) and type(value) == "table" and value or ({}) -- 193
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 196
	local validation = {} -- 199
	if __TS__ArrayIsArray(row.validation) then -- 199
		do -- 199
			local i = 0 -- 201
			while i < #row.validation and #validation < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 201
				do -- 201
					local raw = row.validation[i + 1] -- 202
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 202
						goto __continue43 -- 203
					end -- 203
					local item = raw -- 204
					local kind = (item.kind == "runtime" or item.kind == "manual") and item.kind or (item.kind == "build" and "build" or nil) -- 205
					local result = (item.result == "passed" or item.result == "failed" or item.result == "not_run") and item.result or nil -- 206
					if kind == nil or result == nil then -- 206
						goto __continue43 -- 207
					end -- 207
					validation[#validation + 1] = { -- 208
						kind = kind, -- 209
						result = result, -- 210
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems) -- 211
					} -- 211
				end -- 211
				::__continue43:: -- 211
				i = i + 1 -- 201
			end -- 201
		end -- 201
	end -- 201
	local learningCandidates = {} -- 215
	if __TS__ArrayIsArray(row.learningCandidates) then -- 215
		do -- 215
			local i = 0 -- 217
			while i < #row.learningCandidates and #learningCandidates < AgentConfig.AGENT_LIMITS.completionListMaxItems do -- 217
				do -- 217
					local raw = row.learningCandidates[i + 1] -- 218
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 218
						goto __continue48 -- 219
					end -- 219
					local item = raw -- 220
					local claim = normalizeCompletionText(item.claim) -- 221
					if claim == "" then -- 221
						goto __continue48 -- 222
					end -- 222
					learningCandidates[#learningCandidates + 1] = { -- 223
						claim = claim, -- 224
						scope = (item.scope == "file" or item.scope == "engine") and item.scope or "project", -- 225
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems), -- 226
						confidence = item.confidence == "inferred" and "inferred" or "observed" -- 227
					} -- 227
				end -- 227
				::__continue48:: -- 227
				i = i + 1 -- 217
			end -- 217
		end -- 217
	end -- 217
	return { -- 231
		outcome = outcome, -- 232
		budgetExhausted = row.budgetExhausted == true, -- 233
		validation = validation, -- 234
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 235
		assumptions = normalizeCompletionTextList(row.assumptions), -- 236
		learningCandidates = learningCandidates -- 237
	} -- 237
end -- 192
function ____exports.replaceFirst(text, oldStr, newStr) -- 245
	if oldStr == "" then -- 245
		return text -- 246
	end -- 246
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 247
	if idx < 0 then -- 247
		return text -- 248
	end -- 248
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 249
end -- 245
local function getLeadingWhitespace(text) -- 252
	local i = 0 -- 253
	while i < #text do -- 253
		local ch = __TS__StringAccess(text, i) -- 255
		if ch ~= " " and ch ~= "\t" then -- 255
			break -- 256
		end -- 256
		i = i + 1 -- 257
	end -- 257
	return __TS__StringSubstring(text, 0, i) -- 259
end -- 252
local function getCommonIndentPrefix(lines) -- 262
	local common -- 263
	do -- 263
		local i = 0 -- 264
		while i < #lines do -- 264
			do -- 264
				local line = lines[i + 1] -- 265
				if __TS__StringTrim(line) == "" then -- 265
					goto __continue59 -- 266
				end -- 266
				local indent = getLeadingWhitespace(line) -- 267
				if common == nil then -- 267
					common = indent -- 269
					goto __continue59 -- 270
				end -- 270
				local j = 0 -- 272
				local maxLen = math.min(#common, #indent) -- 273
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 273
					j = j + 1 -- 275
				end -- 275
				common = __TS__StringSubstring(common, 0, j) -- 277
				if common == "" then -- 277
					break -- 278
				end -- 278
			end -- 278
			::__continue59:: -- 278
			i = i + 1 -- 264
		end -- 264
	end -- 264
	return common or "" -- 280
end -- 262
local function removeIndentPrefix(line, indent) -- 283
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 283
		return __TS__StringSubstring(line, #indent) -- 285
	end -- 285
	local lineIndent = getLeadingWhitespace(line) -- 287
	local j = 0 -- 288
	local maxLen = math.min(#lineIndent, #indent) -- 289
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 289
		j = j + 1 -- 291
	end -- 291
	return __TS__StringSubstring(line, j) -- 293
end -- 283
local function dedentLines(lines) -- 296
	local indent = getCommonIndentPrefix(lines) -- 297
	return { -- 298
		indent = indent, -- 299
		lines = __TS__ArrayMap( -- 300
			lines, -- 300
			function(____, line) return removeIndentPrefix(line, indent) end -- 300
		) -- 300
	} -- 300
end -- 296
local function findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 304
	local function foldWhitespace(text, withMap) -- 310
		local parts = {} -- 311
		local map = {} -- 312
		local i = 0 -- 313
		while i < #text do -- 313
			local ch = __TS__StringAccess(text, i) -- 315
			if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 315
				local start = i -- 317
				while i < #text do -- 317
					local next = __TS__StringAccess(text, i) -- 319
					if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 319
						break -- 320
					end -- 320
					i = i + 1 -- 321
				end -- 321
				parts[#parts + 1] = " " -- 323
				if withMap then -- 323
					map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 324
				end -- 324
			else -- 324
				parts[#parts + 1] = ch -- 326
				if withMap then -- 326
					map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 327
				end -- 327
				i = i + 1 -- 328
			end -- 328
		end -- 328
		return { -- 331
			text = table.concat(parts, ""), -- 331
			map = map -- 331
		} -- 331
	end -- 310
	local foldedContent = foldWhitespace(content, true) -- 333
	local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 334
	if foldedOld == "" then -- 334
		return {success = false, message = "old_str not found in file"} -- 336
	end -- 336
	local matches = {} -- 338
	local pos = 0 -- 339
	while true do -- 339
		local idx = (string.find( -- 341
			foldedContent.text, -- 341
			foldedOld, -- 341
			math.max(pos + 1, 1), -- 341
			true -- 341
		) or 0) - 1 -- 341
		if idx < 0 then -- 341
			break -- 342
		end -- 342
		local lastIdx = idx + #foldedOld - 1 -- 343
		local startMap = foldedContent.map[idx + 1] -- 344
		local endMap = foldedContent.map[lastIdx + 1] -- 345
		if startMap ~= nil and endMap ~= nil then -- 345
			matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 347
		end -- 347
		pos = idx + #foldedOld -- 349
	end -- 349
	if #matches == 0 then -- 349
		return {success = false, message = "old_str not found in file"} -- 352
	end -- 352
	if #matches > 1 then -- 352
		return { -- 355
			success = false, -- 356
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 357
		} -- 357
	end -- 357
	local match = matches[1] -- 360
	return { -- 361
		success = true, -- 362
		content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 363
	} -- 363
end -- 304
function ____exports.findIndentTolerantReplacement(content, oldStr, newStr) -- 367
	local contentLines = __TS__StringSplit(content, "\n") -- 372
	local oldLines = __TS__StringSplit(oldStr, "\n") -- 373
	if #oldLines == 0 then -- 373
		return {success = false, message = "old_str not found in file"} -- 375
	end -- 375
	local dedentedOld = dedentLines(oldLines) -- 377
	local dedentedOldText = table.concat(dedentedOld.lines, "\n") -- 378
	local dedentedNew = dedentLines(__TS__StringSplit(newStr, "\n")) -- 379
	local matches = {} -- 380
	do -- 380
		local start = 0 -- 381
		while start <= #contentLines - #oldLines do -- 381
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 382
			local dedentedCandidate = dedentLines(candidateLines) -- 383
			if table.concat(dedentedCandidate.lines, "\n") == dedentedOldText then -- 383
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 385
			end -- 385
			start = start + 1 -- 381
		end -- 381
	end -- 381
	if #matches == 0 then -- 381
		return findWhitespaceTolerantReplacement(content, oldStr, newStr) -- 393
	end -- 393
	if #matches > 1 then -- 393
		return { -- 396
			success = false, -- 397
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 398
		} -- 398
	end -- 398
	local match = matches[1] -- 401
	local rebuiltNewLines = __TS__ArrayMap( -- 402
		dedentedNew.lines, -- 402
		function(____, line) return line == "" and "" or match.indent .. line end -- 402
	) -- 402
	local ____array_7 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 402
	__TS__SparseArrayPush( -- 402
		____array_7, -- 402
		table.unpack(rebuiltNewLines) -- 405
	) -- 405
	__TS__SparseArrayPush( -- 405
		____array_7, -- 405
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 406
	) -- 406
	local nextLines = {__TS__SparseArraySpread(____array_7)} -- 403
	return { -- 408
		success = true, -- 408
		content = table.concat(nextLines, "\n") -- 408
	} -- 408
end -- 367
local function previewText(text, maxLen) -- 411
	if maxLen == nil then -- 411
		maxLen = 200 -- 411
	end -- 411
	if text == "" then -- 411
		return "" -- 412
	end -- 412
	local compact = __TS__StringReplace( -- 413
		__TS__StringReplace(text, "\r", "\\r"), -- 413
		"\n", -- 413
		"\\n" -- 413
	) -- 413
	if #compact <= maxLen then -- 413
		return compact -- 414
	end -- 414
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 415
end -- 411
function ____exports.safeJsonEncode(value, format, emptyAsArray, numAsStr, maxDepth) -- 452
	if format == nil then -- 452
		format = false -- 452
	end -- 452
	if emptyAsArray == nil then -- 452
		emptyAsArray = true -- 452
	end -- 452
	if numAsStr == nil then -- 452
		numAsStr = false -- 452
	end -- 452
	if maxDepth == nil then -- 452
		maxDepth = 128 -- 452
	end -- 452
	return json.encode( -- 453
		sanitizeJSONValue(value), -- 454
		format, -- 455
		emptyAsArray, -- 456
		numAsStr, -- 457
		maxDepth -- 458
	) -- 458
end -- 452
local function isPlainRecord(value) -- 470
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 471
end -- 470
local function normalizeLLMJSONResponse(text) -- 474
	return __TS__StringTrim(text) -- 475
end -- 474
local function utf8TakeHead(text, maxChars) -- 478
	if maxChars <= 0 or text == "" then -- 478
		return "" -- 479
	end -- 479
	local nextPos = utf8.offset(text, maxChars + 1) -- 480
	if nextPos == nil then -- 480
		return text -- 481
	end -- 481
	return string.sub(text, 1, nextPos - 1) -- 482
end -- 478
local function utf8TakeTail(text, maxChars) -- 485
	if maxChars <= 0 or text == "" then -- 485
		return "" -- 486
	end -- 486
	local charLen = utf8.len(text) -- 487
	if charLen == nil or charLen <= maxChars then -- 487
		return text -- 488
	end -- 488
	local startChar = math.max(1, charLen - maxChars + 1) -- 489
	local startPos = utf8.offset(text, startChar) -- 490
	if startPos == nil then -- 490
		return text -- 491
	end -- 491
	return string.sub(text, startPos) -- 492
end -- 485
function ____exports.estimateTextTokens(text) -- 495
	if text == "" then -- 495
		return 0 -- 496
	end -- 496
	return App:estimateTokens(text) -- 497
end -- 495
local function estimateMessagesTokens(messages) -- 500
	local total = 0 -- 501
	do -- 501
		local i = 0 -- 502
		while i < #messages do -- 502
			local message = messages[i + 1] -- 503
			total = total + 8 -- 504
			total = total + ____exports.estimateTextTokens(message.role or "") -- 505
			total = total + ____exports.estimateTextTokens(message.content or "") -- 506
			total = total + ____exports.estimateTextTokens(message.name or "") -- 507
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 508
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 509
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({})) -- 510
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 511
			i = i + 1 -- 502
		end -- 502
	end -- 502
	return total -- 513
end -- 500
local function estimateOptionsTokens(options) -- 516
	local text = ____exports.safeJsonEncode(options) -- 517
	return text and ____exports.estimateTextTokens(text) or 0 -- 518
end -- 516
local function getReservedOutputTokens(options, contextWindow) -- 521
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 522
	if explicitMax > 0 then -- 522
		return math.max(256, explicitMax) -- 527
	end -- 527
	return math.max( -- 528
		1024, -- 528
		math.floor(contextWindow * 0.2) -- 528
	) -- 528
end -- 521
function ____exports.getInputTokenBudget(messages, options, config) -- 531
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 532
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 535
	local optionTokens = estimateOptionsTokens(options) -- 536
	local structuralOverhead = math.max(256, #messages * 16) -- 537
	return math.max(0, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 538
end -- 531
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 541
	if budgetTokens <= 0 or text == "" then -- 541
		return "" -- 542
	end -- 542
	local estimated = ____exports.estimateTextTokens(text) -- 543
	if estimated <= budgetTokens then -- 543
		return text -- 544
	end -- 544
	local marker = "\n...\n" -- 548
	if ____exports.estimateTextTokens(marker) > budgetTokens then -- 548
		return "" -- 549
	end -- 549
	local characters = utf8.len(text) -- 550
	if characters == nil then -- 550
		return "" -- 551
	end -- 551
	local low = 0 -- 552
	local high = characters -- 553
	local best = marker -- 554
	while low <= high do -- 554
		local keep = math.floor((low + high) / 2) -- 556
		local head = math.floor(keep * 0.35) -- 557
		local candidate = (utf8TakeHead(text, head) .. marker) .. utf8TakeTail(text, keep - head) -- 558
		if ____exports.estimateTextTokens(candidate) <= budgetTokens then -- 558
			best = candidate -- 560
			low = keep + 1 -- 561
		else -- 561
			high = keep - 1 -- 563
		end -- 563
	end -- 563
	return best -- 566
end -- 541
local function isXMLWhitespaceChar(ch) -- 569
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 570
end -- 569
local function findLineStart(value, from) -- 573
	local i = from -- 574
	while i >= 0 do -- 574
		if __TS__StringAccess(value, i) == "\n" then -- 574
			return i + 1 -- 576
		end -- 576
		i = i - 1 -- 577
	end -- 577
	return 0 -- 579
end -- 573
local function findLastLiteral(text, needle) -- 582
	if needle == "" then -- 582
		return #text -- 583
	end -- 583
	local last = -1 -- 584
	local from = 0 -- 585
	while from <= #text - #needle do -- 585
		local pos = (string.find( -- 587
			text, -- 587
			needle, -- 587
			math.max(from + 1, 1), -- 587
			true -- 587
		) or 0) - 1 -- 587
		if pos < 0 then -- 587
			break -- 588
		end -- 588
		last = pos -- 589
		from = pos + 1 -- 590
	end -- 590
	return last -- 592
end -- 582
local function unwrapXMLRawText(text) -- 595
	local trimmed = __TS__StringTrim(text) -- 596
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 596
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 598
	end -- 598
	return text -- 600
end -- 595
local function readSimpleXMLTagName(source, openStart, openEnd) -- 603
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 604
	if rawTag == "" then -- 604
		return { -- 606
			success = false, -- 606
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 606
		} -- 606
	end -- 606
	local selfClosing = false -- 608
	local tagText = rawTag -- 609
	if __TS__StringEndsWith(tagText, "/") then -- 609
		selfClosing = true -- 611
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 612
	end -- 612
	local tagName = "" -- 614
	do -- 614
		local i = 0 -- 615
		while i < #tagText do -- 615
			local ch = __TS__StringAccess(tagText, i) -- 616
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 616
				break -- 617
			end -- 617
			tagName = tagName .. ch -- 618
			i = i + 1 -- 615
		end -- 615
	end -- 615
	if tagName == "" then -- 615
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 621
	end -- 621
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 623
end -- 603
local function findMatchingXMLClose(source, tagName, contentStart) -- 626
	local sameOpenPrefix = "<" .. tagName -- 627
	local sameCloseToken = ("</" .. tagName) .. ">" -- 628
	local pos = contentStart -- 629
	local depth = 1 -- 630
	while pos < #source do -- 630
		do -- 630
			local lt = (string.find( -- 632
				source, -- 632
				"<", -- 632
				math.max(pos + 1, 1), -- 632
				true -- 632
			) or 0) - 1 -- 632
			if lt < 0 then -- 632
				break -- 633
			end -- 633
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 633
				local cdataEnd = (string.find( -- 635
					source, -- 635
					"]]>", -- 635
					math.max(lt + 9 + 1, 1), -- 635
					true -- 635
				) or 0) - 1 -- 635
				if cdataEnd < 0 then -- 635
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 636
				end -- 636
				pos = cdataEnd + 3 -- 637
				goto __continue154 -- 638
			end -- 638
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 641
					source, -- 641
					"-->",
					math.max(lt + 4 + 1, 1), -- 641
					true -- 641
				) or 0) - 1 -- 641
				if commentEnd < 0 then -- 641
					return {success = false, message = "invalid xml: unterminated comment"} -- 642
				end -- 642
				pos = commentEnd + 3 -- 643
				goto __continue154 -- 644
			end -- 644
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 644
				depth = depth - 1 -- 647
				if depth == 0 then -- 647
					return {success = true, closeStart = lt} -- 648
				end -- 648
				pos = lt + #sameCloseToken -- 649
				goto __continue154 -- 650
			end -- 650
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 650
				local openEnd = (string.find( -- 653
					source, -- 653
					">", -- 653
					math.max(lt + 1, 1), -- 653
					true -- 653
				) or 0) - 1 -- 653
				if openEnd < 0 then -- 653
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 654
				end -- 654
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 655
				if not tagInfo.success then -- 655
					return tagInfo -- 656
				end -- 656
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 656
					depth = depth + 1 -- 658
				end -- 658
				pos = openEnd + 1 -- 660
				goto __continue154 -- 661
			end -- 661
			local genericEnd = (string.find( -- 663
				source, -- 663
				">", -- 663
				math.max(lt + 1, 1), -- 663
				true -- 663
			) or 0) - 1 -- 663
			if genericEnd < 0 then -- 663
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 664
			end -- 664
			pos = genericEnd + 1 -- 665
		end -- 665
		::__continue154:: -- 665
	end -- 665
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 667
end -- 626
function ____exports.extractXMLFromText(text) -- 670
	local source = __TS__StringTrim(text) -- 671
	local function extractFencedBlock(fence) -- 672
		if not __TS__StringStartsWith(source, fence) then -- 672
			return nil -- 673
		end -- 673
		local firstLineEnd = (string.find( -- 674
			source, -- 674
			"\n", -- 674
			math.max(1, 1), -- 674
			true -- 674
		) or 0) - 1 -- 674
		if firstLineEnd < 0 then -- 674
			return nil -- 675
		end -- 675
		local searchPos = firstLineEnd + 1 -- 676
		local closingFencePositions = {} -- 677
		while searchPos < #source do -- 677
			local ____end = (string.find( -- 679
				source, -- 679
				"```", -- 679
				math.max(searchPos + 1, 1), -- 679
				true -- 679
			) or 0) - 1 -- 679
			if ____end < 0 then -- 679
				break -- 680
			end -- 680
			local lineStart = findLineStart(source, ____end - 1) -- 681
			local lineEnd = (string.find( -- 682
				source, -- 682
				"\n", -- 682
				math.max(____end + 1, 1), -- 682
				true -- 682
			) or 0) - 1 -- 682
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 683
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 683
				closingFencePositions[#closingFencePositions + 1] = ____end -- 685
			end -- 685
			searchPos = ____end + 1 -- 687
		end -- 687
		do -- 687
			local i = #closingFencePositions - 1 -- 689
			while i >= 0 do -- 689
				do -- 689
					local closingFencePos = closingFencePositions[i + 1] -- 690
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 691
					if afterFence ~= "" then -- 691
						goto __continue175 -- 692
					end -- 692
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 693
				end -- 693
				::__continue175:: -- 693
				i = i - 1 -- 689
			end -- 689
		end -- 689
		return nil -- 695
	end -- 672
	local xmlBlock = extractFencedBlock("```xml") -- 697
	if xmlBlock ~= nil then -- 697
		return xmlBlock -- 698
	end -- 698
	local genericBlock = extractFencedBlock("```") -- 699
	if genericBlock ~= nil then -- 699
		return genericBlock -- 700
	end -- 700
	return source -- 701
end -- 670
function ____exports.parseSimpleXMLChildren(source) -- 704
	local result = {} -- 705
	local pos = 0 -- 706
	while pos < #source do -- 706
		do -- 706
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 706
				pos = pos + 1 -- 708
			end -- 708
			if pos >= #source then -- 708
				break -- 709
			end -- 709
			if __TS__StringAccess(source, pos) ~= "<" then -- 709
				return { -- 711
					success = false, -- 711
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 711
				} -- 711
			end -- 711
			if __TS__StringStartsWith(source, "</", pos) then -- 711
				return { -- 714
					success = false, -- 714
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 714
				} -- 714
			end -- 714
			local openEnd = (string.find( -- 716
				source, -- 716
				">", -- 716
				math.max(pos + 1, 1), -- 716
				true -- 716
			) or 0) - 1 -- 716
			if openEnd < 0 then -- 716
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 718
			end -- 718
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 720
			if not tagInfo.success then -- 720
				return tagInfo -- 721
			end -- 721
			if tagInfo.selfClosing then -- 721
				result[tagInfo.tagName] = "" -- 723
				pos = openEnd + 1 -- 724
				goto __continue180 -- 725
			end -- 725
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 727
			if not closeRes.success then -- 727
				return closeRes -- 728
			end -- 728
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 729
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 730
			pos = closeRes.closeStart + #closeToken -- 731
		end -- 731
		::__continue180:: -- 731
	end -- 731
	return {success = true, obj = result} -- 733
end -- 704
function ____exports.parseXMLObjectFromText(text, rootTag) -- 736
	local xmlText = ____exports.extractXMLFromText(text) -- 737
	local rootOpen = ("<" .. rootTag) .. ">" -- 738
	local rootClose = ("</" .. rootTag) .. ">" -- 739
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 740
	local ____end = findLastLiteral(xmlText, rootClose) -- 741
	if start < 0 or ____end < start then -- 741
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 743
	end -- 743
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 745
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 746
	if beforeRoot ~= "" or afterRoot ~= "" then -- 746
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 748
	end -- 748
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 750
	return ____exports.parseSimpleXMLChildren(rootContent) -- 751
end -- 736
function ____exports.fitMessagesToContext(messages, options, config) -- 754
	local modelName = string.lower(config.model) -- 761
	local shouldEchoReasoningContent = __TS__ArraySome( -- 762
		messages, -- 762
		function(____, message) return type(message.reasoning_content) == "string" end -- 762
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 762
	local cloned = __TS__ArrayMap( -- 766
		messages, -- 766
		function(____, message) -- 766
			local clonedMessage = __TS__ObjectAssign({}, message) -- 767
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 767
				clonedMessage.reasoning_content = "" -- 773
			end -- 773
			return clonedMessage -- 775
		end -- 766
	) -- 766
	local budgetTokens = ____exports.getInputTokenBudget(cloned, options, config) -- 777
	local originalTokens = estimateMessagesTokens(cloned) -- 778
	if originalTokens <= budgetTokens then -- 778
		return { -- 780
			messages = cloned, -- 781
			trimmed = false, -- 782
			originalTokens = originalTokens, -- 783
			fittedTokens = originalTokens, -- 784
			budgetTokens = budgetTokens -- 785
		} -- 785
	end -- 785
	local function roleOverhead(message) -- 789
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 789
	end -- 789
	local fixedOverhead = 0 -- 790
	local contentIndexes = {} -- 791
	do -- 791
		local i = 0 -- 792
		while i < #cloned do -- 792
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 793
			contentIndexes[#contentIndexes + 1] = i -- 794
			i = i + 1 -- 792
		end -- 792
	end -- 792
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 796
	if #contentIndexes == 1 then -- 796
		local idx = contentIndexes[1] -- 798
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 799
		local fittedTokens = estimateMessagesTokens(cloned) -- 800
		return { -- 801
			messages = cloned, -- 802
			trimmed = true, -- 803
			originalTokens = originalTokens, -- 804
			fittedTokens = fittedTokens, -- 805
			budgetTokens = budgetTokens -- 806
		} -- 806
	end -- 806
	local nonSystemIndexes = {} -- 810
	local systemIndexes = {} -- 811
	do -- 811
		local i = 0 -- 812
		while i < #cloned do -- 812
			if cloned[i + 1].role == "system" then -- 812
				systemIndexes[#systemIndexes + 1] = i -- 813
			else -- 813
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 814
			end -- 814
			i = i + 1 -- 812
		end -- 812
	end -- 812
	local ____array_8 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 812
	__TS__SparseArrayPush( -- 812
		____array_8, -- 812
		table.unpack(systemIndexes) -- 816
	) -- 816
	local priorityIndexes = {__TS__SparseArraySpread(____array_8)} -- 816
	local remainingContentBudget = contentBudget -- 817
	do -- 817
		local i = #priorityIndexes - 1 -- 818
		while i >= 0 do -- 818
			local idx = priorityIndexes[i + 1] -- 819
			local message = cloned[idx + 1] -- 820
			local minBudget = message.role == "system" and 96 or 192 -- 821
			local target = math.max( -- 822
				minBudget, -- 822
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 822
			) -- 822
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 823
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 824
			remainingContentBudget = math.max(0, remainingContentBudget) -- 825
			i = i - 1 -- 818
		end -- 818
	end -- 818
	local fittedTokens = estimateMessagesTokens(cloned) -- 828
	if fittedTokens > budgetTokens then -- 828
		do -- 828
			local i = 0 -- 830
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 830
				local idx = priorityIndexes[i + 1] -- 831
				local message = cloned[idx + 1] -- 832
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 833
				local excess = fittedTokens - budgetTokens -- 834
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 835
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 836
				fittedTokens = estimateMessagesTokens(cloned) -- 837
				i = i + 1 -- 830
			end -- 830
		end -- 830
	end -- 830
	if fittedTokens > budgetTokens then -- 830
		do -- 830
			local i = 0 -- 841
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 841
				do -- 841
					local idx = priorityIndexes[i + 1] -- 842
					if cloned[idx + 1].role == "system" then -- 842
						goto __continue212 -- 843
					end -- 843
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 844
					fittedTokens = estimateMessagesTokens(cloned) -- 845
				end -- 845
				::__continue212:: -- 845
				i = i + 1 -- 841
			end -- 841
		end -- 841
	end -- 841
	return { -- 848
		messages = cloned, -- 849
		trimmed = true, -- 850
		originalTokens = originalTokens, -- 851
		fittedTokens = fittedTokens, -- 852
		budgetTokens = budgetTokens -- 853
	} -- 853
end -- 754
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken, studioGateway) -- 857
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 869
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 870
	local data = __TS__ObjectAssign({model = model}, requestOptions, {messages = messages, stream = stream}) -- 871
	local studioRequestId = studioGateway and ____exports.createStudioModelRequestId() or nil -- 877
	if stopToken == nil then -- 877
		stopToken = {stopped = false} -- 878
	end -- 878
	return __TS__New( -- 879
		__TS__Promise, -- 879
		function(____, resolve, reject) -- 879
			local requestId = 0 -- 880
			local settled = false -- 881
			local function finishResolve(text) -- 882
				if settled then -- 882
					return -- 883
				end -- 883
				settled = true -- 884
				resolve(nil, text) -- 885
			end -- 882
			local function finishReject(err) -- 887
				if settled then -- 887
					return -- 888
				end -- 888
				settled = true -- 889
				reject(nil, err) -- 890
			end -- 887
			Director.systemScheduler:schedule(function() -- 892
				if not settled then -- 892
					if stopToken.stopped then -- 892
						if requestId ~= 0 then -- 892
							HttpClient:cancel(requestId) -- 896
							requestId = 0 -- 897
						end -- 897
						finishReject("request cancelled") -- 899
						return true -- 900
					end -- 900
					return false -- 902
				end -- 902
				return true -- 904
			end) -- 892
			Director.systemScheduler:schedule(once(function() -- 906
				emit( -- 907
					"LLM_IN", -- 907
					table.concat( -- 907
						__TS__ArrayMap( -- 907
							messages, -- 907
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 907
						), -- 907
						"\n" -- 907
					) -- 907
				) -- 907
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 908
				if jsonStr ~= nil then -- 908
					local headers = { -- 910
						"Authorization: Bearer " .. apiKey, -- 911
						"Content-Type: application/json", -- 912
						receiver and "Accept: text/event-stream" or "Accept: application/json", -- 913
						table.unpack(studioRequestId and ({"X-Studio-Model-Request-Id: " .. studioRequestId}) or ({})) -- 914
					} -- 914
					requestId = receiver and HttpClient:post( -- 916
						url, -- 917
						headers, -- 917
						jsonStr, -- 917
						requestTimeout, -- 917
						function(data) -- 917
							if stopToken.stopped then -- 917
								return true -- 918
							end -- 918
							return receiver(data) -- 919
						end, -- 917
						function(data) -- 920
							requestId = 0 -- 921
							if data ~= nil then -- 921
								finishResolve(data) -- 923
							else -- 923
								finishReject("failed to get http response") -- 925
							end -- 925
						end -- 920
					) or HttpClient:post( -- 920
						url, -- 928
						headers, -- 928
						jsonStr, -- 928
						requestTimeout, -- 928
						function(data) -- 928
							requestId = 0 -- 929
							if stopToken.stopped then -- 929
								finishReject("request cancelled") -- 931
								return -- 932
							end -- 932
							if data ~= nil then -- 932
								finishResolve(data) -- 935
							else -- 935
								finishReject("failed to get http response") -- 937
							end -- 937
						end -- 928
					) -- 928
					if requestId == 0 then -- 928
						finishReject("failed to schedule http request") -- 941
					elseif stopToken.stopped then -- 941
						HttpClient:cancel(requestId) -- 943
						requestId = 0 -- 944
						finishReject("request cancelled") -- 945
					end -- 945
				else -- 945
					finishReject(err) -- 948
				end -- 948
			end)) -- 906
		end -- 879
	) -- 879
end -- 857
function ____exports.createSSEJSONParser(opts) -- 958
	local buffer = "" -- 963
	local eventDataLines = {} -- 964
	local function flushEventIfAny() -- 966
		if #eventDataLines == 0 then -- 966
			return -- 967
		end -- 967
		local dataPayload = table.concat(eventDataLines, "\n") -- 969
		eventDataLines = {} -- 970
		if dataPayload == "[DONE]" then -- 970
			local ____opt_9 = opts.onDone -- 970
			if ____opt_9 ~= nil then -- 970
				____opt_9(dataPayload) -- 973
			end -- 973
			return -- 974
		end -- 974
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 977
		if err == nil then -- 977
			opts.onJSON(obj, dataPayload) -- 979
		else -- 979
			local ____opt_11 = opts.onError -- 979
			if ____opt_11 ~= nil then -- 979
				____opt_11(err, {raw = dataPayload}) -- 981
			end -- 981
		end -- 981
	end -- 966
	local function append(chunk) -- 985
		buffer = buffer .. chunk -- 986
	end -- 985
	local function drain(maxLines) -- 989
		local processedLines = 0 -- 990
		while maxLines == nil or processedLines < maxLines do -- 990
			do -- 990
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 992
				if nl < 0 then -- 992
					break -- 993
				end -- 993
				processedLines = processedLines + 1 -- 994
				local line = __TS__StringSlice(buffer, 0, nl) -- 996
				buffer = __TS__StringSlice(buffer, nl + 1) -- 997
				if __TS__StringEndsWith(line, "\r") then -- 997
					line = string.sub(line, 1, -2) -- 999
				end -- 999
				if line == "" then -- 999
					flushEventIfAny() -- 1002
					goto __continue247 -- 1003
				end -- 1003
				if __TS__StringStartsWith(line, ":") then -- 1003
					goto __continue247 -- 1007
				end -- 1007
				if __TS__StringStartsWith(line, "data:") then -- 1007
					local v = string.sub(line, 6) -- 1010
					if __TS__StringStartsWith(v, " ") then -- 1010
						v = string.sub(v, 2) -- 1011
					end -- 1011
					eventDataLines[#eventDataLines + 1] = v -- 1012
					goto __continue247 -- 1013
				end -- 1013
			end -- 1013
			::__continue247:: -- 1013
		end -- 1013
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0 -- 1016
	end -- 989
	local function feed(chunk) -- 1019
		append(chunk) -- 1020
		drain() -- 1021
	end -- 1019
	local function ____end() -- 1024
		if #buffer > 0 then -- 1024
			local line = buffer -- 1026
			buffer = "" -- 1027
			if __TS__StringEndsWith(line, "\r") then -- 1027
				line = string.sub(line, 1, -2) -- 1028
			end -- 1028
			if __TS__StringStartsWith(line, "data:") then -- 1028
				local v = string.sub(line, 6) -- 1031
				if __TS__StringStartsWith(v, " ") then -- 1031
					v = string.sub(v, 2) -- 1032
				end -- 1032
				eventDataLines[#eventDataLines + 1] = v -- 1033
			end -- 1033
		end -- 1033
		flushEventIfAny() -- 1036
	end -- 1024
	local function discard() -- 1039
		buffer = "" -- 1040
		eventDataLines = {} -- 1041
	end -- 1039
	return { -- 1044
		append = append, -- 1044
		drain = drain, -- 1044
		feed = feed, -- 1044
		["end"] = ____end, -- 1044
		discard = discard -- 1044
	} -- 1044
end -- 958
local SSE_PARSE_LINES_PER_FRAME = 256 -- 1047
local function createScheduledSSEJSONParser(opts, isCancelled) -- 1049
	local parser = ____exports.createSSEJSONParser(opts) -- 1053
	local inputFinished = false -- 1054
	local settled = false -- 1055
	local resolveFinished -- 1056
	local finished = __TS__New( -- 1057
		__TS__Promise, -- 1057
		function(____, resolve) -- 1057
			resolveFinished = resolve -- 1058
		end -- 1057
	) -- 1057
	local function settle() -- 1060
		if settled then -- 1060
			return -- 1061
		end -- 1061
		settled = true -- 1062
		if resolveFinished ~= nil then -- 1062
			resolveFinished() -- 1063
		end -- 1063
	end -- 1060
	Director.systemScheduler:schedule(function() -- 1065
		if settled then -- 1065
			return true -- 1066
		end -- 1066
		if isCancelled and isCancelled() then -- 1066
			parser.discard() -- 1068
			settle() -- 1069
			return true -- 1070
		end -- 1070
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME) -- 1072
		if inputFinished and not hasMoreCompleteLines then -- 1072
			parser["end"]() -- 1074
			settle() -- 1075
			return true -- 1076
		end -- 1076
		return false -- 1078
	end) -- 1065
	return { -- 1080
		append = parser.append, -- 1081
		finish = function() -- 1082
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1082
				inputFinished = true -- 1083
				__TS__Await(finished) -- 1084
			end) -- 1084
		end, -- 1082
		cancel = function() -- 1086
			parser.discard() -- 1087
			settle() -- 1088
		end -- 1086
	} -- 1086
end -- 1049
function ____exports.extractLLMTokenUsage(response) -- 1184
	local usage = response and response.usage -- 1185
	if not usage or type(usage) ~= "table" then -- 1185
		return nil -- 1186
	end -- 1186
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1187
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1190
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1190
		return nil -- 1193
	end -- 1193
	local ____temp_24 -- 1194
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1194
		____temp_24 = usage.prompt_cache_hit_tokens -- 1195
	else -- 1195
		local ____temp_23 -- 1196
		local ____opt_19 = usage.prompt_tokens_details -- 1196
		if type(____opt_19 and ____opt_19.cached_tokens) == "number" then -- 1196
			____temp_23 = usage.prompt_tokens_details.cached_tokens -- 1197
		else -- 1197
			local ____opt_21 = usage.input_tokens_details -- 1197
			____temp_23 = type(____opt_21 and ____opt_21.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1198
		end -- 1198
		____temp_24 = ____temp_23 -- 1196
	end -- 1196
	local cachedInputTokens = ____temp_24 -- 1194
	local ____inputTokens_27 = inputTokens -- 1202
	local ____outputTokens_28 = outputTokens -- 1203
	local ____temp_29 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1204
	local ____temp_30 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1205
	local ____temp_31 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1206
	local ____opt_25 = usage.completion_tokens_details -- 1206
	return { -- 1201
		inputTokens = ____inputTokens_27, -- 1202
		outputTokens = ____outputTokens_28, -- 1203
		totalTokens = ____temp_29, -- 1204
		cachedInputTokens = ____temp_30, -- 1205
		cacheMissInputTokens = ____temp_31, -- 1206
		reasoningOutputTokens = type(____opt_25 and ____opt_25.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1209
	} -- 1209
end -- 1184
function ____exports.validateAgentLLMConfig(config) -- 1253
	local ____opt_32 = config.customOptions -- 1253
	local visionModel = ____opt_32 and ____opt_32.visionModel -- 1254
	if visionModel ~= nil and visionModel ~= json.null and type(visionModel) ~= "string" then -- 1254
		return {success = false, message = "视觉模型名称 visionModel 必须是字符串；留空使用默认行为。"} -- 1256
	end -- 1256
	local ____opt_34 = config.customOptions -- 1256
	local auxiliaryOptions = ____opt_34 and ____opt_34.auxiliaryOptions -- 1258
	if auxiliaryOptions == nil then -- 1258
		return {success = true} -- 1259
	end -- 1259
	local emptyOptions = type(auxiliaryOptions) == "table" and auxiliaryOptions ~= nil and auxiliaryOptions ~= json.null and #__TS__ObjectKeys(auxiliaryOptions) == 0 -- 1260
	if isPlainRecord(auxiliaryOptions) or emptyOptions then -- 1260
		return {success = true} -- 1266
	end -- 1266
	return {success = false, message = "LLM 配置的 auxiliaryOptions 如有填写必须是对象（可以为空），请检查 LLM 配置"} -- 1268
end -- 1253
local function normalizeContextWindow(value) -- 1274
	if type(value) == "number" and value > 0 then -- 1274
		return math.floor(value) -- 1276
	end -- 1276
	return 64000 -- 1278
end -- 1274
local function normalizeLLMTemperature(value) -- 1281
	if type(value) == "number" then -- 1281
		return math.max( -- 1283
			0, -- 1283
			math.min(2, value) -- 1283
		) -- 1283
	end -- 1283
	return 0.1 -- 1285
end -- 1281
local function normalizeLLMMaxTokens(value) -- 1288
	if type(value) == "number" then -- 1288
		return math.max( -- 1290
			1, -- 1290
			math.floor(value) -- 1290
		) -- 1290
	end -- 1290
	return AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1292
end -- 1288
local function normalizeLLMCustomOptions(value) -- 1301
	if type(value) ~= "string" then -- 1301
		return nil -- 1302
	end -- 1302
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1303
	if text == "" then -- 1303
		return nil -- 1304
	end -- 1304
	local decoded = ____exports.safeJsonDecode(text) -- 1305
	return isPlainRecord(decoded) and decoded or nil -- 1306
end -- 1301
local function getLLMConfigRecords() -- 1329
	upgradeLLMConfig() -- 1330
	local rows = DB:query("select * from LLMConfig", true) -- 1331
	local records = {} -- 1332
	if rows and #rows > 1 then -- 1332
		do -- 1332
			local i = 1 -- 1334
			while i < #rows do -- 1334
				local record = {} -- 1335
				do -- 1335
					local c = 0 -- 1336
					while c < #rows[i + 1] do -- 1336
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1337
						c = c + 1 -- 1336
					end -- 1336
				end -- 1336
				records[#records + 1] = record -- 1339
				i = i + 1 -- 1334
			end -- 1334
		end -- 1334
	end -- 1334
	return records -- 1342
end -- 1329
function ____exports.getLLMConfigSummaries() -- 1352
	return __TS__ArrayFlatMap( -- 1353
		getLLMConfigRecords(), -- 1353
		function(____, record) -- 1353
			local id = record.id -- 1354
			local name = record.name -- 1355
			local model = record.model -- 1356
			if type(id) ~= "number" or type(name) ~= "string" or type(model) ~= "string" then -- 1356
				return {} -- 1357
			end -- 1357
			return {{id = id, name = name, model = model, active = record.active ~= 0}} -- 1358
		end -- 1353
	) -- 1353
end -- 1352
local function parseLLMConfig(config) -- 1362
	if not config then -- 1362
		return {success = false, message = "LLM config not found"} -- 1364
	end -- 1364
	local ____config_36 = config -- 1366
	local id = ____config_36.id -- 1366
	local url = ____config_36.url -- 1366
	local model = ____config_36.model -- 1366
	local api_key = ____config_36.api_key -- 1366
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1366
		return {success = false, message = "got invalid LLM config"} -- 1368
	end -- 1368
	return { -- 1370
		success = true, -- 1371
		id = id, -- 1372
		config = { -- 1373
			url = url, -- 1374
			model = model, -- 1375
			apiKey = api_key, -- 1376
			contextWindow = normalizeContextWindow(config.context_window), -- 1377
			temperature = normalizeLLMTemperature(config.temperature), -- 1378
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1379
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1380
			customOptions = normalizeLLMCustomOptions(config.custom_options) -- 1381
		} -- 1381
	} -- 1381
end -- 1362
function ____exports.getLLMConfig(configId) -- 1386
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1387
	if normalizedId == nil or normalizedId <= 0 then -- 1387
		return {success = false, message = "LLM config is not selected"} -- 1389
	end -- 1389
	return parseLLMConfig(__TS__ArrayFind( -- 1391
		getLLMConfigRecords(), -- 1391
		function(____, record) return record.id == normalizedId end -- 1391
	)) -- 1391
end -- 1386
function ____exports.getActiveLLMConfig() -- 1394
	local records = getLLMConfigRecords() -- 1395
	local config = __TS__ArrayFind( -- 1396
		records, -- 1396
		function(____, r) return r.active ~= 0 end -- 1396
	) -- 1396
	if not config then -- 1396
		return {success = false, message = "no active LLM config"} -- 1398
	end -- 1398
	return parseLLMConfig(config) -- 1400
end -- 1394
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1403
	local callEvent -- 1409
	if event.id ~= nil then -- 1409
		local id = event.id -- 1411
		callEvent = { -- 1412
			id = nil, -- 1413
			onData = function(data) -- 1414
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1415
				return event.stopToken.stopped -- 1416
			end, -- 1414
			onCancel = function(reason) -- 1418
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1419
			end, -- 1418
			onDone = function() -- 1421
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1422
			end -- 1421
		} -- 1421
	else -- 1421
		callEvent = event -- 1426
	end -- 1426
	local ____callEvent_37 = callEvent -- 1428
	local onData = ____callEvent_37.onData -- 1428
	local onDone = ____callEvent_37.onDone -- 1428
	local ____callEvent_38 = callEvent -- 1429
	local onCancel = ____callEvent_38.onCancel -- 1429
	local config = llmConfig or (function() -- 1430
		local configRes = ____exports.getActiveLLMConfig() -- 1431
		if not configRes.success then -- 1431
			if onCancel then -- 1431
				onCancel(configRes.message) -- 1433
			end -- 1433
			return nil -- 1434
		end -- 1434
		return configRes.config -- 1436
	end)() -- 1430
	if not config then -- 1430
		return {success = false, message = "no active LLM config"} -- 1439
	end -- 1439
	local url = config.url -- 1439
	local model = config.model -- 1439
	local apiKey = config.apiKey -- 1439
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1442
	if fitted.fittedTokens > fitted.budgetTokens then -- 1442
		return {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."} -- 1444
	end -- 1444
	if fitted.trimmed then -- 1444
		____exports.Log( -- 1447
			"Warn", -- 1447
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1447
		) -- 1447
	end -- 1447
	local stopLLM = false -- 1449
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1450
	local parser = createScheduledSSEJSONParser( -- 1453
		{onJSON = function(obj) -- 1453
			local result = onData(obj) -- 1455
			if result then -- 1455
				stopLLM = true -- 1457
				streamStopToken.stopped = true -- 1458
				streamStopToken.reason = "LLM Stopped" -- 1459
			end -- 1459
		end}, -- 1454
		function() return streamStopToken.stopped end -- 1462
	); -- 1462
	(function() -- 1463
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1463
			local ____try = __TS__AsyncAwaiter(function() -- 1463
				local result = __TS__Await(postLLM( -- 1465
					fitted.messages, -- 1465
					url, -- 1465
					apiKey, -- 1465
					model, -- 1465
					options, -- 1465
					true, -- 1465
					config.customOptions, -- 1465
					function(data) -- 1465
						if stopLLM then -- 1465
							if onCancel then -- 1465
								onCancel("LLM Stopped") -- 1468
								onCancel = nil -- 1469
							end -- 1469
							return true -- 1471
						end -- 1471
						parser.append(data) -- 1473
						return false -- 1474
					end, -- 1465
					streamStopToken, -- 1475
					config.studioGateway -- 1475
				)) -- 1475
				__TS__Await(parser.finish()) -- 1476
				if onDone then -- 1476
					onDone(result) -- 1478
				end -- 1478
			end) -- 1478
			____try = ____try.catch( -- 1478
				____try, -- 1478
				function(____, e) -- 1478
					return __TS__AsyncAwaiter(function() -- 1478
						parser.cancel() -- 1481
						stopLLM = true -- 1482
						if onCancel then -- 1482
							onCancel(tostring(e)) -- 1484
							onCancel = nil -- 1485
						end -- 1485
					end) -- 1485
				end -- 1485
			) -- 1485
			__TS__Await(____try) -- 1464
		end) -- 1464
	end)() -- 1463
	return {success = true} -- 1489
end -- 1403
local function mergeStreamToolCall(target, delta) -- 1492
	if type(delta.id) == "string" and delta.id ~= "" then -- 1492
		target.id = delta.id -- 1494
	end -- 1494
	if type(delta.type) == "string" and delta.type ~= "" then -- 1494
		target.type = delta.type -- 1497
	end -- 1497
	if delta["function"] then -- 1497
		if target["function"] == nil then -- 1497
			target["function"] = {} -- 1500
		end -- 1500
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1500
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1502
		end -- 1502
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1502
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1505
		end -- 1505
	end -- 1505
end -- 1492
local function isToolCallComplete(tc) -- 1510
	if type(tc.id) ~= "string" or tc.id == "" then -- 1510
		return false -- 1511
	end -- 1511
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1511
		return false -- 1512
	end -- 1512
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1512
		return false -- 1513
	end -- 1513
	local args = tc["function"].arguments -- 1514
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1514
		return false -- 1515
	end -- 1515
	local decoded = ____exports.safeJsonDecode(args) -- 1516
	return decoded ~= nil -- 1517
end -- 1510
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1520
	local delta = choice.delta or ({}) -- 1521
	local fullMessage = choice.message or ({}) -- 1522
	local message = acc.message -- 1523
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1524
	if type(role) == "string" and role ~= "" then -- 1524
		message.role = role -- 1528
	end -- 1528
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1530
	if type(content) == "string" and content ~= "" then -- 1530
		message.content = (message.content or "") .. content -- 1534
	end -- 1534
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1536
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1536
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1540
	end -- 1540
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1542
	if #toolCalls > 0 then -- 1542
		if message.tool_calls == nil then -- 1542
			message.tool_calls = {} -- 1546
		end -- 1546
		do -- 1546
			local i = 0 -- 1547
			while i < #toolCalls do -- 1547
				local item = toolCalls[i + 1] -- 1548
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1549
				local ____message_tool_calls_39, ____temp_40 = message.tool_calls, index + 1 -- 1549
				if ____message_tool_calls_39[____temp_40] == nil then -- 1549
					____message_tool_calls_39[____temp_40] = {} -- 1552
				end -- 1552
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1553
				if onToolCallReady and emittedToolCallIds then -- 1553
					local tc = message.tool_calls[index + 1] -- 1555
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1555
						emittedToolCallIds[tc.id] = true -- 1557
						onToolCallReady(tc) -- 1558
					end -- 1558
				end -- 1558
				i = i + 1 -- 1547
			end -- 1547
		end -- 1547
	end -- 1547
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1547
		acc.finish_reason = choice.finish_reason -- 1564
	end -- 1564
end -- 1520
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1568
	local indexes = __TS__ArraySort( -- 1577
		__TS__ArrayFilter( -- 1577
			__TS__ArrayMap( -- 1577
				__TS__ObjectKeys(states), -- 1577
				function(____, key) return __TS__Number(key) end -- 1578
			), -- 1578
			function(____, index) return __TS__NumberIsFinite(index) end -- 1579
		), -- 1579
		function(____, a, b) return a - b end -- 1580
	) -- 1580
	return { -- 1581
		id = id, -- 1582
		created = created, -- 1583
		object = object, -- 1584
		model = model, -- 1585
		choices = __TS__ArrayMap( -- 1586
			indexes, -- 1586
			function(____, index) -- 1586
				local state = states[index] -- 1587
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1588
			end -- 1586
		), -- 1586
		usage = usage, -- 1599
		error = providerError -- 1600
	} -- 1600
end -- 1568
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1604
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1604
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1615
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1616
		local resolvedConfig = config or (function() -- 1619
			local configRes = ____exports.getActiveLLMConfig() -- 1620
			if not configRes.success then -- 1620
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1622
				return nil -- 1623
			end -- 1623
			return configRes.config -- 1625
		end)() -- 1619
		if not resolvedConfig then -- 1619
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1619
		end -- 1619
		local url = resolvedConfig.url -- 1619
		local model = resolvedConfig.model -- 1619
		local apiKey = resolvedConfig.apiKey -- 1619
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1631
		if fitted.fittedTokens > fitted.budgetTokens then -- 1631
			return ____awaiter_resolve(nil, {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."}) -- 1631
		end -- 1631
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1635
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1636
		local ____model_45 = model -- 1639
		local ____url_46 = url -- 1639
		local ____temp_47 = #messages -- 1639
		local ____tostring_42 = tostring -- 1639
		local ____options_max_tokens_41 = options.max_tokens -- 1639
		if ____options_max_tokens_41 == nil then -- 1639
			____options_max_tokens_41 = "unset" -- 1639
		end -- 1639
		local ____tostring_42_result_48 = ____tostring_42(____options_max_tokens_41) -- 1639
		local ____tostring_44 = tostring -- 1639
		local ____options_temperature_43 = options.temperature -- 1639
		if ____options_temperature_43 == nil then -- 1639
			____options_temperature_43 = "unset" -- 1639
		end -- 1639
		____exports.Log( -- 1639
			"Info", -- 1639
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_45) .. " url=") .. ____url_46) .. " messages=") .. tostring(____temp_47)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_42_result_48) .. " temperature=") .. ____tostring_44(____options_temperature_43)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1639
		) -- 1639
		if stopToken and stopToken.stopped then -- 1639
			local reason = stopToken.reason or "request cancelled" -- 1641
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1642
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1642
		end -- 1642
		local ____hasReturned, ____returnValue -- 1642
		local ____try = __TS__AsyncAwaiter(function() -- 1642
			local states = {} -- 1646
			local emittedToolCallIds = {} -- 1647
			local responseId = nil -- 1648
			local responseCreated = nil -- 1649
			local responseObject = nil -- 1650
			local providerError -- 1651
			local responseUsage -- 1652
			local httpChunkCount = 0 -- 1653
			local rawStreamBytes = 0 -- 1654
			local rawStreamPreview = "" -- 1655
			local sseJSONChunkCount = 0 -- 1656
			local choiceJSONChunkCount = 0 -- 1657
			local emptyChoicesChunkCount = 0 -- 1658
			local missingChoicesChunkCount = 0 -- 1659
			local parseErrorCount = 0 -- 1660
			local doneChunkSeen = false -- 1661
			local lastJSONPreview = "" -- 1662
			local parser = createScheduledSSEJSONParser( -- 1663
				{ -- 1663
					onJSON = function(obj, raw) -- 1664
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1665
						lastJSONPreview = previewText(raw, 500) -- 1666
						if not obj or type(obj) ~= "table" then -- 1666
							return -- 1668
						end -- 1668
						local chunk = obj -- 1670
						if chunk.error then -- 1670
							providerError = chunk.error -- 1672
							____exports.Log( -- 1673
								"Warn", -- 1673
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1673
							) -- 1673
							return -- 1674
						end -- 1674
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1676
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1677
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1678
						if chunk.usage and type(chunk.usage) == "table" then -- 1678
							responseUsage = chunk.usage -- 1680
						end -- 1680
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1682
						if not __TS__ArrayIsArray(chunk.choices) then -- 1682
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1684
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1684
								____exports.Log( -- 1686
									"Warn", -- 1686
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1686
								) -- 1686
							end -- 1686
						elseif #choices == 0 then -- 1686
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1689
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1689
								____exports.Log( -- 1691
									"Warn", -- 1691
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1691
								) -- 1691
							end -- 1691
						else -- 1691
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1694
						end -- 1694
						do -- 1694
							local i = 0 -- 1696
							while i < #choices do -- 1696
								local choice = choices[i + 1] -- 1697
								local index = type(choice.index) == "number" and choice.index or i -- 1698
								if states[index] == nil then -- 1698
									states[index] = {index = index, message = {role = "assistant"}} -- 1699
								end -- 1699
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1703
								i = i + 1 -- 1696
							end -- 1696
						end -- 1696
						if onChunk ~= nil then -- 1696
							onChunk( -- 1705
								buildStreamResponse( -- 1706
									states, -- 1706
									model, -- 1706
									responseId, -- 1706
									responseCreated, -- 1706
									responseObject, -- 1706
									providerError, -- 1706
									responseUsage -- 1706
								), -- 1706
								{ -- 1707
									id = chunk.id or "", -- 1708
									created = chunk.created or 0, -- 1709
									object = chunk.object or "", -- 1710
									model = chunk.model or model, -- 1711
									choices = choices -- 1712
								} -- 1712
							) -- 1712
						end -- 1712
					end, -- 1664
					onDone = function() -- 1716
						doneChunkSeen = true -- 1717
					end, -- 1716
					onError = function(err, context) -- 1719
						parseErrorCount = parseErrorCount + 1 -- 1720
						____exports.Log( -- 1721
							"Warn", -- 1721
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1721
						) -- 1721
					end -- 1719
				}, -- 1719
				function() return (stopToken and stopToken.stopped) == true end -- 1723
			) -- 1723
			local ____try = __TS__AsyncAwaiter(function() -- 1723
				__TS__Await(postLLM( -- 1725
					fitted.messages, -- 1725
					url, -- 1725
					apiKey, -- 1725
					model, -- 1725
					options, -- 1725
					true, -- 1725
					resolvedConfig.customOptions, -- 1725
					function(data) -- 1725
						if stopToken and stopToken.stopped then -- 1725
							return true -- 1726
						end -- 1726
						httpChunkCount = httpChunkCount + 1 -- 1727
						rawStreamBytes = rawStreamBytes + #data -- 1728
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1728
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1730
						end -- 1730
						parser.append(data) -- 1732
						return false -- 1733
					end, -- 1725
					stopToken, -- 1734
					resolvedConfig.studioGateway -- 1734
				)) -- 1734
				__TS__Await(parser.finish()) -- 1735
			end) -- 1735
			____try = ____try.catch( -- 1735
				____try, -- 1735
				function(____, e) -- 1735
					return __TS__AsyncAwaiter(function() -- 1735
						parser.cancel() -- 1737
						error(e, 0) -- 1738
					end) -- 1738
				end -- 1738
			) -- 1738
			__TS__Await(____try) -- 1724
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1724
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1741
				if rawResponse and type(rawResponse) == "table" then -- 1741
					local rawResponseObj = rawResponse -- 1743
					if rawResponseObj.error then -- 1743
						providerError = rawResponseObj.error -- 1745
						lastJSONPreview = previewText( -- 1746
							normalizeLLMJSONResponse(rawStreamPreview), -- 1746
							500 -- 1746
						) -- 1746
						____exports.Log( -- 1747
							"Warn", -- 1747
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1747
						) -- 1747
					end -- 1747
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1747
						responseUsage = rawResponseObj.usage -- 1750
					end -- 1750
				end -- 1750
			end -- 1750
			local response = buildStreamResponse( -- 1754
				states, -- 1754
				model, -- 1754
				responseId, -- 1754
				responseCreated, -- 1754
				responseObject, -- 1754
				providerError, -- 1754
				responseUsage -- 1754
			) -- 1754
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1755
			local choiceCount = response.choices and #response.choices or 0 -- 1756
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1757
			____exports.Log( -- 1758
				"Info", -- 1758
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1758
			) -- 1758
			if not doneChunkSeen then -- 1758
				local rawPreview = previewText( -- 1760
					____exports.sanitizeUTF8(rawStreamPreview), -- 1760
					1200 -- 1760
				) -- 1760
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1761
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1762
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1763
				____hasReturned = true -- 1764
				____returnValue = { -- 1764
					success = false, -- 1765
					message = message, -- 1766
					raw = rawStreamPreview, -- 1767
					response = response, -- 1768
					tokenUsage = tokenUsage -- 1769
				} -- 1769
				return -- 1764
			end -- 1764
			if not response.choices or #response.choices == 0 then -- 1764
				local providerMessage = providerError and providerError.message or "" -- 1773
				local providerType = providerError and providerError.type or "" -- 1774
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1775
				local details = table.concat( -- 1778
					__TS__ArrayFilter( -- 1778
						{providerType, providerCode}, -- 1778
						function(____, part) return part ~= "" end -- 1778
					), -- 1778
					"/" -- 1778
				) -- 1778
				local rawPreview = previewText( -- 1779
					____exports.sanitizeUTF8(rawStreamPreview), -- 1779
					1200 -- 1779
				) -- 1779
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1780
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1781
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1784
				____hasReturned = true -- 1785
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1785
				return -- 1785
			end -- 1785
			____hasReturned = true -- 1792
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1792
			return -- 1792
		end) -- 1792
		____try = ____try.catch( -- 1792
			____try, -- 1792
			function(____, e) -- 1792
				return __TS__AsyncAwaiter(function() -- 1792
					if stopToken and stopToken.stopped then -- 1792
						local reason = stopToken.reason or "request cancelled" -- 1799
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1800
						____hasReturned = true -- 1801
						____returnValue = {success = false, message = reason} -- 1801
						return -- 1801
					end -- 1801
					____exports.Log( -- 1803
						"Error", -- 1803
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1803
					) -- 1803
					____hasReturned = true -- 1804
					____returnValue = { -- 1804
						success = false, -- 1804
						message = tostring(e) -- 1804
					} -- 1804
					return -- 1804
				end) -- 1804
			end -- 1804
		) -- 1804
		__TS__Await(____try) -- 1645
		if ____hasReturned then -- 1645
			return ____awaiter_resolve(nil, ____returnValue) -- 1645
		end -- 1645
	end) -- 1645
end -- 1604
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1808
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1808
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1814
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1815
		local resolvedConfig = config or (function() -- 1818
			local configRes = ____exports.getActiveLLMConfig() -- 1819
			if not configRes.success then -- 1819
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1821
				return nil -- 1822
			end -- 1822
			return configRes.config -- 1824
		end)() -- 1818
		if not resolvedConfig then -- 1818
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1818
		end -- 1818
		local url = resolvedConfig.url -- 1818
		local model = resolvedConfig.model -- 1818
		local apiKey = resolvedConfig.apiKey -- 1818
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1830
		if fitted.fittedTokens > fitted.budgetTokens then -- 1830
			return ____awaiter_resolve(nil, {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."}) -- 1830
		end -- 1830
		____exports.Log( -- 1834
			"Info", -- 1834
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1834
		) -- 1834
		if stopToken and stopToken.stopped then -- 1834
			local reason = stopToken.reason or "request cancelled" -- 1836
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1837
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1837
		end -- 1837
		local ____hasReturned, ____returnValue -- 1837
		local ____try = __TS__AsyncAwaiter(function() -- 1837
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1841
				fitted.messages, -- 1841
				url, -- 1841
				apiKey, -- 1841
				model, -- 1841
				options, -- 1841
				false, -- 1841
				resolvedConfig.customOptions, -- 1841
				nil, -- 1841
				stopToken, -- 1841
				resolvedConfig.studioGateway -- 1841
			))) -- 1841
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1842
			____exports.Log( -- 1843
				"Info", -- 1843
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1843
			) -- 1843
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1844
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1844
				local rawPreview = previewText(raw) -- 1846
				____exports.Log( -- 1847
					"Error", -- 1847
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1847
				) -- 1847
				____hasReturned = true -- 1848
				____returnValue = { -- 1848
					success = false, -- 1849
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1850
					raw = raw -- 1851
				} -- 1851
				return -- 1848
			end -- 1848
			local responseObj = response -- 1854
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1855
			____exports.Log( -- 1856
				"Info", -- 1856
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1856
			) -- 1856
			if not responseObj.choices or #responseObj.choices == 0 then -- 1856
				local providerError = responseObj.error -- 1858
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1859
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1862
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1865
				local details = table.concat( -- 1868
					__TS__ArrayFilter( -- 1868
						{providerType, providerCode}, -- 1868
						function(____, part) return part ~= "" end -- 1868
					), -- 1868
					"/" -- 1868
				) -- 1868
				local rawPreview = previewText(raw, 400) -- 1869
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1870
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1873
				____hasReturned = true -- 1874
				____returnValue = {success = false, message = message, raw = raw} -- 1874
				return -- 1874
			end -- 1874
			____hasReturned = true -- 1880
			____returnValue = {success = true, response = responseObj} -- 1880
			return -- 1880
		end) -- 1880
		____try = ____try.catch( -- 1880
			____try, -- 1880
			function(____, e) -- 1880
				return __TS__AsyncAwaiter(function() -- 1880
					if stopToken and stopToken.stopped then -- 1880
						local reason = stopToken.reason or "request cancelled" -- 1886
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1887
						____hasReturned = true -- 1888
						____returnValue = {success = false, message = reason} -- 1888
						return -- 1888
					end -- 1888
					____exports.Log( -- 1890
						"Error", -- 1890
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1890
					) -- 1890
					____hasReturned = true -- 1891
					____returnValue = { -- 1891
						success = false, -- 1891
						message = tostring(e) -- 1891
					} -- 1891
					return -- 1891
				end) -- 1891
			end -- 1891
		) -- 1891
		__TS__Await(____try) -- 1840
		if ____hasReturned then -- 1840
			return ____awaiter_resolve(nil, ____returnValue) -- 1840
		end -- 1840
	end) -- 1840
end -- 1808
return ____exports -- 1808