-- [ts]: Utils.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
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
function ____exports.sanitizeUTF8(text) -- 79
	if not text then -- 79
		return "" -- 80
	end -- 80
	local remaining = text -- 81
	local output = "" -- 82
	while remaining ~= "" do -- 82
		local len, invalidPos = utf8.len(remaining) -- 84
		if len ~= nil then -- 84
			output = output .. remaining -- 86
			break -- 87
		end -- 87
		local badPos = type(invalidPos) == "number" and invalidPos or 1 -- 89
		if badPos > 1 then -- 89
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1) -- 91
		end -- 91
		remaining = __TS__StringSubstring(remaining, badPos) -- 93
	end -- 93
	return output -- 95
end -- 79
function normalizeReasoningEffort(value) -- 836
	if type(value) ~= "string" then -- 836
		return nil -- 837
	end -- 837
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 838
	return normalized ~= "" and normalized or nil -- 839
end -- 839
local LOG_LEVEL = App.debugging and 3 or 2 -- 4
function ____exports.setLogLevel(level) -- 5
	LOG_LEVEL = level -- 6
end -- 5
local LLM_TIMEOUT = 600 -- 9
local LLM_STREAM_TIMEOUT = 600 -- 10
local LLM_STREAM_RAW_DEBUG_MAX = 12000 -- 11
local LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT = 5 -- 12
____exports.Log = function(____type, msg) -- 14
	if LOG_LEVEL < 1 then -- 14
		return -- 15
	elseif LOG_LEVEL < 2 and (____type == "Info" or ____type == "Warn") then -- 15
		return -- 16
	elseif LOG_LEVEL < 3 and ____type == "Info" then -- 16
		return -- 17
	end -- 17
	DoraLog(____type, msg) -- 18
end -- 14
local TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz" -- 45
local TOOL_CALL_ID_COUNTER = 0 -- 46
local function toBase36(value) -- 48
	if value <= 0 then -- 48
		return "0" -- 49
	end -- 49
	local remaining = math.floor(value) -- 50
	local out = "" -- 51
	while remaining > 0 do -- 51
		local digit = remaining % 36 -- 53
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out -- 54
		remaining = math.floor(remaining / 36) -- 55
	end -- 55
	return out -- 57
end -- 48
function ____exports.createLocalToolCallId() -- 60
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1 -- 61
	local timePart = toBase36(os.time()) -- 62
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER) -- 63
	return ("tc" .. timePart) .. counterPart -- 64
end -- 60
local function previewText(text, maxLen) -- 72
	if maxLen == nil then -- 72
		maxLen = 200 -- 72
	end -- 72
	if not text then -- 72
		return "" -- 73
	end -- 73
	local compact = __TS__StringReplace( -- 74
		__TS__StringReplace(text, "\r", "\\r"), -- 74
		"\n", -- 74
		"\\n" -- 74
	) -- 74
	if #compact <= maxLen then -- 74
		return compact -- 75
	end -- 75
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 76
end -- 72
local function sanitizeJSONValue(value) -- 98
	if type(value) == "string" then -- 98
		return ____exports.sanitizeUTF8(value) -- 99
	end -- 99
	if __TS__ArrayIsArray(value) then -- 99
		return __TS__ArrayMap( -- 101
			value, -- 101
			function(____, item) return sanitizeJSONValue(item) end -- 101
		) -- 101
	end -- 101
	if value and type(value) == "table" then -- 101
		local result = {} -- 104
		for key in pairs(value) do -- 105
			result[key] = sanitizeJSONValue(value[key]) -- 106
		end -- 106
		return result -- 108
	end -- 108
	return value -- 110
end -- 98
function ____exports.safeJsonEncode(value, format, emptyAsArray, numAsStr, maxDepth) -- 113
	if format == nil then -- 113
		format = false -- 113
	end -- 113
	if emptyAsArray == nil then -- 113
		emptyAsArray = true -- 113
	end -- 113
	if numAsStr == nil then -- 113
		numAsStr = false -- 113
	end -- 113
	if maxDepth == nil then -- 113
		maxDepth = 128 -- 113
	end -- 113
	return json.encode( -- 114
		sanitizeJSONValue(value), -- 115
		format, -- 116
		emptyAsArray, -- 117
		numAsStr, -- 118
		maxDepth -- 119
	) -- 119
end -- 113
function ____exports.safeJsonDecode(text) -- 123
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 124
	if value == nil then -- 124
		return value, err -- 126
	end -- 126
	return sanitizeJSONValue(value), err -- 128
end -- 123
local function normalizeLLMJSONResponse(text) -- 131
	return __TS__StringTrim(text) -- 132
end -- 131
local function utf8TakeHead(text, maxChars) -- 135
	if maxChars <= 0 or text == "" then -- 135
		return "" -- 136
	end -- 136
	local nextPos = utf8.offset(text, maxChars + 1) -- 137
	if nextPos == nil then -- 137
		return text -- 138
	end -- 138
	return string.sub(text, 1, nextPos - 1) -- 139
end -- 135
local function utf8TakeTail(text, maxChars) -- 142
	if maxChars <= 0 or text == "" then -- 142
		return "" -- 143
	end -- 143
	local charLen = utf8.len(text) -- 144
	if charLen == nil or charLen <= maxChars then -- 144
		return text -- 145
	end -- 145
	local startChar = math.max(1, charLen - maxChars + 1) -- 146
	local startPos = utf8.offset(text, startChar) -- 147
	if startPos == nil then -- 147
		return text -- 148
	end -- 148
	return string.sub(text, startPos) -- 149
end -- 142
function ____exports.estimateTextTokens(text) -- 152
	if not text then -- 152
		return 0 -- 153
	end -- 153
	return App:estimateTokens(text) -- 154
end -- 152
local function estimateMessagesTokens(messages) -- 157
	local total = 0 -- 158
	do -- 158
		local i = 0 -- 159
		while i < #messages do -- 159
			local message = messages[i + 1] -- 160
			total = total + 8 -- 161
			total = total + ____exports.estimateTextTokens(message.role or "") -- 162
			total = total + ____exports.estimateTextTokens(message.content or "") -- 163
			total = total + ____exports.estimateTextTokens(message.name or "") -- 164
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 165
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 166
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({})) -- 167
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 168
			i = i + 1 -- 159
		end -- 159
	end -- 159
	return total -- 170
