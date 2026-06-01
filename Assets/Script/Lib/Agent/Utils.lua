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
function normalizeReasoningEffort(value) -- 791
	if type(value) ~= "string" then -- 791
		return nil -- 792
	end -- 792
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 793
	return normalized ~= "" and normalized or nil -- 794
end -- 794
function ____exports.applyCustomLLMOptions(options, customOptions) -- 805
	if not customOptions then -- 805
		return options -- 809
	end -- 809
	local merged = __TS__ObjectAssign({}, options) -- 810
	for key in pairs(customOptions) do -- 811
		local value = customOptions[key] -- 812
		if value == json.null then -- 812
			__TS__Delete(merged, key) -- 814
		else -- 814
			merged[key] = value -- 816
		end -- 816
	end -- 816
	return merged -- 819
end -- 805
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
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", "Accept: application/json"} -- 552
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
local function normalizeContextWindow(value) -- 766
	if type(value) == "number" then -- 766
		return math.max( -- 768
			64000, -- 768
			math.floor(value) -- 768
		) -- 768
	end -- 768
	return 64000 -- 770
end -- 766
local function normalizeSupportsFunctionCalling(value) -- 773
	return value == nil or value ~= 0 -- 774
end -- 773
local function normalizeLLMTemperature(value) -- 777
	if type(value) == "number" then -- 777
		return math.max( -- 779
			0, -- 779
			math.min(2, value) -- 779
		) -- 779
	end -- 779
	return 0.1 -- 781
end -- 777
local function normalizeLLMMaxTokens(value) -- 784
	if type(value) == "number" then -- 784
		return math.max( -- 786
			1, -- 786
			math.floor(value) -- 786
		) -- 786
	end -- 786
	return 8192 -- 788
end -- 784
local function normalizeLLMCustomOptions(value) -- 797
	if type(value) ~= "string" then -- 797
		return nil -- 798
	end -- 798
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 799
	if text == "" then -- 799
		return nil -- 800
	end -- 800
	local decoded = ____exports.safeJsonDecode(text) -- 801
	return isPlainRecord(decoded) and decoded or nil -- 802
end -- 797
function ____exports.getActiveLLMConfig() -- 822
	local rows = DB:query("select * from LLMConfig", true) -- 823
	local records = {} -- 824
	if rows and #rows > 1 then -- 824
		do -- 824
			local i = 1 -- 826
			while i < #rows do -- 826
				local record = {} -- 827
				do -- 827
					local c = 0 -- 828
					while c < #rows[i + 1] do -- 828
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 829
						c = c + 1 -- 828
					end -- 828
				end -- 828
				records[#records + 1] = record -- 831
				i = i + 1 -- 826
			end -- 826
		end -- 826
	end -- 826
	local config = __TS__ArrayFind( -- 834
		records, -- 834
		function(____, r) return r.active ~= 0 end -- 834
	) -- 834
	if not config then -- 834
		return {success = false, message = "no active LLM config"} -- 836
	end -- 836
	local url = config.url -- 836
	local model = config.model -- 836
	local api_key = config.api_key -- 836
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 836
		return {success = false, message = "got invalude LLM config"} -- 840
	end -- 840
	return { -- 842
		success = true, -- 843
		config = { -- 844
			url = url, -- 845
			model = model, -- 846
			apiKey = api_key, -- 847
			contextWindow = normalizeContextWindow(config.context_window), -- 848
			temperature = normalizeLLMTemperature(config.temperature), -- 849
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 850
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 851
			customOptions = normalizeLLMCustomOptions(config.custom_options), -- 852
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 853
		} -- 853
	} -- 853
end -- 822
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 858
	local callEvent -- 864
	if event.id ~= nil then -- 864
		local id = event.id -- 866
		callEvent = { -- 867
			id = nil, -- 868
			onData = function(data) -- 869
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 870
				return event.stopToken.stopped -- 871
			end, -- 869
			onCancel = function(reason) -- 873
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 874
			end, -- 873
			onDone = function() -- 876
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 877
			end -- 876
		} -- 876
	else -- 876
		callEvent = event -- 881
	end -- 881
	local ____callEvent_5 = callEvent -- 883
	local onData = ____callEvent_5.onData -- 883
	local onDone = ____callEvent_5.onDone -- 883
	local ____callEvent_6 = callEvent -- 884
	local onCancel = ____callEvent_6.onCancel -- 884
	local config = llmConfig or (function() -- 885
		local configRes = ____exports.getActiveLLMConfig() -- 886
		if not configRes.success then -- 886
			if onCancel then -- 886
				onCancel(configRes.message) -- 888
			end -- 888
			return nil -- 889
		end -- 889
		return configRes.config -- 891
	end)() -- 885
	if not config then -- 885
		return {success = false, message = "no active LLM config"} -- 894
	end -- 894
	local url = config.url -- 894
	local model = config.model -- 894
	local apiKey = config.apiKey -- 894
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 897
	if fitted.trimmed then -- 897
		____exports.Log( -- 899
			"Warn", -- 899
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 899
		) -- 899
	end -- 899
	local stopLLM = false -- 901
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 902
		local result = onData(obj) -- 904
		if result then -- 904
			stopLLM = result -- 905
		end -- 905
	end}); -- 903
	(function() -- 908
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 908
			local ____try = __TS__AsyncAwaiter(function() -- 908
				local ____array_8 = __TS__SparseArrayNew( -- 908
					fitted.messages, -- 910
					url, -- 910
					apiKey, -- 910
					model, -- 910
					options, -- 910
					true, -- 910
					config.customOptions, -- 910
					function(data) -- 910
						if stopLLM then -- 910
							if onCancel then -- 910
								onCancel("LLM Stopped") -- 913
								onCancel = nil -- 914
							end -- 914
							return true -- 916
						end -- 916
						parser.feed(data) -- 918
						return false -- 919
					end -- 910
				) -- 910
				local ____temp_7 -- 920
				if event.stopToken ~= nil then -- 920
					____temp_7 = event.stopToken -- 920
				else -- 920
					____temp_7 = nil -- 920
				end -- 920
				__TS__SparseArrayPush(____array_8, ____temp_7) -- 920
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_8))) -- 910
				parser["end"]() -- 921
				if onDone then -- 921
					onDone(result) -- 923
				end -- 923
			end) -- 923
			____try = ____try.catch( -- 923
				____try, -- 923
				function(____, e) -- 923
					return __TS__AsyncAwaiter(function() -- 923
						stopLLM = true -- 926
						if onCancel then -- 926
							onCancel(tostring(e)) -- 928
							onCancel = nil -- 929
						end -- 929
					end) -- 929
				end -- 929
			) -- 929
			__TS__Await(____try) -- 909
		end) -- 909
	end)() -- 908
	return {success = true} -- 933
