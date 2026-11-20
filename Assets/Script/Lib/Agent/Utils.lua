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
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
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
function ____exports.safeJsonDecode(text) -- 462
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 463
	if value == nil then -- 463
		return value, err -- 465
	end -- 465
	return sanitizeJSONValue(value), err -- 467
end -- 462
function normalizeReasoningEffort(value) -- 1320
	if type(value) ~= "string" then -- 1320
		return nil -- 1321
	end -- 1321
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1322
	return normalized ~= "" and normalized or nil -- 1323
end -- 1323
function ____exports.applyCustomLLMOptions(options, customOptions) -- 1334
	if not customOptions then -- 1334
		return options -- 1338
	end -- 1338
	local merged = __TS__ObjectAssign({}, options) -- 1339
	for key in pairs(customOptions) do -- 1340
		do -- 1340
			if key == "auxiliaryOptions" or key == "visionModel" then -- 1340
				goto __continue292 -- 1343
			end -- 1343
			if key == "tools" and options.tools ~= nil then -- 1343
				goto __continue292 -- 1345
			end -- 1345
			local value = customOptions[key] -- 1346
			if value == json.null then -- 1346
				__TS__Delete(merged, key) -- 1348
			else -- 1348
				merged[key] = value -- 1350
			end -- 1350
		end -- 1350
		::__continue292:: -- 1350
	end -- 1350
	return merged -- 1353
