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
function normalizeReasoningEffort(value) -- 855
	if type(value) ~= "string" then -- 855
		return nil -- 856
	end -- 856
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 857
	return normalized ~= "" and normalized or nil -- 858
end -- 858
function ____exports.applyCustomLLMOptions(options, customOptions) -- 869
	if not customOptions then -- 869
		return options -- 873
	end -- 873
	local merged = __TS__ObjectAssign({}, options) -- 874
	for key in pairs(customOptions) do -- 875
		local value = customOptions[key] -- 876
		if value == json.null then -- 876
			__TS__Delete(merged, key) -- 878
		else -- 878
			merged[key] = value -- 880
		end -- 880
	end -- 880
	return merged -- 883
end -- 869
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
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000 -- 193
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 196
	local optionTokens = estimateOptionsTokens(options) -- 197
	local structuralOverhead = math.max(256, #messages * 16) -- 198
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 199
end -- 192
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 202
	if budgetTokens <= 0 or text == "" then -- 202
		return "" -- 203
	end -- 203
	local estimated = ____exports.estimateTextTokens(text) -- 204
	if estimated <= budgetTokens then -- 204
		return text -- 205
	end -- 205
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 206
	local targetChars = math.max( -- 207
		200, -- 207
		math.floor(budgetTokens * charsPerToken) -- 207
	) -- 207
	local keepHead = math.max( -- 208
		0, -- 208
		math.floor(targetChars * 0.35) -- 208
	) -- 208
	local keepTail = math.max(0, targetChars - keepHead) -- 209
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 210
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 211
	return (head .. "\n...\n") .. tail -- 212
end -- 202
local function isXMLWhitespaceChar(ch) -- 215
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 216
end -- 215
local function findLineStart(value, from) -- 219
	local i = from -- 220
	while i >= 0 do -- 220
		if __TS__StringAccess(value, i) == "\n" then -- 220
			return i + 1 -- 222
		end -- 222
		i = i - 1 -- 223
	end -- 223
	return 0 -- 225
end -- 219
local function findLastLiteral(text, needle) -- 228
	if needle == "" then -- 228
		return #text -- 229
	end -- 229
	local last = -1 -- 230
	local from = 0 -- 231
	while from <= #text - #needle do -- 231
		local pos = (string.find( -- 233
			text, -- 233
			needle, -- 233
			math.max(from + 1, 1), -- 233
			true -- 233
		) or 0) - 1 -- 233
		if pos < 0 then -- 233
			break -- 234
		end -- 234
		last = pos -- 235
		from = pos + 1 -- 236
	end -- 236
	return last -- 238
end -- 228
local function unwrapXMLRawText(text) -- 241
	local trimmed = __TS__StringTrim(text) -- 242
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 242
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 244
	end -- 244
	return text -- 246
end -- 241
local function readSimpleXMLTagName(source, openStart, openEnd) -- 249
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 250
	if rawTag == "" then -- 250
		return { -- 252
			success = false, -- 252
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 252
		} -- 252
	end -- 252
	local selfClosing = false -- 254
	local tagText = rawTag -- 255
	if __TS__StringEndsWith(tagText, "/") then -- 255
		selfClosing = true -- 257
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 258
	end -- 258
	local tagName = "" -- 260
	do -- 260
		local i = 0 -- 261
		while i < #tagText do -- 261
			local ch = __TS__StringAccess(tagText, i) -- 262
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 262
				break -- 263
			end -- 263
			tagName = tagName .. ch -- 264
			i = i + 1 -- 261
		end -- 261
	end -- 261
	if tagName == "" then -- 261
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 267
	end -- 267
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 269
end -- 249
local function findMatchingXMLClose(source, tagName, contentStart) -- 272
	local sameOpenPrefix = "<" .. tagName -- 273
	local sameCloseToken = ("</" .. tagName) .. ">" -- 274
	local pos = contentStart -- 275
	local depth = 1 -- 276
	while pos < #source do -- 276
		do -- 276
			local lt = (string.find( -- 278
				source, -- 278
				"<", -- 278
				math.max(pos + 1, 1), -- 278
				true -- 278
			) or 0) - 1 -- 278
			if lt < 0 then -- 278
				break -- 279
			end -- 279
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 279
				local cdataEnd = (string.find( -- 281
					source, -- 281
					"]]>", -- 281
					math.max(lt + 9 + 1, 1), -- 281
					true -- 281
				) or 0) - 1 -- 281
				if cdataEnd < 0 then -- 281
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 282
				end -- 282
				pos = cdataEnd + 3 -- 283
				goto __continue68 -- 284
			end -- 284
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 287
					source, -- 287
					"-->",
					math.max(lt + 4 + 1, 1), -- 287
					true -- 287
				) or 0) - 1 -- 287
				if commentEnd < 0 then -- 287
					return {success = false, message = "invalid xml: unterminated comment"} -- 288
				end -- 288
				pos = commentEnd + 3 -- 289
				goto __continue68 -- 290
			end -- 290
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 290
				depth = depth - 1 -- 293
				if depth == 0 then -- 293
					return {success = true, closeStart = lt} -- 294
				end -- 294
				pos = lt + #sameCloseToken -- 295
				goto __continue68 -- 296
			end -- 296
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 296
				local openEnd = (string.find( -- 299
					source, -- 299
					">", -- 299
					math.max(lt + 1, 1), -- 299
					true -- 299
				) or 0) - 1 -- 299
				if openEnd < 0 then -- 299
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 300
				end -- 300
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 301
				if not tagInfo.success then -- 301
					return tagInfo -- 302
				end -- 302
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 302
					depth = depth + 1 -- 304
				end -- 304
				pos = openEnd + 1 -- 306
				goto __continue68 -- 307
			end -- 307
			local genericEnd = (string.find( -- 309
				source, -- 309
				">", -- 309
				math.max(lt + 1, 1), -- 309
				true -- 309
			) or 0) - 1 -- 309
			if genericEnd < 0 then -- 309
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 310
			end -- 310
			pos = genericEnd + 1 -- 311
		end -- 311
		::__continue68:: -- 311
	end -- 311
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 313
end -- 272
function ____exports.extractXMLFromText(text) -- 316
	local source = __TS__StringTrim(text) -- 317
	local function extractFencedBlock(fence) -- 318
		if not __TS__StringStartsWith(source, fence) then -- 318
			return nil -- 319
		end -- 319
		local firstLineEnd = (string.find( -- 320
			source, -- 320
			"\n", -- 320
			math.max(1, 1), -- 320
			true -- 320
		) or 0) - 1 -- 320
		if firstLineEnd < 0 then -- 320
			return nil -- 321
		end -- 321
		local searchPos = firstLineEnd + 1 -- 322
		local closingFencePositions = {} -- 323
		while searchPos < #source do -- 323
			local ____end = (string.find( -- 325
				source, -- 325
				"```", -- 325
				math.max(searchPos + 1, 1), -- 325
				true -- 325
			) or 0) - 1 -- 325
			if ____end < 0 then -- 325
				break -- 326
			end -- 326
			local lineStart = findLineStart(source, ____end - 1) -- 327
			local lineEnd = (string.find( -- 328
				source, -- 328
				"\n", -- 328
				math.max(____end + 1, 1), -- 328
				true -- 328
			) or 0) - 1 -- 328
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 329
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 329
				closingFencePositions[#closingFencePositions + 1] = ____end -- 331
			end -- 331
			searchPos = ____end + 1 -- 333
		end -- 333
		do -- 333
			local i = #closingFencePositions - 1 -- 335
			while i >= 0 do -- 335
				do -- 335
					local closingFencePos = closingFencePositions[i + 1] -- 336
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 337
					if afterFence ~= "" then -- 337
						goto __continue89 -- 338
					end -- 338
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 339
				end -- 339
				::__continue89:: -- 339
				i = i - 1 -- 335
			end -- 335
		end -- 335
		return nil -- 341
	end -- 318
	local xmlBlock = extractFencedBlock("```xml") -- 343
	if xmlBlock ~= nil then -- 343
		return xmlBlock -- 344
	end -- 344
	local genericBlock = extractFencedBlock("```") -- 345
	if genericBlock ~= nil then -- 345
		return genericBlock -- 346
	end -- 346
	return source -- 347
end -- 316
function ____exports.parseSimpleXMLChildren(source) -- 350
	local result = {} -- 351
	local pos = 0 -- 352
	while pos < #source do -- 352
		do -- 352
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 352
				pos = pos + 1 -- 354
			end -- 354
			if pos >= #source then -- 354
				break -- 355
			end -- 355
			if __TS__StringAccess(source, pos) ~= "<" then -- 355
				return { -- 357
					success = false, -- 357
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 357
				} -- 357
			end -- 357
			if __TS__StringStartsWith(source, "</", pos) then -- 357
				return { -- 360
					success = false, -- 360
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 360
				} -- 360
			end -- 360
			local openEnd = (string.find( -- 362
				source, -- 362
				">", -- 362
				math.max(pos + 1, 1), -- 362
				true -- 362
			) or 0) - 1 -- 362
			if openEnd < 0 then -- 362
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 364
			end -- 364
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 366
			if not tagInfo.success then -- 366
				return tagInfo -- 367
			end -- 367
			if tagInfo.selfClosing then -- 367
				result[tagInfo.tagName] = "" -- 369
				pos = openEnd + 1 -- 370
				goto __continue94 -- 371
			end -- 371
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 373
			if not closeRes.success then -- 373
				return closeRes -- 374
			end -- 374
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 375
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 376
			pos = closeRes.closeStart + #closeToken -- 377
		end -- 377
		::__continue94:: -- 377
	end -- 377
	return {success = true, obj = result} -- 379
end -- 350
function ____exports.parseXMLObjectFromText(text, rootTag) -- 382
	local xmlText = ____exports.extractXMLFromText(text) -- 383
	local rootOpen = ("<" .. rootTag) .. ">" -- 384
	local rootClose = ("</" .. rootTag) .. ">" -- 385
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 386
	local ____end = findLastLiteral(xmlText, rootClose) -- 387
	if start < 0 or ____end < start then -- 387
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 389
	end -- 389
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 391
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 392
	if beforeRoot ~= "" or afterRoot ~= "" then -- 392
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 394
	end -- 394
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 396
	return ____exports.parseSimpleXMLChildren(rootContent) -- 397
end -- 382
function ____exports.fitMessagesToContext(messages, options, config) -- 400
	local modelName = string.lower(config.model) -- 407
	local shouldEchoReasoningContent = __TS__ArraySome( -- 408
		messages, -- 408
		function(____, message) return type(message.reasoning_content) == "string" end -- 408
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking") -- 408
	local cloned = __TS__ArrayMap( -- 412
		messages, -- 412
		function(____, message) -- 412
			local clonedMessage = __TS__ObjectAssign({}, message) -- 413
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then -- 413
				clonedMessage.reasoning_content = "" -- 419
			end -- 419
			return clonedMessage -- 421
		end -- 412
	) -- 412
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 423
	local originalTokens = estimateMessagesTokens(cloned) -- 424
	if originalTokens <= budgetTokens then -- 424
		return { -- 426
			messages = cloned, -- 427
			trimmed = false, -- 428
			originalTokens = originalTokens, -- 429
			fittedTokens = originalTokens, -- 430
			budgetTokens = budgetTokens -- 431
		} -- 431
	end -- 431
	local function roleOverhead(message) -- 435
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 435
	end -- 435
	local fixedOverhead = 0 -- 436
	local contentIndexes = {} -- 437
	do -- 437
		local i = 0 -- 438
		while i < #cloned do -- 438
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 439
			contentIndexes[#contentIndexes + 1] = i -- 440
			i = i + 1 -- 438
		end -- 438
	end -- 438
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 442
	if #contentIndexes == 1 then -- 442
		local idx = contentIndexes[1] -- 444
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 445
		local fittedTokens = estimateMessagesTokens(cloned) -- 446
		return { -- 447
			messages = cloned, -- 448
			trimmed = true, -- 449
			originalTokens = originalTokens, -- 450
			fittedTokens = fittedTokens, -- 451
			budgetTokens = budgetTokens -- 452
		} -- 452
	end -- 452
	local nonSystemIndexes = {} -- 456
	local systemIndexes = {} -- 457
	do -- 457
		local i = 0 -- 458
		while i < #cloned do -- 458
			if cloned[i + 1].role == "system" then -- 458
				systemIndexes[#systemIndexes + 1] = i -- 459
			else -- 459
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 460
			end -- 460
			i = i + 1 -- 458
		end -- 458
	end -- 458
	local ____array_0 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 458
	__TS__SparseArrayPush( -- 458
		____array_0, -- 458
		table.unpack(systemIndexes) -- 462
	) -- 462
	local priorityIndexes = {__TS__SparseArraySpread(____array_0)} -- 462
	local remainingContentBudget = contentBudget -- 463
	do -- 463
		local i = #priorityIndexes - 1 -- 464
		while i >= 0 do -- 464
			local idx = priorityIndexes[i + 1] -- 465
			local message = cloned[idx + 1] -- 466
			local minBudget = message.role == "system" and 96 or 192 -- 467
			local target = math.max( -- 468
				minBudget, -- 468
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 468
			) -- 468
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 469
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 470
			remainingContentBudget = math.max(0, remainingContentBudget) -- 471
			i = i - 1 -- 464
		end -- 464
	end -- 464
	local fittedTokens = estimateMessagesTokens(cloned) -- 474
	if fittedTokens > budgetTokens then -- 474
		do -- 474
			local i = 0 -- 476
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 476
				local idx = priorityIndexes[i + 1] -- 477
				local message = cloned[idx + 1] -- 478
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 479
				local excess = fittedTokens - budgetTokens -- 480
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 481
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 482
				fittedTokens = estimateMessagesTokens(cloned) -- 483
				i = i + 1 -- 476
			end -- 476
		end -- 476
	end -- 476
	if fittedTokens > budgetTokens then -- 476
		do -- 476
			local i = 0 -- 487
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 487
				do -- 487
					local idx = priorityIndexes[i + 1] -- 488
					if cloned[idx + 1].role == "system" then -- 488
						goto __continue126 -- 489
					end -- 489
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 490
					fittedTokens = estimateMessagesTokens(cloned) -- 491
				end -- 491
				::__continue126:: -- 491
				i = i + 1 -- 487
			end -- 487
		end -- 487
	end -- 487
	return { -- 494
		messages = cloned, -- 495
		trimmed = true, -- 496
		originalTokens = originalTokens, -- 497
		fittedTokens = fittedTokens, -- 498
		budgetTokens = budgetTokens -- 499
	} -- 499
end -- 400
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken) -- 503
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 514
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions) -- 515
	local data = __TS__ObjectAssign({}, requestOptions, {model = model, messages = messages, stream = stream}) -- 516
	if stopToken == nil then -- 516
		stopToken = {stopped = false} -- 522
	end -- 522
	return __TS__New( -- 523
		__TS__Promise, -- 523
		function(____, resolve, reject) -- 523
			local requestId = 0 -- 524
			local settled = false -- 525
			local function finishResolve(text) -- 526
				if settled then -- 526
					return -- 527
				end -- 527
				settled = true -- 528
				resolve(nil, text) -- 529
			end -- 526
			local function finishReject(err) -- 531
				if settled then -- 531
					return -- 532
				end -- 532
				settled = true -- 533
				reject(nil, err) -- 534
			end -- 531
			Director.systemScheduler:schedule(function() -- 536
				if not settled then -- 536
					if stopToken.stopped then -- 536
						if requestId ~= 0 then -- 536
							HttpClient:cancel(requestId) -- 540
							requestId = 0 -- 541
						end -- 541
						finishReject("request cancelled") -- 543
						return true -- 544
					end -- 544
					return false -- 546
				end -- 546
				return true -- 548
			end) -- 536
			Director.systemScheduler:schedule(once(function() -- 550
				emit( -- 551
					"LLM_IN", -- 551
					table.concat( -- 551
						__TS__ArrayMap( -- 551
							messages, -- 551
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 551
						), -- 551
						"\n" -- 551
					) -- 551
				) -- 551
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 552
				if jsonStr ~= nil then -- 552
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", receiver and "Accept: text/event-stream" or "Accept: application/json"} -- 554
					requestId = receiver and HttpClient:post( -- 559
						url, -- 560
						headers, -- 560
						jsonStr, -- 560
						requestTimeout, -- 560
						function(data) -- 560
							if stopToken.stopped then -- 560
								return true -- 561
							end -- 561
							return receiver(data) -- 562
						end, -- 560
						function(data) -- 563
							requestId = 0 -- 564
							if data ~= nil then -- 564
								finishResolve(data) -- 566
							else -- 566
								finishReject("failed to get http response") -- 568
							end -- 568
						end -- 563
					) or HttpClient:post( -- 563
						url, -- 571
						headers, -- 571
						jsonStr, -- 571
						requestTimeout, -- 571
						function(data) -- 571
							requestId = 0 -- 572
							if stopToken.stopped then -- 572
								finishReject("request cancelled") -- 574
								return -- 575
							end -- 575
							if data ~= nil then -- 575
								finishResolve(data) -- 578
							else -- 578
								finishReject("failed to get http response") -- 580
							end -- 580
						end -- 571
					) -- 571
					if requestId == 0 then -- 571
						finishReject("failed to schedule http request") -- 584
					elseif stopToken.stopped then -- 584
						HttpClient:cancel(requestId) -- 586
						requestId = 0 -- 587
						finishReject("request cancelled") -- 588
					end -- 588
				else -- 588
					finishReject(err) -- 591
				end -- 591
			end)) -- 550
		end -- 523
	) -- 523
end -- 503
function ____exports.createSSEJSONParser(opts) -- 601
	local buffer = "" -- 606
	local eventDataLines = {} -- 607
	local function flushEventIfAny() -- 609
		if #eventDataLines == 0 then -- 609
			return -- 610
		end -- 610
		local dataPayload = table.concat(eventDataLines, "\n") -- 612
		eventDataLines = {} -- 613
		if dataPayload == "[DONE]" then -- 613
			local ____opt_1 = opts.onDone -- 613
			if ____opt_1 ~= nil then -- 613
				____opt_1(dataPayload) -- 616
			end -- 616
			return -- 617
		end -- 617
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 620
		if err == nil then -- 620
			opts.onJSON(obj, dataPayload) -- 622
		else -- 622
			local ____opt_3 = opts.onError -- 622
			if ____opt_3 ~= nil then -- 622
				____opt_3(err, {raw = dataPayload}) -- 624
			end -- 624
		end -- 624
	end -- 609
	local function feed(chunk) -- 628
		buffer = buffer .. chunk -- 629
		while true do -- 629
			do -- 629
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 632
				if nl < 0 then -- 632
					break -- 633
				end -- 633
				local line = __TS__StringSlice(buffer, 0, nl) -- 635
				buffer = __TS__StringSlice(buffer, nl + 1) -- 636
				if __TS__StringEndsWith(line, "\r") then -- 636
					line = string.sub(line, 1, -2) -- 638
				end -- 638
				if line == "" then -- 638
					flushEventIfAny() -- 641
					goto __continue160 -- 642
				end -- 642
				if __TS__StringStartsWith(line, ":") then -- 642
					goto __continue160 -- 646
				end -- 646
				if __TS__StringStartsWith(line, "data:") then -- 646
					local v = string.sub(line, 6) -- 649
					if __TS__StringStartsWith(v, " ") then -- 649
						v = string.sub(v, 2) -- 650
					end -- 650
					eventDataLines[#eventDataLines + 1] = v -- 651
					goto __continue160 -- 652
				end -- 652
			end -- 652
			::__continue160:: -- 652
		end -- 652
	end -- 628
	local function ____end() -- 657
		if #buffer > 0 then -- 657
			local line = buffer -- 659
			buffer = "" -- 660
			if __TS__StringEndsWith(line, "\r") then -- 660
				line = string.sub(line, 1, -2) -- 661
			end -- 661
			if __TS__StringStartsWith(line, "data:") then -- 661
				local v = string.sub(line, 6) -- 664
				if __TS__StringStartsWith(v, " ") then -- 664
					v = string.sub(v, 2) -- 665
				end -- 665
				eventDataLines[#eventDataLines + 1] = v -- 666
			end -- 666
		end -- 666
		flushEventIfAny() -- 669
	end -- 657
	return {feed = feed, ["end"] = ____end} -- 672
end -- 601
function ____exports.extractLLMTokenUsage(response) -- 766
	local usage = response and response.usage -- 767
	if not usage or type(usage) ~= "table" then -- 767
		return nil -- 768
	end -- 768
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens -- 769
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens -- 772
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then -- 772
		return nil -- 775
	end -- 775
	local ____temp_12 -- 776
	if type(usage.prompt_cache_hit_tokens) == "number" then -- 776
		____temp_12 = usage.prompt_cache_hit_tokens -- 777
	else -- 777
		local ____temp_11 -- 778
		local ____opt_7 = usage.prompt_tokens_details -- 778
		if type(____opt_7 and ____opt_7.cached_tokens) == "number" then -- 778
			____temp_11 = usage.prompt_tokens_details.cached_tokens -- 779
		else -- 779
			local ____opt_9 = usage.input_tokens_details -- 779
			____temp_11 = type(____opt_9 and ____opt_9.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens -- 780
		end -- 780
		____temp_12 = ____temp_11 -- 778
	end -- 778
	local cachedInputTokens = ____temp_12 -- 776
	local ____inputTokens_15 = inputTokens -- 784
	local ____outputTokens_16 = outputTokens -- 785
	local ____temp_17 = type(usage.total_tokens) == "number" and usage.total_tokens or nil -- 786
	local ____temp_18 = type(cachedInputTokens) == "number" and cachedInputTokens or nil -- 787
	local ____temp_19 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil -- 788
	local ____opt_13 = usage.completion_tokens_details -- 788
	return { -- 783
		inputTokens = ____inputTokens_15, -- 784
		outputTokens = ____outputTokens_16, -- 785
		totalTokens = ____temp_17, -- 786
		cachedInputTokens = ____temp_18, -- 787
		cacheMissInputTokens = ____temp_19, -- 788
		reasoningOutputTokens = type(____opt_13 and ____opt_13.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil -- 791
	} -- 791
end -- 766
local function normalizeContextWindow(value) -- 830
	if type(value) == "number" and value > 0 then -- 830
		return math.floor(value) -- 832
	end -- 832
	return 64000 -- 834
end -- 830
local function normalizeSupportsFunctionCalling(value) -- 837
	return value == nil or value ~= 0 -- 838
end -- 837
local function normalizeLLMTemperature(value) -- 841
	if type(value) == "number" then -- 841
		return math.max( -- 843
			0, -- 843
			math.min(2, value) -- 843
		) -- 843
	end -- 843
	return 0.1 -- 845
end -- 841
local function normalizeLLMMaxTokens(value) -- 848
	if type(value) == "number" then -- 848
		return math.max( -- 850
			1, -- 850
			math.floor(value) -- 850
		) -- 850
	end -- 850
	return 8192 -- 852
end -- 848
local function normalizeLLMCustomOptions(value) -- 861
	if type(value) ~= "string" then -- 861
		return nil -- 862
	end -- 862
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 863
	if text == "" then -- 863
		return nil -- 864
	end -- 864
	local decoded = ____exports.safeJsonDecode(text) -- 865
	return isPlainRecord(decoded) and decoded or nil -- 866
end -- 861
function ____exports.getActiveLLMConfig() -- 886
	local rows = DB:query("select * from LLMConfig", true) -- 887
	local records = {} -- 888
	if rows and #rows > 1 then -- 888
		do -- 888
			local i = 1 -- 890
			while i < #rows do -- 890
				local record = {} -- 891
				do -- 891
					local c = 0 -- 892
					while c < #rows[i + 1] do -- 892
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 893
						c = c + 1 -- 892
					end -- 892
				end -- 892
				records[#records + 1] = record -- 895
				i = i + 1 -- 890
			end -- 890
		end -- 890
	end -- 890
	local config = __TS__ArrayFind( -- 898
		records, -- 898
		function(____, r) return r.active ~= 0 end -- 898
	) -- 898
	if not config then -- 898
		return {success = false, message = "no active LLM config"} -- 900
	end -- 900
	local url = config.url -- 900
	local model = config.model -- 900
	local api_key = config.api_key -- 900
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 900
		return {success = false, message = "got invalude LLM config"} -- 904
	end -- 904
	return { -- 906
		success = true, -- 907
		config = { -- 908
			url = url, -- 909
			model = model, -- 910
			apiKey = api_key, -- 911
			contextWindow = normalizeContextWindow(config.context_window), -- 912
			temperature = normalizeLLMTemperature(config.temperature), -- 913
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 914
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 915
			customOptions = normalizeLLMCustomOptions(config.custom_options), -- 916
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 917
		} -- 917
	} -- 917
end -- 886
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 922
	local callEvent -- 928
	if event.id ~= nil then -- 928
		local id = event.id -- 930
		callEvent = { -- 931
			id = nil, -- 932
			onData = function(data) -- 933
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 934
				return event.stopToken.stopped -- 935
			end, -- 933
			onCancel = function(reason) -- 937
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 938
			end, -- 937
			onDone = function() -- 940
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 941
			end -- 940
		} -- 940
	else -- 940
		callEvent = event -- 945
	end -- 945
	local ____callEvent_20 = callEvent -- 947
	local onData = ____callEvent_20.onData -- 947
	local onDone = ____callEvent_20.onDone -- 947
	local ____callEvent_21 = callEvent -- 948
	local onCancel = ____callEvent_21.onCancel -- 948
	local config = llmConfig or (function() -- 949
		local configRes = ____exports.getActiveLLMConfig() -- 950
		if not configRes.success then -- 950
			if onCancel then -- 950
				onCancel(configRes.message) -- 952
			end -- 952
			return nil -- 953
		end -- 953
		return configRes.config -- 955
	end)() -- 949
	if not config then -- 949
		return {success = false, message = "no active LLM config"} -- 958
	end -- 958
	local url = config.url -- 958
	local model = config.model -- 958
	local apiKey = config.apiKey -- 958
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 961
	if fitted.trimmed then -- 961
		____exports.Log( -- 963
			"Warn", -- 963
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 963
		) -- 963
	end -- 963
	local stopLLM = false -- 965
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 966
		local result = onData(obj) -- 968
		if result then -- 968
			stopLLM = result -- 969
		end -- 969
	end}); -- 967
	(function() -- 972
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 972
			local ____try = __TS__AsyncAwaiter(function() -- 972
				local ____array_23 = __TS__SparseArrayNew( -- 972
					fitted.messages, -- 974
					url, -- 974
					apiKey, -- 974
					model, -- 974
					options, -- 974
					true, -- 974
					config.customOptions, -- 974
					function(data) -- 974
						if stopLLM then -- 974
							if onCancel then -- 974
								onCancel("LLM Stopped") -- 977
								onCancel = nil -- 978
							end -- 978
							return true -- 980
						end -- 980
						parser.feed(data) -- 982
						return false -- 983
					end -- 974
				) -- 974
				local ____temp_22 -- 984
				if event.stopToken ~= nil then -- 984
					____temp_22 = event.stopToken -- 984
				else -- 984
					____temp_22 = nil -- 984
				end -- 984
				__TS__SparseArrayPush(____array_23, ____temp_22) -- 984
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_23))) -- 974
				parser["end"]() -- 985
				if onDone then -- 985
					onDone(result) -- 987
				end -- 987
			end) -- 987
			____try = ____try.catch( -- 987
				____try, -- 987
				function(____, e) -- 987
					return __TS__AsyncAwaiter(function() -- 987
						stopLLM = true -- 990
						if onCancel then -- 990
							onCancel(tostring(e)) -- 992
							onCancel = nil -- 993
						end -- 993
					end) -- 993
				end -- 993
			) -- 993
			__TS__Await(____try) -- 973
		end) -- 973
	end)() -- 972
	return {success = true} -- 997
end -- 922
local function mergeStreamToolCall(target, delta) -- 1000
	if type(delta.id) == "string" and delta.id ~= "" then -- 1000
		target.id = delta.id -- 1002
	end -- 1002
	if type(delta.type) == "string" and delta.type ~= "" then -- 1002
		target.type = delta.type -- 1005
	end -- 1005
	if delta["function"] then -- 1005
		if target["function"] == nil then -- 1005
			target["function"] = {} -- 1008
		end -- 1008
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 1008
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 1010
		end -- 1010
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 1010
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 1013
		end -- 1013
	end -- 1013
end -- 1000
local function isToolCallComplete(tc) -- 1018
	if type(tc.id) ~= "string" or tc.id == "" then -- 1018
		return false -- 1019
	end -- 1019
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 1019
		return false -- 1020
	end -- 1020
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 1020
		return false -- 1021
	end -- 1021
	local args = tc["function"].arguments -- 1022
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 1022
		return false -- 1023
	end -- 1023
	local decoded = ____exports.safeJsonDecode(args) -- 1024
	return decoded ~= nil -- 1025
end -- 1018
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 1028
	local delta = choice.delta or ({}) -- 1029
	local fullMessage = choice.message or ({}) -- 1030
	local message = acc.message -- 1031
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 1032
	if type(role) == "string" and role ~= "" then -- 1032
		message.role = role -- 1036
	end -- 1036
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 1038
	if type(content) == "string" and content ~= "" then -- 1038
		message.content = (message.content or "") .. content -- 1042
	end -- 1042
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 1044
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 1044
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 1048
	end -- 1048
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 1050
	if #toolCalls > 0 then -- 1050
		if message.tool_calls == nil then -- 1050
			message.tool_calls = {} -- 1054
		end -- 1054
		do -- 1054
			local i = 0 -- 1055
			while i < #toolCalls do -- 1055
				local item = toolCalls[i + 1] -- 1056
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 1057
				local ____message_tool_calls_24, ____temp_25 = message.tool_calls, index + 1 -- 1057
				if ____message_tool_calls_24[____temp_25] == nil then -- 1057
					____message_tool_calls_24[____temp_25] = {} -- 1060
				end -- 1060
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 1061
				if onToolCallReady and emittedToolCallIds then -- 1061
					local tc = message.tool_calls[index + 1] -- 1063
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 1063
						emittedToolCallIds[tc.id] = true -- 1065
						onToolCallReady(tc) -- 1066
					end -- 1066
				end -- 1066
				i = i + 1 -- 1055
			end -- 1055
		end -- 1055
	end -- 1055
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 1055
		acc.finish_reason = choice.finish_reason -- 1072
	end -- 1072
end -- 1028
local function buildStreamResponse(states, model, id, created, object, providerError, usage) -- 1076
	local indexes = __TS__ArraySort( -- 1085
		__TS__ArrayFilter( -- 1085
			__TS__ArrayMap( -- 1085
				__TS__ObjectKeys(states), -- 1085
				function(____, key) return __TS__Number(key) end -- 1086
			), -- 1086
			function(____, index) return __TS__NumberIsFinite(index) end -- 1087
		), -- 1087
		function(____, a, b) return a - b end -- 1088
	) -- 1088
	return { -- 1089
		id = id, -- 1090
		created = created, -- 1091
		object = object, -- 1092
		model = model, -- 1093
		choices = __TS__ArrayMap( -- 1094
			indexes, -- 1094
			function(____, index) -- 1094
				local state = states[index] -- 1095
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1096
			end -- 1094
		), -- 1094
		usage = usage, -- 1107
		error = providerError -- 1108
	} -- 1108
end -- 1076
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1112
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1112
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1123
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1124
		local resolvedConfig = config or (function() -- 1127
			local configRes = ____exports.getActiveLLMConfig() -- 1128
			if not configRes.success then -- 1128
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1130
				return nil -- 1131
			end -- 1131
			return configRes.config -- 1133
		end)() -- 1127
		if not resolvedConfig then -- 1127
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1127
		end -- 1127
		local url = resolvedConfig.url -- 1127
		local model = resolvedConfig.model -- 1127
		local apiKey = resolvedConfig.apiKey -- 1127
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1139
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1140
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1141
		local ____model_30 = model -- 1144
		local ____url_31 = url -- 1144
		local ____temp_32 = #messages -- 1144
		local ____tostring_27 = tostring -- 1144
		local ____options_max_tokens_26 = options.max_tokens -- 1144
		if ____options_max_tokens_26 == nil then -- 1144
			____options_max_tokens_26 = "unset" -- 1144
		end -- 1144
		local ____tostring_27_result_33 = ____tostring_27(____options_max_tokens_26) -- 1144
		local ____tostring_29 = tostring -- 1144
		local ____options_temperature_28 = options.temperature -- 1144
		if ____options_temperature_28 == nil then -- 1144
			____options_temperature_28 = "unset" -- 1144
		end -- 1144
		____exports.Log( -- 1144
			"Info", -- 1144
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_30) .. " url=") .. ____url_31) .. " messages=") .. tostring(____temp_32)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_27_result_33) .. " temperature=") .. ____tostring_29(____options_temperature_28)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1144
		) -- 1144
		if stopToken and stopToken.stopped then -- 1144
			local reason = stopToken.reason or "request cancelled" -- 1146
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1147
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1147
		end -- 1147
		local ____hasReturned, ____returnValue -- 1147
		local ____try = __TS__AsyncAwaiter(function() -- 1147
			local states = {} -- 1151
			local emittedToolCallIds = {} -- 1152
			local responseId = nil -- 1153
			local responseCreated = nil -- 1154
			local responseObject = nil -- 1155
			local providerError -- 1156
			local responseUsage -- 1157
			local httpChunkCount = 0 -- 1158
			local rawStreamBytes = 0 -- 1159
			local rawStreamPreview = "" -- 1160
			local sseJSONChunkCount = 0 -- 1161
			local choiceJSONChunkCount = 0 -- 1162
			local emptyChoicesChunkCount = 0 -- 1163
			local missingChoicesChunkCount = 0 -- 1164
			local parseErrorCount = 0 -- 1165
			local doneChunkSeen = false -- 1166
			local lastJSONPreview = "" -- 1167
			local parser = ____exports.createSSEJSONParser({ -- 1168
				onJSON = function(obj, raw) -- 1169
					sseJSONChunkCount = sseJSONChunkCount + 1 -- 1170
					lastJSONPreview = previewText(raw, 500) -- 1171
					if not obj or type(obj) ~= "table" then -- 1171
						return -- 1173
					end -- 1173
					local chunk = obj -- 1175
					if chunk.error then -- 1175
						providerError = chunk.error -- 1177
						____exports.Log( -- 1178
							"Warn", -- 1178
							"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1178
						) -- 1178
						return -- 1179
					end -- 1179
					responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1181
					responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1182
					responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1183
					if chunk.usage and type(chunk.usage) == "table" then -- 1183
						responseUsage = chunk.usage -- 1185
					end -- 1185
					local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1187
					if not __TS__ArrayIsArray(chunk.choices) then -- 1187
						missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1189
						if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1189
							____exports.Log( -- 1191
								"Warn", -- 1191
								"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1191
							) -- 1191
						end -- 1191
					elseif #choices == 0 then -- 1191
						emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1194
						if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1194
							____exports.Log( -- 1196
								"Warn", -- 1196
								"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1196
							) -- 1196
						end -- 1196
					else -- 1196
						choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1199
					end -- 1199
					do -- 1199
						local i = 0 -- 1201
						while i < #choices do -- 1201
							local choice = choices[i + 1] -- 1202
							local index = type(choice.index) == "number" and choice.index or i -- 1203
							if states[index] == nil then -- 1203
								states[index] = {index = index, message = {role = "assistant"}} -- 1204
							end -- 1204
							mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1208
							i = i + 1 -- 1201
						end -- 1201
					end -- 1201
					if onChunk ~= nil then -- 1201
						onChunk( -- 1210
							buildStreamResponse( -- 1211
								states, -- 1211
								model, -- 1211
								responseId, -- 1211
								responseCreated, -- 1211
								responseObject, -- 1211
								providerError, -- 1211
								responseUsage -- 1211
							), -- 1211
							{ -- 1212
								id = chunk.id or "", -- 1213
								created = chunk.created or 0, -- 1214
								object = chunk.object or "", -- 1215
								model = chunk.model or model, -- 1216
								choices = choices -- 1217
							} -- 1217
						) -- 1217
					end -- 1217
				end, -- 1169
				onDone = function() -- 1221
					doneChunkSeen = true -- 1222
				end, -- 1221
				onError = function(err, context) -- 1224
					parseErrorCount = parseErrorCount + 1 -- 1225
					____exports.Log( -- 1226
						"Warn", -- 1226
						(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1226
					) -- 1226
				end -- 1224
			}) -- 1224
			__TS__Await(postLLM( -- 1229
				fitted.messages, -- 1229
				url, -- 1229
				apiKey, -- 1229
				model, -- 1229
				options, -- 1229
				true, -- 1229
				resolvedConfig.customOptions, -- 1229
				function(data) -- 1229
					if stopToken and stopToken.stopped then -- 1229
						return true -- 1230
					end -- 1230
					httpChunkCount = httpChunkCount + 1 -- 1231
					rawStreamBytes = rawStreamBytes + #data -- 1232
					if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1232
						rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1234
					end -- 1234
					parser.feed(data) -- 1236
					return false -- 1237
				end, -- 1229
				stopToken -- 1238
			)) -- 1238
			parser["end"]() -- 1239
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1239
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1241
				if rawResponse and type(rawResponse) == "table" then -- 1241
					local rawResponseObj = rawResponse -- 1243
					if rawResponseObj.error then -- 1243
						providerError = rawResponseObj.error -- 1245
						lastJSONPreview = previewText( -- 1246
							normalizeLLMJSONResponse(rawStreamPreview), -- 1246
							500 -- 1246
						) -- 1246
						____exports.Log( -- 1247
							"Warn", -- 1247
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1247
						) -- 1247
					end -- 1247
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then -- 1247
						responseUsage = rawResponseObj.usage -- 1250
					end -- 1250
				end -- 1250
			end -- 1250
			local response = buildStreamResponse( -- 1254
				states, -- 1254
				model, -- 1254
				responseId, -- 1254
				responseCreated, -- 1254
				responseObject, -- 1254
				providerError, -- 1254
				responseUsage -- 1254
			) -- 1254
			local tokenUsage = ____exports.extractLLMTokenUsage(response) -- 1255
			local choiceCount = response.choices and #response.choices or 0 -- 1256
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1257
			____exports.Log( -- 1258
				"Info", -- 1258
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1258
			) -- 1258
			if not doneChunkSeen then -- 1258
				local rawPreview = previewText( -- 1260
					____exports.sanitizeUTF8(rawStreamPreview), -- 1260
					1200 -- 1260
				) -- 1260
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1261
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1262
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1263
				____hasReturned = true -- 1264
				____returnValue = { -- 1264
					success = false, -- 1265
					message = message, -- 1266
					raw = rawStreamPreview, -- 1267
					response = response, -- 1268
					tokenUsage = tokenUsage -- 1269
				} -- 1269
				return -- 1264
			end -- 1264
			if not response.choices or #response.choices == 0 then -- 1264
				local providerMessage = providerError and providerError.message or "" -- 1273
				local providerType = providerError and providerError.type or "" -- 1274
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1275
				local details = table.concat( -- 1278
					__TS__ArrayFilter( -- 1278
						{providerType, providerCode}, -- 1278
						function(____, part) return part ~= "" end -- 1278
					), -- 1278
					"/" -- 1278
				) -- 1278
				local rawPreview = previewText( -- 1279
					____exports.sanitizeUTF8(rawStreamPreview), -- 1279
					1200 -- 1279
				) -- 1279
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1280
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1281
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1284
				____hasReturned = true -- 1285
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage} -- 1285
				return -- 1285
			end -- 1285
			____hasReturned = true -- 1292
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage} -- 1292
			return -- 1292
		end) -- 1292
		____try = ____try.catch( -- 1292
			____try, -- 1292
			function(____, e) -- 1292
				return __TS__AsyncAwaiter(function() -- 1292
					if stopToken and stopToken.stopped then -- 1292
						local reason = stopToken.reason or "request cancelled" -- 1299
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1300
						____hasReturned = true -- 1301
						____returnValue = {success = false, message = reason} -- 1301
						return -- 1301
					end -- 1301
					____exports.Log( -- 1303
						"Error", -- 1303
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1303
					) -- 1303
					____hasReturned = true -- 1304
					____returnValue = { -- 1304
						success = false, -- 1304
						message = tostring(e) -- 1304
					} -- 1304
					return -- 1304
				end) -- 1304
			end -- 1304
		) -- 1304
		__TS__Await(____try) -- 1150
		if ____hasReturned then -- 1150
			return ____awaiter_resolve(nil, ____returnValue) -- 1150
		end -- 1150
	end) -- 1150
