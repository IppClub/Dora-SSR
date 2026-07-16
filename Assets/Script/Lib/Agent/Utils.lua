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
local __TS__Delete = ____lualib.__TS__Delete -- 1
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
function normalizeReasoningEffort(value) -- 853
	if type(value) ~= "string" then -- 853
		return nil -- 854
	end -- 854
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 855
	return normalized ~= "" and normalized or nil -- 856
end -- 856
function ____exports.applyCustomLLMOptions(options, customOptions) -- 867
	if not customOptions then -- 867
		return options -- 871
	end -- 871
	local merged = __TS__ObjectAssign({}, options) -- 872
	for key in pairs(customOptions) do -- 873
		local value = customOptions[key] -- 874
		if value == json.null then -- 874
			__TS__Delete(merged, key) -- 876
		else -- 876
			merged[key] = value -- 878
		end -- 878
	end -- 878
	return merged -- 881
end -- 867
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
local function isPlainRecord(value) -- 131
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 132
end -- 131
local function normalizeLLMJSONResponse(text) -- 135
	return __TS__StringTrim(text) -- 136
end -- 135
local function utf8TakeHead(text, maxChars) -- 139
	if maxChars <= 0 or text == "" then -- 139
		return "" -- 140
	end -- 140
	local nextPos = utf8.offset(text, maxChars + 1) -- 141
	if nextPos == nil then -- 141
		return text -- 142
	end -- 142
	return string.sub(text, 1, nextPos - 1) -- 143
end -- 139
local function utf8TakeTail(text, maxChars) -- 146
	if maxChars <= 0 or text == "" then -- 146
		return "" -- 147
	end -- 147
	local charLen = utf8.len(text) -- 148
	if charLen == nil or charLen <= maxChars then -- 148
		return text -- 149
	end -- 149
	local startChar = math.max(1, charLen - maxChars + 1) -- 150
	local startPos = utf8.offset(text, startChar) -- 151
	if startPos == nil then -- 151
		return text -- 152
	end -- 152
	return string.sub(text, startPos) -- 153
end -- 146
function ____exports.estimateTextTokens(text) -- 156
	if not text then -- 156
		return 0 -- 157
	end -- 157
	return App:estimateTokens(text) -- 158
end -- 156
local function estimateMessagesTokens(messages) -- 161
	local total = 0 -- 162
	do -- 162
		local i = 0 -- 163
		while i < #messages do -- 163
			local message = messages[i + 1] -- 164
			total = total + 8 -- 165
			total = total + ____exports.estimateTextTokens(message.role or "") -- 166
			total = total + ____exports.estimateTextTokens(message.content or "") -- 167
			total = total + ____exports.estimateTextTokens(message.name or "") -- 168
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 169
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 170
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({})) -- 171
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 172
			i = i + 1 -- 163
		end -- 163
	end -- 163
	return total -- 174
end -- 161
local function estimateOptionsTokens(options) -- 177
	local text = ____exports.safeJsonEncode(options) -- 178
	return text and ____exports.estimateTextTokens(text) or 0 -- 179
end -- 177
local function getReservedOutputTokens(options, contextWindow) -- 182
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 183
	if explicitMax > 0 then -- 183
		return math.max(256, explicitMax) -- 188
	end -- 188
	return math.max( -- 189
		1024, -- 189
		math.floor(contextWindow * 0.2) -- 189
	) -- 189