end -- 157
local function estimateOptionsTokens(options) -- 173
	local text = ____exports.safeJsonEncode(options) -- 174
	return text and ____exports.estimateTextTokens(text) or 0 -- 175
end -- 173
local function getReservedOutputTokens(options, contextWindow) -- 178
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 179
	if explicitMax > 0 then -- 179
		return math.max(256, explicitMax) -- 184
	end -- 184
	return math.max( -- 185
		1024, -- 185
		math.floor(contextWindow * 0.2) -- 185
	) -- 185
end -- 178
local function getInputTokenBudget(messages, options, config) -- 188
	local contextWindow = math.max(64000, config.contextWindow) -- 189
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 190
	local optionTokens = estimateOptionsTokens(options) -- 191
	local structuralOverhead = math.max(256, #messages * 16) -- 192
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 193
end -- 188
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 196
	if budgetTokens <= 0 or text == "" then -- 196
		return "" -- 197
	end -- 197
	local estimated = ____exports.estimateTextTokens(text) -- 198
	if estimated <= budgetTokens then -- 198
		return text -- 199
	end -- 199
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 200
	local targetChars = math.max( -- 201
		200, -- 201
		math.floor(budgetTokens * charsPerToken) -- 201
	) -- 201
	local keepHead = math.max( -- 202
		0, -- 202
		math.floor(targetChars * 0.35) -- 202
	) -- 202
	local keepTail = math.max(0, targetChars - keepHead) -- 203
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 204
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 205
	return (head .. "\n...\n") .. tail -- 206
end -- 196
local function isXMLWhitespaceChar(ch) -- 209
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 210
end -- 209
local function findLineStart(value, from) -- 213
	local i = from -- 214
	while i >= 0 do -- 214
		if __TS__StringAccess(value, i) == "\n" then -- 214
			return i + 1 -- 216
		end -- 216
		i = i - 1 -- 217
	end -- 217
	return 0 -- 219
end -- 213
local function findLastLiteral(text, needle) -- 222
	if needle == "" then -- 222
		return #text -- 223
	end -- 223
	local last = -1 -- 224
	local from = 0 -- 225
	while from <= #text - #needle do -- 225
		local pos = (string.find( -- 227
			text, -- 227
			needle, -- 227
			math.max(from + 1, 1), -- 227
			true -- 227
		) or 0) - 1 -- 227
		if pos < 0 then -- 227
			break -- 228
		end -- 228
		last = pos -- 229
		from = pos + 1 -- 230
	end -- 230
	return last -- 232
end -- 222
local function unwrapXMLRawText(text) -- 235
	local trimmed = __TS__StringTrim(text) -- 236
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 236
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 238
	end -- 238
	return text -- 240
end -- 235
local function readSimpleXMLTagName(source, openStart, openEnd) -- 243
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 244
	if rawTag == "" then -- 244
		return { -- 246
			success = false, -- 246
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 246
		} -- 246
	end -- 246
	local selfClosing = false -- 248
	local tagText = rawTag -- 249
	if __TS__StringEndsWith(tagText, "/") then -- 249
		selfClosing = true -- 251
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 252
	end -- 252
	local tagName = "" -- 254
	do -- 254
		local i = 0 -- 255
		while i < #tagText do -- 255
			local ch = __TS__StringAccess(tagText, i) -- 256
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 256
				break -- 257
			end -- 257
			tagName = tagName .. ch -- 258
			i = i + 1 -- 255
		end -- 255
	end -- 255
	if tagName == "" then -- 255
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 261
	end -- 261
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 263
end -- 243
local function findMatchingXMLClose(source, tagName, contentStart) -- 266
	local sameOpenPrefix = "<" .. tagName -- 267
	local sameCloseToken = ("</" .. tagName) .. ">" -- 268
	local pos = contentStart -- 269
	local depth = 1 -- 270
	while pos < #source do -- 270
		do -- 270
			local lt = (string.find( -- 272
				source, -- 272
				"<", -- 272
				math.max(pos + 1, 1), -- 272
				true -- 272
			) or 0) - 1 -- 272
			if lt < 0 then -- 272
				break -- 273
			end -- 273
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 273
				local cdataEnd = (string.find( -- 275
					source, -- 275
					"]]>", -- 275
					math.max(lt + 9 + 1, 1), -- 275
					true -- 275
				) or 0) - 1 -- 275
				if cdataEnd < 0 then -- 275
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 276
				end -- 276
				pos = cdataEnd + 3 -- 277
				goto __continue67 -- 278
			end -- 278
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 281
					source, -- 281
					"-->",
					math.max(lt + 4 + 1, 1), -- 281
					true -- 281
				) or 0) - 1 -- 281
				if commentEnd < 0 then -- 281
					return {success = false, message = "invalid xml: unterminated comment"} -- 282
				end -- 282
				pos = commentEnd + 3 -- 283
				goto __continue67 -- 284
			end -- 284
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 284
				depth = depth - 1 -- 287
				if depth == 0 then -- 287
					return {success = true, closeStart = lt} -- 288
				end -- 288
				pos = lt + #sameCloseToken -- 289
				goto __continue67 -- 290
			end -- 290
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 290
				local openEnd = (string.find( -- 293
					source, -- 293
					">", -- 293
					math.max(lt + 1, 1), -- 293
					true -- 293
				) or 0) - 1 -- 293
				if openEnd < 0 then -- 293
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 294
				end -- 294
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 295
				if not tagInfo.success then -- 295
					return tagInfo -- 296
				end -- 296
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 296
					depth = depth + 1 -- 298
				end -- 298
				pos = openEnd + 1 -- 300
				goto __continue67 -- 301
			end -- 301
			local genericEnd = (string.find( -- 303
				source, -- 303
				">", -- 303
				math.max(lt + 1, 1), -- 303
				true -- 303
			) or 0) - 1 -- 303
			if genericEnd < 0 then -- 303
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 304
			end -- 304
			pos = genericEnd + 1 -- 305
		end -- 305
		::__continue67:: -- 305
	end -- 305
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 307
end -- 266
function ____exports.extractXMLFromText(text) -- 310
	local source = __TS__StringTrim(text) -- 311
	local function extractFencedBlock(fence) -- 312
		if not __TS__StringStartsWith(source, fence) then -- 312
			return nil -- 313
		end -- 313
		local firstLineEnd = (string.find( -- 314
			source, -- 314
			"\n", -- 314
			math.max(1, 1), -- 314
			true -- 314
		) or 0) - 1 -- 314
		if firstLineEnd < 0 then -- 314
			return nil -- 315
		end -- 315
		local searchPos = firstLineEnd + 1 -- 316
		local closingFencePositions = {} -- 317
		while searchPos < #source do -- 317
			local ____end = (string.find( -- 319
				source, -- 319
				"```", -- 319
				math.max(searchPos + 1, 1), -- 319
				true -- 319
			) or 0) - 1 -- 319
			if ____end < 0 then -- 319
				break -- 320
			end -- 320
			local lineStart = findLineStart(source, ____end - 1) -- 321
			local lineEnd = (string.find( -- 322
				source, -- 322
				"\n", -- 322
				math.max(____end + 1, 1), -- 322
				true -- 322
			) or 0) - 1 -- 322
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 323
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 323
				closingFencePositions[#closingFencePositions + 1] = ____end -- 325
			end -- 325
			searchPos = ____end + 1 -- 327
		end -- 327
		do -- 327
			local i = #closingFencePositions - 1 -- 329
			while i >= 0 do -- 329
				do -- 329
					local closingFencePos = closingFencePositions[i + 1] -- 330
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 331
					if afterFence ~= "" then -- 331
						goto __continue88 -- 332
					end -- 332
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 333
				end -- 333
				::__continue88:: -- 333
				i = i - 1 -- 329
			end -- 329
		end -- 329
		return nil -- 335
	end -- 312
	local xmlBlock = extractFencedBlock("```xml") -- 337
	if xmlBlock ~= nil then -- 337
		return xmlBlock -- 338
	end -- 338
	local genericBlock = extractFencedBlock("```") -- 339
	if genericBlock ~= nil then -- 339
		return genericBlock -- 340
	end -- 340
	return source -- 341
end -- 310
function ____exports.parseSimpleXMLChildren(source) -- 344
	local result = {} -- 345
	local pos = 0 -- 346
	while pos < #source do -- 346
		do -- 346
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 346
				pos = pos + 1 -- 348
			end -- 348
			if pos >= #source then -- 348
				break -- 349
			end -- 349
			if __TS__StringAccess(source, pos) ~= "<" then -- 349
				return { -- 351
					success = false, -- 351
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 351
				} -- 351
			end -- 351
			if __TS__StringStartsWith(source, "</", pos) then -- 351
				return { -- 354
					success = false, -- 354
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 354
				} -- 354
			end -- 354
			local openEnd = (string.find( -- 356
				source, -- 356
				">", -- 356
				math.max(pos + 1, 1), -- 356
				true -- 356
			) or 0) - 1 -- 356
			if openEnd < 0 then -- 356
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 358
			end -- 358
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 360
			if not tagInfo.success then -- 360
				return tagInfo -- 361
			end -- 361
			if tagInfo.selfClosing then -- 361
				result[tagInfo.tagName] = "" -- 363
				pos = openEnd + 1 -- 364
				goto __continue93 -- 365
			end -- 365
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 367
			if not closeRes.success then -- 367
				return closeRes -- 368
			end -- 368
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 369
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 370
			pos = closeRes.closeStart + #closeToken -- 371
		end -- 371
		::__continue93:: -- 371
	end -- 371
	return {success = true, obj = result} -- 373
end -- 344
function ____exports.parseXMLObjectFromText(text, rootTag) -- 376
	local xmlText = ____exports.extractXMLFromText(text) -- 377
	local rootOpen = ("<" .. rootTag) .. ">" -- 378
	local rootClose = ("</" .. rootTag) .. ">" -- 379
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 380
	local ____end = findLastLiteral(xmlText, rootClose) -- 381
	if start < 0 or ____end < start then -- 381
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 383
	end -- 383
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 385
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 386
	if beforeRoot ~= "" or afterRoot ~= "" then -- 386
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 388
	end -- 388
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 390
	return ____exports.parseSimpleXMLChildren(rootContent) -- 391
end -- 376
function ____exports.fitMessagesToContext(messages, options, config) -- 394
	local modelName = string.lower(config.model) -- 401
	local shouldEchoReasoningContent = __TS__ArraySome( -- 402
		messages, -- 402
		function(____, message) return type(message.reasoning_content) == "string" end -- 402
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 402
	local cloned = __TS__ArrayMap( -- 406
		messages, -- 406
		function(____, message) -- 406
			local clonedMessage = __TS__ObjectAssign({}, message) -- 407
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 407
				clonedMessage.reasoning_content = "" -- 413
			end -- 413
			return clonedMessage -- 415
		end -- 406
	) -- 406
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 417
	local originalTokens = estimateMessagesTokens(cloned) -- 418
	if originalTokens <= budgetTokens then -- 418
		return { -- 420
			messages = cloned, -- 421
			trimmed = false, -- 422
			originalTokens = originalTokens, -- 423
			fittedTokens = originalTokens, -- 424
			budgetTokens = budgetTokens -- 425
		} -- 425
	end -- 425
	local function roleOverhead(message) -- 429
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 429
	end -- 429
	local fixedOverhead = 0 -- 430
	local contentIndexes = {} -- 431
	do -- 431
		local i = 0 -- 432
		while i < #cloned do -- 432
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 433
			contentIndexes[#contentIndexes + 1] = i -- 434
			i = i + 1 -- 432
		end -- 432
	end -- 432
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 436
	if #contentIndexes == 1 then -- 436
		local idx = contentIndexes[1] -- 438
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 439
		local fittedTokens = estimateMessagesTokens(cloned) -- 440
		return { -- 441
			messages = cloned, -- 442
			trimmed = true, -- 443
			originalTokens = originalTokens, -- 444
			fittedTokens = fittedTokens, -- 445
			budgetTokens = budgetTokens -- 446
		} -- 446
	end -- 446
	local nonSystemIndexes = {} -- 450
	local systemIndexes = {} -- 451
	do -- 451
		local i = 0 -- 452
		while i < #cloned do -- 452
			if cloned[i + 1].role == "system" then -- 452
				systemIndexes[#systemIndexes + 1] = i -- 453
			else -- 453
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 454
			end -- 454
			i = i + 1 -- 452
		end -- 452
	end -- 452
	local ____array_0 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 452
	__TS__SparseArrayPush( -- 452
		____array_0, -- 452
		table.unpack(systemIndexes) -- 456
	) -- 456
	local priorityIndexes = {__TS__SparseArraySpread(____array_0)} -- 456
	local remainingContentBudget = contentBudget -- 457
	do -- 457
		local i = #priorityIndexes - 1 -- 458
		while i >= 0 do -- 458
			local idx = priorityIndexes[i + 1] -- 459
			local message = cloned[idx + 1] -- 460
			local minBudget = message.role == "system" and 96 or 192 -- 461
			local target = math.max( -- 462
				minBudget, -- 462
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 462
			) -- 462
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 463
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 464
			remainingContentBudget = math.max(0, remainingContentBudget) -- 465
			i = i - 1 -- 458
		end -- 458
	end -- 458
	local fittedTokens = estimateMessagesTokens(cloned) -- 468
	if fittedTokens > budgetTokens then -- 468
		do -- 468
			local i = 0 -- 470
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 470
				local idx = priorityIndexes[i + 1] -- 471
				local message = cloned[idx + 1] -- 472
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 473
				local excess = fittedTokens - budgetTokens -- 474
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 475
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 476
				fittedTokens = estimateMessagesTokens(cloned) -- 477
				i = i + 1 -- 470
			end -- 470
		end -- 470
	end -- 470
	if fittedTokens > budgetTokens then -- 470
		do -- 470
			local i = 0 -- 481
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 481
				do -- 481
					local idx = priorityIndexes[i + 1] -- 482
					if cloned[idx + 1].role == "system" then -- 482
						goto __continue125 -- 483
					end -- 483
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 484
					fittedTokens = estimateMessagesTokens(cloned) -- 485
				end -- 485
				::__continue125:: -- 485
				i = i + 1 -- 481
			end -- 481
		end -- 481
	end -- 481
	return { -- 488
		messages = cloned, -- 489
		trimmed = true, -- 490
		originalTokens = originalTokens, -- 491
		fittedTokens = fittedTokens, -- 492
		budgetTokens = budgetTokens -- 493
	} -- 493
end -- 394
local function isDisabledReasoningValue(value) -- 503
	if type(value) ~= "string" then -- 503
		return false -- 504
	end -- 504
	local normalized = string.lower(__TS__StringTrim(value)) -- 505
	return normalized == "disabled" or normalized == "disable" or normalized == "off" or normalized == "none" or normalized == "false" or normalized == "0" -- 506
end -- 503
local LLM_PROVIDER_ADAPTERS = {{ -- 514
	id = "xiaomi-mimo", -- 516
	matches = function(url, model) -- 517
		local urlLower = string.lower(url) -- 518
		local modelLower = string.lower(model) -- 519
		return __TS__StringIncludes(urlLower, "xiaomimimo.com") or __TS__StringIncludes(modelLower, "mimo") -- 520
	end, -- 517
	prepareRequest = function(data) -- 522
		if isDisabledReasoningValue(data.reasoning_effort) and data.thinking == nil then -- 522
			data.thinking = {type = "disabled"} -- 527
		end -- 527
		if type(data.reasoning_effort) == "string" then -- 527
			__TS__Delete(data, "reasoning_effort") -- 530
		end -- 530
	end -- 522
}} -- 522
local function prepareLLMRequestData(messages, url, model, options, stream) -- 536
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = stream}) -- 543
	local adapter = __TS__ArrayFind( -- 549
		LLM_PROVIDER_ADAPTERS, -- 549
		function(____, item) return item.matches(url, model) end -- 549
	) -- 549
	if adapter ~= nil then -- 549
		adapter.prepareRequest(data) -- 550
	end -- 550
	return data -- 551
end -- 536
local function postLLM(messages, url, apiKey, model, options, stream, receiver, stopToken) -- 554
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 564
	local data = prepareLLMRequestData( -- 565
		messages, -- 565
		url, -- 565
		model, -- 565
		options, -- 565
		stream -- 565
	) -- 565
	if stopToken == nil then -- 565
		stopToken = {stopped = false} -- 566
	end -- 566
	return __TS__New( -- 567
		__TS__Promise, -- 567
		function(____, resolve, reject) -- 567
			local requestId = 0 -- 568
			local settled = false -- 569
			local function finishResolve(text) -- 570
				if settled then -- 570
					return -- 571
				end -- 571
				settled = true -- 572
				resolve(nil, text) -- 573
			end -- 570
			local function finishReject(err) -- 575
				if settled then -- 575
					return -- 576
				end -- 576
				settled = true -- 577
				reject(nil, err) -- 578
			end -- 575
			Director.systemScheduler:schedule(function() -- 580
				if not settled then -- 580
					if stopToken.stopped then -- 580
						if requestId ~= 0 then -- 580
							HttpClient:cancel(requestId) -- 584
							requestId = 0 -- 585
						end -- 585
						finishReject("request cancelled") -- 587
						return true -- 588
					end -- 588
					return false -- 590
				end -- 590
				return true -- 592
			end) -- 580
			Director.systemScheduler:schedule(once(function() -- 594
				emit( -- 595
					"LLM_IN", -- 595
					table.concat( -- 595
						__TS__ArrayMap( -- 595
							messages, -- 595
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 595
						), -- 595
						"\n" -- 595
					) -- 595
				) -- 595
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 596
				if jsonStr ~= nil then -- 596
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", "Accept: application/json"} -- 598
					requestId = receiver and HttpClient:post( -- 603
						url, -- 604
						headers, -- 604
						jsonStr, -- 604
						requestTimeout, -- 604
						function(data) -- 604
							if stopToken.stopped then -- 604
								return true -- 605
							end -- 605
							return receiver(data) -- 606
						end, -- 604
						function(data) -- 607
							requestId = 0 -- 608
							if data ~= nil then -- 608
								finishResolve(data) -- 610
							else -- 610
								finishReject("failed to get http response") -- 612
							end -- 612
						end -- 607
					) or HttpClient:post( -- 607
						url, -- 615
						headers, -- 615
						jsonStr, -- 615
						requestTimeout, -- 615
						function(data) -- 615
							requestId = 0 -- 616
							if stopToken.stopped then -- 616
								finishReject("request cancelled") -- 618
								return -- 619
							end -- 619
							if data ~= nil then -- 619
								finishResolve(data) -- 622
							else -- 622
								finishReject("failed to get http response") -- 624
							end -- 624
						end -- 615
					) -- 615
					if requestId == 0 then -- 615
						finishReject("failed to schedule http request") -- 628
					elseif stopToken.stopped then -- 628
						HttpClient:cancel(requestId) -- 630
						requestId = 0 -- 631
						finishReject("request cancelled") -- 632
					end -- 632
				else -- 632
					finishReject(err) -- 635
				end -- 635
			end)) -- 594
		end -- 567
	) -- 567
end -- 554
function ____exports.createSSEJSONParser(opts) -- 645
	local buffer = "" -- 650
	local eventDataLines = {} -- 651
	local function flushEventIfAny() -- 653
		if #eventDataLines == 0 then -- 653
			return -- 654
		end -- 654
		local dataPayload = table.concat(eventDataLines, "\n") -- 656
		eventDataLines = {} -- 657
		if dataPayload == "[DONE]" then -- 657
			local ____opt_3 = opts.onDone -- 657
			if ____opt_3 ~= nil then -- 657
				____opt_3(dataPayload) -- 660
			end -- 660
			return -- 661
		end -- 661
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 664
		if err == nil then -- 664
			opts.onJSON(obj, dataPayload) -- 666
		else -- 666
			local ____opt_5 = opts.onError -- 666
			if ____opt_5 ~= nil then -- 666
				____opt_5(err, {raw = dataPayload}) -- 668
			end -- 668
		end -- 668
	end -- 653
	local function feed(chunk) -- 672
		buffer = buffer .. chunk -- 673
		while true do -- 673
			do -- 673
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 676
				if nl < 0 then -- 676
					break -- 677
				end -- 677
				local line = __TS__StringSlice(buffer, 0, nl) -- 679
				buffer = __TS__StringSlice(buffer, nl + 1) -- 680
				if __TS__StringEndsWith(line, "\r") then -- 680
					line = string.sub(line, 1, -2) -- 682
				end -- 682
				if line == "" then -- 682
					flushEventIfAny() -- 685
					goto __continue167 -- 686
				end -- 686
				if __TS__StringStartsWith(line, ":") then -- 686
					goto __continue167 -- 690
				end -- 690
				if __TS__StringStartsWith(line, "data:") then -- 690
					local v = string.sub(line, 6) -- 693
					if __TS__StringStartsWith(v, " ") then -- 693
						v = string.sub(v, 2) -- 694
					end -- 694
					eventDataLines[#eventDataLines + 1] = v -- 695
					goto __continue167 -- 696
				end -- 696
			end -- 696
			::__continue167:: -- 696
		end -- 696
	end -- 672
	local function ____end() -- 701
		if #buffer > 0 then -- 701
			local line = buffer -- 703
			buffer = "" -- 704
			if __TS__StringEndsWith(line, "\r") then -- 704
				line = string.sub(line, 1, -2) -- 705
			end -- 705
			if __TS__StringStartsWith(line, "data:") then -- 705
				local v = string.sub(line, 6) -- 708
				if __TS__StringStartsWith(v, " ") then -- 708
					v = string.sub(v, 2) -- 709
				end -- 709
				eventDataLines[#eventDataLines + 1] = v -- 710
			end -- 710
		end -- 710
		flushEventIfAny() -- 713
	end -- 701
	return {feed = feed, ["end"] = ____end} -- 716
end -- 645
local function normalizeContextWindow(value) -- 811
	if type(value) == "number" then -- 811
		return math.max( -- 813
			64000, -- 813
			math.floor(value) -- 813
		) -- 813
	end -- 813
	return 64000 -- 815
end -- 811
local function normalizeSupportsFunctionCalling(value) -- 818
	return value == nil or value == nil or value ~= 0 -- 819
end -- 818
local function normalizeLLMTemperature(value) -- 822
	if type(value) == "number" then -- 822
		return math.max( -- 824
			0, -- 824
			math.min(2, value) -- 824
		) -- 824
	end -- 824
	return 0.1 -- 826
end -- 822
local function normalizeLLMMaxTokens(value) -- 829
	if type(value) == "number" then -- 829
		return math.max( -- 831
			1, -- 831
			math.floor(value) -- 831
		) -- 831
	end -- 831
	return 8192 -- 833
end -- 829
function ____exports.getActiveLLMConfig() -- 842
	local rows = DB:query("select * from LLMConfig", true) -- 843
	local records = {} -- 844
	if rows and #rows > 1 then -- 844
		do -- 844
			local i = 1 -- 846
			while i < #rows do -- 846
				local record = {} -- 847
				do -- 847
					local c = 0 -- 848
					while c < #rows[i + 1] do -- 848
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 849
						c = c + 1 -- 848
					end -- 848
				end -- 848
				records[#records + 1] = record -- 851
				i = i + 1 -- 846
			end -- 846
		end -- 846
	end -- 846
	local config = __TS__ArrayFind( -- 854
		records, -- 854
		function(____, r) return r.active ~= 0 end -- 854
	) -- 854
	if not config then -- 854
		return {success = false, message = "no active LLM config"} -- 856
	end -- 856
	local url = config.url -- 856
	local model = config.model -- 856
	local api_key = config.api_key -- 856
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 856
		return {success = false, message = "got invalude LLM config"} -- 860
	end -- 860
	return { -- 862
		success = true, -- 863
		config = { -- 864
			url = url, -- 865
			model = model, -- 866
			apiKey = api_key, -- 867
			contextWindow = normalizeContextWindow(config.context_window), -- 868
			temperature = normalizeLLMTemperature(config.temperature), -- 869
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 870
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 871
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 872
		} -- 872
	} -- 872
end -- 842
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 877
	local callEvent -- 883
	if event.id ~= nil then -- 883
		local id = event.id -- 885
		callEvent = { -- 886
			id = nil, -- 887
			onData = function(data) -- 888
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 889
				return event.stopToken.stopped -- 890
			end, -- 888
			onCancel = function(reason) -- 892
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 893
			end, -- 892
			onDone = function() -- 895
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 896
			end -- 895
		} -- 895
	else -- 895
		callEvent = event -- 900
	end -- 900
	local ____callEvent_7 = callEvent -- 902
	local onData = ____callEvent_7.onData -- 902
	local onDone = ____callEvent_7.onDone -- 902
	local ____callEvent_8 = callEvent -- 903
	local onCancel = ____callEvent_8.onCancel -- 903
	local config = llmConfig or (function() -- 904
		local configRes = ____exports.getActiveLLMConfig() -- 905
		if not configRes.success then -- 905
			if onCancel then -- 905
				onCancel(configRes.message) -- 907
			end -- 907
			return nil -- 908
		end -- 908
		return configRes.config -- 910
	end)() -- 904
	if not config then -- 904
		return {success = false, message = "no active LLM config"} -- 913
	end -- 913
	local url = config.url -- 913
	local model = config.model -- 913
	local apiKey = config.apiKey -- 913
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 916
	if fitted.trimmed then -- 916
		____exports.Log( -- 918
			"Warn", -- 918
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 918
		) -- 918
	end -- 918
	local stopLLM = false -- 920
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 921
		local result = onData(obj) -- 923
		if result then -- 923
			stopLLM = result -- 924
		end -- 924
	end}); -- 922
	(function() -- 927
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 927
			local ____try = __TS__AsyncAwaiter(function() -- 927
				local ____array_10 = __TS__SparseArrayNew( -- 927
					fitted.messages, -- 929
					url, -- 929
					apiKey, -- 929
					model, -- 929
					options, -- 929
					true, -- 929
					function(data) -- 929
						if stopLLM then -- 929
							if onCancel then -- 929
								onCancel("LLM Stopped") -- 932
								onCancel = nil -- 933
							end -- 933
							return true -- 935
						end -- 935
						parser.feed(data) -- 937
						return false -- 938
					end -- 929
				) -- 929
				local ____temp_9 -- 939
				if event.stopToken ~= nil then -- 939
					____temp_9 = event.stopToken -- 939
				else -- 939
					____temp_9 = nil -- 939
				end -- 939
				__TS__SparseArrayPush(____array_10, ____temp_9) -- 939
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_10))) -- 929
				parser["end"]() -- 940
				if onDone then -- 940
					onDone(result) -- 942
				end -- 942
			end) -- 942
			__TS__Await(____try.catch( -- 928
				____try, -- 928
				function(____, e) -- 928
					stopLLM = true -- 945
					if onCancel then -- 945
						onCancel(tostring(e)) -- 947
						onCancel = nil -- 948
					end -- 948
				end -- 948
			)) -- 948
		end) -- 948
	end)() -- 927
	return {success = true} -- 952