end -- 1112
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1308
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1308
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1314
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1315
		local resolvedConfig = config or (function() -- 1318
			local configRes = ____exports.getActiveLLMConfig() -- 1319
			if not configRes.success then -- 1319
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1321
				return nil -- 1322
			end -- 1322
			return configRes.config -- 1324
		end)() -- 1318
		if not resolvedConfig then -- 1318
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1318
		end -- 1318
		local url = resolvedConfig.url -- 1318
		local model = resolvedConfig.model -- 1318
		local apiKey = resolvedConfig.apiKey -- 1318
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1330
		____exports.Log( -- 1331
			"Info", -- 1331
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1331
		) -- 1331
		if stopToken and stopToken.stopped then -- 1331
			local reason = stopToken.reason or "request cancelled" -- 1333
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1334
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1334
		end -- 1334
		local ____hasReturned, ____returnValue -- 1334
		local ____try = __TS__AsyncAwaiter(function() -- 1334
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1338
				fitted.messages, -- 1338
				url, -- 1338
				apiKey, -- 1338
				model, -- 1338
				options, -- 1338
				false, -- 1338
				resolvedConfig.customOptions, -- 1338
				nil, -- 1338
				stopToken -- 1338
			))) -- 1338
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1339
			____exports.Log( -- 1340
				"Info", -- 1340
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1340
			) -- 1340
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1341
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1341
				local rawPreview = previewText(raw) -- 1343
				____exports.Log( -- 1344
					"Error", -- 1344
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1344
				) -- 1344
				____hasReturned = true -- 1345
				____returnValue = { -- 1345
					success = false, -- 1346
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1347
					raw = raw -- 1348
				} -- 1348
				return -- 1345
			end -- 1345
			local responseObj = response -- 1351
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1352
			____exports.Log( -- 1353
				"Info", -- 1353
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1353
			) -- 1353
			if not responseObj.choices or #responseObj.choices == 0 then -- 1353
				local providerError = responseObj.error -- 1355
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1356
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1359
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1362
				local details = table.concat( -- 1365
					__TS__ArrayFilter( -- 1365
						{providerType, providerCode}, -- 1365
						function(____, part) return part ~= "" end -- 1365
					), -- 1365
					"/" -- 1365
				) -- 1365
				local rawPreview = previewText(raw, 400) -- 1366
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1367
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1370
				____hasReturned = true -- 1371
				____returnValue = {success = false, message = message, raw = raw} -- 1371
				return -- 1371
			end -- 1371
			____hasReturned = true -- 1377
			____returnValue = {success = true, response = responseObj} -- 1377
			return -- 1377
		end) -- 1377
		____try = ____try.catch( -- 1377
			____try, -- 1377
			function(____, e) -- 1377
				return __TS__AsyncAwaiter(function() -- 1377
					if stopToken and stopToken.stopped then -- 1377
						local reason = stopToken.reason or "request cancelled" -- 1383
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1384
						____hasReturned = true -- 1385
						____returnValue = {success = false, message = reason} -- 1385
						return -- 1385
					end -- 1385
					____exports.Log( -- 1387
						"Error", -- 1387
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1387
					) -- 1387
					____hasReturned = true -- 1388
					____returnValue = { -- 1388
						success = false, -- 1388
						message = tostring(e) -- 1388
					} -- 1388
					return -- 1388
				end) -- 1388
			end -- 1388
		) -- 1388
		__TS__Await(____try) -- 1337
		if ____hasReturned then -- 1337
			return ____awaiter_resolve(nil, ____returnValue) -- 1337
		end -- 1337
	end) -- 1337
end -- 1308
return ____exports -- 1308