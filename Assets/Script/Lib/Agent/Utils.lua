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
function ____exports.safeJsonDecode(text) -- 492
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 493
	if value == nil then -- 493
		return value, err -- 495
	end -- 495
	return sanitizeJSONValue(value), err -- 497
end -- 492
function normalizeReasoningEffort(value) -- 1350
	if type(value) ~= "string" then -- 1350
		return nil -- 1351
	end -- 1351
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1352
	return normalized ~= "" and normalized or nil -- 1353
end -- 1353
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1364
	if not customOptions then -- 1364
		return options -- 1368
	end -- 1368
	local merged = __TS__ObjectAssign({}, options) -- 1369
	for key in pairs(customOptions) do -- 1370
		do -- 1370
			if key == "auxiliaryOptions" or key == "visionModel" then -- 1370
				goto __continue305 -- 1373
			end -- 1373
			if key == "tools" and options.tools ~= nil then -- 1373
				goto __continue305 -- 1375
			end -- 1375
			local value = customOptions[key] -- 1376
			if value == json.null then -- 1376
				__TS__Delete(merged, key) -- 1378
			else -- 1378
				merged[key] = value -- 1380
			end -- 1380
		end -- 1380
		::__continue305:: -- 1380
	end -- 1380
	return merged -- 1383