end -- 182
local function getInputTokenBudget(messages, options, config) -- 192
	local contextWindow = math.max(64000, config.contextWindow) -- 193
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 194
	local optionTokens = estimateOptionsTokens(options) -- 195
	local structuralOverhead = math.max(256, #messages * 16) -- 196
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 197
end -- 192
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 200
	if budgetTokens <= 0 or text == "" then -- 200
		return "" -- 201
	end -- 201
	local estimated = ____exports.estimateTextTokens(text) -- 202
	if estimated <= budgetTokens then -- 202
		return text -- 203
	end -- 203
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 204
	local targetChars = math.max( -- 205
		200, -- 205
		math.floor(budgetTokens * charsPerToken) -- 205
	) -- 205
	local keepHead = math.max( -- 206
		0, -- 206
		math.floor(targetChars * 0.35) -- 206
	) -- 206
	local keepTail = math.max(0, targetChars - keepHead) -- 207
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 208
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 209
	return (head .. "\n...\n") .. tail -- 210
end -- 200
local function isXMLWhitespaceChar(ch) -- 213
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 214
end -- 213
local function findLineStart(value, from) -- 217
	local i = from -- 218
	while i >= 0 do -- 218
		if __TS__StringAccess(value, i) == "\n" then -- 218
			return i + 1 -- 220
		end -- 220
		i = i - 1 -- 221
	end -- 221
	return 0 -- 223
end -- 217
local function findLastLiteral(text, needle) -- 226
	if needle == "" then -- 226
		return #text -- 227
	end -- 227
	local last = -1 -- 228
	local from = 0 -- 229
	while from <= #text - #needle do -- 229
		local pos = (string.find( -- 231
			text, -- 231
			needle, -- 231
			math.max(from + 1, 1), -- 231
			true -- 231
		) or 0) - 1 -- 231
		if pos < 0 then -- 231
			break -- 232
		end -- 232
		last = pos -- 233
		from = pos + 1 -- 234
	end -- 234
	return last -- 236
end -- 226
local function unwrapXMLRawText(text) -- 239
	local trimmed = __TS__StringTrim(text) -- 240
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 240
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 242
	end -- 242
	return text -- 244
end -- 239
local function readSimpleXMLTagName(source, openStart, openEnd) -- 247
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 248
	if rawTag == "" then -- 248
		return { -- 250
			success = false, -- 250
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 250
		} -- 250
	end -- 250
	local selfClosing = false -- 252
	local tagText = rawTag -- 253
	if __TS__StringEndsWith(tagText, "/") then -- 253
		selfClosing = true -- 255
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 256
	end -- 256
	local tagName = "" -- 258
	do -- 258
		local i = 0 -- 259
		while i < #tagText do -- 259
			local ch = __TS__StringAccess(tagText, i) -- 260
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 260
				break -- 261
			end -- 261
			tagName = tagName .. ch -- 262
			i = i + 1 -- 259
		end -- 259
	end -- 259
	if tagName == "" then -- 259
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 265
	end -- 265
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 267
end -- 247
local function findMatchingXMLClose(source, tagName, contentStart) -- 270
	local sameOpenPrefix = "<" .. tagName -- 271
	local sameCloseToken = ("</" .. tagName) .. ">" -- 272
	local pos = contentStart -- 273
	local depth = 1 -- 274
	while pos < #source do -- 274
		do -- 274
			local lt = (string.find( -- 276
				source, -- 276
				"<", -- 276
				math.max(pos + 1, 1), -- 276
				true -- 276
			) or 0) - 1 -- 276
			if lt < 0 then -- 276
				break -- 277
			end -- 277
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 277
				local cdataEnd = (string.find( -- 279
					source, -- 279
					"]]>", -- 279
					math.max(lt + 9 + 1, 1), -- 279
					true -- 279
				) or 0) - 1 -- 279
				if cdataEnd < 0 then -- 279
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 280
				end -- 280
				pos = cdataEnd + 3 -- 281
				goto __continue68 -- 282
			end -- 282
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 285
					source, -- 285
					"-->",
					math.max(lt + 4 + 1, 1), -- 285
					true -- 285
				) or 0) - 1 -- 285
				if commentEnd < 0 then -- 285
					return {success = false, message = "invalid xml: unterminated comment"} -- 286
				end -- 286
				pos = commentEnd + 3 -- 287
				goto __continue68 -- 288
			end -- 288
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 288
				depth = depth - 1 -- 291
				if depth == 0 then -- 291
					return {success = true, closeStart = lt} -- 292
				end -- 292
				pos = lt + #sameCloseToken -- 293
				goto __continue68 -- 294
			end -- 294
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 294
				local openEnd = (string.find( -- 297
					source, -- 297
					">", -- 297
					math.max(lt + 1, 1), -- 297
					true -- 297
				) or 0) - 1 -- 297
				if openEnd < 0 then -- 297
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 298
				end -- 298
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 299
				if not tagInfo.success then -- 299
					return tagInfo -- 300
				end -- 300
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 300
					depth = depth + 1 -- 302
				end -- 302
				pos = openEnd + 1 -- 304
				goto __continue68 -- 305
			end -- 305
			local genericEnd = (string.find( -- 307
				source, -- 307
				">", -- 307
				math.max(lt + 1, 1), -- 307
				true -- 307
			) or 0) - 1 -- 307
			if genericEnd < 0 then -- 307
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 308
			end -- 308
			pos = genericEnd + 1 -- 309
		end -- 309
		::__continue68:: -- 309
	end -- 309
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 311
end -- 270
function ____exports.extractXMLFromText(text) -- 314
	local source = __TS__StringTrim(text) -- 315
	local function extractFencedBlock(fence) -- 316
		if not __TS__StringStartsWith(source, fence) then -- 316
			return nil -- 317
		end -- 317
		local firstLineEnd = (string.find( -- 318
			source, -- 318
			"\n", -- 318
			math.max(1, 1), -- 318
			true -- 318
		) or 0) - 1 -- 318
		if firstLineEnd < 0 then -- 318
			return nil -- 319
		end -- 319
		local searchPos = firstLineEnd + 1 -- 320
		local closingFencePositions = {} -- 321
		while searchPos < #source do -- 321
			local ____end = (string.find( -- 323
				source, -- 323
				"```", -- 323
				math.max(searchPos + 1, 1), -- 323
				true -- 323
			) or 0) - 1 -- 323
			if ____end < 0 then -- 323
				break -- 324
			end -- 324
			local lineStart = findLineStart(source, ____end - 1) -- 325
			local lineEnd = (string.find( -- 326
				source, -- 326
				"\n", -- 326
				math.max(____end + 1, 1), -- 326
				true -- 326
			) or 0) - 1 -- 326
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 327
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 327
				closingFencePositions[#closingFencePositions + 1] = ____end -- 329
			end -- 329
			searchPos = ____end + 1 -- 331
		end -- 331
		do -- 331
			local i = #closingFencePositions - 1 -- 333
			while i >= 0 do -- 333
				do -- 333
					local closingFencePos = closingFencePositions[i + 1] -- 334
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 335
					if afterFence ~= "" then -- 335
						goto __continue89 -- 336
					end -- 336
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 337
				end -- 337
				::__continue89:: -- 337
				i = i - 1 -- 333
			end -- 333
		end -- 333
		return nil -- 339
	end -- 316
	local xmlBlock = extractFencedBlock("```xml") -- 341
	if xmlBlock ~= nil then -- 341
		return xmlBlock -- 342
	end -- 342
	local genericBlock = extractFencedBlock("```") -- 343
	if genericBlock ~= nil then -- 343
		return genericBlock -- 344
	end -- 344
	return source -- 345
end -- 314
function ____exports.parseSimpleXMLChildren(source) -- 348
	local result = {} -- 349
	local pos = 0 -- 350
	while pos < #source do -- 350
		do -- 350
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 350
				pos = pos + 1 -- 352
			end -- 352
			if pos >= #source then -- 352
				break -- 353
			end -- 353
			if __TS__StringAccess(source, pos) ~= "<" then -- 353
				return { -- 355
					success = false, -- 355
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 355
				} -- 355
			end -- 355
			if __TS__StringStartsWith(source, "</", pos) then -- 355
				return { -- 358
					success = false, -- 358
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 358
				} -- 358
			end -- 358
			local openEnd = (string.find( -- 360
				source, -- 360
				">", -- 360
				math.max(pos + 1, 1), -- 360
				true -- 360
			) or 0) - 1 -- 360
			if openEnd < 0 then -- 360
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 362
			end -- 362
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 364
			if not tagInfo.success then -- 364
				return tagInfo -- 365
			end -- 365
			if tagInfo.selfClosing then -- 365
				result[tagInfo.tagName] = "" -- 367
				pos = openEnd + 1 -- 368
				goto __continue94 -- 369
			end -- 369
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 371
			if not closeRes.success then -- 371
				return closeRes -- 372
			end -- 372
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 373
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 374
			pos = closeRes.closeStart + #closeToken -- 375
		end -- 375
		::__continue94:: -- 375
	end -- 375
	return {success = true, obj = result} -- 377
end -- 348
function ____exports.parseXMLObjectFromText(text, rootTag) -- 380
	local xmlText = ____exports.extractXMLFromText(text) -- 381
	local rootOpen = ("<" .. rootTag) .. ">" -- 382
	local rootClose = ("</" .. rootTag) .. ">" -- 383
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 384
	local ____end = findLastLiteral(xmlText, rootClose) -- 385
	if start < 0 or ____end < start then -- 385
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 387
	end -- 387
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 389
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 390
	if beforeRoot ~= "" or afterRoot ~= "" then -- 390
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 392
	end -- 392
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 394
	return ____exports.parseSimpleXMLChildren(rootContent) -- 395
end -- 380
function ____exports.fitMessagesToContext(messages, options, config) -- 398
	local modelName = string.lower(config.model) -- 405
	local shouldEchoReasoningContent = __TS__ArraySome( -- 406
		messages, -- 406
		function(____, message) return type(message.reasoning_content) == "string" end -- 406
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 406
	local cloned = __TS__ArrayMap( -- 410
		messages, -- 410
		function(____, message) -- 410
			local clonedMessage = __TS__ObjectAssign({}, message) -- 411
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 411
				clonedMessage.reasoning_content = "" -- 417
			end -- 417
			return clonedMessage -- 419
		end -- 410
	) -- 410
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 421
	local originalTokens = estimateMessagesTokens(cloned) -- 422
	if originalTokens <= budgetTokens then -- 422
		return { -- 424
			messages = cloned, -- 425
			trimmed = false, -- 426
			originalTokens = originalTokens, -- 427
			fittedTokens = originalTokens, -- 428
			budgetTokens = budgetTokens -- 429
		} -- 429
	end -- 429
	local function roleOverhead(message) -- 433
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 433
	end -- 433
	local fixedOverhead = 0 -- 434
	local contentIndexes = {} -- 435
	do -- 435
		local i = 0 -- 436
		while i < #cloned do -- 436
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 437
			contentIndexes[#contentIndexes + 1] = i -- 438
			i = i + 1 -- 436
		end -- 436
	end -- 436
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 440
	if #contentIndexes == 1 then -- 440
		local idx = contentIndexes[1] -- 442
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 443
		local fittedTokens = estimateMessagesTokens(cloned) -- 444
		return { -- 445
			messages = cloned, -- 446
			trimmed = true, -- 447
			originalTokens = originalTokens, -- 448
			fittedTokens = fittedTokens, -- 449
			budgetTokens = budgetTokens -- 450
		} -- 450
	end -- 450
	local nonSystemIndexes = {} -- 454
	local systemIndexes = {} -- 455
	do -- 455
		local i = 0 -- 456
		while i < #cloned do -- 456
			if cloned[i + 1].role == "system" then -- 456
				systemIndexes[#systemIndexes + 1] = i -- 457
			else -- 457
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 458
			end -- 458
			i = i + 1 -- 456
		end -- 456
	end -- 456
	local ____array_0 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 456
	__TS__SparseArrayPush( -- 456
		____array_0, -- 456
		table.unpack(systemIndexes) -- 460
	) -- 460
	local priorityIndexes = {__TS__SparseArraySpread(____array_0)} -- 460
	local remainingContentBudget = contentBudget -- 461
	do -- 461
		local i = #priorityIndexes - 1 -- 462
		while i >= 0 do -- 462
			local idx = priorityIndexes[i + 1] -- 463
			local message = cloned[idx + 1] -- 464
			local minBudget = message.role == "system" and 96 or 192 -- 465
			local target = math.max( -- 466
				minBudget, -- 466
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 466
			) -- 466
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 467
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 468
			remainingContentBudget = math.max(0, remainingContentBudget) -- 469
			i = i - 1 -- 462
		end -- 462
	end -- 462
	local fittedTokens = estimateMessagesTokens(cloned) -- 472
	if fittedTokens > budgetTokens then -- 472
		do -- 472
			local i = 0 -- 474
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 474
				local idx = priorityIndexes[i + 1] -- 475
				local message = cloned[idx + 1] -- 476
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 477
				local excess = fittedTokens - budgetTokens -- 478
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 479
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 480
				fittedTokens = estimateMessagesTokens(cloned) -- 481
				i = i + 1 -- 474
			end -- 474
		end -- 474
	end -- 474
	if fittedTokens > budgetTokens then -- 474
		do -- 474
			local i = 0 -- 485
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 485
				do -- 485
					local idx = priorityIndexes[i + 1] -- 486
					if cloned[idx + 1].role == "system" then -- 486
						goto __continue126 -- 487
					end -- 487
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 488
					fittedTokens = estimateMessagesTokens(cloned) -- 489
				end -- 489
				::__continue126:: -- 489
				i = i + 1 -- 485
			end -- 485
		end -- 485
	end -- 485
	return { -- 492
		messages = cloned, -- 493
		trimmed = true, -- 494
		originalTokens = originalTokens, -- 495
		fittedTokens = fittedTokens, -- 496
		budgetTokens = budgetTokens -- 497
	} -- 497
end -- 398
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken) -- 501
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 512
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 513
	local data = __TS__ObjectAssign({}, requestOptions, {model = model, messages = messages, stream = stream}) -- 514
	if stopToken == nil then -- 514
		stopToken = {stopped = false} -- 520
	end -- 520
	return __TS__New( -- 521
		__TS__Promise, -- 521
		function(____, resolve, reject) -- 521
			local requestId = 0 -- 522
			local settled = false -- 523
			local function finishResolve(text) -- 524
				if settled then -- 524
					return -- 525
				end -- 525
				settled = true -- 526
				resolve(nil, text) -- 527
			end -- 524
			local function finishReject(err) -- 529
				if settled then -- 529
					return -- 530
				end -- 530
				settled = true -- 531
				reject(nil, err) -- 532
			end -- 529
			Director.systemScheduler:schedule(function() -- 534
				if not settled then -- 534
					if stopToken.stopped then -- 534
						if requestId ~= 0 then -- 534
							HttpClient:cancel(requestId) -- 538
							requestId = 0 -- 539
						end -- 539
						finishReject("request cancelled") -- 541
						return true -- 542
					end -- 542
					return false -- 544
				end -- 544
				return true -- 546
			end) -- 534
			Director.systemScheduler:schedule(once(function() -- 548
				emit( -- 549
					"LLM_IN", -- 549
					table.concat( -- 549
						__TS__ArrayMap( -- 549
							messages, -- 549
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 549
						), -- 549
						"\n" -- 549
					) -- 549
				) -- 549
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 550
				if jsonStr ~= nil then -- 550
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", receiver and "Accept: text/event-stream" or "Accept: application/json"} -- 552
					requestId = receiver and HttpClient:post( -- 557
						url, -- 558
						headers, -- 558
						jsonStr, -- 558
						requestTimeout, -- 558
						function(data) -- 558
							if stopToken.stopped then -- 558
								return true -- 559
							end -- 559
							return receiver(data) -- 560
						end, -- 558
						function(data) -- 561
							requestId = 0 -- 562
							if data ~= nil then -- 562
								finishResolve(data) -- 564
							else -- 564
								finishReject("failed to get http response") -- 566
							end -- 566
						end -- 561
					) or HttpClient:post( -- 561
						url, -- 569
						headers, -- 569
						jsonStr, -- 569
						requestTimeout, -- 569
						function(data) -- 569
							requestId = 0 -- 570
							if stopToken.stopped then -- 570
								finishReject("request cancelled") -- 572
								return -- 573
							end -- 573
							if data ~= nil then -- 573
								finishResolve(data) -- 576
							else -- 576
								finishReject("failed to get http response") -- 578
							end -- 578
						end -- 569
					) -- 569
					if requestId == 0 then -- 569
						finishReject("failed to schedule http request") -- 582
					elseif stopToken.stopped then -- 582
						HttpClient:cancel(requestId) -- 584
						requestId = 0 -- 585
						finishReject("request cancelled") -- 586
					end -- 586
				else -- 586
					finishReject(err) -- 589
				end -- 589
			end)) -- 548
		end -- 521
	) -- 521
end -- 501
function ____exports.createSSEJSONParser(opts) -- 599
	local buffer = "" -- 604
	local eventDataLines = {} -- 605
	local function flushEventIfAny() -- 607
		if #eventDataLines == 0 then -- 607
			return -- 608
		end -- 608
		local dataPayload = table.concat(eventDataLines, "\n") -- 610
		eventDataLines = {} -- 611
		if dataPayload == "[DONE]" then -- 611
			local ____opt_1 = opts.onDone -- 611
			if ____opt_1 ~= nil then -- 611
				____opt_1(dataPayload) -- 614
			end -- 614
			return -- 615
		end -- 615
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 618
		if err == nil then -- 618
			opts.onJSON(obj, dataPayload) -- 620
		else -- 620
			local ____opt_3 = opts.onError -- 620
			if ____opt_3 ~= nil then -- 620
				____opt_3(err, {raw = dataPayload}) -- 622
			end -- 622
		end -- 622
	end -- 607
	local function feed(chunk) -- 626
		buffer = buffer .. chunk -- 627
		while true do -- 627
			do -- 627
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 630
				if nl < 0 then -- 630
					break -- 631
				end -- 631
				local line = __TS__StringSlice(buffer, 0, nl) -- 633
				buffer = __TS__StringSlice(buffer, nl + 1) -- 634
				if __TS__StringEndsWith(line, "\r") then -- 634
					line = string.sub(line, 1, -2) -- 636
				end -- 636
				if line == "" then -- 636
					flushEventIfAny() -- 639
					goto __continue160 -- 640
				end -- 640
				if __TS__StringStartsWith(line, ":") then -- 640
					goto __continue160 -- 644
				end -- 644
				if __TS__StringStartsWith(line, "data:") then -- 644
					local v = string.sub(line, 6) -- 647
					if __TS__StringStartsWith(v, " ") then -- 647
						v = string.sub(v, 2) -- 648
					end -- 648
					eventDataLines[#eventDataLines + 1] = v -- 649
					goto __continue160 -- 650
				end -- 650
			end -- 650
			::__continue160:: -- 650
		end -- 650
	end -- 626
	local function ____end() -- 655
		if #buffer > 0 then -- 655
			local line = buffer -- 657
			buffer = "" -- 658
			if __TS__StringEndsWith(line, "\r") then -- 658
				line = string.sub(line, 1, -2) -- 659
			end -- 659
			if __TS__StringStartsWith(line, "data:") then -- 659
				local v = string.sub(line, 6) -- 662
				if __TS__StringStartsWith(v, " ") then -- 662
					v = string.sub(v, 2) -- 663
				end -- 663
				eventDataLines[#eventDataLines + 1] = v -- 664
			end -- 664
		end -- 664
		flushEventIfAny() -- 667
	end -- 655
	return {feed = feed, ["end"] = ____end} -- 670
end -- 599
function ____exports.extractLLMTokenUsage(response) -- 764
	local usage = response and response.usage -- 765
	if not usage or type(usage) ~= "table" then -- 765
		return nil -- 766
	end -- 766
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 767
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 770
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 770
		return nil -- 773
	end -- 773
	local ____temp_12 -- 774
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 774
		____temp_12 = usage.prompt_cache_hit_tokens -- 775
	else -- 775
		local ____temp_11 -- 776
		local ____opt_7 = usage.prompt_tokens_details -- 776
		if type(____opt_7 and ____opt_7.cached_tokens) == "number" then -- 776
			____temp_11 = usage.prompt_tokens_details.cached_tokens -- 777
		else -- 777
			local ____opt_9 = usage.input_tokens_details -- 777
			____temp_11 = type(____opt_9 and ____opt_9.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 778
		end -- 778
		____temp_12 = ____temp_11 -- 776
	end -- 776
	local cachedInputTokens = ____temp_12 -- 774
	local ____inputTokens_15 = inputTokens -- 782
	local ____outputTokens_16 = outputTokens -- 783
	local ____temp_17 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 784
	local ____temp_18 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 785
	local ____temp_19 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 786
	local ____opt_13 = usage.completion_tokens_details -- 786
	return { -- 781
		inputTokens = ____inputTokens_15, -- 782
		outputTokens = ____outputTokens_16, -- 783
		totalTokens = ____temp_17, -- 784
		cachedInputTokens = ____temp_18, -- 785
		cacheMissInputTokens = ____temp_19, -- 786
		reasoningOutputTokens = type(____opt_13 and ____opt_13.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 789
	} -- 789
end -- 764
local function normalizeContextWindow(value) -- 828
	if type(value) == "number" then -- 828
		return math.max( -- 830
			64000, -- 830
			math.floor(value) -- 830
		) -- 830
	end -- 830
	return 64000 -- 832
end -- 828
local function normalizeSupportsFunctionCalling(value) -- 835
	return value == nil or value ~= 0 -- 836
end -- 835
local function normalizeLLMTemperature(value) -- 839
	if type(value) == "number" then -- 839
		return math.max( -- 841
			0, -- 841
			math.min(2, value) -- 841
		) -- 841
	end -- 841
	return 0.1 -- 843
end -- 839
local function normalizeLLMMaxTokens(value) -- 846
	if type(value) == "number" then -- 846
		return math.max( -- 848
			1, -- 848
			math.floor(value) -- 848
		) -- 848
	end -- 848
	return 8192 -- 850
end -- 846
local function normalizeLLMCustomOptions(value) -- 859
	if type(value) ~= "string" then -- 859
		return nil -- 860
	end -- 860
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 861
	if text == "" then -- 861
		return nil -- 862
	end -- 862
	local decoded = ____exports.safeJsonDecode(text) -- 863
	return isPlainRecord(decoded) and decoded or nil -- 864
end -- 859
function ____exports.getActiveLLMConfig() -- 884
	local rows = DB:query("select * from LLMConfig", true) -- 885
	local records = {} -- 886
	if rows and #rows > 1 then -- 886
		do -- 886
			local i = 1 -- 888
			while i < #rows do -- 888
				local record = {} -- 889
				do -- 889
					local c = 0 -- 890
					while c < #rows[i + 1] do -- 890
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 891
						c = c + 1 -- 890
					end -- 890
				end -- 890
				records[#records + 1] = record -- 893
				i = i + 1 -- 888
			end -- 888
		end -- 888
	end -- 888
	local config = __TS__ArrayFind( -- 896
		records, -- 896
		function(____, r) return r.active ~= 0 end -- 896
	) -- 896
	if not config then -- 896
		return {success = false, message = "no active LLM config"} -- 898
	end -- 898
	local url = config.url -- 898
	local model = config.model -- 898
	local api_key = config.api_key -- 898
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 898
		return {success = false, message = "got invalude LLM config"} -- 902
	end -- 902
	return { -- 904
		success = true, -- 905
		config = { -- 906
			url = url, -- 907
			model = model, -- 908
			apiKey = api_key, -- 909
			contextWindow = normalizeContextWindow(config.context_window), -- 910
			temperature = normalizeLLMTemperature(config.temperature), -- 911
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 912
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 913
			customOptions = normalizeLLMCustomOptions(config.custom_options), -- 914
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 915
		} -- 915
	} -- 915
end -- 884
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 920
	local callEvent -- 926
	if event.id ~= nil then -- 926
		local id = event.id -- 928
		callEvent = { -- 929
			id = nil, -- 930
			onData = function(data) -- 931
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 932
				return event.stopToken.stopped -- 933
			end, -- 931
			onCancel = function(reason) -- 935
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 936
			end, -- 935
			onDone = function() -- 938
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 939
			end -- 938
		} -- 938
	else -- 938
		callEvent = event -- 943
	end -- 943
	local ____callEvent_20 = callEvent -- 945
	local onData = ____callEvent_20.onData -- 945
	local onDone = ____callEvent_20.onDone -- 945
	local ____callEvent_21 = callEvent -- 946
	local onCancel = ____callEvent_21.onCancel -- 946
	local config = llmConfig or (function() -- 947
		local configRes = ____exports.getActiveLLMConfig() -- 948
		if not configRes.success then -- 948
			if onCancel then -- 948
				onCancel(configRes.message) -- 950
			end -- 950
			return nil -- 951
		end -- 951
		return configRes.config -- 953
	end)() -- 947
	if not config then -- 947
		return {success = false, message = "no active LLM config"} -- 956
	end -- 956
	local url = config.url -- 956
	local model = config.model -- 956
	local apiKey = config.apiKey -- 956
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 959
	if fitted.trimmed then -- 959
		____exports.Log( -- 961
			"Warn", -- 961
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 961
		) -- 961
	end -- 961
	local stopLLM = false -- 963
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 964
		local result = onData(obj) -- 966
		if result then -- 966
			stopLLM = result -- 967
		end -- 967
	end}); -- 965
	(function() -- 970
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 970
			local ____try = __TS__AsyncAwaiter(function() -- 970
				local ____array_23 = __TS__SparseArrayNew( -- 970
					fitted.messages, -- 972
					url, -- 972
					apiKey, -- 972
					model, -- 972
					options, -- 972
					true, -- 972
					config.customOptions, -- 972
					function(data) -- 972
						if stopLLM then -- 972
							if onCancel then -- 972
								onCancel("LLM Stopped") -- 975
								onCancel = nil -- 976
							end -- 976
							return true -- 978
						end -- 978
						parser.feed(data) -- 980
						return false -- 981
					end -- 972
				) -- 972
				local ____temp_22 -- 982
				if event.stopToken ~= nil then -- 982
					____temp_22 = event.stopToken -- 982
				else -- 982
					____temp_22 = nil -- 982
				end -- 982
				__TS__SparseArrayPush(____array_23, ____temp_22) -- 982
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_23))) -- 972
				parser["end"]() -- 983
				if onDone then -- 983
					onDone(result) -- 985
				end -- 985
			end) -- 985
			____try = ____try.catch( -- 985
				____try, -- 985
				function(____, e) -- 985
					return __TS__AsyncAwaiter(function() -- 985
						stopLLM = true -- 988
						if onCancel then -- 988
							onCancel(tostring(e)) -- 990
							onCancel = nil -- 991
						end -- 991
					end) -- 991
				end -- 991
			) -- 991
			__TS__Await(____try) -- 971
		end) -- 971
	end)() -- 970
	return {success = true} -- 995
end -- 920
local function mergeStreamToolCall(target, delta) -- 998
	if type(delta.id) == "string" and delta.id ~= "" then -- 998
		target.id = delta.id -- 1000
	end -- 1000
	if type(delta.type) == "string" and delta.type ~= "" then -- 1000
		target.type = delta.type -- 1003
	end -- 1003
	if delta["function"] then -- 1003
		if target["function"] == nil then -- 1003
			target["function"] = {} -- 1006
		end -- 1006
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1006
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1008
		end -- 1008
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1008
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1011
		end -- 1011
	end -- 1011
end -- 998
local function isToolCallComplete(tc) -- 1016
	if type(tc.id) ~= "string" or tc.id == "" then -- 1016
		return false -- 1017
	end -- 1017
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1017
		return false -- 1018
	end -- 1018
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1018
		return false -- 1019
	end -- 1019
	local args = tc["function"].arguments -- 1020
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1020
		return false -- 1021
	end -- 1021
	local decoded = ____exports.safeJsonDecode(args) -- 1022
	return decoded ~= nil -- 1023
end -- 1016
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1026
	local delta = choice.delta or ({}) -- 1027
	local fullMessage = choice.message or ({}) -- 1028
	local message = acc.message -- 1029
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1030
	if type(role) == "string" and role ~= "" then -- 1030
		message.role = role -- 1034
	end -- 1034
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1036
	if type(content) == "string" and content ~= "" then -- 1036
		message.content = (message.content or "") .. content -- 1040
	end -- 1040
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1042
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1042
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1046
	end -- 1046
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1048
	if #toolCalls > 0 then -- 1048
		if message.tool_calls == nil then -- 1048
			message.tool_calls = {} -- 1052
		end -- 1052
		do -- 1052
			local i = 0 -- 1053
			while i < #toolCalls do -- 1053
				local item = toolCalls[i + 1] -- 1054
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1055
				local ____message_tool_calls_24, ____temp_25 = message.tool_calls, index + 1 -- 1055
				if ____message_tool_calls_24[____temp_25] == nil then -- 1055
					____message_tool_calls_24[____temp_25] = {} -- 1058
				end -- 1058
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1059
				if onToolCallReady and emittedToolCallIds then -- 1059
					local tc = message.tool_calls[index + 1] -- 1061
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1061
						emittedToolCallIds[tc.id] = true -- 1063
						onToolCallReady(tc) -- 1064
					end -- 1064
				end -- 1064
				i = i + 1 -- 1053
			end -- 1053
		end -- 1053
	end -- 1053
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1053
		acc.finish_reason = choice.finish_reason -- 1070
	end -- 1070
end -- 1026
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1074
	local indexes = __TS__ArraySort( -- 1083
		__TS__ArrayFilter( -- 1083
			__TS__ArrayMap( -- 1083
				__TS__ObjectKeys(states), -- 1083
				function(____, key) return __TS__Number(key) end -- 1084
			), -- 1084
			function(____, index) return __TS__NumberIsFinite(index) end -- 1085
		), -- 1085
		function(____, a, b) return a - b end -- 1086
	) -- 1086
	return { -- 1087
		id = id, -- 1088
		created = created, -- 1089
		object = object, -- 1090
		model = model, -- 1091
		choices = __TS__ArrayMap( -- 1092
			indexes, -- 1092
			function(____, index) -- 1092
				local state = states[index] -- 1093
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1094
			end -- 1092
		), -- 1092
		usage = usage, -- 1105
		error = providerError -- 1106
	} -- 1106
end -- 1074
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1110
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1110
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1121
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1122
		local resolvedConfig = config or (function() -- 1125
			local configRes = ____exports.getActiveLLMConfig() -- 1126
			if not configRes.success then -- 1126
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1128
				return nil -- 1129
			end -- 1129
			return configRes.config -- 1131
		end)() -- 1125
		if not resolvedConfig then -- 1125
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1125
		end -- 1125
		local url = resolvedConfig.url -- 1125
		local model = resolvedConfig.model -- 1125
		local apiKey = resolvedConfig.apiKey -- 1125
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1137
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1138
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1139
		local ____model_30 = model -- 1142
		local ____url_31 = url -- 1142
		local ____temp_32 = #messages -- 1142
		local ____tostring_27 = tostring -- 1142
		local ____options_max_tokens_26 = options.max_tokens -- 1142
		if ____options_max_tokens_26 == nil then -- 1142
			____options_max_tokens_26 = "unset" -- 1142
		end -- 1142
		local ____tostring_27_result_33 = ____tostring_27(____options_max_tokens_26) -- 1142
		local ____tostring_29 = tostring -- 1142
		local ____options_temperature_28 = options.temperature -- 1142
		if ____options_temperature_28 == nil then -- 1142
			____options_temperature_28 = "unset" -- 1142
		end -- 1142
		____exports.Log( -- 1142
			"Info", -- 1142
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_30) .. " url=") .. ____url_31) .. " messages=") .. tostring(____temp_32)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_27_result_33) .. " temperature=") .. ____tostring_29(____options_temperature_28)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1142
		) -- 1142
		if stopToken and stopToken.stopped then -- 1142
			local reason = stopToken.reason or "request cancelled" -- 1144
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1145
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1145
		end -- 1145
		local ____hasReturned, ____returnValue -- 1145
		local ____try = __TS__AsyncAwaiter(function() -- 1145
			local states = {} -- 1149
			local emittedToolCallIds = {} -- 1150
			local responseId = nil -- 1151
			local responseCreated = nil -- 1152
			local responseObject = nil -- 1153
			local providerError -- 1154
			local responseUsage -- 1155
			local httpChunkCount = 0 -- 1156
			local rawStreamBytes = 0 -- 1157
			local rawStreamPreview = "" -- 1158
			local sseJSONChunkCount = 0 -- 1159
			local choiceJSONChunkCount = 0 -- 1160
			local emptyChoicesChunkCount = 0 -- 1161
			local missingChoicesChunkCount = 0 -- 1162
			local parseErrorCount = 0 -- 1163
			local doneChunkSeen = false -- 1164
			local lastJSONPreview = "" -- 1165
			local parser = ____exports.createSSEJSONParser({ -- 1166
				onJSON = function(obj, raw) -- 1167
					sseJSONChunkCount = sseJSONChunkCount + 1 -- 1168
					lastJSONPreview = previewText(raw, 500) -- 1169
					if not obj or type(obj) ~= "table" then -- 1169
						return -- 1171
					end -- 1171
					local chunk = obj -- 1173
					if chunk.error then -- 1173
						providerError = chunk.error -- 1175
						____exports.Log( -- 1176
							"Warn", -- 1176
							"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1176
						) -- 1176
						return -- 1177
					end -- 1177
					responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1179
					responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1180
					responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1181
					if chunk.usage and type(chunk.usage) == "table" then -- 1181
						responseUsage = chunk.usage -- 1183
					end -- 1183
					local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1185
					if not __TS__ArrayIsArray(chunk.choices) then -- 1185
						missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1187
						if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1187
							____exports.Log( -- 1189
								"Warn", -- 1189
								"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1189
							) -- 1189
						end -- 1189
					elseif #choices == 0 then -- 1189
						emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1192
						if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1192
							____exports.Log( -- 1194
								"Warn", -- 1194
								"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1194
							) -- 1194
						end -- 1194
					else -- 1194
						choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1197
					end -- 1197
					do -- 1197
						local i = 0 -- 1199
						while i < #choices do -- 1199
							local choice = choices[i + 1] -- 1200
							local index = type(choice.index) == "number" and choice.index or i -- 1201
							if states[index] == nil then -- 1201
								states[index] = {index = index, message = {role = "assistant"}} -- 1202
							end -- 1202
							mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1206
							i = i + 1 -- 1199
						end -- 1199
					end -- 1199
					if onChunk ~= nil then -- 1199
						onChunk( -- 1208
							buildStreamResponse( -- 1209
								states, -- 1209
								model, -- 1209
								responseId, -- 1209
								responseCreated, -- 1209
								responseObject, -- 1209
								providerError, -- 1209
								responseUsage -- 1209
							), -- 1209
							{ -- 1210
								id = chunk.id or "", -- 1211
								created = chunk.created or 0, -- 1212
								object = chunk.object or "", -- 1213
								model = chunk.model or model, -- 1214
								choices = choices -- 1215
							} -- 1215
						) -- 1215
					end -- 1215
				end, -- 1167
				onDone = function() -- 1219
					doneChunkSeen = true -- 1220
				end, -- 1219
				onError = function(err, context) -- 1222
					parseErrorCount = parseErrorCount + 1 -- 1223
					____exports.Log( -- 1224
						"Warn", -- 1224
						(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1224
					) -- 1224
				end -- 1222
			}) -- 1222
			__TS__Await(postLLM( -- 1227
				fitted.messages, -- 1227
				url, -- 1227
				apiKey, -- 1227
				model, -- 1227
				options, -- 1227
				true, -- 1227
				resolvedConfig.customOptions, -- 1227
				function(data) -- 1227
					if stopToken and stopToken.stopped then -- 1227
						return true -- 1228
					end -- 1228
					httpChunkCount = httpChunkCount + 1 -- 1229
					rawStreamBytes = rawStreamBytes + #data -- 1230
					if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1230
						rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1232
					end -- 1232
					parser.feed(data) -- 1234
					return false -- 1235
				end, -- 1227
				stopToken -- 1236
			)) -- 1236
			parser["end"]() -- 1237
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1237
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1239
				if rawResponse and type(rawResponse) == "table" then -- 1239
					local rawResponseObj = rawResponse -- 1241
					if rawResponseObj.error then -- 1241
						providerError = rawResponseObj.error -- 1243
						lastJSONPreview = previewText( -- 1244
							normalizeLLMJSONResponse(rawStreamPreview), -- 1244
							500 -- 1244
						) -- 1244
						____exports.Log( -- 1245
							"Warn", -- 1245
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1245
						) -- 1245
					end -- 1245
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1245
						responseUsage = rawResponseObj.usage -- 1248
					end -- 1248
				end -- 1248
			end -- 1248
			local response = buildStreamResponse( -- 1252
				states, -- 1252
				model, -- 1252
				responseId, -- 1252
				responseCreated, -- 1252
				responseObject, -- 1252
				providerError, -- 1252
				responseUsage -- 1252
			) -- 1252
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1253
			local choiceCount = response.choices and #response.choices or 0 -- 1254
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1255
			____exports.Log( -- 1256
				"Info", -- 1256
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1256
			) -- 1256
			if not doneChunkSeen then -- 1256
				local rawPreview = previewText( -- 1258
					____exports.sanitizeUTF8(rawStreamPreview), -- 1258
					1200 -- 1258
				) -- 1258
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1259
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1260
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1261
				____hasReturned = true -- 1262
				____returnValue = { -- 1262
					success = false, -- 1263
					message = message, -- 1264
					raw = rawStreamPreview, -- 1265
					response = response, -- 1266
					tokenUsage = tokenUsage -- 1267
				} -- 1267
				return -- 1262
			end -- 1262
			if not response.choices or #response.choices == 0 then -- 1262
				local providerMessage = providerError and providerError.message or "" -- 1271
				local providerType = providerError and providerError.type or "" -- 1272
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1273
				local details = table.concat( -- 1276
					__TS__ArrayFilter( -- 1276
						{providerType, providerCode}, -- 1276
						function(____, part) return part ~= "" end -- 1276
					), -- 1276
					"/" -- 1276
				) -- 1276
				local rawPreview = previewText( -- 1277
					____exports.sanitizeUTF8(rawStreamPreview), -- 1277
					1200 -- 1277
				) -- 1277
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1278
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1279
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1282
				____hasReturned = true -- 1283
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1283
				return -- 1283
			end -- 1283
			____hasReturned = true -- 1290
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1290
			return -- 1290
		end) -- 1290
		____try = ____try.catch( -- 1290
			____try, -- 1290
			function(____, e) -- 1290
				return __TS__AsyncAwaiter(function() -- 1290
					if stopToken and stopToken.stopped then -- 1290
						local reason = stopToken.reason or "request cancelled" -- 1297
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1298
						____hasReturned = true -- 1299
						____returnValue = {success = false, message = reason} -- 1299
						return -- 1299
					end -- 1299
					____exports.Log( -- 1301
						"Error", -- 1301
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1301
					) -- 1301
					____hasReturned = true -- 1302
					____returnValue = { -- 1302
						success = false, -- 1302
						message = tostring(e) -- 1302
					} -- 1302
					return -- 1302
				end) -- 1302
			end -- 1302
		) -- 1302
		__TS__Await(____try) -- 1148
		if ____hasReturned then -- 1148
			return ____awaiter_resolve(nil, ____returnValue) -- 1148
		end -- 1148
	end) -- 1148