end -- 858
local function mergeStreamToolCall(target, delta) -- 936
	if type(delta.id) == "string" and delta.id ~= "" then -- 936
		target.id = delta.id -- 938
	end -- 938
	if type(delta.type) == "string" and delta.type ~= "" then -- 938
		target.type = delta.type -- 941
	end -- 941
	if delta["function"] then -- 941
		if target["function"] == nil then -- 941
			target["function"] = {} -- 944
		end -- 944
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 944
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 946
		end -- 946
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 946
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 949
		end -- 949
	end -- 949
end -- 936
local function isToolCallComplete(tc) -- 954
	if type(tc.id) ~= "string" or tc.id == "" then -- 954
		return false -- 955
	end -- 955
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 955
		return false -- 956
	end -- 956
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 956
		return false -- 957
	end -- 957
	local args = tc["function"].arguments -- 958
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 958
		return false -- 959
	end -- 959
	local decoded = ____exports.safeJsonDecode(args) -- 960
	return decoded ~= nil -- 961
end -- 954
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 964
	local delta = choice.delta or ({}) -- 965
	local fullMessage = choice.message or ({}) -- 966
	local message = acc.message -- 967
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 968
	if type(role) == "string" and role ~= "" then -- 968
		message.role = role -- 972
	end -- 972
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 974
	if type(content) == "string" and content ~= "" then -- 974
		message.content = (message.content or "") .. content -- 978
	end -- 978
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 980
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 980
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 984
	end -- 984
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 986
	if toolCalls and #toolCalls > 0 then -- 986
		if message.tool_calls == nil then -- 986
			message.tool_calls = {} -- 990
		end -- 990
		do -- 990
			local i = 0 -- 991
			while i < #toolCalls do -- 991
				local item = toolCalls[i + 1] -- 992
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 993
				local ____message_tool_calls_9, ____temp_10 = message.tool_calls, index + 1 -- 993
				if ____message_tool_calls_9[____temp_10] == nil then -- 993
					____message_tool_calls_9[____temp_10] = {} -- 996
				end -- 996
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 997
				if onToolCallReady and emittedToolCallIds then -- 997
					local tc = message.tool_calls[index + 1] -- 999
					if tc and isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 999
						emittedToolCallIds[tc.id] = true -- 1001
						onToolCallReady(tc) -- 1002
					end -- 1002
				end -- 1002
				i = i + 1 -- 991
			end -- 991
		end -- 991
	end -- 991
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 991
		acc.finish_reason = choice.finish_reason -- 1008
	end -- 1008
