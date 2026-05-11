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
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
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
function normalizeReasoningEffort(value) -- 784
	if type(value) ~= "string" then -- 784
		return nil -- 785
	end -- 785
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 786
	return normalized ~= "" and normalized or nil -- 787
end -- 787
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
local function postLLM(messages, url, apiKey, model, options, stream, receiver, stopToken) -- 497
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 507
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = stream}) -- 508
	if stopToken == nil then -- 508
		stopToken = {stopped = false} -- 514
	end -- 514
	return __TS__New( -- 515
		__TS__Promise, -- 515
		function(____, resolve, reject) -- 515
			local requestId = 0 -- 516
			local settled = false -- 517
			local function finishResolve(text) -- 518
				if settled then -- 518
					return -- 519
				end -- 519
				settled = true -- 520
				resolve(nil, text) -- 521
			end -- 518
			local function finishReject(err) -- 523
				if settled then -- 523
					return -- 524
				end -- 524
				settled = true -- 525
				reject(nil, err) -- 526
			end -- 523
			Director.systemScheduler:schedule(function() -- 528
				if not settled then -- 528
					if stopToken.stopped then -- 528
						if requestId ~= 0 then -- 528
							HttpClient:cancel(requestId) -- 532
							requestId = 0 -- 533
						end -- 533
						finishReject("request cancelled") -- 535
						return true -- 536
					end -- 536
					return false -- 538
				end -- 538
				return true -- 540
			end) -- 528
			Director.systemScheduler:schedule(once(function() -- 542
				emit( -- 543
					"LLM_IN", -- 543
					table.concat( -- 543
						__TS__ArrayMap( -- 543
							messages, -- 543
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 543
						), -- 543
						"\n" -- 543
					) -- 543
				) -- 543
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 544
				if jsonStr ~= nil then -- 544
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", "Accept: application/json"} -- 546
					requestId = receiver and HttpClient:post( -- 551
						url, -- 552
						headers, -- 552
						jsonStr, -- 552
						requestTimeout, -- 552
						function(data) -- 552
							if stopToken.stopped then -- 552
								return true -- 553
							end -- 553
							return receiver(data) -- 554
						end, -- 552
						function(data) -- 555
							requestId = 0 -- 556
							if data ~= nil then -- 556
								finishResolve(data) -- 558
							else -- 558
								finishReject("failed to get http response") -- 560
							end -- 560
						end -- 555
					) or HttpClient:post( -- 555
						url, -- 563
						headers, -- 563
						jsonStr, -- 563
						requestTimeout, -- 563
						function(data) -- 563
							requestId = 0 -- 564
							if stopToken.stopped then -- 564
								finishReject("request cancelled") -- 566
								return -- 567
							end -- 567
							if data ~= nil then -- 567
								finishResolve(data) -- 570
							else -- 570
								finishReject("failed to get http response") -- 572
							end -- 572
						end -- 563
					) -- 563
					if requestId == 0 then -- 563
						finishReject("failed to schedule http request") -- 576
					elseif stopToken.stopped then -- 576
						HttpClient:cancel(requestId) -- 578
						requestId = 0 -- 579
						finishReject("request cancelled") -- 580
					end -- 580
				else -- 580
					finishReject(err) -- 583
				end -- 583
			end)) -- 542
		end -- 515
	) -- 515