end -- 1334
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
--- Plan an Agent decision without treating its configured maximum output as used input.
function ____exports.planAgentDecisionRequest(messages, options, config) -- 532
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 533
	local requestOptions = __TS__ObjectAssign( -- 534
		{}, -- 534
		____exports.applyCustomLLMOptions(options, config.customOptions) -- 534
	) -- 534
	local outputField = type(requestOptions.max_completion_tokens) == "number" and "max_completion_tokens" or "max_tokens" -- 535
	local configuredOutput = requestOptions[outputField] -- 536
	local outputCeiling = type(configuredOutput) == "number" and configuredOutput >= 1 and math.floor(configuredOutput) or getReservedOutputTokens({}, contextWindow) -- 537
	__TS__Delete(requestOptions, "max_tokens") -- 541
	__TS__Delete(requestOptions, "max_completion_tokens") -- 542
	requestOptions[outputField] = outputCeiling -- 543
	local messagesTokens = estimateMessagesTokens(messages) -- 544
	local structuralOverhead = math.max(256, #messages * 16) -- 545
	local fixedTokens = estimateOptionsTokens(requestOptions) + structuralOverhead -- 546
	local usedTokens = messagesTokens + fixedTokens -- 547
	local safetyMargin = 256 -- 548
	local minimumOutput = math.max( -- 549
		256, -- 549
		math.min(1024, outputCeiling) -- 549
	) -- 549
	local inputBudget = math.max(0, contextWindow - fixedTokens - safetyMargin - minimumOutput) -- 550
	local outputLimit = math.min( -- 551
		outputCeiling, -- 551
		math.max(0, contextWindow - usedTokens - safetyMargin) -- 551
	) -- 551
	requestOptions[outputField] = outputLimit -- 552
	return { -- 553
		options = requestOptions, -- 553
		contextWindow = contextWindow, -- 553
		messagesTokens = messagesTokens, -- 553
		structuralOverhead = structuralOverhead, -- 553
		usedTokens = usedTokens, -- 553
		inputBudget = inputBudget, -- 553
		outputLimit = outputLimit -- 553
	} -- 553
end -- 532
function ____exports.getInputTokenBudget(messages, options, config) -- 556
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 557
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 560
	local optionTokens = estimateOptionsTokens(options) -- 561
	local structuralOverhead = math.max(256, #messages * 16) -- 562
	return math.max(0, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 563
end -- 556
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 566
	if budgetTokens <= 0 or text == "" then -- 566
		return "" -- 567
	end -- 567
	local estimated = ____exports.estimateTextTokens(text) -- 568
	if estimated <= budgetTokens then -- 568
		return text -- 569
	end -- 569
	local marker = "\n...\n" -- 573
	if ____exports.estimateTextTokens(marker) > budgetTokens then -- 573
		return "" -- 574
	end -- 574
	local characters = utf8.len(text) -- 575
	if characters == nil then -- 575
		return "" -- 576
	end -- 576
	local low = 0 -- 577
	local high = characters -- 578
	local best = marker -- 579
	while low <= high do -- 579
		local keep = math.floor((low + high) / 2) -- 581
		local head = math.floor(keep * 0.35) -- 582
		local candidate = (utf8TakeHead(text, head) .. marker) .. utf8TakeTail(text, keep - head) -- 583
		if ____exports.estimateTextTokens(candidate) <= budgetTokens then -- 583
			best = candidate -- 585
			low = keep + 1 -- 586
		else -- 586
			high = keep - 1 -- 588
		end -- 588
	end -- 588
	return best -- 591
end -- 566
local function isXMLWhitespaceChar(ch) -- 594
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 595
end -- 594
local function findLineStart(value, from) -- 598
	local i = from -- 599
	while i >= 0 do -- 599
		if __TS__StringAccess(value, i) == "\n" then -- 599
			return i + 1 -- 601
		end -- 601
		i = i - 1 -- 602
	end -- 602
	return 0 -- 604
end -- 598
local function findLastLiteral(text, needle) -- 607
	if needle == "" then -- 607
		return #text -- 608
	end -- 608
	local last = -1 -- 609
	local from = 0 -- 610
	while from <= #text - #needle do -- 610
		local pos = (string.find( -- 612
			text, -- 612
			needle, -- 612
			math.max(from + 1, 1), -- 612
			true -- 612
		) or 0) - 1 -- 612
		if pos < 0 then -- 612
			break -- 613
		end -- 613
		last = pos -- 614
		from = pos + 1 -- 615
	end -- 615
	return last -- 617
end -- 607
local function unwrapXMLRawText(text) -- 620
	local trimmed = __TS__StringTrim(text) -- 621
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 621
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 623
	end -- 623
	return text -- 625
end -- 620
local function readSimpleXMLTagName(source, openStart, openEnd) -- 628
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 629
	if rawTag == "" then -- 629
		return { -- 631
			success = false, -- 631
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 631
		} -- 631
	end -- 631
	local selfClosing = false -- 633
	local tagText = rawTag -- 634
	if __TS__StringEndsWith(tagText, "/") then -- 634
		selfClosing = true -- 636
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 637
	end -- 637
	local tagName = "" -- 639
	do -- 639
		local i = 0 -- 640
		while i < #tagText do -- 640
			local ch = __TS__StringAccess(tagText, i) -- 641
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 641
				break -- 642
			end -- 642
			tagName = tagName .. ch -- 643
			i = i + 1 -- 640
		end -- 640
	end -- 640
	if tagName == "" then -- 640
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 646
	end -- 646
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 648
end -- 628
local function findMatchingXMLClose(source, tagName, contentStart) -- 651
	local sameOpenPrefix = "<" .. tagName -- 652
	local sameCloseToken = ("</" .. tagName) .. ">" -- 653
	local pos = contentStart -- 654
	local depth = 1 -- 655
	while pos < #source do -- 655
		do -- 655
			local lt = (string.find( -- 657
				source, -- 657
				"<", -- 657
				math.max(pos + 1, 1), -- 657
				true -- 657
			) or 0) - 1 -- 657
			if lt < 0 then -- 657
				break -- 658
			end -- 658
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 658
				local cdataEnd = (string.find( -- 660
					source, -- 660
					"]]>", -- 660
					math.max(lt + 9 + 1, 1), -- 660
					true -- 660
				) or 0) - 1 -- 660
				if cdataEnd < 0 then -- 660
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 661
				end -- 661
				pos = cdataEnd + 3 -- 662
				goto __continue155 -- 663
			end -- 663
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 666
					source, -- 666
					"-->",
					math.max(lt + 4 + 1, 1), -- 666
					true -- 666
				) or 0) - 1 -- 666
				if commentEnd < 0 then -- 666
					return {success = false, message = "invalid xml: unterminated comment"} -- 667
				end -- 667
				pos = commentEnd + 3 -- 668
				goto __continue155 -- 669
			end -- 669
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 669
				depth = depth - 1 -- 672
				if depth == 0 then -- 672
					return {success = true, closeStart = lt} -- 673
				end -- 673
				pos = lt + #sameCloseToken -- 674
				goto __continue155 -- 675
			end -- 675
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 675
				local openEnd = (string.find( -- 678
					source, -- 678
					">", -- 678
					math.max(lt + 1, 1), -- 678
					true -- 678
				) or 0) - 1 -- 678
				if openEnd < 0 then -- 678
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 679
				end -- 679
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 680
				if not tagInfo.success then -- 680
					return tagInfo -- 681
				end -- 681
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 681
					depth = depth + 1 -- 683
				end -- 683
				pos = openEnd + 1 -- 685
				goto __continue155 -- 686
			end -- 686
			local genericEnd = (string.find( -- 688
				source, -- 688
				">", -- 688
				math.max(lt + 1, 1), -- 688
				true -- 688
			) or 0) - 1 -- 688
			if genericEnd < 0 then -- 688
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 689
			end -- 689
			pos = genericEnd + 1 -- 690
		end -- 690
		::__continue155:: -- 690
	end -- 690
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 692
end -- 651
function ____exports.extractXMLFromText(text) -- 695
	local source = __TS__StringTrim(text) -- 696
	local function extractFencedBlock(fence) -- 697
		if not __TS__StringStartsWith(source, fence) then -- 697
			return nil -- 698
		end -- 698
		local firstLineEnd = (string.find( -- 699
			source, -- 699
			"\n", -- 699
			math.max(1, 1), -- 699
			true -- 699
		) or 0) - 1 -- 699
		if firstLineEnd < 0 then -- 699
			return nil -- 700
		end -- 700
		local searchPos = firstLineEnd + 1 -- 701
		local closingFencePositions = {} -- 702
		while searchPos < #source do -- 702
			local ____end = (string.find( -- 704
				source, -- 704
				"```", -- 704
				math.max(searchPos + 1, 1), -- 704
				true -- 704
			) or 0) - 1 -- 704
			if ____end < 0 then -- 704
				break -- 705
			end -- 705
			local lineStart = findLineStart(source, ____end - 1) -- 706
			local lineEnd = (string.find( -- 707
				source, -- 707
				"\n", -- 707
				math.max(____end + 1, 1), -- 707
				true -- 707
			) or 0) - 1 -- 707
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 708
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 708
				closingFencePositions[#closingFencePositions + 1] = ____end -- 710
			end -- 710
			searchPos = ____end + 1 -- 712
		end -- 712
		do -- 712
			local i = #closingFencePositions - 1 -- 714
			while i >= 0 do -- 714
				do -- 714
					local closingFencePos = closingFencePositions[i + 1] -- 715
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 716
					if afterFence ~= "" then -- 716
						goto __continue176 -- 717
					end -- 717
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 718
				end -- 718
				::__continue176:: -- 718
				i = i - 1 -- 714
			end -- 714
		end -- 714
		return nil -- 720
	end -- 697
	local xmlBlock = extractFencedBlock("```xml") -- 722
	if xmlBlock ~= nil then -- 722
		return xmlBlock -- 723
	end -- 723
	local genericBlock = extractFencedBlock("```") -- 724
	if genericBlock ~= nil then -- 724
		return genericBlock -- 725
	end -- 725
	return source -- 726
end -- 695
function ____exports.parseSimpleXMLChildren(source) -- 729
	local result = {} -- 730
	local pos = 0 -- 731
	while pos < #source do -- 731
		do -- 731
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 731
				pos = pos + 1 -- 733
			end -- 733
			if pos >= #source then -- 733
				break -- 734
			end -- 734
			if __TS__StringAccess(source, pos) ~= "<" then -- 734
				return { -- 736
					success = false, -- 736
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 736
				} -- 736
			end -- 736
			if __TS__StringStartsWith(source, "</", pos) then -- 736
				return { -- 739
					success = false, -- 739
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 739
				} -- 739
			end -- 739
			local openEnd = (string.find( -- 741
				source, -- 741
				">", -- 741
				math.max(pos + 1, 1), -- 741
				true -- 741
			) or 0) - 1 -- 741
			if openEnd < 0 then -- 741
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 743
			end -- 743
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 745
			if not tagInfo.success then -- 745
				return tagInfo -- 746
			end -- 746
			if tagInfo.selfClosing then -- 746
				result[tagInfo.tagName] = "" -- 748
				pos = openEnd + 1 -- 749
				goto __continue181 -- 750
			end -- 750
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 752
			if not closeRes.success then -- 752
				return closeRes -- 753
			end -- 753
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 754
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 755
			pos = closeRes.closeStart + #closeToken -- 756
		end -- 756
		::__continue181:: -- 756
	end -- 756
	return {success = true, obj = result} -- 758
end -- 729
function ____exports.parseXMLObjectFromText(text, rootTag) -- 761
	local xmlText = ____exports.extractXMLFromText(text) -- 762
	local rootOpen = ("<" .. rootTag) .. ">" -- 763
	local rootClose = ("</" .. rootTag) .. ">" -- 764
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 765
	local ____end = findLastLiteral(xmlText, rootClose) -- 766
	if start < 0 or ____end < start then -- 766
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 768
	end -- 768
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 770
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 771
	if beforeRoot ~= "" or afterRoot ~= "" then -- 771
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 773
	end -- 773
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 775
	return ____exports.parseSimpleXMLChildren(rootContent) -- 776
end -- 761
function ____exports.fitMessagesToContext(messages, options, config) -- 779
	local modelName = string.lower(config.model) -- 786
	local shouldEchoReasoningContent = __TS__ArraySome( -- 787
		messages, -- 787
		function(____, message) return type(message.reasoning_content) == "string" end -- 787
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 787
	local cloned = __TS__ArrayMap( -- 791
		messages, -- 791
		function(____, message) -- 791
			local clonedMessage = __TS__ObjectAssign({}, message) -- 792
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 792
				clonedMessage.reasoning_content = "" -- 798
			end -- 798
			return clonedMessage -- 800
		end -- 791
	) -- 791
	local budgetTokens = ____exports.getInputTokenBudget(cloned, options, config) -- 802
	local originalTokens = estimateMessagesTokens(cloned) -- 803
	if originalTokens <= budgetTokens then -- 803
		return { -- 805
			messages = cloned, -- 806
			trimmed = false, -- 807
			originalTokens = originalTokens, -- 808
			fittedTokens = originalTokens, -- 809
			budgetTokens = budgetTokens -- 810
		} -- 810
	end -- 810
	local function roleOverhead(message) -- 814
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 814
	end -- 814
	local fixedOverhead = 0 -- 815
	local contentIndexes = {} -- 816
	do -- 816
		local i = 0 -- 817
		while i < #cloned do -- 817
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 818
			contentIndexes[#contentIndexes + 1] = i -- 819
			i = i + 1 -- 817
		end -- 817
	end -- 817
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 821
	if #contentIndexes == 1 then -- 821
		local idx = contentIndexes[1] -- 823
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 824
		local fittedTokens = estimateMessagesTokens(cloned) -- 825
		return { -- 826
			messages = cloned, -- 827
			trimmed = true, -- 828
			originalTokens = originalTokens, -- 829
			fittedTokens = fittedTokens, -- 830
			budgetTokens = budgetTokens -- 831
		} -- 831
	end -- 831
	local nonSystemIndexes = {} -- 835
	local systemIndexes = {} -- 836
	do -- 836
		local i = 0 -- 837
		while i < #cloned do -- 837
			if cloned[i + 1].role == "system" then -- 837
				systemIndexes[#systemIndexes + 1] = i -- 838
			else -- 838
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 839
			end -- 839
			i = i + 1 -- 837
		end -- 837
	end -- 837
	local ____array_8 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 837
	__TS__SparseArrayPush( -- 837
		____array_8, -- 837
		table.unpack(systemIndexes) -- 841
	) -- 841
	local priorityIndexes = {__TS__SparseArraySpread(____array_8)} -- 841
	local remainingContentBudget = contentBudget -- 842
	do -- 842
		local i = #priorityIndexes - 1 -- 843
		while i >= 0 do -- 843
			local idx = priorityIndexes[i + 1] -- 844
			local message = cloned[idx + 1] -- 845
			local minBudget = message.role == "system" and 96 or 192 -- 846
			local target = math.max( -- 847
				minBudget, -- 847
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 847
			) -- 847
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 848
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 849
			remainingContentBudget = math.max(0, remainingContentBudget) -- 850
			i = i - 1 -- 843
		end -- 843
	end -- 843
	local fittedTokens = estimateMessagesTokens(cloned) -- 853
	if fittedTokens > budgetTokens then -- 853
		do -- 853
			local i = 0 -- 855
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 855
				local idx = priorityIndexes[i + 1] -- 856
				local message = cloned[idx + 1] -- 857
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 858
				local excess = fittedTokens - budgetTokens -- 859
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 860
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 861
				fittedTokens = estimateMessagesTokens(cloned) -- 862
				i = i + 1 -- 855
			end -- 855
		end -- 855
	end -- 855
	if fittedTokens > budgetTokens then -- 855
		do -- 855
			local i = 0 -- 866
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 866
				do -- 866
					local idx = priorityIndexes[i + 1] -- 867
					if cloned[idx + 1].role == "system" then -- 867
						goto __continue213 -- 868
					end -- 868
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 869
					fittedTokens = estimateMessagesTokens(cloned) -- 870
				end -- 870
				::__continue213:: -- 870
				i = i + 1 -- 866
			end -- 866
		end -- 866
	end -- 866
	return { -- 873
		messages = cloned, -- 874
		trimmed = true, -- 875
		originalTokens = originalTokens, -- 876
		fittedTokens = fittedTokens, -- 877
		budgetTokens = budgetTokens -- 878
	} -- 878
end -- 779
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken, studioGateway) -- 882
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 894
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 895
	local data = __TS__ObjectAssign({model = model}, requestOptions, {messages = messages, stream = stream}) -- 896
	local studioRequestId = studioGateway and ____exports.createStudioModelRequestId() or nil -- 902
	if stopToken == nil then -- 902
		stopToken = {stopped = false} -- 903
	end -- 903
	return __TS__New( -- 904
		__TS__Promise, -- 904
		function(____, resolve, reject) -- 904
			local requestId = 0 -- 905
			local settled = false -- 906
			local function finishResolve(text) -- 907
				if settled then -- 907
					return -- 908
				end -- 908
				settled = true -- 909
				resolve(nil, text) -- 910
			end -- 907
			local function finishReject(err) -- 912
				if settled then -- 912
					return -- 913
				end -- 913
				settled = true -- 914
				reject(nil, err) -- 915
			end -- 912
			Director.systemScheduler:schedule(function() -- 917
				if not settled then -- 917
					if stopToken.stopped then -- 917
						if requestId ~= 0 then -- 917
							HttpClient:cancel(requestId) -- 921
							requestId = 0 -- 922
						end -- 922
						finishReject("request cancelled") -- 924
						return true -- 925
					end -- 925
					return false -- 927
				end -- 927
				return true -- 929
			end) -- 917
			Director.systemScheduler:schedule(once(function() -- 931
				emit( -- 932
					"LLM_IN", -- 932
					table.concat( -- 932
						__TS__ArrayMap( -- 932
							messages, -- 932
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 932
						), -- 932
						"\n" -- 932
					) -- 932
				) -- 932
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 933
				if jsonStr ~= nil then -- 933
					local headers = { -- 935
						"Authorization: Bearer " .. apiKey, -- 936
						"Content-Type: application/json", -- 937
						receiver and "Accept: text/event-stream" or "Accept: application/json", -- 938
						table.unpack(studioRequestId and ({"X-Studio-Model-Request-Id: " .. studioRequestId}) or ({})) -- 939
					} -- 939
					requestId = receiver and HttpClient:post( -- 941
						url, -- 942
						headers, -- 942
						jsonStr, -- 942
						requestTimeout, -- 942
						function(data) -- 942
							if stopToken.stopped then -- 942
								return true -- 943
							end -- 943
							return receiver(data) -- 944
						end, -- 942
						function(data) -- 945
							requestId = 0 -- 946
							if data ~= nil then -- 946
								finishResolve(data) -- 948
							else -- 948
								finishReject("failed to get http response") -- 950
							end -- 950
						end -- 945
					) or HttpClient:post( -- 945
						url, -- 953
						headers, -- 953
						jsonStr, -- 953
						requestTimeout, -- 953
						function(data) -- 953
							requestId = 0 -- 954
							if stopToken.stopped then -- 954
								finishReject("request cancelled") -- 956
								return -- 957
							end -- 957
							if data ~= nil then -- 957
								finishResolve(data) -- 960
							else -- 960
								finishReject("failed to get http response") -- 962
							end -- 962
						end -- 953
					) -- 953
					if requestId == 0 then -- 953
						finishReject("failed to schedule http request") -- 966
					elseif stopToken.stopped then -- 966
						HttpClient:cancel(requestId) -- 968
						requestId = 0 -- 969
						finishReject("request cancelled") -- 970
					end -- 970
				else -- 970
					finishReject(err) -- 973
				end -- 973
			end)) -- 931
		end -- 904
	) -- 904
end -- 882
function ____exports.createSSEJSONParser(opts) -- 983
	local buffer = "" -- 988
	local eventDataLines = {} -- 989
	local function flushEventIfAny() -- 991
		if #eventDataLines == 0 then -- 991
			return -- 992
		end -- 992
		local dataPayload = table.concat(eventDataLines, "\n") -- 994
		eventDataLines = {} -- 995
		if dataPayload == "[DONE]" then -- 995
			local ____opt_9 = opts.onDone -- 995
			if ____opt_9 ~= nil then -- 995
				____opt_9(dataPayload) -- 998
			end -- 998
			return -- 999
		end -- 999
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 1002
		if err == nil then -- 1002
			opts.onJSON(obj, dataPayload) -- 1004
		else -- 1004
			local ____opt_11 = opts.onError -- 1004
			if ____opt_11 ~= nil then -- 1004
				____opt_11(err, {raw = dataPayload}) -- 1006
			end -- 1006
		end -- 1006
	end -- 991
	local function append(chunk) -- 1010
		buffer = buffer .. chunk -- 1011
	end -- 1010
	local function drain(maxLines) -- 1014
		local processedLines = 0 -- 1015
		while maxLines == nil or processedLines < maxLines do -- 1015
			do -- 1015
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 1017
				if nl < 0 then -- 1017
					break -- 1018
				end -- 1018
				processedLines = processedLines + 1 -- 1019
				local line = __TS__StringSlice(buffer, 0, nl) -- 1021
				buffer = __TS__StringSlice(buffer, nl + 1) -- 1022
				if __TS__StringEndsWith(line, "\r") then -- 1022
					line = string.sub(line, 1, -2) -- 1024
				end -- 1024
				if line == "" then -- 1024
					flushEventIfAny() -- 1027
					goto __continue248 -- 1028
				end -- 1028
				if __TS__StringStartsWith(line, ":") then -- 1028
					goto __continue248 -- 1032
				end -- 1032
				if __TS__StringStartsWith(line, "data:") then -- 1032
					local v = string.sub(line, 6) -- 1035
					if __TS__StringStartsWith(v, " ") then -- 1035
						v = string.sub(v, 2) -- 1036
					end -- 1036
					eventDataLines[#eventDataLines + 1] = v -- 1037
					goto __continue248 -- 1038
				end -- 1038
			end -- 1038
			::__continue248:: -- 1038
		end -- 1038
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0 -- 1041
	end -- 1014
	local function feed(chunk) -- 1044
		append(chunk) -- 1045
		drain() -- 1046
	end -- 1044
	local function ____end() -- 1049
		if #buffer > 0 then -- 1049
			local line = buffer -- 1051
			buffer = "" -- 1052
			if __TS__StringEndsWith(line, "\r") then -- 1052
				line = string.sub(line, 1, -2) -- 1053
			end -- 1053
			if __TS__StringStartsWith(line, "data:") then -- 1053
				local v = string.sub(line, 6) -- 1056
				if __TS__StringStartsWith(v, " ") then -- 1056
					v = string.sub(v, 2) -- 1057
				end -- 1057
				eventDataLines[#eventDataLines + 1] = v -- 1058
			end -- 1058
		end -- 1058
		flushEventIfAny() -- 1061
	end -- 1049
	local function discard() -- 1064
		buffer = "" -- 1065
		eventDataLines = {} -- 1066
	end -- 1064
	return { -- 1069
		append = append, -- 1069
		drain = drain, -- 1069
		feed = feed, -- 1069
		["end"] = ____end, -- 1069
		discard = discard -- 1069
	} -- 1069
end -- 983
local SSE_PARSE_LINES_PER_FRAME = 256 -- 1072
local function createScheduledSSEJSONParser(opts, isCancelled) -- 1074
	local parser = ____exports.createSSEJSONParser(opts) -- 1078
	local inputFinished = false -- 1079
	local settled = false -- 1080
	local resolveFinished -- 1081
	local finished = __TS__New( -- 1082
		__TS__Promise, -- 1082
		function(____, resolve) -- 1082
			resolveFinished = resolve -- 1083
		end -- 1082
	) -- 1082
	local function settle() -- 1085
		if settled then -- 1085
			return -- 1086
		end -- 1086
		settled = true -- 1087
		if resolveFinished ~= nil then -- 1087
			resolveFinished() -- 1088
		end -- 1088
	end -- 1085
	Director.systemScheduler:schedule(function() -- 1090
		if settled then -- 1090
			return true -- 1091
		end -- 1091
		if isCancelled and isCancelled() then -- 1091
			parser.discard() -- 1093
			settle() -- 1094
			return true -- 1095
		end -- 1095
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME) -- 1097
		if inputFinished and not hasMoreCompleteLines then -- 1097
			parser["end"]() -- 1099
			settle() -- 1100
			return true -- 1101
		end -- 1101
		return false -- 1103
	end) -- 1090
	return { -- 1105
		append = parser.append, -- 1106
		finish = function() -- 1107
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1107
				inputFinished = true -- 1108
				__TS__Await(finished) -- 1109
			end) -- 1109
		end, -- 1107
		cancel = function() -- 1111
			parser.discard() -- 1112
			settle() -- 1113
		end -- 1111
	} -- 1111
end -- 1074
function ____exports.extractLLMTokenUsage(response) -- 1209
	local usage = response and response.usage -- 1210
	if not usage or type(usage) ~= "table" then -- 1210
		return nil -- 1211
	end -- 1211
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 1212
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 1215
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 1215
		return nil -- 1218
	end -- 1218
	local ____temp_24 -- 1219
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 1219
		____temp_24 = usage.prompt_cache_hit_tokens -- 1220
	else -- 1220
		local ____temp_23 -- 1221
		local ____opt_19 = usage.prompt_tokens_details -- 1221
		if type(____opt_19 and ____opt_19.cached_tokens) == "number" then -- 1221
			____temp_23 = usage.prompt_tokens_details.cached_tokens -- 1222
		else -- 1222
			local ____opt_21 = usage.input_tokens_details -- 1222
			____temp_23 = type(____opt_21 and ____opt_21.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 1223
		end -- 1223
		____temp_24 = ____temp_23 -- 1221
	end -- 1221
	local cachedInputTokens = ____temp_24 -- 1219
	local ____inputTokens_27 = inputTokens -- 1227
	local ____outputTokens_28 = outputTokens -- 1228
	local ____temp_29 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 1229
	local ____temp_30 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 1230
	local ____temp_31 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 1231
	local ____opt_25 = usage.completion_tokens_details -- 1231
	return { -- 1226
		inputTokens = ____inputTokens_27, -- 1227
		outputTokens = ____outputTokens_28, -- 1228
		totalTokens = ____temp_29, -- 1229
		cachedInputTokens = ____temp_30, -- 1230
		cacheMissInputTokens = ____temp_31, -- 1231
		reasoningOutputTokens = type(____opt_25 and ____opt_25.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 1234
	} -- 1234
end -- 1209
function ____exports.validateAgentLLMConfig(config) -- 1278
	local ____opt_32 = config.customOptions -- 1278
	local visionModel = ____opt_32 and ____opt_32.visionModel -- 1279
	if visionModel ~= nil and visionModel ~= json.null and type(visionModel) ~= "string" then -- 1279
		return {success = false, message = "视觉模型名称 visionModel 必须是字符串；留空使用默认行为。"} -- 1281
	end -- 1281
	local ____opt_34 = config.customOptions -- 1281
	local auxiliaryOptions = ____opt_34 and ____opt_34.auxiliaryOptions -- 1283
	if auxiliaryOptions == nil then -- 1283
		return {success = true} -- 1284
	end -- 1284
	local emptyOptions = type(auxiliaryOptions) == "table" and auxiliaryOptions ~= nil and auxiliaryOptions ~= json.null and #__TS__ObjectKeys(auxiliaryOptions) == 0 -- 1285
	if isPlainRecord(auxiliaryOptions) or emptyOptions then -- 1285
		return {success = true} -- 1291
	end -- 1291
	return {success = false, message = "LLM 配置的 auxiliaryOptions 如有填写必须是对象（可以为空），请检查 LLM 配置"} -- 1293
end -- 1278
local function normalizeContextWindow(value) -- 1299
	if type(value) == "number" and value > 0 then -- 1299
		return math.floor(value) -- 1301
	end -- 1301
	return 64000 -- 1303
end -- 1299
local function normalizeLLMTemperature(value) -- 1306
	if type(value) == "number" then -- 1306
		return math.max( -- 1308
			0, -- 1308
			math.min(2, value) -- 1308
		) -- 1308
	end -- 1308
	return 0.1 -- 1310
end -- 1306
local function normalizeLLMMaxTokens(value) -- 1313
	if type(value) == "number" then -- 1313
		return math.max( -- 1315
			1, -- 1315
			math.floor(value) -- 1315
		) -- 1315
	end -- 1315
	return AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1317
end -- 1313
local function normalizeLLMCustomOptions(value) -- 1326
	if type(value) ~= "string" then -- 1326
		return nil -- 1327
	end -- 1327
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 1328
	if text == "" then -- 1328
		return nil -- 1329
	end -- 1329
	local decoded = ____exports.safeJsonDecode(text) -- 1330
	return isPlainRecord(decoded) and decoded or nil -- 1331
end -- 1326
function ____exports.getLLMConfigRecords() -- 1356
	upgradeLLMConfig() -- 1357
	local rows = DB:query("select * from LLMConfig", true) -- 1358
	local records = {} -- 1359
	if rows and #rows > 1 then -- 1359
		do -- 1359
			local i = 1 -- 1361
			while i < #rows do -- 1361
				local record = {} -- 1362
				do -- 1362
					local c = 0 -- 1363
					while c < #rows[i + 1] do -- 1363
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 1364
						c = c + 1 -- 1363
					end -- 1363
				end -- 1363
				records[#records + 1] = record -- 1366
				i = i + 1 -- 1361
			end -- 1361
		end -- 1361
	end -- 1361
	return records -- 1369
end -- 1356
function ____exports.getLLMConfigSummaries() -- 1379
	return __TS__ArrayFlatMap( -- 1380
		____exports.getLLMConfigRecords(), -- 1380
		function(____, record) -- 1380
			local id = record.id -- 1381
			local name = record.name -- 1382
			local model = record.model -- 1383
			if type(id) ~= "number" or type(name) ~= "string" or type(model) ~= "string" then -- 1383
				return {} -- 1384
			end -- 1384
			return {{id = id, name = name, model = model, active = record.active ~= 0}} -- 1385
		end -- 1380
	) -- 1380
end -- 1379
local function parseLLMConfig(config) -- 1389
	if not config then -- 1389
		return {success = false, message = "LLM config not found"} -- 1391
	end -- 1391
	local ____config_36 = config -- 1393
	local id = ____config_36.id -- 1393
	local url = ____config_36.url -- 1393
	local model = ____config_36.model -- 1393
	local api_key = ____config_36.api_key -- 1393
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 1393
		return {success = false, message = "got invalid LLM config"} -- 1395
	end -- 1395
	return { -- 1397
		success = true, -- 1398
		id = id, -- 1399
		config = { -- 1400
			url = url, -- 1401
			model = model, -- 1402
			apiKey = api_key, -- 1403
			contextWindow = normalizeContextWindow(config.context_window), -- 1404
			temperature = normalizeLLMTemperature(config.temperature), -- 1405
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 1406
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 1407
			customOptions = normalizeLLMCustomOptions(config.custom_options) -- 1408
		} -- 1408
	} -- 1408
end -- 1389
function ____exports.getSavedLLMConfigs() -- 1413
	local records = ____exports.getLLMConfigRecords() -- 1414
	__TS__ArraySort( -- 1416
		records, -- 1416
		function(____, a, b) -- 1416
			local activeOrder = __TS__Number(b.active ~= 0) - __TS__Number(a.active ~= 0) -- 1417
			return activeOrder ~= 0 and activeOrder or __TS__Number(a.id) - __TS__Number(b.id) -- 1418
		end -- 1416
	) -- 1416
	return __TS__ArrayFlatMap( -- 1420
		records, -- 1420
		function(____, record) -- 1420
			local result = parseLLMConfig(record) -- 1421
			return result.success and ({result.config}) or ({}) -- 1422
		end -- 1420
	) -- 1420
end -- 1413
function ____exports.getLLMConfig(configId) -- 1426
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId) -- 1427
	if normalizedId == nil or normalizedId <= 0 then -- 1427
		return {success = false, message = "LLM config is not selected"} -- 1429
	end -- 1429
	return parseLLMConfig(__TS__ArrayFind( -- 1431
		____exports.getLLMConfigRecords(), -- 1431
		function(____, record) return record.id == normalizedId end -- 1431
	)) -- 1431
end -- 1426
function ____exports.getActiveLLMConfig() -- 1434
	local records = ____exports.getLLMConfigRecords() -- 1435
	local config = __TS__ArrayFind( -- 1436
		records, -- 1436
		function(____, r) return r.active ~= 0 end -- 1436
	) -- 1436
	if not config then -- 1436
		return {success = false, message = "no active LLM config"} -- 1438
	end -- 1438
	return parseLLMConfig(config) -- 1440
end -- 1434
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 1443
	local callEvent -- 1449
	if event.id ~= nil then -- 1449
		local id = event.id -- 1451
		callEvent = { -- 1452
			id = nil, -- 1453
			onData = function(data) -- 1454
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 1455
				return event.stopToken.stopped -- 1456
			end, -- 1454
			onCancel = function(reason) -- 1458
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 1459
			end, -- 1458
			onDone = function() -- 1461
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 1462
			end -- 1461
		} -- 1461
	else -- 1461
		callEvent = event -- 1466
	end -- 1466
	local ____callEvent_37 = callEvent -- 1468
	local onData = ____callEvent_37.onData -- 1468
	local onDone = ____callEvent_37.onDone -- 1468
	local ____callEvent_38 = callEvent -- 1469
	local onCancel = ____callEvent_38.onCancel -- 1469
	local config = llmConfig or (function() -- 1470
		local configRes = ____exports.getActiveLLMConfig() -- 1471
		if not configRes.success then -- 1471
			if onCancel then -- 1471
				onCancel(configRes.message) -- 1473
			end -- 1473
			return nil -- 1474
		end -- 1474
		return configRes.config -- 1476
	end)() -- 1470
	if not config then -- 1470
		return {success = false, message = "no active LLM config"} -- 1479
	end -- 1479
	local url = config.url -- 1479
	local model = config.model -- 1479
	local apiKey = config.apiKey -- 1479
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 1482
	if fitted.fittedTokens > fitted.budgetTokens then -- 1482
		return {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."} -- 1484
	end -- 1484
	if fitted.trimmed then -- 1484
		____exports.Log( -- 1487
			"Warn", -- 1487
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 1487
		) -- 1487
	end -- 1487
	local stopLLM = false -- 1489
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false}) -- 1490
	local parser = createScheduledSSEJSONParser( -- 1493
		{onJSON = function(obj) -- 1493
			local result = onData(obj) -- 1495
			if result then -- 1495
				stopLLM = true -- 1497
				streamStopToken.stopped = true -- 1498
				streamStopToken.reason = "LLM Stopped" -- 1499
			end -- 1499
		end}, -- 1494
		function() return streamStopToken.stopped end -- 1502
	); -- 1502
	(function() -- 1503
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1503
			local ____try = __TS__AsyncAwaiter(function() -- 1503
				local result = __TS__Await(postLLM( -- 1505
					fitted.messages, -- 1505
					url, -- 1505
					apiKey, -- 1505
					model, -- 1505
					options, -- 1505
					true, -- 1505
					config.customOptions, -- 1505
					function(data) -- 1505
						if stopLLM then -- 1505
							if onCancel then -- 1505
								onCancel("LLM Stopped") -- 1508
								onCancel = nil -- 1509
							end -- 1509
							return true -- 1511
						end -- 1511
						parser.append(data) -- 1513
						return false -- 1514
					end, -- 1505
					streamStopToken, -- 1515
					config.studioGateway -- 1515
				)) -- 1515
				__TS__Await(parser.finish()) -- 1516
				if onDone then -- 1516
					onDone(result) -- 1518
				end -- 1518
			end) -- 1518
			____try = ____try.catch( -- 1518
				____try, -- 1518
				function(____, e) -- 1518
					return __TS__AsyncAwaiter(function() -- 1518
						parser.cancel() -- 1521
						stopLLM = true -- 1522
						if onCancel then -- 1522
							onCancel(tostring(e)) -- 1524
							onCancel = nil -- 1525
						end -- 1525
					end) -- 1525
				end -- 1525
			) -- 1525
			__TS__Await(____try) -- 1504
		end) -- 1504
	end)() -- 1503
	return {success = true} -- 1529
end -- 1443
local function mergeStreamToolCall(target, delta) -- 1532
	if type(delta.id) == "string" and delta.id ~= "" then -- 1532
		target.id = delta.id -- 1534
	end -- 1534
	if type(delta.type) == "string" and delta.type ~= "" then -- 1534
		target.type = delta.type -- 1537
	end -- 1537
	if delta["function"] then -- 1537
		if target["function"] == nil then -- 1537
			target["function"] = {} -- 1540
		end -- 1540
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1540
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1542
		end -- 1542
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1542
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1545
		end -- 1545
	end -- 1545
end -- 1532
local function isToolCallComplete(tc) -- 1550
	if type(tc.id) ~= "string" or tc.id == "" then -- 1550
		return false -- 1551
	end -- 1551
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1551
		return false -- 1552
	end -- 1552
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1552
		return false -- 1553
	end -- 1553
	local args = tc["function"].arguments -- 1554
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1554
		return false -- 1555
	end -- 1555
	local decoded = ____exports.safeJsonDecode(args) -- 1556
	return decoded ~= nil -- 1557
end -- 1550
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1560
	local delta = choice.delta or ({}) -- 1561
	local fullMessage = choice.message or ({}) -- 1562
	local message = acc.message -- 1563
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1564
	if type(role) == "string" and role ~= "" then -- 1564
		message.role = role -- 1568
	end -- 1568
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1570
	if type(content) == "string" and content ~= "" then -- 1570
		message.content = (message.content or "") .. content -- 1574
	end -- 1574
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1576
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1576
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1580
	end -- 1580
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1582
	if #toolCalls > 0 then -- 1582
		if message.tool_calls == nil then -- 1582
			message.tool_calls = {} -- 1586
		end -- 1586
		do -- 1586
			local i = 0 -- 1587
			while i < #toolCalls do -- 1587
				local item = toolCalls[i + 1] -- 1588
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1589
				local ____message_tool_calls_39, ____temp_40 = message.tool_calls, index + 1 -- 1589
				if ____message_tool_calls_39[____temp_40] == nil then -- 1589
					____message_tool_calls_39[____temp_40] = {} -- 1592
				end -- 1592
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1593
				if onToolCallReady and emittedToolCallIds then -- 1593
					local tc = message.tool_calls[index + 1] -- 1595
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1595
						emittedToolCallIds[tc.id] = true -- 1597
						onToolCallReady(tc) -- 1598
					end -- 1598
				end -- 1598
				i = i + 1 -- 1587
			end -- 1587
		end -- 1587
	end -- 1587
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1587
		acc.finish_reason = choice.finish_reason -- 1604
	end -- 1604
end -- 1560
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1608
	local indexes = __TS__ArraySort( -- 1617
		__TS__ArrayFilter( -- 1617
			__TS__ArrayMap( -- 1617
				__TS__ObjectKeys(states), -- 1617
				function(____, key) return __TS__Number(key) end -- 1618
			), -- 1618
			function(____, index) return __TS__NumberIsFinite(index) end -- 1619
		), -- 1619
		function(____, a, b) return a - b end -- 1620
	) -- 1620
	return { -- 1621
		id = id, -- 1622
		created = created, -- 1623
		object = object, -- 1624
		model = model, -- 1625
		choices = __TS__ArrayMap( -- 1626
			indexes, -- 1626
			function(____, index) -- 1626
				local state = states[index] -- 1627
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1628
			end -- 1626
		), -- 1626
		usage = usage, -- 1639
		error = providerError -- 1640
	} -- 1640
end -- 1608
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1644
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1644
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1655
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1656
		local resolvedConfig = config or (function() -- 1659
			local configRes = ____exports.getActiveLLMConfig() -- 1660
			if not configRes.success then -- 1660
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1662
				return nil -- 1663
			end -- 1663
			return configRes.config -- 1665
		end)() -- 1659
		if not resolvedConfig then -- 1659
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1659
		end -- 1659
		local url = resolvedConfig.url -- 1659
		local model = resolvedConfig.model -- 1659
		local apiKey = resolvedConfig.apiKey -- 1659
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1671
		if fitted.fittedTokens > fitted.budgetTokens then -- 1671
			return ____awaiter_resolve(nil, {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."}) -- 1671
		end -- 1671
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1675
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1676
		local ____model_45 = model -- 1679
		local ____url_46 = url -- 1679
		local ____temp_47 = #messages -- 1679
		local ____tostring_42 = tostring -- 1679
		local ____options_max_tokens_41 = options.max_tokens -- 1679
		if ____options_max_tokens_41 == nil then -- 1679
			____options_max_tokens_41 = "unset" -- 1679
		end -- 1679
		local ____tostring_42_result_48 = ____tostring_42(____options_max_tokens_41) -- 1679
		local ____tostring_44 = tostring -- 1679
		local ____options_temperature_43 = options.temperature -- 1679
		if ____options_temperature_43 == nil then -- 1679
			____options_temperature_43 = "unset" -- 1679
		end -- 1679
		____exports.Log( -- 1679
			"Info", -- 1679
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_45) .. " url=") .. ____url_46) .. " messages=") .. tostring(____temp_47)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_42_result_48) .. " temperature=") .. ____tostring_44(____options_temperature_43)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1679
		) -- 1679
		if stopToken and stopToken.stopped then -- 1679
			local reason = stopToken.reason or "request cancelled" -- 1681
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1682
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1682
		end -- 1682
		local ____hasReturned, ____returnValue -- 1682
		local ____try = __TS__AsyncAwaiter(function() -- 1682
			local states = {} -- 1686
			local emittedToolCallIds = {} -- 1687
			local responseId = nil -- 1688
			local responseCreated = nil -- 1689
			local responseObject = nil -- 1690
			local providerError -- 1691
			local responseUsage -- 1692
			local httpChunkCount = 0 -- 1693
			local rawStreamBytes = 0 -- 1694
			local rawStreamPreview = "" -- 1695
			local sseJSONChunkCount = 0 -- 1696
			local choiceJSONChunkCount = 0 -- 1697
			local emptyChoicesChunkCount = 0 -- 1698
			local missingChoicesChunkCount = 0 -- 1699
			local parseErrorCount = 0 -- 1700
			local doneChunkSeen = false -- 1701
			local lastJSONPreview = "" -- 1702
			local parser = createScheduledSSEJSONParser( -- 1703
				{ -- 1703
					onJSON = function(obj, raw) -- 1704
						sseJSONChunkCount = sseJSONChunkCount + 1 -- 1705
						lastJSONPreview = previewText(raw, 500) -- 1706
						if not obj or type(obj) ~= "table" then -- 1706
							return -- 1708
						end -- 1708
						local chunk = obj -- 1710
						if chunk.error then -- 1710
							providerError = chunk.error -- 1712
							____exports.Log( -- 1713
								"Warn", -- 1713
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1713
							) -- 1713
							return -- 1714
						end -- 1714
						responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1716
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1717
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1718
						if chunk.usage and type(chunk.usage) == "table" then -- 1718
							responseUsage = chunk.usage -- 1720
						end -- 1720
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1722
						if not __TS__ArrayIsArray(chunk.choices) then -- 1722
							missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1724
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1724
								____exports.Log( -- 1726
									"Warn", -- 1726
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1726
								) -- 1726
							end -- 1726
						elseif #choices == 0 then -- 1726
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1729
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1729
								____exports.Log( -- 1731
									"Warn", -- 1731
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1731
								) -- 1731
							end -- 1731
						else -- 1731
							choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1734
						end -- 1734
						do -- 1734
							local i = 0 -- 1736
							while i < #choices do -- 1736
								local choice = choices[i + 1] -- 1737
								local index = type(choice.index) == "number" and choice.index or i -- 1738
								if states[index] == nil then -- 1738
									states[index] = {index = index, message = {role = "assistant"}} -- 1739
								end -- 1739
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1743
								i = i + 1 -- 1736
							end -- 1736
						end -- 1736
						if onChunk ~= nil then -- 1736
							onChunk( -- 1745
								buildStreamResponse( -- 1746
									states, -- 1746
									model, -- 1746
									responseId, -- 1746
									responseCreated, -- 1746
									responseObject, -- 1746
									providerError, -- 1746
									responseUsage -- 1746
								), -- 1746
								{ -- 1747
									id = chunk.id or "", -- 1748
									created = chunk.created or 0, -- 1749
									object = chunk.object or "", -- 1750
									model = chunk.model or model, -- 1751
									choices = choices -- 1752
								} -- 1752
							) -- 1752
						end -- 1752
					end, -- 1704
					onDone = function() -- 1756
						doneChunkSeen = true -- 1757
					end, -- 1756
					onError = function(err, context) -- 1759
						parseErrorCount = parseErrorCount + 1 -- 1760
						____exports.Log( -- 1761
							"Warn", -- 1761
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1761
						) -- 1761
					end -- 1759
				}, -- 1759
				function() return (stopToken and stopToken.stopped) == true end -- 1763
			) -- 1763
			local ____try = __TS__AsyncAwaiter(function() -- 1763
				__TS__Await(postLLM( -- 1765
					fitted.messages, -- 1765
					url, -- 1765
					apiKey, -- 1765
					model, -- 1765
					options, -- 1765
					true, -- 1765
					resolvedConfig.customOptions, -- 1765
					function(data) -- 1765
						if stopToken and stopToken.stopped then -- 1765
							return true -- 1766
						end -- 1766
						httpChunkCount = httpChunkCount + 1 -- 1767
						rawStreamBytes = rawStreamBytes + #data -- 1768
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1768
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1770
						end -- 1770
						parser.append(data) -- 1772
						return false -- 1773
					end, -- 1765
					stopToken, -- 1774
					resolvedConfig.studioGateway -- 1774
				)) -- 1774
				__TS__Await(parser.finish()) -- 1775
			end) -- 1775
			____try = ____try.catch( -- 1775
				____try, -- 1775
				function(____, e) -- 1775
					return __TS__AsyncAwaiter(function() -- 1775
						parser.cancel() -- 1777
						error(e, 0) -- 1778
					end) -- 1778
				end -- 1778
			) -- 1778
			__TS__Await(____try) -- 1764
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1764
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1781
				if rawResponse and type(rawResponse) == "table" then -- 1781
					local rawResponseObj = rawResponse -- 1783
					if rawResponseObj.error then -- 1783
						providerError = rawResponseObj.error -- 1785
						lastJSONPreview = previewText( -- 1786
							normalizeLLMJSONResponse(rawStreamPreview), -- 1786
							500 -- 1786
						) -- 1786
						____exports.Log( -- 1787
							"Warn", -- 1787
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1787
						) -- 1787
					end -- 1787
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1787
						responseUsage = rawResponseObj.usage -- 1790
					end -- 1790
				end -- 1790
			end -- 1790
			local response = buildStreamResponse( -- 1794
				states, -- 1794
				model, -- 1794
				responseId, -- 1794
				responseCreated, -- 1794
				responseObject, -- 1794
				providerError, -- 1794
				responseUsage -- 1794
			) -- 1794
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1795
			local choiceCount = response.choices and #response.choices or 0 -- 1796
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1797
			____exports.Log( -- 1798
				"Info", -- 1798
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1798
			) -- 1798
			if not doneChunkSeen then -- 1798
				local rawPreview = previewText( -- 1800
					____exports.sanitizeUTF8(rawStreamPreview), -- 1800
					1200 -- 1800
				) -- 1800
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1801
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1802
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1803
				____hasReturned = true -- 1804
				____returnValue = { -- 1804
					success = false, -- 1805
					message = message, -- 1806
					raw = rawStreamPreview, -- 1807
					response = response, -- 1808
					tokenUsage = tokenUsage -- 1809
				} -- 1809
				return -- 1804
			end -- 1804
			if not response.choices or #response.choices == 0 then -- 1804
				local providerMessage = providerError and providerError.message or "" -- 1813
				local providerType = providerError and providerError.type or "" -- 1814
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1815
				local details = table.concat( -- 1818
					__TS__ArrayFilter( -- 1818
						{providerType, providerCode}, -- 1818
						function(____, part) return part ~= "" end -- 1818
					), -- 1818
					"/" -- 1818
				) -- 1818
				local rawPreview = previewText( -- 1819
					____exports.sanitizeUTF8(rawStreamPreview), -- 1819
					1200 -- 1819
				) -- 1819
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1820
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1821
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1824
				____hasReturned = true -- 1825
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1825
				return -- 1825
			end -- 1825
			____hasReturned = true -- 1832
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1832
			return -- 1832
		end) -- 1832
		____try = ____try.catch( -- 1832
			____try, -- 1832
			function(____, e) -- 1832
				return __TS__AsyncAwaiter(function() -- 1832
					if stopToken and stopToken.stopped then -- 1832
						local reason = stopToken.reason or "request cancelled" -- 1839
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1840
						____hasReturned = true -- 1841
						____returnValue = {success = false, message = reason} -- 1841
						return -- 1841
					end -- 1841
					____exports.Log( -- 1843
						"Error", -- 1843
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1843
					) -- 1843
					____hasReturned = true -- 1844
					____returnValue = { -- 1844
						success = false, -- 1844
						message = tostring(e) -- 1844
					} -- 1844
					return -- 1844
				end) -- 1844
			end -- 1844
		) -- 1844
		__TS__Await(____try) -- 1685
		if ____hasReturned then -- 1685
			return ____awaiter_resolve(nil, ____returnValue) -- 1685
		end -- 1685
	end) -- 1685