end -- 877
local function mergeStreamToolCall(target, delta) -- 955
	if type(delta.id) == "string" and delta.id ~= "" then -- 955
		target.id = delta.id -- 957
	end -- 957
	if type(delta.type) == "string" and delta.type ~= "" then -- 957
		target.type = delta.type -- 960
	end -- 960
	if delta["function"] then -- 960
		if target["function"] == nil then -- 960
			target["function"] = {} -- 963
		end -- 963
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 963
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 965
		end -- 965
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 965
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 968
		end -- 968
	end -- 968
end -- 955
local function isToolCallComplete(tc) -- 973
	if type(tc.id) ~= "string" or tc.id == "" then -- 973
		return false -- 974
	end -- 974
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 974
		return false -- 975
	end -- 975
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 975
		return false -- 976
	end -- 976
	local args = tc["function"].arguments -- 977
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 977
		return false -- 978
	end -- 978
	local decoded = ____exports.safeJsonDecode(args) -- 979
	return decoded ~= nil -- 980
end -- 973
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 983
	local delta = choice.delta or ({}) -- 984
	local fullMessage = choice.message or ({}) -- 985
	local message = acc.message -- 986
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 987
	if type(role) == "string" and role ~= "" then -- 987
		message.role = role -- 991
	end -- 991
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 993
	if type(content) == "string" and content ~= "" then -- 993
		message.content = (message.content or "") .. content -- 997
	end -- 997
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 999
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 999
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1003
	end -- 1003
	local deltaToolCalls = __TS__ArrayIsArray(delta.tool_calls) and delta.tool_calls or nil -- 1005
	local messageToolCalls = __TS__ArrayIsArray(fullMessage.tool_calls) and fullMessage.tool_calls or nil -- 1006
	local toolCalls = deltaToolCalls and #deltaToolCalls > 0 and deltaToolCalls or (messageToolCalls or ({})) -- 1007
	if #toolCalls > 0 then -- 1007
		if message.tool_calls == nil then -- 1007
			message.tool_calls = {} -- 1011
		end -- 1011
		do -- 1011
			local i = 0 -- 1012
			while i < #toolCalls do -- 1012
				local item = toolCalls[i + 1] -- 1013
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1014
				local ____message_tool_calls_11, ____temp_12 = message.tool_calls, index + 1 -- 1014
				if ____message_tool_calls_11[____temp_12] == nil then -- 1014
					____message_tool_calls_11[____temp_12] = {} -- 1017
				end -- 1017
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1018
				if onToolCallReady and emittedToolCallIds then -- 1018
					local tc = message.tool_calls[index + 1] -- 1020
					if tc and isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1020
						emittedToolCallIds[tc.id] = true -- 1022
						onToolCallReady(tc) -- 1023
					end -- 1023
				end -- 1023
				i = i + 1 -- 1012
			end -- 1012
		end -- 1012
	end -- 1012
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1012
		acc.finish_reason = choice.finish_reason -- 1029
	end -- 1029