end -- 497
function ____exports.createSSEJSONParser(opts) -- 593
	local buffer = "" -- 598
	local eventDataLines = {} -- 599
	local function flushEventIfAny() -- 601
		if #eventDataLines == 0 then -- 601
			return -- 602
		end -- 602
		local dataPayload = table.concat(eventDataLines, "\n") -- 604
		eventDataLines = {} -- 605
		if dataPayload == "[DONE]" then -- 605
			local ____opt_1 = opts.onDone -- 605
			if ____opt_1 ~= nil then -- 605
				____opt_1(dataPayload) -- 608
			end -- 608
			return -- 609
		end -- 609
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 612
		if err == nil then -- 612
			opts.onJSON(obj, dataPayload) -- 614
		else -- 614
			local ____opt_3 = opts.onError -- 614
			if ____opt_3 ~= nil then -- 614
				____opt_3(err, {raw = dataPayload}) -- 616
			end -- 616
		end -- 616
	end -- 601
	local function feed(chunk) -- 620
		buffer = buffer .. chunk -- 621
		while true do -- 621
			do -- 621
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 624
				if nl < 0 then -- 624
					break -- 625
				end -- 625
				local line = __TS__StringSlice(buffer, 0, nl) -- 627
				buffer = __TS__StringSlice(buffer, nl + 1) -- 628
				if __TS__StringEndsWith(line, "\r") then -- 628
					line = string.sub(line, 1, -2) -- 630
				end -- 630
				if line == "" then -- 630
					flushEventIfAny() -- 633
					goto __continue159 -- 634
				end -- 634
				if __TS__StringStartsWith(line, ":") then -- 634
					goto __continue159 -- 638
				end -- 638
				if __TS__StringStartsWith(line, "data:") then -- 638
					local v = string.sub(line, 6) -- 641
					if __TS__StringStartsWith(v, " ") then -- 641
						v = string.sub(v, 2) -- 642
					end -- 642
					eventDataLines[#eventDataLines + 1] = v -- 643
					goto __continue159 -- 644
				end -- 644
			end -- 644
			::__continue159:: -- 644
		end -- 644
	end -- 620
	local function ____end() -- 649
		if #buffer > 0 then -- 649
			local line = buffer -- 651
			buffer = "" -- 652
			if __TS__StringEndsWith(line, "\r") then -- 652
				line = string.sub(line, 1, -2) -- 653
			end -- 653
			if __TS__StringStartsWith(line, "data:") then -- 653
				local v = string.sub(line, 6) -- 656
				if __TS__StringStartsWith(v, " ") then -- 656
					v = string.sub(v, 2) -- 657
				end -- 657
				eventDataLines[#eventDataLines + 1] = v -- 658
			end -- 658
		end -- 658
		flushEventIfAny() -- 661
	end -- 649
	return {feed = feed, ["end"] = ____end} -- 664
end -- 593
local function normalizeContextWindow(value) -- 759
	if type(value) == "number" then -- 759
		return math.max( -- 761
			64000, -- 761
			math.floor(value) -- 761
		) -- 761
	end -- 761
	return 64000 -- 763
end -- 759
local function normalizeSupportsFunctionCalling(value) -- 766
	return value == nil or value == nil or value ~= 0 -- 767
end -- 766
local function normalizeLLMTemperature(value) -- 770
	if type(value) == "number" then -- 770
		return math.max( -- 772
			0, -- 772
			math.min(2, value) -- 772
		) -- 772
	end -- 772
	return 0.1 -- 774
end -- 770
local function normalizeLLMMaxTokens(value) -- 777
	if type(value) == "number" then -- 777
		return math.max( -- 779
			1, -- 779
			math.floor(value) -- 779
		) -- 779
	end -- 779
	return 8192 -- 781
end -- 777
function ____exports.getActiveLLMConfig() -- 790
	local rows = DB:query("select * from LLMConfig", true) -- 791
	local records = {} -- 792
	if rows and #rows > 1 then -- 792
		do -- 792
			local i = 1 -- 794
			while i < #rows do -- 794
				local record = {} -- 795
				do -- 795
					local c = 0 -- 796
					while c < #rows[i + 1] do -- 796
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 797
						c = c + 1 -- 796
					end -- 796
				end -- 796
				records[#records + 1] = record -- 799
				i = i + 1 -- 794
			end -- 794
		end -- 794
	end -- 794
	local config = __TS__ArrayFind( -- 802
		records, -- 802
		function(____, r) return r.active ~= 0 end -- 802
	) -- 802
	if not config then -- 802
		return {success = false, message = "no active LLM config"} -- 804
	end -- 804
	local url = config.url -- 804
	local model = config.model -- 804
	local api_key = config.api_key -- 804
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 804
		return {success = false, message = "got invalude LLM config"} -- 808
	end -- 808
	return { -- 810
		success = true, -- 811
		config = { -- 812
			url = url, -- 813
			model = model, -- 814
			apiKey = api_key, -- 815
			contextWindow = normalizeContextWindow(config.context_window), -- 816
			temperature = normalizeLLMTemperature(config.temperature), -- 817
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 818
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 819
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 820
		} -- 820
	} -- 820
end -- 790
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 825
	local callEvent -- 831
	if event.id ~= nil then -- 831
		local id = event.id -- 833
		callEvent = { -- 834
			id = nil, -- 835
			onData = function(data) -- 836
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 837
				return event.stopToken.stopped -- 838
			end, -- 836
			onCancel = function(reason) -- 840
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 841
			end, -- 840
			onDone = function() -- 843
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 844
			end -- 843
		} -- 843
	else -- 843
		callEvent = event -- 848
	end -- 848
	local ____callEvent_5 = callEvent -- 850
	local onData = ____callEvent_5.onData -- 850
	local onDone = ____callEvent_5.onDone -- 850
	local ____callEvent_6 = callEvent -- 851
	local onCancel = ____callEvent_6.onCancel -- 851
	local config = llmConfig or (function() -- 852
		local configRes = ____exports.getActiveLLMConfig() -- 853
		if not configRes.success then -- 853
			if onCancel then -- 853
				onCancel(configRes.message) -- 855
			end -- 855
			return nil -- 856
		end -- 856
		return configRes.config -- 858
	end)() -- 852
	if not config then -- 852
		return {success = false, message = "no active LLM config"} -- 861
	end -- 861
	local url = config.url -- 861
	local model = config.model -- 861
	local apiKey = config.apiKey -- 861
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 864
	if fitted.trimmed then -- 864
		____exports.Log( -- 866
			"Warn", -- 866
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 866
		) -- 866
	end -- 866
	local stopLLM = false -- 868
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 869
		local result = onData(obj) -- 871
		if result then -- 871
			stopLLM = result -- 872
		end -- 872
	end}); -- 870
	(function() -- 875
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 875
			local ____try = __TS__AsyncAwaiter(function() -- 875
				local ____array_8 = __TS__SparseArrayNew( -- 875
					fitted.messages, -- 877
					url, -- 877
					apiKey, -- 877
					model, -- 877
					options, -- 877
					true, -- 877
					function(data) -- 877
						if stopLLM then -- 877
							if onCancel then -- 877
								onCancel("LLM Stopped") -- 880
								onCancel = nil -- 881
							end -- 881
							return true -- 883
						end -- 883
						parser.feed(data) -- 885
						return false -- 886
					end -- 877
				) -- 877
				local ____temp_7 -- 887
				if event.stopToken ~= nil then -- 887
					____temp_7 = event.stopToken -- 887
				else -- 887
					____temp_7 = nil -- 887
				end -- 887
				__TS__SparseArrayPush(____array_8, ____temp_7) -- 887
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_8))) -- 877
				parser["end"]() -- 888
				if onDone then -- 888
					onDone(result) -- 890
				end -- 890
			end) -- 890
			__TS__Await(____try.catch( -- 876
				____try, -- 876
				function(____, e) -- 876
					stopLLM = true -- 893
					if onCancel then -- 893
						onCancel(tostring(e)) -- 895
						onCancel = nil -- 896
					end -- 896
				end -- 896
			)) -- 896
		end) -- 896
	end)() -- 875
	return {success = true} -- 900