end -- 1644
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1848
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1848
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1854
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1855
		local resolvedConfig = config or (function() -- 1858
			local configRes = ____exports.getActiveLLMConfig() -- 1859
			if not configRes.success then -- 1859
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1861
				return nil -- 1862
			end -- 1862
			return configRes.config -- 1864
		end)() -- 1858
		if not resolvedConfig then -- 1858
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1858
		end -- 1858
		local url = resolvedConfig.url -- 1858
		local model = resolvedConfig.model -- 1858
		local apiKey = resolvedConfig.apiKey -- 1858
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1870
		if fitted.fittedTokens > fitted.budgetTokens then -- 1870
			return ____awaiter_resolve(nil, {success = false, message = "LLM context budget is insufficient for the configured output limit and request. Reduce max_tokens/max_completion_tokens or increase contextWindow."}) -- 1870
		end -- 1870
		____exports.Log( -- 1874
			"Info", -- 1874
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1874
		) -- 1874
		if stopToken and stopToken.stopped then -- 1874
			local reason = stopToken.reason or "request cancelled" -- 1876
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1877
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1877
		end -- 1877
		local ____hasReturned, ____returnValue -- 1877
		local ____try = __TS__AsyncAwaiter(function() -- 1877
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1881
				fitted.messages, -- 1881
				url, -- 1881
				apiKey, -- 1881
				model, -- 1881
				options, -- 1881
				false, -- 1881
				resolvedConfig.customOptions, -- 1881
				nil, -- 1881
				stopToken, -- 1881
				resolvedConfig.studioGateway -- 1881
			))) -- 1881
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1882
			____exports.Log( -- 1883
				"Info", -- 1883
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1883
			) -- 1883
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1884
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1884
				local rawPreview = previewText(raw) -- 1886
				____exports.Log( -- 1887
					"Error", -- 1887
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1887
				) -- 1887
				____hasReturned = true -- 1888
				____returnValue = { -- 1888
					success = false, -- 1889
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1890
					raw = raw -- 1891
				} -- 1891
				return -- 1888
			end -- 1888
			local responseObj = response -- 1894
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1895
			____exports.Log( -- 1896
				"Info", -- 1896
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1896
			) -- 1896
			if not responseObj.choices or #responseObj.choices == 0 then -- 1896
				local providerError = responseObj.error -- 1898
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1899
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1902
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1905
				local details = table.concat( -- 1908
					__TS__ArrayFilter( -- 1908
						{providerType, providerCode}, -- 1908
						function(____, part) return part ~= "" end -- 1908
					), -- 1908
					"/" -- 1908
				) -- 1908
				local rawPreview = previewText(raw, 400) -- 1909
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1910
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1913
				____hasReturned = true -- 1914
				____returnValue = {success = false, message = message, raw = raw} -- 1914
				return -- 1914
			end -- 1914
			____hasReturned = true -- 1920
			____returnValue = {success = true, response = responseObj} -- 1920
			return -- 1920
		end) -- 1920
		____try = ____try.catch( -- 1920
			____try, -- 1920
			function(____, e) -- 1920
				return __TS__AsyncAwaiter(function() -- 1920
					if stopToken and stopToken.stopped then -- 1920
						local reason = stopToken.reason or "request cancelled" -- 1926
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1927
						____hasReturned = true -- 1928
						____returnValue = {success = false, message = reason} -- 1928
						return -- 1928
					end -- 1928
					____exports.Log( -- 1930
						"Error", -- 1930
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1930
					) -- 1930
					____hasReturned = true -- 1931
					____returnValue = { -- 1931
						success = false, -- 1931
						message = tostring(e) -- 1931
					} -- 1931
					return -- 1931
				end) -- 1931
			end -- 1931
		) -- 1931
		__TS__Await(____try) -- 1880
		if ____hasReturned then -- 1880
			return ____awaiter_resolve(nil, ____returnValue) -- 1880
		end -- 1880
	end) -- 1880
end -- 1848
return ____exports -- 1848