end -- 1110
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1306
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1306
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1312
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1313
		local resolvedConfig = config or (function() -- 1316
			local configRes = ____exports.getActiveLLMConfig() -- 1317
			if not configRes.success then -- 1317
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1319
				return nil -- 1320
			end -- 1320
			return configRes.config -- 1322
		end)() -- 1316
		if not resolvedConfig then -- 1316
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1316
		end -- 1316
		local url = resolvedConfig.url -- 1316
		local model = resolvedConfig.model -- 1316
		local apiKey = resolvedConfig.apiKey -- 1316
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1328
		____exports.Log( -- 1329
			"Info", -- 1329
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1329
		) -- 1329
		if stopToken and stopToken.stopped then -- 1329
			local reason = stopToken.reason or "request cancelled" -- 1331
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1332
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1332
		end -- 1332
		local ____hasReturned, ____returnValue -- 1332
		local ____try = __TS__AsyncAwaiter(function() -- 1332
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1336
				fitted.messages, -- 1336
				url, -- 1336
				apiKey, -- 1336
				model, -- 1336
				options, -- 1336
				false, -- 1336
				resolvedConfig.customOptions, -- 1336
				nil, -- 1336
				stopToken -- 1336
			))) -- 1336
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1337
			____exports.Log( -- 1338
				"Info", -- 1338
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1338
			) -- 1338
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1339
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1339
				local rawPreview = previewText(raw) -- 1341
				____exports.Log( -- 1342
					"Error", -- 1342
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1342
				) -- 1342
				____hasReturned = true -- 1343
				____returnValue = { -- 1343
					success = false, -- 1344
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1345
					raw = raw -- 1346
				} -- 1346
				return -- 1343
			end -- 1343
			local responseObj = response -- 1349
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1350
			____exports.Log( -- 1351
				"Info", -- 1351
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1351
			) -- 1351
			if not responseObj.choices or #responseObj.choices == 0 then -- 1351
				local providerError = responseObj.error -- 1353
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1354
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1357
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1360
				local details = table.concat( -- 1363
					__TS__ArrayFilter( -- 1363
						{providerType, providerCode}, -- 1363
						function(____, part) return part ~= "" end -- 1363
					), -- 1363
					"/" -- 1363
				) -- 1363
				local rawPreview = previewText(raw, 400) -- 1364
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1365
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1368
				____hasReturned = true -- 1369
				____returnValue = {success = false, message = message, raw = raw} -- 1369
				return -- 1369
			end -- 1369
			____hasReturned = true -- 1375
			____returnValue = {success = true, response = responseObj} -- 1375
			return -- 1375
		end) -- 1375
		____try = ____try.catch( -- 1375
			____try, -- 1375
			function(____, e) -- 1375
				return __TS__AsyncAwaiter(function() -- 1375
					if stopToken and stopToken.stopped then -- 1375
						local reason = stopToken.reason or "request cancelled" -- 1381
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1382
						____hasReturned = true -- 1383
						____returnValue = {success = false, message = reason} -- 1383
						return -- 1383
					end -- 1383
					____exports.Log( -- 1385
						"Error", -- 1385
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1385
					) -- 1385
					____hasReturned = true -- 1386
					____returnValue = { -- 1386
						success = false, -- 1386
						message = tostring(e) -- 1386
					} -- 1386
					return -- 1386
				end) -- 1386
			end -- 1386
		) -- 1386
		__TS__Await(____try) -- 1335
		if ____hasReturned then -- 1335
			return ____awaiter_resolve(nil, ____returnValue) -- 1335
		end -- 1335
	end) -- 1335
end -- 1306
return ____exports -- 1306