end -- 825
local function mergeStreamToolCall(target, delta) -- 903
	if type(delta.id) == "string" and delta.id ~= "" then -- 903
		target.id = delta.id -- 905
	end -- 905
	if type(delta.type) == "string" and delta.type ~= "" then -- 905
		target.type = delta.type -- 908
	end -- 908
	if delta["function"] then -- 908
		if target["function"] == nil then -- 908
			target["function"] = {} -- 911
		end -- 911
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 911
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 913
		end -- 913
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 913
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 916
		end -- 916
	end -- 916
end -- 903
local function isToolCallComplete(tc) -- 921
	if type(tc.id) ~= "string" or tc.id == "" then -- 921
		return false -- 922
	end -- 922
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 922
		return false -- 923
	end -- 923
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 923
		return false -- 924
	end -- 924
	local args = tc["function"].arguments -- 925
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 925
		return false -- 926
	end -- 926
	local decoded = ____exports.safeJsonDecode(args) -- 927
	return decoded ~= nil -- 928
end -- 921
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 931
	local delta = choice.delta or ({}) -- 932
	local fullMessage = choice.message or ({}) -- 933
	local message = acc.message -- 934
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 935
	if type(role) == "string" and role ~= "" then -- 935
		message.role = role -- 939
	end -- 939
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 941
	if type(content) == "string" and content ~= "" then -- 941
		message.content = (message.content or "") .. content -- 945
	end -- 945
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 947
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 947
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 951
	end -- 951
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 953
	if toolCalls and #toolCalls > 0 then -- 953
		if message.tool_calls == nil then -- 953
			message.tool_calls = {} -- 957
		end -- 957
		do -- 957
			local i = 0 -- 958
			while i < #toolCalls do -- 958
				local item = toolCalls[i + 1] -- 959
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 960
				local ____message_tool_calls_9, ____temp_10 = message.tool_calls, index + 1 -- 960
				if ____message_tool_calls_9[____temp_10] == nil then -- 960
					____message_tool_calls_9[____temp_10] = {} -- 963
				end -- 963
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 964
				if onToolCallReady and emittedToolCallIds then -- 964
					local tc = message.tool_calls[index + 1] -- 966
					if tc and isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 966
						emittedToolCallIds[tc.id] = true -- 968
						onToolCallReady(tc) -- 969
					end -- 969
				end -- 969
				i = i + 1 -- 958
			end -- 958
		end -- 958
	end -- 958
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 958
		acc.finish_reason = choice.finish_reason -- 975
	end -- 975