end -- 1364
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
local function encodeStableJSONValue(value, emptyAsArray, depth) -- 462
	if depth > 128 then -- 462
		error("Too many nested JSON values") -- 463
	end -- 463
	if __TS__ArrayIsArray(value) then -- 463
		return ("[" .. table.concat( -- 465
			__TS__ArrayMap( -- 465
				value, -- 465
				function(____, item) return encodeStableJSONValue(item, emptyAsArray, depth + 1) end -- 465
			), -- 465
			"," -- 465
		)) .. "]" -- 465
	end -- 465
	if type(value) == "table" then -- 465
		local record = value -- 468
		local keys = __TS__ObjectKeys(record) -- 469
		if #keys == 0 then -- 469
			return emptyAsArray and "[]" or "{}" -- 470
		end -- 470
		local fields = {} -- 471
		__TS__ArraySort(keys) -- 472
		for ____, key in ipairs(keys) do -- 473
			if type(key) ~= "string" then -- 473
				error("JSON object keys must be strings") -- 474
			end -- 474
			local name = encodeStableJSONValue(key, emptyAsArray, depth + 1) -- 475
			fields[#fields + 1] = (name .. ":") .. encodeStableJSONValue(record[key], emptyAsArray, depth + 1) -- 476
		end -- 476
		return ("{" .. table.concat(fields, ",")) .. "}" -- 478
	end -- 478
	local encoded, err = ____exports.safeJsonEncode(value, false, emptyAsArray) -- 480
	if encoded == nil then -- 480
		error(err or "JSON value could not be encoded") -- 481
	end -- 481
	return encoded -- 482
end -- 462
--- Keep nested schema and message fields stable when Lua's hash seed changes.
function ____exports.safeStableJsonEncode(value, emptyAsArray) -- 486
	if emptyAsArray == nil then -- 486
		emptyAsArray = true -- 486
	end -- 486
	local ok, result = pcall(function() return encodeStableJSONValue(value, emptyAsArray, 0) end) -- 487
	if ok then -- 487
		return result, nil -- 488
	end -- 488
	return nil, tostring(result) -- 489
end -- 486
local function isPlainRecord(value) -- 500
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 501
end -- 500
local function normalizeLLMJSONResponse(text) -- 504
	return __TS__StringTrim(text) -- 505
end -- 504
local function utf8TakeHead(text, maxChars) -- 508
	if maxChars <= 0 or text == "" then -- 508
		return "" -- 509
	end -- 509
	local nextPos = utf8.offset(text, maxChars + 1) -- 510
	if nextPos == nil then -- 510
		return text -- 511
	end -- 511
	return string.sub(text, 1, nextPos - 1) -- 512
end -- 508
local function utf8TakeTail(text, maxChars) -- 515
	if maxChars <= 0 or text == "" then -- 515
		return "" -- 516
	end -- 516
	local charLen = utf8.len(text) -- 517
	if charLen == nil or charLen <= maxChars then -- 517
		return text -- 518
	end -- 518
	local startChar = math.max(1, charLen - maxChars + 1) -- 519
	local startPos = utf8.offset(text, startChar) -- 520
	if startPos == nil then -- 520
		return text -- 521
	end -- 521
	return string.sub(text, startPos) -- 522
end -- 515
function ____exports.estimateTextTokens(text) -- 525
	if text == "" then -- 525
		return 0 -- 526
	end -- 526
	return App:estimateTokens(text) -- 527
end -- 525
local function estimateMessagesTokens(messages) -- 530
	local total = 0 -- 531
	do -- 531
		local i = 0 -- 532
		while i < #messages do -- 532
			local message = messages[i + 1] -- 533
			total = total + 8 -- 534
			total = total + ____exports.estimateTextTokens(message.role or "") -- 535
			total = total + ____exports.estimateTextTokens(message.content or "") -- 536
			total = total + ____exports.estimateTextTokens(message.name or "") -- 537
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 538
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 539
			local toolCallsText = ____exports.safeStableJsonEncode(message.tool_calls or ({})) -- 540
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 541
			i = i + 1 -- 532
		end -- 532
	end -- 532
	return total -- 543
end -- 530
local function estimateOptionsTokens(options) -- 546
	local text = ____exports.safeStableJsonEncode(options) -- 547
	return text and ____exports.estimateTextTokens(text) or 0 -- 548
end -- 546
local function getReservedOutputTokens(options, contextWindow) -- 551
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 552
	if explicitMax > 0 then -- 552
		return math.max(256, explicitMax) -- 557
	end -- 557
	return math.max( -- 558
		1024, -- 558
		math.floor(contextWindow * 0.2) -- 558
	) -- 558
end -- 551
--- Plan an Agent decision without treating its configured maximum output as used input.
function ____exports.planAgentDecisionRequest(messages, options, config) -- 562
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 563
	local requestOptions = __TS__ObjectAssign( -- 564
		{}, -- 564
		____exports.applyCustomLLMOptions(options, config.customOptions) -- 564
	) -- 564
	local outputField = type(requestOptions.max_completion_tokens) == "number" and "max_completion_tokens" or "max_tokens" -- 565
	local configuredOutput = requestOptions[outputField] -- 566
	local outputCeiling = type(configuredOutput) == "number" and configuredOutput >= 1 and math.floor(configuredOutput) or getReservedOutputTokens({}, contextWindow) -- 567
	__TS__Delete(requestOptions, "max_tokens") -- 571
	__TS__Delete(requestOptions, "max_completion_tokens") -- 572
	requestOptions[outputField] = outputCeiling -- 573
	local messagesTokens = estimateMessagesTokens(messages) -- 574
	local structuralOverhead = math.max(256, #messages * 16) -- 575
	local fixedTokens = estimateOptionsTokens(requestOptions) + structuralOverhead -- 576
	local usedTokens = messagesTokens + fixedTokens -- 577
	local safetyMargin = 256 -- 578
	local minimumOutput = math.max( -- 579
		256, -- 579
		math.min(1024, outputCeiling) -- 579
	) -- 579
	local inputBudget = math.max(0, contextWindow - fixedTokens - safetyMargin - minimumOutput) -- 580
	local outputLimit = math.min( -- 581
		outputCeiling, -- 581
		math.max(0, contextWindow - usedTokens - safetyMargin) -- 581
	) -- 581
	requestOptions[outputField] = outputLimit -- 582
	return { -- 583
		options = requestOptions, -- 583
		contextWindow = contextWindow, -- 583
		messagesTokens = messagesTokens, -- 583
		structuralOverhead = structuralOverhead, -- 583
		usedTokens = usedTokens, -- 583
		inputBudget = inputBudget, -- 583
		outputLimit = outputLimit -- 583
	} -- 583
end -- 562
function ____exports.getInputTokenBudget(messages, options, config) -- 586
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 587
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 590
	local optionTokens = estimateOptionsTokens(options) -- 591
	local structuralOverhead = math.max(256, #messages * 16) -- 592
	return math.max(0, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 593
end -- 586
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 596
	if budgetTokens <= 0 or text == "" then -- 596
		return "" -- 597
	end -- 597
	local estimated = ____exports.estimateTextTokens(text) -- 598
	if estimated <= budgetTokens then -- 598
		return text -- 599
	end -- 599
	local marker = "\n...\n" -- 603
	if ____exports.estimateTextTokens(marker) > budgetTokens then -- 603
		return "" -- 604
	end -- 604
	local characters = utf8.len(text) -- 605
	if characters == nil then -- 605
		return "" -- 606
	end -- 606
	local low = 0 -- 607
	local high = characters -- 608
	local best = marker -- 609
	while low <= high do -- 609
		local keep = math.floor((low + high) / 2) -- 611
		local head = math.floor(keep * 0.35) -- 612
		local candidate = (utf8TakeHead(text, head) .. marker) .. utf8TakeTail(text, keep - head) -- 613
		if ____exports.estimateTextTokens(candidate) <= budgetTokens then -- 613
			best = candidate -- 615
			low = keep + 1 -- 616
		else -- 616
			high = keep - 1 -- 618
		end -- 618
	end -- 618
	return best -- 621
end -- 596
local function isXMLWhitespaceChar(ch) -- 624
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 625
end -- 624
local function findLineStart(value, from) -- 628
	local i = from -- 629
	while i >= 0 do -- 629
		if __TS__StringAccess(value, i) == "\n" then -- 629
			return i + 1 -- 631
		end -- 631
		i = i - 1 -- 632
	end -- 632
	return 0 -- 634
end -- 628
local function findLastLiteral(text, needle) -- 637
	if needle == "" then -- 637
		return #text -- 638
	end -- 638
	local last = -1 -- 639
	local from = 0 -- 640
	while from <= #text - #needle do -- 640
		local pos = (string.find( -- 642
			text, -- 642
			needle, -- 642
			math.max(from + 1, 1), -- 642
			true -- 642
		) or 0) - 1 -- 642
		if pos < 0 then -- 642
			break -- 643
		end -- 643
		last = pos -- 644
		from = pos + 1 -- 645
	end -- 645
	return last -- 647
end -- 637
local function unwrapXMLRawText(text) -- 650
	local trimmed = __TS__StringTrim(text) -- 651
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 651
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 653
	end -- 653
	return text -- 655
end -- 650
local function readSimpleXMLTagName(source, openStart, openEnd) -- 658
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 659
	if rawTag == "" then -- 659
		return { -- 661
			success = false, -- 661
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 661
		} -- 661
	end -- 661
	local selfClosing = false -- 663
	local tagText = rawTag -- 664
	if __TS__StringEndsWith(tagText, "/") then -- 664
		selfClosing = true -- 666
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 667
	end -- 667
	local tagName = "" -- 669
	do -- 669
		local i = 0 -- 670
		while i < #tagText do -- 670
			local ch = __TS__StringAccess(tagText, i) -- 671
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 671
				break -- 672
			end -- 672
			tagName = tagName .. ch -- 673
			i = i + 1 -- 670
		end -- 670
	end -- 670
	if tagName == "" then -- 670
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 676
	end -- 676
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 678
end -- 658
local function findMatchingXMLClose(source, tagName, contentStart) -- 681
	local sameOpenPrefix = "<" .. tagName -- 682
	local sameCloseToken = ("</" .. tagName) .. ">" -- 683
	local pos = contentStart -- 684
	local depth = 1 -- 685
	while pos < #source do -- 685
		do -- 685
			local lt = (string.find( -- 687
				source, -- 687
				"<", -- 687
				math.max(pos + 1, 1), -- 687
				true -- 687
			) or 0) - 1 -- 687
			if lt < 0 then -- 687
				break -- 688
			end -- 688
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 688
				local cdataEnd = (string.find( -- 690
					source, -- 690
					"]]>", -- 690
					math.max(lt + 9 + 1, 1), -- 690
					true -- 690
				) or 0) - 1 -- 690
				if cdataEnd < 0 then -- 690
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 691
				end -- 691
				pos = cdataEnd + 3 -- 692
				goto __continue168 -- 693
			end -- 693
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 696
					source, -- 696
					"-->",
					math.max(lt + 4 + 1, 1), -- 696
					true -- 696
				) or 0) - 1 -- 696
				if commentEnd < 0 then -- 696
					return {success = false, message = "invalid xml: unterminated comment"} -- 697
				end -- 697
				pos = commentEnd + 3 -- 698
				goto __continue168 -- 699
			end -- 699
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 699
				depth = depth - 1 -- 702
				if depth == 0 then -- 702
					return {success = true, closeStart = lt} -- 703
				end -- 703
				pos = lt + #sameCloseToken -- 704
				goto __continue168 -- 705
			end -- 705
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 705
				local openEnd = (string.find( -- 708
					source, -- 708
					">", -- 708
					math.max(lt + 1, 1), -- 708
					true -- 708
				) or 0) - 1 -- 708
				if openEnd < 0 then -- 708
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 709
				end -- 709
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 710
				if not tagInfo.success then -- 710
					return tagInfo -- 711
				end -- 711
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 711
					depth = depth + 1 -- 713
				end -- 713
				pos = openEnd + 1 -- 715
				goto __continue168 -- 716
			end -- 716
			local genericEnd = (string.find( -- 718
				source, -- 718
				">", -- 718
				math.max(lt + 1, 1), -- 718
				true -- 718
			) or 0) - 1 -- 718
			if genericEnd < 0 then -- 718
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 719
			end -- 719
			pos = genericEnd + 1 -- 720
		end -- 720
		::__continue168:: -- 720
	end -- 720
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 722
end -- 681
function ____exports.extractXMLFromText(text) -- 725
	local source = __TS__StringTrim(text) -- 726
	local function extractFencedBlock(fence) -- 727
		if not __TS__StringStartsWith(source, fence) then -- 727
			return nil -- 728
		end -- 728
		local firstLineEnd = (string.find( -- 729
			source, -- 729
			"\n", -- 729
			math.max(1, 1), -- 729
			true -- 729
		) or 0) - 1 -- 729
		if firstLineEnd < 0 then -- 729
			return nil -- 730
		end -- 730
		local searchPos = firstLineEnd + 1 -- 731
		local closingFencePositions = {} -- 732
		while searchPos < #source do -- 732
			local ____end = (string.find( -- 734
				source, -- 734
				"```", -- 734
				math.max(searchPos + 1, 1), -- 734
				true -- 734
			) or 0) - 1 -- 734
			if ____end < 0 then -- 734
				break -- 735
			end -- 735
			local lineStart = findLineStart(source, ____end - 1) -- 736
			local lineEnd = (string.find( -- 737
				source, -- 737
				"\n", -- 737
				math.max(____end + 1, 1), -- 737
				true -- 737
			) or 0) - 1 -- 737
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 738
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 738
				closingFencePositions[#closingFencePositions + 1] = ____end -- 740
			end -- 740
			searchPos = ____end + 1 -- 742
		end -- 742
		do -- 742
			local i = #closingFencePositions - 1 -- 744
			while i >= 0 do -- 744
				do -- 744
					local closingFencePos = closingFencePositions[i + 1] -- 745
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 746
					if afterFence ~= "" then -- 746
						goto __continue189 -- 747
					end -- 747
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 748
				end -- 748
				::__continue189:: -- 748
				i = i - 1 -- 744
			end -- 744
		end -- 744
		return nil -- 750
	end -- 727
	local xmlBlock = extractFencedBlock("```xml") -- 752
	if xmlBlock ~= nil then -- 752
		return xmlBlock -- 753
	end -- 753
	local genericBlock = extractFencedBlock("```") -- 754
	if genericBlock ~= nil then -- 754
		return genericBlock -- 755
	end -- 755
	return source -- 756
end -- 725
function ____exports.parseSimpleXMLChildren(source) -- 759
	local result = {} -- 760
	local pos = 0 -- 761
	while pos < #source do -- 761
		do -- 761
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 761
				pos = pos + 1 -- 763
			end -- 763
			if pos >= #source then -- 763
				break -- 764
			end -- 764
			if __TS__StringAccess(source, pos) ~= "<" then -- 764
				return { -- 766
					success = false, -- 766
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 766
				} -- 766
			end -- 766
			if __TS__StringStartsWith(source, "</", pos) then -- 766
				return { -- 769
					success = false, -- 769
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 769
				} -- 769
			end -- 769
			local openEnd = (string.find( -- 771
				source, -- 771
				">", -- 771
				math.max(pos + 1, 1), -- 771
				true -- 771
			) or 0) - 1 -- 771
			if openEnd < 0 then -- 771
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 773
			end -- 773
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 775
			if not tagInfo.success then -- 775
				return tagInfo -- 776
			end -- 776
			if tagInfo.selfClosing then -- 776
				result[tagInfo.tagName] = "" -- 778
				pos = openEnd + 1 -- 779
				goto __continue194 -- 780
			end -- 780
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 782
			if not closeRes.success then -- 782
				return closeRes -- 783
			end -- 783
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 784
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 785
			pos = closeRes.closeStart + #closeToken -- 786
		end -- 786
		::__continue194:: -- 786
	end -- 786
	return {success = true, obj = result} -- 788
end -- 759
function ____exports.parseXMLObjectFromText(text, rootTag) -- 791
	local xmlText = ____exports.extractXMLFromText(text) -- 792
	local rootOpen = ("<" .. rootTag) .. ">" -- 793
	local rootClose = ("</" .. rootTag) .. ">" -- 794
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 795
	local ____end = findLastLiteral(xmlText, rootClose) -- 796
	if start < 0 or ____end < start then -- 796
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 798
	end -- 798
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 800
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 801
	if beforeRoot ~= "" or afterRoot ~= "" then -- 801
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 803
	end -- 803
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 805
	return ____exports.parseSimpleXMLChildren(rootContent) -- 806
end -- 791
function ____exports.fitMessagesToContext(messages, options, config) -- 809
	local modelName = string.lower(config.model) -- 816
	local shouldEchoReasoningContent = __TS__ArraySome( -- 817
		messages, -- 817
		function(____, message) return type(message.reasoning_content) == "string" end -- 817
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 817
	local cloned = __TS__ArrayMap( -- 821
		messages, -- 821
		function(____, message) -- 821
			local clonedMessage = __TS__ObjectAssign({}, message) -- 822
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 822
				clonedMessage.reasoning_content = "" -- 828
			end -- 828
			return clonedMessage -- 830
		end -- 821
	) -- 821
	local budgetTokens = ____exports.getInputTokenBudget(cloned, options, config) -- 832
	local originalTokens = estimateMessagesTokens(cloned) -- 833
	if originalTokens <= budgetTokens then -- 833
		return { -- 835
			messages = cloned, -- 836
			trimmed = false, -- 837
			originalTokens = originalTokens, -- 838
			fittedTokens = originalTokens, -- 839
			budgetTokens = budgetTokens -- 840
		} -- 840
	end -- 840
	local function roleOverhead(message) -- 844
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 844
	end -- 844
	local fixedOverhead = 0 -- 845
	local contentIndexes = {} -- 846
	do -- 846
		local i = 0 -- 847
		while i < #cloned do -- 847
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 848
			contentIndexes[#contentIndexes + 1] = i -- 849
			i = i + 1 -- 847
		end -- 847
	end -- 847
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 851
	if #contentIndexes == 1 then -- 851
		local idx = contentIndexes[1] -- 853
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 854
		local fittedTokens = estimateMessagesTokens(cloned) -- 855
		return { -- 856
			messages = cloned, -- 857
			trimmed = true, -- 858
			originalTokens = originalTokens, -- 859
			fittedTokens = fittedTokens, -- 860
			budgetTokens = budgetTokens -- 861
		} -- 861
	end -- 861
	local nonSystemIndexes = {} -- 865
	local systemIndexes = {} -- 866
	do -- 866
		local i = 0 -- 867
		while i < #cloned do -- 867
			if cloned[i + 1].role == "system" then -- 867
				systemIndexes[#systemIndexes + 1] = i -- 868
			else -- 868
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 869
			end -- 869
			i = i + 1 -- 867
		end -- 867
	end -- 867
	local ____array_8 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 867
	__TS__SparseArrayPush( -- 867
		____array_8, -- 867
		table.unpack(systemIndexes) -- 871
	) -- 871
	local priorityIndexes = {__TS__SparseArraySpread(____array_8)} -- 871
	local remainingContentBudget = contentBudget -- 872
	do -- 872
		local i = #priorityIndexes - 1 -- 873
		while i >= 0 do -- 873
			local idx = priorityIndexes[i + 1] -- 874
			local message = cloned[idx + 1] -- 875
			local minBudget = message.role == "system" and 96 or 192 -- 876
			local target = math.max( -- 877
				minBudget, -- 877
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 877
			) -- 877
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 878
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 879
			remainingContentBudget = math.max(0, remainingContentBudget) -- 880
			i = i - 1 -- 873
		end -- 873
	end -- 873
	local fittedTokens = estimateMessagesTokens(cloned) -- 883
	if fittedTokens > budgetTokens then -- 883
		do -- 883
			local i = 0 -- 885
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 885
				local idx = priorityIndexes[i + 1] -- 886
				local message = cloned[idx + 1] -- 887
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 888
				local excess = fittedTokens - budgetTokens -- 889
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 890
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 891
				fittedTokens = estimateMessagesTokens(cloned) -- 892
				i = i + 1 -- 885
			end -- 885
		end -- 885
	end -- 885
	if fittedTokens > budgetTokens then -- 885
		do -- 885
			local i = 0 -- 896
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 896
				do -- 896
					local idx = priorityIndexes[i + 1] -- 897
					if cloned[idx + 1].role == "system" then -- 897
						goto __continue226 -- 898
					end -- 898
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 899
					fittedTokens = estimateMessagesTokens(cloned) -- 900
				end -- 900
				::__continue226:: -- 900
				i = i + 1 -- 896
			end -- 896
		end -- 896
	end -- 896
	return { -- 903
		messages = cloned, -- 904
		trimmed = true, -- 905
		originalTokens = originalTokens, -- 906
		fittedTokens = fittedTokens, -- 907
		budgetTokens = budgetTokens -- 908
	} -- 908
end -- 809
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken, studioGateway) -- 912
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 924
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 925
	local data = __TS__ObjectAssign({model = model}, requestOptions, {messages = messages, stream = stream}) -- 926
	local studioRequestId = studioGateway and ____exports.createStudioModelRequestId() or nil -- 932
	if stopToken == nil then -- 932
		stopToken = {stopped = false} -- 933
	end -- 933
	return __TS__New( -- 934
		__TS__Promise, -- 934
		function(____, resolve, reject) -- 934
			local requestId = 0 -- 935
			local settled = false -- 936
			local function finishResolve(text) -- 937
				if settled then -- 937
					return -- 938
				end -- 938
				settled = true -- 939
				resolve(nil, text) -- 940
			end -- 937
			local function finishReject(err) -- 942
				if settled then -- 942
					return -- 943
				end -- 943
				settled = true -- 944
				reject(nil, err) -- 945
			end -- 942
			Director.systemScheduler:schedule(function() -- 947
				if not settled then -- 947
					if stopToken.stopped then -- 947
						if requestId ~= 0 then -- 947
							HttpClient:cancel(requestId) -- 951
							requestId = 0 -- 952
						end -- 952
						finishReject("request cancelled") -- 954
						return true -- 955
					end -- 955
					return false -- 957
				end -- 957
				return true -- 959
			end) -- 947
			Director.systemScheduler:schedule(once(function() -- 961
				emit( -- 962
					"LLM_IN", -- 962
					table.concat( -- 962
						__TS__ArrayMap( -- 962
							messages, -- 962
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 962
						), -- 962
						"\n" -- 962
					) -- 962
				) -- 962
				local jsonStr, err = ____exports.safeStableJsonEncode(data) -- 963
				if jsonStr ~= nil then -- 963
					local headers = { -- 965
						"Authorization: Bearer " .. apiKey, -- 966
						"Content-Type: application/json", -- 967
						receiver and "Accept: text/event-stream" or "Accept: application/json", -- 968
						table.unpack(studioRequestId and ({"X-Studio-Model-Request-Id: " .. studioRequestId}) or ({})) -- 969
					} -- 969
					requestId = receiver and HttpClient:post( -- 971
						url, -- 972
						headers, -- 972
						jsonStr, -- 972
						requestTimeout, -- 972
						function(data) -- 972
							if stopToken.stopped then -- 972
								return true -- 973
							end -- 973
							return receiver(data) -- 974
						end, -- 972
						function(data) -- 975
							requestId = 0 -- 976
							if data ~= nil then -- 976
								finishResolve(data) -- 978
							else -- 978
								finishReject("failed to get http response") -- 980
							end -- 980
						end -- 975
					) or HttpClient:post( -- 975
						url, -- 983
						headers, -- 983
						jsonStr, -- 983
						requestTimeout, -- 983
						function(data) -- 983
							requestId = 0 -- 984
							if stopToken.stopped then -- 984
								finishReject("request cancelled") -- 986
								return -- 987
							end -- 987
							if data ~= nil then -- 987
								finishResolve(data) -- 990
							else -- 990
								finishReject("failed to get http response") -- 992
							end -- 992
						end -- 983
					) -- 983
					if requestId == 0 then -- 983
						finishReject("failed to schedule http request") -- 996
					elseif stopToken.stopped then -- 996
						HttpClient:cancel(requestId) -- 998
						requestId = 0 -- 999
						finishReject("request cancelled") -- 1000
					end -- 1000
				else -- 1000
					finishReject(err) -- 1003
				end -- 1003
			end)) -- 961
		end -- 934
	) -- 934
end -- 912
function ____exports.createSSEJSONParser(opts) -- 1013
	local buffer = "" -- 1018
	local eventDataLines = {} -- 1019
	local function flushEventIfAny() -- 1021
		if #eventDataLines == 0 then -- 1021
			return -- 1022
		end -- 1022
		local dataPayload = table.concat(eventDataLines, "\n") -- 1024
		eventDataLines = {} -- 1025
		if dataPayload == "[DONE]" then -- 1025
			local ____opt_9 = opts.onDone -- 1025
			if ____opt_9 ~= nil then -- 1025
				____opt_9(dataPayload) -- 1028
			end -- 1028
			return -- 1029
		end -- 1029
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 1032
		if err == nil then -- 1032
			opts.onJSON(obj, dataPayload) -- 1034
		else -- 1034
			local ____opt_11 = opts.onError -- 1034
			if ____opt_11 ~= nil then -- 1034
				____opt_11(err, {raw = dataPayload}) -- 1036
			end -- 1036
		end -- 1036
	end -- 1021
	local function append(chunk) -- 1040
		buffer = buffer .. chunk -- 1041
	end -- 1040
	local function drain(maxLines) -- 1044
		local processedLines = 0 -- 1045
		while maxLines == nil or processedLines < maxLines do -- 1045
			do -- 1045
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 1047
				if nl < 0 then -- 1047
					break -- 1048
				end -- 1048
				processedLines = processedLines + 1 -- 1049
				local line = __TS__StringSlice(buffer, 0, nl) -- 1051
				buffer = __TS__StringSlice(buffer, nl + 1) -- 1052
				if __TS__StringEndsWith(line, "\r") then -- 1052
					line = string.sub(line, 1, -2) -- 1054
				end -- 1054
				if line == "" then -- 1054
					flushEventIfAny() -- 1057
					goto __continue261 -- 1058
				end -- 1058
				if __TS__StringStartsWith(line, ":") then -- 1058
					goto __continue261 -- 1062
				end -- 1062
				if __TS__StringStartsWith(line, "data:") then -- 1062
					local v = string.sub(line, 6) -- 1065
					if __TS__StringStartsWith(v, " ") then -- 1065
						v = string.sub(v, 2) -- 1066
					end -- 1066
					eventDataLines[#eventDataLines + 1] = v -- 1067
					goto __continue261 -- 1068
				end -- 1068
			end -- 1068
			::__continue261:: -- 1068
		end -- 1068
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0 -- 1071
	end -- 1044
	local function feed(chunk) -- 1074
		append(chunk) -- 1075
		drain() -- 1076
	end -- 1074
	local function ____end() -- 1079
		if #buffer > 0 then -- 1079
			local line = buffer -- 1081
			buffer = "" -- 1082
			if __TS__StringEndsWith(line, "\r") then -- 1082
				line = string.sub(line, 1, -2) -- 1083
			end -- 1083
			if __TS__StringStartsWith(line, "data:") then -- 1083
				local v = string.sub(line, 6) -- 1086
				if __TS__StringStartsWith(v, " ") then -- 1086
					v = string.sub(v, 2) -- 1087
				end -- 1087
				eventDataLines[#eventDataLines + 1] = v -- 1088
			end -- 1088
		end -- 1088
		flushEventIfAny() -- 1091
	end -- 1079
	local function discard() -- 1094
		buffer = "" -- 1095
		eventDataLines = {} -- 1096
	end -- 1094
	return { -- 1099
		append = append, -- 1099
		drain = drain, -- 1099
		feed = feed, -- 1099
		["end"] = ____end, -- 1099
		discard = discard -- 1099
	} -- 1099
end -- 1013
local SSE_PARSE_LINES_PER_FRAME = 256 -- 1102
local function createScheduledSSEJSONParser(opts, isCancelled) -- 1104
	local parser = ____exports.createSSEJSONParser(opts) -- 1108
	local inputFinished = false -- 1109
	local settled = false -- 1110
	local resolveFinished -- 1111
	local finished = __TS__New( -- 1112
		__TS__Promise, -- 1112
		function(____, resolve) -- 1112
			resolveFinished = resolve -- 1113
		end -- 1112
	) -- 1112
	local function settle() -- 1115
		if settled then -- 1115
			return -- 1116
		end -- 1116
		settled = true -- 1117
		if resolveFinished ~= nil then -- 1117
			resolveFinished() -- 1118
		end -- 1118
	end -- 1115
	Director.systemScheduler:schedule(function() -- 1120
		if settled then -- 1120
			return true -- 1121
		end -- 1121
		if isCancelled and isCancelled() then -- 1121
			parser.discard() -- 1123
			settle() -- 1124
			return true -- 1125
		end -- 1125
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME) -- 1127
		if inputFinished and not hasMoreCompleteLines then -- 1127
			parser["end"]() -- 1129
			settle() -- 1130
			return true -- 1131
		end -- 1131
		return false -- 1133
	end) -- 1120
	return { -- 1135
		append = parser.append, -- 1136
		finish = function() -- 1137
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1137
				inputFinished = true -- 1138
				__TS__Await(finished) -- 1139
			end) -- 1139
		end, -- 1137
		cancel = function() -- 1141
			parser.discard() -- 1142
			settle() -- 1143
		end -- 1141
	} -- 1141
end -- 1104
function ____exports.extractLLMTokenUsage(response) -- 1239
	local usage = response and response.usage -- 1240
	if not usage or type(usage) ~= "table" then -- 1240
		return nil -- 1241
	end -- 1241
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1242
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1245
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1245
		return nil -- 1248
	end -- 1248
	local ____temp_24 -- 1249
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1249
		____temp_24 = usage.prompt_cache_hit_tokens -- 1250
	else -- 1250
		local ____temp_23 -- 1251
		local ____opt_19 = usage.prompt_tokens_details -- 1251
		if type(____opt_19 and ____opt_19.cached_tokens) == "number" then -- 1251
			____temp_23 = usage.prompt_tokens_details.cached_tokens -- 1252
		else -- 1252
			local ____opt_21 = usage.input_tokens_details -- 1252
			____temp_23 = type(____opt_21 and ____opt_21.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1253
		end -- 1253
		____temp_24 = ____temp_23 -- 1251
	end -- 1251
	local cachedInputTokens = ____temp_24 -- 1249
	local ____inputTokens_27 = inputTokens -- 1257
	local ____outputTokens_28 = outputTokens -- 1258
	local ____temp_29 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1259
	local ____temp_30 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1260
	local ____temp_31 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1261
	local ____opt_25 = usage.completion_tokens_details -- 1261
	return { -- 1256
		inputTokens = ____inputTokens_27, -- 1257
		outputTokens = ____outputTokens_28, -- 1258
		totalTokens = ____temp_29, -- 1259
		cachedInputTokens = ____temp_30, -- 1260
		cacheMissInputTokens = ____temp_31, -- 1261
		reasoningOutputTokens = type(____opt_25 and ____opt_25.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1264
	} -- 1264
end -- 1239
function ____exports.validateAgentLLMConfig(config) -- 1308
	local ____opt_32 = config.customOptions -- 1308
	local visionModel = ____opt_32 and ____opt_32.visionModel -- 1309
	if visionModel ~= nil and visionModel ~= json.null and type(visionModel) ~= "string" then -- 1309
		return {success = false, message = "视觉模型名称 visionModel 必须是字符串；留空使用默认行为。"} -- 1311
	end -- 1311
	local ____opt_34 = config.customOptions -- 1311
	local auxiliaryOptions = ____opt_34 and ____opt_34.auxiliaryOptions -- 1313
	if auxiliaryOptions == nil then -- 1313
		return {success = true} -- 1314
	end -- 1314
	local emptyOptions = type(auxiliaryOptions) == "table" and auxiliaryOptions ~= nil and auxiliaryOptions ~= json.null and #__TS__ObjectKeys(auxiliaryOptions) == 0 -- 1315
	if isPlainRecord(auxiliaryOptions) or emptyOptions then -- 1315
		return {success = true} -- 1321
	end -- 1321
	return {success = false, message = "LLM 配置的 auxiliaryOptions 如有填写必须是对象（可以为空），请检查 LLM 配置"} -- 1323
end -- 1308
local function normalizeContextWindow(value) -- 1329
	if type(value) == "number" and value > 0 then -- 1329
		return math.floor(value) -- 1331
	end -- 1331
	return 64000 -- 1333
end -- 1329
local function normalizeLLMTemperature(value) -- 1336
	if type(value) == "number" then -- 1336
		return math.max( -- 1338
			0, -- 1338
			math.min(2, value) -- 1338
		) -- 1338
	end -- 1338
	return 0.1 -- 1340
end -- 1336
local function normalizeLLMMaxTokens(value) -- 1343
	if type(value) == "number" then -- 1343
		return math.max( -- 1345
			1, -- 1345
			math.floor(value) -- 1345
		) -- 1345
	end -- 1345
	return AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1347
end -- 1343
local function normalizeLLMCustomOptions(value) -- 1356
	if type(value) ~= "string" then -- 1356
		return nil -- 1357
	end -- 1357
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1358
	if text == "" then -- 1358
		return nil -- 1359
	end -- 1359
	local decoded = ____exports.safeJsonDecode(text) -- 1360
	return isPlainRecord(decoded) and decoded or nil -- 1361
end -- 1356
function ____exports.getLLMConfigRecords() -- 1386
	upgradeLLMConfig() -- 1387
	local rows = DB:query("select * from LLMConfig", true) -- 1388
	local records = {} -- 1389
	if rows and #rows > 1 then -- 1389
		do -- 1389
			local i = 1 -- 1391
			while i < #rows do -- 1391
				local record = {} -- 1392
				do -- 1392
					local c = 0 -- 1393
					while c < #rows[i + 1] do -- 1393
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1394
						c = c + 1 -- 1393
					end -- 1393
				end -- 1393
				records[#records + 1] = record -- 1396
				i = i + 1 -- 1391
			end -- 1391
		end -- 1391
	end -- 1391
	return records -- 1399
end -- 1386
function ____exports.getLLMConfigSummaries() -- 1409
	return __TS__ArrayFlatMap( -- 1410
		____exports.getLLMConfigRecords(), -- 1410
		function(____, record) -- 1410
			local id = record.id -- 1411
			local name = record.name -- 1412
			local model = record.model -- 1413
			if type(id) ~= "number" or type(name) ~= "string" or type(model) ~= "string" then -- 1413
				return {} -- 1414
			end -- 1414
			return {{id = id, name = name, model = model, active = record.active ~= 0}} -- 1415
		end -- 1410
	) -- 1410
end -- 1409
local function parseLLMConfig(config) -- 1419
	if not config then -- 1419
		return {success = false, message = "LLM config not found"} -- 1421
	end -- 1421
	local ____config_36 = config -- 1423
	local id = ____config_36.id -- 1423
	local url = ____config_36.url -- 1423
	local model = ____config_36.model -- 1423
	local api_key = ____config_36.api_key -- 1423
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1423
		return {success = false, message = "got invalid LLM config"} -- 1425
	end -- 1425
	return { -- 1427
		success = true, -- 1428
		id = id, -- 1429
		config = { -- 1430
			url = url, -- 1431
			model = model, -- 1432
			apiKey = api_key, -- 1433
			contextWindow = normalizeContextWindow(config.context_window), -- 1434
			temperature = normalizeLLMTemperature(config.temperature), -- 1435
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1436
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1437
			customOptions = normalizeLLMCustomOptions(config.custom_options) -- 1438
		} -- 1438
	} -- 1438
end -- 1419
function ____exports.getSavedLLMConfigs() -- 1443
	local records = ____exports.getLLMConfigRecords() -- 1444
	__TS__ArraySort( -- 1446
		records, -- 1446
		function(____, a, b) -- 1446
			local activeOrder = __TS__Number(b.active ~= 0) - __TS__Number(a.active ~= 0) -- 1447
			return activeOrder ~= 0 and activeOrder or __TS__Number(a.id) - __TS__Number(b.id) -- 1448
		end -- 1446
	) -- 1446
	return __TS__ArrayFlatMap( -- 1450
		records, -- 1450
		function(____, record) -- 1450
			local result = parseLLMConfig(record) -- 1451
			return result.success and ({result.config}) or ({}) -- 1452
		end -- 1450
	) -- 1450
end -- 1443
function ____exports.getLLMConfig(configId) -- 1456
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1457
	if normalizedId == nil or normalizedId <= 0 then -- 1457
		return {success = false, message = "LLM config is not selected"} -- 1459
	end -- 1459
	return parseLLMConfig(__TS__ArrayFind( -- 1461
		____exports.getLLMConfigRecords(), -- 1461
		function(____, record) return record.id == normalizedId end -- 1461
	)) -- 1461
end -- 1456
function ____exports.getActiveLLMConfig() -- 1464
	local records = ____exports.getLLMConfigRecords() -- 1465
	local config = __TS__ArrayFind( -- 1466
		records, -- 1466
		function(____, r) return r.active ~= 0 end -- 1466
	) -- 1466
	if not config then -- 1466
		return {success = false, message = "no active LLM config"} -- 1468
	end -- 1468
	return parseLLMConfig(config) -- 1470
end -- 1464
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1473
	local callEvent -- 1479
	if event.id ~= nil then -- 1479
		local id = event.id -- 1481
		callEvent = { -- 1482
			id = nil, -- 1483
			onData = function(data) -- 1484
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1485
				return event.stopToken.stopped -- 1486
			end, -- 1484
			onCancel = function(reason) -- 1488
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1489
			end, -- 1488
			onDone = function() -- 1491
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1492
			end -- 1491
		} -- 1491
	else -- 1491
		callEvent = event -- 1496
	end -- 1496
	local ____callEvent_37 = callEvent -- 1498
	local onData = ____callEvent_37.onData -- 1498
	local onDone = ____callEvent_37.onDone -- 1498
	local ____callEvent_38 = callEvent -- 1499
	local onCancel = ____callEvent_38.onCancel -- 1499
	local config = llmConfig or (function() -- 1500
		local configRes = ____exports.getActiveLLMConfig() -- 1501
		if not configRes.success then -- 1501
			if onCancel then -- 1501
				onCancel(configRes.message) -- 1503
			end -- 1503
			return nil -- 1504
		end -- 1504
		return configRes.config -- 1506
	end)() -- 1500
	if not config then -- 1500
		return {success = false, message = "no active LLM config"} -- 1509
	end -- 1509
	local url = config.url -- 1509
	local model = config.model -- 1509
	local apiKey = config.apiKey -- 1509
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1512
	if fitted.fittedTokens > fitted.budgetTokens then -- 1512
		return {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."} -- 1514
	end -- 1514
	if fitted.trimmed then -- 1514
		____exports.Log( -- 1517
			"Warn", -- 1517
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1517
		) -- 1517
	end -- 1517
	local stopLLM = false -- 1519
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1520
	local parser = createScheduledSSEJSONParser( -- 1523
		{onJSON = function(obj) -- 1523
			local result = onData(obj) -- 1525
			if result then -- 1525
				stopLLM = true -- 1527
				streamStopToken.stopped = true -- 1528
				streamStopToken.reason = "LLM Stopped" -- 1529
			end -- 1529
		end}, -- 1524
		function() return streamStopToken.stopped end -- 1532
	); -- 1532
	(function() -- 1533
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1533
			local ____try = __TS__AsyncAwaiter(function() -- 1533
				local result = __TS__Await(postLLM( -- 1535
					fitted.messages, -- 1535
					url, -- 1535
					apiKey, -- 1535
					model, -- 1535
					options, -- 1535
					true, -- 1535
					config.customOptions, -- 1535
					function(data) -- 1535
						if stopLLM then -- 1535
							if onCancel then -- 1535
								onCancel("LLM Stopped") -- 1538
								onCancel = nil -- 1539
							end -- 1539
							return true -- 1541
						end -- 1541
						parser.append(data) -- 1543
						return false -- 1544
					end, -- 1535
					streamStopToken, -- 1545
					config.studioGateway -- 1545
				)) -- 1545
				__TS__Await(parser.finish()) -- 1546
				if onDone then -- 1546
					onDone(result) -- 1548
				end -- 1548
			end) -- 1548
			____try = ____try.catch( -- 1548
				____try, -- 1548
				function(____, e) -- 1548
					return __TS__AsyncAwaiter(function() -- 1548
						parser.cancel() -- 1551
						stopLLM = true -- 1552
						if onCancel then -- 1552
							onCancel(tostring(e)) -- 1554
							onCancel = nil -- 1555
						end -- 1555
					end) -- 1555
				end -- 1555
			) -- 1555
			__TS__Await(____try) -- 1534
		end) -- 1534
	end)() -- 1533
	return {success = true} -- 1559
end -- 1473
local function mergeStreamToolCall(target, delta) -- 1562
	if type(delta.id) == "string" and delta.id ~= "" then -- 1562
		target.id = delta.id -- 1564
	end -- 1564
	if type(delta.type) == "string" and delta.type ~= "" then -- 1564
		target.type = delta.type -- 1567
	end -- 1567
	if delta["function"] then -- 1567
		if target["function"] == nil then -- 1567
			target["function"] = {} -- 1570
		end -- 1570
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1570
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1572
		end -- 1572
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1572
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1575
		end -- 1575
	end -- 1575
end -- 1562
local function isToolCallComplete(tc) -- 1580
	if type(tc.id) ~= "string" or tc.id == "" then -- 1580
		return false -- 1581
	end -- 1581
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1581
		return false -- 1582
	end -- 1582
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1582
		return false -- 1583
	end -- 1583
	local args = tc["function"].arguments -- 1584
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1584
		return false -- 1585
	end -- 1585
	local decoded = ____exports.safeJsonDecode(args) -- 1586
	return decoded ~= nil -- 1587
end -- 1580
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1590
	local delta = choice.delta or ({}) -- 1591
	local fullMessage = choice.message or ({}) -- 1592
	local message = acc.message -- 1593
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1594
	if type(role) == "string" and role ~= "" then -- 1594
		message.role = role -- 1598
	end -- 1598
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1600
	if type(content) == "string" and content ~= "" then -- 1600
		message.content = (message.content or "") .. content -- 1604
	end -- 1604
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1606
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1606
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1610
	end -- 1610
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1612
	if #toolCalls > 0 then -- 1612
		if message.tool_calls == nil then -- 1612
			message.tool_calls = {} -- 1616
		end -- 1616
		do -- 1616
			local i = 0 -- 1617
			while i < #toolCalls do -- 1617
				local item = toolCalls[i + 1] -- 1618
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1619
				local ____message_tool_calls_39, ____temp_40 = message.tool_calls, index + 1 -- 1619
				if ____message_tool_calls_39[____temp_40] == nil then -- 1619
					____message_tool_calls_39[____temp_40] = {} -- 1622
				end -- 1622
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1623
				if onToolCallReady and emittedToolCallIds then -- 1623
					local tc = message.tool_calls[index + 1] -- 1625
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1625
						emittedToolCallIds[tc.id] = true -- 1627
						onToolCallReady(tc) -- 1628
					end -- 1628
				end -- 1628
				i = i + 1 -- 1617
			end -- 1617
		end -- 1617
	end -- 1617
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1617
		acc.finish_reason = choice.finish_reason -- 1634
	end -- 1634
end -- 1590
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1638
	local indexes = __TS__ArraySort( -- 1647
		__TS__ArrayFilter( -- 1647
			__TS__ArrayMap( -- 1647
				__TS__ObjectKeys(states), -- 1647
				function(____, key) return __TS__Number(key) end -- 1648
			), -- 1648
			function(____, index) return __TS__NumberIsFinite(index) end -- 1649
		), -- 1649
		function(____, a, b) return a - b end -- 1650
	) -- 1650
	return { -- 1651
		id = id, -- 1652
		created = created, -- 1653
		object = object, -- 1654
		model = model, -- 1655
		choices = __TS__ArrayMap( -- 1656
			indexes, -- 1656
			function(____, index) -- 1656
				local state = states[index] -- 1657
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1658
			end -- 1656
		), -- 1656
		usage = usage, -- 1669
		error = providerError -- 1670
	} -- 1670
end -- 1638
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1674
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1674
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1685
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1686
		local resolvedConfig = config or (function() -- 1689
			local configRes = ____exports.getActiveLLMConfig() -- 1690
			if not configRes.success then -- 1690
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1692
				return nil -- 1693
			end -- 1693
			return configRes.config -- 1695
		end)() -- 1689
		if not resolvedConfig then -- 1689
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1689
		end -- 1689
		local url = resolvedConfig.url -- 1689
		local model = resolvedConfig.model -- 1689
		local apiKey = resolvedConfig.apiKey -- 1689
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1701
		if fitted.fittedTokens > fitted.budgetTokens then -- 1701
			return ____awaiter_resolve(nil, {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."}) -- 1701
		end -- 1701
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1705
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1706
		local ____model_45 = model -- 1709
		local ____url_46 = url -- 1709
		local ____temp_47 = #messages -- 1709
		local ____tostring_42 = tostring -- 1709
		local ____options_max_tokens_41 = options.max_tokens -- 1709
		if ____options_max_tokens_41 == nil then -- 1709
			____options_max_tokens_41 = "unset" -- 1709
		end -- 1709
		local ____tostring_42_result_48 = ____tostring_42(____options_max_tokens_41) -- 1709
		local ____tostring_44 = tostring -- 1709
		local ____options_temperature_43 = options.temperature -- 1709
		if ____options_temperature_43 == nil then -- 1709
			____options_temperature_43 = "unset" -- 1709
		end -- 1709
		____exports.Log( -- 1709
			"Info", -- 1709
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_45) .. " url=") .. ____url_46) .. " messages=") .. tostring(____temp_47)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_42_result_48) .. " temperature=") .. ____tostring_44(____options_temperature_43)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1709
		) -- 1709
		if stopToken and stopToken.stopped then -- 1709
			local reason = stopToken.reason or "request cancelled" -- 1711
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1712
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1712
		end -- 1712
		local ____hasReturned, ____returnValue -- 1712
		local ____try = __TS__AsyncAwaiter(function() -- 1712
			local states = {} -- 1716
			local emittedToolCallIds = {} -- 1717
			local responseId = nil -- 1718
			local responseCreated = nil -- 1719
			local responseObject = nil -- 1720
			local providerError -- 1721
			local responseUsage -- 1722
			local httpChunkCount = 0 -- 1723
			local rawStreamBytes = 0 -- 1724
			local rawStreamPreview = "" -- 1725
			local sseJSONChunkCount = 0 -- 1726
			local choiceJSONChunkCount = 0 -- 1727
			local emptyChoicesChunkCount = 0 -- 1728
			local missingChoicesChunkCount = 0 -- 1729
			local parseErrorCount = 0 -- 1730
			local doneChunkSeen = false -- 1731
			local lastJSONPreview = "" -- 1732
			local parser = createScheduledSSEJSONParser( -- 1733
				{ -- 1733
					onJSON = function(obj, raw) -- 1734
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1735
						lastJSONPreview = previewText(raw, 500) -- 1736
						if not obj or type(obj) ~= "table" then -- 1736
							return -- 1738
						end -- 1738
						local chunk = obj -- 1740
						if chunk.error then -- 1740
							providerError = chunk.error -- 1742
							____exports.Log( -- 1743
								"Warn", -- 1743
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1743
							) -- 1743
							return -- 1744
						end -- 1744
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1746
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1747
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1748
						if chunk.usage and type(chunk.usage) == "table" then -- 1748
							responseUsage = chunk.usage -- 1750
						end -- 1750
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1752
						if not __TS__ArrayIsArray(chunk.choices) then -- 1752
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1754
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1754
								____exports.Log( -- 1756
									"Warn", -- 1756
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1756
								) -- 1756
							end -- 1756
						elseif #choices == 0 then -- 1756
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1759
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1759
								____exports.Log( -- 1761
									"Warn", -- 1761
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1761
								) -- 1761
							end -- 1761
						else -- 1761
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1764
						end -- 1764
						do -- 1764
							local i = 0 -- 1766
							while i < #choices do -- 1766
								local choice = choices[i + 1] -- 1767
								local index = type(choice.index) == "number" and choice.index or i -- 1768
								if states[index] == nil then -- 1768
									states[index] = {index = index, message = {role = "assistant"}} -- 1769
								end -- 1769
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1773
								i = i + 1 -- 1766
							end -- 1766
						end -- 1766
						if onChunk ~= nil then -- 1766
							onChunk( -- 1775
								buildStreamResponse( -- 1776
									states, -- 1776
									model, -- 1776
									responseId, -- 1776
									responseCreated, -- 1776
									responseObject, -- 1776
									providerError, -- 1776
									responseUsage -- 1776
								), -- 1776
								{ -- 1777
									id = chunk.id or "", -- 1778
									created = chunk.created or 0, -- 1779
									object = chunk.object or "", -- 1780
									model = chunk.model or model, -- 1781
									choices = choices -- 1782
								} -- 1782
							) -- 1782
						end -- 1782
					end, -- 1734
					onDone = function() -- 1786
						doneChunkSeen = true -- 1787
					end, -- 1786
					onError = function(err, context) -- 1789
						parseErrorCount = parseErrorCount + 1 -- 1790
						____exports.Log( -- 1791
							"Warn", -- 1791
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1791
						) -- 1791
					end -- 1789
				}, -- 1789
				function() return (stopToken and stopToken.stopped) == true end -- 1793
			) -- 1793
			local ____try = __TS__AsyncAwaiter(function() -- 1793
				__TS__Await(postLLM( -- 1795
					fitted.messages, -- 1795
					url, -- 1795
					apiKey, -- 1795
					model, -- 1795
					options, -- 1795
					true, -- 1795
					resolvedConfig.customOptions, -- 1795
					function(data) -- 1795
						if stopToken and stopToken.stopped then -- 1795
							return true -- 1796
						end -- 1796
						httpChunkCount = httpChunkCount + 1 -- 1797
						rawStreamBytes = rawStreamBytes + #data -- 1798
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1798
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1800
						end -- 1800
						parser.append(data) -- 1802
						return false -- 1803
					end, -- 1795
					stopToken, -- 1804
					resolvedConfig.studioGateway -- 1804
				)) -- 1804
				__TS__Await(parser.finish()) -- 1805
			end) -- 1805
			____try = ____try.catch( -- 1805
				____try, -- 1805
				function(____, e) -- 1805
					return __TS__AsyncAwaiter(function() -- 1805
						parser.cancel() -- 1807
						error(e, 0) -- 1808
					end) -- 1808
				end -- 1808
			) -- 1808
			__TS__Await(____try) -- 1794
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1794
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1811
				if rawResponse and type(rawResponse) == "table" then -- 1811
					local rawResponseObj = rawResponse -- 1813
					if rawResponseObj.error then -- 1813
						providerError = rawResponseObj.error -- 1815
						lastJSONPreview = previewText( -- 1816
							normalizeLLMJSONResponse(rawStreamPreview), -- 1816
							500 -- 1816
						) -- 1816
						____exports.Log( -- 1817
							"Warn", -- 1817
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1817
						) -- 1817
					end -- 1817
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1817
						responseUsage = rawResponseObj.usage -- 1820
					end -- 1820
				end -- 1820
			end -- 1820
			local response = buildStreamResponse( -- 1824
				states, -- 1824
				model, -- 1824
				responseId, -- 1824
				responseCreated, -- 1824
				responseObject, -- 1824
				providerError, -- 1824
				responseUsage -- 1824
			) -- 1824
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1825
			local choiceCount = response.choices and #response.choices or 0 -- 1826
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1827
			____exports.Log( -- 1828
				"Info", -- 1828
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1828
			) -- 1828
			if not doneChunkSeen then -- 1828
				local rawPreview = previewText( -- 1830
					____exports.sanitizeUTF8(rawStreamPreview), -- 1830
					1200 -- 1830
				) -- 1830
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1831
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1832
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1833
				____hasReturned = true -- 1834
				____returnValue = { -- 1834
					success = false, -- 1835
					message = message, -- 1836
					raw = rawStreamPreview, -- 1837
					response = response, -- 1838
					tokenUsage = tokenUsage -- 1839
				} -- 1839
				return -- 1834
			end -- 1834
			if not response.choices or #response.choices == 0 then -- 1834
				local providerMessage = providerError and providerError.message or "" -- 1843
				local providerType = providerError and providerError.type or "" -- 1844
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1845
				local details = table.concat( -- 1848
					__TS__ArrayFilter( -- 1848
						{providerType, providerCode}, -- 1848
						function(____, part) return part ~= "" end -- 1848
					), -- 1848
					"/" -- 1848
				) -- 1848
				local rawPreview = previewText( -- 1849
					____exports.sanitizeUTF8(rawStreamPreview), -- 1849
					1200 -- 1849
				) -- 1849
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1850
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1851
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1854
				____hasReturned = true -- 1855
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1855
				return -- 1855
			end -- 1855
			____hasReturned = true -- 1862
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1862
			return -- 1862
		end) -- 1862
		____try = ____try.catch( -- 1862
			____try, -- 1862
			function(____, e) -- 1862
				return __TS__AsyncAwaiter(function() -- 1862
					if stopToken and stopToken.stopped then -- 1862
						local reason = stopToken.reason or "request cancelled" -- 1869
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1870
						____hasReturned = true -- 1871
						____returnValue = {success = false, message = reason} -- 1871
						return -- 1871
					end -- 1871
					____exports.Log( -- 1873
						"Error", -- 1873
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1873
					) -- 1873
					____hasReturned = true -- 1874
					____returnValue = { -- 1874
						success = false, -- 1874
						message = tostring(e) -- 1874
					} -- 1874
					return -- 1874
				end) -- 1874
			end -- 1874
		) -- 1874
		__TS__Await(____try) -- 1715
		if ____hasReturned then -- 1715
			return ____awaiter_resolve(nil, ____returnValue) -- 1715
		end -- 1715
	end) -- 1715
end -- 1674
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1878
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1878
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1884
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1885
		local resolvedConfig = config or (function() -- 1888
			local configRes = ____exports.getActiveLLMConfig() -- 1889
			if not configRes.success then -- 1889
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1891
				return nil -- 1892
			end -- 1892
			return configRes.config -- 1894
		end)() -- 1888
		if not resolvedConfig then -- 1888
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1888
		end -- 1888
		local url = resolvedConfig.url -- 1888
		local model = resolvedConfig.model -- 1888
		local apiKey = resolvedConfig.apiKey -- 1888
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1900
		if fitted.fittedTokens > fitted.budgetTokens then -- 1900
			return ____awaiter_resolve(nil, {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."}) -- 1900
		end -- 1900
		____exports.Log( -- 1904
			"Info", -- 1904
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1904
		) -- 1904
		if stopToken and stopToken.stopped then -- 1904
			local reason = stopToken.reason or "request cancelled" -- 1906
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1907
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1907
		end -- 1907
		local ____hasReturned, ____returnValue -- 1907
		local ____try = __TS__AsyncAwaiter(function() -- 1907
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1911
				fitted.messages, -- 1911
				url, -- 1911
				apiKey, -- 1911
				model, -- 1911
				options, -- 1911
				false, -- 1911
				resolvedConfig.customOptions, -- 1911
				nil, -- 1911
				stopToken, -- 1911
				resolvedConfig.studioGateway -- 1911
			))) -- 1911
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1912
			____exports.Log( -- 1913
				"Info", -- 1913
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1913
			) -- 1913
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1914
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1914
				local rawPreview = previewText(raw) -- 1916
				____exports.Log( -- 1917
					"Error", -- 1917
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1917
				) -- 1917
				____hasReturned = true -- 1918
				____returnValue = { -- 1918
					success = false, -- 1919
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1920
					raw = raw -- 1921
				} -- 1921
				return -- 1918
			end -- 1918
			local responseObj = response -- 1924
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1925
			____exports.Log( -- 1926
				"Info", -- 1926
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1926
			) -- 1926
			if not responseObj.choices or #responseObj.choices == 0 then -- 1926
				local providerError = responseObj.error -- 1928
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1929
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1932
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1935
				local details = table.concat( -- 1938
					__TS__ArrayFilter( -- 1938
						{providerType, providerCode}, -- 1938
						function(____, part) return part ~= "" end -- 1938
					), -- 1938
					"/" -- 1938
				) -- 1938
				local rawPreview = previewText(raw, 400) -- 1939
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1940
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1943
				____hasReturned = true -- 1944
				____returnValue = {success = false, message = message, raw = raw} -- 1944
				return -- 1944
			end -- 1944
			____hasReturned = true -- 1950
			____returnValue = {success = true, response = responseObj} -- 1950
			return -- 1950
		end) -- 1950
		____try = ____try.catch( -- 1950
			____try, -- 1950
			function(____, e) -- 1950
				return __TS__AsyncAwaiter(function() -- 1950
					if stopToken and stopToken.stopped then -- 1950
						local reason = stopToken.reason or "request cancelled" -- 1956
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1957
						____hasReturned = true -- 1958
						____returnValue = {success = false, message = reason} -- 1958
						return -- 1958
					end -- 1958
					____exports.Log( -- 1960
						"Error", -- 1960
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1960
					) -- 1960
					____hasReturned = true -- 1961
					____returnValue = { -- 1961
						success = false, -- 1961
						message = tostring(e) -- 1961
					} -- 1961
					return -- 1961
				end) -- 1961
			end -- 1961
		) -- 1961
		__TS__Await(____try) -- 1910
		if ____hasReturned then -- 1910
			return ____awaiter_resolve(nil, ____returnValue) -- 1910
		end -- 1910
	end) -- 1910
end -- 1878
return ____exports -- 1878