end -- 964
local function buildStreamResponse(states, model, id, created, object, providerError) -- 1012
	local indexes = __TS__ArraySort( -- 1020
		__TS__ArrayFilter( -- 1020
			__TS__ArrayMap( -- 1020
				__TS__ObjectKeys(states), -- 1020
				function(____, key) return __TS__Number(key) end -- 1021
			), -- 1021
			function(____, index) return __TS__NumberIsFinite(index) end -- 1022
		), -- 1022
		function(____, a, b) return a - b end -- 1023
	) -- 1023
	return { -- 1024
		id = id, -- 1025
		created = created, -- 1026
		object = object, -- 1027
		model = model, -- 1028
		choices = __TS__ArrayMap( -- 1029
			indexes, -- 1029
			function(____, index) -- 1029
				local state = states[index] -- 1030
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1031
			end -- 1029
		), -- 1029
		error = providerError -- 1042
	} -- 1042
end -- 1012
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1046
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1046
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1054
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1055
		local resolvedConfig = config or (function() -- 1058
			local configRes = ____exports.getActiveLLMConfig() -- 1059
			if not configRes.success then -- 1059
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1061
				return nil -- 1062
			end -- 1062
			return configRes.config -- 1064
		end)() -- 1058
		if not resolvedConfig then -- 1058
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1058
		end -- 1058
		local url = resolvedConfig.url -- 1058
		local model = resolvedConfig.model -- 1058
		local apiKey = resolvedConfig.apiKey -- 1058
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1070
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1071
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1072
		local ____model_15 = model -- 1075
		local ____url_16 = url -- 1075
		local ____temp_17 = #messages -- 1075
		local ____tostring_12 = tostring -- 1075
		local ____options_max_tokens_11 = options.max_tokens -- 1075
		if ____options_max_tokens_11 == nil then -- 1075
			____options_max_tokens_11 = "unset" -- 1075
		end -- 1075
		local ____tostring_12_result_18 = ____tostring_12(____options_max_tokens_11) -- 1075
		local ____tostring_14 = tostring -- 1075
		local ____options_temperature_13 = options.temperature -- 1075
		if ____options_temperature_13 == nil then -- 1075
			____options_temperature_13 = "unset" -- 1075
		end -- 1075
		____exports.Log( -- 1075
			"Info", -- 1075
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_15) .. " url=") .. ____url_16) .. " messages=") .. tostring(____temp_17)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_12_result_18) .. " temperature=") .. ____tostring_14(____options_temperature_13)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1075
		) -- 1075
		if stopToken and stopToken.stopped then -- 1075
			local reason = stopToken.reason or "request cancelled" -- 1077
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1078
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1078
		end -- 1078
		local ____hasReturned, ____returnValue -- 1078
		local ____try = __TS__AsyncAwaiter(function() -- 1078
			local states = {} -- 1082
			local emittedToolCallIds = {} -- 1083
			local responseId = nil -- 1084
			local responseCreated = nil -- 1085
			local responseObject = nil -- 1086
			local providerError -- 1087
			local httpChunkCount = 0 -- 1088
			local rawStreamBytes = 0 -- 1089
			local rawStreamPreview = "" -- 1090
			local sseJSONChunkCount = 0 -- 1091
			local choiceJSONChunkCount = 0 -- 1092
			local emptyChoicesChunkCount = 0 -- 1093
			local missingChoicesChunkCount = 0 -- 1094
			local parseErrorCount = 0 -- 1095
			local doneChunkSeen = false -- 1096
			local lastJSONPreview = "" -- 1097
			local parser = ____exports.createSSEJSONParser({ -- 1098
				onJSON = function(obj, raw) -- 1099
					sseJSONChunkCount = sseJSONChunkCount + 1 -- 1100
					lastJSONPreview = previewText(raw, 500) -- 1101
					if not obj or type(obj) ~= "table" then -- 1101
						return -- 1103
					end -- 1103
					local chunk = obj -- 1105
					if chunk.error then -- 1105
						providerError = chunk.error -- 1107
						____exports.Log( -- 1108
							"Warn", -- 1108
							"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1108
						) -- 1108
						return -- 1109
					end -- 1109
					responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1111
					responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1112
					responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1113
					local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1114
					if not __TS__ArrayIsArray(chunk.choices) then -- 1114
						missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1116
						if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1116
							____exports.Log( -- 1118
								"Warn", -- 1118
								"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1118
							) -- 1118
						end -- 1118
					elseif #choices == 0 then -- 1118
						emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1121
						if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1121
							____exports.Log( -- 1123
								"Warn", -- 1123
								"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1123
							) -- 1123
						end -- 1123
					else -- 1123
						choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1126
					end -- 1126
					do -- 1126
						local i = 0 -- 1128
						while i < #choices do -- 1128
							local choice = choices[i + 1] -- 1129
							local index = type(choice.index) == "number" and choice.index or i -- 1130
							if states[index] == nil then -- 1130
								states[index] = {index = index, message = {role = "assistant"}} -- 1131
							end -- 1131
							mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1135
							i = i + 1 -- 1128
						end -- 1128
					end -- 1128
					if onChunk ~= nil then -- 1128
						onChunk( -- 1137
							buildStreamResponse( -- 1138
								states, -- 1138
								model, -- 1138
								responseId, -- 1138
								responseCreated, -- 1138
								responseObject, -- 1138
								providerError -- 1138
							), -- 1138
							{ -- 1139
								id = chunk.id or "", -- 1140
								created = chunk.created or 0, -- 1141
								object = chunk.object or "", -- 1142
								model = chunk.model or model, -- 1143
								choices = choices -- 1144
							} -- 1144
						) -- 1144
					end -- 1144
				end, -- 1099
				onDone = function() -- 1148
					doneChunkSeen = true -- 1149
				end, -- 1148
				onError = function(err, context) -- 1151
					parseErrorCount = parseErrorCount + 1 -- 1152
					____exports.Log( -- 1153
						"Warn", -- 1153
						(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1153
					) -- 1153
				end -- 1151
			}) -- 1151
			__TS__Await(postLLM( -- 1156
				fitted.messages, -- 1156
				url, -- 1156
				apiKey, -- 1156
				model, -- 1156
				options, -- 1156
				true, -- 1156
				resolvedConfig.customOptions, -- 1156
				function(data) -- 1156
					if stopToken and stopToken.stopped then -- 1156
						return true -- 1157
					end -- 1157
					httpChunkCount = httpChunkCount + 1 -- 1158
					rawStreamBytes = rawStreamBytes + #data -- 1159
					if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1159
						rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1161
					end -- 1161
					parser.feed(data) -- 1163
					return false -- 1164
				end, -- 1156
				stopToken -- 1165
			)) -- 1165
			parser["end"]() -- 1166
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1166
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1168
				if rawResponse and type(rawResponse) == "table" then -- 1168
					local rawResponseObj = rawResponse -- 1170
					if rawResponseObj.error then -- 1170
						providerError = rawResponseObj.error -- 1172
						lastJSONPreview = previewText( -- 1173
							normalizeLLMJSONResponse(rawStreamPreview), -- 1173
							500 -- 1173
						) -- 1173
						____exports.Log( -- 1174
							"Warn", -- 1174
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1174
						) -- 1174
					end -- 1174
				end -- 1174
			end -- 1174
			local response = buildStreamResponse( -- 1178
				states, -- 1178
				model, -- 1178
				responseId, -- 1178
				responseCreated, -- 1178
				responseObject, -- 1178
				providerError -- 1178
			) -- 1178
			local choiceCount = response.choices and #response.choices or 0 -- 1179
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1180
			____exports.Log( -- 1181
				"Info", -- 1181
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1181
			) -- 1181
			if not response.choices or #response.choices == 0 then -- 1181
				local providerMessage = providerError and providerError.message or "" -- 1183
				local providerType = providerError and providerError.type or "" -- 1184
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1185
				local details = table.concat( -- 1188
					__TS__ArrayFilter( -- 1188
						{providerType, providerCode}, -- 1188
						function(____, part) return part ~= "" end -- 1188
					), -- 1188
					"/" -- 1188
				) -- 1188
				local rawPreview = previewText( -- 1189
					____exports.sanitizeUTF8(rawStreamPreview), -- 1189
					1200 -- 1189
				) -- 1189
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1190
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1191
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1194
				____hasReturned = true -- 1195
				____returnValue = {success = false, message = message, raw = rawStreamPreview} -- 1195
				return -- 1195
			end -- 1195
			____hasReturned = true -- 1201
			____returnValue = {success = true, response = response} -- 1201
			return -- 1201
		end) -- 1201
		____try = ____try.catch( -- 1201
			____try, -- 1201
			function(____, e) -- 1201
				return __TS__AsyncAwaiter(function() -- 1201
					if stopToken and stopToken.stopped then -- 1201
						local reason = stopToken.reason or "request cancelled" -- 1207
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1208
						____hasReturned = true -- 1209
						____returnValue = {success = false, message = reason} -- 1209
						return -- 1209
					end -- 1209
					____exports.Log( -- 1211
						"Error", -- 1211
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1211
					) -- 1211
					____hasReturned = true -- 1212
					____returnValue = { -- 1212
						success = false, -- 1212
						message = tostring(e) -- 1212
					} -- 1212
					return -- 1212
				end) -- 1212
			end -- 1212
		) -- 1212
		__TS__Await(____try) -- 1081
		if ____hasReturned then -- 1081
			return ____awaiter_resolve(nil, ____returnValue) -- 1081
		end -- 1081
	end) -- 1081