end -- 931
local function buildStreamResponse(states, model, id, created, object, providerError) -- 979
	local indexes = __TS__ArraySort( -- 987
		__TS__ArrayFilter( -- 987
			__TS__ArrayMap( -- 987
				__TS__ObjectKeys(states), -- 987
				function(____, key) return __TS__Number(key) end -- 988
			), -- 988
			function(____, index) return __TS__NumberIsFinite(index) end -- 989
		), -- 989
		function(____, a, b) return a - b end -- 990
	) -- 990
	return { -- 991
		id = id, -- 992
		created = created, -- 993
		object = object, -- 994
		model = model, -- 995
		choices = __TS__ArrayMap( -- 996
			indexes, -- 996
			function(____, index) -- 996
				local state = states[index] -- 997
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 998
			end -- 996
		), -- 996
		error = providerError -- 1009
	} -- 1009
end -- 979
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1013
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1013
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1021
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1022
		local resolvedConfig = config or (function() -- 1025
			local configRes = ____exports.getActiveLLMConfig() -- 1026
			if not configRes.success then -- 1026
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1028
				return nil -- 1029
			end -- 1029
			return configRes.config -- 1031
		end)() -- 1025
		if not resolvedConfig then -- 1025
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1025
		end -- 1025
		local url = resolvedConfig.url -- 1025
		local model = resolvedConfig.model -- 1025
		local apiKey = resolvedConfig.apiKey -- 1025
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1037
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1038
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1039
		local ____model_15 = model -- 1042
		local ____url_16 = url -- 1042
		local ____temp_17 = #messages -- 1042
		local ____tostring_12 = tostring -- 1042
		local ____options_max_tokens_11 = options.max_tokens -- 1042
		if ____options_max_tokens_11 == nil then -- 1042
			____options_max_tokens_11 = "unset" -- 1042
		end -- 1042
		local ____tostring_12_result_18 = ____tostring_12(____options_max_tokens_11) -- 1042
		local ____tostring_14 = tostring -- 1042
		local ____options_temperature_13 = options.temperature -- 1042
		if ____options_temperature_13 == nil then -- 1042
			____options_temperature_13 = "unset" -- 1042
		end -- 1042
		____exports.Log( -- 1042
			"Info", -- 1042
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_15) .. " url=") .. ____url_16) .. " messages=") .. tostring(____temp_17)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_12_result_18) .. " temperature=") .. ____tostring_14(____options_temperature_13)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1042
		) -- 1042
		if stopToken and stopToken.stopped then -- 1042
			local reason = stopToken.reason or "request cancelled" -- 1044
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1045
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1045
		end -- 1045
		local ____try = __TS__AsyncAwaiter(function() -- 1045
			local states = {} -- 1049
			local emittedToolCallIds = {} -- 1050
			local responseId = nil -- 1051
			local responseCreated = nil -- 1052
			local responseObject = nil -- 1053
			local providerError -- 1054
			local httpChunkCount = 0 -- 1055
			local rawStreamBytes = 0 -- 1056
			local rawStreamPreview = "" -- 1057
			local sseJSONChunkCount = 0 -- 1058
			local choiceJSONChunkCount = 0 -- 1059
			local emptyChoicesChunkCount = 0 -- 1060
			local missingChoicesChunkCount = 0 -- 1061
			local parseErrorCount = 0 -- 1062
			local doneChunkSeen = false -- 1063
			local lastJSONPreview = "" -- 1064
			local parser = ____exports.createSSEJSONParser({ -- 1065
				onJSON = function(obj, raw) -- 1066
					sseJSONChunkCount = sseJSONChunkCount + 1 -- 1067
					lastJSONPreview = previewText(raw, 500) -- 1068
					if not obj or type(obj) ~= "table" then -- 1068
						return -- 1070
					end -- 1070
					local chunk = obj -- 1072
					if chunk.error then -- 1072
						providerError = chunk.error -- 1074
						____exports.Log( -- 1075
							"Warn", -- 1075
							"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1075
						) -- 1075
						return -- 1076
					end -- 1076
					responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1078
					responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1079
					responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1080
					local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1081
					if not __TS__ArrayIsArray(chunk.choices) then -- 1081
						missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1083
						if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1083
							____exports.Log( -- 1085
								"Warn", -- 1085
								"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1085
							) -- 1085
						end -- 1085
					elseif #choices == 0 then -- 1085
						emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1088
						if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1088
							____exports.Log( -- 1090
								"Warn", -- 1090
								"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1090
							) -- 1090
						end -- 1090
					else -- 1090
						choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1093
					end -- 1093
					do -- 1093
						local i = 0 -- 1095
						while i < #choices do -- 1095
							local choice = choices[i + 1] -- 1096
							local index = type(choice.index) == "number" and choice.index or i -- 1097
							if states[index] == nil then -- 1097
								states[index] = {index = index, message = {role = "assistant"}} -- 1098
							end -- 1098
							mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1102
							i = i + 1 -- 1095
						end -- 1095
					end -- 1095
					if onChunk ~= nil then -- 1095
						onChunk( -- 1104
							buildStreamResponse( -- 1105
								states, -- 1105
								model, -- 1105
								responseId, -- 1105
								responseCreated, -- 1105
								responseObject, -- 1105
								providerError -- 1105
							), -- 1105
							{ -- 1106
								id = chunk.id or "", -- 1107
								created = chunk.created or 0, -- 1108
								object = chunk.object or "", -- 1109
								model = chunk.model or model, -- 1110
								choices = choices -- 1111
							} -- 1111
						) -- 1111
					end -- 1111
				end, -- 1066
				onDone = function() -- 1115
					doneChunkSeen = true -- 1116
				end, -- 1115
				onError = function(err, context) -- 1118
					parseErrorCount = parseErrorCount + 1 -- 1119
					____exports.Log( -- 1120
						"Warn", -- 1120
						(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1120
					) -- 1120
				end -- 1118
			}) -- 1118
			__TS__Await(postLLM( -- 1123
				fitted.messages, -- 1123
				url, -- 1123
				apiKey, -- 1123
				model, -- 1123
				options, -- 1123
				true, -- 1123
				function(data) -- 1123
					if stopToken and stopToken.stopped then -- 1123
						return true -- 1124
					end -- 1124
					httpChunkCount = httpChunkCount + 1 -- 1125
					rawStreamBytes = rawStreamBytes + #data -- 1126
					if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1126
						rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1128
					end -- 1128
					parser.feed(data) -- 1130
					return false -- 1131
				end, -- 1123
				stopToken -- 1132
			)) -- 1132
			parser["end"]() -- 1133
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1133
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1135
				if rawResponse and type(rawResponse) == "table" then -- 1135
					local rawResponseObj = rawResponse -- 1137
					if rawResponseObj.error then -- 1137
						providerError = rawResponseObj.error -- 1139
						lastJSONPreview = previewText( -- 1140
							normalizeLLMJSONResponse(rawStreamPreview), -- 1140
							500 -- 1140
						) -- 1140
						____exports.Log( -- 1141
							"Warn", -- 1141
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1141
						) -- 1141
					end -- 1141
				end -- 1141
			end -- 1141
			local response = buildStreamResponse( -- 1145
				states, -- 1145
				model, -- 1145
				responseId, -- 1145
				responseCreated, -- 1145
				responseObject, -- 1145
				providerError -- 1145
			) -- 1145
			local choiceCount = response.choices and #response.choices or 0 -- 1146
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1147
			____exports.Log( -- 1148
				"Info", -- 1148
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1148
			) -- 1148
			if not response.choices or #response.choices == 0 then -- 1148
				local providerMessage = providerError and providerError.message or "" -- 1150
				local providerType = providerError and providerError.type or "" -- 1151
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1152
				local details = table.concat( -- 1155
					__TS__ArrayFilter( -- 1155
						{providerType, providerCode}, -- 1155
						function(____, part) return part ~= "" end -- 1155
					), -- 1155
					"/" -- 1155
				) -- 1155
				local rawPreview = previewText( -- 1156
					____exports.sanitizeUTF8(rawStreamPreview), -- 1156
					1200 -- 1156
				) -- 1156
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1157
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1158
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1161
				return ____awaiter_resolve(nil, {success = false, message = message, raw = rawStreamPreview}) -- 1161
			end -- 1161
			return ____awaiter_resolve(nil, {success = true, response = response}) -- 1161
		end) -- 1161
		__TS__Await(____try.catch( -- 1048
			____try, -- 1048
			function(____, e) -- 1048
				if stopToken and stopToken.stopped then -- 1048
					local reason = stopToken.reason or "request cancelled" -- 1174
					____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1175
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1175
				end -- 1175
				____exports.Log( -- 1178
					"Error", -- 1178
					"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1178
				) -- 1178
				return ____awaiter_resolve( -- 1178
					nil, -- 1178
					{ -- 1179
						success = false, -- 1179
						message = tostring(e) -- 1179
					} -- 1179
				) -- 1179
			end -- 1179
		)) -- 1179
	end) -- 1179