end -- 983
local function buildStreamResponse(states, model, id, created, object, providerError) -- 1033
	local indexes = __TS__ArraySort( -- 1041
		__TS__ArrayFilter( -- 1041
			__TS__ArrayMap( -- 1041
				__TS__ObjectKeys(states), -- 1041
				function(____, key) return __TS__Number(key) end -- 1042
			), -- 1042
			function(____, index) return __TS__NumberIsFinite(index) end -- 1043
		), -- 1043
		function(____, a, b) return a - b end -- 1044
	) -- 1044
	return { -- 1045
		id = id, -- 1046
		created = created, -- 1047
		object = object, -- 1048
		model = model, -- 1049
		choices = __TS__ArrayMap( -- 1050
			indexes, -- 1050
			function(____, index) -- 1050
				local state = states[index] -- 1051
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1052
			end -- 1050
		), -- 1050
		error = providerError -- 1063
	} -- 1063
end -- 1033
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1067
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1067
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1075
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1076
		local resolvedConfig = config or (function() -- 1079
			local configRes = ____exports.getActiveLLMConfig() -- 1080
			if not configRes.success then -- 1080
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1082
				return nil -- 1083
			end -- 1083
			return configRes.config -- 1085
		end)() -- 1079
		if not resolvedConfig then -- 1079
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1079
		end -- 1079
		local url = resolvedConfig.url -- 1079
		local model = resolvedConfig.model -- 1079
		local apiKey = resolvedConfig.apiKey -- 1079
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1091
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1092
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1093
		local ____model_17 = model -- 1096
		local ____url_18 = url -- 1096
		local ____temp_19 = #messages -- 1096
		local ____tostring_14 = tostring -- 1096
		local ____options_max_tokens_13 = options.max_tokens -- 1096
		if ____options_max_tokens_13 == nil then -- 1096
			____options_max_tokens_13 = "unset" -- 1096
		end -- 1096
		local ____tostring_14_result_20 = ____tostring_14(____options_max_tokens_13) -- 1096
		local ____tostring_16 = tostring -- 1096
		local ____options_temperature_15 = options.temperature -- 1096
		if ____options_temperature_15 == nil then -- 1096
			____options_temperature_15 = "unset" -- 1096
		end -- 1096
		____exports.Log( -- 1096
			"Info", -- 1096
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_17) .. " url=") .. ____url_18) .. " messages=") .. tostring(____temp_19)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_14_result_20) .. " temperature=") .. ____tostring_16(____options_temperature_15)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1096
		) -- 1096
		if stopToken and stopToken.stopped then -- 1096
			local reason = stopToken.reason or "request cancelled" -- 1098
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1099
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1099
		end -- 1099
		local ____try = __TS__AsyncAwaiter(function() -- 1099
			local states = {} -- 1103
			local emittedToolCallIds = {} -- 1104
			local responseId = nil -- 1105
			local responseCreated = nil -- 1106
			local responseObject = nil -- 1107
			local providerError -- 1108
			local httpChunkCount = 0 -- 1109
			local rawStreamBytes = 0 -- 1110
			local rawStreamPreview = "" -- 1111
			local sseJSONChunkCount = 0 -- 1112
			local choiceJSONChunkCount = 0 -- 1113
			local emptyChoicesChunkCount = 0 -- 1114
			local missingChoicesChunkCount = 0 -- 1115
			local parseErrorCount = 0 -- 1116
			local doneChunkSeen = false -- 1117
			local lastJSONPreview = "" -- 1118
			local parser = ____exports.createSSEJSONParser({ -- 1119
				onJSON = function(obj, raw) -- 1120
					sseJSONChunkCount = sseJSONChunkCount + 1 -- 1121
					lastJSONPreview = previewText(raw, 500) -- 1122
					if not obj or type(obj) ~= "table" then -- 1122
						return -- 1124
					end -- 1124
					local chunk = obj -- 1126
					if chunk.error then -- 1126
						providerError = chunk.error -- 1128
						____exports.Log( -- 1129
							"Warn", -- 1129
							"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1129
						) -- 1129
						return -- 1130
					end -- 1130
					responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1132
					responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1133
					responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1134
					local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1135
					if not __TS__ArrayIsArray(chunk.choices) then -- 1135
						missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1137
						if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1137
							____exports.Log( -- 1139
								"Warn", -- 1139
								"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1139
							) -- 1139
						end -- 1139
					elseif #choices == 0 then -- 1139
						emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1142
						if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1142
							____exports.Log( -- 1144
								"Warn", -- 1144
								"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1144
							) -- 1144
						end -- 1144
					else -- 1144
						choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1147
					end -- 1147
					do -- 1147
						local i = 0 -- 1149
						while i < #choices do -- 1149
							local choice = choices[i + 1] -- 1150
							local index = type(choice.index) == "number" and choice.index or i -- 1151
							if states[index] == nil then -- 1151
								states[index] = {index = index, message = {role = "assistant"}} -- 1152
							end -- 1152
							mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1156
							i = i + 1 -- 1149
						end -- 1149
					end -- 1149
					if onChunk ~= nil then -- 1149
						onChunk( -- 1158
							buildStreamResponse( -- 1159
								states, -- 1159
								model, -- 1159
								responseId, -- 1159
								responseCreated, -- 1159
								responseObject, -- 1159
								providerError -- 1159
							), -- 1159
							{ -- 1160
								id = chunk.id or "", -- 1161
								created = chunk.created or 0, -- 1162
								object = chunk.object or "", -- 1163
								model = chunk.model or model, -- 1164
								choices = choices -- 1165
							} -- 1165
						) -- 1165
					end -- 1165
				end, -- 1120
				onDone = function() -- 1169
					doneChunkSeen = true -- 1170
				end, -- 1169
				onError = function(err, context) -- 1172
					parseErrorCount = parseErrorCount + 1 -- 1173
					____exports.Log( -- 1174
						"Warn", -- 1174
						(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1174
					) -- 1174
				end -- 1172
			}) -- 1172
			__TS__Await(postLLM( -- 1177
				fitted.messages, -- 1177
				url, -- 1177
				apiKey, -- 1177
				model, -- 1177
				options, -- 1177
				true, -- 1177
				function(data) -- 1177
					if stopToken and stopToken.stopped then -- 1177
						return true -- 1178
					end -- 1178
					httpChunkCount = httpChunkCount + 1 -- 1179
					rawStreamBytes = rawStreamBytes + #data -- 1180
					if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1180
						rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1182
					end -- 1182
					parser.feed(data) -- 1184
					return false -- 1185
				end, -- 1177
				stopToken -- 1186
			)) -- 1186
			parser["end"]() -- 1187
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1187
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1189
				if rawResponse and type(rawResponse) == "table" then -- 1189
					local rawResponseObj = rawResponse -- 1191
					if rawResponseObj.error then -- 1191
						providerError = rawResponseObj.error -- 1193
						lastJSONPreview = previewText( -- 1194
							normalizeLLMJSONResponse(rawStreamPreview), -- 1194
							500 -- 1194
						) -- 1194
						____exports.Log( -- 1195
							"Warn", -- 1195
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1195
						) -- 1195
					end -- 1195
				end -- 1195
			end -- 1195
			local response = buildStreamResponse( -- 1199
				states, -- 1199
				model, -- 1199
				responseId, -- 1199
				responseCreated, -- 1199
				responseObject, -- 1199
				providerError -- 1199
			) -- 1199
			local choiceCount = response.choices and #response.choices or 0 -- 1200
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1201
			____exports.Log( -- 1202
				"Info", -- 1202
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1202
			) -- 1202
			if not response.choices or #response.choices == 0 then -- 1202
				local providerMessage = providerError and providerError.message or "" -- 1204
				local providerType = providerError and providerError.type or "" -- 1205
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1206
				local details = table.concat( -- 1209
					__TS__ArrayFilter( -- 1209
						{providerType, providerCode}, -- 1209
						function(____, part) return part ~= "" end -- 1209
					), -- 1209
					"/" -- 1209
				) -- 1209
				local rawPreview = previewText( -- 1210
					____exports.sanitizeUTF8(rawStreamPreview), -- 1210
					1200 -- 1210
				) -- 1210
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1211
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1212
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1215
				return ____awaiter_resolve(nil, {success = false, message = message, raw = rawStreamPreview}) -- 1215
			end -- 1215
			return ____awaiter_resolve(nil, {success = true, response = response}) -- 1215
		end) -- 1215
		__TS__Await(____try.catch( -- 1102
			____try, -- 1102
			function(____, e) -- 1102
				if stopToken and stopToken.stopped then -- 1102
					local reason = stopToken.reason or "request cancelled" -- 1228
					____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1229
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1229
				end -- 1229
				____exports.Log( -- 1232
					"Error", -- 1232
					"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1232
				) -- 1232
				return ____awaiter_resolve( -- 1232
					nil, -- 1232
					{ -- 1233
						success = false, -- 1233
						message = tostring(e) -- 1233
					} -- 1233
				) -- 1233
			end -- 1233
		)) -- 1233
	end) -- 1233