end -- 1046
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1216
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1216
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1222
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1223
		local resolvedConfig = config or (function() -- 1226
			local configRes = ____exports.getActiveLLMConfig() -- 1227
			if not configRes.success then -- 1227
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1229
				return nil -- 1230
			end -- 1230
			return configRes.config -- 1232
		end)() -- 1226
		if not resolvedConfig then -- 1226
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1226
		end -- 1226
		local url = resolvedConfig.url -- 1226
		local model = resolvedConfig.model -- 1226
		local apiKey = resolvedConfig.apiKey -- 1226
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1238
		____exports.Log( -- 1239
			"Info", -- 1239
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1239
		) -- 1239
		if stopToken and stopToken.stopped then -- 1239
			local reason = stopToken.reason or "request cancelled" -- 1241
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1242
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1242
		end -- 1242
		local ____hasReturned, ____returnValue -- 1242
		local ____try = __TS__AsyncAwaiter(function() -- 1242
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1246
				fitted.messages, -- 1246
				url, -- 1246
				apiKey, -- 1246
				model, -- 1246
				options, -- 1246
				false, -- 1246
				resolvedConfig.customOptions, -- 1246
				nil, -- 1246
				stopToken -- 1246
			))) -- 1246
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1247
			____exports.Log( -- 1248
				"Info", -- 1248
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1248
			) -- 1248
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1249
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1249
				local rawPreview = previewText(raw) -- 1251
				____exports.Log( -- 1252
					"Error", -- 1252
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1252
				) -- 1252
				____hasReturned = true -- 1253
				____returnValue = { -- 1253
					success = false, -- 1254
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1255
					raw = raw -- 1256
				} -- 1256
				return -- 1253
			end -- 1253
			local responseObj = response -- 1259
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1260
			____exports.Log( -- 1261
				"Info", -- 1261
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1261
			) -- 1261
			if not responseObj.choices or #responseObj.choices == 0 then -- 1261
				local providerError = responseObj.error -- 1263
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1264
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1267
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1270
				local details = table.concat( -- 1273
					__TS__ArrayFilter( -- 1273
						{providerType, providerCode}, -- 1273
						function(____, part) return part ~= "" end -- 1273
					), -- 1273
					"/" -- 1273
				) -- 1273
				local rawPreview = previewText(raw, 400) -- 1274
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1275
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1278
				____hasReturned = true -- 1279
				____returnValue = {success = false, message = message, raw = raw} -- 1279
				return -- 1279
			end -- 1279
			____hasReturned = true -- 1285
			____returnValue = {success = true, response = responseObj} -- 1285
			return -- 1285
		end) -- 1285
		____try = ____try.catch( -- 1285
			____try, -- 1285
			function(____, e) -- 1285
				return __TS__AsyncAwaiter(function() -- 1285
					if stopToken and stopToken.stopped then -- 1285
						local reason = stopToken.reason or "request cancelled" -- 1291
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1292
						____hasReturned = true -- 1293
						____returnValue = {success = false, message = reason} -- 1293
						return -- 1293
					end -- 1293
					____exports.Log( -- 1295
						"Error", -- 1295
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1295
					) -- 1295
					____hasReturned = true -- 1296
					____returnValue = { -- 1296
						success = false, -- 1296
						message = tostring(e) -- 1296
					} -- 1296
					return -- 1296
				end) -- 1296
			end -- 1296
		) -- 1296
		__TS__Await(____try) -- 1245
		if ____hasReturned then -- 1245
			return ____awaiter_resolve(nil, ____returnValue) -- 1245
		end -- 1245
	end) -- 1245
end -- 1216
return ____exports -- 1216