end -- 1013
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1183
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1183
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1189
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1190
		local resolvedConfig = config or (function() -- 1193
			local configRes = ____exports.getActiveLLMConfig() -- 1194
			if not configRes.success then -- 1194
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1196
				return nil -- 1197
			end -- 1197
			return configRes.config -- 1199
		end)() -- 1193
		if not resolvedConfig then -- 1193
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1193
		end -- 1193
		local url = resolvedConfig.url -- 1193
		local model = resolvedConfig.model -- 1193
		local apiKey = resolvedConfig.apiKey -- 1193
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1205
		____exports.Log( -- 1206
			"Info", -- 1206
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1206
		) -- 1206
		if stopToken and stopToken.stopped then -- 1206
			local reason = stopToken.reason or "request cancelled" -- 1208
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1209
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1209
		end -- 1209
		local ____try = __TS__AsyncAwaiter(function() -- 1209
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1213
				fitted.messages, -- 1213
				url, -- 1213
				apiKey, -- 1213
				model, -- 1213
				options, -- 1213
				false, -- 1213
				nil, -- 1213
				stopToken -- 1213
			))) -- 1213
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1214
			____exports.Log( -- 1215
				"Info", -- 1215
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1215
			) -- 1215
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1216
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1216
				local rawPreview = previewText(raw) -- 1218
				____exports.Log( -- 1219
					"Error", -- 1219
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1219
				) -- 1219
				return ____awaiter_resolve( -- 1219
					nil, -- 1219
					{ -- 1220
						success = false, -- 1221
						message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1222
						raw = raw -- 1223
					} -- 1223
				) -- 1223
			end -- 1223
			local responseObj = response -- 1226
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1227
			____exports.Log( -- 1228
				"Info", -- 1228
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1228
			) -- 1228
			if not responseObj.choices or #responseObj.choices == 0 then -- 1228
				local providerError = responseObj.error -- 1230
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1231
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1234
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1237
				local details = table.concat( -- 1240
					__TS__ArrayFilter( -- 1240
						{providerType, providerCode}, -- 1240
						function(____, part) return part ~= "" end -- 1240
					), -- 1240
					"/" -- 1240
				) -- 1240
				local rawPreview = previewText(raw, 400) -- 1241
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1242
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1245
				return ____awaiter_resolve(nil, {success = false, message = message, raw = raw}) -- 1245
			end -- 1245
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 1245
		end) -- 1245
		__TS__Await(____try.catch( -- 1212
			____try, -- 1212
			function(____, e) -- 1212
				if stopToken and stopToken.stopped then -- 1212
					local reason = stopToken.reason or "request cancelled" -- 1258
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1259
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1259
				end -- 1259
				____exports.Log( -- 1262
					"Error", -- 1262
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1262
				) -- 1262
				return ____awaiter_resolve( -- 1262
					nil, -- 1262
					{ -- 1263
						success = false, -- 1263
						message = tostring(e) -- 1263
					} -- 1263
				) -- 1263
			end -- 1263
		)) -- 1263
	end) -- 1263
end -- 1183
return ____exports -- 1183