end -- 1067
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1237
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1237
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1243
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1244
		local resolvedConfig = config or (function() -- 1247
			local configRes = ____exports.getActiveLLMConfig() -- 1248
			if not configRes.success then -- 1248
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1250
				return nil -- 1251
			end -- 1251
			return configRes.config -- 1253
		end)() -- 1247
		if not resolvedConfig then -- 1247
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1247
		end -- 1247
		local url = resolvedConfig.url -- 1247
		local model = resolvedConfig.model -- 1247
		local apiKey = resolvedConfig.apiKey -- 1247
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1259
		____exports.Log( -- 1260
			"Info", -- 1260
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1260
		) -- 1260
		if stopToken and stopToken.stopped then -- 1260
			local reason = stopToken.reason or "request cancelled" -- 1262
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1263
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1263
		end -- 1263
		local ____try = __TS__AsyncAwaiter(function() -- 1263
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1267
				fitted.messages, -- 1267
				url, -- 1267
				apiKey, -- 1267
				model, -- 1267
				options, -- 1267
				false, -- 1267
				nil, -- 1267
				stopToken -- 1267
			))) -- 1267
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1268
			____exports.Log( -- 1269
				"Info", -- 1269
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1269
			) -- 1269
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1270
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1270
				local rawPreview = previewText(raw) -- 1272
				____exports.Log( -- 1273
					"Error", -- 1273
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1273
				) -- 1273
				return ____awaiter_resolve( -- 1273
					nil, -- 1273
					{ -- 1274
						success = false, -- 1275
						message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1276
						raw = raw -- 1277
					} -- 1277
				) -- 1277
			end -- 1277
			local responseObj = response -- 1280
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1281
			____exports.Log( -- 1282
				"Info", -- 1282
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1282
			) -- 1282
			if not responseObj.choices or #responseObj.choices == 0 then -- 1282
				local providerError = responseObj.error -- 1284
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1285
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1288
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1291
				local details = table.concat( -- 1294
					__TS__ArrayFilter( -- 1294
						{providerType, providerCode}, -- 1294
						function(____, part) return part ~= "" end -- 1294
					), -- 1294
					"/" -- 1294
				) -- 1294
				local rawPreview = previewText(raw, 400) -- 1295
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1296
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1299
				return ____awaiter_resolve(nil, {success = false, message = message, raw = raw}) -- 1299
			end -- 1299
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 1299
		end) -- 1299
		__TS__Await(____try.catch( -- 1266
			____try, -- 1266
			function(____, e) -- 1266
				if stopToken and stopToken.stopped then -- 1266
					local reason = stopToken.reason or "request cancelled" -- 1312
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1313
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1313
				end -- 1313
				____exports.Log( -- 1316
					"Error", -- 1316
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1316
				) -- 1316
				return ____awaiter_resolve( -- 1316
					nil, -- 1316
					{ -- 1317
						success = false, -- 1317
						message = tostring(e) -- 1317
					} -- 1317
				) -- 1317
			end -- 1317
		)) -- 1317
	end) -- 1317
end -- 1237
return ____exports -- 1237